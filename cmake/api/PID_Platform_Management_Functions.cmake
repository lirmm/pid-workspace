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
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "[PID] INFO: using default profile, based on host native development environment.\n")
  else()
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "[PID] INFO: using ${CURRENT_PROFILE} profile, based on ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT} as main development environment.\n")
    if(${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}_ACTION_INFO)
      string(CONFIGURE "${${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT}_ACTION_INFO}" configured_actions)
      set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION} - ${configured_actions}\n")
    endif()
  endif()
  #printing general properties on languages
  if(CURRENT_ASM_COMPILER)
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO : ASM language available with ${CURRENT_ASM_COMPILER} toolchain.\n")
  else()
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO : ASM language available.\n")
  endif()
  if(CURRENT_C_COMPILER)
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO : C language available with ${CURRENT_C_COMPILER} toolchain (version ${CMAKE_C_COMPILER_VERSION}).\n")
  else()
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO : C language available.\n")
  endif()
  if(CURRENT_CXX_COMPILER)
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO : C++ language available with ${CURRENT_CXX_COMPILER} toolchain (version ${CMAKE_CXX_COMPILER_VERSION}).\n")
  else()
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO : C++ language available.\n")
  endif()
  if(Python_Language_AVAILABLE)
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO : Python language available (version ${CURRENT_PYTHON}")
    if(CURRENT_PYTHON_PACKAGER)
      set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}, ${CURRENT_PYTHON_PACKAGER_EXE} packaging")
    endif()
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}). To use python modules installed in workspace please set the PYTHONPATH to =${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/__python${CURRENT_PYTHON}__\n")

  endif()
  if(CUDA_Language_AVAILABLE)
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO : CUDA language available (version ${CUDA_VERSION}).")
    if(DEFAULT_CUDA_ARCH)
      set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION} Building for architecture ${DEFAULT_CUDA_ARCH}.\n")
    else()
      set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}\n")
    endif()
  endif()
  if(Fortran_Language_AVAILABLE)
    if(CMAKE_Fortran_COMPILER_ID)
      set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO : Fortran language available with ${CMAKE_Fortran_COMPILER_ID} toolchain (version ${CMAKE_Fortran_COMPILER_VERSION}).\n")
    else()
      set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}[PID] INFO : Fortran language available.\n")
    endif()
  endif()


  if(PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS)
    set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION}\n[PID] INFO: additional environments in use:\n")
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
  set(WORKSPACE_CONFIGURATION_DESCRIPTION "${WORKSPACE_CONFIGURATION_DESCRIPTION} + C++ ABI= ${CURRENT_PLATFORM_ABI}\n")

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
	# Now detect the current platform according to host environemnt selection (call to script for platform detection)
	include(CheckTYPE)
	include(CheckARCH)
	include(CheckOS)
	include(CheckSystemPackaging)
	include(CheckDistribution)
	include(CheckCompiler)#only useful for further checking
  include(CheckInstructionSet)
  set(CURRENT_SPECIFIC_INSTRUCTION_SET ${CPU_ALL_AVAILABLE_OPTIMIZATIONS} CACHE INTERNAL "" FORCE)
	include(CheckABI)
  set(CURRENT_PLATFORM_ABI "${CURRENT_CXX_ABI}" CACHE INTERNAL "" FORCE)
  include(CheckLanguage)
	include(CheckPython)
	include(CheckFortran)
	include(CheckCUDA)
  include(CheckDevTools)
  #simply rewriting previously defined variable to normalize their names between workspace and packages (same accessor function can then be used from any place)
  set(CURRENT_PACKAGE_STRING ${CURRENT_PACKAGE_STRING} CACHE INTERNAL "" FORCE)
  set(CURRENT_DISTRIBUTION ${CURRENT_DISTRIBUTION} CACHE INTERNAL "" FORCE)

  if(CURRENT_PLATFORM_OS)#the OS is optional (for microcontrolers there is no OS)
    set(CURRENT_PLATFORM_BASE ${CURRENT_PLATFORM_TYPE}_${CURRENT_PLATFORM_ARCH}_${CURRENT_PLATFORM_OS}_${CURRENT_PLATFORM_ABI} CACHE INTERNAL "" FORCE)
  else()
    set(CURRENT_PLATFORM_BASE ${CURRENT_PLATFORM_TYPE}_${CURRENT_PLATFORM_ARCH}_${CURRENT_PLATFORM_ABI} CACHE INTERNAL "" FORCE)
  endif()

  if(CURRENT_PLATFORM_INSTANCE)
    set(CURRENT_PLATFORM "${CURRENT_PLATFORM_BASE}__${CURRENT_PLATFORM_INSTANCE}__" CACHE INTERNAL "")
  else()
    set(CURRENT_PLATFORM "${CURRENT_PLATFORM_BASE}" CACHE INTERNAL "")
  endif()

  set(PACKAGE_BINARY_INSTALL_DIR ${CMAKE_SOURCE_DIR}/install/${CURRENT_PLATFORM} CACHE INTERNAL "" FORCE)
  set(CURRENT_ENVIRONMENT ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT} CACHE INTERNAL "")
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
  set(options)
  if(CURRENT_PLATFORM_OS MATCHES "linux|freebsd")
    set(options -p)
  elseif(CURRENT_PLATFORM_OS MATCHES "macos")
    set(options --dylib-id -macho)
  endif()
  execute_process(COMMAND ${CMAKE_OBJDUMP} ${options} ${path_to_library}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    ERROR_QUIET
    OUTPUT_VARIABLE OBJECT_CONTENT
    RESULT_VARIABLE res)
  if(res EQUAL 0 AND (NOT OBJECT_CONTENT MATCHES "not an object file"))
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
#     :SOVERSION: the output variable that contains the only the soversion if any, empty otherwise (implies SONAME is not empty).
#
function(get_Soname SONAME SOVERSION library_description)
  set(full_soname)
  set(so_version)
  if(CURRENT_PLATFORM_OS MATCHES "linux|freebsd")
    if(${library_description} MATCHES ".*SONAME[ \t]+([^ \t\n]+)[ \t\n]*")
      set(full_soname ${CMAKE_MATCH_1})
      get_filename_component(extension ${full_soname} EXT)
      if(extension MATCHES "^\\.so\\.([.0-9]+)$")
        set(so_version ${CMAKE_MATCH_1})
      endif()
    endif()
  elseif(CURRENT_PLATFORM_OS MATCHES "macos")
    #need to get the first line of output and extract soname from that
    if(${library_description} MATCHES "^[ \t]*[^ \t\n]+[ \t]*:[^ \t\n]*\n[ \t]*([^ \t\n]+)")
      get_filename_component(VAR_SONAME ${CMAKE_MATCH_1} NAME)
      set(full_soname ${VAR_SONAME})
      get_filename_component(extension ${full_soname} EXT)
      if(extension MATCHES "^\\.([.0-9]+)\\.dylib$")
        set(so_version ${CMAKE_MATCH_1})
      endif()
    endif()
  endif()
  set(${SONAME} ${full_soname} PARENT_SCOPE)#i.e. NO soname
  set(${SOVERSION} ${so_version} PARENT_SCOPE)#i.e. NO soversion by default
