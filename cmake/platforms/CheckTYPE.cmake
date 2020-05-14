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

set(CURRENT_PLATFORM_TYPE CACHE INTERNAL "")

#test of processor type is based on system variables affected by cross compilation
#So it adapts to the current development environment in use
if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86|x64|i686|i386|i486|x86_32|x86_64|amd64|AMD64")
	set(CURRENT_PLATFORM_TYPE x86 CACHE INTERNAL "")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "arm|ARM|aarch64|AARCH64")
	set(CURRENT_PLATFORM_TYPE arm CACHE INTERNAL "")
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "powerpc64|ppc64|ppc64le|powerpc64le|ppc")
	set(CURRENT_PLATFORM_TYPE ppc CACHE INTERNAL "")
else()# Note: add more check to test other processor architectures
	message(FATAL_ERROR "[PID] CRITICAL ERROR: unsupported processor architecture")
endif()
