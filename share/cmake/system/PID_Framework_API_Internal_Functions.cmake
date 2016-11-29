
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


########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Package_Cache_Management_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)

##################################################################################
##################  declaration of a lone package static site ####################
##################################################################################

############ function used to create the README.md file of the framework  ###########
function(generate_Site_Readme_File)
set(README_CONFIG_FILE ${WORKSPACE_DIR}/share/patterns/static_sites/README.md.in)
set(PACKAGE_NAME ${PROJECT_NAME})
configure_file(${README_CONFIG_FILE} ${CMAKE_SOURCE_DIR}/README.md @ONLY)#put it in the source dir
endfunction(generate_Site_Readme_File)


############ function used to generate basic files and directory structure for jekyll  ###########
function(generate_Site_Data)
# 1) generate the basic site structure and default files from a pattern
if(EXISTS ${CMAKE_BINARY_DIR}/to_generate)
	file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/to_generate)
endif()
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/to_generate)

execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/share/patterns/static_sites/static ${CMAKE_BINARY_DIR}/to_generate
		COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/to_generate/_data)

endfunction(generate_Site_Data)

### implementation function for creating a static site for a lone package
macro(declare_Site)

file(RELATIVE_PATH DIR_NAME ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})
if(DIR_NAME STREQUAL "build")

	generate_Site_Readme_File() # generating the simple README file for the project
	generate_Site_Data() #generating the jekyll source folder in build tree

	#searching for jekyll (static site generator)
	find_program(JEKYLL_EXECUTABLE NAMES jekyll) #searcinh for the jekyll executable in standard paths

	if(JEKYLL_EXECUTABLE)

	add_custom_target(build
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DJEKYLL_EXECUTABLE=${JEKYLL_EXECUTABLE}
						-P ${WORKSPACE_DIR}/share/cmake/system/Build_PID_Package_SIte.cmake
		COMMENT "[PID] Building package site ..."
		VERBATIM
	)

	add_custom_target(serve
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DJEKYLL_EXECUTABLE=${JEKYLL_EXECUTABLE}
						-P ${WORKSPACE_DIR}/share/cmake/system/Serve_PID_Framework.cmake
		COMMENT "[PID] Serving the static site of the package ..."
		VERBATIM
	)

	else()
		message("[PID] ERROR: the jekyll executable cannot be found in the system, please install it and put it in a standard path.")
	endif()
else()
	message("[PID] ERROR : please run cmake in the build folder of the package ${PROJECT_NAME} static site.")
	return()
endif()
endmacro(declare_Site)

##################################################################################
##########################  declaration of a framework ###########################
##################################################################################
macro(declare_Framework author institution mail year site license git_address repo_site description)

file(RELATIVE_PATH DIR_NAME ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})
if(DIR_NAME STREQUAL "build")

	set(${PROJECT_NAME}_ROOT_DIR CACHE INTERNAL "")
	list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake) # adding the cmake scripts files from the framework

	init_PID_Version_Variable() # getting the workspace version used to generate the code 
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
	set(${PROJECT_NAME}_SITE ${site} CACHE INTERNAL "")
	set(${PROJECT_NAME}_REPOSITORY_SITE ${repo_site} CACHE INTERNAL "")
	set(${PROJECT_NAME}_LICENSE ${license} CACHE INTERNAL "")
	set(${PROJECT_NAME}_ADDRESS ${git_address} CACHE INTERNAL "")
	set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")#categories are reset


	#searching for jekyll (static site generator)
	find_program(JEKYLL_EXECUTABLE NAMES jekyll) #searcinh for the jekyll executable in standard paths

	if(JEKYLL_EXECUTABLE)

	add_custom_target(build
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_FRAMEWORK=${PROJECT_NAME}
						-DJEKYLL_EXECUTABLE=${JEKYLL_EXECUTABLE}
						-P ${WORKSPACE_DIR}/share/cmake/system/Build_PID_Framework.cmake
		COMMENT "[PID] Building framework ..."
		VERBATIM
	)

	add_custom_target(serve
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_FRAMEWORK=${PROJECT_NAME}
						-DJEKYLL_EXECUTABLE=${JEKYLL_EXECUTABLE}
						-P ${WORKSPACE_DIR}/share/cmake/system/Serve_PID_Framework.cmake
		COMMENT "[PID] Serving the static site of the framework ..."
		VERBATIM
	)

	else()
		message("[PID] ERROR: the jekyll executable cannot be found in the system, please install it and put it in a standard path.")
	endif()
