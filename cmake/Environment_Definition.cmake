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
if(ENVIRONMENT_DEFINITION_INCLUDED)
  return()
endif()
set(ENVIRONMENT_DEFINITION_INCLUDED TRUE)

# prevent CMake automatic detection messages from appearing
set(CMAKE_MESSAGE_LOG_LEVEL NOTICE CACHE INTERNAL "")

get_filename_component(abs_path_to_ws ${WORKSPACE_DIR} ABSOLUTE)
set(WORKSPACE_DIR ${abs_path_to_ws} CACHE PATH "" FORCE)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Environment_API_Internal_Functions NO_POLICY_SCOPE)

include(CMakeParseArguments)

stop_Make_To_Print_Directories()

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Environment| replace:: ``PID_Environment``
#  .. _PID_Environment:
#
#  PID_Environment
#  ---------------
#
#   .. command:: PID_Environment(AUTHOR ... YEAR ... LICENSE ... DESCRIPTION ... [OPTIONS])
#
#   .. command:: declare_PID_Environment(AUTHOR ... YEAR ... LICENSE ... DESCRIPTION ... [OPTIONS])
#
#     Declare the current CMake project as a PID environment with specific meta-information passed as parameters.
#
#     .. rubric:: Required parameters
#
#     :AUTHOR <name>: The name of the author in charge of maintaining the environment.
#     :YEAR <dates>: Reflects the lifetime of the environment, e.g. ``YYYY-ZZZZ`` where ``YYYY`` is the creation year and ``ZZZZ`` the latest modification date.
#     :LICENSE <license name>: The name of the license applying to the environment. This must match one of the existing license file in the ``licenses`` directory of the workspace.
#     :DESCRIPTION <description>: A short description of the environment usage and utility.
#     :ADDRESS <url>: url of the environment's official repository.
#     :PUBLIC_ADDRESS <url>: provide a public counterpart to the repository `ADDRESS`
#
#     .. rubric:: Optional parameters
#
#     :INSTITUTION <institutions>: Define the institution(s) to which the reference author belongs.
#     :MAIL|EMAIL <e-mail>: E-mail of the reference author.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root ``CMakeLists.txt`` file of the environment before any other call to the PID API.
#        - It must be called **exactly once**.
#
#     .. admonition:: Effects
#        :class: important
#
#        Initialization of the environment internal state. After this call the package's content can be defined.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        PID_Environment(
#                          AUTHOR Robin Passama
#                          INSTITUTION LIRMM
#                          YEAR 2013-2018
#                          LICENSE CeCILL
#                          ADDRESS git@gite.lirmm.fr:pid/clang_toolchain.git
#                          DESCRIPTION "using clang toolchain in PID"
#        )
#
macro(PID_Environment)
  declare_PID_Environment(${ARGN})
endmacro(PID_Environment)

