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

include(Configuration_Definition NO_POLICY_SCOPE)

found_PID_Configuration(zlib FALSE)

# - Find zlib installation
# Try to find libraries for zlib on UNIX systems. The following values are defined
#  zlib_FOUND        - True if zlib is available
#  zlib_LIBRARIES    - link against these to use zlib library
if (UNIX)

	find_path(zlib_INCLUDE_PATH zlib.h)
	find_library(zlib_LIB z)

	set(zlib_LIBRARIES) # start with empty list
	set(IS_FOUND TRUE)
	if(zlib_INCLUDE_PATH AND zlib_LIB)
		set(zlib_LIBRARIES -lz)
	else()
		message("[PID] ERROR : cannot find zlib library.")
		set(IS_FOUND FALSE)
	endif()

	if(IS_FOUND)
		found_PID_Configuration(zlib TRUE)
	endif ()

	unset(IS_FOUND)
	unset(zlib_INCLUDE_PATH CACHE)
	unset(zlib_LIB CACHE)
endif ()
