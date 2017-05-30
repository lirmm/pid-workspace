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

set(libpng12_FOUND FALSE CACHE INTERNAL "")
# - Find libpng12 installation
# Try to find libraries for libpng12 on UNIX systems. The following values are defined
#  libpng12_FOUND        - True if libpng12 is available
#  libpng12_LIBRARIES    - link against these to use libpng12 library
if (UNIX)

	find_path(libpng12_INCLUDE_PATH libpng12/png.h)
	find_library(libpng12_LIB png12)

	set(libpng12_LIBRARIES) # start with empty list
	set(IS_FOUND TRUE)
	if(libpng12_INCLUDE_PATH AND libpng12_LIB)
		set(libpng12_LIBRARIES -lpng12)
	else()
		message("[PID] ERROR : cannot find png12 library.")
		set(IS_FOUND FALSE)
	endif()

	if(IS_FOUND)
		set(libpng12_FOUND TRUE CACHE INTERNAL "")
	endif ()

	unset(IS_FOUND)
	unset(libpng12_INCLUDE_PATH CACHE)
	unset(libpng12_LIB CACHE)
endif ()
