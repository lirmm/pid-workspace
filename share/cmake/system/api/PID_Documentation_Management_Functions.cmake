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

##########################################################################################
############################ Guard for optimization of configuration process #############
##########################################################################################
if(PID_DOCUMENTATION_MANAGEMENT_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_DOCUMENTATION_MANAGEMENT_FUNCTIONS_INCLUDED TRUE)
##########################################################################################


################################################################################
######################## Native packages related functions #####################
################################################################################

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
	if(NOT TARGET doc)
		add_custom_target(doc)
	endif()

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
function(generate_Package_License_File)
if(CMAKE_BUILD_TYPE MATCHES Release)
	if(EXISTS ${CMAKE_SOURCE_DIR}/license.txt)# a license has already been generated
		if(NOT REGENERATE_LICENSE)# avoid regeneration if nothing changed
			return()
		endif()
	endif()

	if(	${PROJECT_NAME}_LICENSE )
		find_file(	LICENSE
				"License${${PROJECT_NAME}_LICENSE}.cmake"
				PATH "${WORKSPACE_DIR}/share/cmake/licenses"
				NO_DEFAULT_PATH
			)
		set(LICENSE ${LICENSE} CACHE INTERNAL "")

		if(LICENSE_IN STREQUAL LICENSE_IN-NOTFOUND)
			message("[PID] WARNING : license configuration file for ${${PROJECT_NAME}_LICENSE} not found in workspace, license file will not be generated")
		else()
			#prepare license generation
			set(${PROJECT_NAME}_FOR_LICENSE ${PROJECT_NAME})
			set(${PROJECT_NAME}_DESCRIPTION_FOR_LICENSE ${${PROJECT_NAME}_DESCRIPTION})
			set(${PROJECT_NAME}_YEARS_FOR_LICENSE ${${PROJECT_NAME}_YEARS})
			foreach(author IN LISTS ${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS)
				generate_Full_Author_String(${author} STRING_TO_APPEND)
				set(${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE "${${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE} ${STRING_TO_APPEND}")
			endforeach()

			include(${WORKSPACE_DIR}/share/cmake/licenses/License${${PROJECT_NAME}_LICENSE}.cmake)
			file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
			install(FILES ${CMAKE_SOURCE_DIR}/license.txt DESTINATION ${${PROJECT_NAME}_DEPLOY_PATH})
			file(WRITE ${CMAKE_BINARY_DIR}/share/file_header_comment.txt.in ${LICENSE_HEADER_FILE_DESCRIPTION})
		endif()
	endif()
endif()
endfunction(generate_Package_License_File)


############ function used to create the README.md file of the package  ###########
function(generate_Package_Readme_Files)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	set(README_CONFIG_FILE ${WORKSPACE_DIR}/share/patterns/packages/README.md.in)
	set(APIDOC_WELCOME_CONFIG_FILE ${WORKSPACE_DIR}/share/patterns/packages/APIDOC_welcome.md.in)
	## introduction (more detailed description, if any)
	get_Package_Site_Address(ADDRESS ${PROJECT_NAME})
	if(NOT ADDRESS)#no site description has been provided nor framework reference
		# intro
		set(README_OVERVIEW "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided by site use the short one
		# no reference to site page
		set(PACKAGE_SITE_REF_IN_README "")

		# simplified install section
		set(INSTALL_USE_IN_README "The procedures for installing the ${PROJECT_NAME} package and for using its components is based on the [PID](http://pid.lirmm.net/pid-framework/pages/install.html) build and deployment system called PID. Just follow and read the links to understand how to install, use and call its API and/or applications.")
	else()
		# intro
		generate_Formatted_String("${${PROJECT_NAME}_SITE_INTRODUCTION}" RES_INTRO)
		if("${RES_INTRO}" STREQUAL "")
			set(README_OVERVIEW "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided by site description use the short one
		else()
			set(README_OVERVIEW "${RES_INTRO}") #otherwise use detailed one specific for site
		endif()

		# install procedure
		set(INSTALL_USE_IN_README "The procedures for installing the ${PROJECT_NAME} package and for using its components is available in this [site][package_site]. It is based on a CMake based build and deployment system called [PID](http://pid.lirmm.net/pid-framework/pages/install.html). Just follow and read the links to understand how to install, use and call its API and/or applications.")

		# reference to site page
		set(PACKAGE_SITE_REF_IN_README "[package_site]: ${ADDRESS} \"${PROJECT_NAME} package\"
")
	endif()

	if(${PROJECT_NAME}_LICENSE)
		set(PACKAGE_LICENSE_FOR_README "The license that applies to the whole package content is **${${PROJECT_NAME}_LICENSE}**. Please look at the license.txt file at the root of this repository.")

	else()
		set(PACKAGE_LICENSE_FOR_README "The package has no license defined yet.")
	endif()

	set(README_USER_CONTENT "")
	if(${PROJECT_NAME}_USER_README_FILE AND EXISTS ${CMAKE_SOURCE_DIR}/share/${${PROJECT_NAME}_USER_README_FILE})
		file(READ ${CMAKE_SOURCE_DIR}/share/${${PROJECT_NAME}_USER_README_FILE} CONTENT_ODF_README)
		set(README_USER_CONTENT "${CONTENT_ODF_README}")
	endif()

	set(README_AUTHORS_LIST "")
	foreach(author IN LISTS ${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS)
		generate_Full_Author_String(${author} STRING_TO_APPEND)
		set(README_AUTHORS_LIST "${README_AUTHORS_LIST}\n+ ${STRING_TO_APPEND}")
	endforeach()

	get_Formatted_Package_Contact_String(${PROJECT_NAME} RES_STRING)
	set(README_CONTACT_AUTHOR "${RES_STRING}")

	configure_file(${README_CONFIG_FILE} ${CMAKE_SOURCE_DIR}/README.md @ONLY)#put the readme in the source dir
	configure_file(${APIDOC_WELCOME_CONFIG_FILE} ${CMAKE_BINARY_DIR}/share/APIDOC_welcome.md @ONLY)#put api doc welcome page in the build tree
endif()
endfunction(generate_Package_Readme_Files)


############ functions for the management of static sites of packages  ###########

### create the data files for jekyll
function(generate_Static_Site_Data_Files generated_site_folder)
#generating the data file for package site description
file(MAKE_DIRECTORY ${generated_site_folder}/_data) # create the _data folder to put configuration files inside
configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/package.yml.in ${generated_site_folder}/_data/package.yml @ONLY)
endfunction(generate_Static_Site_Data_Files)


### create the index file for package in the framework
function(generate_Package_Page_Index_In_Framework generated_site_folder)
configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/index.html.in ${generated_site_folder}/index.html @ONLY)
endfunction(generate_Package_Page_Index_In_Framework)

### create introduction page
function(generate_Static_Site_Page_Introduction generated_pages_folder)

# categories
if (NOT ${PROJECT_NAME}_CATEGORIES)
	set(PACKAGE_CATEGORIES_LIST "\nThis package belongs to no category.\n")
else()
	set(PACKAGE_CATEGORIES_LIST "\nThis package belongs to following categories defined in PID workspace:\n")
	foreach(category IN LISTS ${PROJECT_NAME}_CATEGORIES)
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

if("${PACKAGE_DEPENDENCIES_DESCRIPTION}" STREQUAL "") #means that the package has dependencies
	foreach(dep_package IN LISTS ${PROJECT_NAME}_DEPENDENCIES)# we take nly dependencies of the release version
		generate_Dependency_Site(${dep_package} RES_CONTENT_NATIVE)
		set(NATIVE_SITE_SECTION "${NATIVE_SITE_SECTION}\n${RES_CONTENT_NATIVE}")
	endforeach()

	foreach(dep_package IN LISTS ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES)# we take nly dependencies of the release version
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

# package components
set(PACKAGE_COMPONENTS_DESCRIPTION "")
if(${PROJECT_NAME}_COMPONENTS) #if there are components
foreach(component IN LISTS ${PROJECT_NAME}_COMPONENTS)
	generate_Component_Site(${component} RES_CONTENT_COMP)
	set(PACKAGE_COMPONENTS_DESCRIPTION "${PACKAGE_COMPONENTS_DESCRIPTION}\n${RES_CONTENT_COMP}")
endforeach()
endif()

# generating the install file for package site
configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/use.md.in ${generated_pages_folder}/use.md @ONLY)
endfunction(generate_Static_Site_Page_Use)

###
function(generate_Static_Site_Page_Contact generated_pages_folder)
# generating the install file for package site
configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/contact.md.in ${generated_pages_folder}/contact.md @ONLY)
endfunction(generate_Static_Site_Page_Contact)

###
function(generate_Static_Site_Page_License generated_pages_folder)
#adding a license file in markdown format in the site pages (to be copied later if any modification occurred)
configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/license.md.in ${generated_pages_folder}/license.md @ONLY)
endfunction(generate_Static_Site_Page_License)

###
function(define_Component_Documentation_Content component file)
set(DECLARED FALSE)
is_Declared(${component} DECLARED)
if(DECLARED AND EXISTS ${CMAKE_SOURCE_DIR}/share/site/${file})
	define_Documentation_Content(${component} ${file})
else()
	message("[PID] WARNING : documentation file for component ${component} cannot be found at ${CMAKE_SOURCE_DIR}/share/site/${file}. Documentation for this component will not reference this specific content.")
endif()
endfunction(define_Component_Documentation_Content)

###
function(define_Documentation_Content name file)
set(${PROJECT_NAME}_${name}_SITE_CONTENT_FILE ${file} CACHE INTERNAL "")
endfunction(define_Documentation_Content)

###
function(define_Component_Documentation_Content component file)
set(DECLARED FALSE)
is_Declared(${component} DECLARED)
if(DECLARED AND EXISTS ${CMAKE_SOURCE_DIR}/share/site/${file})
	define_Documentation_Content(${component} ${file})
else()
	message("[PID] WARNING : documentation file for component ${component} cannot be found at ${CMAKE_SOURCE_DIR}/share/site/${file}. Documentation for this component will not reference this specific content.")
endif()
endfunction(define_Component_Documentation_Content)

### create the data files from package description
function(generate_Static_Site_Pages generated_pages_folder)
	generate_Static_Site_Page_Introduction(${generated_pages_folder}) # create introduction page
	generate_Static_Site_Page_Install(${generated_pages_folder})# create install page
	generate_Static_Site_Page_Use(${generated_pages_folder})# create use page
	generate_Static_Site_Page_Contact(${generated_pages_folder})# create use page
	generate_Static_Site_Page_License(${generated_pages_folder}) #create license page
endfunction(generate_Static_Site_Pages)

###
macro(configure_Static_Site_Generation_Variables)
set(PACKAGE_NAME ${PROJECT_NAME})
set(PACKAGE_PROJECT_REPOSITORY_PAGE ${${PROJECT_NAME}_PROJECT_PAGE})
set(PACKAGE_CATEGORIES ${${PROJECT_NAME}_CATEGORIES})

#released version info
if(${PROJECT_NAME}_VERSION) #only native package have a current version
	set(PACKAGE_LAST_VERSION_WITH_PATCH "${${PROJECT_NAME}_VERSION}")
	get_Version_String_Numbers(${${PROJECT_NAME}_VERSION} major minor patch)
	set(PACKAGE_LAST_VERSION_WITHOUT_PATCH "${major}.${minor}")
endif()

## descirption (use the most detailed description, if any)
generate_Formatted_String("${${PROJECT_NAME}_SITE_INTRODUCTION}" RES_INTRO)
if("${RES_INTRO}" STREQUAL "")
	set(PACKAGE_DESCRIPTION "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided use the short one
else()
	set(PACKAGE_DESCRIPTION "${RES_INTRO}") #otherwise use detailed one specific for site
endif()

## managing authors
get_Formatted_Package_Contact_String(${PROJECT_NAME} RES_STRING)
set(PACKAGE_MAINTAINER_NAME ${RES_STRING})
set(PACKAGE_MAINTAINER_MAIL ${${PROJECT_NAME}_CONTACT_MAIL})


set(PACKAGE_ALL_AUTHORS "")
foreach(author IN LISTS ${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS)
	get_Formatted_Author_String(${author} RES_STRING)
	set(PACKAGE_ALL_AUTHORS "${PACKAGE_ALL_AUTHORS}\n* ${RES_STRING}")
endforeach()

## managing license
if(${PROJECT_NAME}_LICENSE)
	set(PACKAGE_LICENSE_FOR_SITE ${${PROJECT_NAME}_LICENSE})
	file(READ ${CMAKE_SOURCE_DIR}/license.txt PACKAGE_LICENSE_TEXT_IN_SITE)#getting the text of the license to put into a markdown file for clean printing
else()
	set(PACKAGE_LICENSE_FOR_SITE "No license Defined")
endif()

# following data will always be empty or false for external packages wrappers

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
if(BUILD_COVERAGE_REPORT AND PROJECT_RUN_TESTS)
set(PACKAGE_HAS_COVERAGE true)
else()
set(PACKAGE_HAS_COVERAGE false)
endif()
if(BUILD_STATIC_CODE_CHECKING_REPORT)
set(PACKAGE_HAS_STATIC_CHECKS true)
else()
set(PACKAGE_HAS_STATIC_CHECKS false)
endif()

endmacro(configure_Static_Site_Generation_Variables)

### package site pages generation
function(configure_Package_Pages)
if(NOT ${CMAKE_BUILD_TYPE} MATCHES Release)
	return()
endif()
if(NOT ${PROJECT_NAME}_FRAMEWORK AND NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS) #no web site definition simply exit
	#no static site definition done so we create a fake "site" command in realease mode
	add_custom_target(site
		COMMAND ${CMAKE_COMMAND} -E  echo "No specification of a static site in the project, use the declare_PID_Publishing function in the root CMakeLists.txt file of the project"
	)
	return()
endif()

set(PATH_TO_SITE ${CMAKE_BINARY_DIR}/site)
if(EXISTS ${PATH_TO_SITE}) # delete the content that has to be copied to the site source folder
	file(REMOVE_RECURSE ${PATH_TO_SITE})
endif()
file(MAKE_DIRECTORY ${PATH_TO_SITE}) # create the site root site directory
set(PATH_TO_SITE_PAGES ${PATH_TO_SITE}/pages)
file(MAKE_DIRECTORY ${PATH_TO_SITE_PAGES}) # create the pages directory

#0) prepare variables used for files generations (it is a macro to keep variable defined in the current scope, important for next calls)
configure_Static_Site_Generation_Variables()

#1) generate the data files for jekyll (vary depending on the site creation mode
if(${PROJECT_NAME}_SITE_GIT_ADDRESS) #the package is outside any framework
	generate_Static_Site_Data_Files(${PATH_TO_SITE})

else() #${PROJECT_NAME}_FRAMEWORK is defining a framework for the package
	#find the framework in workspace
	check_Framework(FRAMEWORK_OK ${${PROJECT_NAME}_FRAMEWORK})
	if(NOT FRAMEWORK_OK)
		message(FATAL_ERROR "[PID] ERROR : the framework you specified (${${PROJECT_NAME}_FRAMEWORK}) is unknown in the workspace.")
		return()
	endif()
	generate_Package_Page_Index_In_Framework(${PATH_TO_SITE}) # create index page
endif()

# common generation process between framework and lone static sites

#2) generate pages
generate_Static_Site_Pages(${PATH_TO_SITE_PAGES})

endfunction(configure_Package_Pages)

## generate the section of md file to describe native package dependencies
function(generate_Dependency_Site dependency RES_CONTENT)
if(${dependency}_SITE_ROOT_PAGE)
	set(RES "+ [${dependency}](${${dependency}_SITE_ROOT_PAGE})") #creating a link to the package site
elseif(${dependency}_FRAMEWORK) #the package belongs to a framework, creating a link to this page in the framework
	if(NOT ${${dependency}_FRAMEWORK}_FRAMEWORK_SITE) #getting framework online site
		if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferFramework${${dependency}_FRAMEWORK}.cmake)
			include (${WORKSPACE_DIR}/share/cmake/references/ReferFramework${${dependency}_FRAMEWORK}.cmake) #get the information about the framework
		endif()
	endif()

	if(${${dependency}_FRAMEWORK}_FRAMEWORK_SITE) #get the information about the framework
		set(RES "+ [${dependency}](${${${dependency}_FRAMEWORK}_FRAMEWORK_SITE}/packages/${dependency})")
	else()#in case of a problem (framework unknown), do not create the link
		set(RES "+ ${dependency}")
	endif()
else()# the dependency has no documentation site
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
endfunction(generate_Dependency_Site)

## generate the section of md file to describe external package dependencies
function(generate_External_Dependency_Site dependency RES_CONTENT)
if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferExternal${dependency}.cmake)
	include (${WORKSPACE_DIR}/share/cmake/references/ReferExternal${dependency}.cmake) #get the information about the framework
endif()
if(${dependency}_FRAMEWORK)
	if(NOT ${${dependency}_FRAMEWORK}_FRAMEWORK_SITE)#getting framework online site
		if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferFramework${${dependency}_FRAMEWORK}.cmake)
			include (${WORKSPACE_DIR}/share/cmake/references/ReferFramework${${dependency}_FRAMEWORK}.cmake) #get the information about the framework
		endif()
	endif()
	if(${${dependency}_FRAMEWORK}_FRAMEWORK_SITE)
		set(RES "+ [${dependency}](${${${dependency}_FRAMEWORK}_FRAMEWORK_SITE}/external/${dependency})")
	else()#in case of a problem (framework unknown, problem in framework description), do not create the link
		set(RES "+ ${dependency}")
	endif()
