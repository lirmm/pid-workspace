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

set(CURRENT_DISTRIBUTION CACHE INTERNAL "")

if(APPLE)
 	if(TEST_OS STREQUAL macosx)
		set(CHECK_OS_RESULT TRUE)
	else()
		set(CHECK_OS_RESULT FALSE)
	endif()
	set(CURRENT_DISTRIBUTION "macosx" CACHE INTERNAL "")

elseif(UNIX)
	if(TEST_OS STREQUAL linux)
		set(CHECK_OS_RESULT TRUE)
	else()
		set(CHECK_OS_RESULT FALSE)
	endif()
	# now check for distribution (shoud not influence contraints but only the way to install required constraints)
	execute_process(COMMAND lsb_release -i OUTPUT_VARIABLE DISTRIB_STR ERROR_QUIET)
	string(REGEX REPLACE "^.*:[ \t]*([^ \t\n]+)[ \t]*$" "\\1" RES "${DISTRIB_STR}")
	if(NOT RES STREQUAL "${DISTRIB_STR}")#match
		string(TOLOWER "${RES}" DISTRIB_ID)
		set(CURRENT_DISTRIBUTION "${DISTRIB_ID}" CACHE INTERNAL)
	endif()
else() #other OS are not known (add new elseif statement to check for other OS
	set(CHECK_OS_RESULT FALSE)
endif()


