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