else()
	set(RES "+ ${dependency}")
endif()
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


## generate the section of md file to describe a component of the package
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

# managing component special content
if(${PROJECT_NAME}_${component}_SITE_CONTENT_FILE)
test_Site_Content_File(FILE_NAME EXTENSION ${${PROJECT_NAME}_${component}_SITE_CONTENT_FILE})
	if(FILE_NAME)
		set(RES "${RES}### Details\n")
		set(RES "${RES}Please look at [this page](${FILE_NAME}.html) to get more information.\n")
		set(RES "${RES}\n")
	endif()
endif()


# managing component dependencies
is_HeaderFree_Component(IS_HF ${PROJECT_NAME} ${component})
if(NOT IS_HF)
	#export possible only for libraries with headers
	set(EXPORTS_SOMETHING FALSE)
	set(EXPORTED_DEPS)
	set(INT_EXPORTED_DEPS)
	set(EXT_EXPORTED_DEPS)
	foreach(a_int_dep IN LISTS ${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES)# loop on the component internal dependencies
		if(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${a_int_dep})
			set(EXPORTS_SOMETHING TRUE)
			list(APPEND INT_EXPORTED_DEPS ${a_int_dep})
		endif()
	endforeach()

	foreach(a_pack IN LISTS ${PROJECT_NAME}_${component}_DEPENDENCIES)# loop on the component dependencies
		set(${a_pack}_EXPORTED FALSE)
		foreach(a_comp IN LISTS ${PROJECT_NAME}_${component}_DEPENDENCY_${a_pack}_COMPONENTS)
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

	foreach(inc IN LISTS ${PROJECT_NAME}_${component}_INC_DIRS)# the component export some external dependencies
		string(REGEX REPLACE "^<([^>]+)>.*$" "\\1" RES_EXT_PACK ${inc})
		if(NOT RES_EXT_PACK STREQUAL "${inc}")#match !!
			set(EXPORTS_SOMETHING TRUE)
			if(NOT ${RES_EXT_PACK}_EXPORTED)
				set(${RES_EXT_PACK}_EXPORTED TRUE)
				list(APPEND EXT_EXPORTED_DEPS ${RES_EXT_PACK})
			endif()
		endif()
	endforeach()

	if(EXPORTS_SOMETHING) #defines those dependencies that are exported
		set(RES "${RES}\n### exported dependencies:\n")
		if(INT_EXPORTED_DEPS)
			set(RES "${RES}+ from this package:\n")
			foreach(a_dep IN LISTS INT_EXPORTED_DEPS)
				format_PID_Identifier_Into_Markdown_Link(RES_STR "${a_dep}")
				set(RES "${RES}\t* [${a_dep}](#${RES_STR})\n")
			endforeach()
			set(RES "${RES}\n")
		endif()
		foreach(a_pack IN LISTS EXPORTED_DEPS)
			#defining the target documentation page of the package
			if(${a_pack}_SITE_ROOT_PAGE)
				set(TARGET_PAGE ${${a_pack}_SITE_ROOT_PAGE})
			elseif(${a_pack}_FRAMEWORK AND ${${a_pack}_FRAMEWORK}_FRAMEWORK_SITE)
				set(TARGET_PAGE ${${${a_pack}_FRAMEWORK}_FRAMEWORK_SITE}/packages/${a_pack})
			else()
				set(TARGET_PAGE)
			endif()
			if(TARGET_PAGE)
				set(RES "${RES}+ from package [${a_pack}](${TARGET_PAGE}):\n")
			else()
				set(RES "${RES}+ from package **${a_pack}**:\n")
			endif()
			foreach(a_dep IN LISTS EXPORTED_DEP_${a_pack})
				if(TARGET_PAGE)# the package to which the component belong has a static site defined
					format_PID_Identifier_Into_Markdown_Link(RES_STR "${a_dep}")
					set(RES "${RES}\t* [${a_dep}](${TARGET_PAGE}/pages/use.html#${RES_STR})\n")
				else()
					set(RES "${RES}\t* ${a_dep}\n")
				endif()
			endforeach()
			set(RES "${RES}\n")
		endforeach()

		foreach(a_pack IN LISTS EXT_EXPORTED_DEPS)
			if(${a_pack}_FRAMEWORK AND ${${a_pack}_FRAMEWORK}_FRAMEWORK_SITE)
				set(TARGET_PAGE ${${${a_pack}_FRAMEWORK}_FRAMEWORK_SITE}/external/${a_pack})
			else()
				set(TARGET_PAGE)
			endif()
			if(TARGET_PAGE)
				set(RES "${RES}+ external package [${a_pack}](${TARGET_PAGE})\n")
			else()
				set(RES "${RES}+ external package **${a_pack}**\n")
			endif()
		endforeach()
		set(RES "${RES}\n")
	endif()

	set(RES "${RES}### include directive :\n")
	if(${PROJECT_NAME}_${component}_USAGE_INCLUDES)
		set(RES "${RES}In your code using the library:\n\n")
		set(RES "${RES}{% highlight cpp %}\n")
		foreach(include_file IN LISTS ${PROJECT_NAME}_${component}_USAGE_INCLUDES)
			set(RES "${RES}#include <${include_file}>\n")
		endforeach()
		set(RES "${RES}{% endhighlight %}\n")
	else()
		set(RES "${RES}Not specified (dangerous). You can try including any or all of these headers:\n\n")
		set(RES "${RES}{% highlight cpp %}\n")
		foreach(include_file IN LISTS ${PROJECT_NAME}_${component}_HEADERS)
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
function(create_Local_Static_Site_Project SUCCESS package repo_addr push_site package_url site_url)
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
	set(PACKAGE_PROJECT_URL ${package_url})
	set(PACKAGE_SITE_URL ${site_url})
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

### update the local site
function(update_Local_Static_Site_Project package package_url site_url)
update_Static_Site_Repository(${package}) # updating the repository from git
#reconfigure the root CMakeLists and README to automatically manage evolution in PID
set(PACKAGE_NAME ${package})
set(PACKAGE_PROJECT_URL ${package_url})
set(PACKAGE_SITE_URL ${site_url})
configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/CMakeLists.txt.in ${WORKSPACE_DIR}/sites/packages/${package}/CMakeLists.txt @ONLY)#modifying the cmake project file to the static site project
endfunction(update_Local_Static_Site_Project)

