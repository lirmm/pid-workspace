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

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Project_Module_Path_From_Workspace| replace:: ``set_Project_Module_Path_From_Workspace``
#  .. _set_Project_Module_Path_From_Workspace:
#
#  set_Project_Module_Path_From_Workspace
#  --------------------------------------
#
#   .. command:: set_Project_Module_Path_From_Workspace()
#
#      Set the module path to target all currenlty used contribution spaces at workspace level
#
macro(set_Project_Module_Path_From_Workspace)
  if(PID_WORKSPACE_MODULES_PATH)
    list(APPEND CMAKE_MODULE_PATH ${PID_WORKSPACE_MODULES_PATH})
  endif()
endmacro(set_Project_Module_Path_From_Workspace)

##########################################################################################
############################ auxiliary functions #########################################
##########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_File_In_Contribution_Spaces| replace:: ``find_File_In_Contribution_Spaces``
#  .. _find_File_In_Contribution_Spaces:
#
#  find_File_In_Contribution_Spaces
#  --------------------------------
#
#   .. command:: find_File_In_Contribution_Spaces(RESULT_FILE_PATH RESULT_CONTRIBUTION_SPACE file_type file_name)
#
#      AUxiliary funciton to find a file or directory in the contribution space with highest priority and returns its path and the path to its contribution space
#
#      :file_type: type of the file (licenses, formats, plugins, references, finds)
#      :file_name: name of file or folder
#
#      :RESULT_FILE_PATH: output variable containing path to the file if found, empty otherwise.
#      :RESULT_CONTRIBUTION_SPACE: output variable containing path to the contribution space containing the file or folder if found, empty otherwise.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Path_To_Format_File| replace:: ``get_Path_To_Format_File``
#  .. _get_Path_To_Format_File:
#
#  get_Path_To_Format_File
#  -----------------------
#
#   .. command:: get_Path_To_Format_File(RESULT_PATH code_style)
#
#      get the path to a format file
#
#      :code_style: name of the code style defined by format
#
#      :RESULT_PATH: output variable containing path to the format file if found, empty otherwise.
#
function(get_Path_To_Format_File RESULT_PATH code_style)
  find_File_In_Contribution_Spaces(PATH CONTRIB formats ".clang-format.${code_style}")
  set(${RESULT_PATH} ${PATH} PARENT_SCOPE)
