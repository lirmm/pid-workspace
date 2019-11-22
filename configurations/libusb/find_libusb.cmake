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

	find_path(USB_INCLUDE_PATH libusb-1.0/libusb.h)#find the path of the library
	set(LIBUSB_INCLUDE_DIR ${USB_INCLUDE_PATH})
	unset(LIBUSB_INCLUDE_PATH CACHE)

	#first try to find zlib in implicit system path
	find_PID_Library_In_Linker_Order(usb-1.0 ALL USB_LIB LIBUSB_SONAME)
	if(LIBUSB_INCLUDE_DIR AND USB_LIB)
		convert_PID_Libraries_Into_System_Links(USB_LIB LIBUSB_LINKS)#getting good system links (with -l)
    convert_PID_Libraries_Into_Library_Directories(USB_LIB LIBUSB_LIBDIR)
		found_PID_Configuration(libusb TRUE)
	else()
		message("[PID] ERROR : cannot find usb1.0 library (found include=${LIBUSB_INCLUDE_DIR}, library=${USB_LIB}).")
	endif()

endif ()
