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
if(PACKAGE_DEFINITION_INCLUDED)
  return()
endif()
set(PACKAGE_DEFINITION_INCLUDED TRUE)
##########################################################################################

cmake_minimum_required(VERSION 3.15.7)

# prevent CMake automatic detection messages from appearing
set(CMAKE_MESSAGE_LOG_LEVEL NOTICE CACHE INTERNAL "")

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake)
get_filename_component(abs_path_to_ws ${WORKSPACE_DIR} ABSOLUTE)
set(WORKSPACE_DIR ${abs_path_to_ws} CACHE PATH "" FORCE)

get_filename_component(the_project ${CMAKE_SOURCE_DIR} NAME)
if(EXISTS ${WORKSPACE_DIR}/build/${the_project}_PID_Toolchain.cmake)#use a project specific toolchain if it exists
  set(CMAKE_TOOLCHAIN_FILE ${WORKSPACE_DIR}/build/${the_project}_PID_Toolchain.cmake CACHE INTERNAL "" FORCE)
else()
  set(CMAKE_TOOLCHAIN_FILE ${WORKSPACE_DIR}/build/PID_Toolchain.cmake CACHE INTERNAL "" FORCE)
endif()

include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Package_API_Internal_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(CMakeParseArguments)

stop_Make_To_Print_Directories()

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Package| replace:: ``PID_Package``
#  .. _PID_Package:
#
#  PID_Package
#  -----------
#
#   .. command:: PID_Package(AUTHOR ... YEAR ... LICENSE ... DESCRIPTION ... [OPTIONS])
#
#   .. command:: declare_PID_Package(AUTHOR ... YEAR ... LICENSE ... DESCRIPTION ... [OPTIONS])
#
#     Declare the current CMake project as a PID package with specific meta-information passed as parameters.
#
#     .. rubric:: Required parameters
#
#     :AUTHOR <name>: The name of the author in charge of maintaining the package.
#     :YEAR <dates>: Reflects the lifetime of the package, e.g. ``YYYY-ZZZZ`` where ``YYYY`` is the creation year and ``ZZZZ`` the latest modification date.
#     :LICENSE <license name>: The name of the license applying to the package. This must match one of the existing license file in the ``licenses`` directory of the workspace.
#     :DESCRIPTION <description>: A short description of the package usage and utility.
#
#     .. rubric:: Optional parameters
#
#     :INSTITUTION <institutions>: Define the institution(s) to which the reference author belongs.
#     :MAIL|EMAIL <e-mail>: E-mail of the reference author.
#     :ADDRESS <url>: url of the package's official repository. Must be set once the package is published.
#     :PUBLIC_ADDRESS <url>: provide a public counterpart to the repository `ADDRESS`
#     :README <path relative to share folder>: Used to define a user-defined README file for the package.
#     :CODE_STYLE <code style>: Select the given code style for the project. If clang-format is available, the ``format`` command will be provided to format the source files.
#     :VERSION (major minor [patch] | major.minor.patch): current version of the project either as a list of digits or as a version number with dotted expression.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root ``CMakeLists.txt`` file of the package before any other call to the PID API.
#        - It must be called **exactly once**.
#
#     .. admonition:: Effects
#        :class: important
#
#        Initialization of the package internal state. After this call the package's content can be defined.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        PID_Package(
#                          AUTHOR Robin Passama
#                          INSTITUTION LIRMM
#                          YEAR 2013-2018
#                          LICENSE CeCILL
#                          ADDRESS git@gite.lirmm.fr:passama/a-given-package.git
#                          DESCRIPTION "an example PID package"
#        )
#

macro(PID_Package)
  declare_PID_Package(${ARGN})
endmacro(PID_Package)

macro(declare_PID_Package)
  set(oneValueArgs LICENSE ADDRESS MAIL EMAIL PUBLIC_ADDRESS README CODE_STYLE CONTRIBUTION_SPACE)
  set(multiValueArgs AUTHOR INSTITUTION YEAR DESCRIPTION VERSION)
  cmake_parse_arguments(DECLARE_PID_PACKAGE "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
  if(NOT DECLARE_PID_PACKAGE_AUTHOR)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Package, an author name must be given using AUTHOR keyword.")
  endif()
  if(NOT DECLARE_PID_PACKAGE_YEAR)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Package, a year or year interval must be given using YEAR keyword.")
  endif()
  if(NOT DECLARE_PID_PACKAGE_LICENSE)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Package, a license type must be given using LICENSE keyword.")
  endif()
  if(NOT DECLARE_PID_PACKAGE_DESCRIPTION)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Package, a (short) description of the package must be given using DESCRIPTION keyword.")
  endif()

  if(DECLARE_PID_PACKAGE_UNPARSED_ARGUMENTS)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Package, unknown arguments ${DECLARE_PID_PACKAGE_UNPARSED_ARGUMENTS}.")
  endif()

  if(NOT DECLARE_PID_PACKAGE_ADDRESS AND DECLARE_PID_PACKAGE_PUBLIC_ADDRESS)
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Package, the package must have an adress if a public access adress is declared.")
  endif()

  if(DECLARE_PID_PACKAGE_MAIL)
    set(email ${DECLARE_PID_PACKAGE_MAIL})
  elseif(DECLARE_PID_PACKAGE_EMAIL)
    set(email ${DECLARE_PID_PACKAGE_EMAIL})
  endif()
  declare_Package(	"${DECLARE_PID_PACKAGE_AUTHOR}" "${DECLARE_PID_PACKAGE_INSTITUTION}" "${email}"
  			"${DECLARE_PID_PACKAGE_YEAR}" "${DECLARE_PID_PACKAGE_LICENSE}"
  			"${DECLARE_PID_PACKAGE_ADDRESS}" "${DECLARE_PID_PACKAGE_PUBLIC_ADDRESS}"
  		  "${DECLARE_PID_PACKAGE_DESCRIPTION}" "${DECLARE_PID_PACKAGE_README}" "${DECLARE_PID_PACKAGE_CODE_STYLE}" "${DECLARE_PID_PACKAGE_CONTRIBUTION_SPACE}")
  unset(email)
  if(DECLARE_PID_PACKAGE_VERSION) #version directly declared in the declaration (NEW WAY to specify version)
    set_PID_Package_Version(${DECLARE_PID_PACKAGE_VERSION})#simply pass the list to the "final" function
  endif()
endmacro(declare_PID_Package)

#.rst:
# .. ifmode:: user
#
#  .. |set_PID_Package_Version| replace:: ``set_PID_Package_Version``
#  .. _set_PID_Package_Version:
#
#  set_PID_Package_Version
#  -----------------------
#
#  .. command:: set_PID_Package_Version(MAJOR MINOR [PATCH])
#
#  .. command:: set_PID_Package_Version(version_string)
#
#   Set the current version number of the package.
#
#   .. rubric:: Required parameters
#
#   :MAJOR: A positive number indicating the major version number.
#   :MINOR: A positive number indicating the minor version number.
#   :version_string: alternatively you can use a single version string with the format "MAJOR.MINOR[.PATCH]"
#
#   .. rubric:: Optional parameters
#
#   :PATCH: A positive number indicating the patch version number. If not defined, it will default to ``0``.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |PID_Package|_ but before |build_PID_Package|_.
#      - It must be called : never if the VERSION argument of |PID_Package|_ has been used ; **exactly once** otherwise.
#
#   .. admonition:: Effects
#      :class: important
#
#      Setting the current version number will affect the binar installation folder and configuration files.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      set_PID_Package_Version(1 2)
#
macro(set_PID_Package_Version)
if(${ARGC} EQUAL 3)
	set_Current_Version(${ARGV0} ${ARGV1} ${ARGV2})
elseif(${ARGC} EQUAL 2)
	set_Current_Version(${ARGV0} ${ARGV1} 0)
elseif(${ARGC} EQUAL 1)
  get_Version_String_Numbers("${ARGV0}" major minor patch)
  if(NOT DEFINED major)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling set_PID_Package_Version, you need to input a version number with at least a major and a minor number, optionnaly you can set a patch version (considered as 0 if not set). The version string \"${ARGV0}\" is given.")
  endif()
  if(patch)
    set_Current_Version(${major} ${minor} ${patch})
  else()
    set_Current_Version(${major} ${minor} 0)
  endif()
else()
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling set_PID_Package_Version, you need to input a major and a minor number, optionnaly you can set a patch version (considered as 0 if not set).")
endif()
endmacro(set_PID_Package_Version)

#.rst:
# .. ifmode:: user
#
#  .. |PID_Author| replace:: ``PID_Author``
#  .. _PID_Author:
#
#  PID_Author
#  ----------
#
#  .. command:: PID_Author(AUTHOR ... [INSTITUTION ...])
#
#  .. command:: add_PID_Package_Author(AUTHOR ... [INSTITUTION ...])
#
#   Add an author to the list of authors.
#
#   .. rubric:: Required parameters
#
#   :AUTHOR <name>: Name of the additional author.
#
#   .. rubric:: Optional parameters
#
#   :INSTITUTION <institutions>: Institution(s) to which the author belongs.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |PID_Package|_ but before |build_PID_Package|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     Add an author to the list of authors.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      PID_Author(AUTHOR Benjamin Navarro INSTITUTION LIRMM)
#

macro(PID_Author)
  add_PID_Package_Author(${ARGN})
endmacro(PID_Author)

macro(add_PID_Package_Author)
set(multiValueArgs AUTHOR INSTITUTION)
cmake_parse_arguments(ADD_PID_PACKAGE_AUTHOR "" "" "${multiValueArgs}" ${ARGN} )
if(NOT ADD_PID_PACKAGE_AUTHOR_AUTHOR)
  if(${ARGC} LESS 1 OR ${ARGV0} STREQUAL "INSTITUTION")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Author, an author name must be given using AUTHOR keyword (or simply by giving the name as first argument).")
  else()#the first argument is not the INSTITUTION keyword => it is the name of the author
    add_Author("${ARGV0}" "")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Author, an author name must be given using AUTHOR keyword (or simply by giving the name as first argument).")
  endif()
else()
  add_Author("${ADD_PID_PACKAGE_AUTHOR_AUTHOR}" "${ADD_PID_PACKAGE_AUTHOR_INSTITUTION}")
endif()
endmacro(add_PID_Package_Author)

#.rst:
# .. ifmode:: user
#
#  .. |PID_Reference| replace:: ``PID_Reference``
#  .. _PID_Reference:
#
#  PID_Reference
#  -------------
#
#  .. command:: PID_Reference(VERSION ... PLATFORM ... URL ...)
#
#  .. command:: add_PID_Package_Reference(VERSION ... PLATFORM ... URL ...)
#
#   Declare a reference to a known binary version of the package. This is useful to register various released version of the package.
#
#   .. rubric:: Required parameters
#
#   :VERSION <major>.<minor>[.<patch>]: The full version number of the referenced binary package. See |set_PID_Package_Version|_.
#
#   :PLATFORM <name>: The name of the target plaftorm for which the binary package has been built.
#
#   :URL <url-rel> <url-dbg>:
#     - ``<url-rel>`` is the url of the package binary release build
#     - ``<url-dbg>`` is the url of the package binary debug build.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |PID_Package|_ but before |build_PID_Package|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     Declare a reference that defines where to find an installable binary for a given platform.
#
#     PID uses this information to generate a CMake configuration file that will be used to retrieve this package version. This is the only way to define direct references to binary packages.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#    PID_Reference(VERSION 1.0.0 PLATFORM x86_linux_64_stdc++11
#      URL https://gite.lirmm.fr/pid/pid-binaries/wikis/pid-rpath/1.0.0/linux64/pid-rpath-1.0.0-linux64.tar.gz
#          https://gite.lirmm.fr/pid/pid-binaries/wikis/pid-rpath/1.0.0/linux64/pid-rpath-1.0.0-dbg-linux64.tar.gz
#    )
#

macro(PID_Reference)
  add_PID_Package_Reference(${ARGN})
endmacro(PID_Reference)

