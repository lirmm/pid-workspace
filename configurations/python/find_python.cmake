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

if(python_version)#version argument given
	if(CURRENT_PYTHON VERSION_LESS python_version)
		return()
	endif()
	if(python_version VERSION_LESS 3.0 #python 2 required
			AND NOT CURRENT_PYTHON VERSION_LESS 3.0)# current pyton is >= 3.0
			return()
	endif()
endif()

convert_PID_Libraries_Into_System_Links(PYTHON_LIBRARY PYTHON_LINKS)#getting good system links (with -l)
convert_PID_Libraries_Into_Library_Directories(PYTHON_LIBRARY PYTHON_LIB_DIRS)

if(CURRENT_PYTHON VERSION_LESS 3.0)
	set(PIP_NAME pip2)
else()
	set(PIP_NAME pip3)
endif()

foreach(pack IN LISTS python_packages)
	execute_process(COMMAND ${PIP_NAME} show ${pack} OUTPUT_VARIABLE SHOW_OUTPUT)
	if(SHOW_OUTPUT MATCHES ".*Version:[ \t]*([0-9]+\\.[0-9]+\\.[0-9]+).*")
		if(CMAKE_MATCH_1 STREQUAL "") #no match => cannot find the package
			return()
		endif()
	endif()
endforeach()

set(BIN_PACKAGES ${python_packages})
#now report interesting variables to make them available in configuartion user
found_PID_Configuration(python TRUE)
