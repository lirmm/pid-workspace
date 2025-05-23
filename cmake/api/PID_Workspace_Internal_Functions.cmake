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
if(PID_WORKSPACE_INTERNAL_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_WORKSPACE_INTERNAL_FUNCTIONS_INCLUDED TRUE)

cmake_minimum_required(VERSION 3.19.8)

########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Plugins_Management NO_POLICY_SCOPE)
include(PID_Version_Management_Functions NO_POLICY_SCOPE)
include(PID_Progress_Management_Functions NO_POLICY_SCOPE)
include(PID_Finding_Functions NO_POLICY_SCOPE)
include(PID_Package_Build_Targets_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Configuration_Functions NO_POLICY_SCOPE)
include(PID_Deployment_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
include(PID_Meta_Information_Management_Functions NO_POLICY_SCOPE)
include(PID_Profiles_Functions NO_POLICY_SCOPE)
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
#      :root_category: the name of the root category defined in framework.
#      :all_packages: the list of all packages known in workspace.
#
function(classify_Framework_Root_Category framework root_category all_packages)
foreach(package IN LISTS all_packages)
	if(${package}_FRAMEWORK STREQUAL "${framework}")#check if the package belongs to the framework
		foreach(a_category IN LISTS ${package}_CATEGORIES)
			list(FIND ${framework}_CATEGORIES ${a_category} INDEX)
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
#      :category_full_string: the complete category string (e.g. math/geometry).
#      :root_category: the name of the root category defined in framework.
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
set(ALL_AVAILABLE_ENVIRONMENTS)

get_All_Available_References(reference_files "")
foreach(a_ref_file IN LISTS reference_files)# 2) including all reference files and memorizing packages and frameworks names
	string(REGEX REPLACE "^Refer([^\\.]+)\\.cmake$" "\\1" DEPLOYMENT_UNIT_NAME ${a_ref_file})
	if(DEPLOYMENT_UNIT_NAME MATCHES External)#it is an external package
		string(REGEX REPLACE "^External([^\\.]+)$" "\\1" EXTERNAL_NAME ${DEPLOYMENT_UNIT_NAME})
		list(APPEND ALL_AVAILABLE_PACKAGES ${EXTERNAL_NAME})
	elseif(DEPLOYMENT_UNIT_NAME MATCHES Framework)#it is a framework
		string(REGEX REPLACE "^Framework([^\\.]+)$" "\\1" FRAMEWORK_NAME ${DEPLOYMENT_UNIT_NAME})
		list(APPEND ALL_AVAILABLE_FRAMEWORKS ${FRAMEWORK_NAME})
	elseif(DEPLOYMENT_UNIT_NAME MATCHES Environment)#it is a framework
		string(REGEX REPLACE "^Environment([^\\.]+)$" "\\1" ENVIRONMENT_NAME ${DEPLOYMENT_UNIT_NAME})
		list(APPEND ALL_AVAILABLE_FRAMEWORKS ${FRAMEWORK_NAME})
	else() #it is a native package -> no need to parse more
		list(APPEND ALL_AVAILABLE_PACKAGES ${DEPLOYMENT_UNIT_NAME})
	endif()
	include(Refer${DEPLOYMENT_UNIT_NAME})#directly include (since we know it exists): since module based resolution is based on CMAKE_MODULE_PATH only the first corresponding reference file in the list (the one with highest priority) will be included in the end
endforeach()

set(ALL_PACKAGES ${ALL_AVAILABLE_PACKAGES} CACHE INTERNAL "")
set(ALL_FRAMEWORKS ${ALL_AVAILABLE_FRAMEWORKS} CACHE INTERNAL "")
set(ALL_ENVIRONMENTS ${ALL_AVAILABLE_ENVIRONMENTS} CACHE INTERNAL "")
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
	foreach(a_category IN LISTS ${framework}_CATEGORIES)
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
#      :root_category: the name of the root category that is currently managed in classification process.
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
#   Write in the workspace category description file (pid-workspace/build/CategoriesInfo.cmake) all the cache variables generated by the classification process. This file is used by script for finding info on categories.
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
#      :category: the string defining the category.
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
#      :current_category_full_path: the full path of the currently managed category.
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
#      :current_category_full_path: the full path of the currently managed category.
#
#      :RESULTING_SHORT_NAME: the output variable containing the short name of the category.
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
#      :current_category_full_path: the full path of the currently managed category.
#      :number_of_tabs: number of tabulations to use before printing category information.
#
function(print_Category root_category category number_of_tabs)
	set(PRINTED_VALUE "")
	set(RESULT_STRING "")
	set(index ${number_of_tabs})
	while(index GREATER 0)
		set(RESULT_STRING "${RESULT_STRING}	")
		math(EXPR index "${index}-1")
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
		math(EXPR sub_cat_nb_tabs "${number_of_tabs}+1")
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
#      :root_category: the name of root category.
#      :current_category_full_path: the full path of the currently managed category.
#      :number_of_tabs: number of tabulations to use before printing category information.
#
function(print_Framework_Category framework root_category category number_of_tabs)
	set(PRINTED_VALUE "")
	set(RESULT_STRING "")
	set(index ${number_of_tabs})
	while(index GREATER 0)
		set(RESULT_STRING "${RESULT_STRING}	")
		math(EXPR index "${index}-1")
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
	math(EXPR sub_cat_nb_tabs "${number_of_tabs}+1")
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
#  .. |print_Native_Package_Info| replace:: ``print_Native_Package_Info``
#  .. _print_Native_Package_Info:
#
#  print_Native_Package_Info
#  -------------------------
#
#   .. command:: print_Native_Package_Info(package)
#
#   Print to standard output information about a given native package.
#
#      :package: the name of the package.
#
function(print_Native_Package_Info package)
	message("NATIVE PACKAGE: ${package}")
	fill_String_From_List(descr_string ${package}_DESCRIPTION " ")
	message("DESCRIPTION: ${descr_string}")
	message("LICENSE: ${${package}_LICENSE}")
	message("DATES: ${${package}_YEARS}")
	message("REPOSITORY: ${${package}_ADDRESS}")
	load_Package_Binary_References(REFERENCES_OK ${package})
	if(${package}_FRAMEWORK)
		message("FRAMEWORK: ${${package}_FRAMEWORK} (${${${package}_FRAMEWORK}_SITE})")
		message("DOCUMENTATION: ${${${package}_FRAMEWORK}_SITE}/packages/${package}")
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
	get_Available_Versions(LIST_OF_VERSIONS ${package})
	if(LIST_OF_VERSIONS)
		fill_String_From_List(RES_STR  LIST_OF_VERSIONS " ")
		message("AVAILABLE VERSIONS: ${RES_STR}")
	else()
		message("AVAILABLE VERSIONS: NONE")
	endif()
	if(REFERENCES_OK)
		message("BINARY VERSIONS:")
		print_Package_Binaries(${package})
	else()
		message("BINARY VERSIONS: NONE")
	endif()
endfunction(print_Native_Package_Info)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Available_Versions| replace:: ``get_Available_Versions``
#  .. get_Available_Versions:
#
#  get_Available_Versions
#  ----------------------
#
#   .. command:: get_Available_Versions(LIST_OF_VERSIONS package)
#
#   return the list of available version for a given package.
#
#      :package: the name of the external package.
#
#      :LIST_OF_VERSIONS: the output variable containing the list of versions for package.
#
function(get_Available_Versions LIST_OF_VERSIONS package)
	set(DO_NOT_FIND_${package} TRUE)
	include_Find_File(${package})#just include the find file to get information about compatible versions, do not "find for real" in install tree
	unset(DO_NOT_FIND_${package})
	set(all_known_versions ${${package}_PID_KNOWN_VERSION})
	if(all_known_versions)
		list(REMOVE_ITEM all_known_versions 0.0.0)
	endif()
	sort_Version_List(all_known_versions)
	set(${LIST_OF_VERSIONS} ${all_known_versions} PARENT_SCOPE)
endfunction(get_Available_Versions)

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
	fill_String_From_List(descr_string ${package}_DESCRIPTION " ")
	message("DESCRIPTION: ${descr_string}")
	message("OFFICIAL PROJECT LICENSES: ${${package}_ORIGINAL_PROJECT_LICENSES}")
	print_External_Package_Contact(${package})
	message("OFFICIAL PROJECT AUTHORS: ${${package}_ORIGINAL_PROJECT_AUTHORS}")
	if(${package}_CATEGORIES)
		message("CATEGORIES:")
		foreach(category IN LISTS ${package}_CATEGORIES)
			message("	${category}")
		endforeach()
	endif()
	get_Available_Versions(LIST_OF_VERSIONS ${package})
	if(LIST_OF_VERSIONS)
		fill_String_From_List(RES_STR  LIST_OF_VERSIONS " ")
		message("AVAILABLE VERSIONS: ${RES_STR}")
	else()
		message("AVAILABLE VERSIONS: NONE")
	endif()
	load_Package_Binary_References(REFERENCES_OK ${package})
	if(REFERENCES_OK)
		message("BINARY VERSIONS:")
		print_Package_Binaries(${package})
	else()
		message("BINARY VERSIONS: NONE")
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
	fill_String_From_List(AUTHOR_STRING ${package}_MAIN_AUTHOR " ")
	fill_String_From_List(INSTITUTION_STRING ${package}_MAIN_INSTITUTION " ")
	if(NOT INSTITUTION_STRING STREQUAL "")
		if(${package}_CONTACT_MAIL)
			message("PID PACKAGE CONTACT: ${AUTHOR_STRING} (${${package}_CONTACT_MAIL}) - ${INSTITUTION_STRING}")
		else()
			message("PID PACKAGE CONTACT: ${AUTHOR_STRING} - ${INSTITUTION_STRING}")
		endif()
	else()
		if(${package}_CONTACT_MAIL)
			message("PID PACKAGE CONTACT: ${AUTHOR_STRING} (${${package}_CONTACT_MAIL})")
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
			print_Platform_Compatible_Binary(${package} ${platform} ${version})
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
#      :platform: the identifier of the platform.
#      :version: the version of the binary package.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        The reference file of the given package must be loaded before this call. No automatic automatic (re)load id performed to improve performance.
#
function(print_Platform_Compatible_Binary package platform version)
	set(printed_string "		${platform}:")
	#1) testing if binary can be installed
	check_Package_Platform_Against_Current(BINARY_OK ${package} ${platform} ${version})
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
	fill_String_From_List(descr_string ${framework}_DESCRIPTION " ")
	message("DESCRIPTION: ${descr_string}")
	message("WEB SITE: ${${framework}_SITE}")
	message("LICENSE: ${${framework}_LICENSE}")
	message("DATES: ${${framework}_YEARS}")
	message("REPOSITORY: ${${framework}_ADDRESS}")
	print_Package_Contact(${framework})
	message("AUTHORS:")
	foreach(author IN LISTS ${framework}_AUTHORS_AND_INSTITUTIONS)
		print_Author(${author})
	endforeach()
	if(${framework}_CATEGORIES)
		message("CATEGORIES:")
		foreach(category IN LISTS ${framework}_CATEGORIES)
			message("	${category}")
		endforeach()
	endif()
endfunction(print_Framework_Info)


#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Environment_Info| replace:: ``print_Environment_Info``
#  .. _print_Environment_Info:
#
#  print_Environment_Info
#  ----------------------
#
#   .. command:: print_Environment_Info(env)
#
#   Print brief description of an environment.
#
#      :env: the name of the environment.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        The reference file of the given environment must be loaded before this call. No automatic automatic (re)load id performed to improve performance.
#
function(print_Environment_Info env)
	message("ENVIRONMENT: ${env}")
	fill_String_From_List(descr_string ${env}_DESCRIPTION " ")
	message("DESCRIPTION: ${descr_string}")
	message("LICENSE: ${${env}_LICENSE}")
	message("DATES: ${${env}_YEARS}")
	message("REPOSITORY: ${${env}_ADDRESS}")
	print_Package_Contact(${env})
	message("AUTHORS:")
	foreach(author IN LISTS ${env}_AUTHORS_AND_INSTITUTIONS)
		print_Author(${author})
	endforeach()
	if(EXISTS ${WORKSPACE_DIR}/environments/${env})#the environment exists in workspace
		set(environment_build_folder ${WORKSPACE_DIR}/environments/${env}/build)

		execute_process(COMMAND ${CMAKE_COMMAND} -DGENERATE_INPUTS_DESCRIPTION=TRUE ..
		WORKING_DIRECTORY ${environment_build_folder} OUTPUT_QUIET ERROR_QUIET)

		if(NOT EXISTS ${environment_build_folder}/PID_Inputs.cmake)
		  return()
		endif()
		include(${environment_build_folder}/PID_Inputs.cmake)
		set(list_of_defs)
		if(${env}_INPUTS)
			message("CONSTRAINTS:")
			foreach(var IN LISTS ${env}_INPUTS)
				message(" - ${var}")
			endforeach()
		endif()
	endif()
endfunction(print_Environment_Info)

################################################################################
#################### Deployment units lifecycle management #####################
################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_PID_Environment| replace:: ``create_PID_Environment``
#  .. _create_PID_Environment:
#
#  create_PID_Environment
#  ----------------------
#
#   .. command:: create_PID_Environment(environment author institution  email license)
#
#   Create a environment project into workspace.
#
#      :environment: the name of the environment to create.
#      :author: the name of the environment's author.
#      :institution: the institution of the environment's author.
#      :email: the email of the author.
#      :license: the name of license applying to the environment.
#
function(create_PID_Environment environment author institution email license)
	#copying the pattern folder into the package folder and renaming it
	execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/cmake/patterns/environments/environment ${WORKSPACE_DIR}/environments/${environment}
									WORKING_DIRECTORY ${WORKSPACE_DIR}/build
									OUTPUT_QUIET ERROR_QUIET)

	#setting variables
	set(ENVIRONMENT_NAME ${environment})
	if(author)
		set(ENVIRONMENT_AUTHOR "${author}")
	else()
		if(CMAKE_HOST_WIN32)
			set(ENVIRONMENT_AUTHOR "$ENV{USERNAME}")
		else()
			set(ENVIRONMENT_AUTHOR "$ENV{USER}")
		endif()
	endif()
	if(institution)
		set(ENVIRONMENT_AUTHOR "${ENVIRONMENT_AUTHOR}\n    INSTITUTION        ${institution}")
	endif()
	if(email)
		set(ENVIRONMENT_AUTHOR "${ENVIRONMENT_AUTHOR}\n    EMAIL              ${email}")
	endif()
	if(license)
		set(ENVIRONMENT_CONTENT_META "${license}")
	else()
		message("[PID] WARNING: no license defined so using the default CeCILL license.")
		set(ENVIRONMENT_CONTENT_META "CeCILL")#default license is CeCILL
	endif()
	set(ENVIRONMENT_DESCRIPTION "\"TODO: input a short description of environment ${environment} utility here\"")
	string(TIMESTAMP date "%Y")
	set(ENVIRONMENT_YEARS ${date})
	# generating the root CMakeLists.txt of the package
	configure_file(${WORKSPACE_DIR}/cmake/patterns/environments/CMakeLists.txt.in ${WORKSPACE_DIR}/environments/${environment}/CMakeLists.txt @ONLY)
	#configuring git repository
	init_Environment_Repository(${environment})
	#configuring project now
	execute_process(COMMAND ${CMAKE_COMMAND} -S ${WORKSPACE_DIR}/environments/${environment} -B ${WORKSPACE_DIR}/environments/${environment}/build
									WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment}/build)
endfunction(create_PID_Environment)

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
#   .. command:: create_PID_Wrapper(wrapper author institution email license)
#
#   Create a wrapper project into workspace.
#
#      :wrapper: the name of the wrapper to create.
#      :author: the name of the wrapper's author.
#      :institution: the institution of the wrapper's author.
#      :email: the email of the author.
#      :license: the name of license applying to the wrapper.
#
function(create_PID_Wrapper wrapper author institution email license)
#copying the pattern folder into the package folder and renaming it
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/cmake/patterns/wrappers/package ${WORKSPACE_DIR}/wrappers/${wrapper}
								WORKING_DIRECTORY ${WORKSPACE_DIR}/build
								OUTPUT_QUIET ERROR_QUIET)

#setting variables
set(WRAPPER_NAME ${wrapper})
if(author)
	set(WRAPPER_AUTHOR "${author}")
else()
	if(CMAKE_HOST_WIN32)
		set(WRAPPER_AUTHOR "$ENV{USERNAME}")
	else()
		set(WRAPPER_AUTHOR "$ENV{USER}")
	endif()
endif()
if(institution)
	set(WRAPPER_AUTHOR "${WRAPPER_AUTHOR}\n    INSTITUTION        ${institution}")
endif()
if(email)
	set(WRAPPER_AUTHOR "${WRAPPER_AUTHOR}\n    EMAIL              ${email}")
endif()
if(license)
	set(WRAPPER_CONTENT_META "${license}")
else()
	message("[PID] WARNING: no license defined so using the default CeCILL license.")
	set(WRAPPER_CONTENT_META "CeCILL")#default license is CeCILL
endif()
set(WRAPPER_DESCRIPTION "TODO: input a short description of wrapper ${wrapper} utility here")
string(TIMESTAMP date "%Y")
set(WRAPPER_YEARS ${date})
# generating the root CMakeLists.txt of the package
configure_file(${WORKSPACE_DIR}/cmake/patterns/wrappers/CMakeLists.txt.in ${WORKSPACE_DIR}/wrappers/${wrapper}/CMakeLists.txt @ONLY)
#configuring git repository
init_Wrapper_Repository(${wrapper})
#configuring project now
execute_process(COMMAND ${CMAKE_COMMAND} -S ${WORKSPACE_DIR}/wrappers/${wrapper} -B ${WORKSPACE_DIR}/wrappers/${wrapper}/build
								WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper}/build)
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
#   .. command:: create_PID_Framework(framework author institution email license site)
#
#   Create a framework project into workspace.
#
#      :framework: the name of the framework to create.
#      :author: the name of the framework's author.
#      :institution: the institution of the framework's author.
#      :email: the email of the author.
#      :license: the name of license applying to the framework.
#      :site: the URL of the static site generated by the framework.
#
function(create_PID_Framework framework author institution email license site)
#copying the pattern folder into the package folder and renaming it
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/cmake/patterns/frameworks/framework ${WORKSPACE_DIR}/sites/frameworks/${framework}
								WORKING_DIRECTORY ${WORKSPACE_DIR}/build
								OUTPUT_QUIET ERROR_QUIET)

#setting variables
set(FRAMEWORK_NAME ${framework})
if(author)
	set(FRAMEWORK_AUTHOR "${author}")
