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
if(PID_EXTERNAL_USE_INTERNAL_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_EXTERNAL_USE_INTERNAL_FUNCTIONS_INCLUDED TRUE)

#all internal functions required by the external use API
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Finding_Functions NO_POLICY_SCOPE)
include(PID_Version_Management_Functions NO_POLICY_SCOPE)
include(PID_Progress_Management_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Configuration_Functions NO_POLICY_SCOPE)
include(PID_Package_Cache_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Build_Targets_Management_Functions NO_POLICY_SCOPE)
include(PID_Deployment_Functions NO_POLICY_SCOPE)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
include(External_Definition NO_POLICY_SCOPE)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Local_Components_Info| replace:: ``reset_Local_Components_Info``
#  .. _reset_Local_Components_Info:
#
#  reset_Local_Components_Info
#  ----------------------------
#
#   .. command:: reset_Local_Components_Info(path mode)
#
#    Reset PID related info for a non PID CMake project
#
#     :path: the path to PID workspace build folder
#
#     :mode: the build mode for target PID package's components
#
function(reset_Local_Components_Info path mode)

  set(WORKSPACE_DIR ${path} CACHE INTERNAL "")
  set(WORKSPACE_MODE ${mode} CACHE INTERNAL "")
  ########################################################################
  ############ default value for PID cache variables #####################
  ########################################################################
  foreach(dep_package IN LISTS ${PROJECT_NAME}_PID_PACKAGES)
  	get_Package_Type(${dep_package} PACK_TYPE)
  	if(PACK_TYPE STREQUAL "EXTERNAL")
  		reset_External_Package_Dependency_Cached_Variables_From_Use(${dep_package} ${WORKSPACE_MODE})
  	else()
  		reset_Native_Package_Dependency_Cached_Variables_From_Use(${dep_package} ${WORKSPACE_MODE})
  	endif()
  endforeach()
  set(${PROJECT_NAME}_PID_PACKAGES CACHE INTERNAL "")#reset list of packages
  reset_Packages_Finding_Variables()
  reset_Temporary_Optimization_Variables()
  #resetting specific variables used to manage components defined locally
  foreach(comp IN LISTS DECLARED_LOCAL_COMPONENTS)
  	set(${comp}_LOCAL_DEPENDENCIES CACHE INTERNAL "")
  	set(${comp}_PID_DEPENDENCIES CACHE INTERNAL "")
  endforeach()
  set(DECLARED_LOCAL_COMPONENTS CACHE INTERNAL "")

  foreach(config IN LISTS DECLARED_SYSTEM_DEPENDENCIES)
  	set(${config}_VERSION_STRING CACHE INTERNAL "")
  	set(${config}_REQUIRED_VERSION_EXACT CACHE INTERNAL "")
  	set(${config}_REQUIRED_VERSION_SYSTEM CACHE INTERNAL "")
  endforeach()
    set(DECLARED_SYSTEM_DEPENDENCIES CACHE INTERNAL "")

    #do not manage automatic install since outside from a PID workspace
    #the install will be done through a global function targetting workspacz
    set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD FALSE CACHE INTERNAL "")
endfunction(reset_Local_Components_Info)


#.rst:
#
# .. ifmode:: internal
#
#  .. |enforce_System_Dependencies| replace:: ``enforce_System_Dependencies``
#  .. _enforce_System_Dependencies:
#
#  enforce_System_Dependencies
#  ----------------------------
#
#   .. command:: enforce_System_Dependencies(list_of_os_deps)
#
#    Force to use OS variants of some PID external dependencies.
#
#     :list_of_os_deps: the list of external dependencies that must be used as os variants
#
#     :NOT_ENFORCED: the output variable that is empty if all dependencies can be enforced as OS variants, and contains the name of the first dependency that cannot be enforced
#
function(enforce_System_Dependencies RESULT list_of_os_deps)
foreach(os_variant IN LISTS list_of_os_deps)
	check_System_Configuration(RESULT_OK CONFIG_NAME CONFIG_CONSTRAINTS "${os_variant}")
	if(NOT RESULT_OK)
    set(${NOT_ENFORCED} ${os_variant} PARENT_SCOPE)
		return()
	endif()
	set(${os_variant}_VERSION_STRING ${${os_variant}_VERSION} CACHE INTERNAL "")
	set(${os_variant}_REQUIRED_VERSION_EXACT TRUE CACHE INTERNAL "")
	set(${os_variant}_REQUIRED_VERSION_SYSTEM TRUE CACHE INTERNAL "")
	add_Chosen_Package_Version_In_Current_Process(${os_variant})#for the use of an os variant
