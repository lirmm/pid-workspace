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
#	You can find the complete license description on the official website 		#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################

CMAKE_MINIMUM_REQUIRED(VERSION 3.0.2)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/licenses)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/find)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/constraints/platforms)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)

PROJECT(pid-workspace)
include(CheckOS)

####
set(PACKAGE_BINARY_INSTALL_DIR ${CMAKE_SOURCE_DIR}/install CACHE INTERNAL "")
set(EXTERNAL_PACKAGE_BINARY_INSTALL_DIR ${CMAKE_SOURCE_DIR}/external CACHE INTERNAL "")

###### automatically managing reference to official remote repository #####
set(PID_OFFICIAL_REMOTE_ADDRESS "git@gite.lirmm.fr:pid/pid-workspace.git" CACHE STRING "address of the official PID repository") #this is the "central" repo for PID system
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git remote -v OUTPUT_VARIABLE res)
string(REPLACE "\n" ";" GIT_REMOTES ${res})
set(OFFICIAL_EXISTS)
if(GIT_REMOTES) #there are remotes defined
	foreach(remote IN ITEMS ${GIT_REMOTES})
		string(REGEX REPLACE "^[ \t]*official[ \t]+([^ \t]+)[ \t]*\\(fetch\\)(.*)$" "\\1" OFFICIAL_ADDR ${remote})
		if(NOT "${remote}" STREQUAL "${OFFICIAL_ADDR}")#i.e. match => official already exists
			set(OFFICIAL_EXISTS ${OFFICIAL_ADDR})
			break()
		endif()
	endforeach()
endif()
if(NOT OFFICIAL_EXISTS)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git remote add official ${PID_OFFICIAL_REMOTE_ADDRESS})
elseif(NOT OFFICIAL_EXISTS STREQUAL PID_OFFICIAL_REMOTE_ADDRESS)#strange thing remote may have changed
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git remote set-url official ${PID_OFFICIAL_REMOTE_ADDRESS})
endif()


##### management of PID version #####
# set the current PID version to memorize when updating the workspace.
set(PID_SYSTEM_VERSION 1 CACHE INTERNAL "")
configure_file(${CMAKE_SOURCE_DIR}/share/patterns/PID_version.cmake.in ${CMAKE_BINARY_DIR}/PID_version.cmake @ONLY) #put it into a file to allow package to easily retrieve PID version information


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
extract_Root_Categories("${ALL_AVAILABLE_PACKAGES}") #getting the root categories
classify_Package_Categories("${ALL_AVAILABLE_PACKAGES}")

#5) registering categories
write_Categories_File()

