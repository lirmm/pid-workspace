
##################################################################################
##################auxiliary functions to check package version####################
##################################################################################

###
function(get_Version_String_Numbers version_string major minor patch)
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2;\\3" A_VERSION "${version_string}")
if(NOT A_VERSION STREQUAL "${version_string}")
	list(GET A_VERSION 0 major_vers)
	list(GET A_VERSION 1 minor_vers)
	list(GET A_VERSION 2 patch_vers)
	set(${major} ${major_vers} PARENT_SCOPE)
	set(${minor} ${minor_vers} PARENT_SCOPE)
	set(${patch} ${patch_vers} PARENT_SCOPE)
else()
	message(FATAL_ERROR "BUG : corrupted version string : ${version_string}")
endif()	
endfunction(get_Version_String_Numbers)

###
function (document_Version_Strings is_local package_name major minor patch)
if(is_local)
	set(${package_name}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set(${package_name}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set(${package_name}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set(${package_name}_VERSION_STRING "${major}.${minor}.${patch}" CACHE INTERNAL "")
	set(${package_name}_VERSION_RELATIVE_PATH "own-${${package_name}_VERSION_STRING}" CACHE INTERNAL "")
	
else(is_local)
	set(${package_name}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set(${package_name}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set(${package_name}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set(${package_name}_VERSION_STRING "${major}.${minor}.${patch}" CACHE INTERNAL "")
	set(${package_name}_VERSION_RELATIVE_PATH "${major}.${minor}.${patch}" CACHE INTERNAL "")
endif(is_local)
endfunction(document_Version_Strings)

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

### check if an exact major.minor version exists (patch version is always let undefined)
function (check_Exact_Version 	VERSION_HAS_BEEN_FOUND 
				package_name package_install_dir major_version minor_version) #minor version cannot be increased
set(${VERSION_HAS_BEEN_FOUND} FALSE PARENT_SCOPE)
if(USE_LOCAL_DEPLOYMENT) #local versions have priorities over non local ones in USE_LOCAL_DEPLOYMENT mode (e.g. DEVELOPMENT VERSIONS HAVE GREATER PRIORITIES)
	list_Local_Version_Subdirectories(version_dirs ${package_install_dir})
	if(version_dirs)#scanning local versions  
		set(curr_patch_version 0)
		foreach(patch IN ITEMS ${version_dirs})
			string(REGEX REPLACE "^own-${major_version}\\.${minor_version}\\.([0-9]+)$" "\\1" A_VERSION "${patch}")
			if(	NOT (A_VERSION STREQUAL "${patch}")#there is a match
				AND ${A_VERSION} GREATER ${curr_patch_version})#newer patch version
				set(curr_patch_version ${A_VERSION})
				#set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
				set(result true)
			endif()
		endforeach()
	
		if(result)#a good local version has been found
			message("a local version has been found with hasbeenfound=${VERSION_HAS_BEEN_FOUND}!!")			
			set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)			
			document_Version_Strings(TRUE ${package_name} ${major_version} ${minor_version} ${curr_patch_version})
			return() 	
		endif()	
	unset(version_dirs)	
	endif()
	
endif()

#no adequate local version found OR local version not used
list_Version_Subdirectories(version_dirs ${package_install_dir})
if(version_dirs)#scanning non local versions  
	set(curr_patch_version 0)		
	foreach(patch IN ITEMS ${version_dirs})
		string(REGEX REPLACE "^${major_version}\\.${minor_version}\\.([0-9]+)$" "\\1" A_VERSION "${patch}")
		if(	NOT (A_VERSION STREQUAL "${patch}")#there is a match
			AND ${A_VERSION} GREATER ${curr_patch_version})#newer patch version
			set(curr_patch_version ${A_VERSION})
			set(result true)	
		endif()
	endforeach()
	
	if(result)#at least a good version has been found
		set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
		document_Version_Strings(FALSE ${package_name} ${major_version} ${minor_version} ${curr_patch_version})
		return()
	endif()
endif()
endfunction (check_Exact_Version)


###  check if a version with constraints =major >=minor (with greater minor number available) exists (patch version is always let undefined)
function(check_Best_Version 	VERSION_HAS_BEEN_FOUND
				package_name package_install_dir major_version minor_version)#major version cannot be increased
set(${VERSION_HAS_BEEN_FOUND} FALSE PARENT_SCOPE)

if(USE_LOCAL_DEPLOYMENT) #local versions have priorities over non local ones in USE_LOCAL_DEPLOYMENT mode (e.g. DEVELOPMENT VERSIONS HAVE GREATER PRIORITIES)
	set(curr_max_minor_version ${minor_version})
	set(curr_patch_version 0)
	list_Local_Version_Subdirectories(version_dirs ${package_install_dir})
	if(version_dirs)#scanning local versions  
		foreach(version IN ITEMS ${version_dirs})
			string(REGEX REPLACE "^own-${major_version}\\.([0-9]+)\\.([0-9]+)$" "\\1" A_VERSION "${version}")
			if(NOT (A_VERSION STREQUAL "${version}"))#there is a match
				list(GET A_VERSION 0 minor)
				list(GET A_VERSION 1 patch)
				if("${minor}" EQUAL "${curr_max_minor_version}" 
				AND ("${patch}" EQUAL "${curr_patch_version}" OR "${patch}" GREATER "${curr_patch_version}"))
					set(result true)		
					#a more recent patch version found with same max minor version
					set(curr_patch_version ${patch})
				elseif("${minor}" GREATER "${curr_max_minor_version}")
					set(result true)	
					#a greater minor version found
					set(curr_max_minor_version ${minor})
					set(curr_patch_version ${patch})	
				endif()
			endif()
		endforeach()
	
		if(result)#a good local version has been found
			set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
			document_Version_Strings(TRUE ${package_name} ${major_version} ${curr_max_minor_version} ${curr_patch_version})
			return() 	
		endif()	
	endif()
	unset(version_dirs)
endif()
#no adequate local version found OR local version not used
set(curr_max_minor_version ${minor_version})
set(curr_patch_version 0)
list_Version_Subdirectories(version_dirs ${package_install_dir})
if(version_dirs)#scanning local versions  
	foreach(version IN ITEMS ${version_dirs})
		string(REGEX REPLACE "^${major_version}\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2" A_VERSION "${version}")
		if(NOT (A_VERSION STREQUAL "${version}"))#there is a match
			list(GET A_VERSION 0 minor)
			list(GET A_VERSION 1 patch)
			if("${minor}" EQUAL "${curr_max_minor_version}"
			AND ("${patch}" EQUAL "${curr_patch_version}" OR "${patch}" GREATER "${curr_patch_version}"))
				set(result true)			
				#a more recent patch version found with same max minor version
				set(curr_patch_version ${patch})
			elseif("${minor}" GREATER "${curr_max_minor_version}")
				set(result true)
				#a greater minor version found
				set(curr_max_minor_version ${minor})
				set(curr_patch_version ${patch})	
			endif()
		endif()
	endforeach()
endif()
if(result)#at least a good version has been found
	set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
	document_Version_Strings(FALSE ${package_name} ${major_version} ${curr_max_minor_version} ${curr_patch_version})
endif()
endfunction(check_Best_Version)


### check if a version with constraints >=major >=minor (with greater major and minor number available) exists (patch version is always let undefined) 
function(check_Last_Version 	VERSION_HAS_BEEN_FOUND
				package_name package_install_dir)#taking local version or the most recent if not available
set(${VERSION_HAS_BEEN_FOUND} FALSE PARENT_SCOPE)

if(USE_LOCAL_DEPLOYMENT) #local versions have priorities over non local ones in USE_LOCAL_DEPLOYMENT mode (i.e. DEVELOPMENT VERSIONS HAVE GREATER PRIORITIES)
	list_Local_Version_Subdirectories(local_versions ${package_install_dir})
	if(local_versions)
		set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
		set(version_string_curr "0.0.0")
		foreach(local_version_dir IN ITEMS ${local_versions})
			set(VERSION_NUMBER)		
			string(REGEX REPLACE "^own-([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1\.\\2\.\\3" VERSION_NUMBER ${local_version_dir})
			if(	VERSION_NUMBER
				AND NOT (VERSION_NUMBER STREQUAL "${local_version_dir}") #there is a match
				AND ${version_string_curr} VERSION_LESS "${VERSION_NUMBER}")
				set(version_string_curr ${VERSION_NUMBER})
			endif()
		endforeach()
		get_Version_String_Numbers(${version_string_curr} major minor patch)
		document_Version_Strings(TRUE ${package_name} ${major} ${minor} ${patch})
		return()
	endif()

endif()

#no local version found OR local version not used
list_Version_Subdirectories(non_local_versions ${package_install_dir})
if(non_local_versions)  
	set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
	set(version_string_curr "0.0.0")
	foreach(non_local_version_dir IN ITEMS ${non_local_versions})
		if("${version_string_curr}" VERSION_LESS "${non_local_version_dir}")
			set(version_string_curr ${non_local_version_dir})
		endif()
	endforeach()
	get_Version_String_Numbers(${version_string_curr} major minor patch)
	document_Version_Strings(FALSE ${package_name} ${major} ${minor} ${patch})
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
					set(PATH_TO_HEADER CACHE INTERNAL "")
					return()
				else()
					set(PATH_TO_HEADER CACHE INTERNAL "")
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
				set(PATH_TO_LIB CACHE INTERNAL "")				
				return()
			else()
				set(PATH_TO_LIB CACHE INTERNAL "")
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
			set(PATH_TO_EXE CACHE INTERNAL "")
			return()
		else()
			set(PATH_TO_EXE CACHE INTERNAL "")
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
		set(${package_name}_${requested_component}_FOUND FALSE CACHE INTERNAL "")
	else()
		set(${package_name}_${requested_component}_FOUND TRUE CACHE INTERNAL "")
	endif()
endforeach()
endfunction (all_Components)


###
function (select_Components package_name package_version path_to_package_version list_of_components)
set(USE_FILE_NOTFOUND FALSE PARENT_SCOPE)
include(${path_to_package_version}/share/Use${package_name}-${package_version}.cmake OPTIONAL RESULT_VARIABLE res)#using the generated Use<package>-<version>.cmake file to get adequate version information about components
if(${res} STREQUAL NOTFOUND)
	set(USE_FILE_NOTFOUND TRUE PARENT_SCOPE)
	return()
endif()

if(NOT DEFINED ${package_name}_COMPONENTS)#if there is no component defined for the package there is an error
	set(USE_FILE_NOTFOUND TRUE PARENT_SCOPE)
	return()
endif()

#checking that all requested components trully exist for this version
set(ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND TRUE PARENT_SCOPE)
foreach(requested_component IN ITEMS ${list_of_components})
	list(FIND ${package_name}_COMPONENTS ${requested_component} idx)	
	if(idx EQUAL -1)#component has not been found
		set(${package_name}_${requested_component}_FOUND FALSE  CACHE INTERNAL "")
		if(${${package_name}_FIND_REQUIRED_${requested_component}})
			set(ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND FALSE PARENT_SCOPE)
		endif()
	else()#component found
		check_Component_Elements_Exist(COMPONENT_ELEMENT_NOTFOUND ${path_to_package_version} ${package_name} ${requested_component})
		if(COMPONENT_ELEMENT_NOTFOUND)
			set(${package_name}_${requested_component}_FOUND FALSE  CACHE INTERNAL "")
		else()		
			set(${package_name}_${requested_component}_FOUND TRUE  CACHE INTERNAL "")
		endif()
	endif()
endforeach()
endfunction (select_Components)

###
function(is_Compatible_Version is_compatible package reference_major reference_minor version_to_compare)
set(${is_compatible} FALSE PARENT_SCOPE)
get_Version_String_Numbers("${version_to_compare}.0" compare_major compare_minor compared_patch)
if(	NOT ${compare_major} EQUAL ${reference_major}
	OR ${compare_minor} GREATER ${reference_minor})
	return()#not compatible
endif()
set(${is_compatible} TRUE PARENT_SCOPE)
endfunction(is_Compatible_Version)

###
function(is_Exact_Version_Compatible_With_Previous_Constraints 
		is_compatible
		need_finding
		package
		version_string)

set(${is_compatible} FALSE PARENT_SCOPE)
set(${need_finding} FALSE PARENT_SCOPE)
if(${package}_REQUIRED_VERSION_EXACT)
	if(NOT ${${package}_REQUIRED_VERSION_EXACT} VERSION_EQUAL ${version_string})#not compatible if versions are not the same				
		return() 
	endif()
	set(${is_compatible} TRUE PARENT_SCOPE)
	return()
endif()
#no exact version required	
get_Version_String_Numbers("${version_string}.0" exact_major exact_minor exact_patch)
foreach(version_required IN ITEMS ${${package}_ALL_REQUIRED_VERSIONS})
	message("version required=${version_required}, exact_major=${exact_major}, exact_minor=${exact_minor}")
	unset(COMPATIBLE_VERSION)
	is_Compatible_Version(COMPATIBLE_VERSION ${package} ${exact_major} ${exact_minor} ${version_required})
	if(NOT COMPATIBLE_VERSION)
		return()#not compatible
	endif()
endforeach()

set(${is_compatible} TRUE PARENT_SCOPE)	
if(NOT ${${package_name}_VERSION_STRING} VERSION_EQUAL ${version_string})
	set(${need_finding} TRUE PARENT_SCOPE) #need to find the new exact version
endif()
endfunction(is_Exact_Version_Compatible_With_Previous_Constraints)


###
function(is_Version_Compatible_With_Previous_Constraints 
		is_compatible		
		version_to_find
		package
		version_string)

set(${is_compatible} FALSE PARENT_SCOPE)
# 1) testing compatibility and recording the higher constraint for minor version number
if(${package}_REQUIRED_VERSION_EXACT)
	get_Version_String_Numbers("${${package}_REQUIRED_VERSION_EXACT}.0" exact_major exact_minor exact_patch)
	is_Compatible_Version(COMPATIBLE_VERSION ${exact_major} ${exact_minor} ${version_string})
	if(COMPATIBLE_VERSION)	
		set(${is_compatible} TRUE PARENT_SCOPE)
	endif()
	return()#no need to set the version to find
endif()
get_Version_String_Numbers("${version_string}.0" new_major new_minor new_patch)
set(curr_major ${new_major})
set(curr_max_minor 0)
foreach(version_required IN ITEMS ${${package}_ALL_REQUIRED_VERSIONS})
	get_Version_String_Numbers("${version_required}.0" required_major required_minor required_patch)
	if(NOT ${required_major} EQUAL ${new_major})
		return()#not compatible
	elseif(${required_minor} GREATER ${new_major})
		set(curr_max_minor ${required_minor})
	else()
		set(curr_max_minor ${new_minor})
	endif()
endforeach()
set(${is_compatible} TRUE PARENT_SCOPE)	

# 2) now we have the greater constraint 
set(max_version_constraint "${curr_major}.${curr_max_minor}")
if(NOT ${${package_name}_VERSION_STRING} VERSION_GREATER ${max_version_constraint})
	set(${version_to_find} ${max_version_constraint} PARENT_SCOPE) #need to find the new version
endif()

endfunction(is_Version_Compatible_With_Previous_Constraints)



