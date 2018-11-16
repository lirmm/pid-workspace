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

found_PID_Configuration(libjpeg FALSE)

# - Find libjpeg installation
# Try to find libraries for libjpeg on UNIX systems. The following values are defined
#  libjpeg_FOUND        - True if libjpeg is available
if (UNIX)

	find_path(libjpeg_INCLUDE_PATH jpeglib.h)
	find_library(libjpeg_LIB jpeg)

	set(IS_FOUND TRUE)
	if(libjpeg_INCLUDE_PATH AND libjpeg_LIB)
		convert_PID_Libraries_Into_System_Links(libjpeg_LIB LIBJPEG_LINKS)#getting good system links (with -l)
    convert_PID_Libraries_Into_Library_Directories(libjpeg_LIB LIBJPEG_LIBDIR)
	else()
		message("[PID] ERROR : cannot find jpeg library.")
		set(IS_FOUND FALSE)
	endif()

	if(IS_FOUND)
		found_PID_Configuration(libjpeg TRUE)
	endif ()

	unset(IS_FOUND)
endif ()
