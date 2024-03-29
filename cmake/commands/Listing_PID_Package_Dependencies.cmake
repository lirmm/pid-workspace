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

###
function(print_Current_Dependencies nb_tabs package path_to_write)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
set(begin_string "")
set(index ${nb_tabs})
set(index_plus)
math (EXPR index_plus "${index}+1")

while(index GREATER 0)#add as many tabulations as needed to indent correctly
	set(begin_string "${begin_string}	")
	math(EXPR index "${index}-1")
endwhile()

get_Package_Type(${package} PACK_TYPE)
if(${PACK_TYPE} STREQUAL "NATIVE")
	check_For_Dependencies_Version(unreleased_dependencies ${package})
else()
	set(unreleased_dependencies)
endif()

#native dependencies
foreach(dep IN LISTS CURRENT_NATIVE_DEPENDENCY_${package}_DEPENDENCIES${VAR_SUFFIX})
	set(dep_version ${CURRENT_NATIVE_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}})
	set(unreleased_text)
	list(FIND unreleased_dependencies "${dep}#${dep_version}" dep_index)
	if(dep_index GREATER_EQUAL 0)
		set(unreleased_text " (in development)")
	endif()
	set(expr_to_write "+ ${dep}:  ${dep_version}${unreleased_text}")
	if(NOT path_to_write STREQUAL "")
		file(APPEND ${path_to_write} "${begin_string}${expr_to_write}\n")
	else()
		message("${begin_string}${expr_to_write}")
	endif()
	print_Current_Dependencies(${index_plus} ${dep} "${path_to_write}")#recursion of dependencies with management of indent
