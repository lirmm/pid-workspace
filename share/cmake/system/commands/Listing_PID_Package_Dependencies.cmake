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
math (EXPR index_plus '${index}+1')

while(index GREATER 0)#add as many tabulations as needed to indent correctly
	set(begin_string "${begin_string}	")
	math(EXPR index '${index}-1')
endwhile()

#native dependencies
foreach(dep IN LISTS CURRENT_NATIVE_DEPENDENCY_${package}_DEPENDENCIES${VAR_SUFFIX})
	if(NOT path_to_write STREQUAL "")
		file(APPEND ${path_to_write} "${begin_string}+ ${dep}:  ${CURRENT_NATIVE_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}\n")
	else()
		message("${begin_string}+ ${dep}:  ${CURRENT_NATIVE_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}")
	endif()
	print_Current_Dependencies(${index_plus} ${dep} "${path_to_write}")#recursion of dependencies with management of indent
endforeach()
#external dependencies
foreach(dep IN LISTS CURRENT_NATIVE_DEPENDENCY_${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
	if(NOT path_to_write STREQUAL "")
		file(APPEND ${path_to_write} "${begin_string}- ${dep}: ${CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}\n")
	else()
		message("${begin_string}- ${dep}: ${CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}")
	endif()
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
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)

include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration


if(EXISTS ${CMAKE_BINARY_DIR}/share/Dep${PROJECT_NAME}.cmake)
	include(${CMAKE_BINARY_DIR}/share/Dep${PROJECT_NAME}.cmake)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
	if(${CMAKE_BUILD_TYPE} MATCHES Release)
		if(WRITE_TO_FILE MATCHES true)
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
	elseif(${CMAKE_BUILD_TYPE} MATCHES Debug AND ADDITIONNAL_DEBUG_INFO)
		if(WRITE_TO_FILE MATCHES true)
			set(file_path ${CMAKE_BINARY_DIR}/../release/share/dependencies.txt)
			file(APPEND ${file_path} "\n--------------Debug Mode--------------\n")
		else()
			message("--------------Debug Mode----------------")
		endif()
	endif()


	set(DO_FLAT ${FLAT_PRESENTATION})
	if(DO_FLAT MATCHES true) # presenting as a flat list without hierarchical dependencies
		# CURRENT_NATIVE_DEPENDENCIES and CURRENT_EXTERNAL_DEPENDENCIES are used because these variables collect all direct and undirect dependencies

		#native dependencies
		set(ALL_NATIVE_DEP_STRINGS)
		foreach(dep IN LISTS CURRENT_NATIVE_DEPENDENCIES${VAR_SUFFIX})
			list(APPEND  ALL_NATIVE_DEP_STRINGS "+ ${dep}:  ${CURRENT_NATIVE_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}")
		endforeach()
		if(ALL_NATIVE_DEP_STRINGS)
			list(REMOVE_DUPLICATES  ALL_NATIVE_DEP_STRINGS)
			foreach(dep IN LISTS ALL_NATIVE_DEP_STRINGS)
				if(WRITE_TO_FILE MATCHES true)
					file(APPEND ${file_path} "${dep}\n")
				else()
					message("${dep}")
				endif()
			endforeach()
		endif()
		#external dependencies
		set(ALL_EXTERNAL_DEP_STRINGS)
		foreach(dep IN LISTS CURRENT_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
			list(APPEND  ALL_EXTERNAL_DEP_STRINGS "- ${dep}:  ${CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}")
		endforeach()
		if(ALL_EXTERNAL_DEP_STRINGS)
			list(REMOVE_DUPLICATES  ALL_EXTERNAL_DEP_STRINGS)
			foreach(dep IN LISTS ALL_EXTERNAL_DEP_STRINGS)
				if(WRITE_TO_FILE MATCHES true)
					file(APPEND ${file_path} "${dep}\n")
				else()
					message("${dep}")
				endif()
			endforeach()
		endif()
	else()
		# TARGET_NATIVE_DEPENDENCIES and TARGET_EXTERNAL_DEPENDENCIES are used because these variables only collect direct dependencies, CURRENT_NATIVE_DEPENDENCY_${dep}_VERSION and CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION will be used to get the information at root level
		#native dependencies
		foreach(dep IN LISTS TARGET_NATIVE_DEPENDENCIES${VAR_SUFFIX})
			if(WRITE_TO_FILE MATCHES true)
				file(APPEND ${file_path} "+ ${dep}:  ${CURRENT_NATIVE_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}\n")
				print_Current_Dependencies(1 ${dep} "${file_path}")
			else()
				message("+ ${dep}:  ${CURRENT_NATIVE_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}")
				print_Current_Dependencies(1 ${dep} "")
			endif()
		endforeach()

		#external dependencies (no recursion to manage)
		foreach(dep IN LISTS TARGET_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
			if(WRITE_TO_FILE MATCHES true)
				file(APPEND ${file_path} "- ${dep}: ${CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}\n")
			else()
				message("- ${dep}: ${CURRENT_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}")
			endif()
		endforeach()
	endif()
else()
	message("[PID] Information on dependencies of module ${PROJECT_NAME} cannot be found. Please rerun package configruation (`cmake ..` from build folder).")
endif()
