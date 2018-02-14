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
include(PID_Package_Finding_Functions NO_POLICY_SCOPE)
include(PID_Package_Build_Targets_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Configuration_Functions NO_POLICY_SCOPE)
include(PID_Deployment_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
include(PID_Meta_Information_Management_Functions NO_POLICY_SCOPE)
include(External_Definition NO_POLICY_SCOPE) #to interpret content description of external packages

########################################################################
########## Categories (classification of packages) management ##########
########################################################################

### function used to classify all packages into categories. Usefull to prepare calls to info script.
function(classify_Packages)
#1) get the root of categories (cmake variables) where to start recursion of the classification process
extract_Root_Categories()
#2) classification of packages according to categories
if(ROOT_CATEGORIES)
	foreach(a_cat IN ITEMS ${ROOT_CATEGORIES})
		classify_Root_Category(${a_cat} "${ALL_PACKAGES}")
	endforeach()
endif()
#3) classification of packages according to categories defined in frameworks
if(FRAMEWORKS_CATEGORIES)
	foreach(a_framework IN ITEMS ${FRAMEWORKS_CATEGORIES})
		foreach(a_cat IN ITEMS ${FRAMEWORK_${a_framework}_ROOT_CATEGORIES})
			classify_Framework_Root_Category(${a_framework} ${a_cat} "${ALL_PACKAGES}")
		endforeach()
	endforeach()
endif()
endfunction(classify_Packages)

## subsidiary function to classify all packages according to categories,without taking into account frameworks information
function(classify_Root_Category root_category all_packages)
foreach(package IN ITEMS ${all_packages})
	foreach(a_category IN ITEMS ${${package}_CATEGORIES})
		classify_Category(${a_category} ${root_category} ${package})
	endforeach()
endforeach()
endfunction(classify_Root_Category)


## subsidiary function to classify all packages from a given framework into the categories defined by this framework. This results in creation of variables
function(classify_Framework_Root_Category framework root_category all_packages)
foreach(package IN ITEMS ${all_packages})
	if(${package}_FRAMEWORK STREQUAL "${framework}")#check if the package belongs to the framework
		foreach(a_category IN ITEMS ${${package}_CATEGORIES})
			list(FIND ${framework}_FRAMEWORK_CATEGORIES ${a_category} INDEX)
			if(NOT INDEX EQUAL -1)# this category is a category member of the framework
				classify_Framework_Category(${framework} ${a_category} ${root_category} ${package})
			endif()
		endforeach()
	endif()
endforeach()
endfunction(classify_Framework_Root_Category)


## subsidiary function to create variables that describe the organization of a given framework in terms of categories
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

### macro to reset variables containing workspace content information, according to reference files found in workspace (macro to keep the current scope, important for reference files inclusion)
macro(reset_Workspace_Content_Information)
# 1) fill the two root variables, by searching in all reference files lying in the workspace
set(ALL_AVAILABLE_PACKAGES)
set(ALL_AVAILABLE_FRAMEWORKS)
file(GLOB reference_files ${CMAKE_SOURCE_DIR}/share/cmake/references/Refer*.cmake)
foreach(a_ref_file IN ITEMS ${reference_files})# 2) including all reference files and memorizing packages and frameworks names
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

## subsidiary function to reset all variables describing categories to start from a clean situation
function(reset_All_Categories)
if(ROOT_CATEGORIES)
	foreach(a_category IN ITEMS ${ROOT_CATEGORIES})
		reset_Category(${a_category})
	endforeach()
	set(ROOT_CATEGORIES CACHE INTERNAL "")
endif()
if(FRAMEWORKS_CATEGORIES)
	foreach(a_framework IN ITEMS ${FRAMEWORKS_CATEGORIES})
		foreach(a_category IN ITEMS FRAMEWORK_${a_framework}_ROOT_CATEGORIES)
			reset_Framework_Category(${a_framework} ${a_category})
		endforeach()
	endforeach()
endif()
endfunction(reset_All_Categories)

## subsidiary function to reset all variables of a given category
function(reset_Category category)
if(CAT_${category}_CATEGORIES)
	foreach(a_sub_category IN ITEMS ${CAT_${category}_CATEGORIES})
		reset_Category("${category}/${a_sub_category}")#recursive call
	endforeach()
endif()
if(CAT_${category}_CATEGORY_CONTENT)
	set(CAT_${category}_CATEGORY_CONTENT CACHE INTERNAL "")
endif()
set(CAT_${category}_CATEGORIES CACHE INTERNAL "")
endfunction()


## subsidiary function to reset all variables of a given category
function(reset_Framework_Category framework category)
if(FRAMEWORK_${framework}_CAT_${category}_CATEGORIES)
	foreach(a_sub_category IN ITEMS ${FRAMEWORK_${framework}_CAT_${category}_CATEGORIES})
		reset_Framework_Category(${framework} "${category}/${a_sub_category}")#recursive call
	endforeach()
endif()
if(FRAMEWORK_${framework}_CAT_${category}_CATEGORY_CONTENT)
	set(FRAMEWORK_${framework}_CAT_${category}_CATEGORY_CONTENT CACHE INTERNAL "")
endif()
set(FRAMEWORK_${framework}_CAT_${category}_CATEGORIES CACHE INTERNAL "")
endfunction()

## subsidiary function to get the names of all the root categories to which belong a given package
function(get_Root_Categories package RETURNED_ROOTS)
	set(ROOTS_FOUND)
	foreach(a_category IN ITEMS ${${package}_CATEGORIES})
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


## subsidiary function to get the names of all the root categories defined by a framework
function(get_Framework_Root_Categories framework RETURNED_ROOTS)
	set(ROOTS_FOUND)
	foreach(a_category IN ITEMS ${${framework}_FRAMEWORK_CATEGORIES})
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

## subsidiary function for extracting root categories from workspace description. It consists in classifying all packages and frameworks relative to category structure.
function(extract_Root_Categories)
# extracting category information from packages
set(ALL_ROOTS)
foreach(a_package IN ITEMS ${ALL_PACKAGES})
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
foreach(a_framework IN ITEMS ${ALL_FRAMEWORKS})
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

### classifying all packages and frameworks according to categories structure
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

### write in a file that will be used by script for finding info on categories
function(write_Categories_File)
set(file ${CMAKE_BINARY_DIR}/CategoriesInfo.cmake)
file(WRITE ${file} "")
file(APPEND ${file} "######### declaration of workspace categories ########\n")
file(APPEND ${file} "set(ALL_PACKAGES \"${ALL_PACKAGES}\" CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(ALL_FRAMEWORKS \"${ALL_FRAMEWORKS}\" CACHE INTERNAL \"\")\n")

file(APPEND ${file} "set(ROOT_CATEGORIES \"${ROOT_CATEGORIES}\" CACHE INTERNAL \"\")\n")
foreach(root_cat IN ITEMS ${ROOT_CATEGORIES})
	write_Category_In_File(${root_cat} ${file})
endforeach()
file(APPEND ${file} "######### declaration of workspace categories classified by framework ########\n")
file(APPEND ${file} "set(FRAMEWORKS_CATEGORIES \"${FRAMEWORKS_CATEGORIES}\" CACHE INTERNAL \"\")\n")
if(FRAMEWORKS_CATEGORIES)
	foreach(framework IN ITEMS ${FRAMEWORKS_CATEGORIES})
		write_Framework_Root_Categories_In_File(${framework} ${file})
		foreach(root_cat IN ITEMS ${FRAMEWORK_${framework}_ROOT_CATEGORIES})
			write_Framework_Category_In_File(${framework} ${root_cat} ${file})
		endforeach()
	endforeach()
endif()
endfunction(write_Categories_File)

## subidiary function to write info about a given category into the file
function(write_Category_In_File category thefile)
file(APPEND ${thefile} "set(CAT_${category}_CATEGORY_CONTENT \"${CAT_${category}_CATEGORY_CONTENT}\" CACHE INTERNAL \"\")\n")
if(CAT_${category}_CATEGORIES)
	file(APPEND ${thefile} "set(CAT_${category}_CATEGORIES \"${CAT_${category}_CATEGORIES}\" CACHE INTERNAL \"\")\n")
	foreach(cat IN ITEMS ${CAT_${category}_CATEGORIES})
		write_Category_In_File("${category}/${cat}" ${thefile})
	endforeach()
endif()
endfunction(write_Category_In_File)


## subsidiary function to write info about root categories defined by a framework into the file
function(write_Framework_Root_Categories_In_File framework thefile)
file(APPEND ${thefile} "set(FRAMEWORK_${framework}_ROOT_CATEGORIES \"${FRAMEWORK_${framework}_ROOT_CATEGORIES}\" CACHE INTERNAL \"\")\n")
endfunction(write_Framework_Root_Categories_In_File)

## subsidiary function to write info about categories defined by a framework into the file
function(write_Framework_Category_In_File framework category thefile)
file(APPEND ${thefile} "set(FRAMEWORK_${framework}_CAT_${category}_CATEGORY_CONTENT \"${FRAMEWORK_${framework}_CAT_${category}_CATEGORY_CONTENT}\" CACHE INTERNAL \"\")\n")
if(FRAMEWORK_${framework}_CAT_${category}_CATEGORIES)
	file(APPEND ${thefile} "set(FRAMEWORK_${framework}_CAT_${category}_CATEGORIES \"${FRAMEWORK_${framework}_CAT_${category}_CATEGORIES}\" CACHE INTERNAL \"\")\n")
	foreach(cat IN ITEMS ${FRAMEWORK_${framework}_CAT_${category}_CATEGORIES})
		write_Framework_Category_In_File(${framework} "${category}/${cat}" ${thefile})
	endforeach()
endif()
endfunction(write_Framework_Category_In_File)

### function to find and print the sreached term in all (sub-)categories
function(find_In_Categories searched_category_term)
foreach(root_cat IN ITEMS ${ROOT_CATEGORIES})
	find_Category("" ${root_cat} ${searched_category_term})
endforeach()
endfunction(find_In_Categories)

## subsidiary function to print to standard output the "path" generated by a given category
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
		foreach(root_cat IN ITEMS ${CAT_${current_category_full_path}_CATEGORIES})
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
			foreach(root_cat IN ITEMS ${CAT_${current_category_full_path}_CATEGORIES})
				find_Category("${current_category_full_path}" "${current_category_full_path}/${root_cat}" ${searched_category})
			endforeach()
		endif()
	endif()
endif()
endfunction(find_Category)


## subsidiary function to print to standard output the "path" generated by category structure
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


## subsidiary function to print to standard output a description of a given category
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
		foreach(pack IN ITEMS ${CAT_${category}_CATEGORY_CONTENT})
			set(PRINTED_VALUE "${PRINTED_VALUE} ${pack}")
		endforeach()
		message("${PRINTED_VALUE}")
	else()
		set(PRINTED_VALUE "${RESULT_STRING}${short_name}")
		message("${PRINTED_VALUE}")
	endif()
	if(CAT_${category}_CATEGORIES)
		math(EXPR sub_cat_nb_tabs '${number_of_tabs}+1')
		foreach(sub_cat IN ITEMS ${CAT_${category}_CATEGORIES})
			print_Category("${long_name}" "${category}/${sub_cat}" ${sub_cat_nb_tabs})
		endforeach()
	endif()
endfunction(print_Category)


### subsidiary function to print to standard output a description of a given category defined by a framework
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
		foreach(pack IN ITEMS ${FRAMEWORK_${framework}_CAT_${category}_CATEGORY_CONTENT})
			set(PRINTED_VALUE "${PRINTED_VALUE} ${pack}")
		endforeach()
		message("${PRINTED_VALUE}")
	else()
		set(PRINTED_VALUE "${RESULT_STRING}${short_name}")
		message("${PRINTED_VALUE}")
	endif()
	if(FRAMEWORK_${framework}_CAT_${category}_CATEGORIES)#there are subcategories => recursion
		math(EXPR sub_cat_nb_tabs '${number_of_tabs}+1')
		foreach(sub_cat IN ITEMS ${FRAMEWORK_${framework}_CAT_${category}_CATEGORIES})
			print_Framework_Category(${framework} "${long_name}" "${category}/${sub_cat}" ${sub_cat_nb_tabs})
		endforeach()
	endif()
endfunction(print_Framework_Category)


## subsidiary function to print to standard output a description of all categories defined by a framework
function(print_Framework_Categories framework)
message("---------------------------------")
list(FIND FRAMEWORKS_CATEGORIES ${framework} INDEX)
if(INDEX EQUAL -1)
	message("Framework ${framework} has no category defined")
else()
	message("Packages of the ${framework} framework, by category:")
	foreach(a_cat IN ITEMS ${FRAMEWORK_${framework}_ROOT_CATEGORIES})
		print_Framework_Category(${framework} "" ${a_cat} 0)
	endforeach()
endif()
message("---------------------------------")
endfunction(print_Framework_Categories)

########################################################################
##################### Packages info management #########################
########################################################################

## subsidiary function to print information about an author
function(print_Author author)
	get_Formatted_Author_String("${author}" RES_STRING)
	message("	${RES_STRING}")
endfunction(print_Author)

## subsidiary function to print information about contact author
function(print_Package_Contact package)
	get_Formatted_Package_Contact_String(${package} RES_STRING)
	message("CONTACT: ${RES_STRING}")
endfunction(print_Package_Contact)

### function used to print a basic description of a native package to the standard output
function(print_Package_Info package)
	message("NATIVE PACKAGE: ${package}")
	fill_List_Into_String("${${package}_DESCRIPTION}" descr_string)
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
	foreach(author IN ITEMS ${${package}_AUTHORS_AND_INSTITUTIONS})
		print_Author(${author})
	endforeach()
	if(${package}_CATEGORIES)
		message("CATEGORIES:")
		foreach(category IN ITEMS ${${package}_CATEGORIES})
			message("	${category}")
		endforeach()
	endif()

	if(REFERENCES_OK)
		message("BINARY VERSIONS:")
		print_Package_Binaries(${package})
	endif()
endfunction(print_Package_Info)

### function used to print a basic description of an external package to the standard output
function(print_External_Package_Info package)
	message("EXTERNAL PACKAGE: ${package}")
	fill_List_Into_String("${${package}_DESCRIPTION}" descr_string)
	message("DESCRIPTION: ${descr_string}")
	message("LICENSES: ${${package}_LICENSES}")
	print_External_Package_Contact(${package})
	message("AUTHORS: ${${package}_AUTHORS}")
	if(${package}_CATEGORIES)
		message("CATEGORIES:")
		foreach(category IN ITEMS ${${package}_CATEGORIES})
			message("	${category}")
		endforeach()
	endif()
	load_Package_Binary_References(REFERENCES_OK ${package})
	if(REFERENCES_OK)
		message("BINARY VERSIONS:")
		print_Package_Binaries(${package})
	endif()
endfunction(print_External_Package_Info)

## subsidiary function to print information about contact author
function(print_External_Package_Contact package)
	fill_List_Into_String("${${package}_PID_WRAPPER_CONTACT_AUTHOR}" AUTHOR_STRING)
	fill_List_Into_String("${${package}_PID_WRAPPER_CONTACT_INSTITUTION}" INSTITUTION_STRING)
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


### Constraint: the reference file of the package must be loaded before thsi call.
## subsidiary function to print information about binary versions available for that package
function(print_Package_Binaries package)
	foreach(version IN ITEMS ${${package}_REFERENCES})
		message("	${version}: ")
		foreach(platform IN ITEMS ${${package}_REFERENCE_${version}})
			print_Platform_Compatible_Binary(${package} ${version} ${platform})
		endforeach()
	endforeach()
endfunction(print_Package_Binaries)

### Constraint: the binary references of the package must be loaded before this call.
## subsidiary function to check if a given version of the package exists
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


### Constraint: the binary references of the package must be loaded before this call.
## subsidiary function to check if a given version of the package exists
function(greatest_Version_Archive package RES_VERSION)
if(${package}_REFERENCES)
		get_Available_Binary_Package_Versions(${package} list_of_versions list_of_versions_with_platform)
		if(list_of_versions)
			set(curr_max_version 0.0.0)
			foreach(version IN ITEMS ${list_of_versions})
				if(version VERSION_GREATER curr_max_version)
					set(curr_max_version ${version})
				endif()
			endforeach()
			set(${RES_VERSION} ${curr_max_version} PARENT_SCOPE)
		endif()
endif()
endfunction(greatest_Version_Archive)

## subsidiary function to print all binaries of a package for a given platform
function(print_Platform_Compatible_Binary package version platform)
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


### function to print brief description of a framework
function(print_Framework_Info framework)
	message("FRAMEWORK: ${framework}")
	fill_List_Into_String("${${framework}_FRAMEWORK_DESCRIPTION}" descr_string)
	message("DESCRIPTION: ${descr_string}")
	message("WEB SITE: ${${framework}_FRAMEWORK_SITE}")
	message("LICENSE: ${${framework}_FRAMEWORK_LICENSE}")
	message("DATES: ${${framework}_FRAMEWORK_YEARS}")
	message("REPOSITORY: ${${framework}_FRAMEWORK_ADDRESS}")
	print_Package_Contact(${framework})
	message("AUTHORS:")
	foreach(author IN ITEMS ${${framework}_FRAMEWORK_AUTHORS_AND_INSTITUTIONS})
		print_Author(${author})
	endforeach()
	if(${framework}_FRAMEWORK_CATEGORIES)
		message("CATEGORIES:")
		foreach(category IN ITEMS ${${framework}_FRAMEWORK_CATEGORIES})
			message("	${category}")
		endforeach()
	endif()
endfunction(print_Framework_Info)

########################################################################
#################### Packages lifecycle management #####################
########################################################################

###
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


###
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

###
function(create_PID_Package package author institution license)
#copying the pattern folder into the package folder and renaming it
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/share/patterns/packages/package ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)

