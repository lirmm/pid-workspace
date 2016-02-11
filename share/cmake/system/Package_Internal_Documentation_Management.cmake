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
	message("[PID] WARNING : Doxygen not found please install it to generate the API documentation")
	return()
endif(NOT DOXYGEN_FOUND)

find_file(DOXYFILE_IN   "Doxyfile.in"
			PATHS "${CMAKE_SOURCE_DIR}/share/doxygen"
			NO_DEFAULT_PATH
	)

set(DOXYFILE_PATH)
if(DOXYFILE_IN MATCHES DOXYFILE_IN-NOTFOUND)
	find_file(GENERIC_DOXYFILE_IN   "Doxyfile.in"
					PATHS "${WORKSPACE_DIR}/share/patterns"
					NO_DEFAULT_PATH
		)
	if(GENERIC_DOXYFILE_IN MATCHES GENERIC_DOXYFILE_IN-NOTFOUND)
		message("[PID] INFO : no doxygen template file found ... skipping documentation generation !!")
	else()
		set(DOXYFILE_PATH ${GENERIC_DOXYFILE_IN})
	endif()
	unset(GENERIC_DOXYFILE_IN CACHE)
else()
	set(DOXYFILE_PATH ${DOXYFILE_IN})
endif()
unset(DOXYFILE_IN CACHE)

if(DOXYGEN_FOUND AND DOXYFILE_PATH) #we are able to generate the doc
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

	else()
		set(DOXYFILE_GENERATE_LATEX "NO")
	endif()

	#configuring the Doxyfile.in file to generate a doxygen configuration file
	configure_file(${DOXYFILE_PATH} ${CMAKE_BINARY_DIR}/share/Doxyfile @ONLY)
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
			message("[PID] WARNING : license configuration file for ${${PROJECT_NAME}_LICENSE} not found in workspace, license file will not be generated")
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


