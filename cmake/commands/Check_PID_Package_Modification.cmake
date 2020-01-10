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
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration

function(Find_Unique_Elements first_list second_list unique_in_first unique_in_second prefix_for_elements)

set(temp_first_res)

foreach(element IN LISTS first_list)
	list(FIND second_list ${element} FIND_INDEX)
	if(FIND_INDEX EQUAL -1)
		list(APPEND temp_first_res ${prefix_for_elements}/${element})
	else()#this element is not unique in second list
		list(REMOVE_ITEM second_list ${element})
	endif()
endforeach()

set(temp_second_res)

foreach(element IN LISTS second_list)
	list(APPEND temp_second_res ${prefix_for_elements}/${element})
endforeach()

set(${unique_in_second} ${temp_second_res} PARENT_SCOPE)
set(${unique_in_first} ${temp_first_res} PARENT_SCOPE)
endfunction(Find_Unique_Elements)


function(Find_Unique_Auxiliary_Elements list_of_registered list_of_meaningful_path list_of_existing NEW_FILES REMOVED_FILES prefix_for_elements)

set(temp_no_more_existing)
set(temp_newly_existing)

foreach(element IN LISTS list_of_registered)#for each registered source, check if it exists
	list(FIND list_of_existing ${element} FIND_INDEX)
	if(FIND_INDEX EQUAL -1)#not found in existing files
		list(APPEND temp_no_more_existing ${prefix_for_elements}/${element})
	endif()
endforeach()

foreach(element IN LISTS list_of_meaningful_path) #for each monitored path, check if it exists
	if(EXISTS ${prefix_for_elements}/${element} AND IS_DIRECTORY ${prefix_for_elements}/${element})
		#only case to manage is when a file has been added to a monitored FOLDER because files could have been added to this folder and CMake cannot know that
		#monitored files induce (by definition) a modification of CMake file in order to manage them
		foreach(existing IN LISTS list_of_existing)
			get_filename_component(PATH ${prefix_for_elements}/${existing} DIRECTORY)
			get_filename_component(ABS_EXISTING_PATH ${PATH} ABSOLUTE)
			get_filename_component(ABS_MONITORED_PATH ${prefix_for_elements}/${element} ABSOLUTE)
			if(ABS_EXISTING_PATH STREQUAL ABS_MONITORED_PATH)#an existing file is inside the monitored folder
				#OK now test if this existing elemnt belongs to registered files
				list(FIND list_of_registered ${existing} FIND_INDEX)
				if(FIND_INDEX EQUAL -1)#not found in registered files => this is a new element
					list(APPEND temp_newly_existing ${prefix_for_elements}/${existing})
				endif()
			endif()
		endforeach()
	endif()
endforeach()
if(temp_no_more_existing)
	list(REMOVE_DUPLICATES temp_no_more_existing)
endif()
if(temp_newly_existing)
	list(REMOVE_DUPLICATES temp_newly_existing)
endif()
set(${NEW_FILES} ${temp_newly_existing} PARENT_SCOPE)
set(${REMOVED_FILES} ${temp_no_more_existing} PARENT_SCOPE)
endfunction(Find_Unique_Auxiliary_Elements)

#################################################################################################
########### this is the script file to check if a package need to be reconfigured ###############
########### parameters :
########### SOURCE_PACKAGE_CONTENT : the cmake file describing the whole package content
########### PACKAGE_NAME : name of the package to check
########### WORKSPACE_DIR : path to the root of the workspace
#################################################################################################


if(EXISTS ${SOURCE_PACKAGE_CONTENT}) #the package has already been configured
	include(${SOURCE_PACKAGE_CONTENT}) #import source code meta-information (which files for each component)
else()#first time after a cleaning: need to reconfigure
	file(WRITE ${WORKSPACE_DIR}/packages/${PACKAGE_NAME}/build/share/checksources "")
	file(WRITE ${WORKSPACE_DIR}/packages/${PACKAGE_NAME}/build/share/rebuilt "")
	return()
endif()

set(REMOVED_FILES)
set(ADDED_FILES)
set(path_to_package ${WORKSPACE_DIR}/packages/${PACKAGE_NAME})