macro(add_PID_Package_Reference)
set(oneValueArgs VERSION PLATFORM)
set(multiValueArgs  URL)
cmake_parse_arguments(ADD_PID_PACKAGE_REFERENCE "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

if(NOT ADD_PID_PACKAGE_REFERENCE_URL)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Reference, you need to set the urls where to find binary packages for release and debug modes, using URL <release addr> <debug addr>.")
else()
	list(LENGTH ADD_PID_PACKAGE_REFERENCE_URL SIZE)
	if(NOT SIZE EQUAL 2)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Reference, you need to set the urls where to find binary packages for release and debug modes using URL <release addr> <debug addr>.")
	endif()
endif()
list(GET ADD_PID_PACKAGE_REFERENCE_URL 0 URL_REL)
list(GET ADD_PID_PACKAGE_REFERENCE_URL 1 URL_DBG)

if(NOT ADD_PID_PACKAGE_REFERENCE_PLATFORM)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Reference, you need to set the target platform name using PLATFORM keyword.")
endif()

if(NOT ADD_PID_PACKAGE_REFERENCE_VERSION)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Reference, you need to input a target version number (with major and minor values, optionnaly you can also set a patch value which is considered as 0 if not set) using VERSION keyword.")
else()
	get_Version_String_Numbers(${ADD_PID_PACKAGE_REFERENCE_VERSION} MAJOR MINOR PATCH)
  if(NOT DEFINED MAJOR)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Reference, the version number is corrupted (should follow the pattern major.minor[.patch]).")
  endif()
  #manage PID v1 API way of doing
	set(TARGET_PLATFORM_FOR_REFERENCE ${ADD_PID_PACKAGE_REFERENCE_PLATFORM})

	if(TARGET_PLATFORM_FOR_REFERENCE)#target platform cannot be determined
		if(NOT PATCH)
			add_Reference("${MAJOR}.${MINOR}.0" "${TARGET_PLATFORM_FOR_REFERENCE}" "${URL_REL}" "${URL_DBG}")
		else()
			add_Reference("${MAJOR}.${MINOR}.${PATCH}" "${TARGET_PLATFORM_FOR_REFERENCE}" "${URL_REL}" "${URL_DBG}")
		endif()
	endif()#otherwise simply do not add the reference, cannot resolve with new platform naming standard
endif()
endmacro(add_PID_Package_Reference)

#.rst:
# .. ifmode:: user
#
#  .. |PID_Category| replace:: ``PID_Category``
#  .. _PID_Category:
#
#  PID_Category
#  ------------
#
#  .. command:: PID_Category(CATEGORY)
#
#  .. command:: add_PID_Package_Category(CATEGORY)
#
#   Declare that the current package belongs to a given category.
#
#   .. rubric:: Required parameters
#
#   :CATEGORY: A string describing the category to which the package belongs. Sub-categories are divided by ``/``.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |PID_Package|_ but before |build_PID_Package|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     Register the package has being member of the given (sub)category. This information will be added to the :ref:`package reference file` when it is generated.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#    PID_Category(example/packaging)
#
macro(PID_Category)
  add_PID_Package_Category(${ARGN})
endmacro(PID_Category)

macro(add_PID_Package_Category)
if(NOT ${ARGC} EQUAL 1)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Category, command requires one string argument of the form <category>[/subcategory]*.")
endif()
add_Category("${ARGV0}")
endmacro(add_PID_Package_Category)

macro(declare_PID_Documentation)
	message("[PID] WARNING : in package ${PROJECT_NAME} declare_PID_Documentation is deprecated and is no more used in PID version 2. To define a documentation site please use PID_Publishing function. Skipping documentation generation phase.")
endmacro(declare_PID_Documentation)

#.rst:
# .. ifmode:: user
#
#  .. |PID_Publishing| replace:: ``PID_Publishing``
#  .. _PID_Publishing:
#
#  PID_Publishing
#  --------------
#
#  .. command:: PID_Publishing(AUTHOR ... [INSTITUTION ...])
#
#  .. command:: declare_PID_Publishing(AUTHOR ... [INSTITUTION ...])
#
#   Declare a site where the package is published, i.e. an online website where documentation and binaries of the package ar stored and accessible. There are two alternative for this function: defining a lone static site or defining the publication of the package in a framework.
#
#   .. rubric:: Required parameters
#
#   One of the two following options must be selected.
#
#   :FRAMEWORK <name>: The package belongs to the ``name`` framework. It will contribute to that site.
#   :GIT <url>: A stand-alone package. ``<url>`` is the git repository for the static site of this package.
#
#   When the ``GIT`` option is used, the following argument is also required:
#
#   :PAGE <url>: ``<url>`` is the online url of the static site.
#
#   When the ``GIT`` option is used, the following argument is also required:
#
#   :PROJECT <url>: Where to find the project page. This can also be used for same prupose with ``FRAMEWORK`` but when not used the documentation for the package is not generated (only used to reference the project as part of the framework).
#
#   .. rubric:: Optional parameters
#
#   :DESCRIPTION <description>: A long description of the package utility.
#   :TUTORIAL <file>: ``<file>`` should be a markdown file relative to the ``share/site`` folder of the package. This will be used to generate a tutorial webpage.
#   :ADVANCED <file>: ``<file>`` should be a markdown file relative to the ``share/site`` folder of the package. This will be used to generate an advanced description page.
#   :PUBLISH_BINARIES: If this is present, the package will automatically publish new binaries to the publication site.
#   :PUBLISH_DEVELOPMENT_INFO: If this is present, the package website will contain information for developpers such as coverage reports and static checks.
#   :ALLOWED_PLATFORMS <list of platforms>: list of platforms used for CI, only the specified platforms will be managed in the CI process. **WARNING: Due to gitlab limitation (only one pipeline can be defined) only ONE platform is allowed at the moment OR all pipelines must build to produce the output.**
#   :CATEGORIES <list of string>: list of category strings, used to specify to which categories the package contributes in a framework with same syntax as with PID_Category function. Used together with FRAMEWORK keyword.
#
#   When the ``GIT`` option is used, the following argument is also accepted:
#
#   :LOGO <path>: ``<path>`` is an image file that will be used as a logo. The file path is relative to the ``share/site`` folder of the package.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |PID_Package|_ but before |build_PID_Package|_. It should also be called after every call to |set_PID_Package_Version|_, |PID_Author|_ and |PID_Category|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     The main effect is to generate or update a static site for the project. This static site locally resides in a dedicated git repository. If the project belongs to no framework then it has its lone static site that can be found in sites/packages/<package name>. If it belongs to a framework, the framework repository can be found in sites/frameworks/<framework name>. In this later case, the package only contributes to its own related content not the overall content of the framework.
#
#     In both case, depending on how the package is built, the package will generate different kind of documentation (API documentatio, static check reports, coverage reports, etc.). Depending on options it can also deploy binaries or developper info for the current version and target platform into the static site repository (framework or lone static site).
#
#   .. rubric:: Example
#
#   Declaring the publication of the ``pid-rpath`` package as a stand-alone package:
#
#   .. code-block:: cmake
#
#    declare_PID_Publishing(PROJECT https://gite.lirmm.fr/pid/pid-rpath
#    			GIT git@gite.lirmm.fr:pid/pid-rpath-pages.git
#    			PAGE http://pid.lirmm.net/pid-rpath
#    			DESCRIPTION pid-rpath is a package providing a little API to ease the management of runtime resources within a PID workspace. Runtime resources may be either configuration files, executables or module libraries. Its usage is completely bound to the use of PID system.
#    			ADVANCED specific_usage.md
#    			LOGO	img/rouage_PID.jpg
#    			PUBLISH_BINARIES
#         ALLOWED_PLATFORMS x86_64_linux_stdc++11__ub20_gcc9__)
#
#   Declaring the publication of the ``pid-rpath`` package into the ``pid`` framework:
#
#   .. code-block:: cmake
#
#    PID_Publishing(
#       PROJECT https://gite.lirmm.fr/pid/pid-rpath
#       FRAMEWORK pid
#       DESCRIPTION pid-rpath is a package providing a little API to ease the management of runtime resources within a PID workspace. Runtime resources may be either configuration files, executables or module libraries. Its usage is completely bound to the use of PID system.
#       ADVANCED specific_usage.md
#       PUBLISH_BINARIES
#       ALLOWED_PLATFORMS x86_64_linux_stdc++11__ub20_gcc9__)
#
macro(PID_Publishing)
  declare_PID_Publishing(${ARGN})
endmacro(PID_Publishing)

macro(declare_PID_Publishing)
set(optionArgs PUBLISH_BINARIES PUBLISH_DEVELOPMENT_INFO)
set(oneValueArgs PROJECT FRAMEWORK GIT PAGE ADVANCED TUTORIAL LOGO)
set(multiValueArgs DESCRIPTION ALLOWED_PLATFORMS CATEGORIES)
cmake_parse_arguments(DECLARE_PID_PUBLISHING "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	#manage configuration of CI
if(DECLARE_PID_PUBLISHING_ALLOWED_PLATFORMS)
	foreach(platform IN LISTS DECLARE_PID_PUBLISHING_ALLOWED_PLATFORMS)
		allow_CI_For_Platform(RES_ALLOWED ${platform})
    if(NOT RES_ALLOWED)
      message(FATAL_ERROR "[PID] CRITICAL ERROR: in package ${PROJECT_NAME} when calling PID_Publishing, platform name ${platform} is not well formed")
      return()
    endif()
	endforeach()
	set(DO_CI TRUE)
else()
	set(DO_CI FALSE)
endif()

if(DECLARE_PID_PUBLISHING_FRAMEWORK)
	if(${PROJECT_NAME}_FRAMEWORK)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR: in package ${PROJECT_NAME} when calling PID_Publishing, a framework (${${PROJECT_NAME}_FRAMEWORK}) has already been defined, cannot define a new one !")
		return()
	elseif(${PROJECT_NAME}_SITE_GIT_ADDRESS)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR: in package ${PROJECT_NAME} when calling PID_Publishing, a static site (${${PROJECT_NAME}_SITE_GIT_ADDRESS}) has already been defined, cannot define a framework !")
		return()
	endif()
  if(DECLARE_PID_PUBLISHING_PROJECT)
    set(PUBLISH_DOC TRUE)#publish the doc only if project page has been defined
	endif()#otherwise publishing in only used to define project framework
  init_Documentation_Info_Cache_Variables("${DECLARE_PID_PUBLISHING_FRAMEWORK}" "${DECLARE_PID_PUBLISHING_PROJECT}" "" "" "${DECLARE_PID_PUBLISHING_DESCRIPTION}")
  if(DECLARE_PID_PUBLISHING_CATEGORIES)
    foreach(category IN LISTS DECLARE_PID_PUBLISHING_CATEGORIES)
      PID_Category(${category})
    endforeach()
  endif()
elseif(DECLARE_PID_PUBLISHING_GIT)
	if(NOT DECLARE_PID_PUBLISHING_PROJECT)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Publishing, you must tell where to find the project page of the official package repository using PROJECT keyword.")
	endif()
	if(NOT DECLARE_PID_PUBLISHING_PAGE)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Publishing, you must tell where to find the index page for the static site of the package (using PAGE keyword).")
	endif()
	if(${PROJECT_NAME}_FRAMEWORK)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR:in package ${PROJECT_NAME} bad arguments when calling PID_Publishing, a framework (${${PROJECT_NAME}_FRAMEWORK}) has already been defined, cannot define a static site !")
		return()
	elseif(${PROJECT_NAME}_SITE_GIT_ADDRESS)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR: in package ${PROJECT_NAME} bad arguments when calling PID_Publishing, a static site (${${PROJECT_NAME}_SITE_GIT_ADDRESS}) has already been defined, cannot define a new one !")
		return()
	endif()
	init_Documentation_Info_Cache_Variables("" "${DECLARE_PID_PUBLISHING_PROJECT}" "${DECLARE_PID_PUBLISHING_GIT}" "${DECLARE_PID_PUBLISHING_PAGE}" "${DECLARE_PID_PUBLISHING_DESCRIPTION}")
	set(PUBLISH_DOC TRUE)
else()
	set(PUBLISH_DOC FALSE)
endif()#otherwise there is no site contribution

#manage publication of binaries
if(DECLARE_PID_PUBLISHING_PUBLISH_BINARIES)
	if(NOT PUBLISH_DOC)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Publishing, you cannot publish binaries of the project (using PUBLISH_BINARIES) if you do not publish package ${PROJECT_NAME} using a static site (either use FRAMEWORK or SITE keywords).")
	endif()
	if(NOT DO_CI)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Publishing, you cannot publish binaries of the project (using PUBLISH_BINARIES) if you do not allow any CI process for package ${PROJECT_NAME} (use ALLOWED_PLATFORMS to defines which platforms will be used in CI process).")
	endif()
	publish_Binaries(TRUE)
else()
	publish_Binaries(FALSE)
endif()

#manage publication of information for developpers
if(DECLARE_PID_PUBLISHING_PUBLISH_DEVELOPMENT_INFO)
	if(NOT PUBLISH_DOC)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Publishing, you cannot publish development info of the project (using PUBLISH_DEVELOPMENT_INFO) if you do not publish package ${PROJECT_NAME} using a static site (either use FRAMEWORK or SITE keywords).")
	endif()
	if(NOT DO_CI)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Publishing, you cannot publish development info of the project (using PUBLISH_DEVELOPMENT_INFO) if you do not allow any CI process for package ${PROJECT_NAME} (use ALLOWED_PLATFORMS to defines which platforms will be used in CI process).")
	endif()
	publish_Development_Info(TRUE)
else()
	publish_Development_Info(FALSE)
endif()

#user defined doc
if(DECLARE_PID_PUBLISHING_ADVANCED)
	define_Documentation_Content(advanced "${DECLARE_PID_PUBLISHING_ADVANCED}")
else()
	define_Documentation_Content(advanced FALSE)
endif()
if(DECLARE_PID_PUBLISHING_TUTORIAL)
	define_Documentation_Content(tutorial "${DECLARE_PID_PUBLISHING_TUTORIAL}")
else()
	define_Documentation_Content(tutorial FALSE)
endif()
if(DECLARE_PID_PUBLISHING_LOGO)
	define_Documentation_Content(logo "${DECLARE_PID_PUBLISHING_LOGO}")
else()
	define_Documentation_Content(logo FALSE)
endif()
endmacro(declare_PID_Publishing)

#.rst:
# .. ifmode:: user
#
#  .. |PID_Documentation| replace:: ``PID_Documentation``
#  .. _PID_Documentation:
#
#  PID_Documentation
#  -----------------
#
#  .. command:: PID_Documentation(COMPONENT ... FILE ...)
#
#  .. command:: declare_PID_Component_Documentation(COMPONENT ... FILE ...)
#
#   Add specific documentation for a component
#
#   .. rubric:: Required parameters
#
#   :COMPONENT <name>: Name of the component for which a markdown page is provided.
#   :FILE <path>: Path to the markdown page for the specified component. ``<path>`` is relative to the ``share/site`` folder of the package.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - The component must have been declared with |PID_Component|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     This function registers a markdown page with documentation about the component. This page can be used to generate a specific web page for the component than will be put in the static site defined by the package deployment, see |PID_Publishing|_.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#    PID_Documentation(COMPONENT my-lib FILE mylib_usage.md)
#

macro(PID_Documentation)
  declare_PID_Component_Documentation(${ARGN})
endmacro(PID_Documentation)

macro(declare_PID_Component_Documentation)
set(oneValueArgs COMPONENT FILE)
cmake_parse_arguments(DECLARE_PID_COMPONENT_DOCUMENTATION "" "${oneValueArgs}" "" ${ARGN} )
if(NOT DECLARE_PID_COMPONENT_DOCUMENTATION_FILE)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Documentation, you must define the file or folder that contains specific documentation content for the project using FILE keyword.")
endif()
if(NOT DECLARE_PID_COMPONENT_DOCUMENTATION_COMPONENT)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Documentation, you must define a component name for this content using COMPONENT keyword.")
endif()
#user defined doc for a given component
define_Component_Documentation_Content(${DECLARE_PID_COMPONENT_DOCUMENTATION_COMPONENT} "${DECLARE_PID_COMPONENT_DOCUMENTATION_FILE}")
endmacro(declare_PID_Component_Documentation)

#.rst:
# .. ifmode:: user
#
#  .. |check_PID_Environment| replace:: ``check_PID_Environment``
#  .. _check_PID_Environment:
#
#  check_PID_Environment
#  ---------------------
#
#  .. command:: check_PID_Environment(...)
#
#   Check if the current build profile conforms to the given environments requirements. If constraints are violated then the configuration of the package fails. Otherwise the project will be configured and built accordingly.
#
#   .. rubric:: Optional parameters
#
#   :OPTIONAL: if used then the requirement on build environment is optional.
#   :LANGUAGE ...: constraint check expressions defining which language must/can be used (testing only C and C++ is not necessary).
#   :TOOLSET ...: constraint check expressions defining which toolset must/can be used for target language.
#   :CONFIGURE ...: set of languages that will be configured by the usage of a toolset, in addition to the one defined by the LANGUAGE keyword. TOOLSET keyword is not mandatory as the toolset may be automatically deduced from LANGUAGE expression.
#   :TOOL ...: Set of constraint check expressions defining which extra tools must/can be used.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |PID_Package|_ but before any call to |check_PID_Platform|_ ,any dependency or |build_PID_Package|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     Verify that the current profile in use provides an environment the tool or langauge to use
#
#   .. rubric:: Example
#
#   Checking that the current profile support a f2c generator.
#
#   .. code-block:: cmake
#
#      check_PID_Environment(TOOL f2c)
#
#      check_PID_Environment(LANGUAGE CXX[std=17])#check that a compiler with full c++17 support is provided
#
#      check_PID_Environment(LANGUAGE CXX TOOLSET clang_toolchain[version=9.0])#check that a clang compiler with version >= 9.0 is available
#
#      check_PID_Environment(LANGUAGE CXX CONFIGURE C TOOLSET clang_toolchain[version=9.0])#same as previously but the clang_toolchain is also used for C language
#
#      check_PID_Environment(LANGUAGE CXX[std=17] CONFIGURE C ASM)#check that compiler/stdlib fully supports C++17. If not AND if a solution can be found then the toolset used will also be used for C and ASM languages
#
macro(check_PID_Environment)
  set(monoValueArg OPTIONAL LANGUAGE TOOLSET)
  set(multiValueArgs TOOL CONFIGURE)
  cmake_parse_arguments(CHECK_PID_ENV "" "${monoValueArg}" "${multiValueArgs}" ${ARGN} )

  if(NOT CHECK_PID_ENV_LANGUAGE AND NOT CHECK_PID_ENV_TOOL)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when calling check_PID_Environment you must define at least a constraint expression on a programming language (using LANGUAGE) or an extra tool (using TOOL).")
  elseif(CHECK_PID_ENV_LANGUAGE AND CHECK_PID_ENV_TOOL)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when calling check_PID_Environment you can define at least a constraint expression on a programming language (using LANGUAGE) OR an extra tool (using TOOL), NOT BOTH.")
  endif()
  if(CHECK_PID_ENV_TOOLSET)
    if(NOT CHECK_PID_ENV_LANGUAGE)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when calling check_PID_Environment you must define the LANGUAGE (using LANGUAGE) when you want to use specific toolset (using TOOLSET argument).")
    endif()
  endif()
  if(CHECK_PID_ENV_CONFIGURE)
    if(NOT CHECK_PID_ENV_LANGUAGE)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when calling check_PID_Environment you must define the LANGUAGE (using LANGUAGE) when you want to defined other languages being configured (using CONFIGURE argument) by the same toolset.")
    endif()
  endif()
  if(CHECK_PID_ENV_LANGUAGE)
    check_Environment_Language_Constraints(ERROR "${CHECK_PID_ENV_LANGUAGE}" "${CHECK_PID_ENV_TOOLSET}" "${CHECK_PID_ENV_CONFIGURE}")
  elseif(CHECK_PID_ENV_TOOL)
    check_Environment_Tool_Constraints(ERROR  "${CHECK_PID_ENV_TOOL}")
  endif()
  if(NOT CHECK_PID_ENV_OPTIONAL)
    if(ERROR)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR: in package ${PROJECT_NAME} when calling check_PID_Environment, ${ERROR}")
    endif()
  else()
    if(ERROR)
      if(ADDITIONAL_DEBUG_INFO)
        message("[PID] WARNING: ${ERROR}")
      endif()
      set(${CHECK_PID_ENV_OPTIONAL} FALSE)
    else()
      set(${CHECK_PID_ENV_OPTIONAL} TRUE)
    endif()
  endif()
endmacro(check_PID_Environment)


#.rst:
# .. ifmode:: user
#
#  .. |check_PID_Platform| replace:: ``check_PID_Platform``
#  .. _check_PID_Platform:
#
#  check_PID_Platform
#  ------------------
#
#  .. command:: check_PID_Platform(CONFIGURATION ... [OPTIONS])
#
#   Check if the current target platform conforms to the given platform configuration. If constraints are violated then the configuration of the package fail. Otherwise the project will be configured and built accordingly. The configuration will be checked only if the current platform matches some constraints. If there is no constraint then the configuration is checked whatever the current target platform is.
#
#
#   .. rubric:: Optional parameters
#
#   :CONFIGURATION|REQUIRED <list of configurations>: list of platform configruation expressions that define the required configurations on target platform. Call will fail with an error if a configuration is not satisfied. Use of CONFIGURATION keyword is deprecated.
#   :OPTIONAL <configurations>: list of platform configruation expressions that define the required configurations on target platform. Call will silent errors if a configuration is not satisfied and produce the variable <confi name>_AVAILABLE accordingly.
#
#   These parameters can be used to refine the configuration check.
#
#   :TYPE <list of arch>: Constraint on the processor type.
#   :OS <list of os name>: Constraint on the operating system. For instance the list "linux freebsd" can be used.
#   :ARCH <32|64>: Constraint on the processor architecture.
#   :ABI <list of standard libraries abi>: Constraint on the ABI given by the standard c++ library in use.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |PID_Package|_ but before |build_PID_Package|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     First it checks if the current target platform of the workspace satisfies the specified constraints (TYPE, OS, ARCH and ABI). If all constraints are not respected then nothing is checked and the configuration of the package continues. Otherwise, the package configuration must be checked before continuing the configuration. Each configuration required is then checked individually. This can lead to the automatic install of some configuration, if this is possible (i.e. if there is a known way to install this configuration), which is typically the case for system software dependencies like libraries when:
#
#     1. No cross compilation takes place
#     2. The host system distribution is managed by the configuration (most of time debian like distributions are managed for installable configurations).
#
#     If the target plaform conforms to all required configurations, then the configuration continue. Otherwise the configuratin fails.
#
#   .. rubric:: Example
#
#   Checking that if the target platform is a linux with 32 bits architecture, then it must provide ``posix`` and ``x11`` configruation.
#
#   .. code-block:: cmake
#
#      check_PID_Platform(OS linux ARCH 32 CONFIGURATION posix x11)
#
#   Checking that any target platform provides an openssl configuration.
#
#   .. code-block:: cmake
#
#      check_PID_Platform(REQUIRED openssl)
#
macro(check_PID_Platform)
if(NOT PLUGIN_EXEC_BEFORE_DEPS)
  #plugin call point before any dependency (platform constraint or PID dependency)
  manage_Plugins_In_Package_Before_Dependencies_Description()
  set(PLUGIN_EXEC_BEFORE_DEPS TRUE)
endif()
set(multiValueArgs OS ARCH ABI TYPE CONFIGURATION OPTIONAL REQUIRED)
cmake_parse_arguments(CHECK_PID_PLATFORM "" "" "${multiValueArgs}" ${ARGN} )
#checking usage of the macro by the user
if(NOT CHECK_PID_PLATFORM_CONFIGURATION AND NOT CHECK_PID_PLATFORM_REQUIRED AND NOT CHECK_PID_PLATFORM_OPTIONAL)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
  message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} you must use the keyword REQUIRED or OPTIONAL to describe the set of configuration constraints that apply to the current platform. Use REQUIRED keyword instead of CONFIGURATION since this later is deprecated.")
endif()
if(CHECK_PID_PLATFORM_CONFIGURATION AND CHECK_PID_PLATFORM_REQUIRED)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling check_PID_Platform: it requires the use of REQUIRED or CONFIGURATION keyword to specify the required platform configurations, but not both of them. Use of CONFIGURATION is deprecated, prefer using REQUIRED.")
	return()
endif()
set(required ${CHECK_PID_PLATFORM_CONFIGURATION} ${CHECK_PID_PLATFORM_REQUIRED})
set(optional ${CHECK_PID_PLATFORM_OPTIONAL})
#Note: deprecated signature has been removed in PID v4 so no backward compatibility (not important because not really used)
#check for filters on target constraints

#checking the mandatory configurations
if(required)
  check_Platform_Constraints(RESULT IS_CURRENT "${CHECK_PID_PLATFORM_TYPE}" "${CHECK_PID_PLATFORM_ARCH}" "${CHECK_PID_PLATFORM_OS}" "${CHECK_PID_PLATFORM_ABI}" "${required}" FALSE)
  if(IS_CURRENT AND NOT RESULT)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
  	message(FATAL_ERROR "[PID] CRITICAL ERROR: in package ${PROJECT_NAME} when calling check_PID_Platform, constraint ${required} cannot be satisfied !")
  endif()
endif()
if(optional)
  #finally checking optional configurations
  check_Platform_Constraints(RESULT IS_CURRENT "${CHECK_PID_PLATFORM_TYPE}" "${CHECK_PID_PLATFORM_ARCH}" "${CHECK_PID_PLATFORM_OS}" "${CHECK_PID_PLATFORM_ABI}" "${optional}" TRUE)
endif()
unset(required)
unset(optional)
endmacro(check_PID_Platform)

#.rst:
# .. ifmode:: user
#
#  .. |get_PID_Platform_Info| replace:: ``get_PID_Platform_Info``
#  .. _get_PID_Platform_Info:
#
#  get_PID_Platform_Info
#  ---------------------
#
#  .. command:: get_PID_Platform_Info([OPTIONS])
#
#   Get information about the target platform. This can be used to configure the build accordingly.
#
#   .. rubric:: Optional parameters
#
#   All arguments are optional but at least one must be provided. All properties are retrieved for the target platform.
#
#   :NAME <VAR>: Output the name of the target platform in ``VAR``
#   :TYPE <VAR>: Ouptut the processor type in ``VAR``
#   :OS <VAR>: Output the OS name in ``VAR``
#   :ARCH <VAR>: Output the architecture in ``VAR``
#   :ABI <VAR>: Output the ABI in ``VAR``
#   :DISTRIBUTION <VAR>: Output the distribution in ``VAR``
#   :DISTRIB_VERSION <VAR>: Output the distribution version in ``VAR``
#   :PYTHON <VAR>: Output the Python version in ``VAR``
#   :PROC_OPTIM <VAR>: Output available processor optimizations in ``VAR``
#
#   .. admonition:: Effects
#     :class: important
#
#     After the call, the variables defined by the user will be set to the corresponding value. Then it can be used to control the configuration of the package.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      add_PID_Package_Author(AUTHOR Benjamin Navarro INSTITUTION LIRMM)
#
function(get_PID_Platform_Info)
set(oneValueArgs NAME OS ARCH ABI TYPE PYTHON DISTRIBUTION DISTRIB_VERSION PROC_OPTIM)
cmake_parse_arguments(GET_PID_PLATFORM_INFO "" "${oneValueArgs}" "" ${ARGN} )
set(OK FALSE)
if(GET_PID_PLATFORM_INFO_NAME)
	set(OK TRUE)
	set(${GET_PID_PLATFORM_INFO_NAME} ${CURRENT_PLATFORM_BASE} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_TYPE)
	set(OK TRUE)
	set(${GET_PID_PLATFORM_INFO_TYPE} ${CURRENT_PLATFORM_TYPE} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_OS)
	set(OK TRUE)
	set(${GET_PID_PLATFORM_INFO_OS} ${CURRENT_PLATFORM_OS} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_ARCH)
	set(OK TRUE)
	set(${GET_PID_PLATFORM_INFO_ARCH} ${CURRENT_PLATFORM_ARCH} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_ABI)
	set(OK TRUE)
  set(${GET_PID_PLATFORM_INFO_ABI} ${CURRENT_PLATFORM_ABI} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_PYTHON)
		set(OK TRUE)
		set(${GET_PID_PLATFORM_INFO_PYTHON} ${CURRENT_PYTHON} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_DISTRIBUTION)
		set(OK TRUE)
		set(${GET_PID_PLATFORM_INFO_DISTRIBUTION} ${CURRENT_DISTRIBUTION} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_DISTRIB_VERSION)
		set(OK TRUE)
		set(${GET_PID_PLATFORM_INFO_DISTRIB_VERSION} ${CURRENT_DISTRIBUTION_VERSION} PARENT_SCOPE)
endif()
if(GET_PID_PLATFORM_INFO_PROC_OPTIM)
  set(OK TRUE)
  set(${GET_PID_PLATFORM_INFO_PROC_OPTIM} ${CURRENT_SPECIFIC_INSTRUCTION_SET} PARENT_SCOPE)
endif()
if(NOT OK)
	message("[PID] ERROR :  in package ${PROJECT_NAME} when calling get_PID_Platform_Info, you must use one or more of the NAME, TYPE, ARCH, OS, ABI, DISTRIBUTION, DISTRIB_VERSION, PYTHON or PROC_OPTIM keywords together with corresponding variables that will contain the resulting property of the current platform in use.")
endif()
endfunction(get_PID_Platform_Info)

#.rst:
# .. ifmode:: user
#
#  .. |build_PID_Package| replace:: ``build_PID_Package``
#  .. _build_PID_Package:
#
#  build_PID_Package
#  -----------------
#
#  .. command:: build_PID_Package()
#
#   Automatically configure a PID package according to previous information.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called **last** in the root ``CMakeLists.txt`` file of the package.
#
#   .. admonition:: Effects
#     :class: important
#
#     This function generates configuration files, manage the generation of the global native build process and include the `CMakeLists.txt` files from the following folders (in that order): ``src``, ``apps``, ``test``, ``share``.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      build_PID_Package()
#
macro(build_PID_Package)
  create_Shell_Script_Symlinks()
  if(${ARGC} GREATER 0)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR :  in package ${PROJECT_NAME}, build_PID_Package command requires no arguments.")
  endif()
  build_Package()
endmacro(build_PID_Package)

#.rst:
# .. ifmode:: user
#
#  .. |PID_Component| replace:: ``PID_Component``
#  .. _PID_Component:
#
#  PID_Component
#  -------------
#
#  .. command:: PID_Component(<type> NAME ... DIRECTORY .. [OPTIONS])
#
#  .. command:: declare_PID_Component(<type> NAME ... DIRECTORY .. [OPTIONS])
#
#   Declare a new component in the current package.
#
#   .. rubric:: Required parameters
#
#   :<type>: this is the type of the library. It can be ommited, in this case it is deduced automatically with default values (SHARED, MODULE or HEADER for libraries, APP for applications, TEST for tests)
#            - ``STATIC_LIB|STATIC``: static library
#            - ``SHARED_LIB|SHARED``: shared library
#            - ``MODULE_LIB|MODULE``: shared library without header
#            - ``HEADER_LIB|HEADER``: header-only library
#            - ``APPLICATION|APP``: standard application
#            - ``EXAMPLE_APPLICATION|EXAMPLE``: example code
#            - ``TEST_APPLICATION|TEST``: unit test
#   :NAME <name>: Unique identifier of the component. ``name`` cannot contain whitespaces. The NAME keyword can be omitted if the name of the dependency is the first argument.
#
#   .. rubric:: Optional parameters
#
#   :DIRECTORY <dir>: Sub-folder where to find the component sources. This is relative to the current `CMakeLists.txt` folder. If ommitted then the folder name is considered the same as the component name.
#   :DESCRIPTION <text>: Provides a description of the component. This will be used in generated documentation.
#   :USAGE <list of headers to include>: This should be used to list useful includes to put in client code. This is used for documentation purpose.
#   :DOCUMENTATION: specifies a file (markdown) used to generate an online documentaion for the component.
#   :C_STANDARD <90|99|11>: C language standard used to build the component. Defaults to ``90`` (i.e. ANSI-C)
#   :C_MAX_STANDARD <90|99|11>: Maximum C language standard that can be used when using the component.
#   :CXX_STANDARD <98|11|14|17|20>: C++ language standard used to build the component. Defaults to ``98``.
#   :CXX_MAX_STANDARD <98|11|14|17|20>: Maximum C++ language standard that can be used when using the component.
#   :WARNING_LEVEL <DEFAULT|MORE|ALL>: Level of warning required when building the code, DEFAULT is the compiler's defaut warning level, MORE adds the most common ones and ALL maximizes the number of warnings.
#   :RUNTIME_RESOURCES <files>: ``<files>`` is a list of files and folders relative to the ``share/resources`` folder. These files will be installed automatically and should be accessed in a PID component using the `pid-rpath <http://pid.lirmm.net/pid-framework/packages/pid-rpath>`_ package.
#   :INTERNAL: This flag is used to introduce compilation options that are only used by this component.
#   :EXPORTED: This flag is used to export compilation options. Meaning, components that later refer to this component will be using these options.
#   :SPECIAL_HEADERS: Specify specific files to export from the include folder of the component. Used for instance to export file without explicit header extension.
#   :AUXILIARY_SOURCES: Specify auxiliary source folder or files to use when building the component. Used for instance to share private code between component of the project. May contain a list of path relative to project root dir.
#   :DEPEND ...: Specify a list of components that the current component depends on. These components are not exported.
#   :EXPORT ...: Specify a list of components that the current component depends on and exports.
#   :LOGGABLE: specifies that the component generate logs using the pid-log system.
#   :ALIAS ...: specifies the alias names of the component.
#   :MANAGE_SYMBOLS: Tell the system that the code will manage symbol export by specifying the path (relative to DIRECTORY) where the generated header defining macro for exporting symbols will be put. All symbols of the library will be hidden instead of default behavior where all symbols are exported.
#   :INTERNAL_ONLY: specifies that the library is defined for internal use only, will not be installed by the package.
#   :FOR_EXAMPLES: specifies that library must be internal only and is used for example purpose
#   :FOR_TESTS: specifies that library must be internal only and is used for testing purpose
#   :LOGGABLE: specifies generate logs that can be discriminated from other component logs (using pid-log system)
#
#   The following options are supported by the ``INTERNAL`` and ``EXPORTED`` commands:
#
#   :DEFINITIONS <defs>: Preprocessor definitions. May be exported if these definitions are used in public headers of a library.
#   :LINKS <links>: Linker flags. Should be reserved to specific linker option to use when linking a library or executable. May be exported if this option changes the ABI.
#   :COMPILER_OPTIONS <options>: Compiler-specific options. May be exported if this option changes the ABI.
#
#   Furthermore, the ``INTERNAL`` option also support the following commands:
#   :INCLUDE_DIRS <dirs>: Additional include directories.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - <type> acceptability depends on the current folder.
#
#   .. admonition:: Effects
#     :class: important
#
#     Defines a new component in the package. Will create related targets to build the component and install it (if applicable).
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      PID_Component(STATIC_LIB NAME my-static-lib DIRECTORY binary_lib
#                            INTERNAL DEFINITIONS EXPORT_SYMBOLS
#                            EXPORT DEFINITIONS IMPORT_SYMBOLS
#     )
#

macro(PID_Component)
  declare_PID_Component(${ARGN})
endmacro(PID_Component)

macro(declare_PID_Component)
set(options STATIC_LIB STATIC SHARED_LIB SHARED MODULE_LIB MODULE HEADER_LIB HEADER
            APPLICATION APP EXAMPLE_APPLICATION EXAMPLE TEST_APPLICATION TEST
            PYTHON_PACK PYTHON
            LOGGABLE
            INTERNAL_ONLY FOR_EXAMPLES FOR_TESTS)
set(oneValueArgs MANAGE_SYMBOLS NAME DIRECTORY C_STANDARD C_MAX_STANDARD CXX_STANDARD CXX_MAX_STANDARD DOCUMENTATION WARNING_LEVEL)
set(multiValueArgs INTERNAL EXPORTED RUNTIME_RESOURCES DESCRIPTION USAGE SPECIAL_HEADERS AUXILIARY_SOURCES DEPEND EXPORT ALIAS)
cmake_parse_arguments(DECLARE_PID_COMPONENT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )


#check for the name argument
set(comp_name)
if(DECLARE_PID_COMPONENT_NAME)
  set(comp_name ${DECLARE_PID_COMPONENT_NAME})
  if(DECLARE_PID_COMPONENT_UNPARSED_ARGUMENTS)#if name is given there is no unparsed arguments
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Component, unknown arguments ${DECLARE_PID_COMPONENT_UNPARSED_ARGUMENTS}.")
  endif()
else()
  if(NOT DECLARE_PID_COMPONENT_UNPARSED_ARGUMENTS)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Component, a name must be given to the component using NAME keyword (or if it is the first argument).")
  endif()
  list(REMOVE_ITEM DECLARE_PID_COMPONENT_UNPARSED_ARGUMENTS ${ARGV0})
  list(LENGTH DECLARE_PID_COMPONENT_UNPARSED_ARGUMENTS SIZE)
  if(NOT SIZE EQUAL 0)#means argv0 has been parsed => so it is not the component name
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Component, a name must be given to the component using NAME keyword (or if it is the first argument).")
  else()
    set(comp_name ${ARGV0})
  endif()
endif()

#check unique names
set(DECLARED FALSE)
is_Declared(${comp_name} DECLARED)
if(DECLARED)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when calling PID_Component, a component with the same name than ${comp_name} is already defined.")
	return()
endif()
unset(DECLARED)

if(DECLARE_PID_COMPONENT_DIRECTORY)
  set(dir_name ${DECLARE_PID_COMPONENT_DIRECTORY})
else()
  set(dir_name ${comp_name})#when directory is not specified than we consider that folder name is same as component name
endif()

set(nb_options 0)
if(DECLARE_PID_COMPONENT_STATIC_LIB OR DECLARE_PID_COMPONENT_STATIC)
	math(EXPR nb_options "${nb_options}+1")
	set(type "STATIC")
endif()
if(DECLARE_PID_COMPONENT_SHARED_LIB OR DECLARE_PID_COMPONENT_SHARED)
	math(EXPR nb_options "${nb_options}+1")
	set(type "SHARED")
endif()
if(DECLARE_PID_COMPONENT_MODULE_LIB OR DECLARE_PID_COMPONENT_MODULE)
	math(EXPR nb_options "${nb_options}+1")
	set(type "MODULE")
endif()
if(DECLARE_PID_COMPONENT_HEADER_LIB OR DECLARE_PID_COMPONENT_HEADER)
	math(EXPR nb_options "${nb_options}+1")
	set(type "HEADER")
endif()
if(DECLARE_PID_COMPONENT_APPLICATION OR DECLARE_PID_COMPONENT_APP)
	math(EXPR nb_options "${nb_options}+1")
	set(type "APP")
endif()
if(DECLARE_PID_COMPONENT_EXAMPLE_APPLICATION OR DECLARE_PID_COMPONENT_EXAMPLE)
	math(EXPR nb_options "${nb_options}+1")
	set(type "EXAMPLE")
endif()
if(DECLARE_PID_COMPONENT_TEST_APPLICATION OR DECLARE_PID_COMPONENT_TEST)
	math(EXPR nb_options "${nb_options}+1")
	set(type "TEST")
endif()
if(DECLARE_PID_COMPONENT_PYTHON_PACK OR DECLARE_PID_COMPONENT_PYTHON)
	math(EXPR nb_options "${nb_options}+1")
	set(type "PYTHON")
endif()
if(nb_options GREATER 1)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Component, only one type among (STATIC_LIB|STATIC, SHARED_LIB|SHARED, MODULE_LIB|MODULE, HEADER_LIB|HEADER, APPLICATION|APP, EXAMPLE_APPLICATION|EXAMPLE or TEST_APPLICATION|TEST) must be given for the component.")
elseif(nb_options LESS 1)
  #need to deduce the type
  set(type "UNKNOWN")
endif()

if(type STREQUAL "UNKNOWN")
  usable_In_Regex(matchable_path_to_source ${CMAKE_SOURCE_DIR})
  if(CMAKE_CURRENT_SOURCE_DIR MATCHES "^${matchable_path_to_source}/src.*$")#it is a library
    check_Required_Directories_Exist(PROBLEM "SHARED" ${dir_name})
    if(PROBLEM)
      check_Required_Directories_Exist(PROBLEM "HEADER" ${dir_name})
      if(PROBLEM)
        check_Required_Directories_Exist(PROBLEM "MODULE" ${dir_name})
        if(NOT PROBLEM)
          #OK let's consider it is a shared library
          set(type "MODULE")
        endif()
      else()#OK let's consider it is a header library
        set(type "HEADER")
      endif()
    else()#OK let's consider it is a shared library
      set(type "SHARED")
    endif()
  elseif(CMAKE_CURRENT_SOURCE_DIR MATCHES "^${matchable_path_to_source}/apps.*$")#it is an application
    check_Required_Directories_Exist(PROBLEM "APP" ${dir_name})
    if(NOT PROBLEM)
      set(type "APP")
    endif()
  elseif(CMAKE_CURRENT_SOURCE_DIR MATCHES "^${matchable_path_to_source}/test.*$")#it is a test unit
    check_Required_Directories_Exist(PROBLEM "TEST" ${dir_name})
    if(NOT PROBLEM)
      set(type "TEST")
    endif()
  elseif(CMAKE_CURRENT_SOURCE_DIR MATCHES "^${matchable_path_to_source}/share/script.*$")#it is a python script
    check_Required_Directories_Exist(PROBLEM "PYTHON" ${dir_name})
    if(NOT PROBLEM)
      set(type "PYTHON")
    endif()
  else()#shitty situation !!
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME}  when calling PID_Component, cannot deduce type of the component please use the keywords (STATIC_LIB|STATIC, SHARED_LIB|SHARED, MODULE_LIB|MODULE, HEADER_LIB|HEADER, APPLICATION|APP, EXAMPLE_APPLICATION|EXAMPLE, TEST_APPLICATION|TEST or PYTHON|PYTHON_PACK).")
  endif()
endif()

if(type STREQUAL "UNKNOWN")#no folder found => let's consider it is a header library without folder (pure interface library)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
  message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME}  when calling PID_Component, cannot deduce type of the component because no adequate folder found with name ${dir_name}. Please use the keywords (STATIC_LIB|STATIC, SHARED_LIB|SHARED, MODULE_LIB|MODULE, HEADER_LIB|HEADER, APPLICATION|APP, EXAMPLE_APPLICATION|EXAMPLE, TEST_APPLICATION|TEST or PYTHON|PYTHON_PACK). If you want to define a header library without folder you must use the HEADER keyword. Otherwise you should use the DIRECTORY keyword to specify the name of the folder containing the source code, if its name differs from ${dir_name}.")
