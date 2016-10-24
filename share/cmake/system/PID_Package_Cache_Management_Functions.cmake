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
#	You can find the complete license description on the official website 		#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################


#############################################################################################
############### API functions for managing user options cache variables #####################
#############################################################################################

###
macro(declare_Global_Cache_Options)

# base options
option(BUILD_EXAMPLES "Package builds examples" OFF)
option(BUILD_API_DOC "Package generates the HTML API documentation" OFF)
option(BUILD_AND_RUN_TESTS "Package uses tests" OFF)
option(BUILD_RELEASE_ONLY "Package only build release version" OFF)
option(GENERATE_INSTALLER "Package generates an OS installer for UNIX system" OFF)
option(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD "Enabling the automatic download of not found packages marked as required" ON)
option(ENABLE_PARALLEL_BUILD "Package is built with optimum number of jobs with respect to system properties" ON)
option(BUILD_DEPENDENT_PACKAGES "the build will leads to the rebuild of its dependent package that lies in the workspace as source packages" ON)
option(ADDITIONNAL_DEBUG_INFO "Getting more info on debug mode or more PID messages (hidden by default)" OFF)
option(BUILD_STATIC_CODE_CHECKING_REPORT "running static checks on libraries and applications, if tests are run then additionnal static code checking tests are automatically added." OFF)

# dependent options
include(CMakeDependentOption)
CMAKE_DEPENDENT_OPTION(BUILD_LATEX_API_DOC "Package generates the LATEX api documentation" OFF "BUILD_API_DOC" OFF)
CMAKE_DEPENDENT_OPTION(BUILD_TESTS_IN_DEBUG "Package build and run test in debug mode also" OFF "BUILD_AND_RUN_TESTS" OFF)
CMAKE_DEPENDENT_OPTION(BUILD_COVERAGE_REPORT "Package build a coverage report in debug mode" ON "BUILD_AND_RUN_TESTS;BUILD_TESTS_IN_DEBUG" OFF)
CMAKE_DEPENDENT_OPTION(REQUIRED_PACKAGES_AUTOMATIC_UPDATE "Package will try to install new version when configuring" OFF "REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD" OFF)

endmacro(declare_Global_Cache_Options)

###
macro(manage_Parrallel_Build_Option)

### parallel builds management
if(ENABLE_PARALLEL_BUILD)
	include(ProcessorCount)
	ProcessorCount(NUMBER_OF_JOBS)
	math(EXPR NUMBER_OF_JOBS ${NUMBER_OF_JOBS}+1)
	if(${NUMBER_OF_JOBS} GREATER 1)
		set(PARALLEL_JOBS_FLAG "-j${NUMBER_OF_JOBS}" CACHE INTERNAL "")
	endif()
else()
	set(PARALLEL_JOBS_FLAG CACHE INTERNAL "")
endif()

endmacro(manage_Parrallel_Build_Option)

function(set_Mode_Specific_Options_From_Global)
	execute_process(COMMAND ${CMAKE_COMMAND} -L -N WORKING_DIRECTORY ${CMAKE_BINARY_DIR} OUTPUT_FILE ${CMAKE_BINARY_DIR}/options.txt)
	#parsing option file and generating a load cache cmake script	
	file(STRINGS ${CMAKE_BINARY_DIR}/options.txt LINES)
	set(CACHE_OK FALSE)
	foreach(line IN ITEMS ${LINES})
		if(NOT line STREQUAL "-- Cache values")
			set(CACHE_OK TRUE)
			break()
		endif()
	endforeach()
	set(OPTIONS_FILE ${CMAKE_BINARY_DIR}/share/cacheConfig.cmake)
	file(WRITE ${OPTIONS_FILE} "")
	if(CACHE_OK)		
		foreach(line IN ITEMS ${LINES})
			if(NOT line STREQUAL "-- Cache values")
				string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "set( \\1 \\3\ CACHE \\2 \"\" FORCE)\n" AN_OPTION "${line}")
				file(APPEND ${OPTIONS_FILE} ${AN_OPTION})
			endif()
		endforeach()
	else() # only populating the load cache script with default PID cache variables to transmit them to release/debug mode caches
		file(APPEND ${OPTIONS_FILE} "set(WORKSPACE_DIR ${WORKSPACE_DIR} CACHE PATH \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_EXAMPLES ${BUILD_EXAMPLES} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_API_DOC ${BUILD_API_DOC} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_COVERAGE_REPORT ${BUILD_COVERAGE_REPORT} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_STATIC_CODE_CHECKING_REPORT ${BUILD_STATIC_CODE_CHECKING_REPORT} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_LATEX_API_DOC ${BUILD_LATEX_API_DOC} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_AND_RUN_TESTS ${BUILD_AND_RUN_TESTS} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_TESTS_IN_DEBUG ${BUILD_TESTS_IN_DEBUG} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_RELEASE_ONLY ${BUILD_RELEASE_ONLY} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(GENERATE_INSTALLER ${GENERATE_INSTALLER} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD ${REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(REQUIRED_PACKAGES_AUTOMATIC_UPDATE ${REQUIRED_PACKAGES_AUTOMATIC_UPDATE} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(ENABLE_PARALLEL_BUILD ${ENABLE_PARALLEL_BUILD} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(BUILD_DEPENDENT_PACKAGES ${BUILD_DEPENDENT_PACKAGES} CACHE BOOL \"\" FORCE)\n")
		file(APPEND ${OPTIONS_FILE} "set(ADDITIONNAL_DEBUG_INFO ${ADDITIONNAL_DEBUG_INFO} CACHE BOOL \"\" FORCE)\n")
	endif()
endfunction(set_Mode_Specific_Options_From_Global)

