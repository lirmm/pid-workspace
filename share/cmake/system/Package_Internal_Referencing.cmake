
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
	package_Reference_Exists_In_Workspace(IS_EXISTING ${package})
	if(IS_EXISTING)
		set(USE_SOURCES FALSE)
	else()
		message(SEND_ERROR "Install : Unknown package ${package} : cannot find any source or reference of this package in the workspace")
		return()
	endif()
endif()
# 1) resolve finally required package version (if any specific version required) (major.minor only, patch is let undefined)
set(POSSIBLE)
set(VERSION_MIN)
set(EXACT)
resolve_Required_Package_Version(POSSIBLE VERSION_MIN EXACT ${package})
if(NOT POSSIBLE)
	message(SEND_ERROR "Install : impossible to find an adequate version for package ${package}")
endif()

if(USE_SOURCES)
# go to package source and find all version matching the pattern of VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the gretest version number 

# taking the last patch version available for this major.minor

# now go to the git tag vmajor.minor.patch (git checkout)

# build and install the version (cd build > cmake .. -D... > make build) usig cmake -E chdir command

else()#using references
include(Refer${package}.cmake)
# listing available binaries of the package and searching if there is any "good version" regarding the pattern VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the gretest version number 

# if there is ONE, downloading and installing it

# otherwise, trying to "git clone" the package source (if it can be accessed)
# doing the same as for the USE_SOURCES step
	
endif()

endfunction(install_Package)

###
function(resolve_Required_Package_Version version_possible min_version is_exact package)




endfunction(resolve_Required_Package_Version)

