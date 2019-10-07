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
if(PID_PLATFORM_MANAGEMENT_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_PLATFORM_MANAGEMENT_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |detect_Current_Platform| replace:: ``detect_Current_Platform``
#  .. detect_Current_Platform:
#
#  detect_Current_Platform
#  -----------------------
#
#   .. command:: detect_Current_Platform()
#
#     Puts into cmake variables the description of current platform, deduced from current environment.
#
macro(detect_Current_Platform)
	# Now detect the current platform maccording to host environemnt selection (call to script for platform detection)
	include(CheckTYPE)
	include(CheckARCH)
	include(CheckOS)
	include(CheckABI)
	include(CheckPython)
	include(CheckFortran)
	include(CheckCUDA)
	if(NOT CURRENT_DISTRIBUTION)
		set(WORKSPACE_CONFIGURATION_DESCRIPTION " + processor family = ${CURRENT_TYPE}\n + binary architecture= ${CURRENT_ARCH}\n + operating system=${CURRENT_OS}\n + compiler ABI= ${CURRENT_ABI}")
	else()
		if(NOT CURRENT_DISTRIBUTION_VERSION)
			set(WORKSPACE_CONFIGURATION_DESCRIPTION " + processor family= ${CURRENT_TYPE}\n + binary architecture= ${CURRENT_ARCH}\n + operating system=${CURRENT_OS} (${CURRENT_DISTRIBUTION})\n + compiler ABI= ${CURRENT_ABI}")
		else()#there is a version number bound to the distribution
			set(WORKSPACE_CONFIGURATION_DESCRIPTION " + processor family= ${CURRENT_TYPE}\n + binary architecture= ${CURRENT_ARCH}\n + operating system=${CURRENT_OS} (${CURRENT_DISTRIBUTION} ${CURRENT_DISTRIBUTION_VERSION})\n + compiler ABI= ${CURRENT_ABI}")
		endif()
	endif()
	#simply rewriting previously defined variable to normalize their names between workspace and packages (same accessor function can then be used from any place)
	set(CURRENT_PACKAGE_STRING ${CURRENT_PACKAGE_STRING} CACHE INTERNAL "" FORCE)
	set(CURRENT_DISTRIBUTION ${CURRENT_DISTRIBUTION} CACHE INTERNAL "" FORCE)
	set(CURRENT_PLATFORM_TYPE ${CURRENT_TYPE} CACHE INTERNAL "" FORCE)
	set(CURRENT_PLATFORM_ARCH ${CURRENT_ARCH} CACHE INTERNAL "" FORCE)
	set(CURRENT_PLATFORM_OS ${CURRENT_OS} CACHE INTERNAL "" FORCE)
	if(CURRENT_ABI STREQUAL CXX11)
		set(CURRENT_PLATFORM_ABI abi11 CACHE INTERNAL "" FORCE)
	else()
		set(CURRENT_PLATFORM_ABI abi98 CACHE INTERNAL "" FORCE)
	endif()

	if(CURRENT_PLATFORM_OS)#the OS is optional (for microcontrolers there is no OS)
		set(CURRENT_PLATFORM ${CURRENT_PLATFORM_TYPE}_${CURRENT_PLATFORM_ARCH}_${CURRENT_PLATFORM_OS}_${CURRENT_PLATFORM_ABI} CACHE INTERNAL "" FORCE)
	else()
		set(CURRENT_PLATFORM ${CURRENT_PLATFORM_TYPE}_${CURRENT_PLATFORM_ARCH}_${CURRENT_PLATFORM_ABI} CACHE INTERNAL "" FORCE)
	endif()

	set(EXTERNAL_PACKAGE_BINARY_INSTALL_DIR ${CMAKE_SOURCE_DIR}/external/${CURRENT_PLATFORM} CACHE INTERNAL "")
	set(PACKAGE_BINARY_INSTALL_DIR ${CMAKE_SOURCE_DIR}/install/${CURRENT_PLATFORM} CACHE INTERNAL "")
	message("[PID] INFO : Target platform in use is ${CURRENT_PLATFORM}:\n${WORKSPACE_CONFIGURATION_DESCRIPTION}\n")

	if(Python_Language_AVAILABLE)
		message("[PID] INFO : Python may be used, target python version in use is ${CURRENT_PYTHON}. To use python modules installed in workspace please set the PYTHONPATH to =${WORKSPACE_DIR}/install/python${CURRENT_PYTHON}\n")
	endif()
	if(CUDA_Language_AVAILABLE)
		message("[PID] INFO : CUDA language (version ${CUDA_VERSION}) may be used.")
	endif()
	if(Fortran_Language_AVAILABLE)
		message("[PID] INFO : Fortran language may be used.")
	endif()
endmacro(detect_Current_Platform)

#############################################################################################
############### API functions for managing platform description variables ###################
#############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Current_Platform| replace:: ``manage_Current_Platform``
#  .. _manage_Current_Platform:
#
#  manage_Current_Platform
#  ------------------------
#
#   .. command:: manage_Current_Platform(build_folder)
#
#    If the platform description has changed then clean and launch the reconfiguration of the package.
#
#     :build_folder: the path to the package build_folder.
#
macro(manage_Current_Platform build_folder)
	if(build_folder STREQUAL build)
		if(CURRENT_PLATFORM)# a current platform is already defined
			#if any of the following variable changed, the cache of the CMake project needs to be regenerated from scratch
			set(TEMP_PLATFORM ${CURRENT_PLATFORM})
			set(TEMP_C_COMPILER ${CMAKE_C_COMPILER})
			set(TEMP_CXX_COMPILER ${CMAKE_CXX_COMPILER})
			set(TEMP_CMAKE_LINKER ${CMAKE_LINKER})
			set(TEMP_CMAKE_RANLIB ${CMAKE_RANLIB})
			set(TEMP_CMAKE_CXX_COMPILER_ID ${CMAKE_CXX_COMPILER_ID})
			set(TEMP_CMAKE_CXX_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})
      set(TEMP_CXX_STANDARD_LIBRARIES ${CXX_STANDARD_LIBRARIES})
      foreach(lib IN LISTS TEMP_CXX_STANDARD_LIBRARIES)
        set(TEMP_CXX_STD_LIB_${lib}_ABI_SOVERSION ${CXX_STD_LIB_${lib}_ABI_SOVERSION})
      endforeach()
      set(TEMP_CXX_STD_SYMBOLS ${CXX_STD_SYMBOLS})
      foreach(symbol IN LISTS TEMP_CXX_STD_SYMBOLS)
        set(TEMP_CXX_STD_SYMBOL_${symbol}_VERSION ${CXX_STD_SYMBOL_${symbol}_VERSION})
      endforeach()
		endif()
	endif()
  load_Current_Platform()
	if(build_folder STREQUAL build)
		if(TEMP_PLATFORM)
			if( (NOT TEMP_PLATFORM STREQUAL CURRENT_PLATFORM) #the current platform has changed to we need to regenerate
					OR (NOT TEMP_C_COMPILER STREQUAL CMAKE_C_COMPILER)
					OR (NOT TEMP_CXX_COMPILER STREQUAL CMAKE_CXX_COMPILER)
					OR (NOT TEMP_CMAKE_LINKER STREQUAL CMAKE_LINKER)
					OR (NOT TEMP_CMAKE_RANLIB STREQUAL CMAKE_RANLIB)
					OR (NOT TEMP_CMAKE_CXX_COMPILER_ID STREQUAL CMAKE_CXX_COMPILER_ID)
					OR (NOT TEMP_CMAKE_CXX_COMPILER_VERSION STREQUAL CMAKE_CXX_COMPILER_VERSION)
				)
        set(DO_CLEAN TRUE)
      else()
        set(DO_CLEAN FALSE)
        #detecting if soname of standard lirbaries have changed
        foreach(lib IN LISTS TEMP_CXX_STANDARD_LIBRARIES)
          if(NOT TEMP_CXX_STD_LIB_${lib}_ABI_SOVERSION VERSION_EQUAL CXX_STD_LIB_${lib}_ABI_SOVERSION)
            set(DO_CLEAN TRUE)
            break()
          endif()
        endforeach()
        if(NOT DO_CLEAN)#must check that previous and current lists of standard libraries perfectly match
          foreach(lib IN LISTS CXX_STANDARD_LIBRARIES)
            if(NOT TEMP_CXX_STD_LIB_${lib}_ABI_SOVERSION VERSION_EQUAL CXX_STD_LIB_${lib}_ABI_SOVERSION)
              set(DO_CLEAN TRUE)
              break()
            endif()
          endforeach()
        endif()

        #detecting symbol version changes and symbol addition-removal in C++ standard libraries
        if(NOT DO_CLEAN)
          foreach(symbol IN LISTS TEMP_CXX_STD_SYMBOLS)
            if(NOT TEMP_CXX_STD_SYMBOL_${symbol}_VERSION VERSION_EQUAL CXX_STD_SYMBOL_${symbol}_VERSION)
              set(DO_CLEAN TRUE)
              break()
            endif()
          endforeach()
        endif()
        if(NOT DO_CLEAN)#must check that previous and current lists of ABI symbols perfectly match
          foreach(symbol IN LISTS CXX_STD_SYMBOLS)
            if(NOT CXX_STD_SYMBOL_${symbol}_VERSION VERSION_EQUAL TEMP_CXX_STD_SYMBOL_${symbol}_VERSION)
              set(DO_CLEAN TRUE)
              break()
            endif()
          endforeach()
        endif()

      endif()
      if(DO_CLEAN)
				message("[PID] INFO : cleaning the build folder after major environment change")
				hard_Clean_Package_Debug(${PROJECT_NAME})
				hard_Clean_Package_Release(${PROJECT_NAME})
				reconfigure_Package_Build_Debug(${PROJECT_NAME})#force reconfigure before running the build
				reconfigure_Package_Build_Release(${PROJECT_NAME})#force reconfigure before running the build
			endif()
		endif()
	endif()
