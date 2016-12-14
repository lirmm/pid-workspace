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


include(${WORKSPACE_DIR}/pid/Workspace_Platforms_Info.cmake) #loading the current platform configuration

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)

SEPARATE_ARGUMENTS(TARGET_PACKAGES)

remove_Progress_File() #reset the build progress information (sanity action)
begin_Progress(workspace NEED_REMOVE)

if(TARGET_PACKAGES AND NOT TARGET_PACKAGES STREQUAL "all")
	#clean them first
	foreach(package IN ITEMS ${TARGET_PACKAGES})
		if(EXISTS ${WORKSPACE_DIR}/packages/${package}/build) #rebuild all target packages
			list(APPEND LIST_OF_TARGETS ${package})
		else()
			message("[PID] WARNING : target package ${package} does not exist in workspace")
		endif()
	endforeach()
else()#default is all
	list_All_Source_Packages_In_Workspace(ALL_PACKAGES)
	if(ALL_PACKAGES)
		set(LIST_OF_TARGETS ${ALL_PACKAGES})
	endif()
endif()


if(LIST_OF_TARGETS)
	# build them
	foreach(package IN ITEMS ${LIST_OF_TARGETS})
		execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package}/build ${CMAKE_MAKE_PROGRAM} build force=true)
	endforeach()
endif()


## global management of the process
message("--------------------------------------------")
message("All packages built during this process : ${LIST_OF_TARGETS}")
message("Other Packages deployed/updated/checked during this process : ")
print_Deployed_Packages()
finish_Progress(TRUE) #reset the build progress information
