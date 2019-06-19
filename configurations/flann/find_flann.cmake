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

found_PID_Configuration(flann FALSE)

# - Find flann installation
# Try to find libraries for flann on UNIX systems. The following values are defined
#  FLANN_FOUND        - True if flann is available
#  FLANN_LIBRARIES    - link against these to use flann library
if (UNIX)

	find_path(FLANN_C_INCLUDE_PATH NAMES flann.h PATH_SUFFIXES flann)
	find_library(FLANN_C_LIB NAMES libflann flann)

	find_path(FLANN_CPP_INCLUDE_PATH NAMES flann.hpp PATH_SUFFIXES flann)
	find_library(FLANN_CPP_LIB NAMES libflann_cpp flann_cpp)

	set(FLANN_C_INCLUDE_DIR ${FLANN_C_INCLUDE_PATH})
	set(FLANN_C_LIBRARY ${FLANN_C_LIB})
	set(FLANN_CPP_INCLUDE_DIR ${FLANN_CPP_INCLUDE_PATH})
	set(FLANN_CPP_LIBRARY ${FLANN_CPP_LIB})
	unset(FLANN_C_INCLUDE_PATH CACHE)
	unset(FLANN_C_LIB CACHE)
	unset(FLANN_CPP_INCLUDE_PATH CACHE)
	unset(FLANN_CPP_LIB CACHE)

	if(FLANN_C_INCLUDE_DIR AND FLANN_C_LIBRARY AND FLANN_CPP_INCLUDE_DIR AND FLANN_CPP_LIBRARY)

		#need to extract flann version in file
		if( EXISTS "${FLANN_C_INCLUDE_DIR}/config.h")
			file(READ ${FLANN_C_INCLUDE_DIR}/config.h FLANN_VERSION_FILE_CONTENTS)
		  string(REGEX MATCH "define FLANN_VERSION_ * \"([0-9]+)(\\.[0-9]+)(\\.[0-9]+)?"
		        FLANN_VERSION "${FLANN_VERSION_FILE_CONTENTS}")
		  string(REGEX REPLACE "define FLANN_VERSION_ * \"([0-9]+)(\\.[0-9]+)(\\.[0-9]+)?" "\\1\\2\\3"
		        FLANN_VERSION "${FLANN_VERSION}")
		elseif( EXISTS "${FLANN_CPP_INCLUDE_DIR}/config.h")
			file(READ ${FLANN_CPP_INCLUDE_DIR}/config.h FLANN_VERSION_FILE_CONTENTS)
			string(REGEX MATCH "define FLANN_VERSION_ * \"([0-9]+)(\\.[0-9]+)(\\.[0-9]+)?"
						FLANN_VERSION "${FLANN_VERSION_FILE_CONTENTS}")
			string(REGEX REPLACE "define FLANN_VERSION_ * \"([0-9]+)(\\.[0-9]+)(\\.[0-9]+)?" "\\1\\2\\3"
						FLANN_VERSION "${FLANN_VERSION}")
		else()
			set(FLANN_VERSION "NO-VERSION-FOUND")
		endif()


		convert_PID_Libraries_Into_System_Links(FLANN_C_LIBRARY FLANN_C_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(FLANN_C_LIBRARY FLANN_C_LIBDIRS)

		convert_PID_Libraries_Into_System_Links(FLANN_CPP_LIBRARY FLANN_CPP_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(FLANN_CPP_LIBRARY FLANN_CPP_LIBDIRS)


		list(APPEND FLANN_LINKS ${FLANN_C_LINKS} ${FLANN_CPP_LINKS})
    if(FLANN_LINKS)
      list(REMOVE_DUPLICATES FLANN_LINKS)
    endif()
		list(APPEND FLANN_LIBDIRS ${FLANN_C_LIBDIRS} ${FLANN_CPP_LIBDIRS})
    if(FLANN_LIBDIRS)
      list(REMOVE_DUPLICATES FLANN_LIBDIRS)
    endif()
		list(APPEND FLANN_LIBRARY ${FLANN_C_LIBRARY} ${FLANN_CPP_LIBRARY})
		if(FLANN_LIBRARY)
			list(REMOVE_DUPLICATES FLANN_LIBRARY)
		endif()
		list(APPEND FLANN_INCLUDE_DIR ${FLANN_C_INCLUDE_DIR} ${FLANN_CPP_INCLUDE_DIR})
		if(FLANN_INCLUDE_DIR)
			list(REMOVE_DUPLICATES FLANN_INCLUDE_DIR)
		endif()

		found_PID_Configuration(flann TRUE)
	else()
		message("[PID] ERROR : cannot find flann library.")
	endif()

endif ()