else()
	if(CMAKE_HOST_WIN32)
		set(FRAMEWORK_AUTHOR "$ENV{USERNAME}")
	else()
		set(FRAMEWORK_AUTHOR "$ENV{USER}")
	endif()
endif()
if(institution)
	set(FRAMEWORK_AUTHOR "${FRAMEWORK_AUTHOR}\n    INSTITUTION        ${institution}")
endif()
if(email)
	set(FRAMEWORK_AUTHOR "${FRAMEWORK_AUTHOR}\n    EMAIL              ${email}")
endif()
if(license)
	set(FRAMEWORK_CONTENT_META "${license}")
else()
	message("[PID] WARNING: no license defined so using the default CeCILL license.")
	set(FRAMEWORK_CONTENT_META "CeCILL")#default license is CeCILL
endif()
if(site)
	set(FRAMEWORK_CONTENT_META "${FRAMEWORK_CONTENT_META}\n    SITE               ${site}")
endif()
set(FRAMEWORK_DESCRIPTION "\"TODO: input a short description of framework ${framework} utility here\"")
string(TIMESTAMP date "%Y")
set(FRAMEWORK_YEARS ${date})
# generating the root CMakeLists.txt of the package
configure_file(${WORKSPACE_DIR}/cmake/patterns/frameworks/CMakeLists.txt.in ${WORKSPACE_DIR}/sites/frameworks/${framework}/CMakeLists.txt @ONLY)
#configuring git repository
init_Framework_Repository(${framework})
#configuring project now
execute_process(COMMAND ${CMAKE_COMMAND} -S ${WORKSPACE_DIR}/sites/frameworks/${framework}
								WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
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
#   .. command:: create_PID_Package(package author institution email license code_style)
#
#   Create a native package project into workspace.
#
#      :package: the name of the package to create.
#      :author: the name of the package's author.
#      :institution: the institution of the package's author.
#      :email: the email of the author.
#      :license: the name of license applying to the package.
#      :code_style: the name of code_style.
#
function(create_PID_Package package author institution email license code_style)
#copying the pattern folder into the package folder and renaming it
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/cmake/patterns/packages/package ${WORKSPACE_DIR}/packages/${package}
								WORKING_DIRECTORY ${WORKSPACE_DIR}/build
								OUTPUT_QUIET ERROR_QUIET)

#setting variables
set(PACKAGE_NAME ${package})
if(author)
	set(PACKAGE_AUTHOR "${author}")
else()
	if(CMAKE_HOST_WIN32)
		set(PACKAGE_AUTHOR "$ENV{USERNAME}")
	else()
		set(PACKAGE_AUTHOR "$ENV{USER}")
	endif()
endif()
if(institution)
	set(PACKAGE_AUTHOR "${PACKAGE_AUTHOR}\n    INSTITUTION        ${institution}")
endif()
if(email)
	set(PACKAGE_AUTHOR "${PACKAGE_AUTHOR}\n    EMAIL              ${email}")
endif()
if(license)
	set(PACKAGE_CONTENT_META "${license}")
else()
	message("[PID] WARNING: no license defined so using the default CeCILL license.")
	set(PACKAGE_CONTENT_META "CeCILL")#default license is CeCILL
endif()
if(code_style)
	set(PACKAGE_CONTENT_META "${PACKAGE_CONTENT_META}\n    CODE_STYLE         ${code_style}")
endif()
set(PACKAGE_DESCRIPTION "TODO: input a short description of package ${package} utility here")
string(TIMESTAMP date "%Y")
set(PACKAGE_YEARS ${date})
# generating the root CMakeLists.txt of the package
configure_file(${WORKSPACE_DIR}/cmake/patterns/packages/CMakeLists.txt.in ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt @ONLY)
#confuguring git repository
init_Repository(${package})
#configuring project now
execute_process(COMMAND ${CMAKE_COMMAND} -S ${WORKSPACE_DIR}/packages/${package} -B ${WORKSPACE_DIR}/packages/${package}/build
								WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build)
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
#      :verbose: if TRUE the deployment will print more information to standard output.
#
function(deploy_PID_Framework framework verbose)
set(PROJECT_NAME ${framework})
if(verbose)
	set(ADDITIONAL_DEBUG_INFO ON)
else()
	set(ADDITIONAL_DEBUG_INFO OFF)
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
#  .. |deploy_PID_Environment| replace:: ``deploy_PID_Environment``
#  .. _deploy_PID_Environment:
#
#  deploy_PID_Environment
#  ----------------------
#
#   .. command:: deploy_PID_Environment(environment verbose)
#
#   Deploy a environment into workspace. Result in installing an existing environment repository in the workspace filesystem.
#
#      :environment: the name of the environment to deploy.
#      :verbose: if TRUE the deployment will print more information to standard output.
#
function(deploy_PID_Environment environment verbose)
set(PROJECT_NAME ${environment})
if(verbose)
	set(ADDITIONAL_DEBUG_INFO ON)
else()
	set(ADDITIONAL_DEBUG_INFO OFF)
endif()
	deploy_Environment_Repository(DEPLOYED ${environment})
	if(DEPLOYED)
		message("[PID] INFO : environment ${environment} has been deployed.")
	else()
		message("[PID] ERROR : cannot deploy ${environment} repository.")
	endif()
endfunction(deploy_PID_Environment)

#.rst:
#
# .. ifmode:: internal
#
#  .. |bind_Installed_Package| replace:: ``bind_Installed_Package``
#  .. _bind_Installed_Package:
#
#  bind_Installed_Package
#  -----------------------
#
#   .. command:: bind_Installed_Package(DEPLOYED package version release_only)
#
#   Binding an installed package by resolving its runtime symlinks.
#
#      :platform: the platform for which the target package has been built for.
#      :package: the name of the package to bind.
#      :version: the version to bind
#      :release_only: if TRUE only resolve release binaries
#
#      :BOUND: the output variable that is true of binding process succeede, FALSE otherwise
#
function(bind_Installed_Package BOUND platform package version release_only)
	set(${BOUND} FALSE PARENT_SCOPE)
	set(BIN_PACKAGE_PATH ${WORKSPACE_DIR}/install/${platform}/${package}/${version})
	get_Package_Type(${package} PACK_TYPE)
	if(PACK_TYPE STREQUAL "EXTERNAL")
		if(NOT EXISTS ${BIN_PACKAGE_PATH}/share/Use${package}-${version}.cmake)
			if(ADDITIONAL_DEBUG_INFO)
				message("[PID] WARNING : when resolving runtime dependencies, the binary package ${package} (version ${version}) has no description.")
			endif()
			return()
		endif()
		#getting full external packages description
		if(NOT release_only)
			#include and resolve the use file in debug mode
			set(CMAKE_BUILD_TYPE Debug)
			set(${package}_FOUND_Debug TRUE CACHE INTERNAL "")
			include(${BIN_PACKAGE_PATH}/share/Use${package}-${version}.cmake)
		endif()
		#now resolve the use file in release mode
		set(CMAKE_BUILD_TYPE Release)
		set(${package}_FOUND TRUE CACHE INTERNAL "")
		include(${BIN_PACKAGE_PATH}/share/Use${package}-${version}.cmake)
	else()
		#testing and getting full native packages description in one call
		include(${BIN_PACKAGE_PATH}/share/Use${package}-${version}.cmake OPTIONAL RESULT_VARIABLE res)
		#using the generated Use<package>-<version>.cmake file to get adequate version information about components
		if(	res STREQUAL NOTFOUND)
			message("[PID] ERROR : when resolving runtime dependencies, the binary package ${package} (version ${version}) description cannot be found from the workspace path : ${WORKSPACE_DIR}")
			return()
		elseif(NOT DEFINED ${package}_COMPONENTS)#if there is no component defined for the package there is an error
			message("[PID] ERROR : when resolving runtime dependencies, the binary package ${package} (version ${version}) has no component defined, this denote a bad state for this package.")
			return()
		endif()
	endif()

	##################################################################
	############### resolving all runtime dependencies ###############
	##################################################################

	#set the variable to be able to use Package Internal API
	set(${package}_ROOT_DIR ${BIN_PACKAGE_PATH} CACHE INTERNAL "")
	set(${package}_VERSION_STRING ${version} CACHE INTERNAL "")
	set(PROJECT_NAME workspace)
	if(NOT release_only)
		set(CMAKE_BUILD_TYPE Debug)#to adequately interpret external packages description
		set(${package}_FOUND_DEBUG TRUE CACHE INTERNAL "")
		resolve_Package_Dependencies(${package} Debug TRUE FALSE) # finding all package dependencies
		resolve_Package_Runtime_Dependencies(${package} Debug) # then resolving runtime resources to symlink
		clear_Managed_Packages_For_Runtime_Dependencies(${CMAKE_BUILD_TYPE})
	endif()
	set(CMAKE_BUILD_TYPE Release)#to adequately interpret external packages description
	set(${package}_FOUND TRUE CACHE INTERNAL "")
	resolve_Package_Dependencies(${package} Release TRUE "${release_only}") # finding all package dependencies
	resolve_Package_Runtime_Dependencies(${package} Release) # then resolving runtime resources to symlink

	clear_Managed_Packages_For_Runtime_Dependencies(${CMAKE_BUILD_TYPE})
	set(${BOUND} TRUE PARENT_SCOPE)
endfunction(bind_Installed_Package)

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
#   .. command:: deploy_PID_Native_Package(DEPLOYED package version
#								                            verbose deploy_mode branch run_tests release_only)
#
#   Deploy a native package into workspace. Finally results in installing an existing package version in the workspace install tree.
#
#      :package: the name of the package to deploy.
#      :version: the version to deploy.
#      :verbose: if TRUE the deployment will print more information to standard output.
#      :deploy_mode: use BINARY, SOURCE or ANY.
#      :branch: define the branch to build (may be left empty).
#      :run_tests: if TRUE built project will run tests.
#      :release_only: if TRUE project only generates release binaries
#
#      :DEPLOYED: output variable that is set to SOURCE or BINARY depending on the nature of the deployed package, empty if package has not been deployed.
#
function(deploy_PID_Native_Package DEPLOYED package version verbose deploy_mode branch run_tests release_only)
set(PROJECT_NAME ${package})
if(verbose)
	set(ADDITIONAL_DEBUG_INFO ON)
else()
	set(ADDITIONAL_DEBUG_INFO OFF)
endif()
set(${DEPLOYED} PARENT_SCOPE)

memorize_Binary_References(REFERENCES_FOUND ${package})
if(NOT REFERENCES_FOUND AND deploy_mode STREQUAL "BINARY")
	return()
endif()
set(REPOSITORY_IN_WORKSPACE FALSE)
if(EXISTS ${WORKSPACE_DIR}/packages/${package})
	set(REPOSITORY_IN_WORKSPACE TRUE)
endif()

if(NOT version)#no specific version required
	set(INSTALLED FALSE)
	if(NOT deploy_mode STREQUAL "BINARY")#this first step is only possible if sources can be used
		if(NOT REPOSITORY_IN_WORKSPACE)
			deploy_Package_Repository(REPOSITORY_DEPLOYED ${package})
			if(NOT REPOSITORY_DEPLOYED)
				message("[PID] ERROR : cannot deploy ${package} repository. Abort deployment !")
				return()
			endif()
		endif()
		#now build the package
		if(branch)#deploying a specific branch
			deploy_Source_Native_Package_From_Branch(INSTALLED ${package} ${branch} "${run_tests}" "${release_only}")
			go_To_Commit(${WORKSPACE_DIR}/packages/${package} ${branch})#finally checkout the repository state to the target branch
			if(NOT INSTALLED)
				message("[PID] ERROR : cannot build ${package} after cloning its repository. Abort deployment !")
				return()
			endif()
		else()
			deploy_Source_Native_Package(INSTALLED ${package} "" "${run_tests}" "${release_only}")
		endif()
	endif()
	if(NOT INSTALLED)# deployment from sources was not possible
		#try to install last available version from sources
		if(NOT deploy_mode STREQUAL "SOURCE")#only possile if binaries can be used
			set(RES_VERSION)
			greatest_Version_Archive(${package} RES_VERSION)
			if(RES_VERSION)
				deploy_Binary_Native_Package_Version(BIN_DEPLOYED ${package} ${RES_VERSION} TRUE "" "${release_only}")
				if(NOT BIN_DEPLOYED)
					message("[PID] ERROR : problem deploying ${package} binary archive version ${RES_VERSION}. Deployment aborted !")
					#if source deployment was possible then it would already have heppended in this situation
					#so no more to do -> there is no solution
					return()
				endif()
				bind_Installed_Package(BOUND ${CURRENT_PLATFORM} ${package} ${RES_VERSION} "${release_only}")
				if(BOUND)
					message("[PID] INFO : deploying ${package} binary archive version ${RES_VERSION} success !")
					set(${DEPLOYED} "BINARY" PARENT_SCOPE)
				else()
					message("[PID] ERROR : package ${package} version ${RES_VERSION} cannot be deployed in workspace.")
				endif()
				return()
			else()
				message("[PID] ERROR : no binary archive available for ${package}. Deployment aborted !")
				return()
			endif()
		endif()
	else()
		set(${DEPLOYED} "SOURCE" PARENT_SCOPE)
	endif()
else()#deploying a specific version
	if(NOT deploy_mode STREQUAL "SOURCE")#only possible if binaries can be used
		#first, try to download the archive if the binary archive for this version exists
		exact_Version_Archive_Exists(${package} "${version}" ARCHIVE_EXISTS)
		if(ARCHIVE_EXISTS)#download the binary directly if an archive exists for this version
			deploy_Binary_Native_Package_Version(BIN_DEPLOYED ${package} ${version} TRUE "" "${release_only}")
			if(NOT BIN_DEPLOYED)
				message("[PID] WARNING : problem deploying ${package} binary archive version ${version}. This may be due to binary compatibility problems. Try building from sources...")
			else()
				bind_Installed_Package(BOUND ${CURRENT_PLATFORM} ${package} ${version} "${release_only}")
				if(BOUND)
					message("[PID] INFO : deploying ${package} binary archive version ${version} success !")
					set(${DEPLOYED} "BINARY" PARENT_SCOPE)
				else()
					message("[PID] ERROR : cannot deploy native package ${package} version ${version}.")
				endif()
				return()
			endif()
		endif()
	endif()
	#OK so try from sources (either no binary archive exists or deployment faced a problem - probably binary compatibility problem)
	if(NOT deploy_mode STREQUAL "BINARY")#this first step is only possible if sources can be used
		if(NOT REPOSITORY_IN_WORKSPACE)
			deploy_Package_Repository(REPOSITORY_DEPLOYED ${package})
			if(NOT REPOSITORY_DEPLOYED)
				message("[PID] ERROR : cannot clone ${package} repository. Deployment aborted !")
				return()
			endif()
		endif()
		deploy_Source_Native_Package_Version(SOURCE_DEPLOYED ${package} ${version} TRUE "" "${run_tests}" "${release_only}")
		if(SOURCE_DEPLOYED)
				message("[PID] INFO : package ${package} has been deployed from its repository.")
				set(${DEPLOYED} "SOURCE" PARENT_SCOPE)
		else()
			message("[PID] ERROR : cannot build ${package} from its repository. Deployment aborted !")
		endif()
	else()
		message("[PID] ERROR : cannot install ${package} since source deployment is not allowed. Deployment aborted !")
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
#   .. command:: deploy_PID_External_Package(DEPLOYED package version verbose deploy_mode redeploy release_only)
#
#   Deploy an external package into workspace. Finally results in installing an existing external package version in the workspace install tree.
#
#      :package: the name of the external package to deploy.
#      :version: the version to deploy (if system is used then deploy the corresponding OS version)
#      :verbose: if TRUE the deployment will print more information to standard output.
#      :deploy_mode: use SOURCE, BINARY or ANY.
#      :redeploy: if TRUE the external package version is redeployed even if it was existing before.
#      :release_only: if TRUE only release version will be deployed.
#
#      :DEPLOYED: output variable that is set to SOURCE or BINARY depending on the nature of the deployed package, empty if package has not been deployed.
#
function(deploy_PID_External_Package DEPLOYED package version verbose deploy_mode redeploy release_only)
if(verbose)
	set(ADDITIONAL_DEBUG_INFO ON)
else()
	set(ADDITIONAL_DEBUG_INFO OFF)
endif()
set(${DEPLOYED} PARENT_SCOPE)
memorize_Binary_References(REFERENCES_FOUND ${package})
if(NOT REFERENCES_FOUND AND deploy_mode STREQUAL "BINARY")
	return()
endif()
set(PROJECT_NAME ${package})
#check if the repository of the external package wrapper lies in the workspace
set(REPOSITORY_IN_WORKSPACE FALSE)
if(EXISTS ${WORKSPACE_DIR}/wrappers/${package})
	set(REPOSITORY_IN_WORKSPACE TRUE)
endif()
set(MAX_CURR_VERSION 0.0.0)
if(NOT version)#deploying the latest version of the package
	if(NOT deploy_mode STREQUAL "SOURCE")
		#first try to directly download its archive
		get_Available_Binary_Package_Versions(${package} available_versions available_with_platform)
		if(available_versions)
			foreach(version_i IN LISTS available_versions)
				if(version_i VERSION_GREATER MAX_CURR_VERSION)
					set(MAX_CURR_VERSION ${version_i})
				endif()
			endforeach()
			if(NOT MAX_CURR_VERSION STREQUAL 0.0.0)
				if(EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${MAX_CURR_VERSION})
					if(NOT redeploy)
						message("[PID] INFO : external package ${package} version ${MAX_CURR_VERSION} already lies in the workspace, use force=true to force the redeployment.")
						return()
					endif()
					#remove existing install folder
					file(REMOVE_RECURSE ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${MAX_CURR_VERSION})
				endif()
				deploy_Binary_External_Package_Version(BIN_DEPLOYED ${package} ${MAX_CURR_VERSION} FALSE "${release_only}")
				if(NOT BIN_DEPLOYED)#an error occurred during deployment !! => Not a normal situation
					message("[PID] ERROR : cannot deploy ${package} binary archive version ${MAX_CURR_VERSION}. This is certainy due to a bad, missing or unaccessible archive or due to no archive exists for current platform and build constraints. Please contact the administrator of the package ${package}.")
					return()
				else()
					bind_Installed_Package(BOUND ${CURRENT_PLATFORM} ${package} ${MAX_CURR_VERSION} "${release_only}")
					if(BOUND)
						message("[PID] INFO : deploying ${package} binary archive version ${MAX_CURR_VERSION} success !")
						set(${DEPLOYED} "BINARY" PARENT_SCOPE)
					else()
						message("[PID] ERROR : external package ${package} version ${MAX_CURR_VERSION} cannot be deployed in workspace.")
					endif()
					message("[PID] INFO : external package ${package} version ${MAX_CURR_VERSION} has been deployed from its binary archive.")
					return()
				endif()
			else()#there may be no binary version available for the target OS => not an error
				if(ADDITIONAL_DEBUG_INFO)
					message("[PID] ERROR : no known binary version of external package ${package} for OS ${OS_STRING}.")
				endif()
			endif()
		endif()
	endif()
	#second option: build it from sources
	if(NOT deploy_mode STREQUAL "BINARY")#this step is only possible if sources can be used
		if(NOT REPOSITORY_IN_WORKSPACE)
			deploy_Wrapper_Repository(SOURCE_DEPLOYED ${package})
			if(NOT SOURCE_DEPLOYED)
				message("[PID] ERROR : cannot clone external package ${package} wrapper repository. Deployment aborted !")
				return()
			endif()
		endif()
		set(list_of_installed_versions)
		if(NOT redeploy #only exlcude the installed versions if redeploy is not required
		AND EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/)
			list_Version_Subdirectories(RES_VERSIONS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package})
			set(list_of_installed_versions ${RES_VERSIONS})
		endif()
		deploy_Source_External_Package(SOURCE_DEPLOYED ${package} "${list_of_installed_versions}" "${release_only}")
		if(SOURCE_DEPLOYED)
				message("[PID] INFO : external package ${package} has been deployed from its wrapper repository.")
				set(${DEPLOYED} "SOURCE" PARENT_SCOPE)
		else()
			message("[PID] ERROR : cannot build external package ${package} from its wrapper repository. Deployment aborted !")
		endif()
	else()
		message("[PID] ERROR : cannot install external package ${package} since source deployment is not allowed. Deployment aborted !")
	endif()

