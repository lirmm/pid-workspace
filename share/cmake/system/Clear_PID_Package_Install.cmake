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
#	You can be find the complete license description on the official website 	#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)

function(remove_Installed_Component component package install_version workspace)
	set(PATH_TO_INSTALL_DIR ${workspace}/install/${package}/${install_version})

	if(	${INSTALLED_${component}_TYPE} STREQUAL "HEADER")
		if(${${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE} EQUAL 1)
			file(REMOVE_RECURSE ${PATH_TO_INSTALL_DIR}/include/${INSTALLED_${component}_HEADER_DIR_NAME})#removing header dir
			set(${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE 0 PARENT_SCOPE)
		else()
			math(EXPR NB_USAGES ${${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE}-1)
			set(${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE ${NB_USAGES} PARENT_SCOPE)
		endif()
	elseif( ${INSTALLED_${component}_TYPE} STREQUAL "STATIC")
		if(${${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE} EQUAL 1)
			file(REMOVE_RECURSE ${PATH_TO_INSTALL_DIR}/include/${INSTALLED_${component}_HEADER_DIR_NAME})#removing header dir
			set(${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE 0 PARENT_SCOPE)
		else()
			math(EXPR NB_USAGES ${${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE}-1)
			set(${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE ${NB_USAGES} PARENT_SCOPE)
		endif()
		file(REMOVE ${PATH_TO_INSTALL_DIR}/lib/${INSTALLED_${component}_BINARY_NAME} ${PATH_TO_INSTALL_DIR}/lib/${INSTALLED_${component}_BINARY_NAME_DEBUG})#removing binaries
	elseif( ${INSTALLED_${component}_TYPE} STREQUAL "SHARED")
		if(${${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE} EQUAL 1)
			file(REMOVE_RECURSE ${PATH_TO_INSTALL_DIR}/include/${INSTALLED_${component}_HEADER_DIR_NAME})#removing header dir
			set(${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE 0 PARENT_SCOPE)
		else()
			math(EXPR NB_USAGES ${${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE}-1)
			set(${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE ${NB_USAGES} PARENT_SCOPE)
		endif()
		file(REMOVE ${PATH_TO_INSTALL_DIR}/lib/${INSTALLED_${component}_BINARY_NAME} ${PATH_TO_INSTALL_DIR}/lib/${INSTALLED_${component}_BINARY_NAME_DEBUG})#removing binaries
		file(REMOVE_RECURSE ${PATH_TO_INSTALL_DIR}/.rpath/${component} ${PATH_TO_INSTALL_DIR}/.rpath/${component}-dbg)#removing related rpath folder

	elseif(	${INSTALLED_${component}_TYPE} STREQUAL "EXAMPLE")
		file(REMOVE ${PATH_TO_INSTALL_DIR}/bin/${INSTALLED_${component}_BINARY_NAME} ${PATH_TO_INSTALL_DIR}/bin/${INSTALLED_${component}_BINARY_NAME_DEBUG})#removing binaries
		file(REMOVE_RECURSE ${PATH_TO_INSTALL_DIR}/.rpath/${component} ${PATH_TO_INSTALL_DIR}/.rpath/${component}-dbg)#removing related rpath folder

	elseif( ${INSTALLED_${component}_TYPE} STREQUAL "APP")
		file(REMOVE ${PATH_TO_INSTALL_DIR}/bin/${INSTALLED_${component}_BINARY_NAME} ${PATH_TO_INSTALL_DIR}/bin/${INSTALLED_${component}_BINARY_NAME_DEBUG})#removing binaries
		file(REMOVE_RECURSE ${PATH_TO_INSTALL_DIR}/.rpath/${component} ${PATH_TO_INSTALL_DIR}/.rpath/${component}-dbg)#removing related rpath folder
	endif()
endfunction(remove_Installed_Component)


function(check_Headers_Modifications all_components_to_check package install_version workspace)
set(PATH_TO_INSTALL_DIR ${workspace}/install/${package}/${install_version})

foreach(component IN ITEMS ${all_components_to_check}) #for each remaining existing component
	#component exists, check for header files/folders suppression/changes
	if(	"${INSTALLED_${component}_TYPE}" STREQUAL "HEADER" 
		OR "${INSTALLED_${component}_TYPE}" STREQUAL "STATIC"
		OR "${INSTALLED_${component}_TYPE}" STREQUAL "SHARED")#if component is a library its header folder still exist at this step (not removed by previous function)
		# checking header folder modification/suppression
		if("${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}" STREQUAL "${INSTALLED_${component}_HEADER_DIR_NAME}")#same header include folder
			foreach(header_name IN ITEMS ${INSTALLED_${component}_HEADERS})
				list(FIND ${PACKAGE_NAME}_${component}_HEADERS ${header_name} FIND_INDEX)
				if(FIND_INDEX EQUAL -1)#this header file does no more exists
					file(REMOVE ${PATH_TO_INSTALL_DIR}/include/${INSTALLED_${component}_HEADER_DIR_NAME}/${header_name})
				endif()

			endforeach()

		else()#new folder for this library
			if(${${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE} EQUAL 1)
				file(REMOVE_RECURSE ${PATH_TO_INSTALL_DIR}/include/${INSTALLED_${component}_HEADER_DIR_NAME})#removing old header include folder
				math(EXPR ${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE 0)
			else()
				math(EXPR ${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE ${${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE}-1)
			endif()

		endif()
	endif()
endforeach()
endfunction(check_Headers_Modifications)

#################################################################################################
########### this is the script file to clean a package install folder before installing #########
########### parameters :
########### WORKSPACE_DIR
########### PACKAGE_NAME
########### PACKAGE_INSTALL_VERSION
########### PACKAGE_VERSION
########### NEW_USE_FILE
#################################################################################################

if(EXISTS ${WORKSPACE_DIR}/install/${PACKAGE_NAME}/${PACKAGE_INSTALL_VERSION}/share/Use${PACKAGE_NAME}-${PACKAGE_VERSION}.cmake)
	#first step getting infos from already installed package version
	include(${WORKSPACE_DIR}/install/${PACKAGE_NAME}/${PACKAGE_INSTALL_VERSION}/share/Use${PACKAGE_NAME}-${PACKAGE_VERSION}.cmake)
else()
	return()
endif()

#registering interesting infos for each existing component

foreach(component IN ITEMS ${${PACKAGE_NAME}_COMPONENTS})
	if(NOT ${${PACKAGE_NAME}_${component}_TYPE} STREQUAL "TEST")
		list(APPEND INSTALLED_COMPONENTS ${component})
		set(${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE 0) #initializing usage of headers
	endif()
endforeach()

foreach(component IN ITEMS ${INSTALLED_COMPONENTS})
	if(	${${PACKAGE_NAME}_${component}_TYPE} STREQUAL "HEADER")
		set(INSTALLED_${component}_TYPE HEADER)

		set(INSTALLED_${component}_HEADER_DIR_NAME ${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME})
		math(EXPR NUMBER_OF_USAGES ${${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE}+1)
		set(${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE ${NUMBER_OF_USAGES})

		set(INSTALLED_${component}_HEADERS ${${PACKAGE_NAME}_${component}_HEADERS})
	elseif( ${${PACKAGE_NAME}_${component}_TYPE} STREQUAL "STATIC")
		set(INSTALLED_${component}_TYPE STATIC)

		set(INSTALLED_${component}_HEADER_DIR_NAME ${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME})
		math(EXPR NUMBER_OF_USAGES ${${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE}+1)
		set(${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE ${NUMBER_OF_USAGES})

		set(INSTALLED_${component}_HEADERS ${${PACKAGE_NAME}_${component}_HEADERS})
		set(INSTALLED_${component}_BINARY_NAME ${${PACKAGE_NAME}_${component}_BINARY_NAME}) 
		set(INSTALLED_${component}_BINARY_NAME_DEBUG ${${PACKAGE_NAME}_${component}_BINARY_NAME_DEBUG}) 

	elseif( ${${PACKAGE_NAME}_${component}_TYPE} STREQUAL "SHARED")
		set(INSTALLED_${component}_TYPE SHARED)

		set(INSTALLED_${component}_HEADER_DIR_NAME ${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME})
		math(EXPR NUMBER_OF_USAGES ${${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE}+1)
		set(${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME}_NB_USAGE ${NUMBER_OF_USAGES})

		set(INSTALLED_${component}_HEADERS ${${PACKAGE_NAME}_${component}_HEADERS})
		set(INSTALLED_${component}_BINARY_NAME ${${PACKAGE_NAME}_${component}_BINARY_NAME})
		set(INSTALLED_${component}_BINARY_NAME_DEBUG ${${PACKAGE_NAME}_${component}_BINARY_NAME_DEBUG}) 
	elseif( ${${PACKAGE_NAME}_${component}_TYPE} STREQUAL "MODULE")
		set(INSTALLED_${component}_TYPE MODULE)
		set(INSTALLED_${component}_BINARY_NAME ${${PACKAGE_NAME}_${component}_BINARY_NAME})
		set(INSTALLED_${component}_BINARY_NAME_DEBUG ${${PACKAGE_NAME}_${component}_BINARY_NAME_DEBUG}) 

	elseif(	${${PACKAGE_NAME}_${component}_TYPE} STREQUAL "EXAMPLE")
		set(INSTALLED_${component}_TYPE EXAMPLE)
		set(INSTALLED_${component}_BINARY_NAME ${${PACKAGE_NAME}_${component}_BINARY_NAME})
		set(INSTALLED_${component}_BINARY_NAME_DEBUG ${${PACKAGE_NAME}_${component}_BINARY_NAME_DEBUG}) 

	elseif( ${${PACKAGE_NAME}_${component}_TYPE} STREQUAL "APP")
		set(INSTALLED_${component}_TYPE APP)
		set(INSTALLED_${component}_BINARY_NAME ${${PACKAGE_NAME}_${component}_BINARY_NAME})
		set(INSTALLED_${component}_BINARY_NAME_DEBUG ${${PACKAGE_NAME}_${component}_BINARY_NAME_DEBUG}) 
	endif()
endforeach()

# now include the new Use file to install to that we know all the required information about things to install
include(${NEW_USE_FILE})
set(TO_CHECK_COMPONENTS ${INSTALLED_COMPONENTS})
foreach(component IN ITEMS ${INSTALLED_COMPONENTS}) #for each existing component
	list(FIND ${PACKAGE_NAME}_COMPONENTS ${component} FIND_INDEX)
	if(FIND_INDEX EQUAL -1)#component no more exists => remove corresponding files if necessary
		message("need to remove ${component}")
		remove_Installed_Component(${component} ${PACKAGE_NAME} ${PACKAGE_INSTALL_VERSION} ${WORKSPACE_DIR})
		list(REMOVE_ITEM TO_CHECK_COMPONENTS ${component})
	endif()
endforeach()

#component exists, check for header files/folders suppression/changes
if(TO_CHECK_COMPONENTS)
	check_Headers_Modifications("${TO_CHECK_COMPONENTS}" ${PACKAGE_NAME} ${PACKAGE_INSTALL_VERSION} ${WORKSPACE_DIR})
endif()
