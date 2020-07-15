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

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Local_Static_Site_Project| replace:: ``create_Local_Static_Site_Project``
#  .. _create_Local_Static_Site_Project:
#
#  create_Local_Static_Site_Project
#  --------------------------------
#
#   .. command:: create_Local_Static_Site_Project(SUCCESS package repo_addr push_site package_url site_url)
#
#     Create a local repository for the package's lone static site.
#
#      :package: the name of target package.
#      :repo_addr: the address of the git repository for package static site.
#      :push_site: if TRUE the committed content after creation will be pushed to remote.
#      :package_url: the URL of the package project page (referenced in static site).
#      :site_url: the URL of the package statis site.
#
#      :SUCCESS: the output variable that is TRUE if creation succeed, FALSE otherwise.
#
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
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/cmake/patterns/static_sites/package ${WORKSPACE_DIR}/sites/packages/${package}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/build)#create the folder containing the site from the pattern folder

  set(PACKAGE_NAME ${package})
	set(PACKAGE_PROJECT_URL ${package_url})
	set(PACKAGE_SITE_URL ${site_url})
	configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/CMakeLists.txt.in ${WORKSPACE_DIR}/sites/packages/${package}/CMakeLists.txt @ONLY)#adding the cmake project file to the static site project

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

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Local_Static_Site_Project| replace:: ``update_Local_Static_Site_Project``
#  .. _update_Local_Static_Site_Project:
#
#  update_Local_Static_Site_Project
#  --------------------------------
#
#   .. command:: update_Local_Static_Site_Project(package package_url site_url)
#
#     Update the local repository for the package's lone static site.
#
#      :package: the name of target package.
#      :package_url: the URL of the package project page (referenced in static site).
#      :site_url: the URL of the package statis site.
#
function(update_Local_Static_Site_Project package package_url site_url)
update_Static_Site_Repository(${package}) # updating the repository from git
#reconfigure the root CMakeLists and README to automatically manage evolution in PID
set(PACKAGE_NAME ${package})
set(PACKAGE_PROJECT_URL ${package_url})
set(PACKAGE_SITE_URL ${site_url})
configure_file(${WORKSPACE_DIR}/cmake/patterns/static_sites/CMakeLists.txt.in ${WORKSPACE_DIR}/sites/packages/${package}/CMakeLists.txt @ONLY)#modifying the cmake project file to the static site project
endfunction(update_Local_Static_Site_Project)

#.rst:
#
# .. ifmode:: internal
#
#  .. |static_Site_Project_Exists| replace:: ``static_Site_Project_Exists``
#  .. _static_Site_Project_Exists:
#
#  static_Site_Project_Exists
#  --------------------------
#
#   .. command:: static_Site_Project_Exists(SITE_EXISTS PATH_TO_SITE package)
#
#     Check if the package lone static site repository exists in the workspace.
#
#      :package: the name of target package.
#
#      :SITE_EXISTS: the output variable that is TRUE is static site repository exists, FALSE otherwise.
#      :PATH_TO_SITE: the output variable that contains the path to the static site repository if it exists, empty otherwise.
#
function(static_Site_Project_Exists SITE_EXISTS PATH_TO_SITE package)
set(SEARCH_PATH ${WORKSPACE_DIR}/sites/packages/${package})
if(EXISTS ${SEARCH_PATH} AND IS_DIRECTORY ${SEARCH_PATH})
	set(${SITE_EXISTS} TRUE PARENT_SCOPE)
else()
	set(${SITE_EXISTS} FALSE PARENT_SCOPE)
endif()
set(${PATH_TO_SITE} ${SEARCH_PATH} PARENT_SCOPE)
endfunction(static_Site_Project_Exists)

#.rst:
#
# .. ifmode:: internal
#
#  .. |build_Package_Static_Site| replace:: ``build_Package_Static_Site``
#  .. _build_Package_Static_Site:
#
#  build_Package_Static_Site
#  -------------------------
#
#   .. command:: build_Package_Static_Site(package framework)
#
#     Build the lone static site of a package being it a lone static site or part of a framework.
#
#      :package: the name of target package.
#      :framework: the name of the framework package belongs to, or empty string for a lone static site.
#
function (build_Package_Static_Site package framework)
if(framework)
	execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR}/sites/frameworks/${framework}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
	execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} build
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
else()
	execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR}/sites/packages/${package}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package}/build)
	execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} build
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package}/build)
endif()
endfunction(build_Package_Static_Site)

