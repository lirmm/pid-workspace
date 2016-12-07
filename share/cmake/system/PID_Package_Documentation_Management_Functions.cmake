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
					PATHS "${WORKSPACE_DIR}/share/patterns/packages"
					NO_DEFAULT_PATH
		)
	if(GENERIC_DOXYFILE_IN MATCHES GENERIC_DOXYFILE_IN-NOTFOUND)
		message("[PID] ERROR : no doxygen template file found ... skipping documentation generation !!")
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
	set(DOXYFILE_MAIN_PAGE "${CMAKE_BINARY_DIR}/share/APIDOC_welcome.md")
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
				PATH "${WORKSPACE_DIR}/share/cmake/licenses"
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
function(generate_Readme_Files)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	set(README_CONFIG_FILE ${WORKSPACE_DIR}/share/patterns/packages/README.md.in)
	set(APIDOC_WELCOME_CONFIG_FILE ${WORKSPACE_DIR}/share/patterns/packages/APIDOC_welcome.md.in)
	## introduction (more detailed description, if any)
	if(NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS AND NOT ${PROJECT_NAME}_FRAMEWORK)#no site description has been provided nor framework reference (TODO manage frameworks)
		# intro		
		set(README_OVERVIEW "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided by site use the short one
		# no reference to site page
		set(PACKAGE_SITE_REF_IN_README "")

		# simplified install section
		set(INSTALL_USE_IN_README "The procedures for installing the ${PROJECT_NAME} package and for using its components is based on the [PID](https://gite.lirmm.fr/pid/pid-workspace/wikis/home) build and deployment system called PID. Just follow and read the links to understand how to install, use and call its API and/or applications.")
	else()	
		# intro
		generate_Formatted_String("${${PROJECT_NAME}_SITE_INTRODUCTION}" RES_INTRO)
		if("${RES_INTRO}" STREQUAL "")
			set(README_OVERVIEW "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided by site description use the short one
		else()
			set(README_OVERVIEW "${RES_INTRO}") #otherwise use detailed one specific for site
		endif()
		
		# install procedure
		set(INSTALL_USE_IN_README "The procedures for installing the ${PROJECT_NAME} package and for using its components is available in this [site][package_site]. It is based on a CMake based build and deployment system called PID. Just follow and read the links to understand how to install, use and call its API and/or applications.")

		# reference to site page
		set(PACKAGE_SITE_REF_IN_README "[package_site]: ${${PROJECT_NAME}_SITE_ROOT_PAGE} \"${PROJECT_NAME} package\"
")
	endif()
	
	if(${PROJECT_NAME}_LICENSE)
		set(PACKAGE_LICENSE_FOR_README "The license that applies to the whole package content is **${${PROJECT_NAME}_LICENSE}**. Please look at the license.txt file at the root of this repository.")
		
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
	if(NOT ${PROJECT_NAME}_SITE_ADDRESS)
		
	else()
		set(PACKAGE_SITE_REF )
	endif()
	configure_file(${README_CONFIG_FILE} ${CMAKE_SOURCE_DIR}/README.md @ONLY)#put the readme in the source dir
	configure_file(${APIDOC_WELCOME_CONFIG_FILE} ${CMAKE_BINARY_DIR}/share/APIDOC_welcome.md @ONLY)#put api doc welcome page in the build tree 
endif()
endfunction(generate_Readme_Files)


############ functions for the management of static sites of packages  ###########

### create the data files for jekyll
function(generate_Static_Site_Data_Files generated_site_folder)
#1) generating the data file for package site description
file(MAKE_DIRECTORY ${generated_site_folder}/_data) # create the _data folder to put configuration files inside
set(PACKAGE_NAME ${PROJECT_NAME})
set(PACKAGE_PROJECT_REPOSITORY_PAGE ${${PROJECT_NAME}_PROJECT_PAGE})

## introduction (more detailed description, if any)
generate_Formatted_String("${${PROJECT_NAME}_SITE_INTRODUCTION}" RES_INTRO)
if("${RES_INTRO}" STREQUAL "")
	set(PACKAGE_DESCRIPTION "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided use the short one
else()
	set(PACKAGE_DESCRIPTION "${RES_INTRO}") #otherwise use detailed one specific for site
endif()

get_Formatted_Package_Contact_String(${PROJECT_NAME} RES_STRING)
set(PACKAGE_MAINTAINER_NAME ${RES_STRING})
set(PACKAGE_MAINTAINER_MAIL ${${PROJECT_NAME}_CONTACT_MAIL})

#configure references to logo, advanced material and tutorial pages
set(PACKAGE_TUTORIAL)
if(${PROJECT_NAME}_tutorial_SITE_CONTENT_FILE AND EXISTS ${CMAKE_SOURCE_DIR}/share/site/${${PROJECT_NAME}_tutorial_SITE_CONTENT_FILE})
test_Site_Content_File(FILE_NAME EXTENSION ${${PROJECT_NAME}_tutorial_SITE_CONTENT_FILE})
	if(FILE_NAME)
		set(PACKAGE_TUTORIAL ${FILE_NAME})#put only file name since jekyll may generate html from it
	endif()
endif()

set(PACKAGE_DETAILS)
if(${PROJECT_NAME}_advanced_SITE_CONTENT_FILE AND EXISTS ${CMAKE_SOURCE_DIR}/share/site/${${PROJECT_NAME}_advanced_SITE_CONTENT_FILE})
test_Site_Content_File(FILE_NAME EXTENSION ${${PROJECT_NAME}_advanced_SITE_CONTENT_FILE})
	if(FILE_NAME)
		set(PACKAGE_DETAILS ${FILE_NAME}) #put only file name since jekyll may generate html from it
	endif()
endif()

set(PACKAGE_LOGO)
if(${PROJECT_NAME}_logo_SITE_CONTENT_FILE AND EXISTS ${CMAKE_SOURCE_DIR}/share/site/${${PROJECT_NAME}_logo_SITE_CONTENT_FILE})
test_Site_Content_File(FILE_NAME EXTENSION ${${PROJECT_NAME}_logo_SITE_CONTENT_FILE})
	if(FILE_NAME)
		set(PACKAGE_LOGO ${${PROJECT_NAME}_logo_SITE_CONTENT_FILE}) # put the full relative path for the image
	endif()
endif()

# configure menus content depending on project configuration
if(BUILD_API_DOC)
set(PACKAGE_HAS_API_DOC true)
else()
set(PACKAGE_HAS_API_DOC false)
endif()
if(BUILD_COVERAGE_REPORT)
set(PACKAGE_HAS_COVERAGE true)
else()
set(PACKAGE_HAS_COVERAGE false)
endif()
if(BUILD_STATIC_CODE_CHECKING_REPORT)
set(PACKAGE_HAS_STATIC_CHECKS true)
else()
set(PACKAGE_HAS_STATIC_CHECKS false)
endif()
configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/package.yml.in ${generated_site_folder}/_data/package.yml @ONLY)

endfunction(generate_Static_Site_Data_Files)


### create introduction page
function(generate_Static_Site_Page_Introduction generated_pages_folder)

generate_Formatted_String("${${PROJECT_NAME}_SITE_INTRODUCTION}" RES_INTRO)
if("${RES_INTRO}" STREQUAL "")
	set(PACKAGE_DESCRIPTION "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided use the short one
else()
	set(PACKAGE_DESCRIPTION "${RES_INTRO}") #otherwise use detailed one specific for site
endif()

# authors
get_Formatted_Package_Contact_String(${PROJECT_NAME} RES_STRING)
set(PACKAGE_CONTACT "${RES_STRING}")
set(PACKAGE_ALL_AUTHORS "") 
foreach(author IN ITEMS "${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS}")
	get_Formatted_Author_String(${author} RES_STRING)
	set(PACKAGE_ALL_AUTHORS "${PACKAGE_ALL_AUTHORS}\n* ${RES_STRING}")
endforeach()


# platform configuration
set(PACKAGE_PLATFORM_CONFIGURATION "")
if(${PROJECT_NAME}_AVAILABLE_PLATFORMS)
	set(PACKAGE_PLATFORM_CONFIGURATION "Here are the possible platform configurations for this package:\n")
	foreach(platform IN ITEMS ${${PROJECT_NAME}_AVAILABLE_PLATFORMS})# we take only dependencies of the release version
		generate_Platform_Site(${platform} RES_CONTENT_PLATFORM)
		set(PACKAGE_PLATFORM_CONFIGURATION "${PACKAGE_PLATFORM_CONFIGURATION}\n${RES_CONTENT_PLATFORM}")
	endforeach()
else()
	set(PACKAGE_PLATFORM_CONFIGURATION "This package cannot be used on any platform (this is BUG !!)\n")
endif()

# last version
set(PACKAGE_LAST_VERSION_FOR_SITE "${${PROJECT_NAME}_VERSION}")

if(${PROJECT_NAME}_LICENSE)
	set(PACKAGE_LICENSE_FOR_SITE ${${PROJECT_NAME}_LICENSE})
else()
	set(PACKAGE_LICENSE_FOR_SITE "No license Defined")
endif()

# categories
if (NOT ${PROJECT_NAME}_CATEGORIES)
	set(PACKAGE_CATEGORIES_LIST "\nThis package belongs to no category.\n")
else()
	set(PACKAGE_CATEGORIES_LIST "\nThis package belongs to following categories defined in PID workspace:\n")
	foreach(category IN ITEMS ${${PROJECT_NAME}_CATEGORIES})
		set(PACKAGE_CATEGORIES_LIST "${PACKAGE_CATEGORIES_LIST}\n+ ${category}")
	endforeach()
endif()


# package dependencies
set(EXTERNAL_SITE_SECTION "## External\n")
set(NATIVE_SITE_SECTION "## Native\n")
set(PACKAGE_DEPENDENCIES_DESCRIPTION "")

if(NOT ${PROJECT_NAME}_DEPENDENCIES)
	if(NOT ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES)
		set(PACKAGE_DEPENDENCIES_DESCRIPTION "This package has no dependency.\n")
		set(EXTERNAL_SITE_SECTION "")
	endif()
	set(NATIVE_SITE_SECTION "")
else()
	if(NOT ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES)
		set(EXTERNAL_SITE_SECTION "")
	endif()
endif()

if("${PACKAGE_DEPENDENCIES_DESCRIPTION}" STREQUAL "")
	foreach(dep_package IN ITEMS ${${PROJECT_NAME}_DEPENDENCIES})# we take nly dependencies of the release version
		generate_Dependency_Site(${dep_package} RES_CONTENT_NATIVE)
		set(NATIVE_SITE_SECTION "${NATIVE_SITE_SECTION}\n${RES_CONTENT_NATIVE}")
	endforeach()

	foreach(dep_package IN ITEMS ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES})# we take nly dependencies of the release version
		generate_External_Dependency_Site(${dep_package} RES_CONTENT_EXTERNAL)
		set(EXTERNAL_SITE_SECTION "${EXTERNAL_SITE_SECTION}\n${RES_CONTENT_EXTERNAL}")
	endforeach()

	set(PACKAGE_DEPENDENCIES_DESCRIPTION "${EXTERNAL_SITE_SECTION}\n\n${NATIVE_SITE_SECTION}")
endif()

# generating the introduction file for package site
configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/introduction.md.in ${generated_pages_folder}/introduction.md @ONLY)
endfunction(generate_Static_Site_Page_Introduction)



### create introduction page
function(generate_Static_Site_Page_Install generated_pages_folder)

#released version info 
set(PACKAGE_LAST_VERSION_WITH_PATCH "${${PROJECT_NAME}_VERSION}")
get_Version_String_Numbers(${${PROJECT_NAME}_VERSION} major minor patch)
set(PACKAGE_LAST_VERSION_WITHOUT_PATCH "${major}.${minor}")


#getting git references of the project (for manual installation explanation)
if(NOT ${PROJECT_NAME}_ADDRESS)
	extract_Package_Namespace_From_SSH_URL(${${PROJECT_NAME}_SITE_GIT_ADDRESS} ${PROJECT_NAME} GIT_NAMESPACE SERVER_ADDRESS EXTENSION)
	if(GIT_NAMESPACE AND SERVER_ADDRESS)
		set(OFFICIAL_REPOSITORY_ADDRESS "${SERVER_ADDRESS}:${GIT_NAMESPACE}/${PROJECT_NAME}.git")
		set(GIT_SERVER ${SERVER_ADDRESS})
	else()	#no info about the git namespace => generating a bad address 
		set(OFFICIAL_REPOSITORY_ADDRESS "unknown_server:unknown_namespace/${PROJECT_NAME}.git")
		set(GIT_SERVER unknown_server)
	endif()

else()
	set(OFFICIAL_REPOSITORY_ADDRESS ${${PROJECT_NAME}_ADDRESS})
	extract_Package_Namespace_From_SSH_URL(${${PROJECT_NAME}_ADDRESS} ${PROJECT_NAME} GIT_NAMESPACE SERVER_ADDRESS EXTENSION)
	if(SERVER_ADDRESS)
		set(GIT_SERVER ${SERVER_ADDRESS})
	else()	#no info about the git namespace => use the project name
		set(GIT_SERVER unknown_server)
	endif()
endif()

# generating the install file for package site
configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/install.md.in ${generated_pages_folder}/install.md @ONLY)
endfunction(generate_Static_Site_Page_Install)



### create use page
function(generate_Static_Site_Page_Use generated_pages_folder)

#released version info 
set(PACKAGE_LAST_VERSION_WITH_PATCH "${${PROJECT_NAME}_VERSION}")
get_Version_String_Numbers(${${PROJECT_NAME}_VERSION} major minor patch)
set(PACKAGE_LAST_VERSION_WITHOUT_PATCH "${major}.${minor}")

# package components
set(PACKAGE_COMPONENTS_DESCRIPTION "")
if(${PROJECT_NAME}_COMPONENTS) #if there are components
foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	generate_Component_Site(${component} RES_CONTENT_COMP)
	set(PACKAGE_COMPONENTS_DESCRIPTION "${PACKAGE_COMPONENTS_DESCRIPTION}\n${RES_CONTENT_COMP}")
endforeach()
endif()

# generating the install file for package site
configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/use.md.in ${generated_pages_folder}/use.md @ONLY)
endfunction(generate_Static_Site_Page_Use)


