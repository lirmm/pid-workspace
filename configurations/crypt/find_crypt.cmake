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

found_PID_Configuration(crypt FALSE)

# - Find crypt installation
# Try to find libraries for crypt on UNIX systems. The following values are defined
#  crypt_FOUND        - True if posix is available
#  crypt_LIBRARIES    - link against these to use posix system
if (UNIX)

	# posix is never a framework and some header files may be
	# found in tcl on the mac
	set(CMAKE_FIND_FRAMEWORK_SAVE ${CMAKE_FIND_FRAMEWORK})
	set(CMAKE_FIND_FRAMEWORK NEVER)

	find_path(crypt_INCLUDE_PATH crypt.h
	          /usr/local/include/crypt
		  /usr/local/include
		  /usr/include/crypt
		  /usr/include)

	find_library(crypt_LIB
		NAMES crypt
		PATHS /usr/local/lib /usr/lib /lib )

	set(IS_FOUND TRUE)
	if(crypt_INCLUDE_PATH AND crypt_LIB)
		convert_PID_Libraries_Into_System_Links(crypt_LIB CRYPT_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(crypt_LIB CRYPT_LIBDIR)
	else()
		message("[PID] ERROR : cannot find crypt library.")
		set(IS_FOUND FALSE)
	endif()

	if(IS_FOUND)
		found_PID_Configuration(boost TRUE)
	endif ()

	unset(IS_FOUND)
	set(CMAKE_FIND_FRAMEWORK ${CMAKE_FIND_FRAMEWORK_SAVE})
endif ()
