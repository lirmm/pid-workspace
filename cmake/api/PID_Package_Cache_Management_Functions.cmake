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
if(PID_PACKAGE_CACHE_MANAGEMENT_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_PACKAGE_CACHE_MANAGEMENT_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

#############################################################################################
############### API functions for managing user options cache variables #####################
#############################################################################################
include(CMakeDependentOption)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Native_Global_Cache_Options| replace:: ``declare_Native_Global_Cache_Options``
#  .. _declare_Native_Global_Cache_Options:
#
#  declare_Native_Global_Cache_Options
#  -----------------------------------
#
#   .. command:: declare_Native_Global_Cache_Options()
#
#   Define the generic PID Cmake options that can be set by the user.
#
macro(declare_Native_Global_Cache_Options)

# base options
option(BUILD_EXAMPLES "Package builds examples" OFF)
option(BUILD_API_DOC "Package generates the HTML API documentation" OFF)
set(INTERNAL_OR_DEPENDENT_OPTIONS)
option(BUILD_AND_RUN_TESTS "Package uses tests" OFF)
if(FORCE_DUAL_MODE)
  set(BUILD_RELEASE_ONLY OFF CACHE INTERNAL "" FORCE)
  list(APPEND INTERNAL_OR_DEPENDENT_OPTIONS BUILD_RELEASE_ONLY)
else()
  option(BUILD_RELEASE_ONLY "Package only build release version" ON)
endif()
option(GENERATE_INSTALLER "Package generates an OS installer for UNIX system" OFF)
option(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD "Enabling the automatic download of not found packages marked as required" ON)
option(ENABLE_PARALLEL_BUILD "Package is built with optimum number of jobs with respect to system properties" ON)
option(BUILD_DEPENDENT_PACKAGES "the build will leads to the rebuild of its dependent package that lies in the workspace as source packages" ON)
option(ADDITIONAL_DEBUG_INFO "Getting more info on debug mode or more PID messages (hidden by default)" OFF)
option(BUILD_STATIC_CODE_CHECKING_REPORT "running static checks on libraries and applications, if tests are run then additionnal static code checking tests are automatically added." OFF)
option(ENABLE_SANITIZERS "Enable the sanitizers on the package's components" OFF)
option(WARNINGS_AS_ERRORS "Generating errors when warnings are notified" OFF)

# dependent options
include(CMakeDependentOption)
CMAKE_DEPENDENT_OPTION(BUILD_LATEX_API_DOC "Package generates the LATEX api documentation" OFF "BUILD_API_DOC" OFF)
list(APPEND INTERNAL_OR_DEPENDENT_OPTIONS BUILD_LATEX_API_DOC)

CMAKE_DEPENDENT_OPTION(RUN_TESTS_IN_DEBUG "Package build and run test in debug mode also" OFF "BUILD_AND_RUN_TESTS" OFF)
list(APPEND INTERNAL_OR_DEPENDENT_OPTIONS RUN_TESTS_IN_DEBUG)

CMAKE_DEPENDENT_OPTION(BUILD_COVERAGE_REPORT "Package build a coverage report in debug mode" ON "BUILD_AND_RUN_TESTS;RUN_TESTS_IN_DEBUG" OFF)
list(APPEND INTERNAL_OR_DEPENDENT_OPTIONS BUILD_COVERAGE_REPORT)

CMAKE_DEPENDENT_OPTION(REQUIRED_PACKAGES_AUTOMATIC_UPDATE "Package will try to install new version when configuring" OFF "REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD" OFF)
list(APPEND INTERNAL_OR_DEPENDENT_OPTIONS REQUIRED_PACKAGES_AUTOMATIC_UPDATE)

CMAKE_DEPENDENT_OPTION(SANITIZE_ADDRESS "Enable the address sanitizer" ON "ENABLE_SANITIZERS" OFF)
CMAKE_DEPENDENT_OPTION(SANITIZE_LEAK "Enable the memory leak sanitizer" ON "ENABLE_SANITIZERS" OFF)
CMAKE_DEPENDENT_OPTION(SANITIZE_UNDEFINED "Enable the undefined behavior sanitizer" ON "ENABLE_SANITIZERS" OFF)
list(APPEND INTERNAL_OR_DEPENDENT_OPTIONS SANITIZE_ADDRESS)
list(APPEND INTERNAL_OR_DEPENDENT_OPTIONS SANITIZE_LEAK)
list(APPEND INTERNAL_OR_DEPENDENT_OPTIONS SANITIZE_UNDEFINED)

if(ENABLE_SANITIZERS AND NOT SANITIZE_ADDRESS AND NOT SANITIZE_LEAK AND NOT SANITIZE_UNDEFINED)
  message("[PID] WARNING : ENABLE_SANITIZERS is ON but all sanitizers are OFF")
endif()

list(APPEND INTERNAL_OR_DEPENDENT_OPTIONS TARGET_CONTRIBUTION_SPACE)

set(INTERNAL_OR_DEPENDENT_OPTIONS ${INTERNAL_OR_DEPENDENT_OPTIONS} CACHE INTERNAL "" FORCE)
endmacro(declare_Native_Global_Cache_Options)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Parrallel_Build_Option| replace:: ``manage_Parrallel_Build_Option``
#  .. _manage_Parrallel_Build_Option:
#
#  manage_Parrallel_Build_Option
#  -----------------------------
#
#   .. command:: manage_Parrallel_Build_Option()
#
#   Set the cache variable that defines the generator flags to use when doing parallel build.
#
macro(manage_Parrallel_Build_Option)
### parallel builds management
set(PARALLEL_JOBS_FLAG CACHE INTERNAL "")
if(ENABLE_PARALLEL_BUILD)
  list(FIND LIMITED_JOBS_PACKAGES ${PROJECT_NAME} INDEX)
  if(INDEX EQUAL -1)#project not in the list of packages to restrict to one build job
    if(DEFINED ENV{PID_MAX_JOBS_NUMBER})
      set(PARALLEL_JOBS_FLAG "-j$ENV{PID_MAX_JOBS_NUMBER}")
    else()
      include(ProcessorCount)
      ProcessorCount(NUMBER_OF_JOBS)
      math(EXPR NUMBER_OF_JOBS "${NUMBER_OF_JOBS}+1")
      if(${NUMBER_OF_JOBS} GREATER 1)
        set(PARALLEL_JOBS_FLAG "-j${NUMBER_OF_JOBS}" CACHE INTERNAL "")
      endif()
    endif()
  endif()
endif()
endmacro(manage_Parrallel_Build_Option)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Cache_Option_Line_If_Not_Managed| replace:: ``write_Cache_Option_Line_If_Not_Managed``
#  .. _write_Cache_Option_Line_If_Not_Managed:
#
#  write_Cache_Option_Line_If_Not_Managed
#  --------------------------------------
#
#   .. command:: write_Cache_Option_Line_If_Not_Managed(file entry type managed_entries)
#
#   add to a file a line setting the default cache variable if not already managed
#
#     :file: file to write in.
#     :entry: name of the cache entry.
#     :type: type of the cache entry.
#     :managed_entries: inpout/output variable containing the list of cache entries already contained in the file.
#
function(write_Cache_Option_Line_If_Not_Managed file entry type managed_entries)
  if(${managed_entries})
    list(FIND ${managed_entries} ${entry} INDEX)
    if(NOT INDEX EQUAL -1)#if already found in managed entries then do nothing
      return()
    endif()
  endif()
  if(INTERNAL_OR_DEPENDENT_OPTIONS)
    list(FIND INTERNAL_OR_DEPENDENT_OPTIONS ${entry} INDEX)
    if(NOT INDEX EQUAL -1)
      set(type INTERNAL)
    endif()
  endif()
  #in other situations simply add the entry to the cache
  file(APPEND ${file} "set(${entry} ${${entry}} CACHE ${type} \"\" FORCE)\n")
  set(${managed_entries} ${${managed_entries}} ${entry} PARENT_SCOPE)
endfunction(write_Cache_Option_Line_If_Not_Managed)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Mode_Specific_Options_From_Global| replace:: ``set_Mode_Specific_Options_From_Global``
#  .. _set_Mode_Specific_Options_From_Global:
#
#  set_Mode_Specific_Options_From_Global
#  -------------------------------------
#
#   .. command:: set_Mode_Specific_Options_From_Global()
#
#   Generate the cache file containing build options from cache of the current project global cache.
#
function(set_Mode_Specific_Options_From_Global)
	execute_process(COMMAND ${CMAKE_COMMAND} -L -N ..
                  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                  OUTPUT_FILE ${CMAKE_BINARY_DIR}/options.txt)
	#parsing option file and generating a load cache cmake script
	file(STRINGS ${CMAKE_BINARY_DIR}/options.txt LINES)
	set(CACHE_OK FALSE)
	foreach(line IN LISTS LINES)
		if(NOT line STREQUAL "-- Cache values")
			set(CACHE_OK TRUE)
			break()
		endif()
	endforeach()
	set(OPTIONS_FILE ${CMAKE_BINARY_DIR}/share/cacheConfig.cmake)
	file(WRITE ${OPTIONS_FILE} "")
  set(managed_options)
  if(CACHE_OK)#there is a cache => use it
		foreach(line IN LISTS LINES)
      if(line MATCHES "^([^:]+):([^=]+)=(.*)$")
        if(DEFINED ${CMAKE_MATCH_1})#the target cache variable is defined locally
          if(${CMAKE_MATCH_2} STREQUAL "PATH")
            set(${CMAKE_MATCH_1} "\"${${CMAKE_MATCH_1}}\"") #put paths around double quotes to avoid issues with spaces
          endif()
          set(curr_option "set(${CMAKE_MATCH_1} ${${CMAKE_MATCH_1}} CACHE ${CMAKE_MATCH_2} \"\" FORCE)\n")
        else() #no local definition (strange but OK) => simply recopy the value
          set(curr_option "set(${CMAKE_MATCH_1} ${CMAKE_MATCH_3} CACHE ${CMAKE_MATCH_2} \"\" FORCE)\n")
        endif()
        list(APPEND managed_options ${CMAKE_MATCH_1})
        file(APPEND ${OPTIONS_FILE} ${curr_option})
			endif()
		endforeach()
	#else only populating the load cache script with default PID cache variables to transmit them to release/debug mode caches
	endif()
  #if managed_options is empty this is first run after a hard clean of the build folder
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} WORKSPACE_DIR PATH managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} ADDITIONAL_DEBUG_INFO BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} BUILD_EXAMPLES BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} BUILD_API_DOC BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} BUILD_COVERAGE_REPORT BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} BUILD_STATIC_CODE_CHECKING_REPORT BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} BUILD_LATEX_API_DOC BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} BUILD_AND_RUN_TESTS BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} RUN_TESTS_WITH_PRIVILEGES BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} RUN_TESTS_IN_DEBUG BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} BUILD_RELEASE_ONLY BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} GENERATE_INSTALLER BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} REQUIRED_PACKAGES_AUTOMATIC_UPDATE BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} ENABLE_PARALLEL_BUILD BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} BUILD_DEPENDENT_PACKAGES BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} TARGET_CONTRIBUTION_SPACE STRING managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} ENABLE_SANITIZERS BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} SANITIZE_ADDRESS BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} SANITIZE_LEAK BOOL managed_options)
  write_Cache_Option_Line_If_Not_Managed(${OPTIONS_FILE} SANITIZE_UNDEFINED BOOL managed_options)
  unset(INTERNAL_OR_DEPENDENT_OPTIONS CACHE)
endfunction(set_Mode_Specific_Options_From_Global)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Option_Line_Info| replace:: ``get_Option_Line_Info``
#  .. _get_Option_Line_Info:
#
#  get_Option_Line_Info
#  --------------------
#
#   .. command:: get_Option_Line_Info(NAME TYPE VALUE COMMENT line)
#
#   Extracting information from a line contained in a CMake cache file.
#
#     :line: string taht contains a given line from a cache file.
#
#     :NAME: output variable that contains the name of the option if any in the line, empty otherwise.
#     :TYPE: output variable that contains the type of the option if any in the line, empty otherwise.
#     :VALUE: output variable that contains the value of the option if any in the line, empty otherwise.
#     :COMMENT: output variable that contains the comment if any in the line, empty otherwise.
#
function(get_Option_Line_Info NAME TYPE VALUE COMMENT line)
  set(${NAME} PARENT_SCOPE)
  set(${TYPE} PARENT_SCOPE)
  set(${VALUE} PARENT_SCOPE)
  set(${COMMENT} PARENT_SCOPE)
  if(line AND (NOT line STREQUAL "-- Cache values"))#this line may contain option info
    string(REGEX REPLACE "^//(.*)$" "\\1" COMMENT_LINE ${line})
    if(line STREQUAL "${COMMENT_LINE}") #no match => this NOT a comment =>  is an option line
      string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "\\1;\\2;\\3" AN_OPTION "${line}") #indexes 0: name, 1:type, 2: value
      list(GET AN_OPTION 0 var_name)
      list(GET AN_OPTION 1 var_type)
      list(GET AN_OPTION 2 var_value)
      set(${NAME} ${var_name} PARENT_SCOPE)
      set(${TYPE} ${var_type} PARENT_SCOPE)
      set(${VALUE} ${var_value} PARENT_SCOPE)
    else()#match is OK => this is a comment line
      set(${COMMENT} "${COMMENT_LINE}" PARENT_SCOPE)
    endif()
  endif()#if first line simply do nothing (because no information)
endfunction(get_Option_Line_Info)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Option_Into_List| replace:: ``find_Option_Into_List``
#  .. _find_Option_Into_List:
#
#  find_Option_Into_List
#  ---------------------
#
#   .. command:: find_Option_Into_List(INDEX option_name option_type list_name)
#
#   Finding the given CMake cache option from a list of cache file lines.
#
#     :option_name: the name of the cmake cache option to find.
#     :option_type: the type of the cmake cache option to find (STRING, PATH, INTERNAL, BOOL).
#     :list_name: the name of the list where finding lines from a cache file.
#
#     :INDEX: output variable that contains the index of the line that matches in number of characters, -1 if not found.
#
function(find_Option_Into_List INDEX option_name option_type list_name)
  string(FIND "${${list_name}}" "${option_name}:${option_type}=" POS)
  set(${INDEX} ${POS} PARENT_SCOPE)
endfunction(find_Option_Into_List)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Option_Value_From_List| replace:: ``get_Option_Value_From_List``
#  .. _get_Option_Value_From_List:
#
#  get_Option_Value_From_List
#  --------------------------
#
#   .. command:: get_Option_Value_From_List(VALUE option_name option_type list_name)
#
#   Getting the value of an option from a list of cache file lines.
#
#     :option_name: the name of the cmake cache option to get value from.
#     :option_type: the type of the cmake cache option to get value from (STRING, PATH, INTERNAL, BOOL).
#     :list_name: the name of the list where finding lines from a cache file.
#
#     :VALUE: output variable that contains the value of the cache option (may be empty if option has no value or does not exist).
#
function(get_Option_Value_From_List VALUE option_name option_type list_name)
  set(${VALUE} PARENT_SCOPE)
  foreach(line IN LISTS ${list_name})#value of list name is a list in enclosing scope
    if(line AND (NOT line STREQUAL "-- Cache values"))#this line may contain option info
      string(REGEX REPLACE "^${option_name}:${option_type}=(.*)$" "\\1" AN_OPTION_VAL "${line}")
      if(NOT (line STREQUAL "${AN_OPTION_VAL}"))#MATCH => the option has been found
        set(${VALUE} ${AN_OPTION_VAL} PARENT_SCOPE)
      endif()
    endif()
  endforeach()
endfunction(get_Option_Value_From_List)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Global_Options_From_Mode_Specific| replace:: ``set_Global_Options_From_Mode_Specific``
#  .. _set_Global_Options_From_Mode_Specific:
#
#  set_Global_Options_From_Mode_Specific
#  -------------------------------------
#
#   .. command:: set_Global_Options_From_Mode_Specific()
#
#   Force the build options of the global build mode from cache of the current specific build mode (Release or Debug). Use to update global cache options related to the specific build mode in order to keep consistency of cache at global level.
#
function(set_Global_Options_From_Mode_Specific)
	# GOAL: copying new cache entries in the global build cache
  #first get cache entries from debug and release mode
  if(NOT BUILD_RELEASE_ONLY)
    execute_process(COMMAND ${CMAKE_COMMAND} -LH -N ../..
                    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/debug OUTPUT_FILE ${CMAKE_BINARY_DIR}/optionsDEBUG.txt)
    file(STRINGS ${CMAKE_BINARY_DIR}/optionsDEBUG.txt LINES_DEBUG)
  else()
    set(LINES_DEBUG)
  endif()
  execute_process(COMMAND ${CMAKE_COMMAND} -LH -N ../..
                  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/release OUTPUT_FILE ${CMAKE_BINARY_DIR}/optionsRELEASE.txt)
  if(EXISTS ${CMAKE_BINARY_DIR}/options.txt)
    file(STRINGS ${CMAKE_BINARY_DIR}/options.txt LINES_GLOBAL)
  else()
    set(LINES_GLOBAL)
  endif()
	
	file(STRINGS ${CMAKE_BINARY_DIR}/optionsRELEASE.txt LINES_RELEASE)
  # searching new cache entries in release mode cache
	foreach(line IN LISTS LINES_RELEASE)
    get_Option_Line_Info(OPT_NAME OPT_TYPE OPT_VALUE OPT_COMMENT "${line}")
    if(OPT_COMMENT)#the line contains a comment, simply memorize it (will be used for immediate next option)
      set(last_comment "${OPT_COMMENT}")
    elseif(OPT_NAME AND OPT_TYPE)#the line contains an option
      find_Option_Into_List(INDEX ${OPT_NAME} ${OPT_TYPE} LINES_GLOBAL)#search for same option in global cache
      if(INDEX EQUAL -1)#not found in global cache => this a new cache entry coming from mode specific build
        set(${OPT_NAME} ${OPT_VALUE} CACHE ${OPT_TYPE} "${last_comment}")#value may be empty
      elseif(BUILD_RELEASE_ONLY)
        set(${OPT_NAME} ${OPT_VALUE} CACHE ${OPT_TYPE} "${last_comment}" FORCE)#value may be empty
      endif()
    endif()
	endforeach()
  set(last_comment "")

  # searching new cache entries in debug mode cache
  if(NOT BUILD_RELEASE_ONLY)
    foreach(line IN LISTS LINES_DEBUG)
      get_Option_Line_Info(OPT_NAME OPT_TYPE OPT_VALUE OPT_COMMENT "${line}")
      if(OPT_COMMENT)#the line contains a comment, simply memorize it (will be used for immediate next option)
        set(last_comment "${OPT_COMMENT}")
      elseif(OPT_NAME AND OPT_TYPE)#the line contains an option
        find_Option_Into_List(INDEX_GLOB ${OPT_NAME} ${OPT_TYPE} LINES_GLOBAL)#search for same option in global cache
        find_Option_Into_List(INDEX_REL ${OPT_NAME} ${OPT_TYPE} LINES_RELEASE)#search for same option in global cache
        if(INDEX_GLOB EQUAL -1 AND INDEX_REL EQUAL -1)#not found in global and release caches
          set(${OPT_NAME} ${OPT_VALUE} CACHE ${OPT_TYPE} "${last_comment}")#add it to global cache
        elseif((NOT POS_REL EQUAL -1) AND (NOT POS EQUAL -1))#found in both global and release caches
          #1) check if release and debug have same value
          set(debug_value ${OPT_VALUE})
          get_Option_Value_From_List(release_value ${OPT_NAME} ${OPT_TYPE} LINES_RELEASE)
          if(debug_value STREQUAL release_value) #debug and release have same value
            #1) if their value differ from global one then apply it
            get_Option_Value_From_List(global_value ${OPT_NAME} ${OPT_TYPE} LINES_GLOBAL)
            if(NOT (release_value STREQUAL global_value))#their value is different from value of same global option => need to update
              set(${OPT_NAME} ${release_value} CACHE ${OPT_TYPE} "${last_comment}" FORCE)#add it to global cache
            endif()
          #else debug and release mode variables differ (rare case, except for CMAKE_BUILD_TYPE)
          #simply do nothing : DO NOT remove otherwise at next configuration time it will be added with the value of a mode
          endif()
        endif()
      endif()
  	endforeach()
    set(last_comment "")
  endif()

  # searching removed cache entries in release and debug mode caches => then remove them from global cache
	foreach(line IN LISTS LINES_GLOBAL)
    get_Option_Line_Info(OPT_NAME OPT_TYPE OPT_VALUE OPT_COMMENT "${line}")
    if(OPT_NAME AND OPT_TYPE)#the line contains an option
      if(NOT BUILD_RELEASE_ONLY)
        set(INDEX_DEBUG -1)
        find_Option_Into_List(INDEX_DEBUG ${OPT_NAME} ${OPT_TYPE} LINES_DEBUG)#search for same option in global cache
      endif()
      find_Option_Into_List(INDEX_REL ${OPT_NAME} ${OPT_TYPE} LINES_RELEASE)#search for same option in global cache
      if(INDEX_DEBUG EQUAL -1 AND INDEX_REL EQUAL -1)#not found in debug and release caches
        unset(${OPT_NAME} CACHE) #the option ${OPT_NAME} does not belong to release or debug, simply remove it from global cache
      endif()
    endif()
	endforeach()

	#removing temporary files containing cache entries
  if(NOT BUILD_RELEASE_ONLY)
    file(REMOVE ${CMAKE_BINARY_DIR}/optionsDEBUG.txt)
  endif()
  file(REMOVE ${CMAKE_BINARY_DIR}/optionsRELEASE.txt)
  file(REMOVE ${CMAKE_BINARY_DIR}/options.txt)