###
function(define_Documentation_Content name file)
set(${PROJECT_NAME}_${name}_SITE_CONTENT_FILE ${file} CACHE INTERNAL "")
endfunction(define_Documentation_Content)


### create the data files from package description
function(generate_Static_Site_Pages generated_pages_folder)

# create introduction page
generate_Static_Site_Page_Introduction(${generated_pages_folder})
# create install page
generate_Static_Site_Page_Install(${generated_pages_folder})
# create use page 
generate_Static_Site_Page_Use(${generated_pages_folder})
# copy the site folder

endfunction(generate_Static_Site_Pages)


### site pages generation
function(configure_Pages)
if(NOT ${CMAKE_BUILD_TYPE} MATCHES Release)
	return()
endif()
if(NOT ${PROJECT_NAME}_FRAMEWORK AND NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS) #no web site definition simply exit
	#no static site definition done so we create a fake "site" command in realease mode
	add_custom_target(site
		COMMAND ${CMAKE_COMMAND} -E  echo "No specification of a static site in the project, use the declare_PID_Documentation function in the root CMakeLists.txt file of the project"
	)
	return()
endif()

set(PATH_TO_SITE ${CMAKE_BINARY_DIR}/site)
if(EXISTS ${PATH_TO_SITE})
	file(REMOVE_RECURSE ${PATH_TO_SITE})
