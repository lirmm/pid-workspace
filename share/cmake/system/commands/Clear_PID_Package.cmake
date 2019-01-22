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

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration

if(NOT TARGET_PACKAGE AND DEFINED ENV{package})
	set(TARGET_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_VERSION AND DEFINED ENV{version})
	set(TARGET_VERSION $ENV{version} CACHE INTERNAL "" FORCE)
endif()

if(TARGET_PACKAGE AND TARGET_VERSION)
	if(	EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE}
		AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE})
		clear_PID_Package(RES ${TARGET_PACKAGE} ${TARGET_VERSION})
		if(RES)
			if(TARGET_VERSION STREQUAL "all")
				message("[PID] INFO : all version of native package ${TARGET_PACKAGE} have been uninstalled.")
			else()
				message("[PID] INFO : native package ${TARGET_PACKAGE}, version ${TARGET_VERSION}, has been uninstalled.")
			endif()
		endif()
	elseif(EXISTS ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${TARGET_PACKAGE}
		AND IS_DIRECTORY ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${TARGET_PACKAGE})
		clear_PID_Package(RES	${TARGET_PACKAGE} ${TARGET_VERSION})
		if(RES)
			if(TARGET_VERSION STREQUAL "all")
				message("[PID] INFO : all version of external package ${TARGET_PACKAGE} have been uninstalled.")
			else()
				message("[PID] INFO : external package ${TARGET_PACKAGE}, version ${TARGET_VERSION}, has been uninstalled.")
			endif()
		endif()
	else()
		message("[PID] ERROR : there is no package named ${TARGET_PACKAGE} installed.")
	endif()
else()
	message("[PID] ERROR : you must specify the name of the package to clear using package=<name of package> argument and a version using version=<type or number of the  version>")
endif()
