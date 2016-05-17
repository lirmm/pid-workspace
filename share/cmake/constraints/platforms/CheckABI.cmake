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


set(CHECK_ABI_RESULT FALSE)

if(CMAKE_COMPILER_IS_GNUCXX) 
	if(NOT ${CMAKE_CXX_COMPILER_VERSION} VERSION_LESS 5.1)
		set(CURRENT_ABI "ELF11" CACHE INTERNAL)
	else()
		set(CURRENT_ABI "ELF" CACHE INTERNAL)
	endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
	set(CURRENT_ABI "MAC" CACHE INTERNAL)
else()
	set(CURRENT_ABI "" CACHE INTERNAL)	
endif()

if("${TEST_ABI}" STREQUAL "${CURRENT_ABI}")
	set(CHECK_ABI_RESULT TRUE)
endif()


