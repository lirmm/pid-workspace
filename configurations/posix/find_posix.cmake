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

found_PID_Configuration(posix FALSE)
# - Find posix installation
# Try to find libraries for posix on UNIX systems. The following values are defined
#  posix_FOUND        - True if posix is available
#  posix_LIBRARIES    - link against these to use posix system
if (UNIX)

	# posix is never a framework and some header files may be
	# found in tcl on the mac
	set(CMAKE_FIND_FRAMEWORK_SAVE ${CMAKE_FIND_FRAMEWORK})
	set(CMAKE_FIND_FRAMEWORK NEVER)

	# MODIFICATION for our needs: must be in default system folders so do not provide additionnal folders !!!!!
	find_path(posix_pthread_INCLUDE_PATH pthread.h)
	find_path(posix_rt_INCLUDE_PATH time.h)
	find_path(posix_dl_INCLUDE_PATH dlfcn.h)
	find_path(posix_math_INCLUDE_PATH math.h)

	find_library(posix_pthread_LIB pthread
			PATHS /usr/lib/x86_64-linux-gnu /usr/local/lib /usr/lib /lib )
	find_library(posix_rt_LIB rt)
	find_library(posix_dl_LIB dl)
	find_library(posix_math_LIB m)

	set(POSIX_LIBS)
	set(POSIX_INCS)
	set(IS_FOUND TRUE)
	if(posix_pthread_INCLUDE_PATH AND posix_pthread_LIB)
		list(APPEND POSIX_LIBS ${posix_pthread_LIB})
		list(APPEND POSIX_INCS ${posix_pthread_INCLUDE_PATH})
	else()
		message("[PID] ERROR : when finding posix framework, cannot find pthread library.")
		set(IS_FOUND FALSE)
	endif()

	if(posix_rt_INCLUDE_PATH AND posix_rt_LIB)
		list(APPEND POSIX_LIBS ${posix_rt_LIB})
		list(APPEND POSIX_INCS ${posix_rt_INCLUDE_PATH})
	elseif(NOT APPLE)
		message("[PID] ERROR : when finding posix framework, cannot find rt library.")
		set(IS_FOUND FALSE)
	endif()

	if(posix_dl_INCLUDE_PATH AND posix_dl_LIB)
		list(APPEND POSIX_LIBS ${posix_dl_LIB})
		list(APPEND POSIX_INCS ${posix_dl_INCLUDE_PATH})
	else()
		message("[PID] ERROR : when finding posix framework, cannot find dl library.")
		set(IS_FOUND FALSE)
	endif()

	if(posix_math_INCLUDE_PATH AND posix_math_LIB)
		list(APPEND POSIX_LIBS ${posix_math_LIB})
		list(APPEND POSIX_INCS ${posix_math_INCLUDE_PATH})
	else()
		message("[PID] ERROR : when finding posix framework, cannot find math library.")
		set(IS_FOUND FALSE)
	endif()

	if(IS_FOUND)
		found_PID_Configuration(posix TRUE)
		convert_PID_Libraries_Into_System_Links(POSIX_LIBS POSIX_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(POSIX_LIBS POSIX_LIBDIRS)
	endif ()

	unset(IS_FOUND)
	unset(posix_pthread_INCLUDE_PATH CACHE)
	unset(posix_pthread_LIB CACHE)
	unset(posix_rt_INCLUDE_PATH CACHE)
	unset(posix_rt_LIB CACHE)
	unset(posix_math_INCLUDE_PATH CACHE)
	unset(posix_math_LIB CACHE)
	unset(posix_dl_INCLUDE_PATH CACHE)
	unset(posix_dl_LIB CACHE)
	set(CMAKE_FIND_FRAMEWORK ${CMAKE_FIND_FRAMEWORK_SAVE})
endif ()