else()#deploying a specific version of the external package
	if(NOT version STREQUAL "SYSTEM")
		if(NOT deploy_mode STREQUAL "SOURCE")#not possible if source deployment is forced
			#first, try to download the archive if the binary archive for this version exists
			exact_Version_Archive_Exists(${package} "${version}" ARCHIVE_EXISTS)
			if(ARCHIVE_EXISTS)#download the binary directly if an archive exists for this version
				deploy_Binary_External_Package_Version(BIN_DEPLOYED ${package} ${version} FALSE "${release_only}")#deploying the target binary relocatable archive
				if(NOT BIN_DEPLOYED)
					message("[PID] ERROR : problem deploying ${package} binary archive version ${version}. Deployment aborted !")
					return()
				else()
					bind_Installed_Package(BOUND ${CURRENT_PLATFORM} ${package} ${version} "${release_only}")
					if(BOUND)
						message("[PID] INFO : deploying ${package} binary archive version ${version} success !")
						set(${DEPLOYED} "BINARY" PARENT_SCOPE)
					else()
						message("[PID] ERROR : external package ${package} version ${version} cannot be deployed in workspace.")
					endif()
					message("[PID] INFO : external package ${package} version ${version} has been deployed from its binary archive.")
					return()
				endif()
			endif()
		endif()
	endif()
	#Not possible from binaries so try from sources
	if(NOT deploy_mode STREQUAL "BINARY")#this step is only possible if sources can be used
		if(NOT REPOSITORY_IN_WORKSPACE)
			deploy_Wrapper_Repository(SOURCE_DEPLOYED ${package})
			if(NOT SOURCE_DEPLOYED)
				message("[PID] ERROR : cannot clone external package ${package} wrapper repository. Deployment aborted !")
				return()
			endif()
		endif()
		if(version STREQUAL "SYSTEM")
			#need to determine the OS installed version first
			check_Platform_Configuration(RESULT_OK CONFIG_NAME CONSTRAINTS workspace "${package}" Release)#use the configuration to determine if a version is installed on OS
			if(NOT RESULT_OK)
				message("[PID] ERROR : cannot deploy external package ${package} OS version since no OS version of ${package} can be found in system. Deployment aborted !")
				return()
			endif()
			set(USE_SYSTEM TRUE)
			set(version ${workspace_${package}_VERSION})#use the OS version detected (${package}_VERSION is a standardized variable for configuration) !!
		else()
			set(USE_SYSTEM FALSE)
		endif()
		if(version)#a given version must be installed
			deploy_Source_External_Package_Version(BIN_DEPLOYED ${package} ${version} TRUE ${USE_SYSTEM} "" ${release_only})
			if(BIN_DEPLOYED)
					message("[PID] INFO : external package ${package} has been deployed from its wrapper repository.")
					set(${DEPLOYED} "SOURCE" PARENT_SCOPE)
			else()
				message("[PID] ERROR : cannot build external package ${package} from its wrapper repository. Deployment aborted !")
			endif()
		else()
			message("[PID] INFO : external package ${package} OS configuration has been deployed.")
			set(${DEPLOYED} "SYSTEM" PARENT_SCOPE)
		endif()
	else()
		message("[PID] ERROR : cannot install external package ${package} since source deployment not allowed. Deployment aborted !")
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
#      :git_url: the url of the official remote used for that wrapper.
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
#  .. |connect_PID_Environment| replace:: ``connect_PID_Environment``
#  .. _connect_PID_Environment:
#
#  connect_PID_Environment
#  -----------------------
#
#   .. command:: connect_PID_Environment(environment git_url first_time)
#
#    Configuring the official remote repository of the given environment.
#
#      :environment: the name of the environment.
#      :git_url: the url of the official remote used for that environment.
#      :first_time: if FALSE a reconnection of official repository will take place.
#
function(connect_PID_Environment environment git_url first_time)
if(first_time)#first time this environment is connected because newly created
	# set the address of the official repository in the CMakeLists.txt of the environment
	set_Environment_Repository_Address(${environment} ${git_url})
	register_Environment_Repository_Address(${environment})
	# synchronizing with the "official" remote git repository
	connect_Environment_Repository(${environment} ${git_url})
else() #forced reconnection
	# updating the address of the official repository in the CMakeLists.txt of the package
	reset_Environment_Repository_Address(${environment} ${git_url})
	register_Environment_Repository_Address(${environment})
	# synchronizing with the new "official" remote git repository
	reconnect_Environment_Repository(${environment} ${git_url})
endif()
endfunction(connect_PID_Environment)

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
#      :git_url: the url of the official remote used for that framework.
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
#      :git_url: the url of the official remote used for that package.
#      :first_time: if FALSE a reconnection of official repository will take place.
#
function(connect_PID_Package package git_url first_time)
save_Repository_Context(INITIAL_COMMIT SAVED_CONTENT ${package} FALSE) # saving local repository state
go_To_Integration(${package})
if(first_time)#first time this package is connected because newly created
	# set the address of the official repository in the CMakeLists.txt of the package
	set_Package_Repository_Address(${package} ${git_url})
	register_Repository_Address(${package})
	# synchronizing with the "official" remote git repository
	connect_Package_Repository(${package} ${git_url})
else() #forced reconnection
	# updating the address of the official repository in the CMakeLists.txt of the package
	reset_Package_Repository_Address(${package} ${git_url})
	register_Repository_Address(${package})
	# synchronizing with the new "official" remote git repository
	reconnect_Repository(${package} ${git_url})
endif()
restore_Repository_Context(${package} FALSE ${INITIAL_COMMIT} ${SAVED_CONTENT}) # restoring local repository state
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
#      :git_url: the url of the origin remote used for that package.
#
function(add_Connection_To_PID_Package package git_url)
save_Repository_Context(INITIAL_COMMIT SAVED_CONTENT ${package} FALSE) # saving local repository state
change_Origin_Repository(${package} ${git_url} origin) # synchronizing with the remote "origin" git repository
restore_Repository_Context(${package} FALSE ${INITIAL_COMMIT} ${SAVED_CONTENT})# restoring local repository state
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
#      :version: the installed version to remove.
#
#      :RESULT: the output variable that is TRUE if package version has been removed, FALSE otherwise.
#
function(clear_PID_Package RESULT package version)
set(${RESULT} TRUE PARENT_SCOPE)
if("${version}" MATCHES "[0-9]+\\.[0-9]+\\.[0-9]+")	#specific version targetted

	if( EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${version}
	AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${version})
		file(REMOVE_RECURSE ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${version})
	else()
		message("[PID] ERROR : package ${package} version ${version} does not resides in workspace install directory.")
		set(${RESULT} FALSE PARENT_SCOPE)
	endif()
elseif(version MATCHES "all")#all versions targetted (including own versions and installers folder)
	if( EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}
	AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package})
		file(REMOVE_RECURSE ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package})
	else()
		message("[PID] ERROR : package ${package} is not installed in workspace.")
		set(${RESULT} FALSE PARENT_SCOPE)
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
#clearing install folder
if(	EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package})
	clear_PID_Package(RES ${package} all)
endif()
#clearing source folder
file(REMOVE_RECURSE ${WORKSPACE_DIR}/packages/${package})
endfunction(remove_PID_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |remove_PID_Wrapper| replace:: ``remove_PID_Wrapper``
#  .. _remove_PID_Wrapper:
#
#  remove_PID_Wrapper
#  ------------------
#
#   .. command:: remove_PID_Wrapper(wrapper)
#
#    Clear the workspace of any trace of the target wrapper (including its source repository).
#
#      :wrapper: the name of the wrapper.
#
function(remove_PID_Wrapper wrapper)
	#clearing install folder
	if(	EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${wrapper})
		clear_PID_Package(RES ${wrapper} all)
	endif()
	#clearing source folder
	file(REMOVE_RECURSE ${WORKSPACE_DIR}/wrappers/${wrapper})
endfunction(remove_PID_Wrapper)

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
file(REMOVE_RECURSE ${WORKSPACE_DIR}/sites/frameworks/${framework})
endfunction(remove_PID_Framework)


#.rst:
#
# .. ifmode:: internal
#
#  .. |remove_PID_Environment| replace:: ``remove_PID_Environment``
#  .. _remove_PID_Environment:
#
#  remove_PID_Environment
#  ----------------------
#
#   .. command:: remove_PID_Environment(environment)
#
#    Remove the repository of a given environment from the workspace.
#
#      :environment: the name of the environment.
#
function(remove_PID_Environment environment)
file(REMOVE_RECURSE ${WORKSPACE_DIR}/environments/${environment})
endfunction(remove_PID_Environment)

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
#   .. command:: register_PID_Package(package space)
#
#     Updating the workspace contributions space(s) with updated (or newly created) reference and find files for a given package.
#
#      :package: the name of the package to register.
#      :space: the name of the contribution space where package will be referenced in addition to all spaces where it is already referenced.
#
function(register_PID_Package package space)
	#force the reconfiguration of the package to be sure possily newly created tags are created
	execute_process(COMMAND ${CMAKE_COMMAND} -S ${WORKSPACE_DIR}/packages/${package}
									WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build)
	execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} installing WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build)
	set(ENV{space} ${space})
	execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} referencing WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build)
	unset(ENV{space})
	#only publish if the package has an address and/or a public address
	include_Package_Reference_File(PATH_TO_FILE ${package})
	if(PATH_TO_FILE AND (${package}_PUBLIC_ADDRESS OR ${package}_ADDRESS))#means included and an address is defined
		publish_Package_References_In_Contribution_Spaces_Repositories(${package})
	endif()
endfunction(register_PID_Package)


#.rst:
#
# .. ifmode:: internal
#
#  .. |unregister_PID_Deployment_Unit| replace:: ``unregister_PID_Deployment_Unit``
#  .. _unregister_PID_Deployment_Unit:
#
#  unregister_PID_Deployment_Unit
#  ------------------------------
#
#   .. command:: unregister_PID_Deployment_Unit(RESULT deployment_unit space)
#
#     Updating the workspace contributions space(s) with removed reference and find files for a given package.
#
#      :deployment_unit: the name of the deployment unit (package, wrapper) to unregister.
#      :space: the space from which the deployment unit will be uregister or all known spaces in workspace if empty.
#      :RESULT: the output variabl that is TRUE if something as been unregistered, FALSE otherwse.
#
function(unregister_PID_Deployment_Unit RESULT deployment_unit space)
	if(space)
		set(list_of_spaces ${space})
	else()
		set(list_of_space ${CONTRIBUTION_SPACES})
	endif()
	set(found FALSE)
	foreach(cs IN LISTS list_of_spaces)
		get_Path_To_Contribution_Space(SOURCE_PATH ${cs})
		get_All_Matching_Contributions(LICENSE REFERENCE FIND FORMAT ${cs} ${deployment_unit})
		if(REFERENCE OR FIND)#manage find and reference "all in one" if required
	    set(removed_files)
			set(type_of_contrib)
			set(found TRUE)
	    if(FIND)
	      file(REMOVE ${SOURCE_PATH}/finds/${FIND})
	      list(APPEND removed_files finds/${FIND})
				set(type_of_contrib "package")#only native and external packages have find files
	    endif()
	    if(REFERENCE)
	      file(REMOVE ${SOURCE_PATH}/references/${REFERENCE})
	      list(APPEND removed_files references/${REFERENCE})
				get_Type_Of_Contribution(type_of_contrib ${REFERENCE})
	    endif()
	    commit_Files(SOURCE_COMMIT_RES ${SOURCE_PATH} "${removed_files}" "removed references for ${type_of_contrib} ${deployment_unit}" FALSE)
	  endif()
	endforeach()
	set(${RESULT} ${found} PARENT_SCOPE)
endfunction(unregister_PID_Deployment_Unit)

#.rst:
#
# .. ifmode:: internal
#
#  .. |register_PID_Wrapper| replace:: ``register_PID_Wrapper``
#  .. _register_PID_Wrapper:
#
#  register_PID_Wrapper
#  --------------------
#
#   .. command:: register_PID_Wrapper(wrapper space)
#
#     Updating the workspace contributions space(s) with updated (or newly created) reference and find files for a given external package wrapper.
#
#      :wrapper: the name of the external package wrapper to register.
#      :space: the name of the contribution space where wrapper will be referenced in addition to all spaces where it is already referenced.
#
function(register_PID_Wrapper wrapper space)
	set(ENV{space} ${space})
	execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} referencing WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper}/build)
	unset(ENV{space})
	#only publish if the wrapper has an address and/or a public address
	include_External_Reference_File(PATH_TO_FILE ${wrapper})
	if(PATH_TO_FILE AND (${wrapper}_PUBLIC_ADDRESS OR ${wrapper}_ADDRESS))#means included and an address is defined
		publish_Wrapper_References_In_Contribution_Spaces_Repositories(${wrapper})
	endif()
endfunction(register_PID_Wrapper)

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
#   .. command:: register_PID_Framework(framework space)
#
#     Updating the workspace repository with an updated (or newly created) reference file for a given framework.
#      :space: the name of the contribution space where framework will be referenced in addition to all spaces where it is already referenced.
#
#      :framework: the name of the framework to register.
#
function(register_PID_Framework framework space)
execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} build WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
set(ENV{space} ${space})
execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} referencing WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}/build)
unset(ENV{space})
#only publish if the package has an address and/or a public address
include_Framework_Reference_File(PATH_TO_FILE ${framework})
if(PATH_TO_FILE AND ${framework}_ADDRESS)#means included and an address is defined
	publish_Framework_References_In_Contribution_Spaces_Repositories(${framework})
endif()
endfunction(register_PID_Framework)

#.rst:
#
# .. ifmode:: internal
#
#  .. |register_PID_Environment| replace:: ``register_PID_Environment``
#  .. _register_PID_Environment:
#
#  register_PID_Environment
#  ------------------------
#
#   .. command:: register_PID_Environment(environment space)
#
#     Updating the workspace repository with an updated (or newly created) reference file for a given environment.
#
#      :environment: the name of the environment to register.
#      :space: the name of the contribution space where environment will be referenced in addition to all spaces where it is already referenced.
#
function(register_PID_Environment environment space)
set(ENV{space} ${space})
execute_process(COMMAND ${CMAKE_MAKE_PROGRAM} referencing WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment}/build)
unset(ENV{space})
#only publish if the package has an address and/or a public address
include_Environment_Reference_File(PATH_TO_FILE ${environment})
if(PATH_TO_FILE AND (${environment}_PUBLIC_ADDRESS OR ${environment}_ADDRESS))#means included and an address is defined
	publish_Environment_References_In_Contribution_Spaces_Repositories(${environment})
endif()
endfunction(register_PID_Environment)

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
#   .. command:: release_PID_Package(RESULT package next manage_deps)
#
#     Release the currently developed package version. This results in marking the currnt version with a git tag.
#
#      :package: the name of the package to release.
#      :next: the next version of the package after current has been released.
#      :manage_deps: if TRUE the release process will also apply to unreleased dependencies of the package.
#
#      :RESULT: the output variable that is TRUE if package has been released, FALSE otherwise.
#
function(release_PID_Package RESULT package next branch manage_deps)
set(${RESULT} FALSE PARENT_SCOPE)
# check that current branc of package is integration
get_Repository_Current_Branch(CURRENT_BRANCH ${WORKSPACE_DIR}/packages/${package})
if(NOT CURRENT_BRANCH)
	message("[PID] ERROR : The repository package ${package} is currenlty detached from a branch. Release aborted.")
	return()
endif()
if(branch)
		if(branch STREQUAL "master" OR branch STREQUAL "integration")
			message("[PID] ERROR : the branch argument is used to specify a non standard branch. Do not use it for branch ${branch}.")
			return()
		endif()
		if(NOT CURRENT_BRANCH STREQUAL branch)
			message("[PID] ERROR : impossible to release package ${package} because it is not currently on branch ${branch}.")
			return()
		endif()
else()#no branch specified => using integration
	if(NOT CURRENT_BRANCH STREQUAL "integration")
		message("[PID] ERROR : impossible to release package ${package} because it is not currently on integration branch.")
		return()
	endif()
endif()

# check for modifications
has_Modifications(HAS_MODIFS ${package} FALSE)
if(HAS_MODIFS)
	message("[PID] ERROR : impossible to release package ${package} because there are modifications to commit or stash.")
	return()
endif() # from here we can navigate between branches freely
list_Ignored_Files(IGNORED_ON_DEV_BRANCH ${WORKSPACE_DIR}/packages/${package})

# udpate the master branch from official remote repository
update_Package_Repository_Versions(UPDATE_OK ${package})
if(NOT UPDATE_OK)
	message("[PID] ERROR : impossible to release package ${package} because its master branch cannot be updated from official one. Maybe you have no clone rights from official or local master branch of package ${package} is not synchronizable with official master branch.")
	go_To_Commit(${WORKSPACE_DIR}/packages/${package} ${CURRENT_BRANCH})#always go back to original branch
	return()
endif() #from here graph of commits and version tags are OK

