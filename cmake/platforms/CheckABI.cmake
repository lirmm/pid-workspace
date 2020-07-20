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

function(check_Current_Standard_Library_Is_CXX11_ABI_Compatible COMPATIBLE)
set(${COMPATIBLE} TRUE PARENT_SCOPE)#by default CXX11 is allowed

if(CURRENT_PLATFORM_OS STREQUAL "windows")
	set(${COMPATIBLE} FALSE PARENT_SCOPE)#for now windows support only legacy ABI
	return ()
else()#other systems
	#from here we will look into the symbols
	#first compiling with default
	try_compile(RES ${CMAKE_BINARY_DIR}
		SOURCES ${WORKSPACE_DIR}/cmake/platforms/checks/abi_check.cpp
		COPY_FILE abi_check
		OUTPUT_VARIABLE out)
	execute_process(COMMAND ${CMAKE_NM} ${CMAKE_BINARY_DIR}/abi_check OUTPUT_VARIABLE check_symbols)
	string(FIND ${check_symbols} "__cxx11" INDEX)
	if(INDEX EQUAL -1)#no cxx11 abi symbol found -> it is a legacy abi by default on the current OS
		set(${COMPATIBLE} FALSE PARENT_SCOPE)
		return()
	endif()
endif()
endfunction(check_Current_Standard_Library_Is_CXX11_ABI_Compatible)

function(get_Current_Standard_Library_Version VERSION NAME)
set(${VERSION} PARENT_SCOPE)
set(${NAME} PARENT_SCOPE)

if(CURRENT_PLATFORM_OS STREQUAL "windows")
	#probably need to do some specific things in windows
	return ()
else()#other systems
	#from here we will look into the symbols
	#first compiling with default
	try_compile(RES ${CMAKE_BINARY_DIR}
		SOURCES ${WORKSPACE_DIR}/cmake/platforms/checks/std_lib_version.cpp
		COPY_FILE std_lib_version
		OUTPUT_VARIABLE out)
	execute_process(COMMAND ${CMAKE_BINARY_DIR}/std_lib_version OUTPUT_VARIABLE name_version)

	if(name_version)
		list(GET name_version 0 lib_name)
		set(${NAME} ${lib_name} PARENT_SCOPE)
		list(GET name_version 1 version)
		if(version MATCHES "^([0-9]+)([0-9][0-9][0-9])$")#VERSION + REVISION
			set(${VERSION} ${CMAKE_MATCH_1}.${CMAKE_MATCH_2} PARENT_SCOPE)
		else()#only VERSION
			set(${VERSION} ${version} PARENT_SCOPE)
		endif()
	endif()
endif()
endfunction(get_Current_Standard_Library_Version)

#those two functions must be extended anytime a new standard C library is used
function(get_C_Standard_Library_Symbols_Version RES_SYMBOL_VERSIONS operating_system library_name path_to_library)
	set(STD_SYMBOLS)
	#symbols name depends on the standard library implementation...
	if(library_name STREQUAL "c")#gnu c library
		get_Library_ELF_Symbols_Max_Versions(STD_SYMBOLS ${path_to_library} "GLIBC_")
	elseif(library_name MATCHES "gcc")#gcc library
		get_Library_ELF_Symbols_Max_Versions(STD_SYMBOLS ${path_to_library} "GCC_")
	endif()
	set(${RES_SYMBOL_VERSIONS} ${STD_SYMBOLS} PARENT_SCOPE)
endfunction(get_C_Standard_Library_Symbols_Version)

function(get_CXX_Standard_Library_Symbols_Version RES_SYMBOL_VERSIONS RES_STD_ABI operating_system library_name path_to_library)
	set(STD_SYMBOLS)
	set(${RES_STD_ABI} PARENT_SCOPE)
	#symbols name depends on the standard library implementation...
	if(library_name MATCHES "stdc\\+\\+")#gnu c++ library (may be named stdc++11 as well)
		get_Library_ELF_Symbols_Max_Versions(STD_SYMBOLS ${path_to_library} "GLIBCXX_;CXXABI_")
		set(${RES_STD_ABI} DUAL PARENT_SCOPE)
	elseif(library_name MATCHES "c\\+\\+")#the new libc++ library
		#no ELF symbol version defined in libc++ => use inline namespace of c++11
		set(${RES_STD_ABI} NEW PARENT_SCOPE)
	# elseif(library_name STREQUAL "c++")#the new libc++ library
	endif()
	set(${RES_SYMBOL_VERSIONS} ${STD_SYMBOLS} PARENT_SCOPE)
