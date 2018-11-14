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

	set(fontconfig_LIBRARIES) # start with empty list
	set(IS_FOUND TRUE)
	if(fontconfig_INCLUDE_PATH AND fontconfig_LIB)
		set(fontconfig_LIBRARIES -lfontconfig)
	else()
		message("[PID] ERROR : cannot find fontconfig library.")
		set(IS_FOUND FALSE)
	endif()

	if(IS_FOUND)
		found_PID_Configuration(fontconfig TRUE)
	endif ()

	unset(IS_FOUND)
	unset(fontconfig_INCLUDE_PATH CACHE)
	unset(fontconfig_LIB CACHE)
endif ()
