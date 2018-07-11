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
if(PID_PACKAGE_FINDING_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_PACKAGE_FINDING_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

##################################################################################
##################auxiliary functions to check package version####################
##################################################################################

### select the exact compatible version of a native package (with major.minor strict, only patch can be adapted)
function(select_Exact_Native_Version RES_VERSION minimum_version available_versions)
get_Version_String_Numbers(${minimum_version} MAJOR MINOR PATCH)
if(DEFINED PATCH)
	set(curr_max_patch_number ${PATCH})
else()
	set(curr_max_patch_number -1)
endif()

foreach(version IN LISTS available_versions)
	get_Version_String_Numbers("${version}" COMPARE_MAJOR COMPARE_MINOR COMPARE_PATCH)
	if(	COMPARE_MAJOR EQUAL ${MAJOR}
		AND COMPARE_MINOR EQUAL ${MINOR}
		AND COMPARE_PATCH GREATER ${curr_max_patch_number})
		set(curr_max_patch_number ${COMPARE_PATCH})# taking the last patch version available for this major.minor
	endif()
endforeach()
if(curr_max_patch_number EQUAL -1)#i.e. nothing found
	set(${RES_VERSION} PARENT_SCOPE)
else()
	set(${RES_VERSION} "${MAJOR}.${MINOR}.${curr_max_patch_number}" PARENT_SCOPE)
endif()
endfunction(select_Exact_Native_Version)

### select the exact compatible version of an external package (with strict major.minor.patch)
#simply consists in returning the version value if exists in the list
function(select_Exact_External_Version RES_VERSION exact_version available_versions)
foreach(version IN LISTS available_versions)
	if(version VERSION_EQUAL exact_version)
		set(${RES_VERSION} ${version} PARENT_SCOPE)
		return()
	endif()
endforeach()
set(${RES_VERSION} PARENT_SCOPE)
endfunction(select_Exact_External_Version)



### select the best compatible version of a native package (last major.minor available)
function(select_Best_Native_Version RES_VERSION minimum_version available_versions)
get_Version_String_Numbers(${minimum_version} MAJOR MINOR PATCH)
if(DEFINED PATCH)
	set(curr_max_patch_number ${PATCH})
else()
	set(curr_max_patch_number -1)
endif()
set(curr_max_minor_number ${MINOR})
foreach(version IN LISTS available_versions)
	get_Version_String_Numbers("${version}" COMPARE_MAJOR COMPARE_MINOR COMPARE_PATCH)
	if(COMPARE_MAJOR EQUAL ${MAJOR})
		if(	COMPARE_MINOR EQUAL ${curr_max_minor_number}
			AND COMPARE_PATCH GREATER ${curr_max_patch_number})
			set(curr_max_patch_number ${COMPARE_PATCH})# taking the newest patch version for the current major.minor
		elseif(COMPARE_MINOR GREATER ${curr_max_minor_number})
			set(curr_max_patch_number ${COMPARE_PATCH})# taking the patch version of this major.minor
			set(curr_max_minor_number ${COMPARE_MINOR})# taking the last minor version available for this major
		endif()

	endif()
endforeach()
if(curr_max_patch_number EQUAL -1)#i.e. nothing found
	set(${RES_VERSION} PARENT_SCOPE)
else()
	set(${RES_VERSION} "${MAJOR}.${curr_max_minor_number}.${curr_max_patch_number}" PARENT_SCOPE)
endif()
endfunction(select_Best_Native_Version)

### select the best compatible version of a native package (last major.minor available)
function(select_Best_External_Version RES_VERSION package minimum_version available_versions)
foreach(version IN LISTS available_versions)
	if(version VERSION_EQUAL minimum_version
		OR version VERSION_GREATER minimum_version)#only greater or equal versions are feasible
		if(DEFINED ${package}_PID_KNOWN_VERSION_${minimum_version}_GREATER_VERSIONS_COMPATIBLE_UP_TO)#if not defined the version is compatible with nothing
			if(	highest_version )#if a compatible highest version is already found
					if(version VERSION_GREATER highest_version #the new version must be greater to be interesting
						AND version VERSION_LESS "${${package}_PID_KNOWN_VERSION_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO}")#but it also has to be compatible
						set(highest_version ${version})
					endif()
			elseif(version VERSION_LESS "${${package}_PID_KNOWN_VERSION_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO}")#if no highest compatible version found, simply check that the version is compatible
				set(highest_version ${version})#if highest not set, set ot for thr first time
			endif()
		elseif(version VERSION_EQUAL minimum_version)#no compatible version defined, only the exact version can be used
				set(highest_version ${version})
		endif()
	endif()
endforeach()
set(${RES_VERSION} ${highest_version} PARENT_SCOPE)
endfunction(select_Best_External_Version)

### select the last available version of a native package
function(select_Last_Version RES_VERSION available_versions)
set(curr_version 0.0.0)
foreach(version IN LISTS available_versions)
	if(curr_version VERSION_LESS ${version})
		set(curr_version ${version})
	endif()
endforeach()

if(curr_version VERSION_EQUAL "0.0.0")#i.e. nothing found
	set(${RES_VERSION} PARENT_SCOPE)
else()
	set(${RES_VERSION} "${curr_version}" PARENT_SCOPE)
endif()
endfunction(select_Last_Version)

### check if an exact major.minor version exists (patch version is always let undefined)
function (check_Exact_Version 	VERSION_HAS_BEEN_FOUND
				package_name package_install_dir major_version minor_version patch_version) #minor version cannot be increased but patch version can
set(${VERSION_HAS_BEEN_FOUND} FALSE PARENT_SCOPE)
list_Version_Subdirectories(version_dirs ${package_install_dir})
if(version_dirs)#seaking for a good version only if there are versions installed
  if(patch_version)
    update_Package_Installed_Version(${package_name} ${major_version} ${minor_version} ${patch_version} true "${version_dirs}")#updating only if there are installed versions
    set(curr_patch_version ${patch_version})
  else()#any patch version can be used
    update_Package_Installed_Version(${package_name} ${major_version} ${minor_version} "" true "${version_dirs}")#updating only if there are installed versions
    set(curr_patch_version -1)
  endif()
	foreach(patch IN LISTS version_dirs)
		string(REGEX REPLACE "^${major_version}\\.${minor_version}\\.([0-9]+)$" "\\1" A_VERSION "${patch}")
		if(	NOT (A_VERSION STREQUAL "${patch}") #there is a match
			AND ${A_VERSION} GREATER ${curr_patch_version})#newer patch version
			set(curr_patch_version ${A_VERSION})
			set(result true)
		endif()
	endforeach()

	if(result)#at least a good version has been found
		set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
		document_Version_Strings(${package_name} ${major_version} ${minor_version} ${curr_patch_version})
		return()
	endif()
endif()
endfunction(check_Exact_Version)

###  check if a version with constraints =major >=minor (with greater minor number available) exists
# the patch version is used only if =major and =minor is found
function(check_Best_Version 	VERSION_HAS_BEEN_FOUND
				package_name package_install_dir major_version minor_version patch_version)#major version cannot be increased
set(${VERSION_HAS_BEEN_FOUND} FALSE PARENT_SCOPE)
set(curr_max_minor_version ${minor_version})
list_Version_Subdirectories(version_dirs ${package_install_dir})
if(version_dirs)#seaking for a good version only if there are versions installed
  if(patch_version)
    set(curr_patch_version ${patch_version})
  else()#no preliminary contraints applies to version
    set(curr_patch_version 0)
  endif()
  update_Package_Installed_Version(${package_name} ${major_version} ${minor_version} "${patch_version}" false "${version_dirs}")#updating only if there are installed versions
	foreach(version IN LISTS version_dirs)
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
	if(result)#at least a good version has been found
		set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
		document_Version_Strings(${package_name} ${major_version} ${curr_max_minor_version} ${curr_patch_version})
	endif()
endif()
endfunction(check_Best_Version)


### check if a version with constraints >=major >=minor (with greater major and minor number available) exists (patch version is always let undefined)
function(check_Last_Version 	VERSION_HAS_BEEN_FOUND
				package_name package_install_dir)#taking local version or the most recent if not available
set(${VERSION_HAS_BEEN_FOUND} FALSE PARENT_SCOPE)
list_Version_Subdirectories(local_versions ${package_install_dir})
if(local_versions)#seaking for a good version only if there are versions installed
	update_Package_Installed_Version(${package_name} "" "" "" false "${local_versions}")#updating only if there are installed versions
	set(${VERSION_HAS_BEEN_FOUND} TRUE PARENT_SCOPE)
	set(version_string_curr "0.0.0")
	foreach(local_version_dir IN LISTS local_versions)
		if("${version_string_curr}" VERSION_LESS "${local_version_dir}")
			set(version_string_curr ${local_version_dir})
		endif()
	endforeach()
	get_Version_String_Numbers(${version_string_curr} major minor patch)
	document_Version_Strings(${package_name} ${major} ${minor} ${patch})
endif()
endfunction(check_Last_Version)

###########################################################################################
################# auxiliary functions to check external package version ###################
###########################################################################################

### check if a version compatible with minimal version of the external package exists
function(check_External_Minimum_Version VERSION_FOUND package search_path version)
set(${VERSION_FOUND} PARENT_SCOPE)
list_Version_Subdirectories(VERSION_DIRS ${search_path})
if(VERSION_DIRS)
	foreach(version_dir IN LISTS VERSION_DIRS)
		if(version_dir VERSION_EQUAL version OR version_dir VERSION_GREATER version)#only greater or equal versions are feasible
			if(DEFINED ${package}_PID_KNOWN_VERSION_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO)#if not defined the version is compatible with nothing
				if(	highest_version )#if a compatible highest version is already found
						if(version_dir VERSION_GREATER highest_version #the new version must be greater to be interesting
							AND version_dir VERSION_LESS "${${package}_PID_KNOWN_VERSION_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO}")#but it also has to be compatible
							set(highest_version ${version_dir})
						endif()
				elseif(version_dir VERSION_LESS "${${package}_PID_KNOWN_VERSION_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO}")#if no highest compatible version found, simply check that the version is compatible
					set(highest_version ${version_dir})
				endif()
			elseif(version_dir VERSION_EQUAL version)#no compatible version defined, only the exact version can be used
					set(highest_version ${version_dir})
			endif()
		endif()
	endforeach()
	if(highest_version)
		set(${VERSION_FOUND} ${highest_version} PARENT_SCOPE)
		document_External_Version_Strings(${package} ${highest_version})
	endif()
endif()
endfunction(check_External_Minimum_Version)

### check if the last version of the external package exists
function(check_External_Last_Version VERSION_FOUND package search_path)
set(${VERSION_FOUND} PARENT_SCOPE)
list_Version_Subdirectories(VERSION_DIRS ${search_path})
if(VERSION_DIRS)
	foreach(version_dir IN LISTS VERSION_DIRS)
		if(highest_version)
			if(version_dir VERSION_GREATER highest_version)
				set(highest_version ${version_dir})
			endif()
		else()
			set(highest_version ${version_dir})
		endif()
	endforeach()
	if(highest_version)
		set(${VERSION_FOUND} ${highest_version} PARENT_SCOPE)
		document_External_Version_Strings(${package} ${highest_version})
	endif()
endif()
endfunction(check_External_Last_Version)


### check if an exact major.minor.patch version of the external package exists
function(check_External_Exact_Version VERSION_FOUND package search_path version)
set(${VERSION_FOUND} PARENT_SCOPE)
list_Version_Subdirectories(VERSION_DIRS ${search_path})
if(VERSION_DIRS)
	list(FIND VERSION_DIRS ${version} INDEX)
	if(INDEX EQUAL -1)
		return()
	endif()
	set(${VERSION_FOUND} ${version} PARENT_SCOPE)
	document_External_Version_Strings(${package} ${version})
endif()
endfunction(check_External_Exact_Version)

#########################################################################################################
################## auxiliary functions to check components info (native packages only) ##################
#########################################################################################################

# checking that elements of a component (headers binary, etc.) exist
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
		#for a lib checking headers and then binaries
		if(DEFINED ${package_name}_${component_name}_HEADERS)#a library must have HEADERS defined otherwise ERROR
			#checking existence of all its exported headers
			foreach(header IN LISTS ${package_name}_${component_name}_HEADERS)
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
		if(	${${package_name}_${component_name}_TYPE} STREQUAL "STATIC"
			OR ${${package_name}_${component_name}_TYPE} STREQUAL "SHARED"
			OR ${${package_name}_${component_name}_TYPE} STREQUAL "MODULE")
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
	if("${${package_name}_${component_name}_TYPE}" STREQUAL "APP")
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

# checking all component. See: check_Component_Elements_Exist.
function (all_Components package_name package_version path_to_package_version)
set(USE_FILE_NOTFOUND FALSE PARENT_SCOPE)
include(${path_to_package_version}/share/Use${package_name}-${package_version}.cmake  OPTIONAL RESULT_VARIABLE res)#using the generated Use<package>-<version>.cmake file to get adequate version information about components
if(	${res} STREQUAL NOTFOUND
	OR NOT DEFINED ${package_name}_COMPONENTS) #if there is no component defined for the package there is an error
	set(USE_FILE_NOTFOUND TRUE PARENT_SCOPE)
	return()
endif()
set(${package_name}_${requested_component}_FOUND TRUE CACHE INTERNAL "")
foreach(a_component IN LISTS ${package_name}_COMPONENTS)
	check_Component_Elements_Exist(COMPONENT_ELEMENT_NOTFOUND ${path_to_package_version} ${package_name} ${a_component})
	if(COMPONENT_ELEMENT_NOTFOUND)
		set(${package_name}_${requested_component}_FOUND FALSE CACHE INTERNAL "")
	endif()
endforeach()
endfunction (all_Components)


# checking a set of component. See: check_Component_Elements_Exist.
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
foreach(requested_component IN LISTS list_of_components)
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


#########################################################################################################
######################### auxiliary functions to check version info (native packages) ###################
#########################################################################################################


### function used to check is an exact version is compatible with previous version contrainsts that apply to the current build.
function(is_Exact_Version_Compatible_With_Previous_Constraints
		is_compatible
		need_finding
		package
		version_string)

set(${is_compatible} FALSE PARENT_SCOPE)
set(${need_finding} FALSE PARENT_SCOPE)
if(${package}_REQUIRED_VERSION_EXACT)
	get_Version_String_Numbers("${${package}_REQUIRED_VERSION_EXACT}.0" exact_major exact_minor exact_patch)
	is_Exact_Compatible_Version(COMPATIBLE_VERSION ${exact_major} ${exact_minor} ${version_string})
	if(NOT COMPATIBLE_VERSION)#not compatible if versions are not the same major.minor
		return()
	endif()
	set(${is_compatible} TRUE PARENT_SCOPE)
	return()
endif()
#no exact version required
get_Version_String_Numbers("${version_string}.0" exact_major exact_minor exact_patch)
foreach(version_required IN LISTS ${package}_ALL_REQUIRED_VERSIONS)
	unset(COMPATIBLE_VERSION)
	is_Compatible_Version(COMPATIBLE_VERSION ${exact_major} ${exact_minor} ${version_required})
	if(NOT COMPATIBLE_VERSION)
		return()#not compatible
	endif()
endforeach()

set(${is_compatible} TRUE PARENT_SCOPE)
if(NOT ${${package}_VERSION_STRING} VERSION_EQUAL ${version_string})
	set(${need_finding} TRUE PARENT_SCOPE) #need to find the new exact version
endif()
endfunction(is_Exact_Version_Compatible_With_Previous_Constraints)


### function used to check is a version is compatible with previous version contrainsts that apply to the current build.
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
foreach(version_required IN LISTS ${package}_ALL_REQUIRED_VERSIONS)
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
if(NOT ${${package}_VERSION_STRING} VERSION_GREATER ${max_version_constraint})
	set(${version_to_find} ${max_version_constraint} PARENT_SCOPE) #need to find the new version
endif()

endfunction(is_Version_Compatible_With_Previous_Constraints)


#########################################################################################################
####################### auxiliary functions to check version info (external packages) ###################
#########################################################################################################

### function used to check the compatibility between two versions of an external package
function(is_Compatible_External_Version is_compatible package reference_version version_to_compare)

if(${package}_PID_KNOWN_VERSION_${version_to_compare}_GREATER_VERSIONS_COMPATIBLE_UP_TO)

	if(${reference_version}   VERSION_LESS   ${${package}_PID_KNOWN_VERSION_${version_to_compare}_GREATER_VERSIONS_COMPATIBLE_UP_TO})
		set(${is_compatible} TRUE PARENT_SCOPE)
	else()
		set(${is_compatible} FALSE PARENT_SCOPE)
	endif()
else()
	set(${is_compatible} TRUE PARENT_SCOPE) #if not specified it means that there are no known greater version that is not compatible
endif()
endfunction()


### function used to check is an exact version of an external package is compatible with previous version contrainsts that apply to the current build.
function(is_Exact_External_Version_Compatible_With_Previous_Constraints
		is_compatible
		need_finding
		package
		version_string)

set(${is_compatible} FALSE PARENT_SCOPE)
set(${need_finding} FALSE PARENT_SCOPE)
if(${package}_REQUIRED_VERSION_EXACT)
	if(NOT ${${package}_REQUIRED_VERSION_EXACT}  VERSION_EQUAL  ${version_string})#not compatible if versions are not the same
		return()
	endif()
	set(${is_compatible} TRUE PARENT_SCOPE)
	return()
endif()

#no exact version required
foreach(version_required IN LISTS ${package}_ALL_REQUIRED_VERSIONS)
	unset(COMPATIBLE_VERSION)
	is_Compatible_External_Version(COMPATIBLE_VERSION ${package} ${version_required} ${version_string})
	if(NOT COMPATIBLE_VERSION)
		return()#not compatible
	endif()
endforeach()

set(${is_compatible} TRUE PARENT_SCOPE)
if(NOT ${${package}_VERSION_STRING} VERSION_EQUAL ${version_string})
	set(${need_finding} TRUE PARENT_SCOPE) #need to find the new exact version
endif()
endfunction()



### function used to check is a version of an external package is compatible with previous version contrainsts that apply to the current build.
function(is_External_Version_Compatible_With_Previous_Constraints
		is_compatible
		version_to_find
		package
		version_string)

set(${is_compatible} FALSE PARENT_SCOPE)
# 1) testing compatibility and recording the higher constraint for minor version number
if(${package}_REQUIRED_VERSION_EXACT)
	is_Compatible_External_Version(COMPATIBLE_VERSION ${package} ${${package}_REQUIRED_VERSION_EXACT} ${version_string})
	if(COMPATIBLE_VERSION)
		set(${is_compatible} TRUE PARENT_SCOPE)
	endif()
	return()#no need to set the version to find
endif()

foreach(version_required IN LISTS ${package}_ALL_REQUIRED_VERSIONS)
	unset(COMPATIBLE_VERSION)
	is_Compatible_External_Version(COMPATIBLE_VERSION ${package} ${version_required} ${version_string})
	if(NOT COMPATIBLE_VERSION)
		return()
	endif()
endforeach()
set(${is_compatible} TRUE PARENT_SCOPE)
endfunction(is_External_Version_Compatible_With_Previous_Constraints)


##############################################################################################################
############### API functions for managing cache variables bound to package dependencies #####################
##############################################################################################################

###
function(add_To_Install_Package_Specification package version version_exact)
list(FIND ${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} ${package} INDEX)
if(INDEX EQUAL -1)#not found
	set(${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX}} ${package} CACHE INTERNAL "")
	if(version AND NOT version STREQUAL "")
    set(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
		endif()
	endif()
else()#package already required as "to install"
	if(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX})
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
	else()# when there is a problem !! (maybe a warning could be cgood idea)
		set(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
		endif()
	endif()
endif()
endfunction(add_To_Install_Package_Specification)

###
function(reset_To_Install_Packages)
foreach(pack IN LISTS ${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX})
	foreach(version IN LISTS ${PROJECT_NAME}_TOINSTALL_${pack}_VERSIONS${USE_MODE_SUFFIX})
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


### set an external package as "to be installed"
function(add_To_Install_External_Package_Specification package version version_exact)
list(FIND ${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX} ${package} INDEX)
if(INDEX EQUAL -1)#not found => adding it to "to install" packages
	set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX}} ${package} CACHE INTERNAL "")
	if(version AND NOT version STREQUAL "")#set the version
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} "${version_exact}" CACHE INTERNAL "")
	endif()