### checking if the package static site repository exists in the workspace
function(static_Site_Project_Exists SITE_EXISTS PATH_TO_SITE package)
set(SEARCH_PATH ${WORKSPACE_DIR}/sites/packages/${package})
if(EXISTS ${SEARCH_PATH} AND IS_DIRECTORY ${SEARCH_PATH})
	set(${SITE_EXISTS} TRUE PARENT_SCOPE)
else()
	set(${SITE_EXISTS} FALSE PARENT_SCOPE)
endif()
set(${PATH_TO_SITE} ${SEARCH_PATH} PARENT_SCOPE)
endfunction(static_Site_Project_Exists)


### copying documentation content to the site repository
function(produce_Static_Site_Content package framework version platform include_api_doc include_coverage include_staticchecks include_installer force) # copy everything needed
#### preparing the copy depending on the target: lone static site or framework ####
if(framework AND NOT framework STREQUAL "")
	set(TARGET_PACKAGE_PATH ${WORKSPACE_DIR}/sites/frameworks/${framework}/src/_packages/${package})
	set(TARGET_APIDOC_PATH ${TARGET_PACKAGE_PATH}/api_doc)
	set(TARGET_COVERAGE_PATH ${TARGET_PACKAGE_PATH}/coverage)
	set(TARGET_STATICCHECKS_PATH ${TARGET_PACKAGE_PATH}/static_checks)
	set(TARGET_BINARIES_PATH ${TARGET_PACKAGE_PATH}/binaries/${version}/${platform})
	set(TARGET_PAGES_PATH ${TARGET_PACKAGE_PATH}/pages)
	set(TARGET_POSTS_PATH ${WORKSPACE_DIR}/sites/frameworks/${framework}/src/_posts)

