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


function(Find_Unique_Elements first_list second_list unique_in_first unique_in_second prefix_for_elements)

set(temp_first_res)

foreach(element IN ITEMS ${first_list})
	list(FIND second_list ${element} FIND_INDEX)
	if(FIND_INDEX EQUAL -1)
		list(APPEND temp_first_res ${prefix_for_elements}/${element})
	else()#this element is not unique in second list
		list(REMOVE_ITEM second_list ${element})
	endif()
endforeach()

set(temp_second_res)

foreach(element IN ITEMS ${second_list})
	list(APPEND temp_second_res ${prefix_for_elements}/${element})
endforeach()

set(${unique_in_second} ${temp_second_res} PARENT_SCOPE)
set(${unique_in_first} ${temp_first_res} PARENT_SCOPE)
endfunction(Find_Unique_Elements)

#################################################################################################
########### this is the script file to check if a package need to be reconfigured ###############
########### parameters :
########### SOURCE_PACKAGE_CONTENT : the cmake file describing the whole package content
########### PACKAGE_NAME : name of the package to check
########### WORKSPACE_DIR : path to the root of the workspace
########### USE_MAKE_TOOL : name or path of the make tool
#################################################################################################
include(${WORKSPACE_DIR}/share/cmake/system/PID_Utils_Functions.cmake NO_POLICY_SCOPE)
include(${WORKSPACE_DIR}/share/cmake/system/Package_Internal_Policies.cmake NO_POLICY_SCOPE)

if(EXISTS ${SOURCE_PACKAGE_CONTENT}) #the package has already been configured
	include(${SOURCE_PACKAGE_CONTENT}) #import source code meta-information (which files for each component) 
else()
	file(WRITE ${WORKSPACE_DIR}/packages/${PACKAGE_NAME}/build/release/share/checksources "")
	file(WRITE ${WORKSPACE_DIR}/packages/${PACKAGE_NAME}/build/release/share/rebuilt "")
	return()
endif()

set(REMOVED_FILES)
set(ADDED_FILES)
set(path_to_package ${WORKSPACE_DIR}/packages/${PACKAGE_NAME})

#testing if some of the included CMakeLists.txt files have been modified
test_Modified_Components(${PACKAGE_NAME} ${USE_MAKE_TOOL} MODIFIED)
if(MODIFIED)
	file(WRITE ${WORKSPACE_DIR}/packages/${PACKAGE_NAME}/build/release/share/checksources "")
	return()
endif()

#testing if source code build tree has been modified (files added/removed)
foreach(component IN ITEMS ${${PACKAGE_NAME}_COMPONENTS})
	if(${PACKAGE_NAME}_${component}_HEADER_DIR_NAME AND ${PACKAGE_NAME}_${component}_SOURCE_DIR) # this component is a binary library
		set(current_dir ${path_to_package}/include/${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME})
		file(	GLOB_RECURSE FILE_PACKAGE_HEADERS 
			RELATIVE ${current_dir} 
			"${current_dir}/*.h"
			"${current_dir}/*.hh"
			"${current_dir}/*.hpp"
			"${current_dir}/*.hxx")
		Find_Unique_Elements(	"${${PACKAGE_NAME}_${component}_HEADERS}"	#registered headers
					"${FILE_PACKAGE_HEADERS}" 			#really existing headers	
					TO_REMOVE 						
					TO_ADD
					${current_dir})
		
		list(APPEND REMOVED_FILES ${TO_REMOVE})
		list(APPEND ADDED_FILES ${TO_ADD})

		set(current_dir ${path_to_package}/src/${${PACKAGE_NAME}_${component}_SOURCE_DIR})
		file(	GLOB_RECURSE FILE_PACKAGE_SOURCES 
			RELATIVE ${current_dir} 
			"${current_dir}/*.h"
			"${current_dir}/*.hh"
			"${current_dir}/*.hpp"
			"${current_dir}/*.hxx"
			"${current_dir}/*.c"
			"${current_dir}/*.cc"
			"${current_dir}/*.cpp"
			"${current_dir}/*.cxx")
		Find_Unique_Elements(	"${${PACKAGE_NAME}_${component}_SOURCE_CODE}"	#registered sources
					"${FILE_PACKAGE_SOURCES}" 			#really existing sources	
					TO_REMOVE 						
					TO_ADD
					${current_dir})
		
		list(APPEND REMOVED_FILES ${TO_REMOVE})
		list(APPEND ADDED_FILES ${TO_ADD})

	elseif(${PACKAGE_NAME}_${component}_HEADER_DIR_NAME) # this component is a pure header library
		set(current_dir ${path_to_package}/include/${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME})
		file(	GLOB_RECURSE FILE_PACKAGE_HEADERS 
			RELATIVE ${current_dir} 
			"${current_dir}/*.h"
			"${current_dir}/*.hh"
			"${current_dir}/*.hpp"
			"${current_dir}/*.hxx")
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
		elseif(${PACKAGE_NAME}_${component}_TYPE STREQUAL "TEST")
			set(current_dir ${path_to_package}/test/${${PACKAGE_NAME}_${component}_SOURCE_DIR})
		else() #otherwise this is an example or standard application
			set(current_dir ${path_to_package}/apps/${${PACKAGE_NAME}_${component}_SOURCE_DIR})
		endif()
		
		file(	GLOB_RECURSE FILE_PACKAGE_SOURCES 
			RELATIVE ${current_dir} 
			"${current_dir}/*.h"
			"${current_dir}/*.hh"
			"${current_dir}/*.hpp"
			"${current_dir}/*.hxx"
			"${current_dir}/*.c"
			"${current_dir}/*.cc"
			"${current_dir}/*.cpp"
			"${current_dir}/*.cxx")
		Find_Unique_Elements(	"${${PACKAGE_NAME}_${component}_SOURCE_CODE}"	#registered sources
					"${FILE_PACKAGE_SOURCES}" 			#really existing sources	
					TO_REMOVE 						
					TO_ADD
					${current_dir})
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
	
	file(WRITE ${WORKSPACE_DIR}/packages/${PACKAGE_NAME}/build/release/share/checksources "")
endif()