#adding targets
add_custom_target(help ALL
	COMMAND ${CMAKE_COMMAND} -E echo "Available PID commands:"
	COMMAND ${CMAKE_COMMAND} -E echo "help -- This help message."
	COMMAND ${CMAKE_COMMAND} -E echo "version -- getting version of the workspace."
	COMMAND ${CMAKE_COMMAND} -E echo "list -- listing all packages ordered by categories OR listing the content of a given category using name=NAME_OF_CATEGORY argument."
	COMMAND ${CMAKE_COMMAND} -E echo "info -- getting info on a given package using name=NAME_OF_PACKAGE argument."
	COMMAND ${CMAKE_COMMAND} -E echo "deploy -- deploying a package, either soure repository or binary relocatable archive. Use only name=NAME_OF_PACKAGE argument to deploy source repository or use in addition version=VERSION to deploy the specific binary version. If you want to deploy an external package use extern=true argument."
	COMMAND ${CMAKE_COMMAND} -E echo "resolve -- resolving runtime dependencies of an already installed package. Use name=NAME_OF_PACKAGE and version=VERSION arguments to specify the target binary package."
	COMMAND ${CMAKE_COMMAND} -E echo "create -- create a new package. Use name=NAME_OF_PACKAGE to specify the name of the new package. Other optional arguments are: author, affiliation, license and url. If url is used, the connection with a remote repository is established as calling the connect command."
	COMMAND ${CMAKE_COMMAND} -E echo "connect -- Synchronize local repository with an empty remote one. Required arguments are : name to specify the name of the package and url to specify the url of the remote repository."
	COMMAND ${CMAKE_COMMAND} -E echo "license -- Printing information on licenses or more precise information on a given license using name=NAME_OF_LICENSE argument."
	COMMAND ${CMAKE_COMMAND} -E echo "clear -- Clearing the whole install directory of a package using name=NAME_OF_PACKAGE, version=all or version=a valid number arguments."
	COMMAND ${CMAKE_COMMAND} -E echo "remove -- Removing the target package from the workspace using name=NAME_OF_PACKAGE argument."
	COMMAND ${CMAKE_COMMAND} -E echo "register -- Registering the target package in the workspace using name=NAME_OF_PACKAGE argument. The package is published so that people with adequate rights can now deploy it adequately."
	COMMAND ${CMAKE_COMMAND} -E echo "release -- Releasing the target package using name=NAME_OF_PACKAGE argument and nextversion=MAJOR or MINOR or PATCH to indicate how to icnrease version number. The release mainly consists in good tagging of branches and publication to the server."
	COMMAND ${CMAKE_COMMAND} -E echo "build -- building target source packages in the workspace. You can use the optionnal argument name= to define which package will be build or use the defaut value all to target all source packages."
	COMMAND ${CMAKE_COMMAND} -E echo "rebuild -- force the rebuild of target source packages in the workspace. You can use the optionnal argument name= to define which packages will be build or use the default value all to target all source packages."
	COMMAND ${CMAKE_COMMAND} -E echo "update -- updating a source or binary package using name=NAME_OF_PACKAGE argument. The last available version is deployed in the workspace. If all is used for name, all source and binary packages will be updated."
	COMMAND ${CMAKE_COMMAND} -E echo "upgrade -- upgrading the workspace: install the more recent version of the PID API and references to packages. You can use the optionnal official argument to use non official remote you will use to update the workspace, by default official=ON which means the official remote is used. The argument update may be set ON or OFF -optionnal, default to OFF- to update all packages once the upgrade has been done."
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## listing all packages ordered by categories OR listing the content of a given category
add_custom_target(version
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Print_PID_Workspace_Version.cmake
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
					-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
					-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
					-DCMAKE_COMPILER_IS_GNUCXX=${CMAKE_COMPILER_IS_GNUCXX}
					-DCMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}
					-DCMAKE_CXX_COMPILER_VERSION=${CMAKE_CXX_COMPILER_VERSION}
					-DCMAKE_LINKER=${CMAKE_LINKER}
					-DCMAKE_RANLIB=${CMAKE_RANLIB}
					-DCMAKE_NM=${CMAKE_NM}
					-DCMAKE_AR=${CMAKE_AR}
					-DCMAKE_OBJDUMP=${CMAKE_OBJDUMP}
					-DCMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}
					-DCMAKE_SYSTEM_PROGRAM_PATH="${CMAKE_SYSTEM_PROGRAM_PATH}"
					-DCMAKE_SYSTEM_INCLUDE_PATH="${CMAKE_SYSTEM_INCLUDE_PATH}"
					-DCMAKE_SYSTEM_LIBRARY_PATH="${CMAKE_SYSTEM_LIBRARY_PATH}"
					-DCMAKE_FIND_LIBRARY_PREFIXES="${CMAKE_FIND_LIBRARY_PREFIXES}"
					-DCMAKE_FIND_LIBRARY_SUFFIXES="${CMAKE_FIND_LIBRARY_SUFFIXES}"
					-DCMAKE_SYSTEM_PREFIX_PATH="${CMAKE_SYSTEM_PREFIX_PATH}"
					-DCMAKE_LIBRARY_ARCHITECTURE=${CMAKE_LIBRARY_ARCHITECTURE}
					-DCURRENT_DISTRIBUTION=${CURRENT_DISTRIBUTION}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Print_PID_Package_Info.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## deploying a package (either soure repository or binary package relocatable archive) 
add_custom_target(deploy
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-DPACKAGE_BINARY_INSTALL_DIR=${CMAKE_SOURCE_DIR}/install
					-DEXTERNAL_PACKAGE_BINARY_INSTALL_DIR=${CMAKE_SOURCE_DIR}/external
					-DREQUIRED_PACKAGE=$(name) 
					-DREQUIRED_VERSION=$(version)
					-DREQUIRED_EXTERNAL=$(extern)
					-DCMAKE_SOURCE_DIR=${CMAKE_SOURCE_DIR}
					-DCMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}
					-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
					-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}					
					-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
					-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
					-DCMAKE_COMPILER_IS_GNUCXX=${CMAKE_COMPILER_IS_GNUCXX}
					-DCMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}
					-DCMAKE_CXX_COMPILER_VERSION=${CMAKE_CXX_COMPILER_VERSION}
					-DCMAKE_LINKER=${CMAKE_LINKER}
					-DCMAKE_RANLIB=${CMAKE_RANLIB}
					-DCMAKE_NM=${CMAKE_NM}
					-DCMAKE_AR=${CMAKE_AR}
					-DCMAKE_OBJDUMP=${CMAKE_OBJDUMP}
					-DCMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}
					-DCMAKE_SYSTEM_PROGRAM_PATH="${CMAKE_SYSTEM_PROGRAM_PATH}"
					-DCMAKE_SYSTEM_INCLUDE_PATH="${CMAKE_SYSTEM_INCLUDE_PATH}"
					-DCMAKE_SYSTEM_LIBRARY_PATH="${CMAKE_SYSTEM_LIBRARY_PATH}"
					-DCMAKE_FIND_LIBRARY_PREFIXES="${CMAKE_FIND_LIBRARY_PREFIXES}"
					-DCMAKE_FIND_LIBRARY_SUFFIXES="${CMAKE_FIND_LIBRARY_SUFFIXES}"
					-DCMAKE_SYSTEM_PREFIX_PATH="${CMAKE_SYSTEM_PREFIX_PATH}"
					-DCMAKE_LIBRARY_ARCHITECTURE=${CMAKE_LIBRARY_ARCHITECTURE}
					-DCURRENT_DISTRIBUTION=${CURRENT_DISTRIBUTION}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Deploy_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## building a list of source packages  
