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

set(LANG_Python_PLATFORM_CONSTRAINTS)
set(Python_EVAL_RESULT FALSE)

if(CURRENT_PYTHON_EXECUTABLE)
 if(Python_interpreter_min)
    if(constraint MATCHES "^([0-9]+\\.[0-9]+$")
      if(CMAKE_MATCH_1 VERSION_LESS CURRENT_PYTHON)
          set(Python_EVAL_RESULT FALSE)
          message(FATAL_ERROR "[PID] CRITICAL ERROR: ${CURRENT_PYTHON_EXECUTABLE} Python interpreter version ${CURRENT_PYTHON} < ${CMAKE_MATCH_1}, constraint violated")
      endif()
    endif()
  endif()
  set(Python_EVAL_RESULT TRUE)
  set(Python_soname ${Python_STANDARD_LIBRARIES})
endif()
