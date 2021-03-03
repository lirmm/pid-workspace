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
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Contribution_Space_Functions NO_POLICY_SCOPE)

function(find_In_CS_List FOUND cs)
  list(FIND CONTRIBUTION_SPACES ${cs} INDEX)
  if(INDEX EQUAL -1)#already registered
    set(${FOUND} FALSE PARENT_SCOPE)
  else()
    set(${FOUND} TRUE PARENT_SCOPE)
endif()
endfunction(find_In_CS_List)

function(get_Type_Of_Contribution TYPE_OF reference_file)
  if(reference_file MATCHES ".*ReferExternal.*\\.cmake")
    set(${TYPE_OF} "package" PARENT_SCOPE)
  elseif(reference_file MATCHES ".*ReferFramework.*\\.cmake")
    set(${TYPE_OF} "framework" PARENT_SCOPE)
  elseif(reference_file MATCHES ".*ReferEnvironment.*\\.cmake")
    set(${TYPE_OF} "environment" PARENT_SCOPE)
  else()
    set(${TYPE_OF} "package" PARENT_SCOPE)
  endif()
endfunction(get_Type_Of_Contribution)

if(NOT TARGET_COMMAND AND DEFINED ENV{cmd})
	set(TARGET_COMMAND $ENV{cmd} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{cmd})
	unset(ENV{cmd})
endif()

if(NOT TARGET_CS AND DEFINED ENV{space})
	set(TARGET_CS $ENV{space} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{space})
	unset(ENV{space})
endif()

if(NOT UPDATE_URL AND DEFINED ENV{update})
	set(UPDATE_URL $ENV{update} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{update})
	unset(ENV{update})
endif()

if(NOT PUBLISH_URL AND DEFINED ENV{publish})
	set(PUBLISH_URL $ENV{publish} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{publish})
	unset(ENV{publish})
endif()

if(NOT SOURCE_CS AND DEFINED ENV{from})
	set(SOURCE_CS $ENV{from} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{from})
	unset(ENV{from})
endif()

if(NOT CONTENT_TO_OPERATE AND DEFINED ENV{content})
	set(CONTENT_TO_OPERATE $ENV{content} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{content})
	unset(ENV{content})
endif()

read_Contribution_Spaces_Description_File(SUCCESS)#get the current list of contribution spaces
if(NOT SUCCESS
  OR NOT CONTRIBUTION_SPACES)
  message(FATAL_ERROR "[PID] ERROR : no contribution space in use, please configure again your workspace.")
endif()

set(cmd_list "ls|add|rm|reset|churl|prio_max|prio_min|move|copy|publish|update|status|delete|clean|list|find")
string(REPLACE "|" ", " cmd_list_mess "${cmd_list}")
if(NOT TARGET_COMMAND)
  message(FATAL_ERROR "[PID] ERROR : no command defined when managing contribution spaces. Use cmd argument with a value chosen among ${cmd_list_mess}.")
elseif(NOT TARGET_COMMAND MATCHES "^${cmd_list}$")
  message(FATAL_ERROR "[PID] ERROR :when managing contribution spaces, command ${TARGET_COMMAND} is unknown. Use cmd argument with a value chosen among ${cmd_list_mess}.")
elseif(NOT TARGET_COMMAND MATCHES "^ls|reset|find$")
  if(NOT TARGET_CS)
    list(GET CONTRIBUTION_SPACES 0 prio_max_cs)
    set(TARGET_CS ${prio_max_cs} CACHE INTERNAL "" FORCE)
    message(WARNING "[PID] WARNING :when managing contribution spaces, no target contribution space defined (use space argument). Contribution space with greater priority (${TARGET_CS}) will be used.")
  endif()
endif()
if(TARGET_COMMAND STREQUAL "add")
  if(NOT UPDATE_URL AND NOT PUBLISH_URL)
    message(FATAL_ERROR "[PID] ERROR :when managing contribution spaces, command add requires either argument update (url where to get last updates of the contribution space) or argument publish (to allow write acces in contribution space) to be defined.")
  endif()
elseif(TARGET_COMMAND STREQUAL "churl")
  if(NOT PUBLISH_URL)
    message(FATAL_ERROR "[PID] ERROR :when managing contribution spaces, command churl requires argument publish (url used to publish updates) to be defined.")
  endif()