############ function used to create the README.md file of the package  ###########
function(generate_Readme_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	set(README_CONFIG_FILE ${WORKSPACE_DIR}/share/patterns/README.md.in)
	## introduction (more detailed description, if any)
	if(NOT ${PROJECT_NAME}_WIKI_ADDRESS)#no wiki description has been provided
		# intro		
		set(README_OVERVIEW "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided by wiki use the short one
		# no reference to wiki page
		set(PACKAGE_WIKI_REF_IN_README "")

		# no parent framework
		set(PACKAGE_FRAMEWORK_IN_README "")

		# simplified install section
		set(INSTALL_USE_IN_README "The procedures for installing the ${PROJECT_NAME} package and for using its components is based on the [PID](https://gite.lirmm.fr/pid/pid-workspace/wikis/home) build and deployment system called PID. Just follow and read the links to understand how to install, use and call its API and/or applications.")
	else()	
		# intro
		generate_Formatted_String("${${PROJECT_NAME}_WIKI_ROOT_PAGE_INTRODUCTION}" RES_INTRO)
		if("${RES_INTRO}" STREQUAL "")
			set(README_OVERVIEW "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided by wiki description use the short one
		else()
			set(README_OVERVIEW "${RES_INTRO}") #otherwise use detailed one specific for wiki
		endif()
		
		# install procedure
		set(INSTALL_USE_IN_README "The procedures for installing the ${PROJECT_NAME} package and for using its components is available in this [wiki][package_wiki]. It is based on a CMake based build and deployment system called PID. Just follow and read the links to understand how to install, use and call its API and/or applications.")

		# reference to wiki page
		set(PACKAGE_WIKI_REF_IN_README "[package_wiki]: ${${PROJECT_NAME}_WIKI_ROOT_PAGE} \"${PROJECT_NAME} package\"
")
		# framework parent page
		if(${PROJECT_NAME}_WIKI_FRAMEWORK)
			if(${PROJECT_NAME}_WIKI_PARENT_PAGE)
				set(PACKAGE_FRAMEWORK_IN_README "${PROJECT_NAME} package is part of a more global framework called ${${PROJECT_NAME}_WIKI_FRAMEWORK}. Please have a look at [${${PROJECT_NAME}_WIKI_FRAMEWORK} wiki](${${PROJECT_NAME}_WIKI_PARENT_PAGE}) to get more information.")
			else()
				set(PACKAGE_FRAMEWORK_IN_README "${PROJECT_NAME} package is part of a more global framework called ${${PROJECT_NAME}_WIKI_FRAMEWORK}. No information where to find information about the ${${PROJECT_NAME}_WIKI_FRAMEWORK} framework is given by the project.")
			endif()
		else()
			set(PACKAGE_FRAMEWORK_IN_README "")
		endif()
	endif()
	
	if(${PROJECT_NAME}_LICENSE)
		set(PACKAGE_LICENSE_FOR_README "The license that appies to the whole package content is **${${PROJECT_NAME}_LICENSE}**. For more information about license please read the [wiki][package_wiki] of this package.")
	else()
		set(PACKAGE_LICENSE_FOR_README "The package has no license defined yet.")
	endif()

	
	set(README_AUTHORS_LIST "")	
	foreach(author IN ITEMS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS})
		generate_Full_Author_String(${author} STRING_TO_APPEND)
		set(README_AUTHORS_LIST "${README_AUTHORS_LIST}\n+ ${STRING_TO_APPEND}")
	endforeach()
	
	get_Formatted_Package_Contact_String(${PROJECT_NAME} RES_STRING)
	set(README_CONTACT_AUTHOR "${RES_STRING}")
	if(NOT ${PROJECT_NAME}_WIKI_ADDRESS)
		
	else()
		set(PACKAGE_WIKI_REF )
	endif()
	configure_file(${README_CONFIG_FILE} ${CMAKE_SOURCE_DIR}/README.md @ONLY)#put it in the source dir
endif()
endfunction(generate_Readme_File)


############ functions for the management of wikis of packages  ###########

function(configure_Wiki_Pages)
if(NOT ${PROJECT_NAME}_WIKI_ADDRESS) #no wiki definition simply exit
	return()
endif()
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
	if(${PROJECT_NAME}_WIKI_FRAMEWORK)
		set(LINK_TO_PARENT_WIKI "[Back to ${${PROJECT_NAME}_WIKI_FRAMEWORK} wiki](${${PROJECT_NAME}_WIKI_PARENT_PAGE})")
	else()	
		set(LINK_TO_PARENT_WIKI "[Back to parent wiki](${${PROJECT_NAME}_WIKI_PARENT_PAGE})")
	endif()
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
	message("[PID] WARNING : creating missing folder wiki in ${PROJECT_NAME} share folder")
	if(wiki_content_file)#a content file is targetted but cannot exists in the non-existing folder
		message("[PID] WARNING : creating missing wiki content file ${${PROJECT_NAME}_WIKI_ROOT_PAGE_CONTENT} in ${PROJECT_NAME} share/wiki folder. Remember to commit modifications.")
		file(WRITE ${CMAKE_SOURCE_DIR}/share/wiki/${${PROJECT_NAME}_WIKI_ROOT_PAGE_CONTENT} "\n")
	endif()
else() #folder exists 
	set(PATH_TO_WIKI_ADDITIONAL_CONTENT_FILE ${PATH_TO_WIKI_ADDITIONAL_CONTENT}/${${PROJECT_NAME}_WIKI_ROOT_PAGE_CONTENT})
	if(NOT EXISTS ${PATH_TO_WIKI_ADDITIONAL_CONTENT_FILE})#no file with target name => create an empty one
		message("[PID] WARNING  : missing wiki content file ${${PROJECT_NAME}_WIKI_ROOT_PAGE_CONTENT} in ${PROJECT_NAME} share/wiki folder. File created automatically. Please input some text in it or remove this file and reference to this file in your call to declare_PID_Wiki.  Remember to commit modifications.")
		file(WRITE ${PATH_TO_WIKI_ADDITIONAL_CONTENT_FILE} "\n")
		set(PACKAGE_ADDITIONAL_CONTENT "")
	else()#Here everything is OK
		file(READ ${PATH_TO_WIKI_ADDITIONAL_CONTENT_FILE} FILE_CONTENT)
		set(PACKAGE_ADDITIONAL_CONTENT "${FILE_CONTENT}")
	endif()

endif()

# platform configuration
set(PACKAGE_PLATFORM_CONFIGURATION "")
if(NOT ${PROJECT_NAME}_AVAILABLE_PLATFORMS) # no platform description => implictly there is no spaeicifc platform configruation 
	set(PACKAGE_PLATFORM_CONFIGURATION "This package requires no specific configuration for the target platform.\n")
else()
	set(PACKAGE_PLATFORM_CONFIGURATION "Here are the possible platform configuration for this package:\n")
	foreach(platform IN ITEMS ${${PROJECT_NAME}_AVAILABLE_PLATFORMS})# we take nly dependencies of the release version
		generate_Platform_Wiki(${platform} RES_CONTENT_PLATFORM)
		set(PACKAGE_PLATFORM_CONFIGURATION "${PACKAGE_PLATFORM_CONFIGURATION}\n${RES_CONTENT_PLATFORM}")
	endforeach()
endif()

# package dependencies
set(EXTERNAL_WIKI_SECTION "## External\n")
set(NATIVE_WIKI_SECTION "## Native\n")
set(PACKAGE_DEPENDENCIES_DESCRIPTION "")

if(NOT ${PROJECT_NAME}_DEPENDENCIES)
	if(NOT ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES)
		set(PACKAGE_DEPENDENCIES_DESCRIPTION "This package has no dependency.\n")
		set(EXTERNAL_WIKI_SECTION "")
	endif()
	set(NATIVE_WIKI_SECTION "")
else()
	if(NOT ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES)
		set(EXTERNAL_WIKI_SECTION "")
	endif()
endif()

if("${PACKAGE_DEPENDENCIES_DESCRIPTION}" STREQUAL "")
	foreach(dep_package IN ITEMS ${${PROJECT_NAME}_DEPENDENCIES})# we take nly dependencies of the release version
		generate_Dependency_Wiki(${dep_package} RES_CONTENT_NATIVE)
		set(NATIVE_WIKI_SECTION "${NATIVE_WIKI_SECTION}\n${RES_CONTENT_NATIVE}")
	endforeach()

	foreach(dep_package IN ITEMS ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES})# we take nly dependencies of the release version
		generate_External_Dependency_Wiki(${dep_package} RES_CONTENT_EXTERNAL)
		set(EXTERNAL_WIKI_SECTION "${EXTERNAL_WIKI_SECTION}\n${RES_CONTENT_EXTERNAL}")
	endforeach()

	set(PACKAGE_DEPENDENCIES_DESCRIPTION "${EXTERNAL_WIKI_SECTION}\n\n${NATIVE_WIKI_SECTION}")
endif()

# package components
set(PACKAGE_COMPONENTS_DESCRIPTION "")
if(${PROJECT_NAME}_COMPONENTS) #if there are components
foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	generate_Component_Wiki(${component} RES_CONTENT_COMP)
	set(PACKAGE_COMPONENTS_DESCRIPTION "${PACKAGE_COMPONENTS_DESCRIPTION}\n${RES_CONTENT_COMP}")
endforeach()
endif()

### now configure the home page of the wiki ###
set(PATH_TO_HOMEPAGE_PATTERN ${WORKSPACE_DIR}/share/patterns/home.markdown.in)
configure_file(${PATH_TO_HOMEPAGE_PATTERN} ${CMAKE_BINARY_DIR}/home.markdown @ONLY)#put it in the binary dir for now

endfunction(configure_Wiki_Pages)

###
function(generate_Platform_Wiki platform RES_CONTENT_PLATFORM)
set(CONTENT "## ${platform}\n+ OS type: ${${PROJECT_NAME}_AVAILABLE_PLATFORM_${platform}_OS}\n+ architecture: ${${PROJECT_NAME}_AVAILABLE_PLATFORM_${platform}_ARCH} bit\n")

if(${PROJECT_NAME}_AVAILABLE_PLATFORM_${platform}_CONFIGURATION)
	foreach(config IN ITEMS ${${PROJECT_NAME}_AVAILABLE_PLATFORM_${platform}_CONFIGURATION})
		set(CONTENT "${CONTENT}+ installed software: ${config}")
	endforeach()
else()
	set(CONTENT "${CONTENT}+ no specific installed software required.")
endif()
set(CONTENT "${CONTENT}\n")
set(${RES_CONTENT_PLATFORM} ${CONTENT} PARENT_SCOPE) 
endfunction(generate_Platform_Wiki)

###
function(generate_Dependency_Wiki dependency RES_CONTENT)

if(${dependency}_WIKI_HOME)
	set(RES "+ [${dependency}](${${dependency}_WIKI_HOME})") #creating a link to the package wiki
else()
	set(RES "+ ${dependency}")
endif()
if(${PROJECT_NAME}_DEPENDENCY_${dependency}_VERSION)
	if(${PROJECT_NAME}_DEPENDENCY_${dependency}_${${PROJECT_NAME}_DEPENDENCY_${dependency}_VERSION}_EXACT)
		set(RES "${RES}: exact version ${${PROJECT_NAME}_DEPENDENCY_${dependency}_VERSION} required.")
	else()
		set(RES "${RES}: version ${${PROJECT_NAME}_DEPENDENCY_${dependency}_VERSION} or compatible.")
	endif()
else()
	set(RES "${RES}: last version available.")
endif()
set(${RES_CONTENT} ${RES} PARENT_SCOPE)
endfunction(generate_Dependency_Wiki)


function(generate_External_Dependency_Wiki dependency RES_CONTENT)
set(RES "+ ${dependency}")
if(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dependency}_VERSION)
	if(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dependency}_${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dependency}_VERSION}_EXACT)
		set(RES "${RES}: exact version ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dependency}_VERSION} required.")
	else()
		set(RES "${RES}: version ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dependency}_VERSION} or compatible.")
	endif()
