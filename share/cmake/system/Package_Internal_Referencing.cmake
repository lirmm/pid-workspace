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
#	You can be find the complete license description on the official website 	#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################

#############################################################################################
############### API functions for managing references on dependent packages #################
#############################################################################################

### generate the reference file used to retrieve packages
function(generate_Reference_File pathtonewfile)
set(file ${pathtonewfile})
file(WRITE ${file} "")
file(APPEND ${file} "#### referencing package ${PROJECT_NAME} mode ####\n")
file(APPEND ${file} "set(${PROJECT_NAME}_MAIN_AUTHOR ${${PROJECT_NAME}_MAIN_AUTHOR} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_MAIN_INSTITUTION ${${PROJECT_NAME}_MAIN_INSTITUTION} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_CONTACT_MAIL ${${PROJECT_NAME}_CONTACT_MAIL} CACHE INTERNAL \"\")\n")
set(res_string "")
foreach(auth IN ITEMS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS})
	set(res_string "${res_string}; \"${auth}\"")
endforeach()
file(APPEND ${file} "set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS ${res_string} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_DESCRIPTION ${${PROJECT_NAME}_DESCRIPTION} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_YEARS ${${PROJECT_NAME}_YEARS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_LICENSE ${${PROJECT_NAME}_LICENSE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_ADDRESS ${${PROJECT_NAME}_ADDRESS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_CATEGORIES ${${PROJECT_NAME}_CATEGORIES} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCES ${${PROJECT_NAME}_REFERENCES} CACHE INTERNAL \"\")\n")
foreach(ref_version IN ITEMS ${${PROJECT_NAME}_REFERENCES})
	file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version} ${${PROJECT_NAME}_REFERENCE_${ref_version}} CACHE INTERNAL \"\")\n")
	foreach(ref_system IN ITEMS ${${PROJECT_NAME}_REFERENCE_${ref_version}})
		file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_system} ${${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_system}} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_system}_DEBUG ${${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_system}_DEBUG} CACHE INTERNAL \"\")\n")
		set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_system} CACHE INTERNAL "")
	endforeach()
endforeach()
endfunction(generate_Reference_File)

###
function(resolve_Package_Dependencies package mode)
#message("DEBUG resolve_Package_Dependencies package=${package} mode=${mode}")
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

################## external packages ##################

# 1) managing external package dependencies (the list of dependent packages is defined as ${package}_EXTERNAL_DEPENDENCIES)
# - locating dependent external packages in the workspace and configuring their build variables recursively
set(TO_INSTALL_EXTERNAL_DEPS)
foreach(dep_ext_pack IN ITEMS ${${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}})
	# 1) resolving direct dependencies
	
	resolve_External_Package_Dependency(${package} ${dep_ext_pack} ${mode})
	if(NOT ${dep_ext_pack}_FOUND)
		list(APPEND TO_INSTALL_EXTERNAL_DEPS ${dep_ext_pack})
	endif()
endforeach()

# 2) for not found package
if(TO_INSTALL_EXTERNAL_DEPS) #there are dependencies to install
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		set(INSTALLED_EXTERNAL_PACKAGES "")
		install_Required_External_Packages("${TO_INSTALL_EXTERNAL_DEPS}" INSTALLED_EXTERNAL_PACKAGES)
		foreach(installed IN ITEMS ${INSTALLED_EXTERNAL_PACKAGES})#recursive call for newly installed packages
			resolve_External_Package_Dependency(${package} ${installed} ${mode})
			if(NOT ${installed}_FOUND)
				message(FATAL_ERROR "BUG : impossible to find installed external package ${installed}")
			endif()
		endforeach()
	else()	
		message(FATAL_ERROR "there are some unresolved required external package dependencies : ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${VAR_SUFFIX}}. You may download them \"by hand\" or use the required packages automatic download option")
		return()
	endif()
endif()

################## native packages ##################

# 1) managing package dependencies (the list of dependent packages is defined as ${package}_DEPENDENCIES)
# - locating dependent packages in the workspace and configuring their build variables recursively
set(TO_INSTALL_DEPS)
foreach(dep_pack IN ITEMS ${${package}_DEPENDENCIES${VAR_SUFFIX}})
	# 1) resolving direct dependencies
	resolve_Package_Dependency(${package} ${dep_pack} ${mode})
	if(${dep_pack}_FOUND)
		if(${dep_pack}_DEPENDENCIES${VAR_SUFFIX})
			resolve_Package_Dependencies(${dep_pack} ${mode})#recursion : resolving dependencies for each package dependency
		endif()
	else()
		list(APPEND TO_INSTALL_DEPS ${dep_pack})
	endif()