# here there may have newly untracked files in master that are newly ignored files on dev branch
# these files should be preserved
checkout_From_Master_To_Commit(${WORKSPACE_DIR}/packages/${package} ${CURRENT_BRANCH} IGNORED_ON_DEV_BRANCH)

# registering current version
get_Version_Number_And_Repo_From_Package(${package} DIGITS STRING FORMAT METHOD ADDRESS)
# performing basic checks
if(NOT DIGITS)#version number is not well defined
	message("[PID] ERROR : problem releasing package ${package}, bad version format in its root CMakeLists.txt.")
	return()
elseif(NOT ADDRESS)#there is no connected repository ?
	message("[PID] ERROR : problem releasing package ${package}, no address for official remote repository found in your package description.")
	return()
else()
	test_Remote_Connection(CONNECTED ${WORKSPACE_DIR}/packages/${package} official)
	if(NOT CONNECTED)
		message("[PID] ERROR: problem releasing package ${package}, cannot connect to its official remote. Please check you internet connection.")
		return()
	endif()
endif()

# check that version is not already released on official/master branch
get_Repository_Version_Tags(VERSION_NUMBERS ${package})
if(NOT VERSION_NUMBERS)
	message("[PID] ERROR : malformed package ${package}, no version tag detected in ${package} repository ! This denote a bad state of your repository. Maybe this repository has been cloned by hand wthout pulling its version tags.\n
	1) you can try doing the command `make update` into ${package} project, then try releasing again.\n
  2) you can try solving the problem by yourself. Please go into ${package} repository and enter command `git fetch official --tags`. If no tag exists that probably means you did not create the package using the create command but by copy/pasting code of an existing one. Then create a tag v0.0.0 on your first commit and push it to your official repository: `git checkout <first commit> && git tag -a v0.0.0 -m \"first commit\" && git push official v0.0.0 && git checkout inegration`. Then try again to release your package.")
	return()
endif()
foreach(version IN LISTS VERSION_NUMBERS)
	if(version STREQUAL STRING)
		message("[PID] ERROR : cannot release version ${STRING} for package ${package}, because this version already exists. Please check that the development branch is up to date or change the new version number to release in package description.")
		return()
	endif()
endforeach()

if(NOT branch)# if the target branch branch is not integration then check that there are new commits to release (avoid unnecessary commits)
	# check that there are things to commit to master
	check_For_New_Commits_To_Release(COMMITS_AVAILABLE ${package})
	if(NOT COMMITS_AVAILABLE)
		message("[PID] ERROR : cannot release package ${package} because integration branch has no commits to contribute to new version.")
		return()
	endif()
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
			message("[PID] INFO: releasing dependency ${DEP_PACKAGE} of ${package}...")
			release_PID_Package(DEP_RESULT ${DEP_PACKAGE} "${next}" "" TRUE)#do not use a specific branch as we do not know it (integration is used)
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

# memorize current cache value
mem_Package_Cache(${package})

# build one time to be sure it builds and tests pass (force build in both Debug and Release)
build_And_Install_Source(IS_BUILT ${package} "" "${CURRENT_BRANCH}" TRUE FALSE)
if(NOT IS_BUILT)
	message("[PID] ERROR : cannot release package ${package}, because its branch ${CURRENT_BRANCH} does not build.")
	reset_Package_Cache(${package})
	return()
endif()

if(branch)#if we use a specific branch for patching then do not merge into master but push this branch in official
	publish_Package_Temporary_Branch(PUBLISH_OK ${package} ${CURRENT_BRANCH})
	if(NOT PUBLISH_OK)
		message("[PID] ERROR : cannot release package ${package}, because you are probably not allowed to push new branches to official package repository.")
		reset_Package_Cache(${package})
		return()
	endif()
	tag_Version(${package} ${STRING} TRUE)#create the version tag
	publish_Repository_Version(RESULT_OK ${package} FALSE ${STRING} TRUE)
	if(NOT RESULT_OK)#the user has no sufficient push rights
		delete_Package_Temporary_Branch(${package} ${CURRENT_BRANCH})#delete the temporary branch in official remote when the push failed
		tag_Version(${package} ${STRING} FALSE)#remove local tag
		message("[PID] ERROR : cannot release package ${package}, because your are not allowed to push version to its official remote !")
		reset_Package_Cache(${package})
		return()
	endif()
	register_PID_Package(${package} "")#automate the registering after release
else()# check that integration branch is a fast forward of master
	merge_Into_Master(MERGE_OK ${package} "integration" ${STRING})
	if(NOT MERGE_OK)
		if(list_of_stashed_files)#if merge failed then the gitignore has not been committed so wee need to save/restore again untracked files
			save_Untracked_Files(${WORKSPACE_DIR}/packages/${package} list_of_stashed_files)
		endif()
		message("[PID] ERROR : cannot release package ${package}, because there are potential merge conflicts between master and integration branches. Please update ${CURRENT_BRANCH} branch of package ${package} first, then launch again the release process.")
		go_To_Integration(${package})#always go back to original branch (here integration by construction)
		if(list_of_stashed_files)
			restore_Untracked_Files(${WORKSPACE_DIR}/packages/${package} list_of_stashed_files)
		endif()
		reset_Package_Cache(${package})
		return()
	endif()
	tag_Version(${package} ${STRING} TRUE)#create the version tag
	publish_Repository_Master(RESULT_OK ${package})
	#TODO before everything testing if user has rights to push
	if(RESULT_OK)
		publish_Repository_Version(RESULT_OK ${package} FALSE ${STRING} TRUE)
	endif()
	if(NOT RESULT_OK)#the user has no sufficient push rights
		tag_Version(${package} ${STRING} FALSE)#remove local tag
		message("[PID] ERROR : cannot release package ${package}, because your are not allowed to push to its master branch !")
		go_To_Integration(${package})#always go back to original branch
		reset_Package_Cache(${package})
		return()
	endif()
	register_PID_Package(${package} "")#automate the registering after release

	#remove the installed version built from integration branch
	file(REMOVE_RECURSE ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${STRING})
	#rebuild package from master branch to get a clean installed version (getting clean use file)
	build_And_Install_Source(IS_BUILT ${package} ${STRING} "" FALSE FALSE)
	if(NOT IS_BUILT AND STRING VERSION_GREATER_EQUAL "1.0.0")#if the package is in a preliminary development state do not stop the versionning if package does not build
		go_To_Integration(${package})#always go back to original branch
		message("[PID] WARNING : during release of package ${package}, its version ${STRING} does not build on master branch.")
	endif()
	#merge back master into integration
	merge_Into_Integration(${package})

	### now starting a new version
	list(LENGTH DIGITS SIZE)
	if(SIZE GREATER 2)
		list(GET DIGITS 2 patch)
	else()
		set(patch 0)
	endif()
	if(SIZE GREATER 1)
		list(GET DIGITS 1 minor)
	else()
		set(minor 0)
	endif()
	list(GET DIGITS 0 major)

	# Allow for both lower case and upper case
	string(TOUPPER "${next}" next)
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
	set_Version_Number_To_Package(RESULT_OK ${package} ${FORMAT} ${METHOD} ${major} ${minor} ${patch}) #change the package description with new version
	if(RESULT_OK)
		register_Repository_Version(${package} "${major}.${minor}.${patch}") # commit new modified version
		publish_Repository_Integration(${package})#if publication rejected => user has to handle merge by hand
	else()
		message("[PID] INTERNAL ERROR : during release of package ${package}, cannot write version in CMakeLists.")
		set(${RESULT} FALSE PARENT_SCOPE)
	endif()
endif()
#put back the package into previous configuration
unset(debug)
unset(non_essential)
unset(optim)
unset(examples)
unset(run_tests)
unset(release_only)
reset_Package_Cache(${package})#reset packaeg cache to its initial state
configure_Source(IS_CONFIGURED ${package} non_essential optim examples debug run_tests release_only)
set(${RESULT} ${STRING} PARENT_SCOPE)
update_Package_Repository_From_Remotes(${package}) #synchronize information on remotes with local one (sanity process, not mandatory)
endfunction(release_PID_Package)

function(mem_Package_Cache package)
	set(tmp_dir ${WORKSPACE_DIR}/build/tmp/${package})
	if(NOT EXISTS ${tmp_dir}/release)
		file(MAKE_DIRECTORY ${tmp_dir}/release)
	endif()
	if(NOT EXISTS ${tmp_dir}/debug)
		file(MAKE_DIRECTORY ${tmp_dir}/debug)
	endif()

	set(main_cache_file ${tmp_dir}/CMakeCache.txt)
	set(release_cache_file ${tmp_dir}/release/CMakeCache.txt)
	set(debug_cache_file ${tmp_dir}/debug/CMakeCache.txt)

	if(EXISTS ${main_cache_file})
		file(REMOVE ${main_cache_file})
	endif()
	if(EXISTS ${release_cache_file})
		file(REMOVE ${release_cache_file})
	endif()
	if(EXISTS ${debug_cache_file})
		file(REMOVE ${debug_cache_file})
	endif()

	# FINALLY copying cache files into workspace temporary folder
	set(path_to_pack ${WORKSPACE_DIR}/packages/${package}/build)
	file(COPY ${path_to_pack}/CMakeCache.txt DESTINATION ${tmp_dir})
	if(EXISTS ${path_to_pack}/release/CMakeCache.txt)
		file(COPY ${path_to_pack}/release/CMakeCache.txt DESTINATION ${tmp_dir}/release)
	endif()
	if(EXISTS ${path_to_pack}/debug/CMakeCache.txt)
		file(COPY ${path_to_pack}/debug/CMakeCache.txt DESTINATION ${tmp_dir}/debug)
	endif()
endfunction(mem_Package_Cache)

function(reset_Package_Cache package)
	set(tmp_dir ${WORKSPACE_DIR}/build/tmp/${package})
	set(path_to_pack ${WORKSPACE_DIR}/packages/${package}/build)
	file(COPY ${tmp_dir}/CMakeCache.txt DESTINATION ${path_to_pack})#restore previous cache
	if(EXISTS ${tmp_dir}/release/CMakeCache.txt)
		file(COPY ${tmp_dir}/release/CMakeCache.txt DESTINATION ${path_to_pack}/release)#restore previous cache
	endif()
	if(EXISTS ${tmp_dir}/debug/CMakeCache.txt)
		file(COPY ${tmp_dir}/debug/CMakeCache.txt DESTINATION ${path_to_pack}/debug)#restore previous cache
	endif()
endfunction(reset_Package_Cache)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deprecate_PID_Package| replace:: ``deprecate_PID_Package``
#  .. _deprecate_PID_Package:
#
#  deprecate_PID_Package
#  ---------------------
#
#   .. command:: deprecate_PID_Package(DEPRECTAED_VERSIONS package version)
#
#     Release the currently developed package version. This results in marking the currnt version with a git tag.
#
#      :package: the name of the package to release.
#      :major_versions: list of major versions to deprecate.
#      :minor_versions: list of minor versions to deprecate.
#
#      :RET_DEPRECATED_VERSIONS: the output variable that contains the list of deprecated versions, empty otherwise.
#
function(deprecate_PID_Package RET_DEPRECATED_VERSIONS package major_versions minor_versions)
set(${RET_DEPRECATED_VERSIONS} PARENT_SCOPE)

# to ensure major and minor versions specified only contain one or two number respectively
set(to_deprecate_major)
set(to_deprecate_minor)
foreach(maj IN LISTS major_versions)
	get_Version_String_Numbers(${maj} MAJOR MINOR PATCH)
	list(APPEND to_deprecate_major ${MAJOR})
endforeach()
if(to_deprecate_major)
	list(REMOVE_DUPLICATES to_deprecate_major)
endif()
foreach(min IN LISTS minor_versions)
	get_Version_String_Numbers(${min} MAJOR MINOR PATCH)
	if(MINOR OR MINOR EQUAL 0)
		list(APPEND to_deprecate_minor ${MAJOR}.${MINOR})
	endif()
endforeach()
if(to_deprecate_minor)
	list(REMOVE_DUPLICATES to_deprecate_minor)
endif()
# 1) remove corresponding versions from install tree (if they exist)
set(package_path_in_install ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package})
list_Version_Subdirectories(all_installed_versions ${package_path_in_install})
foreach(a_version IN LISTS all_installed_versions)
	get_Version_String_Numbers(${a_version} MAJOR MINOR PATCH)
	if(to_deprecate_major)
		list(FIND to_deprecate_major ${MAJOR} INDEX)
		if(NOT INDEX EQUAL -1)#major version is matching to one given to deprecate so uninstall it
			file(REMOVE_RECURSE ${package_path_in_install}/${a_version})
			continue()
		endif()
	endif()
	if(to_deprecate_minor)
		list(FIND to_deprecate_minor "${MAJOR}.${MINOR}" INDEX)
		if(NOT INDEX EQUAL -1)#minor version is matching the one given to deprecate so uninstall it
			file(REMOVE_RECURSE ${package_path_in_install}/${a_version})
			continue()
		endif()
	endif()
endforeach()

# 2) remove version tags in repository
set(untagged_versions)
set(package_repo ${WORKSPACE_DIR}/packages/${package})
get_Repository_Version_Tags(released_versions ${package})#getting version numbers depending on value of tags
foreach(a_version IN LISTS released_versions)
	get_Version_String_Numbers(${a_version} MAJOR MINOR PATCH)
	if(to_deprecate_major OR to_deprecate_major EQUAL 0)
		if(to_deprecate_major EQUAL 0 AND a_version VERSION_EQUAL 0.0.0)
			# specific case v0.0.0 is a special version (initial repository version)
			# that should stay in the repository even if major version 0 is deprecated
			continue()
		endif()
		list(FIND to_deprecate_major ${MAJOR} INDEX)
		if(NOT INDEX EQUAL -1)#major version is matching to one given to deprecate so uninstall it
			tag_Version(${package} ${a_version} FALSE)# delete the tag
			execute_Silent_Process(GIT_OUT GIT_RES ${package_repo} git push --delete official v${a_version})
			if(GIT_RES EQUAL 0)
				list(APPEND untagged_versions ${a_version})
			endif()
			continue()
		endif()
	endif()
	if(to_deprecate_minor)
		if(to_deprecate_minor VERSION_EQUAL 0.0 AND a_version VERSION_EQUAL 0.0.0)
			# specific case v0.0.0 is a special version (initial repository version)
			# that should stay in the repository even if major version 0 is deprecated
			continue()
		endif()
		list(FIND to_deprecate_minor "${MAJOR}.${MINOR}" INDEX)
		if(NOT INDEX EQUAL -1)#minor version is matching the one given to deprecate so uninstall it
			tag_Version(${package} ${a_version} FALSE)# delete the tag
			execute_Silent_Process(GIT_OUT GIT_RES ${package_repo} git push --delete official v${a_version})
			if(GIT_RES EQUAL 0)
				list(APPEND untagged_versions ${a_version})
			endif()
			continue()
		endif()
	endif()
endforeach()

#sanity operation to retrieve tag locally removed but not delete in official due to problems
execute_Silent_Process(GIT_OUT GIT_RES ${package_repo} git fetch official --tags)
if(NOT untagged_versions)
	return()
endif()
#3) generating the new reference file and publishing it in adequate spaces
register_PID_Package(${package} "")

set(${RET_DEPRECATED_VERSIONS} ${untagged_versions} PARENT_SCOPE)
endfunction(deprecate_PID_Package)

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
#     Update a native or external package based on git tags of its source repository.
#
#      :package: the name of the native package to update.
#
function(update_PID_Source_Package package)
set(INSTALLED FALSE)
list_Version_Subdirectories(version_dirs ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package})
get_Package_Type(${package} PACK_TYPE)
if(PACK_TYPE STREQUAL "NATIVE")
	message("[PID] INFO : launch the update of native package ${package} from sources...")
	if(EXISTS ${WORKSPACE_DIR}/packages/${package}/build/Package_Build_Info.cmake)
	 include(${WORKSPACE_DIR}/packages/${package}/build/Package_Build_Info.cmake NO_POLICY_SCOPE)#loading the wrapper description
	endif()
	deploy_Source_Native_Package(INSTALLED ${package} "${version_dirs}" FALSE ${${package}_BUILD_RELEASE_ONLY})
else()
	message("[PID] INFO : launch the update of external package ${package} from its wrapper...")
	if(EXISTS ${WORKSPACE_DIR}/wrappers/${package}/build/Build${package}.cmake)
		include(${WORKSPACE_DIR}/wrappers/${package}/build/Build${package}.cmake NO_POLICY_SCOPE)#loading the wrapper description
	endif()
	deploy_Source_External_Package(INSTALLED ${package} "${version_dirs}" ${${package}_BUILD_RELEASE_ONLY})
endif()
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
#     Update a native or external package based on references on its available binary archives.
#
#      :package: the name of the naive package to update.
#
function(update_PID_Binary_Package package)
message("[PID] INFO : launch the update of binary package ${package}...")
list_Version_Subdirectories(version_dirs ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package})
select_Last_Version(RES_VERSION "${version_dirs}")
if(NOT RES_VERSION)
	return()
