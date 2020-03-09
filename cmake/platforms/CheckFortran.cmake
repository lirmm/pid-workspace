

set(Fortran_Language_AVAILABLE FALSE CACHE INTERNAL "")

if(NOT PID_CROSSCOMPILATION)
  include(${CMAKE_ROOT}/Modules/CheckLanguage.cmake)
  check_language(Fortran)
endif()

if(CMAKE_Fortran_COMPILER) #ONLY ENABLE FORTRAN if a Fortran toolchain is available
  enable_language(Fortran) #enable FORTRAN language will generate appropriate variables
  set(Fortran_Language_AVAILABLE TRUE CACHE INTERNAL "")
else()
  message("[PID] WARNING : Fortran language is not supported because no Fortran compiler has been found.")
endif()

foreach(symbol IN LISTS Fortran_STD_SYMBOLS)
	set(Fortran_STD_SYMBOL_${symbol}_VERSION CACHE INTERNAL "")
endforeach()
set(Fortran_STD_SYMBOLS CACHE INTERNAL "")

foreach(lib IN LISTS Fortran_STANDARD_LIBRARIES)
	set(Fortran_STD_LIB_${lib}_ABI_SOVERSION CACHE INTERNAL "")
endforeach()
set(Fortran_STANDARD_LIBRARIES CACHE INTERNAL "")

set(IMPLICIT_LIBS ${CMAKE_Fortran_IMPLICIT_LINK_LIBRARIES})
set(IMPLICIT_DIRS ${CMAKE_Fortran_IMPLICIT_LINK_DIRECTORIES})
list(REMOVE_DUPLICATES IMPLICIT_LIBS)
list(REMOVE_DUPLICATES IMPLICIT_DIRS)
set(STD_LIBS)
set(STD_ABI_SYMBOLS)
# detect current C++ library ABI in use
foreach(lib IN LISTS IMPLICIT_LIBS)
  list(FIND CXX_STANDARD_LIBRARIES ${lib} INDEX)
  if(INDEX EQUAL -1)#check if the library is not an implicit C++ library (otherwise alrteady managed)
  	#lib is the short name of the library
  	find_Library_In_Implicit_System_Dir(VALID_PATH LIB_SONAME LIB_SOVERSION ${lib})
  	if(VALID_PATH)
  		if(LIB_SOVERSION)
  			set(Fortran_STD_LIB_${lib}_ABI_SOVERSION ${LIB_SOVERSION} CACHE INTERNAL "")
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
  endif()
endforeach()

#memorize symbol versions
if(STD_ABI_SYMBOLS)
	list(REMOVE_DUPLICATES STD_ABI_SYMBOLS)
	foreach(symbol IN LISTS STD_ABI_SYMBOLS)
		set(Fortran_STD_SYMBOL_${symbol}_VERSION ${${symbol}_ABI_VERSION} CACHE INTERNAL "")
	endforeach()
endif()

set(Fortran_STANDARD_LIBRARIES ${STD_LIBS} CACHE INTERNAL "")
set(Fortran_STD_SYMBOLS ${STD_ABI_SYMBOLS} CACHE INTERNAL "")
