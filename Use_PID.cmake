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
# .. ifmode:: internal
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
#     :path: the path to the target workspace root folder.
#
macro(import_PID_Workspace path)
if(${path} STREQUAL "")
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a path must be given to import_PID_Workspace.")
endif()
CMAKE_MINIMUM_REQUIRED(VERSION 3.1)#just to ensure that version of CMake tool used in external projects if high enough (supports language standards)

if(NOT EXISTS ${path})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : the path to the PID workspace ${path} does not exist.")
endif()
set(WORKSPACE_DIR ${path} CACHE INTERNAL "")

########################################################################
############ all PID system path are put into the cmake path ###########
########################################################################
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/find)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/platforms)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/configurations)
########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(PID_Set_Policies NO_POLICY_SCOPE)
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
include(External_Definition NO_POLICY_SCOPE)

include(${WORKSPACE_DIR}/pid/Workspace_Platforms_Description.cmake) #loading the workspace description configuration

########################################################################
############ default value for PID cache variables #####################
########################################################################
set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD FALSE CACHE INTERNAL "") #do not manage automatic install since outside from a PID workspace
set(GLOBAL_PROGRESS_VAR TRUE)
if(NOT CMAKE_BUILD_TYPE)
	message("[PID] WARNING : when calling import_PID_Workspace, no known build type defined (Release or Debug) : the Release build is selected by default.")
	set(CMAKE_BUILD_TYPE Release)
endif()
#need to reset the variables used to describe dependencies
foreach(dep_package IN LISTS ${PROJECT_NAME}_PID_PACKAGES)
	get_Package_Type(${dep_package} PACK_TYPE)
	if(PACK_TYPE STREQUAL "EXTERNAL")
		reset_External_Package_Dependency_Cached_Variables_From_Use(${dep_package} ${CMAKE_BUILD_TYPE})
	else()
		reset_Native_Package_Dependency_Cached_Variables_From_Use(${dep_package} ${CMAKE_BUILD_TYPE})
	endif()
endforeach()
set(${PROJECT_NAME}_PID_PACKAGES CACHE INTERNAL "")#reset list of packages
reset_Packages_Finding_Variables()
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
#   .. admonition:: Effects
#     :class: important
#
#     After the call, the content of the package can be in the local project.
#
#   .. rubric:: Example
#
#   .. code-block:: cmake
#
#      import_PID_Package(PACKAGE pid-rpath VERSION 2.1.1)
#
function(import_PID_Package)
set(oneValueArgs PACKAGE VERSION)
set(multiValueArgs)
cmake_parse_arguments(IMPORT_PID_PACKAGE "" "${oneValueArgs}" "" ${ARGN})
if(NOT IMPORT_PID_PACKAGE_PACKAGE)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments, a package name must be given to using NAME keyword.")
endif()
append_Unique_In_Cache(${PROJECT_NAME}_PID_PACKAGES ${IMPORT_PID_PACKAGE_PACKAGE})#reset list of packages
if(NOT IMPORT_PID_PACKAGE_VERSION)
	message("[PID] WARNING : no version given to import_PID_Package, last available version of ${IMPORT_PID_PACKAGE_PACKAGE} will be used.")
	find_package(${IMPORT_PID_PACKAGE_PACKAGE} REQUIRED)
else()
	find_package(${IMPORT_PID_PACKAGE_PACKAGE} ${IMPORT_PID_PACKAGE_VERSION} EXACT REQUIRED)