function(set_Global_Options_From_Mode_Specific)

	# copying new cache entries in the global build cache
	execute_process(COMMAND ${CMAKE_COMMAND} -LH -N WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/debug OUTPUT_FILE ${CMAKE_BINARY_DIR}/optionsDEBUG.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -LH -N WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/release OUTPUT_FILE ${CMAKE_BINARY_DIR}/optionsRELEASE.txt)
	file(STRINGS ${CMAKE_BINARY_DIR}/options.txt LINES_GLOBAL)		
	file(STRINGS ${CMAKE_BINARY_DIR}/optionsDEBUG.txt LINES_DEBUG)
	file(STRINGS ${CMAKE_BINARY_DIR}/optionsRELEASE.txt LINES_RELEASE)
	# searching new cache entries in release mode cache
	foreach(line IN ITEMS ${LINES_RELEASE})
		if(NOT "${line}" STREQUAL "-- Cache values" AND NOT "${line}" STREQUAL "")#this line may contain option info
			string(REGEX REPLACE "^//(.*)$" "\\1" COMMENT ${line})
			if("${line}" STREQUAL "${COMMENT}") #no match this is an option line
				string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "\\1;\\3;\\2" AN_OPTION "${line}")
				list(GET AN_OPTION 0 var_name)
				string(FIND "${LINES}" "${var_name}" POS)	
				if(POS EQUAL -1)#not found, this a new cache entry
					list(GET AN_OPTION 1 var_value)
					list(GET AN_OPTION 2 var_type)
					set(${var_name} ${var_value} CACHE ${var_type} "${last_comment}")
				endif()
			else()#match is OK this is a comment line
				set(last_comment "${COMMENT}")
			endif()
		endif()
	endforeach()

	# searching new cache entries in debug mode cache	
	foreach(line IN ITEMS ${LINES_DEBUG})
		if(NOT "${line}" STREQUAL "-- Cache values" AND NOT "${line}" STREQUAL "")
			string(REGEX REPLACE "^//(.*)$" "\\1" COMMENT ${line})
			if("${line}" STREQUAL "${COMMENT}") #no match this is an option line
				string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "\\1;\\3;\\2" AN_OPTION "${line}")
				list(GET AN_OPTION 0 var_name)
				string(FIND "${LINES}" "${var_name}" POS)
				string(FIND "${LINES_RELEASE}" "${var_name}" POS_REL)
				if(POS EQUAL -1 AND POS_REL EQUAL -1)#not found
					list(GET AN_OPTION 1 var_value)
					list(GET AN_OPTION 2 var_type)				
					set(${var_name} ${var_value} CACHE ${var_type} "${last_comment}")
				endif()
			else()#match is OK this is a comment line
				set(last_comment "${COMMENT}")
			endif()
		endif()
	endforeach()
	# searching removed cache entries in release and debug mode caches => then remove them from global cache
	foreach(line IN ITEMS ${LINES_GLOBAL})
		if(NOT "${line}" STREQUAL "-- Cache values" AND NOT "${line}" STREQUAL "")#this line may contain option info
			string(REGEX REPLACE "^//(.*)$" "\\1" COMMENT ${line})
			if("${line}" STREQUAL "${COMMENT}") #no match this is an option line
				string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "\\1;\\3;\\2" AN_OPTION "${line}")
				list(GET AN_OPTION 0 var_name)
				string(FIND "${LINES_DEBUG}" "${var_name}" POS_DEB)
				string(FIND "${LINES_RELEASE}" "${var_name}" POS_REL)
				if(POS_DEB EQUAL -1 AND POS_REL EQUAL -1)#not found in any mode specific cache
					unset(${var_name} CACHE)
				endif()
			endif()
		endif()
	endforeach()

	#removing temporary files containing cache entries
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/optionsDEBUG.txt)
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/optionsRELEASE.txt)
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/options.txt)
endfunction(set_Global_Options_From_Mode_Specific)

###
function(reset_Mode_Cache_Options CACHE_POPULATED)

#unset all global options
set(WORKSPACE_DIR "" CACHE PATH "" FORCE)
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_API_DOC OFF CACHE BOOL "" FORCE)
set(BUILD_COVERAGE_REPORT OFF CACHE BOOL "" FORCE)
set(BUILD_STATIC_CODE_CHECKING_REPORT OFF CACHE BOOL "" FORCE)
set(BUILD_LATEX_API_DOC OFF CACHE BOOL "" FORCE)
set(BUILD_AND_RUN_TESTS OFF CACHE BOOL "" FORCE)
set(BUILD_TESTS_IN_DEBUG OFF CACHE BOOL "" FORCE)
set(BUILD_RELEASE_ONLY OFF CACHE BOOL "" FORCE)
set(GENERATE_INSTALLER OFF CACHE BOOL "" FORCE)
set(ADDITIONNAL_DEBUG_INFO OFF CACHE BOOL "" FORCE)
set(REQUIRED_PACKAGES_AUTOMATIC_UPDATE OFF CACHE BOOL "" FORCE)
#default ON options
set(ENABLE_PARALLEL_BUILD ON CACHE BOOL "" FORCE)
set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD ON CACHE BOOL "" FORCE)
set(BUILD_DEPENDENT_PACKAGES ON CACHE BOOL "" FORCE)
#include the cmake script that sets the options coming from the global build configuration
if(EXISTS ${CMAKE_BINARY_DIR}/../share/cacheConfig.cmake)
	include(${CMAKE_BINARY_DIR}/../share/cacheConfig.cmake NO_POLICY_SCOPE)
	set(${CACHE_POPULATED} TRUE PARENT_SCOPE)
else()
	set(${CACHE_POPULATED} FALSE PARENT_SCOPE)
endif()

#some purely internal variable that are global for the project
set(PROJECT_RUN_TESTS FALSE CACHE INTERNAL "")
endfunction(reset_Mode_Cache_Options)


### setting global variable describing versions used
function(init_PID_Version_Variable)
if(NOT EXISTS ${WORKSPACE_DIR}/pid/PID_version.cmake)#if workspace has not been built (or build files deleted), then build it to get the version
	execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR} WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
endif()
include(${WORKSPACE_DIR}/pid/PID_version.cmake) # get the current workspace version

if(	EXISTS ${CMAKE_SOURCE_DIR}/share/cmake/${PROJECT_NAME}_PID_Version.cmake)# get the workspace version with wich the package has been built
	#The file already resides in package shared files 
	include(${CMAKE_SOURCE_DIR}/share/cmake/${PROJECT_NAME}_PID_Version.cmake)
	if(${PID_WORKSPACE_VERSION} LESS ${${PROJECT_NAME}_PID_VERSION})#workspace need to be updated
		update_Workspace_Repository("origin")
		execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR} WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
		include(${WORKSPACE_DIR}/pid/PID_version.cmake) # get the current workspace version AGAIN (most up to date version)
		if(${PID_WORKSPACE_VERSION} LESS ${${PROJECT_NAME}_PID_VERSION})#still less => impossible
			message("[PID] INFO : PID version ${${PROJECT_NAME}_PID_VERSION} is corrupted for package ${PROJECT_NAME} ... regenerating version according to most up to date workspace.")
			set(${PROJECT_NAME}_PID_VERSION ${PID_WORKSPACE_VERSION} CACHE INTERNAL "")
			file(WRITE ${CMAKE_SOURCE_DIR}/share/cmake/${PROJECT_NAME}_PID_Version.cmake "set(${PROJECT_NAME}_PID_VERSION ${${PROJECT_NAME}_PID_VERSION} CACHE INTERNAL \"\")")#save the PID version with which the package has been built
		endif()
	#else if > the workspace version of scripts should be able to manage difference between versions by using the ${PROJECT_NAME}_PID_VERSION variable (inside package) or ${package_name}_PID_VERSION (outside package)
	endif()
else()
	set(${PROJECT_NAME}_PID_VERSION ${PID_WORKSPACE_VERSION})#if no version defined yet then set it to the current workspace one
	file(WRITE ${CMAKE_SOURCE_DIR}/share/cmake/${PROJECT_NAME}_PID_Version.cmake "set(${PROJECT_NAME}_PID_VERSION ${${PROJECT_NAME}_PID_VERSION} CACHE INTERNAL \"\")")#save the PID version with which the package has been built
endif()

endfunction(init_PID_Version_Variable)

###
function(first_Called_Build_Mode RESULT)
set(${RESULT} FALSE PARENT_SCOPE)
if(CMAKE_BUILD_TYPE MATCHES Debug OR (CMAKE_BUILD_TYPE MATCHES Release AND BUILD_RELEASE_ONLY))
	set(${RESULT} TRUE PARENT_SCOPE)
endif()
endfunction(first_Called_Build_Mode)

############################################################################
############### API functions for setting global package info ##############
############################################################################

