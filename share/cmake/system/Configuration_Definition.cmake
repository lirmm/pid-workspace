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
if(CONFIGURATION_DEFINITION_INCLUDED)
  return()
endif()
set(CONFIGURATION_DEFINITION_INCLUDED TRUE)

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)

include(PID_Utils_Functions NO_POLICY_SCOPE)

include(CMakeParseArguments)
##################################################################################################
#################### API to ease the description of system configurations ########################
##################################################################################################

#.rst:
#
# .. ifmode:: user
#
#  .. |found_PID_Configuration| replace:: ``found_PID_Configuration``
#  .. _found_PID_Configuration:
#
#  found_PID_Configuration
#  -----------------------
#
#   .. command:: found_PID_Configuration(config value)
#
#      Declare the configuration as FOUND or NOT FOUND.
#
#     .. rubric:: Required parameters
#
#     :<config>: the name of the configuration .
#
#     :<value>: TRUE if configuration has been found or FALSE otherwise .
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the find file provided by a configuration.
#
#     .. admonition:: Effects
#        :class: important
#
#        Change configuration status to FOUND or NOT FOUND.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        found_PID_Configuration(boost TRUE)
#
macro(found_PID_Configuration config value)
  set(${config}_CONFIG_FOUND ${value})
endmacro(found_PID_Configuration)

#.rst:
#
# .. ifmode:: user
#
#  .. |installable_PID_Configuration| replace:: ``installable_PID_Configuration``
#  .. _installable_PID_Configuration:
#
#  installable_PID_Configuration
#  -----------------------------
#
#   .. command:: installable_PID_Configuration(config value)
#
#      Declare the configuration as INSTALLABLE or NOT INSTALLABLE.
#
#     .. rubric:: Required parameters
#
#     :<config>: the name of the configuration .
#
#     :<value>: TRUE if configuration can be installed or FALSE otherwise .
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the installable file provided by a configuration.
#
#     .. admonition:: Effects
#        :class: important
#
#        Change configuration status to INSTALLABLE or NOT INSTALLABLE.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        installable_PID_Configuration(boost TRUE)
#
macro(installable_PID_Configuration config value)
  set(${config}_CONFIG_INSTALLABLE ${value})
endmacro(installable_PID_Configuration)

#.rst:
#
# .. ifmode:: user
#
#  .. |convert_PID_Libraries_Into_System_Links| replace:: ``convert_PID_Libraries_Into_System_Links``
#  .. _convert_PID_Libraries_Into_System_Links:
#
#  convert_PID_Libraries_Into_System_Links
#  ---------------------------------------
#
#   .. command:: convert_PID_Libraries_Into_System_Links(list_of_libraries_var OUT_VAR)
#
#      Utility function to be used in configuration find script. Convert absolute path to libraries into system default link options (-l<library name>).
#
#     .. rubric:: Required parameters
#
#     :<list_of_libraries_var>: the name of the variable that contains the list of libraries to convert.
#
#     :<OUT_VAR>: the output variable that contains the list of aquivalent default system link options.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function can be called in the find file provided by a configuration.
#
#     .. admonition:: Effects
#        :class: important
#
#        No side effect.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        convert_PID_Libraries_Into_System_Links(BOOST_LIBRARIES BOOST_LINKS)
#
function(convert_PID_Libraries_Into_System_Links list_of_libraries_var OUT_VAR)
	set(all_links)
  if(${list_of_libraries_var})#the variable containing the list trully contains a list
  	foreach(lib IN LISTS ${list_of_libraries_var})
  		convert_Library_Path_To_Default_System_Library_Link(res_link ${lib})
  		list(APPEND all_links ${res_link})
  	endforeach()
  endif()
  set(${OUT_VAR} ${all_links} PARENT_SCOPE)
endfunction(convert_PID_Libraries_Into_System_Links)


