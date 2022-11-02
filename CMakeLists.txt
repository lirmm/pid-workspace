#########################################################################################
#       This file is part of the program PID                                            #
#       Program description : build system supportting the PID methodology              #
#       Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique     #
#       et de Microelectronique de Montpellier). All Right reserved.                    #
#                                                                                       #
#       This software is free software: you can redistribute it and/or modify           #
#       it under the terms of the CeCILL-C license as published by                      #
#       the CEA CNRS INRIA, either version 1                                            #
#       of the License, or (at your option) any later version.                          #
#       This software is distributed in the hope that it will be useful,                #
#       but WITHOUT ANY WARRANTY; without even the implied warranty of                  #
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                    #
#       CeCILL-C License for more details.                                              #
#                                                                                       #
#       You can find the complete license description on the official website           #
#       of the CeCILL licenses family (http://www.cecill.info/index.en.html)            #
#########################################################################################

cmake_minimum_required(VERSION 3.15.7)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/api)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/commands)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/platforms)

include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)

project(pid-workspace C CXX ASM)

# Remove the "Built target xxx" messages emitted by Make
set(CMAKE_TARGET_MESSAGES OFF CACHE INTERNAL "")

file(RELATIVE_PATH DIR_NAME ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})
if(DIR_NAME STREQUAL "build")

	### set global workspace variables ###
	set(WORKSPACE_DIR ${CMAKE_SOURCE_DIR} CACHE INTERNAL "")
	option(IN_CI_PROCESS "Determine wether the build takes place in a CI environment (ON) or not (default to OFF)." OFF)
	option(ADDITIONAL_DEBUG_INFO "Get debug info from configuration" OFF)
	option(SHOW_WRAPPERS_BUILD_OUTPUT "Force to always display the wrappers build output (only shown on error by default)" OFF)
	set(LIMITED_JOBS_PACKAGES "" CACHE STRING "List of packages to build with only one job")
	option(FORCE_DUAL_MODE "Force all build and deployment to be made in dual mode -Release and Debug" OFF)
	mark_as_advanced(IN_CI_PROCESS)
	set(PACKAGE_BINARY_INSTALL_DIR ${CMAKE_SOURCE_DIR}/install CACHE INTERNAL "")
	# write the configuration file to memorize at global scope (in build folder) the global workspace configuration information
	write_Workspace_Global_Info_File(${CMAKE_BINARY_DIR}/Workspace_Global_Info.cmake)

	### management of workspace repository ###
	configure_Git()
	if(NOT GIT_CONFIGURED)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: your git tool is NOT configured. To use PID you need to configure git:\n git config --global user.name \"Your Name\" \n git config --global user.email <your email address> \n")
	endif()
	# automatically managing reference to official remote repository #####
	set(PID_OFFICIAL_REMOTE_ADDRESS "https://gite.lirmm.fr/pid/pid-workspace.git" CACHE STRING "address of the official PID repository") #this is the "central" repo for PID system
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git remote -v OUTPUT_VARIABLE res)
	string(REPLACE "\n" ";" GIT_REMOTES ${res})
	set(OFFICIAL_EXISTS)
	foreach(remote IN LISTS GIT_REMOTES)# for each git remote defined in repository
		if(remote)#guard to avoid last semincolon to generate an empty element that makes the reges command crash
			string(REGEX REPLACE "^[ \t]*official[ \t]+([^ \t]+)[ \t]*\\(fetch\\)(.*)$" "\\1" OFFICIAL_ADDR ${remote})
			if(NOT "${remote}" STREQUAL "${OFFICIAL_ADDR}")#i.e. match => official already exists
				set(OFFICIAL_EXISTS ${OFFICIAL_ADDR})
				break()
			endif()
		endif()
	endforeach()
	if(NOT OFFICIAL_EXISTS) # automatically create a branch called official that points to the official remote. This is a sanity action to avoid troubles on updates / deployments.
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git remote add official ${PID_OFFICIAL_REMOTE_ADDRESS})
	elseif(NOT OFFICIAL_EXISTS STREQUAL PID_OFFICIAL_REMOTE_ADDRESS)#strange thing remote may have changed
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git remote set-url official ${PID_OFFICIAL_REMOTE_ADDRESS})
	endif()

	### management of PID version ###
	# set the current PID version to memorize when updating the workspace.
	set(PID_SYSTEM_VERSION 5 CACHE INTERNAL "")
	configure_file(${CMAKE_SOURCE_DIR}/cmake/patterns/PID_version.cmake.in ${CMAKE_BINARY_DIR}/PID_version.cmake @ONLY) #put it into a file to allow packages to easily retrieve PID version information

	### management of workspace configuration ###
	# manage_Migrations() #specific action to manage migration between workspace versions
	reset_Contribution_Spaces() #define what is known in the local workspace
	reset_Profiles() # define the development environment based on current profile
elseif(DIR_NAME MATCHES "build/host$")
	manage_Host_Default_Platform()
	return()
