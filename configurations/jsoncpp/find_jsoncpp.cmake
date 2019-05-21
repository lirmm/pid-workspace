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

found_PID_Configuration(jsoncpp FALSE)

# - Find jsoncpp installation
# Try to find libraries for jsoncpp on UNIX systems. The following values are defined
#  JSONCPP_FOUND        - True if jsoncpp is available
#  JSONCPP_LIBRARIES    - link against these to use jsoncpp library
if (UNIX)

	find_path(JSONCPP_INCLUDE_PATH json/json.h PATH_SUFFIXES jsoncpp)
	find_library(JSONCPP_LIB NAMES jsoncpp libjsoncpp)

	if(JSONCPP_INCLUDE_PATH AND JSONCPP_LIB)
		#need to extract jsoncpp version in file
		if( EXISTS "${JSONCPP_INCLUDE_PATH}/json/version.h")
		  file(READ ${JSONCPP_INCLUDE_PATH}/json/version.h JSONCPP_VERSION_FILE_CONTENTS)
		  string(REGEX MATCH "define JSONCPP_VERSION_MAJOR * +([0-9]+)"
		        JSONCPP_VERSION_MAJOR "${JSONCPP_VERSION_FILE_CONTENTS}")
		  string(REGEX REPLACE "define JSONCPP_VERSION_MAJOR * +([0-9]+)" "\\1"
		        JSONCPP_VERSION_MAJOR "${JSONCPP_VERSION_MAJOR}")
		  string(REGEX MATCH "define JSONCPP_VERSION_MINOR * +([0-9]+)"
		        JSONCPP_VERSION_MINOR "${JSONCPP_VERSION_FILE_CONTENTS}")
		  string(REGEX REPLACE "define JSONCPP_VERSION_MINOR * +([0-9]+)" "\\1"
		        JSONCPP_VERSION_MINOR "${JSONCPP_VERSION_MINOR}")
		  string(REGEX MATCH "define JSONCPP_VERSION_PATCH * +([0-9]+)"
		        JSONCPP_VERSION_PATCH "${JSONCPP_VERSION_FILE_CONTENTS}")
		  string(REGEX REPLACE "define JSONCPP_VERSION_PATCH * +([0-9]+)" "\\1"
		        JSONCPP_VERSION_PATCH "${JSONCPP_VERSION_PATCH}")
		  set(JSONCPP_VERSION ${JSONCPP_VERSION_MAJOR}.${JSONCPP_VERSION_MINOR}.${JSONCPP_VERSION_PATCH})
		else()
			set(JSONCPP_VERSION "NO-VERSION-FOUND")
		endif()

		convert_PID_Libraries_Into_System_Links(JSONCPP_LIB JSONCPP_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(JSONCPP_LIB JSONCPP_LIBDIRS)
		found_PID_Configuration(jsoncpp TRUE)
	else()
		message("[PID] ERROR : cannot find jsoncpp library.")
	endif()

endif ()
