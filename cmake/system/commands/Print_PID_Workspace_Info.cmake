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

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake/system/commands)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake/references)

include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration

include(${WORKSPACE_DIR}/pid/CategoriesInfo.cmake NO_POLICY_SCOPE)

#manage arguments if they are passed as environmentvariables (for non UNIX makefile generators usage)
if(NOT TARGET_FRAMEWORK AND DEFINED ENV{framework})
	set(TARGET_FRAMEWORK $ENV{framework} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_ENVIRONMENT AND DEFINED ENV{environment})#to manage the call for non UNIX makefile generators
	set(TARGET_ENVIRONMENT $ENV{environment} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_PACKAGE AND DEFINED ENV{package})#to manage the call for non UNIX makefile generators
	set(TARGET_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_LICENSE AND DEFINED ENV{license})#to manage the call for non UNIX makefile generators
	set(TARGET_LICENSE $ENV{license} CACHE INTERNAL "" FORCE)
endif()

#perfom the command
if(TARGET_ENVIRONMENT)
	if(TARGET_ENVIRONMENT STREQUAL "all")#listing all frameworks
		file(GLOB all_env RELATIVE ${WORKSPACE_DIR}/cmake/references
					"${WORKSPACE_DIR}/cmake/references/ReferEnvironment*")
		message("[PID] Available environments:")
		foreach(ref_to_env IN LISTS all_env)
			string(REGEX REPLACE "ReferEnvironment([^.]+)\\.cmake" "\\1" env_name ${ref_to_env})
			list(APPEND to_list ${env_name})
		endforeach()
		file(GLOB all_env RELATIVE ${WORKSPACE_DIR}/environments/
				"${WORKSPACE_DIR}/environments/*")

		list(REMOVE_ITEM all_env ".gitignore")
		list(APPEND to_list ${all_env})
		if(to_list)
			list(REMOVE_DUPLICATES to_list)
		endif()
		foreach(env IN LISTS to_list)
			message("- ${env}")
		endforeach()
	else() # getting info about a given environment : general description and categories it defines
		include(ReferEnvironment${TARGET_ENVIRONMENT} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
		if(REQUIRED_STATUS STREQUAL NOTFOUND)
			message("[PID] ERROR : Environment name ${TARGET_ENVIRONMENT} does not refer to any known environment in the workspace")
		else()
			print_Environment_Info(${TARGET_ENVIRONMENT})
		endif()
	endif()

elseif(TARGET_FRAMEWORK)
	if(TARGET_FRAMEWORK STREQUAL "all")#listing all frameworks
		if(FRAMEWORKS_CATEGORIES)
			message("FRAMEWORKS: ")
			foreach(framework IN LISTS FRAMEWORKS_CATEGORIES)
				message("- ${framework}")
			endforeach()
		else()
			message("[PID] WARNING : no framework defined in your workspace.")
		endif()
	else() # getting info about a given framework : general description and categories it defines
		include(ReferFramework${TARGET_FRAMEWORK} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
		if(REQUIRED_STATUS STREQUAL NOTFOUND)
			message("[PID] ERROR : Framework name ${TARGET_FRAMEWORK} does not refer to any known framework in the workspace")
		else()
			print_Framework_Info(${TARGET_FRAMEWORK})
			print_Framework_Categories(${TARGET_FRAMEWORK}) #getting info about a framework
		endif()
	endif()
elseif(TARGET_PACKAGE)
	if(TARGET_PACKAGE STREQUAL "all")#listing all packages ordered by category
		message("CATEGORIES:") # printing the structure of categories and packages they belong to
		foreach(root_cat IN LISTS ROOT_CATEGORIES)
			print_Category("" ${root_cat} 0)
		endforeach()
	else()#searching for categories a package belongs to
		set(EXTERNAL FALSE)
		include(Refer${TARGET_PACKAGE} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
		if(REQUIRED_STATUS STREQUAL NOTFOUND)

			include(ReferExternal${TARGET_PACKAGE} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
			if(REQUIRED_STATUS STREQUAL NOTFOUND)
				message("[PID] ERROR : Package name ${TARGET_PACKAGE} does not refer to any known package in the workspace")
				return()
			endif()
			set(EXTERNAL TRUE)
		endif()
		if(EXTERNAL)
			print_External_Package_Info(${TARGET_PACKAGE})
		else()
			print_Package_Info(${TARGET_PACKAGE})
		endif()
		find_In_Categories(${TARGET_PACKAGE}) # printing the categories the package belongs to
	endif()

elseif(TARGET_LICENSE)

	if(TARGET_LICENSE STREQUAL "all")#listing all packages ordered by category
		print_Available_Licenses()
	else()
		include(License${TARGET_LICENSE} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
		if(REQUIRED_STATUS STREQUAL NOTFOUND)
			message("[PID] ERROR : license name ${TARGET_LICENSE} does not refer to any known license in the workspace.")
			return()
		endif()
		print_License_Info(${TARGET_LICENSE})
	endif()

else() #no argument passed, printing general information about the workspace
	include(${WORKSPACE_DIR}/pid/PID_version.cmake)
	message("[PID] INFO : current workspace version is ${PID_WORKSPACE_VERSION}.")
endif()
