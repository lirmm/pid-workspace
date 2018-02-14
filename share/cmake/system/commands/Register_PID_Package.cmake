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
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration

if(TARGET_PACKAGE AND (NOT TARGET_PACKAGE STREQUAL ""))
	if(EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE}
		AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
		register_PID_Package(${TARGET_PACKAGE})
	else()
		message("[PID] ERROR : the package ${TARGET_PACKAGE} cannot be found in the workspace (a folder with same name should be in ${WORKSPACE_DIR}/packages folder).")
	endif()
elseif(TARGET_FRAMEWORK AND (NOT TARGET_FRAMEWORK STREQUAL ""))
	if(EXISTS ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK}
		AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK})
		register_PID_Framework(${TARGET_FRAMEWORK})
	else()
		message("[PID] ERROR : the framework ${TARGET_FRAMEWORK} cannot be found in the workspace (a folder with same name should be in ${WORKSPACE_DIR}/sites/frameworks folder).")
	endif()
else()
	message("[PID] ERROR : you must specify the name of the package or framework to register using either package=<name of package> or framework=<name fo framework>")
endif()
