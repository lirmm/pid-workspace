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
if(PID_ENV_API_INTERNAL_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_ENV_API_INTERNAL_FUNCTIONS_INCLUDED TRUE)

########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Package_Cache_Management_Functions NO_POLICY_SCOPE)
include(PID_Deployment_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Version_Management_Functions NO_POLICY_SCOPE)
include(PID_Continuous_Integration_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Meta_Information_Management_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
include(PID_Contribution_Space_Functions NO_POLICY_SCOPE)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Environment_Description| replace:: ``reset_Environment_Description``
#  .. _reset_Environment_Description:
#
#  reset_Environment_Description
#  -----------------------------
#
#   .. command:: reset_Environment_Description()
#
#   Reset cache of the current environment project.
#
function(reset_Environment_Description)
  #### reset global descriptive information ####
  #reset constraints on platform
  set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_DEFINED CACHE INTERNAL "")
  set(${PROJECT_NAME}_ARCH_CONSTRAINT CACHE INTERNAL "")
  set(${PROJECT_NAME}_TYPE_CONSTRAINT CACHE INTERNAL "")
  set(${PROJECT_NAME}_OS_CONSTRAINT CACHE INTERNAL "")
  set(${PROJECT_NAME}_ABI_CONSTRAINT CACHE INTERNAL "")
  set(${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT CACHE INTERNAL "")
  set(${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT CACHE INTERNAL "")
  set(${PROJECT_NAME}_CONFIGURATION_CONSTRAINT CACHE INTERNAL "")
  set(${PROJECT_NAME}_CHECK CACHE INTERNAL "")

  #reset build environment description

  # reset constraint that can be used to parameterize the environment
  set(${PROJECT_NAME}_ENVIRONMENT_CONSTRAINTS_DEFINED CACHE INTERNAL "")
  set(${PROJECT_NAME}_OPTIONAL_CONSTRAINTS CACHE INTERNAL "")
  set(${PROJECT_NAME}_REQUIRED_CONSTRAINTS CACHE INTERNAL "")

  # reset environment solutions
  if(${PROJECT_NAME}_SOLUTIONS GREATER 0)
    math(EXPR max "${${PROJECT_NAME}_SOLUTIONS}-1")
    foreach(sol RANGE ${max})#clean the memory
      #reset all conditions for that solution
      set(${PROJECT_NAME}_SOLUTION_${sol}_ARCH CACHE INTERNAL "")
      set(${PROJECT_NAME}_SOLUTION_${sol}_TYPE CACHE INTERNAL "")
      set(${PROJECT_NAME}_SOLUTION_${sol}_OS CACHE INTERNAL "")
      set(${PROJECT_NAME}_SOLUTION_${sol}_ABI CACHE INTERNAL "")
      set(${PROJECT_NAME}_SOLUTION_${sol}_DISTRIBUTION CACHE INTERNAL "")
      set(${PROJECT_NAME}_SOLUTION_${sol}_DISTRIB_VERSION CACHE INTERNAL "")
      #reset known reactions if conditions are met
      set(${PROJECT_NAME}_SOLUTION_${sol}_CONFIGURE CACHE INTERNAL "")
      set(${PROJECT_NAME}_SOLUTION_${sol}_DEPENDENCIES CACHE INTERNAL "")
    endforeach()
  endif()
  set(${PROJECT_NAME}_SOLUTIONS "0" CACHE INTERNAL "")

  #### reset computed information for build ####
  #reset compiler settings issue from finding procedure
  foreach(lang IN ITEMS C CXX ASM Fortran CUDA)
    set(${PROJECT_NAME}_${lang}_COMPILER CACHE INTERNAL "")#full path to compiler in use
    set(${PROJECT_NAME}_${lang}_COMPILER_ID CACHE INTERNAL "")#full path to compiler in use
    set(${PROJECT_NAME}_${lang}_COMPILER_FLAGS CACHE INTERNAL "")#compiler flags
    if(lang STREQUAL "CUDA")
      set(${PROJECT_NAME}_${lang}_HOST_COMPILER CACHE INTERNAL "")
    else()
      set(${PROJECT_NAME}_${lang}_AR CACHE INTERNAL "")# compiler AR and RANLIB tools
      set(${PROJECT_NAME}_${lang}_RANLIB CACHE INTERNAL "")# compiler AR and RANLIB tools
    endif()
  endforeach()
  set(${PROJECT_NAME}_LINKER CACHE INTERNAL "")#full path to linker tool
  set(${PROJECT_NAME}_AR CACHE INTERNAL "")
  set(${PROJECT_NAME}_RANLIB CACHE INTERNAL "")
  set(${PROJECT_NAME}_NM CACHE INTERNAL "")
  set(${PROJECT_NAME}_OBJDUMP CACHE INTERNAL "")
  set(${PROJECT_NAME}_OBJCOPY CACHE INTERNAL "")
  set(${PROJECT_NAME}_EXE_LINKER_FLAGS CACHE INTERNAL "")
  set(${PROJECT_NAME}_MODULE_LINKER_FLAGS CACHE INTERNAL "")
  set(${PROJECT_NAME}_SHARED_LINKER_FLAGS CACHE INTERNAL "")
  set(${PROJECT_NAME}_STATIC_LINKER_FLAGS CACHE INTERNAL "")

  #Python being used as a scripting language it defines an interpreter not a compiler
  set(${PROJECT_NAME}_Python_INTERPRETER CACHE INTERNAL "")#full path to python executable
  set(${PROJECT_NAME}_Python_INCLUDE_DIRS CACHE INTERNAL "")# include for python executable
  set(${PROJECT_NAME}_Python_LIBRARY CACHE INTERNAL "")#path to python library

  # variable to manage generator in use
  set(${PROJECT_NAME}_GENERATOR CACHE INTERNAL "")
  set(${PROJECT_NAME}_MAKE_PROGRAM CACHE INTERNAL "")
  set(${PROJECT_NAME}_GENERATOR_EXTRA CACHE INTERNAL "")
  set(${PROJECT_NAME}_GENERATOR_TOOLSET CACHE INTERNAL "")
  set(${PROJECT_NAME}_GENERATOR_PLATFORM CACHE INTERNAL "")
  set(${PROJECT_NAME}_GENERATOR_INSTANCE CACHE INTERNAL "")
endfunction(reset_Environment_Description)


#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Environment| replace:: ``declare_Environment``
#  .. _declare_Environment:
#
#  declare_Environment
#  -------------------
#
#   .. command:: declare_Environment(author institution mail year license address public_address description )
#
#   Define current project as a PID environment. Internal counterpart to declare_PID_Environment.
#
#      :author: the name of environment contact author.
#      :institution: the name of the institution of the contact author
#      :mail: the mail of contact author
#      :year: the dates of project lifecyle.
#      :license: the name of the license applying to the environment's content.
#      :address: the push url of the environment repository.
#      :public_address: the push url of the environment repository.
#      :description: description of the environment.
#      :contrib_space: determines the default contribution space of the environment.
#
macro(declare_Environment author institution mail year license address public_address description contrib_space)
  reset_Environment_Description()#reset variables generated by the environment
  file(RELATIVE_PATH DIR_NAME ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})
  load_Current_Contribution_Spaces()

  configure_Git()#checking git usable
  if(NOT GIT_CONFIGURED)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR: your git tool is NOT configured. To use PID you need to configure git:\ngit config --global user.name \"Your Name\"\ngit config --global user.email <your email address>\n")
  	return()
  endif()
  if(NOT DIR_NAME STREQUAL "build")
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : please run cmake in the build folder of the environment ${PROJECT_NAME}.")
  	return()
  endif()

  #reset environment description
  init_Meta_Info_Cache_Variables("${author}" "${institution}" "${mail}" "${description}" "${year}" "${license}" "${address}" "${public_address}" "" "" "" "")
	declare_Environment_Global_Cache_Options()
  set_Cache_Entry_For_Default_Contribution_Space("${contrib_space}")
  check_For_Remote_Respositories("${ADDITIONNAL_DEBUG_INFO}")#configuring git remotes
endmacro(declare_Environment)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Environment_Global_Cache_Options| replace:: ``declare_Environment_Global_Cache_Options``
#  .. _declare_Environment_Global_Cache_Options:
#
#  declare_Environment_Global_Cache_Options
#  ----------------------------------------
#
#   .. command:: declare_Environment_Global_Cache_Options()
#
#     Declare configurable options for the currently built environment.
#
macro(declare_Environment_Global_Cache_Options)
option(ADDITIONNAL_DEBUG_INFO "Getting more info on debug mode or more PID messages (hidden by default)" OFF)
endmacro(declare_Environment_Global_Cache_Options)

