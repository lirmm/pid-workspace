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
if(WRAPPER_DEFINITION_INCLUDED)
  return()
endif()
set(WRAPPER_DEFINITION_INCLUDED TRUE)
##########################################################################################


list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)

include(PID_Wrapper_API_Internal_Functions NO_POLICY_SCOPE)
include(External_Definition NO_POLICY_SCOPE) #to be able to interpret content of external package description files
include(Package_Definition NO_POLICY_SCOPE) #to enable the use of get_PID_Platform_Info in find files

include(CMakeParseArguments)

#########################################################################################
######################## API to be used in wrapper description ##########################
#########################################################################################

#.rst:
#
# .. ifmode:: user
#
#  .. |declare_PID_Wrapper| replace:: ``declare_PID_Wrapper``
#  .. _declare_PID_Wrapper:
#
#  declare_PID_Wrapper
#  -------------------
#
#   .. command:: declare_PID_Wrapper(AUTHOR ... YEAR ... LICENSE ... DESCRIPTION ... [OPTIONS])
#
#      Declare the current CMake project as a PID wrapper for a given external package with specific meta-information passed as parameter.
#
#     .. rubric:: Required parameters
#
#     :AUTHOR <name>: Defines the name of the reference author.
#
#     :YEAR <dates>: Reflects the lifetime of the wrapper, e.g. ``YYYY-ZZZZ`` where ``YYYY`` is the creation year and ``ZZZZ`` the latest modification date.
#
#     :LICENSE <license name>: The name of the license applying to the wrapper. This must match one of the existing license file in the ``licenses`` directory of the workspace. This license applies to the wrapper and not to the original project.
#
#     :DESCRIPTION <description>: A short description of the package usage and utility.
#
#     .. rubric:: Optional parameters
#
#     :INSTITUTION <institutions>: Define the institution(s) to which the reference author belongs.
#
#     :MAIL <e-mail>: E-mail of the reference author.
#
#     :ADDRESS <url>: The url of the wrapper's official repository. Must be set once the package is published.
#
#     :PUBLIC_ADDRESS <url>: Can be used to provide a public counterpart to the repository `ADDRESS`
#
#     :README <path relative to share folder>: Used to define a user-defined README file for the package.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root ``CMakeLists.txt`` file of the wrapper before any other call to the PID Wrapper API.
#        - It must be called **exactly once**.
#
#     .. admonition:: Effects
#        :class: important
#
#        Initialization of the wrapper's internal state. After this call the its content can be defined.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        declare_PID_Wrapper(
#		         AUTHOR Robin Passama
#		         INSTITUTION LIRMM
#		         YEAR 2013
#		         LICENSE CeCILL-C
#		         ADDRESS git@gite.lirmm.fr:passama/a-given-wrapper.git
# 		       DESCRIPTION "an example PID wrapper"
#        )
#
macro(declare_PID_Wrapper)
set(oneValueArgs LICENSE ADDRESS MAIL PUBLIC_ADDRESS README)
set(multiValueArgs AUTHOR INSTITUTION YEAR DESCRIPTION)
cmake_parse_arguments(DECLARE_PID_WRAPPER "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_AUTHOR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an author name must be given using AUTHOR keyword.")
endif()
if(NOT DECLARE_PID_WRAPPER_YEAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a year or year interval must be given using YEAR keyword.")
endif()
if(NOT DECLARE_PID_WRAPPER_LICENSE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a license type must be given using LICENSE keyword.")
endif()
if(NOT DECLARE_PID_WRAPPER_DESCRIPTION)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a (short) description of the wrapper must be given using DESCRIPTION keyword.")
endif()

if(DECLARE_PID_WRAPPER_UNPARSED_ARGUMENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, unknown arguments ${DECLARE_PID_WRAPPER_UNPARSED_ARGUMENTS}.")
endif()

if(NOT DECLARE_PID_WRAPPER_ADDRESS AND DECLARE_PID_WRAPPER_PUBLIC_ADDRESS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the wrapper must have an adress if a public access adress is declared.")
endif()

declare_Wrapper(	"${DECLARE_PID_WRAPPER_AUTHOR}" "${DECLARE_PID_WRAPPER_INSTITUTION}" "${DECLARE_PID_WRAPPER_MAIL}"
			"${DECLARE_PID_WRAPPER_YEAR}" "${DECLARE_PID_WRAPPER_LICENSE}"
			"${DECLARE_PID_WRAPPER_ADDRESS}" "${DECLARE_PID_WRAPPER_PUBLIC_ADDRESS}"
		"${DECLARE_PID_WRAPPER_DESCRIPTION}" "${DECLARE_PID_WRAPPER_README}")
endmacro(declare_PID_Wrapper)

#.rst:
#
# .. ifmode:: user
#
#  .. |define_PID_Wrapper_Original_Project_Info| replace:: ``define_PID_Wrapper_Original_Project_Info``
#  .. _define_PID_Wrapper_Original_Project_Info:
#
#  define_PID_Wrapper_Original_Project_Info
#  ----------------------------------------
#
#   .. command:: define_PID_Wrapper_Original_Project_Info(AUTHORS ... LICENSE ... URL ...)
#
#      Set the meta information about original project being wrapped by current project.
#
#     .. rubric:: Required parameters
#
#     :AUTHORS <string>: Defines who are the authors of the original project.
#
#     :LICENSE <string>: The license that applies to the original project content.
#
#     :URL <url>: this is the index URL of the original project.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root CMakeLists.txt file of the wrapper, after declare_PID_Wrapper.
#        - It must be called **exactly once**.
#
#     .. admonition:: Effects
#        :class: important
#
#        Sets the meta-information about original project.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        define_PID_Wrapper_Original_Project_Info(
#	           AUTHORS "Boost.org contributors"
#	           LICENSES "Boost license"
#            URL http://www.boost.org)
#
macro(define_PID_Wrapper_Original_Project_Info)
	set(oneValueArgs URL)
	set(multiValueArgs AUTHORS LICENSES)
	cmake_parse_arguments(DEFINE_WRAPPED_PROJECT "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	if(NOT DEFINE_WRAPPED_PROJECT_AUTHORS)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, authors references must be given using AUTHOR keyword.")
	endif()
	if(NOT DEFINE_WRAPPED_PROJECT_LICENSES)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a license description must be given using LICENSE keyword.")
	endif()
	if(NOT DEFINE_WRAPPED_PROJECT_URL)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, The URL of the original project must be given using URL keyword.")
	endif()
	define_Wrapped_Project("${DEFINE_WRAPPED_PROJECT_AUTHORS}" "${DEFINE_WRAPPED_PROJECT_LICENSES}"  "${DEFINE_WRAPPED_PROJECT_URL}")
endmacro(define_PID_Wrapper_Original_Project_Info)

#.rst:
#
# .. ifmode:: user
#
#  .. |add_PID_Wrapper_Author| replace:: ``add_PID_Wrapper_Author``
#  .. _add_PID_Wrapper_Author:
#
#  add_PID_Wrapper_Author
#  ----------------------
#
#   .. command:: add_PID_Wrapper_Author(AUTHOR ... [INSTITUTION ...])
#
#      Add an author to the list of authors of the wrapper.
#
#     .. rubric:: Required parameters
#
#     :[AUTHOR] <string>: Name of the author. The keyword AUTHOR can be avoided if the name is given as first argument.
#
#     .. rubric:: Optional parameters
#
#     :INSTITUTION <institutions>: the institution(s) to which the author belongs.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root CMakeLists.txt file of the package, after declare_PID_Wrapper and before build_PID_Wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#        Add another author to the list of authors of the wrapper.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        add_PID_Wrapper_Author(AUTHOR Another Writter INSTITUTION LIRMM)
#
macro(add_PID_Wrapper_Author)
set(multiValueArgs AUTHOR INSTITUTION)
cmake_parse_arguments(ADD_PID_WRAPPER_AUTHOR "" "" "${multiValueArgs}" ${ARGN} )
if(NOT ADD_PID_WRAPPER_AUTHOR_AUTHOR)
  if("${ARGV0}" STREQUAL "" OR "${ARGV0}" STREQUAL "INSTITUTION")
    finish_Progress(GLOBAL_PROGRESS_VAR)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an author name must be given using AUTHOR keyword.")
  else()#of the first argument is directly the name of the author
    add_Author("${ARGV0}" "${ADD_PID_WRAPPER_AUTHOR_INSTITUTION}")
  endif()
else()
  add_Author("${ADD_PID_WRAPPER_AUTHOR_AUTHOR}" "${ADD_PID_WRAPPER_AUTHOR_INSTITUTION}")
endif()
endmacro(add_PID_Wrapper_Author)

#.rst:
#
# .. ifmode:: user
#
#  .. |add_PID_Wrapper_Category| replace:: ``add_PID_Wrapper_Category``
#  .. _add_PID_Wrapper_Category:
#
#  add_PID_Wrapper_Category
#  ------------------------
#
#   .. command:: add_PID_Wrapper_Category(...)
#
#      Declare that the current wrapper generates external packages that belong to a given category.
#
#     .. rubric:: Required parameters
#
#     :<string>: Name of the category
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root CMakeLists.txt file of the wrapper, after declare_PID_Wrapper and before build_PID_Wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#        Register the wrapper has being member of the given (sub)category. This information will be added to the wrapper reference file when it is generated.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        add_PID_Wrapper_Category(example/packaging)
#
macro(add_PID_Wrapper_Category)
if(NOT ${ARGC} EQUAL 1)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the add_PID_Wrapper_Category command requires one string argument of the form <category>[/subcategory]*.")
endif()
add_Category("${ARGV0}")
endmacro(add_PID_Wrapper_Category)

#.rst:
#
# .. ifmode:: user
#
#  .. |define_PID_Wrapper_User_Option| replace:: ``define_PID_Wrapper_User_Option``
#  .. _define_PID_Wrapper_User_Option:
#
#  define_PID_Wrapper_User_Option
#  ------------------------------
#
#   .. command:: define_PID_Wrapper_User_Option(OPTION ... TYPE ...[DESCRIPTION ...])
#
#      Declare that the current wrapper generates external packages that belong to a given category.
#
#     .. rubric:: Required parameters
#
#     :[OPTION] <name>:  string defining the name of the user option. This name can then be used in deployment scripts. The option keyword can be omitted is name is given as first argument.
#     :TYPE <type of the cmake option>:  type of the option, to be chosen between: FILEPATH (File chooser dialog), PATH (Directory chooser dialog), STRING (Arbitrary string), BOOL.
#     :DEFAULT ...:  Default value for the option.
#
#     .. rubric:: Optional parameters
#
#     :DESCRIPTION <string>: a string describing what this option is acting on.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root CMakeLists.txt file of the wrapper, after declare_PID_Wrapper and before build_PID_Wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#        Register a new user option into the wrapper. This user option will be used only in deployment scripts.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        define_PID_Wrapper_User_Option(
#	          OPTION BUILD_WITH_CUDA_SUPPORT
#	          TYPE BOOL
#	          DEFAULT OFF
#	          DESCRIPTION "set to ON to enable CUDA support during build")
#
macro(define_PID_Wrapper_User_Option)
set(oneValueArgs OPTION TYPE DESCRIPTION)
set(multiValueArgs DEFAULT)
cmake_parse_arguments(DEFINE_PID_WRAPPER_USER_OPTION "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DEFINE_PID_WRAPPER_USER_OPTION_OPTION)
  if("${ARGV0}" STREQUAL "" OR "${ARGV0}" MATCHES "^TYPE|DESCRIPTION|DEFAULT$")
    finish_Progress(GLOBAL_PROGRESS_VAR)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an option name must be given using OPTION keyword.")
  endif()
  set(option_name "${ARGV0}")
else()
  set(option_name "${DEFINE_PID_WRAPPER_USER_OPTION_OPTION}")
endif()

if(NOT DEFINE_PID_WRAPPER_USER_OPTION_TYPE)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the type of the option must be given using TYPE keyword. Choose amon followiung value: FILEPATH (File chooser dialog), PATH (Directory chooser dialog), STRING (Arbitrary string), BOOL.")
endif()
if(NOT DEFINE_PID_WRAPPER_USER_OPTION_DEFAULT)#no argument passed (arguments may be boolean)
  finish_Progress(GLOBAL_PROGRESS_VAR)
  message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, default value of the option must be given using DEFAULT keyword (may be a list of values).")
endif()
set_Wrapper_Option("${option_name}" "${DEFINE_PID_WRAPPER_USER_OPTION_TYPE}" "${DEFINE_PID_WRAPPER_USER_OPTION_DEFAULT}" "${DEFINE_PID_WRAPPER_USER_OPTION_DESCRIPTION}")
endmacro(define_PID_Wrapper_User_Option)

#.rst:
#
# .. ifmode:: user
#
#  .. |declare_PID_Wrapper_Publishing| replace:: ``declare_PID_Wrapper_Publishing``
#  .. _declare_PID_Wrapper_Publishing:
#
#  declare_PID_Wrapper_Publishing
#  ------------------------------
#
#   .. command:: declare_PID_Wrapper_Publishing(PROJECT ... GIT|FRAMEWORK ... [OPTIONS])
#
#      Declare that the current wrapper generates external packages that belong to a given category.
#
#     .. rubric:: Required parameters
#
#     :PROJECT <url>: This argument tells where to fing the official repository project page of the wrapper. This is used to reference the wrapper project into the static site.
#
#     .. rubric:: Optional parameters
#
#     :ALLOWED_PLATFORMS <list of platforms>: This argument limits the set of platforms used for CI, only platforms specified will be managed in the CI process. WARNING: Due to gitlab limitation (only one pipeline can be defined) only ONE platform is allowed at the moment.
#     :DESCRIPTION <string>: This is a long(er) description of the wrapper that will be used for its documentation in static site.
#     :PUBLISH_BINARIES:  If this argument is used then the wrapper will automatically publish new binary versions to the publication site.
#     :FRAMEWORK <name of the framework>:  If this argument is set, then it means that the wrapper belongs to a framework. It will so contribute to the framework site. You must use either this argument or GIT one.
#     :GIT <repository address>: This is the address of the lone static site repository for the wrapper. It is used to automatically clone/update the static site of the wrapper. With this option the wrapper will not contribute to a framework but will have its own isolated deployment. You must use either this argument or FRAMEWORK one.
#     :PAGE <url>:  This is the online URL of the static site index page. Must be used if you use the GIT argument.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root CMakeLists.txt of the package, after declare_PID_Wrapper and before build_PID_Wrapper.
#        - This function must be called it has to be called after any other following functions: add_PID_Wrapper_Author, add_PID_Wrapper_Category and define_PID_Wrapper_Original_Project_Info.
#
#     .. admonition:: Effects
#        :class: important
#
#        - Generate or update a static site for the project. This static site locally resides in a dedicated git repository. If the project belongs to no framework then it has its lone static site that can be found in <pid-workspace>/sites/packages/<wrapper name>. If it belongs to a framework, the framework repository can be found in <pid-workspace>/sites/frameworks/<framework name>. In this later case, the wrapper only contributes to its own related content not the overall content of the framework.
#        - Depending on options it can also deploy binaries for target platform into the static site repository (framework or lone static site).
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        declare_PID_Wrapper_Publishing(
#              PROJECT https://gite.lirmm.fr/pid/boost
#			         FRAMEWORK pid
#			         DESCRIPTION boost is a PID wrapper for external project called Boost. Boost provides many libraries and templates to ease development in C++.
#			         PUBLISH_BINARIES
#			         ALLOWED_PLATFORMS x86_64_linux_abi11)
#
macro(declare_PID_Wrapper_Publishing)
set(optionArgs PUBLISH_BINARIES)
set(oneValueArgs PROJECT FRAMEWORK GIT PAGE)
set(multiValueArgs DESCRIPTION ALLOWED_PLATFORMS)
cmake_parse_arguments(DECLARE_PID_WRAPPER_PUBLISHING "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	#manage configuration of CI
if(DECLARE_PID_WRAPPER_PUBLISHING_ALLOWED_PLATFORMS)
	foreach(platform IN LISTS DECLARE_PID_WRAPPER_PUBLISHING_ALLOWED_PLATFORMS)
		allow_CI_For_Platform(${platform})
	endforeach()
	set(DO_CI TRUE)
else()
	set(DO_CI FALSE)
endif()

if(DECLARE_PID_WRAPPER_PUBLISHING_FRAMEWORK)
	if(NOT DECLARE_PID_WRAPPER_PUBLISHING_PROJECT)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell where to find the project page of the official package repository using PROJECT keyword.")
	endif()
	if(${PROJECT_NAME}_FRAMEWORK AND (NOT ${PROJECT_NAME}_FRAMEWORK STREQUAL ""))
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: a framework (${${PROJECT_NAME}_FRAMEWORK}) has already been defined, cannot define a new one !")
		return()
	elseif(${PROJECT_NAME}_SITE_GIT_ADDRESS AND (NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS STREQUAL ""))
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: a static site (${${PROJECT_NAME}_SITE_GIT_ADDRESS}) has already been defined, cannot define a framework !")
		return()
	endif()
	init_Documentation_Info_Cache_Variables("${DECLARE_PID_WRAPPER_PUBLISHING_FRAMEWORK}" "${DECLARE_PID_WRAPPER_PUBLISHING_PROJECT}" "" "" "${DECLARE_PID_WRAPPER_PUBLISHING_DESCRIPTION}")
	set(PUBLISH_DOC TRUE)
elseif(DECLARE_PID_WRAPPER_PUBLISHING_GIT)
	if(NOT DECLARE_PID_WRAPPER_PUBLISHING_PROJECT)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell where to find the project page of the official package repository using PROJECT keyword.")
	endif()
	if(NOT DECLARE_PID_WRAPPER_PUBLISHING_PAGE)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell where to find the index page for the static site of the package (using PAGE keyword).")
	endif()
	if(${PROJECT_NAME}_FRAMEWORK AND (NOT ${PROJECT_NAME}_FRAMEWORK STREQUAL ""))
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: a framework (${${PROJECT_NAME}_FRAMEWORK}) has already been defined, cannot define a static site !")
		return()
	elseif(${PROJECT_NAME}_SITE_GIT_ADDRESS AND (NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS STREQUAL ""))
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: a static site (${${PROJECT_NAME}_SITE_GIT_ADDRESS}) has already been defined, cannot define a new one !")
		return()
	endif()
	init_Documentation_Info_Cache_Variables("" "${DECLARE_PID_WRAPPER_PUBLISHING_PROJECT}" "${DECLARE_PID_WRAPPER_PUBLISHING_GIT}" "${DECLARE_PID_WRAPPER_PUBLISHING_PAGE}" "${DECLARE_PID_WRAPPER_PUBLISHING_DESCRIPTION}")
	set(PUBLISH_DOC TRUE)
else()
	set(PUBLISH_DOC FALSE)
endif()#otherwise there is no site contribution

#manage publication of binaries
if(DECLARE_PID_WRAPPER_PUBLISHING_PUBLISH_BINARIES)
	if(NOT PUBLISH_DOC)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you cannot publish binaries of the project (using PUBLISH_BINARIES) if you do not publish package ${PROJECT_NAME} using a static site (either use FRAMEWORK or SITE keywords).")
	endif()
	if(NOT DO_CI)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you cannot publish binaries of the project (using PUBLISH_BINARIES) if you do not allow any CI process for package ${PROJECT_NAME} (use ALLOWED_PLATFORMS to defines which platforms will be used in CI process).")
	endif()
	publish_Binaries(TRUE)
else()
	publish_Binaries(FALSE)
endif()
endmacro(declare_PID_Wrapper_Publishing)

#.rst:
#
# .. ifmode:: user
#
#  .. |build_PID_Wrapper| replace:: ``build_PID_Wrapper``
#  .. _build_PID_Wrapper:
#
#  build_PID_Wrapper
#  -------------------
#
#   .. command:: build_PID_Wrapper()
#
#      Configure the PID wrapper according to overall information.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        This function must be the last one called in the root CMakeList.txt file of the wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#        This function generates configuration files, manage the generation of the global build process and call CMakeLists.txt files of version folders contained in subfolder src.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        build_PID_Wrapper()
#
macro(build_PID_Wrapper)
if(${ARGC} GREATER 0)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the build_PID_Wrapper command requires no arguments.")
	return()
endif()
build_Wrapped_Project()
endmacro(build_PID_Wrapper)

########################################################################################
###############To be used in subfolders of the src folder ##############################
########################################################################################

#.rst:
#
# .. ifmode:: user
#
#  .. |add_PID_Wrapper_Known_Version| replace:: ``add_PID_Wrapper_Known_Version``
#  .. _add_PID_Wrapper_Known_Version:
#
#  add_PID_Wrapper_Known_Version
#  -----------------------------
#
#   .. command:: add_PID_Wrapper_Known_Version(VERSION ... DEPLOY ... [OPTIONS])
#
#      Declare a new version of the original project wrapped into PID system.
#
#     .. rubric:: Required parameters
#
#     :[VERSION] <version string>: tells which version of the external package is being wrapped. The version number must exactly match the name of the folder containing the CMakeLists.txt that does this call. The keyword version may be omitted is version is the first argument.
#     :DEPLOY <path to deploy script>: This is the path, relative to the current folder, to the deploy script used to build and install the external package version. Script must be a cmake module file.
#
#     .. rubric:: Optional parameters
#
#     :POSTINSTALL <path to install script>: This is the path, relative to the current folder, to the install script that will be run after external package version has been installed into the workspace, to perform additionnal configuration steps. Script is a cmake module file.
#     :COMPATIBILITY <version number>: define which previous version is compatible with this current version, if any. Compatible simply means that this current version can be used instead of the previous one without any restriction.
#     :SONAME <version number>: (useful on UNIX only) Specify which soname will be given by default to all shared libraries defined by the wrapper.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be the first one called in the CMakeList.txt file of a version folder.
#
#     .. admonition:: Effects
#        :class: important
#
#        Configure information about a specific version of the external package.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        add_PID_Wrapper_Known_Version(VERSION 1.55.0 DEPLOY deploy.cmake
#                              SONAME 1.55.0 #define the extension name to use for shared objects
#        )
#
#
macro(add_PID_Wrapper_Known_Version)
set(optionArgs)
set(oneValueArgs VERSION DEPLOY COMPATIBILITY SONAME POSTINSTALL)
set(multiValueArgs)
cmake_parse_arguments(ADD_PID_WRAPPER_KNOWN_VERSION "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT ADD_PID_WRAPPER_KNOWN_VERSION_VERSION)
  if("${ARGV0}" STREQUAL "" OR "${ARGV0}" MATCHES "^DEPLOY|COMPATIBILITY|SONAME|POSTINSTALL$")
    finish_Progress(GLOBAL_PROGRESS_VAR)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must define the version number using the VERSION keyword.")
  endif()
  set(version ${ARGV0})
else()
  set(version ${ADD_PID_WRAPPER_KNOWN_VERSION_VERSION})
endif()
if(NOT ADD_PID_WRAPPER_KNOWN_VERSION_DEPLOY)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must define the build script to use using the DEPLOY keyword.")
endif()

#verify the version information
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${version} OR NOT IS_DIRECTORY ${CMAKE_SOURCE_DIR}/src/${version})
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, no folder \"${version}\" can be found in src folder !")
	return()
endif()
list(FIND ${PROJECT_NAME}_KNOWN_VERSIONS ${version} INDEX)
if(NOT INDEX EQUAL -1)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, version \"${version}\" is already registered !")
	return()
endif()
#verify the script information
set(script_file ${ADD_PID_WRAPPER_KNOWN_VERSION_DEPLOY})
get_filename_component(RES_EXTENSION ${script_file} EXT)
if(NOT RES_EXTENSION MATCHES ".*\\.cmake$")
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, type of script file ${script_file} cannot be deduced from its extension only .cmake extensions supported")
	return()
endif()

if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${version}/${script_file})
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : cannot find script file ${script_file} in folder src/${version}/.")
	return()
endif()

#manage post install script
set(post_install_script)
if(ADD_PID_WRAPPER_KNOWN_VERSION_POSTINSTALL)
	set(post_install_script ${ADD_PID_WRAPPER_KNOWN_VERSION_POSTINSTALL})
	get_filename_component(RES_EXTENSION ${post_install_script} EXT)
	if(NOT RES_EXTENSION MATCHES ".*\\.cmake$")
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, type of script file ${script_file} cannot be deduced from its extension only .cmake extensions supported")
		return()
	endif()
	if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${version}/${post_install_script})
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : cannot find post install script file ${post_install_script} in folder src/${version}/.")
		return()
	endif()
endif()

if(ADD_PID_WRAPPER_KNOWN_VERSION_COMPATIBILITY)
	belongs_To_Known_Versions(PREVIOUS_VERSION_EXISTS ${ADD_PID_WRAPPER_KNOWN_VERSION_COMPATIBILITY})
	if(NOT PREVIOUS_VERSION_EXISTS)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : compatibility with previous version ${ADD_PID_WRAPPER_KNOWN_VERSION_COMPATIBILITY} is impossible since this version is not wrapped.")
		return()
	endif()
	set(compatible_with_version ${ADD_PID_WRAPPER_KNOWN_VERSION_COMPATIBILITY})
endif()
add_Known_Version("${version}" "${script_file}" "${compatible_with_version}" "${ADD_PID_WRAPPER_KNOWN_VERSION_SONAME}" "${post_install_script}")
endmacro(add_PID_Wrapper_Known_Version)

#.rst:
#
# .. ifmode:: user
#
#  .. |declare_PID_Wrapper_Platform_Configuration| replace:: ``declare_PID_Wrapper_Platform_Configuration``
#  .. _declare_PID_Wrapper_Platform_Configuration:
#
#  declare_PID_Wrapper_Platform_Configuration
#  ------------------------------------------
#
#   .. command:: declare_PID_Wrapper_Platform_Configuration(CONFIGURATION ... [PLATFORM ...])
#
#      Declare a platform configuration constraint for the current version of the external project being described.
#
#     .. rubric:: Required parameters
#
#     :CONFIGURATION <list of configurations>: tells which version of the external package is being wrapped. The version number must exactly match the name of the folder containing the CMakeLists.txt that does this call.
#
#     .. rubric:: Optional parameters
#
#     :PLATFORM <platform name>: Use to apply the configuration constraints only to the target platform.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the CMakeList.txt file of a version folder after add_PID_Wrapper_Known_Version.
#
#     .. admonition:: Effects
#        :class: important
#
#         - Configure the check of a set of platform configurations that will be perfomed when the given wrapper version is built.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        declare_PID_Wrapper_Platform_Configuration(CONFIGURATION posix)
#
macro(declare_PID_Wrapper_Platform_Configuration)
set(oneValueArgs PLATFORM)
set(multiValueArgs CONFIGURATION)
cmake_parse_arguments(DECLARE_PID_WRAPPER_PLATFORM "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_PLATFORM_CONFIGURATION)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, declare_PID_Wrapper_Platform requires at least to define a required configuration using CONFIGURATION keyword.")
	return()
endif()
declare_Wrapped_Configuration("${DECLARE_PID_WRAPPER_PLATFORM_PLATFORM}" "${DECLARE_PID_WRAPPER_PLATFORM_CONFIGURATION}")
endmacro(declare_PID_Wrapper_Platform_Configuration)

#.rst:
#
# .. ifmode:: user
#
#  .. |declare_PID_Wrapper_External_Dependency| replace:: ``declare_PID_Wrapper_External_Dependency``
#  .. _declare_PID_Wrapper_External_Dependency:
#
#  declare_PID_Wrapper_External_Dependency
#  ---------------------------------------
#
#   .. command:: declare_PID_Wrapper_External_Dependency([PACKAGE] ... [[EXACT] VERSION ...]...)
#
#   .. command:: declare_PID_Wrapper_Dependency([PACKAGE] ... [[EXACT] VERSION ...]...)
#
#     Declare a dependency between the currently described version of the external package and another external package.
#
#     .. rubric:: Required parameters
#
#     :[PACKAGE] <string>: defines the unique identifier of the required package. The keyword PACKAGE may be omitted if name is the first argument.
#
#     .. rubric:: Optional parameters
#
#     :VERSION <version string>: dotted notation of a version, representing which version of the external package is required. May be use many times.
#     :EXACT: use to specify if the following version must be exac. May be used for earch VERSION specification.
#     :COMPONENTS <list of components>: Used to specify which components of the required external package will be used by local components. If not specified there will be no check for the presence of specific components in the required package.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the CMakeList.txt file of a version folder after add_PID_Wrapper_Known_Version.
#
#     .. admonition:: Effects
#        :class: important
#
#         - Register the target package as a dependency of the current package.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        declare_PID_Wrapper_External_Dependency (PACKAGE boost EXACT VERSION 1.55.0 EXACT VERSION 1.63.0 EXACT VERSION 1.64.0)
#
macro(declare_PID_Wrapper_Dependency)
  declare_PID_Wrapper_External_Dependency(${ARGN})
endmacro(declare_PID_Wrapper_Dependency)

macro(declare_PID_Wrapper_External_Dependency)
set(options )
set(oneValueArgs PACKAGE)
set(multiValueArgs) #known versions of the external package that can be used to build/run it
cmake_parse_arguments(DECLARE_PID_WRAPPER_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_DEPENDENCY_PACKAGE)
  if("${ARGV0}" STREQUAL "" OR "${ARGV0}" MATCHES "^EXACT|VERSION$")
    finish_Progress(GLOBAL_PROGRESS_VAR)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, declare_PID_Wrapper_External_Dependency requires to define the name of the dependency by using PACKAGE keyword.")
  	return()
  endif()
  set(package_name ${ARGV0})
  if(DECLARE_PID_WRAPPER_DEPENDENCY_UNPARSED_ARGUMENTS)
    list(REMOVE_ITEM DECLARE_PID_WRAPPER_DEPENDENCY_UNPARSED_ARGUMENTS "${package_name}")
  endif()
else()
  set(package_name ${DECLARE_PID_WRAPPER_DEPENDENCY_PACKAGE})
endif()
if(package_name STREQUAL PROJECT_NAME)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, package ${package_name} cannot require itself !")
	return()
endif()
set(list_of_versions)
set(exact_versions)
if(DECLARE_PID_WRAPPER_DEPENDENCY_UNPARSED_ARGUMENTS)#there are still arguments to parse
  set(TO_PARSE "${DECLARE_PID_WRAPPER_DEPENDENCY_UNPARSED_ARGUMENTS}")
	set(RES_VERSION TRUE)
	while(TO_PARSE AND RES_VERSION)
		parse_Package_Dependency_Version_Arguments("${TO_PARSE}" RES_VERSION RES_EXACT TO_PARSE)
		if(RES_VERSION)
			list(APPEND list_of_versions ${RES_VERSION})
			if(RES_EXACT)
				list(APPEND exact_versions ${RES_VERSION})
			endif()
		elseif(RES_EXACT)
      finish_Progress(GLOBAL_PROGRESS_VAR)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency to external package ${package_name}, you must use the EXACT keyword together with the VERSION keyword.")
			return()
		endif()
	endwhile()
endif()
set(list_of_components)
if(TO_PARSE) #there are still expression to parse
	set(oneValueArgs)
	set(options)
	set(multiValueArgs COMPONENTS)
	cmake_parse_arguments(DECLARE_PID_WRAPPER_DEPENDENCY_MORE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${TO_PARSE})
	if(DECLARE_PID_WRAPPER_DEPENDENCY_MORE_COMPONENTS)
		list(LENGTH DECLARE_PID_WRAPPER_DEPENDENCY_COMPONENTS SIZE)
		if(SIZE LESS 1)
      finish_Progress(GLOBAL_PROGRESS_VAR)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency to external package ${package_name}, at least one component dependency must be defined when using the COMPONENTS keyword.")
			return()
		endif()
		set(list_of_components ${DECLARE_PID_WRAPPER_DEPENDENCY_MORE_COMPONENTS})
	else()
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] WARNING : when declaring dependency to external package ${package_name}, unknown arguments used ${DECLARE_PID_WRAPPER_DEPENDENCY_MORE_UNPARSED_ARGUMENTS}.")
	endif()
endif()

declare_Wrapped_External_Dependency("${package_name}" "${list_of_versions}" "${exact_versions}" "${list_of_components}")
endmacro(declare_PID_Wrapper_External_Dependency)

#.rst:
#
# .. ifmode:: user
#
#  .. |declare_PID_Wrapper_Component| replace:: ``declare_PID_Wrapper_Component``
#  .. _declare_PID_Wrapper_Component:
#
#  declare_PID_Wrapper_Component
#  -----------------------------
#
#   .. command:: declare_PID_Wrapper_Component(COMPONENT ... [OPTIONS])
#
#     Declare a new component for the current version of the external package.
#
#     .. rubric:: Required parameters
#
#     :[COMPONENT] <string w/o withespaces>: defines the unique identifier of the component. The COMPONENT keyword may be omnitted if name if the first argument.
#
#     .. rubric:: Optional parameters
#
#     :C_STANDARD <number of standard>: This argument is followed by the version of the C language standard to be used to build this component. The values may be 90, 99 or 11.
#     :CXX_STANDARD <number of standard>: his argument is followed by the version of the C++ language standard to be used to build this component. The values may be 98, 11, 14 or 17. If not specified the version 98 is used.
#     :DEFINITIONS <defs>: These are the preprocessor definitions used in the component’s interface.
#     :INCLUDES <folders>: These are the include folder to pass to any component using the current component. Path are interpreted relative to the installed external package version root folder.
#     :SHARED_LINKS <links>: These are shared link flags. Path are interpreted relative to the installed external package version root folder.
#     :STATIC_LINKS <links>: These are static link flags. Path are interpreted relative to the installed external package version root folder.
#     :OPTIONS <compile options>: These are compiler options to be used whenever a third party code use this component. This should be used only for options bound to compiler usage, not definitions or include directories.
#     :RUNTIME_RESOURCES <list of path>: This argument is followed by a list of path relative to the installed external package version root folder.
#     :EXPORT ...: list of components that are exported by the declared component. Each element has the pattern [<package name>/]<component_name>.
#     :DEPENDS ...: list of components that the declared component depends on. Each element has the pattern [<package name>/]<component_name>.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - Must be called in the CMakeList.txt file of a version folder after add_PID_Wrapper_Known_Version and before any call to declare_PID_Wrapper_Component_Dependency applied to the same declared component.
#
#     .. admonition:: Effects
#        :class: important
#
#         - Define a component for the current external package version, which is mainly usefull to register all compilation options relative to a component.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        declare_PID_Wrapper_Component(COMPONENT libyaml INCLUDES include SHARED_LINKS ${posix_LINK_OPTIONS} lib/libyaml-cpp)
#
macro(declare_PID_Wrapper_Component)
set(oneValueArgs COMPONENT C_STANDARD CXX_STANDARD SONAME)
set(multiValueArgs INCLUDES SHARED_LINKS STATIC_LINKS DEFINITIONS OPTIONS RUNTIME_RESOURCES EXPORT DEPENDS) #known versions of the external package that can be used to build/run it
cmake_parse_arguments(DECLARE_PID_WRAPPER_COMPONENT "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_COMPONENT_COMPONENT)
  if("${ARGV0}" STREQUAL "" OR "${ARGV0}" MATCHES "^CXX_STANDARD|C_STANDARD|SONAME|INCLUDES|SHARED_LINKS|STATIC_LINKS|DEFINITIONS|OPTIONS|RUNTIME_RESOURCES$")
    finish_Progress(GLOBAL_PROGRESS_VAR)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, declare_PID_Wrapper_Component requires to define the name of the component by using COMPONENT keyword.")
  	return()
  endif()
  set(component_name ${ARGV0})
else()
  set(component_name ${DECLARE_PID_WRAPPER_COMPONENT_COMPONENT})
endif()

declare_Wrapped_Component(${component_name}
  "${DECLARE_PID_WRAPPER_COMPONENT_SHARED_LINKS}"
  "${DECLARE_PID_WRAPPER_COMPONENT_SONAME}"
	"${DECLARE_PID_WRAPPER_COMPONENT_STATIC_LINKS}"
	"${DECLARE_PID_WRAPPER_COMPONENT_INCLUDES}"
	"${DECLARE_PID_WRAPPER_COMPONENT_DEFINITIONS}"
	"${DECLARE_PID_WRAPPER_COMPONENT_OPTIONS}"
	"${DECLARE_PID_WRAPPER_COMPONENT_C_STANDARD}"
	"${DECLARE_PID_WRAPPER_COMPONENT_CXX_STANDARD}"
	"${DECLARE_PID_WRAPPER_COMPONENT_RUNTIME_RESOURCES}")


#dealing with dependencies
if(DECLARE_PID_WRAPPER_COMPONENT_EXPORT)#exported dependencies
  foreach(dep IN LISTS DECLARE_PID_WRAPPER_COMPONENT_EXPORT)
    extract_Component_And_Package_From_Dependency_String(RES_COMP RES_PACK ${dep})
    if(RES_PACK)
      set(COMP_ARGS "${RES_COMP};PACKAGE;${RES_PACK}")
    else()
      set(COMP_ARGS ${RES_COMP})
    endif()
    declare_PID_Wrapper_Component_Dependency(COMPONENT ${component_name} EXPORT EXTERNAL ${COMP_ARGS})
  endforeach()
endif()

if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDS)#non exported dependencies
  foreach(dep IN LISTS DECLARE_PID_WRAPPER_COMPONENT_DEPENDS)
    extract_Component_And_Package_From_Dependency_String(RES_COMP RES_PACK ${dep})
    if(RES_PACK)
      set(COMP_ARGS "${RES_COMP};PACKAGE;${RES_PACK}")
    else()
      set(COMP_ARGS ${RES_COMP})
    endif()
    declare_PID_Wrapper_Component_Dependency(COMPONENT ${component_name} DEPENDS EXTERNAL ${COMP_ARGS})
    endforeach()
endif()

endmacro(declare_PID_Wrapper_Component)

#.rst:
#
# .. ifmode:: user
#
#  .. |declare_PID_Wrapper_Component_Dependency| replace:: ``declare_PID_Wrapper_Component_Dependency``
#  .. _declare_PID_Wrapper_Component_Dependency:
#
#  declare_PID_Wrapper_Component_Dependency
#  ----------------------------------------
#
#   .. command:: declare_PID_Wrapper_Component_Dependency([COMPONENT] ... [OPTIONS])
#
#     Declare a dependency for a component defined in the current version of the current external package.
#
#     .. rubric:: Required parameters
#
#     :[COMPONENT] <string w/o withespaces>: defines the unique identifier of the component for which a dependency is described. The keyword COMPONENT may be omitted if name is given as first argument.
#
#     .. rubric:: Optional parameters
#
#     :EXPORT: Tells whether the component exports the required dependency. Exporting means that the reference to the dependency is contained in its interface (header files). This can be only the case for libraries, not for applications.
#
#     :DEPENDS: Tells whether the component depends on but do not export the required dependency. Exporting means that the reference to the dependency is contained in its interface (header files).
#
#     :[EXTERNAL] <dependency>: This is the name of the component whose component <name> depends on. EXTERNAL keyword may be omitted if EXPORT or DEPENDS keyword are used.
#
#     :PACKAGE <name>: This is the name of the external package the dependency belongs to. This package must have been defined has a package dependency before this call. If this argument is not used, the dependency belongs to the current package (i.e. internal dependency).
#
#     :DEFINITIONS <definitions>:  List of definitions exported by the component. These definitions are supposed to be managed in the dependency's heaedr files, but are set by current component.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - Must be called in the CMakeList.txt file of a version folder after add_PID_Wrapper_Known_Version and after any call to declare_PID_Wrapper_Component applied to the same declared component.
#
#     .. admonition:: Effects
#        :class: important
#
#         -  Define and configure a dependency between a component in the current external package version and another component.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        declare_PID_Wrapper_Component_Dependency(COMPONENT libyaml EXPORT EXTERNAL boost-headers PACKAGE boost)
#
macro(declare_PID_Wrapper_Component_Dependency)
set(options EXPORT DEPENDS)
set(oneValueArgs COMPONENT EXTERNAL PACKAGE)
set(multiValueArgs INCLUDES SHARED_LINKS STATIC_LINKS DEFINITIONS OPTIONS)
cmake_parse_arguments(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_COMPONENT)
  if("${ARGV0}" STREQUAL "" OR "${ARGV0}" MATCHES "^EXPORT|DEPENDS|EXTERNAL|PACKAGE|INCLUDES|SHARED_LINKS|STATIC_LINKS|DEFINITIONS|OPTIONS$")
    finish_Progress(GLOBAL_PROGRESS_VAR)
    message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, declare_PID_Wrapper_Component_Dependency requires to define the name of the declared component using the COMPONENT keyword or by giving the name as first argument.")
    return()
  endif()
  set(component_name ${ARGV0})
  message("")
  if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS)
    list(REMOVE_ITEM DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS ${ARGV0})
  endif()
else()
  set(component_name ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_COMPONENT})
