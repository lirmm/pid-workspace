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

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)

include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Environment_API_Internal_Functions NO_POLICY_SCOPE)

include(CMakeParseArguments)

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
#     :MAIL <e-mail>: E-mail of the reference author.
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
set(oneValueArgs LICENSE ADDRESS MAIL PUBLIC_ADDRESS)
set(multiValueArgs AUTHOR INSTITUTION YEAR DESCRIPTION)
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

declare_Environment("${DECLARE_PID_ENV_AUTHOR}" "${DECLARE_PID_ENV_INSTITUTION}" "${DECLARE_PID_ENV_MAIL}" "${DECLARE_PID_ENV_YEAR}" "${DECLARE_PID_ENV_LICENSE}" "${DECLARE_PID_ENV_ADDRESS}" "${DECLARE_PID_ENV_PUBLIC_ADDRESS}" "${DECLARE_PID_ENV_DESCRIPTION}")
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
#     :PLATFORM <platform>: defines a complete specification of the target platform (e.g. x86_64_linux_abi11).
#     :TYPE <proc>: the type of architecture for processor of the platform (e.g. x86).
#     :ARCH <bits>: the size of processor architecture registry, 16, 32 or 64.
#     :OS <kernel>: the OS kernel of the platform (e.g. linux).
#     :ABI <abi>: the default c++ ABI used by the platform, 98 or 11.
#     :DISTRIBUTION <distrib name>: the name of the distribution of the target platform.
#     :DISTRIB_VERSION <version>: the version of the distribution of the target platform.
#     :CONFIGURATION ...: list of target platform configuration that the host must match
#     :CHECK ...: the path to the script file defining how to check if current host already defines aequate build variables.
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
#           PLATFORM x86_64_linux_abi11
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
set(oneValueArgs CHECK PLATFORM ARCH TYPE OS ABI DISTRIBUTION DISTRIB_VERSION)
set(multiValueArgs CONFIGURATION)
cmake_parse_arguments(DECLARE_PID_ENV_PLATFORM "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

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

define_Build_Environment_Platform("${type_constraint}" "${arch_constraint}" "${os_constraint}" "${abi_constraint}" "${DECLARE_PID_ENV_PLATFORM_DISTRIBUTION}" "${DECLARE_PID_ENV_PLATFORM_DISTRIB_VERSION}" "${DECLARE_PID_ENV_PLATFORM_CONFIGURATION}" "${DECLARE_PID_ENV_PLATFORM_CHECK}")

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
#   .. command:: PID_Environment_Constraints(OPTIONAL ... REQUIRED ...)
#
#   .. command:: declare_PID_Environment_Constraints(OPTIONAL ... REQUIRED ...)
#
#     Declare a set of optional and/or required constraints for the configuration. These constraints are used to provide parameters to environment scripts.
#
#     .. rubric:: Optional parameters
#
#     :REQUIRED ...: the list of constraints whose value must be set before calling it.
#     :OPTIONAL ...: the list of constraints whose value can be set or not before calling it.
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
  set(multiValueArgs OPTIONAL REQUIRED)
  cmake_parse_arguments(DECLARE_PID_ENV_CONSTRAINTS "" "" "${multiValueArgs}" ${ARGN})

  if(NOT DECLARE_PID_ENV_CONSTRAINTS_OPTIONAL AND NOT DECLARE_PID_ENV_CONSTRAINTS_REQUIRED)
    message("[PID] WARNING: when calling declare_PID_Environment_Constraints you defined no optional or required contraints. Aborting.")
    return()
  endif()

  define_Environment_Constraints("${DECLARE_PID_ENV_CONSTRAINTS_OPTIONAL}" "${DECLARE_PID_ENV_CONSTRAINTS_REQUIRED}")
endmacro(declare_PID_Environment_Constraints)

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
#   .. command:: PID_Environment_Solution([CONFIGURE ...] [DEPENDENCIES ...] [FILTERS])
#
#   .. command:: declare_PID_Environment_Solution(CONFIGURE ...  [DEPENDENCIES ...][FILTERS])
#
#     Define a solution to configure the environment for the current host platform.
#
#     .. rubric:: Optional parameters
#
#     :CONFIGURE ...: the path to the script file defining how to configure the build tools used by the environment.
#     :DEPENDENCIES ...: The list of environment that current environment project depends on. Each environment expression can (or must in case of required constraints) embbed constraint value definition.
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
  set(monoValueArgs CONFIGURE DISTRIBUTION DISTRIB_VERSION PLATFORM ARCH TYPE OS ABI)
  set(multiValueArgs DEPENDENCIES)
  cmake_parse_arguments(DECLARE_PID_ENV_SOLUTION "" "${monoValueArgs}" "${multiValueArgs}" ${ARGN})

  if(DECLARE_PID_ENV_SOLUTION_PLATFORM)# a complete platform is specified
    if(DECLARE_PID_ENV_SOLUTION_ARCH
      OR DECLARE_PID_ENV_SOLUTION_TYPE
      OR DECLARE_PID_ENV_SOLUTION_OS
      OR DECLARE_PID_ENV_SOLUTION_ABI)
      message("[PID] WARNING : when calling PID_Environment_Solution you define a complete target platform using PLATFORM, so TYPE, ARCH, OS and ABI arguments will not be interpreted.")
    endif()
    extract_Info_From_Platform(type_constraint arch_constraint os_constraint abi_constraint RES_INSTANCE RES_PLATFORM_BASE ${DECLARE_PID_ENV_SOLUTION_PLATFORM})
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

  if(DECLARE_PID_ENV_SOLUTION_DISTRIB_VERSION)
    if(NOT DECLARE_PID_ENV_SOLUTION_DISTRIBUTION)
      message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling PID_Environment_Install you define distribution version (using DISTRIB_VERSION) but no DISTRIBUTION. Please specify the DISTRIBUTION also.")
      return()
    endif()
  endif()

  define_Environment_Solution_Procedure("${type_constraint}" "${arch_constraint}" "${os_constraint}" "${abi_constraint}"
                                       "${DECLARE_PID_ENV_SOLUTION_DISTRIBUTION}" "${DECLARE_PID_ENV_SOLUTION_DISTRIB_VERSION}"
                                       "${DECLARE_PID_ENV_SOLUTION_CONFIGURE}" "${DECLARE_PID_ENV_SOLUTION_DEPENDENCIES}")
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
  if(${ARGC} GREATER 0)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the build_PID_Environment command requires no arguments.")
  	return()
  endif()
  build_Environment_Project()
endmacro(build_PID_Environment)

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
#   .. command:: configure_Environment_Tool(LANGUAGE ... [COMPILER...] [AR...] [RANLIB...] [FLAGS...])
#
#   .. command:: configure_Environment_Tool(SYSTEM [GENERATOR...] [LINKER ...] [[EXE|MODULE|STATIC|SHARED] FLAGS...])
#
#     Configure the tools used for the current environment. Support different signatures.
#
#     .. rubric:: Required parameters
#
#     :LANGUAGE lang: the language that is being configured (C, CXX, ASM, Fortran, CUDA).
#     :SYSTEM: tells that system wide (as opposed to language wide) variables are configured.
#
#     .. rubric:: Optional parameters
#
#     :COMPILER ...: the path to the compiler in use.
#     :AR ...: the path to the archive tool in use.
#     :RANLIB ...: .
#     :FLAGS ...: set of compiler flags (if used with LANGUAGE) or linker flags (if used with SYSTEM) to use.
#     :LINKER ...: the path to the linker in use.
#     :GENERATOR ...: the name of the generator in use.
#     :EXE|MODULE|STATIC|SHARED: filters for selecting adequate type of binaries for which to apply link flags.
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
function(configure_Environment_Tool)
  set(options SYSTEM EXE MODULE STATIC SHARED)

  set(monoValueArgs SYSROOT STAGING LANGUAGE COMPILER TOOLCHAIN_ID INTERPRETER NM OBJDUMP OBJCOPY LIBRARY AR RANLIB LINKER GENERATOR GEN_EXTRA GEN_TOOLSET GEN_PLATFORM GEN_INSTANCE)
  set(multiValueArgs FLAGS PROGRAM_DIRS LIBRARY_DIRS INCLUDE_DIRS)
  cmake_parse_arguments(CONF_ENV_TOOL "${options}" "${monoValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT CONF_ENV_TOOL_LANGUAGE AND NOT CONF_ENV_TOOL_SYSTEM)
    message(FATAL_ERROR "[PID] CRITICAL ERROR: when calling configure_Environment_Tool, you must use LANGUAGE or SYSTEM arguments.")
    return()
  elseif(CONF_ENV_TOOL_LANGUAGE AND CONF_ENV_TOOL_SYSTEM)
    message(FATAL_ERROR "[PID] CRITICAL ERROR: when calling configure_Environment_Tool, you must use LANGUAGE or SYSTEM arguments but not both.")
    return()
  endif()
  if(CONF_ENV_TOOL_LANGUAGE)
    if(CONF_ENV_TOOL_COMPILER)
      set(${PROJECT_NAME}_${CONF_ENV_TOOL_LANGUAGE}_COMPILER ${CONF_ENV_TOOL_COMPILER} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_TOOLCHAIN_ID)
      set(${PROJECT_NAME}_${CONF_ENV_TOOL_LANGUAGE}_COMPILER_ID ${CONF_ENV_TOOL_TOOLCHAIN_ID} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_AR)
      set(${PROJECT_NAME}_${CONF_ENV_TOOL_LANGUAGE}_AR ${CONF_ENV_TOOL_AR} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_RANLIB)
      set(${PROJECT_NAME}_${CONF_ENV_TOOL_LANGUAGE}_RANLIB ${CONF_ENV_TOOL_RANLIB} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_FLAGS)
      append_Unique_In_Cache(${PROJECT_NAME}_${CONF_ENV_TOOL_LANGUAGE}_COMPILER_FLAGS "${CONF_ENV_TOOL_FLAGS}")
    endif()
    if(CONF_ENV_TOOL_INTERPRETER)
      set(${PROJECT_NAME}_${CONF_ENV_TOOL_LANGUAGE}_INTERPRETER ${CONF_ENV_TOOL_INTERPRETER} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_INCLUDE_DIRS)
      append_Unique_In_Cache(${PROJECT_NAME}_${CONF_ENV_TOOL_LANGUAGE}_INCLUDE_DIRS "${CONF_ENV_TOOL_INCLUDE_DIRS}")
    endif()
    if(CONF_ENV_TOOL_LIBRARY)
      set(${PROJECT_NAME}_${CONF_ENV_TOOL_LANGUAGE}_LIBRARY ${CONF_ENV_TOOL_LIBRARY} CACHE INTERNAL "")
    endif()

  elseif(CONF_ENV_TOOL_SYSTEM)

    #manage generator
    if(CONF_ENV_TOOL_GENERATOR)
      set(${PROJECT_NAME}_GENERATOR ${CONF_ENV_TOOL_GENERATOR} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_GEN_EXTRA)
      set(${PROJECT_NAME}_GENERATOR_EXTRA ${CONF_ENV_TOOL_GEN_EXTRA} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_GEN_TOOLSET)
      set(${PROJECT_NAME}_GENERATOR_TOOLSET ${CONF_ENV_TOOL_GEN_TOOLSET} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_GEN_PLATFORM)
      set(${PROJECT_NAME}_GENERATOR_PLATFORM ${CONF_ENV_TOOL_GEN_PLATFORM} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_GEN_INSTANCE)
      set(${PROJECT_NAME}_GENERATOR_INSTANCE ${CONF_ENV_TOOL_GEN_INSTANCE} CACHE INTERNAL "")
    endif()

    #manage crosscompilation
    if(CONF_ENV_TOOL_SYSROOT)#warning overwritting previosu value if any forced
      set(${PROJECT_NAME}_TARGET_SYSROOT ${CONF_ENV_TOOL_SYSROOT} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_STAGING)#warning overwritting previosu value if any forced
      set(${PROJECT_NAME}_TARGET_STAGING ${CONF_ENV_TOOL_STAGING} CACHE INTERNAL "")
    endif()

      #manage linker in use
    if(CONF_ENV_TOOL_LINKER)
      set(${PROJECT_NAME}_LINKER ${CONF_ENV_TOOL_LINKER} CACHE INTERNAL "")
    endif()

    #manage binary inspection/modification tools
    if(CONF_ENV_TOOL_AR)
      set(${PROJECT_NAME}_AR ${CONF_ENV_TOOL_AR} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_RANLIB)
      set(${PROJECT_NAME}_RANLIB ${CONF_ENV_TOOL_RANLIB} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_NM)
      set(${PROJECT_NAME}_NM ${CONF_ENV_TOOL_NM} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_OBJDUMP)
      set(${PROJECT_NAME}_OBJDUMP ${CONF_ENV_TOOL_OBJDUMP} CACHE INTERNAL "")
    endif()
    if(CONF_ENV_TOOL_OBJCOPY)
      set(${PROJECT_NAME}_OBJCOPY ${CONF_ENV_TOOL_OBJCOPY} CACHE INTERNAL "")
    endif()

    #manage default system path
    if(CONF_ENV_TOOL_INCLUDE_DIRS)
      append_Unique_In_Cache(${PROJECT_NAME}_INCLUDE_DIRS "${CONF_ENV_TOOL_INCLUDE_DIRS}")
    endif()
    if(CONF_ENV_TOOL_LIBRARY_DIRS)
      append_Unique_In_Cache(${PROJECT_NAME}_LIBRARY_DIRS "${CONF_ENV_TOOL_LIBRARY_DIRS}")
    endif()
    if(CONF_ENV_TOOL_PROGRAM_DIRS)
      append_Unique_In_Cache(${PROJECT_NAME}_PROGRAM_DIRS "${CONF_ENV_TOOL_PROGRAM_DIRS}")
    endif()

    if(CONF_ENV_TOOL_FLAGS)
      #checking filters for flags
      set(filter_found FALSE)
      if(CONF_ENV_TOOL_EXE)
        set(filter_found TRUE)
        append_Unique_In_Cache(${PROJECT_NAME}_EXE_LINKER_FLAGS "${CONF_ENV_TOOL_FLAGS}")
      endif()
      if(CONF_ENV_TOOL_MODULE)
        set(filter_found TRUE)
        append_Unique_In_Cache(${PROJECT_NAME}_MODULE_LINKER_FLAGS "${CONF_ENV_TOOL_FLAGS}")
      endif()
      if(CONF_ENV_TOOL_STATIC)
        set(filter_found TRUE)
        append_Unique_In_Cache(${PROJECT_NAME}_STATIC_LINKER_FLAGS "${CONF_ENV_TOOL_FLAGS}")
      endif()
      if(CONF_ENV_TOOL_SHARED)
        set(filter_found TRUE)
        append_Unique_In_Cache(${PROJECT_NAME}_SHARED_LINKER_FLAGS "${CONF_ENV_TOOL_FLAGS}")
      endif()
      if(NOT filter_found)#apply flags to all types
        append_Unique_In_Cache(${PROJECT_NAME}_EXE_LINKER_FLAGS "${CONF_ENV_TOOL_FLAGS}")
        append_Unique_In_Cache(${PROJECT_NAME}_MODULE_LINKER_FLAGS "${CONF_ENV_TOOL_FLAGS}")
        append_Unique_In_Cache(${PROJECT_NAME}_SHARED_LINKER_FLAGS "${CONF_ENV_TOOL_FLAGS}")
        append_Unique_In_Cache(${PROJECT_NAME}_STATIC_LINKER_FLAGS "${CONF_ENV_TOOL_FLAGS}")
      endif()
    endif()
  endif()
endfunction(configure_Environment_Tool)

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
#       Sets the check process result.
#
#     .. rubric:: Required parameters
#
#     :value: return value of the scrit : TRUE if check OK and FALSE otherwise.
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
#     :OS <var>: the ouput variable containing the operating system name (linux, macosx).
#     :ABI <var>: the ouput variable containing the C++ ABI used (98 or 11).
#     :CONFIGURATION <var>: the ouput variable containing the list of configurations of the platform.
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
  set(multiValueArgs CONFIGURATION)
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
      set(${GET_ENV_TARGET_PLATFORM_TYPE} ${CURRENT_TYPE} PARENT_SCOPE)
    endif()
  endif()
  if(GET_ENV_TARGET_PLATFORM_ARCH)
    if(PID_CROSSCOMPILATION OR ${PROJECT_NAME}_ARCH_CONSTRAINT) #constraint has been explicilty specified
      set(${GET_ENV_TARGET_PLATFORM_ARCH} ${${PROJECT_NAME}_ARCH_CONSTRAINT} PARENT_SCOPE)
    else()#no constraint so same as host
      set(${GET_ENV_TARGET_PLATFORM_ARCH} ${CURRENT_ARCH} PARENT_SCOPE)
    endif()
  endif()
  if(GET_ENV_TARGET_PLATFORM_OS)
    if(PID_CROSSCOMPILATION OR ${PROJECT_NAME}_OS_CONSTRAINT) #constraint has been explicilty specified
      set(${GET_ENV_TARGET_PLATFORM_OS} ${${PROJECT_NAME}_OS_CONSTRAINT} PARENT_SCOPE)
    else()#no constraint so same as host
      set(${GET_ENV_TARGET_PLATFORM_OS} ${CURRENT_OS} PARENT_SCOPE)
    endif()
  endif()
  if(GET_ENV_TARGET_PLATFORM_ABI)
    if(PID_CROSSCOMPILATION OR ${PROJECT_NAME}_ABI_CONSTRAINT)#constraint has been explicilty specified
      set(${GET_ENV_TARGET_PLATFORM_ABI} ${${PROJECT_NAME}_ABI_CONSTRAINT} PARENT_SCOPE)
    else()#no constraint so same as host
      set(${GET_ENV_TARGET_PLATFORM_ABI} ${CURRENT_ABI} PARENT_SCOPE)
    endif()
  endif()
  if(GET_ENV_TARGET_PLATFORM_CONFIGURATION)
    set(${GET_ENV_TARGET_PLATFORM_CONFIGURATION} ${${PROJECT_NAME}_CONFIGURATION_CONSTRAINT} PARENT_SCOPE)
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
#     :OS <var>: the ouput variable containing the operating system name (linux, macosx).
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
    set(${GET_ENV_HOST_PLATFORM_TYPE} ${CURRENT_TYPE} PARENT_SCOPE)
  endif()
  if(GET_ENV_HOST_PLATFORM_ARCH)
    set(${GET_ENV_HOST_PLATFORM_ARCH} ${CURRENT_ARCH} PARENT_SCOPE)
  endif()
  if(GET_ENV_HOST_PLATFORM_OS)
    set(${GET_ENV_HOST_PLATFORM_OS} ${CURRENT_OS} PARENT_SCOPE)
  endif()
  if(GET_ENV_HOST_PLATFORM_ABI)
    set(${GET_ENV_HOST_PLATFORM_ABI} ${CURRENT_ABI} PARENT_SCOPE)
  endif()

endfunction(get_Environment_Host_Platform)

#.rst:
#
# .. ifmode:: script
#
#  .. |execute_OS_Command| replace:: ``execute_OS_Command``
#  .. _execute_OS_Command:
#
#  execute_OS_Command
#  ^^^^^^^^^^^^^^^^^^
#
#   .. command:: execute_OS_Command(...)
#
#      invoque a command of the operating system with adequate privileges.
#
#     .. rubric:: Required parameters
#
#     :...: the commands to be passed (do not use sudo !)
#
#     .. admonition:: Effects
#        :class: important
#
#        Execute the command with adequate privileges .
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        execute_OS_Command(apt-get install -y libgtk2.0-dev libgtkmm-2.4-dev)
#
macro(execute_OS_Command)
if(IN_CI_PROCESS)
  execute_process(COMMAND ${ARGN})
else()
  execute_process(COMMAND sudo ${ARGN})#need to have super user privileges except in CI where suding sudi is forbidden
endif()
endmacro(execute_OS_Command)


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
#     :FLAGS: the output variable that contains compile flags for using target abi
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        get_Environment_Target_ABI_Flags(FLAGS "CXX11")
#
function(get_Environment_Target_ABI_Flags FLAGS target_abi)
  if(target_abi STREQUAL "CXX11" OR target_abi EQUAL 11 OR target_abi STREQUAL "abi11")
    set(${FLAGS} "-D_GLIBCXX_USE_CXX11_ABI=1" PARENT_SCOPE)
  else()#use legacy abi
    set(${FLAGS} "-D_GLIBCXX_USE_CXX11_ABI=0" PARENT_SCOPE)
  endif()
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
#     :RESULT <var>: the output variable that is TRUE if host now matches
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
#        evaluate_Host_Platform()
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