################################################################################
#################Management of frameworks life cycle ###########################
################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |framework_Project_Exists| replace:: ``framework_Project_Exists``
#  .. _framework_Project_Exists:
#
#  framework_Project_Exists
#  ------------------------
#
#   .. command:: framework_Project_Exists(SITE_EXISTS PATH_TO_SITE framework)
#
#     Check whether the repository for a given framework exists in workspace.
#
#      :framework: the name of the target framework.
#
#      :SITE_EXISTS: the output variable that is TRUE if the framework repository lies in workspace.
#      :PATH_TO_SITE: the output variable that contains the path to the framework repository.
#
function(framework_Project_Exists SITE_EXISTS PATH_TO_SITE framework)
set(SEARCH_PATH ${WORKSPACE_DIR}/sites/frameworks/${framework})
if(EXISTS ${SEARCH_PATH} AND IS_DIRECTORY ${SEARCH_PATH})
	set(${SITE_EXISTS} TRUE PARENT_SCOPE)
else()
	set(${SITE_EXISTS} FALSE PARENT_SCOPE)
endif()
set(${PATH_TO_SITE} ${SEARCH_PATH} PARENT_SCOPE)
endfunction(framework_Project_Exists)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Framework_Exists| replace:: ``check_Framework_Exists``
#  .. _check_Framework_Exists:
#
#  check_Framework_Exists
#  ----------------------
#
#   .. command:: check_Framework_Exists(CHECK_OK framework)
#
#     Check whether a framework exists.
#
#      :framework: the name of the target framework.
#
#      :CHECK_OK: the output variable that is TRUE if the framework exists (already install or installable).
#
function(check_Framework_Exists CHECK_OK framework)
  include_Framework_Reference_File(REF_EXIST ${framework})
	if(REF_EXIST)
		set(${CHECK_OK} TRUE PARENT_SCOPE)
		return()
	else()
		framework_Project_Exists(FOLDER_EXISTS PATH_TO_SITE ${framework})
		if(FOLDER_EXISTS)#generate the reference file on demand
			execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} referencing
                      WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
			include_Framework_Reference_File(REF_EXIST ${framework})
			if(REF_EXIST)
				set(${CHECK_OK} TRUE PARENT_SCOPE)
				return()
			endif()
		endif()
	endif()
	set(${CHECK_OK} FALSE PARENT_SCOPE)
endfunction(check_Framework_Exists)

#.rst:
#
# .. ifmode:: internal
#
#  .. |load_Framework| replace:: ``load_Framework``
#  .. _load_Framework:
#
#  load_Framework
#  --------------
#
#   .. command:: load_Framework(LOADED framework)
#
#     Putting the framework repository into the workspace, or update it if it is already there.
#
#      :framework: the name of the target framework.
#
#      :LOADED: the output variable that is TRUE if the framework has been loaded.
#
function(load_Framework LOADED framework)
	set(${LOADED} FALSE PARENT_SCOPE)
	set(FOLDER_EXISTS FALSE)
  include_Framework_Reference_File(REF_EXIST ${framework})

	framework_Project_Exists(FOLDER_EXISTS PATH_TO_SITE ${framework})
	if(FOLDER_EXISTS)
		message("[PID] INFO: updating framework ${framework} (this may take a long time)")
		update_Framework_Repository(${framework}) #update the repository to be sure to work on last version
		if(NOT REF_EXIST) #if reference file does not exist we use the project present in the workspace. This way we may force it to generate references
			execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} referencing
                      WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
      include_Framework_Reference_File(REF_EXIST ${framework})
			if(REF_EXIST)
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Framework_Site| replace:: ``get_Framework_Site``
#  .. _get_Framework_Site:
#
#  get_Framework_Site
#  ------------------
#
#   .. command:: get_Framework_Site(framework SITE)
#
#    Get the URL of the static site generated by the given framework.
#
#      :framework: the name of the target framework.
#
#      :SITE: the output variable that contains the URL of framework.
#
function(get_Framework_Site framework SITE)
set(${SITE} ${${framework}_SITE} PARENT_SCOPE)
endfunction(get_Framework_Site)
