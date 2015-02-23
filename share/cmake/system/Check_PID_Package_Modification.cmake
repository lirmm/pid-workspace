

#################################################################################################
########### this is the script file to check if a package need to be reconfigured ###############
########### parameters :
########### SOURCE_PACKAGE_CONTENT : the cmake file describing the whole package content
########### PACKAGE_NAME : name of the package to check
########### WORKSPACE_DIR : path to the root of the workspace
#################################################################################################

if(EXISTS ${SOURCE_PACKAGE_CONTENT}) #the package has already been configured
	include(${SOURCE_PACKAGE_CONTENT}) #import source code meta-information (which file for each component) 
else()
	return()
endif()

set(REMOVED_FILES)
set(path_to_package ${WORKSPACE_DIR}/packages/${PACKAGE_NAME})

foreach(component IN ITEMS ${${PACKAGE_NAME}_COMPONENTS})
	message("looking for component ${component}")
	if(${PACKAGE_NAME}_${component}_HEADER_DIR_NAME AND ${PACKAGE_NAME}_${component}_SOURCE_DIR) # this component is a binary library
		set(current_dir ${path_to_package}/include/${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME})
		foreach(a_header IN ITEMS ${${PACKAGE_NAME}_${component}_HEADERS})
			if(NOT EXISTS ${current_dir}/${a_header})
				list(APPEND REMOVED_FILES ${current_dir}/${a_header})
			endif()
		endforeach()
		set(current_dir ${path_to_package}/src/${${PACKAGE_NAME}_${component}_SOURCE_DIR})
		foreach(a_source IN ITEMS ${${PACKAGE_NAME}_${component}_SOURCE_CODE})
			if(NOT EXISTS ${current_dir}/${a_source})
				list(APPEND REMOVED_FILES ${current_dir}/${a_source})
			endif()
		endforeach()

	elseif(${PACKAGE_NAME}_${component}_HEADER_DIR_NAME) # this component is a pure header library
		set(current_dir ${path_to_package}/include/${${PACKAGE_NAME}_${component}_HEADER_DIR_NAME})
		foreach(a_header IN ITEMS ${${PACKAGE_NAME}_${component}_HEADERS})
			if(NOT EXISTS ${current_dir}/${a_header})
				list(APPEND REMOVED_FILES ${current_dir}/${a_header})
			endif()
		endforeach()
	elseif(${PACKAGE_NAME}_${component}_SOURCE_DIR) # this component is an application
		set(current_dir ${path_to_package}/apps/${${PACKAGE_NAME}_${component}_SOURCE_DIR})
		foreach(a_source IN ITEMS ${${PACKAGE_NAME}_${component}_SOURCE_CODE})
			if(NOT EXISTS ${current_dir}/${a_source})
				list(APPEND REMOVED_FILES ${current_dir}/${a_source})
			endif()
		endforeach()
	endif()
endforeach()

if(REMOVED_FILES)#try make rebuild_cache
	message("ERROR : There are files that have been removed from source tree : ${REMOVED_FILES}")
	message(FATAL_ERROR "You need to reconfigure your package using cmake command before building it")
endif()

