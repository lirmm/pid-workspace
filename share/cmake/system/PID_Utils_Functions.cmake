#########################################################################################
#	This file is part of the program PID						#
#  	Program description : build system supportting the PID methodology  		#
#  	Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique 	#
#	et de Microelectronique de Montpellier). All Right reserved.			#
#											#
#	This software is free software: you can redistribute it and/or modify		#
#	it under the terms of the CeCILL-C license as published by			#
#	the CEA CNRS INRIA, either version 1						#
#	of the License, or (at your option) any later version.				#
#	This software is distributed in the hope that it will be useful,		#
#	but WITHOUT ANY WARRANTY; without even the implied warranty of			#
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the			#
#	CeCILL-C License for more details.						#
#											#
#	You can find the complete license description on the official website 		#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/constraints/platforms) # using platform check modules
#############################################################
########### general utilities for build management ##########
#############################################################

###
function(get_Mode_Variables TARGET_SUFFIX VAR_SUFFIX mode)
if(mode MATCHES Release)
	set(${TARGET_SUFFIX} PARENT_SCOPE)
	set(${VAR_SUFFIX} PARENT_SCOPE)
else()
	set(${TARGET_SUFFIX} -dbg PARENT_SCOPE)
	set(${VAR_SUFFIX} _DEBUG PARENT_SCOPE)
endif()
endfunction(get_Mode_Variables)

###
function(get_System_Variables OS_STRING ARCH_STRING ABI_STRING PACKAGE_STRING)
if(APPLE)
	set(${OS_STRING} macosx PARENT_SCOPE)
	set(${PACKAGE_STRING} Darwin PARENT_SCOPE)
elseif(UNIX)
	set(${OS_STRING} linux PARENT_SCOPE)
	set(${PACKAGE_STRING} Linux PARENT_SCOPE)
else()
	message(SEND_ERROR "[PID] ERROR : unsupported system (Not UNIX or OSX) !")
	return()
endif()
if(${CMAKE_SIZEOF_VOID_P} EQUAL 4)
	set(${ARCH_STRING} 32 PARENT_SCOPE)
elseif(${CMAKE_SIZEOF_VOID_P} EQUAL 8)
	set(${ARCH_STRING} 64 PARENT_SCOPE)
else()
	message(SEND_ERROR "[PID] ERROR : unsupported architecture (Not 32 or 64 bits) !")
	return()
endif()

set(TEST_ABI CXX11)
include(CheckABI)

if(NOT CHECK_ABI_RESULT)
	set(${ABI_STRING} "CXX" PARENT_SCOPE)
else()
	set(${ABI_STRING} "CXX11" PARENT_SCOPE)
endif()
endfunction(get_System_Variables)

###
function(is_A_System_Reference_Path path IS_SYSTEM)

if(UNIX)
	if(path STREQUAL / OR path STREQUAL /usr OR path STREQUAL /usr/local)
		set(${IS_SYSTEM} TRUE PARENT_SCOPE)
	else()
		set(${IS_SYSTEM} FALSE PARENT_SCOPE)
	endif()
endif()

if(APPLE AND NOT ${IS_SYSTEM})
	if(path STREQUAL /Library/Frameworks OR path STREQUAL /Network/Library/Frameworks OR path STREQUAL /System/Library/Framework)
		set(${IS_SYSTEM} TRUE PARENT_SCOPE)
	endif()
endif()

endfunction(is_A_System_Reference_Path)

#############################################################
################ string handling utilities ##################
#############################################################

###
function(extract_All_Words name_with_underscores all_words_in_list)
set(res "")
string(REPLACE "_" ";" res "${name_with_underscores}")
set(${all_words_in_list} ${res} PARENT_SCOPE)
endfunction()

###
function(fill_List_Into_String input_list res_string)
set(res "")
foreach(element IN ITEMS ${input_list})
	set(res "${res} ${element}")
endforeach()
string(STRIP "${res}" res_finished)
set(${res_string} ${res_finished} PARENT_SCOPE)
endfunction()

#############################################################
################ filesystem management utilities ############
#############################################################

###
function(create_Symlink path_to_old path_to_new)
if(	EXISTS ${path_to_new} AND IS_SYMLINK ${path_to_new})
	execute_process(#removing the existing symlink
		COMMAND ${CMAKE_COMMAND} -E remove -f ${path_to_new}
	)