endfunction(get_Soname)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Archive_Description| replace:: ``get_Archive_Description``
#  .. _get_Archive_Description:
#
#  get_Archive_Description
#  -----------------------
#
#   .. command:: get_Archive_Description(DESCRITION path_to_library)
#
#    Get the description of a binary archive.
#
#     :path_to_library: the library to inspect.
#
#     :DESCRITION: the output variable that contains the description of the archive (content).
#
function(get_Archive_Description DESCRITION path_to_library)
  #print the table of content
  execute_process(COMMAND ${CMAKE_AR} -t ${path_to_library}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    ERROR_QUIET
    OUTPUT_VARIABLE OBJECT_CONTENT
    RESULT_VARIABLE res)
  if(res EQUAL 0)
    set(${DESCRITION} ${OBJECT_CONTENT} PARENT_SCOPE)
  else()
    set(${DESCRITION} PARENT_SCOPE)
  endif()
endfunction(get_Archive_Description)

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
#     :library_name: the name of the library (without any prefix or postfix specific to system).
#
#     :REAL_PATH: the output variable that contains the full path to library with resolved symlinks, empty if no path found.
#     :LINK_PATH: the output variable that contains the path to library used at link time, empty if no path found.
#     :LIB_SONAME: the output variable that contains the name of the library if path has been found, empty otherwise.
#
function(find_Possible_Library_Path REAL_PATH LINK_PATH LIB_SONAME folder library_name)
  set(${REAL_PATH} PARENT_SCOPE)
  set(${LINK_PATH} PARENT_SCOPE)
  set(${LIB_SONAME} PARENT_SCOPE)
  get_Platform_Related_Binary_Prefix_Suffix(PREFIX EXTENSIONS "SHARED")
  set(prefixed_name ${PREFIX}${library_name})
  file(GLOB POSSIBLE_NAMES RELATIVE ${folder} "${folder}/${prefixed_name}*" )
  if(NOT POSSIBLE_NAMES)
    return()
  endif()
  #first check for the complete name without soversion
  set(possible_path)
  foreach(ext IN LISTS EXTENSIONS)
    list(FIND POSSIBLE_NAMES ${prefixed_name}${ext} INDEX)
    if(NOT INDEX EQUAL -1)#found "as is"
      set(possible_path ${folder}/${prefixed_name}${ext})#direct name has the priority over the others
      break()
    endif()
  endforeach()

  if(NOT possible_path)
    usable_In_Regex(libregex ${library_name})
    foreach(ext IN LISTS EXTENSIONS)
      if(CURRENT_PLATFORM_OS STREQUAL linux OR CURRENT_PLATFORM_OS STREQUAL freebsd)
        set(pattern "^${PREFIX}${libregex}\\${ext}\\.([\\.0-9])+$")
      elseif(CURRENT_PLATFORM_OS STREQUAL macos)
        set(pattern "^${PREFIX}${libregex}\\.([\\.0-9])+\\${ext}$")
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
      if(possible_path)
        break()
      endif()
    endforeach()
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
#     :path_to_linker_script: the file that is possibly a linker script.
#     :is_shared: TRUE if the target is a shared library false otherwise.
#
#     :LIBRARY_PATH: the output variable that contains the path to the real binary if specified in the linker script, empty otherwise.
#
function(extract_Library_Path_From_Linker_Script LIBRARY_PATH library path_to_linker_script is_shared)
    set(${LIBRARY_PATH} PARENT_SCOPE)
    if(is_shared)
      get_Platform_Related_Binary_Prefix_Suffix(PREFIX EXTENSIONS "SHARED")
    else()
      get_Platform_Related_Binary_Prefix_Suffix(PREFIX EXTENSIONS "STATIC")
    endif()
    usable_In_Regex(libpattern "${library}")
    set(prefixed_name ${PREFIX}${libpattern})

    set(res_extraction)
    foreach(ext IN LISTS EXTENSIONS)
      set(pattern)
      set(index)
      if(CURRENT_PLATFORM_OS STREQUAL "linux"
      OR CURRENT_PLATFORM_OS STREQUAL "freebsd") #GNU linker scripts
        set(pattern "^.*(GROUP|INPUT)[ \t]*\\([ \t]*([^ \t]+${prefixed_name}[^ \t]*\\${ext}[^ \t]*)[ \t]+.*$")#\\ is for adding \ at the beginning of extension (.so) so taht . will not be interpreted as a
        set(index 2)
      elseif(CURRENT_PLATFORM_OS STREQUAL "macos") #macos linker script
        set(pattern "^install-name:[ \t]*'([^ \t]+${prefixed_name}[^ \t]*\\${ext})'[ \t]*.*$")#\\ is for adding \ at the beginning of extension (.so) so taht . will not be interpreted as a
        set(index 1)
      endif()
      file(STRINGS ${path_to_linker_script} EXTRACTED REGEX "${pattern}")
      if(EXTRACTED)
        # the implicit linker script gives the real path to library
        foreach(extracted IN LISTS EXTRACTED)
          if(extracted MATCHES "${pattern}")
            set(${LIBRARY_PATH} ${CMAKE_MATCH_${index}} PARENT_SCOPE)
            return()
          endif()
        endforeach()
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
#     :LIB_LINK_PATH: the output variable that contains only the path to the link, may be path to real soname or path to symlink.
#     :LIB_SONAME: the output variable that contains only the name of the library if path has been found, empty otherwise.
#     :LIB_SOVERSION: the output variable that contains only the SOVERSION of the library if LIB_SONAME has been found, empty otherwise.
#
function(find_Library_In_Implicit_System_Dir LIBRARY_PATH LIB_LINK_PATH LIB_SONAME LIB_SOVERSION library_name)
  set(IMPLICIT_DIRS ${CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES})
  foreach(dir IN LISTS IMPLICIT_DIRS)#searching for library name in same order as specified by the path to ensure same resolution as the linker
  	find_Possible_Library_Path(REAL_PATH LINK_PATH LIBSONAME ${dir} ${library_name})
  	if(REAL_PATH)#there is a standard library or symlink with that name
      get_Soname_Info_From_Library_Path(LIB_PATH SONAME SOVERSION ${library_name} ${REAL_PATH})
      if(LIB_PATH)
        set(${LIBRARY_PATH} ${LIB_PATH} PARENT_SCOPE)
        set(${LIB_SONAME} ${SONAME} PARENT_SCOPE)
        set(${LIB_SOVERSION} ${SOVERSION} PARENT_SCOPE)
        set(${LIB_LINK_PATH} ${LINK_PATH} PARENT_SCOPE)
        return()#solution has been found
      endif()
    endif()
  endforeach()
  set(${LIBRARY_PATH} PARENT_SCOPE)
  set(${LIB_SONAME} PARENT_SCOPE)
  set(${LIB_SOVERSION} PARENT_SCOPE)
  set(${LIB_LINK_PATH} PARENT_SCOPE)
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
#     :full_path: the full path to the library file (may be a real soobject or link or a linker script).
#
#     :LIBRARY_PATH: the output variable that contains the full path to library, empty if no path found.
#     :LIB_SONAME: the output variable that contains only the name of the library if path has been found, empty otherwise.
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
    extract_Library_Path_From_Linker_Script(LIB_PATH ${library_name} ${full_path} TRUE)
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
#  .. |get_RealPath_From_Static_Library_Path| replace:: ``get_RealPath_From_Static_Library_Path``
#  .. _get_RealPath_From_Static_Library_Path:
#
#  get_RealPath_From_Static_Library_Path
#  -------------------------------------
#
#   .. command:: get_RealPath_From_Static_Library_Path(LIBRARY_PATH library_name full_path)
#
#    Get link info of a static library that is supposed to be located in implicit system folders.
#
#     :library_name: the name of the library (without any prefix or suffix specific to system).
#     :full_path: the full path to the library file (may be a real soobject or link or a linker script).
#
#     :LIBRARY_PATH: the output variable that contains the full path to library, empty if no path found.
#
function(get_RealPath_From_Static_Library_Path LIBRARY_PATH library_name full_path)
  get_Archive_Description(DESCRIPTION ${full_path})
  if(DESCRIPTION)#preceding commands says OK: means the binary is recognized as an adequate shared object
    set(${LIBRARY_PATH} ${full_path} PARENT_SCOPE)
    return()
  else()#here we can check the text content, since the file can be an implicit linker script use as an alias (and more)
    extract_Library_Path_From_Linker_Script(LIB_PATH ${library_name} ${full_path} FALSE)
    if(LIB_PATH)
      get_Binary_Description(DESCRIPTION ${LIB_PATH})
      if(DESCRIPTION)#preceding commands says OK: means the binary is recognized as an adequate shared object
        #getting the SONAME
        set(${LIBRARY_PATH} ${LIB_PATH} PARENT_SCOPE)
        return()
      endif()
    endif()
  endif()
  set(${LIBRARY_PATH} PARENT_SCOPE)
