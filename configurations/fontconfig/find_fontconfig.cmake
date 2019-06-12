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

found_PID_Configuration(fontconfig FALSE)

# - Find fontconfig installation
# Try to find libraries for fontconfig on UNIX systems. The following values are defined
#  fontconfig_FOUND        - True if fontconfig is available
#  fontconfig_LIBRARIES    - link against these to use fontconfig library
if (UNIX)
	find_path(fontconfig_INCLUDE_PATH fontconfig/fontconfig.h)
	find_library(fontconfig_LIB fontconfig)
	set(FONTCONFIG_INCLUDE ${fontconfig_INCLUDE_PATH})
	set(FONTCONFIG_LIBRARY ${fontconfig_LIB})
	#unset cache variables to avoid troubles when system configuration changes
	unset(fontconfig_LIB CACHE)
	unset(fontconfig_INCLUDE_PATH CACHE)
	if(FONTCONFIG_INCLUDE AND FONTCONFIG_LIBRARY)
		convert_PID_Libraries_Into_System_Links(FONTCONFIG_LIBRARY FONTCONF_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(FONTCONFIG_LIBRARY FONTCONF_LIBDIR)
		found_PID_Configuration(fontconfig TRUE)
	else()
		message("[PID] ERROR : cannot find fontconfig library.")
	endif()
endif ()
