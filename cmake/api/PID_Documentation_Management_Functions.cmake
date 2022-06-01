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
include(PID_Static_Site_Management_Functions NO_POLICY_SCOPE)


################################################################################
#################### common function between native and wrapper ################
################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Static_Site_Jekyll_Data_File| replace:: ``generate_Static_Site_Jekyll_Data_File``
#  .. _generate_Static_Site_Jekyll_Data_File:
#
#  generate_Static_Site_Jekyll_Data_File
#  -------------------------------------
#
#   .. command:: generate_Static_Site_Jekyll_Data_File(generated_site_folder)
#
#     Generate the configuration file for a lone static site (either for an external package wrapper or for a native package).
#
#      :generated_site_folder: path to the folder that contains generated site pages.
#
function(generate_Static_Site_Jekyll_Data_File generated_site_folder)
#generating the data file for package site description
file(MAKE_DIRECTORY ${generated_site_folder}/_data) # create the _data folder to put configuration files inside
configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/package.yml.in ${generated_site_folder}/_data/package.yml @ONLY)
endfunction(generate_Static_Site_Jekyll_Data_File)


################################################################################
######################## Native packages related functions #####################
################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Example_To_Doc| replace:: ``add_Example_To_Doc``
#  .. _add_Example_To_Doc:
#
#  add_Example_To_Doc
#  ------------------
#
#   .. command:: add_Example_To_Doc(c_name)
#
#     Add source code of the example component to the API documentation of current project.
#
#      :c_name: name of the example component.
#
function(add_Example_To_Doc c_name)
	file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/share/doc/examples/)
	file(COPY ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR} DESTINATION ${PROJECT_BINARY_DIR}/share/doc/examples/)
endfunction(add_Example_To_Doc c_name)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_API| replace:: ``generate_API``
#  .. _generate_API:
#
#  generate_API
#  ------------
#
#   .. command:: generate_API()
#
#     Generate the doxygen API documentation for current package project.
#
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
  if(NOT DOXYGEN_EXECUTABLE)
  	message("[PID] WARNING : Doxygen not found please install it to generate the API documentation")
  	return()
  endif()

  find_file(DOXYFILE_IN   "Doxyfile.in"
  			PATHS "${CMAKE_SOURCE_DIR}/share/doxygen"
  			NO_DEFAULT_PATH
  	)

  set(DOXYFILE_PATH)
  if(DOXYFILE_IN MATCHES DOXYFILE_IN-NOTFOUND)
  	find_file(GENERIC_DOXYFILE_IN   "Doxyfile.in"
  					PATHS "${WORKSPACE_DIR}/cmake/patterns/packages"
  					NO_DEFAULT_PATH
  		)
  	if(GENERIC_DOXYFILE_IN MATCHES GENERIC_DOXYFILE_IN-NOTFOUND)
  		message("[PID] WARNING : no doxygen template file found ... skipping documentation generation !!")
  	else()
  		set(DOXYFILE_PATH ${GENERIC_DOXYFILE_IN})
  	endif()
  	unset(GENERIC_DOXYFILE_IN CACHE)
  else()
  	set(DOXYFILE_PATH ${DOXYFILE_IN})
  endif()
  unset(DOXYFILE_IN CACHE)
  if(DOXYFILE_PATH) #we are able to generate the doc
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
    add_custom_target(doxygen-pid
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

  	add_dependencies(doc doxygen-pid)

  	### end new targets ###

  	### doxyfile configuration ###

  	# configuring doxyfile for html generation
  	set(DOXYFILE_GENERATE_HTML "YES")

  	# configuring doxyfile to use dot executable if available
  	set(DOXYFILE_DOT "NO")
    set(DOXYGEN_DOT_PATH)
  	if(DOXYGEN_DOT_EXECUTABLE)
  		set(DOXYFILE_DOT "YES")
      set(DOXYGEN_DOT_PATH ${DOXYGEN_DOT_EXECUTABLE})
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
  		if(LATEX_COMPILER AND MAKEINDEX_COMPILER AND MAKE_TOOL_EXECUTABLE)
  			if(PDFLATEX_COMPILER)
  				set(DOXYFILE_PDFLATEX "YES")
  			endif(PDFLATEX_COMPILER)

  			add_custom_command(TARGET doxygen-pid
  				POST_BUILD
  				COMMAND "${MAKE_TOOL_EXECUTABLE}"
  				COMMENT	"Running LaTeX for Doxygen documentation in ${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_LATEX_DIR}..."
  				WORKING_DIRECTORY "${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_LATEX_DIR}")
  		else()
  			set(DOXYGEN_LATEX "NO")
  		endif()
  	else()
  		set(DOXYFILE_GENERATE_LATEX "NO")
  	endif()

  	#configuring the Doxyfile.in file to generate a doxygen configuration file
  	configure_file(${DOXYFILE_PATH} ${CMAKE_BINARY_DIR}/share/Doxyfile @ONLY)
  	### end doxyfile configuration ###

  	### installing documentation ###
  	install(DIRECTORY ${CMAKE_BINARY_DIR}/share/doc DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})
  	### end installing documentation ###
  else()
    set(BUILD_API_DOC OFF CACHE BOOL "" FORCE)
  endif()
