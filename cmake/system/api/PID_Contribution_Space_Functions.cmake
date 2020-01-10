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

##########################################################################################
############################ Guard for optimization of configuration process #############
##########################################################################################
if(PID_CONTRIBUTION_SPACE_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_CONTRIBUTION_SPACE_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)


##########################################################################################
############################ format files resolution #####################################
##########################################################################################

function(get_Path_To_Format_File RESULT_PATH code_style)
  set(${RESULT_PATH} PARENT_SCOPE)
  foreach(contribution_space IN LISTS CONTRIBUTION_SPACES)#CONTRIBUTION_SPACES is supposed to be ordered from highest to lowest priority contribution spaces
    set(PATH_TO_PLUGIN ${WORKSPACE_DIR}/contributions/${contribution_space}/formats/.clang-format.${code_style})
    if(EXISTS ${PATH_TO_PLUGIN})
      set(${RESULT_PATH} ${PATH_TO_PLUGIN} PARENT_SCOPE)
      return()
    endif()
  endforeach()
endfunction(get_Path_To_Format_File)

##########################################################################################
############################ plugin files resolution #####################################
##########################################################################################

function(get_Path_To_Plugin_Dir RESULT_PATH plugin)
  set(${RESULT_PATH} PARENT_SCOPE)
  foreach(contribution_space IN LISTS CONTRIBUTION_SPACES)#CONTRIBUTION_SPACES is supposed to be ordered from highest to lowest priority contribution spaces
    set(PATH_TO_PLUGIN ${WORKSPACE_DIR}/contributions/${contribution_space}/plugins/${plugin})
    if(EXISTS ${PATH_TO_PLUGIN} AND IS_DIRECTORY ${PATH_TO_PLUGIN})
      set(${RESULT_PATH} ${PATH_TO_PLUGIN} PARENT_SCOPE)
      return()
    endif()
  endforeach()
endfunction(get_Path_To_Plugin_Dir)

