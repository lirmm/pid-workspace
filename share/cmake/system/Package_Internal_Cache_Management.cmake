#############################################################################################
############### API functions for managing user options cache variables #####################
#############################################################################################
macro(declare_Mode_Cache_Options)

include(CMakeDependentOption)
option(BUILD_EXAMPLES "Package builds examples" OFF)
option(BUILD_API_DOC "Package generates the HTML API documentation" ON)
CMAKE_DEPENDENT_OPTION(BUILD_LATEX_API_DOC "Package generates the LATEX api documentation" OFF
		         "BUILD_API_DOC" OFF)
option(BUILD_AND_RUN_TESTS "Package uses tests" OFF)
option(GENERATE_INSTALLER "Package generates an OS installer for UNIX system" OFF)
option(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD "Enabling the automatic download of not found packages marked as required" ON)
option(ENABLE_PARALLEL_BUILD "Package is built with optimum number of jobs with respect to system properties" ON)

endmacro(declare_Mode_Cache_Options)

macro(manage_Parrallel_Build_Option)

### parallel builds management
if(ENABLE_PARALLEL_BUILD)
	include(ProcessorCount)
	ProcessorCount(NUMBER_OF_JOBS)
	math(EXPR NUMBER_OF_JOBS ${NUMBER_OF_JOBS}+1)
	if(${NUMBER_OF_JOBS} GREATER 1)
		set(PARALLEL_JOBS_FLAG "-j${NUMBER_OF_JOBS}" CACHE INTERNAL "")
	endif()
else()
	set(PARALLEL_JOBS_FLAG CACHE INTERNAL "")
endif()

endmacro(manage_Parrallel_Build_Option)


function(reset_Mode_Cache_Options)
#unset all global options
set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_API_DOC OFF CACHE BOOL "" FORCE)
set(BUILD_LATEX_API_DOC OFF CACHE BOOL "" FORCE)
set(BUILD_AND_RUN_TESTS OFF CACHE BOOL "" FORCE)
set(GENERATE_INSTALLER OFF CACHE BOOL "" FORCE)
set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD OFF CACHE BOOL "" FORCE)
#include the cmake script that sets the options coming from the global build configuration
include(${CMAKE_BINARY_DIR}/../share/cacheConfig.cmake)
endfunction(reset_Mode_Cache_Options)


############################################################################
############### API functions for setting global package info ##############
############################################################################

