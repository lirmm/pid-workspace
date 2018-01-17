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

if(TARGET_FRAMEWORK AND (NOT TARGET_FRAMEWORK STREQUAL ""))# a framework is created
	include(${WORKSPACE_DIR}/share/cmake/references/ReferFramework${TARGET_FRAMEWORK}.cmake OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(NOT REQUIRED_STATUS STREQUAL NOTFOUND)
		message("[PID] ERROR : A framework with the same name ${TARGET_FRAMEWORK} is already referenced in the workspace repository.")
		return()
	endif()
	if(EXISTS ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK} AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK})
		message("[PID] ERROR : A framework with the same name ${TARGET_FRAMEWORK} already resides in the workspace filesystem.")
		return()
	endif()
	if(OPTIONAL_LICENSE)
		include(${WORKSPACE_DIR}/share/cmake/licenses/License${OPTIONAL_LICENSE}.cmake OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
		if(REQUIRED_STATUS STREQUAL NOTFOUND)
			message("[PID] ERROR : License ${OPTIONAL_LICENSE} does not refer to any known license in the workspace.")
			return()
		endif()
	endif()
	if(OPTIONNAL_GIT_URL)
		get_Repository_Name(RES_NAME ${OPTIONNAL_GIT_URL})
		if(	NOT "${RES_NAME}" STREQUAL "${TARGET_FRAMEWORK}"
			AND NOT "${RES_NAME}" STREQUAL "${TARGET_FRAMEWORK}-framework")

			message("[PID] ERROR : the git url of the repository (${OPTIONNAL_GIT_URL}) does not define a repository with same name than framework ${TARGET_FRAMEWORK}.")
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

elseif(TARGET_PACKAGE AND (NOT TARGET_PACKAGE STREQUAL ""))

	include(${WORKSPACE_DIR}/share/cmake/references/Refer${TARGET_PACKAGE}.cmake OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(NOT REQUIRED_STATUS STREQUAL NOTFOUND)
		message("[PID] ERROR : A package with the same name ${TARGET_PACKAGE} is already referenced in the workspace repository.")
		return()
	endif()
	if(EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
		message("[PID] ERROR : A package with the same name ${TARGET_PACKAGE} already resides in the workspace filesystem.")
		return()
	endif()
	if(OPTIONAL_LICENSE)
		include(${WORKSPACE_DIR}/share/cmake/licenses/License${OPTIONAL_LICENSE}.cmake OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
		if(REQUIRED_STATUS STREQUAL NOTFOUND)
			message("[PID] ERROR : License ${OPTIONAL_LICENSE} does not refer to any known license in the workspace.")
			return()
		endif()
	endif()
	if(OPTIONNAL_GIT_URL)
		get_Repository_Name(RES_NAME ${OPTIONNAL_GIT_URL})
		if(NOT "${RES_NAME}" STREQUAL "${TARGET_PACKAGE}")
			message("[PID] ERROR : the git url of the repository (${OPTIONNAL_GIT_URL}) does not define a repository with same name than package ${TARGET_PACKAGE}.")
			return()
		endif()
	endif()

	# from here we are sure the request is well formed
	if(OPTIONNAL_GIT_URL)
		test_Package_Remote_Initialized(${TARGET_PACKAGE} ${OPTIONNAL_GIT_URL} IS_INITIALIZED)#the package is initialized as soon as it has an integration branch (no really perfect but simple and preserve time and memory -> no need to fetch the repository, so no network delays)
		if(IS_INITIALIZED)#simply clone
			clone_Repository(IS_DEPLOYED ${TARGET_PACKAGE} ${OPTIONNAL_GIT_URL})
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

elseif(TARGET_WRAPPER AND (NOT TARGET_WRAPPER STREQUAL ""))
	include(${WORKSPACE_DIR}/share/cmake/references/ReferExternal${TARGET_WRAPPER}.cmake OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(NOT REQUIRED_STATUS STREQUAL NOTFOUND)
		message("[PID] ERROR : A wrapper with the same name ${TARGET_WRAPPER} is already referenced in the workspace repository.")
		return()
	endif()
	if(EXISTS ${WORKSPACE_DIR}/wrappers/${TARGET_WRAPPER} AND IS_DIRECTORY ${WORKSPACE_DIR}/wrappers/${TARGET_WRAPPER})
		message("[PID] ERROR : A wrapper with the same name ${TARGET_WRAPPER} already resides in the workspace filesystem.")
		return()
	endif()
	if(OPTIONAL_LICENSE)
		include(${WORKSPACE_DIR}/share/cmake/licenses/License${OPTIONAL_LICENSE}.cmake OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
		if(REQUIRED_STATUS STREQUAL NOTFOUND)
			message("[PID] ERROR : License ${OPTIONAL_LICENSE} does not refer to any known license in the workspace.")
			return()
		endif()
	endif()
	if(OPTIONNAL_GIT_URL)
		get_Repository_Name(RES_NAME ${OPTIONNAL_GIT_URL})
		if(NOT "${RES_NAME}" STREQUAL "${TARGET_WRAPPER}")
			message("[PID] ERROR : the git url of the repository (${OPTIONNAL_GIT_URL}) does not define a repository with same name than wrapper ${TARGET_WRAPPER}.")
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
	message("[PID] ERROR : You must specify a name for the package to create using package=<name of package> argument or use framework=<name fo framework> to ceate a new framework or use wrapper=<name of the external package> to create a wrapper.")
endif()
