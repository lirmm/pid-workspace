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
include(PID_Progress_Management_Functions NO_POLICY_SCOPE)

macro(set_Project_Module_Path_From_Workspace)
  if(PID_WORKSPACE_MODULES_PATH)
    list(APPEND CMAKE_MODULE_PATH ${PID_WORKSPACE_MODULES_PATH})
  endif()
endmacro(set_Project_Module_Path_From_Workspace)

##########################################################################################
############################ auxiliary functions #########################################
##########################################################################################

function(find_File_In_Contribution_Spaces RESULT_FILE_PATH RESULT_CONTRIBUTION_SPACE file_type file_name)
  set(${RESULT_FILE_PATH} PARENT_SCOPE)
  set(${RESULT_CONTRIBUTION_SPACE} PARENT_SCOPE)
  foreach(contribution_space IN LISTS CONTRIBUTION_SPACES)#CONTRIBUTION_SPACES is supposed to be ordered from highest to lowest priority contribution spaces
    set(PATH_TO_FILE ${WORKSPACE_DIR}/contributions/${contribution_space}/${file_type}/${file_name})
    if(EXISTS ${PATH_TO_FILE})
      set(${RESULT_FILE_PATH} ${PATH_TO_FILE} PARENT_SCOPE)
      set(${RESULT_CONTRIBUTION_SPACE} ${WORKSPACE_DIR}/contributions/${contribution_space} PARENT_SCOPE)
      break()
    endif()
  endforeach()
endfunction(find_File_In_Contribution_Spaces)

##########################################################################################
############################ format files resolution #####################################
##########################################################################################

function(get_Path_To_Format_File RESULT_PATH code_style)
  find_File_In_Contribution_Spaces(PATH CONTRIB formats ".clang-format.${code_style}")
  set(${RESULT_PATH} ${PATH} PARENT_SCOPE)
endfunction(get_Path_To_Format_File)

function(resolve_Path_To_Format_File RESULT_PATH code_style)
  set(${RESULT_PATH} PARENT_SCOPE)
  get_Path_To_Format_File(PATH_TO_FORMAT ${code_style})
  if(NOT PATH_TO_FORMAT)
    update_Contribution_Spaces(UPDATED)
    if(UPDATED)
      get_Path_To_Format_File(PATH_TO_FORMAT ${code_style})
    endif()
  endif()
  set(${RESULT_PATH} ${PATH_TO_FORMAT} PARENT_SCOPE)
endfunction(resolve_Path_To_Format_File)

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


function(resolve_Path_To_Plugin_Dir RESULT_PATH plugin)
  set(${RESULT_PATH} PARENT_SCOPE)
  get_Path_To_Plugin_Dir(PATH_TO_DIR ${plugin})
  if(NOT PATH_TO_DIR)
    update_Contribution_Spaces(UPDATED)
    if(UPDATED)
      get_Path_To_Plugin_Dir(PATH_TO_DIR ${plugin})
    endif()
  endif()
  set(${RESULT_PATH} ${PATH_TO_DIR} PARENT_SCOPE)
endfunction(resolve_Path_To_Plugin_Dir)

##########################################################################################
############################ configuration dirs resolution ###############################
##########################################################################################

function(get_Path_To_Configuration_Dir RESULT_PATH config)
  set(${RESULT_PATH} PARENT_SCOPE)
  foreach(contribution_space IN LISTS CONTRIBUTION_SPACES)#CONTRIBUTION_SPACES is supposed to be ordered from highest to lowest priority contribution spaces
    set(PATH_TO_CONFIG ${WORKSPACE_DIR}/contributions/${contribution_space}/configurations/${config})
    if(EXISTS ${PATH_TO_CONFIG} AND IS_DIRECTORY ${PATH_TO_CONFIG})
      set(${RESULT_PATH} ${PATH_TO_CONFIG} PARENT_SCOPE)
      return()
    endif()
  endforeach()
endfunction(get_Path_To_Configuration_Dir)

function(resolve_Path_To_Configuration_Dir RESULT_PATH config)
  set(${RESULT_PATH} PARENT_SCOPE)
  get_Path_To_Configuration_Dir(PATH_TO_DIR ${config})
  if(NOT PATH_TO_DIR)
    update_Contribution_Spaces(UPDATED)
    if(UPDATED)
      get_Path_To_Configuration_Dir(PATH_TO_DIR ${config})
    endif()
  endif()
  set(${RESULT_PATH} ${PATH_TO_DIR} PARENT_SCOPE)
