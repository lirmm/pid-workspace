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

set(libjpeg_FOUND FALSE CACHE INTERNAL "")
# - Find libjpeg installation
# Try to find libraries for libjpeg on UNIX systems. The following values are defined
#  libjpeg_FOUND        - True if libjpeg is available
#  libjpeg_LIBRARIES    - link against these to use libjpeg library
if (UNIX)

	find_path(libjpeg_INCLUDE_PATH jpeglib.h)
	find_library(libjpeg_LIB jpeg)

	set(libjpeg_LIBRARIES) # start with empty list
	set(IS_FOUND TRUE)
	if(libjpeg_INCLUDE_PATH AND libjpeg_LIB)
		set(libjpeg_LIBRARIES -ljpeg)
	else()
		message("[PID] ERROR : cannot find jpeg library.")
		set(IS_FOUND FALSE)
	endif()

	if(IS_FOUND)
		set(libjpeg_FOUND TRUE CACHE INTERNAL "")
	endif ()

	unset(IS_FOUND)
	unset(libjpeg_INCLUDE_PATH CACHE)
	unset(libjpeg_LIB CACHE)
endif ()
