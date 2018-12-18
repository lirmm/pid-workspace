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
if(PID_PACKAGE_CONFIGURATION_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_PACKAGE_CONFIGURATION_FUNCTIONS_INCLUDED TRUE)
##########################################################################################


#################################################################################################
####################### new API => configure the package with dependencies  #####################
#################################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_Closed_Source_Dependency_Packages| replace:: ``list_Closed_Source_Dependency_Packages``
#  .. _list_Closed_Source_Dependency_Packages:
#
#  list_Closed_Source_Dependency_Packages
#  --------------------------------------
#
#   .. command:: list_Closed_Source_Dependency_Packages()
#
#   List all dependencies (packages) of the currenlty defined package that have a close source license. The list is put in CLOSED_SOURCE_DEPENDENCIES cache variable.
#
function (list_Closed_Source_Dependency_Packages)
set(CLOSED_PACKS)
foreach(pack IN LISTS ${PROJECT_NAME}_ALL_USED_PACKAGES)
	package_License_Is_Closed_Source(CLOSED ${pack} FALSE)
	if(CLOSED)
		list(APPEND CLOSED_PACKS ${pack})
	endif()
endforeach()
if(CLOSED_PACKS)
	list(REMOVE_DUPLICATES CLOSED_PACKS)
endif()
set(CLOSED_SOURCE_DEPENDENCIES ${CLOSED_PACKS} CACHE INTERNAL "")
endfunction(list_Closed_Source_Dependency_Packages)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Closed_Source_Dependency_Package| replace:: ``is_Closed_Source_Dependency_Package``
#  .. _is_Closed_Source_Dependency_Package:
#
#  is_Closed_Source_Dependency_Package
#  -----------------------------------
#
#   .. command:: is_Closed_Source_Dependency_Package(CLOSED package)
#
#   Checking whether a package is a closed source dependency of currenlty defined package.
#
#     :package: the name of the package that IS the dependency.
#
#     :CLOSED: the output variable that is TRUE if package is a close source dependency.
#
function(is_Closed_Source_Dependency_Package CLOSED package)
list(FIND CLOSED_SOURCE_DEPENDENCIES ${package} INDEX)
if(INDEX EQUAL -1)
	set(${CLOSED} FALSE PARENT_SCOPE)
else()#package found in closed source packs => it is closed source
	set(${CLOSED} TRUE PARENT_SCOPE)