endif()

#checking that the required directories exist
if(NOT type STREQUAL "HEADER")#header libraries can define no folder (simple interfaces)
  check_Required_Directories_Exist(PROBLEM ${type} ${dir_name})
  if(PROBLEM)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Component, the source directory ${dir_name} of declared component ${comp_name} cannot be found in ${CMAKE_CURRENT_SOURCE_DIR} (${PROBLEM}). Specify the source directory using DIRECTORY keyword and check that its path is correct")
  endif()
endif()

set(internal_defs "")
set(internal_inc_dirs "")
set(internal_link_flags "")
set(internal_compiler_options "")
if(DECLARE_PID_COMPONENT_INTERNAL)
	if(DECLARE_PID_COMPONENT_INTERNAL STREQUAL "")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Component, INTERNAL keyword must be followed by at least DEFINITIONS or INCLUDE_DIRS or LINKS or COMPILER_OPTIONS keywords and related arguments.")
	endif()
	set(internal_multiValueArgs DEFINITIONS INCLUDE_DIRS LINKS COMPILER_OPTIONS)
	cmake_parse_arguments(DECLARE_PID_COMPONENT_INTERNAL "" "" "${internal_multiValueArgs}" ${DECLARE_PID_COMPONENT_INTERNAL} )
	if(DECLARE_PID_COMPONENT_INTERNAL_DEFINITIONS)
		set(internal_defs ${DECLARE_PID_COMPONENT_INTERNAL_DEFINITIONS})
	endif()
	if(DECLARE_PID_COMPONENT_INTERNAL_INCLUDE_DIRS)
		set(internal_inc_dirs ${DECLARE_PID_COMPONENT_INTERNAL_INCLUDE_DIRS})
	endif()
	if(DECLARE_PID_COMPONENT_INTERNAL_COMPILER_OPTIONS)
		set(internal_compiler_options ${DECLARE_PID_COMPONENT_INTERNAL_COMPILER_OPTIONS})
	endif()
	if(DECLARE_PID_COMPONENT_INTERNAL_LINKS)
		if(type MATCHES HEADER OR type MATCHES STATIC)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
			message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Component, ${type} libraries cannot define internal linker flags.")
		endif()
		set(internal_link_flags ${DECLARE_PID_COMPONENT_INTERNAL_LINKS})
	endif()