elseif(DIR_NAME MATCHES "build/(.+)")#subfolder of build: profile specific folder
	load_Current_Contribution_Spaces()#simply load the contribution space from higher level
	read_Profiles_Description_File(FILE_EXISTS)#from here we are sure the file exists
	include(${CMAKE_BINARY_DIR}/Workspace_Solution_File.cmake)#get the complete description
	manage_Platforms() # define all properties of the current platform in use (based on current build environment)
  	manage_Plugins() # extract plugins in use from each environment according to the current profile in use
	return()
endif()

### generate symlinks necessary for backward compatibility with versions < 4 ###
create_Backward_Compatibility_Symlinks()

### memorize local workspace content ###
#1) reset information about categories
reset_All_Categories()
#2) list the content of the workspace to get clean information about packages and framework
reset_Workspace_Content_Information()
#3) classifying packages w.r.t. framework and categories (framework are set of categories and packages belong to some categories)
classify_Packages()
#4) creating the file that will be used to manage information about categories, packages and frameworks in script file
write_Categories_File()

### adding custom targets providing workspace level commands ###
macro(add_PID_Command name script)
	if(${CMAKE_GENERATOR} STREQUAL "Unix Makefiles")
		set(ARGS ${name}_args)
	endif()
	set(OPTIONS ${name}_options)
	add_custom_target(
		${name}
		COMMAND ${CMAKE_COMMAND}
			${ARGS}
			${OPTIONS}
			-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
			-DADDITIONAL_DEBUG_INFO=${ADDITIONAL_DEBUG_INFO}
			-DSHOW_WRAPPERS_BUILD_OUTPUT=${SHOW_WRAPPERS_BUILD_OUTPUT}
			-P ${CMAKE_SOURCE_DIR}/cmake/commands/${script}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	)
endmacro(add_PID_Command)

# Display help for workspace commands
set(man_args "-DCOMMAND_INFO=\"\${cmd}\"")
add_PID_Command(man Print_Workspace_Man.cmake)

## getting info on the workspace, packages, frameworks or licenses
set(info_args "\
	-DTARGET_PACKAGE=\"\${package}\" \
	-DTARGET_FRAMEWORK=\${framework} \
	-DTARGET_ENVIRONMENT=\${environment} \
	-DTARGET_LANGUAGE=\${language} \
	-DTARGET_LICENSE=\${license} \
  -DSEARCH_EXPR=\${search} ")
add_PID_Command(info Print_PID_Workspace_Info.cmake)

## deploying a package (either soure repository or binary package relocatable archive)
set(deploy_args "\
	-DDEPLOYED_PACKAGE=\${package} \
	-DTARGET_VERSION=\${version} \
	-DDEPLOYED_ENVIRONMENT=\${environment} \
	-DDEPLOYED_FRAMEWORK=\${framework} \
	-DVERBOSE_MODE=\${verbose} \
	-DFORCE_REDEPLOY=\${force} \
	-DUSE_BINARIES=\${use_binaries} \
	-DUSE_SOURCE=\${use_source} \
	-DUSE_BRANCH=\${branch} \
	-DRUN_TESTS=\${test} \
	-DRELEASE_ONLY=\${release_only}")
add_PID_Command(deploy Deploy_PID_Deployment_Unit.cmake)

## building a list of source packages
set(build_args " -DTARGET_PACKAGES=\${package} ")
add_PID_Command(build Build_PID_Packages.cmake)

## rebuilding a list of source packages
set(rebuild_args " -DTARGET_PACKAGES=\${package} ")
add_PID_Command(rebuild Rebuild_PID_Packages.cmake)

## resolving runtime dependencies of an already installed package
set(resolve_args "\
	-DRESOLVED_PACKAGE=\${package} \
	-DTARGET_VERSION=\${version} ) \
  -DRELEASE_ONLY=\${release_only} ")
add_PID_Command(resolve Resolve_PID_Package.cmake)

## creating a new package
set(create_args "\
	-DTARGET_PACKAGE=\${package} \
	-DTARGET_FRAMEWORK=\${framework} \
	-DTARGET_WRAPPER=\${wrapper} \
	-DTARGET_ENVIRONMENT=\${environment} \
	-DOPTIONAL_AUTHOR=\${author} \
	-DOPTIONAL_INSTITUTION=\${affiliation} \
	-DOPTIONAL_EMAIL=\${email} \
	-DOPTIONAL_LICENSE=\${license} \
	-DOPTIONAL_CODE_STYLE=\${code_style} \
	-DOPTIONNAL_GIT_URL=\${url} \
	-DOPTIONNAL_SITE=\${site} ")
add_PID_Command(create Create_PID_Deployment_Unit.cmake)

## connect to newly created PID package to an existing empty repository
set(connect_args "\
	-DTARGET_FRAMEWORK=\${framework} \
	-DTARGET_PACKAGE=\${package} \
	-DTARGET_WRAPPER=\${wrapper} \
	-DTARGET_ENVIRONMENT=\${environment} \
	-DOFFICIAL_GIT_URL=\${official} \
	-DORIGIN_GIT_URL=\${origin} \
	-DFORCED_RECONNECTION=\${force} ")