endforeach()

# 2) for not found package
if(TO_INSTALL_DEPS) #there are dependencies to install
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		set(INSTALLED_PACKAGES "")
		install_Required_Packages("${TO_INSTALL_DEPS}" INSTALLED_PACKAGES)
		foreach(installed IN ITEMS ${INSTALLED_PACKAGES})#recursive call for newly installed packages
			resolve_Package_Dependency(${package} ${installed} ${mode})
			if(${installed}_FOUND)
				if(${installed}_DEPENDENCIES${VAR_SUFFIX})
					resolve_Package_Dependencies(${installed} ${mode})#recursion : resolving dependencies for each package dependency
				endif()
			else()
				message(FATAL_ERROR "BUG : impossible to find installed package ${installed}")
			endif()	
		endforeach()
	else()	
		message(FATAL_ERROR "there are some unresolved required package dependencies : ${${PROJECT_NAME}_TOINSTALL_PACKAGES${VAR_SUFFIX}}. You may download them \"by hand\" or use the required packages automatic download option")
		return()
	endif()
endif()
endfunction(resolve_Package_Dependencies)

#############################################################################################
############################### functions for Native Packages ###############################
#############################################################################################

###
function(resolve_Required_Package_Version version_possible min_version is_exact package)

foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX}})
	get_Version_String_Numbers("${version}.0" compare_major compare_minor compared_patch)
	if(NOT MAJOR_RESOLVED)#first time
		set(MAJOR_RESOLVED ${compare_major})
		set(CUR_MINOR_RESOLVED ${compare_minor})
		if(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX})
			set(CURR_EXACT TRUE)
		else()
			set(CURR_EXACT FALSE)
		endif()
	elseif(NOT compare_major EQUAL ${MAJOR_RESOLVED})
		set(${version_possible} FALSE PARENT_SCOPE)
		return()
	elseif(CURR_EXACT AND (compare_minor GREATER ${CUR_MINOR_RESOLVED}))
		set(${version_possible} FALSE PARENT_SCOPE)
		return()
	elseif(NOT CURR_EXACT AND (compare_minor GREATER ${CUR_MINOR_RESOLVED}))
		set(CUR_MINOR_RESOLVED ${compare_minor})
		if(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX})
			set(CURR_EXACT TRUE)
		else()
			set(CURR_EXACT FALSE)
		endif()
	endif()
endforeach()
set(${version_possible} TRUE PARENT_SCOPE)
set(${min_version} "${MAJOR_RESOLVED}.${CUR_MINOR_RESOLVED}" PARENT_SCOPE)
set(${is_exact} ${CURR_EXACT} PARENT_SCOPE)
endfunction(resolve_Required_Package_Version)

### 


### root function for launching automatic installation process
function(install_Required_Packages list_of_packages_to_install INSTALLED_PACKAGES)
set(successfully_installed "")
set(not_installed "")
foreach(dep_package IN ITEMS ${list_of_packages_to_install}) #while there are still packages to install
	#message("DEBUG : install required packages : ${dep_package}")
	set(INSTALL_OK FALSE)
	install_Package(INSTALL_OK ${dep_package})
	if(INSTALL_OK)
		list(APPEND successfully_installed ${dep_package})
	else()
		list(APPEND not_installed ${dep_package})
	endif()
endforeach()
if(successfully_installed)
	set(${INSTALLED_PACKAGES} ${successfully_installed} PARENT_SCOPE)
endif()
if(not_installed)
	message("[ERROR] : Some of the required packages cannot be installed : ${not_installed}")
endif()
endfunction(install_Required_Packages)

###
function(package_Source_Exists_In_Workspace EXIST RETURNED_PATH package)
set(res FALSE)
if(EXISTS ${WORKSPACE_DIR}/packages/${package} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
set(res TRUE)
set(${RETURNED_PATH} ${WORKSPACE_DIR}/packages/${package} PARENT_SCOPE)
endif()
set(${EXIST} ${res} PARENT_SCOPE)
endfunction(package_Source_Exists_In_Workspace) 

###
function(package_Reference_Exists_In_Workspace EXIST package)
set(res FALSE)
if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/Refer${package}.cmake)
set(res TRUE)
endif()
set(${EXIST} ${res} PARENT_SCOPE)
endfunction(package_Reference_Exists_In_Workspace) 