else()#package already required as "to install"
	if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX})#required versions are already specified
		list(FIND ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} ${version} INDEX)
		if(INDEX EQUAL -1)#version not already required => adding it to required versions
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX}} "${version}" CACHE INTERNAL "")
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} "${version_exact}" CACHE INTERNAL "")
		elseif(version_exact) #if this version was previously not exact it becomes exact if exact is required
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		endif()
	else()#no version specified => simply add the version constraint
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} "${version_exact}" CACHE INTERNAL "")
	endif()
endif()
endfunction(add_To_Install_External_Package_Specification)

###
function(reset_To_Install_External_Packages)
foreach(pack IN LISTS ${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX})
	foreach(version IN LISTS ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_VERSIONS${USE_MODE_SUFFIX})
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_${version}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_VERSIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX} CACHE INTERNAL "")
endfunction(reset_To_Install_External_Packages)


###
function(reset_Found_External_Packages)
foreach(a_used_package IN LISTS ${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES)
	set(${a_used_package}_FOUND CACHE INTERNAL "")
	set(${a_used_package}_ROOT_DIR CACHE INTERNAL "")
	set(${a_used_package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "")
	set(${a_used_package}_REQUIRED_VERSION_EXACT CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES CACHE INTERNAL "")
endfunction(reset_Found_External_Packages)


###
function(reset_Found_Native_Packages)
foreach(a_used_package IN LISTS ${PROJECT_NAME}_ALL_USED_PACKAGES)
	set(${a_used_package}_FOUND CACHE INTERNAL "")
	set(${a_used_package}_ROOT_DIR CACHE INTERNAL "")
	set(${a_used_package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "")
	set(${a_used_package}_REQUIRED_VERSION_EXACT CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_ALL_USED_PACKAGES CACHE INTERNAL "")
endfunction(reset_Found_Native_Packages)

###
function(need_Install_External_Packages NEED)
if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX})
	set(${NEED} TRUE PARENT_SCOPE)
else()
	set(${NEED} FALSE PARENT_SCOPE)
endif()
endfunction(need_Install_External_Packages)

###
function(reset_Packages_Finding_Variables)
#unsetting all cache variables usefull to the find/configuration mechanism
reset_Found_Native_Packages()
reset_Found_External_Packages()
reset_To_Install_Packages()
reset_To_Install_External_Packages()
endfunction(reset_Packages_Finding_Variables)

#########################################################################################################
################## functions to resolve packages dependencies globally ##################################
#########################################################################################################

### Function used to find the best version of a dependency of a given package (i.e. another package). It takes into account the previous constraints that apply to this dependency to find a version that satisfy all constraints (if possible).
# each dependent package version is defined as ${package}_DEPENDENCY_${dependency}_VERSION
# other variables set by the package version use file
# ${package}_DEPENDENCY_${dependency}_REQUIRED		# TRUE if package is required FALSE otherwise (QUIET MODE)
# ${package}_DEPENDENCY_${dependency}_VERSION		# version if a version if specified
# ${package}_DEPENDENCY_${dependency}_VERSION_EXACT	# TRUE if exact version is required
# ${package}_DEPENDENCY_${dependency}_COMPONENTS	# list of components
function(resolve_Package_Dependency package dependency mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(${dependency}_FOUND) #the dependency has already been found (previously found in iteration or recursion, not possible to import it again)
	if(${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX}) # a specific version is required
	 	if( ${package}_DEPENDENCY_${dependency}_VERSION_EXACT${VAR_SUFFIX}) #an exact version is required

			is_Exact_Version_Compatible_With_Previous_Constraints(IS_COMPATIBLE NEED_REFIND ${dependency} ${${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX}}) # will be incompatible if a different exact version already required OR if another major version required OR if another minor version greater than the one of exact version

			if(IS_COMPATIBLE)
				if(NEED_REFIND)
					# OK installing the exact version instead
					#WARNING call to find package
					find_package(
						${dependency}
						${${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX}}
						EXACT
						MODULE
						REQUIRED
						${${package}_DEPENDENCY_${dependency}_COMPONENTS${VAR_SUFFIX}}
					)
				endif()
				return()
			else() #not compatible
				message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent package ${dependency} regarding versions constraints. Search ended when trying to satisfy version coming from package ${package}. All required versions are : ${${dependency}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${dependency}_REQUIRED_VERSION_EXACT}, Last exact version required is ${${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX}}.")
				return()
			endif()
		else()#not an exact version required
			is_Version_Compatible_With_Previous_Constraints (
					COMPATIBLE_VERSION VERSION_TO_FIND
					${dependency} ${${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX}})
			if(COMPATIBLE_VERSION)
				if(VERSION_TO_FIND)
					find_package(
						${dependency}
						${VERSION_TO_FIND}
						MODULE
						REQUIRED
						${${package}_DEPENDENCY_${dependency}_COMPONENTS${VAR_SUFFIX}}
					)
				else()
					return() # nothing to do more, the current used version is compatible with everything
				endif()
			else()
				message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent package ${dependency} regarding versions constraints. Search ended when trying to satisfy version coming from package ${package}. All required versions are : ${${dependency}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${dependency}_REQUIRED_VERSION_EXACT}, Last version required is ${${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX}}.")
				return()
			endif()
		endif()
	else()
		return()#by default the version is compatible (no constraints) so return
	endif()
else()#the dependency has not been already found
	if(${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX})

		if(${package}_DEPENDENCY_${dependency}_VERSION_EXACT${VAR_SUFFIX}) #an exact version has been specified
			#WARNING recursive call to find package
			find_package(
				${dependency}
				${${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX}}
				EXACT
				MODULE
				REQUIRED
				${${package}_DEPENDENCY_${dependency}_COMPONENTS${VAR_SUFFIX}}
			)

		else()
			#WARNING recursive call to find package
			find_package(
				${dependency}
				${${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX}}
				MODULE
				REQUIRED
				${${package}_DEPENDENCY_${dependency}_COMPONENTS${VAR_SUFFIX}}
			)
		endif()
	else()
		find_package(
			${dependency}
			MODULE
			REQUIRED
			${${package}_DEPENDENCY_${dependency}_COMPONENTS${VAR_SUFFIX}}
		)
	endif()
endif()

endfunction(resolve_Package_Dependency)

###
function(resolve_External_Package_Dependency package external_dependency mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(${external_dependency}_FOUND) #the dependency has already been found (previously found in iteration or recursion, not possible to import it again)
	if(${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX}) # a specific version is required
	 	if( ${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION_EXACT${VAR_SUFFIX}) #an exact version is required

			is_Exact_External_Version_Compatible_With_Previous_Constraints(IS_COMPATIBLE NEED_REFIND ${external_dependency} ${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX}}) # will be incompatible if a different exact version already required OR if another major version required OR if another minor version greater than the one of exact version

			if(IS_COMPATIBLE)
				if(NEED_REFIND)
					# OK installing the exact version instead
					#WARNING call to find package
					find_package(
						${external_dependency}
						${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX}}
						EXACT
						MODULE
						REQUIRED
						${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_COMPONENTS${VAR_SUFFIX}}
					)
				endif()
				return()
			else() #not compatible
				message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent external package ${external_dependency} regarding versions constraints. Search ended when trying to satisfy version coming from package ${package}. All required versions are : ${${external_dependency}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${external_dependency}_REQUIRED_VERSION_EXACT}, Last exact version required is ${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX}}.")
				return()
			endif()
		else()#not an exact version required
			is_External_Version_Compatible_With_Previous_Constraints (
					COMPATIBLE_VERSION VERSION_TO_FIND
					${external_dependency} ${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX}})
			if(COMPATIBLE_VERSION)
				if(VERSION_TO_FIND)
					find_package(
						${external_dependency}
						${VERSION_TO_FIND}
						MODULE
						REQUIRED
						${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_COMPONENTS${VAR_SUFFIX}}
					)
				else()
					return() # nothing to do more, the current used version is compatible with everything
				endif()
			else()
				message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent package ${external_dependency} regarding versions constraints. Search ended when trying to satisfy version coming from package ${package}. All required versions are : ${${external_dependency}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${external_dependency}_REQUIRED_VERSION_EXACT}, Last version required is ${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX}}.")
				return()
			endif()
		endif()
	else()
		return()#by default the version is compatible (no constraints) so return
	endif()
