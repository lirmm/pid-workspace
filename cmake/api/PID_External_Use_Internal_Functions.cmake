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
include(PID_Contribution_Space_Functions NO_POLICY_SCOPE)
include(PID_Profiles_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Configuration_Functions NO_POLICY_SCOPE)
include(PID_Package_Cache_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Build_Targets_Management_Functions NO_POLICY_SCOPE)
include(PID_Deployment_Functions NO_POLICY_SCOPE)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
include(External_Definition NO_POLICY_SCOPE)

macro(load_Platform_Info)
  load_Current_Contribution_Spaces()
  load_Profile_Info()
  include(${WORKSPACE_DIR}/build/${CURRENT_PROFILE}/Workspace_Platforms_Description.cmake) #loading the workspace description configuration
  #enabling mandatory languages
  enable_language(CXX) # CXX is mandatory
  enable_language(C) # C is mandatory
  enable_language(ASM)#use assembler (by default will be set to C compiler)
  #enabling other languages
  if(Fortran_Language_AVAILABLE)
    enable_language(Fortran)#use fortran
  endif()
  if(CUDA_Language_AVAILABLE)
    find_package(CUDA)
    if(NOT CUDA_FOUND)#simply stop the configuration
      if(CUDA_NVCC_EXECUTABLE AND CUDA_VERSION)
        #situation where runtime things have been found but toolkit "things" have not been found
        #try to find again but automatically setting the toolkit root dir from
        get_filename_component(PATH_TO_BIN ${CUDA_NVCC_EXECUTABLE} REALPATH)#get the path with symlinks resolved
        get_filename_component(PATH_TO_BIN_FOLDER ${PATH_TO_BIN} DIRECTORY)#get the path with symlinks resolved
        if(PATH_TO_BIN_FOLDER MATCHES "^.*/bin(32|64)?$")#if path finishes with bin or bin32 or bin 64
          #remove the binary folder
          get_filename_component(PATH_TO_TOOLKIT ${PATH_TO_BIN_FOLDER} DIRECTORY)#get folder containing the bin folder
        endif()

        if(PATH_TO_TOOLKIT AND EXISTS ${PATH_TO_TOOLKIT})
          set(CUDA_TOOLKIT_ROOT_DIR ${PATH_TO_TOOLKIT} CACHE PATH "" FORCE)
        endif()
        find_package(CUDA)
      endif()
    endif()
    if(NOT CUDA_FOUND)#simply stop the configuration
      message(WARNING "[PID] WARNING : CUDA language is supported by PID environment you are using but NOT configured for current projet ${PROJECT_NAME}. This may cause troubles if some of the PID dependencies you are using themselves use CUDA. Please set your CUDA environment appropriately for instance by setting CUDA_TOOLKIT_ROOT_DIR variable.")
    else()
      if(CUDA_NVCC_EXECUTABLE)
        set(CMAKE_CUDA_COMPILER ${CUDA_NVCC_EXECUTABLE} CACHE FILEPATH "Path to CUDA compiler" FORCE)
      endif()
      if(CUDA_HOST_COMPILER)
        set(CMAKE_CUDA_HOST_COMPILER ${CUDA_HOST_COMPILER} CACHE FILEPATH "Path to CUDA host cc compiler" FORCE)
      endif()
      set(CUDA_USE_STATIC_CUDA_RUNTIME OFF CACHE INTERNAL "")
      enable_language(CUDA)#use cuda compiler
    endif()
  endif()
