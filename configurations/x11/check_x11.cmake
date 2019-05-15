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

# returned variables
PID_Configuration_Variables(x11
				VARIABLES LINK_OPTIONS RPATH 					LIBRARY_DIRS 	INCLUDE_DIRS	EXTENSIONS_LINK_OPTIONS	 	EXTENSION_RPATH			EXTENSION_LIBRARY_DIRS	EXTENSION_INCLUDE_DIRS	EXTENTIONS_NAMES
				VALUES 		X11_LINKS    X11_LIBRARIES	X11_LIBDIR		X11_INCLUDES  X11_EXT_LINKS							X11_EXT_LIBRARIES 	X11_EXT_LIBDIRS 				X11_EXT_INCLUDES				X11_EXTENTIONS_NAMES)

# constraints
PID_Configuration_Constraints(x11			IN_BINARY extensions
															VALUE		X11_EXTENTIONS_NAMES)
