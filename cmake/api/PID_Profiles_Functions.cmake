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
  set(TEMP_PROFILES ${PROFILES} CACHE INTERNAL "")
  set(TEMP_CURRENT_PROFILE ${CURRENT_PROFILE} CACHE INTERNAL "")
  set(TEMP_CURRENT_GENERATOR ${CURRENT_GENERATOR} CACHE INTERNAL "")
  set(TEMP_CURRENT_GENERATOR_EXTRA ${CURRENT_GENERATOR_EXTRA} CACHE INTERNAL "")
  set(TEMP_CURRENT_GENERATOR_INSTANCE ${CURRENT_GENERATOR_INSTANCE} CACHE INTERNAL "")
  set(TEMP_CURRENT_GENERATOR_TOOLSET ${CURRENT_GENERATOR_TOOLSET} CACHE INTERNAL "")
  set(TEMP_CURRENT_GENERATOR_PLATFORM ${CURRENT_GENERATOR_PLATFORM} CACHE INTERNAL "")
  include(${WORKSPACE_DIR}/pid/Workspace_Profile_Info.cmake)
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
  file(WRITE ${target_file_path} "set(PROFILES ${PROFILES} CACHE INTERNAL \"\")\n")#reset file content and define all available profiles
  file(APPEND ${target_file_path} "set(CURRENT_PROFILE ${CURRENT_PROFILE} CACHE INTERNAL \"\")\n")
  #contribution spaces list is ordered from highest to lowest priority
  foreach(profile IN LISTS PROFILES)
    #all variables used to configrue all environments in use
    file(APPEND ${target_file_path} "set(PROFILE_${profile}_TARGET_SYSROOT ${PROFILE_${profile}_TARGET_SYSROOT} CACHE INTERNAL \"\")\n")
    file(APPEND ${target_file_path} "set(PROFILE_${profile}_TARGET_STAGING ${PROFILE_${profile}_TARGET_STAGING} CACHE INTERNAL \"\")\n")
    file(APPEND ${target_file_path} "set(PROFILE_${profile}_TARGET_INSTANCE ${PROFILE_${profile}_TARGET_INSTANCE} CACHE INTERNAL \"\")\n")
    file(APPEND ${target_file_path} "set(PROFILE_${profile}_TARGET_PLATFORM_OS ${PROFILE_${profile}_TARGET_PLATFORM_OS} CACHE INTERNAL \"\")\n")
    file(APPEND ${target_file_path} "set(PROFILE_${profile}_TARGET_PLATFORM_PROC_ARCH ${PROFILE_${profile}_TARGET_PLATFORM_PROC_ARCH} CACHE INTERNAL \"\")\n")
    file(APPEND ${target_file_path} "set(PROFILE_${profile}_TARGET_PLATFORM_PROC_TYPE ${PROFILE_${profile}_TARGET_PLATFORM_PROC_TYPE} CACHE INTERNAL \"\")\n")
    file(APPEND ${target_file_path} "set(PROFILE_${profile}_TARGET_PLATFORM_ABI ${PROFILE_${profile}_TARGET_PLATFORM_ABI} CACHE INTERNAL \"\")\n")
    file(APPEND ${target_file_path} "set(PROFILE_${profile}_TARGET_DISTRIBUTION ${PROFILE_${profile}_TARGET_DISTRIBUTION} CACHE INTERNAL \"\")\n")
    file(APPEND ${target_file_path} "set(PROFILE_${profile}_TARGET_DISTRIBUTION_VERSION ${PROFILE_${profile}_TARGET_DISTRIBUTION_VERSION} CACHE INTERNAL \"\")\n")
    file(APPEND ${target_file_path} "set(PROFILE_${profile}_DEFAULT_ENVIRONMENT ${PROFILE_${profile}_DEFAULT_ENVIRONMENT} CACHE INTERNAL \"\")\n")
    file(APPEND ${target_file_path} "set(PROFILE_${profile}_MORE_ENVIRONMENTS ${PROFILE_${profile}_MORE_ENVIRONMENTS} CACHE INTERNAL \"\")\n")
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
      append_Unique_In_Cache(PROFILE_${profile}_MORE_ENVIRONMENT ${ADD_MANAGED_PROFILE_ENVIRONMENT})#adding one more additionnal environment
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
  set(path_to_description_file ${WORKSPACE_DIR}/environments/profiles_list.cmake)
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

  if(CURRENT_PROFILE STREQUAL "default")
    message("[PID] INFO: using default profile, based on host native development environment.")
  else()
    message("[PID] INFO: using ${CURRENT_PROFILE} profile, based on ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT} as main development environment.")
  endif()
  if(PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS)
    message("      - additional environments in use are : ${PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS}")
  endif()
  set(dir ${WORKSPACE_DIR}/pid/${CURRENT_PROFILE})
  if(NOT EXISTS ${dir}/Workspace_Platforms_Info.cmake #check if the complete platform description exists for current profile (may have not been generated yet or may has been removed by hand)
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
    # evaluate the main environment of the profile, then all additionnal environments
    if(NOT PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT STREQUAL "host")#need to reevaluate the main environment if profile is not haost default
      evaluate_Environment_From_Workspace(SUCCESS ${CURRENT_PROFILE} ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT} TRUE)#evaluate as main env
      if(SUCCESS)
        file(	COPY ${WORKSPACE_DIR}/environments/${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}/build/PID_Environment_Description.cmake
              DESTINATION ${dir})
        if(EXISTS ${WORKSPACE_DIR}/environments/${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}/build/PID_Toolchain.cmake)
          file(	COPY ${WORKSPACE_DIR}/environments/${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}/build/PID_Toolchain.cmake
                DESTINATION ${dir})
        endif()
      else()#reset to default profile
        set(CURRENT_PROFILE default CACHE INTERNAL "")
      endif()
    endif()
    #whatever the profile all additionnal environments in use must be evaluated
    foreach(env IN LISTS PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS)
      evaluate_Environment_From_Workspace(SUCCESS ${CURRENT_PROFILE} ${env} FALSE)#evaluate as additionnal
      if(SUCCESS)
        file(	COPY ${WORKSPACE_DIR}/environments/${env}/build/PID_Environment_Solution_Info.cmake
              DESTINATION ${dir})
      else()
        #remove the environment
        remove_Additional_Environment(SUCCESS ${CURRENT_PROFILE} ${env})
      endif()
    endforeach()
  endif()

  # write the configuration file to memorize choices for next configuration (and for user editing)
  write_Profiles_Description_File()
  # write the configuration file to memorize at global scope (in pid folder) the global information on current environment
  write_Workspace_Profiles_Info_File()

  # apply result of environment evaluation to the subfolder (reconfigure current project into subfolders)
  # then perform manage platform/plugins to detect all languages features and plugins (automatically done by rerun in subfolder)
  set(args -DWORKSPACE_DIR=${WORKSPACE_DIR} -DIN_CI_PROCESS=${IN_CI_PROCESS} -DPACKAGE_BINARY_INSTALL_DIR=${PACKAGE_BINARY_INSTALL_DIR})
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
  if(EXISTS ${dir}/PID_Environment_Description.cmake)
    set(args -C${dir}/PID_Environment_Description.cmake ${args})#put the cache file first
  endif()

  # reconfigure the pid workspace:
  # - preloading cache for all PID specific variables (-C option of cmake)
  # - using a toolchain file to configure build toolchain (-DCMAKE_TOOLCHAIN_FILE= option).
  execute_process(COMMAND ${CMAKE_COMMAND}
                  ${args}
                  ../..
                  WORKING_DIRECTORY ${dir}
                  OUTPUT_QUIET
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
  set(list_before)
  set(list_after)
  if(NOT PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT STREQUAL "host")
    extract_Plugins_From_Environment(BEFORE_PLUGINS AFTER_PLUGINS ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT})
    list(APPEND list_before ${BEFORE_PLUGINS})
    list(APPEND list_after ${AFTER_PLUGINS})
  endif()
  foreach(env IN LISTS PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS)
    extract_Plugins_From_Environment(BEFORE_PLUGINS AFTER_PLUGINS ${env})
    list(APPEND list_before ${BEFORE_PLUGINS})
    list(APPEND list_after ${AFTER_PLUGINS})
  endforeach()
  if(EXISTS ${CMAKE_BINARY_DIR}/plugins)
    file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/plugins)
  endif()
  if(list_before OR list_after)
    list(REVERSE list_before)
    list(REVERSE list_after)
    set(count 0)
    #generate the set of files used into packages to activate plugins
    foreach(plugin IN LISTS list_before)
      get_filename_component(PLUGIN_NAME ${plugin} NAME)
  		file(COPY ${plugin} DESTINATION ${CMAKE_BINARY_DIR}/plugins/before)
      file(RENAME ${CMAKE_BINARY_DIR}/plugins/before/${PLUGIN_NAME} ${count}.cmake)
      math(EXPR count "${count}+1")
  	endforeach()
    set(count 0)
    foreach(plugin IN LISTS list_after)
      get_filename_component(PLUGIN_NAME ${plugin} NAME)
  		file(COPY ${plugin} DESTINATION ${CMAKE_BINARY_DIR}/plugins/after)
      file(RENAME ${CMAKE_BINARY_DIR}/plugins/after/${PLUGIN_NAME} ${count}.cmake)
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
#   .. command:: extract_Plugins_From_Environment()
#
#      Get the list of path to files used to implement plugins behavior
#
#     :environment: the name of the environment defining the plugin
#
#     :BEFORE_PLUGINS: the output variable containing the list of path to the CMake script files defining plugin behavior to be activated before configuration of package
#
#     :AFTER_PLUGINS: the output variable containing the list of path to the CMake script files defining plugin behavior to be activated after configuration of package
#
function(extract_Plugins_From_Environment BEFORE_PLUGINS AFTER_PLUGINS environment)

#TODO
endfunction(extract_Plugins_From_Environment)
