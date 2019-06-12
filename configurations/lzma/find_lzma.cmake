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

found_PID_Configuration(lzma FALSE)

# - Find lzma installation
# Try to find libraries for lzma on UNIX systems. The following values are defined
#  LZMA_FOUND        - True if lzma is available
#  LZMA_LIBRARIES    - link against these to use lzma library
if (UNIX)

	find_path(LZMA_INCLUDE_DIR lzma.h)
	find_library(LZMA_LIBRARY NAMES lzma liblzma)

	set(LZMA_INCLUDE_PATH ${LZMA_INCLUDE_DIR})
	set(LZMA_LIB ${LZMA_LIBRARY})
	unset(LZMA_INCLUDE_DIR CACHE)
	unset(LZMA_LIBRARY CACHE)

	if(LZMA_INCLUDE_PATH AND LZMA_LIB)

		#need to extract lzma version in file
		if( EXISTS "${LZMA_INCLUDE_PATH}/lzma/version.h")
		  file(READ ${LZMA_INCLUDE_PATH}/lzma/version.h LZMA_VERSION_FILE_CONTENTS)
		  string(REGEX MATCH "define LZMA_VERSION_MAJOR * +([0-9]+)"
		        LZMA_VERSION_MAJOR "${LZMA_VERSION_FILE_CONTENTS}")
		  string(REGEX REPLACE "define LZMA_VERSION_MAJOR * +([0-9]+)" "\\1"
		        LZMA_VERSION_MAJOR "${LZMA_VERSION_MAJOR}")
		  string(REGEX MATCH "define LZMA_VERSION_MINOR * +([0-9]+)"
		        LZMA_VERSION_MINOR "${LZMA_VERSION_FILE_CONTENTS}")
		  string(REGEX REPLACE "define LZMA_VERSION_MINOR * +([0-9]+)" "\\1"
		        LZMA_VERSION_MINOR "${LZMA_VERSION_MINOR}")
		  string(REGEX MATCH "define LZMA_VERSION_PATCH * +([0-9]+)"
		        LZMA_VERSION_PATCH "${LZMA_VERSION_FILE_CONTENTS}")
		  string(REGEX REPLACE "define LZMA_VERSION_PATCH * +([0-9]+)" "\\1"
		        LZMA_VERSION_PATCH "${LZMA_VERSION_PATCH}")
		  set(LZMA_VERSION ${LZMA_VERSION_MAJOR}.${LZMA_VERSION_MINOR}.${LZMA_VERSION_PATCH})
		else()
			set(LZMA_VERSION "NO-VERSION-FOUND")
		endif()

		convert_PID_Libraries_Into_System_Links(LZMA_LIB LZMA_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(LZMA_LIB LZMA_LIBDIRS)

		found_PID_Configuration(lzma TRUE)
	else()
		message("[PID] ERROR : cannot find lzma library.")
	endif()
endif ()