endif()
file(MAKE_DIRECTORY ${PATH_TO_SITE}) # create the site root site directory
set(PATH_TO_SITE_PAGES ${PATH_TO_SITE}/pages)
file(MAKE_DIRECTORY ${PATH_TO_SITE_PAGES}) # create the pages directory

#1) generate the data files for jekyll (vary depending on the site creation mode
if(${PROJECT_NAME}_SITE_GIT_ADDRESS) #the package is outside any framework
	generate_Static_Site_Data_Files(${PATH_TO_SITE})
else()
	#TODO
endif()

# common generation process between framework and lone static sites 

#2) generate pages
generate_Static_Site_Pages(${PATH_TO_SITE_PAGES})

endfunction(configure_Pages)


###
function(generate_Platform_Site platform RES_CONTENT_PLATFORM)
set(CONTENT "### ${platform}\n\n+ OS type: ${${PROJECT_NAME}_AVAILABLE_PLATFORM_${platform}_OS}\n+ architecture: ${${PROJECT_NAME}_AVAILABLE_PLATFORM_${platform}_ARCH} bits\n+ abi: ${${PROJECT_NAME}_AVAILABLE_PLATFORM_${platform}_ABI}\n")

if(${PROJECT_NAME}_AVAILABLE_PLATFORM_${platform}_CONFIGURATION)
	foreach(config IN ITEMS ${${PROJECT_NAME}_AVAILABLE_PLATFORM_${platform}_CONFIGURATION})
		set(CONTENT "${CONTENT}+ platform configuration required: ${config}")
	endforeach()