### printing variables for components in the package ################
macro(print_Component component)
	message("COMPONENT : ${component}${INSTALL_NAME_SUFFIX}")
	message("INTERFACE : ")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_INCLUDE_DIRECTORIES)
		message("includes of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_COMPILE_DEFINITIONS)
		message("defs of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} LINK_INTERFACE_LIBRARIES)
		message("libraries of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")		
		
	message("IMPLEMENTATION :")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INCLUDE_DIRECTORIES)
		message("includes of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} COMPILE_DEFINITIONS)
		message("defs of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} LINK_LIBRARIES)
		message("libraries of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
endmacro(print_Component)

macro(print_Component_Variables)
	message("components of package ${PROJECT_NAME} are :" ${${PROJECT_NAME}_COMPONENTS})
	message("libraries : " ${${PROJECT_NAME}_COMPONENTS_LIBS})
	message("applications : " ${${PROJECT_NAME}_COMPONENTS_APPS})

	foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
		print_Component(${component})	
	endforeach()
endmacro(print_Component_Variables)

function(init_Package_Info_Cache_Variables author institution mail description year license address)
set(res_string)	
foreach(string_el IN ITEMS ${author})
	set(res_string "${res_string}_${string_el}")
endforeach()
set(${PROJECT_NAME}_MAIN_AUTHOR "${res_string}" CACHE INTERNAL "")

set(res_string "")
foreach(string_el IN ITEMS ${institution})
	set(res_string "${res_string}_${string_el}")
endforeach()
set(${PROJECT_NAME}_MAIN_INSTITUTION "${res_string}" CACHE INTERNAL "")
set(${PROJECT_NAME}_CONTACT_MAIL ${mail} CACHE INTERNAL "")

set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_MAIN_AUTHOR}(${${PROJECT_NAME}_MAIN_INSTITUTION})" CACHE INTERNAL "")
set(${PROJECT_NAME}_DESCRIPTION "${description}" CACHE INTERNAL "")
set(${PROJECT_NAME}_YEARS ${year} CACHE INTERNAL "")
set(${PROJECT_NAME}_LICENSE ${license} CACHE INTERNAL "")
if(${CMAKE_BUILD_TYPE} MATCHES Release)
set(${PROJECT_NAME}_ADDRESS ${address} CACHE INTERNAL "")
set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")#categories are reset
endif()
reset_References_Info()
reset_Version_Cache_Variables()
endfunction(init_Package_Info_Cache_Variables)

### setting cache variable for versionning
function(set_Version_Cache_Variables major minor patch)
	set (${PROJECT_NAME}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH} CACHE INTERNAL "")
endfunction(set_Version_Cache_Variables)


function(reset_Version_Cache_Variables)
#resetting general info about the package : only list are reset
set (${PROJECT_NAME}_VERSION_MAJOR CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION_MINOR CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION_PATCH CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION CACHE INTERNAL "" )
endfunction(reset_Version_Cache_Variables)

###
function(add_Author author institution)
	set(res_string_author)	
	foreach(string_el IN ITEMS ${author})
		set(res_string_author "${res_string_author}_${string_el}")
	endforeach()
	set(res_string_instit)
	foreach(string_el IN ITEMS ${institution})
		set(res_string_instit "${res_string_instit}_${string_el}")
	endforeach()
	set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS};${res_string_author}(${res_string_instit})" CACHE INTERNAL "")
endfunction(add_Author)


function(reset_References_Info)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")
	# references to package binaries version available must be reset
	foreach(ref_version IN ITEMS ${${PROJECT_NAME}_REFERENCES})
		foreach(ref_system IN ITEMS ${${PROJECT_NAME}_REFERENCE_${ref_version}})
			set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_system} CACHE INTERNAL "")
			set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_system}_DEBUG CACHE INTERNAL "")
		endforeach()
		set(${PROJECT_NAME}_REFERENCE_${ref_version} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_REFERENCES CACHE INTERNAL "")
	
endif()
endfunction(reset_References_Info)


###
function(add_Reference version system url url-dbg)
	set(${PROJECT_NAME}_REFERENCES ${${PROJECT_NAME}_REFERENCES} ${version} CACHE INTERNAL "")
	set(${PROJECT_NAME}_REFERENCE_${version} ${${PROJECT_NAME}_REFERENCE_${version}} ${system} CACHE INTERNAL "")
	set(${PROJECT_NAME}_REFERENCE_${version}_${system} ${url} CACHE INTERNAL "")
	set(${PROJECT_NAME}_REFERENCE_${version}_${system}_DEBUG ${url-dbg} CACHE INTERNAL "")
endfunction(add_Reference)

###
function(shadow_Repository_Address url)
	set(${PROJECT_NAME}_ADDRESS ${url} CACHE INTERNAL "")
endfunction(shadow_Repository_Address)


function(reset_References_Info)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")
	# references to package binaries version available must be reset
	foreach(ref_version IN ITEMS ${${PROJECT_NAME}_REFERENCES})
		foreach(ref_system IN ITEMS ${${PROJECT_NAME}_REFERENCE_${ref_version}})
			set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_system} CACHE INTERNAL "")
			set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_system}_DEBUG CACHE INTERNAL "")
		endforeach()
		set(${PROJECT_NAME}_REFERENCE_${ref_version} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_REFERENCES CACHE INTERNAL "")
	
endif()
endfunction(reset_References_Info)

###
function(add_Category category_spec)
	set(${PROJECT_NAME}_CATEGORIES ${${PROJECT_NAME}_CATEGORIES} ${category_spec} CACHE INTERNAL "")
endfunction(add_Category)

