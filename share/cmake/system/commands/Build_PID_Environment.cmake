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

function(clean_Build_Tree build_folder)
file(GLOB ALL_FILES "${build_folder}/*")
if(ALL_FILES)
	foreach(a_file IN LISTS ALL_FILES)
		if(IS_DIRECTORY ${a_file})
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${a_file})
		elseif(NOT ${a_file} STREQUAL "${build_folder}/.gitignore")
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
			message(FATAL_ERROR "[PID] ERROR: unknown ABI specified: $ENV{abi}")
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

evaluate_Environment_From_Script(EVAL_OK ${TARGET_ENVIRONMENT} "${TARGET_SYSROOT}" "${TARGET_STAGING}" "${TARGET_PROC_TYPE}" "${TARGET_PROC_ARCH}" "${TARGET_OS}" "${TARGET_ABI}" "${TARGET_DISTRIBUTION}" "${TARGET_DISTRIBUTION_VERSION}")
if(NOT EVAL_OK)
  message(FATAL_ERROR "[PID] ERROR : cannot evaluate environment ${TARGET_ENVIRONMENT} on current host.")
  return()
endif()

message("[PID] INFO : environment ${TARGET_ENVIRONMENT} has been evaluated.")