add_custom_target(build
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-DREQUIRED_PACKAGES="$(name)"
					-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Build_PID_Packages.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## rebuilding a list of source packages  
add_custom_target(rebuild
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-DREQUIRED_PACKAGES="$(name)"
					-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Rebuild_PID_Packages.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## resolving runtime dependencies of an already installed package
add_custom_target(resolve
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-DPACKAGE_BINARY_INSTALL_DIR=${CMAKE_SOURCE_DIR}/install
					-DEXTERNAL_PACKAGE_BINARY_INSTALL_DIR=${CMAKE_SOURCE_DIR}/external
					-DREQUIRED_PACKAGE=$(name) 
					-DREQUIRED_VERSION=$(version)
					-DCMAKE_SOURCE_DIR=${CMAKE_SOURCE_DIR}
					-DCMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}
					-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
					-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
					-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
					-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
					-DCMAKE_COMPILER_IS_GNUCXX=${CMAKE_COMPILER_IS_GNUCXX}
					-DCMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}
					-DCMAKE_CXX_COMPILER_VERSION=${CMAKE_CXX_COMPILER_VERSION}
					-DCMAKE_LINKER=${CMAKE_LINKER}
					-DCMAKE_RANLIB=${CMAKE_RANLIB}
					-DCMAKE_NM=${CMAKE_NM}
					-DCMAKE_AR=${CMAKE_AR}
					-DCMAKE_OBJDUMP=${CMAKE_OBJDUMP}
					-DCMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}
					-DCMAKE_SYSTEM_PROGRAM_PATH="${CMAKE_SYSTEM_PROGRAM_PATH}"
					-DCMAKE_SYSTEM_INCLUDE_PATH="${CMAKE_SYSTEM_INCLUDE_PATH}"
					-DCMAKE_SYSTEM_LIBRARY_PATH="${CMAKE_SYSTEM_LIBRARY_PATH}"
					-DCMAKE_FIND_LIBRARY_PREFIXES="${CMAKE_FIND_LIBRARY_PREFIXES}"
					-DCMAKE_FIND_LIBRARY_SUFFIXES="${CMAKE_FIND_LIBRARY_SUFFIXES}"
					-DCMAKE_SYSTEM_PREFIX_PATH="${CMAKE_SYSTEM_PREFIX_PATH}"
					-DCMAKE_LIBRARY_ARCHITECTURE=${CMAKE_LIBRARY_ARCHITECTURE}
					-DCURRENT_DISTRIBUTION=${CURRENT_DISTRIBUTION}
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
					-DCMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}
					-DREQUIRED_PACKAGE=$(name) 
					-DOFFICIAL_GIT_URL=$(official)
					-DORIGIN_GIT_URL=$(origin)
					-DFORCED_RECONNECTION=$(force)
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
					-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
					-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}					
					-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
					-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
					-DCMAKE_COMPILER_IS_GNUCXX=${CMAKE_COMPILER_IS_GNUCXX}
					-DCMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}
					-DCMAKE_CXX_COMPILER_VERSION=${CMAKE_CXX_COMPILER_VERSION}
					-DCMAKE_LINKER=${CMAKE_LINKER}
					-DCMAKE_RANLIB=${CMAKE_RANLIB}
					-DCMAKE_NM=${CMAKE_NM}
					-DCMAKE_AR=${CMAKE_AR}
					-DCMAKE_OBJDUMP=${CMAKE_OBJDUMP}
					-DCMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}
					-DCMAKE_SYSTEM_PROGRAM_PATH="${CMAKE_SYSTEM_PROGRAM_PATH}"
					-DCMAKE_SYSTEM_INCLUDE_PATH="${CMAKE_SYSTEM_INCLUDE_PATH}"
					-DCMAKE_SYSTEM_LIBRARY_PATH="${CMAKE_SYSTEM_LIBRARY_PATH}"
					-DCMAKE_FIND_LIBRARY_PREFIXES="${CMAKE_FIND_LIBRARY_PREFIXES}"
					-DCMAKE_FIND_LIBRARY_SUFFIXES="${CMAKE_FIND_LIBRARY_SUFFIXES}"
					-DCMAKE_SYSTEM_PREFIX_PATH="${CMAKE_SYSTEM_PREFIX_PATH}"
					-DCMAKE_LIBRARY_ARCHITECTURE=${CMAKE_LIBRARY_ARCHITECTURE}
					-DCURRENT_DISTRIBUTION=${CURRENT_DISTRIBUTION}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Release_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)