endif()

if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXPORT AND DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEPENDS)
  finish_Progress(GLOBAL_PROGRESS_VAR)
  message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling declare_PID_Wrapper_Component_Dependency, EXPORT and DEPENDS keywords cannot be used in same time.")
  return()
endif()

if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXPORT)
	set(exported TRUE)
else()
	set(exported FALSE)
endif()

message("package=${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE} external=${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXTERNAL}")
if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE) #this is a dependency to another external package
	list(FIND ${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCIES ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE} INDEX)
	if(INDEX EQUAL -1)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling declare_PID_Wrapper_Component_Dependency, the component ${component_name} depends on external package ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE} that is not defined as a dependency of the current project.")
		return()
	endif()
	if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXTERNAL)

		declare_Wrapped_Component_Dependency_To_Explicit_Component(${component_name}
			${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE}
			${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXTERNAL}
			${exported}
			"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEFINITIONS}"
		)
	else()#EXTERNAL keyword not used but it is optional
    if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS
      AND (DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXPORT OR DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEPENDS))

      list(GET DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS 0 target_component)
      declare_Wrapped_Component_Dependency_To_Explicit_Component(${component_name}
  			${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE}
  			${target_component}
  			${exported}
  			"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEFINITIONS}"
  		)
    else()
      declare_Wrapped_Component_Dependency_To_Implicit_Components(${component_name}
        ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE} #everything exported by default
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_INCLUDES}"
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_SHARED_LINKS}"
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_STATIC_LINKS}"
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEFINITIONS}"
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_OPTIONS}"
      )
    endif()
	endif()
