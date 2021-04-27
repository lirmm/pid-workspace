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

if(NOT TARGET_MAJOR AND DEFINED ENV{major} AND (NOT TARGET_MAJOR EQUAL 0))#to manage the call for non UNIX makefile generators
  set(TARGET_MAJOR "$ENV{major}" CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{major})
	unset(ENV{major})
endif()
if(NOT TARGET_MINOR AND DEFINED ENV{minor})#to manage the call for non UNIX makefile generators
  set(TARGET_MINOR $ENV{minor} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{minor})
	unset(ENV{minor})
endif()
if(NOT TARGET_PACKAGE AND DEFINED ENV{package})#to manage the call for non UNIX makefile generators
  set(TARGET_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{package})
	unset(ENV{package})
endif()
if(NOT TARGET_PACKAGE)
  message("[PID] CRITICAL ERROR : cannot deprecate no package given. Use package argument to define package to deprecate !")
  return()
endif()
if(NOT TARGET_MAJOR AND (NOT TARGET_MAJOR EQUAL 0)
   AND NOT TARGET_MINOR)
  message("[PID] CRITICAL ERROR : cannot deprecate versions of ${TARGET_PACKAGE} since no version given. Use major and/or minor argument to define which versions must be deprecated.")
  return()
else()#
  extract_All_Words("${TARGET_MAJOR}" "," major_versions_list)
  extract_All_Words("${TARGET_MINOR}" "," minor_versions_list)
endif()

# define path to target in workspace
if(NOT EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
  message(FATAL_ERROR "[PID] ERROR: cannot deprecate package ${TARGET_PACKAGE} because its repository cannot be find in workspace. Please first deploy it from source if you want to deprecate it: pid deploy package=${TARGET_PACKAGE} use_source=true.")
endif()

deprecate_PID_Package(DEPRECATED_VERSIONS ${TARGET_PACKAGE} "${major_versions_list}" "${minor_versions_list}")
if(NOT DEPRECATED_VERSIONS)
  message(FATAL_ERROR "[PID] Cannot deprecate versions, look at previous messages.")
else()
  fill_String_From_List(TO_PRINT_VERSIONS DEPRECATED_VERSIONS ",")
  message("[PID] INFO: versions ${TO_PRINT_VERSIONS} have been deprecated")
endif()
