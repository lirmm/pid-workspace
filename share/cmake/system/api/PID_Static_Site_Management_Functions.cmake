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
if(PID_STATIC_SITE_MANAGEMENT_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_STATIC_SITE_MANAGEMENT_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

include(PID_Deployment_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)

################################################################################
#################Management of lone static sites life cycle ####################
################################################################################

### create a local repository for the package's static site
function(create_Local_Static_Site_Project SUCCESS package repo_addr push_site package_url site_url)
set(PATH_TO_STATIC_SITE_FOLDER ${WORKSPACE_DIR}/sites/packages)
clone_Static_Site_Repository(IS_INITIALIZED BAD_URL ${package} ${repo_addr})
set(CONNECTED FALSE)
if(NOT IS_INITIALIZED)#repository must be initialized first
	if(BAD_URL)
		message("[PID] ERROR : impossible to clone the repository of package ${package} static site (maybe ${repo_addr} is a bad repository address or you have no clone rights for this repository). Please contact the administrator of this repository.")
		set(${SUCCESS} FALSE PARENT_SCOPE)
		return()
	endif()
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/share/patterns/static_sites/package ${WORKSPACE_DIR}/sites/packages/${package})#create the folder containing the site from the pattern folder
	set(PACKAGE_NAME ${package})
	set(PACKAGE_PROJECT_URL ${package_url})
	set(PACKAGE_SITE_URL ${site_url})
	configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/CMakeLists.txt.in ${WORKSPACE_DIR}/sites/packages/${package}/CMakeLists.txt @ONLY)#adding the cmake project file to the static site project

	init_Static_Site_Repository(CONNECTED ${package} ${repo_addr} ${push_site})#configuring the folder as a git repository
	if(push_site AND NOT CONNECTED)
		set(${SUCCESS} FALSE PARENT_SCOPE)
	else()
		set(${SUCCESS} TRUE PARENT_SCOPE)
	endif()
else()
	set(${SUCCESS} TRUE PARENT_SCOPE)
endif()#else the repo has been created
endfunction(create_Local_Static_Site_Project)

### update the local site
function(update_Local_Static_Site_Project package package_url site_url)
update_Static_Site_Repository(${package}) # updating the repository from git
#reconfigure the root CMakeLists and README to automatically manage evolution in PID
set(PACKAGE_NAME ${package})
set(PACKAGE_PROJECT_URL ${package_url})
set(PACKAGE_SITE_URL ${site_url})
configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/CMakeLists.txt.in ${WORKSPACE_DIR}/sites/packages/${package}/CMakeLists.txt @ONLY)#modifying the cmake project file to the static site project
endfunction(update_Local_Static_Site_Project)

### checking if the package static site repository exists in the workspace
function(static_Site_Project_Exists SITE_EXISTS PATH_TO_SITE package)
set(SEARCH_PATH ${WORKSPACE_DIR}/sites/packages/${package})
if(EXISTS ${SEARCH_PATH} AND IS_DIRECTORY ${SEARCH_PATH})
	set(${SITE_EXISTS} TRUE PARENT_SCOPE)
else()
	set(${SITE_EXISTS} FALSE PARENT_SCOPE)
endif()
set(${PATH_TO_SITE} ${SEARCH_PATH} PARENT_SCOPE)
endfunction(static_Site_Project_Exists)


### building the static site simply consists in calling adequately the repository project adequate build commands
function (build_Package_Static_Site package framework)
if(framework AND NOT framework STREQUAL "")
	execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR}/sites/frameworks/${framework} WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
	execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} build WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
else()
	execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR}/sites/packages/${package} WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package}/build)
	execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} build WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package}/build)
endif()
endfunction(build_Package_Static_Site)

################################################################################
#################Management of frameworks life cycle ###########################
################################################################################

###
function(framework_Reference_Exists_In_Workspace EXIST framework)
	if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferFramework${framework}.cmake)
		set(${EXIST} TRUE PARENT_SCOPE)
	else()
		set(${EXIST} FALSE PARENT_SCOPE)
	endif()
endfunction(framework_Reference_Exists_In_Workspace)

### checking if the framework site repository exists in the workspace
function(framework_Project_Exists SITE_EXISTS PATH_TO_SITE framework)
set(SEARCH_PATH ${WORKSPACE_DIR}/sites/frameworks/${framework})
if(EXISTS ${SEARCH_PATH} AND IS_DIRECTORY ${SEARCH_PATH})
	set(${SITE_EXISTS} TRUE PARENT_SCOPE)
else()
	set(${SITE_EXISTS} FALSE PARENT_SCOPE)
endif()
set(${PATH_TO_SITE} ${SEARCH_PATH} PARENT_SCOPE)
endfunction(framework_Project_Exists)

### checking that the given framework exists
function(check_Framework CHECK_OK framework)
	framework_Reference_Exists_In_Workspace(REF_EXIST ${framework})
	if(REF_EXIST)
		include(${WORKSPACE_DIR}/share/cmake/references/ReferFramework${framework}.cmake)
		set(${CHECK_OK} TRUE PARENT_SCOPE)
		return()
	else()
		framework_Project_Exists(FOLDER_EXISTS PATH_TO_SITE ${framework})
		if(FOLDER_EXISTS)#generate the reference file on demand
			execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} referencing WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
			framework_Reference_Exists_In_Workspace(REF_EXIST ${framework})
			if(REF_EXIST)
				include(${WORKSPACE_DIR}/share/cmake/references/ReferFramework${framework}.cmake)
				set(${CHECK_OK} TRUE PARENT_SCOPE)
				return()
			endif()
		endif()
	endif()
	set(${CHECK_OK} FALSE PARENT_SCOPE)
endfunction(check_Framework)

### putting the framework repository into the workspace, or update it if it is already there
function(load_Framework LOADED framework)
	set(${LOADED} FALSE PARENT_SCOPE)
	set(FOLDER_EXISTS FALSE)
	framework_Reference_Exists_In_Workspace(REF_EXIST ${framework})
	if(REF_EXIST)
		include(${WORKSPACE_DIR}/share/cmake/references/ReferFramework${framework}.cmake)
	endif()

	framework_Project_Exists(FOLDER_EXISTS PATH_TO_SITE ${framework})
	if(FOLDER_EXISTS)
		message("[PID] INFO: updating framework ${framework} (this may take a long time)")
		update_Framework_Repository(${framework}) #update the repository to be sure to work on last version
		if(NOT REF_EXIST) #if reference file does not exist we use the project present in the workspace. This way we may force it to generate references
			execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} referencing WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
			framework_Reference_Exists_In_Workspace(REF_EXIST ${framework})
			if(REF_EXIST)
				include(${WORKSPACE_DIR}/share/cmake/references/ReferFramework${framework}.cmake)
				set(${LOADED} TRUE PARENT_SCOPE)
			endif()
		else()
			set(${LOADED} TRUE PARENT_SCOPE)
		endif()
	elseif(REF_EXIST) #we can try to clone it if we know where to clone from
		message("[PID] INFO: deploying framework ${framework} in workspace (this may take a long time)")
		deploy_Framework_Repository(IS_DEPLOYED ${framework})
		if(IS_DEPLOYED)
			set(${LOADED} TRUE PARENT_SCOPE)
		endif()
	endif()
endfunction(load_Framework)

###
function(get_Framework_Site framework SITE)
set(${SITE} ${${framework}_FRAMEWORK_SITE} PARENT_SCOPE)
endfunction(get_Framework_Site)
