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
# ABI detection is based on knowledge of the compiler version
# so it automatically adapts to the development environment in use
if(CMAKE_COMPILER_IS_GNUCXX)
	if(NOT ${CMAKE_CXX_COMPILER_VERSION} VERSION_LESS 5.1)
		set(CURRENT_ABI "CXX11" CACHE INTERNAL "")
	else()
		set(CURRENT_ABI "CXX" CACHE INTERNAL "")
	endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang" OR CMAKE_CXX_COMPILER_ID STREQUAL "clang")
	if(NOT ${CMAKE_CXX_COMPILER_VERSION} VERSION_LESS 3.8)
		set(CURRENT_ABI "CXX11" CACHE INTERNAL "")
	else()
		set(CURRENT_ABI "CXX" CACHE INTERNAL "")
	endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
	set(CURRENT_ABI "CXX" CACHE INTERNAL "")
# add new support for compiler or use CMake generic mechanism to do so
endif()
