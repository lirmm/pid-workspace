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

########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(PID_Set_Policies NO_POLICY_SCOPE)

include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Version_Management_Functions NO_POLICY_SCOPE)
include(PID_Progress_Management_Functions NO_POLICY_SCOPE)
include(PID_Finding_Functions NO_POLICY_SCOPE)
include(PID_Package_Configuration_Functions NO_POLICY_SCOPE)
include(PID_Package_Cache_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Build_Targets_Management_Functions NO_POLICY_SCOPE)
include(PID_Documentation_Management_Functions NO_POLICY_SCOPE)
include(PID_Deployment_Functions NO_POLICY_SCOPE)
include(PID_Package_Coding_Support NO_POLICY_SCOPE)
include(PID_Continuous_Integration_Functions NO_POLICY_SCOPE)
include(PID_Plugins_Management NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
include(PID_Meta_Information_Management_Functions NO_POLICY_SCOPE)

##################################################################################
#################### package management public functions and macros ##############
##################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Package| replace:: ``declare_Package``
#  .. declare_Package:
#
#  declare_Package
#  ---------------
#
#   .. command:: declare_Package(author institution mail year license address public_address description readme_file)
#
#     Declare the current CMake project as a native package. Internal counterpart to declare_PID_Package.
#
#     :author: the name of the contact author.
#     :institution: the institution(s) to which the contact author belongs.
#     :mail: E-mail of the contact author.
#     :year: reflects the lifetime of the package.
#     :license: The name of the license applying to the package.
#     :address: The url of the package's official repository.
#     :public_address: the public counterpart url to address.
#     :description: a short description of the package.
#     :readme_file: the path to a user-defined content of the readme file of the package.
#
macro(declare_Package author institution mail year license address public_address description readme_file)
activate_Adequate_Languages()
file(RELATIVE_PATH DIR_NAME ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})
set(CMAKE_INCLUDE_SYSTEM_FLAG_CXX "-I")#to avoid the use of -isystem that may be not so well managed by some compilers

manage_Current_Platform(${DIR_NAME}) #loading the current platform configuration and perform adequate actions if any changes
set(${PROJECT_NAME}_ROOT_DIR CACHE INTERNAL "")
#################################################
############ Managing options ###################
#################################################
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake) # adding the cmake scripts files from the package
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/find) # using common find modules of the workspace
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references) # using common find modules of the workspace
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/constraints/platforms) # using platform check modules

configure_Git()
set(${PROJECT_NAME}_ARCH ${CURRENT_PLATFORM_ARCH} CACHE INTERNAL "")#to keep compatibility with PID v1 released package versions
initialize_Build_System()#initializing PID specific settings for build

#################################################
############ MANAGING build mode ################
#################################################
manage_Parrallel_Build_Option()
if(DIR_NAME STREQUAL "build/release")
	reset_Mode_Cache_Options(CACHE_POPULATED)
	#setting the variables related to the current build mode
	set(CMAKE_BUILD_TYPE "Release" CACHE String "the type of build is dependent from build location" FORCE)
	set (INSTALL_NAME_SUFFIX "" CACHE INTERNAL "")
	set (USE_MODE_SUFFIX "" CACHE INTERNAL "")
	if(NOT CACHE_POPULATED)
		finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : misuse of PID functionnalities -> you must run cmake command from the build folder at first time.")
		return()
	endif()
elseif(DIR_NAME STREQUAL "build/debug")
	reset_Mode_Cache_Options(CACHE_POPULATED)
	#setting the variables related to the current build mode
	set(CMAKE_BUILD_TYPE "Debug" CACHE String "the type of build is dependent from build location" FORCE)
	set(INSTALL_NAME_SUFFIX -dbg CACHE INTERNAL "")
	set(USE_MODE_SUFFIX "_DEBUG" CACHE INTERNAL "")
	if(NOT CACHE_POPULATED)
		finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : misuse of PID functionnalities -> you must run cmake command from the build folder at first time.")
		return()
	endif()
