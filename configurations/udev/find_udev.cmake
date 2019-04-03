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

found_PID_Configuration(udev FALSE)

# - Find libusb installation
# Try to find libraries for libusb on UNIX systems. The following values are defined
#  libusb_FOUND        - True if libusb is available
#  libusb_LIBRARIES    - link against these to use libusb library
if (UNIX)

	find_path(UDEV_INCLUDE_DIR_FOUND libudev.h)
	find_library(UDEV_LIBRARIES_FOUND NAMES udev libudev PATHS ${ADDITIONAL_LIBRARY_PATHS} ${UDEV_PATH_LIB})

	set(IS_FOUND TRUE)
	if (UDEV_LIBRARIES_FOUND AND UDEV_INCLUDE_DIR_FOUND)
		set(UDEV_INCLUDE_DIR ${UDEV_INCLUDE_DIR_FOUND})
		set(UDEV_LIBRARIES ${UDEV_LIBRARIES_FOUND})
		convert_PID_Libraries_Into_System_Links(UDEV_LIBRARIES UDEV_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(UDEV_LIBRARIES UDEV_LIBDIR)
	else()
		message("[PID] ERROR : cannot find libudev library.")
		set(IS_FOUND FALSE)
	endif ()

	if(IS_FOUND)
		found_PID_Configuration(udev TRUE)
	endif ()

	unset(IS_FOUND)
	unset(UDEV_LIBRARIES_FOUND CACHE)
	unset(UDEV_INCLUDE_DIR_FOUND CACHE)
endif ()
