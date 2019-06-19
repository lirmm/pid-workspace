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

found_PID_Configuration(glew FALSE)

# - Find glew installation
# Try to find libraries for glew on UNIX systems. The following values are defined
#  GLEW_FOUND        - True if glew is available
#  GLEW_LIBRARIES    - link against these to use glew library
if (UNIX)

	find_path(GLEW_INCLUDE_DIR GL/glew.h)
	find_library(GLEW_LIBRARY NAMES glew libglew GLEW libGLEW)

	set(GLEW_INCLUDE_PATH ${GLEW_INCLUDE_DIR})
	set(GLEW_LIB ${GLEW_LIBRARY})
	unset(GLEW_INCLUDE_DIR CACHE)
	unset(GLEW_LIBRARY CACHE)

	if(GLEW_INCLUDE_PATH AND GLEW_LIB)

		#need to extract glew version in file
	  file(READ ${GLEW_INCLUDE_PATH}/GL/glew.h GLEW_VERSION_FILE_CONTENTS)
	  string(REGEX MATCH "define GLEW_VERSION_MAJOR * +([0-9]+)"
	        GLEW_VERSION_MAJOR "${GLEW_VERSION_FILE_CONTENTS}")
	  string(REGEX REPLACE "define GLEW_VERSION_MAJOR * +([0-9]+)" "\\1"
	        GLEW_VERSION_MAJOR "${GLEW_VERSION_MAJOR}")
	  string(REGEX MATCH "define GLEW_VERSION_MINOR * +([0-9]+)"
	        GLEW_VERSION_MINOR "${GLEW_VERSION_FILE_CONTENTS}")
	  string(REGEX REPLACE "define GLEW_VERSION_MINOR * +([0-9]+)" "\\1"
	        GLEW_VERSION_MINOR "${GLEW_VERSION_MINOR}")
	  string(REGEX MATCH "define GLEW_VERSION_MICRO * +([0-9]+)"
	        GLEW_VERSION_MICRO "${GLEW_VERSION_FILE_CONTENTS}")
	  string(REGEX REPLACE "define GLEW_VERSION_MICRO * +([0-9]+)" "\\1"
	        GLEW_VERSION_MICRO "${GLEW_VERSION_MICRO}")
	  set(GLEW_VERSION ${GLEW_VERSION_MAJOR}.${GLEW_VERSION_MINOR}.${GLEW_VERSION_MICRO})

		convert_PID_Libraries_Into_System_Links(GLEW_LIB GLEW_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(GLEW_LIB GLEW_LIBDIRS)

		found_PID_Configuration(glew TRUE)
	else()
		message("[PID] ERROR : cannot find glew library.")
	endif()
endif ()
