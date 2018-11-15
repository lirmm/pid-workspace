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

found_PID_Configuration(libusb FALSE)

# - Find libusb installation
# Try to find libraries for libusb on UNIX systems. The following values are defined
#  libusb_FOUND        - True if libusb is available
#  libusb_LIBRARIES    - link against these to use libusb library
if (UNIX)

	find_path(libusb_INCLUDE_PATH libusb-1.0/libusb.h)#find the path of the library
	find_library(libusb_LIB usb-1.0)

	set(libusb_LIBRARIES) # start with empty list
	set(IS_FOUND TRUE)
	if(libusb_INCLUDE_PATH AND libusb_LIB)
		set(libusb_LIBRARIES -lusb-1.0)
	else()
		message("[PID] ERROR : cannot find usb1.0 library.")
		set(IS_FOUND FALSE)
	endif()

	if(IS_FOUND)
		found_PID_Configuration(libusb TRUE)
	endif ()

	unset(IS_FOUND)
	unset(libusb_INCLUDE_PATH CACHE)
	unset(libusb_LIB CACHE)
endif ()
