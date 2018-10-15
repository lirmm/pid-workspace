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

include(${WORKSPACE_DIR}/configurations/turbojpeg/installable_turbojpeg.cmake)
if(turbojpeg_INSTALLABLE)
	message("[PID] INFO : trying to install turbojpeg...")
	if(CURRENT_DISTRIBUTION STREQUAL ubuntu)
		if(CURRENT_DISTRIBUTION_VERSION VERSION_LESS 17.10)
			execute_process(COMMAND sudo apt-get install libturbojpeg libjpeg-turbo8-dev)
		else()
			execute_process(COMMAND sudo apt-get install libturbojpeg0-dev)
		endif()
	elseif(CURRENT_DISTRIBUTION STREQUAL debian)
		execute_process(COMMAND sudo apt-get install libturbojpeg0-dev)
	endif()

	include(${WORKSPACE_DIR}/configurations/turbojpeg/find_turbojpeg.cmake)
	if(turbojpeg_FOUND)
		message("[PID] INFO : turbojpeg installed !")
		set(turbojpeg_INSTALLED TRUE)
	else()
		set(turbojpeg_INSTALLED FALSE)
		message("[PID] INFO : install of turbojpeg has failed !")
	endif()
else()
	set(turbojpeg_INSTALLED FALSE)
endif()
