include(CategoriesInfo.cmake)
include(../share/cmake/system/Workspace_Internal_Functions.cmake)

if(REQUIRED_CATEGORY)
	set(RESULT FALSE)
	find_category("" ${REQUIRED_CATEGORY} RESULT CATEGORY_TO_CALL)	
	if(RESULT)
		print_Category(${CATEGORY_TO_CALL} 0)		
	else()
		message(FATAL_ERROR "Problem : unknown category ${REQUIRED_CATEGORY}")
	endif()

else()
	message("CATEGORIES:")
	foreach(root_cat IN ITEMS ${ROOT_CATEGORIES})
		print_Category(${root_cat} 0)
	endforeach()
endif()