endif()
if(DECLARE_PID_COMPONENT_WARNING_LEVEL STREQUAL "MORE")
  list(APPEND internal_compiler_options ${CURRENT_CXX_COMPILER_WARN_MORE_OPTIONS})
endif()
if(DECLARE_PID_COMPONENT_WARNING_LEVEL STREQUAL "ALL")
  list(APPEND internal_compiler_options ${CURRENT_CXX_COMPILER_WARN_ALL_OPTIONS})
endif()

if(WARNINGS_AS_ERRORS)#adding flags togenerate errors when warnings occur if option is active
  list(APPEND internal_compiler_options ${CURRENT_CXX_COMPILER_WARN_AS_ERRORS_OPTIONS})
endif()

set(exported_defs)
set(exported_link_flags)
set(exported_compiler_options)

if(DECLARE_PID_COMPONENT_EXPORTED)
	if(type MATCHES APP OR type MATCHES EXAMPLE OR type MATCHES TEST)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Component, applications cannot export anything (invalid use of the EXPORTED keyword).")
	elseif(type MATCHES MODULE)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Component, module librairies cannot export anything (invalid use of the EXPORTED keyword).")
	endif()
	if(DECLARE_PID_COMPONENT_EXPORTED STREQUAL "")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Component, EXPORTED keyword must be followed by at least one DEFINITIONS OR LINKS keyword and related arguments.")
	endif()
	set(exported_multiValueArgs DEFINITIONS LINKS COMPILER_OPTIONS)
	cmake_parse_arguments(DECLARE_PID_COMPONENT_EXPORTED "" "" "${exported_multiValueArgs}" ${DECLARE_PID_COMPONENT_EXPORTED} )
	if(DECLARE_PID_COMPONENT_EXPORTED_DEFINITIONS)
		set(exported_defs ${DECLARE_PID_COMPONENT_EXPORTED_DEFINITIONS})
	endif()
	if(DECLARE_PID_COMPONENT_EXPORTED_LINKS)
		set(exported_link_flags ${DECLARE_PID_COMPONENT_EXPORTED_LINKS})
	endif()
	if(DECLARE_PID_COMPONENT_EXPORTED_COMPILER_OPTIONS)
		set(exported_compiler_options ${DECLARE_PID_COMPONENT_EXPORTED_COMPILER_OPTIONS})
	endif()
endif()

set(runtime_resources "")
if(DECLARE_PID_COMPONENT_RUNTIME_RESOURCES)
	set(runtime_resources ${DECLARE_PID_COMPONENT_RUNTIME_RESOURCES})