elseif(DIR_NAME STREQUAL "build")
	declare_Native_Global_Cache_Options() #first of all declaring global options so that the package is preconfigured with default options values and adequate comments for each variable

	file(WRITE ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/release/share/checksources "")
	file(WRITE ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/release/share/rebuilt "")

	################################################################################################
	################################ General purpose targets #######################################
	################################################################################################

	# target to check if source tree need to be rebuilt
	add_custom_target(checksources
			COMMAND ${CMAKE_COMMAND} -DWORKSPACE_DIR=${WORKSPACE_DIR}
						 -DPACKAGE_NAME=${PROJECT_NAME}
						 -DSOURCE_PACKAGE_CONTENT=${CMAKE_BINARY_DIR}/release/share/Info${PROJECT_NAME}.cmake
						 -P ${WORKSPACE_DIR}/share/cmake/system/commands/Check_PID_Package_Modification.cmake
			COMMENT "[PID] Checking for modified source tree ..."
    	)

	# target to reconfigure the project
	add_custom_command(OUTPUT ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/release/share/rebuilt
			COMMAND ${CMAKE_MAKE_PROGRAM} rebuild_cache
			COMMAND ${CMAKE_COMMAND} -E touch ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/release/share/rebuilt
			DEPENDS ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/release/share/checksources
			COMMENT "[PID] Reconfiguring the package ..."
    	)
	add_custom_target(reconfigure
			DEPENDS ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/release/share/rebuilt
    	)

	add_dependencies(reconfigure checksources)


	# update target (update the package from upstream git repository)
	add_custom_target(update
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-P ${WORKSPACE_DIR}/share/cmake/system/commands/Update_PID_Package.cmake
		COMMENT "[PID] Updating the package ..."
		VERBATIM
	)

	add_custom_target(integrate
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DWITH_OFFICIAL=\${official}
						-P ${WORKSPACE_DIR}/share/cmake/system/commands/Integrate_PID_Package.cmake
		COMMENT "[PID] Integrating modifications ..."
	)

	# updating version of PID
	add_custom_target(sync-version
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-P ${WORKSPACE_DIR}/share/cmake/system/commands/Synchronize_PID_Package_Version.cmake
		COMMENT "[PID] Synchronizing the package version with workspace current version..."
		VERBATIM
	)

	# checking that the build takes place on integration
	add_custom_target(check-branch
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DGIT_REPOSITORY=${CMAKE_SOURCE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
					-DFORCE_RELEASE_BUILD=\${force}
						-P ${WORKSPACE_DIR}/share/cmake/system/commands/Check_PID_Package_Branch.cmake
		COMMENT "[PID] Checking branch..."
	)


	# checking that the official has not been modified (migration)
	if(${PROJECT_NAME}_ADDRESS) #only if there is an official address spefified
	add_custom_target(check-repository
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-P ${WORKSPACE_DIR}/share/cmake/system/commands/Check_PID_Package_Official_Repository.cmake
		COMMENT "[PID] Checking official repository consistency..."
		VERBATIM
	)
	endif()

	################################################################################################
	############ creating custom targets to delegate calls to mode specific targets ################
	################################################################################################

	if(RUN_TESTS_WITH_PRIVILEGES)
		set(SUDOER_PRIVILEGES sudo)
	else()
		set(SUDOER_PRIVILEGES)
	endif()
	# global build target
	if(BUILD_RELEASE_ONLY)
		add_custom_target(build
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} build
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR} ${CMAKE_COMMAND} -E touch build_process
			COMMENT "[PID] Building package (Release mode only) for platform ${CURRENT_PLATFORM} using environment ${CURRENT_ENVIRONMENT} ..."
			VERBATIM
		)
	else()
		add_custom_target(build
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} build
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} build
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR} ${CMAKE_COMMAND} -E touch build_process
			COMMENT "[PID] Building package (Debug and Release modes) for platform ${CURRENT_PLATFORM} using environment ${CURRENT_ENVIRONMENT} ..."
			VERBATIM
		)
		#mode specific build commands
		add_custom_target(build_release
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} build
			COMMENT "[PID] Release build for platform ${CURRENT_PLATFORM} using environment ${CURRENT_ENVIRONMENT} ..."
			VERBATIM
		)
		add_dependencies(build_release reconfigure) #checking if reconfiguration is necessary before build
		add_dependencies(build_release sync-version)#checking if PID version synchronizing needed before build
		add_dependencies(build_release check-branch)#checking if not built on master branch or released tag
		if(${PROJECT_NAME}_ADDRESS)
		add_dependencies(build_release check-repository) #checking if remote addrr needs to be changed
		endif()
		add_custom_target(build_debug
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} build
			COMMENT "[PID] Debug build for platform ${CURRENT_PLATFORM} using environment ${CURRENT_ENVIRONMENT} ..."
			VERBATIM
		)
		add_dependencies(build_debug reconfigure) #checking if reconfiguration is necessary before build
		add_dependencies(build_debug sync-version)#checking if PID version synchronizing needed before build
		add_dependencies(build_debug check-branch)#checking if not built on master branch or released tag
		if(${PROJECT_NAME}_ADDRESS)
		add_dependencies(build_debug check-repository) #checking if remote addrr needs to be changed
	  endif()
	endif()


	add_dependencies(build reconfigure) #checking if reconfiguration is necessary before build
	add_dependencies(build sync-version)#checking if PID version synchronizing needed before build
	add_dependencies(build check-branch)#checking if not built on master branch or released tag
	if(${PROJECT_NAME}_ADDRESS)
	add_dependencies(build check-repository) #checking if remote addrr needs to be changed
	endif()

	if(BUILD_RELEASE_ONLY)
		add_custom_target(global_main ALL
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
			COMMENT "[PID] Compiling and linking package (Release mode only) ..."
			VERBATIM
		)
	else()
		add_custom_target(global_main ALL
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
			COMMENT "[PID] Compiling and linking package (Debug and Release modes) ..."
			VERBATIM
		)
	endif()

	# redefinition of clean target (cleaning the build tree)
	add_custom_target(cleaning
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} clean
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} clean
		COMMENT "[PID] Cleaning package (Debug and Release modes) ..."
		VERBATIM
	)

	# reference file generation target
	add_custom_target(referencing
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} referencing
		COMMENT "[PID] Generating and installing reference to the package ..."
		VERBATIM
	)

	# redefinition of install target
	add_custom_target(installing
		COMMAND ${CMAKE_COMMAND} -E  echo Installing ${PROJECT_NAME} Debug artefacts
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} install
		COMMAND ${CMAKE_COMMAND} -E  echo Installing ${PROJECT_NAME} Release artefacts
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} install
		COMMENT "[PID] Installing the package ..."
		VERBATIM
	)

	# uninstall target (cleaning the install tree)
	add_custom_target(uninstall
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} uninstall
		COMMENT "[PID] Uninstalling the package ..."
		VERBATIM
	)


	# site target (generation of a static site documenting the project)
	add_custom_target(site
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} site
		COMMENT "[PID] Creating/Updating web pages of the project ..."
		VERBATIM
	)

	if(BUILD_AND_RUN_TESTS AND NOT PID_CROSSCOMPILATION)
		# test target (launch test units, redefinition of tests)
		if(BUILD_TESTS_IN_DEBUG)
			add_custom_target(testing
				COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${SUDOER_PRIVILEGES} ${CMAKE_MAKE_PROGRAM} test
				COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${SUDOER_PRIVILEGES} ${CMAKE_MAKE_PROGRAM} test
				COMMENT "[PID] Launching tests ..."
				VERBATIM
			)
		else()
			add_custom_target(testing
				COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${SUDOER_PRIVILEGES} ${CMAKE_MAKE_PROGRAM} test
				COMMENT "[PID] Launching tests ..."
				VERBATIM
			)
		endif()
		if(BUILD_COVERAGE_REPORT)
			add_custom_target(coverage
				COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${SUDOER_PRIVILEGES}${CMAKE_MAKE_PROGRAM} coverage
				COMMENT "[PID] Generating coverage report for tests ..."
				VERBATIM
			)
			add_dependencies(site coverage)
		endif()
	endif()


	if(BUILD_STATIC_CODE_CHECKING_REPORT)
		add_custom_target(staticchecks
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} staticchecks
			COMMENT "[PID] Generating static checks report ..."
			VERBATIM
		)
		add_dependencies(site staticchecks)
	endif()

	if(BUILD_API_DOC)
		# doc target (generation of API documentation)
		add_custom_target(doc
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} doc
			COMMENT "[PID] Generating API documentation ..."
			VERBATIM
		)
		add_dependencies(site doc)
	endif()

	if(GENERATE_INSTALLER)
		# package target (generation and install of a UNIX binary packet)
		add_custom_target(package
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} package
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} package_install
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} package
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} package_install
			COMMENT "[PID] Generating and installing system binary package ..."
			VERBATIM
		)
		add_dependencies(site package)
	endif()

	if(NOT "${license}" STREQUAL "")
		# target to add licensing information to all source files
		add_custom_target(licensing
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} licensing
			COMMENT "[PID] Applying license to sources ..."
			VERBATIM
		)
	endif()
	if(ADDITIONNAL_DEBUG_INFO)
		add_custom_target(list_dependencies
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} list_dependencies
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} list_dependencies
			COMMENT "[PID] listing dependencies of the package ..."
			VERBATIM
		)
	else()
		add_custom_target(list_dependencies
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} list_dependencies
			COMMENT "[PID] listing dependencies of the package ..."
			VERBATIM
		)
	endif()

	if(BUILD_DEPENDENT_PACKAGES AND ADDITIONNAL_DEBUG_INFO)
		message("[PID] INFO : build process of ${PROJECT_NAME} will be recursive.")
	endif()

	if(NOT EXISTS ${CMAKE_BINARY_DIR}/debug OR NOT IS_DIRECTORY ${CMAKE_BINARY_DIR}/debug)
		execute_process(COMMAND ${CMAKE_COMMAND} -E  make_directory debug WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
	endif()
	if(NOT EXISTS ${CMAKE_BINARY_DIR}/release OR NOT IS_DIRECTORY ${CMAKE_BINARY_DIR}/release)
		execute_process(COMMAND ${CMAKE_COMMAND} -E  make_directory release WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
	endif()

	#getting global options (those set by the user)
	set_Mode_Specific_Options_From_Global()

	#calling cmake for each build mode (continue package configuration for Release and Debug Modes
	execute_process(COMMAND ${CMAKE_COMMAND} -DWORKSPACE_DIR=${WORKSPACE_DIR} ${CMAKE_SOURCE_DIR} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/debug)
	execute_process(COMMAND ${CMAKE_COMMAND} -DWORKSPACE_DIR=${WORKSPACE_DIR} ${CMAKE_SOURCE_DIR} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/release)

	#now getting options specific to debug and release modes
	set_Global_Options_From_Mode_Specific()

	return()# execution of the root CMakeLists.txt ends for general build
else()	# the build must be done in the build directory
	message("[PID] ERROR : please run cmake in the build folder of the package ${PROJECT_NAME}.")
	return()
endif()

#################################################
######## Initializing cache variables ###########
#################################################
reset_Package_Description_Cached_Variables()
reset_Documentation_Info()
reset_CI_Variables()
reset_Package_Platforms_Variables()
reset_Packages_Finding_Variables()
init_PID_Version_Variable()
init_Meta_Info_Cache_Variables("${author}" "${institution}" "${mail}" "${description}" "${year}" "${license}" "${address}" "${public_address}" "${readme_file}")
reset_Version_Cache_Variables()
check_For_Remote_Respositories("${PROJECT_NAME}" "${address}")
init_Standard_Path_Cache_Variables()
begin_Progress(${PROJECT_NAME} GLOBAL_PROGRESS_VAR) #managing the build from a global point of view
endmacro(declare_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Documentation_Target| replace:: ``create_Documentation_Target``
#  .. _create_Documentation_Target:
#
#  create_Documentation_Target
#  ---------------------------
#
#   .. command:: create_Documentation_Target()
#
#     Create the "site" target for currently defined package project, used to launch static site update.
#
function(create_Documentation_Target)
if(NOT ${CMAKE_BUILD_TYPE} MATCHES Release) # the documentation can be built in release mode only
	return()
endif()

package_License_Is_Closed_Source(CLOSED ${PROJECT_NAME} FALSE)
get_System_Variables(CURRENT_PLATFORM_NAME CURRENT_PACKAGE_STRING)
set(INCLUDING_BINARIES FALSE)
set(INCLUDING_COVERAGE FALSE)
set(INCLUDING_STATIC_CHECKS FALSE)
if(NOT CLOSED)#check if project is closed source or not

	# management of binaries publication
	if(${PROJECT_NAME}_BINARIES_AUTOMATIC_PUBLISHING)
		set(INCLUDING_BINARIES TRUE)
	endif()

	#checking for coverage generation
	if(BUILD_COVERAGE_REPORT AND PROJECT_RUN_TESTS)
		set(INCLUDING_COVERAGE TRUE)
	endif()

	#checking for coverage generation
	if(BUILD_STATIC_CODE_CHECKING_REPORT AND NOT CLOSED)
		set(INCLUDING_STATIC_CHECKS TRUE)
	endif()

endif()

if(${PROJECT_NAME}_SITE_GIT_ADDRESS) #the publication of the static site is done within a lone static site

	add_custom_target(site
		COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DTARGET_VERSION=${${PROJECT_NAME}_VERSION}
						-DTARGET_PLATFORM=${CURRENT_PLATFORM_NAME}
						-DCMAKE_COMMAND=${CMAKE_COMMAND}
						-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
						-DINCLUDES_API_DOC=${BUILD_API_DOC}
						-DINCLUDES_COVERAGE=${INCLUDING_COVERAGE}
						-DINCLUDES_STATIC_CHECKS=${INCLUDING_STATIC_CHECKS}
						-DINCLUDES_INSTALLER=${INCLUDING_BINARIES}
						-DSYNCHRO=\${synchro}
						-DFORCED_UPDATE=\${force}
						-DSITE_GIT="${${PROJECT_NAME}_SITE_GIT_ADDRESS}"
						-DPACKAGE_PROJECT_URL="${${PROJECT_NAME}_PROJECT_PAGE}"
						-DPACKAGE_SITE_URL="${${PROJECT_NAME}_SITE_ROOT_PAGE}"
			 -P ${WORKSPACE_DIR}/share/cmake/system/commands/Build_PID_Site.cmake)
elseif(${PROJECT_NAME}_FRAMEWORK) #the publication of the static site is done with a framework

	add_custom_target(site
		COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DTARGET_VERSION=${${PROJECT_NAME}_VERSION}
						-DTARGET_PLATFORM=${CURRENT_PLATFORM_NAME}
						-DCMAKE_COMMAND=${CMAKE_COMMAND}
						-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
						-DTARGET_FRAMEWORK=${${PROJECT_NAME}_FRAMEWORK}
						-DINCLUDES_API_DOC=${BUILD_API_DOC}
						-DINCLUDES_COVERAGE=${INCLUDING_COVERAGE}
						-DINCLUDES_STATIC_CHECKS=${INCLUDING_STATIC_CHECKS}
						-DINCLUDES_INSTALLER=${INCLUDING_BINARIES}
						-DSYNCHRO=\${synchro}
						-DPACKAGE_PROJECT_URL="${${PROJECT_NAME}_PROJECT_PAGE}"
			 -P ${WORKSPACE_DIR}/share/cmake/system/commands/Build_PID_Site.cmake
	)
endif()
endfunction(create_Documentation_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Current_Version| replace:: ``set_Current_Version``
#  .. _set_Current_Version:
#
#  set_Current_Version
#  -------------------
#
#   .. command:: set_Current_Version(major minor patch)
#
#     Set the version of currently defined package project.
#
#     :major: the major version number
#
#     :minor: the minor version number
#
#     :patch: the patch version number
#
function(set_Current_Version major minor patch)
	set_Version_Cache_Variables("${major}" "${minor}" "${patch}")
	set_Install_Cache_Variables()
endfunction(set_Current_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Platform_Constraints| replace:: ``check_Platform_Constraints``
#  .. _check_Platform_Constraints:
#
#  check_Platform_Constraints
#  --------------------------
#
#   .. command:: check_Platform_Constraints(RESULT IS_CURRENT type arch os abi constraints)
#
#     Check that the platform constraints provided match the current platform configuration. Constraints are checked only if the current platform matches platform filters provided.
#
#     :type: the target processor type used as a filter (may be empty string if no filter).
#
#     :arch: the target processor architecture (bits) used as a filter (may be empty string if no filter).
#
#     :os: the target kernel used as a filter (may be empty string if no filter).
#
#     :abi: the target abi type used as a filter (may be empty string if no filter).
#
#     :RESULT: the output variable that is TRUE if constraints are satisfied or if no constraint appliesdu to filters, FALSE if any constraint cannot be satisfied.
#
#     :IS_CURRENT: the output variable that contains the current platform identifier if current platformmatches all filters.
#
function(check_Platform_Constraints RESULT IS_CURRENT type arch os abi constraints)
set(SKIP FALSE)
#The check of compatibility between the target platform and the constraints is immediate using platform configuration information (platform files) + additionnal global information (distribution for instance) coming from the workspace

#1) checking the conditions to know if the configuration concerns the platform currently in use
if(type AND NOT type STREQUAL "") # a processor type is specified, so it applies like a filter on current platform
	if(NOT CURRENT_PLATFORM_TYPE STREQUAL ${type})
		set(SKIP TRUE)
	endif()
endif()

if(NOT SKIP AND arch AND NOT arch STREQUAL "") # a processor architecture is specified, so it applies like a filter on current platform
	if(NOT CURRENT_PLATFORM_ARCH STREQUAL ${arch})
		set(SKIP TRUE)
	endif()
endif()

if(NOT SKIP AND os AND NOT os STREQUAL "") # an operating system is specified, so it applies like a filter on current platform
	if(NOT CURRENT_PLATFORM_OS STREQUAL ${os})
		set(SKIP TRUE)
	endif()
endif()

if(NOT SKIP AND abi AND NOT abi STREQUAL "") # an operating system is specified, so it applies like a filter on current platform
	if(NOT CURRENT_PLATFORM_ABI STREQUAL ${abi})
		set(SKIP TRUE)
	endif()
endif()

#2) testing configuration constraints if the platform currently in use satisfies conditions
#
set(${RESULT} TRUE PARENT_SCOPE)
if(SKIP)
	set(${IS_CURRENT} PARENT_SCOPE)
else()
	set(${IS_CURRENT} ${CURRENT_PLATFORM} PARENT_SCOPE)
endif()

if(NOT SKIP AND constraints)
	foreach(config IN LISTS constraints) ## all constraints must be satisfied
		if(EXISTS ${WORKSPACE_DIR}/share/cmake/constraints/configurations/${config}/check_${config}.cmake)
			include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/${config}/check_${config}.cmake)	# check the platform and install it if possible
			if(NOT CHECK_${config}_RESULT)
				message("[PID] ERROR : current platform does not satisfy configuration constraint ${config}.")
				set(${RESULT} FALSE PARENT_SCOPE)
			endif()
		else()
			message("[PID] INFO : when checking constraints on current platform, configuration information for ${config} does not exists. You use an unknown constraint. Please remove this constraint or create a new cmake script file called check_${config}.cmake in ${WORKSPACE_DIR}/share/cmake/constraints/configurations/${config} to manage this configuration.")
			set(${RESULT} FALSE PARENT_SCOPE)
		endif()
	endforeach()
	#from here OK all configuration constraints are satisfied
	add_Configuration_To_Platform("${constraints}")
endif()

# whatever the result the constraint is registered
add_Platform_Constraint_Set("${type}" "${arch}" "${os}" "${abi}" "${constraints}")
endfunction(check_Platform_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |build_Package| replace:: ``build_Package``
#  .. _build_Package:
#
#  build_Package
#  -------------
#
#   .. command:: build_Package()
#
#     Finalize configuration of the current package build process. Internal counterpart of build_PID_Package.
#
macro(build_Package)
get_System_Variables(CURRENT_PLATFORM_NAME PACKAGE_SYSTEM_STRING)

### configuring RPATH management in CMake
set(CMAKE_SKIP_BUILD_RPATH FALSE) # don't skip the full RPATH for the build tree
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE) #do not use any link time info when installing
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) # when building, don't use the install RPATH already

if(APPLE)
	set(CMAKE_MACOSX_RPATH TRUE)
	set(CMAKE_INSTALL_RPATH "@loader_path/../lib;@loader_path") #the default install rpath is the library folder of the installed package (internal librari	es managed by default), name is relative to @loader_path to enable easy package relocation
elseif (UNIX)
	set(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib;\$ORIGIN") #the default install rpath is the library folder of the installed package (internal libraries managed by default), name is relative to $ORIGIN to enable easy package relocation
endif()

#################################################################################
############ MANAGING the configuration of package dependencies #################
#################################################################################
# from here only direct dependencies have been satisfied
# 0) if there are packages to install it means that there are some unresolved required dependencies
set(INSTALL_REQUIRED FALSE)
need_Install_External_Packages(INSTALL_REQUIRED)
if(INSTALL_REQUIRED)
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)#when automatic download engaged (default) then automatically install
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : ${PROJECT_NAME} try to resolve required external package dependencies : ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX}}.")
		endif()
		set(INSTALLED_PACKAGES)
		set(NOT_INSTALLED)
		install_Required_External_Packages("${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX}}" INSTALLED_PACKAGES NOT_INSTALLED)
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : ${PROJECT_NAME} has automatically installed the following external packages : ${INSTALLED_PACKAGES}.")
		endif()
		if(NOT_INSTALLED)
			finish_Progress(GLOBAL_PROGRESS_VAR)
			message(FATAL_ERROR "[PID] CRITICAL ERROR when configuring ${PROJECT_NAME}, there are some unresolved required external package dependencies : ${NOT_INSTALLED}.")
			return()
		endif()
		# now need to find each package version and verify compatibility of versions required (this is resolving dependency)
		foreach(a_dep IN LISTS INSTALLED_PACKAGES)
			resolve_External_Package_Dependency(IS_COMPATIBLE ${PROJECT_NAME} ${a_dep} ${CMAKE_BUILD_TYPE})
		  if(NOT IS_COMPATIBLE)#this time there is really nothing to do since package has been reinstalled
				finish_Progress(GLOBAL_PROGRESS_VAR)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent external package ${a_dep} regarding versions constraints. Search ended when trying to satisfy version coming from package ${PROJECT_NAME}. All required versions are : ${${a_dep}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${a_dep}_REQUIRED_VERSION_EXACT}, Last exact version required is ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${a_dep}_VERSION${USE_MODE_SUFFIX}}.")
				return()
			else()
				add_Chosen_Package_Version_In_Current_Process(${a_dep})
			endif()
		endforeach()
	else()
		finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : there are some unresolved required external package dependencies : ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX}}. You may download them \"by hand\" or use the required packages automatic download option to install them automatically.")
		return()
	endif()
endif()

set(INSTALL_REQUIRED FALSE)
need_Install_Packages(INSTALL_REQUIRED)
if(INSTALL_REQUIRED)
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : ${PROJECT_NAME} try to solve required native package dependencies : ${${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX}}")
		endif()
		set(INSTALLED_PACKAGES)
		set(NOT_INSTALLED)
		install_Required_Native_Packages("${${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX}}" INSTALLED_PACKAGES NOT_INSTALLED)
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : ${PROJECT_NAME} has automatically installed the following native packages : ${INSTALLED_PACKAGES}")
		endif()
		if(NOT_INSTALLED)
			finish_Progress(GLOBAL_PROGRESS_VAR)
			message(FATAL_ERROR "[PID] CRITICAL ERROR when building ${PROJECT_NAME}, there are some unresolved required package dependencies : ${NOT_INSTALLED}.")
			return()
		endif()
		# now need to find each package version and verify compatibility of versions required (this is resolving dependency)
		foreach(a_dep IN LISTS INSTALLED_PACKAGES)
			resolve_Package_Dependency(IS_COMPATIBLE ${PROJECT_NAME} ${a_dep} ${CMAKE_BUILD_TYPE})
			if(NOT IS_COMPATIBLE)#this time there is really nothing to do since package has been reinstalled
				finish_Progress(GLOBAL_PROGRESS_VAR)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent package ${a_dep} regarding versions constraints. Search ended when trying to satisfy version coming from package ${PROJECT_NAME}. All required versions are : ${${a_dep}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${a_dep}_REQUIRED_VERSION_EXACT}, Last exact version required is ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${a_dep}_VERSION${USE_MODE_SUFFIX}}.")
				return()
			else()
				add_Chosen_Package_Version_In_Current_Process(${a_dep})
			endif()
		endforeach()
	else()
		finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR  when building ${PROJECT_NAME} : there are some unresolved required package dependencies : ${${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX}}. You may download them \"by hand\" or use the required packages automatic download option to install them automatically.")
		return()
	endif()
endif()

#resolving external dependencies for project external dependencies
if(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
	# 1) resolving dependencies of required external packages versions (different versions can be required at the same time)
	# we get the set of all packages undirectly required
	foreach(dep_pack IN LISTS ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
 		resolve_Package_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE} TRUE)
 	endforeach()
endif()

if(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
	# 1) resolving dependencies of required native packages versions (different versions can be required at the same time)
	# we get the set of all packages undirectly required
	foreach(dep_pack IN LISTS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
 		resolve_Package_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE} TRUE)
 	endforeach()

	#here every package dependency should have been resolved OR ERROR

	# 2) when done resolving runtime dependencies for all used package (direct or undirect)
	foreach(dep_pack IN LISTS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
		resolve_Package_Runtime_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE})
	endforeach()
endif()

#################################################
############ MANAGING the BUILD #################
#################################################

# listing closed source packages, info to be used in targets managements
if(CMAKE_BUILD_TYPE MATCHES Debug)
	list_Closed_Source_Dependency_Packages()
else()
	set(CLOSED_SOURCE_DEPENDENCIES CACHE INTERNAL "")
endif()

# recursive call into subdirectories to build, install, test the package
add_subdirectory(src)
add_subdirectory(apps)

if(BUILD_AND_RUN_TESTS)
 	if(	CMAKE_BUILD_TYPE MATCHES Release
		OR (CMAKE_BUILD_TYPE MATCHES Debug AND BUILD_TESTS_IN_DEBUG))
		enable_testing()
	endif()
