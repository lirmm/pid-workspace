#########################################################################################
#	This file is part of the program PID						#
#  	Program description : build system supportting the PID methodology  		#
#  	Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique 	#
#	et de Microelectronique de Montpellier). All Right reserved.			#
#											#
#	This software is free software: you can redistribute it and/or modify		#
#	it under the terms of the CeCILL-C license as published by			#
#	the CEA CNRS INRIA, either version 1						#
#	of the License, or (at your option) any later version.				#
#	This software is distributed in the hope that it will be useful,		#
#	but WITHOUT ANY WARRANTY; without even the implied warranty of			#
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the			#
#	CeCILL-C License for more details.						#
#											#
#	You can be find the complete license description on the official website 	#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################

CMAKE_MINIMUM_REQUIRED(VERSION 3.0.2)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/licenses)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/find)
include(Workspace_Internal_Functions NO_POLICY_SCOPE)

PROJECT(pid-workspace)

set(ALL_AVAILABLE_PACKAGES "")
# 1) searching for all reference files. 
file(GLOB reference_files ${CMAKE_SOURCE_DIR}/share/cmake/references/Refer*.cmake)
# 2) including all reference files and memorizing packages names
foreach(a_ref_file IN ITEMS ${reference_files})
	string(REGEX REPLACE "^${CMAKE_SOURCE_DIR}/share/cmake/references/Refer([^\\.]+)\\.cmake$" "\\1" PACKAGE_NAME ${a_ref_file})
	if(PACKAGE_NAME MATCHES External)#it is an external package
		string(REGEX REPLACE "^External([^\\.]+)$" "\\1" PACKAGE_NAME ${PACKAGE_NAME})
	endif()
	list(APPEND ALL_AVAILABLE_PACKAGES ${PACKAGE_NAME})
	include(${a_ref_file})
endforeach()
# 3) resetting categories
reset_All_Categories()
# 4) extracting all available categories and classifying all packages in these categories
foreach(a_package IN ITEMS ${ALL_AVAILABLE_PACKAGES})
	message("categorizing package ${a_package}")	
	classify_Package_Categories(${a_package})
endforeach()
#5) registering categories
write_Categories_File()

