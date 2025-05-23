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

cmake_minimum_required(VERSION 3.19.8)

# prevent CMake automatic detection messages from appearing
set(CMAKE_MESSAGE_LOG_LEVEL NOTICE CACHE INTERNAL "")

get_filename_component(abs_path_to_ws ${WORKSPACE_DIR} ABSOLUTE)
set(WORKSPACE_DIR ${abs_path_to_ws} CACHE PATH "" FORCE)
set(CMAKE_TOOLCHAIN_FILE ${WORKSPACE_DIR}/build/PID_Toolchain.cmake CACHE INTERNAL "" FORCE)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Wrapper_API_Internal_Functions NO_POLICY_SCOPE)
include(External_Definition NO_POLICY_SCOPE) #to be able to interpret content of external package description files
include(Package_Definition NO_POLICY_SCOPE) #to enable the use of get_PID_Platform_Info in find files
include(PID_Utils_Functions NO_POLICY_SCOPE)

include(CMakeParseArguments)

stop_Make_To_Print_Directories()

#########################################################################################
######################## API to be used in wrapper description ##########################
#########################################################################################

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Wrapper| replace:: ``PID_Wrapper``
#  .. _PID_Wrapper:
#
#  PID_Wrapper
#  -----------
#
#   .. command:: PID_Wrapper(AUTHOR ... YEAR ... LICENSE ... DESCRIPTION ... [OPTIONS])
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
#     :MAIL|EMAIL <e-mail>: E-mail of the reference author.
#
#     :ADDRESS <url>: The url of the wrapper's official repository. Must be set once the package is published.
#
#     :PUBLIC_ADDRESS <url>: Can be used to provide a public counterpart to the repository `ADDRESS`
#
#     :README <path relative to share folder>: Used to define a user-defined README file for the package.
#
#     :CONTRIBUTION_SPACE <name>: name of the contribution space to use.
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
#        PID_Wrapper(
#          AUTHOR Robin Passama
#          INSTITUTION LIRMM
#          YEAR 2013
#          LICENSE CeCILL-C
#          ADDRESS git@gite.lirmm.fr:passama/a-given-wrapper.git
#          DESCRIPTION "an example PID wrapper"
#        )
#

macro(PID_Wrapper)
  declare_PID_Wrapper(${ARGN})
endmacro(PID_Wrapper)

macro(declare_PID_Wrapper)
set(oneValueArgs LICENSE ADDRESS MAIL EMAIL PUBLIC_ADDRESS README CONTRIBUTION_SPACE)
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
if(DECLARE_PID_WRAPPER_MAIL)
  set(email ${DECLARE_PID_WRAPPER_MAIL})
elseif(DECLARE_PID_WRAPPER_EMAIL)
  set(email ${DECLARE_PID_WRAPPER_EMAIL})
endif()
declare_Wrapper(	"${DECLARE_PID_WRAPPER_AUTHOR}" "${DECLARE_PID_WRAPPER_INSTITUTION}" "${email}"
			"${DECLARE_PID_WRAPPER_YEAR}" "${DECLARE_PID_WRAPPER_LICENSE}"
			"${DECLARE_PID_WRAPPER_ADDRESS}" "${DECLARE_PID_WRAPPER_PUBLIC_ADDRESS}"
		"${DECLARE_PID_WRAPPER_DESCRIPTION}" "${DECLARE_PID_WRAPPER_README}" "${DECLARE_PID_WRAPPER_CONTRIBUTION_SPACE}")
unset(email)
endmacro(declare_PID_Wrapper)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Original_Project| replace:: ``PID_Original_Project``
#  .. _PID_Original_Project:
#
#  PID_Original_Project
#  --------------------
#
#   .. command:: PID_Original_Project(AUTHORS ... LICENSES ... URL ...)
#
#   .. command:: define_PID_Wrapper_Original_Project_Info(AUTHORS ... LICENSES ... URL ...)
#
#      Set the meta information about original project being wrapped by current project.
#
#     .. rubric:: Required parameters
#
#     :AUTHORS <string>: Defines who are the authors of the original project.
#
#     :LICENSES <string>: The licenses that applies to the original project content.
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
#      PID_Original_Project(
#         AUTHORS "Boost.org contributors"
#         LICENSES "Boost license"
#         URL http://www.boost.org)
#
#
macro(PID_Original_Project)
  define_PID_Wrapper_Original_Project_Info(${ARGN})
endmacro(PID_Original_Project)

macro(define_PID_Wrapper_Original_Project_Info)
	set(oneValueArgs URL)
	set(multiValueArgs AUTHORS LICENSES)
	cmake_parse_arguments(DEFINE_WRAPPED_PROJECT "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	if(NOT DEFINE_WRAPPED_PROJECT_AUTHORS)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, authors references must be given using AUTHOR keyword.")
	endif()
	if(NOT DEFINE_WRAPPED_PROJECT_LICENSES)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a license description must be given using LICENSE keyword.")
	endif()
	if(NOT DEFINE_WRAPPED_PROJECT_URL)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, The URL of the original project must be given using URL keyword.")
	endif()
	define_Wrapped_Project("${DEFINE_WRAPPED_PROJECT_AUTHORS}" "${DEFINE_WRAPPED_PROJECT_LICENSES}"  "${DEFINE_WRAPPED_PROJECT_URL}")
endmacro(define_PID_Wrapper_Original_Project_Info)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Wrapper_Author| replace:: ``PID_Wrapper_Author``
#  .. _PID_Wrapper_Author:
#
#  PID_Wrapper_Author
#  -------------------
#
#   .. command:: PID_Wrapper_Author(AUTHOR ... [INSTITUTION ...])
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
#        PID_Wrapper_Author(AUTHOR Another Writter INSTITUTION LIRMM)
#
#
macro(PID_Wrapper_Author)
  add_PID_Wrapper_Author(${ARGN})
endmacro(PID_Wrapper_Author)

macro(add_PID_Wrapper_Author)
set(multiValueArgs AUTHOR INSTITUTION)
cmake_parse_arguments(ADD_PID_WRAPPER_AUTHOR "" "" "${multiValueArgs}" ${ARGN} )
if(NOT ADD_PID_WRAPPER_AUTHOR_AUTHOR)
  if("${ARGV0}" STREQUAL "" OR "${ARGV0}" STREQUAL "INSTITUTION")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
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
#  .. |PID_Wrapper_Category| replace:: ``PID_Wrapper_Category``
#  .. _PID_Wrapper_Category:
#
#  PID_Wrapper_Category
#  --------------------
#
#   .. command:: PID_Wrapper_Category(...)
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
#        PID_Wrapper_Category(example/packaging)
#

macro(PID_Wrapper_Category)
  add_PID_Wrapper_Category(${ARGN})
endmacro(PID_Wrapper_Category)

macro(add_PID_Wrapper_Category)
if(NOT ${ARGC} EQUAL 1)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the add_PID_Wrapper_Category command requires one string argument of the form <category>[/subcategory]*.")
endif()
add_Category("${ARGV0}")
endmacro(add_PID_Wrapper_Category)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Wrapper_Option| replace:: ``PID_Wrapper_Option``
#  .. _PID_Wrapper_Option:
#
#  PID_Wrapper_Option
#  ------------------
#
#   .. command:: PID_Wrapper_Option(OPTION ... TYPE ... DEFAULT ... [DESCRIPTION ...])
#
#   .. command:: define_PID_Wrapper_User_Option(OPTION ... TYPE ... DEFAULT ... [DESCRIPTION ...])
#
#      Define an option to configure the build of the wrapped project.
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
#        PID_Wrapper_Option(OPTION BUILD_WITH_CUDA_SUPPORT
#          TYPE BOOL DEFAULT OFF
#          DESCRIPTION "set to ON to enable CUDA support during build")
#

macro(PID_Wrapper_Option)
  define_PID_Wrapper_User_Option(${ARGN})
endmacro(PID_Wrapper_Option)

macro(define_PID_Wrapper_User_Option)
set(oneValueArgs OPTION TYPE DESCRIPTION)
set(multiValueArgs DEFAULT)
cmake_parse_arguments(DEFINE_PID_WRAPPER_USER_OPTION "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DEFINE_PID_WRAPPER_USER_OPTION_OPTION)
  if("${ARGV0}" STREQUAL "" OR "${ARGV0}" MATCHES "^TYPE|DESCRIPTION|DEFAULT$")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an option name must be given using OPTION keyword.")
  endif()
  set(option_name "${ARGV0}")
else()
  set(option_name "${DEFINE_PID_WRAPPER_USER_OPTION_OPTION}")
endif()

if(NOT DEFINE_PID_WRAPPER_USER_OPTION_TYPE)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the type of the option must be given using TYPE keyword. Choose amon followiung value: FILEPATH (File chooser dialog), PATH (Directory chooser dialog), STRING (Arbitrary string), BOOL.")
endif()
set_Wrapper_Option("${option_name}" "${DEFINE_PID_WRAPPER_USER_OPTION_TYPE}" "${DEFINE_PID_WRAPPER_USER_OPTION_DEFAULT}" "${DEFINE_PID_WRAPPER_USER_OPTION_DESCRIPTION}")
endmacro(define_PID_Wrapper_User_Option)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Wrapper_Publishing| replace:: ``PID_Wrapper_Publishing``
#  .. _PID_Wrapper_Publishing:
#
#  PID_Wrapper_Publishing
#  ----------------------
#
#   .. command:: PID_Wrapper_Publishing(PROJECT ... GIT|FRAMEWORK ... [OPTIONS])
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
#     :CATEGORIES <list>: list of categories the package belongs to into the framework
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
#        PID_Wrapper_Publishing(
#          PROJECT https://gite.lirmm.fr/pid/boost
#          FRAMEWORK pid
#          DESCRIPTION boost is a PID wrapper for external project called Boost. Boost provides many libraries and templates to ease development in C++.
#          PUBLISH_BINARIES
#          ALLOWED_PLATFORMS x86_64_linux_stdc++11__ub20_gcc9__)
#

macro(PID_Wrapper_Publishing)
  declare_PID_Wrapper_Publishing(${ARGN})
endmacro(PID_Wrapper_Publishing)

macro(declare_PID_Wrapper_Publishing)
set(optionArgs PUBLISH_BINARIES)
set(oneValueArgs PROJECT FRAMEWORK GIT PAGE REGISTRY)
set(multiValueArgs DESCRIPTION ALLOWED_PLATFORMS CATEGORIES)
cmake_parse_arguments(DECLARE_PID_WRAPPER_PUBLISHING "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	#manage configuration of CI
if(DECLARE_PID_WRAPPER_PUBLISHING_ALLOWED_PLATFORMS)
	foreach(platform IN LISTS DECLARE_PID_WRAPPER_PUBLISHING_ALLOWED_PLATFORMS)
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

if(DECLARE_PID_WRAPPER_PUBLISHING_FRAMEWORK)
	if(NOT DECLARE_PID_WRAPPER_PUBLISHING_PROJECT)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell where to find the project page of the official package repository using PROJECT keyword.")
	endif()
	if(${PROJECT_NAME}_FRAMEWORK)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR: a framework (${${PROJECT_NAME}_FRAMEWORK}) has already been defined, cannot define a new one !")
		return()
	elseif(${PROJECT_NAME}_SITE_GIT_ADDRESS)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR: a static site (${${PROJECT_NAME}_SITE_GIT_ADDRESS}) has already been defined, cannot define a framework !")
		return()
	endif()
	init_Documentation_Info_Cache_Variables("${DECLARE_PID_WRAPPER_PUBLISHING_FRAMEWORK}" "${DECLARE_PID_WRAPPER_PUBLISHING_PROJECT}" "" "" "${DECLARE_PID_WRAPPER_PUBLISHING_DESCRIPTION}")
	set(PUBLISH_DOC TRUE)
  if(DECLARE_PID_WRAPPER_PUBLISHING_CATEGORIES)
    foreach(category IN LISTS DECLARE_PID_WRAPPER_PUBLISHING_CATEGORIES)
      PID_Wrapper_Category(${category})
    endforeach()
  endif()
elseif(DECLARE_PID_WRAPPER_PUBLISHING_GIT)
	if(NOT DECLARE_PID_WRAPPER_PUBLISHING_PROJECT)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell where to find the project page of the official package repository using PROJECT keyword.")
	endif()
	if(NOT DECLARE_PID_WRAPPER_PUBLISHING_PAGE)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell where to find the index page for the static site of the package (using PAGE keyword).")
	endif()
	if(${PROJECT_NAME}_FRAMEWORK)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR: a framework (${${PROJECT_NAME}_FRAMEWORK}) has already been defined, cannot define a static site !")
		return()
	elseif(${PROJECT_NAME}_SITE_GIT_ADDRESS)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
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
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Publishing, you cannot publish binaries of the project (using PUBLISH_BINARIES) if you do not publish package ${PROJECT_NAME} using a static site (either use FRAMEWORK or SITE keywords).")
  elseif(NOT ${PROJECT_NAME}_FRAMEWORK)
    #not published in a framework -> need to ensure a registry is defined
    if(NOT DECLARE_PID_WRAPPER_PUBLISHING_REGISTRY)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Publishing, you cannot publish binaries of the project (using PUBLISH_BINARIES) outside of a framework if you do not define a registry for binaries (use REGISTRY keyword).")
    endif()
  else()#defined into a framework
    if(DECLARE_PID_WRAPPER_PUBLISHING_REGISTRY)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Publishing, you cannot publish binaries of the project (using PUBLISH_BINARIES) into a framework if you define a package specific registry for ${PROJECT_NAME} binaries (do not use REGISTRY keyword).")
    endif()
  endif()
  if(NOT DO_CI)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in package ${PROJECT_NAME} bad arguments when calling PID_Publishing, you cannot publish binaries of the project (using PUBLISH_BINARIES) if you do not allow any CI process for package ${PROJECT_NAME} (use ALLOWED_PLATFORMS to defines which platforms will be used in CI process).")
  endif()
  
  publish_Binaries(TRUE "${DECLARE_PID_PUBLISHING_REGISTRY}")
else()
  publish_Binaries(FALSE "")
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
#  -----------------
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
  create_Shell_Script_Symlinks()
  if(${ARGC} GREATER 0)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
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
#  .. |PID_Wrapper_Version| replace:: ``PID_Wrapper_Version``
#  .. _PID_Wrapper_Version:
#
#  PID_Wrapper_Version
#  -------------------
#
#   .. command:: PID_Wrapper_Version(VERSION ... DEPLOY ... [OPTIONS])
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
#     :PREUSE <path to use script>: This is the path, relative to the current folder, to the install script that will be run anytime a package uses this version.
#     :COMPATIBILITY <version number>: define which previous version is compatible with this current version, if any. Compatible simply means that this current version can be used instead of the previous one without any restriction.
#     :SONAME <version number>: (useful on UNIX only) Specify which soname will be given by default to all shared libraries defined by the wrapper.
#     :CMAKE_FOLDER <path to folder>: (useful on CMake projects only) Specify the path, relative to the package install root, where to fond CMake configuration files.
#     :PKGCONFIG_FOLDER <path to folder>: (useful for projects supporting pkg-config only) Specify the path, relative to the package install root, where to find pkg-config configuration files.
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
#        PID_Wrapper_Version(VERSION 1.55.0 DEPLOY deploy.cmake
#            SONAME 1.55.0 #define the extension name to use for shared objects
#        )
#

macro(PID_Wrapper_Version)
  add_PID_Wrapper_Known_Version(${ARGN})
endmacro(PID_Wrapper_Version)

macro(add_PID_Wrapper_Known_Version)
set(optionArgs)
set(oneValueArgs VERSION DEPLOY COMPATIBILITY SONAME POSTINSTALL PREUSE CMAKE_FOLDER PKGCONFIG_FOLDER)
set(multiValueArgs)
cmake_parse_arguments(ADD_PID_WRAPPER_KNOWN_VERSION "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT ADD_PID_WRAPPER_KNOWN_VERSION_VERSION)
  if("${ARGV0}" STREQUAL "" OR "${ARGV0}" MATCHES "^DEPLOY|COMPATIBILITY|SONAME|POSTINSTALL|PREUSE$")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must define the version number using the VERSION keyword.")
  endif()
  set(version ${ARGV0})
else()
  set(version ${ADD_PID_WRAPPER_KNOWN_VERSION_VERSION})
endif()
if(NOT ADD_PID_WRAPPER_KNOWN_VERSION_DEPLOY)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must define the build script to use using the DEPLOY keyword.")
endif()

#verify the version information
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${version} OR NOT IS_DIRECTORY ${CMAKE_SOURCE_DIR}/src/${version})
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, no folder \"${version}\" can be found in src folder !")
	return()
endif()
list(FIND ${PROJECT_NAME}_KNOWN_VERSIONS ${version} INDEX)
if(NOT INDEX EQUAL -1)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, version \"${version}\" is already registered !")
	return()
