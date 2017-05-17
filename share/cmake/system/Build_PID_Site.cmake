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

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
include(PID_Package_Documentation_Management_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)

# managing script arguments
if(NOT DEFINED TARGET_PACKAGE OR TARGET_PACKAGE STREQUAL "")
	message("[PID] ERROR : the target package for which the static website is built is not defined !")
endif()

if(DEFINED SYNCHRO AND SYNCHRO STREQUAL "false")
	set(push_site FALSE)
else()
	set(push_site TRUE) #push by default
endif()

if(DEFINED FORCED_UPDATE AND FORCED_UPDATE STREQUAL "true")
	set(forced_update TRUE)
else()
	set(forced_update FALSE)
endif()

if(INCLUDES_API_DOC)
	set(include_api_doc TRUE)
else()
	set(include_api_doc FALSE)
endif()

if(INCLUDES_COVERAGE)
	set(include_coverage TRUE)
else()
	set(include_coverage FALSE)
endif()

if(INCLUDES_STATIC_CHECKS)
	set(include_staticchecks TRUE)
else()
	set(include_staticchecks FALSE)
endif()

if(INCLUDES_INSTALLER)
	set(include_installer TRUE)
else()
	set(include_installer FALSE)
endif()

#two different behaviors depending on what to do
if(DEFINED TARGET_FRAMEWORK AND (NOT TARGET_FRAMEWORK STREQUAL "")) # the package site is put into a more global site that references all packages of the same framework

	#1) find or install the framework in the workspace
	load_Framework(LOADED ${TARGET_FRAMEWORK})
	if(NOT LOADED)
		message("[PID] ERROR: cannot build package site because the required framework ${TARGET_FRAMEWORK} cannot be found locally or online. This may be due to a lack of a reference file for this framework in the workspace, ask the author of the framework to provide one and update your workspace before launching again this command.")
		return()
	endif()


elseif(DEFINED SITE_GIT AND (NOT SITE_GIT STREQUAL ""))# the package site is put into a dedicated static site

	set(project_url "${PACKAGE_PROJECT_URL}")
	set(site_url "${PACKAGE_SITE_URL}")
	#1) find or put the package static site in the workspace
	static_Site_Project_Exists(SITE_EXISTS PATH_TO_SITE ${TARGET_PACKAGE})
	if(NOT SITE_EXISTS)
		#install the static site if necessary or create it if it does not exists
		create_Local_Static_Site_Project(SUCCEEDED ${TARGET_PACKAGE} ${SITE_GIT} ${push_site} ${project_url} ${site_url})
		if(NOT SUCCEEDED)
			message("[PID] ERROR : impossible to connect to the static site repository. You are probably not a developer of the package ${package} which explains why you cannot publish the static site.")
			return()
		endif()
	else()
		update_Local_Static_Site_Project(${TARGET_PACKAGE} ${project_url} ${site_url}) # update static site repository, to ensure its synchronization
	endif()
else()
	message("[PID] CRITICAL ERROR: cannot build package site due to bad arguments. This situation should never appear so you may face a BUG in PID. Please contact PID developers.")
endif()

#2) clean generate and copy files according to project documentation
produce_Static_Site_Content(${TARGET_PACKAGE} "${TARGET_FRAMEWORK}" ${TARGET_VERSION} ${TARGET_PLATFORM} ${include_api_doc}  ${include_coverage} ${include_staticchecks} ${include_installer} ${forced_update}) # copy everything needed

#3) build static site
build_Static_Site(${TARGET_PACKAGE} "${TARGET_FRAMEWORK}")

#4) if required push to static site official repository
if(push_site)
	if(DEFINED TARGET_FRAMEWORK AND (NOT TARGET_FRAMEWORK STREQUAL ""))
		publish_Framework_Repository(${TARGET_FRAMEWORK} PUBLISHED)
		if(PUBLISHED)
			message("[PID] INFO : framework ${TARGET_FRAMEWORK} repository has been updated on server with new content from package ${TARGET_PACKAGE}.")
		else()
			message("[PID] WARNING : framework ${TARGET_FRAMEWORK} repository has NOT been updated on server with content from package ${TARGET_PACKAGE}.")
		endif()
	else()
		publish_Static_Site_Repository(${TARGET_PACKAGE} PUBLISHED)
		if(PUBLISHED)
			message("[PID] INFO : static site repository of ${TARGET_PACKAGE} has been updated on server.")
		else()
			message("[PID] WARNING : static site repository of ${TARGET_PACKAGE} has been updated on server.")
		endif()
	endif()
else()
	#debug code
	if(DEFINED TARGET_FRAMEWORK AND (NOT TARGET_FRAMEWORK STREQUAL ""))
		message("[PID] INFO : framework ${TARGET_FRAMEWORK} has been updated locally with info from ${TARGET_PACKAGE}.")
	else()
		message("[PID] INFO : static site of ${TARGET_PACKAGE} has been updated locally.")
	endif()

endif()