### printing variables for components in the package ################
macro(print_Component component imported)
	message("COMPONENT : ${component}${INSTALL_NAME_SUFFIX}")
	message("INTERFACE : ")
	get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_INCLUDE_DIRECTORIES)
	message("includes of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
	get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_COMPILE_DEFINITIONS)
	message("defs of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
	get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_LINK_LIBRARIES)
	message("libraries of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
	if(NOT ${imported} AND NOT ${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
		message("IMPLEMENTATION :")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INCLUDE_DIRECTORIES)
		message("includes of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} COMPILE_DEFINITIONS)
		message("defs of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} LINK_LIBRARIES)
		message("libraries of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
	endif()
endmacro(print_Component)

macro(print_Component_Variables)
	message("components of package ${PROJECT_NAME} are :" ${${PROJECT_NAME}_COMPONENTS})
	message("libraries : " ${${PROJECT_NAME}_COMPONENTS_LIBS})
	message("applications : " ${${PROJECT_NAME}_COMPONENTS_APPS})

	foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
		print_Component(${component} FALSE)	
	endforeach()
endmacro(print_Component_Variables)

function(init_Package_Info_Cache_Variables author institution mail description year license address)
set(res_string)	
foreach(string_el IN ITEMS ${author})
	set(res_string "${res_string}_${string_el}")
endforeach()
set(${PROJECT_NAME}_MAIN_AUTHOR "${res_string}" CACHE INTERNAL "")

set(res_string "")
foreach(string_el IN ITEMS ${institution})
	set(res_string "${res_string}_${string_el}")
endforeach()
set(${PROJECT_NAME}_MAIN_INSTITUTION "${res_string}" CACHE INTERNAL "")
set(${PROJECT_NAME}_CONTACT_MAIL ${mail} CACHE INTERNAL "")

set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_MAIN_AUTHOR}(${${PROJECT_NAME}_MAIN_INSTITUTION})" CACHE INTERNAL "")
set(${PROJECT_NAME}_DESCRIPTION "${description}" CACHE INTERNAL "")
set(${PROJECT_NAME}_YEARS ${year} CACHE INTERNAL "")
set(${PROJECT_NAME}_LICENSE ${license} CACHE INTERNAL "")
if(${CMAKE_BUILD_TYPE} MATCHES Release)
set(${PROJECT_NAME}_ADDRESS ${address} CACHE INTERNAL "")
set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")#categories are reset
endif()
reset_References_Info()
reset_Version_Cache_Variables()
endfunction(init_Package_Info_Cache_Variables)

function(init_Standard_Path_Cache_Variables)
set(PACKAGE_BINARY_INSTALL_DIR ${WORKSPACE_DIR}/install CACHE INTERNAL "")
set(EXTERNAL_PACKAGE_BINARY_INSTALL_DIR ${WORKSPACE_DIR}/external CACHE INTERNAL "")
set(${PROJECT_NAME}_INSTALL_PATH ${PACKAGE_BINARY_INSTALL_DIR}/${PROJECT_NAME} CACHE INTERNAL "")
set(CMAKE_INSTALL_PREFIX ${${PROJECT_NAME}_INSTALL_PATH}  CACHE INTERNAL "")
set(${PROJECT_NAME}_PID_RUNTIME_RESOURCE_PATH ${CMAKE_SOURCE_DIR}/share/resources CACHE INTERNAL "")
endfunction(init_Standard_Path_Cache_Variables)

### wiki related cache variables management
function(init_Wiki_Info_Cache_Variables repo home_page framework parent_page content_file introduction)
set(${PROJECT_NAME}_WIKI_ADDRESS "${repo}" CACHE INTERNAL "")
set(${PROJECT_NAME}_WIKI_ROOT_PAGE "${home_page}" CACHE INTERNAL "")
set(${PROJECT_NAME}_WIKI_FRAMEWORK "${framework}" CACHE INTERNAL "")
set(${PROJECT_NAME}_WIKI_PARENT_PAGE "${parent_page}" CACHE INTERNAL "")
set(${PROJECT_NAME}_WIKI_ROOT_PAGE_CONTENT "${content_file}" CACHE INTERNAL "")
set(${PROJECT_NAME}_WIKI_ROOT_PAGE_INTRODUCTION "${introduction}" CACHE INTERNAL "")
endfunction(init_Wiki_Info_Cache_Variables)

function(reset_Wiki_Info)
set(${PROJECT_NAME}_WIKI_ADDRESS CACHE INTERNAL "")
set(${PROJECT_NAME}_WIKI_ROOT_PAGE CACHE INTERNAL "")
set(${PROJECT_NAME}_WIKI_PARENT_PAGE CACHE INTERNAL "")
set(${PROJECT_NAME}_WIKI_FRAMEWORK CACHE INTERNAL "")
set(${PROJECT_NAME}_WIKI_ROOT_PAGE_CONTENT CACHE INTERNAL "")
set(${PROJECT_NAME}_WIKI_ROOT_PAGE_INTRODUCTION CACHE INTERNAL "")
endfunction(reset_Wiki_Info)


### set cache variable for install
function(set_Install_Cache_Variables)
	set(${PROJECT_NAME}_DEPLOY_PATH ${${PROJECT_NAME}_VERSION} CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_LIB_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_AR_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_HEADERS_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/include CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_SHARE_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/share CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_BIN_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/bin CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_RPATH_DIR ${${PROJECT_NAME}_DEPLOY_PATH}/.rpath CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_ROOT_DIR ${PACKAGE_BINARY_INSTALL_DIR}/${PROJECT_NAME}/${${PROJECT_NAME}_DEPLOY_PATH} CACHE INTERNAL "")
endfunction(set_Install_Cache_Variables)

### setting cache variable for versionning
function(set_Version_Cache_Variables major minor patch)
	set (${PROJECT_NAME}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH} CACHE INTERNAL "")
endfunction(set_Version_Cache_Variables)


function(reset_Version_Cache_Variables)
#resetting general info about the package : only list are reset
set (${PROJECT_NAME}_VERSION_MAJOR CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION_MINOR CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION_PATCH CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION CACHE INTERNAL "" )
endfunction(reset_Version_Cache_Variables)

###
function(add_Author author institution)
	set(res_string_author)	
	foreach(string_el IN ITEMS ${author})
		set(res_string_author "${res_string_author}_${string_el}")
	endforeach()
	set(res_string_instit)
	foreach(string_el IN ITEMS ${institution})
		set(res_string_instit "${res_string_instit}_${string_el}")
	endforeach()
	set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS};${res_string_author}(${res_string_instit})" CACHE INTERNAL "")
endfunction(add_Author)


###
function(add_Category category_spec)
	set(${PROJECT_NAME}_CATEGORIES ${${PROJECT_NAME}_CATEGORIES} ${category_spec} CACHE INTERNAL "")
endfunction(add_Category)

###################################################################################
############### API functions for setting platform related variables ##############
###################################################################################

### here platform matches a platform defined in available platforms variable
function(add_Reference version platform url url-dbg)
	list(FIND ${PROJECT_NAME}_AVAILABLE_PLATFORMS${USE_MODE_SUFFIX} ${platform} INDEX)
	if(INDEX EQUAL -1)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: unknown target platform ${platform} when adding reference.")
		return()
	endif()
	set(LIST_OF_VERSIONS ${${PROJECT_NAME}_REFERENCES} ${version})
	list(REMOVE_DUPLICATES LIST_OF_VERSIONS)
	set(${PROJECT_NAME}_REFERENCES  ${LIST_OF_VERSIONS} CACHE INTERNAL "")
	list(FIND ${PROJECT_NAME}_REFERENCE_${version} ${platform} INDEX)
	if(INDEX EQUAL -1)	
		set(${PROJECT_NAME}_REFERENCE_${version} ${${PROJECT_NAME}_REFERENCE_${version}} ${platform} CACHE INTERNAL "")
		set(${PROJECT_NAME}_REFERENCE_${version}_${platform}_URL ${url} CACHE INTERNAL "")
		set(${PROJECT_NAME}_REFERENCE_${version}_${platform}_URL_DEBUG ${url-dbg} CACHE INTERNAL "")
	endif()
endfunction(add_Reference)

###
function(reset_References_Info)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")
	# references to package binaries version available must be reset
	foreach(ref_version IN ITEMS ${${PROJECT_NAME}_REFERENCES})
		foreach(ref_platform IN ITEMS ${${PROJECT_NAME}_REFERENCE_${ref_version}})
			set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL CACHE INTERNAL "")
			set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG CACHE INTERNAL "")
		endforeach()
		set(${PROJECT_NAME}_REFERENCE_${ref_version} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_REFERENCES CACHE INTERNAL "")
