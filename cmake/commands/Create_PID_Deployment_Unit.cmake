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

include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
load_Workspace_Info() #loading the current platform configuration

macro(check_license license_name)
	resolve_License_File(PATH_TO_FILE ${license_name})
	if(NOT PATH_TO_FILE)
		message(FATAL_ERROR "[PID] ERROR : License ${license_name} does not refer to any known license in contributions spaces of the workspace.")
		return()
	endif()
endmacro(check_license)

#first check that commmand parameters are not passed as environment variables
if(NOT OPTIONAL_LICENSE AND DEFINED ENV{license})
	set(OPTIONAL_LICENSE $ENV{license} CACHE INTERNAL "" FORCE)
endif()

if(NOT OPTIONNAL_GIT_URL AND DEFINED ENV{url})
	set(OPTIONNAL_GIT_URL $ENV{url} CACHE INTERNAL "" FORCE)
endif()

if(NOT OPTIONAL_AUTHOR AND DEFINED ENV{author})
	set(OPTIONAL_AUTHOR $ENV{author} CACHE INTERNAL "" FORCE)
endif()

if(NOT OPTIONAL_INSTITUTION AND DEFINED ENV{affiliation})
	set(OPTIONAL_INSTITUTION $ENV{affiliation} CACHE INTERNAL "" FORCE)
endif()

if(NOT OPTIONNAL_SITE AND DEFINED ENV{site})
	set(OPTIONNAL_SITE $ENV{site} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_FRAMEWORK AND DEFINED ENV{framework})
	set(TARGET_FRAMEWORK $ENV{framework} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_PACKAGE AND DEFINED ENV{package})
	set(TARGET_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_WRAPPER AND DEFINED ENV{wrapper})
	set(TARGET_WRAPPER $ENV{wrapper} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_ENVIRONMENT AND DEFINED ENV{environment})
	set(TARGET_ENVIRONMENT $ENV{environment} CACHE INTERNAL "" FORCE)
endif()


#now verify that arguments are consistent and perform adequate actions

if(TARGET_ENVIRONMENT)# a framework is created
	get_Path_To_Environment_Reference_File(RESULT_PATH PATH_TO_CS ${TARGET_ENVIRONMENT})
	if(RESULT_PATH)
		message(FATAL_ERROR "[PID] ERROR : An environment with the same name ${TARGET_ENVIRONMENT} is already referenced in the workspace repository.")
		return()
	endif()
	if(EXISTS ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT} AND IS_DIRECTORY ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT})
		message(FATAL_ERROR "[PID] ERROR : An environment with the same name ${TARGET_ENVIRONMENT} already resides in the workspace filesystem.")
		return()
	endif()
	if(OPTIONAL_LICENSE)
		check_license(${OPTIONAL_LICENSE})
	endif()
	if(OPTIONNAL_GIT_URL)
		get_Repository_Name(RES_NAME ${OPTIONNAL_GIT_URL})
		if(	NOT RES_NAME STREQUAL TARGET_ENVIRONMENT
		AND NOT RES_NAME STREQUAL "${TARGET_ENVIRONMENT}-environment")
			message(FATAL_ERROR "[PID] ERROR : the git url of the repository (${OPTIONNAL_GIT_URL}) does not define a repository with same name than environment ${TARGET_ENVIRONMENT}.")
			return()
		endif()
	endif()
	# from here we are sure the request is well formed
	if(OPTIONNAL_GIT_URL)
		#HERE
		test_Remote_Initialized(${TARGET_ENVIRONMENT} ${OPTIONNAL_GIT_URL} IS_INITIALIZED)#the framework is initialized as soon as it has a branch
		if(IS_INITIALIZED)#simply clone
			clone_Environment_Repository(IS_DEPLOYED ${TARGET_ENVIRONMENT} ${OPTIONNAL_GIT_URL})
			message("[PID] INFO : new environment ${TARGET_ENVIRONMENT} has just been cloned from official remote ${OPTIONNAL_GIT_URL}.")
		else()#we need to synchronize normally with an empty repository
			create_PID_Environment(${TARGET_ENVIRONMENT} "${OPTIONAL_AUTHOR}" "${OPTIONAL_INSTITUTION}" "${OPTIONAL_LICENSE}")
			connect_PID_Environment(${TARGET_ENVIRONMENT} ${OPTIONNAL_GIT_URL} TRUE)
			message("[PID] INFO : new environment ${TARGET_ENVIRONMENT} has just been connected to official remote ${OPTIONNAL_GIT_URL}.")
		endif()

	else() #simply create the package locally
		create_PID_Environment(${TARGET_ENVIRONMENT} "${OPTIONAL_AUTHOR}" "${OPTIONAL_INSTITUTION}" "${OPTIONAL_LICENSE}")
		message("[PID] INFO : new environment ${TARGET_ENVIRONMENT} has just been created locally.")
	endif()