endfunction(get_CXX_Standard_Library_Symbols_Version)

#resetting symbols to avoid any problem
set(C_STD_ABI_SYMBOLS)
set(C_STD_LIBS)
set(CXX_STD_ABI_SYMBOLS)
set(CXX_STD_LIBS)

set(CXX_STD_SYMBOLS CACHE INTERNAL "")
set(CXX_STANDARD_LIBRARIES CACHE INTERNAL "")
set(C_STD_SYMBOLS CACHE INTERNAL "")
set(C_STANDARD_LIBRARIES CACHE INTERNAL "")

#getting standard libraries for C and C++
set(IMPLICIT_CXX_LIBS ${CMAKE_CXX_IMPLICIT_LINK_LIBRARIES})
list(REMOVE_DUPLICATES IMPLICIT_CXX_LIBS)

set(IMPLICIT_C_LIBS ${CMAKE_C_IMPLICIT_LINK_LIBRARIES})
if(IMPLICIT_C_LIBS)
	list(REMOVE_DUPLICATES IMPLICIT_C_LIBS)
	list(REMOVE_ITEM IMPLICIT_CXX_LIBS ${IMPLICIT_C_LIBS})#simply remove the implicit C libs from CXX implicit libs (avoir doing two times same thing)
endif()

# detect current C library ABI in use
foreach(lib IN LISTS IMPLICIT_C_LIBS)
	#lib is the short name of the library
	find_Library_In_Implicit_System_Dir(VALID_PATH LIB_SONAME LIB_SOVERSION ${lib})
	if(VALID_PATH)
		#getting symbols versions from the implicit library
		get_C_Standard_Library_Symbols_Version(RES_SYMBOL_VERSIONS ${CURRENT_PLATFORM_OS} ${lib} ${VALID_PATH})
		while(RES_SYMBOL_VERSIONS)
			pop_ELF_Symbol_Version_From_List(SYMB VERS RES_SYMBOL_VERSIONS)
			serialize_Symbol(SERIALIZED_SYMBOL ${SYMB} ${VERS})
			list(APPEND C_STD_ABI_SYMBOLS ${SERIALIZED_SYMBOL})
		endwhile()
		list(APPEND C_STD_LIBS ${LIB_SONAME})
	endif()#otherwise simply do nothing and check with another folder
endforeach()

#memorize symbol versions
set(C_STD_SYMBOLS ${C_STD_ABI_SYMBOLS} CACHE INTERNAL "")
set(C_STANDARD_LIBRARIES ${C_STD_LIBS} CACHE INTERNAL "")

# detect current C++ library ABI in use
foreach(lib IN LISTS IMPLICIT_CXX_LIBS)
	#lib is the short name of the library
	find_Library_In_Implicit_System_Dir(VALID_PATH LIB_SONAME LIB_SOVERSION ${lib})
	if(VALID_PATH)
		#getting symbols versions from the implicit library
		get_CXX_Standard_Library_Symbols_Version(RES_SYMBOL_VERSIONS COMP_ABI ${CURRENT_PLATFORM_OS} ${lib} ${VALID_PATH})
		while(RES_SYMBOL_VERSIONS)
			pop_ELF_Symbol_Version_From_List(SYMB VERS RES_SYMBOL_VERSIONS)
			serialize_Symbol(SERIALIZED_SYMBOL ${SYMB} ${VERS})
			list(APPEND CXX_STD_ABI_SYMBOLS ${SERIALIZED_SYMBOL})#memorize symbol versions
		endwhile()
		list(APPEND CXX_STD_LIBS ${LIB_SONAME})
		if(COMP_ABI AND NOT COMP_ABI STREQUAL "DUAL")# the compiler ABI cannot be adapted
			set(FORCE_COMPILER_ABI ${COMP_ABI})
		endif()
	endif()#otherwise simply do nothing and check with another folder
endforeach()

