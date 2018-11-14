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

set(boost_FOUND FALSE CACHE INTERNAL "")

find_package(Boost)
if(NOT Boost_FOUND)
	unset(Boost_FOUND)
	return()
endif()

set(BOOST_VERSION ${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION})
set(Boost_LIBRARY_DIRS ${Boost_LIBRARY_DIRS})
set(Boost_INCLUDE_DIRS ${Boost_INCLUDE_DIRS})
message("Boost_LIBRARIES=${Boost_LIBRARIES}")
set(boost_FOUND TRUE CACHE INTERNAL "")
unset(Boost_FOUND)
