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
include(Package_Definition NO_POLICY_SCOPE) # to be able to interpret description of external components

load_Workspace_Info() #loading the current platform configuration
# needed to parse adequately CMAKe variables passed to the script

#first check that commmand parameters are not passed as environment variables
if(NOT INSTALLED_PACKAGE AND DEFINED ENV{package})
	set(INSTALLED_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_VERSION AND DEFINED ENV{version})
	set(TARGET_VERSION $ENV{version} CACHE INTERNAL "" FORCE)
endif()

if(NOT INSTALL_FOLDER AND DEFINED ENV{folder})
	set(INSTALL_FOLDER $ENV{folder} CACHE INTERNAL "" FORCE)
endif()

if(NOT INSTALL_MODE AND DEFINED ENV{mode})
	set(INSTALL_MODE $ENV{mode} CACHE INTERNAL "" FORCE)
endif()

#now make sure user defined folder takes priority over workspace CMAKE_INSTALL_PREFIX if defined
if(INSTALL_FOLDER)
  set(CMAKE_INSTALL_PREFIX ${INSTALL_FOLDER} CACHE INTERNAL "" FORCE)
endif()

#now make sure user defined folder takes priority over workspace CMAKE_BUILD_TYPE if defined
if(INSTALL_MODE)
  set(CMAKE_BUILD_TYPE ${INSTALL_MODE} CACHE INTERNAL "" FORCE)
endif()

#if finally no CMake build type is defined then force the use of release mode
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE INTERNAL "" FORCE)
endif()

if(INSTALLED_PACKAGE AND TARGET_VERSION)
	if(	 NOT EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${INSTALLED_PACKAGE}/${TARGET_VERSION}
		OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${INSTALLED_PACKAGE}/${TARGET_VERSION}
	)
		message(FATAL_ERROR "[PID] ERROR : binary package ${INSTALLED_PACKAGE} version ${TARGET_VERSION} is not installed in workspace,cannot install it in system.")
	endif()
	remove_Progress_File() #reset the build progress information (sanity action)
	begin_Progress(workspace GLOBAL_PROGRESS_VAR)

	install_Package_In_System(IS_INSTALLED ${INSTALLED_PACKAGE} ${TARGET_VERSION})
	if(NOT IS_INSTALLED)
		message(SEND_ERROR "[PID] ERROR : cannot install version ${TARGET_VERSION} of package ${INSTALLED_PACKAGE} in system. Maybe you must have greater permission ... try using sudo.")
	else()
		message("[PID] INFO : version ${TARGET_VERSION} of package ${INSTALLED_PACKAGE} has been installed in ${CMAKE_INSTALL_PREFIX}.")
	endif()
	finish_Progress(TRUE) #reset the build progress information
else()
	message(FATAL_ERROR "[PID] ERROR : you must specify (1) a package using argument package=<name of package>, (2) a package version using argument version=<version number>.")
endif()