else()
	set(RES "${RES}: any version available (dangerous).")
endif()
set(${RES_CONTENT} ${RES} PARENT_SCOPE)
endfunction(generate_External_Dependency_Wiki)


function(generate_Component_Wiki component RES_CONTENT)
is_Externally_Usable(IS_EXT_USABLE ${component})
if(NOT IS_EXT_USABLE)#component cannot be used from outside package => no need to document it
	set(${RES_CONTENT} "" PARENT_SCOPE)
	return()
endif()


set(RES "## ${component}\n") # adding a section fo this component

#adding a first line for explaining the type of the component
if(${${PROJECT_NAME}_${component}_TYPE} STREQUAL "HEADER")
	set(RES "${RES}This is a **pure header library** (no binary).\n")
elseif(${${PROJECT_NAME}_${component}_TYPE} STREQUAL "STATIC")
	set(RES "${RES}This is a **static library** (set of header files and an archive of binary objects).\n")
elseif(${${PROJECT_NAME}_${component}_TYPE} STREQUAL "SHARED")
	set(RES "${RES}This is a **shared library** (set of header files and a shared binary object).\n")
elseif(${${PROJECT_NAME}_${component}_TYPE} STREQUAL "MODULE")
	set(RES "${RES}This is a **module library** (no header files but a shared binary object). Designed to be dynamically loaded by an application or library.\n")