endmacro(load_Platform_Info)

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
#     :mode: the build mode for target PID package's components
#
function(reset_Local_Components_Info path mode)

  set(WORKSPACE_DIR ${path} CACHE INTERNAL "")
  ########################################################################
  ############ default value for PID cache variables #####################
  ########################################################################
  if(WORKSPACE_MODE) # configuration as already ran
    foreach(dep_package IN LISTS ${PROJECT_NAME}_PID_PACKAGES)
      get_Package_Type(${dep_package} PACK_TYPE)
      if(PACK_TYPE STREQUAL "EXTERNAL")
        reset_External_Package_Dependency_Cached_Variables_From_Use(${dep_package} ${WORKSPACE_MODE} TRUE)
      else()
        reset_Native_Package_Dependency_Cached_Variables_From_Use(${dep_package} ${WORKSPACE_MODE} TRUE)
      endif()
    endforeach()
    set(${PROJECT_NAME}_PID_PACKAGES CACHE INTERNAL "")#reset list of packages
    set(current_mode ${CMAKE_BUILD_TYPE})
    set(CMAKE_BUILD_TYPE ${WORKSPACE_MODE})
    reset_Packages_Finding_Variables()
    reset_Temporary_Optimization_Variables(${mode})
    set(CMAKE_BUILD_TYPE ${current_mode})
  endif()
  #resetting specific variables used to manage components defined locally
  foreach(comp IN LISTS DECLARED_LOCAL_COMPONENTS)
    set(${comp}_LOCAL_DEPENDENCIES CACHE INTERNAL "")
    set(${comp}_PID_DEPENDENCIES CACHE INTERNAL "")
    set(${comp}_RUNTIME_RESOURCES CACHE INTERNAL "")
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
  set(WORKSPACE_MODE ${mode} CACHE INTERNAL "")
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
#     :NOT_ENFORCED: the output variable that is empty if all dependencies can be enforced as OS variants, and contains the name of the first dependency that cannot be enforced
#
function(enforce_System_Dependencies NOT_ENFORCED list_of_os_deps)
foreach(os_variant IN LISTS list_of_os_deps)
	#check if this configuration is matching an external package defined in PID
  #NOTE: evaluation context is the current project
  check_Platform_Configuration(CHECK_CONFIG_OK CONFIG_NAME CONFIG_CONSTRAINTS ${PROJECT_NAME} "${os_variant}" ${WORKSPACE_MODE})
  if(NOT CHECK_CONFIG_OK)
    set(${NOT_ENFORCED} ${os_variant} PARENT_SCOPE)
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
#     :target_type: the type of the target (EXE, LIB, etc.)
#
function(prepare_Local_Target_Configuration local_target target_type)
  #creating specific .rpath folders if build tree to make it possible to use runtime resources in build tree
  if(NOT EXISTS ${CMAKE_BINARY_DIR}/.rpath)
    file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/.rpath)
  endif()

  #a dynamic binary need management of rpath
  get_target_property(local_target_name ${local_target} OUTPUT_NAME)
  if(NOT local_target_name)
    set(local_target_name ${local_target})
  endif()
  if(target_type STREQUAL "EXE" OR target_type STREQUAL "LIB")
    get_property(therpath TARGET ${local_target} PROPERTY INSTALL_RPATH)
    if(NOT (thepath MATCHES "^.*\\.rpath/${local_target}"))#if the rpath has not already been set for this local component
      if(APPLE)
        set_property(TARGET ${local_target} APPEND_STRING PROPERTY INSTALL_RPATH "@loader_path/.rpath/${local_target_name};@loader_path/../.rpath/${local_target_name};@loader_path/../lib;@loader_path") #the library targets a specific folder that contains symbolic links to used shared libraries
      elseif(UNIX)
        set_property(TARGET ${local_target} APPEND_STRING PROPERTY INSTALL_RPATH "\$ORIGIN/.rpath/${local_target_name};\$ORIGIN/../.rpath/${local_target_name};\$ORIGIN/../lib;\$ORIGIN") #the library targets a specific folder that contains symbolic links to used shared libraries
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
#     :target_type: the type of the target (EXE, LIB, etc.)
#     :components_list: the list of PID components to bind local target with
#     :mode: the build mode for target's PID components
#
function(configure_Local_Target_With_PID_Components local_target target_type components_list mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

  #Note: below is an hack to allow using output names that are different from CMake default ones
  get_target_property(local_target_name ${local_target} OUTPUT_NAME)
  if(NOT local_target_name)
    set(local_target_name ${local_target})
  endif()
  if(target_type STREQUAL "EXE" OR target_type STREQUAL "LIB")
    if(APPLE)
      set_property(TARGET ${local_target} APPEND_STRING PROPERTY INSTALL_RPATH "@loader_path/.rpath/${local_target_name};@loader_path/../.rpath/${local_target_name};@loader_path/../lib;@loader_path") #the library targets a specific folder that contains symbolic links to used shared libraries
    elseif(UNIX)
      set_property(TARGET ${local_target} APPEND_STRING PROPERTY INSTALL_RPATH "\$ORIGIN/.rpath/${local_target_name};\$ORIGIN/../.rpath/${local_target_name};\$ORIGIN/../lib;\$ORIGIN") #the library targets a specific folder that contains symbolic links to used shared libraries
    endif()
  endif()

  #for the given component memorize its pid dependencies
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

    get_Package_Type(${RES_PACK} PACK_TYPE)
    set(IS_HF)
    if(PACK_TYPE STREQUAL "EXTERNAL")
      rename_If_Alias(comp_name_to_use ${RES_PACK} TRUE ${COMPONENT_NAME} ${mode})
    else()#native component target
      rename_If_Alias(comp_name_to_use ${RES_PACK} FALSE ${COMPONENT_NAME} Release)
      is_HeaderFree_Component(IS_HF ${RES_PACK} ${comp_name_to_use})
    endif()
    append_Unique_In_Cache(${local_target}_PID_DEPENDENCIES "${RES_PACK}/${comp_name_to_use}")#always resolve aliases before memorizing

    if(PACK_TYPE STREQUAL "EXTERNAL" OR NOT IS_HF)#if not header free the component can be linked
      if(PACK_TYPE STREQUAL "EXTERNAL")#external component target
        create_External_Component_Dependency_Target(${RES_PACK} ${comp_name_to_use} ${mode})
      else()#native component target
        create_Dependency_Target(${RES_PACK} ${comp_name_to_use} ${mode}) #create the fake target for component
      endif()
      target_link_libraries(${local_target} PUBLIC ${RES_PACK}_${comp_name_to_use}${TARGET_SUFFIX})

      target_include_directories(${local_target} PUBLIC
      $<TARGET_PROPERTY:${RES_PACK}_${comp_name_to_use}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)

      target_compile_definitions(${local_target} PUBLIC
      $<TARGET_PROPERTY:${RES_PACK}_${comp_name_to_use}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)

      target_compile_options(${local_target} PUBLIC
      $<TARGET_PROPERTY:${RES_PACK}_${comp_name_to_use}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>)

      # manage C/C++ language standards
      if(${RES_PACK}_${comp_name_to_use}_C_STANDARD${VAR_SUFFIX})#the std C is let optional as using a standard may cause error with posix includes
        get_target_property(CURR_STD_C ${local_target} C_STANDARD)
        is_C_Version_Less(IS_LESS ${CURR_STD_C} ${${RES_PACK}_${comp_name_to_use}_C_STANDARD${VAR_SUFFIX}})
        if(IS_LESS)
          set_target_properties(${local_target} PROPERTIES
              C_STANDARD ${${RES_PACK}_${comp_name_to_use}_C_STANDARD${VAR_SUFFIX}}
              C_STANDARD_REQUIRED YES
              C_EXTENSIONS NO
          )#setting the standard in use locally
        endif()
      endif()
      get_target_property(CURR_STD_CXX ${local_target} CXX_STANDARD)
      is_CXX_Version_Less(IS_LESS ${CURR_STD_CXX} ${${RES_PACK}_${comp_name_to_use}_CXX_STANDARD${VAR_SUFFIX}})
      if(IS_LESS)
        set_target_properties(${local_target} PROPERTIES
          CXX_STANDARD ${${RES_PACK}_${comp_name_to_use}_CXX_STANDARD${VAR_SUFFIX}}
          CXX_STANDARD_REQUIRED YES
          CXX_EXTENSIONS NO
          )#setting the standard in use locally
      endif()
      #Note: there is no resolution of dependenct binary packages runtime dependencies (as for native package build) because resolution has already taken place after deployment of dependent packages.
    endif()

    #now generating symlinks in install tree of the component (for exe and shared libs)
    #equivalent of resolve_Source_Component_Runtime_Dependencies in native packages
    if(target_type STREQUAL "EXE" OR target_type STREQUAL "LIB")
      generate_Local_Component_Symlinks(${local_target_name} ${RES_PACK} ${comp_name_to_use} ${mode})
    endif()
  endforeach()
endfunction(configure_Local_Target_With_PID_Components)

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
#   .. command:: generate_Local_Component_Symlinks(local_target_folder_name local_dependency undirect_deps)
#
#    Generate symlinks for runtime resources in the install tree of a non PID defined component depending on a given PID component.
#
#     :local_target_folder_name: the name of the local component's folder containing its runtime resources
#     :package: the name of package containg dependency component.
#     :component: the name of the dependency component.
#     :mode: chosen build mode for the component.
#
function(generate_Local_Component_Symlinks local_target_folder_name package component mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  #now generating symlinks in install tree of the component (for exe and shared libs)
  #equivalent of resolve_Source_Component_Runtime_Dependencies in native packages
  ### STEP A: create symlinks in install tree
  set(to_symlink) # in case of an executable component add third party (undirect) links
  get_Package_Type(${package} PACK_TYPE)
  if(PACK_TYPE STREQUAL "EXTERNAL")
    #shared links of direct dependency will be needed if native component depends on the external dependency
    get_External_Component_Runtime_Links(DEP_LOCAL_LINKS DEP_USING_LINKS ${package} ${component} ${mode})
    get_External_Component_Runtime_Resources(DEP_RESOURCES ${package} ${component} ${mode} FALSE)
    list(APPEND to_symlink ${DEP_USING_LINKS} ${DEP_RESOURCES})
  else()#native packages
    get_Binary_Location(LOCATION_RES ${package} ${component} ${mode})
    list(APPEND to_symlink ${LOCATION_RES})
    #1) getting all runtime links
    get_Bin_Component_Runtime_Links(DEP_LOCAL_LINKS DEP_USING_LINKS ${package} ${component} ${mode}) #need to resolve external symbols whether the component is exported or not (it may have unresolved symbols coming from shared libraries) + resolve external runtime resources
    list(APPEND to_symlink ${DEP_USING_LINKS})#always use using links since component belong to a PID package and current project is not the same by definition
    #2) getting direct and undirect runtime resources dependencies
    get_Bin_Component_Runtime_Resources(DEP_RESOURCES ${package} ${component} ${mode} FALSE)
    list(APPEND to_symlink ${DEP_RESOURCES})
    #finally create install rule for the symlinks
  endif()
  if(to_symlink)
    list(REMOVE_DUPLICATES to_symlink)
  endif()
  foreach(resource IN LISTS to_symlink)
    install_Runtime_Symlink(${resource} "${CMAKE_INSTALL_PREFIX}/.rpath" ${local_target_folder_name})
  endforeach()

  ### STEP B: create symlinks in build tree (to allow the runtime resources PID mechanism to work at runtime)
  set(to_symlink) # in case of an executable component add third party (undirect) links
  if(PACK_TYPE STREQUAL "EXTERNAL")
    get_External_Component_Runtime_Resources(DEP_RESOURCES ${package} ${component} ${mode} FALSE)
    list(APPEND to_symlink ${DEP_RESOURCES})
  else()#native packages
    #no direct runtime resource for the local target BUT it must import runtime resources defined by dependencies
    #1) getting runtime resources of the component dependency
    get_Bin_Component_Runtime_Resources(DEP_RUNTIME_RESOURCES ${package} ${component} ${mode} FALSE) #resolve external runtime resources
    list(APPEND to_symlink ${DEP_RUNTIME_RESOURCES})
    #2) getting component as runtime ressources if it a pure runtime entity (dynamically loaded library)
    if(${package}_${component}_TYPE STREQUAL "MODULE")
      list(APPEND to_symlink ${${package}_ROOT_DIR}/lib/${${package}_${component}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
    elseif(${package}_${component}_TYPE STREQUAL "APP" OR ${package}_${component}_TYPE STREQUAL "EXAMPLE")
      list(APPEND to_symlink ${${package}_ROOT_DIR}/bin/${${package}_${component}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
    endif()
  endif()

  #finally create install rule for the symlinks
  if(to_symlink)
    list(REMOVE_DUPLICATES to_symlink)
  endif()
  foreach(resource IN LISTS to_symlink)
    create_Runtime_Symlink(${resource} "${CMAKE_BINARY_DIR}/.rpath" ${local_target_folder_name})
  endforeach()
endfunction(generate_Local_Component_Symlinks)

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
#     :target_type: the type of the target (EXE, LIB, etc.)
#     :dependency: the local target that is linked with local_target and depends on PID components
#     :mode: the build mode for pid components
#
function(configure_Local_Target_With_Local_Component local_target target_type dependency mode)

	#updating local dependencies for component
	append_Unique_In_Cache(${local_target}_LOCAL_DEPENDENCIES ${dependency})
	target_link_libraries(${local_target} PUBLIC ${dependency})#linking as usual

  #Note: below is an hack to allow using output names that are different from CMake default ones
  get_target_property(local_target_name ${local_target} OUTPUT_NAME)
  if(NOT local_target_name)
    set(local_target_name ${local_target})
  endif()

	#then resolve symlinks required by PID components to find their runtime resources
	if(target_type STREQUAL "EXE"
      OR target_type STREQUAL "LIB")
		generate_Local_Dependency_Symlinks(${local_target_name} ${dependency} ${mode} "")
	endif()
endfunction(configure_Local_Target_With_Local_Component)



#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Local_Component_Runtime_Resources_Symlinks| replace:: ``generate_Local_Component_Runtime_Resources_Symlinks``
#  .. _generate_Local_Component_Runtime_Resources_Symlinks:
#
#  generate_Local_Component_Runtime_Resources_Symlinks
#  ---------------------------------------------------
#
#   .. command:: generate_Local_Component_Runtime_Resources_Symlinks(local_target_folder_name local_dependency mode)
#
#    Generate symlinks for runtime resources in the install tree of a non PID defined component dependning on a given PID component.
#
#     :local_target_folder_name: the name of the local component's folder containing its runtime resources
#     :package: the name of package containg dependency component.
#     :component: the name of the dependency component.
#     :mode: chosen build mode for the component.
#     :undirect_deps: private shared libraries for local_target_folder_name.
#
function(generate_Local_Component_Runtime_Resources_Symlinks local_target_folder_name local_dependency mode)
  foreach(resource IN LISTS ${local_dependency}_RUNTIME_RESOURCES)
    #install a symlink to the resource that lies in the install tree
    install_Runtime_Symlink(${CMAKE_INSTALL_PREFIX}/share/resources/${resource} "${CMAKE_INSTALL_PREFIX}/.rpath" ${local_target_folder_name})
    #create a symlink to the resource that lies in the source tree
    create_Runtime_Symlink(${CMAKE_CURRENT_SOURCE_DIR}/${resource} "${CMAKE_BINARY_DIR}/.rpath" ${local_target_folder_name})
  endforeach()
endfunction(generate_Local_Component_Runtime_Resources_Symlinks)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Local_Dependency_Symlinks| replace:: ``generate_Local_Dependency_Symlinks``
#  .. _generate_Local_Dependency_Symlinks:
#
#  generate_Local_Dependency_Symlinks
#  ----------------------------------
#
#   .. command:: generate_Local_Dependency_Symlinks(local_target local_dependency undirect_deps)
#
#    Generate symlinks for runtime resources in the install tree of a non PID defined component.
#
#     :local_target: the name of the local component (a non PID defined component)
#     :local_dependency: the name of a local component (a non PID defined component) that is a dependency for local_target.
#     :mode: build for for PID components.
#     :undirect_deps: private shared libraries for local_target.
#
function(generate_Local_Dependency_Symlinks local_target local_dependency mode undirect_deps)
	#recursion on local components first
	foreach(dep IN LISTS ${local_dependency}_LOCAL_DEPENDENCIES)
		generate_Local_Dependency_Symlinks(${local_target} ${dep} ${mode} "")#recursion to get all levels of local dependencies
	endforeach()

	foreach(dep IN LISTS ${local_dependency}_PID_DEPENDENCIES)#in this list all direct aliases are already resolved
		extract_Component_And_Package_From_Dependency_String(COMPONENT_NAME RES_PACK ${dep})
    generate_Local_Component_Symlinks(${local_target} ${RES_PACK} ${COMPONENT_NAME} ${mode})
	endforeach()

  generate_Local_Component_Runtime_Resources_Symlinks(${local_target} ${local_dependency} ${mode})

endfunction(generate_Local_Dependency_Symlinks)


#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Dependent_PID_Native_Package| replace:: ``manage_Dependent_PID_Native_Package``
#  .. _manage_Dependent_PID_Native_Package:
#
#  manage_Dependent_PID_Native_Package
#  -----------------------------------
#
#   .. command:: manage_Dependent_PID_Native_Package(DEPLOYED package possible_versions exact_versions)
#
#    Find (and eventually deploy) a PID native package into the PID workspace from a local (non PID) project.
#
#     :package: the name of the package
#     :possible_versions: the possible_versions of the package (may be left empty)
#     :exact_versions: among version those who are exact (may be left empty)
#
#     :DEPLOYED: the output variable that is TRUE if package has been deployed, FALSE otherwise.
#
function(manage_Dependent_PID_Native_Package DEPLOYED package possible_versions exact_versions)
  set(${DEPLOYED} FALSE PARENT_SCOPE)
  append_Unique_In_Cache(${PROJECT_NAME}_PID_PACKAGES ${package})#memorize in list of packages
  set(previous_mode ${CMAKE_BUILD_TYPE})
  set(CMAKE_BUILD_TYPE ${WORKSPACE_MODE})
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})

  #normalize the version numers to avoid any problem
  set(list_of_possible_versions)
	set(list_of_exact_versions)
  set(default_version) #version to use if no choice already made
	if(possible_versions)
		set(list_of_possible_versions)
		set(list_of_exact_versions)
		foreach(ver IN LISTS possible_versions)
			normalize_Version_String(${ver} NORM_STR)
			list(APPEND list_of_possible_versions ${NORM_STR})
		endforeach()
		foreach(ver IN LISTS exact_versions)
			normalize_Version_String(${ver} NORM_STR)
			list(APPEND list_of_exact_versions ${NORM_STR})
		endforeach()
		list(GET list_of_possible_versions 0 default_version) #by defaut this is the first element in the list that is taken
	endif()

  set(used_version)
  set(used_exact)
  get_Chosen_Version_In_Current_Process(REQUIRED_VERSION VERSION_REQUESTORS IS_EXACT IS_SYSTEM ${package})
  if(REQUIRED_VERSION) #the package is already used as a dependency in the current build process so we need to reuse the version already specified or use a compatible one instead
		if(list_of_possible_versions) #list of possible versions is constrained
			#finding the best compatible version, if any (otherwise returned "version" variable is empty)
			find_Best_Compatible_Version(force_version FALSE ${package} ${REQUIRED_VERSION} "${IS_EXACT}" FALSE "${list_of_possible_versions}" "${list_of_exact_versions}")
			if(NOT force_version)#the build context is a dependent build and no compatible version has been found
        set(CMAKE_BUILD_TYPE ${previous_mode})#NOTE: to avoid any bug due to mode change in calling project
        fill_String_From_List(RES_REQ VERSION_REQUESTORS ", ")
				message("[PID] ERROR : In ${PROJECT_NAME}, dependency ${package} is used with possible versions: ${list_of_possible_versions}. But incompatible version ${REQUIRED_VERSION} is already used in packages: ${RES_REQ}.")
        return()
      else()
        set(used_version ${force_version})
			endif()
		else()#no constraint on version => use the already required one
      set(used_version ${REQUIRED_VERSION})
		endif()
    if(IS_EXACT)
	    set(used_exact EXACT)
    endif()
	else()#classical build, the package is not already manage elsewhere
  	if(list_of_possible_versions)#there is a constraint on usable versions
      set(used_version ${default_version})
      if(list_of_exact_versions)
        list(FIND list_of_exact_versions ${default_version} INDEX)
        if(NOT INDEX EQUAL -1 )#found in exact versions
          set(used_exact EXACT)
        endif()
      endif()
    #else no constraint on version
    endif()
	endif()
  if(NOT ${package}_FOUND${VAR_SUFFIX})
    set(${package}_FIND_VERSION_SYSTEM FALSE)
    #find first time !!
    find_package_resolved(${package} ${used_version} ${used_exact})
    if(NOT ${package}_FOUND${VAR_SUFFIX})
      #NOTE: need to deploy the paclkage into workspace
      set(ENV{manage_progress} FALSE)#NOTE using specific argument to avoid deleting the curently used global progress file
      set(release_only TRUE)
      if(CMAKE_BUILD_TYPE MATCHES Debug)
        set(release_only FALSE)
      endif()
      if(used_version)
        execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} deploy package=${package} version=${used_version} release_only=${release_only}
                        WORKING_DIRECTORY ${WORKSPACE_DIR}/build)
      else()
        execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} deploy package=${package} release_only=${release_only}
                        WORKING_DIRECTORY ${WORKSPACE_DIR}/build)
      endif()
      unset(ENV{manage_progress})
      #find again
      find_package_resolved(${package} ${used_version} ${used_exact} REQUIRED)
    endif()
    add_Chosen_Package_Version_In_Current_Process(${package} ${PROJECT_NAME})# report the choice made to global build process
  endif()

  if(${package}_FOUND${VAR_SUFFIX})
    set(${DEPLOYED} TRUE PARENT_SCOPE)
    resolve_Package_Dependencies(${package} ${WORKSPACE_MODE} TRUE "${release_only}")
    set(${package}_RPATH ${${package}_ROOT_DIR}/.rpath CACHE INTERNAL "")
  endif()
  set(CMAKE_BUILD_TYPE ${previous_mode})#NOTE: to avoid any bug due to mode change in calling project
