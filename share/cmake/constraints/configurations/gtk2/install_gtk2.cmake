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


include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/gtk2/installable_gtk2.cmake)
if(gtk2_INSTALLABLE)
	message("[PID] INFO : trying to install gtk2...")
	if(	CURRENT_DISTRIBUTION STREQUAL ubuntu
		OR CURRENT_DISTRIBUTION STREQUAL debian)
		execute_process(COMMAND sudo apt-get install libgtk2.0-dev libgtkmm-2.4-dev)
	elseif(	CURRENT_DISTRIBUTION STREQUAL arch)
		execute_process(COMMAND sudo pacman -S gtk2 gtkmm)
	endif()
	include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/gtk2/find_gtk2.cmake)
	if(gtk2_FOUND)
		message("[PID] INFO : gtk2 installed !")
		set(gtk2_INSTALLED TRUE)
	else()
		set(gtk2_INSTALLED FALSE)
		message("[PID] INFO : install of gtk2 has failed !")
	endif()
else()
	set(gtk2_INSTALLED FALSE)
endif()
