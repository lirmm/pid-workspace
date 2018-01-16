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

### API : declare_PID_Wrapper(AUTHOR main_author_name ... [INSTITUION ...] [MAIL ...] YEAR ... LICENSE license [ADDRESS address] DESCRIPTION ...)
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
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a (short) description of the package must be given using DESCRIPTION keyword.")
endif()

if(DECLARE_PID_WRAPPER_UNPARSED_ARGUMENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, unknown arguments ${DECLARE_PID_WRAPPER_UNPARSED_ARGUMENTS}.")
endif()

if(NOT DECLARE_PID_WRAPPER_ADDRESS AND DECLARE_PID_WRAPPER_PUBLIC_ADDRESS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, the package must have an adress if a public access adress is declared.")
endif()

# declare_Wrapper(	"${DECLARE_PID_WRAPPER_AUTHOR}" "${DECLARE_PID_WRAPPER_INSTITUTION}" "${DECLARE_PID_WRAPPER_MAIL}"
# 			"${DECLARE_PID_WRAPPER_YEAR}" "${DECLARE_PID_WRAPPER_LICENSE}"
# 			"${DECLARE_PID_WRAPPER_ADDRESS}" "${DECLARE_PID_WRAPPER_PUBLIC_ADDRESS}"
# 		"${DECLARE_PID_WRAPPER_DESCRIPTION}" "${DECLARE_PID_WRAPPER_README}")
endmacro(declare_PID_Wrapper)

### feed information about the original projet
macro(define_PID_Wrapper_Original_Project_Info)

endmacro(define_PID_Wrapper_Original_Project_Info)

### memorizing a new known version
macro(add_PID_Wrapper_Known_Version)

endmacro(add_PID_Wrapper_Known_Version)

### define a component
macro(check_PID_Wrapper_Platform)

endmacro(check_PID_Wrapper_Platform)

### dependency to another external package
macro(declare_PID_Wrapper_Dependency)

endmacro(declare_PID_Wrapper_Dependency)

### build the wrapper ==> providing commands used to deploy a specific version of the external package
### make build version=1.55.0 (download, configure, compile and install the adequate version)
macro(build_PID_Wrapper)

endmacro(build_PID_Wrapper)

### define a component
macro(declare_PID_Wrapper_Component)

endmacro(declare_PID_Wrapper_Component)

### define a component
macro(declare_PID_Wrapper_Component_Dependency)

endmacro(declare_PID_Wrapper_Component_Dependency)
