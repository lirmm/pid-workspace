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

set(CURRENT_ABI CACHE INTERNAL "")

function(get_Standard_Library_Symbol_Version RES_SYMBOL_VERSIONS operating_system library_name path_to_library)
	set(${RES_SYMBOL_VERSIONS} PARENT_SCOPE)
	if(library_name MATCHES "stdc\\+\\+")#gnu c++ library (mau be named stdc++11 as well)

		#managing LIBC symbol versions
		file(STRINGS ${path_to_library} LIBC_SYMBOLS REGEX ".*GLIBC_.*")
		set(max_version "0.0.0")
		foreach(version IN LISTS LIBC_SYMBOLS)
			extract_ELF_Symbol_Version(RES_VERSION "GLIBC_" ${version})
			if(RES_VERSION VERSION_GREATER max_version)
				set(max_version ${RES_VERSION})
			endif()
		endforeach()
		if(NOT max_version VERSION_EQUAL "0.0.0")
			list(APPEND res_symbols_version "GLIBC_" "${max_version}")
		endif()

		#managing LIBCXX symbol versions
		file(STRINGS ${path_to_library} LIBCXX_SYMBOLS REGEX ".*GLIBCXX_.*")
		set(max_version "0.0.0")
		foreach(version IN LISTS LIBCXX_SYMBOLS)
			extract_ELF_Symbol_Version(RES_VERSION "GLIBCXX_" ${version})
			if(RES_VERSION VERSION_GREATER max_version)
				set(max_version ${RES_VERSION})
			endif()
		endforeach()
		if(NOT max_version VERSION_EQUAL "0.0.0")
			list(APPEND res_symbols_version "GLIBCXX_" "${max_version}")
		endif()

		#managing CXXABI symbol versions
		file(STRINGS ${path_to_library} CXXABI_SYMBOLS REGEX ".*CXXABI_.*")
		set(max_version "0.0.0")
		foreach(version IN LISTS CXXABI_SYMBOLS)
			extract_ELF_Symbol_Version(RES_VERSION "CXXABI_" ${version})
			if(RES_VERSION VERSION_GREATER max_version)
				set(max_version ${RES_VERSION})
			endif()
		endforeach()
		if(NOT max_version VERSION_EQUAL "0.0.0")
			list(APPEND res_symbols_version "CXXABI_" "${max_version}")
		endif()

		set(${RES_SYMBOL_VERSIONS} ${res_symbols_version} PARENT_SCOPE)
	#elseif(library_name STREQUAL "c++")#the new libc++ library
		#what to do ??
	endif()
endfunction(get_Standard_Library_Symbol_Version)

function(usable_In_Regex RES_STR name)
	string(REPLACE "+" "\\+" RES ${name})
	string(REPLACE "." "\\." RES ${RES})
	set(${RES_STR} ${RES} PARENT_SCOPE)
endfunction(usable_In_Regex)

#resetting symbols to avoid any problem
foreach(symbol IN LISTS STD_ABI_SYMBOLS)
	set(${symbol}_ABI_VERSION)
endforeach()
set(STD_ABI_SYMBOLS)
set(STD_LIBS)

foreach(symbol IN LISTS CXX_STD_SYMBOLS)
	set(CXX_STD_SYMBOL_${symbol}_VERSION CACHE INTERNAL "")
endforeach()
set(CXX_STD_SYMBOLS CACHE INTERNAL "")

foreach(lib IN LISTS CXX_STANDARD_LIBRARIES)
	set(CXX_STD_LIB_${lib}_ABI_SOVERSION CACHE INTERNAL "")
endforeach()
set(CXX_STANDARD_LIBRARIES CACHE INTERNAL "")

