#########################################################################################
#       This file is part of the program PID                                            #
#       Program description : build system supportting the PID methodology              #
#       Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique     #
#       et de Microelectronique de Montpellier). All Right reserved.                    #
#                                                                                       #
#       This software is free software: you can redistribute it and/or modify           #
#       it under the terms of the CeCILL-C license as published by                      #
#       the CEA CNRS INRIA, either version 1                                            #
#       of the License, or (at your option) any later version.                          #
#       This software is distributed in the hope that it will be useful,                #
#       but WITHOUT ANY WARRANTY; without even the implied warranty of                  #
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                    #
#       CeCILL-C License for more details.                                              #
#                                                                                       #
#       You can find the complete license description on the official website           #
#       of the CeCILL licenses family (http://www.cecill.info/index.en.html)            #
#########################################################################################

########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Version_Management_Functions NO_POLICY_SCOPE)
include(PID_Progress_Management_Functions NO_POLICY_SCOPE)
include(PID_Finding_Functions NO_POLICY_SCOPE)
include(PID_Package_Build_Targets_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Configuration_Functions NO_POLICY_SCOPE)
include(PID_Deployment_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
include(PID_Meta_Information_Management_Functions NO_POLICY_SCOPE)
include(External_Definition NO_POLICY_SCOPE) #to interpret content description of external packages

########################################################################
########## Categories (classification of packages) management ##########
########################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |classify_Packages| replace:: ``classify_Packages``
#  .. _classify_Packages:
#
#  classify_Packages
#  -----------------
#
#   .. command:: classify_Packages()
#
#   Classify all known packages into categories. Used to prepare call to the "info" command in workspace.
#
function(classify_Packages)
#1) get the root of categories (cmake variables) where to start recursion of the classification process
extract_Root_Categories()
#2) classification of packages according to categories
foreach(a_cat IN LISTS ROOT_CATEGORIES)
	classify_Root_Category(${a_cat} "${ALL_PACKAGES}")
endforeach()

#3) classification of packages according to categories defined in frameworks
foreach(a_framework IN LISTS FRAMEWORKS_CATEGORIES)
	foreach(a_cat IN LISTS FRAMEWORK_${a_framework}_ROOT_CATEGORIES)
		classify_Framework_Root_Category(${a_framework} ${a_cat} "${ALL_PACKAGES}")
	endforeach()
endforeach()
endfunction(classify_Packages)

#.rst:
#
# .. ifmode:: internal
#
#  .. |classify_Root_Category| replace:: ``classify_Root_Category``
#  .. _classify_Root_Category:
#
#  classify_Root_Category
#  ----------------------
#
#   .. command:: classify_Root_Category(root_category all_packages)
#
#   Classify all packages from a given root category. Subsidiary function to classify all packages according to categories,without taking into account frameworks information.
#
#      :root_category: the name of the root category.
#
#      :all_packages: the list of all packages known in workspace.
#
function(classify_Root_Category root_category all_packages)
foreach(package IN LISTS all_packages)
	foreach(a_category IN LISTS ${package}_CATEGORIES)
		classify_Category(${a_category} ${root_category} ${package})
	endforeach()
endforeach()
endfunction(classify_Root_Category)

#.rst:
#
# .. ifmode:: internal
#
#  .. |classify_Framework_Root_Category| replace:: ``classify_Framework_Root_Category``
#  .. _classify_Framework_Root_Category:
#
#  classify_Framework_Root_Category
#  --------------------------------
#
#   .. command:: classify_Framework_Root_Category(framework root_category all_packages)
#
#   Classify all packages from a given root category defined in a framework. Subsidiary function to classify all packages according to categories defined by frameworks.
#
#      :framework: the name of the framework.
#
#      :root_category: the name of the root category defined in framework.
#
#      :all_packages: the list of all packages known in workspace.
#
function(classify_Framework_Root_Category framework root_category all_packages)
foreach(package IN LISTS all_packages)
	if(${package}_FRAMEWORK STREQUAL "${framework}")#check if the package belongs to the framework
		foreach(a_category IN LISTS ${package}_CATEGORIES)
			list(FIND ${framework}_FRAMEWORK_CATEGORIES ${a_category} INDEX)
			if(NOT INDEX EQUAL -1)# this category is a category member of the framework
				classify_Framework_Category(${framework} ${a_category} ${root_category} ${package})
			endif()
		endforeach()
	endif()
endforeach()
endfunction(classify_Framework_Root_Category)

#.rst:
#
# .. ifmode:: internal
#
#  .. |classify_Framework_Category| replace:: ``classify_Framework_Category``
#  .. _classify_Framework_Category:
#
#  classify_Framework_Category
#  ---------------------------
#
#   .. command:: classify_Framework_Category(framework category_full_string root_category target_package)
#
#   Classify a given package into a given category defined in a framework. Subsidiary function used to create variables that describe the organization of a given framework in terms of categories.
#
#      :framework: the name of the framework.
#
#      :category_full_string: the complete category string (e.g. math/geometry).
#
#      :root_category: the name of the root category defined in framework.
#
#      :target_package: the name of package to classify.
#
function(classify_Framework_Category framework category_full_string root_category target_package)
if("${category_full_string}" STREQUAL "${root_category}")#OK, so the package directly belongs to this category
	set(FRAMEWORK_${framework}_CAT_${category_full_string}_CATEGORY_CONTENT ${FRAMEWORK_${framework}_CAT_${category_full_string}_CATEGORY_CONTENT} ${target_package} CACHE INTERNAL "") #end of recursion
	list(REMOVE_DUPLICATES FRAMEWORK_${framework}_CAT_${category_full_string}_CATEGORY_CONTENT)
	set(FRAMEWORK_${framework}_CAT_${category_full_string}_CATEGORY_CONTENT ${FRAMEWORK_${framework}_CAT_${category_full_string}_CATEGORY_CONTENT} CACHE INTERNAL "")# needed to put the removed duplicates list in cache
else()#not OK we need to know if this is a subcategory or not
	string(REGEX REPLACE "^${root_category}/(.+)$" "\\1" CATEGORY_STRING_CONTENT ${category_full_string})
	if(NOT CATEGORY_STRING_CONTENT STREQUAL ${category_full_string})# it macthes => there are subcategories with root category as root
		set(AFTER_ROOT)
		string(REGEX REPLACE "^([^/]+)/.+$" "\\1" SUBCATEGORY_STRING_CONTENT ${CATEGORY_STRING_CONTENT})
		if(NOT SUBCATEGORY_STRING_CONTENT STREQUAL "${CATEGORY_STRING_CONTENT}")# there are some subcategories
			set(AFTER_ROOT ${SUBCATEGORY_STRING_CONTENT} )
		else()
			set(AFTER_ROOT ${CATEGORY_STRING_CONTENT})
		endif()
		set(FRAMEWORK_${framework}_CAT_${root_category}_CATEGORIES ${FRAMEWORK_${framework}_CAT_${root_category}_CATEGORIES} ${AFTER_ROOT} CACHE INTERNAL "")
		classify_Framework_Category(${framework} ${category_full_string} "${root_category}/${AFTER_ROOT}" ${target_package})
		list(REMOVE_DUPLICATES FRAMEWORK_${framework}_CAT_${root_category}_CATEGORIES)
		set(FRAMEWORK_${framework}_CAT_${root_category}_CATEGORIES ${FRAMEWORK_${framework}_CAT_${root_category}_CATEGORIES} CACHE INTERNAL "")

	#else, this is not the same as root_category (otherwise first test would have succeeded => end of recursion
	endif()
endif()
endfunction(classify_Framework_Category)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Workspace_Content_Information| replace:: ``reset_Workspace_Content_Information``
#  .. _reset_Workspace_Content_Information:
#
#  reset_Workspace_Content_Information
#  -----------------------------------
#
#   .. command:: reset_Workspace_Content_Information()
#
#   Reset variables defining workspace content information, according to reference files found in workspace (macro is used instead of a function to work in the current scope, important for reference files inclusion).
#
macro(reset_Workspace_Content_Information)
# 1) fill the two root variables, by searching in all reference files lying in the workspace
set(ALL_AVAILABLE_PACKAGES)
set(ALL_AVAILABLE_FRAMEWORKS)
file(GLOB reference_files ${CMAKE_SOURCE_DIR}/share/cmake/references/Refer*.cmake)
foreach(a_ref_file IN LISTS reference_files)# 2) including all reference files and memorizing packages and frameworks names
	string(REGEX REPLACE "^${CMAKE_SOURCE_DIR}/share/cmake/references/Refer([^\\.]+)\\.cmake$" "\\1" PACKAGE_NAME ${a_ref_file})
	if(PACKAGE_NAME MATCHES External)#it is an external package
		string(REGEX REPLACE "^External([^\\.]+)$" "\\1" PACKAGE_NAME ${PACKAGE_NAME})
		list(APPEND ALL_AVAILABLE_PACKAGES ${PACKAGE_NAME})
	elseif(PACKAGE_NAME MATCHES Framework)#it is a framework
		string(REGEX REPLACE "^Framework([^\\.]+)$" "\\1" FRAMEWORK_NAME ${PACKAGE_NAME})
		list(APPEND ALL_AVAILABLE_FRAMEWORKS ${FRAMEWORK_NAME})
	else() #it is a native package
		list(APPEND ALL_AVAILABLE_PACKAGES ${PACKAGE_NAME})
	endif()
	include(${a_ref_file}) # no need to test we know by construction that the file exists
endforeach()
set(ALL_PACKAGES ${ALL_AVAILABLE_PACKAGES} CACHE INTERNAL "")
set(ALL_FRAMEWORKS ${ALL_AVAILABLE_FRAMEWORKS} CACHE INTERNAL "")
endmacro(reset_Workspace_Content_Information)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_All_Categories| replace:: ``reset_All_Categories``
#  .. _reset_All_Categories:
#
#  reset_All_Categories
#  --------------------
#
#   .. command:: reset_All_Categories()
#
#   Reset all variables describing categories, used to start from a clean situation when configuring workspace.
#
function(reset_All_Categories)
foreach(a_category IN LISTS ROOT_CATEGORIES)
	reset_Category(${a_category})
endforeach()
set(ROOT_CATEGORIES CACHE INTERNAL "")
foreach(a_framework IN LISTS FRAMEWORKS_CATEGORIES)
	foreach(a_category IN LISTS FRAMEWORK_${a_framework}_ROOT_CATEGORIES)
		reset_Framework_Category(${a_framework} ${a_category})
	endforeach()
endforeach()
endfunction(reset_All_Categories)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Category| replace:: ``reset_Category``
#  .. _reset_Category:
#
#  reset_Category
#  --------------
#
#   .. command:: reset_Category(category)
#
#   Reset all variables describing a given category.
#
#      :category: the string describing the category.
#
function(reset_Category category)
	foreach(a_sub_category IN LISTS CAT_${category}_CATEGORIES)
		reset_Category("${category}/${a_sub_category}")#recursive call
	endforeach()

if(CAT_${category}_CATEGORY_CONTENT)
	set(CAT_${category}_CATEGORY_CONTENT CACHE INTERNAL "")
endif()
set(CAT_${category}_CATEGORIES CACHE INTERNAL "")
endfunction()

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Framework_Category| replace:: ``reset_Framework_Category``
#  .. _reset_Framework_Category:
#
#  reset_Framework_Category
#  ------------------------
#
#   .. command:: reset_Framework_Category(framework category)
#
#   Reset all variables describing a given category defined in a given framework.
#
#      :framework: the name of the framework.
#
#      :category: the string describing the category.
#
function(reset_Framework_Category framework category)
if(FRAMEWORK_${framework}_CAT_${category}_CATEGORIES)
	foreach(a_sub_category IN LISTS FRAMEWORK_${framework}_CAT_${category}_CATEGORIES)
		reset_Framework_Category(${framework} "${category}/${a_sub_category}")#recursive call
	endforeach()
endif()
if(FRAMEWORK_${framework}_CAT_${category}_CATEGORY_CONTENT)
	set(FRAMEWORK_${framework}_CAT_${category}_CATEGORY_CONTENT CACHE INTERNAL "")
endif()
set(FRAMEWORK_${framework}_CAT_${category}_CATEGORIES CACHE INTERNAL "")
endfunction()

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Root_Categories| replace:: ``get_Root_Categories``
#  .. _get_Root_Categories:
#
#  get_Root_Categories
#  -------------------
#
#   .. command:: get_Root_Categories(package RETURNED_ROOTS)
#
#   Get the names of all the root categories to which belong a given package.
#
#      :package: the name of the package.
#
#      :RETURNED_ROOTS: the output variable containing the roots categories.
#
function(get_Root_Categories package RETURNED_ROOTS)
	set(ROOTS_FOUND)
	foreach(a_category IN LISTS ${package}_CATEGORIES)
		string(REGEX REPLACE "^([^/]+)/(.+)$" "\\1;\\2" CATEGORY_STRING_CONTENT ${a_category})
		if(NOT CATEGORY_STRING_CONTENT STREQUAL ${a_category})# it macthes => there are subcategories
			list(GET CATEGORY_STRING_CONTENT 0 ROOT_OF_CATEGORY)
			list(APPEND ROOTS_FOUND ${ROOT_OF_CATEGORY})
		else()
			list(APPEND ROOTS_FOUND ${a_category})
		endif()
	endforeach()
	if(ROOTS_FOUND)
		list(REMOVE_DUPLICATES ROOTS_FOUND)
	endif()
	set(${RETURNED_ROOTS} ${ROOTS_FOUND} PARENT_SCOPE)
endfunction(get_Root_Categories)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Framework_Root_Categories| replace:: ``get_Framework_Root_Categories``
#  .. _get_Framework_Root_Categories:
#
#  get_Framework_Root_Categories
#  -----------------------------
#
#   .. command:: get_Framework_Root_Categories(framework RETURNED_ROOTS)
#
#   Get the names of all the root categories defined by a framework.
#
#      :framework: the name of the framework.
#
#      :RETURNED_ROOTS: the output variable containing the roots categories.
#
function(get_Framework_Root_Categories framework RETURNED_ROOTS)
	set(ROOTS_FOUND)
	foreach(a_category IN LISTS ${framework}_FRAMEWORK_CATEGORIES)
		string(REGEX REPLACE "^([^/]+)/(.+)$" "\\1;\\2" CATEGORY_STRING_CONTENT ${a_category})
		if(NOT CATEGORY_STRING_CONTENT STREQUAL ${a_category})# it macthes => there are subcategories
			list(GET CATEGORY_STRING_CONTENT 0 ROOT_OF_CATEGORY)
			list(APPEND ROOTS_FOUND ${ROOT_OF_CATEGORY})
		else()
			list(APPEND ROOTS_FOUND ${a_category})
		endif()
	endforeach()
	if(ROOTS_FOUND)
		list(REMOVE_DUPLICATES ROOTS_FOUND)
	endif()
	set(${RETURNED_ROOTS} ${ROOTS_FOUND} PARENT_SCOPE)
endfunction(get_Framework_Root_Categories)

#.rst:
#
# .. ifmode:: internal
#
#  .. |extract_Root_Categories| replace:: ``extract_Root_Categories``
#  .. _extract_Root_Categories:
#
#  extract_Root_Categories
#  -----------------------
#
#   .. command:: extract_Root_Categories()
#
#   Extract all root categories from workspace content and pu them in cache variables.
#
function(extract_Root_Categories)
# extracting category information from packages
set(ALL_ROOTS)
foreach(a_package IN LISTS ALL_PACKAGES)
	get_Root_Categories(${a_package} ${a_package}_ROOTS)
	if(${a_package}_ROOTS)
		list(APPEND ALL_ROOTS ${${a_package}_ROOTS})
	endif()
endforeach()
if(ALL_ROOTS)
	list(REMOVE_DUPLICATES ALL_ROOTS)
	set(ROOT_CATEGORIES ${ALL_ROOTS} CACHE INTERNAL "")
else()
	set(ROOT_CATEGORIES CACHE INTERNAL "")
endif()

# classifying by frameworks
set(ALL_ROOTS)
foreach(a_framework IN LISTS ALL_FRAMEWORKS)
	set(FRAMEWORK_${a_framework}_ROOT_CATEGORIES CACHE INTERNAL "")
	get_Framework_Root_Categories(${a_framework} ROOTS)
	if(ROOTS)
		set(FRAMEWORK_${a_framework}_ROOT_CATEGORIES ${ROOTS} CACHE INTERNAL "")
		list(APPEND ALL_ROOTS ${a_framework})
	endif()
endforeach()
if(ALL_ROOTS)
	list(REMOVE_DUPLICATES ALL_ROOTS)
	set(FRAMEWORKS_CATEGORIES ${ALL_ROOTS} CACHE INTERNAL "")
else()
	set(FRAMEWORKS_CATEGORIES CACHE INTERNAL "")
endif()
endfunction(extract_Root_Categories)

#.rst:
#
# .. ifmode:: internal
#
#  .. |classify_Category| replace:: ``classify_Category``
#  .. _classify_Category:
#
#  classify_Category
#  -----------------
#
#   .. command:: classify_Category(category_full_string root_category target_package)
#
#   Classify all packages and frameworks according to categories structure. This function sets the cache variables describing the categorization of packages and frameworks.
#
#      :category_full_string: the string describing the category being currently classified.
#
#      :root_category: the name of the root category that is currently managed in classification process.
#
#      :target_package: the name of the package to classify.
#
function(classify_Category category_full_string root_category target_package)
if("${category_full_string}" STREQUAL "${root_category}")#OK, so the package directly belongs to this category
	set(CAT_${category_full_string}_CATEGORY_CONTENT ${CAT_${category_full_string}_CATEGORY_CONTENT} ${target_package} CACHE INTERNAL "") #end of recursion
	list(REMOVE_DUPLICATES CAT_${category_full_string}_CATEGORY_CONTENT)
	set(CAT_${category_full_string}_CATEGORY_CONTENT ${CAT_${category_full_string}_CATEGORY_CONTENT} CACHE INTERNAL "")# needed to put the removed duplicates list in cache
else()#not OK we need to know if this is a subcategory or not
	string(REGEX REPLACE "^${root_category}/(.+)$" "\\1" CATEGORY_STRING_CONTENT ${category_full_string})
	if(NOT CATEGORY_STRING_CONTENT STREQUAL ${category_full_string})# it macthes => there are subcategories with root category as root
		set(AFTER_ROOT)
		string(REGEX REPLACE "^([^/]+)/.+$" "\\1" SUBCATEGORY_STRING_CONTENT ${CATEGORY_STRING_CONTENT})
		if(NOT SUBCATEGORY_STRING_CONTENT STREQUAL "${CATEGORY_STRING_CONTENT}")# there are some subcategories
			set(AFTER_ROOT ${SUBCATEGORY_STRING_CONTENT} )
		else()
			set(AFTER_ROOT ${CATEGORY_STRING_CONTENT})
		endif()
		set(CAT_${root_category}_CATEGORIES ${CAT_${root_category}_CATEGORIES} ${AFTER_ROOT} CACHE INTERNAL "")
		classify_Category(${category_full_string} "${root_category}/${AFTER_ROOT}" ${target_package})
		list(REMOVE_DUPLICATES CAT_${root_category}_CATEGORIES)
		set(CAT_${root_category}_CATEGORIES ${CAT_${root_category}_CATEGORIES} CACHE INTERNAL "")


	#else, this is not the same as root_category (otherwise first test would have succeeded => end of recursion
	endif()

endif()
endfunction(classify_Category)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Categories_File| replace:: ``write_Categories_File``
#  .. _write_Categories_File:
#
#  write_Categories_File
#  ---------------------
#
#   .. command:: write_Categories_File()
#
#   Write in the workspace category description file (pid-workspace/pid/CategoriesInfo.cmake) all the cache variables generated by the classification process. This file is used by script for finding info on categories.
#
function(write_Categories_File)
set(file ${CMAKE_BINARY_DIR}/CategoriesInfo.cmake)
file(WRITE ${file} "")
file(APPEND ${file} "######### declaration of workspace categories ########\n")
file(APPEND ${file} "set(ALL_PACKAGES \"${ALL_PACKAGES}\" CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(ALL_FRAMEWORKS \"${ALL_FRAMEWORKS}\" CACHE INTERNAL \"\")\n")

file(APPEND ${file} "set(ROOT_CATEGORIES \"${ROOT_CATEGORIES}\" CACHE INTERNAL \"\")\n")
foreach(root_cat IN LISTS ROOT_CATEGORIES)
	write_Category_In_File(${root_cat} ${file})
endforeach()
file(APPEND ${file} "######### declaration of workspace categories classified by framework ########\n")
file(APPEND ${file} "set(FRAMEWORKS_CATEGORIES \"${FRAMEWORKS_CATEGORIES}\" CACHE INTERNAL \"\")\n")
foreach(framework IN LISTS FRAMEWORKS_CATEGORIES)
	write_Framework_Root_Categories_In_File(${framework} ${file})
	foreach(root_cat IN LISTS FRAMEWORK_${framework}_ROOT_CATEGORIES)
		write_Framework_Category_In_File(${framework} ${root_cat} ${file})
	endforeach()
endforeach()
endfunction(write_Categories_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Category_In_File| replace:: ``write_Category_In_File``
#  .. _write_Category_In_File:
#
#  write_Category_In_File
#  ----------------------
#
#   .. command:: write_Category_In_File(category thefile)
#
#   Write in file the cache variables used to describe a given category. See: write_Categories_File.
#
#      :category: the name of the category.
#
#      :thefile: the file to append cache variable in.
#
function(write_Category_In_File category thefile)
file(APPEND ${thefile} "set(CAT_${category}_CATEGORY_CONTENT \"${CAT_${category}_CATEGORY_CONTENT}\" CACHE INTERNAL \"\")\n")
if(CAT_${category}_CATEGORIES)
	file(APPEND ${thefile} "set(CAT_${category}_CATEGORIES \"${CAT_${category}_CATEGORIES}\" CACHE INTERNAL \"\")\n")
	foreach(cat IN LISTS CAT_${category}_CATEGORIES)
		write_Category_In_File("${category}/${cat}" ${thefile})
	endforeach()
endif()
endfunction(write_Category_In_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Framework_Root_Categories_In_File| replace:: ``write_Framework_Root_Categories_In_File``
#  .. _write_Framework_Root_Categories_In_File:
#
#  write_Framework_Root_Categories_In_File
#  ---------------------------------------
#
#   .. command:: write_Framework_Root_Categories_In_File(framework thefile)
#
#   Write in file the cache variables used to describe categories defined by a given framework. See: write_Categories_File.
#
#      :framework: the name of the framework.
#
#      :thefile: the file to append cache variable in.
#
function(write_Framework_Root_Categories_In_File framework thefile)
file(APPEND ${thefile} "set(FRAMEWORK_${framework}_ROOT_CATEGORIES \"${FRAMEWORK_${framework}_ROOT_CATEGORIES}\" CACHE INTERNAL \"\")\n")
endfunction(write_Framework_Root_Categories_In_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Framework_Category_In_File| replace:: ``write_Framework_Category_In_File``
#  .. _write_Framework_Category_In_File:
#
#  write_Framework_Category_In_File
#  --------------------------------
#
#   .. command:: write_Framework_Category_In_File(framework category thefile)
#
#   Write in file the cache variables used to describe a given category defined by a given framework. See: write_Categories_File.
#
#      :framework: the name of the framework.
#
#      :category: the string defining the category.
#
#      :thefile: the file to append cache variable in.
#
function(write_Framework_Category_In_File framework category thefile)
file(APPEND ${thefile} "set(FRAMEWORK_${framework}_CAT_${category}_CATEGORY_CONTENT \"${FRAMEWORK_${framework}_CAT_${category}_CATEGORY_CONTENT}\" CACHE INTERNAL \"\")\n")
if(FRAMEWORK_${framework}_CAT_${category}_CATEGORIES)
	file(APPEND ${thefile} "set(FRAMEWORK_${framework}_CAT_${category}_CATEGORIES \"${FRAMEWORK_${framework}_CAT_${category}_CATEGORIES}\" CACHE INTERNAL \"\")\n")
	foreach(cat IN LISTS FRAMEWORK_${framework}_CAT_${category}_CATEGORIES)
		write_Framework_Category_In_File(${framework} "${category}/${cat}" ${thefile})
	endforeach()
endif()
endfunction(write_Framework_Category_In_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_In_Categories| replace:: ``find_In_Categories``
#  .. _find_In_Categories:
#
#  find_In_Categories
#  ------------------
#
#   .. command:: find_In_Categories(searched_category_term)
#
#   Find and print to standard output the searched term in all (sub-)categories.
#
#      :searched_category_term: the term to search in categories description.
#
function(find_In_Categories searched_category_term)
foreach(root_cat IN LISTS ROOT_CATEGORIES)
	find_Category("" ${root_cat} ${searched_category_term})
endforeach()
endfunction(find_In_Categories)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Category| replace:: ``find_Category``
#  .. _find_Category:
#
#  find_Category
#  -------------
#
#   .. command:: find_Category(root_category current_category_full_path searched_category)
#
#   Print to standard output the "path" generated by a given category if found from a given root category. Subsidiary function for find_In_Categories.
#
#      :root_category: the name of root category.
#
#      :current_category_full_path: the full path of the currently managed category.
#
#      :searched_category_term: the term to search in categories description.
#
function(find_Category root_category current_category_full_path searched_category)
string(REGEX REPLACE "^([^/]+)/(.+)$" "\\1;\\2" CATEGORY_STRING_CONTENT ${searched_category})
if(NOT CATEGORY_STRING_CONTENT STREQUAL ${searched_category})# it macthes => searching category into a specific "category path"
	get_Category_Names("${root_category}" ${current_category_full_path} SHORT_NAME LONG_NAME)
	list(GET CATEGORY_STRING_CONTENT 0 ROOT_OF_CATEGORY)
	list(GET CATEGORY_STRING_CONTENT 1 REMAINING_OF_CATEGORY)
	if("${ROOT_OF_CATEGORY}" STREQUAL ${SHORT_NAME})#treating case of root categories
		find_Category("${root_category}" "${current_category_full_path}" ${REMAINING_OF_CATEGORY}) #search for a possible match
	endif()
	if(CAT_${current_category_full_path}_CATEGORIES)
		#now recursion to search inside subcategories
		foreach(root_cat IN LISTS CAT_${current_category_full_path}_CATEGORIES)
			find_Category("${current_category_full_path}" "${current_category_full_path}/${root_cat}" ${searched_category})
		endforeach()
	endif()
else()#this is a simple category name (end of recursion on path), just testing if this category exists
	get_Category_Names("${root_category}" ${current_category_full_path} SHORT_NAME LONG_NAME)

	if(SHORT_NAME STREQUAL "${searched_category}")# same name -> end of recursion a match has been found
		message("---------------")
		print_Category("" ${current_category_full_path} 0)
	else()#recursion
		if(CAT_${current_category_full_path}_CATEGORIES)
			#now recursion to search inside subcategories
			foreach(root_cat IN LISTS CAT_${current_category_full_path}_CATEGORIES)
				find_Category("${current_category_full_path}" "${current_category_full_path}/${root_cat}" ${searched_category})
			endforeach()
		endif()
	endif()
endif()
endfunction(find_Category)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Category_Names| replace:: ``get_Category_Names``
#  .. _get_Category_Names:
#
#  get_Category_Names
#  ------------------
#
#   .. command:: get_Category_Names(root_category category_full_string RESULTING_SHORT_NAME RESULTING_LONG_NAME)
#
#   Get short name and path of a given category that belongs to a root category. Subsidiary function for find_Category.
#
#      :root_category: the name of root category.
#
#      :current_category_full_path: the full path of the currently managed category.
#
#      :RESULTING_SHORT_NAME: the output variable containing the short name of the category.
#
#      :RESULTING_LONG_NAME: the output variable containing the the full path of the category.
#
function(get_Category_Names root_category category_full_string RESULTING_SHORT_NAME RESULTING_LONG_NAME)
	if("${root_category}" STREQUAL "")
		set(${RESULTING_SHORT_NAME} ${category_full_string} PARENT_SCOPE)
		set(${RESULTING_LONG_NAME} ${category_full_string} PARENT_SCOPE)
		return()
	endif()

	string(REGEX REPLACE "^${root_category}/(.+)$" "\\1" CATEGORY_STRING_CONTENT ${category_full_string})
	if(NOT CATEGORY_STRING_CONTENT STREQUAL ${category_full_string})# it macthed
		set(${RESULTING_SHORT_NAME} ${CATEGORY_STRING_CONTENT} PARENT_SCOPE) #
		set(${RESULTING_LONG_NAME} "${root_category}/${CATEGORY_STRING_CONTENT}" PARENT_SCOPE)
	else()
		message("[PID] Error : internal BUG.")
	endif()
endfunction(get_Category_Names)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Category| replace:: ``print_Category``
#  .. _print_Category:
#
#  print_Category
#  --------------
#
#   .. command:: print_Category(root_category category number_of_tabs)
#
#   Print to standard output the description generated by a given category structure. Subsidiary function for find_Category.
#
#      :root_category: the name of root category.
#
#      :current_category_full_path: the full path of the currently managed category.
#
#      :number_of_tabs: number of tabulations to use before printing category information.
#
function(print_Category root_category category number_of_tabs)
	set(PRINTED_VALUE "")
	set(RESULT_STRING "")
	set(index ${number_of_tabs})
	while(index GREATER 0)
		set(RESULT_STRING "${RESULT_STRING}	")
		math(EXPR index '${index}-1')
	endwhile()

	get_Category_Names("${root_category}" ${category} short_name long_name)

	if(CAT_${category}_CATEGORY_CONTENT)
		set(PRINTED_VALUE "${RESULT_STRING}${short_name}:")
		foreach(pack IN LISTS CAT_${category}_CATEGORY_CONTENT)
			set(PRINTED_VALUE "${PRINTED_VALUE} ${pack}")
		endforeach()
		message("${PRINTED_VALUE}")
	else()
		set(PRINTED_VALUE "${RESULT_STRING}${short_name}")
		message("${PRINTED_VALUE}")
	endif()
	if(CAT_${category}_CATEGORIES)
		math(EXPR sub_cat_nb_tabs '${number_of_tabs}+1')
		foreach(sub_cat IN LISTS CAT_${category}_CATEGORIES)
			print_Category("${long_name}" "${category}/${sub_cat}" ${sub_cat_nb_tabs})
		endforeach()
	endif()
endfunction(print_Category)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Framework_Category| replace:: ``print_Framework_Category``
#  .. _print_Framework_Category:
#
#  print_Framework_Category
#  ------------------------
#
#   .. command:: print_Framework_Category(framework root_category category number_of_tabs)
#
#   Print to standard output the description generated by a given category defined by a given framework. Subsidiary function for print_Framework_Categories.
#
#      :framework: the name of the framework.
#
#      :root_category: the name of root category.
#
#      :current_category_full_path: the full path of the currently managed category.
#
#      :number_of_tabs: number of tabulations to use before printing category information.
#
function(print_Framework_Category framework root_category category number_of_tabs)
	set(PRINTED_VALUE "")
	set(RESULT_STRING "")
	set(index ${number_of_tabs})
	while(index GREATER 0)
		set(RESULT_STRING "${RESULT_STRING}	")
		math(EXPR index '${index}-1')
	endwhile()

	get_Category_Names("${root_category}" ${category} short_name long_name)

	if(FRAMEWORK_${framework}_CAT_${category}_CATEGORY_CONTENT)
		set(PRINTED_VALUE "${RESULT_STRING}${short_name}:")
		foreach(pack IN LISTS FRAMEWORK_${framework}_CAT_${category}_CATEGORY_CONTENT)
			set(PRINTED_VALUE "${PRINTED_VALUE} ${pack}")
		endforeach()
		message("${PRINTED_VALUE}")
	else()
		set(PRINTED_VALUE "${RESULT_STRING}${short_name}")
		message("${PRINTED_VALUE}")
	endif()
	math(EXPR sub_cat_nb_tabs '${number_of_tabs}+1')
	foreach(sub_cat IN LISTS FRAMEWORK_${framework}_CAT_${category}_CATEGORIES)
		print_Framework_Category(${framework} "${long_name}" "${category}/${sub_cat}" ${sub_cat_nb_tabs})
	endforeach()
endfunction(print_Framework_Category)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Framework_Categories| replace:: ``print_Framework_Categories``
#  .. _print_Framework_Categories:
#
#  print_Framework_Categories
#  --------------------------
#
#   .. command:: print_Framework_Categories(framework)
#
#   Print to standard output the description generated by all categories defined by a given framework.
#
#      :framework: the name of the framework.
#
function(print_Framework_Categories framework)
message("---------------------------------")
list(FIND FRAMEWORKS_CATEGORIES ${framework} INDEX)
if(INDEX EQUAL -1)
	message("Framework ${framework} has no category defined")
else()
	message("Packages of the ${framework} framework, by category:")
	foreach(a_cat IN LISTS FRAMEWORK_${framework}_ROOT_CATEGORIES)
		print_Framework_Category(${framework} "" ${a_cat} 0)
	endforeach()
endif()
message("---------------------------------")
endfunction(print_Framework_Categories)

########################################################################
##################### Packages info management #########################
########################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Author| replace:: ``print_Author``
#  .. _print_Author:
#
#  print_Author
#  ------------
#
#   .. command:: print_Author(author)
#
#   Print to standard output information about an author.
#
#      :author: the name of the author.
#
function(print_Author author)
	get_Formatted_Author_String("${author}" RES_STRING)
	message("	${RES_STRING}")
endfunction(print_Author)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Package_Contact| replace:: ``print_Package_Contact``
#  .. _print_Package_Contact:
#
#  print_Package_Contact
#  ---------------------
#
#   .. command:: print_Package_Contact(package)
#
#   Print to standard output information about a contact author of a package.
#
#      :package: the name of the package.
#
function(print_Package_Contact package)
	get_Formatted_Package_Contact_String(${package} RES_STRING)
	message("CONTACT: ${RES_STRING}")
endfunction(print_Package_Contact)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Package_Info| replace:: ``print_Package_Info``
#  .. _print_Package_Info:
#
#  print_Package_Info
#  ------------------
#
#   .. command:: print_Package_Info(package)
#
#   Print to standard output information about a given native package.
#
#      :package: the name of the package.
#
function(print_Package_Info package)
	message("NATIVE PACKAGE: ${package}")
	fill_String_From_List("${${package}_DESCRIPTION}" descr_string)
	message("DESCRIPTION: ${descr_string}")
	message("LICENSE: ${${package}_LICENSE}")
	message("DATES: ${${package}_YEARS}")
	message("REPOSITORY: ${${package}_ADDRESS}")
	load_Package_Binary_References(REFERENCES_OK ${package})
	if(${package}_FRAMEWORK)
		message("DOCUMENTATION: ${${${package}_FRAMEWORK}_FRAMEWORK_SITE}/packages/${package}")
	elseif(${package}_SITE_GIT_ADDRESS)
		message("DOCUMENTATION: ${${package}_SITE_GIT_ADDRESS}")
	endif()
	print_Package_Contact(${package})
	message("AUTHORS:")
	foreach(author IN LISTS ${package}_AUTHORS_AND_INSTITUTIONS)
		print_Author(${author})
	endforeach()
	if(${package}_CATEGORIES)
		message("CATEGORIES:")
		foreach(category IN LISTS ${package}_CATEGORIES)
			message("	${category}")
		endforeach()
	endif()

	if(REFERENCES_OK)
		message("BINARY VERSIONS:")
		print_Package_Binaries(${package})
	endif()
endfunction(print_Package_Info)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_External_Package_Info| replace:: ``print_External_Package_Info``
#  .. _print_External_Package_Info:
#
#  print_External_Package_Info
#  ---------------------------
#
#   .. command:: print_External_Package_Info(package)
#
#   Print to standard output information about a given external package.
#
#      :package: the name of the external package.
#
function(print_External_Package_Info package)
	message("EXTERNAL PACKAGE: ${package}")
	fill_String_From_List("${${package}_DESCRIPTION}" descr_string)
	message("DESCRIPTION: ${descr_string}")
	message("LICENSES: ${${package}_LICENSES}")
	print_External_Package_Contact(${package})
	message("AUTHORS: ${${package}_AUTHORS}")
	if(${package}_CATEGORIES)
		message("CATEGORIES:")
		foreach(category IN LISTS ${package}_CATEGORIES)
			message("	${category}")
		endforeach()
	endif()
	load_Package_Binary_References(REFERENCES_OK ${package})
	if(REFERENCES_OK)
		message("BINARY VERSIONS:")
		print_Package_Binaries(${package})
	endif()
endfunction(print_External_Package_Info)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_External_Package_Contact| replace:: ``print_External_Package_Contact``
#  .. _print_External_Package_Contact:
#
#  print_External_Package_Contact
#  ------------------------------
#
#   .. command:: print_External_Package_Contact(package)
#
#   Print to standard output information about the contact author of a given external package.
#
#      :package: the name of the external package.
#
function(print_External_Package_Contact package)
	fill_String_From_List("${${package}_PID_WRAPPER_CONTACT_AUTHOR}" AUTHOR_STRING)
	fill_String_From_List("${${package}_PID_WRAPPER_CONTACT_INSTITUTION}" INSTITUTION_STRING)
	if(NOT INSTITUTION_STRING STREQUAL "")
		if(${package}_PID_WRAPPER_CONTACT_MAIL)
			message("PID PACKAGE CONTACT: ${AUTHOR_STRING} (${${package}_PID_WRAPPER_CONTACT_MAIL}) - ${INSTITUTION_STRING}")
		else()
			message("PID PACKAGE CONTACT: ${AUTHOR_STRING} - ${INSTITUTION_STRING}")
		endif()
	else()
		if(${package}_PID_WRAPPER_CONTACT_MAIL)
			message("PID PACKAGE CONTACT: ${AUTHOR_STRING} (${${package}_PID_WRAPPER_CONTACT_MAIL})")
		else()
			message("PID PACKAGE CONTACT: ${AUTHOR_STRING}")
		endif()
	endif()
endfunction(print_External_Package_Contact)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Package_Binaries| replace:: ``print_Package_Binaries``
#  .. _print_Package_Binaries:
#
#  print_Package_Binaries
#  ----------------------
#
#   .. command:: print_Package_Binaries(package)
#
#   Print to standard output the information about available binary archives for a given package.
#
#      :package: the name of the package.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        The reference file of the given package must be loaded before this call. No automatic automatic (re)load id performed to improve performance.
#
function(print_Package_Binaries package)
	foreach(version IN LISTS ${package}_REFERENCES)
		message("	${version}: ")
		foreach(platform IN LISTS ${package}_REFERENCE_${version})
			print_Platform_Compatible_Binary(${package} ${platform})
		endforeach()
	endforeach()
endfunction(print_Package_Binaries)

#.rst:
#
# .. ifmode:: internal
#
#  .. |exact_Version_Archive_Exists| replace:: ``exact_Version_Archive_Exists``
#  .. _exact_Version_Archive_Exists:
#
#  exact_Version_Archive_Exists
#  ----------------------------
#
#   .. command:: exact_Version_Archive_Exists(package version RESULT)
#
#   Check whether a given exact version of a package is provided as a binary archive.
#
#      :package: the name of the package.
#
#      :version: the version to check.
#
#      :RESULT: the output variable that is TRUE if a binary archive exists for the package version, FALSE otherwise.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        The reference file of the given package must be loaded before this call. No automatic automatic (re)load id performed to improve performance.
#
function(exact_Version_Archive_Exists package version RESULT)
if(${package}_REFERENCES)
	list(FIND ${package}_REFERENCES ${version} INDEX)
	if(INDEX EQUAL -1)
		set(${RESULT} FALSE PARENT_SCOPE)
		return()
	else()
		get_Available_Binary_Package_Versions(${package} list_of_versions list_of_versions_with_platform)
		list(FIND list_of_versions ${version} INDEX)
		if(INDEX EQUAL -1)
			set(${RESULT} FALSE PARENT_SCOPE)
		else()
			set(${RESULT} TRUE PARENT_SCOPE)
		endif()
	endif()
endif()
endfunction(exact_Version_Archive_Exists)

#.rst:
#
# .. ifmode:: internal
#
#  .. |greatest_Version_Archive| replace:: ``greatest_Version_Archive``
#  .. _greatest_Version_Archive:
#
#  greatest_Version_Archive
#  ------------------------
#
#   .. command:: greatest_Version_Archive(package RES_VERSION)
#
#   Check whether any version of a package is provided as a binary archive.
#
#      :package: the name of the package.
#
#      :RES_VERSION: the output variable that contains the greatest version for which a binary archive is available, FALSE otherwise.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        The reference file of the given package must be loaded before this call. No automatic automatic (re)load id performed to improve performance.
#
function(greatest_Version_Archive package RES_VERSION)
if(${package}_REFERENCES)
		get_Available_Binary_Package_Versions(${package} list_of_versions list_of_versions_with_platform)
		if(list_of_versions)
			set(curr_max_version 0.0.0)
			foreach(version IN LISTS list_of_versions)
				if(version VERSION_GREATER curr_max_version)
					set(curr_max_version ${version})
				endif()
			endforeach()
			set(${RES_VERSION} ${curr_max_version} PARENT_SCOPE)
		endif()
endif()
endfunction(greatest_Version_Archive)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Platform_Compatible_Binary| replace:: ``print_Platform_Compatible_Binary``
#  .. _print_Platform_Compatible_Binary:
#
#  print_Platform_Compatible_Binary
#  --------------------------------
#
#   .. command:: print_Platform_Compatible_Binary(package platform)
#
#   Print to standard output all available binary archives of a given package compatible with a given platform.
#
#      :package: the name of the package.
#
#      :platform: the identifier of the platform.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        The reference file of the given package must be loaded before this call. No automatic automatic (re)load id performed to improve performance.
#
function(print_Platform_Compatible_Binary package platform)
	set(printed_string "		${platform}:")
	#1) testing if binary can be installed
	check_Package_Platform_Against_Current(${package} ${platform} BINARY_OK)
	if(BINARY_OK)
		set(printed_string "${printed_string} CAN BE INSTALLED")
	else()
		set(printed_string "${printed_string} CANNOT BE INSTALLED")
	endif()
	message("${printed_string}")
endfunction(print_Platform_Compatible_Binary)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Framework_Info| replace:: ``print_Framework_Info``
#  .. _print_Framework_Info:
#
#  print_Framework_Info
#  --------------------
#
#   .. command:: print_Framework_Info(framework)
#
#   Print brief description of a framework.
#
#      :framework: the name of the framework.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        The reference file of the given framework must be loaded before this call. No automatic automatic (re)load id performed to improve performance.
#
function(print_Framework_Info framework)
	message("FRAMEWORK: ${framework}")
	fill_String_From_List("${${framework}_FRAMEWORK_DESCRIPTION}" descr_string)
	message("DESCRIPTION: ${descr_string}")
	message("WEB SITE: ${${framework}_FRAMEWORK_SITE}")
	message("LICENSE: ${${framework}_FRAMEWORK_LICENSE}")
	message("DATES: ${${framework}_FRAMEWORK_YEARS}")
	message("REPOSITORY: ${${framework}_FRAMEWORK_ADDRESS}")
	print_Package_Contact(${framework})
	message("AUTHORS:")
	foreach(author IN LISTS ${framework}_FRAMEWORK_AUTHORS_AND_INSTITUTIONS)
		print_Author(${author})
	endforeach()
	if(${framework}_FRAMEWORK_CATEGORIES)
		message("CATEGORIES:")
		foreach(category IN LISTS ${framework}_FRAMEWORK_CATEGORIES)
			message("	${category}")
		endforeach()
	endif()
endfunction(print_Framework_Info)

########################################################################
#################### Packages lifecycle management #####################
########################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_PID_Wrapper| replace:: ``create_PID_Wrapper``
#  .. _create_PID_Wrapper:
#
#  create_PID_Wrapper
#  ------------------
#
#   .. command:: create_PID_Wrapper(wrapper author institution license)
#
#   Create a wrapper project into workspace.
#
#      :wrapper: the name of the wrapper to create.
#
#      :author: the name of the wrapper's author.
#
#      :institution: the institution of the wrapper's author.
#
#      :license: the name of license applying to the wrapper.
#
function(create_PID_Wrapper wrapper author institution license)
#copying the pattern folder into the package folder and renaming it
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/share/patterns/wrappers/package ${WORKSPACE_DIR}/wrappers/${wrapper} OUTPUT_QUIET ERROR_QUIET)

#setting variables
set(WRAPPER_NAME ${wrapper})
if(author AND NOT author STREQUAL "")
	set(WRAPPER_AUTHOR_NAME "${author}")
else()
	set(WRAPPER_AUTHOR_NAME "$ENV{USER}")
endif()
if(institution AND NOT institution STREQUAL "")
	set(WRAPPER_AUTHOR_INSTITUTION "INSTITUTION	${institution}")
else()
	set(WRAPPER_AUTHOR_INSTITUTION "")
endif()
if(license AND NOT license STREQUAL "")
	set(WRAPPER_LICENSE "${license}")
else()
	message("[PID] WARNING: no license defined so using the default CeCILL license.")
	set(WRAPPER_LICENSE "CeCILL")#default license is CeCILL
endif()
set(WRAPPER_DESCRIPTION "TODO: input a short description of wrapper ${wrapper} utility here")
string(TIMESTAMP date "%Y")
set(WRAPPER_YEARS ${date})
# generating the root CMakeLists.txt of the package
configure_file(${WORKSPACE_DIR}/share/patterns/wrappers/CMakeLists.txt.in ../wrappers/${wrapper}/CMakeLists.txt @ONLY)
#confuguring git repository
init_Wrapper_Repository(${wrapper})
endfunction(create_PID_Wrapper)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_PID_Framework| replace:: ``create_PID_Framework``
#  .. _create_PID_Framework:
#
#  create_PID_Framework
#  --------------------
#
#   .. command:: create_PID_Framework(framework author institution license site)
#
#   Create a framework project into workspace.
#
#      :framework: the name of the framework to create.
#
#      :author: the name of the framework's author.
#
#      :institution: the institution of the framework's author.
#
#      :license: the name of license applying to the framework.
#
#      :site: the URL of the static site generated by the framework.
#
function(create_PID_Framework framework author institution license site)
#copying the pattern folder into the package folder and renaming it
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/share/patterns/frameworks/framework ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET)

#setting variables
set(FRAMEWORK_NAME ${framework})
if(author AND NOT author STREQUAL "")
	set(FRAMEWORK_AUTHOR_NAME "${author}")
else()
	set(FRAMEWORK_AUTHOR_NAME "$ENV{USER}")
endif()
if(institution AND NOT institution STREQUAL "")
	set(FRAMEWORK_AUTHOR_INSTITUTION "INSTITUTION	${institution}")
else()
	set(FRAMEWORK_AUTHOR_INSTITUTION "")
endif()
if(license AND NOT license STREQUAL "")
	set(FRAMEWORK_LICENSE "${license}")
else()
	message("[PID] WARNING: no license defined so using the default CeCILL license.")
	set(FRAMEWORK_LICENSE "CeCILL")#default license is CeCILL
endif()
if(site AND NOT site STREQUAL "")
	set(FRAMEWORK_SITE "${site}")
else()
	set(FRAMEWORK_SITE "\"TODO: input the web site address \"")
endif()
set(FRAMEWORK_DESCRIPTION "\"TODO: input a short description of framework ${framework} utility here\"")
string(TIMESTAMP date "%Y")
set(FRAMEWORK_YEARS ${date})
# generating the root CMakeLists.txt of the package
configure_file(${WORKSPACE_DIR}/share/patterns/frameworks/CMakeLists.txt.in ${WORKSPACE_DIR}/sites/frameworks/${framework}/CMakeLists.txt @ONLY)
#configuring git repository
init_Framework_Repository(${framework})
endfunction(create_PID_Framework)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_PID_Package| replace:: ``create_PID_Package``
#  .. _create_PID_Package:
#
#  create_PID_Package
#  ------------------
#
#   .. command:: create_PID_Package(package author institution license)
#
#   Create a native package project into workspace.
#
#      :package: the name of the package to create.
#
#      :author: the name of the package's author.
#
#      :institution: the institution of the package's author.
#
#      :license: the name of license applying to the package.
#
function(create_PID_Package package author institution license)
#copying the pattern folder into the package folder and renaming it
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/share/patterns/packages/package ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)

#setting variables
set(PACKAGE_NAME ${package})
if(author AND NOT author STREQUAL "")
	set(PACKAGE_AUTHOR_NAME "${author}")
else()
	if(WIN32)
		set(PACKAGE_AUTHOR_NAME "$ENV{USERNAME}")
	else()
		set(PACKAGE_AUTHOR_NAME "$ENV{USER}")
	endif()
endif()
if(institution AND NOT institution STREQUAL "")
	set(PACKAGE_AUTHOR_INSTITUTION "INSTITUTION	${institution}")
else()
	set(PACKAGE_AUTHOR_INSTITUTION "")
endif()
if(license AND NOT license STREQUAL "")
	set(PACKAGE_LICENSE "${license}")
else()
	message("[PID] WARNING: no license defined so using the default CeCILL license.")
	set(PACKAGE_LICENSE "CeCILL")#default license is CeCILL
endif()
set(PACKAGE_DESCRIPTION "TODO: input a short description of package ${package} utility here")
string(TIMESTAMP date "%Y")
set(PACKAGE_YEARS ${date})
# generating the root CMakeLists.txt of the package
configure_file(${WORKSPACE_DIR}/share/patterns/packages/CMakeLists.txt.in ../packages/${package}/CMakeLists.txt @ONLY)
#confuguring git repository
init_Repository(${package})
endfunction(create_PID_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_PID_Framework| replace:: ``deploy_PID_Framework``
#  .. _deploy_PID_Framework:
#
#  deploy_PID_Framework
#  --------------------
#
#   .. command:: deploy_PID_Framework(framework verbose)
#
#   Deploy a framework into workspace. Result in installing an existing framework repository in the workspace filesystem.
#
#      :framework: the name of the framework to deploy.
#
#      :verbose: if TRUE the deployment will print more information to standard output.
#
function(deploy_PID_Framework framework verbose)
set(PROJECT_NAME ${framework})
if(verbose)
	set(ADDITIONNAL_DEBUG_INFO ON)
else()
	set(ADDITIONNAL_DEBUG_INFO OFF)
endif()
	deploy_Framework_Repository(DEPLOYED ${framework})
	if(DEPLOYED)
		message("[PID] INFO : framework ${framework} has been deployed.")
	else()
		message("[PID] ERROR : cannot deploy ${framework} repository.")
	endif()
endfunction(deploy_PID_Framework)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_PID_Native_Package| replace:: ``deploy_PID_Native_Package``
#  .. _deploy_PID_Native_Package:
#
#  deploy_PID_Native_Package
#  -------------------------
#
#   .. command:: deploy_PID_Native_Package(package version verbose can_use_source)
#
#   Deploy a native package into workspace. Finally results in installing an existing package version in the workspace install tree.
#
#      :package: the name of the package to deploy.
#
#      :version: the version to deploy.
#
#      :verbose: if TRUE the deployment will print more information to standard output.
#
#      :can_use_source: if TRUE the deployment can be done from the package source repository.
#
function(deploy_PID_Native_Package package version verbose can_use_source branch run_tests)
set(PROJECT_NAME ${package})
set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD ON)
if(verbose)
	set(ADDITIONNAL_DEBUG_INFO ON)
else()
	set(ADDITIONNAL_DEBUG_INFO OFF)
endif()

set(REPOSITORY_IN_WORKSPACE FALSE)
if(EXISTS ${WORKSPACE_DIR}/packages/${package})
	set(REPOSITORY_IN_WORKSPACE TRUE)
endif()

if(version STREQUAL "")#no specific version required
	set(INSTALLED FALSE)
	if(can_use_source)#this first step is only possible if sources can be used
		if(NOT REPOSITORY_IN_WORKSPACE)
			set(DEPLOYED FALSE)
			deploy_Package_Repository(DEPLOYED ${package})
			if(NOT DEPLOYED)
				message("[PID] ERROR : cannot deploy ${package} repository. Abort deployment !")
				return()
			endif()
		endif()
		#now build the package
		if(branch)#deploying a specific branch
			deploy_Source_Native_Package_From_Branch(INSTALLED ${package} ${branch} "${run_tests}")
		else()
			deploy_Source_Native_Package(INSTALLED ${package} "" "${run_tests}")
		endif()
		if(NOT INSTALLED)
			message("[PID] ERROR : cannot build ${package} after cloning its repository. Abort deployment !")
			return()
		endif()
	endif()
	if(NOT INSTALLED)# deployment from sources was not possible
		#try to install last available version from sources
		set(RES_VERSION)
		greatest_Version_Archive(${package} RES_VERSION)
		if(RES_VERSION)
			deploy_Binary_Native_Package_Version(DEPLOYED ${package} ${RES_VERSION} TRUE "")
			if(NOT DEPLOYED)
				message("[PID] ERROR : problem deploying ${package} binary archive version ${RES_VERSION}. Deployment aborted !")
				return()
			else()
				message("[PID] INFO : deploying ${package} binary archive version ${RES_VERSION} success !")
				return()
			endif()
		else()
			message("[PID] ERROR : no binary archive available for ${package}. Deployment aborted !")
			return()
		endif()
	endif()
else()#deploying a specific version
	#first, try to download the archive if the binary archive for this version exists
	exact_Version_Archive_Exists(${package} "${version}" ARCHIVE_EXISTS)
	if(ARCHIVE_EXISTS)#download the binary directly if an archive exists for this version
		deploy_Binary_Native_Package_Version(DEPLOYED ${package} ${version} TRUE "")
		if(NOT DEPLOYED)
			message("[PID] ERROR : problem deploying ${package} binary archive version ${version}. Deployment aborted !")
			return()
		else()
			message("[PID] INFO : deploying ${package} binary archive for version ${version} succeeded !")
			return()
		endif()
	endif()
	#OK so try from sources
	if(can_use_source)#this first step is only possible if sources can be used
		if(NOT REPOSITORY_IN_WORKSPACE)
			deploy_Package_Repository(DEPLOYED ${package})
			if(NOT DEPLOYED)
				message("[PID] ERROR : cannot clone ${package} repository. Deployment aborted !")
				return()
			endif()
		endif()
		deploy_Source_Native_Package_Version(DEPLOYED ${package} ${version} TRUE "" "${run_tests}")
		if(DEPLOYED)
				message("[PID] INFO : package ${package} has been deployed from its repository.")
		else()
			message("[PID] ERROR : cannot build ${package} from its repository. Deployment aborted !")
		endif()
	else()
		message("[PID] ERROR : cannot install ${package} since no binary archive exist for that version. Deployment aborted !")
	endif()
endif()
endfunction(deploy_PID_Native_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_PID_External_Package| replace:: ``deploy_PID_External_Package``
#  .. _deploy_PID_External_Package:
#
#  deploy_PID_External_Package
#  ---------------------------
#
#   .. command:: deploy_PID_External_Package(package version verbose can_use_source redeploy)
#
#   Deploy an external package into workspace. Finally results in installing an existing external package version in the workspace install tree.
#
#      :package: the name of the external package to deploy.
#
#      :version: the version to deploy.
#
#      :verbose: if TRUE the deployment will print more information to standard output.
#
#      :can_use_source: if TRUE the deployment can be done from the external package wrapper (if any).
#
#      :redeploy: if TRUE the external package version is redeployed even if it was existing before.
#
function(deploy_PID_External_Package package version verbose can_use_source redeploy)
if(verbose)
	set(ADDITIONNAL_DEBUG_INFO ON)
else()
	set(ADDITIONNAL_DEBUG_INFO OFF)
endif()

#check if the repository of the external package wrapper lies in the workspace
set(REPOSITORY_IN_WORKSPACE FALSE)
if(EXISTS ${WORKSPACE_DIR}/wrappers/${package})
	set(REPOSITORY_IN_WORKSPACE TRUE)
endif()
get_System_Variables(PLATFORM_NAME PACKAGE_STRING)
set(MAX_CURR_VERSION 0.0.0)
if("${version}" STREQUAL "")#deploying the latest version of the package

	#first try to directly download its archive
	if(${package}_REFERENCES) #there are references to external package binaries
		foreach(version_i IN LISTS ${package}_REFERENCES)
			list(FIND ${package}_REFERENCE_${version_i} ${PLATFORM_NAME} INDEX)
			if(NOT INDEX EQUAL -1) #a reference for this OS is known
				if(${version_i} VERSION_GREATER ${MAX_CURR_VERSION})
					set(MAX_CURR_VERSION ${version_i})
				endif()
			endif()
		endforeach()
		if(NOT ${MAX_CURR_VERSION} STREQUAL 0.0.0)
			if(EXISTS ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${package}/${MAX_CURR_VERSION}
			AND NOT redeploy)
				message("[PID] INFO : external package ${package} version ${MAX_CURR_VERSION} already lies in the workspace, use force=true to force the redeployment.")
				return()
			endif()
			deploy_Binary_External_Package_Version(DEPLOYED ${package} ${MAX_CURR_VERSION} FALSE)
			if(NOT DEPLOYED)#an error occurred during deployment !! => Not a normal situation
				message("[PID] ERROR : cannot deploy ${package} binary archive version ${MAX_CURR_VERSION}. This is certainy due to a bad, missing or unaccessible archive. Please contact the administrator of the package ${package}.")
				return()
			else()
				message("[PID] INFO : external package ${package} version ${MAX_CURR_VERSION} has been deployed from its binary archive.")
				return()
			endif()
		else()#there may be no binary version available for the target OS => not an error
			if(ADDITIONNAL_DEBUG_INFO)
				message("[PID] ERROR : no known binary version of external package ${package} for OS ${OS_STRING}.")
			endif()
		endif()
	endif()

	#second option: build it from sources
	if(can_use_source)#this step is only possible if sources can be used
		if(NOT REPOSITORY_IN_WORKSPACE)
			deploy_Wrapper_Repository(DEPLOYED ${package})
			if(NOT DEPLOYED)
				message("[PID] ERROR : cannot clone external package ${package} wrapper repository. Deployment aborted !")
				return()
			endif()
		endif()
		set(list_of_installed_versions)
		if(NOT redeploy #only exlcude the installed versions if redeploy is not required
		AND EXISTS ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${package}/)
			list_Version_Subdirectories(RES_VERSIONS ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${package})
			set(list_of_installed_versions ${RES_VERSIONS})
		endif()
		deploy_Source_External_Package(DEPLOYED ${package} "${list_of_installed_versions}")
		if(DEPLOYED)
				message("[PID] INFO : external package ${package} has been deployed from its wrapper repository.")
		else()
			message("[PID] ERROR : cannot build external package ${package} from its wrapper repository. Deployment aborted !")
		endif()
	else()
		message("[PID] ERROR : cannot install external package ${package} since no binary archive exist for that version and no source deployment is required. Deployment aborted !")
	endif()

else()#deploying a specific version of the external package
	#first, try to download the archive if the binary archive for this version exists
	exact_Version_Archive_Exists(${package} "${version}" ARCHIVE_EXISTS)
	if(ARCHIVE_EXISTS)#download the binary directly if an archive exists for this version
		deploy_Binary_External_Package_Version(DEPLOYED ${package} ${version} FALSE)#deploying the target binary relocatable archive
		if(NOT DEPLOYED)
			message("[PID] ERROR : problem deploying ${package} binary archive version ${version}. Deployment aborted !")
			return()
		else()
			message("[PID] INFO : deploying ${package} binary archive for version ${version} succeeded !")
			return()
		endif()
	endif()
	#Not possible from binaries so try from sources
	if(can_use_source)#this step is only possible if sources can be used
		if(NOT REPOSITORY_IN_WORKSPACE)
			deploy_Wrapper_Repository(DEPLOYED ${package})
			if(NOT DEPLOYED)
				message("[PID] ERROR : cannot clone external package ${package} wrapper repository. Deployment aborted !")
				return()
			endif()
		endif()
		deploy_Source_External_Package_Version(DEPLOYED ${package} ${version} TRUE "")
		if(DEPLOYED)
				message("[PID] INFO : external package ${package} has been deployed from its wrapper repository.")
		else()
			message("[PID] ERROR : cannot build external package ${package} from its wrapper repository. Deployment aborted !")
		endif()
	else()
		message("[PID] ERROR : cannot install external package ${package} since no binary archive exist for that version. Deployment aborted !")
	endif()
endif()
endfunction(deploy_PID_External_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |connect_PID_Wrapper| replace:: ``connect_PID_Wrapper``
#  .. _connect_PID_Wrapper:
#
#  connect_PID_Wrapper
#  -------------------
#
#   .. command:: connect_PID_Wrapper(wrapper git_url first_time)
#
#    Configuring the official remote repository of the given external package wrapper.
#
#      :wrapper: the name of the external package.
#
#      :git_url: the url of the official remote used for that wrapper.
#
#      :first_time: if FALSE a reconnection of official repository will take place.
#
function(connect_PID_Wrapper wrapper git_url first_time)
if(first_time)#first time this wrapper is connected because newly created
	# set the address of the official repository in the CMakeLists.txt of the framework
	set_Wrapper_Repository_Address(${wrapper} ${git_url})
	register_Wrapper_Repository_Address(${wrapper})
	# synchronizing with the "official" remote git repository
	connect_Wrapper_Repository(${wrapper} ${git_url})
else() #forced reconnection
	# updating the address of the official repository in the CMakeLists.txt of the package
	reset_Wrapper_Repository_Address(${wrapper} ${git_url})
	register_Wrapper_Repository_Address(${wrapper})
	# synchronizing with the new "official" remote git repository
	reconnect_Wrapper_Repository(${wrapper} ${git_url})
endif()
endfunction(connect_PID_Wrapper)

#.rst:
#
# .. ifmode:: internal
#
#  .. |connect_PID_Framework| replace:: ``connect_PID_Framework``
#  .. _connect_PID_Framework:
#
#  connect_PID_Framework
#  ---------------------
#
#   .. command:: connect_PID_Framework(framework git_url first_time)
#
#    Configuring the official remote repository of the given framework.
#
#      :framework: the name of the framework.
#
#      :git_url: the url of the official remote used for that framework.
#
#      :first_time: if FALSE a reconnection of official repository will take place.
#
function(connect_PID_Framework framework git_url first_time)
if(first_time)#first time this framework is connected because newly created
	# set the address of the official repository in the CMakeLists.txt of the framework
	set_Framework_Repository_Address(${framework} ${git_url})
	register_Framework_Repository_Address(${framework})
	# synchronizing with the "official" remote git repository
	connect_Framework_Repository(${framework} ${git_url})
else() #forced reconnection
	# updating the address of the official repository in the CMakeLists.txt of the package
	reset_Framework_Repository_Address(${framework} ${git_url})
	register_Framework_Repository_Address(${framework})
	# synchronizing with the new "official" remote git repository
	reconnect_Framework_Repository(${framework} ${git_url})
endif()
endfunction(connect_PID_Framework)

#.rst:
#
# .. ifmode:: internal
#
#  .. |connect_PID_Package| replace:: ``connect_PID_Package``
#  .. _connect_PID_Package:
#
#  connect_PID_Package
#  -------------------
#
#   .. command:: connect_PID_Package(package git_url first_time)
#
#    Configuring the official remote repository of the given package.
#
#      :package: the name of the native package.
#
#      :git_url: the url of the official remote used for that package.
#
#      :first_time: if FALSE a reconnection of official repository will take place.
#
function(connect_PID_Package package git_url first_time)
save_Repository_Context(INITIAL_COMMIT SAVED_CONTENT ${package}) # saving local repository state
go_To_Integration(${package})
if(first_time)#first time this package is connected because newly created
	# set the address of the official repository in the CMakeLists.txt of the package
	set_Package_Repository_Address(${package} ${git_url})
	register_Repository_Address(${package})
	# synchronizing with the "official" remote git repository
	connect_Repository(${package} ${git_url})
else() #forced reconnection
	# updating the address of the official repository in the CMakeLists.txt of the package
	reset_Package_Repository_Address(${package} ${git_url})
	register_Repository_Address(${package})
	# synchronizing with the new "official" remote git repository
	reconnect_Repository(${package} ${git_url})
endif()
restore_Repository_Context(${package} ${INITIAL_COMMIT} ${SAVED_CONTENT}) # restoring local repository state
endfunction(connect_PID_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Connection_To_PID_Package| replace:: ``add_Connection_To_PID_Package``
#  .. _add_Connection_To_PID_Package:
#
#  add_Connection_To_PID_Package
#  -----------------------------
#
#   .. command:: add_Connection_To_PID_Package(package git_url)
#
#    Configuring the origin remote repository of the given package, but let its official repository unchanged.
#
#      :package: the name of the native package.
#
#      :git_url: the url of the origin remote used for that package.
#
function(add_Connection_To_PID_Package package git_url)
save_Repository_Context(INITIAL_COMMIT SAVED_CONTENT ${package}) # saving local repository state
change_Origin_Repository(${package} ${git_url} origin) # synchronizing with the remote "origin" git repository
restore_Repository_Context(${package} ${INITIAL_COMMIT} ${SAVED_CONTENT})# restoring local repository state
endfunction(add_Connection_To_PID_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Connection_To_PID_Framework| replace:: ``add_Connection_To_PID_Framework``
#  .. _add_Connection_To_PID_Framework:
#
#  add_Connection_To_PID_Framework
#  -------------------------------
#
#   .. command:: add_Connection_To_PID_Framework(framework git_url)
#
#    Configuring the origin remote repository of the given framework, but let its official repository unchanged.
#
#      :framework: the name of the native framework.
#
#      :git_url: the url of the origin remote used for that framework.
#
function(add_Connection_To_PID_Framework framework git_url)
change_Origin_Framework_Repository(${framework} ${git_url} origin) # synchronizing with the remote "origin" git repository
endfunction(add_Connection_To_PID_Framework)

##################################################
###### clearing/removing deployment units ########
##################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |clear_PID_Package| replace:: ``clear_PID_Package``
#  .. _clear_PID_Package:
#
#  clear_PID_Package
#  -----------------
#
#   .. command:: clear_PID_Package(RESULT package version)
#
#    Remove the installed version of a given package from workspace install tree.
#
#      :package: the name of the package.
#
#      :version: the installed version to remove.
#
#      :RESULT: the output variable that is TRUE if package version has been removed, FALSE otherwise.
#
function(clear_PID_Package RESULT package version)
get_System_Variables(PLATFORM_NAME PACKAGE_STRING)
set(${RESULT} TRUE PARENT_SCOPE)
if("${version}" MATCHES "[0-9]+\\.[0-9]+\\.[0-9]+")	#specific version targetted

	if( EXISTS ${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${package}/${version}
	AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${package}/${version})
		execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${package}/${version})
	else()
		if( EXISTS ${WORKSPACE_DIR}/external/${PLATFORM_NAME}/${package}/${version}
		AND IS_DIRECTORY ${WORKSPACE_DIR}/external/${PLATFORM_NAME}/${package}/${version})
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/external/${PLATFORM_NAME}/${package}/${version})
		else()
			message("[PID] ERROR : package ${package} version ${version} does not resides in workspace install directory.")
			set(${RESULT} FALSE PARENT_SCOPE)
		endif()
	endif()
elseif("${version}" MATCHES "all")#all versions targetted (including own versions and installers folder)
	if( EXISTS ${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${package}
	AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${package})
		execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${package})
	else()
		if( EXISTS ${WORKSPACE_DIR}/external/${PLATFORM_NAME}/${package}
		AND IS_DIRECTORY ${WORKSPACE_DIR}/external/${PLATFORM_NAME}/${package})
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/external/${PLATFORM_NAME}/${package})
		else()
			message("[PID] ERROR : package ${package} is not installed in workspace.")
			set(${RESULT} FALSE PARENT_SCOPE)
		endif()
	endif()
else()
	message("[PID] ERROR : invalid version string : ${version}, possible inputs are version numbers and all.")
	set(${RESULT} FALSE PARENT_SCOPE)
endif()
endfunction(clear_PID_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |remove_PID_Package| replace:: ``remove_PID_Package``
#  .. _remove_PID_Package:
#
#  remove_PID_Package
#  ------------------
#
#   .. command:: remove_PID_Package(package)
#
#    Clear the workspace of any trace of the target package (including its source repository).
#
#      :package: the name of the package.
#
function(remove_PID_Package package)
get_System_Variables(PLATFORM_NAME PACKAGE_STRING)
#clearing install folder
if(	EXISTS ${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${package})
	clear_PID_Package(RES ${package} all)
endif()
#clearing source folder
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/packages/${package})
endfunction(remove_PID_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |remove_PID_Framework| replace:: ``remove_PID_Framework``
#  .. _remove_PID_Framework:
#
#  remove_PID_Framework
#  --------------------
#
#   .. command:: remove_PID_Framework(framework)
#
#    Remove the repository of a given framework from the workspace.
#
#      :framework: the name of the framework.
#
function(remove_PID_Framework framework)
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/sites/frameworks/${framework})
endfunction(remove_PID_Framework)


##################################################
############ registering deployment units ########
##################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |register_PID_Package| replace:: ``register_PID_Package``
#  .. _register_PID_Package:
#
#  register_PID_Package
#  --------------------
#
#   .. command:: register_PID_Package(package)
#
#     Updating the workspace repository with updated (or newly created) reference and find files for a given package.
#
#      :package: the name of the package to register.
#
function(register_PID_Package package)
go_To_Workspace_Master()
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package}/build ${CMAKE_MAKE_PROGRAM} install)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package}/build ${CMAKE_MAKE_PROGRAM} referencing)
publish_Package_References_In_Workspace_Repository(${package})
endfunction(register_PID_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |register_PID_Framework| replace:: ``register_PID_Framework``
#  .. _register_PID_Framework:
#
#  register_PID_Framework
#  ----------------------
#
#   .. command:: register_PID_Framework(framework)
#
#     Updating the workspace repository with an updated (or newly created) reference file for a given framework.
#
#      :framework: the name of the framework to register.
#
function(register_PID_Framework framework)
go_To_Workspace_Master()
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework}/build ${CMAKE_MAKE_PROGRAM} build)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework}/build ${CMAKE_MAKE_PROGRAM} referencing)
publish_Framework_References_In_Workspace_Repository(${framework})
endfunction(register_PID_Framework)