endif()#in release mode
endfunction(generate_API)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_License_File| replace:: ``generate_Package_License_File``
#  .. _generate_Package_License_File:
#
#  generate_Package_License_File
#  -----------------------------
#
#   .. command:: generate_Package_License_File()
#
#     Create the license.txt file for current package project.
#
function(generate_Package_License_File)
if(CMAKE_BUILD_TYPE MATCHES Release)
	if(EXISTS ${CMAKE_SOURCE_DIR}/license.txt)# a license has already been generated
		if(NOT REGENERATE_LICENSE)# avoid regeneration if nothing changed
			return()
		endif()
	endif()

	if(	${PROJECT_NAME}_LICENSE )
    resolve_License_File(PATH_TO_FILE ${${PROJECT_NAME}_LICENSE})
	  if(NOT PATH_TO_FILE)
			message("[PID] WARNING : license configuration file for ${${PROJECT_NAME}_LICENSE} not found in any contribution space installed in workspace, license file will not be generated.")
		else()
			#prepare license generation
			set(${PROJECT_NAME}_FOR_LICENSE ${PROJECT_NAME})
      generate_Formatted_String("${${PROJECT_NAME}_DESCRIPTION}" ${PROJECT_NAME}_DESCRIPTION_FOR_LICENSE)
			set(${PROJECT_NAME}_YEARS_FOR_LICENSE ${${PROJECT_NAME}_YEARS})
			foreach(author IN LISTS ${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS)
				generate_Full_Author_String(${author} STRING_TO_APPEND)
				set(${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE "${${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE} ${STRING_TO_APPEND}")
			endforeach()
      include(${PATH_TO_FILE})
			file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
			install(FILES ${CMAKE_SOURCE_DIR}/license.txt DESTINATION ${${PROJECT_NAME}_DEPLOY_PATH})
			file(WRITE ${CMAKE_BINARY_DIR}/share/file_header_comment.txt.in ${LICENSE_HEADER_FILE_DESCRIPTION})
		endif()
	endif()
endif()
endfunction(generate_Package_License_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Git_Ignore_File| replace:: ``generate_Package_Git_Ignore_File``
#  .. _generate_Package_Git_Ignore_File:
#
#  generate_Package_Git_Ignore_File
#  --------------------------------
#
#   .. command:: generate_Package_Git_Ignore_File()
#
#     Create/Update the .gitignore file for current package project.
#
function(generate_Package_Git_Ignore_File)

endfunction(generate_Package_Git_Ignore_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Readme_Files| replace:: ``generate_Package_Readme_Files``
#  .. _generate_Package_Readme_Files:
#
#  generate_Package_Readme_Files
#  -----------------------------
#
#   .. command:: generate_Package_Readme_Files()
#
#     Create the README.md file for current package project.
#
function(generate_Package_Readme_Files)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	set(README_CONFIG_FILE ${WORKSPACE_DIR}/cmake/patterns/packages/README.md.in)
	set(APIDOC_WELCOME_CONFIG_FILE ${WORKSPACE_DIR}/cmake/patterns/packages/APIDOC_welcome.md.in)
	## introduction (more detailed description, if any)
	get_Package_Site_Address(ADDRESS ${PROJECT_NAME})

	set(TABLE_OF_CONTENTS)
	set(TABLE_OF_CONTENTS "${TABLE_OF_CONTENTS} - [Package Overview](#package-overview)\n")
	set(TABLE_OF_CONTENTS "${TABLE_OF_CONTENTS} - [Installation and Usage](#installation-and-usage)\n")
	if(ADDRESS)
		set(TABLE_OF_CONTENTS "${TABLE_OF_CONTENTS} - [Online Documentation](#online-documentation)\n")
	endif()
	set(TABLE_OF_CONTENTS "${TABLE_OF_CONTENTS} - [Offline API Documentation](#offline-api-documentation)\n")
	set(TABLE_OF_CONTENTS "${TABLE_OF_CONTENTS} - [License](#license)\n")
	set(TABLE_OF_CONTENTS "${TABLE_OF_CONTENTS} - [Authors](#authors)\n")

	set(ONLINE_DOCUMENTATION_IN_README)

	if(NOT ADDRESS)#no site description has been provided nor framework reference
		# intro
		generate_Formatted_String("${${PROJECT_NAME}_DESCRIPTION}" RES_INTRO)
		set(README_OVERVIEW "${RES_INTRO}") #if no detailed description provided by site use the short one
		# no reference to site page
		set(PACKAGE_SITE_REF_IN_README "")
	else()
		# intro
		generate_Formatted_String("${${PROJECT_NAME}_SITE_INTRODUCTION}" RES_INTRO)
		if(RES_INTRO)
			set(README_OVERVIEW "${RES_INTRO}") #otherwise use detailed one specific for site
		else()
			generate_Formatted_String("${${PROJECT_NAME}_DESCRIPTION}" RES_INTRO)
			set(README_OVERVIEW "${RES_INTRO}") #if no detailed description provided by site description use the short one
		endif()

		# Documentation
		set(ONLINE_DOCUMENTATION_IN_README "${ONLINE_DOCUMENTATION_IN_README}# Online Documentation\n")
		set(ONLINE_DOCUMENTATION_IN_README "${ONLINE_DOCUMENTATION_IN_README}**${PROJECT_NAME}** documentation is available [online](${ADDRESS}).\n")
		set(ONLINE_DOCUMENTATION_IN_README "${ONLINE_DOCUMENTATION_IN_README}You can find:\n")
		test_Site_Content_File(FILE_NAME EXTENSION ${${PROJECT_NAME}_advanced_SITE_CONTENT_FILE})
		if(FILE_NAME)
			set(ONLINE_DOCUMENTATION_IN_README "${ONLINE_DOCUMENTATION_IN_README} * [Advanced topics](${ADDRESS}/pages/${FILE_NAME})\n")
		endif()
		if(BUILD_API_DOC)
			set(ONLINE_DOCUMENTATION_IN_README "${ONLINE_DOCUMENTATION_IN_README} * [API Documentation](${ADDRESS}/api_doc)\n")
		endif()
		if(BUILD_STATIC_CODE_CHECKING_REPORT)
			set(ONLINE_DOCUMENTATION_IN_README "${ONLINE_DOCUMENTATION_IN_README} * [Static checks report (cppcheck)](${ADDRESS}/static_checks)\n")
		endif()
		if(BUILD_COVERAGE_REPORT AND PROJECT_RUN_TESTS)
			set(ONLINE_DOCUMENTATION_IN_README "${ONLINE_DOCUMENTATION_IN_README} * [Coverage report (lcov)](${ADDRESS}/coverage)\n")
		endif()
	endif()

	set(API_DOCUMENTATION_IN_README "${API_DOCUMENTATION_IN_README}With [Doxygen](https://www.doxygen.nl) installed, the API documentation can be built locally by turning the `BUILD_API_DOC` CMake option `ON` and running the `doc` target, e.g\n")
	set(API_DOCUMENTATION_IN_README "${API_DOCUMENTATION_IN_README}```\npid cd ${PROJECT_NAME}\npid -DBUILD_API_DOC=ON doc\n```\n")
	set(API_DOCUMENTATION_IN_README "${API_DOCUMENTATION_IN_README}The resulting documentation can be accessed by opening `<path to ${PROJECT_NAME}>/build/release/share/doc/html/index.html` in a web browser.")

    generate_Package_Content_Documentation(README_PACKAGE_CONTENT ${PROJECT_NAME})

	set(INSTALL_USE_IN_README)
	set(INSTALL_USE_IN_README "${INSTALL_USE_IN_README}The **${PROJECT_NAME}** project is packaged using [PID](http://pid.lirmm.net), a build and deployment system based on CMake.\n\n")
	set(INSTALL_USE_IN_README "${INSTALL_USE_IN_README}If you wish to adopt PID for your develoment please first follow the installation procedure [here](http://pid.lirmm.net/pid-framework/pages/install.html).\n\n")
	set(INSTALL_USE_IN_README "${INSTALL_USE_IN_README}If you already are a PID user or wish to integrate **${PROJECT_NAME}** in your current build system, please read the appropriate section below.\n\n")

	generate_Install_Procedure_Documentation(INSTALL_DOC ${PROJECT_NAME})
	set(INSTALL_USE_IN_README "${INSTALL_USE_IN_README}\n${INSTALL_DOC}")

	if(${PROJECT_NAME}_LICENSE)
		set(PACKAGE_LICENSE_FOR_README "The license that applies to the whole package content is **${${PROJECT_NAME}_LICENSE}**. Please look at the [license.txt](./license.txt) file at the root of this repository for more details.")
	else()
		set(PACKAGE_LICENSE_FOR_README "The package has no license defined yet.")
	endif()

	set(README_USER_CONTENT "")
	if(${PROJECT_NAME}_USER_README_FILE AND EXISTS ${CMAKE_SOURCE_DIR}/share/${${PROJECT_NAME}_USER_README_FILE})
		file(READ ${CMAKE_SOURCE_DIR}/share/${${PROJECT_NAME}_USER_README_FILE} CONTENT_OF_README)
		string(REPLACE @README_TABLE_OF_CONTENTS@ ${TABLE_OF_CONTENTS} CONTENT_OF_README "${CONTENT_OF_README}")
		set(README_USER_CONTENT "${CONTENT_OF_README}")
	else()
		set(README_TABLE_OF_CONTENTS "# Table of Contents\n${TABLE_OF_CONTENTS}")
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Install_Procedure_Documentation| replace:: ``generate_Install_Procedure_Documentation``
#  .. _generate_Install_Procedure_Documentation:
#
#  generate_Install_Procedure_Documentation
#  ----------------------------------------
#
#   .. command:: generate_Install_Procedure_Documentation(RETURNED_INSTALL_DOC package)
#
#     Generate the string describing the install procedure for given package.
#
#      :package: name of the target package.
#
#      :RETURNED_INSTALL_DOC: the output variable containing the string describing the install procedure.
#
function(generate_Install_Procedure_Documentation RETURNED_INSTALL_DOC package)
if(${package}_PUBLIC_ADDRESS OR ${package}_ADDRESS)
  list(LENGTH ${package}_COMPONENTS_LIBS NB_LIBS)
  set(DOC_STR "## Using an existing PID workspace\n")
  set(DOC_STR "${DOC_STR}\nThis method is for developers who want to install and access **${package}** from their PID workspace.\n")
  set(DOC_STR "${DOC_STR}\nYou can use the `deploy` command to manually install **${package}** in the workspace:\n")
  set(DOC_STR "${DOC_STR}```\ncd <path to pid workspace>\npid deploy package=${package} # latest version\n")
  set(DOC_STR "${DOC_STR}# OR\n")
  set(DOC_STR "${DOC_STR}pid deploy package=${package} version=x.y.z # specific version\n```\n")
  if(NB_LIBS GREATER 0)
    set(DOC_STR "${DOC_STR}Alternatively you can simply declare a dependency to **${package}** in your package's `CMakeLists.txt` and let PID handle everything:\n")
    set(DOC_STR "${DOC_STR}```\nPID_Dependency(${package}) # any version\n")
    set(DOC_STR "${DOC_STR}# OR\n")
    set(DOC_STR "${DOC_STR}PID_Dependency(${package} VERSION x.y.z) # any version compatible with x.y.z\n```\n")
	set(DOC_STR "${DOC_STR}\nIf you need more control over your dependency declaration, please look at [PID_Dependency](https://pid.lirmm.net/pid-framework/assets/apidoc/html/pages/Package_API.html#pid-dependency) documentation.\n")
    if(NB_LIBS EQUAL 1)
      list(GET ${package}_COMPONENTS_LIBS 0 COMP_NAME)
      set(DOC_STR "${DOC_STR}\nOnce the package dependency has been added, you can use `${package}/${COMP_NAME}` as a component dependency.\n")
    else()
      set(DOC_STR "${DOC_STR}\nOnce the package dependency has been added, you can use the following components as component dependencies:\n")
      foreach(comp IN LISTS ${package}_COMPONENTS_LIBS)
	  	set(DOC_STR "${DOC_STR} * `${package}/${comp}`\n")
      endforeach()
	endif()
	set(DOC_STR "${DOC_STR}\nYou can read [PID_Component](https://pid.lirmm.net/pid-framework/assets/apidoc/html/pages/Package_API.html#pid-component) and [PID_Component_Dependency](https://pid.lirmm.net/pid-framework/assets/apidoc/html/pages/Package_API.html#pid-component-dependency) documentations for more details.")
  endif()
  set(DOC_STR "${DOC_STR}\n## Standalone installation\n")
  set(DOC_STR "${DOC_STR}\nThis method allows to build the package without having to create a PID workspace manually. This method is UNIX only.\n")
  set(DOC_STR "${DOC_STR}\nAll you need to do is to first clone the package locally and then run the installation script:\n")
  if(${package}_PUBLIC_ADDRESS)
    set(DOC_STR "${DOC_STR} ```\ngit clone ${${package}_PUBLIC_ADDRESS}\ncd ${package}\n")
  elseif(${package}_ADDRESS)
    set(DOC_STR "${DOC_STR} ```\ngit clone ${${package}_ADDRESS}\ncd ${package}\n")
  endif()
  set(DOC_STR "${DOC_STR}./share/install/standalone_install.sh\n```\n")
  set(DOC_STR "${DOC_STR}The package as well as its dependencies will be deployed under `binaries/pid-workspace`.\n\n")
  set(DOC_STR "${DOC_STR}You can pass `--help` to the script to list the available options.\n\n")

  set(DOC_STR "${DOC_STR}### Using **${package}** in a CMake project\n")
  set(DOC_STR "${DOC_STR}There are two ways to integrate **${package}** in CMake project: the external API or a system install.\n\n")
  set(DOC_STR "${DOC_STR}The first one doesn't require the installation of files outside of the package itself and so is well suited when used as a Git submodule for example.\n")
  set(DOC_STR "${DOC_STR}Please read [this page](https://pid.lirmm.net/pid-framework/pages/external_API_tutorial.html#using-cmake) for more information.\n\n")
  set(DOC_STR "${DOC_STR}The second option is more traditional as it installs the package and its dependencies in a given system folder which can then be retrived using `find_package(${package})`.\n")
  set(DOC_STR "${DOC_STR}You can pass the `--install <path>` option to the installation script to perform the installation and then follow [these steps](https://pid.lirmm.net/pid-framework/pages/external_API_tutorial.html#third-step--extra-system-configuration-required) to configure your environment, find PID packages and link with their components.\n")

  if(NB_LIBS GREATER 0)
    set(DOC_STR "${DOC_STR}### Using **${package}** with pkg-config\n")
    set(DOC_STR "${DOC_STR}You can pass `--pkg-config on` to the installation script to generate the necessary pkg-config files.\n")
    set(DOC_STR "${DOC_STR}Upon completion, the script will tell you how to set the `PKG_CONFIG_PATH` environment variable for **${package}** to be discoverable.\n")
    set(DOC_STR "${DOC_STR}\nThen, to get the necessary compilation flags run:\n")

    if(NB_LIBS EQUAL 1)
      list(GET ${package}_COMPONENTS_LIBS 0 COMP_NAME)
      set(DOC_STR "${DOC_STR}\n```\npkg-config --static --cflags ${package}_${COMP_NAME}\n```\n")
      set(DOC_STR "${DOC_STR}\n```\npkg-config --variable=c_standard ${package}_${COMP_NAME}\n```\n")
      set(DOC_STR "${DOC_STR}\n```\npkg-config --variable=cxx_standard ${package}_${COMP_NAME}\n```\n")
      set(DOC_STR "${DOC_STR}\nTo get linker flags run:\n")
      set(DOC_STR "${DOC_STR}\n```\npkg-config --static --libs ${package}_${COMP_NAME}\n```\n")
    else()
      set(DOC_STR "${DOC_STR}\n```\npkg-config --static --cflags ${package}_<component>\n```\n")
      set(DOC_STR "${DOC_STR}\n```\npkg-config --variable=c_standard ${package}_<component>\n```\n")
      set(DOC_STR "${DOC_STR}\n```\npkg-config --variable=cxx_standard ${package}_<component>\n```\n")
      set(DOC_STR "${DOC_STR}\nTo get the linker flags run:\n")
      set(DOC_STR "${DOC_STR}\n```\npkg-config --static --libs ${package}_<component>\n```\n")
      set(DOC_STR "${DOC_STR}\nWhere `<component>` is one of:\n")
      foreach(comp IN LISTS ${package}_COMPONENTS_LIBS)
        set(DOC_STR "${DOC_STR} * `${comp}`\n")
      endforeach()
    endif()
  endif()

  set(INST_STR "Once the package and its dependencies are installed, you can consume it in different ways.\n")
  set(INST_STR "${INST_STR}## From another PID package\n")
  set(INST_STR "${INST_STR}\nSimply add `PID_Dependency(${package})` or `PID_Dependency(PACKAGE VERSION x.y.z)` in your root *CMakeLists.txt* and then declare one of **${package}**'s components as a dependency in your `PID_Component` calls\n")
endif()
set(${RETURNED_INSTALL_DOC} ${DOC_STR} PARENT_SCOPE)
endfunction(generate_Install_Procedure_Documentation)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Content_Documentation| replace:: ``generate_Package_Content_Documentation``
#  .. generate_Package_Content_Documentation:
#
#  generate_Package_Content_Documentation
#  ----------------------------------------
#
#   .. command:: generate_Package_Content_Documentation(RETURNED_CONTENT_DOC package)
#
#     Generate the string describing the content of given package.
#
#      :package: name of the target package.
#
#      :RETURNED_CONTENT_DOC: the output variable containing the string describing its content.
#
function(generate_Package_Content_Documentation RETURNED_CONTENT_DOC package)
  set(PACKAGE_EXECUTABLES)
  set(PACKAGE_EXAMPLES)
  set(PACKAGE_TESTS)
  foreach(comp IN LISTS ${package}_DECLARED_COMPS)
    set(${package}_${comp}_DESCRIPTION_STR)
    if(${package}_${comp}_DESCRIPTION)
      set(${package}_${comp}_DESCRIPTION_STR ": ${${package}_${comp}_DESCRIPTION}")
    endif()
    if(${package}_${comp}_TYPE STREQUAL APP)
      list(APPEND PACKAGE_EXECUTABLES ${comp})
    endif()
    if(${package}_${comp}_TYPE STREQUAL EXAMPLE)
      list(APPEND PACKAGE_EXAMPLES ${comp})
    endif()
    if(${package}_${comp}_TYPE STREQUAL TEST)
      list(APPEND PACKAGE_TESTS ${comp})
    endif()
  endforeach()

  list(LENGTH ${package}_COMPONENTS_LIBS NB_LIBS)
  list(LENGTH PACKAGE_EXECUTABLES NB_APPS)
  list(LENGTH PACKAGE_EXAMPLES NB_EXAMPLES)
  list(LENGTH PACKAGE_TESTS NB_TESTS)
  list(LENGTH ${package}_COMPONENTS_SCRIPTS NB_SCRIPTS)
  list(LENGTH ${package}_ALIASES NB_ALIASES)


  set(DOC_STR "The **${package}** package contains the following:\n")
  if(NB_LIBS GREATER 0)
    set(DOC_STR "${DOC_STR}\n * Libraries:\n")
    foreach(lib IN LISTS ${package}_COMPONENTS_LIBS)
      string(TOLOWER ${${package}_${lib}_TYPE} lib_type)
      set(DOC_STR "${DOC_STR}\n   * ${lib} (${lib_type})${${package}_${lib}_DESCRIPTION_STR}\n")
    endforeach()
  endif()
  if(NB_APPS GREATER 0)
    set(DOC_STR "${DOC_STR}\n * Applications:\n")
    foreach(app IN LISTS PACKAGE_EXECUTABLES)
	  set(DOC_STR "${DOC_STR}\n   * ${app}${${package}_${app}_DESCRIPTION_STR}\n")
    endforeach()
  endif()
  if(NB_SCRIPTS GREATER 0)
    set(DOC_STR "${DOC_STR}\n * Scripts:\n")
    foreach(script IN LISTS ${package}_COMPONENTS_SCRIPTS)
      string(TOLOWER ${${package}_${script}_TYPE} script_type)
      set(DOC_STR "${DOC_STR}\n   * ${script} (${script_type})${${package}_${script}_DESCRIPTION_STR}\n")
    endforeach()
  endif()
  if(NB_EXAMPLES GREATER 0)
    set(DOC_STR "${DOC_STR}\n * Examples:\n")
    foreach(example IN LISTS PACKAGE_EXAMPLES)
      set(DOC_STR "${DOC_STR}\n   * ${example}${${package}_${example}_DESCRIPTION_STR}\n")
    endforeach()
  endif()
  if(NB_TESTS GREATER 0)
    set(DOC_STR "${DOC_STR}\n * Tests:\n")
    foreach(test IN LISTS PACKAGE_TESTS)
      set(DOC_STR "${DOC_STR}\n   * ${test}${${package}_${test}_DESCRIPTION_STR}\n")
    endforeach()
  endif()
  if(NB_ALIASES GREATER 0)
    set(DOC_STR "${DOC_STR}\n * Aliases:\n")
    foreach(alias IN LISTS ${package}_ALIASES)
      set(DOC_STR "${DOC_STR}\n   * ${alias} -> ${${package}_${alias}_IS_ALIAS_OF}\n")
    endforeach()
  endif()
  set(${RETURNED_CONTENT_DOC} ${DOC_STR} PARENT_SCOPE)
endfunction(generate_Package_Content_Documentation)



#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Page_Index_In_Framework| replace:: ``generate_Package_Page_Index_In_Framework``
#  .. _generate_Package_Page_Index_In_Framework:
#
#  generate_Package_Page_Index_In_Framework
#  ----------------------------------------
#
#   .. command:: generate_Package_Page_Index_In_Framework(generated_site_folder)
#
#      Create the index file for target package when it is published in a framework
#
#      :generated_site_folder: path to the folder that contains generated site pages for target package.
#
function(generate_Package_Page_Index_In_Framework generated_site_folder)
configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/index.md.in ${generated_site_folder}/index.md @ONLY)
endfunction(generate_Package_Page_Index_In_Framework)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Static_Site_Page_Introduction| replace:: ``generate_Package_Static_Site_Page_Introduction``
#  .. _generate_Package_Static_Site_Page_Introduction:
#
#  generate_Package_Static_Site_Page_Introduction
#  ----------------------------------------------
#
#   .. command:: generate_Package_Static_Site_Page_Introduction(generated_site_folder)
#
#      Create the introduction page for target package (for framework or lone site).
#
#      :generated_site_folder: path to the folder that contains generated site pages for target package.
#
function(generate_Package_Static_Site_Page_Introduction generated_pages_folder)

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
		generate_External_Dependency_Site(RES_CONTENT_EXTERNAL ${dep_package}
      ${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_ALL_POSSIBLE_VERSIONS
      ${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_ALL_EXACT_VERSIONS)
		set(EXTERNAL_SITE_SECTION "${EXTERNAL_SITE_SECTION}\n${RES_CONTENT_EXTERNAL}")
	endforeach()

	set(PACKAGE_DEPENDENCIES_DESCRIPTION "${EXTERNAL_SITE_SECTION}\n\n${NATIVE_SITE_SECTION}")
endif()

# generating the introduction file for package site
configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/introduction.md.in ${generated_pages_folder}/introduction.md @ONLY)
endfunction(generate_Package_Static_Site_Page_Introduction)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Static_Site_Page_Install| replace:: ``generate_Package_Static_Site_Page_Install``
#  .. _generate_Package_Static_Site_Page_Install:
#
#  generate_Package_Static_Site_Page_Install
#  -----------------------------------------
#
#   .. command:: generate_Package_Static_Site_Page_Install(generated_site_folder)
#
#      Create the HOWTO install page for target package (for framework or lone site).
#
#      :generated_site_folder: path to the folder that contains generated site pages for target package.
#
function(generate_Package_Static_Site_Page_Install generated_pages_folder)

#getting git references of the project (for manual installation explanation)
if(NOT ${PROJECT_NAME}_ADDRESS)#no repository known by default we have no information about it
  set(OFFICIAL_REPOSITORY_ADDRESS "unknown_server:unknown_namespace/${PROJECT_NAME}.git")
  set(GIT_SERVER unknown_server)
  if(${PROJECT_NAME}_SITE_GIT_ADDRESS)
    extract_Package_Namespace_From_SSH_URL(${${PROJECT_NAME}_SITE_GIT_ADDRESS} ${PROJECT_NAME} GIT_NAMESPACE SERVER_ADDRESS EXTENSION)
  	if(GIT_NAMESPACE AND SERVER_ADDRESS)#OK we can generate a git address
  		set(OFFICIAL_REPOSITORY_ADDRESS "${SERVER_ADDRESS}:${GIT_NAMESPACE}/${PROJECT_NAME}.git")
  		set(GIT_SERVER ${SERVER_ADDRESS})
  	endif()
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
configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/install.md.in ${generated_pages_folder}/install.md @ONLY)
endfunction(generate_Package_Static_Site_Page_Install)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Static_Site_Page_Use| replace:: ``generate_Package_Static_Site_Page_Use``
#  .. _generate_Package_Static_Site_Page_Use:
#
#  generate_Package_Static_Site_Page_Use
#  -------------------------------------
#
#   .. command:: generate_Package_Static_Site_Page_Use(generated_site_folder)
#
#      Create the usage page for target package (for framework or lone site).
#
#      :generated_site_folder: path to the folder that contains generated site pages for target package.
#
function(generate_Package_Static_Site_Page_Use generated_pages_folder)

# package components
set(PACKAGE_COMPONENTS_DESCRIPTION "")
if(${PROJECT_NAME}_COMPONENTS) #if there are components
foreach(component IN LISTS ${PROJECT_NAME}_COMPONENTS)
	generate_Component_Site_For_Package(${component} RES_CONTENT_COMP)
	set(PACKAGE_COMPONENTS_DESCRIPTION "${PACKAGE_COMPONENTS_DESCRIPTION}\n${RES_CONTENT_COMP}")
endforeach()
endif()

# generating the install file for package site
configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/use.md.in ${generated_pages_folder}/use.md @ONLY)
endfunction(generate_Package_Static_Site_Page_Use)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Static_Site_Page_Contact| replace:: ``generate_Package_Static_Site_Page_Contact``
#  .. _generate_Package_Static_Site_Page_Contact:
#
#  generate_Package_Static_Site_Page_Contact
#  -----------------------------------------
#
#   .. command:: generate_Package_Static_Site_Page_Contact(generated_site_folder)
#
#      Create the contact page for target package (for framework or lone site).
#
#      :generated_site_folder: path to the folder that contains generated site pages for target package.
#
function(generate_Package_Static_Site_Page_Contact generated_pages_folder)
# generating the install file for package site
configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/contact.md.in ${generated_pages_folder}/contact.md @ONLY)
endfunction(generate_Package_Static_Site_Page_Contact)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Static_Site_Page_License| replace:: ``generate_Package_Static_Site_Page_License``
#  .. _generate_Package_Static_Site_Page_License:
#
#  generate_Package_Static_Site_Page_License
#  -----------------------------------------
#
#   .. command:: generate_Package_Static_Site_Page_License(generated_site_folder)
#
#      Create the license page for target package (for framework or lone site).
#
#      :generated_site_folder: path to the folder that contains generated site pages for target package.
#
function(generate_Package_Static_Site_Page_License generated_pages_folder)
#adding a license file in markdown format in the site pages (to be copied later if any modification occurred)
configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/license.md.in ${generated_pages_folder}/license.md @ONLY)
endfunction(generate_Package_Static_Site_Page_License)