elseif(TARGET_FRAMEWORK)# a framework is created
	get_Path_To_Framework_Reference_File(RESULT_PATH PATH_TO_CS ${TARGET_FRAMEWORK})
	if(RESULT_PATH)
		message(FATAL_ERROR "[PID] ERROR : A framework with the same name ${TARGET_FRAMEWORK} is already referenced in the workspace repository.")
		return()
	endif()
	if(EXISTS ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK} AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK})
		message(FATAL_ERROR "[PID] ERROR : A framework with the same name ${TARGET_FRAMEWORK} already resides in the workspace filesystem.")
		return()
	endif()
	if(OPTIONAL_LICENSE)
		check_license(${OPTIONAL_LICENSE})
	endif()
	if(OPTIONNAL_GIT_URL)
		get_Repository_Name(RES_NAME ${OPTIONNAL_GIT_URL})
		if(	NOT RES_NAME STREQUAL TARGET_FRAMEWORK
			AND NOT RES_NAME STREQUAL "${TARGET_FRAMEWORK}-framework")
			message(FATAL_ERROR "[PID] ERROR : the git url of the repository (${OPTIONNAL_GIT_URL}) does not define a repository with same name than framework ${TARGET_FRAMEWORK}.")
			return()
		endif()
	endif()
	# from here we are sure the request is well formed
	if(OPTIONNAL_GIT_URL)
		test_Remote_Initialized(${TARGET_FRAMEWORK} ${OPTIONNAL_GIT_URL} IS_INITIALIZED)#the framework is initialized as soon as it has a branch
		if(IS_INITIALIZED)#simply clone
			clone_Framework_Repository(IS_DEPLOYED ${TARGET_FRAMEWORK} ${OPTIONNAL_GIT_URL})
			message("[PID] INFO : new framework ${TARGET_FRAMEWORK} has just been cloned from official remote ${OPTIONNAL_GIT_URL}.")
		else()#we need to synchronize normally with an empty repository
			create_PID_Framework(${TARGET_FRAMEWORK} "${OPTIONAL_AUTHOR}" "${OPTIONAL_INSTITUTION}" "${OPTIONAL_LICENSE}" "${OPTIONNAL_SITE}")
			connect_PID_Framework(${TARGET_FRAMEWORK} ${OPTIONNAL_GIT_URL} TRUE)
			message("[PID] INFO : new framework ${TARGET_FRAMEWORK} has just been connected to official remote ${OPTIONNAL_GIT_URL}.")
		endif()

	else() #simply create the package locally
		create_PID_Framework(${TARGET_FRAMEWORK} "${OPTIONAL_AUTHOR}" "${OPTIONAL_INSTITUTION}" "${OPTIONAL_LICENSE}" "${OPTIONAL_SITE}")
		message("[PID] INFO : new framework ${TARGET_FRAMEWORK} has just been created locally.")
	endif()

