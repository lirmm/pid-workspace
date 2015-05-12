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
	message(FATAL_ERROR "Some of the required packages cannot be installed : ${not_installed}")
endif()
endfunction()

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
		message(SEND_ERROR "Install : Unknown package ${package} : cannot find any source or reference of this package in the workspace")
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
		message(SEND_ERROR "Install : impossible to find an adequate version for package ${package}")
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
		message(SEND_ERROR "Install : impossible to build the package sources ${package}. Try \"by hand\".")
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
		message("DEBUG reference file not found for package ${package}!! BIG BUG since it is supposed to exist if we are here !!!")
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
				message(SEND_ERROR "Install : impossible to build the package sources ${package}. Try \"by hand\".")
				return()
			endif()
			set(${INSTALL_OK} TRUE PARENT_SCOPE)
		else()
			set(${INSTALL_OK} FALSE PARENT_SCOPE)
			message(SEND_ERROR "Install : impossible to locate source repository of package ${package}")			
			return()
		endif()
	endif()
endif()
endfunction(install_Package)


###
function(deploy_Package_Repository IS_DEPLOYED package)
if(${package}_ADDRESS)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages git clone ${${package}_ADDRESS} OUTPUT_QUIET ERROR_QUIET)
	if(EXISTS ${WORKSPACE_DIR}/packages/${package} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
		set(${IS_DEPLOYED} TRUE PARENT_SCOPE)
	else()
		set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
		message(SEND_ERROR "Install : impossible to clone the repository of package ${package} (bad repository address or you have no clone rights for this repository)")
	endif()
else()
	set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
	message(SEND_ERROR "Install : impossible to clone the repository of package ${package} (no repository address defined)")
endif()
endfunction(deploy_Package_Repository)


###
function(get_Available_Binary_Package_Versions package list_of_versions)

#configuring target system
if(APPLE)
	set(curr_system darwin)	
elseif(UNIX)
	set(curr_system linux)
else()
	message(SEND_ERROR "install : unsupported system (Not UNIX or OSX) !")
	return()
endif()
# listing available binaries of the package and searching if there is any "good version"
set(available_binary_package_version "") 
foreach(ref_version IN ITEMS ${${package}_REFERENCES})
	foreach(ref_system IN ITEMS ${${package}_REFERENCE_${ref_version}})
		if(${ref_system} STREQUAL ${curr_system})		
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

# taking the most up to date version
set(curr_version 0.0.0)
foreach(version IN ITEMS ${available_versions})
	if(curr_version VERSION_LESS ${version})
		set(curr_version ${version})
	endif()
endforeach()

set(INSTALLED FALSE)
download_And_Install_Binary_Package(INSTALLED ${package} ${curr_version})
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
#message("DEBUG available versions : ${available_versions}")

# taking the adequate version
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)$" "\\1;\\2" REFVNUMBERS ${VERSION_MIN})
list(GET REFVNUMBERS 0 ref_major)
list(GET REFVNUMBERS 1 ref_minor)

set(INSTALLED FALSE)
if(EXACT)
	set(curr_patch_version -1)
	foreach(version IN ITEMS ${available_versions})
		string(REGEX REPLACE "^${ref_major}\\.${ref_minor}\\.([0-9]+)$" "\\1" PATCH ${version})
		if(NOT "${PATCH}" STREQUAL "${version}")#it matches
			if(${PATCH} GREATER ${curr_patch_version})
				set(curr_patch_version ${PATCH})
			endif()	
		endif()
	endforeach()
	if(${curr_patch_version} GREATER -1)
		download_And_Install_Binary_Package(INSTALLED ${package} "${ref_major}.${VERSION_MIN}.${curr_patch_version}")
	endif()
