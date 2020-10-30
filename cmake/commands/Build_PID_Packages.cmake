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

SEPARATE_ARGUMENTS(TARGET_PACKAGES)

remove_Progress_File() #reset the build progress information (sanity action)
begin_Progress(workspace NEED_REMOVE)

#first check that commmand parameters are not passed as environment variables

if(NOT TARGET_PACKAGES AND DEFINED ENV{package})
	set(TARGET_PACKAGES $ENV{package} CACHE INTERNAL "" FORCE)
endif()

if(DEFINED ENV{package})
	unset(ENV{package})
endif()
#do the job
if(TARGET_PACKAGES AND NOT TARGET_PACKAGES STREQUAL "all")
	#clean them first
	set(LIST_OF_TARGETS)
	foreach(package IN LISTS TARGET_PACKAGES)
		if(EXISTS ${WORKSPACE_DIR}/packages/${package}/build) #rebuild all target packages
			list(APPEND LIST_OF_TARGETS ${package})
		else()
			message(FATAL_ERROR "[PID] CRITICAL_ERROR : target package ${package} does not exist in workspace")
		endif()
	endforeach()
else()#default is all
	list_All_Source_Packages_In_Workspace(ALL_PACKAGES)
	if(ALL_PACKAGES)
		set(LIST_OF_TARGETS ${ALL_PACKAGES})
	else()
		message("[PID] INFO : no package can be found in workspace. Build aborted.")
		return()
	endif()
endif()

#build the packages
set(FAILED_PACKAGES)
foreach(package IN LISTS LIST_OF_TARGETS)
	set(path_to_build ${WORKSPACE_DIR}/packages/${package}/build)
	if(NOT EXISTS ${path_to_build}/CMakeCache.txt)#package not already configured so do it
			execute_process(COMMAND ${CMAKE_COMMAND} -S ${WORKSPACE_DIR}/packages/${package}
											WORKING_DIRECTORY ${path_to_build})
	endif()
	#then build
	target_Options_Passed_Via_Environment(use_env)
	if(use_env)
		set(ENV{force} true)
		execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} build WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build RESULT_VARIABLE RES)
	else()
		execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} build force=true WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build RESULT_VARIABLE RES)
	endif()
	if(NOT RES STREQUAL 0)
		list(APPEND FAILED_PACKAGES ${package})
	endif()
	set(ENV{force})
endforeach()

## global management of the process
message("--------------------------------------------")
message("All packages built during this process : ${LIST_OF_TARGETS}")
message("Other Packages deployed/updated/checked during this process : ")
print_Managed_Packages()
finish_Progress(TRUE) #reset the build progress information
if(FAILED_PACKAGES)
	message(FATAL_ERROR "[PID] ERROR : the following packages could not be built: ${FAILED_PACKAGES}")
endif()
