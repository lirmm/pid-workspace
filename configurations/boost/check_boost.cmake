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

if(NOT boost_FOUND)

	set(boost_VERSION CACHE INTERNAL "")
	set(boost_INCLUDE_DIRS  CACHE INTERNAL "")
	set(boost_LIBRARY_DIRS  CACHE INTERNAL "")
	set(boost_RPATH CACHE INTERNAL "")

	include(${WORKSPACE_DIR}/configurations/boost/find_boost.cmake)
	if(boost_FOUND)
		set(boost_VERSION ${BOOST_VERSION} CACHE INTERNAL "")
		set(CHECK_boost_RESULT TRUE)
	else()
		include(${WORKSPACE_DIR}/configurations/boost/install_boost.cmake)
		if(boost_INSTALLED)
			set(boost_VERSION ${BOOST_VERSION} CACHE INTERNAL "")
			set(boost_LIBRARY_DIRS ${Boost_LIBRARY_DIRS}  CACHE INTERNAL "")
			set(boost_INCLUDE_DIRS ${Boost_INCLUDE_DIRS}  CACHE INTERNAL "")
			set(boost_RPATH ${Boost_LIBRARY_DIRS}  CACHE INTERNAL "")#RPATH to find libraries is the same as the library dirs
			set(CHECK_boost_RESULT TRUE)
		else()
			set(CHECK_boost_RESULT FALSE)
		endif()
	endif()
else()
	set(CHECK_boost_RESULT TRUE)
endif()