## updating a package
add_custom_target(update
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DPACKAGE_BINARY_INSTALL_DIR=${CMAKE_SOURCE_DIR}/install
					-DEXTERNAL_PACKAGE_BINARY_INSTALL_DIR=${CMAKE_SOURCE_DIR}/external
					-DTARGET_PACKAGE=$(name)
					-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
					-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}					
					-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
					-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
					-DCMAKE_COMPILER_IS_GNUCXX=${CMAKE_COMPILER_IS_GNUCXX}
					-DCMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}
					-DCMAKE_CXX_COMPILER_VERSION=${CMAKE_CXX_COMPILER_VERSION}
					-DCMAKE_LINKER=${CMAKE_LINKER}
					-DCMAKE_RANLIB=${CMAKE_RANLIB}
					-DCMAKE_NM=${CMAKE_NM}
					-DCMAKE_AR=${CMAKE_AR}
					-DCMAKE_OBJDUMP=${CMAKE_OBJDUMP}
					-DCMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}
					-DCMAKE_SYSTEM_PROGRAM_PATH="${CMAKE_SYSTEM_PROGRAM_PATH}"
					-DCMAKE_SYSTEM_INCLUDE_PATH="${CMAKE_SYSTEM_INCLUDE_PATH}"
					-DCMAKE_SYSTEM_LIBRARY_PATH="${CMAKE_SYSTEM_LIBRARY_PATH}"
					-DCMAKE_FIND_LIBRARY_PREFIXES="${CMAKE_FIND_LIBRARY_PREFIXES}"
					-DCMAKE_FIND_LIBRARY_SUFFIXES="${CMAKE_FIND_LIBRARY_SUFFIXES}"
					-DCMAKE_SYSTEM_PREFIX_PATH="${CMAKE_SYSTEM_PREFIX_PATH}"
					-DCMAKE_LIBRARY_ARCHITECTURE=${CMAKE_LIBRARY_ARCHITECTURE}
					-DCURRENT_DISTRIBUTION=${CURRENT_DISTRIBUTION}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Update_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## upgrading the workspace
add_custom_target(upgrade
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-DPACKAGE_BINARY_INSTALL_DIR=${CMAKE_SOURCE_DIR}/install
					-DEXTERNAL_PACKAGE_BINARY_INSTALL_DIR=${CMAKE_SOURCE_DIR}/external
					-DTARGET_OFFICIAL=$(official)
					-DUPDATE_ALL_PACKAGES=$(update)
					-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
					-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}					
					-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
					-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
					-DCMAKE_COMPILER_IS_GNUCXX=${CMAKE_COMPILER_IS_GNUCXX}
					-DCMAKE_CXX_COMPILER_ID=${CMAKE_CXX_COMPILER_ID}
					-DCMAKE_CXX_COMPILER_VERSION=${CMAKE_CXX_COMPILER_VERSION}
					-DCMAKE_LINKER=${CMAKE_LINKER}
					-DCMAKE_RANLIB=${CMAKE_RANLIB}
					-DCMAKE_NM=${CMAKE_NM}
					-DCMAKE_AR=${CMAKE_AR}
					-DCMAKE_OBJDUMP=${CMAKE_OBJDUMP}
					-DCMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}
					-DCMAKE_SYSTEM_PROGRAM_PATH="${CMAKE_SYSTEM_PROGRAM_PATH}"
					-DCMAKE_SYSTEM_INCLUDE_PATH="${CMAKE_SYSTEM_INCLUDE_PATH}"
					-DCMAKE_SYSTEM_LIBRARY_PATH="${CMAKE_SYSTEM_LIBRARY_PATH}"
					-DCMAKE_FIND_LIBRARY_PREFIXES="${CMAKE_FIND_LIBRARY_PREFIXES}"
					-DCMAKE_FIND_LIBRARY_SUFFIXES="${CMAKE_FIND_LIBRARY_SUFFIXES}"
					-DCMAKE_SYSTEM_PREFIX_PATH="${CMAKE_SYSTEM_PREFIX_PATH}"
					-DCMAKE_LIBRARY_ARCHITECTURE=${CMAKE_LIBRARY_ARCHITECTURE}
					-DCURRENT_DISTRIBUTION=${CURRENT_DISTRIBUTION}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Upgrade_PID_Workspace.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