else()#it is a lone static site
	set(TARGET_PACKAGE_PATH ${WORKSPACE_DIR}/sites/packages/${package}/src)
	set(TARGET_APIDOC_PATH ${TARGET_PACKAGE_PATH}/api_doc)
	set(TARGET_COVERAGE_PATH ${TARGET_PACKAGE_PATH}/coverage)
	set(TARGET_STATICCHECKS_PATH ${TARGET_PACKAGE_PATH}/static_checks)
	set(TARGET_BINARIES_PATH ${TARGET_PACKAGE_PATH}/_binaries/${version}/${platform})
	set(TARGET_PAGES_PATH ${TARGET_PACKAGE_PATH}/pages)
	set(TARGET_POSTS_PATH ${TARGET_PACKAGE_PATH}/_posts)
endif()

######### copy the API doxygen documentation ##############
set(NEW_POST_CONTENT_API_DOC FALSE)
if(include_api_doc
	AND EXISTS ${WORKSPACE_DIR}/packages/${package}/build/release/share/doc/html) # #may not exists if the make doc command has not been launched
	set(ARE_SAME FALSE)
	if(NOT force)#only do this heavy check if the generation is not forced
		test_Same_Directory_Content(${WORKSPACE_DIR}/packages/${package}/build/release/share/doc/html ${TARGET_APIDOC_PATH} ARE_SAME)
	endif()
	if(NOT ARE_SAME)
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${TARGET_APIDOC_PATH})#delete API doc folder
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/packages/${package}/build/release/share/doc/html  ${TARGET_APIDOC_PATH})#recreate the api_doc folder from the one generated by the package
	set(NEW_POST_CONTENT_API_DOC TRUE)
	endif()