endif()
if(NOT ${IMPORT_PID_PACKAGE_PACKAGE}_FOUND)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : when calling import_PID_Package, the package ${IMPORT_PID_PACKAGE_PACKAGE} cannot be found (any version or required version not found).")
endif()
resolve_Package_Dependencies(${IMPORT_PID_PACKAGE_PACKAGE} ${CMAKE_BUILD_TYPE} TRUE)#TODO from here ERROR due to bad dependency (maybe a BUG in version resolution)
set(${IMPORT_PID_PACKAGE_PACKAGE}_RPATH ${${IMPORT_PID_PACKAGE_PACKAGE}_ROOT_DIR}/.rpath CACHE INTERNAL "")
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
#  .. command:: bind_PID_Components(PACKAGE ... [VERSION ...])
#
#   Make the given local target depends on a set of PID components, typically libraries.
#
#   .. rubric:: Required parameters
#
#   :EXE|LIB <string>: the name of the local target and its type (EXE= exécutable binary, LIB=library).
#   :COMPONENTS <list of components>: the list of components to use. Each component has the pattern <package_name>/<component_name>
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
set(oneValueArgs EXE LIB AR)
set(multiValueArgs COMPONENTS)
cmake_parse_arguments(BIND_PID_COMPONENTS "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
if(NOT BIND_PID_COMPONENTS_EXE AND NOT BIND_PID_COMPONENTS_LIB AND NOT BIND_PID_COMPONENTS_AR)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling bind_PID_Components, name of the target must be given using EXE or LIB or AR keywords.")
elseif((BIND_PID_COMPONENTS_EXE AND BIND_PID_COMPONENTS_LIB) OR (BIND_PID_COMPONENTS_EXE AND BIND_PID_COMPONENTS_AR) OR (BIND_PID_COMPONENTS_AR AND BIND_PID_COMPONENTS_LIB))
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling bind_PID_Components, EXE and LIB keywords cannot be used together.")
elseif(BIND_PID_COMPONENTS_EXE)
	set(name ${BIND_PID_COMPONENTS_EXE})
elseif(BIND_PID_COMPONENTS_LIB)
	set(name ${BIND_PID_COMPONENTS_LIB})
elseif(BIND_PID_COMPONENTS_AR)
	set(name ${BIND_PID_COMPONENTS_AR})
endif()

#prepare component to be able to manage PID runtime path
if(BIND_PID_COMPONENTS_EXE OR BIND_PID_COMPONENTS_LIB)
	if(APPLE)
		set_target_properties(${name} PROPERTIES INSTALL_RPATH "@loader_path/../lib;@loader_path;;@loader_path/.rpath/${name};@loader_path/../.rpath/${name}") #the library targets a specific folder that contains symbolic links to used shared libraries
	elseif(UNIX)
		set_target_properties(${name} PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib;\$ORIGIN;\$ORIGIN/.rpath/${name};\$ORIGIN/../.rpath/${name}") #the library targets a specific folder that contains symbolic links to used shared libraries
	endif()
endif()

if(NOT BIND_PID_COMPONENTS_COMPONENTS)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling bind_PID_Components, at least one component name must be given using COMPONENTS keyword.")
	return()
endif()
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
foreach(dep IN LISTS BIND_PID_COMPONENTS_COMPONENTS)
	message("dependency for ${name}= ${dep}")
  extract_Component_And_Package_From_Dependency_String(COMPONENT_NAME RES_PACK ${dep})
  if(NOT RES_PACK)
		message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling bind_PID_Components, component name must be preceded by its package name and a / (e.g. <package>/<component>).")
	else()
		list(FIND ${PROJECT_NAME}_PID_PACKAGES ${RES_PACK} INDEX)
		if(INDEX EQUAL -1)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : bad arguments when calling bind_PID_Components, package ${RES_PACK} has not been declare using import_PID_Package.")
		endif()
	endif()
	#create the imported target for that component
	get_Package_Type(${RES_PACK} PACK_TYPE)
	if(PACK_TYPE STREQUAL "EXTERNAL")
		#for direct external packages dependencies we need to do differently
		collect_Links_And_Flags_For_External_Component(${RES_PACK} ${COMPONENT_NAME}
					RES_INCS RES_LIB_DIRS RES_DEFS RES_OPTS RES_LINKS_ST RES_LINKS_SH RES_STD_C RES_STD_CXX RES_RUNTIME)
		set(ALL_LINKS ${RES_LINKS_ST} ${RES_LINKS_SH})
		if(ALL_LINKS)
		  evaluate_Variables_In_List(EVAL_LNKS ALL_LINKS) #first evaluate element of the list => if they are variables they are evaluated
			resolve_External_Libs_Path(COMPLETE_LINKS_PATH "${EVAL_LNKS}" ${CMAKE_BUILD_TYPE})
			if(COMPLETE_LINKS_PATH)
				foreach(link IN LISTS COMPLETE_LINKS_PATH)
					create_External_Dependency_Target(EXT_TARGET_NAME ${link} ${CMAKE_BUILD_TYPE})
					if(EXT_TARGET_NAME)
						list(APPEND EXT_LINKS_TARGETS ${EXT_TARGET_NAME})
					else()
						list(APPEND EXT_LINKS_OPTIONS ${link})
					endif()
				endforeach()
			endif()
			list(APPEND EXT_LINKS ${EXT_LINKS_TARGETS} ${EXT_LINKS_OPTIONS})
		endif()
		if(RES_INCS)
		  evaluate_Variables_In_List(EVAL_INCS RES_INCS)#first evaluate element of the list => if they are variables they are evaluated
			resolve_External_Includes_Path(COMPLETE_INCLUDES_PATH "${EVAL_INCS}" ${CMAKE_BUILD_TYPE})
		endif()
		if(RES_OPTS)
			evaluate_Variables_In_List(EVAL_OPTS RES_OPTS)#first evaluate element of the list => if they are variables they are evaluated
		endif()
		if(RES_LIB_DIRS)
		  evaluate_Variables_In_List(EVAL_LDIRS RES_LIB_DIRS)
			resolve_External_Libs_Path(COMPLETE_LIB_DIRS_PATH "${EVAL_LDIRS}" ${CMAKE_BUILD_TYPE})
		endif()
		if(RES_DEFS)
		  evaluate_Variables_In_List(EVAL_DEFS RES_DEFS)#first evaluate element of the list => if they are variables they are evaluated
		endif()
		if(RES_STD_C)
		  evaluate_Variables_In_List(EVAL_CSTD RES_STD_C)
		endif()
		if(RES_STD_CXX)
		  evaluate_Variables_In_List(EVAL_CXXSTD RES_STD_CXX)
		endif()

		# managing compile time flags
		foreach(dir IN LISTS COMPLETE_INCLUDES_PATH)
			target_include_directories(${name} PUBLIC "${dir}")
		endforeach()

		foreach(def IN LISTS RES_DEFS)
			target_compile_definitions(${name} PUBLIC "${def}")
		endforeach()

		foreach(opt IN LISTS RES_OPTS)
			target_compile_options(${name} PUBLIC "${opt}")
		endforeach()

		# managing link time flags
		foreach(link IN LISTS EXT_LINKS)
			target_link_libraries(${name} PUBLIC ${link})
		endforeach()

		foreach(dir IN LISTS COMPLETE_LIB_DIRS_PATH)
		  target_link_libraries(${name} PUBLIC "-L${dir}")#generate -L linker flags for library dirs
		endforeach()

		# manage C/C++ language standards
		if(RES_STD_C)#the std C is let optional as using a standard may cause error with posix includes
			get_target_property(CURR_STD_C ${name} C_STANDARD)
			is_C_Version_Less(IS_LESS ${CURR_STD_C} ${RES_STD_C})
			if(IS_LESS)
				set_target_properties(${name} PROPERTIES
						C_STANDARD ${RES_STD_C}
						C_STANDARD_REQUIRED YES
						C_EXTENSIONS NO
				)#setting the standard in use locally
			endif()
		endif()
		get_target_property(CURR_STD_CXX ${name} CXX_STANDARD)
		is_CXX_Version_Less(IS_LESS ${CURR_STD_CXX} ${RES_STD_CXX})
		if(IS_LESS)
			set_target_properties(${name} PROPERTIES
				CXX_STANDARD ${RES_STD_CXX}
				CXX_STANDARD_REQUIRED YES
				CXX_EXTENSIONS NO
				)#setting the standard in use locally
		endif()

	else()
		create_Dependency_Target(${RES_PACK} ${COMPONENT_NAME} ${CMAKE_BUILD_TYPE}) #create the fake target for component
		is_HeaderFree_Component(DEP_IS_HF ${RES_PACK} ${COMPONENT_NAME})
		if(NOT DEP_IS_HF) #link that target (only possible with non runtime libraries)#TODO not sure this is consistent since a header lib may have undirect binaries !!
			target_link_libraries(${name} PUBLIC ${RES_PACK}-${COMPONENT_NAME}${TARGET_SUFFIX})
		endif()

		target_include_directories(${name} PUBLIC
		$<TARGET_PROPERTY:${RES_PACK}-${COMPONENT_NAME}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)

		target_compile_definitions(${name} PUBLIC
		$<TARGET_PROPERTY:${RES_PACK}-${COMPONENT_NAME}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)

		target_compile_options(${name} PUBLIC
		$<TARGET_PROPERTY:${RES_PACK}-${COMPONENT_NAME}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>)

		# manage C/C++ language standards
		if(${RES_PACK}_${COMPONENT_NAME}_C_STANDARD${VAR_SUFFIX})#the std C is let optional as using a standard may cause error with posix includes
			get_target_property(CURR_STD_C ${name} C_STANDARD)
			is_C_Version_Less(IS_LESS ${CURR_STD_C} ${${RES_PACK}_${COMPONENT_NAME}_C_STANDARD${VAR_SUFFIX}})
			if(IS_LESS)
				set_target_properties(${name} PROPERTIES
						C_STANDARD ${${RES_PACK}_${COMPONENT_NAME}_C_STANDARD${VAR_SUFFIX}}
						C_STANDARD_REQUIRED YES
						C_EXTENSIONS NO
				)#setting the standard in use locally
			endif()
		endif()
		get_target_property(CURR_STD_CXX ${name} CXX_STANDARD)
		is_CXX_Version_Less(IS_LESS ${CURR_STD_CXX} ${${RES_PACK}_${COMPONENT_NAME}_CXX_STANDARD${VAR_SUFFIX}})
		if(IS_LESS)
			set_target_properties(${name} PROPERTIES
				CXX_STANDARD ${${RES_PACK}_${COMPONENT_NAME}_CXX_STANDARD${VAR_SUFFIX}}
				CXX_STANDARD_REQUIRED YES
				CXX_EXTENSIONS NO
				)#setting the standard in use locally
		endif()
	endif()

	#Note: there is no resolution of dependenct binary packages runtime dependencies (as for native package build) because resolution has already taken place after deployment of dependent packages.

	#For executable we need to resolve everything before linking so that there is no more unresolved symbols
	#equivalent with resolve_Source_Component_Linktime_Dependencies in native packages
	if(BIND_PID_COMPONENTS_EXE)
		#need to resolve all symbols before linking executable so need to find undirect symbols => same as for native packages
		# 1) searching each direct dependency in other packages
		set(undirect_deps)
		find_Dependent_Private_Shared_Libraries(LIST_OF_DEP_SHARED ${RES_PACK} ${COMPONENT_NAME} TRUE ${CMAKE_BUILD_TYPE})
		if(LIST_OF_DEP_SHARED)
			set(undirect_deps ${LIST_OF_DEP_SHARED})
		endif()

		if(undirect_deps) #if true we need to be sure that the rpath-link does not contain some dirs of the rpath (otherwise the executable may not run)
			list(REMOVE_DUPLICATES undirect_deps)
			get_target_property(thelibs ${name} LINK_LIBRARIES)
			set_target_properties(${name} PROPERTIES LINK_LIBRARIES "${thelibs};${undirect_deps}")
		endif()
	endif()
	#now generating symlinks in install tree of the component (for exe and shared libs)
	#equivalent of resolve_Source_Component_Runtime_Dependencies in native packages
	if(BIND_PID_COMPONENTS_EXE OR BIND_PID_COMPONENTS_LIB)
		### STEP A: create symlinks in install tree
		set(to_symlink ${undirect_deps}) # in case of an executable component add third party (undirect) links

		get_Binary_Location(LOCATION_RES ${RES_PACK} ${COMPONENT_NAME} ${CMAKE_BUILD_TYPE})
		list(APPEND to_symlink ${LOCATION_RES})

		#1) getting public shared links
		get_Bin_Component_Runtime_Dependencies(INT_DEP_RUNTIME_RESOURCES ${RES_PACK} ${COMPONENT_NAME} ${CMAKE_BUILD_TYPE}) #need to resolve external symbols whether the component is exported or not (it may have unresolved symbols coming from shared libraries) + resolve external runtime resources
		if(INT_DEP_RUNTIME_RESOURCES)
			list(APPEND to_symlink ${INT_DEP_RUNTIME_RESOURCES})
		endif()
		#2) getting private shared links (undirect by definition)
		get_Bin_Component_Direct_Runtime_PrivateLinks_Dependencies(RES_PRIVATE_LINKS ${RES_PACK} ${COMPONENT_NAME} ${CMAKE_BUILD_TYPE})
		if(RES_PRIVATE_LINKS)
			list(APPEND to_symlink ${RES_PRIVATE_LINKS})
		endif()
		#3) getting direct and undirect runtime resources dependencies
		get_Bin_Component_Runtime_Resources_Dependencies(RES_RESOURCES ${RES_PACK} ${COMPONENT_NAME} ${CMAKE_BUILD_TYPE})
		if(RES_RESOURCES)
			list(APPEND to_symlink ${RES_RESOURCES})
		endif()
		#finally create install rule for the symlinks
		if(to_symlink)
			list(REMOVE_DUPLICATES to_symlink)
		endif()
		foreach(resource IN LISTS to_symlink)
			install_Runtime_Symlink(${resource} "${CMAKE_INSTALL_PREFIX}/.rpath" ${name})
		endforeach()

		message("${name} symlinked in install tree: ${to_symlink}")
		### STEP B: create symlinks in build tree (to allow the runtime resources PID mechanism to work at runtime)
		set(to_symlink) # in case of an executable component add third party (undirect) links
		#no direct runtime resource for the local target BUT it must import runtime resources defined by dependencies
		#1) getting runtime resources of the component dependency
		get_Bin_Component_Runtime_Resources_Dependencies(INT_DEP_RUNTIME_RESOURCES ${RES_PACK} ${COMPONENT_NAME} ${CMAKE_BUILD_TYPE}) #resolve external runtime resources
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
			create_Runtime_Symlink(${resource} "${CMAKE_BINARY_DIR}/.rpath" ${name})
		endforeach()
	endif()
endforeach()


#creating specific .rpath folders if build tree to make it possible to use runtime resources in build tree
if(NOT EXISTS ${CMAKE_BINARY_DIR}/.rpath)
	file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/.rpath)
endif()

endfunction(bind_PID_Components)