endfunction(get_RealPath_From_Static_Library_Path)


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
#     :symbol: the symbol that is supposed to have a version number. For instance symbol GLIBCXX can be used for libstdc++.so (GNU standard C++ library).
#
#     :MAX_VERSION: the output variable that contains the max version of the target symbol always with major.minor.patch structure.
#
function(get_Library_ELF_Symbol_Max_Version MAX_VERSION path_to_library symbol)
  set(ALL_SYMBOLS)
  usable_In_Regex(usable_symbol ${symbol})
  file(STRINGS ${path_to_library} ALL_SYMBOLS REGEX ".*${usable_symbol}.*")#extract ascii symbols from the library file
  if(ALL_SYMBOLS)
    set(max_version "0.0.0")
    foreach(version IN LISTS ALL_SYMBOLS)
      extract_ELF_Symbol_Version(RES_VERSION "${usable_symbol}" ${version})#get the version from each found symbol
      if(RES_VERSION VERSION_GREATER max_version)
        set(max_version ${RES_VERSION})
      endif()
    endforeach()
    set(${MAX_VERSION} ${max_version} PARENT_SCOPE)
    return()
  endif()
  set(${MAX_VERSION} PARENT_SCOPE)#no result for that symbol
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
  #need to unset variable that are not in cache by default
  unset(CMAKE_CXX_COMPILER_VERSION)
  unset(CMAKE_CXX_COMPILER_ID)
	if("${build_folder}" MATCHES "${PROJECT_NAME}/build$")
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
  load_Workspace_Info()
	if("${build_folder}" MATCHES "${PROJECT_NAME}/build$")
		if(TEMP_PLATFORM)
			if( (NOT TEMP_PLATFORM STREQUAL CURRENT_PLATFORM) #the current platform has changed so we need to regenerate
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
      if(DO_CLEAN AND NOT type STREQUAL "SITE")
        message("[PID] INFO : cleaning the build folder after major environment change")
        if(type STREQUAL "NATIVE")
  				hard_Clean_Package(${PROJECT_NAME})
  				reconfigure_Package_Build(${PROJECT_NAME})#force reconfigure before running the build
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
#  .. |load_Current_Platform_Only| replace:: ``load_Current_Platform_Only``
#  .. _load_Current_Platform_Only:
#
#  load_Current_Platform_Only
#  --------------------------
#
#   .. command:: load_Current_Platform_Only()
#
#    Load information about target platform description into current process.
#
macro(load_Current_Platform_Only)
#loading global profile config file to decide which profile is in use
load_Profile_Info()
#loading the current platform configuration simply consists in including the config file generated by the workspace
include(${WORKSPACE_DIR}/build/${CURRENT_PROFILE}/Workspace_Platforms_Description.cmake)
include(${WORKSPACE_DIR}/build/${CURRENT_PROFILE}/Workspace_Build_Info.cmake)
endmacro(load_Current_Platform_Only)


#.rst:
#
# .. ifmode:: internal
#
#  .. |load_Workspace_Info| replace:: ``load_Workspace_Info``
#  .. _load_Workspace_Info:
#
#  load_Workspace_Info
#  ---------------------
#
#   .. command:: load_Workspace_Info()
#
#    Load all information from workspace configuration.
#
macro(load_Workspace_Info)
#loading contribution spaces in use
load_Current_Contribution_Spaces()
#loading global profile config file to decide which profile is in use
load_Profile_Info()
#loading the current platform configuration simply consists in including the config file generated by the workspace
include(${WORKSPACE_DIR}/build/${CURRENT_PROFILE}/Workspace_Info.cmake)
set_Project_Module_Path_From_Workspace()
endmacro(load_Workspace_Info)

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
include(${WORKSPACE_DIR}/build/Workspace_Contribution_Spaces.cmake)
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

  foreach(lang IN LISTS ${PROJECT_NAME}_LANGUAGE_CONFIGURATIONS${USE_MODE_SUFFIX})
    set(${PROJECT_NAME}_LANGUAGE_CONFIGURATION_${lang}_ARGS${USE_MODE_SUFFIX} CACHE INTERNAL "")
  endforeach()
  set(${PROJECT_NAME}_LANGUAGE_CONFIGURATIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")

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
  #also reset cplatform configruation constraints coming from langauge in use
  unset(${PROJECT_NAME}_IMPLICIT_PLATFORM_CONSTRAINTS${USE_MODE_SUFFIX} CACHE)
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
      if(PLAT_VERSION VERSION_GREATER_EQUAL PACK_VERSION)
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
        OR name STREQUAL "symbol")#only check for soname and symbols compatibility if any

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
    #WARNING Note: use same arguments as binary (soname and symbol are not used to directly check validity of the configuration) !!
    check_Language_Configuration_With_Arguments(SYSCHECK_RESULT LANG_SPECS TARGET_PLATFORM_SPECS ${lang} PACKAGE_SPECS ${mode})

    #get SONAME and SYMBOLS coming from package configuration
    get_Soname_Symbols_Values(PLATFORM_SONAME PLATFORM_SYMBOLS LANG_SPECS)
    get_Soname_Symbols_Values(PACKAGE_SONAME PACKAGE_SYMBOLS PACKAGE_SPECS)
    #from here we have the value to compare with
    if(PACKAGE_SONAME)#package defines constraints on SONAMES
      test_Soname_Compatibility(SONAME_COMPATIBLE PACKAGE_SONAME PLATFORM_SONAME)
      if(NOT SONAME_COMPATIBLE)
        if(ADDITIONAL_DEBUG_INFO)
          message("[PID] WARNING: standard libraries for language ${lang} have an incompatible soname (${PLATFORM_SONAME}) with those used to build package ${package} (${PACKAGE_SONAME})")
        endif()
        return()
      endif()
    endif()
    if(PACKAGE_SYMBOLS)#package defines constraints on SYMBOLS
      test_Symbols_Compatibility(SYMBOLS_COMPATIBLE PACKAGE_SYMBOLS PLATFORM_SYMBOLS)
      if(NOT SYMBOLS_COMPATIBLE)
        if(ADDITIONAL_DEBUG_INFO)
          message("[PID] WARNING: standard libraries symbols for language ${lang} have incompatible versions (${PLATFORM_SYMBOLS}) with those used to build package ${package} (${PACKAGE_SYMBOLS})")
        endif()
        return()
      endif()
    endif()

    #Note : no need to check platform config required by package since they will be part of required configurations
  endforeach()

  # testing sonames and symbols of libraries coming from platform configurations used by package
  foreach(config IN LISTS ${package}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX})#for each symbol used by the binary
    parse_Configuration_Expression_Arguments(PACKAGE_SPECS ${package}_PLATFORM_CONFIGURATION_${config}_ARGS${VAR_SUFFIX})
    #get SONAME and SYMBOLS coming from platform configuration
    #WARNING Note: use same arguments as binary !!
    check_Platform_Configuration_With_Arguments(SYSCHECK_RESULT PLATFORM_SPECS ${package} ${config} PACKAGE_SPECS ${mode})
    get_Soname_Symbols_Values(PLATFORM_SONAME PLATFORM_SYMBOLS PLATFORM_SPECS)

    #get SONAME and SYMBOLS coming from package configuration
    get_Soname_Symbols_Values(PACKAGE_SONAME PACKAGE_SYMBOLS PACKAGE_SPECS)

    #from here we have the value to compare with
    if(PACKAGE_SONAME)#package defines constraints on SONAMES
      test_Soname_Compatibility(SONAME_COMPATIBLE PACKAGE_SONAME PLATFORM_SONAME)
      if(NOT SONAME_COMPATIBLE)
        if(ADDITIONAL_DEBUG_INFO)
          message("[PID] WARNING: libraries provided by current configuration ${config} have an incompatible soname (${PLATFORM_SONAME}) with those used to build package ${package} (${PACKAGE_SONAME})")
        endif()
        return()
      endif()
    endif()
    if(PACKAGE_SYMBOLS)#package defines constraints on SYMBOLS
      test_Symbols_Compatibility(SYMBOLS_COMPATIBLE PACKAGE_SYMBOLS PLATFORM_SYMBOLS)
      if(NOT SYMBOLS_COMPATIBLE)
        if(ADDITIONAL_DEBUG_INFO)
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
#     Generate an expression (string) that describes the configuration checks needed to manage dependencies of a given configuration.
#
#     :config: the name of the system configuration.
#
#     :RESULTING_EXPRESSION: the input/output variable containing the configuration check equivalent expression.
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
              set(gen_constraint "${gen_constraint}:")
            endif()
            set(first_constraint_written TRUE)
            set(gen_constraint "${gen_constraint}${constraint}")
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
#   .. command:: check_Platform_Configuration(RESULT NAME CONSTRAINTS package config mode)
#
#    Check whether the given configuration constraint (= configruation name + arguments) conforms to target platform. This function is used in source scripts.
#
#     :package: the pakcage that requires the the configuration.
#     :config: the configuration expression (may contain arguments).
#     :mode: the current build mode.
#
#     :RESULT: the output variable that is TRUE configuration constraints is satisfied by current platform.
#     :NAME: the output variable that contains the name of the configuration without arguments.
#     :CONSTRAINTS: the output variable that contains the constraints that applmy to the configuration once used. It includes arguments (constraints imposed by user) and generated contraints (constraints automatically defined by the configuration itself once used).
#
function(check_Platform_Configuration RESULT NAME CONSTRAINTS package config mode)
  parse_Configuration_Expression(CONFIG_NAME CONFIG_ARGS "${config}")
  if(NOT CONFIG_NAME)
    set(${NAME} PARENT_SCOPE)
    set(${CONSTRAINTS} PARENT_SCOPE)
    set(${RESULT} FALSE PARENT_SCOPE)
    message("[PID] CRITICAL ERROR : configuration check ${config} is ill formed.")
    return()
  endif()
  check_Platform_Configuration_With_Arguments(RESULT_WITH_ARGS BINARY_CONSTRAINTS ${package} ${CONFIG_NAME} CONFIG_ARGS ${mode})
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
#   .. command:: check_Platform_Configuration_With_Arguments(CHECK_OK BINARY_CONTRAINTS package config_name config_args_var mode)
#
#    Check whether the given configuration constraint (= configruation name + arguments) conforms to target platform.
#
#     :package: package that requires the configuration.
#     :config_name: the name of the configuration (without argument).
#     :config_args_var: the constraints passed as arguments by the user of the configuration.
#     :mode: the current build mode.
#
#     :CHECK_OK: the output variable that is TRUE configuration constraints is satisfied by current platform.
#     :BINARY_CONTRAINTS: the output variable that contains the list of all parameter (constraints coming from argument or generated by the configuration itself) to use whenever the configuration is used.
#
function(check_Platform_Configuration_With_Arguments CHECK_OK BINARY_CONTRAINTS package config_name config_args_var mode)
  set(${BINARY_CONTRAINTS} PARENT_SCOPE)
  set(${CHECK_OK} FALSE PARENT_SCOPE)

  #check if the configuration has already been checked
  check_Configuration_Temporary_Optimization_Variables(CHECK_ALREADY_MADE CHECK_SUCCESS BIN_CONSTRAINTS ${config_name} ${config_args_var} ${mode})
  if(CHECK_ALREADY_MADE)#same check has already been made, we want to avoid redoing them unecessarily
    set(${CHECK_OK} ${CHECK_SUCCESS} PARENT_SCOPE)
    set(${BINARY_CONTRAINTS} ${BIN_CONSTRAINTS} PARENT_SCOPE)
    return()
  endif()

  if(ADDITIONAL_DEBUG_INFO)
    message("[PID] INFO: checking target platform configuration ${config_name}")
  endif()
  #need to ensure system configuration check is installed
  install_System_Configuration_Check(PATH_TO_CONFIG ${config_name})#TODO
  if(NOT PATH_TO_CONFIG)
    message(WARNING "[PID] ERROR : when checking if system configuration ${config_name} is possibly usable on current platform. Please either : remove the constraint ${config_name}; check that ${config_name} is well spelled and rename it if necessary; contact developpers of wrapper ${config_name} to solve the problem, create a new wrapper called ${config_name} or configure your workspace with the contribution space referencing the wrapper of ${config_name}.")
    return()
  endif()
  reset_Platform_Configuration_Cache_Variables(${config_name}) #reset the output variables to ensure a good result
  include(${PATH_TO_CONFIG}/check_${config_name}.cmake)#get the description of the configuration check
  #now preparing args passed to the configruation (generate cmake variables)
  set(possible_args ${${config_name}_REQUIRED_CONSTRAINTS} ${${config_name}_OPTIONAL_CONSTRAINTS} ${${config_name}_IN_BINARY_CONSTRAINTS})
  if(possible_args)
    list(REMOVE_DUPLICATES possible_args)
    prepare_Configuration_Expression_Arguments(${config_name} ${config_args_var} possible_args)#setting variables that correspond to the arguments passed to the check script
  endif()

  check_Platform_Configuration_Arguments(ARGS_TO_SET ${config_name})
  if(ARGS_TO_SET)#there are unset required arguments
    fill_String_From_List(RES_STRING ARGS_TO_SET ", ")
    message("[PID] WARNING : when checking arguments of configuration ${config_name}, there are required arguments that are not set : ${RES_STRING}")
    return()
  endif()
  #evaluate the platform configuration expression
  evaluate_Platform_Configuration(${config_name} ${PATH_TO_CONFIG} FALSE)
  set(${config_name}_AVAILABLE TRUE CACHE INTERNAL "")
  if(NOT ${config_name}_CONFIG_FOUND)
  	install_Platform_Configuration(${config_name} ${PATH_TO_CONFIG})
  	if(NOT ${config_name}_INSTALLED)
      set(${config_name}_AVAILABLE FALSE CACHE INTERNAL "")
    endif()
  endif()
  if(NOT ${config_name}_AVAILABLE)#configuration is not available so we cannot generate output variables
    set_Configuration_Temporary_Optimization_Variables(${config_name} ${mode} FALSE "${${config_args_var}}" "")
    return()
  endif()

  # checking dependencies
  set(dep_configurations)
  foreach(check IN LISTS ${config_name}_CONFIGURATION_DEPENDENCIES)
    check_Platform_Configuration(RESULT_OK CONFIG_NAME CONFIG_CONSTRAINTS ${package} ${check} ${mode})#check that dependencies are OK
    if(NOT RESULT_OK)
      message("[PID] WARNING : when checking configuration of current platform, configuration ${check}, used by ${config_name} cannot be satisfied.")
      set_Configuration_Temporary_Optimization_Variables(${config_name} ${mode} FALSE "${${config_args_var}}" "")
      return()
    endif()
    #here need to manage resulting binary contraints
    append_Unique_In_Cache(${config_name}_CONFIGURATION_DEPENDENCIES_IN_BINARY ${CONFIG_NAME})
    append_Unique_In_Cache(${CONFIG_NAME}_CONSTRAINTS_IN_BINARY "${CONFIG_CONSTRAINTS}")
  endforeach()

  #extracting variables to make them usable in calling context
  extract_Platform_Configuration_Resulting_Variables(${config_name})

  if(${config_name}_FOUND OR ${config_name}_FOUND_DEBUG)
    #corresponding external package version has already been found
    #Note: use both modes signatures to allow the test to work in any situation (if its is undirectly called from a script)
    #WARNING: the corresponding external package version has already been chosen in local process
    if(NOT ${config_name}_VERSION_STRING VERSION_EQUAL ${config_name}_VERSION
      OR NOT ${config_name}_REQUIRED_VERSION_SYSTEM)#version in use must be same system version
      #ERROR: this configuration simply cannot be used
      message("[PID] WARNING: configuration ${config_name} cannot be used since it matches an external dependency whose version (${${config_name}_VERSION_STRING}) is not compliant with system version required (${${config_name}_VERSION}). If versions are equal it means that the package has been built with a NON OS variant version of ${config_name}.")
      set(${CHECK_OK} FALSE PARENT_SCOPE)
      set_Configuration_Temporary_Optimization_Variables(${config_name} ${mode} FALSE "${${config_args_var}}" "")
      return()
    endif()
  endif()
  # now enforce constraint of using the OS variant of an external package
  # predefine the use of the external package version with its os variant
  # no other choice to ensure compatibility with any package using this external package
  set(${config_name}_VERSION_STRING ${${config_name}_VERSION} CACHE INTERNAL "")
  set(${config_name}_REQUIRED_VERSION_EXACT ${${config_name}_VERSION} CACHE INTERNAL "")
  set(${config_name}_REQUIRED_VERSION_SYSTEM TRUE CACHE INTERNAL "")
  add_Chosen_Package_Version_In_Current_Process(${config_name} ${package})#force the use of an os variant

  #return the complete set of binary contraints
  set(bin_constraints ${${config_name}_REQUIRED_CONSTRAINTS} ${${config_name}_IN_BINARY_CONSTRAINTS})
  get_Configuration_Expression_Resulting_Constraints(ALL_CONSTRAINTS ${config_name} bin_constraints)
  set(${BINARY_CONTRAINTS} ${ALL_CONSTRAINTS} PARENT_SCOPE)#automatic appending constraints generated by the configuration itself for the given binary package generated
  set(${CHECK_OK} TRUE PARENT_SCOPE)
  set_Configuration_Temporary_Optimization_Variables(${config_name} ${mode} TRUE "${${config_args_var}}" "${ALL_CONSTRAINTS}")