#.rst:
#
# .. ifmode:: internal
#
#  .. |define_Build_Environment_Platform| replace:: ``define_Build_Environment_Platform``
#  .. _define_Build_Environment_Platform:
#
#  define_Build_Environment_Platform
#  ---------------------------------
#
#   .. command:: define_Build_Environment_Platform(type_constraint arch_constraint os_constraint abi_constraint distribution distrib_version config check_script)
#
#   Define platform targetted by the curren environment. It consists in setting adequate internal cache variables.
#
#      :type_constraint: constraint on processor architecture type constraint (x86 or arm for instance)
#
#      :arch_constraint: constraint on processor architecture (16, 32, 64)
#
#      :os_constraint: constraint on operating system (linux, macos, windows).
#
#      :abi_constraint: constraint on abi in use (98 or 11).
#
#      :distribution: constraint on operating system distribution in use (e.g. ubuntu, debian).
#
#      :distrib_version: constraint on operating system distribution in use (e.g. for ubuntu 16.04).
#
#      :config: all additional platform configuration that host must match to be also the target.
#
#      :check_script: path to the check script used to test specific build variables on host in order to know if host really matches.
#
function(define_Build_Environment_Platform type_constraint arch_constraint os_constraint abi_constraint distribution distrib_version config check_script)
  set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_DEFINED TRUE CACHE INTERNAL "")
  set(${PROJECT_NAME}_TYPE_CONSTRAINT ${type_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_ARCH_CONSTRAINT ${arch_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_OS_CONSTRAINT ${os_constraint} CACHE INTERNAL "")
  if(abi_constraint STREQUAL "abi98" OR abi_constraint STREQUAL "98" OR abi_constraint STREQUAL "CXX")
    set(${PROJECT_NAME}_ABI_CONSTRAINT CXX CACHE INTERNAL "")
  elseif(abi_constraint STREQUAL "abi11" OR abi_constraint STREQUAL "11" OR abi_constraint STREQUAL "CXX11")
    set(${PROJECT_NAME}_ABI_CONSTRAINT CXX11 CACHE INTERNAL "")
  endif()
  set(${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT ${distribution} CACHE INTERNAL "")
  set(${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT ${distrib_version} CACHE INTERNAL "")
  set(${PROJECT_NAME}_CONFIGURATION_CONSTRAINT ${config} CACHE INTERNAL "")
  set(${PROJECT_NAME}_CHECK ${check_script} CACHE INTERNAL "")
endfunction(define_Build_Environment_Platform)

#.rst:
#
# .. ifmode:: internal
#
#  .. |define_Environment_Constraints| replace:: ``define_Environment_Constraints``
#  .. _define_Environment_Constraints:
#
#  define_Environment_Constraints
#  -------------------------------
#
#   .. command:: define_Environment_Constraints(optional_vars required_vars)
#
#   Define all constraint that can be used with the current environment, in order to configure it.
#
#      :optional_vars: the list of optional variables that specify constraints. Optional means that user do not need to provide a value for these variables.
#
#      :required_vars: the list of required variables that specify constraints. Required means that user must provide a value for these variables.
#
function(define_Environment_Constraints optional_vars required_vars)
  set(${PROJECT_NAME}_ENVIRONMENT_CONSTRAINTS_DEFINED TRUE CACHE INTERNAL "")
  set(${PROJECT_NAME}_OPTIONAL_CONSTRAINTS ${optional_vars} CACHE INTERNAL "")
  set(${PROJECT_NAME}_REQUIRED_CONSTRAINTS ${required_vars} CACHE INTERNAL "")
endfunction(define_Environment_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |define_Environment_Solution_Procedure| replace:: ``define_Environment_Solution_Procedure``
#  .. _define_Environment_Solution_Procedure:
#
#  define_Environment_Solution_Procedure
#  -------------------------------------
#
#   .. command:: define_Environment_Solution_Procedure(type_constraint arch_constraint os_constraint abi_constraint distribution version check_script configure_script)
#
#    Define a new solution for configuring the environment.
#
#      :type_constraint: filters processor architecture type (arm, x86)
#
#      :arch_constraint: filters processor architecture (32, 64)
#
#      :os_constraint: filters operating system
#
#      :abi_constraint: filters default c++ abi
#
#      :distribution: filters the distribution of the host.
#
#      :version: filters the version of the distribution.
#
#      :configure_script: path relative to src folder of the script file used to configure host in order to make it conforms to environment settings
#
#      :dependencies: list of dependencies to other environments
#
function(define_Environment_Solution_Procedure type_constraint arch_constraint os_constraint abi_constraint distribution version configure_script dependencies)
  set(${PROJECT_NAME}_SOLUTION_${${PROJECT_NAME}_SOLUTIONS}_TYPE ${type_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_SOLUTION_${${PROJECT_NAME}_SOLUTIONS}_ARCH ${arch_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_SOLUTION_${${PROJECT_NAME}_SOLUTIONS}_OS ${os_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_SOLUTION_${${PROJECT_NAME}_SOLUTIONS}_ABI ${abi_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_SOLUTION_${${PROJECT_NAME}_SOLUTIONS}_DISTRIBUTION ${distribution} CACHE INTERNAL "")
  set(${PROJECT_NAME}_SOLUTION_${${PROJECT_NAME}_SOLUTIONS}_DISTRIB_VERSION ${version} CACHE INTERNAL "")
  set(${PROJECT_NAME}_SOLUTION_${${PROJECT_NAME}_SOLUTIONS}_CONFIGURE ${configure_script} CACHE INTERNAL "")
  set(${PROJECT_NAME}_SOLUTION_${${PROJECT_NAME}_SOLUTIONS}_DEPENDENCIES ${dependencies} CACHE INTERNAL "")
  math(EXPR temp "${${PROJECT_NAME}_SOLUTIONS}+1")
  set(${PROJECT_NAME}_SOLUTIONS ${temp} CACHE INTERNAL "")
endfunction(define_Environment_Solution_Procedure)

#.rst:
#
# .. ifmode:: internal
#
#  .. |build_Environment_Project| replace:: ``build_Environment_Project``
#  .. _build_Environment_Project:
#
#  build_Environment_Project
#  -------------------------
#
#   .. command:: build_Environment_Project()
#
#  Finalize the build process configuration of the current environment project.
#
macro(build_Environment_Project)

  # build command simply relaunch configuration with parameters managed
  add_custom_target(build
    COMMAND ${CMAKE_COMMAND}
    -DWORKSPACE_DIR=${WORKSPACE_DIR}
    -DTARGET_ENVIRONMENT=${PROJECT_NAME}
		-DTARGET_SYSROOT=\${sysroot}
		-DTARGET_STAGING=\${staging}
		-DTARGET_PLATFORM=\${platform}
		-DTARGET_PROC_TYPE=\${type}
		-DTARGET_PROC_ARCH=\${arch}
		-DTARGET_OS=\${os}
		-DTARGET_ABI=\${abi}
		-DTARGET_DISTRIBUTION=\${distribution}
		-DTARGET_DISTRIBUTION_VERSION=\${distrib_version}
		-DIN_CI_PROCESS=${IN_CI_PROCESS}
    -P ${WORKSPACE_DIR}/cmake/commands/Build_PID_Environment.cmake
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  )

  # update target (update the environment from upstream git repository)
  add_custom_target(update
    COMMAND ${CMAKE_COMMAND}
            -DWORKSPACE_DIR=${WORKSPACE_DIR}
            -DTARGET_ENVIRONMENT=${PROJECT_NAME}
            -P ${WORKSPACE_DIR}/cmake/commands/Update_PID_Deployment_Unit.cmake
    COMMENT "[PID] Updating the environment ${PROJECT_NAME} ..."
    VERBATIM
  )
  #########################################################################################################################
  ######### writing the global reference file for the package with all global info contained in the CMakeFile.txt #########
  #########################################################################################################################
  if(${PROJECT_NAME}_ADDRESS)
    generate_Environment_Reference_File(${CMAKE_BINARY_DIR}/share/ReferEnvironment${PROJECT_NAME}.cmake)
    #copy the reference file of the package into the "references" folder of the workspace
    get_Path_To_All_Deployment_Unit_References_Publishing_Contribution_Spaces(ALL_PUBLISHING_CS ${PROJECT_NAME})
    add_custom_target(referencing
      COMMAND ${CMAKE_COMMAND}
              -DWORKSPACE_DIR=${WORKSPACE_DIR}
              -DTARGET_ENVIRONMENT=${PROJECT_NAME}
              -DCMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}
              -DALL_PUBLISHING_CS=\"${ALL_PUBLISHING_CS}\"
              -P ${WORKSPACE_DIR}/cmake/commands/Referencing_PID_Deployment_Unit.cmake
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
  endif()

  if(NOT EVALUATION_RUN)
    generate_Environment_Inputs_Description_File()
    generate_Environment_Readme_Files() # generating and putting into source directory the readme file used by git hosting service
    generate_Environment_License_File() # generating and putting into source directory the file containing license info about the package
    return()#directly exit
  else()#the make build will do the evaluation run
    message("------------------------------------------------------")
    message("[PID] INFO: evaluating environment ${PROJECT_NAME} ...")
  endif()

  set(EVALUATION_RUN FALSE CACHE INTERNAL "" FORCE)#reset so that new cmake run will not be an evaluation run
  detect_Current_Platform()
  evaluate_Environment_Constraints() #get the parameters passed to the environment
  evaluate_Generator()
  evaluate_Environment_Platform(HOST_MATCHES_TARGET)
  if(NOT HOST_MATCHES_TARGET)#if host does not match all constraints -> we need to configure the toochain using available solutions
    #now evaluate current environment regarding
    set(possible_solution FALSE)
    if(${PROJECT_NAME}_SOLUTIONS GREATER 0)
      math(EXPR max "${${PROJECT_NAME}_SOLUTIONS}-1")
      foreach(index RANGE ${max})
        is_Environment_Solution_Eligible(SOL_POSSIBLE ${index})
        if(SOL_POSSIBLE)
          evaluate_Environment_Solution(EVAL_RESULT ${index})
          if(EVAL_RESULT)# solution check is OK, the solution can be used
            generate_Environment_Toolchain_File(${index})
            set(possible_solution TRUE)
            break()
          endif()
        endif()
      endforeach()
    endif()
    if(NOT possible_solution)
      message(FATAL_ERROR "[PID] CRITICAL ERROR: cannot configure host with environment ${PROJECT_NAME}. No valid solution found.")
      return()
    endif()
  endif()

  #generate workspace configuration files only if really usefull
  generate_Environment_Description_File()
  generate_Environment_Solution_File()
endmacro(build_Environment_Project)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Environment_Dependency| replace:: ``manage_Environment_Dependency``
#  .. _manage_Environment_Dependency:
#
#  manage_Environment_Dependency
#  -----------------------------
#
#   .. command:: manage_Environment_Dependency(MANAGE_RESULT environment)
#
#   Load and configure the dependent environment with current target platforl constraints, then checks that the given dependency is satisfied.
#
#     :environment: the dependency to manage (may include constraint arguments (e.g. gcc_toolchain[version=5.4])).
#
#     :MANAGE_RESULT: the output variable that is TRUE if dependency check is OK, FALSE otherwise.
#
function(manage_Environment_Dependency MANAGE_RESULT environment)
# 1) parse the environment depenedncy to get its name and args separated
parse_System_Check_Constraints(ENV_NAME ENV_ARGS ${environment}) #get environment name from environment expression (extract arguments and base name)

# 2) load the environment if required
load_Environment(LOAD_RESULT ${ENV_NAME})
if(NOT LOAD_RESULT)
  set(${MANAGE_RESULT} FALSE PARENT_SCOPE)
  return()
endif()
# 3) evaluate the dependent environment with current target platform constraints then if OK transfer its build properties to the current environment
evaluate_Environment(GEN_RESULT ${ENV_NAME} "${ENV_ARGS}")
set(${MANAGE_RESULT} ${GEN_RESULT} PARENT_SCOPE)
endfunction(manage_Environment_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |environment_Project_Exists| replace:: ``environment_Project_Exists``
#  .. _environment_Project_Exists:
#
#  environment_Project_Exists
#  --------------------------
#
#   .. command:: environment_Project_Exists(REPO_EXISTS PATH_TO_REPO environment)
#
#     Check whether the repository for a given environment exists in workspace.
#
#      :environment: the name of the target environment.
#
#      :REPO_EXISTS: the output variable that is TRUE if the environment repository lies in workspace.
#
#      :PATH_TO_REPO: the output variable that contains the path to the environment repository.
#
function(environment_Project_Exists REPO_EXISTS PATH_TO_REPO environment)
set(SEARCH_PATH ${WORKSPACE_DIR}/environments/${environment})
if(EXISTS ${SEARCH_PATH} AND IS_DIRECTORY ${SEARCH_PATH})
	set(${REPO_EXISTS} TRUE PARENT_SCOPE)
else()
	set(${REPO_EXISTS} FALSE PARENT_SCOPE)
endif()
set(${PATH_TO_REPO} ${SEARCH_PATH} PARENT_SCOPE)
endfunction(environment_Project_Exists)

#.rst:
#
# .. ifmode:: internal
#
#  .. |load_Environment| replace:: ``load_Environment``
#  .. _load_Environment:
#
#  load_Environment
#  ----------------
#
#   .. command:: load_Environment(LOADED environment)
#
#     Putting the environment repository into the workspace, or update it if it is already there.
#
#      :environment: the name of the target environment.
#
#      :LOADED: the output variable that is TRUE if the environment has been loaded.
#
function(load_Environment LOADED environment)

set(${LOADED} FALSE PARENT_SCOPE)
set(FOLDER_EXISTS FALSE)
include_Environment_Reference_File(REF_EXIST ${environment})

environment_Project_Exists(FOLDER_EXISTS PATH_TO_SITE ${environment})
if(FOLDER_EXISTS)
	message("[PID] INFO: updating environment ${environment} (this may take a long time)")
	update_Environment_Repository(${environment}) #update the repository to be sure to work on last version
	if(NOT REF_EXIST) #if reference file does not exist we use the project present in the workspace.
    # This way we may force it to generate references
		execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} referencing WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment}/build)
    include_Environment_Reference_File(REF_EXIST ${environment})
		if(REF_EXIST)#should be the case anytime after a referencing command
      set(${LOADED} TRUE PARENT_SCOPE)
		endif()
	else()
		set(${LOADED} TRUE PARENT_SCOPE)
	endif()
elseif(REF_EXIST) #we can try to clone it if we know where to clone from
	message("[PID] INFO: deploying environment ${environment} in workspace (this may take a long time)")
	deploy_Environment_Repository(IS_DEPLOYED ${environment})
	if(IS_DEPLOYED)
		set(${LOADED} TRUE PARENT_SCOPE)
	endif()
endif()
endfunction(load_Environment)


#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Environment_From_Script| replace:: ``evaluate_Environment_From_Script``
#  .. _evaluate_Environment_From_Script:
#
#  evaluate_Environment_From_Script
#  -----------------------------------
#
#   .. command:: evaluate_Environment_From_Script(EVAL_OK environment sysroot staging generator toolset)
#
#     Configure the target environment with management of environment variables coming from user.
#
#      :environment: the name of the target environment.
#
#      :sysroot: the path to sysroot.
#
#      :staging: the path to staging.
#
#      :type: the target type of processor (x86, arm, etc.).
#
#      :arch: the target processor architecture (16, 32, 64).
#
#      :os: the target operating system (e.g. linux)
#
#      :abi: the target c++ ABI (98 or 11).
#
#      :distribution: the target OS distribution (e.g. ubuntu)
#
#      :distrib_version: the target distribution version (e.g. 16.04).
#
#      :EVAL_OK: the output variable that is TRUE if the environment has been evaluated and exitted without errors.
#
function(evaluate_Environment_From_Script EVAL_OK environment sysroot staging type arch os abi distribution distrib_version)
set(${EVAL_OK} FALSE PARENT_SCOPE)
# 1. Get CMake definition for variables that are managed by the environment and set by user
set(environment_build_folder ${WORKSPACE_DIR}/environments/${environment}/build)
# 1.1 configure environment
hard_Clean_Build_Folder(${environment_build_folder}) #starting froma clean situation
execute_process(COMMAND ${CMAKE_COMMAND} -D IN_CI_PROCESS=${IN_CI_PROCESS} ..
                WORKING_DIRECTORY ${environment_build_folder})#simply ensure that input are generated
# 1.2 import variable description file
if(NOT EXISTS ${environment_build_folder}/PID_Inputs.cmake)
  return()
endif()
include(${environment_build_folder}/PID_Inputs.cmake)
# 1.3 for each variable, look if a corresponfing environment variable exists and if yes create the CMake definition to pass to environment
set(list_of_defs)
foreach(var IN LISTS ${environment}_INPUTS)
  if(DEFINED ENV{${var}})# an environment variable is defined for that constraint
    string(REPLACE " " "" VAL_LIST "$ENV{${var}}")#remove the spaces in the string if any
    string(REPLACE ";" "," VAL_LIST "${VAL_LIST}")#generate an argument list (with "," delim) from a cmake list (with ";" as delimiter)
    list(APPEND list_of_defs -DVAR_${var}=${VAL_LIST})
  else()
    list(APPEND list_of_defs -U VAR_${var})
  endif()
endforeach()
# 2. reconfigure the environment

 #preamble: for generators, first determine what is the preferred one
if(CURRENT_GENERATOR)
  list(APPEND list_of_defs -DPREFERRED_GENERATOR=\"${CURRENT_GENERATOR}\")
endif()
if(CURRENT_MAKE_PROGRAM)
  list(APPEND list_of_defs -DPREFERRED_MAKE_PROGRAM=\"${CURRENT_MAKE_PROGRAM}\")
endif()
if(CURRENT_GENERATOR_EXTRA)
  list(APPEND list_of_defs -DPREFERRED_GENERATOR_EXTRA=\"${CURRENT_GENERATOR_EXTRA}\")
endif()
if(CURRENT_GENERATOR_TOOLSET)
  list(APPEND list_of_defs -DPREFERRED_GENERATOR_TOOLSET=\"${CURRENT_GENERATOR_TOOLSET}\")
endif()
if(CURRENT_GENERATOR_PLATFORM)
  list(APPEND list_of_defs -DPREFERRED_GENERATOR_PLATFORM=\"${CURRENT_GENERATOR_PLATFORM}\")
endif()
if(CURRENT_GENERATOR_INSTANCE)
  list(APPEND list_of_defs -DPREFERRED_GENERATOR_INSTANCE=\"${CURRENT_GENERATOR_INSTANCE}\")
endif()

# 2.1 add specific variables like for sysroot, staging and generator in the list of definitions
if(sysroot)
  list(APPEND list_of_defs -DFORCED_SYSROOT=${sysroot})
endif()
if(staging)
  list(APPEND list_of_defs -DFORCED_STAGING=${staging})
endif()
if(type)
  list(APPEND list_of_defs -DFORCED_PROC_TYPE=${type})
endif()
if(arch)
  list(APPEND list_of_defs -DFORCED_PROC_ARCH=${arch})
endif()
if(os)
  list(APPEND list_of_defs -DFORCED_OS=${os})
endif()
if(abi)
  list(APPEND list_of_defs -DFORCED_ABI=${abi})
endif()
if(distribution)
  list(APPEND list_of_defs -DFORCED_DISTRIB=${distribution})
endif()
if(distrib_version)
  list(APPEND list_of_defs -DFORCED_DISTRIB_VERSION=${distrib_version})
endif()

# 2.2 reconfigure the environment with new definitions (user and specific variables) and evalutae it againts host
execute_process(COMMAND ${CMAKE_COMMAND} -DEVALUATION_RUN=TRUE ${list_of_defs} ..
                WORKING_DIRECTORY ${environment_build_folder})

# 1.2 import variable description file
if(res OR NOT EXISTS ${environment_build_folder}/PID_Environment_Description.cmake)
  return()
endif()

set(${EVAL_OK} TRUE PARENT_SCOPE)
# at the end: 2 files, toolchain file (optional, only generated if needed) and environment description in environment build folder
endfunction(evaluate_Environment_From_Script)


#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Environment| replace:: ``evaluate_Environment``
#  .. _evaluate_Environment:
#
#  evaluate_Environment
#  --------------------
#
#   .. command:: evaluate_Environment(EVAL_OK environment)
#
#     configure the environment with platform variables adn arguments coming from current environment (or user).
#
#      :environment: the name of the target environment.
#
#      :list_of_args: the list of arguments passed to the environment
#
#      :EVAL_OK: the output variable that is TRUE if the environment has been evaluated and exitted without errors.
#
function(evaluate_Environment EVAL_OK environment list_of_args)
# 1) clean and configure the environment project with definitions coming from target (even inherited)
# those definitions are : "user variables" (e.g. version) and current platform description (that will impose constraints)

set(env_build_folder ${WORKSPACE_DIR}/environments/${environment}/build)
#clean the build folder cache
file(REMOVE ${env_build_folder}/CMakeCache.txt ${env_build_folder}/PID_Toolchain.cmake ${env_build_folder}/PID_Environment_Description.cmake ${env_build_folder}/PID_Environment_Solution_Info.cmake)

#build the list of variables that will be passed to configuration process
prepare_Environment_Arguments(LIST_OF_DEFS_ARGS ${environment} list_of_args)
prepare_Platform_Constraints_Definitions(${environment} LIST_OF_DEFS_PLATFORM)
execute_process(COMMAND ${CMAKE_COMMAND} -DEVALUATION_RUN=TRUE ${LIST_OF_DEFS_ARGS} ${LIST_OF_DEFS_PLATFORM} ..
                WORKING_DIRECTORY ${env_build_folder})#configure, then build

# 2) => it should produce a resulting solution info file => including this file locally to get all definitions then apply them to local variables (overwritting).
# locally we manage thoses variables at configuration time. VAR_<name> is the variable for <name> argument.
# The platform is set using same variables as for target platform description but with FORCE_ prefix.

if(NOT EXISTS ${env_build_folder}/PID_Environment_Solution_Info.cmake)
  set(${EVAL_OK} FALSE PARENT_SCOPE)
  return()
endif()
include(${env_build_folder}/PID_Environment_Solution_Info.cmake)
set_Build_Variables_From_Environment(${environment})
set(${EVAL_OK} TRUE PARENT_SCOPE)
endfunction(evaluate_Environment)


function(set_Build_Variables_From_Environment environment)
  if(${environment}_CROSSCOMPILATION)
    set(${PROJECT_NAME}_CROSSCOMPILATION ${${environment}_CROSSCOMPILATION} CACHE INTERNAL "")
  endif()
  if(${environment}_TARGET_SYSTEM_NAME)
    set(${PROJECT_NAME}_TARGET_SYSTEM_NAME ${${environment}_TARGET_SYSTEM_NAME} CACHE INTERNAL "")
  endif()
  if(${environment}_TARGET_SYSTEM_PROCESSOR)
    set(${PROJECT_NAME}_TARGET_SYSTEM_PROCESSOR ${${environment}_TARGET_SYSTEM_PROCESSOR} CACHE INTERNAL "")
  endif()
  if(NOT ${PROJECT_NAME}_TARGET_SYSROOT AND ${environment}_TARGET_SYSROOT)#only if value not forced by user !
    set(${PROJECT_NAME}_TARGET_SYSROOT ${${environment}_TARGET_SYSROOT} CACHE INTERNAL "")
  endif()
  if(NOT ${PROJECT_NAME}_TARGET_STAGING AND ${environment}_TARGET_STAGING)#only if value not forced by user !
    set(${PROJECT_NAME}_TARGET_STAGING ${${environment}_TARGET_STAGING} CACHE INTERNAL "")
  endif()

  foreach(lang IN ITEMS C CXX ASM Fortran CUDA Python)
    if(NOT lang STREQUAL Python)
      if(${environment}_${lang}_COMPILER)
        set(${PROJECT_NAME}_${lang}_COMPILER ${${environment}_${lang}_COMPILER} CACHE INTERNAL "")
        set(${PROJECT_NAME}_${lang}_COMPILER_ID ${${environment}_${lang}_COMPILER_ID} CACHE INTERNAL "")
      endif()
      if(${environment}_${lang}_COMPILER_FLAGS)
        append_Unique_In_Cache(${PROJECT_NAME}_${lang}_COMPILER_FLAGS "${${environment}_${lang}_COMPILER_FLAGS}" CACHE INTERNAL "")
      endif()
      if(lang STREQUAL CUDA)
        if(${environment}_${lang}_HOST_COMPILER)
          set(${PROJECT_NAME}_${lang}_HOST_COMPILER ${${environment}_${lang}_HOST_COMPILER} CACHE INTERNAL "")
        endif()
      else()
        if(${environment}_${lang}_AR)
          set(${PROJECT_NAME}_${lang}_AR ${${environment}_${lang}_AR} CACHE INTERNAL "")
        endif()
        if(${environment}_${lang}_RANLIB)
          set(${PROJECT_NAME}_${lang}_RANLIB ${${environment}_${lang}_RANLIB} CACHE INTERNAL "")
        endif()
      endif()
    else()
      if(${environment}_${lang}_INTERPRETER)
        set(${PROJECT_NAME}_${lang}_INTERPRETER ${${environment}_${lang}_INTERPRETER} CACHE INTERNAL "")
      endif()
      if(${environment}_${lang}_INCLUDE_DIRS)
        append_Unique_In_Cache(${PROJECT_NAME}_${lang}_INCLUDE_DIRS "${${environment}_${lang}_INCLUDE_DIRS}" CACHE INTERNAL "")
      endif()
      if(${environment}_${lang}_LIBRARY)
        set(${PROJECT_NAME}_${lang}_LIBRARY ${${environment}_${lang}_LIBRARY} CACHE INTERNAL "")
      endif()
    endif()
  endforeach()
  if(${environment}_LINKER)
    set(${PROJECT_NAME}_LINKER ${${environment}_LINKER} CACHE INTERNAL "")
  endif()
  if(${environment}_AR)
    set(${PROJECT_NAME}_AR ${${environment}_AR} CACHE INTERNAL "")
  endif()
  if(${environment}_NM)
    set(${PROJECT_NAME}_NM ${${environment}_NM} CACHE INTERNAL "")
  endif()
  if(${environment}_RANLIB)
    set(${PROJECT_NAME}_RANLIB ${${environment}_RANLIB} CACHE INTERNAL "")
  endif()
  if(${environment}_OBJDUMP)
    set(${PROJECT_NAME}_OBJDUMP ${${environment}_OBJDUMP} CACHE INTERNAL "")
  endif()
  if(${environment}_OBJCOPY)
    set(${PROJECT_NAME}_OBJCOPY ${${environment}_OBJCOPY} CACHE INTERNAL "")
  endif()

  if(${environment}_INCLUDE_DIRS)
    append_Unique_In_Cache(${PROJECT_NAME}_INCLUDE_DIRS "${${environment}_INCLUDE_DIRS}")
  endif()
  if(${environment}_LIBRARY_DIRS)
    append_Unique_In_Cache(${PROJECT_NAME}_LIBRARY_DIRS "${${environment}_LIBRARY_DIRS}")
  endif()
  if(${environment}_PROGRAM_DIRS)
    append_Unique_In_Cache(${PROJECT_NAME}_PROGRAM_DIRS "${${environment}_PROGRAM_DIRS}")
  endif()
  if(${environment}_EXE_LINKER_FLAGS)
    append_Unique_In_Cache(${PROJECT_NAME}_EXE_LINKER_FLAGS "${${environment}_EXE_LINKER_FLAGS}")
  endif()
  if(${environment}_MODULE_LINKER_FLAGS)
    append_Unique_In_Cache(${PROJECT_NAME}_MODULE_LINKER_FLAGS "${${environment}_MODULE_LINKER_FLAGS}")
  endif()
  if(${environment}_SHARED_LINKER_FLAGS)
    append_Unique_In_Cache(${PROJECT_NAME}_SHARED_LINKER_FLAGS "${${environment}_SHARED_LINKER_FLAGS}")
  endif()
  if(${environment}_STATIC_LINKER_FLAGS)
    append_Unique_In_Cache(${PROJECT_NAME}_STATIC_LINKER_FLAGS "${${environment}_STATIC_LINKER_FLAGS}")
  endif()
  if(${environment}_GENERATOR)#may overwrite user choice
    set(${PROJECT_NAME}_GENERATOR ${${environment}_GENERATOR} CACHE INTERNAL "")
  endif()
  if(${environment}_MAKE_PROGRAM)#may overwrite user choice
    set(${PROJECT_NAME}_MAKE_PROGRAM ${${environment}_MAKE_PROGRAM} CACHE INTERNAL "")
  endif()
  if(${environment}_GENERATOR_EXTRA)#may overwrite user choice
    set(${PROJECT_NAME}_GENERATOR_EXTRA ${${environment}_GENERATOR_EXTRA} CACHE INTERNAL "")
  endif()
  if(${environment}_GENERATOR_TOOLSET)#may overwrite user choice
    set(${PROJECT_NAME}_GENERATOR_TOOLSET ${${environment}_GENERATOR_TOOLSET} CACHE INTERNAL "")
  endif()
  if(${environment}_GENERATOR_PLATFORM)#may overwrite user choice
    set(${PROJECT_NAME}_GENERATOR_PLATFORM ${${environment}_GENERATOR_PLATFORM} CACHE INTERNAL "")
  endif()
  if(${environment}_GENERATOR_INSTANCE)#may overwrite user choice
    set(${PROJECT_NAME}_GENERATOR_INSTANCE ${${environment}_GENERATOR_INSTANCE} CACHE INTERNAL "")
  endif()

endfunction(set_Build_Variables_From_Environment)

#.rst:
#
# .. ifmode:: internal
#
#  .. |prepare_Environment_Arguments| replace:: ``prepare_Environment_Arguments``
#  .. _prepare_Config_Arguments:
#
#  prepare_Environment_Arguments
#  -------------------------------
#
#   .. command:: prepare_Environment_Arguments(environment arguments)
#
#     Set the variables corresponding to environment arguments in the parent scope.
#
#     :environment: the name of the environment to be checked.
#
#     :arguments: the parent scope variable containing the list of arguments generated from parse_System_Check_Constraints.
#
#     :LIST_OF_DEFS: the output variable containing the list of CMake definitions to pass to configuration process.
#
function(prepare_Environment_Arguments LIST_OF_DEFS environment arguments)
  if(NOT arguments OR NOT ${arguments})
    return()
  endif()
  set(argument_couples ${${arguments}})
  set(result_list)
  while(argument_couples)
    list(GET argument_couples 0 name)
    list(GET argument_couples 1 value)
    list(REMOVE_AT argument_couples 0 1)#update the list of arguments in parent scope
    string(REPLACE " " "" VAL_LIST "${value}")#remove the spaces in the string if any
    string(REPLACE ";" "," VAL_LIST "${VAL_LIST}")#generate an argument list (with "," delim) from a cmake list (with ";" as delimiter)
    #generate the variable
    list(APPEND result_list -DVAR_${name}=${VAL_LIST})
  endwhile()
  set(${LIST_OF_DEFS} ${result_list} PARENT_SCOPE)
endfunction(prepare_Environment_Arguments)


#.rst:
#
# .. ifmode:: internal
#
#  .. |prepare_Platform_Constraints_Definitions| replace:: ``prepare_Platform_Constraints_Definitions``
#  .. _prepare_Platform_Constraints_Definitions:
#
#  prepare_Platform_Constraints_Definitions
#  -----------------------------------------
#
#   .. command:: prepare_Platform_Constraints_Definitions(LIST_OF_DEFS)
#
#     Create list of CMake definitions for environment platform constraints defined.
#
#     :environment_name: the name of the environment.
#
#     :LIST_OF_DEFS: the output variable containing the list of CMake definitions to pass to configuration process.
#
function(prepare_Platform_Constraints_Definitions environment_name LIST_OF_DEFS)
  set(result_list)
  if(${PROJECT_NAME}_TYPE_CONSTRAINT)
    list(APPEND result_list "-DFORCE_${environment_name}_TYPE_CONSTRAINT=${${PROJECT_NAME}_TYPE_CONSTRAINT}")
  endif()
  if(${PROJECT_NAME}_ARCH_CONSTRAINT)
    list(APPEND result_list "-DFORCE_${environment_name}_ARCH_CONSTRAINT=${${PROJECT_NAME}_ARCH_CONSTRAINT}")
  endif()
  if(${PROJECT_NAME}_OS_CONSTRAINT)
    list(APPEND result_list "-DFORCE_${environment_name}_OS_CONSTRAINT=${${PROJECT_NAME}_OS_CONSTRAINT}")
  endif()
  if(${PROJECT_NAME}_ABI_CONSTRAINT)
    list(APPEND result_list "-DFORCE_${environment_name}_ABI_CONSTRAINT=${${PROJECT_NAME}_ABI_CONSTRAINT}")
  endif()
  if(${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT)
    list(APPEND result_list "-DFORCE_${environment_name}_DISTRIBUTION_CONSTRAINT=${${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT}")
  endif()
  if(${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT)
    list(APPEND result_list "-DFORCE_${environment_name}_DISTRIB_VERSION_CONSTRAINT=${${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT}")
  endif()
  #configuration and chgeck scripts are purely local information
  set(${LIST_OF_DEFS} ${result_list} PARENT_SCOPE)
endfunction(prepare_Platform_Constraints_Definitions)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Environment_Author| replace:: ``add_Environment_Author``
#  .. _add_Environment_Author:
#
#  add_Environment_Author
#  ----------------------
#
#   .. command:: add_Environment_Author(author institution)
#
#   Add an author to the current framework project.
#
#      :author: the author name
#
#      :institution: the author institution.
#
function(add_Environment_Author author institution)
	set(res_string_author)
	foreach(string_el IN LISTS author)
		set(res_string_author "${res_string_author}_${string_el}")
	endforeach()
	set(res_string_instit)
	foreach(string_el IN LISTS institution)
		set(res_string_instit "${res_string_instit}_${string_el}")
	endforeach()
	if(res_string_instit)
		set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS};${res_string_author}(${res_string_instit})" CACHE INTERNAL "")
	else()
		set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS};${res_string_author}" CACHE INTERNAL "")
	endif()
endfunction(add_Environment_Author)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Environment_Reference_File| replace:: ``generate_Environment_Reference_File``
#  .. _generate_Environment_Reference_File:
#
#  generate_Environment_Reference_File
#  -----------------------------------
#
#   .. command:: generate_Environment_Reference_File(pathtonewfile)
#
#   Create a reference file for the current environment project.
#
#     :pathtonewfile: the path to the file to create.
#
function(generate_Environment_Reference_File pathtonewfile)
  file(WRITE ${pathtonewfile} "")
  file(APPEND ${pathtonewfile} "#### referencing environment ${PROJECT_NAME} mode ####\n")
  file(APPEND ${pathtonewfile} "set(${PROJECT_NAME}_MAIN_AUTHOR ${${PROJECT_NAME}_MAIN_AUTHOR} CACHE INTERNAL \"\")\n")
  file(APPEND ${pathtonewfile} "set(${PROJECT_NAME}_MAIN_INSTITUTION ${${PROJECT_NAME}_MAIN_INSTITUTION} CACHE INTERNAL \"\")\n")
  file(APPEND ${pathtonewfile} "set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS \"${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS}\" CACHE INTERNAL \"\")\n")
  file(APPEND ${pathtonewfile} "set(${PROJECT_NAME}_YEARS ${${PROJECT_NAME}_YEARS} CACHE INTERNAL \"\")\n")
  file(APPEND ${pathtonewfile} "set(${PROJECT_NAME}_CONTACT_MAIL ${${PROJECT_NAME}_MAIL} CACHE INTERNAL \"\")\n")
  file(APPEND ${pathtonewfile} "set(${PROJECT_NAME}_ADDRESS ${${PROJECT_NAME}_ADDRESS} CACHE INTERNAL \"\")\n")
  file(APPEND ${pathtonewfile} "set(${PROJECT_NAME}_PUBLIC_ADDRESS ${${PROJECT_NAME}_PUBLIC_ADDRESS} CACHE INTERNAL \"\")\n")
  file(APPEND ${pathtonewfile} "set(${PROJECT_NAME}_LICENSE ${${PROJECT_NAME}_LICENSE} CACHE INTERNAL \"\")\n")
  file(APPEND ${pathtonewfile} "set(${PROJECT_NAME}_DESCRIPTION ${${PROJECT_NAME}_DESCRIPTION} CACHE INTERNAL \"\")\n")
endfunction(generate_Environment_Reference_File)


#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Environment_Inputs_Description_File| replace:: ``generate_Environment_Inputs_Description_File``
#  .. _generate_Environment_Inputs_Description_File:
#
#  generate_Environment_Inputs_Description_File
#  --------------------------------------------
#
#   .. command:: generate_Environment_Inputs_Description_File()
#
#   Create the script file containing current environment inputs (variable defined from constraints).
#
function(generate_Environment_Inputs_Description_File)
  if(${PROJECT_NAME}_OPTIONAL_CONSTRAINTS OR ${PROJECT_NAME}_REQUIRED_CONSTRAINTS)
    set(lift_of_inputs ${${PROJECT_NAME}_OPTIONAL_CONSTRAINTS} ${${PROJECT_NAME}_REQUIRED_CONSTRAINTS})
    file(WRITE ${CMAKE_BINARY_DIR}/PID_Inputs.cmake "set(${PROJECT_NAME}_INPUTS ${lift_of_inputs} CACHE INTERNAL \"\")")
  else()
    file(WRITE ${CMAKE_BINARY_DIR}/PID_Inputs.cmake "")
  endif()
endfunction(generate_Environment_Inputs_Description_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Environment_Readme_Files| replace:: ``generate_Environment_Readme_Files``
#  .. _generate_Environment_Readme_Files:
#
#  generate_Environment_Readme_Files
#  ---------------------------------
#
#   .. command:: generate_Environment_Readme_Files()
#
#   Create the readme file within the current environment project.
#
function(generate_Environment_Readme_Files) # generating and putting into source directory the readme file used by git hosting service
  set(README_CONFIG_FILE ${WORKSPACE_DIR}/cmake/patterns/environments/README.md.in)

  set(ENVIRONMENT_NAME ${PROJECT_NAME})
  set(README_OVERVIEW "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided by wiki description use the short one

  if(${PROJECT_NAME}_LICENSE)
  	set(LICENSE_FOR_README "The license that applies to this repository project is **${${PROJECT_NAME}_LICENSE}**.")
  else()
  	set(LICENSE_FOR_README "The environment has no license defined yet.")
  endif()

  set(README_AUTHORS_LIST "")
  foreach(author IN LISTS ${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS)
  	generate_Full_Author_String(${author} STRING_TO_APPEND)
  	set(README_AUTHORS_LIST "${README_AUTHORS_LIST}\n+ ${STRING_TO_APPEND}")
  endforeach()

  get_Formatted_Package_Contact_String(${PROJECT_NAME} RES_STRING)
  set(README_CONTACT_AUTHOR "${RES_STRING}")

  configure_file(${README_CONFIG_FILE} ${CMAKE_SOURCE_DIR}/README.md @ONLY)#put it in the source dir
endfunction(generate_Environment_Readme_Files)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Environment_License_File| replace:: ``generate_Environment_License_File``
#  .. _generate_Environment_License_File:
#
#  generate_Environment_License_File
#  ---------------------------------
#
#   .. command:: generate_Environment_License_File()
#
#   Create the license file within the current environment project.
#
function(generate_Environment_License_File)

  if(${PROJECT_NAME}_LICENSE)
    resolve_License_File(PATH_TO_FILE ${${PROJECT_NAME}_LICENSE})
    if(NOT PATH_TO_FILE)
      message("[PID] WARNING : license configuration file for ${${PROJECT_NAME}_LICENSE} not found in any contribution space installed in workspace, license file will not be generated.")
  	else()
  		#prepare license generation
  		set(${PROJECT_NAME}_FOR_LICENSE "${PROJECT_NAME} environment")
  		set(${PROJECT_NAME}_DESCRIPTION_FOR_LICENSE ${${PROJECT_NAME}_DESCRIPTION})
  		set(${PROJECT_NAME}_YEARS_FOR_LICENSE ${${PROJECT_NAME}_YEARS})
  		foreach(author IN LISTS ${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS)
  			generate_Full_Author_String(${author} STRING_TO_APPEND)
  			set(${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE "${${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE} ${STRING_TO_APPEND}")
  		endforeach()
      include(${PATH_TO_FILE})
  		file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
  	endif()
  endif()
endfunction(generate_Environment_License_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Generator| replace:: ``evaluate_Generator``
#  .. _evaluate_Generator:
#
#  evaluate_Generator
#  ------------------
#
#   .. command:: evaluate_Generator()
#
#   Set generator related variables to the default value of the upper level.
#
function(evaluate_Generator)
  if(PREFERRED_GENERATOR)
    set(${PROJECT_NAME}_GENERATOR ${PREFERRED_GENERATOR} CACHE INTERNAL "")# cannot be overwritten
  endif()
  if(PREFERRED_MAKE_PROGRAM)
    set(${PROJECT_NAME}_MAKE_PROGRAM ${PREFERRED_MAKE_PROGRAM} CACHE INTERNAL "")# cannot be overwritten
  endif()

  if(PREFERRED_GENERATOR_EXTRA)
    set(${PROJECT_NAME}_GENERATOR_EXTRA ${PREFERRED_GENERATOR_EXTRA} CACHE INTERNAL "")# cannot be overwritten
  endif()
  if(PREFERRED_GENERATOR_TOOLSET)
    set(${PROJECT_NAME}_GENERATOR_TOOLSET ${PREFERRED_GENERATOR_TOOLSET} CACHE INTERNAL "")# cannot be overwritten
  endif()
  if(PREFERRED_GENERATOR_PLATFORM)
    set(${PROJECT_NAME}_GENERATOR_PLATFORM ${PREFERRED_GENERATOR_PLATFORM} CACHE INTERNAL "")# cannot be overwritten
  endif()
  if(PREFERRED_GENERATOR_INSTANCE)
    set(${PROJECT_NAME}_GENERATOR_INSTANCE ${PREFERRED_GENERATOR_INSTANCE} CACHE INTERNAL "")# cannot be overwritten
  endif()
endfunction(evaluate_Generator)

#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Environment_Platform| replace:: ``evaluate_Environment_Platform``
#  .. _evaluate_Environment_Platform:
#
#  evaluate_Environment_Platform
#  -----------------------------
#
#   .. command:: evaluate_Environment_Platform()
#
#   evaluate the target platform VS the host platform.
#
#     :CURRENT_HOST_MATCHES_TARGET: the output variable that is TRUE if current host matches target platform constraints.
#
function(evaluate_Environment_Platform CURRENT_HOST_MATCHES_TARGET)
  set(${PROJECT_NAME}_CROSSCOMPILATION FALSE CACHE INTERNAL "")
  set(result TRUE)

  #manage parameters passed to the environment by the configure script
  if(FORCED_SYSROOT)
    set(${PROJECT_NAME}_TARGET_SYSROOT ${FORCED_SYSROOT} CACHE INTERNAL "")# cannot be overwritten
  endif()
  if(FORCED_STAGING)
    set(${PROJECT_NAME}_TARGET_STAGING ${FORCED_STAGING} CACHE INTERNAL "")# cannot be overwritten
  endif()
  if(FORCED_PROC_TYPE)
    set(${PROJECT_NAME}_TYPE_CONSTRAINT ${FORCED_PROC_TYPE} CACHE INTERNAL "")# cannot be overwritten
  endif()
  if(FORCED_PROC_ARCH)
    set(${PROJECT_NAME}_ARCH_CONSTRAINT ${FORCED_PROC_ARCH} CACHE INTERNAL "")# cannot be overwritten
  endif()
  if(FORCED_OS)
    set(${PROJECT_NAME}_OS_CONSTRAINT ${FORCED_OS} CACHE INTERNAL "")# cannot be overwritten
  endif()
  if(FORCED_ABI)
    set(${PROJECT_NAME}_ABI_CONSTRAINT ${FORCED_ABI} CACHE INTERNAL "")# cannot be overwritten
  endif()
  if(FORCED_DISTRIB)
    set(${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT ${FORCED_DISTRIB} CACHE INTERNAL "")# cannot be overwritten
  endif()
  if(FORCED_DISTRIB_VERSION)
    set(${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT ${FORCED_DISTRIB_VERSION} CACHE INTERNAL "")# cannot be overwritten
  endif()

  #determine if host is target and if we need to crosscompile
  if(${PROJECT_NAME}_TYPE_CONSTRAINT
  AND NOT CURRENT_PLATFORM_TYPE STREQUAL ${PROJECT_NAME}_TYPE_CONSTRAINT)
      set(${PROJECT_NAME}_CROSSCOMPILATION TRUE CACHE INTERNAL "" FORCE)#if processor differs then this is crosscompilation
      set(result FALSE)
  endif()

  if(${PROJECT_NAME}_ARCH_CONSTRAINT
  AND NOT CURRENT_PLATFORM_ARCH EQUAL ${PROJECT_NAME}_ARCH_CONSTRAINT)
      set(result FALSE)
  endif()

  if(${PROJECT_NAME}_OS_CONSTRAINT #operating system type constraint is specified
    AND NOT CURRENT_PLATFORM_OS STREQUAL ${PROJECT_NAME}_OS_CONSTRAINT)
    set(${PROJECT_NAME}_CROSSCOMPILATION TRUE CACHE INTERNAL "" FORCE)#if OS differs then this is corsscompilation
      set(result FALSE)
  endif()

  if(${PROJECT_NAME}_ABI_CONSTRAINT)#processor architecture type constraint is specified
    compare_ABIs(ARE_EQUAL ${${PROJECT_NAME}_ABI_CONSTRAINT} ${CURRENT_PLATFORM_ABI})
    if(NOT ARE_EQUAL)
      #for the ABI it is not necessary to cross compile, juste to have adequate compiler and pass adequate arguments
      set(result FALSE)
    endif()
  endif()

  #compiling for another distribution does not necessarily mean crosscompiling
  if(${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT
     AND NOT CURRENT_DISTRIBUTION STREQUAL ${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT)
    set(result FALSE)
    set(${PROJECT_NAME}_CROSSCOMPILATION TRUE CACHE INTERNAL "" FORCE)# but we can still crosscompile for other distributions like raspbian
  endif()

  if(${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT
  AND NOT CURRENT_DISTRIBUTION_VERSION STREQUAL ${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT)
    set(result FALSE)
  endif()

  if(${PROJECT_NAME}_CONFIGURATION_CONSTRAINT)
    check_Environment_Configuration_Constraint(CHECK_RESULT)
    if(NOT CHECK_RESULT)
      set(result FALSE)
    endif()
  endif()


  # 2 solutions: either current host is matching with constraints (use CHECK script) OR current host needs to be configured
  # additionnal check for target platform
  if(${PROJECT_NAME}_CHECK)
    if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_CHECK})#addintionnal check is required to manage input constraints
      message(FATAL_ERROR "[PID] CRITICAL ERROR: the file ${${PROJECT_NAME}_CHECK} cannot be fund in src folder of ${PROJECT_NAME}")
      return()
    endif()
    #now check if host satisfies all properties of the target platform
    set(ENVIRONMENT_CHECK_RESULT TRUE CACHE INTERNAL "")
    include(${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_CHECK})
    if(NOT ENVIRONMENT_CHECK_RESULT)#host does matches all requirements, so trying to configure these requirements
      set(result FALSE)
    endif()
  else()#no check file means that a solution need to be applied any time
    #used to manage environment that define "user station profiles" or "real target platform" based on dependencies
    #at least a solution must be available in that case
    set(result FALSE)
  endif()

  #provides the result to say if host is target
  set(${CURRENT_HOST_MATCHES_TARGET} ${result} PARENT_SCOPE)

  if(${PROJECT_NAME}_CROSSCOMPILATION)#if host is not target and cross=> We may need to define cross compilation relared information
    if(${PROJECT_NAME}_TYPE_CONSTRAINT)
      set(use_proc_type ${${PROJECT_NAME}_TYPE_CONSTRAINT})
    else()#type is same as current
      set(use_proc_type ${CURRENT_PLATFORM_TYPE})
    endif()
    if(${PROJECT_NAME}_ARCH_CONSTRAINT)
      set(use_proc_arch ${${PROJECT_NAME}_ARCH_CONSTRAINT})
    else()#type is same as current
      set(use_proc_arch ${CURRENT_PLATFORM_ARCH})
    endif()
    if(${PROJECT_NAME}_OS_CONSTRAINT)#operating system type constraint is specified
      set(use_os ${${PROJECT_NAME}_OS_CONSTRAINT})
    else()
      set(use_os ${CURRENT_PLATFORM_ARCH})
    endif()
    #configure crosscompilation variables
    if(use_proc_type STREQUAL "x86")
      if(use_proc_arch EQUAL 32)
        set(proc_name x86)
      elseif(use_proc_arch EQUAL 64)
        set(proc_name x86_64)
      endif()
    elseif(use_proc_type STREQUAL "arm")
      set(proc_name arm)
    #TODO add more processors
    endif()
    set(${PROJECT_NAME}_TARGET_SYSTEM_PROCESSOR ${proc_name} CACHE INTERNAL "")
    #configuring OS
    if(use_os STREQUAL "linux")
      set(os_name Linux)
    elseif(use_os STREQUAL "macos")
      set(os_name Darwin)
    elseif(use_os STREQUAL "windows")
      set(os_name Windows)
    #TODO add more OS here
    else()#unknown target OS -> considered as Generic (no OS)
      set(os_name Generic)
    endif()
    set(${PROJECT_NAME}_TARGET_SYSTEM_NAME ${os_name} CACHE INTERNAL "")
  endif()

endfunction(evaluate_Environment_Platform)


#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Environment_Solution_Eligible| replace:: ``is_Environment_Solution_Eligible``
#  .. _is_Environment_Solution_Eligible:
#
#  is_Environment_Solution_Eligible
#  --------------------------------
#
#   .. command:: is_Environment_Solution_Eligible(RESULT index)
#
#   Evaluate if a solution can be used for current host.
#
#     :index: the index of the solution in the list of solutions.
#
#     :RESULT: the output variable that is TRUE if current host can use this solution to set build related variables.
#
function(is_Environment_Solution_Eligible RESULT index)
  set(${RESULT} FALSE PARENT_SCOPE)
  #check if current host can find a solution
  if(${PROJECT_NAME}_SOLUTION_${index}_DISTRIBUTION)# a constraint on distribution
    if(NOT ${PROJECT_NAME}_SOLUTION_${index}_DISTRIBUTION STREQUAL CURRENT_DISTRIBUTION)#not the current one
      return()
    endif()
    #check if an additional constraint on version applies
    if(${PROJECT_NAME}_SOLUTION_${index}_DISTRIB_VERSION)# a constraint on version of distribution
      if(NOT ${PROJECT_NAME}_SOLUTION_${index}_DISTRIB_VERSION STREQUAL CURRENT_DISTRIBUTION_VERSION)#not the current version
        return()
      endif()
    endif()
  endif()

  if(${PROJECT_NAME}_SOLUTION_${index}_ARCH)# a constraint on processor architecture
    if(NOT ${PROJECT_NAME}_SOLUTION_${index}_ARCH STREQUAL CURRENT_PLATFORM_ARCH)#not the current one
      return()
    endif()
  endif()
  if(${PROJECT_NAME}_SOLUTION_${index}_TYPE)# a constraint on processor architecture
    if(NOT ${PROJECT_NAME}_SOLUTION_${index}_TYPE STREQUAL CURRENT_PLATFORM_TYPE)#not the current one
      return()
    endif()
  endif()
  if(${PROJECT_NAME}_SOLUTION_${index}_OS)# a constraint on kernel
    if(NOT ${PROJECT_NAME}_SOLUTION_${index}_OS STREQUAL CURRENT_PLATFORM_OS)#not the current one
      return()
    endif()
  endif()
  if(${PROJECT_NAME}_SOLUTION_${index}_ABI)# a constraint on processor architecture type
    compare_ABIs(ARE_EQUAL "${${PROJECT_NAME}_SOLUTION_${index}_ABI}" "${CURRENT_PLATFORM_ABI}")
    if(NOT ARE_EQUAL)#not the current one
      return()
    endif()
  endif()
  set(${RESULT} TRUE PARENT_SCOPE)

endfunction(is_Environment_Solution_Eligible)

#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Environment_Solution| replace:: ``evaluate_Environment_Solution``
#  .. _evaluate_Environment_Solution:
#
#  evaluate_Environment_Solution
#  -----------------------------
#
#   .. command:: evaluate_Environment_Solution(EVAL_SOL_RESULT index)
#
#   Evaluate a solution provided by the environment. If
#
#     :index: the index of the solution in the list of solutions.
#
#     :EVAL_SOL_RESULT: the output variable that is TRUE if current host uses this solution to set build related variables.
#
function(evaluate_Environment_Solution EVAL_SOL_RESULT index)
  set(${EVAL_SOL_RESULT} FALSE PARENT_SCOPE)

  # from here we know that the platform (host VS target constraints defined) matches so the solution can be evaluated
  foreach(dep IN LISTS ${PROJECT_NAME}_SOLUTION_${index}_DEPENDENCIES)
    manage_Environment_Dependency(RESULT_DEP ${dep})
    if(NOT RESULT_DEP)
      message("[PID] WARNING: environment ${dep} used as a dependency of ${PROJECT_NAME} cannot find a valid solution.")
      return()
    endif()
  endforeach()
  # from here, means that everything is OK and specific configuration, if any, can apply
  if(${PROJECT_NAME}_SOLUTION_${index}_CONFIGURE)# a configuration script is provided => there is some more configuration to do
    if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_SOLUTION_${index}_CONFIGURE})#addintionnal check is required to manage input constraints
      message(FATAL_ERROR "[PID] CRITICAL ERROR: the file ${${PROJECT_NAME}_SOLUTION_${index}_CONFIGURE} cannot be found in src folder of ${PROJECT_NAME}")
      return()
    endif()
    set(ENVIRONMENT_CONFIG_RESULT TRUE CACHE INTERNAL "")
    include(src/${${PROJECT_NAME}_SOLUTION_${index}_CONFIGURE})# we need to configure host with adequate tools
    if(NOT ENVIRONMENT_CONFIG_RESULT)# toolsets configuration OK (may mean crosscompiling)
      return()
    endif()
  endif()
  set(${EVAL_SOL_RESULT} TRUE PARENT_SCOPE)
endfunction(evaluate_Environment_Solution)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Environment_Configuration_Constraint| replace:: ``check_Environment_Configuration_Constraint``
#  .. _check_Environment_Configuration_Constraint:
#
#  check_Environment_Configuration_Constraint
#  ------------------------------------------
#
#   .. command:: check_Environment_Configuration_Constraint(CHECK_RESULT)
#
#   Check if the current platform satisfies the target platform configuration.
#
#     :index: the index of the solution in the list of solutions.
#
#     :CHECK_RESULT: the output variable that is TRUE if current host satisfies configuration constraints.
#
function(check_Environment_Configuration_Constraint CHECK_RESULT)
  foreach(config IN LISTS ${PROJECT_NAME}_CONFIGURATION_CONSTRAINT)

    check_System_Configuration(RESULT NAME CONSTRAINTS "${config}" Release)
    if(NOT RESULT)
      set(${CHECK_RESULT} FALSE PARENT_SCOPE)
    endif()
  endforeach()
  set(${CHECK_RESULT} TRUE PARENT_SCOPE)
endfunction(check_Environment_Configuration_Constraint)

#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Environment_Constraints| replace:: ``evaluate_Environment_Constraints``
#  .. _evaluate_Environment_Constraints:
#
#  evaluate_Environment_Constraints
#  --------------------------------
#
#   .. command:: evaluate_Environment_Constraints()
#
#   Evaluate the constraints in order to create adequate variables usable in environment script files.
#
function(evaluate_Environment_Constraints)
foreach(opt IN LISTS ${PROJECT_NAME}_OPTIONAL_CONSTRAINTS)
  if(opt AND DEFINED VAR_${opt}) #cmake variable containing the input variable exist => input variable passed by the user
    string(REPLACE " " "" VAL_LIST "${VAR_${opt}}")#remove the spaces in the string if any
    string(REPLACE "," ";" VAL_LIST "${VAL_LIST}")#generate an argument list (with "," delim) from a cmake list (with ";" as delimiter)
    set(${PROJECT_NAME}_${opt} ${VAL_LIST} PARENT_SCOPE)#create the local variable used in scripts
  endif()
endforeach()

foreach(req IN LISTS ${PROJECT_NAME}_REQUIRED_CONSTRAINTS)
  if(NOT DEFINED VAR_${req}) #cmake variable containing the input variable exist => input variable passed by the user
    message(FATAL_ERROR "[PID] CRITICAL ERROR: environment ${PROJECT_NAME} requires ${req} to be defined.")
    return()
  endif()
  string(REPLACE " " "" VAL_LIST "${VAR_${req}}")#remove the spaces in the string if any
  string(REPLACE "," ";" VAL_LIST "${VAL_LIST}")#generate an argument list (with "," delim) from a cmake list (with ";" as delimiter)
  set(${PROJECT_NAME}_${req} ${VAL_LIST} PARENT_SCOPE)#create the local variable used in scripts
endforeach()
#also evaluate constraints coming from dependent environment
if(FORCE_${PROJECT_NAME}_ARCH_CONSTRAINT) #arch constraint has been forced
  if(${PROJECT_NAME}_ARCH_CONSTRAINT AND (NOT ${PROJECT_NAME}_ARCH_CONSTRAINT STREQUAL FORCE_${PROJECT_NAME}_ARCH_CONSTRAINT))
    message(FATAL_ERROR "[PID] CRITICAL ERROR: environment ${PROJECT_NAME} defines a constraint on processor architecture (${${PROJECT_NAME}_ARCH_CONSTRAINT}) but a dependent environment imposes a different one (${FORCE_${PROJECT_NAME}_ARCH_CONSTRAINT}).")
    return()
  else()
    set(${PROJECT_NAME}_ARCH_CONSTRAINT ${FORCE_${PROJECT_NAME}_ARCH_CONSTRAINT} CACHE INTERNAL "")#set its value
  endif()
endif()
if(FORCE_${PROJECT_NAME}_TYPE_CONSTRAINT)
  if(${PROJECT_NAME}_TYPE_CONSTRAINT AND (NOT ${PROJECT_NAME}_TYPE_CONSTRAINT STREQUAL FORCE_${PROJECT_NAME}_TYPE_CONSTRAINT))
    message(FATAL_ERROR "[PID] CRITICAL ERROR: environment ${PROJECT_NAME} defines a constraint on processor architecture size (${${PROJECT_NAME}_TYPE_CONSTRAINT}) but a dependent environment imposes a different one (${FORCE_${PROJECT_NAME}_TYPE_CONSTRAINT}).")
    return()
  else()
    set(${PROJECT_NAME}_TYPE_CONSTRAINT ${FORCE_${PROJECT_NAME}_TYPE_CONSTRAINT} CACHE INTERNAL "")#set its value
  endif()
endif()
if(FORCE_${PROJECT_NAME}_OS_CONSTRAINT)
  if(${PROJECT_NAME}_OS_CONSTRAINT AND (NOT ${PROJECT_NAME}_OS_CONSTRAINT STREQUAL FORCE_${PROJECT_NAME}_OS_CONSTRAINT))
    message(FATAL_ERROR "[PID] CRITICAL ERROR: environment ${PROJECT_NAME} defines a constraint on operating system (${${PROJECT_NAME}_OS_CONSTRAINT}) but a dependent environment imposes a different one (${FORCE_${PROJECT_NAME}_OS_CONSTRAINT}).")
    return()
  else()
    set(${PROJECT_NAME}_OS_CONSTRAINT ${FORCE_${PROJECT_NAME}_OS_CONSTRAINT} CACHE INTERNAL "")#set its value
  endif()
endif()
if(FORCE_${PROJECT_NAME}_ABI_CONSTRAINT)
  if(${PROJECT_NAME}_ABI_CONSTRAINT AND (NOT ${PROJECT_NAME}_ABI_CONSTRAINT STREQUAL FORCE_${PROJECT_NAME}_ABI_CONSTRAINT))
    message(FATAL_ERROR "[PID] CRITICAL ERROR: environment ${PROJECT_NAME} defines a constraint on C++ ABI (${${PROJECT_NAME}_ABI_CONSTRAINT}) but a dependent environment imposes a different one (${FORCE_${PROJECT_NAME}_ABI_CONSTRAINT}).")
    return()
  else()
    set(${PROJECT_NAME}_ABI_CONSTRAINT ${FORCE_${PROJECT_NAME}_ABI_CONSTRAINT} CACHE INTERNAL "")#set its value
  endif()
endif()
if(FORCE_${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT)
  if(${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT AND (NOT ${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT STREQUAL FORCE_${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT))
    message(FATAL_ERROR "[PID] CRITICAL ERROR: environment ${PROJECT_NAME} defines a constraint on OS distribution (${${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT}) but a dependent environment imposes a different one (${FORCE_${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT}).")
    return()
  else()
    set(${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT ${FORCE_${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT} CACHE INTERNAL "")#set its value
  endif()
  if(FORCE_${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT)
    if(${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT AND (NOT ${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT STREQUAL FORCE_${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT))
      message(FATAL_ERROR "[PID] CRITICAL ERROR: environment ${PROJECT_NAME} defines a constraint on OS distribution version (${${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT}) but a dependent environment imposes a different one (${FORCE_${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT}).")
      return()
    else()
      set(${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT ${FORCE_${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT} CACHE INTERNAL "")#set its value
    endif()
  endif()
endif()
if(FORCE_${PROJECT_NAME}_CONFIGURATION_CONSTRAINT)
  #simply add configuration constraints to those already defined
  append_Unique_In_Cache(${PROJECT_NAME}_CONFIGURATION_CONSTRAINT "${FORCE_${PROJECT_NAME}_CONFIGURATION_CONSTRAINT}")
endif()
endfunction(evaluate_Environment_Constraints)


#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Environment_Toolchain_File| replace:: ``generate_Environment_Toolchain_File``
#  .. _generate_Environment_Toolchain_File:
#
#  generate_Environment_Toolchain_File
#  -----------------------------------
#
#   .. command:: generate_Environment_Toolchain_File(index)
#
#   Create the toochain file for the given solution used to configure the workspace.
#
#     :index: the index of the solution in the list of solutions.
#
function(generate_Environment_Toolchain_File index)
  set(description_file ${CMAKE_BINARY_DIR}/PID_Toolchain.cmake)
  file(WRITE ${description_file} "")

  # setting the generator
  if(${PROJECT_NAME}_GENERATOR)
    file(APPEND ${description_file} "set(CMAKE_GENERATOR ${${PROJECT_NAME}_GENERATOR} CACHE INTERNAL \"\" FORCE)\n")
    file(APPEND ${description_file} "set(CMAKE_MAKE_PROGRAM ${${PROJECT_NAME}_MAKE_PROGRAM} CACHE INTERNAL \"\" FORCE)\n")
    if(${PROJECT_NAME}_GENERATOR_EXTRA)
      file(APPEND ${description_file} "set(CMAKE_EXTRA_GENERATOR ${${PROJECT_NAME}_GENERATOR_EXTRA} CACHE INTERNAL \"\" FORCE)\n")
    endif()
    if(${PROJECT_NAME}_GENERATOR_TOOLSET)
      file(APPEND ${description_file} "set(CMAKE_GENERATOR_TOOLSET ${${PROJECT_NAME}_GENERATOR_TOOLSET} CACHE INTERNAL \"\" FORCE)\n")
    endif()
    if(${PROJECT_NAME}_GENERATOR_PLATFORM)
      file(APPEND ${description_file} "set(CMAKE_GENERATOR_PLATFORM ${${PROJECT_NAME}_GENERATOR_PLATFORM} CACHE INTERNAL \"\" FORCE)\n")
    endif()
    if(${PROJECT_NAME}_GENERATOR_INSTANCE)
      file(APPEND ${description_file} "set(CMAKE_GENERATOR_INSTANCE ${${PROJECT_NAME}_GENERATOR_INSTANCE} CACHE INTERNAL \"\" FORCE)\n")
    endif()
  endif()

  if(${PROJECT_NAME}_CROSSCOMPILATION)
    #when cross compiling need to set target system name and processor
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_NAME ${${PROJECT_NAME}_TARGET_SYSTEM_NAME} CACHE INTERNAL \"\" FORCE)\n")
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_PROCESSOR ${${PROJECT_NAME}_TARGET_SYSTEM_PROCESSOR} CACHE INTERNAL \"\" FORCE)\n")
    if(NOT ${PROJECT_NAME}_TARGET_SYSTEM_NAME STREQUAL Generic) # cas where there is a kernel in use (e.g. building for microcontrollers)
      #we need a sysroot to the target operating system filesystem ! => defined by user !!
      if(NOT ${PROJECT_NAME}_TARGET_SYSROOT)#sysroot is necessary when cross compiling to another OS
        message(FATAL_ERROR "[PID] ERROR: you must give a sysroot by using the sysroot argument when calling configure.")
        return()
      endif()
      file(APPEND ${description_file} "set(CMAKE_SYSROOT ${${PROJECT_NAME}_TARGET_SYSROOT} CACHE INTERNAL \"\" FORCE)\n")
      if(${PROJECT_NAME}_TARGET_STAGING)
        file(APPEND ${description_file} "set(CMAKE_STAGING_PREFIX ${${PROJECT_NAME}_TARGET_STAGING} CACHE INTERNAL \"\" FORCE)\n")
      endif()
    endif()
  endif()

  # add build tools variables  to the toolset
  if(${PROJECT_NAME}_CROSSCOMPILATION AND CMAKE_VERSION VERSION_LESS 3.6)#when crosscompiling I need to force the C/C++ compilers if CMake < 3.6
    file(APPEND ${description_file} "include(CMakeForceCompiler)\n")
  endif()
  foreach(lang IN ITEMS C CXX ASM Fortran Python CUDA)
    #simply registering the compiler, id, version and flags
    if(NOT lang STREQUAL "Python")
      if(${PROJECT_NAME}_${lang}_COMPILER)#compiler has been set
        if(${PROJECT_NAME}_CROSSCOMPILATION  #during crosscomppilation
          AND lang MATCHES "C|CXX|Fortran"   #force commands are only available for those languages
          AND CMAKE_VERSION VERSION_LESS 3.6)#in CMake < 3.6
          #when crosscompiling force no check of compilers
          file(APPEND ${description_file} "CMAKE_FORCE_${lang}_COMPILER(${${PROJECT_NAME}_${lang}_COMPILER} \"${${PROJECT_NAME}_${lang}_COMPILER_ID}\")\n")
          if(lang STREQUAL C)#if no check then the CMAKE_SIZE_OF_VOID_P must be set !!
            if(${PROJECT_NAME}_ARCH_CONSTRAINT)#if any constraint has been defined
              math(EXPR register_size "${${PROJECT_NAME}_ARCH_CONSTRAINT}/8")
            else()
              math(EXPR register_size "${CURRENT_PLATFORM_ARCH}/8")
            endif()
            #need to add this variable if I force the compiler => allow PID to finnaly deduce architecture from build configuration
            file(APPEND ${description_file} "set(CMAKE_SIZEOF_VOID_P ${register_size} CACHE INETRNAL \"\" FORCE)\n")
          endif()
        endif()
        #add the default command for setting compiler anytime
        file(APPEND ${description_file} "set(CMAKE_${lang}_COMPILER ${${PROJECT_NAME}_${lang}_COMPILER} CACHE INTERNAL \"\" FORCE)\n")
      endif()

      if(${PROJECT_NAME}_${lang}_COMPILER_FLAGS)
        fill_String_From_List(${PROJECT_NAME}_${lang}_COMPILER_FLAGS LANG_FLAGS)
        file(APPEND ${description_file} "set(CMAKE_${lang}_FLAGS  \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
      endif()
      if(lang STREQUAL CUDA)
        if(${PROJECT_NAME}_${lang}_COMPILER)
          file(APPEND ${description_file} "set(CUDA_NVCC_EXECUTABLE ${${PROJECT_NAME}_${lang}_COMPILER} CACHE INTERNAL \"\" FORCE)\n")
        endif()
        if(${PROJECT_NAME}_${lang}_COMPILER_FLAGS)
          fill_String_From_List(${PROJECT_NAME}_${lang}_COMPILER_FLAGS LANG_FLAGS)
          file(APPEND ${description_file} "set(CUDA_NVCC_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
        endif()
        if(${PROJECT_NAME}_${lang}_HOST_COMPILER)
          file(APPEND ${description_file} "set(CUDA_HOST_COMPILER ${${PROJECT_NAME}_${lang}_HOST_COMPILER} CACHE INTERNAL \"\" FORCE)\n")
          file(APPEND ${description_file} "set(CMAKE_CUDA_HOST_COMPILER ${${PROJECT_NAME}_${lang}_HOST_COMPILER} CACHE INTERNAL \"\" FORCE)\n")
        endif()
      else()
        if(${PROJECT_NAME}_${lang}_AR)
          file(APPEND ${description_file} "set(CMAKE_${lang}_AR ${${PROJECT_NAME}_${lang}_AR} CACHE INTERNAL \"\" FORCE)\n")
        endif()
        if(${PROJECT_NAME}_${lang}_RANLIB)
          file(APPEND ${description_file} "set(CMAKE_${lang}_RANLIB ${${PROJECT_NAME}_${lang}_RANLIB} CACHE INTERNAL \"\" FORCE)\n")
        endif()
      endif()
    else()#for python
      if(${PROJECT_NAME}_${lang}_INTERPRETER)
        file(APPEND ${description_file} "set(PYTHON_EXECUTABLE ${${PROJECT_NAME}_${lang}_INTERPRETER} CACHE INTERNAL \"\" FORCE)\n")
        if(${PROJECT_NAME}_${lang}_INCLUDE_DIRS)
          fill_String_From_List(${PROJECT_NAME}_${lang}_INCLUDE_DIRS LANG_FLAGS)
        file(APPEND ${description_file} "set(PYTHON_INCLUDE_DIRS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
        endif()
        if(${PROJECT_NAME}_${lang}_LIBRARY)
          file(APPEND ${description_file} "set(PYTHON_LIBRARY ${${PROJECT_NAME}_${lang}_LIBRARY} CACHE INTERNAL \"\" FORCE)\n")
        endif()
      endif()
    endif()
  endforeach()
  if(${PROJECT_NAME}_LINKER)
    file(APPEND ${description_file} "set(CMAKE_LINKER ${${PROJECT_NAME}_LINKER} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_EXE_LINKER_FLAGS)
    fill_String_From_List(${PROJECT_NAME}_EXE_LINKER_FLAGS LANG_FLAGS)
    file(APPEND ${description_file} "set(CMAKE_EXE_LINKER_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_MODULE_LINKER_FLAGS)
    fill_String_From_List(${PROJECT_NAME}_MODULE_LINKER_FLAGS LANG_FLAGS)
    file(APPEND ${description_file} "set(CMAKE_MODULE_LINKER_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_SHARED_LINKER_FLAGS)
    fill_String_From_List(${PROJECT_NAME}_SHARED_LINKER_FLAGS LANG_FLAGS)
    file(APPEND ${description_file} "set(CMAKE_SHARED_LINKER_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_STATIC_LINKER_FLAGS)
    fill_String_From_List(${PROJECT_NAME}_STATIC_LINKER_FLAGS LANG_FLAGS)
    file(APPEND ${description_file} "set(CMAKE_STATIC_LINKER_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
  endif()

  if(${PROJECT_NAME}_AR)
    file(APPEND ${description_file} "set(CMAKE_AR ${${PROJECT_NAME}_AR} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_RANLIB)
    file(APPEND ${description_file} "set(CMAKE_RANLIB ${${PROJECT_NAME}_RANLIB} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_NM)
    file(APPEND ${description_file} "set(CMAKE_NM ${${PROJECT_NAME}_NM} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_OBJDUMP)
    file(APPEND ${description_file} "set(CMAKE_OBJDUMP ${${PROJECT_NAME}_OBJDUMP} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_OBJCOPY)
    file(APPEND ${description_file} "set(CMAKE_OBJCOPY ${${PROJECT_NAME}_OBJCOPY} CACHE INTERNAL \"\" FORCE)\n")
  endif()

  if(${PROJECT_NAME}_LIBRARY_DIRS)
    fill_String_From_List(${PROJECT_NAME}_LIBRARY_DIRS DIRS)
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_LIBRARY_PATH ${DIRS} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_INCLUDE_DIRS)
    fill_String_From_List(${PROJECT_NAME}_INCLUDE_DIRS DIRS)
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_INCLUDE_PATH ${DIRS} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_PROGRAM_DIRS)
    fill_String_From_List(${PROJECT_NAME}_PROGRAM_DIRS DIRS)
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_PROGRAM_PATH ${DIRS} CACHE INTERNAL \"\" FORCE)\n")
  endif()

  if(${PROJECT_NAME}_CROSSCOMPILATION)
    if(NOT CMAKE_VERSION VERSION_LESS 3.6)#CMAKE_TRY_COMPILE_TARGET_TYPE available since version 3.6 of CMake
      # avoid problem with try_compile when cross compiling
      file(APPEND ${description_file} "set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY CACHE INTERNAL \"\" FORCE)\n")
    endif()
  endif()


endfunction(generate_Environment_Toolchain_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Environment_Description_File| replace:: ``generate_Environment_Description_File``
#  .. _generate_Environment_Description_File:
#
#  generate_Environment_Description_File
#  -------------------------------------
#
#   .. command:: generate_Environment_Description_File()
#
#   Create the script file used to configure the workspace with description of the environment.
#
function(generate_Environment_Description_File)
set(description_file ${CMAKE_BINARY_DIR}/PID_Environment_Description.cmake)
set(input_file ${WORKSPACE_DIR}/cmake/patterns/environments/PID_Environment_Description.cmake.in)

set(ENVIRONMENT_DESCRIPTION ${${PROJECT_NAME}_DESCRIPTION})
set(ENVIRONMENT_CROSSCOMPILATION ${${PROJECT_NAME}_CROSSCOMPILATION})
set(ENVIRONMENT_INSTANCE ${PROJECT_NAME})
set(ENVIRONMENT_CI ${IN_CI_PROCESS})
set(ENVIRONMENT_DISTRIBUTION ${${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT})
set(ENVIRONMENT_DISTRIB_VERSION ${${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT})

configure_file(${input_file} ${description_file} @ONLY)
endfunction(generate_Environment_Description_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Environment_Solution_File| replace:: ``generate_Environment_Solution_File``
#  .. _generate_Environment_Solution_File:
#
#  generate_Environment_Solution_File
#  ----------------------------------
#
#   .. command:: generate_Environment_Solution_File()
#
#   Create the script file used to manage dependencies between environments.
#
function(generate_Environment_Solution_File)
set(file ${CMAKE_BINARY_DIR}/PID_Environment_Solution_Info.cmake)
file(WRITE ${file} "")#reset the description
file(APPEND ${file} "set(${PROJECT_NAME}_CROSSCOMPILATION ${${PROJECT_NAME}_CROSSCOMPILATION} CACHE INTERNAL \"\")\n")

file(APPEND ${file} "set(${PROJECT_NAME}_TARGET_SYSTEM_NAME ${${PROJECT_NAME}_TARGET_SYSTEM_NAME} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_TARGET_SYSTEM_PROCESSOR ${${PROJECT_NAME}_TARGET_SYSTEM_PROCESSOR} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_TARGET_SYSROOT ${${PROJECT_NAME}_TARGET_SYSROOT} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_TARGET_STAGING ${${PROJECT_NAME}_TARGET_STAGING} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_LIBRARY_DIRS ${${PROJECT_NAME}_LIBRARY_DIRS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_INCLUDE_DIRS ${${PROJECT_NAME}_INCLUDE_DIRS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PROGRAM_DIRS ${${PROJECT_NAME}_PROGRAM_DIRS} CACHE INTERNAL \"\")\n")

foreach(lang IN ITEMS C CXX ASM Python Fortran CUDA)
  if(NOT lang STREQUAL Python)
    file(APPEND ${file} "set(${PROJECT_NAME}_${lang}_COMPILER ${${PROJECT_NAME}_${lang}_COMPILER} CACHE INTERNAL \"\")\n")
    file(APPEND ${file} "set(${PROJECT_NAME}_${lang}_COMPILER_ID ${${PROJECT_NAME}_${lang}_COMPILER_ID} CACHE INTERNAL \"\")\n")

    file(APPEND ${file} "set(${PROJECT_NAME}_${lang}_COMPILER_FLAGS ${${PROJECT_NAME}_${lang}_COMPILER_FLAGS} CACHE INTERNAL \"\")\n")
    if(lang STREQUAL CUDA)
      file(APPEND ${file} "set(${PROJECT_NAME}_${lang}_HOST_COMPILER ${${PROJECT_NAME}_${lang}_HOST_COMPILER} CACHE INTERNAL \"\")\n")
    else()
      file(APPEND ${file} "set(${PROJECT_NAME}_${lang}_AR ${${PROJECT_NAME}_${lang}_AR} CACHE INTERNAL \"\")\n")
      file(APPEND ${file} "set(${PROJECT_NAME}_${lang}_RANLIB ${${PROJECT_NAME}_${lang}_RANLIB} CACHE INTERNAL \"\")\n")
    endif()
  else()
    file(APPEND ${file} "set(${PROJECT_NAME}_${lang}_INTERPRETER ${${PROJECT_NAME}_${lang}_INTERPRETER} CACHE INTERNAL \"\")\n")
    file(APPEND ${file} "set(${PROJECT_NAME}_${lang}_INCLUDE_DIRS ${${PROJECT_NAME}_${lang}_INCLUDE_DIRS} CACHE INTERNAL \"\")\n")
    file(APPEND ${file} "set(${PROJECT_NAME}_${lang}_LIBRARY ${${PROJECT_NAME}_${lang}_LIBRARY}  CACHE INTERNAL \"\")\n")
  endif()
endforeach()
file(APPEND ${file} "set(${PROJECT_NAME}_LINKER ${${PROJECT_NAME}_LINKER} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_AR ${${PROJECT_NAME}_AR} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_RANLIB ${${PROJECT_NAME}_RANLIB} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_NM ${${PROJECT_NAME}_NM} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_OBJDUMP ${${PROJECT_NAME}_OBJDUMP} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_OBJCOPY ${${PROJECT_NAME}_OBJCOPY} CACHE INTERNAL \"\")\n")

file(APPEND ${file} "set(${PROJECT_NAME}_EXE_LINKER_FLAGS ${${PROJECT_NAME}_EXE_LINKER_FLAGS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_MODULE_LINKER_FLAGS ${${PROJECT_NAME}_MODULE_LINKER_FLAGS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_SHARED_LINKER_FLAGS ${${PROJECT_NAME}_SHARED_LINKER_FLAGS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_STATIC_LINKER_FLAGS ${${PROJECT_NAME}_STATIC_LINKER_FLAGS} CACHE INTERNAL \"\")\n")

file(APPEND ${file} "set(${PROJECT_NAME}_GENERATOR ${${PROJECT_NAME}_GENERATOR} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_GENERATOR_EXTRA ${${PROJECT_NAME}_GENERATOR_EXTRA} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_GENERATOR_TOOLSET ${${PROJECT_NAME}_GENERATOR_TOOLSET} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_GENERATOR_PLATFORM ${${PROJECT_NAME}_GENERATOR_PLATFORM} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_GENERATOR_INSTANCE ${${PROJECT_NAME}_GENERATOR_INSTANCE} CACHE INTERNAL \"\")\n")
endfunction(generate_Environment_Solution_File)
