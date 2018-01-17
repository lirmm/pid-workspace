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

include(PID_Framework_API_Internal_Functions NO_POLICY_SCOPE)
include(CMakeParseArguments)


### API : declare_PID_Framework(AUTHOR main_author_name ... [INSTITUTION ...] [MAIL ...] YEAR ... [GIT_ADDRESS | ADDRESS address] [PROJECT site] LICENSE ... DESCRIPTION ... SITE ... [LOGO logo_image_path_relative_to assets/img ] [BANNER banner_image_path_relative_to assets/img])
macro(declare_PID_Framework)
set(oneValueArgs GIT_ADDRESS ADDRESS MAIL SITE PROJECT LICENSE LOGO BANNER)
set(multiValueArgs AUTHOR INSTITUTION YEAR DESCRIPTION)
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
elseif(DECLARE_PID_FRAMEWORK_GIT_ADDRESS)
	set(address ${DECLARE_PID_FRAMEWORK_GIT_ADDRESS})
else()
	message(FATAL_ERROR "[PID] CRITICAL ERROR : you must define the address of the framework's repository using either ADDRESS or GIT_ADDRESS keyword.")
endif()

declare_Framework(	"${DECLARE_PID_FRAMEWORK_AUTHOR}" "${DECLARE_PID_FRAMEWORK_INSTITUTION}" "${DECLARE_PID_FRAMEWORK_MAIL}"
			"${DECLARE_PID_FRAMEWORK_YEAR}" "${DECLARE_PID_FRAMEWORK_SITE}" "${DECLARE_PID_FRAMEWORK_LICENSE}"
			"${address}" "${DECLARE_PID_FRAMEWORK_PROJECT}" "${DECLARE_PID_FRAMEWORK_DESCRIPTION}")
if(DECLARE_PID_FRAMEWORK_LOGO)
	declare_Framework_Image(${DECLARE_PID_FRAMEWORK_LOGO} FALSE)
endif()
if(DECLARE_PID_FRAMEWORK_BANNER)
	declare_Framework_Image(${DECLARE_PID_FRAMEWORK_BANNER} TRUE)
endif()

endmacro(declare_PID_Framework)


### API : add_PID_Framework_Author(AUTHOR ... [INSTITUTION ...])
macro(add_PID_Framework_Author)
set(multiValueArgs AUTHOR INSTITUTION)
cmake_parse_arguments(ADD_PID_FRAMEWORK_AUTHOR "" "" "${multiValueArgs}" ${ARGN} )
if(NOT ADD_PID_FRAMEWORK_AUTHOR_AUTHOR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, an author name must be given using AUTHOR keyword.")
endif()
add_Framework_Author("${ADD_PID_FRAMEWORK_AUTHOR_AUTHOR}" "${ADD_PID_FRAMEWORK_AUTHOR_INSTITUTION}")
endmacro(add_PID_Framework_Author)


### API : add_PID_Framework_Category(category_path)
macro(add_PID_Framework_Category)
if(NOT ${ARGC} EQUAL 1)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the add_PID_Framework_Category command requires one string argument of the form <category>[/subcategory]*.")
endif()
add_Framework_Category("${ARGV0}")
endmacro(add_PID_Framework_Category)

### API : build_PID_Framework()
macro(build_PID_Framework)
if(${ARGC} GREATER 0)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the build_PID_Framework command requires no arguments.")
endif()
build_Framework()
endmacro(build_PID_Framework)


### API : declare_PID_Site() -> only for lone packages static sites
macro(declare_PID_Site)

set(oneValueArgs PACKAGE_URL SITE_URL)
cmake_parse_arguments(DECLARE_PID_SITE "" "${oneValueArgs}" "" ${ARGN} )
declare_Site("${DECLARE_PID_SITE_PACKAGE_URL}" "${DECLARE_PID_SITE_SITE_URL}")
endmacro(declare_PID_Site)