endfunction(check_Platform_Configuration_With_Arguments)



#.rst:
#
# .. ifmode:: internal
#
#  .. |get_All_Configuration_Visible_Build_Variables| replace:: ``get_All_Configuration_Visible_Build_Variables``
#  .. _get_All_Configuration_Visible_Build_Variables:
#
#  get_All_Configuration_Visible_Build_Variables
#  ---------------------------------------------
#
#   .. command:: get_All_Configuration_Visible_Build_Variables(LINK_OPTS COMPILE_OPTS INC_DIRS LIB_DIRS DEFS RPATH config)
#
#    Get all variables usable during build process from a given platform configuration. This allows to get the variables generated by dependencies of this configuration.
#
#     :config: the name of the configuration (without argument).
#
#     :LINK_OPTS: the output variable that contains configruation variables holding linker options.
#     :COMPILE_OPTS: the output variable that contains configruation variables holding compiler options.
#     :INC_DIRS: the output variable that contains configruation variables holding include directories.
#     :LIB_DIRS: the output variable that contains configruation variables holding library directories.
#     :DEFS: the output variable that contains configruation variables holding preprocessor definitions.
#     :RPATH: the output variable that contains configruation variables holding runtime path.
#
function(get_All_Configuration_Visible_Build_Variables LINK_OPTS COMPILE_OPTS INC_DIRS LIB_DIRS DEFS RPATH config)
  #first getting local variables for the given configuration
  set(links)#preprocessor definition that apply to the interface of the configuration's components come from : 1) the configuration definition itself and 2) can be set directly by the user component
  if(DEFINED ${config}_LINK_OPTIONS)
    set(links ${config}_LINK_OPTIONS)
  endif()
  set(defs)#preprocessor definition that apply to the interface of the configuration's components come from : 1) the configuration definition itself and 2) can be set directly by the user component
  if(DEFINED ${config}_DEFINITIONS)
		set(defs ${config}_DEFINITIONS)
	endif()
	#only transmit configuration variable if the configuration defines those variables (even if standard they are not all always defined)
	set(includes)
	if(DEFINED ${config}_INCLUDE_DIRS)
		set(includes ${config}_INCLUDE_DIRS)
	endif()
	set(lib_dirs)
	if(DEFINED ${config}_LIBRARY_DIRS)
		set(lib_dirs ${config}_LIBRARY_DIRS)
	endif()
	set(opts)
	if(DEFINED ${config}_COMPILER_OPTIONS)
		set(opts ${config}_COMPILER_OPTIONS)
	endif()
	set(rpath)
	if(DEFINED ${config}_RPATH)
		set(rpath ${config}_RPATH)
	endif()
  #then getting the variables of the dependencies
  foreach(dep IN LISTS ${config}_CONFIGURATION_DEPENDENCIES)
    #recursion
    get_All_Configuration_Visible_Build_Variables(DEP_LINK_OPTS DEP_COMPILE_OPTS DEP_INC_DIRS DEP_LIB_DIRS DEP_DEFS DEP_RPATH ${dep})
    list(APPEND links ${DEP_LINK_OPTS})
    list(APPEND defs ${DEP_DEFS})
    list(APPEND includes ${DEP_INC_DIRS})
    list(APPEND lib_dirs ${DEP_LIB_DIRS})
    list(APPEND opts ${DEP_COMPILE_OPTS})
    list(APPEND rpath ${DEP_RPATH})
  endforeach()
  if(links)
    list(REMOVE_DUPLICATES links)
  endif()
  if(defs)
    list(REMOVE_DUPLICATES defs)
  endif()
  if(includes)
    list(REMOVE_DUPLICATES includes)
  endif()
  if(lib_dirs)
    list(REMOVE_DUPLICATES lib_dirs)
  endif()
  if(opts)
    list(REMOVE_DUPLICATES opts)
  endif()
  if(rpath)
    list(REMOVE_DUPLICATES rpath)
  endif()
  set(${LINK_OPTS} ${links} PARENT_SCOPE)
  set(${COMPILE_OPTS} ${opts} PARENT_SCOPE)
  set(${INC_DIRS} ${includes} PARENT_SCOPE)
  set(${LIB_DIRS} ${lib_dirs} PARENT_SCOPE)
  set(${DEFS} ${defs} PARENT_SCOPE)
  set(${RPATH} ${rpath} PARENT_SCOPE)
