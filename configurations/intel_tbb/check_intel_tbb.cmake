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
PID_Configuration_Variables(intel_tbb
				VARIABLES 	VERSION 	LINK_OPTIONS 	LIBRARY_DIRS 		RPATH   	INCLUDE_DIRS
				VALUES 		TBB_VERSION 	TBB_LINKS 	TBB_LIBRARY_DIRS 	TBB_LIBRARIES 	TBB_INCLUDE_DIRS)

PID_Configuration_Dependencies(intel_tbb DEPEND posix)
