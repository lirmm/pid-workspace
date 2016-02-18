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


list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)
include(Workspace_Internal_Functions NO_POLICY_SCOPE)

# needed to parse adequately CMAKe variables passed to the script
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PROGRAM_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_INCLUDE_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_LIBRARY_PATH)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_PREFIXES)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_SUFFIXES)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PREFIX_PATH)

if(REQUIRED_EXTERNAL)
	include(ReferExternal${REQUIRED_PACKAGE} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
else()
	include(Refer${REQUIRED_PACKAGE} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
endif()

if(REQUIRED_PACKAGE)
	
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
		message("[PID] ERROR : Package name ${REQUIRED_PACKAGE} does not refer to any known package in the workspace.")
		return()
	endif()
	if(REQUIRED_VERSION)
		if(	REQUIRED_EXTERNAL
			AND EXISTS ${WORKSPACE_DIR}/external/${REQUIRED_PACKAGE}/${REQUIRED_VERSION}
			AND IS_DIRECTORY ${WORKSPACE_DIR}/external/${REQUIRED_PACKAGE}/${REQUIRED_VERSION})
			message("[PID] ERROR : ${REQUIRED_PACKAGE} binary version ${REQUIRED_VERSION} already resides in the workspace.")	
			return()
		elseif(	EXISTS ${WORKSPACE_DIR}/install/${REQUIRED_PACKAGE}/${REQUIRED_VERSION}
			AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${REQUIRED_PACKAGE}/${REQUIRED_VERSION})
			message("[PID] ERROR : ${REQUIRED_PACKAGE} binary version ${REQUIRED_VERSION} already resides in the workspace.")	
			return()	
		endif()

		exact_Version_Exists(${REQUIRED_PACKAGE} "${REQUIRED_VERSION}" EXIST)
		if(NOT EXIST)
			message("[PID] ERROR : A binary relocatable archive with version ${REQUIRED_VERSION} does not exist for package ${REQUIRED_PACKAGE}.")
			return()
		endif()
		if(REQUIRED_EXTERNAL)
			message("[PID] INFO : deploying external package ${REQUIRED_PACKAGE} (version ${REQUIRED_VERSION}) in the workspace ...")
			deploy_External_Package(${REQUIRED_PACKAGE} "${REQUIRED_VERSION}")
			return()
		endif()
		message("[PID] INFO : deploying native PID package ${REQUIRED_PACKAGE} (version ${REQUIRED_VERSION}) in the workspace ...")
	else()
		if(REQUIRED_EXTERNAL)
			message("[PID] ERROR : you need to set a version to deploy an external package like ${REQUIRED_PACKAGE}.")
			return()
		elseif(EXISTS ${WORKSPACE_DIR}/packages/${REQUIRED_PACKAGE} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${REQUIRED_PACKAGE})
			message("[PID] ERROR : Source repository for package ${REQUIRED_PACKAGE} already resides in the workspace.")
			return()	
		endif()
		message("[PID] INFO : deploying native PID package ${REQUIRED_PACKAGE} (last version) in the workspace ...")
	endif()
	deploy_PID_Package(${REQUIRED_PACKAGE} "${REQUIRED_VERSION}")
	
else()
	message("[PID] ERROR : You must specify a package using name=<name of package> argument.")
endif()