elseif(${${PROJECT_NAME}_${component}_TYPE} STREQUAL "APP")
	set(RES "${RES}This is an **application** (just a binary executable). Potentially designed to be called by an application or library.\n")
endif()

if(${PROJECT_NAME}_${component}_DESCRIPTION)#adding description of component utility if it has been defined
	set(RES "${RES}\n${${PROJECT_NAME}_${component}_DESCRIPTION}\n")
endif()

set(RES "${RES}\n")

is_HeaderFree_Component(IS_HF ${PROJECT_NAME} ${component})
if(NOT IS_HF)
	#export possible only for libraries with headers 
	set(EXPORTS_SOMETHING FALSE)
	set(EXPORTED_DEPS)
	set(INT_EXPORTED_DEPS)
	set(EXT_EXPORTED_DEPS)
	if(${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES) # the component has internal dependencies
		foreach(a_int_dep IN ITEMS ${${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES})
			if(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${a_int_dep})
				set(EXPORTS_SOMETHING TRUE)
				list(APPEND INT_EXPORTED_DEPS ${a_int_dep})
			endif()
		endforeach()
	endif()
	if(${PROJECT_NAME}_${component}_DEPENDENCIES) # the component has internal dependencies
		foreach(a_pack IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCIES})
			set(${a_pack}_EXPORTED FALSE)
			foreach(a_comp IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCY_${a_pack}_COMPONENTS})
				if(${PROJECT_NAME}_${component}_EXPORT_${a_pack}_${a_comp})
					set(EXPORTS_SOMETHING TRUE)
					if(NOT ${a_pack}_EXPORTED)
						set(${a_pack}_EXPORTED TRUE)
						list(APPEND EXPORTED_DEPS ${a_pack})
					endif()
					list(APPEND EXPORTED_DEP_${a_pack} ${a_comp})
				endif()
			endforeach()
		endforeach()
	endif()
	
	if(${PROJECT_NAME}_${component}_INC_DIRS) # the component export some external dependencies
		foreach(inc IN ITEMS ${${PROJECT_NAME}_${component}_INC_DIRS})
			string(REGEX REPLACE "^<([^>]+)>.*$" "\\1" RES_EXT_PACK ${inc})			
			if(NOT RES_EXT_PACK STREQUAL "${inc}")#match !!
				set(EXPORTS_SOMETHING TRUE)
				if(NOT ${RES_EXT_PACK}_EXPORTED)
					set(${RES_EXT_PACK}_EXPORTED TRUE)
					list(APPEND EXT_EXPORTED_DEPS ${RES_EXT_PACK})
				endif()
			endif()
		endforeach()
	endif()

	if(EXPORTS_SOMETHING) #defines those dependencies taht are exported
		set(RES "${RES}\n### exported dependencies:\n")
		if(INT_EXPORTED_DEPS)
			set(RES "${RES}+ from this package:\n")
			foreach(a_dep IN ITEMS ${INT_EXPORTED_DEPS})
				set(RES "${RES}\t* [${a_dep}](#${a_dep})\n")
			endforeach()
			set(RES "${RES}\n")
		endif()
		if(EXPORTED_DEPS)
			foreach(a_pack IN ITEMS ${EXPORTED_DEPS})
				set(RES "${RES}+ from package **${a_pack}**:\n")
				foreach(a_dep IN ITEMS ${EXPORTED_DEP_${a_pack}})
					if(${a_pack}_WIKI_HOME)
						set(RES "${RES}\t* [${a_dep}](${${a_pack}_WIKI_HOME}#${a_dep})\n")
					else()
						set(RES "${RES}\t* ${a_dep}\n")
					endif()
				endforeach()
				set(RES "${RES}\n")
			endforeach()

		endif()
		if(EXT_EXPORTED_DEPS)
			foreach(a_pack IN ITEMS ${EXT_EXPORTED_DEPS})
				set(RES "${RES}+ external package **${a_pack}**\n")
			endforeach()

		endif()
		set(RES "${RES}\n")
	endif()

	set(RES "${RES}### include directive :\n")
	if(${PROJECT_NAME}_${component}_USAGE_INCLUDES)
		set(RES "${RES}In your code using the library:\n")
		set(RES "${RES}```\n")
		foreach(include_file IN ITEMS ${${PROJECT_NAME}_${component}_USAGE_INCLUDES})
			set(RES "${RES}#include <${include_file}>\n")
		endforeach()
		set(RES "${RES}```\n")
	else()
		set(RES "${RES}Not specified (dangerous). You can try including any or all of these headers:\n")
		set(RES "${RES}```\n")
		foreach(include_file IN ITEMS ${${PROJECT_NAME}_${component}_HEADERS})
			set(RES "${RES}#include <${include_file}>\n")
		endforeach()
		set(RES "${RES}```\n")
	endif()
