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

found_PID_Configuration(ros FALSE)

set(ROS_INCS)
set(ROS_LIB_DIRS)
set(ROS_LIBS)
set(ROS_LINKS)
set(ROS_BOOST_PID_COMP)

set(ROS_PATH "/opt/ros/${ros_distribution}")
if(EXISTS "${ROS_PATH}/env.sh")

	# find packages
	list(REMOVE_DUPLICATES ros_packages)
	set(ROS_PACKAGES ${ros_packages})

	list(APPEND ros_packages roscpp)
	list(REMOVE_DUPLICATES ros_packages)
	set(CATKIN_BUILD_BINARY_PACKAGE TRUE)#before finding avoid the deployment of ROS env into install folder
	set(CATKIN_INSTALL_INTO_PREFIX_ROOT)
	find_package(catkin REQUIRED COMPONENTS ${ros_packages})
	unset(CATKIN_BUILD_BINARY_PACKAGE)
	unset(CATKIN_INSTALL_INTO_PREFIX_ROOT)
	foreach(inc IN LISTS catkin_INCLUDE_DIRS)
		string(REGEX REPLACE "^${ROS_PATH}(.*)$" "\\1" res_include ${inc})
		if(NOT res_include STREQUAL inc) # it matches
			list(APPEND ROS_INCS "${inc}")
		endif()
	endforeach()

	set(ROS_LIB_DIRS ${catkin_LIBRARY_DIRS})

	foreach(lib IN LISTS catkin_LIBRARIES)
		convert_Library_Path_To_Default_System_Library_Link(res_lib ${lib})
		string(REGEX REPLACE "^-lboost_(.*)$" "\\1" boost_lib ${res_lib})
		if(NOT res_lib STREQUAL boost_lib) # it matches
			list(APPEND ROS_BOOST_PID_COMP "boost-${boost_lib}")
			list(APPEND ROS_BOOST_LIBS "${boost_lib}") #get the boost libraries to use when checking configuration
		else()
			list(APPEND ROS_LIBS ${lib})
		endif()
	endforeach()

	if(ROS_LIBS)
		convert_PID_Libraries_Into_System_Links(ROS_LIBS ROS_LINKS)#getting good system links (with -l)
	endif()
	found_PID_Configuration(ros TRUE)
endif()
