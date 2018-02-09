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

include(PID_Utils_Functions NO_POLICY_SCOPE)
include(${WORKSPACE_DIR}/share/cmake/plugins/cotire/cotire.cmake)

if(${PROJECT_NAME}_COMPONENTS) #if no component => nothing to build so no need of a clang complete

	foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
		if(NOT ${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER") #no need to speed up the build of a header library
			cotire(${${PROJECT_NAME}_${component}_NAME})
		endif()
	endforeach()

endif()
