#########################################################################################
#	This file is part of the program PID						#
#  	Program description : build system supportting the PID methodology  		#
#  	Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique 	#
#	et de Microelectronique de Montpellier). All Right reserved.			#
#											#
#	This software is free software: you can redistribute it and/or modify		#
#	it under the terms of the CeCILL-C license as published by			#
#	the CEA CNRS INRIA, either version 1						#
#	of the License, or (at your option) any later version.				#
#	This software is distributed in the hope that it will be useful,		#
#	but WITHOUT ANY WARRANTY; without even the implied warranty of			#
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the			#
#	CeCILL-C License for more details.						#
#											#
#	You can be find the complete license description on the official website 	#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################

include(CMakeParseArguments)

### 
macro(import_PID_Workspace path)
if(${path} STREQUAL "")
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a path must be given to import_PID_Workspace.")
endif()
CMAKE_MINIMUM_REQUIRED(VERSION 3.0.2)
set(WORKSPACE_DIR ${path} CACHE INTERNAL "")

########################################################################
############ all PID system path are put into the cmake path ###########
########################################################################
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/find)
########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(PID_Set_Policies NO_POLICY_SCOPE)

include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Progress_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Finding_Functions NO_POLICY_SCOPE)
include(PID_Package_Configuration_Functions NO_POLICY_SCOPE)
include(PID_Package_Cache_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Build_Targets_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Documentation_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Deployment_Functions NO_POLICY_SCOPE)

########################################################################
############ default value for PID cache variables #####################
########################################################################
set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD FALSE CACHE INTERNAL "") #do not manage automatic install since outside from a PID workspace
set(PACKAGE_BINARY_INSTALL_DIR ${WORKSPACE_DIR}/install CACHE INTERNAL "") #install dir for native packages
set(EXTERNAL_PACKAGE_BINARY_INSTALL_DIR ${WORKSPACE_DIR}/external CACHE INTERNAL "")# install dir for external packages
endmacro(import_PID_Workspace)

### 
macro(import_PID_Package)
set(oneValueArgs NAME VERSION)
set(multiValueArgs)
cmake_parse_arguments(IMPORT_PID_PACKAGE "" "${oneValueArgs}" "" ${ARGN})
if(NOT IMPORT_PID_PACKAGE_NAME)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a package name must be given to import_PID_Package.")
endif()
if(NOT IMPORT_PID_PACKAGE_VERSION)
	message("[PID] WARNING : no version given to import_PID_Package, last available version of ${IMPORT_PID_PACKAGE_PACKAGE} will be used.")
	find_package(${IMPORT_PID_PACKAGE_NAME} REQUIRED)
else()
	find_package(${IMPORT_PID_PACKAGE_NAME} ${IMPORT_PID_PACKAGE_VERSION} EXACT REQUIRED)
endif()

if(NOT ${IMPORT_PID_PACKAGE_NAME}_FOUND)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling import_PID_Package, the package ${IMPORT_PID_PACKAGE_NAME} cannot be found (any version or required version not found).")
endif()
set(${IMPORT_PID_PACKAGE_NAME}_RPATH ${${IMPORT_PID_PACKAGE_NAME}_ROOT_DIR}/.rpath CACHE INTERNAL "")
endmacro(import_PID_Package)

### 
macro(link_PID_Components)

if(CMAKE_BUILD_TYPE STREQUAL "")
	message("[PID] WARNING : when calling link_PID_Components, no known build type defined (Release or Debug) : the Release build is selected by default.")
	set(CMAKE_BUILD_TYPE Release)
