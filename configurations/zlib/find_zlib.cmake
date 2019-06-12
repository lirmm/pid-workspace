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

	find_path(zlib_INCLUDE_DIR zlib.h)
	find_library(zlib_LIBRARY z)

	set(zlib_INCLUDE_PATH ${zlib_INCLUDE_DIR})
	set(zlib_LIB ${zlib_LIBRARY})
	unset(zlib_INCLUDE_DIR CACHE)
	unset(zlib_LIBRARY CACHE)

	if(zlib_INCLUDE_PATH AND zlib_LIB)
		convert_PID_Libraries_Into_System_Links(zlib_LIB ZLIB_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(zlib_LIB ZLIB_LIBDIRS)

		found_PID_Configuration(zlib TRUE)
	else()
		message("[PID] ERROR : cannot find zlib library.")
	endif()
endif ()