endfunction(manage_Dependent_PID_Native_Package)


#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Dependent_PID_External_Package| replace:: ``manage_Dependent_PID_External_Package``
#  .. _manage_Dependent_PID_External_Package:
#
#  manage_Dependent_PID_External_Package
#  -------------------------------------
#
#   .. command:: manage_Dependent_PID_External_Package(DEPLOYED package possible_versions exact_versions)
#
#    Find (and eventually deploy) a PID external package into the PID workspace from a local (non PID) project.
#
#     :package: the name of the package
#     :possible_versions: the possible_versions of the package (may be left empty)
#     :exact_versions: among version those who are exact (may be left empty)
#
#     :DEPLOYED: the output variable that is TRUE if package has been deployed, FALSE otherwise.
#
function(manage_Dependent_PID_External_Package DEPLOYED package possible_versions exact_versions)
  set(${DEPLOYED} FALSE PARENT_SCOPE)
  append_Unique_In_Cache(${PROJECT_NAME}_PID_PACKAGES ${package})#memorize in list of packages
  set(previous_mode ${CMAKE_BUILD_TYPE})
  set(CMAKE_BUILD_TYPE ${WORKSPACE_MODE})
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})

  #normalize the version numers to avoid any problem
  set(list_of_possible_versions)
	set(list_of_exact_versions)
  set(default_version) #version to use if no choice already made
	if(possible_versions)
		set(list_of_possible_versions)
		set(list_of_exact_versions)
		foreach(ver IN LISTS possible_versions)
			normalize_Version_String(${ver} NORM_STR)
			list(APPEND list_of_possible_versions ${NORM_STR})
		endforeach()
		foreach(ver IN LISTS exact_versions)
			normalize_Version_String(${ver} NORM_STR)
			list(APPEND list_of_exact_versions ${NORM_STR})
		endforeach()
		list(GET list_of_possible_versions 0 default_version) #by defaut this is the first element in the list that is taken
	endif()

  set(used_version)
  set(used_exact)
  #check if local project already used the package as an explicit system dependency
  list(FIND DECLARED_SYSTEM_DEPENDENCIES ${package} INDEX_IN_DECLARED_OS_DEPS)
  if(INDEX_IN_DECLARED_OS_DEPS EQUAL -1)
    set(used_system FALSE)
  else()
    set(used_system TRUE)
  endif()

  ################
  get_Chosen_Version_In_Current_Process(REQUIRED_VERSION VERSION_REQUESTORS IS_EXACT IS_SYSTEM ${package})
  if(REQUIRED_VERSION) #the package is already used as a dependency in the current build process so we need to reuse the version already specified or use a compatible one instead
    if(used_system AND NOT IS_SYSTEM)
      set(CMAKE_BUILD_TYPE ${previous_mode})#NOTE: to avoid any bug due to mode change in calling project
      message("[PID] ERROR : In ${PROJECT_NAME} dependency ${package} is required to be system version while a NON system version is already required by other dependencies.")
      return()
    endif()
    if(list_of_possible_versions) #list of possible versions is constrained
  		#finding the best compatible version, if any (otherwise returned "version" variable is empty)
  		find_Best_Compatible_Version(force_version TRUE ${package} ${REQUIRED_VERSION} "${IS_EXACT}" "${IS_SYSTEM}" "${list_of_possible_versions}" "${list_of_exact_versions}")
  		if(NOT force_version)#the build context is a dependent build and no compatible version has been found
        set(CMAKE_BUILD_TYPE ${previous_mode})#NOTE: to avoid any bug due to mode change in calling project
        fill_String_From_List(RES_REQ VERSION_REQUESTORS ", ")
				message("[PID] ERROR : In ${PROJECT_NAME}, dependency ${package} is used with possible versions: ${list_of_possible_versions}. But incompatible version ${REQUIRED_VERSION} is already used in packages: ${RES_REQ}.")
				return()
  		else()#a version is forced
        set(used_version ${force_version})
  		endif()
  	else()#no constraint on version => use the required one
      set(used_version ${REQUIRED_VERSION})
      if(IS_EXACT)
        set(used_exact EXACT)
      endif()
  	endif()
    set(used_system ${IS_SYSTEM})
  else()
    if(NOT used_system)
      if(list_of_possible_versions)#there is a constraint on usable versions
        set(used_version ${default_version})
        if(list_of_exact_versions)
          list(FIND list_of_exact_versions ${default_version} INDEX)
          if(NOT INDEX EQUAL -1 )#found in exact versions
            set(used_exact EXACT)
          endif()
        endif()
      #else no constraint on version
      endif()
    endif()
  endif()

  if(NOT ${package}_FOUND${VAR_SUFFIX})
    find_package_resolved(${package} ${used_version} ${used_exact})
    if(NOT ${package}_FOUND${VAR_SUFFIX})
      #NOTE: need to deploy the paclkage into workspace
      set(ENV{manage_progress} FALSE)#NOTE using specific argument to avoid deleting the curently used global progress file
      set(release_only TRUE)
      if(CMAKE_BUILD_TYPE MATCHES Debug)
        set(release_only FALSE)
      endif()
      if(used_system)#deploying external dependency as os variant
        execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} deploy package=${package} version=system release_only=${release_only}
                        WORKING_DIRECTORY ${WORKSPACE_DIR}/build)
      else()
        if(version)
          execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} deploy package=${package} version=${version} release_only=${release_only}
                          WORKING_DIRECTORY ${WORKSPACE_DIR}/build)
        else()
          execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} deploy package=${package} release_only=${release_only}
                          WORKING_DIRECTORY ${WORKSPACE_DIR}/build)
        endif()
      endif()
      unset(ENV{manage_progress})
      #find to see if deployment process went well
      if(used_system)
        set(${package}_FIND_VERSION_SYSTEM TRUE)
      else()
        set(${package}_FIND_VERSION_SYSTEM FALSE)
      endif()
      find_package_resolved(${package} ${used_version} ${used_exact} REQUIRED)
    endif()
    add_Chosen_Package_Version_In_Current_Process(${package} ${PROJECT_NAME})# report the choice made to global build process
  endif()

  if(${package}_FOUND${VAR_SUFFIX})
    set(${DEPLOYED} TRUE PARENT_SCOPE)
    resolve_Package_Dependencies(${package} ${WORKSPACE_MODE} TRUE "${release_only}")
    set(${package}_RPATH ${${package}_ROOT_DIR}/.rpath CACHE INTERNAL "")
  endif()
  set(CMAKE_BUILD_TYPE ${previous_mode})#NOTE: to avoid any bug due to mode change in calling project
