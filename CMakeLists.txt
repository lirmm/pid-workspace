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

CMAKE_MINIMUM_REQUIRED(VERSION 3.0.2)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/system/commands)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/licenses)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/find)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/constraints/conditions)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)

PROJECT(pid-workspace)

manage_Platforms(${CMAKE_SOURCE_DIR}) # define the current platform in use and provide to the user some options to control finally targetted platform

manage_Plugins() # define available plugins and plugins in use

set(PACKAGE_BINARY_INSTALL_DIR ${CMAKE_SOURCE_DIR}/install CACHE INTERNAL "")
set(EXTERNAL_PACKAGE_BINARY_INSTALL_DIR ${CMAKE_SOURCE_DIR}/external CACHE INTERNAL "")

###### automatically managing reference to official remote repository #####
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


##### management of PID version #####
# set the current PID version to memorize when updating the workspace.
set(PID_SYSTEM_VERSION 2 CACHE INTERNAL "")
configure_file(${CMAKE_SOURCE_DIR}/share/patterns/PID_version.cmake.in ${CMAKE_BINARY_DIR}/PID_version.cmake @ONLY) #put it into a file to allow packages to easily retrieve PID version information


#1) reset information about categories
reset_All_Categories()
#2) list the content of the workspace to get clean information about packages and framework
reset_Workspace_Content_Information()
#3) classifying packages w.r.t. framework and categories (framework are set of categories and packages belong to some categories)
classify_Packages()
#4) creating the file that will be used to manage information about categories, packages and frameworks in script file
write_Categories_File()

