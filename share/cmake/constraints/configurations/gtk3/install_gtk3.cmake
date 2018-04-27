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


include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/gtk3/installable_gtk3.cmake)
if(gtk3_INSTALLABLE)
	message("[PID] INFO : trying to install gtk3...")
	if(	CURRENT_DISTRIBUTION STREQUAL ubuntu
		OR CURRENT_DISTRIBUTION STREQUAL debian)
		execute_process(COMMAND sudo apt-get install libgtkmm-3.0-dev)
	elseif(	CURRENT_DISTRIBUTION STREQUAL arch)
		execute_process(COMMAND sudo pacman -S gtkmm3)
	endif()
	include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/gtk3/find_gtk3.cmake)
	if(gtk3_FOUND)
		message("[PID] INFO : gtk3 installed !")
		set(gtk3_INSTALLED TRUE)
	else()
		set(gtk3_INSTALLED FALSE)
		message("[PID] INFO : install of gtk3 has failed !")
	endif()
else()
	set(gtk3_INSTALLED FALSE)
endif()