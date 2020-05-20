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
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)

load_Workspace_Info() #loading the current platform configuration

#manage arguments if they are passed as environmentvariables (for non UNIX makefile generators usage)
if(NOT FORCE_RELEASE_BUILD AND DEFINED ENV{force})
	set(FORCE_RELEASE_BUILD "$ENV{force}" CACHE INTERNAL "" FORCE)
endif()

if(	NOT FORCE_RELEASE_BUILD OR
		(NOT FORCE_RELEASE_BUILD STREQUAL "true" AND NOT FORCE_RELEASE_BUILD STREQUAL "TRUE" AND NOT FORCE_RELEASE_BUILD STREQUAL "ON")
	)
	get_Repository_Current_Branch(BRANCH_NAME ${GIT_REPOSITORY})
	if(NOT BRANCH_NAME OR BRANCH_NAME STREQUAL "master")
		message(FATAL_ERROR "[PID] ERROR : ${TARGET_PACKAGE} must be built on a development branch (integration or feature specific branch).")
	endif()
endif()
