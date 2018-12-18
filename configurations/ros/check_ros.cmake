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

function(add_ROS_Dependencies_To_Component component exported)
	if(exported)

			declare_PID_Component_Dependency(
					COMPONENT ${component}
					EXPORT LINKS SHARED ${ros_LINK_OPTIONS}
								 LIBRARY_DIRS ros_LIBRARY_DIRS
								 INCLUDE_DIRS ros_INCLUDE_DIRS
								 RUNTIME_RESOURCES ros_RPATH
			)

			foreach(boost_component IN LISTS ros_BOOST_COMPONENTS)
					declare_PID_Component_Dependency(
							COMPONENT ${component}
							EXPORT EXTERNAL ${boost_component}
							PACKAGE boost
					)
			endforeach()
	else()

				declare_PID_Component_Dependency(
						COMPONENT ${component}
									 LINKS SHARED ${ros_LINK_OPTIONS}
									 LIBRARY_DIRS ros_LIBRARY_DIRS
									 INCLUDE_DIRS ros_INCLUDE_DIRS
									 RUNTIME_RESOURCES ros_RPATH
				)

		foreach(boost_component IN LISTS ros_BOOST_COMPONENTS)
		    declare_PID_Component_Dependency(
		        COMPONENT ${component}
		        EXTERNAL ${boost_component}
		        PACKAGE boost
		    )
		endforeach()
	endif()
endfunction(add_ROS_Dependencies_To_Component)

include(Configuration_Definition NO_POLICY_SCOPE)

# returned variables
PID_Configuration_Variables(ros
			VARIABLES INCLUDE_DIRS 	RPATH  		LIBRARY_DIRS  LINK_OPTIONS  BOOST_COMPONENTS
			VALUES 		ROS_INCS			ROS_LIBS	ROS_LIB_DIRS	ROS_LINKS			ROS_BOOST_PID_COMP)

# constraints
PID_Configuration_Constraints(ros REQUIRED distribution IN_BINARY packages VALUE ROS_PACKAGES)

# dependencies
PID_Configuration_Dependencies(ros DEPENDS boost[libraries=ROS_BOOST_LIBS])
