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

if(NOT fontconfig_FOUND)
	set(fontconfig_COMPILE_OPTIONS CACHE INTERNAL "")
	set(fontconfig_INCLUDE_DIRS CACHE INTERNAL "")
	set(fontconfig_LINK_OPTIONS CACHE INTERNAL "")
	set(fontconfig_DEFINITIONS CACHE INTERNAL "")
	set(fontconfig_RPATH CACHE INTERNAL "")
	include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/fontconfig/find_fontconfig.cmake)
	if(fontconfig_FOUND)
		set(fontconfig_LINK_OPTIONS ${fontconfig_LIBRARIES} CACHE INTERNAL "")
		set(CHECK_fontconfig_RESULT TRUE)
	else()
		include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/fontconfig/install_fontconfig.cmake)
		if(fontconfig_INSTALLED)
			set(fontconfig_LINK_OPTIONS ${fontconfig_LIBRARIES} CACHE INTERNAL "")
			set(CHECK_fontconfig_RESULT TRUE)
		else()
			set(CHECK_fontconfig_RESULT FALSE)
		endif()
	endif()
else()
	set(CHECK_fontconfig_RESULT TRUE)
endif()
