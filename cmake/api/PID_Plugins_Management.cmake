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
macro(manage_Plugins_In_Package folder)
  set(target_path ${WORKSPACE_DIR}/pid/${CURRENT_PROFILE}/plugins/${folder})
  if(EXISTS ${target_path})#check if the folder exists, otherwise simply do nothing
    file(GLOB ALL_SCRIPTS "${target_path}/*")
    if(ALL_SCRIPTS)#check if the folder contains scripts, otherwise simply do nothing
      foreach(plugin_script IN LISTS ALL_SCRIPTS)
        include(${plugin_script})#simply include the corresponding cmake script
    	endforeach()
    endif()
  endif()
endmacro(manage_Plugins_In_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins_In_Package_After_Components_Description| replace:: ``manage_Plugins_In_Package_After_Components_Description``
#  .. _manage_Plugins_In_Package_After_Components_Description:
#
#  manage_Plugins_In_Package_After_Components_Description
#  ------------------------------------------------------
#
#   .. command:: manage_Plugins_In_Package_After_Components_Description()
#
#    Callback function used in currently built package to manage specific configuration actions provided by active environments.
#    This callback is called AFTER components of the package have been described.
#
macro(manage_Plugins_In_Package_After_Components_Description)
  manage_Plugins_In_Package(after_comps)
endmacro(manage_Plugins_In_Package_After_Components_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins_In_Package_Before_Components_Description| replace:: ``manage_Plugins_In_Package_Before_Components_Description``
#  .. _manage_Plugins_In_Package_Before_Components_Description:
#
#  manage_Plugins_In_Package_Before_Components_Description
#  -------------------------------------------------------
#
#   .. command:: manage_Plugins_In_Package_Before_Components_Description()
#
#    Callback function used in currently built package to manage specific configuration actions provided by active environments.
#    This callback is called BEFORE description of components of the package.
#
macro(manage_Plugins_In_Package_Before_Components_Description)
 manage_Plugins_In_Package(before_comps)
endmacro(manage_Plugins_In_Package_Before_Components_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins_In_Package_Before_Dependencies_Description| replace:: ``manage_Plugins_In_Package_Before_Dependencies_Description``
#  .. _manage_Plugins_In_Package_Before_Dependencies_Description:
#
#  manage_Plugins_In_Package_Before_Dependencies_Description
#  ---------------------------------------------------------
#
#   .. command:: manage_Plugins_In_Package_Before_Dependencies_Description()
#
#    Callback function used in currently built package to manage specific configuration actions provided by active environments.
#    This callback is called BEFORE description of dependencies of the package.
#
macro(manage_Plugins_In_Package_Before_Dependencies_Description)
 manage_Plugins_In_Package(before_deps)
endmacro(manage_Plugins_In_Package_Before_Dependencies_Description)

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