endif()
add_subdirectory(share)
add_subdirectory(test)

# specific case : resolve which compile option to use to enable the adequate language standard (CMake version < 3.1 only)
# may be use for other general purpose options in future versions of PID
resolve_Compile_Options_For_Targets(${CMAKE_BUILD_TYPE})

##########################################################
############ MANAGING non source files ###################
##########################################################
generate_Package_Readme_Files() # generating and putting into source directory the readme file used by gitlab + in build tree the api doc welcome page (contain the same information)
generate_Package_License_File() # generating and putting into source directory the file containing license info about the package
generate_Package_Install_Script() # generating and putting into source directory the file and folder containing stand alone install scripts
generate_Find_File() # generating/installing the generic cmake find file for the package
generate_Use_File() #generating the version specific cmake "use" file and the rule to install it
generate_API() #generating the API documentation configuration file and the rule to launch doxygen and install the doc
generate_Info_File() #generating a cmake "info" file containing info about source code of components
generate_Dependencies_File() #generating a cmake "dependencies" file containing information about dependencies
generate_Coverage() #generating a coverage report in debug mode
generate_Static_Checks() #generating a static check report in release mode, if tests are enabled then static check test are automatically generated
create_Documentation_Target() # create target for generating documentation
configure_Package_Pages() # generating the markdown files for the project web pages
generate_Package_CI_Config_File() #generating the CI config file in the project


#installing specific folders of the share sub directory
if(${CMAKE_BUILD_TYPE} MATCHES Release AND EXISTS ${CMAKE_SOURCE_DIR}/share/cmake)
	#installing the share/cmake folder (may contain specific find scripts for external libs used by the package)
	install(DIRECTORY ${CMAKE_SOURCE_DIR}/share/cmake DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/share/resources AND ${CMAKE_BUILD_TYPE} MATCHES Release)
	#installing the share/resource folder (may contain runtime resources for components)
	install(DIRECTORY ${CMAKE_SOURCE_DIR}/share/resources DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})
endif()

#creating specific .rpath folders if build tree
if(NOT EXISTS ${CMAKE_BINARY_DIR}/.rpath)
	file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/.rpath)
endif()
foreach(component IN LISTS ${PROJECT_NAME}_COMPONENTS)
	if(${PROJECT_NAME}_${component}_TYPE STREQUAL "SHARED"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "MODULE"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "APP"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
		will_be_Built(RES ${component})
		if(RES)
			if(EXISTS ${CMAKE_BINARY_DIR}/.rpath/${component}${INSTALL_NAME_SUFFIX})
				file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/.rpath/${component}${INSTALL_NAME_SUFFIX})
			endif()
			file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/.rpath/${component}${INSTALL_NAME_SUFFIX})
		endif()
	endif()
endforeach()

#resolving link time dependencies for executables and modules
foreach(component IN LISTS ${PROJECT_NAME}_COMPONENTS)
	will_be_Built(RES ${component})
	if(RES)
		resolve_Source_Component_Linktime_Dependencies(${component} ${CMAKE_BUILD_TYPE} ${component}_THIRD_PARTY_LINKS)
	endif()
endforeach()

#resolving runtime dependencies for install tree
foreach(component IN LISTS ${PROJECT_NAME}_COMPONENTS)
	will_be_Built(RES ${component})
	if(RES)
		resolve_Source_Component_Runtime_Dependencies(${component} ${CMAKE_BUILD_TYPE} "${${component}_THIRD_PARTY_LINKS}")
	endif()
endforeach()

#resolving runtime dependencies for build tree
foreach(component IN LISTS ${PROJECT_NAME}_COMPONENTS)
	will_be_Built(RES ${component})
	if(RES)
		resolve_Source_Component_Runtime_Dependencies_Build_Tree(${component} ${CMAKE_BUILD_TYPE})
	endif()
endforeach()

#################################################
##### MANAGING the SYSTEM PACKAGING #############
#################################################
# both release and debug packages are built and both must be generated+upoaded / downloaded+installed in the same time
if(GENERATE_INSTALLER)
	include(InstallRequiredSystemLibraries)
	#common infos
	set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
	generate_Contact_String("${${PROJECT_NAME}_MAIN_AUTHOR}" "${${PROJECT_NAME}_CONTACT_MAIL}" RES_CONTACT)
	set(CPACK_PACKAGE_CONTACT "${RES_CONTACT}")
	generate_Formatted_String("${${PROJECT_NAME}_DESCRIPTION}" RES_DESCR)
	set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${RES_DESCR}")
	generate_Formatted_String("${${PROJECT_NAME}_MAIN_INSTITUTION}" RES_INSTIT)
	set(CPACK_PACKAGE_VENDOR "${RES_INSTIT}")
	set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/license.txt)
	set(CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
	set(CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
	set(CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
	set(CPACK_PACKAGE_VERSION "${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}")
	set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}/${${PROJECT_NAME}_VERSION}")
	list(APPEND CPACK_GENERATOR TGZ)

	set(PACKAGE_SOURCE_NAME ${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-${PACKAGE_SYSTEM_STRING}.tar.gz)
	set(PACKAGE_TARGET_NAME ${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-${CURRENT_PLATFORM_NAME}.tar.gz) #we use specific PID platform name instead of CMake default one to avoid troubles (because it is not really discrimant)

	if(PACKAGE_SYSTEM_STRING)
		if(${PROJECT_NAME}_LICENSE)
			package_License_Is_Closed_Source(CLOSED ${PROJECT_NAME} FALSE)
			if(CLOSED)
					#if the license is not open source then we do not generate a package with debug info
					#this requires two step -> first consists in renaming adequately the generated artifcats, second in installing a package with adequate name
					if(CMAKE_BUILD_TYPE MATCHES Release)#release => generate two packages with two different names but with same content
						add_custom_target(	package_install
									COMMAND ${CMAKE_COMMAND} -E rename ${CMAKE_BINARY_DIR}/${PACKAGE_SOURCE_NAME} ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME}
									COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME} ${${PROJECT_NAME}_INSTALL_PATH}/installers/${PACKAGE_TARGET_NAME}
									COMMENT "[PID] installing ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME} in ${${PROJECT_NAME}_INSTALL_PATH}/installers")
					else()#debug => do not install the package
						add_custom_target(	package_install
									COMMAND ${CMAKE_COMMAND} -E echo ""
								COMMENT "[PID] debug package not installed in ${${PROJECT_NAME}_INSTALL_PATH}/installers due to license restriction")
					endif()

			else()#license is open source, do as usual
				add_custom_target(	package_install
							COMMAND ${CMAKE_COMMAND} -E rename ${CMAKE_BINARY_DIR}/${PACKAGE_SOURCE_NAME} ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME}
							COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME} ${${PROJECT_NAME}_INSTALL_PATH}/installers/${PACKAGE_TARGET_NAME}
							COMMENT "[PID] installing ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME} in ${${PROJECT_NAME}_INSTALL_PATH}/installers")
			endif()
		else()#no license (should never happen) => package is supposed to be closed source
			if(CMAKE_BUILD_TYPE MATCHES Release)#release => generate two packages with two different names but with same content
				add_custom_target(	package_install
							COMMAND ${CMAKE_COMMAND} -E rename ${CMAKE_BINARY_DIR}/${PACKAGE_SOURCE_NAME} ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME}
							COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME} ${${PROJECT_NAME}_INSTALL_PATH}/installers/${PACKAGE_TARGET_NAME}
							COMMENT "[PID] installing ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME} in ${${PROJECT_NAME}_INSTALL_PATH}/installers")
			else()#debug => do not install the package
				add_custom_target(	package_install
							COMMAND ${CMAKE_COMMAND} -E echo ""
						COMMENT "[PID] debug package not installed in ${${PROJECT_NAME}_INSTALL_PATH}/installers due to license restriction")
			endif()
		endif()
		include(CPack)
	endif()
endif(GENERATE_INSTALLER)

###############################################################################
######### creating specific targets for easy management of the package ########
###############################################################################

if(${CMAKE_BUILD_TYPE} MATCHES Release)

	#copy the reference file of the package into the "references" folder of the workspace
	add_custom_target(referencing
		COMMAND ${CMAKE_COMMAND}
						-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DREQUIRED_PACKAGE=${PROJECT_NAME}
						-DSOURCE_DIR=${CMAKE_SOURCE_DIR}
						-DBINARY_DIR=${CMAKE_BINARY_DIR}
						-P ${WORKSPACE_DIR}/share/cmake/system/commands/Reference_PID_Package.cmake
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	)

	#licensing all files of the project
	if(	DEFINED ${PROJECT_NAME}_LICENSE
		AND NOT ${${PROJECT_NAME}_LICENSE} STREQUAL "")
		add_custom_target(licensing
			COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
							-DREQUIRED_PACKAGE=${PROJECT_NAME}
							-DSOURCE_DIR=${CMAKE_SOURCE_DIR}
							-DBINARY_DIR=${CMAKE_BINARY_DIR}
							-P ${WORKSPACE_DIR}/share/cmake/system/commands/Licensing_PID_Package_Files.cmake
			VERBATIM
		)
	endif()

	# adding an uninstall command (uninstall the whole installed version currently built)
	add_custom_target(uninstall
		COMMAND ${CMAKE_COMMAND} -E  echo Uninstalling ${PROJECT_NAME} version ${${PROJECT_NAME}_VERSION}
		COMMAND ${CMAKE_COMMAND} -E  remove_directory ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM_NAME}/${PROJECT_NAME}/${${PROJECT_NAME}_VERSION}
		VERBATIM
	)

endif()

add_custom_target(list_dependencies
	COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
					-DPROJECT_NAME=${PROJECT_NAME}
					-DPROJECT_VERSION=${${PROJECT_NAME}_VERSION}
					-DCMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}
					-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
					-DADDITIONNAL_DEBUG_INFO=${ADDITIONNAL_DEBUG_INFO}
					-DFLAT_PRESENTATION=\${flat}
					-DWRITE_TO_FILE=\${write_file}
					-P ${WORKSPACE_DIR}/share/cmake/system/commands/Listing_PID_Package_Dependencies.cmake
)

###############################################################################
######### creating build target for easy sequencing all make commands #########
###############################################################################

if(RUN_TESTS_WITH_PRIVILEGES)
	set(SUDOER_PRIVILEGES sudo)
else()
	set(SUDOER_PRIVILEGES)
endif()

#creating a global build command


package_Has_Nothing_To_Install(NOTHING_INSTALLED)
if(NOTHING_INSTALLED) #if nothing to install, it means that there is nothing to generate... so do nothing
	create_Global_Build_Command("${SUDOER_PRIVILEGES}" FALSE FALSE FALSE FALSE FALSE)
else()
	package_Has_Nothing_To_Build(NOTHING_BUILT)
	if(NOTHING_BUILT)
		set(BUILD_CODE FALSE)
	else()
		set(BUILD_CODE TRUE)
	endif()
	if(CMAKE_BUILD_TYPE MATCHES Release)
		if(BUILD_AND_RUN_TESTS AND PROJECT_RUN_TESTS)
			create_Global_Build_Command("${SUDOER_PRIVILEGES}" TRUE ${BUILD_CODE} "${GENERATE_INSTALLER}" "${BUILD_API_DOC}" "test")
		else()#if tests are not run then remove the test target
			create_Global_Build_Command("${SUDOER_PRIVILEGES}" TRUE ${BUILD_CODE} "${GENERATE_INSTALLER}" "${BUILD_API_DOC}" "")
		endif()
	else()#debug => never build api doc in debug mode
		if(BUILD_AND_RUN_TESTS AND BUILD_TESTS_IN_DEBUG AND PROJECT_RUN_TESTS)  #if tests are not run then remove the coverage or test target
			if(BUILD_COVERAGE_REPORT) #covergae report must be generated with debug symbols activated
				create_Global_Build_Command("${SUDOER_PRIVILEGES}" TRUE ${BUILD_CODE} "${GENERATE_INSTALLER}" FALSE "coverage")
			else() #simple tests
				create_Global_Build_Command("${SUDOER_PRIVILEGES}" TRUE ${BUILD_CODE} "${GENERATE_INSTALLER}" FALSE "test")
			endif()
		else()
			create_Global_Build_Command("${SUDOER_PRIVILEGES}" TRUE ${BUILD_CODE} "${GENERATE_INSTALLER}" FALSE "")
		endif()
	endif()
endif()


#retrieving dependencies on sources packages
if(	BUILD_DEPENDENT_PACKAGES
	AND 	(${CMAKE_BUILD_TYPE} MATCHES Debug
		OR (${CMAKE_BUILD_TYPE} MATCHES Release AND BUILD_RELEASE_ONLY)))
	#only necessary to do dependent build one time, so we do it in debug mode or release if debug not built (i.e. first mode built)
	set(DEPENDENT_SOURCE_PACKAGES)
	list_All_Source_Packages_In_Workspace(RESULT_PACKAGES)
	if(RESULT_PACKAGES)
		foreach(dep_pack IN LISTS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
			list(FIND RESULT_PACKAGES ${dep_pack} id)
			if(NOT id LESS "0")#the package is a dependent source package
				list(APPEND DEPENDENT_SOURCE_PACKAGES ${dep_pack})
			endif()
		endforeach()
	endif()
	if(DEPENDENT_SOURCE_PACKAGES)#there are some dependency managed with source package
		list(LENGTH  DEPENDENT_SOURCE_PACKAGES SIZE)
		if(SIZE EQUAL 1)
			add_custom_target(build-dependencies
				COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
								-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
								-DDEPENDENT_PACKAGES=${DEPENDENT_SOURCE_PACKAGES}
								-DPACKAGE_LAUCHING_BUILD=${PROJECT_NAME}
								-P ${WORKSPACE_DIR}/share/cmake/system/commands/Build_PID_Package_Dependencies.cmake
					COMMENT "[PID] INFO : building dependencies of ${PROJECT_NAME} ..."
					VERBATIM
			)
		else()
			add_custom_target(build-dependencies
				COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
								-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
								-DDEPENDENT_PACKAGES="${DEPENDENT_SOURCE_PACKAGES}"
								-DPACKAGE_LAUCHING_BUILD=${PROJECT_NAME}
								-P ${WORKSPACE_DIR}/share/cmake/system/commands/Build_PID_Package_Dependencies.cmake
					COMMENT "[PID] INFO : building dependencies of ${PROJECT_NAME} ..."
					VERBATIM
			)

		endif()
		add_dependencies(build build-dependencies)# first building dependencies if necessary
	endif()
else()
	set(DEPENDENT_SOURCE_PACKAGES)
endif()

clean_Install_Dir() #cleaning the install directory (include/lib/bin folders) if there are files that are removed (do this only in release mode)

#########################################################################################################################
######### writing the global reference file for the package with all global info contained in the CMakeFile.txt #########
#########################################################################################################################
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	if(${PROJECT_NAME}_ADDRESS)
		generate_Package_Reference_File(${CMAKE_BINARY_DIR}/share/Refer${PROJECT_NAME}.cmake)
	endif()

	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD AND GLOBAL_PROGRESS_VAR)
		some_Packages_Managed_Last_Time(DEPLOYED)
		if(DEPLOYED)
			message("------------------------------------------------------------------")
			message("Packages updated or installed during ${PROJECT_NAME} configuration :")
			print_Managed_Packages()
			message("------------------------------------------------------------------")
		endif()
	endif()