endif()
endfunction(reset_References_Info)


###
function(reset_Platforms_Variables)
	if(${PROJECT_NAME}_AVAILABLE_PLATFORMS${USE_MODE_SUFFIX})
		foreach(platform IN ITEMS ${${PROJECT_NAME}_AVAILABLE_PLATFORMS${USE_MODE_SUFFIX}})
			set(${PROJECT_NAME}_AVAILABLE_PLATFORM_${name}_OS${USE_MODE_SUFFIX} CACHE INTERNAL "")
			set(${PROJECT_NAME}_AVAILABLE_PLATFORM_${name}_ARCH${USE_MODE_SUFFIX} CACHE INTERNAL "")
			set(${PROJECT_NAME}_AVAILABLE_PLATFORM_${name}_ABI${USE_MODE_SUFFIX} CACHE INTERNAL "")
			set(${PROJECT_NAME}_AVAILABLE_PLATFORM_${name}_CONFIGURATION${USE_MODE_SUFFIX} CACHE INTERNAL "")
		endforeach()
	endif()
	set(${PROJECT_NAME}_AVAILABLE_PLATFORMS${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_PLATFORM${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_PLATFORM_OS${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_PLATFORM_ARCH${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_PLATFORM_ABI${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_PLATFORM_CONFIGURATION${USE_MODE_SUFFIX} CACHE INTERNAL "")
endfunction(reset_Platforms_Variables)

###
function(add_Platform SELECT name os arch abi constraints)
	list(FIND ${PROJECT_NAME}_AVAILABLE_PLATFORMS${USE_MODE_SUFFIX} "${name}" INDEX)
	if(INDEX EQUAL -1)
		set(${PROJECT_NAME}_AVAILABLE_PLATFORMS${USE_MODE_SUFFIX} ${${PROJECT_NAME}_AVAILABLE_PLATFORMS${USE_MODE_SUFFIX}} ${name} CACHE INTERNAL "")
		set(${PROJECT_NAME}_AVAILABLE_PLATFORM_${name}_OS${USE_MODE_SUFFIX} ${os} CACHE INTERNAL "")
		set(${PROJECT_NAME}_AVAILABLE_PLATFORM_${name}_ARCH${USE_MODE_SUFFIX} ${arch} CACHE INTERNAL "")
		set(${PROJECT_NAME}_AVAILABLE_PLATFORM_${name}_ABI${USE_MODE_SUFFIX} ${abi} CACHE INTERNAL "")
		set(${PROJECT_NAME}_AVAILABLE_PLATFORM_${name}_CONFIGURATION${USE_MODE_SUFFIX} ${constraints} CACHE INTERNAL "")
	else()
		message(FATAL_ERROR "[PID] CRITICAL ERROR : when defining platform ${name}, this platform is already defined, please use another name.")
	endif()
	if(SELECT)
		set(${PROJECT_NAME}_PLATFORM${USE_MODE_SUFFIX} ${name} CACHE INTERNAL "")
		set(${PROJECT_NAME}_PLATFORM_OS${USE_MODE_SUFFIX} ${os} CACHE INTERNAL "")
		set(${PROJECT_NAME}_PLATFORM_ARCH${USE_MODE_SUFFIX} ${arch} CACHE INTERNAL "")
		set(${PROJECT_NAME}_PLATFORM_ABI${USE_MODE_SUFFIX} ${abi} CACHE INTERNAL "")
		set(${PROJECT_NAME}_PLATFORM_CONFIGURATION${USE_MODE_SUFFIX} ${constraints} CACHE INTERNAL "")
	endif()
endfunction(add_Platform)

###
function(platform_Selected SELECTED)
	if(${PROJECT_NAME}_PLATFORM${USE_MODE_SUFFIX})
		set(${SELECTED} TRUE PARENT_SCOPE)
	else()
		set(${SELECTED} FALSE PARENT_SCOPE)
	endif()
endfunction(platform_Selected)


###
function(platform_Available AVAILABLE)
	if(${PROJECT_NAME}_AVAILABLE_PLATFORMS${USE_MODE_SUFFIX})
		set(${AVAILABLE} TRUE PARENT_SCOPE)
	else()
		set(${AVAILABLE} FALSE PARENT_SCOPE)
	endif()
endfunction(platform_Available)

#############################################################################################
############### API functions for setting components related cache variables ################
#############################################################################################

### configure variables exported by component that will be used to generate the package cmake use file
function (configure_Install_Variables component export include_dirs dep_defs exported_defs exported_options static_links shared_links runtime_resources)

# configuring the export
if(export) # if dependancy library is exported then we need to register its dep_defs and include dirs in addition to component interface defs
	if(	NOT dep_defs STREQUAL "" 
		OR NOT exported_defs  STREQUAL "")	
		set(	${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}} 
			${exported_defs} ${dep_defs}
			CACHE INTERNAL "")
	endif()
	if(NOT include_dirs STREQUAL "")
		set(	${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} 
			${${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX}} 
			${include_dirs}
			CACHE INTERNAL "")
	endif()
	if(NOT exported_options STREQUAL "")	
		set(	${PROJECT_NAME}_${component}_OPTS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_OPTS${USE_MODE_SUFFIX}} 
			${exported_options}
			CACHE INTERNAL "")
	endif()
	
	# links are exported since we will need to resolve symbols in the third party components that will the use the component 	
	if(NOT shared_links STREQUAL "")
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}			
			${shared_links}			
			CACHE INTERNAL "")
	endif()
	if(NOT static_links STREQUAL "")
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}			
			${static_links}			
			CACHE INTERNAL "")
	endif()

else() # otherwise no need to register them since no more useful
	if(NOT exported_defs STREQUAL "") 
		#just add the exported defs of the component not those of the dependency
		set(	${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}} 
			${exported_defs}
			CACHE INTERNAL "")
	endif()
	if(NOT static_links STREQUAL "") #static links are exported if component is not a shared lib (otherwise they simply disappear)
		if (	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER" 
			OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "STATIC"
		)
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}			
			${static_links}			
			CACHE INTERNAL "")
		endif()
	endif()
	if(NOT shared_links STREQUAL "")#private links are shared "non exported" libraries -> these links are used to process executables linking
		set(	${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX}}
			${shared_links}
			CACHE INTERNAL "")
	endif()
endif()

if(NOT runtime_resources STREQUAL "")#runtime resources are exported in any case
	set(	${PROJECT_NAME}_${component}_RUNTIME_RESOURCES
		${${PROJECT_NAME}_${component}_RUNTIME_RESOURCES}
		${runtime_resources}
		CACHE INTERNAL "")
endif()
endfunction(configure_Install_Variables)