endfunction(manage_Dependent_PID_External_Package)


#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Managed_PID_Resources| replace:: ``add_Managed_PID_Resources``
#  .. _add_Managed_PID_Resources:
#
#  add_Managed_PID_Resources
#  --------------------------
#
#   .. command:: add_Managed_PID_Resources(local_target files dirs)
#
#    Define runtime resources used by the local target. These resources will be doscoverable at runtime using pid-rpath API.
#
#     :local_target: the name of the local target defining the resources
#     :files: list of files
#     :dirs: list of firectories.
#
function(add_Managed_PID_Resources local_target files dirs)

    #Note: below is an hack to allow using output names that are different from CMake default ones
    get_target_property(local_target_folder_name ${local_target} OUTPUT_NAME)
    if(NOT local_target_folder_name)
      set(local_target_folder_name ${local_target})
    endif()

  if(files)
    append_Unique_In_Cache(${local_target}_RUNTIME_RESOURCES "${files}")
    install(#install rule for files (to make them available in install tree)
      FILES ${files}
      DESTINATION ${CMAKE_INSTALL_PREFIX}/share/resources
    )
    foreach(a_file IN LISTS files)
      #install a symlink to the resource that lies in the install tree
      install_Runtime_Symlink(${CMAKE_INSTALL_PREFIX}/share/resources/${a_file} "${CMAKE_INSTALL_PREFIX}/.rpath" ${local_target_folder_name})
      #create a symlink to the resource that lies in the source tree
      create_Runtime_Symlink(${CMAKE_CURRENT_SOURCE_DIR}/${a_file} "${CMAKE_BINARY_DIR}/.rpath" ${local_target_folder_name})
    endforeach()
  endif()
  if(dirs)
    append_Unique_In_Cache(${local_target}_RUNTIME_RESOURCES "${dirs}")
    install(#install rule for folders (to make them available in install tree)
      DIRECTORY ${dirs}
      DESTINATION ${CMAKE_INSTALL_PREFIX}/share/resources
    )
    foreach(a_dir IN LISTS dirs)
      #install a symlink to the resource that lies in the install tree
      install_Runtime_Symlink(${CMAKE_INSTALL_PREFIX}/share/resources/${a_dir} "${CMAKE_INSTALL_PREFIX}/.rpath" ${local_target_folder_name})
      #create a symlink to the resource that lies in the source tree
      create_Runtime_Symlink(${CMAKE_CURRENT_SOURCE_DIR}/${a_dir} "${CMAKE_BINARY_DIR}/.rpath" ${local_target_folder_name})
    endforeach()
  endif()
endfunction(add_Managed_PID_Resources)
