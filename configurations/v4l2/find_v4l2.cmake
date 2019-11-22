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

found_PID_Configuration(v4l2 FALSE)

if (UNIX)

	set(CMAKE_MODULE_PATH ${WORKSPACE_DIR}/configurations/v4l2 ${CMAKE_MODULE_PATH})
	find_package(V4L2)

	unset(${V4L2_INCLUDE_VIDEODEV2} CACHE)
	unset(${V4L2_INCLUDE_LIBV4L2} CACHE)
	unset(${V4L2_LIBRARY_LIBV4L2} CACHE)
	unset(${V4L2_LIBRARY_LIBV4LCONVERT} CACHE)

	if(V4L2_FOUND)
		convert_PID_Libraries_Into_System_Links(V4L2_LIBRARIES V4L2_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(V4L2_LIBRARIES V4L2_LIBDIRS)
		extract_Soname_From_PID_Libraries(V4L2_LIBRARIES V4L2_SONAME)
		found_PID_Configuration(v4l2 TRUE)
	else()
		message("[PID] ERROR : cannot find Video 4 Linux 2.")
	endif()
endif ()
