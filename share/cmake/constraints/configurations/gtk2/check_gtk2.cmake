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

if(NOT gtk2_FOUND) #any linux or macosx is gtk2 ...
	set(gtk2_INCLUDE_DIRS CACHE INTERNAL "")
	set(gtk2_COMPILE_OPTIONS CACHE INTERNAL "")
	set(gtk2_DEFINITIONS CACHE INTERNAL "")
	set(gtk2_LINK_OPTIONS CACHE INTERNAL "")
	set(gtk2_RPATH CACHE INTERNAL "")
	# trying to find gtk2
	include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/gtk2/find_gtk2.cmake)
	if(gtk2_FOUND)
		set(gtk2_INCLUDE_DIRS ${gtk2_INCLUDE_PATH} CACHE INTERNAL "")
		set(gtk2_LINK_OPTIONS ${gtk2_LIBRARIES} CACHE INTERNAL "") #simply adding all gtk2 standard libraries
		set(CHECK_gtk2_RESULT TRUE)
	else()
		include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/gtk2/install_gtk2.cmake)
		if(gtk2_INSTALLED)
			set(gtk2_LINK_OPTIONS ${gtk2_LIBRARIES} CACHE INTERNAL "")
			set(gtk2_INCLUDE_DIRS ${gtk2_INCLUDE_PATH} CACHE INTERNAL "")
			set(CHECK_gtk2_RESULT TRUE)
		else()
			set(CHECK_gtk2_RESULT FALSE)
		endif()

	endif()
else()
	set(CHECK_gtk2_RESULT TRUE)
endif()
