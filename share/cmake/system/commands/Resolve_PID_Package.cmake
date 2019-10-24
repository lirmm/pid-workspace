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
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/find) # using common find modules of the workspace
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)

include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration

# needed to parse adequately CMAKe variables passed to the script
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PROGRAM_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_INCLUDE_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_LIBRARY_PATH)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_PREFIXES)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_SUFFIXES)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PREFIX_PATH)

#first check that commmand parameters are not passed as environment variables

if(NOT TARGET_VERSION AND DEFINED ENV{version})
	set(TARGET_VERSION $ENV{version} CACHE INTERNAL "" FORCE)
endif()
if(NOT RESOLVED_PACKAGE AND DEFINED ENV{package})
	set(RESOLVED_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()


if(RESOLVED_PACKAGE AND TARGET_VERSION)
	if(	 NOT EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${RESOLVED_PACKAGE}/${TARGET_VERSION}
		OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${RESOLVED_PACKAGE}/${TARGET_VERSION}
	)
		message("[PID] ERROR : binary package version ${TARGET_VERSION} is not installed on the system.")
		return()
	endif()
	remove_Progress_File() #reset the build progress information (sanity action)
	begin_Progress(workspace GLOBAL_PROGRESS_VAR)

	bind_Installed_Package(BOUND ${CURRENT_PLATFORM} ${RESOLVED_PACKAGE} ${TARGET_VERSION} TRUE)
	if(NOT BOUND)
		message("[PID] ERROR : cannot configure runtime dependencies for installed version ${TARGET_VERSION} of package ${RESOLVED_PACKAGE}.")
	else()
		message("[PID] INFO : runtime dependencies for installed version ${TARGET_VERSION} of package ${RESOLVED_PACKAGE} have been regenerated.")
	endif()
	finish_Progress(TRUE) #reset the build progress information
else()
	message("[PID] ERROR : you must specify (1) a package using argument name=<name of package>, (2) a package version using argument version=<version number>.")
	return()
endif()