##########################################
############ releasing packages ##########
##########################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |release_PID_Package| replace:: ``release_PID_Package``
#  .. _release_PID_Package:
#
#  release_PID_Package
#  -------------------
#
#   .. command:: release_PID_Package(RESULT package next)
#
#     Release the currently developed package version. This results in marking the currnt version with a git tag.
#
#      :package: the name of the package to release.
#
#      :next: the next version of the package after current has been released.
#
#      :manage_deps: if TRUE the release process will also apply to unreleased dependencies of the package.
#
#      :RESULT: the output variable that is TRUE if package has been released, FALSE otherwise.
#
function(release_PID_Package RESULT package next manage_deps)
set(${RESULT} FALSE PARENT_SCOPE)
# check that current branc of package is integration
get_Repository_Current_Branch(CURRENT_BRANCH ${WORKSPACE_DIR}/packages/${package})
if(NOT CURRENT_BRANCH STREQUAL "integration")
	message("[PID] ERROR : impossible to release package ${TARGET_PACKAGE} because it is not currently on integration branch.")
	return()
endif()

# check for modifications
has_Modifications(HAS_MODIFS ${package})
if(HAS_MODIFS)
	message("[PID] ERROR : impossible to release package ${TARGET_PACKAGE} because there are modifications to commit or stash.")
	return()
