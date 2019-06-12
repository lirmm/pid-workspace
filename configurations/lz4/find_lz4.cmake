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

found_PID_Configuration(lz4 FALSE)

# - Find lz4 installation
# Try to find libraries for lz4 on UNIX systems. The following values are defined
#  LZ4_FOUND        - True if lz4 is available
#  LZ4_LIBRARIES    - link against these to use lz4 library
if (UNIX)

	find_path(LZ4_INCLUDE_DIR lz4.h)
	find_library(LZ4_LIBRARY NAMES lz4 liblz4)

	set(LZ4_INCLUDE_PATH ${LZ4_INCLUDE_DIR})
	set(LZ4_LIB ${LZ4_LIBRARY})
	unset(LZ4_INCLUDE_DIR CACHE)
	unset(LZ4_LIBRARY CACHE)

	if(LZ4_INCLUDE_PATH AND LZ4_LIB)

		#need to extract lz4 version in file
		if( EXISTS "${LZ4_INCLUDE_PATH}/lz4.h")
		  file(READ ${LZ4_INCLUDE_PATH}/lz4.h LZ4_VERSION_FILE_CONTENTS)
		  string(REGEX MATCH "define LZ4_VERSION_MAJOR * +([0-9]+)"
		        LZ4_VERSION_MAJOR "${LZ4_VERSION_FILE_CONTENTS}")
		  string(REGEX REPLACE "define LZ4_VERSION_MAJOR * +([0-9]+)" "\\1"
		        LZ4_VERSION_MAJOR "${LZ4_VERSION_MAJOR}")
		  string(REGEX MATCH "define LZ4_VERSION_MINOR * +([0-9]+)"
		        LZ4_VERSION_MINOR "${LZ4_VERSION_FILE_CONTENTS}")
		  string(REGEX REPLACE "define LZ4_VERSION_MINOR * +([0-9]+)" "\\1"
		        LZ4_VERSION_MINOR "${LZ4_VERSION_MINOR}")
		  string(REGEX MATCH "define LZ4_VERSION_RELEASE * +([0-9]+)"
		        LZ4_VERSION_RELEASE "${LZ4_VERSION_FILE_CONTENTS}")
		  string(REGEX REPLACE "define LZ4_VERSION_RELEASE * +([0-9]+)" "\\1"
		        LZ4_VERSION_RELEASE "${LZ4_VERSION_RELEASE}")
		  set(LZ4_VERSION ${LZ4_VERSION_MAJOR}.${LZ4_VERSION_MINOR}.${LZ4_VERSION_RELEASE})
		else()
			set(LZ4_VERSION "NO-VERSION-FOUND")
		endif()

		convert_PID_Libraries_Into_System_Links(LZ4_LIB LZ4_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(LZ4_LIB LZ4_LIBDIRS)

		found_PID_Configuration(lz4 TRUE)
	else()
		message("[PID] ERROR : cannot find lz4 library.")
	endif()
endif ()
