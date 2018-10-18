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
########### this is the script file to call to rebind a package's content #########
###################################################################################
## arguments (passed with -D<name>=<value>): WORKSPACE_DIR, PACKAGE_NAME, PACKAGE_VERSION, REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD (TRUE or FALSE), CMAKE_BINARY_DIR, PROJECT_NAME
set(${PACKAGE_NAME}_BINDED_AND_INSTALLED FALSE)
include(${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${PACKAGE_NAME}/${PACKAGE_VERSION}/share/Use${PACKAGE_NAME}-${PACKAGE_VERSION}.cmake OPTIONAL RESULT_VARIABLE res)
#using the generated Use<package>-<version>.cmake file to get adequate version information about components
if(	${res} STREQUAL NOTFOUND
	OR NOT DEFINED ${PACKAGE_NAME}_COMPONENTS) #if there is no component defined for the package there is an error
	message("[PID] ERROR : The binary package ${PACKAGE_NAME} (version ${PACKAGE_VERSION}) whose runtime dependencies must be (re)bound cannot be found from the workspace path : ${WORKSPACE_DIR}")
	return()
endif()

set(BIN_PACKAGE_PATH ${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${PACKAGE_NAME}/${PACKAGE_VERSION})
# using systems scripts the workspace
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)
list(APPEND CMAKE_MODULE_PATH ${BIN_PACKAGE_PATH}/share/cmake) # adding the cmake find scripts files from the package
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/find) # using common find modules of the workspace
include(PID_Package_API_Internal_Functions NO_POLICY_SCOPE)

# needed to parse adequately CMAKe variables passed to the script
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PROGRAM_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_INCLUDE_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_LIBRARY_PATH)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_PREFIXES)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_SUFFIXES)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PREFIX_PATH)
###############################################################
################## resolve platform constraints ###############
###############################################################

# 1) checking constraints on platform configuration DEBUG mode
foreach(config IN LISTS ${PACKAGE_NAME}_PLATFORM_CONFIGURATIONS_DEBUG)#if empty no configuration for this platform is supposed to be necessary
	if(EXISTS ${WORKSPACE_DIR}/configurations/${config}/check_${config}.cmake)
		if(${PACKAGE_NAME}_PLATFORM_CONFIGURATION_${config}_ARGS_DEBUG)
			prepare_Config_Arguments(${config} ${PACKAGE_NAME}_PLATFORM_CONFIGURATION_${config}_ARGS_DEBUG)#setting variables that correspond to the arguments passed to the check script
		endif()
		include(${WORKSPACE_DIR}/configurations/${config}/check_${config}.cmake)	# check the platform constraint and install it if possible
		if(NOT CHECK_${config}_RESULT) #constraints must be satisfied otherwise error
			finish_Progress(${GLOBAL_PROGRESS_VAR})
			message(FATAL_ERROR "[PID] CRITICAL ERROR : platform configuration constraint ${config} is not satisfied and cannot be solved automatically. Please contact the administrator of package ${PACKAGE_NAME}.")
			return()
		else()
			message("[PID] INFO : platform configuration ${config} for package ${PACKAGE_NAME} is satisfied.")
		endif()
	else()
		finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : when checking platform configuration constraint ${config}, information for ${config} does not exists that means this configuration is unknown within PID. Please contact the administrator of package ${PACKAGE_NAME}.")
		return()
	endif()
endforeach()

# 2) checking constraints on platform configuration RELEASE mode
foreach(config IN LISTS ${PACKAGE_NAME}_PLATFORM_CONFIGURATIONS)#if empty no configuration for this platform is supposed to be necessary
	if(EXISTS ${WORKSPACE_DIR}/configurations/${config}/check_${config}.cmake)
		if(${PACKAGE_NAME}_PLATFORM_CONFIGURATION_${config}_ARGS)
			prepare_Config_Arguments(${config} ${PACKAGE_NAME}_PLATFORM_CONFIGURATION_${config}_ARGS)#setting variables that correspond to the arguments passed to the check script
		endif()
		include(${WORKSPACE_DIR}/configurations/${config}/check_${config}.cmake)	# check the platform constraint and install it if possible
		if(NOT CHECK_${config}_RESULT) #constraints must be satisfied otherwise error
			finish_Progress(${GLOBAL_PROGRESS_VAR})
			message(FATAL_ERROR "[PID] CRITICAL ERROR : platform configuration constraint ${config} is not satisfied and cannot be solved automatically. Please contact the administrator of package ${PACKAGE_NAME}.")
			return()
		endif()
	else()
		finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : when checking platform configuration constraint ${config}, information for ${config} does not exists that means this configuration is unknown within PID. Please contact the administrator of package ${PACKAGE_NAME}.")
		return()
	endif()
