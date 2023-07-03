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
### auxiliary macro to resove resolve path to find files and call find_package ###
##################################################################################


#.rst:
#
# .. ifmode:: internal
#
#  .. |find_package_resolved| replace:: ``find_package_resolved``
#  .. _find_package_resolved:
#
#  find_package_resolved
#  ---------------------
#
#   .. command:: find_package_resolved(deployment_unit ...)
#
#    Do a find_package only if the find file is known in workspace. May update contribution spaces if file is unknown.
#
#     :deployment_unit: the name of the deployment unit to find.
#     :...: other arguments to pass to find_package
#
macro(find_package_resolved deployment_unit)
  resolve_Path_To_Find_File(PATH_KNOWN ${deployment_unit})
  if(PATH_KNOWN)
    find_package(${deployment_unit} ${ARGN})
  endif()
  set(PATH_KNOWN)
endmacro(find_package_resolved)

##################################################################################
##################auxiliary functions to check package version####################
##################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Version_Strings| replace:: ``set_Version_Strings``
#  .. _set_Version_Strings:
#
#  set_Version_Strings
#  -------------------
#
#   .. command:: set_Version_Strings(package_name major minor patch)
#
#    Create the cache variables used to manage the version of a package/
#
#     :package: the name of the package.
#     :major: the major version number
#     :minor: the minor version number
#     :patch: the patch version number
#
function (set_Version_Strings package major minor patch)
	set(${package}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set(${package}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set(${package}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set(${package}_VERSION_STRING "${major}.${minor}.${patch}" CACHE INTERNAL "")
	set(${package}_VERSION_RELATIVE_PATH "${major}.${minor}.${patch}" CACHE INTERNAL "")
endfunction(set_Version_Strings)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Version_Strings| replace:: ``reset_Version_Strings``
#  .. _reset_Version_Strings:
#
#  reset_Version_Strings
#  ---------------------
#
#   .. command:: reset_Version_Strings(package)
#
#    Reset cache variables used to manage the version of a package
#
#
#     :package: the name of the package.
#
function (reset_Version_Strings package)
	unset(${package}_VERSION_MAJOR CACHE)
	unset(${package}_VERSION_MINOR CACHE)
	unset(${package}_VERSION_PATCH CACHE)
	unset(${package}_VERSION_STRING CACHE)
	unset(${package}_VERSION_RELATIVE_PATH CACHE)
endfunction(reset_Version_Strings)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Version_Strings_Recursive| replace:: ``reset_Version_Strings_Recursive``
#  .. _reset_Version_Strings_Recursive:
#
#  reset_Version_Strings_Recursive
#  -------------------------------
#
#   .. command:: reset_Version_Strings_Recursive(package)
#
#    Reset cache variables memorizing versions for a package and its dependencies
#
#
#     :package: the name of the package.
#
function (reset_Version_Strings_Recursive package)
	reset_Version_Strings(${package})
	foreach(dep_package IN LISTS ${package}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
		reset_Version_Strings_Recursive(${dep_package})
	endforeach()
	foreach(dep_package IN LISTS ${package}_DEPENDENCIES${USE_MODE_SUFFIX})
		reset_Version_Strings_Recursive(${dep_package})
	endforeach()
endfunction(reset_Version_Strings_Recursive)


#.rst:
#
# .. ifmode:: internal
#
#  .. |set_External_Version_Strings| replace:: ``set_External_Version_Strings``
#  .. _set_External_Version_Strings:
#
#  set_External_Version_Strings
#  ----------------------------
#
#   .. command:: set_External_Version_Strings(package version)
#
#    Create the cache variables used to manage the version of an external package
#
#     :package: the name of the external package.
#     :version: the version string for the package.
#
function (set_External_Version_Strings package version)
	set(${package}_VERSION_STRING "${version}" CACHE INTERNAL "")
	set(${package}_VERSION_RELATIVE_PATH "${version}" CACHE INTERNAL "")
endfunction(set_External_Version_Strings)

#.rst:
#
# .. ifmode:: internal
#
#  .. |select_Exact_Native_Version| replace:: ``select_Exact_Native_Version``
#  .. _select_Exact_Native_Version:
#
#  select_Exact_Native_Version
#  ---------------------------
#
#   .. command:: select_Exact_Native_Version(RES_VERSION minimum_version available_versions)
#
#    Select the exact compatible version among a list of versions, considering that the policy is native: major and minor number must be respected while patch number can be adapted (max patch available is used).
#
#     :minimum_version: the exact version to match.
#     :available_versions: the list of versions.
#
#     :RES_VERSION: the output variable containing the exact version chosen in the list, or empty if none compatible.
#
function(select_Exact_Native_Version RES_VERSION minimum_version available_versions)
get_Version_String_Numbers(${minimum_version} MAJOR MINOR PATCH)
if(NOT DEFINED MAJOR)#not a valid version string
  set(${RES_VERSION} PARENT_SCOPE)
endif()
if(DEFINED PATCH)
	set(curr_max_patch_number ${PATCH})
  foreach(version IN LISTS available_versions)
    if(version VERSION_EQUAL minimum_version)
      set(${RES_VERSION} ${version} PARENT_SCOPE)
      return()
    endif()
  endforeach()
  set(${RES_VERSION} PARENT_SCOPE)
else() #if patch not defined use same pattern as for minor version
  set(version_found FALSE)
	set(curr_max_patch_number -1)
  foreach(version IN LISTS available_versions)
  	get_Version_String_Numbers("${version}" COMPARE_MAJOR COMPARE_MINOR COMPARE_PATCH)
    if(	COMPARE_MAJOR EQUAL MAJOR
  		AND COMPARE_MINOR EQUAL MINOR
      AND (NOT COMPARE_PATCH LESS curr_max_patch_number)) # COMPARE_PATCH >= current patch
  		set(curr_max_patch_number ${COMPARE_PATCH})# taking the last patch version available for this major.minor
      set(version_found TRUE)
    endif()
  endforeach()

  if(NOT version_found)
  	set(${RES_VERSION} PARENT_SCOPE)
  else()
  	set(${RES_VERSION} "${MAJOR}.${MINOR}.${curr_max_patch_number}" PARENT_SCOPE)
  endif()
endif()

endfunction(select_Exact_Native_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |select_Exact_External_Version| replace:: ``select_Exact_External_Version``
#  .. _select_Exact_External_Version:
#
#  select_Exact_External_Version
#  -----------------------------
#
#   .. command:: select_Exact_External_Version(RES_VERSION exact_version available_versions)
#
#    Select the exact compatible version among a list of versions, considering that the policy is external: major minor and patch numbers must be respected. Simply consists in returning the version value if it exists in the list.
#
#     :exact_version: the exact version to match.
#     :available_versions: the list of versions.
#
#     :RES_VERSION: the output variable containing the exact version chosen in the list.
#
function(select_Exact_External_Version RES_VERSION exact_version available_versions)
foreach(version IN LISTS available_versions)
	if(version VERSION_EQUAL exact_version)
		set(${RES_VERSION} ${version} PARENT_SCOPE)
		return()
	endif()
endforeach()
set(${RES_VERSION} PARENT_SCOPE)
endfunction(select_Exact_External_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |select_Best_Native_Version| replace:: ``select_Best_Native_Version``
#  .. _select_Best_Native_Version:
#
#  select_Best_Native_Version
#  --------------------------
#
#   .. command:: select_Best_Native_Version(RES_VERSION exact_version available_versions)
#
#    Select the best compatible version among a list of versions, considering that the policy is native: major.minor must match, while greatest patch from this minor is used.
#
#     :minimum_version: the minimum version to match.
#     :available_versions: the list of versions.
#
#     :RES_VERSION: the output variable containing the best version chosen in the list.
#
function(select_Best_Native_Version RES_VERSION minimum_version available_versions)
get_Version_String_Numbers(${minimum_version} MAJOR MINOR PATCH)
if(NOT DEFINED MAJOR)#not a valid version string
  set(${RES_VERSION} PARENT_SCOPE)
endif()
set(curr_major -1)
set(curr_minor -1)
set(curr_patch -1)

if(NOT DEFINED MINOR)
	set(target_min_minor 0)
else()
	set(target_min_minor ${MINOR})
endif()
if(NOT DEFINED PATCH)
	set(target_min_patch 0)
else()
	set(target_min_patch ${PATCH})
endif()

foreach(version IN LISTS available_versions)
	get_Version_String_Numbers("${version}" COMPARE_MAJOR COMPARE_MINOR COMPARE_PATCH)
	if(COMPARE_MAJOR EQUAL MAJOR)# major version mutch exactly match
		if(COMPARE_MINOR EQUAL target_min_minor) # perfect matching
			# we need to check that minimum patch required is OK
      		if (COMPARE_PATCH GREATER_EQUAL target_min_patch)#do not use GREATER as if a patch version is defined we can be in a situation where PATCH=PATCH and curr_major has never been set
			  if(COMPARE_PATCH GREATER curr_patch)#take the highest possible patch with the closest version to minimum_version
					set(curr_major ${MAJOR})
					set(curr_minor ${MINOR})
					set(curr_patch ${COMPARE_PATCH})# taking the newest patch version for the current major.minor
				endif()
			endif()
		elseif(COMPARE_MINOR GREATER target_min_minor) # unperfect matching
			if(curr_minor EQUAL -1)#no solution found yet
				# take this version
				set(curr_major ${MAJOR})
				set(curr_minor ${COMPARE_MINOR})
				set(curr_patch ${COMPARE_PATCH})# taking the newest patch version for the current major.minor
			elseif(COMPARE_MINOR LESS curr_minor)# a solution  has already been found and this one has a lower minor version
				#a previous minor version has been taken into account but is was also unperfect
				#but this new minor is "closer" to the minimum required
				set(curr_minor ${COMPARE_MINOR})
				set(curr_patch ${COMPARE_PATCH})# taking the newest patch version for the current major.minor
			elseif(COMPARE_MINOR EQUAL curr_minor)# a solution  has already been found with same minor version
				if(COMPARE_PATCH GREATER curr_patch) #current version has a greater patch version -> use it
					set(curr_patch ${COMPARE_PATCH})# taking the newest patch version for the current major.minor
				endif()
				#same 
			endif()
    	endif()
	endif()
endforeach()
if(curr_patch EQUAL -1 OR curr_major EQUAL -1 OR curr_minor EQUAL -1)#i.e. nothing found
	set(${RES_VERSION} PARENT_SCOPE)
else()
	set(${RES_VERSION} "${curr_major}.${curr_minor}.${curr_patch}" PARENT_SCOPE)
endif()
endfunction(select_Best_Native_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |select_Best_External_Version| replace:: ``select_Best_External_Version``
#  .. _select_Best_External_Version:
#
#  select_Best_External_Version
#  ----------------------------
#
#   .. command:: select_Best_External_Version(RES_VERSION package minimum_version available_versions)
#
#    Select the best compatible version among a list of versions, considering that the policy is external: any version explicitly declared as compatible by the external package can be used instead.
#
#     :package: the name of target external package.
#     :minimum_version: the minimum version to match.
#     :available_versions: the list of versions.
#
#     :RES_VERSION: the output variable containing the best version chosen in the list.
#
function(select_Best_External_Version RES_VERSION package minimum_version available_versions)
foreach(version IN LISTS available_versions)
	if(version VERSION_GREATER_EQUAL minimum_version)#only greater or equal versions are feasible
		if(DEFINED ${package}_PID_KNOWN_VERSION_${minimum_version}_GREATER_VERSIONS_COMPATIBLE_UP_TO)#if not defined the version is compatible with nothing
			if(	highest_version )#if a compatible highest version is already found
					if(version VERSION_GREATER highest_version #the new version must be greater to be interesting
						AND version VERSION_LESS "${${package}_PID_KNOWN_VERSION_${minimum_version}_GREATER_VERSIONS_COMPATIBLE_UP_TO}")#but it also has to be compatible
						set(highest_version ${version})
					endif()
			elseif(version VERSION_LESS "${${package}_PID_KNOWN_VERSION_${minimum_version}_GREATER_VERSIONS_COMPATIBLE_UP_TO}")#if no highest compatible version found, simply check that the version is compatible
				set(highest_version ${version})#if highest not set, set ot for thr first time
			endif()
		elseif(version VERSION_EQUAL minimum_version)#no compatible version defined, only the exact version can be used
				set(highest_version ${version})
		endif()
	endif()
endforeach()
set(${RES_VERSION} ${highest_version} PARENT_SCOPE)
endfunction(select_Best_External_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |select_Last_Version| replace:: ``select_Last_Version``
#  .. _select_Last_Version:
#
#  select_Last_Version
#  -------------------
#
#   .. command:: select_Last_Version(RES_VERSION available_versions)
#
#    Select the greatest version among a list of versions.
#
#     :available_versions: the list of versions.
#     :RES_VERSION: the output variable containing the best version chosen in the list.
#
function(select_Last_Version RES_VERSION available_versions)
set(curr_version 0.0.0)
foreach(version IN LISTS available_versions)
	if(curr_version VERSION_LESS version)
		set(curr_version ${version})
	endif()
endforeach()

if(curr_version VERSION_EQUAL "0.0.0")#i.e. nothing found
	set(${RES_VERSION} PARENT_SCOPE)
else()
	set(${RES_VERSION} "${curr_version}" PARENT_SCOPE)
endif()
endfunction(select_Last_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Exact_Version| replace:: ``check_Exact_Version``
#  .. _check_Exact_Version:
#
#  check_Exact_Version
#  -------------------
#
#   .. command:: check_Exact_Version(VERSION_FOUND package install_dir major minor patch)
#
#    Check whether there is a compatible exact version of the package installed in the workspace, considering the native policy (any  version with greater patch number is valid).
#
#     :package: the name of package to check.
#     :install_dir: the path to package install folder.
#     :major: the major number of version.
#     :minor: the minor number of version.
#     :patch: the patch number of version.
#
#     :VERSION_FOUND: the output variable that contains the compatible version if it exists, empty otherwise.
#
function (check_Exact_Version VERSION_FOUND package install_dir major minor patch) #minor version cannot be increased but patch version can
set(${VERSION_FOUND} FALSE PARENT_SCOPE)
list_Version_Subdirectories(version_dirs ${install_dir})
if(version_dirs)#seaking for a good version only if there are versions installed
	if(patch)
		set(curr_patch_version ${patch})
	else()#no preliminary contraints applies to version
		set(curr_patch_version 0)
	endif()
	update_Package_Installed_Version(${package} ${major} ${minor} "${patch}" true "${version_dirs}" "${BUILD_RELEASE_ONLY}")#updating only if there are installed versions
	foreach(version IN LISTS version_dirs)
		if(version MATCHES "^${major}\\.${minor}\\.([0-9]+)$")
			if(CMAKE_MATCH_1 GREATER_EQUAL curr_patch_version) #=minor >= patch
				set(result TRUE)
				#a more recent patch version found with same minor version
				set(curr_patch_version ${CMAKE_MATCH_1})
			endif()
		endif()
	endforeach()

	if(result)#at least a good version has been found
		set(${VERSION_FOUND} TRUE PARENT_SCOPE)
		set_Version_Strings(${package} ${major} ${minor} ${curr_patch_version})
		return()
	endif()
endif()
endfunction(check_Exact_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Best_Version| replace:: ``check_Best_Version``
#  .. _check_Best_Version:
#
#  check_Best_Version
#  ------------------
#
#   .. command:: check_Best_Version(VERSION_FOUND package install_dir major minor patch)
#
#    Check whether there is a compatible version of the package installed in the workspace, considering the native policy: any version with greater minor is valid.
#    The patch argument is used only if =major and =minor is found.
#
#     :package: the name of package to check.
#     :install_dir: the path to package install folder.
#     :major: the major number of version.
#     :minor: the minor number of version.
#     :patch: the patch number of version.
#
#     :VERSION_FOUND: the output variable that contains the compatible version if it exists, empty otherwise.
#
function(check_Best_Version VERSION_FOUND package install_dir major minor patch)#major version cannot be increased
set(${VERSION_FOUND} FALSE PARENT_SCOPE)
list_Version_Subdirectories(version_dirs ${install_dir})
if(version_dirs)#seaking for a good version only if there are versions installed
  if(patch)
    set(curr_patch_version ${patch})
  else()#no preliminary contraints applies to version
    set(curr_patch_version 0)
  endif()
  update_Package_Installed_Version(${package} ${major} ${minor} "${patch}" false "${version_dirs}" "${BUILD_RELEASE_ONLY}")#updating only if there are installed versions
  set(exact_minor_found FALSE)
  set(curr_minor 99999)#stupidly high number ~= MAX value
  foreach(version IN LISTS version_dirs)
		if(version MATCHES "^${major}\\.${minor}\\.([0-9]+)$")
			if(CMAKE_MATCH_1 GREATER_EQUAL curr_patch_version) #=minor AND >= patch
				set(result TRUE)
				#a more recent patch version found with same minor version
				set(curr_patch_version ${CMAKE_MATCH_1})
				set(exact_minor_found TRUE)
				set(curr_minor ${minor})
			endif()
		elseif(NOT exact_minor_found
				AND version MATCHES "^${major}\\.([0-9]+)\\.([0-9]+)$")
				if(CMAKE_MATCH_1 GREATER ${minor}) #it is binary compatible
					if(CMAKE_MATCH_1 LESS curr_minor)#closer to the required version
						set(curr_minor ${CMAKE_MATCH_1})
						set(curr_patch_version ${CMAKE_MATCH_2})
						set(result TRUE)
					elseif(CMAKE_MATCH_1 EQUAL curr_minor #if as close as previously in terms of available features
							AND CMAKE_MATCH_2 GREATER curr_patch_version)#but a more recent version with bug fixes
						set(curr_patch_version ${CMAKE_MATCH_2})
					endif()
				endif()
		endif()
	endforeach()
	if(result)#at least a good version has been found
		set(${VERSION_FOUND} TRUE PARENT_SCOPE)
		set_Version_Strings(${package} ${major} ${curr_minor} ${curr_patch_version})
	endif()
endif()
endfunction(check_Best_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Last_Version| replace:: ``check_Last_Version``
#  .. _check_Last_Version:
#
#  check_Last_Version
#  ------------------
#
#   .. command:: check_Last_Version(VERSION_FOUND package install_dir)
#
#    Check whether there is a version of the package installed in the workspace and take the one with greatest number.
#
#     :package: the name of package to check.
#     :install_dir: the path to package install folder.
#
#     :VERSION_FOUND: the output variable that contains the version if any, empty otherwise.
#
function(check_Last_Version VERSION_FOUND package install_dir)#taking local version or the most recent if not available
set(${VERSION_FOUND} FALSE PARENT_SCOPE)
list_Version_Subdirectories(local_versions ${install_dir})
if(local_versions)#seaking for a good version only if there are versions installed
	update_Package_Installed_Version(${package} "" "" "" false "${local_versions}" "${BUILD_RELEASE_ONLY}")#updating only if there are installed versions
	set(version_string_curr "0.0.0")
	foreach(local_version_dir IN LISTS local_versions)
		if(version_string_curr VERSION_LESS local_version_dir)
			set(version_string_curr ${local_version_dir})
		endif()
	endforeach()
	get_Version_String_Numbers(${version_string_curr} major minor patch)
  set(${VERSION_FOUND} TRUE PARENT_SCOPE)
  set_Version_Strings(${package} ${major} ${minor} ${patch})
endif()
endfunction(check_Last_Version)

###########################################################################################
################# auxiliary functions to check external package version ###################
###########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_External_Minimum_Version| replace:: ``check_External_Minimum_Version``
#  .. _check_External_Minimum_Version:
#
#  check_External_Minimum_Version
#  ------------------------------
#
#   .. command:: check_External_Minimum_Version(VERSION_FOUND package search_path version)
#
#    Check whether there is a compatible version of the external package installed in the workspace, considering the external policy: any older version declared as compatible with this one is eligible.
#
#     :package: the name of package to check.
#     :search_path: the path to external package install folder.
#     :version: the version number to check.
#
#     :VERSION_FOUND: the output variable that contains the compatible version if it exists, empty otherwise.
#
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
		set_External_Version_Strings(${package} ${highest_version})
	endif()
endif()
endfunction(check_External_Minimum_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_External_Last_Version| replace:: ``check_External_Last_Version``
#  .. _check_External_Last_Version:
#
#  check_External_Last_Version
#  ---------------------------
#
#   .. command:: check_External_Last_Version(VERSION_FOUND package search_path)
#
#    Check whether there is a version of the external package installed in the workspace and take the greatest one.
#
#     :package: the name of package to check.
#     :search_path: the path to external package install folder.
#
#     :VERSION_FOUND: the output variable that contains the greatest version if any exists, empty otherwise.
#
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
		set_External_Version_Strings(${package} ${highest_version})
	endif()
endif()
endfunction(check_External_Last_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_External_Exact_Version| replace:: ``check_External_Exact_Version``
#  .. _check_External_Exact_Version:
#
#  check_External_Exact_Version
#  ----------------------------
#
#   .. command:: check_External_Exact_Version(VERSION_FOUND package search_path version)
#
#    Check whether there is an exact version of the external package installed in the workspace (n adaptation of version allowed).
#
#     :package: the name of package to check.
#     :search_path: the path to external package install folder.
#     :version: the version number to check.
#
#     :VERSION_FOUND: the output variable that contains the exact version if it exists, empty otherwise.
#
function(check_External_Exact_Version VERSION_FOUND package search_path version)
set(${VERSION_FOUND} PARENT_SCOPE)
list_Version_Subdirectories(VERSION_DIRS ${search_path})
if(VERSION_DIRS)
	list(FIND VERSION_DIRS ${version} INDEX)
	if(INDEX EQUAL -1)
		return()
	endif()
	set(${VERSION_FOUND} ${version} PARENT_SCOPE)
	set_External_Version_Strings(${package} ${version})
endif()
endfunction(check_External_Exact_Version)

#########################################################################################################
################## auxiliary functions to check components info (native packages only) ##################
#########################################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Component_Elements_Exist| replace:: ``check_Component_Elements_Exist``
#  .. _check_Component_Elements_Exist:
#
#  check_Component_Elements_Exist
#  ------------------------------
#
#   .. command:: check_Component_Elements_Exist(COMPONENT_ELEMENT_NOTFOUND package_path package component)
#
#    Check whether all elements (headers binary, etc.) bound to a given component (belonging to a given package) exist in workspace.
#
#     :search_path: the path to external package install folder.
#     :package: the name of package to check.
#     :component: the name of the target component.
#
#     :COMPONENT_ELEMENT_NOTFOUND: the output variable that is TRUE if an element of the component has not been found, TRUE otherwise.
#
function(check_Component_Elements_Exist COMPONENT_ELEMENT_NOTFOUND search_path package component)
set(${COMPONENT_ELEMENT_NOTFOUND} TRUE PARENT_SCOPE)
if(NOT DEFINED ${package}_${component}_TYPE)#type of the component must be defined
	return()
endif()

list(FIND ${package}_COMPONENTS_APPS ${component} idx)
if(idx EQUAL -1)#the component is NOT an application
	list(FIND ${package}_COMPONENTS_LIBS ${component} idx)
	if(idx EQUAL -1)#the component is NOT a library either
		return() #ERROR
	else()#the component is a library
		#for a lib checking headers and then binaries
		if(DEFINED ${package}_${component}_HEADERS)#a library must have HEADERS defined otherwise ERROR
			#checking existence of all its exported headers
			foreach(header IN LISTS ${package}_${component}_HEADERS)
				find_file(PATH_TO_HEADER NAMES ${header} PATHS ${search_path}/include/${${package}_${component}_HEADER_DIR_NAME} NO_DEFAULT_PATH)
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
		if(	${${package}_${component}_TYPE} STREQUAL "STATIC"
			OR ${${package}_${component}_TYPE} STREQUAL "SHARED"
    OR ${${package}_${component}_TYPE} STREQUAL "MODULE")
			#checking release and debug binaries (at least one is required)
			find_library(	PATH_TO_LIB
					NAMES ${${package}_${component}_BINARY_NAME} ${${package}_${component}_BINARY_NAME_DEBUG}
					PATHS ${search_path}/lib NO_DEFAULT_PATH)
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
	if("${${package}_${component}_TYPE}" STREQUAL "APP")
		#now checking for binary
		find_program(	PATH_TO_EXE
				NAMES ${${package}_${component}_BINARY_NAME} ${${package}_${component}_BINARY_NAME_DEBUG}
				PATHS ${search_path}/bin NO_DEFAULT_PATH)
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |all_Components| replace:: ``all_Components``
#  .. _all_Components:
#
#  all_Components
#  --------------
#
#   .. command:: all_Components(FILE_NOTFOUND package version search_path)
#
#    Check all components of a given package, to verify that all their elements (header, binary) exist.
#
#     :package: the name of package to check.
#     :version: version of the package.
#     :search_path: the path to package install folder.
#
#     :FILE_NOTFOUND: the output variable that is TRUE if the use file of package version has not been found.
#
function (all_Components FILE_NOTFOUND package version search_path)
set(${FILE_NOTFOUND} FALSE PARENT_SCOPE)
reset_Native_Package_Dependency_Cached_Variables_From_Use(${package} ${CMAKE_BUILD_TYPE} FALSE)#NOTE: no recursion, only clean info local to used package
include(${search_path}/share/Use${package}-${version}.cmake  OPTIONAL RESULT_VARIABLE res)#using the generated Use<package>-<version>.cmake file to get adequate version information about components
if(	${res} STREQUAL NOTFOUND
	OR NOT DEFINED ${package}_COMPONENTS) #if there is no component defined for the package there is an error
	set(${FILE_NOTFOUND} TRUE PARENT_SCOPE)
	return()
endif()
foreach(a_component IN LISTS ${package}_COMPONENTS)
  set(${package}_${a_component}_FOUND TRUE CACHE INTERNAL "")
	check_Component_Elements_Exist(COMPONENT_ELEMENT_NOTFOUND ${search_path} ${package} ${a_component})
	if(COMPONENT_ELEMENT_NOTFOUND)
		set(${package}_${a_component}_FOUND FALSE CACHE INTERNAL "")
	endif()
endforeach()
endfunction(all_Components)

#.rst:
#
# .. ifmode:: internal
#
#  .. |select_Components| replace:: ``select_Components``
#  .. _select_Components:
#
#  select_Components
#  -----------------
#
#   .. command:: select_Components(FILE_NOTFOUND ALL_COMPONENTS_FOUND package version search_path list_of_components)
#
#    Check that the given components of a given package. It verifies that all their elements (header, binary) exist.
#
#     :package: the name of package to check.
#     :version: version of the package.
#     :search_path: the path to package install folder.
#     :list_of_components: the list of components to specifically check.
#
#     :FILE_NOTFOUND: the output variable that is TRUE if the use file of package version has not been found.
#     :ALL_COMPONENTS_FOUND: the output variable that is TRUE if all required components have been found.
#
function (select_Components FILE_NOTFOUND ALL_COMPONENTS_FOUND package version search_path list_of_components)
set(${FILE_NOTFOUND} FALSE PARENT_SCOPE)
set(${ALL_COMPONENTS_FOUND} TRUE PARENT_SCOPE)
reset_Native_Package_Dependency_Cached_Variables_From_Use(${package} ${CMAKE_BUILD_TYPE} FALSE)#NOTE: no recursion, only clean info local to used package
include(${search_path}/share/Use${package}-${version}.cmake OPTIONAL RESULT_VARIABLE res)#using the generated Use<package>-<version>.cmake file to get adequate version information about components
if(${res} STREQUAL NOTFOUND)
	set(${FILE_NOTFOUND} TRUE PARENT_SCOPE)
	return()
endif()

if(NOT DEFINED ${package}_COMPONENTS)#if there is no component defined for the package there is an error
	set(${FILE_NOTFOUND} TRUE PARENT_SCOPE)
	return()
endif()

#checking that all requested components trully exist for this version
foreach(requested_component IN LISTS list_of_components)
	list(FIND ${package}_COMPONENTS ${requested_component} idx)
	if(idx EQUAL -1)#component has not been found
		set(${package}_${requested_component}_FOUND FALSE  CACHE INTERNAL "")
		if(${${package}_FIND_REQUIRED_${requested_component}})
			set(${ALL_COMPONENTS_FOUND} FALSE PARENT_SCOPE)
		endif()
	else()#component found
		check_Component_Elements_Exist(COMPONENT_ELEMENT_NOTFOUND ${search_path} ${package} ${requested_component})
		if(COMPONENT_ELEMENT_NOTFOUND)
			set(${package}_${requested_component}_FOUND FALSE  CACHE INTERNAL "")
		else()
			set(${package}_${requested_component}_FOUND TRUE  CACHE INTERNAL "")
		endif()
	endif()
endforeach()
endfunction(select_Components)


#########################################################################################################
######################### auxiliary functions to check version info (native packages) ###################
#########################################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Exact_Version_Compatible_With_Previous_Constraints| replace:: ``is_Exact_Version_Compatible_With_Previous_Constraints``
#  .. _is_Exact_Version_Compatible_With_Previous_Constraints:
#
#  is_Exact_Version_Compatible_With_Previous_Constraints
#  -----------------------------------------------------
#
#   .. command:: is_Exact_Version_Compatible_With_Previous_Constraints(IS_COMPATIBLE NEED_FINDING package version)
#
#    Check if an exact version is compatible with previous version contrainsts that apply to the current build. This function is used during dependencies version resolutionn process.
#
#     :package: the name of package to check.
#     :version: version of the package.
#
#     :IS_COMPATIBLE: the output variable that is TRUE if the version is compatible, FALSE otherwise.
#     :NEED_FINDING: the output variable that is TRUE if the exact version needs to be find.
#
function(is_Exact_Version_Compatible_With_Previous_Constraints IS_COMPATIBLE NEED_FINDING package version)

set(${IS_COMPATIBLE} FALSE PARENT_SCOPE)
set(${NEED_FINDING} FALSE PARENT_SCOPE)
if(${package}_REQUIRED_VERSION_EXACT)
	get_Version_String_Numbers("${${package}_REQUIRED_VERSION_EXACT}" exact_major exact_minor exact_patch)
	if(NOT DEFINED exact_major)#not a valid version string
		return()
	endif()
	is_Exact_Compatible_Version(COMPATIBLE_VERSION ${exact_major} ${exact_minor} ${version})
	if(NOT COMPATIBLE_VERSION)#not compatible if versions are not the same major.minor
		return()
	endif()
		set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)
	return()
endif()
#no exact version required
get_Version_String_Numbers("${version}" exact_major exact_minor exact_patch)
if(NOT exact_major)#not a valid version string
  return()
endif()
foreach(version_required IN LISTS ${package}_ALL_REQUIRED_VERSIONS)
	unset(COMPATIBLE_VERSION)
	is_Compatible_Version(COMPATIBLE_VERSION ${exact_major} ${exact_minor} ${version_required})
	if(NOT COMPATIBLE_VERSION)
		return()#not compatible
	endif()
endforeach()

set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)
if(NOT ${package}_VERSION_STRING VERSION_EQUAL version)
	set(${NEED_FINDING} TRUE PARENT_SCOPE) #need to find the new exact version
endif()
endfunction(is_Exact_Version_Compatible_With_Previous_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Version_Compatible_With_Previous_Constraints| replace:: ``is_Version_Compatible_With_Previous_Constraints``
#  .. _is_Version_Compatible_With_Previous_Constraints:
#
#  is_Version_Compatible_With_Previous_Constraints
#  -----------------------------------------------
#
#   .. command:: is_Version_Compatible_With_Previous_Constraints(IS_COMPATIBLE VERSION_TO_FIND package version)
#
#    Check if a version is compatible with previous version contrainsts that apply to the current build. This function is used during dependencies version resolutionn process.
#
#     :package: the name of package to check.
#     :version: version of the package.
#
#     :IS_COMPATIBLE: the output variable that is TRUE if the version is compatible, FALSE otherwise.
#     :VERSION_TO_FIND: the output variable that contains the version that needs to be find.
#
function(is_Version_Compatible_With_Previous_Constraints IS_COMPATIBLE VERSION_TO_FIND package version)

set(${IS_COMPATIBLE} FALSE PARENT_SCOPE)
# 1) testing compatibility and recording the higher constraint for minor version number
if(${package}_REQUIRED_VERSION_EXACT)
	get_Version_String_Numbers("${${package}_REQUIRED_VERSION_EXACT}.0" exact_major exact_minor exact_patch)
  if(NOT DEFINED exact_major)#not a valid version string
    return()
  endif()
  is_Compatible_Version(COMPATIBLE_VERSION ${exact_major} ${exact_minor} ${version})
	if(COMPATIBLE_VERSION)
		set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)
	endif()
	return()#no need to set the version to find
endif()
get_Version_String_Numbers("${version}.0" new_major new_minor new_patch)
if(NOT new_major AND NOT new_major EQUAL 0)#not a valid version string
  return()
endif()
set(curr_major ${new_major})
set(curr_max_minor ${new_minor})
foreach(version_required IN LISTS ${package}_ALL_REQUIRED_VERSIONS)
	get_Version_String_Numbers("${version_required}.0" required_major required_minor required_patch)
	if(NOT required_major EQUAL curr_major)
		return()#not compatible since the new version has a greater major version number
	elseif(required_minor GREATER curr_max_minor)
		set(curr_max_minor ${required_minor})
	endif()
endforeach()
set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)

# 2) now we have the greater constraint
set(max_version_constraint "${curr_major}.${curr_max_minor}")
if(${package}_VERSION_STRING VERSION_LESS_EQUAL ${max_version_constraint})
	set(${VERSION_TO_FIND} ${max_version_constraint} PARENT_SCOPE) #need to find the new version
endif()
endfunction(is_Version_Compatible_With_Previous_Constraints)


#########################################################################################################
####################### auxiliary functions to check version info (external packages) ###################
#########################################################################################################

### function used to check the compatibility between two versions of an external package

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Compatible_External_Version| replace:: ``is_Compatible_External_Version``
#  .. _is_Compatible_External_Version:
#
#  is_Compatible_External_Version
#  ------------------------------
#
#   .. command:: is_Compatible_External_Version(IS_COMPATIBLE package reference_version version_to_compare)
#
#    Check if a version of the given external package is compatible with a reference version. This compatibility is deduced from explicit declaration of compatibility in external packages.
#
#     :package: the name of package to check.
#     :reference_version: the reference version of the package.
#     :version_to_compare: version of the package to compare with reference version to know whether one can use it instead of reference_version.
#
#     :IS_COMPATIBLE: the output variable that is TRUE if the version is compatible, FALSE otherwise.
#
function(is_Compatible_External_Version IS_COMPATIBLE package reference_version version_to_compare)
  set(${IS_COMPATIBLE} FALSE PARENT_SCOPE)
  if(reference_version VERSION_EQUAL version_to_compare)
    set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)#same versions so they are compatible
    return()
  endif()
  if(${package}_PID_KNOWN_VERSION_${reference_version}_GREATER_VERSIONS_COMPATIBLE_UP_TO) #there are known versions that are compatible with reference version
    if(${package}_PID_KNOWN_VERSION_${reference_version}_GREATER_VERSIONS_COMPATIBLE_UP_TO VERSION_GREATER version_to_compare #the first incompatible version with reference_version is greater than version_to_compare
      AND version_to_compare VERSION_GREATER reference_version)# version_to_compare is greater than reference_version
  		set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)
  	endif()
  endif()
endfunction(is_Compatible_External_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Compatible_Version| replace:: ``get_Compatible_Version``
#  .. _get_Compatible_Version:
#
#  get_Compatible_Version
#  ----------------------
#
#   .. command:: get_Compatible_Version(RES_VERSION_TO_USE external package version_in_use version_in_use_is_exact version_in_use_is_system version_to_test version_to_test_is_exact version_to_test_is_system)
#
#    From a version constraint of a given package already used in the build process, test if another version constraint is compatible with this one.
#
#     :external: if TRUE the package to check is an external package.
#     :package: the name of package to check.
#     :version_in_use: the version constraint of package, already used in the current build process.
#     :version_in_use_is_exact: if TRUE the version constraint already used in the current build process is EXACT.
#     :version_in_use_is_system: if TRUE the version constraint already used in the current build process is the OS installed version (only for external packages)
#     :version_to_test: the version constraint of package, that may be used instead of current version.
#     :version_to_test_is_exact: if TRUE the version constraint that may be used is EXACT.
#     :version_to_test_is_system: if TRUE the version constraint is the OS installed version (only for external packages)
#
#     :RES_VERSION_TO_USE: the output variable that contains the new version to use if both constraints are applied (may be same as previously). May be empty if no version compatibility is possible between between both constraints
#
function(get_Compatible_Version RES_VERSION_TO_USE external package version_in_use version_in_use_is_exact version_in_use_is_system version_to_test version_to_test_is_exact version_to_test_is_system)
set(${RES_VERSION_TO_USE} PARENT_SCOPE)
if(external)#management of external packages
  if(version_to_test_is_system)# an OS installed version is required
    if(NOT version_in_use_is_system)#NOT compatible if the version already used is NOT the OS installed version
      return()
    endif()
    set(version_to_test_is_exact TRUE)# => the version is exact (same test)
    set(version_in_use_is_exact TRUE)
  elseif(version_in_use_is_system)
    return()
  endif()
  if(version_to_test_is_exact) #the version to test is EXACT, so impossible to change it after build of current project
    if(version_to_test VERSION_EQUAL version_in_use)#they simply need to be the same in any case
      set(${RES_VERSION_TO_USE} ${version_to_test} PARENT_SCOPE)
    endif()
  else()#the version to test is NOT exact, so we can theorically change it in final build with version_in_use (or any compatible version)
    set(DO_NOT_FIND_${package} TRUE)
    include_Find_File(${package})#just include the find file to get information about compatible versions, do not "find for real" in install tree
    unset(DO_NOT_FIND_${package})
    if(version_in_use_is_exact) #the version currenlty in use is exact
      #the exact version in use must be compatible with (usable instead of) the tested one (since in final build version_in_use_will be used)
      is_Compatible_External_Version(IS_COMPATIBLE ${package} ${version_to_test} ${version_in_use})
      if(IS_COMPATIBLE)
        set(${RES_VERSION_TO_USE} ${version_to_test} PARENT_SCOPE)#use currenlty required version as we can replace it by version one in final build
      endif()
    else()#none of the version constraints is exact
      # so in the end the global build process using current project as a dependency can be adapted to use the "most compatible" version
      # there is no problem to build the current project with this "most compatible version"
      is_Compatible_External_Version(IS_COMPATIBLE_PREV ${package} ${version_to_test} ${version_in_use})
      if(IS_COMPATIBLE_PREV)
        set(${RES_VERSION_TO_USE} ${version_in_use} PARENT_SCOPE)#use previously required version
      else()
        is_Compatible_External_Version(IS_COMPATIBLE_CURR ${package} ${version_in_use} ${version_to_test})
        if(IS_COMPATIBLE_CURR)
          set(${RES_VERSION_TO_USE} ${version_to_test} PARENT_SCOPE)#use currenlty required version
        endif()
      endif()
    endif()
  endif()
else()#native package
  if(version_to_test_is_exact) #the version to test is EXACT, so impossible to change it after build of current project
    get_Version_String_Numbers("${version_to_test}.0" exact_major exact_minor exact_patch)
    if(NOT DEFINED exact_major)#not a valid version string
      return()
    endif()
    is_Exact_Compatible_Version(COMPATIBLE_VERSION ${exact_major} ${exact_minor} ${version_in_use})
    if(COMPATIBLE_VERSION)
      set(${RES_VERSION_TO_USE} ${version_to_test} PARENT_SCOPE)
    endif()
  else()#the version to test is NOT exact, so we can theorically change it in final build with version_in_use (or any compatible version)
    if(version_in_use_is_exact) #the version currenlty in use is exact
      #the exact version in use must be compatible with (usable instead of) the tested one (since in final build version_in_use_will be used)
      get_Version_String_Numbers("${version_in_use}.0" exact_major exact_minor exact_patch)
      if(NOT DEFINED exact_major)#not a valid version string
        return()
      endif()
      is_Compatible_Version(IS_COMPATIBLE ${exact_major} ${exact_minor} ${version_to_test})
      if(IS_COMPATIBLE)#OK version in use can be substituted to version to test in the final build process
        set(${RES_VERSION_TO_USE} ${version_to_test} PARENT_SCOPE)#use currenlty required version as we can replace it by version one in final build
      endif()
    else()#none of the version constraints is exact
      # so in the end the global build process using current project as a dependency can be adapted to use the "most compatible" version
      # there is no problem to build the current project with this "most compatible version"
      get_Version_String_Numbers("${version_in_use}.0" major minor patch)
      if(NOT DEFINED major)#not a valid version string
        return()
      endif()
      is_Compatible_Version(IS_COMPATIBLE ${major} ${minor} ${version_to_test})
      if(IS_COMPATIBLE)
        set(${RES_VERSION_TO_USE} ${version_in_use} PARENT_SCOPE)#use previously required version
      else()# the version in use may be less than version to test
        #test if version to test can be used instead (reverse comparison)
        get_Version_String_Numbers("${version_to_test}.0" major minor patch)
        if(NOT DEFINED major)#not a valid version string
          return()
        endif()
        is_Compatible_Version(IS_COMPATIBLE ${major} ${minor} ${version_in_use})
        if(IS_COMPATIBLE)
          #OK so version_to_test (constraint) must be used instead of version selected
          set(${RES_VERSION_TO_USE} ${version_to_test} PARENT_SCOPE)#use currenlty required version
        endif()
      endif()
    endif()
  endif()
endif()
endfunction(get_Compatible_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Best_Compatible_Version| replace:: ``find_Best_Compatible_Version``
#  .. _find_Best_Compatible_Version:
#
#  find_Best_Compatible_Version
#  ----------------------------
#
#   .. command:: find_Best_Compatible_Version(BEST_VERSION_IN_LIST external package version_in_use version_in_use_exact version_in_use_is_system list_of_versions exact_versions use_system)
#
#    From a version constraint of a given package already used in the build process, get the best compatible version from a listr of version constraints (if any).
#
#     :external: if TRUE the package to check is an external package.
#     :package: the name of package to check.
#     :version_in_use: the version constraint of package, already used in the current build process.
#     :version_in_use_is_exact: if TRUE the version constraint already used in the current build process is EXACT.
#     :version_in_use_is_system: if TRUE the version constraint already used in the current build process target an OS installed version.
#     :list_of_versions: the list of alternative version constraints for package.
#     :exact_versions: the sublist of list_of_versions that contains only exact versions constraints.
#
#     :BEST_VERSION_IN_LIST: the output variable that contains the new version constraint to use (may be same as previously).
#
function(find_Best_Compatible_Version BEST_VERSION_IN_LIST external package version_in_use version_in_use_exact version_in_use_is_system list_of_versions exact_versions)
  set(${BEST_VERSION_IN_LIST} PARENT_SCOPE)
  if(external AND version_in_use_is_system)#specific case: a system version is used and it is the only possible version
    list(FIND list_of_versions "SYSTEM" INDEX)#specific : searching for an explicit SYSTEM version among possible versions
    if(INDEX EQUAL -1)#not found !!
      list(FIND list_of_versions ${version_in_use} INDEX)#searching for a possible version that matches the version of the system wide package
      if(INDEX EQUAL -1)#not found !!
        return()#no compatible version  can be found if already required version is not strucly equal to OS installed version
      endif()
    endif()
    #simply returning THE GIVEN VERSION to indicate that the OS version is in use
    set(${BEST_VERSION_IN_LIST} ${version_in_use} PARENT_SCOPE)
  else()
    #first step: build the list of compatible versions
    set(list_of_compatible_versions)
    set(list_of_compatible_exact_versions)
    foreach(version IN LISTS list_of_versions)
      list(FIND exact_versions ${version} INDEX)
      if(INDEX EQUAL -1)
        set(version_to_test_is_exact FALSE)
      else()
        set(version_to_test_is_exact TRUE)
      endif()
      get_Compatible_Version(COMPATIBLE_VERSION "${external}" ${package} "${version_in_use}" "${version_in_use_exact}" "${version_in_use_is_system}" "${version}" "${version_to_test_is_exact}" FALSE)
      if(COMPATIBLE_VERSION)
        if(version_to_test_is_exact)
          list(APPEND list_of_compatible_exact_versions ${COMPATIBLE_VERSION})
        else()
          list(APPEND list_of_compatible_versions ${COMPATIBLE_VERSION})
        endif()
      endif()
    endforeach()
  endif()
  #second step: find the best version
  if(list_of_compatible_versions)#always prefer non exact version to avoid imposing to strong constraints
    list(GET list_of_compatible_versions 0 min_version)#take the non exact version with lowest number that is compatible
    foreach(version IN LISTS list_of_compatible_versions)
      if(version VERSION_LESS min_version)
        set(min_version ${version})
      endif()
    endforeach()
    set(${BEST_VERSION_IN_LIST} ${min_version} PARENT_SCOPE)
  elseif(list_of_compatible_exact_versions)
    list(GET list_of_compatible_exact_versions 0 min_version)
    foreach(version IN LISTS list_of_compatible_exact_versions)
      if(version VERSION_LESS min_version)
        set(min_version ${version})
      endif()
    endforeach()
    set(${BEST_VERSION_IN_LIST} ${min_version} PARENT_SCOPE)
  endif()

endfunction(find_Best_Compatible_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Exact_External_Version_Compatible_With_Previous_Constraints| replace:: ``is_Exact_External_Version_Compatible_With_Previous_Constraints``
#  .. _is_Exact_External_Version_Compatible_With_Previous_Constraints:
#
#  is_Exact_External_Version_Compatible_With_Previous_Constraints
#  --------------------------------------------------------------
#
#   .. command:: is_Exact_External_Version_Compatible_With_Previous_Constraints(IS_COMPATIBLE NEED_FINDING package version)
#
#    Check if an exact version of an external package is compatible with previous version contrainsts that apply to the current build. This function is used during dependencies version resolutionn process.
#
#     :package: the name of package to check.
#     :version: version of the package.
#
#     :IS_COMPATIBLE: the output variable that is TRUE if the version is compatible, FALSE otherwise.
#     :NEED_FINDING: the output variable that is TRUE if the exact version needs to be find.
#
function(is_Exact_External_Version_Compatible_With_Previous_Constraints IS_COMPATIBLE NEED_FINDING package version)
set(${IS_COMPATIBLE} FALSE PARENT_SCOPE)
set(${NEED_FINDING} FALSE PARENT_SCOPE)
if(${package}_REQUIRED_VERSION_EXACT)
  if(NOT ${package}_REQUIRED_VERSION_EXACT VERSION_EQUAL version)#not compatible if versions are not exactly the same
		return()
	endif()
	set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)#otherwise same version so exactly compatible
	return()
endif()
#from here, no exact version already required

#checking compatibility between the new exact required version and previous constraints targetting not exact versions
foreach(version_required IN LISTS ${package}_ALL_REQUIRED_VERSIONS)
	unset(COMPATIBLE_VERSION)
	is_Compatible_External_Version(COMPATIBLE_VERSION ${package} ${version_required} ${version})#the exact version must be usable instead of all other required non exact versions
	if(NOT COMPATIBLE_VERSION)
		return()#not compatible
	endif()
endforeach()

set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)
if(NOT ${package}_ALL_REQUIRED_VERSIONS #no version already required !! => we can use this exact version => we need to launch the find script to set all adequate variables (PID variables used to memorize which version have already been managed)
  OR NOT ${package}_VERSION_STRING VERSION_EQUAL version) #case where the new exact version constraint must be set adequately using the find script (i.e. not the same version as the previously found not exact version) => reset the variables with this new version
	set(${NEED_FINDING} TRUE PARENT_SCOPE) #need to find the new exact version
endif()
endfunction(is_Exact_External_Version_Compatible_With_Previous_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_External_Version_Compatible_With_Previous_Constraints| replace:: ``is_External_Version_Compatible_With_Previous_Constraints``
#  .. _is_External_Version_Compatible_With_Previous_Constraints:
#
#  is_External_Version_Compatible_With_Previous_Constraints
#  --------------------------------------------------------
#
#   .. command:: is_External_Version_Compatible_With_Previous_Constraints(IS_COMPATIBLE VERSION_TO_FIND package version)
#
#    Check if a version of an external package is compatible with previous version contrainsts that apply to the current build. This function is used during dependencies version resolutionn process.
#
#     :package: the name of package to check.
#     :version: version of the package.
#
#     :IS_COMPATIBLE: the output variable that is TRUE if the version is compatible, FALSE otherwise.
#     :VERSION_TO_FIND: the output variable that contains the version that needs to be find.
#
#   .. todo::
#     Check VERSION_TO_FIND: is it necessary or why not used ?
#
function(is_External_Version_Compatible_With_Previous_Constraints IS_COMPATIBLE VERSION_TO_FIND package version)

set(${IS_COMPATIBLE} FALSE PARENT_SCOPE)
set(${VERSION_TO_FIND} PARENT_SCOPE)
# 1) testing compatibility from current required version with a previous exact version constraint (current is compatible )
if(${package}_REQUIRED_VERSION_EXACT)#an exact version is already required
  if(NOT ${package}_REQUIRED_VERSION_EXACT VERSION_EQUAL version)#not compatible if versions are not exactly the same
    return()
  endif()
  set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)
  return()#no need to set the version to find, because the exact version has already been found by definition
endif()
#from here, no exact version already required

#checking compatibility between the new required version and previous constraints targetting not exact versions
if(${package}_ALL_REQUIRED_VERSIONS)
  get_Greater_Version(MAX_VERSION ${${package}_ALL_REQUIRED_VERSIONS})#we know that all these versions are compatible between themselves
  if(MAX_VERSION VERSION_GREATER version)
    unset(COMPATIBLE_VERSION)
    is_Compatible_External_Version(COMPATIBLE_VERSION ${package} ${version} ${MAX_VERSION})#max version must be usable instead of current version
    if(NOT COMPATIBLE_VERSION)
      return()
    endif()
    #no need to set the version to find since max version is already found
  elseif(MAX_VERSION VERSION_LESS version)
    unset(COMPATIBLE_VERSION)
    is_Compatible_External_Version(COMPATIBLE_VERSION ${package} ${MAX_VERSION} ${version})#current version must be usable instead of max version
    if(NOT COMPATIBLE_VERSION)
      return()
    endif()
    set(${VERSION_TO_FIND} ${version} PARENT_SCOPE)
  # else both are equal so compatible => no need to find again the same version
  endif()
else() #no version constraint currently defined
    set(${VERSION_TO_FIND} ${version} PARENT_SCOPE)#simply find the new version
endif()
set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)
endfunction(is_External_Version_Compatible_With_Previous_Constraints)


##############################################################################################################
############### API functions for managing cache variables bound to package dependencies #####################
##############################################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_To_Install_Package_Specification| replace:: ``add_To_Install_Package_Specification``
#  .. _add_To_Install_Package_Specification:
#
#  add_To_Install_Package_Specification
#  ------------------------------------
#
#   .. command:: add_To_Install_Package_Specification(package version version_exact)
#
#    Mark a given package version as "to be installed".
#
#     :package: the name of package to check.
#     :version: version of the package.
#     :version_exact: if TRUE then the version constraint is exact.
#
function(add_To_Install_Package_Specification package version version_exact)
list(FIND ${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} ${package} INDEX)
if(INDEX EQUAL -1)#not found
	append_Unique_In_Cache(${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} ${package})
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
			append_Unique_In_Cache(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX} ${version})
			if(version_exact)
				set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
			else()
				set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
			endif()
		elseif(version_exact) #if this version was previously not exact it becomes exact if exact is required
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		endif()
	else()# when there is a problem !! (maybe a warning could be a good idea)
		set(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
		endif()
	endif()
endif()
endfunction(add_To_Install_Package_Specification)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_To_Install_Packages| replace:: ``reset_To_Install_Packages``
#  .. _reset_To_Install_Packages:
#
#  reset_To_Install_Packages
#  -------------------------
#
#   .. command:: reset_To_Install_Packages()
#
#    Reset all packages marked as "to be installed".
#
function(reset_To_Install_Packages)
foreach(pack IN LISTS ${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX})
	foreach(version IN LISTS ${PROJECT_NAME}_TOINSTALL_${pack}_VERSIONS${USE_MODE_SUFFIX})
		set(${PROJECT_NAME}_TOINSTALL_${pack}_${version}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_TOINSTALL_${pack}_VERSIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} CACHE INTERNAL "")
endfunction(reset_To_Install_Packages)

#.rst:
#
# .. ifmode:: internal
#
#  .. |need_Install_Native_Package| replace:: ``need_Install_Native_Package``
#  .. _need_Install_Native_Package:
#
#  need_Install_Native_Package
#  ---------------------------
#
#   .. command:: need_Install_Native_Package(NEED FIND package)
#
#    Tell whether a native package must be installed in current process.
#
#     :package: the name of the given native package.
#
#     :NEED: the output variable that is TRUE if given native package must be installed.
#     :FIND: the output variable that is TRUE if given external package must be found.
#
function(need_Install_Native_Package NEED FIND package)
  list(FIND ${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} ${package} INDEX)
  if(INDEX EQUAL -1)#package not found in list of packages to install
  	set(${NEED} FALSE PARENT_SCOPE)
  	set(${FIND} FALSE PARENT_SCOPE)
  else()
	if(${package}_FOUND${USE_MODE_SUFFIX})
		set(${NEED} FALSE PARENT_SCOPE)

		resolve_Required_Native_Package_Version(RESOLUTION_OK MINIMUM_VERSION IS_EXACT ${package})
		# MINIMUM_VERSION will be empty if the version already selected is compatible
		if(MINIMUM_VERSION AND MINIMUM_VERSION VERSION_GREATER ${package}_VERSION_STRING)
			set(${NEED} TRUE PARENT_SCOPE)
		endif()

		set(${FIND} TRUE PARENT_SCOPE)
		return()
	endif()
  	set(${NEED} TRUE PARENT_SCOPE)
	set(${FIND} TRUE PARENT_SCOPE)
  endif()
endfunction(need_Install_Native_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_To_Install_External_Package_Specification| replace:: ``add_To_Install_External_Package_Specification``
#  .. _add_To_Install_External_Package_Specification:
#
#  add_To_Install_External_Package_Specification
#  ---------------------------------------------
#
#   .. command:: add_To_Install_External_Package_Specification(package version version_exact)
#
#    Mark a given external package version as "to be installed".
#
#     :package: the name of package to check.
#     :version: version of the package.
#     :version_exact: if TRUE then the version constraint is exact.
#     :os_variant: if TRUE then the version constraint target the OS installed version of the external package.
#
function(add_To_Install_External_Package_Specification package version version_exact os_variant)
list(FIND ${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX} ${package} INDEX)
if(INDEX EQUAL -1)#not found => adding it to "to install" packages
	append_Unique_In_Cache(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX} ${package})
	if(version)#set the version
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} "${version_exact}" CACHE INTERNAL "")
    set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_SYSTEM${USE_MODE_SUFFIX} "${os_variant}" CACHE INTERNAL "")
	endif()
else()#package already required as "to install"
	if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX})#required versions are already specified
		list(FIND ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} ${version} INDEX)
		if(INDEX EQUAL -1)#version not already required => adding it to required versions
			append_Unique_In_Cache(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}")
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} "${version_exact}" CACHE INTERNAL "")
      set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_SYSTEM${USE_MODE_SUFFIX} "${os_variant}" CACHE INTERNAL "")
		elseif(version_exact) #if this version was previously not exact it becomes exact if exact is required
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
      set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_SYSTEM${USE_MODE_SUFFIX} "${os_variant}" CACHE INTERNAL "")
    endif()
	else()#no version specified => simply add the version constraint
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX} "${version_exact}" CACHE INTERNAL "")
    set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_SYSTEM${USE_MODE_SUFFIX} "${os_variant}" CACHE INTERNAL "")
  endif()