set(CXX_STD_SYMBOLS ${CXX_STD_ABI_SYMBOLS} CACHE INTERNAL "")
set(CXX_STANDARD_LIBRARIES ${CXX_STD_LIBS} CACHE INTERNAL "")
get_Current_Standard_Library_Version(res_version res_name)
set(CXX_STD_LIBRARY_VERSION ${res_version} CACHE INTERNAL "")
set(CXX_STD_LIBRARY_NAME ${res_name} CACHE INTERNAL "")
#NOW check the C++ compiler ABI used to build the c++ standard library

set(CURRENT_ABI CACHE INTERNAL "")#reset value of current ABI
if( PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT
		AND NOT PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT STREQUAL "host")
		#we are not in the context of evaluating an environment or current host
		#So MAYBE there is no need to detect the ABI since specified using corresponding compiler flags provided by environment
		string(REGEX MATCH "-D_GLIBCXX_USE_CXX11_ABI=0" IS_LEGACY "${CMAKE_CXX_FLAGS}")
		if(IS_LEGACY)
			set(CURRENT_ABI CXX CACHE INTERNAL "")#reset value of current ABI
		else()
				string(REGEX MATCH "-D_GLIBCXX_USE_CXX11_ABI=1" IS_NEW "${CMAKE_CXX_FLAGS}")
				if(IS_NEW)
					set(CURRENT_ABI CXX11 CACHE INTERNAL "")#reset value of current ABI
				endif()
		endif()
endif()

# remove any compilation setting that forces a specific compiler ABI
#this line is needed to force the compiler to use libstdc++11 newer version of API whatever the version of the distribution is
#e.g. on ubuntu 14 with compiler gcc 5.4 the default value is 0 (legacy ABI)
set(TEMP_FLAGS "${CMAKE_CXX_FLAGS}")
string(REPLACE "-D_GLIBCXX_USE_CXX11_ABI=0" "" TEMP_FLAGS "${TEMP_FLAGS}")
string(REPLACE "-D_GLIBCXX_USE_CXX11_ABI=1" "" TEMP_FLAGS "${TEMP_FLAGS}")
string(STRIP "${TEMP_FLAGS}" TEMP_FLAGS)
set(CMAKE_CXX_FLAGS "${TEMP_FLAGS}" CACHE STRING "" FORCE)#needed for following system checks

#depending on symbol versions we can detect which compiler was used to build the standard library !!
if(NOT CURRENT_ABI)#no C++ ABI explictly specified
	if(CXX_STD_SYMBOLS) #there are versionned symbols
		#use default ABI of the binary version of current std libc++ in use
		foreach(symb IN LISTS CXX_STD_SYMBOLS) #detect ABI based on standard library symbols
			if(symb MATCHES "^<CXXABI_/([.0-9]+)>$")
				if(CMAKE_MATCH_1 VERSION_GREATER_EQUAL 1.3.9) #build from gcc 5.1 or more (or equivalent compiler ABI settings for clang)
					set(cxxabi_is_cxx11_capable TRUE)
				else()
					set(cxxabi_is_cxx11_capable FALSE)
				endif()
			elseif(symb MATCHES "^<GLIBCXX_/([.0-9]+)>$")
				if(CMAKE_MATCH_1 VERSION_GREATER_EQUAL 3.4.21) #build from gcc 5.1 or more (or equivalent compiler ABI settings for clang)
					set(glibcxx_is_cxx11_capable TRUE)
				else()
					set(glibcxx_is_cxx11_capable FALSE)
				endif()
			endif()
		endforeach()
		if(NOT cxxabi_is_cxx11_capable OR NOT glibcxx_is_cxx11_capable)
			set(CURRENT_ABI "CXX" CACHE INTERNAL "")#no need to question about ABI, it must be legacy ABI since this ABI is not implemented into the standard library
		else()# now the standard library is (theorically) capable of supporting CXX11 and legacy ABI
			#but the OS can impose the use of a given ABI : old systems impose the use of legacy ABI to enforce the binary compatiblity of their binary packages)
			#in the end on those system the standard library is only compiled with legacy ABI and so does not support CXX11 ABI
			check_Current_Standard_Library_Is_CXX11_ABI_Compatible(ALLOWED_CXX11)
			if(ALLOWED_CXX11)
				set(CURRENT_ABI "CXX11" CACHE INTERNAL "")
			else()
				set(CURRENT_ABI "CXX" CACHE INTERNAL "")
			endif()
		endif()
	else()
		# adding a generic fake symbol representing the version of the library
		# make it generic for every standard library in use
		if(CXX_STD_LIBRARY_VERSION)
			set(CXX_STD_SYMBOLS "<VERSION_/${CXX_STD_LIBRARY_VERSION}>" CACHE INTERNAL "")#will be used to checl std lib compatibility
		endif()
		if(FORCE_COMPILER_ABI STREQUAL "NEW")
			set(CURRENT_ABI "CXX11" CACHE INTERNAL "")
		elseif(ORCE_COMPILER_ABI STREQUAL "OLD")
			set(CURRENT_ABI "CXX" CACHE INTERNAL "")
		endif()
	endif()
