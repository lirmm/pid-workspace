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

found_PID_Configuration(libpng FALSE)

# - Find libpng installation
# Try to find libraries for libpng on UNIX systems. The following values are defined
#  libpng_FOUND        - True if libpng is available
#  libpng_LIBRARIES    - link against these to use libpng library
if (UNIX)

	find_path(libpng_INCLUDE_PATH png.h)
	find_library(libpng_LIB png)

	set(libpng_LIBRARIES) # start with empty list
	set(IS_FOUND TRUE)
	if(libpng_INCLUDE_PATH AND libpng_LIB)
		set(libpng_LIBRARIES -lpng)
	else()
		message("[PID] ERROR : cannot find png library.")
		set(IS_FOUND FALSE)
	endif()

	if(IS_FOUND)
		found_PID_Configuration(libpng TRUE)
	endif ()

	unset(IS_FOUND)
	unset(libpng_INCLUDE_PATH CACHE)
	unset(libpng_LIB CACHE)
endif ()