elseif(TARGET_COMMAND MATCHES "^move|copy|delete|find$")
  if(NOT CONTENT_TO_OPERATE)
    message(FATAL_ERROR "[PID] ERROR :when managing contribution spaces, command ${TARGET_COMMAND} requires argument content to be defined.")
  endif()
  if(TARGET_COMMAND MATCHES "^move|copy$")
    if(NOT SOURCE_CS)
      message(FATAL_ERROR "[PID] ERROR :when managing contribution spaces, command ${TARGET_COMMAND} requires argument from to be defined.")
    endif()
  endif()
endif()

set(reconfigure FALSE)#by default do nto reconfigure the workspace
if(TARGET_COMMAND STREQUAL "ls")
  message("  Following contribution spaces are ordered from highest to lowest priority contribution space.")
  message("  Edit the file ${WORKSPACE_DIR}/contributions/contribution_spaces_list_cmake to change priorities.")
  foreach(cs IN LISTS CONTRIBUTION_SPACES)
    message("    - ${cs}")
    message("      update=${CONTRIBUTION_SPACE_${cs}_UPDATE_REMOTE}")
    message("      publish=${CONTRIBUTION_SPACE_${cs}_PUBLISH_REMOTE}")
  endforeach()
elseif(TARGET_COMMAND STREQUAL "reset")
  set(CONTRIBUTION_SPACES CACHE INTERNAL "")
  set(reconfigure TRUE)
elseif(TARGET_COMMAND STREQUAL "rm")
  find_In_CS_List(FOUND ${TARGET_CS})
  if(NOT FOUND)
    message("[PID] ERROR : cannot remove ${TARGET_CS} to contribution spaces because this contribution space is not used.")
    return()
  endif()
  set(temp_list ${CONTRIBUTION_SPACES})
  list(REMOVE_ITEM temp_list ${TARGET_CS})
  set(CONTRIBUTION_SPACES ${temp_list} CACHE INTERNAL "")
  if(TARGET_CS STREQUAL "pid")#specific case we ask for suppression of pid official contribution
    # meaning we simply want to reset it to its original configuration
    #it can still contains unpublished commits so we need to remove it and the configuration
    # process will automatically reinstall it from original settings (official remotes)
    file (REMOVE_RECURSE ${WORKSPACE_DIR}/contributions/pid)
  endif()
  set(reconfigure TRUE)
elseif(TARGET_COMMAND STREQUAL "add")
  find_In_CS_List(FOUND ${TARGET_CS})
  if(FOUND)
    message(FATAL_ERROR "[PID] ERROR : cannot add ${TARGET_CS} to contribution spaces since this contribution space is already used.")
  endif()
  add_Contribution_Space(${TARGET_CS} "${UPDATE_URL}" "${PUBLISH_URL}")
  set(reconfigure TRUE)
elseif(TARGET_COMMAND STREQUAL "churl")
  find_In_CS_List(FOUND ${TARGET_CS})
  if(NOT FOUND)
    message(FATAL_ERROR "[PID] ERROR : cannot change url of ${TARGET_CS} because this contribution space is not used.")
  endif()
  #set the publish URL
  set(CONTRIBUTION_SPACE_${TARGET_CS}_PUBLISH_REMOTE ${PUBLISH_URL} CACHE INTERNAL "")
  if(UPDATE_URL)
    set(CONTRIBUTION_SPACE_${TARGET_CS}_UPDATE_REMOTE ${UPDATE_URL} CACHE INTERNAL "")
  endif()
  set(reconfigure TRUE)
elseif(TARGET_COMMAND MATCHES "^prio_max|prio_min$")
  find_In_CS_List(FOUND ${TARGET_CS})
  if(NOT FOUND)
    message(FATAL_ERROR "[PID] ERROR : cannot change priority of ${TARGET_CS} because this contribution space is not used.")
  endif()
  #set the publish URL
  set(temp_list ${CONTRIBUTION_SPACES})
  list(REMOVE_ITEM temp_list ${TARGET_CS})
  #depending on the priority put at beggining or end of the list
  if(TARGET_COMMAND MATCHES "prio_max")
    set(temp_list ${TARGET_CS} ${temp_list})
  else()
    list(APPEND temp_list ${TARGET_CS})
  endif()
  set(CONTRIBUTION_SPACES ${temp_list} CACHE INTERNAL "")
  set(reconfigure TRUE)
elseif(TARGET_COMMAND STREQUAL "publish")
  find_In_CS_List(FOUND ${TARGET_CS})
  if(NOT FOUND)
    message(FATAL_ERROR "[PID] ERROR : cannot publish content from ${TARGET_CS} because this contribution space is not used.")
  endif()
  publish_All_In_Contribution_Space_Repository(${TARGET_CS})
