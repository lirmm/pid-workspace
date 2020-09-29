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

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)

load_Workspace_Info() #loading the current platform configuration

#first check that commmand parameters are not passed as environment variables
if(NOT OFFICIAL_GIT_URL AND DEFINED ENV{official})
	set(OFFICIAL_GIT_URL $ENV{official} CACHE INTERNAL "" FORCE)
endif()

if(NOT ORIGIN_GIT_URL AND DEFINED ENV{origin})
	set(ORIGIN_GIT_URL $ENV{origin} CACHE INTERNAL "" FORCE)
endif()

if(NOT FORCED_RECONNECTION AND DEFINED ENV{force})
	set(FORCED_RECONNECTION $ENV{force} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_PACKAGE AND DEFINED ENV{package})
	set(TARGET_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_FRAMEWORK AND DEFINED ENV{framework})
	set(TARGET_FRAMEWORK $ENV{framework} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_WRAPPER AND DEFINED ENV{wrapper})
	set(TARGET_WRAPPER $ENV{wrapper} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_ENVIRONMENT AND DEFINED ENV{environment})
	set(TARGET_ENVIRONMENT $ENV{environment} CACHE INTERNAL "" FORCE)
endif()

#early common check
if(NOT OFFICIAL_GIT_URL AND NOT ORIGIN_GIT_URL)
	message(FATAL_ERROR "[PID] ERROR : you must enter a git url using official=<git url> argument. This will set the address of the official remote from where you will update released modifications. You can in addition set the address of the origin remote by using origin=<git url>. This will set the address where you will push your modifications. If you do not set origin then it will take the value of official.")
endif()

# managing framework and packages in different ways
if(TARGET_WRAPPER)# a framework is connected
	if(NOT EXISTS ${WORKSPACE_DIR}/wrappers/${TARGET_WRAPPER} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/wrappers/${TARGET_WRAPPER})
		message(FATAL_ERROR "[PID] ERROR : Wrapper ${TARGET_WRAPPER} to connect is not contained in the workspace.")
	endif()
	if(OFFICIAL_GIT_URL AND NOT OFFICIAL_GIT_URL STREQUAL ""
		AND ORIGIN_GIT_URL AND NOT ORIGIN_GIT_URL STREQUAL "") #framework has no official remote compared to package
		message(FATAL_ERROR "[PID] ERROR : Cannot use two different git remotes (origin and official) for wrapper ${TARGET_WRAPPER}  .")
	endif()
	if((NOT OFFICIAL_GIT_URL OR OFFICIAL_GIT_URL STREQUAL "")
		AND (NOT ORIGIN_GIT_URL AND ORIGIN_GIT_URL STREQUAL "")) #framework has no official remote compared to package
		message(FATAL_ERROR "[PID] ERROR : no address given for connecting wrapper ${TARGET_WRAPPER}  .")
	endif()
	set(URL)
	if(OFFICIAL_GIT_URL)
		set(URL ${OFFICIAL_GIT_URL})
	elseif(ORIGIN_GIT_URL)
		set(URL ${ORIGIN_GIT_URL})
	endif()
	get_Repository_Name(RES_NAME ${URL})
	if(NOT "${RES_NAME}" STREQUAL "${TARGET_WRAPPER}")
		message(FATAL_ERROR "[PID] ERROR : the git url of the origin remote repository (${URL}) does not define a repository with same name than wrapper ${TARGET_WRAPPER}.")
	endif()
	set(ALREADY_CONNECTED FALSE)
	is_Repository_Connected(ALREADY_CONNECTED ${WORKSPACE_DIR}/wrappers/${TARGET_WRAPPER} origin)
	if(ALREADY_CONNECTED )#the package must be connected to the official remote for this option to be valid
		if(NOT (FORCED_RECONNECTION STREQUAL "true"))
			message(FATAL_ERROR "[PID] ERROR : wrapper ${TARGET_WRAPPER} is already connected to a git repository. Use the force=true option to force the reconnection.")
		else()
			#here the request is OK, we can apply => changing the origin to make it target a new origin remote (most of time from official TO private remote)
			connect_PID_Wrapper(${TARGET_WRAPPER} ${URL} FALSE)
		endif()
	else()#connect for first time
		connect_PID_Wrapper(${TARGET_WRAPPER} ${URL} TRUE)
	endif()

elseif(TARGET_FRAMEWORK)# a framework is connected
	if(NOT EXISTS ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK})
		message(FATAL_ERROR "[PID] ERROR : Framework ${TARGET_FRAMEWORK} to connect is not contained in the workspace.")
	endif()
	if(OFFICIAL_GIT_URL AND ORIGIN_GIT_URL) #framework has no official remote compared to package
		message(FATAL_ERROR "[PID] ERROR : Cannot use two different git remotes (origin and official) for Framework ${TARGET_FRAMEWORK}  .")
	endif()
	set(URL)
	if(OFFICIAL_GIT_URL)
		set(URL ${OFFICIAL_GIT_URL})
	elseif(ORIGIN_GIT_URL)
		set(URL ${ORIGIN_GIT_URL})
	endif()
	get_Repository_Name(RES_NAME ${URL})
	if(NOT RES_NAME STREQUAL TARGET_FRAMEWORK AND NOT RES_NAME STREQUAL "${TARGET_FRAMEWORK}-framework")#the adress can have the -framework extension
		message(FATAL_ERROR "[PID] ERROR : the git url of the origin remote repository (${URL}) does not define a repository with same name than framework ${TARGET_FRAMEWORK}.")
	endif()
	set(ALREADY_CONNECTED FALSE)
	is_Repository_Connected(ALREADY_CONNECTED ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK} origin)
	if(ALREADY_CONNECTED )#the package must be connected to the official remote for this option to be valid
		if(NOT (FORCED_RECONNECTION STREQUAL "true"))
			message(FATAL_ERROR "[PID] ERROR : framework ${TARGET_FRAMEWORK} is already connected to a git repository. Use the force=true option to force the reconnection.")
		else()
			#here the request is OK, we can apply => changing the origin to make it target a new origin remote (most of time from official TO private remote)
			connect_PID_Framework(${TARGET_FRAMEWORK} ${URL} FALSE)
		endif()
	else()#connect for first time
		connect_PID_Framework(${TARGET_FRAMEWORK} ${URL} TRUE)
	endif()