endif() # from here we can navigate between branches freely

# udpate the master branch from official remote repository
update_Repository_Versions(UPDATE_OK ${package})
if(NOT UPDATE_OK)
	message("[PID] ERROR : impossible to release package ${TARGET_PACKAGE} because its master branch cannot be updated from official one. Maybe you have no clone rights from official or local master branch of package ${package} is not synchronizable with official master branch.")
	go_To_Integration(${package}) #always go back to integration branch
	return()
endif() #from here graph of commits and version tags are OK

# registering current version
go_To_Integration(${package}) #always release from integration branch
get_Version_Number_And_Repo_From_Package(${package} NUMBER STRING_NUMBER ADDRESS)
# performing basic checks
if(NOT NUMBER)#version number is not well defined
	message("[PID] ERROR : problem releasing package ${package}, bad version format in its root CMakeLists.txt.")
	return()
elseif(NOT ADDRESS)#there is no connected repository ?
	message("[PID] ERROR : problem releasing package ${package}, no address for official remote repository found in your package description.")
	return()
endif()

# check that version is not already released on official/master branch
get_Repository_Version_Tags(AVAILABLE_VERSION_TAGS ${package})
normalize_Version_Tags(VERSION_NUMBERS "${AVAILABLE_VERSION_TAGS}")
if(NOT VERSION_NUMBERS)
	message("[PID] ERROR : malformed package ${package}, no version specified !")
	return()
