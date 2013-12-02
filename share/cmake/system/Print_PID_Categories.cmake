include(CategoriesInfo.cmake)

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)

include(Workspace_Internal_Functions)

if(REQUIRED_CATEGORY)
	set(RESULT FALSE)
	find_category("" ${REQUIRED_CATEGORY} RESULT CATEGORY_TO_CALL)	
	if(RESULT)
		print_Category(${CATEGORY_TO_CALL} 0)		
	else()
		message("ERROR : Problem : unknown category ${REQUIRED_CATEGORY}")
		return()
	endif()

else()
	message("CATEGORIES:")
	foreach(root_cat IN ITEMS ${ROOT_CATEGORIES})
		print_Category(${root_cat} 0)
	endforeach()
endif()