endfunction(get_Path_To_Format_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Path_To_Format_File| replace:: ``resolve_Path_To_Format_File``
#  .. _resolve_Path_To_Format_File:
#
#  resolve_Path_To_Format_File
#  ---------------------------
#
#   .. command:: resolve_Path_To_Format_File(RESULT_PATH code_style)
#
#      get the path to a format file, update contribution spaces if not found first time.
#
#      :code_style: name of the code style defined by format
#
#      :RESULT_PATH: output variable containing path to the format file if found, empty otherwise.
#
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
############################ license files resolution ####################################
##########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Path_To_License_File| replace:: ``get_Path_To_License_File``
#  .. _get_Path_To_License_File:
#
#  get_Path_To_License_File
#  ------------------------
#
#   .. command:: get_Path_To_License_File(RESULT_PATH license)
#
#      get the path to the a license file.
#
#      :license: name of the license
#
#      :RESULT_PATH: output variable containing path to the license file if found, empty otherwise.
#
function(get_Path_To_License_File RESULT_PATH license)
  find_File_In_Contribution_Spaces(PATH CONTRIB licenses License${license}.cmake)
  set(${RESULT_PATH} ${PATH} PARENT_SCOPE)
endfunction(get_Path_To_License_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Available_Licenses_For_Contribution_Space| replace:: ``get_Available_Licenses_For_Contribution_Space``
#  .. _get_Available_Licenses_For_Contribution_Space:
#
#  get_Available_Licenses_For_Contribution_Space
#  ---------------------------------------------
#
#   .. command:: get_Available_Licenses_For_Contribution_Space(RES_LIST contribution_space)
#
#      get all available licenses referenecd in a given contribution space
#
#      :contribution_space: name of the contribution space
#
#      :RES_LIST: output variable containing the list of licenses provided by contribution_space.
#
function(get_Available_Licenses_For_Contribution_Space RES_LIST contribution_space)
  set(${RES_LIST} PARENT_SCOPE)
  set(PATH_TO_LICENSE ${WORKSPACE_DIR}/contributions/${contribution_space}/licenses)
  if(EXISTS ${PATH_TO_LICENSE} AND IS_DIRECTORY ${PATH_TO_LICENSE})
    file(GLOB AVAILABLE_LICENSES RELATIVE ${PATH_TO_LICENSE} ${PATH_TO_LICENSE}/*) #getting plugins container folders names
    set(${RES_LIST} ${AVAILABLE_LICENSES} PARENT_SCOPE)
  endif()
endfunction(get_Available_Licenses_For_Contribution_Space)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_All_Available_Licenses| replace:: ``get_All_Available_Licenses``
#  .. _get_All_Available_Licenses:
#
#  get_All_Available_Licenses
#  --------------------------
#
#   .. command:: get_All_Available_Licenses(LICENSES_LIST)
#
#      get all available licenses from all contribution spaces in use.
#
#      :LICENSES_LIST: output variable containing the list of usable licenses.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_License_File| replace:: ``resolve_License_File``
#  .. _resolve_License_File:
#
#  resolve_License_File
#  ------------------
#
#   .. command:: resolve_License_File(PATH_TO_FILE license)
#
#      get the path to a license file, update contribution spaces if not found first time.
#
#      :license: name of the license.
#
#      :RESULT_PATH: output variable containing path to the license file if found, empty otherwise.
function(resolve_License_File PATH_TO_FILE license)
  get_Path_To_License_File(PATH_TO_LICENSE ${license})
  if(NOT PATH_TO_LICENSE)
    update_Contribution_Spaces(UPDATED)
    if(UPDATED)
      get_Path_To_License_File(PATH_TO_LICENSE ${license})
    endif()
  endif()
  set(${PATH_TO_FILE} ${PATH_TO_LICENSE} PARENT_SCOPE)
endfunction(resolve_License_File)

##########################################################################################
############################ find files resolution #######################################
##########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Path_To_Find_File| replace:: ``get_Path_To_Find_File``
#  .. _get_Path_To_Find_File:
#
#  get_Path_To_Find_File
#  ---------------------
#
#   .. command:: get_Path_To_Find_File(RESULT_PATH deployment_unit)
#
#      get the path to the a find file for a given deployment unit.
#
#      :deployment_unit: name of the deployment unit (e.g. name of the package).
#
#      :RESULT_PATH: output variable containing path to the find file if found, empty otherwise.
#
function(get_Path_To_Find_File RESULT_PATH deployment_unit)
  find_File_In_Contribution_Spaces(FIND_FILE_PATH CONTRIB finds Find${deployment_unit}.cmake)
  set(${RESULT_PATH} ${FIND_FILE_PATH} PARENT_SCOPE)
endfunction(get_Path_To_Find_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Path_To_Find_File| replace:: ``resolve_Path_To_Find_File``
#  .. _resolve_Path_To_Find_File:
#
#  resolve_Path_To_Find_File
#  -------------------------
#
#   .. command:: resolve_Path_To_Find_File(RESULT_PATH deployment_unit)
#
#      get the path to a find file for a given deployment unit, update contribution spaces if not found first time.
#
#      :deployment_unit: name of the deployment unit (e.g. name of the package).
#
#      :RESULT_PATH: output variable containing path to deployment_unit's find file if found, empty otherwise.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |include_Find_File| replace:: ``include_Find_File``
#  .. _include_Find_File:
#
#  include_Find_File
#  -----------------
#
#   .. command:: include_Find_File(RESULT_PATH deployment_unit)
#
#      include in current context the find file of a given deployment unit.
#
#      :deployment_unit: name of the deployment unit (e.g. name of the package).
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Path_To_Package_Reference_File| replace:: ``get_Path_To_Package_Reference_File``
#  .. _get_Path_To_Package_Reference_File:
#
#  get_Path_To_Package_Reference_File
#  ----------------------------------
#
#   .. command:: get_Path_To_Package_Reference_File(RESULT_PATH RESULT_CONTRIB_SPACE package)
#
#      get the path to the the reference file of a native package.
#
#      :package: name of the package.
#
#      :RESULT_PATH: output variable containing path to the reference file if found, empty otherwise.
#      :RESULT_CONTRIB_SPACE: output variable containing path to the contribution space with highest priority that contains the reference file.
#
function(get_Path_To_Package_Reference_File RESULT_PATH RESULT_CONTRIB_SPACE package)
  find_File_In_Contribution_Spaces(FIND_FILE_RESULT_PATH PACKAGE_CONTRIB_SPACE references Refer${package}.cmake)
  set(${RESULT_PATH} ${FIND_FILE_RESULT_PATH} PARENT_SCOPE)
  set(${RESULT_CONTRIB_SPACE} ${PACKAGE_CONTRIB_SPACE} PARENT_SCOPE)
endfunction(get_Path_To_Package_Reference_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Path_To_External_Reference_File| replace:: ``get_Path_To_External_Reference_File``
#  .. _get_Path_To_External_Reference_File:
#
#  get_Path_To_External_Reference_File
#  -----------------------------------
#
#   .. command:: get_Path_To_External_Reference_File(RESULT_PATH RESULT_CONTRIB_SPACE package)
#
#      get the path to the the reference file of an external package.
#
#      :package: name of the package.
#
#      :RESULT_PATH: output variable containing path to the reference file if found, empty otherwise.
#      :RESULT_CONTRIB_SPACE: output variable containing path to the contribution space with highest priority that contains the reference file.
#
function(get_Path_To_External_Reference_File RESULT_PATH RESULT_CONTRIB_SPACE package)
  find_File_In_Contribution_Spaces(FIND_FILE_RESULT_PATH PACKAGE_CONTRIB_SPACE references ReferExternal${package}.cmake)
  set(${RESULT_PATH} ${FIND_FILE_RESULT_PATH} PARENT_SCOPE)
  set(${RESULT_CONTRIB_SPACE} ${PACKAGE_CONTRIB_SPACE} PARENT_SCOPE)
endfunction(get_Path_To_External_Reference_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Path_To_Framework_Reference_File| replace:: ``get_Path_To_Framework_Reference_File``
#  .. _get_Path_To_Framework_Reference_File:
#
#  get_Path_To_Framework_Reference_File
#  ------------------------------------
#
#   .. command:: get_Path_To_Framework_Reference_File(RESULT_PATH RESULT_CONTRIB_SPACE framework)
#
#      get the path to the the reference file of a framework.
#
#      :framework: name of the framework.
#
#      :RESULT_PATH: output variable containing path to the reference file if found, empty otherwise.
#      :RESULT_CONTRIB_SPACE: output variable containing path to the contribution space with highest priority that contains the reference file.
#
function(get_Path_To_Framework_Reference_File RESULT_PATH RESULT_CONTRIB_SPACE framework)
  find_File_In_Contribution_Spaces(FIND_FILE_RESULT_PATH PACKAGE_CONTRIB_SPACE references ReferFramework${framework}.cmake)
  set(${RESULT_PATH} ${FIND_FILE_RESULT_PATH} PARENT_SCOPE)
  set(${RESULT_CONTRIB_SPACE} ${PACKAGE_CONTRIB_SPACE} PARENT_SCOPE)
endfunction(get_Path_To_Framework_Reference_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Path_To_Environment_Reference_File| replace:: ``get_Path_To_Environment_Reference_File``
#  .. _get_Path_To_Environment_Reference_File:
#
#  get_Path_To_Environment_Reference_File
#  --------------------------------------
#
#   .. command:: get_Path_To_Environment_Reference_File(RESULT_PATH RESULT_CONTRIB_SPACE environment)
#
#      get the path to the the reference file of an environment.
#
#      :environment: name of the environment.
#
#      :RESULT_PATH: output variable containing path to the reference file if found, empty otherwise.
#      :RESULT_CONTRIB_SPACE: output variable containing path to the contribution space with highest priority that contains the reference file.
#
function(get_Path_To_Environment_Reference_File RESULT_PATH RESULT_CONTRIB_SPACE environment)
  find_File_In_Contribution_Spaces(FIND_FILE_RESULT_PATH PACKAGE_CONTRIB_SPACE references ReferEnvironment${environment}.cmake)
  set(${RESULT_PATH} ${FIND_FILE_RESULT_PATH} PARENT_SCOPE)
  set(${RESULT_CONTRIB_SPACE} ${PACKAGE_CONTRIB_SPACE} PARENT_SCOPE)
endfunction(get_Path_To_Environment_Reference_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |include_Package_Reference_File| replace:: ``include_Package_Reference_File``
#  .. _include_Package_Reference_File:
#
#  include_Package_Reference_File
#  ------------------------------
#
#   .. command:: include_Package_Reference_File(PATH_TO_FILE package)
#
#     Include the reference file of a native package in current context (CMake scope).
#     Note: works as a function since CMake variables of a reference file are all in cache.
#
#      :package: name of the package.
#
#      :PATH_TO_FILE: output variable containing path to the reference file if found, empty otherwise.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |include_External_Reference_File| replace:: ``include_External_Reference_File``
#  .. _include_External_Reference_File:
#
#  include_External_Reference_File
#  -------------------------------
#
#   .. command:: include_External_Reference_File(PATH_TO_FILE package)
#
#     Include the reference file of an external package in current context (CMake scope).
#     Note: works as a function since CMake variables of a reference file are all in cache.
#
#      :package: name of the package.
#
#      :PATH_TO_FILE: output variable containing path to the reference file if found, empty otherwise.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |include_Framework_Reference_File| replace:: ``include_Framework_Reference_File``
#  .. _include_Framework_Reference_File:
#
#  include_Framework_Reference_File
#  --------------------------------
#
#   .. command:: include_Framework_Reference_File(PATH_TO_FILE framework)
#
#     Include the reference file of a framework in current context (CMake scope).
#     Note: works as a function since CMake variables of a reference file are all in cache.
#
#      :framework: name of the framework.
#
#      :PATH_TO_FILE: output variable containing path to the reference file if found, empty otherwise.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |include_Environment_Reference_File| replace:: ``include_Environment_Reference_File``
#  .. _include_Environment_Reference_File:
#
#  include_Environment_Reference_File
#  ----------------------------------
#
#   .. command:: include_Environment_Reference_File(PATH_TO_FILE environment)
#
#     Include the reference file of an environment in current context (CMake scope).
#     Note: works as a function since CMake variables of a reference file are all in cache.
#
#      :environment: name of the environment.
#
#      :PATH_TO_FILE: output variable containing path to the reference file if found, empty otherwise.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Available_References_For_Contribution_Space| replace:: ``get_Available_References_For_Contribution_Space``
#  .. _get_Available_References_For_Contribution_Space:
#
#  get_Available_References_For_Contribution_Space
#  -----------------------------------------------
#
#   .. command:: get_Available_References_For_Contribution_Space(RES_LIST contribution_space prefix)
#
#      get all available reference files referenced in a given contribution space
#
#      :contribution_space: name of the contribution space
#      :prefix: prefix for name (depends on type of deployment unit)
#
#      :RES_LIST: output variable containing the list of licenses provided by contribution_space.
#
function(get_Available_References_For_Contribution_Space RES_LIST contribution_space prefix)
  set(${RES_LIST} PARENT_SCOPE)
  set(PATH_TO_REF ${WORKSPACE_DIR}/contributions/${contribution_space}/references)
  if(EXISTS ${PATH_TO_REF} AND IS_DIRECTORY ${PATH_TO_REF})
    file(GLOB AVAILABLE_REFS RELATIVE ${PATH_TO_REF} ${PATH_TO_REF}/Refer${prefix}*) #getting plugins container folders names
    set(${RES_LIST} ${AVAILABLE_REFS} PARENT_SCOPE)
  endif()
endfunction(get_Available_References_For_Contribution_Space)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_All_Available_References| replace:: ``get_All_Available_References``
#  .. _get_All_Available_References:
#
#  get_All_Available_References
#  ----------------------------
#
#   .. command:: get_All_Available_References(REF_LIST type)
#
#      get all available reference files from all contribution spaces in use, filetered by type.
#
#      :type: type for searched deployment units. Mays take value in: Environment, Framework, External or empty (for native package)
#
#      :REF_LIST: output variable containing the list of references.
#
function(get_All_Available_References REF_LIST prefix)
  set(FINAL_LIST)
  foreach(contrib IN LISTS CONTRIBUTION_SPACES)#CONTRIBUTION_SPACES is supposed to be ordered from highest to lowest priority contribution spaces
    get_Available_References_For_Contribution_Space(RES_LIST ${contrib} "${prefix}")
    list(APPEND FINAL_LIST ${RES_LIST})
  endforeach()
  if(FINAL_LIST)
    list(REMOVE_DUPLICATES FINAL_LIST)
  endif()
  set(${REF_LIST} ${FINAL_LIST} PARENT_SCOPE)
endfunction(get_All_Available_References)

#################################################################################################
############################ Contribution_Spaces global management ##############################
#################################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Contribution_Spaces| replace:: ``update_Contribution_Spaces``
#  .. _update_Contribution_Spaces:
#
#  update_Contribution_Spaces
#  --------------------------
#
#   .. command:: update_Contribution_Spaces()
#
#      Update repositories of all contribution spaces in use.
#
function(update_Contribution_Spaces)
  check_Contribution_Spaces_Updated_In_Current_Process(ALREADY_UPDATED)
  if(NOT ALREADY_UPDATED)
    foreach(contrib IN LISTS CONTRIBUTION_SPACES)
      update_Contribution_Space_Repository(${contrib})
    endforeach()
    set_Contribution_Spaces_Updated_In_Current_Process()
  endif()
endfunction(update_Contribution_Spaces)

#.rst:
#
# .. ifmode:: internal
#
#  .. |configure_Contribution_Space_CMake_Path| replace:: ``configure_Contribution_Space_CMake_Path``
#  .. _configure_Contribution_Space_CMake_Path:
#
#  configure_Contribution_Space_CMake_Path
#  ---------------------------------------
#
#   .. command:: configure_Contribution_Space_CMake_Path(contribution_space)
#
#      Set the CMAKE_MODULE_PATH in current context to make it find content located in a given contrbution space.
#      Note: use a macro to stay in same scope as caller
#
#      :contribution_space: name of the contribution space.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |configure_Contribution_Spaces| replace:: ``configure_Contribution_Spaces``
#  .. _configure_Contribution_Spaces:
#
#  configure_Contribution_Spaces
#  -----------------------------
#
#   .. command:: configure_Contribution_Spaces()
#
#      Set the CMAKE_MODULE_PATH in current context to make it find content located in all used contribution, while preserving priority between contrbution spaces.
#      Note: use a macro to stay in same scope as caller
#
macro(configure_Contribution_Spaces)
  set(PID_WORKSPACE_MODULES_PATH CACHE INTERNAL "")
  # configure the CMAKE_MODULE_PATH according to the list of available contribution_spaces
  foreach(contrib IN LISTS CONTRIBUTION_SPACES)#CONTRIBUTION_SPACES is supposed to be ordered from highest to lowest priority contribution spaces
    configure_Contribution_Space_CMake_Path(${contrib})
  endforeach()
endmacro(configure_Contribution_Spaces)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Path_To_Contribution_Space| replace:: ``get_Path_To_Contribution_Space``
#  .. _get_Path_To_Contribution_Space:
#
#  get_Path_To_Contribution_Space
#  ------------------------------
#
#   .. command:: get_Path_To_Contribution_Space(PATH_TO_DIR space)
#
#      get the path to a contribution space.
#
#      :space: name of the contribution space.
#
#      :PATH_TO_DIR: output variable containing path to the contribution space if found, empty otherwise.
#
function(get_Path_To_Contribution_Space PATH_TO_DIR space)
  set(path ${WORKSPACE_DIR}/contributions/${space})
  if(EXISTS ${path} AND IS_DIRECTORY ${path})
    set(${PATH_TO_DIR} ${path} PARENT_SCOPE)
  else()
    set(${PATH_TO_DIR} PARENT_SCOPE)
  endif()
endfunction(get_Path_To_Contribution_Space)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Path_To_All_Deployment_Unit_References_Publishing_Contribution_Spaces| replace:: ``get_Path_To_All_Deployment_Unit_References_Publishing_Contribution_Spaces``
#  .. _get_Path_To_All_Deployment_Unit_References_Publishing_Contribution_Spaces:
#
#  get_Path_To_All_Deployment_Unit_References_Publishing_Contribution_Spaces
#  -------------------------------------------------------------------------
#
#   .. command:: get_Path_To_All_Deployment_Unit_References_Publishing_Contribution_Spaces( PUBLISHING_CONTRIB_SPACES  deployment_unit)
#
#      get the path to all contribution spaces publishing references of a given depoyment unit.
#
#      :deployment_unit: name of the deployment unit.
#      :default_space: name of the default contribution space to use
#
#      :PUBLISHING_CONTRIB_SPACES: output variable containing the list of path to the contribution spaces that contain references to deployment_unit.
#
function(get_Path_To_All_Deployment_Unit_References_Publishing_Contribution_Spaces PUBLISHING_CONTRIB_SPACES deployment_unit default_space)
  set(list_of_spaces)
  if(TARGET_CONTRIBUTION_SPACE)
    list(APPEND list_of_spaces ${WORKSPACE_DIR}/contributions/${TARGET_CONTRIBUTION_SPACE})
  endif()
  if(default_space)
    list(APPEND list_of_spaces ${WORKSPACE_DIR}/contributions/${default_space})
  endif()

  foreach(cs IN LISTS CONTRIBUTION_SPACES)
    get_All_Matching_Contributions(LICENSE REFERENCE FIND FORMAT PLUGIN ${cs} ${deployment_unit})
    if(REFERENCE OR FIND)
      list(APPEND list_of_spaces ${WORKSPACE_DIR}/contributions/${cs})
    endif()
  endforeach()
  if(list_of_spaces)
    list(REMOVE_DUPLICATES list_of_spaces)
  else()#use at least the contribution space greater priority
    list(GET CONTRIBUTION_SPACES 0 space)
    set(list_of_spaces ${WORKSPACE_DIR}/contributions/${space})
  endif()
  set(${PUBLISHING_CONTRIB_SPACES} ${list_of_spaces} PARENT_SCOPE)
endfunction(get_Path_To_All_Deployment_Unit_References_Publishing_Contribution_Spaces)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Cache_Entry_For_Default_Contribution_Space| replace:: ``set_Cache_Entry_For_Default_Contribution_Space``
#  .. _set_Cache_Entry_For_Default_Contribution_Space:
#
#  set_Cache_Entry_For_Default_Contribution_Space
#  ----------------------------------------------
#
#   .. command:: set_Cache_Entry_For_Default_Contribution_Space()
#
#      create the cache entry TARGET_CONTRIBUTION_SPACE used to define the default contribution space where a deployment unit will publish its references.
#
#      :user_defined: the user defined contribution space, if any.
#
function(set_Cache_Entry_For_Default_Contribution_Space user_defined)
  set(TARGET_CONTRIBUTION_SPACE ${user_defined} CACHE INTERNAL "")
  if(TARGET_CONTRIBUTION_SPACE)
    list(FIND CONTRIBUTION_SPACES "${TARGET_CONTRIBUTION_SPACE}" INDEX)
    if(INDEX EQUAL -1)#not found => not a good value
      message(WARNING "[PID] WARNING : in ${PROJECT_NAME} you specified the contribution space ${TARGET_CONTRIBUTION_SPACE} which is unknown in current workspace.")
      #reset cache variable value
      set(TARGET_CONTRIBUTION_SPACE CACHE INTERNAL "")
    endif()
  endif()
endfunction(set_Cache_Entry_For_Default_Contribution_Space)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Contribution_Space| replace:: ``add_Contribution_Space``
#  .. _add_Contribution_Space:
#
#  add_Contribution_Space
#  ----------------------
#
#   .. command:: add_Contribution_Space(name update publish)
#
#      add to cache the description of a contribution space
#
#      :name: name of the contribution space.
#      :update: URL used to update local content.
#      :publish: URL used to publish local content.
#
function(add_Contribution_Space name update publish)
  append_Unique_In_Cache(CONTRIBUTION_SPACES ${name})#simply add the only update contribution space
  if(publish)
    set(CONTRIBUTION_SPACE_${name}_PUBLISH_REMOTE ${publish} CACHE INTERNAL "")
  else()#no defined publish CS so publish directly in official
    set(CONTRIBUTION_SPACE_${name}_PUBLISH_REMOTE ${update} CACHE INTERNAL "")
  endif()
  if(update)
    set(CONTRIBUTION_SPACE_${name}_UPDATE_REMOTE ${update} CACHE INTERNAL "")
  else()#no defined publish CS so publish directly in official
    set(CONTRIBUTION_SPACE_${name}_UPDATE_REMOTE ${publish} CACHE INTERNAL "")
  endif()
endfunction(add_Contribution_Space)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Contribution_Space| replace:: ``deploy_Contribution_Space``
#  .. _deploy_Contribution_Space:
#
#  deploy_Contribution_Space
#  -------------------------
#
#   .. command:: deploy_Contribution_Space(name update publish)
#
#      Deploy a contrbution space in local workspace.
#
#      :name: name of the contribution space.
#      :update: URL used to update local content.
#      :publish: URL used to publish local content.
#
function(deploy_Contribution_Space DEPLOYED name update publish)
  set(${DEPLOYED} FALSE PARENT_SCOPE)
  clone_Contribution_Space_Repository(CLONED ${update})
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Contribution_Spaces| replace:: ``reset_Contribution_Spaces``
#  .. _reset_Contribution_Spaces:
#
#  reset_Contribution_Spaces
#  -------------------------
#
#   .. command:: reset_Contribution_Spaces()
#
#      Reset any information about contribution spaces and reload them from a contributions description file.
#      May lead to deploy the official PID contribution repository.
#
macro(reset_Contribution_Spaces)
  set(path_to_description_file ${WORKSPACE_DIR}/contributions/contribution_spaces_list.cmake)
  set(official_cs_name "pid")
  set(official_cs_update_remote "https://gite.lirmm.fr/pid/pid-contributions.git")
  set(official_cs_publish_remote "git@gite.lirmm.fr:pid/pid-contributions.git")
  if(FORCE_CONTRIBUTION_SPACES)#in CI process contribution spaces may be forced when configuring the workspace
    set(list_of_pair ${FORCE_CONTRIBUTION_SPACES})
    while(list_of_pair)
      list(GET list_of_pair 0 CS)
      list(GET list_of_pair 1 REMOTE)
      list(REMOVE_AT list_of_pair 0 1)
      add_Contribution_Space(${CS} ${REMOTE} "")
    endwhile()
    write_Contribution_Spaces_Description_File()#write to the file and proceed next steps as usual
    set(FORCE_CONTRIBUTION_SPACES CACHE INTERNAL "" FORCE)
  endif()
  #situations to deal with:
  #- empty contributions folder
  #- missing contributions management file
  read_Contribution_Spaces_Description_File(FILE_EXISTS)
  if(NOT CONTRIBUTION_SPACES)#case at first configuration time just after a clone or a clean (rm -Rf *) of thefolder
    add_Contribution_Space(${official_cs_name} ${official_cs_update_remote} ${official_cs_publish_remote})# pid official CS is the default one and must be present
  else()
    list(FIND CONTRIBUTION_SPACES pid INDEX)
    if(INDEX EQUAL -1)#official contrbution space not present
      add_Contribution_Space(${official_cs_name} ${official_cs_update_remote} ${official_cs_publish_remote})# pid official CS is the default one and must be present
    endif()
  endif()
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
  # and finally write the file that contains all required information for packages, in build folder (since contribution spaces are global to the whole workspace)
  write_Contribution_Spaces(${CMAKE_BINARY_DIR}/Workspace_Contribution_Spaces.cmake)
endmacro(reset_Contribution_Spaces)

#.rst:
#
# .. ifmode:: internal
#
#  .. |PID_Contribution_Space| replace:: ``PID_Contribution_Space``
#  .. _PID_Contribution_Space:
#
#  PID_Contribution_Space
#  ----------------------
#
#   .. command:: PID_Contribution_Space(NAME ... UPDATE ... [PUBLISH ...])
#
#      Declare a contribution space in the contributions description file.
#      Note: to be used only in contributions description file.
#
#      :NAME <string>: name of the contribution space.
#      :UPDATE <URL>: URL used to update local content.
#      :PUBLISH <URL>: URL used to publish local content.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Contribution_Spaces_Variables| replace:: ``reset_Contribution_Spaces_Variables``
#  .. _reset_Contribution_Spaces_Variables:
#
#  reset_Contribution_Spaces_Variables
#  -----------------------------------
#
#   .. command:: reset_Contribution_Spaces_Variables()
#
#      Reset internal cache variables used for contribution spaces description.
#
function(reset_Contribution_Spaces_Variables)
  foreach(contrib_space IN LISTS CONTRIBUTION_SPACES)
    set(CONTRIBUTION_SPACE_${contrib_space}_UPDATE_REMOTE CACHE INTERNAL "")
    set(CONTRIBUTION_SPACE_${contrib_space}_PUBLISH_REMOTE CACHE INTERNAL "")
  endforeach()
  set(CONTRIBUTION_SPACES CACHE INTERNAL "")
endfunction(reset_Contribution_Spaces_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |read_Contribution_Spaces_Description_File| replace:: ``read_Contribution_Spaces_Description_File``
#  .. _read_Contribution_Spaces_Description_File:
#
#  read_Contribution_Spaces_Description_File
#  -----------------------------------------
#
#   .. command:: read_Contribution_Spaces_Description_File(READ_SUCCESS)
#
#      Read the contributions description file and load its content into current context.
#
#      :READ_SUCCESS: output variable that is TRUE is file read, FALSE oetherwise.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Contribution_Spaces_Description_File| replace:: ``write_Contribution_Spaces_Description_File``
#  .. _write_Contribution_Spaces_Description_File:
#
#  write_Contribution_Spaces_Description_File
#  ------------------------------------------
#
#   .. command:: write_Contribution_Spaces_Description_File()
#
#      Write current contribution space description into the contributions description file.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_All_Matching_Contributions| replace:: ``get_All_Matching_Contributions``
#  .. _get_All_Matching_Contributions:
#
#  get_All_Matching_Contributions
#  ------------------------------
#
#   .. command:: get_All_Matching_Contributions(LICENSE REFERENCE FIND FORMAT cs name)
#
#      Get all contributions of a contribution space that match a pattern name
#
#      :cs: name of the contribution space.
#      :name: name of the contribution (license, format, configuration, reference, etc.).
#
#      :LICENSE: output variable that contains a license file name if anyone matches, empty otherwise.
#      :REFERENCE: output variable that contains a reference file name if anyone matches, empty otherwise.
#      :FIND: output variable that contains a find file name if anyone matches, empty otherwise.
#      :FORMAT: output variable that contains a format file name if anyone matches, empty otherwise.
#      :PLUGIN: output variable that contains a plugin folder name if anyone matches, empty otherwise.
#
function(get_All_Matching_Contributions LICENSE REFERENCE FIND FORMAT PLUGIN cs name)
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
  #checking plugins
  if(EXISTS ${PATH_TO_CS}/plugins/${name} AND IS_DIRECTORY ${PATH_TO_CS}/plugins/${name})
    set(${PLUGIN} ${name} PARENT_SCOPE)
  else()
    set(${PLUGIN} PARENT_SCOPE)
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_System_Configuration_All_Non_Official_Contribution_Spaces_In_Use| replace:: ``get_System_Configuration_All_Non_Official_Contribution_Spaces_In_Use``
#  .. _get_System_Configuration_All_Non_Official_Contribution_Spaces_In_Use:
#
#  get_System_Configuration_All_Non_Official_Contribution_Spaces_In_Use
#  --------------------------------------------------------------------
#
#   .. command:: get_System_Configuration_All_Non_Official_Contribution_Spaces_In_Use(LIST_OF_CS config default_cs)
#
#      Get the list of contribution spaces where to find references to configurations used by native or external package.
#      By default contributions that can be found in official contribution space are not put into this list.
#      Also the current project default contribution space has always priority over other spaces that may contain references to a dependency.
#
#      :config: name of the platform configuration (i.e. name of the corresponding wrapper).
#      :default_cs: name of the contribution space considered as default for the current project.
#
#      :LIST_OF_CS: output variable that contains the list of contribution spaces in use in current package.
#
function(get_System_Configuration_All_Non_Official_Contribution_Spaces_In_Use LIST_OF_CS config default_cs)
  set(res_list)
  foreach(check IN LISTS ${config}_CONFIGURATION_DEPENDENCIES)
    parse_Configuration_Expression(CONFIG_NAME CONFIG_ARGS "${check}")
    get_System_Configuration_All_Non_Official_Contribution_Spaces_In_Use(DEP_LIST_OF_CS ${CONFIG_NAME} "${default_cs}")
    list(APPEND res_list ${DEP_LIST_OF_CS})
  endforeach()

  find_Provider_Contribution_Space(PROVIDER ${config} EXTERNAL "${default_cs}")#configuration checks are implemented into external packages
  list(APPEND res_list ${PROVIDER})
  if(res_list)
    list(REMOVE_DUPLICATES res_list)
  endif()
  set(${LIST_OF_CS} ${res_list} PARENT_SCOPE)
endfunction(get_System_Configuration_All_Non_Official_Contribution_Spaces_In_Use)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Package_All_Non_Official_Contribtion_Spaces_In_Use| replace:: ``get_Package_All_Non_Official_Contribtion_Spaces_In_Use``
#  .. _get_Package_All_Non_Official_Contribtion_Spaces_In_Use:
#
#  get_Package_All_Non_Official_Contribtion_Spaces_In_Use
#  ------------------------------------------------------
#
#   .. command:: get_Package_All_Non_Official_Contribtion_Spaces_In_Use(LIST_OF_CS package default_cs mode)
#
#      Get the list of contribution spaces where to find references to dependencies used by current native package.
#      By default contributions that can be found in official contribution space are not put into this list.
#      Also the current project default contribution space has always priority over other spaces that may contain references to a dependency.
#
#      :package: name of the package.
#      :type: type of the package.
#      :default_cs: name of the contribution space considered as default for the current project.
#      :mode: build mode to consider.
#
#      :LIST_OF_CS: output variable that contains the list of contribution spaces in use in current package.
#
function(get_Package_All_Non_Official_Contribtion_Spaces_In_Use LIST_OF_CS package type default_cs mode)
  set(res_list)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  foreach(config IN LISTS ${package}_PLATFORM_CONFIGURATION${VAR_SUFFIX})
    #need to recurse to manage depenencies
    get_System_Configuration_All_Non_Official_Contribution_Spaces_In_Use(DEP_LIST_OF_CS ${config} "${default_cs}")
    list(APPEND res_list ${DEP_LIST_OF_CS})
  endforeach()
  foreach(dep IN LISTS ${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
    get_Package_All_Non_Official_Contribtion_Spaces_In_Use(DEP_LIST_OF_CS ${dep} EXTERNAL "${default_cs}" ${mode})
    list(APPEND res_list ${DEP_LIST_OF_CS})
  endforeach()
  foreach(dep IN LISTS ${package}_DEPENDENCIES${VAR_SUFFIX})
    get_Package_All_Non_Official_Contribtion_Spaces_In_Use(DEP_LIST_OF_CS ${dep} NATIVE "${default_cs}" ${mode})
    list(APPEND res_list ${DEP_LIST_OF_CS})
  endforeach()
  find_Provider_Contribution_Space(PROVIDER ${package} ${type} "${default_cs}")
  list(APPEND res_list ${PROVIDER})
  if(res_list)
    list(REMOVE_DUPLICATES res_list)
  endif()
  set(${LIST_OF_CS} ${res_list} PARENT_SCOPE)
endfunction(get_Package_All_Non_Official_Contribtion_Spaces_In_Use)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Wrapper_All_Non_Official_Contribtion_Spaces_In_Use| replace:: ``get_Wrapper_All_Non_Official_Contribtion_Spaces_In_Use``
#  .. _get_Wrapper_All_Non_Official_Contribtion_Spaces_In_Use:
#
#  get_Wrapper_All_Non_Official_Contribtion_Spaces_In_Use
#  ------------------------------------------------------
#
#   .. command:: get_Wrapper_All_Non_Official_Contribtion_Spaces_In_Use(LIST_OF_CS wrapper default_cs)
#
#      Get the list of contribution spaces where to find references to dependencies used by current external package wrapper.
#      By default contributions that can be found in official contribution space are not put into this list.
#      Also the current project contribution space has always priority over other spaces that may contain references to a dependency.
#
#      :wrapper: name of the external package.
#      :default_cs: name of the contribution space considered as default for the current project.
#
#      :LIST_OF_CS: output variable that contains the list of contribution spaces in use in current package.
#
function(get_Wrapper_All_Non_Official_Contribtion_Spaces_In_Use LIST_OF_CS wrapper default_cs)
  set(res_list)
  foreach(version IN LISTS ${wrapper}_KNOWN_VERSIONS)
  	#reset configurations
  	foreach(config IN LISTS ${wrapper}_KNOWN_VERSION_${version}_CONFIGURATIONS)
      get_System_Configuration_All_Non_Official_Contribution_Spaces_In_Use(DEP_LIST_OF_CS ${config} "${default_cs}")
      list(APPEND res_list ${DEP_LIST_OF_CS})
  	endforeach()
  	#reset package dependencies
  	foreach(package IN LISTS ${wrapper}_KNOWN_VERSION_${version}_DEPENDENCIES)
      get_Package_All_Non_Official_Contribtion_Spaces_In_Use(DEP_LIST_OF_CS ${package} EXTERNAL "${default_cs}" Release)
      list(APPEND res_list ${DEP_LIST_OF_CS})
    endforeach()
  endforeach()

  find_Provider_Contribution_Space(PROVIDER ${wrapper} EXTERNAL "${default_cs}")
  list(APPEND res_list ${PROVIDER})
  if(res_list)
    list(REMOVE_DUPLICATES res_list)
  endif()
  set(${LIST_OF_CS} ${res_list} PARENT_SCOPE)
endfunction(get_Wrapper_All_Non_Official_Contribtion_Spaces_In_Use)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Update_Remote_Of_Contribution_Space| replace:: ``get_Update_Remote_Of_Contribution_Space``
#  .. _get_Update_Remote_Of_Contribution_Space:
#
#  get_Update_Remote_Of_Contribution_Space
#  ---------------------------------------
#
#   .. command:: get_Update_Remote_Of_Contribution_Space(UPDATE_REMOTE cs)
#
#      Get the address of the update remote of a contribution space
#
#      :cs: name of the contribution space.
#
#      :CONFIGURATION: output variable that contains the update remote of the contribution space.
#
function(get_Update_Remote_Of_Contribution_Space UPDATE_REMOTE cs)
  set(${UPDATE_REMOTE} ${CONTRIBUTION_SPACE_${cs}_UPDATE_REMOTE} PARENT_SCOPE)
endfunction(get_Update_Remote_Of_Contribution_Space)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Provider_Contribution_Space| replace:: ``find_Provider_Contribution_Space``
#  .. _find_Provider_Contribution_Space:
#
#  find_Provider_Contribution_Space
#  --------------------------------
#
#   .. command:: find_Provider_Contribution_Space(PROVIDER_CS content)
#
#      Find contribution space that is providing refereces for a content
#      By default contributions that can be found in official contribution returns nothing.
#      Also the current project contribution space has always priority over other spaces that may contain references to a dependency.
#
#      :content: name of the content (native or external package, configuration).
#      :type: type of the content (NATIVE,EXTERNAL)
#      :default_cs: name of the contribution space that is considered as default one.
#
#      :PROVIDER_CS: output variable that contains the name of the provider contribution space.
#
function(find_Provider_Contribution_Space PROVIDER_CS content type default_cs)
  set(${PROVIDER_CS} PARENT_SCOPE)
  if(type STREQUAL "NATIVE")
    if(EXISTS ${WORKSPACE_DIR}/contributions/pid/references/Refer${content}.cmake
    AND EXISTS ${WORKSPACE_DIR}/contributions/pid/finds/Find${content}.cmake)
      return()#if in official contribution space, no need to add it
    endif()

    if(default_cs)#use default CS of the current project
      if(EXISTS ${WORKSPACE_DIR}/contributions/${default_cs}/references/Refer${content}.cmake
      AND EXISTS ${WORKSPACE_DIR}/contributions/${default_cs}/finds/Find${content}.cmake)
        set(${PROVIDER_CS} ${default_cs} PARENT_SCOPE)
        return()
      endif()
    endif()

    #search CS with priority order
    foreach(cs IN LISTS CONTRIBUTION_SPACES)
      if(EXISTS ${WORKSPACE_DIR}/contributions/${cs}/references/Refer${content}.cmake
      AND EXISTS ${WORKSPACE_DIR}/contributions/${cs}/finds/Find${content}.cmake)
        set(${PROVIDER_CS} ${cs} PARENT_SCOPE)
        return()
      endif()
    endforeach()
  elseif(type STREQUAL "EXTERNAL")
    if(EXISTS ${WORKSPACE_DIR}/contributions/pid/references/ReferExternal${content}.cmake
    AND EXISTS ${WORKSPACE_DIR}/contributions/pid/finds/Find${content}.cmake)
      return()#if in official contribution space, no need to add it
    endif()
    if(default_cs)#use default CS of the current project
      if(EXISTS ${WORKSPACE_DIR}/contributions/${default_cs}/references/ReferExternal${content}.cmake
      AND EXISTS ${WORKSPACE_DIR}/contributions/${default_cs}/finds/Find${content}.cmake)
        set(${PROVIDER_CS} ${default_cs} PARENT_SCOPE)
      endif()
    endif()
    #search CS with priority order
    foreach(cs IN LISTS CONTRIBUTION_SPACES)
      if(EXISTS ${WORKSPACE_DIR}/contributions/${cs}/references/ReferExternal${content}.cmake
      AND EXISTS ${WORKSPACE_DIR}/contributions/${cs}/finds/Find${content}.cmake)
        set(${PROVIDER_CS} ${cs} PARENT_SCOPE)
        return()
      endif()
    endforeach()
  endif()
endfunction(find_Provider_Contribution_Space)
