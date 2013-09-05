
##################################################################################
##################auxiliary functions to check package version####################
##################################################################################

###
macro (document_Version_Strings is_local package_name major minor patch)

if(is_local)
	set(${package_name}_VERSION_MAJOR ${major} PARENT_SCOPE)
	set(${package_name}_VERSION_MINOR ${minor} PARENT_SCOPE)
	set(${package_name}_VERSION_PATCH ${patch} PARENT_SCOPE)
	set(${package_name}_VERSION_STRING "${major}.${minor}.${patch}" PARENT_SCOPE)
	set(${package_name}_VERSION_RELATIVE_PATH "own-${${package_name}_VERSION_STRING}" PARENT_SCOPE)
	
else(is_local)
	set(${package_name}_VERSION_MAJOR ${major} PARENT_SCOPE)
	set(${package_name}_VERSION_MINOR ${minor} PARENT_SCOPE)
	set(${package_name}_VERSION_PATCH ${patch} PARENT_SCOPE)
	set(${package_name}_VERSION_STRING "${major}.${minor}.${patch}" PARENT_SCOPE)
	set(${package_name}_VERSION_RELATIVE_PATH "${major}.${minor}.${patch}" PARENT_SCOPE)
endif(is_local)
endmacro(document_Version_Strings)

###
function(list_Version_Subdirectories result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		string(REGEX MATCH "^own-.*$" LOCAL ${child})
		if(IS_DIRECTORY ${curdir}/${child} AND NOT LOCAL)
			list(APPEND dirlist ${child})
		endif()
	endforeach()
	list(REMOVE_ITEM dirlist "installers")
	set(${result} ${dirlist} PARENT_SCOPE)
endfunction(list_Version_Subdirectories)


###
function(list_Local_Version_Subdirectories result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/own-*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_DIRECTORY ${curdir}/${child})
			list(APPEND dirlist ${child})
		endif()
	endforeach()
	set(${result} ${dirlist} PARENT_SCOPE)
endfunction(list_Local_Version_Subdirectories)

###
function (check_Directory_Exists is_existing path)
if(	EXISTS "${path}" 
	AND IS_DIRECTORY "${path}"
  )
	set(${is_existing} TRUE PARENT_SCOPE)
	return()
endif()
set(${is_existing} FALSE PARENT_SCOPE)
endfunction(check_Directory_Exists)

### this functions check local install dirs first
function (check_Exact_Version 	VERSION_HAS_BEEN_FOUND 
				package_name package_install_dir major_version minor_version) #minor version cannot be increased
set(${VERSION_HAS_BEEN_FOUND} FALSE PARENT_SCOPE)

list_Local_Version_Subdirectories(version_dirs ${package_install_dir})
if(version_dirs)#scanning local versions  
	set(curr_patch_version 0)
	foreach(patch IN ITEMS ${version_dirs})
		string(REGEX REPLACE "^own-${major_version}\\.${minor_version}\\.([0-9]+)$" "\\1" A_VERSION "${patch}")
		if(	A_VERSION
			AND ${A_VERSION} GREATER ${curr_patch_version})
			set(curr_patch_version ${A_VERSION})
			set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
		endif()
	endforeach()
	
	if(${VERSION_HAS_BEEN_FOUND})#a good local version has been found
		document_Version_Strings(TRUE ${package_name} ${major_version} ${minor_version} ${curr_patch_version})
		return() #local versions have priorities over non local ones in EXACT mode	
	endif()	
endif()
unset(version_dirs)
list_Version_Subdirectories(version_dirs ${package_install_dir})
if(version_dirs)#scanning non local versions  
	set(curr_patch_version 0)		
	foreach(patch IN ITEMS ${version_dirs})
		string(REGEX REPLACE "^${major_version}\\.${minor_version}\\.([0-9]+)$" "\\1" A_VERSION "${patch}")
		if(	A_VERSION 
			AND ${A_VERSION} GREATER ${curr_patch_version})
			set(curr_patch_version ${A_VERSION})
			set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
		endif()
	endforeach()
	
	if(${VERSION_HAS_BEEN_FOUND})#at least a good version has been found
		document_Version_Strings(FALSE ${package_name} ${major_version} ${minor_version} ${curr_patch_version})
		return()
	endif()
endif()
endfunction (check_Exact_Version)

### this function never scans local install dirs
function(check_Best_Version 	VERSION_HAS_BEEN_FOUND
				package_name package_install_dir major_version minor_version)#major version cannot be increased
set(${VERSION_HAS_BEEN_FOUND} FALSE PARENT_SCOPE)
set(curr_max_minor_version ${minor_version})
set(curr_patch_version 0)
list_Version_Subdirectories(version_dirs ${package_install_dir})	
foreach(version IN ITEMS ${version_dirs})
	string(REGEX REPLACE "^${major_version}\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2" A_VERSION "${version}")
	if(A_VERSION)
		list(GET A_VERSION 0 minor)
		list(GET A_VERSION 1 patch)
		if(${minor} EQUAL ${curr_max_minor_version} 
		AND ${patch} GREATER ${curr_patch_version})
			set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)			
			#a more recent patch version found with same max minor version
			set(curr_patch_version ${patch})
		elseif(${minor} GREATER ${curr_max_minor_version})
			set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
			#a greater minor version found
			set(curr_max_minor_version ${minor})
			set(curr_patch_version ${patch})	
		endif()
	endif(A_VERSION)
endforeach()