endif()
endfunction(add_To_Install_External_Package_Specification)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_To_Install_External_Packages| replace:: ``reset_To_Install_External_Packages``
#  .. _reset_To_Install_External_Packages:
#
#  reset_To_Install_External_Packages
#  ----------------------------------
#
#   .. command:: reset_To_Install_External_Packages()
#
#    Reset all external packages marked as "to be installed".
#
function(reset_To_Install_External_Packages)
foreach(pack IN LISTS ${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX})
	foreach(version IN LISTS ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_VERSIONS${USE_MODE_SUFFIX})
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_${version}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_VERSIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX} CACHE INTERNAL "")
endfunction(reset_To_Install_External_Packages)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Found_External_Packages| replace:: ``reset_Found_External_Packages``
#  .. _reset_Found_External_Packages:
#
#  reset_Found_External_Packages
#  -----------------------------
#
#   .. command:: reset_Found_External_Packages()
#
#    Reset all external packages variables used during find process.
#
function(reset_Found_External_Packages)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})

foreach(a_used_package IN LISTS ${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES)
	set(${a_used_package}_FOUND${VAR_SUFFIX} CACHE INTERNAL "")
	set(${a_used_package}_ROOT_DIR CACHE INTERNAL "")
	set(${a_used_package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "")
	set(${a_used_package}_REQUIRED_VERSION_EXACT CACHE INTERNAL "")
	set(${a_used_package}_REQUIRED_VERSION_SYSTEM CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES CACHE INTERNAL "")
endfunction(reset_Found_External_Packages)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Found_Native_Packages| replace:: ``reset_Found_Native_Packages``
#  .. _reset_Found_Native_Packages:
#
#  reset_Found_Native_Packages
#  ---------------------------
#
#   .. command:: reset_Found_Native_Packages()
#
#    Reset all native packages variables used during find process.
#
function(reset_Found_Native_Packages)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
foreach(a_used_package IN LISTS ${PROJECT_NAME}_ALL_USED_PACKAGES)
	set(${a_used_package}_FOUND${VAR_SUFFIX} CACHE INTERNAL "")
	set(${a_used_package}_ROOT_DIR CACHE INTERNAL "")
	set(${a_used_package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "")
	set(${a_used_package}_REQUIRED_VERSION_EXACT CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_ALL_USED_PACKAGES CACHE INTERNAL "")
endfunction(reset_Found_Native_Packages)

#.rst:
#
# .. ifmode:: internal
#
#  .. |need_Install_External_Package| replace:: ``need_Install_External_Package``
#  .. _need_Install_External_Package:
#
#  need_Install_External_Package
#  -----------------------------
#
#   .. command:: need_Install_External_Package(NEED FIND package)
#
#    Tell whether a package must be installed in current process.
#
#     :package: the name of the given external package.
#
#     :NEED: the output variable that is TRUE if given external package must be installed.
#     :FIND: the output variable that is TRUE if given external package must be found.
#
function(need_Install_External_Package NEED FIND package)
  list(FIND ${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX} ${package} INDEX)
  if(INDEX EQUAL -1)#package not found in list of packages to install
  	set(${NEED} FALSE PARENT_SCOPE)
  	set(${FIND} FALSE PARENT_SCOPE)
  else()
	if(${package}_FOUND${USE_MODE_SUFFIX})
		set(${NEED} FALSE PARENT_SCOPE)

		resolve_Required_External_Package_Version(VERSION_POSSIBLE SELECTED IS_EXACT IS_SYSTEM ${package})
		# SELECTED will be an empty string if the version already selected is compatible
		if(NOT VERSION_POSSIBLE)
			finish_Progress(${GLOBAL_PROGRESS_VAR})
			message(FATAL_ERROR "[PID] CRITICAL ERROR :in ${PROJECT_NAME}, impossible to find a compatible version for dependency ${package}")
		elseif(NOT SELECTED STREQUAL "" AND NOT SELECTED VERSION_EQUAL ${package}_VERSION_STRING)
			set(${NEED} TRUE PARENT_SCOPE)
		endif()

		set(${FIND} TRUE PARENT_SCOPE)
		return()
	endif()
  	set(${NEED} TRUE PARENT_SCOPE)
	set(${FIND} TRUE PARENT_SCOPE)
  endif()
endfunction(need_Install_External_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Packages_Finding_Variables| replace:: ``reset_Packages_Finding_Variables``
#  .. _reset_Packages_Finding_Variables:
#
#  reset_Packages_Finding_Variables
#  --------------------------------
#
#   .. command:: reset_Packages_Finding_Variables()
#
#    Reset all variables bound to find process in the context of a package.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Native_Package_Dependency| replace:: ``resolve_Native_Package_Dependency``
#  .. _resolve_Native_Package_Dependency:
#
#  resolve_Native_Package_Dependency
#  ---------------------------------
#
#   .. command:: resolve_Native_Package_Dependency(VERSION_COMPATIBLE ABI_COMPATIBLE package dependency mode)
#
#    Find the best version of a dependency for a given package (i.e. another package) locally.
#    It takes into account the previous constraints that apply to this dependency to find a version
#    that satisfies all constraints (if possible).
#    each dependent package version is defined as ${package}_DEPENDENCY_${dependency}_VERSION
#    other variables set by the package version use file
#    ${package}_DEPENDENCY_${dependency}_REQUIRED		# TRUE if package is required FALSE otherwise (QUIET MODE)
#    ${package}_DEPENDENCY_${dependency}_VERSION		# version if a version if specified
#    ${package}_DEPENDENCY_${dependency}_VERSION_EXACT	# TRUE if exact version is required
#    ${package}_DEPENDENCY_${dependency}_COMPONENTS	# list of components
#
#     :package: the name of package that has dependencies.
#     :dependency: the name of the native package that is a dependency of package
#     :mode: the build mode to consider.
#
#     :VERSION_COMPATIBLE: the output variable that is TRUE if the dependency has a compatible version with those already defined in current build process, false otherwise.
#     :ABI_COMPATIBLE: the output variable that is TRUE if the dependency use a compatible ABI with the one defined by current platform, false otherwise.
#
function(resolve_Native_Package_Dependency VERSION_COMPATIBLE ABI_COMPATIBLE package dependency mode)
set(${VERSION_COMPATIBLE} TRUE PARENT_SCOPE)
set(${ABI_COMPATIBLE} TRUE PARENT_SCOPE)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(${dependency}_FOUND${VAR_SUFFIX}) #the dependency has already been found (previously found in iteration or recursion, not possible to import it again)
	if(${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX}) # a specific version is required
	 	if( ${package}_DEPENDENCY_${dependency}_VERSION_EXACT${VAR_SUFFIX}) #an exact version is required

			is_Exact_Version_Compatible_With_Previous_Constraints(IS_COMPATIBLE NEED_REFIND ${dependency} ${${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX}}) # will be incompatible if a different exact version already required OR if another major version required OR if another minor version greater than the one of exact version

			if(IS_COMPATIBLE)
				if(NEED_REFIND)
					# OK installing the exact version instead
					find_package_resolved(
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
				set(${VERSION_COMPATIBLE} FALSE PARENT_SCOPE)
				return()
			endif()
		else()#not an exact version required
			is_Version_Compatible_With_Previous_Constraints (
					COMPATIBLE_VERSION VERSION_TO_FIND
					${dependency} ${${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX}})
			if(COMPATIBLE_VERSION)
				if(VERSION_TO_FIND)
					find_package_resolved(
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
        set(${VERSION_COMPATIBLE} FALSE PARENT_SCOPE)
        return()
			endif()
		endif()
	else()
    return()#by default the version is compatible (no constraints) so return
	endif()
else()#the dependency has not been already found
	if(${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX})

		if(${package}_DEPENDENCY_${dependency}_VERSION_EXACT${VAR_SUFFIX}) #an exact version has been specified
			find_package_resolved(
				${dependency}
				${${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX}}
				EXACT
				MODULE
				REQUIRED
				${${package}_DEPENDENCY_${dependency}_COMPONENTS${VAR_SUFFIX}}
			)

		else()
			find_package_resolved(
				${dependency}
				${${package}_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX}}
				MODULE
				REQUIRED
				${${package}_DEPENDENCY_${dependency}_COMPONENTS${VAR_SUFFIX}}
			)
		endif()
	else() # not version specified
		find_package_resolved(
			${dependency}
			MODULE
			REQUIRED
			${${package}_DEPENDENCY_${dependency}_COMPONENTS${VAR_SUFFIX}}
		)
	endif()
endif()
#last step : check STD C++ AND CONFIGURATION ABI compatibilities
if(${dependency}_FOUND${VAR_SUFFIX})
  is_Compatible_With_Current_ABI(IS_ABI_COMPATIBLE ${dependency} ${mode})
  set(${ABI_COMPATIBLE} ${IS_ABI_COMPATIBLE} PARENT_SCOPE)#warning => the binary package may have been built with an incompatible C++ ABI
endif()
endfunction(resolve_Native_Package_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_External_Package_Dependency| replace:: ``resolve_External_Package_Dependency``
#  .. _resolve_External_Package_Dependency:
#
#  resolve_External_Package_Dependency
#  -----------------------------------
#
#   .. command:: resolve_External_Package_Dependency(VERSION_COMPATIBLE ABI_COMPATIBLE package external_dependency mode)
#
#    Find the best version of an external dependency for a given package for a local build. It takes into account the previous constraints that apply to this dependency to find a version that satisfy all constraints (if possible).
#
#     :package: the name of package that has dependencies.
#     :external_dependency: the name of the external package that is a dependency of package.
#     :mode: the build mode to consider.
#
#     :VERSION_COMPATIBLE: the output variable that is TRUE if the dependency has a compatible version with those already defined in current build process, false otherwise.
#     :ABI_COMPATIBLE: the output variable that is TRUE if the dependency use a compatible ABI with the one defined by current platform, false otherwise.
#
function(resolve_External_Package_Dependency VERSION_COMPATIBLE ABI_COMPATIBLE package external_dependency mode)
set(${VERSION_COMPATIBLE} TRUE PARENT_SCOPE)
set(${ABI_COMPATIBLE} TRUE PARENT_SCOPE)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(${external_dependency}_FOUND${VAR_SUFFIX}) #the dependency has already been found (previously found in iteration or recursion, not possible to import it again)
	if(${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX}) # a specific version is required
		if(${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION_EXACT${VAR_SUFFIX}) #an exact version is required
			is_Exact_External_Version_Compatible_With_Previous_Constraints(IS_COMPATIBLE NEED_REFIND
																		${external_dependency}
																		${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX}}) # will be incompatible if a different exact version already required OR if another major version required OR if another minor version greater than the one of exact version
			if(IS_COMPATIBLE)
				if(NEED_REFIND)
					if(${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION_SYSTEM${VAR_SUFFIX})#the OS version is required
						set(${external_dependency}_FIND_VERSION_SYSTEM TRUE)
					else()
						set(${external_dependency}_FIND_VERSION_SYSTEM FALSE)
					endif()
					# OK need to find the exact version instead
					find_package_resolved(
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
				set(${VERSION_COMPATIBLE} FALSE PARENT_SCOPE)
					return()
			endif()
		else()#not an exact version required
			is_External_Version_Compatible_With_Previous_Constraints (
					COMPATIBLE_VERSION VERSION_TO_FIND
					${external_dependency} ${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX}})
			if(COMPATIBLE_VERSION)
				if(VERSION_TO_FIND)
					find_package_resolved(
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
				set(${VERSION_COMPATIBLE} FALSE PARENT_SCOPE)
				return()
			endif()
		endif()
	else()#no specific version constraint applies to dependency from the package
		return()#by default the version is compatible (no constraints) so return (no need to change the version currently in use)
	endif()
else()#the dependency has not been already found
	if(	${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX})

		if(${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION_EXACT${VAR_SUFFIX}) #an exact version has been specified
			if(${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION_SYSTEM${VAR_SUFFIX})#the OS version is required
				set(${external_dependency}_FIND_VERSION_SYSTEM TRUE)
			else()
				set(${external_dependency}_FIND_VERSION_SYSTEM FALSE)
			endif()
			find_package_resolved(
				${external_dependency}
				${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX}}
				EXACT
				MODULE
				REQUIRED
				${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_COMPONENTS${VAR_SUFFIX}}
			)
		else()
			find_package_resolved(
				${external_dependency}
				${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION${VAR_SUFFIX}}
				MODULE
				REQUIRED
				${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_COMPONENTS${VAR_SUFFIX}}
			)
		endif()
	else()# finding without any specific constraint (version or os variant)
		find_package_resolved(
			${external_dependency}
			MODULE
			REQUIRED
			${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_COMPONENTS${VAR_SUFFIX}}
		)
	endif()
endif()
#last step : check STD C++ ABI compatibility
if(${external_dependency}_FOUND${VAR_SUFFIX})
  is_Compatible_With_Current_ABI(IS_ABI_COMPATIBLE ${external_dependency} ${mode})
  set(${ABI_COMPATIBLE} ${IS_ABI_COMPATIBLE} PARENT_SCOPE)
  #warning => the binary package has been built with an incompatible C++ ABI
endif()
endfunction(resolve_External_Package_Dependency)


############################################################################
################ macros used to write cmake find scripts ###################
############################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |exitFindScript| replace:: ``exitFindScript``
#  .. _exitFindScript:
#
#  exitFindScript
#  --------------
#
#   .. command:: exitFindScript(package message_to_send)
#
#    Exitting the find script of a package with a message.
#
#     :package: the name of the package.
#     :message_to_send: message to print when exitting the script.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |exit_And_Manage_Install_Requirement_For_Native| replace:: ``exit_And_Manage_Install_Requirement_For_Native``
#  .. _exit_And_Manage_Install_Requirement_For_Native:
#
#  exit_And_Manage_Install_Requirement_For_Native
#  ----------------------------------------------
#
#   .. command:: exit_And_Manage_Install_Requirement_For_Native(package message_to_send)
#
#    Exitting the find script of a native package with a message and setting adequate variables to ensure install of not found dependencies.
#
#     :package: the name of the package.
#     :message_to_send: message to print when exitting the script.
#
macro(exit_And_Manage_Install_Requirement_For_Native package message_to_send)
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
	if(ADDITIONAL_DEBUG_INFO)
		message(${message_to_send})
	endif()
	return()
endmacro(exit_And_Manage_Install_Requirement_For_Native)

#.rst:
#
# .. ifmode:: internal
#
#  .. |finding_Package| replace:: ``finding_Package``
#  .. _finding_Package:
#
#  finding_Package
#  ---------------
#
#   .. command:: finding_Package(package)
#
#     Launch the native package finding process. Macro to be called in find script of native packages.
#
#     :package: the name of the package.
#
macro(finding_Package package)
if(DO_NOT_FIND_${package})#variable used to avoid finding package (if we only want to include the find file to get between known versions)
  return()
endif()
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})

set(${package}_FOUND${VAR_SUFFIX} FALSE CACHE INTERNAL "")

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

			select_Components(USE_FILE_NOTFOUND ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND ${package} ${${package}_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION} "${${package}_FIND_COMPONENTS}")
			if(USE_FILE_NOTFOUND)
				exitFindScript(${package} "[PID] CRITICAL ERROR  when configuring ${PROJECT_NAME} : the selected version of ${package} (${${package}_VERSION_STRING}) has no configuration file or file is corrupted")
			endif()

			if(NOT ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND)
				exitFindScript(${package} "[PID] CRITICAL ERROR  when configuring ${PROJECT_NAME} : some of the requested components of the package ${package} are missing (version chosen is ${${package}_VERSION_STRING}, requested is ${${package}_FIND_VERSION}),either bad names specified or broken package versionning.")
			endif()

		else()#no component check, register all of them
			all_Components(USE_FILE_NOTFOUND "${package}" ${${package}_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION})
			if(USE_FILE_NOTFOUND)
				exitFindScript(${package} "[PID] CRITICAL ERROR when configuring ${PROJECT_NAME} : the  selected version of ${package} (${${package}_VERSION_STRING}) has no configuration file or file is corrupted.")
			endif()
		endif()
		#need to check if debug binaries are provided (based on ${package}_BUILT_RELEASE_ONLY variable provided in Use file)
		if(CMAKE_BUILD_TYPE MATCHES Debug)
			if(${package}_BUILT_RELEASE_ONLY)#debug binaries are not available, so package is not found
				if(${package}_FIND_VERSION)#force the version patch to be the one resolved
				#Note: this is to ensure that the rebuild of dependency is done on adequate patch version even if this version is not released yet
				set(${package}_FIND_VERSION_PATCH ${${package}_VERSION_PATCH})
				endif()
				unload_Binary_Package_Install_Manifest(${package}) #clean the cache with info coming from use file
				reset_Version_Strings(${package})#clean the cache with info coming from dependency version resolution
				exit_And_Manage_Install_Requirement_For_Native(${package} "[PID] WARNING when configuring ${PROJECT_NAME} : the package ${package} with version ${${package}_FIND_VERSION} has been found but does not provide debug artifacts as required. Considered as not found.")
			endif()
		endif()

		#here everything has been found => setting global standard CMake find process variables to adequate values
		set(${package}_FOUND${VAR_SUFFIX} TRUE CACHE INTERNAL "")
		set(${package}_ROOT_DIR ${PATH_TO_PACKAGE_VERSION} CACHE INTERNAL "")
		append_Unique_In_Cache(${PROJECT_NAME}_ALL_USED_PACKAGES ${package})

		if(${package}_FIND_VERSION)
			if(${package}_FIND_VERSION_EXACT)
				set(${package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(${package}_REQUIRED_VERSION_EXACT "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}" CACHE INTERNAL "")
			else()
				append_Unique_In_Cache(${package}_ALL_REQUIRED_VERSIONS "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}" CACHE INTERNAL "")
			endif()
		endif()

		#registering PID system version for that package
		list_Regular_Files(ALL_CMAKE_FILES ${PATH_TO_PACKAGE_VERSION}/share/cmake)
		set(${package}_PID_VERSION 0 CACHE INTERNAL "")#default version is 0
		foreach(a_file IN LISTS ALL_CMAKE_FILES)
			if(a_file MATCHES "^.+\\.cmake$")
				include(${PATH_TO_PACKAGE_VERSION}/share/cmake/${a_file})
			endif()
		endforeach()
	else()#no adequate version found
    	exit_And_Manage_Install_Requirement_For_Native(${package} "[PID] WARNING when configuring ${PROJECT_NAME} : the package ${package} with version ${${package}_FIND_VERSION} cannot be found in the workspace.")
	endif()
else() #if the directory does not exist it means the package cannot be found
  exit_And_Manage_Install_Requirement_For_Native(${package} "[PID] INFO when configuring ${PROJECT_NAME} : the required package ${package} cannot be found in the workspace.")
endif()
endmacro(finding_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |exit_And_Manage_Install_Requirement_For_External| replace:: ``exit_And_Manage_Install_Requirement_For_External``
#  .. _exit_And_Manage_Install_Requirement_For_External:
#
#  exit_And_Manage_Install_Requirement_For_External
#  ------------------------------------------------
#
#   .. command:: exit_And_Manage_Install_Requirement_For_External(package message_to_send)
#
#    Exitting the find script of an external package with a message and setting adequate variables to ensure install of not found dependencies.
#
#     :package: the name of the package.
#     :message_to_send: message to print when exitting the script.
#
macro(exit_And_Manage_Install_Requirement_For_External package message_to_send is_exact is_system)
	if(${package}_FIND_REQUIRED)
		if(${package}_FIND_VERSION)
			add_To_Install_External_Package_Specification(${package} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}" ${is_exact} ${is_system})
		else()
			add_To_Install_External_Package_Specification(${package} "" FALSE FALSE)
		endif()
	endif()
	if(ADDITIONAL_DEBUG_INFO)
		message(${message_to_send})
	endif()
	return()
endmacro(exit_And_Manage_Install_Requirement_For_External)

#.rst:
#
# .. ifmode:: internal
#
#  .. |finding_External_Package| replace:: ``finding_External_Package``
#  .. _finding_External_Package:
#
#  finding_External_Package
#  ------------------------
#
#   .. command:: finding_External_Package(package)
#
#     Launch the external package finding process. Macro to be called in find script of external packages.
#
#      requires ${package}_PID_KNOWN_VERSION to be defined before calling this macro, set with at least one exact version (MAJOR.MINOR.PATCH)
#      optionnaly ${package}_PID_KNOWN_VERSION_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO can be set to define which version (MAJOR.MINOR.PATCH) is no more compatible with ${version}. Can be done for any version defined as "known".
#
#     :package: the name of the package.
#
macro(finding_External_Package package)
if(DO_NOT_FIND_${package})#variable used to avoid finding package (if we only want to include the find file to get compatibility info between known versions)
  return()
endif()
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
set(${package}_FOUND${VAR_SUFFIX} FALSE CACHE INTERNAL "")
#workspace dir must be defined for each package build
set(EXTERNAL_PACKAGE_${package}_SEARCH_PATH
    ${PACKAGE_BINARY_INSTALL_DIR}/${package}
    CACHE
    INTERNAL
    "path to the package install dir containing versions of ${package} external package"
  )

#preparing variables depending on arguments used for find_package
if(${package}_FIND_VERSION_EXACT)
  set(is_exact TRUE)
else()
  set(is_exact FALSE)
endif()
if(${package}_FIND_VERSION_SYSTEM)#this variable is specific to PID
  set(is_system TRUE)
else()
  set(is_system FALSE)
endif()

check_Directory_Exists(EXIST ${EXTERNAL_PACKAGE_${package}_SEARCH_PATH})
if(EXIST)
  # at this stage the only thing to do is to check for versions
  if(${package}_FIND_VERSION)
		if(is_exact) #using a specific version
			check_External_Exact_Version(VERSION_TO_USE ${package} ${EXTERNAL_PACKAGE_${package}_SEARCH_PATH} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}")
		else() #using the best version as regard of version constraints
			check_External_Minimum_Version(VERSION_TO_USE ${package} ${EXTERNAL_PACKAGE_${package}_SEARCH_PATH} "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}")
		endif()
	else() #no specific version targetted using last available version (takes the last version available)
		check_External_Last_Version(VERSION_TO_USE ${package} ${EXTERNAL_PACKAGE_${package}_SEARCH_PATH})
	endif()
	if(VERSION_TO_USE)#a good version of the package has been found
		set(${package}_ROOT_DIR ${EXTERNAL_PACKAGE_${package}_SEARCH_PATH}/${VERSION_TO_USE} CACHE INTERNAL "")
		reset_External_Package_Dependency_Cached_Variables_From_Use(${package} ${CMAKE_BUILD_TYPE} FALSE)
		include(${${package}_ROOT_DIR}/share/Use${package}-${VERSION_TO_USE}.cmake  OPTIONAL)#using the generated Use<package>-<version>.cmake file to get adequate version information about components
		if(is_system)# an OS variant is required
			if(NOT ${package}_BUILT_OS_VARIANT)#the binary package is NOT an OS variant
				unset(${package}_ROOT_DIR CACHE)
				exit_And_Manage_Install_Requirement_For_External(${package} "[PID] WARNING: the required OS variant version (${VERSION_TO_USE}) of external package ${package} cannot be found in the workspace." ${is_exact} ${is_system})
			endif()
		else()# when not a system install the package may be built in release only mode
			if(CMAKE_BUILD_TYPE MATCHES Debug)
				if(${package}_BUILT_RELEASE_ONLY)#debug binaries are not available, so package is not found
					unload_Binary_Package_Install_Manifest(${package}) #clean the cache with info coming from use file
					reset_Version_Strings(${package})#clean the cache with info coming from dependency version resolution
					exit_And_Manage_Install_Requirement_For_External(${package} "[PID] WARNING: the package ${package} with version ${${package}_FIND_VERSION} has been found but does not provide debug artifacts as required. Considered as not found." ${is_exact} ${is_system})
				endif()
			endif()
		# else even if an OS variant is not required, an OS variant can be used
		endif()
		set(${package}_FOUND${VAR_SUFFIX} TRUE CACHE INTERNAL "")
		#add the undirectly used packages as well
    	append_Unique_In_Cache(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES ${package})
		if(${package}_FIND_VERSION)
			if(is_exact)
				set(${package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(${package}_REQUIRED_VERSION_EXACT "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}" CACHE INTERNAL "")
				if(is_system)
					set(${package}_REQUIRED_VERSION_SYSTEM TRUE CACHE INTERNAL "")
				else()
					set(${package}_REQUIRED_VERSION_SYSTEM FALSE CACHE INTERNAL "")
        		endif()
      		else()
				append_Unique_In_Cache(${package}_ALL_REQUIRED_VERSIONS "${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}")
			endif()
		endif()
	else()#no adequate version found
    	exit_And_Manage_Install_Requirement_For_External(${package} "[PID] WARNING : the required version(${${package}_FIND_VERSION_MAJOR}.${${package}_FIND_VERSION_MINOR}.${${package}_FIND_VERSION_PATCH}) of external package ${package} cannot be found in the workspace." ${is_exact} ${is_system})
	endif()
else() #if the directory does not exist it means the external package cannot be found
  exit_And_Manage_Install_Requirement_For_External(${package} "[PID] INFO : the required external package ${package} cannot be found in the workspace." ${is_exact} ${is_system})
endif()
endmacro(finding_External_Package)