else()
	set(CONTENT "${CONTENT}+ no specific platform configuration required.")
endif()
set(CONTENT "${CONTENT}\n")
set(${RES_CONTENT_PLATFORM} ${CONTENT} PARENT_SCOPE) 
endfunction(generate_Platform_Site)

###
function(generate_Dependency_Site dependency RES_CONTENT)
if(${dependency}_SITE_ROOT_PAGE)
	set(RES "+ [${dependency}](${${dependency}_SITE_ROOT_PAGE})") #creating a link to the package site
else()
	set(RES "+ ${dependency}")#TODO implement this for frameworks
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
endfunction(generate_Dependency_Site)


function(generate_External_Dependency_Site dependency RES_CONTENT)
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
endfunction(generate_External_Dependency_Site)


function(generate_Component_Site component RES_CONTENT)
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
					if(${a_pack}_SITE_ROOT_PAGE)
						set(RES "${RES}\t* [${a_dep}](${${a_pack}_SITE_ROOT_PAGE}#${a_dep})\n")
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
		set(RES "${RES}In your code using the library:\n\n")
		set(RES "${RES}{% highlight cpp %}\n")	
		foreach(include_file IN ITEMS ${${PROJECT_NAME}_${component}_USAGE_INCLUDES})
			set(RES "${RES}#include <${include_file}>\n")
		endforeach()
		set(RES "${RES}{% endhighlight %}\n")
	else()
		set(RES "${RES}Not specified (dangerous). You can try including any or all of these headers:\n\n")
		set(RES "${RES}{% highlight cpp %}\n")	
		foreach(include_file IN ITEMS ${${PROJECT_NAME}_${component}_HEADERS})
			set(RES "${RES}#include <${include_file}>\n")
		endforeach()
		set(RES "${RES}{% endhighlight %}\n")
	endif()