#############################################################################################
############### API functions for setting components related cache variables ################
#############################################################################################

### configure variables exported by component that will be used to generate the package cmake use file
function (configure_Install_Variables component export include_dirs dep_defs exported_defs static_links shared_links runtime_resources)
# configuring the export
if(export) # if dependancy library is exported then we need to register its dep_defs and include dirs in addition to component interface defs
	if(	NOT dep_defs STREQUAL "" 
		OR NOT exported_defs  STREQUAL "")	
		set(	${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}} 
			${exported_defs} ${dep_defs}
			CACHE INTERNAL "")
	endif()
	if(NOT include_dirs STREQUAL "")
		set(	${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} 
			${${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX}} 
			${include_dirs}
			CACHE INTERNAL "")
	endif()
	# links are exported since we will need to resolve symbols in the third party components that will the use the component 	
	if(NOT shared_links STREQUAL "")
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}			
			${shared_links}			
			CACHE INTERNAL "")
	endif()
	if(NOT static_links STREQUAL "")
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}			
			${static_links}			
			CACHE INTERNAL "")
	endif()

else() # otherwise no need to register them since no more useful
	if(NOT exported_defs STREQUAL "") 
		#just add the exported defs of the component not those of the dependency
		set(	${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}} 
			${exported_defs}
			CACHE INTERNAL "")
	endif()
	if(NOT static_links STREQUAL "") #static links are exported if component is not a shared lib
		if (	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER" 
			OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "STATIC"
		)
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}			
			${static_links}			
			CACHE INTERNAL "")
		endif()
	endif()
	if(NOT shared_links STREQUAL "")#shared links are privates (not exported) -> these links are used to process executables linking
		set(	${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX}}			
			${shared_links}
			CACHE INTERNAL "")
	endif()
endif()
if(NOT runtime_resources STREQUAL "")
	set(	${PROJECT_NAME}_${component}_RUNTIME_RESOURCES
		${${PROJECT_NAME}_${component}_RUNTIME_RESOURCES}
		${runtime_resources} 
		CACHE INTERNAL "")
endif()
endfunction(configure_Install_Variables)


### reset components related cached variables 
function(reset_Component_Cached_Variables component)
# resetting package dependencies
foreach(a_dep_pack IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}})
	foreach(a_dep_comp IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCY_${a_dep_pack}_COMPONENTS${USE_MODE_SUFFIX}})
		set(${PROJECT_NAME}_${component}_EXPORT_${a_dep_pack}_${a_dep_comp}${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_${component}_DEPENDENCY_${a_dep_pack}_COMPONENTS${USE_MODE_SUFFIX}  CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}  CACHE INTERNAL "")

# resetting internal dependencies
foreach(a_internal_dep_comp IN ITEMS ${${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}})
	set(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${a_internal_dep_comp}${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")

#resetting all other variables
set(${PROJECT_NAME}_${component}_HEADER_DIR_NAME CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_HEADERS CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_BINARY_NAME${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_SOURCE_CODE CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_SOURCE_DIR CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${USE_MODE_SUFFIX} CACHE INTERNAL "")
endfunction(reset_Component_Cached_Variables)

function(init_Component_Cached_Variables_For_Export component exported_defs exported_links runtime_resources)
set(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} "${exported_defs}" CACHE INTERNAL "") #exported defs
set(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} "${exported_links}" CACHE INTERNAL "") #exported links
set(${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} "" CACHE INTERNAL "") #exported include directories (not useful to set it there since they will be exported "manually")
set(${PROJECT_NAME}_${component}_RUNTIME_RESOURCES${USE_MODE_SUFFIX} "${runtime_resources}" CACHE INTERNAL "")#runtime resources are exported by default
endfunction(init_Component_Cached_Variables_For_Export)

### resetting all internal cached variables that would cause some troubles
function(reset_All_Component_Cached_Variables)

# package dependencies declaration must be reinitialized otherwise some problem (uncoherent dependancy versions) would appear
foreach(dep_package IN ITEMS ${${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX}})
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} CACHE INTERNAL "")	
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_${${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")

# external package dependencies declaration must be reinitialized 
foreach(dep_package IN ITEMS ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}})
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} CACHE INTERNAL "")	
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")


