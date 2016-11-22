
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


########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Package_Cache_Management_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions.cmake NO_POLICY_SCOPE)

##################################################################################
##########################  declaration of the framework #########################
##################################################################################
macro(declare_Framework author institution mail year site license address description)

set(${PROJECT_NAME}_ROOT_DIR CACHE INTERNAL "")
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake) # adding the cmake scripts files from the framework

init_PID_Version_Variable() # getting the workspace version used to generate the code 
set(res_string)	
foreach(string_el IN ITEMS ${author})
	set(res_string "${res_string}_${string_el}")
endforeach()
set(${PROJECT_NAME}_MAIN_AUTHOR "${res_string}" CACHE INTERNAL "")

set(res_string "")
foreach(string_el IN ITEMS ${institution})
	set(res_string "${res_string}_${string_el}")
endforeach()
set(${PROJECT_NAME}_MAIN_INSTITUTION "${res_string}" CACHE INTERNAL "")
set(${PROJECT_NAME}_CONTACT_MAIL ${mail} CACHE INTERNAL "")
set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_MAIN_AUTHOR}(${${PROJECT_NAME}_MAIN_INSTITUTION})" CACHE INTERNAL "")
set(${PROJECT_NAME}_DESCRIPTION "${description}" CACHE INTERNAL "")
set(${PROJECT_NAME}_YEARS ${year} CACHE INTERNAL "")
set(${PROJECT_NAME}_SITE ${site} CACHE INTERNAL "")
set(${PROJECT_NAME}_LICENSE ${license} CACHE INTERNAL "")
set(${PROJECT_NAME}_ADDRESS ${address} CACHE INTERNAL "")
set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")#categories are reset
endmacro(declare_Framework)


##################################################################################
############################### building the framework ###########################
##################################################################################

############ function used to create the README.md file of the framework  ###########
function(generate_Framework_Readme_File)
set(README_CONFIG_FILE ${WORKSPACE_DIR}/share/patterns/frameworks/README.md.in)
set(FRAMEWORK_NAME ${PROJECT_NAME})
set(FRAMEWORK_SITE ${PROJECT_NAME}_SITE)
set(README_OVERVIEW "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided by wiki description use the short one


if(${PROJECT_NAME}_LICENSE)
	set(LICENSE_FOR_README "The license that applies to this repository project is **${${PROJECT_NAME}_LICENSE}**.
else()
	set(LICENSE_FOR_README "The package has no license defined yet.")
endif()


set(README_AUTHORS_LIST "")	
foreach(author IN ITEMS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS})
	generate_Full_Author_String(${author} STRING_TO_APPEND)
	set(README_AUTHORS_LIST "${README_AUTHORS_LIST}\n+ ${STRING_TO_APPEND}")
endforeach()

get_Formatted_Package_Contact_String(${PROJECT_NAME} RES_STRING)
set(README_CONTACT_AUTHOR "${RES_STRING}")

configure_file(${README_CONFIG_FILE} ${CMAKE_SOURCE_DIR}/README.md @ONLY)#put it in the source dir
endfunction(generate_Framework_Readme_File)

############ function used to create the license.txt file of the package  ###########
function(generate_Framework_License_File)
if(	DEFINED ${PROJECT_NAME}_LICENSE 
	AND NOT ${${PROJECT_NAME}_LICENSE} STREQUAL "")

	find_file(	LICENSE   
			"License${${PROJECT_NAME}_LICENSE}.cmake"
			PATH "${WORKSPACE_DIR}/share/cmake/licenses"
			NO_DEFAULT_PATH
		)
	set(LICENSE ${LICENSE} CACHE INTERNAL "")
	
	if(LICENSE_IN-NOTFOUND)
		message("[PID] WARNING : license configuration file for ${${PROJECT_NAME}_LICENSE} not found in workspace, license file will not be generated")
	else()
		foreach(author IN ITEMS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS})
			generate_Full_Author_String(${author} STRING_TO_APPEND)
			set(${PROJECT_NAME}_AUTHORS_LIST "${${PROJECT_NAME}_AUTHORS_LIST} ${STRING_TO_APPEND}")
		endforeach()
		include(${WORKSPACE_DIR}/share/cmake/licenses/License${${PROJECT_NAME}_LICENSE}.cmake)
		file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
	endif()
endif()
endfunction(generate_Framework_License_File)

### main function for building the package
macro(build_Framework)

#################################################
############ MANAGING the BUILD #################
#################################################

# recursive call into subdirectories to configure the workspace
add_subdirectory(share)
generate_Framework_Readme_File() # generating and putting into source directory the readme file used by gitlab
generate_Framework_License_File() # generating and putting into source directory the file containing license info about the package

#########################################################################################################################
######### writing the global reference file for the package with all global info contained in the CMakeFile.txt #########
#########################################################################################################################
if(${PROJECT_NAME}_ADDRESS)
	generate_Reference_File(${CMAKE_BINARY_DIR}/share/Refer${PROJECT_NAME}.cmake) 
	#copy the reference file of the package into the "references" folder of the workspace
	add_custom_target(referencing
		COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/share/Refer${PROJECT_NAME}.cmake ${WORKSPACE_DIR}/share/cmake/references
		COMMAND ${CMAKE_COMMAND} -E echo "Framework references have been registered into the worskpace"
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
endif()

endmacro(build_Framework)


