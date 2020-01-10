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
if(PID_PLUGINS_MANAGEMENT_INCLUDED)
  return()
endif()
set(PID_PLUGINS_MANAGEMENT_INCLUDED TRUE)
##########################################################################################

include(PID_Contribution_Space_Functions NO_POLICY_SCOPE)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins_In_Package| replace:: ``manage_Plugins_In_Package``
#  .. _manage_Plugins_In_Package:
#
#  manage_Plugins_In_Package
#  -------------------------
#
#   .. command:: manage_Plugins_In_Package()
#
#    Manage actions of activated/deactivated plugins in currently built package.
#
function(manage_Plugins_In_Package)
include(${WORKSPACE_DIR}/pid/Workspace_Plugins_Info.cmake OPTIONAL RESULT_VARIABLE res)
if(NOT res STREQUAL NOTFOUND)
  foreach(plugin IN LISTS WORKSPACE_INACTIVE_PLUGINS)
		if(${plugin}_PLUGIN_RESIDUAL_FILES)# if the plugin generates residual files we need to exclude them from source tree using .gitignore
			dereference_Residual_Files(${plugin})
		endif()
		deactivate_Plugin(${plugin})
	endforeach()
  foreach(plugin IN LISTS WORKSPACE_ACTIVE_PLUGINS)
		if(${plugin}_PLUGIN_RESIDUAL_FILES)# if the plugin generates residual files we need to exclude them from source tree using .gitignore
			dereference_Residual_Files(${plugin})
		endif()
		activate_Plugin(${plugin})
	endforeach()
endif()
endfunction(manage_Plugins_In_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |activate_Plugin| replace:: ``activate_Plugin``
#  .. _activate_Plugin:
#
#  activate_Plugin
#  ---------------
#
#   .. command:: activate_Plugin(plugin)
#
#    Manage activation of a given plugin in currently built package.
#
#      :plugin: The name of the plugin
#
function(activate_Plugin plugin)
  get_Path_To_Plugin_Dir(PLUG_PATH ${plugin})
  if(PLUG_PATH AND EXISTS ${PLUG_PATH}/plugin_activate.cmake)
    include(${PLUG_PATH}/plugin_activate.cmake)
  	if(${plugin}_PLUGIN_ACTIVATION_MESSAGE)
  		message("[PID] INFO : plugin ${plugin}: ${${plugin}_PLUGIN_ACTIVATION_MESSAGE}.")
  	endif()
  else()
    message("[PID] WARNING: plugin ${plugin} is corrupted, no file to activate it.")
  endif()
endfunction(activate_Plugin)

#.rst:
#
# .. ifmode:: internal
#
#  .. |plugin_Description| replace:: ``plugin_Description``
#  .. _plugin_Description:
#
#  plugin_Description
#  ------------------
#
#   .. command:: plugin_Description(plugin)
#
#   include the plugin description in current context
#
#      :plugin: The name of the plugin
#
macro(plugin_Description plugin)
  get_Path_To_Plugin_Dir(PLUG_PATH ${plugin})
  if(PLUG_PATH)
    include(${PLUG_PATH}/plugin_description.cmake OPTIONAL)
  endif()
  set(PLUG_PATH)
endmacro(plugin_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deactivate_Plugin| replace:: ``deactivate_Plugin``
#  .. _deactivate_Plugin:
#
#  deactivate_Plugin
#  -----------------
#
#   .. command:: deactivate_Plugin(plugin)
#
#    Manage deactivation of a given plugin in currently built package.
#
#      :plugin: The name of the plugin
#
function(deactivate_Plugin plugin)
  get_Path_To_Plugin_Dir(PLUG_PATH ${plugin})
	if(PLUG_PATH AND EXISTS ${PLUG_PATH}/plugin_deactivate.cmake)
    if(${plugin}_PLUGIN_DEACTIVATION_MESSAGE)
      message("[PID] INFO : plugin ${plugin} : ${${plugin}_PLUGIN_DEACTIVATION_MESSAGE}.")
    endif()
  else()
    if(ADDITIONNAL_DEBUG_INFO)
      message("[PID] INFO: plugin ${plugin} defines no file for deactivation.")
    endif()
	endif()
endfunction(deactivate_Plugin)

#.rst:
#
# .. ifmode:: internal
#
#  .. |dereference_Residual_Files| replace:: ``dereference_Residual_Files``
#  .. _dereference_Residual_Files:
#
#  dereference_Residual_Files
#  --------------------------
#
#   .. command:: dereference_Residual_Files(plugin)
#
#    Dereference the residual files of the pugins (if any) in the git repository so that they will not be part of a commit.
#
#      :plugin: The name of the plugin
#
function(dereference_Residual_Files plugin)
if (NOT ${plugin}_PLUGIN_RESIDUAL_FILES)
	return()
endif()

set(PATH_TO_IGNORE ${CMAKE_SOURCE_DIR}/.gitignore)
file(STRINGS ${PATH_TO_IGNORE} IGNORED_FILES)
if(NOT IGNORED_FILES) #simply write the file from scratch if there is nothing ingnored from now
	file(WRITE ${PATH_TO_IGNORE} "")
	foreach(ignored IN LISTS ${plugin}_PLUGIN_RESIDUAL_FILES)
		file(APPEND ${PATH_TO_IGNORE} "${ignored}\n")
	endforeach()
	execute_process(COMMAND git add ${PATH_TO_IGNORE} WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}) #immediately add it to git reference system to avoid big troubles
	return()
endif()

set(rules_added FALSE)
foreach(ignored IN LISTS ${plugin}_PLUGIN_RESIDUAL_FILES)
	set(add_rule TRUE)
	foreach(already_ignored IN LISTS IGNORED_FILES) #looking if this ignore rule is already written in the .gitignore file
		if(already_ignored STREQUAL ignored)
			set(add_rule FALSE)
			break()
		endif()
	endforeach()
	if(add_rule) #only add te ignore rule if necessary
		file(APPEND ${PATH_TO_IGNORE} "${ignored}\n")
		set(rules_added TRUE)
	endif()
endforeach()
if(rules_added)
	execute_process(COMMAND git add ${PATH_TO_IGNORE} WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}) #immediately add it to git reference system to avoid big troubles
endif()
endfunction(dereference_Residual_Files)