else()#this is a dependency to another component defined in the same external package
	if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXTERNAL)
    set(target_component ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXTERNAL})
  else()
    if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS
      AND (DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXPORT OR DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEPENDS))

      list(GET DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS 0 target_component)
    else()
      finish_Progress(GLOBAL_PROGRESS_VAR)
  		message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling declare_PID_Wrapper_Component_Dependency, need to define the component used by ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_COMPONENT}, by using the keyword EXTERNAL.")
  		return()
    endif()
	endif()
  message("component name = ${component_name} target_component=${target_component}")
	declare_Wrapped_Component_Internal_Dependency(${component_name}
		${target_component}
		${exported}
		"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEFINITIONS}"
	)
endif()
endmacro(declare_PID_Wrapper_Component_Dependency)


#########################################################################################
######################## API to be used in deploy scripts ###############################
#########################################################################################

function(translate_Into_Options)
set(options)
set(oneValueArgs C_STANDARD CXX_STANDARD FLAGS)
set(multiValueArgs INCLUDES DEFINITIONS)
cmake_parse_arguments(TRANSLATE_INTO_OPTION "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT TRANSLATE_INTO_OPTION_FLAGS)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling translate_Into_Options, need to define the variable where to return flags by using the FLAGS keyword.")
	return()
