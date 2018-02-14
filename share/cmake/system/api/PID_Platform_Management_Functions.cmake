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


###################################################################################
############### API functions for setting platform related variables ##############
###################################################################################

## check if a platform name match a platform defined in workspace
function(platform_Exist IS_DEFINED platform)
if(platform AND NOT platform STREQUAL "")
	list(FIND WORKSPACE_ALL_PLATFORMS "${platform}" INDEX)
	if(INDEX EQUAL -1)
		set(${IS_DEFINED} FALSE PARENT_SCOPE)
	else()
		set(${IS_DEFINED} TRUE PARENT_SCOPE)
	endif()
else()
	set(${IS_DEFINED} FALSE PARENT_SCOPE)
endif()
endfunction(platform_Exist)


## function used to create uvariable usefull to list common properties of platforms
function(initialize_Platform_Variables)
set(WORKSPACE_ALL_TYPE PARENT_SCOPE)
set(WORKSPACE_ALL_OS  PARENT_SCOPE)
set(WORKSPACE_ALL_ARCH PARENT_SCOPE)
set(WORKSPACE_ALL_ABI PARENT_SCOPE)
if(WORKSPACE_ALL_PLATFORMS)
	foreach(platform IN ITEMS ${WORKSPACE_ALL_PLATFORMS})
		string(REGEX REPLACE "^([^_]+)_([^_]+)_([^_]+)_([^_]+)$" "\\1;\\2;\\3;\\4" RES_LIST ${platform})
		if(NOT platform STREQUAL "${RES_LIST}")#match a platform with a target OS
			list(GET RES_LIST 0 TYPE)
			list(GET RES_LIST 1 ARCH)
			list(GET RES_LIST 2 OS)
			list(GET RES_LIST 3 ABI)
			list(APPEND WORKSPACE_ALL_TYPE ${TYPE})
			list(APPEND WORKSPACE_ALL_OS ${OS})
			list(APPEND WORKSPACE_ALL_ARCH ${ARCH})
			list(APPEND WORKSPACE_ALL_ABI ${ABI})
		else()
			string(REGEX REPLACE "^([^_]+)_([^_]+)_([^_]+)$" "\\1;\\2;\\3" RES_LIST ${platform})
			if(NOT platform STREQUAL "${RES_LIST}")#match a platform without any target OS
				list(GET RES_LIST 0 TYPE)
				list(GET RES_LIST 1 ARCH)
				list(GET RES_LIST 2 ABI)
				list(APPEND WORKSPACE_ALL_TYPE ${TYPE})
				list(APPEND WORKSPACE_ALL_ARCH ${ARCH})
				list(APPEND WORKSPACE_ALL_ABI ${ABI})
			endif()
		endif()
	endforeach()
	list(REMOVE_DUPLICATES WORKSPACE_ALL_TYPE)
	list(REMOVE_DUPLICATES WORKSPACE_ALL_OS)
	list(REMOVE_DUPLICATES WORKSPACE_ALL_ARCH)
	list(REMOVE_DUPLICATES WORKSPACE_ALL_ABI)

	set(WORKSPACE_ALL_TYPE ${WORKSPACE_ALL_TYPE} PARENT_SCOPE)
	set(WORKSPACE_ALL_OS ${WORKSPACE_ALL_OS} PARENT_SCOPE)
	set(WORKSPACE_ALL_ARCH ${WORKSPACE_ALL_ARCH} PARENT_SCOPE)
	set(WORKSPACE_ALL_ABI ${WORKSPACE_ALL_ABI} PARENT_SCOPE)
endif()
endfunction(initialize_Platform_Variables)