endif()

# for any kind of usable component
set(RES "${RES}\n### CMake usage :\n\nIn the CMakeLists.txt files of your applications, libraries or tests:\n```\ndeclare_PID_Component_Dependency(\n\t\t\t\tCOMPONENT\tyour component name\n\t\t\t\tNATIVE\t${component}\n\t\t\t\tPACKAGE\t${PROJECT_NAME})\n```\n")

set(${RES_CONTENT} ${RES} PARENT_SCOPE)
endfunction(generate_Component_Wiki)

function(create_Local_Wiki_Project SUCCESS package repo_addr) # package wiki folder does not exists
set(PATH_TO_WIKI_FOLDER ${WORKSPACE_DIR}/wikis)
clone_Wiki_Repository(IS_DEPLOYED ${package} ${repo_addr})
if(NOT IS_DEPLOYED)#repository must be initialized first
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/share/patterns/wiki ${WORKSPACE_DIR}/wikis/${package}.wiki)#create the folder
	init_Wiki_Repository(CONNECTED ${package} ${repo_addr})#configuring the folder as a git repository
	set(${SUCCESS} ${CONNECTED} PARENT_SCOPE) 
else()
	set(${SUCCESS} TRUE PARENT_SCOPE)
	message("[PID] INFO : wiki has been installed.")