### reset components related cached variables 
function(reset_Component_Cached_Variables component)
# resetting package dependencies
foreach(a_dep_pack IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}})
	foreach(a_dep_comp IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCY_${a_dep_pack}_COMPONENTS${USE_MODE_SUFFIX}})
		set(${PROJECT_NAME}_${component}_EXPORT_${a_dep_pack}_${a_dep_comp}${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_${component}_DEPENDENCY_${a_dep_pack}_COMPONENTS${USE_MODE_SUFFIX}  CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}  CACHE INTERNAL "")

# resetting internal dependencies
foreach(a_internal_dep_comp IN ITEMS ${${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}})
	set(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${a_internal_dep_comp}${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")

#resetting all other variables
set(${PROJECT_NAME}_${component}_HEADER_DIR_NAME CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_HEADERS CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_BINARY_NAME${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_OPTS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_SOURCE_CODE CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_SOURCE_DIR CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_DESCRIPTION CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_USAGE_INCLUDES CACHE INTERNAL "")
endfunction(reset_Component_Cached_Variables)

function(init_Component_Cached_Variables_For_Export component exported_defs exported_options exported_links runtime_resources)
set(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} "${exported_defs}" CACHE INTERNAL "") #exported defs
set(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} "${exported_links}" CACHE INTERNAL "") #exported links
set(${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} "" CACHE INTERNAL "") #exported include directories (not useful to set it there since they will be exported "manually")
set(${PROJECT_NAME}_${component}_OPTS${USE_MODE_SUFFIX} "${exported_options}" CACHE INTERNAL "") #exported compiler options
set(${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${USE_MODE_SUFFIX} "${runtime_resources}" CACHE INTERNAL "")#runtime resources are exported by default
endfunction(init_Component_Cached_Variables_For_Export)

### resetting all internal cached variables that would cause some troubles
function(reset_All_Component_Cached_Variables)

# package dependencies declaration must be reinitialized otherwise some problem (uncoherent dependancy versions) would appear
foreach(dep_package IN ITEMS ${${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX}})
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} CACHE INTERNAL "")	
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_${${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")

# external package dependencies declaration must be reinitialized 
foreach(dep_package IN ITEMS ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}})
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} CACHE INTERNAL "")	
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")

# component declaration must be reinitialized otherwise some problem (redundancy of declarations) would appear
foreach(a_component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	reset_Component_Cached_Variables(${a_component})
endforeach()
reset_Declared()
set(${PROJECT_NAME}_COMPONENTS CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_LIBS CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_APPS CACHE INTERNAL "")

#unsetting all root variables usefull to the find/configuration mechanism
foreach(a_used_package IN ITEMS ${${PROJECT_NAME}_ALL_USED_PACKAGES})
	set(${a_used_package}_FOUND CACHE INTERNAL "")
	set(${a_used_package}_ROOT_DIR CACHE INTERNAL "")
	set(${a_used_package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "")
	set(${a_used_package}_REQUIRED_VERSION_EXACT CACHE INTERNAL "")
endforeach()
foreach(a_used_package IN ITEMS ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES})
	set(${a_used_package}_FOUND CACHE INTERNAL "")
	set(${a_used_package}_ROOT_DIR CACHE INTERNAL "")
	set(${a_used_package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "")
	set(${a_used_package}_REQUIRED_VERSION_EXACT CACHE INTERNAL "")
endforeach()

set(${PROJECT_NAME}_ALL_USED_PACKAGES CACHE INTERNAL "")
set(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES CACHE INTERNAL "")
reset_Platforms_Variables()
reset_To_Install_Packages()
reset_To_Install_External_Packages()
reset_Wiki_Info()
endfunction(reset_All_Component_Cached_Variables)

###
function(init_Component_Description component description usage)
generate_Formatted_String("${description}" RES_STRING)
set(${PROJECT_NAME}_${component}_DESCRIPTION "${RES_STRING}" CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_USAGE_INCLUDES "${usage}" CACHE INTERNAL "")
endfunction(init_Component_Description)

###
function(mark_As_Declared component)
set(${PROJECT_NAME}_DECLARED_COMPS ${${PROJECT_NAME}_DECLARED_COMPS} ${component} CACHE INTERNAL "")
endfunction(mark_As_Declared)

###
function(is_Declared component RES)
list(FIND ${PROJECT_NAME}_DECLARED_COMPS ${component} INDEX)
if(INDEX EQUAL -1)
	set(${RES} FALSE PARENT_SCOPE)
else()
	set(${RES} TRUE PARENT_SCOPE)
endif()

endfunction(is_Declared)

###
function(reset_Declared)
set(${PROJECT_NAME}_DECLARED_COMPS CACHE INTERNAL "")
endfunction(reset_Declared)

function(export_Component IS_EXPORTING package component dep_package dep_component mode)
is_HeaderFree_Component(IS_HF ${package} ${component})
if(IS_HF)
	set(${IS_EXPORTING} FALSE PARENT_SCOPE)
	return()
endif()
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})	

if(package STREQUAL "${dep_package}")
	if(${package}_${component}_INTERNAL_EXPORT_${dep_component}${VAR_SUFFIX})
		set(${IS_EXPORTING} TRUE PARENT_SCOPE)
	else()
		set(${IS_EXPORTING} FALSE PARENT_SCOPE)
	endif()
else()
	if(${package}_${component}_EXPORT_${dep_package}_${dep_component}${VAR_SUFFIX})
		set(${IS_EXPORTING} TRUE PARENT_SCOPE)
	else()
		set(${IS_EXPORTING} FALSE PARENT_SCOPE)
	endif()	

endif()

endfunction(export_Component)

### to know if the component is an application
function(is_HeaderFree_Component ret_var package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	OR ${package}_${component}_TYPE STREQUAL "MODULE"
	)
	set(${ret_var} TRUE PARENT_SCOPE)
else()
	set(${ret_var} FALSE PARENT_SCOPE)
endif()
endfunction(is_HeaderFree_Component)


### to know if the component is an application
function(is_Executable_Component ret_var package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	)
	set(${ret_var} TRUE PARENT_SCOPE)
else()
	set(${ret_var} FALSE PARENT_SCOPE)
endif()
endfunction(is_Executable_Component)

### to know if component will be built
function (is_Built_Component ret_var  package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	OR ${package}_${component}_TYPE STREQUAL "STATIC"
	OR ${package}_${component}_TYPE STREQUAL "SHARED"
	OR ${package}_${component}_TYPE STREQUAL "MODULE"
)
	set(${ret_var} TRUE PARENT_SCOPE)
else()
	set(${ret_var} FALSE PARENT_SCOPE)
endif()
endfunction(is_Built_Component)

function(build_Option_For_Example example_comp)
CMAKE_DEPENDENT_OPTION(BUILD_EXAMPLE_${example_comp} "Package build the example application ${example_comp}" ON "BUILD_EXAMPLES" ON)
endfunction(build_Option_For_Example)

function(reset_Removed_Examples_Build_Option)
get_cmake_property(ALL_CACHED_VARIABLES CACHE_VARIABLES) #getting all cache variables
foreach(a_cache_var ${ALL_CACHED_VARIABLES})
	string(REGEX REPLACE "^BUILD_EXAMPLE_(.*)$" "\\1" EXAMPLE_NAME ${a_cache_var})

	if(NOT EXAMPLE_NAME STREQUAL "${a_cache_var}")#match => this is an option related to an example !!
		set(DECLARED FALSE)
		is_Declared(${EXAMPLE_NAME} DECLARED)
		if(NOT DECLARED)# corresponding example component has not been declared
			unset(${a_cache_var} CACHE)#remove option from cache
		endif()
	endif()