endfunction(resolve_Path_To_Configuration_Dir)

##########################################################################################
############################ license files resolution ####################################
##########################################################################################

function(get_Path_To_License_File RESULT_PATH license)
  find_File_In_Contribution_Spaces(PATH CONTRIB licenses License${license}.cmake)
  set(${RESULT_PATH} ${PATH} PARENT_SCOPE)
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

#will work as a function since variables are in cache inside reference files
function(check_License_File PATH_TO_FILE license)
  get_Path_To_License_File(PATH_TO_LICENSE ${license})
  if(NOT PATH_TO_LICENSE)
    update_Contribution_Spaces(UPDATED)
    if(UPDATED)
      get_Path_To_License_File(PATH_TO_LICENSE ${license})
      if(PATH_TO_LICENSE)
        include (${PATH_TO_LICENSE}) #get the information about the framework
      endif()
    endif()
  endif()
  set(${PATH_TO_FILE} ${PATH_TO_LICENSE} PARENT_SCOPE)
endfunction(check_License_File)


##########################################################################################
############################ find files resolution #######################################
##########################################################################################

function(get_Path_To_Find_File RESULT_PATH deployment_unit)
  find_File_In_Contribution_Spaces(FIND_FILE_PATH CONTRIB finds Find${deployment_unit}.cmake)
  set(${RESULT_PATH} ${FIND_FILE_PATH} PARENT_SCOPE)
endfunction(get_Path_To_Find_File)

function(resolve_Path_To_Find_File RESULT_PATH deployment_unit)
  get_Path_To_Find_File(PATH_TO_FILE ${deployment_unit})
  if(NOT PATH_TO_FILE)
    update_Contribution_Spaces(UPDATED)
    if(UPDATED)
      get_Path_To_Find_File(PATH_TO_FILE ${deployment_unit})
    endif()
  endif()
  set(${RESULT_PATH} ${PATH_TO_FILE} PARENT_SCOPE)
endfunction(resolve_Path_To_Find_File)

macro(include_Find_File deployment_unit)
  resolve_Path_To_Find_File(PATH_TO_FILE ${deployment_unit})
  if(PATH_TO_FILE)
    include(${PATH_TO_FILE})
  endif()
  set(PATH_TO_FILE)
endmacro(include_Find_File)

##########################################################################################
############################ reference files resolution ##################################
##########################################################################################

function(get_Path_To_Package_Reference_File RESULT_PATH RESULT_CONTRIB_SPACE package)
  find_File_In_Contribution_Spaces(FIND_FILE_RESULT_PATH PACKAGE_CONTRIB_SPACE references Refer${package}.cmake)
  set(${RESULT_PATH} ${FIND_FILE_RESULT_PATH} PARENT_SCOPE)
  set(${RESULT_CONTRIB_SPACE} ${PACKAGE_CONTRIB_SPACE} PARENT_SCOPE)
endfunction(get_Path_To_Package_Reference_File)

function(get_Path_To_External_Reference_File RESULT_PATH RESULT_CONTRIB_SPACE package)
  find_File_In_Contribution_Spaces(FIND_FILE_RESULT_PATH PACKAGE_CONTRIB_SPACE references ReferExternal${package}.cmake)
  set(${RESULT_PATH} ${FIND_FILE_RESULT_PATH} PARENT_SCOPE)
  set(${RESULT_CONTRIB_SPACE} ${PACKAGE_CONTRIB_SPACE} PARENT_SCOPE)
endfunction(get_Path_To_External_Reference_File)

function(get_Path_To_Framework_Reference_File RESULT_PATH RESULT_CONTRIB_SPACE framework)
  find_File_In_Contribution_Spaces(FIND_FILE_RESULT_PATH PACKAGE_CONTRIB_SPACE references ReferFramework${framework}.cmake)
  set(${RESULT_PATH} ${FIND_FILE_RESULT_PATH} PARENT_SCOPE)
  set(${RESULT_CONTRIB_SPACE} ${PACKAGE_CONTRIB_SPACE} PARENT_SCOPE)
endfunction(get_Path_To_Framework_Reference_File)