###
function(get_Package_References LIST_OF_REFS package)
include(Refer${package} OPTIONAL RESULT_VARIABLE res)
if(	${res} STREQUAL NOTFOUND) #if there is no component defined for the package there is an error
	set(${EXIST} ${FALSE} PARENT_SCOPE)
	return()
endif()
set(${EXIST} ${FALSE} PARENT_SCOPE)
endfunction(get_Package_References)


###
function(install_Package INSTALL_OK package)

# 0) test if either reference or source of the package exist in the workspace
set(IS_EXISTING FALSE)  
set(PATH_TO_SOURCE "")
package_Source_Exists_In_Workspace(IS_EXISTING PATH_TO_SOURCE ${package})
if(IS_EXISTING)
	set(USE_SOURCES TRUE)
else()
	set(IS_EXISTING)
	package_Reference_Exists_In_Workspace(IS_EXISTING ${package})
	if(IS_EXISTING)
		#message("DEBUG package ${package} reference exists in workspace !")
		set(USE_SOURCES FALSE)
	else()
		set(${INSTALL_OK} FALSE PARENT_SCOPE)
		message("[ERROR] : Unknown package ${package} : cannot find any source or reference of this package in the workspace")
		return()
	endif()
endif()
#message("DEBUG required versions = ${${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX}}")
if(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX})
# 1) resolve finally required package version (if any specific version required) (major.minor only, patch is let undefined)
	set(POSSIBLE FALSE)
	set(VERSION_MIN)
	set(EXACT FALSE)
	resolve_Required_Package_Version(POSSIBLE VERSION_MIN EXACT ${package})
	if(NOT POSSIBLE)
		message("[ERROR] : impossible to find an adequate version for package ${package}")
		set(${INSTALL_OK} FALSE PARENT_SCOPE)
		return()
	endif()
	#message("DEBUG a min version has been chosen : ${VERSION_MIN} and is exact ? = ${EXACT}")
	set(NO_VERSION FALSE)	
else()
	set(NO_VERSION TRUE)
endif()

if(USE_SOURCES) #package sources reside in the workspace
	set(SOURCE_DEPLOYED FALSE)
	if(NOT NO_VERSION)
		deploy_Source_Package_Version(SOURCE_DEPLOYED ${package} ${VERSION_MIN} ${EXACT})
	else()
		deploy_Source_Package(SOURCE_DEPLOYED ${package}) # case when the sources exist but haven't been installed yet (should never happen)
	endif()
	if(NOT SOURCE_DEPLOYED)
		message("[ERROR] : impossible to build the sources of package ${package}. Try \"by hand\".")
	else()
		set(${INSTALL_OK} TRUE PARENT_SCOPE)
	endif()
else()#using references
	include(Refer${package} OPTIONAL RESULT_VARIABLE refer_path)
	set(PACKAGE_BINARY_DEPLOYED FALSE)
	if(NOT ${refer_path} STREQUAL NOTFOUND)
		#message("DEBUG : trying to deploy a binary package !!")
		if(NOT NO_VERSION)#seeking for an adequate version regarding the pattern VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the greatest minor version number 
			deploy_Binary_Package_Version(PACKAGE_BINARY_DEPLOYED ${package} ${VERSION_MIN} ${EXACT})
		else()# deploying the most up to date version
			deploy_Binary_Package(PACKAGE_BINARY_DEPLOYED ${package})
		endif()
	else()
		message("[ERROR] : reference file not found for package ${package}!! This is maybe due to a bad release of package ${package}. Please contact the administrator of this package. !!!")
	endif()
	
	if(PACKAGE_BINARY_DEPLOYED) # if there is ONE adequate reference, downloading and installing it
		set(${INSTALL_OK} TRUE PARENT_SCOPE)
	else()# otherwise, trying to "git clone" the package source (if it can be accessed)
		set(DEPLOYED FALSE)
		deploy_Package_Repository(DEPLOYED ${package})
		if(DEPLOYED) # doing the same as for the USE_SOURCES step
			set(SOURCE_DEPLOYED FALSE)		
			if(NOT NO_VERSION)
				deploy_Source_Package_Version(SOURCE_DEPLOYED ${package} ${VERSION_MIN} ${EXACT})
			else()
				deploy_Source_Package(SOURCE_DEPLOYED ${package})
			endif()
			if(NOT SOURCE_DEPLOYED)
				set(${INSTALL_OK} FALSE PARENT_SCOPE)				
				message("[ERROR]  : impossible to build the package sources ${package}. Try \"by hand\".")
				return()
			endif()
			set(${INSTALL_OK} TRUE PARENT_SCOPE)
		else()
			set(${INSTALL_OK} FALSE PARENT_SCOPE)
			message("[ERROR] : impossible to locate source repository of package ${package}")			
			return()
		endif()
	endif()