#.rst:
#
# .. ifmode:: internal
#
#  .. |define_Component_Documentation_Content| replace:: ``define_Component_Documentation_Content``
#  .. _define_Component_Documentation_Content:
#
#  define_Component_Documentation_Content
#  --------------------------------------
#
#   .. command:: define_Component_Documentation_Content(component file)
#
#      Memorize the documentation file for a given component of current package project.
#
#      :component: the name of the component.
#      :file: the memorized path to documentation file.
#
function(define_Component_Documentation_Content component file)
set(DECLARED FALSE)
is_Declared(${component} DECLARED)
if(DECLARED AND EXISTS ${CMAKE_SOURCE_DIR}/share/site/${file})
	define_Documentation_Content(${DECLARED} ${file})
else()
	message("[PID] WARNING : documentation file for component ${component} cannot be found at ${CMAKE_SOURCE_DIR}/share/site/${file}. Documentation for this component will not reference this specific content.")
endif()
endfunction(define_Component_Documentation_Content)

#.rst:
#
# .. ifmode:: internal
#
#  .. |define_Documentation_Content| replace:: ``define_Documentation_Content``
#  .. _define_Documentation_Content:
#
#  define_Documentation_Content
#  ----------------------------
#
#   .. command:: define_Documentation_Content(label file)
#
#      Memorize the path to a documentation file with a given unique label.
#
#      :label: the label attached to the file.
#      :file: the memorized path to documentation file.
#
function(define_Documentation_Content label file)
set(${PROJECT_NAME}_${label}_SITE_CONTENT_FILE ${file} CACHE INTERNAL "")
endfunction(define_Documentation_Content)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Static_Site_Pages| replace:: ``generate_Package_Static_Site_Pages``
#  .. _generate_Package_Static_Site_Pages:
#
#  generate_Package_Static_Site_Pages
#  ----------------------------------
#
#   .. command:: generate_Package_Static_Site_Pages(generated_site_folder)
#
#      Create the static site data files for a package (framework or statis site).
#
#      :generated_site_folder: path to the folder that contains generated site pages for target package.
#
function(generate_Package_Static_Site_Pages generated_pages_folder)
	generate_Package_Static_Site_Page_Introduction(${generated_pages_folder}) # create introduction page
	generate_Package_Static_Site_Page_Install(${generated_pages_folder})# create install page
	generate_Package_Static_Site_Page_Use(${generated_pages_folder})# create use page
	generate_Package_Static_Site_Page_Contact(${generated_pages_folder})# create use page
	generate_Package_Static_Site_Page_License(${generated_pages_folder}) #create license page
