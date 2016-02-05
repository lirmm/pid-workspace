#########################################################################################
#	This file is part of the program PID						#
#  	Program description : build system supportting the PID methodology  		#
#  	Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique 	#
#	et de Microelectronique de Montpellier). All Right reserved.			#
#											#
#	This software is free software: you can redistribute it and/or modify		#
#	it under the terms of the CeCILL-C license as published by			#
#	the CEA CNRS INRIA, either version 1						#
#	of the License, or (at your option) any later version.				#
#	This software is distributed in the hope that it will be useful,		#
#	but WITHOUT ANY WARRANTY; without even the implied warranty of			#
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the			#
#	CeCILL-C License for more details.						#
#											#
#	You can find the complete license description on the official website 		#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################

if(NOT X11_FOUND)
	find_package(X11)
	set(x11_COMPILE_OPTIONS CACHE INTERNAL "")
	set(x11_INCLUDES CACHE INTERNAL "")
	set(x11_LINK_OPTIONS CACHE INTERNAL "")
	set(x11_RPATH CACHE INTERNAL "")
	if(X11_FOUND)
		set(x11_INCLUDES ${X11_INCLUDE_DIR} CACHE INTERNAL "")
		set(x11_LINK_OPTIONS ${X11_LIBRARIES} CACHE INTERNAL "")
		set(CHECK_x11_RESULT TRUE)
	else()
		if(	CURRENT_DISTRIBUTION STREQUAL ubuntu 
			OR CURRENT_DISTRIBUTION STREQUAL debian)
			message("[PID] INFO : trying to install x11...")
			execute_process(COMMAND sudo apt-get install xorg openbox)
			find_package(X11)
			if(X11_FOUND)
				message("[PID] INFO : x11 installed !")
				set(x11_INCLUDES ${X11_INCLUDE_DIR} CACHE INTERNAL "")
				set(x11_LINK_OPTIONS ${X11_LIBRARIES} CACHE INTERNAL "")
				set(CHECK_x11_RESULT TRUE)
			else()
				message("[PID] INFO : install of x11 has failed !")
				set(CHECK_x11_RESULT FALSE)
			endif()
		else()
			set(CHECK_x11_RESULT FALSE)
		endif()
	endif()
else()
	set(CHECK_x11_RESULT TRUE)
endif()
