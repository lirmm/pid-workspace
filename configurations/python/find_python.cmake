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

found_PID_Configuration(python FALSE)

if(python_version VERSION_LESS 3.0)#python 2 required
	if(NOT CURRENT_PYTHON VERSION_LESS python_version
		AND CURRENT_PYTHON VERSION_LESS 3.0)#OK version match
		set(PIP_NAME pip2)
	else()
		return()
	endif()
else() #python 3 required
	if(NOT CURRENT_PYTHON VERSION_LESS python_version
		AND NOT CURRENT_PYTHON VERSION_LESS 3.0)#OK version match
		set(PIP_NAME pip3)
	else()
		return()
	endif()
endif()

foreach(pack IN LISTS python_packages)
	execute_process(COMMAND ${PIP_NAME} show ${pack} OUTPUT_VARIABLE SHOW_OUTPUT)
	if(SHOW_OUTPUT MATCHES ".*Version:[ \t]*([0-9]+\\.[0-9]+\\.[0-9]+).*")
		if(CMAKE_MATCH_1 STREQUAL "") #no match => cannot find the package
			return()
		endif()
	endif()
endforeach()

#now report interesting variables to make them available in configuartion user
found_PID_Configuration(python TRUE)
