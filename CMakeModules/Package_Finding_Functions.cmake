
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
##################auxiliary functions to fill exported variables##################
##################################################################################


function (all_Components package_name package_version path_to_package_version)
set(COMPONENT_FUNCTION_RETURNS TRUE PARENT_SCOPE)
include(${path_to_package_version}/share/Use${package_name}-${package_version}.cmake  OPTIONAL RESULT_VARIABLE res)#using the generated Use<package>-<version>.cmake file to get adequate version information about components
if(${res} EQUAL NOTFOUND)
	set(COMPONENT_FUNCTION_RETURNS FALSE PARENT_SCOPE)
endif()
endfunction (all_Components package_name path_to_package_version)


function (select_Components package_name path_to_package_version list_of_components)
set(COMPONENT_FUNCTION_RETURNS TRUE PARENT_SCOPE)
set(ALL_COMPONENTS_HAVE_BEEN_FOUND FALSE PARENT_SCOPE)
include(${path_to_package_version}/share/Use${package_name}-${package_version}.cmake OPTIONAL RESULT_VARIABLE res)#using the generated Use<package>-<version>.cmake file to get adequate version information about components
if(${res} EQUAL NOTFOUND)
	set(COMPONENT_FUNCTION_RETURNS FALSE PARENT_SCOPE)
	return()
endif()

#checking that all requested components trully exist for this version
foreach(requested_component IN ITEMS ${list_of_components})
	list(FIND ${package_name}_COMPONENTS ${requested_component} idx)	
	if(idx EQUAL -1)#component has not been found
		return()
	endif()
endforeach()
set(ALL_COMPONENTS_HAVE_BEEN_FOUND TRUE PARENT_SCOPE)

endfunction (select_Components package_name path_to_package_version list_of_components)


##################################################################################
##############end auxiliary functions to fill exported variables##################
##################################################################################



