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

include(${WORKSPACE_DIR}/configurations/libjpeg/installable_libjpeg.cmake)
if(libjpeg_INSTALLABLE)
	message("[PID] INFO : trying to install libjpeg...")
	if(	CURRENT_DISTRIBUTION STREQUAL ubuntu
		OR CURRENT_DISTRIBUTION STREQUAL debian)
		execute_process(COMMAND sudo apt-get install libjpeg-dev)
	elseif(	CURRENT_DISTRIBUTION STREQUAL arch)
		execute_process(COMMAND sudo pacman -S libjpeg-turbo --noconfirm)
	endif()
	include(${WORKSPACE_DIR}/configurations/libjpeg/find_libjpeg.cmake)
	if(libjpeg_FOUND)
		message("[PID] INFO : libjpeg installed !")
		set(libjpeg_INSTALLED TRUE)
	else()
		set(libjpeg_INSTALLED FALSE)
		message("[PID] INFO : install of libjpeg has failed !")
	endif()
else()
	set(libjpeg_INSTALLED FALSE)
endif()
