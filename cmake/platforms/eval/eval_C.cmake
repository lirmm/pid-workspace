
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

set(C_EVAL_RESULT FALSE)
set(LANG_C_PLATFORM_CONSTRAINTS)

if(CMAKE_C_COMPILER)
  if(C_optimization)
    if(C_optimization STREQUAL "all" OR C_optimization STREQUAL "native")
    	#nothing to check just provide the exact list in binary constraints
    	set(C_optimization ${CURRENT_SPECIFIC_INSTRUCTION_SET})
    else()#only a subset of all processor instructions is required, check if they exist
    	foreach(opt IN LISTS C_optimization)
    		list(FIND CURRENT_SPECIFIC_INSTRUCTION_SET ${opt} INDEX)
    		if(INDEX EQUAL -1)
    			return()
    		endif()
    	endforeach()
    endif()
    set(FLAGS_FOR_OPTIMS)
    foreach(opt IN LISTS C_optimization)
      foreach(flag IN LISTS CPU_${opt}_FLAGS)#these variables can themselves contain list
        if(NOT CMAKE_C_FLAGS MATCHES "${flag}")#only add flag if not already used
          set(FLAGS_FOR_OPTIMS "${FLAGS_FOR_OPTIMS} ${flag}")
        endif()
      endforeach()
    endforeach()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${FLAGS_FOR_OPTIMS}" CACHE STRING "" FORCE)
  endif()
  set(C_soname ${C_STANDARD_LIBRARIES})
  set(C_symbol ${C_STD_SYMBOLS})
  set(C_EVAL_RESULT TRUE)
endif()
