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


#################################################################################################
########### this is the script file to update a package #########################################
########### parameters :
########### TARGET_PACKAGE : name of the package to check
########### WORKSPACE_DIR : path to the root of the workspace
#################################################################################################

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
include(Workspace_Internal_Functions NO_POLICY_SCOPE)

if(TARGET_PACKAGE)
	if(TARGET_PACKAGE STREQUAL "all")
		update_PID_All_Package()
	else()
		if(EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
			update_PID_Source_Package(${TARGET_PACKAGE})
		else()
			# it may be a binary package
			update_PID_Binary_Package(${TARGET_PACKAGE})
		endif()
	endif()
else()
	message("ERROR : You must specify the name of the package to update using name= argument. If you use all as name, all packages will be updated, either they are binary or source.")
endif()

