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
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration

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

#perform actions of the commands

if(TARGET_PACKAGE)
	if(TARGET_PACKAGE STREQUAL "all")
		update_PID_All_Packages()
	else()
		if(EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
			update_PID_Source_Package(${TARGET_PACKAGE})
		else()
			load_Package_Binary_References(REFERENCES_OK ${TARGET_PACKAGE})
			if(NOT REFERENCES_OK)
				message("[PID] ERROR : no binary reference exists for the package ${TARGET_PACKAGE}. Cannot update it ! Please contact the maintainer of package ${package} to have more information about this problem.")
			endif()
			# it may be a binary package
			update_PID_Binary_Package(${TARGET_PACKAGE})
		endif()
	endif()
else()
	message("[PID] ERROR : You must specify the name of the package to update using name= argument. If you use all as name, all packages will be updated, either they are binary or source.")
endif()

## global management of the process
message("--------------------------------------------------------")
message("All packages updated and deployed during this process : ")
print_Managed_Packages()
finish_Progress(TRUE) #reset the build progress information
