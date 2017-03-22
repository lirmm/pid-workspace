#########################################################################################
#	This file is part of the program PID						#
#  	Program description : build system supportting the PID methodology  		#
#  	Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique 	#
#	et de Microelectronique de Montpellier). All Right reserved.			#
#											#
#	This software is free software: you can redistribute it and/or modify		#
#	it under the terms of the CeCILL-C license as published by			#
#	the CEA CNRS INRIA, either version 1						#
#	of the License, or (at your option) any later version.				#
#	This software is distributed in the hope that it will be useful,		#
#	but WITHOUT ANY WARRANTY; without even the implied warranty of			#
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the			#
#	CeCILL-C License for more details.						#
#											#
#	You can find the complete license description on the official website 		#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################
execute_process(COMMAND which xeno-config RESULT_VARIABLE res OUTPUT_VARIABLE XENO_CONFIG_PATH OUTPUT_STRIP_TRAILING_WHITESPACE)
if(UNIX AND NOT APPLE)
	execute_process(COMMAND which xeno-config RESULT_VARIABLE res OUTPUT_VARIABLE XENO_CONFIG_PATH OUTPUT_STRIP_TRAILING_WHITESPACE)
	if(res)
		message("[PID] ERROR: xenomai not found on the workstation, keeping current configuration.")
		set(PID_ENVIRONMENT_NOT_AVAILABLE TRUE)
	else()
		# the gcc compiler is user for building codes on host
		set(PID_ENVIRONMENT_DESCRIPTION "The development environment is based on the host base configuration configured to generate xenomai compatible code" CACHE INTERNAL "")

		set(PID_CROSSCOMPILATION FALSE CACHE INTERNAL "") #do not crosscompile since it is the same environment (host)

	endif()
else()
	set(CURRENT_ENVIRONMENT host CACHE INTERNAL "" FORCE)
	message("[PID] ERROR: xenomai cannot be used on apple platforms, keeping current configuration.")
	set(PID_ENVIRONMENT_NOT_AVAILABLE TRUE)
endif()



