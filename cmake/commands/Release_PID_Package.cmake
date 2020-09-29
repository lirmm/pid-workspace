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
message("[PID] INFO : launching release of package ${TARGET_PACKAGE} ...")

#first check that commmand parameters are not passed as environment variables

if(NOT AUTOMATIC_RELEASE AND DEFINED ENV{recursive})
	set(AUTOMATIC_RELEASE $ENV{recursive} CACHE INTERNAL "" FORCE)
endif()
if(NOT TARGET_PACKAGE AND DEFINED ENV{package})
	set(TARGET_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()
if(NOT NEXT_VERSION AND DEFINED ENV{nextversion})
	set(NEXT_VERSION $ENV{nextversion} CACHE INTERNAL "" FORCE)
endif()
if(NOT FROM_BRANCH AND DEFINED ENV{branch})
	set(FROM_BRANCH $ENV{branch} CACHE INTERNAL "" FORCE)
endif()

#do the check of argument values
if(	AUTOMATIC_RELEASE STREQUAL "true"
		OR AUTOMATIC_RELEASE STREQUAL "TRUE"
		OR AUTOMATIC_RELEASE STREQUAL "ON")
	set(manage_dependencies TRUE)
else()
	set(manage_dependencies FALSE)
endif()

if(TARGET_PACKAGE)
	if(EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
		release_PID_Package(RESULT_VERSION ${TARGET_PACKAGE} "${NEXT_VERSION}" "${FROM_BRANCH}" ${manage_dependencies})
		if(NOT RESULT_VERSION)
			message(FATAL_ERROR "[PID] ERROR : release of package ${TARGET_PACKAGE} failed !")
		else()
			message("[PID] INFO : package ${TARGET_PACKAGE} version ${RESULT_VERSION} has been released.")
		endif()
	else()
		message(FATAL_ERROR "[PID] ERROR : package ${TARGET_PACKAGE} does not exist.")
	endif()
else()
	message(FATAL_ERROR "[PID] ERROR : You must specify the name of the package to release using package=<name of package> argument.")
endif()