endfunction(get_All_Configuration_Visible_Build_Variables)

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
  set(possible_args ${${config_name}_OPTIONAL_CONSTRAINTS} ${${config_name}_REQUIRED_CONSTRAINTS} ${${config_name}_IN_BINARY_CONSTRAINTS})
  if(possible_args)
    list(REMOVE_DUPLICATES possible_args)
    prepare_Configuration_Expression_Arguments(${config_name} ${config_args} possible_args)#setting variables that correspond to the arguments passed to the check script
  endif()

  check_Platform_Configuration_Arguments(ARGS_TO_SET ${config_name})
  if(ARGS_TO_SET)#there are unset required arguments
    fill_String_From_List(RES_STRING ARGS_TO_SET ", ")
    message("[PID] WARNING : when testing arguments of configuration ${config_name}, there are required arguments that are not set : ${RES_STRING}")
    return()
  endif()

  # checking dependencies first
  foreach(check IN LISTS ${config_name}_CONFIGURATION_DEPENDENCIES)
    parse_Configuration_Expression(CONFIG_NAME CONFIG_ARGS "${check}")
    if(NOT CONFIG_NAME)
      return()
    endif()
    is_Allowed_Platform_Configuration(DEP_ALLOWED ${CONFIG_NAME} CONFIG_ARGS)
    if(NOT DEP_ALLOWED)
      return()
    endif()
  endforeach()

  evaluate_Platform_Configuration(${config_name} ${PATH_TO_CONFIG} FALSE) # find the artifacts used by this configuration
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
#  .. |is_Allowed_Language_Configuration| replace:: ``is_Allowed_Language_Configuration``
#  .. _is_Allowed_Language_Configuration:
#
#  is_Allowed_Language_Configuration
#  ----------------------------------
#
#   .. command:: is_Allowed_Language_Configuration(ALLOWED lang_name lang_args)
#
#    Test if a configuration can be used with current platform.
#
#     :lang_name: the name of the language (without argument, according to CMake standard).
#     :lang_args: the constraints passed as arguments by the user of the configuration.
#
#     :ALLOWED: the output variable that is TRUE if configuration can be used.
#
function(is_Allowed_Language_Configuration ALLOWED lang_name lang_args)
  set(${ALLOWED} FALSE PARENT_SCOPE)
  import_Language_Parameters(${lang_name})
  set(lang_constraints ${LANG_${lang_name}_OPTIONAL_CONSTRAINTS} ${LANG_${lang_name}_IN_BINARY_CONSTRAINTS})
  if(lang_constraints)
    list(REMOVE_DUPLICATES lang_constraints)
    prepare_Configuration_Expression_Arguments(${lang_name} ${lang_args} lang_constraints)
  endif()
  evaluate_Language_Configuration(${lang_name})#evaluation takes place here (call to platforms/eval/eval_${lang_name}.cmake)

  if(NOT ${lang_name}_EVAL_RESULT)#language configuration cannot be satisfied
    return()
  endif()
  set(${ALLOWED} TRUE PARENT_SCOPE)
