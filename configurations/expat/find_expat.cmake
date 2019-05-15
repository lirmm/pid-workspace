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

found_PID_Configuration(expat FALSE)

# - Find expat installation
# Try to find libraries for expat on UNIX systems. The following values are defined
#  EXPAT_FOUND        - True if expat is available
#  EXPAT_LIBRARIES    - link against these to use expat library
if (UNIX)

	find_path(EXPAT_INCLUDE_PATH expat.h)
	find_library(EXPAT_LIB NAMES expat libexpat)

	set(IS_FOUND TRUE)
	if(EXPAT_INCLUDE_PATH AND EXPAT_LIB)

		#need to extract expat version in file
	  file(READ ${EXPAT_INCLUDE_PATH}/expat.h EXPAT_VERSION_FILE_CONTENTS)
	  string(REGEX MATCH "define XML_MAJOR_VERSION * +([0-9]+)"
	        XML_MAJOR_VERSION "${EXPAT_VERSION_FILE_CONTENTS}")
	  string(REGEX REPLACE "define XML_MAJOR_VERSION * +([0-9]+)" "\\1"
	        XML_MAJOR_VERSION "${XML_MAJOR_VERSION}")
	  string(REGEX MATCH "define XML_MINOR_VERSION * +([0-9]+)"
	        XML_MINOR_VERSION "${EXPAT_VERSION_FILE_CONTENTS}")
	  string(REGEX REPLACE "define XML_MINOR_VERSION * +([0-9]+)" "\\1"
	        XML_MINOR_VERSION "${XML_MINOR_VERSION}")
	  string(REGEX MATCH "define XML_MICRO_VERSION * +([0-9]+)"
	        XML_MICRO_VERSION "${EXPAT_VERSION_FILE_CONTENTS}")
	  string(REGEX REPLACE "define XML_MICRO_VERSION * +([0-9]+)" "\\1"
	        XML_MICRO_VERSION "${XML_MICRO_VERSION}")
	  set(EXPAT_VERSION ${XML_MAJOR_VERSION}.${XML_MINOR_VERSION}.${XML_MICRO_VERSION})

		convert_PID_Libraries_Into_System_Links(EXPAT_LIB EXPAT_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(EXPAT_LIB EXPAT_LIBDIRS)
	else()
		message("[PID] ERROR : cannot find expat library.")
		set(IS_FOUND FALSE)
	endif()

	if(IS_FOUND)
		found_PID_Configuration(expat TRUE)
	endif ()

	unset(IS_FOUND)
endif ()