endif()#else the repo has been created

endfunction(create_Local_Wiki_Project)

function(wiki_Project_Exists WIKI_EXISTS PATH_TO_WIKI package)
set(SEARCH_PATH ${WORKSPACE_DIR}/wikis/${package}.wiki)
if(EXISTS ${SEARCH_PATH} AND IS_DIRECTORY ${SEARCH_PATH})
	set(${WIKI_EXISTS} TRUE PARENT_SCOPE)
else()
	set(${WIKI_EXISTS} FALSE PARENT_SCOPE)
endif()
set(${PATH_TO_WIKI} ${SEARCH_PATH} PARENT_SCOPE)
endfunction()

function(clean_Local_Wiki package) # clean the folder content (api-doc content)
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/wikis/${package}.wiki/api-doc/html)#delete API doc folder
execute_process(COMMAND ${CMAKE_COMMAND} -E remove ${WORKSPACE_DIR}/wikis/${package}.wiki/license.txt)#delete the license file
execute_process(COMMAND ${CMAKE_COMMAND} -E remove ${WORKSPACE_DIR}/wikis/${package}.wiki/home.markdown)#delete the main page
endfunction(clean_Local_Wiki)

function(copy_Wiki_Content package content_file) # copy everything needed (api-doc content, share/wiki except content_file_to_remove
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/packages/${package}/build/release/share/doc/html  ${WORKSPACE_DIR}/wikis/${package}.wiki/api-doc/html)#recreate the api-doc folder from the one generated by the package
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/packages/${package}/share/wiki  ${WORKSPACE_DIR}/wikis/${package}.wiki)#copy the content of the shared wiki folder of the repository (user defined pages, documents and images)
execute_process(COMMAND ${CMAKE_COMMAND} -E remove ${WORKSPACE_DIR}/wikis/${package}.wiki/${content_file})#exclude the content file from the wiki repository (it is included in the home page)
execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${WORKSPACE_DIR}/packages/${package}/build/release/home.markdown  ${WORKSPACE_DIR}/wikis/${package}.wiki)#copy the up to date wiki home page into wiki repository
execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${WORKSPACE_DIR}/packages/${package}/license.txt  ${WORKSPACE_DIR}/wikis/${package}.wiki)#copy the up to date license file into wiki repository
endfunction(copy_Wiki_Content)

