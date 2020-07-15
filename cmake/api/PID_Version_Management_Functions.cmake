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
if(PID_VERSION_MANAGEMENT_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_VERSION_MANAGEMENT_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_PID_Version_Variable| replace:: ``init_PID_Version_Variable``
#  .. _init_PID_Version_Variable:
#
#  init_PID_Version_Variable
#  -------------------------
#
#   .. command:: init_PID_Version_Variable(project_name path_to_project)
#
#     Initialize global variable describing the version of PID in use
#
#      :project_name: the name of target project.
#      :path_to_project: the path to target project repository in local workspace.
#
function(init_PID_Version_Variable project_name path_to_project)
if(NOT EXISTS ${WORKSPACE_DIR}/build/PID_version.cmake)#if workspace has not been built (or build files deleted), then build it to get the version
	execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR} WORKING_DIRECTORY ${WORKSPACE_DIR}/build)
endif()
include(${WORKSPACE_DIR}/build/PID_version.cmake) # get the current workspace version

if(	EXISTS ${path_to_project}/share/cmake/${project_name}_PID_Version.cmake)# get the workspace version with wich the package has been built
	#The file already resides in package shared files
	include(${path_to_project}/share/cmake/${project_name}_PID_Version.cmake)
	if(PID_WORKSPACE_VERSION VERSION_LESS ${project_name}_PID_VERSION)#workspace need to be updated
		update_Workspace_Repository("official")
		execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR} WORKING_DIRECTORY ${WORKSPACE_DIR}/build)#reconfigure workspace
		include(${WORKSPACE_DIR}/build/PID_version.cmake) # get the current workspace version AGAIN (most up to date version)
		if(PID_WORKSPACE_VERSION VERSION_LESS ${project_name}_PID_VERSION)#still less => impossible
			message(WARNING "[PID] WARNING : PID version ${${project_name}_PID_VERSION} of ${project_name} is corrupted since it is greater than most up to date version of official workspace (${PID_WORKSPACE_VERSION}).")
			set(${project_name}_PID_VERSION ${PID_WORKSPACE_VERSION} CACHE INTERNAL "")
			file(WRITE ${path_to_project}/share/cmake/${project_name}_PID_Version.cmake "set(${project_name}_PID_VERSION ${${project_name}_PID_VERSION} CACHE INTERNAL \"\")")#save the PID version with which the package has been built
		endif()
  elseif(PID_WORKSPACE_VERSION VERSION_GREATER ${project_name}_PID_VERSION)
    # if workspace version > package version: the workspace version of scripts should be able to manage difference between versions
    # by using the ${PROJECT_NAME}_PID_VERSION variable (inside package) or ${package_name}_PID_VERSION (outside package)
    # Choice is made to update the PID version of current project so that when released next it will provoque the automatic update of workspace
		set(${project_name}_PID_VERSION ${PID_WORKSPACE_VERSION} CACHE INTERNAL "")
		file(WRITE ${path_to_project}/share/cmake/${project_name}_PID_Version.cmake "set(${project_name}_PID_VERSION ${${project_name}_PID_VERSION} CACHE INTERNAL \"\")")#save the PID version with which the package has been built
		message("[PID] INFO : new PID system version for ${project_name} is: ${${project_name}_PID_VERSION}.")
	endif()
else()
	set(${project_name}_PID_VERSION ${PID_WORKSPACE_VERSION})#if no version defined yet then set it to the current workspace one
	file(WRITE ${path_to_project}/share/cmake/${project_name}_PID_Version.cmake "set(${project_name}_PID_VERSION ${${project_name}_PID_VERSION} CACHE INTERNAL \"\")")#save the PID version with which the package has been built
	message("[PID] INFO : PID system version set for ${project_name}: ${${project_name}_PID_VERSION}.")
endif()
endfunction(init_PID_Version_Variable)

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Workspace_For_Required_PID_Version| replace:: ``update_Workspace_For_Required_PID_Version``
#  .. _update_Workspace_For_Required_PID_Version:
#
#  update_Workspace_For_Required_PID_Version
#  -----------------------------------------
#
#   .. command:: update_Workspace_For_Required_PID_Version(project_name path_to_project)
#
#     Update the workspace if its version is not up to date considering requirements of a binary package
#
#      :package: the name of target project.
#      :path_to_package: the path to target project repository in local workspace.
#
function(update_Workspace_For_Required_PID_Version package path_to_package)
  #first get the global PID_WORKSPACE_VERSION
  if(NOT PID_WORKSPACE_VERSION)#workspace version is unknown for now in current context
    if(NOT EXISTS ${WORKSPACE_DIR}/build/PID_version.cmake)#if workspace has not been built (or build files deleted), then build it to get the version
    	execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR} WORKING_DIRECTORY ${WORKSPACE_DIR}/build)
    endif()
    include(${WORKSPACE_DIR}/build/PID_version.cmake) # get the current workspace version
  endif()
  if(	EXISTS ${path_to_package}/share/cmake/${package}_PID_Version.cmake)# get the workspace version with wich the package has been built
    include(${path_to_package}/share/cmake/${package}_PID_Version.cmake)
    if(PID_WORKSPACE_VERSION VERSION_LESS ${package}_PID_VERSION)#workspace need to be updated
  		update_Workspace_Repository("official")
  		execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR} WORKING_DIRECTORY ${WORKSPACE_DIR}/build)#reconfigure workspace
  		include(${WORKSPACE_DIR}/build/PID_version.cmake) # get the current workspace version AGAIN (most up to date version)
  		if(PID_WORKSPACE_VERSION VERSION_LESS ${package}_PID_VERSION)#still less => impossible
  			message(WARNING "[PID] WARNING : PID version ${${package}_PID_VERSION} of ${package} is corrupted since it is greater than most up to date version of official workspace (${PID_WORKSPACE_VERSION}).")
  			set(${package}_PID_VERSION ${PID_WORKSPACE_VERSION} CACHE INTERNAL "")
  		endif()
    endif()
  endif()#if it does not exists it means the required workspace version is below version 4 => no need to update
endfunction(update_Workspace_For_Required_PID_Version)
