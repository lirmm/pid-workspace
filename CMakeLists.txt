PROJECT(pid-workspace)
CMAKE_MINIMUM_REQUIRED(VERSION 2.8.11)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/licenses)
include(Workspace_Internal_Functions)

set(ALL_AVAILABLE_PACKAGES "")
# 1) searching for all reference files. 
file(GLOB reference_files ${CMAKE_SOURCE_DIR}/share/cmake/references/Refer*.cmake)
# 2) including all reference files and memorizing packages names
foreach(a_ref_file IN ITEMS ${reference_files})
	string(REGEX REPLACE "^${CMAKE_SOURCE_DIR}/share/cmake/references/Refer([^\\.]+)\\.cmake$" "\\1" PACKAGE_NAME ${a_ref_file})
	list(APPEND ALL_AVAILABLE_PACKAGES ${PACKAGE_NAME})
	include(${a_ref_file})
endforeach()
message("available packages = ${ALL_AVAILABLE_PACKAGES}")
# 3) resetting categories
reset_All_Categories()
# 4) extracting all available categories and classifying all packages in these categories
foreach(a_package IN ITEMS ${ALL_AVAILABLE_PACKAGES})
	classify_Package_Categories(${a_package})
endforeach()
# 5) printing categories
set(MESSAGE_TO_PRINT "")
print_categories(MESSAGE_TO_PRINT)
set(CATEGORIES_MESSAGE "'${MESSAGE_TO_PRINT}'")
message("${MESSAGE_TO_PRINT}")

#adding targets
add_custom_target(list_categories
	COMMAND ${CMAKE_COMMAND} -E  echo ${CATEGORIES_MESSAGE}

)