endif()
set(oneValueArgs PACKAGE NAME)
set(multiValueArgs COMPONENTS)
cmake_parse_arguments(LINK_PID_COMPONENTS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
if(NOT LINK_PID_COMPONENTS_NAME)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling link_PID_Components, name of the target must be given.")
endif()
if(NOT LINK_PID_COMPONENTS_PACKAGE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling link_PID_Components, a package name must be given.")
endif()
if(NOT LINK_PID_COMPONENTS_COMPONENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling link_PID_Components, at least one component name must be given.")
endif()
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX  ${CMAKE_BUILD_TYPE})
#create the imported targets
foreach (component IN ITEMS  ${LINK_PID_COMPONENTS_COMPONENTS})
	create_Dependency_Target(${LINK_PID_COMPONENTS_PACKAGE} ${component} ${CMAKE_BUILD_TYPE})
	is_HeaderFree_Component(DEP_IS_HF ${LINK_PID_COMPONENTS_PACKAGE} ${component})
	if(NOT DEP_IS_HF)
		target_link_libraries(${LINK_PID_COMPONENTS_NAME} PUBLIC ${LINK_PID_COMPONENTS_PACKAGE}-${component}${TARGET_SUFFIX})
		target_include_directories(${LINK_PID_COMPONENTS_NAME} PUBLIC 
			$<TARGET_PROPERTY:${LINK_PID_COMPONENTS_PACKAGE}-${component}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)

		target_compile_definitions(${LINK_PID_COMPONENTS_NAME} PUBLIC 
			$<TARGET_PROPERTY:${LINK_PID_COMPONENTS_PACKAGE}-${component}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)

		target_compile_options(${LINK_PID_COMPONENTS_NAME} PUBLIC
			$<TARGET_PROPERTY:${LINK_PID_COMPONENTS_PACKAGE}-${component}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>)
	endif()
	set(${LINK_PID_COMPONENTS_PACKAGE}_${component}_RESOURCES ${${LINK_PID_COMPONENTS_PACKAGE}_RPATH}/${component}${TARGET_SUFFIX} CACHE INTERNAL "")
	
endforeach()
endmacro(link_PID_Components)


###
macro(targets_For_PID_Components)

set(oneValueArgs PACKAGE)
set(multiValueArgs COMPONENTS)
cmake_parse_arguments(TARGETS_PID_COMPONENTS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
if(NOT TARGETS_PID_COMPONENTS_PACKAGE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling targets_For_PID_Components, a package name must be given.")
endif()
if(NOT TARGETS_PID_COMPONENTS_COMPONENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling targets_For_PID_Components, at least one component name must be given.")
endif()
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX  ${CMAKE_BUILD_TYPE})
#create the imported targets
foreach (component IN ITEMS  ${TARGETS_PID_COMPONENTS_COMPONENTS})
	create_Dependency_Target(${TARGETS_PID_COMPONENTS_PACKAGE} ${component} ${CMAKE_BUILD_TYPE})
	set(${TARGETS_PID_COMPONENTS_PACKAGE}_${component}_RESOURCES ${${TARGETS_PID_PACKAGE}_RPATH}/${component}${TARGET_SUFFIX} CACHE INTERNAL "")
endforeach()
endmacro(targets_For_PID_Components)



###
macro(path_To_PID_Component_Resources)

set(oneValueArgs PACKAGE COMPONENT RESOURCES)
cmake_parse_arguments(PATH_PID_RESOURCES "" "${oneValueArgs}" "" ${ARGN})
if(NOT PATH_PID_RESOURCES_PACKAGE OR NOT PATH_PID_RESOURCES_COMPONENT)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling path_To_PID_Component_Resources, a package name and a component name must be given. Use keywords PACKAGE and COMPONENT to do so.")
endif()
if(NOT PATH_PID_RESOURCES_RESOURCES)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling path_To_PID_Component_Resources, a return variable containing returned path to resources must be given. Use keyword RESOURCES.")
endif()
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX  ${CMAKE_BUILD_TYPE})
if (NOT TARGET ${PATH_PID_RESOURCES_PACKAGE}-${PATH_PID_RESOURCES_COMPONENT}${TARGET_SUFFIX})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling path_To_PID_Component_Resources, the target corresponding to the required component does not exist. Use targets_For_PID_Components() macro to do so.")
endif()

file(GLOB RESULT ${${TARGETS_PID_COMPONENTS_PACKAGE}_${component}_RESOURCES}/*)
set(${PATH_PID_RESOURCES_RESOURCES} ${RESULT} PARENT_SCOPE)
endmacro(path_To_PID_Component_Resources)


