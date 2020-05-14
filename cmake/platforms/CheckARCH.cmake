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

set(CURRENT_PLATFORM_ARCH CACHE INTERNAL "")

#test of processor architecture is based on the compiler used
#So it adapts to the current development environment in use
if(CMAKE_SIZEOF_VOID_P EQUAL 2)
	set(CURRENT_PLATFORM_ARCH 16 CACHE INTERNAL "")
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
	set(CURRENT_PLATFORM_ARCH 32 CACHE INTERNAL "")
elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
	set(CURRENT_PLATFORM_ARCH 64 CACHE INTERNAL "")
endif()