elseif(TARGET_COMMAND STREQUAL "update")
  find_In_CS_List(FOUND ${TARGET_CS})
  if(NOT FOUND)
    message(FATAL_ERROR "[PID] ERROR : cannot update content of ${TARGET_CS} because this contribution space is not used.")
  endif()
  #if this situation we allow confltcs as it is an intentional action from the user
  update_Contribution_Space_Repository(UPDATE_OK ${TARGET_CS} TRUE)
elseif(TARGET_COMMAND STREQUAL "status")
  find_In_CS_List(FOUND ${TARGET_CS})
  if(NOT FOUND)
    message(FATAL_ERROR "[PID] ERROR : cannot update content of ${TARGET_CS} because this contribution space is not used.")
  endif()
  get_Contribution_Space_Repository_Status(LIST_TO_COMMIT LIST_TO_RESET ${TARGET_CS})
  if(LIST_TO_COMMIT)
    get_Name_Of_Contributions_From_Modified_Files(LIST_OF_PACKAGES LIST_OF_FRAMEWORKS
                                                  LIST_OF_ENVIRONMENTS LIST_OF_LICENSES LIST_OF_FORMATS
                                                  "${LIST_TO_COMMIT}")
    message("[PID] INFO: contributions to publish in contribution space ${TARGET_CS}")
    if(LIST_OF_PACKAGES)
      message("[PID] INFO: packages:")
      foreach(contrib IN LISTS LIST_OF_PACKAGES)
        message("            - ${contrib}")
      endforeach()
    endif()
    if(LIST_OF_FRAMEWORKS)
      message("[PID] INFO: frameworks:")
      foreach(contrib IN LISTS LIST_OF_FRAMEWORKS)
        message("            - ${contrib}")
      endforeach()
    endif()
    if(LIST_OF_ENVIRONMENTS)
      message("[PID] INFO: environments:")
      foreach(contrib IN LISTS LIST_OF_ENVIRONMENTS)
        message("            - ${contrib}")
      endforeach()
    endif()
    if(LIST_OF_LICENSES)
      message("[PID] INFO: licenses:")
      foreach(contrib IN LISTS LIST_OF_LICENSES)
        message("            - ${contrib}")
      endforeach()
    endif()
    if(LIST_OF_FORMATS)
      message("[PID] INFO: formats:")
      foreach(contrib IN LISTS LIST_OF_FORMATS)
        message("            - ${contrib}")
      endforeach()
    endif()
  else()
    message("[PID] INFO: nothing new to publish in ${TARGET_CS}")
  endif()
elseif(TARGET_COMMAND STREQUAL "list")
  find_In_CS_List(FOUND ${TARGET_CS})
  if(NOT FOUND)
    message(FATAL_ERROR "[PID] ERROR : cannot list references in ${TARGET_CS} because this contribution space is not used.")
  endif()
  get_Path_To_Contribution_Space(TARGET_PATH ${TARGET_CS})
  get_Name_Of_Contributions(LIST_OF_PACKAGES LIST_OF_FRAMEWORKS
                            LIST_OF_ENVIRONMENTS LIST_OF_LICENSES LIST_OF_FORMATS
                            "${TARGET_PATH}")
  message("[PID] INFO: contributions in contribution space ${TARGET_CS}")
  if(LIST_OF_PACKAGES)
    message("[PID] INFO: packages:")
    foreach(contrib IN LISTS LIST_OF_PACKAGES)
      message("            - ${contrib}")
    endforeach()
  endif()
  if(LIST_OF_FRAMEWORKS)
    message("[PID] INFO: frameworks:")
    foreach(contrib IN LISTS LIST_OF_FRAMEWORKS)
      message("            - ${contrib}")
    endforeach()
  endif()
  if(LIST_OF_ENVIRONMENTS)
    message("[PID] INFO: environments:")
    foreach(contrib IN LISTS LIST_OF_ENVIRONMENTS)
      message("            - ${contrib}")
    endforeach()
  endif()
  if(LIST_OF_LICENSES)
    message("[PID] INFO: licenses:")
    foreach(contrib IN LISTS LIST_OF_LICENSES)
      message("            - ${contrib}")
    endforeach()
  endif()
  if(LIST_OF_FORMATS)
    message("[PID] INFO: formats:")
    foreach(contrib IN LISTS LIST_OF_FORMATS)
      message("            - ${contrib}")
    endforeach()
  endif()