endif()
#print_Component_Variables()

# dealing with plugins at the end of the configuration process
manage_Plugins_In_Package()
reset_Removed_Examples_Build_Option()
finish_Progress(${GLOBAL_PROGRESS_VAR}) #managing the build from a global point of view
endmacro(build_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Library_Component| replace:: ``declare_Library_Component``
#  .. _declare_Library_Component:
#
#  declare_Library_Component
#  -------------------------
#
#   .. command:: declare_Library_Component(c_name dirname type c_standard cxx_standard internal_inc_dirs internal_defs internal_compiler_options exported_defs exported_compiler_options internal_links exported_links runtime_resources)
#
#     Declare a library in the currently defined package.
#
#     :c_name: the name of the library.
#
#     :dirname: the name of the folder that contains includes and/or source code of the library.
#
#     :type: the type of the library (HEADER, STATIC, SHARED or MODULE).
#
#     :c_standard: the C language standard used (may be empty).
#
#     :cxx_standard: the C++ language standard used (98, 11, 14, 17).
#
#     :internal_inc_dirs: additionnal include dirs (internal to package, that contains header files, e.g. like common definition between package components), that don't have to be exported since not in the interface of the library.
#
#     :internal_defs: definitions that affects only the implementation of the library.
#
#     :internal_compiler_options: compiler options used for building the library but not exported to component using the library.
#
#     :exported_defs: definitions that affects the interface (public headers) of the library.
#
#     :exported_compiler_options: compiler options that need to be used whenever a component uses the library.
#
#     :internal_links: only for module or shared libs some internal linker flags used to build the component.
#
#     :exported_links: only for static and shared libs : some linker flags (not a library inclusion, e.g. -l<li> or full path to a lib) that must be used when linking with the component.
#
#     :runtime_resources: list of path to files relative to share/resources folder, supposed to be used at runtime by the library.
#
#     :more_headers: list of path to files or globing expressions relative to src/${dirname} folder, targetting additionnal headers to be part of the interface of the library (used to target files with no extension for instance).
#
#     :more_sources: list of path to files and folders relative to arc folder, containing auxiliary sources to be used for building the library.
#
#     :symlink_folders: list of path to folders where to install symlinks.
#
function(declare_Library_Component c_name dirname type c_standard cxx_standard internal_inc_dirs internal_defs
                                   internal_compiler_options exported_defs exported_compiler_options
																   internal_links exported_links runtime_resources more_headers more_sources
															 		 symlink_folders)
#indicating that the component has been declared and need to be completed
is_Library_Type(RES "${type}")
if(RES)
	set(${PROJECT_NAME}_${c_name}_TYPE ${type} CACHE INTERNAL "")
else()
	finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : you must specify a type (HEADER, STATIC, SHARED or MODULE) for library ${c_name}")
	return()
endif()

# manage options and eventually adjust language standard in use
set(c_standard_used ${c_standard})
set(cxx_standard_used ${cxx_standard})
filter_Compiler_Options(STD_C_OPT STD_CXX_OPT FILTERED_INTERNAL_OPTS "${internal_compiler_options}")
if(STD_C_OPT)
	message("[PID] WARNING:  when declaring library ${c_name},  directly using option -std=c${STD_C_OPT} or -std=gnu${STD_C_OPT} is not recommanded, use the C_STANDARD keywork in component description instead. PID performs corrective action.")
	is_C_Version_Less(IS_LESS "${c_standard_used}" "${STD_C_OPT}")
	if(IS_LESS)
		set(c_standard_used ${STD_C_OPT})
	endif()
endif()
if(STD_CXX_OPT)
	message("[PID] WARNING: when declaring library ${c_name}, directly using option -std=c++${STD_CXX_OPT} or -std=gnu++${STD_CXX_OPT} is not recommanded, use the CXX_STANDARD keywork in component description instead. PID performs corrective action.")
	is_CXX_Version_Less(IS_LESS "${cxx_standard_used}" "${STD_CXX_OPT}")
	if(IS_LESS)
		set(cxx_standard_used ${STD_CXX_OPT})
	endif()
endif()
filter_Compiler_Options(STD_C_OPT STD_CXX_OPT FILTERED_EXPORTED_OPTS "${exported_compiler_options}")
if(STD_C_OPT)
	message("[PID] WARNING:  when declaring library ${c_name},  directly using option -std=c${STD_C_OPT} or -std=gnu${STD_C_OPT} is not recommanded, use the C_STANDARD keywork in component description instead. PID performs corrective action.")
	is_C_Version_Less(IS_LESS "${c_standard_used}" "${STD_C_OPT}")
	if(IS_LESS)
		set(c_standard_used ${STD_C_OPT})
	endif()
endif()
if(STD_CXX_OPT)
	message("[PID] WARNING: when declaring library ${c_name}, directly using option -std=c++${STD_CXX_OPT} or -std=gnu++${STD_CXX_OPT} is not recommanded, use the CXX_STANDARD keywork in component description instead. PID performs corrective action.")
	is_CXX_Version_Less(IS_LESS "${cxx_standard_used}" "${STD_CXX_OPT}")
	if(IS_LESS)
		set(cxx_standard_used ${STD_CXX_OPT})
	endif()
endif()

### managing headers ###
if(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "MODULE") # a module library has no declared interface (only used dynamically)
	if(dirname)# a pure header library may define no folder
		set(${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include/${dirname})
		install(DIRECTORY ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING REGEX "${${PROJECT_NAME}_${c_name}_HEADERS_SELECTION_PATTERN}")
		#a library defines a folder containing one or more headers and/or subdirectories
		get_All_Headers_Relative(${PROJECT_NAME}_${c_name}_ALL_HEADERS_RELATIVE ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR} "${${PROJECT_NAME}_${c_name}_HEADERS_ADDITIONAL_FILTERS}")
		get_All_Headers_Absolute(${PROJECT_NAME}_${c_name}_ALL_HEADERS ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR} "${more_headers}")
	endif()
	set(${PROJECT_NAME}_${c_name}_HEADER_DIR_NAME ${dirname} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_HEADERS_ADDITIONAL_FILTERS ${more_headers} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_HEADERS ${${PROJECT_NAME}_${c_name}_ALL_HEADERS_RELATIVE} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_HEADERS_SELECTION_PATTERN "^$")
	foreach(header IN LISTS ${PROJECT_NAME}_${c_name}_HEADERS)
		set(${PROJECT_NAME}_${c_name}_HEADERS_SELECTION_PATTERN  "^.*${header}$|${${PROJECT_NAME}_${c_name}_HEADERS_SELECTION_PATTERN}")
	endforeach()
endif()

### managing sources and defining targets ###
if(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "HEADER")# a header library has no source code (generates no binary)
	#collect sources for the library
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/${dirname})

	## 1) collect info about the sources for registration purpose
	#register the source dir
	if(${CMAKE_BUILD_TYPE} MATCHES Release)
		set(${PROJECT_NAME}_${c_name}_SOURCE_DIR ${dirname} CACHE INTERNAL "")
		get_All_Sources_Relative(${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR})
		set(${PROJECT_NAME}_${c_name}_SOURCE_CODE ${${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE} CACHE INTERNAL "")
		if(more_sources)
			get_All_Sources_Relative_From(SOURCES PATH_TO_MONITOR ${CMAKE_SOURCE_DIR}/src "${more_sources}")
			set(${PROJECT_NAME}_${c_name}_AUX_SOURCE_CODE ${SOURCES} CACHE INTERNAL "")
			set(${PROJECT_NAME}_${c_name}_AUX_MONITORED_PATH ${PATH_TO_MONITOR} CACHE INTERNAL "")
		endif()
	endif()
	## 2) collect sources for build process
	set(use_includes ${internal_inc_dirs})

	get_All_Sources_Absolute(${PROJECT_NAME}_${c_name}_ALL_SOURCES ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR})
	if(more_sources)
		get_All_Sources_Absolute_From(SOURCES INCLUDES ${CMAKE_SOURCE_DIR}/src "${more_sources}")
		list(APPEND ${PROJECT_NAME}_${c_name}_ALL_SOURCES ${SOURCES})
		if(INCLUDES)
			list(APPEND use_includes ${INCLUDES})
		endif()
	endif()
	list(APPEND ${PROJECT_NAME}_${c_name}_ALL_SOURCES ${${PROJECT_NAME}_${c_name}_ALL_HEADERS})

	#defining shared and/or static targets for the library and
	#adding the targets to the list of installed components when make install is called
	if(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "STATIC") #a static library has no internal links (never trully linked)
		create_Static_Lib_Target(${c_name} "${c_standard_used}" "${cxx_standard_used}" "${${PROJECT_NAME}_${c_name}_ALL_SOURCES}" "${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}"  "${use_includes}" "${exported_defs}" "${internal_defs}" "${FILTERED_EXPORTED_OPTS}" "${FILTERED_INTERNAL_OPTS}" "${exported_links}")
		register_Component_Binary(${c_name})
	elseif(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "SHARED")
		create_Shared_Lib_Target(${c_name} "${c_standard_used}" "${cxx_standard_used}" "${${PROJECT_NAME}_${c_name}_ALL_SOURCES}" "${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}" "${use_includes}" "${exported_defs}" "${internal_defs}" "${FILTERED_EXPORTED_OPTS}" "${FILTERED_INTERNAL_OPTS}" "${exported_links}" "${internal_links}")
		install(DIRECTORY DESTINATION ${${PROJECT_NAME}_INSTALL_RPATH_DIR}/${c_name}${INSTALL_NAME_SUFFIX})#create the folder that will contain symbolic links (e.g. to shared libraries) used by the component (will allow full relocation of components runtime dependencies at install time)
		register_Component_Binary(${c_name})
	elseif(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "MODULE") #a static library has no exported links (no interface)
		contains_Python_Code(HAS_WRAPPER ${CMAKE_CURRENT_SOURCE_DIR}/${dirname})
		if(HAS_WRAPPER)
			if(NOT CURRENT_PYTHON)#we cannot build the module because there is no python module
				return()
			endif()
			#adding adequate path to pyhton librairies
			list(APPEND INCLUDE_DIRS_WITH_PYTHON ${use_includes} ${CURRENT_PYTHON_INCLUDE_DIRS})
			list(APPEND LIBRARIES_WITH_PYTHON ${internal_links} ${CURRENT_PYTHON_LIBRARIES})
			create_Module_Lib_Target(${c_name} "${c_standard_used}" "${cxx_standard_used}" "${${PROJECT_NAME}_${c_name}_ALL_SOURCES}" "${INCLUDE_DIRS_WITH_PYTHON}" "${internal_defs}" "${FILTERED_INTERNAL_OPTS}" "${LIBRARIES_WITH_PYTHON}")
		else()
			create_Module_Lib_Target(${c_name} "${c_standard_used}" "${cxx_standard_used}" "${${PROJECT_NAME}_${c_name}_ALL_SOURCES}" "${use_includes}" "${internal_defs}" "${FILTERED_INTERNAL_OPTS}" "${internal_links}")
		endif()
		install(DIRECTORY DESTINATION ${${PROJECT_NAME}_INSTALL_RPATH_DIR}/${c_name}${INSTALL_NAME_SUFFIX})#create the folder that will contain symbolic links (e.g. to shared libraries) used by the component (will allow full relocation of components runtime dependencies at install time)
		register_Component_Binary(${c_name})#need to register before calling manage python
		if(HAS_WRAPPER)
			manage_Python_Scripts(${c_name} ${dirname})#specific case to manage, python scripts must be installed in a share/script subfolder
			set(${PROJECT_NAME}_${c_name}_HAS_PYTHON_WRAPPER TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_${c_name}_HAS_PYTHON_WRAPPER FALSE CACHE INTERNAL "")
		endif()
	endif()
	if(symlink_folders)
		foreach(symlink IN LISTS symlink_folders)
			install_Additional_Binary_Symlink(${c_name} ${symlink})
		endforeach()
	endif()
else()#simply creating a "fake" target for header only library
	create_Header_Lib_Target(${c_name} "${c_standard_used}" "${cxx_standard_used}" "${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}" "${exported_defs}" "${FILTERED_EXPORTED_OPTS}" "${exported_links}")
endif()

# registering exported flags for all kinds of libs
init_Component_Cached_Variables_For_Export(${c_name} "${c_standard_used}" "${cxx_standard_used}" "${exported_defs}" "${FILTERED_EXPORTED_OPTS}" "${exported_links}" "${runtime_resources}")

#updating global variables of the CMake process
append_Unique_In_Cache(${PROJECT_NAME}_COMPONENTS ${c_name})
append_Unique_In_Cache(${PROJECT_NAME}_COMPONENTS_LIBS ${c_name})
# global variable to know that the component has been declared (must be reinitialized at each run of cmake)
mark_As_Declared(${c_name})
endfunction(declare_Library_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Application_Component| replace:: ``declare_Application_Component``
#  .. _declare_Application_Component:
#
#  declare_Application_Component
#  -----------------------------
#
#   .. command:: declare_Application_Component(c_name dirname type c_standard cxx_standard internal_inc_dirs internal_defs internal_compiler_options internal_link_flags runtime_resources)
#
#     Declare an  application (executable) in the currently defined package.
#
#     :c_name: the name of the application.
#
#     :dirname: the name of the folder that contains source code of the application.
#
#     :type: the type of the applciation (APPLICATION, EXAMPLE, TEST).
#
#     :c_standard: the C language standard used (may be empty).
#
#     :cxx_standard: the C++ language standard used (98, 11, 14, 17).
#
#     :internal_inc_dirs: additionnal include dirs (internal to package, that contains header files, e.g. like common definition between package components).
#
#     :internal_defs: preprocessor definitions used for building the application.
#
#     :internal_compiler_options: compiler options used for building the application.
#
#     :internal_link_flags: internal linker flags used to build the application.
#
#     :runtime_resources: list of path to files relative to share/resources folder, supposed to be used at runtime by the application.
#
#     :more_sources: list of path to files and folders relative to app folder, containing auxiliary sources to be used for building the application.
#
#     :symlink_folders: list of path to folders where to install symlinks.
#
function(declare_Application_Component c_name dirname type c_standard cxx_standard internal_inc_dirs internal_defs
internal_compiler_options internal_link_flags runtime_resources more_sources symlinks)

is_Application_Type(RES "${type}")#double check, for internal use only (purpose: simplify PID code debugging)
if(RES)
	set(${PROJECT_NAME}_${c_name}_TYPE ${type} CACHE INTERNAL "")
else() #a simple application by default
	finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : you have to set a type name (TEST, APP, EXAMPLE) for the application component ${c_name}")
	return()
endif()

# manage options and eventually adjust language standard in use
set(c_standard_used ${c_standard})
set(cxx_standard_used ${cxx_standard})
filter_Compiler_Options(STD_C_OPT STD_CXX_OPT FILTERED_INTERNAL_OPTS "${internal_compiler_options}")
if(STD_C_OPT)
	message("[PID] WARNING:  when declaring library ${c_name},  directly using option -std=c${STD_C_OPT} or -std=gnu${STD_C_OPT} is not recommanded, use the C_STANDARD keywork in component description instead. PID performs corrective action.")
	is_C_Version_Less(IS_LESS ${c_standard_used} ${STD_C_OPT})
	if(IS_LESS)
		set(c_standard_used ${STD_C_OPT})
	endif()
endif()
if(STD_CXX_OPT)
	message("[PID] WARNING: when declaring library ${c_name}, directly using option -std=c++${STD_CXX_OPT} or -std=gnu++${STD_CXX_OPT} is not recommanded, use the CXX_STANDARD keywork in component description instead. PID performs corrective action.")
	is_CXX_Version_Less(IS_LESS ${cxx_standard_used} ${STD_CXX_OPT})
	if(IS_LESS)
		set(cxx_standard_used ${STD_CXX_OPT})
	endif()
endif()

#managing sources for the application
if(	${PROJECT_NAME}_${c_name}_TYPE STREQUAL "APP"
	OR ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "EXAMPLE")
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/apps/${dirname} CACHE INTERNAL "")
elseif(	${PROJECT_NAME}_${c_name}_TYPE STREQUAL "TEST")
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/test/${dirname} CACHE INTERNAL "")
endif()