endif()
endfunction(is_Closed_Source_Dependency_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_Public_Includes| replace:: ``list_Public_Includes``
#  .. _list_Public_Includes:
#
#  list_Public_Includes
#  --------------------
#
#   .. command:: list_Public_Includes(INCLUDES package component mode)
#
#   List all public include path of a component.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :INCLUDES: the output variable that contains the list of public include path.
#
function(list_Public_Includes INCLUDES package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

set(RES "${${package}_ROOT_DIR}/include/${${package}_${component}_HEADER_DIR_NAME}")
#additionally provided include dirs (cflags -I<path>) (external/system exported include dirs)
if(${package}_${component}_INC_DIRS${mode_suffix})
	resolve_External_Includes_Path(RES_INCLUDES "${${package}_${component}_INC_DIRS${VAR_SUFFIX}}" ${mode})
	list(APPEND RES ${RES_INCLUDES})
endif()
set(${INCLUDES} ${RES} PARENT_SCOPE)
endfunction(list_Public_Includes)

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_Public_Links| replace:: ``list_Public_Links``
#  .. _list_Public_Links:
#
#  list_Public_Links
#  -----------------
#
#   .. command:: list_Public_Links(LINKS package component mode)
#
#   List all public links of a component.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :LINKS: the output variable that contains the list of public links.
#
function(list_Public_Links LINKS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
#provided additionnal ld flags (exported external/system libraries and ldflags)
if(${package}_${component}_LINKS${VAR_SUFFIX})
	resolve_External_Libs_Path(RES_LINKS "${${package}_${component}_LINKS${VAR_SUFFIX}}" ${mode})
set(${LINKS} "${RES_LINKS}" PARENT_SCOPE)
endif()
endfunction(list_Public_Links)

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_Public_Definitions| replace:: ``list_Public_Definitions``
#  .. _list_Public_Definitions:
#
#  list_Public_Definitions
#  -----------------------
#
#   .. command:: list_Public_Definitions(DEFS package component mode)
#
#   List all public preprocessor definitions of a component.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :DEFS: the output variable that contains the list of public definitions.
#
function(list_Public_Definitions DEFS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(${package}_${component}_DEFS${VAR_SUFFIX})
	set(${DEFS} ${${package}_${component}_DEFS${VAR_SUFFIX}} PARENT_SCOPE)
endif()
endfunction(list_Public_Definitions)

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_Public_Options| replace:: ``list_Public_Options``
#  .. _list_Public_Options:
#
#  list_Public_Options
#  -------------------
#
#   .. command:: list_Public_Options(OPTS package component mode)
#
#   List all public compiler options of a component.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :OPTS: the output variable that contains the list of public compiler options.
#
function(list_Public_Options OPTS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
#checking that no compiler option is used directly to set the standard
#remove the option and set the standard adequately instead
set(FILTERED_OPTS)
foreach(opt IN LISTS ${package}_${component}_OPTS${VAR_SUFFIX})
	#checking for CXX_STANDARD
	is_CXX_Standard_Option(STANDARD_NUMBER ${opt})
	if(STANDARD_NUMBER)
		message("[PID] WARNING: in component ${component} of package ${package}, directly using option -std=c++${STANDARD_NUMBER} or -std=gnu++${STANDARD_NUMBER} is not recommanded, use the CXX_STANDARD keywork in component description instead. PID performs corrective action.")
		is_CXX_Version_Less(IS_LESS ${${package}_${component}_CXX_STANDARD${VAR_SUFFIX}} ${STANDARD_NUMBER})
		if(IS_LESS)
			set(${package}_${component}_CXX_STANDARD${VAR_SUFFIX} ${STANDARD_NUMBER} CACHE INTERNAL "")
		endif()
	else()#checking for C_STANDARD
		is_C_Standard_Option(STANDARD_NUMBER ${opt})
		if(STANDARD_NUMBER)
			message("[PID] WARNING: in component ${component} of package ${package}, directly using option -std=c${STANDARD_NUMBER} or -std=gnu${STANDARD_NUMBER} is not recommanded, use the C_STANDARD keywork in component description instead. PID performs corrective action.")
			is_C_Version_Less(IS_LESS ${${package}_${component}_C_STANDARD${VAR_SUFFIX}} ${STANDARD_NUMBER})
			if(IS_LESS)
				set(${package}_${component}_C_STANDARD${VAR_SUFFIX} ${STANDARD_NUMBER} CACHE INTERNAL "")
			endif()
		else()
			list(APPEND FILTERED_OPTS ${opt})#keep the option unchanged
		endif()
	endif()
endforeach()
set(${OPTS} ${FILTERED_OPTS} PARENT_SCOPE)
endfunction(list_Public_Options)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Binary_Location| replace:: ``get_Binary_Location``
#  .. _get_Binary_Location:
#
#  get_Binary_Location
#  -------------------
#
#   .. command:: get_Binary_Location(LOCATION_RES package component mode)
#
#   Get the path of a given component's resulting binary in the filesystem.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :LOCATION_RES: the output variable that contains the path to the component's binary.
#
function(get_Binary_Location LOCATION_RES package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
is_Executable_Component(IS_EXE ${package} ${component})
if(IS_EXE)
	set(${LOCATION_RES} "${${package}_ROOT_DIR}/bin/${${package}_${component}_BINARY_NAME${VAR_SUFFIX}}" PARENT_SCOPE)
elseif(NOT ${package}_${component}_TYPE STREQUAL "HEADER")
	set(${LOCATION_RES} "${${package}_ROOT_DIR}/lib/${${package}_${component}_BINARY_NAME${VAR_SUFFIX}}" PARENT_SCOPE)
endif()
endfunction(get_Binary_Location)

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_Private_Links| replace:: ``list_Private_Links``
#  .. _list_Private_Links:
#
#  list_Private_Links
#  ------------------
#
#   .. command:: list_Private_Links(PRIVATE_LINKS package component mode)
#
#   List all private links of a component. Symbolf of private links are not exported, but need to be known at executable link time in order to resolve global symbol resolution.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :PRIVATE_LINKS: the output variable that contains the list of private links.
#
function(list_Private_Links PRIVATE_LINKS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
#provided additionnal ld flags (exported external/system libraries and ldflags)
if(${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX})
	resolve_External_Libs_Path(RES_LINKS "${${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX}}" ${mode})
set(${PRIVATE_LINKS} "${RES_LINKS}" PARENT_SCOPE)
endif()
endfunction(list_Private_Links)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Language_Standards| replace:: ``get_Language_Standards``
#  .. _get_Language_Standards:
#
#  get_Language_Standards
#  ----------------------
#
#   .. command:: get_Language_Standards(STD_C STD_CXX package component mode)
#
#   Get C and C++ language standard used for a component.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :STD_C: the output variable that contains the C language standard used.
#
#     :STD_CXX: the output variable that contains the C++ language standard used.
#
function(get_Language_Standards STD_C STD_CXX package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(${STD_C} ${${package}_${component}_C_STANDARD${VAR_SUFFIX}} PARENT_SCOPE)
set(${STD_CXX} ${${package}_${component}_CXX_STANDARD${VAR_SUFFIX}} PARENT_SCOPE)
endfunction(get_Language_Standards)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Language_Standards| replace:: ``manage_Language_Standards``
#  .. _manage_Language_Standards:
#
#  manage_Language_Standards
#  -------------------------
#
#   .. command:: manage_Language_Standards(package component mode)
#
#   Set C and C++ language standard default values if not set for a component.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
function(manage_Language_Standards package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(NOT ${package}_${component}_C_STANDARD${VAR_SUFFIX})
	set(${package}_${component}_C_STANDARD${VAR_SUFFIX} 90 CACHE INTERNAL "")
endif()
if(NOT ${package}_${component}_CXX_STANDARD${VAR_SUFFIX})
	set(${package}_${component}_CXX_STANDARD${VAR_SUFFIX} 98 CACHE INTERNAL "")
endif()
endfunction(manage_Language_Standards)
##################################################################################
###################### runtime dependencies management API #######################
##################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Bin_Component_Direct_Runtime_Resources_Dependencies| replace:: ``get_Bin_Component_Direct_Runtime_Resources_Dependencies``
#  .. _get_Bin_Component_Direct_Runtime_Resources_Dependencies:
#
#  get_Bin_Component_Direct_Runtime_Resources_Dependencies
#  -------------------------------------------------------
#
#   .. command:: get_Bin_Component_Direct_Runtime_Resources_Dependencies(RES_RESOURCES package component mode)
#
#   Get list of path to all resources (executables, modules, files and folders) directly used by a component (from another package than currenlty defined one) at runtime.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :RES_RESOURCES: the output variable that contains the list of path to runtime resources.
#
function(get_Bin_Component_Direct_Runtime_Resources_Dependencies RES_RESOURCES package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)
if(${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX})#if there are exported resources
	resolve_External_Resources_Path(COMPLETE_RESOURCES_PATH "${${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX}}" ${mode})
	foreach(path IN LISTS COMPLETE_RESOURCES_PATH)
		if(NOT IS_ABSOLUTE ${path}) #relative path => this a native package resource
			list(APPEND result ${${package}_ROOT_DIR}/share/resources/${path})#the path contained by the link
		else() #absolute resource path coming from external or system dependencies
			list(APPEND result ${path})#the direct path to the dependency (absolute)
		endif()
	endforeach()
endif()
set(${RES_RESOURCES} ${result} PARENT_SCOPE)
endfunction(get_Bin_Component_Direct_Runtime_Resources_Dependencies)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Bin_Component_Runtime_Resources_Dependencies| replace:: ``get_Bin_Component_Runtime_Resources_Dependencies``
#  .. _get_Bin_Component_Runtime_Resources_Dependencies:
#
#  get_Bin_Component_Runtime_Resources_Dependencies
#  ------------------------------------------------
#
#   .. command:: get_Bin_Component_Runtime_Resources_Dependencies(RES_RESOURCES package component mode)
#
#   Get list of path to all resources (executables, modules, files and folders) directly or undirectly used by a component at runtime.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :RES_RESOURCES: the output variable that contains the list of path to runtime resources.
#
function(get_Bin_Component_Runtime_Resources_Dependencies RES_RESOURCES package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)
get_Bin_Component_Direct_Runtime_Resources_Dependencies(DIRECT_RESOURCES ${package} ${component} ${mode})
list(APPEND result ${DIRECT_RESOURCES})

foreach(dep_pack IN LISTS ${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep_comp IN LISTS ${package}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})
		#applications do not need to propagate their runtime resources (since everything will be resolved according to their own rpath and binary location
		#nevertheless they can allow the access to some of their file or directory in order to let other code modify or extent their runtime behavior (for instance by modifying configuration files)
		get_Bin_Component_Runtime_Resources_Dependencies(INT_DEP_RUNTIME_RESOURCES ${dep_pack} ${dep_comp} ${mode}) #resolve external runtime resources
		if(INT_DEP_RUNTIME_RESOURCES)
			list(APPEND result ${INT_DEP_RUNTIME_RESOURCES})
		endif()
		if(${dep_pack}_${dep_comp}_TYPE STREQUAL "MODULE")
			list(APPEND result ${${dep_pack}_ROOT_DIR}/lib/${${dep_pack}_${dep_comp}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
		elseif(${dep_pack}_${dep_comp}_TYPE STREQUAL "APP" OR  ${dep_pack}_${dep_comp}_TYPE STREQUAL "EXAMPLE")
			list(APPEND result ${${dep_pack}_ROOT_DIR}/bin/${${dep_pack}_${dep_comp}_BINARY_NAME${VAR_SUFFIX}})#the application is a direct runtime dependency of the component
		endif()

	endforeach()
endforeach()

# 3) adding internal components dependencies
foreach(int_dep IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
	#applications do not need to propagate their runtime resources (since everything will be resolved according to their own rpath and binary location
	#nevertheless they can allow the access to some of their file or directory in order to let other code modify or extent their runtime behavior (for instance by modifying configuration files)
	get_Bin_Component_Runtime_Resources_Dependencies(INT_DEP_RUNTIME_RESOURCES ${package} ${int_dep} ${mode})
	if(INT_DEP_RUNTIME_RESOURCES)
		list(APPEND result ${INT_DEP_RUNTIME_RESOURCES})
	endif()
	if(${package}_${int_dep}_TYPE STREQUAL "MODULE")
		list(APPEND result ${${package}_ROOT_DIR}/lib/${${package}_${int_dep}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
	elseif(${package}_${int_dep}_TYPE STREQUAL "APP" OR ${package}_${int_dep}_TYPE STREQUAL "EXAMPLE")
		list(APPEND result ${${package}_ROOT_DIR}/bin/${${package}_${int_dep}_BINARY_NAME${VAR_SUFFIX}})#the application is a direct runtime dependency of the component
	endif()
endforeach()

set(${RES_RESOURCES} ${result} PARENT_SCOPE)
endfunction(get_Bin_Component_Runtime_Resources_Dependencies)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Bin_Component_Direct_Internal_Runtime_Dependencies| replace:: ``get_Bin_Component_Direct_Internal_Runtime_Dependencies``
#  .. _get_Bin_Component_Direct_Internal_Runtime_Dependencies:
#
#  get_Bin_Component_Direct_Internal_Runtime_Dependencies
#  ------------------------------------------------------
#
#   .. command:: get_Bin_Component_Direct_Internal_Runtime_Dependencies(RES_RESOURCES package component mode prefix_path suffix_ext)
#
#   Get list of internal dependencies of a component that are runtime components.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :prefix_path: the prefix path to append to names of components targets found.
#
#     :suffix_ext: the suffix extension name to append to names of components targets found.
#
#     :RES_RESOURCES: the output variable that contains the list of internal runtime dependencies.
#
function(get_Bin_Component_Direct_Internal_Runtime_Dependencies RES_RESOURCES package component mode prefix_path suffix_ext)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(RES)
foreach(int_dep IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
	is_Runtime_Component(IS_RUNTIME ${package} ${int_dep})
	if(IS_RUNTIME)
		list(APPEND RES ${prefix_path}${int_dep}${TARGET_SUFFIX}${suffix_ext})
	endif()
endforeach()
set(${RES_RESOURCES} ${RES} PARENT_SCOPE)
endfunction(get_Bin_Component_Direct_Internal_Runtime_Dependencies)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Bin_Component_Direct_Runtime_Links_Dependencies| replace:: ``get_Bin_Component_Direct_Runtime_Links_Dependencies``
#  .. _get_Bin_Component_Direct_Runtime_Links_Dependencies:
#
#  get_Bin_Component_Direct_Runtime_Links_Dependencies
#  ---------------------------------------------------
#
#   .. command:: get_Bin_Component_Direct_Runtime_Links_Dependencies(RES_LINKS package component mode)
#
#   Get list of all public shared links directly used by a component at runtime.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :RES_LINKS: the output variable that contains the list of shared links used by component at runtime.
#
function(get_Bin_Component_Direct_Runtime_Links_Dependencies RES_LINKS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)
if(${package}_${component}_LINKS${VAR_SUFFIX})#if there are exported links
  resolve_External_Libs_Path(RES "${${package}_${component}_LINKS${VAR_SUFFIX}}" ${mode})#resolving libraries path against external packages path
	foreach(lib IN LISTS RES)
		is_Shared_Lib_With_Path(IS_SHARED ${lib})
		if(IS_SHARED)#only shared libs with absolute path need to be configured (the others are supposed to be retrieved automatically by the OS)
			list(APPEND result ${lib})
		endif()
	endforeach()
endif()
set(${RES_LINKS} ${result} PARENT_SCOPE)
endfunction(get_Bin_Component_Direct_Runtime_Links_Dependencies)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Bin_Component_Runtime_Dependencies| replace:: ``get_Bin_Component_Runtime_Dependencies``
#  .. _get_Bin_Component_Runtime_Dependencies:
#
#  get_Bin_Component_Runtime_Dependencies
#  --------------------------------------
#
#   .. command:: get_Bin_Component_Runtime_Dependencies(ALL_RUNTIME_RESOURCES package component mode)
#
#   Get list of all public runtime dependencies used by a component at runtime. Used to generate PID symlinks to resolve loading of shared libraries used by the component.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :ALL_RUNTIME_RESOURCES: the output variable that contains the list of all runtime dependencies of the component.
#
function(get_Bin_Component_Runtime_Dependencies ALL_RUNTIME_RESOURCES package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result "")

# 1) adding directly used external dependencies (only those bound to external package are interesting, system dependencies do not need a specific traetment)

get_Bin_Component_Direct_Runtime_Links_Dependencies(RES_LINKS ${package} ${component} ${mode})
list(APPEND result ${RES_LINKS})

# 2) adding package components dependencies
foreach(dep_pack IN LISTS ${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep_comp IN LISTS ${package}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})
		if(${dep_pack}_${dep_comp}_TYPE STREQUAL "HEADER" OR ${dep_pack}_${dep_comp}_TYPE STREQUAL "STATIC")
			get_Bin_Component_Runtime_Dependencies(INT_DEP_RUNTIME_RESOURCES ${dep_pack} ${dep_comp} ${mode}) #need to resolve external symbols whether the component is exported or not (it may have unresolved symbols coming from shared libraries) + resolve external runtime resources
			if(INT_DEP_RUNTIME_RESOURCES)
				list(APPEND result ${INT_DEP_RUNTIME_RESOURCES})
			endif()
		elseif(${dep_pack}_${dep_comp}_TYPE STREQUAL "SHARED")
			list(APPEND result ${${dep_pack}_ROOT_DIR}/lib/${${dep_pack}_${dep_comp}_BINARY_NAME${VAR_SUFFIX}})#the shared library is a direct dependency of the component
			is_Component_Exporting_Other_Components(EXPORTING ${dep_pack} ${dep_comp} ${mode})
			if(EXPORTING) # doing transitive search only if shared libs export something
				get_Bin_Component_Runtime_Dependencies(INT_DEP_RUNTIME_RESOURCES ${dep_pack} ${dep_comp} ${mode}) #need to resolve more external symbols only if the component is exported
				if(INT_DEP_RUNTIME_RESOURCES)# guarding against shared libs presence
					list(APPEND result ${INT_DEP_RUNTIME_RESOURCES})
				endif()
			endif() #no need to resolve external symbols if the shared library component is not exported
		endif()
	endforeach()
endforeach()

# 3) adding internal components dependencies
foreach(int_dep IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
	if(${package}_${int_dep}_TYPE STREQUAL "HEADER" OR ${package}_${int_dep}_TYPE STREQUAL "STATIC")
		get_Bin_Component_Runtime_Dependencies(INT_DEP_RUNTIME_RESOURCES ${package} ${int_dep} ${mode}) #need to resolve external symbols whether the component is exported or not (it may have unresolved symbols coming from shared libraries)
		if(INT_DEP_RUNTIME_RESOURCES)
			list(APPEND result ${INT_DEP_RUNTIME_RESOURCES})
		endif()
	elseif(${package}_${int_dep}_TYPE STREQUAL "SHARED")
		# no need to link internal dependencies with symbolic links (they will be found automatically)
		is_Component_Exporting_Other_Components(EXPORTING ${package} ${int_dep} ${mode})
		if(EXPORTING) # doing transitive search only if shared libs export something
			get_Bin_Component_Runtime_Dependencies(INT_DEP_RUNTIME_RESOURCES ${package} ${int_dep} ${mode}) #need to resolve external symbols only if the component is exported
			if(INT_DEP_RUNTIME_RESOURCES)# guarding against shared libs presence
				list(APPEND result ${INT_DEP_RUNTIME_RESOURCES})
			endif()
		endif() #no need to resolve external symbols if the shared library component is not exported
	endif()
endforeach()

# 4) adequately removing first duplicates in the list
list(REVERSE result)
list(REMOVE_DUPLICATES result)
list(REVERSE result)
set(${ALL_RUNTIME_RESOURCES} ${result} PARENT_SCOPE)
endfunction(get_Bin_Component_Runtime_Dependencies)

##################################################################################
################## finding shared libs dependencies for the linker ###############
##################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Dependent_Private_Shared_Libraries| replace:: ``find_Dependent_Private_Shared_Libraries``
#  .. _find_Dependent_Private_Shared_Libraries:
#
#  find_Dependent_Private_Shared_Libraries
#  ---------------------------------------
#
#   .. command:: find_Dependent_Private_Shared_Libraries(LIST_OF_UNDIRECT_DEPS package component is_direct mode)
#
#   Get the list of all private shared libraries that are undirect dependencies of a given component.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :is_direct: if TRUE then links to external libraries of the component are not taken into account.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :LIST_OF_UNDIRECT_DEPS: the output variable that is the list of undirect shared libraries used by component.
#
function(find_Dependent_Private_Shared_Libraries LIST_OF_UNDIRECT_DEPS package component is_direct mode)
set(undirect_list)
get_Mode_Variables(mode_binary_suffix mode_var_suffix ${mode})
# 0) no need to search for systems dependencies as they can be found automatically using OS shared libraries binding mechanism

# 1) searching public external dependencies
if(NOT is_direct) #otherwise external dependencies are direct dependencies so their LINKS (i.e. exported links) are already taken into account (not private)
	if(${package}_${component}_LINKS${mode_var_suffix})
		resolve_External_Libs_Path(RES_LINKS "${${package}_${component}_LINKS${mode_var_suffix}}" ${mode})#resolving libraries path against external packages path
		foreach(ext_dep IN LISTS RES_LINKS)
			is_Shared_Lib_With_Path(IS_SHARED ${ext_dep})
			if(IS_SHARED)
				list(APPEND undirect_list ${ext_dep})
			endif()
		endforeach()
	endif()
endif()

# 1-bis) searching private external dependencies
if(${package}_${component}_PRIVATE_LINKS${mode_var_suffix})
	resolve_External_Libs_Path(RES_PRIVATE_LINKS "${${package}_${component}_PRIVATE_LINKS${mode_var_suffix}}" ${mode})#resolving libraries path against external packages path
	foreach(ext_dep IN LISTS RES_PRIVATE_LINKS)
		is_Shared_Lib_With_Path(IS_SHARED ${ext_dep})
		if(IS_SHARED)
			list(APPEND undirect_list ${ext_dep})
		endif()
	endforeach()
endif()

# 2) searching in dependent packages
foreach(dep_package IN LISTS ${package}_${component}_DEPENDENCIES${mode_var_suffix})
	foreach(dep_component IN LISTS ${package}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${mode_var_suffix})
		set(UNDIRECT)
		if(is_direct) # current component is a direct dependency of the application
			if(	${dep_package}_${dep_component}_TYPE STREQUAL "STATIC"
				OR ${dep_package}_${dep_component}_TYPE STREQUAL "HEADER"
				OR ${package}_${component}_EXPORTS_${dep_package}_${dep_component}${mode_var_suffix})
				 #the potential shared lib dependencies of the header or static lib will be direct dependencies of the application OR the shared lib dependency is a direct dependency of the application
				find_Dependent_Private_Shared_Libraries(UNDIRECT ${dep_package} ${dep_component} TRUE ${mode})
			elseif(${dep_package}_${dep_component}_TYPE STREQUAL "SHARED")#it is a shared lib that is not exported
				find_Dependent_Private_Shared_Libraries(UNDIRECT ${dep_package} ${dep_component} FALSE ${mode}) #the shared lib dependency is NOT a direct dependency of the application
				list(APPEND undirect_list "${${dep_package}_ROOT_DIR}/lib/${${dep_package}_${dep_component}_BINARY_NAME${mode_var_suffix}}")
			endif()
		else() #current component is NOT a direct dependency of the application
			if(	${dep_package}_${dep_component}_TYPE STREQUAL "STATIC"
				OR ${dep_package}_${dep_component}_TYPE STREQUAL "HEADER")
				find_Dependent_Private_Shared_Libraries(UNDIRECT ${dep_package} ${dep_component} FALSE ${mode})
			elseif(${dep_package}_${dep_component}_TYPE STREQUAL "SHARED")#it is a shared lib that is not exported
				find_Dependent_Private_Shared_Libraries(UNDIRECT ${dep_package} ${dep_component} FALSE ${mode}) #the shared lib dependency is a direct dependency of the application
				list(APPEND undirect_list "${${dep_package}_ROOT_DIR}/lib/${${dep_package}_${dep_component}_BINARY_NAME${mode_var_suffix}}")
			endif()
		endif()

		if(UNDIRECT)
			list(APPEND undirect_list ${UNDIRECT})
		endif()
	endforeach()
endforeach()

# 3) searching in current package
foreach(dep_component IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${mode_var_suffix})
	set(UNDIRECT)
	if(is_direct) # current component is a direct dependency of the application
		if(	${package}_${dep_component}_TYPE STREQUAL "STATIC"
			OR ${package}_${dep_component}_TYPE STREQUAL "HEADER"
			OR ${package}_${component}_INTERNAL_EXPORTS_${dep_component}${mode_var_suffix})
			find_Dependent_Private_Shared_Libraries(UNDIRECT ${package} ${dep_component} TRUE ${mode}) #the potential shared lib dependencies of the header or static lib will be direct dependencies of the application OR the shared lib dependency is a direct dependency of the application
		elseif(${package}_${dep_component}_TYPE STREQUAL "SHARED")#it is a shared lib that is not exported
			find_Dependent_Private_Shared_Libraries(UNDIRECT ${package} ${dep_component} FALSE ${mode}) #the shared lib dependency is NOT a direct dependency of the application
			#adding this shared lib to the links of the application
			if(${package} STREQUAL ${PROJECT_NAME})
				#special case => the currenlty built package is the target package (may be not the case on recursion on another package)
				# we cannot target the lib folder as it does not exist at build time in the build tree
				# we simply target the corresponding build "target"
				list(APPEND undirect_list "${dep_component}${mode_binary_suffix}")
			else()
				list(APPEND undirect_list "${${package}_ROOT_DIR}/lib/${${package}_${dep_component}_BINARY_NAME${mode_var_suffix}}")
			endif()
		endif()
	else() #current component is NOT a direct dependency of the application
		if(	${package}_${dep_component}_TYPE STREQUAL "STATIC"
			OR ${package}_${dep_component}_TYPE STREQUAL "HEADER")
			find_Dependent_Private_Shared_Libraries(UNDIRECT ${package} ${dep_component} FALSE ${mode})
		elseif(${package}_${dep_component}_TYPE STREQUAL "SHARED")#it is a shared lib that is exported or NOT
			find_Dependent_Private_Shared_Libraries(UNDIRECT ${package} ${dep_component} FALSE ${mode}) #the shared lib dependency is NOT a direct dependency of the application in all cases

			#adding this shared lib to the links of the application
			if(${package} STREQUAL ${PROJECT_NAME})
				#special case => the currenlty built package is the target package (may be not the case on recursion on another package)
				# we cannot target the lib folder as it does not exist at build time in the build tree
				# we simply target the corresponding build "target"
				list(APPEND undirect_list "${dep_component}${mode_binary_suffix}")
			else()
				list(APPEND undirect_list "${${package}_ROOT_DIR}/lib/${${package}_${dep_component}_BINARY_NAME${mode_var_suffix}}")
			endif()
		endif()
	endif()

	if(UNDIRECT)
		list(APPEND undirect_list ${UNDIRECT})
	endif()
endforeach()

if(undirect_list) #if true we need to be sure that the rpath-link does not contain some dirs of the rpath (otherwise the executable may not run)
	list(REMOVE_DUPLICATES undirect_list)
	set(${LIST_OF_UNDIRECT_DEPS} "${undirect_list}" PARENT_SCOPE)
endif()
endfunction(find_Dependent_Private_Shared_Libraries)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Bin_Component_Direct_Runtime_PrivateLinks_Dependencies| replace:: ``get_Bin_Component_Direct_Runtime_PrivateLinks_Dependencies``
#  .. _get_Bin_Component_Direct_Runtime_PrivateLinks_Dependencies:
#
#  get_Bin_Component_Direct_Runtime_PrivateLinks_Dependencies
#  ----------------------------------------------------------
#
#   .. command:: get_Bin_Component_Direct_Runtime_PrivateLinks_Dependencies(RES_PRIVATE_LINKS package component mode)
#
#   Get list of all private shared links directly used by a component at runtime.
#
#     :package: the name of the package containing the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :RES_PRIVATE_LINKS: the output variable that contains the list of private shared links used by component at runtime.
#
function(get_Bin_Component_Direct_Runtime_PrivateLinks_Dependencies RES_PRIVATE_LINKS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)

if(${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX})#if there are private links
	resolve_External_Libs_Path(RES_PRIVATE "${${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX}}" ${mode})#resolving libraries path against external packages path
	foreach(lib IN LISTS RES_PRIVATE)
		is_Shared_Lib_With_Path(IS_SHARED ${lib})
		if(IS_SHARED)
			list(APPEND result ${lib})
		endif()
	endforeach()
endif()
set(${RES_PRIVATE_LINKS} ${result} PARENT_SCOPE)
endfunction(get_Bin_Component_Direct_Runtime_PrivateLinks_Dependencies)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Source_Component_Linktime_Dependencies| replace:: ``resolve_Source_Component_Linktime_Dependencies``
#  .. _resolve_Source_Component_Linktime_Dependencies:
#
#  resolve_Source_Component_Linktime_Dependencies
#  ----------------------------------------------
#
#   .. command:: resolve_Source_Component_Linktime_Dependencies(component mode THIRD_PARTY_LINKS)
#
#   Resolve required symbols for building an executable component contained in currently defined package. This consists in finding undirect shared libraries that are theorically unknown in the context of the component but that are required in order to globally resolve symbols when linking the executable.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :THIRD_PARTY_LINKS: the output variable that contains the list of undirect private shared dependencies of component.
#
function(resolve_Source_Component_Linktime_Dependencies component mode THIRD_PARTY_LINKS)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

will_be_Built(COMP_WILL_BE_BUILT ${component})

if(NOT COMP_WILL_BE_BUILT)#special case for executables that need rpath link to be specified (due to system shared libraries linking system)-> the linker must resolve all target links (even shared libs) transitively
	return()
endif()

is_Runtime_Component(COMP_IS_RUNTIME ${PROJECT_NAME} ${component})
if(NOT COMP_IS_RUNTIME)
	return()
endif()

set(undirect_deps)
# 0) no need to search for system libraries as they are installed and found automatically by the OS binding mechanism, idem for external dependencies since they are always direct dependencies for the currenlty build component

# 1) searching each direct dependency in other packages
foreach(dep_package IN LISTS ${PROJECT_NAME}_${component}_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep_component IN LISTS ${PROJECT_NAME}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
		set(LIST_OF_DEP_SHARED)
		is_HeaderFree_Component(IS_HF ${dep_package} ${dep_component})
		if(NOT IS_HF)
			find_Dependent_Private_Shared_Libraries(LIST_OF_DEP_SHARED ${dep_package} ${dep_component} TRUE ${CMAKE_BUILD_TYPE})
			if(LIST_OF_DEP_SHARED)
				list(APPEND undirect_deps ${LIST_OF_DEP_SHARED})
			endif()
		endif()
	endforeach()
endforeach()

# 2) searching each direct dependency in current package (no problem with undirect internal dependencies since undirect path only target install path which is not a problem for build)
foreach(dep_component IN LISTS ${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
	set(LIST_OF_DEP_SHARED)
	is_HeaderFree_Component(IS_HF ${PROJECT_NAME} ${dep_component})
	if(NOT IS_HF)
		find_Dependent_Private_Shared_Libraries(LIST_OF_DEP_SHARED ${PROJECT_NAME} ${dep_component} TRUE ${CMAKE_BUILD_TYPE})
		if(LIST_OF_DEP_SHARED)
			list(APPEND undirect_deps ${LIST_OF_DEP_SHARED})
		endif()
	endif()
endforeach()

if(undirect_deps) #if true we need to be sure that the rpath-link does not contain some dirs of the rpath (otherwise the executable may not run)
	list(REMOVE_DUPLICATES undirect_deps)
	get_target_property(thelibs ${component}${TARGET_SUFFIX} LINK_LIBRARIES)
	set_target_properties(${component}${TARGET_SUFFIX} PROPERTIES LINK_LIBRARIES "${thelibs};${undirect_deps}")
	set(${THIRD_PARTY_LINKS} ${undirect_deps} PARENT_SCOPE)
endif()
endfunction(resolve_Source_Component_Linktime_Dependencies)


##################################################################################
################## binary packages configuration #################################
##################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Package_Runtime_Dependencies| replace:: ``resolve_Package_Runtime_Dependencies``
#  .. _resolve_Package_Runtime_Dependencies:
#
#  resolve_Package_Runtime_Dependencies
#  ------------------------------------
#
#   .. command:: resolve_Package_Runtime_Dependencies(package mode)
#
#   Resolve all runtime dependencies for all components of a given package.
#
#     :package: the name of the package.
#
#     :mode: the build mode (Release or Debug) for the package.
#
function(resolve_Package_Runtime_Dependencies package mode)
if(${package}_PREPARE_RUNTIME)#this is a guard to limit recursion -> the runtime has already been prepared
	return()
endif()

if(${package}_DURING_PREPARE_RUNTIME)
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : cyclic dependencies between packages found : Package ${package} is undirectly requiring itself !")
	return()
endif()
set(${package}_DURING_PREPARE_RUNTIME TRUE)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

# 1) resolving runtime dependencies by recursion (resolving dependancy packages' components first)
if(${package}_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep IN LISTS ${package}_DEPENDENCIES${VAR_SUFFIX})
		resolve_Package_Runtime_Dependencies(${dep} ${mode})
	endforeach()
endif()
# 2) resolving runtime dependencies of the package's own components
foreach(component IN LISTS ${package}_COMPONENTS)
	resolve_Bin_Component_Runtime_Dependencies(${package} ${component} ${mode})
endforeach()
set(${package}_DURING_PREPARE_RUNTIME FALSE)
set(${package}_PREPARE_RUNTIME TRUE)
endfunction(resolve_Package_Runtime_Dependencies)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Bin_Component_Runtime_Dependencies| replace:: ``resolve_Bin_Component_Runtime_Dependencies``
#  .. _resolve_Bin_Component_Runtime_Dependencies:
#
#  resolve_Bin_Component_Runtime_Dependencies
#  ------------------------------------------
#
#   .. command:: resolve_Bin_Component_Runtime_Dependencies(package component mode)
#
#   Resolve runtime dependencies for a component contained in another package than currenlty defined one (a binary component). Resolution consists in creating adequate symlinks for shared libraries used by component.
#
#     :package: the name of the package that contains the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
function(resolve_Bin_Component_Runtime_Dependencies package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(	${package}_${component}_TYPE STREQUAL "SHARED"
	OR ${package}_${component}_TYPE STREQUAL "MODULE"
	OR ${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE")

	# 1) getting direct runtime dependencies
	get_Bin_Component_Runtime_Dependencies(ALL_RUNTIME_DEPS ${package} ${component} ${mode})#suppose that findPackage has resolved everything

	# 2) adding direct private external dependencies
	get_Bin_Component_Direct_Runtime_PrivateLinks_Dependencies(RES_PRIVATE_LINKS ${package} ${component} ${mode})
	list(APPEND ALL_RUNTIME_DEPS ${RES_PRIVATE_LINKS})

	#3) getting direct and undirect runtime resources dependencies
	get_Bin_Component_Runtime_Resources_Dependencies(RES_RESOURCES ${package} ${component} ${mode})
	list(APPEND ALL_RUNTIME_DEPS ${RES_RESOURCES})
	create_Bin_Component_Symlinks(${package} ${component} ${mode} "${ALL_RUNTIME_DEPS}")
	if(${package}_${component}_TYPE STREQUAL "MODULE"
			AND ${package}_${component}_HAS_PYTHON_WRAPPER #this is a python wrapper => python needs additionnal configuration to work properly
			AND CURRENT_PYTHON)#python is activated
		# getting path to internal targets dependecies that produce a runtime code (not used for rpath but required for python modules)

		#cannot use the generator expression due to generator expression not evaluated in install(CODE) -> CMake BUG
		if(CURRENT_PLATFORM_OS STREQUAL "macosx")
	    set(suffix_ext .dylib)
    elseif(CURRENT_PLATFORM_OS STREQUAL "windows")
        set(suffix_ext .dll)
		else()
		    set(suffix_ext .so)
		endif()
		#we need to reference also internal libraries for creating adequate symlinks for python
		set(prefix_path ${${package}_ROOT_DIR}/lib/lib)
		get_Bin_Component_Direct_Internal_Runtime_Dependencies(RES_DEPS ${package} ${component} ${CMAKE_BUILD_TYPE} ${prefix_path} ${suffix_ext})
		list(APPEND ALL_RUNTIME_DEPS ${RES_DEPS})
		#finally we need to reference also the module binary itself
		get_Binary_Location(LOCATION_RES ${package} ${component} ${mode})
		list(APPEND ALL_RUNTIME_DEPS ${LOCATION_RES})
		create_Bin_Component_Python_Symlinks(${package} ${component} ${CMAKE_BUILD_TYPE} "${ALL_RUNTIME_DEPS}")
	endif()
endif()
endfunction(resolve_Bin_Component_Runtime_Dependencies)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Bin_Component_Symlinks| replace:: ``create_Bin_Component_Symlinks``
#  .. _create_Bin_Component_Symlinks:
#
#  create_Bin_Component_Symlinks
#  -----------------------------
#
#   .. command:: create_Bin_Component_Symlinks(package component mode)
#
#   Generating symlinks to a set of runtime resources used by a component contained in a package that is not the currenlty defined one.
#
#     :package: the name of the package that contains the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :resources: the list of path to resources that need to be symlinked.
#
function(create_Bin_Component_Symlinks package component mode resources)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
#creatings symbolic links
foreach(resource IN LISTS resources)
	create_Runtime_Symlink("${resource}" "${${package}_ROOT_DIR}/.rpath" ${component}${TARGET_SUFFIX})
endforeach()
endfunction(create_Bin_Component_Symlinks)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Bin_Component_Python_Symlinks| replace:: ``create_Bin_Component_Python_Symlinks``
#  .. _create_Bin_Component_Python_Symlinks:
#
#  create_Bin_Component_Python_Symlinks
#  ------------------------------------
#
#   .. command:: create_Bin_Component_Python_Symlinks(package component mode)
#
#   Generating symlinks to a set of resources needed by a component contained in a package that is not the currenlty defined one. These symlinks are created in a place where python scripts can find them.
#
#     :package: the name of the package that contains the component.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :resources: the list of path to runtime resources that need to be symlinked.
#
function(create_Bin_Component_Python_Symlinks package component mode resources)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
foreach(resource IN LISTS resources)
	create_Runtime_Symlink("${resource}" "${${package}_ROOT_DIR}/share/script" ${component})#installing Debug and Release modes links in the same script folder
endforeach()
endfunction(create_Bin_Component_Python_Symlinks)

##################################################################################
################### source package run time dependencies in install tree #########
##################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Source_Component_Python_Symlinks| replace:: ``create_Source_Component_Python_Symlinks``
#  .. _create_Source_Component_Python_Symlinks:
#
#  create_Source_Component_Python_Symlinks
#  ---------------------------------------
#
#   .. command:: create_Source_Component_Python_Symlinks(component mode resources)
#
#   Installing symlinks to a set of resources needed by a component of the currenlty defined package. These symlinks are installed in a place where python scripts can find them.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :resources: the list of path to runtime resources that need to be symlinked.
#
function(create_Source_Component_Python_Symlinks component mode resources)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
foreach(resource IN LISTS resources)
	install_Runtime_Symlink(${resource} "${${PROJECT_NAME}_DEPLOY_PATH}/share/script" ${component})#installing Debug and Release modes links in the same script folder
endforeach()
endfunction(create_Source_Component_Python_Symlinks)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Source_Component_Symlinks| replace:: ``create_Source_Component_Symlinks``
#  .. _create_Source_Component_Symlinks:
#
#  create_Source_Component_Symlinks
#  --------------------------------
#
#   .. command:: create_Source_Component_Symlinks(component mode resources)
#
#   Installing symlinks to a set of resources needed by a component of the currenlty defined package.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :resources: the list of path to runtime resources that need to be symlinked.
#
function(create_Source_Component_Symlinks component mode resources)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
foreach(resource IN LISTS resources)
	install_Runtime_Symlink(${resource} "${${PROJECT_NAME}_DEPLOY_PATH}/.rpath" ${component}${TARGET_SUFFIX})
endforeach()
endfunction(create_Source_Component_Symlinks)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Source_Component_Runtime_Dependencies| replace:: ``resolve_Source_Component_Runtime_Dependencies``
#  .. _resolve_Source_Component_Runtime_Dependencies:
#
#  resolve_Source_Component_Runtime_Dependencies
#  ---------------------------------------------
#
#   .. command:: resolve_Source_Component_Runtime_Dependencies(component mode third_party_libs)
#
#   Resolve runtime dependencies of a component in the currenlty defined package. Finally create symlinks to these runtime resources in the install tree.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :third_party_libs: the list of third party libraries for which symlinks must be created in addition of those resolved by the function. Used when creating symlinks for an application to ensure the executable will finally load the goos libraries (for instance instead of OS ones).
#
function(resolve_Source_Component_Runtime_Dependencies component mode third_party_libs)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(	${PROJECT_NAME}_${component}_TYPE STREQUAL "SHARED"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "MODULE"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "APP"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE" )
	# 1) getting all public runtime dependencies (including inherited ones)
	get_Bin_Component_Runtime_Dependencies(ALL_RUNTIME_DEPS ${PROJECT_NAME} ${component} ${CMAKE_BUILD_TYPE})
	# 2) adding direct private external dependencies
	get_Bin_Component_Direct_Runtime_PrivateLinks_Dependencies(RES_PRIVATE_LINKS ${PROJECT_NAME} ${component} ${CMAKE_BUILD_TYPE})
	list(APPEND ALL_RUNTIME_DEPS ${RES_PRIVATE_LINKS})
	#3) getting direct and undirect runtime resources dependencies
	get_Bin_Component_Runtime_Resources_Dependencies(RES_RESOURCES ${PROJECT_NAME} ${component} ${CMAKE_BUILD_TYPE})
	list(APPEND ALL_RUNTIME_DEPS ${RES_RESOURCES})
	# 3) in case of an executable component add third party (undirect) links
  if(third_party_libs)
		list(APPEND ALL_RUNTIME_DEPS ${third_party_libs})
  endif()

	create_Source_Component_Symlinks(${component} ${CMAKE_BUILD_TYPE} "${ALL_RUNTIME_DEPS}")
	if(${PROJECT_NAME}_${component}_TYPE STREQUAL "MODULE"
			AND ${PROJECT_NAME}_${component}_HAS_PYTHON_WRAPPER #this is a python wrapper => python needs additionnal configuration to work properly
			AND CURRENT_PYTHON)#python is activated
		# getting path to internal targets dependecies that produce a runtime code (not used for rpath but required for python modules)

		#cannot use the generator expression due to generator expression not evaluated in install(CODE) -> CMake BUG
		if(CURRENT_PLATFORM_OS STREQUAL "macosx")
		    set(suffix_ext .dylib)
        elseif(CURRENT_PLATFORM_OS STREQUAL "windows")
            set(suffix_ext .dll)
		else()
		    set(suffix_ext .so)
		endif()
		set(prefix_path ${${PROJECT_NAME}_INSTALL_PATH}/${${PROJECT_NAME}_DEPLOY_PATH}/lib/lib)
		get_Bin_Component_Direct_Internal_Runtime_Dependencies(RES_DEPS ${PROJECT_NAME} ${component} ${CMAKE_BUILD_TYPE} ${prefix_path} ${suffix_ext})
		list(APPEND ALL_RUNTIME_DEPS ${RES_DEPS})
		create_Source_Component_Python_Symlinks(${component} ${CMAKE_BUILD_TYPE} "${ALL_RUNTIME_DEPS}")
	endif()
endif()
endfunction(resolve_Source_Component_Runtime_Dependencies)

##################################################################################
################### source package run time dependencies in build tree ###########
##################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Source_Component_Direct_Runtime_Resources_Dependencies| replace:: ``get_Source_Component_Direct_Runtime_Resources_Dependencies``
#  .. _get_Source_Component_Direct_Runtime_Resources_Dependencies:
#
#  get_Source_Component_Direct_Runtime_Resources_Dependencies
#  ----------------------------------------------------------
#
#   .. command:: get_Source_Component_Direct_Runtime_Resources_Dependencies(RES_RESOURCES component mode)
#
#   Get list of path to all runtime resources (executables, modules, files and folders) directly used by a component (from currenlty defined package) at runtime.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :RES_RESOURCES: the output variable that contains the list of path to runtime resources.
#
function(get_Source_Component_Direct_Runtime_Resources_Dependencies RES_RESOURCES component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)
if(${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX})#if there are exported resources
	resolve_External_Resources_Path(COMPLETE_RESOURCES_PATH "${${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX}}" ${mode})
	foreach(path IN LISTS COMPLETE_RESOURCES_PATH)
		if(NOT IS_ABSOLUTE ${path}) #relative path => this a native package resource
			list(APPEND result ${CMAKE_SOURCE_DIR}/share/resources/${path})#the path contained by the link
		else() #external or absolute resource path coming from external/system dependencies
			list(APPEND result ${path})#the direct path to the dependency (absolute initially or relative to the external package and resolved)
		endif()
	endforeach()
endif()

set(${RES_RESOURCES} ${result} PARENT_SCOPE)
endfunction(get_Source_Component_Direct_Runtime_Resources_Dependencies)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Source_Component_Runtime_Resources_Dependencies| replace:: ``get_Source_Component_Runtime_Resources_Dependencies``
#  .. get_Source_Component_Runtime_Resources_Dependencies:
#
#  get_Source_Component_Runtime_Resources_Dependencies
#  ---------------------------------------------------
#
#   .. command:: get_Source_Component_Runtime_Resources_Dependencies(RES_RESOURCES component mode)
#
#   Get list of path to all resources (executables, modules, files and folders) directly or undirectly used by a component (from currenlty defined package) at runtime.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :RES_RESOURCES: the output variable that contains the list of path to runtime resources.
#
function(get_Source_Component_Runtime_Resources_Dependencies RES_RESOURCES component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)

get_Source_Component_Direct_Runtime_Resources_Dependencies(DIRECT_RESOURCES ${component} ${mode})
list(APPEND result ${DIRECT_RESOURCES})

foreach(dep_pack IN LISTS ${PROJECT_NAME}_${component}_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep_comp IN LISTS ${PROJECT_NAME}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})
		#applications do not need to propagate their runtime resources (since everything will be resolved according to their own rpath and binary location)
		#nevertheless they can allow the access to some of their file or directory in order to let other code modify or extent their runtime behavior (for instance by modifying configuration files)
		get_Bin_Component_Runtime_Resources_Dependencies(INT_DEP_RUNTIME_RESOURCES ${dep_pack} ${dep_comp} ${mode}) #resolve external runtime resources
		if(INT_DEP_RUNTIME_RESOURCES)
			list(APPEND result ${INT_DEP_RUNTIME_RESOURCES})
		endif()
		if(${dep_pack}_${dep_comp}_TYPE STREQUAL "MODULE")
			list(APPEND result ${${dep_pack}_ROOT_DIR}/lib/${${dep_pack}_${dep_comp}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
		elseif(${dep_pack}_${dep_comp}_TYPE STREQUAL "APP" OR  ${dep_pack}_${dep_comp}_TYPE STREQUAL "EXAMPLE")
			list(APPEND result ${${dep_pack}_ROOT_DIR}/bin/${${dep_pack}_${dep_comp}_BINARY_NAME${VAR_SUFFIX}})#the application is a direct runtime dependency of the component
		endif()

	endforeach()
endforeach()

# 3) adding internal components dependencies
foreach(int_dep IN LISTS ${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
	#applications do not need to propagate their runtime resources (since everything will be resolved according to their own rpath and binary location
	#nevertheless they can allow the access to some of their file or directory in order to let other code modify or extent their runtime behavior (for instance by modifying configuration files)
	get_Source_Component_Runtime_Resources_Dependencies(INT_DEP_RUNTIME_RESOURCES ${int_dep} ${mode})
	if(INT_DEP_RUNTIME_RESOURCES)
		list(APPEND result ${INT_DEP_RUNTIME_RESOURCES})
	endif()
	if(${PROJECT_NAME}_${int_dep}_TYPE STREQUAL "MODULE")
		list(APPEND result ${CMAKE_BINARY_DIR}/src/${${PROJECT_NAME}_${int_dep}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
	elseif(${PROJECT_NAME}_${int_dep}_TYPE STREQUAL "APP" OR ${PROJECT_NAME}_${int_dep}_TYPE STREQUAL "EXAMPLE")
		list(APPEND result ${CMAKE_BINARY_DIR}/apps/${${PROJECT_NAME}_${int_dep}_BINARY_NAME${VAR_SUFFIX}})#the application is a direct runtime dependency of the component
	endif()
endforeach()
set(${RES_RESOURCES} ${result} PARENT_SCOPE)
endfunction(get_Source_Component_Runtime_Resources_Dependencies)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Source_Component_Symlinks_Build_Tree| replace:: ``create_Source_Component_Symlinks_Build_Tree``
#  .. _create_Source_Component_Symlinks_Build_Tree:
#
#  create_Source_Component_Symlinks_Build_Tree
#  -------------------------------------------
#
#   .. command:: create_Source_Component_Symlinks_Build_Tree(component mode resources)
#
#   In build tree, create symlinks to a set of runtime resources (executables, modules, files, folders) needed by a component of the currenlty defined package.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :resources: the list of path to runtime resources that need to be symlinked.
#
function(create_Source_Component_Symlinks_Build_Tree component mode resources)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(resources)
	foreach(resource IN LISTS resources)
		create_Runtime_Symlink(${resource} ${CMAKE_BINARY_DIR}/.rpath ${component}${TARGET_SUFFIX})
	endforeach()
endif()
endfunction(create_Source_Component_Symlinks_Build_Tree)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Source_Component_Runtime_Dependencies_Build_Tree| replace:: ``resolve_Source_Component_Runtime_Dependencies_Build_Tree``
#  .. _resolve_Source_Component_Runtime_Dependencies_Build_Tree:
#
#  resolve_Source_Component_Runtime_Dependencies_Build_Tree
#  --------------------------------------------------------
#
#   .. command:: resolve_Source_Component_Runtime_Dependencies_Build_Tree(component mode)
#
#   Resolve runtime dependencies of a component in the currenlty defined package. Finally create symlinks to these runtime resources in the build tree. This differentiation is mandatory to get runtime resource mechanism working in build tree (required for runninf test units using runtime resources for instance).
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
function(resolve_Source_Component_Runtime_Dependencies_Build_Tree component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(	${PROJECT_NAME}_${component}_TYPE STREQUAL "SHARED"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "MODULE"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "APP"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")

	# getting direct and undirect runtime resources dependencies
	get_Source_Component_Runtime_Resources_Dependencies(RES_RESOURCES ${component} ${CMAKE_BUILD_TYPE})#resolving dependencies according to local links
	create_Source_Component_Symlinks_Build_Tree(${component} ${CMAKE_BUILD_TYPE} "${RES_RESOURCES}")
endif()
endfunction(resolve_Source_Component_Runtime_Dependencies_Build_Tree)

###############################################################################################
############################## cleaning the installed tree ####################################
###############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |clean_Install_Dir| replace:: ``clean_Install_Dir``
#  .. clean_Install_Dir:
#
#  clean_Install_Dir
#  -----------------
#
#   .. command:: clean_Install_Dir()
#
#   Define a target that automatically cleans the install folder of the currenlty defined package anytime the build target is launched.
#
function(clean_Install_Dir)
get_System_Variables(CURRENT_PLATFORM_NAME CURRENT_PACKAGE_STRING)
if(	${CMAKE_BUILD_TYPE} MATCHES Release
	AND EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM_NAME}/${PROJECT_NAME}/${${PROJECT_NAME}_DEPLOY_PATH}
	AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM_NAME}/${PROJECT_NAME}/${${PROJECT_NAME}_DEPLOY_PATH} #if package is already installed
)
	# calling a script that will do the job in its own context (to avoid problem when including cmake scripts that would redefine critic variables)
	add_custom_target(cleaning_install
							COMMAND ${CMAKE_COMMAND} -DWORKSPACE_DIR=${WORKSPACE_DIR}
						 -DPACKAGE_NAME=${PROJECT_NAME}
						 -DCURRENT_PLATFORM=${CURRENT_PLATFORM_NAME}
						 -DPACKAGE_INSTALL_VERSION=${${PROJECT_NAME}_DEPLOY_PATH}
						 -DPACKAGE_VERSION=${${PROJECT_NAME}_VERSION}
						 -DNEW_USE_FILE=${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake #this file does not exist at configruation time (only after generation phase)
						 -P ${WORKSPACE_DIR}/share/cmake/system/commands/Clear_PID_Package_Install.cmake
						 COMMENT "[PID] INFO : Cleaning install tree ..."
						 VERBATIM
	)
	add_dependencies(build cleaning_install) #removing built files in install tree that have been deleted with new configuration

endif()
endfunction(clean_Install_Dir)

#.rst:
#
# .. ifmode:: internal
#
#  .. |locate_External_Package_Used_In_Component| replace:: ``locate_External_Package_Used_In_Component``
#  .. _locate_External_Package_Used_In_Component:
#
#  locate_External_Package_Used_In_Component
#  -----------------------------------------
#
#   .. command:: locate_External_Package_Used_In_Component(USE_PACKAGE package component mode external_package)
#
#   Tell whether an external package is used within a given component.
#
#     :package: the name of the package.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :external_package: the name of external package to check.
#
#     :USE_PACKAGE: the output variable that is TRUE if the external package is used within component, FALSE otherwise.
#
function(locate_External_Package_Used_In_Component USE_PACKAGE package component mode external_package)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  # consists in searching for the <${external_package}> in flags used by the component
  set(${USE_PACKAGE} FALSE PARENT_SCOPE)
  set(all_flags "${${package}_${component}_INC_DIRS${VAR_SUFFIX}};${${package}_${component}_LINKS${VAR_SUFFIX}};${${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX}};${${package}_${component}_LIB_DIRS${VAR_SUFFIX}};${${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX}}")
  string(FIND "${all_flags}" "<${external_package}>" INDEX)#simply find the pattern specifying the path to installed package version folder
  if(INDEX GREATER -1)
    set(${USE_PACKAGE} TRUE PARENT_SCOPE)
  endif()
endfunction(locate_External_Package_Used_In_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_External_Packages_Used_In_Component| replace:: ``get_External_Packages_Used_In_Component``
#  .. _get_External_Packages_Used_In_Component:
#
#  get_External_Packages_Used_In_Component
#  ---------------------------------------
#
#   .. command:: get_External_Packages_Used_In_Component(USED_EXT_PACKAGES package component mode)
#
#   Get all external package that a given BINARY component depends on.
#
#     :package: the name of the package.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :external_package: the name of external package to check.
#
#     :USED_EXT_PACKAGES: the output variable that contains the list of external dependencies directly or undirectly used by component.
#
function(get_External_Packages_Used_In_Component USED_EXT_PACKAGES package component mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  set(external_deps)
  foreach(ext_dep IN LISTS ${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
    locate_External_Package_Used_In_Component(IS_USED ${package} ${component} ${mode} ${ext_dep})
    if(IS_USED)
      list(APPEND external_deps ${ext_dep})
    endif()
    #need also to find in external dependencies of these external dependencies, if their name appears in exported symbol then they must be direct dependencies in binaries
    #this is a special case as external packages are explicitly written in component flags
    foreach(ext_dep_dep IN LISTS ${ext_dep}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
      locate_External_Package_Used_In_Component(IS_USED ${package} ${component} ${mode} ${ext_dep_dep})
      if(IS_USED)
        list(APPEND external_deps ${ext_dep_dep})
      endif()
    endforeach()
  endforeach()
  if(external_deps)
    list(REMOVE_DUPLICATES external_deps)
  endif()
  set(${USED_EXT_PACKAGES} ${external_deps} PARENT_SCOPE)
endfunction(get_External_Packages_Used_In_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Packages_Used_In_Component| replace:: ``get_Packages_Used_In_Component``
#  .. _get_Packages_Used_In_Component:
#
#  get_Packages_Used_In_Component
#  ------------------------------
#
#   .. command:: get_Packages_Used_In_Component(USED_NATIVE_PACKAGES USED_EXT_PACKAGES package component mode)
#
#   Get all packages that a given BINARY component depends on.
#
#     :package: the name of the package.
#
#     :component: the name of the component.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :USED_NATIVE_PACKAGES: the output variable that contains the list of native dependencies directly or undirectly used by component.
#
#     :USED_EXT_PACKAGES: the output variable that contains the list of external dependencies directly or undirectly used by component.
#
function(get_Packages_Used_In_Component USED_NATIVE_PACKAGES USED_EXT_PACKAGES package component mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  set(${USED_NATIVE_PACKAGES} PARENT_SCOPE)
  set(${USED_EXT_PACKAGES} PARENT_SCOPE)
  #no need to look into internal dependencies as they will be finally managed by a call to this function

  set(external_deps)
  set(native_deps)

  #first find the direct external dependencies + undirect dependencies
  get_External_Packages_Used_In_Component(EXT_PACKAGES ${package} ${component} ${mode})
  if(EXT_PACKAGES)
    list(APPEND external_deps ${EXT_PACKAGES})
  endif()

  #second find the direct native dependencies = simple as dependencies to other native package are explicit
  if(${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
    list(APPEND native_deps ${${package}_${component}_DEPENDENCIES${VAR_SUFFIX}})
    #need to look into each of its native package dependencies
    foreach(nat_dep IN LISTS ${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
      foreach(nat_dep_com IN LISTS ${package}_${component}_DEPENDENCY_${nat_dep}_COMPONENTS${VAR_SUFFIX})#depends on some native components
        #dealing with external dependencies => get exported references of external packages in these components
        get_External_Packages_Used_In_Component(EXT_PACKAGES ${nat_dep} ${nat_dep_com} ${mode})
        if(EXT_PACKAGES)
          list(APPEND external_deps ${EXT_PACKAGES})
        endif()
        #dealing with native dependencies
        foreach(nat_dep_com_dep IN LISTS ${nat_dep}_${nat_dep_com}_DEPENDENCIES${VAR_SUFFIX})
          foreach(nat_dep_com_dep_comp IN LISTS ${nat_dep}_${nat_dep_com}_DEPENDENCY_${nat_dep_com_dep}_COMPONENTS${VAR_SUFFIX})#depends on some native components
            if(${nat_dep}_${nat_dep_com}_EXPORT_${nat_dep_com_dep}_${nat_dep_com_dep_comp})#the dependency export another component from another package so symbols of this another component will appear in current package component
              #=> the undirect package must be a direct dependency of this one
              list(APPEND native_deps ${nat_dep_com_dep})
            endif()
          endforeach()
        endforeach()
      endforeach()
    endforeach()
  endif()

  if(native_deps)
    list(REMOVE_DUPLICATES native_deps)
  endif()
  if(external_deps)
    list(REMOVE_DUPLICATES external_deps)
  endif()
  set(${USED_EXT_PACKAGES} ${external_deps} PARENT_SCOPE)
  set(${USED_NATIVE_PACKAGES} ${native_deps} PARENT_SCOPE)

endfunction(get_Packages_Used_In_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |collect_Local_Exported_Dependencies| replace:: ``collect_Local_Exported_Dependencies``
#  .. _collect_Local_Exported_Dependencies:
#
#  collect_Local_Exported_Dependencies
#  -----------------------------------
#
#   .. command:: collect_Local_Exported_Dependencies(NATIVE_DEPS EXTERNAL_DEPS package mode)
#
#   Get all packages that a given BINARY package depends on.
#
#     :package: the name of the package.
#
#     :mode: the build mode (Release or Debug) for the component.
#
#     :NATIVE_DEPS: the output variable that contains the list of native dependencies directly or undirectly used by component.
#
#     :EXTERNAL_DEPS: the output variable that contains the list of external dependencies directly or undirectly used by component.
#
function(collect_Local_Exported_Dependencies NATIVE_DEPS EXTERNAL_DEPS package mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  set(${NATIVE_DEPS} PARENT_SCOPE)
  set(${EXTERNAL_DEPS} PARENT_SCOPE)

  set(external_deps)
  set(native_deps)

  foreach(comp IN LISTS ${package}_COMPONENTS)# foreach component defined by the package
    will_be_Installed(RESULT ${comp})
    if(RESULT)#OK take into account this component because it is present in install tree (i.e. it lies in the binary package version)
      get_Packages_Used_In_Component(USED_NATIVE_PACKAGES USED_EXT_PACKAGES ${package} ${comp} ${mode})
      if(USED_NATIVE_PACKAGES)
        list(APPEND native_deps ${USED_NATIVE_PACKAGES})
      endif()
      if(USED_EXT_PACKAGES)
        list(APPEND external_deps ${USED_EXT_PACKAGES})
      endif()
    endif()
  endforeach()

  if(native_deps)
    list(REMOVE_DUPLICATES native_deps)
  endif()
  if(external_deps)
    list(REMOVE_DUPLICATES external_deps)
  endif()
  #need to memorize in binary the version of dependencies finally used to build it !!!
  set(ext_result)
  foreach(ext IN LISTS external_deps)#for direct external dependencies
    if(${ext}_BUILT_OS_VARIANT)#need to know if this is the OS variant that has been found
      set(system_str "TRUE")
      set(exact_str "TRUE")#an OS variant is always exact ?? we say YES as an hypothesis
    else()
      set(system_str "FALSE")
      if(${ext}_REQUIRED_VERSION_EXACT)# version may be or not set to something so manage its value explicilty to avoid having an empty element in the list
        set(exact_str "TRUE")#an OS variant is always exact ?? we say YES as an hypothesis
      else()
        set(exact_str "FALSE")#an OS variant is always exact ?? we say YES as an hypothesis
      endif()
    endif()
    list(APPEND ext_result "${ext},${${ext}_VERSION_STRING},${exact_str},${system_str}")
  endforeach()

  set(nat_result)
  foreach(nat IN LISTS native_deps)#for direct external dependencies
    if(${nat}_REQUIRED_VERSION_EXACT)# version may be or not set to semething so manage its value explicilty to avoid having an empty element in the list
      list(APPEND nat_result "${nat},${${nat}_VERSION_STRING},TRUE,FALSE")#native are never system dependencies
    else()
      list(APPEND nat_result "${nat},${${nat}_VERSION_STRING},FALSE,FALSE")#native are never system dependencies
    endif()
  endforeach()

  set(${NATIVE_DEPS} ${nat_result} PARENT_SCOPE)
  set(${EXTERNAL_DEPS} ${ext_result} PARENT_SCOPE)
endfunction(collect_Local_Exported_Dependencies)