endif()

if(DECLARE_PID_COMPONENT_LOGGABLE)
  # check that pid-log is a dependency of the package
  is_Package_Dependency(IS_DEPENDENCY "pid-log")
  if(NOT IS_DEPENDENCY AND NOT PROJECT_NAME STREQUAL "pid-log")#avoid special case of component used to test logging system inside pid-log
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when calling PID_Component, ${comp_name} is declared as loggable, but ${PROJECT_NAME} does not depends on pid-log package. Please add pid-log as a dependency of your package.")
	endif()
  if(IS_DEPENDENCY AND pid-log_VERSION_STRING VERSION_LESS 3.1)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when calling PID_Component, ${comp_name} is declared as loggable, but ${PROJECT_NAME} depends on a too old version of pid-log package. Please add pid-log version 3.1 or more as a dependency of your package.")
  endif()
endif()

if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
  list(APPEND internal_compiler_options "/permissive-") # Force MSVC to be standard compliant
  list(APPEND internal_defs "_USE_MATH_DEFINES") # Force MSVC to define math constants in math.h/cmath (e.g M_PI)
endif()

if(type MATCHES "APP" OR type MATCHES "EXAMPLE" OR type MATCHES "TEST")
	if(ENABLE_SANITIZERS)
		if(SANITIZE_ADDRESS)
			add_Sanitizer_Flags_If_Available(ADDRESS internal_compiler_options internal_link_flags)
		endif()
		if(SANITIZE_LEAK)
			add_Sanitizer_Flags_If_Available(LEAK internal_compiler_options internal_link_flags)
		endif()
		if(SANITIZE_UNDEFINED)
			add_Sanitizer_Flags_If_Available(UNDEFINED internal_compiler_options internal_link_flags)
		endif()
	endif()
  # manage options and eventually adjust language standard in use
  adjust_Languages_Standards_Description(ERR MESS C_STD_USED CXX_STD_USED INTERN_OPTS EXPORT_OPTS
                                        internal_compiler_options exported_compiler_options
                                        "${DECLARE_PID_COMPONENT_C_STANDARD}"
                                        "${DECLARE_PID_COMPONENT_C_MAX_STANDARD}"
                                        "${DECLARE_PID_COMPONENT_CXX_STANDARD}"
                                        "${DECLARE_PID_COMPONENT_CXX_MAX_STANDARD}")
  if(ERR)
    if(ERR STREQUAL "CRITICAL")
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR: in package ${PROJECT_NAME} when calling PID_Component, problem with declared application ${comp_name}, ${MESS}")
    else()
      message("[PID] WARNING: in package ${PROJECT_NAME} when calling PID_Component to declare application ${comp_name}, ${MESS}")
    endif()
  endif()
	declare_Application_Component(	${comp_name}
					${dir_name}
					${type}
					"${C_STD_USED}"
          "${DECLARE_PID_COMPONENT_C_MAX_STANDARD}"
					"${CXX_STD_USED}"
					"${DECLARE_PID_COMPONENT_CXX_MAX_STANDARD}"
					"${internal_inc_dirs}"
					"${internal_defs}"
					"${INTERN_OPTS}"
					"${internal_link_flags}"
					"${runtime_resources}"
          "${DECLARE_PID_COMPONENT_AUXILIARY_SOURCES}"
          "${DECLARE_PID_COMPONENT_LOGGABLE}"
          "${DECLARE_PID_COMPONENT_ALIAS}")

elseif(type MATCHES "PYTHON")#declare a python package
	declare_Python_Component(${comp_name} ${dir_name})
else() #it is a library
	if(ENABLE_SANITIZERS)
		if(SANITIZE_ADDRESS)
			add_Sanitizer_Flags_If_Available(ADDRESS internal_compiler_options exported_link_flags)
		endif()
		if(SANITIZE_LEAK)
			add_Sanitizer_Flags_If_Available(LEAK internal_compiler_options exported_link_flags)
		endif()
		if(SANITIZE_UNDEFINED)
			add_Sanitizer_Flags_If_Available(UNDEFINED internal_compiler_options exported_link_flags)
		endif()
	endif()
  adjust_Languages_Standards_Description(ERR MESS C_STD_USED CXX_STD_USED INTERN_OPTS EXPORT_OPTS
                                        internal_compiler_options exported_compiler_options
                                        "${DECLARE_PID_COMPONENT_C_STANDARD}"
                                        "${DECLARE_PID_COMPONENT_C_MAX_STANDARD}"
                                        "${DECLARE_PID_COMPONENT_CXX_STANDARD}"
                                        "${DECLARE_PID_COMPONENT_CXX_MAX_STANDARD}")
  if(ERR)
    if(ERR STREQUAL "CRITICAL")
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR: in package ${PROJECT_NAME} when calling PID_Component to declare library ${comp_name}, ${MESS}")
    else()
      message("[PID] WARNING: in package ${PROJECT_NAME} when calling PID_Component to declare library ${comp_name}, ${MESS}")
    endif()
  endif()

  if(DECLARE_PID_COMPONENT_FOR_EXAMPLES OR DECLARE_PID_COMPONENT_FOR_TESTS)
    if(NOT DECLARE_PID_COMPONENT_INTERNAL_ONLY)
      message(FATAL_ERROR "[PID] CRITICAL ERROR: in package ${PROJECT_NAME} when calling PID_Component to declare library ${comp_name}, declared as FOR_TESTS or FOR_EXAMPLES but not INTERNAL_ONLY")
    endif()
  endif()
	declare_Library_Component(${comp_name}
					"${dir_name}"
					${type}
					"${C_STD_USED}"
          "${DECLARE_PID_COMPONENT_C_MAX_STANDARD}"
					"${CXX_STD_USED}"
					"${DECLARE_PID_COMPONENT_CXX_MAX_STANDARD}"
					"${internal_inc_dirs}"
					"${internal_defs}"
					"${INTERN_OPTS}"
					"${exported_defs}"
					"${EXPORT_OPTS}"
					"${internal_link_flags}"
					"${exported_link_flags}"
					"${runtime_resources}"
          "${DECLARE_PID_COMPONENT_SPECIAL_HEADERS}"
          "${DECLARE_PID_COMPONENT_AUXILIARY_SOURCES}"
          "${DECLARE_PID_COMPONENT_LOGGABLE}"
          "${DECLARE_PID_COMPONENT_ALIAS}"
          "${DECLARE_PID_COMPONENT_MANAGE_SYMBOLS}"
          "${DECLARE_PID_COMPONENT_INTERNAL_ONLY}"
          "${DECLARE_PID_COMPONENT_FOR_EXAMPLES}"
          "${DECLARE_PID_COMPONENT_FOR_TESTS}"
  )
endif()
if(DECLARE_PID_COMPONENT_DESCRIPTION)
	init_Component_Description(${comp_name} "${DECLARE_PID_COMPONENT_DESCRIPTION}" "${DECLARE_PID_COMPONENT_USAGE}")
endif()

#dealing with dependencies
if(DECLARE_PID_COMPONENT_EXPORT)#exported dependencies
  foreach(dep IN LISTS DECLARE_PID_COMPONENT_EXPORT)
    extract_Component_And_Package_From_Dependency_String(COMPONENT_NAME RES_PACK ${dep})
    set(COMPONENT_ARG ${COMPONENT_NAME})
    if(RES_PACK)#here the package name may be a framework name
      get_Package_Type(${RES_PACK} PACK_TYPE)
      if(PACK_TYPE STREQUAL "UNKNOWN")#not a known package => it is maybe a framework
        check_Framework_Exists(CHECK_OK ${RES_PACK})
        if(CHECK_OK)
          set(PACKAGE_ARG "FRAMEWORK;${RES_PACK}")
        else()
          finish_Progress(${GLOBAL_PROGRESS_VAR})
          message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when calling PID_Component, name ${RES_PACK} used to denote namespace of component ${comp_name} does not refer to any known package or framework.")
        endif()
      else()
        set(PACKAGE_ARG "PACKAGE;${RES_PACK}")
      endif()
    else()#no package defined
      set(PACKAGE_ARG)
      if(${COMPONENT_NAME}_AVAILABLE)#there is a configuration with same name that is available
        set(COMPONENT_ARG CONFIGURATION ${COMPONENT_NAME})#transform component name into a configuration name
      endif()
    endif()
    declare_PID_Component_Dependency(COMPONENT ${comp_name} EXPORT ${COMPONENT_ARG} ${PACKAGE_ARG})
  endforeach()
endif()

if(DECLARE_PID_COMPONENT_DEPEND)#non exported dependencies
  foreach(dep IN LISTS DECLARE_PID_COMPONENT_DEPEND)
    extract_Component_And_Package_From_Dependency_String(COMPONENT_NAME RES_PACK ${dep})
    set(COMPONENT_ARG ${COMPONENT_NAME})
    if(RES_PACK)#here the package name may be a framework name
      get_Package_Type(${RES_PACK} PACK_TYPE)
      if(PACK_TYPE STREQUAL "UNKNOWN")#not a known package => it is maybe a framework
        check_Framework_Exists(CHECK_OK ${RES_PACK})
        if(CHECK_OK)
          set(PACKAGE_ARG "FRAMEWORK;${RES_PACK}")
        else()
          finish_Progress(${GLOBAL_PROGRESS_VAR})
          message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when calling PID_Component, name ${RES_PACK} used to denote namespace of component ${comp_name} does not refer to any known package or framework.")
        endif()
      else()
        set(PACKAGE_ARG "PACKAGE;${RES_PACK}")
      endif()
    else()
      set(PACKAGE_ARG)
      if(${COMPONENT_NAME}_AVAILABLE)#there is a configuration with same name that is available
        set(COMPONENT_ARG CONFIGURATION ${COMPONENT_NAME})#transform component name into a configuration name
      endif()
    endif()
    declare_PID_Component_Dependency(COMPONENT ${comp_name} DEPEND ${COMPONENT_ARG} ${PACKAGE_ARG})
  endforeach()
endif()

if(DECLARE_PID_COMPONENT_LOGGABLE)#need to deal with dependency to pid-log if not explicitly managed
  list(FIND ${PROJECT_NAME}_${comp_name}_DEPENDENCIES${USE_MODE_SUFFIX} pid-log INDEX)
  if(INDEX EQUAL -1)#pid-log is not already a dependency
    declare_PID_Component_Dependency(COMPONENT ${comp_name} EXPORT pid-log PACKAGE pid-log)
  endif()
endif()

if(DECLARE_PID_COMPONENT_DOCUMENTATION)
  declare_PID_Component_Documentation(COMPONENT ${comp_name} FILE ${DECLARE_PID_COMPONENT_DOCUMENTATION})
endif()
endmacro(declare_PID_Component)



#.rst:
# .. ifmode:: user
#
#  .. |PID_Predeclare_Application| replace:: ``PID_Predeclare_Application``
#  .. _PID_Predeclare_Application:
#
#  PID_Predeclare_Application
#  --------------------------
#
#  .. command:: PID_Predeclare_Application(name)
#
#   Predeclare an application. To be used in CMakeLists.txt of src folder to allow a library to depend on an internal application (that will be defined later)
#
#   .. rubric:: Required parameters
#
#   :<name>: Name of the application. This later must be defined in the CMakeLists.txt of the app folder.
#
macro(PID_Predeclare_Application name)
  add_executable(${PROJECT_NAME}_${name}${INSTALL_NAME_SUFFIX})
  set_target_properties(
    ${PROJECT_NAME}_${name}${INSTALL_NAME_SUFFIX}
    PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/apps
  )
  set(${PROJECT_NAME}_${name}_TYPE APP CACHE INTERNAL "")
  mark_As_Predeclared(${name})
endmacro(PID_Predeclare_Application)

#.rst:
# .. ifmode:: user
#
#  .. |PID_Dependency| replace:: ``PID_Dependency``
#  .. _PID_Dependency:
#
#  PID_Dependency
#  --------------
#
#  .. command:: PID_Dependency([PACKAGE] ... [EXTERNAL|NATIVE] [OPTIONS])
#
#  .. command:: declare_PID_Package_Dependency([PACKAGE] ... [EXTERNAL|NATIVE] [OPTIONS])
#
#   Declare a dependency between the current package and another package.
#
#   .. rubric:: Required parameters
#
#   :[PACKAGE] <name>: Name of the package the current package depends upon. The PACKAGE keyword can be omitted if the name of the dependency is the first argument.
#
#   .. rubric:: Optional parameters
#
#   :EXTERNAL: Use this keyword when you want to specify ``name`` as an external package. In most cases this keyword can be omitted as PID can automatically detect the type of packages.
#   :NATIVE: Use this keyword when you want to specify  ``name`` as a native package. In most cases this keyword can be omitted as PID can automatically detect the type of packages.
#   :OPTIONAL: Make the dependency optional.
#   :[EXACT|FROM|TO] VERSION <version>: Specifies the requested package version. ``EXACT`` means this exact version is required (patch revision may be ignored for native packages), otherwise this is treated as a minimum version requirement. Multiple exact versions may be specified. In that case, the first one is the default version. Another option is to define ranges of versions with FROM VERSION ... TO VERSION .. expressions.
#   :COMPONENTS <components>: Specify which components of the given package are required.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called in the root ``CMakeLists.txt`` file of the package, after |PID_Package|_ but before |build_PID_Package|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     This function will register the target package as a dependency of the current package. The information will be added to the :ref:`package use file`.
#
#   .. rubric:: Example
#
#   Simple example:
#
#   .. code-block:: cmake
#
#      PID_Dependency (
#                PACKAGE another-package
#                NATIVE VERSION 1.0
#                COMPONENTS lib-other-sh
#      )
#
#   Specifying multiple acceptable versions:
#
#   .. code-block:: cmake
#
#      declare_PID_Package_Dependency (PACKAGE boost EXTERNAL
#                                      EXACT VERSION 1.55.0
#                                      EXACT VERSION 1.63.0
#                                      EXACT VERSION 1.64.0
#      )
#
#   Same but with reduced signature:
#
#   .. code-block:: cmake
#
#      PID_Dependency (boost EXACT VERSION 1.55.0
#                            EXACT VERSION 1.63.0
#                            EXACT VERSION 1.64.0
#      )
#
macro(PID_Dependency)
  declare_PID_Package_Dependency(${ARGN})
endmacro(PID_Dependency)

macro(declare_PID_Package_Dependency)

if(NOT PLUGIN_EXEC_BEFORE_DEPS)
  #plugin call point before any dependency (platform constraint or PID dependency)
  manage_Plugins_In_Package_Before_Dependencies_Description()
  set(PLUGIN_EXEC_BEFORE_DEPS TRUE)
endif()

set(options EXTERNAL NATIVE OPTIONAL)
set(oneValueArgs PACKAGE)
cmake_parse_arguments(DECLARE_PID_DEPENDENCY "${options}" "${oneValueArgs}" "" ${ARGN} )
if(DECLARE_PID_DEPENDENCY_PACKAGE)
  set(name_of_dependency ${DECLARE_PID_DEPENDENCY_PACKAGE})
