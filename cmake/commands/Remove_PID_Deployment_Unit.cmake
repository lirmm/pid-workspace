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

#first check that commmand parameters are not passed as environment variables

if(NOT TARGET_ENVIRONMENT AND DEFINED ENV{environment})
	set(TARGET_ENVIRONMENT $ENV{environment} CACHE INTERNAL "" FORCE)
endif()
if(NOT TARGET_FRAMEWORK AND DEFINED ENV{framework})
	set(TARGET_FRAMEWORK $ENV{framework} CACHE INTERNAL "" FORCE)
endif()
if(NOT TARGET_PACKAGE AND DEFINED ENV{package})
	set(TARGET_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()

# perform actions of the command
if(TARGET_PACKAGE)
	if(EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE}
		AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
		remove_PID_Package(${TARGET_PACKAGE})
	elseif(EXISTS ${WORKSPACE_DIR}/wrappers/${TARGET_PACKAGE}
		AND IS_DIRECTORY ${WORKSPACE_DIR}/wrappers/${TARGET_PACKAGE})
		remove_PID_Wrapper(${TARGET_PACKAGE})
        else()
		message(FATAL_ERROR "[PID] ERROR : the package to be removed, named ${TARGET_PACKAGE}, does not lie in the workspace.")
	endif()
elseif(TARGET_FRAMEWORK)
	if(EXISTS ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK}
		AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK})
		remove_PID_Framework(${TARGET_FRAMEWORK})
	else()
		message(FATAL_ERROR "[PID] ERROR : the framework to be removed, named ${TARGET_FRAMEWORK}, does not lie in the workspace.")
	endif()
elseif(TARGET_ENVIRONMENT)
	if(EXISTS ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT}
	AND IS_DIRECTORY ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT})
		remove_PID_Environment(${TARGET_ENVIRONMENT})
	else()
		message(FATAL_ERROR "[PID] ERROR : the environment to be removed, named ${TARGET_ENVIRONMENT}, does not lie in the workspace.")
	endif()
else()
	message(FATAL_ERROR "[PID] ERROR : you must specify the name of the package to remove using package=<name of package> argument, or the name of the framework to remove by using framework=<name of framework> argument.")
endif()