endfunction(is_Allowed_Language_Configuration)


#.rst:
#
# .. ifmode:: internal
#
#  .. |memorize_Platform_Configuration_Inputs| replace:: ``memorize_Platform_Configuration_Inputs``
#  .. _memorize_Platform_Configuration_Inputs:
#
#  memorize_Platform_Configuration_Inputs
#  --------------------------------------
#
#   .. command:: memorize_Platform_Configuration_Inputs(config index)
#
#    Memorize in a cache file the arguments used as constraint for checking the platform configuration.
#
#     :config: the name of the configuration (without argument).
#     :index: index for teh set of input arguments used to check theconfigruation.
#
function(memorize_Platform_Configuration_Inputs config index)
  set(eval_input_file ${CMAKE_BINARY_DIR}/input_vars.txt)#using a txt file that is read to avoid inclusion that implicitly generates a reconfiguration when modified
  if(FORCE_REEVAL)#if forced reevaluation, simply stop as inputs will not be modified
    message("FORCED REEVALUATION")
    return()
  endif()
  if(NOT EXISTS ${eval_input_file})
    file(WRITE ${eval_input_file} "")#empty file at beginning
  endif()
  extract_All_Words("${ARGS}" " " ARGS_LIST)
  set(args_val)
  foreach(arg IN LISTS ARGS_LIST)
    fill_String_From_List(RES_VAL ${config}_${arg} ",")#list are separated with , NOT ; (otherwise problem with CMake parsing)
    list(APPEND args_val "${arg}=${RES_VAL}")
  endforeach()
  file(APPEND ${eval_input_file} "${index} >>> ${args_val}\n")
endfunction(memorize_Platform_Configuration_Inputs)

#.rst:
#
# .. ifmode:: internal
#
#  .. |platform_Configuration_Arguments_Already_Checked| replace:: ``platform_Configuration_Arguments_Already_Checked``
#  .. _platform_Configuration_Arguments_Already_Checked:
#
#  platform_Configuration_Arguments_Already_Checked
#  ------------------------------------------------
#
#   .. command:: platform_Configuration_Arguments_Already_Checked(RES_INDEX config path_to_config)
#
#    Memorize in a cache file the arguments used as constraint for checking the platform configuration.
#
#     :config: the name of the configuration (without argument).
#     :path_to_config: path to the configuration check script installed in workspace.