#setting variables
set(PACKAGE_NAME ${package})
if(author AND NOT author STREQUAL "")
	set(PACKAGE_AUTHOR_NAME "${author}")
else()
	set(PACKAGE_AUTHOR_NAME "$ENV{USER}")
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


### Installing a framework on the workspace filesystem from an existing framework repository, known in the workspace.
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


### Installing a package on the workspace filesystem from an existing package repository, known in the workspace. All its dependencies will be deployed, either has binary (if available) or has source (if not).
function(deploy_PID_Native_Package package version verbose can_use_source redeploy)
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

if("${version}" STREQUAL "")#no specific version required
	if(can_use_source)#this first step is only possible if sources can be used
		if(NOT REPOSITORY_IN_WORKSPACE)
			set(DEPLOYED FALSE)
			deploy_Package_Repository(DEPLOYED ${package})
			if(NOT DEPLOYED)
				message("[PID] ERROR : cannot deploy ${package} repository. Deployment aborted !")
				return()
			endif()
		endif()
		#now build the package
		set(INSTALLED FALSE)
		deploy_Source_Native_Package(INSTALLED ${package} "")
		if(NOT INSTALLED)
			message("[PID] ERROR : cannot build ${package} after cloning of its repository. Deployment aborted !")
			return()
		endif()
	endif()
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
		deploy_Source_Native_Package_Version(DEPLOYED ${package} ${version} TRUE "")
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


