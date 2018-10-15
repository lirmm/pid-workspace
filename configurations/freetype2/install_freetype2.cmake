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

include(${WORKSPACE_DIR}/configurations/freetype2/installable_freetype2.cmake)
if(freetype2_INSTALLABLE)
	message("[PID] INFO : trying to install freetype2...")
	if(	CURRENT_DISTRIBUTION STREQUAL ubuntu
		OR CURRENT_DISTRIBUTION STREQUAL debian)
		execute_process(COMMAND sudo apt-get install libfreetype6-dev)
	elseif(	CURRENT_DISTRIBUTION STREQUAL arch)
		execute_process(COMMAND sudo pacman -S freetype2 --noconfirm)
	endif()
	include(${WORKSPACE_DIR}/configurations/freetype2/find_freetype2.cmake)
	if(freetype2_FOUND)
		message("[PID] INFO : freetype2 installed !")
		set(freetype2_INSTALLED TRUE)
	else()
		set(freetype2_INSTALLED FALSE)
		message("[PID] INFO : install of freetype2 has failed !")
	endif()
else()
	set(freetype2_INSTALLED FALSE)
endif()