#.rst:
#
# .. ifmode:: user
#
#  .. |convert_PID_Libraries_Into_Library_Directories| replace:: ``convert_PID_Libraries_Into_Library_Directories``
#  .. _convert_PID_Libraries_Into_Library_Directories:
#
#  convert_PID_Libraries_Into_Library_Directories
#  ----------------------------------------------
#
#   .. command:: convert_PID_Libraries_Into_Library_Directories(list_of_libraries_var OUT_VAR)
#
#      Utility function to be used in configuration find script. Extract the library directories to use to find them from absolute path to libraries.
#
#     .. rubric:: Required parameters
#
#     :<list_of_libraries_var>: the name of the variable that contains the list of libraries to convert.
#
#     :<OUT_VAR>: the output variable that contains the list of path to libraries folders.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function can be called in the find file provided by a configuration.
#
#     .. admonition:: Effects
#        :class: important
#
#        No side effect.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        convert_PID_Libraries_Into_Library_Directories(BOOST_LIBRARIES BOOST_LIB_DIRS)
#
function(convert_PID_Libraries_Into_Library_Directories list_of_libraries_var OUT_VAR)
	set(all_links)
  if(${list_of_libraries_var})#the variable containing the list trully contains a list
  	foreach(lib IN LISTS ${list_of_libraries_var})
  		get_filename_component(FOLDER ${lib} DIRECTORY)
  		list(APPEND all_links ${FOLDER})
  	endforeach()
    list(REMOVE_DUPLICATES all_links)
  endif()
  set(${OUT_VAR} ${all_links} PARENT_SCOPE)
endfunction(convert_PID_Libraries_Into_Library_Directories)

#.rst:
#
# .. ifmode:: user
#
#  .. |declare_PID_Configuration_Variables| replace:: ``declare_PID_Configuration_Variables``
#  .. _declare_PID_Configuration_Variables:
#
#  declare_PID_Configuration_Variables
#  -----------------------------------
#
#   .. command:: declare_PID_Configuration_Variables(name VARIABLES ... VALUES ...)
#
#   .. command:: PID_Configuration_Variables(name VARIABLES ... VALUES ...)
#
#      To be used in check files of configuration. Used to declare the list of output variables generated by a configuration and how to set them from variables generated by the find file.
#
#     .. rubric:: Required parameters
#
#     :<name>: the name of the configuration.
#
#     :VARIABLES <list of variables>: the list of variables that are returned by the configuration.
#     :VALUES <list of variables>: the list of variables used to set the value of returned variables. This lis is ordered the same way as VARIABLES, so that each variable in VALUES matches a variable with same index in VARIABLES.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function can be called in the check file provided by a configuration.
#
#     .. admonition:: Effects
#        :class: important
#
#        Memorize variables used for the given configuration.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        # the configuration boost returns differents variables such as: boost_VERSION, boost_RPATH, etc...
#        # These variable are set according to the value of respectively: BOOST_VERSION, Boost_LIBRARY_DIRS, etc.
#
#        declare_PID_Configuration_Variables(boost
#			      VARIABLES VERSION       LIBRARY_DIRS        INCLUDE_DIRS        RPATH
#			      VALUES    BOOST_VERSION Boost_LIBRARY_DIRS  Boost_INCLUDE_DIRS  Boost_LIBRARY_DIRS
#        )
#
#        PID_Configuration_Variables(boost
#			     VARIABLES VERSION       LIBRARY_DIRS        INCLUDE_DIRS        RPATH
#			     VALUES    BOOST_VERSION Boost_LIBRARY_DIRS  Boost_INCLUDE_DIRS  Boost_LIBRARY_DIRS
#        )
#
macro(PID_Configuration_Variables)
  declare_PID_Configuration_Variables(${ARGN})
endmacro(PID_Configuration_Variables)

