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
include(${WORKSPACE_DIR}/share/cmake/plugins/pkg_config/pkg_config.cmake)

foreach(library IN LISTS ${PROJECT_NAME}_COMPONENTS_LIBS)
	if(NOT ${PROJECT_NAME}_${library}_TYPE STREQUAL "MODULE")#module libraries are not intended to be used at compile time
		generate_Pkg_Config_Files(${CMAKE_BINARY_DIR}/share ${PROJECT_NAME} ${CURRENT_PLATFORM} ${${PROJECT_NAME}_VERSION} ${library} ${CMAKE_BUILD_TYPE})
	endif()
endforeach()
