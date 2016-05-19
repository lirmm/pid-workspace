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


include(Package_Internal_Definition NO_POLICY_SCOPE)
include(CMakeParseArguments)

### API : declare_PID_Package(AUTHOR main_author_name ... [INSTITUION ...] [MAIL ...] YEAR ... LICENSE license [ADDRESS address] DESCRIPTION ...)
macro(declare_PID_Package)
set(oneValueArgs LICENSE ADDRESS MAIL)
set(multiValueArgs AUTHOR INSTITUTION YEAR DESCRIPTION)
cmake_parse_arguments(DECLARE_PID_PACKAGE "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_PACKAGE_AUTHOR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an author name must be given using AUTHOR keyword.")
endif()
if(NOT DECLARE_PID_PACKAGE_YEAR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a year or year interval must be given using YEAR keyword.")
endif()
if(NOT DECLARE_PID_PACKAGE_LICENSE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a license type must be given using LICENSE keyword.")
endif()
if(NOT DECLARE_PID_PACKAGE_DESCRIPTION)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a (short) description of the package must be given using DESCRIPTION keyword.")
endif()

if(DECLARE_PID_PACKAGE_UNPARSED_ARGUMENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, unknown arguments ${DECLARE_PID_PACKAGE_UNPARSED_ARGUMENTS}.")
endif()

declare_Package(	"${DECLARE_PID_PACKAGE_AUTHOR}" "${DECLARE_PID_PACKAGE_INSTITUTION}" "${DECLARE_PID_PACKAGE_MAIL}"
			"${DECLARE_PID_PACKAGE_YEAR}" "${DECLARE_PID_PACKAGE_LICENSE}" 
			"${DECLARE_PID_PACKAGE_ADDRESS}" "${DECLARE_PID_PACKAGE_DESCRIPTION}")
endmacro(declare_PID_Package)

### API : set_PID_Package_Version(major minor [patch])
macro(set_PID_Package_Version)

if(${ARGC} EQUAL 3)
	set_Current_Version(${ARGV0} ${ARGV1} ${ARGV2})
elseif(${ARGC} EQUAL 2)
	set_Current_Version(${ARGV0} ${ARGV1} 0)
else()
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to input a major and a minor number, optionnaly you can set a patch version (considered as 0 if not set).")
endif()
endmacro(set_PID_Package_Version)

### API : add_PID_Package_Author(AUTHOR ... [INSTITUTION ...])
macro(add_PID_Package_Author)
set(multiValueArgs AUTHOR INSTITUTION)
cmake_parse_arguments(ADD_PID_PACKAGE_AUTHOR "" "" "${multiValueArgs}" ${ARGN} )
if(NOT ADD_PID_PACKAGE_AUTHOR_AUTHOR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an author name must be given using AUTHOR keyword.")
endif()
add_Author("${ADD_PID_PACKAGE_AUTHOR_AUTHOR}" "${ADD_PID_PACKAGE_AUTHOR_INSTITUTION}")
endmacro(add_PID_Package_Author)

### API : 	add_PID_Package_Reference(VERSION major.minor[.patch] PLATFORM platform name URL url-rel url_dbg)
macro(add_PID_Package_Reference)
set(oneValueArgs VERSION PLATFORM)
set(multiValueArgs  URL)
cmake_parse_arguments(ADD_PID_PACKAGE_REFERENCE "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

if(NOT ADD_PID_PACKAGE_REFERENCE_URL)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to set the urls where to find binary packages for release and debug modes, using URL <release addr> <debug addr>.")
else()
	list(LENGTH ADD_PID_PACKAGE_REFERENCE_URL SIZE)
	if(NOT SIZE EQUAL 2)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to set the urls where to find binary packages for release and debug modes using URL <release addr> <debug addr>.")
	endif()
endif()
list(GET ADD_PID_PACKAGE_REFERENCE_URL 0 URL_REL)
list(GET ADD_PID_PACKAGE_REFERENCE_URL 1 URL_DBG)

if(NOT ADD_PID_PACKAGE_REFERENCE_PLATFORM)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to set the target platform name using PLATFORM keyword.")
endif()

if(NOT ADD_PID_PACKAGE_REFERENCE_VERSION)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to input a target version number (with major and minor values, optionnaly you can also set a patch value which is considered as 0 if not set) using VERSION keyword.")
else()
	get_Version_String_Numbers(${ADD_PID_PACKAGE_REFERENCE_VERSION} MAJOR MINOR PATCH)
	if(NOT PATCH)
		add_Reference("${MAJOR}.${MINOR}.0" "${ADD_PID_PACKAGE_REFERENCE_PLATFORM}" "${URL_REL}" "${URL_DBG}")
	else()
		add_Reference("${MAJOR}.${MINOR}.${PATCH}" "${ADD_PID_PACKAGE_REFERENCE_PLATFORM}" "${URL_REL}" "${URL_DBG}")
	endif()
endif()
endmacro(add_PID_Package_Reference)

### API : add_PID_Package_Category(category_path)
macro(add_PID_Package_Category)
if(NOT ${ARGC} EQUAL 1)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the add_PID_Package_Category command requires one string argument of the form <category>[/subcategory]*.")
endif()
add_Category("${ARGV0}")
endmacro(add_PID_Package_Category)

### API : declare_PID_Documentation()
macro(declare_PID_Documentation)
set(oneValueArgs GIT_ADDRESS HOME_PAGE FRAMEWORK_NAME FRAMEWORK_PAGE SPECIFIC_CONTENT)
set(multiValueArgs DESCRIPTION)
cmake_parse_arguments(DECLARE_PID_WIKI "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_WIKI_GIT_ADDRESS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to set the repository address for the project wiki using GIT_ADDRESS keyword.")
endif()
if(NOT DECLARE_PID_WIKI_HOME_PAGE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to set the http address of the home page of this wiki using HOME_PAGE keyword.")
endif()
define_Wiki("${DECLARE_PID_WIKI_GIT_ADDRESS}" "${DECLARE_PID_WIKI_HOME_PAGE}" "${DECLARE_PID_WIKI_FRAMEWORK_NAME}" "${DECLARE_PID_WIKI_FRAMEWORK_PAGE}" "${DECLARE_PID_WIKI_SPECIFIC_CONTENT}" "${DECLARE_PID_WIKI_DESCRIPTION}")
endmacro(declare_PID_Documentation)

### API: check_PID_Platform(	NAME resulting_name
#				OS osname
#				ARCH 32 OR 64
#				[ABI CXX or CXX11]
#				[CONFIGURATION ...])
macro(check_PID_Platform)
set(oneValueArgs NAME OS ARCH ABI)
set(multiValueArgs CONFIGURATION)
cmake_parse_arguments(CHECK_PID_PLATFORM "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT CHECK_PID_PLATFORM_NAME)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to set the name you will use to manage your platform using NAME keyword.")
endif()
if(NOT CHECK_PID_PLATFORM_OS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to set the target OS of your platform using OS keyword.")
elseif((NOT CHECK_PID_PLATFORM_OS STREQUAL linux) AND (NOT CHECK_PID_PLATFORM_OS STREQUAL macosx))
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, unknown operating system ${CHECK_PID_PLATFORM_OS} (see OS argument).")
endif()

if((NOT CHECK_PID_PLATFORM_ARCH) OR (NOT CHECK_PID_PLATFORM_ARCH EQUAL 32 AND NOT CHECK_PID_PLATFORM_ARCH EQUAL 64))
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to set the target architecture (32 or 64) using ARCH keyword.")
endif()

check_Platform_Constraints(${CHECK_PID_PLATFORM_NAME} "${CHECK_PID_PLATFORM_OS}" "${CHECK_PID_PLATFORM_ARCH}" "${CHECK_PID_PLATFORM_ABI}" "${CHECK_PID_PLATFORM_CONFIGURATION}")
endmacro(check_PID_Platform)

### API: check_All_PID_Default_Platforms([CONFIGURATION list of system constraints])
macro(check_All_PID_Default_Platforms)
set(multiValueArgs CONFIGURATION)
cmake_parse_arguments(CHECK_ALL_PID_DEFAULT_PLATFORM "" "" "${multiValueArgs}" ${ARGN} )
create_Default_Platforms_Set("${CHECK_ALL_PID_DEFAULT_PLATFORM_CONFIGURATION}")
endmacro(check_All_PID_Default_Platforms)

### API : build_PID_Package()
macro(build_PID_Package)
if(${ARGC} GREATER 0)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the build_PID_Package command requires no arguments.")
endif()
build_Package()
endmacro(build_PID_Package)

### API : declare_PID_Component(NAME name 
#				DIRECTORY dirname 
#				<STATIC_LIB|SHARED_LIB|MODULE_LIB|HEADER_LIB|APPLICATION|EXAMPLE_APPLICATION|TEST_APPLICATION> 
#				[INTERNAL [DEFINITIONS def ...] [INCLUDE_DIRS dir ...] [COMPILER_OPTIONS ...] [LINKS link ...] ] 
#				[EXPORTED [DEFINITIONS def ...] [COMPILER_OPTIONS ...] [LINKS link ...] 
#				[RUNTIME_RESOURCES <some path to files in the share/resources dir>]
#				[DESCRIPTION short description of the utility of this component]
#				[USAGE includes...])
macro(declare_PID_Component)
set(options STATIC_LIB SHARED_LIB MODULE_LIB HEADER_LIB APPLICATION EXAMPLE_APPLICATION TEST_APPLICATION)
set(oneValueArgs NAME DIRECTORY)
set(multiValueArgs INTERNAL EXPORTED RUNTIME_RESOURCES DESCRIPTION USAGE)
cmake_parse_arguments(DECLARE_PID_COMPONENT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(DECLARE_PID_COMPONENT_UNPARSED_ARGUMENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, unknown arguments ${DECLARE_PID_COMPONENT_UNPARSED_ARGUMENTS}.")
endif()

if(NOT DECLARE_PID_COMPONENT_NAME)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name must be given to the component using NAME keyword.")
endif()
if(NOT DECLARE_PID_COMPONENT_DIRECTORY)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a source directory must be given using DIRECTORY keyword.")
endif()
set(nb_options 0)
if(DECLARE_PID_COMPONENT_STATIC_LIB)
	math(EXPR nb_options "${nb_options}+1")
	set(type "STATIC")
endif()
if(DECLARE_PID_COMPONENT_SHARED_LIB)
	math(EXPR nb_options "${nb_options}+1")
	set(type "SHARED")
endif()
if(DECLARE_PID_COMPONENT_MODULE_LIB)
	math(EXPR nb_options "${nb_options}+1")
	set(type "MODULE")
endif()
if(DECLARE_PID_COMPONENT_HEADER_LIB)
	math(EXPR nb_options "${nb_options}+1")
	set(type "HEADER")
endif()
if(DECLARE_PID_COMPONENT_APPLICATION)
	math(EXPR nb_options "${nb_options}+1")
	set(type "APP")
endif()
if(DECLARE_PID_COMPONENT_EXAMPLE_APPLICATION)
	math(EXPR nb_options "${nb_options}+1")
	set(type "EXAMPLE")
endif()
if(DECLARE_PID_COMPONENT_TEST_APPLICATION)
	math(EXPR nb_options "${nb_options}+1")
	set(type "TEST")
endif()
if(NOT nb_options EQUAL 1)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, only one type among (STATIC_LIB, SHARED_LIB, MODULE_LIB, HEADER_LIB, APPLICATION, EXAMPLE_APPLICATION|TEST_APPLICATION) must be given for the component.")
endif()

set(internal_defs "")
set(internal_inc_dirs "")
set(internal_link_flags "")
if(DECLARE_PID_COMPONENT_INTERNAL)
	if(DECLARE_PID_COMPONENT_INTERNAL STREQUAL "")
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, INTERNAL keyword must be followed by by at least one DEFINITION OR INCLUDE_DIR OR LINK keyword and related arguments.")
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
			message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, ${type} libraries cannot define internal linker flags.")
		endif()
		set(internal_link_flags ${DECLARE_PID_COMPONENT_INTERNAL_LINKS})
	endif()
endif()

set(exported_defs "")
if(DECLARE_PID_COMPONENT_EXPORTED)
	if(type MATCHES APP OR type MATCHES EXAMPLE OR type MATCHES TEST)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, applications cannot export anything (invalid use of the EXPORT keyword).")
	elseif(type MATCHES MODULE)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, module librairies cannot export anything (invalid use of the EXPORT keyword).")
	endif()
	if(DECLARE_PID_COMPONENT_EXPORTED STREQUAL "")
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, EXPORTED keyword must be followed by at least one DEFINITIONS OR LINKS keyword and related arguments.")
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

if(type MATCHES "APP" OR type MATCHES "EXAMPLE" OR type MATCHES "TEST")
	declare_Application_Component(	${DECLARE_PID_COMPONENT_NAME} 
					${DECLARE_PID_COMPONENT_DIRECTORY} 
					${type} 
					"${internal_inc_dirs}" 
					"${internal_defs}" 
					"${internal_compiler_options}"
					"${internal_link_flags}"
					"${runtime_resources}")
else() #it is a library
	declare_Library_Component(	${DECLARE_PID_COMPONENT_NAME} 
					${DECLARE_PID_COMPONENT_DIRECTORY} 
					${type} 
					"${internal_inc_dirs}"
					"${internal_defs}"
					"${internal_compiler_options}"
					"${exported_defs}" 
					"${exported_compiler_options}"
					"${internal_link_flags}"
					"${exported_link_flags}"
					"${runtime_resources}")
endif()
if(NOT "${DECLARE_PID_COMPONENT_DESCRIPTION}" STREQUAL "")
	init_Component_Description(${DECLARE_PID_COMPONENT_NAME} "${DECLARE_PID_COMPONENT_DESCRIPTION}" "${DECLARE_PID_COMPONENT_USAGE}")
endif()
endmacro(declare_PID_Component)

### API : declare_PID_Package_Dependency (	PACKAGE name 
#						<EXTERNAL VERSION version_string [EXACT] | NATIVE VERSION major minor [EXACT] >
#						[COMPONENTS component ...])
macro(declare_PID_Package_Dependency)
set(options EXTERNAL NATIVE)
set(oneValueArgs PACKAGE)
cmake_parse_arguments(DECLARE_PID_DEPENDENCY "${options}" "${oneValueArgs}" "" ${ARGN} )
if(NOT DECLARE_PID_DEPENDENCY_PACKAGE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name must be given to the required package using PACKAGE keywork.")
endif()

if(DECLARE_PID_DEPENDENCY_EXTERNAL AND DECLARE_PID_DEPENDENCY_NATIVE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the type of the required package must be EXTERNAL or NATIVE, not both.")
elseif(DECLARE_PID_DEPENDENCY_EXTERNAL)
	set(exact FALSE)
	if(DECLARE_PID_DEPENDENCY_UNPARSED_ARGUMENTS)
		set(oneValueArgs VERSION)
		set(options EXACT)
		set(multiValueArgs COMPONENTS)
		cmake_parse_arguments(DECLARE_PID_DEPENDENCY_EXTERNAL "${options}" "${oneValueArgs}" "${multiValueArgs}" ${DECLARE_PID_DEPENDENCY_UNPARSED_ARGUMENTS})
		if(DECLARE_PID_DEPENDENCY_EXTERNAL_EXACT)
			set(exact TRUE)			
			if(NOT DECLARE_PID_DEPENDENCY_EXTERNAL_VERSION)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must use the EXACT keyword together with the VERSION keyword.")
			endif()
		endif()
		if(DECLARE_PID_DEPENDENCY_EXTERNAL_COMPONENTS)
			list(LENGTH DECLARE_PID_DEPENDENCY_EXTERNAL_COMPONENTS SIZE)
			if(SIZE LESS 1)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, at least one component dependency must be defined when using the COMPONENTS keyword.")
			endif()
		endif()
	endif()
	declare_External_Package_Dependency(${DECLARE_PID_DEPENDENCY_PACKAGE} "${DECLARE_PID_DEPENDENCY_EXTERNAL_VERSION}" "${exact}" "${DECLARE_PID_DEPENDENCY_EXTERNAL_COMPONENTS}")
elseif(DECLARE_PID_DEPENDENCY_NATIVE)
	if(DECLARE_PID_DEPENDENCY_UNPARSED_ARGUMENTS)
		set(options EXACT)
		set(multiValueArgs VERSION COMPONENTS)
		cmake_parse_arguments(DECLARE_PID_DEPENDENCY_NATIVE "${options}" "" "${multiValueArgs}" ${DECLARE_PID_DEPENDENCY_UNPARSED_ARGUMENTS})
		if(DECLARE_PID_DEPENDENCY_PID_UNPARSED_ARGUMENTS)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, there are some unknown arguments ${DECLARE_PID_DEPENDENCY_NATIVE_UNPARSED_ARGUMENTS}.")
		endif()

		set(exact FALSE)
		if(DECLARE_PID_DEPENDENCY_NATIVE_VERSION)
			list(LENGTH DECLARE_PID_DEPENDENCY_NATIVE_VERSION SIZE)
			if(SIZE EQUAL 2)#it is a version string decomposed into a major and a minor number
				list(GET DECLARE_PID_DEPENDENCY_NATIVE_VERSION 0 MAJOR)
				list(GET DECLARE_PID_DEPENDENCY_NATIVE_VERSION 1 MINOR)
				set(VERS_NUMB "${MAJOR}.${MINOR}")
			elseif(SIZE EQUAL 1)#it is a complete version string
				set(VERS_NUMB "${DECLARE_PID_DEPENDENCY_NATIVE_VERSION}")
			else()
				message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you need to input a major and a minor number.")
			endif()
			if(DECLARE_PID_DEPENDENCY_NATIVE_EXACT)
				set(exact TRUE)
			endif()

		else()
			set(VERS_NUMB "")
		endif()
	
		if(DECLARE_PID_DEPENDENCY_NATIVE_COMPONENTS)
			list(LENGTH DECLARE_PID_DEPENDENCY_NATIVE_COMPONENTS SIZE)
			if(SIZE LESS 1)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, at least one component dependency must be defined when using COMPONENTS keyword.")
			endif()
		endif()
		declare_Package_Dependency(${DECLARE_PID_DEPENDENCY_PACKAGE} "${VERS_NUMB}" ${exact} "${DECLARE_PID_DEPENDENCY_NATIVE_COMPONENTS}")
	else()
		declare_Package_Dependency(${DECLARE_PID_DEPENDENCY_PACKAGE} "" FALSE "")
	endif()
	
endif()
endmacro(declare_PID_Package_Dependency)


### API : declare_PID_Component_Dependency (	COMPONENT name
#						[EXPORT] 
#						<DEPEND|NATIVE dep_component [PACKAGE dep_package] 
#						| [EXTERNAL ext_package INCLUDE_DIRS dir ... RUNTIME_RESOURCES ...] LINKS [STATIC link ...] [SHARED link ...]>
#						[INTERNAL_DEFINITIONS def ...]
#						[IMPORTED_DEFINITIONS def ...]
#						[EXPORTED_DEFINITIONS def ...]
#						
#						)
macro(declare_PID_Component_Dependency)
set(options EXPORT)
set(oneValueArgs COMPONENT DEPEND NATIVE PACKAGE EXTERNAL)
set(multiValueArgs INCLUDE_DIRS LINKS COMPILER_OPTIONS INTERNAL_DEFINITIONS IMPORTED_DEFINITIONS EXPORTED_DEFINITIONS RUNTIME_RESOURCES)
cmake_parse_arguments(DECLARE_PID_COMPONENT_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, unknown arguments ${DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS}.")
endif()
if(NOT DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name must be given to the component that declare the dependency using COMPONENT keyword.")
endif()
set(export FALSE)
if(DECLARE_PID_COMPONENT_DEPENDENCY_EXPORT)
	set(export TRUE)
endif()

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
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the LINKS option argument must be followed only by static and/or shared links.")
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

if(DECLARE_PID_COMPONENT_DEPENDENCY_DEPEND OR DECLARE_PID_COMPONENT_DEPENDENCY_NATIVE)
	if(DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, keywords EXTERNAL (requiring an external package) and NATIVE (or DEPEND) (requiring a PID component) cannot be used simultaneously.")
	endif()
	if(DECLARE_PID_COMPONENT_DEPENDENCY_DEPEND)
		set(target_component ${DECLARE_PID_COMPONENT_DEPENDENCY_DEPEND})
	else()
		set(target_component ${DECLARE_PID_COMPONENT_DEPENDENCY_NATIVE})
	endif()
	if(DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE)#package dependency
		declare_Package_Component_Dependency(
					${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT} 
					${DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE} 
					${target_component}
					${export}
					"${comp_defs}" 
					"${comp_exp_defs}"
					"${dep_defs}"
					)
	else()#internal dependency
		declare_Internal_Component_Dependency(
					${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}
					${target_component} 
					${export}
					"${comp_defs}" 
					"${comp_exp_defs}"
					"${dep_defs}"
					)
	endif()

elseif(DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL)#external dependency

	declare_External_Component_Dependency(
				${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}
				${DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL} 
				${export} 
				"${DECLARE_PID_COMPONENT_DEPENDENCY_INCLUDE_DIRS}"
				"${comp_defs}" 
				"${comp_exp_defs}"
				"${dep_defs}"
				"${compiler_options}"
				"${static_links}"
				"${shared_links}"
				"${DECLARE_PID_COMPONENT_DEPENDENCY_RUNTIME_RESOURCES}")
else()#system dependency

	declare_System_Component_Dependency(
			${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}
			${export}
			"${DECLARE_PID_COMPONENT_DEPENDENCY_INCLUDE_DIRS}"
			"${comp_defs}" 
			"${comp_exp_defs}"
			"${dep_defs}"
			"${compiler_options}"
			"${static_links}"
			"${shared_links}"
			"${DECLARE_PID_COMPONENT_DEPENDENCY_RUNTIME_RESOURCES}")
endif()
endmacro(declare_PID_Component_Dependency)


### API : run_PID_Test (NAME 			test_name
#			<EXE name | COMPONENT 	name [PACKAGE name]>
#			ARGUMENTS	 	list_of_args
#			)
macro(run_PID_Test)
set(oneValueArgs NAME EXE COMPONENT PACKAGE)
set(multiValueArgs ARGUMENTS)
cmake_parse_arguments(RUN_PID_TEST "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(RUN_PID_TEST_UNPARSED_ARGUMENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, unknown arguments ${DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS}.")
endif()
if(NOT RUN_PID_TEST_NAME)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name must be given to the test (using NAME <name> syntax) !")
endif()

if(NOT RUN_PID_TEST_EXE AND NOT RUN_PID_TEST_COMPONENT)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an executable must be defined. Using EXE you can use an executable present on your system or by using COMPONENT. In this later case you must specify a PID executable component. If the PACKAGE keyword is used then this component will be found in another package than the current one.")
endif()

if(RUN_PID_TEST_EXE AND RUN_PID_TEST_COMPONENT)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must use either a system executable (using EXE keyword) OR a PID application component (using COMPONENT keyword).")
endif()

if(RUN_PID_TEST_EXE)
	add_test("${RUN_PID_TEST_NAME}" "${RUN_PID_TEST_EXE}" ${RUN_PID_TEST_ARGUMENTS})
else()#RUN_PID_TEST_COMPONENT
	if(RUN_PID_TEST_PACKAGE)#component coming from another PID package
		set(target_of_test ${RUN_PID_TEST_PACKAGE}-${RUN_PID_TEST_COMPONENT})
		add_test(${RUN_PID_TEST_NAME} ${target_of_test} ${RUN_PID_TEST_ARGUMENTS})
	else()#internal component
		
		add_test(${RUN_PID_TEST_NAME} ${RUN_PID_TEST_COMPONENT} ${RUN_PID_TEST_ARGUMENTS})
	endif()
endif()

endmacro(run_PID_Test)


### API : external_PID_Package_Path (NAME external_package PATH result)
macro(external_PID_Package_Path)
set(oneValueArgs NAME PATH)
cmake_parse_arguments(EXT_PACKAGE_PATH "" "${oneValueArgs}" "" ${ARGN} )
if(NOT EXT_PACKAGE_PATH_NAME OR NOT EXT_PACKAGE_PATH_PATH)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name of an external package must be provided with name and a variable containing the resulting path must be set with PATH keyword.")
endif()
set(${EXT_PACKAGE_PATH_PATH})
is_External_Package_Defined(${PROJECT_NAME} "${EXT_PACKAGE_PATH_NAME}" ${CMAKE_BUILD_TYPE} ${EXT_PACKAGE_PATH_PATH})

endmacro(external_PID_Package_Path)


### API : create_PID_Install_Symlink (PATH where_to_create NAME symlink_name TARGET target_of_symlink)
macro(create_PID_Install_Symlink)
set(oneValueArgs NAME PATH TARGET)
cmake_parse_arguments(CREATE_INSTALL_SYMLINK "" "${oneValueArgs}" "" ${ARGN} )
if(NOT CREATE_INSTALL_SYMLINK_NAME OR NOT CREATE_INSTALL_SYMLINK_PATH OR NOT CREATE_INSTALL_SYMLINK_TARGET)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name for the new symlink created must be provided with NAME keyword, the path relative to its install location must be provided with PATH keyword and the target of the symlink must be provided with TARGET keyword.")
endif()
set(FULL_INSTALL_PATH ${CMAKE_INSTALL_PREFIX}/${${PROJECT_NAME}_DEPLOY_PATH}/${CREATE_INSTALL_SYMLINK_PATH})
set( link   ${CREATE_INSTALL_SYMLINK_NAME})
set( target ${CREATE_INSTALL_SYMLINK_TARGET})

add_custom_target(install_symlink_${link} ALL
        COMMAND ${CMAKE_COMMAND} -E remove -f ${FULL_INSTALL_PATH}/${link}
	COMMAND ${CMAKE_COMMAND} -E chdir ${FULL_INSTALL_PATH} ${CMAKE_COMMAND} -E  create_symlink ${target} ${link})

endmacro(create_PID_Install_Symlink)

