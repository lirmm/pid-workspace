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
function(generate_Institution_String institution RES_STRING)
extract_All_Words("${institution}" INSTITUTION_ALL_WORDS)
fill_List_Into_String("${INSTITUTION_ALL_WORDS}" INSTITUTION_STRING)
set(${RES_STRING} "${INSTITUTION_STRING}" PARENT_SCOPE)
endfunction()

###
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
function(add_To_Install_Package_Specification package version version_exact)
list(FIND ${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} ${package} INDEX)
if(INDEX EQUAL -1)#not found
	set(${PROJECT_NAME}_TOINSTALL_PACKAGES ${${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX}} ${package} CACHE INTERNAL "")
	if(version AND NOT version STREQUAL "")
		set(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX} "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
		endif()
	endif()
else()#package already required as "to install"
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
endif()
endfunction(add_To_Install_Package_Specification)

###
function(reset_To_Install_Packages)
foreach(pack IN ITEMS ${${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX}})
	foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_${pack}_VERSIONS${USE_MODE_SUFFIX}})
		set(${PROJECT_NAME}_TOINSTALL_${pack}_${version}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_TOINSTALL_${pack}_VERSIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} CACHE INTERNAL "")
endfunction(reset_To_Install_Packages)

function(need_Install_Packages NEED)
if(${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX})
	set(${NEED} TRUE PARENT_SCOPE)
else()
	set(${NEED} FALSE PARENT_SCOPE)
endif()
endfunction(need_Install_Packages)


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
if(UNIX AND NOT APPLE)
	set(curr_system linux)
elseif(APPLE)
	set(curr_system darwin)
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
	execute_process(
		COMMAND ${CMAKE_COMMAND} -D BUILD_EXAMPLES:BOOL=OFF -D USE_LOCAL_DEPLOYMENT:BOOL=OFF -D GENERATE_INSTALLER:BOOL=OFF -D BUILD_LATEX_API_DOC:BOOL=OFF -D BUILD_AND_RUN_TESTS:BOOL=OFF -D REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD:BOOL=ON ..
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build
		ERROR_QUIET OUTPUT_QUIET
		)
	execute_process(
		COMMAND ${CMAKE_BUILD_TOOL} build
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build
		ERROR_QUIET OUTPUT_QUIET	
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
execute_process(
		COMMAND git tag -l v*
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
		OUTPUT_VARIABLE res
		)

if(NOT res) #no version available => BUG
	set(${DEPLOYED} FALSE PARENT_SCOPE)
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
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()

set(ALL_IS_OK FALSE)
build_And_Install_Package(ALL_IS_OK ${package} "${curr_max_major_number}.${curr_max_minor_number}.${curr_max_patch_number}")

if(ALL_IS_OK)
	set(${DEPLOYED} TRUE PARENT_SCOPE)
else()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
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
	message("deploy_Source_Package_Version : DEPLOYED !!")
else()
	message("deploy_Source_Package_Version : NOT DEPLOYED")
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
message("DEBUG : trying to build ${package} with version ${version}")
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



