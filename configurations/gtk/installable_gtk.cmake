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
if(	CURRENT_DISTRIBUTION STREQUAL ubuntu
	OR CURRENT_DISTRIBUTION STREQUAL debian
	OR CURRENT_DISTRIBUTION STREQUAL arch)
	if(gtk_version EQUAL 2 OR gtk_version EQUAL 3)
		installable_PID_Configuration(gtk TRUE)
	elseif(NOT gtk_version AND gtk_preferred)
		set(found_gtk_version)
		foreach(version IN LISTS gtk_preferred)
			if(version EQUAL 2 OR version EQUAL 3)
				set(found_gtk_version ${version})
				break()
			endif()
		endforeach()
		if(found_gtk_version)
			installable_PID_Configuration(gtk TRUE)
		else()
			installable_PID_Configuration(gtk FALSE)
		endif()
	else()
		installable_PID_Configuration(gtk FALSE)
	endif()
else()
	installable_PID_Configuration(gtk FALSE)
endif()