endif()

######### copy the coverage report ##############
set(NEW_POST_CONTENT_COVERAGE FALSE)
if(include_coverage
	AND EXISTS ${WORKSPACE_DIR}/packages/${package}/build/debug/share/coverage_report)# #may not exists if the make coverage command has not been launched
	set(ARE_SAME FALSE)
	if(NOT force)#only do this heavy check if the generation is not forced
		test_Same_Directory_Content(${WORKSPACE_DIR}/packages/${package}/build/debug/share/coverage_report ${TARGET_COVERAGE_PATH} ARE_SAME)
	endif()
	if(NOT ARE_SAME)
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${TARGET_COVERAGE_PATH} ERROR_QUIET OUTPUT_QUIET)#delete coverage report folder
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/packages/${package}/build/debug/share/coverage_report ${TARGET_COVERAGE_PATH})#recreate the coverage folder from the one generated by the package
	set(NEW_POST_CONTENT_COVERAGE TRUE)
	endif()
endif()

######### copy the static check report ##############
set(NEW_POST_CONTENT_STATICCHECKS FALSE)
if(include_staticchecks
	AND EXISTS ${WORKSPACE_DIR}/packages/${package}/build/release/share/static_checks_report) #may not exists if the make staticchecks command has not been launched
	set(ARE_SAME FALSE)
	if(NOT force)#only do this heavy check if the generation is not forced
		test_Same_Directory_Content(${WORKSPACE_DIR}/packages/${package}/build/release/share/static_checks_report ${TARGET_STATICCHECKS_PATH} ARE_SAME)
	endif()
	if(NOT ARE_SAME)
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${TARGET_STATICCHECKS_PATH} ERROR_QUIET OUTPUT_QUIET)#delete static checks report folder
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/packages/${package}/build/release/share/static_checks_report ${TARGET_STATICCHECKS_PATH})#recreate the static_checks folder from the one generated by the package
	set(NEW_POST_CONTENT_STATICCHECKS TRUE)
	endif()
endif()

