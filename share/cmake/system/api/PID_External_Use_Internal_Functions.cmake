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
  reset_Temporary_Optimization_Variables(${mode})
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
#  .. |register_System_Dependency_As_External_Package_OS_Variant| replace:: ``register_System_Dependency_As_External_Package_OS_Variant``
#  .. _register_System_Dependency_As_External_Package_OS_Variant:
#
#  register_System_Dependency_As_External_Package_OS_Variant
#  ---------------------------------------------------------
#
#   .. command:: register_System_Dependency_As_External_Package_OS_Variant(system_dep)
#
#    Register a system dependency as the OS variant of an external package, if possible.
#
#     :system_dep: the system dependency that may be used to enforce usage of OS variant for the corresponding external package
#
#     :NOT_VALIDATED: output variable that is empty if check of config constraint succeeded, conatins the name of teh failing configuration otherwise
#
function(register_System_Dependency_As_External_Package_OS_Variant NOT_VALIDATED system_dep)
  check_System_Configuration(RESULT_OK CONFIG_NAME CONFIG_CONSTRAINTS "${system_dep}")
	if(NOT RESULT_OK)
    set(${NOT_VALIDATED} ${system_dep} PARENT_SCOPE)
		return()
	endif()

  if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferExternal${CONFIG_NAME}.cmake)
    #predefined the use of the external package version with its os variant
    set(${CONFIG_NAME}_VERSION_STRING ${${CONFIG_NAME}_VERSION} CACHE INTERNAL "")
    set(${CONFIG_NAME}_REQUIRED_VERSION_EXACT ${${CONFIG_NAME}_VERSION} CACHE INTERNAL "")
    set(${CONFIG_NAME}_REQUIRED_VERSION_SYSTEM TRUE CACHE INTERNAL "")
    add_Chosen_Package_Version_In_Current_Process(${CONFIG_NAME})#for the use of an os variant
    append_Unique_In_Cache(DECLARED_SYSTEM_DEPENDENCIES ${CONFIG_NAME})
  endif()
  #also check for dependencies of the configuration as they may be external package as well
  foreach(dep_dep IN LISTS ${CONFIG_NAME}_CONFIGURATION_DEPENDENCIES)
    register_System_Dependency_As_External_Package_OS_Variant(DEP_NOT_VALIDATED ${dep_dep})
    if(DEP_NOT_VALIDATED)
      set(${NOT_VALIDATED} ${DEP_NOT_VALIDATED} PARENT_SCOPE)
      return()
    endif()
  endforeach()
  set(${NOT_VALIDATED} PARENT_SCOPE)
endfunction(register_System_Dependency_As_External_Package_OS_Variant)

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
function(enforce_System_Dependencies NOT_ENFORCED list_of_os_deps)
foreach(os_variant IN LISTS list_of_os_deps)
	#check if this configuration is matching an external package defined in PID
  register_System_Dependency_As_External_Package_OS_Variant(REGISTERING_NOTOK ${os_variant})
  if(REGISTERING_NOTOK)
    set(${NOT_ENFORCED} ${REGISTERING_NOTOK} PARENT_SCOPE)
    return()
  endif()
endforeach()
set(${NOT_ENFORCED} PARENT_SCOPE)
endfunction(enforce_System_Dependencies)

#.rst:
#
# .. ifmode:: internal
#
#  .. |prepare_Local_Target_Configuration| replace:: ``prepare_Local_Target_Configuration``
#  .. _prepare_Local_Target_Configuration:
#
#  prepare_Local_Target_Configuration
#  ----------------------------------
#
#   .. command:: prepare_Local_Target_Configuration(local_target target_type)
#
#    Prepare the local CMake target to be capable of using PID components
#
#     :local_target: the local target that is linked with pid components
#
#     :target_type: the type of the target (EXE, LIB, etc.)
#
function(prepare_Local_Target_Configuration local_target target_type)
  #creating specific .rpath folders if build tree to make it possible to use runtime resources in build tree
  if(NOT EXISTS ${CMAKE_BINARY_DIR}/.rpath)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/.rpath)
  endif()

  #a dynamic binary need management of rpath
  if(target_type STREQUAL "EXE" OR target_type STREQUAL "LIB")
    get_property(therpath TARGET ${local_target} PROPERTY INSTALL_RPATH)
    if(NOT (thepath MATCHES "^.*\\.rpath/${local_target}"))#if the rpath has not already been set for this local component
      if(APPLE)
        set_property(TARGET ${local_target} APPEND_STRING PROPERTY INSTALL_RPATH "@loader_path/.rpath/${local_target};@loader_path/../.rpath/${local_target};@loader_path/../lib;@loader_path") #the library targets a specific folder that contains symbolic links to used shared libraries
      elseif(UNIX)
        set_property(TARGET ${local_target} APPEND_STRING PROPERTY INSTALL_RPATH "\$ORIGIN/.rpath/${local_target};\$ORIGIN/../.rpath/${local_target};\$ORIGIN/../lib;\$ORIGIN") #the library targets a specific folder that contains symbolic links to used shared libraries
      endif()
    endif()
  endif()

  #updating list of local components bound to pid components
  append_Unique_In_Cache(DECLARED_LOCAL_COMPONENTS ${local_target})

