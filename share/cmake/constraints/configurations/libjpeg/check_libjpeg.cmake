#########################################################################################
#       This file is part of the program PID                                            #
#       Program description : build system supporting the PID methodology              	#
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

if(NOT libjpeg_FOUND)
	set(libjpeg_COMPILE_OPTIONS CACHE INTERNAL "")
	set(libjpeg_INCLUDE_DIRS CACHE INTERNAL "")
	set(libjpeg_LINK_OPTIONS CACHE INTERNAL "")
	set(libjpeg_DEFINITIONS CACHE INTERNAL "")
	set(libjpeg_RPATH CACHE INTERNAL "")
	include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/libjpeg/find_libjpeg.cmake)
	if(libjpeg_FOUND)
		set(libjpeg_LINK_OPTIONS ${libjpeg_LIBRARIES} CACHE INTERNAL "")
		set(CHECK_libjpeg_RESULT TRUE)
	else()
		include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/libjpeg/install_libjpeg.cmake)
		if(libjpeg_INSTALLED)
			set(libjpeg_LINK_OPTIONS ${libjpeg_LIBRARIES} CACHE INTERNAL "")
			set(CHECK_libjpeg_RESULT TRUE)
		else()
			set(CHECK_libjpeg_RESULT FALSE)
		endif()
	endif()
else()
	set(CHECK_libjpeg_RESULT TRUE)
endif()
