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


include(PID_Package_API_Internal_Functions NO_POLICY_SCOPE)
include(CMakeParseArguments)

### API : declare_PID_Package(AUTHOR main_author_name ... [INSTITUION ...] [MAIL ...] YEAR ... LICENSE license [ADDRESS address] DESCRIPTION ...)
macro(declare_PID_Package)
set(oneValueArgs LICENSE ADDRESS MAIL PUBLIC_ADDRESS)
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

if(NOT DECLARE_PID_PACKAGE_ADDRESS AND DECLARE_PID_PACKAGE_PUBLIC_ADDRESS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the package must have an adress if a public access adress is declared.")
endif()

declare_Package(	"${DECLARE_PID_PACKAGE_AUTHOR}" "${DECLARE_PID_PACKAGE_INSTITUTION}" "${DECLARE_PID_PACKAGE_MAIL}"
			"${DECLARE_PID_PACKAGE_YEAR}" "${DECLARE_PID_PACKAGE_LICENSE}"
			"${DECLARE_PID_PACKAGE_ADDRESS}" "${DECLARE_PID_PACKAGE_PUBLIC_ADDRESS}"
			"${DECLARE_PID_PACKAGE_DESCRIPTION}")
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
	#manage PID v1 API way of doing
	platform_Exist(IS_EXISTING ${ADD_PID_PACKAGE_REFERENCE_PLATFORM})
	if (NOT IS_EXISTING)
		platform_Exist(IS_EXISTING "${${ADD_PID_PACKAGE_REFERENCE_PLATFORM}}")#take the value of the name instead of the direct name
		if (NOT IS_EXISTING)
			message("[PID] WARNING: unknown target platform ${ADD_PID_PACKAGE_REFERENCE_PLATFORM} when adding reference. Please look into ${WORKSPACE_DIR}/share/cmake/platforms/ to find all predefined platforms or eventually create your own new one and place it in this folder. The references to binaries using ${platform} will be ignored.") #just do this as a warning to enable compatiblity with V1 style references
			set(TARGET_PLATFORM_FOR_REFERENCE)
		else()
			set(TARGET_PLATFORM_FOR_REFERENCE ${${ADD_PID_PACKAGE_REFERENCE_PLATFORM}})
		endif()
	else()
		set(TARGET_PLATFORM_FOR_REFERENCE ${ADD_PID_PACKAGE_REFERENCE_PLATFORM})
	endif()

	if(TARGET_PLATFORM_FOR_REFERENCE)#target platform cannot be determined
		if(NOT PATCH)
			add_Reference("${MAJOR}.${MINOR}.0" "${TARGET_PLATFORM_FOR_REFERENCE}" "${URL_REL}" "${URL_DBG}")
		else()
			add_Reference("${MAJOR}.${MINOR}.${PATCH}" "${TARGET_PLATFORM_FOR_REFERENCE}" "${URL_REL}" "${URL_DBG}")
		endif()
	endif()#otherwise simply do not add the reference, cannot resolve with new platform naming standard
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
	message("[PID] WARNING : the declare_PID_Documentation is deprecated and is no more used in PID version 2. To define a documentation site please use declare_PID_Publishing function. Skipping documentation generation phase.")
endmacro(declare_PID_Documentation)

### API : declare_PID_Publishing()
macro(declare_PID_Publishing)
set(optionArgs PUBLISH_BINARIES PUBLISH_DEVELOPMENT_INFO)
set(oneValueArgs PROJECT FRAMEWORK GIT PAGE ADVANCED TUTORIAL LOGO)
set(multiValueArgs DESCRIPTION ALLOWED_PLATFORMS)
cmake_parse_arguments(DECLARE_PID_DEPLOYMENT "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(NOT DECLARE_PID_DEPLOYMENT_PROJECT)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell where to find the project page of the official package repository using PROJECT keyword.")
endif()

if(NOT DECLARE_PID_DEPLOYMENT_FRAMEWORK AND NOT DECLARE_PID_DEPLOYMENT_GIT)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell either where to find the repository of the package's static site (using GIT keyword) or to which framework the package contributes to (using FRAMEWORK keyword).")
endif()
if(DECLARE_PID_DEPLOYMENT_FRAMEWORK)
	define_Framework_Contribution("${DECLARE_PID_DEPLOYMENT_FRAMEWORK}" "${DECLARE_PID_DEPLOYMENT_PROJECT}" "${DECLARE_PID_DEPLOYMENT_DESCRIPTION}")
else()#DECLARE_PID_DEPLOYMENT_HOME
	if(NOT DECLARE_PID_DEPLOYMENT_PAGE)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must tell where to find the index page for the static site of the package (using PAGE keyword).")
	endif()
	define_Static_Site_Contribution("${DECLARE_PID_DEPLOYMENT_PROJECT}" "${DECLARE_PID_DEPLOYMENT_GIT}" "${DECLARE_PID_DEPLOYMENT_PAGE}" "${DECLARE_PID_DEPLOYMENT_DESCRIPTION}")
endif()

#manage publication of binaries
if(DECLARE_PID_DEPLOYMENT_ALLOWED_PLATFORMS)
	foreach(platform IN ITEMS ${DECLARE_PID_DEPLOYMENT_ALLOWED_PLATFORMS})
		restrict_CI(${platform})
	endforeach()
endif()

#manage publication of binaries
if(DECLARE_PID_DEPLOYMENT_PUBLISH_BINARIES)
	publish_Binaries(TRUE)
else()
	publish_Binaries(FALSE)
endif()

#manage publication of information for developpers
if(DECLARE_PID_DEPLOYMENT_PUBLISH_DEVELOPMENT_INFO)
	publish_Development_Info(TRUE)
else()
	publish_Development_Info(FALSE)
endif()

#user defined doc
if(DECLARE_PID_DEPLOYMENT_ADVANCED)
	define_Documentation_Content(advanced "${DECLARE_PID_DEPLOYMENT_ADVANCED}")
else()
	define_Documentation_Content(advanced FALSE)
endif()
if(DECLARE_PID_DEPLOYMENT_TUTORIAL)
	define_Documentation_Content(tutorial "${DECLARE_PID_DEPLOYMENT_TUTORIAL}")
else()
	define_Documentation_Content(tutorial FALSE)
endif()
if(DECLARE_PID_DEPLOYMENT_LOGO)
	define_Documentation_Content(logo "${DECLARE_PID_DEPLOYMENT_LOGO}")
else()
	define_Documentation_Content(logo FALSE)
endif()
endmacro(declare_PID_Publishing)

### API : declare_PID_Component_Documentation()
macro(declare_PID_Component_Documentation)
set(oneValueArgs COMPONENT FILE)
cmake_parse_arguments(DECLARE_PID_COMPONENT_DOCUMENTATION "" "${oneValueArgs}" "" ${ARGN} )
if(NOT DECLARE_PID_COMPONENT_DOCUMENTATION_FILE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must define the file or folder that contains specific documentation content for the project using FILE keyword.")
endif()
if(NOT DECLARE_PID_COMPONENT_DOCUMENTATION_COMPONENT)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, you must define a component name for this content using COMPONENT keyword.")
endif()
#user defined doc for a given component
define_Component_Documentation_Content(${DECLARE_PID_COMPONENT_DOCUMENTATION_COMPONENT} "${DECLARE_PID_COMPONENT_DOCUMENTATION_FILE}")
endmacro(declare_PID_Component_Documentation)

### API: check_PID_Platform(	[NAME resulting_name] is obsolete
#				[TYPE x86 or arm]
#				[OS osname]
#				[ARCH 16 OR 32 OR 64]
#				[ABI CXX or CXX11]
#				CONFIGURATION ...)
macro(check_PID_Platform)
set(oneValueArgs NAME OS ARCH ABI TYPE)
set(multiValueArgs CONFIGURATION)
cmake_parse_arguments(CHECK_PID_PLATFORM "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(CHECK_PID_PLATFORM_NAME)
	message("[PID] WARNING : NAME is a deprecated argument. Platforms are now defined at workspace level and this macro now check if the current platform satisfies configuration constraints according to the optionnal conditions specified by TYPE, ARCH, OS and ABI. The only constraints that will be checked are those for which the current platform satisfies the conditions.")
	if(NOT CHECK_PID_PLATFORM_OS)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you must define at least an OS when using the deprecated NAME keyword")
	else()
		list(FIND WORKSPACE_ALL_OS ${CHECK_PID_PLATFORM_OS} INDEX)
		if(INDEX EQUAL -1)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : ${CHECK_PID_PLATFORM_OS} is a bad value for argument OS. Use a valid operating system description string like xenomai, linux or macosx.")
		endif()
	endif()
	if(NOT CHECK_PID_PLATFORM_ARCH)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you must define at least an ARCH when using the deprecated NAME keyword")
	else()
		list(FIND WORKSPACE_ALL_ARCH ${CHECK_PID_PLATFORM_ARCH} INDEX)
		if(INDEX EQUAL -1)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : ${CHECK_PID_PLATFORM_ARCH} is a bad value for argument ARCH. Use a value like 16, 32 or 64.")
		endif()
	endif()
	check_Platform_Constraints(RESULT IS_CURRENT "" "${CHECK_PID_PLATFORM_ARCH}" "${CHECK_PID_PLATFORM_OS}" "${CHECK_PID_PLATFORM_ABI}" "${CHECK_PID_PLATFORM_CONFIGURATION}") #no type as it was not managed with PID v1
	set(${CHECK_PID_PLATFORM_NAME} ${IS_CURRENT})
	if(IS_CURRENT AND NOT RESULT)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: when calling check_PID_Platform, constraint cannot be satisfied !")
	endif()

else()
	if(NOT CHECK_PID_PLATFORM_CONFIGURATION)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you must use the CONFIGURATION keyword to describe the set of configuration constraints that apply to the current platform.")
	endif()
	if(CHECK_PID_PLATFORM_TYPE)
		list(FIND WORKSPACE_ALL_TYPE ${CHECK_PID_PLATFORM_TYPE} INDEX)
		if(INDEX EQUAL -1)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : ${CHECK_PID_PLATFORM_TYPE} is a bad value for argument TYPE. Use a valid processor type like x86 or arm.")
		endif()
	endif()
	if(CHECK_PID_PLATFORM_OS)
		list(FIND WORKSPACE_ALL_OS ${CHECK_PID_PLATFORM_OS} INDEX)
		if(INDEX EQUAL -1)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : ${CHECK_PID_PLATFORM_OS} is a bad value for argument OS. Use a valid operating system description string like xenomai, linux or macosx.")
		endif()
	endif()
	if(CHECK_PID_PLATFORM_ARCH)
		list(FIND WORKSPACE_ALL_ARCH ${CHECK_PID_PLATFORM_ARCH} INDEX)
		if(INDEX EQUAL -1)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : ${CHECK_PID_PLATFORM_ARCH} is a bad value for argument ARCH. Use a value like 16, 32 or 64.")
		endif()
	endif()
	if(CHECK_PID_PLATFORM_ABI)
		list(FIND WORKSPACE_ALL_ABI ${CHECK_PID_PLATFORM_ABI} INDEX)
		if(INDEX EQUAL -1)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : ${CHECK_PID_PLATFORM_ABI} is a bad value for argument ABI. Use a value like CXX or CXX11.")
		endif()
	endif()
	#checking the constraints
	check_Platform_Constraints(RESULT IS_CURRENT "${CHECK_PID_PLATFORM_TYPE}" "${CHECK_PID_PLATFORM_ARCH}" "${CHECK_PID_PLATFORM_OS}" "${CHECK_PID_PLATFORM_ABI}" "${CHECK_PID_PLATFORM_CONFIGURATION}")
	if(NOT RESULT)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: when calling check_PID_Platform, constraint cannot be satisfied !")
	endif()
endif()
endmacro(check_PID_Platform)

### API: get_PID_Platform_Info([TYPE res_type] [OS res_os] [ARCH res_arch] [ABI res_abi])
function(get_PID_Platform_Info)
set(oneValueArgs NAME OS ARCH ABI TYPE)
set(multiValueArgs CONFIGURATION)
cmake_parse_arguments(GET_PID_PLATFORM_INFO "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
set(OK FALSE)
if(GET_PID_PLATFORM_INFO_NAME)
	set(OK TRUE)
	set(${GET_PID_PLATFORM_INFO_NAME} ${CURRENT_PLATFORM} PARENT_SCOPE)
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
if(NOT OK)
	message("[PID] ERROR : you must use one or more of the NAME, TYPE, ARCH, OS or ABI keywords together with corresponding variables that will contain the resulting property of the current platform in use.")
endif()
endfunction(get_PID_Platform_Info)

### API: check_All_PID_Default_Platforms([CONFIGURATION] list of system constraints). Same as previously but without any condition
macro(check_All_PID_Default_Platforms)
set(multiValueArgs CONFIGURATION)
message("[PID] WARNING : the check_All_PID_Default_Platforms function is deprecated as check_PID_Platform will now do the job equaly well.")

check_PID_Platform(NAME linux64 OS linux ARCH 64 ABI CXX)
check_PID_Platform(NAME linux32 OS linux ARCH 32 ABI CXX)
check_PID_Platform(NAME linux64cxx11 OS linux ARCH 64 ABI CXX11)
check_PID_Platform(NAME macosx64 OS macosx ARCH 64 ABI CXX)

cmake_parse_arguments(CHECK_PID_PLATFORM "" "" "${multiValueArgs}" ${ARGN} )

if(CHECK_PID_PLATFORM_CONFIGURATION)
	check_Platform_Constraints(RESULT IS_CURRENT "" "" "" "" "${CHECK_PID_PLATFORM_CONFIGURATION}")
	if(NOT RESULT)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling check_All_PID_Default_Platforms, the current platform dos not satisfy configuration constraints.")
	endif()
endif()
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
set(oneValueArgs NAME DIRECTORY C_STANDARD CXX_STANDARD)
set(multiValueArgs INTERNAL EXPORTED RUNTIME_RESOURCES DESCRIPTION USAGE)
cmake_parse_arguments(DECLARE_PID_COMPONENT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(DECLARE_PID_COMPONENT_UNPARSED_ARGUMENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, unknown arguments ${DECLARE_PID_COMPONENT_UNPARSED_ARGUMENTS}.")
endif()

if(DECLARE_PID_COMPONENT_C_STANDARD)
	set(c_language_standard ${DECLARE_PID_COMPONENT_C_STANDARD})
	if(	NOT c_language_standard EQUAL 90
	AND NOT c_language_standard EQUAL 99
	AND NOT c_language_standard EQUAL 11)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad C_STANDARD argument, the value used must be 90, 99 or 11.")
	endif()
else() #default language standard is first standard
	set(c_language_standard 90)
endif()

if(DECLARE_PID_COMPONENT_CXX_STANDARD)
	set(cxx_language_standard ${DECLARE_PID_COMPONENT_CXX_STANDARD})
	if(	NOT cxx_language_standard EQUAL 98
	AND NOT cxx_language_standard EQUAL 11
	AND NOT cxx_language_standard EQUAL 14
	AND NOT cxx_language_standard EQUAL 17 )
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad CXX_STANDARD argument, the value used must be 98, 11, 14 or 17.")
	endif()
else() #default language standard is first standard
	set(cxx_language_standard 98)
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

#check unique names
set(DECLARED FALSE)
is_Declared(${DECLARE_PID_COMPONENT_NAME} DECLARED)
if(DECLARED)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : a component with the same name than ${DECLARE_PID_COMPONENT_NAME} is already defined.")
	return()
endif()
unset(DECLARED)

if(type MATCHES "APP" OR type MATCHES "EXAMPLE" OR type MATCHES "TEST")
	declare_Application_Component(	${DECLARE_PID_COMPONENT_NAME}
					${DECLARE_PID_COMPONENT_DIRECTORY}
					${type}
					"${c_language_standard}"
					"${cxx_language_standard}"
					"${internal_inc_dirs}"
					"${internal_defs}"
					"${internal_compiler_options}"
					"${internal_link_flags}"
					"${runtime_resources}")
else() #it is a library
	declare_Library_Component(	${DECLARE_PID_COMPONENT_NAME}
					${DECLARE_PID_COMPONENT_DIRECTORY}
					${type}
					"${c_language_standard}"
					"${cxx_language_standard}"
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

function(parse_Package_Dependency_Version_Arguments args RES_VERSION RES_EXACT RES_UNPARSED)
set(full_string)
string(REGEX REPLACE "^(EXACT;VERSION;[^;]+;?).*$" "\\1" RES "${args}")
if(RES STREQUAL "${args}")
	string(REGEX REPLACE "^(VERSION;[^;]+;?).*$" "\\1" RES "${args}")
	if(NOT full_string STREQUAL "${args}")#there is a match => there is a version specified
		set(full_string ${RES})
	endif()
else()#there is a match => there is a version specified
	set(full_string ${RES})
endif()
if(full_string)#version expression has been found => parse it
	set(options EXACT)
	set(oneValueArg VERSION)
	cmake_parse_arguments(PARSE_PACKAGE_ARGS "${options}" "${oneValueArg}" "" ${full_string})
	set(${RES_VERSION} ${PARSE_PACKAGE_ARGS_VERSION} PARENT_SCOPE)
	set(${RES_EXACT} ${PARSE_PACKAGE_ARGS_EXACT} PARENT_SCOPE)

	#now extracting unparsed
	string(LENGTH "${full_string}" PARSED_SIZE)
	string(LENGTH "${args}" TOTAL_SIZE)

	if(PARSED_SIZE EQUAL TOTAL_SIZE)
		set(${RES_UNPARSED} PARENT_SCOPE)
	else()
		string(SUBSTRING "${args}" ${PARSED_SIZE} -1 UNPARSED_STRING)
		set(${RES_UNPARSED} ${UNPARSED_STRING} PARENT_SCOPE)
	endif()

else()
	set(${RES_VERSION} PARENT_SCOPE)
	set(${RES_EXACT} PARENT_SCOPE)
	set(${RES_UNPARSED} "${args}" PARENT_SCOPE)
endif()
endfunction(parse_Package_Dependency_Version_Arguments)

### API : declare_PID_Package_Dependency (	PACKAGE name
#						<EXTERNAL VERSION version_string [EXACT] | NATIVE [VERSION major[.minor] [EXACT]]] >
#						[COMPONENTS component ...])
macro(declare_PID_Package_Dependency)
set(options EXTERNAL NATIVE OPTIONAL)
set(oneValueArgs PACKAGE)
cmake_parse_arguments(DECLARE_PID_DEPENDENCY "${options}" "${oneValueArgs}" "" ${ARGN} )
if(NOT DECLARE_PID_DEPENDENCY_PACKAGE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name must be given to the required package using PACKAGE keywork.")
endif()
if(DECLARE_PID_DEPENDENCY_PACKAGE STREQUAL PROJECT_NAME)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, package ${DECLARE_PID_DEPENDENCY_PACKAGE} cannot require itself !")
endif()
if(DECLARE_PID_DEPENDENCY_EXTERNAL AND DECLARE_PID_DEPENDENCY_NATIVE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency to package ${DECLARE_PID_DEPENDENCY_PACKAGE}, the type of the required package must be EXTERNAL or NATIVE, not both.")
elseif(NOT DECLARE_PID_DEPENDENCY_EXTERNAL AND NOT DECLARE_PID_DEPENDENCY_NATIVE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency to package ${DECLARE_PID_DEPENDENCY_PACKAGE}, the type of the required package must be EXTERNAL or NATIVE (use one of these KEYWORDS).")
else() #first checks OK now parsing version related arguments
	set(list_of_versions)
	set(exact_versions)
	if(DECLARE_PID_DEPENDENCY_UNPARSED_ARGUMENTS)
		set(TO_PARSE "${DECLARE_PID_DEPENDENCY_UNPARSED_ARGUMENTS}")
		set(RES_VERSION TRUE)
		while(TO_PARSE AND RES_VERSION)
			parse_Package_Dependency_Version_Arguments("${TO_PARSE}" RES_VERSION RES_EXACT TO_PARSE)
			if(RES_VERSION)
				list(APPEND list_of_versions ${RES_VERSION})
				if(RES_EXACT)
					list(APPEND exact_versions ${RES_VERSION})
				endif()
			elseif(RES_EXACT)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency to package ${DECLARE_PID_DEPENDENCY_PACKAGE}, you must use the EXACT keyword together with the VERSION keyword.")
			endif()
		endwhile()
	endif()
	set(list_of_components)
	if(TO_PARSE) #there are still components to parse
		set(oneValueArgs)
		set(options)
		set(multiValueArgs COMPONENTS)
		cmake_parse_arguments(DECLARE_PID_DEPENDENCY_MORE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${TO_PARSE})
		if(DECLARE_PID_DEPENDENCY_MORE_COMPONENTS)
			list(LENGTH DECLARE_PID_DEPENDENCY_MORE_COMPONENTS SIZE)
			if(SIZE LESS 1)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency to package ${DECLARE_PID_DEPENDENCY_PACKAGE}, at least one component dependency must be defined when using the COMPONENTS keyword.")
			endif()
			set(list_of_components ${DECLARE_PID_DEPENDENCY_MORE_COMPONENTS})
		else()
			message(FATAL_ERROR "[PID] WARNING : when declaring dependency to package ${DECLARE_PID_DEPENDENCY_PACKAGE}, unknown arguments used ${DECLARE_PID_DEPENDENCY_MORE_UNPARSED_ARGUMENTS}.")
		endif()
	endif()

	if(DECLARE_PID_DEPENDENCY_EXTERNAL)#external package
		declare_External_Package_Dependency(${DECLARE_PID_DEPENDENCY_PACKAGE} "${DECLARE_PID_DEPENDENCY_OPTIONAL}" "${list_of_versions}" "${exact_versions}" "${list_of_components}")
	else()#native package
		declare_Package_Dependency(${DECLARE_PID_DEPENDENCY_PACKAGE} "${DECLARE_PID_DEPENDENCY_OPTIONAL}" "${list_of_versions}" "${exact_versions}" "${list_of_components}")
	endif()
endif()
endmacro(declare_PID_Package_Dependency)

### Get information about a dependency so that it can help the user configure the build
function(used_Package_Dependency)
set(oneValueArgs USED VERSION PACKAGE)
cmake_parse_arguments(USED_PACKAGE_DEPENDENCY "" "${oneValueArgs}" "" ${ARGN} )

if(NOT USED_PACKAGE_DEPENDENCY_PACKAGE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR: when calling used_Package_Dependency you specified no dependency name using PACKAGE keyword")
	return()
endif()
set(dep_package ${USED_PACKAGE_DEPENDENCY_PACKAGE})
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

endfunction(used_Package_Dependency dep_package)

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

if(NOT DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, a name must be given to the component that declare the dependency using COMPONENT keyword.")
endif()
if(DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, unknown arguments ${DECLARE_PID_COMPONENT_DEPENDENCY_UNPARSED_ARGUMENTS}.")
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
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, the LINKS option argument must be followed only by static and/or shared links.")
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
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, keywords EXTERNAL (requiring an external package) and NATIVE (or DEPEND) (requiring a PID component) cannot be used simultaneously.")
	endif()
	if(DECLARE_PID_COMPONENT_DEPENDENCY_DEPEND)
		set(target_component ${DECLARE_PID_COMPONENT_DEPENDENCY_DEPEND})
	else()
		set(target_component ${DECLARE_PID_COMPONENT_DEPENDENCY_NATIVE})
	endif()

	if(DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE
		AND NOT DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE STREQUAL PROJECT_NAME)#package dependency target package is not current project

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
		if(target_component STREQUAL DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, the component cannot depend on itself !")
		endif()

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

	if(DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE)
		if(DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE STREQUAL PROJECT_NAME)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when declaring dependency for component ${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}, the target external package canoot be current project !")
		endif()
		declare_External_Wrapper_Component_Dependency(
					${DECLARE_PID_COMPONENT_DEPENDENCY_COMPONENT}
					${DECLARE_PID_COMPONENT_DEPENDENCY_PACKAGE}
					${DECLARE_PID_COMPONENT_DEPENDENCY_EXTERNAL}
					${export}
					"${comp_defs}"
					"${comp_exp_defs}"
					"${dep_defs}")

	else()
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
	endif()
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
#			PRIVILEGED
#			ARGUMENTS	 	list_of_args
#			)
macro(run_PID_Test)
set(options PRIVILEGED)
set(oneValueArgs NAME EXE COMPONENT PACKAGE)
set(multiValueArgs ARGUMENTS)
cmake_parse_arguments(RUN_PID_TEST "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
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

if(NOT PID_CROSSCOMPILATION)
	set(PROJECT_RUN_TESTS TRUE CACHE INTERNAL "")
endif()

if(RUN_PID_TEST_PRIVILEGED)
	if(NOT RUN_TESTS_WITH_PRIVILEGES)
		set(RUN_TESTS_WITH_PRIVILEGES TRUE CACHE INTERNAL "")
	endif()
endif()

if(RUN_PID_TEST_EXE)
	add_test("${RUN_PID_TEST_NAME}" "${RUN_PID_TEST_EXE}" ${RUN_PID_TEST_ARGUMENTS})
else()#RUN_PID_TEST_COMPONENT
	if(RUN_PID_TEST_PACKAGE)#component coming from another PID package
		set(target_of_test ${RUN_PID_TEST_PACKAGE}-${RUN_PID_TEST_COMPONENT}${INSTALL_NAME_SUFFIX})
		add_test(${RUN_PID_TEST_NAME} ${target_of_test} ${RUN_PID_TEST_ARGUMENTS})
	else()#internal component
		add_test(${RUN_PID_TEST_NAME} ${RUN_PID_TEST_COMPONENT}${INSTALL_NAME_SUFFIX} ${RUN_PID_TEST_ARGUMENTS})
	endif()
endif()

endmacro(run_PID_Test)

##################################################################################################
#################### API to ease the description of external packages ############################
##################################################################################################
macro(declare_PID_External_Package)
	set(options)
	set(oneValueArgs PACKAGE)
	set(multiValueArgs)
	cmake_parse_arguments(DECLARE_PID_EXTERNAL_PACKAGE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	if(NOT DECLARE_PID_EXTERNAL_PACKAGE_PACKAGE)
		message("[PID] WARNING: Bad usage of function declare_PID_External_Package: package name must be defined using PACKAGE keyword")
		return() #return will exit from current Use file included (because we are in a macro)
	endif()
	#reset all values
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
	set(package ${DECLARE_PID_EXTERNAL_PACKAGE_PACKAGE})
	set(${package}_HAS_DESCRIPTION TRUE CACHE INTERNAL "")#variable to be used to test if the package is described with a wrapper (if this macro is used this is always TRUE)
	if(NOT ${package}_DECLARED)
		#reset all variables related to this external package
		set(${package}_PLATFORM${VAR_SUFFIX}  CACHE INTERNAL "")
		set(${package}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX}  CACHE INTERNAL "")
		if(${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
			foreach(dep IN ITEMS ${${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}})
				set(${package}_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_EXTERNAL_DEPENDENCY_${dep}_VERSION_EXACT${VAR_SUFFIX} CACHE INTERNAL "")
			endforeach()
		endif()
		set(${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} CACHE INTERNAL "")
		if(${package}_COMPONENTS${VAR_SUFFIX})
			foreach(comp IN ITEMS ${${package}_COMPONENTS${VAR_SUFFIX}})
				#resetting variables of the component
				set(${package}_${comp}_INC_DIRS${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_OPTS${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_DEFS${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_STATIC_LINKS${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_SHARED_LINKS${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_RUNTIME_RESOURCES${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_INTERNAL_DEPENDENCIES${VAR_SUFFIX} CACHE INTERNAL "")
				if(${package}_${comp}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
					foreach(dep_pack IN ITEMS ${${package}_${comp}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}})
						if(${package}_${comp}_EXTERNAL_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})
							foreach(dep_comp IN ITEMS ${${package}_${comp}_EXTERNAL_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX}})
								set(${package}_${comp}_EXTERNAL_EXPORT_${dep_pack}_${dep_comp}${VAR_SUFFIX} CACHE INTERNAL "")
							endforeach()
							set(${package}_${comp}_EXTERNAL_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX} CACHE INTERNAL "")
						endif()
					endforeach()
					set(${package}_${comp}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} CACHE INTERNAL "")
				endif()
			endforeach()
		endif()
	else()
		return()#simply returns as the external package is already in memory
	endif()
	set(${package}_DECLARED TRUE)
endmacro(declare_PID_External_Package)

### API: used to describe external package platform constraints
macro(check_PID_External_Package_Platform)
set(options)
set(oneValueArgs PLATFORM PACKAGE)
set(multiValueArgs CONFIGURATION)
cmake_parse_arguments(CHECK_EXTERNAL_PID_PLATFORM "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(CHECK_EXTERNAL_PID_PLATFORM_PACKAGE
	AND CHECK_EXTERNAL_PID_PLATFORM_CONFIGURATION
	AND CHECK_EXTERNAL_PID_PLATFORM_PLATFORM)
	if(NOT ${CHECK_EXTERNAL_PID_PLATFORM_PACKAGE}_DECLARED)
		message("[PID] WARNING: Bad usage of function check_PID_External_Package_Platform: package ${CHECK_EXTERNAL_PID_PLATFORM_PACKAGE} is unknown. Use macro declare_PID_External_Package to declare it")
		return() #return will exit from current Use file included (because we are in a macro)
	endif()
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
	set(${CHECK_EXTERNAL_PID_PLATFORM_PACKAGE}_PLATFORM${VAR_SUFFIX} ${CHECK_EXTERNAL_PID_PLATFORM_PLATFORM}  CACHE INTERNAL "")
	set(${CHECK_EXTERNAL_PID_PLATFORM_PACKAGE}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX} ${CHECK_EXTERNAL_PID_PLATFORM_CONFIGURATION}  CACHE INTERNAL "")
else()
	message("[PID] WARNING: Bad usage of function check_PID_External_Package_Platform: PACKAGE (value: ${CHECK_EXTERNAL_PID_PLATFORM_PACKAGE}), PLATFORM (value: ${CHECK_EXTERNAL_PID_PLATFORM_PLATFORM}) and CONFIGURATION (value: ${CHECK_EXTERNAL_PID_PLATFORM_CONFIGURATION}) keywords must be used !")
	return() #return will exit from current Use file included (because we are in a macro)
endif()
endmacro(check_PID_External_Package_Platform)

### API: used to describe external package dependency to other external packages
macro(declare_PID_External_Package_Dependency)
	set(options EXACT)
	set(oneValueArgs PACKAGE EXTERNAL VERSION)
	cmake_parse_arguments(DECLARE_PID_EXTERNAL_DEPENDENCY "${options}" "${oneValueArgs}" "" ${ARGN} )
	if(DECLARE_PID_EXTERNAL_DEPENDENCY_PACKAGE
		AND DECLARE_PID_EXTERNAL_DEPENDENCY_EXTERNAL) #if everything not used then simply do nothing
		if(NOT ${CHECK_EXTERNAL_PID_PLATFORM_PACKAGE}_DECLARED)
			message("[PID] WARNING: Bad usage of function declare_PID_External_Package_Dependency: package ${DECLARE_PID_EXTERNAL_DEPENDENCY_PACKAGE} is unknown. Use macro declare_PID_External_Package to declare it")
			return() #return will exit from current Use file included (because we are in a macro)
		endif()
		set(package ${DECLARE_PID_EXTERNAL_DEPENDENCY_PACKAGE})
		set(dependency ${DECLARE_PID_EXTERNAL_DEPENDENCY_EXTERNAL})

		get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
		set(${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} ${${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}} ${dependency} CACHE INTERNAL "")

		if(NOT DECLARE_PID_EXTERNAL_DEPENDENCY_VERSION)
			if(DECLARE_PID_DEPENDENCY_EXTERNAL_EXACT)
				message("[PID] WARNING: Bad usage of function declare_PID_External_Package_Dependency: use EXACT keyword only if a version is defined.")
				return() #return will exit from current Use file included (because we are in a macro)
			endif()
			set(${package}_EXTERNAL_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX} CACHE INTERNAL "")
			set(${package}_EXTERNAL_DEPENDENCY_${dependency}_VERSION_EXACT${VAR_SUFFIX} FALSE CACHE INTERNAL "")

		else()
			if(DECLARE_PID_DEPENDENCY_EXTERNAL_EXACT)
				set(exact TRUE)
			else()
				set(exact FALSE)
			endif()
			if(NOT ${package}_EXTERNAL_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX})
				set(${package}_EXTERNAL_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX} ${DECLARE_PID_EXTERNAL_DEPENDENCY_VERSION} CACHE INTERNAL "")
				set(${package}_EXTERNAL_DEPENDENCY_${dependency}_VERSION_EXACT${VAR_SUFFIX} ${exact} CACHE INTERNAL "")
			else()
					message("[PID] WARNING: Bad usage of function declare_PID_External_Package_Dependency: package ${package} already declares a dependency to external package ${dependency} with version ${DECLARE_PID_EXTERNAL_DEPENDENCY_VERSION} has already been defined !")
					return() #return will exit from current Use file included (because we are in a macro)
			endif()
		endif()
	else()
		message("[PID] WARNING: Bad usage of function declare_PID_External_Package_Dependency: PACKAGE (value: ${package}) and EXTERNAL (value: ${dependency}) keywords must be used !")
		return() #return will exit from current Use file included (because we are in a macro)
	endif()
endmacro(declare_PID_External_Package_Dependency)

### API: used to describe a component inside and external package
macro(declare_PID_External_Component)
	set(options)
	set(oneValueArgs PACKAGE COMPONENT C_STANDARD CXX_STANDARD)
	set(multiValueArgs INCLUDES STATIC_LINKS SHARED_LINKS DEFINITIONS RUNTIME_RESOURCES COMPILER_OPTIONS)

	cmake_parse_arguments(DECLARE_PID_EXTERNAL_COMPONENT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	if(NOT DECLARE_PID_EXTERNAL_COMPONENT_PACKAGE OR NOT DECLARE_PID_EXTERNAL_COMPONENT_COMPONENT)
		message("[PID] WARNING: Bad usage of function declare_PID_External_Component: you must define the PACKAGE (value: ${DECLARE_PID_EXTERNAL_COMPONENT_PACKAGE}) and the name of the component using COMPONENT keyword (value: ${DECLARE_PID_EXTERNAL_COMPONENT_COMPONENT}).")
		return()#return will exit from current Use file included (because we are in a macro)
	endif()
	if(NOT ${DECLARE_PID_EXTERNAL_COMPONENT_PACKAGE}_DECLARED)
		message("[PID] WARNING: Bad usage of function declare_PID_External_Component: package ${DECLARE_PID_EXTERNAL_COMPONENT_PACKAGE} is unknown. Use macro declare_PID_External_Package to declare it")
		return() #return will exit from current Use file included (because we are in a macro)
	endif()
	set(curr_ext_package ${DECLARE_PID_EXTERNAL_COMPONENT_PACKAGE})
	set(curr_ext_comp ${DECLARE_PID_EXTERNAL_COMPONENT_COMPONENT})
	set(comps_list ${${curr_ext_package}_COMPONENTS${VAR_SUFFIX}} ${curr_ext_comp})
	list(REMOVE_DUPLICATES comps_list)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
	set(${curr_ext_package}_COMPONENTS${VAR_SUFFIX} ${comps_list} CACHE INTERNAL "")

	#manage include folders
	set(incs)
	if(DECLARE_PID_EXTERNAL_COMPONENT_INCLUDES)
		foreach(an_include IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_INCLUDES})
			if(an_include MATCHES "^(<${curr_ext_package}>|/).*")
				list(APPEND incs ${an_include})
			else()#if the string DOES NOT start with a / (absolute path), a <package> (relative path from package root) then we add the header <package> to the path
				list(APPEND incs "<${curr_ext_package}>/${an_include}")# prepend the external package name
			endif()
		endforeach()
	endif()
	if(incs)
		list(REMOVE_DUPLICATES incs)
		set(${curr_ext_package}_${curr_ext_comp}_INC_DIRS${VAR_SUFFIX} ${incs} CACHE INTERNAL "")
	endif()
	#manage compile options
	set(${curr_ext_package}_${curr_ext_comp}_OPTS${VAR_SUFFIX} ${DECLARE_PID_EXTERNAL_COMPONENT_COMPILER_OPTIONS} CACHE INTERNAL "")
	#manage definitions
	set(${curr_ext_package}_${curr_ext_comp}_DEFS${VAR_SUFFIX} ${DECLARE_PID_EXTERNAL_COMPONENT_DEFINITIONS} CACHE INTERNAL "")

	#manage C standard in USE
	if(DECLARE_PID_EXTERNAL_COMPONENT_C_STANDARD)
		set(c_language_standard ${DECLARE_PID_EXTERNAL_COMPONENT_C_STANDARD})
		if(	NOT c_language_standard EQUAL 90
		AND NOT c_language_standard EQUAL 99
		AND NOT c_language_standard EQUAL 11)
			message("[PID] ERROR : bad C_STANDARD argument for component ${curr_ext_comp} from external package ${curr_ext_package}, the value used must be 90, 99 or 11.")
		endif()
	else() #default language standard is first standard
		set(c_language_standard 90)
	endif()
	set(${curr_ext_package}_${curr_ext_comp}_C_STANDARD${VAR_SUFFIX} ${c_language_standard} CACHE INTERNAL "")

	if(DECLARE_PID_EXTERNAL_COMPONENT_CXX_STANDARD)
		set(cxx_language_standard ${DECLARE_PID_EXTERNAL_COMPONENT_CXX_STANDARD})
		if(	NOT cxx_language_standard EQUAL 98
		AND NOT cxx_language_standard EQUAL 11
		AND NOT cxx_language_standard EQUAL 14
		AND NOT cxx_language_standard EQUAL 17 )
		message(FATAL_ERROR "[PID] ERROR : bad CXX_STANDARD argument for component ${curr_ext_comp} from external package ${curr_ext_package}, the value used must be 98, 11, 14 or 17.")
		endif()
	else() #default language standard is first standard
		set(cxx_language_standard 98)
	endif()
	#manage definitions
	set(${curr_ext_package}_${curr_ext_comp}_CXX_STANDARD${VAR_SUFFIX} ${cxx_language_standard} CACHE INTERNAL "")

	#manage links
	set(links)
	if(DECLARE_PID_EXTERNAL_COMPONENT_STATIC_LINKS)
		foreach(a_link IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_STATIC_LINKS})
			#if the string DOES NOT start with a / (absolute path), a <package> (relative path from package root) or - (link option specification) then we add the header <package>
			if(a_link MATCHES  "^(<${curr_ext_package}>|/|-).*")
				list(APPEND links ${a_link})
			else()
				list(APPEND links "<${curr_ext_package}>/${a_link}")# prepend the external package name
			endif()
		endforeach()
	endif()
	if(links)
		list(REMOVE_DUPLICATES links)
		set(${curr_ext_package}_${curr_ext_comp}_STATIC_LINKS${VAR_SUFFIX} ${links} CACHE INTERNAL "")
	endif()

	#manage shared links
	set(links)
	if(DECLARE_PID_EXTERNAL_COMPONENT_SHARED_LINKS)
		foreach(a_link IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_SHARED_LINKS})
			#if the string DOES NOT start with a / (absolute path), a <package> (relative path from package root) or - (link option specification) then we add the header <package>
			if(a_link MATCHES  "^(<${curr_ext_package}>|/|-).*")
				list(APPEND links ${a_link})
			else()
				list(APPEND links "<${curr_ext_package}>/${a_link}")# prepend the external package name
			endif()
		endforeach()
	endif()
	if(links)
		list(REMOVE_DUPLICATES links)
		set(${curr_ext_package}_${curr_ext_comp}_SHARED_LINKS${VAR_SUFFIX} ${links} CACHE INTERNAL "")
	endif()


	#manage runtime resources
	set(resources)
	if(DECLARE_PID_EXTERNAL_COMPONENT_RUNTIME_RESOURCES)
		foreach(a_resource IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_RUNTIME_RESOURCES})
			if(a_resource MATCHES "^<${curr_ext_package}>")
				list(APPEND resources ${a_resource})
			else()
				list(APPEND resources "<${curr_ext_package}>/${a_resource}")# prepend the external package name
			endif()
		endforeach()
	endif()
	if(resources)
		list(REMOVE_DUPLICATES links)
		set(${curr_ext_package}_${curr_ext_comp}_RUNTIME_RESOURCES${VAR_SUFFIX} ${resources} CACHE INTERNAL "")
	endif()
endmacro(declare_PID_External_Component)

### declare_PID_External_Component_Dependency (PACKAGE current COMPONENT curr_comp [DEPENDS or EXPORT other] comp EXTERNAL other ext pack)
### EXTERNAL may be not used if the dependency is INTERNAL to the external package
### if EXTERNAL is used it may be use with a component name (using EXPORT or DEPENDS) or without (and so will directly use keywords: INCLUDES LINKS DEFINITIONS RUNTIME_RESOURCES COMPILER_OPTIONS)
macro(declare_PID_External_Component_Dependency)
	set(options)
	set(oneValueArgs PACKAGE COMPONENT EXTERNAL EXPORT USE)
	set(multiValueArgs INCLUDES STATIC_LINKS SHARED_LINKS DEFINITIONS RUNTIME_RESOURCES COMPILER_OPTIONS)
	cmake_parse_arguments(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	if(NOT DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_PACKAGE OR NOT DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_COMPONENT)
		message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: you must define the PACKAGE (value: ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_PACKAGE}) and the name of the component using COMPONENT keyword (value: ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_COMPONENT}).")
		return()
	endif()
	if(NOT ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_PACKAGE}_DECLARED)
		message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: package ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_PACKAGE} is unknown. Use macro declare_PID_External_Package to declare it")
		return() #return will exit from current Use file included (because we are in a macro)
	endif()
	set(LOCAL_PACKAGE ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_PACKAGE})
	set(LOCAL_COMPONENT ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_COMPONENT})
	set(TARGET_COMPONENT)
	set(EXPORT_TARGET FALSE)

	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
	#checking that the component is defined locally
	list(FIND ${LOCAL_PACKAGE}_COMPONENTS${VAR_SUFFIX} ${LOCAL_COMPONENT} INDEX)
	if(INDEX EQUAL -1)
		message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: external package ${LOCAL_PACKAGE} does not define component ${LOCAL_COMPONENT}.")
		return()
	endif()

	#configuraing target package
	if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXTERNAL)
		list(FIND ${LOCAL_PACKAGE}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXTERNAL} INDEX)
		if(INDEX EQUAL -1)
			# the external package is using the dependent package
			message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: external package ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXTERNAL} is not defined as a dependency of external package ${LOCAL_PACKAGE}.")
			return()
		endif()
		set(TARGET_PACKAGE ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXTERNAL})
		#in that case a component is not mandatory defined we can just target the libraries inside the depdendency packages
	else() #if not an external component it means it is an internal one
		#in that case the component must be defined
		set(TARGET_PACKAGE)#internal means the local is the dependency
	endif()

	#configuring target component
	if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_USE)
		if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXPORT)
			message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: in package ${LOCAL_PACKAGE} you must use either USE OR EXPORT keywords not both.")
			return()
		endif()
		set(TARGET_COMPONENT ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_USE})
	elseif(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXPORT)
		set(TARGET_COMPONENT ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXPORT})
		set(EXPORT_TARGET TRUE)
	endif()

	if(TARGET_COMPONENT AND NOT TARGET_PACKAGE) #this is a link to a component locally defined
		list(FIND ${LOCAL_PACKAGE}_COMPONENTS${VAR_SUFFIX} ${TARGET_COMPONENT} INDEX)
		if(INDEX EQUAL -1)
			message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: external package ${LOCAL_PACKAGE} does not define component ${TARGET_COMPONENT} used as a dependency for ${LOCAL_COMPONENT}.")
			return()
		endif()
	endif()

	# more checks
	if(TARGET_COMPONENT)
		if(NOT TARGET_PACKAGE)
			set(list_of_comps ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_INTERNAL_DEPENDENCIES${VAR_SUFFIX}} ${TARGET_COMPONENT})
			list(REMOVE_DUPLICATES list_of_comps)
			set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_INTERNAL_DEPENDENCIES${VAR_SUFFIX} ${list_of_comps} CACHE INTERNAL "")
			set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_INTERNAL_EXPORT_${TARGET_COMPONENT}${VAR_SUFFIX} ${EXPORT_TARGET} CACHE INTERNAL "")
		else()
			set(list_of_deps ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}} ${TARGET_PACKAGE})
			list(REMOVE_DUPLICATES list_of_deps)
			set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} ${list_of_deps} CACHE INTERNAL "")
			set(list_of_comps ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_DEPENDENCY_${TARGET_PACKAGE}_COMPONENTS${VAR_SUFFIX}} ${TARGET_COMPONENT})
			list(REMOVE_DUPLICATES list_of_comps)
			set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_DEPENDENCY_${TARGET_PACKAGE}_COMPONENTS${VAR_SUFFIX} ${list_of_comps} CACHE INTERNAL "")
			set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_EXPORT_${TARGET_PACKAGE}_${TARGET_COMPONENT}${VAR_SUFFIX} ${EXPORT_TARGET} CACHE INTERNAL "")
		endif()
	else() #otherwise this is a direct reference to external package content
		set(list_of_deps ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}} ${TARGET_PACKAGE})
		list(REMOVE_DUPLICATES list_of_deps)
		set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} ${list_of_deps} CACHE INTERNAL "")
		#this previous line is used to tell the system that path inside this component's variables have to be resolved again that external package
		if(NOT TARGET_PACKAGE) #check that we really target an external package
			message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: a target external package name must be defined when a component dependency is defined with no target component (use the EXTERNAL KEYWORD).")
			return()
		endif()
	endif()