elseif(TARGET_COMMAND STREQUAL "find")
  set(formats)
  set(licenses)
  set(finds)
  set(references)
  set(list_of_cs)
  # memorize information globally
  foreach(cs IN LISTS CONTRIBUTION_SPACES)
    get_All_Matching_Contributions(LICENSE REFERENCE FIND FORMAT ${cs} ${CONTENT_TO_OPERATE})
    if(LICENSE OR FORMATS OR REFERENCE OR FIND)
      list(APPEND list_of_cs ${cs})
      if(LICENSE)
        list(APPEND licenses ${cs})
      endif()
      if(FORMAT)
        list(APPEND formats ${cs})
      endif()
      if(REFERENCE)
        set(${cs}_REFERENCE ${REFERENCE})
        list(APPEND references ${cs})
      endif()
      if(FIND)
        list(APPEND finds ${cs})
      endif()
    endif()
  endforeach()
  if(NOT list_of_cs)
    message("[PID] INFO : no reference of ${CONTENT_TO_OPERATE} can be found in any contribution space.")
    return()
  endif()
  #printing output
  if(licenses)
    fill_String_From_List(RES_LIC_STRING licenses ", ")
    message("[PID] INFO: license ${CONTENT_TO_OPERATE} found in contribution spaces : ${RES_LIC_STRING}")
  endif()
  if(formats)
    fill_String_From_List(RES_FORMAT_STRING formats ", ")
    message("[PID] INFO: format ${CONTENT_TO_OPERATE} found in contribution spaces : ${RES_FORMAT_STRING}")
  endif()
  if(references OR finds)
    #specific case: provide information to help debugging a problematic situation
    set(all_refs ${references} ${finds})
    list(REMOVE_DUPLICATES all_refs)
    fill_String_From_List(RES_REF_STRING all_refs ", ")
    message("[PID] INFO: references to package ${CONTENT_TO_OPERATE} found in contribution spaces : ${RES_REF_STRING}")
    #checking CS that do not provide a find file
    set(missing_find)
    foreach(cs IN LISTS references)
      list(FIND finds "${cs}" INDEX)
      if(INDEX EQUAL -1)
        list(APPEND missing_find ${cs})
      endif()
    endforeach()
    if(missing_find)
      fill_String_From_List(RES_MISS_STRING missing_find ", ")
      message("[PID] WARNING: some contribution spaces do not define a find file for package ${CONTENT_TO_OPERATE}: ${RES_MISS_STRING}")
    endif()
    #checking CS that do not provide a reference file
    set(missing_ref)
    foreach(cs IN LISTS finds)
      list(FIND references "${cs}" INDEX)
      if(INDEX EQUAL -1)
        list(APPEND missing_ref ${cs})
      endif()
    endforeach()
    if(missing_ref)
      fill_String_From_List(RES_MISS_STRING missing_ref ", ")
      message("[PID] WARNING: some contribution spaces do not define a reference file for package ${CONTENT_TO_OPERATE}: ${RES_MISS_STRING}")
    endif()
    #checking type of contributions based on their reference file
    set(externals)
    set(natives)
    foreach(cs IN LISTS references)
      if(${cs}_REFERENCE MATCHES ".*ReferExternal.+\\.cmake")
        list(APPEND externals ${cs})
      else()
        list(APPEND natives ${cs})
      endif()
    endforeach()
    if(natives AND externals)
      message("[PID] WARNING: package ${CONTENT_TO_OPERATE} is referenced as either a native and external package (this may generate corrupted deployment/build process):")
      fill_String_From_List(RES_NATIVE_STRING natives ", ")
      message("[PID] INFO:referenced as native by: ${RES_NATIVE_STRING}")
      fill_String_From_List(RES_EXT_STRING externals ", ")
      message("[PID] INFO:referenced as external by: ${RES_EXT_STRING}")
    endif()
  endif()