endif()

# for any kind of usable component
set(RES "${RES}\n### CMake usage :\n\nIn the CMakeLists.txt files of your applications, libraries or tests:\n\n{% highlight cmake %}\ndeclare_PID_Component_Dependency(\n\t\t\t\tCOMPONENT\tyour component name\n\t\t\t\tNATIVE\t${component}\n\t\t\t\tPACKAGE\t${PROJECT_NAME})\n{% endhighlight %}\n\n")

set(${RES_CONTENT} ${RES} PARENT_SCOPE)
endfunction(generate_Component_Site)

### create a local repository for the package's static site
function(create_Local_Static_Site_Project SUCCESS package repo_addr push_site) 
set(PATH_TO_STATIC_SITE_FOLDER ${WORKSPACE_DIR}/sites/packages)
clone_Static_Site_Repository(IS_INITIALIZED BAD_URL ${package} ${repo_addr})
set(CONNECTED FALSE)
if(NOT IS_INITIALIZED)#repository must be initialized first
	if(BAD_URL)
		message("[PID] ERROR : impossible to clone the repository of package ${package} static site (maybe ${repo_addr} is a bad repository address or you have no clone rights for this repository). Please contact the administrator of this repository.")
		set(${SUCCESS} FALSE PARENT_SCOPE)
		return()
	endif()
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/share/patterns/static_sites/package ${WORKSPACE_DIR}/sites/packages/${package})#create the folder containing the site from the pattern folder
	set(PACKAGE_NAME ${package})
	configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/CMakeLists.txt.in ${WORKSPACE_DIR}/sites/packages/${package}/CMakeLists.txt @ONLY)#adding the cmake project file to the static site project

	init_Static_Site_Repository(CONNECTED ${package} ${repo_addr} ${push_site})#configuring the folder as a git repository
	if(push_site AND NOT CONNECTED)
		set(${SUCCESS} FALSE PARENT_SCOPE)
	else()
		set(${SUCCESS} TRUE PARENT_SCOPE)
	endif()
else()
	set(${SUCCESS} TRUE PARENT_SCOPE)
endif()#else the repo has been created
endfunction(create_Local_Static_Site_Project)

### checking if the package static site repository exists in the workspace 
function(static_Site_Project_Exists SITE_EXISTS PATH_TO_SITE package)
set(SEARCH_PATH ${WORKSPACE_DIR}/sites/packages/${package})
if(EXISTS ${SEARCH_PATH} AND IS_DIRECTORY ${SEARCH_PATH})
	set(${SITE_EXISTS} TRUE PARENT_SCOPE)
else()
	set(${SITE_EXISTS} FALSE PARENT_SCOPE)
endif()
set(${PATH_TO_SITE} ${SEARCH_PATH} PARENT_SCOPE)
endfunction()

### checking if the framework site repository exists in the workspace
function(framework_Project_Exists SITE_EXISTS PATH_TO_SITE framework)
set(SEARCH_PATH ${WORKSPACE_DIR}/sites/frameworks/${framework})
if(EXISTS ${SEARCH_PATH} AND IS_DIRECTORY ${SEARCH_PATH})
	set(${SITE_EXISTS} TRUE PARENT_SCOPE)