#manage include folders
if(TARGET_PACKAGE AND NOT TARGET_COMPONENT) #if a target package is specified but not a component
	set(incs ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_INC_DIRS${VAR_SUFFIX}})
	if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_INCLUDES)
		foreach(an_include IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_INCLUDES})
			if(an_include MATCHES "^(<${TARGET_PACKAGE}>|/).*")
				list(APPEND incs ${an_include})
			else()
				list(APPEND incs "<${TARGET_PACKAGE}>/${an_include}")# prepend the external package name
			endif()
		endforeach()
		list(REMOVE_DUPLICATES incs)
	endif()
	set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_INC_DIRS${VAR_SUFFIX} ${incs} CACHE INTERNAL "")

	#manage compile options
	set(opts ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_OPTS${VAR_SUFFIX}} ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_COMPILER_OPTIONS})
	if(opts)
		list(REMOVE_DUPLICATES opts)
	endif()
	set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_OPTS${VAR_SUFFIX} ${opts} CACHE INTERNAL "")
	#manage definitions
	set(defs ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_DEFS${VAR_SUFFIX}} ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_DEFINITIONS})
	if(defs)
		list(REMOVE_DUPLICATES defs)
	endif()
	set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_DEFS${VAR_SUFFIX} ${defs} CACHE INTERNAL "")
	#manage links
	set(links ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_STATIC_LINKS${VAR_SUFFIX}})
	if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_STATIC_LINKS)
		foreach(a_link IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_STATIC_LINKS})
			if(a_link MATCHES  "^(<${TARGET_PACKAGE}>|/|-).*")
				list(APPEND links ${a_link})
			else()
				list(APPEND links "<${TARGET_PACKAGE}>/${a_link}")# prepend the external package name
			endif()
		endforeach()
		list(REMOVE_DUPLICATES links)
	endif()
	set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_STATIC_LINKS${VAR_SUFFIX} ${links} CACHE INTERNAL "")

	#manage shared links
	set(links ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_SHARED_LINKS${VAR_SUFFIX}})
	if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_SHARED_LINKS)
		foreach(a_link IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_SHARED_LINKS})
			if(a_link MATCHES  "^(<${TARGET_PACKAGE}>|/|-).*")
				list(APPEND links ${a_link})
			else()
				list(APPEND links "<${TARGET_PACKAGE}>/${a_link}")# prepend the external package name
			endif()
		endforeach()
		list(REMOVE_DUPLICATES links)
	endif()
	set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_SHARED_LINKS${VAR_SUFFIX} ${links} CACHE INTERNAL "")

	#manage runtime resources
	set(resources ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_RUNTIME_RESOURCES${VAR_SUFFIX}})
	if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_RUNTIME_RESOURCES)
		foreach(a_resource IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_RUNTIME_RESOURCES})
			if(a_resource MATCHES "^<${TARGET_PACKAGE}>")
				list(APPEND resources ${a_resource})
			else()
				list(APPEND resources "<${TARGET_PACKAGE}>/${a_resource}")# prepend the external package name
			endif()
		endforeach()
		list(REMOVE_DUPLICATES resources)
	endif()
	set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_RUNTIME_RESOURCES${VAR_SUFFIX} ${resources} CACHE INTERNAL "")
endif()
endmacro(declare_PID_External_Component_Dependency)


#############################################################################################
###########################Other functions of the API #######################################
#############################################################################################

### API : external_PID_Package_Path (NAME external_package PATH result)
function(external_PID_Package_Path)
set(oneValueArgs NAME PATH)
cmake_parse_arguments(EXT_PACKAGE_PATH "" "${oneValueArgs}" "" ${ARGN} )
if(NOT EXT_PACKAGE_PATH_NAME OR NOT EXT_PACKAGE_PATH_PATH)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a name of an external package must be provided with name and a variable containing the resulting path must be set with PATH keyword.")
endif()
is_External_Package_Defined(${PROJECT_NAME} "${EXT_PACKAGE_PATH_NAME}" ${CMAKE_BUILD_TYPE} PATHTO)
if(PATHTO STREQUAL NOTFOUND)
	set(${EXT_PACKAGE_PATH_PATH} NOTFOUND PARENT_SCOPE)
else()
	set(${EXT_PACKAGE_PATH_PATH} ${PATHTO} PARENT_SCOPE)
endif()
endfunction(external_PID_Package_Path)


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