endforeach()
endfunction(reset_Removed_Examples_Build_Option)

### 
function(will_be_Built result component)
if( (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST" AND NOT BUILD_AND_RUN_TESTS)
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE" AND (NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${component})))
	set(${result} FALSE PARENT_SCOPE)
else()
	set(${result} TRUE PARENT_SCOPE)
endif()
endfunction(will_be_Built)

### 
function(will_be_Installed result component)
if( (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE" AND (NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${component})))
	set(${result} FALSE PARENT_SCOPE)
else()
	set(${result} TRUE PARENT_SCOPE)
endif()
endfunction(will_be_Installed)

### 
function(is_Externally_Usable result component)
if( (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE"))
	set(${result} FALSE PARENT_SCOPE)
else()
	set(${result} TRUE PARENT_SCOPE)
endif()
endfunction(is_Externally_Usable)


### registering the binary name of a component
function(register_Component_Binary c_name)
	get_target_property(BIN_LOC ${c_name}${INSTALL_NAME_SUFFIX} LOCATION)
	get_filename_component(BIN_NAME ${BIN_LOC} NAME)
	set(${PROJECT_NAME}_${c_name}_BINARY_NAME${USE_MODE_SUFFIX} ${BIN_NAME} CACHE INTERNAL "")
endfunction(register_Component_Binary)


#resolving dependencies
function(is_Bin_Component_Exporting_Other_Components RESULT package component mode)
set(${RESULT} FALSE PARENT_SCOPE)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

#scanning external dependencies
if(${package}_${component}_LINKS${VAR_SUFFIX}) #only exported links here
	set(${RESULT} TRUE PARENT_SCOPE)
	return()
endif()

# scanning internal dependencies
if(${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
	foreach(int_dep IN ITEMS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
		if(${package}_${component}_INTERNAL_EXPORT_${int_dep}${VAR_SUFFIX})
			set(${RESULT} TRUE PARENT_SCOPE)
			return()
		endif()
	endforeach()		
endif()

# scanning package dependencies
foreach(dep_pack IN ITEMS ${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
	foreach(ext_dep IN ITEMS ${package}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})
		if(${package}_${component}_EXPORT_${dep_pack}_${ext_dep}${VAR_SUFFIX})
			set(${RESULT} TRUE PARENT_SCOPE)
			return()
		endif()
	endforeach()
endforeach()
endfunction(is_Bin_Component_Exporting_Other_Components)


##############################################################################################################
############### API functions for managing cache variables bound to package dependencies #####################
##############################################################################################################

###
function(add_To_Install_Package_Specification package version version_exact)
list(FIND ${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} ${package} INDEX)
if(INDEX EQUAL -1)#not found
	set(${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX}} ${package} CACHE INTERNAL "")
	if(version AND NOT version STREQUAL "")
		set(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
		endif()
	endif()
else()#package already required as "to install"
	if(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX})
		list(FIND ${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX} ${version} INDEX)
		if(INDEX EQUAL -1)#version not already required
			set(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
			if(version_exact)
				set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
			else()
				set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
			endif()
		elseif(version_exact) #if this version was previously not exact it becomes exact if exact is required
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")		
		endif()
	else()# when there is a problem !! (maybe a warning could be cgood idea)
		set(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
		endif()
	endif()
endif()
endfunction(add_To_Install_Package_Specification)

###
function(reset_To_Install_Packages)
foreach(pack IN ITEMS ${${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX}})
	foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_${pack}_VERSIONS${USE_MODE_SUFFIX}})
		set(${PROJECT_NAME}_TOINSTALL_${pack}_${version}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_TOINSTALL_${pack}_VERSIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} CACHE INTERNAL "")
endfunction(reset_To_Install_Packages)

###
function(need_Install_Packages NEED)
if(${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX})
	set(${NEED} TRUE PARENT_SCOPE)
else()
	set(${NEED} FALSE PARENT_SCOPE)
endif()
endfunction(need_Install_Packages)


###
function(add_To_Install_External_Package_Specification package version exact)
list(FIND ${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX} ${package} INDEX)
if(INDEX EQUAL -1)#not found
	set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX}} ${package} CACHE INTERNAL "")
	if(version AND NOT version STREQUAL "")
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
		endif()
	endif()
else()#package already required as "to install"
	if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX})
		list(FIND ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} ${version} INDEX)
		if(INDEX EQUAL -1)#version not already required
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
			if(version_exact)
				set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
			else()
				set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
			endif()
		elseif(version_exact) #if this version was previously not exact it becomes exact if exact is required
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")		
		endif()
	else()#on a buggy package this may happen (a warning may be a good idea)
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
		endif()
	endif()
endif()
endfunction(add_To_Install_External_Package_Specification)

###
function(reset_To_Install_External_Packages)
foreach(pack IN ITEMS ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX}})
	foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_VERSIONS${USE_MODE_SUFFIX}})
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_${version}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_VERSIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX} CACHE INTERNAL "")
endfunction(reset_To_Install_External_Packages)

###
function(need_Install_External_Packages NEED)
if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX})
	set(${NEED} TRUE PARENT_SCOPE)
else()
	set(${NEED} FALSE PARENT_SCOPE)
endif()
endfunction(need_Install_External_Packages)