endif()
#verify the script information
set(script_file ${ADD_PID_WRAPPER_KNOWN_VERSION_DEPLOY})
get_filename_component(RES_EXTENSION ${script_file} EXT)
if(NOT RES_EXTENSION MATCHES ".*\\.cmake$")
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, type of script file ${script_file} cannot be deduced from its extension only .cmake extensions supported")
	return()
endif()

if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${version}/${script_file})
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : cannot find script file ${script_file} in folder src/${version}/.")
	return()
endif()

#manage post install script
set(post_install_script)
if(ADD_PID_WRAPPER_KNOWN_VERSION_POSTINSTALL)
	set(post_install_script ${ADD_PID_WRAPPER_KNOWN_VERSION_POSTINSTALL})
	get_filename_component(RES_EXTENSION ${post_install_script} EXT)
	if(NOT RES_EXTENSION MATCHES ".*\\.cmake$")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, type of script file ${post_install_script} cannot be deduced from its extension. Only .cmake extensions supported")
		return()
	endif()
	if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${version}/${post_install_script})
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : cannot find post install script file ${post_install_script} in folder src/${version}/.")
		return()
	endif()
endif()

#manage pre use script
set(pre_use_script)
if(ADD_PID_WRAPPER_KNOWN_VERSION_PREUSE)
	set(pre_use_script ${ADD_PID_WRAPPER_KNOWN_VERSION_PREUSE})
	get_filename_component(RES_EXTENSION ${pre_use_script} EXT)
	if(NOT RES_EXTENSION MATCHES ".*\\.cmake$")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, type of script file ${pre_use_script} cannot be deduced from its extension. Only .cmake extensions supported")
	endif()
	if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${version}/${pre_use_script})
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : cannot find post install script file ${pre_use_script} in folder src/${version}/.")
	endif()
endif()


if(ADD_PID_WRAPPER_KNOWN_VERSION_COMPATIBILITY)
	set(compatible_with_version ${ADD_PID_WRAPPER_KNOWN_VERSION_COMPATIBILITY})
  if(version VERSION_LESS_EQUAL ${compatible_with_version})
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : when defining ${PROJECT_NAME} version ${version}, invalid compatible version ${compatible_with_version} (must be < ${version}).")
  endif()
endif()

add_Known_Version("${version}" "${script_file}" "${compatible_with_version}" "${ADD_PID_WRAPPER_KNOWN_VERSION_SONAME}" "${post_install_script}" "${pre_use_script}" "${ADD_PID_WRAPPER_KNOWN_VERSION_CMAKE_FOLDER}" "${ADD_PID_WRAPPER_KNOWN_VERSION_PKGCONFIG_FOLDER}")
endmacro(add_PID_Wrapper_Known_Version)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Wrapper_Environment| replace:: ``PID_Wrapper_Environment``
#  .. _PID_Wrapper_Environment:
#
#  PID_Wrapper_Environment
#  -----------------------
#
#   .. command:: PID_Wrapper_Environment(...)
#
#   .. command:: declare_PID_Wrapper_Environment(... )
#
#      Declare a configuration constraint on the build environment for the current version of the external project being described.
#
#     .. rubric:: Required parameters
#
#     :OPTIONAL: if used then the requirement on build environment is optional.
#     :LANGUAGE ...: Set of constraint check expressions defining which languages must/can be used (testing only C and C++ is not necessary).
#     :TOOLSET ...: Set of constraint check expressions defining which toolset must/can be used for target language. If many languages are specified then there must have as many toolsets defined, in same order.
#     :TOOL ...: Set of constraint check expressions defining which tools (compiler, interpreter, generators, etc.) must/can be used.
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
#        PID_Wrapper_Environment(LANGUAGE CUDA)
#
macro(PID_Wrapper_Environment)
  declare_PID_Wrapper_Environment(${ARGN})
endmacro(PID_Wrapper_Environment)

macro(declare_PID_Wrapper_Environment)
set(options OPTIONAL)
set(mono_value_args)
set(multiValueArgs TOOL LANGUAGE TOOLSET)
cmake_parse_arguments(DECLARE_PID_WRAPPER_ENVIRONMENT "${options}" "${mono_value_args}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_ENVIRONMENT_TOOL AND NOT DECLARE_PID_WRAPPER_ENVIRONMENT_LANGUAGE)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in ${PROJECT_NAME} bad arguments when calling PID_Wrapper_Environment, a tool (using TOOL keyword) or a constraint on language in use (using LANGUAGE ketword) MUST be defined.")
	return()
endif()
if(DECLARE_PID_WRAPPER_ENVIRONMENT_TOOLSET)
  if(NOT DECLARE_PID_WRAPPER_ENVIRONMENT_LANGUAGE)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR :  in ${PROJECT_NAME} bad arguments when calling PID_Wrapper_Environment, the LANGUAGE (using LANGUAGE) MUST be defined when a specific toolset is wanted (using TOOLSET argument).")
  endif()
  list(LENGTH CHECK_PID_ENV_TOOLSET SIZE_TOOLSETS)
  list(LENGTH CHECK_PID_ENV_LANGUAGE SIZE_LANGUAGES)
  if(NOT SIZE_TOOLSETS EQUAL SIZE_LANGUAGES)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in ${PROJECT_NAME} when calling PID_Wrapper_Environment, there is not as many toolsets (${SIZE_TOOLSETS}) as languages defined (${SIZE_LANGUAGES}).")
  endif()
endif()
if(DECLARE_PID_WRAPPER_ENVIRONMENT_OPTIONAL)
  set(optional TRUE)
else()
  set(optional FALSE)
endif()
declare_Wrapped_Environment_Configuration(DO_EXIT "${DECLARE_PID_WRAPPER_ENVIRONMENT_LANGUAGE}" "${DECLARE_PID_WRAPPER_ENVIRONMENT_TOOLSET}" "${DECLARE_PID_WRAPPER_ENVIRONMENT_TOOL}" "${optional}")
if(DO_EXIT)
  unset(DO_EXIT)
  declare_Current_Version_Unavailable()
  return()
endif()
unset(DO_EXIT)
unset(optional)#avoid propagating this variable to other functions
endmacro(declare_PID_Wrapper_Environment)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Wrapper_Configuration| replace:: ``PID_Wrapper_Configuration``
#  .. _PID_Wrapper_Configuration:
#
#  PID_Wrapper_Configuration
#  -------------------------
#
#   .. command:: PID_Wrapper_Configuration(REQUIRED|OPTIONAL ... [PLATFORM ...])
#
#   .. command:: declare_PID_Wrapper_Platform_Configuration(CONFIGURATION ... [PLATFORM ...])
#
#      Declare a platform configuration constraint for the current version of the external project being described.
#
#     .. rubric:: Required parameters
#
#     :REQUIRED|CONFIGURATION <list of configurations>: list of configuration expression defining the required target platform configurations.
#     :OPTIONAL <list of configurations>: list of configuration expression defining the required target platform configurations.
#
#     .. rubric:: Optional parameters
#
#     :PLATFORM <list of platform or OS name>: Used to apply the configuration constraints only to the target platform (e.g. x86_64_linux_stdc++11) or operating system (e.g. linux).
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
#        PID_Wrapper_Configuration(REQUIRED posix)
#
macro(PID_Wrapper_Configuration)
  declare_PID_Wrapper_Platform_Configuration(${ARGN})
endmacro(PID_Wrapper_Configuration)

macro(declare_PID_Wrapper_Platform_Configuration)
set(options)
set(oneValueArgs)
set(multiValueArgs PLATFORM CONFIGURATION OPTIONAL REQUIRED)
cmake_parse_arguments(DECLARE_PID_WRAPPER_PLATFORM "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_PLATFORM_CONFIGURATION AND NOT DECLARE_PID_WRAPPER_PLATFORM_REQUIRED AND NOT DECLARE_PID_WRAPPER_PLATFORM_OPTIONAL)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in ${PROJECT_NAME} bad arguments when calling PID_Wrapper_Configuration, use either REQUIRED or OPTIONAL keyword is mandatory.")
	return()
endif()
if(DECLARE_PID_WRAPPER_PLATFORM_CONFIGURATION AND DECLARE_PID_WRAPPER_PLATFORM_REQUIRED)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in ${PROJECT_NAME} bad arguments when calling PID_Wrapper_Configuration, use either REQUIRED or CONFIGURATION keyword to specify the required platform configurations, but not both of them. Use of CONFIGURATION is deprecated, prefer using REQUIRED.")
	return()
endif()
#Note: CONFIGURATION is kept for backward compatibility
set(required ${DECLARE_PID_WRAPPER_PLATFORM_CONFIGURATION} ${DECLARE_PID_WRAPPER_PLATFORM_REQUIRED})
declare_Wrapped_Platform_Configuration(DO_EXIT "${DECLARE_PID_WRAPPER_PLATFORM_PLATFORM}" "${required}" "${DECLARE_PID_WRAPPER_PLATFORM_OPTIONAL}")
unset(required)
if(DO_EXIT)
  unset(DO_EXIT)
  declare_Current_Version_Unavailable()
  return()
endif()
unset(DO_EXIT)
endmacro(declare_PID_Wrapper_Platform_Configuration)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Wrapper_Dependency| replace:: ``PID_Wrapper_Dependency``
#  .. _PID_Wrapper_Dependency:
#
#  PID_Wrapper_Dependency
#  ----------------------
#
#   .. command:: PID_Wrapper_Dependency([PACKAGE] ... [[EXACT] VERSION ...]...)
#
#   .. command:: declare_PID_Wrapper_External_Dependency([PACKAGE] ... [[EXACT] VERSION ...]...)
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
#        PID_Wrapper_Dependency (PACKAGE boost EXACT VERSION 1.55.0 EXACT VERSION 1.63.0 EXACT VERSION 1.64.0)
#
macro(PID_Wrapper_Dependency)
  declare_PID_Wrapper_External_Dependency(${ARGN})
endmacro(PID_Wrapper_Dependency)

macro(declare_PID_Wrapper_External_Dependency)
set(options OPTIONAL)
set(oneValueArgs PACKAGE)
set(multiValueArgs) #known versions of the external package that can be used to build/run it
cmake_parse_arguments(DECLARE_PID_WRAPPER_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_DEPENDENCY_PACKAGE)
  if("${ARGV0}" STREQUAL "" OR "${ARGV0}" MATCHES "^EXACT|VERSION|OPTIONAL$")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : in ${PROJECT_NAME} bad arguments when calling PID_Wrapper_Dependency, name of the dependency must be defined using PACKAGE keyword.")
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
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : in ${PROJECT_NAME} bad arguments when calling PID_Wrapper_Dependency, package ${package_name} cannot require itself !")
	return()
endif()
set(list_of_versions)
set(exact_versions)
set(REMAINING_TO_PARSE)
if(DECLARE_PID_WRAPPER_DEPENDENCY_UNPARSED_ARGUMENTS)#there are still arguments to parse
  parse_Package_Dependency_All_Version_Arguments(${package_name} DECLARE_PID_WRAPPER_DEPENDENCY_UNPARSED_ARGUMENTS list_of_versions exact_versions REMAINING_TO_PARSE PARSE_RESULT)
  if(NOT PARSE_RESULT)#error during parsing process
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in ${PROJECT_NAME} bad arguments when calling PID_Wrapper_Dependency, dependency ${package_name} has bad specification of versions constraints, see previous messages.")
  endif()
endif()
set(list_of_components)
if(REMAINING_TO_PARSE) #there are still expression to parse
	set(oneValueArgs)
	set(options)
	set(multiValueArgs COMPONENTS)
	cmake_parse_arguments(DECLARE_PID_WRAPPER_DEPENDENCY_MORE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${REMAINING_TO_PARSE})
	if(DECLARE_PID_WRAPPER_DEPENDENCY_MORE_COMPONENTS)
		list(LENGTH DECLARE_PID_WRAPPER_DEPENDENCY_MORE_COMPONENTS SIZE)
		if(SIZE LESS 1)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
			message(FATAL_ERROR "[PID] CRITICAL ERROR : in ${PROJECT_NAME} bad arguments when calling PID_Wrapper_Dependency (for dependency ${package_name}), at least one component dependency must be defined when using the COMPONENTS keyword.")
			return()
		endif()
		set(list_of_components ${DECLARE_PID_WRAPPER_DEPENDENCY_MORE_COMPONENTS})
	else()
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] WARNING : in ${PROJECT_NAME} bad arguments when calling PID_Wrapper_Dependency, unknown arguments used ${DECLARE_PID_WRAPPER_DEPENDENCY_MORE_UNPARSED_ARGUMENTS}.")
	endif()
endif()

declare_Wrapped_External_Dependency(DO_EXIT "${package_name}" "${DECLARE_PID_WRAPPER_DEPENDENCY_OPTIONAL}" "${list_of_versions}" "${exact_versions}" "${list_of_components}")
if(DO_EXIT)
  unset(DO_EXIT)
  declare_Current_Version_Unavailable()
  return()
endif()
#avoid propagating variables to other functions
unset(list_of_components)
unset(list_of_versions)
unset(exact_versions)
endmacro(declare_PID_Wrapper_External_Dependency)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Wrapper_Component| replace:: ``PID_Wrapper_Component``
#  .. _PID_Wrapper_Component:
#
#  PID_Wrapper_Component
#  ---------------------
#
#   .. command:: PID_Wrapper_Component([COMPONENT] ... [OPTIONS])
#
#   .. command:: declare_PID_Wrapper_Component([COMPONENT] ... [OPTIONS])
#
#     Declare a new component for the current version of the external package.
#
#     .. rubric:: Required parameters
#
#     :[COMPONENT] <string w/o withespaces>: defines the unique identifier of the component. The COMPONENT keyword may be omnitted if name if the first argument.
#
#     .. rubric:: Optional parameters
#
#     :C_STANDARD <number of standard>: version of the C language standard to be used to build this component. The values may be 90, 99 or 11.
#     :C_MAX_STANDARD <number of standard>: max version of the C language standard allowed when using this component.
#     :CXX_STANDARD <number of standard>: version of the C++ language standard to be used to build this component. The values may be 98, 11, 14 or 17. If not specified the version 98 is used.
#     :CXX_MAX_STANDARD <number of standard>: max version of the C++ language standard to be used to build this component. If not specified the version 98 is used.
#     :SONAME <version number>: allows to set the SONAME to use for that specific library instead of the default one.
#     :DEFINITIONS <defs>: preprocessor definitions used in the component’s interface.
#     :INCLUDES <folders>: include folders to pass to any component using the current component. Path are interpreted relative to the installed external package version root folder.
#     :SHARED_LINKS <links>: shared link flags. Path are interpreted relative to the installed external package version root folder.
#     :DEBUG_SUFFIX suffix: Suffix to add to libraries binaries names when built in Debug mode.
#     :FORCED_SHARED_LINKS <links>: shared links whose binary is forced to be linked into dependent binaries (see -Wl,no-as-needed)
#     :STATIC_LINKS <links>: static link flags. Path are interpreted relative to the installed external package version root folder.
#     :OPTIONS <compile options>: compiler options to be used whenever a third party code use this component. This should be used only for options bound to compiler usage, not definitions or include directories.
#     :RUNTIME_RESOURCES <list of path>: list of path relative to the installed external package version root folder.
#     :EXPORT ...: list of components that are exported by the declared component. Each element has the pattern [<package name>/]<component_name>.
#     :DEPEND ...: list of components that the declared component depends on. Each element has the pattern [<package name>/]<component_name>.
#     :ALIAS ...: list of alias for naming the component.
#     :PYTHON ...: list of files and/or folder that define a python package. Used to define python bindings.
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
#        PID_Wrapper_Component(COMPONENT libyaml INCLUDES include SHARED_LINKS ${posix_LINK_OPTIONS} lib/libyaml-cpp)
#
macro(PID_Wrapper_Component)
  declare_PID_Wrapper_Component(${ARGN})
