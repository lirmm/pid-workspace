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
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)

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
  set_Build_Environment_Platform("" "" "" "" "" "" "")

  # reset constraint that can be used to parameterize the environment
  set(${PROJECT_NAME}_ENVIRONMENT_CONSTRAINTS_DEFINED CACHE INTERNAL "")
  set(${PROJECT_NAME}_OPTIONAL_CONSTRAINTS CACHE INTERNAL "")
  set(${PROJECT_NAME}_IN_BINARY_CONSTRAINTS CACHE INTERNAL "")
  set(${PROJECT_NAME}_REQUIRED_CONSTRAINTS CACHE INTERNAL "")
  set(${PROJECT_NAME}_CHECK  CACHE INTERNAL "")
  foreach(var IN LISTS ${PROJECT_NAME}_RETURNED_VARIABLES)
    set(${PROJECT_NAME}_${var}_RETURNED_VARIABLE CACHE INTERNAL "")
  endforeach()
  set(${PROJECT_NAME}_RETURNED_VARIABLES CACHE INTERNAL "")

  set(${PROJECT_NAME}_DEPENDENCIES CACHE INTERNAL "")

  # reset environment solutions
  if(${PROJECT_NAME}_SOLUTIONS GREATER 0)
    math(EXPR max "${${PROJECT_NAME}_SOLUTIONS}-1")
    foreach(sol RANGE ${max})#clean the memory
      #reset all info for that solution
      set_Environment_Solution(${sol} "" "" "" "" "" "" "")
    endforeach()
  endif()
  set(${PROJECT_NAME}_SOLUTIONS 0 CACHE INTERNAL "")

  #### reset computed information for build ####
  #reset compiler settings issue from finding procedure
  foreach(lang IN LISTS ${PROJECT_NAME}_LANGUAGES)#C CXX ASM Fortran CUDA
    if(${PROJECT_NAME}_${lang}_TOOLSETS GREATER 0)#some toolset already defined
      math(EXPR max_toolset "${${PROJECT_NAME}_${lang}_TOOLSETS}-1")
      foreach(toolset RANGE ${max_toolset})
        set_Language_Toolset(${lang} ${toolset} "" "" "" "" "" "" "" "" "" "" "" "")
      endforeach()
    endif()
    set(${PROJECT_NAME}_${lang}_TOOLSETS 0 CACHE INTERNAL "")
  endforeach()
  set(${PROJECT_NAME}_LANGUAGES CACHE INTERNAL "")
  set(${PROJECT_NAME}_SYSTEM_WIDE_CONFIGURATION FALSE CACHE INTERNAL "")

  foreach(tool IN LISTS ${PROJECT_NAME}_EXTRA_TOOLS)
    set_Extra_Tool(${tool} "" "" "" "" "" "" "" "" "" "")
  endforeach()
  set(${PROJECT_NAME}_EXTRA_TOOLS CACHE INTERNAL "")

  set(${PROJECT_NAME}_LINKER CACHE INTERNAL "")#full path to linker tool
  set(${PROJECT_NAME}_AR CACHE INTERNAL "")
  set(${PROJECT_NAME}_RANLIB CACHE INTERNAL "")
  set(${PROJECT_NAME}_NM CACHE INTERNAL "")
  set(${PROJECT_NAME}_OBJDUMP CACHE INTERNAL "")
  set(${PROJECT_NAME}_OBJCOPY CACHE INTERNAL "")
  set(${PROJECT_NAME}_RPATH CACHE INTERNAL "")
  set(${PROJECT_NAME}_EXE_LINKER_FLAGS CACHE INTERNAL "")
  set(${PROJECT_NAME}_MODULE_LINKER_FLAGS CACHE INTERNAL "")
  set(${PROJECT_NAME}_SHARED_LINKER_FLAGS CACHE INTERNAL "")
  set(${PROJECT_NAME}_STATIC_LINKER_FLAGS CACHE INTERNAL "")
  set(${PROJECT_NAME}_INCLUDE_DIRS CACHE INTERNAL "")
  set(${PROJECT_NAME}_LIBRARY_DIRS CACHE INTERNAL "")
  set(${PROJECT_NAME}_PROGRAM_DIRS CACHE INTERNAL "")
  # variable to manage generator in use
  set(${PROJECT_NAME}_GENERATOR_TOOLSET CACHE INTERNAL "")
  set(${PROJECT_NAME}_GENERATOR_PLATFORM CACHE INTERNAL "")
  # specific for crosscompilation
  set(${PROJECT_NAME}_TARGET_SYSROOT CACHE INTERNAL "")
  set(${PROJECT_NAME}_TARGET_STAGING CACHE INTERNAL "")
endfunction(reset_Environment_Description)


#.rst:
#
# .. ifmode:: internal
#
#  .. |load_Workspace_Global_Info| replace:: ``load_Workspace_Global_Info``
#  .. _load_Workspace_Global_Info:
#
#  load_Workspace_Global_Info
#  --------------------------------
#
#   .. command:: load_Workspace_Global_Info()
#
#     Load into current context the workspae global options
#
function(load_Workspace_Global_Info)
	include(${WORKSPACE_DIR}/build/Workspace_Global_Info.cmake)
endfunction(load_Workspace_Global_Info)

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
#   .. command:: declare_Environment(author institution mail year license address public_address description contrib_space info)
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
#      :info: description of the action of the environment.
#
macro(declare_Environment author institution mail year license address public_address description contrib_space info)
  reset_Environment_Description()#reset variables generated by the environment
  file(RELATIVE_PATH DIR_NAME ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})

  load_Current_Contribution_Spaces()
  load_Workspace_Global_Info()

  configure_Git()#checking git usable
  if(NOT GIT_CONFIGURED)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR: your git tool is NOT configured. To use PID you need to configure git:\ngit config --global user.name \"Your Name\"\ngit config --global user.email <your email address>\n")
  	return()
  endif()

  update_Git_Ignore_File(${WORKSPACE_DIR}/cmake/patterns/environments/environment/.gitignore)

  if(NOT DIR_NAME STREQUAL "build")
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : please run cmake in the build folder of the environment ${PROJECT_NAME}.")
  	return()
  endif()

  #reset environment description
  init_Meta_Info_Cache_Variables("${author}" "${institution}" "${mail}" "${description}" "${year}" "${license}" "${address}" "${public_address}" "" "" "" "" "")
	declare_Environment_Global_Cache_Options()
  set_Cache_Entry_For_Default_Contribution_Space("${contrib_space}")
  set(action_info ${info})
  fill_String_From_List(RES_INFO action_info " ")
  set(${PROJECT_NAME}_ACTION_INFO "${RES_INFO}" CACHE INTERNAL "")
  check_For_Remote_Respositories("${ADDITIONAL_DEBUG_INFO}")#configuring git remotes
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
option(ADDITIONAL_DEBUG_INFO "Getting more info on debug mode or more PID messages (hidden by default)" OFF)
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
#   .. command:: define_Build_Environment_Platform(type_constraint arch_constraint os_constraint abi_constraint distribution distrib_version)
#
#   Define platform targetted by the curren environment. It consists in setting adequate internal cache variables.
#
#      :instance: constraint on platform instance name
#      :type_constraint: constraint on processor architecture type constraint (x86 or arm for instance)
#      :arch_constraint: constraint on processor architecture (16, 32, 64)
#      :os_constraint: constraint on operating system (linux, freebsd, macos, windows).
#      :abi_constraint: constraint on abi in use (98 or 11).
#      :distribution: constraint on operating system distribution in use (e.g. ubuntu, debian).
#      :distrib_version: constraint on operating system distribution in use (e.g. for ubuntu 16.04).
#
function(define_Build_Environment_Platform instance type_constraint arch_constraint os_constraint abi_constraint distribution distrib_version)
  set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_DEFINED TRUE CACHE INTERNAL "")
  set_Build_Environment_Platform( "${instance}"
                                  "${type_constraint}"
                                  "${arch_constraint}"
                                  "${os_constraint}"
                                  "${abi_constraint}"
                                  "${distribution}"
                                  "${distrib_version}")