# component declaration must be reinitialized otherwise some problem (redundancy of declarations) would appear
foreach(a_component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	reset_Component_Cached_Variables(${a_component})
endforeach()
reset_Declared()
set(${PROJECT_NAME}_COMPONENTS CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_LIBS CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_APPS CACHE INTERNAL "")

#unsetting all root variables usefull to the find/configuration mechanism
foreach(a_used_package IN ITEMS ${${PROJECT_NAME}_ALL_USED_PACKAGES})
	set(${a_used_package}_FOUND CACHE INTERNAL "")
	set(${a_used_package}_ROOT_DIR CACHE INTERNAL "")
	set(${a_used_package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "")
	set(${a_used_package}_REQUIRED_VERSION_EXACT CACHE INTERNAL "")
endforeach()
foreach(a_used_package IN ITEMS ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES})
	set(${a_used_package}_FOUND CACHE INTERNAL "")
	set(${a_used_package}_ROOT_DIR CACHE INTERNAL "")
	set(${a_used_package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "")
	set(${a_used_package}_REQUIRED_VERSION_EXACT CACHE INTERNAL "")
endforeach()

set(${PROJECT_NAME}_ALL_USED_PACKAGES CACHE INTERNAL "")
set(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES CACHE INTERNAL "")
reset_To_Install_Packages()
reset_To_Install_External_Packages()
endfunction(reset_All_Component_Cached_Variables)


###
function(mark_As_Declared component)
set(${PROJECT_NAME}_DECLARED_COMPS ${${PROJECT_NAME}_DECLARED_COMPS} ${component} CACHE INTERNAL "")
endfunction(mark_As_Declared)

###
function(is_Declared component RES)
list(FIND ${PROJECT_NAME}_DECLARED_COMPS ${component} INDEX)
if(INDEX EQUAL -1)
	set(${RES} FALSE PARENT_SCOPE)
else()
	set(${RES} TRUE PARENT_SCOPE)
endif()

endfunction(is_Declared)

###
function(reset_Declared)
set(${PROJECT_NAME}_DECLARED_COMPS CACHE INTERNAL "")
endfunction(reset_Declared)


### to know if the component is an application
function(is_Executable_Component ret_var package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	)
	set(${ret_var} TRUE PARENT_SCOPE)
else()
	set(${ret_var} FALSE PARENT_SCOPE)
endif()
endfunction(is_Executable_Component)

### to know if component will be built
function (is_Built_Component ret_var  package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	OR ${package}_${component}_TYPE STREQUAL "STATIC"
	OR ${package}_${component}_TYPE STREQUAL "SHARED"
	OR ${package}_${component}_TYPE STREQUAL "MODULE"
)
	set(${ret_var} TRUE PARENT_SCOPE)
else()
	set(${ret_var} FALSE PARENT_SCOPE)
endif()
endfunction(is_Built_Component)

### 
function(will_be_Built result component)
if( (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST" AND NOT BUILD_AND_RUN_TESTS)
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE" AND NOT BUILD_EXAMPLES))
	set(${result} FALSE PARENT_SCOPE)
else()
	set(${result} TRUE PARENT_SCOPE)
endif()
endfunction(will_be_Built)

### 
function(will_be_Installed result component)
if( (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE" AND NOT BUILD_EXAMPLES))
	set(${result} FALSE PARENT_SCOPE)
else()
	set(${result} TRUE PARENT_SCOPE)
endif()
endfunction(will_be_Installed)

### registering the binary name of a component
function(register_Component_Binary c_name)
	get_target_property(BIN_LOC ${c_name}${INSTALL_NAME_SUFFIX} LOCATION)
	get_filename_component(BIN_NAME ${BIN_LOC} NAME)
	set(${PROJECT_NAME}_${c_name}_BINARY_NAME${USE_MODE_SUFFIX} ${BIN_NAME} CACHE INTERNAL "")
endfunction(register_Component_Binary)


#resolving dependencies
function(is_Bin_Component_Exporting_Other_Components RESULT package component mode)
set(${RESULT} FALSE PARENT_SCOPE)
if(mode MATCHES Release)
	set(mode_var_suffix "")
elseif(mode MATCHES Debug)
	set(mode_var_suffix "_DEBUG")
else()
	message(FATAL_ERROR "Bug : unknown mode ${mode}")
	return()
endif()
#scanning external dependencies
if(${package}_${component}_LINKS${mode_var_suffix}) #only exported links here
	set(${RESULT} TRUE PARENT_SCOPE)
	return()
endif()

# scanning internal dependencies
if(${package}_${component}_INTERNAL_DEPENDENCIES${mode_var_suffix})
	foreach(int_dep IN ITEMS ${package}_${component}_INTERNAL_DEPENDENCIES${mode_var_suffix})
		if(${package}_${component}_INTERNAL_EXPORT_${int_dep}${mode_var_suffix})
			set(${RESULT} TRUE PARENT_SCOPE)
			return()
		endif()
	endforeach()		
endif()

# scanning package dependencies
foreach(dep_pack IN ITEMS ${package}_${component}_DEPENDENCIES${mode_var_suffix})
	foreach(ext_dep IN ITEMS ${package}_${component}_DEPENDENCY_${dep_pack}_COMPONENTS${mode_var_suffix})
		if(${package}_${component}_EXPORT_${dep_pack}_${ext_dep}${mode_var_suffix})
			set(${RESULT} TRUE PARENT_SCOPE)
			return()
		endif()
	endforeach()
endforeach()
endfunction(is_Bin_Component_Exporting_Other_Components)


##############################################################################################################
############### API functions for managing cache variables bound to package dependencies #####################
##############################################################################################################

###
function(add_To_Install_Package_Specification package version version_exact)
list(FIND ${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} ${package} INDEX)
if(INDEX EQUAL -1)#not found
	set(${PROJECT_NAME}_TOINSTALL_PACKAGES ${${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX}} ${package} CACHE INTERNAL "")
	if(version AND NOT version STREQUAL "")
		set(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
		endif()
	endif()
else()#package already required as "to install"
	list(FIND ${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX} ${version} INDEX)
	if(INDEX EQUAL -1)#version not already required
		set(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
		endif()
	elseif(version_exact) #if this version was previously not exact it becomes exact if exact is required
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")		
	endif()
endif()
endfunction(add_To_Install_Package_Specification)

###
function(reset_To_Install_Packages)
foreach(pack IN ITEMS ${${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX}})
	foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_${pack}_VERSIONS${USE_MODE_SUFFIX}})
		set(${PROJECT_NAME}_TOINSTALL_${pack}_${version}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_TOINSTALL_${pack}_VERSIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} CACHE INTERNAL "")
endfunction(reset_To_Install_Packages)

###
function(need_Install_Packages NEED)
if(${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX})
	set(${NEED} TRUE PARENT_SCOPE)
else()
	set(${NEED} FALSE PARENT_SCOPE)
endif()
endfunction(need_Install_Packages)


###
function(add_To_Install_External_Package_Specification package version exact)
list(FIND ${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX} ${package} INDEX)
if(INDEX EQUAL -1)#not found
	set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX}} ${package} CACHE INTERNAL "")
	if(version AND NOT version STREQUAL "")
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
		endif()
	endif()
else()#package already required as "to install"
	list(FIND ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} ${version} INDEX)
	if(INDEX EQUAL -1)#version not already required
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
		endif()
	elseif(version_exact) #if this version was previously not exact it becomes exact if exact is required
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")		
	endif()
endif()
endfunction(add_To_Install_External_Package_Specification)

###
function(reset_To_Install_External_Packages)
foreach(pack IN ITEMS ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX}})
	foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_VERSIONS${USE_MODE_SUFFIX}})
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_${version}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_VERSIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX} CACHE INTERNAL "")
endfunction(reset_To_Install_External_Packages)

