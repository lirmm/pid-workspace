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

find_package(Threads)
set(threads_COMPILE_OPTIONS CACHE INTERNAL "")
set(threads_INCLUDES CACHE INTERNAL "")
set(threads_LINK_OPTIONS CACHE INTERNAL "")
set(threads_RPATH CACHE INTERNAL "")
if(Threads_FOUND)
	set(threads_LINK_OPTIONS ${CMAKE_THREAD_LIBS_INIT} CACHE INTERNAL "")
	set(CHECK_threads_RESULT TRUE)
else()
	set(CHECK_threads_RESULT FALSE)
endif()