function(get_Path_To_Environment_Reference_File RESULT_PATH RESULT_CONTRIB_SPACE environment)
  find_File_In_Contribution_Spaces(FIND_FILE_RESULT_PATH PACKAGE_CONTRIB_SPACE references ReferEnvironment${environment}.cmake)
  set(${RESULT_PATH} ${FIND_FILE_RESULT_PATH} PARENT_SCOPE)
  set(${RESULT_CONTRIB_SPACE} ${PACKAGE_CONTRIB_SPACE} PARENT_SCOPE)
endfunction(get_Path_To_Environment_Reference_File)

#will work as a function since variables are in cache inside reference files
function(include_Package_Reference_File PATH_TO_FILE package)
  get_Path_To_Package_Reference_File(PATH_TO_REF PATH_TO_CS ${package})
  if(PATH_TO_REF)
    include (${PATH_TO_REF}) #get the information about the framework
  else()
    update_Contribution_Spaces(UPDATED)
    if(UPDATED)
      get_Path_To_Package_Reference_File(PATH_TO_REF PATH_TO_CS ${package})
      if(PATH_TO_REF)
        include (${PATH_TO_REF}) #get the information about the framework
      endif()
    endif()
  endif()
  set(${PATH_TO_FILE} ${PATH_TO_REF} PARENT_SCOPE)
endfunction(include_Package_Reference_File)

#will work as a function since variables are in cache inside reference files
function(include_External_Reference_File PATH_TO_FILE package)
  get_Path_To_External_Reference_File(PATH_TO_REF PATH_TO_CS ${package})
  if(PATH_TO_REF)
    include (${PATH_TO_REF}) #get the information about the framework
  else()
    update_Contribution_Spaces(UPDATED)
    if(UPDATED)
      get_Path_To_External_Reference_File(PATH_TO_REF PATH_TO_CS ${package})
      if(PATH_TO_REF)
        include (${PATH_TO_REF}) #get the information about the framework
      endif()
    endif()
  endif()
  set(${PATH_TO_FILE} ${PATH_TO_REF} PARENT_SCOPE)
endfunction(include_External_Reference_File)

#will work as a function since variables are in cache inside reference files
function(include_Framework_Reference_File PATH_TO_FILE framework)
  get_Path_To_Framework_Reference_File(PATH_TO_REF PATH_TO_CS ${framework})
  if(PATH_TO_REF)
    include (${PATH_TO_REF}) #get the information about the framework
  else()
    update_Contribution_Spaces(UPDATED)
    if(UPDATED)
      get_Path_To_Framework_Reference_File(PATH_TO_REF PATH_TO_CS ${framework})
      if(PATH_TO_REF)
        include (${PATH_TO_REF}) #get the information about the framework
      endif()
    endif()
  endif()
  set(${PATH_TO_FILE} ${PATH_TO_REF} PARENT_SCOPE)
endfunction(include_Framework_Reference_File)

#will work as a function since variables are in cache inside reference files
function(include_Environment_Reference_File PATH_TO_FILE environment)
  get_Path_To_Environment_Reference_File(PATH_TO_REF PATH_TO_CS ${environment})
  if(PATH_TO_REF)
    include (${PATH_TO_REF}) #get the information about the framework
  else()
    update_Contribution_Spaces(UPDATED)
    if(UPDATED)
      get_Path_To_Environment_Reference_File(PATH_TO_REF PATH_TO_CS ${environment})
      if(PATH_TO_REF)
        include (${PATH_TO_REF}) #get the information about the framework
      endif()
    endif()
  endif()
  set(${PATH_TO_FILE} ${PATH_TO_REF} PARENT_SCOPE)
endfunction(include_Environment_Reference_File)

function(get_Available_References_For_Contribution_Space RES_LIST contribution_space prefix)
  set(${RES_LIST} PARENT_SCOPE)
  set(PATH_TO_REF ${WORKSPACE_DIR}/contributions/${contribution_space}/references)
  if(EXISTS ${PATH_TO_REF} AND IS_DIRECTORY ${PATH_TO_REF})
    file(GLOB AVAILABLE_REFS RELATIVE ${PATH_TO_REF} ${PATH_TO_REF}/Refer${prefix}*) #getting plugins container folders names
    set(${RES_LIST} ${AVAILABLE_REFS} PARENT_SCOPE)
  endif()
endfunction(get_Available_References_For_Contribution_Space)