macro(declare_PID_Environment)
set(oneValueArgs LICENSE ADDRESS MAIL EMAIL PUBLIC_ADDRESS CONTRIBUTION_SPACE)
set(multiValueArgs AUTHOR INSTITUTION YEAR DESCRIPTION INFO)
cmake_parse_arguments(DECLARE_PID_ENV "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

if(NOT DECLARE_PID_ENV_LICENSE)
  message(FATAL_ERROR "[PID] CRITICAL ERROR: in PID_Environment, you must define a license for the environment project using LICENSE argument.")
  return()
endif()

if(NOT DECLARE_PID_ENV_AUTHOR)
  message(FATAL_ERROR "[PID] CRITICAL ERROR: in PID_Environment, you must define the contact author using AUTHOR argument.")
  return()
endif()

if(NOT DECLARE_PID_ENV_YEAR)
  message(FATAL_ERROR "[PID] CRITICAL ERROR: in PID_Environment, you must define the creation date using YEAR argument.")
  return()
endif()

if(NOT DECLARE_PID_ENV_DESCRIPTION)
  message(FATAL_ERROR "[PID] CRITICAL ERROR: in PID_Environment, you must provide a quich description of the environment usage and utility using DESCRIPTION argument.")
  return()
endif()

if(DECLARE_PID_ENV_MAIL)
  set(email ${DECLARE_PID_ENV_MAIL})
elseif(DECLARE_PID_ENV_EMAIL)
  set(email ${DECLARE_PID_ENV_EMAIL})
endif()

declare_Environment("${DECLARE_PID_ENV_AUTHOR}" "${DECLARE_PID_ENV_INSTITUTION}" "${email}" "${DECLARE_PID_ENV_YEAR}" "${DECLARE_PID_ENV_LICENSE}" "${DECLARE_PID_ENV_ADDRESS}" "${DECLARE_PID_ENV_PUBLIC_ADDRESS}" "${DECLARE_PID_ENV_DESCRIPTION}" "${DECLARE_PID_ENV_CONTRIBUTION_SPACE}" "${DECLARE_PID_ENV_INFO}")
unset(email)
endmacro(declare_PID_Environment)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Environment_Author| replace:: ``PID_Environment_Author``
#  .. _PID_Environment_Author:
#
#  PID_Environment_Author
#  ----------------------
#
#   .. command:: PID_Environment_Author(AUHTOR ...[INSTITUTION ...])
#
#   .. command:: add_PID_Environment_Author(AUHTOR ...[INSTITUTION ...])
#
#      Add an author to the list of authors of the environment.
#
#     .. rubric:: Required parameters
#
#     :AUTHOR <name>: The name of the author.
#
#     .. rubric:: Optional parameters
#
#     :INSTITUTION <institutions>: Define the institution(s) to which the author belongs to.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root CMakeLists.txt file of the package, after PID_Environment and before build_PID_Environment.
#
#     .. admonition:: Effects
#        :class: important
#
#         Add another author to the list of authors of the environment.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        PID_Environment_Author(AUTHOR Another Writter INSTITUTION LIRMM)
#
macro(PID_Environment_Author)
  add_PID_Environment_Author(${ARGN})
endmacro(PID_Environment_Author)

macro(add_PID_Environment_Author)
set(multiValueArgs AUTHOR INSTITUTION)
cmake_parse_arguments(ADD_PID_ENV_AUTHOR "" "" "${multiValueArgs}" ${ARGN} )
if(NOT ADD_PID_ENV_AUTHOR_AUTHOR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an author name must be given using AUTHOR keyword.")
endif()
add_Environment_Author("${ADD_PID_ENV_AUTHOR_AUTHOR}" "${ADD_PID_ENV_AUTHOR_INSTITUTION}")
endmacro(add_PID_Environment_Author)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Environment_Platform| replace:: ``PID_Environment_Platform``
#  .. _PID_Environment_Platform:
#
#  PID_Environment_Platform
#  ------------------------
#
#   .. command:: PID_Environment_Platform([OPTIONS])
#
#   .. command:: declare_PID_Environment_Platform([OPTIONS])
#
#     Defines for building the current environment on the given host platform that satisfies all requirements.
#
#     .. rubric:: Optional parameters
#
#     :PLATFORM <platform>: defines a complete specification of the target platform (e.g. x86_64_linux_stdc++11).
#     :INSTANCE <name>: defines a platform instance name.
#     :TYPE <proc>: the type of architecture for processor of the platform (e.g. x86).
#     :ARCH <bits>: the size of processor architecture registry, 16, 32 or 64.
#     :OS <kernel>: the OS kernel of the platform (e.g. linux).
#     :ABI <abi>: the default c++ ABI used by the platform, 98 or 11.
#     :DISTRIBUTION <distrib name>: the name of the distribution of the target platform.
#     :DISTRIB_VERSION <version>: the version of the distribution of the target platform.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root ``CMakeLists.txt`` file of the environment after call to PID_Environment and before call to build_PID_Environment.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        PID_Environment_Platform(
#           PLATFORM x86_64_linux_stdc++11
#           DISTRIBUTION ubuntu
#           DISTRIB_VERSION 18.04
#        )
#
macro(PID_Environment_Platform)
  declare_PID_Environment_Platform(${ARGN})
endmacro(PID_Environment_Platform)

macro(declare_PID_Environment_Platform)
if(${PROJECT_NAME}_PLATFORM_CONSTRAINT_DEFINED)
  message(FATAL_ERROR "[PID] CRITICAL ERROR: PID_Environment_Platform can be called only once per environment.")
  return()
endif()
set(oneValueArgs CHECK PLATFORM INSTANCE ARCH TYPE OS ABI DISTRIBUTION DISTRIB_VERSION)
cmake_parse_arguments(DECLARE_PID_ENV_PLATFORM "" "${oneValueArgs}" "" ${ARGN} )

if(DECLARE_PID_ENV_PLATFORM_DISTRIB_VERSION)
  if(NOT DECLARE_PID_ENV_PLATFORM_DISTRIBUTION)
    message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling PID_Environment_Platform you must define the DISTRIBUTION of the corresponding DISTRIB_VERSION.")
    return()
  endif()
endif()

if(DECLARE_PID_ENV_PLATFORM_PLATFORM)# a complete platform is specified
  if(DECLARE_PID_ENV_PLATFORM_ARCH
    OR DECLARE_PID_ENV_PLATFORM_TYPE
    OR DECLARE_PID_ENV_PLATFORM_OS
    OR DECLARE_PID_ENV_PLATFORM_ABI)
    message("[PID] WARNING : when calling PID_Environment_Platform you define a complete target platform using PLATFORM so TYPE, ARCH, OS and ABI arguments will not be interpreted.")
  endif()
  extract_Info_From_Platform(type_constraint arch_constraint os_constraint abi_constraint RES_INSTANCE RES_PLATFORM_BASE ${DECLARE_PID_ENV_PLATFORM_PLATFORM})

else()#getting more specific contraint on platform
  if(DECLARE_PID_ENV_PLATFORM_ARCH)
    set(arch_constraint ${DECLARE_PID_ENV_PLATFORM_ARCH})
  endif()
  if(DECLARE_PID_ENV_PLATFORM_TYPE)
    set(type_constraint ${DECLARE_PID_ENV_PLATFORM_TYPE})
  endif()
  if(DECLARE_PID_ENV_PLATFORM_OS)
    set(os_constraint ${DECLARE_PID_ENV_PLATFORM_OS})
  endif()
  if(DECLARE_PID_ENV_PLATFORM_ABI)
    set(abi_constraint ${DECLARE_PID_ENV_PLATFORM_ABI})
  endif()
endif()

define_Build_Environment_Platform("${DECLARE_PID_ENV_PLATFORM_INSTANCE}" "${type_constraint}" "${arch_constraint}" "${os_constraint}" "${abi_constraint}"
                                  "${DECLARE_PID_ENV_PLATFORM_DISTRIBUTION}" "${DECLARE_PID_ENV_PLATFORM_DISTRIB_VERSION}"
                                 )
unset(arch_constraint)
unset(type_constraint)
unset(os_constraint)
unset(abi_constraint)
endmacro(declare_PID_Environment_Platform)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Environment_Constraints| replace:: ``PID_Environment_Constraints``
#  .. _PID_Environment_Constraints:
#
#  PID_Environment_Constraints
#  ---------------------------
#
#   .. command:: PID_Environment_Constraints(OPTIONAL ... REQUIRED ... CHECK ...)
#
#   .. command:: declare_PID_Environment_Constraints(OPTIONAL ... REQUIRED ... CHECK ...)
#
#     Declare a set of optional and/or required constraints for the configuration. These constraints are used to provide parameters to environment scripts.
#
#     .. rubric:: Optional parameters
#
#     :REQUIRED ...: the list of constraints whose value must be set before calling it.
#     :OPTIONAL ...: the list of constraints whose value can be set or not before calling it.
#     :IN_BINARY ...: the list of constraints whose value is can be set or not before calling it BUT that written into binaries once check is OK.
#     :CHECK ...: the path to check script used to check if current CMAKE configuration matches constraints.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root ``CMakeLists.txt`` file of the environment after call to PID_Environment and before call to build_PID_Environment.
#
#     .. admonition:: Effects
#        :class: important
#
#        Defines parameters to the configuration process.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        PID_Environment_Constraints(
#                          REQUIRED version
#        )
#
macro(PID_Environment_Constraints)
  declare_PID_Environment_Constraints(${ARGN})
endmacro(PID_Environment_Constraints)

macro(declare_PID_Environment_Constraints)
  if(${PROJECT_NAME}_ENVIRONMENT_CONSTRAINTS_DEFINED)
    message(FATAL_ERROR "[PID] CRITICAL ERROR: PID_Environment_Constraints can be called only once per environment.")
    return()
  endif()
  set(monoValueArgs CHECK)
  set(multiValueArgs OPTIONAL REQUIRED IN_BINARY)
  cmake_parse_arguments(DECLARE_PID_ENV_CONSTRAINTS "" "${monoValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT DECLARE_PID_ENV_CONSTRAINTS_OPTIONAL
     AND NOT DECLARE_PID_ENV_CONSTRAINTS_REQUIRED
     AND NOT DECLARE_PID_ENV_CONSTRAINTS_IN_BINARY
     AND NOT DECLARE_PID_ENV_CONSTRAINTS_CHECK)
     message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling PID_Environment_Constraints you defined no optional / required contraints or check script. Aborting.")
     return()
  endif()
  if(DECLARE_PID_ENV_CONSTRAINTS_CHECK)
    if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${DECLARE_PID_ENV_CONSTRAINTS_CHECK})
      message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling PID_Environment_Constraints the check script ${DECLARE_PID_ENV_CONSTRAINTS_CHECK} does not exist in project. Aborting.")
      return()
    endif()
  endif()
  define_Environment_Constraints("${DECLARE_PID_ENV_CONSTRAINTS_OPTIONAL}"
                                 "${DECLARE_PID_ENV_CONSTRAINTS_REQUIRED}"
                                 "${DECLARE_PID_ENV_CONSTRAINTS_IN_BINARY}"
                                 "${DECLARE_PID_ENV_CONSTRAINTS_CHECK}"
                               )
endmacro(declare_PID_Environment_Constraints)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Environment_Dependencies| replace:: ``PID_Environment_Dependencies``
#  .. _PID_Environment_Dependencies:
#
#  PID_Environment_Dependencies
#  ----------------------------
#
#   .. command:: PID_Environment_Dependencies(...)
#
#   .. command:: declare_PID_Environment_Dependencies(...)
#
#     Define a dependency for the environment.
#
#     .. rubric:: parameters
#
#     :...: The list of environment that current environment project depends on. Each environment expression can (or must in case of required constraints) embbed constraint value definition.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root ``CMakeLists.txt`` file of the environment after call to PID_Environment_Platform and before call to build_PID_Environment.
#
#     .. admonition:: Effects
#        :class: important
#
#        Defines parameters to the configuration process.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        PID_Environment_Dependencies(gcc_toolchain)
#
macro(PID_Environment_Dependencies)
  declare_PID_Environment_Dependencies(${ARGN})
endmacro(PID_Environment_Dependencies)

macro(declare_PID_Environment_Dependencies)
  if(NOT "${ARGN}" STREQUAL "")
    foreach(dep IN ITEMS ${ARGN})
      add_Environment_Dependency(${dep})
    endforeach()
  endif()
endmacro(declare_PID_Environment_Dependencies)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Environment_Solution| replace:: ``PID_Environment_Solution``
#  .. _PID_Environment_Solution:
#
#  PID_Environment_Solution
#  ------------------------
#
#   .. command:: PID_Environment_Solution([CONFIGURE ...] [FILTERS])
#
#   .. command:: declare_PID_Environment_Solution(CONFIGURE ...  [FILTERS])
#
#     Define a solution to configure the environment for the current host platform.
#
#     .. rubric:: Optional parameters
#
#     :CONFIGURE ...: the path to the script file defining how to configure the build tools used by the environment.
#     :HOST: This filter This is a filter for applying the solution. The solution will apply only if target platform matches host platform.
#     :DISTRIBUTION ...: This is a filter for applying the solution. The solution will apply only if host is of same distribution.
#     :DISTRIB_VERSION ...: This is a filter for applying the solution. The solution will apply only if host is of same version of distribution (you must also use DISTRIBUTION filter).
#     :PLATFORM ...: This is a filter for applying the solution. The solution will apply only if host exactly matches the given platform. To be more selective use a combination of ARCH, TYPE, OS, ABI keywords
#     :ARCH ...: This is a filter for applying the solution. The solution will apply only if host has given processor architecture type (e.g. x86).
#     :TYPE ...: This is a filter for applying the solution. The solution will apply only if host has given processor architecture register size (e.g. 32).
#     :OS ...: This is a filter for applying the solution. The solution will apply only if host runs the given kernel.
#     :ABI ...: This is a filter for applying the solution. The solution will apply only if host default C++ ABI is 98 or 11.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root ``CMakeLists.txt`` file of the environment after call to PID_Environment and before call to build_PID_Environment.
#
#     .. admonition:: Effects
#        :class: important
#
#        Defines parameters to the configuration process.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        PID_Environment_Solution(OS linux DISTRIBUTION ubuntu CHECK ubuntu/check.cmake)
#
macro(PID_Environment_Solution)
  declare_PID_Environment_Solution(${ARGN})
endmacro(PID_Environment_Solution)

macro(declare_PID_Environment_Solution)
  set(options HOST)
  set(monoValueArgs CONFIGURE DISTRIBUTION DISTRIB_VERSION PLATFORM ARCH TYPE OS ABI)
  cmake_parse_arguments(DECLARE_PID_ENV_SOLUTION "${options}" "${monoValueArgs}" "" ${ARGN})

  if(NOT DECLARE_PID_ENV_SOLUTION_CONFIGURE)
    message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling PID_Environment_Solution you must define a configuration script using CONFIGURE keyword.")
    return()
  endif()
  if(DECLARE_PID_ENV_SOLUTION_PLATFORM)# a complete platform is specified
    if(DECLARE_PID_ENV_SOLUTION_ARCH
      OR DECLARE_PID_ENV_SOLUTION_TYPE
      OR DECLARE_PID_ENV_SOLUTION_OS
      OR DECLARE_PID_ENV_SOLUTION_ABI)
      message("[PID] WARNING : when calling PID_Environment_Solution you define a complete target platform using PLATFORM, so TYPE, ARCH, OS and ABI arguments will not be interpreted.")
    endif()
    extract_Info_From_Platform(type_constraint arch_constraint os_constraint abi_constraint RES_INSTANCE RES_PLATFORM_BASE ${DECLARE_PID_ENV_SOLUTION_PLATFORM})
  elseif(DECLARE_PID_ENV_SOLUTION_HOST)
    if(DECLARE_PID_ENV_SOLUTION_ARCH
      OR DECLARE_PID_ENV_SOLUTION_TYPE
      OR DECLARE_PID_ENV_SOLUTION_OS
      OR DECLARE_PID_ENV_SOLUTION_ABI)
      message("[PID] WARNING : when calling PID_Environment_Solution you define a complete target platform using HOST, so TYPE, ARCH, OS and ABI arguments will not be interpreted.")
    endif()
    set(arch_constraint ${CURRENT_PLATFORM_ARCH})
    set(type_constraint ${CURRENT_PLATFORM_TYPE})
    set(os_constraint ${CURRENT_PLATFORM_OS})
    set(abi_constraint ${CURRENT_PLATFORM_ABI})
  else()#getting more specific contraint on platform
    if(DECLARE_PID_ENV_SOLUTION_ARCH)
      set(arch_constraint ${DECLARE_PID_ENV_SOLUTION_ARCH})
    endif()
    if(DECLARE_PID_ENV_SOLUTION_TYPE)
      set(type_constraint ${DECLARE_PID_ENV_SOLUTION_TYPE})
    endif()
    if(DECLARE_PID_ENV_SOLUTION_OS)
      set(os_constraint ${DECLARE_PID_ENV_SOLUTION_OS})
    endif()
    if(DECLARE_PID_ENV_SOLUTION_ABI)
      set(abi_constraint ${DECLARE_PID_ENV_SOLUTION_ABI})
    endif()
  endif()

  if(DECLARE_PID_ENV_SOLUTION_HOST)
    if(DECLARE_PID_ENV_SOLUTION_DISTRIB_VERSION OR  DECLARE_PID_ENV_SOLUTION_DISTRIBUTION)
        message("[PID] WARNING : when calling PID_Environment_Solution you define a complete target platform using HOST, so DISTRIBUTION and DISTRIB_VERSION arguments will not be interpreted")
    endif()
    set(distrib ${CURRENT_DISTRIBUTION})
    set(distrib_version ${CURRENT_DISTRIBUTION_VERSION})

  else()
    if(DECLARE_PID_ENV_SOLUTION_DISTRIB_VERSION)
      if(NOT DECLARE_PID_ENV_SOLUTION_DISTRIBUTION)
        message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling PID_Environment_Solution you define distribution version (using DISTRIB_VERSION) but no DISTRIBUTION. Please specify the DISTRIBUTION also.")
        return()
      endif()
    endif()
    set(distrib ${DECLARE_PID_ENV_SOLUTION_DISTRIBUTION})
    set(distrib_version ${DECLARE_PID_ENV_SOLUTION_DISTRIB_VERSION})
  endif()


  add_Environment_Solution_Procedure("${type_constraint}" "${arch_constraint}" "${os_constraint}" "${abi_constraint}"
                                       "${distrib}" "${distrib_version}"
                                       "${DECLARE_PID_ENV_SOLUTION_CONFIGURE}")
  unset(arch_constraint)
  unset(type_constraint)
  unset(os_constraint)
  unset(abi_constraint)
  unset(distrib)
  unset(distrib_version)
endmacro(declare_PID_Environment_Solution)

#.rst:
#
# .. ifmode:: user
#
#  .. |build_PID_Environment| replace:: ``build_PID_Environment``
#  .. _build_PID_Environment:
#
#  build_PID_Environment
#  ---------------------
#
#   .. command:: build_PID_Environment()
#
#       Configure PID environment according to previous information.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be the last one called in the root CMakeList.txt file of the environment.
#
#     .. admonition:: Effects
#        :class: important
#
#         This function launch the configuration of the environment build process.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        build_PID_Environment()
#
macro(build_PID_Environment)
  create_Shell_Script_Symlinks()
  if(${ARGC} GREATER 0)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the build_PID_Environment command requires no arguments.")
  endif()
  build_Environment_Project()
endmacro(build_PID_Environment)

#.rst:
#
# .. ifmode:: script
#
#  .. |get_Configured_Environment_Tool| replace:: ``get_Configured_Environment_Tool``
#  .. _get_Configured_Environment_Tool:
#
#  get_Configured_Environment_Tool
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Configured_Environment_Tool(LANGUAGE ... [COMPILER ...] [AR...] [RANLIB...]
#                                                [FLAGS...] [HOST_COMPILER...] [TOOLCHAIN_ID...])
#
#   .. command:: get_Configured_Environment_Tool(SYSTEM [GEN_TOOLSET ...] GEN_PLATFORM...] [LINKER ...] [AR...] [RANLIB...]
#                                               [EXE_FLAGS...] [MODULE_FLAGS...] [STATIC_FLAGS...] [SHARED_FLAGS...])
#
#     Get information about the currenltly configured tools used by the current environment. Support different signatures.
#
#     .. rubric:: Required parameters
#
#     :LANGUAGE lang: the language that is being configured (C, CXX, ASM, Fortran, CUDA, Pyhthon).
#     :SYSTEM: tells that system wide (as opposed to language wide) variables are configured.
#
#     .. rubric:: Optional parameters
#
#     :COMPILER ...: the output variable containing the path to the compiler in use.
#     :AR ...: the  output variable containing the path to the archiver tool in use.
#     :RANLIB ...: the output variable containing the path to static library creation tool in use.
#     :HOST_COMPILER ...: the  output variable containing the path to host c/c++ compiler in use.
#     :TOOLCHAIN_ID ...: the  output variable containing the toolchain ID for language.
#     :INTERPRETER ...: the  output variable containing the path to langauge interpreter.
#     :INCLUDE_DIRS ...: the  output variable containing the set of path to language standard library include dirs or system include dirs.
#     :LIBRARY ...: the output variable containing the path to standard language library in use.
#     :FLAGS ...: the output variable containing the set of compiler flags (if used with LANGUAGE).
#     :LIBRARY_DIRS ...: the  output variable containing the set of path to system library dirs.
#     :PROGRAM_DIRS ...: the  output variable containing the set of path to system program dirs.
#     :LINKER ...: the output variable containing the path to the linker in use.
#     :GEN_TOOLSET ...: the output variable containing the name of the generator toolset to use.
#     :GEN_PLATFORM ...: the output variable containing the name of the generator platform to use.
#     :EXE_FLAGS ...: the output variable containing the link flags for executables.
#     :MODULE_FLAGS ...: the output variable containing the link flags for modules.
#     :STATIC_FLAGS ...: the output variable containing the link flags for static libraries.
#     :SHARED_FLAGS ...: the output variable containing the link flags for shared libraries.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in script files of the environment.
#
#     .. admonition:: Effects
#        :class: important
#
#        Set the variables used to configure the build environment.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        get_Configured_Environment_Tool(LANGUAGE ASM COMPILER asm_compiler_path)
#
#        get_Configured_Environment_Tool(SYSTEM LINKER path_to_linker EXE_FLAGS flags_for_exe)
#
function(get_Configured_Environment_Tool)
  set(options SYSTEM)
  set(monoValueArgs FLAGS EXE_FLAGS MODULE_FLAGS STATIC_FLAGS SHARED_FLAGS SYSROOT STAGING LANGUAGE COMPILER HOST_COMPILER TOOLCHAIN_ID INTERPRETER NM OBJDUMP OBJCOPY LIBRARY AR RANLIB LINKER GEN_TOOLSET GEN_PLATFORM PROGRAM_DIRS LIBRARY_DIRS INCLUDE_DIRS)
  cmake_parse_arguments(GET_CONF_ENV_TOOL "${options}" "${monoValueArgs}" "" ${ARGN})

  if(NOT GET_CONF_ENV_TOOL_LANGUAGE AND NOT GET_CONF_ENV_TOOL_SYSTEM)
    message(FATAL_ERROR "[PID] CRITICAL ERROR: when calling get_Configured_Environment_Tool, you must use LANGUAGE or SYSTEM arguments.")
    return()
  elseif(GET_CONF_ENV_TOOL_LANGUAGE AND GET_CONF_ENV_TOOL_SYSTEM)
    message(FATAL_ERROR "[PID] CRITICAL ERROR: when calling get_Configured_Environment_Tool, you must use LANGUAGE or SYSTEM arguments but not both.")
    return()
  endif()

  if(GET_CONF_ENV_TOOL_SYSTEM)
    if(GET_CONF_ENV_TOOL_GEN_TOOLSET)
      set(${GET_CONF_ENV_TOOL_GEN_TOOLSET} ${${PROJECT_NAME}_GENERATOR_TOOLSET} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_GEN_PLATFORM)
      set(${GET_CONF_ENV_TOOL_GEN_PLATFORM} ${${PROJECT_NAME}_GENERATOR_PLATFORM} PARENT_SCOPE)
    endif()

    #manage crosscompilation
    if(GET_CONF_ENV_TOOL_SYSROOT)#warning overwritting previosu value if any forced
      set(${GET_CONF_ENV_TOOL_SYSROOT} ${${PROJECT_NAME}_TARGET_SYSROOT} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_STAGING)#warning overwritting previosu value if any forced
      set(${GET_CONF_ENV_TOOL_STAGING} ${${PROJECT_NAME}_TARGET_STAGING} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_LINKER)
      set(${GET_CONF_ENV_TOOL_LINKER} ${${PROJECT_NAME}_LINKER} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_AR)
      set(${GET_CONF_ENV_TOOL_AR} ${${PROJECT_NAME}_AR} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_RANLIB)
      set(${GET_CONF_ENV_TOOL_RANLIB} ${${PROJECT_NAME}_RANLIB} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_NM)
      set(${GET_CONF_ENV_TOOL_NM} ${${PROJECT_NAME}_NM} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_OBJDUMP)
      set(${GET_CONF_ENV_TOOL_OBJDUMP} ${${PROJECT_NAME}_OBJDUMP} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_OBJCOPY)
      set(${CONF_ENV_TOOL_OBJCOPY} ${${PROJECT_NAME}_OBJCOPY} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_INCLUDE_DIRS)
      set(${GET_CONF_ENV_TOOL_INCLUDE_DIRS} ${${PROJECT_NAME}_INCLUDE_DIRS} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_LIBRARY_DIRS)
      set(${GET_CONF_ENV_TOOL_LIBRARY_DIRS} ${${PROJECT_NAME}_LIBRARY_DIRS} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_PROGRAM_DIRS)
      set(${GET_CONF_ENV_TOOL_PROGRAM_DIRS} ${${PROJECT_NAME}_PROGRAM_DIRS} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_EXE_FLAGS)
      set(${GET_CONF_ENV_TOOL_EXE_FLAGS} ${${PROJECT_NAME}_EXE_LINKER_FLAGS} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_MODULE_FLAGS)
      set(${GET_CONF_ENV_TOOL_MODULE_FLAGS} ${${PROJECT_NAME}_MODULE_LINKER_FLAGS} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_STATIC_FLAGS)
      set(${GET_CONF_ENV_TOOL_STATIC_FLAGS} ${${PROJECT_NAME}_STATIC_LINKER_FLAGS} PARENT_SCOPE)
    endif()
    if(GET_CONF_ENV_TOOL_SHARED_FLAGS)
      set(${GET_CONF_ENV_TOOL_SHARED_FLAGS} ${${PROJECT_NAME}_SHARED_LINKER_FLAGS} PARENT_SCOPE)
    endif()
  else()#get information about a specific language
    set(lang ${GET_CONF_ENV_TOOL_LANGUAGE})
    set(configured_toolset ${PROJECT_NAME}_${lang}_TOOLSET_0)
    if(GET_CONF_ENV_TOOL_COMPILER)
      if(${configured_toolset}_COMPILER)
        set(${GET_CONF_ENV_TOOL_COMPILER} ${${configured_toolset}_COMPILER} PARENT_SCOPE)
      endif()
    endif()
    if(GET_CONF_ENV_TOOL_RANLIB)
      if(${configured_toolset}_COMPILER_RANLIB)
        set(${GET_CONF_ENV_TOOL_RANLIB} ${${configured_toolset}_COMPILER_RANLIB} PARENT_SCOPE)
      endif()
    endif()
    if(GET_CONF_ENV_TOOL_AR)
      if(${configured_toolset}_COMPILER_AR)
        set(${GET_CONF_ENV_TOOL_AR} ${${configured_toolset}_COMPILER_AR} PARENT_SCOPE)
      endif()
    endif()
    if(GET_CONF_ENV_TOOL_HOST_COMPILER)
      if(${configured_toolset}_HOST_COMPILER)
        set(${GET_CONF_ENV_TOOL_HOST_COMPILER} ${${configured_toolset}_HOST_COMPILER} PARENT_SCOPE)
      endif()
    endif()
    if(GET_CONF_ENV_TOOL_TOOLCHAIN_ID)
      if(${configured_toolset}_COMPILER_ID)
        set(${GET_CONF_ENV_TOOL_TOOLCHAIN_ID} ${${configured_toolset}_COMPILER_ID} PARENT_SCOPE)
      endif()
    endif()
    if(GET_CONF_ENV_TOOL_INTERPRETER)
      if(${configured_toolset}_INTERPRETER)
        set(${GET_CONF_ENV_TOOL_INTERPRETER} ${${configured_toolset}_INTERPRETER} PARENT_SCOPE)
      endif()
    endif()
    if(GET_CONF_ENV_TOOL_LIBRARY)
      if(${configured_toolset}_LIBRARY)
        set(${GET_CONF_ENV_TOOL_LIBRARY} ${${configured_toolset}_LIBRARY} PARENT_SCOPE)
      endif()
    endif()
    if(GET_CONF_ENV_TOOL_INCLUDE_DIRS)
      if(${configured_toolset}_INCLUDE_DIRS)
        set(${GET_CONF_ENV_TOOL_INCLUDE_DIRS} ${${configured_toolset}_INCLUDE_DIRS} PARENT_SCOPE)
      endif()
    endif()
    if(GET_CONF_ENV_TOOL_FLAGS)
      if(${configured_toolset}_COMPILER_FLAGS)
        set(${GET_CONF_ENV_TOOL_FLAGS} "${${configured_toolset}_COMPILER_FLAGS}" PARENT_SCOPE)
      endif()
    endif()
  endif()

endfunction(get_Configured_Environment_Tool)

#.rst:
#
# .. ifmode:: script
#
#  .. |configure_Environment_Tool| replace:: ``configure_Environment_Tool``
#  .. _configure_Environment_Tool:
#
#  configure_Environment_Tool
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: configure_Environment_Tool(LANGUAGE ... [COMPILER...] [COVERAGE ...] [AR...] [RANLIB...] [FLAGS...])
#
#   .. command:: configure_Environment_Tool(SYSTEM [GENERATOR...] [LINKER ...] [[EXE|MODULE|STATIC|SHARED] FLAGS...])
#
#   .. command:: configure_Environment_Tool(EXTRA ... [OPTIONS ...] [PLUGIN ...])
#
#     Configure the tools used for the current environment. Support different signatures.
#
#     .. rubric:: Required parameters
#
#     :LANGUAGE lang: the language that is being configured (C, CXX, ASM, Fortran, CUDA).
#     :SYSTEM: tells that system wide (as opposed to language wide) variables are configured.
#     :EXTRA tool_name: tells that an extra tool is defined.
#
#     .. rubric:: Optional parameters
#
#     :COMPILER ...: the path to the compiler in use (for LANGUAGE).
#     :INTERPRETER ...: the path to the interpreter in use (for LANGUAGE, Python only for now).
#     :HOST_COMPILER ...: the path to the host C compiler in use (for LANGUAGE, CUDA only for now).
#     :TOOLSET_ID  ...: identifier of the toolset (for LANGUAGE).
#     :AR ...: the path to the archive tool in use (for LANGUAGE and SYSTEM).
#     :COVERAGE ...: the path to the coverage tool in use (for LANGUAGE).
#     :RANLIB ...: the path to the static library creation tool (for LANGUAGE and SYSTEM)..
#     :FLAGS ...: set of compiler flags (if used with LANGUAGE) or linker flags (if used with SYSTEM) to use.
#     :LINKER ...: the path to the linker in use (for SYSTEM).
#     :NM ...: the path to the nm tool in use (for SYSTEM).
#     :RPATH ...: path to the rpath manipulation tool (for SYSTEM, crosscompilation only).
#     :OBJDUMP ...: the path to the objdump tool in use (for SYSTEM).
#     :OBJCOPY ...: the path to the objcopy tool in use (for SYSTEM).
#     :GEN_TOOLSET ...: the name of the generator toolset to use (for SYSTEM).
#     :GEN_PLATFORM ...: the name of the generator platform to use (for SYSTEM).
#     :EXE|MODULE|STATIC|SHARED: filters for selecting adequate type of binaries for which to apply link flags (for SYSTEM).
#     :CURRENT: use the current environment to set all adequate variables of the target language (for LANGUAGE AND SYSTEM).
#     :PROGRAM ...: memorize the path to the main extra tool program (for EXTRA).
#     :LIBRARY: path to the target library (for EXTRA, LANGUAGE and SYSTEM).
#     :PROGRAM_DIRS ...: list of path to library dirs (for EXTRA and SYSTEM).
#     :INCLUDE_DIRS ...: list of path to include dirs (for LANGUAGE and SYSTEM).
#     :LIBRARY_DIRS ...: list of path to library dirs (for SYSTEM).
#     :CONFIGURATION ...: list of required platform configurations (for EXTRA).
#     :PLUGIN [ BEFORE_DEPS ...] [BEFORE_COMPS ...] [DURING_COMPS ...] [AFTER_COMPS ...]: plugin script to call at specific package configuration times.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in script files of the environment.
#
#     .. admonition:: Effects
#        :class: important
#
#        Set the variables used to configure the build environment.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        configure_Environment_Tool(LANGUAGE ASM COMPILER ${CMAKE_ASM_COMPILER})
#
#        configure_Environment_Tool(SYSTEM LINKER ${CMAKE_LINKER} FLAGS -m32 )
#
#        configure_Environment_Tool(EXTRA pkg-config PROGRAM ${PKG_CONFIG_EXECUTABLE}
#                                   PLUGIN AFTER use_pkg-config.cmake)
#
function(configure_Environment_Tool)
  set(options SYSTEM EXE MODULE STATIC SHARED CURRENT)
  set(monoValueArgs EXTRA PROGRAM CONFIGURATION SYSROOT STAGING LANGUAGE COMPILER HOST_COMPILER TOOLCHAIN_ID INTERPRETER NM OBJDUMP OBJCOPY AR RANLIB LINKER GEN_TOOLSET GEN_PLATFORM COVERAGE RPATH)
  set(multiValueArgs PLUGIN FLAGS PROGRAM_DIRS LIBRARY_DIRS INCLUDE_DIRS LIBRARY)
  cmake_parse_arguments(CONF_ENV_TOOL "${options}" "${monoValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT CONF_ENV_TOOL_LANGUAGE AND NOT CONF_ENV_TOOL_SYSTEM AND NOT CONF_ENV_TOOL_EXTRA)
    message(FATAL_ERROR "[PID] CRITICAL ERROR: when calling configure_Environment_Tool, you must use LANGUAGE, SYSTEM or EXTRA arguments.")
    return()
  else()
    set(nb_found 0)
    if(CONF_ENV_TOOL_SYSTEM)
      math(EXPR nb_found "${nb_found}+1")
    endif()
    if(CONF_ENV_TOOL_LANGUAGE)
      math(EXPR nb_found "${nb_found}+1")
    endif()
    if(CONF_ENV_TOOL_EXTRA)
      math(EXPR nb_found "${nb_found}+1")
    endif()
    if(nb_found GREATER 1)
      message(FATAL_ERROR "[PID] CRITICAL ERROR: when calling configure_Environment_Tool, arguments LANGUAGE, SYSTEM and EXTRA cannot be used at the same time.")
      return()
    endif()
  endif()
  if(CONF_ENV_TOOL_LANGUAGE)
    if(CONF_ENV_TOOL_CURRENT)#using current detected compiler settings by default
      set(use_compiler ${CMAKE_${CONF_ENV_TOOL_LANGUAGE}_COMPILER})
      set(use_compiler_ar ${CMAKE_${CONF_ENV_TOOL_LANGUAGE}_COMPILER_AR})
      set(use_compiler_ranlib ${CMAKE_${CONF_ENV_TOOL_LANGUAGE}_COMPILER_RANLIB})
      set(use_host_compiler ${CMAKE_${CONF_ENV_TOOL_LANGUAGE}_HOST_COMPILER})
      set(use_compiler_flags ${CMAKE_${CONF_ENV_TOOL_LANGUAGE}_FLAGS})
    endif()
    if(CONF_ENV_TOOL_COMPILER)
      set(use_compiler ${CONF_ENV_TOOL_COMPILER})
    endif()
    if(CONF_ENV_TOOL_TOOLCHAIN_ID)
      set(use_compiler_id ${CONF_ENV_TOOL_TOOLCHAIN_ID})
    endif()
    if(CONF_ENV_TOOL_AR)
      set(use_compiler_ar ${CONF_ENV_TOOL_AR})
    endif()
    if(CONF_ENV_TOOL_RANLIB)
      set(use_compiler_ranlib ${CONF_ENV_TOOL_RANLIB})
    endif()
    if(CONF_ENV_TOOL_HOST_COMPILER)
      set(use_host_compiler ${CONF_ENV_TOOL_HOST_COMPILER})
    endif()
    if(CONF_ENV_TOOL_FLAGS)
      set(use_compiler_flags ${CONF_ENV_TOOL_FLAGS})
    endif()

    add_Language_Toolset(${CONF_ENV_TOOL_LANGUAGE} TRUE
                         "" "" #Note: for local toolset, not possible to resolve the expression immediately, need the environment to be completely evaluated, and same for check script
                         "${use_compiler}"
                         "${use_compiler_id}"
                         "${use_compiler_ar}"
                         "${use_compiler_ranlib}"
                         "${use_compiler_flags}"
                         "${CONF_ENV_TOOL_INTERPRETER}"
                         "${CONF_ENV_TOOL_INCLUDE_DIRS}"
                         "${CONF_ENV_TOOL_LIBRARY}"
                         "${CONF_ENV_TOOL_COVERAGE}"
                         "${use_host_compiler}")

  elseif(CONF_ENV_TOOL_SYSTEM)

    if(CONF_ENV_TOOL_CURRENT)#set default value for system
      set(${PROJECT_NAME}_GENERATOR_TOOLSET ${CMAKE_GENERATOR_TOOLSET} CACHE INTERNAL "")
      set(${PROJECT_NAME}_GENERATOR_PLATFORM ${CMAKE_GENERATOR_PLATFORM} CACHE INTERNAL "")
      set(${PROJECT_NAME}_TARGET_SYSROOT ${CMAKE_SYSROOT} CACHE INTERNAL "")
      set(${PROJECT_NAME}_TARGET_STAGING ${CMAKE_STAGING_PREFIX} CACHE INTERNAL "")
      set(${PROJECT_NAME}_LINKER ${CMAKE_LINKER} CACHE INTERNAL "")
      set(${PROJECT_NAME}_AR ${CMAKE_AR} CACHE INTERNAL "")
      set(${PROJECT_NAME}_RANLIB ${CMAKE_RANLIB} CACHE INTERNAL "")
      set(${PROJECT_NAME}_NM ${CMAKE_NM} CACHE INTERNAL "")
      set(${PROJECT_NAME}_OBJDUMP ${CMAKE_OBJDUMP} CACHE INTERNAL "")
      set(${PROJECT_NAME}_OBJCOPY ${CMAKE_OBJCOPY} CACHE INTERNAL "")
      set(${PROJECT_NAME}_RPATH ${RPATH_UTILITY} CACHE INTERNAL "")
      set(${PROJECT_NAME}_INCLUDE_DIRS ${CMAKE_SYSTEM_INCLUDE_PATH} CACHE INTERNAL "")
      set(${PROJECT_NAME}_LIBRARY_DIRS ${CMAKE_SYSTEM_LIBRARY_PATH} CACHE INTERNAL "")
      set(${PROJECT_NAME}_PROGRAM_DIRS ${CMAKE_SYSTEM_PROGRAM_PATH} CACHE INTERNAL "")
      set(${PROJECT_NAME}_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}" CACHE INTERNAL "")
      set(${PROJECT_NAME}_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS}" CACHE INTERNAL "")
      set(${PROJECT_NAME}_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}" CACHE INTERNAL "")
      set(${PROJECT_NAME}_STATIC_LINKER_FLAGS "${CMAKE_STATIC_LINKER_FLAGS}" CACHE INTERNAL "")
    endif()

    set(exe_flags)
    set(module_flags)
    set(static_flags)
    set(shared_flags)
    if(CONF_ENV_TOOL_FLAGS)
      #checking filters for flags
      set(filter_found FALSE)
      if(CONF_ENV_TOOL_EXE)
        set(filter_found TRUE)
        set(exe_flags "${CONF_ENV_TOOL_FLAGS}")
      endif()
      if(CONF_ENV_TOOL_MODULE)
        set(filter_found TRUE)
        set(module_flags "${CONF_ENV_TOOL_FLAGS}")
      endif()
      if(CONF_ENV_TOOL_STATIC)
        set(filter_found TRUE)
        set(static_flags "${CONF_ENV_TOOL_FLAGS}")
      endif()
      if(CONF_ENV_TOOL_SHARED)
        set(filter_found TRUE)
        set(shared_flags "${CONF_ENV_TOOL_FLAGS}")
      endif()
      if(NOT filter_found)#apply flags to all types
        set(exe_flags "${CONF_ENV_TOOL_FLAGS}")
        set(module_flags "${CONF_ENV_TOOL_FLAGS}")
        set(static_flags "${CONF_ENV_TOOL_FLAGS}")
        set(shared_flags "${CONF_ENV_TOOL_FLAGS}")
      endif()
    endif()

    set_System_Wide_Configuration("${CONF_ENV_TOOL_GEN_TOOLSET}" "${CONF_ENV_TOOL_GEN_PLATFORM}"
      "${CONF_ENV_TOOL_SYSROOT}" "${CONF_ENV_TOOL_STAGING}"
        "${CONF_ENV_TOOL_LINKER}" "${CONF_ENV_TOOL_AR}"   "${CONF_ENV_TOOL_RANLIB}"
        "${CONF_ENV_TOOL_NM}"   "${CONF_ENV_TOOL_OBJDUMP}" "${CONF_ENV_TOOL_OBJCOPY}" "${CONF_ENV_TOOL_RPATH}"
        "${CONF_ENV_TOOL_INCLUDE_DIRS}"   "${CONF_ENV_TOOL_LIBRARY_DIRS}" "${CONF_ENV_TOOL_PROGRAM_DIRS}"
        "${exe_flags}" "${module_flags}" "${static_flags}" "${shared_flags}"
    )

  elseif(CONF_ENV_TOOL_EXTRA)#extra tool defined
    if(CONF_ENV_TOOL_PLUGIN)
      set(options ON_DEMAND)
      set(monoValueArgs BEFORE_DEPS BEFORE_COMPS DURING_COMPS AFTER_COMPS)
      cmake_parse_arguments(CONF_PLUGIN "${options}" "${monoValueArgs}" "" ${CONF_ENV_TOOL_PLUGIN})
      set(plugin_before_deps ${CONF_PLUGIN_BEFORE_DEPS})
      set(plugin_before_comps ${CONF_PLUGIN_BEFORE_COMPS})
      set(plugin_during_comps ${CONF_PLUGIN_DURING_COMPS})
      set(plugin_after_comps ${CONF_PLUGIN_AFTER_COMPS})
      set(plugin_ondemand ${CONF_PLUGIN_ON_DEMAND})
    endif()
    # Note: no expression provided since it will be computable when envronment is fully configured
    # Note same for check script that is automatically added when generating solution description
    add_Extra_Tool(${CONF_ENV_TOOL_EXTRA} "" "" TRUE
                  "${CONF_ENV_TOOL_PROGRAM}" "${CONF_ENV_TOOL_CONFIGURATION}" "${CONF_ENV_TOOL_PROGRAM_DIRS}"
                  "${plugin_before_deps}" "${plugin_before_comps}" "${plugin_during_comps}" "${plugin_after_comps}" "${plugin_ondemand}")
  endif()
endfunction(configure_Environment_Tool)

#.rst:
#
# .. ifmode:: script
#
#  .. |return_Environment_Configured| replace:: ``return_Environment_Configured``
#  .. _return_Environment_Configured:
#
#  return_Environment_Configured
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: return_Environment_Configured(value)
#
#       Sets the environment configuration process result.
#
#     .. rubric:: Required parameters
#
#     :value: return value of the scrit : TRUE if configuration is OK and FALSE otherwise.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in script files of the environment.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        return_Environment_Configured()
#
macro(return_Environment_Configured value)
  set(ENVIRONMENT_CONFIG_RESULT ${value} CACHE INTERNAL "")
  return()
endmacro(return_Environment_Configured)


#.rst:
#
# .. ifmode:: script
#
#  .. |return_Environment_Check| replace:: ``return_Environment_Check``
#  .. _return_Environment_Check:
#
#  return_Environment_Check
#  ^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: return_Environment_Check(value)
#
#       Sets the environment check process result.
#
#     .. rubric:: Required parameters
#
#     :value: return value of the scrit : TRUE if current CMake configuration matches constraints and FALSE otherwise.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in check script file of the environment.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        return_Environment_Check()
#
macro(return_Environment_Check value)
  set(ENVIRONMENT_CHECK_RESULT ${value} CACHE INTERNAL "")
  return()
endmacro(return_Environment_Check)

#.rst:
#
# .. ifmode:: script
#
#  .. |host_Match_Target_Platform| replace:: ``host_Match_Target_Platform``
#  .. _host_Match_Target_Platform:
#
#  host_Match_Target_Platform
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: host_Match_Target_Platform(IT_MATCHES)
#
#     Check whether host fullfil all target platform constraints.
#
#     .. rubric:: Required parameters
#
#     :IT_MATCHES: the ouput variable that is true if host fullfils all target platform constraints.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in script files of the environment.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        host_Match_Target_Platform(MATCHING)
#        if(MATCHING)
#          # do something
#        endif()
#
function(host_Match_Target_Platform IT_MATCHES)
  set(${IT_MATCHES} FALSE PARENT_SCOPE)
  get_Environment_Host_Platform(DISTRIBUTION host_distrib DISTRIB_VERSION host_distrib_version
                                 TYPE host_proc ARCH host_bits OS host_os ABI host_abi)
  get_Environment_Target_Platform(DISTRIBUTION target_distrib DISTRIB_VERSION target_distrib_version
                                 TYPE target_proc ARCH target_bits OS target_os ABI target_abi)

  if(target_proc)
    if(NOT host_proc STREQUAL target_proc)
      return()
    endif()
  endif()
  if(target_bits)
    if(NOT host_bits EQUAL target_bits)
      return()
    endif()
  endif()
  if(target_os)
    if(NOT host_os STREQUAL target_os)
      return()
    endif()
  endif()
  if(target_abi)
    if(NOT host_abi STREQUAL target_abi)
      return()
    endif()
  endif()
  if(target_distrib)
    if(NOT host_distrib STREQUAL target_distrib)
      return()
    endif()
    if(target_distrib_version)
      if(NOT host_distrib_version VERSION_EQUAL target_distrib_version)
        return()
      endif()
    endif()
  endif()

  set(${IT_MATCHES} TRUE PARENT_SCOPE)
endfunction(host_Match_Target_Platform)

#.rst:
#
# .. ifmode:: script
#
#  .. |get_Environment_Target_Platform| replace:: ``get_Environment_Target_Platform``
#  .. _get_Environment_Target_Platform:
#
#  get_Environment_Target_Platform
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Environment_Target_Platform()
#
#     Get information about target platform. The function returns constraints that apply to the target platform.
#
#     .. rubric:: Optional parameters
#
#     :DISTRIBUTION <var>: the ouput variable containing the name of the distribution.
#     :DISTRIB_VERSION <var>: the ouput variable containing the version of the distribution.
#     :TYPE <var>: the ouput variable containing the type of processor (x86, arm).
#     :ARCH <var>: the ouput variable containing the architecture for TYPE (16, 32 or 64).
#     :OS <var>: the ouput variable containing the operating system name (linux, macos).
#     :ABI <var>: the ouput variable containing the C++ ABI used (98 or 11).
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in script files of the environment.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#       get_Environment_Target_Platform(DISTRIBUTION distrib TYPE proc ARCH bits OS os)
#
function(get_Environment_Target_Platform)
  set(monoValueArgs DISTRIBUTION DISTRIB_VERSION TYPE ARCH OS ABI)
  cmake_parse_arguments(GET_ENV_TARGET_PLATFORM "" "${monoValueArgs}" "" ${ARGN})

  if(GET_ENV_TARGET_PLATFORM_DISTRIBUTION)
    if(PID_CROSSCOMPILATION OR ${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT) #constraint has been explicilty specified
      set(${GET_ENV_TARGET_PLATFORM_DISTRIBUTION} ${${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT} PARENT_SCOPE)
    else()#no constraint so same as host
      set(${GET_ENV_TARGET_PLATFORM_DISTRIBUTION} ${CURRENT_DISTRIBUTION} PARENT_SCOPE)
    endif()
  endif()
  if(GET_ENV_TARGET_PLATFORM_DISTRIB_VERSION)
    if(PID_CROSSCOMPILATION OR ${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT) #constraint has been explicilty specified
      set(${GET_ENV_TARGET_PLATFORM_DISTRIB_VERSION} ${${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT} PARENT_SCOPE)
    else()#no constraint so same as host
      set(${GET_ENV_TARGET_PLATFORM_DISTRIB_VERSION} ${CURRENT_DISTRIBUTION_VERSION} PARENT_SCOPE)
    endif()
  endif()

  if(GET_ENV_TARGET_PLATFORM_TYPE)
    if(PID_CROSSCOMPILATION OR ${PROJECT_NAME}_TYPE_CONSTRAINT) #constraint has been explicilty specified
      set(${GET_ENV_TARGET_PLATFORM_TYPE} ${${PROJECT_NAME}_TYPE_CONSTRAINT} PARENT_SCOPE)
    else()#no constraint so same as host
      set(${GET_ENV_TARGET_PLATFORM_TYPE} ${CURRENT_PLATFORM_TYPE} PARENT_SCOPE)
    endif()
  endif()
  if(GET_ENV_TARGET_PLATFORM_ARCH)
    if(PID_CROSSCOMPILATION OR ${PROJECT_NAME}_ARCH_CONSTRAINT) #constraint has been explicilty specified
      set(${GET_ENV_TARGET_PLATFORM_ARCH} ${${PROJECT_NAME}_ARCH_CONSTRAINT} PARENT_SCOPE)
    else()#no constraint so same as host
      set(${GET_ENV_TARGET_PLATFORM_ARCH} ${CURRENT_PLATFORM_ARCH} PARENT_SCOPE)
    endif()
  endif()
  if(GET_ENV_TARGET_PLATFORM_OS)
    if(PID_CROSSCOMPILATION OR ${PROJECT_NAME}_OS_CONSTRAINT) #constraint has been explicilty specified
      set(${GET_ENV_TARGET_PLATFORM_OS} ${${PROJECT_NAME}_OS_CONSTRAINT} PARENT_SCOPE)
    else()#no constraint so same as host
      set(${GET_ENV_TARGET_PLATFORM_OS} ${CURRENT_PLATFORM_OS} PARENT_SCOPE)
    endif()
  endif()
  if(GET_ENV_TARGET_PLATFORM_ABI)
    if(PID_CROSSCOMPILATION OR ${PROJECT_NAME}_ABI_CONSTRAINT)#constraint has been explicilty specified
      set(${GET_ENV_TARGET_PLATFORM_ABI} ${${PROJECT_NAME}_ABI_CONSTRAINT} PARENT_SCOPE)
    else()#no constraint so same as host
      set(${GET_ENV_TARGET_PLATFORM_ABI} ${CURRENT_CXX_ABI} PARENT_SCOPE)
    endif()
  endif()

endfunction(get_Environment_Target_Platform)

#.rst:
#
# .. ifmode:: script
#
#  .. |get_Environment_Host_Platform| replace:: ``get_Environment_Host_Platform``
#  .. _get_Environment_Host_Platform:
#
#  get_Environment_Host_Platform
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Environment_Host_Platform([OPTION var]...)
#
#     Get information about host platform. The function returns the current parameters of the host platform.
#
#     .. rubric:: Optional parameters
#
#     :DISTRIBUTION <var>: the ouput variable containing the name of the distribution.
#     :DISTRIB_VERSION <var>: the ouput variable containing the version of the distribution.
#     :TYPE <var>: the ouput variable containing the type of processor (x86, arm).
#     :ARCH <var>: the ouput variable containing the processor architecture for TYPE (16, 32 or 64).
#     :OS <var>: the ouput variable containing the operating system name (linux, macos).
#     :ABI <var>: the ouput variable containing the C++ ABI used (98 or 11).
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in script files of the environment.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#       get_Environment_Host_Platform(DISTRIBUTION distrib TYPE proc ARCH bits OS os)
#
function(get_Environment_Host_Platform)
  set(monoValueArgs DISTRIBUTION DISTRIB_VERSION TYPE ARCH OS ABI)
  cmake_parse_arguments(GET_ENV_HOST_PLATFORM "" "${monoValueArgs}" "" ${ARGN})

  if(GET_ENV_HOST_PLATFORM_DISTRIBUTION)
    set(${GET_ENV_HOST_PLATFORM_DISTRIBUTION} ${CURRENT_DISTRIBUTION} PARENT_SCOPE)
  endif()
  if(GET_ENV_HOST_PLATFORM_DISTRIB_VERSION)
    set(${GET_ENV_HOST_PLATFORM_DISTRIB_VERSION} ${CURRENT_DISTRIBUTION_VERSION} PARENT_SCOPE)
  endif()
  if(GET_ENV_HOST_PLATFORM_TYPE)
    set(${GET_ENV_HOST_PLATFORM_TYPE} ${CURRENT_PLATFORM_TYPE} PARENT_SCOPE)
  endif()
  if(GET_ENV_HOST_PLATFORM_ARCH)
    set(${GET_ENV_HOST_PLATFORM_ARCH} ${CURRENT_PLATFORM_ARCH} PARENT_SCOPE)
  endif()
  if(GET_ENV_HOST_PLATFORM_OS)
    set(${GET_ENV_HOST_PLATFORM_OS} ${CURRENT_PLATFORM_OS} PARENT_SCOPE)
  endif()
  if(GET_ENV_HOST_PLATFORM_ABI)
    set(${GET_ENV_HOST_PLATFORM_ABI} ${CURRENT_PLATFORM_ABI} PARENT_SCOPE)
  endif()

endfunction(get_Environment_Host_Platform)


#.rst:
#
# .. ifmode:: script
#
#  .. |get_Environment_Target_ABI_Flags| replace:: ``get_Environment_Target_ABI_Flags``
#  .. _get_Environment_Target_ABI_Flags:
#
#  get_Environment_Target_ABI_Flags
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Environment_Target_ABI_Flags(FLAGS target_abi)
#
#      Get C++ compiler flags to use the given ABI.
#
#     .. rubric:: Required parameters
#
#     :target_abi: the desired ABI to be used
#
#     :CFLAGS: the output variable that contains compile flags for using target abi
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        get_Environment_Target_ABI_Flags(CFLAGS "stdc++11")
#
function(get_Environment_Target_ABI_Flags CFLAGS target_abi)
  set(result_cflags)
  if(target_abi STREQUAL "stdc++11")#using new abi of stdc++
    set(result_cflags "-D_GLIBCXX_USE_CXX11_ABI=1")
  elseif(target_abi STREQUAL "stdc++")#use legacy abi of stdc++
    set(result_cflags "-D_GLIBCXX_USE_CXX11_ABI=0")
  endif()
  #no flags for other standard libraries
  set(${CFLAGS} ${result_cflags} PARENT_SCOPE)#by default no flag is required for standard libraries
endfunction(get_Environment_Target_ABI_Flags)

#.rst:
#
# .. ifmode:: script
#
#  .. |evaluate_Host_Platform| replace:: ``evaluate_Host_Platform``
#  .. _evaluate_Host_Platform:
#
#  evaluate_Host_Platform
#  ^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: evaluate_Host_Platform()
#
#      Evaluate again the host platform configuration. To be used after an update of the host (for instance after using apt-get install).
#
#     .. rubric:: Required parameters
#
#     :RESULT <var>: the output variable that is TRUE if host now matches constraints
#
#     .. admonition:: Effects
#        :class: important
#
#        Recompure all internal cache variables describing the host.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        evaluate_Host_Platform(EVAL_RES)
#        if(EVAL_RES)
#         # do something
#        endif()
#
macro(evaluate_Host_Platform RESULT)
detect_Current_Platform() #update host platform variables
set(${RESULT} TRUE)
if(${PROJECT_NAME}_CHECK)#there is a file for checking configuration of the host
  if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_CHECK})#addintionnal check is required to manage input constraints
    message(FATAL_ERROR "[PID] CRITICAL ERROR: the file ${${PROJECT_NAME}_CHECK} cannot be fund in src folder of ${PROJECT_NAME}")
    return()
  endif()
  #now check if host satisfies all properties of the target platform
  set(ENVIRONMENT_CHECK_RESULT TRUE CACHE INTERNAL "")
  include(${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_CHECK})
  if(NOT ENVIRONMENT_CHECK_RESULT)#host does matches all requirements, so trying to configure these requirements
    set(${RESULT} FALSE)
  endif()
endif()
#if no check it means that the environment does not impose any direct constraint !!
endmacro(evaluate_Host_Platform)


#.rst:
#
# .. ifmode:: script
#
#  .. |check_Program_Version| replace:: ``check_Program_Version``
#  .. _check_Program_Version:
#
#  check_Program_Version
#  ^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: check_Program_Version(RESULT version_var is_exact program_str version_extraction_regex)
#
#      Check whether a program matches version constraint.
#
#     .. rubric:: Required parameters
#
#     :RESULT: the output variable that contains the version of program if it matches version constraint, or TRUE if program has no version. Otherwise returns FALSE.
#     :version_var: the input variable containing version constraint
#     :is_exact: TRUE if version must exactly match
#     :program_str: the expression executed to get program version
#     :version_extraction_regex: the regular expression used to get versioninfo from program output
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        check_Program_Version(EVAL_RES gcc_version "${gcc_exact}" "gcc -v" "^gcc[ \t]+version[ \t]+([^ \t]+)[ \t]+.*$")
#        if(EVAL_RES)
#         # do something
#        endif()
#
function(check_Program_Version RESULT version_var is_exact program_str version_extraction_regex)
  set(${RESULT} FALSE PARENT_SCOPE)
  get_Program_Version(VERSION_RES "${program_str}" "${version_extraction_regex}")
  if(${version_var})#a version constraint has been specified
    if(NOT VERSION_RES)#cannot find version
      return()
    endif()
    check_Environment_Version(RES ${version_var} "${is_exact}" "${VERSION_RES}")
    if(NOT RES)#cannot find version
      return()
    endif()
	endif()
  #if no constraint specified simply return the version value
  if(NOT VERSION_RES)#program has no version AND no constraint specified
    set(${RESULT} TRUE PARENT_SCOPE)
    return()
  endif()
  set(${RESULT} ${VERSION_RES} PARENT_SCOPE)
endfunction(check_Program_Version)

#.rst:
#
# .. ifmode:: script
#
#  .. |extract_Version_Numbers| replace:: ``extract_Version_Numbers``
#  .. _extract_Version_Numbers:
#
#  extract_Version_Numbers
#  ^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: extract_Version_Numbers(MAJOR MINOR PATCH version)
#
#      extract numbers from a version string
#
#     .. rubric:: Required parameters
#
#     :MAJOR: the output variable that contains the major number of version.
#     :MINOR: the output variable that contains the minor number of version.
#     :PATCH: the output variable that contains the patch number of version.
#     :version: the full version string
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        extract_Version_Numbers(MAJOR MINOR PATCH 1.2.3)
#        message("major number is ${MAJOR}")
#
function(extract_Version_Numbers MAJOR MINOR PATCH version)
  get_Version_String_Numbers("${version}" extract_major extract_minor extract_patch)
  set(${MAJOR} ${extract_major} PARENT_SCOPE)
  set(${MINOR} ${extract_minor} PARENT_SCOPE)
  set(${PATCH} ${extract_patch} PARENT_SCOPE)
endfunction(extract_Version_Numbers)

#.rst:
#
# .. ifmode:: script
#
#  .. |check_Environment_Version| replace:: ``check_Environment_Version``
#  .. _check_Environment_Version:
#
#  check_Environment_Version
#  ^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: check_Environment_Version(RESULT version_var is_exact version_to_check)
#
#      Check whether a version of thenvironment matches a version constraint.
#
#     .. rubric:: Required parameters
#
#     :RESULT: the output variable that is TRUE if program matches version constraint
#     :version_var: the input variable containing version constraint
#     :is_exact: TRUE if version must exactly match
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        check_Program_Version(EVAL_RES gcc_version "${gcc_exact}" "gcc -v" "^gcc[ \t]+version[ \t]+([^ \t]+)[ \t]+.*$")
#        if(EVAL_RES)
#         # do something
#        endif()
#
function(check_Environment_Version RESULT version_var is_exact version_to_check)
  if(${version_var})#a version constraint has been specified
    set(${RESULT} FALSE PARENT_SCOPE)
    if(is_exact)
      if(NOT version_to_check VERSION_EQUAL ${version_var})
        return()
      endif()
    else()
      if(version_to_check VERSION_LESS ${version_var})
        return()
      endif()
    endif()
  endif()
  set(${RESULT} TRUE PARENT_SCOPE)
endfunction(check_Environment_Version)

#.rst:
#
# .. ifmode:: script
#
#  .. |get_Program_Version| replace:: ``get_Program_Version``
#  .. _get_Program_Version:
#
#  get_Program_Version
#  ^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Program_Version(VERSION program_str version_extraction_regex)
#
#      Get the version of a given program.
#
#     .. rubric:: Required parameters
#
#     :VERSION: the output variable that is TRUE if host now matches constraints
#     :program_str: the expression executed to get program version
#     :version_extraction_regex: the regular expression used to get versioninfo from program output
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        get_Program_Version(VERSION_RES "gcc -v" "^gcc[ \t]+version[ \t]+([^ \t]+)[ \t]+.*$")
#        if(VERSION_RES)
#         # do something
#        endif()
#
function(get_Program_Version VERSION program_str version_extraction_regex)
  set(${VERSION} PARENT_SCOPE)

  string(REPLACE " " ";" program_cmd "${program_str}")
  execute_process(COMMAND ${program_cmd} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                  OUTPUT_VARIABLE program_specs ERROR_VARIABLE program_errors)


  if(NOT program_specs AND program_errors)
    set(program_specs ${program_errors})#using error output is sometimes necessary as it may contain the ouput of the command
  endif()
  set(version)
  string(REPLACE "\n" ";" LIST_OF_LINES "${program_specs}")
  foreach (line IN LISTS LIST_OF_LINES)
    if(line MATCHES "${version_extraction_regex}")
      set(version ${CMAKE_MATCH_1})
      break()
    endif()
  endforeach()
  if(version)
    set(${VERSION} ${version} PARENT_SCOPE)
  endif()
endfunction(get_Program_Version)

#.rst:
#
# .. ifmode:: script
#
#  .. |check_Environment_Architecture| replace:: ``check_Environment_Architecture``
#  .. _check_Environment_Architecture:
#
#  check_Environment_Architecture
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: check_Environment_Architecture(RESULT arch_var arch_list)
#
#      Check whether a set of architectures is allowed.
#
#     .. rubric:: Required parameters
#
#     :RESULT: the output variable that is TRUE if architecture(s) are all managed managed
#     :arch_var: the input variable containing architecture(s) to check
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        check_Environment_Architecture(EVAL_RES cuda_architecture "6.1;7.1")
#        if(EVAL_RES)
#         # do something
#        endif()
#
function(check_Environment_Architecture RESULT arch_var arch_list)
  if(${arch_var})#a version constraint has been specified
    set(${RESULT} FALSE PARENT_SCOPE)
    foreach(arch IN LISTS arch_list)
      list(FIND arch_var "${arch_list}" INDEX)
      if(INDEX EQUAL -1)#not found in available arch list
        return()
      endif()
    endforeach()
  endif()
  set(${RESULT} TRUE PARENT_SCOPE)
endfunction(check_Environment_Architecture)

#.rst:
#
# .. ifmode:: script
#
#  .. |set_Environment_Constraints| replace:: ``set_Environment_Constraints``
#  .. _set_Environment_Constraints:
#
#  set_Environment_Constraints
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: set_Environment_Constraints(VARIABLES ... VALUES ...)
#
#      Set the value of a variable used as a constraint for the environment.
#
#     .. rubric:: Required parameters
#
#     :VARIABLES ...: the list of variables whose values are set
#     :VALUES ...: the list of values corresponding to teh variables (same ordering).
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        set_Environment_Constraints(VARIABLES version VALUES 3.25.2)
#
function(set_Environment_Constraints)
  set(multiValueArgs VARIABLES VALUES)
  cmake_parse_arguments(SET_ENV_CONST "" "" "${multiValueArgs}" ${ARGN})

  if(NOT SET_ENV_CONST_VARIABLES)
    message("[PID] ERROR: when using set_Environment_Constraints target variables must be specified using VARIABLES")
    return()
  elseif(NOT SET_ENV_CONST_VALUES)
    message("[PID] ERROR: when using set_Environment_Constraints target variables values must be specified using VALUES arguments.")
    return()
  endif()
  list(LENGTH SET_ENV_CONST_VARIABLES SIZE_VARS)
  list(LENGTH SET_ENV_CONST_VALUES SIZE_VALS)
  if(NOT SIZE_VARS EQUAL SIZE_VALS)
    message(FATAL_ERROR "[PID] CRITICAL ERROR: Bad usage of function set_Environment_Constraints, you must give the a value for each variable defined using VARIABLES keyword. ")
    return()
  else()
    foreach(var IN LISTS SET_ENV_CONST_VARIABLES)
      list(FIND SET_ENV_CONST_VARIABLES ${var} INDEX)
      list(GET SET_ENV_CONST_VALUES ${INDEX} CORRESPONDING_VAL)
      set(${PROJECT_NAME}_${var} ${CORRESPONDING_VAL} PARENT_SCOPE)#the value of the variable is not the real value but the name of the variable
    endforeach()
  endif()
endfunction(set_Environment_Constraints)

#.rst:
#
# .. ifmode:: script
#
#  .. |install_System_Packages| replace:: ``install_System_Packages``
#  .. _install_System_Packages:
#
#  install_System_Packages
#  ^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: install_System_Packages(RESULT ...)
#
#      Install packages for various packaging systems (depends on host distribution)
#
#     .. rubric:: Required parameters
#
#     :APT|PACMAN|YUM|BREW|PORTS|CHOCO ... : the list of package to install for a given packager. Many packages can be defined.
#
#     .. rubric:: Required parameters
#
#     :RESULT var: the output variable that is TRUE if somes packages have been installed, FALSE otherwise.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        install_System_Packages(APT gcc-9 PACMAN gcc-9)
#
function(install_System_Packages)
  set(use_packages)
  cmake_parse_arguments(INSTALL_SYSTEM_PACKAGES "" "RESULT" "${PID_KNOWN_PACKAGING_SYSTEMS}" ${ARGN})#use known packagers names as multi value arguments
  if(INSTALL_SYSTEM_PACKAGES_RESULT)
    set(${INSTALL_SYSTEM_PACKAGES_RESULT} FALSE PARENT_SCOPE)
  endif()
  foreach(packager IN LISTS PID_KNOWN_PACKAGING_SYSTEMS)
    if( INSTALL_SYSTEM_PACKAGES_${packager}
        AND packager STREQUAL CURRENT_PACKAGING_SYSTEM)#OK there is a packager specified for the one used in current platform
      set(use_packages ${INSTALL_SYSTEM_PACKAGES_${packager}})
      break()
    endif()
  endforeach()
  if(NOT use_packages)
    return()
  endif()
  # Note: install packages one by one to avoid install procedure to be broken by a non existing system package
  # that provokes an exit of the install command
  # this allows to define many variant names for the install of a unique package
  # This is mandatory to easily adapt to all variations introduced by various distributions
  foreach(pack IN LISTS use_packages)
    if(ADDITIONAL_DEBUG_INFO)
      message("[PID] INFO : ${PROJECT_NAME} is trying to install system package ${pack}...")
    endif()
    execute_System_Packaging_Command(${pack})
  endforeach()
  if(INSTALL_SYSTEM_PACKAGES_RESULT)
    set(${INSTALL_SYSTEM_PACKAGES_RESULT} TRUE PARENT_SCOPE)
  endif()
endfunction(install_System_Packages)