endfunction(set_Global_Options_From_Mode_Specific)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Mode_Cache_Options| replace:: ``reset_Mode_Cache_Options``
#  .. _reset_Mode_Cache_Options:
#
#  reset_Mode_Cache_Options
#  ------------------------
#
#   .. command:: reset_Mode_Cache_Options(CACHE_POPULATED)
#
#   Force the reset of the current specific build mode (Release or Debug) cache with content coming from the global cache.
#
#     :CACHE_POPULATED: output variable that is TRUE if cache of the current specific build mode has been reset with values coming from the global cache.
#
function(reset_Mode_Cache_Options CACHE_POPULATED)

set(${CACHE_POPULATED} TRUE PARENT_SCOPE)

#some purely internal variable that are global for the project
set(PROJECT_RUN_TESTS FALSE CACHE INTERNAL "")
set(RUN_TESTS_WITH_PRIVILEGES FALSE CACHE INTERNAL "")
endfunction(reset_Mode_Cache_Options)

#.rst:
#
# .. ifmode:: internal
#
#  .. |first_Called_Build_Mode| replace:: ``first_Called_Build_Mode``
#  .. _first_Called_Build_Mode:
#
#  first_Called_Build_Mode
#  -----------------------
#
#   .. command:: first_Called_Build_Mode(RESULT)
#
#   Tells whether the current specific build mode is the first one called during global build process (depends on CMake options chosen by the user).
#
#     :RESULT: output variable that is TRUE if current specific build mode is the first to execute.
#
function(first_Called_Build_Mode RESULT)
set(${RESULT} FALSE PARENT_SCOPE)
if(CMAKE_BUILD_TYPE MATCHES Debug OR (CMAKE_BUILD_TYPE MATCHES Release AND BUILD_RELEASE_ONLY))
	set(${RESULT} TRUE PARENT_SCOPE)
endif()
endfunction(first_Called_Build_Mode)

############################################################################
############### API functions for setting global package info ##############
############################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Component| replace:: ``print_Component``
#  .. _print_Component:
#
#  print_Component
#  ----------------
#
#   .. command:: print_Component(component)
#
#   Print the  variables for the target of a given component in the currenlty defined package.
#
#     :component: the name of the component to print.
#
macro(print_Component component)
	if(NOT ${PROJECT_NAME}_${component}_TYPE STREQUAL "PYTHON")
		message("COMPONENT : ${component}${INSTALL_NAME_SUFFIX}")
		message("INTERFACE : ")
		get_target_property(RES_VAR ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} INTERFACE_INCLUDE_DIRECTORIES)
		message("includes of ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} INTERFACE_COMPILE_DEFINITIONS)
		message("defs of ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} INTERFACE_LINK_LIBRARIES)
		message("libraries of ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")

		if(NOT ${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
			message("IMPLEMENTATION :")
			get_target_property(RES_VAR ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} INCLUDE_DIRECTORIES)
			message("includes of ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
			get_target_property(RES_VAR ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} COMPILE_DEFINITIONS)
			message("defs of ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
			get_target_property(RES_VAR ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} LINK_LIBRARIES)
			message("libraries of ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		endif()
	else()
		message("COMPONENT : ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} IS PYTHON SCRIPT")
	endif()
endmacro(print_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Component_Variables| replace:: ``print_Component_Variables``
#  .. _print_Component_Variables:
#
#  print_Component_Variables
#  -------------------------
#
#   .. command:: print_Component_Variables()
#
#   Print target related variables for all components of the currenlty defined package.
#
macro(print_Component_Variables)
	message("components of package ${PROJECT_NAME} are :" ${${PROJECT_NAME}_COMPONENTS})
	message("libraries : " ${${PROJECT_NAME}_COMPONENTS_LIBS})
	message("applications : " ${${PROJECT_NAME}_COMPONENTS_APPS})
	message("applications : " ${${PROJECT_NAME}_COMPONENTS_SCRIPTS})

	foreach(component IN LISTS ${PROJECT_NAME}_COMPONENTS)
		print_Component(${component})
	endforeach()
endmacro(print_Component_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Standard_Path_Cache_Variables| replace:: ``init_Standard_Path_Cache_Variables``
#  .. _init_Standard_Path_Cache_Variables:
#
#  init_Standard_Path_Cache_Variables
#  ----------------------------------
#
#   .. command:: init_Standard_Path_Cache_Variables()
#
#   Initialize generic cache variables values in currently defined package (for instance used to set CMAKE_INSTALL_PREFIX).
#
function(init_Standard_Path_Cache_Variables)
set(${PROJECT_NAME}_INSTALL_PATH ${PACKAGE_BINARY_INSTALL_DIR}/${PROJECT_NAME} CACHE INTERNAL "")
set(CMAKE_INSTALL_PREFIX ${${PROJECT_NAME}_INSTALL_PATH}  CACHE INTERNAL "" FORCE)
set(${PROJECT_NAME}_PID_RUNTIME_RESOURCE_PATH ${CMAKE_SOURCE_DIR}/share/resources CACHE INTERNAL "")
endfunction(init_Standard_Path_Cache_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Install_Cache_Variables| replace:: ``set_Install_Cache_Variables``
#  .. _set_Install_Cache_Variables:
#
#  set_Install_Cache_Variables
#  ---------------------------
#
#   .. command:: set_Install_Cache_Variables()
#
#   Set cache variables values for all PID standard variable used for install in currently defined package.
#
function(set_Install_Cache_Variables)
	set(${PROJECT_NAME}_DEPLOY_PATH ${${PROJECT_NAME}_VERSION} CACHE INTERNAL "")
	set(${PROJECT_NAME}_INSTALL_LIB_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set(${PROJECT_NAME}_INSTALL_AR_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set(${PROJECT_NAME}_INSTALL_HEADERS_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/include CACHE INTERNAL "")
	set(${PROJECT_NAME}_INSTALL_SHARE_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/share CACHE INTERNAL "")
	set(${PROJECT_NAME}_INSTALL_SCRIPT_PATH ${${PROJECT_NAME}_INSTALL_SHARE_PATH}/script CACHE INTERNAL "")
	set(${PROJECT_NAME}_INSTALL_BIN_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/bin CACHE INTERNAL "")
	set(${PROJECT_NAME}_INSTALL_RPATH_DIR ${${PROJECT_NAME}_DEPLOY_PATH}/.rpath CACHE INTERNAL "")
	set(${PROJECT_NAME}_ROOT_DIR ${PACKAGE_BINARY_INSTALL_DIR}/${PROJECT_NAME}/${${PROJECT_NAME}_DEPLOY_PATH} CACHE INTERNAL "")
endfunction(set_Install_Cache_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Version_Cache_Variables| replace:: ``set_Version_Cache_Variables``
#  .. _set_Version_Cache_Variables:
#
#  set_Version_Cache_Variables
#  ---------------------------
#
#   .. command:: set_Version_Cache_Variables(major minor patch)
#
#   Set cache variables values for PID standard variable used for version description in currently defined package.
#
#     :major: the major version number
#     :minor: the minor version number
#     :patch: the patch version number
#
function(set_Version_Cache_Variables major minor patch)
	set(${PROJECT_NAME}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set(${PROJECT_NAME}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set(${PROJECT_NAME}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set(${PROJECT_NAME}_VERSION "${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH}" CACHE INTERNAL "")
endfunction(set_Version_Cache_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Version_Cache_Variables| replace:: ``reset_Version_Cache_Variables``
#  .. _reset_Version_Cache_Variables:
#
#  reset_Version_Cache_Variables
#  -----------------------------
#
#   .. command:: reset_Version_Cache_Variables()
#
#   Reset cache variables values for PID standard variable used for version description in currently defined package. Used for cleaning the project before starting configuration.
#
macro(reset_Version_Cache_Variables)
#resetting general info about the package : only list are reset
set(${PROJECT_NAME}_VERSION_MAJOR CACHE INTERNAL "" )
set(${PROJECT_NAME}_VERSION_MINOR CACHE INTERNAL "" )
set(${PROJECT_NAME}_VERSION_PATCH CACHE INTERNAL "" )
set(${PROJECT_NAME}_VERSION CACHE INTERNAL "" )

#unset equivalent CMake generated variables
unset(${PROJECT_NAME}_VERSION_MAJOR)
unset(${PROJECT_NAME}_VERSION_MINOR)
unset(${PROJECT_NAME}_VERSION_PATCH)
unset(${PROJECT_NAME}_VERSION)

endmacro(reset_Version_Cache_Variables)


#############################################################################################
############### API functions for setting components related cache variables ################
#############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |package_Has_Nothing_To_Build| replace:: ``package_Has_Nothing_To_Build``
#  .. _package_Has_Nothing_To_Build:
#
#  package_Has_Nothing_To_Build
#  ----------------------------
#
#   .. command:: package_Has_Nothing_To_Build(NOTHING_BUILT)
#
#   Tell whether a package has something to build or not.
#
#     :NOTHING_BUILT: the output variable that is TRUE if the package content define nothing to build (depending on options chosen by the user and content of the package).
#
function(package_Has_Nothing_To_Build NOTHING_BUILT)
	foreach(comp IN LISTS ${PROJECT_NAME}_COMPONENTS)
		will_be_Built(RES ${comp})
		if(RES)
			set(${NOTHING_BUILT} FALSE PARENT_SCOPE)
			return()
		endif()
	endforeach()
	set(${NOTHING_BUILT} TRUE PARENT_SCOPE)
endfunction(package_Has_Nothing_To_Build)

#.rst:
#
# .. ifmode:: internal
#
#  .. |package_Has_Nothing_To_Install| replace:: ``package_Has_Nothing_To_Install``
#  .. _package_Has_Nothing_To_Install:
#
#  package_Has_Nothing_To_Install
#  ------------------------------
#
#   .. command:: package_Has_Nothing_To_Install(NOTHING_INSTALLED)
#
#   Tell whether a package has something to install or not.
#
#     :NOTHING_INSTALLED: the output variable that is TRUE if the package content define nothing to install (depending on options chosen by the user and content of the package).
#
function(package_Has_Nothing_To_Install NOTHING_INSTALLED)
	if(${PROJECT_NAME}_COMPONENTS)
		foreach(comp IN LISTS ${PROJECT_NAME}_COMPONENTS)
			will_be_Installed(RES ${comp})
			if(RES)
				set(${NOTHING_INSTALLED} FALSE PARENT_SCOPE)
				return()
			endif()
		endforeach()
	endif()
	set(${NOTHING_INSTALLED} TRUE PARENT_SCOPE)
endfunction(package_Has_Nothing_To_Install)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Usable_Python_Wrapper_Module| replace:: ``is_Usable_Python_Wrapper_Module``
#  .. _is_Usable_Python_Wrapper_Module:
#
#  is_Usable_Python_Wrapper_Module
#  -------------------------------
#
#   .. command:: is_Usable_Python_Wrapper_Module(IS_PYTHON package component)
#
#   Check whether a component is a python wrapped module and whether it can be used inside current workspace.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component to check.
#
#     :IS_PYTHON: the output variable that is TRUE if the package content define nothing to install (depending on options chosen by the user and content of the package).
#
function(is_Usable_Python_Wrapper_Module IS_PYTHON package component)
	if(${package}_${component}_TYPE STREQUAL "MODULE" #otherwise cannot be a python wrapper
      AND CURRENT_PYTHON)# otherwise cannot be usable since python not activated
		set(${IS_PYTHON} ${${package}_${component}_HAS_PYTHON_WRAPPER} PARENT_SCOPE)
	else()
		set(${IS_PYTHON} FALSE PARENT_SCOPE)
	endif()
endfunction(is_Usable_Python_Wrapper_Module)

#.rst:
#
# .. ifmode:: internal
#
#  .. |configure_Install_Variables_From_Dependency| replace:: ``configure_Install_Variables_From_Dependency``
#  .. _configure_Install_Variables_From_Dependency:
#
#  configure_Install_Variables_From_Dependency
#  -------------------------------------------
#
#   .. command:: configure_Install_Variables_From_Dependency(component export include_dirs dep_defs exported_defs exported_options static_links shared_links c_standard c_max_standard cxx_standard cxx_max_standard runtime_resources)
#
#   Configure cache variables defining a component of the currenlty defined package according to specification of a dependency. These variables will be used to generate the part of the package cmake use file related to the component.
#
#     :component: the name of the component.
#     :export: if TRUE means that the component description is exported by the package (i.e. may be used by other packages).
#     :include_dirs: the list of external include path known by the component.
#     :library_dirs: the list of path where to search libraries.
#     :dep_defs:  the list of preprocessor definitions defined by the component but used in the interface of its external dependencies.
#     :exported_defs:  the list of preprocessor definitions defined by the component and used in its own interface.
#     :exported_options:  the list of compiler options exported by the component.
#     :static_links:  the list of path to external static libraries used by the component.
#     :shared_links:  the list of path to external shared libraries used by the component.
#     :c_standard:  the C language standard used by the dependency.
#     :c_max_standard:  the max C language standard allowed by the dependency.
#     :cxx_standard:  the C++ language standard used by the dependency.
#     :cxx_max_standard:  the max C++ language standard allowed by the dependency.
#     :runtime_resources: the list of path to runtime resources used by the component.
#
function (configure_Install_Variables_From_Dependency component export include_dirs library_dirs
                                      dep_defs exported_defs
                                      exported_options
                                      static_links shared_links
                                      c_standard c_max_standard cxx_standard cxx_max_standard
                                      runtime_resources)
# configuring the export
if(export) # if dependancy library is exported then we need to register its dep_defs and include dirs in addition to component interface defs
	if(dep_defs OR exported_defs)
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} "${exported_defs}")
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} "${dep_defs}")
	endif()
	if(include_dirs)
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} "${include_dirs}")
	endif()
	if(library_dirs)
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_LIB_DIRS${USE_MODE_SUFFIX} "${library_dirs}")
	endif()
	if(exported_options)
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_OPTS${USE_MODE_SUFFIX} "${exported_options}")
	endif()
  # links are exported since we will need to resolve symbols in the third party components that will the use the component
	if(shared_links)
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} "${shared_links}")
	endif()
	if(static_links)
    foreach(link IN LISTS static_links)
      if(link MATCHES "^-(.+)$")#special case : an OS link that is specifically specified as a static link
        append_Unique_In_Cache(${PROJECT_NAME}_${component}_SYSTEM_STATIC_LINKS${USE_MODE_SUFFIX} ${link})
      else()
        append_Unique_In_Cache(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} ${link})
      endif()
    endforeach()
	endif()

else() # otherwise no need to register them since no more useful
	if(exported_defs)
		#just add the exported defs of the component not those of the dependency
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} "${exported_defs}")
	endif()
	if(static_links) #static links are exported if component is not a shared or module lib (otherwise they simply disappear)
		if (	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER"
			OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "STATIC"
		)
      foreach(link IN LISTS static_links)
        if(link MATCHES "^-(.+)$")#special case : an OS link that is specifically specified as a static link
          append_Unique_In_Cache(${PROJECT_NAME}_${component}_SYSTEM_STATIC_LINKS${USE_MODE_SUFFIX} ${link})
        else()
          append_Unique_In_Cache(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} ${link})
        endif()
      endforeach()
		endif()
	endif()
	if(shared_links)#private links are shared "non exported" libraries -> these links are used to process executables linking
    #should be used in very rare cases for system libraries at specific places OR only to manage legacy binary packages OR to manage private links to external package content
    append_Unique_In_Cache(${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX} "${shared_links}")
	endif()
endif()

if(c_standard)
  evaluate_Variables_In_List(EVAL_CSTD c_standard)
  evaluate_Variables_In_List(EVAL_MAX_CSTD c_max_standard)

  #adjust languages standards version, also check adjustment considering max standard, if any
  check_Imported_C_Standard(ERROR MESSAGE NEW_C_STD NEW_C_MAX_STD
                            "${${PROJECT_NAME}_${component}_C_STANDARD${USE_MODE_SUFFIX}}" "${EVAL_CSTD}"
                            "${${PROJECT_NAME}_${component}_C_MAX_STANDARD${USE_MODE_SUFFIX}}" "${EVAL_MAX_CSTD}")
  if(ERROR)
    if(ERROR STREQUAL "CRITICAL")
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR: in ${PROJECT_NAME}, when adding system/external dependency to component ${component} : ${MESSAGE}")
    else()#warning
      message("[PID] WARNING: in ${PROJECT_NAME}, when adding system/external dependency to component ${component} : ${MESSAGE}")
    endif()
  endif()

  if(NEW_C_STD)
    set(${PROJECT_NAME}_${component}_C_STANDARD${USE_MODE_SUFFIX} ${NEW_C_STD} CACHE INTERNAL "")
  endif()
  if(NEW_C_MAX_STD)
    set(${PROJECT_NAME}_${component}_C_MAX_STANDARD${USE_MODE_SUFFIX} ${NEW_C_MAX_STD} CACHE INTERNAL "")
  endif()