else()
	set(${SITE_EXISTS} FALSE PARENT_SCOPE)
endif()
set(${PATH_TO_SITE} ${SEARCH_PATH} PARENT_SCOPE)
endfunction()

function(clean_Local_Static_Site package include_api_doc include_coverage include_staticchecks) # clean the source folder content
if(include_api_doc)
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/sites/packages/${package}/src/api_doc)#delete API doc folder
endif()
if(include_coverage)
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/sites/packages/${package}/src/coverage ERROR_QUIET OUTPUT_QUIET)#delete coverage report folder
endif()
if(include_staticchecks)
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/sites/packages/${package}/src/static_checks ERROR_QUIET OUTPUT_QUIET)#delete static checks report folder
endif()
execute_process(COMMAND ${CMAKE_COMMAND} -E remove ${WORKSPACE_DIR}/sites/packages/${package}/license.txt)#delete the license file
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/sites/packages/${package}/src/pages)#delete all pages
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${WORKSPACE_DIR}/sites/packages/${package}/src/pages)#recreate the pages folder
endfunction(clean_Local_Static_Site)

function(copy_Static_Site_Content package version platform include_api_doc include_coverage include_staticchecks include_installer) # copy everything needed
if(include_api_doc AND EXISTS ${WORKSPACE_DIR}/packages/${package}/build/release/share/doc/html) # #may not exists if the make doc command has not been launched
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/packages/${package}/build/release/share/doc/html  ${WORKSPACE_DIR}/sites/packages/${package}/src/api_doc)#recreate the api_doc folder from the one generated by the package
endif()

if(include_coverage AND EXISTS ${WORKSPACE_DIR}/packages/${package}/build/debug/share/coverage_report)# #may not exists if the make coverage command has not been launched
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/packages/${package}/build/debug/share/coverage_report ${WORKSPACE_DIR}/sites/packages/${package}/src/coverage)#recreate the coverage folder from the one generated by the package
endif()

if(include_staticchecks AND EXISTS ${WORKSPACE_DIR}/packages/${package}/build/release/share/static_checks_report) #may not exists if the make staticchecks command has not been launched
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/packages/${package}/build/release/share/static_checks_report ${WORKSPACE_DIR}/sites/packages/${package}/src/static_checks)#recreate the static_checks folder from the one generated by the package
endif()

if(	include_installer
	AND EXISTS ${WORKSPACE_DIR}/packages/${package}/build/release/${package}-${version}-${platform}.tar.gz
	AND EXISTS ${WORKSPACE_DIR}/packages/${package}/build/debug/${package}-${version}-dbg-${platform}.tar.gz) 
	
	file(MAKE_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package}/src/_binaries/${version}/${platform})#create the target folder if it does not exist

	file(COPY ${WORKSPACE_DIR}/packages/${package}/build/release/${package}-${version}-${platform}.tar.gz 
		${WORKSPACE_DIR}/packages/${package}/build/debug/${package}-${version}-dbg-${platform}.tar.gz
		DESTINATION  ${WORKSPACE_DIR}/sites/packages/${package}/src/_binaries/${version}/${platform})#copy the binaries

	# configure the file used to reference the binary in jekyll
	set(BINARY_PACKAGE ${package})
	set(BINARY_VERSION ${version})
	set(BINARY_PLATFORM ${platform})
	configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/binary.md.in ${WORKSPACE_DIR}/sites/packages/${package}/src/_binaries/${version}/${platform}/binary.md @ONLY)#adding the cmake project file to the static site project
endif()

execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${WORKSPACE_DIR}/packages/${package}/license.txt  ${WORKSPACE_DIR}/sites/packages/${package})#copy the up to date license file into site repository

#now copy the content -> 2 phases

#1) copy content from source into the binary dir
if(EXISTS ${WORKSPACE_DIR}/packages/${package}/share/site AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/share/site)

execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/packages/${package}/share/site ${WORKSPACE_DIR}/packages/${package}/build/release/site/pages)#copy the content of the site source share folder of the package (user defined pages, documents and images)

endif()

#2) copy content from binary dir to site repository source dir
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/packages/${package}/build/release/site ${WORKSPACE_DIR}/sites/packages/${package}/src)

endfunction(copy_Static_Site_Content)

### building the static site simply consists in calling adequately the repository project adequate build commands
function (build_Static_Site package)
execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR}/sites/packages/${package} WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package}/build)
execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} build WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package}/build)
endfunction(build_Static_Site)

