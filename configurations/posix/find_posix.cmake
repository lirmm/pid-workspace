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
	set(IS_FOUND TRUE)

	# check for headers
	find_path(posix_pthread_INCLUDE_PATH pthread.h)
	find_path(posix_rt_INCLUDE_PATH time.h)
	find_path(posix_dl_INCLUDE_PATH dlfcn.h)

	if(NOT posix_pthread_INCLUDE_PATH
		OR NOT posix_rt_INCLUDE_PATH
		OR NOT posix_dl_INCLUDE_PATH)
		set(POSIX_INCS)
		set(IS_FOUND FALSE)
		message("[PID] ERROR : cannot find headers of posix libraries.")
	endif()
	unset(posix_pthread_INCLUDE_PATH CACHE)
	unset(posix_rt_INCLUDE_PATH CACHE)
	unset(posix_dl_INCLUDE_PATH CACHE)


		# check for libraries (only in implicit system folders)
	find_PID_Library_In_Linker_Order(pthread IMPLICIT pthread_LIBRARY_PATH pthread_SONAME)
	if(NOT pthread_LIBRARY_PATH)
		message("[PID] ERROR : when finding posix, cannot find pthread library.")
		set(IS_FOUND FALSE)
	endif()
	find_PID_Library_In_Linker_Order(rt IMPLICIT rt_LIBRARY_PATH rt_SONAME)
	if(NOT rt_LIBRARY_PATH)
		message("[PID] ERROR : when finding posix, cannot find rt library.")
		set(IS_FOUND FALSE)
	endif()
	find_PID_Library_In_Linker_Order(dl IMPLICIT dl_LIBRARY_PATH dl_SONAME)
	if(NOT dl_LIBRARY_PATH)
		message("[PID] ERROR : when finding posix, cannot find dl library.")
		set(IS_FOUND FALSE)
	endif()

	if(IS_FOUND)
		set(POSIX_INCS ${posix_pthread_INCLUDE_PATH} ${posix_rt_INCLUDE_PATH} ${posix_dl_INCLUDE_PATH})
		set(POSIX_SONAME ${pthread_SONAME} ${rt_SONAME} ${dl_SONAME})
		set(POSIX_LIBS ${pthread_LIBRARY_PATH} ${rt_LIBRARY_PATH} ${dl_LIBRARY_PATH})
		found_PID_Configuration(posix TRUE)
		convert_PID_Libraries_Into_System_Links(POSIX_LIBS POSIX_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(POSIX_LIBS POSIX_LIBDIRS)
		#SONAMES are already computed no need to use dedicated functions
	endif ()

	unset(IS_FOUND)
	set(CMAKE_FIND_FRAMEWORK ${CMAKE_FIND_FRAMEWORK_SAVE})
endif ()