endforeach()

###############################################################
############### resolving external dependencies ###############
###############################################################

# 1) getting all the runtime external dependencies of the package
foreach(ext_dep IN LISTS ${PACKAGE_NAME}_EXTERNAL_DEPENDENCIES_DEBUG)
	if(${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_USE_RUNTIME_DEBUG)
		list(APPEND ALL_EXTERNAL_DEPS_DEBUG ${ext_dep})
	endif()
endforeach()
foreach(ext_dep IN LISTS ${PACKAGE_NAME}_EXTERNAL_DEPENDENCIES)
	if(${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_USE_RUNTIME)
		list(APPEND ALL_EXTERNAL_DEPS ${ext_dep})
	endif()
endforeach()

# 2) looking for unresolved external runtime dependencies
foreach(ext_dep IN LISTS ALL_EXTERNAL_DEPS_DEBUG)
	if(CONFIG_${ext_dep})#the path has been set by the user with -DCONFIG_<package>=<path> argument
		set(${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_REFERENCE_PATH_DEBUG ${CONFIG_${ext_dep}})#changing the reference path
	else()
		is_A_System_Reference_Path(${${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_REFERENCE_PATH_DEBUG} RES)
		if(NOT RES)#by default we consider that the workspace contains installed external projects in a dedicated folder for it if the external package has not been declared as installed by default in system directories
			set(${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_REFERENCE_PATH_DEBUG ${WORKSPACE_DIR}/external/${PLATFORM_NAME}/${ext_dep} CACHE PATH "")
			list(APPEND NOT_DEFINED_EXT_DEPS_DEBUG ${ext_dep})
		endif()
	endif()
endforeach()
foreach(ext_dep IN LISTS ALL_EXTERNAL_DEPS)
	if(CONFIG_${ext_dep})#the path has been set by the user with -DCONFIG_<package>=<path> argument
		set(${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_REFERENCE_PATH ${CONFIG_${ext_dep}})#changing the reference path
	else()
		is_A_System_Reference_Path(${${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_REFERENCE_PATH} RES)
		if(NOT RES)
			set(${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_REFERENCE_PATH ${WORKSPACE_DIR}/external/${PLATFORM_NAME}/${ext_dep} CACHE PATH "")
			list(APPEND NOT_DEFINED_EXT_DEPS ${ext_dep})
		endif()

	endif()
endforeach()
if(NOT_DEFINED_EXT_DEPS OR NOT_DEFINED_EXT_DEPS_DEBUG)
	message(WARNING "[PID] WARNING : Following external packages path has been automatically set. To resolve their path by hand use -DCONFIG_<package>=<path> option when calling this script")
	foreach(ext_dep IN LISTS NOT_DEFINED_EXT_DEPS_DEBUG)
		message("[PID] DEBUG mode : ${ext_dep} with path = ${${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_REFERENCE_PATH_DEBUG}")
	endforeach()
	foreach(ext_dep IN LISTS NOT_DEFINED_EXT_DEPS)
		message("[PID] RELEASE mode : ${ext_dep} with path = ${${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_REFERENCE_PATH}")
	endforeach()

	# 3) replacing "once and for all" (until next rebind call) these dependencies in the use file
	set(theusefile ${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${PACKAGE_NAME}/${PACKAGE_VERSION}/share/Use${PACKAGE_NAME}-${PACKAGE_VERSION}.cmake)
	file(WRITE ${theusefile} "")#resetting the file content
	write_Use_File(${theusefile} ${PACKAGE_NAME} Debug)
	write_Use_File(${theusefile} ${PACKAGE_NAME} Release)
endif()


##################################################################
############### resolving all runtime dependencies ###############
##################################################################

set(${PACKAGE_NAME}_ROOT_DIR ${BIN_PACKAGE_PATH} CACHE INTERNAL "")
set(${PACKAGE_NAME}_FOUND TRUE CACHE INTERNAL "")

# finding all package dependencies
resolve_Package_Dependencies(${PACKAGE_NAME} Debug TRUE)
resolve_Package_Dependencies(${PACKAGE_NAME} Release TRUE)

# resolving runtime dependencies
resolve_Package_Runtime_Dependencies(${PACKAGE_NAME} Debug)
resolve_Package_Runtime_Dependencies(${PACKAGE_NAME} Release)

set(${PACKAGE_NAME}_BINDED_AND_INSTALLED TRUE)
