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

found_PID_Configuration(doubleconversion FALSE)

# - Find doubleconversion installation
# Try to find libraries for doubleconversion on UNIX systems. The following values are defined
#  DOUBLECONVERSION_FOUND        - True if doubleconversion is available
#  DOUBLECONVERSION_LIBRARIES    - link against these to use doubleconversion library
if (UNIX)

	find_path(DOUBLECONVERSION_INCLUDE_DIR double-conversion.h PATH_SUFFIXES double-conversion)
	find_library(DOUBLECONVERSION_LIBRARY NAMES double-conversion libdouble-conversion)

	set(DOUBLECONVERSION_INCLUDE_PATH ${DOUBLECONVERSION_INCLUDE_DIR})
	set(DOUBLECONVERSION_LIB ${DOUBLECONVERSION_LIBRARY})
	unset(DOUBLECONVERSION_INCLUDE_DIR CACHE)
	unset(DOUBLECONVERSION_LIBRARY CACHE)

	if(DOUBLECONVERSION_INCLUDE_PATH AND DOUBLECONVERSION_LIB)

	  set(DOUBLECONVERSION_VERSION "NO-VERSION-FOUND")
		convert_PID_Libraries_Into_System_Links(DOUBLECONVERSION_LIB DOUBLECONVERSION_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(DOUBLECONVERSION_LIB DOUBLECONVERSION_LIBDIRS)

		found_PID_Configuration(doubleconversion TRUE)
	else()
		message("[PID] ERROR : cannot find double-conversion library.")
	endif()
endif ()
