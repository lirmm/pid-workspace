###########################################################################################
################# auxiliary functions to check external package version ###################
###########################################################################################

###
function(check_External_Exact_Version VERSION_FOUND search_path version)
set(${VERSION_FOUND} PARENT_SCOPE)
list_Version_Subdirectories(VERSION_DIRS ${search_path})
if(VERSION_DIRS)
	list(FIND VERSION_DIRS ${version} INDEX)
	if(INDEX EQUAL -1)
		return()
	endif()
	set(${VERSION_FOUND} ${version} PARENT_SCOPE)		
endif()
endfunction()

###
function(check_External_Minimum_Version VERSION_FOUND package search_path version)
set(${VERSION_FOUND} PARENT_SCOPE)
list_Version_Subdirectories(VERSION_DIRS ${search_path})
if(VERSION_DIRS)
	foreach(version_dir IN ITEMS ${VERSION_DIRS})
		if(version_dir VERSION_EQUAL version OR version_dir VERSION_GREATER version)
			if(highest_version)
				if(version_dir VERSION_GREATER highest_version 
				AND version_dir VERSION_LESS "${${package}_PID_KNOWN_VERSION_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO}")
					set(highest_version ${version_dir})
				endif()
			else()
				set(highest_version ${version_dir})	
			endif()			
		endif()

	endforeach()
	if(highest_version)
		set(${VERSION_FOUND} ${highest_version} PARENT_SCOPE)
	endif()
endif()
endfunction()

###
function(check_External_Last_Version VERSION_FOUND search_path)
set(${VERSION_FOUND} PARENT_SCOPE)
list_Version_Subdirectories(VERSION_DIRS ${search_path})
if(VERSION_DIRS)

	foreach(version_dir IN ITEMS ${VERSION_DIRS})
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
	endif()
endif()
endfunction()

###########################################################################################
################# internal functions to install external package version ##################
###########################################################################################

###
function(add_To_Install_External_Package_Specification package version exact)
list(FIND ${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES ${package} INDEX)
if(INDEX EQUAL -1)#not found
	set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES} ${package} CACHE INTERNAL "")
	if(version AND NOT version STREQUAL "")
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT FALSE CACHE INTERNAL "")
		endif()
	endif()
else()#package already required as "to install"
	list(FIND ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS ${version} INDEX)
	if(INDEX EQUAL -1)#version not already required
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS "${version}" CACHE INTERNAL "")
		if(version_exact)
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT FALSE CACHE INTERNAL "")
		endif()
	elseif(version_exact) #if this version was previously not exact it becomes exact if exact is required
			set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT TRUE CACHE INTERNAL "")		
	endif()
endif()
endfunction()

###
function(reset_To_Install_External_Packages)
foreach(pack IN ITEMS ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES})
	foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_VERSIONS})
		set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_${version}_EXACT CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${pack}_VERSIONS CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES CACHE INTERNAL "")
endfunction(reset_To_Install_External_Packages)

function(need_Install_External_Packages NEED)
if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES)
	set(${NEED} TRUE PARENT_SCOPE)
else()
	set(${NEED} FALSE PARENT_SCOPE)
endif()
endfunction(need_Install_External_Packages)


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
endfunction()


###
function(deploy_External_Package_Version DEPLOYED package VERSION)
set(INSTALLED FALSE)
#begin
if(UNIX AND NOT APPLE)
	set(curr_system linux)
elseif(APPLE)
	#TODO
endif()
###### downloading the binary package ######
#release code
set(FILE_BINARY "")
set(FOLDER_BINARY "")
generate_Binary_Package_Name(${package} ${VERSION} "Release" FILE_BINARY FOLDER_BINARY)
set(download_url ${${package}_REFERENCE_${VERSION}_${curr_system}})
file(DOWNLOAD ${download_url} ${CMAKE_BINARY_DIR}/share/${FILE_BINARY} STATUS res)
list(GET res 0 numeric_error)
list(GET res 1 status)
if(NOT numeric_error EQUAL 0)
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	message(WARNING "install : problem when downloading binary version ${VERSION} of package ${package} from address ${download_url}: ${status}")
	return()