endfunction(prepare_Local_Target_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |configure_Local_Target_With_PID_Components| replace:: ``configure_Local_Target_With_PID_Components``
#  .. _configure_Local_Target_With_PID_Components:
#
#  configure_Local_Target_With_PID_Components
#  ------------------------------------------
#
#   .. command:: configure_Local_Target_With_PID_Components(local_target mode)
#
#    Reset PID related info for a non PID CMake project
#
#     :local_target: the local target that isbound with pid components
#
#     :target_type: the type of the target (EXE, LIB, etc.)
#
#     :components_list: the list of PID components to bind local target with
#
#     :mode: the build mode for target's PID components
#
function(configure_Local_Target_With_PID_Components local_target target_type components_list mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  if(target_type STREQUAL "EXE" OR target_type STREQUAL "LIB")
    if(APPLE)
      set_property(TARGET ${local_target} APPEND_STRING PROPERTY INSTALL_RPATH "@loader_path/.rpath/${local_target};@loader_path/../.rpath/${local_target};@loader_path/../lib;@loader_path") #the library targets a specific folder that contains symbolic links to used shared libraries
    elseif(UNIX)
      set_property(TARGET ${local_target} APPEND_STRING PROPERTY INSTALL_RPATH "\$ORIGIN/.rpath/${local_target};\$ORIGIN/../.rpath/${local_target};\$ORIGIN/../lib;\$ORIGIN") #the library targets a specific folder that contains symbolic links to used shared libraries
    endif()
  endif()

  #for the given component memorize its pid dependencies
  append_Unique_In_Cache(${local_target}_PID_DEPENDENCIES "${components_list}")

  foreach(dep IN LISTS components_list)
    extract_Component_And_Package_From_Dependency_String(COMPONENT_NAME RES_PACK ${dep})
    if(NOT RES_PACK)
      message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling bind_PID_Components, component name must be preceded by its package name and a / (e.g. <package>/<component>).")
    else()
      list(FIND ${PROJECT_NAME}_PID_PACKAGES ${RES_PACK} INDEX)
      if(INDEX EQUAL -1)
        message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling bind_PID_Components, package ${RES_PACK} has not been declare using import_PID_Package.")
      endif()
    endif()
    is_HeaderFree_Component(IS_HF ${RES_PACK} ${COMPONENT_NAME})
    if(NOT IS_HF)#if not header free the component can be linked
      #create the imported target for that component
      get_Package_Type(${RES_PACK} PACK_TYPE)
      if(PACK_TYPE STREQUAL "EXTERNAL")
        create_External_Component_Dependency_Target(${RES_PACK} ${COMPONENT_NAME} ${WORKSPACE_MODE})
      else()#native component target
        create_Dependency_Target(${RES_PACK} ${COMPONENT_NAME} ${WORKSPACE_MODE}) #create the fake target for component
      endif()
      target_link_libraries(${local_target} PUBLIC ${RES_PACK}-${COMPONENT_NAME}${TARGET_SUFFIX})

      target_include_directories(${local_target} PUBLIC
      $<TARGET_PROPERTY:${RES_PACK}-${COMPONENT_NAME}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)

      target_compile_definitions(${local_target} PUBLIC
      $<TARGET_PROPERTY:${RES_PACK}-${COMPONENT_NAME}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)

      target_compile_options(${local_target} PUBLIC
      $<TARGET_PROPERTY:${RES_PACK}-${COMPONENT_NAME}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>)

      # manage C/C++ language standards
      if(${RES_PACK}_${COMPONENT_NAME}_C_STANDARD${VAR_SUFFIX})#the std C is let optional as using a standard may cause error with posix includes
        get_target_property(CURR_STD_C ${local_target} C_STANDARD)
        is_C_Version_Less(IS_LESS ${CURR_STD_C} ${${RES_PACK}_${COMPONENT_NAME}_C_STANDARD${VAR_SUFFIX}})
        if(IS_LESS)
          set_target_properties(${local_target} PROPERTIES
              C_STANDARD ${${RES_PACK}_${COMPONENT_NAME}_C_STANDARD${VAR_SUFFIX}}
              C_STANDARD_REQUIRED YES
              C_EXTENSIONS NO
          )#setting the standard in use locally
        endif()
      endif()
      get_target_property(CURR_STD_CXX ${local_target} CXX_STANDARD)
      is_CXX_Version_Less(IS_LESS ${CURR_STD_CXX} ${${RES_PACK}_${COMPONENT_NAME}_CXX_STANDARD${VAR_SUFFIX}})
      if(IS_LESS)
        set_target_properties(${local_target} PROPERTIES
          CXX_STANDARD ${${RES_PACK}_${COMPONENT_NAME}_CXX_STANDARD${VAR_SUFFIX}}
          CXX_STANDARD_REQUIRED YES
          CXX_EXTENSIONS NO
          )#setting the standard in use locally
      endif()
      #Note: there is no resolution of dependenct binary packages runtime dependencies (as for native package build) because resolution has already taken place after deployment of dependent packages.

      #For executable we need to resolve everything before linking so that there is no more unresolved symbols
      #equivalent with resolve_Source_Component_Linktime_Dependencies in native packages
      if(target_type STREQUAL "EXE")
        #need to resolve all symbols before linking executable so need to find undirect symbols => same as for native packages
        # 1) searching each direct dependency in other packages
        set(undirect_deps)
        get_Package_Type(${RES_PACK} thetype)
        if(thetype STREQUAL "EXTERNAL")
          get_External_Component_Runtime_PrivateLinks_Dependencies(LIST_OF_DEP_SHARED ${RES_PACK} ${COMPONENT_NAME} FALSE ${WORKSPACE_MODE})
        else()
          get_Native_Component_Runtime_PrivateLinks_Dependencies(LIST_OF_DEP_SHARED ${RES_PACK} ${COMPONENT_NAME} FALSE ${WORKSPACE_MODE})
        endif()
        if(LIST_OF_DEP_SHARED)
          set(undirect_deps ${LIST_OF_DEP_SHARED})
        endif()

        if(undirect_deps) #if true we need to be sure that the rpath-link does not contain some dirs of the rpath (otherwise the executable may not run)
          list(REMOVE_DUPLICATES undirect_deps)
          get_target_property(thelibs ${local_target} LINK_LIBRARIES)
          set_target_properties(${local_target} PROPERTIES LINK_LIBRARIES "${thelibs};${undirect_deps}")
        endif()
      endif()
    endif()
    #now generating symlinks in install tree of the component (for exe and shared libs)
    #equivalent of resolve_Source_Component_Runtime_Dependencies in native packages
    if(target_type STREQUAL "EXE" OR target_type STREQUAL "LIB")
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
        install_Runtime_Symlink(${resource} "${CMAKE_INSTALL_PREFIX}/.rpath" ${local_target})
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
        create_Runtime_Symlink(${resource} "${CMAKE_BINARY_DIR}/.rpath" ${local_target})
      endforeach()
    endif()
  endforeach()

endfunction(configure_Local_Target_With_PID_Components)


#.rst:
#
# .. ifmode:: internal
#
#  .. |configure_Local_Target_With_Local_Component| replace:: ``configure_Local_Target_With_Local_Component``
#  .. _configure_Local_Target_With_Local_Component:
#
#  configure_Local_Target_With_Local_Component
#  -------------------------------------------
#
#   .. command:: configure_Local_Target_With_Local_Component(local_target target_type)
#
#    Configure a local target that is bound with another local target that is using PID components.
#
#     :local_target: the local target that is linked with pid components
#
#     :target_type: the type of the target (EXE, LIB, etc.)
#
#     :dependency: the local target that is linked with local_target and depends on PID components
#
#     :mode: the build mode for pid components
#
function(configure_Local_Target_With_Local_Component local_target target_type dependency mode)

	#updating local dependencies for component
	append_Unique_In_Cache(${local_target}_LOCAL_DEPENDENCIES ${dependency})
	target_link_libraries(${local_target} PUBLIC ${dependency})#linking as usual

	if(target_type STREQUAL "EXE")#resolve global linking for executables !!
		#need to resolve all symbols before linking executable so need to find undirect symbols => same as for native packages
		get_Local_Private_Shared_Libraries(LIBS ${dependency} ${mode})
		if(LIBS)
			get_target_property(thelibs ${local_target} LINK_LIBRARIES)
			set_target_properties(${local_target} PROPERTIES LINK_LIBRARIES "${thelibs};${LIBS}")
		endif()
	endif()
	#then resolve symlinks required by PID components to find their runtime resources
	if(target_type STREQUAL "EXE"
      OR target_type STREQUAL "LIB")
		generate_Local_Component_Symlinks(${local_target} ${dependency} "${LIBS}")
	endif()
endfunction(configure_Local_Target_With_Local_Component)

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
#   .. command:: get_Local_Private_Shared_Libraries(LIBS local_target mode)
#
#    Get the shared library not exported by a given local target (that is not a PID defined component).
#
#     :local_target: the name of the local target
#
#     :mode: the build mode for PID components to use
#
#     :LIBS: the output variable containing path to shared libraries
#
function(get_Local_Private_Shared_Libraries LIBS local_target mode)
	set(${LIBS} PARENT_SCOPE)
	set(undirect_deps)
	#recursion on local components first
	foreach(dep IN LISTS ${local_target}_LOCAL_DEPENDENCIES)
		get_Local_Private_Shared_Libraries(DEP_LIBS ${dep})
		if(DEP_LIBS)
			list(APPEND undirect_deps ${DEP_LIBS})
		endif()
	endforeach()

	#then direct dependencies to PID components
	foreach(dep IN LISTS ${local_target}_PID_DEPENDENCIES)
		extract_Component_And_Package_From_Dependency_String(COMPONENT_NAME RES_PACK ${dep})
    get_Package_Type(${RES_PACK} thetype)
    if(thetype STREQUAL "EXTERNAL")
      get_External_Component_Runtime_PrivateLinks_Dependencies(LIST_OF_DEP_SHARED ${RES_PACK} ${COMPONENT_NAME} FALSE ${mode})
    else()
      get_Native_Component_Runtime_PrivateLinks_Dependencies(LIST_OF_DEP_SHARED ${RES_PACK} ${COMPONENT_NAME} FALSE ${mode})
    endif()
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
#   .. command:: generate_Local_Component_Symlinks(local_target local_dependency undirect_deps)
#
#    Generate symlinks for runtime resources in the install tree of a non PID defined component.
#
#     :local_target: the name of the local component (a non PID defined component)
#
#     :local_dependency: the name of a local component (a non PID defined component) that is a dependency for local_target.
#
#     :undirect_deps: private shared libraries for local_target.
#
function(generate_Local_Component_Symlinks local_target local_dependency undirect_deps)
	#recursion on local components first
	foreach(dep IN LISTS ${local_dependency}_LOCAL_DEPENDENCIES)
		generate_Local_Component_Symlinks(${local_target} ${dep} "")
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
			install_Runtime_Symlink(${resource} "${CMAKE_INSTALL_PREFIX}/.rpath" ${local_target})
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
			create_Runtime_Symlink(${resource} "${CMAKE_BINARY_DIR}/.rpath" ${local_target})
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
  set(previous_mode ${CMAKE_BUILD_TYPE})
  set(CMAKE_BUILD_TYPE ${WORKSPACE_MODE})
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
  list(FIND DECLARED_SYSTEM_DEPENDENCIES ${package} INDEX_IN_DECLARED_OS_DEPS)
  if(NOT INDEX_IN_DECLARED_OS_DEPS EQUAL -1)
    set(${package}_FIND_VERSION_SYSTEM TRUE)
    find_package(${package} ${${package}_VERSION_STRING} EXACT)
  else()
    set(${package}_FIND_VERSION_SYSTEM FALSE)
    if(NOT version)
      find_package(${package})
    else()
      find_package(${package} ${version} EXACT)
    endif()
  endif()
  if(NOT ${package}_FOUND${VAR_SUFFIX})
    #TODO deploy from workspace
    set(ENV{manage_progress} FALSE)

    #TODO need to check this
    if(NOT INDEX_IN_DECLARED_OS_DEPS EQUAL -1)#deploying external dependency as os variant
      execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} deploy package=${package} version=system
                      WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
    else()
      if(version)
        execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} deploy package=${package} version=${version}
        WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
      else()
        execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} deploy package=${package}
        WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
      endif()
    endif()
    unset(ENV{manage_progress})
    #find again to see if deployment process went well
    if(NOT INDEX_IN_DECLARED_OS_DEPS EQUAL -1)
      set(${package}_FIND_VERSION_SYSTEM TRUE)
    else()
      set(${package}_FIND_VERSION_SYSTEM FALSE)
    endif()
    if(NOT version)
    	find_package(${package} REQUIRED)
    else()
    	find_package(${package} ${version} EXACT REQUIRED)
    endif()
  endif()

  if(${package}_FOUND${VAR_SUFFIX})
    set(${DEPLOYED} TRUE PARENT_SCOPE)
    resolve_Package_Dependencies(${package} ${WORKSPACE_MODE} TRUE)
    set(${package}_RPATH ${${package}_ROOT_DIR}/.rpath CACHE INTERNAL "")
  else()
    set(${DEPLOYED} FALSE PARENT_SCOPE)
  endif()
  set(CMAKE_BUILD_TYPE ${previous_mode})
endfunction(manage_Dependent_PID_Package)