elseif(TARGET_COMMAND STREQUAL "move")
  find_In_CS_List(FOUND ${TARGET_CS})
  if(NOT FOUND)
    message(FATAL_ERROR "[PID] ERROR : cannot move references in ${TARGET_CS} because this contribution space is not used.")
  endif()
  find_In_CS_List(FOUND ${SOURCE_CS})
  if(NOT FOUND)
    message(FATAL_ERROR "[PID] ERROR : cannot move references from ${SOURCE_CS} because this contribution space is not used.")
  endif()
  get_Path_To_Contribution_Space(SOURCE_PATH ${SOURCE_CS})
  get_Path_To_Contribution_Space(TARGET_PATH ${TARGET_CS})
  get_All_Matching_Contributions(LICENSE REFERENCE FIND FORMAT ${SOURCE_CS} ${CONTENT_TO_OPERATE})
  if(LICENSE)
    if(NOT EXISTS ${TARGET_PATH}/licenses)
      file(MAKE_DIRECTORY ${TARGET_PATH}/licenses)
    endif()
    file(RENAME ${SOURCE_PATH}/licenses/${LICENSE} ${TARGET_PATH}/licenses/${LICENSE})
    commit_Files(SOURCE_COMMIT_RES ${SOURCE_PATH} "licenses/${LICENSE}" "removed references for license ${CONTENT_TO_OPERATE}" FALSE)
    commit_Files(TARGET_COMMIT_RES ${TARGET_PATH} "licenses/${LICENSE}" "added references for license ${CONTENT_TO_OPERATE}" FALSE)
  endif()
  if(FORMAT)
    if(NOT EXISTS ${TARGET_PATH}/formats)
      file(MAKE_DIRECTORY ${TARGET_PATH}/formats)
    endif()
    file(RENAME ${SOURCE_PATH}/formats/${FORMAT} ${TARGET_PATH}/formats/${FORMAT})
    commit_Files(SOURCE_COMMIT_RES ${SOURCE_PATH} "formats/${FORMAT}" "removed references for format ${CONTENT_TO_OPERATE}" FALSE)
    commit_Files(TARGET_COMMIT_RES ${TARGET_PATH} "formats/${FORMAT}" "added references for format ${CONTENT_TO_OPERATE}" FALSE)
  endif()
  if(REFERENCE OR FIND)#manage find and reference "all in one" if required
    set(moved_files)
    set(type_of_contrib)
    if(FIND)
      if(NOT EXISTS ${TARGET_PATH}/finds)
        file(MAKE_DIRECTORY ${TARGET_PATH}/finds)
      endif()
      file(RENAME ${SOURCE_PATH}/finds/${FIND} ${TARGET_PATH}/finds/${FIND})
      list(APPEND moved_files finds/${FIND})
      set(type_of_contrib "package")#only native and external packages have find files
    endif()
    if(REFERENCE)
      if(NOT EXISTS ${TARGET_PATH}/references)
        file(MAKE_DIRECTORY ${TARGET_PATH}/references)
      endif()
      file(RENAME ${SOURCE_PATH}/references/${REFERENCE} ${TARGET_PATH}/references/${REFERENCE})
      list(APPEND moved_files references/${REFERENCE})
      get_Type_Of_Contribution(type_of_contrib ${REFERENCE})
    endif()
    commit_Files(SOURCE_COMMIT_RES ${SOURCE_PATH} "${moved_files}" "removed references for ${type_of_contrib} ${CONTENT_TO_OPERATE}" FALSE)
    commit_Files(TARGET_COMMIT_RES ${TARGET_PATH} "${moved_files}" "added references for ${type_of_contrib} ${CONTENT_TO_OPERATE}" FALSE)
  endif()