endif()
execute_process(
	COMMAND ${CMAKE_COMMAND} -E create_symlink ${path_to_old} ${path_to_new}
)
endfunction(create_Symlink)

###
function(create_Rpath_Symlink path_to_target path_to_rpath_folder rpath_sub_folder)
#first creating the path where to put symlinks if it does not exist
set(FULL_RPATH_DIR ${path_to_rpath_folder}/.rpath/${rpath_sub_folder})
file(MAKE_DIRECTORY ${FULL_RPATH_DIR})
get_filename_component(A_FILE ${path_to_target} NAME)
#second creating the symlink
create_Symlink(${path_to_target} ${FULL_RPATH_DIR}/${A_FILE})
endfunction(create_Rpath_Symlink)

###
function(install_Rpath_Symlink path_to_target path_to_rpath_folder rpath_sub_folder)
get_filename_component(A_FILE "${path_to_target}" NAME)
set(FULL_RPATH_DIR ${path_to_rpath_folder}/.rpath/${rpath_sub_folder})
install(DIRECTORY DESTINATION ${FULL_RPATH_DIR}) #create the folder that will contain symbolic links to runtime resources used by the component (will allow full relocation of components runtime dependencies at install time)
install(CODE "
        if(EXISTS ${FULL_RPATH_DIR}/${A_FILE} AND IS_SYMLINK ${FULL_RPATH_DIR}/${A_FILE})
		execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${FULL_RPATH_DIR}/${A_FILE}
				WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX})
	endif()
	execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink ${path_to_target} ${FULL_RPATH_DIR}/${A_FILE}
                                WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX})
	message(\"-- Installing: ${FULL_RPATH_DIR}/${A_FILE}\")

")# creating links "on the fly" when installing

endfunction(install_Rpath_Symlink)

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


#############################################################
################ Management of version information ##########
#############################################################

###
function (document_Version_Strings package_name major minor patch)
	set(${package_name}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set(${package_name}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set(${package_name}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set(${package_name}_VERSION_STRING "${major}.${minor}.${patch}" CACHE INTERNAL "")
	set(${package_name}_VERSION_RELATIVE_PATH "${major}.${minor}.${patch}" CACHE INTERNAL "")
endfunction(document_Version_Strings)


###
function (document_External_Version_Strings package version)
	set(${package}_VERSION_STRING "${version}" CACHE INTERNAL "")
	set(${package}_VERSION_RELATIVE_PATH "${version}" CACHE INTERNAL "")
endfunction(document_External_Version_Strings)


###
function(get_Version_String_Numbers version_string major minor patch)
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2;\\3" A_VERSION "${version_string}")
if(A_VERSION STREQUAL "${version_string}") #no match try with more than 3 elements
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.?(.*)$" "\\1;\\2;\\3;\\4" A_VERSION "${version_string}")
endif()
if(NOT A_VERSION STREQUAL "${version_string}") # version string is well formed with major.minor.patch (at least) format
	list(GET A_VERSION 0 major_vers)
	list(GET A_VERSION 1 minor_vers)
	list(GET A_VERSION 2 patch_vers)
	set(${major} ${major_vers} PARENT_SCOPE)
	set(${minor} ${minor_vers} PARENT_SCOPE)
	set(${patch} ${patch_vers} PARENT_SCOPE)
else()#testing with only two elements
	string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)$" "\\1;\\2" A_VERSION "${version_string}")
	if(NOT A_VERSION STREQUAL "${version_string}") # version string is well formed with major.minor format
		list(GET A_VERSION 0 major_vers)
		list(GET A_VERSION 1 minor_vers)
		set(${major} ${major_vers} PARENT_SCOPE)
		set(${minor} ${minor_vers} PARENT_SCOPE)
		set(${patch} PARENT_SCOPE)
	else() #only a major number ??
		string(REGEX REPLACE "^([0-9]+)$" "\\1" A_VERSION "${version_string}")
		if(NOT A_VERSION STREQUAL "${version_string}") # version string is well formed with major.minor format
			list(GET A_VERSION 0 major_vers)
			set(${major} ${major_vers} PARENT_SCOPE)
			set(${minor} PARENT_SCOPE)
			set(${patch} PARENT_SCOPE)
		else() #not even a number
			message(FATAL_ERROR "[PID] CRITICAL ERROR : corrupted version string ${version_string}.")
		endif()
	endif()
endif()	
endfunction(get_Version_String_Numbers)

###
function(list_Version_Subdirectories result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_DIRECTORY ${curdir}/${child})
			list(APPEND dirlist ${child})
		endif()
	endforeach()
	list(REMOVE_ITEM dirlist "installers")
	set(${result} ${dirlist} PARENT_SCOPE)
endfunction(list_Version_Subdirectories)


###
function(is_Compatible_Version is_compatible reference_major reference_minor version_to_compare)
set(${is_compatible} FALSE PARENT_SCOPE)
get_Version_String_Numbers("${version_to_compare}.0" compare_major compare_minor compared_patch)
if(	NOT ${compare_major} EQUAL ${reference_major}
	OR ${compare_minor} GREATER ${reference_minor})
	return()#not compatible
endif()
set(${is_compatible} TRUE PARENT_SCOPE)
endfunction(is_Compatible_Version)


#############################################################
################ Information about authors ##################
#############################################################

###
function(generate_Full_Author_String author RES_STRING)
string(REGEX REPLACE "^([^\\(]+)\\(([^\\)]*)\\)$" "\\1;\\2" author_institution "${author}")
list(GET author_institution 0 AUTHOR_NAME)
list(GET author_institution 1 INSTITUTION_NAME)
extract_All_Words("${AUTHOR_NAME}" AUTHOR_ALL_WORDS)
extract_All_Words("${INSTITUTION_NAME}" INSTITUTION_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
fill_List_Into_String("${INSTITUTION_ALL_WORDS}" INSTITUTION_STRING)
if(NOT INSTITUTION_STRING STREQUAL "")
	set(${RES_STRING} "${AUTHOR_STRING} (${INSTITUTION_STRING})" PARENT_SCOPE)
else()
	set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
endif()
endfunction()

###
function(generate_Contact_String author mail RES_STRING)
extract_All_Words("${author}" AUTHOR_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
if(mail AND NOT mail STREQUAL "")
	set(${RES_STRING} "${AUTHOR_STRING} (${mail})" PARENT_SCOPE)
else()
	set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
endif()
endfunction()

###
function(generate_Formatted_String input RES_STRING)
extract_All_Words("${input}" INPUT_ALL_WORDS)
fill_List_Into_String("${INPUT_ALL_WORDS}" INPUT_STRING)
set(${RES_STRING} "${INPUT_STRING}" PARENT_SCOPE)
endfunction(generate_Formatted_String)

###
function(get_Formatted_Author_String author RES_STRING)
string(REGEX REPLACE "^([^\\(]+)\\(([^\\)]*)\\)$" "\\1;\\2" author_institution "${author}")
list(LENGTH author_institution SIZE)
if(${SIZE} EQUAL 2)
list(GET author_institution 0 AUTHOR_NAME)
list(GET author_institution 1 INSTITUTION_NAME)
extract_All_Words("${AUTHOR_NAME}" AUTHOR_ALL_WORDS)
extract_All_Words("${INSTITUTION_NAME}" INSTITUTION_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
fill_List_Into_String("${INSTITUTION_ALL_WORDS}" INSTITUTION_STRING)
elseif(${SIZE} EQUAL 1)
list(GET author_institution 0 AUTHOR_NAME)
extract_All_Words("${AUTHOR_NAME}" AUTHOR_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
set(INSTITUTION_STRING "")
endif()
if(NOT INSTITUTION_STRING STREQUAL "")
	set(${RES_STRING} "${AUTHOR_STRING} - ${INSTITUTION_STRING}" PARENT_SCOPE)
else()
	set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
endif()
endfunction(get_Formatted_Author_String)

###
function(get_Formatted_Package_Contact_String package RES_STRING)
extract_All_Words("${${package}_MAIN_AUTHOR}" AUTHOR_ALL_WORDS)
extract_All_Words("${${package}_MAIN_INSTITUTION}" INSTITUTION_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
fill_List_Into_String("${INSTITUTION_ALL_WORDS}" INSTITUTION_STRING)
if(NOT INSTITUTION_STRING STREQUAL "")
	if(${package}_CONTACT_MAIL)
		set(${RES_STRING} "${AUTHOR_STRING} (${${package}_CONTACT_MAIL}) - ${INSTITUTION_STRING}" PARENT_SCOPE)
	else()
		set(${RES_STRING} "${AUTHOR_STRING} - ${INSTITUTION_STRING}" PARENT_SCOPE)
	endif()
else()
	if(${package}_CONTACT_MAIL)
		set(${RES_STRING} "${AUTHOR_STRING} (${${package}_CONTACT_MAIL})" PARENT_SCOPE)
	else()
		set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
	endif()
endif()
endfunction(get_Formatted_Package_Contact_String)

#############################################################
################ Source file management #####################
#############################################################

###
function(get_All_Sources_Relative RESULT dir)
file(	GLOB_RECURSE 
	RES
	RELATIVE ${dir} 
	"${dir}/*.c"
	"${dir}/*.cc"
	"${dir}/*.cpp"
	"${dir}/*.cxx"
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.hh"
	"${dir}/*.hxx"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Sources_Relative)

###
function(get_All_Sources_Absolute RESULT dir)
file(	GLOB_RECURSE 
	RES
	${dir} 
	"${dir}/*.c"
	"${dir}/*.cc"
	"${dir}/*.cpp"
	"${dir}/*.cxx"
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.hh"
	"${dir}/*.hxx"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Sources_Absolute)

###
function(get_All_Headers_Relative RESULT dir)
file(	GLOB_RECURSE 
	RES
	RELATIVE ${dir} 
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.hh"
	"${dir}/*.hxx"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Headers_Relative)

###
function(get_All_Headers_Absolute RESULT dir)
file(	GLOB_RECURSE 
	RES
	${dir} 
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.hh"
	"${dir}/*.hxx"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Headers_Absolute)

###
function(is_Shared_Lib_With_Path SHARED input_link)
set(${SHARED} FALSE PARENT_SCOPE)
get_filename_component(LIB_TYPE ${input_link} EXT)
if(LIB_TYPE)
        if(APPLE)
                if(LIB_TYPE MATCHES "^(\\.[0-9]+)*\\.dylib$")#found shared lib
			set(${SHARED} TRUE PARENT_SCOPE)
		endif()
	elseif(UNIX)
                if(LIB_TYPE MATCHES "^\\.so(\\.[0-9]+)*$")#found shared lib
			set(${SHARED} TRUE PARENT_SCOPE)
		endif()
	endif()
else()
	# no extenion may be possible with MACOSX frameworks
        if(APPLE)
		set(${SHARED} TRUE PARENT_SCOPE)
	endif()
endif()
endfunction(is_Shared_Lib_With_Path)

###
function(is_External_Package_Defined ref_package ext_package mode RES_PATH_TO_PACKAGE)

get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(EXT_PACKAGE-NOTFOUND PARENT_SCOPE)
if(DEFINED ${ref_package}_EXTERNAL_DEPENDENCY_${ext_package}_VERSION${VAR_SUFFIX})
	set(${RES_PATH_TO_PACKAGE} ${WORKSPACE_DIR}/external/${ext_package}/${${ref_package}_EXTERNAL_DEPENDENCY_${ext_package}_VERSION${VAR_SUFFIX}} PARENT_SCOPE)
	return()
elseif(${ref_package}_DEPENDENCIES${mode_suffix}) #the external dependency may be issued from a third party native package
	foreach(dep_pack IN ITEMS ${${ref_package}_DEPENDENCIES${VAR_SUFFIX}})
		is_External_Package_Defined(${dep_pack} ${ext_package} ${mode} PATHTO)
		if(NOT EXT_PACKAGE-NOTFOUND)
			set(${RES_PATH_TO_PACKAGE} ${PATHTO} PARENT_SCOPE)
			return()
		endif()
	endforeach()
endif()
set(EXT_PACKAGE-NOTFOUND TRUE PARENT_SCOPE)
endfunction(is_External_Package_Defined)


###
function(resolve_External_Libs_Path COMPLETE_LINKS_PATH package ext_links mode)
set(res_links)
foreach(link IN ITEMS ${ext_links})
	string(REGEX REPLACE "^<([^>]+)>(.*)" "\\1;\\2" RES ${link})
	if(NOT RES STREQUAL ${link})# a replacement has taken place => this is a full path to a library
		set(fullpath)
		list(GET RES 0 ext_package_name)
		list(GET RES 1 relative_path)
		unset(EXT_PACKAGE-NOTFOUND)
		is_External_Package_Defined(${package} ${ext_package_name} ${mode} PATHTO)
		if(DEFINED EXT_PACKAGE-NOTFOUND)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for link ${link}!! Please set the path to this external package.")		
		else()
			set(fullpath ${PATHTO}${relative_path})
			list(APPEND res_links ${fullpath})				
		endif()
	else() # this may be a link with a prefix (like -L<path>) that need replacement
		string(REGEX REPLACE "^([^<]+)<([^>]+)>(.*)" "\\1;\\2;\\3" RES_WITH_PREFIX ${link})
		if(NOT RES_WITH_PREFIX STREQUAL ${link})# a replacement has taken place
			list(GET RES_WITH_PREFIX 0 link_prefix)
			list(GET RES_WITH_PREFIX 1 ext_package_name)
			is_External_Package_Defined(${package} ${ext_package_name} ${mode} PATHTO)
			if(EXT_PACKAGE-NOTFOUND)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for link ${link}!!")
			endif()
			liST(LENGTH RES_WITH_PREFIX SIZE)
			if(SIZE EQUAL 3)
				list(GET RES_WITH_PREFIX 2 relative_path)
				set(fullpath ${link_prefix}${PATHTO}/${relative_path})
			else()	
				set(fullpath ${link_prefix}${PATHTO})
			endif()
			list(APPEND res_links ${fullpath})
		else()#this is a link that does not require any replacement (e.g. -l<library name> or -L<system path>)
			list(APPEND res_links ${link})
		endif()
	endif()
endforeach()
set(${COMPLETE_LINKS_PATH} ${res_links} PARENT_SCOPE)
endfunction(resolve_External_Libs_Path)

###
function(resolve_External_Includes_Path COMPLETE_INCLUDES_PATH package_context ext_inc_dirs mode)
set(res_includes)
foreach(include_dir IN ITEMS ${ext_inc_dirs})
	string(REGEX REPLACE "^<([^>]+)>(.*)" "\\1;\\2" RES ${include_dir})
	if(NOT RES STREQUAL ${include_dir})# a replacement has taken place => this is a full path to an incude dir of an external package
		list(GET RES 0 ext_package_name)
		is_External_Package_Defined(${package_context} ${ext_package_name} ${mode} PATHTO)
		if(EXT_PACKAGE-NOTFOUND)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for include dir ${include_dir}!! Please set the path to this external package.")
		endif()
		liST(LENGTH RES SIZE)
		if(SIZE EQUAL 2)#the package name has a suffix (relative path)
			list(GET RES 1 relative_path)
			set(fullpath ${PATHTO}${relative_path})
		else()	#no suffix append to the external package name
			set(fullpath ${PATHTO})
		endif()
		list(APPEND res_includes ${fullpath})
	else() # this may be an include dir with a prefix (-I<path>) that need replacement
		string(REGEX REPLACE "^-I<([^>]+)>(.*)" "\\1;\\2" RES_WITH_PREFIX ${include_dir})
		if(NOT RES_WITH_PREFIX STREQUAL ${include_dir})
			list(GET RES_WITH_PREFIX 1 relative_path)
			list(GET RES_WITH_PREFIX 0 ext_package_name)
			is_External_Package_Defined(${package_context} ${ext_package_name} ${mode} PATHTO)
			if(EXT_PACKAGE-NOTFOUND)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for include dir ${include_dir}!! Please set the path to this external package.")
			endif()
			set(fullpath ${PATHTO}${relative_path})
			list(APPEND res_includes ${fullpath})
		else()#this is an include dir that does not require any replacement ! (should be avoided)
			string(REGEX REPLACE "^-I(.+)" "\\1" RES_WITHOUT_PREFIX ${include_dir})			
			if(NOT RES_WITHOUT_PREFIX STREQUAL ${include_dir})
				list(APPEND res_includes ${RES_WITHOUT_PREFIX})
			else()
				list(APPEND res_includes ${include_dir}) #for absolute path or system dependencies simply copying the path
			endif()				
		endif()
	endif()
endforeach()
set(${COMPLETE_INCLUDES_PATH} ${res_includes} PARENT_SCOPE)
endfunction(resolve_External_Includes_Path)


###
function(resolve_External_Resources_Path COMPLETE_RESOURCES_PATH package ext_resources mode)
set(res_resources)
foreach(resource IN ITEMS ${ext_resources})
	string(REGEX REPLACE "^<([^>]+)>(.*)" "\\1;\\2" RES ${resource})
	if(NOT RES STREQUAL ${resource})# a replacement has taken place => this is a relative path to an external package resource
		set(fullpath)
		list(GET RES 0 ext_package_name)
		list(GET RES 1 relative_path)
		unset(EXT_PACKAGE-NOTFOUND)		
		is_External_Package_Defined(${package} ${ext_package_name} ${mode} PATHTO)
		if(DEFINED EXT_PACKAGE-NOTFOUND)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : undefined external package ${ext_package_name} used for resource ${resource}!! Please set the path to this external package.")		
		else()
			set(fullpath ${PATHTO}${relative_path})
			list(APPEND res_resources ${fullpath})				
		endif()
	else()
		list(APPEND res_resources ${resource})	#for  relative path or system dependencies (absolute path) simply copying the path	
	endif()
endforeach()
set(${COMPLETE_RESOURCES_PATH} ${res_resources} PARENT_SCOPE)
endfunction(resolve_External_Resources_Path)


#############################################################
################ Package Life cycle management ##############
#############################################################

###
function(set_Package_Repository_Address package git_url)
	file(READ ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE  "([ \t\n])YEAR" "\\1 ADDRESS ${git_url}\n YEAR" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt ${NEW_CONTENT})
endfunction(set_Package_Repository_Address)

###
function(reset_Package_Repository_Address package new_git_url)
	file(READ ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE "([ \t\n])ADDRESS[ \t\n]+([^ \t\n]+)([ \t\n]+)" "\\1 ADDRESS ${new_git_url}\\3" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt ${NEW_CONTENT})
endfunction(reset_Package_Repository_Address)

###
function(get_Package_Repository_Address package RES_URL)
	file(READ ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt CONTENT)
	string(REGEX REPLACE "^.+[ \t\n]ADDRESS[ \t\n]+([^ \t\n]+)[ \t\n]+.*$" "\\1" url ${CONTENT})
	if(url STREQUAL "${CONTENT}")#no match
		set(${RES_URL} "" PARENT_SCOPE)
		return()
	endif()
	set(${RES_URL} ${url} PARENT_SCOPE)
endfunction(get_Package_Repository_Address)

###
function(list_All_Source_Packages_In_Workspace PACKAGES)
file(GLOB source_packages RELATIVE ${WORKSPACE_DIR}/packages ${WORKSPACE_DIR}/packages/*)
foreach(a_file IN ITEMS ${source_packages})
	if(EXISTS ${WORKSPACE_DIR}/packages/${a_file} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${a_file})
		list(APPEND result ${a_file})
	endif()
endforeach()
set(${PACKAGES} ${result} PARENT_SCOPE)
endfunction(list_All_Source_Packages_In_Workspace)

###
function(list_All_Binary_Packages_In_Workspace NATIVE_PACKAGES EXTERNAL_PACKAGES)
file(GLOB bin_pakages RELATIVE ${WORKSPACE_DIR}/install ${WORKSPACE_DIR}/install/*)
foreach(a_file IN ITEMS ${bin_pakages})
	if(EXISTS ${WORKSPACE_DIR}/install/${a_file} AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${a_file})
		list(APPEND result ${a_file})
	endif()
endforeach()
set(${NATIVE_PACKAGES} ${result} PARENT_SCOPE)
set(result)
file(GLOB ext_pakages RELATIVE ${WORKSPACE_DIR}/external ${WORKSPACE_DIR}/external/*)
foreach(a_file IN ITEMS ${ext_pakages})
	if(EXISTS ${WORKSPACE_DIR}/external/${a_file} AND IS_DIRECTORY ${WORKSPACE_DIR}/external/${a_file})
		list(APPEND result ${a_file})
	endif()
endforeach()

set(${EXTERNAL_PACKAGES} ${result} PARENT_SCOPE)
endfunction(list_All_Binary_Packages_In_Workspace)


###
function(package_Already_Built answer package reference_package)
set(${answer} FALSE PARENT_SCOPE)
if(EXISTS ${WORKSPACE_DIR}/packages/${package}/build/build_process)
	if(${WORKSPACE_DIR}/packages/${package}/build/build_process IS_NEWER_THAN ${WORKSPACE_DIR}/packages/${reference_package}/build/build_process)
		set(${answer} TRUE PARENT_SCOPE)
	endif()
endif()
endfunction(package_Already_Built)


###
function(test_Modified_Components package build_tool result)
set(${result} FALSE PARENT_SCOPE)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package}/build/release ${build_tool} cmake_check_build_system OUTPUT_VARIABLE NEED_UPDATE)
if(NOT NEED_UPDATE STREQUAL "")
	set(${result} TRUE PARENT_SCOPE)
endif() 
endfunction(test_Modified_Components)


###
function(get_Version_Number_And_Repo_From_Package package NUMBER STRING_NUMBER ADDRESS)
set(${ADDRESS} PARENT_SCOPE)
file(STRINGS ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt PACKAGE_METADATA) #getting global info on the package
foreach(line IN ITEMS ${PACKAGE_METADATA})
	string(REGEX REPLACE "^.*set_PID_Package_Version\\(([0-9]+)(\\ +)([0-9]+)(\\ *)([0-9]*)(\\ *)\\).*$" "\\1;\\3;\\5" A_VERSION ${line})
	if(NOT "${line}" STREQUAL "${A_VERSION}")
		set(VERSION_COMMAND ${A_VERSION})#only taking the last instruction since it shadows previous ones
	endif()
	string(REGEX REPLACE "^.*ADDRESS[\\ \\\t]+([^\\ \\\t]+\\.git).*$" "\\1" AN_ADDRESS ${line})
	if(NOT "${line}" STREQUAL "${AN_ADDRESS}")
		set(${ADDRESS} ${AN_ADDRESS} PARENT_SCOPE)#an address had been found
	endif()
endforeach()
if(VERSION_COMMAND)
	#from here we are sure there is at least 2 digits 
	list(GET VERSION_COMMAND 0 MAJOR)
	list(GET VERSION_COMMAND 1 MINOR)
	list(LENGTH VERSION_COMMAND size_of_version)
	if(NOT size_of_version GREATER 2)
		set(PATCH 0)
		list(APPEND VERSION_COMMAND 0)
	else()
		list(GET VERSION_COMMAND 2 PATCH)
	endif()
	set(${STRING_NUMBER} "${MAJOR}.${MINOR}.${PATCH}" PARENT_SCOPE)
else()
	set(${STRING_NUMBER} "" PARENT_SCOPE)
endif()

set(${NUMBER} ${VERSION_COMMAND} PARENT_SCOPE)
endfunction(get_Version_Number_And_Repo_From_Package)

###
function(set_Version_Number_To_Package package major minor patch)

file(READ ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt PACKAGE_METADATA) #getting global info on the package
string(REGEX REPLACE "^(.*)set_PID_Package_Version\\(([0-9]+)(\\ +)([0-9]+)(\\ *)([0-9]*)(\\ *)\\)(.*)$" "\\1;\\8" PACKAGE_METADATA_WITHOUT_VERSION ${PACKAGE_METADATA})

list(GET PACKAGE_METADATA_WITHOUT_VERSION 0 BEGIN)
list(GET PACKAGE_METADATA_WITHOUT_VERSION 1 END)

set(TO_WRITE "${BEGIN}set_PID_Package_Version(${major} ${minor} ${patch})${END}")
file(WRITE ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt ${TO_WRITE}) #getting global info on the package

endfunction(set_Version_Number_To_Package)

###
function(is_Binary_Package_Version_In_Development RESULT package version)
set(${RESULT} FALSE PARENT_SCOPE)
set(USE_FILE ${WORKSPACE_DIR}/install/${package}/${version}/share/Use${package}-${version}.cmake) 
if(EXISTS ${USE_FILE}) #file does not exists means the target version is not in development
	set(PID_VERSION_FILE ${WORKSPACE_DIR}/install/${package}/${version}/share/cmake/${package}_PID_Version.cmake)
	if(EXISTS ${PID_VERSION_FILE})
		include(${PID_VERSION_FILE})
		PID_Package_Is_With_Development_Info_In_Use_Files(RES ${package})
		if(RES)
			include(${USE_FILE})#include the definitions
			if(${package}_DEVELOPMENT_STATE STREQUAL "development") #this binary package has been built from a development branch
				set(${RESULT} TRUE PARENT_SCOPE)
			endif()
		endif()
	endif()
endif()
endfunction(is_Binary_Package_Version_In_Development)


