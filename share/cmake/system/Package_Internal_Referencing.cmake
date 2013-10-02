
###
function(generate_Reference_File pathtonewfile)
set(file ${pathtonewfile})
file(WRITE ${file} "")
file(APPEND ${file} "#### referencing package ${PROJECT_NAME} mode ####\n")
file(APPEND ${file} "set(${PROJECT_NAME}_MAIN_AUTHOR ${${PROJECT_NAME}_MAIN_AUTHOR} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_MAIN_INSTITUTION ${${PROJECT_NAME}_MAIN_INSTITUTION} CACHE INTERNAL \"\")\n")
message("authors = ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS}")
file(APPEND ${file} "set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS} CACHE INTERNAL \"\")\n")
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
list(FIND ${PROJECT_NAME}_TOINSTALL_PACKAGES ${package} INDEX)
if(INDEX EQUAL -1)#not found
	set(${PROJECT_NAME}_TOINSTALL_PACKAGES ${${PROJECT_NAME}_TOINSTALL_PACKAGES} ${package} CACHE INTERNAL "")
	if(version AND NOT version STREQUAL "")
		set(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT FALSE CACHE INTERNAL "")
		endif()
	endif()
else()#package already required as "to install"
	list(FIND ${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS INDEX)
	if(INDEX EQUAL -1)#version not already required
		set(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT FALSE CACHE INTERNAL "")
		endif()
	elseif(version_exact) #if this version was previously not exact it becomes exact if exact is required
			set(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT TRUE CACHE INTERNAL "")		
	endif()
endif()
endfunction(add_To_Install_Package_Specification)


###
function(reset_To_Install_Packages)
foreach(pack IN ITEMS ${${PROJECT_NAME}_TOINSTALL_PACKAGES})
	foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_${pack}_VERSIONS})
		set(${PROJECT_NAME}_TOINSTALL_${pack}_${version}_EXACT CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_TOINSTALL_${pack}_VERSIONS CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_TOINSTALL_PACKAGES CACHE INTERNAL "")
endfunction(reset_To_Install_Packages)

function(need_Install_Packages NEED)
if(${PROJECT_NAME}_TOINSTALL_PACKAGES)
	set(${NEED} TRUE PARENT_SCOPE)
else()
	set(${NEED} FALSE PARENT_SCOPE)
endif()
endfunction(need_Install_Packages)

###
function(resolve_Required_Package_Version version_possible min_version is_exact package)

foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS})
	get_Version_String_Numbers("${version}.0" compare_major compare_minor compared_patch)
	if(NOT MAJOR_RESOLVED)#first time
		set(MAJOR_RESOLVED ${compare_major})
		set(CUR_MINOR_RESOLVED ${compare_minor})
		if(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT)
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
		if(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT)
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


### root function for launching automatic installation process
function(install_Required_Packages INSTALLED_PACKAGES)
set(successfully_installed)
set(not_installed)
foreach(package IN ITEMS ${${PROJECT_NAME}_TOINSTALL_PACKAGES})
	set(INSTALL_OK FALSE)
	install_Package(INSTALL_OK ${package})
	if(INSTALL_OK)
		list(APPEND successfully_installed ${package})
	else()
		list(APPEND not_installed ${package})
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
endfunction(package_Source_Exists_In_Workspace) 

###
function(get_Package_References LIST_OF_REFS package)
include(Refer${package} OPTIONAL RESULT_VARIABLE res)
if(	${res} STREQUAL NOTFOUND) #if there is no component defined for the package there is an error
	set(${EXIST} ${FALSE} PARENT_SCOPE)
	return()
endif()
set(${EXIST} ${FALSE} PARENT_SCOPE)
endfunction()

###
function(install_Package INSTALL_OK package)
set(${INSTALL_OK} FALSE PARENT_SCOPE)
# 0) test if either reference or source of the package exist in the workspace
set(IS_EXISTING)  
set(PATH_TO_SOURCE)
package_Source_Exists_In_Workspace(IS_EXISTING PATH_TO_SOURCE ${package})
if(IS_EXISTING)
	set(USE_SOURCES TRUE)
else()
	set(IS_EXISTING)
	package_Reference_Exists_In_Workspace(IS_EXISTING ${package})
	if(IS_EXISTING)
		set(USE_SOURCES FALSE)
	else()
		message(SEND_ERROR "Install : Unknown package ${package} : cannot find any source or reference of this package in the workspace")
		return()
	endif()
endif()
if(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS)
# 1) resolve finally required package version (if any specific version required) (major.minor only, patch is let undefined)
	set(POSSIBLE)
	set(VERSION_MIN)
	set(EXACT)
	resolve_Required_Package_Version(POSSIBLE VERSION_MIN EXACT ${package})
	if(NOT POSSIBLE)
		message(SEND_ERROR "Install : impossible to find an adequate version for package ${package}")
		return()
	endif()
	set(NO_VERSION FALSE)	
else()
	set(NO_VERSION TRUE)
endif()

if(USE_SOURCES) #package sources reside in the workspace
	if(NOT NO_VERSION)
		deploy_Source_Package_Version(${package} ${VERSION_MIN} ${EXACT})
	else()
		deploy_Source_Package(${package}) # case when the sources exist but haven't been installed yet (should never happen)
	endif()
else()#using references
include(Refer${package}.cmake)
# listing available binaries of the package and searching if there is any "good version" regarding the pattern VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the greatest version number 
set(PACKAGE_BINARY_DEPLOYED)
if(NOT NO_VERSION)
	deploy_Binary_Package_Version(PACKAGE_BINARY_DEPLOYED ${package} ${VERSION_MIN} ${EXACT})
