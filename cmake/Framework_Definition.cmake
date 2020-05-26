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
if(FRAMEWORK_DEFINITION_INCLUDED)
  return()
endif()
set(FRAMEWORK_DEFINITION_INCLUDED TRUE)
##########################################################################################

get_filename_component(abs_path_to_ws ${WORKSPACE_DIR} ABSOLUTE)
set(WORKSPACE_DIR ${abs_path_to_ws} CACHE PATH "" FORCE)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Framework_API_Internal_Functions NO_POLICY_SCOPE)
include(CMakeParseArguments)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Framework| replace:: ``PID_Framework``
#  .. _PID_Framework:
#
#  PID_Framework
#  -------------
#
#   .. command:: PID_Framework(AUTHOR ... YEAR ... LICENSE ... DESCRIPTION ... ADDRESS ... SITE ... [OPTIONS])
#
#   .. command:: declare_PID_Framework(AUTHOR ... YEAR ... LICENSE ... DESCRIPTION ... ADDRESS ... SITE ... [OPTIONS])
#
#      Declare the current CMake project as a PID framework.
#
#     .. rubric:: Required parameters
#
#     :AUTHOR <name>: The name of the author in charge of maintaining the framework.
#     :YEAR <dates>: Reflects the lifetime of the package, e.g. ``YYYY-ZZZZ`` where ``YYYY`` is the creation year and ``ZZZZ`` the latest modification date.
#     :LICENSE <license name>: The name of the license applying to the framework. This must match one of the existing license file in the ``licenses`` directory of the workspace.
#     :DESCRIPTION <description>: A short description of the framework.
#     :ADDRESS <url>: The url of the framework's repository. Must be set once the package is published.
#     :SITE <url>: The url where to find the static site generated by the framework.
#
#     .. rubric:: Optional parameters
#
#     :PUBLIC_ADDRESS <url>: The url of the framework repository public address (if package is public only) from where to get modifications of the fraemwork.
#     :INSTITUTION <institutions>: Define the institution(s) to which the framework maintainer belongs to.
#     :MAIL <e-mail>: E-mail of the maintainer author.
#     :PROJECT <url>: The url of the online git repository project page where to find source code of the framework.
#     :LOGO <path to image file>: The path to the image used as logo for the framework. This path is relative to framework src/assets folder.
#     :BANNER <path to image file>: The path to the image used as a banner for the framework index page. This path is relative to framework src/assets folder.
#     :WELCOME <path to markdown file>: The path to the mardown use for the welcome. This path is relative to framework src/pages folder.
#     :CONTRIBUTION_SPACE <name>: the name of the default contribution space used by the framework to publish its references.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root CMakeLists.txt file of the framework, before any other call to PID framework API.
#        - Exactly one call to this macro is allowed.
#
#     .. admonition:: Effects
#        :class: important
#
#         Initialization of framework’s internal state: after this call the framework’s content is ready to be defined.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        PID_Framework(
#           AUTHOR       Robin Passama
#       		MAIL         passama@lirmm.fr
#       		INSTITUTION  LIRMM
#       		ADDRESS      git@gite.lirmm.fr:pid/pid-framework.git
#           PUBLIC_ADDRESS https://gite.lirmm.fr/pid/pid-framework.git
#       	 	YEAR         2016
#       		LICENSE      CeCILL-C
#       		DESCRIPTION  "PID is a global development methodology supported by many tools inclusing a CMake API and dedicated C++ projects."
#       		SITE         https://pid.lirmm.net/pid-framework
#       		PROJECT      https://gite.lirmm.fr/pid/pid-framework
#       		LOGO         img/pid_logo.jpg
#       		BANNER       img/cooperationmechanisms.jpg
#       	)
#
macro(PID_Framework)
  declare_PID_Framework(${ARGN})
endmacro(PID_Framework)