endmacro(PID_Wrapper_Component)

macro(declare_PID_Wrapper_Component)
set(oneValueArgs COMPONENT C_STANDARD C_MAX_STANDARD CXX_STANDARD CXX_MAX_STANDARD STANDARD SONAME DEBUG_SUFFIX)
set(multiValueArgs INCLUDES SHARED_LINKS STATIC_LINKS FORCED_SHARED_LINKS DEFINITIONS OPTIONS RUNTIME_RESOURCES EXPORT DEPEND ALIAS PYTHON) #known versions of the external package that can be used to build/run it
cmake_parse_arguments(DECLARE_PID_WRAPPER_COMPONENT "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_COMPONENT_COMPONENT)
  if("${ARGV0}" STREQUAL "" OR "${ARGV0}" MATCHES "^CXX_STANDARD|CXX_MAX_STANDARD|C_STANDARD|C_MAX_STANDARD|SONAME|INCLUDES|SHARED_LINKS|STATIC_LINKS|DEFINITIONS|OPTIONS|RUNTIME_RESOURCES$")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
  	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, declare_PID_Wrapper_Component requires to define the name of the component by using COMPONENT keyword.")
  	return()
  endif()
  set(component_name ${ARGV0})
else()
  set(component_name ${DECLARE_PID_WRAPPER_COMPONENT_COMPONENT})
endif()
set(fake_intern_opts)
adjust_Languages_Standards_Description(ERR MESS C_STD_USED CXX_STD_USED INTERN_OPTS EXPORT_OPTS
                                      fake_intern_opts DECLARE_PID_WRAPPER_COMPONENT_OPTIONS
                                      "${DECLARE_PID_WRAPPER_COMPONENT_C_STANDARD}"
                                      "${DECLARE_PID_WRAPPER_COMPONENT_C_MAX_STANDARD}"
                                      "${DECLARE_PID_WRAPPER_COMPONENT_CXX_STANDARD}"
                                      "${DECLARE_PID_WRAPPER_COMPONENT_CXX_MAX_STANDARD}")
if(ERR)
  if(ERR STREQUAL "CRITICAL")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR: when declaring component ${component_name} in wrapper ${PROJECT_NAME}, ${MESS}")
  else()
    message("[PID] WARNING: when declaring component ${component_name} in wrapper ${PROJECT_NAME}, ${MESS}")
  endif()
endif()
declare_Wrapped_Component(${component_name}
  "${DECLARE_PID_WRAPPER_COMPONENT_FORCED_SHARED_LINKS}"
  "${DECLARE_PID_WRAPPER_COMPONENT_SHARED_LINKS}"
  "${DECLARE_PID_WRAPPER_COMPONENT_SONAME}"
	"${DECLARE_PID_WRAPPER_COMPONENT_STATIC_LINKS}"
	"${DECLARE_PID_WRAPPER_COMPONENT_INCLUDES}"
	"${DECLARE_PID_WRAPPER_COMPONENT_DEFINITIONS}"
	"${EXPORT_OPTS}"
	"${C_STD_USED}"
	"${DECLARE_PID_WRAPPER_COMPONENT_C_MAX_STANDARD}"
	"${CXX_STD_USED}"
	"${DECLARE_PID_WRAPPER_COMPONENT_CXX_MAX_STANDARD}"
	"${DECLARE_PID_WRAPPER_COMPONENT_RUNTIME_RESOURCES}"
	"${DECLARE_PID_WRAPPER_COMPONENT_ALIAS}"
  "${DECLARE_PID_WRAPPER_COMPONENT_PYTHON}"
  "${DECLARE_PID_WRAPPER_COMPONENT_DEBUG_SUFFIX}")


#dealing with dependencies
if(DECLARE_PID_WRAPPER_COMPONENT_EXPORT)#exported dependencies
  foreach(dep IN LISTS DECLARE_PID_WRAPPER_COMPONENT_EXPORT)
    if(dep STREQUAL component_name)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR: when declaring component ${component_name} in wrapper ${PROJECT_NAME}, the component declare itself as a dependency !")
    endif()
    extract_Component_And_Package_From_Dependency_String(RES_COMP RES_PACK ${dep})
    if(RES_PACK)
      set(COMP_ARGS "${RES_COMP};PACKAGE;${RES_PACK}")
    elseif(${RES_COMP}_AVAILABLE)#transform the component dependency into a configuration dependency
      set(COMP_ARGS "CONFIGURATION;${RES_COMP}")
    else()
      set(COMP_ARGS ${RES_COMP})
    endif()
    declare_PID_Wrapper_Component_Dependency(COMPONENT ${component_name} EXPORT ${COMP_ARGS})
  endforeach()
endif()

if(DECLARE_PID_WRAPPER_COMPONENT_DEPEND)#non exported dependencies
  foreach(dep IN LISTS DECLARE_PID_WRAPPER_COMPONENT_DEPEND)
    if(dep STREQUAL component_name)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR: when declaring component ${component_name} in wrapper ${PROJECT_NAME}, the component declare itself as a dependency !")
    endif()
    extract_Component_And_Package_From_Dependency_String(RES_COMP RES_PACK ${dep})
    if(RES_PACK)
      set(COMP_ARGS "${RES_COMP};PACKAGE;${RES_PACK}")
    elseif(${RES_COMP}_AVAILABLE)#transform the component dependency into a configuration dependency
      set(COMP_ARGS "CONFIGURATION;${RES_COMP}")
    else()
      set(COMP_ARGS ${RES_COMP})
    endif()
    declare_PID_Wrapper_Component_Dependency(COMPONENT ${component_name} DEPEND ${COMP_ARGS})
    endforeach()
endif()

endmacro(declare_PID_Wrapper_Component)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Wrapper_Component_Dependency| replace:: ``PID_Wrapper_Component_Dependency``
#  .. _PID_Wrapper_Component_Dependency:
#
#  PID_Wrapper_Component_Dependency
#  --------------------------------
#
#   .. command:: PID_Wrapper_Component_Dependency([COMPONENT] ... [OPTIONS])
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
#     :DEPEND: Tells whether the component depends on but do not export the required dependency. Exporting means that the reference to the dependency is contained in its interface (header files).
#
#     :[EXTERNAL] <dependency>: This is the name of the component whose component <name> depends on. EXTERNAL keyword may be omitted if EXPORT or DEPEND keyword are used.
#
#     :PACKAGE <name>: This is the name of the external package the dependency belongs to. This package must have been defined has a package dependency before this call. If this argument is not used, the dependency belongs to the current package (i.e. internal dependency).
#
#     :DEFINITIONS <definitions>:  List of definitions exported by the component. These definitions are supposed to be managed in the dependency's heaedr files, but are set by current component.
#
#     :INCLUDES <list of path>:  List of path to system include folders.
#
#     :LIBRARY_DIRS  <list of path>:   List of path to system libraries folders.
#
#     :SHARED_LINKS <list of link>:  List of shared system links.
#
#     :STATIC_LINKS  <list of link>:  List of static system links.
#
#     :OPTIONS  <list of options>:  List of compiler options to use when using a system library.
#
#     :RUNTIME_RESOURCES  <list of path>:  List of path to system runtime resource such as program for instance.
#
#     :C_STANDARD  <std number>: the C standard used by the dependency.
#
#     :CXX_STANDARD  <std number>: the C++ standard used by the dependency.
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
#        PID_Wrapper_Component_Dependency(COMPONENT libyaml EXPORT EXTERNAL boost-headers PACKAGE boost)
#
macro(PID_Wrapper_Component_Dependency)
  declare_PID_Wrapper_Component_Dependency(${ARGN})
endmacro(PID_Wrapper_Component_Dependency)

macro(declare_PID_Wrapper_Component_Dependency)
set(target_component)
set(component_name)
set(options EXPORT DEPEND)
set(oneValueArgs COMPONENT EXTERNAL PACKAGE C_STANDARD C_MAX_STANDARD CXX_STANDARD CXX_MAX_STANDARD CONFIGURATION)
set(multiValueArgs INCLUDES LIBRARY_DIRS SHARED_LINKS STATIC_LINKS DEFINITIONS OPTIONS RUNTIME_RESOURCES)
cmake_parse_arguments(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_COMPONENT)
  if(${ARGC} LESS 1 OR ${ARGV0} MATCHES "^EXPORT|DEPEND|EXTERNAL|PACKAGE|INCLUDES|LIBRARY_DIRS|SHARED_LINKS|STATIC_LINKS|DEFINITIONS|OPTIONS|C_STANDARD|CXX_STANDARD|RUNTIME_RESOURCES$")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, PID_Wrapper_Component_Dependency requires to define the name of the declared component using the COMPONENT keyword or by giving the name as first argument.")
    return()
  endif()
  set(component_name ${ARGV0})
  if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS)
    list(REMOVE_ITEM DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS ${ARGV0})
  endif()
else()
  set(component_name ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_COMPONENT})
endif()

if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXPORT AND DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEPEND)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
  message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling PID_Wrapper_Component_Dependency, EXPORT and DEPEND keywords cannot be used in same time.")
  return()
endif()

if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXPORT)
	set(exported TRUE)
else()
	set(exported FALSE)
endif()

if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE) #this is a dependency to another external package
	list(FIND ${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCIES ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE} INDEX)
	if(INDEX EQUAL -1)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
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
      AND (DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXPORT OR DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEPEND))

      list(GET DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS 0 target_component)
      declare_Wrapped_Component_Dependency_To_Explicit_Component(${component_name}
  			${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE}
  			${target_component}
  			${exported}
  			"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEFINITIONS}"
  		)
    else()
      set(fake_intern_opts)
      adjust_Languages_Standards_Description(ERR MESS C_STD_USED CXX_STD_USED INTERN_OPTS EXPORT_OPTS
                                            fake_intern_opts DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_OPTIONS
                                            "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_C_STANDARD}"
                                            "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_C_MAX_STANDARD}"
                                            "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_CXX_STANDARD}"
                                            "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_CXX_MAX_STANDARD}")
      if(ERR)
        if(ERR STREQUAL "CRITICAL")
          finish_Progress(${GLOBAL_PROGRESS_VAR})
          message(FATAL_ERROR "[PID] CRITICAL ERROR: when declaring implicit dependency to package ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE} for component ${component_name} in wrapper ${PROJECT_NAME}, ${MESS}")
        else()
          message("[PID] WARNING: when declaring implicit dependency to package ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE} for component ${component_name} in wrapper ${PROJECT_NAME}, ${MESS}")
        endif()
      endif()
      declare_Wrapped_Component_Dependency_To_Implicit_Components(${component_name}
        ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_PACKAGE} #everything exported by default
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_INCLUDES}"
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_SHARED_LINKS}"
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_STATIC_LINKS}"
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEFINITIONS}"
        "${EXPORT_OPTS}"
  			"${C_STD_USED}"
  			"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_C_MAX_STANDARD}"
  			"${CXX_STD_USED}"
  			"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_CXX_MAX_STANDARD}"
  			"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_RUNTIME_RESOURCES}"
      )
    endif()
	endif()
else()#this is a dependency to another component defined in the same external package OR a dependency to system libraries
	if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXTERNAL) #if the signature contains EXTERNAL
    set(target_component ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXTERNAL})
  else()
    if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS
      AND (DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXPORT OR DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEPEND))

      list(GET DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS 0 target_component)
    elseif(NOT DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_EXPORT AND NOT DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEPEND)
      #OK export or depends on nothing and no other info can help decide what the user wants
      finish_Progress(${GLOBAL_PROGRESS_VAR})
  		message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling declare_PID_Wrapper_Component_Dependency, need to define the component used by ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_COMPONENT}, by using the keyword EXTERNAL.")
  		return()
    endif()
	endif()
  if(target_component)
    if(target_component STREQUAL component_name)
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR: when declaring dependency to component ${component_name} in wrapper ${PROJECT_NAME}, the component declare itself as a dependency !")
    endif()

  	declare_Wrapped_Component_Internal_Dependency(${component_name}
  		${target_component}
  		${exported}
  		"${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEFINITIONS}"
  	)
  else()#no target component defined => it is a system dependency
    if(DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_CONFIGURATION)
      set(config ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_CONFIGURATION})
      get_All_Configuration_Visible_Build_Variables(LINK_OPTS COMPILE_OPTS INC_DIRS LIB_DIRS DEFS RPATH ${config})
      set(all_links)
      foreach(var IN LISTS LINK_OPTS)
        foreach(link IN LISTS ${var})#for each link defined by the configuration variable
          list(APPEND all_links ${link})#get the value of the link
        endforeach()
      endforeach()
      #same call as an hand-made one but using automatically standard configuration variables
      set(all_defs ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEFINITIONS})#preprocessor definition that apply to the interface of the configuration's components come from : 1) the configuration definition itself and 2) can be set directly by the user component
      foreach(var IN LISTS DEFS)#note: ${var} is the name of the variable
        list(APPEND all_defs ${${var}})#preprocessor definition that apply to the interface of the configuration's components come from : 1) the configuration definition itself and 2) can be set directly by the user component
      endforeach()
      set(all_opts)
      foreach(var IN LISTS COMPILE_OPTS)#note: ${var} is the name of the variable
        list(APPEND all_opts ${${var}})#preprocessor definition that apply to the interface of the configuration's components come from : 1) the configuration definition itself and 2) can be set directly by the user component
      endforeach()
      #only transmit configuration variable if the configuration defines those variables (even if standard they are not all always defined)
      #Note: compared to previous variables those ones are not immediately evaluated since they refer to "path" that can change when relocation occurs
      #or when deployed on another system
      set(includes ${INC_DIRS})
      set(lib_dirs ${LIB_DIRS})
      set(rpath ${RPATH})

      set(fake_intern_opts)
      adjust_Languages_Standards_Description(ERR MESS C_STD_USED CXX_STD_USED INTERN_OPTS EXPORT_OPTS
                                            fake_intern_opts all_opts
                                            "${${config}_C_STANDARD}"
                                            "${${config}_C_MAX_STANDARD}"
                                            "${${config}_CXX_STANDARD}"
                                            "${${config}_CXX_MAX_STANDARD}")
      if(ERR)
        if(ERR STREQUAL "CRITICAL")
          finish_Progress(${GLOBAL_PROGRESS_VAR})
          message(FATAL_ERROR "[PID] CRITICAL ERROR: when requiring system configuration ${config} for component ${component_name} in wrapper ${PROJECT_NAME}, ${MESS}")
        else()
          message("[PID] WARNING: when requiring system configuration ${config} for component ${component_name} in wrapper ${PROJECT_NAME}, ${MESS}")
        endif()
      endif()
      #need to apply corrrective action in compiler options
      set(all_opts ${EXPORT_OPTS})#force adaption of the variable at global scope
      declare_Wrapped_Component_System_Dependency(${component_name}
        "${includes}"
        "${lib_dirs}"
        "${all_links}"
        "${all_defs}"
        "${all_opts}"
        "${C_STD_USED}"
        "${${config}_C_MAX_STANDARD}"
        "${CXX_STD_USED}"
        "${${config}_CXX_MAX_STANDARD}"
        "${rpath}"
      )
      set(config)#reset value of the config variable
    else()#no explicit configuration defined => the user has to manage dependencies "by hand" (should be avoided)

      set(fake_intern_opts)
      adjust_Languages_Standards_Description(ERR MESS C_STD_USED CXX_STD_USED INTERN_OPTS EXPORT_OPTS
                                            fake_intern_opts DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_OPTIONS
                                            "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_C_STANDARD}"
                                            "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_C_MAX_STANDARD}"
                                            "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_CXX_STANDARD}"
                                            "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_CXX_MAX_STANDARD}")
      if(ERR)
        if(ERR STREQUAL "CRITICAL")
          finish_Progress(${GLOBAL_PROGRESS_VAR})
          message(FATAL_ERROR "[PID] CRITICAL ERROR: when defining direct system requirement for component ${component_name} in wrapper ${PROJECT_NAME}, ${MESS}")
        else()
          message("[PID] WARNING: when defining direct system requirement for component ${component_name} in wrapper ${PROJECT_NAME}, ${MESS}")
        endif()
      endif()
      list(APPEND ALL_LINKS ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_SHARED_LINKS} ${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_STATIC_LINKS})
      declare_Wrapped_Component_System_Dependency(${component_name}
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_INCLUDES}"
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_LIBRARY_DIRS}"
        "${ALL_LINKS}"
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_DEFINITIONS}"
        "${INTERN_OPTS}"
        "${C_STD_USED}"
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_C_MAX_STANDARD}"
        "${CXX_STD_USED}"
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_CXX_MAX_STANDARD}"
        "${DECLARE_PID_WRAPPER_COMPONENT_DEPENDENCY_RUNTIME_RESOURCES}"
      )
    endif()
  endif()
