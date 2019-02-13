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

function(clean_Build_Tree workspace)
file(GLOB ALL_FILES "${workspace}/pid/*")
if(ALL_FILES)
	foreach(a_file IN LISTS ALL_FILES)
		if(IS_DIRECTORY ${a_file})
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${a_file})
		elseif(NOT ${a_file} STREQUAL "${workspace}/pid/.gitignore")
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${a_file})
		endif()
	endforeach()
endif()
endfunction(clean_Build_Tree)

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/find)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/platforms)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/configurations)

include(PID_Deployment_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
include(PID_Environment_API_Internal_Functions NO_POLICY_SCOPE)

### script used to configure the environment to another one

#first check that commmand parameters are not passed as environment variables

if(NOT TARGET_ENVIRONMENT AND DEFINED ENV{environment})
	set(TARGET_ENVIRONMENT $ENV{environment} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_SYSROOT AND DEFINED ENV{sysroot})
	set(TARGET_SYSROOT $ENV{sysroot} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_STAGING AND DEFINED ENV{staging})
	set(TARGET_STAGING $ENV{staging} CACHE INTERNAL "" FORCE)
endif()

#more on platform
if(NOT TARGET_PLATFORM AND DEFINED ENV{platform})
	set(TARGET_PLATFORM $ENV{platform} CACHE INTERNAL "" FORCE)
endif()

if(TARGET_PLATFORM)
	extract_Info_From_Platform(RES_TYPE RES_ARCH RES_OS RES_ABI RES_INSTANCE RES_PLATFORM_BASE ${TARGET_PLATFORM})
	set(TARGET_PROC_TYPE ${RES_TYPE} CACHE INTERNAL "" FORCE)
	set(TARGET_PROC_ARCH ${RES_ARCH} CACHE INTERNAL "" FORCE)
	if(NOT RES_OS)
		set(TARGET_OS "Generic" CACHE INTERNAL "" FORCE)
	else()
		set(TARGET_OS ${RES_OS} CACHE INTERNAL "" FORCE)
	endif()
	set(TARGET_ABI ${RES_ABI} CACHE INTERNAL "" FORCE)
else()
	if(NOT TARGET_PROC_TYPE AND DEFINED ENV{proc_type})
		set(TARGET_PROC_TYPE $ENV{proc_type} CACHE INTERNAL "" FORCE)
	endif()
	if(NOT TARGET_PROC_ARCH AND DEFINED ENV{proc_arch})
		set(TARGET_PROC_ARCH $ENV{proc_arch} CACHE INTERNAL "" FORCE)
	endif()
	if(NOT TARGET_OS AND DEFINED ENV{os})
		set(TARGET_OS $ENV{os} CACHE INTERNAL "" FORCE)
	endif()
	if(NOT TARGET_ABI AND DEFINED ENV{abi})
		if("$ENV{abi}" STREQUAL "abi98" OR "$ENV{abi}" STREQUAL "98")
			set(TARGET_ABI CXX CACHE INTERNAL "" FORCE)
		elseif("$ENV{abi}" STREQUAL "abi11" OR "$ENV{abi}" STREQUAL "11")
			set(TARGET_ABI CXX11 CACHE INTERNAL "" FORCE)
		else()
			message("[PID] ERROR: unknown ABI specified: $ENV{abi}")
		endif()
	endif()
endif()


if(NOT TARGET_DISTRIBUTION AND DEFINED ENV{distribution})
	set(TARGET_DISTRIBUTION $ENV{distribution} CACHE INTERNAL "" FORCE)
	#more on platform
	if(NOT TARGET_DISTRIBUTION_VERSION AND DEFINED ENV{distrib_version})
		set(TARGET_DISTRIBUTION_VERSION $ENV{distrib_version} CACHE INTERNAL "" FORCE)
	endif()
endif()

#second: do the job

if(NOT TARGET_ENVIRONMENT) # checking if the target environment has to change
	message(FATAL_ERROR "[PID] ERROR : you must set the name of the target environment using environment=*name of the environment*. Use host to go back to default host build environment configuration.")
	return()
endif()

if(TARGET_ENVIRONMENT STREQUAL "host")
	message("[PID] INFO : changing to default host environment")
	#removing all cmake or pid configuration files
	hard_Clean_Build_Folder(${WORKSPACE_DIR}/pid)
	# reconfigure the pid workspace with no environment
	execute_process(COMMAND ${CMAKE_COMMAND} -DCURRENT_ENVIRONMENT= ${WORKSPACE_DIR}
			WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)

else() #we need to change the environment

	# 1. load the environment into current context
	load_Environment(IS_LOADED ${TARGET_ENVIRONMENT})
	if(NOT IS_LOADED)
		message(FATAL_ERROR "[PID] ERROR : environment ${TARGET_ENVIRONMENT} is unknown in workspace, or cannot be installed due to connection problems or permission issues.")
		return()
	endif()
	message("[PID] INFO : changing build environment to ${TARGET_ENVIRONMENT}")

	#by default we will keep the same generator except if environment specifies a new one
	include(${WORKSPACE_DIR}/pid/Workspace_Platforms_Description.cmake)
	set(CURRENT_GENERATOR "${CMAKE_GENERATOR}")
	set(CURRENT_MAKE_PROGRAM ${CMAKE_MAKE_PROGRAM})
	set(CURRENT_GENERATOR_EXTRA "${CMAKE_EXTRA_GENERATOR}")
	set(CURRENT_GENERATOR_TOOLSET "${CMAKE_GENERATOR_TOOLSET}")
	set(CURRENT_GENERATOR_PLATFORM "${CMAKE_GENERATOR_PLATFORM}")
	set(CURRENT_GENERATOR_INSTANCE "${CMAKE_GENERATOR_INSTANCE}")

	# 2. evaluate the environment with current call context
	# Warning: the generator in use may be forced by the environment, this later has priority over user defined one.
	# Warning: the sysroot in use may be forced by the user, so the sysroot passed by user has always priority over those defined by environments.
	# Warning: the staging in use may be forced by the user, so the staging passed by user has always priority over those defined by environments.
	evaluate_Environment_From_Configure(EVAL_OK ${TARGET_ENVIRONMENT} "${TARGET_SYSROOT}" "${TARGET_STAGING}" "${TARGET_PROC_TYPE}" "${TARGET_PROC_ARCH}" "${TARGET_OS}" "${TARGET_ABI}" "${TARGET_DISTRIBUTION}" "${TARGET_DISTRIBUTION_VERSION}")
	if(NOT EVAL_OK)
		message(FATAL_ERROR "[PID] ERROR : cannot evaluate environment ${TARGET_ENVIRONMENT} on current host. Aborting workspace configruation.")
		return()
	endif()
	#removing all cmake or pid configuration files in pid workspace
	clean_Build_Tree(${WORKSPACE_DIR})

	# reconfigure the pid workspace:
	# - preloading cache for all PID specific variables (-C option of cmake)
	# - using a toolchain file to configure build toolchain (-DCMAKE_TOOLCHAIN_FILE= option).
	if(EXISTS ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT}/build/PID_Toolchain.cmake)
		#preferable to copy the toolchain file in build tree of the workspace
		# this way no risk that an environment that is reconfigured generate no more toolchain file (create an error in workspace)
		file(	COPY ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT}/build/PID_Toolchain.cmake
							 ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT}/build/PID_Environment_Description.cmake
					DESTINATION ${WORKSPACE_DIR}/pid)

		execute_process(COMMAND ${CMAKE_COMMAND}
										-DCMAKE_TOOLCHAIN_FILE=${WORKSPACE_DIR}/pid/PID_Toolchain.cmake
										-DCURRENT_ENVIRONMENT=${TARGET_ENVIRONMENT}
										-C ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT}/build/PID_Environment_Description.cmake
										${WORKSPACE_DIR}
									WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)

	else()
		file(	COPY ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT}/build/PID_Environment_Description.cmake
					DESTINATION ${WORKSPACE_DIR}/pid)

		execute_process(COMMAND ${CMAKE_COMMAND}
									-DCURRENT_ENVIRONMENT=${TARGET_ENVIRONMENT}
									-C ${WORKSPACE_DIR}/pid/PID_Environment_Description.cmake
									${WORKSPACE_DIR}
								WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)

	endif()

endif()