endif()
foreach(version IN LISTS VERSION_NUMBERS)
	if(version STREQUAL STRING_NUMBER)
		message("[PID] ERROR : cannot release version ${STRING_NUMBER} for package ${package}, because this version already exists.")
		return()
	endif()
endforeach()

# check that there are things to commit to master
check_For_New_Commits_To_Release(COMMITS_AVAILABLE ${package})
if(NOT COMMITS_AVAILABLE)
	message("[PID] WARNING : cannot release package ${package} because integration branch has no commits to contribute to new version.")
	return()
endif()

# check that version of dependencies exist
check_For_Dependencies_Version(BAD_VERSION_OF_DEPENDENCIES ${package})
if(BAD_VERSION_OF_DEPENDENCIES)#there are unreleased dependencies
	if(manage_deps)#the call asks to release the unreleased dependencies
		set(unreleased_dependencies)
		foreach(dep IN LISTS BAD_VERSION_OF_DEPENDENCIES)
			extract_All_Words(${dep} "#" RES_LIST)#extract with # because this is the separator used in check_For_Dependencies_Version
			list(GET RES_LIST 0 DEP_PACKAGE)
			list(GET RES_LIST 1 DEP_VERSION)
			message("[PID] releasing dependency ${DEP_PACKAGE} of ${package}...")
			release_PID_Package(DEP_RESULT ${dep} ${next} TRUE)
			if(NOT DEP_RESULT)
				list(APPEND unreleased_dependencies ${dep})
			endif()
		endforeach()
		if(unreleased_dependencies)
			message("[PID] ERROR : cannot release package ${package} because of problem in release of some of its dependencies:")
			foreach(unreleased_dep IN LISTS unreleased_dependencies)
				extract_All_Words(${unreleased_dep} "#" RES_LIST)#extract with # because this is the separator used in check_For_Dependencies_Version
				list(GET RES_LIST 0 DEP_PACKAGE)
				list(GET RES_LIST 1 DEP_VERSION)
				message("- dependency ${DEP_PACKAGE} version ${DEP_VERSION}")
			endforeach()
		else()
			check_For_Dependencies_Version(BAD_VERSION_OF_DEPENDENCIES ${package})
		endif()
	endif()

	if(BAD_VERSION_OF_DEPENDENCIES)#there are unreleased dependencies
		message("[PID] ERROR : cannot release package ${package} because of invalid version of dependencies:")
		foreach(dep IN LISTS BAD_VERSION_OF_DEPENDENCIES)
			extract_All_Words(${dep} "#" RES_LIST)#extract with # because this is the separator used in check_For_Dependencies_Version
			list(GET RES_LIST 0 DEP_PACKAGE)
			list(GET RES_LIST 1 DEP_VERSION)
			message("- dependency ${DEP_PACKAGE} has unknown version ${DEP_VERSION}")
		endforeach()
		return()
	endif()
