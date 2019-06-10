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

set(CURRENT_DISTRIBUTION CACHE INTERNAL "")
set(CURRENT_DISTRIBUTION_VERSION "" CACHE INTERNAL "")
set(CURRENT_PACKAGE_STRING CACHE INTERNAL "")
set(CURRENT_OS CACHE INTERNAL "")

set(CURRENT_PLATFORM_INSTANCE ${PID_USE_INSTANCE_NAME} CACHE INTERNAL "")#reset with current value of instance name

#test of the os is based on the compiler used  (APPLE and UNIX variables) AND on system variables affected by crosscompilation (CMAKE_SYSTEM_NAME)
#So it adapts to the current development environment in use

if(UNIX AND APPLE AND CMAKE_SYSTEM_NAME STREQUAL Darwin) #darwin = kernel name for macos systems
	set(CURRENT_OS macos  CACHE INTERNAL "")
	set(CURRENT_PACKAGE_STRING "Darwin" CACHE INTERNAL "")
	if(NOT PID_CROSSCOMPILATION)
		set(CURRENT_DISTRIBUTION "macos" CACHE INTERNAL "")
	else()
		set(CURRENT_DISTRIBUTION "" CACHE INTERNAL "")
	endif()

elseif(UNIX)
	if(CMAKE_SYSTEM_NAME STREQUAL Xenomai)# linux kernel patched with xenomai
		set(CURRENT_PACKAGE_STRING "Xenomai")
		set(CURRENT_OS "xenomai" CACHE INTERNAL "")
	elseif(CMAKE_SYSTEM_NAME STREQUAL Linux)# linux kernel = the reference !!
		set(CURRENT_PACKAGE_STRING "Linux")
		set(CURRENT_OS "linux" CACHE INTERNAL "")
	endif()
	# now check for distribution (shoud not influence contraints but only the way to install required constraints)
	if(NOT PID_CROSSCOMPILATION)
		execute_process(COMMAND lsb_release -i
										OUTPUT_VARIABLE DISTRIB_STR RESULT_VARIABLE lsb_res ERROR_QUIET) #lsb_release is a standard linux command to get information about the system, including the distribution ID
		if(NOT lsb_res EQUAL 0)
			# lsb_release is not available
			# checking for archlinux
			if(EXISTS "/etc/arch-release")
				set(DISTRIB_STR "Distributor ID:	Arch") # same string as lsb_release -i would return
			endif()
		endif()
		string(REGEX REPLACE "^[^:]+:[ \t\r]*([A-Za-z_0-9]+)[ \t\r\n]*$" "\\1" RES "${DISTRIB_STR}")

		if(NOT RES STREQUAL "${DISTRIB_STR}")#match
			string(TOLOWER "${RES}" DISTRIB_ID)
			set(CURRENT_DISTRIBUTION "${DISTRIB_ID}" CACHE INTERNAL "")
			execute_process(COMMAND lsb_release -r
											OUTPUT_VARIABLE VERSION_STR ERROR_QUIET) #lsb_release is a standard linux command to get information about the system, including the distribution ID
			string(REGEX REPLACE "^[^:]+:[ \t\r]*([\\.0-9]+)[ \t\r\n]*$" "\\1" RES "${VERSION_STR}")
			if(NOT RES STREQUAL "${VERSION_STR}")#match
				string(TOLOWER "${RES}" VERSION_NUMBER)
				set(CURRENT_DISTRIBUTION_VERSION "${VERSION_NUMBER}" CACHE INTERNAL "")
			else()
				set(CURRENT_DISTRIBUTION_VERSION "" CACHE INTERNAL "")
			endif()
		else()
			set(CURRENT_DISTRIBUTION "" CACHE INTERNAL "")
			set(CURRENT_DISTRIBUTION_VERSION "" CACHE INTERNAL "")
		endif()
	else()# when cross compiling we cannot deduce distribution info
		#but we can still use information coming from environment description
		set(CURRENT_DISTRIBUTION "${PID_USE_DISTRIBUTION}" CACHE INTERNAL "")
		set(CURRENT_DISTRIBUTION_VERSION "${PID_USE_DISTRIB_VERSION}" CACHE INTERNAL "")
	endif()
elseif(WIN32)
	set(CURRENT_OS windows  CACHE INTERNAL "")
	set(CURRENT_PACKAGE_STRING "NT" CACHE INTERNAL "")
	if(NOT PID_CROSSCOMPILATION)
		set(CURRENT_DISTRIBUTION "${CMAKE_SYSTEM_VERSION}" CACHE INTERNAL "")
	else()
		set(CURRENT_DISTRIBUTION "" CACHE INTERNAL "")
	endif()
	set(CURRENT_DISTRIBUTION_VERSION "" CACHE INTERNAL "")
endif()
#other OS are not known (add new elseif statement to check for other OS and set adequate variables)
