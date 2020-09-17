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
function(check_Standards_Supported_By_Compiler_And_StdLib LIST_OF_STDS)
  set(${LIST_OF_STDS} PARENT_SCOPE)
  set(compiler_support_up_to 98)
  set(stdlib_support_up_to 98)
  #MOST of information comes from https://en.cppreference.com/w/cpp/compiler_support
  #first check for compilers
  if(CURRENT_CXX_COMPILER STREQUAL "gcc")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 4.8.1)#before version 4.8.1 of gcc the c++ 11 standard is not fully supported
      list(APPEND compiler_support_up_to 11)
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 5)#before version 5.0 of gcc the c++ 14 standard is not fully supported
      list(APPEND compiler_support_up_to 14)
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 9.1)#before version 9.1 of gcc the c++ 17 standard is not fully supported
      list(APPEND compiler_support_up_to 17)
    endif()
  elseif(CURRENT_CXX_COMPILER STREQUAL "clang")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 3.3)#before version 3.3 of clang the c++ 11 standard is not fully supported
      list(APPEND compiler_support_up_to 11)
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 3.4)#before version 3.4 of clang the c++ 14 standard is not fully supported
      list(APPEND compiler_support_up_to 14)
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 6)#before version 6 of clang the c++ 17 standard is not fully supported
      list(APPEND compiler_support_up_to 17)
    endif()
  elseif(CURRENT_CXX_COMPILER STREQUAL "appleclang")
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 10.0)#since version 10.0 all features are supported
      list(APPEND compiler_support_up_to 11 14 17)
    endif()
  elseif(CURRENT_CXX_COMPILER STREQUAL "msvc")#MSVC == windows == A specific standard library
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.14)#before version 19.14 of MSVC the c++ 11 and 14 standards are not fully supported
      list(APPEND compiler_support_up_to 11 14)
      list(APPEND stdlib_support_up_to 11 14)
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 19.24)#before version 19.24 of MSVC the c++ 17 standard is not fully supported
      list(APPEND compiler_support_up_to 17)
      list(APPEND stdlib_support_up_to 17)
    endif()
  elseif(CURRENT_CXX_COMPILER STREQUAL "icc")#intel compiler
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 15.0)
      list(APPEND compiler_support_up_to 11)
    endif()
    if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 17.0)
      list(APPEND compiler_support_up_to 14)
    endif()
  else()
    message(WARNING "[PID] unsupported compiler : ${CURRENT_CXX_COMPILER}")
    return()
  endif()
  #then check for standard library
  if(CXX_STD_LIBRARY_NAME STREQUAL "stdc++")
    if(CXX_STD_LIBRARY_VERSION VERSION_GREATER_EQUAL 6)#before version 6 of stdc++ the c++ 11 standard is not fully supported
      list(APPEND stdlib_support_up_to 11 14)
    endif()
    if(CXX_STD_LIBRARY_VERSION VERSION_GREATER_EQUAL 9)#before version 9 of stdc++ the c++ 17 standard is not fully supported
      list(APPEND stdlib_support_up_to 17)
    endif()
  elseif(CXX_STD_LIBRARY_NAME STREQUAL "c++")
    if(CXX_STD_LIBRARY_VERSION VERSION_GREATER_EQUAL 3.8)#before version 3.8 of c++ the c++ 11 standard is not fully supported
      list(APPEND stdlib_support_up_to 11 14)
    endif()
    #no full support of c++17 right now
  endif()
  #now
  set(support_up_to)
  foreach(libstd IN LISTS stdlib_support_up_to)
    list(FIND compiler_support_up_to ${libstd} INDEX)
    if(NOT INDEX EQUAL -1)# support of standard in library but also in compiler
      list(APPEND support_up_to ${libstd})
    endif()
  endforeach()
  set(${LIST_OF_STDS} ${support_up_to} PARENT_SCOPE)
endfunction(check_Standards_Supported_By_Compiler_And_StdLib)

macro(get_Platform_Configurations_To_Check used_std)
  if(${used_std} EQUAL 17)
    if(CXX_STD_LIBRARY_NAME STREQUAL "stdc++")#for now support for threading is implemented with tbb
      set(LANG_CXX_PLATFORM_CONSTRAINTS intel_tbb)
    endif()
  endif()
endmacro(get_Platform_Configurations_To_Check)

set(LANG_CXX_PLATFORM_CONSTRAINTS)
set(CXX_EVAL_RESULT FALSE)

if(CMAKE_CXX_COMPILER)
  if(CXX_optimization)
    if(CXX_optimization STREQUAL "all" OR CXX_optimization STREQUAL "native")
    	#nothing to check just provide the exact list in binary constraints
    	set(CXX_optimization ${CURRENT_SPECIFIC_INSTRUCTION_SET})
    else()#only a subset of all processor instructions is required, check if they exist
    	foreach(opt IN LISTS CXX_optimization)
    		list(FIND CURRENT_SPECIFIC_INSTRUCTION_SET ${opt} INDEX)
    		if(INDEX EQUAL -1)
    			return()
    		endif()
    	endforeach()
    endif()
    set(FLAGS_FOR_OPTIMS)
    foreach(opt IN LISTS CXX_optimization)
      foreach(flag IN LISTS CPU_${opt}_FLAGS)#these variables can themselves contain list
        if(NOT CMAKE_CXX_FLAGS MATCHES "${flag}")#only add flag if not already used
          set(FLAGS_FOR_OPTIMS "${FLAGS_FOR_OPTIMS} ${flag}")
        endif()
      endforeach()
    endforeach()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${FLAGS_FOR_OPTIMS}" CACHE STRING "" FORCE)
  endif()
  if(CXX_std)
    #1) get supported standards
    check_Standards_Supported_By_Compiler_And_StdLib(POSSIBLE_STDS)
    #2) check that required standard is supported
    list(FIND POSSIBLE_STDS ${CXX_std} INDEX)
    if(INDEX EQUAL -1)
      message("[PID] ERROR: required c++ standard ${CXX_std} is not supported by current compiler !")
      return()
    endif()
    #3) set options depending on compiler and required support
    get_Platform_Configurations_To_Check(${CXX_std})

  endif()
  set(CXX_soname ${CXX_STANDARD_LIBRARIES})
  set(CXX_symbol ${CXX_STD_SYMBOLS})
  set(CXX_EVAL_RESULT TRUE)
endif()