elseif(TARGET_PACKAGE)
	get_Path_To_Package_Reference_File(RESULT_PATH PATH_TO_CS ${TARGET_PACKAGE})
	if(RESULT_PATH)
		message(FATAL_ERROR "[PID] ERROR : A package with the same name ${TARGET_PACKAGE} is already referenced in the workspace repository.")
		return()
	endif()
	if(EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
		message(FATAL_ERROR "[PID] ERROR : A package with the same name ${TARGET_PACKAGE} already resides in the workspace filesystem.")
		return()
	endif()
	if(OPTIONAL_LICENSE)
		check_license(${OPTIONAL_LICENSE})
	endif()
	if(OPTIONNAL_GIT_URL)
		get_Repository_Name(RES_NAME ${OPTIONNAL_GIT_URL})
		if(NOT RES_NAME STREQUAL TARGET_PACKAGE)
			message(FATAL_ERROR "[PID] ERROR : the git url of the repository (${OPTIONNAL_GIT_URL}) does not define a repository with same name than package ${TARGET_PACKAGE}.")
			return()
		endif()
	endif()

	# from here we are sure the request is well formed
	if(OPTIONNAL_GIT_URL)
		test_Package_Remote_Initialized(${TARGET_PACKAGE} ${OPTIONNAL_GIT_URL} IS_INITIALIZED)#the package is initialized as soon as it has an integration branch (no really perfect but simple and preserve time and memory -> no need to fetch the repository, so no network delays)
		if(IS_INITIALIZED)#simply clone
			clone_Package_Repository(IS_DEPLOYED ${TARGET_PACKAGE} ${OPTIONNAL_GIT_URL})
			go_To_Integration(${TARGET_PACKAGE})
			message("[PID] INFO : new package ${TARGET_PACKAGE} has just been cloned from official remote ${OPTIONNAL_GIT_URL}.")
		else()#we need to synchronize normally with an empty repository
			create_PID_Package(${TARGET_PACKAGE} "${OPTIONAL_AUTHOR}" "${OPTIONAL_INSTITUTION}" "${OPTIONAL_LICENSE}")
			connect_PID_Package(${TARGET_PACKAGE} ${OPTIONNAL_GIT_URL} TRUE)
			message("[PID] INFO : new package ${TARGET_PACKAGE} has just been connected to official remote ${OPTIONNAL_GIT_URL}.")
		endif()

	else() #simply create the package locally
		create_PID_Package(${TARGET_PACKAGE} "${OPTIONAL_AUTHOR}" "${OPTIONAL_INSTITUTION}" "${OPTIONAL_LICENSE}")
		message("[PID] INFO : new package ${TARGET_PACKAGE} has just been created locally.")
	endif()

elseif(TARGET_WRAPPER)
	get_Path_To_External_Reference_File(RESULT_PATH PATH_TO_CS ${TARGET_WRAPPER})
	if(RESULT_PATH)
		message(FATAL_ERROR "[PID] ERROR : An external package with the same name ${TARGET_WRAPPER} is already referenced in the workspace repository.")
		return()
	endif()
	if(EXISTS ${WORKSPACE_DIR}/wrappers/${TARGET_WRAPPER} AND IS_DIRECTORY ${WORKSPACE_DIR}/wrappers/${TARGET_WRAPPER})
		message(FATAL_ERROR "[PID] ERROR : A wrapper with the same name ${TARGET_WRAPPER} already resides in the workspace filesystem.")
		return()
	endif()
	if(OPTIONAL_LICENSE)
		check_license(${OPTIONAL_LICENSE})
	endif()
	if(OPTIONNAL_GIT_URL)
		get_Repository_Name(RES_NAME ${OPTIONNAL_GIT_URL})
		if(NOT "${RES_NAME}" STREQUAL "${TARGET_WRAPPER}")
			message(FATAL_ERROR "[PID] ERROR : the git url of the repository (${OPTIONNAL_GIT_URL}) does not define a repository with same name than wrapper ${TARGET_WRAPPER}.")
			return()
		endif()
	endif()
	# from here we are sure the request is well formed
	if(OPTIONNAL_GIT_URL)
		test_Remote_Initialized(${TARGET_WRAPPER} ${OPTIONNAL_GIT_URL} IS_INITIALIZED)#the framework is initialized as soon as it has a branch
		if(IS_INITIALIZED)#simply clone
			clone_Wrapper_Repository(IS_DEPLOYED ${TARGET_WRAPPER} ${OPTIONNAL_GIT_URL})
			message("[PID] INFO : new wrapper ${TARGET_WRAPPER} has just been cloned from official remote ${OPTIONNAL_GIT_URL}.")
		else()#we need to synchronize normally with an empty repository
			create_PID_Wrapper(${TARGET_WRAPPER} "${OPTIONAL_AUTHOR}" "${OPTIONAL_INSTITUTION}" "${OPTIONAL_LICENSE}")
			connect_PID_Wrapper(${TARGET_WRAPPER} ${OPTIONNAL_GIT_URL} TRUE)
			message("[PID] INFO : new wrapper ${TARGET_WRAPPER} has just been connected to official remote ${OPTIONNAL_GIT_URL}.")
		endif()

	else() #simply create the package locally
		create_PID_Wrapper(${TARGET_WRAPPER} "${OPTIONAL_AUTHOR}" "${OPTIONAL_INSTITUTION}" "${OPTIONAL_LICENSE}" "${OPTIONAL_SITE}")
		message("[PID] INFO : new wrapper ${TARGET_WRAPPER} has just been created locally.")
	endif()

else()
	message(FATAL_ERROR "[PID] ERROR : You must specify a name for the package to create using package=<name of package> argument or use framework=<name fo framework> to ceate a new framework or use wrapper=<name of the external package> to create a wrapper.")
endif()