#adding targets
add_custom_target(help ALL
	COMMAND ${CMAKE_COMMAND} -E echo "Available PID commands:"
	COMMAND ${CMAKE_COMMAND} -E echo "list -- listing all packages ordered by categories OR listing the content of a given category using name=NAME_OF_CATEGORY argument."
	COMMAND ${CMAKE_COMMAND} -E echo "info -- getting info on a given package using name=NAME_OF_PACKAGE argument."
	COMMAND ${CMAKE_COMMAND} -E echo "deploy -- deploying a package, either soure repository or binary relocatable archive. Use only name=NAME_OF_PACKAGE argument to deploy source repository or use in addition version=VERSION to deploy the specific binary version."
	COMMAND ${CMAKE_COMMAND} -E echo "resolve -- resolving runtime dependencies of an already installed package. Use name=NAME_OF_PACKAGE and version=VERSION arguments to specify the target binary package."
	COMMAND ${CMAKE_COMMAND} -E echo "create -- create a new package. Use name=NAME_OF_PACKAGE to specify the name of the new package. Other optional arguments are: author, affiliation, license and url. If url is used, the connection with a remote repository is established as calling the connect command."
	COMMAND ${CMAKE_COMMAND} -E echo "connect -- Synchronize local repository with an empty remote one. Required arguments are : name to specify the name of the package and url to specify the url of the remote repository."
	COMMAND ${CMAKE_COMMAND} -E echo "license -- Printing information on licenses or more precise information on a given license using name=NAME_OF_LICENSE argument."
	COMMAND ${CMAKE_COMMAND} -E echo "clear -- Clearing the whole install directory of a package using name=NAME_OF_PACKAGE, version=all or version=a valid number arguments."
	COMMAND ${CMAKE_COMMAND} -E echo "remove -- Removing the target package from the workspace using name=NAME_OF_PACKAGE argument."
	COMMAND ${CMAKE_COMMAND} -E echo "register -- Registering the target package in the workspace using name=NAME_OF_PACKAGE argument. The package is published so that people with adequate rights can now deploy it adequately."
	COMMAND ${CMAKE_COMMAND} -E echo "release -- Releasing the target package using name=NAME_OF_PACKAGE argument and nextversion=MAJOR or MINOR or PATCH to indicate how to icnrease version number. The release mainly consists in good tagging of branches and publication to the server."
	COMMAND ${CMAKE_COMMAND} -E echo "update -- updating a source or binary package using name=NAME_OF_PACKAGE argument. The last available version is deployed in the workspace. If all is used for name, all source and binary packages will be updated."
	COMMAND ${CMAKE_COMMAND} -E echo "upgrade -- upgrading the workspace: install the more recent version of the PID API and references to packages. You can use the optionnal remote argument to set the remote you will use to update the workspace, by default it is the origin remote. The argument update may be set ON or OFF -optionnal, default to ON- to update all packages once the upgrade has been done."
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## listing all packages ordered by categories OR listing the content of a given category
add_custom_target(list
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DREQUIRED_CATEGORY=$(name) 
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Print_PID_Categories.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## getting info on a package
add_custom_target(info
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DREQUIRED_PACKAGE=$(name)
					-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Print_PID_Package_Info.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## deploying a package (either soure repository or binary package relocatable archive) 
add_custom_target(deploy
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DPACKAGE_BINARY_INSTALL_DIR=${CMAKE_SOURCE_DIR}/install
					-DCMAKE_FIND_LIBRARY_PREFIXES=${CMAKE_FIND_LIBRARY_PREFIXES}
					-DCMAKE_FIND_LIBRARY_SUFFIXES=${CMAKE_FIND_LIBRARY_SUFFIXES}
					-DREQUIRED_PACKAGE=$(name) 
					-DREQUIRED_VERSION=$(version)
					-DCMAKE_SOURCE_DIR=${CMAKE_SOURCE_DIR}
					-DCMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}
					-DCMAKE_BUILD_TOOL=${CMAKE_BUILD_TOOL}
					-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Deploy_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## resolving runtime dependencies of an already installed package
add_custom_target(resolve
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-DPACKAGE_BINARY_INSTALL_DIR=${CMAKE_SOURCE_DIR}/install
					-DCMAKE_FIND_LIBRARY_PREFIXES=${CMAKE_FIND_LIBRARY_PREFIXES}
					-DCMAKE_FIND_LIBRARY_SUFFIXES=${CMAKE_FIND_LIBRARY_SUFFIXES}
					-DREQUIRED_PACKAGE=$(name) 
					-DREQUIRED_VERSION=$(version)
					-DCMAKE_SOURCE_DIR=${CMAKE_SOURCE_DIR}
					-DCMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}
					-DCMAKE_BUILD_TOOL=${CMAKE_BUILD_TOOL}
					-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Resolve_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## creating a new package
add_custom_target(create
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DREQUIRED_PACKAGE=$(name) 
					-DOPTIONAL_AUTHOR="$(author)" 
					-DOPTIONAL_INSTITUTION="$(affiliation)"
					-DOPTIONAL_LICENSE=$(license)
					-DOPTIONNAL_GIT_URL=$(url)
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Create_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## connect to newly created PID package to an existing empty repository
add_custom_target(connect
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DREQUIRED_PACKAGE=$(name) 
					-DREQUIRED_GIT_URL=$(url) 
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Connect_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)


## listing available licenses
add_custom_target(license
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DREQUIRED_LICENSE=$(name)
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Print_PID_License_Info.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## clearing a package install directory
add_custom_target(clear
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DTARGET_PACKAGE=$(name)
					-DTARGET_VERSION=$(version)					
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Clear_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)


## completely remove a package from workspace
add_custom_target(remove
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DTARGET_PACKAGE=$(name)
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Remove_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)


## register a package in the workspace
add_custom_target(register
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DTARGET_PACKAGE=$(name)
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Register_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)


## releasing a package
add_custom_target(release
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DTARGET_PACKAGE=$(name)
					-DNEXT_VERSION=$(nextversion)
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Release_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)


## updating a package
add_custom_target(update
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DTARGET_PACKAGE=$(name)
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Update_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## upgrading the workspace
add_custom_target(upgrade
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DTARGET_REMOTE_REPOSITORY=$(remote)
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Upgrade_PID_Workspace.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
