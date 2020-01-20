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
include(CMakeParseArguments)
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

#################################################################################################
############################ Contribution_Spaces global management ##############################
#################################################################################################

function(update_Contribution_Spaces)
  check_Contribution_Spaces_Updated_In_Current_Process(ALREADY_UPDATED)
  if(NOT ALREADY_UPDATED)
    foreach(contrib IN LISTS CONTRIBUTION_SPACES)
      update_Contribution_Space_Repository(${contrib})
    endforeach()
    set_Contribution_Spaces_Updated_In_Current_Process()
  endif()
endfunction(update_Contribution_Spaces)

#Note: use a macro to stay in same scope as caller
macro(configure_Contribution_Space_CMake_Path contribution_space)
  set(path_to_cs ${WORKSPACE_DIR}/contributions/${contribution_space})
  if(EXISTS ${path_to_cs})
    if(EXISTS ${path_to_cs}/references)
      list(APPEND CMAKE_MODULE_PATH ${path_to_cs}/references)
      append_Unique_In_Cache(PID_WORKSPACE_MODULES_PATH ${path_to_cs}/references)
    endif()
    if(EXISTS ${path_to_cs}/finds)
      list(APPEND CMAKE_MODULE_PATH ${path_to_cs}/finds)
      append_Unique_In_Cache(PID_WORKSPACE_MODULES_PATH ${path_to_cs}/finds)
    endif()
  endif()
endmacro(configure_Contribution_Space_CMake_Path)

macro(configure_Contribution_Spaces)
  set(PID_WORKSPACE_MODULES_PATH CACHE INTERNAL "")
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

function(get_Path_To_All_Deployment_Unit_References_Publishing_Contribution_Spaces PUBLISHING_CONTRIB_SPACES deployment_unit)
  set(list_of_spaces)
  if(TARGET_CONTRIBUTION_SPACE)
    list(APPEND list_of_spaces ${WORKSPACE_DIR}/contributions/${TARGET_CONTRIBUTION_SPACE})
  endif()
  foreach(cs IN LISTS CONTRIBUTION_SPACES)
    get_All_Matching_Contributions(LICENSE REFERENCE FIND FORMAT CONFIGURATION ${cs} ${deployment_unit})
    if(REFERENCE OR FIND)
      list(APPEND list_of_spaces ${WORKSPACE_DIR}/contributions/${cs})
    endif()
  endforeach()
  if(list_of_spaces)
    list(REMOVE_DUPLICATES list_of_spaces)
  else()
    list(GET CONTRIBUTION_SPACES 0 space)
    set(list_of_spaces ${space})
  endif()
  set(${PUBLISHING_CONTRIB_SPACES} ${list_of_spaces} PARENT_SCOPE)
endfunction(get_Path_To_All_Deployment_Unit_References_Publishing_Contribution_Spaces)

function(set_Cache_Entry_For_Default_Contribution_Space)
  set(TARGET_CONTRIBUTION_SPACE "" CACHE STRING "Contribution space used for publishing. Possible values are: ${CONTRIBUTION_SPACES} (first is default)")
  if(TARGET_CONTRIBUTION_SPACE)
    list(FIND CONTRIBUTION_SPACES "${TARGET_CONTRIBUTION_SPACE}" INDEX)
    if(INDEX EQUAL -1)#not found => not a good value
      #reset cache variable value
      set(TARGET_CONTRIBUTION_SPACE CACHE STRING "Contribution space used for publishing. Possible values are: ${CONTRIBUTION_SPACES} (first is default)" FORCE)
    endif()
  endif()
endfunction(set_Cache_Entry_For_Default_Contribution_Space)

function(add_Contribution_Space name update publish)
  append_Unique_In_Cache(CONTRIBUTION_SPACES ${name})#simply add the only update contribution space
  set(CONTRIBUTION_SPACE_${name}_UPDATE_REMOTE ${update} CACHE INTERNAL "")
  if(publish)
    set(CONTRIBUTION_SPACE_${name}_PUBLISH_REMOTE ${publish} CACHE INTERNAL "")
  else()#no defined publish CS so publish directly in official
    set(CONTRIBUTION_SPACE_${name}_PUBLISH_REMOTE ${update} CACHE INTERNAL "")
  endif()
endfunction(add_Contribution_Space)