elseif(${ARGC} LESS 1
    OR ("${ARGV0}" MATCHES "^EXTERNAL|NATIVE|OPTIONAL$"))
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in ${PROJECT_NAME} bad argumentswhen calling PID_Dependency, a name must be given to the required package using PACKAGE keywork (or by simply giving the name as first argument).")
else()
  set(name_of_dependency ${ARGV0})
  list(REMOVE_ITEM DECLARE_PID_DEPENDENCY_UNPARSED_ARGUMENTS ${name_of_dependency})#indeed we need to do that to manage remaining unparsed arguments because ARGV0 in this case belongs to unparsed args
endif()
if(name_of_dependency STREQUAL PROJECT_NAME)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in ${PROJECT_NAME} bad argumentswhen calling PID_Dependency, package ${name_of_dependency} cannot require itself !")
endif()
if(DECLARE_PID_DEPENDENCY_EXTERNAL AND DECLARE_PID_DEPENDENCY_NATIVE)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in ${PROJECT_NAME} bad arguments when calling PID_Dependency, declared dependency to package ${name_of_dependency} has both types EXTERNAL and NATIVE (use only one of these KEYWORDS).")
elseif(NOT DECLARE_PID_DEPENDENCY_EXTERNAL AND NOT DECLARE_PID_DEPENDENCY_NATIVE)
  get_Package_Type(${name_of_dependency} PACK_TYPE)
  if(PACK_TYPE STREQUAL "UNKNOWN")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : in ${PROJECT_NAME} bad arguments when calling PID_Dependency, package ${name_of_dependency} is unknown. It means the package is not referenced in any contribution space of the workspace. Please verify the name of ${name_of_dependency} or ask its maintainers which contribution space should be used to make this package available.")
  else()
    set(package_type ${PACK_TYPE})
  endif()
elseif(DECLARE_PID_DEPENDENCY_EXTERNAL)
  set(package_type "EXTERNAL")
else()
  set(package_type "NATIVE")
endif()
#first checks OK now parsing version related arguments
set(list_of_versions)
set(exact_versions)
set(REMAINING_TO_PARSE)
if(DECLARE_PID_DEPENDENCY_UNPARSED_ARGUMENTS)
  parse_Package_Dependency_All_Version_Arguments(${name_of_dependency} DECLARE_PID_DEPENDENCY_UNPARSED_ARGUMENTS list_of_versions exact_versions REMAINING_TO_PARSE PARSE_RESULT)
  if(NOT PARSE_RESULT)#error during parsing process
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Dependency, declared dependency to package ${name_of_dependency}, see previous messages.")
  endif()
  if(NOT list_of_versions)
    include_Find_File(${name_of_dependency})
    fill_String_From_List(ALL_VERSIONS ${name_of_dependency}_PID_KNOWN_VERSION ", ")
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME}, no version of dependency ${name_of_dependency} matches the version constraint. Available versions are ${ALL_VERSIONS}.")
  endif()
endif()
set(list_of_components)
if(REMAINING_TO_PARSE) #there are still components to parse
	set(oneValueArgs)
	set(options)
	set(multiValueArgs COMPONENTS)
	cmake_parse_arguments(DECLARE_PID_DEPENDENCY_MORE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${REMAINING_TO_PARSE})
	if(DECLARE_PID_DEPENDENCY_MORE_COMPONENTS)
		list(LENGTH DECLARE_PID_DEPENDENCY_MORE_COMPONENTS SIZE)
		if(SIZE LESS 1)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
			message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Dependency, at least one components must be defined using COMPONENTS keyword for declared dependency to package ${name_of_dependency}.")
		endif()
		set(list_of_components ${DECLARE_PID_DEPENDENCY_MORE_COMPONENTS})
	else()
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] WARNING : in package ${PROJECT_NAME} bad arguments when calling PID_Dependency, unknown arguments used ${DECLARE_PID_DEPENDENCY_MORE_UNPARSED_ARGUMENTS} to declared dependency to package ${name_of_dependency}, .")
	endif()
endif()
if(package_type STREQUAL "EXTERNAL")#it is an external package
  declare_External_Package_Dependency(${name_of_dependency} "${DECLARE_PID_DEPENDENCY_OPTIONAL}" "${list_of_versions}" "${exact_versions}" "${list_of_components}")
else()#otherwise a native package
	declare_Native_Package_Dependency(${name_of_dependency} "${DECLARE_PID_DEPENDENCY_OPTIONAL}" "${list_of_versions}" "${exact_versions}" "${list_of_components}")
endif()
endmacro(declare_PID_Package_Dependency)

#.rst:
# .. ifmode:: user
#
#  .. |used_PID_Dependency| replace:: ``used_PID_Dependency``
#  .. _used_PID_Dependency:
#
#  used_PID_Dependency
#  -------------------
#
#  .. command:: used_PID_Dependency([PACKAGE] ... [USED var] [VERSION var])
#
#  .. command:: used_PID_Package_Dependency([PACKAGE] ... [USED var] [VERSION var])
#
#    Get information about a dependency so that it can help the user configure the build.
#
#   .. rubric:: Required parameters
#
#   :[PACKAGE] <name>: Name of the depoendency. The PACKAGE ketword may be omitted.
#
#   .. rubric:: Optional parameters
#
#   :USED var: var is the output variable that is TRUE if dependency is used, FALSE otherwise. This is used to test if an optional dependency is in use.
#   :VERSION var: var is the output variable that contains the version of the dependency that is used for current build.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - Must be called after all declaration of package dependencies.
#
#   .. admonition:: Effects
#     :class: important
#
#     This function has no side effect but simply returns information about dependency.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      used_PID_Dependency(PACKAGE boost VERSION version_str)
#      #configure components according to version_str...
#
macro(used_PID_Dependency)
  used_PID_Package_Dependency(${ARGN})
endmacro(used_PID_Dependency)

function(used_PID_Package_Dependency)
set(oneValueArgs USED VERSION PACKAGE)
cmake_parse_arguments(USED_PACKAGE_DEPENDENCY "" "${oneValueArgs}" "" ${ARGN} )

if(USED_PACKAGE_DEPENDENCY_PACKAGE)
  set(dep_package ${USED_PACKAGE_DEPENDENCY_PACKAGE})
elseif(${ARGC} LESS 1
    OR ("${ARGV0}" MATCHES "^USED|VERSION$"))
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR: when calling used_PID_Dependency you specified no dependency name. Eithe pass the name as first argument or use the PACKAGE keyword to specify it.")
	return()
else()
  set(dep_package ${ARGV0})
endif()
set(package_found TRUE)
list(FIND ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package} INDEX)
if(INDEX EQUAL -1)
	list(FIND ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package} INDEX)
	if(INDEX EQUAL -1)
		set(package_found FALSE)
	else()
		set(IS_EXTERNAL TRUE)
	endif()
endif()

if(USED_PACKAGE_DEPENDENCY_USED)
	if(package_found)
		set(${USED_PACKAGE_DEPENDENCY_USED} TRUE PARENT_SCOPE)
	else()
		set(${USED_PACKAGE_DEPENDENCY_USED} FALSE PARENT_SCOPE)
	endif()
endif()

if(USED_PACKAGE_DEPENDENCY_VERSION)
	if(package_found)
		#from here it has been found so it may have a version
		if(IS_EXTERNAL)#it is an external package
			set(${USED_PACKAGE_DEPENDENCY_VERSION} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}} PARENT_SCOPE)#by definition no version used
		else()#it is a native package
			set(${USED_PACKAGE_DEPENDENCY_VERSION} ${${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}} PARENT_SCOPE)#by definition no version used
		endif()
	else()
		set(${USED_PACKAGE_DEPENDENCY_VERSION} FALSE PARENT_SCOPE)
	endif()
endif()
endfunction(used_PID_Package_Dependency)


#.rst:
# .. ifmode:: user
#
#  .. |PID_Component_Dependency| replace:: ``PID_Component_Dependency``
#  .. _PID_Component_Dependency:
#
#  PID_Component_Dependency
#  ------------------------
#
#  .. command:: PID_Component_Dependency([COMPONENT] ... [EXPORT|DEPEND] [NATIVE|EXTERNAL] ... [PACKAGE|FRAMEWORK ...] [definitions...])
#
#  .. command:: PID_Component_Dependency([COMPONENT] ... [EXPORT] [EXTERNAL ...] [OPTIONS])
#
#  .. command:: PID_Component_Dependency([COMPONENT] ... [EXPORT|DEPEND] CONFIGURATION ... [definitions...])
#
#  .. command:: declare_PID_Component_Dependency([COMPONENT] ... [EXPORT|DEPEND] [NATIVE|EXTERNAL] ... [PACKAGE ...] [defintions...])
#
#  .. command:: declare_PID_Component_Dependency([COMPONENT] ... [EXPORT] [EXTERNAL ...] [OPTIONS])
#
#   Declare a dependency for a component of the current package.
#   First signature is used to defince a dependency to an explicity component either native or external. Compared to the DEPEND option of |PID_Component|_ this function may define additional configuration for a given component dependency (typically setting definitions).
#   Second signature is used to define a dependency between the component and either the content of an external package or to the operating system.
#   Third signature is used to define a dependency between the component and all components defined by a configuration. This is a shortcut of second signature to bind a component with system dependencies that are described as configurations.
#   As often as possible first or third signature must be preferred to second one. This later here is mainly to ensure legacy compatibility.
#
#   .. rubric:: Common parameters
#
#   :[COMPONENT] <name>: Name of the component. The COMPONENT ketword may be omitted.
#   :EXPORT: If this flag is present, the dependency is exported. It means that symbols of this dependency appears in component public headers.
#   :INTERNAL_DEFINITIONS <defs>: Definitions used internally in ``name`` when the dependency is used.
#   :IMPORTED_DEFINITIONS <defs>: Definitions contained in the interface of the dependency that are set when the component uses this dependency.
#   :EXPORTED_DEFINITIONS <defs>: Definitions that are exported by ``name`` when that dependency is used.
#
#   .. rubric:: First signature
#
#   :[NATIVE] <component>: ``component`` is the native component that ``name`` depends upon. The keyword NATIVE is optional but may be useful to specify exactly the nature of the required component, for instance is there are naming conflicts between component of different packages. Cannot be used together with NATIVE keyword.
#   :[EXTERNAL] <component>: ``component`` is the external component that ``name`` depends upon. The keyword EXTERNAL is optional but may be useful to specify exactly the nature of the required component, for instance is there are naming conflicts between component of different packages. Cannot be used together with NATIVE keyword.
#   :[EXPORT]: If this flag is present, the dependency is exported. It means that symbols of this dependency appears in component public headers. Cannot be used together with DEPEND keyword.
#   :[DEPEND]: If this flag is present, the dependency is NOT exported. It means that symbols of this dependency do not appear in component public headers. Cannot be used together with EXPORT keyword. If none of EXPORT or DEPEND keyword are used, you must either use NATIVE or EXTERNAL keyword to specify the dependency.
#   :[PACKAGE <package>]: ``package`` is the native package that contains the component. If ``PACKAGE`` is not used, it means either ``component`` is part of the current package or it can be found in current package dependencies.
#   :[FRAMEWORK <framework>]: ``framework`` is the name of the framework containing the package that itself contains the component. Usable instead of ``PACKAGE``.
#   :[CONFIGURATION <framework>]: ``framework`` is the name of the framework containing the package that itself contains the component. Usable instead of ``PACKAGE``.
#
#   .. rubric:: Second signature
#
#   :[EXTERNAL <package>]: Name of the external package that component depends upon.
#   :INCLUDE_DIRS <dirs>: Specify include directories for this dependency. For external packages, these paths must be relative to the package root dir (using ``<package>``).
#   :LIBRARY_DIRS <path>: Specify library search directories for this dependency. For external packages, these paths must be relative to the package root dir (using ``<package>``).
#   :RUNTIME_RESOURCES <paths>: Specify where to find runtime resources. For external package, these paths must be relative to the package root dir (using ``<package>``).
#   :COMPILER_OPTIONS: Compiler options that are not definitions.
#   :LINKS STATIC|SHARED <links>:
#     - ``STATIC <links>``: static libraries. For system libraries, system referencing must be used (e.g. -lm for libm.a). For external packages, complete path (relative to the package root dir) must be used.
#     - ``SHARED <links>``: shared libraries. For system libraries, system referencing must be used (e.g. -lm for libm.a). For external packages, complete path (relative to the package root dir) must be used.
#
#   .. rubric:: Third signature
#
#   :[EXPORT]: If this flag is present, the dependency is exported. It means that symbols of this dependency appears in component public headers. Cannot be used together with DEPEND keyword.
#   :[DEPEND]: If this flag is present, the dependency is NOT exported. It means that symbols of this dependency do not appear in component public headers. Cannot be used together with EXPORT keyword. If none of EXPORT or DEPEND keyword are used, you must either use NATIVE or EXTERNAL keyword to specify the dependency.
#   :[CONFIGURATION <configuration>]: ``configuration`` is the name of the configuration defining the system dependency.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - Must be called after the component has been declared using |PID_Component|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     This function is used to defined a dependency between a component in the current package and another component. This will configure the build process accordingly.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      #declare a dependency to the content of an external package (do not use component description - NOT RECOMMENDED)
#      PID_Component_Dependency(COMPONENT my-static-lib
#                                       EXTERNAL boost INCLUDE_DIRS <boost>/include
#      )
#
#      #declare a dependency to an external component that is NOT exported
#      PID_Component_Dependency(my-static-lib
#                                       DEPEND EXTERNAL boost-headers PACKAGE boost
#      )
#
#      #declare a dependency to a system configuration that is NOT exported
#      PID_Component_Dependency(my-static-lib
#                                       DEPEND CONFIGURATION posix
#      )
#
#      #declare a dependency to a native package of same project that is exported
#      PID_Component_Dependency(COMPONENT my-static-lib
#                                       EXPORT NATIVE my-given-lib-bis
#      )
#
#      # suppose that package pid-rpath has been defined as a package dependency
#      declare_PID_Component_Dependency(my-static-lib
#                                       DEPEND NATIVE rpathlib PACKAGE pid-rpath
#      )
#
#      # suppose that package pid-rpath has been defined as a package dependency
#      PID_Component_Dependency(my-static-lib DEPEND rpathlib)
#
#      # suppose that package pid-rpath has been defined as a package dependency
#      PID_Component_Dependency(my-other-lib EXPORT rpathlib)
#      #it is exported since includes of rpathlib are in public includes of my-other-lib
#
#
macro(PID_Component_Dependency)
  declare_PID_Component_Dependency(${ARGN})
endmacro(PID_Component_Dependency)

