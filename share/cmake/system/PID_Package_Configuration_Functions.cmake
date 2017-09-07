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

#################################################################################################
####################### new API => configure the package with dependencies  #####################
#################################################################################################

function (list_Closed_Source_Dependency_Packages)
include (${CMAKE_BINARY_DIR}/share/Dep${PROJECT_NAME}.cmake)
set(CLOSED_PACKS)
if(CURRENT_NATIVE_DEPENDENCIES)
	foreach(pack IN ITEMS ${CURRENT_NATIVE_DEPENDENCIES})
		package_License_Is_Closed_Source(CLOSED ${pack})
		if(CLOSED)
			list(APPEND CLOSED_PACKS ${pack})
		endif()
	endforeach()
	list(REMOVE_DUPLICATES CLOSED_PACKS)
endif()
set(CLOSED_SOURCE_DEPENDENCIES ${CLOSED_PACKS} CACHE INTERNAL "")
endfunction(list_Closed_Source_Dependency_Packages)

function(is_Closed_Source_Dependency_Package CLOSED package)
list(FIND CLOSED_SOURCE_DEPENDENCIES ${package} INDEX)
if(INDEX EQUAL -1)
	set(${CLOSED} FALSE PARENT_SCOPE)
else()#package found in closed source packs => it is closed source
	set(${CLOSED} TRUE PARENT_SCOPE)
endif()
endfunction(is_Closed_Source_Dependency_Package)

