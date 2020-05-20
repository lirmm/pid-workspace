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
if(PID_PROFILE_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_PROFILE_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

include(PID_Environment_API_Internal_Functions NO_POLICY_SCOPE)

include(CMakeParseArguments)

#.rst:
#
# .. ifmode:: internal
#
#  .. |load_Profile_Info| replace:: ``load_Profile_Info``
#  .. _load_Profile_Info:
#
#  load_Profile_Info
#  -----------------
#
#   .. command:: load_Profile_Info()
#
#      Load information about current profile into current process.
#
function(load_Profile_Info)
  if(EXISTS ${WORKSPACE_DIR}/pid/Workspace_Profile_Info.cmake)
    set(TEMP_PROFILES ${PROFILES} CACHE INTERNAL "")
    set(TEMP_CURRENT_PROFILE ${CURRENT_PROFILE} CACHE INTERNAL "")
    set(TEMP_CURRENT_GENERATOR ${CURRENT_GENERATOR} CACHE INTERNAL "")
    set(TEMP_CURRENT_GENERATOR_EXTRA ${CURRENT_GENERATOR_EXTRA} CACHE INTERNAL "")
    set(TEMP_CURRENT_GENERATOR_INSTANCE ${CURRENT_GENERATOR_INSTANCE} CACHE INTERNAL "")
    set(TEMP_CURRENT_GENERATOR_TOOLSET ${CURRENT_GENERATOR_TOOLSET} CACHE INTERNAL "")
    set(TEMP_CURRENT_GENERATOR_PLATFORM ${CURRENT_GENERATOR_PLATFORM} CACHE INTERNAL "")
    include(${WORKSPACE_DIR}/pid/Workspace_Profile_Info.cmake)
  endif()
endfunction(load_Profile_Info)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Profile_Info| replace:: ``reset_Profile_Info``
#  .. _reset_Profile_Info:
#
#  reset_Profile_Info
#  ------------------
#
#   .. command:: reset_Profile_Info()
#
#      Load information about current profile into current process.
#
function(reset_Profile_Info)
  if(TEMP_PROFILES)
    set(PROFILES ${TEMP_PROFILES} CACHE INTERNAL "")
    set(CURRENT_PROFILE ${TEMP_CURRENT_PROFILE} CACHE INTERNAL "")
    set(CURRENT_GENERATOR ${TEMP_CURRENT_GENERATOR} CACHE INTERNAL "")
    set(CURRENT_GENERATOR_EXTRA ${TEMP_CURRENT_GENERATOR_EXTRA} CACHE INTERNAL "")
    set(CURRENT_GENERATOR_INSTANCE ${TEMP_CURRENT_GENERATOR_INSTANCE} CACHE INTERNAL "")
    set(CURRENT_GENERATOR_TOOLSET ${TEMP_CURRENT_GENERATOR_TOOLSET} CACHE INTERNAL "")
    set(CURRENT_GENERATOR_PLATFORM ${TEMP_CURRENT_GENERATOR_PLATFORM} CACHE INTERNAL "")

    unset(TEMP_PROFILES CACHE)
    unset(TEMP_CURRENT_PROFILE CACHE)
    unset(TEMP_CURRENT_GENERATOR CACHE)
    unset(TEMP_CURRENT_GENERATOR_EXTRA CACHE)
    unset(TEMP_CURRENT_GENERATOR_INSTANCE CACHE)
    unset(TEMP_CURRENT_GENERATOR_TOOLSET CACHE)
    unset(TEMP_CURRENT_GENERATOR_PLATFORM CACHE)
  endif()
endfunction(reset_Profile_Info)



#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Profiles_Variables| replace:: ``reset_Profiles_Variables``
#  .. _reset_Profiles_Variables:
#
#  reset_Profiles_Variables
#  -----------------------------------
#
#   .. command:: reset_Profiles_Variables()
#
#      Reset internal cache variables used for profiles description.
#
function(reset_Profiles_Variables)
  foreach(profile IN LISTS PROFILES)
    #all variables used to configrue all environments in use
    set(PROFILE_${profile}_TARGET_SYSROOT CACHE INTERNAL "")
    set(PROFILE_${profile}_TARGET_STAGING CACHE INTERNAL "")
    set(PROFILE_${profile}_TARGET_INSTANCE CACHE INTERNAL "")
    set(PROFILE_${profile}_TARGET_PLATFORM_OS CACHE INTERNAL "")
    set(PROFILE_${profile}_TARGET_PLATFORM_PROC_ARCH CACHE INTERNAL "")
    set(PROFILE_${profile}_TARGET_PLATFORM_PROC_TYPE CACHE INTERNAL "")
    set(PROFILE_${profile}_TARGET_PLATFORM_ABI CACHE INTERNAL "")
    set(PROFILE_${profile}_TARGET_DISTRIBUTION CACHE INTERNAL "")
    set(PROFILE_${profile}_TARGET_DISTRIBUTION_VERSION CACHE INTERNAL "")
    set(PROFILE_${profile}_DEFAULT_ENVIRONMENT CACHE INTERNAL "")#the default environment in use (may be host)
    set(PROFILE_${profile}_MORE_ENVIRONMENTS CACHE INTERNAL "")
  endforeach()
  set(PROFILES CACHE INTERNAL "")
  set(CURRENT_PROFILE CACHE INTERNAL "")
endfunction(reset_Profiles_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |read_Profiles_Description_File| replace:: ``read_Profiles_Description_File``
#  .. _read_Profiles_Description_File:
#
#  read_Profiles_Description_File
#  ------------------------------
#
#   .. command:: read_Profiles_Description_File(READ_SUCCESS)
#
#      Read the profiles file and load its content into current context.
#
#      :READ_SUCCESS: output variable that is TRUE is file read, FALSE oetherwise.
#
function(read_Profiles_Description_File READ_SUCCESS)
  set(target_file_path ${WORKSPACE_DIR}/environments/profiles_list.cmake)
  if(EXISTS ${target_file_path})#if file exists it means there is a description
    reset_Profiles_Variables()#reset already existing description
    include(${target_file_path})
    set(${READ_SUCCESS} TRUE PARENT_SCOPE)
    return()
  endif()
  set(${READ_SUCCESS} FALSE PARENT_SCOPE)
endfunction(read_Profiles_Description_File)


#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Profiles_Description_File| replace:: ``write_Profiles_Description_File``
#  .. _write_Profiles_Description_File:
#
#  write_Profiles_Description_File
#  -------------------------------
#
#   .. command:: write_Profiles_Description_File()
#
#      Write available profiles description into the profile description file.
#
function(write_Profiles_Description_File)
  set(target_file_path ${WORKSPACE_DIR}/environments/profiles_list.cmake)
  file(WRITE ${target_file_path} "")#reset file content
  foreach(profile IN LISTS PROFILES)

    #all variables used to configure all environments in use
    set(all_envs ${PROFILE_${profile}_DEFAULT_ENVIRONMENT})
    list(APPEND all_envs ${PROFILE_${profile}_MORE_ENVIRONMENTS})
    fill_String_From_List(all_envs all_envs_str)
    if(profile STREQUAL CURRENT_PROFILE)
      set(str_to_write "PID_Profile(NAME ${profile} CURRENT ENVIRONMENTS ${all_envs_str}")
    else()
      set(str_to_write "PID_Profile(NAME ${profile} ENVIRONMENTS ${all_envs_str}")
    endif()
    if(PROFILE_${profile}_TARGET_PLATFORM_PROC_TYPE)
      set(str_to_write "${str_to_write}\n            PROC_TYPE ${PROFILE_${profile}_TARGET_PLATFORM_PROC_TYPE}")
    endif()
    if(PROFILE_${profile}_TARGET_PLATFORM_PROC_ARCH)
      set(str_to_write "${str_to_write}\n            PROC_ARCH ${PROFILE_${profile}_TARGET_PLATFORM_PROC_ARCH}")
    endif()
    if(PROFILE_${profile}_TARGET_PLATFORM_OS)
      set(str_to_write "${str_to_write}\n            OS         ${PROFILE_${profile}_TARGET_PLATFORM_OS}")
    endif()
    if(PROFILE_${profile}_TARGET_PLATFORM_ABI)
      set(str_to_write "${str_to_write}\n            ABI        ${PROFILE_${profile}_TARGET_PLATFORM_ABI}")
    endif()
    if(PROFILE_${profile}_TARGET_INSTANCE)
      set(str_to_write "${str_to_write}\n            INSTANCE    ${PROFILE_${profile}_TARGET_INSTANCE}")
    endif()
    if(PROFILE_${profile}_TARGET_DISTRIBUTION)
      set(str_to_write "${str_to_write}\n            DISTRIBUTION ${PROFILE_${profile}_TARGET_DISTRIBUTION}")
    endif()
    if(PROFILE_${profile}_TARGET_DISTRIBUTION_VERSION)
      set(str_to_write "${str_to_write}\n            DISTRIBUTION_VERSION ${PROFILE_${profile}_TARGET_DISTRIBUTION_VERSION}")
    endif()
    set(str_to_write "${str_to_write})")
    file(APPEND ${target_file_path} "${str_to_write}\n")
  endforeach()
endfunction(write_Profiles_Description_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Workspace_Profiles_Info_File| replace:: ``write_Workspace_Profiles_Info_File``
#  .. _write_Workspace_Profiles_Info_File:
#
#  write_Workspace_Profiles_Info_File
#  ----------------------------------
#
#   .. command:: write_Workspace_Profiles_Info_File()
#
#      Write current profile required information into a file used at deployment unit level to decide which profile to use
#
function(write_Workspace_Profiles_Info_File)
  set(target_file_path ${WORKSPACE_DIR}/pid/Workspace_Profile_Info.cmake)
  file(WRITE ${target_file_path} "set(PROFILES ${PROFILES} CACHE INTERNAL \"\")\n")#reset file content and define all available profiles
  file(APPEND ${target_file_path} "set(CURRENT_PROFILE ${CURRENT_PROFILE} CACHE INTERNAL \"\")\n")
  # also memorizing generator info required to generate the CMake projects from native build system
  file(APPEND ${target_file_path} "set(CURRENT_GENERATOR \"${CMAKE_GENERATOR}\" CACHE INTERNAL \"\")\n")
  file(APPEND ${target_file_path} "set(CURRENT_GENERATOR_EXTRA \"${CMAKE_EXTRA_GENERATOR}\" CACHE INTERNAL \"\")\n")
  file(APPEND ${target_file_path} "set(CURRENT_GENERATOR_INSTANCE \"${CMAKE_GENERATOR_INSTANCE}\" CACHE INTERNAL \"\")\n")
  file(APPEND ${target_file_path} "set(CURRENT_GENERATOR_TOOLSET \"${CMAKE_GENERATOR_TOOLSET}\" CACHE INTERNAL \"\")\n")
  file(APPEND ${target_file_path} "set(CURRENT_GENERATOR_PLATFORM \"${CMAKE_GENERATOR_PLATFORM}\" CACHE INTERNAL \"\")\n")
endfunction(write_Workspace_Profiles_Info_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Managed_Profile| replace:: ``add_Managed_Profile``
#  .. -add_Managed_Profile:
#
#  add_Managed_Profile
#  -------------------
#
#   .. command:: add_Managed_Profile()
#
#      Adding a new profile to profiles list and / or setting its properties.
#
#      :profile: The name of the profile
#
#      :ENVIRONMENT: the default environment to use for this profile
#      :INSTANCE: the instance name for the profile
#      :SYSROOT: the sysroot folder to use (when crosscompiling)
#      :STAGING: the staging folder to use (when crosscompiling)
#      :OS: the platform OS to target
#      :PROC_TYPE: the processor type to target
#      :PROC_ARCH: the processor arch to target
#      :ABI: the c++ compiler ABI to target
#      :DISTRIBUTION: the distribution to target
#      :DISTRIB_VERSION: the version of distribution to target
#
function(add_Managed_Profile profile)
  append_Unique_In_Cache(PROFILES ${profile})
  set(oneValueArgs SYSROOT STAGING INSTANCE OS PROC_TYPE PROC_ARCH ABI DISTRIBUTION DISTRIB_VERSION ENVIRONMENT)
  cmake_parse_arguments(ADD_MANAGED_PROFILE "" "${oneValueArgs}" "" ${ARGN} )

  if(ADD_MANAGED_PROFILE_ENVIRONMENT)
    if(PROFILE_${profile}_DEFAULT_ENVIRONMENT)#default environment already defined
      append_Unique_In_Cache(PROFILE_${profile}_MORE_ENVIRONMENTS ${ADD_MANAGED_PROFILE_ENVIRONMENT})#adding one more additionnal environment
    else()
      set(PROFILE_${profile}_DEFAULT_ENVIRONMENT ${ADD_MANAGED_PROFILE_ENVIRONMENT} CACHE INTERNAL "")
    endif()
  endif()
  if(ADD_MANAGED_PROFILE_SYSTROOT)
    set(PROFILE_${profile}_TARGET_SYSROOT ${ADD_MANAGED_PROFILE_SYSTROOT} CACHE INTERNAL "")
  endif()
  if(ADD_MANAGED_PROFILE_STAGING)
    set(PROFILE_${profile}_TARGET_STAGING ${ADD_MANAGED_PROFILE_STAGING} CACHE INTERNAL "")
  endif()
  if(ADD_MANAGED_PROFILE_INSTANCE)
    set(PROFILE_${profile}_TARGET_INSTANCE ${ADD_MANAGED_PROFILE_INSTANCE} CACHE INTERNAL "")
  endif()
  if(ADD_MANAGED_PROFILE_OS)
    set(PROFILE_${profile}_TARGET_PLATFORM_OS ${ADD_MANAGED_PROFILE_OS} CACHE INTERNAL "")
  endif()
  if(ADD_MANAGED_PROFILE_PROC_TYPE)
    set(PROFILE_${profile}_TARGET_PLATFORM_PROC_TYPE ${ADD_MANAGED_PROFILE_PROC_TYPE} CACHE INTERNAL "")
  endif()
  if(ADD_MANAGED_PROFILE_PROC_ARCH)
    set(PROFILE_${profile}_TARGET_PLATFORM_PROC_ARCH ${ADD_MANAGED_PROFILE_PROC_ARCH} CACHE INTERNAL "")
  endif()
  if(ADD_MANAGED_PROFILE_ABI)
    set(PROFILE_${profile}_TARGET_PLATFORM_ABI ${ADD_MANAGED_PROFILE_ABI} CACHE INTERNAL "")
  endif()
  if(ADD_MANAGED_PROFILE_DISTRIBUTION)
    set(PROFILE_${profile}_TARGET_DISTRIBUTION ${ADD_MANAGED_PROFILE_DISTRIBUTION} CACHE INTERNAL "")
  endif()
  if(ADD_MANAGED_PROFILE_DISTRIB_VERSION)
    set(PROFILE_${profile}_TARGET_DISTRIBUTION_VERSION ${ADD_MANAGED_PROFILE_DISTRIB_VERSION} CACHE INTERNAL "")
  endif()

endfunction(add_Managed_Profile)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Default_Profile| replace:: ``add_Default_Profile``
#  .. _add_Default_Profile:
#
#  add_Default_Profile
#  -------------------
#
#   .. command:: add_Default_Profile()
#
#      Adding the default profile description to profiles list.
#
function(add_Default_Profile)
  add_Managed_Profile("default" ENVIRONMENT "host" INSTANCE "")#force the instance name to be empty
  if(NOT CURRENT_PROFILE)#default is current is no other profile is current one
    set(CURRENT_PROFILE "default" CACHE INTERNAL "")
  endif()
endfunction(add_Default_Profile)

#.rst:
#
# .. ifmode:: internal
#
#  .. |remove_Profile| replace:: ``remove_Profile``
#  .. _remove_Profile:
#
#  remove_Profile
#  --------------
#
#   .. command:: remove_Profile(CURRENT_CHANGED profile)
#
#      Removing a profile from profiles list.
#
#      :profile: The name of the profile
#
#      :CURRENT_CHANGED: The output variable that is TRUE if current environment has changed after removal
#
function(remove_Profile CURRENT_CHANGED profile)
  set(${CURRENT_CHANGED} FALSE PARENT_SCOPE)
  set(profiles ${PROFILES})
  list(REMOVE_ITEM profiles ${profile})
  set(PROFILES ${profiles} CACHE INTERNAL "")
  if(CURRENT_PROFILE STREQUAL profile)
    set(CURRENT_PROFILE default CACHE INTERNAL "")
    set(${CURRENT_CHANGED} TRUE PARENT_SCOPE)
  endif()
  unset(PROFILE_${profile}_TARGET_SYSROOT CACHE)
  unset(PROFILE_${profile}_TARGET_STAGING CACHE)
  unset(PROFILE_${profile}_TARGET_INSTANCE CACHE)
  unset(PROFILE_${profile}_TARGET_PLATFORM_OS CACHE)
  unset(PROFILE_${profile}_TARGET_PLATFORM_PROC_ARCH CACHE)
  unset(PROFILE_${profile}_TARGET_PLATFORM_PROC_TYPE CACHE)
  unset(PROFILE_${profile}_TARGET_PLATFORM_ABI CACHE)
  unset(PROFILE_${profile}_TARGET_DISTRIBUTION CACHE)
  unset(PROFILE_${profile}_TARGET_DISTRIBUTION_VERSION CACHE)
  unset(PROFILE_${profile}_DEFAULT_ENVIRONMENT CACHE)
  unset(PROFILE_${profile}_MORE_ENVIRONMENTS CACHE)
endfunction(remove_Profile)

#.rst:
#
# .. ifmode:: internal
#
#  .. |remove_Additional_Environment| replace:: ``remove_Additional_Environment``
#  .. _remove_Additional_Environment:
#
#  remove_Additional_Environment
#  ----------------------------
#
#   .. command:: remove_Additional_Environment(SUCCESS profile environment)
#
#      Removing an additional environment from a profile.
#
#      :profile: The name of the profile
#
#      :environment: The name of the target environment to be removed
#
#      :SUCCESS: The output variable that is TRUE if removal succeeded, FALSE otherwise
#
function(remove_Additional_Environment SUCCESS profile environment)
  set(tmp_lst ${PROFILE_${profile}_MORE_ENVIRONMENTS})
  list(FIND tmp_lst ${environment} INDEX)
  if(INDEX EQUAL -1)#does not exist
    set(${SUCCESS} FALSE PARENT_SCOPE)
    return()
  endif()
  list(REMOVE_ITEM tmp_lst ${environment})
  set(PROFILE_${profile}_MORE_ENVIRONMENTS ${tmp_lst} CACHE INTERNAL "")
  set(${SUCCESS} TRUE PARENT_SCOPE)
endfunction(remove_Additional_Environment)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Profiles| replace:: ``reset_Profiles``
#  .. _reset_Profiles:
#
#  reset_Profiles
#  --------------
#
#   .. command:: reset_Profiles()
#
#      Reset any information about user profiles and reload them from a profile list file.
#
macro(reset_Profiles)
  #situations to deal with:
  #- empty environments folder
  #- missing profile list file
  read_Profiles_Description_File(FILE_EXISTS)
  if(NOT PROFILES)#case at first configuration time just after a clone or if file has been removed manually
    add_Default_Profile()
  else()
    list(FIND PROFILES "default" INDEX)
    if(INDEX EQUAL -1)#default profile not present for any reason
      add_Default_Profile()
    endif()
  endif()

  set(dir ${WORKSPACE_DIR}/pid/${CURRENT_PROFILE})

  if(NOT EXISTS ${dir}/Workspace_Info.cmake #check if the complete platform description exists for current profile (may have not been generated yet or may has been removed by hand)
     OR NOT EXISTS ${dir}/Workspace_Solution_File.cmake
     OR FORCE_CURRENT_PROFILE_EVALUATION) # explicit query to a reevaluation of the profile
    if(FORCE_CURRENT_PROFILE_EVALUATION)
      unset(FORCE_CURRENT_PROFILE_EVALUATION CACHE)
    endif()
    #need to reconfigure if not exist
    if(NOT EXISTS ${dir})
      file(MAKE_DIRECTORY ${dir})
    else()
      hard_Clean_Build_Folder(${dir})
    endif()

    set(full_solution_str "set(PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT} CACHE INTERNAL \"\")")
    # evaluate the main environment of the profile, then all additionnal environments
    if(NOT PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT STREQUAL "host")#need to reevaluate the main environment if profile is not haost default
      evaluate_Environment_From_Workspace(SUCCESS ${CURRENT_PROFILE} ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT} TRUE)#evaluate as main env
      if(SUCCESS)
        file(	READ ${WORKSPACE_DIR}/environments/${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}/build/PID_Environment_Solution_Info.cmake
              more_solution)
        set(full_solution_str "${full_solution_str}\n${more_solution}")
        if(EXISTS ${WORKSPACE_DIR}/environments/${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}/build/PID_Toolchain.cmake)
          file(	COPY ${WORKSPACE_DIR}/environments/${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}/build/PID_Toolchain.cmake
                DESTINATION ${dir})
        endif()
      elseif(IN_CI_PROCESS)# crash with an error since IN CI contraints on dev env MUST be fulfilled
        message(FATAL_ERROR "[PID] CRITICAL ERROR : cannot evaluate environment ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT} on current host, abort.")
      else()#reset to default profile
        set(CURRENT_PROFILE default CACHE INTERNAL "")
      endif()
    endif()
    fill_String_From_List(PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS RES_STR)
    set(full_solution_str "${full_solution_str}\nset(PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS ${RES_STR} CACHE INTERNAL \"\")")
    #whatever the profile all additionnal environments in use must be evaluated
    foreach(env IN LISTS PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS)
      evaluate_Environment_From_Workspace(SUCCESS ${CURRENT_PROFILE} ${env} FALSE)#evaluate as additionnal
      if(SUCCESS)
        file(	READ ${WORKSPACE_DIR}/environments/${env}/build/PID_Environment_Solution_Info.cmake
              temp_str)
        set(full_solution_str "${full_solution_str}\n${temp_str}")
      else()
        #remove the environment
        remove_Additional_Environment(SUCCESS ${CURRENT_PROFILE} ${env})
      endif()
    endforeach()

    # write the allow access for full solution description
    file(WRITE ${dir}/Workspace_Solution_File.cmake "${full_solution_str}")
  endif()


  # apply result of profile evaluation to the subfolder (reconfigure current project into subfolders)
  # then perform manage platform/plugins to detect all languages features and plugins (automatically done by rerun in subfolder)
  # need to set the definitions used in evalutaion of profile specific configuration
  set(args -DWORKSPACE_DIR=${WORKSPACE_DIR} -DIN_CI_PROCESS=${IN_CI_PROCESS} -DPACKAGE_BINARY_INSTALL_DIR=${PACKAGE_BINARY_INSTALL_DIR})
  include(${dir}/Workspace_Solution_File.cmake)#use the solution file to set global variables
  if(${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}_CROSSCOMPILATION)
    list(APPEND args -DPID_CROSSCOMPILATION=TRUE)
  endif()
  if(${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}_TARGET_INSTANCE)
    list(APPEND args -DPID_USE_INSTANCE_NAME=${${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}_TARGET_INSTANCE})
  endif()
  if(${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}_TARGET_PLATFORM)
    list(APPEND args -DPID_USE_TARGET_PLATFORM=${${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}_TARGET_PLATFORM})
  endif()
  if(${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}_TARGET_DISTRIBUTION)
    list(APPEND args -DPID_USE_DISTRIBUTION=${${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}_TARGET_DISTRIBUTION})
  endif()
  if(${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}_TARGET_DISTRIBUTION_VERSION)
    list(APPEND args -DPID_USE_DISTRIB_VERSION=${${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}_TARGET_DISTRIBUTION_VERSION})
  endif()

  # write the configuration file to memorize choices for next configuration (and for user editing)
  write_Profiles_Description_File()
  # write the configuration file to memorize at global scope (in pid folder) the global information on current profile
  write_Workspace_Profiles_Info_File()

  # configuring the CMake generator in use
  if(CMAKE_EXTRA_GENERATOR)
    set(generator_name "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else()
    set(generator_name "${CMAKE_GENERATOR}")
  endif()
  list(APPEND args -G "${generator_name}")#use same generator as the one used at higher workspace level

  if(EXISTS ${dir}/PID_Toolchain.cmake)
    list(APPEND args -DCMAKE_TOOLCHAIN_FILE=${dir}/PID_Toolchain.cmake)
  endif()

  # reconfigure the pid workspace:
  # - preloading cache for all PID specific variables (-C option of cmake)
  # - using a toolchain file to configure build toolchain (-DCMAKE_TOOLCHAIN_FILE= option).
  if(ADDITIONNAL_DEBUG_INFO)
    set(subcommand_option)
  else()
    set(subcommand_option OUTPUT_QUIET ERROR_QUIET)
  endif()
  execute_process(COMMAND ${CMAKE_COMMAND}
                  ${args}
                  ../..
                  WORKING_DIRECTORY ${dir}
                  ${subcommand_option}
  )

  # get platform description from profile specific configuration
  if(EXISTS ${dir}/Platform_Description.txt)
    file(READ ${dir}/Platform_Description.txt DESCRIPTION_FILE)
    message("${DESCRIPTION_FILE}")
  endif()
endmacro(reset_Profiles)



#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Environment_From_Workspace| replace:: ``evaluate_Environment_From_Workspace``
#  .. _evaluate_Environment_From_Workspace:
#
#  evaluate_Environment_From_Workspace
#  -----------------------------------
#
#   .. command:: evaluate_Environment_From_Workspace(RESULT profile environment is_default)
#
#      Evaluate an environment used into a profile
#
#     :profile: the name of the profile being evaluated
#
#     :environment: the name of the environment to evaluate
#
#     :is_default: if TRUE the environment will be evaluated as default environment for the profile, otherwise it will be evaluated as an additionnal environment
#
#     :RESULT: The result variable that is TRUE if environment has been correctly evaluated, false otherwise
#
function(evaluate_Environment_From_Workspace RESULT profile environment is_default)
  set(${RESULT} FALSE PARENT_SCOPE)
  # 1. load the environment into current context
	load_Environment(IS_LOADED ${environment})
	if(NOT IS_LOADED)
		message("[PID] ERROR : environment ${environment} is unknown in workspace, or cannot be installed due to connection problems or permission issues.")
		return()
	endif()

	# 2. evaluate the environment with current call context
	# Warning: the generator in use may be forced by the environment, this later has priority over user defined one.
	# Warning: the sysroot in use may be forced by the user, so the sysroot passed by user has always priority over those defined by environments.
	# Warning: the staging in use may be forced by the user, so the staging passed by user has always priority over those defined by environments.

  evaluate_Environment_From_Script(EVAL_OK ${environment}
          "${PROFILE_${profile}_TARGET_INSTANCE}"
          "${PROFILE_${profile}_TARGET_SYSROOT}"
          "${PROFILE_${profile}_TARGET_STAGING}"
          "${PROFILE_${profile}_TARGET_PLATFORM_PROC_TYPE}"
          "${PROFILE_${profile}_TARGET_PLATFORM_PROC_ARCH}"
          "${PROFILE_${profile}_TARGET_PLATFORM_OS}"
          "${PROFILE_${profile}_TARGET_PLATFORM_ABI}"
          "${PROFILE_${profile}_TARGET_DISTRIBUTION}"
          "${PROFILE_${profile}_TARGET_DISTRIBUTION_VERSION}")
	if(NOT EVAL_OK)
    message("[PID] ERROR : cannot evaluate environment ${environment} on current host. Aborting workspace configuration.")
		return()
	endif()
  set(${RESULT} TRUE PARENT_SCOPE)
endfunction(evaluate_Environment_From_Workspace)


#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins| replace:: ``manage_Plugins``
#  .. _manage_Plugins:
#
#  manage_Plugins
#  --------------
#
#   .. command:: manage_Plugins()
#
#      Prepare plugins files to be usable by packages depending on current profile in use
#
function(manage_Plugins)
  set(list_before_deps)
  set(list_before_comps)
  set(list_during_comps)
  set(list_after_comps)
  if(NOT EXISTS ${CMAKE_BINARY_DIR}/Workspace_Solution_File.cmake)
    message(FATAL_ERROR "[PID] CRITICAL ERROR: file ${CMAKE_BINARY_DIR}/Workspace_Solution_File.cmake cannot be found ! Aborting.")
  endif()
  if(NOT PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT STREQUAL "host")#host environment defines no plugin
    extract_Plugins_From_Environment(BEFORE_DEPS BEFORE_COMPS DURING_COMPS AFTER_COMPS ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT})
    list(APPEND list_before_deps ${BEFORE_DEPS})
    list(APPEND list_before_comps ${BEFORE_COMPS})
    list(APPEND list_during_comps ${DURING_COMPS})
    list(APPEND list_after_comps ${AFTER_COMPS})
  endif()
  foreach(env IN LISTS PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS)#additionnal environments may define plugins
    extract_Plugins_From_Environment(BEFORE_DEPS BEFORE_COMPS DURING_COMPS AFTER_COMPS ${env})
    list(APPEND list_before_deps ${BEFORE_DEPS})
    list(APPEND list_before_comps ${BEFORE_COMPS})
    list(APPEND list_during_comps ${DURING_COMPS})
    list(APPEND list_after_comps ${AFTER_COMPS})
  endforeach()
  if(EXISTS ${CMAKE_BINARY_DIR}/plugins)
    file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/plugins)
  endif()
  if(list_before_deps OR list_before_comps OR list_during_comps OR list_after_comps)
    set(count 0)
    #generate the set of files used into packages to activate plugins
    set(path_to_plug_before_deps ${CMAKE_BINARY_DIR}/plugins/before_deps)
    if(NOT EXISTS ${path_to_plug_before_deps})
      file(MAKE_DIRECTORY ${path_to_plug_before_deps})
    endif()
    set(path_to_plug_before_comps ${CMAKE_BINARY_DIR}/plugins/before_comps)
    if(NOT EXISTS ${path_to_plug_before_comps})
      file(MAKE_DIRECTORY ${path_to_plug_before_comps})
    endif()
    set(path_to_plug_during_comps ${CMAKE_BINARY_DIR}/plugins/during_comps)
    if(NOT EXISTS ${path_to_plug_during_comps})
      file(MAKE_DIRECTORY ${path_to_plug_during_comps})
    endif()
    set(path_to_plug_after_comps ${CMAKE_BINARY_DIR}/plugins/after_comps)
    if(NOT EXISTS ${path_to_plug_after_comps})
      file(MAKE_DIRECTORY ${path_to_plug_after_comps})
    endif()

    set(count 0)
    foreach(plugin IN LISTS list_before_deps)
      get_filename_component(PLUGIN_NAME ${plugin} NAME)
  		file(COPY ${plugin} DESTINATION ${path_to_plug_before_deps})
      file(RENAME ${path_to_plug_before_deps}/${PLUGIN_NAME} ${path_to_plug_before_deps}/${count}.cmake)
      math(EXPR count "${count}+1")
  	endforeach()
    set(count 0)
    foreach(plugin IN LISTS list_before_comps)
      get_filename_component(PLUGIN_NAME ${plugin} NAME)
  		file(COPY ${plugin} DESTINATION ${path_to_plug_before_comps})
      file(RENAME ${path_to_plug_before_comps}/${PLUGIN_NAME} ${path_to_plug_before_comps}/${count}.cmake)
      math(EXPR count "${count}+1")
  	endforeach()
    set(count 0)
    foreach(plugin IN LISTS list_during_comps)
      get_filename_component(PLUGIN_NAME ${plugin} NAME)
  		file(COPY ${plugin} DESTINATION ${path_to_plug_during_comps})
      file(RENAME ${path_to_plug_during_comps}/${PLUGIN_NAME} ${path_to_plug_during_comps}/${count}.cmake)
      math(EXPR count "${count}+1")
  	endforeach()
    set(count 0)
    foreach(plugin IN LISTS list_after_comps)
      get_filename_component(PLUGIN_NAME ${plugin} NAME)
  		file(COPY ${plugin} DESTINATION ${path_to_plug_after_comps})
      file(RENAME ${path_to_plug_after_comps}/${PLUGIN_NAME} ${path_to_plug_after_comps}/${count}.cmake)
      math(EXPR count "${count}+1")
  	endforeach()
  endif()
endfunction(manage_Plugins)


#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_Plugins_From_Environment| replace:: ``extract_Plugins_From_Environment``
#  .. _extract_Plugins_From_Environment:
#
#  extract_Plugins_From_Environment
#  --------------------------------
#
#   .. command:: extract_Plugins_From_Environment(BEFORE_DEPS BEFORE_COMPS AFTER_COMPS environment)
#
#      Get the list of path to files used to implement plugins behavior
#
#     :environment: the name of the environment defining the plugin
#     :BEFORE_DEPS: the output variable containing the list of path to the CMake script files defining plugin behavior to be activated before description of dependencies of a package
#     :BEFORE_COMPS: the output variable containing the list of path to the CMake script files defining plugin behavior to be activated before description of components of a package
#     :DURING_COMPS: the output variable containing the list of path to the CMake script files defining plugin behavior to be activated during description of components of a package
#     :AFTER_COMPS: the output variable containing the list of path to the CMake script files defining plugin behavior to be activated after description of components of a package
#
function(extract_Plugins_From_Environment BEFORE_DEPS BEFORE_COMPS DURING_COMPS AFTER_COMPS environment)
   set(path_to_env ${WORKSPACE_DIR}/environments/${environment})
   set(res_bef_deps)
   set(res_bef_comps)
   set(res_during_comps)
   set(res_aft_comps)
   if(NOT EXISTS ${path_to_env})#check that te environment exist because we need to copy scripts from its content
     load_Environment(LOADED ${environment})
     if(NOT LOADED)
       message(FATAL_ERROR "[PID] CRITICAL ERROR: cannot find or deploy environment ${environment}. This is probably due to a badly referenced environment or it is contained in a contribution space not currenlty used.")
       return()
     endif()
   endif()
   foreach(tool IN LISTS ${environment}_EXTRA_TOOLS)
     if(${environment}_EXTRA_${tool}_PLUGIN_BEFORE_DEPENDENCIES)
       list(APPEND res_bef_deps ${${environment}_EXTRA_${tool}_PLUGIN_BEFORE_DEPENDENCIES})
     endif()
     if(${environment}_EXTRA_${tool}_PLUGIN_BEFORE_COMPONENTS)
       list(APPEND res_bef_comps ${${environment}_EXTRA_${tool}_PLUGIN_BEFORE_COMPONENTS})
     endif()
     if(${environment}_EXTRA_${tool}_PLUGIN_DURING_COMPONENTS)
       list(APPEND res_during_comps ${${environment}_EXTRA_${tool}_PLUGIN_DURING_COMPONENTS})
     endif()
     if(${environment}_EXTRA_${tool}_PLUGIN_AFTER_COMPONENTS)
       list(APPEND res_aft_comps ${${environment}_EXTRA_${tool}_PLUGIN_AFTER_COMPONENTS})
     endif()
   endforeach()
   if(res_bef_deps)
     list(REMOVE_DUPLICATES res_bef_deps)
   endif()
   if(res_bef_comps)
     list(REMOVE_DUPLICATES res_bef_comps)
   endif()
   if(res_during_comps)
     list(REMOVE_DUPLICATES res_during_comps)
   endif()
   if(res_aft_comps)
     list(REMOVE_DUPLICATES res_aft_comps)
   endif()
   set(${BEFORE_DEPS} ${res_bef_deps} PARENT_SCOPE)
   set(${BEFORE_COMPS} ${res_bef_comps} PARENT_SCOPE)
   set(${DURING_COMPS} ${res_during_comps} PARENT_SCOPE)
   set(${AFTER_COMPS} ${res_aft_comps} PARENT_SCOPE)
endfunction(extract_Plugins_From_Environment)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Language_Configuration| replace:: ``check_Language_Configuration``
#  .. _check_Language_Configuration:
#
#  check_Language_Configuration
#  --------------------------
#
#   .. command:: check_Language_Configuration(RESULT NAME CONSTRAINTS lang mode)
#
#    Check whether the given langauge constraint (= configruation name + arguments) conforms to current build environment.
#
#     :lang: the language check expression (may contain arguments).
#
#     :mode: the current build mode.
#
#     :RESULT: the output variable that is TRUE langauge constraints is satisfied by current platform.
#
#     :NAME: the output variable that contains the name of the language without arguments.
#
#     :CONSTRAINTS: the output variable that contains the constraints that applmy to the language once used. It includes arguments (constraints imposed by user) and generated contraints (constraints automatically defined by the language itself once used).
#
function(check_Language_Configuration RESULT NAME CONSTRAINTS lang mode)
  parse_Configuration_Expression(LANG_NAME LANG_ARGS "${lang}")
  if(NOT LANG_NAME)
    set(${NAME} PARENT_SCOPE)
    set(${CONSTRAINTS} PARENT_SCOPE)
    set(${RESULT} FALSE PARENT_SCOPE)
    message("[PID] CRITICAL ERROR : language check ${lang} is ill formed.")
    return()
  endif()
  check_Language_Configuration_With_Arguments(RESULT_WITH_ARGS BINARY_CONSTRAINTS ${LANG_NAME} LANG_ARGS ${mode})
  set(${NAME} ${LANG_NAME} PARENT_SCOPE)
  set(${RESULT} ${RESULT_WITH_ARGS} PARENT_SCOPE)
  # last step consist in generating adequate expressions for constraints
  generate_Configuration_Expression_Parameters(LIST_OF_CONSTRAINTS ${LANG_NAME} "${BINARY_CONSTRAINTS}")
  set(${CONSTRAINTS} ${LIST_OF_CONSTRAINTS} PARENT_SCOPE)
endfunction(check_Language_Configuration)


#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Language_Configuration_With_Arguments| replace:: ``check_Language_Configuration_With_Arguments``
#  .. _check_Language_Configuration_With_Arguments:
#
#  check_Language_Configuration_With_Arguments
#  -------------------------------------------
#
#   .. command:: check_Language_Configuration_With_Arguments(CHECK_OK BINARY_CONTRAINTS lang_name lang_args mode)
#
#    Check whether the given configuration constraint (= configruation name + arguments) conforms to target platform.
#
#     :lang_name: the name of the language (without argument).
#
#     :lang_args: the constraints passed as arguments by the user of the language.
#
#     :mode: the current build mode.
#
#     :CHECK_OK: the output variable that is TRUE language constraints are satisfied by current build environment.
#
#     :BINARY_CONTRAINTS: the output variable that contains the list of all parameter (constraints coming from argument or generated by the language itself) to use whenever the language is used.
#
function(check_Language_Configuration_With_Arguments CHECK_OK BINARY_CONTRAINTS lang_name lang_args mode)
  set(${BINARY_CONTRAINTS} PARENT_SCOPE)
  set(${CHECK_OK} FALSE PARENT_SCOPE)
  if(NOT ${lang_name}_Language_AVAILABLE)
    return()#if language is not available in the current build environment, simply stop
  endif()

  #check if the language configuration has already been checked
  check_Configuration_Temporary_Optimization_Variables(RES_CHECK RES_CONSTRAINTS ${lang_name} ${mode})
  if(RES_CHECK)
    if(${lang_args})#testing if the variable containing arguments is not empty
      #in this situation we need to check if all args match constraints
      check_Configuration_Arguments_Included_In_Constraints(INCLUDED ${lang_args} ${RES_CONSTRAINTS})
      if(INCLUDED)#no need to evaluate again
        set(${CHECK_OK} ${${RES_CHECK}} PARENT_SCOPE)
        set(${BINARY_CONTRAINTS} ${${RES_CONSTRAINTS}} PARENT_SCOPE)
        return()
      endif()
    else()#we may not need to reevaluate as there is no argument (so they will not change)
      set(${CHECK_OK} ${${RES_CHECK}} PARENT_SCOPE)
      set(${BINARY_CONTRAINTS} ${${RES_CONSTRAINTS}} PARENT_SCOPE)
      return()
    endif()
  endif()

  #from here we know we need to check more
  import_Language_Parameters(${lang_name})
  set(lang_constraints ${LANG_${lang_name}_OPTIONAL_CONSTRAINTS} ${LANG_${lang_name}_IN_BINARY_CONSTRAINTS})
  if(lang_constraints)
    list(REMOVE_DUPLICATES lang_constraints)
    prepare_Configuration_Expression_Arguments(${lang_name} ${lang_args} lang_constraints)
  endif()

  evaluate_Language_Configuration(${lang_name})
  if(NOT ${lang}_EVAL_RESULT)#language configuration cannot be satisfied
    set_Configuration_Temporary_Optimization_Variables(${lang_name} ${mode} FALSE "")
    return()
  endif()

  #return the complete set of binary contraints
  if(lang_constraints)
    get_Configuration_Expression_Resulting_Constraints(ALL_CONSTRAINTS ${lang_name} LANG_${lang_name}_IN_BINARY_CONSTRAINTS)
  endif()
  set(${BINARY_CONTRAINTS} ${ALL_CONSTRAINTS} PARENT_SCOPE)#automatic appending constraints generated by the configuration itself for the given binary package generated
  set(${CHECK_OK} TRUE PARENT_SCOPE)
  set_Configuration_Temporary_Optimization_Variables(${lang_name} ${mode} TRUE "${ALL_CONSTRAINTS}")
endfunction(check_Language_Configuration_With_Arguments)

#.rst:
#
# .. ifmode:: internal
#
#  .. |import_Language_Parameters| replace:: ``import_Language_Parameters``
#  .. _import_Language_Parameters:
#
#  import_Language_Parameters
#  --------------------------
#
#   .. command:: import_Language_Parameters(lang)
#
#    import in current context the language specific parameters that can be used as constraints in language configuration expression.
#
#     :lang: the target language.
#
macro(import_Language_Parameters lang)
  if(EXISTS ${WORKSPACE_DIR}/cmake/platforms/eval/params_${lang}.cmake)
    include(${WORKSPACE_DIR}/cmake/platforms/eval/params_${lang}.cmake)
  endif()
endmacro(import_Language_Parameters)

#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Language_Configuration| replace:: ``evaluate_Language_Configuration``
#  .. _evaluate_Language_Configuration:
#
#  evaluate_Language_Configuration
#  -------------------------------
#
#   .. command:: evaluate_Language_Configuration(lang)
#
#    evaluate a language configuration expression.
#
#     :lang: the target language.
#
macro(evaluate_Language_Configuration lang)
  set(${lang}_EVAL_RESULT FALSE)
  if(EXISTS ${WORKSPACE_DIR}/cmake/platforms/eval/eval_${lang}.cmake)
    include(${WORKSPACE_DIR}/cmake/platforms/eval/eval_${lang}.cmake)
  endif()
endmacro(evaluate_Language_Configuration)


#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Language_Toolset| replace:: ``check_Language_Toolset``
#  .. _check_Language_Toolset:
#
#  check_Language_Toolset
#  ----------------------
#
#   .. command:: check_Language_Toolset(RESULT lang toolset mode)
#
#    Check whether the given langauge toolset is available and if yes, set the environment adequately.
#
#     :lang: the language for which a specific toolset is required.
#
#     :toolset: the environment configuration expression defining the toolset to use.
#
#     :mode: the current build mode.
#
#     :RESULT: the output variable that is TRUE if language toolset is configured for current package or wrapper.
#
function(check_Language_Toolset RESULT lang toolset mode)
  parse_Configuration_Expression(TS_NAME TS_ARGS "${toolset}")
  if(NOT TS_NAME)
    set(${RESULT} FALSE PARENT_SCOPE)
    message("[PID] CRITICAL ERROR : language toolset check ${toolset} is ill formed.")
    return()
  endif()
  check_Language_Toolset_Configuration_With_Arguments(RESULT_WITH_ARGS ${lang} ${TS_NAME} TS_ARGS ${mode})
  set(${RESULT} ${RESULT_WITH_ARGS} PARENT_SCOPE)
endfunction(check_Language_Toolset)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Language_Toolset_Configuration_With_Arguments| replace:: ``check_Language_Toolset_Configuration_With_Arguments``
#  .. _check_Language_Toolset_Configuration_With_Arguments:
#
#  check_Language_Toolset_Configuration_With_Arguments
#  ---------------------------------------------------
#
#   .. command:: check_Language_Toolset_Configuration_With_Arguments(CHECK_OK lang_name lang_args mode)
#
#    Check whether the given build environment provide the target language toolset.
#
#     :lang_name: the name of the language.
#
#     :toolset_name: the name of the language tooolset (without argument).
#
#     :toolset_args: the constraints passed as arguments by the user of the toolset (typically version).
#
#     :mode: the current build mode.
#
#     :CHECK_OK: the output variable that is TRUE if language toolset constraints are satisfied by current build environment.
#
function(check_Language_Toolset_Configuration_With_Arguments CHECK_OK lang_name toolset_name toolset_args mode)
  set(${CHECK_OK} FALSE PARENT_SCOPE)

  #check if the language configuration has already been checked
  check_Configuration_Temporary_Optimization_Variables(RES_CHECK RES_CONSTRAINTS ${toolset_name} ${mode})
  if(RES_CHECK)
    if(${toolset_args})#testing if the variable containing arguments is not empty
      #in this situation we need to check if all args match constraints
      check_Configuration_Arguments_Included_In_Constraints(INCLUDED ${toolset_args} ${RES_CONSTRAINTS})
      if(INCLUDED)#no need to evaluate again
        set(${CHECK_OK} ${${RES_CHECK}} PARENT_SCOPE)
        return()
      endif()
    else()#we may not need to reevaluate as there is no argument (so they will not change)
      set(${CHECK_OK} ${${RES_CHECK}} PARENT_SCOPE)
      return()
    endif()
  endif()

  #if code pass here we have to (re)evaluate the toolset configuration
  if(NOT EXISTS ${WORKSPACE_DIR}/environments/${toolset_name})
    # Note : if environment does not exists it means:
    # 1) there is no chance for it to have been used in current profile
    # 2) we have no chance to find its check script
    # Consequence: immediately force its deployment if possible
    deploy_Environment_Repository(IS_DEPLOYED ${toolset_name})
    if(NOT IS_DEPLOYED)
      set_Configuration_Temporary_Optimization_Variables(${toolset_name} ${mode} FALSE "${RES_CONSTRAINTS}")#remember that test failed with those constraints
      return()
    endif()
  endif()
  if(NOT EXISTS ${WORKSPACE_DIR}/environments/${toolset_name}/build/PID_Inputs.cmake)
    # Note : if environment does not have an inputs description file, it means it has never been generated
    # 1) there is no chance for it to have been used in current profile
    # 2) we have no chance to find its check script
    # 1.1 configure environment
    generate_Environment_Inputs_File(FILE_EXISTS ${toolset_name})
    # 1.2 import variable description file
    if(NOT FILE_EXISTS)
      set_Configuration_Temporary_Optimization_Variables(${toolset_name} ${mode} FALSE "${RES_CONSTRAINTS}")#remember that test failed with those constraints
      return()
    endif()
  endif()

  # from here environment defining the toolset at least exists in workspace and provides a description
  # Note: it can be unused in current environment BUT it can also be IMPLICITLY used in the default host environment
  include(${WORKSPACE_DIR}/environments/${toolset_name}/build/PID_Inputs.cmake)
  prepare_Configuration_Expression_Arguments(${toolset_name} ${toolset_args} ${toolset_name}_INPUTS)
  evaluate_Language_Toolset_Configuration(RES ${lang_name} ${toolset_name})
  if(NOT RES)#language configuration cannot be satisfied
    set_Configuration_Temporary_Optimization_Variables(${toolset_name} ${mode} FALSE "${RES_CONSTRAINTS}")#remember that test failed with those constraints
    return()
  endif()

  #return the complete set of binary contraints
  set(${CHECK_OK} TRUE PARENT_SCOPE)
  set_Configuration_Temporary_Optimization_Variables(${toolset_name} ${mode} TRUE "${RES_CONSTRAINTS}")#remember that test failed with those constraints
endfunction(check_Language_Toolset_Configuration_With_Arguments)

#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Language_Toolset_Configuration| replace:: ``evaluate_Language_Toolset_Configuration``
#  .. _evaluate_Language_Toolset_Configuration:
#
#  evaluate_Language_Toolset_Configuration
#  ---------------------------------------
#
#   .. command:: evaluate_Language_Toolset_Configuration(lang toolset)
#
#    evaluate a language toolset configuration expression. If test successful the toolset is configured to be used with that language in current project.
#
#     :lang: the target language.
#
#     :toolset: the target toolset for this language.
#
function(evaluate_Language_Toolset_Configuration RESULT lang toolset)
  set(${RESULT} FALSE PARENT_SCOPE)
  #first check is only for testing if current toolset is not already OK
  include(${WORKSPACE_DIR}/environments/${toolset}/build/PID_Environment_Solution_Info.cmake)
  if(NOT ${toolset}_CHECK)# no check script defined so cannot evaluate if current build env config is OK
    return()
  endif()
  include(${${toolset}_CHECK})
  if(ENVIRONMENT_CHECK_RESULT)
    set(${RESULT} TRUE PARENT_SCOPE)
    return()
  endif()
  #from here check is not successfull so build env need to be reconfigured by using an available additional toolset
  if(NOT PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT STREQUAL "host")
    evaluate_Toolset_From_Environment(IS_OK ${lang} ${toolset} ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT})
    if(IS_OK)
      set(${RESULT} TRUE PARENT_SCOPE)
      return()
    endif()
  endif()
  foreach(env IN LISTS PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS)
    evaluate_Toolset_From_Environment(IS_OK ${lang} ${toolset} ${env})
    if(IS_OK)
      set(${RESULT} TRUE PARENT_SCOPE)
      return()
    endif()
  endforeach()
  # from here there is no known solution due to constraint (probably version)
  # need to generate another solution for same toolset in current profile
  # => simply evaluate it, it will overwrite global profiles info if required
  evaluate_Environment_From_Package(EVAL_OK ${toolset})
  if(NOT EVAL_OK)
    return()
  endif()

  use_Language_Toolset(${lang} ${toolset}_${lang}_TOOLSET_0)#always toolset 0 since added or overwrite more environments
endfunction(evaluate_Language_Toolset_Configuration)


#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Toolset_From_Environment| replace:: ``evaluate_Toolset_From_Environment``
#  .. _evaluate_Toolset_From_Environment:
#
#  evaluate_Toolset_From_Environment
#  ---------------------------------
#
#   .. command:: evaluate_Toolset_From_Environment( RES_OK lang toolset environment_in_solution)
#
#    Check whether the given build environment provide the target language toolset.
#
#     :lang: the name of the language
#
#     :toolset: the name of the toolset.
#
#     :environment: the environment defining the toolset.
#
#     :RES_OK: the output variable that is TRUE if language toolset constraints are satisfied by given build environment.
#
function(evaluate_Toolset_From_Environment RES_OK lang toolset environment)
  set(${RES_OK} FALSE PARENT_SCOPE)
  list(FIND ${environment}_LANGUAGES ${lang} INDEX)
  if(INDEX EQUAL -1)
    return()
  endif()
  math(EXPR max_index "${${environment}_${lang}_TOOLSETS}-1")
  foreach(index RANGE ${max_index})
    check_Tool_Expression(EXPRESSION_MATCH_REQUIRED ${toolset} ${${environment}_${lang}_TOOLSET_${index}_CONSTRAINT_EXPRESSION})
    if(EXPRESSION_MATCH_REQUIRED)
      use_Language_Toolset(${environment}_${lang}_TOOLSET_${index})
      set(${RES_OK} TRUE PARENT_SCOPE)
      return()
    endif()
  endforeach()
endfunction(evaluate_Toolset_From_Environment)

#.rst:
#
# .. ifmode:: internal
#
#  .. |use_Language_Toolset| replace:: ``use_Language_Toolset``
#  .. _use_Language_Toolset:
#
#  use_Language_Toolset
#  --------------------
#
#   .. command:: use_Language_Toolset(lang toolset_prefix_in_solution)
#
#    set the global CMake language related compilation variables of the current project from profile variables.
#
#     :lang: the name of the language
#
#     :toolset_prefix_in_solution: prefix of the toolset in CMake variables defining the profile.
#
function(use_Language_Toolset lang toolset_prefix_in_solution)
  if(${toolset_prefix_in_solution}_COMPILER)
    file(APPEND ${PACKAGE_SPECIFIC_BUILD_INFO_FILE} "set(CMAKE_${lang}_COMPILER ${${toolset_prefix_in_solution}_COMPILER} CACHE INTERNAL \"\" FORCE)\n")
    if(${toolset_prefix_in_solution}_COMPILER_ID)
      file(APPEND ${PACKAGE_SPECIFIC_BUILD_INFO_FILE} "set(CMAKE_${lang}_COMPILER_ID ${${toolset_prefix_in_solution}_COMPILER_ID} CACHE INTERNAL \"\" FORCE)\n")
    endif()
    if(${toolset_prefix_in_solution}_COMPILER_RANLIB)
      file(APPEND ${PACKAGE_SPECIFIC_BUILD_INFO_FILE} "set(CMAKE_${lang}_COMPILER_RANLIB ${${toolset_prefix_in_solution}_COMPILER_RANLIB} CACHE INTERNAL \"\" FORCE)\n")
    endif()
    if(${toolset_prefix_in_solution}_COMPILER_AR)
      file(APPEND ${PACKAGE_SPECIFIC_BUILD_INFO_FILE} "set(CMAKE_${lang}_COMPILER_AR ${${toolset_prefix_in_solution}_COMPILER_AR} CACHE INTERNAL \"\" FORCE)\n")
    endif()
  endif()
  if(${toolset_prefix_in_solution}_HOST_COMPILER)
    file(APPEND ${PACKAGE_SPECIFIC_BUILD_INFO_FILE} "set(CMAKE_${lang}_HOST_COMPILER ${${toolset_prefix_in_solution}_HOST_COMPILER} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${toolset_prefix_in_solution}_COMPILER_FLAGS)
    file(APPEND ${PACKAGE_SPECIFIC_BUILD_INFO_FILE} "set(CMAKE_${lang}_COMPILER_FLAGS ${${toolset_prefix_in_solution}_COMPILER_FLAGS} CACHE INTERNAL \"\" FORCE)\n")
  endif()
endfunction(use_Language_Toolset)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Extra_Tool_Configuration| replace:: ``check_Extra_Tool_Configuration``
#  .. _check_Extra_Tool_Configuration:
#
#  check_Extra_Tool_Configuration
#  -------------------------------
#
#   .. command:: check_Extra_Tool_Configuration(RESULT CONFIG_CONSTRAINTS tool mode)
#
#    Check whether the current build profile provides the corresponding tool.
#
#     :tool: the environment extra tool check expression (may contain arguments).
#
#     :mode: the current build mode.
#
#     :RESULT: the output variable that is TRUE environment constraints is satisfied by current build environment.
#
#     :CONFIG_CONSTRAINTS: the output variable that contains the platform configuration constraints that may be required by the environment. This is a list of check expressions.
#
function(check_Extra_Tool_Configuration RESULT CONFIG_CONSTRAINTS tool mode)
  # find_Mathing_Tool_In_Current_Profile(TOOL_PREFIX ${tool})
  parse_Configuration_Expression(TOOL_NAME TOOL_ARGS "${tool}")
  if(NOT TOOL_NAME)
    set(${RESULT} FALSE PARENT_SCOPE)
    set(${CONFIG_CONSTRAINTS} PARENT_SCOPE)
    message("[PID] CRITICAL ERROR : extra toolset check ${tool} is ill formed.")
    return()
  endif()
  add_Required_Extra_Tool(${TOOL_NAME})
  check_Extra_Tool_Configuration_With_Arguments(RESULT_WITH_ARGS CONSTRAINTS ${TOOL_NAME} TOOL_ARGS ${mode})
  set(${RESULT} ${RESULT_WITH_ARGS} PARENT_SCOPE)
  set(${CONFIG_CONSTRAINTS} ${CONSTRAINTS} PARENT_SCOPE)
endfunction(check_Extra_Tool_Configuration)


#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Extra_Tool_Configuration_With_Arguments| replace:: ``check_Extra_Tool_Configuration_With_Arguments``
#  .. _check_Extra_Tool_Configuration_With_Arguments:
#
#  check_Extra_Tool_Configuration_With_Arguments
#  ---------------------------------------------
#
#   .. command:: check_Extra_Tool_Configuration_With_Arguments(CHECK_OK lang_name lang_args mode)
#
#    Check whether the given build environment provide the target language toolset.
#
#     :tool: the name of the extra tool
#
#     :tool_args: the constraints passed as arguments by the user of the tool (typically version).
#
#     :mode: the current build mode.
#
#     :CHECK_OK: the output variable that is TRUE if language toolset constraints are satisfied by current build environment.
#
#     :CONFIGS: the output variable that contains the list of configruation constraints to check when using this tool.
#
function(check_Extra_Tool_Configuration_With_Arguments CHECK_OK CONFIGS tool tool_args mode)
  set(${CHECK_OK} FALSE PARENT_SCOPE)
  set(${CONFIGS} PARENT_SCOPE)
  #if code pass here we have to (re)evaluate the toolset configuration
  if(NOT EXISTS ${WORKSPACE_DIR}/environments/${tool})
    # Note : if environment does not exists it means:
    # 1) there is no chance for it to have been used in current profile
    # 2) we have no chance to find its check script
    # Consequence: immediately force its deployment if possible
    deploy_Environment_Repository(IS_DEPLOYED ${tool})
    if(NOT IS_DEPLOYED)
      return()
    endif()
  endif()
  if(NOT EXISTS ${WORKSPACE_DIR}/environments/${tool}/build/PID_Inputs.cmake)
    # Note : if environment does not have an inputs description file, it means it has never been generated
    # 1) there is no chance for it to have been used in current profile
    # 2) we have no chance to find its check script
    # 1.1 configure environment
    generate_Environment_Inputs_File(FILE_EXISTS ${tool})
    # 1.2 import variable description file
    if(NOT FILE_EXISTS)
      return()
    endif()
  endif()

  # from here environment defining the toolset at least exists in workspace and provides a description
  # Note: it can be unused in current environment BUT it can also be IMPLICITLY used in the default host environment
  include(${WORKSPACE_DIR}/environments/${tool}/build/PID_Inputs.cmake)
  prepare_Configuration_Expression_Arguments(${tool} ${tool_args} ${tool}_INPUTS)

  evaluate_Extra_Tool_Configuration(RES RES_CONFIGS ${tool})
  if(NOT RES)#language configuration cannot be satisfied
    return()
  endif()

  #return the complete set of binary contraints
  set(${CHECK_OK} TRUE PARENT_SCOPE)
  set(${CONFIGS} ${RES_CONFIGS} PARENT_SCOPE)
endfunction(check_Extra_Tool_Configuration_With_Arguments)


#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Tool_Expression| replace:: ``check_Tool_Expression``
#  .. check_Tool_Expression:
#
#  check_Tool_Expression
#  ---------------------
#
#   .. command:: check_Tool_Expression(COMPATIBLE tool tool_expression)
#
#    Check whether a constraint expression provided into a profile description is compatible with current constraints of a an extra tool or language toolset.
#
#     :tool: the name of the extra tool or language toolset
#
#     :tool_expression: the constraints expression to check against.
#
#     :COMPATIBLE: the output variable that is TRUE if tool_expression is compatible with tool constraints.
#
function(check_Tool_Expression COMPATIBLE tool tool_expression)
  set(${COMPATIBLE} FALSE PARENT_SCOPE)
  parse_Configuration_Expression(TOOL_NAME TOOL_ARGS "${tool_expression}")
  if(TOOL_NAME STREQUAL tool)
    prepare_Configuration_Expression_Arguments(temp_${tool} ${TOOL_ARGS} ${tool}_INPUTS)
    #getting toolset args coming from the local expression (i.e. package level constraint) into current context
    set(RESULT_VERS TRUE)# by default (no constraint required) result is OK
    set(RESULT_ARCH TRUE)# by default (no constraint required) result is OK
    if(${tool}_version)# a specific version is required
      check_Environment_Version(RESULT_VERS ${tool}_version "${${tool}_exact}" "${temp_${tool}_version}")
    endif()
    if(${tool}_architecture)# a specific architecture is required
      check_Environment_Architecture(RESULT_ARCH ${tool}_architecture "${temp_${tool}_architecture}")
    endif()
    if(RESULT_VERS AND RESULT_ARCH)
      set(${COMPATIBLE} TRUE PARENT_SCOPE)
      return()
    endif()
  endif()
endfunction(check_Tool_Expression)


#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Extra_Tool_In_Environment| replace:: ``evaluate_Extra_Tool_In_Environment``
#  .. _evaluate_Extra_Tool_In_Environment:
#
#  evaluate_Extra_Tool_In_Environment
#  ----------------------------------
#
#   .. command:: evaluate_Extra_Tool_In_Environment(RESULT CONFIGS_TO_CHECK tool environment)
#
#    Evaluate a specific extra tool if it is provided by a given environment.
#
#     :tool: the name of the extra tool
#
#     :environment: the name of the environment providing the tool.
#
#     :CHECK_OK: the output variable that is TRUE if language toolset constraints are satisfied by current build environment.
#
#     :CONFIGS_TO_CHECK: the output variable that contains the list of configuration constraints to check when using this tool.
#
function(evaluate_Extra_Tool_In_Environment RESULT CONFIGS_TO_CHECK tool environment)
  set(${RESULT} FALSE PARENT_SCOPE)
  set(${CONFIGS_TO_CHECK} PARENT_SCOPE)
  foreach(extra IN LISTS ${environment}_EXTRA_TOOLS)
    if(tool STREQUAL extra)
      check_Extra_Tool_Expression(EXPRESSION_MATCH_REQUIRED ${tool} ${${environment}_EXTRA_${tool}_CONSTRAINT_EXPRESSION})
      if(EXPRESSION_MATCH_REQUIRED)
        set(${CONFIGS_TO_CHECK} ${${environment}_EXTRA_${tool}_PLATFORM_CONFIGURATIONS} PARENT_SCOPE)
        set(${RESULT} TRUE PARENT_SCOPE)
        return()
      endif()
    endif()
  endforeach()
endfunction(evaluate_Extra_Tool_In_Environment)

#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Extra_Tool_Configuration| replace:: ``evaluate_Extra_Tool_Configuration``
#  .. _evaluate_Extra_Tool_Configuration:
#
#  evaluate_Extra_Tool_Configuration
#  ----------------------------------
#
#   .. command:: evaluate_Extra_Tool_Configuration(RES CONFIGS tool)
#
#    Evaluate an extra tool, if it is provided in current profile.
#
#     :tool: the contraint expression
#
#     :RES: the output variable that is TRUE if extra tool constraints are satisfied by current profile.
#
#     :CONFIGS: the output variable that contains the list of configuration constraints to check when using this tool.
#
function(evaluate_Extra_Tool_Configuration RES CONFIGS tool)
  set(${CHECK_OK} FALSE PARENT_SCOPE)
  set(${CONFIGS} PARENT_SCOPE)
  if(NOT PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT STREQUAL "host")
    evaluate_Extra_Tool_In_Environment(IS_OK RES_CONFIGS ${tool} ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT})
    if(IS_OK)
      set(${RESULT} TRUE PARENT_SCOPE)
      set(${CONFIGS} ${RES_CONFIGS} PARENT_SCOPE)
      return()
    endif()
  endif()
  foreach(env IN LISTS PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS)
    evaluate_Extra_Tool_In_Environment(IS_OK RES_CONFIGS ${tool} ${env})
    if(IS_OK)
      set(${RESULT} TRUE PARENT_SCOPE)
      set(${CONFIGS} ${RES_CONFIGS} PARENT_SCOPE)
      return()
    endif()
  endforeach()
  # from here there is no known solution due to constraint (probably version)
  # need to generate another solution for same toolset in current profile
  # => simply evaluate it, it will overwrite global profiles info if required
  evaluate_Environment_From_Package(EVAL_OK ${tool})
  if(NOT EVAL_OK)
    return()
  endif()
  evaluate_Extra_Tool_In_Environment(RESULT CONFIGS_TO_CHECK ${tool} ${tool})

  set(${RESULT} ${RESULT} PARENT_SCOPE)
  set(${CONFIGS} ${CONFIGS_TO_CHECK} PARENT_SCOPE)
endfunction(evaluate_Extra_Tool_Configuration)


#.rst:
#
# .. ifmode:: internal
#
#  .. |PID_Profile| replace:: ``PID_Profile``
#  .. _PID_Profile:
#
#  PID_Profile
#  ------------
#
#   .. command:: PID_Profile(NAME ... [OPTIONS...]])
#
#      Declare a profile in the profile list file.
#      Note: to be used only in profiles list file.
#
#      :NAME <string>: name of the profile (must be unique in the file).
#      :CURRENT: if specified, the profile is the one currently used.
#      :ENVIRONMENTS <list>: list of environments to use, the first element being considered as the default one. If none specified only host environemnt will be used.
#      :PLATFORM <string>: platform description string, may include also instance name. Alternatively the profile can impose more specifc constraints using other arguments.
#      :PROC_TYPE <string>: type of the processor (e.g. x86, arm).
#      :PROC_ARCH <string>: address type of the processor (32 or 64 bits).
#      :OS <string>: operating system of the platform (linux, freebsd, macos, windows).
#      :ABI <string>: ABI to use for C++ compilation ("abi98" or "abi11").
#      :INSTANCE <string>: instance name for target platform.
#      :DISTRIBUTION <string>: name of the operating system distribution.
#      :DISTRIBUTION_VERSION <version>: version of the distribution.
#
#      :SYSROOT <path>: path to the sysroot when crosscompiling.
#      :STAGING <path>: path to the staging area when crosscompiling.
#
function(PID_Profile)
  set(options CURRENT)
  set(oneValueArgs NAME SYSROOT STAGING INSTANCE PLATFORM OS PROC_ARCH PROC_TYPE ABI DISTRIBUTION DISTRIBUTION_VERSION)
  set(multiValueArgs ENVIRONMENTS)
  cmake_parse_arguments(PID_PROFILE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  if(NOT PID_PROFILE_NAME)
    message(FATAL_ERROR "[PID] CRITICAL ERROR: in PID_Profile, NAME of the profile must be defined.")
    return()
  endif()
  set(profile ${PID_PROFILE_NAME})

  if(NOT PID_PROFILE_ENVIRONMENTS)
    set(env "host")
    set(other_envs)
  else()
    set(temp_list ${PID_PROFILE_ENVIRONMENTS})
    list(GET temp_list 0 env)
    list(REMOVE_AT temp_list 0)
    set(other_envs "${temp_list}")
  endif()
  set(PROFILE_${profile}_DEFAULT_ENVIRONMENT ${env} CACHE INTERNAL "")
  set(PROFILE_${profile}_MORE_ENVIRONMENTS ${other_envs} CACHE INTERNAL "")

  if(NOT PROFILES)
    #first profile defined => becomes the default one to avoid any misdescription by user
    set(CURRENT_PROFILE ${profile} CACHE INTERNAL "")
  endif()
  append_Unique_In_Cache(PROFILES ${profile})
  if(PID_PROFILE_CURRENT)
    set(CURRENT_PROFILE ${profile}   CACHE INTERNAL "")
  endif()
  if(PID_PROFILE_PLATFORM)
    extract_Info_From_Platform(type arch os abi instance PLATFORM_BASE ${PID_PROFILE_PLATFORM})
  endif()
  if(PID_PROFILE_PROC_TYPE)
    set(type ${PID_PROFILE_PROC_TYPE})
  endif()
  if(PID_PROFILE_PROC_ARCH)
    set(arch ${PID_PROFILE_PROC_ARCH})
  endif()
  if(PID_PROFILE_OS)
    set(os ${PID_PROFILE_OS})
  endif()
  if(PID_PROFILE_ABI)
    set(abi ${PID_PROFILE_ABI})
  endif()
  if(PID_PROFILE_INSTANCE)
    set(instance ${PID_PROFILE_INSTANCE})
  endif()
  set(PROFILE_${profile}_TARGET_SYSROOT ${PID_PROFILE_SYSROOT} CACHE INTERNAL "")
  set(PROFILE_${profile}_TARGET_STAGING ${PID_PROFILE_STAGING} CACHE INTERNAL "")
  set(PROFILE_${profile}_TARGET_INSTANCE ${instance} CACHE INTERNAL "")
  set(PROFILE_${profile}_TARGET_PLATFORM_OS ${os} CACHE INTERNAL "")
  set(PROFILE_${profile}_TARGET_PLATFORM_PROC_TYPE ${type} CACHE INTERNAL "")
  set(PROFILE_${profile}_TARGET_PLATFORM_PROC_ARCH ${arch} CACHE INTERNAL "")
  set(PROFILE_${profile}_TARGET_PLATFORM_ABI ${abi} CACHE INTERNAL "")
  set(PROFILE_${profile}_TARGET_DISTRIBUTION ${PID_PROFILE_DISTRIBUTION} CACHE INTERNAL "")
  set(PROFILE_${profile}_TARGET_DISTRIBUTION_VERSION ${DISTRIBUTION_VERSION}  CACHE INTERNAL "")
endfunction(PID_Profile)