macro(declare_PID_Component_Dependency)
set(options EXPORT DEPEND)
set(oneValueArgs COMPONENT NATIVE PACKAGE EXTERNAL FRAMEWORK C_STANDARD C_MAX_STANDARD CXX_STANDARD CXX_MAX_STANDARD CONFIGURATION)
set(multiValueArgs INCLUDE_DIRS LIBRARY_DIRS LINKS COMPILER_OPTIONS INTERNAL_DEFINITIONS IMPORTED_DEFINITIONS EXPORTED_DEFINITIONS RUNTIME_RESOURCES)
cmake_parse_arguments(DECLARE_PID_COMPONENT_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

if(NOT DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT)
  if(${ARGC} LESS 1 OR ${ARGV0} MATCHES "^EXPORT|DEPEND|NATIVE|PACKAGE|EXTERNAL|C_STANDARD|CXX_STANDARD|C_MAX_STANDARD|CXX_MAX_STANDARD|INCLUDE_DIRS LINKS|COMPILER_OPTIONS|INTERNAL_DEFINITIONS|IMPORTED_DEFINITIONS|EXPORTED_DEFINITIONS|RUNTIME_RESOURCES$")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Component_Dependency, a name must be given to the component that declare the dependency using COMPONENT keyword or simply by using first argument.")
  else()
    set(component_name ${ARGV0})
    if(DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS)
      list(REMOVE_ITEM DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS ${component_name})#in case of the component has been described without using the COMPONENT keyword it also belongs to unparsed arguments
    endif()
  endif()
else()
  set(component_name ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT})
