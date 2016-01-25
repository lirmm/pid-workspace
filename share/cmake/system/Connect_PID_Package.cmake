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

if(REQUIRED_PACKAGE)
	if(NOT EXISTS ${WORKSPACE_DIR}/packages/${REQUIRED_PACKAGE} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/packages/${REQUIRED_PACKAGE})
		message("[PID notification] ERROR : Package ${REQUIRED_PACKAGE} to connect is not contained in the workspace.")
		return()
	endif()
	if(NOT OFFICIAL_GIT_URL AND NOT ORIGIN_GIT_URL)
		message("[PID notification] ERROR : you must enter a git url using official=<git url> argument. This will set the address of the official remote from where you will update realeased modifications. You can in addition set the address of the origin remote by using origin=<git url>. This will set the address where you will push your modifications. If you do not set origin then it will take the value of official.")
		return()
	
	elseif(NOT OFFICIAL_GIT_URL) # possible only if add an origin to a package that only gets an official (adding connection to a private version of the repository)
		set(ALREADY_CONNECTED FALSE)
		is_Package_Connected(ALREADY_CONNECTED ${REQUIRED_PACKAGE} official)
		if(NOT ALREADY_CONNECTED)#the package must be connected to the official branch for this option to be valid
			message("[PID notification] ERROR : package ${REQUIRED_PACKAGE} is not connected to an official git repository. This indicates a package in a bad state. This must be solved using official=<address of the official repository> option.")
			return()
		endif()
		get_Repository_Name(RES_NAME ${ORIGIN_GIT_URL})	
		if(NOT "${RES_NAME}" STREQUAL "${REQUIRED_PACKAGE}")
			message("[PID notification] ERROR : the git url of the origin remote repository (${ORIGIN_GIT_URL}) does not define a repository with same name than package ${REQUIRED_PACKAGE}.")
			return()
		endif()
		#here the request is OK, we can apply => changing the origin to make it target a new origin remote (most of time from official TO private remote)
		reconnect_PID_Package(${REQUIRED_PACKAGE} ${ORIGIN_GIT_URL})
		
	else()# standard case after a package creation (setting its official repository)
		set(ALREADY_CONNECTED FALSE)
		is_Package_Connected(ALREADY_CONNECTED ${REQUIRED_PACKAGE} official)
		if(ALREADY_CONNECTED AND NOT (FORCED_RECONNECTION STREQUAL "true"))
			message("[PID notification] ERROR : package ${REQUIRED_PACKAGE} is already connected to an official git repository. Use the force=true option to force the reconnection.")
			return()
		endif()
		get_Repository_Name(RES_NAME ${OFFICIAL_GIT_URL})	
		if(NOT "${RES_NAME}" STREQUAL "${REQUIRED_PACKAGE}")
			message("[PID notification] ERROR : the git url of the official repository (${OFFICIAL_GIT_URL}) does not define a repository with same name than package ${REQUIRED_PACKAGE}.")
			return()
		endif()

		if(ORIGIN_GIT_URL)#both official AND origin are set (sanity check)
			get_Repository_Name(RES_NAME ${ORIGIN_GIT_URL})	
			if(NOT "${RES_NAME}" STREQUAL "${REQUIRED_PACKAGE}")
				message("[PID notification] ERROR : the git url of the origin repository (${ORIGIN_GIT_URL}) does not define a repository with same name than package ${REQUIRED_PACKAGE}.")
				return()
			endif()
		endif()

		if(FORCED_RECONNECTION STREQUAL "true")#changing the official repository
			connect_PID_Package(${REQUIRED_PACKAGE} ${OFFICIAL_GIT_URL} FALSE)
		else()
			connect_PID_Package(${REQUIRED_PACKAGE} ${OFFICIAL_GIT_URL} TRUE)
		endif()
		message("[PID notification] INFO : Package ${REQUIRED_PACKAGE} has been connected with official remote  ${OFFICIAL_GIT_URL}.")
		add_Connection_To_PID_Package(${REQUIRED_PACKAGE} ${ORIGIN_GIT_URL})
		message("[PID notification] INFO : Package ${REQUIRED_PACKAGE} has been connected with origin remote  ${ORIGIN_GIT_URL}.")
		
	endif()
	
else()
	message("[PID notification] ERROR : You must specify the name of the package to connect to a git repository using name=<name of package> argument.")
endif()