### Installing an external package binary on the workspace filesystem from an existing download point. Constraint: the reference file of the package must be loaded before thsi call.
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
		foreach(version_i IN ITEMS ${${package}_REFERENCES})
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

### Configuring the official remote repository of current wrapper
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

### Configuring the official remote repository of current package
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

### Configuring the official remote repository of current package
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

### reconnecting the origin BUT letting the official remote unchanged
function(add_Connection_To_PID_Package package git_url)
save_Repository_Context(INITIAL_COMMIT SAVED_CONTENT ${package}) # saving local repository state
change_Origin_Repository(${package} ${git_url} origin) # synchronizing with the remote "origin" git repository
restore_Repository_Context(${package} ${INITIAL_COMMIT} ${SAVED_CONTENT})# restoring local repository state
endfunction(add_Connection_To_PID_Package)


### reconnecting the origin BUT letting the official remote unchanged
function(add_Connection_To_PID_Framework framework git_url)
change_Origin_Framework_Repository(${framework} ${git_url} origin) # synchronizing with the remote "origin" git repository
endfunction(add_Connection_To_PID_Framework)

##################################################
###### clearing/removing deployment units ########
##################################################

### clearing consist in clearing a package version related folder from the workspace
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

### removing consists in clearing the workspace of any trace of the target package (including its source repository)
function(remove_PID_Package package)
get_System_Variables(PLATFORM_NAME PACKAGE_STRING)
#clearing install folder
if(	EXISTS ${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${package})
	clear_PID_Package(RES ${package} all)
endif()
#clearing source folder
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/packages/${package})
endfunction(remove_PID_Package)