elseif(TARGET_ENVIRONMENT)# an environment is connected
	if(NOT EXISTS ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT})
		message(FATAL_ERROR "[PID] ERROR : Environment ${TARGET_ENVIRONMENT} to connect is not contained in the workspace.")
	endif()
	if(OFFICIAL_GIT_URL AND ORIGIN_GIT_URL) #environment has no official remote compared to package
		message(FATAL_ERROR "[PID] ERROR : Cannot use two different git remotes (origin and official) for environment ${TARGET_ENVIRONMENT}  .")
	endif()
	set(URL)
	if(OFFICIAL_GIT_URL)
		set(URL ${OFFICIAL_GIT_URL})
	elseif(ORIGIN_GIT_URL)
		set(URL ${ORIGIN_GIT_URL})
	endif()
	get_Repository_Name(RES_NAME ${URL})
	if(NOT RES_NAME STREQUAL TARGET_ENVIRONMENT AND NOT RES_NAME STREQUAL "${TARGET_ENVIRONMENT}-environment")#the adress can have the -environment extension
		message(FATAL_ERROR "[PID] ERROR : the git url of the origin remote repository (${URL}) does not define a repository with same name than environment ${TARGET_FRAMEWORK}.")
	endif()
	set(ALREADY_CONNECTED FALSE)
	is_Repository_Connected(ALREADY_CONNECTED ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT} origin)
	if(ALREADY_CONNECTED )#the package must be connected to the official remote for this option to be valid
		if(NOT (FORCED_RECONNECTION STREQUAL "true"))
			message(FATAL_ERROR "[PID] ERROR : environment ${TARGET_ENVIRONMENT} is already connected to a git repository. Use the force=true option to force the reconnection.")
		else()
			#here the request is OK, we can apply => changing the origin to make it target a new origin remote (most of time from official TO private remote)
			connect_PID_Environment(${TARGET_ENVIRONMENT} ${URL} FALSE)
		endif()
	else()#connect for first time
		connect_PID_Environment(${TARGET_ENVIRONMENT} ${URL} TRUE)
	endif()

elseif(TARGET_PACKAGE)
	if(NOT EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
		message(FATAL_ERROR "[PID] ERROR : Package ${TARGET_PACKAGE} to connect is not contained in the workspace.")
	endif()
	if(NOT OFFICIAL_GIT_URL) # possible only if add an origin to a package that only gets an official (adding connection to a private version of the repository)
		set(ALREADY_CONNECTED FALSE)
		is_Repository_Connected(ALREADY_CONNECTED ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} official)
		if(NOT ALREADY_CONNECTED)#the package must be connected to the official branch for this option to be valid
			message(FATAL_ERROR "[PID] ERROR : package ${TARGET_PACKAGE} is not connected to an official git repository. This indicates a package in a bad state. This must be solved using official=<address of the official repository> option.")
		endif()
		get_Repository_Name(RES_NAME ${ORIGIN_GIT_URL})
		if(NOT "${RES_NAME}" STREQUAL "${TARGET_PACKAGE}")
			message(FATAL_ERROR "[PID] ERROR : the git url of the origin remote repository (${ORIGIN_GIT_URL}) does not define a repository with same name than package ${TARGET_PACKAGE}.")
		endif()
		#here the request is OK, we can apply => changing the origin to make it target a new origin remote (most of time from official TO private remote)
		add_Connection_To_PID_Package(${TARGET_PACKAGE} ${ORIGIN_GIT_URL})

	else()# standard case after a package creation (setting its official repository)
		set(ALREADY_CONNECTED FALSE)
		is_Repository_Connected(ALREADY_CONNECTED ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} official)
		if(ALREADY_CONNECTED AND NOT (FORCED_RECONNECTION STREQUAL "true"))
			message(FATAL_ERROR "[PID] ERROR : package ${TARGET_PACKAGE} is already connected to an official git repository. Use the force=true option to force the reconnection.")
		endif()
		get_Repository_Name(RES_NAME ${OFFICIAL_GIT_URL})
		if(NOT RES_NAME STREQUAL "${TARGET_PACKAGE}")
			message(FATAL_ERROR "[PID] ERROR : the git url of the official repository (${OFFICIAL_GIT_URL}) does not define a repository with same name than package ${TARGET_PACKAGE}.")
		endif()

		if(ORIGIN_GIT_URL)#both official AND origin are set (sanity check)
			get_Repository_Name(RES_NAME ${ORIGIN_GIT_URL})
			if(NOT "${RES_NAME}" STREQUAL "${TARGET_PACKAGE}")
				message(FATAL_ERROR "[PID] ERROR : the git url of the origin repository (${ORIGIN_GIT_URL}) does not define a repository with same name than package ${TARGET_PACKAGE}.")
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
	message(FATAL_ERROR "[PID] ERROR : You must specify the name of the project to connect to a git repository : either a native package using package=<name of package> argument or a framework using framework=<name of framework> argument.")
endif()