endif()
endfunction(install_Package)


###
function(deploy_Package_Repository IS_DEPLOYED package)
if(${package}_ADDRESS)
	clone_Repository(DEPLOYED ${package} ${${package}_ADDRESS})
	set(${IS_DEPLOYED} ${DEPLOYED} PARENT_SCOPE)
else()
	set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
	message("[ERROR] : impossible to clone the repository of package ${package} (no repository address defined). This is maybe due to a malformed package, please contact the administrator of this package.")
endif()
endfunction(deploy_Package_Repository)


###
function(get_Available_Binary_Package_Versions package list_of_versions)

#configuring target system
get_System_Variables(OS_STRING PACKAGE_STRING)
# listing available binaries of the package and searching if there is any "good version"
set(available_binary_package_version "") 
foreach(ref_version IN ITEMS ${${package}_REFERENCES})
	foreach(ref_system IN ITEMS ${${package}_REFERENCE_${ref_version}})
		if(${ref_system} STREQUAL ${OS_STRING})		
			list(APPEND available_binary_package_version ${ref_version})
		endif()
	endforeach()
endforeach()
if(NOT available_binary_package_version)
	return()#nothing to do
endif()
list(REMOVE_DUPLICATES available_binary_package_version)
set(${list_of_versions} ${available_binary_package_version} PARENT_SCOPE)
endfunction(get_Available_Binary_Package_Versions)


###
function(deploy_Binary_Package DEPLOYED package)
set(available_versions "")
get_Available_Binary_Package_Versions(${package} available_versions)
if(NOT available_versions)
	set(${DEPLOYED} FALSE PARENT_SCOPE)
endif()

select_Last_Version(RES_VERSION "${available_versions}")# taking the most up to date version

set(INSTALLED FALSE)
download_And_Install_Binary_Package(INSTALLED ${package} "${RES_VERSION}")
if(INSTALLED)
	set(${DEPLOYED} TRUE PARENT_SCOPE)
else()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
endif()
endfunction(deploy_Binary_Package)

###
function(deploy_Binary_Package_Version DEPLOYED package VERSION_MIN EXACT)
set(available_versions "")
get_Available_Binary_Package_Versions(${package} available_versions)
if(NOT available_versions)
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()

if(EXACT)
	select_Exact_Version(RES_VERSION ${VERSION_MIN} "${available_versions}")
else()
	select_Best_Version(RES_VERSION ${VERSION_MIN} "${available_versions}")
endif()
set(INSTALLED FALSE)
if(RES_VERSION)
	download_And_Install_Binary_Package(INSTALLED ${package} "${RES_VERSION}")
endif()
if(INSTALLED)
	set(${DEPLOYED} TRUE PARENT_SCOPE)
else()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
endif()
endfunction(deploy_Binary_Package_Version)

###
function(generate_Binary_Package_Name package version mode RES_FILE RES_FOLDER)
get_System_Variables(OS_STRING PACKAGE_STRING)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

set(${RES_FILE} "${package}-${version}${TARGET_SUFFIX}-${PACKAGE_STRING}.tar.gz" PARENT_SCOPE)
set(${RES_FOLDER} "${package}-${version}${TARGET_SUFFIX}-${PACKAGE_STRING}" PARENT_SCOPE)
endfunction(generate_Binary_Package_Name)

###
function(download_And_Install_Binary_Package INSTALLED package version_string)
get_System_Variables(OS_STRING PACKAGE_STRING)
###### downloading the binary package ######
#release code
set(FILE_BINARY "")
set(FOLDER_BINARY "")
message("download_And_Install_Binary_Package package=${package} version=${version_string}")
generate_Binary_Package_Name(${package} "${version_string}" Release FILE_BINARY FOLDER_BINARY)
set(download_url ${${package}_REFERENCE_${version_string}_${OS_STRING}})
file(DOWNLOAD ${download_url} ${CMAKE_BINARY_DIR}/share/${FILE_BINARY} STATUS res SHOW_PROGRESS)
list(GET res 0 numeric_error)
list(GET res 1 status)
if(NOT numeric_error EQUAL 0)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message("[ERROR] : problem when downloading binary version ${version_string} of package ${package} from address ${download_url}: ${status}")
	return()