endif()

# ABI detection is no more based on knowledge of the compiler version
#but now we check that minumum version of the compiler are used together with ABI CXX11 (not sure if we force a given ABI and did not detect it)
if(CURRENT_ABI STREQUAL "CXX11")#check that compiler in use supports the CXX11 ABI
	if(CURRENT_CXX_COMPILER STREQUAL "gcc")
		if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.1)#before version 5.1 of gcc the cxx11 abi is not supported
			message(FATAL_ERROR "[PID] CRITICAL ERROR : compiler in use (${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION}) does not support CXX11 ABI.")
		endif()
	elseif(CURRENT_CXX_COMPILER STREQUAL "clang")
		if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.8)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : compiler in use (${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION}) does not support CXX11 ABI.")
		endif()
	else()# add new support for compiler or use CMake generic mechanism to do so for instance : CURRENT_CXX_COMPILER STREQUAL "msvc"
		message("[PID] WARNING : compiler in use (${CMAKE_CXX_COMPILER_ID} version ${CMAKE_CXX_COMPILER_VERSION}) ABI support is not identified in PID.")
	endif()
endif()

if(FORCE_COMPILER_ABI)
	if(CURRENT_ABI STREQUAL "CXX11" AND FORCE_COMPILER_ABI STREQUAL "OLD")
		message(FATAL_ERROR "[PID] CRITICAL ERROR : new CXX11 ABI is not supported by standard library in use.")
	elseif(CURRENT_ABI STREQUAL "CXX" AND FORCE_COMPILER_ABI STREQUAL "NEW")
		message(FATAL_ERROR "[PID] CRITICAL ERROR : old CXX ABI is not supported by standard library in use.")
	endif()
else()# setting the C++ compiler flags adequately if DUAL abi is supported
	if(CURRENT_ABI STREQUAL "CXX11")
		set(CMAKE_CXX_FLAGS "${TEMP_FLAGS} -D_GLIBCXX_USE_CXX11_ABI=1" CACHE STRING "" FORCE)
	else()#using legacy ABI
		set(CMAKE_CXX_FLAGS "${TEMP_FLAGS} -D_GLIBCXX_USE_CXX11_ABI=0" CACHE STRING "" FORCE)
	endif()
endif()


#finally deal with compile flags
if(UNIX AND NOT APPLE)
	# need to deal also with linker option related to rpath/runpath. With recent version of the linker the RUNPATH is set by default NOT the RPATH
	# cmake does not manage this aspect it consider that this is always the RPATH in USE BUT this is not TRUE
	# so force the usage of a linker flag to deactivate the RUNPATH generation
	string(REPLACE "-Wl,--disable-new-dtags" "" CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
	if(NOT CMAKE_EXE_LINKER_FLAGS)
		set(CMAKE_EXE_LINKER_FLAGS "-Wl,--disable-new-dtags" CACHE STRING "" FORCE)
	endif()
	string(REPLACE "-Wl,--disable-new-dtags" "" CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS}")
	if(NOT CMAKE_MODULE_LINKER_FLAGS)
		set(CMAKE_MODULE_LINKER_FLAGS "-Wl,--disable-new-dtags" CACHE STRING "" FORCE)
	endif()
	string(REPLACE "-Wl,--disable-new-dtags" "" CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS}")
	if(NOT CMAKE_SHARED_LINKER_FLAGS)
		set(CMAKE_SHARED_LINKER_FLAGS "-Wl,--disable-new-dtags" CACHE STRING "" FORCE)
	endif()
endif()