endif()
# Note: load the use file of last version to check if it is used as "release only"
# newly installed version (if any) will follow same install pattern
include(${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${RES_VERSION}/share/Use${package}-${RES_VERSION}.cmake)
get_Package_Type(${package} PACK_TYPE)
if(PACK_TYPE STREQUAL "NATIVE")
	deploy_Binary_Native_Package(DEPLOYED ${package} "${version_dirs}" "${${package}_BUILT_RELEASE_ONLY}")
else()
	deploy_Binary_External_Package(DEPLOYED ${package} "${version_dirs}" "${${package}_BUILT_RELEASE_ONLY}")
endif()
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
list_All_Binary_Packages_In_Workspace(BINARY_PACKAGES)
list_All_Source_Packages_In_Workspace(NATIVES)
list_All_Wrappers_In_Workspace(WRAPPERS)
set(SOURCE_PACKAGES ${NATIVES} ${WRAPPERS})

if(SOURCE_PACKAGES)
	if(BINARY_PACKAGES)#no need to check for packages already updated from sources
		list(REMOVE_ITEM BINARY_PACKAGES ${SOURCE_PACKAGES})
	endif()
	foreach(package IN LISTS SOURCE_PACKAGES)
		update_PID_Source_Package(${package})
	endforeach()
endif()
if(BINARY_PACKAGES)
	foreach(package IN LISTS BINARY_PACKAGES)
		load_Package_Binary_References(REFERENCES_OK ${package})
		if(NOT REFERENCES_OK)
			message("[PID] WARNING : no binary reference exists for the package ${package}. Cannot update it ! Please contact the maintainer of package ${package} to have more information about this problem.")
		else()
			get_Package_Type(${package} PACK_TYPE)
			if(PACK_TYPE STREQUAL "NATIVE")
				update_PID_Binary_Package(${package})
			else()
				update_PID_External_Package(${package})
			endif()
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
#      :update: if TRUE all packages will be updated after the workspace upgrade.
#
function(upgrade_Workspace remote update)
save_Workspace_Repository_Context(CURRENT_COMMIT SAVED_CONTENT)
update_Workspace_Repository(${remote})
restore_Workspace_Repository_Context(ERROR ${CURRENT_COMMIT} ${SAVED_CONTENT})
if(ERROR)
	message("[PID] WARNING: You may have to resolve some conflicts in your workspace ! You should check in logs if a CONFLICT has been detected by git: ${ERROR}.")
endif()
update_Contribution_Spaces(UPDATED)
execute_process(COMMAND ${CMAKE_COMMAND} .. WORKING_DIRECTORY ${WORKSPACE_DIR}/build RESULT_VARIABLE res)
if(NOT res EQUAL 0)
	message("[PID] CRITICAL ERROR : problem when reconfiguring the workspace. This is probably due to conflicts between your local modifications and those coming from the official workspace.")
endif()
if(update)
	update_PID_All_Packages()
endif()
endfunction(upgrade_Workspace)


#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Component_Symlinks_In_System_Tree| replace:: ``create_Component_Symlinks_In_System_Tree``
#  .. _create_Component_Symlinks_In_System_Tree:
#
#  create_Component_Symlinks_In_System_Tree
#  -----------------------------------------
#
#   .. command:: create_Component_Symlinks_In_System_Tree(package component resources_var)
#
#   Create symlinks to runtime resources that are located into a system install tree.
#
#     :component: the name of the component.
#
#     :resources_var: the name of the variable that contains the list of runtime resources for the component.
#
function(create_Component_Symlinks_In_System_Tree component resources_var)
	if(${resources_var})
		get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
		#creatings symbolic links
		make_Empty_Folder(${CMAKE_INSTALL_PREFIX}/.rpath/${component}${TARGET_SUFFIX})
		foreach(resource IN LISTS ${resources_var})
			create_Runtime_Symlink("${resource}" "${CMAKE_INSTALL_PREFIX}/.rpath" ${component}${TARGET_SUFFIX})
		endforeach()
	endif()
endfunction(create_Component_Symlinks_In_System_Tree)

#.rst:
#
# .. ifmode:: internal
#
#  .. |install_Component_Runtime_Symlinks_In_Folder| replace:: ``install_Component_Runtime_Symlinks_In_Folder``
#  .. _install_Component_Runtime_Symlinks_In_Folder:
#
#  install_Component_Runtime_Symlinks_In_Folder
#  ---------------------------------------------
#
#   .. command:: install_Component_Runtime_Symlinks_In_Folder(package component)
#
#   Create symlinks to runtime resources directly or undirectly used by a component of the pakage in the install tree.
#
#     :package: the name of the package.
#
#     :component: the name of the component.
#
function(install_Component_Runtime_Symlinks_In_Folder package component)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
is_Runtime_Component(IS_RUNTIME ${package} ${component})#no need to resolve alias since component is supposed to be a base name
if(	IS_RUNTIME )#symlinks need to be generated only for runtime components
	#3) getting direct and undirect runtime resources dependencies
	get_Bin_Component_Runtime_Resources(RES_RESOURCES ${package} ${component} ${CMAKE_BUILD_TYPE} TRUE)
	if(RES_RESOURCES)
    list(REMOVE_DUPLICATES RES_RESOURCES)
		create_Component_Symlinks_In_System_Tree(${component} RES_RESOURCES)
  endif()
endif()
endfunction(install_Component_Runtime_Symlinks_In_Folder)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_CMake_Find_File_Language_Standard| replace:: ``generate_Package_CMake_Find_File_Language_Standard``
#  .. _generate_Package_CMake_Find_File_Language_Standard:
#
#  generate_Package_CMake_Find_File_Language_Standard
#  ----------------------------------------------------
#
#   .. command:: generate_Package_CMake_Find_File_Language_Standard(package component file_name)
#
#   Generate the expression managing the language standard in CMake find file for a given component
#
#     :package: the name of the package.
#
#     :component: the name of the component in package.
#
#     :file_name: the path to find file currenlty xritten where to append content.
#
function(generate_Package_CMake_Find_File_Language_Standard package component file_name)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
# Note: need to use target_compile_features to set the C and C++ standard on interface libraries
# => force the use of CMake 3.8 at minimum

if(${package}_${component}_C_STANDARD${VAR_SUFFIX})
	is_A_C_Language_Standard(IS_STD ${${package}_${component}_C_STANDARD${VAR_SUFFIX}})
	if(IS_STD)
		file(APPEND ${file_name} "  target_compile_features(${package}::${component} INTERFACE c_std_${${package}_${component}_C_STANDARD${VAR_SUFFIX}})\n")
	endif()
endif()

if(${package}_${component}_CXX_STANDARD${VAR_SUFFIX})
	is_A_CXX_Language_Standard(IS_STD ${${package}_${component}_CXX_STANDARD${VAR_SUFFIX}})
	if(IS_STD)
		file(APPEND ${file_name} "  target_compile_features(${package}::${component} INTERFACE cxx_std_${${package}_${component}_CXX_STANDARD${VAR_SUFFIX}})\n")
	endif()
endif()

endfunction(generate_Package_CMake_Find_File_Language_Standard)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_CMake_Find_File| replace:: ``generate_Package_CMake_Find_File``
#  .. _generate_Package_CMake_Find_File:
#
#  generate_Package_CMake_Find_File
#  ---------------------------------
#
#   .. command:: generate_Package_CMake_Find_File(package is_external is_system)
#
#   Generate the CMake find file for a package
#
#     :package: the name of the package.
#
#     :is_external: if TRUE the package is considered as external.
#
#     :is_system: if TRUE the system variant of the external package is managed.
#
function(generate_Package_CMake_Find_File package is_external is_system)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
extract_Version_NUMBERS(
	${package}_VERSION_MAJOR
	${package}_VERSION_MINOR
	${package}_VERSION_PATCH
	${${package}_VERSION_STRING}
)
set(file_name ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/pid_cmake/Find${package}.cmake)
file(WRITE ${file_name} "cmake_minimum_required(VERSION 3.19.8)\n")#reset file content and start writing find procedure
#CMake 3.8 is minimum required to get the target compile features available
file(APPEND ${file_name} "if(${package}_FOUND)\n")
file(APPEND ${file_name} "  set(${package}_VERSION_STRING_GENERATED ${${package}_VERSION_STRING})\n")
file(APPEND ${file_name} "else()\n")
file(APPEND ${file_name} "  include(FindPackageHandleStandardArgs)\n")
file(APPEND ${file_name} "  set(${package}_VERSION_MAJOR_GENERATED ${${package}_VERSION_MAJOR})\n")
file(APPEND ${file_name} "  set(${package}_VERSION_MINOR_GENERATED ${${package}_VERSION_MINOR})\n")
file(APPEND ${file_name} "  set(${package}_VERSION_PATCH_GENERATED ${${package}_VERSION_PATCH})\n")

file(APPEND ${file_name} "  set(${package}_FOUND_COMPATIBLE_VERSION TRUE)\n")
file(APPEND ${file_name} "  if(${package}_FIND_VERSION)\n")
file(APPEND ${file_name} "    if(${package}_FIND_VERSION_MAJOR EQUAL ${package}_VERSION_MAJOR_GENERATED)\n")
file(APPEND ${file_name} "      if(${package}_FIND_VERSION_MINOR EQUAL ${package}_VERSION_MINOR_GENERATED)\n")
file(APPEND ${file_name} "        if(${package}_FIND_VERSION_PATCH GREATER ${package}_VERSION_PATCH_GENERATED)\n")
file(APPEND ${file_name} "          set(${package}_FOUND_COMPATIBLE_VERSION FALSE)\n")
file(APPEND ${file_name} "        endif()\n")
file(APPEND ${file_name} "      elseif(${package}_FIND_VERSION_MINOR GREATER ${package}_VERSION_MINOR_GENERATED)\n")
file(APPEND ${file_name} "        set(${package}_FOUND_COMPATIBLE_VERSION FALSE)\n")
file(APPEND ${file_name} "      endif()\n")
file(APPEND ${file_name} "    else()\n")
file(APPEND ${file_name} "      set(${package}_FOUND_COMPATIBLE_VERSION FALSE)\n")
file(APPEND ${file_name} "    endif()\n")
file(APPEND ${file_name} "  endif()\n")
file(APPEND ${file_name} "  if(${package}_FOUND_COMPATIBLE_VERSION)\n")
	# find deps + generate targets
file(APPEND ${file_name} "    set(PACKAGE_SEARCH_PATH ${CMAKE_INSTALL_PREFIX})\n")
file(APPEND ${file_name} "    set(PACKAGE_LIB_SEARCH_PATH ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})\n")
file(APPEND ${file_name} "    set(PACKAGE_BIN_SEARCH_PATH ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR})\n")
file(APPEND ${file_name} "    set(PACKAGE_INC_SEARCH_PATH ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR})\n")

file(APPEND ${file_name} "    # searching for dependencies \n")
foreach(ext_pack IN LISTS ${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
	set(find_args_str)
	if(${package}_EXTERNAL_DEPENDENCY_${ext_pack}_VERSION${VAR_SUFFIX})
		if(${package}_EXTERNAL_DEPENDENCY_${ext_pack}_VERSION_EXACT${VAR_SUFFIX})
			set(find_args_str ${${ext_pack}_VERSION_STRING} EXACT)
		else()
			set(find_args_str ${${ext_pack}_VERSION_STRING})
		endif()
	endif()
	file(APPEND ${file_name} "    find_package(${ext_pack} ${find_args_str} REQUIRED)\n")
endforeach()
foreach(nat_pack IN LISTS ${package}_DEPENDENCIES${VAR_SUFFIX})
	if(${package}_DEPENDENCY_${nat_pack}_VERSION${VAR_SUFFIX})
		if(${package}_DEPENDENCY_${nat_pack}_VERSION_EXACT${VAR_SUFFIX})
			set(find_args_str ${${nat_pack}_VERSION_STRING} EXACT)
		else()
			set(find_args_str ${${nat_pack}_VERSION_STRING})
		endif()
	endif()
	file(APPEND ${file_name} "    find_package(${nat_pack} ${find_args_str} REQUIRED)\n")
endforeach()

if(is_external)
	foreach(component IN LISTS ${package}_COMPONENTS${VAR_SUFFIX})#creating local target for each component

		file(APPEND ${file_name} "    add_library(${package}::${component} INTERFACE IMPORTED GLOBAL)\n")#creating the target
		if(NOT is_system)#if it is a system olibrary then its include is supposed to be public
			file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES \${PACKAGE_INC_SEARCH_PATH})\n")
		endif()

		generate_Package_CMake_Find_File_Language_Standard(${package} ${component} ${file_name})

		list_Public_Definitions(DEFS ${package} ${component} ${CMAKE_BUILD_TYPE})
		list_Public_Options(OPTS ${package} ${component} ${CMAKE_BUILD_TYPE})
	  	list_External_Links(SHARED_LNKS STATIC_LNKS ${package} ${component} ${CMAKE_BUILD_TYPE})

		#no need to manage library dirs as all libraries in a system install are supposed to be in folders that the loader/linker can find
		foreach(def IN LISTS DEFS)
			file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS \"${def}\")\n")
		endforeach()
		foreach(opt IN LISTS OPTS)
			file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_OPTIONS \"${opt}\")\n")
		endforeach()

		foreach(link IN LISTS SHARED_LNKS)
			get_Link_Type(RES_TYPE ${link})
			if(RES_TYPE STREQUAL OPTION) #this is an option => simply pass it to the link interface
				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${link})\n")
			else()#this is a full path to a library
				get_filename_component(LIB_NAME ${link} NAME)
				if(NOT is_system)#check can only be performed with non system libraries
					file(APPEND ${file_name} "    if(NOT EXISTS \${PACKAGE_LIB_SEARCH_PATH}/${LIB_NAME})\n")
						file(APPEND ${file_name} "      message(WARNING \"Package ${package} component ${component} : cannot find library ${LIB_NAME} in \${PACKAGE_LIB_SEARCH_PATH}\")\n")
						file(APPEND ${file_name} "      return()\n")
					file(APPEND ${file_name} "    endif()\n")
				endif()
				file(APPEND ${file_name} "    if(NOT TARGET ext${LIB_NAME})\n")
				file(APPEND ${file_name} "      add_library(ext${LIB_NAME} SHARED IMPORTED GLOBAL)\n")
				if(is_system)#if it is a system dependency wit hsimply use the library name and the system is supposed to be able to automatically find the corresponding binary
					file(APPEND ${file_name} "      set_target_properties(ext${LIB_NAME} PROPERTIES INTERFACE_LINK_LIBRARIES ${LIB_NAME})\n")
				else()#otherwise we can specify it
					file(APPEND ${file_name} "      set_target_properties(ext${LIB_NAME} PROPERTIES IMPORTED_LOCATION \${PACKAGE_LIB_SEARCH_PATH}/${LIB_NAME})\n")
				endif()
				file(APPEND ${file_name} "    endif()\n")
				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ext${LIB_NAME})\n")
			endif()
	  endforeach()
	  #static second
	  foreach(link IN LISTS STATIC_LNKS)
			get_Link_Type(RES_TYPE ${link})
 			if(RES_TYPE STREQUAL OPTION) #this is an option => simply pass it to the link interface
 				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${link})\n")
 			else()#this is a full path to a library
				get_filename_component(LIB_NAME ${link} NAME)
				if(NOT is_system)#check can only be performed with non system libraries
					file(APPEND ${file_name} "    if(NOT EXISTS \${PACKAGE_LIB_SEARCH_PATH}/${LIB_NAME})\n")
					file(APPEND ${file_name} "      message(WARNING \"Package ${package} component ${component} : cannot find library ${LIB_NAME} in \${PACKAGE_LIB_SEARCH_PATH}\")\n")
					file(APPEND ${file_name} "      return()\n")
					file(APPEND ${file_name} "    endif()\n")
				endif()
 				file(APPEND ${file_name} "    if(NOT TARGET ext${LIB_NAME})\n")
 				file(APPEND ${file_name} "      add_library(ext${LIB_NAME} STATIC IMPORTED GLOBAL)\n")
				if(is_system)#if it is a system dependency wit hsimply use the library name and the system is supposed to be able to automatically find the corresponding binary
					file(APPEND ${file_name} "      set_target_properties(ext${LIB_NAME} PROPERTIES INTERFACE_LINK_LIBRARIES ${LIB_NAME})\n")
				else()#otherwise we can specify it
					file(APPEND ${file_name} "      set_target_properties(ext${LIB_NAME} PROPERTIES IMPORTED_LOCATION \${PACKAGE_LIB_SEARCH_PATH}/${LIB_NAME})\n")
				endif()
 				file(APPEND ${file_name} "    endif()\n")
 				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ext${LIB_NAME})\n")
 			endif()
	  endforeach()


		# managing dependencies
		foreach(dep_component IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
			rename_If_Alias(dep_name_to_use ${package} ${dep_component})#dependent component name may be an alias
			export_External_Component(IS_EXPORTING ${package} ${component} ${package} ${dep_name_to_use} ${CMAKE_BUILD_TYPE})
			if(IS_EXPORTING)
				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${package}::${dep_name_to_use},INTERFACE_INCLUDE_DIRECTORIES>)\n")
				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS $<TARGET_PROPERTY:${package}::${dep_name_to_use},INTERFACE_COMPILE_DEFINITIONS>)\n")
				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_OPTIONS $<TARGET_PROPERTY:${package}::${dep_name_to_use},INTERFACE_COMPILE_OPTIONS>)\n")
				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${package}::${dep_name_to_use})\n")
			elseif(${package}_${component}_TYPE STREQUAL "SHARED" OR ${package}_${component}_TYPE STREQUAL "MODULE")
				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY IMPORTED_LINK_DEPENDENT_LIBRARIES ${package}::${dep_name_to_use})\n")
			endif()#exporting the linked libraries in any case
		endforeach()

		foreach(dep_package IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
			foreach(dep_component IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
				rename_If_Alias(dep_name_to_use ${dep_package} ${dep_component})#dependent component name may be an alias
				export_External_Component(IS_EXPORTING ${package} ${component} ${dep_package} ${dep_name_to_use} ${CMAKE_BUILD_TYPE})
  			if(IS_EXPORTING)
  				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${dep_package}::${dep_name_to_use},INTERFACE_INCLUDE_DIRECTORIES>)\n")
  				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS $<TARGET_PROPERTY:${dep_package}::${dep_name_to_use},INTERFACE_COMPILE_DEFINITIONS>)\n")
  				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_OPTIONS $<TARGET_PROPERTY:${dep_package}::${dep_name_to_use},INTERFACE_COMPILE_OPTIONS>)\n")
  				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${dep_package}::${dep_name_to_use})\n")
  			elseif(${package}_${component}_TYPE STREQUAL "SHARED" OR ${package}_${component}_TYPE STREQUAL "MODULE")
  				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY IMPORTED_LINK_DEPENDENT_LIBRARIES ${dep_package}::${dep_name_to_use})\n")
  			endif()#exporting the linked libraries in any case
		  endforeach()
		endforeach()
	endforeach()

