
##################################################################################
##################auxiliary functions to check package version####################
##################################################################################

###
macro (document_Version_Strings package_name major minor patch)

if(${major} STREQUAL "" AND ${minor} STREQUAL "" AND ${patch} STREQUAL "")
	set(${package_name}_VERSION_STRING "own" PARENT_SCOPE)
else()
	set(${package_name}_VERSION_MAJOR ${major} PARENT_SCOPE)
	set(${package_name}_VERSION_MINOR ${minor} PARENT_SCOPE)
	set(${package_name}_VERSION_PATCH ${patch} PARENT_SCOPE)
	set(${package_name}_VERSION_STRING "${major}.${minor}.${patch}" PARENT_SCOPE)
endif()
endmacro(document_Version_Strings package_name major minor patch)

###
macro(list_Version_Subdirectories result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_DIRECTORY ${curdir}/${child})
			list(APPEND dirlist ${child})
		endif()
	endforeach()
	list(REMOVE_ITEM dirlist "own" "installers")
	set(${result} ${dirlist})
endmacro()

###
function (check_Directory_Exists path)
if(	EXISTS "${path}" 
	AND IS_DIRECTORY "${path}"
  )
	set(RETURN_CHECK_DIRECTORY_EXISTS TRUE PARENT_SCOPE)
	return()
endif()
set(RETURN_CHECK_DIRECTORY_EXISTS FALSE PARENT_SCOPE)
endfunction(check_Directory_Exists path)

###
function (check_Exact_Version package_name package_framework major_version minor_version) #minor version cannot be increased
set(VERSION_HAS_BEEN_FOUND FALSE PARENT_SCOPE)
list_Version_Subdirectories(version_dirs ${package_framework})	
set(curr_patch_version 0)		
foreach(patch IN ITEMS ${version_dirs})
	string(REGEX REPLACE "^${major_version}\\.${minor_version}\\.([0-9]+)$" "\\1" A_VERSION "${patch}")
	if(	A_VERSION 
		AND ${A_VERSION} GREATER ${curr_patch_version})
		set(curr_patch_version ${A_VERSION})
		set(VERSION_HAS_BEEN_FOUND TRUE PARENT_SCOPE)
	endif(A_VERSION)
endforeach()
	
if(${VERSION_HAS_BEEN_FOUND})#at least a good version has been found
	document_Version_Strings(${package_name} ${major_version} ${minor_version} ${curr_patch_version})
endif(${VERSION_HAS_BEEN_FOUND})

endfunction (check_Exact_Version package_name package_framework major_version minor_version)

###
function(check_Minor_Version package_name package_framework major_version minor_version)#major version cannot be increased
set(VERSION_HAS_BEEN_FOUND FALSE PARENT_SCOPE)
set(curr_max_minor_version ${minor_version})
set(curr_patch_version 0)
list_Version_Subdirectories(version_dirs ${package_framework})	
foreach(version IN ITEMS ${version_dirs})
	string(REGEX REPLACE "^${major_version}\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2" A_VERSION "${version}")
	if(A_VERSION)
		list(GET A_VERSION 0 minor)
		list(GET A_VERSION 1 patch)
		if(${minor} EQUAL ${curr_max_minor_version} 
		AND ${patch} GREATER ${curr_patch_version})
			set(VERSION_HAS_BEEN_FOUND TRUE PARENT_SCOPE)			
			#a more recent patch version found with same max minor version
			set(curr_patch_version ${patch})
		elseif(${minor} GREATER ${curr_max_minor_version})
			set(VERSION_HAS_BEEN_FOUND TRUE PARENT_SCOPE)
			#a greater minor version found
			set(curr_max_minor_version ${minor})
			set(curr_patch_version ${patch})	
		endif()
	endif(A_VERSION)
endforeach()

if(${VERSION_HAS_BEEN_FOUND})#at least a good version has been found
	document_Version_Strings(${package_name} ${major_version} ${curr_max_minor_version} ${curr_patch_version})
endif(${VERSION_HAS_BEEN_FOUND})

endfunction(check_Adequate_Version package_name package_framework major_version minor_version)

###
function(check_Local_Or_Newest_Version package_name package_framework)#taking local version or the most recent if not available
set(VERSION_HAS_BEEN_FOUND FALSE PARENT_SCOPE)
set(BASIC_PATH_TO_SEARCH "${package_framework}/own")
check_Directory_Exists(${BASIC_PATH_TO_SEARCH})
if(${RETURN_CHECK_DIRECTORY_EXISTS})
	set(VERSION_HAS_BEEN_FOUND TRUE PARENT_SCOPE)
	document_Version_Strings(${package_name} "" "" "")
	return()