endif()
set(result "")
if(TRANSLATE_INTO_OPTION_INCLUDES)
	foreach(an_include IN LISTS TRANSLATE_INTO_OPTION_INCLUDES)
		set(result "${result} -I${an_include}")
	endforeach()
endif()
if(TRANSLATE_INTO_OPTION_DEFINITIONS)
	foreach(a_def IN LISTS TRANSLATE_INTO_OPTION_DEFINITIONS)
		set(result "${result} -D${a_def}")
	endforeach()
endif()

if(TRANSLATE_INTO_OPTION_C_STANDARD OR TRANSLATE_INTO_OPTION_CXX_STANDARD)
	translate_Standard_Into_Option(RES_C_STD_OPT RES_CXX_STD_OPT "${TRANSLATE_INTO_OPTION_C_STANDARD}" "${TRANSLATE_INTO_OPTION_CXX_STANDARD}")
	if(RES_C_STD_OPT)
		set(result "${result} ${RES_C_STD_OPT}")
	endif()
	if(RES_CXX_STD_OPT)
		set(result "${result} ${RES_CXX_STD_OPT}")
	endif()
endif()
set(${TRANSLATE_INTO_OPTION_FLAGS} ${result} PARENT_SCOPE)
endfunction(translate_Into_Options)

#.rst:
#
# .. ifmode:: user
#
#  .. |get_External_Dependencies_Info| replace:: ``get_External_Dependencies_Info``
#  .. _get_External_Dependencies_Info:
#
#  get_External_Dependencies_Info
#  ----------------------------------------
#
#   .. command:: get_External_Dependencies_Info([OPTIONS])
#
#     Allow to get info defined in description of the currenlty built version.
#
#     .. rubric:: Optional parameters
#
#     :PACKAGE <ext_package>: Target external package that is a dependency of the currently built package, for which we want specific information. Used as a filter to limit information to those relative to the dependency.
#     :ROOT <returned path>: The variable passed as argument will be filled with the path to the dependency external package version. Must be used together with PACKAGE.
#     :OPTIONS <returned options>: The variable passed as argument will be filled with compiler options for the external package version being built.
#     :INCLUDES <returned includes>: The variable passed as argument will be filled with include folders for the external package version being built.
#     :DEFINITIONS <returned defs>: The variable passed as argument will be filled with all definitions for the external package version being built.
#     :LINKS <returned links>: The variable passed as argument will be filled with all path to librairies and linker options for the external package version being built.
#     :C_STANDARD <returned c_std>: The variable passed as argument will be filled with the C language standard to use for the external package version, if any specified.
#     :CXX_STANDARD <returned cxx_std>: The variable passed as argument will be filled with the CXX language standard to use for the external package version, if any specified.
#     :FLAGS: option to get result of all preceeding arguments directly as compiler flags instead of CMake variables.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - Must be used in deploy scripts defined in a wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#         -  This function has no side effect but simply allow the wrapper build process to get some information about the package it is trying to build. Indeed, building an external package may require to have precise information about package description in order to use adequate compilation flags.
#
#     .. rubric:: Example
#
#     Example of deploy script used for the yaml-cpp wrapper:
#
#     .. code-block:: cmake
#
#        get_External_Dependencies_Info(INCLUDES all_includes)
#        execute_process(COMMAND ${CMAKE_COMMAND} -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=${TARGET_INSTALL_DIR} -DBoost_INCLUDE_DIR=${all_includes} .. WORKING_DIRECTORY ${YAML_BUILD_DIR})
#
function(get_External_Dependencies_Info)
set(options FLAGS)
set(oneValueArgs PACKAGE ROOT C_STANDARD CXX_STANDARD)
set(multiValueArgs OPTIONS INCLUDES DEFINITIONS LINKS)
cmake_parse_arguments(GET_EXTERNAL_DEPENDENCY_INFO "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

#build the version prefix using variables automatically configured in Build_PID_Wrapper script
#for cleaner description at next lines only
set(prefix ${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSION_${TARGET_EXTERNAL_VERSION})

if(GET_EXTERNAL_DEPENDENCY_INFO_ROOT)
	if(NOT GET_EXTERNAL_DEPENDENCY_INFO_PACKAGE)
    finish_Progress(GLOBAL_PROGRESS_VAR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_External_Dependency_Info, need to define the external package by using the keyword PACKAGE.")
		return()
	endif()
	set(dep_version ${${prefix}_DEPENDENCY_${GET_EXTERNAL_DEPENDENCY_INFO_PACKAGE}_VERSION_USED_FOR_BUILD})
	set(ext_package_root ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${GET_EXTERNAL_DEPENDENCY_INFO_PACKAGE}/${dep_version})
	set(${GET_EXTERNAL_DEPENDENCY_INFO_ROOT} ${ext_package_root} PARENT_SCOPE)
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES)
	if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
		translate_Into_Options(INCLUDES ${${prefix}_BUILD_INCLUDES} FLAGS RES_INCLUDES)
		set(${GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES} ${RES_INCLUDES} PARENT_SCOPE)
	else()
  	set(${GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES} ${${prefix}_BUILD_INCLUDES} PARENT_SCOPE)
	endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_DEFINITIONS)
	if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
		translate_Into_Options(DEFINITIONS ${${prefix}_BUILD_DEFINITIONS} FLAGS RES_DEFS)
		set(${GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES} ${RES_DEFS} PARENT_SCOPE)
	else()
	  set(${GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES} ${${prefix}_BUILD_DEFINITIONS} PARENT_SCOPE)
	endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_OPTIONS)
  set(${GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES} ${${prefix}_BUILD_COMPILER_OPTIONS} PARENT_SCOPE)
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_C_STANDARD)
	if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
		translate_Into_Options(C_STANDARD ${${prefix}_BUILD_C_STANDARD} FLAGS RES_C_STD)
		set(${GET_EXTERNAL_DEPENDENCY_INFO_C_STANDARD} ${RES_C_STD} PARENT_SCOPE)
	else()
	  set(${GET_EXTERNAL_DEPENDENCY_INFO_C_STANDARD} ${${prefix}_BUILD_C_STANDARD} PARENT_SCOPE)
	endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_CXX_STANDARD)
	if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
		translate_Into_Options(CXX_STANDARD ${${prefix}_BUILD_CXX_STANDARD} FLAGS RES_CXX_STD)
		set(${GET_EXTERNAL_DEPENDENCY_INFO_CXX_STANDARD} ${RES_CXX_STD} PARENT_SCOPE)
	else()
	  set(${GET_EXTERNAL_DEPENDENCY_INFO_CXX_STANDARD} ${${prefix}_BUILD_CXX_STANDARD} PARENT_SCOPE)
	endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_LINKS)
  set(${GET_EXTERNAL_DEPENDENCY_INFO_LINKS} ${${prefix}_BUILD_LINKS} PARENT_SCOPE)
