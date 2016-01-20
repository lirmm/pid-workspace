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


### adding source code of the example components to the API doc
function(add_Example_To_Doc c_name)
	file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/share/doc/examples/)
	file(COPY ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR} DESTINATION ${PROJECT_BINARY_DIR}/share/doc/examples/)
endfunction(add_Example_To_Doc c_name)

### generating API documentation for the package
function(generate_API)

if(${CMAKE_BUILD_TYPE} MATCHES Release) # if in release mode we generate the doc

if(NOT BUILD_API_DOC)
	return()
endif()

if(EXISTS ${PROJECT_SOURCE_DIR}/share/doxygen/img/)
	install(DIRECTORY ${PROJECT_SOURCE_DIR}/share/doxygen/img/ DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH}/doc/)
	file(COPY ${PROJECT_SOURCE_DIR}/share/doxygen/img/ DESTINATION ${PROJECT_BINARY_DIR}/share/doc/)
endif()

#finding doxygen tool and doxygen configuration file 
find_package(Doxygen)
if(NOT DOXYGEN_FOUND)
	message(WARNING "Doxygen not found please install it to generate the API documentation")
	return()
endif(NOT DOXYGEN_FOUND)
find_file(DOXYFILE_IN   "Doxyfile.in"
			PATHS "${CMAKE_SOURCE_DIR}/share/doxygen"
			NO_DEFAULT_PATH
	)
set(DOXYFILE_IN ${DOXYFILE_IN} CACHE INTERNAL "")
if(DOXYFILE_IN-NOTFOUND)
	message(WARNING "Doxyfile not found in the share folder of your package !! Getting the standard doxygen template file from workspace ... ")
	find_file(GENERIC_DOXYFILE_IN   "Doxyfile.in"
					PATHS "${WORKSPACE_DIR}/share/cmake/patterns"
					NO_DEFAULT_PATH
		)
	set(GENERIC_DOXYFILE_IN ${GENERIC_DOXYFILE_IN} CACHE INTERNAL "")
	if(GENERIC_DOXYFILE_IN-NOTFOUND)
		message(WARNING "No Template file found in ${WORKSPACE_DIR}/share/cmake/patterns/, skipping documentation generation !!")		
	else(GENERIC_DOXYFILE_IN-NOTFOUND)
		file(COPY ${WORKSPACE_DIR}/share/cmake/patterns/Doxyfile.in ${CMAKE_SOURCE_DIR}/share/doxygen)
		message(STATUS "Template file found in ${WORKSPACE_DIR}/share/cmake/patterns/ and copied to your package, you can now modify it")		
	endif(GENERIC_DOXYFILE_IN-NOTFOUND)
endif(DOXYFILE_IN-NOTFOUND)

if(DOXYGEN_FOUND AND (NOT DOXYFILE_IN-NOTFOUND OR NOT GENERIC_DOXYFILE_IN-NOTFOUND)) #we are able to generate the doc
	# general variables
	set(DOXYFILE_SOURCE_DIRS "${CMAKE_SOURCE_DIR}/include/")
	set(DOXYFILE_MAIN_PAGE "${CMAKE_SOURCE_DIR}/README.md")
	set(DOXYFILE_PROJECT_NAME ${PROJECT_NAME})
	set(DOXYFILE_PROJECT_VERSION ${${PROJECT_NAME}_VERSION})
	set(DOXYFILE_OUTPUT_DIR ${CMAKE_BINARY_DIR}/share/doc)
	set(DOXYFILE_HTML_DIR html)
	set(DOXYFILE_LATEX_DIR latex)

	### new targets ###
	# creating the specific target to run doxygen
	add_custom_target(doxygen
		${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/share/Doxyfile
		DEPENDS ${CMAKE_BINARY_DIR}/share/Doxyfile
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
		COMMENT "Generating API documentation with Doxygen" VERBATIM
	)

	# target to clean installed doc
	set_property(DIRECTORY
		APPEND PROPERTY
		ADDITIONAL_MAKE_CLEAN_FILES
		"${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_HTML_DIR}")

	# creating the doc target
	get_target_property(DOC_TARGET doc TYPE)
	if(NOT DOC_TARGET)
		add_custom_target(doc)
	endif(NOT DOC_TARGET)

	add_dependencies(doc doxygen)

	### end new targets ###

	### doxyfile configuration ###

	# configuring doxyfile for html generation 
	set(DOXYFILE_GENERATE_HTML "YES")

	# configuring doxyfile to use dot executable if available
	set(DOXYFILE_DOT "NO")
	if(DOXYGEN_DOT_EXECUTABLE)
		set(DOXYFILE_DOT "YES")
	endif()

	# configuring doxyfile for latex generation 
	set(DOXYFILE_PDFLATEX "NO")

	if(BUILD_LATEX_API_DOC)
		# target to clean installed doc
		set_property(DIRECTORY
			APPEND PROPERTY
			ADDITIONAL_MAKE_CLEAN_FILES
			"${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_LATEX_DIR}")
		set(DOXYFILE_GENERATE_LATEX "YES")
		find_package(LATEX)
		find_program(DOXYFILE_MAKE make)
		mark_as_advanced(DOXYFILE_MAKE)
		if(LATEX_COMPILER AND MAKEINDEX_COMPILER AND DOXYFILE_MAKE)
			if(PDFLATEX_COMPILER)
				set(DOXYFILE_PDFLATEX "YES")
			endif(PDFLATEX_COMPILER)

			add_custom_command(TARGET doxygen
				POST_BUILD
				COMMAND "${DOXYFILE_MAKE}"
				COMMENT	"Running LaTeX for Doxygen documentation in ${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_LATEX_DIR}..."
				WORKING_DIRECTORY "${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_LATEX_DIR}")
		else(LATEX_COMPILER AND MAKEINDEX_COMPILER AND DOXYFILE_MAKE)
			set(DOXYGEN_LATEX "NO")
		endif(LATEX_COMPILER AND MAKEINDEX_COMPILER AND DOXYFILE_MAKE)

	else(BUILD_LATEX_API_DOC)
		set(DOXYFILE_GENERATE_LATEX "NO")
	endif(BUILD_LATEX_API_DOC)

	#configuring the Doxyfile.in file to generate a doxygen configuration file
	configure_file(${CMAKE_SOURCE_DIR}/share/doxygen/Doxyfile.in ${CMAKE_BINARY_DIR}/share/Doxyfile @ONLY)
	### end doxyfile configuration ###

	### installing documentation ###
	install(DIRECTORY ${CMAKE_BINARY_DIR}/share/doc DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})
	### end installing documentation ###