#     :RES_INDEX: the output variable that conains the index in cache file for the adequate set of arguments if this set matches the set of arguments currenlty checked, otherwise empty if no set of arguments matches current set of arguments passed.
#
function(platform_Configuration_Arguments_Already_Checked RES_INDEX config path_to_config)
  set(eval_input_file ${path_to_config}/build/input_vars.txt)#using a txt file that is read to avoid inclusion that implicitly generates a reconfiguration
  set(${RES_INDEX} PARENT_SCOPE)
  if(NOT EXISTS ${eval_input_file})
    return()
  endif()
  list(LENGTH ${config}_arguments size_args_curr)
  file (STRINGS ${eval_input_file} PREVIOUS_CALLS)
  foreach(call IN LISTS PREVIOUS_CALLS)#creae the variablkes locally
    if(call MATCHES "^([0-9]+) >>> (.*)$")
      #1) get all constraints arguments passed to the previous evaluation
      set(curr_idx ${CMAKE_MATCH_1})
      set(args_list ${CMAKE_MATCH_2})
      set(tmp_args)
      foreach(arg IN LISTS args_list)
        if(arg MATCHES "^([^=]+)=(.+)$")
          extract_All_Words("${CMAKE_MATCH_2}" "," ARGS_LIST)
          set(tmp_${CMAKE_MATCH_1} ${ARGS_LIST})#create the variable
          list(APPEND tmp_args tmp_${CMAKE_MATCH_1})#memorize the variable
        endif()
      endforeach()
      #2) compare previous value VS current value of arguments
      set(match_ok FALSE)
      if(NOT ${config}_arguments)
        if(NOT tmp_args)#bot are empty so OK
          set(match_ok TRUE)
        endif()
      elseif(tmp_args) #OTHERWISE: if previous args are empty then not the previosu call is not adequate
        #both list are
        list(LENGTH tmp_args size_args_prev)
        if(size_args_prev EQUAL size_args_curr)#OTHERWISE: not same set of arguments
          set(all_same_args TRUE)
          foreach(arg IN LISTS ${config}_arguments)
            if(NOT DEFINED tmp_${arg})
              set(all_same_args FALSE)
              break()#NOTE: if argument not defined in previous context no need to continue
            endif()
            list(LENGTH tmp_${arg} size_prev)
            list(LENGTH ${config}_${arg} size_curr)
            if(NOT size_prev EQUAL size_curr)
              #NOTE: currenlty tested argument has not the same SIZE in previous and current contexts so immediately stop
              set(all_same_args FALSE)
              break()
            endif()
            #OK so now checking that each value of the list can be found in the other list
            foreach(val IN LISTS ${config}_${arg})
              list(FIND tmp_${arg} ${val} INDEX)
              if(INDEX EQUAL -1)
                set(all_same_args FALSE)
                break()
              endif()
            endforeach()
            if(NOT all_same_args)
              break()# NOTE: currenlty tested argument has not the same (unordered) VALUE in previous and current contexts so immediately stop
            endif()
          endforeach()
          if(all_same_args)
            set(match_ok TRUE)
          endif()
        endif()
      endif()
      #3) reset the variable to avoid any problem with following iterations
      foreach(arg IN LISTS tmp_args)
        unset(${arg})
      endforeach()
      #4) verify that a match has been found
      if(match_ok)
        set(${RES_INDEX} ${curr_idx} PARENT_SCOPE)
        return()
      endif()
    endif()
  endforeach()
endfunction(platform_Configuration_Arguments_Already_Checked)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Already_Checked_Platform_Configuration_Arguments| replace:: ``reset_Already_Checked_Platform_Configuration_Arguments``
#  .. _reset_Already_Checked_Platform_Configuration_Arguments:
#
#  reset_Already_Checked_Platform_Configuration_Arguments
#  ------------------------------------------------------
#
#   .. command:: reset_Already_Checked_Platform_Configuration_Arguments(path_to_config)
#
#    Reset all cache information that memorize the set of arguments already checked for a platform configuration.
#    This remove either cache file for inputs AND the various output variables correspond to results of previous calls.
#
#     :path_to_config: path to the configuration check script installed in workspace.
#
function(reset_Already_Checked_Platform_Configuration_Arguments path_to_config)
  set(eval_input_file ${path_to_config}/build/input_vars.txt)#
  if(EXISTS ${eval_input_file})
    file(REMOVE ${eval_input_file})#simply remove the file containing the cached arguments
  endif()
  file(GLOB ALL_OUTPUTS ${path_to_config}/build/output_vars_*.cmake)
  foreach(a_file IN LISTS ALL_OUTPUTS)
    file(REMOVE ${a_file})
  endforeach()
endfunction(reset_Already_Checked_Platform_Configuration_Arguments)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Next_Index_For_Checked_Platform_Configuration_Arguments| replace:: ``get_Next_Index_For_Checked_Platform_Configuration_Arguments``
#  .. _get_Next_Index_For_Checked_Platform_Configuration_Arguments:
#
#  get_Next_Index_For_Checked_Platform_Configuration_Arguments
#  -----------------------------------------------------------
#
#   .. command:: get_Next_Index_For_Checked_Platform_Configuration_Arguments(NEXT_INDEX path_to_config)
#
#    Get the index to use for evaluating the next set of arguments.
#    Used when no set of argument already checked matches the current call arguments, to know how to memorize the currently used set of arguments.
#
#     :path_to_config: path to the configuration check script installed in workspace.
#
#     :NEXT_INDEX: the output variable that contains the index in cache file for the new set of arguments.
#
function(get_Next_Index_For_Checked_Platform_Configuration_Arguments NEXT_INDEX path_to_config)
  file(GLOB ALL_OUTPUTS ${path_to_config}/build/output_vars_*.cmake)
  set(max_index -1)
  foreach(a_file IN LISTS ALL_OUTPUTS)
    if(a_file MATCHES "output_vars_([0-9]+).cmake")
      if(CMAKE_MATCH_1 GREATER max_index)
        set(max_index ${CMAKE_MATCH_1})
      endif()
    endif()
  endforeach()
  if(max_index EQUAL -1)
    set(${NEXT_INDEX} 0 PARENT_SCOPE)
  else()
    math(EXPR next_idx "${max_index}+1")
    set(${NEXT_INDEX} ${next_idx} PARENT_SCOPE)
  endif()
