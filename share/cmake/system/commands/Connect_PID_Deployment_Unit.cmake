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

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)

include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration

#early common check
if(NOT OFFICIAL_GIT_URL AND NOT ORIGIN_GIT_URL)
	message("[PID] ERROR : you must enter a git url using official=<git url> argument. This will set the address of the official remote from where you will update released modifications. You can in addition set the address of the origin remote by using origin=<git url>. This will set the address where you will push your modifications. If you do not set origin then it will take the value of official.")
	return()
endif()

# managing framework and packages in different ways
if(TARGET_WRAPPER AND (NOT TARGET_WRAPPER STREQUAL ""))# a framework is connected
	if(NOT EXISTS ${WORKSPACE_DIR}/wrappers/${TARGET_WRAPPER} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/wrappers/${TARGET_WRAPPER})
		message("[PID] ERROR : Wrapper ${TARGET_WRAPPER} to connect is not contained in the workspace.")
		return()
	endif()
	if(OFFICIAL_GIT_URL AND NOT OFFICIAL_GIT_URL STREQUAL ""
		AND ORIGIN_GIT_URL AND NOT ORIGIN_GIT_URL STREQUAL "") #framework has no official remote compared to package
		message("[PID] ERROR : Cannot use two different git remotes (origin and official) for wrapper ${TARGET_WRAPPER}  .")
		return()
	endif()
	if((NOT OFFICIAL_GIT_URL OR OFFICIAL_GIT_URL STREQUAL "")
		AND (NOT ORIGIN_GIT_URL AND ORIGIN_GIT_URL STREQUAL "")) #framework has no official remote compared to package
		message("[PID] ERROR : no address given for connecting wrapper ${TARGET_WRAPPER}  .")
		return()
	endif()
	set(URL)
	if(OFFICIAL_GIT_URL)
		set(URL ${OFFICIAL_GIT_URL})
	elseif(ORIGIN_GIT_URL)
		set(URL ${ORIGIN_GIT_URL})
	endif()
	get_Repository_Name(RES_NAME ${URL})
	if(NOT "${RES_NAME}" STREQUAL "${TARGET_WRAPPER}")
		message("[PID] ERROR : the git url of the origin remote repository (${URL}) does not define a repository with same name than wrapper ${TARGET_WRAPPER}.")
		return()
	endif()
	set(ALREADY_CONNECTED FALSE)
	is_Package_Connected(ALREADY_CONNECTED ${TARGET_WRAPPER} origin)
	if(ALREADY_CONNECTED )#the package must be connected to the official remote for this option to be valid
		if(NOT (FORCED_RECONNECTION STREQUAL "true"))
			message("[PID] ERROR : framework ${TARGET_WRAPPER} is already connected to a git repository. Use the force=true option to force the reconnection.")
			return()
		else()
			#here the request is OK, we can apply => changing the origin to make it target a new origin remote (most of time from official TO private remote)
			connect_PID_Wrapper(${TARGET_WRAPPER} ${URL} FALSE)
		endif()
	else()#connect for first time
		connect_PID_Wrapper(${TARGET_WRAPPER} ${URL} TRUE)
	endif()

elseif(TARGET_FRAMEWORK AND (NOT TARGET_FRAMEWORK STREQUAL ""))# a framework is connected
	if(NOT EXISTS ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK})
		message("[PID] ERROR : Framework ${TARGET_FRAMEWORK} to connect is not contained in the workspace.")
		return()
	endif()
	if(OFFICIAL_GIT_URL AND NOT OFFICIAL_GIT_URL STREQUAL ""
		AND ORIGIN_GIT_URL AND NOT ORIGIN_GIT_URL STREQUAL "") #framework has no official remote compared to package
		message("[PID] ERROR : Cannot use two different git remotes (origin and official) for Framework ${TARGET_FRAMEWORK}  .")
		return()
	endif()
	if((NOT OFFICIAL_GIT_URL OR OFFICIAL_GIT_URL STREQUAL "")
		AND (NOT ORIGIN_GIT_URL AND ORIGIN_GIT_URL STREQUAL "")) #framework has no official remote compared to package
		message("[PID] ERROR : no address given for connecting framework ${TARGET_FRAMEWORK}  .")
		return()
	endif()
	set(URL)
	if(OFFICIAL_GIT_URL)
		set(URL ${OFFICIAL_GIT_URL})
	elseif(ORIGIN_GIT_URL)
		set(URL ${ORIGIN_GIT_URL})
	endif()
	get_Repository_Name(RES_NAME ${URL})
	if(NOT "${RES_NAME}" STREQUAL "${TARGET_FRAMEWORK}")
		message("[PID] ERROR : the git url of the origin remote repository (${URL}) does not define a repository with same name than package ${TARGET_FRAMEWORK}.")
		return()
	endif()
	set(ALREADY_CONNECTED FALSE)
	is_Framework_Connected(ALREADY_CONNECTED ${TARGET_FRAMEWORK} origin)
	if(ALREADY_CONNECTED )#the package must be connected to the official remote for this option to be valid
		if(NOT (FORCED_RECONNECTION STREQUAL "true"))
			message("[PID] ERROR : framework ${TARGET_FRAMEWORK} is already connected to a git repository. Use the force=true option to force the reconnection.")
			return()
		else()
			#here the request is OK, we can apply => changing the origin to make it target a new origin remote (most of time from official TO private remote)
			connect_PID_Framework(${TARGET_FRAMEWORK} ${URL} FALSE)
		endif()
	else()#connect for first time
		connect_PID_Framework(${TARGET_FRAMEWORK} ${URL} TRUE)
	endif()

