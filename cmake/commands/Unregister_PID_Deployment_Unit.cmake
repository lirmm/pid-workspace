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
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
load_Workspace_Info() #loading the current platform configuration

#manage arguments if they have been passed as environment variables
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

#NOTE: used to force the usage of a specific contribution space
if(NOT TARGET_CS AND DEFINED ENV{space})
	set(TARGET_CS $ENV{space} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{space})
	unset(ENV{space})
endif()
#perform the actions of the command
if(TARGET_PACKAGE)
  unregister_PID_Deployment_Unit(RESULT ${TARGET_PACKAGE} "${TARGET_CS}")
	if(NOT RESULT)
    if(TARGET_CS)
      message(FATAL_ERROR "[PID] ERROR : the package ${TARGET_PACKAGE} cannot be unregistered since it is not referenced in ${TARGET_CS} contribution space.")
    else()
	    message(FATAL_ERROR "[PID] ERROR : the package ${TARGET_PACKAGE} cannot be unregistered since it is not referenced in any contribution space.")
    endif()
  endif()
elseif(TARGET_FRAMEWORK)
  unregister_PID_Deployment_Unit(RESULT ${TARGET_FRAMEWORK} "${TARGET_CS}")
  if(TARGET_CS)
    message(FATAL_ERROR "[PID] ERROR : the framework ${TARGET_FRAMEWORK} cannot be unregistered since it is not referenced in ${TARGET_CS} contribution space.")
  else()
    message(FATAL_ERROR "[PID] ERROR : the framework ${TARGET_FRAMEWORK} cannot be unregistered since it is not referenced in any contribution space.")
  endif()
elseif(TARGET_ENVIRONMENT)
  unregister_PID_Deployment_Unit(RESULT ${TARGET_ENVIRONMENT} "${TARGET_CS}")
  if(TARGET_CS)
    message(FATAL_ERROR "[PID] ERROR : the environment ${TARGET_ENVIRONMENT} cannot be unregistered since it is not referenced in ${TARGET_CS} contribution space.")
  else()
    message(FATAL_ERROR "[PID] ERROR : the environment ${TARGET_ENVIRONMENT} cannot be unregistered since it is not referenced in any contribution space.")
  endif()
else()
	message(FATAL_ERROR "[PID] ERROR : you must specify the name of the package, environment or framework to unregister using either package=<name of package>, framework=<name of framework>, environment=<name of environment>")
endif()
