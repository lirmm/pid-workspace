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

include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)

if(TARGET_FRAMEWORK AND (NOT TARGET_FRAMEWORK STREQUAL ""))
	include(ReferFramework${TARGET_FRAMEWORK} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
		message("[PID] ERROR : Framework name ${TARGET_FRAMEWORK} does not refer to any known framework in the workspace")
	else()
		print_Framework_Info(${TARGET_FRAMEWORK})	
	endif()
elseif(TARGET_PACKAGE AND (NOT TARGET_PACKAGE STREQUAL ""))
	include(Refer${TARGET_PACKAGE} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
	
		include(ReferExternal${TARGET_PACKAGE} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
		if(REQUIRED_STATUS STREQUAL NOTFOUND)
			message("[PID] ERROR : Package name ${TARGET_PACKAGE} does not refer to any known package in the workspace")
			return()
		endif()
		print_External_Package_Info(${TARGET_PACKAGE})
		return()
	endif()
	print_Package_Info(${TARGET_PACKAGE})
else()
	message("[PID] ERROR : you must specify the name of a package or framework to get information about it. Use package=<name of package> or framework=<name of framework> argument.")
endif()