#testing if some of the included CMakeLists.txt files have been modified
test_Modified_Components(${PACKAGE_NAME} ${CMAKE_MAKE_PROGRAM} MODIFIED)
if(MODIFIED)
	file(WRITE ${WORKSPACE_DIR}/packages/${PACKAGE_NAME}/build/release/share/checksources "")
	return()
endif()
unset(FILE_PACKAGE_ALL_SRC)
unset(FILE_PACKAGE_ALL_APPS)
unset(FILE_PACKAGE_ALL_TESTS)
unset(FILE_PACKAGE_ALL_SCRIPTS)
#testing if source code build tree has been modified (files added/removed)
foreach(component IN LISTS ${PACKAGE_NAME}_COMPONENTS)
	if(${PACKAGE_NAME}_${component}_HEADER_DIR_NAME AND ${PACKAGE_NAME}_${component}_SOURCE_DIR) # this component is a binary library
		set(current_dir ${path_to_package}/include/${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME})

		get_All_Headers_Relative(FILE_PACKAGE_HEADERS ${current_dir} "${${PACKAGE_NAME}_${component}_HEADERS_ADDITIONAL_FILTERS}")
		Find_Unique_Elements(	"${${PACKAGE_NAME}_${component}_HEADERS}"	#registered headers
					"${FILE_PACKAGE_HEADERS}" 			#really existing headers
					TO_REMOVE
					TO_ADD
					${current_dir})

		list(APPEND REMOVED_FILES ${TO_REMOVE})
		list(APPEND ADDED_FILES ${TO_ADD})

		set(current_dir ${path_to_package}/src/${${PACKAGE_NAME}_${component}_SOURCE_DIR})
		get_All_Sources_Relative(FILE_PACKAGE_SOURCES ${current_dir})
		Find_Unique_Elements(	"${${PACKAGE_NAME}_${component}_SOURCE_CODE}"	#registered sources
				"${FILE_PACKAGE_SOURCES}" 			#really existing sources
				TO_REMOVE
				TO_ADD
			${current_dir})

		list(APPEND REMOVED_FILES ${TO_REMOVE})
		list(APPEND ADDED_FILES ${TO_ADD})

		#managing auxiliary sources
		if(NOT DEFINED FILE_PACKAGE_ALL_SRC)#check if sources from src dir have already been found
			set(aux_root_dir ${path_to_package}/src)
				get_All_Sources_Relative(FILE_PACKAGE_ALL_SRC ${aux_root_dir})
		endif()

		Find_Unique_Auxiliary_Elements(
				"${${PACKAGE_NAME}_${component}_AUX_SOURCE_CODE}"	#registered sources
				"${${PACKAGE_NAME}_${component}_AUX_MONITORED_PATH}"	#registered path of these sources
				"${FILE_PACKAGE_ALL_SRC}" 		#really existing sources on filesystem
				TO_ADD
				TO_REMOVE
				${aux_root_dir})

		list(APPEND REMOVED_FILES ${TO_REMOVE})
		list(APPEND ADDED_FILES ${TO_ADD})

	elseif(${PACKAGE_NAME}_${component}_HEADER_DIR_NAME) # this component is a pure header library
		set(current_dir ${path_to_package}/include/${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME})
		get_All_Headers_Relative(FILE_PACKAGE_HEADERS ${current_dir} "${${PACKAGE_NAME}_${component}_HEADERS_ADDITIONAL_FILTERS}")

		Find_Unique_Elements(	"${${PACKAGE_NAME}_${component}_HEADERS}"	#registered headers
					"${FILE_PACKAGE_HEADERS}" 			#really existing headers
					TO_REMOVE
					TO_ADD
					${current_dir})
		list(APPEND REMOVED_FILES ${TO_REMOVE})
		list(APPEND ADDED_FILES ${TO_ADD})

	elseif(${PACKAGE_NAME}_${component}_SOURCE_DIR) # this component is an application or module
		if(${PACKAGE_NAME}_${component}_TYPE STREQUAL "MODULE")
			set(current_dir ${path_to_package}/src/${${PACKAGE_NAME}_${component}_SOURCE_DIR})
			set(aux_root_dir ${path_to_package}/src)
			if(NOT DEFINED FILE_PACKAGE_ALL_SRC)#check if sources from src dir have already been found
				get_All_Sources_Relative(FILE_PACKAGE_ALL_SRC ${aux_root_dir})
			endif()
			set(FILE_PACKAGE_AUX_SOURCES ${FILE_PACKAGE_ALL_SRC})
		elseif(${PACKAGE_NAME}_${component}_TYPE STREQUAL "TEST")
			set(current_dir ${path_to_package}/test/${${PACKAGE_NAME}_${component}_SOURCE_DIR})
			set(aux_root_dir ${path_to_package}/test)
			if(NOT DEFINED FILE_PACKAGE_ALL_TESTS)#check if sources from src dir have already been found
				get_All_Sources_Relative(FILE_PACKAGE_ALL_TESTS ${aux_root_dir})
			endif()
			set(FILE_PACKAGE_AUX_SOURCES ${FILE_PACKAGE_ALL_TESTS})
		elseif(${PACKAGE_NAME}_${component}_TYPE STREQUAL "PYTHON")
			set(current_dir ${path_to_package}/share/script/${${PACKAGE_NAME}_${component}_SOURCE_DIR})
			set(aux_root_dir ${path_to_package}/share/script)
			if(NOT DEFINED FILE_PACKAGE_ALL_SCRIPTS)#check if sources from src dir have already been found
				get_All_Sources_Relative(FILE_PACKAGE_ALL_SCRIPTS ${aux_root_dir})
			endif()
			set(FILE_PACKAGE_AUX_SOURCES ${FILE_PACKAGE_ALL_SCRIPTS})
		else() #otherwise this is an example or standard application
			set(current_dir ${path_to_package}/apps/${${PACKAGE_NAME}_${component}_SOURCE_DIR})
			set(aux_root_dir ${path_to_package}/apps)
			if(NOT DEFINED FILE_PACKAGE_ALL_APPS)#check if sources from src dir have already been found
				get_All_Sources_Relative(FILE_PACKAGE_ALL_APPS ${aux_root_dir})
			endif()
			set(FILE_PACKAGE_AUX_SOURCES ${FILE_PACKAGE_ALL_APPS})
		endif()

		get_All_Sources_Relative(FILE_PACKAGE_SOURCES ${current_dir})
		Find_Unique_Elements(	"${${PACKAGE_NAME}_${component}_SOURCE_CODE}"	#registered sources
					"${FILE_PACKAGE_SOURCES}" 			#really existing sources
					TO_REMOVE
					TO_ADD
					${current_dir})

		list(APPEND REMOVED_FILES ${TO_REMOVE})
		list(APPEND ADDED_FILES ${TO_ADD})

		#managing auxiliary sources
		Find_Unique_Auxiliary_Elements(
				"${${PACKAGE_NAME}_${component}_AUX_SOURCE_CODE}"	#registered sources
				"${${PACKAGE_NAME}_${component}_AUX_MONITORED_PATH}"	#registered path of these sources
				"${FILE_PACKAGE_AUX_SOURCES}" 		#really existing sources on filesystem
				TO_ADD
				TO_REMOVE
				${aux_root_dir})
		list(APPEND REMOVED_FILES ${TO_REMOVE})
		list(APPEND ADDED_FILES ${TO_ADD})
	endif()
endforeach()


if(REMOVED_FILES OR ADDED_FILES)#try make rebuild_cache
	if(REMOVED_FILES)
		list(REMOVE_DUPLICATES REMOVED_FILES)
		message("[PID] INFO : there are files that have been removed from source tree : ${REMOVED_FILES}")
	endif()
	if(ADDED_FILES)
		list(REMOVE_DUPLICATES ADDED_FILES)
		message("[PID] INFO : there are files that have been added to source tree : ${ADDED_FILES}")
	endif()

	file(WRITE ${WORKSPACE_DIR}/packages/${PACKAGE_NAME}/build/share/checksources "")
endif()