endforeach()
set(${NOT_ENFORCED} PARENT_SCOPE)
endfunction(enforce_System_Dependencies)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Local_Private_Shared_Libraries| replace:: ``get_Local_Private_Shared_Libraries``
#  .. _get_Local_Private_Shared_Libraries:
#
#  get_Local_Private_Shared_Libraries
#  -----------------------------------
#
#   .. command:: get_Local_Private_Shared_Libraries(LIBS local_component)
#
#    Get the shared library not exported by a given component that is not a PID defined component.
#
#     :local_component: the name of the local component
#
#     :LIBS: the output variable containing path to shared libraries
#
function(get_Local_Private_Shared_Libraries LIBS local_component)
	set(${LIBS} PARENT_SCOPE)
	set(undirect_deps)
	#recursion on local components first
	foreach(dep IN LISTS ${local_component}_LOCAL_DEPENDENCIES)
		get_Local_Private_Shared_Libraries(DEP_LIBS ${dep})
		if(DEP_LIBS)
			list(APPEND undirect_deps ${DEP_LIBS})
		endif()
	endforeach()

	#then direct dependencies to PID components
	foreach(dep IN LISTS ${local_component}_PID_DEPENDENCIES)
		extract_Component_And_Package_From_Dependency_String(COMPONENT_NAME RES_PACK ${dep})
		get_Native_Component_Runtime_PrivateLinks_Dependencies(LIST_OF_DEP_SHARED ${RES_PACK} ${COMPONENT_NAME} FALSE ${WORKSPACE_MODE})
		if(LIST_OF_DEP_SHARED)
			list(APPEND undirect_deps ${LIST_OF_DEP_SHARED})
		endif()
	endforeach()

	if(undirect_deps)
		list(REMOVE_DUPLICATES undirect_deps)
	endif()
	set(${LIBS} ${undirect_deps} PARENT_SCOPE)