# specifically managing examples
if(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "EXAMPLE")
	build_Option_For_Example(${c_name})
	add_Example_To_Doc(${c_name}) #examples are added to the doc to be referenced
	if(NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${c_name}) #examples are not built so no need to continue
		mark_As_Declared(${c_name})
		return()
	endif()
elseif(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "TEST")
	if(NOT BUILD_AND_RUN_TESTS) #tests are not built so no need to continue
		mark_As_Declared(${c_name})
		return()
	endif()
endif()
will_be_Installed(COMP_WILL_BE_INSTALLED ${c_name})

set(use_includes ${internal_inc_dirs})
get_All_Sources_Absolute(${PROJECT_NAME}_${c_name}_ALL_SOURCES ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR})
if(more_sources)
	get_All_Sources_Absolute_From(SOURCES INCLUDES ${CMAKE_SOURCE_DIR}/apps "${more_sources}")
	list(APPEND ${PROJECT_NAME}_${c_name}_ALL_SOURCES ${SOURCES})
	if(INCLUDES)
		list(APPEND use_includes ${INCLUDES})
	endif()
endif()
#defining the target to build the application

if(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "TEST")# NB : tests do not need to be relocatable since they are purely local
	create_Executable_Target(${c_name} "${c_standard_used}" "${cxx_standard_used}" "${${PROJECT_NAME}_${c_name}_ALL_SOURCES}" "${use_includes}" "${internal_defs}" "${FILTERED_EXPORTED_OPTS}" "${internal_link_flags}")

	install(DIRECTORY DESTINATION ${${PROJECT_NAME}_INSTALL_RPATH_DIR}/${c_name}${INSTALL_NAME_SUFFIX})#create the folder that will contain symbolic links (e.g. to shared libraries) used by the component (will allow full relocation of components runtime dependencies at install time)
	if(symlinks AND ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "APP")
		foreach(symlink IN LISTS symlinks)
			install_Additional_Binary_Symlink(${c_name} ${symlink})
		endforeach()
	endif()
else()
	create_TestUnit_Target(${c_name} "${c_standard_used}" "${cxx_standard_used}" "${${PROJECT_NAME}_${c_name}_ALL_SOURCES}" "${use_includes}" "${internal_defs}" "${FILTERED_EXPORTED_OPTS}" "${internal_link_flags}")
endif()
register_Component_Binary(${c_name})# resgistering name of the executable

#registering source code for the component
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	get_All_Sources_Relative(${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR})
	set(${PROJECT_NAME}_${c_name}_SOURCE_CODE ${${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_SOURCE_DIR ${dirname} CACHE INTERNAL "")
	if(more_sources)
		get_All_Sources_Relative_From(SOURCES PATH_TO_MONITOR ${CMAKE_SOURCE_DIR}/apps "${more_sources}")
		set(${PROJECT_NAME}_${c_name}_AUX_SOURCE_CODE ${SOURCES} CACHE INTERNAL "")
		set(${PROJECT_NAME}_${c_name}_AUX_MONITORED_PATH ${PATH_TO_MONITOR} CACHE INTERNAL "")
	endif()
endif()

# registering exported flags for all kinds of apps => empty variables (except runtime resources since applications export no flags)
init_Component_Cached_Variables_For_Export(${c_name} "${c_standard_used}" "${cxx_standard_used}" "" "" "" "${runtime_resources}")

#updating global variables of the CMake process
append_Unique_In_Cache(${PROJECT_NAME}_COMPONENTS ${c_name})
append_Unique_In_Cache(${PROJECT_NAME}_COMPONENTS_APPS ${c_name})
# global variable to know that the component has been declared  (must be reinitialized at each run of cmake)
mark_As_Declared(${c_name})
endfunction(declare_Application_Component)


function(declare_Python_Component	c_name dirname)
set(${PROJECT_NAME}_${c_name}_TYPE "PYTHON" CACHE INTERNAL "")
#registering source code for the component
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/share/script/${dirname} CACHE INTERNAL "")
	get_All_Sources_Relative(${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR})
	set(${PROJECT_NAME}_${c_name}_SOURCE_CODE ${${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_SOURCE_DIR ${dirname} CACHE INTERNAL "")
	if(more_sources)
		get_All_Sources_Relative_From(SOURCES PATH_TO_MONITOR ${CMAKE_SOURCE_DIR}/share/script "${more_sources}")
		set(${PROJECT_NAME}_${c_name}_AUX_SOURCE_CODE ${SOURCES} CACHE INTERNAL "")
		set(${PROJECT_NAME}_${c_name}_AUX_MONITORED_PATH ${PATH_TO_MONITOR} CACHE INTERNAL "")
	endif()
endif()
manage_Python_Scripts(${c_name} ${dirname})
#updating global variables of the CMake process
append_Unique_In_Cache(${PROJECT_NAME}_COMPONENTS ${c_name})
append_Unique_In_Cache(${PROJECT_NAME}_COMPONENTS_SCRIPTS ${c_name})
# global variable to know that the component has been declared  (must be reinitialized at each run of cmake)
mark_As_Declared(${c_name})
endfunction(declare_Python_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Package_Dependency| replace:: ``declare_Package_Dependency``
#  .. _declare_Package_Dependency:
#
#  declare_Package_Dependency
#  --------------------------
#
#   .. command:: declare_Package_Dependency(dep_package optional list_of_versions exact_versions list_of_components)
#
#     Specify a dependency between the currently defined package and another native package.
#
#     :dep_package: the package that is the dependency.
#
#     :optional: if TRUE the dependency is optional.
#
#     :list_of_versions: the list of possible incompatible versions for the dependency.
#
#     :exact_versions: the list of exact version among possible ones.
#
#     :list_of_components: the list of required components that must belong to dependency.
#
function(declare_Package_Dependency dep_package optional list_of_versions exact_versions list_of_components)
# ${PROJECT_NAME}_DEPENDENCIES				# packages required by current package
# ${PROJECT_NAME}__DEPENDENCY_${dep_package}_VERSION		# version constraint for package ${dep_package}   required by ${PROJECT_NAME}
# ${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION_EXACT	# TRUE if exact version is required
# ${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS	# list of composants of ${dep_package} used by current package
	set(unused FALSE)
	# 0) check if a version of this dependency is required by another package
	get_Chosen_Version_In_Current_Process(REQUIRED_VERSION IS_EXACT ${dep_package})

	# 1) the package may be required at that time
	# defining if there is either a specific version to use or not
	if(NOT list_of_versions)
		if(optional)
			set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "Select if ${dep_package} is to be used by typing ANY or not using NONE.")
			if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "NONE")#create the dependency except otherwise specified
				if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "ANY")#manage change of dependency in user description
					set(${dep_package}_ALTERNATIVE_VERSION_USED ANY CACHE STRING "Select if ${dep_package} is to be used by typing ANY or not using NONE." FORCE)
				endif()
			else()
				set(unused TRUE)
			endif()
		else()
			set(${dep_package}_ALTERNATIVE_VERSION_USED ANY CACHE INTERNAL "" FORCE)
		endif()#else no message since nohting to say to the user
		if(NOT unused)
			if(REQUIRED_VERSION) #the package is already used as a dependency in the current build process so we need to reuse the version already specified or use a compatible one instead
				add_Package_Dependency_To_Cache(${dep_package} ${REQUIRED_VERSION} ${IS_EXACT} "${list_of_components}") #set the dependency
			else()#no version required
				add_Package_Dependency_To_Cache(${dep_package} "" FALSE "${list_of_components}")
			endif()
		endif()
	else()#there are version specified
		fill_String_From_List("${list_of_versions}" available_versions) #get available version as a string (used to print them)
		#check if required version (if any) is compatible with current target version
		list(LENGTH list_of_versions SIZE)
		list(GET list_of_versions 0 default_version) #by defaut this is the first element in the list that is taken
		if(REQUIRED_VERSION) #the package is already used as a dependency in the current build process so we need to reuse the version already specified or use a compatible one instead
			#finding the best compatible version, if any
			find_Best_Compatible_Version(version FALSE ${dep_package} ${REQUIRED_VERSION} "${IS_EXACT}" "${list_of_versions}" "${exact_versions}")
		else()
			set(version ${default_version})
		endif()

		##### create the cache variables for user at first time #####
		set(message_for_variable "Select which version of dependency ${dep_package} is to be used among versions : ${available_versions}.")
		if(optional) #message for the optional dependency includes the possiiblity to input NONE
			set(message_for_variable "${message_for_variable} Or use NONE to avoid using this dependency.")
		endif()
		if(version) #the package may be already used as a dependency in the current build process so we need to reuse the version already specified or use a compatible one instead
			if(SIZE EQUAL 1)
				set(${dep_package}_ALTERNATIVE_VERSION_USED ${version} CACHE INTERNAL "" FORCE)#do not show the variable to the user
			else()
				set(${dep_package}_ALTERNATIVE_VERSION_USED ${version} CACHE STRING "${message_for_variable}")
			endif()
		else()#no version, only possible if in a dependent build process
			if(optional)
				# since dependency is optional, we simply just do not use it to avoid unresolvable configuration
				set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "${message_for_variable}.")#initial value set to unused
			else() #version of a required dependency
				#no version compatible => use default version as base value (will generate an error just after BUT will be usable if the user then run a non depednent build of dep_package later)
				set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE STRING "${message_for_variable}")
			endif()
		endif()

		##### set the cache variables adequately depending on the build context (dependent build or classical build) #####
		if(REQUIRED_VERSION AND NOT version)#the build context is a dependent build and no compatible version has been found
			if(optional)#hopefully the depndency is optional so we can deactivate it
				set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "Select which version of dependency ${dep_package} is to be used among versions : ${available_versions}. Or use NONE set to avoid using this dependency." FORCE)
				message("[PID] WARNING : dependency ${dep_package} for package ${PROJECT_NAME} is optional and has been automatically deactivated as its version (${version}) is not compatible with version ${REQUIRED_VERSION} previously required by other packages.")
			else()#this is to ensure that on a dependent build an adequate version has been chosen from the list of possible versions
				finish_Progress(GLOBAL_PROGRESS_VAR)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : In ${PROJECT_NAME} dependency ${dep_package} is used in another package with version ${REQUIRED_VERSION}, but this version is not usable in this project that depends on versions : ${available_versions}.")
				return()
			endif()
		endif()

		##### check if the variable value is not faulty #####
		if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED)#check if there is a value set by user
			if(optional)#hopefully the dependency is optional so we can force its deactivation
				set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "${message_for_variable}" FORCE)
			else()
				finish_Progress(GLOBAL_PROGRESS_VAR)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : In ${PROJECT_NAME} no version version is defined for dependency ${dep_package}.")
				return()
			endif()
		else()#a version constraint was specified
			if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "NONE" OR NOT optional)#it is not a deactivated optional dependency
				if(${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "ANY")#special case where any version was previously specified (due to a change in specification of the dependency)
					if(NOT version)
						set(version ${default_version})
					endif()
					set(${dep_package}_ALTERNATIVE_VERSION_USED ${version} CACHE STRING "${message_for_variable}" FORCE)
				else()#otherwise there is a version constraint specified
					if(REQUIRED_VERSION)#we are currently in the context of a dependent build
						#need to force the usage of the chosen alternative
						set(${dep_package}_ALTERNATIVE_VERSION_USED ${version} CACHE STRING "${message_for_variable}" FORCE)
					else()#classic build: other compatible versions may be used with dependent builds so simply do not check that
						list(FIND list_of_versions ${${dep_package}_ALTERNATIVE_VERSION_USED} INDEX)
						if(INDEX EQUAL -1 )#no possible version found
							finish_Progress(GLOBAL_PROGRESS_VAR)
							message(FATAL_ERROR "[PID] CRITICAL ERROR : In ${PROJECT_NAME} a bad version (${${dep_package}_ALTERNATIVE_VERSION_USED}) was used for dependency ${dep_package}.")
							return()
						endif()
					endif()
				endif()
			endif()
		endif()

		##### determine whether the dependency is used and memorize its version #####
		if(${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "NONE")
			set(unused TRUE)
		else()#if a version is used, configure it
			if(exact_versions)
				list(FIND exact_versions ${${dep_package}_ALTERNATIVE_VERSION_USED} INDEX)
				if(INDEX EQUAL -1)#selected version not found in the list of exact versions
					add_Package_Dependency_To_Cache(${dep_package} "${${dep_package}_ALTERNATIVE_VERSION_USED}" FALSE "${list_of_components}") #set the dependency
				else()#if the target version belong to the list of exact version then ... it is exact ^^
					add_Package_Dependency_To_Cache(${dep_package} "${${dep_package}_ALTERNATIVE_VERSION_USED}" TRUE "${list_of_components}") #set the dependency
				endif()
			else()#by definition this is not an exact version selected
				add_Package_Dependency_To_Cache(${dep_package} "${${dep_package}_ALTERNATIVE_VERSION_USED}" FALSE "${list_of_components}") #set the dependency
			endif()
		endif()
	endif()#version specified


	if(NOT unused) #if the dependency is really used (guard the case when it were optional and unselected by user)
		# 3) try to find the adequate package version => it is necessarily required
		if(NOT ${dep_package}_FOUND)#testing if the package has been previously found or not
			resolve_Package_Dependency(IS_COMPATIBLE ${PROJECT_NAME} ${dep_package} ${CMAKE_BUILD_TYPE})
			if(NOT IS_COMPATIBLE)
				finish_Progress(GLOBAL_PROGRESS_VAR)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent package ${dep_package} regarding versions constraints. Search ended when trying to satisfy version coming from package ${PROJECT_NAME}. All required versions are : ${${dep_package}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${dep_package}_REQUIRED_VERSION_EXACT}, Last exact version required is ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}}. Try to put this dependency as first dependency in your CMakeLists.txt in order to force its version constraint before any other.")
				return()
			else()
				add_Chosen_Package_Version_In_Current_Process(${dep_package})
			endif()
		endif()#otherwise nothing more to do
	endif()