else()
	message("[PID] ERROR : please run cmake in the build folder of the framework ${PROJECT_NAME}.")
	return()
endif()
endmacro(declare_Framework)

###
macro(declare_Framework_Image image_file_path is_banner)

if(is_banner)
	set(${PROJECT_NAME}_BANNER_IMAGE_FILE_NAME ${image_file_path})
else() #this is a logo
	set(${PROJECT_NAME}_LOGO_IMAGE_FILE_NAME ${image_file_path})
endif()

endmacro(declare_Framework_Image)

##################################################################################
############################### building the framework ###########################
##################################################################################

############ function used to create the README.md file of the framework  ###########
function(generate_Framework_Readme_File)
set(README_CONFIG_FILE ${WORKSPACE_DIR}/share/patterns/frameworks/README.md.in)


set(FRAMEWORK_NAME ${PROJECT_NAME})
set(FRAMEWORK_SITE ${${PROJECT_NAME}_SITE})
set(README_OVERVIEW "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided by wiki description use the short one


if(${PROJECT_NAME}_LICENSE)
	set(LICENSE_FOR_README "The license that applies to this repository project is **${${PROJECT_NAME}_LICENSE}**.")
else()
	set(LICENSE_FOR_README "The package has no license defined yet.")
endif()

set(README_AUTHORS_LIST "")

foreach(author IN ITEMS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS})
	generate_Full_Author_String(${author} STRING_TO_APPEND)
	set(README_AUTHORS_LIST "${README_AUTHORS_LIST}\n+ ${STRING_TO_APPEND}")
endforeach()

get_Formatted_Package_Contact_String(${PROJECT_NAME} RES_STRING)
set(README_CONTACT_AUTHOR "${RES_STRING}")

configure_file(${README_CONFIG_FILE} ${CMAKE_SOURCE_DIR}/README.md @ONLY)#put it in the source dir
endfunction(generate_Framework_Readme_File)

############ function used to create the license.txt file of the package  ###########
function(generate_Framework_License_File)
if(	DEFINED ${PROJECT_NAME}_LICENSE 
	AND NOT ${${PROJECT_NAME}_LICENSE} STREQUAL "")

	find_file(	LICENSE   
			"License${${PROJECT_NAME}_LICENSE}.cmake"
			PATH "${WORKSPACE_DIR}/share/cmake/licenses"
			NO_DEFAULT_PATH
		)
	set(LICENSE ${LICENSE} CACHE INTERNAL "")
	
	if(LICENSE_IN-NOTFOUND)
		message("[PID] WARNING : license configuration file for ${${PROJECT_NAME}_LICENSE} not found in workspace, license file will not be generated")
	else()
		foreach(author IN ITEMS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS})
			generate_Full_Author_String(${author} STRING_TO_APPEND)
			set(${PROJECT_NAME}_AUTHORS_LIST "${${PROJECT_NAME}_AUTHORS_LIST} ${STRING_TO_APPEND}")
		endforeach()
		include(${WORKSPACE_DIR}/share/cmake/licenses/License${${PROJECT_NAME}_LICENSE}.cmake)
		file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
	endif()
endif()
endfunction(generate_Framework_License_File)


############ function used to generate data files for jekyll  ###########
function(generate_Framework_Data)
# 1) generate the basic site structure and default files from a pattern
if(EXISTS ${CMAKE_BINARY_DIR}/to_generate)
	file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/to_generate)
endif()
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/to_generate)

execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/share/patterns/frameworks/static ${CMAKE_BINARY_DIR}/to_generate
		COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/to_generate/_data)