endif(${RETURN_CHECK_DIRECTORY_EXISTS})

#no own folder, the package has been downloaded but is not developped by the user
#taking the last available version
list_Version_Subdirectories(available_versions ${package_framework})
if(NOT available_versions)
	message(SEND_ERROR "Impossible to get any version of the package ${package_name}"	
	return()
else()
	set(version_string_curr "0.0.0")
	foreach(version_element IN ITEMS ${available_versions})
		if(${version_string_curr} VERSION_LESS ${version_element})
			set(version_string_curr ${version_element})
		endif()
	endforeach()
	set(VERSION_HAS_BEEN_FOUND TRUE PARENT_SCOPE)
	string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2;\\3" VERSION_NUMBERS ${version_string_curr})
	list(GET VERSION_NUMBERS 0 major)
	list(GET VERSION_NUMBERS 1 minor)
	list(GET VERSION_NUMBERS 2 patch)
	document_Version_Strings(${package_name} ${major} ${minor} ${patch})
endif()

endfunction(check_Local_Or_Newest_Version package_name package_framework major_version minor_version)


##################################################################################
##############end auxiliary functions to check package version####################
##################################################################################


##################################################################################
##################auxiliary functions to check components info  ##################
##################################################################################

#checking existence of config files
macro(check_Config_Files CONFIG_FILES_FOUND package_path package_name component_name)
set(CONFIG_FILES_FOUND TRUE)
if(DEFINED ${package_name}_${component_name}_CONFIG_FILES)

	foreach(config_file IN ITEMS ${${package_name}_${component_name}_CONFIG_FILES})
		find_file(PATH_TO_CONFIG NAMES ${config_file} PATHS ${package_path}/config/${component_name} NO_DEFAULT_PATH)
		if(PATH_TO_CONFIG-NOTFOUND)
			set(CONFIG_FILES_FOUND FALSE)
			break()
		endif()
	endforeach()
endif()

endmacro(check_Config_Files package_path package_name component_name)


#checking elements of a component
function(check_Component_Elements_Exist package_path package_name component_name)
set(COMPONENT_ELEMENT_NOTFOUND TRUE PARENT_SCOPE)
if(NOT DEFINED ${package_name}_${component_name}_TYPE)#type of the component must be defined
	return()
endif() 	

list(FIND ${package_name}_COMPONENTS_APPS ${component_name} idx)
if(idx EQUAL -1)#the component is NOT an application
	list(FIND ${package_name}_COMPONENTS_LIBS ${component_name} idx)
	if(idx EQUAL -1)#the component is NOT a library either
		return() #ERROR
	else()#the component is a library 
		#for a lib checking first level headers and optionnaly library
		if(DEFINED ${package_name}_${component_name}_HEADERS)#a library must have HEADERS defined otherwise ERROR
			#checking existence of all its exported headers			
			foreach(header IN ITEMS ${${package_name}_${component_name}_HEADERS})
				find_file(PATH_TO_HEADER NAMES ${header} PATHS ${package_path}/include/${component_name} NO_DEFAULT_PATH)
				if(PATH_TO_HEADER-NOTFOUND)
					return()
				endif()
			endforeach()
		else()
			return()	
		endif()
		#now checking for binaries if necessary
		if(${${package_name}_${component_name}_TYPE} STREQUAL "COMPLETE")
			#shared version
			find_library(PATH_TO_LIB NAMES ${component_name} PATHS ${package_path}/lib NO_DEFAULT_PATH)
			if(PATH_TO_EXE-NOTFOUND)
				return()
			endif()
			#static version
			find_library(PATH_TO_LIB NAMES ${component_name}-st PATHS ${package_path}/lib NO_DEFAULT_PATH)
			if(PATH_TO_EXE-NOTFOUND)
				return()
			endif()
		elseif(${${package_name}_${component_name}_TYPE} STREQUAL "STATIC")
			find_library(PATH_TO_LIB NAMES ${component_name}-st PATHS ${package_path}/lib NO_DEFAULT_PATH)
			if(PATH_TO_EXE-NOTFOUND)
				return()
			endif()
		elseif(${${package_name}_${component_name}_TYPE} STREQUAL "SHARED")
			find_library(PATH_TO_LIB NAMES ${component_name} PATHS ${package_path}/lib NO_DEFAULT_PATH)
			if(PATH_TO_EXE-NOTFOUND)
				return()
			endif()
		endif()
		#optionally checking for config files
		check_Config_Files(CONFIG_FILES_FOUND ${package_path} ${package_name} ${component_name})
		if(${CONFIG_FILES_FOUND})
			set(COMPONENT_ELEMENT_NOTFOUND FALSE  PARENT_SCOPE)
		endif(${CONFIG_FILES_FOUND})
	endif()

else()#the component is an application
	if(${${package_name}_${component_name}_TYPE} STREQUAL "APP")
		#now checking for binary
		find_program(PATH_TO_EXE NAMES ${component_name} PATHS ${package_path}/bin NO_DEFAULT_PATH)
		if(PATH_TO_EXE-NOTFOUND)
			return()
		endif()
		#optionally checking for config files
		check_Config_Files(CONFIG_FILES_FOUND ${package_path} ${package_name} ${component_name})
		if(${CONFIG_FILES_FOUND})
			set(COMPONENT_ELEMENT_NOTFOUND FALSE  PARENT_SCOPE)
		endif(${CONFIG_FILES_FOUND})
	else()
		return()
	endif()	
endif()

endfunction(check_Component_Elements_Exist package_name component_name)

###
function (all_Components package_name package_version path_to_package_version)
set(USE_FILE_NOTFOUND FALSE PARENT_SCOPE)
include(${path_to_package_version}/share/Use${package_name}-${package_version}.cmake  OPTIONAL RESULT_VARIABLE res)#using the generated Use<package>-<version>.cmake file to get adequate version information about components
if(${res} STREQUAL NOTFOUND)
	set(USE_FILE_NOTFOUND TRUE PARENT_SCOPE)
	return()
endif()

#checking components found
if(NOT DEFINED ${${package_name}_COMPONENTS})#if there is no component defined for the package there is an error
	set(USE_FILE_NOTFOUND TRUE PARENT_SCOPE)
	return()
endif()

foreach(a_component IN ITEMS ${${package_name}_COMPONENTS})
	check_Component_Elements_Exist(${path_to_package_version} ${package_name} ${a_component})
	if(${COMPONENT_ELEMENT_NOTFOUND})
		set(${package_name}_${requested_component}_FOUND FALSE PARENT_SCOPE)
	else()
		set(${package_name}_${requested_component}_FOUND TRUE PARENT_SCOPE)
	endif(${COMPONENT_ELEMENT_NOTFOUND})
endforeach()

endfunction (all_Components package_name path_to_package_version)


###
function (select_Components package_name path_to_package_version list_of_components)
set(USE_FILE_NOTFOUND FALSE PARENT_SCOPE)

include(${path_to_package_version}/share/Use${package_name}-${package_version}.cmake OPTIONAL RESULT_VARIABLE res)#using the generated Use<package>-<version>.cmake file to get adequate version information about components
if(${res} STREQUAL NOTFOUND)
	set(USE_FILE_NOTFOUND TRUE PARENT_SCOPE)
	return()
endif()

if(NOT DEFINED ${${package_name}_COMPONENTS})#if there is no component defined for the package there is an error
	set(USE_FILE_NOTFOUND TRUE PARENT_SCOPE)
	return()
endif()

#checking that all requested components trully exist for this version
set(ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND TRUE PARENT_SCOPE)
foreach(requested_component IN ITEMS ${list_of_components})
	list(FIND ${package_name}_COMPONENTS ${requested_component} idx)	
	if(idx EQUAL -1)#component has not been found	
		set(${package_name}_${requested_component}_FOUND FALSE PARENT_SCOPE)
		if(${${package_name}_FIND_REQUIRED_${requested_component}})
			set(ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND FALSE PARENT_SCOPE)
		endif()
	else()#component found
		check_Component_Elements_Exist(${path_to_package_version} ${package_name} ${requested_component})
		if(${COMPONENT_ELEMENT_NOTFOUND})
			set(${package_name}_${requested_component}_FOUND FALSE PARENT_SCOPE)
		else()		
			set(${package_name}_${requested_component}_FOUND TRUE PARENT_SCOPE)
		endif()
	endif()
endforeach()

endfunction (select_Components package_name path_to_package_version list_of_components)


##################################################################################
##############end auxiliary functions to check components infos ##################
##################################################################################