endfunction(declare_Package_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_External_Package_Dependency| replace:: ``declare_External_Package_Dependency``
#  .. _declare_External_Package_Dependency:
#
#  declare_External_Package_Dependency
#  -----------------------------------
#
#   .. command:: declare_External_Package_Dependency(dep_package optional list_of_versions exact_versions list_of_components)
#
#     Specify a dependency between the currently defined native package and an external package.
#
#     :dep_package: the external package that is the dependency.
#
#     :optional: if TRUE the dependency is optional.
#
#     :list_of_versions: the list of possible incompatible versions for the dependency.
#
#     :exact_versions: the list of exact version among possible ones.
#
#     :list_of_components: the list of required components that must belong to dependency.
#
function(declare_External_Package_Dependency dep_package optional list_of_versions exact_versions components_list)
set(unused FALSE)
# 0) check if a version of this dependency is required by another package used in the current build process and memorize this version
get_Chosen_Version_In_Current_Process(REQUIRED_VERSION IS_EXACT ${dep_package})

# defining if there is either a specific version to use or not
if(NOT list_of_versions) # no version constraint specified
	if(optional)
		#set the cache option, NONE by default
		set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "Select if ${dep_package} is to be used by typing ANY or not using NONE.")
		if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "NONE")#create the dependency except otherwise specified
			if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "ANY")#manage change of dependency in user description
				set(${dep_package}_ALTERNATIVE_VERSION_USED ANY CACHE STRING "Select if ${dep_package} is to be used by typing ANY or not using NONE." FORCE)
			endif()
		else()#dependency is not used so no need to bother if already required in current process
			set(unused TRUE)
		endif()
	else()#dependency is not optional so any version can be used
		set(${dep_package}_ALTERNATIVE_VERSION_USED ANY CACHE INTERNAL "" FORCE)#no message since nothing to say to the user
	endif()
	if(NOT unused)#if dependency is used (i.e. not optional or optional and set to ANY)
		# now checking if a version is already required by current build process
		if(REQUIRED_VERSION) #the package is already used as a dependency in the current build process so we need to reuse the version already specified or use a compatible one instead
			add_External_Package_Dependency_To_Cache(${dep_package} ${REQUIRED_VERSION} ${IS_EXACT} "${list_of_components}") #set the dependency
		else()#no version required
			add_External_Package_Dependency_To_Cache(${dep_package} "" FALSE "${list_of_components}") #set the dependency
		endif()
	endif()
else()#there are version(s) specified
	fill_String_From_List("${list_of_versions}" available_versions) #get available version as a string (used to print them)
	#check if required version (if any) is compatible with current target version
	list(LENGTH list_of_versions SIZE)
	list(GET list_of_versions 0 default_version) #by defaut this is the first element in the list that is taken
	if(REQUIRED_VERSION) #the package is already used as a dependency in the current build process so we need to reuse the version already specified or use a compatible one instead
		#finding the best compatible version, if any
		find_Best_Compatible_Version(version TRUE ${dep_package} ${REQUIRED_VERSION} "${IS_EXACT}" "${list_of_versions}" "${exact_versions}")
	else()
		set(version ${default_version})
	endif()

	##### create the cache variables for user at first time #####
	set(message_for_variable "Select the version of dependency ${dep_package} : ${available_versions}.")
	if(optional) #message for the optional dependency includes the possiiblity to input NONE
		set(message_for_variable "${message_for_variable} Or use NONE to avoid using this dependency.")
	endif()
	if(version) #the package may be already used as a dependency in the current build process so we need to reuse the version already specified or use a compatible one instead
		if(SIZE EQUAL 1)
			set(${dep_package}_ALTERNATIVE_VERSION_USED ${version} CACHE INTERNAL "" FORCE)#do not show the variable to the user
		else()
			set(${dep_package}_ALTERNATIVE_VERSION_USED ${version} CACHE STRING "${message_for_variable}")
		endif()
	else()#no version variable defined, only possible if in a dependent build process
		if(optional)
			# since dependency is optional, we simply just do not use it to avoid unresolvable configuration
			set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "${message_for_variable}.")#initial value set to unused
		else() #version of a required dependency
			#no version compatible => use default version as base value (will generate an error just after BUT will be usable if the user then run a non depednent build of dep_package later)
			set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE STRING "${message_for_variable}")
		endif()
	endif()

	##### set the cache variables adequately depending on the build context (dependent build or classical build) #####
	if(REQUIRED_VERSION AND NOT version)#the build context is a dependent build and no compatible version has been found
		if(optional)#hopefully the depndency is optional so we can deactivate it
			set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "Select which version of dependency ${dep_package} is to be used among versions : ${available_versions}. Or use NONE set to avoid using this dependency." FORCE)
			message("[PID] WARNING : dependency ${dep_package} for package ${PROJECT_NAME} is optional and has been automatically deactivated as its version (${version}) is not compatible with version ${REQUIRED_VERSION} previously required by other packages.")
		else()#this is to ensure that on a dependent build an adequate version has been chosen from the list of possible versions
			finish_Progress(GLOBAL_PROGRESS_VAR)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : In ${PROJECT_NAME} dependency ${dep_package} is used in another package with version ${REQUIRED_VERSION}, but this version is not usable in this project that depends on versions : ${available_versions}.")
			return()
		endif()
	endif()

	##### check if the variable value is not faulty #####
	if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED)#check if there is a value set by user
		if(optional)#hopefully the dependency is optional so we can force its deactivation
			set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "${message_for_variable}" FORCE)
		else()
			finish_Progress(GLOBAL_PROGRESS_VAR)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : In ${PROJECT_NAME} no version version is defined for dependency ${dep_package}.")
			return()
		endif()
	else()#a version constraint was specified
		if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "NONE" OR NOT optional)#it is not a deactivated optional dependency
			if(${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "ANY")#special case where any version was previously specified (due to a change in specification of the dependency)
				if(NOT version)
					set(version ${default_version})
				endif()
				set(${dep_package}_ALTERNATIVE_VERSION_USED ${version} CACHE STRING "${message_for_variable}" FORCE)
			else()#otherwise there is a version constraint specified
				if(REQUIRED_VERSION)#we are currently in the context of a dependent build
					#need to force the usage of the chosen alternative
					set(${dep_package}_ALTERNATIVE_VERSION_USED ${version} CACHE STRING "${message_for_variable}" FORCE)
				else()#classic build: other compatible versions may be used with dependent builds so simply do not check that
					list(FIND list_of_versions ${${dep_package}_ALTERNATIVE_VERSION_USED} INDEX)
					if(INDEX EQUAL -1 )#no possible version found
						finish_Progress(GLOBAL_PROGRESS_VAR)
						message(FATAL_ERROR "[PID] CRITICAL ERROR : In ${PROJECT_NAME} a bad version (${${dep_package}_ALTERNATIVE_VERSION_USED}) was used for dependency ${dep_package}.")
						return()
					endif()
				endif()
			endif()
		endif()
	endif()

	##### determine whether the dependency is used and memorize its version #####
	if(${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "NONE")
		set(unused TRUE)
	else()#if a version is used, configure it
		if(exact_versions)
			list(FIND exact_versions ${${dep_package}_ALTERNATIVE_VERSION_USED} INDEX)
			if(INDEX EQUAL -1)#selected version not found in the list of exact versions
				add_External_Package_Dependency_To_Cache(${dep_package} "${${dep_package}_ALTERNATIVE_VERSION_USED}" FALSE "${list_of_components}") #set the dependency
			else()#if the target version belong to the list of exact version then ... it is exact ^^
				add_External_Package_Dependency_To_Cache(${dep_package} "${${dep_package}_ALTERNATIVE_VERSION_USED}" TRUE "${list_of_components}") #set the dependency
			endif()
		else()#by definition this is not an exact version selected
			add_External_Package_Dependency_To_Cache(${dep_package} "${${dep_package}_ALTERNATIVE_VERSION_USED}" FALSE "${list_of_components}") #set the dependency
		endif()
	endif()
endif()#version specified

if(NOT unused) #if the dependency is really used (in case it were optional and unselected by user)
	# 3) try to find the adequate package version => it is necessarily required
	if(NOT ${dep_package}_FOUND)#testing if the package has been previously found or not
		resolve_External_Package_Dependency(IS_COMPATIBLE ${PROJECT_NAME} ${dep_package} ${CMAKE_BUILD_TYPE})
		if(NOT IS_COMPATIBLE)
			finish_Progress(GLOBAL_PROGRESS_VAR)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent package ${dep_package} regarding versions constraints. Search ended when trying to satisfy version coming from package ${PROJECT_NAME}. All required versions are : ${${dep_package}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${dep_package}_REQUIRED_VERSION_EXACT}, Last exact version required is ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}}. Try to put this dependency as first dependency in your CMakeLists.txt in order to force its version constraint before any other.")
			return()
		else()
			add_Chosen_Package_Version_In_Current_Process(${dep_package})
		endif()
  endif()

