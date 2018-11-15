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

include(Configuration_Definition NO_POLICY_SCOPE)

found_PID_Configuration(boost FALSE)
if(boost_libraries)
	find_package(Boost COMPONENTS ${boost_libraries})
else()
	find_package(Boost)
endif()
if(NOT Boost_FOUND)
	unset(Boost_FOUND)
	return()
endif()
if(Boost_LIBRARIES)
	convert_PID_Libraries_Into_System_Links(Boost_LIBRARIES Boost_LINKS)#getting good system links (with -l)
endif()
set(Boost_COMPONENTS ${boost_libraries})
set(BOOST_VERSION ${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION})
found_PID_Configuration(boost TRUE)
unset(Boost_FOUND)