function(get_All_Available_References REF_LIST prefix)
  set(FINAL_LIST)
  foreach(contrib IN LISTS CONTRIBUTION_SPACES)#CONTRIBUTION_SPACES is supposed to be ordered from highest to lowest priority contribution spaces
    get_Available_References_For_Contribution_Space(RES_LIST ${contrib} "${prefix}")
    list(APPEND FINAL_LIST ${RES_LIST})
  endforeach()
  if(FINAL_LIST)
    list(REMOVE_DUPLICATES FINAL_LIST)
  endif()
  set(${PLUGINS_LIST} ${FINAL_LIST} PARENT_SCOPE)
endfunction(get_All_Available_References)

##########################################################################################
############################ Contribution_Spaces management ##############################
##########################################################################################

function(update_Contribution_Spaces)
  check_Contribution_Spaces_Updated_In_Current_Process(ALREADY_UPDATED)
  if(NOT ALREADY_UPDATED)
    foreach(contrib IN LISTS CONTRIBUTION_SPACES)
      update_Contribution_Space_Repository(${contrib})
    endforeach()
    set_Contribution_Spaces_Updated_In_Current_Process()
  endif()
endfunction(update_Contribution_Spaces)

function(reset_Contribution_Spaces)
  set(default_official_contribution "pid-contributions")

  if(NOT CONTRIBUTION_SPACES)
    #case at first configuration time just after a clone or a clean (rm -Rf *) of the pid folder
    if(NOT EXISTS ${WORKSPACE_DIR}/contributions/${default_official_contribution})# pid-contributions does not exists while it is the default official contribution space
      clone_Contribution_Space_Repository(CLONED https://gite.lirmm.fr/pid/pid-contributions.git)
      if(NOT CLONED)
        message(WARNING "[PID] CRITICAL ERROR : impossible to clone the missing official contribution space, please set its url by using the configure command.")
        return()
      endif()
    endif()
    append_Unique_In_Cache(CONTRIBUTION_SPACES ${default_official_contribution})#simply add the only official contribution space
  else()
    set(TEMP_CONTRIBUTION_SPACES ${CONTRIBUTION_SPACES})#memorize the current priority order of contribution spaces
    set(CONTRIBUTION_SPACES CACHE INTERNAL "")#reset the cache variable
    #update the priority list of contribution spaces
    if(DEFINED CONTRIBUTION_PRIORITY)
      set(priority ${CONTRIBUTION_PRIORITY})
      unset(CONTRIBUTION_PRIORITY CACHE)
    else()
      set(priority 0)#highest priority by default
    endif()
    if(DEFINED ADD_CONTRIBUTION)
      list(INSERT TEMP_CONTRIBUTION_SPACES ${priority})
      unset(ADD_CONTRIBUTION CACHE)
    elseif(DEFINED SET_CONTRIBUTION)
      list(GET TEMP_CONTRIBUTION_SPACES ${SET_CONTRIBUTION} INDEX)
      if(NOT INDEX EQUAL priority)#change priority of the contribution
        list(REMOVE_ITEM TEMP_CONTRIBUTION_SPACES ${SET_CONTRIBUTION})#remove previous place in list
        math(EXPR priority "${priority}-1")
        list(INSERT TEMP_CONTRIBUTION_SPACES ${priority})#set the new priority
      endif()
    endif()
    # check if the default "pid-contributions" exists in workspace
    if(NOT EXISTS ${WORKSPACE_DIR}/contributions/${default_official_contribution})# pid-contributions does not exists while it is the default official contribution space
      clone_Contribution_Space_Repository(CLONED https://gite.lirmm.fr/pid/pid-contributions.git)
      if(NOT CLONED)
        message(WARNING "[PID] CRITICAL ERROR : impossible to clone the missing official contribution space, please set its url by using the configure command.")
      else()
        list(INSERT TEMP_CONTRIBUTION_SPACES -1)#insert the contribution with lowest priority
      endif()
    endif()

    #now building the final list by checking that everything is correct
    foreach(contrib IN LISTS TEMP_CONTRIBUTION_SPACES)#now adding to the cache variable the element in same order as in temporary variable
      if(EXISTS ${WORKSPACE_DIR}/contributions/${contrib} AND IS_DIRECTORY ${WORKSPACE_DIR}/contributions/${contrib})#avoid .gitignore or removed contribution spaces
        append_Unique_In_Cache(CONTRIBUTION_SPACES ${contrib})
      endif()
    endforeach()
  endif()
  configure_Contribution_Spaces()
endfunction(reset_Contribution_Spaces)

#Note: use a macro to stay in same scope as caller
macro(configure_Contribution_Space_CMake_Path contribution_space)
  set(TEMP_LIST_OF_PATH)
  if(EXISTS ${WORKSPACE_DIR}/contributions/${contribution_space})
    if(EXISTS ${WORKSPACE_DIR}/contributions/${contribution_space}/references)
      list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/contributions/${contribution_space}/references)
      list(APPEND TEMP_LIST_OF_PATH ${WORKSPACE_DIR}/contributions/${contribution_space}/references)
    endif()
    if(EXISTS ${WORKSPACE_DIR}/contributions/${contribution_space}/finds)
      list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/contributions/${contribution_space}/finds)
      list(APPEND TEMP_LIST_OF_PATH ${WORKSPACE_DIR}/contributions/${contribution_space}/finds)
    endif()
  endif()
  list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)
  list(REMOVE_DUPLICATES TEMP_LIST_OF_PATH)
  set(PID_WORKSPACE_MODULES_PATH ${TEMP_LIST_OF_PATH} CACHE INTERNAL "")
