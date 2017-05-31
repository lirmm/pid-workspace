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

include(${WORKSPACE_DIR}/pid/Workspace_Platforms_Info.cmake) #loading the current platform configuration

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)

# needed to parse adequately CMAKe variables passed to the script
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PROGRAM_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_INCLUDE_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_LIBRARY_PATH)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_PREFIXES)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_SUFFIXES)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PREFIX_PATH)

#including the adequate reference file
if(TARGET_FRAMEWORK AND (NOT TARGET_FRAMEWORK STREQUAL ""))# a framework is deployed
	# checks of the arguments
	include(ReferFramework${TARGET_FRAMEWORK} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
		message("[PID] ERROR : Framework name ${TARGET_FRAMEWORK} does not refer to any known framework in the workspace.")
		return()
	endif()
	# deployment of the framework
	if(EXISTS ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK} AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK})
		message("[PID] ERROR : Source repository for framework ${TARGET_FRAMEWORK} already resides in the workspace.")
		return()
	endif()
	message("[PID] INFO : deploying PID framework ${TARGET_FRAMEWORK} in the workspace ...")
	deploy_PID_Framework(${TARGET_FRAMEWORK} "${VERBOSE_MODE}") #do the job
	return()
else()# a package deployment is required

	# checks of the arguments
	if(TARGET_EXTERNAL AND (NOT TARGET_EXTERNAL STREQUAL ""))
		include(ReferExternal${TARGET_EXTERNAL} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
		if(REQUIRED_STATUS STREQUAL NOTFOUND)
			message("[PID] ERROR : External package name ${TARGET_EXTERNAL} does not refer to any known package in the workspace.")
			return()
		endif()
	elseif(TARGET_PACKAGE AND (NOT TARGET_PACKAGE STREQUAL ""))
		include(Refer${TARGET_PACKAGE} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
		if(REQUIRED_STATUS STREQUAL NOTFOUND)
			message("[PID] ERROR : Package name ${TARGET_PACKAGE} does not refer to any known package in the workspace.")
			return()
		endif()
	else()
		message("[PID] ERROR : You must specify the project to deploy: either a native package name using package=<name of package>, an external package using external=<name of package> or a framework using framework=<name of framework> argument.")
		return()
	endif()

	## start package deployment process
	remove_Progress_File() #reset the build progress information (sanity action)
	begin_Progress(workspace NEED_REMOVE)

	# check of the arguments
	if(TARGET_VERSION)
		if(	TARGET_EXTERNAL AND (NOT TARGET_EXTERNAL STREQUAL "")
			AND EXISTS ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${TARGET_EXTERNAL}/${TARGET_VERSION}
			AND IS_DIRECTORY ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${TARGET_EXTERNAL}/${TARGET_VERSION})
			message("[PID] ERROR : ${TARGET_EXTERNAL} binary version ${TARGET_VERSION} already resides in the workspace.")
			return()
		elseif(	EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE}/${TARGET_VERSION}
			AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE}/${TARGET_VERSION})
			message("[PID] ERROR : ${TARGET_PACKAGE} binary version ${TARGET_VERSION} already resides in the workspace.")
			return()
		endif()
		if(TARGET_EXTERNAL AND (NOT TARGET_EXTERNAL STREQUAL ""))
			set(PACKAGE_NAME ${TARGET_EXTERNAL})
		else()
			set(PACKAGE_NAME ${TARGET_PACKAGE})
		endif()
		# now load the binary references of the package
		load_Package_Binary_References(REFERENCES_OK ${PACKAGE_NAME})
		if(NOT REFERENCES_OK)
			message("[PID] ERROR : Cannot find any reference to a binary version of ${PACKAGE_NAME}. Aborting.")
			return()
		endif()
		exact_Version_Exists(${PACKAGE_NAME} "${TARGET_VERSION}" EXIST)
		if(NOT EXIST)
			message("[PID] ERROR : A binary relocatable archive with version ${TARGET_VERSION} does not exist for package ${PACKAGE_NAME}.")
			return()
		endif()
		if(TARGET_EXTERNAL AND (NOT TARGET_EXTERNAL STREQUAL ""))#external package is deployed
			message("[PID] INFO : deploying external package ${PACKAGE_NAME} (version ${TARGET_VERSION}) in the workspace ...")
			deploy_External_Package(${PACKAGE_NAME} "${TARGET_VERSION}" "${VERBOSE_MODE}")
			return()
		else()#native package is deployed
			message("[PID] INFO : deploying native PID package ${PACKAGE_NAME} (version ${TARGET_VERSION}) in the workspace ...")
			deploy_PID_Package(${PACKAGE_NAME} "${TARGET_VERSION}" "${VERBOSE_MODE}") #do the job
		endif()

	else()
		if(TARGET_EXTERNAL AND (NOT TARGET_EXTERNAL STREQUAL ""))
			message("[PID] ERROR : you need to set a version to deploy an external package like ${TARGET_EXTERNAL}.")
			return()
		elseif(EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
			message("[PID] ERROR : Source repository for package ${TARGET_PACKAGE} already resides in the workspace.")
			return()
		endif()
		message("[PID] INFO : deploying native PID package ${TARGET_PACKAGE} (last version) in the workspace ...")
		deploy_PID_Package(${TARGET_PACKAGE} "${TARGET_VERSION}" "${VERBOSE_MODE}") #do the job
	endif()

	## global management of the process
	message("--------------------------------------------")
	message("All packages deployed during this process : ")
	print_Deployed_Packages()
	finish_Progress(TRUE) #reset the build progress information

endif()