###  removing consists in removing the git repository of the framework from the workspace
function(remove_PID_Framework framework)
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/sites/frameworks/${framework})
endfunction(remove_PID_Framework)


##################################################
############ registering deployment units ########
##################################################


### registering consists in updating the workspace repository with an updated reference file for this package
function(register_PID_Package package)
go_To_Workspace_Master()
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package}/build ${CMAKE_MAKE_PROGRAM} install)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package}/build ${CMAKE_MAKE_PROGRAM} referencing)
publish_Package_References_In_Workspace_Repository(${package})
endfunction(register_PID_Package)


### registering consists in updating the workspace repository with an updated reference file for this framework
function(register_PID_Framework framework)
go_To_Workspace_Master()
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework}/build ${CMAKE_MAKE_PROGRAM} build)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks/${framework}/build ${CMAKE_MAKE_PROGRAM} referencing)
publish_Framework_References_In_Workspace_Repository(${framework})
endfunction(register_PID_Framework)

##########################################
############ releasing packages ##########
##########################################


### releasing the package version => registering the current version with a git tag
function(release_PID_Package RESULT package next)
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
foreach(version IN ITEMS ${VERSION_NUMBERS})
	if(version STREQUAL "${STRING_NUMBER}")
		message("[PID] ERROR : cannot release version ${STRING_NUMBER} for package ${package}, because this version already exists.")
		return()
	endif()