endmacro(manage_Current_Platform)

#.rst:
#
# .. ifmode:: internal
#
#  .. |load_Current_Platform| replace:: ``load_Current_Platform``
#  .. _load_Current_Platform:
#
#  load_Current_Platform
#  ---------------------
#
#   .. command:: load_Current_Platform()
#
#    Load the platform description information into current process.
#
function(load_Current_Platform)
#loading the current platform configuration simply consist in including the config file generated by the workspace
include(${WORKSPACE_DIR}/pid/Workspace_Platforms_Info.cmake)
endfunction(load_Current_Platform)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Package_Platforms_Variables| replace:: ``reset_Package_Platforms_Variables``
#  .. _reset_Package_Platforms_Variables:
#
#  reset_Package_Platforms_Variables
#  ---------------------------------
#
#   .. command:: reset_Package_Platforms_Variables()
#
#    Reset all platform constraints applying to current project.
#
function(reset_Package_Platforms_Variables)
  foreach(config IN LISTS ${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX})
    set(${PROJECT_NAME}_PLATFORM_CONFIGURATION_${config}_ARGS${USE_MODE_SUFFIX} CACHE INTERNAL "")#reset arguments if any
    set(${PROJECT_NAME}_PLATFORM_CONFIGURATION_${config}_BUILD_ONLY${USE_MODE_SUFFIX} CACHE INTERNAL "")#reset arguments if any
  endforeach()
	set(${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
endfunction(reset_Package_Platforms_Variables)


#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Compatible_With_Current_ABI| replace:: ``is_Compatible_With_Current_ABI``
#  .. _is_Compatible_With_Current_ABI:
#
#  is_Compatible_With_Current_ABI
#  ------------------------------
#
#   .. command:: is_Compatible_With_Current_ABI(COMPATIBLE package)
#
#    Chech whether the given package binary in use use a compatible ABI for standard library.
#
#     :package: the name of binary package to check.
#
#     :COMPATIBLE: the output variable that is TRUE if package's stdlib usage is compatible with current platform ABI, FALSE otherwise.
#
function(is_Compatible_With_Current_ABI COMPATIBLE package)

  if((${package}_BUILT_WITH_CXX_ABI AND NOT ${package}_BUILT_WITH_CXX_ABI STREQUAL CURRENT_CXX_ABI)
    OR (${package}_BUILT_WITH_CMAKE_INTERNAL_PLATFORM_ABI AND NOT ${package}_BUILT_WITH_CMAKE_INTERNAL_PLATFORM_ABI STREQUAL CMAKE_INTERNAL_PLATFORM_ABI))
    set(${COMPATIBLE} FALSE PARENT_SCOPE)
    #remark: by default we are not restructive if teh binary file does not contain sur information
    return()
  else()
    #test for standard libraries versions
    foreach(lib IN LISTS ${package}_BUILT_WITH_CXX_STD_LIBRARIES)
      if(${package}_BUILT_WITH_CXX_STD_LIB_${lib}_ABI_SOVERSION
          AND CXX_STD_LIB_${lib}_ABI_SOVERSION
          AND (NOT ${package}_BUILT_WITH_CXX_STD_LIB_${lib}_ABI_SOVERSION STREQUAL CXX_STD_LIB_${lib}_ABI_SOVERSION))
          #soversion number must be defined for the given lib in order to be compared (if no sonumber => no restriction)
          set(${COMPATIBLE} FALSE PARENT_SCOPE)
          return()
      endif()
    endforeach()
    foreach(lib IN LISTS CXX_STANDARD_LIBRARIES)
      if(${package}_BUILT_WITH_CXX_STD_LIB_${lib}_ABI_SOVERSION
          AND CXX_STD_LIB_${lib}_ABI_SOVERSION
          AND (NOT ${package}_BUILT_WITH_CXX_STD_LIB_${lib}_ABI_SOVERSION STREQUAL CXX_STD_LIB_${lib}_ABI_SOVERSION))
          #soversion number must be defined for the given lib in order to be compared (if no sonumber => no restriction)
          set(${COMPATIBLE} FALSE PARENT_SCOPE)
          return()
      endif()
    endforeach()

    #test symbols versions
    foreach(symbol IN LISTS ${package}_BUILT_WITH_CXX_STD_SYMBOLS)#for each symbol used by the binary
      if(NOT CXX_STD_SYMBOL_${symbol}_VERSION)#corresponding symbol do not exist in current environment => it is an uncompatible binary
        set(${COMPATIBLE} FALSE PARENT_SCOPE)
        return()
      endif()

      #the binary has been built and linked against a newer version of standard libraries => NOT compatible
      if(${package}_BUILT_WITH_CXX_STD_SYMBOL_${symbol}_VERSION VERSION_GREATER CXX_STD_SYMBOL_${symbol}_VERSION)
        set(${COMPATIBLE} FALSE PARENT_SCOPE)
        return()
      endif()
    endforeach()
  endif()
  set(${COMPATIBLE} TRUE PARENT_SCOPE)
endfunction(is_Compatible_With_Current_ABI)


#.rst:
#
# .. ifmode:: internal
#
#  .. |parse_System_Check_Constraints| replace:: ``parse_System_Check_Constraints``
#  .. _parse_System_Check_Constraints:
#
#  parse_System_Check_Constraints
#  -------------------------------
#
#   .. command:: parse_System_Check_Constraints(NAME ARGS constraint)
#
#     Extract the arguments passed to a configuration or environment check.
#
#     :constraint: the string representing the constraint check.
#
#     :NAME: the output variable containing the name of the configuration
#
#     :ARGS: the output variable containing the list of  arguments of the constraint check.
#
function(parse_System_Check_Constraints NAME ARGS constraint)
  string(REPLACE " " "" constraint ${constraint})#remove the spaces if any
  string(REPLACE "\t" "" constraint ${constraint})#remove the tabulations if any
  if(constraint MATCHES "^([^[]+)\\[([^]]+)\\]$")#it matches !! => there are arguments passed to the configuration
    set(THE_NAME ${CMAKE_MATCH_1})
    set(THE_ARGS ${CMAKE_MATCH_2})
    set(${ARGS} PARENT_SCOPE)
    set(${NAME} PARENT_SCOPE)
    if(NOT THE_ARGS)
      return()#this is a ill formed description of a system check
    endif()
    string(REPLACE ":" ";" ARGS_LIST "${THE_ARGS}")
    parse_Configuration_Arguments_From_Binaries(result ARGS_LIST)#here parsing is the same as from binary package use files
    set(${ARGS} ${result} PARENT_SCOPE)
    set(${NAME} ${THE_NAME} PARENT_SCOPE)
  else()#this is a configuration constraint without arguments
    set(${ARGS} PARENT_SCOPE)
    set(${NAME} ${constraint} PARENT_SCOPE)
  endif()
endfunction(parse_System_Check_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Configuration_Parameters| replace:: ``generate_Configuration_Parameters``
#  .. _generate_Configuration_Parameters:
#
#  generate_Configuration_Parameters
#  ---------------------------------
#
#   .. command:: generate_Configuration_Parameters(RESULTING_EXPRESSION config_name config_args)
#
#     Generate a list whose each element is an expression of the form name=value.
#
#     :config_name: the name of the system configuration.
#
#     :config_args: list of arguments to use as constraints checn checking the system configuration.
#
#     :LIST_OF_PAREMETERS: the output variable containing the list of expressions used to value the configuration.
#
function(generate_Configuration_Parameters LIST_OF_PAREMETERS config_name config_args)
  set(returned)
  if(config_args)
    set(first_time TRUE)
    #now generating expression for each argument
    while(config_args)
      list(GET config_args 0 name)
      list(GET config_args 1 value)
      list(APPEND returned "${name}=${value}")
      list(REMOVE_AT config_args 0 1)
    endwhile()
  endif()
  set(${LIST_OF_PAREMETERS} ${returned} PARENT_SCOPE)
endfunction(generate_Configuration_Parameters)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Configuration_Constraints| replace:: ``generate_Configuration_Constraints``
#  .. _generate_Configuration_Constraints:
#
#  generate_Configuration_Constraints
#  ----------------------------------
#
#   .. command:: generate_Configuration_Constraints(RESULTING_EXPRESSION config_name config_args)
#
#     Generate an expression (string) that describes the configuration check given by configuration name and arguments. Inverse operation of parse_System_Check_Constraints.
#
#     :config_name: the name of the system configuration.
#
#     :config_args: list of arguments to use as constraints checn checking the system configuration.
#
#     :RESULTING_EXPRESSION: the output variable containing the configuration check equivalent expression.
#
function(generate_Configuration_Constraints RESULTING_EXPRESSION config_name config_args)
  if(config_args)
    set(final_expression "${config_name}[")
    generate_Configuration_Parameters(PARAMS ${config_name} "${config_args}")
    set(first_time TRUE)
    #now generating expression for each argument
    foreach(arg IN LISTS PARAMS)
      if(NOT first_time)
        set(final_expression "${final_expression}:${arg}")
      else()
        set(final_expression "${final_expression}${arg}")
        set(first_time FALSE)
      endif()
    endforeach()
    set(final_expression "${final_expression}]")

  else()#there is no argument
    set(final_expression "${config_name}")
  endif()
  set(${RESULTING_EXPRESSION} "${final_expression}" PARENT_SCOPE)
endfunction(generate_Configuration_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_System_Configuration| replace:: ``check_System_Configuration``
#  .. _check_System_Configuration:
#
#  check_System_Configuration
#  --------------------------
#
#   .. command:: check_System_Configuration(RESULT NAME CONSTRAINTS config)
#
#    Check whether the given configuration constraint (= configruation name + arguments) conforms to target platform. This function is used in source scripts.
#
#     :config: the configuration expression (may contain arguments).
#
#     :RESULT: the output variable that is TRUE configuration constraints is satisfied by current platform.
#
#     :NAME: the output variable that contains the name of the configuration without arguments.
#
#     :CONSTRAINTS: the output variable that contains the constraints that applmy to the configuration once used. It includes arguments (constraints imposed by user) and generated contraints (constraints automatically defined by the configuration itself once used).
#
function(check_System_Configuration RESULT NAME CONSTRAINTS config)
  parse_System_Check_Constraints(CONFIG_NAME CONFIG_ARGS "${config}")
  if(NOT CONFIG_NAME)
    set(${NAME} PARENT_SCOPE)
    set(${CONSTRAINTS} PARENT_SCOPE)
    set(${RESULT} FALSE PARENT_SCOPE)
    message("[PID] CRITICAL ERROR : configuration check ${config} is ill formed.")
    return()
  endif()
  check_System_Configuration_With_Arguments(RESULT_WITH_ARGS BINARY_CONSTRAINTS ${CONFIG_NAME} CONFIG_ARGS)
  set(${NAME} ${CONFIG_NAME} PARENT_SCOPE)
  set(${RESULT} ${RESULT_WITH_ARGS} PARENT_SCOPE)
  # last step consist in generating adequate expressions for constraints
  generate_Configuration_Parameters(LIST_OF_CONSTRAINTS ${CONFIG_NAME} "${BINARY_CONSTRAINTS}")
  set(${CONSTRAINTS} ${LIST_OF_CONSTRAINTS} PARENT_SCOPE)
endfunction(check_System_Configuration)


#.rst:
#
# .. ifmode:: internal
#
#  .. |parse_Configuration_Arguments_From_Binaries| replace:: ``parse_Configuration_Arguments_From_Binaries``
#  .. _parse_Configuration_Arguments_From_Binaries:
#
#  parse_Configuration_Arguments_From_Binaries
#  -------------------------------------------
#
#   .. command:: parse_Configuration_Arguments_From_Binaries(RESULT_VARIABLE config_args_var)
#
#    Parse the configruation arguments when they come from the use file of a binary package
#
#     :config_args_var: the list of arguments coming from a native packag euse file. They the pattern variable=value with list value separated by ,.
#
#     :RESULT_VARIABLE: the output variable that contains the list of parsed arguments. Elements come two by two in the list, first being the variable name and the second being the value (unchanged from input).
#
function(parse_Configuration_Arguments_From_Binaries RESULT_VARIABLE config_args_var)
set(result)
foreach(arg IN LISTS ${config_args_var})
  if(arg MATCHES "^([^=]+)=(.+)$")
    list(APPEND result ${CMAKE_MATCH_1} ${CMAKE_MATCH_2})#simply append both arguments
  endif()
endforeach()
set(${RESULT_VARIABLE} ${result} PARENT_SCOPE)
endfunction(parse_Configuration_Arguments_From_Binaries)


#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Configuration_Arguments_Included_In_Constraints| replace:: ``check_Configuration_Arguments_Included_In_Constraints``
#  .. check_Configuration_Arguments_Included_In_Constraints:
#
#  check_Configuration_Arguments_Included_In_Constraints
#  -----------------------------------------------------
#
#   .. command:: check_Configuration_Arguments_Included_In_Constraints(INCLUDED arguments_var constraints_var)
#
#    Check whether a set of arguments of a configuration have already been checked in the current configuration process
#
#     :arguments_var: the variable containing the list of arguments to check.
#
#     :constraints_var: the variable containing the list of constraints already checked.
#
#     :INCLUDED: the output variable that is true if al arguments have already been checked.
#
function(check_Configuration_Arguments_Included_In_Constraints INCLUDED arguments_var constraints_var)
set(${INCLUDED} FALSE PARENT_SCOPE)

set(argument_couples ${${arguments_var}})
while(argument_couples)
  list(GET argument_couples 0 arg_name)
  list(GET argument_couples 1 arg_value)
  list(REMOVE_AT argument_couples 0 1)#update the list of arguments
  #from here we get a constraint name and a value
  set(is_arg_found FALSE)
  #evaluate values of the argument so that we can compare it
  if(arg_value AND NOT arg_value STREQUAL \"\")#special case of an empty list (represented with \"\") must be avoided
    string(REPLACE " " "" ARG_VAL_LIST ${arg_value})#remove the spaces in the string if any
    string(REPLACE "," ";" ARG_VAL_LIST ${ARG_VAL_LIST})#generate a cmake list (with ";" as delimiter) from an argument list (with "," delimiter)
  else()
    set(ARG_VAL_LIST)
  endif()

  set(constraints_couples ${${constraints_var}})
  while(constraints_couples)
    list(GET constraints_couples 0 constraint_name)
    list(GET constraints_couples 1 constraint_value)
    list(REMOVE_AT constraints_couples 0 1)#update the list of arguments
    if(constraint_name STREQUAL arg_name)#argument found in constraints
      set(is_arg_found TRUE)
      #OK we need to check the value
      if(constraint_value AND NOT constraint_value STREQUAL \"\")#special case of an empty list (represented with \"\") must be avoided
        string(REPLACE " " "" CONSTRAINT_VAL_LIST ${constraint_value})#remove the spaces in the string if any
        string(REPLACE "," ";" CONSTRAINT_VAL_LIST ${CONSTRAINT_VAL_LIST})#generate a cmake list (with ";" as delimiter) from an argument list (with "," delimiter)
      else()
        set(CONSTRAINT_VAL_LIST)
      endif()
      #second : do the comparison
      foreach(arg_list_val IN LISTS ARG_VAL_LIST)
        set(val_found FALSE)
        foreach(ct_list_val IN LISTS CONSTRAINT_VAL_LIST)
          if(ct_list_val STREQUAL arg_list_val)
            set(val_found TRUE)
            break()
          endif()
        endforeach()
        if(NOT val_found)
          #we can immediately return => not included
          return()
        endif()
      endforeach()
      break()#exit the loop if argument has been found
    endif()
  endwhile()
  if(NOT is_arg_found)
    #if argument not found in constraint we can conclude that it is not included in constraints
    return()
  endif()
endwhile()
set(${INCLUDED} TRUE PARENT_SCOPE)
endfunction(check_Configuration_Arguments_Included_In_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_System_Configuration_With_Arguments| replace:: ``check_System_Configuration_With_Arguments``
#  .. _check_System_Configuration_With_Arguments:
#
#  check_System_Configuration_With_Arguments
#  -----------------------------------------
#
#   .. command:: check_System_Configuration_With_Arguments(CHECK_OK BINARY_CONTRAINTS config_name config_args)
#
#    Check whether the given configuration constraint (= configruation name + arguments) conforms to target platform.
#
#     :config_name: the name of the configuration (without argument).
#
#     :config_args: the constraints passed as arguments by the user of the configuration.
#
#     :CHECK_OK: the output variable that is TRUE configuration constraints is satisfied by current platform.
#
#     :BINARY_CONTRAINTS: the output variable that contains the list of all parameter (constraints coming from argument or generated by the configuration itself) to use whenever the configuration is used.
#
function(check_System_Configuration_With_Arguments CHECK_OK BINARY_CONTRAINTS config_name config_args)
  set(${BINARY_CONTRAINTS} PARENT_SCOPE)
  set(${CHECK_OK} FALSE PARENT_SCOPE)
  if(EXISTS ${WORKSPACE_DIR}/configurations/${config_name}/check_${config_name}.cmake)
    #check if the configuration has already been checked
    check_Configuration_Temporary_Optimization_Variables(RES_CHECK RES_CONSTRAINTS ${config_name})
    if(RES_CHECK)
      if(${config_args})#testing if the variable containing arguments is not empty
        #if this situation we need to check if all args match constraints
        check_Configuration_Arguments_Included_In_Constraints(INCLUDED ${config_args} ${RES_CONSTRAINTS})
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
    reset_Configuration_Cache_Variables(${config_name}) #reset the output variables to ensure a good result
    include(${WORKSPACE_DIR}/configurations/${config_name}/check_${config_name}.cmake)#get the description of the configuration check
    #now preparing args passed to the configruation (generate cmake variables)
    if(${config_args})#testing if the variable containing arguments is not empty
      prepare_Configuration_Arguments(${config_name} ${config_args})#setting variables that correspond to the arguments passed to the check script
    endif()
    check_Configuration_Arguments(ARGS_TO_SET ${config_name})
    if(ARGS_TO_SET)#there are unset required arguments
      fill_String_From_List(ARGS_TO_SET RES_STRING)
      message("[PID] WARNING : when checking arguments of configuration ${config_name}, there are required arguments that are not set : ${RES_STRING}")
      return()
    endif()

    # finding artifacts to fulfill system configuration
    find_Configuration(${config_name})
    set(${config_name}_AVAILABLE TRUE CACHE INTERNAL "")
    if(NOT ${config_name}_CONFIG_FOUND)
    	install_Configuration(${config_name})
    	if(NOT ${config_name}_INSTALLED)
        set(${config_name}_AVAILABLE FALSE CACHE INTERNAL "")
      endif()
    endif()
    if(NOT ${config_name}_AVAILABLE)#configuration is not available so we cannot generate output variables
      set_Configuration_Temporary_Optimization_Variables(${config_name} FALSE "")
      return()
    endif()

    # checking dependencies
    foreach(check IN LISTS ${config_name}_CONFIGURATION_DEPENDENCIES)
      check_System_Configuration(RESULT_OK CONFIG_NAME CONFIG_CONSTRAINTS ${check})#check that dependencies are OK
      if(NOT RESULT_OK)
        message("[PID] WARNING : when checking configuration of current platform, configuration ${check}, used by ${config_name} cannot be satisfied.")
        set_Configuration_Temporary_Optimization_Variables(${config_name} FALSE "")
        return()
      endif()
    endforeach()

    #extracting variables to make them usable in calling context
    extract_Configuration_Resulting_Variables(${config_name})

    #return the complete set of binary contraints
    get_Configuration_Resulting_Constraints(ALL_CONSTRAINTS ${config_name})
    set(${BINARY_CONTRAINTS} ${ALL_CONSTRAINTS} PARENT_SCOPE)#automatic appending constraints generated by the configuration itself for the given binary package generated
    set(${CHECK_OK} TRUE PARENT_SCOPE)
    set_Configuration_Temporary_Optimization_Variables(${config_name} TRUE "${ALL_CONSTRAINTS}")
    return()
  else()
    message("[PID] WARNING : when checking constraints on current platform, configuration information for ${config_name} does not exists. You use an unknown constraint. Please remove this constraint or create a new cmake script file called check_${config_name}.cmake in ${WORKSPACE_DIR}/configurations/${config_name} to manage this configuration. You can also try to update your workspace to get updates on available configurations.")
    return()
  endif()
endfunction(check_System_Configuration_With_Arguments)


#.rst:
#
# .. ifmode:: internal
#
#  .. |into_Configuration_Argument_List| replace:: ``into_Configuration_Argument_List``
#  .. _into_Configuration_Argument_List:
#
#  into_Configuration_Argument_List
#  --------------------------------
#
#   .. command:: into_Configuration_Argument_List(ALLOWED config_name config_args)
#
#    Test if a configuration can be used with current platform.
#
#     :input: the parent_scope variable containing string delimited arguments.
#
#     :OUTPUT: the output variable containing column delimited arguments.
#
function(into_Configuration_Argument_List input OUTPUT)
  string(REPLACE ";" "," TEMP "${${input}}")
  string(REPLACE " " "" TEMP "${TEMP}")
  string(REPLACE "\t" "" TEMP "${TEMP}")
  set(${OUTPUT} ${TEMP} PARENT_SCOPE)
endfunction(into_Configuration_Argument_List)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Allowed_System_Configuration| replace:: ``is_Allowed_System_Configuration``
#  .. _is_Allowed_System_Configuration:
#
#  is_Allowed_System_Configuration
#  -------------------------------
#
#   .. command:: is_Allowed_System_Configuration(ALLOWED config_name config_args)
#
#    Test if a configuration can be used with current platform.
#
#     :config_name: the name of the configuration (without argument).
#
#     :config_args: the constraints passed as arguments by the user of the configuration.
#
#     :ALLOWED: the output variable that is TRUE if configuration can be used.
#
function(is_Allowed_System_Configuration ALLOWED config_name config_args)
  set(${ALLOWED} FALSE PARENT_SCOPE)
  if( EXISTS ${WORKSPACE_DIR}/configurations/${config_name}/check_${config_name}.cmake
      AND EXISTS ${WORKSPACE_DIR}/configurations/${config_name}/find_${config_name}.cmake)

    reset_Configuration_Cache_Variables(${config_name}) #reset the output variables to ensure a good result

    include(${WORKSPACE_DIR}/configurations/${config_name}/check_${config_name}.cmake)#get the description of the configuration check

    #now preparing args passed to the configruation (generate cmake variables)
    if(${config_args})#testing if the variable containing arguments is not empty
      prepare_Configuration_Arguments(${config_name} ${config_args})#setting variables that correspond to the arguments passed to the check script
    endif()
    check_Configuration_Arguments(ARGS_TO_SET ${config_name})
    if(ARGS_TO_SET)#there are unset required arguments
      fill_String_From_List(ARGS_TO_SET RES_STRING)
      message("[PID] WARNING : when testing arguments of configuration ${config_name}, there are required arguments that are not set : ${RES_STRING}")
      return()
    endif()

    # checking dependencies first
    foreach(check IN LISTS ${config_name}_CONFIGURATION_DEPENDENCIES)
      parse_System_Check_Constraints(CONFIG_NAME CONFIG_ARGS "${check}")
      if(NOT CONFIG_NAME)
        return()
      endif()
      is_Allowed_System_Configuration(DEP_ALLOWED CONFIG_NAME CONFIG_ARGS)
      if(NOT DEP_ALLOWED)
        return()
      endif()
    endforeach()

    find_Configuration(${config_name}) # find the artifacts used by this configuration
    if(NOT ${config_name}_CONFIG_FOUND)# not found, trying to see if it can be installed
      is_Configuration_Installable(INSTALLABLE ${config_name})
      if(NOT INSTALLABLE)
          return()
      endif()
    endif()
  else()
    message("[PID] WARNING : configuration ${config_name} is unknown in workspace.")
    return()
  endif()
  set(${ALLOWED} TRUE PARENT_SCOPE)
endfunction(is_Allowed_System_Configuration)

#FROM here

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Configuration| replace:: ``find_Configuration``
#  .. _find_Configuration:
#
#  find_Configuration
#  ------------------
#
#   .. command:: find_Configuration(config)
#
#   Call the procedure for finding artefacts related to a configuration. Set the ${config}_FOUND variable, that is TRUE is configuration has been found, FALSE otherwise.
#
#     :config: the name of the configuration to find.
#
macro(find_Configuration config)
  set(${config}_CONFIG_FOUND FALSE)
  if(EXISTS ${WORKSPACE_DIR}/configurations/${config}/find_${config}.cmake)
    include(${WORKSPACE_DIR}/configurations/${config}/find_${config}.cmake)
  endif()
endmacro(find_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Configuration_Installable| replace:: ``is_Configuration_Installable``
#  .. _is_Configuration_Installable:
#
#  is_Configuration_Installable
#  ----------------------------
#
#   .. command:: is_Configuration_Installable(INSTALLABLE config)
#
#   Call the procedure telling if a configuratio can be installed.
#
#     :config: the name of the configuration to install.
#
#     :INSTALLABLE: the output variable that is TRUE is configuartion can be installed, FALSE otherwise.
#
function(is_Configuration_Installable INSTALLABLE config)
  set(${INSTALLABLE} FALSE PARENT_SCOPE)
  if(EXISTS ${WORKSPACE_DIR}/configurations/${config}/installable_${config}.cmake)
    include(${WORKSPACE_DIR}/configurations/${config}/installable_${config}.cmake)
    if(${config}_CONFIG_INSTALLABLE)
      set(${INSTALLABLE} TRUE PARENT_SCOPE)
    endif()
  endif()
endfunction(is_Configuration_Installable)

#.rst:
#
# .. ifmode:: internal
#
#  .. |install_Configuration| replace:: ``install_Configuration``
#  .. _install_Configuration:
#
#  install_Configuration
#  ---------------------
#
#   .. command:: install_Configuration(config)
#
#   Call the install procedure of a given configuration. Set the ${config}_INSTALLED variable to TRUE if the configuration has been installed on OS.
#
#     :config: the name of the configuration to install.
#
macro(install_Configuration config)
  set(${config}_INSTALLED FALSE)
  is_Configuration_Installable(INSTALLABLE ${config})
  if(INSTALLABLE)
    message("[PID] INFO : installing configuration ${config}...")
  	if(EXISTS ${WORKSPACE_DIR}/configurations/${config}/install_${config}.cmake)
      include(${WORKSPACE_DIR}/configurations/${config}/install_${config}.cmake)
      find_Configuration(${config})
      if(${config}_CONFIG_FOUND)
        message("[PID] INFO : configuration ${config} installed !")
        set(${config}_INSTALLED TRUE)
      else()
        message("[PID] WARNING : install of configuration ${config} has failed !")
      endif()
    endif()
  endif()
endmacro(install_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Configuration_Cache_Variables| replace:: ``reset_Configuration_Cache_Variables``
#  .. _reset_Configuration_Cache_Variables:
#
#  reset_Configuration_Cache_Variables
#  -----------------------------------
#
#   .. command:: reset_Configuration_Cache_Variables(config)
#
#   Reset all cache variables relatied to the given configuration
#
#     :config: the name of the configuration to be reset.
#
function(reset_Configuration_Cache_Variables config)
  if(${config}_RETURNED_VARIABLES)
    foreach(var IN LISTS ${config}_RETURNED_VARIABLES)
      set(${config}_${var} CACHE INTERNAL "")
    endforeach()
    set(${config}_RETURNED_VARIABLES CACHE INTERNAL "")
  endif()
  set(${config}_REQUIRED_CONSTRAINTS CACHE INTERNAL "")
  set(${config}_OPTIONAL_CONSTRAINTS CACHE INTERNAL "")
  foreach(constraint IN LISTS ${config}_IN_BINARY_CONSTRAINTS)
    set(${config}_${constraint}_BINARY_VALUE CACHE INTERNAL "")
  endforeach()
  set(${config}_IN_BINARY_CONSTRAINTS CACHE INTERNAL "")
  set(${config}_CONFIGURATION_DEPENDENCIES CACHE INTERNAL "")
endfunction(reset_Configuration_Cache_Variables)


#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_Configuration_Resulting_Variables| replace:: ``extract_Configuration_Resulting_Variables``
#  .. _extract_Configuration_Resulting_Variables:
#
#  extract_Configuration_Resulting_Variables
#  -----------------------------------------
#
#   .. command:: extract_Configuration_Resulting_Variables(config)
#
#     Get the list of constraints that should apply to a given configuration when used in a binary.
#
#     :config: the name of the configuration to be checked.
#
function(extract_Configuration_Resulting_Variables config)
  #updating output variables from teh value of variables specified by PID_Configuration_Variables
  foreach(var IN LISTS ${config}_RETURNED_VARIABLES)
    #the content of ${config}_${var}_RETURNED_VARIABLE is the name of a variable so need to get its value using ${}
    set(${config}_${var} ${${${config}_${var}_RETURNED_VARIABLE}} CACHE INTERNAL "")
  endforeach()
endfunction(extract_Configuration_Resulting_Variables)


#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Configuration_Arguments| replace:: ``check_Configuration_Arguments``
#  .. _check_Configuration_Arguments:
#
#  check_Configuration_Arguments
#  -----------------------------
#
#   .. command:: check_Configuration_Arguments(ARGS_TO_SET config)
#
#     Check if all required arguments for the configuration are set before checking the configuration.
#
#     :config: the name of the configuration to be checked.
#
#     :ARGS_TO_SET: the parent scope variable containing the list of required arguments that have not been set by user.
#
function(check_Configuration_Arguments ARGS_TO_SET config)
  set(list_of_args)
  foreach(arg IN LISTS ${config}_REQUIRED_CONSTRAINTS)
    if(NOT ${config}_${arg} AND NOT ${config}_${arg} EQUAL 0 AND NOT ${config}_${arg} STREQUAL "FALSE")
      list(APPEND list_of_args ${arg})
    endif()
  endforeach()
  set(${ARGS_TO_SET} ${list_of_args} PARENT_SCOPE)
endfunction(check_Configuration_Arguments)

#.rst:
#
# .. ifmode:: internal
#
#  .. |prepare_Configuration_Arguments| replace:: ``prepare_Configuration_Arguments``
#  .. _prepare_Configuration_Arguments:
#
#  prepare_Configuration_Arguments
#  -------------------------------
#
#   .. command:: prepare_Configuration_Arguments(config arguments)
#
#     Set the variables corresponding to configuration arguments in the parent scope.
#
#     :config: the name of the configuration to be checked.
#
#     :arguments: the parent scope variable containing the list of arguments generated from parse_System_Check_Constraints.
#
function(prepare_Configuration_Arguments config arguments)
  if(NOT arguments OR NOT ${arguments})
    return()
  endif()
  set(argument_couples ${${arguments}})
  while(argument_couples)
    list(GET argument_couples 0 name)
    list(GET argument_couples 1 value)
    list(REMOVE_AT argument_couples 0 1)#update the list of arguments in parent scope
    if(value AND NOT value STREQUAL \"\")#special case of an empty list (represented with \"\") must be avoided
      string(REPLACE " " "" VAL_LIST ${value})#remove the spaces in the string if any
      string(REPLACE "," ";" VAL_LIST ${VAL_LIST})#generate a cmake list (with ";" as delimiter) from an argument list (with "," delimiter)
    else()
      set(VAL_LIST)
    endif()
    list(FIND ${config}_REQUIRED_CONSTRAINTS ${name} INDEX)
    set(GENERATE_VAR FALSE)
    if(NOT INDEX EQUAL -1)# it is a required constraint
      set(GENERATE_VAR TRUE)
    else()
      list(FIND ${config}_OPTIONAL_CONSTRAINTS ${name} INDEX)
      if(NOT INDEX EQUAL -1)
        set(GENERATE_VAR TRUE)
      else()
        list(FIND ${config}_IN_BINARY_CONSTRAINTS ${name} INDEX)
        if(NOT INDEX EQUAL -1)
          set(GENERATE_VAR TRUE)
        endif()
      endif()
    endif()
    if(GENERATE_VAR)
      #now interpret variables contained in the list
      set(final_list_of_values)
      foreach(element IN LISTS VAL_LIST)#for each value in the list
        if(element AND DEFINED ${element})#element is a variable
          list(APPEND final_list_of_values ${${element}})
        else()
          list(APPEND final_list_of_values ${element})
        endif()
      endforeach()
      set(${config}_${name} ${final_list_of_values} PARENT_SCOPE)
    endif()
  endwhile()
endfunction(prepare_Configuration_Arguments)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Configuration_Resulting_Constraints| replace:: ``get_Configuration_Resulting_Constraints``
#  .. _get_Configuration_Resulting_Constraints:
#
#  get_Configuration_Resulting_Constraints
#  ---------------------------------------
#
#   .. command:: get_Configuration_Resulting_Constraints(BINARY_CONSTRAINTS config)
#
#     Get the list of constraints that should apply to a given configuration when used in a binary.
#
#     :config: the name of the configuration to be checked.
#
#     :BINARY_CONSTRAINTS: the output variable the contains the list of constraints to be used in binaries (pair name-value).
#
function(get_Configuration_Resulting_Constraints BINARY_CONSTRAINTS config)

#updating all constraints to apply in binary package, they correspond to variable that will be outputed
foreach(constraint IN LISTS ${config}_REQUIRED_CONSTRAINTS)
  set(VAL_LIST ${${config}_${constraint}})#get the value of the variable corresponding to the configuration constraint
  string(REPLACE " " "" VAL_LIST "${VAL_LIST}")#remove the spaces in the string if any
  string(REPLACE ";" "," VAL_LIST "${VAL_LIST}")#generate a configuration argument list (with "," as delimiter) from an argument list (with "," delimiter)
  list(APPEND all_constraints ${constraint} "${VAL_LIST}")#use guillemet to set exactly one element
endforeach()

foreach(constraint IN LISTS ${config}_IN_BINARY_CONSTRAINTS)
  set(VAL_LIST "${${${config}_${constraint}_BINARY_VALUE}}")#interpret the value of the adequate configuration generated internal variable
  if(NOT VAL_LIST)#list is empty
    list(APPEND all_constraints ${constraint} "\"\"")#specific case: dealing with an empty value
  else()
    string(REPLACE " " "" VAL_LIST "${VAL_LIST}")#remove the spaces in the string if any
    string(REPLACE ";" "," VAL_LIST "${VAL_LIST}")#generate a configuration argument list (with "," as delimiter) from an argument list (with "," delimiter)
    list(APPEND all_constraints ${constraint} "${VAL_LIST}")#use guillemet to set exactly one element
  endif()
endforeach()

#optional constraints are never propagated to binaries description
set(${BINARY_CONSTRAINTS} ${all_constraints} PARENT_SCOPE)#the value of the variable is not the real value but the name of the variable

endfunction(get_Configuration_Resulting_Constraints)