endif()

#debug code 
set(FILE_BINARY_DEBUG "")
set(FOLDER_BINARY_DEBUG "")
generate_Binary_Package_Name(${package} ${version_string} "Debug" FILE_BINARY_DEBUG FOLDER_BINARY_DEBUG)
set(download_url_dbg ${${package}_REFERENCE_${version_string}_${OS_STRING}_url_DEBUG})
file(DOWNLOAD ${download_url_dbg} ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG} STATUS res-dbg SHOW_PROGRESS)
list(GET res-dbg 0 numeric_error_dbg)
list(GET res-dbg 1 status_dbg)
if(NOT numeric_error_dbg EQUAL 0)#there is an error
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message("[ERROR] : problem when downloading binary version ${version_string} of package ${package} from address ${download_url_dbg} : ${status_dbg}")
	return()
endif()

######## installing the package ##########
# 1) creating the package root folder
if(NOT EXISTS ${WORKSPACE_DIR}/install/${package} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/install/${package})
	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${package}
			WORKING_DIRECTORY ${WORKSPACE_DIR}/install/
			ERROR_QUIET OUTPUT_QUIET)
endif()

# 2) extracting binary archive in a cross platform way
set(error_res "")
execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY}
          	COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
		ERROR_VARIABLE error_res OUTPUT_QUIET)
if (error_res)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message(WARNING "install : cannot extract binary archives ${FILE_BINARY} ${FILE_BINARY_DEBUG}")
	return()
endif()

# 3) copying resulting folders into the install path in a cross platform way
set(error_res "")
execute_process(
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/${FOLDER_BINARY} ${WORKSPACE_DIR}/install/${package}
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/${FOLDER_BINARY_DEBUG} ${WORKSPACE_DIR}/install/${package}
	ERROR_VARIABLE error_res OUTPUT_QUIET)

if (error_res)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message(WARNING "install : cannot extract version folder from ${FOLDER_BINARY} and ${FOLDER_BINARY_DEBUG}")
	return()
endif()

############ post install configuration of the workspace ############
set(PACKAGE_NAME ${package})
set(PACKAGE_VERSION ${version_string})
include(${WORKSPACE_DIR}/share/cmake/system/Bind_PID_Package.cmake)
if(NOT ${PACKAGE_NAME}_BINDED_AND_INSTALLED)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message(WARNING "install : cannot configure runtime dependencies for installed version ${version_string} of package ${package}")
	return()
endif()
set(${INSTALLED} TRUE PARENT_SCOPE)
endfunction(download_And_Install_Binary_Package)

### 
function(build_And_Install_Source DEPLOYED package version)
	if(NOT EXISTS ${WORKSPACE_DIR}/packages/${package}/build/CMakeCache.txt)	
		#first step populating the cache if needed		
		execute_process(
			COMMAND ${CMAKE_COMMAND} ..
			WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build
			ERROR_QUIET OUTPUT_QUIET
			)
	endif()	
	execute_process(
		COMMAND ${CMAKE_COMMAND} -D BUILD_EXAMPLES:BOOL=OFF -D GENERATE_INSTALLER:BOOL=OFF -D BUILD_API_DOC:BOOL=OFF -D BUILD_LATEX_API_DOC:BOOL=OFF -D BUILD_AND_RUN_TESTS:BOOL=OFF -D REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD:BOOL=ON -D ENABLE_PARALLEL_BUILD:BOOL=ON  ..
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build
		)
	execute_process(
		COMMAND ${CMAKE_BUILD_TOOL} build
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build
		)
	if(EXISTS ${WORKSPACE_DIR}/install/${package}/${version}/share/Use${package}-${version}.cmake)
		set(${DEPLOYED} TRUE PARENT_SCOPE)
	else()
		set(${DEPLOYED} FALSE PARENT_SCOPE)
	endif()

endfunction(build_And_Install_Source)

