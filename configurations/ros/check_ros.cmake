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

function(add_ROS_Dependencies_To_Component component)
	declare_PID_Component_Dependency(
	    COMPONENT ${component}
	    LINKS SHARED ${ros_LIBS} STATIC -L${ros_RPATH}
	    INCLUDE_DIRS ${ros_INCLUDE_DIRS}
	)

	foreach(boost_component IN LISTS ros_BOOST_COMPONENTS)
	    declare_PID_Component_Dependency(
	        COMPONENT ${component}
	        EXTERNAL ${boost_component}
	        PACKAGE boost
	    )
	endforeach()
endfunction()

if(NOT ros_distribution)
	set(CHECK_ros_RESULT FALSE)
	message("[PID] ERROR : Please indicate what ROS distribution to use by passing the 'distribution' parameter to the configuration, e.g. check_PID_Platform(CONFIGURATION ros[distribution=kinetic])")
	return()
endif()

if(NOT ros_packages)
	message("[PID] INFO : No packages defined for the ROS configuration. To add some, use the 'packages' parameter, e.g. check_PID_Platform(CONFIGURATION ros[distribution=kinetic:packages=sensor_msgs,control_msgs])")
endif()

# use variable ros_distribution to target specific distributions
# use variable ros_packages to target additionnal packages
if(NOT ros_distribution STREQUAL USED_ROS_DISTRO OR NOT ros_FOUND OR NOT ros_packages STREQUAL USED_ROS_PACKAGES)

	set(USED_ROS_DISTRO ${ros_distribution} CACHE INTERNAL "")
	set(USED_ROS_PACKAGES ${ros_packages} CACHE INTERNAL "")
	set(ros_INCLUDE_DIRS CACHE INTERNAL "")
	set(ros_LIBS CACHE INTERNAL "")
	set(ros_RPATH CACHE INTERNAL "") # add the path to the lib folder of ros
	set(ros_BOOST_VERSION CACHE INTERNAL "")
	set(ros_BOOST_COMPONENTS CACHE INTERNAL "")

	# trying to find ros
	include(${WORKSPACE_DIR}/configurations/ros/find_ros.cmake)
	if(ros_FOUND) # if ROS distrubution and all packages have been found
		set(ros_BOOST_VERSION ${ROS_BOOST_VER} CACHE INTERNAL "")
		set(ros_BOOST_COMPONENTS ${ROS_BOOST_COMP} CACHE INTERNAL "")
		set(ros_INCLUDE_DIRS ${ROS_INCS} CACHE INTERNAL "")
		set(ros_LIBS ${ROS_LIBS} CACHE INTERNAL "")
		set(ros_RPATH ${ROS_LIB_DIRS} CACHE INTERNAL "")
		set(CHECK_ros_RESULT TRUE)
	else() # if either the distribution or any package not found
		include(${WORKSPACE_DIR}/configurations/ros/install_ros.cmake)
		set(CHECK_ros_RESULT ${ros_INSTALLED})
	endif()
else()
	set(CHECK_ros_RESULT TRUE)
endif()