else()
	set(curr_patch_version -1)
	set(curr_min_minor_version ${ref_minor})
	foreach(version IN ITEMS ${available_versions})
		string(REGEX REPLACE "^${ref_major}\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2" VNUMBERS ${version})
		if(NOT "${VNUMBERS}" STREQUAL "${version}")#it matches
			list(GET VNUMBERS 0 compare_minor)
			list(GET VNUMBERS 1 compare_patch)
			if(${compare_minor} GREATER ${curr_min_minor_version})
				set(curr_min_minor_version ${compare_minor})
				set(curr_patch_version ${compare_patch})
			elseif(${compare_minor} EQUAL ${curr_min_minor_version}
				AND ${compare_patch} GREATER ${curr_patch_version})
				set(curr_patch_version ${compare_patch})
			endif()

		endif()
	endforeach()
	if(${curr_patch_version} GREATER -1)#at least one match
		#message("DEBUG : installing package ${package} with version ${ref_major}.${curr_min_minor_version}.${curr_patch_version}")
		download_And_Install_Binary_Package(INSTALLED ${package} "${ref_major}.${curr_min_minor_version}.${curr_patch_version}")
	endif()
endif()
if(INSTALLED)
	set(${DEPLOYED} TRUE PARENT_SCOPE)
else()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
endif()
endfunction(deploy_Binary_Package_Version)

###
function(generate_Binary_Package_Name package version mode RES_FILE RES_FOLDER)
if(APPLE)
	set(system_string Darwin)	
elseif(UNIX)
	set(system_string Linux)	
endif()
if(mode MATCHES Debug)
	set(mode_string "-dbg")
else()
	set(mode_string "")
endif()

set(${RES_FILE} "${package}-${version}${mode_string}-${system_string}.tar.gz" PARENT_SCOPE)
set(${RES_FOLDER} "${package}-${version}${mode_string}-${system_string}" PARENT_SCOPE)
endfunction(generate_Binary_Package_Name)

###
function(download_And_Install_Binary_Package INSTALLED package version_string)
if(APPLE)
	set(curr_system darwin)	
elseif(UNIX)
	set(curr_system linux)
endif()
###### downloading the binary package ######
#release code
set(FILE_BINARY "")
set(FOLDER_BINARY "")
generate_Binary_Package_Name(${package} ${version_string} "Release" FILE_BINARY FOLDER_BINARY)
set(download_url ${${package}_REFERENCE_${version_string}_${curr_system}})
file(DOWNLOAD ${download_url} ${CMAKE_BINARY_DIR}/share/${FILE_BINARY} STATUS res SHOW_PROGRESS)
list(GET res 0 numeric_error)
list(GET res 1 status)
if(NOT numeric_error EQUAL 0)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message(WARNING "install : problem when downloading binary version ${version_string} of package ${package} from address ${download_url}: ${status}")
	return()
endif()

#debug code 
set(FILE_BINARY_DEBUG "")
set(FOLDER_BINARY_DEBUG "")
generate_Binary_Package_Name(${package} ${version_string} "Debug" FILE_BINARY_DEBUG FOLDER_BINARY_DEBUG)
set(download_url_dbg ${${package}_REFERENCE_${version_string}_${curr_system}_url_DEBUG})
file(DOWNLOAD ${download_url_dbg} ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG} STATUS res-dbg SHOW_PROGRESS)
list(GET res-dbg 0 numeric_error_dbg)
list(GET res-dbg 1 status_dbg)
if(NOT numeric_error_dbg EQUAL 0)#there is an error
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message(WARNING "install : problem when downloading binary version ${version_string} of package ${package} from address ${download_url_dbg} : ${status_dbg}")
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
		COMMAND ${CMAKE_COMMAND} -D BUILD_EXAMPLES:BOOL=OFF -D GENERATE_INSTALLER:BOOL=OFF -D BUILD_API_DOC:BOOL=OFF -D BUILD_LATEX_API_DOC:BOOL=OFF -D BUILD_AND_RUN_TESTS:BOOL=OFF -D REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD:BOOL=ON ..
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
execute_process(
		COMMAND git tag -l v*
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
		OUTPUT_VARIABLE res
		)