# detect current C++ library ABI in use
foreach(lib IN LISTS CMAKE_CXX_IMPLICIT_LINK_LIBRARIES)
	#lib is the short name of the library
	get_Platform_Related_Binary_Prefix_Suffix(PREFIX EXTENSION ${CURRENT_OS} "SHARED")
  set(libname ${PREFIX}${lib}${EXTENSION})
	foreach(dir IN LISTS CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES)#searching for library name in same order as specified by the path to ensure same resolution as the linker
		if(EXISTS ${dir}/${libname})#there is a standard library or symlink with that name
			#getting symbols versions from the implicit library
			get_Standard_Library_Symbol_Version(RES_SYMBOL_VERSIONS ${CURRENT_OS} ${lib} ${dir}/${libname})
			while(RES_SYMBOL_VERSIONS)
				list(GET RES_SYMBOL_VERSIONS 0 symbol)
				list(GET RES_SYMBOL_VERSIONS 1 version)
				list(APPEND STD_ABI_SYMBOLS ${symbol})
				if(NOT version VERSION_LESS ${symbol}_ABI_VERSION)
					set(${symbol}_ABI_VERSION ${version})
				endif()
				list(REMOVE_AT RES_SYMBOL_VERSIONS 0 1)
			endwhile()
			list(REMOVE_DUPLICATES STD_ABI_SYMBOLS)
			list(APPEND STD_LIBS ${lib})
			get_filename_component(RES ${dir}/${libname} REALPATH)#resolving symlinks if any
			usable_In_Regex(RES_STR ${libname})
			set(extensions)
			string(REGEX REPLACE "^.*${RES_STR}\\.(.+)$" "\\1" extensions ${RES})
			if(extensions STREQUAL RES)#not match
				set(major)
			else()
				get_Version_String_Numbers("${extensions}" major minor patch)
			endif()
			set(CXX_STD_LIB_${lib}_ABI_SOVERSION ${major} CACHE INTERNAL "")
			break() #break the execution of the loop w
		endif()
	endforeach()
endforeach()

#memorize symbol versions
foreach(symbol IN LISTS STD_ABI_SYMBOLS)
	set(CXX_STD_SYMBOL_${symbol}_VERSION ${${symbol}_ABI_VERSION} CACHE INTERNAL "")
endforeach()
set(CXX_STD_SYMBOLS ${STD_ABI_SYMBOLS} CACHE INTERNAL "")

set(CXX_STANDARD_LIBRARIES ${STD_LIBS} CACHE INTERNAL "")

#depending on symbol versions we can detect which compiler was used to build the standard library !!
set(USE_CXX_ABI CACHE STRING "Give the compiler ABI standard to use (either 98 or 11 are valid values). If none given, the default compiler ABI will be used.")
if(	NOT USE_CXX_ABI #user did not specified anything
		OR NOT USE_CXX_ABI MATCHES "^11|98$")#user specified something stupid
	foreach(symb IN LISTS STD_ABI_SYMBOLS)
		if(symb STREQUAL "CXXABI_")
			if(NOT ${symb}_ABI_VERSION VERSION_LESS 1.3.9) #build from gcc 5.1 or more (or equivalent compiler ABI settings for clang)
				set(cxxabi_is_cxx11 TRUE)
			else()
				set(cxxabi_is_cxx11 FALSE)
			endif()
		elseif(symb STREQUAL "GLIBCXX_")
			if(NOT ${symb}_ABI_VERSION VERSION_LESS 3.4.21) #build from gcc 5.1 or more (or equivalent compiler ABI settings for clang)
				set(glibcxx_is_cxx11 TRUE)
			else()
				set(glibcxx_is_cxx11 FALSE)
			endif()
		endif()
	endforeach()
	if(cxxabi_is_cxx11 AND glibcxx_is_cxx11)
		set(CURRENT_ABI "CXX11" CACHE INTERNAL "")
	else()
		set(CURRENT_ABI "CXX" CACHE INTERNAL "")
	endif()
else()# set the ABI depending on user wishes
	if(USE_CXX_ABI STREQUAL 11)
		set(CURRENT_ABI "CXX11" CACHE INTERNAL "")
	else()
		set(CURRENT_ABI "CXX" CACHE INTERNAL "")
	endif()
endif()

# ABI detection is no more based on knowledge of the compiler version
#but now we check that minumum version of the compiler are used
if(CURRENT_ABI STREQUAL "CXX11")#check that compiler in use supports the CXX11 ABI
	if(CMAKE_COMPILER_IS_GNUCXX)
		if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.1)#before version 5.1 of gcc the cxx11 abi is not supported
			message(FATAL_ERROR "[PID] CRITICAL ERROR : compiler in use (${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION}) does not support CXX11 ABI.")
		endif()
	elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang" OR CMAKE_CXX_COMPILER_ID STREQUAL "clang")
		if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.8)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : compiler in use (${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION}) does not support CXX11 ABI.")
		endif()
	else()# add new support for compiler or use CMake generic mechanism to do so for instance : CMAKE_CXX_COMPILER_ID STREQUAL "MSVC"
		message("[PID] WARNING : compiler in use (${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION}) ABI support is not identified in PID.")
	endif()
endif()
