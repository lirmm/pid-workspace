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

include(CMakeParseArguments)

#.rst:
#
# .. ifmode:: user
#
#  .. |import_PID_Workspace| replace:: ``import_PID_Workspace``
#  .. _import_PID_Workspace:
#
#  import_PID_Workspace
#  --------------------
#
#   .. command:: import_PID_Workspace(path)
#
#     Import a PID workspace into current non PID CMake project.
#
#   .. rubric:: Optional parameters
#
#   :PATH <path>: the path to the target workspace root folder. If you only want to set the path you can omit the PATH keyword.
#
#   :MODE <mode>: the build mode (Release or Debug) you want to use for PID libraries.
#
#   :SYSTEM_DEPENDENCIES <list of external dependencies>: the list of OS dependencies to use. Will force all external dependencies of PID packages to be system dependencies.
#
#   .. admonition:: Effects
#     :class: important
#
#     After the call, the PID workspace can be used in the local project.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      set(PATH_TO_PID_WORKSPACE /opt/pid/pid-workspace CACHE PATH "")
#      import_PID_Workspace(PATH ${PATH_TO_PID_WORKSPACE})
#
#   .. code-block:: cmake
#
#      import_PID_Workspace(MODE Release SYSTEM_DEPENDENCIES eigen boost)
#
macro(import_PID_Workspace)
#interpret user arguments
set(oneValueArgs PATH MODE)
set(multiValueArgs SYSTEM_DEPENDENCIES)
cmake_parse_arguments(IMPORT_PID_WORKSPACE "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
if(${ARGC} EQUAL 0)
	set(path)
elseif(${ARGC} EQUAL 1)
	set(path "${ARGV0}")
else()#there are arguments specified in CMake style
	if(IMPORT_PID_WORKSPACE_PATH)
		set(path "${IMPORT_PID_WORKSPACE_PATH}")
	else()
		set(path)
	endif()
endif()

if(NOT path)
	#test if the workspace has been deployed has a submodule directly inside the external project
	if(EXISTS ${CMAKE_SOURCE_DIR}/pid-workspace AND IS_DIRECTORY ${CMAKE_SOURCE_DIR}/pid-workspace)
		set(workspace_path ${CMAKE_SOURCE_DIR}/pid-workspace)
	else()
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling import_PID_Workspace, a path must be given to import_PID_Workspace OR you can directly deploy the pid-workspace at the root of your project.")
	endif()
else()
	if(NOT EXISTS ${path})
		if(EXISTS ${CMAKE_SOURCE_DIR}/pid-workspace AND IS_DIRECTORY ${CMAKE_SOURCE_DIR}/pid-workspace)
			set(workspace_path ${CMAKE_SOURCE_DIR}/pid-workspace)
		else()
			message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling import_PID_Workspace, the path to the PID workspace ${path} does not exist.")
		endif()
	else()#otherwise use the user provided path
		set(workspace_path ${path})
	endif()
endif()

if(IMPORT_PID_WORKSPACE_MODE)
	set(mode "${IMPORT_PID_WORKSPACE_MODE}")
else()
	if(CMAKE_BUILD_TYPE AND CMAKE_BUILD_TYPE STREQUAL Release OR CMAKE_BUILD_TYPE STREQUAL Debug)
		set(mode ${CMAKE_BUILD_TYPE})
	else()
		set(mode Release)
	endif()
endif()

if(NOT CMAKE_BUILD_TYPE)
	message("[PID] WARNING : when calling import_PID_Workspace, no known build type defined by project (Release or Debug) ${PROJECT_NAME} and none specified using MODE argument: the Release build is selected by default.")
	set(CMAKE_BUILD_TYPE Release CACHE STRING "build mode (Release or Debug)" FORCE)
endif()

CMAKE_MINIMUM_REQUIRED(VERSION 3.1)#just to ensure that version of CMake tool used in external projects if high enough (supports language standards)

set(CMAKE_INCLUDE_SYSTEM_FLAG_CXX "-I")

########################################################################
############ all PID system path are put into the cmake path ###########
########################################################################
list(APPEND CMAKE_MODULE_PATH ${workspace_path}/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${workspace_path}/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${workspace_path}/cmake/system/commands)
list(APPEND CMAKE_MODULE_PATH ${workspace_path}/cmake/platforms)
list(APPEND CMAKE_MODULE_PATH ${workspace_path}/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${workspace_path}/cmake/find)
list(APPEND CMAKE_MODULE_PATH ${workspace_path}/configurations)
########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_External_Use_Internal_Functions NO_POLICY_SCOPE)

execute_process(COMMAND ${CMAKE_COMMAND} -S ${workspace_path} -B ${workspace_path}/pid
								WORKING_DIRECTORY ${workspace_path}/pid)#force reconfiguration (in case workspace was deployed as a submodule and never configured)

include(${workspace_path}/pid/Workspace_Platforms_Description.cmake) #loading the workspace description configuration

#need to reset the variables used to describe dependencies
reset_Local_Components_Info(${workspace_path} ${mode})
#enforce constraints before finding packages
begin_Progress(workspace GLOBAL_PROGRESS_VAR)
if(IMPORT_PID_WORKSPACE_SYSTEM_DEPENDENCIES)
	enforce_System_Dependencies(NOT_ENFORCED "${IMPORT_PID_WORKSPACE_SYSTEM_DEPENDENCIES}")
	if(NOT_ENFORCED)
		finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : System dependencies ${NOT_ENFORCED} cannot be found.")
	endif()
endif()
endmacro(import_PID_Workspace)

#.rst:
# .. ifmode:: user
#
#  .. |import_PID_Package| replace:: ``import_PID_Package``
#  .. _import_PID_Package:
#
#  import_PID_Package
#  ------------------
#
#  .. command:: import_PID_Package(PACKAGE ... [VERSION ...])
#
#   Import a target package from the currently used PID workspace.
#
#   .. rubric:: Required parameters
#
#   :PACKAGE <string>: the name of the package to import
#
#   .. rubric:: Optional parameters
#
#   :VERSION <version string>: the version of the target package to import.
#
#   .. admonition:: Constraints
#     :class: important
#
#     Must be called AFTER import_PID_Workspace.
#
#   .. admonition:: Effects
#     :class: important
#
#     After the call, components defined by the PID package can be used in the local project.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      import_PID_Package(PACKAGE pid-rpath VERSION 2.1.1)
#
function(import_PID_Package)
set(oneValueArgs PACKAGE NAME VERSION)
set(multiValueArgs)
cmake_parse_arguments(IMPORT_PID_PACKAGE "" "${oneValueArgs}" "" ${ARGN})
if(NOT IMPORT_PID_PACKAGE_PACKAGE AND NOT IMPORT_PID_PACKAGE_NAME)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments passed to import_PID_Package, a package name must be given to using NAME keyword.")
elseif(IMPORT_PID_PACKAGE_PACKAGE)
	set(package_name ${IMPORT_PID_PACKAGE_PACKAGE})
else()
	set(package_name ${IMPORT_PID_PACKAGE_NAME})
endif()
if(NOT IMPORT_PID_PACKAGE_VERSION)
	message("[PID] WARNING : no version given to import_PID_Package, last available version of ${package_name} will be used.")
endif()
manage_Dependent_PID_Package(DEPLOYED ${package_name} "${IMPORT_PID_PACKAGE_VERSION}")
if(NOT DEPLOYED)
	finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling import_PID_Package, the package ${package_name} cannot be found and deployed.")
	return()
endif()
endfunction(import_PID_Package)

#.rst:
# .. ifmode:: user
#
#  .. |bind_PID_Components| replace:: ``bind_PID_Components``
#  .. _bind_PID_Components:
#
#  bind_PID_Components
#  -------------------
#
#  .. command:: bind_PID_Components(EXE|LIB|AR ... COMPONENTS ...)
#
#   Make the given local target depends on a set of PID components, typically libraries.
#
#   .. rubric:: Required parameters
#
#   :EXE|LIB|AR <string>: the name of the local target and its type (EXE= exécutable binary, LIB=shared library, AR= archive library).
#   :COMPONENTS <list of components>: the list of components to use. Each component has the pattern <package_name>/<component_name>
#
#   .. admonition:: Constraints
#     :class: important
#
#     PID Packages used must have been immported using import_PID_Package BEFORE call to this function.
#
#   .. admonition:: Effects
#     :class: important
#
#     After the call, the target depends on given components.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      bind_PID_Components(NAME my-target COMPONENTS pid-rpath/rpathlib)
#
function(bind_PID_Components)
	finish_Progress(${GLOBAL_PROGRESS_VAR})#force finishing progress from first call of bind_PID_Components
	set(oneValueArgs EXE LIB AR)
	set(multiValueArgs COMPONENTS)
	cmake_parse_arguments(BIND_PID_COMPONENTS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
	if(NOT BIND_PID_COMPONENTS_EXE AND NOT BIND_PID_COMPONENTS_LIB AND NOT BIND_PID_COMPONENTS_AR)
		finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling bind_PID_Components, name of the target must be given using EXE or LIB or AR keywords.")
	elseif((BIND_PID_COMPONENTS_EXE AND BIND_PID_COMPONENTS_LIB) OR (BIND_PID_COMPONENTS_EXE AND BIND_PID_COMPONENTS_AR) OR (BIND_PID_COMPONENTS_AR AND BIND_PID_COMPONENTS_LIB))
		finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling bind_PID_Components, EXE and LIB keywords cannot be used together.")
	elseif(BIND_PID_COMPONENTS_EXE)
		set(name ${BIND_PID_COMPONENTS_EXE})
	elseif(BIND_PID_COMPONENTS_LIB)
		set(name ${BIND_PID_COMPONENTS_LIB})
	elseif(BIND_PID_COMPONENTS_AR)
		set(name ${BIND_PID_COMPONENTS_AR})
	endif()

  if(NOT BIND_PID_COMPONENTS_COMPONENTS)
    message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling bind_PID_Components, at least one component name must be given using COMPONENTS keyword.")
    return()
  endif()
	if(BIND_PID_COMPONENTS_EXE)
		set(target_type "EXE")
	elseif(BIND_PID_COMPONENTS_LIB)
		set(target_type "LIB")
	elseif(BIND_PID_COMPONENTS_AR)
		set(target_type "AR")
	endif()
	prepare_Local_Target_Configuration(${name} "${target_type}")
	configure_Local_Target_With_PID_Components(${name} ${target_type} "${BIND_PID_COMPONENTS_COMPONENTS}" ${WORKSPACE_MODE})
endfunction(bind_PID_Components)

#.rst:
# .. ifmode:: user
#
#  .. |bind_Local_Component| replace:: ``bind_Local_Component``
#  .. _bind_Local_Component:
#
#  bind_Local_Component
#  --------------------
#
#  .. command:: bind_Local_Component(EXE|LIB|AR ... COMPONENT ...)
#
#   Make the given local target depends on another local target (i.e. library). Use to manage transitivity between local components when the dependency depends on pid components.
#
#   .. rubric:: Required parameters
#
#   :EXE|LIB|AR <string>: the name of the local target and its type (EXE= exécutable binary, LIB=shared library, AR= archive library).
#   :COMPONENT <string>: the name of the local component target that is the dependency.
#
#   .. admonition:: Effects
#     :class: important
#
#     After the call, the content of the package can be in the local project.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      bind_Local_Component(EXE local COMPONENT mylib)
#
function(bind_Local_Component)
	set(oneValueArgs EXE LIB AR COMPONENT)
	cmake_parse_arguments(BIND_LOCAL_COMPONENT "" "${oneValueArgs}" "" ${ARGN})
	if(NOT BIND_LOCAL_COMPONENT_EXE AND NOT BIND_LOCAL_COMPONENT_LIB AND NOT BIND_LOCAL_COMPONENT_AR)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling bind_Local_Components, name of the target must be given using EXE or LIB or AR keywords.")
	elseif((BIND_LOCAL_COMPONENT_EXE AND BIND_LOCAL_COMPONENT_LIB) OR (BIND_LOCAL_COMPONENT_EXE AND BIND_LOCAL_COMPONENT_AR) OR (BIND_LOCAL_COMPONENT_AR AND BIND_LOCAL_COMPONENT_LIB))
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling bind_Local_Components, EXE and LIB keywords cannot be used together.")
	elseif(BIND_LOCAL_COMPONENT_EXE)
		set(component ${BIND_LOCAL_COMPONENT_EXE})
	elseif(BIND_LOCAL_COMPONENT_LIB)
		set(component ${BIND_LOCAL_COMPONENT_LIB})
	elseif(BIND_LOCAL_COMPONENT_AR)
		set(component ${BIND_LOCAL_COMPONENT_AR})
	endif()

	if(NOT BIND_LOCAL_COMPONENT_COMPONENT)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling bind_Local_Components, a component name must be given using COMPONENT keyword.")
		return()
	endif()
	if(BIND_LOCAL_COMPONENT_EXE)
		set(target_type "EXE")
	elseif(BIND_LOCAL_COMPONENT_LIB)
		set(target_type "LIB")
	elseif(BIND_LOCAL_COMPONENT_AR)
		set(target_type "AR")
	endif()
	#prepare the local target to be bounded with PID components
	prepare_Local_Target_Configuration(${component} ${target_type})
	configure_Local_Target_With_Local_Component(${component} ${target_type} ${BIND_LOCAL_COMPONENT_COMPONENT} ${WORKSPACE_MODE})
endfunction(bind_Local_Component)

#.rst:
# .. ifmode:: user
#
#  .. |add_Runtime_Resources| replace:: ``add_Runtime_Resources``
#  .. _add_Runtime_Resources:
#
#  add_Runtime_Resources
#  ---------------------
#
#  .. command:: add_Runtime_Resources(TARGET ... FILES ... DIRECTORIES ...)
#
#   Make the given files and directories discoverable by pid-rpath
#
#   .. rubric:: Required parameters
#
#   :TARGET <string>: the name of the local target
#   :FILES <list of paths>: the list of files to install. Path are relative to current project root folder.
#   :DIRECTORIES <list of paths>: the list of directories to install. Path are relative to current project root folder.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      add_Runtime_Resources(TARGET my-target FILES my_config.yaml DIRECTORIES config params)
#
function(add_Runtime_Resources)
	set(oneValueArgs TARGET)
	set(multiValueArgs FILES DIRECTORIES)
	cmake_parse_arguments(ADD_RUNTIME_RESOURCES "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	if(NOT ADD_RUNTIME_RESOURCES_TARGET)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling add_Runtime_Resources, the target must be specified using the TARGET keyword.")
	elseif(NOT ADD_RUNTIME_RESOURCES_FILES AND NOT ADD_RUNTIME_RESOURCES_DIRECTORIES)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling add_Runtime_Resources, runtime resources add must specified using the FILES and/or DIRECTORIES keywords.")
	endif()

	if(NOT ADD_RUNTIME_RESOURCES_FILES AND NOT ADD_RUNTIME_RESOURCES_DIRECTORIES)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling add_Runtime_Resources, at list one file (using FILES) or one directory (using DIRECTORIES) must be defined.")
	endif()

	foreach(a_file IN LISTS ADD_RUNTIME_RESOURCES_FILES)
		if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${a_file})
			message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling add_Runtime_Resources, cannot find resource file ${CMAKE_CURRENT_SOURCE_DIR}/${a_file}.")
		endif()
	endforeach()

	foreach(a_dir IN LISTS ADD_RUNTIME_RESOURCES_DIRECTORIES)
		if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${a_dir} OR NOT IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${a_dir})
			message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling add_Runtime_Resources, cannot find resource folder ${CMAKE_CURRENT_SOURCE_DIR}/${a_dir}.")
		endif()
	endforeach()

	#OK we can proceed
	add_Managed_PID_Resources(${ADD_RUNTIME_RESOURCES_TARGET} "${ADD_RUNTIME_RESOURCES_FILES}" "${ADD_RUNTIME_RESOURCES_DIRECTORIES}")
endfunction(add_Runtime_Resources)