### list all public headers of a component
function(list_Public_Includes INCLUDES package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

set(RES "${${package}_ROOT_DIR}/include/${${package}_${component}_HEADER_DIR_NAME}")
#additionally provided include dirs (cflags -I<path>) (external/system exported include dirs)
if(${package}_${component}_INC_DIRS${mode_suffix})
	resolve_External_Includes_Path(RES_INCLUDES ${package} "${${package}_${component}_INC_DIRS${VAR_SUFFIX}}" ${mode})
	list(APPEND RES ${RES_INCLUDES})
endif()
set(${INCLUDES} ${RES} PARENT_SCOPE)
endfunction(list_Public_Includes)

### list all public links of a component
function(list_Public_Links LINKS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
#provided additionnal ld flags (exported external/system libraries and ldflags)
if(${package}_${component}_LINKS${VAR_SUFFIX})
	resolve_External_Libs_Path(RES_LINKS ${package} "${${package}_${component}_LINKS${VAR_SUFFIX}}" ${mode})
set(${LINKS} "${RES_LINKS}" PARENT_SCOPE)
endif()
endfunction(list_Public_Links)

### list all public definitions of a component
function(list_Public_Definitions DEFS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(${package}_${component}_DEFS${VAR_SUFFIX})
	set(${DEFS} ${${package}_${component}_DEFS${VAR_SUFFIX}} PARENT_SCOPE)
endif()
endfunction(list_Public_Definitions)

### list all public compile options of a component
function(list_Public_Options OPTS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(${package}_${component}_OPTS${VAR_SUFFIX})
	#checking that no compiler option is used directly to set the standard
	#remove the option and set the standard adequately instead
	set(FILTERED_OPTS)
	foreach(opt IN ITEMS ${${package}_${component}_OPTS${VAR_SUFFIX}})
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
endif()
endfunction(list_Public_Options)

### get the location of a given component resulting binary on the filesystem
function( get_Binary_Location LOCATION_RES package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

is_Executable_Component(IS_EXE ${package} ${component})
if(IS_EXE)
	set(${LOCATION_RES} "${${package}_ROOT_DIR}/bin/${${package}_${component}_BINARY_NAME${VAR_SUFFIX}}" PARENT_SCOPE)
elseif(NOT ${package}_${component}_TYPE STREQUAL "HEADER")
	set(${LOCATION_RES} "${${package}_ROOT_DIR}/lib/${${package}_${component}_BINARY_NAME${VAR_SUFFIX}}" PARENT_SCOPE)
endif()
endfunction(get_Binary_Location)

### list all the private links of a component (its symbols are not exported, but need to be known in order to manage the link of executables adequately)
function(list_Private_Links PRIVATE_LINKS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
#provided additionnal ld flags (exported external/system libraries and ldflags)
if(${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX})
	resolve_External_Libs_Path(RES_LINKS ${package} "${${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX}}" ${mode})
set(${PRIVATE_LINKS} "${RES_LINKS}" PARENT_SCOPE)
endif()
endfunction(list_Private_Links)

###
function(get_Language_Standards STD_C STD_CXX package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(${STD_C} ${${package}_${component}_C_STANDARD${VAR_SUFFIX}} PARENT_SCOPE)
set(${STD_CXX} ${${package}_${component}_CXX_STANDARD${VAR_SUFFIX}} PARENT_SCOPE)
endfunction(get_Language_Standards)

###
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

function(find_Dependent_Private_Shared_Libraries LIST_OF_UNDIRECT_DEPS package component is_direct mode)
set(undirect_list)
get_Mode_Variables(mode_binary_suffix mode_var_suffix ${mode})
# 0) no need to search for systems dependencies as they can be found automatically using OS shared libraries binding mechanism

# 1) searching public external dependencies
if(NOT is_direct) #otherwise external dependencies are direct dependencies so their LINKS (i.e. exported links) are already taken into account (not private)
	if(${package}_${component}_LINKS${mode_var_suffix})
		resolve_External_Libs_Path(RES_LINKS ${package} "${${package}_${component}_LINKS${mode_var_suffix}}" ${mode})#resolving libraries path against external packages path
		foreach(ext_dep IN ITEMS ${RES_LINKS})
			is_Shared_Lib_With_Path(IS_SHARED ${ext_dep})
			if(IS_SHARED)
				list(APPEND undirect_list ${ext_dep})
			endif()
		endforeach()
	endif()
endif()

# 1-bis) searching private external dependencies
if(${package}_${component}_PRIVATE_LINKS${mode_var_suffix})
	resolve_External_Libs_Path(RES_PRIVATE_LINKS ${package} "${${package}_${component}_PRIVATE_LINKS${mode_var_suffix}}" ${mode})#resolving libraries path against external packages path
	foreach(ext_dep IN ITEMS ${RES_PRIVATE_LINKS})
		is_Shared_Lib_With_Path(IS_SHARED ${ext_dep})
		if(IS_SHARED)
			list(APPEND undirect_list ${ext_dep})
		endif()
	endforeach()
endif()

# 2) searching in dependent packages
foreach(dep_package IN ITEMS ${${package}_${component}_DEPENDENCIES${mode_var_suffix}})
	foreach(dep_component IN ITEMS ${${package}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${mode_var_suffix}})
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
foreach(dep_component IN ITEMS ${${package}_${component}_INTERNAL_DEPENDENCIES${mode_var_suffix}})
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

function(get_Bin_Component_Direct_Runtime_Resources_Dependencies RES_RESOURCES package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)
if(${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX})#if there are exported resources
	resolve_External_Resources_Path(COMPLETE_RESOURCES_PATH ${package} "${${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX}}" ${mode})
	foreach(path IN ITEMS ${COMPLETE_RESOURCES_PATH})
		if(NOT IS_ABSOLUTE ${path}) #relative path => this a native package resource
			list(APPEND result ${${package}_ROOT_DIR}/share/resources/${path})#the path contained by the link
		else() #external or absolute resource path coming from external dependencies
			list(APPEND result ${path})#the direct path to the dependency (absolute or relative to the external package)
		endif()
	endforeach()
endif()
set(${RES_RESOURCES} ${result} PARENT_SCOPE)
endfunction(get_Bin_Component_Direct_Runtime_Resources_Dependencies)

###
function(get_Bin_Component_Runtime_Resources_Dependencies RES_RESOURCES package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)
get_Bin_Component_Direct_Runtime_Resources_Dependencies(DIRECT_RESOURCES ${package} ${component} ${mode})
list(APPEND result ${DIRECT_RESOURCES})

foreach(dep_pack IN ITEMS ${${package}_${component}_DEPENDENCIES${VAR_SUFFIX}})
	foreach(dep_comp IN ITEMS ${${package}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX}})
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
foreach(int_dep IN ITEMS ${${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX}})
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


###
function(get_Bin_Component_Direct_Runtime_Links_Dependencies RES_LINKS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)
if(${package}_${component}_LINKS${VAR_SUFFIX})#if there are exported links

        resolve_External_Libs_Path(RES ${package} "${${package}_${component}_LINKS${VAR_SUFFIX}}" ${mode})#resolving libraries path against external packages path
        if(RES)
		foreach(lib IN ITEMS ${RES})
                        is_Shared_Lib_With_Path(IS_SHARED ${lib})
			if(IS_SHARED)#only shared libs with absolute path need to be configured (the others are supposed to be retrieved automatically by the OS)
                                list(APPEND result ${lib})
			endif()
		endforeach()
	endif()
endif()

set(${RES_LINKS} ${result} PARENT_SCOPE)
endfunction(get_Bin_Component_Direct_Runtime_Links_Dependencies)

###
function(get_Bin_Component_Direct_Runtime_PrivateLinks_Dependencies RES_PRIVATE_LINKS package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)

if(${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX})#if there are private links
	resolve_External_Libs_Path(RES_PRIVATE ${package} "${${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX}}" ${mode})#resolving libraries path against external packages path
	if(RES_PRIVATE)
		foreach(lib IN ITEMS ${RES_PRIVATE})
			is_Shared_Lib_With_Path(IS_SHARED ${lib})
			if(IS_SHARED)
				list(APPEND result ${lib})
			endif()
		endforeach()
	endif()
endif()

set(${RES_PRIVATE_LINKS} ${result} PARENT_SCOPE)
endfunction(get_Bin_Component_Direct_Runtime_PrivateLinks_Dependencies)


### recursive function to find runtime dependencies
function(get_Bin_Component_Runtime_Dependencies ALL_RUNTIME_RESOURCES package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result "")

# 1) adding directly used external dependencies (only those bound to external package are interesting, system dependencies do not need a specific traetment)

get_Bin_Component_Direct_Runtime_Links_Dependencies(RES_LINKS ${package} ${component} ${mode})
list(APPEND result ${RES_LINKS})

# 2) adding package components dependencies
foreach(dep_pack IN ITEMS ${${package}_${component}_DEPENDENCIES${VAR_SUFFIX}})
	foreach(dep_comp IN ITEMS ${${package}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX}})
		if(${dep_pack}_${dep_comp}_TYPE STREQUAL "HEADER" OR ${dep_pack}_${dep_comp}_TYPE STREQUAL "STATIC")
			get_Bin_Component_Runtime_Dependencies(INT_DEP_RUNTIME_RESOURCES ${dep_pack} ${dep_comp} ${mode}) #need to resolve external symbols whether the component is exported or not (it may have unresolved symbols coming from shared libraries) + resolve external runtime resources
			if(INT_DEP_RUNTIME_RESOURCES)
				list(APPEND result ${INT_DEP_RUNTIME_RESOURCES})
			endif()
		elseif(${dep_pack}_${dep_comp}_TYPE STREQUAL "SHARED")
			list(APPEND result ${${dep_pack}_ROOT_DIR}/lib/${${dep_pack}_${dep_comp}_BINARY_NAME${VAR_SUFFIX}})#the shared library is a direct dependency of the component
			is_Bin_Component_Exporting_Other_Components(EXPORTING ${dep_pack} ${dep_comp} ${mode})
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
        foreach(int_dep IN ITEMS ${${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX}})
	if(${package}_${int_dep}_TYPE STREQUAL "HEADER" OR ${package}_${int_dep}_TYPE STREQUAL "STATIC")
		get_Bin_Component_Runtime_Dependencies(INT_DEP_RUNTIME_RESOURCES ${package} ${int_dep} ${mode}) #need to resolve external symbols whether the component is exported or not (it may have unresolved symbols coming from shared libraries)
		if(INT_DEP_RUNTIME_RESOURCES)
			list(APPEND result ${INT_DEP_RUNTIME_RESOURCES})
		endif()
	elseif(${package}_${int_dep}_TYPE STREQUAL "SHARED")
		# no need to link internal dependencies with symbolic links (they will be found automatically)
		is_Bin_Component_Exporting_Other_Components(EXPORTING ${package} ${int_dep} ${mode})
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

function(resolve_Source_Component_Linktime_Dependencies component mode THIRD_PARTY_LINKS)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

is_Executable_Component(COMP_IS_EXEC ${PROJECT_NAME} ${component})
will_be_Built(COMP_WILL_BE_BUILT ${component})

if(	NOT COMP_IS_EXEC
	OR NOT COMP_WILL_BE_BUILT)#special case for executables that need rpath link to be specified (due to system shared libraries linking system)-> the linker must resolve all target links (even shared libs) transitively
	return()
endif()

set(undirect_deps)
# 0) no need to search for system libraries as they are installed and found automatically by the OS binding mechanism, idem for external dependencies since they are always direct dependencies for the currenlty build component

# 1) searching each direct dependency in other packages
foreach(dep_package IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCIES${VAR_SUFFIX}})
	foreach(dep_component IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX}})
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
foreach(dep_component IN ITEMS ${${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX}})
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

### resolve runtime dependencies for packages
function(resolve_Package_Runtime_Dependencies package mode)
if(${package}_PREPARE_RUNTIME)#this is a guard to limit recursion -> the runtime has already been prepared
	return()
endif()

if(${package}_DURING_PREPARE_RUNTIME)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : cyclic dependencies between packages found : Package ${package} is undirectly requiring itself !")
	return()
endif()
set(${package}_DURING_PREPARE_RUNTIME TRUE)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

# 1) resolving runtime dependencies by recursion (resolving dependancy packages' components first)
if(${package}_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep IN ITEMS ${${package}_DEPENDENCIES${VAR_SUFFIX}})
		resolve_Package_Runtime_Dependencies(${dep} ${mode})
	endforeach()
endif()
# 2) resolving runtime dependencies of the package's own components
foreach(component IN ITEMS ${${package}_COMPONENTS})
	resolve_Bin_Component_Runtime_Dependencies(${package} ${component} ${mode})
endforeach()
set(${package}_DURING_PREPARE_RUNTIME FALSE)
set(${package}_PREPARE_RUNTIME TRUE)
endfunction(resolve_Package_Runtime_Dependencies)


### resolve runtime dependencies for components
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
endif()
endfunction(resolve_Bin_Component_Runtime_Dependencies)


### configuring components runtime paths (links to libraries)
function(create_Bin_Component_Symlinks bin_package bin_component mode resources)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
#creatings symbolic links
foreach(resource IN ITEMS ${resources})
	create_Rpath_Symlink("${resource}" "${${bin_package}_ROOT_DIR}" ${bin_component}${TARGET_SUFFIX})
endforeach()
endfunction(create_Bin_Component_Symlinks)

##################################################################################
################### source package run time dependencies in install tree #########
##################################################################################


### configuring source components (currently built) runtime paths (links to libraries, executable, modules, files, etc.)
function(create_Source_Component_Symlinks component mode targets)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
foreach(target IN ITEMS ${targets})
	install_Rpath_Symlink(${target} ${${PROJECT_NAME}_DEPLOY_PATH} ${component}${TARGET_SUFFIX})
endforeach()
endfunction(create_Source_Component_Symlinks)

###
function(resolve_Source_Component_Runtime_Dependencies component mode THIRD_PARTY_LIBS)
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
        if(THIRD_PARTY_LIBS)
		list(APPEND ALL_RUNTIME_DEPS ${THIRD_PARTY_LIBS})
        endif()
	create_Source_Component_Symlinks(${component} ${CMAKE_BUILD_TYPE} "${ALL_RUNTIME_DEPS}")
endif()
endfunction(resolve_Source_Component_Runtime_Dependencies)

##################################################################################
################### source package run time dependencies in build tree ###########
##################################################################################

###
function(get_Source_Component_Direct_Runtime_Resources_Dependencies RES_RESOURCES component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)
if(${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX})#if there are exported resources
	resolve_External_Resources_Path(COMPLETE_RESOURCES_PATH ${PROJECT_NAME} "${${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX}}" ${mode})
	foreach(path IN ITEMS ${COMPLETE_RESOURCES_PATH})
		if(NOT IS_ABSOLUTE ${path}) #relative path => this a native package resource
			list(APPEND result ${CMAKE_SOURCE_DIR}/share/resources/${path})#the path contained by the link
		else() #external or absolute resource path coming from external/system dependencies
			list(APPEND result ${path})#the direct path to the dependency (absolute initially or relative to the external package and resolved)
		endif()
	endforeach()
endif()

set(${RES_RESOURCES} ${result} PARENT_SCOPE)
endfunction(get_Source_Component_Direct_Runtime_Resources_Dependencies)

function(get_Source_Component_Runtime_Resources_Dependencies RES_RESOURCES component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(result)

get_Source_Component_Direct_Runtime_Resources_Dependencies(DIRECT_RESOURCES ${component} ${mode})
list(APPEND result ${DIRECT_RESOURCES})

foreach(dep_pack IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCIES${VAR_SUFFIX}})
	foreach(dep_comp IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX}})
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
if(${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
	foreach(int_dep IN ITEMS ${${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX}})
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
endif()
set(${RES_RESOURCES} ${result} PARENT_SCOPE)
endfunction(get_Source_Component_Runtime_Resources_Dependencies)


### configuring source components (currntly built) runtime paths (links to libraries, executable, modules, files, etc.)
function(create_Source_Component_Symlinks_Build_Tree component mode resources)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(NOT "${resources}" STREQUAL "")
	foreach(resource IN ITEMS ${resources})
		create_Rpath_Symlink(${resource} ${CMAKE_BINARY_DIR} ${component}${TARGET_SUFFIX})
	endforeach()
endif()
endfunction(create_Source_Component_Symlinks_Build_Tree)

###
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
						 -P ${WORKSPACE_DIR}/share/cmake/system/Clear_PID_Package_Install.cmake
						 COMMENT "[PID] INFO : Cleaning install tree ..."
						 VERBATIM
	)
	add_dependencies(build cleaning_install) #removing built files in install tree that have been deleted with new configuration

endif()
endfunction(clean_Install_Dir)
