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
	if(CURRENT_DISTRIBUTION STREQUAL ubuntu)
		set(ROS_PATH "/opt/ros/${ros_distribution}")
		if(NOT EXISTS ${ROS_PATH})#the given distribution does not exist on the filesystem
			#updating apt to know where to find ROS packages
			execute_process(COMMAND lsb_release -sc OUTPUT_VARIABLE DISTRO_NICK ERROR_QUIET) #lsb_release is a standard linux command to get information about the system, including the distribution ID
			string(REGEX REPLACE "^[ \n\t]*([^ \t\n]+)[ \n\t]*" "\\1" DISTRO_NICK ${DISTRO_NICK})#getting distro nick name
			execute_process(COMMAND ${CMAKE_COMMAND} -E echo "deb http://packages.ros.org/ros/ubuntu ${DISTRO_NICK} main" OUTPUT_VARIABLE to_print)
			set(apt_list_for_ros /etc/apt/sources.list.d/ros-latest.list)
			if(EXISTS ${apt_list_for_ros})
				file(READ ${apt_list_for_ros} ROS_APT_LIST)
				set(to_print "${ROS_APT_LIST}\n${to_print}")
			endif()
			file(WRITE ${CMAKE_BINARY_DIR}/ros-latest.list "${to_print}")
			execute_OS_Configuration_Command(${CMAKE_COMMAND} -E copy_if_different ${CMAKE_BINARY_DIR}/ros-latest.list ${apt_list_for_ros})
			file(REMOVE ${CMAKE_BINARY_DIR}/ros-latest.list)
			execute_OS_Configuration_Command(apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116)
			execute_OS_Configuration_Command(apt-get update)
			execute_OS_Configuration_Command(apt-get -y install ros-${ros_distribution}-ros-base)

			#updating environment variables in order to use ROS
			if(CURRENT_SHELL STREQUAL ZSH)#shell is zsh
				set(shell_id "z" )
			else()#default shell is bash
				set(shell_id "ba" )
			endif()
			set(path_to_session_script $ENV{HOME}/.${shell_id}shrc)
			file(APPEND ${path_to_session_script} "\nsource /opt/ros/${ros_distribution}/setup.${shell_id}sh\n")
			message("[PID] WARNING : Please run 'source ~/.bashrc' or 'source ~/.zshrc' depending on your shell ! ")
		endif()

		#installing additional packages
		if(ros_packages)
			foreach(package IN LISTS ros_packages)
				string(REPLACE "_" "-" package_name ${package})
				execute_OS_Configuration_Command(apt-get -y install ros-${ros_distribution}-${package_name})
			endforeach()
		endif()

	endif()
endif()
