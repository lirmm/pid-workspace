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

include(${WORKSPACE_DIR}/configurations/x11/installable_x11.cmake)
if(x11_INSTALLABLE)
	message("[PID] INFO : trying to install x11...")
	execute_process(COMMAND sudo apt-get install xorg openbox libx11-dev libxt-dev libxft-dev libxpm-dev libxcomposite-dev libxdamage-dev libxtst-dev libxinerama-dev libxrandr-dev libxxf86vm-dev libxcursor-dev libxss-dev libxkbfile-dev)
	include(${WORKSPACE_DIR}/configurations/x11/find_x11.cmake)
	if(x11_FOUND)
		message("[PID] INFO : x11 installed !")
		set(x11_INSTALLED TRUE)
	else()
		set(x11_INSTALLED FALSE)
		message("[PID] INFO : install of x11 has failed !")
	endif()
else()
	set(x11_INSTALLED FALSE)
endif()