endif()
endmacro(declare_PID_Wrapper_Component_Dependency)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Wrapper_System_Configuration| replace:: ``PID_Wrapper_System_Configuration``
#  .. _PID_Wrapper_System_Configuration:
#
#  PID_Wrapper_System_Configuration
#  ----------------------------------------
#
#   .. command:: PID_Wrapper_System_Configuration(EVAL ... VARIABLES ... VALUES ... [OPTIONS])
#
#   .. command:: declare_PID_Wrapper_System_Configuration(EVAL ... VARIABLES ... VALUES ... [OPTIONS])
#
#      To be used in check files of configuration. Used to declare the list of output variables generated by a configuration and how to set them from variables generated by the find file.
#
#     .. rubric:: Required parameters
#
#     :<name>: the name of the configuration.
#     :EVAL <path to eval file>: path to the system configuration evaluation CMake script, relative to system folder.
#     :VARIABLES <list of variables>: the list of variables that are returned by the configuration.
#     :VALUES <list of variables>: the list of variables used to set the value of returned variables. This lis is ordered the same way as VARIABLES, so that each variable in VALUES matches a variable with same index in VARIABLES.
#
#     .. rubric:: Optional parameters
#
#     :FIND_PACKAGES <list of find modules>: list of find modules directly provided by the wrapper.
#     :INSTALL <path to install file>: path to the  CMake script used to install the system configuration, relative to system folder
#     :LANGUAGES <list of languages>: list of special languages (CUDA, Python, Fortran) required by the system configuration.
#     :USE <path to use file>: path to the  CMake script that provide CMake functions/macro definition that will be usable anytime by packages when the system configuration is checked.
#     :LANGUAGES <list of languages>: list of special languages (CUDA, Python, Fortran) required by the system configuration.
#     :ADDITIONAL_CONTENT <list of path>: list of path to files and folders used by the evaluation script.
#     :APT|PACMAN|YUM|BREW|PORT|CHOCO <list of packages>: automatic install procedure defining which packages must be installed depending of the corresponding packaging system of the host.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function can be called in the check file provided by a configuration.
#
#     .. admonition:: Effects
#        :class: important
#
#        Memorize variables used for the given configuration.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        # the configuration boost returns differents variables such as: boost_VERSION, boost_RPATH, etc...
#        # These variable are set according to the value of respectively: BOOST_VERSION, Boost_LIBRARY_DIRS, etc.
#        declare_PID_Wrapper_System_Configuration(
#           EVAL eval_boost.cmake
#           VARIABLES VERSION       LIBRARY_DIRS        INCLUDE_DIRS        RPATH
#           VALUES    BOOST_VERSION Boost_LIBRARY_DIRS  Boost_INCLUDE_DIRS  Boost_LIBRARY_DIRS
#        )
#        PID_Wrapper_System_Configuration_Variables(
#           EVAL eval_boost.cmake
#           VARIABLES VERSION       LIBRARY_DIRS        INCLUDE_DIRS        RPATH
#           VALUES    BOOST_VERSION Boost_LIBRARY_DIRS  Boost_INCLUDE_DIRS  Boost_LIBRARY_DIRS
#        )
#
macro(PID_Wrapper_System_Configuration)
  declare_PID_Wrapper_System_Configuration(${ARGN})
endmacro(PID_Wrapper_System_Configuration)

function(declare_PID_Wrapper_System_Configuration)
  set(monoValueArg EVAL INSTALL)
  set(multiValueArg ${PID_KNOWN_PACKAGING_SYSTEMS} FIND_PACKAGES VARIABLES VALUES LANGUAGES ADDITIONAL_CONTENT USE) #the value may be a list
  cmake_parse_arguments(DECLARE_PID_CONFIGURATION "" "${monoValueArg}" "${multiValueArg}" ${ARGN})
  if(NOT DECLARE_PID_CONFIGURATION_EVAL)
    message(FATAL_ERROR "[PID] CRITICAL ERROR: Bad usage of function PID_Wrapper_System_Configuration, you must give the cmake file used for configuration evaluation using EVAL keyword")
  endif()
  set(${PROJECT_NAME}_SYSTEM_CONFIGURATION_DEFINED TRUE CACHE INTERNAL "")
  set(${PROJECT_NAME}_EVAL_FILE ${DECLARE_PID_CONFIGURATION_EVAL} CACHE INTERNAL "")
  if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${${PROJECT_NAME}_EVAL_FILE})
    message(FATAL_ERROR "[PID] CRITICAL ERROR: Bad usage of function PID_Wrapper_System_Configuration, evaluation file ${${PROJECT_NAME}_EVAL_FILE} does not exist.")
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    return()
  endif()
  if(DECLARE_PID_CONFIGURATION_VARIABLES OR DECLARE_PID_CONFIGURATION_VALUES)
    list(LENGTH DECLARE_PID_CONFIGURATION_VARIABLES SIZE_VARS)
    list(LENGTH DECLARE_PID_CONFIGURATION_VALUES SIZE_VALS)
    if(NOT SIZE_VARS EQUAL SIZE_VALS)
      message(FATAL_ERROR "[PID] CRITICAL ERROR: Bad usage of function PID_Wrapper_System_Configuration, you must give the a value (the name of the variable holding the value to set) for each variable defined using VARIABLES keyword. ")
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      return()
    else()
      set(${PROJECT_NAME}_RETURNED_VARIABLES ${DECLARE_PID_CONFIGURATION_VARIABLES} CACHE INTERNAL "")
      foreach(var IN LISTS DECLARE_PID_CONFIGURATION_VARIABLES)
        list(FIND DECLARE_PID_CONFIGURATION_VARIABLES ${var} INDEX)
        list(GET DECLARE_PID_CONFIGURATION_VALUES ${INDEX} CORRESPONDING_VAL)
        set(${PROJECT_NAME}_${var}_RETURNED_VARIABLE ${CORRESPONDING_VAL} CACHE INTERNAL "")#the value of the variable is not the real value but the name of the variable
      endforeach()
    endif()
  endif()
  if(DECLARE_PID_CONFIGURATION_FIND_PACKAGES)
    set(${PROJECT_NAME}_FIND_PACKAGES ${DECLARE_PID_CONFIGURATION_FIND_PACKAGES} CACHE INTERNAL "")
    foreach(file IN LISTS ${PROJECT_NAME}_FIND_PACKAGES)
      if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/Find${file}.cmake)
        message(FATAL_ERROR "[PID] CRITICAL ERROR: Bad usage of function PID_Wrapper_System_Configuration, find package file ${file} does not exist.")
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        return()
      endif()
    endforeach()
  endif()
  foreach(packager IN LISTS PID_KNOWN_PACKAGING_SYSTEMS)
    if( DECLARE_PID_CONFIGURATION_${packager}
        AND packager STREQUAL CURRENT_PACKAGING_SYSTEM)#OK there is a packager specified for the one used in current platform
      set(${PROJECT_NAME}_INSTALL_PACKAGES ${DECLARE_PID_CONFIGURATION_${packager}} CACHE INTERNAL "")
    endif()
  endforeach()
  if(DECLARE_PID_CONFIGURATION_INSTALL)
    set(${PROJECT_NAME}_INSTALL_PROCEDURE ${DECLARE_PID_CONFIGURATION_INSTALL} CACHE INTERNAL "")
    if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${${PROJECT_NAME}_INSTALL_PROCEDURE})
      message(FATAL_ERROR "[PID] CRITICAL ERROR: Bad usage of function PID_Wrapper_System_Configuration, install procedure file ${${PROJECT_NAME}_INSTALL_PROCEDURE} does not exist.")
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      return()
    endif()
  endif()
  if(DECLARE_PID_CONFIGURATION_LANGUAGES)
    set(${PROJECT_NAME}_EVAL_LANGUAGES ${DECLARE_PID_CONFIGURATION_LANGUAGES} CACHE INTERNAL "")
  endif()

  if(DECLARE_PID_CONFIGURATION_ADDITIONAL_CONTENT)
    set(${PROJECT_NAME}_EVAL_ADDITIONAL_CONTENT ${DECLARE_PID_CONFIGURATION_ADDITIONAL_CONTENT} CACHE INTERNAL "")
    foreach(content IN LISTS ${PROJECT_NAME}_EVAL_ADDITIONAL_CONTENT)
    	if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${content})
        message(FATAL_ERROR "[PID] CRITICAL ERROR: Bad usage of function PID_Wrapper_System_Configuration, additionnal content ${content} does not exist.")
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        return()
      endif()
    endforeach()
  endif()

  if(DECLARE_PID_CONFIGURATION_USE)
    set(${PROJECT_NAME}_USE_FILES ${DECLARE_PID_CONFIGURATION_USE} CACHE INTERNAL "")
  endif()
endfunction(declare_PID_Wrapper_System_Configuration)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Wrapper_System_Configuration_Constraints| replace:: ``PID_Wrapper_System_Configuration_Constraints``
#  .. _PID_Wrapper_System_Configuration_Constraints:
#
#  PID_Wrapper_System_Configuration_Constraints
#  --------------------------------------------
#
#   .. command:: PID_Wrapper_System_Configuration_Constraints([OPTIONS...])
#
#   .. command:: declare_PID_Wrapper_System_Configuration_Constraints([OPTIONS...])
#
#      To be used in check files of configuration. Used to declare the list of constraints managed by the configuration.
#
#     .. rubric:: Optional parameters
#
#     :REQUIRED <list of variables>: The list of required constraints. Required means that the constraints must be specified at configuration check time. All required constraints always appear in final binaries description.
#     :OPTIONAL <list of variables>: The list of optional constraints. Optional means that the constraints value can be ignored when considering binaries AND no paremeter can be given for those constraints at configuration check time.
#     :IN_BINARY <list of variables>: The list of optional constraints at source compilation time but that are required at binary usage time.
#     :VALUE <list of variables>: The list variables used to set the value of the corresponding list of variables IN_BINARY. Used to initialize the value of constraints used only at binary usage time.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function can be called in the check file provided by a configuration.
#
#     .. admonition:: Effects
#        :class: important
#
#        Memorize constraints that can be used for the given configuration.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        declare_PID_Wrapper_System_Configuration_Constraints(ros REQUIRED distribution IN_BINARY packages VALUE ROS_PACKAGES)
#
#        PID_Wrapper_System_Configuration_Constraints(ros REQUIRED distribution IN_BINARY packages VALUE ROS_PACKAGES)
#
macro(PID_Wrapper_System_Configuration_Constraints)
  declare_PID_Wrapper_System_Configuration_Constraints(${ARGN})
endmacro(PID_Wrapper_System_Configuration_Constraints)

function(declare_PID_Wrapper_System_Configuration_Constraints)
  set(multiValueArg REQUIRED OPTIONAL IN_BINARY VALUE) #the value may be a list
  cmake_parse_arguments(PID_CONFIGURATION_CONSTRAINTS "" "" "${multiValueArg}" ${ARGN})
  if(NOT PID_CONFIGURATION_CONSTRAINTS_REQUIRED AND NOT PID_CONFIGURATION_CONSTRAINTS_OPTIONAL AND NOT PID_CONFIGURATION_CONSTRAINTS_IN_BINARY)
    message("[PID] WARNING: Bad usage of function declare_PID_Wrapper_System_Configuration_Constraints, you must give at least one variable using either REQUIRED, IN_BINARY or OPTIONAL keywords.")
  else()
      set(${PROJECT_NAME}_REQUIRED_CONSTRAINTS ${PID_CONFIGURATION_CONSTRAINTS_REQUIRED} CACHE INTERNAL "")#the value of the variable is not the real value but the name of the variable
      set(${PROJECT_NAME}_OPTIONAL_CONSTRAINTS ${PID_CONFIGURATION_CONSTRAINTS_OPTIONAL} CACHE INTERNAL "")#the value of the variable is not the real value but the name of the variable
      list(LENGTH PID_CONFIGURATION_CONSTRAINTS_IN_BINARY SIZE_VARS)
      list(LENGTH PID_CONFIGURATION_CONSTRAINTS_VALUE SIZE_VALS)
      if(NOT SIZE_VARS EQUAL SIZE_VALS)
        message("[PID] WARNING: Bad usage of function PID_Wrapper_System_Configuration_Constraints (or declare_PID_Wrapper_System_Configuration_Constraints), you must give the a value (the name of the variable holding the value to set) for each variable defined using IN_BINARY keyword. ")
      else()
        set(${PROJECT_NAME}_IN_BINARY_CONSTRAINTS ${PID_CONFIGURATION_CONSTRAINTS_IN_BINARY} CACHE INTERNAL "")#the value of the variable is not the real value but the name of the variable
        foreach(constraint IN LISTS PID_CONFIGURATION_CONSTRAINTS_IN_BINARY)
          list(FIND PID_CONFIGURATION_CONSTRAINTS_IN_BINARY ${constraint} INDEX)
          list(GET PID_CONFIGURATION_CONSTRAINTS_VALUE ${INDEX} CORRESPONDING_VAL)
          set(${PROJECT_NAME}_${constraint}_BINARY_VALUE ${CORRESPONDING_VAL} CACHE INTERNAL "")#the value of the variable is not the real value but the name of the variable
        endforeach()
      endif()
  endif()
endfunction(declare_PID_Wrapper_System_Configuration_Constraints)

#.rst:
#
# .. ifmode:: user
#
#  .. |PID_Wrapper_System_Configuration_Dependencies| replace:: ``PID_Wrapper_System_Configuration_Dependencies``
#  .. _PID_Wrapper_System_Configuration_Dependencies:
#
#  PID_Wrapper_System_Configuration_Dependencies
#  ---------------------------------------------
#
#   .. command:: PID_Wrapper_System_Configuration_Dependencies(DEPEND ...)
#
#   .. command:: declare_PID_Wrapper_System_Configuration_Dependencies(DEPEND ...)
#
#      To be used in check files of configuration. Used to declare the list of configuration that the given configuration depends on.
#
#     .. rubric:: Required parameters
#
#     :DEPEND <list of configuration checks>: The list of expressions representing the different systems configurations used by given configuration.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function can be called in the check file provided by a configuration.
#
#     .. admonition:: Effects
#        :class: important
#
#        Memorize dependencies used by the given configuration.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        declare_PID_Wrapper_System_Configuration_Dependencies(ros DEPEND boost)
#
#        PID_Wrapper_System_Configuration_Dependencies(ros DEPEND boost)
#
macro(PID_Wrapper_System_Configuration_Dependencies)
  declare_PID_Wrapper_System_Configuration_Dependencies(${ARGN})
