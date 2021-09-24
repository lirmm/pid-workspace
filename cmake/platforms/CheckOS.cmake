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

set(CURRENT_PACKAGE_STRING CACHE INTERNAL "")
set(CURRENT_PLATFORM_OS CACHE INTERNAL "")
set(CURRENT_PLATFORM_INSTANCE ${PID_USE_INSTANCE_NAME} CACHE INTERNAL "")#reset with current value of instance name

#test of the os is based on the compiler used  (APPLE and UNIX variables) AND on system variables affected by crosscompilation (CMAKE_SYSTEM_NAME)
#So it adapts to the current development environment in use

#By default package string is the system name in CMake
if(CMAKE_SYSTEM_NAME)
	set(CURRENT_PACKAGE_STRING "${CMAKE_SYSTEM_NAME}" CACHE INTERNAL "")
endif()
if(WIN32)
	set(CURRENT_PLATFORM_OS "windows" CACHE INTERNAL "")
	# set(CURRENT_PACKAGE_STRING "NT" CACHE INTERNAL "") #TODO check if mandatory or not to force this
elseif(UNIX AND APPLE AND CMAKE_SYSTEM_NAME STREQUAL Darwin) #darwin = kernel name for macos systems
	set(CURRENT_PLATFORM_OS "macos"  CACHE INTERNAL "")
elseif(UNIX)
	if(CMAKE_SYSTEM_NAME STREQUAL Linux)# linux kernel = the reference !!
		set(CURRENT_PLATFORM_OS "linux" CACHE INTERNAL "")
	elseif(CMAKE_SYSTEM_NAME STREQUAL FreeBSD)# free BSD kernel
		set(CURRENT_PLATFORM_OS "freebsd" CACHE INTERNAL "")
	endif()
endif()

if(NOT CURRENT_PLATFORM_OS)
	message("[PID] WARNING: no OS detected. Maybe targetting bare metal ?")
endif()