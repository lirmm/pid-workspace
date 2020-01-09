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

function(check_Current_OS_Allow_CXX11_ABI ALLOWED)
set(${ALLOWED} TRUE PARENT_SCOPE)#by default CXX11 is allowed

if(CURRENT_PLATFORM_OS STREQUAL windows)
	set(${ALLOWED} FALSE PARENT_SCOPE)#for now windows support only legacy ABI
	return ()
else()#other systems
	#from here we will look into the symbols
	try_compile(RES ${WORKSPACE_DIR}/pid
		SOURCES ${WORKSPACE_DIR}/cmake/platforms/checks/abi_check.cpp
		COPY_FILE abi_check
		OUTPUT_VARIABLE out)

	if(NOT RES)#cannot compile for unknow reason -> use a predefined check
		if(CURRENT_PLATFORM_OS STREQUAL linux)
			if(CURRENT_DISTRIBUTION STREQUAL ubuntu)
				if(CURRENT_DISTRIBUTION_VERSION VERSION_LESS 16.04)
					set(${ALLOWED} FALSE PARENT_SCOPE)#ubuntu < 16.04
				endif()
			endif()
		endif()
		return()
	endif()

	execute_process(COMMAND ${CMAKE_NM} ${WORKSPACE_DIR}/pid/abi_check OUTPUT_VARIABLE check_symbols)
	string(FIND ${check_symbols} "__cxx11" INDEX)
	if(INDEX EQUAL -1)#no cxx11 abi symbol found -> it is a legacy abi by default
		set(${ALLOWED} FALSE PARENT_SCOPE)
		return()
	endif()
endif()
endfunction(check_Current_OS_Allow_CXX11_ABI)

set(CURRENT_ABI CACHE INTERNAL "")

function(get_Standard_Library_Symbols_Version RES_SYMBOL_VERSIONS operating_system library_name path_to_library)
	set(STD_SYMBOLS)
	#symbols name depends on the standard library implementation...
	if(library_name MATCHES "stdc\\+\\+")#gnu c++ library (may be named stdc++11 as well)
		get_Library_ELF_Symbols_Max_Versions(STD_SYMBOLS ${path_to_library} "GLIBCXX_;CXXABI_")
	#elseif(library_name STREQUAL "c++")#the new libc++ library
	elseif(library_name STREQUAL "c")#gnu c library
		get_Library_ELF_Symbols_Max_Versions(STD_SYMBOLS ${path_to_library} "GLIBC_")
		#what to do ??
	elseif(library_name MATCHES "gcc")#gcc library
		get_Library_ELF_Symbols_Max_Versions(STD_SYMBOLS ${path_to_library} "GCC_")
		#what to do ??
	endif()
	set(${RES_SYMBOL_VERSIONS} ${STD_SYMBOLS} PARENT_SCOPE)
endfunction(get_Standard_Library_Symbols_Version)

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

set(IMPLICIT_LIBS ${CMAKE_CXX_IMPLICIT_LINK_LIBRARIES})
set(IMPLICIT_DIRS ${CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES})
list(REMOVE_DUPLICATES IMPLICIT_LIBS)
list(REMOVE_DUPLICATES IMPLICIT_DIRS)
# detect current C++ library ABI in use
foreach(lib IN LISTS IMPLICIT_LIBS)
	#lib is the short name of the library
	find_Library_In_Implicit_System_Dir(VALID_PATH LIB_SONAME LIB_SOVERSION ${lib})
	if(VALID_PATH)
		if(LIB_SOVERSION)
			set(CXX_STD_LIB_${lib}_ABI_SOVERSION ${LIB_SOVERSION} CACHE INTERNAL "")
		endif()
		#getting symbols versions from the implicit library
		get_Standard_Library_Symbols_Version(RES_SYMBOL_VERSIONS ${CURRENT_OS} ${lib} ${VALID_PATH})
		while(RES_SYMBOL_VERSIONS)
			pop_ELF_Symbol_Version_From_List(SYMB VERS RES_SYMBOL_VERSIONS)
			list(APPEND STD_ABI_SYMBOLS ${SYMB})
			set(${SYMB}_ABI_VERSION ${VERS})
		endwhile()
		list(APPEND STD_LIBS ${lib})
	endif()#otherwise simply do nothing and check with another folder
endforeach()

#memorize symbol versions
if(STD_ABI_SYMBOLS)
	list(REMOVE_DUPLICATES STD_ABI_SYMBOLS)
	foreach(symbol IN LISTS STD_ABI_SYMBOLS)
		set(CXX_STD_SYMBOL_${symbol}_VERSION ${${symbol}_ABI_VERSION} CACHE INTERNAL "")
	endforeach()
endif()
set(CXX_STD_SYMBOLS ${STD_ABI_SYMBOLS} CACHE INTERNAL "")
set(CXX_STANDARD_LIBRARIES ${STD_LIBS} CACHE INTERNAL "")

#depending on symbol versions we can detect which compiler was used to build the standard library !!
list(FIND CMAKE_CXX_FLAGS "-D_GLIBCXX_USE_CXX11_ABI=1" INDEX)
if(NOT INDEX EQUAL -1)#there is a flag that explicilty sets the ABI to 11
		set(CURRENT_ABI "CXX11" CACHE INTERNAL "")
else()
	list(FIND CMAKE_CXX_FLAGS "-D_GLIBCXX_USE_CXX11_ABI=0" INDEX)
	if(NOT INDEX EQUAL -1)#there is a flag that explicilty sets the ABI to 98
			set(CURRENT_ABI "CXX" CACHE INTERNAL "")
	else()
		set(CURRENT_ABI CACHE INTERNAL "")
	endif()
endif()

if(NOT CURRENT_ABI)#no ABI explictly specified
	#use default ABI of the binary version of current std libc++ in use
	foreach(symb IN LISTS STD_ABI_SYMBOLS)
		if(symb STREQUAL "CXXABI_")
			if(NOT ${symb}_ABI_VERSION VERSION_LESS 1.3.9) #build from gcc 5.1 or more (or equivalent compiler ABI settings for clang)
				set(cxxabi_is_cxx11_capable TRUE)
			else()
				set(cxxabi_is_cxx11_capable FALSE)
			endif()
		elseif(symb STREQUAL "GLIBCXX_")
			if(NOT ${symb}_ABI_VERSION VERSION_LESS 3.4.21) #build from gcc 5.1 or more (or equivalent compiler ABI settings for clang)
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
		check_Current_OS_Allow_CXX11_ABI(ALLOWED_CXX11)
		if(ALLOWED_CXX11)
			set(CURRENT_ABI "CXX11" CACHE INTERNAL "")
		else()
			set(CURRENT_ABI "CXX" CACHE INTERNAL "")
		endif()
	endif()
endif()



# ABI detection is no more based on knowledge of the compiler version
#but now we check that minumum version of the compiler are used together with ABI CXX11
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
