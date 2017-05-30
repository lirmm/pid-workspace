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

if(NOT pcre3_FOUND) #any linux or macosx is zlib ...
	set(pcre3_COMPILE_OPTIONS CACHE INTERNAL "")
	set(pcre3_INCLUDE_DIRS CACHE INTERNAL "")
	set(pcre3_LINK_OPTIONS CACHE INTERNAL "")
	set(pcre3_RPATH CACHE INTERNAL "")
	include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/pcre3/find_pcre3.cmake)
	if(pcre3_FOUND)
		set(pcre3_LINK_OPTIONS ${pcre3_LIBRARIES} CACHE INTERNAL "") #simply adding all zlib standard libraries
		set(CHECK_pcre3_RESULT TRUE)
	else()
		set(CHECK_pcre3_RESULT FALSE)
	endif()
else()
	set(CHECK_pcre3_RESULT TRUE)
endif()
