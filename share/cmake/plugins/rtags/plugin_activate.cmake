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

option(RTAGS_INDEX_DEBUG "Index the Debug (TRUE) or Release (FALSE) configuration with RTags" TRUE)

set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE CACHE BOOL "" FORCE)

if(CMAKE_BUILD_TYPE MATCHES Release AND NOT RTAGS_INDEX_DEBUG) #only generating in release mode

	set(COMPILE_COMMANDS_PATH ${CMAKE_SOURCE_DIR}/build/release/compile_commands.json)
	execute_process(COMMAND ${WORKSPACE_DIR}/share/cmake/plugins/rtags/index.sh ${COMPILE_COMMANDS_PATH})

elseif(CMAKE_BUILD_TYPE MATCHES Debug AND RTAGS_INDEX_DEBUG) #only generating in debug mode

	set(COMPILE_COMMANDS_PATH ${CMAKE_SOURCE_DIR}/build/debug/compile_commands.json)
	execute_process(COMMAND ${WORKSPACE_DIR}/share/cmake/plugins/rtags/index.sh ${COMPILE_COMMANDS_PATH})

endif()