else()#Note: part for native packages
	#searching elements to make sure the package is well installed
	foreach(component IN LISTS ${package}_COMPONENTS)
		is_Built_Component(IS_BUILT ${package} ${component})
		if(IS_BUILT AND NOT ${package}_${component}_TYPE STREQUAL "TEST")#searching for binaries
			is_Executable_Component(IS_EXE ${package} ${component})
			if(IS_EXE)
				file(APPEND ${file_name} "    if(NOT EXISTS \${PACKAGE_BIN_SEARCH_PATH}/${${package}_${component}_BINARY_NAME${VAR_SUFFIX}})\n")
				file(APPEND ${file_name} "      message(WARNING \"Package ${package} component ${component} : cannot find executable ${${package}_${component}_BINARY_NAME${VAR_SUFFIX}} in \${PACKAGE_BIN_SEARCH_PATH}\")\n")
				file(APPEND ${file_name} "      return()\n")
				file(APPEND ${file_name} "    endif()\n")
			else()
				file(APPEND ${file_name} "    if(NOT EXISTS \${PACKAGE_LIB_SEARCH_PATH}/${${package}_${component}_BINARY_NAME${VAR_SUFFIX}})\n")
				file(APPEND ${file_name} "      message(WARNING \"Package ${package} component ${component} : cannot find library ${${package}_${component}_BINARY_NAME${VAR_SUFFIX}} in \${PACKAGE_LIB_SEARCH_PATH}\")\n")
				file(APPEND ${file_name} "      return()\n")
				file(APPEND ${file_name} "    endif()\n")
			endif()
		endif()
		is_HeaderFree_Component(IS_HF ${package} ${component})
		if(NOT IS_HF)#searching for headers
			foreach(header_file IN LISTS ${package}_${component}_HEADERS)
				file(APPEND ${file_name} "    if(NOT EXISTS \${PACKAGE_INC_SEARCH_PATH}/${header_file})\n")
				file(APPEND ${file_name} "      message(WARNING \"Package ${package} component ${component} : cannot find header ${header_file} in \${PACKAGE_INC_SEARCH_PATH}\")\n")
				file(APPEND ${file_name} "      return()\n")
				file(APPEND ${file_name} "    endif()\n")
			endforeach()
		endif()

		#create a local target for the component (only for libraries components)
		set(target_created FALSE)
		if(${package}_${component}_TYPE STREQUAL "MODULE")
			set(target_created TRUE)
			file(APPEND ${file_name} "    add_library(${package}::${component} MODULE IMPORTED GLOBAL)\n")
			file(APPEND ${file_name} "    set_target_properties(${package}::${component} PROPERTIES IMPORTED_LOCATION \"\${PACKAGE_LIB_SEARCH_PATH}/${${package}_${component}_BINARY_NAME${VAR_SUFFIX}}\"\n")
		elseif(${package}_${component}_TYPE STREQUAL "SHARED")
			set(target_created TRUE)
			if(WIN32)
				file(APPEND ${file_name} "    add_library(${package}::${component} STATIC IMPORTED GLOBAL)\n")
				string(REPLACE ".dll" ".lib" STATIC_NAME "${${package}_${component}_BINARY_NAME${VAR_SUFFIX}}")
				set(LOCATION_RES "\${PACKAGE_LIB_SEARCH_PATH}/${STATIC_NAME}")
			else()
				file(APPEND ${file_name} "    add_library(${package}::${component} SHARED IMPORTED GLOBAL)\n")
				set(LOCATION_RES "\${PACKAGE_LIB_SEARCH_PATH}/${${package}_${component}_BINARY_NAME${VAR_SUFFIX}}")
			endif()
			file(APPEND ${file_name} "    set_target_properties(${package}::${component} PROPERTIES IMPORTED_LOCATION \"${LOCATION_RES}\")\n")
			file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES \${PACKAGE_INC_SEARCH_PATH})\n")
		elseif(${package}_${component}_TYPE STREQUAL "STATIC")
			set(target_created TRUE)
			file(APPEND ${file_name} "    add_library(${package}::${component} STATIC IMPORTED GLOBAL)\n")
			file(APPEND ${file_name} "    set_target_properties(${package}::${component} PROPERTIES IMPORTED_LOCATION \"\${PACKAGE_LIB_SEARCH_PATH}/${${package}_${component}_BINARY_NAME${VAR_SUFFIX}}\")\n")
			file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES \${PACKAGE_INC_SEARCH_PATH})\n")
		elseif(${package}_${component}_TYPE STREQUAL "HEADER")
			set(target_created TRUE)
			file(APPEND ${file_name} "    add_library(${package}::${component} INTERFACE IMPORTED GLOBAL)\n")
			file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES \${PACKAGE_INC_SEARCH_PATH})\n")
			endif()

		if(target_created)

			generate_Package_CMake_Find_File_Language_Standard(${package} ${component} ${file_name})

			list_Public_Links(LINKS SYSTEM_STATIC ${package} ${component} ${CMAKE_BUILD_TYPE})
			list_Private_Links(PRIVATE_LINKS ${package} ${component} ${CMAKE_BUILD_TYPE})
			list_Public_Definitions(DEFS ${package} ${component} ${CMAKE_BUILD_TYPE})
			list_Public_Options(OPTS ${package} ${component} ${CMAKE_BUILD_TYPE})

			#no need to manage library dirs as all libraries in a system install are supposed to be in folders that the loader/linker can find
			foreach(def IN LISTS DEFS)
				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS \"${def}\")\n")
			endforeach()
			foreach(opt IN LISTS OPTS)
				file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_OPTIONS \"${opt}\")\n")
			endforeach()

			foreach(link IN LISTS LINKS)
				get_Link_Type(RES_TYPE ${link})
				if(RES_TYPE STREQUAL OPTION) #this is an option => simply pass it to the link interface
					file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${link})\n")
				else()#this is a full path to a library
					get_filename_component(LIB_NAME ${link} NAME)
					file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ext${LIB_NAME})\n")
				endif()
			endforeach()
			# managing private link time flags (private links are never put in the interface)#TODO check that
			if(${package}_${component}_TYPE STREQUAL "SHARED" OR ${package}_${component}_TYPE STREQUAL "MODULE")
				foreach(link IN LISTS PRIVATE_LINKS)
					get_Link_Type(RES_TYPE ${link})
					get_filename_component(LIB_NAME ${link} NAME)
					if(RES_TYPE STREQUAL OPTION) #this is an option => simply pass it to the link interface
						file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY IMPORTED_LINK_DEPENDENT_LIBRARIES ${link})\n")
					else()#this is a full path to a library
						file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY IMPORTED_LINK_DEPENDENT_LIBRARIES ext${LIB_NAME})\n")
					endif()
				endforeach()
			endif()

			foreach(link IN LISTS SYSTEM_STATIC)#force the use of a system static link
				if(WIN32)
          string(REGEX REPLACE "^-l(.+)$" "\\1.lib" link_name ${link})
        else()
          string(REGEX REPLACE "^-l(.+)$" "lib\\1.a" link_name ${link})
        endif()
        file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${link_name})\n")
			endforeach()

			#now dealing with dependencies
			foreach(dep_package IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
			  foreach(dep_component IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
					rename_If_Alias(dep_name_to_use ${dep_package} ${dep_component})#dependent component name may be an alias
					export_External_Component(IS_EXPORTING ${package} ${component} ${dep_package} ${dep_name_to_use} ${CMAKE_BUILD_TYPE})
					if(IS_EXPORTING)
						file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${dep_package}::${dep_name_to_use},INTERFACE_INCLUDE_DIRECTORIES>)\n")
						file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS $<TARGET_PROPERTY:${dep_package}::${dep_name_to_use},INTERFACE_COMPILE_DEFINITIONS>)\n")
						file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_OPTIONS $<TARGET_PROPERTY:${dep_package}::${dep_name_to_use},INTERFACE_COMPILE_OPTIONS>)\n")
						file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${dep_package}::${dep_name_to_use})\n")
					elseif(${package}_${component}_TYPE STREQUAL "SHARED" OR ${package}_${component}_TYPE STREQUAL "MODULE")
						file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY IMPORTED_LINK_DEPENDENT_LIBRARIES ${dep_package}::${dep_name_to_use})\n")
					endif()#exporting the linked libraries in any case
			  endforeach()
			endforeach()

			#dealing with internal dependencies
			foreach(dep_component IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
				rename_If_Alias(dep_name_to_use ${package} ${dep_component})#dependent component name may be an alias
				export_Component_Resolving_Alias(IS_EXPORTING ${package} ${component} ${component} ${package} ${dep_name_to_use} ${dep_component} ${CMAKE_BUILD_TYPE})
				is_HeaderFree_Component(DEP_IS_HF ${package} ${dep_name_to_use})
				if(NOT DEP_IS_HF)#the required package component is a library with header it can export something
					if(IS_EXPORTING)
						#use to this to be compatible with CMake >= 3.1
						file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${package}::${dep_name_to_use},INTERFACE_INCLUDE_DIRECTORIES>)\n")
						file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS $<TARGET_PROPERTY:${package}::${dep_name_to_use},INTERFACE_COMPILE_DEFINITIONS>)\n")
						file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_OPTIONS $<TARGET_PROPERTY:${package}::${dep_name_to_use},INTERFACE_COMPILE_OPTIONS>)\n")
						file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${package}::${dep_name_to_use})\n")
					elseif(${package}_${component}_TYPE STREQUAL "SHARED" OR ${package}_${component}_TYPE STREQUAL "MODULE")
						file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY IMPORTED_LINK_DEPENDENT_LIBRARIES ${package}::${dep_name_to_use})\n")
					endif()#exporting th
				endif()
			endforeach()

			#dealing with package dependencies
			foreach(dep_package IN LISTS ${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
				foreach(dep_component IN LISTS ${package}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
					rename_If_Alias(dep_name_to_use ${dep_package} ${dep_component})#dependent component name may be an alias
					export_Component_Resolving_Alias(IS_EXPORTING ${package} ${component} ${component} ${dep_package} ${dep_name_to_use} ${dep_component} ${CMAKE_BUILD_TYPE})
					is_HeaderFree_Component(DEP_IS_HF ${dep_package} ${dep_name_to_use})
					if(NOT DEP_IS_HF)#the required package component is a library with header it can export something
						if(IS_EXPORTING)
							file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${dep_package}::${dep_name_to_use},INTERFACE_INCLUDE_DIRECTORIES>)\n")
							file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS $<TARGET_PROPERTY:${dep_package}::${dep_name_to_use},INTERFACE_COMPILE_DEFINITIONS>)\n")
							file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_COMPILE_OPTIONS $<TARGET_PROPERTY:${dep_package}::${dep_name_to_use},INTERFACE_COMPILE_OPTIONS>)\n")
							file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${dep_package}::${dep_name_to_use})\n")
						elseif(${package}_${component}_TYPE STREQUAL "SHARED" OR ${package}_${component}_TYPE STREQUAL "MODULE")
							file(APPEND ${file_name} "    set_property(TARGET ${package}::${component} APPEND PROPERTY IMPORTED_LINK_DEPENDENT_LIBRARIES ${dep_package}::${dep_name_to_use})\n")
						endif()
					endif()
				endforeach()
			endforeach()
		endif()
	endforeach()
endif()

file(APPEND ${file_name} "    # package as been found and all targets created\n")
file(APPEND ${file_name} "    set(${package}_VERSION_STRING_GENERATED ${${package}_VERSION_STRING})\n")
file(APPEND ${file_name} "  endif()\n")
file(APPEND ${file_name} "endif()\n") # if package found
file(APPEND ${file_name} "find_package_handle_standard_args(\n")
file(APPEND ${file_name} "  ${package}\n")
file(APPEND ${file_name} "  DEFAULT_MSG\n")
file(APPEND ${file_name} "  ${package}_VERSION_STRING_GENERATED\n")
file(APPEND ${file_name} ")\n")