endfunction(get_Local_Private_Shared_Libraries)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Local_Component_Symlinks| replace:: ``generate_Local_Component_Symlinks``
#  .. _generate_Local_Component_Symlinks:
#
#  generate_Local_Component_Symlinks
#  ----------------------------------
#
#   .. command:: generate_Local_Component_Symlinks(local_component local_dependency undirect_deps)
#
#    Generate symlinks for runtime resources in the install tree of a non PID defined component.
#
#     :local_component: the name of the local component (a non PID defined component)
#
#     :local_dependency: the name of a local component (a non PID defined component) that is a dependency for local_component.
#
#     :undirect_deps: private shared libraries for local_component.
#
function(generate_Local_Component_Symlinks local_component local_dependency undirect_deps)
	#recursion on local components first
	foreach(dep IN LISTS ${local_dependency}_LOCAL_DEPENDENCIES)
		generate_Local_Component_Symlinks(${local_component} ${dep} "")
	endforeach()

	foreach(dep IN LISTS ${local_dependency}_PID_DEPENDENCIES)
		extract_Component_And_Package_From_Dependency_String(COMPONENT_NAME RES_PACK ${dep})

		#now generating symlinks in install tree of the component (for exe and shared libs)
		#equivalent of resolve_Source_Component_Runtime_Dependencies in native packages
		### STEP A: create symlinks in install tree
		set(to_symlink ${undirect_deps}) # in case of an executable component add third party (undirect) links

		get_Binary_Location(LOCATION_RES ${RES_PACK} ${COMPONENT_NAME} ${WORKSPACE_MODE})
		list(APPEND to_symlink ${LOCATION_RES})

		#1) getting public shared links
		get_Bin_Component_Runtime_Dependencies(INT_DEP_RUNTIME_RESOURCES ${RES_PACK} ${COMPONENT_NAME} ${WORKSPACE_MODE}) #need to resolve external symbols whether the component is exported or not (it may have unresolved symbols coming from shared libraries) + resolve external runtime resources
		if(INT_DEP_RUNTIME_RESOURCES)
			list(APPEND to_symlink ${INT_DEP_RUNTIME_RESOURCES})
		endif()
		#2) getting private shared links (undirect by definition)
		get_Bin_Component_Direct_Runtime_PrivateLinks_Dependencies(RES_PRIVATE_LINKS ${RES_PACK} ${COMPONENT_NAME} ${WORKSPACE_MODE})
		if(RES_PRIVATE_LINKS)
			list(APPEND to_symlink ${RES_PRIVATE_LINKS})
		endif()
		#3) getting direct and undirect runtime resources dependencies
		get_Bin_Component_Runtime_Resources_Dependencies(RES_RESOURCES ${RES_PACK} ${COMPONENT_NAME} ${WORKSPACE_MODE})
		if(RES_RESOURCES)
			list(APPEND to_symlink ${RES_RESOURCES})
		endif()
		#finally create install rule for the symlinks
		if(to_symlink)
			list(REMOVE_DUPLICATES to_symlink)
		endif()
		foreach(resource IN LISTS to_symlink)
			install_Runtime_Symlink(${resource} "${CMAKE_INSTALL_PREFIX}/.rpath" ${local_component})
		endforeach()

		### STEP B: create symlinks in build tree (to allow the runtime resources PID mechanism to work at runtime)
		set(to_symlink) # in case of an executable component add third party (undirect) links
		#no direct runtime resource for the local target BUT it must import runtime resources defined by dependencies
		#1) getting runtime resources of the component dependency
		get_Bin_Component_Runtime_Resources_Dependencies(INT_DEP_RUNTIME_RESOURCES ${RES_PACK} ${COMPONENT_NAME} ${WORKSPACE_MODE}) #resolve external runtime resources
		if(INT_DEP_RUNTIME_RESOURCES)
			list(APPEND to_symlink ${INT_DEP_RUNTIME_RESOURCES})
		endif()
		#2) getting component as runtime ressources if it a pure runtime entity (dynamically loaded library)
		if(${RES_PACK}_${COMPONENT_NAME}_TYPE STREQUAL "MODULE")
			list(APPEND to_symlink ${${RES_PACK}_ROOT_DIR}/lib/${${RES_PACK}_${COMPONENT_NAME}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
		elseif(${RES_PACK}_${COMPONENT_NAME}_TYPE STREQUAL "APP" OR ${RES_PACK}_${COMPONENT_NAME}_TYPE STREQUAL "EXAMPLE")
			list(APPEND to_symlink ${${RES_PACK}_ROOT_DIR}/bin/${${RES_PACK}_${COMPONENT_NAME}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
		endif()
		#finally create install rule for the symlinks
		if(to_symlink)
			list(REMOVE_DUPLICATES to_symlink)
		endif()
		foreach(resource IN LISTS to_symlink)
			create_Runtime_Symlink(${resource} "${CMAKE_BINARY_DIR}/.rpath" ${local_component})
		endforeach()
	endforeach()
endfunction(generate_Local_Component_Symlinks)


#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Dependent_PID_Package| replace:: ``manage_Dependent_PID_Package``
#  .. _manage_Dependent_PID_Package:
#
#  manage_Dependent_PID_Package
#  ----------------------------
#
#   .. command:: manage_Dependent_PID_Package(DEPLOYED package version)
#
#    Deploy a PID package into the PID workspace from a local (non PID) project.
#
#     :package: the name of the package
#
#     :version: the version of the package (may be left empty)
#
#     :DEPLOYED: the output variable that is TRUE if package has been deployed, FALSE otherwise.
#
function(manage_Dependent_PID_Package DEPLOYED package version)
  append_Unique_In_Cache(${PROJECT_NAME}_PID_PACKAGES ${package})#reset list of packages
  if(NOT version)
  	find_package(${package} REQUIRED)
  else()
  	find_package(${package} ${version} EXACT REQUIRED)
  endif()

  if(NOT ${package}_FOUND)
    #TODO deploy from workspace
    set(ENV{manage_progress} FALSE)
    if(version)
    execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} deploy package=${package} version=${version}
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
    else()
    execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} deploy package=${package}
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
    endif()
    unset(ENV{manage_progress})
    #find again to see if deployment process went well
    if(NOT version)
    	find_package(${package} REQUIRED)
    else()
    	find_package(${package} ${version} EXACT REQUIRED)
    endif()
  endif()

  if(${package}_FOUND)
    set(${DEPLOYED} TRUE PARENT_SCOPE)
    resolve_Package_Dependencies(${package} ${WORKSPACE_MODE} TRUE)#TODO from here ERROR due to bad dependency (maybe a BUG in version resolution)
    set(${package}_RPATH ${${package}_ROOT_DIR}/.rpath CACHE INTERNAL "")
  else()
    set(${DEPLOYED} FALSE PARENT_SCOPE)
  endif()
endfunction(manage_Dependent_PID_Package)