###
function(deploy_Source_Package DEPLOYED package)
# go to package source and find all version matching the pattern of VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the greatest version number 
set(${DEPLOYED} FALSE PARENT_SCOPE)
save_Repository_Context(CURRENT_COMMIT SAVED_CONTENT ${package})
update_Repository_Versions(${package}) # updating the local repository to get all available released modifications
get_Repository_Version_Tags(GIT_VERSIONS ${package})
if(NOT GIT_VERSIONS) #no version available => BUG
	message("[ERROR] : no version available for source package ${package}. Maybe this is a malformed package, please contact the administrator of this package.")
	restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
	return()
endif()

normalize_Version_Tags(VERSION_NUMBERS "${GIT_VERSIONS}") #getting standard version number depending on value of tags
select_Last_Version(RES_VERSION "${VERSION_NUMBERS}")
if(NOT RES_VERSION)
	message("[ERROR] : no version found for package ${package} !! Maybe this is due to a malformed package. Please contact the administrator of this package.")
	restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
	return()
endif()

set(ALL_IS_OK FALSE)
build_And_Install_Package(ALL_IS_OK ${package} "${RES_VERSION}")

if(ALL_IS_OK)
	set(${DEPLOYED} TRUE PARENT_SCOPE)
else()
	message("[ERROR] : automatic build and install of package ${package} FAILED !!")
endif()
restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
endfunction(deploy_Source_Package)

###
function(deploy_Source_Package_Version DEPLOYED package VERSION_MIN EXACT)

# go to package source and find all version matching the pattern of VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the greatest version number
save_Repository_Context(CURRENT_COMMIT SAVED_CONTENT ${package})
update_Repository_Versions(${package}) # updating the local repository to get all available modifications
get_Repository_Version_Tags(GIT_VERSIONS ${package}) #get all version tags
if(NOT GIT_VERSIONS) #no version available => BUG
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
	return()
endif()

normalize_Version_Tags(VERSION_NUMBERS "${GIT_VERSIONS}")

if(EXACT)
	select_Exact_Version(RES_VERSION ${VERSION_MIN} "${VERSION_NUMBERS}")
else()
	select_Best_Version(RES_VERSION ${VERSION_MIN} "${VERSION_NUMBERS}")
endif()
if(NOT RES_VERSION)
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
	return()
endif()
set(ALL_IS_OK FALSE)
build_And_Install_Package(ALL_IS_OK ${package} "${RES_VERSION}")
if(ALL_IS_OK)
	set(${DEPLOYED} TRUE PARENT_SCOPE)
else()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
endif()
restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
endfunction(deploy_Source_Package_Version)

###
function(build_And_Install_Package DEPLOYED package version)

# 1) going to the adequate git tag matching the selected version
go_To_Version(${package} ${version})
# 2) building sources
set(IS_BUILT FALSE)

build_And_Install_Source(IS_BUILT ${package} ${version})

if(IS_BUILT)
	set(${DEPLOYED} TRUE PARENT_SCOPE)
else()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
endif()
endfunction(build_And_Install_Package)


#############################################################################################
############################### functions for external Packages #############################
#############################################################################################

###
function(resolve_Required_External_Package_Version selected_version package)
if(NOT ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX})#no specific version required
	if(${package}_REFERENCES)
		#simply searching to most up to date one in available references
		set(CURRENT_VERSION 0.0.0)
		foreach(ref IN ITEMS ${${package}_REFERENCES})
			if(ref VERSION_GREATER ${CURRENT_VERSION})
				set(CURRENT_VERSION ${ref})
			endif()
		endforeach()
		set(${selected_version} "${CURRENT_VERSION}" PARENT_SCOPE)
		return()
	else()
		set(${selected_version} PARENT_SCOPE)
		message("[ERROR] : Impossible to find a valid reference to any version of external package ${package}")
		return()
	endif()