endforeach()

# check that there are things to commit to master
check_For_New_Commits_To_Release(COMMITS_AVAILABLE ${package})
if(NOT COMMITS_AVAILABLE)
	message("[PID] ERROR : cannot release package ${package} because integration branch has no commits to contribute to new version.")
	return()
endif()

# check that version of dependencies exist
check_For_Dependencies_Version(BAD_VERSION_OF_DEPENDENCIES ${package})
if(BAD_VERSION_OF_DEPENDENCIES)
	message("[PID] ERROR : cannot release package ${package} because of invalid version of dependencies:")
	foreach(dep IN ITEMS ${BAD_VERSION_OF_DEPENDENCIES})
		extract_All_Words(${dep} "#" RES_LIST)#extract with # because this is the separator used in check_For_Dependencies_Version
		list(GET RES_LIST 0 DEP_PACKAGE)
		list(GET RES_LIST 1 DEP_VERSION)
		message("- dependency ${DEP_PACKAGE} has unknown version ${DEP_VERSION}")
	endforeach()
	return()
endif()

# check that integration is a fast forward of master
merge_Into_Master(MERGE_OK ${package} ${STRING_NUMBER})
if(NOT MERGE_OK)
	message("[PID] ERROR : cannot release package ${package}, because there are potential merge conflicts between master and integration branches. Please update ${package} integration branch first then launch again the release process.")
	go_To_Integration(${package}) #always go back to integration branch
	return()
