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

found_PID_Configuration(netcdf FALSE)

# - Find netcdf installation
# Try to find libraries for netcdf on UNIX systems. The following values are defined
#  NETCDF_FOUND        - True if netcdf is available
#  NETCDF_LIBRARIES    - link against these to use netcdf library
if (UNIX)

	find_path(NETCDF_INCLUDE_PATH netcdf.h)
	find_library(NETCDF_LIB NAMES netcdf libnetcdf)
	set(NETCDF_LIBRARY ${NETCDF_LIB})
	set(NETCDF_INCLUDE_DIR ${NETCDF_INCLUDE_PATH})
	unset(NETCDF_LIB CACHE)
	unset(NETCDF_INCLUDE_PATH CACHE)
	if(NETCDF_INCLUDE_DIR AND NETCDF_LIBRARY)
		set(NETCDF_VERSION "UNKNOWN-VERSION")
		convert_PID_Libraries_Into_System_Links(NETCDF_LIBRARY NETCDF_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(NETCDF_LIBRARY NETCDF_LIBDIRS)
		found_PID_Configuration(netcdf TRUE)
	else()
		message("[PID] ERROR : cannot find netcdf library.")
	endif()

endif ()