##################################################################################
############################## install the dependancies ########################## 
########### functions used to create the use<package><version>.cmake  ############ 
##################################################################################
function(write_Use_File file package build_mode)
set(MODE_SUFFIX "")
if(${build_mode} MATCHES Release) #mode independent info written only once in the release mode
	file(APPEND ${file} "######### declaration of package wiki info ########\n")
	file(APPEND ${file} "set(${package}_WIKI_HOME ${${package}_WIKI_ROOT_PAGE} CACHE INTERNAL \"\")\n")
	
	file(APPEND ${file} "######### declaration of package development info ########\n")	
	get_Repository_Current_Branch(RES_BRANCH ${WORKSPACE_DIR}/packages/${package})
	if(NOT RES_BRANCH OR RES_BRANCH STREQUAL "master")#not on a development branch
		file(APPEND ${file} "set(${package}_DEVELOPMENT_STATE release CACHE INTERNAL \"\")\n")
	else()
		file(APPEND ${file} "set(${package}_DEVELOPMENT_STATE development CACHE INTERNAL \"\")\n")
	endif()
	

	file(APPEND ${file} "######### declaration of package components ########\n")
	file(APPEND ${file} "set(${package}_COMPONENTS ${${package}_COMPONENTS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_COMPONENTS_APPS ${${package}_COMPONENTS_APPS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_COMPONENTS_LIBS ${${package}_COMPONENTS_LIBS} CACHE INTERNAL \"\")\n")
	
	file(APPEND ${file} "####### internal specs of package components #######\n")
	foreach(a_component IN ITEMS ${${package}_COMPONENTS_LIBS})
		file(APPEND ${file} "set(${package}_${a_component}_TYPE ${${package}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
		if(NOT ${package}_${a_component}_TYPE STREQUAL "MODULE")#modules do not have public interfaces
			file(APPEND ${file} "set(${package}_${a_component}_HEADER_DIR_NAME ${${package}_${a_component}_HEADER_DIR_NAME} CACHE INTERNAL \"\")\n")
			file(APPEND ${file} "set(${package}_${a_component}_HEADERS ${${package}_${a_component}_HEADERS} CACHE INTERNAL \"\")\n")
		endif()
	endforeach()
	foreach(a_component IN ITEMS ${${package}_COMPONENTS_APPS})
		file(APPEND ${file} "set(${package}_${a_component}_TYPE ${${package}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
	endforeach()
else()
	set(MODE_SUFFIX _DEBUG)
endif()

#mode dependent info written adequately depending on the mode 
# 0) platforms constraints
file(APPEND ${file} "#### declaration of platform dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(${package}_PLATFORM${MODE_SUFFIX} ${${package}_PLATFORM${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
if(${package}_PLATFORM${MODE_SUFFIX})
	set(platform ${${package}_PLATFORM${MODE_SUFFIX}})
	file(APPEND ${file} "set(${package}_PLATFORM_${platform}_OS${MODE_SUFFIX} ${${package}_PLATFORM_OS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_PLATFORM_${platform}_ARCH${MODE_SUFFIX} ${${package}_PLATFORM_ARCH${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_PLATFORM_${platform}_ABI${MODE_SUFFIX} ${${package}_PLATFORM_ABI${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_PLATFORM_${platform}_CONFIGURATION${MODE_SUFFIX} ${${package}_PLATFORM_CONFIGURATION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
endif()

# 1) external package dependencies
file(APPEND ${file} "#### declaration of external package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

if(${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX})
	foreach(a_ext_dep IN ITEMS ${${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}})
		file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		if(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX})
			file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
		else()
			file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
		endif()
		file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_COMPONENTS${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_COMPONENTS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	endforeach()
endif()

# 2) native package dependencies
file(APPEND ${file} "#### declaration of package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(${package}_DEPENDENCIES${MODE_SUFFIX} ${${package}_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
if(${package}_DEPENDENCIES${MODE_SUFFIX})
	foreach(a_dep IN ITEMS ${${package}_DEPENDENCIES${MODE_SUFFIX}})
		file(APPEND ${file} "set(${package}_DEPENDENCY_${a_dep}_VERSION${MODE_SUFFIX} ${${package}_DEPENDENCY_${a_dep}_VERSION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		if(${package}_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX})
			file(APPEND ${file} "set(${package}_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
		else()
			file(APPEND ${file} "set(${package}_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
		endif()
		file(APPEND ${file} "set(${package}_DEPENDENCY_${a_dep}_COMPONENTS${MODE_SUFFIX} ${${package}_DEPENDENCY_${a_dep}_COMPONENTS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	endforeach()
endif()

# 3) internal+external components specifications
file(APPEND ${file} "#### declaration of components exported flags and binary in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN ITEMS ${${package}_COMPONENTS})
	is_Built_Component(IS_BUILT_COMP ${package} ${a_component})
	is_HeaderFree_Component(IS_HF_COMP ${package} ${a_component})
	if(IS_BUILT_COMP)#if not a pure header library
		file(APPEND ${file} "set(${package}_${a_component}_BINARY_NAME${MODE_SUFFIX} ${${package}_${a_component}_BINARY_NAME${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	endif()
	if(NOT IS_HF_COMP)#it is a library but not a module library
		file(APPEND ${file} "set(${package}_${a_component}_INC_DIRS${MODE_SUFFIX} ${${package}_${a_component}_INC_DIRS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_OPTS${MODE_SUFFIX} ${${package}_${a_component}_OPTS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_DEFS${MODE_SUFFIX} ${${package}_${a_component}_DEFS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_LINKS${MODE_SUFFIX} ${${package}_${a_component}_LINKS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_PRIVATE_LINKS${MODE_SUFFIX} ${${package}_${a_component}_PRIVATE_LINKS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	endif()
	file(APPEND ${file} "set(${package}_${a_component}_RUNTIME_RESOURCES${MODE_SUFFIX} ${${package}_${a_component}_RUNTIME_RESOURCES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

endforeach()

# 4) package internal component dependencies
file(APPEND ${file} "#### declaration package internal component dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN ITEMS ${${package}_COMPONENTS})
	if(${package}_${a_component}_INTERNAL_DEPENDENCIES${MODE_SUFFIX}) # the component has internal dependencies
		file(APPEND ${file} "set(${package}_${a_component}_INTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${package}_${a_component}_INTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		foreach(a_int_dep IN ITEMS ${${package}_${a_component}_INTERNAL_DEPENDENCIES${MODE_SUFFIX}})
			if(${package}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${MODE_SUFFIX})
				file(APPEND ${file} "set(${package}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")				
			else()
				file(APPEND ${file} "set(${package}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")			
			endif()
		endforeach()
	endif()
endforeach()

# 5) component dependencies 
file(APPEND ${file} "#### declaration of component dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN ITEMS ${${package}_COMPONENTS})
	if(${package}_${a_component}_DEPENDENCIES${MODE_SUFFIX}) # the component has package dependencies
		file(APPEND ${file} "set(${package}_${a_component}_DEPENDENCIES${MODE_SUFFIX} ${${package}_${a_component}_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		foreach(dep_package IN ITEMS ${${package}_${a_component}_DEPENDENCIES${MODE_SUFFIX}})
			file(APPEND ${file} "set(${package}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${MODE_SUFFIX} ${${package}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
			foreach(dep_component IN ITEMS ${${package}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${MODE_SUFFIX}})
				if(${package}_${a_component}_EXPORT_${dep_package}_${dep_component})
					file(APPEND ${file} "set(${package}_${a_component}_EXPORT_${dep_package}_${dep_component}${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
				else()
					file(APPEND ${file} "set(${package}_${a_component}_EXPORT_${dep_package}_${dep_component}${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
				endif()
			endforeach()
		endforeach()
	endif()
endforeach()
endfunction(write_Use_File)

function(create_Use_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode 
	set(file ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake)
else()
	set(file ${CMAKE_BINARY_DIR}/share/UseDebugTemp)
endif()

#resetting the file content
file(WRITE ${file} "")
write_Use_File(${file} ${PROJECT_NAME} ${CMAKE_BUILD_TYPE})

#finalizing release mode by agregating info from the debug mode
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode
	if(EXISTS ${CMAKE_BINARY_DIR}/../debug/share/UseDebugTemp)
		file(READ ${CMAKE_BINARY_DIR}/../debug/share/UseDebugTemp DEBUG_CONTENT)
		file(APPEND ${file} "${DEBUG_CONTENT}")
	endif()
endif()
endfunction(create_Use_File)

###############################################################################################
############################## providing info on the package content ########################## 
###############################################################################################

#################### function used to create the Info<package>.cmake  ######################### 
function(generate_Info_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode 
	set(file ${CMAKE_BINARY_DIR}/share/Info${PROJECT_NAME}.cmake)
	file(WRITE ${file} "")#resetting the file content
	file(APPEND ${file} "######### declaration of package components ########\n")
	file(APPEND ${file} "set(${PROJECT_NAME}_COMPONENTS ${${PROJECT_NAME}_COMPONENTS} CACHE INTERNAL \"\")\n")
	foreach(a_component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})		
		file(APPEND ${file} "######### content of package component ${a_component} ########\n")
		file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_TYPE ${${PROJECT_NAME}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
		if(${PROJECT_NAME}_${a_component}_SOURCE_DIR)
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_SOURCE_DIR ${${PROJECT_NAME}_${a_component}_SOURCE_DIR} CACHE INTERNAL \"\")\n")
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_SOURCE_CODE ${${PROJECT_NAME}_${a_component}_SOURCE_CODE} CACHE INTERNAL \"\")\n")
		endif()
		if(${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME)	
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME ${${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME} CACHE INTERNAL \"\")\n")
			file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADERS ${${PROJECT_NAME}_${a_component}_HEADERS} CACHE INTERNAL \"\")\n")

		endif()
	endforeach()
endif()

endfunction(generate_Info_File)


############ function used to create the  Find<package>.cmake file of the package  ###########
function(generate_Find_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	# generating/installing the generic cmake find file for the package 
	configure_file(${WORKSPACE_DIR}/share/patterns/FindPackage.cmake.in ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake @ONLY)
	install(FILES ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake DESTINATION ${WORKSPACE_DIR}/share/cmake/find) #install in the worskpace cmake directory which contains cmake find modules
endif()
endfunction(generate_Find_File)

############ function used to create the Use<package>-<version>.cmake file of the package  ###########
macro(generate_Use_File)
create_Use_File()
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	install(	FILES ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake 
			DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH}
	)
endif()
endmacro(generate_Use_File)


############ function used to create the Dep<package>.cmake file of the package  ###########

###
function(current_Native_Dependencies_For_Package package depfile PACKAGES_ALREADY_MANAGED PACKAGES_NEWLY_MANAGED)
get_Mode_Variables(TARGET_SUFFIX MODE_SUFFIX ${CMAKE_BUILD_TYPE})
#information on package to register
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_VERSION${MODE_SUFFIX} ${${package}_VERSION_STRING} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_ALL_VERSION${MODE_SUFFIX} ${${package}_ALL_REQUIRED_VERSIONS} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_DEPENDENCIES${MODE_SUFFIX} ${${package}_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

#platform info
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_PLATFORM${MODE_SUFFIX} ${${package}_PLATFORM} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_NATIVE_DEPENDENCY_${package}_PLATFORM_CONFIGURATION${MODE_SUFFIX} ${${package}_PLATFORM_${${package}_PLATFORM}_CONFIGURATION} CACHE INTERNAL \"\")\n")

#recursion on external dependencies
set(ALREADY_MANAGED ${PACKAGES_ALREADY_MANAGED} ${package})
set(NEWLY_MANAGED ${package})

foreach(a_used_package IN ITEMS ${${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}})
	list(FIND ALREADY_MANAGED ${a_used_package} INDEX)
	if(INDEX EQUAL -1) #not managed yet
		current_External_Dependencies_For_Package(${a_used_package} ${depfile} NEW_LIST)
		list(APPEND ALREADY_MANAGED ${NEW_LIST})
		list(APPEND NEWLY_MANAGED ${NEW_LIST})
	endif()	
endforeach()

#recursion on dependencies
foreach(a_used_package IN ITEMS ${${package}_DEPENDENCIES${MODE_SUFFIX}})
	list(FIND ALREADY_MANAGED ${a_used_package} INDEX)
	if(INDEX EQUAL -1) #not managed yet
		current_Native_Dependencies_For_Package(${a_used_package} ${depfile} "${ALREADY_MANAGED}" NEW_LIST)
		list(APPEND ALREADY_MANAGED ${NEW_LIST})
		list(APPEND NEWLY_MANAGED ${NEW_LIST})
	endif()
endforeach()

set(${PACKAGES_NEWLY_MANAGED} ${NEWLY_MANAGED} PARENT_SCOPE)
endfunction(current_Native_Dependencies_For_Package)

###
function(current_External_Dependencies_For_Package package depfile PACKAGES_NEWLY_MANAGED)
get_Mode_Variables(TARGET_SUFFIX MODE_SUFFIX ${CMAKE_BUILD_TYPE})
#information on package to register
file(APPEND ${depfile} "set(CURRENT_EXTERNAL_DEPENDENCY_${package}_VERSION${MODE_SUFFIX} ${${package}_VERSION_STRING} CACHE INTERNAL \"\")\n")
file(APPEND ${depfile} "set(CURRENT_EXTERNAL_DEPENDENCY_${package}_ALL_VERSION${MODE_SUFFIX} ${${package}_ALL_REQUIRED_VERSIONS} CACHE INTERNAL \"\")\n")

#no platform info for external libraries

set(NEWLY_MANAGED ${package})
set(${PACKAGES_NEWLY_MANAGED} ${NEWLY_MANAGED} PARENT_SCOPE)
endfunction(current_External_Dependencies_For_Package)


###
macro(generate_Dependencies_File)
get_Mode_Variables(TARGET_SUFFIX MODE_SUFFIX ${CMAKE_BUILD_TYPE})
set(file ${CMAKE_BINARY_DIR}/share/Dep${PROJECT_NAME}.cmake)
file(WRITE ${file} "")
############# FIRST PART : statically declared dependencies ################

# 1) platforms
file(APPEND ${file} "set(TARGET_PLATFORM${MODE_SUFFIX} ${${PROJECT_NAME}_PLATFORM${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_PLATFORM${MODE_SUFFIX})
	file(APPEND ${file} "set(TARGET_PLATFORM_OS${MODE_SUFFIX} ${${PROJECT_NAME}_PLATFORM_OS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(TARGET_PLATFORM_ARCH${MODE_SUFFIX} ${${PROJECT_NAME}_PLATFORM_ARCH${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

	file(APPEND ${file} "set(TARGET_PLATFORM_CONFIGURATION${MODE_SUFFIX} ${${PROJECT_NAME}_PLATFORM_CONFIGURATION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
endif()

# 2) external packages
file(APPEND ${file} "#### declaration of external package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

if(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX})
	foreach(a_ext_dep IN ITEMS ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}})
		file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION${MODE_SUFFIX} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		if(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX})
			file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
		else()
			file(APPEND ${file} "set(TARGET_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
		endif()
	endforeach()
endif()

# 3) native package dependencies
file(APPEND ${file} "#### declaration of package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(TARGET_NATIVE_DEPENDENCIES${MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_DEPENDENCIES${MODE_SUFFIX})
	foreach(a_dep IN ITEMS ${${PROJECT_NAME}_DEPENDENCIES${MODE_SUFFIX}})
		file(APPEND ${file} "set(TARGET_NATIVE_DEPENDENCY_${a_dep}_VERSION${MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCY_${a_dep}_VERSION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		if(${PROJECT_NAME}_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX})
			file(APPEND ${file} "set(TARGET_NATIVE_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
		else()
			file(APPEND ${file} "set(TARGET_NATIVE_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
		endif()
	endforeach()
endif()


set(NEWLY_MANAGED)
set(ALREADY_MANAGED)
############# SECOND PART : dynamically found dependencies according to current workspace content ################

file(APPEND ${file} "set(CURRENT_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES)
	foreach(a_used_package IN ITEMS ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES})
		current_External_Dependencies_For_Package(${a_used_package} ${file} NEWLY_MANAGED)
		list(APPEND ALREADY_MANAGED ${NEWLY_MANAGED})
	endforeach()
endif()

file(APPEND ${file} "set(CURRENT_NATIVE_DEPENDENCIES${MODE_SUFFIX} ${${PROJECT_NAME}_ALL_USED_PACKAGES} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_ALL_USED_PACKAGES)
	foreach(a_used_package IN ITEMS ${${PROJECT_NAME}_ALL_USED_PACKAGES})
		list(FIND ALREADY_MANAGED ${a_used_package} INDEX)
		if(INDEX EQUAL -1) #not managed yet
			current_Native_Dependencies_For_Package(${a_used_package} ${file} "${ALREADY_MANAGED}" NEWLY_MANAGED)
			list(APPEND ALREADY_MANAGED ${NEWLY_MANAGED})
		endif()
	endforeach()
endif()

endmacro(generate_Dependencies_File)