else()#specific version(s) required
	list(REMOVE_DUPLICATES ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX})
	#1) testing if a solution exists as regard of "exactness" of versions	
	set(CURRENT_EXACT FALSE)
	set(CURRENT_VERSION)
	foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX}})
		if(CURRENT_EXACT)
			if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX}) #impossible to find two different exact versions solution
				set(${selected_version} PARENT_SCOPE)
				return()
			elseif(${version} VERSION_GREATER ${CURRENT_VERSION})#any not exact version that is greater than current exact one makes the solution impossible 
				set(${selected_version} PARENT_SCOPE)
				return()
			endif()

		else()
			if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX})
				if(NOT CURRENT_VERSION OR CURRENT_VERSION VERSION_LESS ${version})			
					set(CURRENT_EXACT TRUE)
					set(CURRENT_VERSION ${version})
				else()# current version is greater than exact one currently required => impossible 
					set(${selected_version} PARENT_SCOPE)
					return()
				endif()

			else()#getting the greater minimal required version
				if(NOT CURRENT_VERSION OR CURRENT_VERSION VERSION_LESS ${version})
					set(CURRENT_VERSION ${version})
				endif()
			endif()
			
		endif()
		
	endforeach()
	#2) testing if a solution exists as regard of "compatibility" of versions
	foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX}})
		if(NOT ${version} VERSION_EQUAL ${CURRENT_VERSION})
			if(DEFINED ${package}_REFERENCE_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO
			AND NOT ${CURRENT_VERSION} VERSION_LESS ${package}_REFERENCE_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO) #current version not compatible with the version
				set(${selected_version} PARENT_SCOPE)
				return()
			endif()
		endif()
	endforeach()

endif()

set(${selected_version} "${CURRENT_VERSION}" PARENT_SCOPE)
endfunction(resolve_Required_External_Package_Version)


###
function(install_External_Package INSTALL_OK package)

# 0) test if reference of the external package exists in the workspace
set(IS_EXISTING FALSE)  
package_Reference_Exists_In_Workspace(IS_EXISTING External${package})
if(NOT IS_EXISTING)
	set(${INSTALL_OK} FALSE PARENT_SCOPE)
	message("[ERROR] : Unknown external package ${package} : cannot find any reference of this package in the workspace")
	return()
endif()
include(ReferExternal${package} OPTIONAL RESULT_VARIABLE refer_path)
if(${refer_path} STREQUAL NOTFOUND)
	message("[ERROR] : Reference file not found for package ${package}!! This is certainly due to a bad released package. please ocntact the administrator or that package !!!")
	return()
endif()

# 1) resolve finally required package version (if any specific version required) (major.minor only, patch is let undefined)
set(SELECTED)
resolve_Required_External_Package_Version(SELECTED ${package})
if(SELECTED)
	#2) installing package
	set(PACKAGE_BINARY_DEPLOYED FALSE)
	deploy_External_Package_Version(PACKAGE_BINARY_DEPLOYED ${package} ${SELECTED})
	if(PACKAGE_BINARY_DEPLOYED) # if there is ONE adequate reference, downloading and installing it
		set(${INSTALL_OK} TRUE PARENT_SCOPE)
		return()
	endif()
else()
	message("[ERROR] : impossible to find an adequate version for external package ${package}")
endif()

set(${INSTALL_OK} FALSE PARENT_SCOPE)	
endfunction(install_External_Package)

###
function(install_Required_External_Packages list_of_packages_to_install INSTALLED_PACKAGES)
set(successfully_installed "")
set(not_installed "")
foreach(dep_package IN ITEMS ${list_of_packages_to_install}) #while there are still packages to install
	set(INSTALL_OK FALSE)
	install_External_Package(INSTALL_OK ${dep_package})
	if(INSTALL_OK)
		list(APPEND successfully_installed ${dep_package})
	else()
		list(APPEND not_installed ${dep_package})
	endif()
endforeach()
if(successfully_installed)
	set(${INSTALLED_PACKAGES} ${successfully_installed} PARENT_SCOPE)
endif()
if(not_installed)
	message("[ERROR] : Some of the required external packages cannot be installed : ${not_installed}")
endif()
endfunction(install_Required_External_Packages)


###
function(deploy_External_Package_Version DEPLOYED package VERSION)
set(INSTALLED FALSE)
#begin
get_System_Variables(OS_STRING PACKAGE_STRING)
###### downloading the binary package ######
message("downloading the binary package, please wait ...")
#1) release code
set(FILE_BINARY "")
set(FOLDER_BINARY "")
generate_Binary_Package_Name(${package} ${VERSION} "Release" FILE_BINARY FOLDER_BINARY)
set(download_url ${${package}_REFERENCE_${VERSION}_${OS_STRING}_url})
set(FOLDER_BINARY ${${package}_REFERENCE_${VERSION}_${OS_STRING}_folder})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory release
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
			ERROR_QUIET OUTPUT_QUIET)
