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

function(get_Fortran_Standard_Library_Symbols_Version RES_SYMBOL_VERSIONS operating_system library_name path_to_library)
	set(STD_SYMBOLS)
	#symbols name depends on the standard library implementation...
	if(library_name MATCHES "gfortran")#gfortran library
		get_Library_ELF_Symbols_Max_Versions(STD_SYMBOLS ${path_to_library} "GFORTRAN_;GFORTRAN_C99_")
		#what to do ??
	elseif(library_name MATCHES "quadmath")#quadmath library
		get_Library_ELF_Symbols_Max_Versions(STD_SYMBOLS ${path_to_library} "QUADMATH_")
		#what to do ??
	endif()
	set(${RES_SYMBOL_VERSIONS} ${STD_SYMBOLS} PARENT_SCOPE)
endfunction(get_Fortran_Standard_Library_Symbols_Version)

set(Fortran_Language_AVAILABLE FALSE CACHE INTERNAL "")
check_language(Fortran)
if(CMAKE_Fortran_COMPILER) #ONLY ENABLE FORTRAN if a Fortran toolchain is available
  enable_language(Fortran) #enable FORTRAN language will generate appropriate variables
  set(Fortran_Language_AVAILABLE TRUE CACHE INTERNAL "")
else()#cannot find fortran => exitting
  return()
endif()

foreach(symbol IN LISTS Fortran_STD_SYMBOLS)
	set(Fortran_STD_SYMBOL_${symbol}_VERSION CACHE INTERNAL "")
endforeach()
set(Fortran_STD_SYMBOLS CACHE INTERNAL "")

set(Fortran_STANDARD_LIBRARIES CACHE INTERNAL "")

set(IMPLICIT_Fortran_LIBS ${CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES})
list(REMOVE_ITEM IMPLICIT_Fortran_LIBS ${CMAKE_CXX_IMPLICIT_LINK_LIBRARIES} ${CMAKE_C_IMPLICIT_LINK_LIBRARIES})
#check if libraries are not an implicit C/C++ library (otherwise already managed)
set(Fortran_STD_LIBS)
set(Fortran_STD_ABI_SYMBOLS)
# detect current C++ library ABI in use
foreach(lib IN LISTS IMPLICIT_Fortran_LIBS)
	#lib is the short name of the library
	find_Library_In_Implicit_System_Dir(VALID_PATH LIB_SONAME LIB_SOVERSION ${lib})
	if(VALID_PATH)
		#getting symbols versions from the implicit library
		get_Fortran_Standard_Library_Symbols_Version(RES_SYMBOL_VERSIONS ${CURRENT_PLATFORM_OS} ${lib} ${VALID_PATH})
		while(RES_SYMBOL_VERSIONS)
			pop_ELF_Symbol_Version_From_List(SYMB VERS RES_SYMBOL_VERSIONS)
      serialize_Symbol(SERIALIZED_SYMBOL ${SYMB} ${VERS})
			list(APPEND Fortran_STD_ABI_SYMBOLS ${SERIALIZED_SYMBOL})#memorize symbol versions
		endwhile()
		list(APPEND Fortran_STD_LIBS ${LIB_SONAME})
	endif()#otherwise simply do nothing and check with another folder
endforeach()

set(Fortran_STANDARD_LIBRARIES ${Fortran_STD_LIBS} CACHE INTERNAL "")
set(Fortran_STD_SYMBOLS ${Fortran_STD_ABI_SYMBOLS} CACHE INTERNAL "")