add_PID_Command(connect Connect_PID_Deployment_Unit.cmake)

## clearing a package install directory
set(uninstall_args "\
	-DTARGET_PACKAGE=\${package} \
	-DTARGET_VERSION=\${version} ")
add_PID_Command(uninstall Clear_PID_Package.cmake)

## clearing a package install directory
set(hard_clean_args "\
	-DTARGET_PACKAGE=\${package} \
	-DTARGET_FRAMEWORK=\${framework} \
	-DTARGET_ENVIRONMENT=\${environment} \
	-DRECONFIGURE=\${configure} ")
add_PID_Command(hard_clean Hard_Clean_PID_Package.cmake)

## completely remove a package from workspace
set(remove_args "\
	-DTARGET_PACKAGE=\${package} \
	-DTARGET_FRAMEWORK=\${framework} \
	-DTARGET_ENVIRONMENT=\${environment} ")
add_PID_Command(remove Remove_PID_Deployment_Unit.cmake)

## register a package in the workspace
set(register_args "\
	-DTARGET_PACKAGE=\${package} \
	-DTARGET_FRAMEWORK=\${framework} \
	-DTARGET_ENVIRONMENT=\${environment} \
  -DTARGET_CS=\${space} ")
add_PID_Command(register Register_PID_Deployment_Unit.cmake)

## unregister a package
set(unregister_args "\
	-DTARGET_PACKAGE=\${package} \
	-DTARGET_FRAMEWORK=\${framework} \
	-DTARGET_ENVIRONMENT=\${environment} \
  -DTARGET_CS=\${space} ")
add_PID_Command(unregister Unregister_PID_Deployment_Unit.cmake)

## releasing a package
set(release_args "\
	-DTARGET_PACKAGE=\${package} \
	-DNEXT_VERSION=\${nextversion} \
	-DFROM_BRANCH=\${branch} \
	-DFROM_PATCH=\${patch} \
	-DAUTOMATIC_RELEASE=\${recursive} ")
add_PID_Command(release Release_PID_Package.cmake)

## deprecate package versions (kind of unrelease operation)
set(release_args "\
	-DTARGET_PACKAGE=\${package} \
	-DTARGET_VERSION=\${version} \ ")
add_PID_Command(deprecate Deprecate_PID_Package_Versions.cmake)

## updating a package
set(update_args "\
	-DTARGET_PACKAGE=\${package} \
	-DTARGET_ENVIRONMENT=\${environment} \
	-DTARGET_FRAMEWORK=\${framework} \
	-DFORCE_SOURCE=\${force_source} ")
add_PID_Command(update Update_PID_Deployment_Unit.cmake)

## upgrading the workspace
set(upgrade_args "\
	-DTARGET_OFFICIAL=\${official} \
	-DUPDATE_ALL_PACKAGES=\${update} ")
add_PID_Command(upgrade Upgrade_PID_Workspace.cmake)

## upgrading the workspace
set(install_args "\
	-DINSTALLED_PACKAGE=\${package} \
	-DTARGET_VERSION=\${version} \
	-DINSTALL_FOLDER=\${folder} \
	-DINSTALL_MODE=\${mode} ")
set(install_options "\
	-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \
	-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")
add_PID_Command(sysinstall Install_PID_Package.cmake)

## configuring the workspace
set(profiles_args "\
	-DTARGET_COMMAND=\${cmd} \
	-DTARGET_PROFILE=\${profile} \
	-DTARGET_ENVIRONMENT=\${env} \
	-DTARGET_INSTANCE=\${instance} \
	-DTARGET_SYSROOT=\${sysroot} \
	-DTARGET_STAGING=\${staging} \
	-DTARGET_PLATFORM=\${platform} \
	-DTARGET_PROC_TYPE=\${proc_type} \
	-DTARGET_PROC_ARCH=\${proc_arch} \
	-DTARGET_OS=\${os} \
	-DTARGET_ABI=\${abi} \
	-DTARGET_DISTRIBUTION=\${distribution} \
	-DTARGET_DISTRIBUTION_VERSION=\${distrib_version} ")
set(profiles_options "\
	-DIN_CI_PROCESS=${IN_CI_PROCESS} \
	-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}") #using default or current native build system
add_PID_Command(profiles Manage_PID_Profiles.cmake)

## manage contribution spaces
set(contributions_args "\
	-DTARGET_COMMAND=\${cmd} \
	-DTARGET_CS=\${space} \
	-DUPDATE_URL=\${update} \
	-DPUBLISH_URL=\${publish} \
	-DSOURCE_CS=\${from} \
	-DCONTENT_TO_OPERATE=\${content} ")
set(contributions_options "\
	-DIN_CI_PROCESS=${IN_CI_PROCESS} \
	-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}") #using default or current native build system
add_PID_Command(contributions Manage_PID_Contribution_Spaces.cmake)

add_PID_Command(workspace_path Print_Workspace_Path.cmake)

# Targets to run when no target is specified
add_custom_target(
    default
    ALL
    DEPENDS
        man
        info
)