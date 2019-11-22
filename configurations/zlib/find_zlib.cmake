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
	set(ZLIB_INCLUDE_PATH ${zlib_INCLUDE_DIR})
	unset(zlib_INCLUDE_DIR CACHE)

	#first try to find zlib in implicit system path
	find_PID_Library_In_Linker_Order(z ALL ZLIB_LIB ZLIB_SONAME)

	if(ZLIB_INCLUDE_PATH AND ZLIB_LIB)
		convert_PID_Libraries_Into_System_Links(ZLIB_LIB ZLIB_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(ZLIB_LIB ZLIB_LIBDIRS)
		extract_Symbols_From_PID_Libraries(ZLIB_LIB "ZLIB_" ZLIB_SYMBOLS)
		found_PID_Configuration(zlib TRUE)
	else()
		message("[PID] ERROR : cannot find zlib library.")
	endif()
endif ()
