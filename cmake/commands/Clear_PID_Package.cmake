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


list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
load_Workspace_Info() #loading the current platform configuration

if(NOT TARGET_PACKAGE AND DEFINED ENV{package})
	set(TARGET_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_VERSION AND DEFINED ENV{version})
	set(TARGET_VERSION $ENV{version} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_PACKAGE)
	message(FATAL_ERROR "[PID] ERROR : you must specify the name of the package to clear using package=<name of package> argument. Set all as a value to uninstall all native and external packages.")
endif()
if(TARGET_PACKAGE STREQUAL "all")#cleaning all packages and wrappers, all of their version
	list_Subdirectories(PACKS_TO_UNINSTALL ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM})
	foreach(pack IN LISTS PACKS_TO_UNINSTALL)
		if(NOT pack MATCHES "^__.+__$")
			clear_PID_Package(RES ${pack} "all")
		endif()
	endforeach()
	message("[PID] INFO : all packages have been uninstalled.")
else()
	if(	NOT EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE}
			OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : there is no package named ${TARGET_PACKAGE} installed in ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}.")
	endif()
	if(NOT TARGET_VERSION)
		set(TARGET_VERSION "all" CACHE INTERNAL "" FORCE)
		message("[PID] WARNING: no version specified, uninstalling all versions of ${TARGET_PACKAGE}")
	endif()
	clear_PID_Package(RES ${TARGET_PACKAGE} ${TARGET_VERSION})
	if(RES)
		if(TARGET_VERSION STREQUAL "all")
			message("[PID] INFO : all version of package ${TARGET_PACKAGE} have been uninstalled.")
		else()
			message("[PID] INFO : package ${TARGET_PACKAGE}, version ${TARGET_VERSION}, has been uninstalled.")
		endif()
	else()
		if(TARGET_VERSION STREQUAL "all")
			message("[PID] ERROR : cannot uninstall all versions of package ${TARGET_PACKAGE}.")
		else()
			message("[PID] ERROR : cannot uninstall package ${TARGET_PACKAGE}, version ${TARGET_VERSION}.")
		endif()
	endif()
endif()
