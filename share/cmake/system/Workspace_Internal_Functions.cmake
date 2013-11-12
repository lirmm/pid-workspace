###
function(classify_Package_Categories package)
foreach(a_category IN ITEMS ${${package}_CATEGORIES})
	classify_Category(${a_category} ${package} ROOT_CATEGORIES)	
endforeach()
endfunction()

###
function(reset_All_Categories)
foreach(a_category IN ITEMS ${ROOT_CATEGORIES})
	reset_Category(${a_category})
endforeach()
set(ROOT_CATEGORIES "" CACHE INTERNAL "")
endfunction()

###
function(reset_Category category)
if(${category}_CATEGORIES)
	foreach(a_category IN ITEMS ${${category}_CATEGORIES})
		reset_Category(${a_category})#recursive call
	endforeach()
endif()
if(${category}_CATEGORY_CONTENT)
	set(${category}_CATEGORY_CONTENT CACHE INTERNAL "")
endif()
set(${category}_CATEGORIES CACHE INTERNAL "")
endfunction()

###
function(classify_Category category_full_string package container_variable)
string(REGEX REPLACE "^([^/]+)/(.+)$" "\\1;\\2" CATEGORY_STRING_CONTENT ${category_full_string})
if(NOT CATEGORY_STRING_CONTENT STREQUAL ${category_full_string})# it macthes => there are subcategories
	list(GET CATEGORY_STRING_CONTENT 0 ROOT_OF_CATEGORY)
	list(GET CATEGORY_STRING_CONTENT 1 REMAINING_OF_CATEGORY)
	# adding the current category to its containing category	
	set(temp_container ${${container_variable}} ${ROOT_OF_CATEGORY})
	list(REMOVE_DUPLICATES temp_container)
	set(${container_variable} ${temp_container} CACHE INTERNAL "")
	#classifying subcategories by recursion
	classify_Category(${REMAINING_OF_CATEGORY} ${package} ${ROOT_OF_CATEGORY}_CATEGORIES)
else()#there is no sub categories
	#string(REGEX REPLACE "^(.+)$" "\\1" ROOT_OF_CATEGORY ${category_full_string})
	# adding the current category to its containing category	
	set(temp_container ${${container_variable}} ${category_full_string})
	list(REMOVE_DUPLICATES temp_container)
	set(${container_variable} ${temp_container} CACHE INTERNAL "")
	# adding the package to the current category 
	set(temp_cat_content ${${category_full_string}_CATEGORY_CONTENT} ${package})
	list(REMOVE_DUPLICATES temp_cat_content)
	set(${category_full_string}_CATEGORY_CONTENT ${temp_cat_content} CACHE INTERNAL "")
endif()
endfunction()



function(write_Categories_File)
set(file ${CMAKE_BINARY_DIR}/CategoriesInfo.cmake)
file(WRITE ${file} "")
file(APPEND ${file} "######### declaration of workspace categories ########\n")
file(APPEND ${file} "set(ROOT_CATEGORIES ${ROOT_CATEGORIES} CACHE INTERNAL \"\")\n")
foreach(root_cat IN ITEMS ${ROOT_CATEGORIES})
	write_Category_In_File(${root_cat} ${file})
endforeach()
endfunction()


function(write_Category_In_File category thefile)
file(APPEND ${thefile} "set(${category}_CATEGORY_CONTENT ${${category}_CATEGORY_CONTENT} CACHE INTERNAL \"\")\n")
if(${category}_CATEGORIES)
	file(APPEND ${thefile} "set(${category}_CATEGORIES ${${category}_CATEGORIES} CACHE INTERNAL \"\")\n")
	foreach(cat IN ITEMS ${${category}_CATEGORIES})
		write_Category_In_File(${cat} ${thefile})
	endforeach()
endif()
endfunction()


function(find_category containing_category searched_category RESULT)
string(REGEX REPLACE "^([^/]+)/(.+)$" "\\1;\\2" CATEGORY_STRING_CONTENT ${searched_category})
if(NOT CATEGORY_STRING_CONTENT STREQUAL ${searched_category})# it macthes => searching a specific subcateogry of a category
	list(GET CATEGORY_STRING_CONTENT 0 ROOT_OF_CATEGORY)
	list(GET CATEGORY_STRING_CONTENT 1 REMAINING_OF_CATEGORY)

	if(NOT containing_category)#otherwise no specific constraint apply to the search
		list(FIND containing_category ${ROOT_OF_CATEGORY} INDEX)
		if(INDEX EQUAL -1)
			set(${RESULT} FALSE PARENT_SCOPE)
			return()
		endif()
	endif()
	if(NOT ${ROOT_OF_CATEGORY}_CATEGORIES)#if the root category has no subcategories no need to continue
		set(${RESULT} FALSE PARENT_SCOPE)
		return()
	endif()
	set(SUB_RESULT FALSE)
	find_category("${ROOT_OF_CATEGORY}" ${REMAINING_OF_CATEGORY} SUB_RESULT)
	if(SUB_RESULT)
		set(${RESULT} TRUE PARENT_SCOPE)
	else()
		set(${RESULT} FALSE PARENT_SCOPE)
	endif()
	
else()#this is a simple category name, just testing of this category exists
	if(${searched_category}_CATEGORIES OR ${searched_category}_CATEGORY_CONTENT)
		set(${RESULT} TRUE PARENT_SCOPE)
	else()
		set(${RESULT} FALSE PARENT_SCOPE)
	endif()
endif()

endfunction()

function(print_Category category number_of_tabs)
set(PRINTED_VALUE "")
set(RESULT_STRING "")
set(index ${number_of_tabs})
while(index GREATER 0)
	set(RESULT_STRING "${RESULT_STRING}	")
	math(EXPR index '${index}-1')
endwhile()
if(${category}_CATEGORY_CONTENT)
	set(PRINTED_VALUE "${RESULT_STRING}${category}:")
	foreach(pack IN ITEMS ${${category}_CATEGORY_CONTENT})
		set(PRINTED_VALUE "${PRINTED_VALUE} ${pack}")
	endforeach()
	message("${PRINTED_VALUE}")
else()
	set(PRINTED_VALUE "${RESULT_STRING}${category}")
	message("${PRINTED_VALUE}")	
endif()
if(${category}_CATEGORIES)
	math(EXPR sub_cat_nb_tabs '${number_of_tabs}+1')
	foreach(sub_cat IN ITEMS ${${category}_CATEGORIES})
		print_Category(${sub_cat} ${sub_cat_nb_tabs})
	endforeach()
endif()
endfunction()


