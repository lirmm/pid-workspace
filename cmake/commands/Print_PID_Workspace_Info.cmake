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

include(${WORKSPACE_DIR}/build/CategoriesInfo.cmake NO_POLICY_SCOPE)

function(matching_terms RESULT all_terms test_str strict)
	set(${RESULT} FALSE PARENT_SCOPE)
	string(TOLOWER "${test_str}" test_str)
	string(REPLACE " " ";" test_str "${test_str}")
	string(REPLACE "\t" ";" test_str "${test_str}")
	string(REPLACE "\n" ";" test_str "${test_str}")
	string(REPLACE "/" ";" test_str "${test_str}")
	string(REPLACE "(" ";" test_str "${test_str}")
	string(REPLACE ")" ";" test_str "${test_str}")
	string(REPLACE "[" ";" test_str "${test_str}")
	string(REPLACE "]" ";" test_str "${test_str}")
	string(REPLACE "." ";" test_str "${test_str}")
	string(REPLACE "!" ";" test_str "${test_str}")
	string(REPLACE "?" ";" test_str "${test_str}")
	list(REMOVE_DUPLICATES test_str)
	string(TOLOWER "${all_terms}" all_terms)
	foreach(term IN LISTS all_terms)
		set(term_found FALSE)
		string(LENGTH "${term}" SIZE)
		if(strict) #match the exact word
			set(to_match "^${term}$")
		else()
			if(SIZE GREATER 4)
				set(to_match "^(.*${term}.*)$")
			else()#with very few characters chances to match
				set(to_match "^(${term}.*)$")
			endif()
		endif()
		foreach(word IN LISTS  test_str)
			if(word MATCHES "${to_match}")
				set(term_found TRUE)
				break()
			endif()
		endforeach()
		if(NOT term_found)
			return()
		endif()
	endforeach()
	set(${RESULT} TRUE PARENT_SCOPE)
endfunction(matching_terms)

#manage arguments if they are passed as environmentvariables (for non UNIX makefile generators usage)
if(NOT TARGET_FRAMEWORK AND DEFINED ENV{framework})
	set(TARGET_FRAMEWORK $ENV{framework} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{framework})
	unset(ENV{framework})
endif()

if(NOT TARGET_ENVIRONMENT AND DEFINED ENV{environment})#to manage the call for non UNIX makefile generators
	set(TARGET_ENVIRONMENT $ENV{environment} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{environment})
	unset(ENV{environment})
endif()

if(NOT TARGET_PACKAGE AND DEFINED ENV{package})#to manage the call for non UNIX makefile generators
	set(TARGET_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{package})
	unset(ENV{package})
endif()

if(NOT TARGET_LICENSE AND DEFINED ENV{license})#to manage the call for non UNIX makefile generators
	set(TARGET_LICENSE $ENV{license} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{license})
	unset(ENV{license})
endif()

if(NOT TARGET_LANGUAGE AND DEFINED ENV{language})#to manage the call for non UNIX makefile generators
	set(TARGET_LANGUAGE $ENV{language} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{language})
	unset(ENV{language})
endif()

if(NOT SEARCH_EXPR AND DEFINED ENV{search})
	set(SEARCH_EXPR $ENV{search} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{search})
	unset(ENV{search})
endif()

if(NOT IS_STRICT AND DEFINED ENV{strict})
	set(IS_STRICT $ENV{strict} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{strict})
	unset(ENV{strict})
endif()