file(DOWNLOAD ${download_url} ${CMAKE_BINARY_DIR}/share/release/${FILE_BINARY} STATUS res SHOW_PROGRESS TLS_VERIFY OFF)
list(GET res 0 numeric_error)
list(GET res 1 status)
if(NOT numeric_error EQUAL 0)
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	message("[ERROR] : problem when downloading binary version ${VERSION} of package ${package} from address ${download_url}: ${status}")
	return()
endif()
#2) debug code (optionnal for external packages => just to avoid unecessary redoing code download)
if(EXISTS ${package}_REFERENCE_${VERSION}_${OS_STRING}_url_DEBUG)
	set(FILE_BINARY_DEBUG "")
	set(FOLDER_BINARY_DEBUG "")
	generate_Binary_Package_Name(${package} ${VERSION} "Debug" FILE_BINARY_DEBUG FOLDER_BINARY_DEBUG)
	set(download_url_dbg ${${package}_REFERENCE_${VERSION}_${OS_STRING}_url_DEBUG})
	set(FOLDER_BINARY_DEBUG ${${package}_REFERENCE_${VERSION}_${OS_STRING}_folder_DEBUG})
	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory debug
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
			ERROR_QUIET OUTPUT_QUIET)
	file(DOWNLOAD ${download_url_dbg} ${CMAKE_BINARY_DIR}/share/debug/${FILE_BINARY_DEBUG} STATUS res-dbg SHOW_PROGRESS TLS_VERIFY OFF)
	list(GET res-dbg 0 numeric_error_dbg)
	list(GET res-dbg 1 status_dbg)
	if(NOT numeric_error_dbg EQUAL 0)#there is an error
		set(${DEPLOYED} FALSE PARENT_SCOPE)
		message("[ERROR] : problem when downloading binary version ${VERSION} of package ${package} from address ${download_url_dbg} : ${status_dbg}")
		return()
	endif()
endif()

######## installing the external package ##########
# 1) creating the external package root folder and the version folder
if(NOT EXISTS ${WORKSPACE_DIR}/external/${package} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/external/${package})
	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${package}
			WORKING_DIRECTORY ${WORKSPACE_DIR}/external/
			ERROR_QUIET OUTPUT_QUIET)
endif()
if(NOT EXISTS ${WORKSPACE_DIR}/external/${package}/${VERSION} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/external/${package}/${VERSION})
	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${VERSION}
		WORKING_DIRECTORY ${WORKSPACE_DIR}/external/${package}
		ERROR_QUIET OUTPUT_QUIET)
endif()



# 2) extracting binary archive in cross platform way
set(error_res "")
message("decompressing the binary package, please wait ...")
if(EXISTS download_url_dbg)
	execute_process(
          	COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/debug/${FILE_BINARY_DEBUG}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share/debug
		ERROR_VARIABLE error_res OUTPUT_QUIET)
else()
	execute_process(
		COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/release/${FILE_BINARY}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share/release
		ERROR_VARIABLE error_res OUTPUT_QUIET)
endif()

if (error_res)
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	message("[ERROR] :  cannot extract binary archives ${FILE_BINARY} ${FILE_BINARY_DEBUG}")
	return()
endif()

# 3) copying resulting folders into the install path in a cross platform way
message("installing the binary package into the workspace, please wait ...")
set(error_res "")
if(EXISTS download_url_dbg)
	execute_process(
		COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/release/${FOLDER_BINARY} ${WORKSPACE_DIR}/external/${package}/${VERSION}
          	COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/debug/${FOLDER_BINARY_DEBUG} ${WORKSPACE_DIR}/external/${package}/${VERSION}
		ERROR_VARIABLE error_res OUTPUT_QUIET)
else()
	execute_process(
		COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/release/${FOLDER_BINARY} ${WORKSPACE_DIR}/external/${package}/${VERSION}/
		ERROR_VARIABLE error_res OUTPUT_QUIET)
endif()

if (error_res)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message("[ERROR] : cannot extract folder from ${FOLDER_BINARY} ${FOLDER_BINARY_DEBUG}")
	return()
endif()
# 4) removing generated artifacts
if(EXISTS download_url_dbg)
	execute_process(
		COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/share/debug
		COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/share/release
		ERROR_QUIET OUTPUT_QUIET)
else()
	execute_process(
		COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/share/release
		ERROR_QUIET OUTPUT_QUIET)
endif()

set(${DEPLOYED} TRUE PARENT_SCOPE)
endfunction(deploy_External_Package_Version)