endif()
#debug code
set(FILE_BINARY_DEBUG "")
set(FOLDER_BINARY_DEBUG "")
generate_Binary_Package_Name(${package} ${VERSION} "Debug" FILE_BINARY_DEBUG FOLDER_BINARY_DEBUG)
set(download_url_dbg ${${package}_REFERENCE_${VERSION}_${curr_system}_DEBUG})
file(DOWNLOAD ${download_url_dbg} ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG} STATUS res-dbg)
list(GET res-dbg 0 numeric_error_dbg)
list(GET res-dbg 1 status_dbg)
if(NOT numeric_error_dbg EQUAL 0)#there is an error
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	message(WARNING "install : problem when downloading binary version ${VERSION} of package ${package} from address ${download_url_dbg} : ${status_dbg}")
	return()
endif()

# installing
if(NOT EXISTS ${WORKSPACE_DIR}/external/${package} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/external/${package})
	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${package}
			WORKING_DIRECTORY ${WORKSPACE_DIR}/external/
			ERROR_QUIET OUTPUT_QUIET)
endif()
# extracting binary archive in cross platform way
set(error_res "")
execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY}
          	COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
		ERROR_VARIABLE error_res OUTPUT_QUIET)

if (error_res)
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	message(WARNING "install : cannot extract binary archives ${FILE_BINARY} ${FILE_BINARY_DEBUG}")
	return()
endif()

# copying resulting folders into the install path in a cross platform way
set(error_res "")
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/${FOLDER_BINARY} ${WORKSPACE_DIR}/external/${package}
          	COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/${FOLDER_BINARY_DEBUG} ${WORKSPACE_DIR}/external/${package}
		ERROR_VARIABLE error_res OUTPUT_QUIET)
if (error_res)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message(WARNING "install : cannot extract version folder from ${FOLDER_BINARY} and ${FOLDER_BINARY_DEBUG}")
	return()
endif()

set(${DEPLOYED} TRUE PARENT_SCOPE)
endfunction(deploy_External_Package_Version)


###
function(resolve_Required_External_Package_Version selected_version package)
if(NOT ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS)#no specific version required
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
	list(REMOVE_DUPLICATES ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS)
	#1) testing if a solution exists as regard of "exactness" of versions	
	set(CURRENT_EXACT FALSE)
	set(CURRENT_VERSION)
	foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS})
		if(CURRENT_EXACT)
			if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT) #impossible to find two different exact versions solution
				set(${selected_version} PARENT_SCOPE)
				return()
			elseif(${version} VERSION_GREATER ${CURRENT_VERSION})#any not exact version that is greater than current exact one makes the solution impossible 
				set(${selected_version} PARENT_SCOPE)
				return()
			endif()

		else()
			if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT)
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
	foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS})
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
function(resolve_External_Package_Dependency package external_dependency)

