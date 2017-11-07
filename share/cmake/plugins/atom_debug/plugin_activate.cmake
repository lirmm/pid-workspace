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

include(PID_Utils_Functions)

macro(add_Debug_Target component folder)
	set(component_config "\"${component}\":\n\tpath: \"build/debug/${folder}/${component}-dbg\"\n\tcmd: \"build\"\n")
	set(DEBUG_CONFIG "${DEBUG_CONFIG}${component_config}")
endmacro()

## main script
if(CMAKE_BUILD_TYPE MATCHES Debug) #only generating in debug mode
	set(DEBUG_CONFIG)

	foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
		if(${PROJECT_NAME}_${component}_TYPE STREQUAL "APP")
			add_Debug_Target(${component} apps)
		elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE")
			add_Debug_Target(${component} apps)
		elseif(BUILD_TESTS_IN_DEBUG AND ${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
			add_Debug_Target(${component} test)
		endif()
	endforeach()

	set(path_to_file "${CMAKE_SOURCE_DIR}/.atom-dbg.cson")
	if(EXISTS ${path_to_file})
		file(REMOVE ${path_to_file})
	endif()
	file(GENERATE OUTPUT ${path_to_file} CONTENT ${DEBUG_CONFIG})
endif()