else()#the dependency has not been already found
	if(	${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX})

		if(${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION_EXACT${VAR_SUFFIX}) #an exact version has been specified
			#WARNING recursive call to find package
			find_package(
				${external_dependency}
				${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX}}
				EXACT
				MODULE
				REQUIRED
				${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_COMPONENTS${VAR_SUFFIX}}
			)

		else()
			#WARNING recursive call to find package
			find_package(
				${external_dependency}
				${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX}}
				MODULE
				REQUIRED
				${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_COMPONENTS${VAR_SUFFIX}}
			)
		endif()
	else()
		find_package(
			${external_dependency}
			MODULE
			REQUIRED
			${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_COMPONENTS${VAR_SUFFIX}}
		)
	endif()
endif()

endfunction(resolve_External_Package_Dependency)


############################################################################
################ macros used to write cmake find scripts ###################
############################################################################
macro(exitFindScript package message_to_send)
	if(${package}_FIND_REQUIRED)
		message(SEND_ERROR "${message_to_send}")#fatal error
		return()
	elseif(${package}_FIND_QUIETLY)
		return()#simply exitting
	else()
		message(STATUS "${message_to_send}")#simple notification message
		return()
	endif()
endmacro(exitFindScript)

### macro to be called in find script of packages. Implement the finding process the standard way in CMake.
macro(finding_Package package)
set(${package}_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(PACKAGE_${package}_SEARCH_PATH
    ${PACKAGE_BINARY_INSTALL_DIR}/${package}
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the package : ${package}"
  )

check_Directory_Exists(EXIST ${PACKAGE_${package}_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions
	#variables that will be filled by generic functions
	if(${package}_FIND_VERSION)
		if(${package}_FIND_VERSION_EXACT) #using a specific version (only patch number can be adapted)
			check_Exact_Version(VERSION_HAS_BEEN_FOUND "${package}" ${PACKAGE_${package}_SEARCH_PATH} ${${package}_FIND_VERSION_MAJOR} ${${package}_FIND_VERSION_MINOR} "${${package}_FIND_VERSION_PATCH}")
		else() #using the best version as regard of version constraints (only minor and patch numbers can be adapted)
      check_Best_Version(VERSION_HAS_BEEN_FOUND "${package}" ${PACKAGE_${package}_SEARCH_PATH} ${${package}_FIND_VERSION_MAJOR} ${${package}_FIND_VERSION_MINOR} "${${package}_FIND_VERSION_PATCH}")
		endif()
	else() #no specific version targetted using last available version (major minor and patch numbers can be adapted)
		check_Last_Version(VERSION_HAS_BEEN_FOUND "${package}" ${PACKAGE_${package}_SEARCH_PATH})
	endif()
	if(VERSION_HAS_BEEN_FOUND)#a good version of the package has been found
		set(PATH_TO_PACKAGE_VERSION ${PACKAGE_${package}_SEARCH_PATH}/${${package}_VERSION_RELATIVE_PATH})
		if(${package}_FIND_COMPONENTS) #specific components must be checked, taking only selected components

			select_Components(${package} ${${package}_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION} "${${package}_FIND_COMPONENTS}")
			if(USE_FILE_NOTFOUND)
				exitFindScript(${package} "[PID] CRITICAL ERROR  when configuring ${PROJECT_NAME} : the selected version of ${package} (${${package}_VERSION_STRING}) has no configuration file or file is corrupted")
			endif()

			if(NOT ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND)
				exitFindScript(${package} "[PID] CRITICAL ERROR  when configuring ${PROJECT_NAME} : some of the requested components of the package ${package} are missing (version chosen is ${${package}_VERSION_STRING}, requested is ${${package}_FIND_VERSION}),either bad names specified or broken package versionning.")
			endif()

		else()#no component check, register all of them

			all_Components("${package}" ${${package}_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION})
			if(USE_FILE_NOTFOUND)
				exitFindScript(${package} "[PID] CRITICAL ERROR when configuring ${PROJECT_NAME} : the  selected version of ${package} (${${package}_VERSION_STRING}) has no configuration file or file is corrupted.")
			endif()
		endif()

		#here everything has been found => setting global standard CMake find process variables to adequate values
		set(${package}_FOUND TRUE CACHE INTERNAL "")
		set(${package}_ROOT_DIR ${PATH_TO_PACKAGE_VERSION} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_PACKAGES ${${PROJECT_NAME}_ALL_USED_PACKAGES} ${package} CACHE INTERNAL "")
		if(${package}_FIND_VERSION)
			if(${package}_FIND_VERSION_EXACT)
				set(${package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(${package}_REQUIRED_VERSION_EXACT "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}" CACHE INTERNAL "")
			else()
				set(${package}_ALL_REQUIRED_VERSIONS ${${package}_ALL_REQUIRED_VERSIONS} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}" CACHE INTERNAL "")
			endif()
		endif()

		#registering PID system version for that package
		include(${PATH_TO_PACKAGE_VERSION}/share/cmake/${package}_PID_VERSION.cmake OPTIONAL RESULT_VARIABLE res)#using the installed PID version file to know which version is used
		if(${res} STREQUAL NOTFOUND) #no bound to the package (maybe old package style before versionning)
			set(${package}_PID_VERSION 0 CACHE INTERNAL "")#default version is 0
		endif()

	else()#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(${package}_FIND_REQUIRED)
				if(${package}_FIND_VERSION)
          if(${package}_FIND_VERSION_PATCH)
					   add_To_Install_Package_Specification(${package} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}" ${${package}_FIND_VERSION_EXACT})
          else()
            add_To_Install_Package_Specification(${package} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}" ${${package}_FIND_VERSION_EXACT})
          endif()
        else()
					add_To_Install_Package_Specification(${package} "" FALSE)
				endif()
			endif()
		else()
			exitFindScript(${package} "[PID] ERROR when configuring ${PROJECT_NAME} : the package ${package} with version ${${package}_FIND_VERSION} cannot be found in the workspace.")
		endif()
	endif()
else() #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(${package}_FIND_REQUIRED)
			if(${package}_FIND_VERSION)
        if(${package}_FIND_VERSION_PATCH)
           add_To_Install_Package_Specification(${package} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}" ${${package}_FIND_VERSION_EXACT})
        else()
          add_To_Install_Package_Specification(${package} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}" ${${package}_FIND_VERSION_EXACT})
        endif()
			else()
				add_To_Install_Package_Specification(${package} "" FALSE)
			endif()
		endif()
	else()
		exitFindScript(${package} "[PID] ERROR when configuring ${PROJECT_NAME} : the required package ${package} cannot be found in the workspace.")
	endif()

endif()

endmacro(finding_Package)


##find script for external packages
# requires ${package}_PID_KNOWN_VERSION to be defined before calling this macro, set with at least one exact version (MAJOR.MINOR.PATCH)
# optionnaly ${package}_PID_KNOWN_VERSION_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO can be set to define which version (MAJOR.MINOR.PATCH) is no more compatible with ${version}. Can be done for any version defined as "known".
macro(finding_External_Package package)
set(${package}_FOUND FALSE CACHE INTERNAL "")
#workspace dir must be defined for each package build
set(EXTERNAL_PACKAGE_${package}_SEARCH_PATH
    ${EXTERNAL_PACKAGE_BINARY_INSTALL_DIR}/${package}
    CACHE
    INTERNAL
    "path to the package install dir containing versions of ${package} external package"
  )

check_Directory_Exists(EXIST ${EXTERNAL_PACKAGE_${package}_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions

	#variables that will be filled by generic functions
	if(${package}_FIND_VERSION)
		if(${package}_FIND_VERSION_EXACT) #using a specific version
			check_External_Exact_Version(VERSION_TO_USE ${package} ${EXTERNAL_PACKAGE_${package}_SEARCH_PATH} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}")
		else() #using the best version as regard of version constraints
			check_External_Minimum_Version(VERSION_TO_USE ${package} ${EXTERNAL_PACKAGE_${package}_SEARCH_PATH} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}")
		endif()
	else() #no specific version targetted using last available version (takes the last version available)
		check_External_Last_Version(VERSION_TO_USE ${package} ${EXTERNAL_PACKAGE_${package}_SEARCH_PATH})
	endif()
	if(VERSION_TO_USE)#a good version of the package has been found
		set(${package}_FOUND TRUE CACHE INTERNAL "")
		set(${package}_ROOT_DIR ${EXTERNAL_PACKAGE_${package}_SEARCH_PATH}/${VERSION_TO_USE} CACHE INTERNAL "")
		include(${${package}_ROOT_DIR}/share/Use${package}-${VERSION_TO_USE}.cmake  OPTIONAL)#using the generated Use<package>-<version>.cmake file to get adequate version information about components
		#add the undirectly used packages as well
		set(LIST_OF_EXTS ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES} ${package})
		if(LIST_OF_EXTS)
			list(REMOVE_DUPLICATES LIST_OF_EXTS)
		endif()
		set(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES ${LIST_OF_EXTS} CACHE INTERNAL "")

		if(${package}_FIND_VERSION)
			if(${package}_FIND_VERSION_EXACT)
				set(${package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(${package}_REQUIRED_VERSION_EXACT "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}" CACHE INTERNAL "")
			else()
				set(${package}_ALL_REQUIRED_VERSIONS ${${package}_ALL_REQUIRED_VERSIONS} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}" CACHE INTERNAL "")
			endif()
		endif()
	else()#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(${package}_FIND_REQUIRED)
				if(${package}_FIND_VERSION)
					if(${package}_FIND_VERSION_EXACT)
						set(is_exact TRUE)
					else()
						set(is_exact FALSE)
					endif()
					add_To_Install_External_Package_Specification(${package} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}" ${is_exact})
				else()
					add_To_Install_External_Package_Specification(${package} "" FALSE)
				endif()
			endif()
		else()
			exitFindScript(${package} "[PID] ERROR : the required version(${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}) of external package ${package} cannot be found in the workspace.")
		endif()
	endif()

else() #if the directory does not exist it means the external package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(${package}_FIND_REQUIRED)
			if(${package}_FIND_VERSION)
				add_To_Install_External_Package_Specification(${package} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}" ${${package}_FIND_VERSION_EXACT})
			else()
				add_To_Install_External_Package_Specification(${package} "" FALSE)
			endif()
		endif()
	else()
		exitFindScript(${package} "[PID] ERROR : the required external package ${package} cannot be found in the workspace.")
	endif()

endif()

endmacro(finding_External_Package)
