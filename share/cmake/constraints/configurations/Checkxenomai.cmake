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


if(NOT xenomai_FOUND)
	set(xenomai_COMPILE_OPTIONS CACHE INTERNAL "")
	set(xenomai_INCLUDES CACHE INTERNAL "")
	set(xenomai_LINK_OPTIONS CACHE INTERNAL "")
	set(xenomai_RPATH CACHE INTERNAL "")
	execute_process(COMMAND which xeno-config RESULT_VARIABLE res OUTPUT_VARIABLE XENO_CONFIG_PATH OUTPUT_STRIP_TRAILING_WHITESPACE)
	if(res)
		set(xenomai_FOUND FALSE CACHE INTERNAL "")
	else()
		set(xenomai_FOUND TRUE  CACHE INTERNAL "")
	endif()

	if(xenomai_FOUND)
		#getting flags from xenomai to put them in adequate variables
		execute_process(COMMAND ${XENO_CONFIG_PATH} --skin=posix --cflags OUTPUT_VARIABLE XENO_CFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
		execute_process(COMMAND ${XENO_CONFIG_PATH} --skin=posix --ldflags OUTPUT_VARIABLE XENO_LDFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
		set(xenomai_COMPILE_OPTIONS ${XENO_CFLAGS} CACHE INTERNAL "")
		set(xenomai_LINK_OPTIONS ${XENO_LDFLAGS} CACHE INTERNAL "") #simply adding all posix standard variabless
		set(CHECK_xenomai_RESULT TRUE)
	else()
		set(CHECK_xenomai_RESULT FALSE)
	endif()
else()
	set(CHECK_xenomai_RESULT TRUE)
endif()