function(declare_PID_Configuration_Variables)
  set(multiValueArg VARIABLES VALUES) #the value may be a list
  cmake_parse_arguments(PID_CONFIGURATION_VARIABLES "" "" "${multiValueArg}" ${ARGN})
  set(name ${ARGV0})
  if(NOT name OR name STREQUAL "VARIABLES" OR name STREQUAL "VALUES")
    message("[PID] WARNING: Bad usage of function PID_Configuration_Variables, you must give the name of the configuration as first argument")
  elseif(NOT PID_CONFIGURATION_VARIABLES_VARIABLES OR NOT PID_CONFIGURATION_VARIABLES_VALUES)
    message("[PID] WARNING: Bad usage of function PID_Configuration_Variables, you must give the variable to set using VARIABLES keyword and the variable from which it will take value using VALUES keyword")
  else()
    list(LENGTH PID_CONFIGURATION_VARIABLES_VARIABLES SIZE_VARS)
    list(LENGTH PID_CONFIGURATION_VARIABLES_VALUES SIZE_VALS)
    if(NOT SIZE_VARS EQUAL SIZE_VALS)
      message("[PID] WARNING: Bad usage of function PID_Configuration_Variables, you must give the a value (the name of the variable holding the value to set) for each variable defined using VARIABLES keyword. ")
    else()
      set(${name}_RETURNED_VARIABLES ${PID_CONFIGURATION_VARIABLES_VARIABLES} CACHE INTERNAL "")
      foreach(var IN LISTS PID_CONFIGURATION_VARIABLES_VARIABLES)
        list(FIND PID_CONFIGURATION_VARIABLES_VARIABLES ${var} INDEX)
        list(GET PID_CONFIGURATION_VARIABLES_VALUES ${INDEX} CORRESPONDING_VAL)
        set(${name}_${var}_RETURNED_VARIABLE ${CORRESPONDING_VAL} CACHE INTERNAL "")#the value of the variable is not the real value but the name of the variable
      endforeach()
    endif()
  endif()
endfunction(declare_PID_Configuration_Variables)

#.rst:
#
# .. ifmode:: user
#
#  .. |declare_PID_Configuration_Constraints| replace:: ``declare_PID_Configuration_Constraints``
#  .. _declare_PID_Configuration_Contraints:
#
#  declare_PID_Configuration_Constraints
#  -------------------------------------
#
#   .. command:: declare_PID_Configuration_Constraints(name [OPTIONS...])
#
#   .. command:: PID_Configuration_Constraints(name  [OPTIONS...])
#
#      To be used in check files of configuration. Used to declare the list of constraints managed by the configuration.
#
#     .. rubric:: Required parameters
#
#     :<name>: the name of the configuration.
#
#     .. rubric:: Optional parameters
#
#     :REQUIRED <list of variables>: The list of required constraints. Required means that the constraints must be specified at configuration check time. All required constraints always appear in final binaries description.
#     :OPTIONAL <list of variables>: The list of optional constraints. Optional means that the constraints value can be ignored when considering binaries AND no paremeter can be given for those constraints at configuration check time.
#     :IN_BINARY <list of variables>: The list of optional constraints at source compilation time but that are required at binary usage time.
#     :VALUE <list of variables>: The list variables used to set the value of the corresponding list of variables IN_BINARY. Used to initialize the value of constraints used only at binary usage time.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function can be called in the check file provided by a configuration.
#
#     .. admonition:: Effects
#        :class: important
#
#        Memorize constraints that can be used for the given configuration.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        declare_PID_Configuration_Constraints(ros REQUIRED distribution IN_BINARY packages VALUE ROS_PACKAGES)
#
#        PID_Configuration_Constraints(ros REQUIRED distribution IN_BINARY packages VALUE ROS_PACKAGES)
#
macro(PID_Configuration_Constraints)
  declare_PID_Configuration_Constraints(${ARGN})
endmacro(PID_Configuration_Constraints)