if(NOT res) #no version available => BUG
	message("Error : no version available for source package ${package}")	
	return()
endif()
string(REPLACE "\n" ";" GIT_VERSIONS ${res})
set(curr_max_patch_number -1)
set(curr_max_minor_number -1)
set(curr_max_major_number -1)
foreach(version IN ITEMS ${GIT_VERSIONS})
	set(VNUMBERS "")
	string(REGEX REPLACE "^v([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2;\\3" VNUMBERS ${version})
	if(NOT "${version}" STREQUAL "${VNUMBERS}")#i.e. match found (this was a well formed version number)
		list(GET VNUMBERS 0 compare_major)
		list(GET VNUMBERS 1 compare_minor)
		list(GET VNUMBERS 2 compare_patch)
		if(${compare_major} GREATER ${curr_max_major_number})
			set(curr_max_major_number ${compare_major})
			set(curr_max_minor_number ${compare_minor})	
			set(curr_max_patch_number ${compare_patch})		
		elseif(	${compare_major} EQUAL ${curr_max_major_number}
			AND ${compare_minor} GREATER ${curr_max_minor_number})
			set(curr_max_minor_number ${compare_minor})
			set(curr_max_patch_number ${compare_patch})
		elseif( ${compare_major} EQUAL ${curr_max_major_number}
			AND ${compare_minor} EQUAL ${curr_max_minor_number} 
			AND ${compare_patch} GREATER ${curr_max_patch_number})
			set(curr_max_patch_number ${compare_patch})# taking the patch version of this major.minor
			
		endif()
	endif()
endforeach()
if(curr_max_patch_number EQUAL -1 OR curr_max_minor_number EQUAL -1 OR curr_max_major_number EQUAL -1)#i.e. nothing found
	message("Error : no adequate version found for package ${package}")
	return()
endif()

set(ALL_IS_OK FALSE)
build_And_Install_Package(ALL_IS_OK ${package} "${curr_max_major_number}.${curr_max_minor_number}.${curr_max_patch_number}")

if(ALL_IS_OK)
	set(${DEPLOYED} TRUE PARENT_SCOPE)
else()
	message("Error : automatic build and install of package ${package} FAILED !!")
endif()

endfunction(deploy_Source_Package)

###
function(deploy_Source_Package_Version DEPLOYED package VERSION_MIN EXACT)

# go to package source and find all version matching the pattern of VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the greatest version number
execute_process(
		COMMAND git tag -l v*
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
		OUTPUT_VARIABLE res
		)

if(NOT res) #no version available => BUG
	message("DEBUG : NO output var !!!!")
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)$" "\\1;\\2" REFVNUMBERS ${VERSION_MIN})
list(GET REFVNUMBERS 0 ref_major)
list(GET REFVNUMBERS 1 ref_minor)
string(REPLACE "\n" ";" GIT_VERSIONS ${res})
#message("DEBUG : available versions are : ${GIT_VERSIONS}")
set(ALL_IS_OK FALSE)
if(EXACT)
	set(curr_max_patch_number -1)
	foreach(version IN ITEMS ${GIT_VERSIONS})
		set(VNUMBERS)
		string(REGEX REPLACE "^v([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2;\\3" VNUMBERS ${version})
		if(NOT "${version}" STREQUAL "${VNUMBERS}")#i.e. match found (this was a well formed version number)
			list(GET VNUMBERS 0 compare_major)
			list(GET VNUMBERS 1 compare_minor)
			list(GET VNUMBERS 2 compare_patch)
			if(	${compare_major} EQUAL ${ref_major} 
				AND ${compare_minor} EQUAL ${ref_minor} 
				AND ${compare_patch} GREATER ${curr_max_patch_number})
				set(curr_max_patch_number ${compare_patch})# taking the last patch version available for this major.minor
			endif()
		endif()
	endforeach()
	if(curr_max_patch_number EQUAL -1)#i.e. nothing found
		set(${DEPLOYED} FALSE PARENT_SCOPE)
		return()
	endif()
	build_And_Install_Package(ALL_IS_OK ${package} "${ref_major}.${ref_minor}.${curr_max_patch_number}")
	