endif()
publish_Repository_Version(${package} ${STRING_NUMBER} RESULT_OK)
if(NOT RESULT_OK) #the user has no sufficient push rights
	message("[PID] ERROR : cannot release package ${package}, because your are not allowed to push to its master branch !")
	go_To_Integration(${package}) #always go back to integration branch
	return()
endif()
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


### update a source package based on git tags of its repository
function(update_PID_Source_Package package)
get_System_Variables(PLATFORM_NAME PACKAGE_STRING)
set(INSTALLED FALSE)
message("[PID] INFO : launch the update of source package ${package}...")
list_Version_Subdirectories(version_dirs ${WORKSPACE_DIR}/install/${PLATFORM_NAME}/${package})
deploy_Source_Native_Package(INSTALLED ${package} "${version_dirs}")
if(NOT INSTALLED)
	message("[PID] ERROR : cannot update ${package}.")
else()
	message("[PID] INFO : package ${package} update finished.")
endif()
endfunction(update_PID_Source_Package)


### update a binary package based on available binary references
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

### update an external package based on available binary references
function(update_PID_External_Package package)
message("[PID] INFO : new versions of external binary package ${package} will not be installed automatically (only if a new version is required by native package)...")
endfunction(update_PID_External_Package)

### update all packages of the workspace
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
	foreach(package IN ITEMS ${SOURCE_PACKAGES})
		update_PID_Source_Package(${package})
	endforeach()
endif()
if(NATIVES)
	foreach(package IN ITEMS ${NATIVES})
		load_Package_Binary_References(REFERENCES_OK ${package})
		if(NOT REFERENCES_OK)
			message("[PID] WARNING : no binary reference exists for the package ${package}. Cannot update it ! Please contact the maintainer of package ${package} to have more information about this problem.")
		else()
			update_PID_Binary_Package(${package})
		endif()
	endforeach()
endif()
if(EXTERNALS)
	foreach(package IN ITEMS ${EXTERNALS})
		load_Package_Binary_References(REFERENCES_OK ${package})
		if(NOT REFERENCES_OK)
			message("[PID] WARNING : no binary reference exists for the package ${package}. Cannot update it ! Please contact the maintainer of package ${package} to have more information about this problem.")
		else()
			update_PID_External_Package(${package})
		endif()
	endforeach()
endif()
endfunction(update_PID_All_Packages)

### UPGRADE COMMAND IMPLEMENTATION
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