endif()

endfunction(get_External_Dependencies_Info)

#.rst:
#
# .. ifmode:: user
#
#  .. |get_User_Option_Info| replace:: ``get_User_Option_Info``
#  .. _get_User_Option_Info:
#
#  get_User_Option_Info
#  --------------------
#
#   .. command:: get_User_Option_Info(COMPONENT ... [OPTIONS])
#
#     Allow to get info defined and set by user of the wrapper into deploy script when a wrapper version is built.
#
#     .. rubric:: Required parameters
#
#     :OPTION <variable>: Target option we need to get the value into the deploy script.
#     :RESULT <returned variable>: The variable passed as argument will be filled with the value of the target user option's value.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - Must be used in deploy scripts defined in a wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#         -  This function has no side effect but simply allow the wrapper build process to get some information about the package it is trying to build. Indeed, building an external package may require additional configuration from the user in order to use adequate compilation flags.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        get_User_Option_Info(OPTION BUILD_WITH_CUDA_SUPPORT RESULT using_cuda)
#        if(using_cuda)
#          build_process_using_CUDA(...)
#        else()
#          build_process_without_CUDA(...)
#        endif()
#
function(get_User_Option_Info)
set(oneValueArgs OPTION RESULT)
cmake_parse_arguments(GET_USER_OPTION_INFO "" "${oneValueArgs}" "" ${ARGN} )
if(NOT GET_USER_OPTION_INFO_OPTION)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_User_Option_Info, need to define the name of the option by using the keyword OPTION.")
	return()