endmacro(PID_Wrapper_System_Configuration_Dependencies)

function(declare_PID_Wrapper_System_Configuration_Dependencies)
  append_Unique_In_cache(${PROJECT_NAME}_CONFIGURATION_DEPENDENCIES "${ARGN}")
endfunction(declare_PID_Wrapper_System_Configuration_Dependencies)

#########################################################################################
######################## API to be used in deploy scripts ###############################
#########################################################################################

function(translate_Into_Options)
set(options)
set(oneValueArgs C_STANDARD CXX_STANDARD FLAGS)
set(multiValueArgs INCLUDES DEFINITIONS LIBRARY_DIRS LINKS)
cmake_parse_arguments(TRANSLATE_INTO_OPTION "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT TRANSLATE_INTO_OPTION_FLAGS)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling translate_Into_Options, need to define the variable where to return flags by using the FLAGS keyword.")
	return()
endif()
set(result)
if(TRANSLATE_INTO_OPTION_INCLUDES)
	foreach(an_include IN LISTS TRANSLATE_INTO_OPTION_INCLUDES)
		list(APPEND result "-I${an_include}")
	endforeach()
endif()
if(TRANSLATE_INTO_OPTION_LIBRARY_DIRS)
	foreach(a_dir IN LISTS TRANSLATE_INTO_OPTION_LIBRARY_DIRS)
		list(APPEND result "-L${a_dir}")
	endforeach()
endif()
if(TRANSLATE_INTO_OPTION_DEFINITIONS)
	foreach(a_def IN LISTS TRANSLATE_INTO_OPTION_DEFINITIONS)
		list(APPEND result "-D${a_def}")
	endforeach()
endif()
if(TRANSLATE_INTO_OPTION_LINKS)
	foreach(a_link IN LISTS TRANSLATE_INTO_OPTION_LINKS)
    convert_Library_Path_To_Default_System_Library_Link(RESULTING_LINK ${a_link})
    list(APPEND result "${RESULTING_LINK}")
	endforeach()
endif()

if(TRANSLATE_INTO_OPTION_C_STANDARD OR TRANSLATE_INTO_OPTION_CXX_STANDARD)
	translate_Standard_Into_Option(RES_C_STD_OPT RES_CXX_STD_OPT "${TRANSLATE_INTO_OPTION_C_STANDARD}" "${TRANSLATE_INTO_OPTION_CXX_STANDARD}")
	if(RES_C_STD_OPT)
		list(APPEND result "${RES_C_STD_OPT}")
	endif()
	if(RES_CXX_STD_OPT)
		list(APPEND result "${RES_CXX_STD_OPT}")
	endif()
endif()
fill_String_From_List(opts result " ")
set(${TRANSLATE_INTO_OPTION_FLAGS} ${opts} PARENT_SCOPE)
endfunction(translate_Into_Options)

#.rst:
#
# .. ifmode:: script
#
#  .. |get_External_Dependencies_Info| replace:: ``get_External_Dependencies_Info``
#  .. _get_External_Dependencies_Info:
#
#  get_External_Dependencies_Info
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_External_Dependencies_Info([OPTIONS])
#
#     Allow to get info defined in description of the currenlty built version.
#
#     .. rubric:: Optional parameters
#
#     :PACKAGE <ext_package>: Target external package that is a dependency of the currently built package, for which we want specific information. Used as a filter to get information only for a given dependency.
#     :COMPONENT: Filter to get only information relative to a component. Mustbe used together with PACKAGE to get only info relative to a component dependency.
#     :LOCAL: Filter to get only local information. Must be used together with PACKAGE and optionally with COMPONENT.
#     :ROOT <variable>: The variable passed as argument will be filled with the path to the dependency external package version. Must be used together with PACKAGE.
#     :CMAKE <variable>: The variable passed as argument will be filled with the path to the folder containing CMake config files. Only usable with PACKAGE.
#     :PKGCONFIG <variable>: The variable passed as argument will be filled with the path to the folder containing pkgconfig config files. Only usable with PACKAGE.
#     :OPTIONS <variable>: The variable passed as argument will be filled with compiler options for the external package version being built.
#     :INCLUDES <variable>: The variable passed as argument will be filled with include folders for the external package version being built.
#     :DEFINITIONS <variable>: The variable passed as argument will be filled with all definitions for the external package version being built.
#     :LINKS <variable>: The variable passed as argument will be filled with all path to librairies and linker options for the external package version being built.
#     :LIBRARY_DIRS <variable>: The variable passed as argument will be filled with all path to folders containing libraries.
#     :C_STANDARD <variable>: The variable passed as argument will be filled with the C language standard to use for the external package version, if any specified.
#     :CXX_STANDARD <variable>: The variable passed as argument will be filled with the CXX language standard to use for the external package version, if any specified.
#     :RESOURCES <variable>: The variable passed as argument will be filled with the runtime resources provided by external dependencies.
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
set(options FLAGS LOCAL)
set(oneValueArgs PACKAGE COMPONENT ROOT C_STANDARD CXX_STANDARD OPTIONS INCLUDES DEFINITIONS LINKS LIBRARY_DIRS RESOURCES CMAKE PKGCONFIG)
set(multiValueArgs)
cmake_parse_arguments(GET_EXTERNAL_DEPENDENCY_INFO "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

set(package_info)
set(component_info)
set(target_var)
set(only_local_info FALSE)
if(GET_EXTERNAL_DEPENDENCY_INFO_LOCAL)
  if(NOT GET_EXTERNAL_DEPENDENCY_INFO_PACKAGE)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_External_Dependency_Info, when using LOCAL you need also to define the external package by using the keyword PACKAGE.")
  endif()
  set(only_local_info TRUE)
endif()

#build the version prefix using variables automatically configured in Build_PID_Wrapper script
#for cleaner description at next lines only
if(GET_EXTERNAL_DEPENDENCY_INFO_PACKAGE)#only direct dependencies can be targetted
  set(package_info ${GET_EXTERNAL_DEPENDENCY_INFO_PACKAGE})
  set(prefix ${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSION_${TARGET_EXTERNAL_VERSION}_DEPENDENCY_${GET_EXTERNAL_DEPENDENCY_INFO_PACKAGE})
  set(dep_version ${${prefix}_VERSION_USED_FOR_BUILD})
  if(NOT dep_version)
    message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_External_Dependency_Info, ${GET_EXTERNAL_DEPENDENCY_INFO_PACKAGE} is not part of the declared dependencies.")
  endif()
  set(ext_package_root ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${GET_EXTERNAL_DEPENDENCY_INFO_PACKAGE}/${dep_version})
  if(GET_EXTERNAL_DEPENDENCY_INFO_COMPONENT)#only direct component dependencies can be targetted
    set(prefix ${prefix}_COMPONENT_${GET_EXTERNAL_DEPENDENCY_INFO_COMPONENT})#refine the prefix !!
    set(component_info ${GET_EXTERNAL_DEPENDENCY_INFO_COMPONENT})
  endif()
elseif(GET_EXTERNAL_DEPENDENCY_INFO_COMPONENT)#NOTE: COMPONENT must be used together with PACKAGE
  finish_Progress(${GLOBAL_PROGRESS_VAR})
  message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_External_Dependency_Info, when using COMPONENT you need also to define the external package by using the keyword PACKAGE.")
else()
  set(prefix ${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSION_${TARGET_EXTERNAL_VERSION})
endif()


if(GET_EXTERNAL_DEPENDENCY_INFO_ROOT)
	if(NOT package_info)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_External_Dependency_Info, when using ROOT keyword you also need to define the external package by using the keyword PACKAGE.")
	endif()
	set(${GET_EXTERNAL_DEPENDENCY_INFO_ROOT} ${ext_package_root} PARENT_SCOPE)
endif()



if(GET_EXTERNAL_DEPENDENCY_INFO_CMAKE)
	if(NOT package_info)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_External_Dependency_Info, when using CMAKE keyword you also need to define the external package by using the keyword PACKAGE.")
	endif()
  if(${package_info}_CMAKE_FOLDER)
	  set(${GET_EXTERNAL_DEPENDENCY_INFO_CMAKE} ${ext_package_root}/${${package_info}_CMAKE_FOLDER} PARENT_SCOPE)
  else()
    message(WARNING "[PID] WARNING : when calling get_External_Dependency_Info, using CMAKE keyword with dependency ${package_info} nbut this package does not provide CMake configuration information.")
    set(${GET_EXTERNAL_DEPENDENCY_INFO_CMAKE} PARENT_SCOPE)
  endif()
endif()


if(GET_EXTERNAL_DEPENDENCY_INFO_PKGCONFIG)
	if(NOT package_info)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_External_Dependency_Info, when using PKGCONFIG keyword you also need to define the external package by using the keyword PACKAGE.")
	endif()
  if(${package_info}_PKGCONFIG_FOLDER)
	  set(${GET_EXTERNAL_DEPENDENCY_INFO_PKGCONFIG} ${ext_package_root}/${${package_info}_PKGCONFIG_FOLDER} PARENT_SCOPE)
  else()
    message(WARNING "[PID] WARNING : when calling get_External_Dependency_Info, using PKGCONFIG keyword with dependency ${package_info} nbut this package does not provide pkg-config configuration information.")
    set(${GET_EXTERNAL_DEPENDENCY_INFO_PKGCONFIG} PARENT_SCOPE)
  endif()
endif()

# WARNING: IMPORTANT NOTE !!
# We retur variables surrounded by guillemets to
# force the definition of the output variable even if its value is empty

if(GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES)
  if(only_local_info)
    if(component_info)
      set(target_var ${package_info}_${component_info}_LOCAL_INCLUDES)
    else()
      set(target_var ${package_info}_LOCAL_INCLUDES)
    endif()
  else()
    set(target_var ${prefix}_BUILD_INCLUDES)
  endif()
  if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
    translate_Into_Options(INCLUDES ${${target_var}} FLAGS RES_INCLUDES)
    set(${GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES} "${RES_INCLUDES}" PARENT_SCOPE)
  else()
    set(${GET_EXTERNAL_DEPENDENCY_INFO_INCLUDES} "${${target_var}}" PARENT_SCOPE)
  endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_LIBRARY_DIRS)
  if(only_local_info)
    if(component_info)
      set(target_var ${package_info}_${component_info}_LOCAL_LIB_DIRS)
    else()
      set(target_var ${package_info}_LOCAL_LIB_DIRS)
    endif()
  else()
    set(target_var ${prefix}_BUILD_LIB_DIRS)
  endif()
	if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
		translate_Into_Options(LIBRARY_DIRS ${${target_var}} FLAGS RES_LIB_DIRS)
    set(${GET_EXTERNAL_DEPENDENCY_INFO_LIBRARY_DIRS} "${RES_LIB_DIRS}" PARENT_SCOPE)
  else()
    set(${GET_EXTERNAL_DEPENDENCY_INFO_LIBRARY_DIRS} "${${target_var}}" PARENT_SCOPE)
	endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_DEFINITIONS)
  if(only_local_info)
    if(component_info)
      set(target_var ${package_info}_${component_info}_LOCAL_DEFINITIONS)
    else()
      set(target_var ${package_info}_LOCAL_DEFINITIONS)
    endif()
  else()
    set(target_var ${prefix}_BUILD_DEFINITIONS)
  endif()
	if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
		translate_Into_Options(DEFINITIONS ${${target_var}} FLAGS RES_DEFS)
    set(${GET_EXTERNAL_DEPENDENCY_INFO_DEFINITIONS} "${RES_DEFS}" PARENT_SCOPE)
	else()
    set(${GET_EXTERNAL_DEPENDENCY_INFO_DEFINITIONS} "${${target_var}}" PARENT_SCOPE)
	endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_OPTIONS)
  if(only_local_info)
    if(component_info)
      set(target_var ${package_info}_${component_info}_LOCAL_COMPILER_OPTIONS)
    else()
      set(target_var ${package_info}_LOCAL_COMPILER_OPTIONS)
    endif()
  else()
    set(target_var ${prefix}_BUILD_COMPILER_OPTIONS)
  endif()
  set(${GET_EXTERNAL_DEPENDENCY_INFO_OPTIONS} "${${target_var}}" PARENT_SCOPE)
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_C_STANDARD)
  if(only_local_info)
    if(component_info)
      set(target_var ${package_info}_${component_info}_LOCAL_C_STANDARD)
    else()
      set(target_var ${package_info}_LOCAL_C_STANDARD)
    endif()
  else()
    set(target_var ${prefix}_BUILD_C_STANDARD)
  endif()
	if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
		translate_Into_Options(C_STANDARD ${${target_var}} FLAGS RES_C_STD)
		set(${GET_EXTERNAL_DEPENDENCY_INFO_C_STANDARD} "${RES_C_STD}" PARENT_SCOPE)
	else()
	  set(${GET_EXTERNAL_DEPENDENCY_INFO_C_STANDARD} "${${target_var}}" PARENT_SCOPE)
	endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_CXX_STANDARD)
  if(only_local_info)
    if(component_info)
      set(target_var ${package_info}_${component_info}_LOCAL_CXX_STANDARD)
    else()
      set(target_var ${package_info}_LOCAL_CXX_STANDARD)
    endif()
  else()
    set(target_var ${prefix}_BUILD_CXX_STANDARD)
  endif()
	if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
		translate_Into_Options(CXX_STANDARD ${${target_var}} FLAGS RES_CXX_STD)
		set(${GET_EXTERNAL_DEPENDENCY_INFO_CXX_STANDARD} "${RES_CXX_STD}" PARENT_SCOPE)
	else()
	  set(${GET_EXTERNAL_DEPENDENCY_INFO_CXX_STANDARD} "${${target_var}}" PARENT_SCOPE)
	endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_LINKS)
  if(only_local_info)
    if(component_info)
      set(target_var ${package_info}_${component_info}_LOCAL_LINKS)
    else()
      set(target_var ${package_info}_LOCAL_LINKS)
    endif()
  else()
    set(target_var ${prefix}_BUILD_LINKS)
  endif()

  if(GET_EXTERNAL_DEPENDENCY_INFO_FLAGS)
		translate_Into_Options(LINKS ${${target_var}} FLAGS RES_LINKER_FLAGS)
		set(${GET_EXTERNAL_DEPENDENCY_INFO_LINKS} "${RES_LINKER_FLAGS}" PARENT_SCOPE)
	else()
	  set(${GET_EXTERNAL_DEPENDENCY_INFO_LINKS} "${${target_var}}" PARENT_SCOPE)
	endif()
endif()

if(GET_EXTERNAL_DEPENDENCY_INFO_RESOURCES)
  if(only_local_info)
    if(component_info)
      set(target_var ${package_info}_${component_info}_LOCAL_RUNTIME_RESOURCES)
    else()
      set(target_var ${package_info}_LOCAL_RUNTIME_RESOURCES)
    endif()
  else()
    set(target_var ${prefix}_BUILD_RUNTIME_RESOURCES)
  endif()
  set(${GET_EXTERNAL_DEPENDENCY_INFO_RESOURCES} "${${target_var}}" PARENT_SCOPE)
endif()

endfunction(get_External_Dependencies_Info)

#.rst:
#
# .. ifmode:: script
#
#  .. |get_User_Option_Info| replace:: ``get_User_Option_Info``
#  .. _get_User_Option_Info:
#
#  get_User_Option_Info
#  ^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_User_Option_Info(OPTION ... RESULT ...)
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
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_User_Option_Info, need to define the name of the option by using the keyword OPTION.")
	return()
endif()
if(NOT GET_USER_OPTION_INFO_RESULT)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_User_Option_Info, need to define the variable that will receive the value of the option by using the keyword RESULT.")
	return()
endif()
if(NOT ${TARGET_EXTERNAL_PACKAGE}_USER_OPTIONS)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_User_Option_Info, no user option is defined in the wrapper ${TARGET_EXTERNAL_PACKAGE}.")
	return()