#adding custom targets providing workspace level commands
add_custom_target(help ALL
	COMMAND ${CMAKE_COMMAND} -E echo "Available PID commands:"
	COMMAND ${CMAKE_COMMAND} -E echo "help -- This help message."
	COMMAND ${CMAKE_COMMAND} -E echo "info -- getting information about the workspace. With no argument it will printing the current version of PID. If the argument framework=*all* is used, then it lists all frameworks. If, instead, the argument framework=*name of a framework* is used, then it prints information about the framework and lists all packages of the framework with same name, ordered by categories defined by the framework. If the argument package=*name of a package* is used then it prints information about the package. If the argument package=*all* is used then it lists all packages ordered by categories. If the argument license=*all* is used then it lists all licenses avilable in the workspace. If the argument license=*a givenl license* is used then it prints precise information on the license."
	COMMAND ${CMAKE_COMMAND} -E echo "deploy -- deploying a package, either soure repository or binary relocatable archive, or a framework. Use only package=*name of a package* argument to deploy source repository of the corresponding native package or external package wrapper. Use in addition version=VERSION to deploy a specific version, this argument must be used for an external package. The argument no_source=true will force the download of an existing binary package version archive. Use the argument force=true to force deployment even if the adequate version already lies in the workspace. Otherwise, if you want to deploy a framework use framework=*name of a framework* argument lonely."
	COMMAND ${CMAKE_COMMAND} -E echo "resolve -- resolving runtime dependencies of an already installed package. Use package=*name of a package* and version=*a version number* arguments to specify the target binary package."
	COMMAND ${CMAKE_COMMAND} -E echo "create -- create a new package, framework or wrapper. Use package=*name of a package* to specify the name of the new package. If you want to create a framework use the framework=*name of a framework* argument instead. If you want to create a wrapper for an external package use the wrapper=*name of an external package* argument instead. Other optional arguments are: author, affiliation, license, and url. If url is used, the connection with a remote repository is established the same way as calling the connect command. If a framework is created you may use the site=*framework web site url* argument."
	COMMAND ${CMAKE_COMMAND} -E echo "connect -- synchronize local repository with a remote one. Required arguments are : package -to specify the name of the package- or framework -same for a framework- or wrapper -same for a wrapper-. Other arguments are official or origin to specify the url of the remote repository to set. official is the default one, and can only be set on an empty remote repository except if the argument force=true is used to force the update of the official repository. "
	COMMAND ${CMAKE_COMMAND} -E echo "clear -- Clearing the whole install directory of a package using package=*name of package*, version=*all* or version=*a valid number* arguments."
	COMMAND ${CMAKE_COMMAND} -E echo "remove -- Removing the target package or framework from the workspace. To remove a package use argument package=*name of the package*. To remove a framework use framework=*name of the framework*."
	COMMAND ${CMAKE_COMMAND} -E echo "register -- Registering the target package in the workspace using package=*name of the package* argument. To register a framework in the workspace use the framework=*name of the framework* argument instead. The package or framework is published so that people with adequate rights can now deploy it."
	COMMAND ${CMAKE_COMMAND} -E echo "release -- Releasing the target package using package=*name of the package* argument and nextversion=*MAJOR* or *MINOR* or *PATCH* to indicate how to increase version number. The release mainly consists in good tagging of branches and publication to the server."
	COMMAND ${CMAKE_COMMAND} -E echo "build -- building target source packages in the workspace. You can use the optionnal argument package=*name of the package* to define which package will be build or use the defaut value all to target all source packages."
	COMMAND ${CMAKE_COMMAND} -E echo "rebuild -- force the rebuild of target source packages in the workspace. You can use the optionnal argument package=*name of the package* to define which package will be build or use the default value *all* to target all source packages."
	COMMAND ${CMAKE_COMMAND} -E echo "update -- updating a source or binary package using package=*name of the package* argument. The last available version is deployed in the workspace. If *all* is used for name, all source and binary packages will be updated."
	COMMAND ${CMAKE_COMMAND} -E echo "upgrade -- upgrading the workspace: install the more recent version of the PID API and references to packages. You can use the optionnal official= argument to use a non official repository to update the workspace, by default official=ON which means the official remote is used. The argument update may be set ON or OFF -optionnal, default to OFF- to update all packages once the upgrade has been done."
	COMMAND ${CMAKE_COMMAND} -E echo "configure -- configuring development environment in use. You have to set the environment name using environment=*name of the environment to use*. You may use the value python to configure python, you then also need to set the target python version with version=*version* or use the value default to go back to default OS version of python."
	COMMAND ${CMAKE_COMMAND} -E echo "hard_clean -- deep cleaning of packages build folder, may be usefull after compiler changes for instance. You have to set the package name using package=*name of the package to clean* or all to hard clean all packages."
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## getting info on the workspace, packages, frameworks or licenses
add_custom_target(info
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=$(package)
					-DTARGET_FRAMEWORK=$(framework)
					-DTARGET_LICENSE=$(license)
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Print_PID_Workspace_Info.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## deploying a package (either soure repository or binary package relocatable archive)
add_custom_target(deploy
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=$(package)
					-DTARGET_VERSION=$(version)
					-DTARGET_FRAMEWORK=$(framework)
					-DVERBOSE_MODE=$(verbose)
					-DFORCE_REDEPLOY=$(force)
					-DNO_SOURCE=$(no_source)
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Deploy_PID_Deployment_Unit.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## building a list of source packages
add_custom_target(build
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGES="$(package)"
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Build_PID_Packages.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## rebuilding a list of source packages
add_custom_target(rebuild
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGES="$(package)"
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Rebuild_PID_Packages.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## resolving runtime dependencies of an already installed package
add_custom_target(resolve
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=$(package)
					-DTARGET_VERSION=$(version)
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Resolve_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## creating a new package
add_custom_target(create
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=$(package)
					-DTARGET_FRAMEWORK=$(framework)
					-DTARGET_WRAPPER=$(wrapper)
					-DOPTIONAL_AUTHOR="$(author)"
					-DOPTIONAL_INSTITUTION="$(affiliation)"
					-DOPTIONAL_LICENSE=$(license)
					-DOPTIONNAL_GIT_URL=$(url)
					-DOPTIONNAL_SITE=$(site)
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Create_PID_Deployment_Unit.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## connect to newly created PID package to an existing empty repository
add_custom_target(connect
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_FRAMEWORK=$(framework)
					-DTARGET_PACKAGE=$(package)
					-DTARGET_WRAPPER=$(wrapper)
					-DOFFICIAL_GIT_URL=$(official)
					-DORIGIN_GIT_URL=$(origin)
					-DFORCED_RECONNECTION=$(force)
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-DCMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Connect_PID_Deployment_Unit.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)


## clearing a package install directory
add_custom_target(clear
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=$(package)
					-DTARGET_VERSION=$(version)
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Clear_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## clearing a package install directory
add_custom_target(hard_clean
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=$(package)
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Hard_Clean_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## completely remove a package from workspace
add_custom_target(remove
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=$(package)
					-DTARGET_FRAMEWORK=$(framework)
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Remove_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)


## register a package in the workspace
add_custom_target(register
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=$(package)
					-DTARGET_FRAMEWORK=$(framework)
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Register_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)


## releasing a package
add_custom_target(release
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=$(package)
					-DNEXT_VERSION=$(nextversion)
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Release_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)


## updating a package
add_custom_target(update
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=$(package)
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Update_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## upgrading the workspace
add_custom_target(upgrade
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_OFFICIAL=$(official)
					-DUPDATE_ALL_PACKAGES=$(update)
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Upgrade_PID_Workspace.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## configuring the workspace
add_custom_target(configure
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_ENVIRONMENT=$(environment)
					-DTARGET_VERSION=$(version)
					-DCURRENT_ENVIRONMENT=${CURRENT_ENVIRONMENT}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/commands/Configure_PID_Environment.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
