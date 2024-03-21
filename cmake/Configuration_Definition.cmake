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

# prevent CMake automatic detection messages from appearing
set(CMAKE_MESSAGE_LOG_LEVEL NOTICE CACHE INTERNAL "")

include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)

include(CMakeParseArguments)
load_Current_Platform_Only()
stop_Make_To_Print_Directories()

##################################################################################################
#################### API to ease the description of system configurations ########################
##################################################################################################

#.rst:
#
# .. ifmode:: system
#
#  .. |found_PID_Configuration| replace:: ``found_PID_Configuration``
#  .. _found_PID_Configuration:
#
#  found_PID_Configuration
#  ^^^^^^^^^^^^^^^^^^^^^^^
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
# .. ifmode:: system
#
#  .. |installable_PID_Configuration| replace:: ``installable_PID_Configuration``
#  .. _installable_PID_Configuration:
#
#  installable_PID_Configuration
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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
# .. ifmode:: system
#
#  .. |execute_OS_Configuration_Command| replace:: ``execute_OS_Configuration_Command``
#  .. _execute_OS_Configuration_Command:
#
#  execute_OS_Configuration_Command
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: execute_OS_Configuration_Command([NOT_PRIVILEGED] [OUTPUT_VARIABLE var] ...)
#
#      invoque a command of the operating system with adequate privileges.
#
#     .. rubric:: Required parameters
#
#     :NOT_PRIVILEGED: is used first argument passed for privileged execution is never required
#     :OUTPUT_VARIABLE var: contains the output from std output and error
#     :...: the command to be executed (do not use sudo !)
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
#        execute_OS_Configuration_Command(apt-get install -y libgtk2.0-dev libgtkmm-2.4-dev)
#
macro(execute_OS_Configuration_Command)
if(NOT DO_NOT_INSTALL)
  set(oneValueArgs OUTPUT_VARIABLE)
  set(options NOT_PRIVILEGED)
  cmake_parse_arguments(EXE_OS_CMD "${options}" "${oneValueArgs}" "" ${ARGN} )
  set(exec_opts OUTPUT_VARIABLE process_output ERROR_VARIABLE process_output RESULT_VARIABLE result)
   # fill_String_From_List(ARGS EXE_OS_CMD_UNPARSED_ARGUMENTS " ")
  if(EXE_OS_CMD_NOT_PRIVILEGED)
    execute_process(COMMAND ${EXE_OS_CMD_UNPARSED_ARGUMENTS} ${exec_opts})
  elseif(IN_CI_PROCESS)#force unpriviledged run in CI
    execute_process(COMMAND ${EXE_OS_CMD_UNPARSED_ARGUMENTS} ${exec_opts})
  else()#do a priviledge call by default
    #need to have super user privileges except in CI where suding sudi is forbidden
    execute_process(COMMAND sudo ${EXE_OS_CMD_UNPARSED_ARGUMENTS} ${exec_opts})
  endif()
  if(NOT result EQUAL 0)
    message("${process_output}")
  endif()
  if(EXE_OS_CMD_OUTPUT_VARIABLE)
    set(${EXE_OS_CMD_OUTPUT_VARIABLE} ${process_output})
  endif()
  unset(process_output)
  unset(result)
  unset(exec_opts)
endif()
endmacro(execute_OS_Configuration_Command)