endfunction(generate_Package_Static_Site_Pages)

################################################################################
#################### Static sites for wrappers #################################
################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Wrapper_Static_Site_Page_Introduction| replace:: ``generate_Wrapper_Static_Site_Page_Introduction``
#  .. _generate_Wrapper_Static_Site_Page_Introduction:
#
#  generate_Wrapper_Static_Site_Page_Introduction
#  ----------------------------------------------
#
#   .. command:: generate_Wrapper_Static_Site_Page_Introduction(generated_site_folder)
#
#      Create the introduction page for target wrapper (for framework or lone site).
#
#      :generated_site_folder: path to the folder that contains generated site pages for target wrapper.
#
function(generate_Wrapper_Static_Site_Page_Introduction generated_pages_folder)

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
set(PACKAGE_DEPENDENCIES_DESCRIPTION "")


if(NOT ${PROJECT_NAME}_KNOWN_VERSION_${PACKAGE_LAST_VERSION_WITH_PATCH}_DEPENDENCIES)
	set(PACKAGE_DEPENDENCIES_DESCRIPTION "This package has no dependency.\n")
	set(EXTERNAL_SITE_SECTION "")
endif()

if(NOT PACKAGE_DEPENDENCIES_DESCRIPTION) #means that the package has dependencies
	foreach(dep_package IN LISTS ${PROJECT_NAME}_KNOWN_VERSION_${PACKAGE_LAST_VERSION_WITH_PATCH}_DEPENDENCIES)# we take only dependencies of the last version
    set(prefix ${PROJECT_NAME}_KNOWN_VERSION_${PACKAGE_LAST_VERSION_WITH_PATCH}_DEPENDENCY_${dep_package})

    generate_External_Dependency_Site(RES_CONTENT_EXTERNAL ${dep_package}
            ${PROJECT_NAME}_KNOWN_VERSION_${PACKAGE_LAST_VERSION_WITH_PATCH}_DEPENDENCY_${dep_package}_VERSIONS
            ${PROJECT_NAME}_KNOWN_VERSION_${PACKAGE_LAST_VERSION_WITH_PATCH}_DEPENDENCY_${dep_package}_VERSIONS_EXACT)

    set(EXTERNAL_SITE_SECTION "${EXTERNAL_SITE_SECTION}\n${RES_CONTENT_EXTERNAL}")
	endforeach()
	set(PACKAGE_DEPENDENCIES_DESCRIPTION "${EXTERNAL_SITE_SECTION}\n")
endif()

# generating the introduction file for package site
configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/introduction_wrapper.md.in ${generated_pages_folder}/introduction.md @ONLY)
endfunction(generate_Wrapper_Static_Site_Page_Introduction)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Wrapper_Static_Site_Page_Contact| replace:: ``generate_Wrapper_Static_Site_Page_Contact``
#  .. _generate_Wrapper_Static_Site_Page_Contact:
#
#  generate_Wrapper_Static_Site_Page_Contact
#  -----------------------------------------
#
#   .. command:: generate_Wrapper_Static_Site_Page_Contact(generated_site_folder)
#
#      Create the contact page for target wrapper (for framework or lone site).
#
#      :generated_site_folder: path to the folder that contains generated site pages for target wrapper.
#
function(generate_Wrapper_Static_Site_Page_Contact generated_pages_folder)
  configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/contact_wrapper.md.in ${generated_pages_folder}/contact.md @ONLY)
endfunction(generate_Wrapper_Static_Site_Page_Contact)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Wrapper_Static_Site_Page_Install| replace:: ``generate_Wrapper_Static_Site_Page_Install``
#  .. _generate_Wrapper_Static_Site_Page_Install:
#
#  generate_Wrapper_Static_Site_Page_Install
#  -----------------------------------------
#
#   .. command:: generate_Wrapper_Static_Site_Page_Install(generated_site_folder)
#
#      Create the  HOWTO install page for target wrapper (for framework or lone site).
#
#      :generated_site_folder: path to the folder that contains generated site pages for target wrapper.
#
function(generate_Wrapper_Static_Site_Page_Install generated_pages_folder)

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
configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/install_wrapper.md.in ${generated_pages_folder}/install.md @ONLY)
endfunction(generate_Wrapper_Static_Site_Page_Install)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Component_Site_For_Wrapper| replace:: ``generate_Component_Site_For_Wrapper``
#  .. _generate_Component_Site_For_Wrapper:
#
#  generate_Component_Site_For_Wrapper
#  -----------------------------------
#
#   .. command:: generate_Component_Site_For_Wrapper(prefix component RES_CONTENT)
#
#      Generate the description (section of md file) for a given component defined in an external package wrapper.
#
#      :prefix: prefix to use to target adequate version of external package.
#      :component: the name of teh component.
#
#      :RES_CONTENT: the output variable containing the generated markdown content.
#
function(generate_Component_Site_For_Wrapper prefix component RES_CONTENT)

set(RES "## ${component}\n") # adding a section fo this component

#export possible only for libraries with headers
set(EXPORTS_SOMETHING FALSE)
set(EXPORTED_DEPS)
set(INT_EXPORTED_DEPS)
set(EXT_EXPORTED_DEPS)
foreach(a_int_dep IN LISTS ${prefix}_${component}_INTERNAL_DEPENDENCIES)# loop on the component internal dependencies
	if(${prefix}_${component}_INTERNAL_DEPENDENCY_${a_int_dep}_EXPORTED)
		set(EXPORTS_SOMETHING TRUE)
		list(APPEND INT_EXPORTED_DEPS ${a_int_dep})
	endif()
endforeach()

foreach(a_pack IN LISTS ${prefix}_${component}_DEPENDENCIES)# loop on the component dependencies
	set(${a_pack}_EXPORTED FALSE)
	foreach(a_comp IN LISTS ${prefix}_${component}_DEPENDENCY_${a_pack})
		if(${prefix}_${component}_DEPENDENCY_${a_pack}_${a_comp}_EXPORTED)
			set(EXPORTS_SOMETHING TRUE)
			if(NOT ${a_pack}_EXPORTED)
				set(${a_pack}_EXPORTED TRUE)
				list(APPEND EXPORTED_DEPS ${a_pack})
			endif()
			list(APPEND EXPORTED_DEP_${a_pack} ${a_comp})
		endif()
	endforeach()
endforeach()

if(EXPORTS_SOMETHING) #defines those dependencies that are exported
	set(RES "${RES}\n### exported dependencies:\n")
	if(INT_EXPORTED_DEPS)
		set(RES "${RES}+ from this external package:\n")
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
		elseif(${a_pack}_FRAMEWORK AND ${${a_pack}_FRAMEWORK}_SITE)
			set(TARGET_PAGE ${${${a_pack}_FRAMEWORK}_SITE}/external/${a_pack})
		else()
			set(TARGET_PAGE)
		endif()
		if(TARGET_PAGE)
			set(RES "${RES}+ from external package [${a_pack}](${TARGET_PAGE}):\n")
		else()
			set(RES "${RES}+ from external package **${a_pack}**:\n")
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
	set(RES "${RES}\n")
endif()

if(${prefix}_${component}_USAGE_INCLUDES)
  set(RES "${RES}### include directive :\n")
	set(RES "${RES}In your code using the library:\n\n")
	set(RES "${RES}{% highlight cpp %}\n")
	foreach(include_file IN LISTS ${prefix}_${component}_USAGE_INCLUDES)
		set(RES "${RES}#include <${include_file}>\n")
	endforeach()
	set(RES "${RES}{% endhighlight %}\n")
endif()
# for any kind of usable component
set(RES "${RES}\n### CMake usage :\n\nIn the CMakeLists.txt files of your applications and tests, or those of your libraries that **do not export the dependency**:\n\n{% highlight cmake %}\nPID_Component_Dependency(\n\t\t\t\tCOMPONENT\tyour component name\n\t\t\t\tDEPEND\t${component}\n\t\t\t\tPACKAGE\t${PROJECT_NAME})\n{% endhighlight %}\n\n")
set(RES "${RES}\n\nIn the CMakeLists.txt files of libraries **exporting the dependency** :\n\n{% highlight cmake %}\nPID_Component_Dependency(\n\t\t\t\tCOMPONENT\tyour component name\n\t\t\t\tEXPORT\t${component}\n\t\t\t\tPACKAGE\t${PROJECT_NAME})\n{% endhighlight %}\n\n")

set(${RES_CONTENT} ${RES} PARENT_SCOPE)
endfunction(generate_Component_Site_For_Wrapper)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Wrapper_Static_Site_Page_Use| replace:: ``generate_Wrapper_Static_Site_Page_Use``
#  .. _generate_Wrapper_Static_Site_Page_Use:
#
#  generate_Wrapper_Static_Site_Page_Use
#  -------------------------------------
#
#   .. command:: generate_Wrapper_Static_Site_Page_Use(generated_site_folder)
#
#      Create the usage page for target wrapper (for framework or lone site).
#
#      :generated_site_folder: path to the folder that contains generated site pages for target wrapper.
#
function(generate_Wrapper_Static_Site_Page_Use generated_pages_folder)

# package components
set(PACKAGE_COMPONENTS_DESCRIPTION "")
if(${PROJECT_NAME}_KNOWN_VERSION_${PACKAGE_LAST_VERSION_WITH_PATCH}_COMPONENTS) #if there are components
  set(prefix ${PROJECT_NAME}_KNOWN_VERSION_${PACKAGE_LAST_VERSION_WITH_PATCH}_COMPONENT)
  foreach(component IN LISTS ${PROJECT_NAME}_KNOWN_VERSION_${PACKAGE_LAST_VERSION_WITH_PATCH}_COMPONENTS)
  	generate_Component_Site_For_Wrapper(${prefix} ${component} RES_CONTENT_COMP)
  	set(PACKAGE_COMPONENTS_DESCRIPTION "${PACKAGE_COMPONENTS_DESCRIPTION}\n${RES_CONTENT_COMP}")
  endforeach()
