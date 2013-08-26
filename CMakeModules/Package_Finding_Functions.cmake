
##################################################################################
##################auxiliary functions to check package version####################
##################################################################################

###
macro (document_Version_Strings package_name major minor patch)
set(${package_name}_VERSION_MAJOR ${major} PARENT_SCOPE)
set(${package_name}_VERSION_MINOR ${minor} PARENT_SCOPE)
set(${package_name}_VERSION_PATCH ${patch} PARENT_SCOPE)
set(${package_name}_VERSION_STRING "${major}.${minor}.${patch}" PARENT_SCOPE)
endmacro(document_Version_Strings package_name major minor patch)

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
macro(list_Version_Subdirectories result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		check_Directory_Exists("${curdir}/${child}")#security check
		if(${RETURN_CHECK_DIRECTORY_EXISTS})
			list(APPEND dirlist ${child})
		endif(${RETURN_CHECK_DIRECTORY_EXISTS})
	endforeach()
	list(SORT dirlist)
	list(REMOVE_ITEM "installers")#this folder is not a version folder
	set(${result} ${dirlist})
endmacro(list_Version_Subdirectories result curdir)



###
function(check_Compatible_Patch_Version_Directory package_framework major_version minor_version)
	set(BASIC_PATH_TO_SEARCH "${package_framework}/${major_version}.${minor_version}")
	set(RETURN_COMPATIBLE_PATCH_VERSION FALSE PARENT_SCOPE) 
	
	foreach(iteration RANGE 99)
		set(PATH_TO_SEARCH "${BASIC_PATH_TO_SEARCH}.${iteration}")
		check_Directory_Exists(${PATH_TO_SEARCH})
		if(${RETURN_CHECK_DIRECTORY_EXISTS})
			set(RETURN_COMPATIBLE_PATCH_VERSION TRUE PARENT_SCOPE)
			#always register the last patch version found
			set(LAST_COMPATIBLE_PATCH_VERSION iteration PARENT_SCOPE)
		endif(${RETURN_CHECK_DIRECTORY_EXISTS})
	endforeach()
endif(${minor_version} STREQUAL "")
endfunction(check_Compatible_Version_Directory package_framework major_version minor_version)

###
function (check_Exact_Version package_name package_framework major_version minor_version) #minor version cannot be increased
check_Compatible_Patch_Version_Directory(${package_framework} ${major_version} ${minor_version})
if(${RETURN_COMPATIBLE_PATCH_VERSION})
	set(VERSION_HAS_BEEN_FOUND TRUE PARENT_SCOPE)
	document_Version_Strings(${package_name} ${major_version} ${minor_version} ${LAST_COMPATIBLE_PATCH_VERSION})
else(${RETURN_COMPATIBLE_PATCH_VERSION})
	set(VERSION_HAS_BEEN_FOUND FALSE PARENT_SCOPE)
endif(${RETURN_COMPATIBLE_PATCH_VERSION})
endfunction (check_Exact_Version package_name package_framework major_version minor_version)

###
function(check_Minor_Version package_name package_framework major_version minor_version)#major version cannot be increased
set(BASIC_PATH_TO_SEARCH "${package_framework}/${major_version}")
set(VERSION_HAS_BEEN_FOUND FALSE PARENT_SCOPE)

foreach(iteration RANGE ${minor_version} 99)
	check_Compatible_Patch_Version_Directory(${package_framework} ${major_version} ${iteration})
	if(${RETURN_COMPATIBLE_PATCH_VERSION})
		set(VERSION_HAS_BEEN_FOUND TRUE PARENT_SCOPE)
		set(LAST_COMPATIBLE_MINOR_VERSION ${iteration})
	endif(${RETURN_COMPATIBLE_PATCH_VERSION})

endforeach()	

if(${VERSION_HAS_BEEN_FOUND})
	document_Version_Strings(${package_name} ${major_version} ${LAST_COMPATIBLE_MINOR_VERSION} ${LAST_COMPATIBLE_PATCH_VERSION})
endif()
endfunction(check_Adequate_Version package_name package_framework major_version minor_version)

###
function(check_Local_Or_Newest_Version package_name package_framework major_version minor_version)#major version can be increased





endfunction(check_Local_Or_Newest_Version package_name package_framework major_version minor_version)


##################################################################################
##############end auxiliary functions to check package version####################
##################################################################################


##################################################################################
##################auxiliary functions to fill exported variables##################
##################################################################################
function (select_Components package_name path_to_package_version list_of_components)




endfunction (select_Components package_name path_to_package_version list_of_components)


function (all_Components package_name path_to_package_version)




endfunction (all_Components package_name path_to_package_version)

##################################################################################
##############end auxiliary functions to fill exported variables##################
##################################################################################