endif()
if(NOT GET_USER_OPTION_INFO_RESULT)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_User_Option_Info, need to define the variable that will receive the value of the option by using the keyword RESULT.")
	return()
endif()
if(NOT ${TARGET_EXTERNAL_PACKAGE}_USER_OPTIONS)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_User_Option_Info, no user option is defined in the wrapper ${TARGET_EXTERNAL_PACKAGE}.")
	return()
endif()
list(FIND ${TARGET_EXTERNAL_PACKAGE}_USER_OPTIONS ${GET_USER_OPTION_INFO_OPTION} INDEX)
if(INDEX EQUAL -1)
  finish_Progress(GLOBAL_PROGRESS_VAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_User_Option_Info, no user option with name ${GET_USER_OPTION_INFO_OPTION} is defined in the wrapper ${TARGET_EXTERNAL_PACKAGE}.")
	return()
endif()
set(${GET_USER_OPTION_INFO_RESULT} ${${TARGET_EXTERNAL_PACKAGE}_USER_OPTION_${GET_USER_OPTION_INFO_OPTION}_VALUE} PARENT_SCOPE)
endfunction(get_User_Option_Info)

###

#.rst:
#
# .. ifmode:: user
#
#  .. |get_Environment_Info| replace:: ``get_Environment_Info``
#  .. _get_Environment_Info:
#
#  get_Environment_Info
#  --------------------
#
#   .. command:: get_Environment_Info(COMPONENT ... [OPTIONS])
#
#     Getting all options and flags (compiler in use, basic flags for each type of component, and so on) defined by the current environment, to be able to access them in the deploy script.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - Must be used in deploy scripts defined in a wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#         -  This function has no side effect but simply allow the wrapper build process to get some information about the package it is trying to build.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        get_Environment_Info(MAKE make_tool JOBS jobs-flag CXX COMPILER compiler_used CFLAGS compile_flags SHARED LDFLAGS linker_flags)
#
#
function(get_Environment_Info)
  set(options MODULE SHARED STATIC EXE DEBUG RELEASE C CXX ASM) #used to define the context
  set(oneValueArgs COMPILER AR LINKER MAKE RANLIB JOBS) #returned values conditionned by options
  set(multiValueArgs CFLAGS LDFLAGS) #returned values conditionned by options
  cmake_parse_arguments(GET_ENVIRONMENT_INFO "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  #returning flag to use with make tool
  if(GET_ENVIRONMENT_INFO_JOBS)
    include(ProcessorCount)
    ProcessorCount(NUMBER_OF_JOBS)
    math(EXPR NUMBER_OF_JOBS ${NUMBER_OF_JOBS}+1)
    if(${NUMBER_OF_JOBS} GREATER 1)
    	set(${GET_ENVIRONMENT_INFO_JOBS} "-j${NUMBER_OF_JOBS}" PARENT_SCOPE)
    else()
    	set(${GET_ENVIRONMENT_INFO_JOBS} "" PARENT_SCOPE)
    endif()
  endif()

  #returning info about tools in use (usefull when crosscompiling for instance)
  if(GET_ENVIRONMENT_INFO_COMPILER)
    if(GET_ENVIRONMENT_INFO_C)
      set(${GET_ENVIRONMENT_INFO_COMPILER} ${CMAKE_C_COMPILER} PARENT_SCOPE)
    elseif(GET_ENVIRONMENT_INFO_CXX)
      set(${GET_ENVIRONMENT_INFO_COMPILER} ${CMAKE_CXX_COMPILER} PARENT_SCOPE)
    elseif(GET_ENVIRONMENT_INFO_ASM)
      set(${GET_ENVIRONMENT_INFO_COMPILER} ${CMAKE_ASM_COMPILER} PARENT_SCOPE)
    else()
      message(FATAL_ERROR "[PID] CRITICAL ERROR : When trying to get compiler in use you must specify the target language (C, CXX or ASM).")
    	return()
    endif()
  endif()
  if(GET_ENVIRONMENT_INFO_AR)
    set(${GET_ENVIRONMENT_INFO_AR} ${CMAKE_AR} PARENT_SCOPE)
  endif()
  if(GET_ENVIRONMENT_INFO_LINKER)
    set(${GET_ENVIRONMENT_INFO_LINKER} ${CMAKE_LINKER} PARENT_SCOPE)
  endif()
  if(GET_ENVIRONMENT_INFO_RANLIB)
    set(${GET_ENVIRONMENT_INFO_RANLIB} ${CMAKE_RANLIB} PARENT_SCOPE)
  endif()
  if(GET_ENVIRONMENT_INFO_MAKE)
    set(${GET_ENVIRONMENT_INFO_MAKE} ${CMAKE_MAKE_PROGRAM} PARENT_SCOPE)
  endif()

  if(GET_ENVIRONMENT_INFO_CFLAGS)
    if(GET_ENVIRONMENT_INFO_C)
      set(list_of_flags ${CMAKE_C_FLAGS})
      set(is_cxx FALSE)
    elseif(GET_ENVIRONMENT_INFO_CXX)
      set(is_cxx TRUE)
      set(list_of_flags ${CMAKE_CXX_FLAGS})
    else()
      message(FATAL_ERROR "[PID] CRITICAL ERROR : When trying to get CFLAGS in use you must specify the target language (C, CXX).")
      return()
    endif()
    if(NOT GET_ENVIRONMENT_INFO_DEBUG OR GET_ENVIRONMENT_INFO_RELEASE)
      if(is_cxx)
        list(APPEND list_of_flags ${CMAKE_CXX_FLAGS_RELEASE})
      else()
        list(APPEND list_of_flags ${CMAKE_C_FLAGS_RELEASE})
      endif()
    else()
      if(is_cxx)
        list(APPEND list_of_flags ${CMAKE_CXX_FLAGS_DEBUG})
      else()
        list(APPEND list_of_flags ${CMAKE_C_FLAGS_DEBUG})
      endif()
    endif()
    fill_String_From_List("${list_of_flags}" cflags_string)
    set(${GET_ENVIRONMENT_INFO_CFLAGS} "${cflags_string}" PARENT_SCOPE)
  endif() #end for c flags

  if(GET_ENVIRONMENT_INFO_LDFLAGS)#now flags for the linker
    if(NOT GET_ENVIRONMENT_INFO_DEBUG OR GET_ENVIRONMENT_INFO_RELEASE)
      set(suffix _RELEASE)
    else()
      set(suffix _DEBUG)
    endif()
    if(GET_ENVIRONMENT_INFO_MODULE)
      set(ldflags_list ${CMAKE_MODULE_LINKER_FLAGS})
      list(APPEND ldflags_list ${CMAKE_MODULE_LINKER_FLAGS${suffix}})
      fill_String_From_List("${ldflags_list}" ldflags_string)
      set(${GET_ENVIRONMENT_INFO_LDFLAGS} "${ldflags_string}" PARENT_SCOPE)
    elseif(GET_ENVIRONMENT_INFO_SHARED)
      set(ldflags_list ${CMAKE_SHARED_LINKER_FLAGS})
      list(APPEND ldflags_list ${CMAKE_SHARED_LINKER_FLAGS${suffix}})
      fill_String_From_List("${ldflags_list}" ldflags_string)
      set(${GET_ENVIRONMENT_INFO_LDFLAGS} "${ldflags_string}" PARENT_SCOPE)
    elseif(GET_ENVIRONMENT_INFO_STATIC)
      set(ldflags_list ${CMAKE_STATIC_LINKER_FLAGS})
      list(APPEND ldflags_list ${CMAKE_STATIC_LINKER_FLAGS${suffix}})
      fill_String_From_List("${ldflags_list}" ldflags_string)
      set(${GET_ENVIRONMENT_INFO_LDFLAGS} "${ldflags_string}" PARENT_SCOPE)
    elseif(GET_ENVIRONMENT_INFO_EXE)
      set(ldflags_list ${CMAKE_EXE_LINKER_FLAGS})
      list(APPEND ldflags_list ${CMAKE_EXE_LINKER_FLAGS${suffix}})
      fill_String_From_List("${ldflags_list}" ldflags_string)
      set(${GET_ENVIRONMENT_INFO_LDFLAGS} "${ldflags_string}" PARENT_SCOPE)
    else()
      message(FATAL_ERROR "[PID] CRITICAL ERROR : When trying to get LDFLAGS in use you must specify the kind of component you try to build (MODULE, SHARED, STATIC or EXE).")
    	return()
    endif()
  endif()
endfunction(get_Environment_Info)