else()
  set(PACKAGE_COMPONENTS_DESCRIPTION "The PID wrapper for ${PROJECT_NAME} version ${PACKAGE_LAST_VERSION_WITH_PATCH} does not provide any component description.")
endif()

# generating the install file for package site
configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/use_wrapper.md.in ${generated_pages_folder}/use.md @ONLY)
endfunction(generate_Wrapper_Static_Site_Page_Use)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Wrapper_Static_Site_Page_License| replace:: ``generate_Wrapper_Static_Site_Page_License``
#  .. _generate_Wrapper_Static_Site_Page_License:
#
#  generate_Wrapper_Static_Site_Page_License
#  -----------------------------------------
#
#   .. command:: generate_Wrapper_Static_Site_Page_License(generated_site_folder)
#
#      Create the license page for target wrapper (for framework or lone site).
#
#      :generated_site_folder: path to the folder that contains generated site pages for target wrapper.
#
function(generate_Wrapper_Static_Site_Page_License generated_pages_folder)
#adding a license file in markdown format in the site pages (to be copied later if any modification occurred)
configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/license_wrapper.md.in ${generated_pages_folder}/license.md @ONLY)
endfunction(generate_Wrapper_Static_Site_Page_License)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Wrapper_Static_Site_Pages| replace:: ``generate_Wrapper_Static_Site_Pages``
#  .. _generate_Wrapper_Static_Site_Pages:
#
#  generate_Wrapper_Static_Site_Pages
#  ----------------------------------
#
#   .. command:: generate_Wrapper_Static_Site_Pages(generated_site_folder)
#
#      Create the static site data files for a wrapper (framework or statis site).
#
#      :generated_site_folder: path to the folder that contains generated site pages for target wrapper.
#
function(generate_Wrapper_Static_Site_Pages generated_pages_folder)
  generate_Wrapper_Static_Site_Page_Introduction(${generated_pages_folder}) # create introduction page
  generate_Wrapper_Static_Site_Page_Install(${generated_pages_folder})# create install page
  generate_Wrapper_Static_Site_Page_Use(${generated_pages_folder})# create usage page
	generate_Wrapper_Static_Site_Page_Contact(${generated_pages_folder})# create use page
	generate_Wrapper_Static_Site_Page_License(${generated_pages_folder}) #create license page
endfunction(generate_Wrapper_Static_Site_Pages)

#.rst:
#
# .. ifmode:: internal
#
#  .. |configure_Static_Site_Generation_Variables| replace:: ``configure_Static_Site_Generation_Variables``
#  .. _configure_Static_Site_Generation_Variables:
#
#  configure_Static_Site_Generation_Variables
#  ------------------------------------------
#
#   .. command:: configure_Static_Site_Generation_Variables()
#
#      Configure all variable used for static site generation (native pakages or external package wrappers)
#
macro(configure_Static_Site_Generation_Variables)
set(PACKAGE_NAME ${PROJECT_NAME})
set(PACKAGE_PROJECT_REPOSITORY_PAGE ${${PROJECT_NAME}_PROJECT_PAGE})

if(NOT ${PROJECT_NAME}_CATEGORIES)
  set(PACKAGE_CATEGORIES)
else()
  list(LENGTH ${PROJECT_NAME}_CATEGORIES SIZE)
  if(SIZE EQUAL 1)
    set(PACKAGE_CATEGORIES ${${PROJECT_NAME}_CATEGORIES})
  else()
    set(PACKAGE_CATEGORIES "[")
    set(idx 0)
    foreach(cat IN LISTS ${PROJECT_NAME}_CATEGORIES)
      set(PACKAGE_CATEGORIES "${PACKAGE_CATEGORIES}${cat}")
      math(EXPR idx "${idx}+1")
      if(NOT idx EQUAL SIZE)
        set(PACKAGE_CATEGORIES "${PACKAGE_CATEGORIES},")
      endif()
    endforeach()
    set(PACKAGE_CATEGORIES "${PACKAGE_CATEGORIES}]")
  endif()
endif()

set(PACKAGE_ORIGINAL_PROJECT_SITE ${${PROJECT_NAME}_ORIGINAL_PROJECT_SITE}) #useful only for wrappers
set(PACKAGE_ORIGINAL_PROJECT_LICENSES ${${PROJECT_NAME}_ORIGINAL_PROJECT_LICENSES}) #useful only for wrappers

#released version info
if(${PROJECT_NAME}_VERSION) #only native package have a current version
	set(PACKAGE_LAST_VERSION_WITH_PATCH "${${PROJECT_NAME}_VERSION}")
	get_Version_String_Numbers(${${PROJECT_NAME}_VERSION} major minor patch)
	set(PACKAGE_LAST_VERSION_WITHOUT_PATCH "${major}.${minor}")
elseif(${PROJECT_NAME}_KNOWN_VERSIONS)#only external package wrappers have known versions
  set(greater_version)
  foreach(version IN LISTS ${PROJECT_NAME}_KNOWN_VERSIONS)
    if(NOT greater_version OR version VERSION_GREATER greater_version)
      set(greater_version ${version})
    endif()
  endforeach()
  if(greater_version)
    set(PACKAGE_LAST_VERSION_WITH_PATCH "${greater_version}")
    get_Version_String_Numbers(${greater_version} major minor patch)
    set(PACKAGE_LAST_VERSION_WITHOUT_PATCH "${major}.${minor}")
  endif()
endif()