function(deploy_Contribution_Space DEPLOYED name update publish)
  set(${DEPLOYED} FALSE PARENT_SCOPE)
  clone_Contribution_Space_Repository(CLONED ${publish})
  if(NOT CLONED)
    return()
  endif()
  #rename cloned repository folder when necessary
  get_Repository_Name(repository_name ${publish})
  if(EXISTS ${WORKSPACE_DIR}/contributions/${repository_name}
    AND NOT repository_name STREQUAL name)
    file(RENAME ${WORKSPACE_DIR}/contributions/${repository_name} ${WORKSPACE_DIR}/contributions/${name})
  endif()
  #finally set the update address
  configure_Remote(${WORKSPACE_DIR}/contributions/${name} origin ${update} ${publish})
  set(${DEPLOYED} TRUE PARENT_SCOPE)
endfunction(deploy_Contribution_Space)

function(reset_Contribution_Spaces)
  set(path_to_description_file ${WORKSPACE_DIR}/contributions/contribution_spaces_list.cmake)
  set(official_cs_name "pid")
  set(official_cs_update_remote "https://gite.lirmm.fr/pid/pid-contributions.git")
  set(official_cs_publish_remote "git@gite.lirmm.fr:pid/pid-contributions.git")
  #situations to deal with:
  #- empty contributions folder
  #- missing contributions management file

  read_Contribution_Spaces_Description_File(FILE_EXISTS)
  if(NOT FILE_EXISTS)# this is first configuration run of the workspace, or file has been removed by user to explicitly reset current configuration
      if(NOT CONTRIBUTION_SPACES)#case at first configuration time just after a clone or a clean (rm -Rf *) of the pid folder
        add_Contribution_Space(${official_cs_name} ${official_cs_update_remote} ${official_cs_publish_remote})# pid official CS is the default one and must be present
      endif()
  endif()#otherwise CS related cache variables have been reset with their value coming from the description file
  #from here the cache variables are set so we need to align contributions folder content according to their values
  foreach(cs IN LISTS CONTRIBUTION_SPACES)
    if(EXISTS ${WORKSPACE_DIR}/contributions/${cs})
      configure_Remote(${WORKSPACE_DIR}/contributions/${cs} origin ${CONTRIBUTION_SPACE_${cs}_UPDATE_REMOTE} ${CONTRIBUTION_SPACE_${cs}_PUBLISH_REMOTE})
    else()
      deploy_Contribution_Space(IS_SUCCESS ${cs} ${CONTRIBUTION_SPACE_${cs}_UPDATE_REMOTE} ${CONTRIBUTION_SPACE_${cs}_PUBLISH_REMOTE})
      if(NOT IS_SUCCESS)
        message(FATAL_ERROR "[PID] CRITICAL ERROR : cannot deploy contribution space ${cs}, probably due to bad address (${CONTRIBUTION_SPACE_${cs}_PUBLISH_REMOTE}) or connection problems.")
      endif()
    endif()
  endforeach()
  #manage removal of contribution spaces
  file(GLOB all_installed_cs RELATIVE ${WORKSPACE_DIR}/contributions ${WORKSPACE_DIR}/contributions/*)
  foreach(cs IN LISTS all_installed_cs)
    if(IS_DIRECTORY ${WORKSPACE_DIR}/contributions/${cs})#ignore files like .gitignore and cs list file
      list(FIND CONTRIBUTION_SPACES ${cs} INDEX)
      if(INDEX EQUAL -1)#the corresponding CS is not in list of contribution spaces (is has been removed)
        file(REMOVE_RECURSE ${WORKSPACE_DIR}/contributions/${cs})
      endif()
    endif()
  endforeach()
  # now write the configuration file to memorize choices for next configuration (and for user editing)
  write_Contribution_Spaces_Description_File()
  # configure workspace (set CMAKE_MODULE_PATH adequately)
  configure_Contribution_Spaces()
endfunction(reset_Contribution_Spaces)

function(PID_Contribution_Space)
  set(oneValueArgs NAME UPDATE PUBLISH)
  cmake_parse_arguments(PID_CONTRIBUTION_SPACE "" "${oneValueArgs}" "" ${ARGN} )

  if(NOT PID_CONTRIBUTION_SPACE_NAME)
    message(FATAL_ERROR "[PID] CRITICAL ERROR: in PID_Contribution_Space, NAME of the constribution space must be defined.")
    return()
  endif()
  if(NOT PID_CONTRIBUTION_SPACE_UPDATE)
    message(FATAL_ERROR "[PID] CRITICAL ERROR: in PID_Contribution_Space, UPDATE remote of the constribution space must be defined.")
    return()
  endif()
  add_Contribution_Space(${PID_CONTRIBUTION_SPACE_NAME} ${PID_CONTRIBUTION_SPACE_UPDATE} "${PID_CONTRIBUTION_SPACE_PUBLISH}")
endfunction(PID_Contribution_Space)

function(reset_Contribution_Spaces_Variables)
  foreach(contrib_space IN LISTS CONTRIBUTION_SPACES)
    set(CONTRIBUTION_SPACE_${contrib_space}_UPDATE_REMOTE CACHE INTERNAL "")
    set(CONTRIBUTION_SPACE_${contrib_space}_PUBLISH_REMOTE CACHE INTERNAL "")
  endforeach()
  set(CONTRIBUTION_SPACES CACHE INTERNAL "")
endfunction(reset_Contribution_Spaces_Variables)

function(read_Contribution_Spaces_Description_File READ_SUCCESS)
  set(target_file_path ${WORKSPACE_DIR}/contributions/contribution_spaces_list.cmake)
  if(EXISTS ${target_file_path})#if file exists it means there is a description
    reset_Contribution_Spaces_Variables()#reset already existing description
    include(${target_file_path})
    set(${READ_SUCCESS} TRUE PARENT_SCOPE)
    return()
  endif()
  set(${READ_SUCCESS} FALSE PARENT_SCOPE)
endfunction(read_Contribution_Spaces_Description_File)

function(write_Contribution_Spaces_Description_File)
  set(target_file_path ${WORKSPACE_DIR}/contributions/contribution_spaces_list.cmake)
  file(WRITE ${target_file_path} "")#reset file content
  #contribution spaces list is ordered from highest to lowest priority
  foreach(contrib_space IN LISTS CONTRIBUTION_SPACES)
    if(CONTRIBUTION_SPACE_${contrib_space}_PUBLISH_REMOTE)
      set(TO_WRITE "PID_Contribution_Space(NAME ${contrib_space} UPDATE ${CONTRIBUTION_SPACE_${contrib_space}_UPDATE_REMOTE} PUBLISH ${CONTRIBUTION_SPACE_${contrib_space}_PUBLISH_REMOTE})")
    else()
      set(TO_WRITE "PID_Contribution_Space(NAME ${contrib_space} UPDATE ${CONTRIBUTION_SPACE_${contrib_space}_UPDATE_REMOTE})")
    endif()
    file(APPEND ${target_file_path} "${TO_WRITE}\n")
  endforeach()
endfunction(write_Contribution_Spaces_Description_File)

function(get_All_Matching_Contributions LICENSE REFERENCE FIND FORMAT CONFIGURATION cs name)
  get_Path_To_Contribution_Space(PATH_TO_CS ${cs})
  #checking licenses
  if(EXISTS ${PATH_TO_CS}/licenses/License${name}.cmake)
    set(${LICENSE} License${name}.cmake PARENT_SCOPE)
  else()
    set(${LICENSE} PARENT_SCOPE)
  endif()
  #checking formats
  if(EXISTS ${PATH_TO_CS}/formats/.clang-format.${name})
    set(${FORMAT} .clang-format.${name} PARENT_SCOPE)
  else()
    set(${FORMAT} PARENT_SCOPE)
  endif()
  #checking configurations
  if(EXISTS ${PATH_TO_CS}/configurations/${name} AND IS_DIRECTORY ${PATH_TO_CS}/configurations/${name})
    set(${CONFIGURATION} ${name} PARENT_SCOPE)
  else()
    set(${CONFIGURATION} PARENT_SCOPE)
  endif()
  #checking find files
  if(EXISTS ${PATH_TO_CS}/finds/Find${name}.cmake)
    set(${FIND} Find${name}.cmake PARENT_SCOPE)
  else()
    set(${FIND} PARENT_SCOPE)
  endif()
  #checking references
  if(EXISTS ${PATH_TO_CS}/references/Refer${name}.cmake)
    set(${REFERENCE} Refer${name}.cmake PARENT_SCOPE)
  elseif(EXISTS ${PATH_TO_CS}/references/ReferExternal${name}.cmake)
    set(${REFERENCE} ReferExternal${name}.cmake PARENT_SCOPE)
  elseif(EXISTS ${PATH_TO_CS}/references/ReferEnvironment${name}.cmake)
    set(${REFERENCE} ReferEnvironment${name}.cmake PARENT_SCOPE)
  elseif(EXISTS ${PATH_TO_CS}/references/ReferFramework${name}.cmake)
    set(${REFERENCE} ReferFramework${name}.cmake PARENT_SCOPE)
  else()
    set(${REFERENCE} PARENT_SCOPE)
  endif()
endfunction(get_All_Matching_Contributions)
