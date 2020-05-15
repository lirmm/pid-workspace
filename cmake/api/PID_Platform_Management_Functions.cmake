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

include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Package_Cache_Management_Functions NO_POLICY_SCOPE)
include(PID_Contribution_Space_Functions NO_POLICY_SCOPE)
include(PID_Profiles_Functions NO_POLICY_SCOPE)


#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Platform_Reporting_File| replace:: ``write_Platform_Reporting_File``
#  .. _write_Platform_Reporting_File:
#
#  write_Platform_Reporting_File
#  -----------------------------
#
#   .. command:: write_Platform_Reporting_File(file)
#
#     Write platform info user reporting file.
#
#     :file: path to target file
#
function(write_Platform_Reporting_File file)
  #print global info
  set(WORKSPACE_CONFIGURATION_DESCRIPTION)
  if(CURRENT_PROFILE STREQUAL "default")
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "[PID] INFO: using default profile, based on host native development en
    vironment.\n")
  else()
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "[PID] INFO: using ${CURRENT_PROFILE} profile, based on ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT} as main development environment.\n")
    if(${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}_ACTION_INFO)
      string(CONFIGURE "${${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}_ACTION_INFO}" configured_actions)
      set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION} - ${configured_actions}\n")
    endif()
  endif()
  if(PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS)
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO: additional environments in use:\n")
    foreach(add_env IN LISTS PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS)
      set(mess_str "  -  ${add_env}")
      if(${add_env}_ACTION_INFO)
        string(CONFIGURE "${${add_env}_ACTION_INFO}" configured_actions)
        set(mess_str "${mess_str}: ${configured_actions}")
      endif()
      set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}${mess_str}\n")
    endforeach()
  endif()

  set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}\n[PID] INFO : Target platform in use is ${CURRENT_PLATFORM}:\n")
  if(CURRENT_SPECIFIC_INSTRUCTION_SET)
    string(REPLACE ";" ", " OPTIMIZATIONS "${CURRENT_SPECIFIC_INSTRUCTION_SET}")
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION} + processor family = ${CURRENT_PLATFORM_TYPE} (optimizations: ${OPTIMIZATIONS})\n")
  else()
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION} + processor family = ${CURRENT_PLATFORM_TYPE}\n")
  endif()
  set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION} + binary architecture= ${CURRENT_PLATFORM_ARCH}\n")
  if(CURRENT_PLATFORM_OS)
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION} + operating system=${CURRENT_PLATFORM_OS}")
    if(CURRENT_DISTRIBUTION)
      set(distrib_str "")
      if(NOT CURRENT_DISTRIBUTION_VERSION)
        if(CURRENT_PACKAGING_SYSTEM)
          set(distrib_str "(${CURRENT_DISTRIBUTION}, ${CURRENT_PACKAGING_SYSTEM_EXE} packaging)")
        else()
          set(distrib_str "(${CURRENT_DISTRIBUTION})")
        endif()
      else()#there is a version number bound to the distribution
        if(CURRENT_PACKAGING_SYSTEM)
          set(distrib_str "(${CURRENT_DISTRIBUTION} ${CURRENT_DISTRIBUTION_VERSION}, ${CURRENT_PACKAGING_SYSTEM_EXE} packaging)")
        else()
          set(distrib_str "(${CURRENT_DISTRIBUTION} ${CURRENT_DISTRIBUTION_VERSION})")
        endif()
      endif()
      set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION} ${distrib_str}\n")
    else()
      set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}\n")
    endif()
  endif()
  set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION} + compiler ABI= ${CURRENT_PLATFORM_ABI}\n")

  if(Python_Language_AVAILABLE)
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO : Python may be used, target python version in use is ${CURRENT_PYTHON}. To use python modules installed in workspace please set the PYTHONPATH to =${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/__python${CURRENT_PYTHON}__\n")
  endif()
  if(CUDA_Language_AVAILABLE)
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO : CUDA language (version ${CUDA_VERSION}) may be used.\n")
  endif()
  if(Fortran_Language_AVAILABLE)
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO : Fortran language may be used.\n")
  endif()
  file(WRITE ${CMAKE_BINARY_DIR}/Platform_Description.txt "${WORKSPACE_CONFIGURATION_DESCRIPTION}")
endfunction(write_Platform_Reporting_File)

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
	include(CheckSystemPackaging)
	include(CheckDistribution)
	include(CheckCompiler)#only useful for further checking
  include(CheckInstructionSet)
  set(CURRENT_SPECIFIC_INSTRUCTION_SET ${CPU_ALL_AVAILABLE_OPTIMIZATIONS} CACHE INTERNAL "" FORCE)
	include(CheckABI)
  if(CURRENT_ABI STREQUAL CXX11)
    set(CURRENT_PLATFORM_ABI abi11 CACHE INTERNAL "" FORCE)
  else()
    set(CURRENT_PLATFORM_ABI abi98 CACHE INTERNAL "" FORCE)
  endif()
  include(CheckLanguage)
	include(CheckPython)
	include(CheckFortran)
	include(CheckCUDA)
  include(CheckDevTools)
  #simply rewriting previously defined variable to normalize their names between workspace and packages (same accessor function can then be used from any place)
  set(CURRENT_PACKAGE_STRING ${CURRENT_PACKAGE_STRING} CACHE INTERNAL "" FORCE)
  set(CURRENT_DISTRIBUTION ${CURRENT_DISTRIBUTION} CACHE INTERNAL "" FORCE)

  if(CURRENT_PLATFORM_OS)#the OS is optional (for microcontrolers there is no OS)
    set(CURRENT_PLATFORM ${CURRENT_PLATFORM_TYPE}_${CURRENT_PLATFORM_ARCH}_${CURRENT_PLATFORM_OS}_${CURRENT_PLATFORM_ABI} CACHE INTERNAL "" FORCE)
  else()
    set(CURRENT_PLATFORM ${CURRENT_PLATFORM_TYPE}_${CURRENT_PLATFORM_ARCH}_${CURRENT_PLATFORM_ABI} CACHE INTERNAL "" FORCE)
  endif()

  set(PACKAGE_BINARY_INSTALL_DIR ${CMAKE_SOURCE_DIR}/install/${CURRENT_PLATFORM} CACHE INTERNAL "" FORCE)

endmacro(detect_Current_Platform)


#############################################################################################
######################## utility functions to get info about binaries #######################
#############################################################################################


#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_ELF_Symbol_Version| replace:: ``extract_ELF_Symbol_Version``
#  .. _extract_ELF_Symbol_Version:
#
#  extract_ELF_Symbol_Version
#  --------------------------
#
#   .. command:: extract_ELF_Symbol_Version(RES_VERSION symbol symbol_version)
#
#    Get the version from a (supposed to be) versionned symbol.
#
#     :symbol: the symbol that is supposed to have a version number. For instance symbol GLIBCXX can be used for libstdc++.so (GNU standard C++ library).
#
#     :symbol_version: the input symbol, for instance "GLIBCXX_2.4".
#
#     :RES_VERSION: the output variable that contains the version of the target symbol always with major.minor.patch structure. For istance with previous arguùents it returns "2.4.0".
#
function(extract_ELF_Symbol_Version RES_VERSION symbol symbol_version)
  if(symbol_version MATCHES "^${symbol}([0-9]+(\\.[0-9]+)*)$")
    set(${RES_VERSION} "${CMAKE_MATCH_1}" PARENT_SCOPE)
	else()
		set(${RES_VERSION} "0.0.0" PARENT_SCOPE)
	endif()
endfunction(extract_ELF_Symbol_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |pop_ELF_Symbol_Version_From_List| replace:: ``pop_ELF_Symbol_Version_From_List``
#  .. _pop_ELF_Symbol_Version_From_List:
#
#  pop_ELF_Symbol_Version_From_List
#  --------------------------------
#
#   .. command:: pop_ELF_Symbol_Version_From_List(RES_SYMBOL RES_VERSION inout_list)
#
#    Get the first symbol and version from a list generated by get_Library_ELF_Symbols_Max_Versions and remove them from this list.
#
#     :inout_list: the input/output variable that contains the list to be updated.
#
#     :RES_SYMBOL: the output variable that contains the symbol name
#
#     :RES_VERSION: the output variable that contains the symbol version.
#
function(pop_ELF_Symbol_Version_From_List RES_SYMBOL RES_VERSION inout_list)
  if(${inout_list})#if list not empty
    list(GET ${inout_list} 0 symbol)
    list(GET ${inout_list} 1 version)
    list(REMOVE_AT ${inout_list} 0 1)
    set(${inout_list} ${${inout_list}} PARENT_SCOPE)#update is only local for now so update it in parent scope
    set(${RES_SYMBOL} ${symbol} PARENT_SCOPE)
    set(${RES_VERSION} ${version} PARENT_SCOPE)
  else()
    set(${RES_SYMBOL} PARENT_SCOPE)
    set(${RES_VERSION} PARENT_SCOPE)
  endif()
endfunction(pop_ELF_Symbol_Version_From_List)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Binary_Description| replace:: ``get_Binary_Description``
#  .. _get_Binary_Description:
#
#  get_Binary_Description
#  ----------------------
#
#   .. command:: get_Binary_Description(DESCRITION path_to_library)
#
#    Get the description of a runtime binary (ELF format).
#
#     :path_to_library: the library to inspect.
#
#     :DESCRITION: the output variable that contains the description of the binary object.
#
function(get_Binary_Description DESCRITION path_to_library)
  execute_process(COMMAND ${CMAKE_OBJDUMP} -p ${path_to_library}
                  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                  ERROR_QUIET
                  OUTPUT_VARIABLE OBJECT_CONTENT
                  RESULT_VARIABLE res)
  if(res EQUAL 0)
    set(${DESCRITION} ${OBJECT_CONTENT} PARENT_SCOPE)
  else()
    set(${DESCRITION} PARENT_SCOPE)
  endif()
endfunction(get_Binary_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Soname| replace:: ``get_Soname``
#  .. _get_Soname:
#
#  get_Soname
#  ----------
#
#   .. command:: get_Soname(SONAME SOVERSION library_description)
#
#    Get the SONAME from a target library description.
#
#     :library_description: the PARENT SCOPE variable containing the library description.
#
#     :SONAME: the output variable that contains the full soname, if any, empty otherwise.
#
#     :SOVERSION: the output variable that contains the only the soversion if any, empty otherwise (implies SONAME is not empty).
#
function(get_Soname SONAME SOVERSION library_description)
  set(full_soname)
  set(so_version)
  if(${library_description} MATCHES ".*SONAME[ \t]+([^ \t\n]+)[ \t\n]*")
    set(full_soname ${CMAKE_MATCH_1})
    get_filename_component(extension ${full_soname} EXT)
    if(CURRENT_PLATFORM_OS STREQUAL linux OR CURRENT_PLATFORM_OS STREQUAL freebsd)
      if(extension MATCHES "^\\.so\\.([.0-9]+)$")
        set(so_version ${CMAKE_MATCH_1})
      endif()
    elseif(CURRENT_PLATFORM_OS STREQUAL macos AND extension MATCHES "^\\.([.0-9]+)\\.dylib$")
      set(so_version ${CMAKE_MATCH_1})
    endif()
  endif()
  set(${SONAME} ${full_soname} PARENT_SCOPE)#i.e. NO soname
  set(${SOVERSION} ${so_version} PARENT_SCOPE)#i.e. NO soversion by default
endfunction(get_Soname)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Possible_Library_Path| replace:: ``find_Possible_Library_Path``
#  .. _find_Possible_Library_Path:
#
#  find_Possible_Library_Path
#  --------------------------
#
#   .. command:: find_Possible_Library_Path(FULL_PATH LINK_PATH LIB_SONAME library_name library_description)
#
#    Get the SONAME from a target library description.
#
#     :folder: the absolute path to the folder where the library can lie.
#
#     :library_name: the name of the library (without any prefix or postfix specific to system).
#
#     :REAL_PATH: the output variable that contains the full path to library with resolved symlinks, empty if no path found.
#
#     :LINK_PATH: the output variable that contains the path to library used at link time, empty if no path found.
#
#     :LIB_SONAME: the output variable that contains the name of the library if path has been found, empty otherwise.
#
function(find_Possible_Library_Path REAL_PATH LINK_PATH LIB_SONAME folder library_name)
  set(${REAL_PATH} PARENT_SCOPE)
  set(${LINK_PATH} PARENT_SCOPE)
  set(${LIB_SONAME} PARENT_SCOPE)
  get_Platform_Related_Binary_Prefix_Suffix(PREFIX EXTENSION "SHARED")
  set(prefixed_name ${PREFIX}${library_name})
  file(GLOB POSSIBLE_NAMES RELATIVE ${folder} "${folder}/${PREFIX}${library_name}*" )
  if(NOT POSSIBLE_NAMES)
    return()
  endif()
  #first check for the complete name without soversion
  set(possible_path)
  list(FIND POSSIBLE_NAMES ${PREFIX}${library_name}${EXTENSION} INDEX)
  if(INDEX EQUAL -1)#not found "as is"
    usable_In_Regex(libregex ${library_name})
    if(CURRENT_PLATFORM_OS STREQUAL linux OR CURRENT_PLATFORM_OS STREQUAL freebsd)
      set(pattern "^${PREFIX}${libregex}\\${EXTENSION}\\.([\\.0-9])+$")
    elseif(CURRENT_PLATFORM_OS STREQUAL macos)
      set(pattern "^${PREFIX}${libregex}\\.([\\.0-9])+\\${EXTENSION}$")
    else()#uncuspported OS => no pattern for SONAMED files
      return()#no solution
    endif()
    set(possible_path)
    foreach(name IN LISTS POSSIBLE_NAMES)
      #take the first one
      if(name MATCHES "${pattern}")
        set(possible_path ${folder}/${name})
        break()
      endif()
    endforeach()
  else()#it has the priority over the others
    set(possible_path ${folder}/${PREFIX}${library_name}${EXTENSION})
  endif()
  if(possible_path)
    get_filename_component(RET_PATH ${possible_path} REALPATH)
    set(${REAL_PATH} ${RET_PATH} PARENT_SCOPE)
    set(${LINK_PATH} ${possible_path} PARENT_SCOPE)
    set(${LIB_SONAME} ${PREFIX}${library_name}${EXTENSION} PARENT_SCOPE)
  endif()
endfunction(find_Possible_Library_Path)


#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_Library_Path_From_Linker_Script| replace:: ``extract_Library_Path_From_Linker_Script``
#  .. _extract_Library_Path_From_Linker_Script:
#
#  extract_Library_Path_From_Linker_Script
#  ---------------------------------------
#
#   .. command:: extract_Library_Path_From_Linker_Script(LIBRARY_PATH library path_to_linker_script)
#
#    From a file that is supposed to be a linker script extract real path to corresponding library.
#
#     :library: the name of the library (without any prefix or postfix specific to system).
#
#     :path_to_linker_script: the file that is possibly a linker script.
#
#     :LIBRARY_PATH: the output variable that contains the path to the real binary if specified in the linker script, empty otherwise.
#
function(extract_Library_Path_From_Linker_Script LIBRARY_PATH library path_to_linker_script)
    set(${LIBRARY_PATH} PARENT_SCOPE)
    get_Platform_Related_Binary_Prefix_Suffix(PREFIX EXTENSION "SHARED")
    usable_In_Regex(libpattern "${library}")
    set(prefixed_name ${PREFIX}${libpattern})
    set(pattern "^.*(GROUP|INPUT)[ \t]*\\([ \t]*([^ \t]+${prefixed_name}[^ \t]*\\${EXTENSION}[^ \t]*)[ \t]+.*$")#\\ is for adding \ at the beginning of extension (.so) so taht . will not be interpreted as a
    file(STRINGS ${path_to_linker_script} EXTRACTED REGEX "${pattern}")

    if(NOT EXTRACTED)#not a linker script or script does not contain
      return()
    endif()
    #from here the implicit linker script gioves the real path to library
    foreach(extracted IN LISTS EXTRACTED)
      if(EXTRACTED MATCHES "${pattern}")
        set(${LIBRARY_PATH} ${CMAKE_MATCH_2} PARENT_SCOPE)
        return()
      endif()
    endforeach()
endfunction(extract_Library_Path_From_Linker_Script)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Library_In_Implicit_System_Dir| replace:: ``find_Library_In_Implicit_System_Dir``
#  .. _find_Library_In_Implicit_System_Dir:
#
#  find_Library_In_Implicit_System_Dir
#  -----------------------------------
#
#   .. command:: find_Library_In_Implicit_System_Dir(LIBRARY_PATH LIB_SONAME LIB_SOVERSION library_name)
#
#    Get link info of a library that is supposed to be located in implicit system folders.
#
#     :library_name: the name of the library (without any prefix or postfix specific to system).
#
#     :LIBRARY_PATH: the output variable that contains the full path to library, empty if no path found.
#
#     :LIB_SONAME: the output variable that contains only the name of the library if path has been found, empty otherwise.
#
#     :LIB_SOVERSION: the output variable that contains only the SOVERSION of the library if LIB_SONAME has been found, empty otherwise.
#
function(find_Library_In_Implicit_System_Dir LIBRARY_PATH LIB_SONAME LIB_SOVERSION library_name)
  set(IMPLICIT_DIRS ${CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES})
  foreach(dir IN LISTS IMPLICIT_DIRS)#searching for library name in same order as specified by the path to ensure same resolution as the linker
  	find_Possible_Library_Path(REAL_PATH LINK_PATH LIBSONAME ${dir} ${library_name})
  	if(REAL_PATH)#there is a standard library or symlink with that name
      get_Soname_Info_From_Library_Path(LIB_PATH SONAME SOVERSION ${library_name} ${REAL_PATH})
      if(LIB_PATH)
        set(${LIBRARY_PATH} ${LIB_PATH} PARENT_SCOPE)
        set(${LIB_SONAME} ${SONAME} PARENT_SCOPE)
        set(${LIB_SOVERSION} ${SOVERSION} PARENT_SCOPE)
        return()#solution has been found
      endif()
    endif()
  endforeach()
  set(${LIBRARY_PATH} PARENT_SCOPE)
  set(${LIB_SONAME} PARENT_SCOPE)
  set(${LIB_SOVERSION} PARENT_SCOPE)
endfunction(find_Library_In_Implicit_System_Dir)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Soname_Info_From_Library_Path| replace:: ``get_Soname_Info_From_Library_Path``
#  .. _get_Soname_Info_From_Library_Path:
#
#  get_Soname_Info_From_Library_Path
#  ---------------------------------
#
#   .. command:: get_Soname_Info_From_Library_Path(LIBRARY_PATH LIB_SONAME LIB_SOVERSION library_name full_path)
#
#    Get link info of a library that is supposed to be located in implicit system folders.
#
#     :library_name: the name of the library (without any prefix or suffix specific to system).
#
#     :full_path: the full path to the library file (may be a real soobject or link or a linker script).
#
#     :LIBRARY_PATH: the output variable that contains the full path to library, empty if no path found.
#
#     :LIB_SONAME: the output variable that contains only the name of the library if path has been found, empty otherwise.
#
#     :LIB_SOVERSION: the output variable that contains only the SOVERSION of the library if LIB_SONAME has been found, empty otherwise.
#
function(get_Soname_Info_From_Library_Path LIBRARY_PATH LIB_SONAME LIB_SOVERSION library_name full_path)
  get_Binary_Description(DESCRIPTION ${full_path})
  if(DESCRIPTION)#preceding commands says OK: means the binary is recognized as an adequate shared object
    #getting the SONAME
    get_Soname(SONAME SOVERSION DESCRIPTION)
    set(${LIBRARY_PATH} ${full_path} PARENT_SCOPE)
    set(${LIB_SONAME} ${SONAME} PARENT_SCOPE)
    set(${LIB_SOVERSION} ${SOVERSION} PARENT_SCOPE)
    return()
  else()#here we can check the text content, since the file can be an implicit linker script use as an alias (and more)
    extract_Library_Path_From_Linker_Script(LIB_PATH ${library_name} ${full_path})
    if(LIB_PATH)
      get_Binary_Description(DESCRIPTION ${LIB_PATH})
      if(DESCRIPTION)#preceding commands says OK: means the binary is recognized as an adequate shared object
        #getting the SONAME
        get_Soname(SONAME SOVERSION DESCRIPTION)
        set(${LIBRARY_PATH} ${LIB_PATH} PARENT_SCOPE)
        set(${LIB_SONAME} ${SONAME} PARENT_SCOPE)
        set(${LIB_SOVERSION} ${SOVERSION} PARENT_SCOPE)
        return()
      endif()
    endif()
  endif()
  set(${LIBRARY_PATH} PARENT_SCOPE)
  set(${LIB_SONAME} PARENT_SCOPE)
  set(${LIB_SOVERSION} PARENT_SCOPE)
endfunction(get_Soname_Info_From_Library_Path)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Library_ELF_Symbol_Max_Version| replace:: ``get_Library_ELF_Symbol_Max_Version``
#  .. _get_Library_ELF_Symbol_Max_Version:
#
#  get_Library_ELF_Symbol_Max_Version
#  ----------------------------------
#
#   .. command:: get_Library_ELF_Symbol_Max_Version(MAX_VERSION path_to_library symbol)
#
#    Get the max version for a (supposed to be) versionned symbol of the given library.
#
#     :path_to_library: the library to inspect.
#
#     :symbol: the symbol that is supposed to have a version number. For instance symbol GLIBCXX can be used for libstdc++.so (GNU standard C++ library).
#
#     :MAX_VERSION: the output variable that contains the max version of the target symbol always with major.minor.patch structure.
#
function(get_Library_ELF_Symbol_Max_Version MAX_VERSION path_to_library symbol)
  set(ALL_SYMBOLS)
  usable_In_Regex(usable_symbol ${symbol})
  file(STRINGS ${path_to_library} ALL_SYMBOLS REGEX ".*${usable_symbol}.*")#extract ascii symbols from the library file
  set(max_version "0.0.0")
  foreach(version IN LISTS ALL_SYMBOLS)
    extract_ELF_Symbol_Version(RES_VERSION "${usable_symbol}" ${version})#get the version from each found symbol
    if(RES_VERSION VERSION_GREATER max_version)
      set(max_version ${RES_VERSION})
    endif()
  endforeach()
  if(max_version VERSION_EQUAL "0.0.0")
    set(${MAX_VERSION} PARENT_SCOPE)#no result for that symbol
  endif()
  set(${MAX_VERSION} ${max_version} PARENT_SCOPE)
endfunction(get_Library_ELF_Symbol_Max_Version)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Library_ELF_Symbols_Max_Versions| replace:: ``get_Library_ELF_Symbols_Max_Versions``
#  .. _get_Library_ELF_Symbols_Max_Versions:
#
#  get_Library_ELF_Symbols_Max_Versions
#  -------------------------------------
#
#   .. command:: get_Library_ELF_Symbols_Max_Versions(LIST_OF_SYMBOLS_VERSIONS path_to_library list_of_symbols)
#
#    Get the list of all versions for all given symbols.
#
#     :path_to_library: the library to inspect.
#
#     :list_of_symbols: the symbols whose version must be found.
#
#     :LIST_OF_SYMBOLS_VERSIONS: the output variable that contains the list of pairs (symbol, version).
#
function(get_Library_ELF_Symbols_Max_Versions LIST_OF_SYMBOLS_VERSIONS path_to_library list_of_symbols)
  set(res_symbols_version)
  foreach(symbol IN LISTS list_of_symbols)
    get_Library_ELF_Symbol_Max_Version(MAX_VERSION_FOR_SYMBOL ${path_to_library} ${symbol})
    if(MAX_VERSION_FOR_SYMBOL)# version exists for that symbol
			list(APPEND res_symbols_version "${symbol}" "${MAX_VERSION_FOR_SYMBOL}")
		endif()
  endforeach()
  set(${LIST_OF_SYMBOLS_VERSIONS} ${res_symbols_version} PARENT_SCOPE)
endfunction(get_Library_ELF_Symbols_Max_Versions)

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
#    If the platform description has changed then clean and launch the reconfiguration of the delpoyment unit.
#
#     :build_folder: the path to the package build_folder.
#
#     :type: type of the deployment unit (NATIVE, EXTERNAL, FRAMEWORK, ENVIRONMENT)
#
macro(manage_Current_Platform build_folder type)
	if(build_folder STREQUAL "build")
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
      set(TEMP_CXX_STD_SYMBOLS ${CXX_STD_SYMBOLS})
      foreach(symbol IN LISTS TEMP_CXX_STD_SYMBOLS)
        set(TEMP_CXX_STD_SYMBOL_${symbol}_VERSION ${CXX_STD_SYMBOL_${symbol}_VERSION})
      endforeach()
		endif()
	endif()
  load_Current_Platform()
	if(build_folder STREQUAL "build")
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
        if(type STREQUAL "NATIVE")
  				hard_Clean_Package_Debug(${PROJECT_NAME})
  				hard_Clean_Package_Release(${PROJECT_NAME})
  				reconfigure_Package_Build_Debug(${PROJECT_NAME})#force reconfigure before running the build
  				reconfigure_Package_Build_Release(${PROJECT_NAME})#force reconfigure before running the build
        elseif(type STREQUAL "EXTERNAL")
          hard_Clean_Wrapper(${PROJECT_NAME})
      		reconfigure_Wrapper_Build(${PROJECT_NAME})
        elseif(type STREQUAL "FRAMEWORK")
          hard_Clean_Framework(${PROJECT_NAME})
      		reconfigure_Framework_Build(${PROJECT_NAME})
        endif()
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
macro(load_Current_Platform)
#loading contribution spaces in use
load_Current_Contribution_Spaces()
#loading global profile config file to decide which profile is in use
load_Profile_Info()
#loading the current platform configuration simply consists in including the config file generated by the workspace
include(${WORKSPACE_DIR}/pid/${CURRENT_PROFILE}/Workspace_Platforms_Info.cmake)
set_Project_Module_Path_From_Workspace()
endmacro(load_Current_Platform)

#.rst:
#
# .. ifmode:: internal
#
#  .. |load_Current_Contribution_Spaces| replace:: ``load_Current_Contribution_Spaces``
#  .. _load_Current_Contribution_Spaces:
#
#  load_Current_Contribution_Spaces
#  --------------------------------
#
#   .. command:: load_Current_Contribution_Spaces()
#
#    Load the contributions currently in use in the workspace into current process context.
#
macro(load_Current_Contribution_Spaces)
#loading the current platform configuration simply consists in including the config file generated by the workspace
include(${WORKSPACE_DIR}/pid/Workspace_Contribution_Spaces.cmake)
set_Project_Module_Path_From_Workspace()
endmacro(load_Current_Contribution_Spaces)

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
    foreach(param IN LISTS ${config}_OPTIONAL_CONSTRAINTS)
      unset(${config}_${param} CACHE)
    endforeach()
    unset(${config}_OPTIONAL_CONSTRAINTS CACHE)
    foreach(param IN LISTS ${config}_REQUIRED_CONSTRAINTS)
      unset(${config}_${param} CACHE)
    endforeach()
    unset(${config}_REQUIRED_CONSTRAINTS CACHE)
    foreach(param IN LISTS ${config}_IN_BINARY_CONSTRAINTS)
      unset(${config}_${param} CACHE)
    endforeach()
    unset(${config}_IN_BINARY_CONSTRAINTS CACHE)
    unset(${PROJECT_NAME}_PLATFORM_CONFIGURATION_${config}_ARGS${USE_MODE_SUFFIX} CACHE)#reset arguments if any
  endforeach()
	unset(${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX} CACHE)
endfunction(reset_Package_Platforms_Variables)


#.rst:
#
# .. ifmode:: internal
#
#  .. |test_Soname_Compatibility| replace:: ``test_Soname_Compatibility``
#  .. _test_Soname_Compatibility:
#
#  test_Soname_Compatibility
#  --------------------------
#
#   .. command:: test_Soname_Compatibility(COMPATIBLE package_sonames_var platform_sonames_var)
#
#   Test whether the current platform configruation fulfills SONAMES required by a package configuration.
#
#     :package_sonames_var: the variable containing the list of sonames directly required by a configuration.
#
#     :platform_sonames_var: the variable that contains sonames provided by the platform.
#
#     :COMPATIBLE: the output variable that is TRUE if package configuration is satisfied by current platform.
#
function(test_Soname_Compatibility COMPATIBLE package_sonames_var platform_sonames_var)
  set(${COMPATIBLE} FALSE PARENT_SCOPE)
  #simply check that for each soname this soname exists in current platform
  foreach(package_lib IN LISTS ${package_sonames_var})#for each library coming from the binary package
    set(LIB_SONAME_FOUND FALSE)
    foreach(platform_lib IN LISTS ${platform_sonames_var})#searching the corresponding library coming from current platform
      if(platform_lib STREQUAL package_lib)#found
          set(LIB_SONAME_FOUND TRUE)
          break()
      endif()
    endforeach()
    if(NOT LIB_SONAME_FOUND)
      return()
    endif()
  endforeach()
  set(${COMPATIBLE} TRUE PARENT_SCOPE)
endfunction(test_Soname_Compatibility)


#.rst:
#
# .. ifmode:: internal
#
#  .. |serialize_Symbol| replace:: ``serialize_Symbol``
#  .. _serialize_Symbol:
#
#  serialize_Symbol
#  ----------------
#
#   .. command:: serialize_Symbol(RET_STR symbol version)
#
#   Serialize a symbol version into a string..
#
#     :symbol: the symbol name.
#
#     :version: the symbol version.
#
#     :RET_STR: the string output variable that contains the serialized symbol version.
#
function(serialize_Symbol RET_STR symbol version)
set(${RET_STR} "<${symbol}/${version}>" PARENT_SCOPE)
endfunction(serialize_Symbol)



#.rst:
#
# .. ifmode:: internal
#
#  .. |deserialize_Symbol| replace:: ``deserialize_Symbol``
#  .. _deserialize_Symbol:
#
#  deserialize_Symbol
#  ------------------
#
#   .. command:: deserialize_Symbol(RET_STR symbol version)
#
#   Deerialize a symbol name and from a string. Inverse operation of serialize_Symbol.
#
#     :symbol_str: the serialized symbol.
#
#     :RET_SYMBOL: the output variable that contains the symbol name.
#
#     :RET_VERSION: the output variable that contains the symbol version.
#
function(deserialize_Symbol RET_SYMBOL RET_VERSION symbol_str)
  if(symbol_str MATCHES "^<([^/]+)/([^>]+)>$")
    set(${RET_SYMBOL} ${CMAKE_MATCH_1} PARENT_SCOPE)
    set(${RET_VERSION} ${CMAKE_MATCH_2} PARENT_SCOPE)
  else()
    set(${RET_SYMBOL} PARENT_SCOPE)
    set(${RET_VERSION} PARENT_SCOPE)
  endif()
endfunction(deserialize_Symbol)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Platform_Provides_Compatible_Symbol| replace:: ``check_Platform_Provides_Compatible_Symbol``
#  .. _check_Platform_Provides_Compatible_Symbol:
#
#  check_Platform_Provides_Compatible_Symbol
#  -----------------------------------------
#
#   .. command:: check_Platform_Provides_Compatible_Symbol(COMPATIBLE package_symbol platform_symbols_var)
#
#   Test whether the current platform configruation provide symbols compatible with those required by a package configuration.
#
#     :package_sonames_var: the variable containing the list of symbols directly required by a configuration.
#
#     :platform_sonames_var: the variable that contains the list of symbols provided by the platform.
#
#     :COMPATIBLE: the output variable that is TRUE if package configuration is satisfied by current platform.
#
function(check_Platform_Provides_Compatible_Symbol COMPATIBLE package_symbol platform_symbols_var)
  set(${COMPATIBLE} FALSE PARENT_SCOPE)
  deserialize_Symbol(PACK_SYMBOL PACK_VERSION ${package_symbol})
  set(FOUND FALSE)
  foreach(platform_symbol IN LISTS ${platform_symbols_var})
    deserialize_Symbol(PLAT_SYMBOL PLAT_VERSION ${platform_symbol})
    if(PACK_SYMBOL STREQUAL PLAT_SYMBOL)# this is the symbol to check
      if(NOT PLAT_VERSION VERSION_LESS PACK_VERSION)
        set(${COMPATIBLE} TRUE PARENT_SCOPE)
      endif()
      return()
    endif()
  endforeach()
endfunction(check_Platform_Provides_Compatible_Symbol)

#.rst:
#
# .. ifmode:: internal
#
#  .. |test_Symbols_Compatibility| replace:: ``test_Symbols_Compatibility``
#  .. _test_Symbols_Compatibility:
#
#  test_Symbols_Compatibility
#  --------------------------
#
#   .. command:: test_Symbols_Compatibility(COMPATIBLE package_symbols_var platform_symbols_var)
#
#   Test whether the current platform configruation provide symbols compatible with those required by a package configuration.
#
#     :package_symbols_var: the variable containing the list of symbols directly required by a configuration.
#
#     :platform_symbols_var: the variable that contains the list of symbols provided by the platform.
#
#     :COMPATIBLE: the output variable that is TRUE if package configuration is satisfied by current platform.
#
function(test_Symbols_Compatibility COMPATIBLE package_symbols_var platform_symbols_var)
  set(${COMPATIBLE} FALSE PARENT_SCOPE)
  foreach(package_symbol IN LISTS ${package_symbols_var})
    check_Platform_Provides_Compatible_Symbol(SYMBOL_COMPATIBLE ${package_symbol} ${platform_symbols_var})
    if(NOT SYMBOL_COMPATIBLE)
      return()
    endif()
  endforeach()
  set(${COMPATIBLE} TRUE PARENT_SCOPE)
endfunction(test_Symbols_Compatibility)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Soname_Symbols_Values| replace:: ``get_Soname_Symbols_Values``
#  .. _get_Soname_Symbols_Values:
#
#  get_Soname_Symbols_Values
#  --------------------------
#
#   .. command:: get_Soname_Symbols_Values(SONAME SYMBOLS binary_config_args_var)
#
#   Get Sonames and symbols required by the libraries coming from a configuration.
#
#     :binary_config_args_var: the variable containing the list if arguments of a configuration.
#
#     :SONAME: the output variable that contains sonames required by the configuration.
#
#     :SYMBOLS: the output variable that contains symbols required by the configuration.
#
function(get_Soname_Symbols_Values SONAME SYMBOLS binary_config_args_var)
  set(${SONAME} PARENT_SCOPE)
  set(${SYMBOLS} PARENT_SCOPE)

  set(var_val_pair_list ${${binary_config_args_var}})
  #only get symbols and soname
  set(ALREADY_DONE 0)
  while(var_val_pair_list)
    list(GET var_val_pair_list 0 name)
    list(GET var_val_pair_list 1 value)
    list(REMOVE_AT var_val_pair_list 0 1)#update the list of arguments in parent scope
    if( name STREQUAL "soname"
        OR name STREQUAL "symbols")#only check for soname and symbols compatibility if any

      if(value AND NOT value STREQUAL \"\")#special case of an empty list (represented with \"\") must be avoided
        string(REPLACE " " "" VAL_LIST ${value})#remove the spaces in the string if any
        string(REPLACE "," ";" VAL_LIST ${VAL_LIST})#generate a cmake list (with ";" as delimiter) from an argument list (with "," delimiter)
      else()
        set(VAL_LIST)
      endif()
      math(EXPR ALREADY_DONE "${ALREADY_DONE}+1")
      if(VAL_LIST)#ensure there is a value
        if(name STREQUAL "soname")
          set(${SONAME} ${VAL_LIST} PARENT_SCOPE)
        else()
          set(${SYMBOLS} ${VAL_LIST} PARENT_SCOPE)
        endif()
      endif()
    endif()
    if(ALREADY_DONE EQUAL 2)#just to optimize a bit
      return()
    endif()
  endwhile()
endfunction(get_Soname_Symbols_Values)

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
#     :mode: the considered build mode.
#
#     :COMPATIBLE: the output variable that is TRUE if package's stdlib usage is compatible with current platform ABI, FALSE otherwise.
#
function(is_Compatible_With_Current_ABI COMPATIBLE package mode)
  set(${COMPATIBLE} FALSE PARENT_SCOPE)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

  # testing for languages standard libraries SO versions and symbols
  foreach(lang IN LISTS ${package}_LANGUAGE_CONFIGURATIONS${VAR_SUFFIX})#for each symbol used by the binary
    parse_Configuration_Expression_Arguments(PACKAGE_SPECS ${package}_LANGUAGE_CONFIGURATION_${lang}_ARGS${VAR_SUFFIX})
    #get SONAME and SYMBOLS coming from language configuration
    #WARNING Note: use same arguments as binary (soname and symbol are not used to directly check validaity of the configuration) !!
    check_Language_Configuration_With_Arguments(SYSCHECK_RESULT PLATFORM_SPECS ${lang} PACKAGE_SPECS ${mode})
    get_Soname_Symbols_Values(PLATFORM_SONAME PLATFORM_SYMBOLS PLATFORM_SPECS)

    #get SONAME and SYMBOLS coming from package configuration
    get_Soname_Symbols_Values(PACKAGE_SONAME PACKAGE_SYMBOLS PACKAGE_SPECS)

    #from here we have the value to compare with
    if(PACKAGE_SONAME)#package defines constraints on SONAMES
      test_Soname_Compatibility(SONAME_COMPATIBLE PACKAGE_SONAME PLATFORM_SONAME)
      if(NOT SONAME_COMPATIBLE)
        if(ADDITIONNAL_DEBUG_INFO)
          message("[PID] WARNING: standard libraries for language ${lang} have an incompatible soname (${PLATFORM_SONAME}) with those used to build package ${package} (${PACKAGE_SONAME})")
        endif()
        return()
      endif()
    endif()
    if(PACKAGE_SYMBOLS)#package defines constraints on SYMBOLS
      test_Symbols_Compatibility(SYMBOLS_COMPATIBLE PACKAGE_SYMBOLS PLATFORM_SYMBOLS)
      if(NOT SYMBOLS_COMPATIBLE)
        if(ADDITIONNAL_DEBUG_INFO)
          message("[PID] WARNING: standard libraries symbols for language ${lang} have incompatible versions (${PLATFORM_SYMBOLS}) with those used to build package ${package} (${PACKAGE_SYMBOLS})")
        endif()
        return()
      endif()
    endif()
  endforeach()

  # testing sonames and symbols of libraries coming from platform configurations used by package
  foreach(config IN LISTS ${package}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX})#for each symbol used by the binary
    parse_Configuration_Expression_Arguments(PACKAGE_SPECS ${package}_PLATFORM_CONFIGURATION_${config}_ARGS${VAR_SUFFIX})
    #get SONAME and SYMBOLS coming from platform configuration
    #WARNING Note: use same arguments as binary !!
    check_Platform_Configuration_With_Arguments(SYSCHECK_RESULT PLATFORM_SPECS ${config} PACKAGE_SPECS ${mode})
    get_Soname_Symbols_Values(PLATFORM_SONAME PLATFORM_SYMBOLS PLATFORM_SPECS)

    #get SONAME and SYMBOLS coming from package configuration
    get_Soname_Symbols_Values(PACKAGE_SONAME PACKAGE_SYMBOLS PACKAGE_SPECS)

    #from here we have the value to compare with
    if(PACKAGE_SONAME)#package defines constraints on SONAMES
      test_Soname_Compatibility(SONAME_COMPATIBLE PACKAGE_SONAME PLATFORM_SONAME)
      if(NOT SONAME_COMPATIBLE)
        if(ADDITIONNAL_DEBUG_INFO)
          message("[PID] WARNING: libraries provided by current configuration ${config} have an incompatible soname (${PLATFORM_SONAME}) with those used to build package ${package} (${PACKAGE_SONAME})")
        endif()
        return()
      endif()
    endif()
    if(PACKAGE_SYMBOLS)#package defines constraints on SYMBOLS
      test_Symbols_Compatibility(SYMBOLS_COMPATIBLE PACKAGE_SYMBOLS PLATFORM_SYMBOLS)
      if(NOT SYMBOLS_COMPATIBLE)
        if(ADDITIONNAL_DEBUG_INFO)
          message("[PID] WARNING: symbols provided by current configuration ${config} have incompatible versions (${PLATFORM_SYMBOLS}) with those used to build package ${package} (${PACKAGE_SYMBOLS})")
        endif()
        return()
      endif()
    endif()
  endforeach()
  set(${COMPATIBLE} TRUE PARENT_SCOPE)
endfunction(is_Compatible_With_Current_ABI)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Platform_Configuration_Expression_For_Dependency| replace:: ``generate_Platform_Configuration_Expression_For_Dependency``
#  .. _generate_Platform_Configuration_Expression_For_Dependency:
#
#  generate_Platform_Configuration_Expression_For_Dependency
#  ---------------------------------------------------------
#
#   .. command:: generate_Platform_Configuration_Expression_For_Dependency(RESULTING_EXPRESSION config)
#
#     Generate an expression (string) that describes the configuration checks neeed to manage dependencies of a given configuration.
#
#     :config: the name of the system configuration.
#
#     :RESULTING_EXPRESSION: the input/output variable containing the configuration check equivalent expression.
#
#     :RESULTING_CONFIG: the input/output variable containing the list of configuration names already managed.
#
function(generate_Platform_Configuration_Expression_For_Dependency RESULTING_EXPRESSION RESULTING_CONFIG_LIST config)
  if(${config}_CONFIGURATION_DEPENDENCIES_IN_BINARY)
      set(temp_list_of_config_written ${${RESULTING_CONFIG_LIST}})
    set(temp_list_of_expressions_written ${${RESULTING_EXPRESSION}})
    foreach(dep_conf IN LISTS ${config}_CONFIGURATION_DEPENDENCIES_IN_BINARY)
      list(FIND temp_list_of_config_written ${dep_conf} INDEX)
      if(INDEX EQUAL -1)#not already written !!
        list(APPEND temp_list_of_config_written ${dep_conf})
        if(${dep_conf}_CONSTRAINTS_IN_BINARY)
          set(gen_constraint "${dep_conf}[")
          set(first_constraint_written FALSE)
          foreach(constraint IN LISTS ${dep_conf}_CONSTRAINTS_IN_BINARY)
            if(first_constraint_written)
              set(gen_constraint ":${gen_constraint}")
            endif()
            set(gen_constraint "${gen_constraint}${constraint}")
            set(first_constraint_written TRUE)
          endforeach()
          set(gen_constraint "${gen_constraint}]")
          list(APPEND temp_list_of_expressions_written "${gen_constraint}")
        else()
          list(APPEND temp_list_of_expressions_written ${dep_conf})
        endif()
        #recursion to manage dependencies of dependencies (and so on)
        generate_Platform_Configuration_Expression_For_Dependency(temp_list_of_expressions_written temp_list_of_config_written ${dep_conf})
      endif()
    endforeach()
    set(${RESULTING_EXPRESSION} ${temp_list_of_expressions_written} PARENT_SCOPE)
    set(${RESULTING_CONFIG_LIST} ${temp_list_of_config_written} PARENT_SCOPE)
  endif()
endfunction(generate_Platform_Configuration_Expression_For_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Platform_Configuration| replace:: ``check_Platform_Configuration``
#  .. _check_Platform_Configuration:
#
#  check_Platform_Configuration
#  ----------------------------
#
#   .. command:: check_Platform_Configuration(RESULT NAME CONSTRAINTS config mode)
#
#    Check whether the given configuration constraint (= configruation name + arguments) conforms to target platform. This function is used in source scripts.
#
#     :config: the configuration expression (may contain arguments).
#
#     :mode: the current build mode.
#
#     :RESULT: the output variable that is TRUE configuration constraints is satisfied by current platform.
#
#     :NAME: the output variable that contains the name of the configuration without arguments.
#
#     :CONSTRAINTS: the output variable that contains the constraints that applmy to the configuration once used. It includes arguments (constraints imposed by user) and generated contraints (constraints automatically defined by the configuration itself once used).
#
function(check_Platform_Configuration RESULT NAME CONSTRAINTS config mode)
  parse_Configuration_Expression(CONFIG_NAME CONFIG_ARGS "${config}")
  if(NOT CONFIG_NAME)
    set(${NAME} PARENT_SCOPE)
    set(${CONSTRAINTS} PARENT_SCOPE)
    set(${RESULT} FALSE PARENT_SCOPE)
    message("[PID] CRITICAL ERROR : configuration check ${config} is ill formed.")
    return()
  endif()
  check_Platform_Configuration_With_Arguments(RESULT_WITH_ARGS BINARY_CONSTRAINTS ${CONFIG_NAME} CONFIG_ARGS ${mode})
  set(${NAME} ${CONFIG_NAME} PARENT_SCOPE)
  set(${RESULT} ${RESULT_WITH_ARGS} PARENT_SCOPE)
  # last step consist in generating adequate expressions for constraints
  generate_Configuration_Expression_Parameters(LIST_OF_CONSTRAINTS ${CONFIG_NAME} "${BINARY_CONSTRAINTS}")
  set(${CONSTRAINTS} ${LIST_OF_CONSTRAINTS} PARENT_SCOPE)
endfunction(check_Platform_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Platform_Configuration_With_Arguments| replace:: ``check_Platform_Configuration_With_Arguments``
#  .. _check_Platform_Configuration_With_Arguments:
#
#  check_Platform_Configuration_With_Arguments
#  -------------------------------------------
#
#   .. command:: check_Platform_Configuration_With_Arguments(CHECK_OK BINARY_CONTRAINTS config_name config_args mode)
#
#    Check whether the given configuration constraint (= configruation name + arguments) conforms to target platform.
#
#     :config_name: the name of the configuration (without argument).
#
#     :config_args: the constraints passed as arguments by the user of the configuration.
#
#     :mode: the current build mode.
#
#     :CHECK_OK: the output variable that is TRUE configuration constraints is satisfied by current platform.
#
#     :BINARY_CONTRAINTS: the output variable that contains the list of all parameter (constraints coming from argument or generated by the configuration itself) to use whenever the configuration is used.
#
function(check_Platform_Configuration_With_Arguments CHECK_OK BINARY_CONTRAINTS config_name config_args mode)
  set(${BINARY_CONTRAINTS} PARENT_SCOPE)
  set(${CHECK_OK} FALSE PARENT_SCOPE)

  install_System_Configuration_Check(PATH_TO_CONFIG ${config_name})
  if(NOT PATH_TO_CONFIG)
    message(WARNING "[PID] ERROR : when checking if system configuration ${config_name} is possibly usable on current platform. Please either : remove the constraint ${config_name}; check that ${config_name} is well spelled and rename it if necessary; contact developpers of wrapper ${config_name} to solve the problem, create a new wrapper called ${config_name} or configure your workspace with the contribution space referencing the wrapper of ${config_name}.")
    return()
  endif()
  #check if the configuration has already been checked
  check_Configuration_Temporary_Optimization_Variables(RES_CHECK RES_CONSTRAINTS ${config_name} ${mode})
  if(RES_CHECK)
    if(${config_args})#testing if the variable containing arguments is not empty
      #in this situation we need to check if all args match constraints
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
  reset_Platform_Configuration_Cache_Variables(${config_name}) #reset the output variables to ensure a good result
  include(${PATH_TO_CONFIG}/check_${config_name}.cmake)#get the description of the configuration check
  #now preparing args passed to the configruation (generate cmake variables)
  set(possible_args ${${config_name}_REQUIRED_CONSTRAINTS} ${${config_name}_OPTIONAL_CONSTRAINTS} ${${config_name}_IN_BINARY_CONSTRAINTS})
  if(possible_args)
    list(REMOVE_DUPLICATES possible_args)
    prepare_Configuration_Expression_Arguments(${config_name} ${config_args} possible_args)#setting variables that correspond to the arguments passed to the check script
  endif()

  check_Platform_Configuration_Arguments(ARGS_TO_SET ${config_name})
  if(ARGS_TO_SET)#there are unset required arguments
    fill_String_From_List(ARGS_TO_SET RES_STRING)
    message("[PID] WARNING : when checking arguments of configuration ${config_name}, there are required arguments that are not set : ${RES_STRING}")
    return()
  endif()

  evaluate_Platform_Configuration(${config_name} ${PATH_TO_CONFIG})
  set(${config_name}_AVAILABLE TRUE CACHE INTERNAL "")
  if(NOT ${config_name}_CONFIG_FOUND)
  	install_Platform_Configuration(${config_name} ${PATH_TO_CONFIG})
  	if(NOT ${config_name}_INSTALLED)
      set(${config_name}_AVAILABLE FALSE CACHE INTERNAL "")
    endif()
  endif()
  if(NOT ${config_name}_AVAILABLE)#configuration is not available so we cannot generate output variables
    set_Configuration_Temporary_Optimization_Variables(${config_name} ${mode} FALSE "")
    return()
  endif()

  # checking dependencies
  set(dep_configurations)
  foreach(check IN LISTS ${config_name}_CONFIGURATION_DEPENDENCIES)
    check_Platform_Configuration(RESULT_OK CONFIG_NAME CONFIG_CONSTRAINTS ${check} ${mode})#check that dependencies are OK
    if(NOT RESULT_OK)
      message("[PID] WARNING : when checking configuration of current platform, configuration ${check}, used by ${config_name} cannot be satisfied.")
      set_Configuration_Temporary_Optimization_Variables(${config_name} ${mode} FALSE "")
      return()
    endif()
    #here need to manage resulting binary contraints
    append_Unique_In_Cache(${config_name}_CONFIGURATION_DEPENDENCIES_IN_BINARY ${CONFIG_NAME})
    append_Unique_In_Cache(${CONFIG_NAME}_CONSTRAINTS_IN_BINARY "${CONFIG_CONSTRAINTS}")
  endforeach()

  #extracting variables to make them usable in calling context
  extract_Platform_Configuration_Resulting_Variables(${config_name})

  #now enforce constraint of using the OS variant of an external package
  # predefine the use of the external package version with its os variant
  # no other choice to ensure compatibility with any package using this external package
  set(${config_name}_VERSION_STRING ${${config_name}_VERSION} CACHE INTERNAL "")
  set(${config_name}_REQUIRED_VERSION_EXACT ${${config_name}_VERSION} CACHE INTERNAL "")
  set(${config_name}_REQUIRED_VERSION_SYSTEM TRUE CACHE INTERNAL "")
  add_Chosen_Package_Version_In_Current_Process(${config_name})#force the use of an os variant

  #return the complete set of binary contraints
  set(bin_constraints ${${config_name}_REQUIRED_CONSTRAINTS} ${${config_name}_IN_BINARY_CONSTRAINTS})
  get_Configuration_Expression_Resulting_Constraints(ALL_CONSTRAINTS ${config_name} bin_constraints)
  set(${BINARY_CONTRAINTS} ${ALL_CONSTRAINTS} PARENT_SCOPE)#automatic appending constraints generated by the configuration itself for the given binary package generated
  set(${CHECK_OK} TRUE PARENT_SCOPE)
  set_Configuration_Temporary_Optimization_Variables(${config_name} ${mode} TRUE "${ALL_CONSTRAINTS}")
endfunction(check_Platform_Configuration_With_Arguments)

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
#  .. |is_Allowed_Platform_Configuration| replace:: ``is_Allowed_Platform_Configuration``
#  .. _is_Allowed_Platform_Configuration:
#
#  is_Allowed_Platform_Configuration
#  ---------------------------------
#
#   .. command:: is_Allowed_Platform_Configuration(ALLOWED config_name config_args)
#
#    Test if a configuration can be used with current platform.
#
#     :config_name: the name of the configuration (without argument).
#
#     :config_args: the constraints passed as arguments by the user of the configuration.
#
#     :ALLOWED: the output variable that is TRUE if configuration can be used.
#
function(is_Allowed_Platform_Configuration ALLOWED config_name config_args)
  set(${ALLOWED} FALSE PARENT_SCOPE)
  install_System_Configuration_Check(PATH_TO_CONFIG ${config_name})
  if(NOT PATH_TO_CONFIG)
    message(WARNING "[PID] ERROR : when checking if system configuration ${config_name} is possibly usable on current platform, configuration cannot be found in currenlty installed contribution spaces. Please either : remove the constraint ${config_name}; check that ${config_name} is well spelled and rename it if necessary; contact developpers of wrapper ${config_name} to solve the problem, create a new wrapper called ${config_name} or configure your workspace with the contribution space referencing the wrapper of ${config_name}.")
    return()
  endif()

  reset_Platform_Configuration_Cache_Variables(${config_name}) #reset the output variables to ensure a good result
  include(${PATH_TO_CONFIG}/check_${config_name}.cmake)#get the description of the configuration check

  #now preparing args passed to the configruation (generate cmake variables)
  set(possible_args ${${config_name}_OPTIONAL_CONSTRAINTS} ${${config_name}_OPTIONAL_CONSTRAINTS} ${${config_name}_IN_BINARY_CONSTRAINTS})
  if(possible_args)
    list(REMOVE_DUPLICATES all_constraints)
    prepare_Configuration_Expression_Arguments(${config_name} ${config_args} possible_args)#setting variables that correspond to the arguments passed to the check script
  endif()

  check_Platform_Configuration_Arguments(ARGS_TO_SET ${config_name})
  if(ARGS_TO_SET)#there are unset required arguments
    fill_String_From_List(ARGS_TO_SET RES_STRING)
    message("[PID] WARNING : when testing arguments of configuration ${config_name}, there are required arguments that are not set : ${RES_STRING}")
    return()
  endif()

  # checking dependencies first
  foreach(check IN LISTS ${config_name}_CONFIGURATION_DEPENDENCIES)
    parse_Configuration_Expression(CONFIG_NAME CONFIG_ARGS "${check}")
    if(NOT CONFIG_NAME)
      return()
    endif()
    is_Allowed_Platform_Configuration(DEP_ALLOWED CONFIG_NAME CONFIG_ARGS)
    if(NOT DEP_ALLOWED)
      return()
    endif()
  endforeach()

  evaluate_Platform_Configuration(${config_name} ${PATH_TO_CONFIG}) # find the artifacts used by this configuration
  if(NOT ${config_name}_CONFIG_FOUND)# not found, trying to see if it can be installed
    is_Platform_Configuration_Installable(INSTALLABLE ${config_name} ${PATH_TO_CONFIG})
    if(NOT INSTALLABLE)
        return()
    endif()
  endif()
  set(${ALLOWED} TRUE PARENT_SCOPE)
endfunction(is_Allowed_Platform_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |evaluate_Platform_Configuration| replace:: ``evaluate_Platform_Configuration``
#  .. _evaluate_Platform_Configuration:
#
#  evaluate_Platform_Configuration
#  -------------------------------
#
#   .. command:: evaluate_Platform_Configuration(config path_to_config)
#
#   Call the procedure for finding artefacts related to a configuration. Set the ${config}_FOUND variable, that is TRUE is configuration has been found, FALSE otherwise.
#
#     :config: the name of the configuration to find.
#
#     :path_to_config: the path to configuration folder.
#
macro(evaluate_Platform_Configuration config path_to_config)
  # finding artifacts to fulfill system configuration
  set(${config}_CONFIG_FOUND FALSE)
  set(eval_file ${path_to_config}/${${config}_EVAL_FILE})
  set(check_file ${path_to_config}/check_${config}.cmake)#used only to know if regeneration is required
  set(eval_project_file ${path_to_config}/CMakeLists.txt)
  set(eval_result_config_file ${path_to_config}/output_vars.cmake.in)
  set(eval_result_file ${path_to_config}/output_vars.cmake)
  set(eval_folder ${path_to_config}/build)
  set(eval_languages C CXX)
  foreach(lang IN LISTS ${config}_EVAL_LANGUAGES)
    if(${lang}_Language_AVAILABLE)
      list(APPEND eval_languages ${lang})
    endif()
  endforeach()

  #preliminary checks for evaluation
  if(NOT EXISTS ${eval_file})
    message(ERROR "[PID] ERROR : system configuration check for package ${config} has no evaluation file. Evaluation aborted on error.")
    return()
  endif()
  foreach(content IN LISTS ${config}_EVAL_ADDITIONAL_CONTENT)
    if(NOT EXISTS ${path_to_config}/${content})
      message(ERROR "[PID] ERROR : when evaluating system configuration package ${config}, evaluation content ${content} not fond in ${path_to_config}/${content}. Evaluation aborted on error !")
      return()
    endif()
  endforeach()
  foreach(file IN LISTS ${config}_USE_FILES)
    if(NOT EXISTS ${path_to_config}/${file})
      message(ERROR "[PID] ERROR : when evaluating system configuration package ${config}, CMake file ${path_to_config}/${file} not found. Evaluation aborted on error !")
      return()
    endif()
  endforeach()

  #prepare CMake project used for evaluation
  if(NOT EXISTS ${eval_folder})#create the build folder used for evaluation
    file(MAKE_DIRECTORY ${eval_folder})
  endif()

  if(${check_file} IS_NEWER_THAN ${eval_project_file})# only regenerate the project file if check file has changed (project regenerated)
    file(GLOB eval_build_files "${eval_folder}/*")#clean the eval project subfolder when necessary
    if(eval_build_files)
      file(REMOVE_RECURSE ${eval_build_files})
    endif()
    file(WRITE ${eval_project_file} "cmake_minimum_required(VERSION 3.0.2)\n")
    file(APPEND ${eval_project_file} "set(WORKSPACE_DIR ${WORKSPACE_DIR} CACHE PATH \"root of the PID workspace\")\n")
    file(APPEND ${eval_project_file} "list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake)\n")
    file(APPEND ${eval_project_file} "include(Configuration_Definition NO_POLICY_SCOPE)\n")
    file(APPEND ${eval_project_file} "project(test_${config} ${eval_languages})\n")
    file(APPEND ${eval_project_file} "list(APPEND CMAKE_MODULE_PATH \${CMAKE_SOURCE_DIR})\n")
    file(APPEND ${eval_project_file} "include(${eval_file})\n")
    file(APPEND ${eval_project_file} "configure_file(${eval_result_config_file} ${eval_result_file} @ONLY)")
  endif()
  #prepare CMake project pattern file used used for getting result
  if(NOT EXISTS ${eval_result_config_file})
    set(eval_vars)#getting all meaningfull variables returned from the eval script
    foreach(var IN LISTS ${config}_RETURNED_VARIABLES)
      list(APPEND eval_vars ${${config}_${var}_RETURNED_VARIABLE})#getting name of each returned variable
    endforeach()
    foreach(var IN LISTS ${config}_IN_BINARY_CONSTRAINTS)
      list(APPEND eval_vars ${${config}_${var}_BINARY_VALUE})#getting name of each variable used in "required in binary constraint"
    endforeach()
    if(eval_vars)
      list(REMOVE_DUPLICATES eval_vars)
    endif()
    file(WRITE ${eval_result_config_file} "set(${config}_CONFIG_FOUND \@${config}_CONFIG_FOUND\@)\n")
    foreach(var IN LISTS eval_vars)
      file(APPEND ${eval_result_config_file} "set(${var} @${var}@)\n")#the output file will contain value of variables generated by the eval script
    endforeach()
    unset(eval_vars)
  endif()

  #launch evaluation
  #1) prepare argument as CMake definitions
  set(calling_defs "")
  foreach(arg IN LISTS ${config}_arguments)
    set(calling_defs "-D${config}_${arg}=${${config}_${arg}} ${calling_defs}")
  endforeach()
  foreach(arg IN LISTS ${config}_no_arguments)
    set(calling_defs "-U${config}_${arg} ${calling_defs}")
  endforeach()
  if(ADDITIONNAL_DEBUG_INFO)
    set(options)
    set(calling_defs "-DADDITIONNAL_DEBUG_INFO=ON ${calling_defs}")
  else()
    set(options OUTPUT_QUIET ERROR_QUIET)
  endif()

  if(CMAKE_HOST_WIN32)#on a window host path must be resolved
  	separate_arguments(COMMAND_ARGS_AS_LIST WINDOWS_COMMAND "${calling_defs}")
  else()#if not on wondows use a UNIX like command syntax
  	separate_arguments(COMMAND_ARGS_AS_LIST UNIX_COMMAND "${calling_defs}")#always from host perpective
  endif()
  #2) evaluate
  if(EXISTS ${eval_result_file})#remove result file if evaluating again
    file(REMOVE ${eval_result_file})
  endif()
  execute_process(COMMAND ${CMAKE_COMMAND} -DWORKSPACE_DIR=${WORKSPACE_DIR} ${COMMAND_ARGS_AS_LIST} ..
                  WORKING_DIRECTORY ${eval_folder} ${options})
  unset(COMMAND_ARGS_AS_LIST)
  unset(calling_defs)
  #3) get the result
  if(EXISTS ${eval_result_file})
    include(${eval_result_file})#may set ${config}_CONFIG_FOUND to TRUE AND load returned variables
    if(${config}_CONFIG_FOUND)
      foreach(file IN LISTS ${config}_USE_FILES)
        include(${path_to_config}/${file})#directly provide use files to user (so they can use provided function/macro definitions)
      endforeach()
    endif()
  endif()
endmacro(evaluate_Platform_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Platform_Configuration_Installable| replace:: ``is_Platform_Configuration_Installable``
#  .. _is_Platform_Configuration_Installable:
#
#  is_Platform_Configuration_Installable
#  -------------------------------------
#
#   .. command:: is_Platform_Configuration_Installable(INSTALLABLE config path_to_config)
#
#   Call the procedure telling if a configuration can be installed.
#
#     :config: the name of the configuration to install.
#
#     :path_to_config: the path to configuration folder.
#
#     :INSTALLABLE: the output variable that is TRUE is configuartion can be installed, FALSE otherwise.
#
function(is_Platform_Configuration_Installable INSTALLABLE config path_to_config)
  if(${config}_INSTALL_PACKAGES)#there is a simple install procedure based on system packages
    set(${INSTALLABLE} TRUE PARENT_SCOPE)
    return()
  endif()
  if(${config}_INSTALL_PROCEDURE AND EXISTS ${path_to_config}/${${config}_INSTALL_PROCEDURE})#there is an install procedure defined in a cmake script file
    include(Configuration_Definition NO_POLICY_SCOPE)
    set(DO_NOT_INSTALL TRUE)#only evaluate if the system package can be installed, do not proceed
    include(${path_to_config}/${${config}_INSTALL_PROCEDURE})
    if(${config}_CONFIG_INSTALLABLE)
      set(${INSTALLABLE} TRUE PARENT_SCOPE)
      return()
    endif()
  endif()
  set(${INSTALLABLE} FALSE PARENT_SCOPE)
endfunction(is_Platform_Configuration_Installable)

#.rst:
#
# .. ifmode:: internal
#
#  .. |install_Platform_Configuration| replace:: ``install_Platform_Configuration``
#  .. _install_Platform_Configuration:
#
#  install_Platform_Configuration
#  ------------------------------
#
#   .. command:: install_Platform_Configuration(config path_to_config)
#
#   Call the install procedure of a given configuration. Set the ${config}_INSTALLED variable to TRUE if the configuration has been installed on OS.
#
#     :config: the name of the configuration to install.
#
#     :path_to_config: the path to configuration folder.
#
macro(install_Platform_Configuration config path_to_config)
  set(${config}_INSTALLED FALSE)
  is_Platform_Configuration_Installable(INSTALLABLE ${config} ${path_to_config})
  if(INSTALLABLE)
    message("[PID] INFO : installing configuration ${config}...")
    if(${config}_INSTALL_PACKAGES)
      execute_OS_Command(${CURRENT_PACKAGING_SYSTEM_EXE} ${CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS} ${${config}_INSTALL_PACKAGES})
    else()
      include(Configuration_Definition NO_POLICY_SCOPE)
      set(DO_NOT_INSTALL FALSE)# apply installation instructions
      include(${path_to_config}/${${config}_INSTALL_PROCEDURE})
    endif()
    #now evaluate configuration check after install
    evaluate_Platform_Configuration(${config} ${path_to_config})
    if(${config}_CONFIG_FOUND)
      message("[PID] INFO : configuration ${config} installed !")
      set(${config}_INSTALLED TRUE)
    else()
      message("[PID] WARNING : install of configuration ${config} has failed !")
    endif()
  else()
    message("[PID] WARNING : ${config} cannot be installed. Please contact developpers of ${config} wrapper or if you are the developper define an install procedures in ${config} wrapper.")
  endif()
endmacro(install_Platform_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Platform_Configuration_Cache_Variables| replace:: ``reset_Platform_Configuration_Cache_Variables``
#  .. _reset_Platform_Configuration_Cache_Variables:
#
#  reset_Platform_Configuration_Cache_Variables
#  --------------------------------------------
#
#   .. command:: reset_Platform_Configuration_Cache_Variables(config)
#
#   Reset all cache variables relatied to the given configuration
#
#     :config: the name of the configuration to be reset.
#
function(reset_Platform_Configuration_Cache_Variables config)
  set(${config}_EVAL_FILE CACHE INTERNAL "")
  set(${config}_INSTALL_PACKAGES CACHE INTERNAL "")
  set(${config}_INSTALL_PROCEDURE CACHE INTERNAL "")
  set(${config}_REQUIRED_CONSTRAINTS CACHE INTERNAL "")
  set(${config}_OPTIONAL_CONSTRAINTS CACHE INTERNAL "")
  foreach(constraint IN LISTS ${config}_IN_BINARY_CONSTRAINTS)
    set(${config}_${constraint}_BINARY_VALUE CACHE INTERNAL "")
  endforeach()
  set(${config}_IN_BINARY_CONSTRAINTS CACHE INTERNAL "")
  set(${config}_CONFIGURATION_DEPENDENCIES CACHE INTERNAL "")
  foreach(dep_config IN LISTS ${config}_CONFIGURATION_DEPENDENCIES_IN_BINARY)
    reset_Platform_Configuration_Cache_Variables(${dep_config})
  endforeach()
  set(${config}_CONSTRAINTS_IN_BINARY CACHE INTERNAL "")
  set(${config}_CONFIGURATION_DEPENDENCIES_IN_BINARY CACHE INTERNAL "")
endfunction(reset_Platform_Configuration_Cache_Variables)


#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_Platform_Configuration_Resulting_Variables| replace:: ``extract_Platform_Configuration_Resulting_Variables``
#  .. _extract_Platform_Configuration_Resulting_Variables:
#
#  extract_Platform_Configuration_Resulting_Variables
#  --------------------------------------------------
#
#   .. command:: extract_Platform_Configuration_Resulting_Variables(config)
#
#     Get the list of constraints that should apply to a given configuration when used in a binary.
#
#     :config: the name of the configuration to be checked.
#
function(extract_Platform_Configuration_Resulting_Variables config)
  #updating output variables from teh value of variable s specified by PID_Configuration_Variables
  foreach(var IN LISTS ${config}_RETURNED_VARIABLES)
    #the content of ${config}_${var}_RETURNED_VARIABLE is the name of a variable so need to get its value using ${}
    set(${config}_${var} ${${${config}_${var}_RETURNED_VARIABLE}} CACHE INTERNAL "")
  endforeach()
endfunction(extract_Platform_Configuration_Resulting_Variables)


#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Platform_Configuration_Arguments| replace:: ``check_Platform_Configuration_Arguments``
#  .. _check_Platform_Configuration_Arguments:
#
#  check_Platform_Configuration_Arguments
#  --------------------------------------
#
#   .. command:: check_Platform_Configuration_Arguments(ARGS_TO_SET config)
#
#     Check if all required arguments for the configuration are set before checking the configuration.
#
#     :config: the name of the configuration to be checked.
#
#     :ARGS_TO_SET: the parent scope variable containing the list of required arguments that have not been set by user.
#
function(check_Platform_Configuration_Arguments ARGS_TO_SET config)
  set(list_of_args)
  foreach(arg IN LISTS ${config}_REQUIRED_CONSTRAINTS)
    if(NOT ${config}_${arg} AND NOT ${config}_${arg} EQUAL 0 AND NOT ${config}_${arg} STREQUAL "FALSE")
      list(APPEND list_of_args ${arg})
    endif()
  endforeach()
  set(${ARGS_TO_SET} ${list_of_args} PARENT_SCOPE)
endfunction(check_Platform_Configuration_Arguments)