else()
	set(curr_max_patch_number -1)
	set(curr_max_minor_number ${ref_minor})
	foreach(version IN ITEMS ${GIT_VERSIONS})
		set(VNUMBERS "")
		string(REGEX REPLACE "^v([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2;\\3" VNUMBERS ${version})
		if(NOT "${version}" STREQUAL "${VNUMBERS}")#i.e. match found (this was a well formed version number)
			list(GET VNUMBERS 0 compare_major)
			list(GET VNUMBERS 1 compare_minor)
			list(GET VNUMBERS 2 compare_patch)
			if(${compare_major} EQUAL ${ref_major})
				if(	${compare_minor} EQUAL ${curr_max_minor_number} 
					AND ${compare_patch} GREATER ${curr_max_patch_number})
					set(curr_max_patch_number ${compare_patch})# taking the newest patch version for the current major.minor
				elseif(${compare_minor} GREATER ${curr_max_minor_number} )
					set(curr_max_patch_number ${compare_patch})# taking the patch version of this major.minor
					set(curr_max_minor_number ${compare_minor})# taking the last minor version available for this major
				endif()
				
			endif()
		endif()
	endforeach()
	if(curr_max_patch_number EQUAL -1)#i.e. nothing found
		set(${DEPLOYED} FALSE PARENT_SCOPE)
		return()
	endif()
	#message("DEBUG : now building and installing code for ${package} with selected version : ${ref_major}.${curr_max_minor_number}.${curr_max_patch_number}")
	build_And_Install_Package(ALL_IS_OK ${package} "${ref_major}.${curr_max_minor_number}.${curr_max_patch_number}")
	
endif()

if(ALL_IS_OK)
	set(${DEPLOYED} TRUE PARENT_SCOPE)
else()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
endif()

endfunction(deploy_Source_Package_Version)

###
function(build_And_Install_Package DEPLOYED package version)

# 0) memorizing the current branc the user is working with
execute_process(COMMAND git branch
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
		OUTPUT_VARIABLE current_branches ERROR_QUIET)
string(REPLACE "\n" ";" GIT_BRANCHES ${current_branches})

foreach(branch IN ITEMS ${GIT_BRANCHES})
	string(REGEX REPLACE "^\\* (.*)$" "\\1" A_BRANCH ${branch})
	if(NOT "${branch}" STREQUAL "${A_BRANCH}")#i.e. match found (this is the current branch)
		set(curr_branch ${A_BRANCH})
		break()
	endif()
endforeach()

# 1) going to the adequate git tag matching the selected version
#message("DEBUG memorizing branch : ${curr_branch} and going to tagged version : ${version}")
execute_process(COMMAND git checkout tags/v${version}
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
		OUTPUT_QUIET ERROR_QUIET)
# 2) building sources
set(IS_BUILT FALSE)
#message("DEBUG : trying to build ${package} with version ${version}")
build_And_Install_Source(IS_BUILT ${package} ${version})
#message("DEBUG : going back to ${curr_branch} branch")
# 3) going back to the initial branch in use
execute_process(COMMAND git checkout ${curr_branch}
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
		OUTPUT_QUIET ERROR_QUIET)

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
		message(FATAL_ERROR "Impossible to find a valid reference to any version of external package ${package}")
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
	message(SEND_ERROR "Install : Unknown external package ${package} : cannot find any reference of this package in the workspace")
	return()
endif()
include(ReferExternal${package} OPTIONAL RESULT_VARIABLE refer_path)
if(${refer_path} STREQUAL NOTFOUND)
	message(FATAL ERROR "Reference file not found for package ${package}!! BIG BUG since it is supposed to exist !!!")
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
	message(SEND_ERROR "Install : impossible to find an adequate version for external package ${package}")
endif()

set(${INSTALL_OK} FALSE PARENT_SCOPE)	
endfunction(install_External_Package)


