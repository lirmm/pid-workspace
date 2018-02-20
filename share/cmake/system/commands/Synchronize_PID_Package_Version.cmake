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
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration


if(NOT EXISTS ${WORKSPACE_DIR}/pid/PID_version.cmake)#if workspace has not been built (or build files deleted), then build it to get the version
	execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR} WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
endif()
include(${WORKSPACE_DIR}/pid/PID_version.cmake) # get the current workspace version
set(PATH_TO_PACKAGE ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
if(	EXISTS ${PATH_TO_PACKAGE}/share/cmake/${TARGET_PACKAGE}_PID_Version.cmake)# get the workspace version with wich the package has been built
	#The file already resides in package shared files
	include(${PATH_TO_PACKAGE}/share/cmake/${TARGET_PACKAGE}_PID_Version.cmake)
	if(${PID_WORKSPACE_VERSION} LESS ${${TARGET_PACKAGE}_PID_VERSION})#workspace need to be updated
		update_Workspace_Repository("origin")
		execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR} WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
		include(${WORKSPACE_DIR}/pid/PID_version.cmake) # get the current workspace version AGAIN (most up to date version)
		if(${PID_WORKSPACE_VERSION} LESS ${${TARGET_PACKAGE}_PID_VERSION})#still less => impossible
			message("[PID] INFO : PID version ${${TARGET_PACKAGE}_PID_VERSION} is corrupted for package ${TARGET_PACKAGE} ... regenerating version according to most up to date workspace.")
			set(${TARGET_PACKAGE}_PID_VERSION ${PID_WORKSPACE_VERSION} CACHE INTERNAL "")
			file(WRITE ${PATH_TO_PACKAGE}/share/cmake/${TARGET_PACKAGE}_PID_Version.cmake "set(${TARGET_PACKAGE}_PID_VERSION ${${TARGET_PACKAGE}_PID_VERSION} CACHE INTERNAL \"\")")#save the PID version with which the package has been built
		endif()
	elseif(${PID_WORKSPACE_VERSION} GREATER ${${TARGET_PACKAGE}_PID_VERSION})
		#here we need to synchronize the versions
		set(${TARGET_PACKAGE}_PID_VERSION ${PID_WORKSPACE_VERSION} CACHE INTERNAL "")
		file(WRITE ${PATH_TO_PACKAGE}/share/cmake/${TARGET_PACKAGE}_PID_Version.cmake "set(${TARGET_PACKAGE}_PID_VERSION ${${TARGET_PACKAGE}_PID_VERSION} CACHE INTERNAL \"\")")#save the PID version with which the package has been built
		message("[PID] INFO : new PID system version for package ${TARGET_PACKAGE} is: ${${TARGET_PACKAGE}_PID_VERSION}.")
	endif()
else()
	set(${TARGET_PACKAGE}_PID_VERSION ${PID_WORKSPACE_VERSION})#if no version defined yet then set it to the current workspace one
	file(WRITE ${PATH_TO_PACKAGE}/share/cmake/${TARGET_PACKAGE}_PID_Version.cmake "set(${TARGET_PACKAGE}_PID_VERSION ${${TARGET_PACKAGE}_PID_VERSION} CACHE INTERNAL \"\")")#save the PID version with which the package has been built
	message("[PID] INFO : PID system version set for package ${TARGET_PACKAGE}: ${${TARGET_PACKAGE}_PID_VERSION}.")
endif()