endif()

if(cxx_standard)
  #need to evaluate standard before checking
  evaluate_Variables_In_List(EVAL_CXXSTD cxx_standard)
  evaluate_Variables_In_List(EVAL_MAX_CXXSTD cxx_max_standard)
  check_Imported_CXX_Standard(ERROR MESSAGE NEW_CXX_STD NEW_CXX_MAX_STD
                            "${${PROJECT_NAME}_${component}_CXX_STANDARD${USE_MODE_SUFFIX}}" "${EVAL_CXXSTD}"
                            "${${PROJECT_NAME}_${component}_CXX_MAX_STANDARD${USE_MODE_SUFFIX}}" "${EVAL_MAX_CXXSTD}")
  if(ERROR)
    if(ERROR STREQUAL "CRITICAL")
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR: in ${PROJECT_NAME}, when adding system/external dependency to component ${component} : ${MESSAGE}")
    else()#warning
      message("[PID] WARNING: in ${PROJECT_NAME}, when adding system/external dependency to component ${component} : ${MESSAGE}")
    endif()
  endif()

  if(NEW_CXX_STD)
    set(${PROJECT_NAME}_${component}_CXX_STANDARD${USE_MODE_SUFFIX} ${NEW_CXX_STD} CACHE INTERNAL "")
  endif()
  if(NEW_CXX_MAX_STD)
    set(${PROJECT_NAME}_${component}_CXX_MAX_STANDARD${USE_MODE_SUFFIX} ${NEW_CXX_MAX_STD} CACHE INTERNAL "")
  endif()
endif()

if(runtime_resources)#runtime resources are exported in any case
  append_Unique_In_Cache(${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${USE_MODE_SUFFIX} "${runtime_resources}")
endif()
endfunction(configure_Install_Variables_From_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |adjust_Languages_Standard_For_Imported_Component| replace:: ``adjust_Languages_Standard_For_Imported_Component``
#  .. _adjust_Languages_Standard_For_Imported_Component:
#
#  adjust_Languages_Standard_For_Imported_Component
#  ------------------------------------------------
#
#   .. command:: adjust_Languages_Standard_For_Imported_Component(package component mode)
#
#   Adjust desription of languages standards in use for a component depending on its options
#
#     :package: the name of the package owning the component.
#     :component: the name of the component.
#     :mode: the target build mode
#
#     :RES_OPTS: the output variable the contains the options without any call to language standard settings
#
function(adjust_Languages_Standard_For_Imported_Component RES_OPTS package component mode)
  set(${RES_OPTS} PARENT_SCOPE)
  list_Public_Options(OPTS ${package} ${component} ${mode})
  if(OPTS)
    get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})#get variables related to the current build mode
    set(fake_intern_opts)
    adjust_Languages_Standards_Description(ERR MESS C_STD_USED CXX_STD_USED NO_INTERN_OPTS FILTERED_OPTS
                                          fake_intern_opts OPTS
                                          "${${package}_${component}_C_STANDARD${VAR_SUFFIX}}"
                                          "${${package}_${component}_C_MAX_STANDARD${VAR_SUFFIX}}"
                                          "${${package}_${component}_CXX_STANDARD${VAR_SUFFIX}}"
                                          "${${package}_${component}_CXX_MAX_STANDARD${VAR_SUFFIX}}")
    if(ERR)
      if(ERR STREQUAL "CRITICAL")
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        message(FATAL_ERROR "[PID] CRITICAL ERROR: for component ${component} from package ${package} in ${PROJECT_NAME} context, ${MESS}")
      else()
        message("[PID] WARNING: for component ${component} from package ${package} in ${PROJECT_NAME} context, ${MESS}")
      endif()
    endif()
    set(${RES_OPTS} ${FILTERED_OPTS} PARENT_SCOPE)
    if(C_STD_USED)
      set(${package}_${component}_C_STANDARD${VAR_SUFFIX} ${C_STD_USED})
    endif()
    if(CXX_STD_USED)
      set(${package}_${component}_CXX_STANDARD${VAR_SUFFIX} ${CXX_STD_USED})
    endif()
  endif()
endfunction(adjust_Languages_Standard_For_Imported_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Package_Dependency| replace:: ``is_Package_Dependency``
#  .. _is_Package_Dependency:
#
#  is_Package_Dependency
#  ---------------------
#
#   .. command:: is_Package_Dependency(IS_DEPENDENCY dep_package)
#
#   Check whether a native or external package is a dependency of the currently defined package.
#
#     :dep_package: the name of the package to check.
#
#     :IS_DEPENDENCY: the output variable that is TRUE if dep_package is a dependency of the current package, FALSE otherwise.
#
function(is_Package_Dependency IS_DEPENDENCY dep_package)
set(${IS_DEPENDENCY} FALSE PARENT_SCOPE)
if(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})#there are dependencies to sreach in
	list(FIND ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package} INDEX)
	if(NOT INDEX EQUAL -1) #package found in dependencies
		set(${IS_DEPENDENCY} TRUE PARENT_SCOPE)
		return()
	endif()
endif()
if(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})#there are external dependencies to sreach in
	list(FIND ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package} INDEX)
	if(NOT INDEX EQUAL -1)#package found in dependencies
		set(${IS_DEPENDENCY} TRUE PARENT_SCOPE)
		return()
	endif()
endif()
endfunction(is_Package_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Package_Dependency_To_Cache| replace:: ``add_Package_Dependency_To_Cache``
#  .. _add_Package_Dependency_To_Cache:
#
#  add_Package_Dependency_To_Cache
#  -------------------------------
#
#   .. command:: add_Package_Dependency_To_Cache(dep_package version exact list_of_components)
#
#   Set adequate cache variables of currently defined package when defining a native package dependency.
#
#     :dep_package: the name of the native package that IS the dependency.
#     :version: the version constraint on dep_package (may be empty string if no version constraint applies).
#     :exact: if TRUE the version constraint is exact.
#     :list_of_components: the list of components that must belong to dep_package.
#
function(add_Package_Dependency_To_Cache dep_package version exact list_of_components)
  append_Unique_In_Cache(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package})
  append_Unique_In_Cache(${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} "${list_of_components}")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} ${version} CACHE INTERNAL "")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION_EXACT${USE_MODE_SUFFIX} ${exact} CACHE INTERNAL "")#false by definition since no version constraint
endfunction(add_Package_Dependency_To_Cache)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_External_Package_Dependency_To_Cache| replace:: ``add_External_Package_Dependency_To_Cache``
#  .. _add_External_Package_Dependency_To_Cache:
#
#  add_External_Package_Dependency_To_Cache
#  ----------------------------------------
#
#   .. command:: add_External_Package_Dependency_To_Cache(dep_package version exact system list_of_components)
#
#   Set adequate cache variables of currently defined package when defining an external package dependency.
#
#     :dep_package: the name of the external package that IS the dependency.
#     :version: the version constraint on dep_package (may be empty string if no version constraint applies).
#     :exact: if TRUE the version constraint is exact.
#     :system: if TRUE the version constraint targets the OS installed version.
#     :list_of_components: the list of components that must belong to dep_package.
#
function(add_External_Package_Dependency_To_Cache dep_package version exact system list_of_components)
  append_Unique_In_Cache(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package})
  append_Unique_In_Cache(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} "${list_of_components}")
  set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} ${version} CACHE INTERNAL "")
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION_EXACT${USE_MODE_SUFFIX} ${exact} CACHE INTERNAL "")#false by definition since no version constraint
  set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION_SYSTEM${USE_MODE_SUFFIX} ${system} CACHE INTERNAL "")#false by definition since no version constraint
