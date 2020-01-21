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

found_PID_Configuration(libraw1394 FALSE)

# - Find libraw1394 installation
# Try to find libraries for libraw1394 on UNIX systems. The following values are defined
#  libraw1394_FOUND        - True if libraw1394 is available
#  libraw1394_LIBRARIES    - link against these to use libraw1394 library
if (UNIX)

	find_path(LIBRAW1394_INCLUDE_PATH libraw1394/raw1394.h)#find the path of the library
	set(LIBRAW1394_INCLUDE_DIR ${LIBRAW1394_INCLUDE_PATH})
	unset(LIBRAW1394_INCLUDE_PATH CACHE)

	#first try to find zlib in implicit system path
	find_PID_Library_In_Linker_Order(raw1394 ALL LIBRAW1394_LIB LIBRAW1394_SONAME)
	if(LIBRAW1394_INCLUDE_DIR AND LIBRAW1394_LIB)
		convert_PID_Libraries_Into_System_Links(LIBRAW1394_LIB LIBRAW1394_LINKS)#getting good system links (with -l)
    	convert_PID_Libraries_Into_Library_Directories(LIBRAW1394_LIB LIBRAW1394_LIBDIR)
		found_PID_Configuration(libraw1394 TRUE)
	else()
		message("[PID] ERROR : cannot find Raw1394 library (found include=${LIBRAW1394_INCLUDE_DIR}, library=${LIBRAW1394_LIB}).")
	endif()

endif ()