endif()

# build one time to be sure it builds and tests are passing
build_And_Install_Source(IS_BUILT ${package} "" "integration" TRUE)
if(NOT IS_BUILT)
	message("[PID] ERROR : cannot release package ${package}, because its integration branch doesnot build.")
	return()
endif()

# check that integration is a fast forward of master
merge_Into_Master(MERGE_OK ${package} ${STRING_NUMBER})
if(NOT MERGE_OK)
	message("[PID] ERROR : cannot release package ${package}, because there are potential merge conflicts between master and integration branches. Please update ${package} integration branch first then launch again the release process.")
	go_To_Integration(${package}) #always go back to integration branch
	return()
endif()
tag_Version(${package} ${STRING_NUMBER} TRUE)#create the version tag
publish_Repository_Version(${package} ${STRING_NUMBER} RESULT_OK)
if(NOT RESULT_OK) #the user has no sufficient push rights
	tag_Version(${package} ${STRING_NUMBER} FALSE)#remove local tag
	message("[PID] ERROR : cannot release package ${package}, because your are not allowed to push to its master branch !")
	go_To_Integration(${package}) #always go back to integration branch
	return()
endif()
#remove the installed version built from integration branch
file(REMOVE_RECURSE ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM_NAME}/${package}/${STRING_NUMBER}
#rebuild package from master branch to get a clean installed version (getting clean use file)
build_And_Install_Source(IS_BUILT ${package} ${STRING_NUMBER} "" FALSE)
#merge back master into integration
merge_Into_Integration(${package})