endfunction(add_External_Package_Dependency_To_Cache)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Component_Cached_Variables| replace:: ``reset_Component_Cached_Variables``
#  .. _reset_Component_Cached_Variables:
#
#  reset_Component_Cached_Variables
#  --------------------------------
#
#   .. command:: reset_Component_Cached_Variables(package component mode)
#
#   Reset all cache internal variables related to a given component contained in a given package. Used to ensure the cache is clean before configuring.
#
#     :package: the name of the target package.
#     :component: the name of the target component.
#     :mode: the build mode.
#
function(reset_Component_Cached_Variables package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
# resetting package dependencies
foreach(a_dep_pack IN LISTS ${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
	foreach(a_dep_comp IN LISTS ${package}_${component}_DEPENDENCY_${a_dep_pack}_COMPONENTS${VAR_SUFFIX})
		set(${package}_${component}_EXPORT_${a_dep_pack}_${a_dep_comp}${VAR_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${package}_${component}_DEPENDENCY_${a_dep_pack}_COMPONENTS${VAR_SUFFIX}  CACHE INTERNAL "")
endforeach()
set(${package}_${component}_DEPENDENCIES${VAR_SUFFIX}  CACHE INTERNAL "")

# resetting internal dependencies
foreach(a_internal_dep_comp IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
	set(${package}_${component}_INTERNAL_EXPORT_${a_internal_dep_comp}${VAR_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX} CACHE INTERNAL "")

#resetting all other variables
set(${package}_${component}_HEADER_DIR_NAME CACHE INTERNAL "")
set(${package}_${component}_HEADERS CACHE INTERNAL "")
set(${package}_${component}_C_STANDARD CACHE INTERNAL "")
set(${package}_${component}_CXX_STANDARD CACHE INTERNAL "")
set(${package}_${component}_C_MAX_STANDARD CACHE INTERNAL "")
set(${package}_${component}_CXX_MAX_STANDARD CACHE INTERNAL "")
set(${package}_${component}_BINARY_NAME${VAR_SUFFIX} CACHE INTERNAL "")
set(${package}_${component}_DEFS${VAR_SUFFIX} CACHE INTERNAL "")
set(${package}_${component}_OPTS${VAR_SUFFIX} CACHE INTERNAL "")
set(${package}_${component}_LINKS${VAR_SUFFIX} CACHE INTERNAL "")
set(${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX} CACHE INTERNAL "")
set(${package}_${component}_SYSTEM_STATIC_LINKS${VAR_SUFFIX} CACHE INTERNAL "")
set(${package}_${component}_INC_DIRS${VAR_SUFFIX} CACHE INTERNAL "")
set(${package}_${component}_LIB_DIRS${VAR_SUFFIX} CACHE INTERNAL "")
set(${package}_${component}_SOURCE_CODE CACHE INTERNAL "")
set(${package}_${component}_SOURCE_DIR CACHE INTERNAL "")
set(${package}_${component}_AUX_SOURCE_CODE CACHE INTERNAL "")
set(${package}_${component}_AUX_MONITORED_PATH CACHE INTERNAL "")
set(${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX} CACHE INTERNAL "")
set(${package}_${component}_DESCRIPTION CACHE INTERNAL "")
set(${package}_${component}_USAGE_INCLUDES CACHE INTERNAL "")
set(${package}_${component}_INTERNAL_ONLY CACHE INTERNAL "")
set(${package}_${component}_FOR_EXAMPLES CACHE INTERNAL "")
set(${package}_${component}_FOR_TESTS CACHE INTERNAL "")
endfunction(reset_Component_Cached_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Component_Cached_Variables_For_Export| replace:: ``init_Component_Cached_Variables_For_Export``
#  .. _init_Component_Cached_Variables_For_Export:
#
#  init_Component_Cached_Variables_For_Export
#  ------------------------------------------
#
#   .. command:: init_Component_Cached_Variables_For_Export(component c_standard cxx_standard exported_defs exported_options exported_links runtime_resources)
#
#   Initialize cache internal variables related to a given component.
#
#     :component: the name of the target component.
#     :c_standard:  the C language standard used by component.
#     :c_max_standard:  the maximum C language standard allowed when using the component.
#     :cxx_standard:  the C++ language standard used by component.
#     :cxx_max_standard:  the maximum C++ language standard allowed when using the component.
#     :exported_defs:  the list of preprocessor definitions defined by the component and used in its own interface.
#     :exported_options:  the list of compiler options exported by the component.
#     :exported_links:  the list of links used by the component and exported in its description.
#     :runtime_resources: the list of path to runtime resources used by the component.
#
function(init_Component_Cached_Variables_For_Export component c_standard c_max_standard cxx_standard cxx_max_standard exported_defs exported_options exported_links runtime_resources)
set(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} "${exported_defs}" CACHE INTERNAL "") #exported defs
set(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} "${exported_links}" CACHE INTERNAL "") #exported links
set(${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} "" CACHE INTERNAL "") #exported include directories (not useful to set it there since they will be exported "manually")
set(${PROJECT_NAME}_${component}_OPTS${USE_MODE_SUFFIX} "${exported_options}" CACHE INTERNAL "") #exported compiler options
set(${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${USE_MODE_SUFFIX} "${runtime_resources}" CACHE INTERNAL "")#runtime resources are exported by default
set(${PROJECT_NAME}_${component}_C_STANDARD${USE_MODE_SUFFIX} "${c_standard}" CACHE INTERNAL "")#minimum C standard of the component interface
set(${PROJECT_NAME}_${component}_CXX_STANDARD${USE_MODE_SUFFIX} "${cxx_standard}" CACHE INTERNAL "")#minimum C++ standard of the component interface
set(${PROJECT_NAME}_${component}_C_MAX_STANDARD${USE_MODE_SUFFIX} "${c_max_standard}" CACHE INTERNAL "")#minimum C standard of the component interface
set(${PROJECT_NAME}_${component}_CXX_MAX_STANDARD${USE_MODE_SUFFIX} "${cxx_max_standard}" CACHE INTERNAL "")#minimum C++ standard of the component interface
endfunction(init_Component_Cached_Variables_For_Export)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Alias_To_Cache| replace:: ``add_Alias_To_Cache``
#  .. _add_Alias_To_Cache:
#
#  add_Alias_To_Cache
#  ------------------
#
#   .. command:: add_Alias_To_Cache(component alias_list)
#
#   Add an alias to a component of teh current project.
#
#     :component: the name of the component.
#     :alias_list: list of aliases names for the component.
#
function(add_Alias_To_Cache component alias_list)
  foreach(alias IN LISTS alias_list)
    list(FIND ${PROJECT_NAME}_ALIASES ${alias} INDEX)
    if(NOT INDEX EQUAL -1)
      message(FATAL_ERROR "[PID] CRITICAL ERROR: the alias ${alias} used for component ${component} is already used as alias for another component")
    endif()
    list(FIND ${PROJECT_NAME}_COMPONENTS ${alias} INDEX)
    if(NOT INDEX EQUAL -1)
      message(FATAL_ERROR "[PID] CRITICAL ERROR: the alias ${alias} used for component ${component} is already the name of another component")
    endif()
    set(${PROJECT_NAME}_${alias}_IS_ALIAS_OF ${component} CACHE INTERNAL "")
  endforeach()
  append_Unique_In_Cache(${PROJECT_NAME}_ALIASES "${alias_list}")
endfunction(add_Alias_To_Cache)


#.rst:
#
# .. ifmode:: internal
#
#  .. |rename_If_Alias| replace:: ``rename_If_Alias``
#  .. _rename_If_Alias:
#
#  rename_If_Alias
#  ---------------
#
#   .. command:: rename_If_Alias(ALIAS_NAME package component)
#
#     Return the real name of the component from the given input name, this later can be the real name or an alias name.
#
#     :package: name of package containing the component.
#     :component: the name of the component or an alias.
#
#     :ALIAS_NAME: the output variable that contains the real name of the aliased component if component is an alias, FALSE otherwise.
#
function(rename_If_Alias ALIAS_NAME package component)
  list(FIND ${package}_ALIASES ${component} INDEX)
  if(INDEX EQUAL -1)#not found in aliases
    set(${ALIAS_NAME} ${component} PARENT_SCOPE)
  else()
    set(${ALIAS_NAME} ${${package}_${component}_IS_ALIAS_OF} PARENT_SCOPE)
  endif()
endfunction(rename_If_Alias)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Build_Info_Cached_Variables_From_Use| replace:: ``reset_Build_Info_Cached_Variables_From_Use``
#  .. _reset_Build_Info_Cached_Variables_From_Use:
#
#  reset_Build_Info_Cached_Variables_From_Use
#  ------------------------------------------
#
#   .. command:: reset_Build_Info_Cached_Variables_From_Use(package)
#
#   Reset cache internal variables related to the build environment coming from the use file of a package (native or external) used as a dependency in the current context.
#
#     :package: the name of the package dependency.
#     :mode: the current build mode.
#
function(reset_Build_Info_Cached_Variables_From_Use package mode)#common for external and native packages
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  #cleaning the memorized dependency cache variables
  #this is only usefull  avoid having BUGS in package build process after target platform ABI has been changed in workspace
  set(${package}_BUILT_FOR_DISTRIBUTION CACHE INTERNAL "")
  set(${package}_BUILT_FOR_DISTRIBUTION_VERSION CACHE INTERNAL "")
  set(${package}_BUILT_FOR_INSTANCE  CACHE INTERNAL "")
  set(${package}_BUILT_RELEASE_ONLY CACHE INTERNAL "")
  set(${package}_BUILT_OS_VARIANT CACHE INTERNAL "")#only for external but no side effects on natives

  foreach(lang IN LISTS ${package}_LANGUAGE_CONFIGURATIONS${VAR_SUFFIX})
    set(${package}_LANGUAGE_CONFIGURATION_${lang}_ARGS${VAR_SUFFIX} CACHE INTERNAL "")
  endforeach()
  set(${package}_LANGUAGE_CONFIGURATIONS${VAR_SUFFIX} CACHE INTERNAL "")
endfunction(reset_Build_Info_Cached_Variables_From_Use)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Native_Package_Dependency_Cached_Variables_From_Use| replace:: ``reset_Native_Package_Dependency_Cached_Variables_From_Use``
#  .. _reset_Native_Package_Dependency_Cached_Variables_From_Use:
#
#  reset_Native_Package_Dependency_Cached_Variables_From_Use
#  ---------------------------------------------------------
#
#   .. command:: reset_Native_Package_Dependency_Cached_Variables_From_Use(package mode recursive)
#
#   Reset all cache internal variables coming from the use file of a native package used as a dependency in the current context.
#
#     :package: the name of the native package dependency.
#     :mode: the build mode.
#     :recursive: if TRUE the varoables of package dependencies will also be reset, otherwise only variables local to the component will be reset.
#
function(reset_Native_Package_Dependency_Cached_Variables_From_Use package mode recursive)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  reset_Build_Info_Cached_Variables_From_Use(${package} ${mode})
  #cleaning everything

  set(${package}_PLATFORM${VAR_SUFFIX} CACHE INTERNAL "")

  foreach(config IN LISTS ${package}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX})
    set(${package}_PLATFORM_CONFIGURATION_${config}_ARGS${VAR_SUFFIX} CACHE INTERNAL "")
  endforeach()
  set(${package}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX} CACHE INTERNAL "")

  foreach(comp IN LISTS ${package}_COMPONENTS)
    reset_Component_Cached_Variables(${package} ${comp} ${mode})
  endforeach()
  foreach(alias IN LISTS ${package}_ALIASES)
    set(${package}_${alias}_IS_ALIAS_OF CACHE INTERNAL "")
  endforeach()
  set(${package}_COMPONENTS CACHE INTERNAL "")
  set(${package}_COMPONENTS_APPS CACHE INTERNAL "")
  set(${package}_COMPONENTS_LIBS CACHE INTERNAL "")
  set(${package}_COMPONENTS_SCRIPTS CACHE INTERNAL "")
  set(${package}_ALIASES CACHE INTERNAL "")

  foreach(ext_dep IN LISTS ${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
    set(${package}_EXTERNAL_DEPENDENCY_${ext_dep}_ALL_POSSIBLE_VERSIONS${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_EXTERNAL_DEPENDENCY_${ext_dep}_ALL_EXACT_VERSIONS${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_EXTERNAL_DEPENDENCY_${ext_dep}_VERSION${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_EXTERNAL_DEPENDENCY_${ext_dep}_VERSION_EXACT${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_EXTERNAL_DEPENDENCY_${ext_dep}_VERSION_SYSTEM${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_EXTERNAL_DEPENDENCY_${ext_dep}_COMPONENTS${VAR_SUFFIX}  CACHE INTERNAL "")
    if(recursive)
      reset_External_Package_Dependency_Cached_Variables_From_Use(${ext_dep} ${mode} TRUE)#recursion !!
    endif()
  endforeach()
  set(${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} CACHE INTERNAL "")

  foreach(nat_dep IN LISTS ${package}_DEPENDENCIES${VAR_SUFFIX})
    set(${package}_DEPENDENCY_${nat_dep}_ALL_POSSIBLE_VERSIONS${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_DEPENDENCY_${nat_dep}_ALL_EXACT_VERSIONS${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_DEPENDENCY_${nat_dep}_VERSION${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_DEPENDENCY_${nat_dep}_VERSION_EXACT${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_DEPENDENCY_${nat_dep}_COMPONENTS${VAR_SUFFIX} CACHE INTERNAL "")
    if(recursive)
      reset_Native_Package_Dependency_Cached_Variables_From_Use(${nat_dep} ${mode} TRUE)#recursion !!
    endif()
  endforeach()
  set(${package}_DEPENDENCIES${VAR_SUFFIX} CACHE INTERNAL "")
endfunction(reset_Native_Package_Dependency_Cached_Variables_From_Use)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_External_Package_Dependency_Cached_Variables_From_Use| replace:: ``reset_External_Package_Dependency_Cached_Variables_From_Use``
#  .. _reset_External_Package_Dependency_Cached_Variables_From_Use:
#
#  reset_External_Package_Dependency_Cached_Variables_From_Use
#  -----------------------------------------------------------
#
#   .. command:: reset_External_Package_Dependency_Cached_Variables_From_Use(package mode recursive)
#
#   Reset all cache internal variables coming from the use file of an external package used as a dependency in the current context.
#
#     :package: the name of the external package dependency.
#     :mode: the build mode.
#     :recursive: if TRUE the varoables of package dependencies will also be reset, otherwise only variables local to the component will be reset.
#
function(reset_External_Package_Dependency_Cached_Variables_From_Use package mode recursive)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  reset_Build_Info_Cached_Variables_From_Use(${package} ${mode})
  #cleaning
  set(${package}_PLATFORM${VAR_SUFFIX} CACHE INTERNAL "")
  foreach(config IN LISTS ${package}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX})
    set(${package}_PLATFORM_CONFIGURATION_${config}_ARGS${VAR_SUFFIX} CACHE INTERNAL "")
  endforeach()
  set(${package}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX} CACHE INTERNAL "")

  foreach(comp IN LISTS ${package}_COMPONENTS)
    #resetting variables of the component
    set(${package}_${comp}_INC_DIRS${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_${comp}_LIB_DIRS${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_${comp}_OPTS${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_${comp}_DEFS${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_${comp}_STATIC_LINKS${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_${comp}_FORCED_SHARED_LINKS${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_${comp}_SHARED_LINKS${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_${comp}_C_STANDARD${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_${comp}_CXX_STANDARD${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_${comp}_C_MAX_STANDARD${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_${comp}_CXX_MAX_STANDARD${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_${comp}_RUNTIME_RESOURCES${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_${comp}_INTERNAL_DEPENDENCIES${VAR_SUFFIX} CACHE INTERNAL "")
    foreach(dep_pack IN LISTS ${package}_${comp}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
      foreach(dep_comp IN LISTS ${package}_${comp}_EXTERNAL_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})
        set(${package}_${comp}_EXTERNAL_EXPORT_${dep_pack}_${dep_comp}${VAR_SUFFIX} CACHE INTERNAL "")
      endforeach()
      set(${package}_${comp}_EXTERNAL_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX} CACHE INTERNAL "")
    endforeach()
    set(${package}_${comp}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} CACHE INTERNAL "")
  endforeach()
  set(${package}_COMPONENTS CACHE INTERNAL "")

  foreach(alias IN LISTS ${package}_ALIASES${VAR_SUFFIX})
    set(${package}_${alias}_IS_ALIAS_OF${VAR_SUFFIX} CACHE INTERNAL "")
  endforeach()
  set(${package}_ALIASES${VAR_SUFFIX} CACHE INTERNAL "")

  foreach(ext_dep IN LISTS ${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
    set(${package}_EXTERNAL_DEPENDENCY_${ext_dep}_ALL_POSSIBLE_VERSIONS${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_EXTERNAL_DEPENDENCY_${ext_dep}_ALL_EXACT_VERSIONS${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_EXTERNAL_DEPENDENCY_${ext_dep}_VERSION${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_EXTERNAL_DEPENDENCY_${ext_dep}_VERSION_EXACT${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_EXTERNAL_DEPENDENCY_${ext_dep}_VERSION_SYSTEM${VAR_SUFFIX} CACHE INTERNAL "")
    set(${package}_EXTERNAL_DEPENDENCY_${ext_dep}_COMPONENTS${VAR_SUFFIX}  CACHE INTERNAL "")
    if(recursive)
      reset_External_Package_Dependency_Cached_Variables_From_Use(${ext_dep} ${mode} TRUE)#recursion !!
    endif()
  endforeach()
  set(${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} CACHE INTERNAL "")

endfunction(reset_External_Package_Dependency_Cached_Variables_From_Use)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Extra_Tool_Cache_Variables| replace:: ``reset_Extra_Tool_Cache_Variables``
#  .. _reset_Extra_Tool_Cache_Variables:
#
#  reset_Extra_Tool_Cache_Variables
#  ---------------------------------
#
#   .. command:: reset_Extra_Tool_Cache_Variables()
#
#   Resetting all internal cached variables defined by a package. Used to start reconfiguration from a clean situation.
#
function(reset_Extra_Tool_Cache_Variables)
  set(${PROJECT_NAME}_EXTRA_TOOLS_REQUIRED CACHE INTERNAL "")
endfunction(reset_Extra_Tool_Cache_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Required_Extra_Tools| replace:: ``add_Required_Extra_Tools``
#  .. _add_Required_Extra_Tools:
#
#  add_Required_Extra_Tools
#  ------------------------
#
#   .. command:: add_Required_Extra_Tools(tool)
#
#   Add into cache the information of required extra tool.
#
#     :environment: the name of required environment defining extra tools
#
function(add_Required_Extra_Tools environment)
  get_Extra_Tools_With_On_Demand_Plugins_For_Environment(ALL_EXTRA ${environment})
  foreach(extra IN LISTS ALL_EXTRA)
    append_Unique_In_Cache(${PROJECT_NAME}_EXTRA_TOOLS_REQUIRED ${extra})
  endforeach()
endfunction(add_Required_Extra_Tools)


#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Package_Description_Cached_Variables| replace:: ``reset_Package_Description_Cached_Variables``
#  .. _reset_Package_Description_Cached_Variables:
#
#  reset_Package_Description_Cached_Variables
#  ------------------------------------------
#
#   .. command:: reset_Package_Description_Cached_Variables()
#
#   Resetting all internal cached variables defined by a package. Used to start reconfiguration from a clean situation.
#
function(reset_Package_Description_Cached_Variables)
  reset_Extra_Tool_Cache_Variables()#reset info on plugins used
	# package dependencies declaration must be reinitialized otherwise some problem (uncoherent dependancy versions) would appear
	foreach(dep_package IN LISTS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
    reset_Version_Strings_Recursive(${dep_package})#reset resolved version
    set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_ALL_POSSIBLE_VERSIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
    set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_ALL_EXACT_VERSIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
		set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} CACHE INTERNAL "")
		set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} CACHE INTERNAL "")
		set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_${${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
    reset_Native_Package_Dependency_Cached_Variables_From_Use(${dep_package} ${CMAKE_BUILD_TYPE} TRUE)
  endforeach()
	set(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")

	# external package dependencies declaration must be reinitialized
	foreach(dep_package IN LISTS ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
    reset_Version_Strings_Recursive(${dep_package})#reset resolved version
    set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_ALL_POSSIBLE_VERSIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
    set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_ALL_EXACT_VERSIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
		set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} CACHE INTERNAL "")
		set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} CACHE INTERNAL "")
		set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
		set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION_SYSTEM${USE_MODE_SUFFIX} CACHE INTERNAL "")
    reset_External_Package_Dependency_Cached_Variables_From_Use(${dep_package} ${CMAKE_BUILD_TYPE} TRUE)
  endforeach()
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")

	# component declaration must be reinitialized otherwise some problem (redundancy of declarations) would appear
	foreach(a_component IN LISTS ${PROJECT_NAME}_COMPONENTS)
		reset_Component_Cached_Variables(${PROJECT_NAME} ${a_component} ${CMAKE_BUILD_TYPE})
	endforeach()

  foreach(alias IN LISTS ${PROJECT_NAME}_ALIASES)
    set(${PROJECT_NAME}_${alias}_IS_ALIAS_OF CACHE INTERNAL "")
  endforeach()
	reset_Declared()
  reset_Predeclared()
	set(${PROJECT_NAME}_COMPONENTS CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_LIBS CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_APPS CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_SCRIPTS CACHE INTERNAL "")
	set(${PROJECT_NAME}_ALIASES CACHE INTERNAL "")
endfunction(reset_Package_Description_Cached_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Dependency_Complete_Description| replace:: ``set_Dependency_Complete_Description``
#  .. _set_Dependency_Complete_Description:
#
#  set_Dependency_Complete_Description
#  -----------------------------------
#
#   .. command:: set_Dependency_Complete_Description(dep_package external possible_versions exact_versions)
#
#   setting internal cache variables used to memorize all possible versions for a given dependency (for documentation purpose only).
#
#     :dep_package: the name of the external package dependency.
#     :external: if TRUE dep_package is an external package, otherwise it is a native package.
#     :possible_versions: the name of the variable that contains the list of possible version for that dependency.
#     :possible_versions: the name of the variable that contains the list of exact versions among possible ones for that dependency.
#
function(set_Dependency_Complete_Description dep_package external possible_versions exact_versions)
if(external)
  if(possible_versions AND ${possible_versions})
    set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_ALL_POSSIBLE_VERSIONS${USE_MODE_SUFFIX} ${${possible_versions}} CACHE INTERNAL "")
    if(exact_versions AND ${exact_versions})
      set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_ALL_EXACT_VERSIONS${USE_MODE_SUFFIX} ${${exact_versions}} CACHE INTERNAL "")
    endif()
  endif()
else()#for native packages use another set of variables
  if(possible_versions AND ${possible_versions})
    set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_ALL_POSSIBLE_VERSIONS${USE_MODE_SUFFIX} ${${possible_versions}} CACHE INTERNAL "")
    if(exact_versions AND ${exact_versions})
      set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_ALL_EXACT_VERSIONS${USE_MODE_SUFFIX} ${${exact_versions}} CACHE INTERNAL "")
    endif()
  endif()
endif()
endfunction(set_Dependency_Complete_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Component_Description| replace:: ``init_Component_Description``
#  .. _init_Component_Description:
#
#  init_Component_Description
#  --------------------------
#
#   .. command:: init_Component_Description(component description usage)
#
#   Initialize cache internal variables related to the documentation of a given component.
#
#     :component: the name of the target component.
#     :description:  the long description of component utility.
#     :usage: the list of path to header files to include in order to use the component.
#
function(init_Component_Description component description usage)
generate_Formatted_String("${description}" RES_STRING)
set(${PROJECT_NAME}_${component}_DESCRIPTION "${RES_STRING}" CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_USAGE_INCLUDES "${usage}" CACHE INTERNAL "")
endfunction(init_Component_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |mark_As_Declared| replace:: ``mark_As_Declared``
#  .. _mark_As_Declared:
#
#  mark_As_Declared
#  ----------------
#
#   .. command:: mark_As_Declared(component)
#
#   Memorize that the component has been declare in current configuration process.
#
#     :component: the name of the target component.
#
function(mark_As_Declared component)
set(${PROJECT_NAME}_DECLARED_COMPS ${${PROJECT_NAME}_DECLARED_COMPS} ${component} CACHE INTERNAL "")
list(REMOVE_ITEM ${PROJECT_NAME}_PREDECLARED_COMPS ${component})
set(${PROJECT_NAME}_PREDECLARED_COMPS ${${PROJECT_NAME}_PREDECLARED_COMPS} CACHE INTERNAL "")
endfunction(mark_As_Declared)

#.rst:
#
# .. ifmode:: internal
#
#  .. |mark_As_Predeclared| replace:: ``mark_As_Predeclared``
#  .. _mark_As_Predeclared:
#
#  mark_As_Predeclared
#  -------------------
#
#   .. command:: mark_As_Predeclared(component)
#
#   Memorize that the component has been predeclared in current configuration process.
#
#     :component: the name of the target component.
#
function(mark_As_Predeclared component)
set(${PROJECT_NAME}_PREDECLARED_COMPS ${${PROJECT_NAME}_PREDECLARED_COMPS} ${component} CACHE INTERNAL "")
endfunction(mark_As_Predeclared)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Declared| replace:: ``is_Declared``
#  .. _is_Declared:
#
#  is_Declared
#  -----------
#
#   .. command:: is_Declared(component RESULT)
#
#   Check whether a component has been declared in current configuration process, or not.
#
#     :component: the name of the component or one of its aliases to check.
#
#     :RESULT: the output variable that contains the name of the component if component has been declared, FALSE otherwise.
#
function(is_Declared component RESULT)
list(FIND ${PROJECT_NAME}_DECLARED_COMPS ${component} INDEX)
if(INDEX EQUAL -1)
  list(FIND ${PROJECT_NAME}_ALIASES ${component} INDEX)
  if(INDEX EQUAL -1)
	   set(${RESULT} FALSE PARENT_SCOPE)
  else()#the given name is an alias
    set(${RESULT} ${${PROJECT_NAME}_${component}_IS_ALIAS_OF} PARENT_SCOPE)
  endif()
else()
	set(${RESULT} ${component} PARENT_SCOPE)
endif()
endfunction(is_Declared)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Predeclared| replace:: ``is_Predeclared``
#  .. _is_Predeclared:
#
#  is_Predeclared
#  --------------
#
#   .. command:: is_Predeclared(component RESULT)
#
#   Check whether a component has been predeclared in current configuration process, or not.
#
#     :component: the name of the component or one of its aliases to check.
#
#     :RESULT: the output variable that contains the name of the component if component has been predeclared, FALSE otherwise.
#
function(is_Predeclared component RESULT)
list(FIND ${PROJECT_NAME}_PREDECLARED_COMPS ${component} INDEX)
if(INDEX EQUAL -1)
  set(${RESULT} FALSE PARENT_SCOPE)
else()
	set(${RESULT} ${component} PARENT_SCOPE)
endif()
endfunction(is_Predeclared)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Declared| replace:: ``reset_Declared``
#  .. _reset_Declared:
#
#  reset_Declared
#  --------------
#
#   .. command:: reset_Declared()
#
#   Reset all declared component in currenlty defined package.
#
function(reset_Declared)
set(${PROJECT_NAME}_DECLARED_COMPS CACHE INTERNAL "")
endfunction(reset_Declared)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Predeclared| replace:: ``reset_Predeclared``
#  .. _reset_Predeclared:
#
#  reset_Predeclared
#  -----------------
#
#   .. command:: reset_Predeclared()
#
#   Reset all declared component in currenlty defined package.
#
function(reset_Predeclared)
set(${PROJECT_NAME}_PREDECLARED_COMPS CACHE INTERNAL "")
endfunction(reset_Predeclared)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Internal_Only| replace:: ``set_Internal_Only``
#  .. _set_Internal_Only:
#
#  set_Internal_Only
#  -----------------
#
#   .. command:: set_Internal_Only()
#
#   Set properties of library related to its internal use.
#
#     :component: the name of the library.
#     :is_internal: TRUE if library is for internal use only, FALSE otherwise.
#     :for_examples: TRUE if library is for code example purpose, FALSE otherwise.
#     :for_tests: TRUE if library is for test purpose, FALSE otherwise.
#
function(set_Internal_Only component is_internal for_examples for_tests)
  set(${PROJECT_NAME}_${component}_INTERNAL_ONLY ${is_internal} CACHE INTERNAL "")
  if(is_internal)
    set(${PROJECT_NAME}_${component}_FOR_EXAMPLES ${for_examples} CACHE INTERNAL "")
    set(${PROJECT_NAME}_${component}_FOR_TESTS ${for_tests} CACHE INTERNAL "")
  else()
    set(${PROJECT_NAME}_${component}_FOR_EXAMPLES FALSE CACHE INTERNAL "")
    set(${PROJECT_NAME}_${component}_FOR_TESTS FALSE CACHE INTERNAL "")
  endif()
endfunction(set_Internal_Only)



#.rst:
#
# .. ifmode:: internal
#
#  .. |export_External_Component| replace:: ``export_External_Component``
#  .. _export_External_Component:
#
#  export_External_Component
#  -------------------------
#
#   .. command:: export_External_Component(IS_EXPORTING package component dep_package dep_component mode)
#
#   Check whether a native or external component exports another external component.
#
#     :package: the name of the package containing the exporting component.
#     :component: the name of the exporting component.
#     :dep_package: the name of the package containing the exported component.
#     :dep_component: the name of the exported component.
#     :mode: the build mode to consider (Debug or Release)
#
#     :IS_EXPORTING: the output variable that is TRUE if component export dep_component, FALSE otherwise. It is UNSET if either variable used for declaring export is unset
#
function(export_External_Component IS_EXPORTING package component dep_package dep_component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

if(package STREQUAL "${dep_package}")# both components belong to same external package
  if(NOT DEFINED ${package}_${component}_INTERNAL_EXPORT_${dep_component}${VAR_SUFFIX})
    unset(${IS_EXPORTING} PARENT_SCOPE)#Note: required to manage aliases (if variable not defined means either component or dep_component is not a valid name)
  elseif(${package}_${component}_INTERNAL_EXPORT_${dep_component}${VAR_SUFFIX})
		set(${IS_EXPORTING} TRUE PARENT_SCOPE)
	else()
		set(${IS_EXPORTING} FALSE PARENT_SCOPE)
	endif()
else()
  if(NOT DEFINED ${package}_${component}_EXTERNAL_EXPORT_${dep_package}_${dep_component}${VAR_SUFFIX})
    unset(${IS_EXPORTING} PARENT_SCOPE)#Note: required to manage aliases (if variable not defined means either component or dep_component is not a valid name)
  elseif(${package}_${component}_EXTERNAL_EXPORT_${dep_package}_${dep_component}${VAR_SUFFIX})
		set(${IS_EXPORTING} TRUE PARENT_SCOPE)
	else()
		set(${IS_EXPORTING} FALSE PARENT_SCOPE)
	endif()
endif()
endfunction(export_External_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |export_External_Component_Resolving_Alias| replace:: ``export_External_Component_Resolving_Alias``
#  .. _export_External_Component_Resolving_Alias:
#
#  export_External_Component_Resolving_Alias
#  -----------------------------------------
#
#   .. command:: export_External_Component_Resolving_Alias(IS_EXPORTING package component component_alias dep_package dep_component dep_component_alias mode)
#
#   Check whether an external component exports another external component. This function returns exact result wether components names are base names or aliases.
#
#     :package: the name of the package containing the exporting component.
#     :component: the name of the exporting component.
#     :component_alias: the alias of the exporting component or base name if no alias used.
#     :dep_package: the name of the package containing the exported component.
#     :dep_component: the name of the exported component.
#     :dep_component_alias: the alias of the exported component or base name if no alias used.
#     :mode: the build mode to consider (Debug or Release)
#
#     :IS_EXPORTING: the output variable that is TRUE if component export dep_component, FALSE otherwise.
#
function(export_External_Component_Resolving_Alias IS_EXPORTING package component component_alias dep_package dep_component dep_component_alias mode)
set(${IS_EXPORTING} FALSE PARENT_SCOPE)
export_External_Component(FIRST_TRIAL_EXPORTING ${package} ${component} ${dep_package} ${dep_component} ${mode})#using base name to verify export
if(DEFINED FIRST_TRIAL_EXPORTING)#as soon as variable is defined it means we used the good name for component AND dependency, so result is meaningful
  if(FIRST_TRIAL_EXPORTING)
    set(${IS_EXPORTING} TRUE PARENT_SCOPE)
  endif()
  return()
endif()
if(NOT component STREQUAL component_alias)#we can check with alias name for the component
  export_External_Component(SECOND_TRIAL_EXPORTING ${package} ${component_alias} ${dep_package} ${dep_component} ${mode})#using base name to verify export
  if(DEFINED SECOND_TRIAL_EXPORTING)#as soon as variable is defined it means we used the good name for component AND dependency, so result is meaningful
    if(SECOND_TRIAL_EXPORTING)
      set(${IS_EXPORTING} TRUE PARENT_SCOPE)
    endif()
    return()
  endif()
endif()
if(NOT dep_component STREQUAL dep_component_alias)#we can check with alias name for the component
  export_External_Component(THIRD_TRIAL_EXPORTING ${package} ${component} ${dep_package} ${dep_component_alias} ${mode})#using base name to verify export
  if(DEFINED THIRD_TRIAL_EXPORTING)#as soon as variable is defined it means we used the good name for component AND dependency, so result is meaningful
    if(THIRD_TRIAL_EXPORTING)
      set(${IS_EXPORTING} TRUE PARENT_SCOPE)
    endif()
    return()
  endif()
endif()
if((NOT component STREQUAL component_alias) AND (NOT dep_component STREQUAL dep_component_alias))
  export_External_Component(LAST_TRIAL_EXPORTING ${package} ${component_alias} ${dep_package} ${dep_component_alias} ${mode})#using base name to verify export
  if(DEFINED LAST_TRIAL_EXPORTING)#as soon as variable is defined it means we used the good name for component AND dependency, so result is meaningful
    if(LAST_TRIAL_EXPORTING)
      set(${IS_EXPORTING} TRUE PARENT_SCOPE)
    endif()
    return()
  endif()
endif()
endfunction(export_External_Component_Resolving_Alias)


#.rst:
#
# .. ifmode:: internal
#
#  .. |export_Component| replace:: ``export_Component``
#  .. _export_Component:
#
#  export_Component
#  ----------------
#
#   .. command:: export_Component(IS_EXPORTING package component dep_package dep_component mode)
#
#   Check whether a component exports another component.
#
#     :package: the name of the package containing the exporting component.
#     :component: the name of the exporting component.
#     :dep_package: the name of the package containing the exported component.
#     :dep_component: the name of the exported component.
#     :mode: the build mode to consider (Debug or Release)
#
#     :IS_EXPORTING: the output variable that is TRUE if component export dep_component, FALSE otherwise. It is UNSET if either variable used for declaring export is not defined.
#
function(export_Component IS_EXPORTING package component dep_package dep_component mode)
is_HeaderFree_Component(IS_HF ${package} ${component})
if(NOT DEFINED IS_HF)
  unset(${IS_EXPORTING} PARENT_SCOPE)
  return()
elseif(IS_HF)
	set(${IS_EXPORTING} FALSE PARENT_SCOPE)
	return()
endif()
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

if(package STREQUAL "${dep_package}")
  if(NOT DEFINED ${package}_${component}_INTERNAL_EXPORT_${dep_component}${VAR_SUFFIX})
    unset(${IS_EXPORTING} PARENT_SCOPE)
  elseif(${package}_${component}_INTERNAL_EXPORT_${dep_component}${VAR_SUFFIX})
		set(${IS_EXPORTING} TRUE PARENT_SCOPE)
	else()
		set(${IS_EXPORTING} FALSE PARENT_SCOPE)
	endif()
else()
  if(NOT DEFINED ${package}_${component}_EXPORT_${dep_package}_${dep_component}${VAR_SUFFIX})
    unset(${IS_EXPORTING} PARENT_SCOPE)
  elseif(${package}_${component}_EXPORT_${dep_package}_${dep_component}${VAR_SUFFIX})
		set(${IS_EXPORTING} TRUE PARENT_SCOPE)
	else()
		set(${IS_EXPORTING} FALSE PARENT_SCOPE)
	endif()
endif()
endfunction(export_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |export_Component_Resolving_Alias| replace:: ``export_Component_Resolving_Alias``
#  .. _export_Component_Resolving_Alias:
#
#  export_Component_Resolving_Alias
#  --------------------------------
#
#   .. command:: export_Component_Resolving_Alias(IS_EXPORTING package component component_alias dep_package dep_component dep_component_alias mode)
#
#   Check whether a component exports another component. This function returns exact result wether components names are base names or aliases.
#
#     :package: the name of the package containing the exporting component.
#     :component: the name of the exporting component.
#     :component_alias: the alias of the exporting component or base name if no alias used.
#     :dep_package: the name of the package containing the exported component.
#     :dep_component: the name of the exported component.
#     :dep_component_alias: the alias of the exported component or base name if no alias used.
#     :mode: the build mode to consider (Debug or Release)
#
#     :IS_EXPORTING: the output variable that is TRUE if component export dep_component, FALSE otherwise.
#
function(export_Component_Resolving_Alias IS_EXPORTING package component component_alias dep_package dep_component dep_component_alias mode)
set(${IS_EXPORTING} FALSE PARENT_SCOPE)
export_Component(FIRST_TRIAL_EXPORTING ${package} ${component} ${dep_package} ${dep_component} ${mode})#using base name to verify export
if(DEFINED FIRST_TRIAL_EXPORTING)#as soon as variable is defined it means we used the good name for component AND dependency, so result is meaningful
  if(FIRST_TRIAL_EXPORTING)
    set(${IS_EXPORTING} TRUE PARENT_SCOPE)
  endif()
  return()
endif()
if(NOT component STREQUAL component_alias)#we can check with alias name for the component
  export_Component(SECOND_TRIAL_EXPORTING ${package} ${component_alias} ${dep_package} ${dep_component} ${mode})#using base name to verify export
  if(DEFINED SECOND_TRIAL_EXPORTING)#as soon as variable is defined it means we used the good name for component AND dependency, so result is meaningful
    if(SECOND_TRIAL_EXPORTING)
      set(${IS_EXPORTING} TRUE PARENT_SCOPE)
    endif()
    return()
  endif()
endif()
if(NOT dep_component STREQUAL dep_component_alias)#we can check with alias name for the component
  export_Component(THIRD_TRIAL_EXPORTING ${package} ${component} ${dep_package} ${dep_component_alias} ${mode})#using base name to verify export
  if(DEFINED THIRD_TRIAL_EXPORTING)#as soon as variable is defined it means we used the good name for component AND dependency, so result is meaningful
    if(THIRD_TRIAL_EXPORTING)
      set(${IS_EXPORTING} TRUE PARENT_SCOPE)
    endif()
    return()
  endif()
endif()
if((NOT component STREQUAL component_alias) AND (NOT dep_component STREQUAL dep_component_alias))
  export_Component(LAST_TRIAL_EXPORTING ${package} ${component_alias} ${dep_package} ${dep_component_alias} ${mode})#using base name to verify export
  if(DEFINED LAST_TRIAL_EXPORTING)#as soon as variable is defined it means we used the good name for component AND dependency, so result is meaningful
    if(LAST_TRIAL_EXPORTING)
      set(${IS_EXPORTING} TRUE PARENT_SCOPE)
    endif()
    return()
  endif()
endif()
endfunction(export_Component_Resolving_Alias)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_HeaderFree_Component| replace:: ``is_HeaderFree_Component``
#  .. _is_HeaderFree_Component:
#
#  is_HeaderFree_Component
#  -----------------------
#
#   .. command:: is_HeaderFree_Component(RESULT package component)
#
#   Check whether a component has a public interface (i.e. a set of public headers).
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component has NO public interface, FALSE otherwise.
#
function(is_HeaderFree_Component RESULT package component)
if(NOT DEFINED ${package}_${component}_TYPE)
  unset(${RESULT} PARENT_SCOPE)#Note : useful to manage cases where we do not know if component is base or alias name (can be considered as false anyway in this situation)
elseif (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	OR ${package}_${component}_TYPE STREQUAL "MODULE"
	OR ${package}_${component}_TYPE STREQUAL "PYTHON"
	)
	set(${RESULT} TRUE PARENT_SCOPE)
else()
	set(${RESULT} FALSE PARENT_SCOPE)
endif()
endfunction(is_HeaderFree_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Runtime_Component| replace:: ``is_Runtime_Component``
#  .. _is_Runtime_Component:
#
#  is_Runtime_Component
#  --------------------
#
#   .. command:: is_Runtime_Component(RESULT package component)
#
#   Check whether a component exists at runtime or not.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component exists at runtime, FALSE otherwise.
#
function(is_Runtime_Component RESULT package component)
  set(${RESULT} FALSE PARENT_SCOPE)
  get_Package_Type(${package} PACK_TYPE)
  if(PACK_TYPE STREQUAL "EXTERNAL")
    if( ${package}_${component}_SHARED_LINKS${VAR_SUFFIX}
        OR ${package}_${component}_FORCED_SHARED_LINKS${VAR_SUFFIX}
        OR ${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX}
        OR ${package}_${component}_PYTHON_PACKAGES${VAR_SUFFIX})
        set(${RESULT} TRUE PARENT_SCOPE)
    endif()
  else()#native package
    if (	${package}_${component}_TYPE STREQUAL "APP"
    	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
    	OR ${package}_${component}_TYPE STREQUAL "TEST"
    	OR ${package}_${component}_TYPE STREQUAL "SHARED"
    	OR ${package}_${component}_TYPE STREQUAL "MODULE"
    	)
    	set(${RESULT} TRUE PARENT_SCOPE)
    endif()
  endif()
endfunction(is_Runtime_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Executable_Component| replace:: ``is_Executable_Component``
#  .. _is_Executable_Component:
#
#  is_Executable_Component
#  -----------------------
#
#   .. command:: is_Executable_Component(RESULT package component)
#
#   Check whether a component is an executable.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component is an executable, FALSE otherwise.
#
function(is_Executable_Component RESULT package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	)
	set(${RESULT} TRUE PARENT_SCOPE)
else()
	set(${RESULT} FALSE PARENT_SCOPE)
endif()
endfunction(is_Executable_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Built_Component| replace:: ``is_Built_Component``
#  .. _is_Built_Component:
#
#  is_Built_Component
#  ------------------
#
#   .. command:: is_Built_Component(RESULT package component)
#
#   Check whether a component is built by the build process or simply installed (e.g. header only libraries and python scripts are not built).
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component is built, FALSE otherwise.
#
function (is_Built_Component RESULT package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	OR ${package}_${component}_TYPE STREQUAL "STATIC"
	OR ${package}_${component}_TYPE STREQUAL "SHARED"
	OR ${package}_${component}_TYPE STREQUAL "MODULE"
)
	set(${RESULT} TRUE PARENT_SCOPE)
else()
	set(${RESULT} FALSE PARENT_SCOPE)#scripts and headers libraries are not built
endif()
endfunction(is_Built_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |will_be_Built| replace:: ``will_be_Built``
#  .. _will_be_Built:
#
#  will_be_Built
#  -------------
#
#   .. command:: will_be_Built(RESULT component)
#
#   Check whether a component of the currently defined package  will built depending on cache variables chosen by the user.
#
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component will be built by current build process, FALSE otherwise.
#
function(will_be_Built RESULT component)
if((${PROJECT_NAME}_${component}_TYPE STREQUAL "PYTHON") #python scripts are never built
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST" AND NOT BUILD_AND_RUN_TESTS)
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE" AND (NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${component})))
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
else()
	if(${PROJECT_NAME}_${component}_TYPE STREQUAL "MODULE")### to know wehether a module is a python wrapped module and is really compilable
		contains_Python_Code(HAS_WRAPPER ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_${component}_SOURCE_DIR})
		if(HAS_WRAPPER AND NOT CURRENT_PYTHON)#wthe module will not be built as there is no python configuration
			set(${RESULT} FALSE PARENT_SCOPE)
			return()
		endif()
	endif()
	set(${RESULT} TRUE PARENT_SCOPE)
endif()
endfunction(will_be_Built)

#.rst:
#
# .. ifmode:: internal
#
#  .. |will_be_Installed| replace:: ``will_be_Installed``
#  .. _will_be_Installed:
#
#  will_be_Installed
#  -----------------
#
#   .. command:: will_be_Installed(RESULT component)
#
#   Check whether a component of the currently defined package will installed depending on cache variables chosen by the user and component nature.
#
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component will be installed by current build process, FALSE otherwise.
#
function(will_be_Installed RESULT component)
if( (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE" AND (NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${component})))
	set(${RESULT} FALSE PARENT_SCOPE)
elseif(${PROJECT_NAME}_${component}_INTERNAL_ONLY)#internal libraries are never installed
  if(${PROJECT_NAME}_${component}_FOR_EXAMPLES AND BUILD_EXAMPLES)#except if they are used for examples and examples are built
    set(${RESULT} TRUE PARENT_SCOPE)
    return()
  endif()
  set(${RESULT} FALSE PARENT_SCOPE)
else()
	if(${PROJECT_NAME}_${component}_TYPE STREQUAL "MODULE")### to know wehether a module is a python wrapped module and is really compilable
		contains_Python_Code(HAS_WRAPPER ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_${component}_SOURCE_DIR})
		if(HAS_WRAPPER AND NOT CURRENT_PYTHON)#the module will not be installed as there is no python configuration
			set(${RESULT} FALSE PARENT_SCOPE)
			return()
		endif()
	endif()
	set(${RESULT} TRUE PARENT_SCOPE)
endif()
endfunction(will_be_Installed)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Externally_Usable| replace:: ``is_Externally_Usable``
#  .. _is_Externally_Usable:
#
#  is_Externally_Usable
#  --------------------
#
#   .. command:: is_Externally_Usable(RESULT component)
#
#   Check whether a component of the currently defined package is, by nature, usable by another package (not a test or example).
#
#     :component: the name of the component.
#
#     :RESULT: the output variable that is TRUE if component can be used by another package, FALSE otherwise.
#
function(is_Externally_Usable RESULT component)
if( (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE"))
	set(${RESULT} FALSE PARENT_SCOPE)
else()
	set(${RESULT} TRUE PARENT_SCOPE)
endif()
endfunction(is_Externally_Usable)

#.rst:
#
# .. ifmode:: internal
#
#  .. |build_Option_For_Example| replace:: ``build_Option_For_Example``
#  .. _build_Option_For_Example:
#
#  build_Option_For_Example
#  ------------------------
#
#   .. command:: build_Option_For_Example(example_comp)
#
#   Create a cache option to active/deactivate the build of an example.
#
#     :example_comp: the name of the example component.
#
function(build_Option_For_Example example_comp)
CMAKE_DEPENDENT_OPTION(BUILD_EXAMPLE_${example_comp} "Package build the example application ${example_comp}" ON "BUILD_EXAMPLES" ON)
endfunction(build_Option_For_Example)


#.rst:
#
# .. ifmode:: internal
#
#  .. |project_Has_Tests_Or_Examples| replace:: ``project_Has_Tests_Or_Examples``
#  .. project_Has_Tests_Or_Examples:
#
#  project_Has_Tests_Or_Examples
#  ------------------------
#
#   .. command:: project_Has_Tests_Or_Examples(HAS_TESTS HAS_EXAMPLES)
#
#   Tells whether the project contain tests or examples
#
#     :HAS_TESTS: ouput var TRUE if project has tests
#     :HAS_TESTS: ouput var TRUE if project has examples
#
function(project_Has_Tests_Or_Examples HAS_TESTS HAS_EXAMPLES)
  set(PACKAGE_HAS_EXAMPLES FALSE)
  set(PACKAGE_HAS_TESTS FALSE)
  foreach(component IN LISTS ${PROJECT_NAME}_DECLARED_COMPS)#looking into all declared components
    if(${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE")
      set(PACKAGE_HAS_EXAMPLES TRUE)
    elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
      set(PACKAGE_HAS_TESTS TRUE)
    endif()
  endforeach()
  set(${HAS_TESTS} ${PACKAGE_HAS_TESTS} PARENT_SCOPE)
  set(${HAS_EXAMPLES} ${PACKAGE_HAS_EXAMPLES} PARENT_SCOPE)
endfunction(project_Has_Tests_Or_Examples)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Removed_Examples_Build_Option| replace:: ``reset_Removed_Examples_Build_Option``
#  .. _reset_Removed_Examples_Build_Option:
#
#  reset_Removed_Examples_Build_Option
#  -----------------------------------
#
#   .. command:: reset_Removed_Examples_Build_Option()
#
#   Remove all cache variables related to examples in currently defined package.
#
function(reset_Removed_Examples_Build_Option)
get_cmake_property(ALL_CACHED_VARIABLES CACHE_VARIABLES) #getting all cache variables
foreach(a_cache_var ${ALL_CACHED_VARIABLES})
	string(REGEX REPLACE "^BUILD_EXAMPLE_(.*)$" "\\1" EXAMPLE_NAME ${a_cache_var})

	if(NOT EXAMPLE_NAME STREQUAL "${a_cache_var}")#match => this is an option related to an example !!
		set(DECLARED FALSE)
		is_Declared(${EXAMPLE_NAME} DECLARED)
		if(NOT DECLARED)# corresponding example component has not been declared
			unset(${a_cache_var} CACHE)#remove option from cache
		endif()
	endif()
endforeach()
endfunction(reset_Removed_Examples_Build_Option)

#.rst:
#
# .. ifmode:: internal
#
#  .. |register_Component_Binary| replace:: ``register_Component_Binary``
#  .. _register_Component_Binary:
#
#  register_Component_Binary
#  -------------------------
#
#   .. command:: register_Component_Binary(component)
#
#   Memorize in cache the generated binary name of a component. Warning: the binary name uses Cmake generator expressions.
#
#     :component: the name of the component.
#
function(register_Component_Binary component)
	set(${PROJECT_NAME}_${component}_BINARY_NAME${USE_MODE_SUFFIX} "$<TARGET_FILE_NAME:${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX}>" CACHE INTERNAL "")
endfunction(register_Component_Binary)

#.rst:
#
# .. ifmode:: internal
#
#  .. |register_Runtime_Component_Binary| replace:: ``register_Runtime_Component_Binary``
#  .. _register_Runtime_Component_Binary:
#
#  register_Runtime_Component_Binary
#  ---------------------------------
#
#   .. command:: register_Runtime_Component_Binary(component type)
#
#   Memorize in cache the generated binary name of a component. 
#
#     :component: the name of the component.
#     :type: the type of the component.
#
function(register_Runtime_Component_Binary component type)
  get_Platform_Related_Binary_Prefix_Suffix(PREFIX SUFFIX ${type})
  set(${PROJECT_NAME}_${component}_LOCAL_BINARY_NAME${USE_MODE_SUFFIX} "${PREFIX}${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX}${SUFFIX}" CACHE INTERNAL "")
endfunction(register_Runtime_Component_Binary)



#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Component_Exporting_Other_Components| replace:: ``is_Component_Exporting_Other_Components``
#  .. _is_Bin_Component_Exporting_Other_Components:
#
#  is_Component_Exporting_Other_Components
#  ---------------------------------------
#
#   .. command:: is_Component_Exporting_Other_Components(RESULT package component mode)
#
#   Check whether a component exports other components.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode considered (Release or Debug).
#
#     :RESULT: the output variable that is TRUE if the component export other components, FALSE otherwise.
#
function(is_Component_Exporting_Other_Components RESULT package component mode)
set(${RESULT} FALSE PARENT_SCOPE)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

#scanning external dependencies
if(${package}_${component}_LINKS${VAR_SUFFIX}
    OR ${package}_${component}_SYSTEM_STATIC_LINKS${VAR_SUFFIX}) #only exported links here
	set(${RESULT} TRUE PARENT_SCOPE)
	return()
endif()

# scanning external dependencies
foreach(dep_pack IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
	foreach(ext_dep IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})
		if(${package}_${component}_EXTERNAL_EXPORT_${dep_pack}_${ext_dep}${VAR_SUFFIX})
			set(${RESULT} TRUE PARENT_SCOPE)
			return()
		endif()
	endforeach()
endforeach()

# scanning internal dependencies
foreach(int_dep IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
	if(${package}_${component}_INTERNAL_EXPORT_${int_dep}${VAR_SUFFIX})
		set(${RESULT} TRUE PARENT_SCOPE)
		return()
	endif()
endforeach()

# scanning package dependencies
foreach(dep_pack IN LISTS ${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
	foreach(ext_dep IN LISTS ${package}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})
		if(${package}_${component}_EXPORT_${dep_pack}_${ext_dep}${VAR_SUFFIX})
			set(${RESULT} TRUE PARENT_SCOPE)
			return()
		endif()
	endforeach()
endforeach()
endfunction(is_Component_Exporting_Other_Components)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Packages_Containing_Component| replace:: ``find_Packages_Containing_Component``
#  .. _find_Packages_Containing_Component:
#
#  find_Packages_Containing_Component
#  ----------------------------------
#
#   .. command:: find_Packages_Containing_Component(CONTAINER_PACKAGES package component)
#
#   Find the list of packages that define a given component.
#
#     :package: the name of the package from where starting the search.
#     :component: the name of the component.
#
#     :CONTAINER_PACKAGES: the output variable that contains the list of packages that define a component with same name.
#
function(find_Packages_Containing_Component CONTAINER_PACKAGES package component)
set(result)
#searching into component of the current package
list(FIND ${package}_COMPONENTS ${component} INDEX)
if(NOT INDEX EQUAL -1)#the same component name has been found
  list(APPEND result ${package})
endif()
#now find in aliases names
list(FIND ${package}_ALIASES ${component} INDEX)
if(NOT INDEX EQUAL -1)#the same component name has been found
  list(APPEND result ${package})
endif()
#searching into direct external dependencies
foreach(ext_dep IN LISTS ${package}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
  find_Packages_Containing_Component(CONTAINER ${ext_dep} ${component})
  if(CONTAINER)
    list(APPEND result ${CONTAINER})
  endif()
endforeach()
if(NOT is_external)
  #searching into direct native dependencies
  set(CONTAINER)
  foreach(nat_dep IN LISTS ${package}_DEPENDENCIES${USE_MODE_SUFFIX})
    find_Packages_Containing_Component(CONTAINER ${nat_dep} ${component})
    if(CONTAINER)
      list(APPEND result ${CONTAINER})
    endif()
  endforeach()
endif()
if(result)
  list(REMOVE_DUPLICATES result)
endif()
set(${CONTAINER_PACKAGES} ${result} PARENT_SCOPE)
endfunction(find_Packages_Containing_Component)

##################################################################################
############################## install the dependancies ##########################
########### functions used to create the use<package><version>.cmake  ############
##################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_In_Binary_Configuration_Dependency_In_Use_File| replace:: ``write_In_Binary_Configuration_Dependency_In_Use_File``
#  .. -write_In_Binary_Configuration_Dependency_In_Use_File:
#
#  write_In_Binary_Configuration_Dependency_In_Use_File
#  ----------------------------------------------------
#
#   .. command:: write_In_Binary_Configuration_Dependency_In_Use_File(file package mode_suffix config configs_already_written)
#
#   Write in the use file the variable containing arguments used for a dependent configuration check.
#
#     :file: the path to file to write in.
#     :package: the name of the package.
#     :mode_suffix: the suffix to use dependencing on mode
#     :config: the name of configuration that may have dependencies
#     :configs_already_written: the IN OUT variable containing the list of configurations already written in use file
#
function(write_In_Binary_Configuration_Dependency_In_Use_File file package mode_suffix config configs_already_written)
  if(${config}_CONFIGURATION_DEPENDENCIES_IN_BINARY)
    set(temp_list_of_config_written ${${configs_already_written}})
    foreach(dep_conf IN LISTS ${config}_CONFIGURATION_DEPENDENCIES_IN_BINARY)
      list(FIND temp_list_of_config_written ${dep_conf} INDEX)
      if(INDEX EQUAL -1)#not already written !!
        list(APPEND temp_list_of_config_written ${dep_conf})
        if(${dep_conf}_CONSTRAINTS_IN_BINARY)
          file(APPEND ${file} "set(${package}_PLATFORM_CONFIGURATION_${dep_conf}_ARGS${mode_suffix} ${${dep_conf}_CONSTRAINTS_IN_BINARY} CACHE INTERNAL \"\")\n")
        endif()
        write_In_Binary_Configuration_Dependency_In_Use_File(${file} ${package} "${mode_suffix}" ${dep_conf} temp_list_of_config_written)
      endif()
    endforeach()
    set(${configs_already_written} ${temp_list_of_config_written} PARENT_SCOPE)
  endif()
endfunction(write_In_Binary_Configuration_Dependency_In_Use_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Use_File| replace:: ``write_Use_File``
#  .. _write_Use_File:
#
#  write_Use_File
#  --------------
#
#   .. command:: write_Use_File(file package build_mode)
#
#   Write the use file of a package for the given build mode.
#
#     :file: the path to file to write in.
#     :package: the name of the package.
#     :build_mode: the build mode considered (Release or Debug).
#
function(write_Use_File file package build_mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${build_mode})
#need to resolve components that will really lie in the resulting install tree
set(list_of_comps)
set(list_of_apps)
set(list_of_libs)
foreach(comp IN LISTS ${package}_COMPONENTS)
  will_be_Installed(INSTALLED ${comp})
  if(INSTALLED)
    list(APPEND list_of_comps ${comp})
    if(${package}_${comp}_TYPE STREQUAL "APP" OR ${package}_${comp}_TYPE STREQUAL "EXAMPLE")
      list(APPEND list_of_apps ${comp})
    else()
      list(APPEND list_of_libs ${comp})
    endif()
  endif()
endforeach()
#also need to resolve their alias, if any
set(list_of_aliases)
foreach(alias IN LISTS ${package}_ALIASES)
  list(FIND list_of_comps ${${package}_${alias}_IS_ALIAS_OF} INDEX)
  if(NOT INDEX EQUAL -1)#alias matches a component that will be installed
    list(APPEND list_of_aliases ${alias})
  endif()
endforeach()

if(${build_mode} MATCHES Release) #mode independent info written only once in the release mode
	file(APPEND ${file} "######### declaration of package meta info that can be usefull for other packages ########\n")
	file(APPEND ${file} "set(${package}_LICENSE ${${package}_LICENSE} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_ADDRESS ${${package}_ADDRESS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_PUBLIC_ADDRESS ${${package}_PUBLIC_ADDRESS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_CATEGORIES ${${package}_CATEGORIES} CACHE INTERNAL \"\")\n")

	file(APPEND ${file} "######### declaration of package web site info ########\n")
	file(APPEND ${file} "set(${package}_FRAMEWORK ${${package}_FRAMEWORK} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_PROJECT_PAGE ${${package}_PROJECT_PAGE} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_SITE_ROOT_PAGE ${${package}_SITE_ROOT_PAGE} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_SITE_GIT_ADDRESS ${${package}_SITE_GIT_ADDRESS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_SITE_INTRODUCTION \"${${package}_SITE_INTRODUCTION}\" CACHE INTERNAL \"\")\n")

	file(APPEND ${file} "######### declaration of package development info ########\n")
	get_Repository_Current_Branch(RES_BRANCH ${WORKSPACE_DIR}/packages/${package})
	if(NOT RES_BRANCH OR RES_BRANCH STREQUAL "master")#not on a development branch
		file(APPEND ${file} "set(${package}_DEVELOPMENT_STATE release CACHE INTERNAL \"\")\n")
	else()
		file(APPEND ${file} "set(${package}_DEVELOPMENT_STATE development CACHE INTERNAL \"\")\n")
	endif()

  file(APPEND ${file} "set(${package}_BUILT_FOR_DISTRIBUTION ${CURRENT_DISTRIBUTION} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${package}_BUILT_FOR_DISTRIBUTION_VERSION ${CURRENT_DISTRIBUTION_VERSION} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${package}_BUILT_FOR_INSTANCE ${CURRENT_PLATFORM_INSTANCE} CACHE INTERNAL \"\")\n")
  # Note: used to tell if the installed package contains debug binaries
  if(BUILD_RELEASE_ONLY)
    file(APPEND ${file} "set(${package}_BUILT_RELEASE_ONLY TRUE CACHE INTERNAL \"\")\n")
  else()
    file(APPEND ${file} "set(${package}_BUILT_RELEASE_ONLY FALSE CACHE INTERNAL \"\")\n")
  endif()
 

	file(APPEND ${file} "######### declaration of package components ########\n")
	file(APPEND ${file} "set(${package}_COMPONENTS ${list_of_comps} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_COMPONENTS_APPS ${list_of_apps} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_COMPONENTS_LIBS ${list_of_libs} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_COMPONENTS_SCRIPTS ${${package}_COMPONENTS_SCRIPTS} CACHE INTERNAL \"\")\n")
  file(APPEND ${file} "set(${package}_ALIASES ${list_of_aliases} CACHE INTERNAL \"\")\n")

	file(APPEND ${file} "####### internal specs of package components #######\n")
	foreach(a_component IN LISTS list_of_libs)
		file(APPEND ${file} "set(${package}_${a_component}_TYPE ${${package}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
		if(NOT ${package}_${a_component}_TYPE STREQUAL "MODULE")#modules do not have public interfaces
			file(APPEND ${file} "set(${package}_${a_component}_HEADER_DIR_NAME ${${package}_${a_component}_HEADER_DIR_NAME} CACHE INTERNAL \"\")\n")
			file(APPEND ${file} "set(${package}_${a_component}_HEADERS ${${package}_${a_component}_HEADERS} CACHE INTERNAL \"\")\n")
    elseif(${package}_${a_component}_HAS_PYTHON_WRAPPER)
      file(APPEND ${file} "set(${package}_${a_component}_HAS_PYTHON_WRAPPER TRUE CACHE INTERNAL \"\")\n")
    endif()
	endforeach()
	foreach(a_component IN LISTS list_of_apps)
		file(APPEND ${file} "set(${package}_${a_component}_TYPE ${${package}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
	endforeach()
	foreach(a_component IN LISTS ${package}_COMPONENTS_SCRIPTS)
		file(APPEND ${file} "set(${package}_${a_component}_TYPE ${${package}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
	endforeach()
  foreach(an_alias IN LISTS list_of_aliases)
    file(APPEND ${file} "set(${package}_${an_alias}_IS_ALIAS_OF ${${package}_${an_alias}_IS_ALIAS_OF} CACHE INTERNAL \"\")\n")
  endforeach()
endif()

get_Platform_Variables(BASENAME curr_platform_name)
#mode dependent info written adequately depending on the mode
# 0) platforms configuration constraints

file(APPEND ${file} "#### declaration of language requirements in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(lang IN LISTS ${package}_LANGUAGE_CONFIGURATIONS${VAR_SUFFIX})
  if(${package}_LANGUAGE_CONFIGURATION_${lang}_ARGS${VAR_SUFFIX})
    file(APPEND ${file} "set(${package}_LANGUAGE_CONFIGURATION_${lang}_ARGS${VAR_SUFFIX} ${${package}_LANGUAGE_CONFIGURATION_${lang}_ARGS${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
  endif()
endforeach()
file(APPEND ${file} "set(${package}_LANGUAGE_CONFIGURATIONS${VAR_SUFFIX} ${${package}_LANGUAGE_CONFIGURATIONS${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")

file(APPEND ${file} "#### declaration of platform dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(${package}_PLATFORM${VAR_SUFFIX} ${curr_platform_name} CACHE INTERNAL \"\")\n") # not really usefull since a use file is bound to a given platform, but may be usefull for debug

set(memorized_configs)

foreach(config IN LISTS ${package}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX})
  list(APPEND memorized_configs ${config})
  if(${package}_PLATFORM_CONFIGURATION_${config}_ARGS${VAR_SUFFIX})
    file(APPEND ${file} "set(${package}_PLATFORM_CONFIGURATION_${config}_ARGS${VAR_SUFFIX} ${${package}_PLATFORM_CONFIGURATION_${config}_ARGS${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
  endif()
  write_In_Binary_Configuration_Dependency_In_Use_File(${file} ${package} "${VAR_SUFFIX}" ${config} memorized_configs)
endforeach()
file(APPEND ${file} "set(${package}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX} ${memorized_configs} CACHE INTERNAL \"\")\n")

#Use file generation process needs to integrate undirect required package dependencies that becomes direct due to transitivity in components
#NB: this is mandatory to resolve conflicting dependencies versions in binary packages
collect_Local_Exported_Dependencies(NATIVE_DEPS EXTERNAL_DEPS ${package} ${build_mode})
#NB: each dep in these variable has the form: name,version,exact,system (see below for information extraction)
# 1) external package dependencies
if(EXTERNAL_DEPS)
  file(APPEND ${file} "#### declaration of external package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")

  foreach(a_ext_dep IN LISTS EXTERNAL_DEPS)
    string(REPLACE "," ";" dep_spec ${a_ext_dep})
    list(GET dep_spec 0 DEP_NAME)
    list(GET dep_spec 1 DEP_VERSION)
    list(GET dep_spec 2 DEP_EXACT)
    list(GET dep_spec 3 DEP_SYSTEM)
    list(APPEND USED_DEPS ${DEP_NAME})#getting the list of all direct or undirect dependencies

    file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${DEP_NAME}_VERSION${VAR_SUFFIX} ${DEP_VERSION} CACHE INTERNAL \"\")\n")
    file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${DEP_NAME}_VERSION_EXACT${VAR_SUFFIX} ${DEP_EXACT} CACHE INTERNAL \"\")\n")
    file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${DEP_NAME}_VERSION_SYSTEM${VAR_SUFFIX} ${DEP_SYSTEM} CACHE INTERNAL \"\")\n")
    #component are only defined for direct dependencies, if any defined for such a dependency
    file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${DEP_NAME}_COMPONENTS${VAR_SUFFIX} ${${package}_EXTERNAL_DEPENDENCY_${DEP_NAME}_COMPONENTS${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
  endforeach()

  file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} ${USED_DEPS} CACHE INTERNAL \"\")\n")
endif()

# 2) native package dependencies
if(NATIVE_DEPS)
  set(USED_DEPS)#reset to avoid troubles
  file(APPEND ${file} "#### declaration of native package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
  #getting the list of all direct or undirect dependencies
  foreach(a_nat_dep IN LISTS NATIVE_DEPS)
    string(REPLACE "," ";" dep_spec ${a_nat_dep})
    list(GET dep_spec 0 DEP_NAME)
    list(GET dep_spec 1 DEP_VERSION)
    list(GET dep_spec 2 DEP_EXACT)
    list(GET dep_spec 3 DEP_SYSTEM)
    list(APPEND USED_DEPS ${DEP_NAME})

  	file(APPEND ${file} "set(${package}_DEPENDENCY_${DEP_NAME}_VERSION${VAR_SUFFIX} ${DEP_VERSION} CACHE INTERNAL \"\")\n")
    file(APPEND ${file} "set(${package}_DEPENDENCY_${DEP_NAME}_VERSION_EXACT${VAR_SUFFIX} ${DEP_EXACT} CACHE INTERNAL \"\")\n")
    #component are only defined for direct dependencies, if any defined for such a dependency
  	file(APPEND ${file} "set(${package}_DEPENDENCY_${DEP_NAME}_COMPONENTS${VAR_SUFFIX} ${${package}_DEPENDENCY_${DEP_NAME}_COMPONENTS${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
  endforeach()

  file(APPEND ${file} "set(${package}_DEPENDENCIES${VAR_SUFFIX} ${USED_DEPS} CACHE INTERNAL \"\")\n")
endif()

# 3) internal+external components specifications
file(APPEND ${file} "#### declaration of components exported flags and binary in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN LISTS list_of_comps)
	is_Built_Component(IS_BUILT_COMP ${package} ${a_component})#nNote: o need to manage aliases since variable contains only base name of components in current project (by construction)
	is_HeaderFree_Component(IS_HF_COMP ${package} ${a_component})#Note: no need to manage aliases since variable contains only base name of components in current project (by construction)
	if(IS_BUILT_COMP)#if not a pure header library
		file(APPEND ${file} "set(${package}_${a_component}_BINARY_NAME${VAR_SUFFIX} ${${package}_${a_component}_BINARY_NAME${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
	endif()
	if(NOT IS_HF_COMP)#it is a library but not a module library
		file(APPEND ${file} "set(${package}_${a_component}_INC_DIRS${VAR_SUFFIX} ${${package}_${a_component}_INC_DIRS${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
    file(APPEND ${file} "set(${package}_${a_component}_LIB_DIRS${VAR_SUFFIX} ${${package}_${a_component}_LIB_DIRS${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_OPTS${VAR_SUFFIX} \"${${package}_${a_component}_OPTS${VAR_SUFFIX}}\" CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_DEFS${VAR_SUFFIX} \"${${package}_${a_component}_DEFS${VAR_SUFFIX}}\" CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_LINKS${VAR_SUFFIX} ${${package}_${a_component}_LINKS${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_PRIVATE_LINKS${VAR_SUFFIX} ${${package}_${a_component}_PRIVATE_LINKS${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
    file(APPEND ${file} "set(${package}_${a_component}_SYSTEM_STATIC_LINKS${VAR_SUFFIX} ${${package}_${a_component}_SYSTEM_STATIC_LINKS${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_C_STANDARD${VAR_SUFFIX} ${${package}_${a_component}_C_STANDARD${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_CXX_STANDARD${VAR_SUFFIX} ${${package}_${a_component}_CXX_STANDARD${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
    file(APPEND ${file} "set(${package}_${a_component}_C_MAX_STANDARD${VAR_SUFFIX} ${${package}_${a_component}_C_MAX_STANDARD${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_CXX_MAX_STANDARD${VAR_SUFFIX} ${${package}_${a_component}_CXX_MAX_STANDARD${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
	endif()
	file(APPEND ${file} "set(${package}_${a_component}_RUNTIME_RESOURCES${VAR_SUFFIX} ${${package}_${a_component}_RUNTIME_RESOURCES${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")

  #component are only defined for direct dependencies, if any defined for such a dependency
  file(APPEND ${file} "set(${package}_${a_component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} ${${package}_${a_component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
  foreach(dep_ext_pack IN LISTS ${package}_${a_component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
    file(APPEND ${file} "set(${package}_${a_component}_EXTERNAL_DEPENDENCY_${dep_ext_pack}_COMPONENTS${VAR_SUFFIX} ${${package}_${a_component}_EXTERNAL_DEPENDENCY_${dep_ext_pack}_COMPONENTS${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
    foreach(dep_component IN LISTS ${package}_${a_component}_EXTERNAL_DEPENDENCY_${dep_ext_pack}_COMPONENTS${VAR_SUFFIX})
      if(${package}_${a_component}_EXTERNAL_EXPORT_${dep_ext_pack}_${dep_component})
        file(APPEND ${file} "set(${package}_${a_component}_EXTERNAL_EXPORT_${dep_ext_pack}_${dep_component}${VAR_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
      else()
        file(APPEND ${file} "set(${package}_${a_component}_EXTERNAL_EXPORT_${dep_ext_pack}_${dep_component}${VAR_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
      endif()
    endforeach()
  endforeach()
endforeach()

# 4) package internal component dependencies
file(APPEND ${file} "#### declaration package internal component dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN LISTS list_of_comps)
	if(${package}_${a_component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX}) # the component has internal dependencies
		file(APPEND ${file} "set(${package}_${a_component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX} ${${package}_${a_component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
		foreach(a_int_dep IN LISTS ${package}_${a_component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
			if(${package}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${VAR_SUFFIX})
				file(APPEND ${file} "set(${package}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${VAR_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
			else()
				file(APPEND ${file} "set(${package}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${VAR_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
			endif()
		endforeach()
	endif()
endforeach()

# 5) component dependencies
file(APPEND ${file} "#### declaration of component dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN LISTS list_of_comps)
	if(${package}_${a_component}_DEPENDENCIES${VAR_SUFFIX}) # the component has package dependencies
		file(APPEND ${file} "set(${package}_${a_component}_DEPENDENCIES${VAR_SUFFIX} ${${package}_${a_component}_DEPENDENCIES${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
		foreach(dep_package IN LISTS ${package}_${a_component}_DEPENDENCIES${VAR_SUFFIX})
			file(APPEND ${file} "set(${package}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX} ${${package}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX}} CACHE INTERNAL \"\")\n")
			foreach(dep_component IN LISTS ${package}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
				if(${package}_${a_component}_EXPORT_${dep_package}_${dep_component})
					file(APPEND ${file} "set(${package}_${a_component}_EXPORT_${dep_package}_${dep_component}${VAR_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
				else()
					file(APPEND ${file} "set(${package}_${a_component}_EXPORT_${dep_package}_${dep_component}${VAR_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
				endif()
			endforeach()
		endforeach()
	endif()
endforeach()
endfunction(write_Use_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Use_File| replace:: ``create_Use_File``
#  .. _create_Use_File:
#
#  create_Use_File
#  ---------------
#
#   .. command:: create_Use_File()
#
#   Create the use file for the currenlt defined package.
#
function(create_Use_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode
	set(file ${CMAKE_BINARY_DIR}/share/UseReleaseTemp)
else()
	set(file ${CMAKE_BINARY_DIR}/share/UseDebugTemp)
endif()

#resetting the file content
file(WRITE ${file} "")
write_Use_File(${file} ${PROJECT_NAME} ${CMAKE_BUILD_TYPE})

#finalizing release mode by agregating info from the debug mode
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode
	if(EXISTS ${CMAKE_BINARY_DIR}/../debug/share/UseDebugGen) #checking that the debug generated file exists
		file(READ ${CMAKE_BINARY_DIR}/../debug/share/UseDebugGen DEBUG_CONTENT)
		file(APPEND ${file} "${DEBUG_CONTENT}")
	endif()
	#removing debug files
	file(REMOVE ${CMAKE_BINARY_DIR}/../debug/share/UseDebugTemp)
	#generating use file, using file(GENERATE) is required to generate info containing generator expression
	file(GENERATE OUTPUT ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake
        INPUT ${file})
else() #this step is required to generate info containing generator expression
	file(GENERATE OUTPUT ${CMAKE_BINARY_DIR}/share/UseDebugGen
        INPUT ${file})
endif()
endfunction(create_Use_File)

###############################################################################################
############################## providing info on the package content ##########################
###############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Info_File| replace:: ``generate_Info_File``
#  .. _generate_Info_File:
#
#  generate_Info_File
#  ------------------
#
#   .. command:: generate_Info_File()
#
#   Create the info file (Info<package>.cmake) for the currenlty defined package. This info file is used at build time to know whether the content of the package has changed.
#
function(generate_Info_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode
	set(file ${CMAKE_BINARY_DIR}/../share/Info${PROJECT_NAME}.cmake)
	file(WRITE ${file} "")#resetting the file content
	file(APPEND ${file} "######### declaration of package components ########\n")
	file(APPEND ${file} "set(${PROJECT_NAME}_COMPONENTS ${${PROJECT_NAME}_COMPONENTS} CACHE INTERNAL \"\")\n")
	foreach(a_component IN LISTS ${PROJECT_NAME}_COMPONENTS)
		file(APPEND ${file} "######### content of package component ${a_component} ########\n")
		file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_TYPE ${${PROJECT_NAME}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
		if(${PROJECT_NAME}_${a_component}_SOURCE_DIR)
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_SOURCE_DIR ${${PROJECT_NAME}_${a_component}_SOURCE_DIR} CACHE INTERNAL \"\")\n")
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_SOURCE_CODE ${${PROJECT_NAME}_${a_component}_SOURCE_CODE} CACHE INTERNAL \"\")\n")
      file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_AUX_SOURCE_CODE ${${PROJECT_NAME}_${a_component}_AUX_SOURCE_CODE} CACHE INTERNAL \"\")\n")
      file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_AUX_MONITORED_PATH ${${PROJECT_NAME}_${a_component}_AUX_MONITORED_PATH} CACHE INTERNAL \"\")\n")
    endif()
		if(${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME)
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME ${${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME} CACHE INTERNAL \"\")\n")
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADERS ${${PROJECT_NAME}_${a_component}_HEADERS} CACHE INTERNAL \"\")\n")
      file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADERS_ADDITIONAL_FILTERS ${${PROJECT_NAME}_${a_component}_HEADERS_ADDITIONAL_FILTERS} CACHE INTERNAL \"\")\n")
    endif()
	endforeach()
endif()
endfunction(generate_Info_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Find_File| replace:: ``generate_Package_Find_File``
#  .. _generate_Package_Find_File:
#
#  generate_Package_Find_File
#  --------------------------
#
#   .. command:: generate_Package_Find_File()
#
#   Create and install the find file (Find<package>.cmake) for the currenlty defined package.
#
function(generate_Package_Find_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	# generating/installing the generic cmake find file for the package
  get_Repository_Version_Tags(VERSION_NUMBERS ${PROJECT_NAME})#getting standard version number depending on value of tags
  #filtering versions, keep only major.minor.max_patch
  set(selected_versions)
  foreach(a_version IN LISTS VERSION_NUMBERS)
    if(selected_versions)
      get_Version_String_Numbers(${a_version} MAJOR MINOR PATCH)
      set(to_compare ${MAJOR}.${MINOR})
      set(to_remove)
      set(to_add TRUE)
      #find a same major.minor version with a lower patch number
      foreach(selected IN LISTS selected_versions)
        get_Version_String_Numbers(${selected} SEL_MAJOR SEL_MINOR SEL_PATCH)
        if(to_compare VERSION_EQUAL "${SEL_MAJOR}.${SEL_MINOR}")
          if(a_version VERSION_GREATER selected)
            set(to_remove ${selected})
          else()
            set(to_add FALSE)
          endif()
          break()
        endif()
      endforeach()
      if(to_remove)
        list(REMOVE_ITEM selected_versions ${to_remove})
      endif()
      if(to_add)
        list(APPEND selected_versions ${a_version})
      endif()
    else()
      list(APPEND selected_versions ${a_version})
    endif()
  endforeach()
  set(FIND_FILE_KNOWN_VERSIONS ${selected_versions})#only write release versions
	configure_file(${WORKSPACE_DIR}/cmake/patterns/packages/FindPackage.cmake.in ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake @ONLY)
  get_Path_To_All_Deployment_Unit_References_Publishing_Contribution_Spaces(ALL_PUBLISHING_CS ${PROJECT_NAME} "")
  foreach(cs_path IN LISTS ALL_PUBLISHING_CS)
    install(FILES ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake DESTINATION ${cs_path}/finds) #install in the adequate contribution space
  endforeach()
endif()
endfunction(generate_Package_Find_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Use_File| replace:: ``generate_Use_File``
#  .. _generate_Use_File:
#
#  generate_Use_File
#  -----------------
#
#   .. command:: generate_Use_File()
#
#   Create and install the use file (Use<package>-<version>.cmake) for the currenlty defined package.
#
macro(generate_Use_File)
create_Use_File()
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	install(	FILES ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake
			DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH}
	)
endif()
endmacro(generate_Use_File)

############################################################################################
############ function used to create the Dep<package>.cmake file of the package  ###########
############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |current_Native_Dependencies_For_Package| replace:: ``current_Native_Dependencies_For_Package``
#  .. _current_Native_Dependencies_For_Package:
#
#  current_Native_Dependencies_For_Package
#  ---------------------------------------
#
#   .. command:: current_Native_Dependencies_For_Package(package depfile packages_already_managed PACKAGES_NEWLY_MANAGED)
#
#   Write the description of native dependencies of a given package in the dependencies description file.
#
#     :package: the name of the package.
#     :file: the path to file to write in.
#     :packages_already_managed: the list of packages already managed in the process of writing dependency file.
#
#     :PACKAGES_NEWLY_MANAGED: the output variable containing the list of package newly managed after this call.
#
function(current_Native_Dependencies_For_Package package depfile packages_already_managed PACKAGES_NEWLY_MANAGED)
get_Mode_Variables(TARGET_SUFFIX MODE_SUFFIX ${CMAKE_BUILD_TYPE})
#information on package to register
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_VERSION${MODE_SUFFIX} ${${package}_VERSION_STRING} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_ALL_VERSION${MODE_SUFFIX} ${${package}_ALL_REQUIRED_VERSIONS} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_DEPENDENCIES${MODE_SUFFIX} ${${package}_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

#registering platform configuration info coming from the dependency
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX} ${${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
foreach(config IN LISTS ${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX})
  if(${package}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX})#there are arguments to pass to that constraint
    file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX} ${${package}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
  endif()
endforeach()
#call on external dependencies
set(ALREADY_MANAGED ${packages_already_managed} ${package})
set(NEWLY_MANAGED ${package})

foreach(a_used_package IN LISTS ${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX})
	list(FIND ALREADY_MANAGED ${a_used_package} INDEX)
	if(INDEX EQUAL -1) #not managed yet
		current_External_Dependencies_For_Package(${a_used_package} ${depfile} "${ALREADY_MANAGED}" NEW_LIST)
		list(APPEND ALREADY_MANAGED ${NEW_LIST})
		list(APPEND NEWLY_MANAGED ${NEW_LIST})
	endif()
endforeach()

#recursion on native dependencies
foreach(a_used_package IN LISTS ${package}_DEPENDENCIES${MODE_SUFFIX})
	list(FIND ALREADY_MANAGED ${a_used_package} INDEX)
	if(INDEX EQUAL -1) #not managed yet
		current_Native_Dependencies_For_Package(${a_used_package} ${depfile} "${ALREADY_MANAGED}" NEW_LIST)
		list(APPEND ALREADY_MANAGED ${NEW_LIST})
		list(APPEND NEWLY_MANAGED ${NEW_LIST})
	endif()
endforeach()

set(${PACKAGES_NEWLY_MANAGED} ${NEWLY_MANAGED} PARENT_SCOPE)
endfunction(current_Native_Dependencies_For_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |current_External_Dependencies_For_Package| replace:: ``current_External_Dependencies_For_Package``
#  .. _current_External_Dependencies_For_Package:
#
#  current_External_Dependencies_For_Package
#  -----------------------------------------
#
#   .. command:: current_External_Dependencies_For_Package(package depfile PACKAGES_NEWLY_MANAGED)
#
#   Write the description of external dependencies of a given package in the dependencies description file.
#
#     :package: the name of the package.
#     :file: the path to file to write in.
#     :packages_already_managed: the list of packages already managed in the process of writing dependency file.
#
#     :PACKAGES_NEWLY_MANAGED: the output variable containing the list of external package newly managed after this call.
#
function(current_External_Dependencies_For_Package package depfile packages_already_managed PACKAGES_NEWLY_MANAGED)
get_Mode_Variables(TARGET_SUFFIX MODE_SUFFIX ${CMAKE_BUILD_TYPE})
#information on package to register
file(APPEND ${depfile} "set(CURRENT_EXTERNAL_DEPENDENCY_${package}_VERSION${MODE_SUFFIX} ${${package}_VERSION_STRING} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_EXTERNAL_DEPENDENCY_${package}_VERSION_EXACT${MODE_SUFFIX} ${${package}_REQUIRED_VERSION_EXACT} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_EXTERNAL_DEPENDENCY_${package}_VERSION_SYSTEM${MODE_SUFFIX} ${${package}_REQUIRED_VERSION_SYSTEM} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_EXTERNAL_DEPENDENCY_${package}_ALL_VERSION${MODE_SUFFIX} ${${package}_ALL_REQUIRED_VERSIONS} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_EXTERNAL_DEPENDENCY_${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

# platform configuration info for external libraries
file(APPEND ${depfile} "set(CURRENT_EXTERNAL_DEPENDENCY_${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX} ${${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
foreach(config IN LISTS ${package}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX})
  if(${package}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX})#there are arguments to pass to that constraint
    file(APPEND ${depfile} "set(CURRENT_EXTERNAL_DEPENDENCY_${package}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX} ${${package}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
  endif()
endforeach()

set(ALREADY_MANAGED ${packages_already_managed} ${package})
set(NEWLY_MANAGED ${package})

foreach(a_used_package IN LISTS ${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX})
	list(FIND ALREADY_MANAGED ${a_used_package} INDEX)
	if(INDEX EQUAL -1) #not managed yet
		current_External_Dependencies_For_Package(${a_used_package} ${depfile} "${ALREADY_MANAGED}" NEW_LIST)
		list(APPEND ALREADY_MANAGED ${NEW_LIST})
		list(APPEND NEWLY_MANAGED ${NEW_LIST})
	endif()
endforeach()

set(${PACKAGES_NEWLY_MANAGED} ${NEWLY_MANAGED} PARENT_SCOPE)
endfunction(current_External_Dependencies_For_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Dependencies_File| replace:: ``generate_Dependencies_File``
#  .. _generate_Dependencies_File:
#
#  generate_Dependencies_File
#  --------------------------
#
#   .. command:: generate_Dependencies_File()
#
#   Create the dependencies description file (Dep<package>.cmake) for the currenlty defined package. This file is used to track modifications of packages used.
#
macro(generate_Dependencies_File)
get_Platform_Variables(BASENAME curr_platform_name)
get_Mode_Variables(TARGET_SUFFIX MODE_SUFFIX ${CMAKE_BUILD_TYPE})
set(file ${CMAKE_BINARY_DIR}/share/Dep${PROJECT_NAME}.cmake)
file(WRITE ${file} "")
############# FIRST PART : statically declared dependencies ################

# 1) platforms
file(APPEND ${file} "set(TARGET_PLATFORM ${curr_platform_name} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(TARGET_PLATFORM_TYPE ${CURRENT_PLATFORM_TYPE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(TARGET_PLATFORM_ARCH ${CURRENT_PLATFORM_ARCH} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(TARGET_PLATFORM_OS ${CURRENT_PLATFORM_OS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(TARGET_PLATFORM_ABI ${CURRENT_PLATFORM_ABI} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(TARGET_PLATFORM_CONFIGURATIONS${MODE_SUFFIX} ${${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
foreach(config IN LISTS ${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${MODE_SUFFIX})
  if(${PROJECT_NAME}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX})
    file(APPEND ${file} "set(TARGET_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX} ${${PROJECT_NAME}_PLATFORM_CONFIGURATION_${config}_ARGS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
  endif()
endforeach()
# 2) external packages
file(APPEND ${file} "#### declaration of external package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

if(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX})
	foreach(a_ext_dep IN LISTS ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX})
		file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION${MODE_SUFFIX} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
    if(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_SYSTEM${MODE_SUFFIX})
      file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_SYSTEM${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
      file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
    else()
      if(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX})
        file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
      else()
        file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
      endif()
    endif()
	endforeach()
endif()

# 3) native package dependencies
file(APPEND ${file} "#### declaration of package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(TARGET_NATIVE_DEPENDENCIES${MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_DEPENDENCIES${MODE_SUFFIX})
	foreach(a_dep IN LISTS ${PROJECT_NAME}_DEPENDENCIES${MODE_SUFFIX})
		file(APPEND ${file} "set(TARGET_NATIVE_DEPENDENCY_${a_dep}_VERSION${MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCY_${a_dep}_VERSION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		if(${PROJECT_NAME}_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX})
			file(APPEND ${file} "set(TARGET_NATIVE_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
		else()
			file(APPEND ${file} "set(TARGET_NATIVE_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
		endif()
	endforeach()
endif()


set(NEWLY_MANAGED)
set(ALREADY_MANAGED)
############# SECOND PART : dynamically found dependencies according to current workspace content ################

#external dependencies
file(APPEND ${file} "set(CURRENT_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES)
	foreach(a_used_package IN LISTS ${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES)
		current_External_Dependencies_For_Package(${a_used_package} ${file} "${ALREADY_MANAGED}" NEWLY_MANAGED)
		list(APPEND ALREADY_MANAGED ${NEWLY_MANAGED})
	endforeach()
endif()

#native dependencies

file(APPEND ${file} "set(CURRENT_NATIVE_DEPENDENCIES${MODE_SUFFIX} ${${PROJECT_NAME}_ALL_USED_PACKAGES} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_ALL_USED_PACKAGES)
	foreach(a_used_package IN LISTS ${PROJECT_NAME}_ALL_USED_PACKAGES)
		list(FIND ALREADY_MANAGED ${a_used_package} INDEX)
		if(INDEX EQUAL -1) #not managed yet
			current_Native_Dependencies_For_Package(${a_used_package} ${file} "${ALREADY_MANAGED}" NEWLY_MANAGED)
			list(APPEND ALREADY_MANAGED ${NEWLY_MANAGED})
		endif()
	endforeach()
endif()

endmacro(generate_Dependencies_File)


#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Loggable_File| replace:: ``generate_Loggable_File``
#  .. _generate_Loggable_File:
#
#  generate_Loggable_File
#  -----------------------
#
#   .. command:: generate_Loggable_File()
#
#   Generate the header file used by the logging system to identify components generating logs.
#
#     :component: the name of the component.
#     :target_folder: the path to target_folder to write in.
#     :in_include: if true target_folder targets a public include dir, oitherwise it targets a source dir.
#
#     :GENERATED_FILE: the output variable containing the path to the generated header file.
#     :PREPROC_VAR_NAME: the output variable containing the name of the preprocessor variable used to guard the use of a given loggable component.
#
function(generate_Loggable_File GENERATED_FILE PREPROC_VAR_NAME component target_folder in_include)
  set(FRAMEWORK_NAME ${${PROJECT_NAME}_FRAMEWORK})
  set(COMPONENT_NAME ${component})

	string(REPLACE "-" "_" PREPROC_GUARD_PACKAGE_NAME ${PROJECT_NAME})
	string(REPLACE "-" "_" PREPROC_GUARD_NAME ${component})#to avoid problem with preprocessor tokens extraction
  set(PREPROC_GUARD_NAME "LOG_${PREPROC_GUARD_PACKAGE_NAME}_${PREPROC_GUARD_NAME}")
  set(gen_file "${target_folder}/pid/log/${PROJECT_NAME}_${component}.h")
  configure_file("${WORKSPACE_DIR}/cmake/patterns/packages/loggable.h.in" ${gen_file} @ONLY)
  set(${GENERATED_FILE} ${gen_file} PARENT_SCOPE)
  set(${PREPROC_VAR_NAME} ${PREPROC_GUARD_NAME} PARENT_SCOPE)
endfunction(generate_Loggable_File)


#############################################################################################
############### management of temporary variables used to optimize the build process ########
#############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Temporary_Optimization_Variables| replace:: ``reset_Temporary_Optimization_Variables``
#  .. _reset_Temporary_Optimization_Variables:
#
#  reset_Temporary_Optimization_Variables
#  --------------------------------------
#
#   .. command:: reset_Temporary_Optimization_Variables()
#
#   Clean the cache from temporary variables used to optimize the configuration process
#
#     :mode: the current buid mode.
#
function(reset_Temporary_Optimization_Variables mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  foreach(comp IN LISTS TEMP_VARS${VAR_SUFFIX})
  	unset(TEMP_${comp}_LOCAL_RUNTIME_LINKS${VAR_SUFFIX} CACHE)
  	unset(TEMP_${comp}_USING_RUNTIME_LINKS${VAR_SUFFIX} CACHE)
  	unset(TEMP_${comp}_RUNTIME_RESOURCES${VAR_SUFFIX} CACHE)
  	unset(TEMP_${comp}_SOURCE_RUNTIME_RESOURCES${VAR_SUFFIX} CACHE)
    unset(TEMP_${comp}_MANAGED_RUNTIME${VAR_SUFFIX} CACHE)
  endforeach()
  unset(TEMP_VARS CACHE)
  foreach(config IN LISTS TEMP_CONFIGS${VAR_SUFFIX})
    list(LENGTH TEMP_CONFIG_${config}_CHECKS${VAR_SUFFIX} SIZE)
    math(EXPR total_range "${SIZE}-1")
    foreach(check RANGE ${total_range})
      unset(TEMP_CONFIG_${config}_CHECK_${check}${VAR_SUFFIX} CACHE)
      unset(TEMP_CONFIG_${config}_CALL_CONSTRAINTS_${check}${VAR_SUFFIX} CACHE)
      unset(TEMP_CONFIG_${config}_BINARY_CONSTRAINTS_${check}${VAR_SUFFIX} CACHE)
    endforeach()
  	unset(TEMP_CONFIG_${config}_CHECKS${VAR_SUFFIX} CACHE)
  endforeach()
  unset(TEMP_CONFIGS${VAR_SUFFIX} CACHE)
endfunction(reset_Temporary_Optimization_Variables)



#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Configuration_Temporary_Optimization_Variables| replace:: ``set_Configuration_Temporary_Optimization_Variables``
#  .. _set_Configuration_Temporary_Optimization_Variables:
#
#  set_Configuration_Temporary_Optimization_Variables
#  --------------------------------------------------
#
#   .. command:: set_Configuration_Temporary_Optimization_Variables(config mode test_ok call_constraints binary_constraints)
#
#   set optimization variables used to check configurations
#
#     :config: the name of the configuration.
#     :mode: the current buid mode.
#     :test_ok: set to TRUE or FALSE the result of the check.
#     :call_constraints: the list of call constraints to memorize.
#     :binary_constraints: the list of binary constraints to memorize.
#
function(set_Configuration_Temporary_Optimization_Variables config mode test_ok call_constraints binary_constraints)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  if(NOT DEFINED TEMP_CONFIG_${config}_CHECKS${VAR_SUFFIX})
    set(next_index 0)
  else()
    list(LENGTH TEMP_CONFIG_${config}_CHECKS${VAR_SUFFIX} next_index)
  endif()
  set(TEMP_CONFIG_${config}_CHECK_${next_index}${VAR_SUFFIX} ${test_ok} CACHE INTERNAL "")
  set(TEMP_CONFIG_${config}_CALL_CONSTRAINTS_${next_index}${VAR_SUFFIX} ${call_constraints} CACHE INTERNAL "")
  set(TEMP_CONFIG_${config}_BINARY_CONSTRAINTS_${next_index}${VAR_SUFFIX} ${binary_constraints} CACHE INTERNAL "")
  math(EXPR new_size "${next_index}+1")
  set(TEMP_CONFIG_${config}_CHECKS${VAR_SUFFIX} ${new_size} CACHE INTERNAL "")
  append_Unique_In_Cache(TEMP_CONFIGS${VAR_SUFFIX} ${config})
endfunction(set_Configuration_Temporary_Optimization_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Configuration_Temporary_Optimization_Variables| replace:: ``check_Configuration_Temporary_Optimization_Variables``
#  .. _check_Configuration_Temporary_Optimization_Variables:
#
#  check_Configuration_Temporary_Optimization_Variables
#  ----------------------------------------------------
#
#   .. command:: check_Configuration_Temporary_Optimization_Variables(RES_CHECK_MADE config mode)
#
#   check whether a configuration has already been checked.
#
#     :config: the name of the configuration that is being checked.
#     :config_args_var: the input variable containing the list of arguments to check.
#     :mode: the current buid mode.
#
#     :RES_CHECK_MADE: the output variable that is TRUE if equivalent check has already been made, false otherwise.
#     :RES_CHECK: the output variable that contains the result of the previous check.
#     :RES_CONSTRAINTS: the output variable that contains the constraints of the previous check.
#
function(check_Configuration_Temporary_Optimization_Variables RES_CHECK_MADE RES_CHECK RES_CONSTRAINTS config config_args_var mode)
  set(${RES_CHECK_MADE} FALSE PARENT_SCOPE)
  set(${RES_CHECK} PARENT_SCOPE)
  set(${RES_CONSTRAINTS} PARENT_SCOPE)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  if(DEFINED TEMP_CONFIG_${config}_CHECKS${VAR_SUFFIX})
    math(EXPR total "${TEMP_CONFIG_${config}_CHECKS${VAR_SUFFIX}}-1")
    foreach(iter RANGE ${total})
      compare_Current_Configuration_Check_Args_With_Previous(INCLUDED ${config_args_var} TEMP_CONFIG_${config}_CALL_CONSTRAINTS_${iter}${VAR_SUFFIX})
      if(INCLUDED)
        set(${RES_CHECK_MADE} TRUE PARENT_SCOPE)
        set(${RES_CHECK} ${TEMP_CONFIG_${config}_CHECK_${iter}${VAR_SUFFIX}} PARENT_SCOPE)
        set(${RES_CONSTRAINTS} ${TEMP_CONFIG_${config}_BINARY_CONSTRAINTS_${iter}${VAR_SUFFIX}} PARENT_SCOPE)#returning the binary constraints not the call constraints
        return()
      endif()
    endforeach()
    return()
  endif()
endfunction(check_Configuration_Temporary_Optimization_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Runtime_Links_Temporary_Optimization_Variables| replace:: ``set_Runtime_Links_Temporary_Optimization_Variables``
#  .. _set_Runtime_Links_Temporary_Optimization_Variables:
#
#  set_Runtime_Links_Temporary_Optimization_Variables
#  --------------------------------------------------
#
#   .. command:: set_Runtime_Links_Temporary_Optimization_Variables(package component mode list_of_links)
#
#   set optimization variables used to check runtime links of a component.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode.
#     :list_of_local_links_var: the parent scope variable containing the list of links to use to generate symplinks for package.
#     :list_of_using_links_var: the parent scope variable containing the list of links to use to generate symplinks for another package than package.
#
function(set_Runtime_Links_Temporary_Optimization_Variables package component mode list_of_local_links_var list_of_using_links_var)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  append_Unique_In_Cache(TEMP_VARS${VAR_SUFFIX} ${package}_${component})
  set(TEMP_${package}_${component}_LOCAL_RUNTIME_LINKS${VAR_SUFFIX} ${${list_of_local_links_var}} CACHE INTERNAL "")
  set(TEMP_${package}_${component}_USING_RUNTIME_LINKS${VAR_SUFFIX} ${${list_of_using_links_var}} CACHE INTERNAL "")
endfunction(set_Runtime_Links_Temporary_Optimization_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Runtime_Links_Temporary_Optimization_Variables| replace:: ``check_Runtime_Links_Temporary_Optimization_Variables``
#  .. _check_Runtime_Links_Temporary_Optimization_Variables:
#
#  check_Runtime_Links_Temporary_Optimization_Variables
#  ----------------------------------------------------
#
#   .. command:: check_Runtime_Links_Temporary_Optimization_Variables(LOCAL_LINKS USING_LINKS package component mode)
#
#   check whether runtime links of a component have already been computed.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode.
#
#     :LOCAL_LINKS: the output variable that contains the variable containing the previous check resulting runtime local links, or that is empty if no previous check.
#     :USING_LINKS: the output variable that contains the variable containing the previous check resulting runtime local links, or that is empty if no previous check.
#
function(check_Runtime_Links_Temporary_Optimization_Variables LOCAL_LINKS USING_LINKS package component mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  if(DEFINED TEMP_${package}_${component}_LOCAL_RUNTIME_LINKS${VAR_SUFFIX}
    AND DEFINED TEMP_${package}_${component}_USING_RUNTIME_LINKS${VAR_SUFFIX})
    set(${LOCAL_LINKS} TEMP_${package}_${component}_LOCAL_RUNTIME_LINKS${VAR_SUFFIX} PARENT_SCOPE)
    set(${USING_LINKS} TEMP_${package}_${component}_USING_RUNTIME_LINKS${VAR_SUFFIX} PARENT_SCOPE)
    return()
  endif()
  set(${LOCAL_LINKS} PARENT_SCOPE)
  set(${USING_LINKS} PARENT_SCOPE)
endfunction(check_Runtime_Links_Temporary_Optimization_Variables)


#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables| replace:: ``check_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables``
#  .. _check_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables:
#
#  check_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables
#  ----------------------------------------------------------------------
#
#   .. command:: check_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables(ALREADY_MANAGED package component mode)
#
#    Check whether runtime dependencies of a component have already been managed (i.e. symlinks generated).
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode.
#
#     :ALREADY_MANAGED: the output variable that is TRUE is component has already been managed, false otherwise.
#
function(check_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables ALREADY_MANAGED package component mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  if(TEMP_${package}_${component}_MANAGED_RUNTIME${VAR_SUFFIX})
    set(${ALREADY_MANAGED} TRUE PARENT_SCOPE)
    return()
  endif()
  set(${ALREADY_MANAGED} FALSE PARENT_SCOPE)
endfunction(check_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables| replace:: ``set_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables``
#  .. _set_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables:
#
#  set_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables
#  --------------------------------------------------------------------
#
#   .. command:: set_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables(package component mode)
#
#    Set runtime dependencies resolution of a component as "managed".
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode.
#
function(set_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables package component mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  append_Unique_In_Cache(TEMP_VARS${VAR_SUFFIX} ${package}_${component})
  set(TEMP_${package}_${component}_MANAGED_RUNTIME${VAR_SUFFIX} TRUE CACHE INTERNAL "")
endfunction(set_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Resources_Temporary_Optimization_Variables| replace:: ``set_Resources_Temporary_Optimization_Variables``
#  .. _set_Resources_Temporary_Optimization_Variables:
#
#  set_Resources_Temporary_Optimization_Variables
#  ----------------------------------------------
#
#   .. command:: set_Resources_Temporary_Optimization_Variables(package component mode list_of_resources)
#
#   set optimization variables used to check runtime resources of a component.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode.
#     :list_of_resources: the list of runtime resources to memorize.
#
function(set_Resources_Temporary_Optimization_Variables package component mode list_of_resources)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  append_Unique_In_Cache(TEMP_VARS${VAR_SUFFIX} ${package}_${component})
  set(TEMP_${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX} "${list_of_resources}" CACHE INTERNAL "")
endfunction(set_Resources_Temporary_Optimization_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Resource_Temporary_Optimization_Variables| replace:: ``check_Resource_Temporary_Optimization_Variables``
#  .. _check_Resource_Temporary_Optimization_Variables:
#
#  check_Resource_Temporary_Optimization_Variables
#  -----------------------------------------------
#
#   .. command:: check_Resource_Temporary_Optimization_Variables(RESOURCES package component mode)
#
#   check whether runtime resources of a component have already been computed.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode.
#
#     :RESOURCES: the output variable that contains the variable containing the previous check resulting runtime resources, or that is empty if no previous check.
#
function(check_Resource_Temporary_Optimization_Variables RESOURCES package component mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  if(DEFINED TEMP_${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX})
    set(${RESOURCES} TEMP_${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX} PARENT_SCOPE)
    return()
  endif()
  set(${RESOURCES} PARENT_SCOPE)
endfunction(check_Resource_Temporary_Optimization_Variables)


#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Source_Resources_Temporary_Optimization_Variables| replace:: ``set_Source_Resources_Temporary_Optimization_Variables``
#  .. _set_Source_Resources_Temporary_Optimization_Variables:
#
#  set_Source_Resources_Temporary_Optimization_Variables
#  -----------------------------------------------------
#
#   .. command:: set_Source_Resources_Temporary_Optimization_Variables(component mode list_of_resources)
#
#   set optimization variables used to check runtime resources in source/build tree for a given source component.
#
#     :component: the name of the component.
#     :mode: the build mode.
#     :list_of_resources: the list of runtime resources to memorize.
#
function(set_Source_Resources_Temporary_Optimization_Variables component mode list_of_resources)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  append_Unique_In_Cache(TEMP_VARS${VAR_SUFFIX} ${PROJECT_NAME}_${component})
  set(TEMP_${PROJECT_NAME}_${component}_SOURCE_RUNTIME_RESOURCES${VAR_SUFFIX} "${list_of_resources}" CACHE INTERNAL "")
endfunction(set_Source_Resources_Temporary_Optimization_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Source_Resource_Temporary_Optimization_Variables| replace:: ``check_Source_Resource_Temporary_Optimization_Variables``
#  .. _check_Source_Resource_Temporary_Optimization_Variables:
#
#  check_Source_Resource_Temporary_Optimization_Variables
#  ------------------------------------------------------
#
#   .. command:: check_Source_Resource_Temporary_Optimization_Variables(RESOURCES component mode)
#
#   check whether path to runtime resources in Build tree for a given component have already been computed .
#
#     :component: the name of the source component.
#     :mode: the build mode.
#
#     :RESOURCES: the output variable that contains the variable containing the previous check resulting runtime resources, or that is empty if no previous check.
#
function(check_Source_Resource_Temporary_Optimization_Variables RESOURCES component mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  if(DEFINED TEMP_${PROJECT_NAME}_${component}_SOURCE_RUNTIME_RESOURCES${VAR_SUFFIX})
    set(${RESOURCES} TEMP_${PROJECT_NAME}_${component}_SOURCE_RUNTIME_RESOURCES${VAR_SUFFIX} PARENT_SCOPE)
    return()
  endif()
  set(${RESOURCES} PARENT_SCOPE)
endfunction(check_Source_Resource_Temporary_Optimization_Variables)