endif()
if(NOT ${PROJECT_NAME}_${component_name}_FOR_DOC_ONLY)
  set(comp_defs "")
  if(DECLARE_PID_COMPONENT_DEPENDENCY_INTERNAL_DEFINITIONS)
    set(comp_defs ${DECLARE_PID_COMPONENT_DEPENDENCY_INTERNAL_DEFINITIONS})
  endif()

  set(dep_defs "")
  if(DECLARE_PID_COMPONENT_DEPENDENCY_IMPORTED_DEFINITIONS)
    set(dep_defs ${DECLARE_PID_COMPONENT_DEPENDENCY_IMPORTED_DEFINITIONS})
  endif()

  set(comp_exp_defs "")
  if(DECLARE_PID_COMPONENT_DEPENDENCY_EXPORTED_DEFINITIONS)
    set(comp_exp_defs ${DECLARE_PID_COMPONENT_DEPENDENCY_EXPORTED_DEFINITIONS})
  endif()

  set(static_links "")
  set(shared_links "")
  if(DECLARE_PID_COMPONENT_DEPENDENCY_LINKS)
    set(multiValueArgs STATIC SHARED)
    cmake_parse_arguments(DECLARE_PID_COMPONENT_DEPENDENCY_LINKS "" "" "${multiValueArgs}" ${DECLARE_PID_COMPONENT_DEPENDENCY_LINKS} )
    if(DECLARE_PID_COMPONENT_DEPENDENCY_LINKS_UNPARSED_ARGUMENTS)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Component_Dependency, the LINKS option argument must be followed only by static and/or shared links for component ${component_name}.")
    endif()

    if(DECLARE_PID_COMPONENT_DEPENDENCY_LINKS_STATIC)
      set(static_links ${DECLARE_PID_COMPONENT_DEPENDENCY_LINKS_STATIC})
    endif()

    if(DECLARE_PID_COMPONENT_DEPENDENCY_LINKS_SHARED)
      set(shared_links ${DECLARE_PID_COMPONENT_DEPENDENCY_LINKS_SHARED})
    endif()
  endif()

  if(DECLARE_PID_COMPONENT_DEPENDENCY_COMPILER_OPTIONS)
    set(compiler_options ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPILER_OPTIONS})
  endif()

  #check that the signature follows one of the allowed signatures and memorize corresponding attributes

  #the dependency is exported
  if(DECLARE_PID_COMPONENT_DEPENDENCY_EXPORT) #EXPORT keyword has priority over DEPEND one, so if both are used the dependency is exported.
    set(export TRUE)
  else()
    set(export FALSE)
  endif()

  set(package_type)
  set(target_component)
  set(target_package)

  if(DECLARE_PID_COMPONENT_DEPENDENCY_NATIVE AND DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when declaring dependency for component ${component_name}, keywords EXTERNAL (requiring an external package) and NATIVE (requiring a native component) cannot be used simultaneously.")
  elseif(DECLARE_PID_COMPONENT_DEPENDENCY_NATIVE)

    #when the explicit NATIVE signature is used there should be no unparsed argument
    if(DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when declaring dependency for component ${component_name}, unknown arguments ${DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS}.")
    endif()

    set(package_type "NATIVE")#component defined in a native package
    set(target_component ${DECLARE_PID_COMPONENT_DEPENDENCY_NATIVE})
    if(DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE) #another package is formally defined
      set(target_package ${DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE})
    endif()
  elseif(DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL)

    #when the explicit EXTERNAL signature is used there should be no unparsed argument
    if(DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when declaring dependency for component ${component_name}, unknown arguments ${DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS}.")
    endif()

    set(package_type "EXTERNAL")#component formally defined in an external package

    if(DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE) #an external package name is given => external package is supposed to be provided with a description file
      if(DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE STREQUAL PROJECT_NAME)
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when declaring dependency for component ${component_name}, the external package cannot be current project !")
      endif()

      set(target_component ${DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL})#in this situation the name of the component is given by the external keyword
      set(target_package ${DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE})
    else()#no package explicitely specified => 2 cases : either a direct dependency to an external package content OR an external component is specified with implicit external package
      # check if the name target by EXTERNAL matches an external package name
      get_Package_Type(${DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL} PACK_TYPE)
      if(NOT PACK_TYPE STREQUAL "EXTERNAL")#the name does not refer to an external package => it should be an external component
        set(target_component ${DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL})#EXTERNAL keyword is used to target a component
      else()#the name used is the name of an EXTERNAL package
        set(target_component)#in this situation the name of the component is empty since no component is explicitly targetted
        set(target_package ${DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL})#the EXTERNAL keyword refers to an exetrnal package
      endif()
    endif()
  else()#NO keyword used to specify the kind of component => we do not know if package is native or external
    #either EXPORT or DEPEND must be used to specify if the dependency is exported or not
    if(NOT DECLARE_PID_COMPONENT_DEPENDENCY_EXPORT AND NOT DECLARE_PID_COMPONENT_DEPENDENCY_DEPEND)
      #no component specified
      if(DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS) #there is a target component specified => ERROR
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when declaring dependency for component ${component_name}, you must use either EXPORT or DEPEND keyword to define the dependency if you do not use either NATIVE or EXTERNAL explicit declarations.")
      endif()
    endif()

    if(DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS)
      #unparsed arguments contains the name of the dependency
      list(GET DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS 0 first_one)
      set(target_component ${first_one})
    endif()
    if(DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE) #a package name is explicitly given
      set(target_package ${DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE})
    elseif(DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK)
      check_Framework_Exists(CHECK_OK ${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK})
      if(NOT CHECK_OK)#specified framework does not exists
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when declaring dependency for component ${component_name}, framework ${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK} containing component ${target_component} is unknown.")
      endif()
      set(CONTAINERS_IN_FRAMEWORK)
      find_Packages_Containing_Component(CONTAINERS ${PROJECT_NAME} ${target_component})
      foreach(pack IN LISTS CONTAINERS)
        if(${pack}_FRAMEWORK STREQUAL "${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK}")
          list(APPEND CONTAINERS_IN_FRAMEWORK ${pack})
        endif()
      endforeach()
      list(LENGTH CONTAINERS_IN_FRAMEWORK SIZE)
      if(SIZE EQUAL 0)
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when declaring dependency for component ${component_name}, no package defining component ${target_component} belongs to framework ${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK}.")
      elseif(SIZE GREATER 1)
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when declaring dependency for component ${component_name}, many packages (${CONTAINERS_IN_FRAMEWORK}) of the framework ${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK} define a component named ${target_component}. This denotes a bad design of framework ${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK} because this later should ensure component names unicity.")
      else()
        set(target_package ${CONTAINERS_IN_FRAMEWORK})
      endif()
    endif()
  endif()

  #now try to resolve the package in use if not explicitly specified while a component is used
  if(NOT target_package AND target_component)
    find_Packages_Containing_Component(CONTAINERS ${PROJECT_NAME} ${target_component})
    list(LENGTH CONTAINERS SIZE)
    if(SIZE EQUAL 0)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when declaring dependency for component ${component_name}, component ${target_component} cannot be found in ${PROJECT_NAME} or its dependencies.")
    elseif(SIZE GREATER 1)#more than one component has target name and no package specified
      if(NOT DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK)
        #no framework name specified so it is really a lone component name
        list(FIND CONTAINERS ${PROJECT_NAME} INDEX)
        if(INDEX EQUAL -1) #if component does not belong to current project
          finish_Progress(${GLOBAL_PROGRESS_VAR})
          message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when declaring dependency for component ${component_name}, cannot deduce the package containing component ${target_component} because many packages contain a component with same name: ${CONTAINERS}.")
        else()#OK by definition internal dependencies have always priority in this situation
          set(target_package ${PROJECT_NAME})
        endif()
      else()
        #in case there is more than one package defining same component name, if a framework is defined
        # we can find if there is only one package of the list belonging to that framework
        check_Framework_Exists(CHECK_OK ${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK})
        if(NOT CHECK_OK)#specified framework does not exists
          finish_Progress(${GLOBAL_PROGRESS_VAR})
          message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when declaring dependency for component ${component_name}, framework ${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK} containing component ${target_component} is unknown.")
        endif()
        set(CONTAINERS_IN_FRAMEWORK)
        foreach(pack IN LISTS CONTAINERS)
          if(${pack}_FRAMEWORK STREQUAL "${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK}")
            list(APPEND CONTAINERS_IN_FRAMEWORK ${pack})
          endif()
        endforeach()
        list(LENGTH CONTAINERS_IN_FRAMEWORK SIZE)
        if(SIZE EQUAL 0)
          finish_Progress(${GLOBAL_PROGRESS_VAR})
          message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when declaring dependency for component ${component_name}, no package defining component ${target_component} belongs to framework ${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK}.")
        elseif(SIZE GREATER 1)
          finish_Progress(${GLOBAL_PROGRESS_VAR})
          message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when declaring dependency for component ${component_name}, many packages (${CONTAINERS_IN_FRAMEWORK}) of the framework ${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK} define a component named ${target_component}. This denotes a bad design of framework ${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK} because this later should ensure component names unicity.")
        else()
          set(target_package ${CONTAINERS_IN_FRAMEWORK})
        endif()
      endif()
    else()#there is exactly one container
      if(DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK)#we need to check that the package really belongs to the framework
        check_Framework_Exists(CHECK_OK ${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK})
        if(NOT CHECK_OK)#specified framework does not exists
          finish_Progress(${GLOBAL_PROGRESS_VAR})
          message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when declaring dependency for component ${component_name}, framework ${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK} containing component ${target_component} is unknown.")
        endif()
        if(${CONTAINERS}_FRAMEWORK STREQUAL "${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK}")#OK adequate framework specified
          set(target_package ${CONTAINERS})
        else()
          finish_Progress(${GLOBAL_PROGRESS_VAR})
          message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when declaring dependency for component ${component_name}, only package that belongs to framework ${DECLARE_PID_COMPONENT_DEPENDENCY_FRAMEWORK} is ${CONTAINERS} but this later does not contain component ${target_component}.")
        endif()
      else()
      set(target_package ${CONTAINERS})#Note: CONTAINERS is the current project if found nowhere else
      endif()
    endif()
  endif()

  #check for package dependency (native or external)
  if(target_package)
    if(NOT target_package STREQUAL PROJECT_NAME)# do not check for dependency for an internal component
      #check that package type has been resolved
      if(NOT package_type)
        get_Package_Type(${target_package} THETYPE)
        set(package_type ${THETYPE})
      endif()
      if(NOT DO_NOT_PRODUCE_WARNINGS_FOR_DIRECT_DEPENDENCY_TO_UNDIRECT_PACKAGE)
        #produce a warning if the package is not a direct dependency of the current project
        is_Package_Dependency(IS_DEPENDENCY "${target_package}")
        if(NOT IS_DEPENDENCY)
          set(IS_CONFIGURED TRUE)
          if(${PROJECT_NAME}_${component_name}_TYPE STREQUAL "TEST" AND NOT BUILD_AND_RUN_TESTS)
            set(IS_CONFIGURED FALSE)
          elseif(${PROJECT_NAME}_${component_name}_TYPE STREQUAL "EXAMPLE" AND (NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${component_name}))
            set(IS_CONFIGURED FALSE)
          endif()
          if(IS_CONFIGURED) #only notify the error if the package DOES configure the component
            message(WARNING "[PID] WARNING : in package ${PROJECT_NAME} bad arguments when declaring dependency for component ${component_name}, the component directly depends on an non direct package ${target_package} !")
          endif()
        endif()
      endif()
    endif()
  endif()

  #AFTER CHECKS: now do the declaration for real according to the signatire of the call
  if(target_package)#a package name where to find the component is known
    if(target_package STREQUAL PROJECT_NAME)#internal dependency, by definition
      if(target_component STREQUAL component_name)
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when declaring dependency for component ${component_name}, the component cannot depend on itself !")
      endif()
      declare_Internal_Component_Dependency(
            ${component_name}
            ${target_component}
            ${export}
            "${comp_defs}"
            "${comp_exp_defs}"
            "${dep_defs}"
            )
    elseif(package_type STREQUAL "NATIVE")
      declare_Package_Component_Dependency(
            ${component_name}
            ${target_package}
            ${target_component}
            ${export}
            "${comp_defs}"
            "${comp_exp_defs}"
            "${dep_defs}"
            )
    elseif(target_component)#package_type is "EXTERNAL" AND a component is specified
      declare_External_Component_Dependency(
            ${component_name}
            ${target_package}
            ${target_component}
            ${export}
            "${comp_defs}"
            "${comp_exp_defs}"
            "${dep_defs}")
    else()#package_type is "EXTERNAL" AND a NO component is specified (direct references to external package content)
      set(fake_intern)
      adjust_Languages_Standards_Description(ERR MESS C_STD_USED CXX_STD_USED INTERN_OPTS EXPORT_OPTS
                                            fake_intern compiler_options
                                            "${DECLARE_PID_COMPONENT_DEPENDENCY_C_STANDARD}"
                                            "${DECLARE_PID_COMPONENT_DEPENDENCY_C_MAX_STANDARD}"
                                            "${DECLARE_PID_COMPONENT_DEPENDENCY_CXX_STANDARD}"
                                            "${DECLARE_PID_COMPONENT_DEPENDENCY_CXX_MAX_STANDARD}")
      if(ERR)
        if(ERR STREQUAL "CRITICAL")
          finish_Progress(${GLOBAL_PROGRESS_VAR})
          message(FATAL_ERROR "[PID] CRITICAL ERROR: in package ${PROJECT_NAME} when declaring direct dependency to package ${target_package} for component ${component_name} in package ${PROJECT_NAME}, ${MESS}")
        else()
          message("[PID] WARNING: in package ${PROJECT_NAME} when declaring direct dependency to package ${target_package} for component ${component_name} in package ${PROJECT_NAME}, ${MESS}")
        endif()
      endif()

      declare_External_Package_Component_Dependency(
            ${component_name}
            ${target_package}
            ${export}
            "${DECLARE_PID_COMPONENT_DEPENDENCY_INCLUDE_DIRS}"
            "${comp_defs}"
            "${comp_exp_defs}"
            "${dep_defs}"
            "${INTERN_OPTS}"
            "${static_links}"
            "${shared_links}"
            "${C_STD_USED}"
            "${DECLARE_PID_COMPONENT_DEPENDENCY_C_MAX_STANDARD}"
            "${CXX_STD_USED}"
            "${DECLARE_PID_COMPONENT_DEPENDENCY_CXX_MAX_STANDARD}"
            "${DECLARE_PID_COMPONENT_DEPENDENCY_RUNTIME_RESOURCES}")
    endif()
  else()#no target package => 2 cases OS dependency OR ERROR
    if(target_component) #a PID component is given so it cannot be a system dependency
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} when declaring dependency for component ${component_name}, the package containing component ${target_component} cannot be deduced !")
    else()#this is a system dependency
      if(DECLARE_PID_COMPONENT_DEPENDENCY_CONFIGURATION)#system dependency described with a direct configuration
        declare_System_Component_Dependency_Using_Configuration(
          ${component_name}
          ${export}
          ${DECLARE_PID_COMPONENT_DEPENDENCY_CONFIGURATION}
          "${comp_defs}"
          "${comp_exp_defs}"
          "${dep_defs}"
        )
      else()
        set(fake_intern)
        adjust_Languages_Standards_Description(ERR MESS C_STD_USED CXX_STD_USED INTERN_OPTS EXPORT_OPTS
                                              fake_intern compiler_options
                                              "${DECLARE_PID_COMPONENT_DEPENDENCY_C_STANDARD}"
                                              "${DECLARE_PID_COMPONENT_DEPENDENCY_C_MAX_STANDARD}"
                                              "${DECLARE_PID_COMPONENT_DEPENDENCY_CXX_STANDARD}"
                                              "${DECLARE_PID_COMPONENT_DEPENDENCY_CXX_MAX_STANDARD}")
        if(ERR)
          if(ERR STREQUAL "CRITICAL")
            finish_Progress(${GLOBAL_PROGRESS_VAR})
            message(FATAL_ERROR "[PID] CRITICAL ERROR: in package ${PROJECT_NAME} when declaring direct system dependency for component ${component_name} in package ${PROJECT_NAME}, ${MESS}")
          else()
            message("[PID] WARNING: when declaring direct system dependency for component ${component_name} in package ${PROJECT_NAME}, ${MESS}")
          endif()
        endif()
        declare_System_Component_Dependency(
            ${component_name}
            ${export}
            "${DECLARE_PID_COMPONENT_DEPENDENCY_INCLUDE_DIRS}"
            "${DECLARE_PID_COMPONENT_DEPENDENCY_LIBRARY_DIRS}"
            "${comp_defs}"
            "${comp_exp_defs}"
            "${dep_defs}"
            "${INTERN_OPTS}"
            "${static_links}"
            "${shared_links}"
            "${C_STD_USED}"
            "${DECLARE_PID_COMPONENT_DEPENDENCY_C_MAX_STANDARD}"
            "${CXX_STD_USED}"
            "${DECLARE_PID_COMPONENT_DEPENDENCY_CXX_MAX_STANDARD}"
            "${DECLARE_PID_COMPONENT_DEPENDENCY_RUNTIME_RESOURCES}")
      endif()
    endif()
  endif()
endif()

endmacro(declare_PID_Component_Dependency)


#.rst:
# .. ifmode:: user
#
#  .. |run_PID_Test| replace:: ``run_PID_Test``
#  .. _run_PID_Test:
#
#  run_PID_Test
#  ------------
#
#  .. command:: run_PID_Test(NAME ... [OPTIONS])
#
#   Run a test using an application.
#
#   The application can be:
#   - an executable (e.g. valgrind)
#   - a PID component (standard, example or test application)
#   - a Python script
#
#   .. rubric:: Common parameters
#
#   :NAME <name>: Unique identifier for the test
#   :ARGUMENTS <args>: (optional) Arguments passed to the executable, component or script
#
#   .. rubric:: Executable parameters
#
#   :EXE <name>: Name of the executable to run.
#
#   .. rubric:: Component parameters
#
#   :COMPONENT <name>: Name of the component to run.
#   :PACKAGE <name>: Package to which the component belongs (defaults to the current package).
#
#   .. rubric:: Python script
#
#   :PYTHON: Flag the test as a Python test.
#
#   In that case, the first argument of ``ARGUMENTS`` is interpreted as a Python script, located in the ``test`` or ``share/script`` folder of the package.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - The component variant of this function must be called after the component has been declared.
#
#   .. admonition:: Effects
#     :class: important
#
#     Adds a test to the ``make test`` target. When the test is run it will generate a ``PASSED`` or ``ERROR`` message according to the result.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      run_PID_Test (NAME correctness_of_my-shared-lib_step1 COMPONENT my-test ARGUMENTS "first" "124" "12")
#      run_PID_Test (NAME correctness_of_my-shared-lib_step2 COMPONENT my-test ARGUMENTS "second" "12" "46")
#      run_PID_Test (NAME correctness_of_my-shared-lib_step3 COMPONENT my-test ARGUMENTS "first" "0" "87")
#
function(run_PID_Test)
set(options PRIVILEGED PYTHON)
set(oneValueArgs NAME EXE COMPONENT PACKAGE)
set(multiValueArgs ARGUMENTS)
cmake_parse_arguments(RUN_PID_TEST "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(RUN_PID_TEST_UNPARSED_ARGUMENTS)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments for the test ${RUN_PID_TEST_NAME}, unknown arguments ${DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS}.")
endif()
if(NOT RUN_PID_TEST_NAME)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments for the test ${RUN_PID_TEST_NAME}, a name must be given to the test (using NAME <name> syntax) !")
else()
  cmake_policy(GET CMP0064 CAN_TEST_TEST_NAME)
	if(CAN_TEST_TEST_NAME STREQUAL "NEW")
		if(TEST ${RUN_PID_TEST_NAME})
			message("[PID] WARNING : in package ${PROJECT_NAME} bad arguments for the test ${RUN_PID_TEST_NAME}, this test unit is already defined. Skipping new definition !")
			return()
		endif()
	endif()
endif()

if(NOT RUN_PID_TEST_EXE AND NOT RUN_PID_TEST_COMPONENT AND NOT RUN_PID_TEST_PYTHON)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments for the test ${RUN_PID_TEST_NAME}, an executable must be defined. Using EXE you can use an executable present on your system. By using COMPONENT you can specify a component built by the project. In this later case you must specify a PID executable component. If the PACKAGE keyword is used then this component will be found in another package than the current one. Finaly you can otherwise use the PYTHON keyword and pass the target python script file lying in your test folder as argument (path is relative to the test folder).")
endif()

if((RUN_PID_TEST_EXE AND RUN_PID_TEST_COMPONENT)
		OR (RUN_PID_TEST_EXE AND RUN_PID_TEST_PYTHON)
		OR (RUN_PID_TEST_COMPONENT AND RUN_PID_TEST_PYTHON))
    finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments for the test ${RUN_PID_TEST_NAME}, you must use either a system executable (using EXE keyword) OR a PID application component (using COMPONENT keyword) OR the python executable (using PYTHON keyword).")
endif()

if(RUN_PID_TEST_PYTHON)
	if(NOT CURRENT_PYTHON)
		return()
	endif()
	if(NOT RUN_PID_TEST_ARGUMENTS)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments for the test ${RUN_PID_TEST_NAME}, you must define a path to a target python file using ARGUMENTS keyword.")
	endif()
	list(LENGTH  RUN_PID_TEST_ARGUMENTS SIZE)
	if(NOT SIZE EQUAL 1)
		message("[PID] WARNING : in package ${PROJECT_NAME} bad arguments for the test ${RUN_PID_TEST_NAME}, you must define a path to a UNIQUE target python file using ARGUMENTS keyword. First file is selected, others will be ignored.")
	endif()
	list(GET RUN_PID_TEST_ARGUMENTS 0 target_py_file)
	if (NOT target_py_file MATCHES "^.*\\.py$")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments for the test ${RUN_PID_TEST_NAME}, ${target_py_file} is not a python file.")
	endif()
	if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${target_py_file})#first check that the file exists in test folder
		set(PATH_TO_PYTHON_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${target_py_file})
	elseif(EXISTS ${CMAKE_SOURCE_DIR}/share/script/${target_py_file})
		set(PATH_TO_PYTHON_FILE ${CMAKE_SOURCE_DIR}/share/script/${target_py_file})
	else()
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments for the test ${RUN_PID_TEST_NAME}, ${target_py_file} cannot be found in either test or script folders.")
	endif()
endif()

if(NOT PID_CROSSCOMPILATION)
	set(PROJECT_RUN_TESTS TRUE CACHE INTERNAL "")
elseif(BUILD_AND_RUN_TESTS)
  message("[PID] INFO : in package ${PROJECT_NAME} cannot run tests because project is currently compiled for another target than host !")
endif()

if(RUN_PID_TEST_PRIVILEGED)
	if(NOT RUN_TESTS_WITH_PRIVILEGES)
		set(RUN_TESTS_WITH_PRIVILEGES TRUE CACHE INTERNAL "")
	endif()
endif()

if(RUN_PID_TEST_EXE)
	call_CTest(${RUN_PID_TEST_NAME} "${RUN_PID_TEST_EXE}" "${RUN_PID_TEST_ARGUMENTS}")
elseif(RUN_PID_TEST_COMPONENT)# run test by executing a PID component
	if(RUN_PID_TEST_PACKAGE)#component coming from another PID package
		set(target_of_test ${RUN_PID_TEST_PACKAGE}_${RUN_PID_TEST_COMPONENT}${INSTALL_NAME_SUFFIX})
		call_CTest(${RUN_PID_TEST_NAME} "${target_of_test}" "${RUN_PID_TEST_ARGUMENTS}")
	else()#internal component
		call_CTest(${RUN_PID_TEST_NAME} "${PROJECT_NAME}_${RUN_PID_TEST_COMPONENT}${INSTALL_NAME_SUFFIX}" "${RUN_PID_TEST_ARGUMENTS}")
	endif()
elseif(RUN_PID_TEST_PYTHON)#run PID test with python
	call_CTest(${RUN_PID_TEST_NAME} "${CURRENT_PYTHON_EXECUTABLE}" "${PATH_TO_PYTHON_FILE}")
	#setting the python path automatically for this test
	set_tests_properties(${RUN_PID_TEST_NAME} PROPERTIES ENVIRONMENT "PYTHONPATH=${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/__python${CURRENT_PYTHON}__")
endif()
endfunction(run_PID_Test)


#############################################################################################
###########################Other functions of the API #######################################
#############################################################################################

#.rst:
# .. ifmode:: user-advanced
#
#  .. |external_PID_Package_Path| replace:: ``external_PID_Package_Path``
#  .. _external_PID_Package_Path:
#
#  external_PID_Package_Path
#  ^^^^^^^^^^^^^^^^^^^^^^^^^
#
#  .. command:: external_PID_Package_Path(NAME ... PATH ...)
#
#   Get the path to a target external package that is supposed to exist in the local workspace.
#
#   .. rubric:: Required parameters
#
#   :NAME <name>: Name of the target external package.
#   :PATH <var>: ``<var>`` will contain the package root folder.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - This function must be called after a dependency to ``name`` has been declared using |PID_Dependency|_.
#
#   .. admonition:: Effects
#     :class: important
#
#     No effect on the project.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      external_PID_Package_Path(NAME boost PATH BOOST_ROOT_PATH)
#      message(INFO "Boost root path is: ${BOOST_ROOT_PATH}")
#
function(external_PID_Package_Path)
set(oneValueArgs NAME PATH)
cmake_parse_arguments(EXT_PACKAGE_PATH "" "${oneValueArgs}" "" ${ARGN} )
if(NOT EXT_PACKAGE_PATH_NAME OR NOT EXT_PACKAGE_PATH_PATH)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name of an external package must be provided with name and a variable containing the resulting path must be set with PATH keyword.")
endif()
is_External_Package_Defined(PATHTO "${EXT_PACKAGE_PATH_NAME}" ${CMAKE_BUILD_TYPE})
if(NOT PATHTO)
	set(${EXT_PACKAGE_PATH_PATH} NOTFOUND PARENT_SCOPE)
else()
	set(${EXT_PACKAGE_PATH_PATH} ${PATHTO} PARENT_SCOPE)
endif()
endfunction(external_PID_Package_Path)


#.rst:
# .. ifmode:: user-advanced
#
#  .. |create_PID_Install_Symlink| replace:: ``create_PID_Install_Symlink``
#  .. _create_PID_Install_Symlink:
#
#  create_PID_Install_Symlink
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#  .. command:: create_PID_Install_Symlink(NAME ... PATH ... TARGET ...)
#
#   Creates a symlink somewhere in the install folder of the package.
#
#   .. rubric:: Required parameters
#
#   :NAME <name>: Name of the created symlink.
#   :PATH <var>: Path (relative to the package install folder) where the symlink will be put.
#   :TARGET <path>: The absolute path targetted by the symlink.
#
#   .. admonition:: Constraints
#      :class: warning
#
#      - The target path must exist.
#
#   .. admonition:: Effects
#     :class: important
#
#     This creates a package specific symlink. It is mostly used to manage runtime dependencies for specific external or system resources.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      external_PID_Package_Path (NAME boost PATH BOOST_ROOT_PATH)
#      create_PID_Install_Symlink(NAME libboost_system.so PATH bin TARGET ${BOOST_ROOT_PATH}/lib/libboost_system.so)
#
macro(create_PID_Install_Symlink)
set(oneValueArgs NAME PATH TARGET)
cmake_parse_arguments(CREATE_INSTALL_SYMLINK "" "${oneValueArgs}" "" ${ARGN} )
if(NOT CREATE_INSTALL_SYMLINK_NAME OR NOT CREATE_INSTALL_SYMLINK_PATH OR NOT CREATE_INSTALL_SYMLINK_TARGET)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name for the new symlink created must be provided with NAME keyword, the path relative to its install location must be provided with PATH keyword and the target of the symlink must be provided with TARGET keyword.")
endif()
set(FULL_INSTALL_PATH ${CMAKE_INSTALL_PREFIX}/${${PROJECT_NAME}_DEPLOY_PATH}/${CREATE_INSTALL_SYMLINK_PATH})
set( link   ${CREATE_INSTALL_SYMLINK_NAME})
set( target ${CREATE_INSTALL_SYMLINK_TARGET})

add_custom_target(install_symlink_${link} ALL
        COMMAND ${CMAKE_COMMAND} -E remove -f ${FULL_INSTALL_PATH}/${link}
	COMMAND ${CMAKE_COMMAND} -E chdir ${FULL_INSTALL_PATH} ${CMAKE_COMMAND} -E  create_symlink ${target} ${link})

endmacro(create_PID_Install_Symlink)