### now starting a new version
list(GET NUMBER 0 major)
list(GET NUMBER 1 minor)
list(GET NUMBER 2 patch)
if("${next}" STREQUAL "MAJOR")
	math(EXPR major "${major}+1")
	set(minor 0)
	set(patch 0)
elseif("${next}" STREQUAL "MINOR")
	math(EXPR minor "${minor}+1")
	set(patch 0)
elseif("${next}" STREQUAL "PATCH")
	math(EXPR patch "${patch}+1")
else()#default behavior
	math(EXPR minor "${minor}+1")
	set(patch 0)
endif()
# still on integration branch
set_Version_Number_To_Package(${package} ${major} ${minor} ${patch}) #change the package description with new version
register_Repository_Version(${package} "${major}.${minor}.${patch}") # commit new modified version
publish_Repository_Integration(${package})#if publication rejected => user has to handle merge by hand
set(${RESULT} ${STRING_NUMBER} PARENT_SCOPE)
update_Remotes(${package}) #synchronize information on remotes with local one (sanity process, not mandatory)
endfunction(release_PID_Package)

##########################################
############ updating packages ###########
##########################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_PID_Source_Package| replace:: ``update_PID_Source_Package``
#  .. _update_PID_Source_Package:
#
#  update_PID_Source_Package
#  -------------------------
#
#   .. command:: update_PID_Source_Package(package)
#
#     Update a native package based on git tags of its source repository.
#
#      :package: the name of the native package to update.
#
function(update_PID_Source_Package package)
get_System_Variables(PLATFORM_NAME PACKAGE_STRING)
set(INSTALLED FALSE)
message("[PID] INFO : launch the update of source package ${package}...")
list_Version_Subdirectories(version_dirs ${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${package})
deploy_Source_Native_Package(INSTALLED ${package} "${version_dirs}" FALSE)
if(NOT INSTALLED)
	message("[PID] ERROR : cannot update ${package}.")
else()
	message("[PID] INFO : package ${package} update finished.")
endif()
endfunction(update_PID_Source_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_PID_Binary_Package| replace:: ``update_PID_Binary_Package``
#  .. _update_PID_Binary_Package:
#
#  update_PID_Binary_Package
#  -------------------------
#
#   .. command:: update_PID_Binary_Package(package)
#
#     Update a native package based on references on its available binary archives.
#
#      :package: the name of the naive package to update.
#
function(update_PID_Binary_Package package)
get_System_Variables(PLATFORM_NAME PACKAGE_STRING)
message("[PID] INFO : launch the update of binary package ${package}...")
list_Version_Subdirectories(version_dirs ${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${package})
deploy_Binary_Native_Package(DEPLOYED ${package} "${version_dirs}")
if(NOT DEPLOYED)
	message("[PID] ERROR : cannot update ${package}.")
else()
	message("[PID] INFO : package ${package} update finished...")
endif()
endfunction(update_PID_Binary_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_PID_External_Package| replace:: ``update_PID_External_Package``
#  .. _update_PID_External_Package:
#
#  update_PID_External_Package
#  ---------------------------
#
#   .. command:: update_PID_External_Package(package)
#
#     Deprecated. Update an external package based on references on its available binary archives.
#
#      :package: the name of the external package to update.
#
function(update_PID_External_Package package)
message("[PID] INFO : new versions of external binary package ${package} will not be installed automatically (only if a new version is required by native package)...")
endfunction(update_PID_External_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_PID_All_Packages| replace:: ``update_PID_All_Packages``
#  .. _update_PID_All_Packages:
#
#  update_PID_All_Packages
#  -----------------------
#
#   .. command:: update_PID_All_Packages()
#
#     Update all packages versions of all packages deployed in workspace.
#
function(update_PID_All_Packages)
set(NATIVES)
set(EXTERNALS)
set(SOURCE_PACKAGES)
list_All_Binary_Packages_In_Workspace(NATIVES EXTERNALS)
list_All_Source_Packages_In_Workspace(SOURCE_PACKAGES)

if(SOURCE_PACKAGES)
	if(NATIVES)
		list(REMOVE_ITEM NATIVES ${SOURCE_PACKAGES})
	endif()
	foreach(package IN LISTS SOURCE_PACKAGES)
		update_PID_Source_Package(${package})
	endforeach()
endif()
if(NATIVES)
	foreach(package IN LISTS NATIVES)
		load_Package_Binary_References(REFERENCES_OK ${package})
		if(NOT REFERENCES_OK)
			message("[PID] WARNING : no binary reference exists for the package ${package}. Cannot update it ! Please contact the maintainer of package ${package} to have more information about this problem.")
		else()
			update_PID_Binary_Package(${package})
		endif()
	endforeach()
endif()
if(EXTERNALS)
	foreach(package IN LISTS EXTERNALS)
		load_Package_Binary_References(REFERENCES_OK ${package})
		if(NOT REFERENCES_OK)
			message("[PID] WARNING : no binary reference exists for the package ${package}. Cannot update it ! Please contact the maintainer of package ${package} to have more information about this problem.")
		else()
			update_PID_External_Package(${package})
		endif()
	endforeach()
endif()
endfunction(update_PID_All_Packages)

#.rst:
#
# .. ifmode:: internal
#
#  .. |upgrade_Workspace| replace:: ``upgrade_Workspace``
#  .. _upgrade_Workspace:
#
#  upgrade_Workspace
#  -----------------
#
#   .. command:: upgrade_Workspace(remote update)
#
#     Upgrade the worskpace. This resultats in getting last version of PID APIs and updated references to packages/framework/wrappers.
#
#      :remote: the remote of workspace to use for update (origin or official).
#
#      :update: if TRUE all packages will be updated after the workspace upgrade.
#
function(upgrade_Workspace remote update)
save_Workspace_Repository_Context(CURRENT_COMMIT SAVED_CONTENT)
update_Workspace_Repository(${remote})
restore_Workspace_Repository_Context(${CURRENT_COMMIT} ${SAVED_CONTENT})
message("[PID] WARNING: You may have to resolve some conflicts in your source packages !")
if(update)
	update_PID_All_Packages()
endif()
endfunction(upgrade_Workspace)

########################################################################
######################## Licenses management ###########################
########################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Available_Licenses| replace:: ``print_Available_Licenses``
#  .. _print_Available_Licenses:
#
#  print_Available_Licenses
#  ------------------------
#
#   .. command:: print_Available_Licenses()
#
#     Print brief description of all licenses available in workspace.
#
function(print_Available_Licenses)
file(GLOB ALL_AVAILABLE_LICENSES ${WORKSPACE_DIR}/share/cmake/licenses/*.cmake)
list(REMOVE_DUPLICATES ALL_AVAILABLE_LICENSES)
set(licenses "")
foreach(licensefile IN LISTS ALL_AVAILABLE_LICENSES)
	get_filename_component(licensefilename ${licensefile} NAME)
	string(REGEX REPLACE "^License([^\\.]+)\\.cmake$" "\\1" a_license "${licensefilename}")
	if(NOT "${a_license}" STREQUAL "${licensefilename}")#it matches
		list(APPEND licenses ${a_license})
	endif()
endforeach()
set(res_licenses_string "")
fill_String_From_List("${licenses}" res_licenses_string)
message("AVAILABLE LICENSES: ${res_licenses_string}")
endfunction(print_Available_Licenses)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_License_Info| replace:: ``print_License_Info``
#  .. _print_License_Info:
#
#  print_License_Info
#  ------------------
#
#   .. command:: print_License_Info(license)
#
#     Print description of a given license.
#
#      :license: the name of the license to print (e.g. GNUGPL).
#
function(print_License_Info license)
message("LICENSE: ${LICENSE_NAME}")
message("VERSION: ${LICENSE_VERSION}")
message("OFFICIAL NAME: ${LICENSE_FULLNAME}")
message("AUTHORS: ${LICENSE_AUTHORS}")
endfunction(print_License_Info)


########################################################################
######################## Platforms management ##########################
########################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |detect_Current_Platform| replace:: ``detect_Current_Platform``
#  .. detect_Current_Platform:
#
#  detect_Current_Platform
#  -----------------------
#
#   .. command:: detect_Current_Platform()
#
#     Puts into cmake variables the description of current platform, deduced from current environment.
#
function(detect_Current_Platform)
	# Now detect the current platform maccording to host environemnt selection (call to script for platform detection)
	include(CheckTYPE)
	include(CheckARCH)
	include(CheckOS)
	include(CheckABI)
	include(CheckPython)
	if(CURRENT_DISTRIBUTION STREQUAL "")
		set(WORKSPACE_CONFIGURATION_DESCRIPTION " + processor family = ${CURRENT_TYPE}\n + binary architecture= ${CURRENT_ARCH}\n + operating system=${CURRENT_OS}\n + compiler ABI= ${CURRENT_ABI}")
	else()
		if(CURRENT_DISTRIBUTION_VERSION STREQUAL "")
			set(WORKSPACE_CONFIGURATION_DESCRIPTION " + processor family= ${CURRENT_TYPE}\n + binary architecture= ${CURRENT_ARCH}\n + operating system=${CURRENT_OS} (${CURRENT_DISTRIBUTION})\n + compiler ABI= ${CURRENT_ABI}")
		else()#there is a version number bound to the distribution
			set(WORKSPACE_CONFIGURATION_DESCRIPTION " + processor family= ${CURRENT_TYPE}\n + binary architecture= ${CURRENT_ARCH}\n + operating system=${CURRENT_OS} (${CURRENT_DISTRIBUTION} ${CURRENT_DISTRIBUTION_VERSION})\n + compiler ABI= ${CURRENT_ABI}")
		endif()
	endif()
	#simply rewriting previously defined variable to normalize their names between workspace and packages (same accessor function can then be used from any place)
	set(CURRENT_PACKAGE_STRING ${CURRENT_PACKAGE_STRING} CACHE INTERNAL "" FORCE)
	set(CURRENT_DISTRIBUTION ${CURRENT_DISTRIBUTION} CACHE INTERNAL "" FORCE)
	set(CURRENT_PLATFORM_TYPE ${CURRENT_TYPE} CACHE INTERNAL "" FORCE)
	set(CURRENT_PLATFORM_ARCH ${CURRENT_ARCH} CACHE INTERNAL "" FORCE)
	set(CURRENT_PLATFORM_OS ${CURRENT_OS} CACHE INTERNAL "" FORCE)
	if(CURRENT_ABI STREQUAL CXX11)
		set(CURRENT_PLATFORM_ABI abi11 CACHE INTERNAL "" FORCE)
	else()
		set(CURRENT_PLATFORM_ABI abi98 CACHE INTERNAL "" FORCE)
	endif()

	if(CURRENT_PLATFORM_OS)#the OS is optional (for microcontrolers there is no OS)
		set(CURRENT_PLATFORM ${CURRENT_PLATFORM_TYPE}_${CURRENT_PLATFORM_ARCH}_${CURRENT_PLATFORM_OS}_${CURRENT_PLATFORM_ABI} CACHE INTERNAL "" FORCE)
	else()
		set(CURRENT_PLATFORM ${CURRENT_PLATFORM_TYPE}_${CURRENT_PLATFORM_ARCH}_${CURRENT_PLATFORM_ABI} CACHE INTERNAL "" FORCE)
	endif()

	set(EXTERNAL_PACKAGE_BINARY_INSTALL_DIR ${CMAKE_SOURCE_DIR}/external/${CURRENT_PLATFORM} CACHE INTERNAL "")
	set(PACKAGE_BINARY_INSTALL_DIR ${CMAKE_SOURCE_DIR}/install/${CURRENT_PLATFORM} CACHE INTERNAL "")
	message("[PID] INFO : Target platform in use is ${CURRENT_PLATFORM}:\n${WORKSPACE_CONFIGURATION_DESCRIPTION}\n")

	if(CURRENT_PYTHON)
		message("[PID] INFO : Python may be used, target python version in use is ${CURRENT_PYTHON}. To use python modules installed in workspace please set the PYTHONPATH to =${WORKSPACE_DIR}/install/python${CURRENT_PYTHON}\n")
	endif()
endfunction(detect_Current_Platform)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Current_Configuration_Build_Related_Variables| replace:: ``write_Current_Configuration_Build_Related_Variables``
#  .. _write_Current_Configuration_Build_Related_Variables:
#
#  write_Current_Configuration_Build_Related_Variables
#  ---------------------------------------------------
#
#   .. command:: write_Current_Configuration_Build_Related_Variables(file)
#
#     Append to a given file the content of advanced build options used by CMake.
#
#      :file: the path to the file to write in.
#
function(write_Current_Configuration_Build_Related_Variables file)
file(WRITE ${file} "")
file(APPEND ${file} "set(CMAKE_AR \"${CMAKE_AR}\" CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_CXX_COMPILER \"${CMAKE_CXX_COMPILER}\" CACHE FILEPATH \"\" FORCE)\n")
if(CURRENT_ABI STREQUAL "CXX11")
	#this line is needed to force the compiler to use libstdc++11 newer version of API whatever the version of the distribution is
	#e.g. on ubuntu 14 with compiler gcc 5.4 the default value keeps
	set(TEMP_FLAGS ${CMAKE_CXX_FLAGS} -D_GLIBCXX_USE_CXX11_ABI=1)
	list(REMOVE_DUPLICATES TEMP_FLAGS)#just to avoid repeating the same option again and again at each workspace configuration time
	set(CMAKE_CXX_FLAGS ${TEMP_FLAGS} CACHE STRING "" FORCE)
endif()

file(APPEND ${file} "set(CMAKE_CXX_FLAGS \"${CMAKE_CXX_FLAGS}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_CXX_FLAGS_DEBUG \"${CMAKE_CXX_FLAGS_DEBUG}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_CXX_FLAGS_MINSIZEREL \"${CMAKE_CXX_FLAGS_MINSIZEREL}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_CXX_FLAGS_RELEASE \"${CMAKE_CXX_FLAGS_RELEASE}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_CXX_FLAGS_RELWITHDEBINFO \"${CMAKE_CXX_FLAGS_RELWITHDEBINFO}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_C_COMPILER \"${CMAKE_C_COMPILER}\" CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_C_FLAGS \"${CMAKE_C_FLAGS}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_C_FLAGS_DEBUG \"${CMAKE_C_FLAGS_DEBUG}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_C_FLAGS_MINSIZEREL \"${CMAKE_C_FLAGS_MINSIZEREL}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_C_FLAGS_RELEASE \"${CMAKE_C_FLAGS_RELEASE}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_C_FLAGS_RELWITHDEBINFO \"${CMAKE_C_FLAGS_RELWITHDEBINFO}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_EXE_LINKER_FLAGS \"${CMAKE_EXE_LINKER_FLAGS}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_EXE_LINKER_FLAGS_DEBUG \"${CMAKE_EXE_LINKER_FLAGS_DEBUG}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL \"${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_EXE_LINKER_FLAGS_RELEASE \"${CMAKE_EXE_LINKER_FLAGS_RELEASE}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO \"${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_LINKER \"${CMAKE_LINKER}\" CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MAKE_PROGRAM \"${CMAKE_MAKE_PROGRAM}\" CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MODULE_LINKER_FLAGS \"${CMAKE_MODULE_LINKER_FLAGS}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MODULE_LINKER_FLAGS_DEBUG \"${CMAKE_MODULE_LINKER_FLAGS_DEBUG}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL \"${CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MODULE_LINKER_FLAGS_RELEASE \"${CMAKE_MODULE_LINKER_FLAGS_RELEASE}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO \"${CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_NM \"${CMAKE_NM}\" CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_OBJCOPY \"${CMAKE_OBJCOPY}\" CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_OBJDUMP \"${CMAKE_OBJDUMP}\" CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_RANLIB \"${CMAKE_RANLIB}\" CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SHARED_LINKER_FLAGS \"${CMAKE_SHARED_LINKER_FLAGS}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SHARED_LINKER_FLAGS_DEBUG \"${CMAKE_SHARED_LINKER_FLAGS_DEBUG}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL \"${CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SHARED_LINKER_FLAGS_RELEASE \"${CMAKE_SHARED_LINKER_FLAGS_RELEASE}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO \"${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_STATIC_LINKER_FLAGS \"${CMAKE_STATIC_LINKER_FLAGS}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_STATIC_LINKER_FLAGS_DEBUG \"${CMAKE_STATIC_LINKER_FLAGS_DEBUG}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL \"${CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_STATIC_LINKER_FLAGS_RELEASE \"${CMAKE_STATIC_LINKER_FLAGS_RELEASE}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO \"${CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO}\" CACHE STRING \"\" FORCE)\n")

# defining additionnal build configuration variables related to the current platform build system in use (private variables)

## cmake related
file(APPEND ${file} "set(CMAKE_MODULE_PATH \"${CMAKE_MODULE_PATH}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MAKE_PROGRAM \"${CMAKE_MAKE_PROGRAM}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_GENERATOR \"${CMAKE_GENERATOR}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_EXTRA_GENERATOR \"${CMAKE_EXTRA_GENERATOR}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_GENERATOR_TOOLSET \"${CMAKE_GENERATOR_TOOLSET}\" CACHE INTERNAL \"\" FORCE)\n")

## system related
file(APPEND ${file} "set(CMAKE_FIND_LIBRARY_PREFIXES \"${CMAKE_FIND_LIBRARY_PREFIXES}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_FIND_LIBRARY_SUFFIXES \"${CMAKE_FIND_LIBRARY_SUFFIXES}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SYSTEM_PREFIX_PATH \"${CMAKE_SYSTEM_PREFIX_PATH}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_LIBRARY_ARCHITECTURE ${CMAKE_LIBRARY_ARCHITECTURE} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SYSTEM_PROGRAM_PATH \"${CMAKE_SYSTEM_PROGRAM_PATH}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SYSTEM_INCLUDE_PATH \"${CMAKE_SYSTEM_INCLUDE_PATH}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SYSTEM_LIBRARY_PATH \"${CMAKE_SYSTEM_LIBRARY_PATH}\" CACHE INTERNAL \"\" FORCE)\n")

## compiler related
file(APPEND ${file} "set(CMAKE_COMPILER_IS_GNUCXX \"${CMAKE_COMPILER_IS_GNUCXX}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_CXX_COMPILER_ID \"${CMAKE_CXX_COMPILER_ID}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_CXX_COMPILER_VERSION \"${CMAKE_CXX_COMPILER_VERSION}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SIZEOF_VOID_P \"${CMAKE_SIZEOF_VOID_P}\" CACHE INTERNAL \"\" FORCE)\n")

# Finnally defining variables related to crosscompilation
file(APPEND ${file} "set(PID_CROSSCOMPILATION ${PID_CROSSCOMPILATION} CACHE INTERNAL \"\" FORCE)\n")
if(PID_CROSSCOMPILATION) #only write these information if we are trully cross compiling
	file(APPEND ${file} "set(CMAKE_CROSSCOMPILING \"${CMAKE_CROSSCOMPILING}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_SYSTEM_NAME \"${CMAKE_SYSTEM_NAME}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_SYSTEM_VERSION \"${CMAKE_SYSTEM_VERSION}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_SYSTEM_PROCESSOR \"${CMAKE_SYSTEM_PROCESSOR}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_C_COMPILER_TARGET \"${CMAKE_C_COMPILER_TARGET}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_CXX_COMPILER_TARGET \"${CMAKE_CXX_COMPILER_TARGET}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN \"${CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN ${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_SYSROOT \"${CMAKE_SYSROOT}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM \"${CMAKE_FIND_ROOT_PATH_MODE_PROGRAM}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY \"${CMAKE_FIND_ROOT_PATH_MODE_LIBRARY}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE \"${CMAKE_FIND_ROOT_PATH_MODE_INCLUDE}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE \"${CMAKE_FIND_ROOT_PATH_MODE_PACKAGE}\" CACHE INTERNAL \"\" FORCE)\n")
endif()
endfunction(write_Current_Configuration_Build_Related_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Platform_Description| replace:: ``write_Platform_Description``
#  .. _write_Platform_Description:
#
#  write_Platform_Description
#  --------------------------
#
#   .. command:: write_Platform_Description(file)
#
#     (Re)Writing to a given file the cache variables of the workspace defining the current platform in use.
#
#      :file: the path to the file to write in.
#
function(write_Platform_Description file)
file(WRITE ${file} "")#reset the file

# defining properties of the current platform
file(APPEND ${file} "set(CURRENT_PLATFORM ${CURRENT_PLATFORM} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CURRENT_PACKAGE_STRING ${CURRENT_PACKAGE_STRING} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CURRENT_DISTRIBUTION ${CURRENT_DISTRIBUTION} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CURRENT_DISTRIBUTION_VERSION ${CURRENT_DISTRIBUTION_VERSION} CACHE INTERNAL \"\" FORCE)\n")

file(APPEND ${file} "set(CURRENT_PLATFORM_TYPE ${CURRENT_PLATFORM_TYPE} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CURRENT_PLATFORM_ARCH ${CURRENT_PLATFORM_ARCH} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CURRENT_PLATFORM_OS ${CURRENT_PLATFORM_OS} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CURRENT_PLATFORM_ABI ${CURRENT_PLATFORM_ABI} CACHE INTERNAL \"\" FORCE)\n")

#default install path used for that platform
file(APPEND ${file} "set(EXTERNAL_PACKAGE_BINARY_INSTALL_DIR ${EXTERNAL_PACKAGE_BINARY_INSTALL_DIR} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(PACKAGE_BINARY_INSTALL_DIR ${PACKAGE_BINARY_INSTALL_DIR} CACHE INTERNAL \"\" FORCE)\n")

if(CURRENT_ENVIRONMENT)
	file(APPEND ${file} "set(CURRENT_ENVIRONMENT ${CURRENT_ENVIRONMENT} CACHE INTERNAL \"\" FORCE)\n")
else()
	file(APPEND ${file} "set(CURRENT_ENVIRONMENT host CACHE INTERNAL \"\" FORCE)\n")
endif()
	#managing python
	file(APPEND ${file} "set(CURRENT_PYTHON ${CURRENT_PYTHON} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PYTHON_EXECUTABLE ${CURRENT_PYTHON_EXECUTABLE} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PYTHON_LIBRARIES ${CURRENT_PYTHON_LIBRARIES} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PYTHON_INCLUDE_DIRS ${CURRENT_PYTHON_INCLUDE_DIRS} CACHE INTERNAL \"\" FORCE)\n")
endfunction(write_Platform_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Current_Configuration| replace:: ``write_Current_Configuration``
#  .. _write_Current_Configuration:
#
#  write_Current_Configuration
#  ---------------------------
#
#   .. command:: write_Current_Configuration(file)
#
#     Writing to the global file allowing to access all workspace related global variables.
#
#      :file: the path to the file to write in.
#
function(write_Current_Configuration file)
file(WRITE ${file} "")
write_Platform_Description(${CMAKE_BINARY_DIR}/Workspace_Platforms_Description.cmake)
file(APPEND ${file} "include(${CMAKE_BINARY_DIR}/Workspace_Platforms_Description.cmake NO_POLICY_SCOPE)\n")
write_Current_Configuration_Build_Related_Variables(${CMAKE_BINARY_DIR}/Workspace_Build_Info.cmake)
file(APPEND ${file} "include(${CMAKE_BINARY_DIR}/Workspace_Build_Info.cmake NO_POLICY_SCOPE)\n")
# defining all build configuration variables related to the current platform
endfunction(write_Current_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Platforms| replace:: ``manage_Platforms``
#  .. _manage_Platforms:
#
#  manage_Platforms
#  ----------------
#
#   .. command:: manage_Platforms(path_to_workspace)
#
#     Define the current platform in use and provide to the user some options to control finally targetted platform.
#
#      :path_to_workspace: the path to the workspace root.
#
function(manage_Platforms path_to_workspace)
set(WORKSPACE_DIR ${path_to_workspace} CACHE INTERNAL "")
if(CURRENT_ENVIRONMENT)
	#load the environment description
	include(${CMAKE_SOURCE_DIR}/environments/${CURRENT_ENVIRONMENT}/PID_Environment_Description.cmake)
	message("[PID] INFO: ${PID_ENVIRONMENT_DESCRIPTION}")
else()
	message("[PID] INFO: development environment in use is the host default environment (based on ${CMAKE_CXX_COMPILER_ID} build toolchain).")
endif()

# detecting which platform is in use according to environment description
detect_Current_Platform()

# generate the current platform configuration file (that will be used to build packages)
set(CONFIG_FILE ${CMAKE_BINARY_DIR}/Workspace_Platforms_Info.cmake)
write_Current_Configuration(${CONFIG_FILE})

endfunction(manage_Platforms)


########################################################################
########################## Plugins management ##########################
########################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |register_Available_Plugins| replace:: ``register_Available_Plugins``
#  .. _register_Available_Plugins:
#
#  register_Available_Plugins
#  --------------------------
#
#   .. command:: register_Available_Plugins()
#
#     Find available plugins in workspace and create user options to (de)activate them.
#
function(register_Available_Plugins)
file(GLOB ALL_AVAILABLE_PLUGINS RELATIVE ${CMAKE_SOURCE_DIR}/share/cmake/plugins ${CMAKE_SOURCE_DIR}/share/cmake/plugins/*) #getting plugins container folders names
	if(NOT ALL_AVAILABLE_PLUGINS)
		set(WORKSPACE_ALL_PLUGINS CACHE INTERNAL "")
		set(WORKSPACE_ACTIVE_PLUGINS CACHE INTERNAL "")
		set(WORKSPACE_INACTIVE_PLUGINS CACHE INTERNAL "")
		return()
	endif()
	set(ALL_PLUGINS_DEFINED)
	foreach(plugin IN LISTS ALL_AVAILABLE_PLUGINS)#filtering plugins description files (check if these are really cmake files related to plugins description, according to the PID standard)
		include(${CMAKE_SOURCE_DIR}/share/cmake/plugins/${plugin}/plugin_description.cmake OPTIONAL RESULT_VARIABLE res)

		if(NOT res STREQUAL NOTFOUND)# there may have other dirty files in the folder and we just do not consider them
			list(APPEND ALL_PLUGINS_DEFINED ${plugin})
			option(PLUGIN_${plugin} "${${plugin}_PLUGIN_DESCRIPTION}" OFF)
		endif()
	endforeach()
	list(REMOVE_DUPLICATES ALL_PLUGINS_DEFINED)
	if(NOT ALL_PLUGINS_DEFINED)
		set(WORKSPACE_ALL_PLUGINS CACHE INTERNAL "")
		set(WORKSPACE_ACTIVE_PLUGINS CACHE INTERNAL "")
		set(WORKSPACE_INACTIVE_PLUGINS CACHE INTERNAL "")
		return()
	endif()

	# detecting which plugins are active
	set(WORKSPACE_ALL_PLUGINS ${ALL_PLUGINS_DEFINED} CACHE INTERNAL "")
	set(ALL_PLUGINS_ACTIVE)
	foreach(plugin IN LISTS WORKSPACE_ALL_PLUGINS)
		if(PLUGIN_${plugin})
			list(APPEND ALL_PLUGINS_ACTIVE ${plugin})
		else()
			list(APPEND ALL_PLUGINS_INACTIVE ${plugin})
		endif()
	endforeach()
	set(WORKSPACE_ACTIVE_PLUGINS ${ALL_PLUGINS_ACTIVE} CACHE INTERNAL "")
	set(WORKSPACE_INACTIVE_PLUGINS ${ALL_PLUGINS_INACTIVE} CACHE INTERNAL "")
endfunction(register_Available_Plugins)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Plugins_Info_File| replace:: ``write_Plugins_Info_File``
#  .. _write_Plugins_Info_File:
#
#  write_Plugins_Info_File
#  -----------------------
#
#   .. command:: write_Plugins_Info_File(file)
#
#     Write workspace cache variable related to plugins management into a cmake file.
#
#      :file: the path to the file to write in.
#
function(write_Plugins_Info_File file)
file(WRITE ${file} "")
file(APPEND ${file} "set(WORKSPACE_ALL_PLUGINS ${WORKSPACE_ALL_PLUGINS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(WORKSPACE_ACTIVE_PLUGINS ${WORKSPACE_ACTIVE_PLUGINS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(WORKSPACE_INACTIVE_PLUGINS ${WORKSPACE_INACTIVE_PLUGINS} CACHE INTERNAL \"\")\n")
if(WORKSPACE_ACTIVE_PLUGINS)
	foreach(plugin IN LISTS WORKSPACE_ACTIVE_PLUGINS)
		file(APPEND ${file} "set(${plugin}_PLUGIN_ACTIVATION_MESSAGE \"${${plugin}_PLUGIN_ACTIVATION_MESSAGE}\" CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${plugin}_PLUGIN_DEACTIVATION_MESSAGE \"${${plugin}_PLUGIN_DEACTIVATION_MESSAGE}\" CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${plugin}_PLUGIN_RESIDUAL_FILES ${${plugin}_PLUGIN_RESIDUAL_FILES} CACHE INTERNAL \"\")\n")
	endforeach()
endif()
endfunction(write_Plugins_Info_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins| replace:: ``manage_Plugins``
#  .. _manage_Plugins:
#
#  manage_Plugins
#  --------------
#
#   .. command:: manage_Plugins()
#
#     Define active plugins among available ones in workspace and depending on user options.
#
function(manage_Plugins)

# listing all available plugins from plugins definitions cmake files found in the workspace
register_Available_Plugins()

if(WORKSPACE_ACTIVE_PLUGINS)
	message("[PID] INFO : Active plugins")
	foreach(plugin IN LISTS WORKSPACE_ACTIVE_PLUGINS)
		message("  + ${plugin} : ${${plugin}_PLUGIN_ACTIVATED_MESSAGE}")
	endforeach()
endif()

set(PLUGINS_FILE ${CMAKE_BINARY_DIR}/Workspace_Plugins_Info.cmake)
write_Plugins_Info_File(${PLUGINS_FILE})
endfunction(manage_Plugins)