# 2) generate the data file containing general information about the framework (generated from a CMake pattern file)
set(FRAMEWORK_NAME ${PROJECT_NAME})
set(FRAMEWORK_SITE_URL ${${PROJECT_NAME}_SITE})
set(FRAMEWORK_PROJECT_REPOSITORY_PAGE ${${PROJECT_NAME}_REPOSITORY_SITE})
get_Formatted_Package_Contact_String(${PROJECT_NAME} RES_STRING)
set(FRAMEWORK_MAINTAINER_NAME ${RES_STRING})
set(FRAMEWORK_MAINTAINER_MAIL ${${PROJECT_NAME}_CONTACT_MAIL})
set(FRAMEWORK_DESCRIPTION ${${PROJECT_NAME}_DESCRIPTION})
set(FRAMEWORK_BANNER ${${PROJECT_NAME}_BANNER_IMAGE_FILE_NAME})
set(FRAMEWORK_LOGO ${${PROJECT_NAME}_LOGO_IMAGE_FILE_NAME})
configure_file(${CMAKE_SOURCE_DIR}/share/framework.yml.in ${CMAKE_BINARY_DIR}/to_generate/_data/framework.yml @ONLY)

# 3) generate the data file defining categories managed by the framework (generated from scratch)
file(WRITE ${CMAKE_BINARY_DIR}/to_generate/_data/categories.yml "")
if(${PROJECT_NAME}_CATEGORIES)
	foreach(cat IN ITEMS ${${PROJECT_NAME}_CATEGORIES})
		extract_All_Words_From_Path(${cat} LIST_OF_NAMES)
		list(LENGTH LIST_OF_NAMES SIZE)
		set(FINAL_NAME "")
		if(SIZE GREATER 1)# there are subcategories
			foreach(name IN ITEMS ${LIST_OF_NAMES})
				extract_All_Words(${name} NEW_NAMES)# replace underscores with spaces
				
				fill_List_Into_String("${NEW_NAMES}" RES_STRING)
				set(FINAL_NAME "${FINAL_NAME} ${RES_STRING}")
				math(EXPR SIZE '${SIZE}-1')
				if(SIZE GREATER 0) #there is more than on categrization level remaining
					set(FINAL_NAME "${FINAL_NAME}/ ")
				endif()
				
			endforeach()
			file(APPEND ${CMAKE_BINARY_DIR}/to_generate/_data/categories.yml "- name: \"${FINAL_NAME}\"\n  index: \"${cat}\"\n\n")
		else()
			extract_All_Words(${cat} NEW_NAMES)# replace underscores with spaces
			fill_List_Into_String("${NEW_NAMES}" RES_STRING)
			set(FINAL_NAME "${RES_STRING}")
			file(APPEND ${CMAKE_BINARY_DIR}/to_generate/_data/categories.yml "- name: \"${FINAL_NAME}\"\n  index: \"${cat}\"\n\n")
		endif()
	endforeach()
endif()

# 4) generate the configuration file for jekyll generation
configure_file(${CMAKE_SOURCE_DIR}/share/_config.yml.in ${CMAKE_BINARY_DIR}/to_generate/_config.yml @ONLY)

endfunction(generate_Framework_Data)


### main function for building the package
macro(build_Framework)

####################################################
############ CONFIGURING the BUILD #################
####################################################

# configuring all that can be configured from framework description
generate_Framework_Readme_File() # generating and putting into source directory the readme file used by gitlab
generate_Framework_License_File() # generating and putting into source directory the file containing license info about the package
generate_Framework_Data() # generating the data files for jelkyll (result in the build tree)

# build steps
# 1) create or clean the _site folder in build tree. 
# 2) create or clean the to_generate folder in build tree. When created all files are copied from static folder of framework pattern. When cleaned only user specific code is removed
# 3) copy all framework specific content from src (hand written or generated by packages) and build (generated files) dirs INTO the to_generate folder.
# 4) call jekyll on the to_generate folder with _site has output => the output site is in the _site folder of the build tree.


#########################################################################################################################
######### writing the global reference file for the package with all global info contained in the CMakeFile.txt #########
#########################################################################################################################
if(${PROJECT_NAME}_ADDRESS)
	generate_Reference_File(${CMAKE_BINARY_DIR}/share/ReferFramework${PROJECT_NAME}.cmake) 
	#copy the reference file of the package into the "references" folder of the workspace
	add_custom_target(referencing
		COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/share/ReferFramework${PROJECT_NAME}.cmake ${WORKSPACE_DIR}/share/cmake/references
		COMMAND ${CMAKE_COMMAND} -E echo "Framework references have been registered into the worskpace"
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
endif()

endmacro(build_Framework)

