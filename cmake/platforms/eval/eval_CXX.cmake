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
  #first check for compilers
  list(FIND KNOWN_CXX_COMPILERS ${CURRENT_CXX_COMPILER} INDEX)
  if(INDEX EQUAL -1)
    message(WARNING "[PID] WARNING: unsupported compiler ${CURRENT_CXX_COMPILER}")
    return()
  else()
    foreach(std IN LISTS KNOWN_CXX_STANDARDS)
      if(${CURRENT_CXX_COMPILER}_std${std}_BEGIN_SUPPORT 
        AND CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL ${CURRENT_CXX_COMPILER}_std${std}_BEGIN_SUPPORT)
        list(APPEND compiler_support_up_to ${std})
      endif()

    endforeach()
  endif()
  #then check for standard library
  list(FIND KNOWN_CXX_STDLIBS ${CXX_STD_LIBRARY_NAME} INDEX)
  if(INDEX EQUAL -1)
    message(WARNING "[PID] WARNING: unsupported library ${CXX_STD_LIBRARY_NAME}")
    return()
  else()
    foreach(std IN LISTS KNOWN_CXX_STANDARDS)
      if(${CXX_STD_LIBRARY_NAME}_std${std}_BEGIN_SUPPORT
          AND CXX_STD_LIBRARY_VERSION VERSION_GREATER_EQUAL ${CXX_STD_LIBRARY_NAME}_std${std}_BEGIN_SUPPORT)
        list(APPEND stdlib_support_up_to ${std})
      endif()
    endforeach()
  endif()
  #finally compute possibly usable standards
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
  if(CXX_optimization)#requied optimizations for build
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
    #if optimizations are required then add the flags to the cxx flags
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${FLAGS_FOR_OPTIMS}" CACHE STRING "" FORCE)
  endif()
  if(CXX_proc_optimization)#just check that optimization are available for the proc
    if(CXX_proc_optimization STREQUAL "all" OR CXX_proc_optimization STREQUAL "native")
    	#nothing to check just provide the exact list in binary constraints
    	set(CXX_proc_optimization ${CURRENT_SPECIFIC_INSTRUCTION_SET})
    else()#only a subset of all processor instructions is required, check if they exist
      foreach(opt IN LISTS CXX_proc_optimization)
        list(FIND CURRENT_SPECIFIC_INSTRUCTION_SET ${opt} INDEX)
        if(INDEX EQUAL -1)
          return()
        endif()
      endforeach()
    endif()
  endif()
  if(CXX_std)
    #1) get supported standards
    check_Standards_Supported_By_Compiler_And_StdLib(POSSIBLE_STDS)
    #2) check that required standard is supported
    list(FIND POSSIBLE_STDS ${CXX_std} INDEX)
    if(INDEX EQUAL -1)
      if(ADDITIONAL_DEBUG_INFO)
        message(WARNING "[PID] WARNING: required c++ standard ${CXX_std} is not supported by current toolset !")
      endif()
      return()
    endif()
    #3) set options depending on compiler and required support
    get_Platform_Configurations_To_Check(${CXX_std})
  endif()
  set(CXX_soname ${CXX_STANDARD_LIBRARIES})
  set(CXX_symbol ${CXX_STD_SYMBOLS})
  set(list_of_optims ${CXX_proc_optimization} ${CXX_optimization})
  if(list_of_optims)
    list(REMOVE_DUPLICATES list_of_optims)
  endif()
  set(CXX_proc_optimization ${list_of_optims})
  if(NOT CXX_std)#no standard support required at package level
    set(CXX_std 98)#use minimum standard
  endif()
  if(CXX_compiler_min)
    string(REPLACE "," ";" OUT_COMPILERS_MIN "${CXX_compiler_min}")
    foreach(constraint IN LISTS OUT_COMPILERS_MIN)
      if(constraint MATCHES "^(.+)-(.+)$")
        if(CMAKE_MATCH_1 STREQUAL CURRENT_CXX_COMPILER)
          if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS CMAKE_MATCH_2)
            message(WARNING "[PID] WARNING: ${CURRENT_CXX_COMPILER} C++ compiler version ${CMAKE_CXX_COMPILER_VERSION} < ${CMAKE_MATCH_2}, constraint violated")
          endif()
        break()
        endif()
      endif()
    endforeach()
  endif()
  if(CXX_stdlib_min)
    string(REPLACE "," ";" OUT_STDLIB_MIN "${CXX_stdlib_min}")
    foreach(constraint IN LISTS OUT_STDLIB_MIN)
      if(constraint MATCHES "^(.+)-(.+)$")
        if(CMAKE_MATCH_1 STREQUAL CXX_STD_LIBRARY_NAME)
          if(CXX_STD_LIBRARY_VERSION VERSION_LESS CMAKE_MATCH_2)
            message(WARNING "[PID] WARNING: ${CXX_STD_LIBRARY_NAME} C++ standard library version ${CXX_STD_LIBRARY_VERSION} < ${CMAKE_MATCH_2}, constraint violated")
          endif()
          break()
        endif()
      endif()
    endforeach()

  endif()
  set(CXX_EVAL_RESULT TRUE)
endif()