macro(declare_PID_Framework)
set(oneValueArgs GIT_ADDRESS ADDRESS PUBLIC_ADDRESS MAIL EMAIL SITE PROJECT LICENSE LOGO BANNER WELCOME CONTRIBUTION_SPACE)
set(multiValueArgs AUTHOR INSTITUTION YEAR DESCRIPTION CATEGORIES)
cmake_parse_arguments(DECLARE_PID_FRAMEWORK "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_FRAMEWORK_AUTHOR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an author name must be given using AUTHOR keyword.")
endif()
if(NOT DECLARE_PID_FRAMEWORK_YEAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a year or year interval must be given using YEAR keyword.")
endif()
if(NOT DECLARE_PID_FRAMEWORK_SITE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a web site address must be given using SITE keyword.")
endif()
if(NOT DECLARE_PID_FRAMEWORK_LICENSE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a license must be defined using LICENSE keyword.")
endif()
if(NOT DECLARE_PID_FRAMEWORK_DESCRIPTION)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a (short) description of the framework must be given using DESCRIPTION keyword.")
endif()

if(DECLARE_PID_FRAMEWORK_UNPARSED_ARGUMENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, unknown arguments ${DECLARE_PID_FRAMEWORK_UNPARSED_ARGUMENTS}.")
endif()

if(DECLARE_PID_FRAMEWORK_ADDRESS)
	set(address ${DECLARE_PID_FRAMEWORK_ADDRESS})
elseif(DECLARE_PID_FRAMEWORK_GIT_ADDRESS)#deprecated
	set(address ${DECLARE_PID_FRAMEWORK_GIT_ADDRESS})
else()
	message(FATAL_ERROR "[PID] CRITICAL ERROR : you must define the address of the framework's repository using either ADDRESS or GIT_ADDRESS keyword.")
endif()


if(DECLARE_PID_FRAMEWORK_MAIL)
  set(email ${DECLARE_PID_FRAMEWORK_MAIL})
elseif(DECLARE_PID_FRAMEWORK_EMAIL)
  set(email ${DECLARE_PID_FRAMEWORK_EMAIL})
endif()
declare_Framework(	"${DECLARE_PID_FRAMEWORK_AUTHOR}" "${DECLARE_PID_FRAMEWORK_INSTITUTION}" "${email}"
			"${DECLARE_PID_FRAMEWORK_YEAR}" "${DECLARE_PID_FRAMEWORK_SITE}" "${DECLARE_PID_FRAMEWORK_LICENSE}"
			"${address}" "${DECLARE_PID_FRAMEWORK_PUBLIC_ADDRESS}" "${DECLARE_PID_FRAMEWORK_PROJECT}" "${DECLARE_PID_FRAMEWORK_DESCRIPTION}"
    "${DECLARE_PID_FRAMEWORK_WELCOME}" "${DECLARE_PID_FRAMEWORK_CONTRIBUTION_SPACE}")
unset(email)
if(DECLARE_PID_FRAMEWORK_LOGO)
	declare_Framework_Image(${DECLARE_PID_FRAMEWORK_LOGO} FALSE)
endif()
if(DECLARE_PID_FRAMEWORK_BANNER)
	declare_Framework_Image(${DECLARE_PID_FRAMEWORK_BANNER} TRUE)
endif()
if(DECLARE_PID_FRAMEWORK_CATEGORIES)
  foreach(cat IN LISTS DECLARE_PID_FRAMEWORK_CATEGORIES)
    add_PID_Framework_Category(${cat})
  endforeach()
endif()
endmacro(declare_PID_Framework)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Framework_Author| replace:: ``PID_Framework_Author``
#  .. _PID_Framework_Author:
#
#  PID_Framework_Author
#  --------------------
#
#   .. command:: PID_Framework_Author(AUTHOR ...[INSTITUTION ...])
#
#   .. command:: add_PID_Framework_Author(AUTHOR ...[INSTITUTION ...])
#
#      Add an author to the list of authors of the framework.
#
#     .. rubric:: Required parameters
#
#     :AUTHOR <name>: The name of the author.
#
#     .. rubric:: Optional parameters
#
#     :INSTITUTION <institutions>: Define the institution(s) to which the author belongs to.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root CMakeLists.txt file of the package, after declare_PID_Framework and before build_PID_Framework.
#
#     .. admonition:: Effects
#        :class: important
#
#         Add another author to the list of authors of the framework.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        PID_Framework_Author(AUTHOR Another Writter INSTITUTION LIRMM)
#
macro(PID_Framework_Author)
  add_PID_Framework_Author(${ARGN})
endmacro(PID_Framework_Author)

macro(add_PID_Framework_Author)
set(multiValueArgs AUTHOR INSTITUTION)
cmake_parse_arguments(ADD_PID_FRAMEWORK_AUTHOR "" "" "${multiValueArgs}" ${ARGN} )
if(NOT ADD_PID_FRAMEWORK_AUTHOR_AUTHOR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an author name must be given using AUTHOR keyword.")
endif()
add_Framework_Author("${ADD_PID_FRAMEWORK_AUTHOR_AUTHOR}" "${ADD_PID_FRAMEWORK_AUTHOR_INSTITUTION}")
endmacro(add_PID_Framework_Author)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Framework_Category| replace:: ``PID_Framework_Category``
#  .. _PID_Framework_Category:
#
#  PID_Framework_Category
#  ----------------------
#
#   .. command:: PID_Framework_Category(...)
#
#   .. command:: add_PID_Framework_Category(...)
#
#      Define a new category for classifying packages of the current framework.
#
#     .. rubric:: Required parameters
#
#     :<string>: specifies the category and (optionally) subcategories to which a package of the framework can belong to.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in the root CMakeLists.txt file of the package, after declare_PID_Framework and before build_PID_Framework.
#
#     .. admonition:: Effects
#        :class: important
#
#         Register a new category into the framework. This information will be added to the framework reference file when it is generated.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        PID_Framework_Category(programming/filesystem)
#
macro(PID_Framework_Category)
  add_PID_Framework_Category(${ARGN})
endmacro(PID_Framework_Category)

macro(add_PID_Framework_Category)
if(NOT ${ARGC} EQUAL 1)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the add_PID_Framework_Category command requires one string argument of the form <category>[/subcategory]*.")
endif()
add_Framework_Category("${ARGV0}")
endmacro(add_PID_Framework_Category)

#.rst:
#
# .. ifmode:: user
#
#  .. |build_PID_Framework| replace:: ``build_PID_Framework``
#  .. _build_PID_Framework:
#
#  build_PID_Framework
#  -------------------
#
#   .. command:: build_PID_Framework()
#
#       Configure PID framework according to previous information.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be the last one called in the root CMakeList.txt file of the framework.
#
#     .. admonition:: Effects
#        :class: important
#
#         This function launch the configuration of the framework build process.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        build_PID_Framework()
#
macro(build_PID_Framework)
if(${ARGC} GREATER 0)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the build_PID_Framework command requires no arguments.")
endif()
build_Framework()
endmacro(build_PID_Framework)