###
function(is_External_Package_Defined ref_package ext_package mode RES_PATH_TO_PACKAGE)
if(mode MATCHES Debug)
	set(mode_suffix "_DEBUG")
else()
	set(mode_suffix "")
endif()
set(EXT_PACKAGE-NOTFOUND PARENT_SCOPE)

if(DEFINED ${ref_package}_EXTERNAL_DEPENDENCY_${ext_package}_VERSION${mode_suffix})
	set(${RES_PATH_TO_PACKAGE} ${WORKSPACE_DIR}/external/${ext_package}/${${ref_package}_EXTERNAL_DEPENDENCY_${ext_package}_VERSION${mode_suffix}} PARENT_SCOPE)
	return()
elseif(${ref_package}_DEPENDENCIES${mode_suffix}) #the external dependency may be issued from a third party native package
	foreach(dep_pack IN ITEMS ${${ref_package}_DEPENDENCIES${mode_suffix}})
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
	string(REGEX REPLACE "^<([^>]+)>([^\\.]+\\.[a|la|so|dylib].*)" "\\1;\\2" RES ${link})
	if(NOT RES MATCHES ${link})# a replacement has taken place => this is a full path to a library
		set(fullpath)
		list(GET RES 0 ext_package_name)
		list(GET RES 1 relative_path)
		unset(EXT_PACKAGE-NOTFOUND)		
		is_External_Package_Defined(${package} ${ext_package_name} ${mode} PATHTO)
		if(DEFINED EXT_PACKAGE-NOTFOUND)
			message(FATAL_ERROR "undefined external package ${ext_package_name} used for link ${link}!! Please set the path to this external package.")		
		else()
			set(fullpath ${PATHTO}${relative_path})
			list(APPEND res_links ${fullpath})				
		endif()
	else() # this may be a link with a prefix (like -L<path>) that need replacement
		string(REGEX REPLACE "^([^<]+)<([^>]+)>(.*)" "\\1;\\2;\\3" RES_WITH_PREFIX ${link})
		if(NOT RES_WITH_PREFIX MATCHES ${link})
			list(GET RES_WITH_PREFIX 0 link_prefix)
			list(GET RES_WITH_PREFIX 1 ext_package_name)
			is_External_Package_Defined(${package} ${ext_package_name} ${mode} PATHTO)
			if(EXT_PACKAGE-NOTFOUND)
				message(FATAL_ERROR "undefined external package ${ext_package_name} used for link ${link}!!")
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
#message("resolve_External_Libs_Path=${res_links}")
set(${COMPLETE_LINKS_PATH} ${res_links} PARENT_SCOPE)
endfunction(resolve_External_Libs_Path)

###
function(resolve_External_Includes_Path COMPLETE_INCLUDES_PATH package_context ext_inc_dirs mode)
set(res_includes)
foreach(include_dir IN ITEMS ${ext_inc_dirs})
	string(REGEX REPLACE "^<([^>]+)>(.*)" "\\1;\\2" RES ${include_dir})
	if(NOT RES MATCHES ${include_dir})# a replacement has taken place => this is a full path to an incude dir of an external package
		list(GET RES 0 ext_package_name)
		is_External_Package_Defined(${package_context} ${ext_package_name} ${mode} PATHTO)
		if(EXT_PACKAGE-NOTFOUND)
			message(FATAL_ERROR "undefined external package ${ext_package_name} used for include dir ${include_dir}!! Please set the path to this external package.")
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
		if(NOT RES_WITH_PREFIX MATCHES ${include_dir})
			list(GET RES_WITH_PREFIX 1 relative_path)
			list(GET RES_WITH_PREFIX 0 ext_package_name)
			is_External_Package_Defined(${package_context} ${ext_package_name} ${mode} PATHTO)
			if(EXT_PACKAGE-NOTFOUND)
				message(FATAL_ERROR "undefined external package ${ext_package_name} used for include dir ${include_dir}!! Please set the path to this external package.")
			endif()
			set(fullpath ${PATHTO}${relative_path})
			list(APPEND res_includes ${fullpath})
		else()#this is an include dir that does not require any replacement ! (should be avoided)
			string(REGEX REPLACE "^-I(.+)" "\\1" RES_WITHOUT_PREFIX ${include_dir})			
			if(NOT RES_WITHOUT_PREFIX MATCHES ${include_dir})
				list(APPEND res_includes ${RES_WITHOUT_PREFIX})
			else()
				list(APPEND res_includes ${include_dir})
			endif()				
		endif()
	endif()