if(${VERSION_HAS_BEEN_FOUND})#at least a good version has been found
	document_Version_Strings(FALSE ${package_name} ${major_version} ${curr_max_minor_version} ${curr_patch_version})
endif()
endfunction(check_Best_Version)

### this function checks into local folders first then in 
function(check_Last_Version 	VERSION_HAS_BEEN_FOUND
					package_name package_install_dir)#taking local version or the most recent if not available
set(${VERSION_HAS_BEEN_FOUND} FALSE PARENT_SCOPE)
list_Local_Version_Subdirectories(local_versions ${package_install_dir})
list_Version_Subdirectories(non_local_versions ${package_install_dir})

if(local_versions OR non_local_versions)  
	set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
	set(version_string_curr "0.0.0")
	set(is_local FALSE)	
	foreach(local_version_dir IN ITEMS ${local_versions})
		set(VERSION_NUMBER)		
		string(REGEX REPLACE "^own-([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1\.\\2\.\\3" VERSION_NUMBER ${local_version_dir})		
		if(VERSION_NUMBER AND ${version_string_curr} VERSION_LESS ${VERSION_NUMBER})
			set(is_local TRUE)
			set(version_string_curr ${VERSION_NUMBER})
		endif()
	endforeach()
	foreach(non_local_version_dir IN ITEMS ${non_local_versions})
		if(${version_string_curr} VERSION_LESS ${non_local_version_dir})
			set(is_local FALSE)
			set(version_string_curr ${non_local_version_dir})
		endif()
	endforeach()

	string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2;\\3" VERSION_NUMBERS ${version_string_curr})
	list(GET VERSION_NUMBERS 0 major)
	list(GET VERSION_NUMBERS 1 minor)
	list(GET VERSION_NUMBERS 2 patch)
	document_Version_Strings(${is_local} ${package_name} ${major} ${minor} ${patch})
endif()
endfunction(check_Last_Version)

##################################################################################
##################auxiliary functions to check components info  ##################
##################################################################################

#checking elements of a component
function(check_Component_Elements_Exist COMPONENT_ELEMENT_NOTFOUND package_path package_name component_name)
set(${COMPONENT_ELEMENT_NOTFOUND} TRUE PARENT_SCOPE)
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
				find_file(PATH_TO_HEADER NAMES ${header} PATHS ${package_path}/include/${${package_name}_${component_name}_HEADER_DIR_NAME} NO_DEFAULT_PATH)
				if(PATH_TO_HEADER-NOTFOUND)
					return()
				endif()
			endforeach()
		else()
			return()	
		endif()
		#now checking for binaries if necessary
		if(	${package_name}_${component_name}_TYPE STREQUAL "STATIC"
			OR ${package_name}_${component_name}_TYPE STREQUAL "SHARED")
			#checking release and debug binaries (at least one is required)
			find_library(	PATH_TO_LIB 
					NAMES ${${package_name}_${component_name}_BINARY_NAME} ${${package_name}_${component_name}_BINARY_NAME_DEBUG}
					PATHS ${package_path}/lib NO_DEFAULT_PATH)
			if(PATH_TO_LIB-NOTFOUND)
				return()
			endif()			
		endif()
		set(${COMPONENT_ELEMENT_NOTFOUND} FALSE PARENT_SCOPE)
	endif()

else()#the component is an application
	if(${${package_name}_${component_name}_TYPE} STREQUAL "APP")
		#now checking for binary
		find_program(	PATH_TO_EXE 
				NAMES ${${package_name}_${component_name}_BINARY_NAME} ${${package_name}_${component_name}_BINARY_NAME_DEBUG}
				PATHS ${package_path}/bin NO_DEFAULT_PATH)
		if(PATH_TO_EXE-NOTFOUND)
			return()
		endif()
		set(${COMPONENT_ELEMENT_NOTFOUND} FALSE  PARENT_SCOPE)
	else()
		return()
	endif()	
endif()

endfunction(check_Component_Elements_Exist)

###
function (all_Components package_name package_version path_to_package_version)
set(USE_FILE_NOTFOUND FALSE PARENT_SCOPE)
include(${path_to_package_version}/share/Use${package_name}-${package_version}.cmake  OPTIONAL RESULT_VARIABLE res)#using the generated Use<package>-<version>.cmake file to get adequate version information about components
if(	${res} STREQUAL NOTFOUND
	OR NOT DEFINED ${package_name}_COMPONENTS) #if there is no component defined for the package there is an error
	set(USE_FILE_NOTFOUND TRUE PARENT_SCOPE)
	return()
endif()

foreach(a_component IN ITEMS ${${package_name}_COMPONENTS})
	check_Component_Elements_Exist(COMPONENT_ELEMENT_NOTFOUND ${path_to_package_version} ${package_name} ${a_component})
	if(COMPONENT_ELEMENT_NOTFOUND)
		set(${package_name}_${requested_component}_FOUND FALSE PARENT_SCOPE)
	else()
		set(${package_name}_${requested_component}_FOUND TRUE PARENT_SCOPE)
	endif(${COMPONENT_ELEMENT_NOTFOUND})
endforeach()
endfunction (all_Components)


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
		check_Component_Elements_Exist(COMPONENT_ELEMENT_NOTFOUND ${path_to_package_version} ${package_name} ${requested_component})
		if(COMPONENT_ELEMENT_NOTFOUND)
			set(${package_name}_${requested_component}_FOUND FALSE PARENT_SCOPE)
		else()		
			set(${package_name}_${requested_component}_FOUND TRUE PARENT_SCOPE)
		endif()
	endif()
endforeach()
endfunction (select_Components)