function(get_Available_Plugins_For_Contribution_Space RES_LIST contribution_space)
  set(${RES_LIST} PARENT_SCOPE)
  set(PATH_TO_PLUGINS ${WORKSPACE_DIR}/contributions/${contribution_space}/plugins)
  if(EXISTS ${PATH_TO_PLUGINS} AND IS_DIRECTORY ${PATH_TO_PLUGINS})
    file(GLOB AVAILABLE_PLUGINS RELATIVE ${PATH_TO_PLUGINS} ${PATH_TO_PLUGINS}/*) #getting plugins container folders names
    set(${RES_LIST} ${AVAILABLE_PLUGINS} PARENT_SCOPE)
  endif()
endfunction(get_Available_Plugins_For_Contribution_Space)

function(get_All_Available_Plugins PLUGINS_LIST)
  set(FINAL_LIST)
  foreach(contrib IN LISTS CONTRIBUTION_SPACES)#CONTRIBUTION_SPACES is supposed to be ordered from highest to lowest priority contribution spaces
    get_Available_Plugins_For_Contribution_Space(RES_LIST ${contrib})
    list(APPEND FINAL_LIST ${RES_LIST})
  endforeach()
  if(FINAL_LIST)
    list(REMOVE_DUPLICATES FINAL_LIST)
  endif()
  set(${PLUGINS_LIST} ${FINAL_LIST} PARENT_SCOPE)
endfunction(get_All_Available_Plugins)


##########################################################################################
############################ configuration files resolution ##############################
##########################################################################################


function(get_Path_To_Configuration_Dir RESULT_PATH config)
  set(${RESULT_PATH} PARENT_SCOPE)
  foreach(contribution_space IN LISTS CONTRIBUTION_SPACES)#CONTRIBUTION_SPACES is supposed to be ordered from highest to lowest priority contribution spaces
    set(PATH_TO_CONFIG ${WORKSPACE_DIR}/contributions/${contribution_space}/contributions/${config})
    if(EXISTS ${PATH_TO_CONFIG} AND IS_DIRECTORY ${PATH_TO_CONFIG})
      set(${RESULT_PATH} ${PATH_TO_CONFIG} PARENT_SCOPE)
      return()
    endif()
  endforeach()
endfunction(get_Path_To_Configuration_Dir)

##########################################################################################
############################ license files resolution ####################################
##########################################################################################

function(get_Path_To_License_File RESULT_PATH license)
  set(${RESULT_PATH} PARENT_SCOPE)
  foreach(contribution_space IN LISTS CONTRIBUTION_SPACES)#CONTRIBUTION_SPACES is supposed to be ordered from highest to lowest priority contribution spaces
    set(PATH_TO_LICENSE_FILE ${WORKSPACE_DIR}/contributions/${contribution_space}/licenses/License${license}.cmake)
    if(EXISTS ${PATH_TO_LICENSE_FILE})
      set(${RESULT_PATH} ${PATH_TO_LICENSE_FILE} PARENT_SCOPE)
      return()
    endif()
  endforeach()
endfunction(get_Path_To_License_File)


function(get_Available_Licenses_For_Contribution_Space RES_LIST contribution_space)
  set(${RES_LIST} PARENT_SCOPE)
  set(PATH_TO_LICENSE ${WORKSPACE_DIR}/contributions/${contribution_space}/licenses)
  if(EXISTS ${PATH_TO_LICENSE} AND IS_DIRECTORY ${PATH_TO_LICENSE})
    file(GLOB AVAILABLE_LICENSES RELATIVE ${PATH_TO_LICENSE} ${PATH_TO_LICENSE}/*) #getting plugins container folders names
    set(${RES_LIST} ${AVAILABLE_LICENSES} PARENT_SCOPE)
  endif()
endfunction(get_Available_Licenses_For_Contribution_Space)

function(get_All_Available_Licenses LICENSES_LIST)
  set(FINAL_LIST)
  foreach(contrib IN LISTS CONTRIBUTION_SPACES)#CONTRIBUTION_SPACES is supposed to be ordered from highest to lowest priority contribution spaces
    get_Available_Licenses_For_Contribution_Space(RES_LIST ${contrib})
    list(APPEND FINAL_LIST ${RES_LIST})
  endforeach()
  if(FINAL_LIST)
    list(REMOVE_DUPLICATES FINAL_LIST)
  endif()
  set(${PLUGINS_LIST} ${FINAL_LIST} PARENT_SCOPE)
endfunction(get_All_Available_Licenses)


##########################################################################################
############################ Contribution_Spaces management ##############################
##########################################################################################

function(reset_Contribution_Spaces)
  file(GLOB contributions_spaces RELATIVE ${WORKSPACE_DIR} "${WORKSPACE_DIR}/contributions/*")
  set(CONTRIBUTION_SPACES ${contributions_spaces} CACHE INTERNAL "")#TODO maybe use another way to fill this variable to get priority on contribution spaces
  list(FIND CONTRIBUTION_SPACES "pid-contributions" INDEX)
  if(INDEX EQUAL -1)# pid-contributions does not exists while it is the default official contribution space
    message("[PID] WARNING : contribution space pid-contributions has been deleted, resintalling it from official repository")
    clone_Contribution_Space_Repository(CLONED https://gite.lirmm.fr/pid/pid-contributions.git)
    if(NOT CLONED)
      message(WARNING "[PID] CRITICAL ERROR : impossible to clone the missing official contribution space, please set its url by using the configure command.")
    endif()
  endif()
endfunction(reset_Contribution_Spaces)

#Note: use a macro to stay in same scope as caller
macro(configure_Contribution_Space_CMake_Path contribution_space)
  if(EXISTS ${WORKSPACE_DIR}/contributions/${contribution_space})
    if(EXISTS ${WORKSPACE_DIR}/contributions/${contribution_space}/references)
      list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/contributions/${contribution_space}/references)
    endif()
    if(EXISTS ${WORKSPACE_DIR}/contributions/${contribution_space}/find)
      list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/contributions/${contribution_space}/find)
    endif()
  endif()
endmacro(configure_Contribution_Space_CMake_Path)

macro(configure_Contribution_Spaces)
  # configure the CMAKE_MODULE_PATH according to the list of available contribution_spaces
  foreach(contrib IN LISTS CONTRIBUTION_SPACES)#CONTRIBUTION_SPACES is supposed to be ordered from highest to lowest priority contribution spaces
    configure_Contribution_Space_CMake_Path(${contrib})
  endforeach()
endmacro(configure_Contribution_Spaces)
