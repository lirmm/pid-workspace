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


include(${WORKSPACE_DIR}/configurations/ros/installable_ros.cmake)
if(ros_INSTALLABLE)
	message("[PID] INFO : trying to install ROS ${ROS_DISTRO}...")
	if(CURRENT_DISTRIBUTION STREQUAL ubuntu)
		execute_process(COMMAND sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list')
		execute_process(COMMAND sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116)
		execute_process(COMMAND sudo apt-get update)
		execute_process(COMMAND sudo apt-get -y install ros-${ROS_DISTRO}-ros-base)
		if(ROS_PACKAGES)
			foreach(package IN LISTS ROS_PACKAGES)
				string(REPLACE "_" "-" package_name ${package})
				execute_process(COMMAND sudo apt-get -y install ros-${ROS_DISTRO}-${package_name})
			endif()
		endif()

		execute_process(COMMAND ${CMAKE_COMMAND} -E echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc)
		execute_process(COMMAND ${CMAKE_COMMAND} -E echo "source /opt/ros/${ROS_DISTRO}/setup.zsh" >> ~/.zshrc)
		message("Please run 'source ~/.bashrc' or 'source ~/.zshrc' depending on your shell")
	endif()
	include(${WORKSPACE_DIR}/configurations/ros/find_ros.cmake)
	if(ros_FOUND)
		message("[PID] INFO : ROS ${ROS_DISTRO} installed !")
		set(ros_INSTALLED TRUE)
	else()
		set(ros_INSTALLED FALSE)
		message("[PID] INFO : install of ROS ${ROS_DISTRO} has failed !")
	endif()
else()
	set(ros_INSTALLED FALSE)
endif()