######### copy the new binaries ##############
set(NEW_POST_CONTENT_BINARY FALSE)
if(	include_installer
	AND EXISTS ${WORKSPACE_DIR}/packages/${package}/build/release/${package}-${version}-${platform}.tar.gz
	AND NOT EXISTS ${TARGET_BINARIES_PATH})
	# update the site content only if necessary
	file(MAKE_DIRECTORY ${TARGET_BINARIES_PATH})#create the target folder

	file(COPY ${WORKSPACE_DIR}/packages/${package}/build/release/${package}-${version}-${platform}.tar.gz
	${WORKSPACE_DIR}/packages/${package}/build/debug/${package}-${version}-dbg-${platform}.tar.gz
	DESTINATION  ${TARGET_BINARIES_PATH})#copy the release archive

	if(EXISTS ${WORKSPACE_DIR}/packages/${package}/build/debug/${package}-${version}-dbg-${platform}.tar.gz)#copy debug archive if it exist
			file(COPY ${WORKSPACE_DIR}/packages/${package}/build/debug/${package}-${version}-dbg-${platform}.tar.gz
			DESTINATION  ${TARGET_BINARIES_PATH})#copy the binaries
	endif()
	# configure the file used to reference the binary in jekyll
	set(BINARY_PACKAGE ${package})
	set(BINARY_VERSION ${version})
	set(BINARY_PLATFORM ${platform})
	configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/binary.md.in ${TARGET_BINARIES_PATH}/binary.md @ONLY)#adding to the static site project the markdown file describing the binary package (to be used by jekyll)

	set(NEW_POST_CONTENT_BINARY TRUE)
endif()

######### copy the license file (only for lone static sites, framework have their own) ##############
if(NOT framework OR framework STREQUAL "")
	set(ARE_SAME FALSE)
	if(NOT force)#only do this heavy check if the generation is not forced
		test_Same_File_Content(${WORKSPACE_DIR}/packages/${package}/license.txt ${WORKSPACE_DIR}/sites/packages/${package}/license.txt ARE_SAME)
	endif()
	if(NOT ARE_SAME)
		execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${WORKSPACE_DIR}/packages/${package}/license.txt  ${WORKSPACE_DIR}/sites/packages/${package})#copy the up to date license file into site repository
	endif()
endif()

######### copy the documentation content ##############
set(NEW_POST_CONTENT_PAGES FALSE)
# 1) copy content from source into the binary dir
if(EXISTS ${WORKSPACE_DIR}/packages/${package}/share/site AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/share/site)
	#copy the content of the site source share folder of the package (user defined pages, documents and images) to the package final site in build tree
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/packages/${package}/share/site ${WORKSPACE_DIR}/packages/${package}/build/release/site/pages)
endif()

# 2) if content is new (either generated or user defined) then clean the site and copy the content to the site repository
set(ARE_SAME FALSE)
if(NOT force)#only do this heavy check if the generation is not forced
	test_Same_Directory_Content(${WORKSPACE_DIR}/packages/${package}/build/release/site/pages ${TARGET_PAGES_PATH} ARE_SAME)
endif()

if(NOT ARE_SAME)
	# clean the source folder content
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${TARGET_PAGES_PATH})#delete all pages
	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${TARGET_PAGES_PATH})# recreate the pages folder
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/packages/${package}/build/release/site ${TARGET_PACKAGE_PATH})# copy content from binary dir to site repository source dir
	set(NEW_POST_CONTENT_PAGES TRUE)
else()
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${WORKSPACE_DIR}/packages/${package}/build/release/site/index.html ${TARGET_PACKAGE_PATH})# copy content from binary dir to site repository source dir
endif()


######### configure the post used to describe the update ##############
string(TIMESTAMP POST_DATE "%Y-%m-%d" UTC)
string(TIMESTAMP POST_HOUR "%H-%M-%S" UTC)
set(POST_FILENAME "${POST_DATE}-${POST_HOUR}-${package}-${version}-${platform}-update.markdown")
set(POST_PACKAGE ${package})
if(force)
	set(POST_TITLE "The update of package ${package} has been forced !")
else()
	set(POST_TITLE "package ${package} has been updated !")
endif()
set(POST_UPDATE_STRING "")
if(NEW_POST_CONTENT_API_DOC)
	set(POST_UPDATE_STRING "${POST_UPDATE_STRING}### The doxygen API documentation has been updated for version ${version}\n\n")
endif()
if(NEW_POST_CONTENT_COVERAGE)
	set(POST_UPDATE_STRING "${POST_UPDATE_STRING}### The coverage report has been updated for version ${version}\n\n")
endif()
if(NEW_POST_CONTENT_STATICCHECKS)
	set(POST_UPDATE_STRING "${POST_UPDATE_STRING}### The static checks report has been updated for version ${version}\n\n")
endif()
if(NEW_POST_CONTENT_BINARY)
	set(POST_UPDATE_STRING "${POST_UPDATE_STRING}### A binary version of the package targetting ${platform} platform has been added for version ${version}\n\n")
endif()
if(NEW_POST_CONTENT_PAGES)
	set(POST_UPDATE_STRING "${POST_UPDATE_STRING}### The pages documenting the package have been updated\n\n")
endif()
if(NOT POST_UPDATE_STRING STREQUAL "") #do not generate a post if there is nothing to say (sanity check)
	configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/post.markdown.in ${TARGET_POSTS_PATH}/${POST_FILENAME} @ONLY)#adding to the static site project the markdown file used as a post on the site
endif()
endfunction(produce_Static_Site_Content)

### building the static site simply consists in calling adequately the repository project adequate build commands
function (build_Static_Site package framework)
if(framework AND NOT framework STREQUAL "")
	execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR}/sites/frameworks/${framework} WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
	execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} build WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
else()
	execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR}/sites/packages/${package} WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package}/build)
	execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} build WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package}/build)
endif()
endfunction(build_Static_Site)

#####################################################################
###################Framework usage functions ########################
#####################################################################