#.rst:
#
# .. ifmode:: system
#
#  .. |resolve_PID_System_Libraries_From_Path| replace:: ``resolve_PID_System_Libraries_From_Path``
#  .. _resolve_PID_System_Libraries_From_Path:
#
#  resolve_PID_System_Libraries_From_Path
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: resolve_PID_System_Libraries_From_Path(list_of_path
#                                                       ALL_SHARED_LIBRARIES_REAL_PATH
#                                                       ALL_SHARED_LIBRARIES_SONAME
#                                                       ALL_STATIC_LIBRARIES_REAL_PATH
#                                                       ALL_LINKS_PATH)
#
#      Utility function to be used in system configuration eval script (cf. Wrapper API).
#      Resolve real path to libraries' binaries (i.e. resolve linker scripts) and get their soname.
#      Typically used after a call to find_package.
#
#     .. rubric:: Required parameters
#
#     :<list_of_path>: the list of path to libraries.
#
#     :<ALL_SHARED_LIBRARIES_REAL_PATH>: the output variable that contains the list of path to real binaries in operating system filesystem.
#
#     :<ALL_SHARED_LIBRARIES_SONAME>: the output variable that contains the list of the libraries sonames.
#
#     :<ALL_STATIC_LIBRARIES_REAL_PATH>: the output variable that contains the list of path to static libraries.
#
#     :<ALL_LINKS_PATH>: the output variable that contains the list of path to links (or real path if no link) used to target the libraries used (either static or shared).
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function can be called in the eval script of a system configuration.
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
#        find_package(OpenSSL REQUIRED)
#        resolve_PID_System_Libraries_From_Path("${OpenSSL_LIBRARIES}" ALL OPENSSL_LIBS OPENSSL_SONAMES)
#
function(resolve_PID_System_Libraries_From_Path all_libraries ALL_SHARED_LIBRARIES_REAL_PATH ALL_SHARED_LIBRARIES_SONAME ALL_STATIC_LIBRARIES_PATH ALL_LINKS_PATH)
  set(result_shared_path)
  set(result_static_path)
  set(result_sonames)
  set(result_link_path)
  foreach(lib IN LISTS all_libraries)
    find_PID_Library_In_Linker_Order(${lib} ALL REAL_PATH SONAME LINK_PATH)
    if(SONAME)
      list(APPEND result_sonames ${SONAME})
      list(APPEND result_shared_path ${REAL_PATH})
    else()
      list(APPEND result_static_path ${REAL_PATH})
    endif()
    list(APPEND result_link_path ${LINK_PATH})
  endforeach()
  set(${ALL_SHARED_LIBRARIES_REAL_PATH} ${result_shared_path} PARENT_SCOPE)
  set(${ALL_SHARED_LIBRARIES_SONAME} ${result_sonames} PARENT_SCOPE)
  set(${ALL_STATIC_LIBRARIES_PATH} ${result_static_path} PARENT_SCOPE)
  set(${ALL_LINKS_PATH} ${result_link_path} PARENT_SCOPE)
endfunction(resolve_PID_System_Libraries_From_Path)

#.rst:
#
# .. ifmode:: system
#
#  .. |find_PID_Library_In_Linker_Order| replace:: ``find_PID_Library_In_Linker_Order``
#  .. _find_PID_Library_In_Linker_Order:
#
#  find_PID_Library_In_Linker_Order
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: find_PID_Library_In_Linker_Order(possible_library_names search_folders_type LIBRARY_PATH LIB_SONAME)
#
#      Utility function to be used in configuration find script. Try to find a library in same order as the linker.
#
#     .. rubric:: Required parameters
#
#     :<possible_library_names_or_path>: the list of possible names or path for the library.
#
#     :<search_folders_type>: if equal to "ALL" all path will be searched in. If equal to "IMPLICIT" only implicit link folders (non user install folders) will be searched in. If equal to "USER" implicit link folders are not used.
#
#     :<LIBRARY_PATH>: the output variable that contains the path to the library in the system.
#
#     :<LIB_SONAME>: the output variable that contains the SONAME of the library, if any (for shared libraries).
#
#     .. rubric:: Optional parameters
#
#     :<out_var_link>: the output variable that contains the path to link used to target the library (or real path if direct path is used)
#
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
#        find_PID_Library_In_Linker_Order("tiff" ALL TIFF_LIB TIFF_SONAME)
#
function(find_PID_Library_In_Linker_Order possible_library_names_or_path search_folders_type LIBRARY_PATH LIB_SONAME)
  #0)extract name from full path, is any
  set(out_var_link)
  if(NOT "${ARGN}" STREQUAL "")
    set(out_var_link ${ARGN})
  endif()
  set(IS_PATH FALSE)
  set(IS_NAME FALSE)
  foreach(name_or_path IN LISTS possible_library_names_or_path)
    if(EXISTS ${name_or_path})#this is a path
      set(IS_PATH TRUE)
    else()
      set(IS_NAME TRUE)
    endif()
  endforeach()
  if(IS_PATH AND IS_NAME)
    message("[PID] ERROR: bad usage of function find_PID_Library_In_Linker_Order, must provide name or path as argument but not both")
    return()
  elseif(IS_PATH)
    list(LENGTH possible_library_names_or_path SIZE)
    if(SIZE GREATER 1)
      message("[PID] ERROR: bad usage of function find_PID_Library_In_Linker_Order, only one path must be provided !")
      return()
    endif()

    #from here only one path given => must resolve everything to be sure we do not target a linker script but we want soname info from real binary
    list(GET possible_library_names_or_path 0 the_path)
    get_filename_component(LIB_NAME_WE ${the_path} NAME_WE)
    is_Shared_Lib_With_Path(SHARED ${the_path})
    if(SHARED)
      get_Platform_Related_Binary_Prefix_Suffix(PREFIX EXTENSIONS "SHARED")
    else()
      get_Platform_Related_Binary_Prefix_Suffix(PREFIX EXTENSIONS "STATIC")
    endif()
    if(PREFIX)
      string(FIND "${LIB_NAME_WE}" "${PREFIX}" INDEX)
      if(INDEX EQUAL 0)#avoid removing prefix like "lib" if same string is used within library name
        string(LENGTH "${PREFIX}" PREFIX_LENGTH)
        string(SUBSTRING "${LIB_NAME_WE}" ${PREFIX_LENGTH} -1 lib_name)
      else()#no prefix for this lib ... not impossible
        set(lib_name ${LIB_NAME_WE})
      endif()
    else()
      set(lib_name ${LIB_NAME_WE})
    endif()
    if(SHARED)
      get_Soname_Info_From_Library_Path(LIB_PATH SONAME SOVERSION ${lib_name} ${the_path})
      set(${LIBRARY_PATH} ${LIB_PATH} PARENT_SCOPE)
      set(${LIB_SONAME} ${SONAME} PARENT_SCOPE)
    else()#this is a path to a static library
      get_RealPath_From_Static_Library_Path(LIB_PATH ${lib_name} ${the_path})
      set(${LIBRARY_PATH} ${LIB_PATH} PARENT_SCOPE)
      set(${LIB_SONAME} PARENT_SCOPE)#no sonames for static libraries
    endif()
    if(out_var_link)#if a path is given directly return the library path when the link path name is required
      set(${out_var_link} ${the_path} PARENT_SCOPE)#may be different than LIB_PATH wichi is the resolved path
    endif()
    return()
  endif()
  #1) search in implicit system folders
  if(NOT search_folders_type STREQUAL "USER")
    foreach(lib IN LISTS possible_library_names_or_path)
      find_Library_In_Implicit_System_Dir(IMPLICIT_LIBRARY_PATH LINK_PATH RET_SONAME LIB_SOVERSION ${lib})
      if(IMPLICIT_LIBRARY_PATH)#found
        set(${LIBRARY_PATH} ${IMPLICIT_LIBRARY_PATH} PARENT_SCOPE)
        set(${LIB_SONAME} ${RET_SONAME} PARENT_SCOPE)
        if(out_var_link)#return the link path when required
          set(${out_var_link} ${LINK_PATH} PARENT_SCOPE)
        endif()
        return()
      endif()
    endforeach()
  endif()
  if(NOT search_folders_type STREQUAL "IMPLICIT")
  #2) search in cmake defined system search folders
    find_library(RET_LIBRARY NAMES ${possible_library_names_or_path})
    if(RET_LIBRARY)
      set(lib_path ${RET_LIBRARY})
      unset(RET_LIBRARY CACHE)
      set(${LIBRARY_PATH} ${lib_path} PARENT_SCOPE)

      extract_Soname_From_PID_Libraries(lib_path RET_SONAME)
      set(${LIB_SONAME} ${RET_SONAME} PARENT_SCOPE)
      if(out_var_link)#return the link path when required
        set(${out_var_link} ${lib_path} PARENT_SCOPE)
      endif()
      return()
    endif()
  endif()

  set(${LIBRARY_PATH} PARENT_SCOPE)
  set(${LIB_SONAME} PARENT_SCOPE)
  if(out_var_link)
    set(${out_var_link} PARENT_SCOPE)
  endif()
endfunction(find_PID_Library_In_Linker_Order)

#.rst:
#
# .. ifmode:: system
#
#  .. |convert_PID_Libraries_Into_System_Links| replace:: ``convert_PID_Libraries_Into_System_Links``
#  .. _convert_PID_Libraries_Into_System_Links:
#
#  convert_PID_Libraries_Into_System_Links
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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
# .. ifmode:: system
#
#  .. |convert_PID_Libraries_Into_Library_Directories| replace:: ``convert_PID_Libraries_Into_Library_Directories``
#  .. _convert_PID_Libraries_Into_Library_Directories:
#
#  convert_PID_Libraries_Into_Library_Directories
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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
      is_A_System_Reference_Path(${FOLDER} IS_SYSTEM)#do not add it if folder is a  default libraries folder
      if(NOT IS_SYSTEM)
        list(APPEND all_links ${FOLDER})
      endif()
  	endforeach()
    if(all_links)
      list(REMOVE_DUPLICATES all_links)
    endif()
  endif()
  set(${OUT_VAR} ${all_links} PARENT_SCOPE)
endfunction(convert_PID_Libraries_Into_Library_Directories)


#.rst:
#
# .. ifmode:: system
#
#  .. |extract_Soname_From_PID_Libraries| replace:: ``extract_Soname_From_PID_Libraries``
#  .. _extract_Soname_From_PID_Libraries:
#
#  extract_Soname_From_PID_Libraries
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: extract_Soname_From_PID_Libraries(list_of_libraries_var OUT_VAR)
#
#      Utility function to be used in configuration find script. Extract the libraries sonames from libraries path.
#
#     .. rubric:: Required parameters
#
#     :<list_of_libraries_var>: the name of the variable that contains the list of libraries to convert.
#
#     :<OUT_VAR>: the output variable that contains the list of sonames, in same order.
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
#        extract_Soname_From_PID_Libraries(CURL_SONAMES CURL_LIB)
#
function(extract_Soname_From_PID_Libraries list_of_libraries_var OUT_VAR)
  set(all_sonames)
  if(${list_of_libraries_var})#the variable containing the list trully contains a list
    foreach(lib IN LISTS ${list_of_libraries_var})
      get_Binary_Description(LIB_DESCR ${lib})
      get_Soname(SONAME SOVERSION LIB_DESCR)
      if(SONAME)
        list(APPEND all_sonames ${SONAME})
      endif()
    endforeach()
    if(all_sonames)
      list(REMOVE_DUPLICATES all_sonames)
    endif()
  endif()
  set(${OUT_VAR} ${all_sonames} PARENT_SCOPE)
endfunction(extract_Soname_From_PID_Libraries)


#.rst:
#
# .. ifmode:: system
#
#  .. |extract_Symbols_From_PID_Libraries| replace:: ``extract_Symbols_From_PID_Libraries``
#  .. _extract_Symbols_From_PID_Libraries:
#
#  extract_Symbols_From_PID_Libraries
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: extract_Symbols_From_PID_Libraries(list_of_libraries_var list_of_symbols OUT_LIST_OF_SYMBOL_VERSION_PAIRS)
#
#      Utility function to be used in configuration find script. Extract the libraries symbols from libraries path.
#
#     .. rubric:: Required parameters
#
#     :<list_of_libraries_var>: the name of the variable that contains the list of libraries to check.
#
#     :<list_of_symbols>: the name of the variable that contains the list of symbols to find.
#
#     :<OUT_LIST_OF_SYMBOL_VERSION_PAIRS>: the output variable that contains the list of pairs <symbol,max version>.
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
#        extract_Symbols_From_PID_Libraries(OPENSSL_SYMBOLS OPENSSL_LIB "OPENSSL_")
#
function(extract_Symbols_From_PID_Libraries list_of_libraries_var list_of_symbols OUT_LIST_OF_SYMBOL_VERSION_PAIRS)
  foreach(symbol IN LISTS list_of_symbols)#cleaning variable, in case of
    unset(${symbol}_MAX_VERSION)
  endforeach()
  set(managed_symbols)
  if(${list_of_libraries_var})#the variable containing the list trully contains a list
    foreach(lib IN LISTS ${list_of_libraries_var})
      foreach(symbol IN LISTS list_of_symbols)
        get_Library_ELF_Symbol_Max_Version(MAX_VERSION ${lib} ${symbol})
        if(MAX_VERSION)
          if(${symbol}_MAX_VERSION)#a version is already known for that symbol
            if(${symbol}_MAX_VERSION VERSION_LESS MAX_VERSION)
              set(${symbol}_MAX_VERSION ${MAX_VERSION})
            endif()
          else()
            list(APPEND managed_symbols ${symbol})
            set(${symbol}_MAX_VERSION ${MAX_VERSION})
          endif()
        endif()
      endforeach()
    endforeach()
  endif()
  set(all_symbols_pair)
  foreach(symbol IN LISTS managed_symbols)
    serialize_Symbol(SERIALIZED_SYMBOL ${symbol} ${${symbol}_MAX_VERSION})
    list(APPEND all_symbols_pair "${SERIALIZED_SYMBOL}")
  endforeach()
  set(${OUT_LIST_OF_SYMBOL_VERSION_PAIRS} ${all_symbols_pair} PARENT_SCOPE)
endfunction(extract_Symbols_From_PID_Libraries)

#.rst:
#
# .. ifmode:: system
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
