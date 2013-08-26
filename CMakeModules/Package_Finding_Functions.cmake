
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
macro(List_Version_Subdirectories result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_DIRECTORY ${curdir}/${child})
		list(APPEND dirlist ${child})
		endif()
	endforeach()
	list(REMOVE_ITEM dirlist "own" "installers")
	list(SORT dirlist)
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
List_Version_Subdirectories(available_versions ${package_framework})
if(NOT available_versions)
	message(SEND_ERROR "Impossible to get any version of the package ${package_name}"	
	return()
else()
	list(REVERSE available_versions)
	list(GET available_versions 0 LAST_VERSION_AVAILABLE)	
	set(VERSION_HAS_BEEN_FOUND TRUE PARENT_SCOPE)
	#TODO verifier la REGEXP	
	string(REGEX MATCH "^([0-99])\.([0-99])\.([0-99])$" VERSION_NUMBERS ${LAST_VERSION_AVAILABLE})
	#TODO comment extraires les sous produits de la regrexp
	document_Version_Strings(${package_name} "" "" "")
endif()


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