endmacro(configure_Contribution_Space_CMake_Path)

macro(configure_Contribution_Spaces)
  # configure the CMAKE_MODULE_PATH according to the list of available contribution_spaces
  foreach(contrib IN LISTS CONTRIBUTION_SPACES)#CONTRIBUTION_SPACES is supposed to be ordered from highest to lowest priority contribution spaces
    configure_Contribution_Space_CMake_Path(${contrib})
  endforeach()
endmacro(configure_Contribution_Spaces)

function(get_Path_To_Contribution_Space PATH_TO_DIR space)
  set(path ${WORKSPACE_DIR}/contributions/${space})
  if(EXISTS ${path} AND IS_DIRECTORY ${path})
    set(${PATH_TO_DIR} ${path} PARENT_SCOPE)
  else()
    set(${PATH_TO_DIR} PARENT_SCOPE)
  endif()
endfunction(get_Path_To_Contribution_Space)

function(get_Path_To_Default_Contribution_Space DEFAULT_CONTRIB_SPACE)
  if(PUBLISHING_IN_CONTRIBUTION_SPACE)
    set(${DEFAULT_CONTRIB_SPACE} ${WORKSPACE_DIR}/contributions/${PUBLISHING_IN_CONTRIBUTION_SPACE} PARENT_SCOPE)
  else()
    list(GET CONTRIBUTION_SPACES 0 space)
    set(${DEFAULT_CONTRIB_SPACE} ${WORKSPACE_DIR}/contributions/${space} PARENT_SCOPE)
  endif()
endfunction(get_Path_To_Default_Contribution_Space)

function(set_Default_Contribution_Space_For_Publication SET_OK space)
  list(FIND CONTRIBUTION_SPACES "${space}" INDEX)
  if(INDEX EQUAL -1)
    set(PUBLISHING_IN_CONTRIBUTION_SPACE CACHE INTERNAL "")#reset the previous value
    set(${SET_OK} FALSE PARENT_SCOPE)
  else()
    set(PUBLISHING_IN_CONTRIBUTION_SPACE ${space} CACHE INTERNAL "")
    set(${SET_OK} TRUE PARENT_SCOPE)
  endif()
endfunction(set_Default_Contribution_Space_For_Publication)

function(set_Cache_Entry_For_Default_Contribution_Space)
  set(TARGET_CONTRIBUTION_SPACE "" CACHE STRING "The contribution space to contribute to. Possible values are: ${CONTRIBUTION_SPACES} (first is default)")
  if(TARGET_CONTRIBUTION_SPACE)
    set_Default_Contribution_Space_For_Publication(RESULT_OK ${TARGET_CONTRIBUTION_SPACE})
    if(NOT RESULT_OK)#not a valid target contribution space
      #reset the cache variable
      set(TARGET_CONTRIBUTION_SPACE "" CACHE STRING "The contribution space to contribute to. Possible values are: ${ALL_SPACES} (first is default)" FORCE)
    endif()
  endif()
endfunction(set_Cache_Entry_For_Default_Contribution_Space)