## descirption (use the most detailed description, if any)
generate_Formatted_String("${${PROJECT_NAME}_SITE_INTRODUCTION}" RES_INTRO)
if("${RES_INTRO}" STREQUAL "")
	set(PACKAGE_DESCRIPTION "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided use the short one
else()
	set(PACKAGE_DESCRIPTION "${RES_INTRO}") #otherwise use detailed one specific for site
endif()

if(${PROJECT_NAME}_USER_README_FILE AND EXISTS ${CMAKE_SOURCE_DIR}/share/${${PROJECT_NAME}_USER_README_FILE})
	file(READ ${CMAKE_SOURCE_DIR}/share/${${PROJECT_NAME}_USER_README_FILE} CONTENT_OF_README)
	set(PACKAGE_README "<div markdown=\"1\">\n${CONTENT_OF_README}\n</div>")
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |configure_Package_Pages| replace:: ``configure_Package_Pages``
#  .. _configure_Package_Pages:
#
#  configure_Package_Pages
#  -----------------------
#
#   .. command:: configure_Package_Pages()
#
#      Configure and generate static site pages for a package.
#
function(configure_Package_Pages)
if(NOT ${CMAKE_BUILD_TYPE} MATCHES Release)
	return()
endif()
if(NOT ${PROJECT_NAME}_FRAMEWORK AND NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS) #no web site definition simply exit
	#no static site definition done so we create a fake "site" command in realease mode
	add_custom_target(site
		COMMAND ${CMAKE_COMMAND} -E  echo "[PID] WARNING: No specification of a static site in the project, use the PID_Publishing function in the root CMakeLists.txt file of the project"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
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
	generate_Static_Site_Jekyll_Data_File(${PATH_TO_SITE})

else() #${PROJECT_NAME}_FRAMEWORK is defining a framework for the package
	#find the framework in workspace
	check_Framework_Exists(FRAMEWORK_OK ${${PROJECT_NAME}_FRAMEWORK})
  if(NOT FRAMEWORK_OK)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] ERROR : the framework you specified (${${PROJECT_NAME}_FRAMEWORK}) is unknown in the workspace.")
		return()
	endif()
	generate_Package_Page_Index_In_Framework(${PATH_TO_SITE}) # create index page
endif()

# common generation process between framework and lone static sites

#2) generate pages
generate_Package_Static_Site_Pages(${PATH_TO_SITE_PAGES})
endfunction(configure_Package_Pages)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Dependency_Site| replace:: ``generate_Dependency_Site``
#  .. _generate_Dependency_Site:
#
#  generate_Dependency_Site
#  ------------------------
#
#   .. command:: generate_Dependency_Site(dependency RES_CONTENT)
#
#      Generate section of md file for a native package dependency. This defines markdown links to the static static site of the dependency.
#
#      :dependency: the name of the dependency.
#
#      :RES_CONTENT: output variable containing the markdown content used to target the dependency static site.
#
function(generate_Dependency_Site dependency RES_CONTENT)
if(${dependency}_SITE_ROOT_PAGE)
	set(RES "+ [${dependency}](${${dependency}_SITE_ROOT_PAGE})") #creating a link to the package site
elseif(${dependency}_FRAMEWORK) #the package belongs to a framework, creating a link to this page in the framework
	if(NOT ${${dependency}_FRAMEWORK}_SITE) #getting framework online site
    include_Framework_Reference_File(PATH_TO_FILE ${${dependency}_FRAMEWORK})
    if(NOT PATH_TO_FILE)
      message(FATAL_ERROR "[PID] Cannot find any reference to framework ${${dependency}_FRAMEWORK}")
      return()
    endif()
	endif()

	if(${${dependency}_FRAMEWORK}_SITE) #get the information about the framework
		set(RES "+ [${dependency}](${${${dependency}_FRAMEWORK}_SITE}/packages/${dependency})")
	else()#in case of a problem (framework unknown), do not create the link
		set(RES "+ ${dependency}")
	endif()
else()# the dependency has no documentation site
	set(RES "+ ${dependency}")
endif()

if(${PROJECT_NAME}_DEPENDENCY_${dependency}_ALL_POSSIBLE_VERSIONS)
  set(ALL_VERSIONS)
  foreach(vers IN LISTS ${PROJECT_NAME}_DEPENDENCY_${dependency}_ALL_POSSIBLE_VERSIONS)
    if(ALL_VERSIONS)
      set(ALL_VERSIONS "${ALL_VERSIONS},")
    endif()
    list(FIND ${PROJECT_NAME}_DEPENDENCY_${dependency}_ALL_EXACT_VERSIONS ${vers} INDEX)
    if(index EQUAL -1)
      set(ALL_VERSIONS "${ALL_VERSIONS} version ${vers} or compatible")
    else()
      set(ALL_VERSIONS "${ALL_VERSIONS} exact version ${vers}")
    endif()
  endforeach()
  set(RES "${RES}:${ALL_VERSIONS}.")
else()
	set(RES "${RES}: any version available.")
endif()
set(${RES_CONTENT} ${RES} PARENT_SCOPE)
endfunction(generate_Dependency_Site)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_External_Dependency_Site| replace:: ``generate_External_Dependency_Site``
#  .. _generate_External_Dependency_Site:
#
#  generate_External_Dependency_Site
#  ---------------------------------
#
#   .. command:: generate_External_Dependency_Site(RES_CONTENT dependency list_of_versions exact_versions)
#
#      Generate section of md file for an external package dependency. This defines markdown links to the static static site of the dependency.
#
#      :dependency: the name of the dependency.
#      :list_of_versions: the variable containing the list of possible versions for the dependency.
#      :exact_versions: the variable containing the list of exact versions (amon possible) for the dependency.
#
#      :RES_CONTENT: output variable containing the markdown content used to target the dependency static site.
#
function(generate_External_Dependency_Site RES_CONTENT dependency list_of_versions exact_versions)
  include_External_Reference_File(PATH_TO_FILE ${dependency})
  if(NOT PATH_TO_FILE)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR: reference file not found for package ${package}!! This is certainly due to a badly referenced package. Please contact the administrator of package ${package} !!!")
  	return()
  endif()

  if(${dependency}_FRAMEWORK)
  	if(NOT ${${dependency}_FRAMEWORK}_SITE)#getting framework online site
      include_Framework_Reference_File(PATH_TO_FILE ${${dependency}_FRAMEWORK})
      if(NOT PATH_TO_FILE)
        message(FATAL_ERROR "[PID] CRITICAL ERROR: cannot find any reference to framework ${${dependency}_FRAMEWORK}")
        return()
      endif()
  	endif()
  	if(${${dependency}_FRAMEWORK}_SITE)
  		set(RES "+ [${dependency}](${${${dependency}_FRAMEWORK}_SITE}/external/${dependency})")
  	else()#in case of a problem (framework unknown, problem in framework description), do not create the link
  		set(RES "+ ${dependency}")
  	endif()
  else()
  	set(RES "+ ${dependency}")
  endif()

  if(list_of_versions AND ${list_of_versions})
    set(ALL_VERSIONS)
    foreach(vers IN LISTS ${list_of_versions})
      if(ALL_VERSIONS)#there is already content in ALL_VERSIONS => managing append operation
        set(ALL_VERSIONS "${ALL_VERSIONS},")
      endif()
      list(FIND exact_versions ${vers} INDEX)
      if(index EQUAL -1)
        set(ALL_VERSIONS "${ALL_VERSIONS} version ${vers} or compatible")
      else()
        set(ALL_VERSIONS "${ALL_VERSIONS} exact version ${vers}")
      endif()
    endforeach()
    set(RES "${RES}:${ALL_VERSIONS}.")
  else()
  	set(RES "${RES}: any version available.")
  endif()
  set(${RES_CONTENT} ${RES} PARENT_SCOPE)
endfunction(generate_External_Dependency_Site)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Component_Site_For_Package| replace:: ``generate_Component_Site_For_Package``
#  .. _generate_Component_Site_For_Package:
#
#  generate_Component_Site_For_Package
#  -----------------------------------
#
#   .. command:: generate_Component_Site_For_Package(component RES_CONTENT)
#
#      Generate the section of md file to describe a component of the currently built package.
#
#      :component: the name of the component.
#
#      :RES_CONTENT: output variable containing the markdown content used to describe the component.
#
function(generate_Component_Site_For_Package component RES_CONTENT)
is_Externally_Usable(IS_EXT_USABLE ${component})#Note: no need to resolve since component is supposed to be already resolved if necessary.
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
			elseif(${a_pack}_FRAMEWORK AND ${${a_pack}_FRAMEWORK}_SITE)
				set(TARGET_PAGE ${${${a_pack}_FRAMEWORK}_SITE}/packages/${a_pack})
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
			if(${a_pack}_FRAMEWORK AND ${${a_pack}_FRAMEWORK}_SITE)
				set(TARGET_PAGE ${${${a_pack}_FRAMEWORK}_SITE}/packages/${a_pack})
			else()
				set(TARGET_PAGE)
			endif()
			if(TARGET_PAGE)
				set(RES "${RES}+ package [${a_pack}](${TARGET_PAGE})\n")
			else()
				set(RES "${RES}+ package **${a_pack}**\n")
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
set(RES "${RES}\n### CMake usage :\n\nIn the CMakeLists.txt files of your applications and tests, or those of your libraries that **do not export the dependency**:\n\n{% highlight cmake %}\nPID_Component_Dependency(\n\t\t\t\tCOMPONENT\tyour component name\n\t\t\t\tDEPEND\t${component}\n\t\t\t\tPACKAGE\t${PROJECT_NAME})\n{% endhighlight %}\n\n")
set(RES "${RES}\n\nIn the CMakeLists.txt files of libraries **exporting the dependency** :\n\n{% highlight cmake %}\nPID_Component_Dependency(\n\t\t\t\tCOMPONENT\tyour component name\n\t\t\t\tEXPORT\t${component}\n\t\t\t\tPACKAGE\t${PROJECT_NAME})\n{% endhighlight %}\n\n")

set(${RES_CONTENT} ${RES} PARENT_SCOPE)
endfunction(generate_Component_Site_For_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |produce_Package_Static_Site_Content| replace:: ``produce_Package_Static_Site_Content``
#  .. _produce_Package_Static_Site_Content:
#
#  produce_Package_Static_Site_Content
#  -----------------------------------
#
#   .. command:: produce_Package_Static_Site_Content(package only_bin framework version include_api_doc include_coverage include_staticchecks include_installer force)
#
#      Copy generated documentation and binaries content to the package static site repository (framework or lone site).
#
#      :package: the name of the package.
#      :only_bin: if TRUE then only produce binaries into static site.
#      :framework: the name of the framework (or empty string if package belongs to no framework).
#      :version: the version for wich the documentation is generated.
#      :include_api_doc: TRUE if API documentation must be included in static site.
#      :include_coverage: TRUE if coverage report must be included in static site.
#      :include_staticchecks: TRUE if static checks report must be included in static site.
#      :include_installer: TRUE if generated binaries are published by the static site.
#      :force: if TRUE the whole content is copied, otherwise only detected modifications are copied.
#
function(produce_Package_Static_Site_Content package only_bin framework version include_api_doc include_coverage include_staticchecks include_installer force) # copy everything needed

  get_Platform_Variables(BASENAME current_platform_name)

  #### preparing the copy depending on the target: lone static site or framework ####
  if(framework)
  	set(TARGET_PACKAGE_PATH ${WORKSPACE_DIR}/sites/frameworks/${framework}/src/_packages/${package})
  	set(TARGET_APIDOC_PATH ${TARGET_PACKAGE_PATH}/api_doc)
  	set(TARGET_COVERAGE_PATH ${TARGET_PACKAGE_PATH}/coverage)
  	set(TARGET_STATICCHECKS_PATH ${TARGET_PACKAGE_PATH}/static_checks)
    set(TARGET_ALL_BINARIES ${TARGET_PACKAGE_PATH}/binaries)
    set(TARGET_BINARIES_PATH ${TARGET_ALL_BINARIES}/${version}/${CURRENT_PLATFORM})
    set(TARGET_PAGES_PATH ${TARGET_PACKAGE_PATH}/pages)
  	set(TARGET_POSTS_PATH ${WORKSPACE_DIR}/sites/frameworks/${framework}/src/_posts)

  else()#it is a lone static site (no need to adapt the path as they work the same for external wrappers and native packages)
  	set(TARGET_PACKAGE_PATH ${WORKSPACE_DIR}/sites/packages/${package}/src)
    set(TARGET_ALL_BINARIES ${TARGET_PACKAGE_PATH}/_binaries)
    set(TARGET_BINARIES_PATH ${TARGET_ALL_BINARIES}/${version}/${CURRENT_PLATFORM})
    set(TARGET_APIDOC_PATH ${TARGET_PACKAGE_PATH}/api_doc)
  	set(TARGET_COVERAGE_PATH ${TARGET_PACKAGE_PATH}/coverage)
  	set(TARGET_STATICCHECKS_PATH ${TARGET_PACKAGE_PATH}/static_checks)
  	set(TARGET_PAGES_PATH ${TARGET_PACKAGE_PATH}/pages)
  	set(TARGET_POSTS_PATH ${TARGET_PACKAGE_PATH}/_posts)
  endif()

  set(NEW_POST_CONTENT_API_DOC FALSE)
  set(NEW_POST_CONTENT_COVERAGE FALSE)
  set(NEW_POST_CONTENT_STATICCHECKS FALSE)
  set(NEW_POST_CONTENT_BINARY FALSE)
  set(NEW_POST_CONTENT_PAGES FALSE)

  set(PATH_TO_PACKAGE_BUILD ${WORKSPACE_DIR}/packages/${package}/build)
  if(NOT only_bin)#no need to generate anything related to documentation

    ######### copy the API doxygen documentation ##############
    if(include_api_doc
    	AND EXISTS ${PATH_TO_PACKAGE_BUILD}/release/share/doc/html) # #may not exists if the make doc command has not been launched
    	set(ARE_SAME FALSE)
    	if(NOT force)#only do this heavy check if the generation is not forced
    		test_Same_Directory_Content(${PATH_TO_PACKAGE_BUILD}/release/share/doc/html ${TARGET_APIDOC_PATH} ARE_SAME)
    	endif()
    	if(NOT ARE_SAME)
        file(REMOVE_RECURSE ${TARGET_APIDOC_PATH})
      	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${PATH_TO_PACKAGE_BUILD}/release/share/doc/html  ${TARGET_APIDOC_PATH} 
		  				WORKING_DIRECTORY ${PATH_TO_PACKAGE_BUILD})#recreate the api_doc folder from the one generated by the package
      	set(NEW_POST_CONTENT_API_DOC TRUE)
    	endif()
    endif()

    ######### copy the coverage report ##############
    if(include_coverage
    	AND EXISTS ${PATH_TO_PACKAGE_BUILD}/debug/share/coverage_report)# #may not exists if the make coverage command has not been launched
    	set(ARE_SAME FALSE)
    	if(NOT force)#only do this heavy check if the generation is not forced
    		test_Same_Directory_Content(${PATH_TO_PACKAGE_BUILD}/debug/share/coverage_report ${TARGET_COVERAGE_PATH} ARE_SAME)
    	endif()
    	if(NOT ARE_SAME)
        file(REMOVE_RECURSE ${TARGET_COVERAGE_PATH})#delete coverage report folder
      	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${PATH_TO_PACKAGE_BUILD}/debug/share/coverage_report ${TARGET_COVERAGE_PATH} 
		  				WORKING_DIRECTORY ${PATH_TO_PACKAGE_BUILD})#recreate the coverage folder from the one generated by the package
      	set(NEW_POST_CONTENT_COVERAGE TRUE)
    	endif()
    endif()

    ######### copy the static check report ##############
    if(include_staticchecks
    	AND EXISTS ${WORKSPACE_DIR}/packages/${package}/build/release/share/static_checks_report) #may not exists if the make staticchecks command has not been launched
    	set(ARE_SAME FALSE)
    	if(NOT force)#only do this heavy check if the generation is not forced
    		test_Same_Directory_Content(${WORKSPACE_DIR}/packages/${package}/build/release/share/static_checks_report ${TARGET_STATICCHECKS_PATH} ARE_SAME)
    	endif()
    	if(NOT ARE_SAME)
        file(REMOVE_RECURSE ${TARGET_STATICCHECKS_PATH})#delete static checks report folder
    	   execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${PATH_TO_PACKAGE_BUILD}/release/share/static_checks_report ${TARGET_STATICCHECKS_PATH}
            				WORKING_DIRECTORY ${PATH_TO_PACKAGE_BUILD})#recreate the static_checks folder from the one generated by the package
    	set(NEW_POST_CONTENT_STATICCHECKS TRUE)
    	endif()
    endif()
  endif()

  ######### copy the new binaries ##############
  if(	include_installer
  	AND EXISTS ${PATH_TO_PACKAGE_BUILD}/release/${package}-${version}-${current_platform_name}.tar.gz)#at least a release version has been generated previously

  	# update the site content only if necessary
    if(NOT EXISTS ${TARGET_BINARIES_PATH})
      file(MAKE_DIRECTORY ${TARGET_BINARIES_PATH})#create the target folder if it does not exist
    endif()
	#copy the release binary package archive
  	file(COPY ${PATH_TO_PACKAGE_BUILD}/release/${package}-${version}-${current_platform_name}.tar.gz #copying archive
              ${PATH_TO_PACKAGE_BUILD}/release/share/Use${package}-${version}.cmake             #copying install manifest
  	     DESTINATION  ${TARGET_BINARIES_PATH})
	#copy the debug binary package archive if available
  	if(EXISTS ${PATH_TO_PACKAGE_BUILD}/debug/${package}-${version}-dbg-${current_platform_name}.tar.gz)#copy debug archive if it exists
  			file(COPY ${PATH_TO_PACKAGE_BUILD}/debug/${package}-${version}-dbg-${current_platform_name}.tar.gz
  			     DESTINATION  ${TARGET_BINARIES_PATH})#copy the binaries
  	endif()
  	# configure the file used to reference the binary in jekyll
    set(BINARY_VERSION ${version})
    set(BINARY_PACKAGE ${package})
    set(BINARY_PLATFORM ${CURRENT_PLATFORM})
    #adding to the static site project the markdown file describing the binary package (to be used by jekyll)
  	configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/binary.md.in ${TARGET_BINARIES_PATH}/binary.md @ONLY)

  	set(NEW_POST_CONTENT_BINARY TRUE)
  endif()

  # finally whether binaries have been produced or not this time
  # remove all versions not referenced in find file (except eventually current version)
  set(NEW_POST_CONTENT_REMOVED_BINS)
  if(EXISTS ${TARGET_ALL_BINARIES})
    set(DO_NOT_FIND_${package} TRUE)
    include_Find_File(${package})
    set(versions_to_allow ${${package}_PID_KNOWN_VERSION})
    list(APPEND versions_to_allow ${version})
    list(REMOVE_ITEM versions_to_allow 0.0.0)
    if(versions_to_allow)
      list_Version_Subdirectories(all_published_versions ${TARGET_ALL_BINARIES})
      foreach(a_version IN LISTS all_published_versions)
        list(FIND versions_to_allow ${a_version} INDEX)
        if(INDEX EQUAL -1)#version not found (deprecated or patch version proposed)
          #remove the crresponding directory
          file(REMOVE_RECURSE ${TARGET_ALL_BINARIES}/${a_version})
          list(APPEND NEW_POST_CONTENT_REMOVED_BINS ${a_version})
        endif()
      endforeach()
    endif()
  endif()

  ######### copy the license file (only for lone static sites, framework have their own) ##############
  if(NOT framework)
  	set(ARE_SAME FALSE)
  	if(NOT force)#only do this heavy check if the generation is not forced
  		test_Same_File_Content(${WORKSPACE_DIR}/packages/${package}/license.txt ${WORKSPACE_DIR}/sites/packages/${package}/license.txt ARE_SAME)
  	endif()
  	if(NOT ARE_SAME)
      #copy the up to date license file into site repository
      file(COPY ${WORKSPACE_DIR}/packages/${package}/license.txt DESTINATION ${WORKSPACE_DIR}/sites/packages/${package})
  	endif()
  endif()


  if(NOT only_bin)#no need to generate anything related to documentation if only binaries are generated

    ######### copy the documentation content ##############
    # 1) copy content from source into the binary dir
    if(EXISTS ${WORKSPACE_DIR}/packages/${package}/share/site AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/share/site)
    	#copy the content of the site source share folder of the package (user defined pages, documents and images) to the package final site in build tree
    	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/packages/${package}/share/site ${PATH_TO_PACKAGE_BUILD}/release/site/pages
       WORKING_DIRECTORY ${PATH_TO_PACKAGE_BUILD})
    endif()

    # 2) if content is new (either generated or user defined) then clean the site and copy the content to the site repository
    set(ARE_SAME FALSE)
    if(NOT force)#only do this heavy check if the generation is not forced
    	test_Same_Directory_Content(${PATH_TO_PACKAGE_BUILD}/release/site/pages ${TARGET_PAGES_PATH} ARE_SAME)
    endif()

    if(NOT ARE_SAME)
    	# clean the source folder content
      file(REMOVE_RECURSE ${TARGET_PAGES_PATH})#delete all pages
      file(MAKE_DIRECTORY ${TARGET_PAGES_PATH})# recreate the pages folder
    	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${PATH_TO_PACKAGE_BUILD}/release/site ${TARGET_PACKAGE_PATH}
        				WORKING_DIRECTORY ${PATH_TO_PACKAGE_BUILD})# copy content from binary dir to site repository source dir
    	set(NEW_POST_CONTENT_PAGES TRUE)
    endif()
  endif()

  ######### configure the post used to describe the update ##############
  string(TIMESTAMP POST_DATE "%Y-%m-%d" UTC)
  string(TIMESTAMP POST_HOUR "%H-%M-%S" UTC)
  set(POST_FILENAME "${POST_DATE}-${POST_HOUR}-${package}-${version}-${CURRENT_PLATFORM}-update.markdown")
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
  	set(POST_UPDATE_STRING "${POST_UPDATE_STRING}### A binary version of the package targetting ${CURRENT_PLATFORM} platform has been added for version ${version}\n\n")
  endif()
  if(NEW_POST_CONTENT_REMOVED_BINS)
    fill_String_From_List(RES_TO_PRINT NEW_POST_CONTENT_REMOVED_BINS ", ")
    set(POST_UPDATE_STRING "${POST_UPDATE_STRING}### Binaries have been removed for deprecated versions : ${RES_TO_PRINT}\n\n")
  endif()
  if(NEW_POST_CONTENT_PAGES)
  	set(POST_UPDATE_STRING "${POST_UPDATE_STRING}### The pages documenting the package have been updated\n\n")
  endif()
  if(NOT POST_UPDATE_STRING STREQUAL "") #do not generate a post if there is nothing to say (sanity check)
  	configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/post.markdown.in ${TARGET_POSTS_PATH}/${POST_FILENAME} @ONLY)#adding to the static site project the markdown file used as a post on the site
  endif()
