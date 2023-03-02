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


list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(Wrapper_Definition NO_POLICY_SCOPE) # to be able to interpret description of external packages and generate the use files

load_Workspace_Info() #loading the current platform configuration before executing the deploy script

#manage arguments if they are passed as environmentvariables (for non UNIX makefile generators usage)
if(NOT TARGET_VERSION AND DEFINED ENV{version})
	set(TARGET_VERSION $ENV{version} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{version})
	unset(ENV{version})
endif()

if(NOT TARGET_VERSION)
	message(FATAL_ERROR "[PID] CRITICAL ERROR: you must define the version to memorize using version= argument to the memorizing command")
	return()
endif()

get_Package_Type(${TARGET_PACKAGE} PACK_TYPE)
#########################################################################################
#######################################Build script #####################################
#########################################################################################

if(PACK_TYPE STREQUAL "EXTERNAL")
	if(TARGET_VERSION STREQUAL "all")
		message("[PID] INFO : memorizing all versions for external package ${TARGET_PACKAGE} ...")
	else()
		message("[PID] INFO : memorizing version ${TARGET_VERSION} for external package ${TARGET_PACKAGE} ...")
	endif()
		#checking that user input is coherent

	set(package_dir ${WORKSPACE_DIR}/wrappers/${TARGET_PACKAGE})

	if(NOT EXISTS ${package_dir}/build/Build${TARGET_PACKAGE}.cmake)
	  message(FATAL_ERROR "[PID] CRITICAL ERROR : build configuration file has not been generated for ${TARGET_PACKAGE}, please rerun wrapper configuration...")
	  return()
	endif()

	include(${package_dir}/build/Build${TARGET_PACKAGE}.cmake)#load the content description

	if(${TARGET_PACKAGE}_KNOWN_VERSIONS) #check that the target version exist
	  	if(TARGET_VERSION STREQUAL "all")
		  set(all_versions ${${TARGET_PACKAGE}_KNOWN_VERSIONS})
		else()
			list(FIND ${TARGET_PACKAGE}_KNOWN_VERSIONS ${TARGET_VERSION} INDEX)
			if(INDEX EQUAL -1)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : ${TARGET_PACKAGE} external package version ${TARGET_VERSION} is not defined by wrapper of ${TARGET_PACKAGE}")
				return()
			endif()
			set(all_versions ${TARGET_VERSION})
		endif()
	else()
	  message(FATAL_ERROR "[PID] CRITICAL ERROR : wrapper of ${TARGET_PACKAGE} does not define any version (no version subfolder found in src folder of the wrapper, each name of version folder must match the pattern major.minor.patch) !!! Build aborted ...")
	  return()
	endif()
else()
	if(TARGET_VERSION STREQUAL "all")
		message("[PID] INFO : memorizing all versions for native package ${TARGET_PACKAGE} ...")
		get_Repository_Version_Tags(VERSION_NUMBERS ${TARGET_PACKAGE})
		if(NOT VERSION_NUMBERS)
			message("[PID] ERROR : no known version for native package ${TARGET_PACKAGE}, cannot memorize them.")
			return()
		endif()
		set(all_versions ${VERSION_NUMBERS})
	else()
		message("[PID] INFO : memorizing version ${TARGET_VERSION} for native package ${TARGET_PACKAGE} ...")
		set(all_versions ${TARGET_VERSION})
	endif()
endif()



function(memorize_version_tags version)
	#check if the version tag existed before
	set(add_tag FALSE)
	get_Repository_Version_Tags(VERSION_NUMBERS ${TARGET_PACKAGE})
	if(NOT VERSION_NUMBERS)
		set(add_tag TRUE)
	else()
		list(FIND VERSION_NUMBERS ${version} INDEX)
		if(INDEX EQUAL -1)#version tag not found in existing version tags
			set(add_tag TRUE)
		endif()
	endif()
	#create local tag and push it
	if(add_tag)#simply add the tag since version was not referenced before
		if(PACK_TYPE STREQUAL "NATIVE")
			message(FATAL_ERROR "[PID] ERROR : cannot memorizing version ${version} for native package ${TARGET_PACKAGE} because version has never been released...")
			return()
		endif()
		# for external packages only
		tag_Version(${TARGET_PACKAGE} ${version} TRUE)
		if(REMOTE_ADDR)
			publish_Repository_Version(RESULT ${TARGET_PACKAGE} TRUE ${version} TRUE)
		endif()
	else()#replace existing tag
		if(PACK_TYPE STREQUAL "NATIVE")
			if(REMOTE_ADDR)
				#delete remote tag
				publish_Repository_Version(RESULT ${TARGET_PACKAGE} FALSE ${version} FALSE)
				#if RESULT is false then this was because the tag was not existing -> nothig more to do
				# push same tag to relaunch the CI process
				publish_Repository_Version(RESULT ${TARGET_PACKAGE} FALSE ${version} TRUE)
				if(NOT RESULT)
					message(FATAL_ERROR "[PID] ERROR: cannot publish tag ${version} to official remote (${REMOTE_ADDR}) !")
					return()
				endif()
			endif()
		else()
		if(REMOTE_ADDR)
			#delete remote tag
			publish_Repository_Version(RESULT ${TARGET_PACKAGE} TRUE ${version} FALSE)
			#if RESULT is false then this was because the tag was not existing -> nothig more to do
		endif()
		#delete local tag
		tag_Version(${TARGET_PACKAGE} ${version} FALSE)

		#create new local tag
		tag_Version(${TARGET_PACKAGE} ${version} TRUE)
		if(REMOTE_ADDR)
			#push the tag
			publish_Repository_Version(RESULT ${TARGET_PACKAGE} TRUE ${version} TRUE)
		endif()
		endif()
		if(REMOTE_ADDR AND NOT RESULT)
			message(FATAL_ERROR "[PID] ERROR: cannot publish tag ${version} to official remote (${REMOTE_ADDR}) !")
			return()
		endif()
		message("[PID] INFO : external package ${TARGET_PACKAGE} version ${version} is memorized !")
	endif()
endfunction()

foreach(a_version IN LISTS all_versions)
	memorize_version_tags(${a_version})
endforeach()
