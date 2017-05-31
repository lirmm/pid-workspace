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

include(${WORKSPACE_DIR}/pid/Workspace_Platforms_Info.cmake) #loading the current platform configuration

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)

include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)

# needed to parse adequately CMAKe variables passed to the script
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PROGRAM_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_INCLUDE_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_LIBRARY_PATH)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_PREFIXES)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_SUFFIXES)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PREFIX_PATH)

if(TARGET_PACKAGE AND TARGET_VERSION)
	if(	NOT EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE}
		OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE}
		OR NOT EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE}/${TARGET_VERSION}
		OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE}/${TARGET_VERSION}
	)
		message("[PID] ERROR : binary package version ${TARGET_VERSION} is not installed on the system.")
		return()
	endif()
	set(PACKAGE_NAME ${package})
	set(PROJECT_NAME ${package})
	set(PACKAGE_VERSION ${version})
	set(PLATFORM_NAME ${CURRENT_PLATFORM})
	set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD TRUE)
	include(${WORKSPACE_DIR}/share/cmake/system/Bind_PID_Package.cmake)
	if(NOT ${PACKAGE_NAME}_BINDED_AND_INSTALLED)
		message("[PID] ERROR : cannot configure runtime dependencies for installed version ${version} of package ${package}.")
	endif()
else()
	message("[PID] ERROR : you must specify (1) a package using argument name=<name of package>, (2) a package version using argument version=<version number>.")
	return()
endif()