endfunction(produce_Package_Static_Site_Content)

#####################################################################
###################Framework usage functions ########################
#####################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Package_Site_Address| replace:: ``get_Package_Site_Address``
#  .. _get_Package_Site_Address:
#
#  get_Package_Site_Address
#  ------------------------
#
#   .. command:: generate_Component_Site_For_Package(SITE_ADDRESS package)
#
#      Get the root address of the package page (either if it belongs to a framework or has its own lone static site)
#
#      :package: the name of the package.
#
#      :SITE_ADDRESS: the output variable that contains the online address of the package static site.
#
function(get_Package_Site_Address SITE_ADDRESS package)
set(${SITE_ADDRESS} PARENT_SCOPE)
if(${package}_FRAMEWORK) #package belongs to a framework
  include_Framework_Reference_File(PATH_TO_FILE ${${package}_FRAMEWORK})
  if(NOT PATH_TO_FILE)
    message(FATAL_ERROR "[PID] Cannot find any reference to framework ${${package}_FRAMEWORK} containing package ${package}")
    return()
  endif()
  set(${SITE_ADDRESS} ${${${package}_FRAMEWORK}_SITE}/packages/${package} PARENT_SCOPE)
elseif(${package}_SITE_GIT_ADDRESS AND ${package}_SITE_ROOT_PAGE)
	set(${SITE_ADDRESS} ${${package}_SITE_ROOT_PAGE} PARENT_SCOPE)
endif()
endfunction(get_Package_Site_Address)

################################################################################
################## External package wrapper related functions ##################
################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Wrapper_Readme_Files| replace:: ``generate_Wrapper_Readme_Files``
#  .. _generate_Wrapper_Readme_Files:
#
#  generate_Wrapper_Readme_Files
#  -----------------------------
#
#   .. command:: generate_Wrapper_Readme_Files()
#
#     Create the README.md file for current wrapper project.
#
function(generate_Wrapper_Readme_Files)
set(README_CONFIG_FILE ${WORKSPACE_DIR}/cmake/patterns/wrappers/README.md.in)
## introduction (more detailed description, if any)
get_Wrapper_Site_Address(ADDRESS ${PROJECT_NAME})
if(NOT ADDRESS)#no site description has been provided nor framework reference
	# intro
  generate_Formatted_String("${${PROJECT_NAME}_DESCRIPTION}" RES_INTRO)
	set(README_OVERVIEW "${RES_INTRO}") #if no detailed description provided by site use the short one
	# no reference to site page
	set(WRAPPER_SITE_REF_IN_README "")

	# simplified install section
	set(INSTALL_USE_IN_README "The procedures for installing the ${PROJECT_NAME} wrapper and for using its components is based on the [PID](http://pid.lirmm.net/pid-framework/pages/install.html) build and deployment system called PID. Just follow and read the links to understand how to install, use and call its API and/or applications.")
