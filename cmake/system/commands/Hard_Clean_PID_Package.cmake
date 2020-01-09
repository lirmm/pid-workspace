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

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake/system/commands)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration

#manage usage of environment variables
if(NOT TARGET_PACKAGE AND DEFINED ENV{package})
  set(TARGET_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()

if(NOT RECONFIGURE AND DEFINED ENV{configure})
  set(RECONFIGURE $ENV{configure} CACHE INTERNAL "" FORCE)
endif()

if(TARGET_PACKAGE)
  if(TARGET_PACKAGE STREQUAL all)
    list_All_Source_Packages_In_Workspace(ALL_SOURCE_PACKAGES)
    list_All_Wrappers_In_Workspace(ALL_EXTERNAL_WRAPPERS)
    if(ALL_EXTERNAL_WRAPPERS)
      foreach(sub IN LISTS ALL_EXTERNAL_WRAPPERS)
        hard_Clean_Package(${sub})
      endforeach()
    endif()
    if(ALL_SOURCE_PACKAGES)
      foreach(sub IN LISTS ALL_SOURCE_PACKAGES)
        hard_Clean_Package(${sub})
      endforeach()
    endif()
    if(RECONFIGURE STREQUAL "true" OR RECONFIGURE STREQUAL "TRUE" OR RECONFIGURE STREQUAL "ON")
      foreach(sub IN LISTS ALL_EXTERNAL_WRAPPERS)
        reconfigure_Wrapper_Build(${sub})
      endforeach()
      foreach(sub IN LISTS ALL_SOURCE_PACKAGES)
        reconfigure_Package_Build(${sub})
      endforeach()
    endif()
    message("[PID] INFO : all packages have been hard cleaned.")
  elseif(EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
    hard_Clean_Package(${TARGET_PACKAGE})
    if(RECONFIGURE STREQUAL "true" OR RECONFIGURE STREQUAL "TRUE" OR RECONFIGURE STREQUAL "ON")
      reconfigure_Package_Build(${TARGET_PACKAGE})
    endif()
    message("[PID] INFO : the package ${TARGET_PACKAGE} has been hard cleaned.")
  else()
    message("[PID] ERROR : the name ${TARGET_PACKAGE} does not refer to any known package in the workspace.")
  endif()
else()
	message("[PID] ERROR : you must specify the name of the package to hard clean using package=<name of package> argument or use all to target all packages")
endif()