endfunction(generate_Package_CMake_Find_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |install_Package_Content_In_Folder| replace:: ``install_Package_Content_In_Folder``
#  .. _install_Package_Content_In_Folder:
#
#  install_Package_Content_In_Folder
#  ---------------------------------
#
#   .. command:: install_Package_Content_In_Folder(package version mode folder)
#
#   Install the content of a package into a given folder.
#   The package build mode is defined with CMAKE_BUILD_TYPE and install folder by CMAKE_INSTALL_PREFIX.
#
#     :package: the name of the package.
#
function(install_Package_Content_In_Folder package)
set(IS_SYSTEM_DEPENDENCY_WRAPPER FALSE)
set(GENERATE_SYMLINKS TRUE)
set(package_workspace_path ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${${package}_VERSION_STRING})
get_Package_Type(${package} PACK_TYPE)
if(PACK_TYPE STREQUAL "EXTERNAL")
	set(is_external TRUE)
	if(${package}_BUILT_OS_VARIANT)
		set(IS_SYSTEM_DEPENDENCY_WRAPPER TRUE)
	endif()
	set(GENERATE_SYMLINKS FALSE)
else()#it is a native package
	set(is_external FALSE)
endif()

if(NOT IS_SYSTEM_DEPENDENCY_WRAPPER)#for OS variant version of external packages simply do not do anything
	#1) copy the content of include, bin, lib and share/resources + in adequate folders (use share/pid/resources as new root to avoid troubles in system folders)
	if(EXISTS ${package_workspace_path}/bin AND IS_DIRECTORY ${package_workspace_path}/bin)
		file(GLOB binaries ${package_workspace_path}/bin/*)
		file(COPY ${binaries} DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR})
	endif()
	if(EXISTS ${package_workspace_path}/include AND IS_DIRECTORY ${package_workspace_path}/include)
		if(is_external)#there is one inclusion level less in external packages
			file(GLOB includes ${package_workspace_path}/include/*)
		else()
			file(GLOB includes ${package_workspace_path}/include/*/*)
		endif()
		file(COPY ${includes} DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR})
	endif()
	set(libs_path ${package_workspace_path}/lib)
	if(EXISTS ${libs_path} AND IS_DIRECTORY ${libs_path})
		file(GLOB_RECURSE libs ${libs_path}/*.so* ${libs_path}/*.a ${libs_path}/*.la ${libs_path}/*.dylib ${libs_path}/*.dll ${libs_path}/*.lib)
		file(COPY ${libs} DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
	endif()
	#management of contained runtime resources
	if(is_external)#runtime resources of external packages are really specific
		set(ext_res)
		foreach(component IN LISTS ${package}_COMPONENTS)
			if(${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX})
				list(APPEND ext_res ${${package}_${component}_RUNTIME_RESOURCES${VAR_SUFFIX}})
			endif()
		endforeach()
		if(ext_res)
			resolve_External_Package_Runtime_Resources(EXT_RUNTIME_RES "${ext_res}" ${CMAKE_BUILD_TYPE})
			if(EXT_RUNTIME_RES)
				file(COPY ${EXT_RUNTIME_RES} DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/runtime_resources)#putting all runtime resource directly in the folder runtime_resources
			endif()
		endif()
	else()#it is a native package
		#runtime resource definition is specific to PID packages
		if(EXISTS ${package_workspace_path}/share/resources AND IS_DIRECTORY ${package_workspace_path}/share/resources)
			file(GLOB runres ${package_workspace_path}/share/resources/*)
			if(runres)
				file(COPY ${runres} DESTINATION ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/runtime_resources)#putting all runtime resource directly in the folder runtime_resources
			endif()
		endif()
	endif()

	if(GENERATE_SYMLINKS)
		#generate adequate symlinks for runtime resources in .rpath (only for native packages)
		foreach(component IN LISTS ${package}_COMPONENTS)
			install_Component_Runtime_Symlinks_In_Folder(${package} ${component})
		endforeach()
	endif()
endif()

generate_Package_CMake_Find_File(${package} ${is_external} ${IS_SYSTEM_DEPENDENCY_WRAPPER})

endfunction(install_Package_Content_In_Folder)

#.rst:
#
# .. ifmode:: internal
#
#  .. |install_Package_In_Folder| replace:: ``install_Package_In_Folder``
#  .. _install_Package_In_Folder:
#
#  install_Package_In_Folder
#  -------------------------
#
#   .. command:: install_Package_In_Folder(package version mode folder)
#
#   Install a package and all its dependencies into a given folder.
#   The package build mode is defined with CMAKE_BUILD_TYPE and install folder by CMAKE_INSTALL_PREFIX.
#
#     :package: the name of the package.
#
function(install_Package_In_Folder package)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
if(${package}_PREPARE_INSTALL${VAR_SUFFIX})#this is a guard to limit recursion -> the runtime has already been prepared
	return()
endif()

if(${package}_DURING_PREPARE_INSTALL${VAR_SUFFIX})
  finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : cyclic dependencies between packages found : Package ${package} is undirectly requiring itself !")
	return()
endif()
set(${package}_DURING_PREPARE_INSTALL${VAR_SUFFIX} TRUE)

#installing packages dependency
foreach(dep IN LISTS ${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
	install_Package_In_Folder(${dep} ${${dep}_VERSION_STRING})
endforeach()

foreach(dep IN LISTS ${package}_DEPENDENCIES${VAR_SUFFIX})#only for native packages
	install_Package_In_Folder(${dep} ${${dep}_VERSION_STRING})
endforeach()

# 2) installing package's own content
install_Package_Content_In_Folder(${package})

set(${package}_DURING_PREPARE_INSTALL${VAR_SUFFIX} FALSE)
set(${package}_PREPARE_INSTALL${VAR_SUFFIX} TRUE)
endfunction(install_Package_In_Folder)

#.rst:
#
# .. ifmode:: internal
#
#  .. |install_Package_In_System| replace:: ``install_Package_In_System``
#  .. _install_Package_In_System:
#
#  install_Package_In_System
#  -------------------------
#
#   .. command:: install_Package_In_System(IS_INSTALLED platform package version system_folder)
#
#     Install a given package into a system folder. Will end in installing all the headers and binaries of package and its dependencies
#     into adequate subfolders of the taregt system folder.
#     The package build mode is defined with CMAKE_BUILD_TYPE and install folder by CMAKE_INSTALL_PREFIX.
#
#      :package: the name of the package to install in system.
#      :version: the version of the package to install.
#
#      :IS_INSTALLED: the output variable that is TRUE if the install process succeeded, FALSE otherwise
#
#
function(install_Package_In_System IS_INSTALLED package version)

	set(${IS_INSTALLED} FALSE PARENT_SCOPE)
	set(BIN_PACKAGE_PATH ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${version})
	include(${BIN_PACKAGE_PATH}/share/Use${package}-${version}.cmake OPTIONAL RESULT_VARIABLE res)
	#using the generated Use<package>-<version>.cmake file to get adequate version information about components
	if(	res STREQUAL NOTFOUND)
		message("[PID] ERROR : The binary package ${package} (version ${version}) cannot be found from the workspace path : ${WORKSPACE_DIR}")
		return()
	elseif(NOT DEFINED ${package}_COMPONENTS)#if there is no component defined for the package there is an error
		message("[PID] INFO : binary package ${package} (version ${version}) has no component defined, this denote a bad state for this package.")
		return()
	endif()
	include(PID_Package_API_Internal_Functions NO_POLICY_SCOPE)
	include(GNUInstallDirs)
	if(NOT CMAKE_INSTALL_BINDIR)
		set(CMAKE_INSTALL_BINDIR bin)
	endif()
	if(NOT CMAKE_INSTALL_LIBDIR)
		set(CMAKE_INSTALL_LIBDIR lib)
	endif()
	if(CMAKE_LIBRARY_ARCHITECTURE)
		set(CMAKE_INSTALL_LIBDIR ${CMAKE_INSTALL_LIBDIR}/${CMAKE_LIBRARY_ARCHITECTURE})
	else()
		set(CMAKE_INSTALL_LIBDIR ${CMAKE_INSTALL_LIBDIR}/${CMAKE_LIBRARY_ARCHITECTURE})
	endif()
	if(NOT CMAKE_INSTALL_INCLUDEDIR)
		set(CMAKE_INSTALL_INCLUDEDIR include)
	endif()
	if(NOT CMAKE_INSTALL_DATAROOTDIR)
		set(CMAKE_INSTALL_DATAROOTDIR share)
	endif()
	##################################################################
	############### resolving all runtime dependencies ###############
	##################################################################

	#set the variable to be able to use Package Internal API
	set(${package}_ROOT_DIR ${BIN_PACKAGE_PATH} CACHE INTERNAL "")

	set(PROJECT_NAME workspace)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
	set(${package}_FOUND${VAR_SUFFIX} TRUE CACHE INTERNAL "")
	set(${package}_VERSION_STRING ${version} CACHE INTERNAL "")
	if(CMAKE_BUILD_TYPE MATCHES Debug)
		set(release_only FALSE)
	else()
		set(release_only TRUE)
	endif()
	resolve_Package_Dependencies(${package} ${CMAKE_BUILD_TYPE} TRUE "${release_only}") # finding all package dependencies and loading all adequate variables locally

	#prepare creation of install subfolders
	if(NOT EXISTS ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR})
		file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR} )
	endif()
	if(NOT EXISTS ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR})
		file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_INCLUDEDIR} )
	endif()
	if(NOT EXISTS ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/runtime_resources)
		file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/runtime_resources)
	endif()
	if(NOT EXISTS ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/pid_cmake)#where generated find scripts will be put
		file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}/pid_cmake)
	endif()
	if(NOT EXISTS ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
		file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
	endif()
	if(NOT EXISTS ${CMAKE_INSTALL_PREFIX}/.rpath)
		file(MAKE_DIRECTORY ${CMAKE_INSTALL_PREFIX}/.rpath )
	endif()
	#create adequate global symlink to manage bruntime resources the good way
	create_Symlink(${CMAKE_INSTALL_PREFIX}/.rpath ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/.rpath)#make pid-rpath capable of finding runtime resource folder whatever the relative position is
	create_Symlink(${CMAKE_INSTALL_PREFIX}/.rpath ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}/.rpath)#make pid-rpath capable of finding runtime resource folder whatever the relative position is

	#now install everything
	install_Package_In_Folder(${package})
	set(${IS_INSTALLED} TRUE PARENT_SCOPE)
endfunction(install_Package_In_System)

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
	get_All_Available_Licenses(ALL_AVAILABLE_LICENSES)
	set(licenses "")
	foreach(licensefile IN LISTS ALL_AVAILABLE_LICENSES)
		get_filename_component(licensefilename ${licensefile} NAME)
		if(licensefilename MATCHES "^License([^\\.]+)\\.cmake$")#it matches
			list(APPEND licenses ${CMAKE_MATCH_1})
		endif()
	endforeach()
	set(res_licenses_string "")
	fill_String_From_List(res_licenses_string licenses " ")
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
######################## Languages management ##########################
########################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Available_Languages| replace:: ``print_Available_Languages``
#  .. _print_Available_Languages:
#
#  print_Available_Languages
#  -------------------------
#
#   .. command:: print_Available_Languages()
#
#     Print brief description of all langauges available with current profile.
#
function(print_Available_Languages)
	foreach(lang IN ITEMS C CXX ASM Fortran CUDA Python)
		print_Language_Info(${lang})
	endforeach()
endfunction(print_Available_Languages)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Language_Info| replace:: ``print_Language_Info``
#  .. _print_Language_Info:
#
#  print_Language_Info
#  -------------------
#
#   .. command:: print_Language_Info(lang)
#
#     Print information about a given language.
#
#      :lang: the Cmake identifier of the language.
#
function(print_Language_Info lang)
if(${lang}_Language_AVAILABLE)
	import_Language_Parameters(${lang})
	set(lang_constraints ${LANG_${lang}_OPTIONAL_CONSTRAINTS} ${LANG_${lang}_REQUIRED_CONSTRAINTS} ${LANG_${lang}_IN_BINARY_CONSTRAINTS})
	if(lang_constraints)
			message("${lang} available, possible CONSTRAINTS:")
		foreach(cst IN LISTS lang_constraints)
			message("+ ${cst}")
		endforeach()
	else()
		message("${lang} available")
	endif()
else()
	message("${lang} not available")
endif()
endfunction(print_Language_Info)

########################################################################
######################## Platforms management ##########################
########################################################################

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
	file(APPEND ${file} "set(CURRENT_PLATFORM_BASE ${CURRENT_PLATFORM_BASE} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PLATFORM_INSTANCE ${CURRENT_PLATFORM_INSTANCE} CACHE INTERNAL \"\" FORCE)\n")

	file(APPEND ${file} "set(CURRENT_PACKAGE_STRING ${CURRENT_PACKAGE_STRING} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_DISTRIBUTION ${CURRENT_DISTRIBUTION} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_DISTRIBUTION_VERSION ${CURRENT_DISTRIBUTION_VERSION} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(PID_KNOWN_PACKAGING_SYSTEMS ${PID_KNOWN_PACKAGING_SYSTEMS} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PACKAGING_SYSTEM ${CURRENT_PACKAGING_SYSTEM} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PACKAGING_SYSTEM_EXE ${CURRENT_PACKAGING_SYSTEM_EXE} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PACKAGING_SYSTEM_FORCE_NON_ROOT_USER ${CURRENT_PACKAGING_SYSTEM_FORCE_NON_ROOT_USER} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS ${CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PACKAGING_SYSTEM_EXE_UPDATE_OPTIONS ${CURRENT_PACKAGING_SYSTEM_EXE_UPDATE_OPTIONS} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PACKAGING_SYSTEM_EXE_UPGRADE_OPTIONS ${CURRENT_PACKAGING_SYSTEM_EXE_UPGRADE_OPTIONS} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PLATFORM_TYPE ${CURRENT_PLATFORM_TYPE} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PLATFORM_ARCH ${CURRENT_PLATFORM_ARCH} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_SPECIFIC_INSTRUCTION_SET ${CURRENT_SPECIFIC_INSTRUCTION_SET} CACHE INTERNAL \"\" FORCE)\n")
	foreach(instruction_set IN LISTS CURRENT_SPECIFIC_INSTRUCTION_SET)
		file(APPEND ${file} "set(CPU_${instruction_set}_FLAGS ${CPU_${instruction_set}_FLAGS} CACHE INTERNAL \"\" FORCE)\n")
	endforeach()
	file(APPEND ${file} "set(CURRENT_PLATFORM_OS ${CURRENT_PLATFORM_OS} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PLATFORM_ABI ${CURRENT_PLATFORM_ABI} CACHE INTERNAL \"\" FORCE)\n")

	#default install path used for that platform
	file(APPEND ${file} "set(PACKAGE_BINARY_INSTALL_DIR ${PACKAGE_BINARY_INSTALL_DIR} CACHE INTERNAL \"\" FORCE)\n")

	if(CURRENT_ENVIRONMENT)
		file(APPEND ${file} "set(CURRENT_ENVIRONMENT ${CURRENT_ENVIRONMENT} CACHE INTERNAL \"\" FORCE)\n")
	else()
		file(APPEND ${file} "set(CURRENT_ENVIRONMENT host CACHE INTERNAL \"\" FORCE)\n")
	endif()
	# managing abi related variables, used to check for binary compatibility
	file(APPEND ${file} "set(CMAKE_INTERNAL_PLATFORM_ABI ${CMAKE_INTERNAL_PLATFORM_ABI} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_C_COMPILER ${CURRENT_C_COMPILER} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(C_STANDARD_LIBRARIES ${C_STANDARD_LIBRARIES} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(C_STD_SYMBOLS ${C_STD_SYMBOLS} CACHE INTERNAL \"\" FORCE)\n")

	file(APPEND ${file} "set(CURRENT_CXX_ABI ${CURRENT_CXX_ABI} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_CXX_COMPILER ${CURRENT_CXX_COMPILER} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_CXX_COMPILER_WARN_MORE_OPTIONS ${CURRENT_CXX_COMPILER_WARN_MORE_OPTIONS} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_CXX_COMPILER_WARN_ALL_OPTIONS ${CURRENT_CXX_COMPILER_WARN_ALL_OPTIONS} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_CXX_COMPILER_WARN_AS_ERRORS_OPTIONS ${CURRENT_CXX_COMPILER_WARN_AS_ERRORS_OPTIONS} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CXX_STANDARD_LIBRARIES ${CXX_STANDARD_LIBRARIES} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CXX_STD_SYMBOLS ${CXX_STD_SYMBOLS} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CXX_STD_LIBRARY_VERSION ${CXX_STD_LIBRARY_VERSION} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CXX_STD_LIBRARY_NAME ${CXX_STD_LIBRARY_NAME} CACHE INTERNAL \"\" FORCE)\n")

	file(APPEND ${file} "set(CURRENT_ASM_COMPILER ${CURRENT_ASM_COMPILER} CACHE INTERNAL \"\" FORCE)\n")

	file(APPEND ${file} "set(ASM_Language_AVAILABLE ${ASM_Language_AVAILABLE} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(C_Language_AVAILABLE ${C_Language_AVAILABLE} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CXX_Language_AVAILABLE ${CXX_Language_AVAILABLE} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(Python_Language_AVAILABLE ${Python_Language_AVAILABLE} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(Fortran_Language_AVAILABLE ${Fortran_Language_AVAILABLE} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CUDA_Language_AVAILABLE ${CUDA_Language_AVAILABLE} CACHE INTERNAL \"\" FORCE)\n")
	if(Fortran_Language_AVAILABLE)
		file(APPEND ${file} "set(Fortran_STANDARD_LIBRARIES ${Fortran_STANDARD_LIBRARIES} CACHE INTERNAL \"\" FORCE)\n")
		file(APPEND ${file} "set(Fortran_STD_SYMBOLS ${Fortran_STD_SYMBOLS} CACHE INTERNAL \"\" FORCE)\n")
	endif()
	if(CUDA_Language_AVAILABLE)
		file(APPEND ${file} "set(CUDA_STANDARD_LIBRARIES ${CUDA_STANDARD_LIBRARIES} CACHE INTERNAL \"\" FORCE)\n")
		file(APPEND ${file} "set(CUDA_STD_SYMBOLS ${CUDA_STD_SYMBOLS} CACHE INTERNAL \"\" FORCE)\n")
		foreach(symbol IN LISTS CUDA_STD_SYMBOLS)
			file(APPEND ${file} "set(CUDA_STD_SYMBOL_${symbol}_VERSION ${CUDA_STD_SYMBOL_${symbol}_VERSION} CACHE INTERNAL \"\" FORCE)\n")
		endforeach()
	endif()
	#managing python
	file(APPEND ${file} "set(CURRENT_PYTHON ${CURRENT_PYTHON} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(Python_STANDARD_LIBRARIES ${Python_STANDARD_LIBRARIES} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PYTHON_EXECUTABLE ${CURRENT_PYTHON_EXECUTABLE} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PYTHON_LIBRARIES ${CURRENT_PYTHON_LIBRARIES} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PYTHON_INCLUDE_DIRS ${CURRENT_PYTHON_INCLUDE_DIRS} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PYTHON_PACKAGER ${CURRENT_PYTHON_PACKAGER} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PYTHON_PACKAGER_EXE ${CURRENT_PYTHON_PACKAGER_EXE} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CURRENT_PYTHON_PACKAGER_EXE_OPTIONS ${CURRENT_PYTHON_PACKAGER_EXE_OPTIONS} CACHE INTERNAL \"\" FORCE)\n")


	#adding information about known compilers
	foreach(lang IN ITEMS C CXX Fortran CUDA ASM)
		if(KNOWN_${lang}_COMPILERS AND KNOWN_${lang}_STANDARDS AND KNOWN_${lang}_STDLIBS)
			file(APPEND ${file} "set(KNOWN_${lang}_COMPILERS ${KNOWN_${lang}_COMPILERS} CACHE INTERNAL \"\" FORCE)\n")
			file(APPEND ${file} "set(KNOWN_${lang}_STANDARDS ${KNOWN_${lang}_STANDARDS} CACHE INTERNAL  \"\" FORCE)\n")
			file(APPEND ${file} "set(KNOWN_${lang}_STDLIBS ${KNOWN_${lang}_STDLIBS} CACHE INTERNAL  \"\" FORCE)\n")
			foreach(compiler IN LISTS KNOWN_${lang}_COMPILERS)
				foreach(std IN LISTS KNOWN_${lang}_STANDARDS)
					file(APPEND ${file} "set(${compiler}_std${std}_BEGIN_SUPPORT ${${compiler}_std${std}_BEGIN_SUPPORT} CACHE INTERNAL  \"\" FORCE)\n")

				endforeach()
				if(${compiler}_PREFERRED_ENVIRONMENT)
					file(APPEND ${file} "set(${compiler}_PREFERRED_ENVIRONMENT ${${compiler}_PREFERRED_ENVIRONMENT} CACHE INTERNAL  \"\" FORCE)\n")
				endif()
			endforeach()
			foreach(lib IN LISTS KNOWN_${lang}_STDLIBS)
				foreach(std IN LISTS KNOWN_${lang}_STANDARDS)
					file(APPEND ${file} "set(${lib}_std${std}_BEGIN_SUPPORT ${${lib}_std${std}_BEGIN_SUPPORT} CACHE INTERNAL  \"\" FORCE)\n")
				endforeach()
			endforeach()
		endif()
	endforeach()
endfunction(write_Platform_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Workspace_Global_Info_File| replace:: ``write_Workspace_Global_Info_File``
#  .. _write_Workspace_Global_Info_File:
#
#  write_Workspace_Global_Info_File
#  --------------------------------
#
#   .. command:: write_Workspace_Global_Info_File(file)
#
#     (Re)Writing to a given file the workspace CMake options.
#
#      :file: the path to the file to write in.
#
function(write_Workspace_Global_Info_File file)
	#managing CI
	file(WRITE ${file} "set(IN_CI_PROCESS ${IN_CI_PROCESS} CACHE INTERNAL \"\" FORCE)\n")
	#managing user specific constraints
	separate_arguments(LIMITED_JOBS_PACKAGES)
	file(APPEND ${file} "set(LIMITED_JOBS_PACKAGES ${LIMITED_JOBS_PACKAGES} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(FORCE_DUAL_MODE ${FORCE_DUAL_MODE} CACHE INTERNAL \"\" FORCE)\n")
	#managing crosscompilation
	file(APPEND ${file} "set(PID_CROSSCOMPILATION ${PID_CROSSCOMPILATION} CACHE INTERNAL \"\" FORCE)\n")
endfunction(write_Workspace_Global_Info_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_CMake_Info| replace:: ``write_CMake_Info``
#  .. _write_CMake_Info:
#
#  write_CMake_Info
#  -----------------
#
#   .. command:: write_CMake_Info(file)
#
#     (Re)Writing to a given file the cache variables of the workspace defining global info related to PID and CMake.
#
#      :file: the path to the file to write in.
#
function(write_CMake_Info file)
	#store the PID module path
	file(WRITE ${file} "set(CMAKE_MODULE_PATH \"${CMAKE_MODULE_PATH}\" CACHE INTERNAL \"\" FORCE)\n")
	# store the CMake generator
	file(APPEND ${file} "set(CMAKE_MAKE_PROGRAM \"${CMAKE_MAKE_PROGRAM}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_GENERATOR \"${CMAKE_GENERATOR}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_EXTRA_GENERATOR \"${CMAKE_EXTRA_GENERATOR}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_GENERATOR_TOOLSET \"${CMAKE_GENERATOR_TOOLSET}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_GENERATOR_PLATFORM \"${CMAKE_GENERATOR_PLATFORM}\" CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_GENERATOR_INSTANCE \"${CMAKE_GENERATOR_INSTANCE}\" CACHE INTERNAL \"\" FORCE)\n")
endfunction(write_CMake_Info)

#.rst:
#
# .. ifmode:: internal
#
#  .. |write_Contribution_Spaces| replace:: ``write_Contribution_Spaces``
#  .. _write_Contribution_Spaces:
#
#  write_Contribution_Spaces
#  --------------------------
#
#   .. command:: write_Contribution_Spaces(file)
#
#     (Re)Writing to a given file the cache variables of the workspace defining the contribution spaces in use.
#
#      :file: the path to the file to write in.
#
function(write_Contribution_Spaces file)
	file(WRITE ${file} "")#reset the file
	#managing contributions
	file(APPEND ${file} "set(CONTRIBUTION_SPACES ${CONTRIBUTION_SPACES} CACHE INTERNAL \"\" FORCE)\n")
	foreach(cs IN LISTS CONTRIBUTION_SPACES)
		file(APPEND ${file} "set(CONTRIBUTION_SPACE_${cs}_UPDATE_REMOTE ${CONTRIBUTION_SPACE_${cs}_UPDATE_REMOTE} CACHE INTERNAL \"\" FORCE)\n")
		file(APPEND ${file} "set(CONTRIBUTION_SPACE_${cs}_PUBLISH_REMOTE ${CONTRIBUTION_SPACE_${cs}_PUBLISH_REMOTE} CACHE INTERNAL \"\" FORCE)\n")
	endforeach()
	file(APPEND ${file} "set(PID_WORKSPACE_MODULES_PATH \"${PID_WORKSPACE_MODULES_PATH}\" CACHE INTERNAL \"\" FORCE)\n")
endfunction(write_Contribution_Spaces)

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
# defining all build configuration variables related to the current platform
write_Current_Configuration_Build_Related_Variables(${CMAKE_BINARY_DIR}/Workspace_Build_Info.cmake)
file(APPEND ${file} "include(${CMAKE_BINARY_DIR}/Workspace_Build_Info.cmake NO_POLICY_SCOPE)\n")
# defining all build configuration variables related to the current platform
file(APPEND ${file} "include(${CMAKE_BINARY_DIR}/Workspace_Solution_File.cmake NO_POLICY_SCOPE)\n")
write_CMake_Info(${CMAKE_BINARY_DIR}/Workspace_CMake_Info.cmake)
file(APPEND ${file} "include(${WORKSPACE_DIR}/build/Workspace_Global_Info.cmake NO_POLICY_SCOPE)\n")
file(APPEND ${file} "include(${CMAKE_BINARY_DIR}/Workspace_CMake_Info.cmake NO_POLICY_SCOPE)\n")
endfunction(write_Current_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Migrations| replace:: ``manage_Migrations``
#  .. _manage_Migrations:
#
#  manage_Migrations
#  -----------------
#
#   .. command:: manage_Migrations()
#
#     Manage a migration from an old workspace to a new one.
#     Note: transition to PID v4 removes the external folder
#
function(manage_Migrations)
#To PID V4
if((EXISTS ${WORKSPACE_DIR}/configurations AND IS_DIRECTORY ${WORKSPACE_DIR}/configurations)
		OR (EXISTS ${WORKSPACE_DIR}/external AND IS_DIRECTORY ${WORKSPACE_DIR}/external))
		message(WARNING "[PID] Your are migrating your workspace to PID version 4 or greater. Workspace subfolders configurations and external will be removed. Currenlty installed packages will be removed. You will need to rebuild install the content of your local workspace.")
endif()
# All previously existing configurations are now wrappers referenced in official pid contribution space
if(EXISTS ${WORKSPACE_DIR}/configurations AND IS_DIRECTORY ${WORKSPACE_DIR}/configurations)
	file(REMOVE_RECURSE ${WORKSPACE_DIR}/configurations)
endif()#simply remove all configurations as they are provided using wrappers.
file(GLOB installed_native ${WORKSPACE_DIR}/install/*)
foreach(platform IN LISTS installed_native)#removing all packages
	file(REMOVE_RECURSE ${platform})
endforeach()
file(REMOVE_RECURSE ${WORKSPACE_DIR}/external)#removing all existing installed external packages
endfunction(manage_Migrations)




#.rst:
#
# .. ifmode:: internal
#
#  .. |reevaluate_Host_Default_Platform| replace:: ``reevaluate_Host_Default_Platform``
#  .. _reevaluate_Host_Default_Platform:
#
#  reevaluate_Host_Default_Platform
#  ---------------------------------
#
#   .. command:: reevaluate_Host_Default_Platform()
#
#     force reevalaution of host default platform to get correct build variables
#
function(reevaluate_Host_Default_Platform)
	set(host_config_folder ${WORKSPACE_DIR}/build/host)
	if(NOT EXISTS ${host_config_folder})
		file(MAKE_DIRECTORY ${host_config_folder})
	endif()
	check_Host_Configuration_Evaluated_In_Current_Process(ALREADY_EVALUATED)
	if(NOT ALREADY_EVALUATED)
		execute_process(COMMAND ${CMAKE_COMMAND} -S ${WORKSPACE_DIR} -B ${WORKSPACE_DIR}/build/host
						-DADDITIONAL_DEBUG_INFO=${ADDITIONAL_DEBUG_INFO}
						-DWORKSPACE_DIR=${WORKSPACE_DIR}
						WORKING_DIRECTORY ${WORKSPACE_DIR}/build/host)
		set_Host_Configuration_Evaluated_In_Current_Process()
	endif()
endfunction(reevaluate_Host_Default_Platform)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Host_Default_Platform| replace:: ``manage_Host_Default_Platform``
#  .. _manage_Host_Default_Platform:
#
#  manage_Host_Default_Platform
#  ----------------------------
#
#   .. command:: manage_Host_Default_Platform()
#
#     Define the current configuration of the host.
#
function(manage_Host_Default_Platform)
# detecting which platform is in use according to environment description
detect_Current_Platform()
write_Platform_Description(${WORKSPACE_DIR}/build/host/Workspace_Platforms_Description.cmake)
# defining all build configuration variables related to the current platform
write_Current_Configuration_Build_Related_Variables(${WORKSPACE_DIR}/build/host/Workspace_Build_Info.cmake)
# defining all build configuration variables related to the current platform
write_CMake_Info(${WORKSPACE_DIR}/build/host/Workspace_CMake_Info.cmake)
endfunction(manage_Host_Default_Platform)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Host_Default_Platform| replace:: ``get_Host_Default_Platform``
#  .. _get_Host_Default_Platform:
#
#  get_Host_Default_Platform
#  ----------------------------
#
#   .. command:: get_Host_Default_Platform()
#
#     Get the current configuration of the host.
#
function(get_Host_Default_Platform)

set(wpd_file ${WORKSPACE_DIR}/build/host/Workspace_Platforms_Description.cmake)
set(wbi_file ${WORKSPACE_DIR}/build/host/Workspace_Build_Info.cmake)
set(wci_file ${WORKSPACE_DIR}/build/host/Workspace_CMake_Info.cmake)
if(EXISTS ${wpd_file} AND  EXISTS ${wbi_file} AND EXISTS ${wci_file})
	include(${wpd_file})
	include(${wbi_file})
	include(${wci_file})
endif()
endfunction(get_Host_Default_Platform)




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
#   .. command:: manage_Platforms()
#
#     Define the current platform in use and provide to the user some options to control finally targetted platform.
#
function(manage_Platforms)
if(NOT PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT STREQUAL "host")#need to reevaluate the main environment if profile is not haost default
	hashcode_From_Expression(ENV_NAME ENV_HASH ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT})
	set(prefix ${ENV_NAME}_${ENV_HASH})

	set(PID_USE_INSTANCE_NAME ${${prefix}_TARGET_INSTANCE} CACHE INTERNAL "" FORCE)
	set(PID_USE_DISTRIBUTION ${${prefix}_TARGET_DISTRIBUTION} CACHE INTERNAL "" FORCE)
	set(PID_USE_DISTRIB_VERSION ${${prefix}_TARGET_DISTRIBUTION_VERSION} CACHE INTERNAL "" FORCE)
	if(${prefix}_CROSSCOMPILATION)
	  set(PID_CROSSCOMPILATION TRUE CACHE INTERNAL "" FORCE)
	else()
		set(PID_CROSSCOMPILATION FALSE CACHE INTERNAL "" FORCE)
	endif()
else()
	set(default_env_name host)
	# by definition host environment never allows for crosscompilation
	set(PID_CROSSCOMPILATION FALSE CACHE INTERNAL "" FORCE)
	# host is never evaluated directly, so we need to get information directly from profile

	set(PID_USE_INSTANCE_NAME ${PROFILE_${CURRENT_PROFILE}_TARGET_INSTANCE} CACHE INTERNAL "" FORCE)
	set(PID_USE_DISTRIBUTION ${PROFILE_${CURRENT_PROFILE}_TARGET_DISTRIBUTION} CACHE INTERNAL "" FORCE)
	set(PID_USE_DISTRIB_VERSION ${PROFILE_${CURRENT_PROFILE}_TARGET_DISTRIBUTION_VERSION} CACHE INTERNAL "" FORCE)
endif()
	# include(${dir}/Workspace_Solution_File.cmake)#use the solution file to set global variables

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER) # during local profile evaluation, program MUST be in host system
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE NEVER) # during local profile evaluation, packages MUST be found in host system

if(PID_CROSSCOMPILATION)
	#when cross compiling all artefacts must be found in sysroot including programs
	#those programs like compiler or interpreters that are not in sysroot must have been defined by environment in use
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
else()
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER)
endif()
# detecting which platform is in use according to environment description
detect_Current_Platform()

# generate the platform description file used for user reporting
write_Platform_Reporting_File(${CMAKE_BINARY_DIR}/Platform_Description.txt)

# generate the current platform configuration file (that will be used to build packages)
write_Current_Configuration(${CMAKE_BINARY_DIR}/Workspace_Info.cmake)

endfunction(manage_Platforms)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Backward_Compatibility_Symlinks| replace:: ``create_Backward_Compatibility_Symlinks``
#  .. create_Backward_Compatibility_Symlinks:
#
#  create_Backward_Compatibility_Symlinks
#  --------------------------------------
#
#   .. command:: create_Backward_Compatibility_Symlinks()
#
#     Creates the share/cmake -> cmake and cmake/system -> cmake for backward compatibility
#     with PID versions < 4
#
function(create_Backward_Compatibility_Symlinks)
	if(EXISTS ${CMAKE_SOURCE_DIR}/share/cmake)
		file(REMOVE ${CMAKE_SOURCE_DIR}/share/cmake )
	endif()
	if(EXISTS ${CMAKE_SOURCE_DIR}/cmake/system)
		file(REMOVE ${CMAKE_SOURCE_DIR}/cmake/system )
	endif()
	#generate the symlinks
	create_Symlink(${CMAKE_SOURCE_DIR}/cmake ${CMAKE_SOURCE_DIR}/share/cmake)
	create_Symlink(${CMAKE_SOURCE_DIR}/cmake ${CMAKE_SOURCE_DIR}/cmake/system)
endfunction(create_Backward_Compatibility_Symlinks)

function(generate_Host_Toolchain_File)
  set(description_file ${CMAKE_BINARY_DIR}/PID_Toolchain.cmake)
  file(WRITE ${description_file} "")

  # setting the generator prroperties
  if(CMAKE_GENERATOR_INSTANCE)#use default instance if there is one defined
    file(APPEND ${description_file} "set(CMAKE_GENERATOR_INSTANCE ${CMAKE_GENERATOR_INSTANCE} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_GENERATOR_TOOLSET)#use targetted generator toolset if any
    file(APPEND ${description_file} "set(CMAKE_GENERATOR_TOOLSET ${${PROJECT_NAME}_GENERATOR_TOOLSET} CACHE INTERNAL \"\" FORCE)\n")
  elseif(CMAKE_GENERATOR_TOOLSET)# otherwise use default toolset if there is one defined
    file(APPEND ${description_file} "set(CMAKE_GENERATOR_TOOLSET ${CMAKE_GENERATOR_TOOLSET} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_GENERATOR_PLATFORM)
    file(APPEND ${description_file} "set(CMAKE_GENERATOR_PLATFORM ${${PROJECT_NAME}_GENERATOR_PLATFORM} CACHE INTERNAL \"\" FORCE)\n")
  elseif(CMAKE_GENERATOR_PLATFORM)#use default platform if there is one defined
    file(APPEND ${description_file} "set(CMAKE_GENERATOR_PLATFORM ${CMAKE_GENERATOR_PLATFORM} CACHE INTERNAL \"\" FORCE)\n")
  endif()

  if(${PROJECT_NAME}_CROSSCOMPILATION)
    #when cross compiling need to set target system name and processor
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_NAME ${${PROJECT_NAME}_TARGET_SYSTEM_NAME} CACHE INTERNAL \"\" FORCE)\n")
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_PROCESSOR ${${PROJECT_NAME}_TARGET_SYSTEM_PROCESSOR} CACHE INTERNAL \"\" FORCE)\n")
    if(NOT ${PROJECT_NAME}_TARGET_SYSTEM_NAME STREQUAL Generic) # cas where there is a kernel in use (e.g. building for microcontrollers)
      #we need a sysroot to the target operating system filesystem ! => defined by user !!
      if(NOT ${PROJECT_NAME}_TARGET_SYSROOT)#sysroot is necessary when cross compiling to another OS
        message(FATAL_ERROR "[PID] CRITICAL ERROR: you must give a sysroot by using the sysroot argument when calling build command.")
      endif()
      file(APPEND ${description_file} "set(CMAKE_SYSROOT ${${PROJECT_NAME}_TARGET_SYSROOT} CACHE INTERNAL \"\" FORCE)\n")
      if(${PROJECT_NAME}_TARGET_STAGING)
        file(APPEND ${description_file} "set(CMAKE_STAGING_PREFIX ${${PROJECT_NAME}_TARGET_STAGING} CACHE INTERNAL \"\" FORCE)\n")
      endif()
    endif()
    #add specific information from what cannot be deduced when cross compiling
    if(NOT ${PROJECT_NAME}_ABI_CONSTRAINT)#c++ standard library abi in use
      message("[PID] WARNING: you should give an abi constraint in ${PROJECT_NAME}. Using compiler default ABI as default.")
    endif()
    if(${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT)#c++ standard library abi in use
      file(APPEND ${description_file} "set(PID_USE_DISTRIBUTION ${${PROJECT_NAME}_DISTRIBUTION_CONSTRAINT} CACHE INTERNAL \"\" FORCE)\n")
    endif()
    if(${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT)#c++ standard library abi in use
      file(APPEND ${description_file} "set(PID_USE_DISTRIB_VERSION ${${PROJECT_NAME}_DISTRIB_VERSION_CONSTRAINT} CACHE INTERNAL \"\" FORCE)\n")
    endif()
  endif()

  # add build tools variables  to the toolset
  #manage languages directly managed at workspace level (CMake managed languages)
  foreach(lang IN ITEMS C CXX ASM Fortran Python CUDA)
    if(NOT ${PROJECT_NAME}_${lang}_TOOLSETS OR ${PROJECT_NAME}_${lang}_TOOLSETS LESS 1)
      continue()#simply do not manage the language
    endif()
    set(prefix ${PROJECT_NAME}_${lang}_TOOLSET_0)
    if(lang STREQUAL "Python")
      file(APPEND ${description_file} "set(PYTHON_EXECUTABLE ${${prefix}_INTERPRETER} CACHE INTERNAL \"\" FORCE)\n")
      if(${prefix}_INCLUDE_DIRS)
        fill_String_From_List(LANG_FLAGS ${prefix}_INCLUDE_DIRS " ")
        file(APPEND ${description_file} "set(PYTHON_INCLUDE_DIRS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
      endif()
      if(${prefix}_LIBRARY)
        file(APPEND ${description_file} "set(PYTHON_LIBRARY ${${prefix}_LIBRARY} CACHE INTERNAL \"\" FORCE)\n")
      endif()
    elseif(${prefix}_COMPILER) #other languages are compiled by default so to be managed a compiler must be defined
      #add the default command for setting compiler anytime
      file(APPEND ${description_file} "set(CMAKE_${lang}_COMPILER ${${prefix}_COMPILER} CACHE INTERNAL \"\" FORCE)\n")

      if(${prefix}_COMPILER_FLAGS)
        fill_String_From_List(LANG_FLAGS ${prefix}_COMPILER_FLAGS " ")
        file(APPEND ${description_file} "set(CMAKE_${lang}_FLAGS  \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
      endif()
      if(${prefix}_LIBRARY)#if standard libraries sonames are given
        file(APPEND ${description_file} "set(PID_USE_${lang}_STANDARD_LIBRARIES ${${prefix}_LIBRARY} CACHE INTERNAL \"\" FORCE)\n")
      endif()
      if(${prefix}_COVERAGE)#if standard libraries sonames are given
        file(APPEND ${description_file} "set(PID_USE_${lang}_COVERAGE ${${prefix}_COVERAGE} CACHE INTERNAL \"\" FORCE)\n")
      endif()
      if(lang MATCHES "CUDA")#for CUDA also set the old variables for compiler info
        file(APPEND ${description_file} "set(CUDA_NVCC_EXECUTABLE ${${prefix}_COMPILER} CACHE INTERNAL \"\" FORCE)\n")
        if(${prefix}_COMPILER_FLAGS)
          fill_String_From_List(LANG_FLAGS ${prefix}_COMPILER_FLAGS " ")
          file(APPEND ${description_file} "set(CUDA_NVCC_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
        endif()
        if(${prefix}_HOST_COMPILER)
          file(APPEND ${description_file} "set(CUDA_HOST_COMPILER ${${prefix}_HOST_COMPILER} CACHE INTERNAL \"\" FORCE)\n")
          file(APPEND ${description_file} "set(CMAKE_CUDA_HOST_COMPILER ${${prefix}_HOST_COMPILER} CACHE INTERNAL \"\" FORCE)\n")#also set the CMake supported language variable
        endif()
      else()
        if(${prefix}_COMPILER_AR)
          file(APPEND ${description_file} "set(CMAKE_${lang}_COMPILER_AR ${${prefix}_COMPILER_AR} CACHE INTERNAL \"\" FORCE)\n")
        endif()
        if(${prefix}_COMPILER_RANLIB)
          file(APPEND ${description_file} "set(CMAKE_${lang}_COMPILER_RANLIB ${${prefix}_COMPILER_RANLIB} CACHE INTERNAL \"\" FORCE)\n")
        endif()
      endif()
    endif()
  endforeach()

  if(${PROJECT_NAME}_LINKER)
    file(APPEND ${description_file} "set(CMAKE_LINKER ${${PROJECT_NAME}_LINKER} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_EXE_LINKER_FLAGS)
    fill_String_From_List(LANG_FLAGS ${PROJECT_NAME}_EXE_LINKER_FLAGS " ")
    file(APPEND ${description_file} "set(CMAKE_EXE_LINKER_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_MODULE_LINKER_FLAGS)
    fill_String_From_List(LANG_FLAGS ${PROJECT_NAME}_MODULE_LINKER_FLAGS " ")
    file(APPEND ${description_file} "set(CMAKE_MODULE_LINKER_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_SHARED_LINKER_FLAGS)
    fill_String_From_List(LANG_FLAGS ${PROJECT_NAME}_SHARED_LINKER_FLAGS " ")
    file(APPEND ${description_file} "set(CMAKE_SHARED_LINKER_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_STATIC_LINKER_FLAGS)
    fill_String_From_List(LANG_FLAGS ${PROJECT_NAME}_STATIC_LINKER_FLAGS " ")
    file(APPEND ${description_file} "set(CMAKE_STATIC_LINKER_FLAGS \"${LANG_FLAGS}\" CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_LIBRARY_DIRS)
    fill_String_From_List(DIRS ${PROJECT_NAME}_LIBRARY_DIRS " ")
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_LIBRARY_PATH ${DIRS} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_INCLUDE_DIRS)
    fill_String_From_List(DIRS ${PROJECT_NAME}_INCLUDE_DIRS " ")
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_INCLUDE_PATH ${DIRS} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_PROGRAM_DIRS)
    fill_String_From_List(DIRS ${PROJECT_NAME}_PROGRAM_DIRS " ")
    file(APPEND ${description_file} "set(CMAKE_SYSTEM_PROGRAM_PATH ${DIRS} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_AR)
    file(APPEND ${description_file} "set(CMAKE_AR ${${PROJECT_NAME}_AR} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_RANLIB)
    file(APPEND ${description_file} "set(CMAKE_RANLIB ${${PROJECT_NAME}_RANLIB} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_NM)
    file(APPEND ${description_file} "set(CMAKE_NM ${${PROJECT_NAME}_NM} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_OBJDUMP)
    file(APPEND ${description_file} "set(CMAKE_OBJDUMP ${${PROJECT_NAME}_OBJDUMP} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_OBJCOPY)
    file(APPEND ${description_file} "set(CMAKE_OBJCOPY ${${PROJECT_NAME}_OBJCOPY} CACHE INTERNAL \"\" FORCE)\n")
  endif()
  if(${PROJECT_NAME}_RPATH)
    file(APPEND ${description_file} "set(PID_USE_RPATH_UTILITY ${${PROJECT_NAME}_RPATH} CACHE INTERNAL \"\" FORCE)\n")
  endif()

  if(${PROJECT_NAME}_CROSSCOMPILATION)
    # avoid problem with try_compile when cross compiling
    file(APPEND ${description_file} "set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY CACHE INTERNAL \"\" FORCE)\n")

  endif()

endfunction(generate_Host_Toolchain_File)