elseif(TARGET_PACKAGE AND (NOT TARGET_PACKAGE STREQUAL ""))
	if(NOT EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
		message("[PID] ERROR : Package ${TARGET_PACKAGE} to connect is not contained in the workspace.")
		return()
	endif()
	if(NOT OFFICIAL_GIT_URL) # possible only if add an origin to a package that only gets an official (adding connection to a private version of the repository)
		set(ALREADY_CONNECTED FALSE)
		is_Package_Connected(ALREADY_CONNECTED ${TARGET_PACKAGE} official)
		if(NOT ALREADY_CONNECTED)#the package must be connected to the official branch for this option to be valid
			message("[PID] ERROR : package ${TARGET_PACKAGE} is not connected to an official git repository. This indicates a package in a bad state. This must be solved using official=<address of the official repository> option.")
			return()
		endif()
		get_Repository_Name(RES_NAME ${ORIGIN_GIT_URL})
		if(NOT "${RES_NAME}" STREQUAL "${TARGET_PACKAGE}")
			message("[PID] ERROR : the git url of the origin remote repository (${ORIGIN_GIT_URL}) does not define a repository with same name than package ${TARGET_PACKAGE}.")
			return()
		endif()
		#here the request is OK, we can apply => changing the origin to make it target a new origin remote (most of time from official TO private remote)
		add_Connection_To_PID_Package(${TARGET_PACKAGE} ${ORIGIN_GIT_URL})

	else()# standard case after a package creation (setting its official repository)
		set(ALREADY_CONNECTED FALSE)
		is_Package_Connected(ALREADY_CONNECTED ${TARGET_PACKAGE} official)
		if(ALREADY_CONNECTED AND NOT (FORCED_RECONNECTION STREQUAL "true"))
			message("[PID] ERROR : package ${TARGET_PACKAGE} is already connected to an official git repository. Use the force=true option to force the reconnection.")
			return()
		endif()
		get_Repository_Name(RES_NAME ${OFFICIAL_GIT_URL})
		if(NOT "${RES_NAME}" STREQUAL "${TARGET_PACKAGE}")
			message("[PID] ERROR : the git url of the official repository (${OFFICIAL_GIT_URL}) does not define a repository with same name than package ${TARGET_PACKAGE}.")
			return()
		endif()

		if(ORIGIN_GIT_URL)#both official AND origin are set (sanity check)
			get_Repository_Name(RES_NAME ${ORIGIN_GIT_URL})
			if(NOT "${RES_NAME}" STREQUAL "${TARGET_PACKAGE}")
				message("[PID] ERROR : the git url of the origin repository (${ORIGIN_GIT_URL}) does not define a repository with same name than package ${TARGET_PACKAGE}.")
				return()
			endif()
		endif()

		if(FORCED_RECONNECTION STREQUAL "true")#changing the official repository
			connect_PID_Package(${TARGET_PACKAGE} ${OFFICIAL_GIT_URL} FALSE)
		else()
			connect_PID_Package(${TARGET_PACKAGE} ${OFFICIAL_GIT_URL} TRUE)
		endif()
		message("[PID] INFO : Package ${TARGET_PACKAGE} has been connected with official remote  ${OFFICIAL_GIT_URL}.")
		if(ORIGIN_GIT_URL)
			add_Connection_To_PID_Package(${TARGET_PACKAGE} ${ORIGIN_GIT_URL})
			message("[PID] INFO : Package ${TARGET_PACKAGE} has been connected with origin remote  ${ORIGIN_GIT_URL}.")
		endif()
	endif()
else()
	message("[PID] ERROR : You must specify the name of the project to connect to a git repository : either a native package using package=<name of package> argument or a framework using framework=<name of framework> argument.")
endif()
