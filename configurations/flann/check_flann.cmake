#########################################################################################
#       This file is part of the program PID                                            #
#       Program description : build system supporting the PID methodology              	#
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
PID_Configuration_Variables(flann
				VARIABLES VERSION				LINK_OPTIONS	LIBRARY_DIRS 	RPATH  				INCLUDE_DIRS				C_LINK_OPTIONS	C_LIBRARY_DIRS 	C_RPATH  					C_INCLUDE_DIRS			CPP_LINK_OPTIONS	CPP_LIBRARY_DIRS 	CPP_RPATH  				CPP_INCLUDE_DIRS
				VALUES 		FLANN_VERSION	FLANN_LINKS		FLANN_LIBDIRS	FLANN_LIBRARY FLANN_INCLUDE_DIR		FLANN_C_LINKS		FLANN_C_LIBDIRS	FLANN_C_LIBRARY 	FLANN_C_INCLUDE_DIR	FLANN_CPP_LINKS		FLANN_CPP_LIBDIRS	FLANN_CPP_LIBRARY FLANN_CPP_INCLUDE_DIR)

# constraints
PID_Configuration_Constraints(flann	IN_BINARY version
																		VALUE			FLANN_VERSION)