endforeach()
#external dependencies
foreach(dep IN LISTS CURRENT_NATIVE_DEPENDENCY_${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
	set(expr_to_write "- ${dep}: ${CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}")
	if(CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION_SYSTEM${VAR_SUFFIX})
		set(expr_to_write "${expr_to_write} (system)")
	endif()
	if(NOT path_to_write STREQUAL "")
		file(APPEND ${path_to_write} "${begin_string}${expr_to_write}\n")
	else()
		message("${begin_string}${expr_to_write}")
	endif()
	print_Current_Dependencies(${index_plus} ${dep} "${path_to_write}")#recursion of dependencies with management of indent
endforeach()
#external dependencies
foreach(dep IN LISTS CURRENT_EXTERNAL_DEPENDENCY_${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
	set(expr_to_write "- ${dep}: ${CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}")
	if(CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION_SYSTEM${VAR_SUFFIX})
		set(expr_to_write "${expr_to_write} (system)")
	endif()
	if(NOT path_to_write STREQUAL "")
		file(APPEND ${path_to_write} "${begin_string}${expr_to_write}\n")
	else()
		message("${begin_string}${expr_to_write}")
	endif()
	print_Current_Dependencies(${index_plus} ${dep} "${path_to_write}")#recursion of dependencies with management of indent
endforeach()
endfunction(print_Current_Dependencies)

###
function(agregate_All_Platform_Configurations RES_CONFIGURATIONS)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
set(all_configs ${TARGET_PLATFORM_CONFIGURATIONS${VAR_SUFFIX}})

foreach(dep IN LISTS CURRENT_NATIVE_DEPENDENCIES${VAR_SUFFIX})
	list(APPEND all_configs ${CURRENT_NATIVE_DEPENDENCY_${dep}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX}})
endforeach()
foreach(dep IN LISTS CURRENT_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
	list(APPEND all_configs ${CURRENT_EXTERNAL_DEPENDENCY_${dep}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX}})
endforeach()
if(all_configs)
	list(REMOVE_DUPLICATES all_configs)
endif()
set(${RES_CONFIGURATIONS} ${all_configs} PARENT_SCOPE)
endfunction(agregate_All_Platform_Configurations)

###################################################################################
######## this is the script file to call to list a package's dependencies #########
###################################################################################

# using systems scripts of the workspace

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
load_Workspace_Info() #loading the current platform configuration


#manage arguments if they are passed as environmentvariables (for non UNIX makefile generators usage)
if(NOT FLAT_PRESENTATION AND DEFINED ENV{flat})
	set(FLAT_PRESENTATION $ENV{flat} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{flat})
	unset(ENV{flat})
endif()

if(NOT WRITE_TO_FILE AND DEFINED ENV{write_file})
	set(WRITE_TO_FILE $ENV{write_file} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{write_file})
	unset(ENV{write_file})
endif()

if(EXISTS ${CMAKE_BINARY_DIR}/share/Dep${PROJECT_NAME}.cmake)
	include(${CMAKE_BINARY_DIR}/share/Dep${PROJECT_NAME}.cmake)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
	if(${CMAKE_BUILD_TYPE} MATCHES Release)
		if(WRITE_TO_FILE STREQUAL "true" OR WRITE_TO_FILE STREQUAL "TRUE" OR WRITE_TO_FILE STREQUAL "ON")
			set(file_path ${CMAKE_BINARY_DIR}/share/dependencies.txt)
			file(WRITE ${file_path} "Dependencies of ${PROJECT_NAME}, version ${PROJECT_VERSION} \n")
			file(APPEND ${file_path} "target platform: ${TARGET_PLATFORM} (type=${TARGET_PLATFORM_TYPE}, arch=${TARGET_PLATFORM_ARCH}, os=${TARGET_PLATFORM_OS}, abi=${TARGET_PLATFORM_ABI})\n")
			agregate_All_Platform_Configurations(ALL_CONFIGURATIONS)
			foreach(config IN LISTS ALL_CONFIGURATIONS)
				file(APPEND ${file_path} "* ${config}\n")
			endforeach()
			file(APPEND ${file_path} "\n")
			file(APPEND ${file_path} "--------------Release Mode--------------\n")
		else()
			message("Dependencies of ${PROJECT_NAME}, version ${PROJECT_VERSION}")
			message("target platform: ${TARGET_PLATFORM} (type=${TARGET_PLATFORM_TYPE}, arch=${TARGET_PLATFORM_ARCH}, os=${TARGET_PLATFORM_OS}, abi=${TARGET_PLATFORM_ABI})")
			agregate_All_Platform_Configurations(ALL_CONFIGURATIONS)
			foreach(config IN LISTS ALL_CONFIGURATIONS)
				message("* ${config}")
			endforeach()
			message("--------------Release Mode--------------")
		endif()
	elseif(CMAKE_BUILD_TYPE MATCHES "Debug" AND ADDITIONAL_DEBUG_INFO)
		if(WRITE_TO_FILE STREQUAL "true" OR WRITE_TO_FILE STREQUAL "TRUE" OR WRITE_TO_FILE STREQUAL "ON")
			set(file_path ${CMAKE_BINARY_DIR}/../release/share/dependencies.txt)
			file(APPEND ${file_path} "\n--------------Debug Mode--------------\n")
		else()
			message("--------------Debug Mode----------------")
		endif()
	endif()

	check_For_Dependencies_Version(unreleased_dependencies ${PROJECT_NAME})
	set(DO_FLAT ${FLAT_PRESENTATION})
	if(DO_FLAT MATCHES true) # presenting as a flat list without hierarchical dependencies
		# CURRENT_NATIVE_DEPENDENCIES and CURRENT_EXTERNAL_DEPENDENCIES are used because these variables collect all direct and undirect dependencies

		# CURRENT_NATIVE_DEPENDENCIES${VAR_SUFFIX} and CURRENT_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} are overriden by check_For_Dependencies_Version so we need to save it before the call
		set(native_deps ${CURRENT_NATIVE_DEPENDENCIES${VAR_SUFFIX}})
		set(ext_deps ${CURRENT_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}})

		foreach(dep IN LISTS ${native_deps})
			check_For_Dependencies_Version(dep_unreleased_dependencies ${dep})
			list(APPEND unreleased_dependencies ${dep_unreleased_dependencies})
		endforeach()

		set(CURRENT_NATIVE_DEPENDENCIES${VAR_SUFFIX} ${native_deps})
		set(CURRENT_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} ${ext_deps})

		#native dependencies
		set(ALL_NATIVE_DEP_STRINGS)
		foreach(dep IN LISTS CURRENT_NATIVE_DEPENDENCIES${VAR_SUFFIX})
			set(dep_version ${CURRENT_NATIVE_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}})
			set(unreleased_text)
			list(FIND unreleased_dependencies "${dep}#${dep_version}" dep_index)
			if(dep_index GREATER_EQUAL 0)
				set(unreleased_text " (in development)")
			endif()
			list(APPEND  ALL_NATIVE_DEP_STRINGS "+ ${dep}:  ${dep_version}${unreleased_text}")
		endforeach()
		if(ALL_NATIVE_DEP_STRINGS)
			list(REMOVE_DUPLICATES  ALL_NATIVE_DEP_STRINGS)
			foreach(dep IN LISTS ALL_NATIVE_DEP_STRINGS)
				if(WRITE_TO_FILE STREQUAL "true" OR WRITE_TO_FILE STREQUAL "TRUE" OR WRITE_TO_FILE STREQUAL "ON")
					file(APPEND ${file_path} "${dep}\n")
				else()
					message("${dep}")
				endif()
			endforeach()
		endif()
		#external dependencies
		set(ALL_EXTERNAL_DEP_STRINGS)

		foreach(dep IN LISTS CURRENT_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
			if(CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION_SYSTEM${VAR_SUFFIX})
				list(APPEND  ALL_EXTERNAL_DEP_STRINGS "- ${dep}:  ${CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}} (system)")
			else()
				list(APPEND  ALL_EXTERNAL_DEP_STRINGS "- ${dep}:  ${CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}")
			endif()
		endforeach()
		if(ALL_EXTERNAL_DEP_STRINGS)
			list(REMOVE_DUPLICATES  ALL_EXTERNAL_DEP_STRINGS)
			foreach(dep IN LISTS ALL_EXTERNAL_DEP_STRINGS)
				if(WRITE_TO_FILE STREQUAL "true" OR WRITE_TO_FILE STREQUAL "TRUE" OR WRITE_TO_FILE STREQUAL "ON")
					file(APPEND ${file_path} "${dep}\n")
				else()
					message("${dep}")
				endif()
			endforeach()
		endif()
	else()
		# TARGET_NATIVE_DEPENDENCIES and TARGET_EXTERNAL_DEPENDENCIES are used because these variables only collect direct dependencies, CURRENT_NATIVE_DEPENDENCY_${dep}_VERSION and CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION will be used to get the information at root level
		#native dependencies
		# These variables will be overwritten inside print_Current_Dependencies by calls to check_For_Dependencies_Version so we need to save them
		set(native_deps ${TARGET_NATIVE_DEPENDENCIES${VAR_SUFFIX}})
		set(ext_deps ${TARGET_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}})

		foreach(dep IN LISTS native_deps)
			set(dep_version ${CURRENT_NATIVE_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}})
			set(unreleased_text)
			list(FIND unreleased_dependencies "${dep}#${dep_version}" dep_index)
			if(dep_index GREATER_EQUAL 0)
				set(unreleased_text " (in development)")
			endif()
			set(expr_to_write "+ ${dep}:  ${dep_version}${unreleased_text}")
			if(WRITE_TO_FILE STREQUAL "true" OR WRITE_TO_FILE STREQUAL "TRUE" OR WRITE_TO_FILE STREQUAL "ON")
				file(APPEND ${file_path} "${expr_to_write}\n")
				print_Current_Dependencies(1 ${dep} "${file_path}")
			else()
				message("${expr_to_write}")
				print_Current_Dependencies(1 ${dep} "")
			endif()
		endforeach()

		set(TARGET_NATIVE_DEPENDENCIES${VAR_SUFFIX} ${native_deps})
		set(TARGET_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} ${ext_deps})

		#external dependencies
		foreach(dep IN LISTS ext_deps)
			set(expr_to_write "- ${dep}:  ${CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}")
			if(CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION_SYSTEM${VAR_SUFFIX})
				set(expr_to_write "${expr_to_write} (system)")
			endif()
			if(WRITE_TO_FILE STREQUAL "true" OR WRITE_TO_FILE STREQUAL "TRUE" OR WRITE_TO_FILE STREQUAL "ON")
				file(APPEND ${file_path} "${expr_to_write}\n")
				print_Current_Dependencies(1 ${dep} "${file_path}")
			else()
				message("${expr_to_write}")
				print_Current_Dependencies(1 ${dep} "")
			endif()
		endforeach()
	endif()
else()
	message("[PID] Information on dependencies of module ${PROJECT_NAME} cannot be found. Please rerun package configruation (`cmake ..` from build folder).")
endif()
