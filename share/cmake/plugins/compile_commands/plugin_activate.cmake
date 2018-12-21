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

## main script

if(CMAKE_BUILD_TYPE MATCHES Release) #only generating in release mode

	if(${PROJECT_NAME}_COMPONENTS) #if no component => nothing to build so no need of compile commands

		set( CMAKE_EXPORT_COMPILE_COMMANDS ON )
		if( EXISTS "${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json" )
			EXECUTE_PROCESS( COMMAND ${CMAKE_COMMAND} -E copy_if_different
				${CMAKE_CURRENT_BINARY_DIR}/compile_commands.json
				${CMAKE_CURRENT_SOURCE_DIR}/compile_commands.json
				)
		endif()

	endif()

endif()
