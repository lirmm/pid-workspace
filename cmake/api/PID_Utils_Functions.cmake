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
if(PID_UTILS_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_UTILS_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

include(CMakeParseArguments)
include(PID_Contribution_Space_Functions NO_POLICY_SCOPE)


##########################################################################################
################# Management of configuration expressions ################################
##########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Configuration_Expression_Resulting_Constraints| replace:: ``get_Configuration_Expression_Resulting_Constraints``
#  .. _get_Configuration_Expression_Resulting_Constraints:
#
#  get_Configuration_Expression_Resulting_Constraints
#  --------------------------------------------------
#
#   .. command:: get_Configuration_Expression_Resulting_Constraints(BINARY_CONSTRAINTS config possible_constraints)
#
#     Get the list of constraints that should apply to a given configuration when used in a binary.
#
#     :config: the name of the configuration to be checked.
#     :possible_constraints: the parent scope variable that contains names of constraint that should be part of the binary.
#
#     :BINARY_CONSTRAINTS: the output variable the contains the list of constraints to be used in binaries. A constraint is represented by two following elements in the list with the form : name value.
#
function(get_Configuration_Expression_Resulting_Constraints BINARY_CONSTRAINTS config possible_constraints)

  #updating all constraints to apply in binary package, they correspond to variable that will be outputed
  set(all_constraints)
  foreach(constraint IN LISTS ${possible_constraints})
    if(DEFINED ${config}_${constraint}_BINARY_VALUE)#interpret the value of the adequate internal variable instead of the default generated one
      generate_Value_For_Configuration_Expression_Parameter(RES_VALUE ${${config}_${constraint}_BINARY_VALUE})
    else()
      generate_Value_For_Configuration_Expression_Parameter(RES_VALUE ${config}_${constraint})
    endif()
    list(APPEND all_constraints ${constraint} "${RES_VALUE}")#use guillemet to set exactly one element
  endforeach()
  #optional constraints are never propagated to binaries description
  set(${BINARY_CONSTRAINTS} ${all_constraints} PARENT_SCOPE)#the value of the variable is not the real value but the name of the variable
endfunction(get_Configuration_Expression_Resulting_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |prepare_Configuration_Expression_Arguments| replace:: ``prepare_Configuration_Expression_Arguments``
#  .. _prepare_Configuration_Expression_Arguments:
#
#  prepare_Configuration_Expression_Arguments
#  ------------------------------------------
#
#   .. command:: prepare_Configuration_Expression_Arguments(config arguments possible_constraints)
#
#     Set the variables corresponding to configuration arguments in the parent scope, as well as the list of variables that are set and unset.
#
#     :config: the name of the configuration to be checked.
#     :arguments: the parent scope variable containing the list of arguments generated from parse_Configuration_Expression.
#     :possible_constraints: the parent scope variable containing the list of possible constraints that can be valued by arguments.
#
function(prepare_Configuration_Expression_Arguments config arguments possible_constraints)
  if(NOT arguments OR NOT ${arguments})#testing if the variable containing arguments is not empty
    return()
  endif()
  if(NOT ${possible_constraints})#if no possible constraints simply exit
    return()
  endif()
  set(all_args_set)
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

    list(FIND ${possible_constraints} ${name} INDEX)
    list(APPEND all_args_set ${name})
    if(NOT INDEX EQUAL -1)
      #now interpret variables contained in the list
      set(final_list_of_values)
      foreach(element IN LISTS VAL_LIST)#for each value in the list
        if(element AND DEFINED ${element})#element is a variable
          list(APPEND final_list_of_values ${${element}})#evaluate it
        else()
          list(APPEND final_list_of_values ${element})#simply copy the value
        endif()
      endforeach()
      set(${config}_${name} ${final_list_of_values} PARENT_SCOPE)#create the variable in parent scope
    endif()
  endwhile()
  set(all_args_to_unset)
  foreach(constraint IN LISTS ${possible_constraints})
    list(FIND all_args_set ${constraint} INDEX)
    if(INDEX EQUAL -1)#not found in argument set ... need to unset it from cache in the end
      list(APPEND all_args_to_unset ${constraint})
    endif()
  endforeach()

  set(${config}_arguments ${all_args_set} PARENT_SCOPE)
  set(${config}_no_arguments ${all_args_to_unset} PARENT_SCOPE)
endfunction(prepare_Configuration_Expression_Arguments)


#.rst:
#
# .. ifmode:: internal
#
#  .. |compare_Current_Configuration_Check_Args_With_Previous| replace:: ``compare_Current_Configuration_Check_Args_With_Previous``
#  .. compare_Current_Configuration_Check_Args_With_Previous:
#
#  compare_Current_Configuration_Check_Args_With_Previous
#  ------------------------------------------------------
#
#   .. command:: compare_Current_Configuration_Check_Args_With_Previous(INCLUDED arguments_var constraints_var)
#
#    Check whether a set of arguments of a configuration have already been checked in the current configuration process
#
#     :arguments_var: the variable containing the list of arguments to check.
#     :constraints_var: the variable containing the list of constraints already checked.
#
#     :INCLUDED: the output variable that is true if same check has been made.
#
function(compare_Current_Configuration_Check_Args_With_Previous INCLUDED arguments_var constraints_var)
  #quick checks to avoid checking values of both variables
  if(NOT ${arguments_var} AND NOT ${constraints_var})#both are empty
    set(${INCLUDED} TRUE PARENT_SCOPE)#by definition they are both equal
    return()
  endif()
  set(${INCLUDED} FALSE PARENT_SCOPE)
  if((${arguments_var} AND NOT ${constraints_var})#one is empty and not the other
      OR (NOT ${arguments_var} AND ${constraints_var}))
      return()#by definition one does not include the other
  endif()
  list(LENGTH ${arguments_var} SIZE_ARGS)
  list(LENGTH ${constraints_var} SIZE_MEM)
  if(NOT SIZE_ARGS EQUAL SIZE_MEM)
    return()#not the same number of arguments so we know that the check is not the same
  endif()
  math(EXPR last_elem_index_mem "${SIZE_MEM}-1")
  set(argument_couples ${${arguments_var}})
  set(constraints_couples ${${constraints_var}})
  while(argument_couples)
  list(GET argument_couples 0 arg_name)
  list(GET argument_couples 1 arg_value)
  list(REMOVE_AT argument_couples 0 1)#update the list of arguments
  #from here we get a constraint name and a value
  set(is_arg_found FALSE)
  #evaluate values of the argument so that we can compare it
  parse_Configuration_Expression_Argument_Value(ARG_VAL_LIST "${arg_value}")

  foreach(iter RANGE 0 ${last_elem_index_mem} 2)
    list(GET constraints_couples ${iter} constraint_name)
    if(constraint_name STREQUAL arg_name)#argument with same value found
      set(is_arg_found TRUE)
      #now check the value of this argument
      math(EXPR value_iter "${iter}+1")
      list(GET constraints_couples ${value_iter} constraint_value)
      parse_Configuration_Expression_Argument_Value(CONSTRAINT_VAL_LIST "${constraint_value}")
      #second : do the comparison between the value of both arguments (memorized and checked one)
      foreach(arg_list_val IN LISTS ARG_VAL_LIST)#Note: for list we siply check if the value to check belongs to the list, we do not check strict equality between lists
        if(NOT arg_list_val IN_LIST CONSTRAINT_VAL_LIST)
          #we can immediately return => not same check because value of the same argument differs
          return()
        endif()
      endforeach()
    endif()
    if(NOT is_arg_found)
      #if argument not found in memorized constraints then the current check is not the same as previous one
      return()
    endif()
  endforeach()
  endwhile()
  set(${INCLUDED} TRUE PARENT_SCOPE)
endfunction(compare_Current_Configuration_Check_Args_With_Previous)

#.rst:
#
# .. ifmode:: internal
#
#  .. |parse_Configuration_Expression_Argument_Value| replace:: ``parse_Configuration_Expression_Argument_Value``
#  .. _parse_Constraints_Check_Expression_Argument_Value:
#
#  parse_Configuration_Expression_Argument_Value
#  -------------------------------------------------
#
#   .. command:: parse_Configuration_Expression_Argument_Value(RESULT_VALUE value_expression)
#
#    Parse the value expression of an argument of a configuration expression. Usefull to manage value that are lists in expessions.
#
#     :value_expression: the string repsenting the value of a configuration expression's argument.
#
#     :RESULT_VALUE: the output variable that contains the value (in CMake format) of the argument variable.
#
function(parse_Configuration_Expression_Argument_Value RESULT_VALUE value_expression)
  if(value_expression AND NOT value_expression STREQUAL \"\")#special case of an empty list (represented with \"\") must be avoided
    string(REPLACE " " "" ARG_VAL_LIST ${value_expression})#remove the spaces in the string if any
    string(REPLACE "," ";" ARG_VAL_LIST ${ARG_VAL_LIST})#generate a cmake list (with ";" as delimiter) from an argument list (with "," delimiter)
  else()
    set(ARG_VAL_LIST)
  endif()
  set(${RESULT_VALUE} ${ARG_VAL_LIST} PARENT_SCOPE)
endfunction(parse_Configuration_Expression_Argument_Value)

#.rst:
#
# .. ifmode:: internal
#
#  .. |parse_Configuration_Expression_Arguments| replace:: ``parse_Configuration_Expression_Arguments``
#  .. _parse_Constraints_Check_Expression_Arguments:
#
#  parse_Configuration_Expression_Arguments
#  --------------------------------------------
#
#   .. command:: parse_Configuration_Expression_Arguments(RESULT_VARIABLE config_args_var)
#
#    Parse the configruation expression arguments when they come from the use file of a binary package
#
#     :config_args_var: the list of arguments coming from a use file. They the pattern variable=value with list value separated by ,.
#
#     :RESULT_VARIABLE: the output variable that contains the list of parsed arguments. Elements come two by two in the list, first being the variable name and the second being the value (unchanged from input).
#
function(parse_Configuration_Expression_Arguments RESULT_VARIABLE config_args_var)
set(result)
foreach(arg IN LISTS ${config_args_var})
  if(arg MATCHES "^([^=]+)=(.+)$")
    list(APPEND result ${CMAKE_MATCH_1} ${CMAKE_MATCH_2})#simply append both arguments
  endif()
endforeach()
set(${RESULT_VARIABLE} ${result} PARENT_SCOPE)
endfunction(parse_Configuration_Expression_Arguments)


#.rst:
#
# .. ifmode:: internal
#
#  .. |parse_Configuration_Expression| replace:: ``parse_Configuration_Expression``
#  .. _parse_Constraints_Check_Expression:
#
#  parse_Configuration_Expression
#  ----------------------------------
#
#   .. command:: parse_Configuration_Expression(NAME ARGS constraint)
#
#     Extract the arguments of a configuration expression.
#
#     :constraint: the string representing the constraint check.
#
#     :NAME: the output variable containing the base name of the expression (environment or system configuration)
#     :ARGS: the output variable containing the list of arguments of the constraint check. Elements in the list go by pair (name or argument, value)
#
function(parse_Configuration_Expression NAME ARGS constraint)
  string(REPLACE " " "" constraint ${constraint})#remove the spaces if any
  string(REPLACE "\t" "" constraint ${constraint})#remove the tabulations if any
  if(constraint MATCHES "^([^[]+)\\[([^]]+)\\]$")#it matches !! => there are arguments in the check expression
    set(THE_NAME ${CMAKE_MATCH_1})
    set(THE_ARGS ${CMAKE_MATCH_2})
    set(${ARGS} PARENT_SCOPE)
    set(${NAME} PARENT_SCOPE)
    if(NOT THE_ARGS)
      return()#this is a ill formed description of a system check
    endif()
    string(REPLACE ":" ";" ARGS_LIST "${THE_ARGS}")
    parse_Configuration_Expression_Arguments(result ARGS_LIST)#here parsing
    set(${ARGS} ${result} PARENT_SCOPE)
    set(${NAME} ${THE_NAME} PARENT_SCOPE)
  else()#this is a configuration constraint without arguments
    set(${ARGS} PARENT_SCOPE)
    set(${NAME} ${constraint} PARENT_SCOPE)
  endif()
endfunction(parse_Configuration_Expression)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Configuration_Expression_Parameters| replace:: ``generate_Configuration_Expression_Parameters``
#  .. _generate_Constraints_Check_Parameters:
#
#  generate_Configuration_Expression_Parameters
#  --------------------------------------------
#
#   .. command:: generate_Configuration_Expression_Parameters(RESULTING_EXPRESSION config_name config_args)
#
#     Generate a list whose each element is an expression of the form name=value.
#
#     :config_name: the name of the configuration to check.
#     :config_args: list of arguments to use as constraints when checking the configuration.
#
#     :LIST_OF_PAREMETERS: the output variable containing the list of expressions used to value the parameters of the expression.
#
function(generate_Configuration_Expression_Parameters LIST_OF_PAREMETERS config_name config_args)
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
endfunction(generate_Configuration_Expression_Parameters)


#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Value_For_Configuration_Expression_Parameter| replace:: ``generate_Value_For_Configuration_Expression_Parameter``
#  .. _generate_Value_For_Constraints_Check_Expression_Parameter:
#
#  generate_Value_For_Configuration_Expression_Parameter
#  ---------------------------------------------------------
#
#   .. command:: generate_Value_For_Configuration_Expression_Parameter(RES_VAL variable)
#
#     Generate a string that represent the value of an argument in a constraint check expression.
#
#     :variable: the parent scope variable that contains the value.
#
#     :RES_VAL: the output variable containing the representation of the variable's value in a constraint check expression.
#
function(generate_Value_For_Configuration_Expression_Parameter RES_VAL variable)
  set(VAL_LIST "${${variable}}")#interpret the value of the adequate parent scope variable
  if(NOT VAL_LIST)#list is empty
    set(${RES_VAL} "\"\"" PARENT_SCOPE)#specific case: dealing with an empty value
  else()
    string(REPLACE " " "" VAL_LIST "${VAL_LIST}")#remove the spaces in the string if any
    string(REPLACE ";" "," VAL_LIST "${VAL_LIST}")#generate a constraint expression value list (with "," as delimiter) from an argument list (with ";" delimiter)
    set(${RES_VAL} "${VAL_LIST}" PARENT_SCOPE)#use guillemet to set exactly one element
  endif()
endfunction(generate_Value_For_Configuration_Expression_Parameter)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Configuration_Expression| replace:: ``generate_Configuration_Expression``
#  .. _generate_Constraints_Check_Expression:
#
#  generate_Configuration_Expression
#  -------------------------------------
#
#   .. command:: generate_Configuration_Expression(RESULTING_EXPRESSION config_name config_args)
#
#     Generate an expression (string) that describes a check given by configuration or environment name and arguments. Inverse operation of parse_Configuration_Expression.
#
#     :config_name: the name of the system configuration.
#     :config_args: list of arguments to use as constraints when checking the system configuration. Value for the variables have already been generated by using generate_Value_For_Configuration_Expression_Parameter
#
#     :RESULTING_EXPRESSION: the output variable containing the configuration check equivalent expression.
#
function(generate_Configuration_Expression RESULTING_EXPRESSION config_name config_args)
  if(config_args)
    set(final_expression "${config_name}[")
    generate_Configuration_Expression_Parameters(PARAMS ${config_name} "${config_args}")
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
endfunction(generate_Configuration_Expression)


#############################################################
###################### system utilities #####################
#############################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |execute_OS_Command| replace:: ``execute_OS_Command``
#  .. _execute_OS_Command:
#
#  execute_OS_Command
#  ------------------
#
#   .. command:: execute_OS_Command(list_of_args)
#
#      invoque a command of the operating system with adequate privileges.
#
#     :list_of_args: the system command to be passed and that will be executed with adequate privileges (do not use sudo !)
#
macro(execute_OS_Command)
if(IN_CI_PROCESS)
  execute_process(COMMAND ${ARGN})
else()
  execute_process(COMMAND sudo ${ARGN})#need to have super user privileges except in CI where sudo is forbidden
endif()
endmacro(execute_OS_Command)

#############################################################
########### general utilities for build management ##########
#############################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Mode_Variables| replace:: ``get_Mode_Variables``
#  .. _get_Mode_Variables:
#
#  get_Mode_Variables
#  ------------------
#
#   .. command:: get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX mode)
#
#     Getting suffixes related to target mode (common accessor usefull in many places)
#
#     :mode: the mode for which getting corresponding suffixes
#
#     :TARGET_SUFFIX: the output variable containing the suffix string to be used for targets names
#     :VAR_SUFFIX: the output variable containing the suffix string to be used for CMake variable names
#
function(get_Mode_Variables TARGET_SUFFIX VAR_SUFFIX mode)
if(mode MATCHES Release)
	set(${TARGET_SUFFIX} PARENT_SCOPE)
	set(${VAR_SUFFIX} PARENT_SCOPE)
else()
	set(${TARGET_SUFFIX} -dbg PARENT_SCOPE)
	set(${VAR_SUFFIX} _DEBUG PARENT_SCOPE)
endif()
endfunction(get_Mode_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Platform_Variables| replace:: ``get_Platform_Variables``
#  .. _get_Platform_Variables:
#
#  get_Platform_Variables
#  ----------------------
#
#   .. command:: get_Platform_Variables([OPTION value]...)
#
#     Getting basic system variables related to current target platform (common accessor usefull in many places).
#
#     :BASENAME var:  the output variable that contains the base name of the current platform (with the form <arch>_<bits>_<kernel>_<abi>, e.g. x86_64_linux_stdc++11).
#     :INSTANCE var:  the output variable that contains the name of the instance for current platform (empty by default).
#     :PKG_STRING var: the output variable that contains the string representing the platform name appended to binary archives generated by CPack
#     :DISTRIBUTION var: the output variable that contains the string representing the current platform distribution (if any)
#     :DIST_VERSION var: the output variable that contains the string representing the current platform distribution version (if any distribution defined)
#
function(get_Platform_Variables)
  set(oneValueArgs BASENAME INSTANCE PKG_STRING DISTRIBUTION DIST_VERSION OS ARCH ABI TYPE PYTHON)
  cmake_parse_arguments(GET_PLATFORM_VARIABLES "" "${oneValueArgs}" "" ${ARGN} )
  if(GET_PLATFORM_VARIABLES_BASENAME)
    set(${GET_PLATFORM_VARIABLES_BASENAME} ${CURRENT_PLATFORM_BASE} PARENT_SCOPE)
  endif()
  if(GET_PLATFORM_VARIABLES_INSTANCE)
    set(${GET_PLATFORM_VARIABLES_INSTANCE} ${CURRENT_PLATFORM_INSTANCE} PARENT_SCOPE)
  endif()
  if(GET_PLATFORM_VARIABLES_PKG_STRING)
    set(${GET_PLATFORM_VARIABLES_PKG_STRING} ${CURRENT_PACKAGE_STRING} PARENT_SCOPE)
  endif()
  if(GET_PLATFORM_VARIABLES_DISTRIBUTION)
    set(${GET_PLATFORM_VARIABLES_DISTRIBUTION} ${CURRENT_DISTRIBUTION} PARENT_SCOPE)
  endif()
  if(GET_PLATFORM_VARIABLES_DIST_VERSION)
    set(${GET_PLATFORM_VARIABLES_DIST_VERSION} ${CURRENT_DISTRIBUTION_VERSION} PARENT_SCOPE)
  endif()
  if(GET_PLATFORM_VARIABLES_TYPE)
  	set(OK TRUE)
  	set(${GET_PLATFORM_VARIABLES_TYPE} ${CURRENT_PLATFORM_TYPE} PARENT_SCOPE)
  endif()
  if(GET_PLATFORM_VARIABLES_OS)
  	set(OK TRUE)
  	set(${GET_PLATFORM_VARIABLES_OS} ${CURRENT_PLATFORM_OS} PARENT_SCOPE)
  endif()
  if(GET_PLATFORM_VARIABLES_ARCH)
  	set(OK TRUE)
  	set(${GET_PLATFORM_VARIABLES_ARCH} ${CURRENT_PLATFORM_ARCH} PARENT_SCOPE)
  endif()
  if(GET_PLATFORM_VARIABLES_ABI)
  	set(OK TRUE)
    set(${GET_PLATFORM_VARIABLES_ABI} ${CURRENT_PLATFORM_ABI} PARENT_SCOPE)
  endif()
  if(GET_PLATFORM_VARIABLES_PYTHON)
  		set(OK TRUE)
  		set(${GET_PLATFORM_VARIABLES_PYTHON} ${CURRENT_PYTHON} PARENT_SCOPE)
  endif()
endfunction(get_Platform_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_A_System_Reference_Path| replace:: ``is_A_System_Reference_Path``
#  .. _is_A_System_Reference_Path:
#
#  is_A_System_Reference_Path
#  --------------------------
#
#   .. command:: is_A_System_Reference_Path(path IS_SYSTEM)
#
#     Tells wether the path is a system path where are located binaries.
#
#     :path: the path to check
#
#     :IS_SYSTEM: the output variable that is TRUE if path is a system reference path, FALSE otherwise
#
function(is_A_System_Reference_Path path IS_SYSTEM)
  set(all_default_path)
  list(APPEND all_default_path ${CMAKE_C_IMPLICIT_LINK_DIRECTORIES} ${CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES})
  if(all_default_path)
    list(REMOVE_DUPLICATES all_default_path)
    foreach(a_path IN LISTS all_default_path)
      if(a_path STREQUAL path)#OK path is in default path => remove it
        set(${IS_SYSTEM} TRUE PARENT_SCOPE)
        return()
      endif()
    endforeach()
  endif()
  set(${IS_SYSTEM} FALSE PARENT_SCOPE)
endfunction(is_A_System_Reference_Path)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_A_System_Include_Path| replace:: ``is_A_System_Include_Path``
#  .. _is_A_System_Include_Path:
#
#  is_A_System_Include_Path
#  ------------------------
#
#   .. command:: is_A_System_Include_Path(IS_SYSTEM path)
#
#     Tells wether a path is a system include folder.
#
#     :path: the path to check
#
#     :IS_SYSTEM: the output variable that is TRUE if path is a system include path, FALSE otherwise
#
function(is_A_System_Include_Path IS_SYSTEM path)
  set(all_default_path ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES} ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
  if(all_default_path)
    get_filename_component(RESOLVED_PATH ${path} REALPATH)#Note: resolve the path if it is a symlink to ensure it does not point to a system folder
    list(REMOVE_DUPLICATES all_default_path)
    foreach(a_path IN LISTS all_default_path)
      if(a_path STREQUAL RESOLVED_PATH)#OK path is in default path => remove it
        set(${IS_SYSTEM} TRUE PARENT_SCOPE)
        return()
      endif()
    endforeach()
  endif()
  set(${IS_SYSTEM} FALSE PARENT_SCOPE)
endfunction(is_A_System_Include_Path)

#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_Info_From_Platform| replace:: ``extract_Info_From_Platform``
#  .. _extract_Info_From_Platform:
#
#  extract_Info_From_Platform
#  --------------------------
#
#   .. command:: extract_Info_From_Platform(RES_TYPE RES_ARCH RES_OS RES_ABI RES_INSTANCE RES_PLATFORM_BASE name)
#
#     Extract the different elements of a platform name (e.g. x86_64_linux_stdc++11) to get corresponding information.
#
#     :name: the name of the platform
#
#     :RES_TYPE: the output variable containing processor architecture type (e.g. x86)
#     :RES_ARCH: the output variable containing processor registry size (e.g. 32 or 64)
#     :RES_OS: the output variable containing  kernel name (e.g. linux) or empty string if the target platform has no kernel (e.g. microcontroller)
#     :RES_ABI: the output variable containing abi name (e.g. stdc++, stdc++11, c++, msvc, etc.)
#     :RES_INSTANCE: the output variable containing platform instance name (may be empty in case of a valid match)
#     :RES_PLATFORM_BASE: the output variable containing platform base name (in case no instance is specified it is == name)
#
function(extract_Info_From_Platform RES_TYPE RES_ARCH RES_OS RES_ABI RES_INSTANCE RES_PLATFORM_BASE name)
  if(name MATCHES "^(.+)__(.+)__$")#there is an instance name
    set(platform_name ${CMAKE_MATCH_1})
    set(instance_name ${CMAKE_MATCH_2})# this is a custom platform name used for CI and binary deployment
  else()
    set(platform_name ${name})
    set(instance_name)
  endif()
	string(REGEX REPLACE "^([^_]+)_([^_]+)_([^_]+)_([^_]+)$" "\\1;\\2;\\3;\\4" list_of_properties ${platform_name})
  if(list_of_properties STREQUAL platform_name)#if no replacement, try without kernel name
    string(REGEX REPLACE "^([^_]+)_([^_]+)_([^_]+)$" "\\1;\\2;\\3" list_of_properties ${platform_name})
    if(list_of_properties STREQUAL platform_name)#bad name => not allowed
    	set(${RES_TYPE} PARENT_SCOPE)
    	set(${RES_ARCH} PARENT_SCOPE)
    	set(${RES_OS} PARENT_SCOPE)
    	set(${RES_ABI} PARENT_SCOPE)
    	set(${RES_INSTANCE} PARENT_SCOPE)
    	set(${RES_PLATFORM_BASE} PARENT_SCOPE)
    else()
      list(GET list_of_properties 2 abi)
    endif()
  else()
  	list(GET list_of_properties 2 os)
  	list(GET list_of_properties 3 abi)
  endif()

	list(GET list_of_properties 0 type)
	list(GET list_of_properties 1 arch)
	set(${RES_TYPE} ${type} PARENT_SCOPE)
	set(${RES_ARCH} ${arch} PARENT_SCOPE)
	set(${RES_OS} ${os} PARENT_SCOPE)
  set(${RES_ABI} ${abi} PARENT_SCOPE)
  set(${RES_INSTANCE} ${instance_name} PARENT_SCOPE)
  set(${RES_PLATFORM_BASE} ${platform_name} PARENT_SCOPE)
endfunction(extract_Info_From_Platform)

#############################################################
################ string handling utilities ##################
#############################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |escape_Guillemet_From_String| replace:: ``escape_Guillemet_From_String``
#  .. _escape_Guillemet_From_String:
#
#  escape_Guillemet_From_String
#  ----------------------------
#
#   .. command:: escape_Guillemet_From_String(str_var)
#
#    Update the input string in such a way that escaped guillemets are preserved if the value of the string is evaluated
#
#     :str_var: the input/output string variable that may contain guillemet characters to escape.
#
function(escape_Guillemet_From_String str_var)
  if(${str_var})
    string(REPLACE "\"" "\\\"" ret_str "${${str_var}}")
    set(${str_var} ${ret_str} PARENT_SCOPE)
  endif()
endfunction(escape_Guillemet_From_String)

#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_Component_And_Package_From_Dependency_String| replace:: ``extract_Component_And_Package_From_Dependency_String``
#  .. _extract_Component_And_Package_From_Dependency_String:
#
#  extract_Component_And_Package_From_Dependency_String
#  ----------------------------------------------------
#
#   .. command:: extract_Component_And_Package_From_Dependency_String(RES_COMP RES_PACK dependency_string)
#
#    Get the name of component and package from a dependency string. Dependencies strinsg follow the poattern: [<package_name>/]<component_name>
#
#     :dependency_string: the dependency string to parse.
#
#     :RES_COMP: the output variable that contains the name of the component.
#     :RES_PACK: the output variable that contains the name of the package, if any specified, or that is empty otherwise.
#
function(extract_Component_And_Package_From_Dependency_String RES_COMP RES_PACK dependency_string)
if(dependency_string MATCHES "^([^/]+)/(.+)$") #it matches => this is a dependency string with package expression using / symbol
  list(GET RESULT_LIST 0 package)
  list(GET RESULT_LIST 1 component)
  set(${RES_COMP} ${CMAKE_MATCH_2} PARENT_SCOPE)
  set(${RES_PACK} ${CMAKE_MATCH_1} PARENT_SCOPE)
else()#this is a dependency that only specifies the name of the component
  set(${RES_PACK} PARENT_SCOPE)
  set(${RES_COMP} ${dependency_string} PARENT_SCOPE)
endif()
endfunction(extract_Component_And_Package_From_Dependency_String)

#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_All_Words| replace:: ``extract_All_Words``
#  .. _extract_All_Words:
#
#  extract_All_Words
#  -----------------
#
#   .. command:: extract_All_Words(the_string separator ALL_WORDS_IN_LIST)
#
#    Split a string into a list of words.
#
#     :the_string: the the_string to split.
#     :separator: the separator character used to split the string.
#
#     :ALL_WORDS_IN_LIST: the output variable containg the list of words
#
function(extract_All_Words the_string separator ALL_WORDS_IN_LIST)
set(res "")
string(REPLACE "${separator}" ";" res "${the_string}")
set(${ALL_WORDS_IN_LIST} ${res} PARENT_SCOPE)
endfunction(extract_All_Words)

#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_All_Words_From_Path| replace:: ``extract_All_Words_From_Path``
#  .. _extract_All_Words_From_Path:
#
#  extract_All_Words_From_Path
#  ---------------------------
#
#   .. command:: extract_All_Words_From_Path(name_with_slash ALL_WORDS_IN_LIST)
#
#    Split a path into a list of words.
#
#     :name_with_slash: the path expressed as a CMake path (with / separator)
#
#     :ALL_WORDS_IN_LIST: the output variable containg the list of words from the path
#
function(extract_All_Words_From_Path name_with_slash ALL_WORDS_IN_LIST)
set(res "")
string(REPLACE "/" ";" res "${name_with_slash}")
set(${ALL_WORDS_IN_LIST} ${res} PARENT_SCOPE)
endfunction(extract_All_Words_From_Path)

#.rst:
#
# .. ifmode:: internal
#
#  .. |fill_String_From_List| replace:: ``fill_String_From_List``
#  .. _fill_String_From_List:
#
#  fill_String_From_List
#  ---------------------
#
#   .. command:: fill_String_From_List(RES_STRING input_list separator)
#
#    Create a string from a list using a separator string.
#
#     :input_list: the variable containing the list of words.
#     :separator: the string used as a delimiter between words.
#
#     :RES_STRING: the output variable containg the resulting string
#
function(fill_String_From_List RES_STRING input_list separator)
set(res "")
foreach(element IN LISTS ${input_list})
  if(res STREQUAL "")
    set (res "${element}")
  else()
   set(res "${res}${separator}${element}")
 endif()
endforeach()
string(STRIP "${res}" res_finished)
set(${RES_STRING} ${res_finished} PARENT_SCOPE)
endfunction(fill_String_From_List)


#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_Package_Namespace_From_SSH_URL| replace:: ``extract_Package_Namespace_From_SSH_URL``
#  .. _extract_Package_Namespace_From_SSH_URL:
#
#  extract_Package_Namespace_From_SSH_URL
#  --------------------------------------
#
#   .. command:: extract_Package_Namespace_From_SSH_URL(url package NAMESPACE SERVER_ADDRESS EXTENSION)
#
#    Extract useful information (for PID) from the git url of a package repository.
#
#     :url: the git URL.
#     :package: the name of the package.
#
#     :NAMESPACE: output variable containing the namespace of the repository
#     :SERVER_ADDRESS: output variable containing the address of the git repository server
#     :EXTENSION: output variable containing the name of the package extension. This later information is used to get the name of the lone static site for a package.
#
function(extract_Package_Namespace_From_SSH_URL url package NAMESPACE SERVER_ADDRESS EXTENSION)
set(CMAKE_MATCH_3)#reset the last match
if(url MATCHES "^([^@]+@[^:]+):([^/]+)/${package}(\\.site|-site|\\.pages|-pages)?\\.git$") #match found
	set(${NAMESPACE} ${CMAKE_MATCH_2} PARENT_SCOPE)
	set(${SERVER_ADDRESS} ${CMAKE_MATCH_1} PARENT_SCOPE)
  set(${EXTENSION} ${CMAKE_MATCH_3} PARENT_SCOPE)
else()
	set(${NAMESPACE} PARENT_SCOPE)
	set(${SERVER_ADDRESS} PARENT_SCOPE)
	set(${EXTENSION} PARENT_SCOPE)
endif()
endfunction(extract_Package_Namespace_From_SSH_URL)

#.rst:
#
# .. ifmode:: internal
#
#  .. |format_PID_Identifier_Into_Markdown_Link| replace:: ``format_PID_Identifier_Into_Markdown_Link``
#  .. _format_PID_Identifier_Into_Markdown_Link:
#
#  format_PID_Identifier_Into_Markdown_Link
#  ----------------------------------------
#
#   .. command:: format_PID_Identifier_Into_Markdown_Link(RES_LINK function_name)
#
#    Transform the name of a function into a name that can be exploited in markdown to target corresponding function symbol (used for cross referencing functions).
#
#     :function_name: the name of the function.
#
#     :RES_LINK: the output variable containing the resulting markdown link string
#
function(format_PID_Identifier_Into_Markdown_Link RES_LINK function_name)
string(REPLACE "_" "" RES_STR ${function_name})#simply remove underscores
string(REPLACE " " "-" FINAL_STR ${RES_STR})#simply remove underscores
set(${RES_LINK} ${FINAL_STR} PARENT_SCOPE)
endfunction(format_PID_Identifier_Into_Markdown_Link)

#.rst:
#
# .. ifmode:: internal
#
#  .. |normalize_Version_String| replace:: ``normalize_Version_String``
#  .. _normalize_Version_String:
#
#  normalize_Version_String
#  ------------------------
#
#   .. command:: normalize_Version_String(input_version NORMALIZED_VERSION_STRING)
#
#    Normalize a version string so that it always match the pattern: major.minor.patch
#
#     :input_version: the version to normalize, with dotted notation
#
#     :NORMALIZED_VERSION_STRING: the output variable containing the normalized version string
#
function(normalize_Version_String input_version NORMALIZED_VERSION_STRING)
	get_Version_String_Numbers(${input_version} major minor patch)
	set(VERSION_STR "${major}.")
	if(minor)
		set(VERSION_STR "${VERSION_STR}${minor}.")
	else()
		set(VERSION_STR "${VERSION_STR}0.")
	endif()
	if(patch)
		set(VERSION_STR "${VERSION_STR}${patch}")
	else()
		set(VERSION_STR "${VERSION_STR}0")
	endif()
	set(${NORMALIZED_VERSION_STRING} ${VERSION_STR} PARENT_SCOPE)
endfunction(normalize_Version_String)


#.rst:
#
# .. ifmode:: internal
#
#  .. |sort_Version_List| replace:: ``sort_Version_List``
#  .. _sort_Version_List:
#
#  sort_Version_List
#  -----------------
#
#   .. command:: sort_Version_List(list_var)
#
#    Sort a list from lower to greater version.
#
#     :list_var: the input/output variable containing the list to sort.
#
function(sort_Version_List list_var)
  if(NOT ${list_var})
    return()#return if input list is empty
  endif()
  set(sorted_list)
  while(${input_list_var})
    list(GET elements_to_sort 0 curr_min_version)
    foreach(comp_version IN LISTS ${input_list_var})
      if(comp_version VERSION_LESS curr_min_version)
        set(curr_min_version ${comp_version})
      endif()
    endforeach()
    list(REMOVE_ITEM ${input_list_var} ${curr_min_version})
    list(APPEND sorted_list ${curr_min_version})
  endwhile()
  set(${input_list_var} ${sorted_list} PARENT_SCOPE)#reset content of output
endfunction(sort_Version_List)

#############################################################
################ filesystem management utilities ############
#############################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Src_File_Updated| replace:: ``is_Src_File_Updated``
#  .. _is_Src_File_Updated:
#
#  is_Src_File_Updated
#  ---------------------------
#
#   .. command:: is_Src_File_Updated(NEWER installed_file src_file)
#
#     Check whether a source file has been updated since last modification of another installed file.
#
#     :installed_file: the path to the installed file.
#     :src_file: the path to the source file whose last modification date is tested
#
#     :NEWER: the output variable tha is TRUE if source file has been updated since last modification of installed file, FALSE otherwise.
#
function(is_Src_File_Updated NEWER installed_file src_file)
if(NOT EXISTS ${installed_file})
  set(${NEWER} TRUE PARENT_SCOPE)
endif()
set(${NEWER} FALSE PARENT_SCOPE)
if(${src_file} IS_NEWER_THAN ${installed_file})#not sure file1 is strictly newer they can be of same date
  #they can have same date
  file(TIMESTAMP ${src_file} SRC_TIME "%s" UTC)
  file(TIMESTAMP ${installed_file} INSTALL_TIME "%s" UTC)
  if(SRC_TIME GREATER INSTALL_TIME)
    set(${NEWER} TRUE PARENT_SCOPE)
  endif()
endif()
return()
endfunction(is_Src_File_Updated)

#.rst:
#
# .. ifmode:: internal
#
#  .. |make_Empty_Folder| replace:: ``make_Empty_Folder``
#  .. _make_Empty_Folder:
#
#  make_Empty_Folder
#  -----------------
#
#   .. command:: make_Empty_Folder(path)
#
#    clear the content of an existing folder of create it.
#
#     :path: the path to the folder
#
function(make_Empty_Folder path)
if(path)
  if(EXISTS ${path} AND IS_DIRECTORY ${path})
    file(GLOB DIR_CONTENT "${path}/*")
    if(DIR_CONTENT)#not already empty
      file(REMOVE_RECURSE ${path})
      file(MAKE_DIRECTORY ${path})
    endif()
  else()
    file(MAKE_DIRECTORY ${path})
  endif()
endif()
endfunction(make_Empty_Folder)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Symlink| replace:: ``create_Symlink``
#  .. _create_Symlink:
#
#  create_Symlink
#  --------------
#
#   .. command:: create_Symlink(path_to_old path_to_new)
#
#    Create a symlink to a filesystem resource (file or folder).
#
#     :path_to_old: the path to create a symlink for
#     :path_to_new: the path of the resulting symlink
#
function(create_Symlink path_to_old path_to_new)
    set(oneValueArgs WORKING_DIR)
    cmake_parse_arguments(OPT "" "${oneValueArgs}" "" ${ARGN} )
    if(WIN32)
        string(REGEX REPLACE "/" "\\\\" path_to_old ${path_to_old})
        string(REGEX REPLACE "/" "\\\\" path_to_new ${path_to_new})
        if(OPT_WORKING_DIR)
            string(REGEX REPLACE "/" "\\\\" OPT_WORKING_DIR ${OPT_WORKING_DIR})
        endif()

        # check if target is a directory or a file to pass to proper argument to mklink
        if(IS_DIRECTORY ${path_to_old})
            set(mklink_option "/J")
          else()
            set(mklink_option "/H")
        endif()
    endif()

    if(EXISTS ${OPT_WORKING_DIR}/${path_to_new} AND IS_SYMLINK ${OPT_WORKING_DIR}/${path_to_new})
        #remove the existing symlink
        file(REMOVE ${OPT_WORKING_DIR}/${path_to_new})
    endif()

    #1) first create the folder containing symlinks if it does not exist
    get_filename_component(containing_folder ${path_to_new} DIRECTORY)
    if(NOT EXISTS ${containing_folder})
      file(MAKE_DIRECTORY ${containing_folder})
    endif()
    #2) then generate symlinks in this folder
    if(WIN32)
        if(OPT_WORKING_DIR)
            execute_process(
                COMMAND cmd.exe /c mklink ${mklink_option} ${path_to_new} ${path_to_old}
                WORKING_DIRECTORY ${OPT_WORKING_DIR}
                OUTPUT_QUIET
                ERROR_QUIET
            )
        else()
            execute_process(
                COMMAND cmd.exe /c mklink ${mklink_option} ${path_to_new} ${path_to_old}
                OUTPUT_QUIET
                ERROR_QUIET
            )
        endif()
    else()
        if(OPT_WORKING_DIR)
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E create_symlink ${path_to_old} ${path_to_new}
                WORKING_DIRECTORY ${OPT_WORKING_DIR}
            )
        else()
            execute_process(
                COMMAND ${CMAKE_COMMAND} -E create_symlink ${path_to_old} ${path_to_new}
            )
        endif()
    endif()
endfunction(create_Symlink)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Runtime_Symlink| replace:: ``create_Runtime_Symlink``
#  .. _create_Runtime_Symlink:
#
#  create_Runtime_Symlink
#  ----------------------
#
#   .. command:: create_Runtime_Symlink(path_to_target path_to_container_folder rpath_sub_folder)
#
#    Create a symlink for a runtime resource of a component.
#
#     :path_to_target: the target runtime resource to symlink.
#     :path_to_container_folder: the path to the package .rpath folder.
#     :rpath_sub_folder: the path to relative to the .rpath folder of the component that use the symlink to access its runtime resources.
#
function(create_Runtime_Symlink path_to_target path_to_container_folder rpath_sub_folder)
#first creating the path where to put symlinks if it does not exist
set(RUNTIME_DIR ${path_to_container_folder}/${rpath_sub_folder})
get_filename_component(A_FILE ${path_to_target} NAME)
#second creating the symlink
create_Symlink(${path_to_target} ${RUNTIME_DIR}/${A_FILE})
endfunction(create_Runtime_Symlink)

#.rst:
#
# .. ifmode:: internal
#
#  .. |install_Runtime_Symlink| replace:: ``install_Runtime_Symlink``
#  .. _install_Runtime_Symlink:
#
#  install_Runtime_Symlink
#  -----------------------
#
#   .. command:: install_Runtime_Symlink(path_to_target path_to_rpath_folder rpath_sub_folder)
#
#    Install symlink for a runtime resource of a component.
#
#     :path_to_target: the target runtime resource to symlink.
#     :path_to_rpath_folder: the path to the package .rpath folder.
#     :rpath_sub_folder: the path to relative to the .rpath folder of the component that use the symlink to access its runtime resources.
#
function(install_Runtime_Symlink path_to_target path_to_rpath_folder rpath_sub_folder)
  get_filename_component(A_FILE "${path_to_target}" NAME)
	set(FULL_RPATH_DIR ${path_to_rpath_folder}/${rpath_sub_folder})
	install(DIRECTORY DESTINATION ${FULL_RPATH_DIR}) #create the folder that will contain symbolic links to runtime resources used by the component (will allow full relocation of components runtime dependencies at install time)
  if(WIN32)
      string(REGEX REPLACE "/" "\\\\\\\\" W32_PATH_FILE ${FULL_RPATH_DIR}/${A_FILE})
      string(REGEX REPLACE "/" "\\\\\\\\" W32_PATH_TARGET ${path_to_target})
  endif()
	install(CODE "
                    list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake/api)
                    include(PID_Utils_Functions NO_POLICY_SCOPE)
                    message(\"-- Installing: ${CMAKE_INSTALL_PREFIX}/${FULL_RPATH_DIR}/${A_FILE}\")
                    create_Symlink(${path_to_target} ${FULL_RPATH_DIR}/${A_FILE} WORKING_DIR ${CMAKE_INSTALL_PREFIX})
	")# creating links "on the fly" when installing
endfunction(install_Runtime_Symlink)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_PID_Compatible_Rpath| replace:: ``set_PID_Compatible_Rpath``
#  .. _set_PID_Compatible_Rpath:
#
#  set_PID_Compatible_Rpath
#  ------------------------
#
#   .. command:: set_PID_Compatible_Rpath(package version)
#
#    Set the rpath of a binary with a PID compliant format
#
#      :path_to_binary: the path to the binary file to modify
#
function(set_PID_Compatible_Rpath path_to_binary)
	if(CMAKE_HOST_APPLE)#TODO check with APPLE as I am not sure of what needs to be done
		get_filename_component(RES_NAME ${path_to_binary} NAME)
		execute_process(COMMAND ${RPATH_UTILITY} -id "@rpath/${RES_NAME}" ${path_to_binary}
		                WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
									  ERROR_QUIET OUTPUT_QUIET)
		execute_process(COMMAND ${RPATH_UTILITY} -add_rpath "@loader_path/../.rpath" ${path_to_binary}
										WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
									  ERROR_QUIET OUTPUT_QUIET)
		execute_process(COMMAND ${RPATH_UTILITY} -add_rpath "@loader_path/../lib" ${path_to_binary}
										WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
									  ERROR_QUIET OUTPUT_QUIET)
		execute_process(COMMAND ${RPATH_UTILITY} -add_rpath "@loader_path" ${path_to_binary}
										WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
									  ERROR_QUIET OUTPUT_QUIET)
	else()
		set(rpath "\$ORIGIN/../.rpath:\$ORIGIN/../lib:\$ORIGIN")
		execute_process(COMMAND ${RPATH_UTILITY} --force-rpath --set-rpath "${rpath}" ${path_to_binary}
										WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
									  ERROR_QUIET OUTPUT_QUIET)
	endif()
endfunction(set_PID_Compatible_Rpath)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Directory_Exists| replace:: ``check_Directory_Exists``
#  .. _check_Directory_Exists:
#
#  check_Directory_Exists
#  ----------------------
#
#   .. command:: check_Directory_Exists(IS_EXISTING path)
#
#    Tell whether the given path is a folder path and it exists on filesystem.
#
#     :path: the path to check
#
#     :IS_EXISTING: the output variable set to TRUE is the directory exist, FALSE otherwise.
#
function (check_Directory_Exists IS_EXISTING path)
if(	EXISTS "${path}"
	AND IS_DIRECTORY "${path}")
	set(${IS_EXISTING} TRUE PARENT_SCOPE)
	return()
endif()
set(${IS_EXISTING} FALSE PARENT_SCOPE)
endfunction(check_Directory_Exists)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Required_Directories_Exist| replace:: ``check_Required_Directories_Exist``
#  .. _check_Required_Directories_Exist:
#
#  check_Required_Directories_Exist
#  --------------------------------
#
#   .. command:: check_Required_Directories_Exist(PROBLEM type folder)
#
#    Tell whether the given path is a folder path and it exists on filesystem.
#
#     :type: the type of component for which the adequate folders are checked. May take values : STATIC, SHARED, HEADER, MODULE, EXAMPLE, APPLICATION, TEST or PYTHON.
#     :folder: the name of the folder where to find code related to the component.
#
#     :PROBLEM: the output variable containing the message if any problem detected.
#
function (check_Required_Directories_Exist PROBLEM type folder)
	#checking directory containing headers
	set(${PROBLEM} PARENT_SCOPE)
	if(type STREQUAL "STATIC" OR type STREQUAL "SHARED" OR type STREQUAL "HEADER")
		check_Directory_Exists(EXIST  ${CMAKE_SOURCE_DIR}/include/${folder})
		if(NOT EXIST)
			set(${PROBLEM} "No folder named ${folder} in the include folder of the project" PARENT_SCOPE)
			return()
		endif()
	endif()
	if(type STREQUAL "STATIC" OR type STREQUAL "SHARED" OR type STREQUAL "MODULE"
		OR type STREQUAL "APP" OR type STREQUAL "EXAMPLE" OR type STREQUAL "TEST")
		check_Directory_Exists(EXIST  ${CMAKE_CURRENT_SOURCE_DIR}/${folder})
		if(NOT EXIST)
			set(${PROBLEM} "No folder named ${folder} in folder ${CMAKE_CURRENT_SOURCE_DIR}" PARENT_SCOPE)
			return()
		endif()
	elseif(type STREQUAL "PYTHON")
		check_Directory_Exists(EXIST ${CMAKE_CURRENT_SOURCE_DIR}/script/${folder})
		if(NOT EXIST)
			set(${PROBLEM} "No folder named ${folder} in folder ${CMAKE_CURRENT_SOURCE_DIR}/script" PARENT_SCOPE)
			return()
		endif()
	endif()
endfunction(check_Required_Directories_Exist)


#
# .. ifmode:: internal
#
#  .. |copy_Package_Install_Folder| replace:: ``copy_Package_Install_Folder``
#  .. _copy_Package_Install_Folder:
#
#  copy_Package_Install_Folder
#  ---------------------------
#
#   .. command:: copy_Package_Install_Folder(ERROR source destination working_dir)
#
#    Copy content of a package install folder into the folder. Manages invalid symlinks (like those in the rpath folder)
#
#      :source: The folder whose content is coped.
#      :destination: the folder in which content is copied
#      :working_dir: the working directory for copy operation.
#
#      :ERROR: the output variable that contains an error if operation failed.
#
function(copy_Package_Install_Folder ERROR source destination working_dir)
  set(${ERROR} PARENT_SCOPE)
  if(NOT EXISTS ${destination})
    file(MAKE_DIRECTORY ${destination})
  endif()
  if(EXISTS ${source}/.rpath)#remove any symlink in this folder as they will be invalid after copy and may invalidate the copy operation
    file(REMOVE_RECURSE ${source}/.rpath)
  endif()
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${source} ${destination}
    WORKING_DIRECTORY ${working_dir}
  ERROR_VARIABLE error_out OUTPUT_QUIET)
  set(${ERROR} ${error_out} PARENT_SCOPE)
endfunction(copy_Package_Install_Folder)

#############################################################
################ Management of version information ##########
#############################################################


#.rst:
#
# .. ifmode:: internal
#
#  .. |parse_Version_Argument| replace:: ``parse_Version_Argument``
#  .. _parse_Version_Argument:
#
#  parse_Version_Argument
#  ----------------------
#
#   .. command:: parse_Version_Argument(string_to_parse VERSION FORMAT)
#
#    Parse a string that is a version argument passed to PID. This string can be a sequence of digits or a dotted notation formatted string.
#
#     :string_to_parse: the version string to parse that has been written by an end user.
#
#     :VERSION: the output variable containing the list of version digits.
#     :FORMAT: the output variable that is set to DIGITS if string_to_parse was given by a sequence of digits, set to DOTTED_STRING if string_to_parse was written with dotted notation or empty otherwise (bad version argument given).
#
function(parse_Version_Argument string_to_parse VERSION FORMAT)
  unset(CMAKE_MATCH_3)
  if(string_to_parse MATCHES "^[ \t]*([0-9]+)[ \t]+([0-9]+)[ \t]*([0-9]+)?[ \t]*$")#the replacement took place so the version is defined with 2 ou 3 digits
    if(CMAKE_MATCH_3)
      set(${VERSION} "${CMAKE_MATCH_1};${CMAKE_MATCH_2};${CMAKE_MATCH_3}" PARENT_SCOPE)#only taking the last instruction since it shadows previous ones
    else()
      set(${VERSION} "${CMAKE_MATCH_1};${CMAKE_MATCH_2}" PARENT_SCOPE)#only taking the last instruction since it shadows previous ones
    endif()
    set(${FORMAT} "DIGITS" PARENT_SCOPE)#also specify it is under digits format
    return()
  endif()
  #OK so maybe it is under dotted notation
  unset(CMAKE_MATCH_3)
  unset(CMAKE_MATCH_4)
  if(string_to_parse MATCHES "^[ \t]*([0-9]+)\\.([0-9]+)(\\.([0-9]+))?[ \t]*$")#the replacement took place so the version is defined with a 3 digits dotted notation
    if(CMAKE_MATCH_4)
      set(${VERSION} "${CMAKE_MATCH_1};${CMAKE_MATCH_2};${CMAKE_MATCH_4}" PARENT_SCOPE)#only taking the last instruction since it shadows previous ones
    else()
      set(${VERSION} "${CMAKE_MATCH_1};${CMAKE_MATCH_2}" PARENT_SCOPE)#only taking the last instruction since it shadows previous ones
    endif()
    set(${FORMAT} "DOTTED_STRING" PARENT_SCOPE)#also specify it has been found under dotted notation format
    return()
  endif()
  set(${VERSION} PARENT_SCOPE)
  set(${FORMAT} PARENT_SCOPE)
endfunction(parse_Version_Argument)

#.rst:
#
# .. ifmode:: internal
#
#  .. |parse_Package_Dependency_Version_Arguments| replace:: ``parse_Package_Dependency_Version_Arguments``
#  .. _parse_Package_Dependency_Version_Arguments:
#
#  parse_Package_Dependency_Version_Arguments
#  ------------------------------------------
#
#   .. command:: parse_Package_Dependency_Version_Arguments(args RES_VERSION RES_EXACT RES_UNPARSED)
#
#    Parse a version constraint expression and extract corresponding version number and exactness attribute.
#
#     :args: arguments to parse, that may contains version constraints expressions.
#
#     :RES_VERSION: the output variable containing the first version constraint detected, if any.
#     :RES_CONSTRAINT: the output variable that contains the constraint type on version constraint expression (EXACT, TO or FROM), or that is empty if no additionnal constraint is given.
#     :RES_UNPARSED: the output variable containing the remaining expressions after the first version constraint expression detected.
#
function(parse_Package_Dependency_Version_Arguments args RES_VERSION RES_CONSTRAINT RES_UNPARSED)
set(expr_string)
if(args MATCHES "^;?(EXACT;|FROM;|TO;)?(VERSION;[^;]+)(;.+)?$")
  set(expr_string ${CMAKE_MATCH_1}${CMAKE_MATCH_2})
  set(${RES_UNPARSED} ${CMAKE_MATCH_3} PARENT_SCOPE)
endif()
if(expr_string)#version expression has been found => parse it
	set(options EXACT FROM TO)
	set(oneValueArg VERSION)
	cmake_parse_arguments(PARSE_PACKAGE_ARGS "${options}" "${oneValueArg}" "" ${expr_string})
	set(${RES_VERSION} ${PARSE_PACKAGE_ARGS_VERSION} PARENT_SCOPE)
  if(PARSE_PACKAGE_ARGS_EXACT)
	   set(${RES_CONSTRAINT} EXACT PARENT_SCOPE)
  elseif(PARSE_PACKAGE_ARGS_FROM)
    set(${RES_CONSTRAINT} FROM PARENT_SCOPE)
  elseif(PARSE_PACKAGE_ARGS_TO)
    set(${RES_CONSTRAINT} TO PARENT_SCOPE)
  endif()
else()
	set(${RES_VERSION} PARENT_SCOPE)
	set(${RES_CONSTRAINT} PARENT_SCOPE)
	set(${RES_UNPARSED} "${args}" PARENT_SCOPE)
endif()
endfunction(parse_Package_Dependency_Version_Arguments)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Versions_In_Interval| replace:: ``get_Versions_In_Interval``
#  .. _get_Versions_In_Interval:
#
#  get_Versions_In_Interval
#  ------------------------
#
#   .. command:: get_Versions_In_Interval(IN_VERSIONS all_versions from_version to_version)
#
#   From a list of versions collect all those that are in an interval [FROM...TO].
#
#     :all_versions: parent_scope variable containing the list of all versions.
#     :from_version: lower bound of the version interval.
#     :to_version: upper bound of the version interval.
#
#     :IN_VERSIONS: the output variable containing the list of versions in the interval from...to.
#
function(get_Versions_In_Interval IN_VERSIONS all_versions from_version to_version)
set(temp_list ${${all_versions}})
set(result_list)
  foreach(element IN LISTS temp_list)
    if(element VERSION_GREATER_EQUAL from_version
    AND element VERSION_LESS_EQUAL to_version)
      list(APPEND result_list ${element})
    endif()
  endforeach()
set(${IN_VERSIONS} ${result_list} PARENT_SCOPE)
endfunction(get_Versions_In_Interval)

#.rst:
#
# .. ifmode:: internal
#
#  .. |collect_Versions_From_Constraints| replace:: ``collect_Versions_From_Constraints``
#  .. _collect_Versions_From_Constraints:
#
#  collect_Versions_From_Constraints
#  ---------------------------------
#
#   .. command:: collect_Versions_From_Constraints(INTERVAL_VERSIONS package from_version to_version)
#
#   Collect all versions of a package that are in an interval [FROM...TO].
#
#     :package: name of the package for which versions in interval are computed.
#     :from_version: lower bound of the version interval.
#     :to_version: upper bound of the version interval.
#
#     :INTERVAL_VERSIONS: the output variable containing the list of version in the interval from...to.
#
function(collect_Versions_From_Constraints INTERVAL_VERSIONS package from_version to_version)
get_Package_Type(${package} PACK_TYPE)
set(${INTERVAL_VERSIONS} PARENT_SCOPE)

#get the official known version (those published)
if(NOT DEFINED ${package}_PID_KNOWN_VERSION)
  set(DO_NOT_FIND_${package} TRUE)
  include_Find_File(${package})#TODO check if no real problem when find file is NOT found
  unset(DO_NOT_FIND_${package})
endif()
set(ALL_VERSIONS ${${package}_PID_KNOWN_VERSION})

if(ALL_VERSIONS)
  list(REMOVE_DUPLICATES ALL_VERSIONS)
  #some corrective actions before calling functions to get version in interval
  if(NOT from_version)
    set(from_version 0.0.0)
  endif()
  if(NOT to_version)
    set(to_version 99999.99999.99999)
  endif()
  get_Versions_In_Interval(IN_VERSIONS ALL_VERSIONS ${from_version} ${to_version})
  set(${INTERVAL_VERSIONS} ${IN_VERSIONS} PARENT_SCOPE)
endif()
endfunction(collect_Versions_From_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |parse_Package_Dependency_All_Version_Arguments| replace:: ``parse_Package_Dependency_All_Version_Arguments``
#  .. _parse_Package_Dependency_All_Version_Arguments:
#
#  parse_Package_Dependency_All_Version_Arguments
#  ----------------------------------------------
#
#   .. command:: parse_Package_Dependency_All_Version_Arguments(package all_args LIST_OF_VERSIONS EXACT_VERSIONS REMAINING_TO_PARSE PARSE_RESULT)
#
#    Parse an expression that contains version constraints and fill corresponding output variables.
#
#     :package: name of the package used in the current depenency.
#     :all_args: parent scope variable containing string arguments to parse and that may contains version constraints expressions.
#
#     :LIST_OF_VERSIONS: the output variable containing a list of version.
#     :EXACT_VERSIONS: the output variable containing the list of exact versions.
#     :REMAINING_TO_PARSE: the output variable containing the remaining expressions after all version constraint expressions have been parsed.
#     :PARSE_RESULT: the output variable that is TRUE if parsing is OK, FALSE otherwise.
#
function(parse_Package_Dependency_All_Version_Arguments package all_args LIST_OF_VERSIONS EXACT_VERSIONS REMAINING_TO_PARSE PARSE_RESULT)
  set(TO_PARSE "${${all_args}}")
  set(${LIST_OF_VERSIONS} PARENT_SCOPE)
  set(${EXACT_VERSIONS} PARENT_SCOPE)
  set(${PARSE_RESULT} TRUE PARENT_SCOPE)
  set(all_versions)
  set(all_exact_versions)
  set(already_from)
  set(already_to)
	set(RES_VERSION TRUE)#initialize to TRUE to enter the loop
	while(TO_PARSE AND RES_VERSION)
		parse_Package_Dependency_Version_Arguments("${TO_PARSE}" RES_VERSION ADDITIONNAL_CONSTRAINT TO_PARSE)
    if(RES_VERSION)
      if(ADDITIONNAL_CONSTRAINT)
        if(ADDITIONNAL_CONSTRAINT STREQUAL "EXACT")
          if(already_from)
            message("[PID] ERROR : an EXACT VERSION expression cannot be used just after a FROM VERSION expression.")
            set(${PARSE_RESULT} FALSE PARENT_SCOPE)
            return()
          else()
            list(APPEND all_versions ${RES_VERSION})
            list(APPEND all_exact_versions ${RES_VERSION})#simply adding the version to the two returned lists
          endif()
        elseif(ADDITIONNAL_CONSTRAINT STREQUAL "FROM")
          if(already_from)
            message("[PID] ERROR : a FROM VERSION expression cannot be used just after another FROM VERSION expression.")
            set(${PARSE_RESULT} FALSE PARENT_SCOPE)
            return()
          else()
            set(already_from ${RES_VERSION})
            set(already_to)#reset to (if necessay) because a new interval is defined
          endif()
        elseif(ADDITIONNAL_CONSTRAINT STREQUAL "TO")
          if(already_from)#ok we face a normal from...to... expression
            if(already_from VERSION_LESS already_to)
              message("[PID] ERROR : a TO VERSION expression must specify a version that is greater or equal than its preceding FROM VERSION expression.")
              set(${PARSE_RESULT} FALSE PARENT_SCOPE)
              return()
            endif()
            collect_Versions_From_Constraints(RES_INTERVAL_VERSIONS ${package} "${already_from}" "${RES_VERSION}")
            list(APPEND all_versions ${RES_INTERVAL_VERSIONS})
            set(already_from)#reset from... memory to be capable of defining multiple intervals
          elseif(already_to)
            message("[PID] ERROR : a TO VERSION expression cannot be used just after another TO VERSION expression.")
            set(${PARSE_RESULT} FALSE PARENT_SCOPE)
            return()
          else()#to... without from... means "any previous version to"
            collect_Versions_From_Constraints(RES_INTERVAL_VERSIONS ${package} "" "${RES_VERSION}")
            list(APPEND all_versions ${RES_INTERVAL_VERSIONS})
            set(already_to ${RES_VERSION})
          endif()
        endif()
      else()#simple version constraint
        list(APPEND all_versions ${RES_VERSION})
			endif()
		elseif(ADDITIONNAL_CONSTRAINT)#additionnal constraint without VERSION => error !
      message("[PID] ERROR : you cannot use EXACT, FROM or TO keywords without using the VERSION keyword (e.g. EXACT VERSION 3.0.4).")
      set(${PARSE_RESULT} FALSE PARENT_SCOPE)
      return()
    endif()
	endwhile()
  #need to manage the "closing" of a FROM expression
  if(already_from)# collect all known versions from the specified one
    collect_Versions_From_Constraints(RES_INTERVAL_VERSIONS ${package} "${already_from}" "")
    list(APPEND all_versions ${RES_INTERVAL_VERSIONS})
  endif()
  #produce the reply
  if(all_versions)
    list(REVERSE all_versions)
  endif()
  set(${REMAINING_TO_PARSE} ${TO_PARSE} PARENT_SCOPE)
  set(${LIST_OF_VERSIONS} ${all_versions} PARENT_SCOPE)
  set(${EXACT_VERSIONS} ${all_exact_versions} PARENT_SCOPE)
endfunction(parse_Package_Dependency_All_Version_Arguments)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Version_String_Numbers| replace:: ``get_Version_String_Numbers``
#  .. _get_Version_String_Numbers:
#
#  get_Version_String_Numbers
#  --------------------------
#
#   .. command:: get_Version_String_Numbers(version_string major minor patch)
#
#    Parse a version string to extract major, minor and patch numbers.
#
#     :version_string: the version string to parse.
#
#     :MAJOR: the output variable set to the value of version major number.
#     :MINOR: the output variable set to the value of version minor number.
#     :PATCH: the output variable set to the value of version patch number.
#
function(get_Version_String_Numbers version_string MAJOR MINOR PATCH)
if(version_string MATCHES "^([0-9]+)(\\.([0-9]+))?(\\.([0-9]+))?\\.?(.*)$") # version string is well formed with major.minor.patch (at least) format
	set(${MAJOR} ${CMAKE_MATCH_1} PARENT_SCOPE)
	set(${MINOR} ${CMAKE_MATCH_3} PARENT_SCOPE)
	set(${PATCH} ${CMAKE_MATCH_5} PARENT_SCOPE)
else() #not even a number
  set(${MAJOR} PARENT_SCOPE)
  set(${MINOR} PARENT_SCOPE)
  set(${PATCH} PARENT_SCOPE)
endif()
endfunction(get_Version_String_Numbers)

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_Version_Subdirectories| replace:: ``list_Version_Subdirectories``
#  .. _list_Version_Subdirectories:
#
#  list_Version_Subdirectories
#  ---------------------------
#
#   .. command:: list_Version_Subdirectories(RESULT curdir)
#
#    Get the list of all subfolder of a given folder that match the pattern : "major.minor.patch".
#
#     :curdir: the path to a folder that may contain version subfolders.
#
#     :RESULT: the output variable scontaining the list of all version sufolders.
#
function(list_Version_Subdirectories RESULT curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_DIRECTORY ${curdir}/${child} AND "${child}" MATCHES "^[0-9]+\\.[0-9]+\\.[0-9]+$")
			list(APPEND dirlist ${child})
		endif()
	endforeach()
  list(SORT dirlist)
	set(${RESULT} ${dirlist} PARENT_SCOPE)
endfunction(list_Version_Subdirectories)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Greater_Version| replace:: ``get_Greater_Version``
#  .. _get_Greater_Version:
#
#  get_Greater_Version
#  -------------------
#
#   .. command:: get_Greater_Version(GREATER_ONE list_of_versions)
#
#    Get the greater version from a list of versions.
#
#     :list_of_versions: the list of versions.
#
#     :GREATER_ONE: the output variable scontaining the max version found in list.
#
function(get_Greater_Version GREATER_ONE list_of_versions)
  set(version_string_curr)
  foreach(version IN LISTS list_of_versions)
    if(NOT version_string_curr)
        set(version_string_curr ${version})
    elseif(version_string_curr VERSION_LESS ${version})
      set(version_string_curr ${version})
    endif()
  endforeach()
  set(${GREATER_ONE} ${version_string_curr} PARENT_SCOPE)
endfunction(get_Greater_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_Platform_Symlinks| replace:: ``list_Platform_Symlinks``
#  .. _list_Platform_Symlinks:
#
#  list_Platform_Symlinks
#  ----------------------
#
#   .. command:: list_Platform_Symlinks(RESULT curdir)
#
#    Get the list of all symlink from a given folder, with each symlink pointing to a folder with a platform name pattern (e.g. x86_64_linux_stdc++11).
#
#     :curdir: the folder to find symlinks in.
#
#     :RESULT: the output variable containing the list of symlinks.
#
function(list_Platform_Symlinks RESULT curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_SYMLINK ${curdir}/${child})
      if("${child}" MATCHES "^[^_]+_[^_]+_[^_]+_[^_]+$")
  			list(APPEND dirlist ${child})
      elseif("${child}" MATCHES "^[^_]+_[^_]+_[^_]+$")
  			list(APPEND dirlist ${child})
      endif()
		endif()
	endforeach()
  list(SORT dirlist)
	set(${RESULT} ${dirlist} PARENT_SCOPE)
endfunction(list_Platform_Symlinks)

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_Platform_Subdirectories| replace:: ``list_Platform_Subdirectories``
#  .. _list_Platform_Subdirectories:
#
#  list_Platform_Subdirectories
#  ----------------------------
#
#   .. command:: list_Platform_Subdirectories(RESULT curdir)
#
#    Get the list of all direct subfolders of a given folder, each folder with a platform name pattern (e.g. x86_64_linux_stdc++11).
#
#     :curdir: the folder to find platform subfolders in.
#
#     :RESULT: the output variable containing the list of platform subfolders.
#
function(list_Platform_Subdirectories RESULT curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
  if(children)
  	foreach(child ${children})
  		if(IS_DIRECTORY ${curdir}/${child}
  			AND NOT IS_SYMLINK ${curdir}/${child}
  			AND "${child}" MATCHES "^[^_]+_[^_]+_[^_]+_[^_]+(__.+__)?$")#platform name pattern takes into account pontential environment instance
  			list(APPEND dirlist ${child})
  		endif()
  	endforeach()
  endif()
	set(${RESULT} ${dirlist} PARENT_SCOPE)
endfunction(list_Platform_Subdirectories)

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_Subdirectories| replace:: ``list_Subdirectories``
#  .. _list_Subdirectories:
#
#  list_Subdirectories
#  -------------------
#
#   .. command:: list_Subdirectories(RESULT curdir)
#
#    Get the list of all direct subfolders of a given folder.
#
#     :curdir: the folder to find subfolders in.
#
#     :RESULT: the output variable containing the list of subfolders.
#
function(list_Subdirectories RESULT curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_DIRECTORY ${curdir}/${child})
			list(APPEND dirlist ${child})
		endif()
	endforeach()
	set(${RESULT} ${dirlist} PARENT_SCOPE)
endfunction(list_Subdirectories)

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_Regular_Files| replace:: ``list_Regular_Files``
#  .. _list_Regular_Files:
#
#  list_Regular_Files
#  -------------------
#
#   .. command:: list_Regular_Files(RESULT curdir)
#
#    Get the list of all regular files into a given folder.
#
#     :curdir: the folder to find regular files in.
#
#     :RESULT: the output variable containing the list of regular files names.
#
function(list_Regular_Files RESULT curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(filelist "")
	foreach(child ${children})
		if(NOT IS_DIRECTORY ${curdir}/${child} AND NOT IS_SYMLINK ${curdir}/${child})
			list(APPEND filelist ${child})
		endif()
	endforeach()
	set(${RESULT} ${filelist} PARENT_SCOPE)
endfunction(list_Regular_Files)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Compatible_Version| replace:: ``is_Compatible_Version``
#  .. _is_Compatible_Version:
#
#  is_Compatible_Version
#  ---------------------
#
#   .. command:: is_Compatible_Version(COMPATIBLE reference_major reference_minor version_to_compare)
#
#    Tell whether a reference version is compatible with (i.e. can be used instead of) another version. Means that their major version are the same and compared version has same or lower minor version number.
#
#     :reference_major: the major number of the reference version.
#     :reference_minor: the minor number of the reference version.
#     :version_to_compare: the version string of the compared version
#
#     :COMPATIBLE: the output variable that is TRUE if reference version is compatible with version_to_compare.
#
function(is_Compatible_Version COMPATIBLE reference_major reference_minor version_to_compare)
set(${COMPATIBLE} FALSE PARENT_SCOPE)
get_Version_String_Numbers("${version_to_compare}.0" compare_major compare_minor compared_patch)
if(NOT compare_major EQUAL reference_major OR compare_minor GREATER reference_minor)
	return()#not compatible
endif()
set(${COMPATIBLE} TRUE PARENT_SCOPE)
endfunction(is_Compatible_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Exact_Compatible_Version| replace:: ``is_Exact_Compatible_Version``
#  .. _is_Exact_Compatible_Version:
#
#  is_Exact_Compatible_Version
#  ---------------------------
#
#   .. command:: is_Exact_Compatible_Version(COMPATIBLE reference_major reference_minor version_to_compare)
#
#    Tell whether a version is compatible with a reference version if an exact constraint is applied. Means that their major and minor version number are the same.
#
#     :reference_major: the major number of the reference version.
#     :reference_minor: the minor number of the reference version.
#     :version_to_compare: the version string of the compared version
#
#     :COMPATIBLE: the output variable that is TRUE if version_to_compare is compatible with reference version
#
function(is_Exact_Compatible_Version COMPATIBLE reference_major reference_minor version_to_compare)
set(${COMPATIBLE} FALSE PARENT_SCOPE)
get_Version_String_Numbers("${version_to_compare}.0" compare_major compare_minor compared_patch)
if(	NOT (compare_major EQUAL reference_major)
    OR NOT (compare_minor EQUAL reference_minor))
	return()#not compatible
endif()
set(${COMPATIBLE} TRUE PARENT_SCOPE)
endfunction(is_Exact_Compatible_Version)

#############################################################
################ Information about authors ##################
#############################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Full_Author_String| replace:: ``generate_Full_Author_String``
#  .. _generate_Full_Author_String:
#
#  generate_Full_Author_String
#  ---------------------------
#
#   .. command:: generate_Full_Author_String(author RES_STRING)
#
#    Transform an author string from an internal format to a readable format (ready to be used in any information output for the user).
#
#     :author: the author description internal string (e.g. "firstname_lastname(all_words_of_the_institution)").
#
#     :RES_STRING: the output variable that contains the author information string in a readable format.
#
function(generate_Full_Author_String author RES_STRING)
string(REGEX REPLACE "^([^\\(]+)\\(([^\\)]+)\\)$" "\\1;\\2" author_institution "${author}")
if(author_institution STREQUAL "${author}")
	string(REGEX REPLACE "^([^\\(]+)\\(([^\\)]*)\\)$" "\\1;\\2" author_institution "${author}")
	list(GET author_institution 0 AUTHOR_NAME)
	set(INSTITUTION_NAME)
else()
	list(GET author_institution 0 AUTHOR_NAME)
	list(GET author_institution 1 INSTITUTION_NAME)
endif()
extract_All_Words("${AUTHOR_NAME}" "_" AUTHOR_ALL_WORDS)
extract_All_Words("${INSTITUTION_NAME}" "_" INSTITUTION_ALL_WORDS)
fill_String_From_List(AUTHOR_STRING AUTHOR_ALL_WORDS " ")
fill_String_From_List(INSTITUTION_STRING INSTITUTION_ALL_WORDS " ")
if(NOT INSTITUTION_STRING STREQUAL "")
	set(${RES_STRING} "${AUTHOR_STRING} (${INSTITUTION_STRING})" PARENT_SCOPE)
else()
	set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
endif()
endfunction(generate_Full_Author_String)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Contact_String| replace:: ``generate_Contact_String``
#  .. _generate_Contact_String:
#
#  generate_Contact_String
#  -----------------------
#
#   .. command:: generate_Contact_String(author mail RES_STRING)
#
#    Transform a contact author string from an internal format to a readable format (ready to be used in any information output for the user).
#
#     :author: the author description internal string (e.g. "firstname_lastname").
#     :mail: the mail of the contact author.
#
#     :RES_STRING: the output variable that contains the contact author information string in a readable format.
#
function(generate_Contact_String author mail RES_STRING)
extract_All_Words("${author}" "_" AUTHOR_ALL_WORDS)
fill_String_From_List(AUTHOR_STRING AUTHOR_ALL_WORDS " ")
if(mail AND NOT mail STREQUAL "")
	set(${RES_STRING} "${AUTHOR_STRING} (${mail})" PARENT_SCOPE)
else()
	set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
endif()
endfunction(generate_Contact_String)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Formatted_Framework_Contact_String| replace:: ``get_Formatted_Framework_Contact_String``
#  .. _get_Formatted_Framework_Contact_String:
#
#  get_Formatted_Framework_Contact_String
#  --------------------------------------
#
#   .. command:: get_Formatted_Framework_Contact_String(framework RES_STRING)
#
#    Transform a string from an internal format to a readable format used in framework static site.
#
#     :framework: the name of target framework.
#
#     :RES_STRING: the output variable that contains the string in a readable format.
#
function(get_Formatted_Framework_Contact_String framework RES_STRING)
extract_All_Words("${${framework}_MAIN_AUTHOR}" "_" AUTHOR_ALL_WORDS)
extract_All_Words("${${framework}_MAIN_INSTITUTION}" "_" INSTITUTION_ALL_WORDS)
fill_String_From_List(AUTHOR_STRING AUTHOR_ALL_WORDS " ")
fill_String_From_List(INSTITUTION_STRING INSTITUTION_ALL_WORDS " ")
if(NOT INSTITUTION_STRING STREQUAL "")
	if(${framework}_CONTACT_MAIL)
		set(${RES_STRING} "${AUTHOR_STRING} (${${framework}_CONTACT_MAIL}) - ${INSTITUTION_STRING}" PARENT_SCOPE)
	else()
		set(${RES_STRING} "${AUTHOR_STRING} - ${INSTITUTION_STRING}" PARENT_SCOPE)
	endif()
else()
	if(${package}_CONTACT_MAIL)
		set(${RES_STRING} "${AUTHOR_STRING} (${${framework}_CONTACT_MAIL})" PARENT_SCOPE)
	else()
		set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
	endif()
endif()
endfunction(get_Formatted_Framework_Contact_String)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Formatted_String| replace:: ``generate_Formatted_String``
#  .. _generate_Formatted_String:
#
#  generate_Formatted_String
#  -------------------------
#
#   .. command:: generate_Formatted_String(input RES_STRING)
#
#    Transform a string from an internal format to a readable format (ready to be used in any information output for the user).
#
#     :input: the string with internal format (e.g. "one_two_three").
#
#     :RES_STRING: the output variable that contains the string in a readable format.
#
function(generate_Formatted_String input RES_STRING)
extract_All_Words("${input}" "_" INPUT_ALL_WORDS)
fill_String_From_List(INPUT_STRING INPUT_ALL_WORDS " ")
set(${RES_STRING} "${INPUT_STRING}" PARENT_SCOPE)
endfunction(generate_Formatted_String)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Formatted_Author_String| replace:: ``get_Formatted_Author_String``
#  .. _get_Formatted_Author_String:
#
#  get_Formatted_Author_String
#  ---------------------------
#
#   .. command:: get_Formatted_Author_String(author RES_STRING)
#
#    Transform an author string from an internal format to a readable format.
#
#     :author: the author data in internal format.
#
#     :RES_STRING: the output variable that contains the author string in a readable format.
#
function(get_Formatted_Author_String author RES_STRING)
string(REGEX REPLACE "^([^\\(]+)\\(([^\\)]*)\\)$" "\\1;\\2" author_institution "${author}")
list(LENGTH author_institution SIZE)
if(SIZE EQUAL 2)
  list(GET author_institution 0 AUTHOR_NAME)
  list(GET author_institution 1 INSTITUTION_NAME)
  extract_All_Words("${AUTHOR_NAME}" "_" AUTHOR_ALL_WORDS)
  extract_All_Words("${INSTITUTION_NAME}" "_" INSTITUTION_ALL_WORDS)
  fill_String_From_List(AUTHOR_STRING AUTHOR_ALL_WORDS " ")
  fill_String_From_List(INSTITUTION_STRING INSTITUTION_ALL_WORDS " ")
elseif(SIZE EQUAL 1)
  list(GET author_institution 0 AUTHOR_NAME)
  extract_All_Words("${AUTHOR_NAME}" "_" AUTHOR_ALL_WORDS)
  fill_String_From_List(AUTHOR_STRING AUTHOR_ALL_WORDS " ")
  set(INSTITUTION_STRING "")
endif()
if(NOT INSTITUTION_STRING STREQUAL "")
	set(${RES_STRING} "${AUTHOR_STRING} - ${INSTITUTION_STRING}" PARENT_SCOPE)
else()
	set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
endif()
endfunction(get_Formatted_Author_String)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Formatted_Package_Contact_String| replace:: ``get_Formatted_Package_Contact_String``
#  .. _get_Formatted_Package_Contact_String:
#
#  get_Formatted_Package_Contact_String
#  ------------------------------------
#
#   .. command:: get_Formatted_Package_Contact_String(package RES_STRING)
#
#    Transform a string from an internal format to a readable format used in package description (static site, workspace commands).
#
#     :package: the name of target package.
#
#     :RES_STRING: the output variable that contains the contact string in a readable format.
#
function(get_Formatted_Package_Contact_String package RES_STRING)
extract_All_Words("${${package}_MAIN_AUTHOR}" "_" AUTHOR_ALL_WORDS)
extract_All_Words("${${package}_MAIN_INSTITUTION}" "_" INSTITUTION_ALL_WORDS)
fill_String_From_List(AUTHOR_STRING AUTHOR_ALL_WORDS " ")
fill_String_From_List(INSTITUTION_STRING INSTITUTION_ALL_WORDS " ")
if(NOT INSTITUTION_STRING STREQUAL "")
	if(${package}_CONTACT_MAIL)
		set(${RES_STRING} "${AUTHOR_STRING} (${${package}_CONTACT_MAIL}) - ${INSTITUTION_STRING}" PARENT_SCOPE)
	else()
		set(${RES_STRING} "${AUTHOR_STRING} - ${INSTITUTION_STRING}" PARENT_SCOPE)
	endif()
else()
	if(${package}_CONTACT_MAIL)
		set(${RES_STRING} "${AUTHOR_STRING} (${${package}_CONTACT_MAIL})" PARENT_SCOPE)
	else()
		set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
	endif()
endif()
endfunction(get_Formatted_Package_Contact_String)

#.rst:
#
# .. ifmode:: internal
#
#  .. |package_License_Is_Closed_Source| replace:: ``package_License_Is_Closed_Source``
#  .. _package_License_Is_Closed_Source:
#
#  package_License_Is_Closed_Source
#  --------------------------------
#
#   .. command:: package_License_Is_Closed_Source(CLOSED package is_external)
#
#    Check whether the license applying to a package is closed source or not.
#
#     :package: the name of the package.
#     :is_external: if TRUE then the package is an external package.
#
#     :CLOSED: the output variable that is TRUE if package is closed source.
#
function(package_License_Is_Closed_Source CLOSED package is_external)
	#first step determining if the dependent package provides its license in its use file (compatiblity with previous version of PID)
	if(NOT ${package}_LICENSE)
    if(is_external)
      include_External_Reference_File(PATH_TO_FILE ${package})
      if(NOT PATH_TO_FILE)#we consider the package as having an opensource license when no information provided
  			set(${CLOSED} FALSE PARENT_SCOPE)
  			return()
  		endif()
    else()
      include_Package_Reference_File(PATH_TO_FILE ${package})
  		if(NOT PATH_TO_FILE)#we consider the package as having an opensource license when no information provided
  			set(${CLOSED} FALSE PARENT_SCOPE)
  			return()
  		endif()
    endif()
	endif()
	set(found_license_description FALSE)
	if(KNOWN_LICENSES)
		list(FIND KNOWN_LICENSES ${${package}_LICENSE} INDEX)
		if(NOT INDEX EQUAL -1)
			set(found_license_description TRUE)
		endif()#otherwise license has never been loaded so do not know if open or closed source
	endif()#otherwise license is unknown for now
	if(NOT found_license_description)
		#trying to find that license
    resolve_License_File(PATH_TO_FILE ${${package}_LICENSE})
    if(NOT PATH_TO_FILE)
      set(${CLOSED} TRUE PARENT_SCOPE)
      message("[PID] ERROR : cannot find description file for license ${${package}_LICENSE}, specified for package ${package}. Package is supposed to be closed source.")
      return()
    endif()
    include(${PATH_TO_FILE})
		set(temp_list ${KNOWN_LICENSES} ${${package}_LICENSE} CACHE INTERNAL "")
		list(REMOVE_DUPLICATES temp_list)
		set(KNOWN_LICENSES ${temp_list} CACHE INTERNAL "")#adding the license to known licenses

		if(LICENSE_IS_OPEN_SOURCE)
			set(KNOWN_LICENSE_${${package}_LICENSE}_CLOSED FALSE CACHE INTERNAL "")
		else()
			set(KNOWN_LICENSE_${${package}_LICENSE}_CLOSED TRUE CACHE INTERNAL "")
		endif()
	endif()
	# here the license is already known, simply checking for the registered values
	# this memorization is to optimize configuration time as License file may be long to load
	set(${CLOSED} ${KNOWN_LICENSE_${${package}_LICENSE}_CLOSED} PARENT_SCOPE)
endfunction(package_License_Is_Closed_Source)

#############################################################
################ Source file management #####################
#############################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |activate_Adequate_Languages| replace:: ``activate_Adequate_Languages``
#  .. _activate_Adequate_Languages:
#
#  activate_Adequate_Languages
#  ---------------------------
#
#   .. command:: activate_Adequate_Languages()
#
#    Activate adequate languages in the current CMake project, depending on source file used in the project.
#
macro(activate_Adequate_Languages)

#enable assembler by default => assembler will be used anytime because it is a C/C++ project
enable_language(ASM)#use assembler

if(CMAKE_Fortran_COMPILER AND EXISTS ${CMAKE_Fortran_COMPILER})
  enable_language(Fortran)#use fortran
endif()

if(CMAKE_CUDA_COMPILER AND EXISTS ${CMAKE_CUDA_COMPILER})#if a CUDA compiler is defined by the current environment, then enable language
  set(temp_flags ${CMAKE_CUDA_FLAGS})#need to deactivate forced flags to avoid problems when detecting language
  set(CMAKE_CUDA_FLAGS CACHE INTERNAL "" FORCE)
  enable_language(CUDA)#use cuda compiler
  set(CMAKE_CUDA_FLAGS ${temp_flags} CACHE INTERNAL "" FORCE)
endif()

endmacro(activate_Adequate_Languages)

#.rst:
#
# .. ifmode:: internal
#
#  .. |filter_All_Sources| replace:: ``filter_All_Sources``
#  .. _filter_All_Sources:
#
#  filter_All_Sources
#  -------------------
#
#   .. command:: filter_All_Sources(LIST_TO_FILTER)
#
#    Filter the input list by keeping only c/c++ source files.
#
#     :LIST_TO_FILTER: the input and output variable that contains all source files path.
#
function(filter_All_Sources LIST_TO_FILTER)
  set(temp_sources_to_check)
  if(LIST_TO_FILTER AND ${LIST_TO_FILTER})
    foreach(source IN LISTS ${LIST_TO_FILTER})
      if(source MATCHES "^.+\\.(c|C|cc|cpp|cxx|c\\+\\+|h|hh|hpp|hxx)$" # a file with specific C/C++ extension
          OR source MATCHES "^[^.]+$" )# a file without extension
        list(APPEND temp_sources_to_check ${source})
      endif()
    endforeach()
  endif()
set (${LIST_TO_FILTER} ${temp_sources_to_check} PARENT_SCOPE)
endfunction(filter_All_Sources)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_All_Sources_Relative| replace:: ``get_All_Sources_Relative``
#  .. _get_All_Sources_Relative:
#
#  get_All_Sources_Relative
#  ------------------------
#
#   .. command:: get_All_Sources_Relative(RESULT dir)
#
#    Get all the relative path of source files found in a folder (and its subfolders).
#
#     :dir: the path to the folder
#
#     :RESULT: the output variable that contains all source files path relative to the folder.
#
function(get_All_Sources_Relative RESULT dir)
  set(additional_filter)
  if(Fortran_Language_AVAILABLE)
    list(APPEND additional_filters "${dir}/*.f" "${dir}/*.F" "${dir}/*.for" "${dir}/*.f90" "${dir}/*.f95" "${dir}/*.f03")
  endif()
  if(CUDA_Language_AVAILABLE)
    list(APPEND additional_filters "${dir}/*.cu" "${dir}/*.cuh")
  endif()
  if(Python_Language_AVAILABLE)
    list(APPEND additional_filters "${dir}/*.py")
  endif()

  file(	GLOB_RECURSE
  	RES
  	RELATIVE ${dir}
  	"${dir}/*.c"
  	"${dir}/*.C"
  	"${dir}/*.cc"
  	"${dir}/*.cpp"
  	"${dir}/*.cxx"
  	"${dir}/*.c++"
  	"${dir}/*.h"
  	"${dir}/*.hpp"
  	"${dir}/*.hh"
  	"${dir}/*.hxx"
  	"${dir}/*.h++"
  	"${dir}/*.s"
  	"${dir}/*.S"
  	"${dir}/*.asm"
    ${additional_filters}
  )
  set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Sources_Relative)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_All_Sources_Absolute| replace:: ``get_All_Sources_Absolute``
#  .. _get_All_Sources_Absolute:
#
#  get_All_Sources_Absolute
#  ------------------------
#
#   .. command:: get_All_Sources_Absolute(RESULT dir)
#
#    Get the absolute path of all the source files found in a folder (and subfolders). Absolute sources do not take into account python files as they will not be part of a build process.
#
#     :dir: the path to the folder
#
#     :RESULT: the output variable that contains all source files path.
#
function(get_All_Sources_Absolute RESULT dir)
  set(additional_filter)
  if(Fortran_Language_AVAILABLE)
    list(APPEND additional_filters "${dir}/*.f" "${dir}/*.F" "${dir}/*.for" "${dir}/*.f90" "${dir}/*.f95" "${dir}/*.f03")
  endif()
  if(CUDA_Language_AVAILABLE)
    list(APPEND additional_filters "${dir}/*.cu" "${dir}/*.cuh")
  endif()
  if(Python_Language_AVAILABLE)
    list(APPEND additional_filters "${dir}/*.py")
  endif()

  file(	GLOB_RECURSE
  	RES
  	${dir}
  	"${dir}/*.c"
  	"${dir}/*.C"
  	"${dir}/*.cc"
  	"${dir}/*.cpp"
  	"${dir}/*.c++"
  	"${dir}/*.cxx"
  	"${dir}/*.h"
  	"${dir}/*.hpp"
  	"${dir}/*.h++"
  	"${dir}/*.hh"
  	"${dir}/*.hxx"
  	"${dir}/*.s"
  	"${dir}/*.S"
  	"${dir}/*.asm"
    ${additional_filters}
  )
  set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Sources_Absolute)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_All_Cpp_Sources_Absolute| replace:: ``get_All_Cpp_Sources_Absolute``
#  .. _get_All_Cpp_Sources_Absolute:
#
#  get_All_Cpp_Sources_Absolute
#  ----------------------------
#
#   .. command:: get_All_Cpp_Sources_Absolute(RESULT dir)
#
#    Get the absolute path of all the C/C++ source files found in a folder (and subfolders).
#
#     :dir: the path to the folder
#
#     :RESULT: the output variable that contains all source files path.
#
function(get_All_Cpp_Sources_Absolute RESULT dir)
file(	GLOB_RECURSE
	RES
	${dir}
	"${dir}/*.c"
	"${dir}/*.C"
	"${dir}/*.cc"
	"${dir}/*.cpp"
	"${dir}/*.c++"
	"${dir}/*.cxx"
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.h++"
	"${dir}/*.hh"
	"${dir}/*.hxx"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Cpp_Sources_Absolute)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_All_Sources_Absolute_From| replace:: ``get_All_Sources_Absolute_From``
#  .. _get_All_Sources_Absolute_From:
#
#  get_All_Sources_Absolute_From
#  -----------------------------
#
#   .. command:: get_All_Sources_Absolute_From(PATH_TO_SOURCES LIST_OF_INCLUDES root_dir list_of_path)
#
#    List all source files absolute path that are contained in a set of path expressed relative to a root path. If a path given targets a folder that contains header files, this  path is added to the list of monitored include folders.
#    Path to source files are simply added to the list.
#
#     :root_dir: the path to the root folder, path are expressed reltive to.
#     :list_of_path: the list of path to scan.
#
#     :PATH_TO_SOURCES: the ouput variable containing the list of path to source files that are contained in list_of_path.
#     :LIST_OF_INCLUDES: the ouput variable containing the list of absolute path to include folder from list_of_path.
#
function(get_All_Sources_Absolute_From PATH_TO_SOURCES LIST_OF_INCLUDES root_dir list_of_path)
set(all_sources)
set(all_includes)
set(${PATH_TO_SOURCES} PARENT_SCOPE)
set(${LIST_OF_INCLUDES} PARENT_SCOPE)
foreach(path IN LISTS list_of_path)
  if(EXISTS "${root_dir}/${path}")
    if(IS_DIRECTORY "${root_dir}/${path}")
      get_All_Sources_Absolute(DIR_SRC "${root_dir}/${path}")
      list(APPEND all_sources "${DIR_SRC}")
      get_All_Headers_Absolute(ALL_HEADERS "${root_dir}/${path}" "")
      if(ALL_HEADERS)#if there are headers into the folder simply add this folder as an include folder
        list(APPEND all_includes "${root_dir}/${path}")
      endif()
    else()
      list(APPEND all_sources "${root_dir}/${path}")
    endif()
  endif()
endforeach()
set(${LIST_OF_INCLUDES} ${all_includes}  PARENT_SCOPE)
set(${PATH_TO_SOURCES} ${all_sources} PARENT_SCOPE)
endfunction(get_All_Sources_Absolute_From)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_All_Sources_Relative_From| replace:: ``get_All_Sources_Relative_From``
#  .. _get_All_Sources_Relative_From:
#
#  get_All_Sources_Relative_From
#  -----------------------------
#
#   .. command:: get_All_Sources_Relative_From(PATH_TO_SOURCES MONITORED_FOLDER root_dir list_of_path)
#
#    List all source files path relative from a root path that are contained in a set of path. If a path given target a folder its content is recursively added and the path is added to the monitored folders. Path to source files are simply added to the list.
#
#     :root_dir: the path to the root folder, path are expressed reltive to.
#     :list_of_path: the list of path to scan.
#
#     :PATH_TO_SOURCES: the ouput variable containing the list of path to source files that are contained in list_of_path.
#     :MONITORED_FOLDER: the ouput variable containing the list of path to folder from list_of_path.
#
function(get_All_Sources_Relative_From PATH_TO_SOURCES MONITORED_FOLDER root_dir list_of_path)
set(RESULT)
set(MONITOR)
set(${PATH_TO_SOURCES} PARENT_SCOPE)
set(${MONITORED_FOLDER} PARENT_SCOPE)
foreach(path IN LISTS list_of_path)
  if(EXISTS "${root_dir}/${path}")
    if(IS_DIRECTORY "${root_dir}/${path}")
      list(APPEND MONITOR ${path})#directly add the relative path to monitored elements
      get_All_Sources_Relative(DIR_SRC "${root_dir}/${path}")
      foreach(src IN LISTS DIR_SRC)
        list(APPEND temp_rel_src "${path}/${src}")
      endforeach()
      list(APPEND RESULT ${temp_rel_src})
    else()
      list(APPEND RESULT "${path}")
    endif()
  endif()
endforeach()
set(${PATH_TO_SOURCES} ${RESULT} PARENT_SCOPE)
set(${MONITORED_FOLDER} ${MONITOR} PARENT_SCOPE)
endfunction(get_All_Sources_Relative_From)

#.rst:
#
# .. ifmode:: internal
#
#  .. |contains_Python_Code| replace:: ``contains_Python_Code``
#  .. _contains_Python_Code:
#
#  contains_Python_Code
#  --------------------
#
#   .. command:: contains_Python_Code(HAS_PYTHON dir)
#
#    Tell whether a folder contains python script or not.
#
#     :dir: the path to the folder
#
#     :HAS_PYTHON: the output variable that is TRUE if folder contains python code.
#
function(contains_Python_Code HAS_PYTHON dir)
file(GLOB_RECURSE HAS_PYTHON_CODE ${dir} "${dir}/*.py")
set(${HAS_PYTHON} ${HAS_PYTHON_CODE} PARENT_SCOPE)
endfunction(contains_Python_Code)

#.rst:
#
# .. ifmode:: internal
#
#  .. |contains_Python_Package_Description| replace:: ``contains_Python_Package_Description``
#  .. _contains_Python_Package_Description:
#
#  contains_Python_Package_Description
#  -----------------------------------
#
#   .. command:: contains_Python_Package_Description(IS_PYTHON_PACK dir)
#
#    Tell whether a folder is a python package or not.
#
#     :dir: the path to the folder
#
#     :IS_PYTHON_PACK: the output variable that is TRUE if folder is a python package.
#
function(contains_Python_Package_Description IS_PYTHON_PACK dir)
	file(GLOB PY_PACK_FILE RELATIVE ${dir} "${dir}/__init__.py")
	set(${IS_PYTHON_PACK} ${PY_PACK_FILE} PARENT_SCOPE)
endfunction(contains_Python_Package_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_All_Headers_Relative| replace:: ``get_All_Headers_Relative``
#  .. _get_All_Headers_Relative:
#
#  get_All_Headers_Relative
#  ------------------------
#
#   .. command:: get_All_Headers_Relative(RESULT dir)
#
#    Get all the relative path of header files found in a folder (and its subfolders).
#
#     :dir: the path to the folder
#     :filters: custom filters provided by the user, that target header files relative to dir (used for instance for headers without extension)
#
#     :RESULT: the output variable that contains all header files path relative to the folder.
#
function(get_All_Headers_Relative RESULT dir filters)
set(LIST_OF_FILTERS)
foreach(filter IN LISTS filters)
  list(APPEND LIST_OF_FILTERS "${dir}/${filter}")
endforeach()

set(additional_filter)
if(CUDA_Language_AVAILABLE)
  list(APPEND additional_filters "${dir}/*.cuh")#specific header extension when using CUDA
endif()

file(	GLOB_RECURSE
	RES
	RELATIVE ${dir}
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.hh"
	"${dir}/*.hxx"
	"${dir}/*.h++"
  ${additional_filters}
  ${LIST_OF_FILTERS}
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Headers_Relative)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_All_Headers_Absolute| replace:: ``get_All_Headers_Absolute``
#  .. _get_All_Headers_Absolute:
#
#  get_All_Headers_Absolute
#  ------------------------
#
#   .. command:: get_All_Headers_Absolute(RESULT dir filters)
#
#    Get the absolute path of all the header files found in a folder (and subfolders).
#
#     :dir: the path to the folder
#     :filters: custom filters provided by the user, that target header files relative to dir (used for instance for headers without extension)
#
#     :RESULT: the output variable that contains all header files absolute path.
#
function(get_All_Headers_Absolute RESULT dir filters)
  set(LIST_OF_FILTERS)
  foreach(filter IN LISTS filters)
    list(APPEND LIST_OF_FILTERS "${dir}/${filter}")
  endforeach()

  set(additional_filter)
  if(CUDA_Language_AVAILABLE)
    list(APPEND additional_filters "${dir}/*.cuh")#specific header extension when using CUDA
  endif()

  file(	GLOB_RECURSE
  	RES
  	${dir}
  	"${dir}/*.h"
  	"${dir}/*.hpp"
  	"${dir}/*.hh"
  	"${dir}/*.hxx"
    ${additional_filters}
    ${LIST_OF_FILTERS}
  )
  set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Headers_Absolute)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Shared_Lib_With_Path| replace:: ``is_Shared_Lib_With_Path``
#  .. _is_Shared_Lib_With_Path:
#
#  is_Shared_Lib_With_Path
#  -----------------------
#
#   .. command:: is_Shared_Lib_With_Path(SHARED input_link)
#
#    Tell whether the path to a binary object is a shared/dynamic library.
#
#     :input_link: the path to a given binary
#
#     :SHARED: the output variable that is TRUE .
#
function(is_Shared_Lib_With_Path SHARED input_link)
set(${SHARED} FALSE PARENT_SCOPE)
get_filename_component(LIB_TYPE ${input_link} EXT)
if(LIB_TYPE)
  if(APPLE)
      if(LIB_TYPE MATCHES "\\.dylib$")#found shared lib
        set(${SHARED} TRUE PARENT_SCOPE)
      endif()
  elseif(UNIX)
      if(LIB_TYPE MATCHES "\\.so(\\.[0-9]+)*$")#found shared lib
        set(${SHARED} TRUE PARENT_SCOPE)
      endif()
  elseif(WIN32)
     if(LIB_TYPE MATCHES "^\\.dll(\\.[0-9]+)*$")#found shared lib
        set(${SHARED} TRUE PARENT_SCOPE)
     endif()
  endif()
else()
   # no extenion may be possible with MACOSX frameworks
  if(APPLE)
     set(${SHARED} TRUE PARENT_SCOPE)
  endif()
endif()
endfunction(is_Shared_Lib_With_Path)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Library_Dirs_For_Links| replace:: ``get_Library_Dirs_For_Links``
#  .. _get_Library_Dirs_For_Links:
#
#  get_Library_Dirs_For_Links
#  --------------------------
#
#   .. command:: get_Library_Dirs_For_Links(OUT_LDIRS ext_package list_of_libraries)
#
#    Provides the list of library dirs provided by a given external package.
#
#     :ext_package: the name of external package
#     :list_of_libraries: the list variable containing links defined in external package
#
#     :OUT_LDIRS: the output variable that contains the list of library dirs.
#
function(get_Library_Dirs_For_Links OUT_LDIRS ext_package list_of_libraries)
  set(ret_ldirs)
  if(list_of_libraries AND ${list_of_libraries})#the variable containing the list trully contains a list
    foreach(lib IN LISTS ${list_of_libraries})
      if(lib MATCHES "^<${ext_package}>.+$")
        get_filename_component(FOLDER ${lib} DIRECTORY)
        list(APPEND ret_ldirs ${FOLDER})
      endif()#if a system link is used (absolute) no need to define the library dir because not related to the package
    endforeach()
    if(ret_ldirs)
      list(REMOVE_DUPLICATES ret_ldirs)
    endif()
  endif()
  set(${OUT_LDIRS} ${ret_ldirs} PARENT_SCOPE)
endfunction(get_Library_Dirs_For_Links)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Shared_Lib_Extension| replace:: ``create_Shared_Lib_Extension``
#  .. _create_Shared_Lib_Extension:
#
#  create_Shared_Lib_Extension
#  ---------------------------
#
#   .. command:: create_Shared_Lib_Extension(RES_EXT platform soname)
#
#    Get the extension string to use for shared libraries.
#
#     :platform: the identifier of target platform.
#     :soname: the soname to use for unix shared objects
#
#     :RES_EXT: the output variable containing the resulting extension to use for shared objects, depending on platform.
#
function(create_Shared_Lib_Extension RES_EXT platform soname)
  extract_Info_From_Platform(RES_ARCH RES_BITS RES_OS RES_ABI RES_INSTANCE RES_PLATFORM_BASE ${platform})
  if(RES_OS STREQUAL "macos")
    if(soname OR soname EQUAL 0)
      if(soname MATCHES "^\\.[0-9].*$")
        set(${RES_EXT} "${soname}.dylib" PARENT_SCOPE)
      else()
        set(${RES_EXT} ".${soname}.dylib" PARENT_SCOPE)
      endif()
    else()
      set(${RES_EXT} ".dylib" PARENT_SCOPE)
    endif()
	elseif(RES_OS STREQUAL "windows")
		set(${RES_EXT} ".dll" PARENT_SCOPE)
	else()# Linux or any other standard UNIX system
		if(soname OR soname EQUAL 0)
			if(soname MATCHES "^\\.[0-9].*$")#MATCH: the soname expression start with a dot
				set(${RES_EXT} ".so${soname}" PARENT_SCOPE)
			else()#the expression starts with a number, simply add the dot
				set(${RES_EXT} ".so.${soname}" PARENT_SCOPE)
			endif()
		else()
			set(${RES_EXT} ".so" PARENT_SCOPE)
		endif()
	endif()
endfunction(create_Shared_Lib_Extension)


#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Static_Lib_Extension| replace:: ``create_Static_Lib_Extension``
#  .. _create_Static_Lib_Extension:
#
#  create_Static_Lib_Extension
#  ---------------------------
#
#   .. command:: create_Static_Lib_Extension(RES_EXT platform)
#
#    Get the extension string to use for static libraries.
#
#     :platform: the identifier of target platform.
#
#     :RES_EXT: the output variable containing the resulting extension to use for statlic libraries.
#
function(create_Static_Lib_Extension RES_EXT platform)
  if(CURRENT_PLATFORM_OS STREQUAL "windows")
		set(${RES_EXT} ".lib" PARENT_SCOPE)
	else()# Linux or any other standard UNIX system
		set(${RES_EXT} ".a" PARENT_SCOPE)
	endif()
endfunction(create_Static_Lib_Extension)

#.rst:
#
# .. ifmode:: internal
#
#  .. |shared_Library_Needs_Soname| replace:: ``shared_Library_Needs_Soname``
#  .. _shared_Library_Needs_Soname:
#
#  shared_Library_Needs_Soname
#  -----------------------------------
#
#   .. command:: shared_Library_Needs_Soname(NEEDS_SONAME library_path platform)
#
#    Check whether a shared library needs to have a soname extension appended to its name.
#
#     :library_path: the path to the library.
#     :platform: the target platform.
#
#     :NEEDS_SONAME: the output variable that is TRUE if the extension finish by a SONAME.
#
function(shared_Library_Needs_Soname NEEDS_SONAME library_path platform)
  set(${NEEDS_SONAME} FALSE PARENT_SCOPE)
  if(library_path MATCHES "^-l.*$")#OS dependency using standard library path => no need of soname extension
    return()
  endif()
	extract_Info_From_Platform(RES_ARCH RES_BITS RES_OS RES_ABI RES_INSTANCE RES_PLATFORM_BASE ${platform})
  get_filename_component(EXTENSION ${library_path} EXT)#get the longest extension of the file
	if(RES_OS STREQUAL "macosx")
    set(target_extension "\\.dylib")
  elseif(RES_OS STREQUAL "windows")
    set(target_extension "\\.dll")
  else()
    set(target_extension "\\.so(\\.[0-9]+)*")
  endif()
  if(EXTENSION MATCHES "^(\\.[^\\.]+)*${target_extension}$")#there is already a .so|.dylib|.dll extension
    # this check is here to ensure that a library name ending with a dot followed by any characters
    # will not be considered as a library extension (e.g. example libusb-1.0)
    return()
  endif()
  set(${NEEDS_SONAME} TRUE PARENT_SCOPE)
endfunction(shared_Library_Needs_Soname)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Static_Lib_Path| replace:: ``create_Static_Lib_Path``
#  .. _create_Static_Lib_Path:
#
#  create_Static_Lib_Path
#  ----------------------
#
#   .. command:: create_Static_Lib_Path(RET_PATH library_path platform)
#
#    Create a valid static library path from a binary name or relative path
#
#     :library_path: the path to the library.
#     :platform: the target platform.
#
#     :RET_PATH: the output variable that contains the path to shared library.
#
function(create_Static_Lib_Path RET_PATH library_path platform)
  static_Library_Needs_Extension(NEEDS_EXT ${library_path} ${platform})
  # if it's not a path then construct it according to the platform
  if(NOT library_path MATCHES "/" # if it's not a path then construct it according to the platform
    AND NOT library_path MATCHES "^-l")#not an option
    if(WIN32)
      set(library_path lib/${library_path})
    elseif(library_path MATCHES "^lib.*")
      set(library_path lib/${library_path})
    else()
      set(library_path lib/lib${library_path})
    endif()
  endif()
  if(NEEDS_EXT)#OK no extension defined we can apply
    create_Static_Lib_Extension(RES_EXT ${platform})
    set(library_path "${library_path}${RES_EXT}")
  endif()
  set(${RET_PATH} ${library_path} PARENT_SCOPE)
endfunction(create_Static_Lib_Path)


#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Shared_Lib_Path| replace:: ``create_Shared_Lib_Path``
#  .. _create_Shared_Lib_Path:
#
#  create_Shared_Lib_Path
#  ----------------------
#
#   .. command:: create_Shared_Lib_Path(RET_PATH library_path platform soname)
#
#    Check whether a shared library needs to have a soname extension appended to its name.
#
#     :library_path: the path to the library.
#     :platform: the target platform.
#     :soname: the soname used by the library.
#
#     :RET_PATH: the output variable that contains the path to shared library.
#
function(create_Shared_Lib_Path RET_PATH library_path platform soname)
  shared_Library_Needs_Soname(RESULT_SONAME ${library_path} ${platform})
  # if it's not a path then construct it according to the platform
  if(NOT library_path MATCHES "/" #not a path
     AND NOT library_path MATCHES "^-l")#not an option
    if(WIN32)
      set(library_path lib/${library_path})
    elseif(library_path MATCHES "^lib.*")#the lib prefix is used
      set(library_path lib/${library_path})
    else()#no library prefix
      set(library_path lib/lib${library_path})
    endif()
  endif()
  if(RESULT_SONAME)#OK no extension defined we can apply
    create_Shared_Lib_Extension(RES_EXT ${platform} "${soname}")#create the soname extension
    set(library_path "${library_path}${RES_EXT}")
  endif()
  set(${RET_PATH} ${library_path} PARENT_SCOPE)
endfunction(create_Shared_Lib_Path)

#.rst:
#
# .. ifmode:: internal
#
#  .. |static_Library_Needs_Extension| replace:: ``static_Library_Needs_Extension``
#  .. _static_Library_Needs_Extension:
#
#  static_Library_Needs_Extension
#  -----------------------------------
#
#   .. command:: static_Library_Needs_Extension(NEEDS_EXT library_path platform)
#
#    Check whether a static library needs to have an extension appended to its name.
#
#     :library_path: the path to the library.
#     :platform: the target platform.
#
#     :NEEDS_EXT: the output variable that is TRUE if the extension finish by a SONAME.
#
function(static_Library_Needs_Extension NEEDS_EXT library_path platform)
  set(${NEEDS_EXT} TRUE PARENT_SCOPE)
  get_filename_component(EXTENSION ${library_path} EXT)#get the longest extension of the file
  if(NOT EXTENSION)
    return()
  endif()
  if(CURRENT_PLATFORM_OS STREQUAL "windows")
    set(target_extension "\\.lib")
  else()
    set(target_extension "\\.l?a")
  endif()
  if(EXTENSION MATCHES "^(\\.[^\\.]+)*${target_extension}$")#there is already a .so|.dylib|.dll extension
    # this check is here to ensure that a library name ending with a dot followed by any characters
    # will not be considered as a library extension (e.g. example libusb-1.0)
    set(${NEEDS_EXT} FALSE PARENT_SCOPE)
    return()
  endif()
endfunction(static_Library_Needs_Extension)


#.rst:
#
# .. ifmode:: internal
#
#  .. |convert_Library_Path_To_Default_System_Library_Link| replace:: ``convert_Library_Path_To_Default_System_Library_Link``
#  .. _convert_Library_Path_To_Default_System_Library_Link:
#
#  convert_Library_Path_To_Default_System_Library_Link
#  ---------------------------------------------------
#
#   .. command:: convert_Library_Path_To_Default_System_Library_Link(RESULTING_LINK library_path)
#
#    Concert a path to a system library into a linker option
#
#     :library_path: the path to the library.
#
#     :RESULTING_LINK: the output variable that contains the default system link option for the given library.
#
function(convert_Library_Path_To_Default_System_Library_Link RESULTING_LINK library_path)
  if(library_path MATCHES "^-l.*$")#OS dependency using standard library path => no need for conversion
    set(${RESULTING_LINK} ${library_path} PARENT_SCOPE)
    return()
  endif()
  get_filename_component(LIB_NAME ${library_path} NAME)
  #remove the extensions only if
  if(LIB_NAME MATCHES "^(.+)\\.(lib|l?a)$")#static library => need to force their usage
    set(${RESULTING_LINK} "${LIB_NAME}" PARENT_SCOPE)#keep the extension to force use of a static library
  else()
    string(REGEX REPLACE "^lib(.+)$" "\\1" LIB_NAME ${LIB_NAME})#remove the first "lib" characters if any
    if(APPLE)
      string(REGEX REPLACE "^(.+)\\.(\\.[0-9]+)*dylib$" "\\1" LIB_NAME ${LIB_NAME})
    elseif(UNIX)
      string(REGEX REPLACE "^(.+)\\.so(\\.[0-9]+)*$" "\\1" LIB_NAME ${LIB_NAME})
    else()
      string(REGEX REPLACE "^(.+)\\.dll(\\.[0-9]+)*$" "\\1" LIB_NAME ${LIB_NAME})
    endif()
    set(${RESULTING_LINK} "-l${LIB_NAME}" PARENT_SCOPE)
  endif()
endfunction(convert_Library_Path_To_Default_System_Library_Link)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Link_Type| replace:: ``get_Link_Type``
#  .. _get_Link_Type:
#
#  get_Link_Type
#  -------------
#
#   .. command:: get_Link_Type(RES_TYPE input_link)
#
#    Get the type of a link option based on the extension used (if any)
#
#     :input_link: the link option
#
#     :RES_TYPE: the output variable that contains the type of the target binary (SHARED, STATIC or OPTION if none of the two first) .
#
function(get_Link_Type RES_TYPE input_link)

set(${RES_TYPE} OPTION PARENT_SCOPE)# by default if no extension => considered as a specific linker option
get_filename_component(LIB_TYPE ${input_link} EXT)
if(LIB_TYPE)
    if(LIB_TYPE MATCHES "^(\\.[0-9]+)*\\.dylib$")#found shared lib (MACOSX)
		set(${RES_TYPE} SHARED PARENT_SCOPE)
	elseif(LIB_TYPE MATCHES "^\\.so(\\.[0-9]+)*$")#found shared lib (UNIX)
		set(${RES_TYPE} SHARED PARENT_SCOPE)
  elseif(LIB_TYPE MATCHES "^\\.dll$")#found shared lib (windows)
    set(${RES_TYPE} SHARED PARENT_SCOPE)
	elseif(LIB_TYPE MATCHES "^\\.a$")#found static lib (C)
		set(${RES_TYPE} STATIC PARENT_SCOPE)
	elseif(LIB_TYPE MATCHES "^\\.la$")#found static lib (libtools archives)
		set(${RES_TYPE} STATIC PARENT_SCOPE)
	elseif(LIB_TYPE MATCHES "^\\.lib$")#found lib (windows)
		set(${RES_TYPE} STATIC PARENT_SCOPE)
	endif()
endif()
endfunction(get_Link_Type)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Library_Type| replace:: ``is_Library_Type``
#  .. _is_Library_Type:
#
#  is_Library_Type
#  ---------------
#
#   .. command:: is_Library_Type(RESULT keyword)
#
#    Check whether the type of a component is a library.
#
#     :keyword: the type of the component.
#
#     :RESULT: the output variable that is TRUE if the component is a library, FALSE otherwise.
#
function(is_Library_Type RESULT keyword)
	if(keyword STREQUAL "HEADER"
		OR keyword STREQUAL "STATIC"
		OR keyword STREQUAL "SHARED"
		OR keyword STREQUAL "MODULE")
		set(${RESULT} TRUE PARENT_SCOPE)
	else()
		set(${RESULT} FALSE PARENT_SCOPE)
	endif()
endfunction(is_Library_Type)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Platform_Related_Binary_Prefix_Suffix| replace:: ``get_Platform_Related_Binary_Prefix_Suffix``
#  .. _get_Platform_Related_Binary_Prefix_Suffix:
#
#  get_Platform_Related_Binary_Prefix_Suffix
#  -----------------------------------------
#
#   .. command:: get_Platform_Related_Binary_Prefix_Suffix(PREFIX SUFFIX type_of_binary)
#
#    Get prefix and suffix of the name for a given component binary that depends on the platform and type of component.
#
#     :type_of_binary: the type of the component.
#
#     :PREFIX: the output variable that contains the prefix of the binary.
#
#     :SUFFIX: the output variable that contains the list of possible extension for the binary.
#
function(get_Platform_Related_Binary_Prefix_Suffix PREFIX SUFFIX type_of_binary)
  set(${PREFIX} PARENT_SCOPE)
  set(${SUFFIX} PARENT_SCOPE)
  if(type_of_binary STREQUAL "STATIC")
    set(${SUFFIX} ${CMAKE_STATIC_LIBRARY_SUFFIX} PARENT_SCOPE)
    set(${PREFIX} ${CMAKE_STATIC_LIBRARY_PREFIX} PARENT_SCOPE)
  elseif(type_of_binary STREQUAL "SHARED" OR type_of_binary STREQUAL "MODULE")
    if(CURRENT_PLATFORM_OS STREQUAL "macos")
      set(${SUFFIX} ${CMAKE_SHARED_LIBRARY_SUFFIX} ".tbd" PARENT_SCOPE)#.tbd are linker script in macos
    else()
      set(${SUFFIX} ${CMAKE_SHARED_LIBRARY_SUFFIX} PARENT_SCOPE)
    endif()
    set(${PREFIX} ${CMAKE_SHARED_LIBRARY_PREFIX} PARENT_SCOPE)
  elseif(type_of_binary STREQUAL "APPLICATION" OR type_of_binary STREQUAL "EXAMPLE")
    set(${SUFFIX} ${CMAKE_EXECUTABLE_SUFFIX} PARENT_SCOPE)
  endif()
endfunction(get_Platform_Related_Binary_Prefix_Suffix)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Application_Type| replace:: ``is_Application_Type``
#  .. _is_Application_Type:
#
#  is_Application_Type
#  -------------------
#
#   .. command:: is_Application_Type(RESULT keyword)
#
#    Check whether the type of a component is an application.
#
#     :keyword: the type of the component.
#
#     :RESULT: the output variable that is TRUE if the component is an application, FALSE otherwise.
#
function(is_Application_Type RESULT keyword)
	if(	keyword STREQUAL "TEST"
		OR keyword STREQUAL "APP"
		OR keyword STREQUAL "EXAMPLE")
		set(${RESULT} TRUE PARENT_SCOPE)
	else()
		set(${RESULT} FALSE PARENT_SCOPE)
	endif()
endfunction(is_Application_Type)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Package_Type| replace:: ``get_Package_Type``
#  .. _get_Package_Type:
#
#  get_Package_Type
#  ----------------
#
#   .. command:: get_Package_Type(package PACK_TYPE)
#
#    Given a package name, detects if this package is an external package or a native package depending on workspace content.
#
#     :package: the name of the package.
#
#     :PACK_TYPE: the output variable that contains the package type (NATIVE or EXTERNAL) if detected, UNKNOWN otherwise.
#
function(get_Package_Type package PACK_TYPE)
  #try to find it in source tree
  if(EXISTS ${WORKSPACE_DIR}/wrappers/${package} AND IS_DIRECTORY ${WORKSPACE_DIR}/wrappers/${package})
  	set(${PACK_TYPE} "EXTERNAL" PARENT_SCOPE)
    return()
  elseif(EXISTS ${WORKSPACE_DIR}/packages/${package} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
  	set(${PACK_TYPE} "NATIVE" PARENT_SCOPE)
    return()
  endif()
  # From here they are unknown in the local filesystem, finaly try to find references of this package
  # if not in source tree the package has been deployed from a reference file => use this information to deduce its type
  get_Path_To_External_Reference_File(RESULT_PATH PATH_TO_CS ${package})
  if(RESULT_PATH)
    set(${PACK_TYPE} "EXTERNAL" PARENT_SCOPE)
    return()
  else()
    get_Path_To_Package_Reference_File(RESULT_PATH PATH_TO_CS ${package})
    if(RESULT_PATH)
      set(${PACK_TYPE} "NATIVE" PARENT_SCOPE)
      return()
    endif()
  endif()
  set(${PACK_TYPE} "UNKNOWN" PARENT_SCOPE)
endfunction(get_Package_Type)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_External_Package_Defined| replace:: ``is_External_Package_Defined``
#  .. _is_External_Package_Defined:
#
#  is_External_Package_Defined
#  ---------------------------
#
#   .. command:: is_External_Package_Defined(RES_PATH_TO_PACKAGE ext_package mode)
#
#    Get the path to the target external package install folder.
#
#     :ext_package: the name of external package
#     :mode: the considered build mode
#
#     :RES_PATH_TO_PACKAGE: the output variable that contains the path to the external package install folder or NOTFOUND if package cannot be found in workspace.
#
function(is_External_Package_Defined RES_PATH_TO_PACKAGE ext_package mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(${ext_package}_FOUND${VAR_SUFFIX})
	set(${RES_PATH_TO_PACKAGE} ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${ext_package}/${${ext_package}_VERSION_STRING} PARENT_SCOPE)
else()
	set(${RES_PATH_TO_PACKAGE} PARENT_SCOPE)
endif()
endfunction(is_External_Package_Defined)


#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_External_Compiler_Options| replace:: ``resolve_External_Compiler_Options``
#  .. _resolve_External_Compiler_Options:
#
#  resolve_External_Compiler_Options
#  ---------------------------------
#
#   .. command:: resolve_External_Compiler_Options(RES ext_package link)
#
#    Extract from compiler options everything that may be put into more specific
#    features (includes, definitions) and set adequately corresponding variables.
#
#     :IN_OUT_OPTS: the input/output variable that contain compiler options.
#     :IN_OUT_OPTS: the input/output variable that contains preprocessor definitions.
#     :IN_OUT_INCS: the input/output variable that contains include directives.
#
function(resolve_External_Compiler_Options IN_OUT_OPTS IN_OUT_DEFS IN_OUT_INCS)
set(out_incs ${${IN_OUT_INCS}})
set(out_defs ${${IN_OUT_DEFS}})
set(out_opts)
#filtering compiler options
foreach(opt IN LISTS ${IN_OUT_OPTS})
  if(opt MATCHES "^(-D|/D)(.*)")
    list(APPEND out_defs ${CMAKE_MATCH_2})
  elseif(opt MATCHES "^(-I|/I|-isystem).*")
    list(APPEND out_incs ${CMAKE_MATCH_2})
  else()
    list(APPEND out_opts ${opt})
  endif()
endforeach()
#now resolving flags in definitions
set(final_defs)
foreach(def IN LISTS out_defs)
  if(def MATCHES "^(-D|/D)(.*)")
    list(APPEND final_defs ${CMAKE_MATCH_2})
  else()
    list(APPEND final_defs ${def})
  endif()
endforeach()
#now resolving flags in definitions
set(final_incs)
foreach(inc IN LISTS out_incs)
  if(inc MATCHES "^(-I|/I|-isystem).*")
    list(APPEND final_incs ${CMAKE_MATCH_2})
  else()
    list(APPEND final_incs ${inc})
  endif()
endforeach()
#returning
set(${IN_OUT_OPTS} ${out_opts} PARENT_SCOPE)
set(${IN_OUT_DEFS} ${final_defs} PARENT_SCOPE)
set(${IN_OUT_INCS} ${final_incs} PARENT_SCOPE)
endfunction(resolve_External_Compiler_Options)

#.rst:
#
# .. ifmode:: internal
#
#  .. |transform_External_Link_Into_Absolute_Path_Expression| replace:: ``transform_External_Link_Into_Absolute_Path_Expression``
#  .. _transform_External_Link_Into_Absolute_Path_Expression:
#
#  transform_External_Link_Into_Absolute_Path_Expression
#  -----------------------------------------------------
#
#   .. command:: transform_External_Link_Into_Absolute_Path_Expression(RES ext_package link)
#
#    From a linker option, generate a package tag `<ext_package>` at beginning of the expresion it is a relative path to a library of the external package.
#
#     :ext_package: the name of external package
#     :link: the linker flag that can be a path to a library
#
#     :RES: the output variable that contains the corresponding linker expression (possibly with an absolute path to a library).
#
function(transform_External_Link_Into_Absolute_Path_Expression RES ext_package link)
  #if the string DOES NOT start with a / (absolute path), a <package> (relative path from package root) or - (link option specification) then we add the header <package>
  if(link MATCHES  "^(<${ext_package}>|/|-|/).*")
    set(${RES} ${link} PARENT_SCOPE)#already well formed
  else()
    set(${RES} "<${ext_package}>/${link}" PARENT_SCOPE)# prepend the external package tag
  endif()
endfunction(transform_External_Link_Into_Absolute_Path_Expression)

#.rst:
#
# .. ifmode:: internal
#
#  .. |transform_External_Include_Into_Absolute_Path_Expression| replace:: ``transform_External_Include_Into_Absolute_Path_Expression``
#  .. _transform_External_Include_Into_Absolute_Path_Expression:
#
#  transform_External_Include_Into_Absolute_Path_Expression
#  --------------------------------------------------------
#
#   .. command:: transform_External_Include_Into_Absolute_Path_Expression(RES ext_package inc)
#
#    From an include option expression, generate a package tag `<ext_package>` at beginning of the expresion it is a relative path to an include folder of the external package.
#
#     :ext_package: the name of external package
#     :inc: the include flag that can be a path to an include folder.
#
#     :RES: the output variable that contains the corresponding include expression (possibly an absolute path to a folder).
#
function(transform_External_Include_Into_Absolute_Path_Expression RES ext_package inc)
  if(inc MATCHES "^(<${ext_package}>|/|/).*")
    set(${RES} ${inc} PARENT_SCOPE)
  else()#if the string DOES NOT start with a / (absolute path), or a <package> tag (relative path from package root) then we add the header <package> to the path
    set(${RES} "<${ext_package}>/${inc}" PARENT_SCOPE)# prepend the external package tag
  endif()
endfunction(transform_External_Include_Into_Absolute_Path_Expression)

#.rst:
#
# .. ifmode:: internal
#
#  .. |transform_External_Path_Into_Absolute_Path_Expression| replace:: ``transform_External_Path_Into_Absolute_Path_Expression``
#  .. _transform_External_Path_Into_Absolute_Path_Expression:
#
#  transform_External_Path_Into_Absolute_Path_Expression
#  -----------------------------------------------------
#
#   .. command:: transform_External_Path_Into_Absolute_Path_Expression(RES ext_package path)
#
#    From a path expression, generate a package tag `<ext_package>` at beginning of the expresion it is a relative path to a folder of the external package.
#
#     :ext_package: the name of external package
#     :path: the path expression.
#
#     :RES: the output variable that contains the corresponding path expression (an absolute path).
#
function(transform_External_Path_Into_Absolute_Path_Expression RES ext_package path)
  #if the string DOES NOT start with a / (absolute path) or by a <package> tag (relative path from package root), then then we add the <package> tag at the begginning of the target path.
  if(path MATCHES "^(<${ext_package}>|/).*$")
    set(${RES} ${path} PARENT_SCOPE)
  else()
    set(${RES} "<${ext_package}>/${path}" PARENT_SCOPE)# prepend the external package tag
  endif()
endfunction(transform_External_Path_Into_Absolute_Path_Expression)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_External_Libs_Path| replace:: ``resolve_External_Libs_Path``
#  .. _resolve_External_Libs_Path:
#
#  resolve_External_Libs_Path
#  --------------------------
#
#   .. command:: resolve_External_Libs_Path(COMPLETE_LINKS_PATH ext_links mode)
#
#    Resolve any kind of link option, either static or shared, absolute or relative to provide an absolute path (most of time pointing to a library in the workspace).
#
#     :ext_links: the link options to resolve.
#     :mode: the given build mode.
#
#     :COMPLETE_LINKS_PATH: the output variable that contains the resolved links (linker options may be let unchanged).
#
function(resolve_External_Libs_Path COMPLETE_LINKS_PATH ext_links mode)
set(res_links)
foreach(link IN LISTS ext_links)
  set(CMAKE_MATCH_1)
  set(CMAKE_MATCH_2)
  set(CMAKE_MATCH_3)
  if(link AND DEFINED ${link})#check if this is a variable coming from a configuration
    if(${link})#if this variable is not empty
      list(APPEND res_links ${${link}})
    endif()
    #otherwise this is a variable that must simply be omitted
  elseif(link MATCHES "^<([^>]+)>(.*)$")# a replacement has taken place => this is a full path to a library
    set(ext_package_name ${CMAKE_MATCH_1})
		is_External_Package_Defined(PATHTO ${ext_package_name} ${mode})
		if(NOT PATHTO)
      if(GLOBAL_PROGRESS_VAR)
        finish_Progress(${GLOBAL_PROGRESS_VAR})
      endif()
			message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for link ${link}!! Please set the path to this external package.")
		else()
			list(APPEND res_links ${PATHTO}${CMAKE_MATCH_2})
		endif()
	elseif(link MATCHES "^([^<]+)<([^>]+)>(.*)")# this may be a link with a prefix (like -L<path>) that need replacement
		set(link_prefix ${CMAKE_MATCH_1})
    set(ext_package_name ${CMAKE_MATCH_2})
		is_External_Package_Defined(PATHTO ${ext_package_name} ${mode})
		if(NOT PATHTO)
      if(GLOBAL_PROGRESS_VAR)
        finish_Progress(${GLOBAL_PROGRESS_VAR})
      endif()
      message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for link ${link}!!")
			return()
		endif()
		list(APPEND res_links ${link_prefix}${PATHTO}${CMAKE_MATCH_3})
	else()#this is a link that does not require any replacement (e.g. -l<library name> or -L<system path>)
		list(APPEND res_links ${link})
	endif()
endforeach()
set(${COMPLETE_LINKS_PATH} ${res_links} PARENT_SCOPE)
endfunction(resolve_External_Libs_Path)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_External_Includes_Path| replace:: ``resolve_External_Includes_Path``
#  .. _resolve_External_Includes_Path:
#
#  resolve_External_Includes_Path
#  ------------------------------
#
#   .. command:: resolve_External_Includes_Path(COMPLETE_INCLUDES_PATH ext_inc_dirs mode)
#
#    Resolve any kind of include path, either absolute or relative to provide an absolute path (most of time pointing to the adequate place in the workspace).
#
#     :ext_inc_dirs: the includes path to resolve.
#     :mode: the given build mode.
#
#     :COMPLETE_INCLUDES_PATH: the output variable that contains the resolved paths.
#
function(resolve_External_Includes_Path COMPLETE_INCLUDES_PATH ext_inc_dirs mode)
set(res_includes)
foreach(include_dir IN LISTS ext_inc_dirs)
  set(CMAKE_MATCH_1)
  set(CMAKE_MATCH_2)
  set(CMAKE_MATCH_3)
  if(include_dir AND DEFINED ${include_dir})#check if this is a variable coming from a configuration
    if(${include_dir})#if this variable is not empty
      list(APPEND res_includes ${${include_dir}})
    endif()
    #otherwise this is a variable that must simply be omitted
  elseif(include_dir MATCHES "^<([^>]+)>(.*)$")# a replacement has taken place => this is a full path to an incude dir of an external package
		set(ext_package_name ${CMAKE_MATCH_1})
		is_External_Package_Defined(PATHTO ${ext_package_name} ${mode})
		if(NOT PATHTO)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
			message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for include dir ${include_dir}!! Please set the path to this external package.")
		endif()
		list(APPEND res_includes ${PATHTO}${CMAKE_MATCH_2})
	elseif(include_dir MATCHES "^-I<([^>]+)>(.*)$")# this may be an include dir with a prefix (-I<path>) that need replacement
		set(ext_package_name ${CMAKE_MATCH_1})
		is_External_Package_Defined(PATHTO ${ext_package_name} ${mode})
		if(NOT PATHTO)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
			message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for include dir ${include_dir}!! Please set the path to this external package.")
		endif()
		list(APPEND res_includes${PATHTO}${CMAKE_MATCH_2})
	elseif(include_dir MATCHES "^-I(.+)")#this is an include dir that does not require any replacement => system include dir ! (should be avoided)
		list(APPEND res_includes ${CMAKE_MATCH_1})
	else()
		list(APPEND res_includes ${include_dir}) #for absolute path or system dependencies simply copying the absolute path
	endif()
endforeach()
#second path to remove default system path (avoid any trouble)
set(res_includes_without_system)
foreach(include_dir IN LISTS res_includes)
  is_A_System_Include_Path(IS_SYSTEM ${include_dir})
  if(NOT IS_SYSTEM)
    list(APPEND res_includes_without_system ${include_dir})
  endif()
endforeach()
set(${COMPLETE_INCLUDES_PATH} ${res_includes_without_system} PARENT_SCOPE)
endfunction(resolve_External_Includes_Path)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_External_Resources_Path| replace:: ``resolve_External_Resources_Path``
#  .. _resolve_External_Resources_Path:
#
#  resolve_External_Resources_Path
#  -------------------------------
#
#   .. command:: resolve_External_Resources_Path(COMPLETE_RESOURCES_PATH ext_resources mode)
#
#    Resolve path to runtime resources in order to get absolute path pointing to the adequate file or folder in the workspace.
#
#     :ext_resources: the path to runtime resources to resolve.
#     :mode: the given build mode.
#
#     :COMPLETE_RESOURCES_PATH: the output variable that contains the resolved paths.
#
function(resolve_External_Resources_Path COMPLETE_RESOURCES_PATH ext_resources mode)
set(res_resources)
foreach(resource IN LISTS ext_resources)
  set(CMAKE_MATCH_1)
  set(CMAKE_MATCH_2)
	if(resource MATCHES "^<([^>]+)>(.*)")# a replacement has taken place => this is a relative path to an external package resource
		set(ext_package_name ${CMAKE_MATCH_1})
		is_External_Package_Defined(PATHTO ${ext_package_name} ${mode})
		if(NOT PATHTO)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
			message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for resource ${resource}!! Please set the path to this external package.")
		else()
			list(APPEND res_resources ${PATHTO}${CMAKE_MATCH_2})
		endif()
  elseif(resource AND DEFINED ${resource})#the resource is not a path but a variable => need to interpret it !
    list(APPEND res_resources ${${resource}})	# evaluate the variable to get the system path
  else()#this is a relative path (relative to a native package) or an absolute path
		list(APPEND res_resources ${resource})	#for relative path or system dependencies (absolute path) simply copying the path
	endif()
endforeach()
set(${COMPLETE_RESOURCES_PATH} ${res_resources} PARENT_SCOPE)
endfunction(resolve_External_Resources_Path)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_External_Resources_Relative_Path| replace:: ``resolve_External_Resources_Relative_Path``
#  .. _resolve_External_Resources_Relative_Path:
#
#  resolve_External_Resources_Relative_Path
#  ----------------------------------------
#
#   .. command:: resolve_External_Resources_Relative_Path(RELATIVE_RESOURCES_PATH ext_resources mode)
#
#    Resolve relative path to runtime resources with respect to external package root dir.
#
#     :ext_resources: the path to runtime resources to resolve.
#     :mode: the given build mode.
#
#     :RELATIVE_RESOURCES_PATH: the output variable that contains the resolved relative paths (or absolute if system path).
#
function(resolve_External_Resources_Relative_Path RELATIVE_RESOURCES_PATH ext_resources mode)
set(res_resources)
foreach(resource IN LISTS ext_resources)
  set(CMAKE_MATCH_1)
  set(CMAKE_MATCH_2)
	if(resource MATCHES "^<[^>]+>(.*)")# a replacement has taken place => this is a relative path to an external package resource
		list(APPEND res_resources ${CMAKE_MATCH_1})
  elseif(resource AND DEFINED ${resource})#the resource is not a path but a variable => need to interpret it !
    list(APPEND res_resources ${${resource}})	# evaluate the variable to get the system path
  else()#this is a relative path (relative to an external package or an absolute path
		list(APPEND res_resources ${resource})	#for relative path or system dependencies (absolute path) simply copying the path
	endif()
endforeach()
set(${COMPLETE_RESOURCES_PATH} ${res_resources} PARENT_SCOPE)
endfunction(resolve_External_Resources_Relative_Path)

#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Variables_In_List| replace:: ``evaluate_Variables_In_List``
#  .. _evaluate_Variables_In_List:
#
#  evaluate_Variables_In_List
#  --------------------------
#
#   .. command:: evaluate_Variables_In_List(variable)
#
#     Evaluate the variables contained in a list.
#
#     :variable: the parent scope variable to evaluate. Its content will potentially be modified after execution.
#
#     :out_list: the output variable that contain the resulting list.
#
function(evaluate_Variables_In_List out_list variable)
  if(NOT variable OR NOT ${variable})#nothing inside parent scope variable
    set(${out_list} PARENT_SCOPE)
    return()
  endif()
  set(resulting_list)
  foreach(element IN LISTS ${variable})#for each element contained in the variable
    if(DEFINED ${element})#the element is a variable !!!
      list(APPEND resulting_list ${${element}})#we put into result the evaluation of this variable
    else()
      list(APPEND resulting_list ${element})#we directly put the value into result
    endif()
  endforeach()
  set(${out_list} ${resulting_list} PARENT_SCOPE)
endfunction(evaluate_Variables_In_List)


#.rst:
#
# .. ifmode:: internal
#
#  .. |append_Prefix_In_List| replace:: ``append_Prefix_In_List``
#  .. _append_Prefix_In_List:
#
#  append_Prefix_In_List
#  ---------------------
#
#   .. command:: append_Prefix_In_List(prefix variable)
#
#     Append a prefix string at the beginning of each element of a list.
#
#     :prefix: the string to append as prefix.
#     :variable: the input parent scope variable. Its content is modified after execution.
#
function(append_Prefix_In_List prefix variable)
  if(NOT variable OR NOT ${variable})#nothing inside parent scope variable
    return()
  endif()
  set(resulting_list)
  foreach(element IN LISTS ${variable})#for each element contained in the variable
    list(APPEND resulting_list "${prefix}${element}")
  endforeach()
  set(${variable} ${resulting_list} PARENT_SCOPE)
endfunction(append_Prefix_In_List)

#############################################################
################ Package Life cycle management ##############
#############################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Package_Repository_Address| replace:: ``set_Package_Repository_Address``
#  .. _set_Package_Repository_Address:
#
#  set_Package_Repository_Address
#  ------------------------------
#
#   .. command:: set_Package_Repository_Address(package git_url)
#
#    Adding an address for the git repository to the package description..
#
#     :package: the name ofthe target source package.
#     :git_url: the url to set.
#
function(set_Package_Repository_Address package git_url)
	file(READ ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE  "([ \t\n]+)YEAR" "\\1ADDRESS ${git_url}\n\\1YEAR" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt ${NEW_CONTENT})
endfunction(set_Package_Repository_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Package_Repository_Address| replace:: ``reset_Package_Repository_Address``
#  .. _reset_Package_Repository_Address:
#
#  reset_Package_Repository_Address
#  --------------------------------
#
#   .. command:: reset_Package_Repository_Address(package new_git_url)
#
#    Changing  the address of the git repository to a package description..
#
#     :package: the name ofthe target source package.
#     :new_git_url: the new giturl to set instead of existing one.
#
function(reset_Package_Repository_Address package new_git_url)
	file(READ ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE "([ \t\n]+)ADDRESS([ \t\n]+)([^ \t\n]+)([ \t\n]+)" "\\1ADDRESS\\2${new_git_url}\\4" NEW_CONTENT ${CONTENT})
	string(REGEX REPLACE "([ \t\n]+)PUBLIC_ADDRESS([ \t\n]+)([^ \t\n]+)([ \t\n]+)" "\\1PUBLIC_ADDRESS\\2${new_git_url}\\4" FINAL_CONTENT ${NEW_CONTENT})
	file(WRITE ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt ${FINAL_CONTENT})
endfunction(reset_Package_Repository_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Deployment_Unit_Repository_Address_In_Description| replace:: ``get_Deployment_Unit_Repository_Address_In_Description``
#  .. _get_Deployment_Unit_Repository_Address_In_Description:
#
#  get_Deployment_Unit_Repository_Address_In_Description
#  -----------------------------------------------------
#
#   .. command:: get_Deployment_Unit_Repository_Address_In_Description(path_to_repo RES_URL RES_PUBLIC_URL)
#
#    Getting git repository addresses of a deployment unit from its description.
#
#     :path_to_repo: the path to deployment unit repository in local workspace.
#
#     :RES_URL: the output variable that contains the current git URL of teh pakage respository.
#     :RES_PUBLIC_URL: the output variable that contains the public counterpart URL of package respotiry.
#
function(get_Deployment_Unit_Repository_Address_In_Description path_to_repo RES_URL RES_PUBLIC_URL)
  if(NOT EXISTS ${path_to_repo}/CMakeLists.txt)
	  set(${RES_URL} PARENT_SCOPE)
    set(${RES_PUBLIC_URL} PARENT_SCOPE)
    return()
  endif()

	file(READ ${path_to_repo}/CMakeLists.txt CMAKE_CONTENT)
	#checking for restricted address
	if(CMAKE_CONTENT MATCHES "^.+[ \t\n]ADDRESS[ \t\n]+([^ \t\n]+)[ \t\n]+.*$")
    set(${RES_URL} ${CMAKE_MATCH_1} PARENT_SCOPE)
	else()
    set(${RES_URL} PARENT_SCOPE)
	endif()
	#checking for public (fetch only) address
	if(CMAKE_CONTENT MATCHES "^.+[ \t\n]PUBLIC_ADDRESS[ \t\n]+([^ \t\n]+)[ \t\n]+.*$")
    set(${RES_PUBLIC_URL} ${CMAKE_MATCH_1} PARENT_SCOPE)
	else()
    set(${RES_PUBLIC_URL} PARENT_SCOPE)
	endif()
endfunction(get_Deployment_Unit_Repository_Address_In_Description)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Deployment_Unit_Reference_Info| replace:: ``get_Deployment_Unit_Reference_Info``
#  .. _get_Deployment_Unit_Reference_Info:
#
#  get_Deployment_Unit_Reference_Info
#  ----------------------------------
#
#   .. command:: get_Deployment_Unit_Reference_Info(path_to_repo REF_EXISTS RES_URL RES_PUBLIC_URL)
#
#    Getting info on a deployment unit extracted from its reference file.
#
#     :path_to_repo: the path to the repository of the deployment unit into local workspace.
#
#     :REF_EXISTS: the output variable that is TRUE if reference file exists, FALSE otherwise.
#     :RES_URL: the output variable that contains the current git URL of the pakage respository.
#     :RES_PUBLIC_URL: the output variable that contains the public counterpart URL of package respotiry.
#
function(get_Deployment_Unit_Reference_Info path_to_repo REF_EXISTS RES_URL RES_PUBLIC_URL)
  set(${RES_URL} PARENT_SCOPE)
  set(${RES_PUBLIC_URL} PARENT_SCOPE)
  set(${REF_EXISTS} FALSE PARENT_SCOPE)

  get_filename_component(DU_PATH ${path_to_repo} DIRECTORY)#type can be deduced from containing folder
  get_filename_component(DU_NAME ${path_to_repo} NAME)#DUname is the name of the folder (last element of the path)

  set(DU_TYPE)

  if(DU_PATH MATCHES "packages$")
    set(DU_TYPE "package")
  elseif(DU_PATH MATCHES "wrappers$")
    set(DU_TYPE "wrapper")
  elseif(DU_PATH MATCHES "sites/frameworks$")
    set(DU_TYPE "framework")
  elseif(DU_PATH MATCHES "environments$")
    set(DU_TYPE "environment")
  else()
    #we are in a context of a standalone install or CI build,
    # so path_to_repo is not located into the workspace
    #trying to find adequate name in workspace
    if(EXISTS ${WORKSPACE_DIR}/packages/${DU_NAME})
      set(DU_TYPE "package")
    elseif(${WORKSPACE_DIR}/wrappers/${DU_NAME})
      set(DU_TYPE "wrapper")
    elseif(${WORKSPACE_DIR}/sites/frameworks/${DU_NAME})
      set(DU_TYPE "framework")
    elseif(${WORKSPACE_DIR}/environments/${DU_NAME})
      set(DU_TYPE "environment")
    else()
      message("[PID] INTERNAL ERROR: Bad path given to get_Deployment_Unit_Reference_Info: ${path_to_repo}")
      return()
    endif()
  endif()

  if(DU_TYPE STREQUAL "package")
    get_Path_To_Package_Reference_File(PATH_TO_FILE PATH_TO_CS ${DU_NAME})
  elseif(DU_TYPE STREQUAL "wrapper")
    get_Path_To_External_Reference_File(PATH_TO_FILE PATH_TO_CS ${DU_NAME})
  elseif(DU_TYPE STREQUAL "framework")
    get_Path_To_Framework_Reference_File(PATH_TO_FILE PATH_TO_CS ${DU_NAME})
  elseif(DU_TYPE STREQUAL "environment")
    get_Path_To_Environment_Reference_File(PATH_TO_FILE PATH_TO_CS ${DU_NAME})
  endif()
  if(NOT PATH_TO_FILE)
    update_Contribution_Spaces(UPDATED)
    if(UPDATED)
      if(DU_TYPE STREQUAL "package")
        get_Path_To_Package_Reference_File(PATH_TO_FILE PATH_TO_CS ${DU_NAME})
      elseif(DU_TYPE STREQUAL "wrapper")
        get_Path_To_External_Reference_File(PATH_TO_FILE PATH_TO_CS ${DU_NAME})
      elseif(DU_TYPE STREQUAL "framework")
        get_Path_To_Framework_Reference_File(PATH_TO_FILE PATH_TO_CS ${DU_NAME})
      elseif(DU_TYPE STREQUAL "environment")
        get_Path_To_Environment_Reference_File(PATH_TO_FILE PATH_TO_CS ${DU_NAME})
      endif()
    else()
      return()
    endif()
  endif()
  set(${REF_EXISTS} TRUE PARENT_SCOPE)

  #MEMORIZATION INTO temporary variables
  # common to all types of deployment units
  set(TEMP_${DU_NAME}_MAIN_AUTHOR ${${DU_NAME}_MAIN_AUTHOR})
  set(TEMP_${DU_NAME}_MAIN_INSTITUTION ${${DU_NAME}_MAIN_INSTITUTION})
  set(TEMP_${DU_NAME}_CONTACT_MAIL ${${DU_NAME}_CONTACT_MAIL})
  set(TEMP_${DU_NAME}_AUTHORS_AND_INSTITUTIONS ${${DU_NAME}_AUTHORS_AND_INSTITUTIONS})
  set(TEMP_${DU_NAME}_YEARS ${${DU_NAME}_YEARS})
  set(TEMP_${DU_NAME}_DESCRIPTION ${${DU_NAME}_DESCRIPTION})
  set(TEMP_${DU_NAME}_LICENSE ${${DU_NAME}_LICENSE})
  set(TEMP_${DU_NAME}_ADDRESS ${${DU_NAME}_ADDRESS})
  set(TEMP_${DU_NAME}_PUBLIC_ADDRESS ${${DU_NAME}_PUBLIC_ADDRESS})
  set(TEMP_${DU_NAME}_PROJECT_PAGE ${${DU_NAME}_PROJECT_PAGE})
  if(NOT DU_TYPE STREQUAL "environment")#common to all except environments
    set(TEMP_${DU_NAME}_CATEGORIES ${${DU_NAME}_CATEGORIES})
    if(DU_TYPE STREQUAL "framework")#specific to frameworks: generated site
      set(TEMP_${DU_NAME}_SITE ${${DU_NAME}_SITE})
    else()#common to wrappers and packages
      set(TEMP_${DU_NAME}_FRAMEWORK ${${DU_NAME}_FRAMEWORK})
      set(TEMP_${DU_NAME}_SITE_ROOT_PAGE ${${DU_NAME}_SITE_ROOT_PAGE})
      set(TEMP_${DU_NAME}_SITE_GIT_ADDRESS ${${DU_NAME}_SITE_GIT_ADDRESS})
      set(TEMP_${DU_NAME}_SITE_INTRODUCTION ${${DU_NAME}_SITE_INTRODUCTION})
      set(TEMP_${DU_NAME}_REFERENCES ${${DU_NAME}_REFERENCES})
      if(DU_TYPE STREQUAL "wrapper")#specific to wrappers: description of original project
        set(TEMP_${DU_NAME}_ORIGINAL_PROJECT_AUTHORS ${${DU_NAME}_ORIGINAL_PROJECT_AUTHORS})
        set(TEMP_${DU_NAME}_ORIGINAL_PROJECT_SITE ${${DU_NAME}_ORIGINAL_PROJECT_SITE})
        set(TEMP_${DU_NAME}_ORIGINAL_PROJECT_LICENSES ${${DU_NAME}_ORIGINAL_PROJECT_LICENSES})
      endif()
    endif()
  endif()

  #then include (will modify these cache variables)
  include(${PATH_TO_FILE})
  #returning adresses
  set(${RES_URL} ${${DU_NAME}_ADDRESS} PARENT_SCOPE)
  set(${RES_PUBLIC_URL} ${${DU_NAME}_PUBLIC_ADDRESS} PARENT_SCOPE)

  #RESET INITIAL VALUES FROM temporary variables
  # common to all types of deployment units
  set(${DU_NAME}_MAIN_AUTHOR ${TEMP_${DU_NAME}_MAIN_AUTHOR} CACHE INTERNAL "")
  set(${DU_NAME}_MAIN_INSTITUTION ${TEMP_${DU_NAME}_MAIN_INSTITUTION} CACHE INTERNAL "")
  set(${DU_NAME}_CONTACT_MAIL ${TEMP_${DU_NAME}_CONTACT_MAIL} CACHE INTERNAL "")
  set(${DU_NAME}_AUTHORS_AND_INSTITUTIONS ${TEMP_${DU_NAME}_AUTHORS_AND_INSTITUTIONS} CACHE INTERNAL "")
  set(${DU_NAME}_YEARS ${TEMP_${DU_NAME}_YEARS} CACHE INTERNAL "")
  set(${DU_NAME}_DESCRIPTION ${TEMP_${DU_NAME}_DESCRIPTION} CACHE INTERNAL "")
  set(${DU_NAME}_LICENSE ${TEMP_${DU_NAME}_LICENSE} CACHE INTERNAL "")
  set(${DU_NAME}_ADDRESS ${TEMP_${DU_NAME}_ADDRESS} CACHE INTERNAL "")
  set(${DU_NAME}_PUBLIC_ADDRESS ${TEMP_${DU_NAME}_PUBLIC_ADDRESS} CACHE INTERNAL "")
  set(${DU_NAME}_PROJECT_PAGE ${TEMP_${DU_NAME}_PROJECT_PAGE} CACHE INTERNAL "")
  if(NOT DU_TYPE STREQUAL "environment")#common to all except environments
    set(${DU_NAME}_CATEGORIES ${TEMP_${DU_NAME}_CATEGORIES} CACHE INTERNAL "")
    if(DU_TYPE STREQUAL "framework")#specific to frameworks: generated site
      set(${DU_NAME}_SITE ${TEMP_${DU_NAME}_SITE} CACHE INTERNAL "")
    else()#common to wrapper and packages
      set(${DU_NAME}_FRAMEWORK ${TEMP_${DU_NAME}_FRAMEWORK} CACHE INTERNAL "")
      set(${DU_NAME}_SITE_ROOT_PAGE ${TEMP_${DU_NAME}_SITE_ROOT_PAGE} CACHE INTERNAL "")
      set(${DU_NAME}_SITE_GIT_ADDRESS ${TEMP_${DU_NAME}_SITE_GIT_ADDRESS} CACHE INTERNAL "")
      set(${DU_NAME}_SITE_INTRODUCTION ${TEMP_${DU_NAME}_SITE_INTRODUCTION} CACHE INTERNAL "")
      set(${DU_NAME}_REFERENCES ${TEMP_${DU_NAME}_REFERENCES} CACHE INTERNAL "")
      if(DU_TYPE STREQUAL "wrapper")#specific to wrappers: description of original project
        set(${DU_NAME}_ORIGINAL_PROJECT_AUTHORS ${TEMP_${DU_NAME}_ORIGINAL_PROJECT_AUTHORS} CACHE INTERNAL "")
        set(${DU_NAME}_ORIGINAL_PROJECT_SITE ${TEMP_${DU_NAME}_ORIGINAL_PROJECT_SITE} CACHE INTERNAL "")
        set(${DU_NAME}_ORIGINAL_PROJECT_LICENSES ${TEMP_${DU_NAME}_ORIGINAL_PROJECT_LICENSES} CACHE INTERNAL "")
      endif()
    endif()
  endif()
endfunction(get_Deployment_Unit_Reference_Info)


#.rst:
#
# .. ifmode:: internal
#
#  .. |list_All_Source_Packages_In_Workspace| replace:: ``list_All_Source_Packages_In_Workspace``
#  .. _list_All_Source_Packages_In_Workspace:
#
#  list_All_Source_Packages_In_Workspace
#  -------------------------------------
#
#   .. command:: list_All_Source_Packages_In_Workspace(PACKAGES)
#
#    Getting all source packages that currently exist in local workspace.
#
#     :PACKAGES: the output variable that contains the list of package of the workspace.
#
function(list_All_Source_Packages_In_Workspace PACKAGES)
file(GLOB source_packages RELATIVE ${WORKSPACE_DIR}/packages ${WORKSPACE_DIR}/packages/*)
foreach(a_file IN LISTS source_packages)
	if(EXISTS ${WORKSPACE_DIR}/packages/${a_file} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${a_file})
		list(APPEND result ${a_file})
	endif()
endforeach()
set(${PACKAGES} ${result} PARENT_SCOPE)
endfunction(list_All_Source_Packages_In_Workspace)


#.rst:
#
# .. ifmode:: internal
#
#  .. |list_All_Wrappers_In_Workspace| replace:: ``list_All_Wrappers_In_Workspace``
#  .. _list_All_Wrappers_In_Workspace:
#
#  list_All_Wrappers_In_Workspace
#  ------------------------------
#
#   .. command:: list_All_Wrappers_In_Workspace(WRAPPERS)
#
#    Getting all external packages wrappers that currently exist in local workspace.
#
#     :WRAPPERS: the output variable that contains the list of wrappers of the workspace.
#
function(list_All_Wrappers_In_Workspace WRAPPERS)
  file(GLOB source_wrappers RELATIVE ${WORKSPACE_DIR}/wrappers ${WORKSPACE_DIR}/wrappers/*)
  foreach(a_file IN LISTS source_wrappers)
  	if(EXISTS ${WORKSPACE_DIR}/wrappers/${a_file} AND IS_DIRECTORY ${WORKSPACE_DIR}/wrappers/${a_file})
  		list(APPEND result ${a_file})
  	endif()
  endforeach()
  set(${WRAPPERS} ${result} PARENT_SCOPE)
endfunction(list_All_Wrappers_In_Workspace)

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_All_Binary_Packages_In_Workspace| replace:: ``list_All_Binary_Packages_In_Workspace``
#  .. _list_All_Binary_Packages_In_Workspace:
#
#  list_All_Binary_Packages_In_Workspace
#  -------------------------------------
#
#   .. command:: list_All_Binary_Packages_In_Workspace(BIN_PACKAGES)
#
#    Getting all binary packages (native and external) that currently exist in local workspace.
#
#     :BIN_PACKAGES: the output variable that contains the list of  binary packages in the workspace.
#
function(list_All_Binary_Packages_In_Workspace BIN_PACKAGES)
file(GLOB bin_pakages RELATIVE ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM} ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/*)
foreach(a_file IN LISTS bin_pakages)
	if(EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${a_file}
  AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${a_file})
		list(APPEND result ${a_file})
	endif()
endforeach()
set(${BIN_PACKAGES} ${result} PARENT_SCOPE)
endfunction(list_All_Binary_Packages_In_Workspace)

#.rst:
#
# .. ifmode:: internal
#
#  .. |package_Already_Built| replace:: ``package_Already_Built``
#  .. _package_Already_Built:
#
#  package_Already_Built
#  ---------------------
#
#   .. command:: package_Already_Built(ANSWER package version reference_package)
#
#    Tells Wether a source package used as a dependency by another package needs is already built from is using package point of view.
#
#     :package: the name of the package used as a dependency.
#     :version: the version of the package used as a dependency.
#     :reference_package: the name of the package using the dependency.
#
#     :ANSWER: the output variable that is TRUE if package needs to be rebuilt, FALSE otherwise.
#
function(package_Already_Built ANSWER package version reference_package)
  set(${ANSWER} FALSE PARENT_SCOPE)
  set(use_file_dep ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${version}/share/Use${package}-${version}.cmake)
  set(build_file ${WORKSPACE_DIR}/packages/${reference_package}/build/build_process)
  if(NOT EXISTS ${use_file_dep})#no use file installed so package is not already considered as built
    return()
  elseif(NOT EXISTS ${build_file} OR ${use_file_dep} IS_NEWER_THAN ${build_file})
    set(${ANSWER} TRUE PARENT_SCOPE)#no need to rebuild since we know that dependency package has been built since last build of reference_package
    return()#not built after cleaning => not already built
  endif()
  #otherwise we are not sure so package is considered as not already built
endfunction(package_Already_Built)

#.rst:
#
# .. ifmode:: internal
#
#  .. |package_Dependency_Needs_To_Be_Rebuilt| replace:: ``package_Dependency_Needs_To_Be_Rebuilt``
#  .. _package_Dependency_Needs_To_Be_Rebuilt:
#
#  package_Dependency_Needs_To_Be_Rebuilt
#  --------------------------------------
#
#   .. command:: package_Dependency_Needs_To_Be_Rebuilt(ANSWER package version reference_package)
#
#    Tells Wether a source package used as a dependency by another package needs to be rebuilt or not.
#
#     :package: the name of the package used as a dependency.
#     :version: the version of the package used as a dependency.
#     :reference_package: the name of the package using the dependency.
#
#     :ANSWER: the output variable that is TRUE if package needs to be rebuilt, FALSE otherwise.
#
function(package_Dependency_Needs_To_Be_Rebuilt ANSWER package version reference_package)
  set(${ANSWER} FALSE PARENT_SCOPE)
  package_Already_Built(ALREADY_BUILT ${package} ${version} ${reference_package})
  if(NOT ALREADY_BUILT)# if not already built since last build of reference package there may have modifications to build
    get_Repository_Current_Branch(BRANCH_NAME ${WORKSPACE_DIR}/packages/${package})
    if(BRANCH_NAME AND NOT BRANCH_NAME STREQUAL "master")#check if package currently in development
      # if on integration branch or another feature specific branch (not on master or on an "isolated" commit like one pointed by a tag)
      # then the dependency may have to be rebuilt
      # 1) check if the rebuild of the package dependency is not newer than refenrence package (if true it means that this later has been
      # rebuild since last build of reference package and did not generate the use file !)
      set(build_file ${WORKSPACE_DIR}/packages/${reference_package}/build/build_process)
      set(build_file_dep ${WORKSPACE_DIR}/packages/${package}/build/build_process)
      if(${build_file_dep} IS_NEWER_THAN ${build_file})
        return()
      endif()
      # 2) check if the version used is not already released, in this case it is not an in development version by definition
      # so no need to rebuild.
      get_Repository_Version_Tags(VERSION_NUMBERS ${package})
      list(FIND VERSION_NUMBERS ${version} INDEX)
      if(INDEX EQUAL -1)
        #OK target version is not release yet we suppose the package can have modifications
        set(${ANSWER} TRUE PARENT_SCOPE)
      endif()
    endif()
  endif()
endfunction(package_Dependency_Needs_To_Be_Rebuilt)


#.rst:
#
# .. ifmode:: internal
#
#  .. |test_Modified_Components| replace:: ``test_Modified_Components``
#  .. _test_Modified_Components:
#
#  test_Modified_Components
#  ------------------------
#
#   .. command:: test_Modified_Components(package build_tool RESULT)
#
#    Check wether components of a package have any modifications.
#
#     :package: the name of the target package.
#     :build_tool: the path to build toolin use (e.g. make).
#
#     :RESULT: the output variable that is TRUE if any component of package has modifications, FALSE otherwise.
#
function(test_Modified_Components package build_tool RESULT)
set(${RESULT} FALSE PARENT_SCOPE)
if(CMAKE_GENERATOR STREQUAL "Unix Makefiles")#rule to check if any modification is generated only by makefiles
  execute_process(COMMAND ${build_tool} cmake_check_build_system
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build
                  OUTPUT_VARIABLE NEED_UPDATE)
  if(NOT NEED_UPDATE STREQUAL "")
  	set(${RESULT} TRUE PARENT_SCOPE)
  endif()
endif()
endfunction(test_Modified_Components)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Version_Number_And_Repo_From_Package| replace:: ``get_Version_Number_And_Repo_From_Package``
#  .. _get_Version_Number_And_Repo_From_Package:
#
#  get_Version_Number_And_Repo_From_Package
#  ----------------------------------------
#
#   .. command:: get_Version_Number_And_Repo_From_Package(package DIGITS STRING_NUMBER ADDRESS)
#
#    Get information from the description of a source package (e.g. data extracted from its CMakeLists.txt).
#
#     :package: the name of the target package.
#
#     :DIGITS: the output variable that list of numbers bound to the version (major;minor[;patch]).
#     :STRING: the output variable that contains the PID normalized string of package version number.
#     :FORMAT: the output variable that contains the format of the specified version (DOTTED_STRING or DIGITS).
#     :METHOD: the output variable that contains the method used to specify the version (FUNCTION or ARG).
#     :ADDRESS: the output variable that contains the address of the repository.
#
#
function(get_Version_Number_And_Repo_From_Package package DIGITS STRING FORMAT METHOD ADDRESS)
set(${ADDRESS} PARENT_SCOPE)
file(STRINGS ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt PACKAGE_METADATA) #getting global info on the package
#parsing the file to find where version is given (in package declaration VERSION argument or in set_PID_Package_Version call)
set(WITH_ARG FALSE)
set(WITH_FUNCTION FALSE)
set(IN_DECLARE FALSE)
set(ADDR_OK FALSE)
set(declare_function_regex_pattern "([dD][eE][cC][lL][Aa][rR][eE]_)?[pP][iI][dD]_[pP][aA][cC][kK][aA][gG][eE]")
set(version_function_regex_pattern "[sS][eE][tT]_[pP][iI][dD]_[pP][aA][cC][kK][aA][gG][eE]_[vV][eE][rR][sS][iI][oO][nN]")

foreach(line IN LISTS PACKAGE_METADATA)
	if(line)
    if(line MATCHES "^[^#]*${declare_function_regex_pattern}[ \t]*\\((.*)$")
      set(IN_DECLARE TRUE)
      if("${CMAKE_MATCH_2}" MATCHES "^[^#]*VERSION[ \t]+([0-9\\. \t]+).*$")#check if version argument not on first line
        # string(REGEX REPLACE "^[^#]*VERSION([0-9\\. \t]+).*$" "\\1" VERSION_ARGS ${line})#extract the argument for version (either digits or version string)
        parse_Version_Argument("${CMAKE_MATCH_1}" VERSION_DIGITS VERSION_FORMAT)#CMAKE_MATCH_1 changed because of last if .. MATCHES
        set(WITH_ARG TRUE)
      endif()
    elseif(IN_DECLARE AND (NOT WITH_ARG) #still after declare call but not found any VERSION argument yet
      AND (line MATCHES "^[^#]*${version_function_regex_pattern}[ \t]*\\(([0-9][0-9\\. \t]+)\\).*$"))#this is a call to set_PID_Package_Version function
      set(IN_DECLARE FALSE)# call to set_pid_package means we are outside of the declare function
      parse_Version_Argument("${CMAKE_MATCH_1}" VERSION_DIGITS VERSION_FORMAT)
      set(WITH_FUNCTION TRUE)
    elseif(IN_DECLARE AND
      (line MATCHES "^[^#]*ADDRESS[ \t]+([^ \t]+\\.git).*"))
      set(${ADDRESS} ${CMAKE_MATCH_1} PARENT_SCOPE)#an address has been found
      set(ADDR_OK TRUE)
    elseif(IN_DECLARE AND (NOT WITH_ARG)
      AND (line MATCHES "^[^#]*VERSION[ \t]+([0-9][0-9\\. \t]+).*$"))
      parse_Version_Argument("${CMAKE_MATCH_1}" VERSION_DIGITS VERSION_FORMAT)
      set(WITH_ARG TRUE)
    endif()
	endif()
  if((WITH_ARG OR WITH_FUNCTION) AND ADDR_OK)#just to avoid parsing the whole file !
    break()
  endif()
endforeach()

set(${DIGITS} ${VERSION_DIGITS} PARENT_SCOPE)

if(VERSION_DIGITS)
	#from here we are sure there is at least 2 digits
	list(GET VERSION_DIGITS 0 MAJOR)
	list(GET VERSION_DIGITS 1 MINOR)
	list(LENGTH VERSION_DIGITS size_of_version)
	if(size_of_version LESS 3)# no patch version defined
		set(PATCH 0)
		list(APPEND VERSION_DIGITS 0)
	else()
		list(GET VERSION_DIGITS 2 PATCH)
	endif()
	set(${STRING} "${MAJOR}.${MINOR}.${PATCH}" PARENT_SCOPE)
  set(${FORMAT} ${VERSION_FORMAT} PARENT_SCOPE)
  if(WITH_FUNCTION)
    set(${METHOD} "FUNCTION" PARENT_SCOPE)
  else()
    set(${METHOD} "ARG" PARENT_SCOPE)
  endif()
else()
	set(${STRING} PARENT_SCOPE)
  set(${FORMAT} PARENT_SCOPE)
  set(${METHOD} PARENT_SCOPE)
endif()

endfunction(get_Version_Number_And_Repo_From_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Version_Number_To_Package| replace:: ``set_Version_Number_To_Package``
#  .. _set_Version_Number_To_Package:
#
#  set_Version_Number_To_Package
#  ----------------------------------------
#
#   .. command:: set_Version_Number_To_Package(RESULT_OK package format major minor patch)
#
#    Set the version in package description (e.g. CMakeLists.txt).
#
#     :package: the name of the target package.
#     :format: the format used to write the version (dotted string notation -DOTTED_STRING- or list of digits -DIGITS).
#     :method: the method used to specify the version (with dedicated function -FUNCTION- or as argument of package declaration -ARG).
#     :major: major number of the package version.
#     :minor: minor number of the package version.
#     :patch: patch number of the package version.
#
#     :RESULT_OK: the output variable that is TRUE if
#
function(set_Version_Number_To_Package RESULT_OK package format method major minor patch)
file(STRINGS ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt PACKAGE_METADATA) #getting global info on the package
set(${RESULT_OK} TRUE PARENT_SCOPE)
set(BEGIN "")
set(END "")
set(SIGNATURE_FOUND FALSE)

set(declare_function_regex_pattern "([dD][eE][cC][lL][Aa][rR][eE]_)?([pP][iI][dD]_[pP][aA][cC][kK][aA][gG][eE])")
set(version_function_regex_pattern "[sS][eE][tT]_[pP][iI][dD]_[pP][aA][cC][kK][aA][gG][eE]_[vV][eE][rR][sS][iI][oO][nN]")

if(method STREQUAL "FUNCTION")#using function set_PID_Package_Version
  foreach(line IN LISTS PACKAGE_METADATA)
  	if(line MATCHES "^([^#]*${version_function_regex_pattern}[ \t]*\\()[^\\)]+(\\).*)$")#this is a call to set_PID_Package_Version function
        set(SIGNATURE_FOUND TRUE)
        set(BEGIN "${BEGIN}${CMAKE_MATCH_1}")
        set(END "${CMAKE_MATCH_2}\n")
    else()
      if(NOT SIGNATURE_FOUND)
        set(BEGIN "${BEGIN}${line}\n")
      else()
        set(END "${END}${line}\n")
      endif()
    endif()
  endforeach()
else()# VERSION argument of package method=="ARG"
  set(IN_DECLARE FALSE)
  foreach(line IN LISTS PACKAGE_METADATA)
    if(NOT SIGNATURE_FOUND AND (line MATCHES "^[^#]*${declare_function_regex_pattern}[ \t]*\\(.*$"))#the pattern for declare function has been found
      set(declare_function_signature ${CMAKE_MATCH_1}${CMAKE_MATCH_2})
      set(IN_DECLARE TRUE)
      if(line MATCHES "^([^#]*${declare_function_signature}[ \t]*\\([^#]*VERSION[ \t]+)[0-9][0-9\\. \t]+(.*)$")#check if version not on first line
        set(SIGNATURE_FOUND TRUE)
        set(BEGIN "${BEGIN}${CMAKE_MATCH_1}")
        set(END "${CMAKE_MATCH_2}\n")
      else()#VERSION argument not found on that line
        #simply copy the whole line
        set(BEGIN "${BEGIN}${line}\n")
      endif()
    elseif(IN_DECLARE AND (NOT SIGNATURE_FOUND) #searching in declare function but not at first line
          AND (line MATCHES "^([^#]*VERSION[ \t]+)[0-9][0-9\\. \t]+(.*)$"))
      set(SIGNATURE_FOUND TRUE)
      set(BEGIN "${BEGIN}${CMAKE_MATCH_1}")
      set(END "${CMAKE_MATCH_2}\n")
    else() #other lines
      if(NOT SIGNATURE_FOUND)
        set(BEGIN "${BEGIN}${line}\n")
      else()
        set(END "${END}${line}\n")
      endif()
    endif()
  endforeach()
endif()
if(NOT SIGNATURE_FOUND)
  set(${RESULT_OK} FALSE PARENT_SCOPE)
  return()
endif()
#OK simply write new version string at good place
if(format STREQUAL DIGITS)#version formatted as a list of digits
  set(TO_WRITE "${BEGIN}${major} ${minor} ${patch}${END}")
else()#version formatted with dotted notation
  set(TO_WRITE "${BEGIN}${major}.${minor}.${patch}${END}")
endif()
file(WRITE ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt ${TO_WRITE})
endfunction(set_Version_Number_To_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Binary_Package_Version_In_Development| replace:: ``is_Binary_Package_Version_In_Development``
#  .. _is_Binary_Package_Version_In_Development:
#
#  is_Binary_Package_Version_In_Development
#  ----------------------------------------
#
#   .. command:: is_Binary_Package_Version_In_Development(RESULT package version)
#
#    Check wether a given binary package version is in development state. That means the version in used is not a released version.
#
#     :package: the name of the target package.
#     :version: target version of the package.
#
#     :RESULT: the output variable taht is TRUE if package version is in development (not released), FALSE otherwise
#
function(is_Binary_Package_Version_In_Development RESULT package version)
set(${RESULT} FALSE PARENT_SCOPE)
set(USE_FILE ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${version}/share/Use${package}-${version}.cmake)
if(EXISTS ${USE_FILE}) #file does not exists means the target version is not in development
  include(${USE_FILE})#include the definitions
  if(${package}_DEVELOPMENT_STATE STREQUAL "development") #this binary package has been built from a development branch
    set(${RESULT} TRUE PARENT_SCOPE)
  endif()
endif()
endfunction(is_Binary_Package_Version_In_Development)

#.rst:
#
# .. ifmode:: internal
#
#  .. |hard_Clean_Build_Folder| replace:: ``hard_Clean_Build_Folder``
#  .. _hard_Clean_Build_Folder:
#
#  hard_Clean_Build_Folder
#  -----------------------
#
#   .. command:: hard_Clean_Build_Folder(path_to_folder)
#
#    Clean a build folder in an aggressive and definitive way.
#
#     :path_to_folder: the path to the build folder to reset.
#
function(hard_Clean_Build_Folder path_to_folder)
  file(GLOB thefiles RELATIVE ${path_to_folder} ${path_to_folder}/*)
  foreach(a_file IN LISTS thefiles)
    if(NOT a_file STREQUAL ".gitignore")
      file(REMOVE_RECURSE ${path_to_folder}/${a_file})
    endif()
  endforeach()
endfunction(hard_Clean_Build_Folder)

#.rst:
#
# .. ifmode:: internal
#
#  .. |hard_Clean_Environment| replace:: ``hard_Clean_Environment``
#  .. _hard_Clean_Environment:
#
#  hard_Clean_Environment
#  ----------------------
#
#   .. command:: hard_Clean_Environment(environment)
#
#    Clean the build folder of a environment in an aggressive and definitive way.
#
#     :environment: the name of the target environment.
#
function(hard_Clean_Environment environment)
  hard_Clean_Build_Folder(${WORKSPACE_DIR}/environments/${environment}/build)
endfunction(hard_Clean_Environment)

#.rst:
#
# .. ifmode:: internal
#
#  .. |hard_Clean_Package| replace:: ``hard_Clean_Package``
#  .. _hard_Clean_Package:
#
#  hard_Clean_Package
#  ------------------
#
#   .. command:: hard_Clean_Package(package)
#
#    Clean the build folder of a package in an aggressive and definitive way.
#
#     :package: the name of the target package.
#
function(hard_Clean_Package package)
  get_Package_Type(${package} PACK_TYPE)
  if(PACK_TYPE STREQUAL "EXTERNAL")
    set(TARGET_BUILD_FOLDER ${WORKSPACE_DIR}/wrappers/${package}/build)
  else()
    set(TARGET_BUILD_FOLDER ${WORKSPACE_DIR}/packages/${package}/build)
  endif()
  hard_Clean_Build_Folder(${TARGET_BUILD_FOLDER})
endfunction(hard_Clean_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reconfigure_Package_Build| replace:: ``reconfigure_Package_Build``
#  .. _reconfigure_Package_Build:
#
#  reconfigure_Package_Build
#  --------------------------
#
#   .. command:: reconfigure_Package_Build(package)
#
#    Reconfigure a package (launch cmake process on that package).
#
#     :package: the name of the target package.
#
function(reconfigure_Package_Build package)
set(TARGET_BUILD_FOLDER ${WORKSPACE_DIR}/packages/${package}/build)
execute_process(COMMAND ${CMAKE_COMMAND} -DBUILD_RELEASE_ONLY:BOOL=OFF .. WORKING_DIRECTORY ${TARGET_BUILD_FOLDER} )
endfunction(reconfigure_Package_Build)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_For_Dependencies_Version| replace:: ``check_For_Dependencies_Version``
#  .. _check_For_Dependencies_Version:
#
#  check_For_Dependencies_Version
#  ------------------------------
#
#   .. command:: check_For_Dependencies_Version(BAD_DEPS package)
#
#    Check wether version of package dependencies have been released (i.e. if their version specified in the CMakeLists.txt of the package is released).
#
#     :package: the name of the target package.
#
#     :BAD_DEPS: the output variable containing the list of packages whose version in use are not released.
#
function(check_For_Dependencies_Version BAD_DEPS package)
set(${BAD_DEPS} PARENT_SCOPE)
set(list_of_bad_deps)
#check that the files describing the dependencies are existing
if(NOT EXISTS ${WORKSPACE_DIR}/packages/${package}/build/release/share/Dep${package}.cmake
OR NOT EXISTS ${WORKSPACE_DIR}/packages/${package}/build/debug/share/Dep${package}.cmake)
  #simply reconfigure to get the dependencies
  reconfigure_Package_Build(${package})
  if(NOT EXISTS ${WORKSPACE_DIR}/packages/${package}/build/release/share/Dep${package}.cmake
    OR NOT EXISTS ${WORKSPACE_DIR}/packages/${package}/build/debug/share/Dep${package}.cmake)
    message("[PID] WARNING : no dependency description found in package ${package}: cannot check version of its dependencies. The configuration of this package should fail at some point.")
    return()
  endif()
endif()
# loading variables describing dependencies
include(${WORKSPACE_DIR}/packages/${package}/build/release/share/Dep${package}.cmake)
include(${WORKSPACE_DIR}/packages/${package}/build/debug/share/Dep${package}.cmake)

# now check that target dependencies
#debug
foreach(dep IN LISTS TARGET_NATIVE_DEPENDENCIES_DEBUG)
	if(EXISTS ${WORKSPACE_DIR}/packages/${dep})#checking that the user may use a version generated by a source package
		# step 1: get all versions for that package
		get_Repository_Version_Tags(VERSION_NUMBERS ${dep})

		# step 2: checking that the version specified in the CMakeLists really exist
		if(TARGET_NATIVE_DEPENDENCY_${dep}_VERSION_DEBUG)
			normalize_Version_String(${TARGET_NATIVE_DEPENDENCY_${dep}_VERSION_DEBUG} NORMALIZED_STR)# normalize to a 3 digits version number to allow comparion in the search

			list(FIND VERSION_NUMBERS ${NORMALIZED_STR} INDEX)
  			if(INDEX EQUAL -1)# the version of dependency has not been released yet
  				list(APPEND list_of_bad_deps "${dep}#${TARGET_NATIVE_DEPENDENCY_${dep}_VERSION_DEBUG}")#using # instead of _ since names of package can contain _
  			endif()
  		endif()#else no version bound to dependency == no constraint
	  endif()
	endforeach()

#release
foreach(dep IN LISTS TARGET_NATIVE_DEPENDENCIES)
	if(EXISTS ${WORKSPACE_DIR}/packages/${dep})#checking that the user may use a version generated by a source package
		# step 1: get all versions for that package
		get_Repository_Version_Tags(VERSION_NUMBERS ${dep})
		# step 2: checking that the version specified in the CMakeLists really exist
		if(TARGET_NATIVE_DEPENDENCY_${dep}_VERSION)
			normalize_Version_String(${TARGET_NATIVE_DEPENDENCY_${dep}_VERSION} NORMALIZED_STR)# normalize to a 3 digits version number to allow comparion in the search
			list(FIND VERSION_NUMBERS ${NORMALIZED_STR} INDEX)
			if(INDEX EQUAL -1)# the version of dependency has not been released yet
				list(APPEND list_of_bad_deps "${dep}#${TARGET_NATIVE_DEPENDENCY_${dep}_VERSION}")#using # instead of _ since names of package can contain _
			endif()
		endif()#no version bound to dependency == no constraint
	endif()
endforeach()
if(list_of_bad_deps)#guard to avoid troubles with CMake complaining that the list does not exist
	list(REMOVE_DUPLICATES list_of_bad_deps)
	set(${BAD_DEPS} ${list_of_bad_deps} PARENT_SCOPE)#need of guillemet to preserve the list structure
endif()
endfunction(check_For_Dependencies_Version)

################################################################
################ Wrappers Life cycle management ################
################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |reconfigure_Wrapper_Build| replace:: ``reconfigure_Wrapper_Build``
#  .. _reconfigure_Wrapper_Build:
#
#  reconfigure_Wrapper_Build
#  -------------------------
#
#   .. command:: reconfigure_Wrapper_Build()
#
#     Reconfigure the currently built wrapper (i.e. launch cmake configuration).
#
function(reconfigure_Wrapper_Build package)
  execute_process(COMMAND ${CMAKE_COMMAND} ..
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${package}/build)
endfunction(reconfigure_Wrapper_Build)

#.rst:
#
# .. ifmode:: internal
#
#  .. |hard_Clean_Wrapper| replace:: ``hard_Clean_Wrapper``
#  .. _hard_Clean_Wrapper:
#
#  hard_Clean_Wrapper
#  ------------------
#
#   .. command:: hard_Clean_Wrapper(wrapper)
#
#    Clean the build folder of a wrapper in an aggressive and definitive way.
#
#     :wrapper: the name of the target wrapper.
#
function(hard_Clean_Wrapper wrapper)
  hard_Clean_Build_Folder(${WORKSPACE_DIR}/wrappers/${wrapper}/build)
endfunction(hard_Clean_Wrapper)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Wrapper_Repository_Address| replace:: ``set_Wrapper_Repository_Address``
#  .. _set_Wrapper_Repository_Address:
#
#  set_Wrapper_Repository_Address
#  ------------------------------
#
#   .. command:: set_Wrapper_Repository_Address(wrapper git_url)
#
#    Add a repository address of a wrapper in its description (i.e. in CMakeLists.txt)  .
#
#     :wrapper: the name of the target wrapper.
#     :git_url: the git url to set.
#
function(set_Wrapper_Repository_Address wrapper git_url)
	file(READ ${WORKSPACE_DIR}/wrappers/${wrapper}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE  "([ \t\n]+)YEAR" "\\1ADDRESS ${git_url}\n\\1YEAR" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/wrappers/${wrapper}/CMakeLists.txt ${NEW_CONTENT})
endfunction(set_Wrapper_Repository_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Wrapper_Repository_Address| replace:: ``reset_Wrapper_Repository_Address``
#  .. _reset_Wrapper_Repository_Address:
#
#  reset_Wrapper_Repository_Address
#  --------------------------------
#
#   .. command:: reset_Wrapper_Repository_Address(wrapper new_git_url)
#
#    Change the repository address of a wrapper in its description (i.e. in CMakeLists.txt)  .
#
#     :wrapper: the name of the target wrapper.
#     :new_git_url: the new git url to set.
#
function(reset_Wrapper_Repository_Address wrapper new_git_url)
	file(READ ${WORKSPACE_DIR}/wrappers/${wrapper}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE "([ \t\n]+)ADDRESS[ \t\n]+([^ \t\n]+)([ \t\n]+)" "\\1ADDRESS ${new_git_url}\\3" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/wrappers/${wrapper}/CMakeLists.txt ${NEW_CONTENT})
endfunction(reset_Wrapper_Repository_Address)

################################################################
################ Frameworks Life cycle management ##############
################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |reconfigure_Framework_Build| replace:: ``reconfigure_Framework_Build``
#  .. _reconfigure_Framework_Build:
#
#  reconfigure_Framework_Build
#  ---------------------------
#
#   .. command:: reconfigure_Framework_Build()
#
#     Reconfigure the currently built framework (i.e. launch cmake configuration).
#
function(reconfigure_Framework_Build framework)
set(TARGET_BUILD_FOLDER ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
execute_process(COMMAND ${CMAKE_COMMAND} .. WORKING_DIRECTORY ${TARGET_BUILD_FOLDER})
endfunction(reconfigure_Framework_Build)

#.rst:
#
# .. ifmode:: internal
#
#  .. |hard_Clean_Framework| replace:: ``hard_Clean_Framework``
#  .. _hard_Clean_Framework:
#
#  hard_Clean_Framework
#  --------------------
#
#   .. command:: hard_Clean_Framework(framework)
#
#    Clean the build folder of a framework in an aggressive and definitive way.
#
#     :framework: the name of the target framework.
#
function(hard_Clean_Framework framework)
  hard_Clean_Build_Folder(${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
endfunction(hard_Clean_Framework)


#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Framework_Repository_Address| replace:: ``set_Framework_Repository_Address``
#  .. _set_Framework_Repository_Address:
#
#  set_Framework_Repository_Address
#  --------------------------------
#
#   .. command:: set_Framework_Repository_Address(framework git_url)
#
#    Add a repository address of a framework in its description (i.e. in CMakeLists.txt)  .
#
#     :framework: the name of the target framework.
#     :git_url: the git url to set.
#
function(set_Framework_Repository_Address framework git_url)
	file(READ ${WORKSPACE_DIR}/sites/frameworks/${framework}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE  "([ \t\n]+)YEAR" "\\1ADDRESS ${git_url}\n\\1YEAR" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/sites/frameworks/${framework}/CMakeLists.txt ${NEW_CONTENT})
endfunction(set_Framework_Repository_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Framework_Repository_Address| replace:: ``reset_Framework_Repository_Address``
#  .. _reset_Framework_Repository_Address:
#
#  reset_Framework_Repository_Address
#  ----------------------------------
#
#   .. command:: reset_Framework_Repository_Address(framework new_git_url)
#
#    Change the repository address of a framework in its description (i.e. in CMakeLists.txt)  .
#
#     :framework: the name of the target framework.
#     :new_git_url: the new git url to set.
#
function(reset_Framework_Repository_Address framework new_git_url)
	file(READ ${WORKSPACE_DIR}/sites/frameworks/${framework}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE "([ \t\n]+)ADDRESS[ \t\n]+([^ \t\n]+)([ \t\n]+)" "\\1ADDRESS ${new_git_url}\\3" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/sites/frameworks/${framework}/CMakeLists.txt ${NEW_CONTENT})
endfunction(reset_Framework_Repository_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Framework_Repository_Address| replace:: ``get_Framework_Repository_Address``
#  .. _get_Framework_Repository_Address:
#
#  get_Framework_Repository_Address
#  --------------------------------
#
#   .. command:: get_Framework_Repository_Address(framework RES_URL)
#
#    Get the repository address of a framework from its description (i.e. in CMakeLists.txt)  .
#
#     :framework: the name of the target framework.
#
#     :RES_URL: the output variable containing the URL of the framqork in its description.
#
function(get_Framework_Repository_Address framework RES_URL)
	file(READ ${WORKSPACE_DIR}/sites/frameworks/${framework}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE "^.+[ \t\n]ADDRESS[ \t\n]+([^ \t\n]+)[ \t\n]+.*$" "\\1" url ${CONTENT})
	if(url STREQUAL "${CONTENT}")#no match
		set(${RES_URL} "" PARENT_SCOPE)
		return()
	endif()
	set(${RES_URL} ${url} PARENT_SCOPE)
endfunction(get_Framework_Repository_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Jekyll_URLs| replace:: ``get_Jekyll_URLs``
#  .. _get_Jekyll_URLs:
#
#  get_Jekyll_URLs
#  ---------------
#
#   .. command:: get_Jekyll_URLs(full_url NAMESPACE REMAINING_URL)
#
#    Tokenize a http address into a namespace and a remaining part. Used to extract information used by jekyll to adequately configure a static site.
#
#     :full_url: the given full URL.
#
#     :NAMESPACE: the output variable containing the namespace (http[s]?://gite.lirmm.fr) of the URL.
#     :REMAINING_URL: the output variable containing the remaining of the URL.
#
function(get_Jekyll_URLs full_url NAMESPACE REMAINING_URL)
	string(REGEX REPLACE "^(http[s]?://[^/]+)/(.+)$" "\\1;\\2" all_urls ${full_url})
	if(NOT (all_urls STREQUAL full_url))#it matches
		list(GET all_urls 0 pub)
		list(GET all_urls 1 base)
		set(${NAMESPACE} ${pub} PARENT_SCOPE)
		set(${REMAINING_URL} ${base} PARENT_SCOPE)
	else()
		string(REGEX REPLACE "^(http[s]?://[^/]+)/?$" "\\1" pub_url ${full_url})
		set(${NAMESPACE} ${pub_url} PARENT_SCOPE)
		set(${REMAINING_URL} PARENT_SCOPE)
	endif()
endfunction(get_Jekyll_URLs)


################################################################
################ Environments Life cycle management ############
################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Environment_Repository_Address| replace:: ``set_Environment_Repository_Address``
#  .. _set_Environment_Repository_Address:
#
#  set_Environment_Repository_Address
#  ----------------------------------
#
#   .. command:: set_Environment_Repository_Address(environment git_url)
#
#    Add a repository address of a environment in its description (i.e. in CMakeLists.txt)  .
#
#     :environment: the name of the target environment.
#     :git_url: the git url to set.
#
function(set_Environment_Repository_Address environment git_url)
	file(READ ${WORKSPACE_DIR}/environments/${environment}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE  "([ \t\n]+)YEAR" "\\1ADDRESS ${git_url}\n\\1YEAR" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/environments/${environment}/CMakeLists.txt ${NEW_CONTENT})
endfunction(set_Environment_Repository_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Environment_Repository_Address| replace:: ``reset_Environment_Repository_Address``
#  .. _reset_Environment_Repository_Address:
#
#  reset_Environment_Repository_Address
#  ------------------------------------
#
#   .. command:: reset_Environment_Repository_Address(environment new_git_url)
#
#    Change the repository address of a environment in its description (i.e. in CMakeLists.txt)  .
#
#     :environment: the name of the target environment.
#     :new_git_url: the new git url to set.
#
function(reset_Environment_Repository_Address environment new_git_url)
	file(READ ${WORKSPACE_DIR}/sites/frameworks/${environment}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE "([ \t\n]+)ADDRESS[ \t\n]+([^ \t\n]+)([ \t\n]+)" "\\1ADDRESS ${new_git_url}\\3" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/sites/frameworks/${environment}/CMakeLists.txt ${NEW_CONTENT})
endfunction(reset_Environment_Repository_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Environment_Repository_Address| replace:: ``get_Environment_Repository_Address``
#  .. _get_Environment_Repository_Address:
#
#  get_Environment_Repository_Address
#  ----------------------------------
#
#   .. command:: get_Environment_Repository_Address(environment RES_URL)
#
#    Get the repository address of a environment from its description (i.e. in CMakeLists.txt)  .
#
#     :environment: the name of the target environment.
#
#     :RES_URL: the output variable containing the URL of the environment in its description.
#
function(get_Environment_Repository_Address environment RES_URL)
	file(READ ${WORKSPACE_DIR}/environments/${environment}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE "^.+[ \t\n]ADDRESS[ \t\n]+([^ \t\n]+)[ \t\n]+.*$" "\\1" url ${CONTENT})
	if(url STREQUAL CONTENT)#no match
		set(${RES_URL} "" PARENT_SCOPE)
		return()
	endif()
	set(${RES_URL} ${url} PARENT_SCOPE)
endfunction(get_Environment_Repository_Address)


################################################################
################ Static site file management ###################
################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |test_Site_Content_File| replace:: ``test_Site_Content_File``
#  .. _test_Site_Content_File:
#
#  test_Site_Content_File
#  ----------------------
#
#   .. command:: test_Site_Content_File(FILE_NAME EXTENSION a_file)
#
#    Check wether the file passed as argument is usable in a static site generation process. It can be pure html, markdown or image (jpg png gif bmp) file.
#
#     :a_file: the full file name.
#
#     :FILE_NAME: the output variable containing the file name without extension, or that is empty if the file cannot be used for static generation.
#     :EXTENSION: the output variable containing the file extension, or that is empty if the file cannot be used for static generation.
#
function(test_Site_Content_File FILE_NAME EXTENSION a_file)
set(${FILE_NAME} PARENT_SCOPE)
set(${EXTENSION} PARENT_SCOPE)

#get the name and extension of the file
string(REGEX REPLACE "^([^\\.]+)\\.(.+)$" "\\1;\\2" RESULTING_FILE ${a_file})
if(NOT RESULTING_FILE STREQUAL ${a_file}) #it matches
	list(GET RESULTING_FILE 1 RES_EXT)
	list(APPEND POSSIBLE_EXTS markdown mkdown mkdn mkd md htm html jpg png gif bmp)
	list(FIND POSSIBLE_EXTS ${RES_EXT} INDEX)
	if(INDEX GREATER -1)
		list(GET RESULTING_FILE 0 RES_NAME)
		set(${FILE_NAME} ${RES_NAME} PARENT_SCOPE)
		set(${EXTENSION} ${RES_EXT} PARENT_SCOPE)
	endif()
endif()
endfunction(test_Site_Content_File)

#########################################################################
################ text files manipulation utilities ######################
#########################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |test_Same_File_Content| replace:: ``test_Same_File_Content``
#  .. _test_Same_File_Content:
#
#  test_Same_File_Content
#  ----------------------
#
#   .. command:: test_Same_File_Content(file1_path file2_path ARE_SAME)
#
#    Check wether two regular files have same content.
#
#     :file1_path: the path to first file.
#     :file2_path: the path to second file.
#
#     :ARE_SAME: the output variable that is TRUE of both files have same content, FALSE otherwise.
#
function(test_Same_File_Content file1_path file2_path ARE_SAME)
  set(${ARE_SAME} FALSE PARENT_SCOPE)
  if(NOT EXISTS ${file1_path} OR NOT EXISTS ${file2_path})
    #if any or both files do not exists, their content is not the same
    return()
  endif()
  file(READ ${file1_path} FILE_1_CONTENT)
  file(READ ${file2_path} FILE_2_CONTENT)
  if("${FILE_1_CONTENT}" STREQUAL "${FILE_2_CONTENT}")
  	set(${ARE_SAME} TRUE PARENT_SCOPE)
  endif()
endfunction(test_Same_File_Content)

#.rst:
#
# .. ifmode:: internal
#
#  .. |test_Same_Directory_Content| replace:: ``test_Same_Directory_Content``
#  .. _test_Same_Directory_Content:
#
#  test_Same_Directory_Content
#  ---------------------------
#
#   .. command:: test_Same_Directory_Content(dir1_path dir2_path ARE_SAME)
#
#    Check wether two folders have exactly same content (even their contained regular files have same content).
#
#     :dir1_path: the path to first folder.
#     :dir2_path: the path to second folder.
#
#     :ARE_SAME: the output variable that is TRUE of both folders have same content, FALSE otherwise.
#
function(test_Same_Directory_Content dir1_path dir2_path ARE_SAME)
file(GLOB_RECURSE ALL_FILES_DIR1 RELATIVE ${dir1_path} ${dir1_path}/*)
file(GLOB_RECURSE ALL_FILES_DIR2 RELATIVE ${dir2_path} ${dir2_path}/*)
foreach(a_file IN LISTS ALL_FILES_DIR1)
	list(FIND ALL_FILES_DIR2 ${a_file} INDEX)
	if(INDEX EQUAL -1)#if file not found -> not same content
		set(${ARE_SAME} FALSE PARENT_SCOPE)
		return()
	else()
		if(NOT IS_DIRECTORY ${dir1_path}/${a_file} AND NOT IS_SYMLINK ${dir1_path}/${a_file})
			set(SAME FALSE)
			test_Same_File_Content(${dir1_path}/${a_file} ${dir2_path}/${a_file} SAME)
			if(NOT SAME)#file content is different
				set(${ARE_SAME} FALSE PARENT_SCOPE)
				return()
			endif()
		endif()
	endif()
endforeach()
set(${ARE_SAME} TRUE PARENT_SCOPE)
endfunction(test_Same_Directory_Content)

######################################################################################
################ compiler arguments test/manipulation functions ######################
######################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_C_Existing_Standards| replace:: ``get_C_Existing_Standards``
#  .. _get_C_Existing_Standards:
#
#  get_C_Existing_Standards
#  ------------------------
#
#   .. command:: get_C_Existing_Standards(ALL_C_STDS)
#
#    Gives the ordered list of available C language standards, from older to newer. Used as an auxiliary function the centralizes information on available standards.
#
#     :ALL_C_STDS: the output variable that contains the list of available standards.
#
function(get_C_Existing_Standards ALL_C_STDS)
  set(${ALL_C_STDS} 90 99 11 PARENT_SCOPE)
endfunction(get_C_Existing_Standards)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_CXX_Existing_Standards| replace:: ``get_CXX_Existing_Standards``
#  .. _get_CXX_Existing_Standards:
#
#  get_CXX_Existing_Standards
#  --------------------------
#
#   .. command:: get_CXX_Existing_Standards(ALL_CXX_STDS)
#
#    Gives the ordered list of available C++ language standards, from older to newer. Used as an auxiliary function the centralizes information on available standards.
#
#     :ALL_CXX_STDS: the output variable that contains the list of available standards.
#
function(get_CXX_Existing_Standards ALL_CXX_STDS)
  set(${ALL_CXX_STDS} 98 11 14 17 20 PARENT_SCOPE)
endfunction(get_CXX_Existing_Standards)

#.rst:
#
# .. ifmode:: internal
#
#  .. |translate_Standard_Into_Option| replace:: ``translate_Standard_Into_Option``
#  .. _translate_Standard_Into_Option:
#
#  translate_Standard_Into_Option
#  ------------------------------
#
#   .. command:: translate_Standard_Into_Option(RES_C_STD_OPT RES_CXX_STD_OPT c_std_number cxx_std_number)
#
#    Translate C/C++ language standard expressions into equivalent compiler options (e.G. C++ langauge standard 98 is translated into -std=c++98).
#
#     :c_std_number: the C language standard used.
#     :cxx_std_number: the C++ language standard used.
#
#     :RES_C_STD_OPT: the output variable that contains the equivalent compiler option for C language standard.
#     :RES_CXX_STD_OPT: the output variable that contains the equivalent compiler option for C++ language standard.
#
function(translate_Standard_Into_Option RES_C_STD_OPT RES_CXX_STD_OPT c_std_number cxx_std_number)
	#managing c++
  is_A_CXX_Language_Standard(IS_CXX_STD "${cxx_std_number}")
  if(IS_CXX_STD)
    if(CMAKE_HOST_WIN32)
      set(${RES_CXX_STD_OPT} "/std=c++${cxx_std_number}" PARENT_SCOPE)
    else()
      set(${RES_CXX_STD_OPT} "-std=c++${cxx_std_number}" PARENT_SCOPE)
    endif()
  else()
    set(${RES_CXX_STD_OPT} PARENT_SCOPE)
  endif()

	#managing c
  is_A_C_Language_Standard(IS_C_STD "${c_std_number}")
  if(IS_C_STD)
    if(CMAKE_HOST_WIN32)
      set(${RES_CXX_STD_OPT} "/std=c${cxx_std_number}" PARENT_SCOPE)
    else()
      set(${RES_C_STD_OPT} "-std=c${c_std_number}" PARENT_SCOPE)
    endif()
  else()
    set(${RES_C_STD_OPT} PARENT_SCOPE)
  endif()
endfunction(translate_Standard_Into_Option)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_CXX_Version_Less| replace:: ``is_CXX_Version_Less``
#  .. _is_CXX_Version_Less:
#
#  is_CXX_Version_Less
#  -------------------
#
#   .. command:: is_CXX_Version_Less(IS_LESS first second)
#
#    Compare two C++ language standard versions. Suppose that standards are valid values or empty.
#
#     :first: the first language standard version to compare.
#     :second: the second language standard version to compare.
#
#     :IS_LESS: the output variable that is TRUE if first is an older standard than second.
#
function(is_CXX_Version_Less IS_LESS first second)
if(NOT second)#second is not set so false anytime
  set(${IS_LESS} FALSE PARENT_SCOPE)
  return()
endif()
if(NOT first) #first is not set so true anytime
  set(${IS_LESS} TRUE PARENT_SCOPE)
  return()
endif()
get_CXX_Existing_Standards(ALL_CXX_STDS)
list(FIND ALL_CXX_STDS ${first} INDEX_FIRST)
list(FIND ALL_CXX_STDS ${second} INDEX_SECOND)
if(INDEX_FIRST LESS INDEX_SECOND)
  set(${IS_LESS} TRUE PARENT_SCOPE)
else()
  set(${IS_LESS} FALSE PARENT_SCOPE)
endif()
endfunction(is_CXX_Version_Less)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_C_Version_Less| replace:: ``is_C_Version_Less``
#  .. _is_C_Version_Less:
#
#  is_C_Version_Less
#  -------------------
#
#   .. command:: is_C_Version_Less(IS_LESS first second)
#
#    Compare two C language standard versions. Suppose that standards are valid values or empty
#
#     :first: the first language standard version to compare.
#     :second: the second language standard version to compare.
#
#     :IS_LESS: the output variable that is TRUE if first is an older standard than second.
#
function(is_C_Version_Less IS_LESS first second)
if(NOT second) #second is not set so false anytime
	set(${IS_LESS} FALSE PARENT_SCOPE)
	return()
endif()
if(NOT first) #first is not set so true anytime
	set(${IS_LESS} TRUE PARENT_SCOPE)
	return()
endif()

get_C_Existing_Standards(ALL_C_STDS)
list(FIND ALL_C_STDS ${first} INDEX_FIRST)
list(FIND ALL_C_STDS ${second} INDEX_SECOND)
if(INDEX_FIRST LESS INDEX_SECOND)
  set(${IS_LESS} TRUE PARENT_SCOPE)
else()
  set(${IS_LESS} FALSE PARENT_SCOPE)
endif()
endfunction(is_C_Version_Less)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_C_Standard_Option| replace:: ``is_C_Standard_Option``
#  .. _is_C_Standard_Option:
#
#  is_C_Standard_Option
#  --------------------
#
#   .. command:: is_C_Standard_Option(STANDARD_NUMBER opt)
#
#    Check whether the option passed to the compiler is used to set the C language standard and eventually get corrsponding C language standard version.
#
#     :opt: the compiler option to check.
#
#     :STANDARD_NUMBER: the output variable that contains the C language standard version, or empty if the option is not used to set language standard.
#
function(is_C_Standard_Option STANDARD_NUMBER opt)
  get_C_Existing_Standards(ALL_C_STDS)
  fill_String_From_List(RES_PATTERN ALL_C_STDS "|")
  if(opt MATCHES "^[ \t]*-std=(c|gnu)(${RES_PATTERN})[ \t]*$")#it matches
  	set(${STANDARD_NUMBER} ${CMAKE_MATCH_2} PARENT_SCOPE)
  endif()
endfunction(is_C_Standard_Option)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_CXX_Standard_Option| replace:: ``is_CXX_Standard_Option``
#  .. _is_CXX_Standard_Option:
#
#  is_CXX_Standard_Option
#  ----------------------
#
#   .. command:: is_CXX_Standard_Option(STANDARD_NUMBER opt)
#
#    Check whether the option passed to the compiler is used to set the C++ language standard and eventually get corresponding C++ language standard version.
#
#     :opt: the compiler option to check.
#
#     :STANDARD_NUMBER: the output variable that contains the C++ language standard version, or empty if the option is not used to set language standard.
#
function(is_CXX_Standard_Option STANDARD_NUMBER opt)
  get_CXX_Existing_Standards(ALL_CXX_STDS)
  fill_String_From_List(RES_PATTERN ALL_CXX_STDS "|")
  if(opt MATCHES "^[ \t]*-std=(c|gnu)\\+\\+(${RES_PATTERN})[ \t]*$")#it is a standard setting option
  	set(${STANDARD_NUMBER} ${CMAKE_MATCH_2} PARENT_SCOPE)
  endif()
endfunction(is_CXX_Standard_Option)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_A_C_Language_Standard| replace:: ``is_A_C_Language_Standard``
#  .. _is_A_C_Language_Standard:
#
#  is_A_C_Language_Standard
#  ------------------------
#
#   .. command:: is_A_C_Language_Standard(IS_STD number)
#
#    Tells wether a number matches a C language standard number .
#
#     :IS_STD: the output variable that is TRUE if number is a standard.
#
#     :number: the number to test.
#
function(is_A_C_Language_Standard IS_STD number)
  get_C_Existing_Standards(ALL_STDS)
  list(FIND ALL_STDS "${number}" INDEX)
  if(INDEX EQUAL -1)
    set(${IS_STD} FALSE PARENT_SCOPE)
  else()
    set(${IS_STD} TRUE PARENT_SCOPE)
  endif()
endfunction(is_A_C_Language_Standard)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_A_CXX_Language_Standard| replace:: ``is_A_CXX_Language_Standard``
#  .. _is_A_CXX_Language_Standard:
#
#  is_A_CXX_Language_Standard
#  --------------------------
#
#   .. command:: is_A_CXX_Language_Standard(IS_STD number)
#
#    Tells wether a number matches a C++ language standard number .
#
#     :IS_STD: the output variable that is TRUE if number is a standard.
#
#     :number: the number to test.
#
function(is_A_CXX_Language_Standard IS_STD number)
  get_CXX_Existing_Standards(ALL_STDS)
  list(FIND ALL_STDS "${number}" INDEX)
  if(INDEX EQUAL -1)
    set(${IS_STD} FALSE PARENT_SCOPE)
  else()
    set(${IS_STD} TRUE PARENT_SCOPE)
  endif()
endfunction(is_A_CXX_Language_Standard)


#.rst:
#
# .. ifmode:: internal
#
#  .. |filter_Compiler_Options| replace:: ``filter_Compiler_Options``
#  .. _filter_Compiler_Options:
#
#  filter_Compiler_Options
#  -----------------------
#
#   .. command:: filter_Compiler_Options(STD_C_OPT STD_CXX_OPT FILTERED_OPTS opts)
#
#     Filter the options to get those related to language standard used.
#
#     :opts: the list of compilation options.
#
#     :STD_C_OPT: the output variable containg the C language standard used, if any.
#     :STD_CXX_OPT: the output variable containg the C++ language standard used, if any.
#     :FILTERED_OPTS: the output variable containing the list of options not related to language standard, if any.
#
function(filter_Compiler_Options STD_C_OPT STD_CXX_OPT FILTERED_OPTS opts)
set(RES_FILTERED)
set(${STD_CXX_OPT} PARENT_SCOPE)
set(${STD_C_OPT} PARENT_SCOPE)
foreach(opt IN LISTS opts)
	unset(STANDARD_NUMBER)
	#checking for CXX_STANDARD
	is_CXX_Standard_Option(STANDARD_NUMBER ${opt})
	if(STANDARD_NUMBER)
		set(${STD_CXX_OPT} ${STANDARD_NUMBER} PARENT_SCOPE)
	else()#checking for C_STANDARD
		is_C_Standard_Option(STANDARD_NUMBER ${opt})
		if(STANDARD_NUMBER)
			set(${STD_C_OPT} ${STANDARD_NUMBER} PARENT_SCOPE)
		else()
			list(APPEND RES_FILTERED ${opt})#keep the option unchanged
		endif()
	endif()
endforeach()
set(${FILTERED_OPTS} ${RES_FILTERED} PARENT_SCOPE)
endfunction(filter_Compiler_Options)


#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Languages_Standards_In_Options| replace:: ``check_Languages_Standards_In_Options``
#  .. _check_Languages_Standards_In_Options:
#
#  check_Languages_Standards_In_Options
#  ------------------------------------
#
#   .. command:: check_Languages_Standards_In_Options(RES_C_STD RES_CXX_STD RES_OPTS c_std cxx_std list_of_options)
#
#     Check whether a list of options specify a target language standard and compare it with the corresponding standard in use.
#
#     :c_std: the current C language standard.
#     :cxx_std: the current C++ language standard.
#     :list_of_options: the INPUT variable that contains a list of compilation options.
#
#     :RES_C_STD: the output variable containg the C language standard coming from options, if it is newer than current one, empty otherwise.
#     :RES_CXX_STD: the output variable containg the C++ language standard coming from options, if it is newer than current one, empty otherwise.
#     :RES_OPTS: the output variable containing the list of all options not related to language standard built from list_of_options.
#
function(check_Languages_Standards_In_Options RES_C_STD RES_CXX_STD RES_OPTS c_std cxx_std list_of_options)
  set(RES_C_STD PARENT_SCOPE)
  set(RES_CXX_STD PARENT_SCOPE)
  filter_Compiler_Options(STD_C_OPT STD_CXX_OPT FILTERED_OPTS "${${list_of_options}}")
  set(${RES_OPTS} ${FILTERED_OPTS} PARENT_SCOPE)
  if(STD_C_OPT)
  	is_C_Version_Less(IS_LESS "${c_std}" "${STD_C_OPT}")
  	if(IS_LESS)
  		set(RES_C_STD ${STD_C_OPT} PARENT_SCOPE)
  	endif()
  endif()
  if(STD_CXX_OPT)
  	is_CXX_Version_Less(IS_LESS "${cxx_std}" "${STD_CXX_OPT}")
  	if(IS_LESS)
      set(RES_CXX_STD ${STD_CXX_OPT} PARENT_SCOPE)
  	endif()
  endif()
endfunction(check_Languages_Standards_In_Options)


#.rst:
#
# .. ifmode:: internal
#
#  .. |adjust_Languages_Standards_Description| replace:: ``adjust_Languages_Standards_Description``
#  .. _adjust_Languages_Standards_Description:
#
#  adjust_Languages_Standards_Description
#  ---------------------------------------
#
#   .. command:: adjust_Languages_Standards_Description(ERROR MESSAGE
#                                                C_STD_USED CXX_STD_USED INTERNAL_OPTS_USED EXPORTED_OPTS_USED
#                                                internal_opts_var exported_opts_var
#                                                c_standard c_max_standard cxx_standard cxx_max_standard)
#
#     Auxiliary function of the API used to check if given description of languages standard is correct and the automate adjustment of the description if possible.
#
#     :internal_opts_var: the INPUT variable that contains a list of compilation options used internaly.
#     :exported_opts_var: the INPUT variable that contains a list of compilation options that are exported.
#     :c_standard: the C language standard used.
#     :c_max_standard: the max C language standard allowed when using the component.
#     :cxx_standard: the C++ language standard used.
#     :cxx_max_standard: the max C++ language standard allowed when using the component.
#
#     :ERROR: the output variable containing the error type (WARNING or CRITICAL) if any error appears in description.
#     :MESSAGE: the output variable containing the error message if an error is generated.
#     :C_STD_USED: the output variable containg the C language standard to be finally used.
#     :CXX_STD_USED: the output variable containg the C++ language standard to be finally used.
#     :INTERNAL_OPTS_USED: the output variable containing the list of all internal compiler options without language related options.
#     :EXPORTED_OPTS_USED: the output variable containing the list of all exported compiler options without language related options.
#
function(adjust_Languages_Standards_Description ERROR MESSAGE
                                                C_STD_USED CXX_STD_USED INTERNAL_OPTS_USED EXPORTED_OPTS_USED
                                                internal_opts_var exported_opts_var
                                                c_standard c_max_standard cxx_standard cxx_max_standard)

  #set local temporary variables that are returned in the end
  set(ret_error)
  set(ret_message)
  #preliminary checks on inputs
  if(c_standard)
    set(c_standard_used ${c_standard})
    is_A_C_Language_Standard(IS_STD ${c_standard})
  	if(NOT IS_STD)
      get_C_Existing_Standards(ALL_C_STDS)
      fill_String_From_List(POSSIBLE_STDS_STR ALL_C_STDS ", ")
      set(ret_message "${ret_message}bad C_STANDARD argument, its value must be one of: ${POSSIBLE_STDS_STR}. ")
      set(ret_error "CRITICAL")
  	endif()
  else() #default language standard is first standard
    set(c_standard_used 90)
  endif()
  if(c_max_standard)
    is_A_C_Language_Standard(IS_STD ${c_max_standard})
    if(NOT IS_STD)
      get_C_Existing_Standards(ALL_C_STDS)
      fill_String_From_List(POSSIBLE_STDS_STR ALL_C_STDS ", ")
      set(ret_message "${ret_message}bad C_MAX_STANDARD argument, the value must be one of: ${POSSIBLE_STDS_STR}. ")
      set(ret_error "CRITICAL")
    endif()
  endif()
  if(cxx_standard)
    set(cxx_standard_used ${cxx_standard})
    is_A_CXX_Language_Standard(IS_STD ${cxx_standard})
  	if(NOT IS_STD)
      get_CXX_Existing_Standards(ALL_CXX_STDS)
      fill_String_From_List(POSSIBLE_STDS_STR ALL_CXX_STDS ", ")
    	set(ret_message "${ret_message}bad CXX_STANDARD argument, the value must be one of: ${POSSIBLE_STDS_STR}. ")
      set(ret_error "CRITICAL")
  	endif()
  else() #default language standard is first standard
  	set(cxx_standard_used 98)
  endif()
  if(cxx_max_standard)
    is_A_CXX_Language_Standard(IS_STD ${cxx_max_standard})
    if(NOT IS_STD)
      get_CXX_Existing_Standards(ALL_CXX_STDS)
      fill_String_From_List(POSSIBLE_STDS_STR ALL_CXX_STDS ", ")
      set(ret_message "${ret_message}bad CXX_MAX_STANDARD argument, the value must be one of: ${POSSIBLE_STDS_STR}. ")
      set(ret_error "CRITICAL")
    endif()
  endif()

  if(NOT ret_error)#if an error is already generted at this stage, no need to continue
    check_Languages_Standards_In_Options(STD_C_OPT STD_CXX_OPT FILTERED_INTERNAL_OPTS "${c_standard_used}" "${cxx_standard_used}" ${internal_opts_var})
    if(STD_C_OPT)#standard has been modified due to options
    	set(c_standard_used ${STD_C_OPT})
    	set(ret_message "directly using option -std=c${STD_C_OPT} or -std=gnu${STD_C_OPT} is not recommanded, use the C_STANDARD keywork in component description instead. PID performs corrective action.")
      set(ret_error "WARNING")
    endif()
    if(STD_CXX_OPT)#standard has been modified due to options
    	set(cxx_standard_used ${STD_CXX_OPT})
    	set(ret_message "directly using option -std=c++${STD_CXX_OPT} or -std=gnu++${STD_CXX_OPT} is not recommanded, use the CXX_STANDARD keywork in component description instead. PID performs corrective action.")
      set(ret_error "WARNING")
    endif()
    check_Languages_Standards_In_Options(STD_C_OPT STD_CXX_OPT FILTERED_EXPORTED_OPTS "${c_standard_used}" "${cxx_standard_used}" ${exported_opts_var})
    if(STD_C_OPT)
    	set(c_standard_used ${STD_C_OPT})
    	set(ret_message "directly using option -std=c${STD_C_OPT} or -std=gnu${STD_C_OPT} is not recommanded, use the C_STANDARD keywork in component description instead. PID performs corrective action.")
      set(ret_error "WARNING")
    endif()
    if(STD_CXX_OPT)
    	set(cxx_standard_used ${STD_CXX_OPT})
    	set(ret_message "directly using option -std=c++${STD_CXX_OPT} or -std=gnu++${STD_CXX_OPT} is not recommanded, use the CXX_STANDARD keywork in component description instead. PID performs corrective action.")
      set(ret_error "WARNING")
    endif()
    #now basically check standards set VS max standards (to verify that description is not stupid !)
    if(c_max_standard)
    	is_C_Version_Less(IS_LESS "${c_max_standard}" "${c_standard_used}")
    	if(IS_LESS)
        if(ret_message)
    	   set(ret_message "${ret_message}. Now the max C language standard (${c_max_standard}) is older than the standard used (${c_standard_used}) !!")
        else()
         set(ret_message "the max C language standard (${c_max_standard}) is older than the standard used (${c_standard_used}) !!")
        endif()
       set(ret_error "CRITICAL")
      endif()
    endif()
    if(cxx_max_standard)
    	is_CXX_Version_Less(IS_LESS "${cxx_max_standard}" "${cxx_standard_used}")
    	if(IS_LESS)
        if(ret_message)
         set(ret_message "${ret_message}. Now the max C++ language standard (${cxx_max_standard}) is older than the standard used (${cxx_standard_used}) !!")
        else()
         set(ret_message "the max C++ language standard (${cxx_max_standard}) is older than the standard used (${cxx_standard_used}) !!")
        endif()
        set(ret_error "CRITICAL")
    	endif()
    endif()
  endif()
  #returning variables
  set(${C_STD_USED} ${c_standard_used} PARENT_SCOPE)
  set(${CXX_STD_USED} ${cxx_standard_used} PARENT_SCOPE)
  set(${INTERNAL_OPTS_USED} ${FILTERED_INTERNAL_OPTS} PARENT_SCOPE)
  set(${EXPORTED_OPTS_USED} ${FILTERED_EXPORTED_OPTS} PARENT_SCOPE)
  set(${MESSAGE} ${ret_message} PARENT_SCOPE)
  set(${ERROR} ${ret_error} PARENT_SCOPE)
endfunction(adjust_Languages_Standards_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Required_CMake_Version_For_Standard| replace:: ``get_Required_CMake_Version_For_Standard``
#  .. _get_Required_CMake_Version_For_Standard:
#
#  get_Required_CMake_Version_For_Standard
#  ---------------------------------------
#
#   .. command:: get_Required_CMake_Version_For_Standard(RES_MIN_CMAKE_VERSION cxx_std)
#
#     Returns the minimum required CMake version when using given C++ standard
#
#     :cxx_std: the target C++ language standard.
#
#     :RES_MIN_CMAKE_VERSION: the output variable containing the minimum required version of CMake.
#
function(get_Required_CMake_Version_For_Standard RES_MIN_CMAKE_VERSION cxx_std)
  set(min_cmake_version_for_std_property 3.8.2)
  if(cxx_std EQUAL 20)
    set(min_cmake_version_for_std_property 3.11.4)
  endif()
  set(${RES_MIN_CMAKE_VERSION} ${min_cmake_version_for_std_property} PARENT_SCOPE)#CXX standard property
endfunction(get_Required_CMake_Version_For_Standard)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Imported_C_Standard| replace:: ``check_Imported_C_Standard``
#  .. _check_Imported_C_Standard:
#
#  check_Imported_C_Standard
#  -------------------------
#
#   .. command:: check_Imported_C_Standard(ERROR MESSAGE NEW_C_STD NEW_C_MAX_STD c_std imported_c_std c_max_std imported_c_max_std)
#
#     Check whether C standard specification coming from a dependency must/can be adpated depending on current scpecifications.
#
#     :c_std: the current C language standard.
#     :imported_c_std: the C language standard specified by a dependency.
#     :c_max_std: the current max C language allowed (may be empty with no constraint).
#     :imported_c_max_std: the max C language standard allowed by a dependency.
#
#     :ERROR: the output variable containing the error type (CRITICAL or WARNING) if any, empty otherwise.
#     :MESSAGE: the output variable containing the message to print when an error is detected.
#     :NEW_C_STD: the output variable containing the modified C standard if modification required, empty otherwise.
#     :NEW_C_MAX_STD: the output variable containing the modified C MAX standard if modification required, empty otherwise.
#
function(check_Imported_C_Standard ERROR MESSAGE NEW_C_STD NEW_C_MAX_STD c_std imported_c_std c_max_std imported_c_max_std)
  set(${ERROR} PARENT_SCOPE)
  set(${MESSAGE} PARENT_SCOPE)
  set(${NEW_C_STD} PARENT_SCOPE)
  set(${NEW_C_MAX_STD} PARENT_SCOPE)
  set(ret_mess)
  set(ret_err)
  is_C_Version_Less(IS_LESS "${c_std}" "${imported_c_std}")
  if(IS_LESS)#need to use the system/external dependency standard, otherwise this information would disappear
    if(c_max_std)
      is_C_Version_Less(IS_LESS "${c_max_std}" "${imported_c_std}")
      if(IS_LESS)
        set(${ERROR} "CRITICAL" PARENT_SCOPE)
        set(${MESSAGE} "need to change declared C standard (${c_std}) to ${imported_c_std}, but this standard is greater than max allowed (${c_max_std})" PARENT_SCOPE)
        return()
      endif()
    endif()
    set(${NEW_C_STD} ${imported_c_std} PARENT_SCOPE)
    set(ret_err "WARNING")
    set(ret_mess "need to change declared C standard (${c_std}) to ${imported_c_std}")
  endif()
  is_C_Version_Less(IS_LESS "${imported_c_max_std}" "${c_max_std}")
  if(IS_LESS)#need to ajust max standard to the lowest max standard in use
    set(ret_err "WARNING")
    set(${NEW_C_MAX_STD} ${imported_c_max_std} PARENT_SCOPE)
    if(ret_mess)#already a warning
      set(ret_mess "${ret_mess}. Also need to change declared C max standard (${c_max_std}) to ${imported_c_max_std}")
    else()
      set(ret_mess "need to change declared C max standard (${c_max_std}) to ${imported_c_max_std}")
    endif()
  endif()
  set(${ERROR} "${ret_err}" PARENT_SCOPE)
  set(${MESSAGE} "${ret_mess}" PARENT_SCOPE)
endfunction(check_Imported_C_Standard)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Imported_CXX_Standard| replace:: ``check_Imported_CXX_Standard``
#  .. _check_Imported_CXX_Standard:
#
#  check_Imported_CXX_Standard
#  ---------------------------
#
#   .. command:: check_Imported_CXX_Standard(ERROR MESSAGE NEW_CXX_STD NEW_CXX_MAX_STD cxx_std imported_cxx_std cxx_max_std imported_cxx_max_std)
#
#     Check whether C++ standard specification coming from a dependency must/can be adpated depending on current scpecifications.
#
#     :cxx_std: the current C++ language standard.
#     :imported_cxx_std: the C++ language standard specified by a dependency.
#     :cxx_max_std: the current max C++ language allowed (may be empty with no constraint).
#     :imported_cxx_max_std: the max C++ language standard allowed by a dependency.
#
#     :ERROR: the output variable containing the error type (CRITICAL or WARNING) if any, empty otherwise.
#     :MESSAGE: the output variable containing the message to print when an error is detected.
#     :NEW_CXX_STD: the output variable containing the modified C++ standard if modification required, empty otherwise.
#     :NEW_CXX_MAX_STD: the output variable containing the modified C++ MAX standard if modification required, empty otherwise.
#
function(check_Imported_CXX_Standard ERROR MESSAGE NEW_CXX_STD NEW_CXX_MAX_STD cxx_std imported_cxx_std cxx_max_std imported_cxx_max_std)
  set(${ERROR} PARENT_SCOPE)
  set(${MESSAGE} PARENT_SCOPE)
  set(${NEW_CXX_STD} PARENT_SCOPE)
  set(${NEW_CXX_MAX_STD} PARENT_SCOPE)
  set(ret_mess)
  set(ret_err)
  is_CXX_Version_Less(IS_LESS "${cxx_std}" "${imported_cxx_std}")
  if(IS_LESS)#need to use the system/external dependency standard, otherwise this information would disappear
    if(cxx_max_std)
      is_CXX_Version_Less(IS_LESS "${cxx_max_std}" "${imported_cxx_std}")
      if(IS_LESS)
        set(${ERROR} "CRITICAL" PARENT_SCOPE)
        set(${MESSAGE} "need to change declared C++ standard (${cxx_std}) to ${imported_cxx_std}, but this standard is greater than max allowed (${cxx_max_std})" PARENT_SCOPE)
        return()
      endif()
    endif()
    set(${NEW_CXX_STD} ${imported_cxx_std} PARENT_SCOPE)
    set(ret_err "WARNING")
    set(ret_mess "need to change declared C++ standard (${cxx_std}) to ${imported_cxx_std}")
  endif()
  is_CXX_Version_Less(IS_LESS "${imported_cxx_max_std}" "${cxx_max_std}")
  if(IS_LESS)#need to ajust max standard to the lowest max standard in use
    set(ret_err "WARNING")
    set(${NEW_CXX_MAX_STD} ${imported_cxx_max_std} PARENT_SCOPE)
    if(ret_mess)#already a warning
      set(ret_mess "${ret_mess}. Also need to change declared C++ max standard (${cxx_max_std}) to ${imported_cxx_max_std}")
    else()
      set(ret_mess "need to change declared C++ max standard (${cxx_max_std}) to ${imported_cxx_max_std}")
    endif()
  endif()
  set(${ERROR} "${ret_err}" PARENT_SCOPE)
  set(${MESSAGE} "${ret_mess}" PARENT_SCOPE)
endfunction(check_Imported_CXX_Standard)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Imported_Standards| replace:: ``resolve_Imported_Standards``
#  .. _resolve_Standards:
#
#  resolve_Imported_Standards
#  --------------------------
#
#   .. command:: resolve_Imported_Standards(RES_NEW_C_STD RES_NEW_C_MAX_STD RES_NEW_CXX_STD RES_NEW_CXX_MAX_STD
#                                  curr_c_std curr_c_max_std curr_cxx_std curr_cxx_max_std
#                                  dep_c_std dep_c_max_std dep_cxx_std dep_cxx_max_std)
#
#     Resolve constraints on C and C++ standards. Generates errors when constraints are not compatible.
#
#     :curr_c_std: the current C language standard.
#     :curr_c_max_std: the current max C language allowed (may be empty with no constraint).
#     :curr_cxx_std: the current C++ language standard.
#     :curr_cxx_max_std: the current max C++ language allowed (may be empty with no constraint).
#
#     :dep_c_std: the C language standard specified by a dependency.
#     :dep_c_max_std: the max C language standard allowed by a dependency.
#     :dep_cxx_std: the C++ language standard specified by a dependency.
#     :dep_cxx_max_std: the max C++ language standard allowed by a dependency.
#
#     :ERROR: the output variable containing the error type (CRITICAL or WARNING) if any, empty otherwise.
#     :MESSAGE: the output variable containing the message to print when an error is detected.
#
#     :RES_NEW_C_STD: the output variable containing the modified C standard if modification required, empty otherwise.
#     :RES_NEW_C_MAX_STD: the output variable containing the modified C MAX standard if modification required, empty otherwise.
#     :RES_NEW_CXX_STD: the output variable containing the modified C++ standard if modification required, empty otherwise.
#     :RES_NEW_CXX_MAX_STD: the output variable containing the modified C++ MAX standard if modification required, empty otherwise.
#
function(resolve_Imported_Standards ERROR MESSAGE RES_NEW_C_STD RES_NEW_C_MAX_STD RES_NEW_CXX_STD RES_NEW_CXX_MAX_STD
                           curr_c_std curr_c_max_std curr_cxx_std curr_cxx_max_std
                           dep_c_std dep_c_max_std dep_cxx_std dep_cxx_max_std)
   set(${ERROR} PARENT_SCOPE)
   set(${MESSAGE} PARENT_SCOPE)
   set(curr_mess)
   set(curr_err)
   set(${RES_NEW_C_STD} PARENT_SCOPE)
   set(${RES_NEW_C_MAX_STD} PARENT_SCOPE)
   set(${RES_NEW_CXX_STD} PARENT_SCOPE)
   set(${RES_NEW_CXX_MAX_STD} PARENT_SCOPE)
   check_Imported_C_Standard(ERR MESS
                             NEW_C_STD NEW_C_MAX_STD
                             "${curr_c_std}" "${dep_c_std}"
                             "${curr_c_max_std}" "${dep_c_max_std}")

   if(ERR)
     if(ERR STREQUAL "CRITICAL")
       set(${ERROR} "${ERR}" PARENT_SCOPE)
       set(${MESSAGE} "${MESS}" PARENT_SCOPE)
       return()
     else()#warning
       set(curr_mess "${MESS}")
       set(curr_err "${ERR}")
     endif()
   endif()

   if(NEW_C_STD)#need to modify component due to its dependency
    set(${RES_NEW_C_STD} ${NEW_C_STD} PARENT_SCOPE)
   endif()
   if(NEW_C_MAX_STD)#need to update the max standard allowed
    set(${RES_NEW_C_MAX_STD} ${NEW_C_MAX_STD} PARENT_SCOPE)
   endif()

   #second check C++ language standard
   check_Imported_CXX_Standard(ERROR MESSAGE
                               NEW_CXX_STD NEW_CXX_MAX_STD
                               "${curr_cxx_std}" "${dep_cxx_std}"
                               "${curr_cxx_max_std}" "${dep_cxx_max_std}")
   if(ERR)
     if(ERR STREQUAL "CRITICAL")
       set(${ERROR} "${ERR}" PARENT_SCOPE)
       set(${MESSAGE} "${MESS}" PARENT_SCOPE)
       return()
     else()#warning
       if(curr_mess)
         set(curr_mess "${curr_mess}. ${MESS}")
         set(curr_err "${ERR}")
       endif()
     endif()
   endif()

    if(NEW_CXX_STD)#need to modify component due to its dependency
     set(${RES_NEW_CXX_STD} ${NEW_CXX_STD} PARENT_SCOPE)
    endif()
    if(NEW_CXX_MAX_STD)#need to update the max standard allowed
     set(${RES_NEW_CXX_MAX_STD} ${NEW_CXX_MAX_STD} PARENT_SCOPE)
    endif()

    set(${MESSAGE} "${curr_mess}" PARENT_SCOPE)
    set(${ERROR} "${curr_err}" PARENT_SCOPE)
endfunction(resolve_Imported_Standards)


#################################################################################################
################################### pure CMake utilities ########################################
#################################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |execute_Silent_Process| replace:: ``execute_Silent_Process``
#  .. _execute_Silent_Process:
#
#  execute_Silent_Process
#  ----------------------
#
#   .. command:: execute_Silent_Process(OUTPUT ...)
#
#    Execute a process with silent output but returning the output into a variable.
#
#     :OUTPUT: the output variable containing output of the process (error + standard) .
#
#     :RESULT: the output variable containing result code of the process.
#
#     :dir: working directory for executing the command.
#
#     :...: list of arguments to pass to execute_process
#
function(execute_Silent_Process OUTPUT RESULT dir)
  execute_process(COMMAND ${ARGN}
                  WORKING_DIRECTORY ${dir}
                  OUTPUT_FILE ${CMAKE_BINARY_DIR}/tmp_exec_out.txt
                  ERROR_FILE ${CMAKE_BINARY_DIR}/tmp_exec_out.txt
                  RESULT_VARIABLE res)#pulling master branch of origin or official
  file(READ ${CMAKE_BINARY_DIR}/tmp_exec_out.txt file_content)
  file(REMOVE ${CMAKE_BINARY_DIR}/tmp_exec_out.txt)
  set(${OUTPUT} "${file_content}" PARENT_SCOPE)
  set(${RESULT} "${res}" PARENT_SCOPE)
endfunction(execute_Silent_Process)

#.rst:
#
# .. ifmode:: internal
#
#  .. |call_CTest| replace:: ``call_CTest``
#  .. _wrap_CTest_Call:
#
#  call_CTest
#  ---------------
#
#   .. command:: call_CTest(name command args)
#
#    Create a CTest test.
#
#     :name: name of the test.
#
#     :command: command to execute to runthe test
#
#     :args: list of arguments for the command
#
function(call_CTest name command args)
  if(WIN32)
    add_test(NAME ${name} COMMAND run.bat ${command}.exe ${args})
  else()
    add_test(NAME ${name} COMMAND ${command} ${args})
  endif()
endfunction(call_CTest)

#.rst:
#
# .. ifmode:: internal
#
#  .. |usable_In_Regex| replace:: ``usable_In_Regex``
#  .. _usable_In_Regex:
#
#  usable_In_Regex
#  ---------------
#
#   .. command:: usable_In_Regex(RES_STR name)
#
#    Prepare a string so that its content can be found in a regular expression.
#
#     :name: the string content that is a name we want to search in a regular expression.
#
#     :RES_STR: the output variable that contains the equivalent name usable in a regular expression
#
function(usable_In_Regex RES_STR name)
	string(REPLACE "+" "\\+" RES ${name})
	string(REPLACE "." "\\." RES ${RES})
	string(REPLACE "(" "\\(" RES ${RES})
	string(REPLACE ")" "\\)" RES ${RES})
	string(REPLACE "[" "\\[" RES ${RES})
	string(REPLACE "]" "\\]" RES ${RES})
	set(${RES_STR} ${RES} PARENT_SCOPE)
endfunction(usable_In_Regex)

#.rst:
#
# .. ifmode:: internal
#
#  .. |append_Unique_In_Cache| replace:: ``append_Unique_In_Cache``
#  .. _append_Unique_In_Cache:
#
#  append_Unique_In_Cache
#  ----------------------
#
#   .. command:: append_Unique_In_Cache(list_name element_value)
#
#    Append and element to a list in cache. If the list does not exist in CACHE previous to this call it is created in CACHE.
#
#     :list_name: the input/output CACHE variable containing the list to append.
#
#     :element_value: the new element to append.
#
function(append_Unique_In_Cache list_name element_value)
  if(element_value)
    list(REMOVE_DUPLICATES element_value)
  endif()
  if(${list_name})
		set(temp_list ${${list_name}})
		list(APPEND temp_list ${element_value})
		list(REMOVE_DUPLICATES temp_list)
		set(${list_name} ${temp_list} CACHE INTERNAL "")
	else()
		set(${list_name} ${element_value} CACHE INTERNAL "")
	endif()
endfunction(append_Unique_In_Cache)

#.rst:
#
# .. ifmode:: internal
#
#  .. |remove_From_Cache| replace:: ``remove_From_Cache``
#  .. _remove_From_Cache:
#
#  remove_From_Cache
#  ----------------------
#
#   .. command:: remove_From_Cache(list_name element_value)
#
#    Remove an element from a list in cache. If the list does not exist in CACHE nothing is done.
#
#     :list_name: the input/output CACHE variable containing the list to remove the element from.
#
#     :element_value: the element to remove.
#
function(remove_From_Cache list_name element_value)
	if(${list_name})
		set(temp_list ${${list_name}})
		list(REMOVE_ITEM temp_list ${element_value})
		set(${list_name} ${temp_list} CACHE INTERNAL "")
	else()
		set(${list_name} ${element_value} CACHE INTERNAL "")
	endif()
endfunction(remove_From_Cache)

#.rst:
#
# .. ifmode:: internal
#
#  .. |remove_Duplicates_From_List| replace:: ``remove_Duplicates_From_List``
#  .. _remove_Duplicates_From_List:
#
#  remove_Duplicates_From_List
#  ---------------------------
#
#   .. command:: remove_Duplicates_From_List(list_name)
#
#    Remove duplicates element from list. This function is used to avoid checking the list existence anytime the call of list(REMOVE_DUPLICATE ...) command is used.
#
#     :list_name: the input/output variable containing the list to remove duplicates in.
#
function(remove_Duplicates_From_List list_name)
	if(${list_name})#there are elements in the list
		list(REMOVE_DUPLICATES ${list_name})
		set(${list_name} ${${list_name}} PARENT_SCOPE)
	endif()
endfunction(remove_Duplicates_From_List)

#.rst:
#
# .. ifmode:: internal
#
#  .. |define_Parallel_Jobs_Flag| replace:: ``define_Parallel_Jobs_Flag``
#  .. _define_Parallel_Jobs_Flag:
#
#  define_Parallel_Jobs_Flag
#  -------------------------
#
#   .. command:: define_Parallel_Jobs_Flag(PARALLEL_JOBS_FLAG)
#
#    Get the build system flag to use in order to get optimal number of jobs when building.
#
#     :PARALLEL_JOBS_FLAG: the output variable containing the native build system flag.
#
function(define_Parallel_Jobs_Flag PARALLEL_JOBS_FLAG)
  include(ProcessorCount)
  ProcessorCount(NUMBER_OF_JOBS)
  math(EXPR NUMBER_OF_JOBS "${NUMBER_OF_JOBS}+1")#according to
  if(NUMBER_OF_JOBS GREATER 1)#TODO manage variants between generators
  	set(${PARALLEL_JOBS_FLAG} "-j${NUMBER_OF_JOBS}" PARENT_SCOPE)
  else()
  	set(${PARALLEL_JOBS_FLAG} PARENT_SCOPE)
  endif()
endfunction(define_Parallel_Jobs_Flag)


#.rst:
#
# .. ifmode:: internal
#
#  .. |target_Options_Passed_Via_Environment| replace:: ``target_Options_Passed_Via_Environment``
#  .. _target_Options_Passed_Via_Environment:
#
#  target_Options_Passed_Via_Environment
#  -------------------------------------
#
#   .. command:: target_Options_Passed_Via_Environment(RESULT)
#
#    Tells whether the current CMake generator requires target option to be passed as environment variables
#
#     :RESULT: the output variable that is TRUE if generator requires the use of environment variables
#
function(target_Options_Passed_Via_Environment RESULT)
    if(${CMAKE_GENERATOR} STREQUAL "Unix Makefiles")
      set(${RESULT} FALSE PARENT_SCOPE)
    else()
      set(${RESULT} TRUE PARENT_SCOPE)
    endif()
endfunction(target_Options_Passed_Via_Environment)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Join_Generator_Expression| replace:: ``get_Join_Generator_Expression``
#  .. _get_Join_Generator_Expression:
#
#  get_Join_Generator_Expression
#  -----------------------------
#
#   .. command:: get_Join_Generator_Expression(EXPR_VAR join_list join_flag)
#
#    Create a JOIN generator expression equivalent to the list given in argument.
#
#     :join_list: the list of lements to join in expression.
#     :join_flag: the flag to append before any element of the list (may be empty string).
#
#     :EXPR_VAR: the output variable containing the resulting generator expression.
#
function(get_Join_Generator_Expression EXPR_VAR join_list join_flag)
  list(LENGTH join_list SIZE)
  if(SIZE EQUAL 0)
    set(${EXPR_VAR} "$<0:notuseful>" PARENT_SCOPE)#produces nothing
  else()
    list(REMOVE_DUPLICATES join_list)
    set(res "")
    foreach(element IN LISTS join_list)
      set(res "${res}${join_flag}${element} ")
    endforeach()
    string(STRIP "${res}" res)
    set(${EXPR_VAR} "$<1:${res}>" PARENT_SCOPE)#produces the content of the right side of the generator expression
  endif()
endfunction(get_Join_Generator_Expression)

#.rst:
#
# .. ifmode:: internal
#
#  .. |append_Join_Generator_Expressions| replace:: ``append_Join_Generator_Expressions``
#  .. _append_Join_Generator_Expressions:
#
#  append_Join_Generator_Expressions
#  ---------------------------------
#
#   .. command:: append_Join_Generator_Expressions(inout_expr input_expr)
#
#    Create a JOIN generator expression equivalent for two generator expressions.
#
#     :inout_expr: the input/output variable containing the resulting generator expression, whose content is used as first element in result.
#     :input_expr: input variable containing the second expression to join
#
function(append_Join_Generator_Expressions inout_expr input_expr)
  if(${inout_expr})
    set(${inout_expr} "$<JOIN:${${inout_expr}}, ${input_expr}>" PARENT_SCOPE)
  else()
    set(${inout_expr} "${input_expr}" PARENT_SCOPE)
  endif()
endfunction(append_Join_Generator_Expressions)

#.rst:
#
# .. ifmode:: internal
#
#  .. |symlink_DLLs_To_Lib_Folder| replace:: ``symlink_DLLs_To_Lib_Folder``
#  .. _symlink_DLLs_To_Lib_Folder:
#
#  symlink_DLLs_To_Lib_Folder
#  ---------------------------
#
#   .. command:: symlink_DLLs_To_Lib_Folder(install_directory)
#
#    On Windows, symlinks any DLL present in install_directory/bin to install_directory/lib for consistency with UNIX platforms
#
#     :install_directory: the installation directory containing the bin and lib folders
#
function(symlink_DLLs_To_Lib_Folder install_directory)
  if(WIN32)
    file(GLOB dlls ${install_directory}/bin/*.dll)
    foreach(dll ${dlls})
      string(REPLACE "/bin/" "/lib/" dll_in_src ${dll})
      create_Symlink(${dll} ${dll_in_src})
    endforeach()
  endif()
endfunction(symlink_DLLs_To_Lib_Folder)

#.rst:
#
# .. ifmode:: internal
#
#  .. |enforce_Standard_Install_Dirs| replace:: ``enforce_Standard_Install_Dirs``
#  .. _enforce_Standard_Install_Dirs:
#
#  enforce_Standard_Install_Dirs
#  ---------------------------------
#
#   .. command:: enforce_Standard_Install_Dirs(install_directory)
#
#    create symlinks to existing install folder directories with PID standard names. Used to get homogeneous installs.
#    Note: Build systems may install libraries for instance in a lib64 folder on some platforms, If it's the case, symlink the folder to lib in order to have a unique wrapper description.
#
#     :install_directory: the installation directory containing the bin and src folders
#
function(enforce_Standard_Install_Dirs install_directory)
  if(EXISTS ${install_directory}/lib64)
    create_Symlink(${install_directory}/lib64 ${install_directory}/lib)
  endif()
  if(EXISTS ${install_directory}/lib32)
    create_Symlink(${install_directory}/lib32 ${install_directory}/lib)
  endif()
  if(EXISTS ${install_directory}/bin64)
    create_Symlink(${install_directory}/bin64 ${install_directory}/bin)
  endif()
  if(EXISTS ${install_directory}/bin32)
    create_Symlink(${install_directory}/bin32 ${install_directory}/bin)
  endif()
endfunction(enforce_Standard_Install_Dirs)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Shell_Script_Symlinks| replace:: ``create_Shell_Script_Symlinks``
#  .. create_Shell_Script_Symlinks:
#
#  create_Shell_Script_Symlinks
#  ----------------------------
#
#   .. command:: create_Shell_Script_Symlinks()
#
#     Creates symlinks in the current source directory for the pid and pid.bat script located in the workspace root
#
function(create_Shell_Script_Symlinks)
	set(scripts "pid;pid.bat")
	foreach(script IN LISTS scripts)
		if(NOT EXISTS ${CMAKE_SOURCE_DIR}/${script})
			create_Symlink(${WORKSPACE_DIR}/${script} ${CMAKE_SOURCE_DIR}/${script})
		endif()
    if(NOT EXISTS ${CMAKE_SOURCE_DIR}/build/${script})
			create_Symlink(${WORKSPACE_DIR}/${script} ${CMAKE_SOURCE_DIR}/build/${script})
		endif()
	endforeach()
endfunction(create_Shell_Script_Symlinks)


#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Git_Ignore_File| replace:: ``update_Git_Ignore_File``
#  .. _update_Git_Ignore_File:
#
#  update_Git_Ignore_File
#  ----------------------
#
#   .. command:: update_Git_Ignore_File()
#
#     Create/Update the .gitignore file for current project.
#
#     :gitignore_pattern: the path to the pattern file to use
#
function(update_Git_Ignore_File gitignore_pattern)
  set(project_file ${CMAKE_SOURCE_DIR}/.gitignore)
  if(EXISTS ${project_file})#update
    file(STRINGS ${gitignore_pattern} PATTERN_LINES)
    file(STRINGS ${CMAKE_SOURCE_DIR}/.gitignore PROJECT_LINES)
    set(all_pattern_included TRUE)
    foreach(line IN LISTS PATTERN_LINES)
      list(FIND PROJECT_LINES "${line}" INDEX)
      if(INDEX EQUAL -1)#default line not found
        set(all_pattern_included FALSE)
        break()#stop here and regenerate
      endif()
    endforeach()
    if(NOT all_pattern_included)
      set(TO_APPEND_AFTER_PATTERN)
      foreach(line IN LISTS PROJECT_LINES)
        list(FIND PATTERN_LINES "${line}" INDEX)
        if(INDEX EQUAL -1)#line not found in pattern
          list(APPEND TO_APPEND_AFTER_PATTERN ${line})
        endif()
      endforeach()
      file(COPY ${gitignore_pattern} DESTINATION ${CMAKE_SOURCE_DIR})#regenerate the file
      foreach(line IN LISTS TO_APPEND_AFTER_PATTERN)
        file(APPEND ${project_file} "${line}\n")
      endforeach()
    endif()#otherwise nothing to do
  else()#create
    file(COPY ${gitignore_pattern} DESTINATION ${CMAKE_SOURCE_DIR})
  endif()
endfunction(update_Git_Ignore_File)
