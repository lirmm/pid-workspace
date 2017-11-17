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

if(${CMAKE_MAJOR_VERSION} GREATER 2 AND ${CMAKE_MINOR_VERSION} GREATER 2)

	find_program(IWYU_PATH include-what-you-use)
	if(IWYU_PATH)
		set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${IWYU_PATH} CACHE STRING "" FORCE)
		set(CMAKE_C_INCLUDE_WHAT_YOU_USE ${IWYU_PATH} CACHE STRING "" FORCE)
	else()
		unset(CMAKE_CXX_INCLUDE_WHAT_YOU_USE CACHE)
		unset(CMAKE_C_INCLUDE_WHAT_YOU_USE CACHE)
		message("\n[IWYU] The include-what-you-use executable cannnot be found. Make sure it is in your PATH.\n")
	endif()

endif()