function(declare_PID_Configuration_Constraints)
  set(multiValueArg REQUIRED OPTIONAL IN_BINARY VALUE) #the value may be a list
  cmake_parse_arguments(PID_CONFIGURATION_CONSTRAINTS "" "" "${multiValueArg}" ${ARGN})
  set(name ${ARGV0})
  if(NOT name OR name STREQUAL "REQUIRED" OR name STREQUAL "OPTIONAL" OR name STREQUAL "IN_BINARY" OR name STREQUAL "VALUE")
    message("[PID] WARNING: Bad usage of function declare_PID_Configuration_Constraints, you must give the name of the configuration as first argument.")
  elseif(NOT PID_CONFIGURATION_CONSTRAINTS_REQUIRED AND NOT PID_CONFIGURATION_CONSTRAINTS_OPTIONAL AND NOT PID_CONFIGURATION_CONSTRAINTS_IN_BINARY)
    message("[PID] WARNING: Bad usage of function declare_PID_Configuration_Constraints, you must give at least one variable using either REQUIRED, IN_BINARY or OPTIONAL keywords.")
  else()
      set(${name}_REQUIRED_CONSTRAINTS ${PID_CONFIGURATION_CONSTRAINTS_REQUIRED} CACHE INTERNAL "")#the value of the variable is not the real value but the name of the variable
      set(${name}_OPTIONAL_CONSTRAINTS ${PID_CONFIGURATION_CONSTRAINTS_OPTIONAL} CACHE INTERNAL "")#the value of the variable is not the real value but the name of the variable
      list(LENGTH PID_CONFIGURATION_CONSTRAINTS_IN_BINARY SIZE_VARS)
      list(LENGTH PID_CONFIGURATION_CONSTRAINTS_VALUE SIZE_VALS)
      if(NOT SIZE_VARS EQUAL SIZE_VALS)
        message("[PID] WARNING: Bad usage of function declare_PID_Configuration_Constraints, you must give the a value (the name of the variable holding the value to set) for each variable defined using IN_BINARY keyword. ")
      else()
        set(${name}_IN_BINARY_CONSTRAINTS ${PID_CONFIGURATION_CONSTRAINTS_IN_BINARY} CACHE INTERNAL "")#the value of the variable is not the real value but the name of the variable
        foreach(constraint IN LISTS PID_CONFIGURATION_CONSTRAINTS_IN_BINARY)
          list(FIND PID_CONFIGURATION_CONSTRAINTS_IN_BINARY ${constraint} INDEX)
          list(GET PID_CONFIGURATION_CONSTRAINTS_VALUE ${INDEX} CORRESPONDING_VAL)
          set(${name}_${constraint}_BINARY_VALUE ${CORRESPONDING_VAL} CACHE INTERNAL "")#the value of the variable is not the real value but the name of the variable
        endforeach()
      endif()
  endif()
endfunction(declare_PID_Configuration_Constraints)

#.rst:
#
# .. ifmode:: user
#
#  .. |declare_PID_Configuration_Dependencies| replace:: ``declare_PID_Configuration_Dependencies``
#  .. _declare_PID_Configuration_Dependencies:
#
#  declare_PID_Configuration_Dependencies
#  --------------------------------------
#
#   .. command:: declare_PID_Configuration_Dependencies(name [OPTIONS...])
#
#   .. command:: PID_Configuration_Dependencies(name  [OPTIONS...])
#
#      To be used in check files of configuration. Used to declare the list of configuration that the given configuration depends on.
#
#     .. rubric:: Required parameters
#
#     :<name>: the name of the configuration.
#     :DEPENDS <list of configuration checks>: The list of expressions representing the different systems configurations used by given configuration.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function can be called in the check file provided by a configuration.
#
#     .. admonition:: Effects
#        :class: important
#
#        Memorize dependencies used by the given configuration.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        declare_PID_Configuration_Dependencies(ros DEPENDS boost)
#
#        PID_Configuration_Dependencies(ros DEPENDS boost)
#
macro(PID_Configuration_Dependencies)
  declare_PID_Configuration_Dependencies(${ARGN})
endmacro(PID_Configuration_Dependencies)

function(declare_PID_Configuration_Dependencies)
  set(multiValueArg DEPENDS) #the value may be a list
  cmake_parse_arguments(PID_CONFIGURATION_DEPENDENCIES "" "" "${multiValueArg}" ${ARGN})
  set(name ${ARGV0})
  if(NOT name OR name STREQUAL "DEPENDS")
    message("[PID] WARNING: Bad usage of function declare_PID_Configuration_Dependencies, you must give the name of the configuration as first argument.")
  elseif(NOT PID_CONFIGURATION_DEPENDENCIES_DEPENDS)
    message("[PID] WARNING: Bad usage of function declare_PID_Configuration_Dependencies, you must give at least one configuration that ${name} depends on using DEPENDS keyword.")
  else()
    foreach(dep IN LISTS PID_CONFIGURATION_DEPENDENCIES_DEPENDS)
      append_Unique_In_cache(${name}_CONFIGURATION_DEPENDENCIES "${PID_CONFIGURATION_DEPENDENCIES_DEPENDS}")
    endforeach()
  endif()
endfunction(declare_PID_Configuration_Dependencies)