### Get the root address of the package page (either if it belongs to a framework or has its own lone static site)
function(get_Package_Site_Address SITE_ADDRESS package)
set(${SITE_ADDRESS} PARENT_SCOPE)
if(${package}_FRAMEWORK) #package belongs to a framework
	if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferFramework${${package}_FRAMEWORK}.cmake)
		include(${WORKSPACE_DIR}/share/cmake/references/ReferFramework${${package}_FRAMEWORK}.cmake)
		set(${SITE_ADDRESS} ${${${package}_FRAMEWORK}_FRAMEWORK_SITE}/packages/${package} PARENT_SCOPE)
	endif()
elseif(${package}_SITE_GIT_ADDRESS AND ${package}_SITE_ROOT_PAGE)
	set(${SITE_ADDRESS} ${${package}_SITE_ROOT_PAGE} PARENT_SCOPE)
endif()
endfunction(get_Package_Site_Address)

###
function(framework_Reference_Exists_In_Workspace EXIST framework)
	if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferFramework${framework}.cmake)
		set(${EXIST} TRUE PARENT_SCOPE)
	else()
		set(${EXIST} FALSE PARENT_SCOPE)
	endif()
endfunction(framework_Reference_Exists_In_Workspace)

### checking if the framework site repository exists in the workspace
function(framework_Project_Exists SITE_EXISTS PATH_TO_SITE framework)
set(SEARCH_PATH ${WORKSPACE_DIR}/sites/frameworks/${framework})
if(EXISTS ${SEARCH_PATH} AND IS_DIRECTORY ${SEARCH_PATH})
	set(${SITE_EXISTS} TRUE PARENT_SCOPE)
else()
	set(${SITE_EXISTS} FALSE PARENT_SCOPE)
endif()
set(${PATH_TO_SITE} ${SEARCH_PATH} PARENT_SCOPE)
endfunction(framework_Project_Exists)

### checking that the given framework exists
function(check_Framework CHECK_OK framework)
	framework_Reference_Exists_In_Workspace(REF_EXIST ${framework})
	if(REF_EXIST)
		include(${WORKSPACE_DIR}/share/cmake/references/ReferFramework${framework}.cmake)
		set(${CHECK_OK} TRUE PARENT_SCOPE)
		return()
	else()
		framework_Project_Exists(FOLDER_EXISTS PATH_TO_SITE ${framework})
		if(FOLDER_EXISTS)#generate the reference file on demand
			execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} referencing WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
			framework_Reference_Exists_In_Workspace(REF_EXIST ${framework})
			if(REF_EXIST)
				include(${WORKSPACE_DIR}/share/cmake/references/ReferFramework${framework}.cmake)
				set(${CHECK_OK} TRUE PARENT_SCOPE)
				return()
			endif()
		endif()
	endif()
	set(${CHECK_OK} FALSE PARENT_SCOPE)
endfunction(check_Framework)

### putting the framework repository into the workspace, or update it if it is already there
function(load_Framework LOADED framework)
	set(${LOADED} FALSE PARENT_SCOPE)
	set(FOLDER_EXISTS FALSE)
	framework_Reference_Exists_In_Workspace(REF_EXIST ${framework})
	if(REF_EXIST)
		include(${WORKSPACE_DIR}/share/cmake/references/ReferFramework${framework}.cmake)
	endif()

	framework_Project_Exists(FOLDER_EXISTS PATH_TO_SITE ${framework})
	if(FOLDER_EXISTS)
		message("[PID] INFO: updating framework ${framework} (this may take a long time)")
		update_Framework_Repository(${framework}) #update the repository to be sure to work on last version
		if(NOT REF_EXIST) #if reference file does not exist we use the project present in the workspace. This way we may force it to generate references
			execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} referencing WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
			framework_Reference_Exists_In_Workspace(REF_EXIST ${framework})
			if(REF_EXIST)
				include(${WORKSPACE_DIR}/share/cmake/references/ReferFramework${framework}.cmake)
				set(${LOADED} TRUE PARENT_SCOPE)
			endif()
		else()
			set(${LOADED} TRUE PARENT_SCOPE)
		endif()
	elseif(REF_EXIST) #we can try to clone it if we know where to clone from
		message("[PID] INFO: deploying framework ${framework} in workspace (this may take a long time)")
		deploy_Framework_Repository(IS_DEPLOYED ${framework})
		if(IS_DEPLOYED)
			set(${LOADED} TRUE PARENT_SCOPE)
		endif()
	endif()
endfunction(load_Framework)

###
function(get_Framework_Site framework SITE)
set(${SITE} ${${framework}_FRAMEWORK_SITE} PARENT_SCOPE)
endfunction(get_Framework_Site)



################################################################################
################## External package wrapper related functions ##################
################################################################################

