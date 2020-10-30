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

#################################################################################################
########### this is the script file to update a package #########################################
########### parameters :
########### TARGET_PACKAGE : name of the package to check
########### WORKSPACE_DIR : path to the root of the workspace
#################################################################################################


list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
load_Workspace_Info() #loading the current platform configuration

# needed to parse adequately CMAKe variables passed to the script
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PROGRAM_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_INCLUDE_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_LIBRARY_PATH)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_PREFIXES)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_SUFFIXES)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PREFIX_PATH)

## global management of the process
remove_Progress_File() #reset the build progress information (sanity action)
begin_Progress(workspace NEED_REMOVE)

#first check that commmand parameters are not passed as environment variables
if(NOT TARGET_PACKAGE AND DEFINED ENV{package})
	set(TARGET_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{package})
	unset(ENV{package})
endif()

if(NOT TARGET_FRAMEWORK AND DEFINED ENV{framework})
	set(TARGET_FRAMEWORK $ENV{framework} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{framework})
	unset(ENV{framework})
endif()

if(NOT TARGET_ENVIRONMENT AND DEFINED ENV{environment})
	set(TARGET_ENVIRONMENT $ENV{environment} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{environment})
	unset(ENV{environment})
endif()

if(NOT FORCE_SOURCE AND DEFINED ENV{force_source})
	set(FORCE_SOURCE $ENV{force_source} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{force_source})
	unset(ENV{force_source})
endif()

#perform actions of the commands
if(TARGET_PACKAGE)
	if(TARGET_PACKAGE STREQUAL "all")
		update_PID_All_Packages()
	else()
		list_Version_Subdirectories(version_dirs ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE})

		get_Package_Type(${TARGET_PACKAGE} PACK_TYPE)
		if(PACK_TYPE STREQUAL "NATIVE")
			if(EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE}
				 AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
				 save_Repository_Context(CURRENT_COMMIT SAVED_CONTENT ${TARGET_PACKAGE} FALSE)
				 update_Package_Repository_Versions(UPDATE_OK ${TARGET_PACKAGE})
				 restore_Repository_Context(${TARGET_PACKAGE} FALSE ${CURRENT_COMMIT} ${SAVED_CONTENT})
				 if(UPDATE_OK)
				 		deploy_Source_Native_Package(INSTALLED ${TARGET_PACKAGE} "${version_dirs}" FALSE)
				 else()
					 message("[PID] ERROR : nothing updated, abort")
				 endif()
			 endif()
		else()
			if(EXISTS ${WORKSPACE_DIR}/wrappers/${TARGET_PACKAGE}
			AND IS_DIRECTORY ${WORKSPACE_DIR}/wrappers/${TARGET_PACKAGE})
				save_Repository_Context(CURRENT_COMMIT SAVED_CONTENT ${TARGET_PACKAGE} TRUE)
				update_Wrapper_Repository(UPDATE_OK ${TARGET_PACKAGE})#update wrapper repository
				restore_Repository_Context(${TARGET_PACKAGE} TRUE ${CURRENT_COMMIT} ${SAVED_CONTENT})
				if(UPDATE_OK)
					deploy_Source_External_Package(INSTALLED ${TARGET_PACKAGE} "${version_dirs}")
				else()
					message("[PID] ERROR : nothing updated, abort")
				endif()
			 endif()
		endif()
		if(NOT INSTALLED)
			if(FORCE_SOURCE)
				if(PACK_TYPE STREQUAL "NATIVE")
					message(FATAL_ERROR "[PID] ERROR : no source repository exists in local workspace for native package ${TARGET_PACKAGE}.")
				else()
					message(FATAL_ERROR "[PID] ERROR : no wrapper repository exists in local workspace for external package ${TARGET_PACKAGE}.")
				endif()
				return()
			endif()
			load_Package_Binary_References(REFERENCES_OK ${TARGET_PACKAGE})
			if(NOT REFERENCES_OK)
				message(SEND_ERROR "[PID] ERROR : no binary reference exists in local workspace for package ${TARGET_PACKAGE}. Cannot update it ! Please contact the maintainer of package ${package} to have more information about this problem.")
			endif()
			if(PACK_TYPE STREQUAL "NATIVE")
				update_PID_Binary_Package(${TARGET_PACKAGE})
			else()
				update_PID_External_Package(${TARGET_PACKAGE})
			endif()
		endif()
	endif()
elseif(TARGET_FRAMEWORK)
	if(EXISTS ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK}
	   AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK})
		update_Framework_Repository(${TARGET_FRAMEWORK})
	else()
		message(SEND_ERROR "[PID] ERROR : No framework ${TARGET_FRAMEWORK} exist in workspace. Cannot update it !")
	endif()
elseif(TARGET_ENVIRONMENT)
	if(EXISTS ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT}
	   AND IS_DIRECTORY ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT})
		update_Environment_Repository(${TARGET_ENVIRONMENT})
	else()
		message(SEND_ERROR "[PID] ERROR : No environment ${TARGET_ENVIRONMENT} exist in workspace. Cannot update it !")
	endif()
else()
	message(SEND_ERROR "[PID] ERROR : You must specify the deployment unit to update using either 'package', 'wrapper', 'framework' or 'environment' argument. If you use the value 'all' instead of a deployment unit name, all deployment units of the corresponding type will be updated, either they are binary or source.")
endif()

## global management of the process
message("--------------------------------------------------------")
message("All packages updated and deployed during this process : ")
print_Managed_Packages()
finish_Progress(TRUE) #reset the build progress information