endif()
endfunction(declare_External_Package_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Internal_Component_Dependency| replace:: ``declare_Internal_Component_Dependency``
#  .. _declare_Internal_Component_Dependency:
#
#  declare_Internal_Component_Dependency
#  -------------------------------------
#
#   .. command:: declare_Internal_Component_Dependency(component dep_component export comp_defs comp_exp_defs dep_defs)
#
#     Specify a dependency between two components of the currently defined native package.
#
#     :component: the name of the component that have a dependency.
#
#     :dep_component: the name of the component that IS the dependency.
#
#     :export: if TRUE component exports dep_component (i.e. public headers of component include public headers of dep_component)
#
#     :comp_defs: preprocessor definitions in the implementation of component that conditionnate the use of dep_component (may be an empty string). These definitions are not exported by component.
#
#     :comp_exp_defs: preprocessor definitions in the interface (public headers) of component that conditionnate the use of dep_component (may be an empty string). These definitions are exported by component.
#
#     :dep_defs: preprocessor definitions used in the interface of dep_component, that are set when component uses dep_component (may be an empty string). These definitions are exported if dep_component is exported by component.
#
function(declare_Internal_Component_Dependency component dep_component export comp_defs comp_exp_defs dep_defs)
#message("declare_Internal_Component_Dependency : component = ${component}, dep_component=${dep_component}, export=${export}, comp_defs=${comp_defs} comp_exp_defs=${comp_exp_defs} dep_defs=${dep_defs}")
set(COMP_WILL_BE_BUILT FALSE)
will_be_Built(COMP_WILL_BE_BUILT ${component})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()
set(DECLARED FALSE)
is_Declared(${dep_component} DECLARED)
if(NOT DECLARED)
	finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR when building ${component} in ${PROJECT_NAME} : component ${dep_component} is not defined in current package ${PROJECT_NAME}.")
endif()
#guarding depending type of involved components
is_HeaderFree_Component(IS_HF_COMP ${PROJECT_NAME} ${component})
is_HeaderFree_Component(IS_HF_DEP ${PROJECT_NAME} ${dep_component})
is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})
set(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${dep_component}${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
if (IS_HF_COMP)
		if(IS_HF_DEP)
			# setting compile definitions for configuring the target
			fill_Component_Target_With_Dependency(${component} ${PROJECT_NAME} ${dep_component} ${CMAKE_BUILD_TYPE} FALSE "${comp_defs}" "" "")
		else()
			# setting compile definitions for configuring the target
			fill_Component_Target_With_Dependency(${component} ${PROJECT_NAME} ${dep_component} ${CMAKE_BUILD_TYPE} FALSE "${comp_defs}" "" "${dep_defs}")
		endif()
elseif(IS_BUILT_COMP)
	if(IS_HF_DEP)
		configure_Install_Variables(${component} FALSE "" "" "${comp_exp_defs}" "" "" "" "" "" "")
		# setting compile definitions for configuring the target
		fill_Component_Target_With_Dependency(${component} ${PROJECT_NAME} ${dep_component} ${CMAKE_BUILD_TYPE} FALSE "${comp_defs}" "${comp_exp_defs}" "")

	else()
		#prepare the dependancy export
		if(export)
			set(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${dep_component}${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		endif()
		configure_Install_Variables(${component} ${export} "" "${dep_defs}" "${comp_exp_defs}" "" "" "" "" "" "")

		# setting compile definitions for configuring the target
		fill_Component_Target_With_Dependency(${component} ${PROJECT_NAME} ${dep_component} ${CMAKE_BUILD_TYPE} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
	endif()
elseif(	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
	if(IS_HF_DEP)
		configure_Install_Variables(${component} FALSE "" "" "${comp_exp_defs}" "" "" "" "" "" "")
		fill_Component_Target_With_Dependency(${component} ${PROJECT_NAME} ${dep_component} ${CMAKE_BUILD_TYPE} FALSE "" "${comp_exp_defs}" "")

	else()
		#prepare the dependancy export
		set(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${dep_component}${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "") #export is necessarily true for a pure header library
		configure_Install_Variables(${component} TRUE "" "${dep_defs}" "${comp_exp_defs}" "" "" "" "" "" "")
		# setting compile definitions for configuring the "fake" target
		fill_Component_Target_With_Dependency(${component} ${PROJECT_NAME} ${dep_component} ${CMAKE_BUILD_TYPE} TRUE "" "${comp_exp_defs}" "${dep_defs}")

	endif()
else()
	message (FATAL_ERROR "[PID] CRITICAL ERROR when building ${component} in ${PROJECT_NAME} : unknown type (${${PROJECT_NAME}_${component}_TYPE}) for component ${component} of package ${PROJECT_NAME}.")
	return()
endif()
# include directories and links do not require to be added
# declare the internal dependency
set(	${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}
	${${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}} ${dep_component}
	CACHE INTERNAL "")
endfunction(declare_Internal_Component_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Package_Component_Dependency| replace:: ``declare_Package_Component_Dependency``
#  .. _declare_Package_Component_Dependency:
#
#  declare_Package_Component_Dependency
#  ------------------------------------
#
#   .. command:: declare_Package_Component_Dependency(component dep_package dep_component export comp_defs comp_exp_defs dep_defs)
#
#     Specify a dependency between a component of the currently defined native package and a component belonging to another native package.
#
#     :component: the name of the component that have a dependency.
#
#     :dep_package: the name of the package that contains the dependency.
#
#     :dep_component: the name of the component that IS the dependency,which belongs to dep_package.
#
#     :export: if TRUE component exports dep_component (i.e. public headers of component include public headers of dep_component)
#
#     :comp_defs: preprocessor definitions in the implementation of component that conditionnate the use of dep_component (may be an empty string). These definitions are not exported by component.
#
#     :comp_exp_defs: preprocessor definitions in the interface (public headers) of component that conditionnate the use of dep_component (may be an empty string). These definitions are exported by component.
#
#     :dep_defs: preprocessor definitions used in the interface of dep_component, that are set when component uses dep_component (may be an empty string). These definitions are exported if dep_component is exported by component.
#
function(declare_Package_Component_Dependency component dep_package dep_component export comp_defs comp_exp_defs dep_defs)
	# ${PROJECT_NAME}_${component}_DEPENDENCIES			# packages used by the component ${component} of the current package
	# ${PROJECT_NAME}_${component}_DEPENDENCY_${dep_package}_COMPONENTS	# components of package ${dep_package} used by component ${component} of current package
#message("declare_Package_Component_Dependency : component = ${component}, dep_package = ${dep_package}, dep_component=${dep_component}, export=${export}, comp_defs=${comp_defs} comp_exp_defs=${comp_exp_defs} dep_defs=${dep_defs}")
will_be_Built(COMP_WILL_BE_BUILT ${component})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()

set(${PROJECT_NAME}_${c_name}_EXPORT_${dep_package}_${dep_component} FALSE CACHE INTERNAL "")
#guarding depending type of involved components
is_HeaderFree_Component(IS_HF_COMP ${PROJECT_NAME} ${component})
is_HeaderFree_Component(IS_HF_DEP ${dep_package} ${dep_component})
is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})
if (IS_HF_COMP)
	# setting compile definitions for configuring the target
	if(IS_HF_DEP)#the dependency has no build interface(header free) => it is a runtime dependency
		fill_Component_Target_With_Dependency(${component} ${dep_package} ${dep_component} ${CMAKE_BUILD_TYPE} FALSE "${comp_defs}" "" "")
	else()	#the dependency has a build interface
		fill_Component_Target_With_Dependency(${component} ${dep_package} ${dep_component} ${CMAKE_BUILD_TYPE} FALSE "${comp_defs}" "" "${dep_defs}")
	#do not export anything
	endif()
elseif(IS_BUILT_COMP)
	if(IS_HF_DEP)#the dependency has no build interface(header free) => it is a runtime dependency
		# setting compile definitions for configuring the target
		fill_Component_Target_With_Dependency(${component} ${dep_package} ${dep_component} ${CMAKE_BUILD_TYPE} FALSE "${comp_defs}" "${comp_exp_defs}" "")
		configure_Install_Variables(${component} FALSE "" "" "${comp_exp_defs}" "" "" "" "" "" "")
	else()	#the dependency has a build interface
		if(export)#prepare the dependancy export
			set(${PROJECT_NAME}_${component}_EXPORT_${dep_package}_${dep_component} TRUE CACHE INTERNAL "")
		endif()
		configure_Install_Variables(${component} ${export} "" "${dep_defs}" "${comp_exp_defs}" "" "" "" "" "" "")

		# setting compile definitions for configuring the target
		fill_Component_Target_With_Dependency(${component} ${dep_package} ${dep_component} ${CMAKE_BUILD_TYPE} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
	endif()

elseif(	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
		# setting compile definitions for configuring the target
	if(IS_HF_DEP)#the dependency has no build interface(header free) => it is a runtime dependency
		fill_Component_Target_With_Dependency(${component} ${dep_package} ${dep_component} ${CMAKE_BUILD_TYPE} FALSE "" "${comp_exp_defs}" "")

		configure_Install_Variables(${component} FALSE "" "" "${comp_exp_defs}" "" "" "" "" "" "")
	else()	#the dependency has a build interface

		#prepare the dependancy export
		set(${PROJECT_NAME}_${component}_EXPORT_${dep_package}_${dep_component} TRUE CACHE INTERNAL "") #export is necessarily true for a pure header library
		configure_Install_Variables(${component} TRUE "" "${dep_defs}" "${comp_exp_defs}" "" "" "" "" "" "")
		fill_Component_Target_With_Dependency(${component} ${dep_package} ${dep_component} ${CMAKE_BUILD_TYPE} TRUE "" "${comp_exp_defs}" "${dep_defs}")

		#fill_Component_Target_With_Package_Dependency(${component} ${dep_package} ${dep_component} TRUE "" "${comp_exp_defs}" "${dep_defs}")
	endif()
else()
	message (FATAL_ERROR "[PID] CRITICAL ERROR when building ${component} in ${PROJECT_NAME} : unknown type (${${PROJECT_NAME}_${component}_TYPE}) for component ${component} in package ${PROJECT_NAME}.")
	return()
endif()

#links and include directories do not require to be added (will be found automatically)
set(	${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}
	${${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}}
	${dep_package}
	CACHE INTERNAL "")
set(	${PROJECT_NAME}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}
	${${PROJECT_NAME}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}}
	${dep_component}
	CACHE INTERNAL "")
endfunction(declare_Package_Component_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_System_Component_Dependency| replace:: ``declare_System_Component_Dependency``
#  .. _declare_System_Component_Dependency:
#
#  declare_System_Component_Dependency
#  -----------------------------------
#
#   .. command:: declare_System_Component_Dependency(component export inc_dirs comp_defs comp_exp_defs dep_defs compiler_options static_links shared_links c_standard cxx_standard runtime_resources)
#
#     Specify a dependency between a component of the currently defined native package and system components.
#     details: declare a dependancy that does not create new targets, but directly configures the component with adequate flags coming from system dependencies.
#     Should be avoided anytime possible, but useful to configure a component with flags and options coming from a platform configuration.
#
#     :component: the name of the component that have a dependency.
#
#     :export: if TRUE component exports the content of the dependency.
#
#     :inc_dirs: path to include directories required by the component in order to build.
#
#     :comp_defs: preprocessor definitions in the implementation of component that conditionnate the use of system dependencies (may be an empty string). These definitions are not exported by component.
#
#     :comp_exp_defs: preprocessor definitions in the interface (public headers) of component that conditionnate the use of system dependencies (may be an empty string). These definitions are exported by component.
#
#     :dep_defs: preprocessor definitions used in the headers system dependencies, that are defined by component (may be an empty string). These definitions are exported if dep_component is exported by component.
#
#     :compiler_options: compiler options to use for this dependency (may be let empty).
#
#     :static_links: list of path to static libraries (may be let empty).
#
#     :shared_links: list of path to shared libraries or linker options (may be let empty).
#
#     :c_standard: the C language standard to use because of the dependency (may be let empty).
#
#     :cxx_standard: the C++ language standard to use because of the dependency (may be let empty).
#
#     :runtime_resources: set of path to files or folder used at runtime (may be let empty).
#
function(declare_System_Component_Dependency component export inc_dirs comp_defs comp_exp_defs dep_defs compiler_options static_links shared_links c_standard cxx_standard runtime_resources)
will_be_Built(COMP_WILL_BE_BUILT ${component})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()
will_be_Installed(COMP_WILL_BE_INSTALLED ${component})

#guarding depending type of involved components
is_HeaderFree_Component(IS_HF_COMP ${PROJECT_NAME} ${component})
is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})
set(TARGET_LINKS ${static_links} ${shared_links})

if (IS_HF_COMP) #no header to the component
	if(${PROJECT_NAME}_${component}_TYPE STREQUAL "PYTHON")#specific case of python components
		list(APPEND ALL_WRAPPED_FILES ${shared_links} ${runtime_resources})
		create_Python_Wrapper_To_Files(${component} "${ALL_WRAPPED_FILES}")
	else()
		if(COMP_WILL_BE_INSTALLED)
			configure_Install_Variables(${component} FALSE "" "" "" "" "" "" "" "" "${runtime_resources}")
		endif()
		# setting compile definitions for the target
		fill_Component_Target_With_External_Dependency(${component} FALSE "${comp_defs}" "" "${dep_defs}" "${inc_dirs}" "${TARGET_LINKS}" "${c_standard}" "${cxx_standard}")
	endif()
elseif(IS_BUILT_COMP)
	#prepare the dependancy export
	configure_Install_Variables(${component} ${export} "${inc_dirs}" "${dep_defs}" "${comp_exp_defs}" "${compiler_options}" "${static_links}" "${shared_links}" "${c_standard}" "${cxx_standard}" "${runtime_resources}")
	# setting compile definitions for the target
	fill_Component_Target_With_External_Dependency(${component} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}" "${inc_dirs}" "${TARGET_LINKS}" "${c_standard}" "${cxx_standard}")

elseif(	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
	#prepare the dependancy export
	configure_Install_Variables(${component} TRUE "${inc_dirs}" "${dep_defs}" "${comp_exp_defs}" "${compiler_options}" "${static_links}" "${shared_links}" "${c_standard}" "${cxx_standard}" "${runtime_resources}") #export is necessarily true for a pure header library
	# setting compile definitions for the target
	fill_Component_Target_With_External_Dependency(${component} TRUE "" "${comp_exp_defs}" "${dep_defs}" "${inc_dirs}" "${TARGET_LINKS}" "${c_standard}" "${cxx_standard}")
else()
	message (FATAL_ERROR "[PID] CRITICAL ERROR when building ${component} in ${PROJECT_NAME} : unknown type (${${PROJECT_NAME}_${component}_TYPE}) for component ${component} in package ${PROJECT_NAME}.")
endif()
endfunction(declare_System_Component_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_External_Package_Component_Dependency| replace:: ``declare_External_Package_Component_Dependency``
#  .. _declare_External_Package_Component_Dependency:
#
#  declare_External_Package_Component_Dependency
#  ---------------------------------------------
#
#   .. command:: declare_External_Package_Component_Dependency(component dep_package export inc_dirs comp_defs comp_exp_defs dep_defs compiler_options static_links shared_links c_standard cxx_standard runtime_resources)
#
#     Specify a dependency between a component of the currently defined native package and the content of an external package.
#     details: declare an external dependancy that does not create new targets, but directly configures the component with adequate flags coming from dep_package.
#     Should be used prior to system dependencies for all dependencies that are not true system dependencies but should be avoided everytime the external package provide a content description (use file).
#
#     :component: the name of the component that have a dependency.
#
#     :dep_package: the name of the external package that contains the dependency.
#
#     :export: if TRUE component exports the content of dep_package.
#
#     :inc_dirs: include directories to add to component in order to build it. These include dirs are expressed relatively to dep_package root dir using "<dep_package>" expression (e.g. <boost>).
#
#     :comp_defs: preprocessor definitions in the implementation of component that conditionnate the use of dep_package (may be an empty string). These definitions are not exported by component.
#
#     :comp_exp_defs: preprocessor definitions in the interface (public headers) of component that conditionnate the use of dep_package (may be an empty string). These definitions are exported by component.
#
#     :dep_defs: preprocessor definitions used in the headers of dep_package, that are set by component(may be an empty string). These definitions are exported if dep_component is exported by component.
#
#     :compiler_options: compiler options to use for this dependency (may be let empty).
#
#     :static_links: list of path to static libraries relative to dep_package root dir (may be let empty).
#
#     :shared_links: list of path to shared libraries relative to dep_package root dir or linker options (may be let empty).
#
#     :c_standard: the C language standard to use because of the dependency (may be let empty).
#
#     :cxx_standard: the C++ language standard to use because of the dependency (may be let empty).
#
#     :runtime_resources: st of path to files or folder used at runtime relative to dep_package root dir (may be let empty).
#
function(declare_External_Package_Component_Dependency component dep_package export inc_dirs comp_defs comp_exp_defs dep_defs compiler_options static_links shared_links c_standard cxx_standard runtime_resources)
will_be_Built(COMP_WILL_BE_BUILT ${component})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()
will_be_Installed(COMP_WILL_BE_INSTALLED ${component})

if(NOT ${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX})
	message (FATAL_ERROR "[PID] CRITICAL ERROR when building ${component} in ${PROJECT_NAME} : the external package ${dep_package} is not defined !")
else()

	#guarding depending type of involved components
	is_HeaderFree_Component(IS_HF_COMP ${PROJECT_NAME} ${component})
	is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})
	set(TARGET_LINKS ${static_links} ${shared_links})

	if (IS_HF_COMP)
		if(${PROJECT_NAME}_${component}_TYPE STREQUAL "PYTHON")#specific case of python components
			list(APPEND ALL_WRAPPED_FILES ${shared_links} ${runtime_resources})
			create_Python_Wrapper_To_Files(${component} "${ALL_WRAPPED_FILES}")
		else()
			if(COMP_WILL_BE_INSTALLED)
				configure_Install_Variables(${component} FALSE "" "" "" "" "" "${shared_links}" "" "" "${runtime_resources}")
			endif()
			# setting compile definitions for the target
			fill_Component_Target_With_External_Dependency(${component} FALSE "${comp_defs}" "" "${dep_defs}" "${inc_dirs}" "${TARGET_LINKS}" "${c_standard}" "${cxx_standard}")
		endif()
	elseif(IS_BUILT_COMP)
		#prepare the dependancy export
		configure_Install_Variables(${component} ${export} "${inc_dirs}" "${dep_defs}" "${comp_exp_defs}" "${compiler_options}" "${static_links}" "${shared_links}" "${c_standard}" "${cxx_standard}" "${runtime_resources}")
		# setting compile definitions for the target
		fill_Component_Target_With_External_Dependency(${component} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}" "${inc_dirs}" "${TARGET_LINKS}" "${c_standard}" "${cxx_standard}")
	elseif(	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
		#prepare the dependancy export
		configure_Install_Variables(${component} TRUE "${inc_dirs}" "${dep_defs}" "${comp_exp_defs}" "${compiler_options}" "${static_links}" "${shared_links}" "${c_standard}" "${cxx_standard}" "${runtime_resources}") #export is necessarily true for a pure header library

		# setting compile definitions for the "fake" target
		fill_Component_Target_With_External_Dependency(${component} TRUE "" "${comp_exp_defs}" "${dep_defs}" "${inc_dirs}" "${TARGET_LINKS}" "${c_standard}" "${cxx_standard}")
	else()
		message (FATAL_ERROR "[PID] CRITICAL ERROR when building ${component} in ${PROJECT_NAME} : unknown type (${${PROJECT_NAME}_${component}_TYPE}) for component ${component} in package ${PROJECT_NAME}.")
	endif()
endif()
endfunction(declare_External_Package_Component_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |collect_Links_And_Flags_For_External_Component| replace:: ``collect_Links_And_Flags_For_External_Component``
#  .. _collect_Links_And_Flags_For_External_Component:
#
#  collect_Links_And_Flags_For_External_Component
#  ----------------------------------------------
#
#   .. command:: collect_Links_And_Flags_For_External_Component(dep_package dep_component RES_INCS RES_DEFS RES_OPTS RES_LINKS_STATIC RES_LINKS_SHARED RES_C_STANDARD RES_CXX_STANDARD RES_RUNTIME)
#
#     Get all required options needed to use an external component.
#
#     :dep_package: the name of the external package that contains the external component.
#
#     :dep_component: the name of the target external component.
#
#     :RES_INCS: output variable containing include path to use when using dep_component.
#
#     :RES_DEFS: output variable containing preprocessor definitions to use when using dep_component.
#
#     :RES_OPTS: output variable containing compiler options to use when using dep_component.
#
#     :RES_LINKS_STATIC: output variable containing the list of path to static libraries to use when using dep_component.
#
#     :RES_LINKS_SHARED: output variable containing the list of path to shared libraries and linker options to use when using dep_component.
#
#     :RES_C_STANDARD: output variable containing the C language standard to use when using dep_component.
#
#     :RES_CXX_STANDARD: output variable containing the C++ language standard to use when using dep_component.
#
#     :RES_RUNTIME: output variable containing the list of path to files or folder used at runtime by dep_component.
#
function(collect_Links_And_Flags_For_External_Component dep_package dep_component
RES_INCS RES_DEFS RES_OPTS RES_LINKS_STATIC RES_LINKS_SHARED RES_C_STANDARD RES_CXX_STANDARD RES_RUNTIME)
set(INCS_RESULT)
set(DEFS_RESULT)
set(OPTS_RESULT)
set(STATIC_LINKS_RESULT)
set(SHARED_LINKS_RESULT)
set(RUNTIME_RESULT)

if(${dep_package}_${dep_component}_C_STANDARD${USE_MODE_SUFFIX})#initialize with current value
	set(C_STD_RESULT ${${dep_package}_${dep_component}_C_STANDARD${USE_MODE_SUFFIX}})
else()
	set(C_STD_RESULT 90)#take lowest value
endif()
if(${dep_package}_${dep_component}_CXX_STANDARD${USE_MODE_SUFFIX})#initialize with current value
	set(CXX_STD_RESULT ${${dep_package}_${dep_component}_CXX_STANDARD${USE_MODE_SUFFIX}})
else()
	set(CXX_STD_RESULT 98)#take lowest value
endif()


## collecting internal dependencies (recursive call on internal dependencies first)
if(${dep_package}_${dep_component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
	foreach(comp IN LISTS ${dep_package}_${dep_component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
		collect_Links_And_Flags_For_External_Component(${dep_package} ${comp} INCS DEFS OPTS LINKS_ST LINKS_SH C_STD CXX_STD RUNTIME_RES)
		if(${dep_package}_${dep_component}_INTERNAL_EXPORT_${comp}${USE_MODE_SUFFIX})
			if(INCS)
				list (APPEND INCS_RESULT ${INCS})
			endif()
			if(DEFS)
				list (APPEND DEFS_RESULT ${DEFS})
			endif()
		endif()

		if(OPTS)
			list (APPEND OPTS_RESULT ${OPTS})
		endif()
		if(LINKS_ST)
			list (APPEND STATIC_LINKS_RESULT ${LINKS_ST})
		endif()
		if(LINKS_SH)
			list (APPEND SHARED_LINKS_RESULT ${LINKS_SH})
		endif()
		if(C_STD)#always take the greater standard number
			is_C_Version_Less(IS_LESS ${C_STD_RESULT} "${${dep_package}_${comp}_C_STANDARD${VAR_SUFFIX}}")
			if(IS_LESS)
				set(C_STD_RESULT ${${dep_package}_${comp}_C_STANDARD${VAR_SUFFIX}})
			endif()
		endif()
		if(CXX_STD)#always take the greater standard number
			is_CXX_Version_Less(IS_LESS ${CXX_STD_RESULT} "${${dep_package}_${comp}_CXX_STANDARD${VAR_SUFFIX}}")
			if(IS_LESS)
				set(CXX_STD_RESULT ${${dep_package}_${comp}_CXX_STANDARD${VAR_SUFFIX}})
			endif()
		endif()
		if(RUNTIME_RES)
			list (APPEND RUNTIME_RESULT ${RUNTIME_RES})
		endif()
	endforeach()
endif()

#1. Manage dependencies of the component
if(${dep_package}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}) #if the external package has dependencies we have to resolve those needed by the component
	#some checks to verify the validity of the declaration
	if(NOT ${dep_package}_COMPONENTS${USE_MODE_SUFFIX})
		message (FATAL_ERROR "[PID] CRITICAL ERROR declaring dependency to ${dep_component} in package ${dep_package} : component ${dep_component} is unknown in ${dep_package}.")
		return()
	endif()
	list(FIND ${dep_package}_COMPONENTS${USE_MODE_SUFFIX} ${dep_component} INDEX)
	if(INDEX EQUAL -1)
		message (FATAL_ERROR "[PID] CRITICAL ERROR declaring dependency to ${dep_component} in package ${dep_package} : component ${dep_component} is unknown in ${dep_package}.")
		return()
	endif()

	## collecting external dependencies (recursive call on external dependencies - the corresponding external package must exist)
	foreach(dep IN LISTS ${dep_package}_${dep_component}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
		foreach(comp IN LISTS ${dep_package}_${dep_component}_EXTERNAL_DEPENDENCY_${dep}_COMPONENTS${USE_MODE_SUFFIX})#if no component defined this is not an errror !
			collect_Links_And_Flags_For_External_Component(${dep} ${comp} INCS DEFS OPTS LINKS_ST LINKS_SH C_STD CXX_STD RUNTIME_RES)
			if(${dep_package}_${dep_component}_EXTERNAL_EXPORT_${dep}_${comp}${USE_MODE_SUFFIX})
				if(INCS)
					list (APPEND INCS_RESULT ${INCS})
				endif()
				if(DEFS)
					list (APPEND DEFS_RESULT ${DEFS})
				endif()
			endif()

			if(OPTS)
				list (APPEND OPTS_RESULT ${OPTS})
			endif()

			if(LINKS_ST)
				list (APPEND STATIC_LINKS_RESULT ${LINKS_ST})
			endif()

			if(LINKS_SH)
				list (APPEND SHARED_LINKS_RESULT ${LINKS_SH})
			endif()

			is_C_Version_Less(IS_LESS ${C_STD_RESULT} "${C_STD}")#always take the greater standard number
			if(IS_LESS)
				set(C_STD_RESULT ${C_STD})
			endif()
			is_CXX_Version_Less(IS_LESS ${CXX_STD_RESULT} "${CXX_STD}")
			if(IS_LESS)
				set(CXX_STD_RESULT ${CXX_STD})
			endif()

			if(RUNTIME_RES)
				list (APPEND RUNTIME_RESULT ${RUNTIME_RES})
			endif()
		endforeach()
	endforeach()
endif()

#2. Manage the component properties and return the result
if(${dep_package}_${dep_component}_INC_DIRS${USE_MODE_SUFFIX})
	list(APPEND INCS_RESULT ${${dep_package}_${dep_component}_INC_DIRS${USE_MODE_SUFFIX}})
endif()
if(${dep_package}_${dep_component}_DEFS${USE_MODE_SUFFIX})
	list(APPEND DEFS_RESULT ${${dep_package}_${dep_component}_DEFS${USE_MODE_SUFFIX}})
endif()
if(${dep_package}_${dep_component}_OPTS${USE_MODE_SUFFIX})
	list(APPEND OPTS_RESULT ${${dep_package}_${dep_component}_OPTS${USE_MODE_SUFFIX}})
endif()
if(${dep_package}_${dep_component}_STATIC_LINKS${USE_MODE_SUFFIX})
	list(APPEND STATIC_LINKS_RESULT ${${dep_package}_${dep_component}_STATIC_LINKS${USE_MODE_SUFFIX}})
endif()
if(${dep_package}_${dep_component}_SHARED_LINKS${USE_MODE_SUFFIX})
	list(APPEND SHARED_LINKS_RESULT ${${dep_package}_${dep_component}_SHARED_LINKS${USE_MODE_SUFFIX}})
endif()
if(${dep_package}_${dep_component}_RUNTIME_RESOURCES${USE_MODE_SUFFIX})
	list(APPEND RUNTIME_RESULT ${${dep_package}_${dep_component}_RUNTIME_RESOURCES${USE_MODE_SUFFIX}})
endif()

#3. clearing the lists
if(INCS_RESULT)
	list(REMOVE_DUPLICATES INCS_RESULT)
endif()
if(DEFS_RESULT)
	list(REMOVE_DUPLICATES DEFS_RESULT)
endif()
if(OPTS_RESULT)
	list(REMOVE_DUPLICATES OPTS_RESULT)
endif()
if(STATIC_LINKS_RESULT)
	list(REMOVE_DUPLICATES STATIC_LINKS_RESULT)
endif()
if(SHARED_LINKS_RESULT)
	list(REMOVE_DUPLICATES SHARED_LINKS_RESULT)
endif()
if(RUNTIME_RESULT)
	list(REMOVE_DUPLICATES RUNTIME_RESULT)
endif()

#4. return the values
set(${RES_INCS} ${INCS_RESULT} PARENT_SCOPE)
set(${RES_DEFS} ${DEFS_RESULT} PARENT_SCOPE)
set(${RES_OPTS} ${OPTS_RESULT} PARENT_SCOPE)
set(${RES_LINKS_STATIC} ${STATIC_LINKS_RESULT} PARENT_SCOPE)
set(${RES_LINKS_SHARED} ${SHARED_LINKS_RESULT} PARENT_SCOPE)
set(${RES_RUNTIME} ${RUNTIME_RESULT} PARENT_SCOPE)
set(${RES_C_STANDARD} ${C_STD_RESULT} PARENT_SCOPE)
set(${RES_CXX_STANDARD} ${CXX_STD_RESULT} PARENT_SCOPE)
endfunction(collect_Links_And_Flags_For_External_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_External_Component_Dependency| replace:: ``declare_External_Component_Dependency``
#  .. _declare_External_Component_Dependency:
#
#  declare_External_Component_Dependency
#  -------------------------------------
#
#   .. command:: declare_External_Component_Dependency(component dep_package dep_component export comp_defs comp_exp_defs dep_defs)
#
#     Specify a dependency between a component of the currently defined native package and a component belonging to an external package.
#
#     :component: the name of the component that have a dependency.
#
#     :dep_package: the name of the external package that contains the dependency.
#
#     :dep_component: the name of the external component that IS the dependency, which belongs to dep_package.
#
#     :export: if TRUE component exports dep_component (i.e. public headers of component include public headers of dep_component)
#
#     :comp_defs: preprocessor definitions in the implementation of component that conditionnate the use of dep_component (may be an empty string). These definitions are not exported by component.
#
#     :comp_exp_defs: preprocessor definitions in the interface (public headers) of component that conditionnate the use of dep_component (may be an empty string). These definitions are exported by component.
#
#     :dep_defs: preprocessor definitions used in the interface of dep_component, that are set when component uses dep_component (may be an empty string). These definitions are exported if dep_component is exported by component.
#
function(declare_External_Component_Dependency component dep_package dep_component export comp_defs comp_exp_defs dep_defs)

will_be_Built(COMP_WILL_BE_BUILT ${component})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()

if(NOT ${dep_package}_HAS_DESCRIPTION)# no external package description provided (maybe due to the fact that an old version of the external package is installed)
	message ("[PID] WARNING when building ${component} in ${PROJECT_NAME} : the external package ${dep_package} provides no description. Attempting to reinstall it to get it !")
	install_External_Package(INSTALL_OK ${dep_package} TRUE FALSE)#force the reinstall of binary
	if(NOT INSTALL_OK)
		message (FATAL_ERROR "[PID] CRITICAL ERROR when reinstalling package ${dep_package} in ${PROJECT_NAME}, cannot redeploy package binary archive !")
		return()
	endif()

	find_package(#configure again the package
		${dep_package}
		${${dep_package}_VERSION_STRING} #use the version already in use
		EXACT
		MODULE
		REQUIRED
	)
	if(NOT ${dep_package}_HAS_DESCRIPTION)
		#description still unavailable => fatal error
		message (FATAL_ERROR "[PID] CRITICAL ERROR after reinstalling package ${dep_package} in ${PROJECT_NAME} : the project has no description of its content !")
		return()
	endif()
	message ("[PID] INFO when building ${component} in ${PROJECT_NAME} : the external package ${dep_package} now provides content description.")
endif()

will_be_Installed(COMP_WILL_BE_INSTALLED ${component})
#guarding depending on type of involved components
is_HeaderFree_Component(IS_HF_COMP ${PROJECT_NAME} ${component})
is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})

#I need first to collect (recursively) all links and flags using the adequate variables (same as for native or close).
collect_Links_And_Flags_For_External_Component(${dep_package} ${dep_component}
RES_INCS RES_DEFS RES_OPTS RES_LINKS_ST RES_LINKS_SH RES_STD_C RES_STD_CXX RES_RUNTIME)
set(EXTERNAL_DEFS ${dep_defs} ${RES_DEFS})
set(ALL_LINKS ${RES_LINKS_ST} ${RES_LINKS_SH})
if (IS_HF_COMP) #a component withour headers
	if(${PROJECT_NAME}_${component}_TYPE STREQUAL "PYTHON")#specific case of python components
		list(APPEND ALL_WRAPPED_FILES ${RES_LINKS_SH} ${RES_RUNTIME})
		create_Python_Wrapper_To_Files(${component} "${ALL_WRAPPED_FILES}")
	else()
		if(COMP_WILL_BE_INSTALLED)
			configure_Install_Variables(${component} FALSE "" "" "" "" "" "${RES_LINKS_SH}" "" "" "${RES_RUNTIME}")
		endif()
		# setting compile definitions for the target
		fill_Component_Target_With_External_Dependency(${component} FALSE "${comp_defs}" "" "${EXTERNAL_DEFS}" "${RES_INCS}" "${ALL_LINKS}" "${RES_STD_C}" "${RES_STD_CXX}")
	endif()
elseif(IS_BUILT_COMP) #a component that is built by the build procedure
	#configure_Install_Variables component export include_dirs dep_defs exported_defs exported_options static_links shared_links runtime_resources)
	#prepare the dependancy export
	set(EXTERNAL_DEFS ${dep_defs} ${RES_DEFS})
	configure_Install_Variables(${component} ${export} "${RES_INCS}" "${EXTERNAL_DEFS}" "${comp_exp_defs}" "${RES_OPTS}" "${RES_LINKS_ST}" "${RES_LINKS_SH}" "${RES_STD_C}" "${RES_STD_CXX}" "${runtime_resources}")

	# setting compile definitions for the target
	fill_Component_Target_With_External_Dependency(${component} ${export} "${comp_defs}" "${comp_exp_defs}" "${EXTERNAL_DEFS}" "${RES_INCS}" "${ALL_LINKS}" "${RES_STD_C}" "${RES_STD_CXX}")
elseif(	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER") #a pure header component
	#prepare the dependancy export
	configure_Install_Variables(${component} TRUE "${RES_INCS}" "${EXTERNAL_DEFS}" "${comp_exp_defs}" "${RES_OPTS}" "${RES_LINKS_ST}" "${RES_LINKS_SH}" "${RES_STD_C}" "${RES_STD_CXX}" "${runtime_resources}") #export is necessarily true for a pure header library

	# setting compile definitions for the "fake" target
	fill_Component_Target_With_External_Dependency(${component} TRUE "" "${comp_exp_defs}" "${EXTERNAL_DEFS}" "${RES_INCS}" "${ALL_LINKS}" "${RES_STD_C}" "${RES_STD_CXX}")
else()
	message (FATAL_ERROR "[PID] CRITICAL ERROR when building ${component} in ${PROJECT_NAME} : unknown type (${${PROJECT_NAME}_${component}_TYPE}) for component ${component} in package ${PROJECT_NAME}.")
endif()
endfunction(declare_External_Component_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Install_Script| replace:: ``generate_Package_Install_Script``
#  .. _generate_Package_Install_Script:
#
#  generate_Package_Install_Script
#  -------------------------------
#
#   .. command:: generate_Package_Install_Script()
#
#     (Re)Generate the stand alone install script into share folder of current package project.
#
function(generate_Package_Install_Script)
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/share/install)
	file(COPY ${WORKSPACE_DIR}/share/patterns/packages/package/share/install DESTINATION ${CMAKE_SOURCE_DIR}/share)
	return()
endif()
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/share/install/standlone_install.sh)
	file(COPY ${WORKSPACE_DIR}/share/patterns/packages/package/share/install/standalone_install.sh DESTINATION ${CMAKE_SOURCE_DIR}/share/install)
endif()
#TODO copy .bat file also when written
endfunction(generate_Package_Install_Script)