endfunction(define_Build_Environment_Platform)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Build_Environment_Platform| replace:: ``set_Build_Environment_Platform``
#  .. _set_Build_Environment_Platform:
#
#  set_Build_Environment_Platform
#  ---------------------------------
#
#   .. command:: set_Build_Environment_Platform(type_constraint arch_constraint os_constraint abi_constraint distribution distrib_version)
#
#   Auxiliary function to set platform constraints.
#
#      :instance: constraint on platform instance name
#      :type_constraint: constraint on processor architecture type constraint (x86 or arm for instance)
#      :arch_constraint: constraint on processor architecture (16, 32, 64)
#      :os_constraint: constraint on operating system (linux, freebsd, macos, windows).
#      :abi_constraint: constraint on abi in use (98 or 11).
#      :distribution: constraint on operating system distribution in use (e.g. ubuntu, debian).
#      :distrib_version: constraint on operating system distribution in use (e.g. for ubuntu 16.04).
#
function(set_Build_Environment_Platform instance type_constraint arch_constraint os_constraint abi_constraint distribution distrib_version)
  set(${PROJECT_NAME}_TARGET_INSTANCE ${instance} CACHE INTERNAL "")
  set(${PROJECT_NAME}_TYPE_CONSTRAINT ${type_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_ARCH_CONSTRAINT ${arch_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_OS_CONSTRAINT ${os_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_ABI_CONSTRAINT ${abi_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT ${distribution} CACHE INTERNAL "")
  set(${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT ${distrib_version} CACHE INTERNAL "")
endfunction(set_Build_Environment_Platform)

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
#   .. command:: define_Environment_Constraints(optional_vars in_binary_vars check_script)
#
#   Define all constraint that can be used with the current environment, in order to configure it.
#
#      :optional_vars: the list of optional variables that specify constraints. Optional means that user do not need to provide a value for these variables.
#      :required_vars: the list of required variables that specify constraints. Required means that user must provide a value for these variables.
#      :in_binary_vars: the list of required variables that specify constraints. IN Binary means optional but will be used in in in binary description of the environment.
#      :check_script: the path (relative to src folder) of the check script used to determine if current CMake configuration matches constraints.
#
function(define_Environment_Constraints optional_vars required_vars in_binary_vars check_script)
  set(${PROJECT_NAME}_ENVIRONMENT_CONSTRAINTS_DEFINED TRUE CACHE INTERNAL "")
  set(${PROJECT_NAME}_OPTIONAL_CONSTRAINTS ${optional_vars} CACHE INTERNAL "")
  set(${PROJECT_NAME}_IN_BINARY_CONSTRAINTS ${in_binary_vars} CACHE INTERNAL "")
  set(${PROJECT_NAME}_REQUIRED_CONSTRAINTS ${required_vars} CACHE INTERNAL "")
  set(${PROJECT_NAME}_CHECK ${check_script} CACHE INTERNAL "")
endfunction(define_Environment_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Environment_Solution| replace:: ``set_Environment_Solution``
#  .. _set_Environment_Solution:
#
#  set_Environment_Solution
#  ------------------------
#
#   .. command:: set_Environment_Solution(index type_constraint arch_constraint os_constraint abi_constraint distribution version check_script configure_script)
#
#    Auxisialry function to set the value of a solution.
#
#      :index: index of the solution to set
#      :type_constraint: filters processor architecture type (arm, x86)
#      :arch_constraint: filters processor architecture (32, 64)
#      :os_constraint: filters operating system
#      :abi_constraint: filters default c++ abi
#      :distribution: filters the distribution of the host.
#      :version: filters the version of the distribution.
#      :configure_script: path relative to src folder of the script file used to configure host in order to make it conforms to environment settings
#
function(set_Environment_Solution index type_constraint arch_constraint os_constraint abi_constraint distribution version configure_script)
  set(${PROJECT_NAME}_SOLUTION_${index}_TYPE ${type_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_SOLUTION_${index}_ARCH ${arch_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_SOLUTION_${index}_OS ${os_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_SOLUTION_${index}_ABI ${abi_constraint} CACHE INTERNAL "")
  set(${PROJECT_NAME}_SOLUTION_${index}_DISTRIBUTION ${distribution} CACHE INTERNAL "")
  set(${PROJECT_NAME}_SOLUTION_${index}_DISTRIB_VERSION ${version} CACHE INTERNAL "")
  set(${PROJECT_NAME}_SOLUTION_${index}_CONFIGURE ${configure_script} CACHE INTERNAL "")
endfunction(set_Environment_Solution)


#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Environment_Dependency| replace:: ``add_Environment_Dependency``
#  .. _add_Environment_Dependency:
#
#  add_Environment_Dependency
#  --------------------------
#
#   .. command:: add_Environment_Dependency(dependency)
#
#    Auxiliary function to add a dependency to the environment.
#
#      :environment_expr: environment constraint expression
#
function(add_Environment_Dependency environment_expr)
  append_Unique_In_Cache(${PROJECT_NAME}_DEPENDENCIES ${environment_expr})
endfunction(add_Environment_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Environment_Solution_Procedure| replace:: ``add_Environment_Solution_Procedure``
#  .. _add_Environment_Solution_Procedure:
#
#  add_Environment_Solution_Procedure
#  ----------------------------------
#
#   .. command:: add_Environment_Solution_Procedure(type_constraint arch_constraint os_constraint abi_constraint distribution version check_script configure_script)
#
#    Define a new solution for configuring the environment.
#
#      :type_constraint: filters processor architecture type (arm, x86)
#      :arch_constraint: filters processor architecture (32, 64)
#      :os_constraint: filters operating system
#      :abi_constraint: filters default c++ abi
#      :distribution: filters the distribution of the host.
#      :version: filters the version of the distribution.
#      :configure_script: path relative to src folder of the script file used to configure host in order to make it conforms to environment settings
#
function(add_Environment_Solution_Procedure type_constraint arch_constraint os_constraint abi_constraint distribution version configure_script)
  set_Environment_Solution(${${PROJECT_NAME}_SOLUTIONS}
                          "${type_constraint}"
                          "${arch_constraint}"
                          "${os_constraint}"
                          "${abi_constraint}"
                          "${distribution}"
                          "${version}"
                          "${configure_script}")
  math(EXPR temp "${${PROJECT_NAME}_SOLUTIONS}+1")
  set(${PROJECT_NAME}_SOLUTIONS ${temp} CACHE INTERNAL "")
endfunction(add_Environment_Solution_Procedure)


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
    -DTARGET_INSTANCE=\${instance}
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
    -DADDITIONAL_DEBUG_INFO=${ADDITIONAL_DEBUG_INFO}
    -P ${WORKSPACE_DIR}/cmake/commands/Build_PID_Environment.cmake
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  )

  add_custom_target(hard_clean
  COMMAND ${CMAKE_COMMAND}
            -DWORKSPACE_DIR=${WORKSPACE_DIR}
            -DTARGET_ENVIRONMENT=${PROJECT_NAME}
            -DADDITIONAL_DEBUG_INFO=${ADDITIONAL_DEBUG_INFO}
            -P ${WORKSPACE_DIR}/cmake/commands/Hard_Clean_PID_Package.cmake
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
    add_custom_target(referencing
      COMMAND ${CMAKE_COMMAND}
              -DWORKSPACE_DIR=${WORKSPACE_DIR}
              -DTARGET_ENVIRONMENT=${PROJECT_NAME}
              -DCMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}
              -DTARGET_CONTRIBUTION_SPACE=${TARGET_CONTRIBUTION_SPACE}
              -DTARGET_CS=\${space}
              -P ${WORKSPACE_DIR}/cmake/commands/Referencing_PID_Deployment_Unit.cmake
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    )
  endif()

  if(NOT EVALUATION_RUN)
    generate_Environment_Inputs_Description_File()
    generate_Environment_Readme_Files() # generating and putting into source directory the readme file used by git hosting service
    generate_Environment_License_File() # generating and putting into source directory the file containing license info about the package
    return()#directly exit
  else()#the build command will do the evaluation run
    message("[PID] INFO: evaluating environment ${PROJECT_NAME} ...")
  endif()

  get_Host_Default_Platform()# get information about host
  evaluate_Environment_Constraints(IN_CONSTRAINTS CONSTRAINTS_OK) #get the parameters passed to the environment
  if(NOT CONSTRAINTS_OK)
    set(EVALUATION_RUN FALSE CACHE INTERNAL "" FORCE)#reset so that new cmake run will not be an evaluation run
    message(FATAL_ERROR "[PID] CRITICAL ERROR: environment ${PROJECT_NAME} cannot fulfill some constraints (see previous logs).")
  endif()
  evaluate_Generator()

  evaluate_Environment_Platform(HOST_MATCHES_TARGET)
  if(NOT HOST_MATCHES_TARGET)#if host does not match all constraints -> we need to configure the toochain using available solutions
    message("[PID] INFO: current host configuration does not satisfy constraints on target platform, need to find a solution...")
  endif()
  evaluate_Environment_Dependencies(EVAL_DEPS)
  if(NOT EVAL_DEPS)
    set(EVALUATION_RUN FALSE CACHE INTERNAL "" FORCE)#reset so that new cmake run will not be an evaluation run
    message(FATAL_ERROR "[PID] CRITICAL ERROR: cannot configure host with environment ${PROJECT_NAME} because there is no valid solution for its dependencies.")
  endif()
  #now evaluate current environment regarding available solutions
  set(valid_solution FALSE)
  if(${PROJECT_NAME}_SOLUTIONS GREATER 0)
    math(EXPR max "${${PROJECT_NAME}_SOLUTIONS}-1")
    foreach(index RANGE ${max})
      is_Environment_Solution_Eligible(SOL_POSSIBLE ${index})
      if(SOL_POSSIBLE)
        evaluate_Environment_Solution(${index})
        if(EVAL_RESULT)# solution check is OK, the solution can be used
          set(valid_solution TRUE)
          break()
        endif()
      endif()
    endforeach()
    if(NOT valid_solution)
      set(EVALUATION_RUN FALSE CACHE INTERNAL "" FORCE)#reset so that new cmake run will not be an evaluation run
      message(FATAL_ERROR "[PID] CRITICAL ERROR: cannot configure host with environment ${PROJECT_NAME}. No valid solution found.")
    endif()
  endif()

  #generate workspace configuration files only if really usefull
  deduce_Platform_Variables()
  compute_Resulting_Environment_Contraints()
  adjust_Environment_Binary_Variables()#need to set the previously computed expression where it is required
  string(SHA1 hashcode "${IN_CONSTRAINTS}")
  generate_Environment_Solution_File("${hashcode}")#generate the global solution file
  generate_Environment_Toolchain_File()#from global solution generate the toolchain file
  set(EVALUATION_RUN FALSE CACHE INTERNAL "" FORCE)#reset so that new cmake run will not be an evaluation run
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
# 1) parse the environment dependency to get its name and args separated
parse_Configuration_Expression(ENV_NAME ENV_ARGS ${environment}) #get environment name from environment expression (extract arguments and base name)

# 2) load the environment if required
load_Environment(LOAD_RESULT ${ENV_NAME})
if(NOT LOAD_RESULT)
  set(${MANAGE_RESULT} FALSE PARENT_SCOPE)
  return()
endif()
# 3) evaluate the dependent environment with current target platform constraints then if OK transfer its build properties to the current environment
evaluate_Environment_From_Environment(GEN_RESULT ${ENV_NAME} "${ENV_ARGS}")
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
  if(ADDITIONAL_DEBUG_INFO)
	   message("[PID] INFO: updating environment ${environment} (this may take a long time)")
  endif()
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
#  .. |generate_Environment_Inputs_File| replace:: ``generate_Environment_Inputs_File``
#  .. _generate_Environment_Inputs_File:
#
#  generate_Environment_Inputs_File
#  --------------------------------
#
#   .. command:: generate_Environment_Inputs_File(environment)
#
#     Configure the target environment in orderto get the filedescribing its inputs.
#
#      :environment: the name of the target environment.
#
#      :RESULT: the output variable that is TRUE if inputs file has been generated.
#
function(generate_Environment_Inputs_File RESULT environment)

  set(environment_build_folder ${WORKSPACE_DIR}/environments/${environment}/build)
  # 1.1 configure environment
  hard_Clean_Build_Folder(${environment_build_folder}) #starting from a clean situation

  load_Profile_Info()
  if(CMAKE_EXTRA_GENERATOR)
    set(generator_used "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
  else()
    set(generator_used "${CMAKE_GENERATOR}")
  endif()

  #for native build system that support instance/toolset/platform specification we need to transmit those option (using a toolchain file, sinec this is the most generic and general way to do)
  if(CMAKE_GENERATOR_INSTANCE OR CMAKE_GENERATOR_TOOLSET OR CMAKE_GENERATOR_PLATFORM)#need to use an instance to set the specific native build tool used
    file(WRITE ${environment_build_folder}/Generator_Instance.cmake "")
    if(CMAKE_GENERATOR_INSTANCE)
      file(APPEND ${environment_build_folder}/Generator_Instance.cmake "set(CMAKE_GENERATOR_INSTANCE ${CMAKE_GENERATOR_INSTANCE})\n")
    endif()
    if(CMAKE_GENERATOR_TOOLSET)
      file(APPEND ${environment_build_folder}/Generator_Instance.cmake "set(CMAKE_GENERATOR_TOOLSET ${CMAKE_GENERATOR_TOOLSET})\n")
    endif()
    if(CMAKE_GENERATOR_PLATFORM)
      file(APPEND ${environment_build_folder}/Generator_Instance.cmake "set(CURRENT_GENERATOR_PLATFORM ${CMAKE_GENERATOR_PLATFORM})\n")
    endif()
    set(toolchain -DCMAKE_TOOLCHAIN_FILE=${environment_build_folder}/Generator_Instance.cmake)
  else()
    set(toolchain)
  endif()
  reset_Profile_Info()#need to reset profile info to its initial value (avoid troubles when changing profile)
  if(NOT ADDITIONAL_DEBUG_INFO)
    set(execute_args OUTPUT_QUIET ERROR_QUIET)
  endif()
  execute_process(COMMAND ${CMAKE_COMMAND}
                  -G "${generator_used}"
                  ${toolchain}
                  -DADDITIONAL_DEBUG_INFO=${ADDITIONAL_DEBUG_INFO}
                  -D IN_CI_PROCESS=${IN_CI_PROCESS} ..
                  WORKING_DIRECTORY ${environment_build_folder}
                  ${execute_args}
                  )#simply ensure that input are generated
  if(NOT EXISTS ${environment_build_folder}/PID_Inputs.cmake)
    set(${RESULT} FALSE PARENT_SCOPE)
    return()
  endif()
  set(${RESULT} TRUE PARENT_SCOPE)
endfunction(generate_Environment_Inputs_File)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Platform_Constraints_Definitions| replace:: ``get_Platform_Constraints_Definitions``
#  .. _get_Platform_Constraints_Definitions:
#
#  get_Platform_Constraints_Definitions
#  ------------------------------------
#
#   .. command:: get_Platform_Constraints_Definitions(RESULT_DEFS environment
#                                                    instance sysroot staging
#                                                    proc_type proc_arch os abi
#                                                    distrib distrib_version)
#
#     Get the list of CMake definitions used to set platform related constraints.
#
#     :environment: the name of the environment.
#     :instance: giving name of the instance.
#     :sysroot: giving path to the sysroot.
#     :staging: giving path to the staging area.
#     :proc_type: constraint on type of processor.
#     :proc_arch: constraint on architecture of processor.
#     :os: constraint on operating system.
#     :abi: constraint on C++ ABI.
#     :distrib: constraint on operating system's distribution.
#     :distrib_version: constraint on version of operating system's distribution.
#
#     :RESULT_DEFS: the output variable containing the list of CMake definitions to pass to configuration process.
#
function(get_Platform_Constraints_Definitions RESULT_DEFS environment instance sysroot staging proc_type proc_arch os abi distrib distrib_version)
  set(result_list)
  if(instance)
    list(APPEND result_list -DFORCE_${environment}_TARGET_INSTANCE=${instance})
  endif()
  if(sysroot)
    list(APPEND result_list -DFORCE_${environment}_TARGET_SYSROOT=${sysroot})
  endif()
  if(staging)
    list(APPEND result_list -DFORCE_${environment}_TARGET_STAGING=${staging})
  endif()
  if(proc_type)
    list(APPEND result_list -DFORCE_${environment}_TYPE_CONSTRAINT=${proc_type})
  endif()
  if(proc_arch)
    list(APPEND result_list -DFORCE_${environment}_ARCH_CONSTRAINT=${proc_arch})
  endif()
  if(os)
    list(APPEND result_list -DFORCE_${environment}_OS_CONSTRAINT=${os})
  endif()
  if(abi)
    list(APPEND result_list -DFORCE_${environment}_ABI_CONSTRAINT=${abi})
  endif()
  if(distrib)
    list(APPEND result_list -DFORCE_${environment}_DISTRIBUTION_CONSTRAINT=${distrib})
  endif()
  if(distrib_version)
    list(APPEND result_list -DFORCE_${environment}_DISTRIB_VERSION_CONSTRAINT=${distrib_version})
  endif()
  #configuration and chgeck scripts are purely local information
  set(${RESULT_DEFS} ${result_list} PARENT_SCOPE)
endfunction(get_Platform_Constraints_Definitions)

#.rst:
#
# .. ifmode:: internal
#
#  .. |prepare_Environment_Arguments| replace:: ``prepare_Environment_Arguments``
#  .. _prepare_Environment_Arguments:
#
#  prepare_Environment_Arguments
#  -------------------------------
#
#   .. command:: prepare_Environment_Arguments(LIST_OF_DEFS environment arguments)
#
#     Set the variables corresponding to environment arguments in the parent scope.
#
#     :environment: the name of the environment to be checked.
#     :arguments: the parent scope variable containing the list of arguments generated from parse_Configuration_Expression.
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
    generate_Value_For_Configuration_Expression_Parameter(VAL_LIST value)
    #generate the variable
    list(APPEND result_list "-DVAR_${name}=${VAL_LIST}")
  endwhile()
  set(${LIST_OF_DEFS} ${result_list} PARENT_SCOPE)
endfunction(prepare_Environment_Arguments)

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
#      :instance: the instance name to use.
#      :sysroot: the path to sysroot.
#      :staging: the path to staging.
#      :type: the target type of processor (x86, arm, etc.).
#      :arch: the target processor architecture (16, 32, 64).
#      :os: the target operating system (e.g. linux)
#      :abi: the target c++ ABI (98 or 11).
#      :distribution: the target OS distribution (e.g. ubuntu)
#      :distrib_version: the target distribution version (e.g. 16.04).
#
#      :EVAL_OK: the output variable that is TRUE if the environment has been evaluated and exitted without errors.
#
function(evaluate_Environment_From_Script EVAL_OK environment instance sysroot staging type arch os abi distribution distrib_version)
set(${EVAL_OK} FALSE PARENT_SCOPE)

# 1. Get CMake definition for variables that are managed by the environment and set by user
set(environment_build_folder ${WORKSPACE_DIR}/environments/${environment}/build)
# 1.1 configure environment
generate_Environment_Inputs_File(FILE_EXISTS ${environment})
# 1.2 import variable description file
if(NOT FILE_EXISTS)
  return()
endif()

include(${environment_build_folder}/PID_Inputs.cmake)

# 1.3 for each variable, look if a corresponfing environment variable exists and if yes create the CMake definition to pass to environment
set(list_of_defs)
foreach(var IN LISTS ${environment}_INPUTS)
  if(DEFINED ENV{${var}})# an environment variable is defined for that constraint
    string(REPLACE " " "" VAL_LIST "$ENV{${var}}")#remove the spaces in the string if any
    string(REPLACE ";" "," VAL_LIST "${VAL_LIST}")#generate an argument list (with "," delim) from a cmake list (with ";" as delimiter)
    list(APPEND list_of_defs "-DVAR_${var}=${VAL_LIST}")
  else()
    list(APPEND list_of_defs -U VAR_${var})
  endif()
endforeach()
# 2. reconfigure the environment

# 2.1 add specific variables like for sysroot, staging and generator in the list of definitions
get_Platform_Constraints_Definitions(PLATFORM_DEFS ${environment} "${instance}" "${sysroot}" "${staging}"
                                     "${type}" "${arch}" "${os}" "${abi}" "${distribution}" "${distrib_version}")

execute_process(COMMAND ${CMAKE_COMMAND}
                -DEVALUATION_RUN=TRUE
                -DADDITIONAL_DEBUG_INFO=${ADDITIONAL_DEBUG_INFO}
                ${PLATFORM_DEFS}
                ${list_of_defs}
                ..
                WORKING_DIRECTORY ${environment_build_folder}
                RESULT_VARIABLE res)


  foreach(var IN LISTS ${environment}_INPUTS)#avoid keeping in memory the environment variable
    if(DEFINED ENV{${var}})# an environment variable is defined for that constraint
      unset(ENV{${var}})
    endif()
  endforeach()

  # 1.2 import variable description file
  if(res OR NOT EXISTS ${environment_build_folder}/PID_Environment_Solution_Info.cmake)
    return()
  endif()

  set(${EVAL_OK} TRUE PARENT_SCOPE)
  # at the end: 2 files, toolchain file (optional, only generated if needed) and environment description in environment build folder
endfunction(evaluate_Environment_From_Script)

#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Environment_From_Environment| replace:: ``evaluate_Environment_From_Environment``
#  .. _evaluate_Environment_From_Environment:
#
#  evaluate_Environment_From_Environment
#  -------------------------------------
#
#   .. command:: evaluate_Environment_From_Environment(EVAL_OK environment)
#
#     configure the environment with platform variables and arguments coming from current environment (or user).
#
#      :environment: the name of the target environment.
#      :list_of_args: the list of arguments passed to the environment
#
#      :EVAL_OK: the output variable that is TRUE if the environment has been evaluated and exitted without errors.
#
function(evaluate_Environment_From_Environment EVAL_OK environment list_of_args)
# 1) clean and configure the environment project with definitions coming from target (even inherited)
# those definitions are : "user variables" (e.g. version) and current platform description (that will impose constraints)

set(toplevel_env_build_folder ${WORKSPACE_DIR}/environments/${PROJECT_NAME}/build)
if(EXISTS ${toplevel_env_build_folder}/PID_Toolchain.cmake)
  set(current_toplevel_toolchain -DCMAKE_TOOLCHAIN_FILE=${toplevel_env_build_folder}/PID_Toolchain.cmake)
else()
  set(current_toplevel_toolchain)
endif()

set(env_build_folder ${WORKSPACE_DIR}/environments/${environment}/build)
#clean the build folder cache
file(REMOVE ${env_build_folder}/CMakeCache.txt ${env_build_folder}/PID_Toolchain.cmake ${env_build_folder}/PID_Environment_Solution_Info.cmake)

#build the list of variables that will be passed to configuration process
prepare_Environment_Arguments(LIST_OF_DEFS_ARGS ${environment} list_of_args)
get_Platform_Constraints_Definitions(PLATFORM_DEFS ${environment}
        "${${PROJECT_NAME}_TARGET_INSTANCE}" "${${PROJECT_NAME}_TARGET_SYSROOT}" "${${PROJECT_NAME}_TARGET_STAGING}"
        "${${PROJECT_NAME}_TYPE_CONSTRAINT}" "${${PROJECT_NAME}_ARCH_CONSTRAINT}"
        "${${PROJECT_NAME}_OS_CONSTRAINT}" "${${PROJECT_NAME}_ABI_CONSTRAINT}"
        "${${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT}" "${${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT}")

execute_process(COMMAND ${CMAKE_COMMAND}
                        -DEVALUATION_RUN=TRUE
                        ${current_toplevel_toolchain}
                        ${LIST_OF_DEFS_ARGS}
                        ${PLATFORM_DEFS} ..
                WORKING_DIRECTORY ${env_build_folder})#configure, then build

# 2) => it should produce a resulting solution info file => including this file locally to get all definitions then apply them to local variables (overwritting).
# locally we manage thoses variables at configuration time. VAR_<name> is the variable for <name> argument.
# The platform is set using same variables as for target platform description but with FORCE_ prefix.

if(NOT EXISTS ${env_build_folder}/PID_Environment_Solution_Info.cmake)
  set(${EVAL_OK} FALSE PARENT_SCOPE)
  return()
endif()
include(${env_build_folder}/PID_Environment_Solution_Info.cmake)
import_Solution_From_Dependency(${environment})
set(${EVAL_OK} TRUE PARENT_SCOPE)
endfunction(evaluate_Environment_From_Environment)


#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Environment_From_Package| replace:: ``evaluate_Environment_From_Package``
#  .. _evaluate_Environment_From_Package:
#
#  evaluate_Environment_From_Package
#  ---------------------------------
#
#   .. command:: evaluate_Environment_From_Package(EVAL_OK environment)
#
#     configure the environment with platform variables and arguments coming from current environment (or user).
#
#      :environment: the name of the target environment.
#      :list_of_args: the list of arguments passed to the environment
#
#      :EVAL_OK: the output variable that is TRUE if the environment has been evaluated and exitted without errors.
#
function(evaluate_Environment_From_Package EVAL_OK environment)
# 1) clean and configure the environment project with definitions coming from target (even inherited)
# those definitions are : "user variables" (e.g. version) and current platform description (that will impose constraints)

set(env_build_folder ${WORKSPACE_DIR}/environments/${environment}/build)
#clean the build folder cache
file(REMOVE ${env_build_folder}/CMakeCache.txt ${env_build_folder}/PID_Toolchain.cmake ${env_build_folder}/PID_Environment_Solution_Info.cmake)

#build the list of variables that will be passed to configuration process
# prepare_Environment_Arguments(LIST_OF_DEFS_ARGS ${environment} list_of_args)TODO
# 1.3 for each variable, look if a corresponfing environment variable exists and if yes create the CMake definition to pass to environment
set(list_of_defs)
foreach(var IN LISTS ${environment}_INPUTS)
  if(DEFINED ${environment}_${var})# variable is defined for that constraint
    string(REPLACE " " "" VAL_LIST "${${environment}_${var}}")#remove the spaces in the string if any
    string(REPLACE ";" "," VAL_LIST "${VAL_LIST}")#generate an argument list (with "," delim) from a cmake list (with ";" as delimiter)
    list(APPEND list_of_defs "-DVAR_${var}=${VAL_LIST}")
  else()
    list(APPEND list_of_defs -U VAR_${var})
  endif()
endforeach()

# Note: using settings of the current target platform (possible since we are in a package/wrapper)
# Note: we still need to manage specific variabels related to crosscompilation to ensure that the environment is corrrectly evaluated
if(NOT default_env STREQUAL "host")
  set(target_sysroot ${${environment}_TARGET_SYSROOT})#cross compilation can take place
  set(target_staging ${${environment}_TARGET_STAGING})#cross compilation can take place
else()
  set(target_sysroot)#no cross compilation
  set(target_staging)#no cross compilation
endif()
get_Platform_Constraints_Definitions(PLATFORM_DEFS ${environment}
        "${CURRENT_PLATFORM_INSTANCE}" "${target_sysroot}" "${target_staging}"
        "${CURRENT_PLATFORM_TYPE}" "${CURRENT_PLATFORM_ARCH}"
        "${CURRENT_PLATFORM_OS}" "${CURRENT_PLATFORM_ABI}"
        "${CURRENT_DISTRIBUTION}" "${CURRENT_DISTRIBUTION_VERSION}")

reevaluate_Host_Default_Platform()
execute_process(COMMAND ${CMAKE_COMMAND}
                        -DEVALUATION_RUN=TRUE
                        ${list_of_defs}
                        ${PLATFORM_DEFS} ..
                WORKING_DIRECTORY ${env_build_folder})#configure, then build

# 2) => it should produce a resulting solution info file => including this file locally to get all definitions then apply them to local variables (overwritting).
# locally we manage thoses variables at configuration time. VAR_<name> is the variable for <name> argument.
# The platform is set using same variables as for target platform description but with FORCE_ prefix.

if(NOT EXISTS ${env_build_folder}/PID_Environment_Solution_Info.cmake)
  set(${EVAL_OK} FALSE PARENT_SCOPE)
  return()
endif()
include(${env_build_folder}/PID_Environment_Solution_Info.cmake)
set(${EVAL_OK} TRUE PARENT_SCOPE)
endfunction(evaluate_Environment_From_Package)



#.rst:
#
# .. ifmode:: internal
#
#  .. |import_Solution_From_Dependency| replace:: ``import_Solution_From_Dependency``
#  .. _import_Solution_From_Dependency:
#
#  import_Solution_From_Dependency
#  -------------------------------
#
#   .. command:: import_Solution_From_Dependency(environment)
#
#     Impport locally the solution provided by a dependency.
#
#      :environment: the name of the dependency.
#
function(import_Solution_From_Dependency environment)
set(prefix ${environment}_${LAST_RUN_HASHCODE})
  if(${prefix}_CROSSCOMPILATION)
    set(${PROJECT_NAME}_CROSSCOMPILATION ${${prefix}_CROSSCOMPILATION} CACHE INTERNAL "")
    if(NOT ${PROJECT_NAME}_TARGET_SYSROOT AND ${prefix}_TARGET_SYSROOT)#only if value not set at upper level !
      set(${PROJECT_NAME}_TARGET_SYSROOT ${${prefix}_TARGET_SYSROOT} CACHE INTERNAL "")
    endif()
    if(NOT ${PROJECT_NAME}_TARGET_STAGING AND ${prefix}_TARGET_STAGING)#only if value not set at upper level !
      set(${PROJECT_NAME}_TARGET_STAGING ${${prefix}_TARGET_STAGING} CACHE INTERNAL "")
    endif()
  endif()
  if(NOT ${PROJECT_NAME}_TARGET_INSTANCE AND ${prefix}_TARGET_INSTANCE)#only if value not set at upper level !
    set(${PROJECT_NAME}_TARGET_INSTANCE ${${prefix}_TARGET_INSTANCE} CACHE INTERNAL "")
  endif()

  foreach(lang IN LISTS ${prefix}_LANGUAGES)
    math(EXPR max_toolsets "${${prefix}_${lang}_TOOLSETS}-1")
    foreach(toolset RANGE ${max_toolsets})
      add_Language_Toolset(${lang} FALSE
                          "${${prefix}_${lang}_TOOLSET_${toolset}_CONSTRAINT_EXPRESSION}"
                          "${${prefix}_${lang}_TOOLSET_${toolset}_CHECK_SCRIPT}"
                          "${${prefix}_${lang}_TOOLSET_${toolset}_COMPILER}"
                          "${${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_ID}"
                          "${${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_AR}"
                          "${${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_RANLIB}"
                          "${${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_FLAGS}"
                          "${${prefix}_${lang}_TOOLSET_${toolset}_INTERPRETER}"
                          "${${prefix}_${lang}_TOOLSET_${toolset}_INCLUDE_DIRS}"
                          "${${prefix}_${lang}_TOOLSET_${toolset}_LIBRARY}"
                          "${${prefix}_${lang}_TOOLSET_${toolset}_COVERAGE}"
                          "${${prefix}_${lang}_TOOLSET_${toolset}_HOST_COMPILER}"
      )
    endforeach()
  endforeach()

  foreach(tool IN LISTS ${prefix}_EXTRA_TOOLS)
      add_Extra_Tool(${tool}
                    "${${prefix}_EXTRA_${tool}_CONSTRAINT_EXPRESSION}"
                    "${${prefix}_EXTRA_${tool}_CHECK_SCRIPT}"
                    FALSE
                    "${${prefix}_EXTRA_${tool}_PROGRAM}"
                    "${${prefix}_EXTRA_${tool}_PLATFORM_CONFIGURATIONS}"
                    "${${prefix}_EXTRA_${tool}_PROGRAM_DIRS}"
                    "${${prefix}_EXTRA_${tool}_PLUGIN_BEFORE_DEPENDENCIES}"
                    "${${prefix}_EXTRA_${tool}_PLUGIN_BEFORE_COMPONENTS}"
                    "${${prefix}_EXTRA_${tool}_PLUGIN_DURING_COMPONENTS}"
                    "${${prefix}_EXTRA_${tool}_PLUGIN_AFTER_COMPONENTS}"
                    "${${prefix}_EXTRA_${tool}_PLUGIN_ON_DEMAND}"
      )
  endforeach()

  if(${prefix}_LINKER)
    if(${PROJECT_NAME}_LINKER)
      message(FATAL_ERROR "[PID] CRITICAL ERROR : the system linker in use cannot be set by environment ${environment} because it is already set to ${${PROJECT_NAME}_LINKER}")
      return()
    endif()
    set(${PROJECT_NAME}_LINKER ${${prefix}_LINKER} CACHE INTERNAL "")
    set(${PROJECT_NAME}_SYSTEM_WIDE_CONFIGURATION TRUE CACHE INTERNAL "")
  endif()
  if(${prefix}_AR)
    if(${PROJECT_NAME}_AR)
      message(FATAL_ERROR "[PID] CRITICAL ERROR : the system archiver in use cannot be set by environment ${environment} because it is already set to ${${PROJECT_NAME}_AR}")
      return()
    endif()
    set(${PROJECT_NAME}_AR ${${prefix}_AR} CACHE INTERNAL "")
    set(${PROJECT_NAME}_SYSTEM_WIDE_CONFIGURATION TRUE CACHE INTERNAL "")
  endif()
  if(${prefix}_NM)
    if(${PROJECT_NAME}_NM)
      message(FATAL_ERROR "[PID] CRITICAL ERROR : the system naming tool in use cannot be set by environment ${environment} because it is already set to ${${PROJECT_NAME}_NM}")
      return()
    endif()
    set(${PROJECT_NAME}_NM ${${prefix}_NM} CACHE INTERNAL "")
    set(${PROJECT_NAME}_SYSTEM_WIDE_CONFIGURATION TRUE CACHE INTERNAL "")
  endif()
  if(${prefix}_RANLIB)
    if(${PROJECT_NAME}_RANLIB)
      message(FATAL_ERROR "[PID] CRITICAL ERROR : the system static libraries creator tool in use cannot be set by environment ${environment} because it is already set to ${${PROJECT_NAME}_RANLIB}")
      return()
    endif()
    set(${PROJECT_NAME}_RANLIB ${${prefix}_RANLIB} CACHE INTERNAL "")
    set(${PROJECT_NAME}_SYSTEM_WIDE_CONFIGURATION TRUE CACHE INTERNAL "")
  endif()
  if(${prefix}_OBJDUMP)
    if(${PROJECT_NAME}_OBJDUMP)
      message(FATAL_ERROR "[PID] CRITICAL ERROR : the system objdump tool in use cannot be set by environment ${environment} because it is already set to ${${PROJECT_NAME}_OBJDUMP}")
      return()
    endif()
    set(${PROJECT_NAME}_OBJDUMP ${${prefix}_OBJDUMP} CACHE INTERNAL "")
    set(${PROJECT_NAME}_SYSTEM_WIDE_CONFIGURATION TRUE CACHE INTERNAL "")
  endif()
  if(${prefix}_OBJCOPY)
    if(${PROJECT_NAME}_OBJCOPY)
      message(FATAL_ERROR "[PID] CRITICAL ERROR : the system objcopy tool in use cannot be set by environment ${environment} because it is already set to ${${PROJECT_NAME}_OBJCOPY}")
      return()
    endif()
    set(${PROJECT_NAME}_OBJCOPY ${${prefix}_OBJCOPY} CACHE INTERNAL "")
    set(${PROJECT_NAME}_SYSTEM_WIDE_CONFIGURATION TRUE CACHE INTERNAL "")
  endif()
  if(${prefix}_RPATH)
    if(${PROJECT_NAME}_RPATH)
      message(FATAL_ERROR "[PID] CRITICAL ERROR : the system rpath edition tool in use cannot be set by environment ${environment} because it is already set to ${${PROJECT_NAME}_RPATH}")
      return()
    endif()
    set(${PROJECT_NAME}_RPATH ${${prefix}_RPATH} CACHE INTERNAL "")
    set(${PROJECT_NAME}_SYSTEM_WIDE_CONFIGURATION TRUE CACHE INTERNAL "")
  endif()

  if(${prefix}_INCLUDE_DIRS)
    append_Unique_In_Cache(${PROJECT_NAME}_INCLUDE_DIRS "${${prefix}_INCLUDE_DIRS}")
  endif()
  if(${prefix}_LIBRARY_DIRS)
    append_Unique_In_Cache(${PROJECT_NAME}_LIBRARY_DIRS "${${prefix}_LIBRARY_DIRS}")
  endif()
  if(${prefix}_PROGRAM_DIRS)
    append_Unique_In_Cache(${PROJECT_NAME}_PROGRAM_DIRS "${${prefix}_PROGRAM_DIRS}")
  endif()
  if(${prefix}_EXE_LINKER_FLAGS)
    append_Unique_In_Cache(${PROJECT_NAME}_EXE_LINKER_FLAGS "${${prefix}_EXE_LINKER_FLAGS}")
  endif()
  if(${prefix}_MODULE_LINKER_FLAGS)
    append_Unique_In_Cache(${PROJECT_NAME}_MODULE_LINKER_FLAGS "${${prefix}_MODULE_LINKER_FLAGS}")
  endif()
  if(${prefix}_SHARED_LINKER_FLAGS)
    append_Unique_In_Cache(${PROJECT_NAME}_SHARED_LINKER_FLAGS "${${prefix}_SHARED_LINKER_FLAGS}")
  endif()
  if(${prefix}_STATIC_LINKER_FLAGS)
    append_Unique_In_Cache(${PROJECT_NAME}_STATIC_LINKER_FLAGS "${${prefix}_STATIC_LINKER_FLAGS}")
  endif()

  if(${prefix}_GENERATOR_TOOLSET)#may overwrite user choice
    if(${PROJECT_NAME}_GENERATOR_TOOLSET)
      message(FATAL_ERROR "[PID] CRITICAL ERROR : the geneator toolset in use cannot be set by environment ${environment} because it is already set to ${${PROJECT_NAME}_GENERATOR_TOOLSET}")
      return()
    endif()
    set(${PROJECT_NAME}_GENERATOR_TOOLSET ${${prefix}_GENERATOR_TOOLSET} CACHE INTERNAL "")
  endif()
  if(${prefix}_GENERATOR_PLATFORM)#may overwrite user choice
    if(${PROJECT_NAME}_GENERATOR_PLATFORM)
      message(FATAL_ERROR "[PID] CRITICAL ERROR : the geneator platform in use cannot be set by environment ${environment} because it is already set to ${${PROJECT_NAME}_GENERATOR_PLATFORM}")
      return()
    endif()
    set(${PROJECT_NAME}_GENERATOR_PLATFORM ${${prefix}_GENERATOR_PLATFORM} CACHE INTERNAL "")
  endif()
endfunction(import_Solution_From_Dependency)

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
  file(APPEND ${pathtonewfile} "set(${PROJECT_NAME}_CONTACT_MAIL ${${PROJECT_NAME}_CONTACT_MAIL} CACHE INTERNAL \"\")\n")
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
  if( ${PROJECT_NAME}_OPTIONAL_CONSTRAINTS
      OR ${PROJECT_NAME}_IN_BINARY_CONSTRAINTS
      OR ${PROJECT_NAME}_REQUIRED_CONSTRAINTS)
    set(lift_of_inputs ${${PROJECT_NAME}_OPTIONAL_CONSTRAINTS} ${${PROJECT_NAME}_REQUIRED_CONSTRAINTS} ${${PROJECT_NAME}_IN_BINARY_CONSTRAINTS})
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
  if(PREFERRED_GENERATOR_TOOLSET)
    set(${PROJECT_NAME}_GENERATOR_TOOLSET ${PREFERRED_GENERATOR_TOOLSET} CACHE INTERNAL "")# cannot be overwritten
  endif()
  if(PREFERRED_GENERATOR_PLATFORM)
    set(${PROJECT_NAME}_GENERATOR_PLATFORM ${PREFERRED_GENERATOR_PLATFORM} CACHE INTERNAL "")# cannot be overwritten
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

  if(${PROJECT_NAME}_ABI_CONSTRAINT)#ABI constraint is specified
    if(NOT ${PROJECT_NAME}_ABI_CONSTRAINT STREQUAL CURRENT_PLATFORM_ABI)
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

  #provides the result to say if host is target
  set(${CURRENT_HOST_MATCHES_TARGET} ${result} PARENT_SCOPE)

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
    if(NOT ${PROJECT_NAME}_SOLUTION_${index}_ABI STREQUALCURRENT_PLATFORM_ABI )#not the current one
      return()
    endif()
  endif()
  set(${RESULT} TRUE PARENT_SCOPE)

endfunction(is_Environment_Solution_Eligible)


#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Environment_Dependencies| replace:: ``evaluate_Environment_Dependencies``
#  .. _evaluate_Environment_Dependencies:
#
#  evaluate_Environment_Dependencies
#  ---------------------------------
#
#   .. command:: evaluate_Environment_Dependencies(EVAL_RESULT)
#
#   Evaluate dependencies of the current project.
#
#     :EVAL_RESULT: the output variable that is TRUE if all dependencies are satisfied.
#
function(evaluate_Environment_Dependencies EVAL_RESULT)
  set(${EVAL_RESULT} FALSE PARENT_SCOPE)
  foreach(dep IN LISTS ${PROJECT_NAME}_DEPENDENCIES)
    manage_Environment_Dependency(RESULT_DEP ${dep})
    if(NOT RESULT_DEP)
      message("[PID] WARNING: environment ${dep} used as a dependency of ${PROJECT_NAME} cannot find a valid solution.")
      return()
    endif()
    # Regenerate the toolchain after each evaluated dependency so that we can pass it to the next one
    generate_Environment_Toolchain_File()#from global solution generate the toolchain file
  endforeach()
  set(${EVAL_RESULT} TRUE PARENT_SCOPE)
endfunction(evaluate_Environment_Dependencies)

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
#   .. command:: evaluate_Environment_Solution(index)
#
#   Evaluate a solution provided by the environment. Macro is used instead of fucntion so that variables generated in script are exported in global context
#
#     :index: the index of the solution in the list of solutions.
#
#     :EVAL_RESULT: the parent scope variable that is TRUE if current host uses this solution to set build related variables.
#
macro(evaluate_Environment_Solution index)
  set(EVAL_RESULT FALSE)

  # from here we know that the platform (host VS target constraints defined) matches so the solution can be evaluated
  # from here, means that everything is OK and specific configuration, if any, can apply
  if(${PROJECT_NAME}_SOLUTION_${index}_CONFIGURE)# a configuration script is provided => there is some more configuration to do
    if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_SOLUTION_${index}_CONFIGURE})#addintionnal check is required to manage input constraints
      message(FATAL_ERROR "[PID] CRITICAL ERROR: the file ${${PROJECT_NAME}_SOLUTION_${index}_CONFIGURE} cannot be found in src folder of ${PROJECT_NAME}")
      return()
    endif()
    set(ENVIRONMENT_CONFIG_RESULT TRUE CACHE INTERNAL "")
    include(src/${${PROJECT_NAME}_SOLUTION_${index}_CONFIGURE})# we need to configure host with adequate tools
    if(NOT ENVIRONMENT_CONFIG_RESULT)# toolsets configuration OK (may mean crosscompiling)
      if(ADDITIONAL_DEBUG_INFO)
        message("[PID] INFO : evaluation of solution ${index} defined in ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_SOLUTION_${index}_CONFIGURE} failed")
      endif()
    else()
      set(EVAL_RESULT TRUE)
    endif()
  endif()
endmacro(evaluate_Environment_Solution)

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
#   .. command:: evaluate_Environment_Constraints(CONSTRAINTS_EXPR EVAL_RESULT)
#
#   Evaluate the constraints in order to create adequate variables usable in environment script files.
#
#     :CONSTRAINTS_EXPR: the parent scope variable that constains the constraint expression
#     :EVAL_RESULT: the parent scope variable that is TRUE if any constraints is violated, FALSE otherwise.
#
function(evaluate_Environment_Constraints CONSTRAINTS_EXPR EVAL_RESULT)
  set(${EVAL_RESULT} FALSE PARENT_SCOPE)
  set(${CONSTRAINTS_EXPR} FALSE PARENT_SCOPE)
  set(const_expr)
  foreach(opt IN LISTS ${PROJECT_NAME}_OPTIONAL_CONSTRAINTS ${PROJECT_NAME}_IN_BINARY_CONSTRAINTS)
    if(opt AND DEFINED VAR_${opt}) #cmake variable containing the input variable exist => input variable passed by the user
      if(const_expr)
        set(const_expr "${const_expr}:${opt}=${VAR_${opt}}")
      else()
        set(const_expr "${opt}=${VAR_${opt}}")
      endif()
      parse_Configuration_Expression_Argument_Value(VAL_LIST "${VAR_${opt}}")
      set(${PROJECT_NAME}_${opt} ${VAL_LIST} PARENT_SCOPE)#create the local variable used in scripts
    endif()
  endforeach()

  foreach(req IN LISTS ${PROJECT_NAME}_REQUIRED_CONSTRAINTS)
    if(NOT DEFINED VAR_${req}) #cmake variable containing the input variable exist => input variable passed by the user
      message("[PID] ERROR: environment ${PROJECT_NAME} requires ${req} to be defined.")
      return()
    endif()
    if(const_expr)
      set(const_expr "${const_expr}:${req}=${VAR_${req}}")
    else()
      set(const_expr "${req}=${VAR_${req}}")
    endif()
    parse_Configuration_Expression_Argument_Value(VAL_LIST "${VAR_${req}}")
    set(${PROJECT_NAME}_${req} ${VAL_LIST} PARENT_SCOPE)#create the local variable used in scripts
  endforeach()
  #also evaluate constraints coming from dependent environment or configuration script


  if(FORCE_${PROJECT_NAME}_TARGET_SYSROOT)
    set(${PROJECT_NAME}_TARGET_SYSROOT ${FORCE_${PROJECT_NAME}_TARGET_SYSROOT} CACHE INTERNAL "")# higher level specified sysroot always takes precedence
  endif()
  if(FORCE_${PROJECT_NAME}_TARGET_STAGING)
    set(${PROJECT_NAME}_TARGET_STAGING ${FORCE_${PROJECT_NAME}_TARGET_STAGING} CACHE INTERNAL "")#  higher level specified staging always takes precedence
  endif()
  if(FORCE_${PROJECT_NAME}_TARGET_INSTANCE)
    set(${PROJECT_NAME}_TARGET_INSTANCE ${FORCE_${PROJECT_NAME}_TARGET_INSTANCE} CACHE INTERNAL "")#  higher level specified staging always takes precedence
  endif()

if(FORCE_${PROJECT_NAME}_ARCH_CONSTRAINT) #arch constraint has been forced
  if(${PROJECT_NAME}_ARCH_CONSTRAINT AND (NOT ${PROJECT_NAME}_ARCH_CONSTRAINT STREQUAL FORCE_${PROJECT_NAME}_ARCH_CONSTRAINT))
    message("[PID] ERROR: environment ${PROJECT_NAME} defines a constraint on processor architecture (${${PROJECT_NAME}_ARCH_CONSTRAINT}) but a dependent environment imposes a different one (${FORCE_${PROJECT_NAME}_ARCH_CONSTRAINT}).")
    return()
  else()
    set(${PROJECT_NAME}_ARCH_CONSTRAINT ${FORCE_${PROJECT_NAME}_ARCH_CONSTRAINT} CACHE INTERNAL "")#set its value
  endif()
endif()
if(FORCE_${PROJECT_NAME}_TYPE_CONSTRAINT)
  if(${PROJECT_NAME}_TYPE_CONSTRAINT AND (NOT ${PROJECT_NAME}_TYPE_CONSTRAINT STREQUAL FORCE_${PROJECT_NAME}_TYPE_CONSTRAINT))
    message("[PID] ERROR: environment ${PROJECT_NAME} defines a constraint on processor architecture size (${${PROJECT_NAME}_TYPE_CONSTRAINT}) but a dependent environment imposes a different one (${FORCE_${PROJECT_NAME}_TYPE_CONSTRAINT}).")
    return()
  else()
    set(${PROJECT_NAME}_TYPE_CONSTRAINT ${FORCE_${PROJECT_NAME}_TYPE_CONSTRAINT} CACHE INTERNAL "")#set its value
  endif()
endif()
if(FORCE_${PROJECT_NAME}_OS_CONSTRAINT)
  if(${PROJECT_NAME}_OS_CONSTRAINT AND (NOT ${PROJECT_NAME}_OS_CONSTRAINT STREQUAL FORCE_${PROJECT_NAME}_OS_CONSTRAINT))
    message("[PID] ERROR: environment ${PROJECT_NAME} defines a constraint on operating system (${${PROJECT_NAME}_OS_CONSTRAINT}) but a dependent environment imposes a different one (${FORCE_${PROJECT_NAME}_OS_CONSTRAINT}).")
    return()
  else()
    set(${PROJECT_NAME}_OS_CONSTRAINT ${FORCE_${PROJECT_NAME}_OS_CONSTRAINT} CACHE INTERNAL "")#set its value
  endif()
endif()
if(FORCE_${PROJECT_NAME}_ABI_CONSTRAINT)
  if(${PROJECT_NAME}_ABI_CONSTRAINT AND (NOT ${PROJECT_NAME}_ABI_CONSTRAINT STREQUAL FORCE_${PROJECT_NAME}_ABI_CONSTRAINT))
    message("[PID] ERROR: environment ${PROJECT_NAME} defines a constraint on C++ ABI (${${PROJECT_NAME}_ABI_CONSTRAINT}) but a dependent environment imposes a different one (${FORCE_${PROJECT_NAME}_ABI_CONSTRAINT}).")
    return()
  else()
    set(${PROJECT_NAME}_ABI_CONSTRAINT ${FORCE_${PROJECT_NAME}_ABI_CONSTRAINT} CACHE INTERNAL "")#set its value
  endif()
endif()
if(FORCE_${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT)
  if(${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT AND (NOT ${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT STREQUAL FORCE_${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT))
    message("[PID] ERROR: environment ${PROJECT_NAME} defines a constraint on OS distribution (${${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT}) but a dependent environment imposes a different one (${FORCE_${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT}).")
    return()
  else()
    set(${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT ${FORCE_${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT} CACHE INTERNAL "")#set its value
  endif()
  if(FORCE_${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT)
    if(${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT AND (NOT ${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT STREQUAL FORCE_${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT))
      message("[PID] ERROR: environment ${PROJECT_NAME} defines a constraint on OS distribution version (${${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT}) but a dependent environment imposes a different one (${FORCE_${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT}).")
      return()
    else()
      set(${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT ${FORCE_${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT} CACHE INTERNAL "")#set its value
    endif()
  endif()
endif()
set(${EVAL_RESULT} TRUE PARENT_SCOPE)
set(${CONSTRAINTS_EXPR} "${const_expr}" PARENT_SCOPE)
endfunction(evaluate_Environment_Constraints)


#.rst:
#
# .. ifmode:: internal
#
#  .. |deduce_Platform_Variables| replace:: ``deduce_Platform_Variables``
#  .. _deduce_Platform_Variables:
#
#  deduce_Platform_Variables
#  --------------------------
#
#   .. command:: deduce_Platform_Variables()
#
#   From environment description deduce general variables that will be used in generated toolchain file.
#
function(deduce_Platform_Variables)
  #reset the variables first
  set(${PROJECT_NAME}_TARGET_SYSTEM_PROCESSOR CACHE INTERNAL "")
  set(${PROJECT_NAME}_TARGET_SYSTEM_NAME CACHE INTERNAL "")
  set(${PROJECT_NAME}_TARGET_PLATFORM CACHE INTERNAL "")
  set(${PROJECT_NAME}_TARGET_DISTRIBUTION CACHE INTERNAL "")
  set(${PROJECT_NAME}_TARGET_DISTRIBUTION_VERSION CACHE INTERNAL "")

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
    set(use_os ${CURRENT_PLATFORM_OS})
  endif()
  if(${PROJECT_NAME}_ABI_CONSTRAINT)#operating system type constraint is specified
    set(use_abi ${${PROJECT_NAME}_ABI_CONSTRAINT})
  else()
    set(use_abi ${CURRENT_PLATFORM_ABI})
  endif()
  if(use_os)
    set(${PROJECT_NAME}_TARGET_PLATFORM ${use_proc_type}_${use_proc_arch}_${use_os}_${use_abi} CACHE INTERNAL "")
  else()#do not use OS (Generic target)
    set(${PROJECT_NAME}_TARGET_PLATFORM ${use_proc_type}_${use_proc_arch}_${use_abi} CACHE INTERNAL "")
  endif()

  if(${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT)
    set(${PROJECT_NAME}_TARGET_DISTRIBUTION ${${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT} CACHE INTERNAL "")
    if(${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT)
      set(${PROJECT_NAME}_TARGET_DISTRIBUTION_VERSION ${${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT} CACHE INTERNAL "")
    endif()
  endif()

  if(${PROJECT_NAME}_CROSSCOMPILATION)#if host is not target and cross=> We may need to define cross compilation relared information
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
    elseif(use_os STREQUAL "freebsd")
      set(os_name FreeBSD)
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
endfunction(deduce_Platform_Variables)

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
#   Create the toochain file for the current environment projec. It is used to configure the workspace.
#
function(generate_Environment_Toolchain_File)
  set(description_file ${CMAKE_BINARY_DIR}/PID_Toolchain.cmake)
  file(WRITE ${description_file} "")

  # setting the generator prroperties
  if(CMAKE_GENERATOR_INSTANCE)#use default instance if there is one defined
    file(APPEND ${description_file} "set(CMAKE_GENERATOR_INSTANCE ${CMAKE_GENERATOR_INSTANCE} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_GENERATOR_TOOLSET)#use targetted generator toolset if any
    file(APPEND ${description_file} "set(CMAKE_GENERATOR_TOOLSET ${${PROJECT_NAME}_GENERATOR_TOOLSET} CACHE INTERNAL \"\" FORCE)\n")
  elseif(CMAKE_GENERATOR_TOOLSET)# otherwise use default toolset if there is one defined
    file(APPEND ${description_file} "set(CMAKE_GENERATOR_TOOLSET ${CMAKE_GENERATOR_TOOLSET} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_GENERATOR_PLATFORM)
    file(APPEND ${description_file} "set(CMAKE_GENERATOR_PLATFORM ${${PROJECT_NAME}_GENERATOR_PLATFORM} CACHE INTERNAL \"\" FORCE)\n")
  elseif(CMAKE_GENERATOR_PLATFORM)#use default platform if there is one defined
    file(APPEND ${description_file} "set(CMAKE_GENERATOR_PLATFORM ${CMAKE_GENERATOR_PLATFORM} CACHE INTERNAL \"\" FORCE)\n")
  endif()

  if(${PROJECT_NAME}_CROSSCOMPILATION)
    #when cross compiling need to set target system name and processor
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_NAME ${${PROJECT_NAME}_TARGET_SYSTEM_NAME} CACHE INTERNAL \"\" FORCE)\n")
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_PROCESSOR ${${PROJECT_NAME}_TARGET_SYSTEM_PROCESSOR} CACHE INTERNAL \"\" FORCE)\n")
    if(NOT ${PROJECT_NAME}_TARGET_SYSTEM_NAME STREQUAL Generic) # cas where there is a kernel in use (e.g. building for microcontrollers)
      #we need a sysroot to the target operating system filesystem ! => defined by user !!
      if(NOT ${PROJECT_NAME}_TARGET_SYSROOT)#sysroot is necessary when cross compiling to another OS
        message(FATAL_ERROR "[PID] CRITICAL ERROR: you must give a sysroot by using the sysroot argument when calling build command.")
      endif()
      file(APPEND ${description_file} "set(CMAKE_SYSROOT ${${PROJECT_NAME}_TARGET_SYSROOT} CACHE INTERNAL \"\" FORCE)\n")
      if(${PROJECT_NAME}_TARGET_STAGING)
        file(APPEND ${description_file} "set(CMAKE_STAGING_PREFIX ${${PROJECT_NAME}_TARGET_STAGING} CACHE INTERNAL \"\" FORCE)\n")
      endif()
    endif()
    #add specific information from what cannot be deduced when cross compiling
    if(NOT ${PROJECT_NAME}_ABI_CONSTRAINT)#c++ standard library abi in use
      message("[PID] WARNING: you should give an abi constraint in ${PROJECT_NAME}. Using compiler default ABI as default.")
    endif()
    if(${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT)#c++ standard library abi in use
      file(APPEND ${description_file} "set(PID_USE_DISTRIBUTION ${${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT} CACHE INTERNAL \"\" FORCE)\n")
    endif()
    if(${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT)#c++ standard library abi in use
      file(APPEND ${description_file} "set(PID_USE_DISTRIB_VERSION ${${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT} CACHE INTERNAL \"\" FORCE)\n")
    endif()
  endif()

  # add build tools variables  to the toolset
  #manage languages directly managed at workspace level (CMake managed languages)
  foreach(lang IN ITEMS C CXX ASM Fortran Python CUDA)
    if(NOT ${PROJECT_NAME}_${lang}_TOOLSETS OR ${PROJECT_NAME}_${lang}_TOOLSETS LESS 1)
      continue()#simply do not manage the language
    endif()
    set(prefix ${PROJECT_NAME}_${lang}_TOOLSET_0)
    if(lang STREQUAL "Python")
      file(APPEND ${description_file} "set(PYTHON_EXECUTABLE ${${prefix}_INTERPRETER} CACHE INTERNAL \"\" FORCE)\n")
      if(${prefix}_INCLUDE_DIRS)
        fill_String_From_List(LANG_FLAGS ${prefix}_INCLUDE_DIRS " ")
        file(APPEND ${description_file} "set(PYTHON_INCLUDE_DIRS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
      endif()
      if(${prefix}_LIBRARY)
        file(APPEND ${description_file} "set(PYTHON_LIBRARY ${${prefix}_LIBRARY} CACHE INTERNAL \"\" FORCE)\n")
      endif()
    elseif(${prefix}_COMPILER) #other languages are compiled by default so to be managed a compiler must be defined
      #add the default command for setting compiler anytime
      file(APPEND ${description_file} "set(CMAKE_${lang}_COMPILER ${${prefix}_COMPILER} CACHE INTERNAL \"\" FORCE)\n")

      if(${prefix}_COMPILER_FLAGS)
        fill_String_From_List(LANG_FLAGS ${prefix}_COMPILER_FLAGS " ")
        file(APPEND ${description_file} "set(CMAKE_${lang}_FLAGS  \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
      endif()
      if(${prefix}_LIBRARY)#if standard libraries sonames are given
        file(APPEND ${description_file} "set(PID_USE_${lang}_STANDARD_LIBRARIES ${${prefix}_LIBRARY} CACHE INTERNAL \"\" FORCE)\n")
      endif()
      if(${prefix}_COVERAGE)#if standard libraries sonames are given
        file(APPEND ${description_file} "set(PID_USE_${lang}_COVERAGE ${${prefix}_COVERAGE} CACHE INTERNAL \"\" FORCE)\n")
      endif()
      if(lang MATCHES "CUDA")#for CUDA also set the old variables for compiler info
        file(APPEND ${description_file} "set(CUDA_NVCC_EXECUTABLE ${${prefix}_COMPILER} CACHE INTERNAL \"\" FORCE)\n")
        if(${prefix}_COMPILER_FLAGS)
          fill_String_From_List(LANG_FLAGS ${prefix}_COMPILER_FLAGS " ")
          file(APPEND ${description_file} "set(CUDA_NVCC_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
        endif()
        if(${prefix}_HOST_COMPILER)
          file(APPEND ${description_file} "set(CUDA_HOST_COMPILER ${${prefix}_HOST_COMPILER} CACHE INTERNAL \"\" FORCE)\n")
          file(APPEND ${description_file} "set(CMAKE_CUDA_HOST_COMPILER ${${prefix}_HOST_COMPILER} CACHE INTERNAL \"\" FORCE)\n")#also set the CMake supported language variable
        endif()
      else()
        if(${prefix}_COMPILER_AR)
          file(APPEND ${description_file} "set(CMAKE_${lang}_COMPILER_AR ${${prefix}_COMPILER_AR} CACHE INTERNAL \"\" FORCE)\n")
        endif()
        if(${prefix}_COMPILER_RANLIB)
          file(APPEND ${description_file} "set(CMAKE_${lang}_COMPILER_RANLIB ${${prefix}_COMPILER_RANLIB} CACHE INTERNAL \"\" FORCE)\n")
        endif()
      endif()
    endif()
  endforeach()

  if(${PROJECT_NAME}_LINKER)
    file(APPEND ${description_file} "set(CMAKE_LINKER ${${PROJECT_NAME}_LINKER} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_EXE_LINKER_FLAGS)
    fill_String_From_List(LANG_FLAGS ${PROJECT_NAME}_EXE_LINKER_FLAGS " ")
    file(APPEND ${description_file} "set(CMAKE_EXE_LINKER_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_MODULE_LINKER_FLAGS)
    fill_String_From_List(LANG_FLAGS ${PROJECT_NAME}_MODULE_LINKER_FLAGS " ")
    file(APPEND ${description_file} "set(CMAKE_MODULE_LINKER_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_SHARED_LINKER_FLAGS)
    fill_String_From_List(LANG_FLAGS ${PROJECT_NAME}_SHARED_LINKER_FLAGS " ")
    file(APPEND ${description_file} "set(CMAKE_SHARED_LINKER_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_STATIC_LINKER_FLAGS)
    fill_String_From_List(LANG_FLAGS ${PROJECT_NAME}_STATIC_LINKER_FLAGS " ")
    file(APPEND ${description_file} "set(CMAKE_STATIC_LINKER_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_LIBRARY_DIRS)
    fill_String_From_List(DIRS ${PROJECT_NAME}_LIBRARY_DIRS " ")
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_LIBRARY_PATH ${DIRS} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_INCLUDE_DIRS)
    fill_String_From_List(DIRS ${PROJECT_NAME}_INCLUDE_DIRS " ")
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_INCLUDE_PATH ${DIRS} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_PROGRAM_DIRS)
    fill_String_From_List(DIRS ${PROJECT_NAME}_PROGRAM_DIRS " ")
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_PROGRAM_PATH ${DIRS} CACHE INTERNAL \"\" FORCE)\n")
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
  if(${PROJECT_NAME}_RPATH)
    file(APPEND ${description_file} "set(PID_USE_RPATH_UTILITY ${${PROJECT_NAME}_RPATH} CACHE INTERNAL \"\" FORCE)\n")
  endif()

  if(${PROJECT_NAME}_CROSSCOMPILATION)
    # avoid problem with try_compile when cross compiling
    file(APPEND ${description_file} "set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY CACHE INTERNAL \"\" FORCE)\n")

  endif()

endfunction(generate_Environment_Toolchain_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |compute_Resulting_Environment_Contraints| replace:: ``compute_Resulting_Environment_Contraints``
#  .. _compute_Resulting_Environment_Contraints:
#
#  compute_Resulting_Environment_Contraints
#  ----------------------------------------
#
#   .. command:: compute_Resulting_Environment_Contraints()
#
#   Compute the result constraint for the environment that includes all required and in binary parameters for the current environment.
#
function(compute_Resulting_Environment_Contraints)
  # need to write the constraints that will lie in binary of the environment
  set(all_constraints)
  #updating all constraints to apply in binary package, they correspond to variable that will be outputed
  foreach(constraint IN LISTS ${PROJECT_NAME}_REQUIRED_CONSTRAINTS ${PROJECT_NAME}_IN_BINARY_CONSTRAINTS)
    generate_Value_For_Configuration_Expression_Parameter(RES_VALUE ${PROJECT_NAME}_${constraint})
    list(APPEND all_constraints ${constraint} "${RES_VALUE}")#use guillemet to set exactly one element
  endforeach()

  generate_Configuration_Expression(RESULTING_EXPRESSION ${PROJECT_NAME} "${all_constraints}")
  set(${PROJECT_NAME}_CONSTRAINT_EXPRESSION ${RESULTING_EXPRESSION} CACHE INTERNAL "")
endfunction(compute_Resulting_Environment_Contraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |adjust_Environment_Binary_Variables| replace:: ``adjust_Environment_Binary_Variables``
#  .. adjust_Environment_Binary_Variables:
#
#  adjust_Environment_Binary_Variables
#  -----------------------------------
#
#   .. command:: adjust_Environment_Binary_Variables()
#
#   Compute the result constraint for the environment that includes all required and in binary parameters for the current environment.
#
function(adjust_Environment_Binary_Variables)
  foreach(lang IN LISTS ${PROJECT_NAME}_LANGUAGES)
    if(${PROJECT_NAME}_${lang}_TOOLSETS GREATER 0)#some toolset already defined
      math(EXPR max_toolset "${${PROJECT_NAME}_${lang}_TOOLSETS}-1")
      foreach(toolset RANGE ${max_toolset})
        if(NOT ${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_CONSTRAINT_EXPRESSION)#toolset has been defined by the current project => need to adjust the constraint expression
          set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_CONSTRAINT_EXPRESSION ${${PROJECT_NAME}_CONSTRAINT_EXPRESSION} CACHE INTERNAL "")
        endif()
        if(NOT ${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_CHECK_SCRIPT)#toolset has been defined by the current project => need to adjust the path to check script
          set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_CHECK_SCRIPT ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_CHECK} CACHE INTERNAL "")
        endif()
      endforeach()
    endif()
  endforeach()

  foreach(tool IN LISTS ${PROJECT_NAME}_EXTRA_TOOLS)
    if(NOT ${PROJECT_NAME}_EXTRA_${tool}_CONSTRAINT_EXPRESSION)#extra tool has been defined by the current project => need to adjust the constraint expression
      set(${PROJECT_NAME}_EXTRA_${tool}_CONSTRAINT_EXPRESSION ${${PROJECT_NAME}_CONSTRAINT_EXPRESSION} CACHE INTERNAL "")
    endif()
    if(NOT ${PROJECT_NAME}_EXTRA_${tool}_CHECK_SCRIPT)#toolset has been defined by the current project => need to adjust the path to check script
      set(${PROJECT_NAME}_EXTRA_${tool}_CHECK_SCRIPT ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_CHECK} CACHE INTERNAL "")
    endif()
  endforeach()

endfunction(adjust_Environment_Binary_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Language_Toolset| replace:: ``set_Language_Toolset``
#  .. _set_Language_Toolset:
#
#  set_Language_Toolset
#  --------------------
#
#   .. command:: set_Language_Toolset(lang toolset expression script compiler comp_id comp_ar comp_ranlib comp_flags interp includes library)
#
#   Set the description of a language toolset in cache
#
#     :lang: the label of target language
#     :toolset: the index of language toolset
#     :expression: the constraint expression corresponding to the use of the given environment.
#     :script: the path to the check script used to evaluate the environment.
#     :compiler: the path to language compiler program.
#     :comp_id: the identifier of compiler
#     :comp_ar: the archiver tool for compiler
#     :comp_ranlib: the archiver manager for compiler
#     :comp_flags: the default flags to use with the comiler
#     :interp: the interpreter for the language
#     :includes: the include folder where to find standard library definitions
#     :libraries: the path to language standard libraries (CUDA, python) or sonames of standard libraries (C,C++)
#     :host_cc: the C or C++ compiler required by the higher level compiler
#
function(set_Language_Toolset lang toolset expression script compiler comp_id comp_ar comp_ranlib comp_flags interp includes libraries coverage host_cc)
  set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_CONSTRAINT_EXPRESSION ${expression} CACHE INTERNAL "")
  set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_CHECK_SCRIPT ${script} CACHE INTERNAL "")
  set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER ${compiler} CACHE INTERNAL "")
  set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER_ID ${comp_id} CACHE INTERNAL "")
  set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER_AR ${comp_ar} CACHE INTERNAL "")
  set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER_RANLIB ${comp_ranlib} CACHE INTERNAL "")
  set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER_FLAGS "${comp_flags}" CACHE INTERNAL "")
  set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_INTERPRETER ${interp} CACHE INTERNAL "")
  set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_INCLUDE_DIRS ${includes} CACHE INTERNAL "")
  set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_LIBRARY ${libraries} CACHE INTERNAL "")
  set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COVERAGE ${coverage} CACHE INTERNAL "")
  set(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_HOST_COMPILER ${host_cc} CACHE INTERNAL "")
endfunction(set_Language_Toolset)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Language_Toolset| replace:: ``add_Language_Toolset``
#  .. _add_Language_Toolset:
#
#  add_Language_Toolset
#  --------------------
#
#   .. command:: add_Language_Toolset(lang default expression script compiler comp_id comp_ar comp_ranlib comp_flags interp includes library host_cc)
#
#   Add definition of a new toolset for language. This toolset becomes default toolset.
#
#     :lang: the label of target language
#     :default: if TRUE the new toolset is supposed to be default and so toolsets will be reordered, otherwise solution is appended to existing ones
#     :expression: the constraknt expression for the corresponding toolset.
#     :script: the path to the check script used to evaluate the environment.
#     :compiler: the path to language compiler program.
#     :comp_id: the identifier of compiler
#     :comp_ar: the archiver tool for compiler
#     :comp_ranlib: the archiver manager for compiler
#     :comp_flags: the default flags to use with the comiler
#     :interp: the interpreter for the language
#     :includes: the include folder where to find standard library definitions
#     :library: the path to language standard library
#     :coverage: the path to coverage tool for that language (gcov)
#     :host_cc: the C or C++ compiler required by the higher level compiler
#
function(add_Language_Toolset lang default expression script compiler comp_id comp_ar comp_ranlib comp_flags interp includes library coverage host_cc)
  append_Unique_In_Cache(${PROJECT_NAME}_LANGUAGES ${lang})
  if(NOT ${PROJECT_NAME}_${lang}_TOOLSETS)
    set(${PROJECT_NAME}_${lang}_TOOLSETS 0 CACHE INTERNAL "")
  endif()
  if(default)#need to reorder the existing list
    set(count ${${PROJECT_NAME}_${lang}_TOOLSETS})
    while(count GREATER 0)#need to reorder existing toolsets that may come from dependencies (simply giving each of them next index)
      math(EXPR prev "${count}-1")
      set_Language_Toolset(${lang} "${count}"
                          "${${PROJECT_NAME}_${lang}_TOOLSET_${prev}_CONSTRAINT_EXPRESSION}"
                          "${${PROJECT_NAME}_${lang}_TOOLSET_${prev}_CHECK_SCRIPT}"
                          "${${PROJECT_NAME}_${lang}_TOOLSET_${prev}_COMPILER}"
                          "${${PROJECT_NAME}_${lang}_TOOLSET_${prev}_COMPILER_ID}"
                          "${${PROJECT_NAME}_${lang}_TOOLSET_${prev}_COMPILER_AR}"
                          "${${PROJECT_NAME}_${lang}_TOOLSET_${prev}_RANLIB}"
                          "${${PROJECT_NAME}_${lang}_TOOLSET_${prev}_COMPILER_FLAGS}"
                          "${${PROJECT_NAME}_${lang}_TOOLSET_${prev}_INTERPRETER}"
                          "${${PROJECT_NAME}_${lang}_TOOLSET_${prev}_INCLUDE_DIRS}"
                          "${${PROJECT_NAME}_${lang}_TOOLSET_${prev}_LIBRARY}"
                          "${${PROJECT_NAME}_${lang}_TOOLSET_${prev}_COVERAGE}"
                          "${${PROJECT_NAME}_${lang}_TOOLSET_${prev}_HOST_COMPILER}"
      )
      set(count ${prev})
    endwhile()
    set(new_index "0")#put it at beginning
  else()
    set(new_index "${${PROJECT_NAME}_${lang}_TOOLSETS}")#if no reorder put it at the end
  endif()
  #add the new default toolset at index 0
  set_Language_Toolset(${lang} "${new_index}"
                      "${expression}"
                      "${script}"
                      "${compiler}"
                      "${comp_id}"
                      "${comp_ar}"
                      "${comp_ranlib}"
                      "${comp_flags}"
                      "${interp}"
                      "${includes}"
                      "${library}"
                      "${coverage}"
                      "${host_cc}"
  )
  math(EXPR plus_one "${${PROJECT_NAME}_${lang}_TOOLSETS}+1")
  set(${PROJECT_NAME}_${lang}_TOOLSETS ${plus_one} CACHE INTERNAL "")#finally increasing the number of toolsets
endfunction(add_Language_Toolset)


#.rst:
#
# .. ifmode:: internal
#
#  .. |set_System_Wide_Configuration| replace:: ``set_System_Wide_Configuration``
#  .. _set_System_Wide_Configuration:
#
#  set_System_Wide_Configuration
#  -----------------------------
#
#   .. command:: set_System_Wide_Configuration(gen_toolset gen_platform
#                                       sysroot staging
#                                       linker ar ranlib nm objdump objcopy rpath
#                                       inc_dirs lib_dirs prog_dirs
#                                       exe_flags module_flags static_flags shared_flags)
#
#   Set the configuration of the host to adequately manage the target platform
#
#     :gen_toolset: generator toolset to use
#     :gen_platform: generator platform to use
#     :sysroot: target platform sysroot (cross comilation only).
#     :staging: target platform staging area (cross comilation only).
#     :linker: the path to system wide linker.
#     :ar: the path to system wide ar tool.
#     :ranlib: the path to system wide ranlib tool.
#     :nm: the path to system wide nm tool.
#     :objdump: the path to system wide objdump tool.
#     :objcopy: the path to system wide objcopy tool.
#     :rpath: the path to system wide rpath edition tool.
#     :inc_dirs: the list path to system include directories
#     :lib_dirs: the list path to system libraries directories
#     :prog_dirs: the list path to system programs directories
#     :exe_flags: list of flags to add when linking an executable
#     :module_flags: list of flags to add when linking a module library
#     :static_flags: list of flags to add when linking a static library
#     :shared_flags: list of flags to add when linking a shared library
#
function(set_System_Wide_Configuration gen_toolset gen_platform
                                       sysroot staging
                                       linker ar ranlib nm objdump objcopy rpath
                                       inc_dirs lib_dirs prog_dirs
                                       exe_flags module_flags static_flags shared_flags
                                      )
  #manage generator toolsets
  if(gen_toolset)
    set(${PROJECT_NAME}_GENERATOR_TOOLSET ${gen_toolset} CACHE INTERNAL "")
  endif()
  if(gen_platform)
    set(${PROJECT_NAME}_GENERATOR_PLATFORM ${gen_platform} CACHE INTERNAL "")
  endif()
  #manage crosscompilation
  if(sysroot)#warning overwritting previous value if any forced
    set(${PROJECT_NAME}_TARGET_SYSROOT ${sysroot} CACHE INTERNAL "")
  endif()
  if(staging)#warning overwritting previous value if any forced
    set(${PROJECT_NAME}_TARGET_STAGING ${staging} CACHE INTERNAL "")
  endif()
  #manage linker in use
  if(linker)
    set(${PROJECT_NAME}_LINKER ${linker} CACHE INTERNAL "")
  endif()
  #manage binary inspection/modification tools
  if(ar)
    set(${PROJECT_NAME}_AR ${ar} CACHE INTERNAL "")
  endif()
  if(ranlib)
    set(${PROJECT_NAME}_RANLIB ${ranlib} CACHE INTERNAL "")
  endif()
  if(nm)
    set(${PROJECT_NAME}_NM ${nm} CACHE INTERNAL "")
  endif()
  if(objdump)
    set(${PROJECT_NAME}_OBJDUMP ${objdump} CACHE INTERNAL "")
  endif()
  if(objcopy)
    set(${PROJECT_NAME}_OBJCOPY ${objcopy} CACHE INTERNAL "")
  endif()
  if(rpath)
    set(${PROJECT_NAME}_RPATH ${rpath} CACHE INTERNAL "")
  endif()

  #manage default system path
  if(inc_dirs)
    append_Unique_In_Cache(${PROJECT_NAME}_INCLUDE_DIRS "${inc_dirs}")
  endif()
  if(lib_dirs)
    append_Unique_In_Cache(${PROJECT_NAME}_LIBRARY_DIRS "${lib_dirs}")
  endif()
  if(prog_dirs)
    append_Unique_In_Cache(${PROJECT_NAME}_PROGRAM_DIRS "${prog_dirs}")
  endif()

  if(exe_flags)
    append_Unique_In_Cache(${PROJECT_NAME}_EXE_LINKER_FLAGS "${exe_flags}")
  endif()
  if(module_flags)
    append_Unique_In_Cache(${PROJECT_NAME}_MODULE_LINKER_FLAGS "${module_flags}")
  endif()
  if(static_flags)
    append_Unique_In_Cache(${PROJECT_NAME}_STATIC_LINKER_FLAGS "${static_flags}")
  endif()
  if(shared_flags)
    append_Unique_In_Cache(${PROJECT_NAME}_SHARED_LINKER_FLAGS "${shared_flags}")
  endif()
  set(${PROJECT_NAME}_SYSTEM_WIDE_CONFIGURATION TRUE CACHE INTERNAL "")
endfunction(set_System_Wide_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Extra_Tool| replace:: ``set_Extra_Tool``
#  .. _set_Extra_Tool:
#
#  set_Extra_Tool
#  --------------
#
#   .. command:: set_Extra_Tool(tool_name expression on_demand
#                               tool_program tool_configs tool_program_dirs
#                               tool_plugin_before_deps tool_plugin_before_comps
#                               tool_plugin_after_comps tool_plugin_ondemand)
#
#   Set definition of an extra tool.
#
#     :tool: the name of extra tool.
#     :expression: the constraint expression provided by the environment defining the extra tool.
#     :script: the path to the check script used to evaluate the environment.
#     :tool_program: path to the tool program (may be let empty).
#     :tool_configs: platform configuration required by the tool.
#     :tool_program_dirs: runtime path to use for the program executable.
#     :tool_plugin_before_deps: path to plugin script that is executed before dependencies description.
#     :tool_plugin_before_comps: path to plugin script that is executed after dependencies description and before components description.
#     :tool_plugin_during_comps: path to plugin script that is executed after during components description.
#     :tool_plugin_after_comps: path to plugin script that is executed after components description.
#     :tool_plugin_ondemand: if TRUE the plugin is only activated on demand.
#
function(set_Extra_Tool tool expression script tool_program tool_configs tool_program_dirs tool_plugin_before_deps tool_plugin_before_comps tool_plugin_during_comps tool_plugin_after_comps tool_plugin_ondemand)
  set(${PROJECT_NAME}_EXTRA_${tool}_CONSTRAINT_EXPRESSION ${expression} CACHE INTERNAL "")
  set(${PROJECT_NAME}_EXTRA_${tool}_CHECK_SCRIPT ${script} CACHE INTERNAL "")
  set(${PROJECT_NAME}_EXTRA_${tool}_PROGRAM ${tool_program} CACHE INTERNAL "")
  set(${PROJECT_NAME}_EXTRA_${tool}_PLATFORM_CONFIGURATIONS ${tool_configs} CACHE INTERNAL "")
  set(${PROJECT_NAME}_EXTRA_${tool}_PROGRAM_DIRS ${tool_program_dirs} CACHE INTERNAL "")

  set(tool_plugin_prefix ${CMAKE_SOURCE_DIR}/src/)

  # plugins coming from dependencies have an absolute path but local ones only have a script name
  if(IS_ABSOLUTE "${tool_plugin_before_deps}" OR
     IS_ABSOLUTE "${tool_plugin_before_comps}" OR
     IS_ABSOLUTE "${tool_plugin_during_comps}" OR
     IS_ABSOLUTE "${tool_plugin_after_comps}")
     # no prefix for absolute paths
     set(tool_plugin_prefix)
  endif()

  if(tool_plugin_before_deps)
    set(${PROJECT_NAME}_EXTRA_${tool}_PLUGIN_BEFORE_DEPENDENCIES ${tool_plugin_prefix}${tool_plugin_before_deps} CACHE INTERNAL "")
  endif()
  if(tool_plugin_before_comps)
    set(${PROJECT_NAME}_EXTRA_${tool}_PLUGIN_BEFORE_COMPONENTS ${tool_plugin_prefix}${tool_plugin_before_comps} CACHE INTERNAL "")
  endif()
  if(tool_plugin_during_comps)
    set(${PROJECT_NAME}_EXTRA_${tool}_PLUGIN_DURING_COMPONENTS ${tool_plugin_prefix}${tool_plugin_during_comps} CACHE INTERNAL "")
  endif()
  if(tool_plugin_after_comps)
    set(${PROJECT_NAME}_EXTRA_${tool}_PLUGIN_AFTER_COMPONENTS ${tool_plugin_prefix}${tool_plugin_after_comps} CACHE INTERNAL "")
  endif()
  set(${PROJECT_NAME}_EXTRA_${tool}_PLUGIN_ON_DEMAND ${tool_plugin_ondemand} CACHE INTERNAL "")
endfunction(set_Extra_Tool)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Extra_Tool| replace:: ``add_Extra_Tool``
#  .. _add_Extra_Tool:
#
#  add_Extra_Tool
#  --------------
#
#   .. command:: add_Extra_Tool(tool expression script force on_demand
#                              tool_program tool_configs tool_program_dirs
#                              tool_plugin_before_deps tool_plugin_before_comps
#                              tool_plugin_after_comps tool_plugin_ondemand)
#
#   Add definition of an extra tool to the set of extra tools of the environment.
#
#     :tool: the name of extra tool.
#     :expression: the constraint expression of the environment providing the extra tool.
#     :script: the path to the check script used to evaluate the environment.
#     :force: if TRUE force the update even if already defined.
#     :tool_program: path to the program main executable.
#     :tool_configs: platform configuration required by the tool.
#     :tool_program_dirs: runtime path to use for the program executable.
#     :force: if TRUE force the update even if already defined.
#     :tool_plugin_before_deps: path to plugin script that is executed before dependencies description.
#     :tool_plugin_before_comps: path to plugin script that is executed after dependencies description and before components description.
#     :tool_plugin_during_comps: path to plugin script that is executed after during components description.
#     :tool_plugin_after_comps: path to plugin script that is executed after components description.
#     :tool_plugin_ondemand: plugi scripts are activated only when the configuration is explicilty required by project.
#
function(add_Extra_Tool tool expression script force tool_program tool_configs tool_program_dirs tool_plugin_before_deps tool_plugin_before_comps tool_plugin_during_comps tool_plugin_after_comps tool_plugin_ondemand)
  if(NOT force)
    list(FIND ${PROJECT_NAME}_EXTRA_TOOLS ${tool} INDEX)
    if(NOT INDEX EQUAL -1)#already define, do not overwrite
      return()
    endif()
  endif()
  append_Unique_In_Cache(${PROJECT_NAME}_EXTRA_TOOLS ${tool})
  set_Extra_Tool(${tool} "${expression}" "${script}"
                "${tool_program}" "${tool_configs}" "${tool_program_dirs}"
              "${tool_plugin_before_deps}" "${tool_plugin_before_comps}" "${tool_plugin_during_comps}"
              "${tool_plugin_after_comps}" "${tool_plugin_ondemand}")
endfunction(add_Extra_Tool)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Language_Toolset| replace:: ``write_Language_Toolset``
#  .. _write_Language_Toolset:
#
#  write_Language_Toolset
#  ----------------------
#
#   .. command:: write_Language_Toolset(environment lang toolset prefix)
#
#   Write description of a language toolset into the project solution file.
#
#     :file: the path to target file to write in.
#     :lang: the label of target language
#     :toolset: the index of language toolset
#     :prefix: prefix for variable corresponding to the fucking constraint used to evaluate the environment
#
function(write_Language_Toolset file lang toolset prefix)
  #write the constraint expression corresponding to that toolset
  file(APPEND ${file} "set(${prefix}_${lang}_TOOLSET_${toolset}_CONSTRAINT_EXPRESSION ${${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_CONSTRAINT_EXPRESSION} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_${lang}_TOOLSET_${toolset}_CHECK_SCRIPT ${${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_CHECK_SCRIPT} CACHE INTERNAL \"\")\n")
  if(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER)#for compiled languages
    file(APPEND ${file} "set(${prefix}_${lang}_TOOLSET_${toolset}_COMPILER ${${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER} CACHE INTERNAL \"\")\n")
  endif()
  if(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER_ID)
    file(APPEND ${file} "set(${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_ID ${${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER_ID} CACHE INTERNAL \"\")\n")
  endif()
  if(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER_FLAGS)
    file(APPEND ${file} "set(${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_FLAGS \"${${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER_FLAGS}\" CACHE INTERNAL \"\")\n")
  endif()
  if(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_INCLUDE_DIRS)
    file(APPEND ${file} "set(${prefix}_${lang}_TOOLSET_${toolset}_INCLUDE_DIRS ${${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_INCLUDE_DIRS} CACHE INTERNAL \"\")\n")
  endif()
  if(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_LIBRARY)
    file(APPEND ${file} "set(${prefix}_${lang}_TOOLSET_${toolset}_LIBRARY ${${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_LIBRARY} CACHE INTERNAL \"\")\n")
  endif()
  if(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COVERAGE)
    file(APPEND ${file} "set(${prefix}_${lang}_TOOLSET_${toolset}_COVERAGE ${${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COVERAGE} CACHE INTERNAL \"\")\n")
  endif()
  if(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_INTERPRETER)
    file(APPEND ${file} "set(${prefix}_${lang}_TOOLSET_${toolset}_INTERPRETER ${${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_INTERPRETER} CACHE INTERNAL \"\")\n")
  endif()
  if(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER_AR)
    file(APPEND ${file} "set(${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_AR ${${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER_AR} CACHE INTERNAL \"\")\n")
  endif()
  if(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER_RANLIB)
    file(APPEND ${file} "set(${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_RANLIB ${${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_COMPILER_RANLIB} CACHE INTERNAL \"\")\n")
  endif()
  if(${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_HOST_COMPILER)#for languages that require C/C++ compiler to generate code
    file(APPEND ${file} "set(${prefix}_${lang}_TOOLSET_${toolset}_HOST_COMPILER ${${PROJECT_NAME}_${lang}_TOOLSET_${toolset}_HOST_COMPILER} CACHE INTERNAL \"\")\n")
  endif()
endfunction(write_Language_Toolset)


#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Extra_Tool| replace:: ``write_Extra_Tool``
#  .. _write_Extra_Tool:
#
#  write_Extra_Tool
#  ----------------
#
#   .. command:: write_Extra_Tool(environment lang toolset)
#
#   Write description of an extra tool into the project solution file.
#
#     :file: the path to target file to write in.
#
#     :tool: the name of the extra tool
#     :prefix: prefix for variable corresponding to the fucking constraint used to evaluate the environment
#
function(write_Extra_Tool file tool prefix)
  file(APPEND ${file} "set(${prefix}_EXTRA_${tool}_CONSTRAINT_EXPRESSION \"${${PROJECT_NAME}_EXTRA_${tool}_CONSTRAINT_EXPRESSION}\" CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_EXTRA_${tool}_CHECK_SCRIPT \"${${PROJECT_NAME}_EXTRA_${tool}_CHECK_SCRIPT}\" CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_EXTRA_${tool}_PROGRAM ${${PROJECT_NAME}_EXTRA_${tool}_PROGRAM} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_EXTRA_${tool}_PLATFORM_CONFIGURATIONS ${${PROJECT_NAME}_EXTRA_${tool}_PLATFORM_CONFIGURATIONS} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_EXTRA_${tool}_PROGRAM_DIRS ${${PROJECT_NAME}_EXTRA_${tool}_PROGRAM_DIRS} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_EXTRA_${tool}_PLUGIN_BEFORE_DEPENDENCIES ${${PROJECT_NAME}_EXTRA_${tool}_PLUGIN_BEFORE_DEPENDENCIES} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_EXTRA_${tool}_PLUGIN_BEFORE_COMPONENTS ${${PROJECT_NAME}_EXTRA_${tool}_PLUGIN_BEFORE_COMPONENTS} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_EXTRA_${tool}_PLUGIN_DURING_COMPONENTS ${${PROJECT_NAME}_EXTRA_${tool}_PLUGIN_DURING_COMPONENTS} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_EXTRA_${tool}_PLUGIN_AFTER_COMPONENTS ${${PROJECT_NAME}_EXTRA_${tool}_PLUGIN_AFTER_COMPONENTS} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_EXTRA_${tool}_PLUGIN_ON_DEMAND ${${PROJECT_NAME}_EXTRA_${tool}_PLUGIN_ON_DEMAND} CACHE INTERNAL \"\")\n")
endfunction(write_Extra_Tool)

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
#   :hashcode: hash code for input constraints agregated
#
function(generate_Environment_Solution_File hashcode)
set(file ${CMAKE_BINARY_DIR}/PID_Environment_Solution_Info.cmake)

set(prefix "${PROJECT_NAME}_${hashcode}")
file(WRITE ${file} "")#reset the description

file(APPEND ${file} "set(LAST_RUN_HASHCODE ${hashcode} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${prefix}_ACTION_INFO \"${${PROJECT_NAME}_ACTION_INFO}\" CACHE INTERNAL \"\")\n")
# need to write the constraints that will lie in binary of the environment
file(APPEND ${file} "set(${prefix}_CONSTRAINT_EXPRESSION ${${PROJECT_NAME}_CONSTRAINT_EXPRESSION} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${prefix}_CHECK ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_CHECK} CACHE INTERNAL \"\")\n")

file(APPEND ${file} "set(${prefix}_TARGET_INSTANCE ${${PROJECT_NAME}_TARGET_INSTANCE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${prefix}_TARGET_PLATFORM ${${PROJECT_NAME}_TARGET_PLATFORM} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${prefix}_TARGET_DISTRIBUTION ${${PROJECT_NAME}_TARGET_DISTRIBUTION} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${prefix}_TARGET_DISTRIBUTION_VERSION ${${PROJECT_NAME}_TARGET_DISTRIBUTION_VERSION} CACHE INTERNAL \"\")\n")

file(APPEND ${file} "set(${prefix}_CROSSCOMPILATION ${${PROJECT_NAME}_CROSSCOMPILATION} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_CROSSCOMPILATION)
  file(APPEND ${file} "set(${prefix}_TARGET_SYSROOT ${${PROJECT_NAME}_TARGET_SYSROOT} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_TARGET_STAGING ${${PROJECT_NAME}_TARGET_STAGING} CACHE INTERNAL \"\")\n")
endif()

file(APPEND ${file} "set(${prefix}_SYSTEM_WIDE_CONFIGURATION ${${PROJECT_NAME}_SYSTEM_WIDE_CONFIGURATION} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_SYSTEM_WIDE_CONFIGURATION)
  file(APPEND ${file} "set(${prefix}_LINKER ${${PROJECT_NAME}_LINKER} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_AR ${${PROJECT_NAME}_AR} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_RANLIB ${${PROJECT_NAME}_RANLIB} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_NM ${${PROJECT_NAME}_NM} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_OBJDUMP ${${PROJECT_NAME}_OBJDUMP} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_OBJCOPY ${${PROJECT_NAME}_OBJCOPY} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_RPATH ${${PROJECT_NAME}_RPATH} CACHE INTERNAL \"\")\n")
  fill_String_From_List(res_exe_linker_flags ${PROJECT_NAME}_EXE_LINKER_FLAGS " ")
  file(APPEND ${file} "set(${prefix}_EXE_LINKER_FLAGS \"${res_exe_linker_flags}\" CACHE INTERNAL \"\")\n")
  fill_String_From_List(res_module_linker_flags ${PROJECT_NAME}_MODULE_LINKER_FLAGS " ")
  file(APPEND ${file} "set(${prefix}_MODULE_LINKER_FLAGS \"${res_module_linker_flags}\" CACHE INTERNAL \"\")\n")
  fill_String_From_List(res_shared_linker_flags ${PROJECT_NAME}_SHARED_LINKER_FLAGS " ")
  file(APPEND ${file} "set(${prefix}_SHARED_LINKER_FLAGS \"${res_shared_linker_flags}\" CACHE INTERNAL \"\")\n")
  fill_String_From_List(res_static_linker_flags ${PROJECT_NAME}_STATIC_LINKER_FLAGS " ")
  file(APPEND ${file} "set(${prefix}_STATIC_LINKER_FLAGS \"${res_static_linker_flags}\" CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_LIBRARY_DIRS ${${PROJECT_NAME}_LIBRARY_DIRS} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_INCLUDE_DIRS ${${PROJECT_NAME}_INCLUDE_DIRS} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${prefix}_PROGRAM_DIRS ${${PROJECT_NAME}_PROGRAM_DIRS} CACHE INTERNAL \"\")\n")
endif()

file(APPEND ${file} "set(${prefix}_LANGUAGES ${${PROJECT_NAME}_LANGUAGES} CACHE INTERNAL \"\")\n")
foreach(lang IN LISTS ${PROJECT_NAME}_LANGUAGES)#default are C CXX ASM Python Fortran CUDA
  file(APPEND ${file} "set(${prefix}_${lang}_TOOLSETS ${${PROJECT_NAME}_${lang}_TOOLSETS} CACHE INTERNAL \"\")\n")#write the number of toolsets provided
  math(EXPR max_toolset "${${PROJECT_NAME}_${lang}_TOOLSETS}-1")
  foreach(toolset RANGE ${max_toolset})
    write_Language_Toolset(${file} ${lang} ${toolset} ${prefix})
  endforeach()
endforeach()

file(APPEND ${file} "set(${prefix}_EXTRA_TOOLS ${${PROJECT_NAME}_EXTRA_TOOLS} CACHE INTERNAL \"\")\n")
foreach(tool IN LISTS ${PROJECT_NAME}_EXTRA_TOOLS)
  write_Extra_Tool(${file} ${tool} ${prefix})
endforeach()

# Note : those two options should be considered when using Visual studio or Xcode with specific non default configurations
if(${PROJECT_NAME}_GENERATOR_PLATFORM)
  file(APPEND ${file} "set(${prefix}_GENERATOR_PLATFORM ${${PROJECT_NAME}_GENERATOR_PLATFORM} CACHE INTERNAL \"\")\n")
endif()
if(${PROJECT_NAME}_GENERATOR_TOOLSET)
  file(APPEND ${file} "set(${prefix}_GENERATOR_TOOLSET ${${PROJECT_NAME}_GENERATOR_TOOLSET} CACHE INTERNAL \"\")\n")
endif()
endfunction(generate_Environment_Solution_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Language_Toolset| replace:: ``print_Language_Toolset``
#  .. _print_Language_Toolset:
#
#  print_Language_Toolset
#  ----------------------
#
#   .. command:: print_Language_Toolset(environment lang toolset)
#
#   Print the solution evaluated by an environment for a given toolset of a given language.
#
#     :prefix: the prefix for environment with input constraints.
#     :lang: the label of target language
#     :toolset: the index of language toolset
#
function(print_Language_Toolset prefix lang toolset)
  if(NOT ${prefix}_${lang}_TOOLSETS)
    return()
  endif()
  set(lang_str)
  #print the settings of the default language toolset
  if(${prefix}_${lang}_TOOLSET_${toolset}_COMPILER)#for compiled languages
    if(${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_ID)
      set(lang_str "${lang_str}    * compiler : ${${prefix}_${lang}_TOOLSET_${toolset}_COMPILER} (id=${${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_ID})\n")
    else()
      set(lang_str "${lang_str}    * compiler : ${${prefix}_${lang}_TOOLSET_${toolset}_COMPILER}\n")
    endif()
  endif()
  if(${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_FLAGS)
    fill_String_From_List(flags_str ${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_FLAGS " ")
    set(lang_str "${lang_str}    * compilation flags : ${flags_str}\n")
  endif()
  if(${prefix}_${lang}_TOOLSET_${toolset}_INCLUDE_DIRS)
    fill_String_From_List(incs_str ${prefix}_${lang}_TOOLSET_${toolset}_INCLUDE_DIRS " ")
    set(lang_str "${lang_str}    * standard library include dirs : ${incs_str}\n")
  endif()
  if(${prefix}_${lang}_TOOLSET_${toolset}_LIBRARY)
    set(lang_str "${lang_str}    * standard libraries : ${${prefix}_${lang}_TOOLSET_${toolset}_LIBRARY}\n")
  endif()
  if(${prefix}_${lang}_TOOLSET_${toolset}_COVERAGE)
    set(lang_str "${lang_str}    * coverage tool : ${${prefix}_${lang}_TOOLSET_${toolset}_COVERAGE}\n")
  endif()
  if(${prefix}_${lang}_TOOLSET_${toolset}_INTERPRETER)
    set(lang_str "${lang_str}    * interpreter : ${${prefix}_${lang}_TOOLSET_${toolset}_INTERPRETER}\n")
  endif()
  if(${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_AR)
    set(lang_str "${lang_str}    * archiver : ${${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_AR}\n")
  endif()
  if(${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_RANLIB)
    set(lang_str "${lang_str}    * static libraries creator : ${${prefix}_${lang}_TOOLSET_${toolset}_COMPILER_RANLIB}\n")
  endif()
  if(${prefix}_${lang}_TOOLSET_${toolset}_HOST_COMPILER)#for languages that require C/C++ compiler to generate code
    set(lang_str "${lang_str}    * host compiler : ${${prefix}_${lang}_TOOLSET_${toolset}_HOST_COMPILER}\n")
  endif()
  message("${lang_str}")
endfunction(print_Language_Toolset)


#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Extra_Tool| replace:: ``print_Extra_Tool``
#  .. _print_Extra_Tool:
#
#  print_Extra_Tool
#  ----------------
#
#   .. command:: print_Extra_Tool(environment tool)
#
#   Print the solution evaluated by an environment for a given extra tool.
#
#     :prefix: the prefix of target environment.
#     :tool: the name of extra tool
#
function(print_Extra_Tool prefix tool)
  set(tool_str)
  if(${prefix}_EXTRA_${tool}_PROGRAM)
    set(tool_str "${tool_str}    * program: ${${prefix}_EXTRA_${tool}_PROGRAM}\n")
  endif()
  if(${prefix}_EXTRA_${tool}_PLATFORM_CONFIGURATIONS)
    set(tool_str "${tool_str}    * platform requirements: ${${prefix}_EXTRA_${tool}_PLATFORM_CONFIGURATIONS}\n")
  endif()
  if(${prefix}_EXTRA_${tool}_PLUGIN_BEFORE_DEPENDENCIES
    OR ${prefix}_EXTRA_${tool}_PLUGIN_BEFORE_COMPONENTS
    OR ${prefix}_EXTRA_${tool}_PLUGIN_AFTER_COMPONENTS
    OR ${prefix}_EXTRA_${tool}_PLUGIN_DURING_COMPONENTS)
    if(${prefix}_EXTRA_${tool}_PLUGIN_ON_DEMAND)
      set(tool_str "${tool_str}    * on demand plugin callbacks:\n")
    else()
      set(tool_str "${tool_str}    * plugin callbacks:\n")
    endif()
    if(${prefix}_EXTRA_${tool}_PLUGIN_BEFORE_DEPENDENCIES)
      set(tool_str "${tool_str}         + before dependencies: ${${prefix}_EXTRA_${tool}_PLUGIN_BEFORE_DEPENDENCIES}\n")
    endif()
    if(${prefix}_EXTRA_${tool}_PLUGIN_BEFORE_COMPONENTS)
      set(tool_str "${tool_str}         + before components: ${${prefix}_EXTRA_${tool}_PLUGIN_BEFORE_COMPONENTS}\n")
    endif()
    if(${prefix}_EXTRA_${tool}_PLUGIN_DURING_COMPONENTS)
      set(tool_str "${tool_str}         + during components: ${${prefix}_EXTRA_${tool}_PLUGIN_DURING_COMPONENTS}\n")
    endif()
    if(${prefix}_EXTRA_${tool}_PLUGIN_AFTER_COMPONENTS)
      set(tool_str "${tool_str}         + after components: ${${prefix}_EXTRA_${tool}_PLUGIN_AFTER_COMPONENTS}\n")
    endif()
  endif()
  message("${tool_str}")
endfunction(print_Extra_Tool)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Evaluated_Environment| replace:: ``print_Evaluated_Environment``
#  .. _print_Evaluated_Environment:
#
#  print_Evaluated_Environment
#  ---------------------------
#
#   .. command:: print_Evaluated_Environment(environment)
#
#   Print the solution evaluated by an environment.
#
#     :environment: the name of target environment.
#
function(print_Evaluated_Environment environment)
  message("[PID] description of environment ${environment} solution")
  set(prefix ${environment}_${LAST_RUN_HASHCODE})
  set(crosscomp_str)
  if(${prefix}_CROSSCOMPILATION)#when crosscompiling there are a few specific variables that may be set
    set(crosscomp_str "- requires crosscompilation\n")
    if(${prefix}_TARGET_SYSTEM_NAME)
      set(crosscomp_str "${crosscomp_str}  + target OS: ${${prefix}_TARGET_SYSTEM_NAME}")
    endif()
    if(${prefix}_TARGET_SYSTEM_PROCESSOR)
      set(crosscomp_str "${crosscomp_str}  + target processor: ${${prefix}_TARGET_SYSTEM_PROCESSOR}")
    endif()
    if(${prefix}_TARGET_SYSROOT)
      set(crosscomp_str "${crosscomp_str}  + sysroot: ${${prefix}_TARGET_SYSROOT}")
    endif()
    if(${prefix}_TARGET_STAGING)
      set(crosscomp_str "${crosscomp_str}  + staging: ${${prefix}_TARGET_STAGING}")
    endif()
    if(${prefix}_ABI_CONSTRAINT)
      set(crosscomp_str "${crosscomp_str}  + c++ library ABI: ${${prefix}_ABI_CONSTRAINT}")
    endif()
  endif()
  if(crosscomp_str)
    message("${crosscomp_str}")
  endif()

  #more on system wide configruation (not necessarily require crosscompilation)
  if(${prefix}_SYSTEM_WIDE_CONFIGURATION)
    if(${prefix}_LINKER)
      message("- linker: ${${prefix}_LINKER}")
    endif()
    if(${prefix}_AR)
      message("- static libraries archiver: ${${prefix}_AR}")
    endif()
    if(${prefix}_RANLIB)
      message("- static libraries creator: ${${prefix}_RANLIB}")
    endif()
    if(${prefix}_NM)
      message("- object symbols extractor: ${${prefix}_NM}")
    endif()
    if(${prefix}_OBJDUMP)
      message("- object symbols explorer: ${${prefix}_OBJDUMP}")
    endif()
    if(${prefix}_OBJCOPY)
      message("- object translator: ${${prefix}_OBJCOPY}")
    endif()
    if(${prefix}_RPATH)
      message("- rpath editor: ${${prefix}_RPATH}")
    endif()
    if(${prefix}_EXE_LINKER_FLAGS)
      message("- linker flags for executables: ${${prefix}_EXE_LINKER_FLAGS}")
    endif()
    if(${prefix}_MODULE_LINKER_FLAGS)
      message("- linker flags for modules: ${${prefix}_MODULE_LINKER_FLAGS}")
    endif()
    if(${prefix}_SHARED_LINKER_FLAGS)
      message("- linker flags for shared libraries: ${${prefix}_SHARED_LINKER_FLAGS}")
    endif()
    if(${prefix}_STATIC_LINKER_FLAGS)
      message("- linker flags for static libraries: ${${prefix}_STATIC_LINKER_FLAGS}")
    endif()
    if(${prefix}_LIBRARY_DIRS)
      message("- system libraries directories: ${${prefix}_LIBRARY_DIRS}")
    endif()
    if(${prefix}_INCLUDE_DIRS)
      message("- system include directories: ${${prefix}_INCLUDE_DIRS}")
    endif()
    if(${prefix}_PROGRAM_DIRS)
      message("- system program directories: ${${prefix}_PROGRAM_DIRS}")
    endif()
  endif()

  #now getting all informations about supported languages
  if(${prefix}_LANGUAGES)
    message("- configured languages:")
    foreach(lang IN LISTS ${prefix}_LANGUAGES)
      message("  + ${lang}:")
      print_Language_Toolset(${prefix} ${lang} 0)
      if(${prefix}_${lang}_TOOLSETS GREATER 1)
        message("    ++ additionnal toolsets:")
        math(EXPR max_toolset "${${prefix}_${lang}_TOOLSETS}-1")
        foreach(toolset RANGE 1 ${max_toolset})
          print_Language_Toolset(${prefix} ${lang} ${toolset})
        endforeach()
      endif()
    endforeach()
  endif()

  #now getting all informations about supported languages
  if(${prefix}_EXTRA_TOOLS)
    message("- configured extra tools:")
    foreach(tool IN LISTS ${prefix}_EXTRA_TOOLS)
      message("  + ${tool}:")
      print_Extra_Tool(${prefix} ${tool})
    endforeach()
  endif()

endfunction(print_Evaluated_Environment)
