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


include(${WORKSPACE_DIR}/pid/CategoriesInfo.cmake)

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)

include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)

if(TARGET_FRAMEWORK AND (NOT TARGET_FRAMEWORK STREQUAL ""))
	if(TARGET_FRAMEWORK STREQUAL "all")#listing all frameworks
		if(FRAMEWORKS_CATEGORIES)
			foreach(framework IN ITEMS ${FRAMEWORKS_CATEGORIES})
				message("- ${framework}")
			endforeach()
		else()
			message("[PID] WARNING : no framework defined in your workspace.")
		endif()
	else() #describing the categories defined by a specific framework
		print_Framework_Categories(${TARGET_FRAMEWORK}) #getting info about a framework
	endif()
elseif(TARGET_PACKAGE AND (NOT TARGET_PACKAGE STREQUAL ""))
	find_In_Categories(${TARGET_PACKAGE})
else()
	message("CATEGORIES:") # printing the structure of categories and packages they belong to
	foreach(root_cat IN ITEMS ${ROOT_CATEGORIES})
		print_Category("" ${root_cat} 0)
	endforeach()
endif()

