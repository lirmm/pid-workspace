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
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Contribution_Space_Functions NO_POLICY_SCOPE)
include(PID_Finding_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)

get_Package_Type(${TARGET_PACKAGE} PACK_TYPE)
if(PACK_TYPE STREQUAL "EXTERNAL")
  list_Version_Subdirectories(in_project_versions ${WORKSPACE_DIR}/wrappers/${TARGET_PACKAGE}/src)
elseif(PACK_TYPE STREQUAL "NATIVE")
  get_Repository_Version_Tags(GIT_VERSIONS ${TARGET_PACKAGE})
  normalize_Version_Tags(in_project_versions "${GIT_VERSIONS}")
endif()
if(in_project_versions)
  list(REMOVE_ITEM in_project_versions 0.0.0)
endif()
load_Current_Contribution_Spaces()
set(DO_NOT_FIND_${TARGET_PACKAGE} TRUE)
include_Find_File(${TARGET_PACKAGE})#just include the find file to get information about compatible versions, do not "find for real" in install tree
unset(DO_NOT_FIND_${TARGET_PACKAGE})
set(all_known_versions ${${TARGET_PACKAGE}_PID_KNOWN_VERSION})
if(all_known_versions)
  list(REMOVE_ITEM all_known_versions 0.0.0)
endif()
set(purely_local_version)
foreach(version IN LISTS in_project_versions)
  list(FIND all_known_versions ${version} INDEX)
  if(INDEX EQUAL -1)#checking for purely local versions
    list(APPEND purely_local_version ${version})
  endif()
endforeach()

set(purely_remote_version)
foreach(version IN LISTS all_known_versions)
  list(FIND in_project_versions ${version} INDEX)
  if(INDEX EQUAL -1)#checking for purely remote versions
    list(APPEND purely_remote_version ${version})
  endif()
endforeach()

set(all_versions ${all_known_versions} ${in_project_versions})
if(all_versions)
  list(REMOVE_DUPLICATES all_versions)
endif()

sort_Version_List(all_versions)
if(NOT all_versions)
  message("NO VERSION KNOWN")
endif()
foreach(version IN LISTS all_versions)
  set(note)
  if(purely_remote_version)
    list(FIND purely_remote_version ${version} INDEX)
    if(NOT INDEX EQUAL -1)
      set(note "(LOCAL, requires referencing)")
    endif()
  elseif(purely_local_version)
    list(FIND purely_remote_version ${version} INDEX)
    if(NOT INDEX EQUAL -1)
      set(note "(REMOTE, requires upgrade)")
    endif()
  endif()
  message("- ${version} ${note}")
endforeach()