endforeach()
set(${COMPLETE_INCLUDES_PATH} ${res_includes} PARENT_SCOPE)
endfunction(resolve_External_Includes_Path)


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
	message(FATAL_ERROR "Some of the required external packages cannot be installed : ${not_installed}")
endif()
endfunction(install_Required_External_Packages)


###
function(deploy_External_Package_Version DEPLOYED package VERSION)
set(INSTALLED FALSE)
#begin
if(UNIX AND NOT APPLE)
	set(curr_system linux)
elseif(APPLE)
	set(curr_system darwin)
else()
	message(SEND_ERROR "install : unsupported system (Not UNIX or OSX) !")
	return()
endif()
###### downloading the binary package ######
message("downloading the binary package, please wait ...")
#1) release code
set(FILE_BINARY "")
set(FOLDER_BINARY "")
generate_Binary_Package_Name(${package} ${VERSION} "Release" FILE_BINARY FOLDER_BINARY)
set(download_url ${${package}_REFERENCE_${VERSION}_${curr_system}_url})
set(FOLDER_BINARY ${${package}_REFERENCE_${VERSION}_${curr_system}_folder})
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory release
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
			ERROR_QUIET OUTPUT_QUIET)
file(DOWNLOAD ${download_url} ${CMAKE_BINARY_DIR}/share/release/${FILE_BINARY} STATUS res SHOW_PROGRESS TLS_VERIFY OFF)
list(GET res 0 numeric_error)
list(GET res 1 status)
if(NOT numeric_error EQUAL 0)
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	message(WARNING "install : problem when downloading binary version ${VERSION} of package ${package} from address ${download_url}: ${status}")
	return()
endif()
#2) debug code (optionnal for external packages => just to avoid unecessary redoing code download)
if(EXISTS ${package}_REFERENCE_${VERSION}_${curr_system}_url_DEBUG)
	set(FILE_BINARY_DEBUG "")
	set(FOLDER_BINARY_DEBUG "")
	generate_Binary_Package_Name(${package} ${VERSION} "Debug" FILE_BINARY_DEBUG FOLDER_BINARY_DEBUG)
	set(download_url_dbg ${${package}_REFERENCE_${VERSION}_${curr_system}_url_DEBUG})
	set(FOLDER_BINARY_DEBUG ${${package}_REFERENCE_${VERSION}_${curr_system}_folder_DEBUG})
	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory debug
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
			ERROR_QUIET OUTPUT_QUIET)
	file(DOWNLOAD ${download_url_dbg} ${CMAKE_BINARY_DIR}/share/debug/${FILE_BINARY_DEBUG} STATUS res-dbg SHOW_PROGRESS TLS_VERIFY OFF)
	list(GET res-dbg 0 numeric_error_dbg)
	list(GET res-dbg 1 status_dbg)
	if(NOT numeric_error_dbg EQUAL 0)#there is an error
		set(${DEPLOYED} FALSE PARENT_SCOPE)
		message(WARNING "install : problem when downloading binary version ${VERSION} of package ${package} from address ${download_url_dbg} : ${status_dbg}")
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
	message(WARNING "install : cannot extract binary archives ${FILE_BINARY} ${FILE_BINARY_DEBUG}")
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
	message(WARNING "install : cannot extract folder from ${FOLDER_BINARY} ${FOLDER_BINARY_DEBUG}")
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