if(SEARCH_EXPR)
	# 0 ) get the list of terms to find
	extract_All_Words("${SEARCH_EXPR}" "," TERMS_TO_FIND)
	list(REMOVE_DUPLICATES TERMS_TO_FIND)

	set(all_refs)
	#1) COLLECT the informations
	get_All_Available_References(REFS "")
	foreach(ref IN LISTS REFS)
		if(ref MATCHES "^ReferFramework(.+)\\.cmake$")
			#DO NTOHING
		elseif(ref MATCHES "^ReferEnvironment(.+)\\.cmake$")
			#DO NTOHING
		elseif(ref MATCHES "^ReferExternal(.+)\\.cmake$")
			include_External_Reference_File(PATH_TO_FILE ${CMAKE_MATCH_1})
			list(APPEND all_refs ${CMAKE_MATCH_1})
		elseif(ref MATCHES "^Refer(.+)\\.cmake$")
			include_Package_Reference_File(PATH_TO_FILE ${CMAKE_MATCH_1})
			list(APPEND all_refs ${CMAKE_MATCH_1})
		endif()
	endforeach()
	# 2) find the expression
	set(matching_refs)
	foreach(ref IN LISTS all_refs)
		#test if name matches
		set(list_of_terms ${ref})
		#test if description match
		if(${ref}_DESCRIPTION)	#test if description match
			list(APPEND list_of_terms ${${ref}_DESCRIPTION})
		endif()
		if(${ref}_CATEGORIES)	#test if categories match
			list(APPEND list_of_terms ${${ref}_CATEGORIES})
		endif()
		matching_terms(RESULT "${TERMS_TO_FIND}" "${list_of_terms}" "${IS_STRICT}")
		if(RESULT)
			list(APPEND matching_refs ${ref})
		endif()
	endforeach()
	if(NOT matching_refs)
		message("[PID] INFO: No package match expression \"${SEARCH_EXPR}\"")
		return()
	endif()
	message("[PID] INFO: packages matching expression \"${SEARCH_EXPR}\":")
	foreach(ref IN LISTS matching_refs)
		fill_String_From_List(RES_STR ${ref}_DESCRIPTION " ")
		message("- ${ref}: ${RES_STR}")
		if(${ref}_CATEGORIES)
			fill_String_From_List(CAT_STR ${ref}_CATEGORIES ", ")
			message("   - categories: ${CAT_STR}")
		endif()
		if(${ref}_PROJECT_PAGE)
			message("   - project: ${${ref}_PROJECT_PAGE}")
		endif()
		if(${ref}_FRAMEWORK)
			include_Framework_Reference_File(PATH_TO_FILE ${${ref}_FRAMEWORK})
			if(PATH_TO_FILE)
				get_Package_Type(${ref} PACK_TYPE)
				if(PACK_TYPE STREQUAL "EXTERNAL")
					message("   - documentation: ${${${ref}_FRAMEWORK}_SITE}/external/${ref}/index.html")
				else()
					message("   - documentation: ${${${ref}_FRAMEWORK}_SITE}/packages/${ref}/index.html")
				endif()
			endif()
		elseif(${ref}_SITE_ROOT_PAGE)
			message("   - documentation: ${${ref}_SITE_ROOT_PAGE}")
		endif()
	endforeach()
	return()
endif()

#perfom the command
if(TARGET_ENVIRONMENT)
	if(TARGET_ENVIRONMENT STREQUAL "all")#listing all environments
		get_All_Available_References(ENV_REFS Environment)
		message("[PID] Available environments:")
		foreach(ref_to_env IN LISTS ENV_REFS)
			string(REGEX REPLACE "ReferEnvironment([^.]+)\\.cmake" "\\1" env_name ${ref_to_env})
			list(APPEND to_list ${env_name})
		endforeach()
		file(GLOB all_env RELATIVE ${WORKSPACE_DIR}/environments/ "${WORKSPACE_DIR}/environments/*")

		list(REMOVE_ITEM all_env ".gitignore")
		list(REMOVE_ITEM all_env "profiles_list.cmake")
		list(APPEND to_list ${all_env})
		if(to_list)
			list(REMOVE_DUPLICATES to_list)
		endif()
		foreach(env IN LISTS to_list)
			message("- ${env}")
		endforeach()
	else() # getting info about a given environment : general description and categories it defines
		include_Environment_Reference_File(PATH_TO_FILE ${TARGET_ENVIRONMENT})
		if(NOT PATH_TO_FILE)
			message(FATAL_ERROR "[PID] ERROR : Environment name ${TARGET_ENVIRONMENT} does not refer to any known environment in installed contribution spaces")
		else()
			print_Environment_Info(${TARGET_ENVIRONMENT})
		endif()
	endif()