###
function(need_Install_External_Packages NEED)
if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX})
	set(${NEED} TRUE PARENT_SCOPE)
else()
	set(${NEED} FALSE PARENT_SCOPE)
endif()
endfunction(need_Install_External_Packages)


##################################################################################
############################## install the dependancies ########################## 
########### functions used to create the use<package><version>.cmake  ############ 
##################################################################################
function(write_Use_File file package build_mode)
set(MODE_SUFFIX "")
if(${build_mode} MATCHES Release) #mode independent info written only once in the release mode 
	file(APPEND ${file} "######### declaration of package components ########\n")
	file(APPEND ${file} "set(${package}_COMPONENTS ${${package}_COMPONENTS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_COMPONENTS_APPS ${${package}_COMPONENTS_APPS} CACHE INTERNAL \"\")\n")
	file(APPEND ${file} "set(${package}_COMPONENTS_LIBS ${${package}_COMPONENTS_LIBS} CACHE INTERNAL \"\")\n")
	
	file(APPEND ${file} "####### internal specs of package components #######\n")
	foreach(a_component IN ITEMS ${${package}_COMPONENTS_LIBS})
		file(APPEND ${file} "set(${package}_${a_component}_TYPE ${${package}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
		if(NOT ${package}_${a_component}_TYPE STREQUAL "MODULE")#modules do not have public interfaces
			file(APPEND ${file} "set(${package}_${a_component}_HEADER_DIR_NAME ${${package}_${a_component}_HEADER_DIR_NAME} CACHE INTERNAL \"\")\n")
			file(APPEND ${file} "set(${package}_${a_component}_HEADERS ${${package}_${a_component}_HEADERS} CACHE INTERNAL \"\")\n")
		endif()
		file(APPEND ${file} "set(${package}_${a_component}_RUNTIME_RESOURCES ${${package}_${a_component}_RUNTIME_RESOURCES} CACHE INTERNAL \"\")\n")
	endforeach()
	foreach(a_component IN ITEMS ${${package}_COMPONENTS_APPS})
		file(APPEND ${file} "set(${package}_${a_component}_TYPE ${${package}_${a_component}_TYPE} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_RUNTIME_RESOURCES ${${package}_${a_component}_RUNTIME_RESOURCES} CACHE INTERNAL \"\")\n")
	endforeach()
else()
	set(MODE_SUFFIX _DEBUG)
endif()

#mode dependent info written adequately depending the mode 

# 1) external package dependencies
file(APPEND ${file} "#### declaration of external package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")

foreach(a_ext_dep IN ITEMS ${${package}_EXTERNAL_DEPENDENCIES${MODE_SUFFIX}})
	file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	if(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX})
		file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
	else()
		file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_VERSION_EXACT${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
	endif()
	file(APPEND ${file} "set(${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_COMPONENTS${MODE_SUFFIX} ${${package}_EXTERNAL_DEPENDENCY_${a_ext_dep}_COMPONENTS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
endforeach()

# 2) native package dependencies
file(APPEND ${file} "#### declaration of package dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
file(APPEND ${file} "set(${package}_DEPENDENCIES${MODE_SUFFIX} ${${package}_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
foreach(a_dep IN ITEMS ${${package}_DEPENDENCIES${MODE_SUFFIX}})
	file(APPEND ${file} "set(${package}_DEPENDENCY_${a_dep}_VERSION${MODE_SUFFIX} ${${package}_DEPENDENCY_${a_dep}_VERSION${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	if(${package}_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX})
		file(APPEND ${file} "set(${package}_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
	else()
		file(APPEND ${file} "set(${package}_DEPENDENCY_${a_dep}_VERSION_EXACT${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
	endif()
	file(APPEND ${file} "set(${package}_DEPENDENCY_${a_dep}_COMPONENTS${MODE_SUFFIX} ${${package}_DEPENDENCY_${a_dep}_COMPONENTS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
endforeach()

# 3) internal+external components specifications
file(APPEND ${file} "#### declaration of components exported flags and binary in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN ITEMS ${${package}_COMPONENTS})
	is_Built_Component(IS_BUILT_COMP ${package} ${a_component})
	is_Executable_Component(IS_EXEC_COMP ${package} ${a_component})
	if(IS_BUILT_COMP)#if not a pure header library
		file(APPEND ${file} "set(${package}_${a_component}_BINARY_NAME${MODE_SUFFIX} ${${package}_${a_component}_BINARY_NAME${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	endif()
	if(NOT IS_EXEC_COMP)#it is a library
		file(APPEND ${file} "set(${package}_${a_component}_INC_DIRS${MODE_SUFFIX} ${${package}_${a_component}_INC_DIRS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_DEFS${MODE_SUFFIX} ${${package}_${a_component}_DEFS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_LINKS${MODE_SUFFIX} ${${package}_${a_component}_LINKS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${package}_${a_component}_PRIVATE_LINKS${MODE_SUFFIX} ${${package}_${a_component}_PRIVATE_LINKS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
	endif()
endforeach()

# 4) package internal component dependencies
file(APPEND ${file} "#### declaration package internal component dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN ITEMS ${${package}_COMPONENTS})
	if(${package}_${a_component}_INTERNAL_DEPENDENCIES${MODE_SUFFIX}) # the component has internal dependencies
		file(APPEND ${file} "set(${package}_${a_component}_INTERNAL_DEPENDENCIES${MODE_SUFFIX} ${${package}_${a_component}_INTERNAL_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		foreach(a_int_dep IN ITEMS ${${package}_${a_component}_INTERNAL_DEPENDENCIES${MODE_SUFFIX}})
			if(${package}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${MODE_SUFFIX})
				file(APPEND ${file} "set(${package}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")				
			else()
				file(APPEND ${file} "set(${package}_${a_component}_INTERNAL_EXPORT_${a_int_dep}${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")			
			endif()
		endforeach()
	endif()
endforeach()

# 5) component dependencies 
file(APPEND ${file} "#### declaration of component dependencies in ${CMAKE_BUILD_TYPE} mode ####\n")
foreach(a_component IN ITEMS ${${package}_COMPONENTS})
	if(${package}_${a_component}_DEPENDENCIES${MODE_SUFFIX}) # the component has package dependencies
		file(APPEND ${file} "set(${package}_${a_component}_DEPENDENCIES${MODE_SUFFIX} ${${package}_${a_component}_DEPENDENCIES${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
		foreach(dep_package IN ITEMS ${${package}_${a_component}_DEPENDENCIES${MODE_SUFFIX}})
			file(APPEND ${file} "set(${package}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${MODE_SUFFIX} ${${package}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${MODE_SUFFIX}} CACHE INTERNAL \"\")\n")
			foreach(dep_component IN ITEMS ${${package}_${a_component}_DEPENDENCY_${dep_package}_COMPONENTS${MODE_SUFFIX}})
				if(${package}_${a_component}_EXPORT_${dep_package}_${dep_component})
					file(APPEND ${file} "set(${package}_${a_component}_EXPORT_${dep_package}_${dep_component}${MODE_SUFFIX} TRUE CACHE INTERNAL \"\")\n")
				else()
					file(APPEND ${file} "set(${package}_${a_component}_EXPORT_${dep_package}_${dep_component}${MODE_SUFFIX} FALSE CACHE INTERNAL \"\")\n")
				endif()
			endforeach()
		endforeach()
	endif()
endforeach()
endfunction(write_Use_File)

function(create_Use_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode 
	set(file ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake)
else()
	set(file ${CMAKE_BINARY_DIR}/share/UseDebugTemp)
endif()

#resetting the file content
file(WRITE ${file} "")
write_Use_File(${file} ${PROJECT_NAME} ${CMAKE_BUILD_TYPE})

#finalizing release mode by agregating info from the debug mode
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode 
	file(READ "${CMAKE_BINARY_DIR}/../debug/share/UseDebugTemp" DEBUG_CONTENT)
	file(APPEND ${file} "${DEBUG_CONTENT}")
endif()
endfunction(create_Use_File)

###############################################################################################
############################## providing info on the package content ########################## 
###############################################################################################

#################### function used to create the Info<package>.cmake  ######################### 
function(generate_Info_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release) #mode independent info written only once in the release mode 
	set(file ${CMAKE_BINARY_DIR}/share/Info${PROJECT_NAME}.cmake)
	file(WRITE ${file} "")#resetting the file content
	file(APPEND ${file} "######### declaration of package components ########\n")
	file(APPEND ${file} "set(${PROJECT_NAME}_COMPONENTS ${${PROJECT_NAME}_COMPONENTS} CACHE INTERNAL \"\")\n")
	foreach(a_component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})		
		if(NOT ${${PROJECT_NAME}_${a_component}_TYPE} STREQUAL "TEST")
			if(${PROJECT_NAME}_${a_component}_SOURCE_DIR)
				file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_SOURCE_DIR ${${PROJECT_NAME}_${a_component}_SOURCE_DIR} CACHE INTERNAL \"\")\n")
				file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_SOURCE_CODE ${${PROJECT_NAME}_${a_component}_SOURCE_CODE} CACHE INTERNAL \"\")\n")
			endif()
			if(${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME)	
				file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME ${${PROJECT_NAME}_${a_component}_HEADER_DIR_NAME} CACHE INTERNAL \"\")\n")
				file(APPEND ${file} "set(${PROJECT_NAME}_${a_component}_HEADERS ${${PROJECT_NAME}_${a_component}_HEADERS} CACHE INTERNAL \"\")\n")

			endif()
		endif()
	endforeach()
endif()

endfunction(generate_Info_File)


############ function used to create the license.txt file of the package  ###########
function(generate_License_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	if(	DEFINED ${PROJECT_NAME}_LICENSE 
		AND NOT ${${PROJECT_NAME}_LICENSE} STREQUAL "")
	
		find_file(	LICENSE   
				"License${${PROJECT_NAME}_LICENSE}.cmake"
				PATH "${WORKSPACE_DIR}/share/cmake/system"
				NO_DEFAULT_PATH
			)
		set(LICENSE ${LICENSE} CACHE INTERNAL "")
		
		if(LICENSE_IN-NOTFOUND)
			message(WARNING "license configuration file for ${${PROJECT_NAME}_LICENSE} not found in workspace, license file will not be generated")
		else(LICENSE_IN-NOTFOUND)
			foreach(author IN ITEMS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS})
				generate_Full_Author_String(${author} STRING_TO_APPEND)
				set(${PROJECT_NAME}_AUTHORS_LIST "${${PROJECT_NAME}_AUTHORS_LIST} ${STRING_TO_APPEND}")
			endforeach()
			include(${WORKSPACE_DIR}/share/cmake/licenses/License${${PROJECT_NAME}_LICENSE}.cmake)
			file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
			install(FILES ${CMAKE_SOURCE_DIR}/license.txt DESTINATION ${${PROJECT_NAME}_DEPLOY_PATH})
			file(WRITE ${CMAKE_BINARY_DIR}/share/file_header_comment.txt.in ${LICENSE_HEADER_FILE_DESCRIPTION})
		endif(LICENSE_IN-NOTFOUND)
	endif()
endif()
endfunction(generate_License_File)

############ function used to create the  Find<package>.cmake file of the package  ###########
function(generate_Find_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	# generating/installing the generic cmake find file for the package 
	configure_file(${WORKSPACE_DIR}/share/cmake/patterns/FindPackage.cmake.in ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake @ONLY)
	install(FILES ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake DESTINATION ${WORKSPACE_DIR}/share/cmake/find) #install in the worskpace cmake directory which contains cmake find modules
endif()
endfunction(generate_Find_File)

############ function used to create the Use<package>-<version>.cmake file of the package  ###########
macro(generate_Use_File)
create_Use_File()
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	install(	FILES ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake 
			DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH}
	)
endif()
endmacro(generate_Use_File)