endif()
	set(BUILD_API_DOC OFF FORCE)
endif()
endfunction(generate_API)

############ function used to create the license.txt file of the package  ###########
function(generate_License_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	if(	DEFINED ${PROJECT_NAME}_LICENSE 
		AND NOT ${${PROJECT_NAME}_LICENSE} STREQUAL "")
	
		find_file(	LICENSE   
				"License${${PROJECT_NAME}_LICENSE}.cmake"
				PATH "${WORKSPACE_DIR}/share/cmake/system"
				NO_DEFAULT_PATH
			)
		set(LICENSE ${LICENSE} CACHE INTERNAL "")
		
		if(LICENSE_IN-NOTFOUND)
			message(WARNING "license configuration file for ${${PROJECT_NAME}_LICENSE} not found in workspace, license file will not be generated")
		else(LICENSE_IN-NOTFOUND)
			foreach(author IN ITEMS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS})
				generate_Full_Author_String(${author} STRING_TO_APPEND)
				set(${PROJECT_NAME}_AUTHORS_LIST "${${PROJECT_NAME}_AUTHORS_LIST} ${STRING_TO_APPEND}")
			endforeach()
			include(${WORKSPACE_DIR}/share/cmake/licenses/License${${PROJECT_NAME}_LICENSE}.cmake)
			file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
			install(FILES ${CMAKE_SOURCE_DIR}/license.txt DESTINATION ${${PROJECT_NAME}_DEPLOY_PATH})
			file(WRITE ${CMAKE_BINARY_DIR}/share/file_header_comment.txt.in ${LICENSE_HEADER_FILE_DESCRIPTION})
		endif(LICENSE_IN-NOTFOUND)
	endif()
endif()
endfunction(generate_License_File)

############ functions for the management of wikis of packages  ###########
function(wiki_Project_Exists WIKI_EXISTS PATH_TO_WIKI package)
set(SEARCH_PATH ${WORKSPACE_DIR}/wikis/${package}.wiki)
if(EXISTS ${SEARCH_PATH} AND IS_DIRECTORY ${SEARCH_PATH})
	set(${WIKI_EXISTS} TRUE PARENT_SCOPE)
else()
	set(${WIKI_EXISTS} FALSE PARENT_SCOPE)
endif()
set(${PATH_TO_WIKI} ${SEARCH_PATH} PARENT_SCOPE)
endfunction()