else()
	# intro
  if(${PROJECT_NAME}_SITE_INTRODUCTION)
    generate_Formatted_String("${${PROJECT_NAME}_SITE_INTRODUCTION}" RES_INTRO)
  else()
    generate_Formatted_String("${${PROJECT_NAME}_DESCRIPTION}" RES_INTRO)
  endif()
  set(README_OVERVIEW "${RES_INTRO}") #if no detailed description provided by site description use the short one

	# install procedure
	set(INSTALL_USE_IN_README "The procedures for installing the ${PROJECT_NAME} wrapper and for using its components is available in this [site][package_site]. It is based on a CMake based build and deployment system called [PID](http://pid.lirmm.net/pid-framework/pages/install.html). Just follow and read the links to understand how to install, use and call its API and/or applications.")

	# reference to site page
	set(WRAPPER_SITE_REF_IN_README "[package_site]: ${ADDRESS} \"${PROJECT_NAME} wrapper\"
")
endif()

if(${PROJECT_NAME}_LICENSE)
	set(WRAPPER_LICENSE_FOR_README "The license that applies to the PID wrapper content (Cmake files mostly) is **${${PROJECT_NAME}_LICENSE}**. Please look at the license.txt file at the root of this repository for more details. The content generated by the wrapper being based on third party code it is subject to the licenses that apply for the ${PROJECT_NAME} project ")
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Wrapper_License_File| replace:: ``generate_Wrapper_License_File``
#  .. _generate_Wrapper_License_File:
#
#  generate_Wrapper_License_File
#  -----------------------------
#
#   .. command:: generate_Wrapper_License_File()
#
#     Create the license file for current wrapper project (differs a bit from those of the native packages).
#
function(generate_Wrapper_License_File)
if(EXISTS ${CMAKE_SOURCE_DIR}/license.txt)# a license has already been generated
	if(NOT REGENERATE_LICENSE)# avoid regeneration if nothing changed
		return()
	endif()
endif()
if(${PROJECT_NAME}_LICENSE)
  resolve_License_File(PATH_TO_FILE ${${PROJECT_NAME}_LICENSE})
  if(NOT PATH_TO_FILE)
    message("[PID] WARNING : license configuration file for ${${PROJECT_NAME}_LICENSE} not found in any contribution space installed in workspace, license file will not be generated.")
  else()
		#prepare license generation
		set(${PROJECT_NAME}_FOR_LICENSE "${PROJECT_NAME} PID Wrapper")
		set(${PROJECT_NAME}_DESCRIPTION_FOR_LICENSE ${${PROJECT_NAME}_DESCRIPTION})
		set(${PROJECT_NAME}_YEARS_FOR_LICENSE ${${PROJECT_NAME}_YEARS})
		foreach(author IN LISTS ${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS)
			generate_Full_Author_String(${author} STRING_TO_APPEND)
			set(${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE "${${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE} ${STRING_TO_APPEND}")
		endforeach()
    include(${PATH_TO_FILE})
		file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
	endif()
endif()
endfunction(generate_Wrapper_License_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Wrapper_Page_Index_In_Framework| replace:: ``generate_Wrapper_Page_Index_In_Framework``
#  .. _generate_Wrapper_Page_Index_In_Framework:
#
#  generate_Wrapper_Page_Index_In_Framework
#  ----------------------------------------
#
#   .. command:: generate_Wrapper_Page_Index_In_Framework(generated_site_folder)
#
#      Create the index file for target wrapper when it is published in a framework
#
#      :generated_site_folder: path to the folder that contains generated site pages for target wrapper.
#
function(generate_Wrapper_Page_Index_In_Framework generated_site_folder)
configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/index_wrapper.html.in ${generated_site_folder}/index.html @ONLY)
endfunction(generate_Wrapper_Page_Index_In_Framework)

#.rst:
#
# .. ifmode:: internal
#
#  .. |configure_Wrapper_Pages| replace:: ``configure_Wrapper_Pages``
#  .. _configure_Wrapper_Pages:
#
#  configure_Wrapper_Pages
#  -----------------------
#
#   .. command:: configure_Wrapper_Pages()
#
#      Configure and generate static site pages for a wrapper.
#
function(configure_Wrapper_Pages)
if(NOT ${PROJECT_NAME}_FRAMEWORK AND NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS) #no web site definition simply exit
	#no static site definition done so we create a fake "site" command in realease mode
	add_custom_target(site
		COMMAND ${CMAKE_COMMAND} -E  echo "No specification of a static site in the project, use the declare_PID_Publishing function in the root CMakeLists.txt file of the project"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
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
	generate_Static_Site_Jekyll_Data_File(${PATH_TO_SITE})

else() #${PROJECT_NAME}_FRAMEWORK is defining a framework for the package
	#find the framework in workspace
	check_Framework_Exists(FRAMEWORK_OK ${${PROJECT_NAME}_FRAMEWORK})
	if(NOT FRAMEWORK_OK)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] ERROR : the framework you specified (${${PROJECT_NAME}_FRAMEWORK}) is unknown in the workspace.")
		return()
	endif()
	generate_Wrapper_Page_Index_In_Framework(${PATH_TO_SITE}) # create index page
endif()

# common generation process between framework and lone static sites

#2) generate pages
generate_Wrapper_Static_Site_Pages(${PATH_TO_SITE_PAGES})
endfunction(configure_Wrapper_Pages)

#.rst:
#
# .. ifmode:: internal
#
#  .. |produce_Wrapper_Static_Site_Content| replace:: ``produce_Wrapper_Static_Site_Content``
#  .. _produce_Wrapper_Static_Site_Content:
#
#  produce_Wrapper_Static_Site_Content
#  -----------------------------------
#
#   .. command:: produce_Wrapper_Static_Site_Content(package only_bin framework version include_installer force)
#
#      Copy generated documentation and binaries content to the external package static site repository (framework or lone site).
#
#      :package: the name of the external package.
#      :only_bin: if TRUE then only produce binaries into static site.
#      :framework: the name of the framework (or empty string if package belongs to no framework).
#      :versions: the version for wich the documentation is generated.
#      :include_installer: TRUE if generated binaries are published by the static site.
#      :force: if TRUE the whole content is copied, otherwise only detected modifications are copied.
#
function(produce_Wrapper_Static_Site_Content package only_bin framework versions include_installer force)

  get_Platform_Variables(BASENAME current_platform_name)

  #### preparing the copy depending on the target: lone static site or framework ####
  if(framework)
  	set(TARGET_PACKAGE_PATH ${WORKSPACE_DIR}/sites/frameworks/${framework}/src/_external/${package})
  	set(TARGET_POSTS_PATH ${WORKSPACE_DIR}/sites/frameworks/${framework}/src/_posts)
    set(TARGET_BINARIES_PATH ${TARGET_PACKAGE_PATH}/binaries)
  else()#it is a lone static site (no need to adapt the path as they work the same for external wrappers and native packages)
  	set(TARGET_PACKAGE_PATH ${WORKSPACE_DIR}/sites/packages/${package}/src)
  	set(TARGET_POSTS_PATH ${TARGET_PACKAGE_PATH}/_posts)
    set(TARGET_BINARIES_PATH ${TARGET_PACKAGE_PATH}/_binaries)
  endif()
  set(TARGET_PAGES_PATH ${TARGET_PACKAGE_PATH}/pages)
  set(PATH_TO_WRAPPER_BUILD ${WORKSPACE_DIR}/wrappers/${package}/build)
  ######### copy the binaries that have been built ##############
  set(NEW_POST_CONTENT_BINARY_VERSIONS)
  if(include_installer) #reinstall all the binary archives that lie in the wrapper build folder
    foreach(version IN LISTS versions)
      set(target_archive_path ${PATH_TO_WRAPPER_BUILD}/${version}/installer/${package}-${version}-${current_platform_name}.tar.gz)
      set(target_install_manifest ${PATH_TO_WRAPPER_BUILD}/Use${package}-${version}.cmake)
      set(target_dbg_archive_path ${PATH_TO_WRAPPER_BUILD}/${version}/installer/${package}-${version}-dbg-${current_platform_name}.tar.gz)
      if(EXISTS ${target_archive_path})#an archive has been generated for this package version by the wrapper
        set(target_bin_path ${TARGET_BINARIES_PATH}/${version}/${CURRENT_PLATFORM})
        if(NOT EXISTS ${target_bin_path})
          file(MAKE_DIRECTORY ${target_bin_path})#create the target folder
        endif()
        file(COPY ${target_archive_path} ${target_install_manifest}
            DESTINATION ${target_bin_path})#copy the release archive and install manifest
        if(EXISTS ${target_dbg_archive_path})#copy debug archive if it exist
    			file(COPY ${target_dbg_archive_path} DESTINATION ${target_bin_path})#copy the debug archive
      	endif()
      	set(BINARY_VERSION ${version})
        set(BINARY_PACKAGE ${package})
        set(BINARY_PLATFORM ${CURRENT_PLATFORM})
        # configure the file used to reference the binary in jekyll
        #adding to the static site project the markdown file describing the binary package (to be used by jekyll)
        configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/binary.md.in ${target_bin_path}/binary.md @ONLY)
        list(APPEND NEW_POST_CONTENT_BINARY_VERSIONS ${version})
      endif()
    endforeach()
  endif()

  # whether a binary package installer is generated for this version or not
  set(NEW_POST_CONTENT_REMOVED_BINS)
  list_Version_Subdirectories(all_published_versions ${TARGET_BINARIES_PATH})
  foreach(a_version IN LISTS all_published_versions)
    list(FIND versions ${a_version} INDEX)
    if(INDEX EQUAL -1) #support for this version has been deprecated
      #remove the folder
      file(REMOVE_RECURSE ${TARGET_BINARIES_PATH}/${a_version})
      list(APPEND NEW_POST_CONTENT_REMOVED_BINS ${a_version})
    endif()
  endforeach()

  ######### copy the license file (only for lone static sites, framework have their own) ##############
  if(NOT framework)
  	set(ARE_SAME FALSE)
  	if(NOT force)#only do this heavy check if the generation is not forced
  		test_Same_File_Content(${WORKSPACE_DIR}/wrappers/${package}/license.txt ${WORKSPACE_DIR}/sites/packages/${package}/license.txt ARE_SAME)
  	endif()
  	if(NOT ARE_SAME)
      #copy the up to date license file into site repository
      file(COPY ${WORKSPACE_DIR}/wrappers/${package}/license.txt DESTINATION ${WORKSPACE_DIR}/sites/packages/${package})
  	endif()
  endif()

  ######### copy the documentation content ##############
  set(NEW_POST_CONTENT_PAGES FALSE)
  if(NOT only_bin) #no need to generate pages if only binaries are uploaded into the static site
    # 1) copy content from source into the binary dir
    if(EXISTS ${WORKSPACE_DIR}/wrappers/${package}/share/site AND IS_DIRECTORY ${WORKSPACE_DIR}/wrappers/${package}/share/site)
    	#copy the content of the site source share folder of the package (user defined pages, documents and images) to the package final site in build tree
    	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/wrappers/${package}/share/site ${PATH_TO_WRAPPER_BUILD}/site/pages
       WORKING_DIRECTORY ${PATH_TO_WRAPPER_BUILD})
    endif()

    # 2) if content is new (either generated or user defined) then clean the site and copy the content to the site repository
    set(ARE_SAME FALSE)
    if(NOT force)#only do this heavy check if the generation is not forced
    	test_Same_Directory_Content(${WORKSPACE_DIR}/wrappers/${package}/build/site/pages ${TARGET_PAGES_PATH} ARE_SAME)
    endif()

    if(NOT ARE_SAME)
    	# clean the source folder content
      file(REMOVE_RECURSE ${TARGET_PAGES_PATH})#delete all pages
      file(MAKE_DIRECTORY ${TARGET_PAGES_PATH})#recreate the pages folder
    	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${PATH_TO_WRAPPER_BUILD}/site ${TARGET_PACKAGE_PATH}
        WORKING_DIRECTORY ${PATH_TO_WRAPPER_BUILD})# copy content from binary dir to site repository source dir
    	set(NEW_POST_CONTENT_PAGES TRUE)
    else()
      file(COPY ${PATH_TO_WRAPPER_BUILD}/site/index.html DESTINATION ${TARGET_PACKAGE_PATH})#QUESTION: why copying only the index ?
    endif()
  endif()

  ######### configure the post used to describe the update ##############
  string(TIMESTAMP POST_DATE "%Y-%m-%d" UTC)
  string(TIMESTAMP POST_HOUR "%H-%M-%S" UTC)
  set(POST_FILENAME "${POST_DATE}-${POST_HOUR}-${package}-${CURRENT_PLATFORM}-update.markdown")
  set(POST_PACKAGE ${package})
  if(force)
  	set(POST_TITLE "The update of external package ${package} has been forced !")
  else()
  	set(POST_TITLE "external package ${package} has been updated !")
  endif()
  set(POST_UPDATE_STRING "")
  if(NEW_POST_CONTENT_BINARY_VERSIONS)
    fill_String_From_List(ALL_VERSIONS_STR NEW_POST_CONTENT_BINARY_VERSIONS " ")
    set(POST_UPDATE_STRING "${POST_UPDATE_STRING}### Binary versions of the external package targetting ${CURRENT_PLATFORM} platform have been added/updated : ${ALL_VERSIONS_STR}\n\n")
  endif()
  if(NEW_POST_CONTENT_REMOVED_BINS)
    fill_String_From_List(RES_TO_PRINT NEW_POST_CONTENT_REMOVED_BINS ", ")
    set(POST_UPDATE_STRING "${POST_UPDATE_STRING}### Binaries have been removed for deprecated versions: ${RES_TO_PRINT}\n\n")
  endif()
  if(NEW_POST_CONTENT_PAGES)
  	set(POST_UPDATE_STRING "${POST_UPDATE_STRING}### The pages documenting the external package have been updated\n\n")
  endif()
  if(NOT POST_UPDATE_STRING STREQUAL "") #do not generate a post if there is nothing to say (sanity check)
  	configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/post.markdown.in ${TARGET_POSTS_PATH}/${POST_FILENAME} @ONLY)#adding to the static site project the markdown file used as a post on the site
  endif()
endfunction(produce_Wrapper_Static_Site_Content)