endif()
list(FIND ${TARGET_EXTERNAL_PACKAGE}_USER_OPTIONS ${GET_USER_OPTION_INFO_OPTION} INDEX)
if(INDEX EQUAL -1)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling get_User_Option_Info, no user option with name ${GET_USER_OPTION_INFO_OPTION} is defined in the wrapper ${TARGET_EXTERNAL_PACKAGE}.")
	return()
endif()
set(${GET_USER_OPTION_INFO_RESULT} ${${TARGET_EXTERNAL_PACKAGE}_USER_OPTION_${GET_USER_OPTION_INFO_OPTION}_VALUE} PARENT_SCOPE)
endfunction(get_User_Option_Info)

#.rst:
#
# .. ifmode:: script
#
#  .. |install_External_Project| replace:: ``install_External_Project``
#  .. _install_External_Project:
#
#  install_External_Project
#  ^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: install_External_Project([URL ...] ARCHIVE|GIT_CLONE_COMMIT ... FOLDER ... PATH ... [OPTIONS])
#
#     Install the external project into build tree. This project can be either:
#       + downloaded as an archive from an online archive filesystem
#       + cloned from an online git repository
#       + extracted from a local archive provided by the wrapper
#
#     .. rubric:: Required parameters
#
#     :ARCHIVE|GIT_CLONE_COMMIT <string>: The name of the archive downloaded (or its path relative to current source dir if not download) or the identifier of the commit to checkout to. Both keyword ARCHIVE and GIT_CLONE_COMMIT are exclusive.
#     :FOLDER <string>: The folder resulting from archive extraction or repository cloning.
#
#     .. rubric:: Optional parameters
#
#     :URL <url>: The URL from where to download the archive or to clone the project.
#     :GIT_CLONE_ARGS <list of arguments>: List of argument to use when cloning.
#     :PATH <path>: the output variable that contains the path to the installed project, empty if project cannot be installed
#     :PROJECT <string>: the name of the project if you want to generate nice outputs about external package install process
#     :VERSION <version string>: the version of the external project that is installed, only usefull together with PROJECT keyword.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - Must be used in deploy scripts defined in a wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#         -  This function is used to download and install the archive of an external project.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        install_External_Project( PROJECT yaml-cpp
#                          VERSION 0.6.2
#                          URL https://github.com/jbeder/yaml-cpp/archive/yaml-cpp-0.6.2.tar.gz
#                          ARCHIVE yaml-cpp-0.6.2.tar.gz
#                          FOLDER yaml-cpp-yaml-cpp-0.6.2)
#
#
function(install_External_Project)
  set(options) #used to define the context
  set(oneValueArgs PROJECT VERSION URL ARCHIVE GIT_CLONE_COMMIT FOLDER PATH)
  set(multiValueArgs GIT_CLONE_ARGS)
  cmake_parse_arguments(INSTALL_EXTERNAL_PROJECT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
  if((NOT INSTALL_EXTERNAL_PROJECT_GIT_CLONE_COMMIT AND NOT INSTALL_EXTERNAL_PROJECT_ARCHIVE)
      OR NOT INSTALL_EXTERNAL_PROJECT_FOLDER)

    if(INSTALL_EXTERNAL_PROJECT_PATH)
      set(${INSTALL_EXTERNAL_PROJECT_PATH} PARENT_SCOPE)
    endif()
    set(ERROR_IN_SCRIPT TRUE PARENT_SCOPE)
    message(FATAL_ERROR "[PID] CRITICAL ERROR : ARCHIVE (or GIT_CLONE_COMMIT) and FOLDER arguments must be provided to install_External_Project.")
    return()
  endif()

  if(INSTALL_EXTERNAL_PROJECT_GIT_CLONE_COMMIT AND INSTALL_EXTERNAL_PROJECT_ARCHIVE)
    set(ERROR_IN_SCRIPT TRUE PARENT_SCOPE)
    message(FATAL_ERROR "[PID] CRITICAL ERROR : ARCHIVE and GIT_CLONE_COMMIT arguments are exclusive.")
    return()
  endif()

  if(NOT INSTALL_EXTERNAL_PROJECT_URL AND NOT INSTALL_EXTERNAL_PROJECT_ARCHIVE)
    set(ERROR_IN_SCRIPT TRUE PARENT_SCOPE)
    message(FATAL_ERROR "[PID] CRITICAL ERROR : ARCHIVE argument must be used if you provide no URL to install_External_Project.")
    return()
  endif()

  if(INSTALL_EXTERNAL_PROJECT_VERSION)
    set(version_str " version ${INSTALL_EXTERNAL_PROJECT_VERSION}")
  else()
    set(version_str)
  endif()
  #check that the build dir has not been deleted
  if(NOT EXISTS ${TARGET_BUILD_DIR})
    execute_process(COMMAND ${CMAKE_COMMAND} .. WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
  endif()

  if(INSTALL_EXTERNAL_PROJECT_ARCHIVE)
    if(INSTALL_EXTERNAL_PROJECT_URL)#an url is provided so download the file
      set(archive_name ${INSTALL_EXTERNAL_PROJECT_ARCHIVE})
      if(NOT EXISTS ${TARGET_BUILD_DIR}/${archive_name})#only download if necessary
        if(INSTALL_EXTERNAL_PROJECT_PROJECT)
          message("[PID] INFO : Downloading ${INSTALL_EXTERNAL_PROJECT_PROJECT}${version_str} ...")
        endif()
        if(SHOW_WRAPPERS_BUILD_OUTPUT)
          set(SHOW_DOWNLOAD_PROGRESS SHOW_PROGRESS)
        else()
          set(SHOW_DOWNLOAD_PROGRESS)
        endif()
        file(DOWNLOAD ${INSTALL_EXTERNAL_PROJECT_URL} ${TARGET_BUILD_DIR}/${archive_name}
             ${SHOW_DOWNLOAD_PROGRESS}
             STATUS dl_result)
        list(GET dl_result 0 return_val)
        if(NOT return_val EQUAL 0)
          list(GET dl_result 1 error_str)
          message("[PID] WARNING : cannot download ${INSTALL_EXTERNAL_PROJECT_PROJECT}${version_str} from ${INSTALL_EXTERNAL_PROJECT_URL}. Reason: ${error_str}. Try again...")
          # sanity action: remove the file
          file(REMOVE ${TARGET_BUILD_DIR}/${archive_name})
          execute_process(COMMAND ${CMAKE_COMMAND} -E sleep 10  OUTPUT_QUIET ERROR_QUIET)
          file(DOWNLOAD ${INSTALL_EXTERNAL_PROJECT_URL} ${TARGET_BUILD_DIR}/${archive_name}
                ${SHOW_DOWNLOAD_PROGRESS}
                STATUS dl_result)
          list(GET dl_result 0 return_val)
          if(NOT return_val EQUAL 0)
            list(GET dl_result 1 error_str)
            message("[PID] ERROR : cannot download ${INSTALL_EXTERNAL_PROJECT_PROJECT}${version_str} from ${INSTALL_EXTERNAL_PROJECT_URL}. Reason: ${error_str}")
            # sanity action: remove the file
            file(REMOVE ${TARGET_BUILD_DIR}/${archive_name})
          endif()
        endif()
      endif()
    else()#the archive has to be found locally
      if(NOT EXISTS ${TARGET_SOURCE_DIR}/${INSTALL_EXTERNAL_PROJECT_ARCHIVE})
        set(ERROR_IN_SCRIPT TRUE PARENT_SCOPE)
        message(FATAL_ERROR "[PID] CRITICAL ERROR : ${INSTALL_EXTERNAL_PROJECT_ARCHIVE} cannot be found in source tree (check that the path os correct).")
        return()
      endif()
      if(INSTALL_EXTERNAL_PROJECT_PROJECT)
        message("[PID] INFO : Preparing extraction of ${INSTALL_EXTERNAL_PROJECT_PROJECT}${version_str} ...")
      endif()
      get_filename_component(archive_name ${INSTALL_EXTERNAL_PROJECT_ARCHIVE} NAME)
      file(COPY ${TARGET_SOURCE_DIR}/${INSTALL_EXTERNAL_PROJECT_ARCHIVE} DESTINATION ${TARGET_BUILD_DIR})#simply copy the archive
    endif()

    #check if no problem appear during extraction
    if(NOT EXISTS ${TARGET_BUILD_DIR}/${archive_name})
      if(INSTALL_EXTERNAL_PROJECT_PROJECT)
        message("[PID] ERROR : During deployment of ${INSTALL_EXTERNAL_PROJECT_PROJECT}${version_str}, cannot download the archive.")
      endif()
      if(INSTALL_EXTERNAL_PROJECT_PATH)
        set(${INSTALL_EXTERNAL_PROJECT_PATH} PARENT_SCOPE)
      endif()
      set(ERROR_IN_SCRIPT TRUE PARENT_SCOPE)
      return()
    endif()

    #cleaning the already extracted folder
    if(EXISTS ${TARGET_BUILD_DIR}/${INSTALL_EXTERNAL_PROJECT_FOLDER})
      file(REMOVE_RECURSE ${TARGET_BUILD_DIR}/${INSTALL_EXTERNAL_PROJECT_FOLDER})
    endif()

    if(INSTALL_EXTERNAL_PROJECT_PROJECT)
      message("[PID] INFO : Extracting ${INSTALL_EXTERNAL_PROJECT_PROJECT}${version_str} ...")
    endif()
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E tar xf ${archive_name}
      WORKING_DIRECTORY ${TARGET_BUILD_DIR}
      RESULT_VARIABLE RES
    )
    if(NOT RES EQUAL 0)
      file(REMOVE ${archive_name})
    endif()
  elseif(INSTALL_EXTERNAL_PROJECT_GIT_CLONE_COMMIT)
    if(EXISTS ${TARGET_BUILD_DIR}/${INSTALL_EXTERNAL_PROJECT_FOLDER})
      file(REMOVE_RECURSE ${TARGET_BUILD_DIR}/${INSTALL_EXTERNAL_PROJECT_FOLDER})
    endif()

    if(INSTALL_EXTERNAL_PROJECT_PROJECT)
      message("[PID] INFO : Cloning ${INSTALL_EXTERNAL_PROJECT_PROJECT} with commit ${INSTALL_EXTERNAL_PROJECT_GIT_CLONE_COMMIT} ...")
    endif()
    execute_process(
      COMMAND git clone ${INSTALL_EXTERNAL_PROJECT_GIT_CLONE_ARGS} ${INSTALL_EXTERNAL_PROJECT_URL}
      WORKING_DIRECTORY ${TARGET_BUILD_DIR}
    )
    execute_process(
      COMMAND git checkout ${INSTALL_EXTERNAL_PROJECT_GIT_CLONE_COMMIT}
      WORKING_DIRECTORY ${TARGET_BUILD_DIR}/${INSTALL_EXTERNAL_PROJECT_FOLDER}
    )
    # If the repo has submodules we need to bring them back to their version corresponding to the checked out commit
    execute_process(
      COMMAND git submodule update --recursive
      WORKING_DIRECTORY ${TARGET_BUILD_DIR}/${INSTALL_EXTERNAL_PROJECT_FOLDER}
    )
  endif()

  #check that the extract went well
  if(NOT EXISTS ${TARGET_BUILD_DIR}/${INSTALL_EXTERNAL_PROJECT_FOLDER}
      OR NOT IS_DIRECTORY ${TARGET_BUILD_DIR}/${INSTALL_EXTERNAL_PROJECT_FOLDER})
    if(INSTALL_EXTERNAL_PROJECT_PROJECT)
      if(INSTALL_EXTERNAL_PROJECT_ARCHIVE)
        message("[PID] ERROR : during deployment of ${INSTALL_EXTERNAL_PROJECT_PROJECT}${version_str}, cannot extract the archive (${TARGET_BUILD_DIR}/${INSTALL_EXTERNAL_PROJECT_FOLDER} does not exists).")
      elseif(INSTALL_EXTERNAL_PROJECT_GIT_CLONE_COMMIT)
        message("[PID] ERROR : during cloning of ${INSTALL_EXTERNAL_PROJECT_PROJECT}, cannot extract the archive  (${TARGET_BUILD_DIR}/${INSTALL_EXTERNAL_PROJECT_FOLDER} does not exists).")
      endif()
    endif()
    if(INSTALL_EXTERNAL_PROJECT_PATH)
      set(${INSTALL_EXTERNAL_PROJECT_PATH} PARENT_SCOPE)
    endif()
    set(ERROR_IN_SCRIPT TRUE PARENT_SCOPE)
    return()
  endif()

  #return the path
if(INSTALL_EXTERNAL_PROJECT_PATH)
  set(${INSTALL_EXTERNAL_PROJECT_PATH} ${TARGET_BUILD_DIR}/${INSTALL_EXTERNAL_PROJECT_FOLDER} PARENT_SCOPE)
endif()
endfunction(install_External_Project)

#.rst:
#
# .. ifmode:: script
#
#  .. |return_External_Project_Error| replace:: ``return_External_Project_Error``
#  .. _return_External_Project_Error:
#
#  return_External_Project_Error
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: return_External_Project_Error()
#
#     Make the current wrapper script to return an error.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - Must be used in deploy scripts defined in a wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#         -  generates an error code for the current deploy script.
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#         return_External_Project_Error()
#
macro(return_External_Project_Error)
  set(ERROR_IN_SCRIPT TRUE)
  return()
endmacro(return_External_Project_Error)

#.rst:
#
# .. ifmode:: script
#
#  .. |build_B2_External_Project| replace:: ``build_B2_External_Project``
#  .. _build_B2_External_Project:
#
#  build_B2_External_Project
#  ^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: build_B2_External_Project(PROJECT ... FOLDER ... MODE ... [OPTIONS])
#
#     Configure, build and install an external project defined with Boost build.
#     WARNING: this function is usable only in wrappers, to build Boost build projects
#
#     .. rubric:: Required parameters
#
#     :PROJECT <string>: The name of the external project.
#     :FOLDER <string>: The name of the folder containing the project.
#     :MODE <Release|Debug>: The build mode.
#
#     .. rubric:: Optional parameters
#
#     :QUIET: if used then the output of this command will be silent.
#     :COMMENT <string>: A string to append to message to inform about special thing you are doing. Usefull if you intend to buildmultiple time the same external project with different options.
#     :DEFINITIONS <list of definitions>: the CMake definitions you need to provide to the cmake build script.
#     :WITH <list of libraries>: Libraries to be included in the build
#     :WITHOUT <list of libraries>: Libraries to be excluded from the build
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - Must be used in deploy scripts defined in a wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#         -  Build and install the external project into workspace install tree..
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#         in wrapper content description file:
#
#           PID_Wrapper_Environment(b2)
#
#         in wrapper deploy script:
#
#           build_B2_External_Project(PROJECT boost FOLDER boost_1_64_0 MODE Release)
#

#.rst:
#
# .. ifmode:: script
#
#  .. |build_Autotools_External_Project| replace:: ``build_Autotools_External_Project``
#  .. _build_Autotools_External_Project:
#
#  build_Autotools_External_Project
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: build_Autotools_External_Project(PROJECT ... FOLDER ... MODE ... [OPTIONS])
#
#     Configure, build and install an external project defined with GNU autotools.
#
#     .. rubric:: Required parameters
#
#     :PROJECT <string>: The name of the external project.
#     :FOLDER <string>: The name of the folder containing the project.
#     :MODE <Release|Debug>: The build mode.
#
#     .. rubric:: Optional parameters
#
#     :QUIET: if used then the output of this command will be silent.
#     :COMMENT <string>: A string to append to message to inform about special thing you are doing. Usefull if you intend to buildmultiple time the same external project with different options.
#     :DEFINITIONS <list of definitions>: the CMake definitions you need to provide to the cmake build script.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - Must be used in deploy scripts defined in a wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#         -  Build and install the external project into workspace install tree..
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#         build_Autotools_External_Project(PROJECT aproject FOLDER a_project_v12 MODE Release)
#


#.rst:
#
# .. ifmode:: script
#
#  .. |build_Colcon_Workspace| replace:: ``build_Colcon_Workspace``
#  .. build_Colcon_Workspace:
#
#  build_Colcon_Workspace
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: build_Colcon_Workspace(PROJECT ... WORKSPACE ...)
#
#     Build a colcon workspace that contains a set of projects.
#
#     .. rubric:: Required parameters
#
#     :PROJECT <string>: The global name of the external project defined as a workspace.
#     :WORKSPACE <string>: The path to the colcon workspace, relative to root build folder.
#
#     .. rubric:: Optional parameters
#
#     :MODE <Rlease|Debug>: The global name of the external project defined as a workspace.
#     :COMMENT <string>: comment printed during execution.
#     :RPATH <list of strings>: additionnal rpath to set (for plugins).
#     :DEFINITIONS <list of defs>: additionnal cmake definitions for colcon packages.
#     
#     .. admonition:: Constraints
#        :class: warning
#
#        - Must be used in deploy scripts defined in a wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#         -  build all porjects in the workspace .
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#         build_Colcon_Workspace(PROJECT gazebo WORKSPACE workspace Mode Release)
#

#.rst:
#
# .. ifmode:: script
#
#  .. |build_Waf_External_Project| replace:: ``build_Waf_External_Project``
#  .. _build_Waf_External_Project:
#
#  build_Waf_External_Project
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: build_Waf_External_Project(PROJECT ... FOLDER ... MODE ... [OPTIONS])
#
#     Configure, build and install an external project defined with python Waf tool.
#
#     .. rubric:: Required parameters
#
#     :PROJECT <string>: The name of the external project.
#     :FOLDER <string>: The name of the folder containing the project.
#     :MODE <Release|Debug>: The build mode.
#
#     .. rubric:: Optional parameters
#
#     :COMMENT <string>: A string to append to message to inform about special thing you are doing. Usefull if you intend to buildmultiple time the same external project with different options.
#     :DEFINITIONS <list of definitions>: the CMake definitions you need to provide to the cmake build script.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - Must be used in deploy scripts defined in a wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#         -  Build and install the external project into workspace install tree..
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#         build_Waf_External_Project(PROJECT aproject FOLDER a_project_v12 MODE Release)
#
function(build_Waf_External_Project)
  if(ERROR_IN_SCRIPT)
    return()
  endif()
  set(options QUIET) #used to define the context
  set(oneValueArgs PROJECT FOLDER MODE COMMENT USER_JOBS)
  set(multiValueArgs C_FLAGS CXX_FLAGS LD_FLAGS OPTIONS)
  cmake_parse_arguments(BUILD_WAF_EXTERNAL_PROJECT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
  if(NOT BUILD_WAF_EXTERNAL_PROJECT_PROJECT OR NOT BUILD_WAF_EXTERNAL_PROJECT_FOLDER OR NOT BUILD_WAF_EXTERNAL_PROJECT_MODE)
    message(FATAL_ERROR "[PID] CRITICAL ERROR : PROJECT, FOLDER and MODE arguments are mandatory when calling build_Waf_External_Project.")
    return()
  endif()

  if(BUILD_WAF_EXTERNAL_PROJECT_QUIET)
    message("[PID] INFO : build_Waf_External_Project QUIET option is now deprecated, use the SHOW_WRAPPERS_BUILD_OUTPUT variable instead")
  endif()

  if(NOT SHOW_WRAPPERS_BUILD_OUTPUT)
    set(OUTPUT_MODE OUTPUT_VARIABLE process_output ERROR_VARIABLE process_output)
  else()
    set(OUTPUT_MODE)
  endif()

  if(BUILD_WAF_EXTERNAL_PROJECT_COMMENT)
    set(use_comment "(${BUILD_WAF_EXTERNAL_PROJECT_COMMENT}) ")
  endif()

  #create the build folder inside the project folder
  set(project_dir ${TARGET_BUILD_DIR}/${BUILD_WAF_EXTERNAL_PROJECT_FOLDER})
  if(NOT EXISTS ${project_dir})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling build_Waf_External_Project the build folder specified (${BUILD_WAF_EXTERNAL_PROJECT_FOLDER}) does not exist.")
    return()
  endif()

  message("[PID] INFO : Configuring, building and installing ${BUILD_WAF_EXTERNAL_PROJECT_PROJECT} ${use_comment} ...")

  # preparing b2 invocation parameters
  #configure build mode (to get available parameters see https://boostorg.github.io/build/tutorial.html section "Feature reference")
  if(BUILD_WAF_EXTERNAL_PROJECT_MODE STREQUAL Debug)
      set(ARGS_FOR_WAF_BUILD "variant=debug")
      set(TARGET_MODE Debug)
  else()
      set(ARGS_FOR_WAF_BUILD "variant=release")
      set(TARGET_MODE Release)
  endif()
   #ABI definition is already in compile flags

  #configure compilation flags
  set(C_FLAGS_ENV ${BUILD_WAF_EXTERNAL_PROJECT_C_FLAGS})
  set(CXX_FLAGS_ENV ${BUILD_WAF_EXTERNAL_PROJECT_CXX_FLAGS})
  set(LD_FLAGS_ENV ${BUILD_WAF_EXTERNAL_PROJECT_LD_FLAGS})
  translate_Standard_Into_Option(RES_C_STD_OPT RES_CXX_STD_OPT ${USE_C_STD} ${USE_CXX_STD})
  list(APPEND C_FLAGS_ENV ${RES_C_STD_OPT})
  list(APPEND CXX_FLAGS_ENV ${RES_CXX_STD_OPT})

  get_Environment_Info(CXX RELEASE CFLAGS cxx_flags COMPILER cxx_compiler LINKER ld_tool)
  get_Environment_Info(SHARED LDFLAGS ld_flags)
  get_Environment_Info(C RELEASE CFLAGS c_flags COMPILER c_compiler)

  if(c_flags)
    list(APPEND C_FLAGS_ENV ${c_flags})
  endif()
  if(cxx_flags)
    list(APPEND CXX_FLAGS_ENV ${cxx_flags})
  endif()
  if(ld_flags)
    list(APPEND LD_FLAGS_ENV ${ld_flags})
  endif()

  set(TEMP_LDFLAGS "$ENV{LDFLAGS}")
  set(TEMP_C "$ENV{CFLAGS}")
  set(TEMP_CXX "$ENV{CXXFLAGS}")
  set(TEMP_C_COMPILER "$ENV{CC}")
  set(TEMP_CXX_COMPILER "$ENV{CXX}")
  set(TEMP_LD "$ENV{LD}")

  fill_String_From_List(RES_STRING LD_FLAGS_ENV " ")
  set(ENV{LDFLAGS} ${RES_STRING})
  fill_String_From_List(RES_STRING C_FLAGS_ENV " ")
  set(ENV{CFLAGS} ${RES_STRING})
  fill_String_From_List(RES_STRING CXX_FLAGS_ENV " ")
  set(ENV{CXXFLAGS} "${RES_STRING}")
  set(ENV{CC} "${c_compiler}")
  set(ENV{CXX} "${cxx_compiler}")
  set(ENV{LD} "${ld_tool}")

  # Use user-defined number of jobs if defined
  if(ENABLE_PARALLEL_BUILD AND BUILD_WAF_EXTERNAL_PROJECT_USER_JOBS) #the user may have put a restriction
    set(jnumber ${BUILD_WAF_EXTERNAL_PROJECT_USER_JOBS})
  else()
    get_Job_Count_For(${BUILD_WAF_EXTERNAL_PROJECT_PROJECT} jnumber)
  endif()
  set(jobs "-j${jnumber}")

  message("[PID] INFO : Building ${BUILD_WAF_EXTERNAL_PROJECT_PROJECT} ${use_comment} in ${TARGET_MODE} mode using ${jnumber} jobs...")

  execute_process(
    COMMAND ${CURRENT_PYTHON_EXECUTABLE} waf distclean configure build install ${BUILD_WAF_EXTERNAL_PROJECT_OPTIONS} ${jobs} --prefix=${TARGET_INSTALL_DIR} ..
    WORKING_DIRECTORY ${project_dir}
    RESULT_VARIABLE result
    ${OUTPUT_MODE}
  )

  #put back environment variables in previous state
  set(ENV{LDFLAGS} "${TEMP_LD}")
  set(ENV{CFLAGS} "${TEMP_C}")
  set(ENV{CXXFLAGS} "${TEMP_CXX}")
  set(ENV{CC} "${TEMP_C_COMPILER}")
  set(ENV{CXX} "${TEMP_CXX_COMPILER}")
  set(ENV{LD} "${TEMP_LD}")
  if(NOT result EQUAL 0)#error at configuration time
    if(OUTPUT_MODE)
      message("${build_output}")
    endif()
    message("[PID] ERROR : cannot configure/build/install Waf project ${BUILD_WAF_EXTERNAL_PROJECT_PROJECT} ${use_comment} ...")
    set(ERROR_IN_SCRIPT TRUE PARENT_SCOPE)
    return()
  endif()

  enforce_Standard_Install_Dirs(${TARGET_INSTALL_DIR})
  symlink_DLLs_To_Lib_Folder(${TARGET_INSTALL_DIR})
  set_External_Runtime_Component_Rpath(${TARGET_EXTERNAL_PACKAGE} ${TARGET_EXTERNAL_VERSION})
endfunction(build_Waf_External_Project)

#.rst:
#
# .. ifmode:: script
#
#  .. |build_CMake_External_Project| replace:: ``build_CMake_External_Project``
#  .. _build_CMake_External_Project:
#
#  build_CMake_External_Project
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: build_CMake_External_Project(URL ... ARCHIVE ... FOLDER ... PATH ... [OPTIONS])
#
#     Configure, build and install a Cmake external project.
#
#     .. rubric:: Required parameters
#
#     :PROJECT <string>: The name of the external project.
#     :FOLDER <string>: The name of the folder containing the project.
#     :Mode <Release|Debug>: The build mode.
#
#     .. rubric:: Optional parameters
#
#     :COMMENT <string>: A string to append to message to inform about special thing you are doing. Usefull if you intend to buildmultiple time the same external project with different options.
#     :DEFINITIONS <list of definitions>: the CMake definitions you need to provide to the cmake build script.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - Must be used in deploy scripts defined in a wrapper.
#
#     .. admonition:: Effects
#        :class: important
#
#         -  Build and install the external project into workspace install tree..
#
#     .. rubric:: Example
#
#     .. code-block:: cmake
#
#        build_CMake_External_Project( PROJECT yaml-cpp FOLDER yaml-cpp-yaml-cpp-0.6.2 MODE Release
#                              DEFINITIONS BUILD_GMOCK=OFF BUILD_GTEST=OFF BUILD_SHARED_LIBS=ON YAML_CPP_BUILD_TESTS=OFF YAML_CPP_BUILD_TESTS=OFF YAML_CPP_BUILD_TOOLS=OFF YAML_CPP_BUILD_CONTRIB=OFF gtest_force_shared_crt=OFF
#                              COMMENT "shared libraries")
#
#
function(build_CMake_External_Project)
  if(ERROR_IN_SCRIPT)
    return()
  endif()
  set(options QUIET) #used to define the context
  set(oneValueArgs PROJECT FOLDER MODE USER_JOBS COMMENT)
  set(multiValueArgs DEFINITIONS)
  cmake_parse_arguments(BUILD_CMAKE_EXTERNAL_PROJECT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
  if(NOT BUILD_CMAKE_EXTERNAL_PROJECT_PROJECT OR NOT BUILD_CMAKE_EXTERNAL_PROJECT_FOLDER OR NOT BUILD_CMAKE_EXTERNAL_PROJECT_MODE)
    message(FATAL_ERROR "[PID] CRITICAL ERROR : PROJECT, FOLDER and MODE arguments are mandatory when calling build_CMake_External_Project.")
    return()
  endif()

  if(BUILD_CMAKE_EXTERNAL_PROJECT_QUIET)
    message("[PID] INFO : build_CMake_External_Project QUIET option is now deprecated, use the SHOW_WRAPPERS_BUILD_OUTPUT variable instead")
  endif()

  if(NOT SHOW_WRAPPERS_BUILD_OUTPUT)
    set(OUTPUT_MODE OUTPUT_VARIABLE process_output ERROR_VARIABLE process_output)
  else()
    set(OUTPUT_MODE)
  endif()

  if(BUILD_CMAKE_EXTERNAL_PROJECT_MODE STREQUAL Debug)
    set(TARGET_MODE Debug)
  else()
    set(TARGET_MODE Release)
  endif()
  #create the build folder inside the project folder
  set(project_build_dir ${TARGET_BUILD_DIR}/${BUILD_CMAKE_EXTERNAL_PROJECT_FOLDER}/build)
  if(NOT EXISTS ${project_build_dir})
    file(MAKE_DIRECTORY ${project_build_dir})#create the build dir
  else()#clean the build folder
    hard_Clean_Build_Folder(${project_build_dir})
  endif()

  set(calling_defs)
  #compute user defined CMake definitions => create the arguments of the command line with space separated arguments
  # this is to allow the usage of a list of list in CMake
  foreach(def IN LISTS BUILD_CMAKE_EXTERNAL_PROJECT_DEFINITIONS)
   # Managing list and variables
   if(def MATCHES "(.+)=(.+)") #if a cmake assignement (should be the case for any definition)
     if(DEFINED ${CMAKE_MATCH_2}) # if right-side of the assignement is a variable
       set(val ${${CMAKE_MATCH_2}}) #take the value of the variable
     else()
       set(val ${CMAKE_MATCH_2})
     endif()
     set(var ${CMAKE_MATCH_1})
     if(val #if val has a value OR if value of val is "FALSE"
        OR val MATCHES "FALSE|OFF"
        OR val EQUAL 0
        OR val MATCHES "NOTFOUND")#if VAL is not empty
       set(calling_defs "${calling_defs} -D${var}=${val}")
     endif()
   elseif(def MATCHES "(.+)=")#empty assignment
     set(calling_defs "${calling_defs} -D${CMAKE_MATCH_1}=")
   else()#no setting this is a cmake specific argument
     set(calling_defs "${calling_defs} ${def}")
   endif()
  endforeach()
  #use separate_arguments to adequately manage list in values
  if(CMAKE_HOST_WIN32)#on a window host path must be resolved
		separate_arguments(COMMAND_ARGS_AS_LIST WINDOWS_COMMAND "${calling_defs}")
	else()#if not on windows use a UNIX like command syntax
		separate_arguments(COMMAND_ARGS_AS_LIST UNIX_COMMAND "${calling_defs}")#always from host perpective
	endif()

  if(BUILD_CMAKE_EXTERNAL_PROJECT_COMMENT)
    set(use_comment "(${BUILD_CMAKE_EXTERNAL_PROJECT_COMMENT}) ")
  endif()

  message("[PID] INFO : Configuring ${BUILD_CMAKE_EXTERNAL_PROJECT_PROJECT} ${use_comment}...")
  # pre-populate the cache with the cache file of the workspace containing build infos,
  # then populate with additionnal information
  # specific: management of rpath
  set(rpath_options "-DCMAKE_SKIP_BUILD_RPATH=FALSE -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=FALSE -DCMAKE_BUILD_WITH_INSTALL_RPATH=FALSE")
  if(APPLE)
    set(rpath_options "${rpath_options} -DCMAKE_MACOSX_RPATH=TRUE -DCMAKE_INSTALL_RPATH=@loader_path/../.rpath;@loader_path/../lib;@loader_path")
  elseif (UNIX)
    set(rpath_options "${rpath_options} -DCMAKE_INSTALL_RPATH=\$ORIGIN/../.rpath;\$ORIGIN/../lib;\$ORIGIN")
  endif()
  if(CMAKE_HOST_WIN32)#on a window host path must be resolved
		separate_arguments(RPATH_ARGS_AS_LIST WINDOWS_COMMAND "${rpath_options}")
	else()#if not on windows use a UNIX like command syntax
		separate_arguments(RPATH_ARGS_AS_LIST UNIX_COMMAND "${rpath_options}")#always from host perpective
	endif()
  get_Project_Specific_Build_Info(BUILD_INFO_FILE)
  execute_process(
    COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=${TARGET_MODE}
                            -DCMAKE_INSTALL_PREFIX=${TARGET_INSTALL_DIR}
                            -DCMAKE_SKIP_INSTALL_RPATH=OFF
                            -DCMAKE_SKIP_RPATH=OFF
                            -DCMAKE_INSTALL_LIBDIR=lib
                            -DCMAKE_INSTALL_BINDIR=bin
                            -DCMAKE_INSTALL_INCLUDEDIR=include
                            -DCMAKE_INSTALL_DATAROOTDIR=share
                            ${RPATH_ARGS_AS_LIST}
                            -DCMAKE_C_STANDARD=${USE_C_STD}
                            -DCMAKE_CXX_STANDARD=${USE_CXX_STD}
                            -C ${BUILD_INFO_FILE}
                            ${COMMAND_ARGS_AS_LIST}
                            ..
      WORKING_DIRECTORY ${project_build_dir}
      ${OUTPUT_MODE}
      RESULT_VARIABLE result
    )
  if(NOT result EQUAL 0)#error at configuration time
    message("${process_output}")
    set(ERROR_IN_SCRIPT TRUE PARENT_SCOPE)
    message("[PID] ERROR : cannot configure CMake project ${BUILD_CMAKE_EXTERNAL_PROJECT_PROJECT} ${use_comment} ...")
    return()
  endif()
  #once configure, build it
  # Use user-defined number of jobs if defined
  get_Environment_Info(MAKE make_program)#get jobs flags from environment
  if(ENABLE_PARALLEL_BUILD AND BUILD_CMAKE_EXTERNAL_PROJECT_USER_JOBS) #the user may have put a restriction
    set(jnumber ${BUILD_CMAKE_EXTERNAL_PROJECT_USER_JOBS})
  else()
    get_Job_Count_For(${BUILD_CMAKE_EXTERNAL_PROJECT_PROJECT} jnumber)
  endif()
  set(jobs "-j${jnumber}")

  message("[PID] INFO : Building ${BUILD_CMAKE_EXTERNAL_PROJECT_PROJECT} ${use_comment} in ${TARGET_MODE} mode using ${jnumber} jobs...")
  execute_process(
    COMMAND ${make_program} ${jobs} WORKING_DIRECTORY ${project_build_dir} ${OUTPUT_MODE}
    RESULT_VARIABLE result
  )
  if(NOT result EQUAL 0)#error at configuration time
    message("${process_output}")
    message("[PID] ERROR : cannot build CMake project ${BUILD_CMAKE_EXTERNAL_PROJECT_PROJECT} ${use_comment} ...")
    set(ERROR_IN_SCRIPT TRUE PARENT_SCOPE)
    return()
  endif()

  message("[PID] INFO : Installing ${BUILD_CMAKE_EXTERNAL_PROJECT_PROJECT} ${use_comment} in ${TARGET_MODE} mode...")
  execute_process(
    COMMAND ${make_program} install WORKING_DIRECTORY ${project_build_dir} ${OUTPUT_MODE}
    RESULT_VARIABLE result
  )
  if(NOT result EQUAL 0)#error at configuration time
    message("${process_output}")
    message("[PID] ERROR : cannot install CMake project ${BUILD_CMAKE_EXTERNAL_PROJECT_PROJECT} ${use_comment} ...")
    set(ERROR_IN_SCRIPT TRUE PARENT_SCOPE)
    return()
  endif()
  enforce_Standard_Install_Dirs(${TARGET_INSTALL_DIR})
  symlink_DLLs_To_Lib_Folder(${TARGET_INSTALL_DIR})
endfunction(build_CMake_External_Project)

# #.rst:
# #
# # .. ifmode:: script
# #
# #  .. |build_Bazel_External_Project| replace:: ``build_Bazel_External_Project``
# #  .. _build_Bazel_External_Project:
# #
# #  build_Bazel_External_Project
# #  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# #
# #   .. command:: build_Bazel_External_Project(PROJECT ... FOLDER ... INSTALL_PATH ... MODE ... TARGET .. [OPTIONS])
# #
# #     Configure, build and install a Bazel (google build system) external project.
# #
# #     .. rubric:: Required parameters
# #
# #     :PROJECT <string>: The name of the external project.
# #     :FOLDER <string>: The name of the folder containing the project.
# #     :INSTALL_PATH <path>: The path where the components are supposed to be found
# #     :MODE <Release|Debug>: The build mode.
# #     :TARGET <string>: The name of the target being built.
# #
# #     .. rubric:: Optional parameters
# #
# #     :MIN_VERSION: minimum version of bazel tool to use.
# #     :MAX_VERSION: maximum version of bazel tool to use.
# #     :QUIET: if used then the output of this command will be silent.
# #     :COMMENT <string>: A string to append to message to inform about special thing you are doing. Usefull if you intend to buildmultiple time the same external project with different options.
# #     :DEFINITIONS <list of definitions>: the bazel definitions (environment variables) you need to provide to the cmake build script.
# #
# #     .. admonition:: Constraints
# #        :class: warning
# #
# #        - Must be used in deploy scripts defined in a wrapper.
# #
# #     .. admonition:: Effects
# #        :class: important
# #
# #         -  Build and install the external project into workspace install tree..
# #
# #     .. rubric:: Example
# #
# #     .. code-block:: cmake
# #
# #        build_Bazel_External_Project( PROJECT tensorflow FOLDER tensorflow-1.13.1 MODE Release
# #                              COMMENT "shared libraries")
# #
# #
# function(build_Bazel_External_Project)
#   if(ERROR_IN_SCRIPT)
#     return()
#   endif()
#   set(options QUIET) #used to define the context
#   set(oneValueArgs PROJECT FOLDER MODE COMMENT MIN_VERSION MAX_VERSION INSTALL_PATH TARGET USER_JOBS)
#   set(multiValueArgs DEFINITIONS)
#   cmake_parse_arguments(BUILD_BAZEL_EXTERNAL_PROJECT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
#   if(NOT BUILD_BAZEL_EXTERNAL_PROJECT_PROJECT
#       OR NOT BUILD_BAZEL_EXTERNAL_PROJECT_FOLDER
#       OR NOT BUILD_BAZEL_EXTERNAL_PROJECT_MODE
#       OR NOT BUILD_BAZEL_EXTERNAL_PROJECT_TARGET)
#     message(FATAL_ERROR "[PID] CRITICAL ERROR : PROJECT, FOLDER, TARGET and MODE arguments are mandatory when calling build_CMake_External_Project.")
#     return()
#   endif()

#   if(BUILD_BAZEL_EXTERNAL_PROJECT_QUIET)
#     set(OUTPUT_MODE OUTPUT_QUIET)
#   endif()

#   if(BUILD_BAZEL_EXTERNAL_PROJECT_MODE STREQUAL Debug)
#     set(TARGET_MODE Debug)
#   else()
#     set(TARGET_MODE Release)
#   endif()

#   if(BUILD_BAZEL_EXTERNAL_PROJECT_COMMENT)
#     set(use_comment "(${BUILD_BAZEL_EXTERNAL_PROJECT_COMMENT}) ")
#   endif()

#   if(BUILD_BAZEL_EXTERNAL_PROJECT_MIN_VERSION OR BUILD_BAZEL_EXTERNAL_PROJECT_MAX_VERSION)#a constraint on bazel version to use
#     if(BUILD_BAZEL_EXTERNAL_PROJECT_MIN_VERSION AND BUILD_BAZEL_EXTERNAL_PROJECT_MAX_VERSION)
#       if(BUILD_BAZEL_EXTERNAL_PROJECT_MAX_VERSION VERSION_LESS_EQUAL BUILD_BAZEL_EXTERNAL_PROJECT_MIN_VERSION)
#         message(FATAL_ERROR "[PID] CRITICAL ERROR : MIN_VERSION specified is greater than MAX_VERSION constraint.")
#         return()
#       endif()
#     endif()
#     if(BUILD_BAZEL_EXTERNAL_PROJECT_MIN_VERSION)
#       find_package(Bazel ${BUILD_BAZEL_EXTERNAL_PROJECT_MIN_VERSION})
#     endif()
#     if(BAZEL_FOUND)#a version has been found
#       if(BUILD_BAZEL_EXTERNAL_PROJECT_MAX_VERSION) #but a max version constraint is defined
#         if(BAZEL_VERSION VERSION_GREATER BUILD_BAZEL_EXTERNAL_PROJECT_MAX_VERSION)#does not fit the constraints
#           message(FATAL_ERROR "[PID] CRITICAL ERROR : cannot find a bazel version compatible with MIN_VERSION and MAX_VERSION constraints.")
#           return()
#         endif()
#       endif()
#     elseif(BUILD_BAZEL_EXTERNAL_PROJECT_MAX_VERSION)#there is only a max version specified !!
#       find_package(Bazel ${BUILD_BAZEL_EXTERNAL_PROJECT_MAX_VERSION} EXACT) #use exact to avoid using greater version number
#       if(NOT BAZEL_FOUND)
#         message(FATAL_ERROR "[PID] CRITICAL ERROR : cannot find a bazel version compatible with MIN_VERSION and MAX_VERSION constraints.")
#         return()
#       endif()
#     endif()
#   else()#no version constraint so code is supposed to work with any version of bazel
#     find_package(Bazel)
#     if(NOT BAZEL_FOUND)
#       message(FATAL_ERROR "[PID] CRITICAL ERROR : cannot find bazel installed.")
#       return()
#     endif()

#   endif()

#   set(project_src_dir ${TARGET_BUILD_DIR}/${BUILD_BAZEL_EXTERNAL_PROJECT_FOLDER})
#   string(REPLACE " " ";" CMAKE_CXX_FLAGS cxx_flags_list)
#   foreach(flag IN LISTS cxx_flags_list)
#     if(flag)
#       list(APPEND bazel_build_arguments "--cxxopt ${flag}")#do not give build mode related options as they are already managed by bazel
#     endif()
#   endforeach()
#   string(REPLACE " " ";" CMAKE_CXX_FLAGS c_flags_list)
#   foreach(flag IN LISTS c_flags_list)
#     if(flag)
#       list(APPEND bazel_build_arguments "--conlyopt ${flag}")#do not give build mode related options as they are already managed by bazel
#     endif()
#   endforeach()

#   if(TARGET_MODE STREQUAL Debug)
#     list(APPEND bazel_build_arguments "--config=dbg")
#   else()
#     list(APPEND bazel_build_arguments "--config=opt")
#   endif()

#   #adding all arguments coming with the current target platform
#   # list(APPEND bazel_arguments )
#   # TODO look at possible available arguments to the bazel tool see https://docs.bazel.build/versions/master/user-manual.html
#   set(jnumber 1)
#   if(ENABLE_PARALLEL_BUILD)#parallel build is allowed from CMake configuration
#     list(FIND LIMITED_JOBS_PACKAGES ${BUILD_BAZEL_EXTERNAL_PROJECT_PROJECT} INDEX)
#     if(INDEX EQUAL -1)#package can compile with many jobs
#       if(BUILD_BAZEL_EXTERNAL_PROJECT_USER_JOBS)#the user may have put a restriction
#         set(jnumber ${BUILD_BAZEL_EXTERNAL_PROJECT_USER_JOBS})
#       else()
#         get_Environment_Info(JOBS_NUMBER jnumber)
#       endif()
#     endif()
#   endif()
#   set(jobs_opt "--jobs=${jnumber}")

#   if(NOT OUTPUT_MODE STREQUAL OUTPUT_QUIET)
#     set(failure_report "--verbose_failures")
#   endif()

#   set(used_target ${BUILD_BAZEL_EXTERNAL_PROJECT_TARGET})
#   message("[PID] INFO : Building ${BUILD_BAZEL_EXTERNAL_PROJECT_PROJECT} ${use_comment} in ${TARGET_MODE} mode using ${jnumber} jobs...")
#   execute_process(
#     COMMAND ${BAZEL_EXECUTABLE} build
#     ${failure_report} #getting info about failure
#     ${jobs_opt} #set the adequate number of jobs
#     --color no --curses yes #no need color, but nice output !
#     ${bazel_build_arguments}
#     ${BUILD_BAZEL_EXTERNAL_PROJECT_DEFINITIONS} #add specific definitions if any
#     ${used_target} #give the target name as last argument
#     WORKING_DIRECTORY ${project_src_dir} ${OUTPUT_MODE}
#     RESULT_VARIABLE result
#   )

#   if(NOT result EQUAL 0)#error at configuration time
#     message("[PID] ERROR : cannot build Bazel project ${BUILD_BAZEL_EXTERNAL_PROJECT_PROJECT} ${use_comment} ...")
#     set(ERROR_IN_SCRIPT TRUE PARENT_SCOPE)
#     return()
#   endif()

#   if(BUILD_BAZEL_EXTERNAL_PROJECT_INSTALL_PATH)
#     message("[PID] INFO : Installing ${BUILD_BAZEL_EXTERNAL_PROJECT_PROJECT} ${use_comment}in ${TARGET_MODE} mode...")
#     #need to do this "by hand", binaries first
#     set(bin_path ${project_src_dir}/${BUILD_BAZEL_EXTERNAL_PROJECT_INSTALL_PATH})
#     get_filename_component(binary_name ${BUILD_BAZEL_EXTERNAL_PROJECT_INSTALL_PATH} NAME)
#     if(NOT EXISTS ${bin_path})
#       message("[PID] ERROR : cannot find binaries generated by Bazel project ${BUILD_BAZEL_EXTERNAL_PROJECT_PROJECT} ${use_comment} ... (missing is ${bin_path})")
#       set(ERROR_IN_SCRIPT TRUE PARENT_SCOPE)
#       return()
#     endif()
#     get_Link_Type(RES_TYPE ${binary_name})
#     if(RES_TYPE STREQUAL "OPTION")#if an option it means it is not identified as a library => it is an executable in current context
#       file(COPY ${bin_path} DESTINATION ${TARGET_INSTALL_DIR}/bin)
#     else()
#       file(COPY ${bin_path} DESTINATION ${TARGET_INSTALL_DIR}/lib)
#     endif()
#   endif()

#   symlink_DLLs_To_Lib_Folder(${TARGET_INSTALL_DIR})
# endfunction(build_Bazel_External_Project)


#.rst:
#
# .. ifmode:: script
#
#  .. |get_Current_External_Version| replace:: ``get_Current_External_Version``
#  .. _get_Current_External_Version:
#
#  get_Current_External_Version
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Current_External_Version(RESULT_VERSION)
#
#     Get the version of external package that is currently built or defined
#
function(get_Current_External_Version VERSION_RESULT)
  set(${VERSION_RESULT} PARENT_SCOPE)
  if(TARGET_EXTERNAL_VERSION)#we are currently in a script
    set(${VERSION_RESULT} ${TARGET_EXTERNAL_VERSION} PARENT_SCOPE)
  else()#context of wrapper configruation
    get_filename_component(ret_version ${CMAKE_CURRENT_SOURCE_DIR} NAME)
    set(${VERSION_RESULT} ${ret_version} PARENT_SCOPE)
  endif()
endfunction(get_Current_External_Version)


#.rst:
#
# .. ifmode:: script
#
#  .. |check_External_Project_Required_CMake_Version| replace:: ``check_External_Project_Required_CMake_Version``
#  .. _check_External_Project_Required_CMake_Version:
#
#  check_External_Project_Required_CMake_Version
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: check_External_Project_Required_CMake_Version(version)
#
#     check that current version of CMake is greater than minimum version required by deployment script
#
macro(check_External_Project_Required_CMake_Version min_version)

if(CMAKE_VERSION VERSION_LESS "${min_version}")
  set(ERROR_IN_SCRIPT TRUE)
  message("[PID] ERROR: cannot execute the deployment script for ${TARGET_EXTERNAL_PACKAGE} because cmake version required by this project (${min_version}) is greater than current cmake version (${CMAKE_VERSION}). Update to a more recent version of cmake.")
  return()
endif()
endmacro(check_External_Project_Required_CMake_Version)
