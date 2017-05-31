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

set(CURRENT_TYPE CACHE INTERNAL "")

#test of processor type is based on system variables affected by cross compilation
#So it adapts to the current development environment in use

if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL arm)
	set(CURRENT_TYPE arm CACHE INTERNAL "")
elseif(	"${CMAKE_SYSTEM_PROCESSOR}" STREQUAL x86
	OR "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL x64
	OR "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL i686
	OR "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL i386
	OR "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL i486
	OR "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL x86_32
	OR "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL x86_64
	OR "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL amd64)
	set(CURRENT_TYPE x86 CACHE INTERNAL "")
endif()# Note: add more check to test other processor architectures