### print description on all available licenses
function(print_Available_Licenses)
file(GLOB ALL_AVAILABLE_LICENSES ${WORKSPACE_DIR}/share/cmake/licenses/*.cmake)
list(REMOVE_DUPLICATES ALL_AVAILABLE_LICENSES)
set(licenses "")
foreach(licensefile IN ITEMS ${ALL_AVAILABLE_LICENSES})
	get_filename_component(licensefilename ${licensefile} NAME)
	string(REGEX REPLACE "^License([^\\.]+)\\.cmake$" "\\1" a_license "${licensefilename}")
	if(NOT "${a_license}" STREQUAL "${licensefilename}")#it matches
		list(APPEND licenses ${a_license})
	endif()
endforeach()
set(res_licenses_string "")
fill_List_Into_String("${licenses}" res_licenses_string)
message("AVAILABLE LICENSES: ${res_licenses_string}")
endfunction()

### print description of a given license
function(print_License_Info license)
message("LICENSE: ${LICENSE_NAME}")
message("VERSION: ${LICENSE_VERSION}")
message("OFFICIAL NAME: ${LICENSE_FULLNAME}")
message("AUTHORS: ${LICENSE_AUTHORS}")
endfunction()


########################################################################
######################## Platforms management ##########################
########################################################################

## subsidiary function that puts into cmake variables the description of available platforms
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

## subsidiary function to append to a file the content of advanced options of CMAKE
function(write_Current_Configuration_Build_Related_Variables file)
file(WRITE ${file} "")
file(APPEND ${file} "set(CMAKE_AR ${CMAKE_AR} CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_CXX_COMPILER ${CMAKE_CXX_COMPILER} CACHE FILEPATH \"\" FORCE)\n")
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
file(APPEND ${file} "set(CMAKE_C_COMPILER ${CMAKE_C_COMPILER} CACHE FILEPATH \"\" FORCE)\n")
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
file(APPEND ${file} "set(CMAKE_LINKER ${CMAKE_LINKER} CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MAKE_PROGRAM ${CMAKE_MAKE_PROGRAM} CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MODULE_LINKER_FLAGS \"${CMAKE_MODULE_LINKER_FLAGS}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MODULE_LINKER_FLAGS_DEBUG \"${CMAKE_MODULE_LINKER_FLAGS_DEBUG}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL \"${CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MODULE_LINKER_FLAGS_RELEASE \"${CMAKE_MODULE_LINKER_FLAGS_RELEASE}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO \"${CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO}\" CACHE STRING \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_NM ${CMAKE_NM} CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_OBJCOPY ${CMAKE_OBJCOPY} CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_OBJDUMP ${CMAKE_OBJDUMP} CACHE FILEPATH \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_RANLIB ${CMAKE_RANLIB} CACHE FILEPATH \"\" FORCE)\n")
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
file(APPEND ${file} "set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_MAKE_PROGRAM \"${CMAKE_MAKE_PROGRAM}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_GENERATOR \"${CMAKE_GENERATOR}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_EXTRA_GENERATOR \"${CMAKE_EXTRA_GENERATOR}\" CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_GENERATOR_TOOLSET \"${CMAKE_GENERATOR_TOOLSET}\" CACHE INTERNAL \"\" FORCE)\n")

## system related
file(APPEND ${file} "set(CMAKE_FIND_LIBRARY_PREFIXES ${CMAKE_FIND_LIBRARY_PREFIXES} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SYSTEM_PREFIX_PATH ${CMAKE_SYSTEM_PREFIX_PATH} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_LIBRARY_ARCHITECTURE ${CMAKE_LIBRARY_ARCHITECTURE} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SYSTEM_PROGRAM_PATH ${CMAKE_SYSTEM_PROGRAM_PATH} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SYSTEM_INCLUDE_PATH ${CMAKE_SYSTEM_INCLUDE_PATH} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SYSTEM_LIBRARY_PATH ${CMAKE_SYSTEM_LIBRARY_PATH} CACHE INTERNAL \"\" FORCE)\n")

## compiler related
file(APPEND ${file} "set(CMAKE_COMPILER_IS_GNUCXX ${CMAKE_COMPILER_IS_GNUCXX} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_CXX_COMPILER_ID ${CMAKE_CXX_COMPILER_ID} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_CXX_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION} CACHE INTERNAL \"\" FORCE)\n")
file(APPEND ${file} "set(CMAKE_SIZEOF_VOID_P ${CMAKE_SIZEOF_VOID_P} CACHE INTERNAL \"\" FORCE)\n")

# Finnally defining variables related to crosscompilation
file(APPEND ${file} "set(PID_CROSSCOMPILATION ${PID_CROSSCOMPILATION} CACHE INTERNAL \"\" FORCE)\n")
if(PID_CROSSCOMPILATION) #only write these information if we are trully cross compiling
	file(APPEND ${file} "set(CMAKE_CROSSCOMPILING ${CMAKE_CROSSCOMPILING} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_SYSTEM_NAME ${CMAKE_SYSTEM_NAME} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_SYSTEM_VERSION ${CMAKE_SYSTEM_VERSION} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_C_COMPILER_TARGET ${CMAKE_C_COMPILER_TARGET} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_CXX_COMPILER_TARGET ${CMAKE_CXX_COMPILER_TARGET} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN ${CMAKE_C_COMPILER_EXTERNAL_TOOLCHAIN} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN ${CMAKE_CXX_COMPILER_EXTERNAL_TOOLCHAIN} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_SYSROOT ${CMAKE_SYSROOT} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ${CMAKE_FIND_ROOT_PATH_MODE_PROGRAM} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ${CMAKE_FIND_ROOT_PATH_MODE_LIBRARY} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ${CMAKE_FIND_ROOT_PATH_MODE_INCLUDE} CACHE INTERNAL \"\" FORCE)\n")
	file(APPEND ${file} "set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ${CMAKE_FIND_ROOT_PATH_MODE_PACKAGE} CACHE INTERNAL \"\" FORCE)\n")
endif()
endfunction(write_Current_Configuration_Build_Related_Variables)


## subsidiary function for writing a global description of the workspace into a cmake file
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

## subsidiary function for writing workspace configuration to a cmake file
function(write_Current_Configuration file)
file(WRITE ${file} "")
write_Platform_Description(${CMAKE_BINARY_DIR}/Workspace_Platforms_Description.cmake)
file(APPEND ${file} "include(${CMAKE_BINARY_DIR}/Workspace_Platforms_Description.cmake NO_POLICY_SCOPE)\n")
write_Current_Configuration_Build_Related_Variables(${CMAKE_BINARY_DIR}/Workspace_Build_Info.cmake)
file(APPEND ${file} "include(${CMAKE_BINARY_DIR}/Workspace_Build_Info.cmake NO_POLICY_SCOPE)\n")
# defining all build configuration variables related to the current platform
endfunction(write_Current_Configuration)

### define the current platform in use and provide to the user some options to control finally targetted platform
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

## subsidiary function for retrieving available plugins and creating options to activate them
function(register_Available_Plugins)
file(GLOB ALL_AVAILABLE_PLUGINS RELATIVE ${CMAKE_SOURCE_DIR}/share/cmake/plugins ${CMAKE_SOURCE_DIR}/share/cmake/plugins/*) #getting plugins container folders names
	if(NOT ALL_AVAILABLE_PLUGINS)
		set(WORKSPACE_ALL_PLUGINS CACHE INTERNAL "")
		set(WORKSPACE_ACTIVE_PLUGINS CACHE INTERNAL "")
		return()
	endif()
	set(ALL_PLUGINS_DEFINED)
	foreach(plugin IN ITEMS ${ALL_AVAILABLE_PLUGINS})#filtering plugins description files (check if these are really cmake files related to plugins description, according to the PID standard)
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
		return()
	endif()

	# detecting which plugins are active
	set(WORKSPACE_ALL_PLUGINS ${ALL_PLUGINS_DEFINED} CACHE INTERNAL "")
	set(ALL_PLUGINS_ACTIVE)
	foreach(plugin IN ITEMS ${WORKSPACE_ALL_PLUGINS})
		if(PLUGIN_${plugin})
			list(APPEND ALL_PLUGINS_ACTIVE ${plugin})
		endif()
	endforeach()
	if(ALL_PLUGINS_ACTIVE)
		set(WORKSPACE_ACTIVE_PLUGINS ${ALL_PLUGINS_ACTIVE} CACHE INTERNAL "")
	else()
		set(WORKSPACE_ACTIVE_PLUGINS CACHE INTERNAL "")
	endif()
endfunction(register_Available_Plugins)

## subsidiary function for writing workspace active plugins configuration to a cmake file
function(write_Active_Plugins file)
file(WRITE ${file} "")
file(APPEND ${file} "set(WORKSPACE_ALL_PLUGINS ${WORKSPACE_ALL_PLUGINS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(WORKSPACE_ACTIVE_PLUGINS ${WORKSPACE_ACTIVE_PLUGINS} CACHE INTERNAL \"\")\n")
if(WORKSPACE_ACTIVE_PLUGINS)
	foreach(plugin IN ITEMS ${WORKSPACE_ACTIVE_PLUGINS})
		file(APPEND ${file} "set(${plugin}_PLUGIN_ACTIVATION_MESSAGE \"${${plugin}_PLUGIN_ACTIVATION_MESSAGE}\" CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${plugin}_PLUGIN_RESIDUAL_FILES ${${plugin}_PLUGIN_RESIDUAL_FILES} CACHE INTERNAL \"\")\n")
	endforeach()
endif()
endfunction(write_Active_Plugins)

### define active plugins among available plugins
function(manage_Plugins)

# listing all available plugins from plugins definitions cmake files found in the workspace
register_Available_Plugins()

if(WORKSPACE_ACTIVE_PLUGINS)
	message("[PID] Active plugins:")
	foreach(plugin IN ITEMS ${WORKSPACE_ACTIVE_PLUGINS})
		message(" ${plugin}")
	endforeach()
endif()

set(PLUGINS_FILE ${CMAKE_BINARY_DIR}/Workspace_Plugins_Info.cmake)
write_Active_Plugins(${PLUGINS_FILE})
endfunction(manage_Plugins)