endfunction(get_Next_Index_For_Checked_Platform_Configuration_Arguments)

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
#   .. command:: evaluate_Platform_Configuration(config path_to_config force_reeval)
#
#   Call the procedure for finding artefacts related to a configuration. Set the ${config}_FOUND variable, that is TRUE is configuration has been found, FALSE otherwise.
#
#     :config: the name of the configuration to find.
#     :path_to_config: the path to configuration folder.
#     :force_reeval: if TRUE the evaluation will be forced even if the same set of arguments has already been tested.
#
macro(evaluate_Platform_Configuration config path_to_config force_reeval)
  # finding artifacts to fulfill system configuration
  set(${config}_CONFIG_FOUND FALSE)
  set(eval_file ${path_to_config}/${${config}_EVAL_FILE})
  set(check_file ${path_to_config}/check_${config}.cmake)#used only to know if regeneration is required
  set(eval_project_file ${path_to_config}/CMakeLists.txt)
  set(eval_result_config_file ${path_to_config}/output_vars.cmake.in)
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
  # optimization check to avoid CMake regeneration of system check when not necessary
  # NOTE: main problem is related to reevaluation due to debug+release builds :
  # each build mode write the included file (same for both) which leads to a complete reevaluation of the
  set(need_reevaluate TRUE)
  set(need_regen FALSE)
  set(result_index 0)
  set(force_reevaluation ${force_reeval})#NOTE: define a variable since force_reeval is a macro argument => not a variable
  #prepare CMake project used for evaluation
  if(NOT EXISTS ${eval_folder})#if build folder does not exists no need to question
    file(MAKE_DIRECTORY ${eval_folder})#create the build folder used for evaluation at first time, then immediately reevaluate
    set(need_regen TRUE)
  else()
    #specific case when the API has been updated => need to regenerate one time to be sure
    is_Src_File_Updated(UPDATED ${eval_project_file} ${WORKSPACE_DIR}/cmake/api/PID_Platform_Management_Functions.cmake)
    if(NOT UPDATED)
      #case when the check file has been regenerated FROM WRAPPER but installed project not reevaluated
      is_Src_File_Updated(UPDATED ${eval_project_file} ${check_file})
    endif()
    if(UPDATED)
      set(need_regen TRUE)
    endif()
    if(need_regen)#when regeneration is required we must reset everything already evaluated
      reset_Already_Checked_Platform_Configuration_Arguments(${path_to_config})
    else()
      # NOTE: if this file exists and noneed to regen we can check if all input
      # variables have already been evaluated
      # if this is true no need to continue
      platform_Configuration_Arguments_Already_Checked(INDEX_MATCHING_ARGS ${config} ${path_to_config})
      if(DEFINED INDEX_MATCHING_ARGS)
        set(need_reevaluate FALSE)
        set(result_index ${INDEX_MATCHING_ARGS})
      endif()
    endif()
  endif()
  if(need_reevaluate OR force_reevaluation)
    set(write_output_config FALSE)
    if(need_regen) # only regenerate the project file if check file has changed (project regenerated) or if current file has changed (implementation evolution)
      file(GLOB eval_build_files "${eval_folder}/*")#clean the eval project subfolder when necessary
      if(eval_build_files)
        file(REMOVE_RECURSE ${eval_build_files})
      endif()
      get_filename_component(the_path ${WORKSPACE_DIR} ABSOLUTE)
      file(WRITE ${eval_project_file} "cmake_minimum_required(VERSION 3.8.2)\n")
      file(APPEND ${eval_project_file} "set(WORKSPACE_DIR ${the_path} CACHE PATH \"root of the PID workspace\")\n")
      file(APPEND ${eval_project_file} "list(APPEND CMAKE_MODULE_PATH \${WORKSPACE_DIR}/cmake \${WORKSPACE_DIR}/cmake/api)\n")
      file(APPEND ${eval_project_file} "include(Configuration_Definition NO_POLICY_SCOPE)\n")# to interpret user defined eval files
      file(APPEND ${eval_project_file} "include(PID_Platform_Management_Functions NO_POLICY_SCOPE)\n")# to acces functions of platform management API
      file(APPEND ${eval_project_file} "project(test_${config} ${eval_languages})\n")
      file(APPEND ${eval_project_file} "set(CMAKE_MODULE_PATH \${CMAKE_SOURCE_DIR} \${CMAKE_MODULE_PATH})\n")
      file(APPEND ${eval_project_file} "if(EXISTS ${WORKSPACE_DIR}/build/System_Modules_Paths.cmake)\n")
      file(APPEND ${eval_project_file} "  include(${WORKSPACE_DIR}/build/System_Modules_Paths.cmake)\n")
      file(APPEND ${eval_project_file} "endif()\n")
      file(APPEND ${eval_project_file} "include(${${config}_EVAL_FILE})\n")
      file(APPEND ${eval_project_file} "configure_file(\${CMAKE_SOURCE_DIR}/output_vars.cmake.in \${CMAKE_BINARY_DIR}/output_vars_\${RESULT_INDEX}.cmake @ONLY)\n")
      file(APPEND ${eval_project_file} "memorize_Platform_Configuration_Inputs(${config} \${RESULT_INDEX})\n")
      set(write_output_config TRUE) #anytime regeneration took place simply rewrite config file defining resul variables
    else()
      #regenerate output config file if it does not exist OR or check file updated
      is_Src_File_Updated(UPDATED ${eval_result_config_file} ${check_file})
      # only perform this step if check file has been regenerated (new implem for the system check)
      # to ensure consistency: then the generated output config file must be in turn regenerated because
      # the variables it contains may have changed
      if(UPDATED)
        set(write_output_config TRUE)
      endif()
    endif()
    #prepare CMake project pattern file used used for getting result
    if(write_output_config)
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
    unset(write_output_config)

    # launch evaluation
    # 1) define which file contains the result
    if(need_reevaluate)
      get_Next_Index_For_Checked_Platform_Configuration_Arguments(result_index ${path_to_config})
      #otherwise it means evaluation has been forced so the result_index is already set
    endif()
    # 2) prepare argument as definition of CMake cache variables
    fill_String_From_List(CALL_ARGS ${config}_arguments " ")
    set(calling_defs "-DRESULT_INDEX=${result_index} \"-DARGS=${CALL_ARGS}\" -DFORCE_REEVAL=${force_reevaluation}")#set the index for the file containing output variables
    foreach(arg IN LISTS ${config}_arguments)
      set(calling_defs "-D${config}_${arg}=${${config}_${arg}} ${calling_defs}")
    endforeach()
    foreach(arg IN LISTS ${config}_no_arguments)
      set(calling_defs "-U${config}_${arg} ${calling_defs}")
    endforeach()
    if(ADDITIONAL_DEBUG_INFO)
      set(options)
    else()
      set(options OUTPUT_QUIET ERROR_QUIET)
    endif()

    if(CMAKE_HOST_WIN32)#on a window host path must be resolved
    	separate_arguments(COMMAND_ARGS_AS_LIST WINDOWS_COMMAND "${calling_defs}")
    else()#if not on windows use a UNIX like command syntax
    	separate_arguments(COMMAND_ARGS_AS_LIST UNIX_COMMAND "${calling_defs}")#always from host perpective
    endif()
    #3) evaluate
    execute_process(COMMAND ${CMAKE_COMMAND} -DWORKSPACE_DIR=${WORKSPACE_DIR} ${COMMAND_ARGS_AS_LIST} ..
                    WORKING_DIRECTORY ${eval_folder} ${options})
    unset(COMMAND_ARGS_AS_LIST)
  endif()

  #3) get the result anytime
  set(eval_result_file ${path_to_config}/build/output_vars_${result_index}.cmake)
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
    unset(DO_NOT_INSTALL)
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
#     :path_to_config: the path to configuration folder.
#
macro(install_Platform_Configuration config path_to_config)
  set(${config}_INSTALLED FALSE)
  is_Platform_Configuration_Installable(INSTALLABLE ${config} ${path_to_config})
  if(INSTALLABLE)
    message("[PID] INFO : installing configuration ${config}...")
    if(${config}_INSTALL_PACKAGES)
      if(ADDITIONAL_DEBUG_INFO)
        message("[PID] INFO : ${config} defines possible system packages ${${config}_INSTALL_PACKAGES}...")
      endif()
      foreach(pack IN LISTS ${config}_INSTALL_PACKAGES)
        # Note: install packages one by one to avoid install procedure to be broken by a non existing system package
        # that provokes an exit of the install command
        # this allows to define many variant names for the install of a unique package
        # This is mandatory to easily adapt to all variations introduced by various distributions
        if(ADDITIONAL_DEBUG_INFO)
          message("[PID] INFO : ${config} is trying to install system package ${pack}...")
        endif()
        execute_System_Packaging_Command(${pack})
      endforeach()
    else()
      include(Configuration_Definition NO_POLICY_SCOPE)
      set(DO_NOT_INSTALL FALSE)# apply installation instructions
      include(${path_to_config}/${${config}_INSTALL_PROCEDURE})
      unset(DO_NOT_INSTALL)
    endif()
    #now evaluate configuration check after install
    evaluate_Platform_Configuration(${config} ${path_to_config} TRUE)
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
