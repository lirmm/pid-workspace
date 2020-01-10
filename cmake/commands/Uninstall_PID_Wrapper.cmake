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

if(NOT TARGET_EXTERNAL_VERSION AND DEFINED ENV{version})#to manage the call for non UNIX makefile generators
  set(TARGET_EXTERNAL_VERSION $ENV{version} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_EXTERNAL_VERSION)
  message("[PID] CRITICAL ERROR : cannot uninstall a version since no version given. Use version argument to set it !")
  return()
endif()

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration


if(NOT EXISTS ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${TARGET_EXTERNAL_PACKAGE})
  message("[PID] ERROR : no external package wrapper ${TARGET_EXTERNAL_PACKAGE} installed in worskspace for platform ${CURRENT_PLATFORM}.")
  return()
endif()

if(TARGET_EXTERNAL_VERSION STREQUAL "all")
  #direclty remove the containing folder
  file(REMOVE_RECURSE ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${TARGET_EXTERNAL_PACKAGE})
  message("[PID] INFO : all versions of external package wrapper ${TARGET_EXTERNAL_PACKAGE} removed from worskspace for platform ${CURRENT_PLATFORM}.")
  return()
else() #remove a given version folder

  if(NOT EXISTS ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${TARGET_EXTERNAL_PACKAGE}/${TARGET_EXTERNAL_VERSION})
    message("[PID] ERROR : no version ${TARGET_EXTERNAL_VERSION} of external package wrapper ${TARGET_EXTERNAL_PACKAGE} installed in worskspace for platform ${CURRENT_PLATFORM}.")
    return()
  endif()
  file(REMOVE_RECURSE ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${TARGET_EXTERNAL_PACKAGE}/${TARGET_EXTERNAL_VERSION})
  message("[PID] INFO : version ${TARGET_EXTERNAL_VERSION} of external package wrapper ${TARGET_EXTERNAL_PACKAGE} removed from worskspace for platform ${CURRENT_PLATFORM}.")
  return()

endif()