if(${external_dependency}_FOUND) #the dependency has already been found (previously found in iteration or recursion, not possible to import it again)
	if(${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION) # a specific version is required
	 	if( ${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION_EXACT) #an exact version is required
			
			is_Exact_External_Version_Compatible_With_Previous_Constraints(IS_COMPATIBLE NEED_REFIND ${external_dependency} ${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION}) # will be incompatible if a different exact version already required OR if another major version required OR if another minor version greater than the one of exact version
 
			if(IS_COMPATIBLE)
				if(NEED_REFIND)
					# OK installing the exact version instead
					#WARNING call to find package
					find_package(
						${external_dependency} 
						${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION} 
						EXACT
						MODULE
						REQUIRED
						${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_COMPONENTS}
					)
				endif()
				return()				
			else() #not compatible
				message(FATAL_ERROR "impossible to find compatible versions of dependent external package ${external_dependency} regarding versions constraints. Search ended when trying to satisfy version coming from package ${package}. All required versions are : ${${external_dependency}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${external_dependency}_REQUIRED_VERSION_EXACT}, Last exact version required is ${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION}.")
				return()
			endif()
		else()#not an exact version required
			is_External_Version_Compatible_With_Previous_Constraints (
					COMPATIBLE_VERSION VERSION_TO_FIND 
					${external_dependency} ${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION})
			if(COMPATIBLE_VERSION)
				if(VERSION_TO_FIND)
					find_package(
						${external_dependency} 
						${VERSION_TO_FIND}
						MODULE
						REQUIRED
						${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_COMPONENTS}
					)
				else()
					return() # nothing to do more, the current used version is compatible with everything 	
				endif()
			else()
				message(FATAL_ERROR "impossible to find compatible versions of dependent package ${external_dependency} regarding versions constraints. Search ended when trying to satisfy version coming from package ${package}. All required versions are : ${${external_dependency}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${external_dependency}_REQUIRED_VERSION_EXACT}, Last version required is ${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION}.")
				return()
			endif()
		endif()
	else()
		return()#by default the version is compatible (no constraints) so return 
	endif()
else()#the dependency has not been already found
	message("DEBUG resolve_External_Package_Dependency ${external_dependency} NOT FOUND !!")	
	if(	${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION)
		
		if(${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION_EXACT) #an exact version has been specified
			#WARNING recursive call to find package
			find_package(
				${external_dependency} 
				${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION} 
				EXACT
				MODULE
				REQUIRED
				${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_COMPONENTS}
			)

		else()
			#WARNING recursive call to find package
			message("DEBUG before find : dep= ${external_dependency}, version = ${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION}")
			find_package(
				${external_dependency} 
				${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_VERSION} 
				MODULE
				REQUIRED
				${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_COMPONENTS}
			)
		endif()
	else()
		find_package(
			${external_dependency} 
			MODULE
			REQUIRED
			${${package}_EXTERNAL_DEPENDENCY_${external_dependency}_COMPONENTS}
		)
	endif()
endif()

endfunction()

###
function(is_Compatible_External_Version is_compatible package reference_version version_to_compare)

if(${reference_version} VERSION_LESS ${${package}_PID_KNOWN_VERSION_${version_to_compare}_GREATER_VERSIONS_COMPATIBLE_UP_TO})  
	set(${is_compatible} TRUE PARENT_SCOPE)
else()
	set(${is_compatible} FALSE PARENT_SCOPE)
endif()

endfunction()

###
function(is_Exact_External_Version_Compatible_With_Previous_Constraints 
		is_compatible
		need_finding
		package
		version_string)

set(${is_compatible} FALSE PARENT_SCOPE)
set(${need_finding} FALSE PARENT_SCOPE)
if(${package}_REQUIRED_VERSION_EXACT)
	if(NOT ${${package}_REQUIRED_VERSION_EXACT} VERSION_EQUAL ${version_string})#not compatible if versions are not the same				
		return() 
	endif()
	set(${is_compatible} TRUE PARENT_SCOPE)
	return()
endif()

#no exact version required
foreach(version_required IN ITEMS ${${package}_ALL_REQUIRED_VERSIONS})
	unset(COMPATIBLE_VERSION)
	is_Compatible_External_Version(COMPATIBLE_VERSION ${package} ${version_string} ${version})
	if(NOT COMPATIBLE_VERSION)
		return()#not compatible
	endif()
endforeach()

set(${is_compatible} TRUE PARENT_SCOPE)	
if(NOT ${${package}_VERSION_STRING} VERSION_EQUAL ${version_string})
	set(${need_finding} TRUE PARENT_SCOPE) #need to find the new exact version
endif()
endfunction()


###
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

foreach(version_required IN ITEMS ${${package}_ALL_REQUIRED_VERSIONS})
	unset(COMPATIBLE_VERSION)	
	is_Compatible_External_Version(COMPATIBLE_VERSION ${package} ${version})
	if(NOT COMPATIBLE_VERSION)	
		return()
	endif()
endforeach()
set(${is_compatible} TRUE PARENT_SCOPE)	


endfunction()