elseif(TARGET_FRAMEWORK)
	if(TARGET_FRAMEWORK STREQUAL "all")#listing all frameworks
		if(FRAMEWORKS_CATEGORIES)
			message("FRAMEWORKS: ")
			foreach(framework IN LISTS FRAMEWORKS_CATEGORIES)
				message("- ${framework}")
			endforeach()
		else()
			message("[PID] WARNING : no framework defined in your workspace.")
		endif()
	else() # getting info about a given framework : general description and categories it defines
		include_Framework_Reference_File(PATH_TO_FILE ${TARGET_FRAMEWORK})
		if(NOT PATH_TO_FILE)
			message(FATAL_ERROR "[PID] ERROR : Framework name ${TARGET_FRAMEWORK} does not refer to any known framework in installed contribution spaces")
		else()
			print_Framework_Info(${TARGET_FRAMEWORK})
			print_Framework_Categories(${TARGET_FRAMEWORK}) #getting info about a framework
		endif()
	endif()
elseif(TARGET_PACKAGE)
	if(TARGET_PACKAGE STREQUAL "all")#listing all packages ordered by category
		message("CATEGORIES:") # printing the structure of categories and packages they belong to
		foreach(root_cat IN LISTS ROOT_CATEGORIES)
			print_Category("" ${root_cat} 0)
		endforeach()
	else()#searching for categories a package belongs to
		get_Package_Type(${TARGET_PACKAGE} PACK_TYPE)
		if(PACK_TYPE STREQUAL "UNKNOWN")#if unknown it means there is no reference or source repository
			update_Contribution_Spaces(UPDATED)
	    if(UPDATED)
				get_Package_Type(${TARGET_PACKAGE} PACK_TYPE)#update the package type
			endif()
		endif()
		if(PACK_TYPE STREQUAL "UNKNOWN")#if unknown it means there is no reference or source repository => now an error
			message(FATAL_ERROR "[PID] ERROR : package ${TARGET_PACKAGE} does not refer to any known package in installed contribution spaces")
		elseif(PACK_TYPE STREQUAL "EXTERNAL")
			set(EXTERNAL TRUE)
			include_External_Reference_File(PATH_TO_FILE ${TARGET_PACKAGE})
		elseif(PACK_TYPE STREQUAL "NATIVE")
			set(EXTERNAL FALSE)
			include_Package_Reference_File(PATH_TO_FILE ${TARGET_PACKAGE})
		endif()
		if(PATH_TO_FILE)
			if(EXTERNAL)
				print_External_Package_Info(${TARGET_PACKAGE})
			else()
				print_Native_Package_Info(${TARGET_PACKAGE})
			endif()
			find_In_Categories(${TARGET_PACKAGE}) # printing the categories the package belongs to
		else()
			message("[PID] INFO : package ${TARGET_PACKAGE} is local and no reference file has been provided for it. Please launch the referencing command for this package to get it.")
			return()
		endif()
	endif()

elseif(TARGET_LICENSE)

	if(TARGET_LICENSE STREQUAL "all")#listing all packages ordered by category
		print_Available_Licenses()
	else()
		resolve_License_File(PATH_TO_FILE ${TARGET_LICENSE})
		if(NOT PATH_TO_FILE)
			message(FATAL_ERROR "[PID] ERROR : license name ${TARGET_LICENSE} does not refer to any known license in installed contribution spaces.")
		endif()
		include(${PATH_TO_FILE})
		print_License_Info(${TARGET_LICENSE})
	endif()

elseif(TARGET_LANGUAGE)
	if(TARGET_LANGUAGE STREQUAL "all")#listing all packages ordered by category
		print_Available_Languages()
	else()
		print_Language_Info(${TARGET_LANGUAGE})
	endif()

else() #no argument passed, printing general information about the workspace
	include(${WORKSPACE_DIR}/build/PID_version.cmake)
	message("[PID] INFO : current workspace version is ${PID_WORKSPACE_VERSION}.")
endif()