else()
	deploy_Binary_Package(PACKAGE_BINARY_DEPLOYED ${package})
endif()
if(PACKAGE_BINARY_DEPLOYED) # if there is ONE adequate reference, downloading and installing it
	set(${INSTALL_OK} TRUE PARENT_SCOPE)
else()# otherwise, trying to "git clone" the package source (if it can be accessed)
set(DEPLOYED)
deploy_Package_Repository(DEPLOYED ${package})
if(DEPLOYED) # doing the same as for the USE_SOURCES step
	if(NOT NO_VERSION)
		deploy_Source_Package_Version(SOURCE_DEPLOYED ${package} ${VERSION_MIN} ${EXACT})
	else()
		deploy_Source_Package(SOURCE_DEPLOYED ${package})
	endif()
	if(NOT SOURCE_DEPLOYED)
		message(SEND_ERROR "Install : impossible to build the package sources ${package}. Try \"by hand\".")
	endif()
else()
	message(SEND_ERROR "Install : impossible to locate source repository of package ${package}")
endif()

endif()

endfunction(install_Package)


###
function(deploy_Package_Repository IS_DEPLOYED package)
if(${package}_ADDRESS)
	execute_process(${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages git clone ${${package}_ADDRESS} OUTPUT_QUIET ERROR_QUIET)
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


### TODO
function(deploy_Binary_Package package)


endfunction(deploy_Binary_Package)


### TODO
function(deploy_Binary_Package_Version package VERSION_MIN EXACT)


endfunction(deploy_Binary_Package_Version)


### 
function(deploy_Source_Package DEPLOYED package)
	set(ERROR_OCCURRED)
	execute_process(
		COMMAND ${CMAKE_COMMAND} .. -DBUILD_EXAMPLES:BOOL=OFF -DBUILD_WITH_PRINT_MESSAGES:BOOL=OFF -DUSE_LOCAL_DEPLOYMENT:BOOL=OFF -DGENERATE_INSTALLER:BOOL=OFF -DBUILD_LATEX_API_DOC:BOOL=OFF -DBUILD_AND_RUN_TESTS:BOOL=OFF -DBUILD_PACKAGE_REFERENCE:BOOL=OFF -DREQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD:BOOL=ON
		COMMAND ${CMAKE_BUILD_TOOL} build
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build
		ERROR_VARIABLE ERROR_OCCURRED
		OUTPUT_QUIET)

	if(ERROR_OCCURRED)
		set(${DEPLOYED} FALSE PARENT_SCOPE)
		return()
	endif()
	set(${DEPLOYED} TRUE PARENT_SCOPE)
endfunction(deploy_Source_Package)


###
function(deploy_Source_Package_Version DEPLOYED package VERSION_MIN EXACT)

# go to package source and find all version matching the pattern of VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the greatest version number 
execute_process(
		COMMAND git tag -l 'v*'
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
		OUTPUT_VARIABLE res
		)
if(NOT res) #no version available => BUG
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()
string(REGEX REPLACE "^([0-9]+)\.([0-9]+)$)" "\\1;\\2" REFVNUMBERS ${VERSION_MIN})
list(GET REFVNUMBERS 0 ref_major)
list(GET REFVNUMBERS 1 ref_minor)

set(ALL_IS_OK)
if(EXACT)
	set(curr_max_patch_number -1)
	foreach(version IN ITEMS ${res})
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
	if(NOT curr_max_patch_number EQUAL -1)#i.e. nothing found
		set(${DEPLOYED} FALSE PARENT_SCOPE)
		return()
	endif()
	
	build_And_Install_Package(ALL_IS_OK ${package} "${ref_major}.${ref_minor}.${curr_max_patch_number}")
	
else()
	set(curr_max_patch_number -1)
	set(curr_max_minor_number ${ref_minor})
	foreach(version IN ITEMS ${res})
		set(VNUMBERS)
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
	if(NOT curr_max_patch_number EQUAL -1)#i.e. nothing found
		set(${DEPLOYED} FALSE PARENT_SCOPE)
		return()
	endif()
	
	build_And_Install_Package(ALL_IS_OK ${package} "${ref_major}.${curr_max_minor_number}.${curr_max_patch_number}")
endif()

if(ALL_IS_OK)
	set(${DEPLOYED} TRUE PARENT_SCOPE)
else()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
endif()

# now go to the git tag vmajor.minor.patch (git checkout)

# build and install the version (cd build > cmake .. -D... > make build) usig cmake -E chdir command
endfunction(deploy_Source_Package_Version)

function(build_And_Install_Package DEPLOYED package version)

# 0) memorizing the current branc the user is working with
execute_process(COMMAND git branch
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
		OUTPUT_VARIABLE current_branches ERROR_QUIET)

foreach(branch IN ITEMS ${current_branches})
	string(REGEX REPLACE "^\\* (.*)$" "\\1" A_BRANCH ${branch})
	if(NOT "${branch}" STREQUAL "${A_BRANCH}")#i.e. match found (this is the current branch)
		set(curr_branch ${A_BRANCH})
		break()
	endif()
endforeach()

# 1) going to the adequate git tag matching the selected version
execute_process(COMMAND git checkout master
		COMMAND git checkout tags/v${version}
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
		OUTPUT_QUIET ERROR_QUIET)
# 2) building sources
set(IS_BUILT)
deploy_Source_Package(IS_BUILT ${package})

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


