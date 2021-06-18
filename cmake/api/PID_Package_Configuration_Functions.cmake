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
#   .. command:: list_Public_Includes(INCLUDES package component mode self)
#
#   List all public include path of a component.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#     :self: if TRUE the component returns its own header dir (for native only).
#
#     :INCLUDES: the output variable that contains the list of public include path.
#
function(list_Public_Includes INCLUDES package component mode self)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(self)
  set(RES "${${package}_ROOT_DIR}/include/${${package}_${component}_HEADER_DIR_NAME}")
else()
  set(RES)
endif()
#additionally provided include dirs (cflags -I<path>) (external/system exported include dirs)
if(${package}_${component}_INC_DIRS${VAR_SUFFIX})
  evaluate_Variables_In_List(EVAL_INCS ${package}_${component}_INC_DIRS${VAR_SUFFIX})#first evaluate element of the list => if they are variables they are evaluated
  resolve_External_Includes_Path(RES_INCLUDES "${EVAL_INCS}" ${mode})
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
#   .. command:: list_Public_Links(LINKS STATIC_LINKS package component mode)
#
#   List all public links of a component.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :LINKS: the output variable that contains the list of public links.
#     :STATIC_LINKS: the output variable that contains the list of public system links specified as STATIC.
#
function(list_Public_Links LINKS STATIC_LINKS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

#provided additionnal ld flags (exported external/system libraries and ldflags)
if(${package}_${component}_LINKS${VAR_SUFFIX})
  evaluate_Variables_In_List(EVAL_SH_LINKS ${package}_${component}_LINKS${VAR_SUFFIX}) #first evaluate element of the list => if they are variables they are evaluated
	resolve_External_Libs_Path(RES_LINKS "${EVAL_SH_LINKS}" ${mode})
  set(${LINKS} "${RES_LINKS}" PARENT_SCOPE)
endif()
if(${package}_${component}_SYSTEM_STATIC_LINKS${VAR_SUFFIX})
  evaluate_Variables_In_List(EVAL_ST_LINKS ${package}_${component}_SYSTEM_STATIC_LINKS${VAR_SUFFIX}) #first evaluate element of the list => if they are variables they are evaluated
	resolve_External_Libs_Path(RES_ST_LINKS "${EVAL_ST_LINKS}" ${mode})
  set(${STATIC_LINKS} ${RES_ST_LINKS} PARENT_SCOPE)
endif()
endfunction(list_Public_Links)

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_External_Links| replace:: ``list_External_Links``
#  .. _list_External_Links:
#
#  list_External_Links
#  -------------------
#
#   .. command:: list_External_Links(SHARED_LINKS STATIC_LINKS package component mode)
#
#   List all public links of a component.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :LINKS: the output variable that contains the list of public links.
#     :STATIC_LINKS: the output variable that contains the list of links to static libraries.
#     :STATIC_LINKS: the output variable that contains the list of links to shared libraries.
#
function(list_External_Links SHARED_LINKS STATIC_LINKS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(${STATIC_LINKS} PARENT_SCOPE)
set(${SHARED_LINKS} PARENT_SCOPE)
#provided additionnal ld flags (exported external/system libraries and ldflags)
if(${package}_${component}_STATIC_LINKS${VAR_SUFFIX})
  evaluate_Variables_In_List(EVAL_ST_LINKS ${package}_${component}_STATIC_LINKS${VAR_SUFFIX}) #first evaluate element of the list => if they are variables they are evaluated
	resolve_External_Libs_Path(RES_ST_LINKS "${EVAL_ST_LINKS}" ${mode})
  set(${STATIC_LINKS} ${RES_ST_LINKS} PARENT_SCOPE)
endif()
if(${package}_${component}_SHARED_LINKS${VAR_SUFFIX})
  evaluate_Variables_In_List(EVAL_SH_LINKS ${package}_${component}_SHARED_LINKS${VAR_SUFFIX}) #first evaluate element of the list => if they are variables they are evaluated
	resolve_External_Libs_Path(RES_SH_LINKS "${EVAL_SH_LINKS}" ${mode})
  set(${SHARED_LINKS} ${RES_SH_LINKS} PARENT_SCOPE)
endif()
endfunction(list_External_Links)

#.rst:
#
# .. ifmode:: internal
#
#  .. |list_Public_Lib_Dirs| replace:: ``list_Public_Lib_Dirs``
#  .. _list_Public_Lib_Dirs:
#
#  list_Public_Lib_Dirs
#  --------------------
#
#   .. command:: list_Public_Lib_Dirs(DIRS package component mode)
#
#   List all public library directories of a component.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :DIRS: the output variable that contains the list of public library directories.
#
function(list_Public_Lib_Dirs DIRS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
#provided additionnal ld flags (exported external/system libraries and ldflags)
if(${package}_${component}_LIB_DIRS${VAR_SUFFIX})
  #evaluate variable that may come from system configurations
  evaluate_Variables_In_List(EVAL_LDIRS ${package}_${component}_LIB_DIRS${VAR_SUFFIX})
  #then resolve complete path to external packages
  resolve_External_Libs_Path(RES_DIRS "${EVAL_LDIRS}" ${mode})
  set(${DIRS} ${RES_DIRS} PARENT_SCOPE)
else()
  set(${DIRS} PARENT_SCOPE)
endif()
endfunction(list_Public_Lib_Dirs)

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
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :DEFS: the output variable that contains the list of public definitions.
#
function(list_Public_Definitions DEFS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(${package}_${component}_DEFS${VAR_SUFFIX})
  #evaluate variables that may come from system configurations
  evaluate_Variables_In_List(EVAL_INCS ${package}_${component}_DEFS${VAR_SUFFIX})
	set(${DEFS} ${EVAL_INCS} PARENT_SCOPE)
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
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :OPTS: the output variable that contains the list of public compiler options.
#
function(list_Public_Options OPTS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
#checking that no compiler option is used directly to set the standard
#remove the option and set the standard adequately instead
set(FILTERED_OPTS)
if(${package}_${component}_OPTS${VAR_SUFFIX})
  evaluate_Variables_In_List(EVAL_OPTS ${package}_${component}_OPTS${VAR_SUFFIX})
  foreach(opt IN LISTS EVAL_OPTS)
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
endif()
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
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :LOCATION_RES: the output variable that contains the path to the component's binary.
#
function(get_Binary_Location LOCATION_RES package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
rename_If_Alias(comp_name_to_use ${package} ${component})
is_Executable_Component(IS_EXE ${package} ${comp_name_to_use})
if(IS_EXE)
	set(${LOCATION_RES} "${${package}_ROOT_DIR}/bin/${${package}_${comp_name_to_use}_BINARY_NAME${VAR_SUFFIX}}" PARENT_SCOPE)
elseif(NOT ${package}_${comp_name_to_use}_TYPE STREQUAL "HEADER")
	set(${LOCATION_RES} "${${package}_ROOT_DIR}/lib/${${package}_${comp_name_to_use}_BINARY_NAME${VAR_SUFFIX}}" PARENT_SCOPE)
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
#     :component: the name of the component.
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


##################################################################################
############### runtime resources dependencies management API ####################
##################################################################################

## auxiliary functions for direct runtime resources extraction for : source, binary and external components

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_External_Component_Direct_Runtime_Resources| replace:: ``get_External_Component_Direct_Runtime_Resources``
#  .. get_External_Component_Direct_Runtime_Resources:
#
#  get_External_Component_Direct_Runtime_Resources
#  -----------------------------------------------
#
#   .. command:: get_External_Component_Direct_Runtime_Resources(RES_RESOURCES package component mode)
#
#   Get list of path to all resources (executables, modules, files and folders) directly used by an external component at runtime.
#
#     :package: the name of the external package containing the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#     :insystempath: if FALSE the function returns the full path to resources in workspace otherwise it returns the relative path of the resource in its corresponding system install folder (used for system install only).
#
#     :RES_RESOURCES: the output variable that contains the list of path to runtime resources.
#
function(get_External_Component_Direct_Runtime_Resources RES_RESOURCES package component mode insystempath)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)
if(${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX})#if there are exported resources
  if(insystempath)
    resolve_External_Resources_Relative_Path(RELATIVE_RESOURCES_PATH "${${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX}}" ${mode})
    foreach(path IN LISTS RELATIVE_RESOURCES_PATH)
      if(IS_ABSOLUTE ${path})#path to a system folder are absolute
        list(APPEND result ${path})#the direct path to the dependency (absolute) : will be the case anytime for external packages
      else()
        list(APPEND result ${CMAKE_INSTALL_DIR}/${CMAKE_INSTALL_DATAROOTDIR}/runtime_resources/${path})#external project runtime resources have been put into specific share/pid_resource install folder
      endif()
    endforeach()
  else()
  	resolve_External_Resources_Path(COMPLETE_RESOURCES_PATH "${${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX}}" ${mode})
    list(APPEND result ${COMPLETE_RESOURCES_PATH})#the direct path to the dependency (absolute) : will be the case anytime for external packages
  endif()
endif()

set(${RES_RESOURCES} ${result} PARENT_SCOPE)
endfunction(get_External_Component_Direct_Runtime_Resources)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Bin_Component_Direct_Runtime_Resources| replace:: ``get_Bin_Component_Direct_Runtime_Resources``
#  .. _get_Bin_Component_Direct_Runtime_Resources:
#
#  get_Bin_Component_Direct_Runtime_Resources
#  ------------------------------------------
#
#   .. command:: get_Bin_Component_Direct_Runtime_Resources(RES_RESOURCES package component mode)
#
#   Get list of path to all resources (executables, modules, files and folders) directly used by a component (from another package than currenlty defined one) at runtime.
#   Note: this function can be used also with external components as native and external component share same description variables for runtime resources.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#     :insystempath: if FALSE the function returns the full path to resources in workspace otherwise it returns the relative path of the resource in its corresponding system install folder (used for system install only).
#
#     :RES_RESOURCES: the output variable that contains the list of path to runtime resources.
#
function(get_Bin_Component_Direct_Runtime_Resources RES_RESOURCES package component mode insystempath)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)
if(${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX})#if there are exported resources
	resolve_External_Resources_Path(COMPLETE_RESOURCES_PATH "${${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX}}" ${mode})
	foreach(path IN LISTS COMPLETE_RESOURCES_PATH)
		if(NOT IS_ABSOLUTE ${path}) #relative path => this a native package resource
      if(insystempath)
        list(APPEND result ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/runtime_resources/${path})#targetting the system install folder instead of workspace folder
      else()
         list(APPEND result ${${package}_ROOT_DIR}/share/resources/${path})#the path contained by the link
      endif()
    else() #absolute resource path coming from external or system dependencies
      list(APPEND result ${path})#the direct path to the dependency (absolute) : will be the case anytime for external packages
    endif()
	endforeach()
endif()

set(${RES_RESOURCES} ${result} PARENT_SCOPE)
endfunction(get_Bin_Component_Direct_Runtime_Resources)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Source_Component_Direct_Runtime_Resources| replace:: ``get_Source_Component_Direct_Runtime_Resources``
#  .. _get_Source_Component_Direct_Runtime_Resources:
#
#  get_Source_Component_Direct_Runtime_Resources
#  ---------------------------------------------
#
#   .. command:: get_Source_Component_Direct_Runtime_Resources(RES_RESOURCES component mode)
#
#   Get list of path to all runtime resources (executables, modules, files and folders) directly used by a component (from currenlty defined package) at runtime.
#
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :RES_RESOURCES: the output variable that contains the list of path to runtime resources.
#
function(get_Source_Component_Direct_Runtime_Resources RES_RESOURCES component mode)
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
endfunction(get_Source_Component_Direct_Runtime_Resources)

## functions for runtime resources extraction for : source, binary and external components

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_External_Component_Runtime_Resources| replace:: ``get_External_Component_Runtime_Resources``
#  .. _get_External_Component_Runtime_Resources:
#
#  get_External_Component_Runtime_Resources
#  -------------------------------------------------------
#
#   .. command:: get_External_Component_Runtime_Resources(RES_RESOURCES package component mode)
#
#   Get list of path to all resources (executables, modules, files and folders) directly used by an external component at runtime.
#
#     :package: the name of the external package containing the component.
#     :component: the name of the external component.
#     :mode: the build mode (Release or Debug) for the component.
#     :insystempath: if FALSE the function returns the full path to resources in workspace otherwise it returns the relative path of the resource in its corresponding system install folder (used for system install only).
#
#     :RES_RESOURCES: the output variable that contains the list of path to runtime resources.
#
function(get_External_Component_Runtime_Resources RES_RESOURCES package component mode insystempath)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)

#optimization (compute things only one time)
check_Resource_Temporary_Optimization_Variables(RESOURCES_VAR ${package} ${component} ${mode})
if(RESOURCES_VAR)
  set(${RES_RESOURCES} ${${RESOURCES_VAR}} PARENT_SCOPE)
  return()
endif()

get_External_Component_Direct_Runtime_Resources(LOCAL_RESOURCES ${package} ${component} ${mode} ${insystempath})
list(APPEND result ${LOCAL_RESOURCES})

#check for tuntime resources in external component internal dependencies
foreach(dep_component IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
  #recursion to get runtime resources
  rename_If_Alias(dep_comp_name ${package} ${dep_component})
  get_External_Component_Runtime_Resources(DEP_RESOURCES ${package} ${dep_comp_name} ${mode} ${insystempath})
  if(DEP_RESOURCES)
    list(APPEND result ${DEP_RESOURCES})
  endif()
endforeach()

#then check for runtime resources in external component dependencies
foreach(dep_package IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
  foreach(dep_component IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
    #recursion to get runtime resources
    rename_If_Alias(dep_comp_name ${dep_package} ${dep_component})
    get_External_Component_Runtime_Resources(DEP_RESOURCES ${dep_package} ${dep_comp_name} ${mode} ${insystempath})
    if(DEP_RESOURCES)
      list(APPEND result ${DEP_RESOURCES})
    endif()
  endforeach()
endforeach()

if(result)
  list(REMOVE_DUPLICATES result)
endif()
set(${RES_RESOURCES} ${result} PARENT_SCOPE)
set_Resources_Temporary_Optimization_Variables(${package} ${component} ${mode} "${result}")
endfunction(get_External_Component_Runtime_Resources)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Bin_Component_Runtime_Resources| replace:: ``get_Bin_Component_Runtime_Resources``
#  .. _get_Bin_Component_Runtime_Resources:
#
#  get_Bin_Component_Runtime_Resources
#  ------------------------------------------------
#
#   .. command:: get_Bin_Component_Runtime_Resources(RES_RESOURCES package component mode insystempath)
#
#   Get list of path to all resources (executables, modules, files and folders) directly or undirectly used by a component at runtime.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#     :insystempath: if FALSE the function returns the full path to resources in workspace otherwise it returns the relative path of the resource in its corresponding system install folder (used for system install only).
#
#     :RES_RESOURCES: the output variable that contains the list of path to runtime resources.
#
function(get_Bin_Component_Runtime_Resources RES_RESOURCES package component mode insystempath)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)
#optimization (compute things only one time)
check_Resource_Temporary_Optimization_Variables(RESOURCES_VAR ${package} ${component} ${mode})
if(RESOURCES_VAR)
  set(${RES_RESOURCES} ${${RESOURCES_VAR}} PARENT_SCOPE)
  return()
endif()

# 1) runtime resources defined locally in component
get_Bin_Component_Direct_Runtime_Resources(DIRECT_RESOURCES ${package} ${component} ${mode} ${insystempath})
list(APPEND result ${DIRECT_RESOURCES})

# 2) then check for runtime resources in external component dependencies
foreach(dep_package IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
  foreach(dep_component IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
    rename_If_Alias(dep_comp_name ${dep_package} ${dep_component})#by definition a resolved component is a native one
    #recursion to get runtime resources
    get_External_Component_Runtime_Resources(DEP_RESOURCES ${dep_package} ${dep_comp_name} ${mode} ${insystempath})
    if(DEP_RESOURCES)
      list(APPEND result ${DEP_RESOURCES})
    endif()
  endforeach()
endforeach()

# 3) adding internal components dependencies
foreach(int_dep IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
	#applications do not need to propagate their runtime resources (since everything will be resolved according to their own rpath and binary location
	#nevertheless they can allow the access to some of their file or directory in order to let other code modify or extent their runtime behavior (for instance by modifying configuration files)
  rename_If_Alias(dep_comp_name ${package} ${int_dep})#by definition a resolved component is a native one
  get_Bin_Component_Runtime_Resources(INT_DEP_RUNTIME_RESOURCES ${package} ${dep_comp_name} ${mode} ${insystempath})
	if(INT_DEP_RUNTIME_RESOURCES)
		list(APPEND result ${INT_DEP_RUNTIME_RESOURCES})
	endif()
	if(${package}_${dep_comp_name}_TYPE STREQUAL "MODULE")
    if(insystempath)
      list(APPEND result ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${${package}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
    else()
      list(APPEND result ${${package}_ROOT_DIR}/lib/${${package}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
    endif()
  elseif(${package}_${dep_comp_name}_TYPE STREQUAL "APP" OR ${package}_${dep_comp_name}_TYPE STREQUAL "EXAMPLE")
    if(insystempath)
      list(APPEND result ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${${package}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})
    else()
      list(APPEND result ${${package}_ROOT_DIR}/bin/${${package}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})#the application is a direct runtime dependency of the component
    endif()
	endif()
endforeach()

# 4) adding dependencies to runtime resources of component from other packages
foreach(dep_pack IN LISTS ${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep_comp IN LISTS ${package}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})
		#applications do not need to propagate their runtime resources (since everything will be resolved according to their own rpath and binary location
		#nevertheless they can allow the access to some of their file or directory in order to let other code modify or extent their runtime behavior (for instance by modifying configuration files)
    rename_If_Alias(dep_comp_name ${dep_pack} ${dep_comp})#by definition a resolved component is a native one
    get_Bin_Component_Runtime_Resources(INT_DEP_RUNTIME_RESOURCES ${dep_pack} ${dep_comp_name} ${mode} ${insystempath}) #resolve external runtime resources
		if(INT_DEP_RUNTIME_RESOURCES)
			list(APPEND result ${INT_DEP_RUNTIME_RESOURCES})
		endif()
		if(${dep_pack}_${dep_comp_name}_TYPE STREQUAL "MODULE")
      if(insystempath)
        list(APPEND result ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${${dep_pack}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
      else()
        list(APPEND result ${${dep_pack}_ROOT_DIR}/lib/${${dep_pack}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
      endif()
    elseif(${dep_pack}_${dep_comp_name}_TYPE STREQUAL "APP" OR  ${dep_pack}_${dep_comp_name}_TYPE STREQUAL "EXAMPLE")
      if(insystempath)
        list(APPEND result ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/${${dep_pack}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})
      else()
        list(APPEND result ${${dep_pack}_ROOT_DIR}/bin/${${dep_pack}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})#the application is a direct runtime dependency of the component
      endif()
    endif()
	endforeach()
endforeach()

if(result)
  list(REMOVE_DUPLICATES result)
endif()
set(${RES_RESOURCES} ${result} PARENT_SCOPE)
set_Resources_Temporary_Optimization_Variables(${package} ${component} ${mode} "${result}")
endfunction(get_Bin_Component_Runtime_Resources)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Source_Component_Runtime_Resources| replace:: ``get_Source_Component_Runtime_Resources``
#  .. _get_Source_Component_Runtime_Resources:
#
#  get_Source_Component_Runtime_Resources
#  --------------------------------------
#
#   .. command:: get_Source_Component_Runtime_Resources(RES_RESOURCES component mode)
#
#   Get list of path to all resources (executables, modules, files and folders) directly or undirectly used by a component (from currenlty defined package) at runtime.
#
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :RES_RESOURCES: the output variable that contains the list of path to runtime resources.
#
function(get_Source_Component_Runtime_Resources RES_RESOURCES component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)
#optimization (compute things only one time)
check_Source_Resource_Temporary_Optimization_Variables(RESOURCES_VAR ${component} ${mode})
if(RESOURCES_VAR)
  set(${RES_RESOURCES} ${${RESOURCES_VAR}} PARENT_SCOPE)
return()
endif()
get_Source_Component_Direct_Runtime_Resources(DIRECT_RESOURCES ${component} ${mode})
list(APPEND result ${DIRECT_RESOURCES})

#then check for runtime resources in explicit external component dependencies
foreach(dep_package IN LISTS ${PROJECT_NAME}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
  foreach(dep_component IN LISTS ${PROJECT_NAME}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
    #recursion to get runtime resources
    rename_If_Alias(dep_comp_name ${dep_package} ${dep_component})
    get_External_Component_Runtime_Resources(DEP_RESOURCES ${dep_package} ${dep_comp_name} ${mode} FALSE)
    list(APPEND result ${DEP_RESOURCES})
  endforeach()
endforeach()

foreach(dep_pack IN LISTS ${PROJECT_NAME}_${component}_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep_comp IN LISTS ${PROJECT_NAME}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})
		#applications do not need to propagate their runtime resources (since everything will be resolved according to their own rpath and binary location)
		#nevertheless they can allow the access to some of their file or directory in order to let other code modify or extent their runtime behavior (for instance by modifying configuration files)
    rename_If_Alias(dep_comp_name ${dep_pack} ${dep_comp})#by definition a resolved component is a native one
    get_Bin_Component_Runtime_Resources(DEP_RESOURCES ${dep_pack} ${dep_comp_name} ${mode} FALSE) #resolve external runtime resources
    list(APPEND result ${DEP_RESOURCES})
		if(${dep_pack}_${dep_comp_name}_TYPE STREQUAL "MODULE")
			list(APPEND result ${${dep_pack}_ROOT_DIR}/lib/${${dep_pack}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
		elseif(${dep_pack}_${dep_comp_name}_TYPE STREQUAL "APP" OR  ${dep_pack}_${dep_comp_name}_TYPE STREQUAL "EXAMPLE")
			list(APPEND result ${${dep_pack}_ROOT_DIR}/bin/${${dep_pack}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})#the application is a direct runtime dependency of the component
		endif()

	endforeach()
endforeach()

# 3) adding internal components dependencies
foreach(int_dep IN LISTS ${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
	#applications do not need to propagate their runtime resources (since everything will be resolved according to their own rpath and binary location
	#nevertheless they can allow the access to some of their file or directory in order to let other code modify or extent their runtime behavior (for instance by modifying configuration files)
  rename_If_Alias(dep_comp_name ${PROJECT_NAME} ${int_dep})#by definition a resolved component is a native one
  get_Source_Component_Runtime_Resources(DEP_RESOURCES ${dep_comp_name} ${mode})
  list(APPEND result ${DEP_RESOURCES})
	if(${PROJECT_NAME}_${dep_comp_name}_TYPE STREQUAL "MODULE")
		list(APPEND result ${CMAKE_BINARY_DIR}/src/${${PROJECT_NAME}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})#the module library is a direct runtime dependency of the component
	elseif(${PROJECT_NAME}_${dep_comp_name}_TYPE STREQUAL "APP" OR ${PROJECT_NAME}_${dep_comp_name}_TYPE STREQUAL "EXAMPLE")
		list(APPEND result ${CMAKE_BINARY_DIR}/apps/${${PROJECT_NAME}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})#the application is a direct runtime dependency of the component
	endif()
endforeach()

if(result)
  list(REMOVE_DUPLICATES result)
endif()
set(${RES_RESOURCES} ${result} PARENT_SCOPE)
set_Source_Resources_Temporary_Optimization_Variables(${component} ${mode} "${result}")
endfunction(get_Source_Component_Runtime_Resources)

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
#   Note: This function is necessary only to generate adequate symlinks for python modules.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#     :prefix_path: the prefix path to append to names of components targets found.
#     :suffix_ext: the suffix extension name to append to names of components targets found.
#
#     :RES_RESOURCES: the output variable that contains the list of internal runtime dependencies.
#
function(get_Bin_Component_Direct_Internal_Runtime_Dependencies RES_RESOURCES package component mode prefix_path suffix_ext)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(RES)
foreach(int_dep IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
  rename_If_Alias(int_name_to_use ${package} ${int_dep})#resolve alias
	is_Runtime_Component(IS_RUNTIME ${package} ${int_name_to_use})
	if(IS_RUNTIME)
		list(APPEND RES ${prefix_path}${int_name_to_use}${TARGET_SUFFIX}${suffix_ext})#need to use the real component name as target name, never its alias
	endif()
endforeach()
set(${RES_RESOURCES} ${RES} PARENT_SCOPE)
endfunction(get_Bin_Component_Direct_Internal_Runtime_Dependencies)

##################################################################################
##################### all runtime dependencies management API ####################
##################################################################################


## auxiliary functions for direct links extraction for : source, binary and external components

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_External_Component_Direct_Runtime_Links| replace:: ``get_External_Component_Direct_Runtime_Links``
#  .. _get_External_Component_Direct_Runtime_Links:
#
#  get_External_Component_Direct_Runtime_Links
#  -------------------------------------------
#
#   .. command:: get_External_Component_Direct_Runtime_Links(RES_LINKS package component mode)
#
#   Get list of all shared links provided by an external component at runtime.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :RES_LINKS: the output variable that contains the list of shared links used by component at runtime.
#
function(get_External_Component_Direct_Runtime_Links RES_LINKS package component mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  set(result)
  #directly adding shared links owned by the component
  if(${package}_${component}_SHARED_LINKS${VAR_SUFFIX})#if the component defines public shared links
    resolve_External_Libs_Path(RES_SHARED "${${package}_${component}_SHARED_LINKS${VAR_SUFFIX}}" ${mode})#resolving libraries path against external packages path
    foreach(lib IN LISTS RES_SHARED)
      is_Shared_Lib_With_Path(IS_SHARED ${lib})
      if(IS_SHARED)#only shared libs with absolute path need to be configured (the others are supposed to be retrieved automatically by the OS)
        list(APPEND result ${lib})
      endif()
    endforeach()
  endif()
  set(${RES_LINKS} ${result} PARENT_SCOPE)
endfunction(get_External_Component_Direct_Runtime_Links)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Bin_Component_Direct_Runtime_Links| replace:: ``get_Bin_Component_Direct_Runtime_Links``
#  .. _get_Bin_Component_Direct_Runtime_Links:
#
#  get_Bin_Component_Direct_Runtime_Links
#  --------------------------------------
#
#   .. command:: get_Bin_Component_Direct_Runtime_Links(RES_LINKS package component mode)
#
#   Get list of all shared links directly used by a component at runtime.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :RES_LINKS: the output variable that contains the list of shared links used by component at runtime.
#
function(get_Bin_Component_Direct_Runtime_Links RES_LINKS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)

#1) searching in public links
if(${package}_${component}_LINKS${VAR_SUFFIX})#if there are exported links
  resolve_External_Libs_Path(RES "${${package}_${component}_LINKS${VAR_SUFFIX}}" ${mode})#resolving libraries path against external packages path
	foreach(lib IN LISTS RES)
		is_Shared_Lib_With_Path(IS_SHARED ${lib})
		if(IS_SHARED)#only shared libs with absolute path need to be configured (the others are supposed to be retrieved automatically by the OS)
			list(APPEND result ${lib})
		endif()
	endforeach()
endif()
#Remark: no need to search in SYSTEM_STATIC LINKS since they are static by definition
# 2) searching private links
if(${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX})
  set(RES_PRIVATE)
	resolve_External_Libs_Path(RES_PRIVATE "${${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX}}" ${mode})#resolving libraries path against external packages path
	foreach(ext_lib IN LISTS RES_PRIVATE)
		is_Shared_Lib_With_Path(IS_SHARED ${ext_lib})
		if(IS_SHARED)#this is not a linker option or a system link option
			list(APPEND result ${ext_lib})
		endif()
	endforeach()
endif()

if(result)
  list(REMOVE_DUPLICATES result)
endif()
set(${RES_LINKS} ${result} PARENT_SCOPE)
endfunction(get_Bin_Component_Direct_Runtime_Links)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_External_Component_Runtime_Links| replace:: ``get_External_Component_Runtime_Links``
#  .. _get_External_Component_Runtime_Links:
#
#  get_External_Component_Runtime_Links
#  ------------------------------------
#
#   .. command:: get_External_Component_Runtime_Links(ALL_LOCAL_RUNTIME_LINKS ALL_USING_RUNTIME_LINKS package component mode)
#
#   Get list of all shared links used by an external component at runtime.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :ALL_LOCAL_RUNTIME_LINKS: the output variable that contains the list of all runtime links of the component to be used in local package.
#     :ALL_USING_RUNTIME_LINKS: the output variable that contains the list of all runtime links of the component to be used in using packages.
#
function(get_External_Component_Runtime_Links ALL_LOCAL_RUNTIME_LINKS ALL_USING_RUNTIME_LINKS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)
check_Runtime_Links_Temporary_Optimization_Variables(LOCAL_LINKS_VAR USING_LINKS_VAR ${package} ${component} ${mode})
if(LOCAL_LINKS_VAR AND USING_LINKS_VAR)
  set(${ALL_LOCAL_RUNTIME_LINKS} ${${LOCAL_LINKS_VAR}} PARENT_SCOPE)
  set(${ALL_USING_RUNTIME_LINKS} ${${USING_LINKS_VAR}} PARENT_SCOPE)
  return()
endif()
set(local_package_result)
set(using_package_result)

#directly adding shared links owned by the component
get_External_Component_Direct_Runtime_Links(LOCAL_LINKS ${package} ${component} ${mode})
list(APPEND using_package_result ${LOCAL_LINKS})

#then check for shared links in external component internal dependencies
foreach(dep_component IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
  #recursion to get runtime links
  rename_If_Alias(dep_comp_name ${package} ${dep_component})#by definition a resolved component is a native one
  get_External_Component_Runtime_Links(LOCAL_DEP_LINKS USING_DEP_LINKS ${package} ${dep_comp_name} ${mode})
  list(APPEND local_package_result ${LOCAL_DEP_LINKS})
  list(APPEND using_package_result ${USING_DEP_LINKS})
endforeach()

#then check for shared links in external component external dependencies
foreach(dep_package IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
  foreach(dep_component IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
    #recursion to get runtime links
    rename_If_Alias(dep_comp_name ${dep_package} ${dep_component})#by definition a resolved component is a native one
    get_External_Component_Runtime_Links(LOCAL_DEP_LINKS USING_DEP_LINKS ${dep_package} ${dep_comp_name} ${mode})
    list(APPEND local_package_result ${USING_DEP_LINKS})#as the component belongs to another package we always use its using links in local package
    list(APPEND using_package_result ${USING_DEP_LINKS})
  endforeach()
endforeach()

remove_Duplicates_From_List(local_package_result)
remove_Duplicates_From_List(using_package_result)
set(${ALL_LOCAL_RUNTIME_LINKS} ${local_package_result} PARENT_SCOPE)
set(${ALL_USING_RUNTIME_LINKS} ${using_package_result} PARENT_SCOPE)
set_Runtime_Links_Temporary_Optimization_Variables(${package} ${component} ${mode} local_package_result using_package_result)
endfunction(get_External_Component_Runtime_Links)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Bin_Component_Runtime_Links| replace:: ``get_Bin_Component_Runtime_Links``
#  .. _get_Bin_Component_Runtime_Links:
#
#  get_Bin_Component_Runtime_Links
#  -------------------------------
#
#   .. command:: get_Bin_Component_Runtime_Links(ALL_LOCAL_RUNTIME_LINKS ALL_USING_RUNTIME_LINKS package component mode)
#
#   Get list of all public runtime dependencies used by a component at runtime. Used to generate PID symlinks to resolve loading of shared libraries used by the component.
#
#     :package: the name of the package containing the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :ALL_LOCAL_RUNTIME_LINKS: the output variable that contains the list of all runtime links of the component to be used in local package.
#     :ALL_USING_RUNTIME_LINKS: the output variable that contains the list of all runtime links of the component to be used in using packages.
#
function(get_Bin_Component_Runtime_Links ALL_LOCAL_RUNTIME_LINKS ALL_USING_RUNTIME_LINKS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

#optimization
check_Runtime_Links_Temporary_Optimization_Variables(LOCAL_LINKS_VAR USING_LINKS_VAR ${package} ${component} ${mode})
if(LOCAL_LINKS_VAR AND USING_LINKS_VAR)
  set(${ALL_LOCAL_RUNTIME_LINKS} ${${LOCAL_LINKS_VAR}} PARENT_SCOPE)
  set(${ALL_USING_RUNTIME_LINKS} ${${USING_LINKS_VAR}} PARENT_SCOPE)
  return()
endif()
set(local_package_result)
set(using_package_result)

# 1) adding directly used external dependencies and system dependencies
get_Bin_Component_Direct_Runtime_Links(RES_LINKS ${package} ${component} ${mode})
list(APPEND local_package_result ${RES_LINKS})

# 2) adding runtime links from external components
foreach(dep_package IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
  foreach(dep_component IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
    rename_If_Alias(dep_comp_name ${dep_package} ${dep_component})#by definition a resolved component is a native one
    #shared links of direct dependency will be needed if native component depends on the external dependency
    get_External_Component_Runtime_Links(DEP_LOCAL_LINKS DEP_USING_LINKS ${dep_package} ${dep_comp_name} ${mode})
    list(APPEND local_package_result ${DEP_USING_LINKS})
  endforeach()
endforeach()

# 3) adding package components dependencies
foreach(dep_pack IN LISTS ${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep_comp IN LISTS ${package}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})

    rename_If_Alias(dep_comp_name ${dep_pack} ${dep_comp})#by definition a resolved component is a native one
    if(${dep_pack}_${dep_comp_name}_TYPE STREQUAL "HEADER"
      OR ${dep_pack}_${dep_comp_name}_TYPE STREQUAL "STATIC"
      OR ${dep_pack}_${dep_comp_name}_TYPE STREQUAL "SHARED")
			get_Bin_Component_Runtime_Links(LOCAL_DEP_LINKS USING_DEP_LINKS ${dep_pack} ${dep_comp_name} ${mode}) #need to resolve external symbols whether the component is exported or not (it may have unresolved symbols coming from shared libraries) + resolve external runtime resources
      list(APPEND local_package_result ${USING_DEP_LINKS})#as the component belongs to another package we always use using links
      if(${dep_pack}_${dep_comp}_TYPE STREQUAL "SHARED")#shared libraries need to be added
        list(APPEND local_package_result ${${dep_pack}_ROOT_DIR}/lib/${${dep_pack}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})#the shared library is a direct dependency of the component
      endif()
		endif()
	endforeach()
endforeach()

# 4) adding internal components dependencies
foreach(int_dep IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
  rename_If_Alias(dep_comp_name ${package} ${int_dep})#by definition a resolved component is a native one
  if(${package}_${dep_comp_name}_TYPE STREQUAL "HEADER"
    OR ${package}_${dep_comp_name}_TYPE STREQUAL "STATIC"
    OR ${package}_${dep_comp_name}_TYPE STREQUAL "SHARED")
		get_Bin_Component_Runtime_Links(LOCAL_DEP_LINKS USING_DEP_LINKS ${package} ${dep_comp_name} ${mode}) #need to resolve external symbols whether the component is exported or not (it may have unresolved symbols coming from shared libraries)
    list(APPEND local_package_result ${LOCAL_DEP_LINKS})
    list(APPEND using_package_result ${USING_DEP_LINKS})
    if(${package}_${dep_comp_name}_TYPE STREQUAL "SHARED")
      #shared libraries used internally to the current package must be registered to be accesible to using packages
      list(APPEND using_package_result ${${package}_ROOT_DIR}/lib/${${package}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})#the shared library is a direct dependency of the component
    endif()
	endif()
endforeach()

# build the final results
remove_Duplicates_From_List(local_package_result)
list(APPEND using_package_result ${local_package_result})#local result contains
remove_Duplicates_From_List(using_package_result)

set(${ALL_LOCAL_RUNTIME_LINKS} ${local_package_result} PARENT_SCOPE)
set(${ALL_USING_RUNTIME_LINKS} ${using_package_result} PARENT_SCOPE)
set_Runtime_Links_Temporary_Optimization_Variables(${package} ${component} ${mode} local_package_result using_package_result)
endfunction(get_Bin_Component_Runtime_Links)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Source_Component_Runtime_Links| replace:: ``get_Source_Component_Runtime_Links``
#  .. _get_Source_Component_Runtime_Links:
#
#  get_Source_Component_Runtime_Links
#  ----------------------------------
#
#   .. command:: get_Source_Component_Runtime_Links(ALL_RUNTIME_LINKS package component mode)
#
#   Get list of all links used by a component at runtime. Used to generate PID symlinks to resolve loading of shared libraries used by the component.
#
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :ALL_RUNTIME_LINKS: the output variable that contains the list of all runtime links used by the component.
#
function(get_Source_Component_Runtime_Links ALL_RUNTIME_LINKS component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)

#optimization
check_Runtime_Links_Temporary_Optimization_Variables(LOCAL_LINKS_VAR USING_LINKS_VAR ${PROJECT_NAME} ${component} ${mode})
if(LOCAL_LINKS_VAR)# a source component can only generate local links list
  set(${ALL_RUNTIME_LINKS} ${${LOCAL_LINKS_VAR}} PARENT_SCOPE)
  return()
endif()

# 1) adding directly used external dependencies (only those bound to external package are interesting, system dependencies do not need a specific treatment)
get_Bin_Component_Direct_Runtime_Links(RES_LINKS ${PROJECT_NAME} ${component} ${mode})
list(APPEND result ${RES_LINKS})

# 2) adding runtime links from external components
foreach(dep_package IN LISTS ${PROJECT_NAME}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
  foreach(dep_component IN LISTS ${PROJECT_NAME}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
    #shared links of direct dependency will be needed if native component depends on the external dependency
    rename_If_Alias(dep_comp_name ${dep_package} ${dep_component})#by definition a resolved component is a native one
    get_External_Component_Runtime_Links(DEP_LOCAL_LINKS DEP_USING_LINKS ${dep_package} ${dep_comp_name} ${mode})
    list(APPEND result ${DEP_USING_LINKS})
  endforeach()
endforeach()

# 3) adding package components dependencies
foreach(dep_pack IN LISTS ${PROJECT_NAME}_${component}_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep_comp IN LISTS ${PROJECT_NAME}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})
    rename_If_Alias(dep_comp_name ${dep_pack} ${dep_comp})#by definition a resolved component is a native one
    if(${dep_pack}_${dep_comp_name}_TYPE STREQUAL "HEADER"
      OR ${dep_pack}_${dep_comp_name}_TYPE STREQUAL "STATIC"
      OR ${dep_pack}_${dep_comp_name}_TYPE STREQUAL "SHARED")
			get_Bin_Component_Runtime_Links(LOCAL_DEP_LINKS USING_DEP_LINKS ${dep_pack} ${dep_comp_name} ${mode}) #need to resolve external symbols whether the component is exported or not (it may have unresolved symbols coming from shared libraries) + resolve external runtime resources
      list(APPEND result ${USING_DEP_LINKS})#depenedncy belongs to another package so always using links are used
      if(${dep_pack}_${dep_comp_name}_TYPE STREQUAL "SHARED")#shared libraries need to be added anytime
        list(APPEND result ${${dep_pack}_ROOT_DIR}/lib/${${dep_pack}_${dep_comp_name}_BINARY_NAME${VAR_SUFFIX}})#the shared library is a direct dependency of the component
      endif()
		endif()
	endforeach()
endforeach()

# 4) adding internal components dependencies
foreach(int_dep IN LISTS ${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
  rename_If_Alias(dep_comp_name ${PROJECT_NAME} ${int_dep})#by definition a resolved component is a native one
  if(${PROJECT_NAME}_${dep_comp_name}_TYPE STREQUAL "HEADER"
    OR ${PROJECT_NAME}_${dep_comp_name}_TYPE STREQUAL "STATIC"
    OR ${PROJECT_NAME}_${dep_comp_name}_TYPE STREQUAL "SHARED")
		get_Source_Component_Runtime_Links(DEP_LINKS ${dep_comp_name} ${mode}) #need to resolve external symbols whether the component is exported or not (it may have unresolved symbols coming from shared libraries)
    list(APPEND result ${DEP_LINKS})
	endif()# no need to link internal dependencies with symbolic links (they will be found automatically in current pakage install tree)
endforeach()

# adequately removing duplicates in the list
if(result)
  list(REMOVE_DUPLICATES result)
endif()
set(empty_result)
set(${ALL_RUNTIME_LINKS} ${result} PARENT_SCOPE)
set_Runtime_Links_Temporary_Optimization_Variables(${PROJECT_NAME} ${component} ${mode} result empty_result)
endfunction(get_Source_Component_Runtime_Links)

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
#     :mode: the build mode (Release or Debug) for the package.
#
function(resolve_Package_Runtime_Dependencies package mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(${package}_PREPARE_RUNTIME${VAR_SUFFIX})#this is a guard to limit recursion -> the runtime has already been prepared
	return()
endif()
if(${package}_DURING_PREPARE_RUNTIME${VAR_SUFFIX})
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : cyclic dependencies between packages found : Package ${package} is undirectly requiring itself !")
	return()
endif()
set(${package}_DURING_PREPARE_RUNTIME${VAR_SUFFIX} TRUE)

# 1) resolving runtime dependencies by recursion (resolving dependancy packages' components first)
foreach(dep IN LISTS ${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
  resolve_Package_Runtime_Dependencies(${dep} ${mode})
endforeach()
foreach(dep IN LISTS ${package}_DEPENDENCIES${VAR_SUFFIX})
  resolve_Package_Runtime_Dependencies(${dep} ${mode})
endforeach()
# 2) resolving runtime dependencies of the package's own components
get_Package_Type(${package} PACK_TYPE)
if(PACK_TYPE STREQUAL "EXTERNAL")
  if(mode STREQUAL "Debug")
    make_Empty_Folder(${${package}_ROOT_DIR}/.rpath)
  endif()
  foreach(component IN LISTS ${package}_COMPONENTS${VAR_SUFFIX})
  	resolve_External_Component_Runtime_Dependencies(${package} ${${package}_VERSION_STRING} ${component} ${mode})
  endforeach()
else()
  foreach(component IN LISTS ${package}_COMPONENTS)
  	resolve_Bin_Component_Runtime_Dependencies(${package} ${component} ${mode})
  endforeach()
endif()
set(${package}_DURING_PREPARE_RUNTIME${VAR_SUFFIX} FALSE)
set(${package}_PREPARE_RUNTIME${VAR_SUFFIX} TRUE)
endfunction(resolve_Package_Runtime_Dependencies)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_External_Component_Runtime_Dependencies| replace:: ``resolve_External_Component_Runtime_Dependencies``
#  .. _resolve_External_Component_Runtime_Dependencies:
#
#  resolve_External_Component_Runtime_Dependencies
#  -----------------------------------------------
#
#   .. command:: resolve_External_Component_Runtime_Dependencies(package component mode)
#
#   Resolve runtime dependencies for a component contained in another package than currently defined one (a binary component).
#   Resolution consists in creating adequate symlinks for shared libraries used by component.
#
#     :package: the name of the package that contains the component.
#     :version: the version of the package that contains the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
function(resolve_External_Component_Runtime_Dependencies package version component mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

  rename_If_Alias(real_comp_name ${package} ${component})
  is_Runtime_Component(COMP_IS_RUNTIME ${package} ${real_comp_name})
  if(NOT COMP_IS_RUNTIME)#no runtime elements so nothing to resolve
  	return()
  endif()
  check_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables(MANAGED ${package} ${real_comp_name} ${mode})
  if(MANAGED)#optimization
    return()
  endif()
  set(ALL_RUNTIME_DEPS)
  # 1) getting all shared links dependencies
  get_External_Component_Runtime_Links(RES_LOCAL_LINKS RES_USING_LINKS ${package} ${real_comp_name} ${mode})
  list(APPEND ALL_RUNTIME_DEPS ${RES_LOCAL_LINKS})#the binary package own runtime dependencies is resolved to need to consider only its local links dependencies
  #2) getting direct and undirect runtime resources dependencies
  get_External_Component_Runtime_Resources(DEP_RESOURCES ${package} ${real_comp_name} ${mode} FALSE)
  list(APPEND ALL_RUNTIME_DEPS ${DEP_RESOURCES})#the binary package own runtime dependencies is resolved to need to consider only its local links dependencies
  #3) generate symlinks
  create_External_Component_Symlinks(${package} ${real_comp_name} ${mode} "${ALL_RUNTIME_DEPS}")
  get_Platform_Variables(PYTHON python_version)
  if(python_version AND mode STREQUAL "Release")#python packages are only in release mode
    set(python_symlinks ${RES_USING_LINKS} ${DEP_RESOURCES})#from python package perspective, all links are output of itself (local libraries in external package must be symlinked)
    set(path_to_python_install ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/__python${python_version}__)
	  if(NOT EXISTS ${path_to_python_install})
	    file(MAKE_DIRECTORY ${path_to_python_install})
	  endif()
    foreach(package_path IN LISTS ${package}_${real_comp_name}_PYTHON_PACKAGES${VAR_SUFFIX})#component define one or more python package
      #correctly configure those python packages with symlinks
      configure_External_Python_Packages(${package} ${version} ${CURRENT_PLATFORM} ${python_version} FALSE ${package_path} "${python_symlinks}")
    endforeach()
  endif()
  set_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables(${package} ${real_comp_name} ${mode})
endfunction(resolve_External_Component_Runtime_Dependencies)

#.rst:
#
# .. ifmode:: internal
#
#  .. |configure_External_Python_Packages| replace:: ``configure_External_Python_Packages``
#  .. _configure_External_Python_Packages:
#
#  configure_External_Python_Packages
#  ----------------------------------
#
#   .. command:: configure_External_Python_Packages(package platform python_version package_path list_of_symlinks)
#
#   Generating symlinks to python packages defined by an external package.
#
#     :package: the name of the external package that contains python packages.
#     :version: version of the package.
#     :platform: the name of current platform.
#     :python_version: the python version currently used.
#     :change_rpath: if TRUE the rpath of python modules will be changed.
#     :package_path: the relative path to python package in external package install folder.
#     :list_of_symlinks: the list of symlinks to generate into python package.
#
function(configure_External_Python_Packages package version platform python_version change_rpath package_path list_of_symlinks)
  set(path_to_python_install ${WORKSPACE_DIR}/install/${platform}/__python${python_version}__)
  set(root_folder_in_install ${WORKSPACE_DIR}/install/${platform}/${package}/${version})

  set(create_pack FALSE)
  if(package_path MATCHES "^.+\\.py$")
    set(create_pack TRUE)
    set(relative_package_path ${package_path})
  elseif(EXISTS ${root_folder_in_install}/${package_path}
         AND IS_DIRECTORY ${root_folder_in_install}/${package_path})#the package is a folder with a init.py file inside
    #do not create the package
    set(relative_package_path ${package_path})
  elseif(package_path MATCHES ".+\\.(so|dylib|dll)$")# filename with extension => python bindings
    set(create_pack TRUE)
    set(relative_package_path "${package_path}")
  else()# filename without extension => python bindings, adding the adequate extension
    set(create_pack TRUE)
    create_Shared_Lib_Extension(RES_EXT ${platform} "")#get the dynamic library extension
    set(relative_package_path "${package_path}${RES_EXT}")
  endif()
  set(binaries_to_modify)
  if(create_pack)#no package defined, PID imposes to create one, no direct python module allowed
    get_filename_component(NAME_OF_PACK ${relative_package_path} NAME_WE)
    #clean and create package folder in workspace's python install dir
    #package has same name as the module (without extension)
    if(EXISTS ${path_to_python_install}/${NAME_OF_PACK})
      file(REMOVE_RECURSE ${path_to_python_install}/${NAME_OF_PACK})
    endif()
    file(MAKE_DIRECTORY ${path_to_python_install}/${NAME_OF_PACK})
    set(symlink_deps_folders ${path_to_python_install}/${NAME_OF_PACK})

    # create the package init script
    set(PYTHON_PACKAGE ${NAME_OF_PACK})
    configure_file(${WORKSPACE_DIR}/cmake/patterns/wrappers/__init__.py.in ${path_to_python_install}/${NAME_OF_PACK}/__init__.py @ONLY)
    #now create a symlink to the module in it
    get_filename_component(NAME_OF_LINK ${relative_package_path} NAME)
    create_Symlink(${root_folder_in_install}/${relative_package_path} ${path_to_python_install}/${NAME_OF_PACK}/${NAME_OF_LINK})#generate the symlink used
    if(relative_package_path MATCHES ".+\\.(so|dylib|dll)$")
      set(binaries_to_modify ${root_folder_in_install}/${relative_package_path})
    endif()
  else()#already a package simply, symlink it
    get_filename_component(NAME_OF_LINK ${relative_package_path} NAME)
    create_Symlink(${root_folder_in_install}/${relative_package_path} ${path_to_python_install}/${NAME_OF_LINK})#generate the symlink used
    #in this folder listing binaries I need to modify
    set(symlink_deps_folders ${root_folder_in_install}/${relative_package_path})#by default we always put dependency symlinks in the package root folder
    set(binaries_to_modify)
    file(GLOB_RECURSE ALL_FILES "${root_folder_in_install}/${relative_package_path}/*" )
    foreach(a_file IN LISTS ALL_FILES)
      if(a_file MATCHES ".+\\.(so|dylib|dll)$")
        list(APPEND binaries_to_modify ${a_file})
        get_filename_component(THE_DIR ${a_file} DIRECTORY)
        list(APPEND symlink_deps_folders ${THE_DIR})
      endif()
    endforeach()
    list(REMOVE_DUPLICATES symlink_deps_folders)
  endif()
  #now set the rpath of each shared object into the python package (i.e. python bindings)
  if(change_rpath)
    foreach(shared IN LISTS binaries_to_modify)
      set_PID_Compatible_Rpath(${shared})
    endforeach()
  endif()
  #need to create symlinks to shared objects used by module so that they can be resolved at runtime
  foreach(symlink IN LISTS list_of_symlinks)
    get_filename_component(LINK_NAME ${symlink} NAME)
    foreach(a_folder IN LISTS symlink_deps_folders)#if there are subpackages I also need to generate symlinks to dependencies in them
      create_Symlink(${symlink} ${a_folder}/${LINK_NAME})#generate the symlink used
    endforeach()
  endforeach()
endfunction(configure_External_Python_Packages)

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
#   Resolve runtime dependencies for a component contained in another package than currently defined one (a binary component).
#   Resolution consists in creating adequate symlinks for shared libraries used by component.
#
#     :package: the name of the package that contains the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
function(resolve_Bin_Component_Runtime_Dependencies package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

rename_If_Alias(real_comp_name ${package} ${component})#resolve alias (by definition in this function always a native component)
is_Runtime_Component(COMP_IS_RUNTIME ${package} ${real_comp_name})
if(NOT COMP_IS_RUNTIME AND NOT ${package}_${real_comp_name}_TYPE STREQUAL "PYTHON")
	return()
endif()

check_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables(MANAGED ${package} ${real_comp_name} ${mode})
if(MANAGED)#optimization
  return()
endif()

if(${package}_${real_comp_name}_TYPE STREQUAL "PYTHON")
  create_Python_Install_Symlinks(${package} ${real_comp_name} ${mode})
else()
  set(ALL_RUNTIME_DEPS)
  # 1) getting all shared links dependencies
  get_Bin_Component_Runtime_Links(LOCAL_LINKS USING_LINKS ${package} ${real_comp_name} ${mode})#suppose that findPackage has resolved everything
  list(APPEND ALL_RUNTIME_DEPS ${LOCAL_LINKS})#the binary package own runtime dependencies is resolved to need to consider only its local links dependencies
  #2) getting direct and undirect runtime resources dependencies
  get_Bin_Component_Runtime_Resources(RES_RESOURCES ${package} ${real_comp_name} ${mode} FALSE)
  list(APPEND ALL_RUNTIME_DEPS ${RES_RESOURCES})
  if(ALL_RUNTIME_DEPS)
    list(REMOVE_DUPLICATES ALL_RUNTIME_DEPS)
  endif()
  #3) generate symlinks
  create_Bin_Component_Symlinks(${package} ${real_comp_name} ${mode} "${ALL_RUNTIME_DEPS}")

  is_Usable_Python_Wrapper_Module(USABLE_WRAPPER ${package} ${real_comp_name})
  if(USABLE_WRAPPER)
  	# getting path to internal targets dependecies that produce a runtime code (not used for rpath but required for python modules)

  	#cannot use the generator expression due to generator expression not evaluated in install(CODE) -> CMake BUG
  	if(CURRENT_PLATFORM_OS STREQUAL "macos")
      set(suffix_ext .dylib)
    elseif(CURRENT_PLATFORM_OS STREQUAL "windows")
        set(suffix_ext .dll)
  	else()
  	    set(suffix_ext .so)
  	endif()
  	#we need to reference also internal libraries for creating adequate symlinks for python
  	set(prefix_path ${${package}_ROOT_DIR}/lib/lib)
  	get_Bin_Component_Direct_Internal_Runtime_Dependencies(RES_DEPS ${package} ${real_comp_name} ${mode} ${prefix_path} ${suffix_ext})
  	list(APPEND ALL_RUNTIME_DEPS ${RES_DEPS})
  	#finally we need to reference also the module binary itself
  	get_Binary_Location(LOCATION_RES ${package} ${real_comp_name} ${mode})
  	list(APPEND ALL_RUNTIME_DEPS ${LOCATION_RES})
    #create symlinks inside the python package (get access to all runtime objects)
  	create_Bin_Component_Python_Symlinks(${package} ${real_comp_name} ${mode} "${ALL_RUNTIME_DEPS}")
    #create symlink to the pyhton package inside the python install folder
    create_Python_Install_Symlinks(${package} ${real_comp_name} ${mode})
  endif()
endif()
set_Runtime_Dependencies_Resolution_Temporary_Optimization_Variables(${package} ${real_comp_name} ${mode})
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
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#     :resources: the list of path to resources that need to be symlinked.
#
function(create_Bin_Component_Symlinks package component mode resources)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
#creatings symbolic links
make_Empty_Folder(${${package}_ROOT_DIR}/.rpath/${package}_${component}${TARGET_SUFFIX})
foreach(resource IN LISTS resources)
	create_Runtime_Symlink("${resource}" "${${package}_ROOT_DIR}/.rpath" ${package}_${component}${TARGET_SUFFIX})
endforeach()
endfunction(create_Bin_Component_Symlinks)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_External_Component_Symlinks| replace:: ``create_External_Component_Symlinks``
#  .. _create_External_Component_Symlinks:
#
#  create_External_Component_Symlinks
#  ----------------------------------
#
#   .. command:: create_External_Component_Symlinks(package component mode resources)
#
#   Generating symlinks to a set of runtime resources used by a component contained in a package that is not the currenlty defined one.
#
#     :package: the name of the external package that contains the component.
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#     :resources: the list of path to resources that need to be symlinked.
#
function(create_External_Component_Symlinks package component mode resources)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  #creatings symbolic links
  foreach(resource IN LISTS resources)
  	create_Runtime_Symlink("${resource}" "${${package}_ROOT_DIR}/.rpath" "")#no rpath sobfolder for external packages
  endforeach()
endfunction(create_External_Component_Symlinks)

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
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#     :resources: the list of path to runtime resources that need to be symlinked.
#
function(create_Bin_Component_Python_Symlinks package component mode resources)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
make_Empty_Folder(${${package}_ROOT_DIR}/share/script/${component})
foreach(resource IN LISTS resources)
	create_Runtime_Symlink("${resource}" "${${package}_ROOT_DIR}/share/script" ${component})#installing Debug and Release modes links in the same script folder
endforeach()
endfunction(create_Bin_Component_Python_Symlinks)


#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Python_Install_Symlinks| replace:: ``create_Python_Install_Symlinks``
#  .. _create_Python_Install_Symlinks:
#
#  create_Python_Install_Symlinks
#  ------------------------------
#
#   .. command:: create_Python_Install_Symlinks(package component mode)
#
#   Generating symlinks to python packages defined by a component of a package.
#
#     :package: the name of the package that contains the component.
#     :component: the name of the python package.
#     :mode: the build mode (Release or Debug) for the component.
#
function(create_Python_Install_Symlinks package component mode)
  if(NOT CURRENT_PYTHON)
    return()#do nothing if python not configured
  endif()
  set(path_to_package ${${package}_ROOT_DIR})
  set(path_to_python_package ${path_to_package}/share/script/${component})#Note: name is unique for DEBUG or RELEASE versions
  set(path_to_python_install ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/__python${CURRENT_PYTHON}__)

  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  if(${package}_${component}_TYPE STREQUAL "MODULE")
    # this is a binary module for wrapping c++ code into python
    # we need to create the symlink to the installed library implementing the wrapper inside the python package itself
    set(path_to_module ${path_to_package}/lib/${${package}_${component}_BINARY_NAME${VAR_SUFFIX}})
    # create the symlink to the module library INSIDE the python package folder
    create_Symlink(${path_to_module} ${path_to_python_package}/${${package}_${component}_BINARY_NAME${VAR_SUFFIX}})#generate the symlink used
  endif()

  # now in python folder creating a symlink pointing to the python package folder (same for script AND wrappers)
  contains_Python_Package_Description(IS_PYTHON_PACK ${path_to_python_package})
  if(IS_PYTHON_PACK)#wrappers python packages or pure python packages are described the same way
    if(NOT EXISTS path_to_python_install)
      file(MAKE_DIRECTORY ${path_to_python_install})
    endif()
    create_Symlink(${path_to_python_package} ${path_to_python_install}/${component}${TARGET_SUFFIX})#generate the symlink used
  endif()

endfunction(create_Python_Install_Symlinks)

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
#     :mode: the build mode (Release or Debug) for the component.
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
#     :mode: the build mode (Release or Debug) for the component.
#     :resources_var: the variable containing the list of path to runtime resources that need to be symlinked.
#
function(create_Source_Component_Symlinks component mode resources_var)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
foreach(resource IN LISTS ${resources_var})
	install_Runtime_Symlink(${resource} "${${PROJECT_NAME}_DEPLOY_PATH}/.rpath" ${PROJECT_NAME}_${component}${TARGET_SUFFIX})
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
#   .. command:: resolve_Source_Component_Runtime_Dependencies(component mode)
#
#   Resolve runtime dependencies of a component in the currenlty defined package. Finally create symlinks to these runtime resources in the install tree.
#
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
function(resolve_Source_Component_Runtime_Dependencies component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

rename_If_Alias(real_comp_name ${PROJECT_NAME} ${component})

will_be_Built(COMP_WILL_BE_BUILT ${real_comp_name})
if(NOT COMP_WILL_BE_BUILT)#special case for executables that need rpath link to be specified (due to system shared libraries linking system)-> the linker must resolve all target links (even shared libs) transitively
	return()
endif()

is_Runtime_Component(COMP_IS_RUNTIME ${PROJECT_NAME} ${real_comp_name})
if(NOT COMP_IS_RUNTIME)
	return()
endif()

# 1) getting all public runtime dependencies
get_Source_Component_Runtime_Links(ALL_RUNTIME_DEPS ${real_comp_name} ${mode})
# 2) getting direct and undirect runtime resources dependencies
get_Bin_Component_Runtime_Resources(RES_RESOURCES ${PROJECT_NAME} ${real_comp_name} ${mode} FALSE)
list(APPEND ALL_RUNTIME_DEPS ${RES_RESOURCES})

if(ALL_RUNTIME_DEPS)
  list(REMOVE_DUPLICATES ALL_RUNTIME_DEPS)
endif()
if(WIN32)
  create_Source_Component_Symlinks_Build_Tree(${real_comp_name} ${mode} ALL_RUNTIME_DEPS)
endif()
create_Source_Component_Symlinks(${real_comp_name} ${mode} ALL_RUNTIME_DEPS)
is_Usable_Python_Wrapper_Module(USABLE_WRAPPER ${PROJECT_NAME} ${real_comp_name})
if(USABLE_WRAPPER)
	# getting path to internal targets dependecies that produce a runtime code (not used for rpath but required for python modules)

	#cannot use the generator expression due to generator expression not evaluated in install(CODE) -> CMake BUG
	if(CURRENT_PLATFORM_OS STREQUAL "macos")
	    set(suffix_ext .dylib)
  elseif(CURRENT_PLATFORM_OS STREQUAL "windows")
      set(suffix_ext .dll)
	else()
	    set(suffix_ext .so)
	endif()

	set(prefix_path ${${PROJECT_NAME}_INSTALL_PATH}/${${PROJECT_NAME}_INSTALL_LIB_PATH}/lib)
	get_Bin_Component_Direct_Internal_Runtime_Dependencies(RES_DEPS ${PROJECT_NAME} ${real_comp_name} ${CMAKE_BUILD_TYPE} ${prefix_path} ${suffix_ext})
	list(APPEND ALL_RUNTIME_DEPS ${RES_DEPS})
  #finally we need to reference also the installed module binary itself
  set(module_binary_name ${real_comp_name}${TARGET_SUFFIX}${suffix_ext})
  set(path_to_module ${${PROJECT_NAME}_INSTALL_PATH}/${${PROJECT_NAME}_INSTALL_LIB_PATH}/${module_binary_name})
  list(APPEND ALL_RUNTIME_DEPS ${path_to_module})

	create_Source_Component_Python_Symlinks(${real_comp_name} ${CMAKE_BUILD_TYPE} "${ALL_RUNTIME_DEPS}")
endif()
endfunction(resolve_Source_Component_Runtime_Dependencies)

##################################################################################
################### source package run time dependencies in build tree ###########
##################################################################################

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
#     :mode: the build mode (Release or Debug) for the component.
#     :var_resources: the parent scope variable containing the list of path to runtime resources that need to be symlinked.
#
function(create_Source_Component_Symlinks_Build_Tree component mode var_resources)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
make_Empty_Folder(${CMAKE_BINARY_DIR}/.rpath/${PROJECT_NAME}_${component}${TARGET_SUFFIX})

foreach(resource IN LISTS ${var_resources})
	create_Runtime_Symlink(${resource} ${CMAKE_BINARY_DIR}/.rpath ${PROJECT_NAME}_${component}${TARGET_SUFFIX})
endforeach()
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
#     :mode: the build mode (Release or Debug) for the component.
#
function(resolve_Source_Component_Runtime_Dependencies_Build_Tree component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

rename_If_Alias(real_comp_name ${PROJECT_NAME} ${component})

is_Runtime_Component(COMP_IS_RUNTIME ${PROJECT_NAME} ${real_comp_name})
if(NOT COMP_IS_RUNTIME)
	return()
endif()

# getting direct and undirect runtime resources for the component
get_Source_Component_Runtime_Resources(RES_RESOURCES ${real_comp_name} ${CMAKE_BUILD_TYPE})
if(RES_RESOURCES)
  list(REMOVE_DUPLICATES RES_RESOURCES)
  create_Source_Component_Symlinks_Build_Tree(${real_comp_name} ${CMAKE_BUILD_TYPE} RES_RESOURCES)
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
if(	${CMAKE_BUILD_TYPE} MATCHES Release
	AND EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${PROJECT_NAME}/${${PROJECT_NAME}_DEPLOY_PATH}
	AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${PROJECT_NAME}/${${PROJECT_NAME}_DEPLOY_PATH} #if package is already installed
)
	# calling a script that will do the job in its own context (to avoid problem when including cmake scripts that would redefine critic variables)
	add_custom_target(cleaning_install
							COMMAND ${CMAKE_COMMAND} -DWORKSPACE_DIR=${WORKSPACE_DIR}
						 -DPACKAGE_NAME=${PROJECT_NAME}
						 -DCURRENT_PLATFORM=${CURRENT_PLATFORM}
						 -DPACKAGE_INSTALL_VERSION=${${PROJECT_NAME}_DEPLOY_PATH}
						 -DPACKAGE_VERSION=${${PROJECT_NAME}_VERSION}
						 -DNEW_USE_FILE=${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake #this file does not exist at configruation time (only after generation phase)
						 -P ${WORKSPACE_DIR}/cmake/commands/Clear_PID_Package_Install.cmake
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
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#     :external_package: the name of external package to check.
#
#     :USE_PACKAGE: the output variable that is TRUE if the external package is used within component, FALSE otherwise.
#
function(locate_External_Package_Used_In_Component USE_PACKAGE package component mode external_package)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  # consists in searching for the <${external_package}> in flags used by the component
  set(${USE_PACKAGE} FALSE PARENT_SCOPE)
  set(all_flags "${${package}_${component}_INC_DIRS${VAR_SUFFIX}};${${package}_${component}_LINKS${VAR_SUFFIX}};${${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX}};${${package}_${component}_SYSTEM_STATIC_LINKS${VAR_SUFFIX}};${${package}_${component}_LIB_DIRS${VAR_SUFFIX}};${${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX}}")
  string(FIND "${all_flags}" "<${external_package}>" INDEX)#simply find the pattern specifying the path to installed package version folder
  if(INDEX GREATER -1)
    set(${USE_PACKAGE} TRUE PARENT_SCOPE)
  endif()

  # check in explicit description od external component dependencies
  if(${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})#simply check that the package is used in component
    list(FIND ${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} ${external_package} INDEX)
    if(NOT INDEX EQUAL -1)
      set(${USE_PACKAGE} TRUE PARENT_SCOPE)
      return()
    endif()
    #otherwise search in dependencies of component dependencies
    foreach(dep_ext_pack IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
      foreach(dep_ext_comp IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCY_${dep_ext_pack}${VAR_SUFFIX})
        #do recursion (possible since native and external packages share same structure for external dependencies)
        locate_External_Package_Used_In_Component(PACK_USED ${dep_ext_pack} ${dep_ext_comp} ${external_package})
        if(PACK_USED)
          set(${USE_PACKAGE} TRUE PARENT_SCOPE)
        endif()
      endforeach()
    endforeach()
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
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :external_package: the name of external package to check.
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
#     :component: the name of the component.
#     :mode: the build mode (Release or Debug) for the component.
#
#     :USED_NATIVE_PACKAGES: the output variable that contains the list of native dependencies directly or undirectly used by component.
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
#     :mode: the build mode (Release or Debug) for the component.
#
#     :NATIVE_DEPS: the output variable that contains the list of native dependencies directly or undirectly used by component.
#     :EXTERNAL_DEPS: the output variable that contains the list of external dependencies directly or undirectly used by component.
#
function(collect_Local_Exported_Dependencies NATIVE_DEPS EXTERNAL_DEPS package mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
  set(${NATIVE_DEPS} PARENT_SCOPE)
  set(${EXTERNAL_DEPS} PARENT_SCOPE)

  set(external_deps)
  set(native_deps)

  foreach(comp IN LISTS ${package}_COMPONENTS)# foreach component defined by the package
    will_be_Installed(RESULT ${comp})#Note: no need to resolve since component list only contains base names (even from Use file)
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