function(configure_Wiki_Pages)
## introduction (more detailed description, if any)
generate_Formatted_String("${${PROJECT_NAME}_WIKI_ROOT_PAGE_INTRODUCTION}" RES_INTRO)
if("${RES_INTRO}" STREQUAL "")
	set(WIKI_INTRODUCTION "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided use the short one
else()
	set(WIKI_INTRODUCTION "${RES_INTRO}") #otherwise use detailed one specific for wiki
endif()

## navigation links
if("${${PROJECT_NAME}_WIKI_PARENT_PAGE}" STREQUAL "")
	set(LINK_TO_PARENT_WIKI "")
else()
	set(LINK_TO_PARENT_WIKI "[Back to parent wiki](${${PROJECT_NAME}_WIKI_PARENT_PAGE})")
endif()

# authors
get_Formatted_Package_Contact_String(${PROJECT_NAME} RES_STRING)
set(PACKAGE_CONTACT "${RES_STRING}")
set(PACKAGE_ALL_AUTHORS "") 
foreach(author IN ITEMS "${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS}")
	get_Formatted_Author_String(${author} RES_STRING)
	set(PACKAGE_ALL_AUTHORS "${PACKAGE_ALL_AUTHORS}\n* ${RES_STRING}")
endforeach()

# last version
get_Repository_Version_Tags(AVAILABLE_VERSION_TAGS ${PROJECT_NAME})

if(NOT AVAILABLE_VERSION_TAGS)
	set(PACKAGE_LAST_VERSION_FOR_WIKI "no version released yet")
	set(PACKAGE_LAST_VERSION_WITH_PATCH "1.2.0")
	set(PACKAGE_LAST_VERSION_WITHOUT_PATCH "1.2")
else()
	normalize_Version_Tags(VERSION_NUMBERS "${AVAILABLE_VERSION_TAGS}")
	select_Last_Version(RES_VERSION "${VERSION_NUMBERS}")
	set(PACKAGE_LAST_VERSION_FOR_WIKI "${RES_VERSION}")
	set(PACKAGE_LAST_VERSION_WITH_PATCH "${RES_VERSION}")
	get_Version_String_Numbers(${RES_VERSION} major minor patch)
	set(PACKAGE_LAST_VERSION_WITHOUT_PATCH "${major}.${minor}")
endif()
if(${PROJECT_NAME}_LICENSE)

	set(PACKAGE_LICENSE_FOR_WIKI ${${PROJECT_NAME}_LICENSE})
else()
	set(PACKAGE_LICENSE_FOR_WIKI "No license Defined")
endif()

# categories
if (NOT ${PROJECT_NAME}_CATEGORIES)
	set(PACKAGE_CATEGORIES_LIST "This package belongs to no category.")
else()
	set(PACKAGE_CATEGORIES_LIST "This package belongs to following categories defined in PID workspace:")
	foreach(category IN ITEMS ${${PROJECT_NAME}_CATEGORIES})
		set(PACKAGE_CATEGORIES_LIST "${PACKAGE_CATEGORIES_LIST}\n* ${category}")

	endforeach()
endif()


# additional content
set(PATH_TO_WIKI_ADDITIONAL_CONTENT ${CMAKE_SOURCE_DIR}/share/wiki)
if(NOT EXISTS ${PATH_TO_WIKI_ADDITIONAL_CONTENT}) #if folder does not exist (old package style)
	file(COPY ${WORKSPACE_DIR}/share/patterns/package/share/wiki DESTINATION ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/share)#create the folder
	set(PACKAGE_ADDITIONAL_CONTENT "")
	message(WARNING "[PID system notification] creating missing folder wiki in ${PROJECT_NAME} share folder")
	if(wiki_content_file)#a content file is targetted but cannot exists in the non-existing folder
		message(WARNING "[PID system notification] creating missing wiki content file ${${PROJECT_NAME}_WIKI_ROOT_PAGE_CONTENT} in ${PROJECT_NAME} share/wiki folder. Remember to commit modifications.")
		file(WRITE ${CMAKE_SOURCE_DIR}/share/wiki/${${PROJECT_NAME}_WIKI_ROOT_PAGE_CONTENT} "\n")
	endif()
else() #folder exists 
	set(PATH_TO_WIKI_ADDITIONAL_CONTENT_FILE ${PATH_TO_WIKI_ADDITIONAL_CONTENT}/${${PROJECT_NAME}_WIKI_ROOT_PAGE_CONTENT})
	if(NOT EXISTS ${PATH_TO_WIKI_ADDITIONAL_CONTENT_FILE})#no file with target name => create an empty one
		message(WARNING "[PID system notification] missing wiki content file ${${PROJECT_NAME}_WIKI_ROOT_PAGE_CONTENT} in ${PROJECT_NAME} share/wiki folder. File created automatically. Please input some text in it or remove this file and reference to this file in your call to declare_PID_Wiki.  Remember to commit modifications.")
		file(WRITE ${PATH_TO_WIKI_ADDITIONAL_CONTENT_FILE} "\n")
		set(PACKAGE_ADDITIONAL_CONTENT "")
	else()#Here everything is OK
		file(READ ${PATH_TO_WIKI_ADDITIONAL_CONTENT_FILE} FILE_CONTENT)
		set(PACKAGE_ADDITIONAL_CONTENT "${FILE_CONTENT}")
	endif()

endif()

# package dependencies


# package components


### now configure the home page of the wiki ###
set(PATH_TO_HOMEPAGE_PATTERN ${WORKSPACE_DIR}/share/patterns/home.markdown.in)
configure_file(${PATH_TO_HOMEPAGE_PATTERN} ${CMAKE_BINARY_DIR}/home.markdown @ONLY)#put it in the binary dir for now

endfunction()