elseif(TARGET_COMMAND STREQUAL "copy")
  find_In_CS_List(FOUND ${TARGET_CS})
  if(NOT FOUND)
    message(FATAL_ERROR "[PID] ERROR : cannot copy contributions in ${TARGET_CS} because this contribution space is not used.")
  endif()
  find_In_CS_List(FOUND ${SOURCE_CS})
  if(NOT FOUND)
    message(FATAL_ERROR "[PID] ERROR : cannot copy contributions from ${SOURCE_CS} because this contribution space is not used.")
  endif()
  get_Path_To_Contribution_Space(SOURCE_PATH ${SOURCE_CS})
  get_Path_To_Contribution_Space(TARGET_PATH ${TARGET_CS})
  get_All_Matching_Contributions(LICENSE REFERENCE FIND FORMAT ${SOURCE_CS} ${CONTENT_TO_OPERATE})
  if(LICENSE)
    if(NOT EXISTS ${TARGET_PATH}/licenses)
      file(MAKE_DIRECTORY ${TARGET_PATH}/licenses)
    endif()
    file(COPY ${SOURCE_PATH}/licenses/${LICENSE} DESTINATION ${TARGET_PATH}/licenses)
    commit_Files(COMMIT_RES ${SOURCE_PATH} "licenses/${LICENSE}" "added references for license ${CONTENT_TO_OPERATE}" FALSE)
  endif()
  if(FORMAT)
    if(NOT EXISTS ${TARGET_PATH}/formats)
      file(MAKE_DIRECTORY ${TARGET_PATH}/formats)
    endif()
    file(COPY ${SOURCE_PATH}/formats/${FORMAT} DESTINATION ${TARGET_PATH}/formats)
    commit_Files(COMMIT_RES ${TARGET_PATH} "formats/${FORMAT}" "addded references for format ${CONTENT_TO_OPERATE}" FALSE)
  endif()
  if(REFERENCE OR FIND)
    set(copied_files)
    set(type_of_contrib)
    if(FIND)
      if(NOT EXISTS ${TARGET_PATH}/finds)
        file(MAKE_DIRECTORY ${TARGET_PATH}/finds)
      endif()
      file(COPY ${SOURCE_PATH}/finds/${FIND} DESTINATION ${TARGET_PATH}/finds)
      list(APPEND copied_files finds/${FIND})
      set(type_of_contrib "package")#only native and external packages have find files
    endif()
    if(REFERENCE)
      if(NOT EXISTS ${TARGET_PATH}/references)
        file(MAKE_DIRECTORY ${TARGET_PATH}/references)
      endif()
      file(COPY ${SOURCE_PATH}/references/${REFERENCE} DESTINATION ${TARGET_PATH}/references)
      list(APPEND copied_files references/${REFERENCE})
      get_Type_Of_Contribution(type_of_contrib ${REFERENCE})
    endif()
    commit_Files(COMMIT_RES ${TARGET_PATH} "${copied_files}" "addded references for ${type_of_contrib} ${CONTENT_TO_OPERATE}" FALSE)
  endif()
elseif(TARGET_COMMAND STREQUAL "delete")
  find_In_CS_List(FOUND ${TARGET_CS})
  if(NOT FOUND)
    message(FATAL_ERROR "[PID] ERROR : cannot delete contributions in ${TARGET_CS} because this contribution space is not used.")
  endif()
  get_Path_To_Contribution_Space(TARGET_PATH ${TARGET_CS})
  get_All_Matching_Contributions(LICENSE REFERENCE FIND FORMAT ${TARGET_CS} ${CONTENT_TO_OPERATE})
  if(LICENSE)
    file(REMOVE ${TARGET_PATH}/licenses/${LICENSE})
    commit_Files(COMMIT_RES ${TARGET_PATH} "licenses/${LICENSE}" "removed references for license ${CONTENT_TO_OPERATE}" FALSE)
  endif()
  if(FORMAT)
    file(REMOVE ${TARGET_PATH}/formats/${FORMAT})
    commit_Files(COMMIT_RES ${TARGET_PATH} "formats/${FORMAT}" "removed references for format ${CONTENT_TO_OPERATE}" FALSE)
  endif()
  if(REFERENCE OR FIND)
    set(deleted_files)
    set(type_of_contrib)
    if(FIND)
      file(REMOVE ${TARGET_PATH}/finds/${FIND})
      list(APPEND deleted_files finds/${FIND})
      set(type_of_contrib "package")#only native and external packages have find files
    endif()
    if(REFERENCE)
      file(REMOVE ${TARGET_PATH}/references/${REFERENCE})
      list(APPEND deleted_files references/${REFERENCE})
      get_Type_Of_Contribution(type_of_contrib ${REFERENCE})
    endif()
    commit_Files(COMMIT_RES ${TARGET_PATH} "${deleted_files}" "removed references for ${type_of_contrib} ${CONTENT_TO_OPERATE}" FALSE)
  endif()
elseif(TARGET_COMMAND STREQUAL "clean")
  find_In_CS_List(FOUND ${TARGET_CS})
  if(NOT FOUND)
    message(FATAL_ERROR "[PID] ERROR : cannot clean contributions in ${TARGET_CS} because this contribution space is not used.")
  endif()
  get_Path_To_Contribution_Space(TARGET_PATH ${TARGET_CS})
  reset_Repository_Context(${TARGET_PATH})
endif()
if(reconfigure)
  #finally update the file and reconfigure the workspace
  write_Contribution_Spaces_Description_File()
  execute_process(COMMAND ${CMAKE_COMMAND} .. WORKING_DIRECTORY ${WORKSPACE_DIR}/build)#reconfigure the workspace
endif()