###
function(generate_Wrapper_Readme_Files)
set(README_CONFIG_FILE ${WORKSPACE_DIR}/share/patterns/wrappers/README.md.in)
## introduction (more detailed description, if any)
get_Wrapper_Site_Address(ADDRESS ${PROJECT_NAME})
if(NOT ADDRESS)#no site description has been provided nor framework reference
	# intro
	set(README_OVERVIEW "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided by site use the short one
	# no reference to site page
	set(WRAPPER_SITE_REF_IN_README "")

	# simplified install section
	set(INSTALL_USE_IN_README "The procedures for installing the ${PROJECT_NAME} wrapper and for using its components is based on the [PID](http://pid.lirmm.net/pid-framework/pages/install.html) build and deployment system called PID. Just follow and read the links to understand how to install, use and call its API and/or applications.")
else()
	# intro
	generate_Formatted_String("${${PROJECT_NAME}_SITE_INTRODUCTION}" RES_INTRO)
	if("${RES_INTRO}" STREQUAL "")
		set(README_OVERVIEW "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided by site description use the short one
	else()
		set(README_OVERVIEW "${RES_INTRO}") #otherwise use detailed one specific for site
	endif()

	# install procedure
	set(INSTALL_USE_IN_README "The procedures for installing the ${PROJECT_NAME} wrapper and for using its components is available in this [site][package_site]. It is based on a CMake based build and deployment system called [PID](http://pid.lirmm.net/pid-framework/pages/install.html). Just follow and read the links to understand how to install, use and call its API and/or applications.")

	# reference to site page
	set(WRAPPER_SITE_REF_IN_README "[package_site]: ${ADDRESS} \"${PROJECT_NAME} wrapper\"
")
endif()

if(${PROJECT_NAME}_LICENSE)
	set(WRAPPER_LICENSE_FOR_README "The license that applies to the PID wrapper content (Cmake files mostly) is **${${PROJECT_NAME}_LICENSE}**. Please look at the license.txt file at the root of this repository. The content generated by the wrapper being based on third party code it is subject to the licenses that apply for the ${PROJECT_NAME} project ")
else()
	set(WRAPPER_LICENSE_FOR_README "The wrapper has no license defined yet.")
endif()

set(README_USER_CONTENT "")
if(${PROJECT_NAME}_USER_README_FILE AND EXISTS ${CMAKE_SOURCE_DIR}/share/${${PROJECT_NAME}_USER_README_FILE})
	file(READ ${CMAKE_SOURCE_DIR}/share/${${PROJECT_NAME}_USER_README_FILE} CONTENT_OF_README)
	set(README_USER_CONTENT "${CONTENT_OF_README}")
endif()

set(README_AUTHORS_LIST "")
foreach(author IN LISTS ${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS)
	generate_Full_Author_String(${author} STRING_TO_APPEND)
	set(README_AUTHORS_LIST "${README_AUTHORS_LIST}\n+ ${STRING_TO_APPEND}")
endforeach()

get_Formatted_Package_Contact_String(${PROJECT_NAME} RES_STRING)
set(README_CONTACT_AUTHOR "${RES_STRING}")

configure_file(${README_CONFIG_FILE} ${CMAKE_SOURCE_DIR}/README.md @ONLY)#put the readme in the source dir
endfunction(generate_Wrapper_Readme_Files)

### generating the license file used in wrapper (differs a bit from those of the native packages)
function(generate_Wrapper_License_File)
if(	DEFINED ${PROJECT_NAME}_LICENSE
	AND NOT ${${PROJECT_NAME}_LICENSE} STREQUAL "")

	find_file(LICENSE_IN
			"License${${PROJECT_NAME}_LICENSE}.cmake"
			PATH "${WORKSPACE_DIR}/share/cmake/licenses"
			NO_DEFAULT_PATH
		)
	if(LICENSE_IN STREQUAL LICENSE_IN-NOTFOUND)
		message("[PID] WARNING : license configuration file for ${${PROJECT_NAME}_LICENSE} not found in workspace, license file will not be generated")
	else()

		#prepare license generation
		set(${PROJECT_NAME}_FOR_LICENSE "${PROJECT_NAME} PID Wrapper")
		set(${PROJECT_NAME}_DESCRIPTION_FOR_LICENSE ${${PROJECT_NAME}_DESCRIPTION})
		set(${PROJECT_NAME}_YEARS_FOR_LICENSE ${${PROJECT_NAME}_YEARS})
		foreach(author IN LISTS ${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS)
			generate_Full_Author_String(${author} STRING_TO_APPEND)
			set(${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE "${${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE} ${STRING_TO_APPEND}")
		endforeach()

		include(${WORKSPACE_DIR}/share/cmake/licenses/License${${PROJECT_NAME}_LICENSE}.cmake)
		file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
	endif()
endif()
endfunction(generate_Wrapper_License_File)


### create the index file for wrapper in the framework
function(generate_Wrapper_Page_Index_In_Framework generated_site_folder)
configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/index_wrapper.html.in ${generated_site_folder}/index.html @ONLY)
endfunction(generate_Wrapper_Page_Index_In_Framework)


### package site pages generation
function(configure_Wrapper_Pages)
if(NOT ${PROJECT_NAME}_FRAMEWORK AND NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS) #no web site definition simply exit
	#no static site definition done so we create a fake "site" command in realease mode
	add_custom_target(site
		COMMAND ${CMAKE_COMMAND} -E  echo "No specification of a static site in the project, use the declare_PID_Publishing function in the root CMakeLists.txt file of the project"
	)
	return()
endif()

set(PATH_TO_SITE ${CMAKE_BINARY_DIR}/site)
if(EXISTS ${PATH_TO_SITE}) # delete the content that has to be copied to the site source folder
	file(REMOVE_RECURSE ${PATH_TO_SITE})
endif()
file(MAKE_DIRECTORY ${PATH_TO_SITE}) # create the site root site directory
set(PATH_TO_SITE_PAGES ${PATH_TO_SITE}/pages)
file(MAKE_DIRECTORY ${PATH_TO_SITE_PAGES}) # create the pages directory

#0) prepare variables used for files generations (it is a macro to keep variable defined in the current scope, important for next calls)
configure_Static_Site_Generation_Variables()

#1) generate the data files for jekyll (vary depending on the site creation mode
if(${PROJECT_NAME}_SITE_GIT_ADDRESS) #the package is outside any framework
	generate_Static_Site_Data_Files(${PATH_TO_SITE})

else() #${PROJECT_NAME}_FRAMEWORK is defining a framework for the package
	#find the framework in workspace
	check_Framework(FRAMEWORK_OK ${${PROJECT_NAME}_FRAMEWORK})
	if(NOT FRAMEWORK_OK)
		message(FATAL_ERROR "[PID] ERROR : the framework you specified (${${PROJECT_NAME}_FRAMEWORK}) is unknown in the workspace.")
		return()
	endif()
	generate_Wrapper_Page_Index_In_Framework(${PATH_TO_SITE}) # create index page
endif()

# common generation process between framework and lone static sites

#2) generate pages
generate_Static_Site_Pages(${PATH_TO_SITE_PAGES})

endfunction(configure_Wrapper_Pages)
