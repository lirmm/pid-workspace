#########################################################################################
#	This file is part of the program PID						#
#  	Program description : build system supportting the PID methodology  		#
#  	Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique 	#
#	et de Microelectronique de Montpellier). All Right reserved.			#
#											#
#	This software is free software: you can redistribute it and/or modify		#
#	it under the terms of the CeCILL-C license as published by			#
#	the CEA CNRS INRIA, either version 1						#
#	of the License, or (at your option) any later version.				#
#	This software is distributed in the hope that it will be useful,		#
#	but WITHOUT ANY WARRANTY; without even the implied warranty of			#
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the			#
#	CeCILL-C License for more details.						#
#											#
#	You can find the complete license description on the official website 		#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################


########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(Package_Internal_Policies NO_POLICY_SCOPE)
include(Package_Internal_Finding NO_POLICY_SCOPE)
include(Package_Internal_Configuration NO_POLICY_SCOPE)
include(Package_Internal_Referencing NO_POLICY_SCOPE)
include(Package_Internal_Targets_Management NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)

########################################################################
########## Categories (classification of packages) management ##########
########################################################################

###
function(classify_Package_Categories all_packages)
foreach(a_cat IN ITEMS ${ROOT_CATEGORIES})
	classify_Root_Category(${a_cat} "${all_packages}")
endforeach()
endfunction(classify_Package_Categories)

###
function(classify_Root_Category root_category all_packages)
foreach(package IN ITEMS ${all_packages})
	foreach(a_category IN ITEMS ${${package}_CATEGORIES})
		classify_Category(${a_category} ${root_category} ${package})	
	endforeach()
endforeach()
endfunction(classify_Root_Category)

###
function(reset_All_Categories)
foreach(a_category IN ITEMS ${ROOT_CATEGORIES})
	reset_Category(${a_category})
endforeach()
set(ROOT_CATEGORIES CACHE INTERNAL "")
endfunction()

###
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

###
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

###
function(extract_Root_Categories all_packages)
set(ALL_ROOTS CACHE INTERNAL "")
foreach(a_package IN ITEMS ${all_packages})
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
endfunction(extract_Root_Categories)

###
function(classify_Category category_full_string root_category target_package)
if("${category_full_string}" STREQUAL "${root_category}")#OK, so the package directly belongs to this category
	set(CAT_${category_full_string}_CATEGORY_CONTENT ${CAT_${category_full_string}_CATEGORY_CONTENT} ${target_package} CACHE INTERNAL "") #end of recursion
	list(REMOVE_DUPLICATES CAT_${category_full_string}_CATEGORY_CONTENT)
	set(CAT_${category_full_string}_CATEGORY_CONTENT ${CAT_${category_full_string}_CATEGORY_CONTENT} CACHE INTERNAL "")
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

###
function(write_Categories_File)
set(file ${CMAKE_BINARY_DIR}/CategoriesInfo.cmake)
file(WRITE ${file} "")
file(APPEND ${file} "######### declaration of workspace categories ########\n")
file(APPEND ${file} "set(ROOT_CATEGORIES \"${ROOT_CATEGORIES}\" CACHE INTERNAL \"\")\n")
foreach(root_cat IN ITEMS ${ROOT_CATEGORIES})
	write_Category_In_File(${root_cat} ${file})
endforeach()
endfunction()

###
function(write_Category_In_File category thefile)
file(APPEND ${thefile} "set(CAT_${category}_CATEGORY_CONTENT \"${CAT_${category}_CATEGORY_CONTENT}\" CACHE INTERNAL \"\")\n")
if(CAT_${category}_CATEGORIES)
	file(APPEND ${thefile} "set(CAT_${category}_CATEGORIES \"${CAT_${category}_CATEGORIES}\" CACHE INTERNAL \"\")\n")
	foreach(cat IN ITEMS ${CAT_${category}_CATEGORIES})
		write_Category_In_File("${category}/${cat}" ${thefile})
	endforeach()
endif()
endfunction()

###
function(find_In_Categories searched_category_term)
foreach(root_cat IN ITEMS ${ROOT_CATEGORIES})
	find_Category("" ${root_cat} ${searched_category_term})	
endforeach()
message("---------------")
endfunction(find_In_Categories)

###
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


###
function(get_Category_Names root_category category_full_string RESULTING_SHORT_NAME RESULTING_LONG_NAME)

if("${root_category}" STREQUAL "")
	set(${RESULTING_SHORT_NAME} ${category_full_string} PARENT_SCOPE)
	set(${RESULTING_LONG_NAME} ${category_full_string} PARENT_SCOPE)
	return()
endif()

string(REGEX REPLACE "^${root_category}/(.+)$" "\\1" CATEGORY_STRING_CONTENT ${category_full_string})
if(NOT CATEGORY_STRING_CONTENT STREQUAL ${category_full_string})# it macthed
	set(${RESULTING_SHORT_NAME} ${CATEGORY_STRING_CONTENT} PARENT_SCOPE)
	set(${RESULTING_LONG_NAME} "${root_category}/${CATEGORY_STRING_CONTENT}" PARENT_SCOPE)
else()
	message("[PID] Error : internal BUG.")
endif()

endfunction(get_Category_Names)

###
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

########################################################################
##################### Packages info management #########################
########################################################################

###
function(print_Author author)
get_Formatted_Author_String("${author}" RES_STRING)
message("	${RES_STRING}")
endfunction(print_Author)

###
function(print_Package_Contact package)
get_Formatted_Package_Contact_String(${package} RES_STRING)
message("CONTACT: ${RES_STRING}")
endfunction(print_Package_Contact)

###
function(print_Package_Info package)
message("NATIVE PACKAGE: ${package}")
fill_List_Into_String("${${package}_DESCRIPTION}" descr_string)
message("DESCRIPTION: ${descr_string}")
message("LICENSE: ${${package}_LICENSE}")
message("DATES: ${${package}_YEARS}")
message("REPOSITORY: ${${package}_ADDRESS}")
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
if(${package}_REFERENCES)
	message("BINARY VERSIONS:")
	print_Native_Package_Binaries(${package})
endif()
endfunction(print_Package_Info)

###
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
if(${package}_REFERENCES)
	message("BINARY VERSIONS:")
	print_External_Package_Binaries(${package})
endif()
endfunction(print_External_Package_Info)

###
function(print_External_Package_Contact package)
fill_List_Into_String("${${package}_PID_Package_AUTHOR}" AUTHOR_STRING)
fill_List_Into_String("${${package}_PID_Package_INSTITUTION}" INSTITUTION_STRING)
if(NOT INSTITUTION_STRING STREQUAL "")
	if(${package}_PID_Package_CONTACT_MAIL)
		message("PID PACKAGE CONTACT: ${AUTHOR_STRING} (${${package}_PID_Package_CONTACT_MAIL}) - ${INSTITUTION_STRING}")
	else()
		message("PID PACKAGE CONTACT: ${AUTHOR_STRING} - ${INSTITUTION_STRING}")
	endif()
else()
	if(${package}_PID_Package_CONTACT_MAIL)
		message("PID PACKAGE CONTACT: ${AUTHOR_STRING} (${${package}_PID_Package_CONTACT_MAIL})")
	else()
		message("PID PACKAGE CONTACT: ${AUTHOR_STRING}")
	endif()
endif()
endfunction(print_External_Package_Contact)



###
function(print_External_Package_Binaries package)
foreach(version IN ITEMS ${${package}_REFERENCES})
	message("	${version}: ")
	foreach(system IN ITEMS ${${package}_REFERENCE_${version}})
		foreach(arch IN ITEMS ${${package}_REFERENCE_${version}_${system}})
			print_Accessible_Binary(${package} ${version} ${system} ${arch})
		endforeach()
	endforeach()
endforeach()
endfunction(print_External_Package_Binaries)


###
function(print_Native_Package_Binaries package)
foreach(version IN ITEMS ${${package}_REFERENCES})
	message("	${version}: ")
	foreach(platform IN ITEMS ${${package}_REFERENCE_${version}})
		print_Platform_Accessible_Binary(${package} ${version} ${platform})
	endforeach()
endforeach()
endfunction(print_Native_Package_Binaries)


###
function(test_Package_Binary_Against_Platform package version IS_COMPATIBLE)
foreach(system IN ITEMS ${${package}_REFERENCE_${version}})
	if(system STREQUAL "linux" AND UNIX AND NOT APPLE)
		set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)
		return()
	elseif(system STREQUAL "darwin" AND APPLE)
		set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)
		return()
	endif()
endforeach()
set(${IS_COMPATIBLE} FALSE PARENT_SCOPE)
endfunction(test_Package_Binary_Against_Platform)

###
function(exact_Version_Exists package version RESULT)
list(FIND ${package}_REFERENCES ${version} INDEX)
if(INDEX EQUAL -1)
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
else()
	test_Package_Binary_Against_Platform(${package} ${version} COMPATIBLE)
	if(COMPATIBLE)	
		set(${RESULT} TRUE PARENT_SCOPE)
	else()
		set(${RESULT} FALSE PARENT_SCOPE)
	endif()
endif()
endfunction(exact_Version_Exists)

### generate the nale of an archive generated by CPack
function(generate_Binary_Package_Archive_Name package version system mode RES_FILE RES_FOLDER)
if(system STREQUAL "linux")
	set(system_string Linux)
elseif(system STREQUAL "macosx")
	set(system_string Darwin)
endif()
if(mode MATCHES Debug)
	set(mode_string "-dbg")
else()
	set(mode_string "")
endif()

set(${RES_FILE} "${package}-${version}${mode_string}-${system_string}.tar.gz" PARENT_SCOPE)
set(${RES_FOLDER} "${package}-${version}${mode_string}-${system_string}" PARENT_SCOPE)
endfunction(generate_Binary_Package_Archive_Name)

###
function(test_binary_download package version system arch RESULT)

#testing release archive
set(download_url ${${package}_REFERENCE_${version}_${system}_${arch}_URL})

generate_Binary_Package_Archive_Name(${package} ${version} ${system} Release RES_FILE RES_FOLDER)
set(destination ${CMAKE_BINARY_DIR}/share/${RES_FILE})
set(res "")
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory share
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
			ERROR_QUIET OUTPUT_QUIET)

file(DOWNLOAD ${download_url} ${destination} STATUS res SHOW_PROGRESS TLS_VERIFY OFF)#waiting one second
list(GET res 0 numeric_error)
list(GET res 1 status)
if(NOT numeric_error EQUAL 0)#testing if connection can be established
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
endif()
execute_process(COMMAND ${CMAKE_COMMAND} -E tar xvf ${destination}
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
	ERROR_VARIABLE error
	OUTPUT_QUIET
)
file(REMOVE ${destination}) #removing archive file
if(NOT error STREQUAL "")#testing if archive is valid
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
else()
	file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/share/${RES_FOLDER})#cleaning (removing extracted folder)
endif()


#testing debug archive
if(EXISTS ${package}_REFERENCE_${version}_${system}_${arch}_URL_DEBUG)
	set(download_url_dbg ${${package}_REFERENCE_${version}_${system}_${arch}_URL_DEBUG})

	generate_Binary_Package_Archive_Name(${package} ${version} ${system} Debug RES_FILE RES_FOLDER)
	set(destination_dbg ${CMAKE_BINARY_DIR}/share/${RES_FILE})
	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory share
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
			ERROR_QUIET OUTPUT_QUIET)
	set(res_dbg "")
	file(DOWNLOAD ${download_url_dbg} ${destination_dbg} STATUS res_dbg)#waiting one second
	list(GET res_dbg 0 numeric_error_dbg)
	list(GET res_dbg 1 status_dbg)
	if(NOT numeric_error_dbg EQUAL 0)#testing if connection can be established
		set(${RESULT} FALSE PARENT_SCOPE)
		return()
	endif()
	execute_process(COMMAND ${CMAKE_COMMAND} -E tar xvf ${destination_dbg}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
		ERROR_VARIABLE error
		OUTPUT_QUIET
	)
	file(REMOVE ${destination_dbg})#removing archive file
	if(NOT error STREQUAL "")#testing if archive is valid
		set(${RESULT} FALSE PARENT_SCOPE)
		return()
	else()
		file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/share/${RES_FOLDER}) #cleaning (removing extracted folder)
	endif()
endif()

#release and debug versions are accessible => OK
set(${RESULT} TRUE PARENT_SCOPE)
endfunction(test_binary_download)


###
function(print_Accessible_Binary package version system arch)
set(printed_string "		${system}(${arch}):")
#1) testing if binary can be installed

if(	(APPLE AND "${system}" STREQUAL macosx) #test if OS is OK
	OR (UNIX AND "${system}" STREQUAL linux)) 
	if(	(${CMAKE_SIZEOF_VOID_P} EQUAL 4 AND ${arch} EQUAL 32)#test if architecture is OK
		OR (${CMAKE_SIZEOF_VOID_P} EQUAL 8 AND ${arch} EQUAL 64) )
		set(RESULT FALSE)
		test_binary_download(${package} ${version} ${system} ${arch} RESULT)
		if(RESULT)
			set(printed_string "${printed_string} CAN BE INSTALLED")
		else()
			set(printed_string "${printed_string} CANNOT BE DOWNLOADED")
		endif()
	else()
		set(printed_string "${printed_string} CANNOT BE INSTALLED")
	endif()
else()
	set(printed_string "${printed_string} CANNOT BE INSTALLED")
endif()
message("${printed_string}")
endfunction(print_Accessible_Binary)

###
function(print_Platform_Accessible_Binary package version platform)
set(printed_string "		${platform}:")
#1) testing if binary can be installed

if(	(APPLE AND "${system}" STREQUAL macosx) #test if OS is OK
	OR (UNIX AND "${system}" STREQUAL linux)) 
	if(	(${CMAKE_SIZEOF_VOID_P} EQUAL 4 AND ${arch} EQUAL 32)#test if architecture is OK
		OR (${CMAKE_SIZEOF_VOID_P} EQUAL 8 AND ${arch} EQUAL 64) )
		set(RESULT FALSE)
		test_binary_download(${package} ${version} ${system} ${arch} RESULT)
		if(RESULT)
			set(printed_string "${printed_string} CAN BE INSTALLED")
		else()
			set(printed_string "${printed_string} CANNOT BE DOWNLOADED")
		endif()
	else()
		set(printed_string "${printed_string} CANNOT BE INSTALLED")
	endif()
else()
	set(printed_string "${printed_string} CANNOT BE INSTALLED")
endif()
message("${printed_string}")
endfunction(print_Platform_Accessible_Binary)
########################################################################
#################### Packages lifecycle management #####################
########################################################################

###
function(create_PID_Package package author institution license)
#copying the pattern folder into the package folder and renaming it
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/share/patterns/package ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)

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
configure_file(${WORKSPACE_DIR}/share/patterns/CMakeLists.txt.in ../packages/${package}/CMakeLists.txt @ONLY)
#confuguring git repository
init_Repository(${package})
endfunction(create_PID_Package)


###
function(deploy_PID_Package package version)
set(PROJECT_NAME ${package})
set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD ON)
if("${version}" STREQUAL "")#deploying the source repository
	set(DEPLOYED FALSE)
	deploy_Package_Repository(DEPLOYED ${package})
	if(DEPLOYED)
		set(INSTALLED FALSE)
		deploy_Source_Package(INSTALLED ${package} "")
		if(NOT INSTALLED)
			message("[PID] ERROR : cannot install ${package} after deployment.")
			return()
		endif()
	else()
		message("[PID] ERROR : cannot deploy ${package} repository.")
	endif()
else()#deploying the target binary relocatable archive 
	deploy_Binary_Package_Version(DEPLOYED ${package} ${version} TRUE "")
	if(NOT DEPLOYED) 
		message("[PID] ERROR : cannot deploy ${package} binary archive version ${version}.")
	endif()
endif()
endfunction(deploy_PID_Package)

###
function(deploy_External_Package package version)
get_System_Variables(OS_STRING ARCH_BITS PACKAGE_STRING)
set(MAX_CURR_VERSION 0.0.0)
if("${version}" STREQUAL "")#deploying the latest version of the repository
	foreach(version_i IN ITEMS ${${package}_REFERENCES})
		list(FIND ${package}_REFERENCE_${version_i} ${OS_STRING} INDEX)
		if(	NOT INDEX EQUAL -1) #a reference for this OS is known
			list(FIND ${package}_REFERENCE_${version_i}_${OS_STRING} ${ARCH_BITS} INDEX)
			if(NOT INDEX EQUAL -1 #a reference for this arch is known
			AND ${version_i} VERSION_GREATER ${MAX_CURR_VERSION})
				set(MAX_CURR_VERSION ${version_i})
			endif()
		endif()
	endforeach()
	if(NOT ${MAX_CURR_VERSION} STREQUAL 0.0.0)
		deploy_External_Package_Version(DEPLOYED ${package} ${MAX_CURR_VERSION})
		if(NOT DEPLOYED) 
			message("[PID] ERROR : cannot deploy ${package} binary archive version ${MAX_CURR_VERSION}. This is certainy due to a bad, missing or unaccessible archive. Please contact the administrator of the package ${package}.")
		endif()
	else()
		message("[PID] ERROR : no known version to external package ${package} for OS ${OS_STRING}.")
	endif()

else()#deploying the target binary relocatable archive 
	deploy_External_Package_Version(DEPLOYED ${package} ${version})
	if(NOT DEPLOYED) 
		message("[PID] ERROR : cannot deploy ${package} binary archive version ${version}.")
	endif()
endif()
endfunction(deploy_External_Package)

###
function(resolve_PID_Package package version)
set(PACKAGE_NAME ${package})
set(PROJECT_NAME ${package})
set(PACKAGE_VERSION ${version})
set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD TRUE)
include(${WORKSPACE_DIR}/share/cmake/system/Bind_PID_Package.cmake)
if(NOT ${PACKAGE_NAME}_BINDED_AND_INSTALLED)
	message("[PID] ERROR : cannot configure runtime dependencies for installed version ${version} of package ${package}.")
endif()
endfunction(resolve_PID_Package)


###
function(connect_PID_Package package git_url first_time)
save_Repository_Context(INITIAL_COMMIT SAVED_CONTENT ${package}) # saving local repository state
go_To_Integration(${package})
if(first_time)
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


##########################################
###### clearing/removing packages ########
##########################################

###
function(clear_PID_Package package version)
if("${version}" MATCHES "[0-9]+\\.[0-9]+\\.[0-9]+")	#specific version targetted

	if( EXISTS ${WORKSPACE_DIR}/install/${package}/${version}
	AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${package}/${version})
		execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/install/${package}/${version})
	else()
		if( EXISTS ${WORKSPACE_DIR}/external/${package}/${version}
		AND IS_DIRECTORY ${WORKSPACE_DIR}/external/${package}/${version})
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/external/${package}/${version})
		else()
			message("[PID] ERROR : package ${package} version ${version} does not resides in workspace install directory.")
		endif()
	endif()
elseif("${version}" MATCHES "all")#all versions targetted (including own versions and installers folder)
	if( EXISTS ${WORKSPACE_DIR}/install/${package}
	AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${package})
		execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/install/${package})
	else()
		if( EXISTS ${WORKSPACE_DIR}/external/${package}
		AND IS_DIRECTORY ${WORKSPACE_DIR}/external/${package})
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/external/${package})
		else()
			message("[PID] ERROR : package ${package} is not installed in workspace.")
		endif()
	endif()
else()
	message("[PID] ERROR : invalid version string : ${version}, possible inputs are version numbers and all.")
endif()
endfunction(clear_PID_Package)

###
function(remove_PID_Package package)

if(	EXISTS ${WORKSPACE_DIR}/install/${package})
	clear_PID_Package(${package} all)
endif()

execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/packages/${package})
endfunction(remove_PID_Package package)

##########################################
############ registering packages ########
##########################################


###
function(register_PID_Package package)
go_To_Workspace_Master()
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package}/build ${CMAKE_MAKE_PROGRAM} install)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package}/build ${CMAKE_MAKE_PROGRAM} referencing)
publish_References_In_Workspace_Repository(${package})
endfunction(register_PID_Package)


##########################################
############ releasing packages ##########
##########################################

###
function(get_Version_Number_And_Repo_From_Package package NUMBER STRING_NUMBER ADDRESS)
set(${ADDRESS} PARENT_SCOPE)
file(STRINGS ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt PACKAGE_METADATA) #getting global info on the package
foreach(line IN ITEMS ${PACKAGE_METADATA})
	string(REGEX REPLACE "^.*set_PID_Package_Version\\(([0-9]+)(\\ +)([0-9]+)(\\ *)([0-9]*)(\\ *)\\).*$" "\\1;\\3;\\5" A_VERSION ${line})
	if(NOT "${line}" STREQUAL "${A_VERSION}")
		set(VERSION_COMMAND ${A_VERSION})#only taking the last instruction since it shadows previous ones
	endif()
	string(REGEX REPLACE "^.*ADDRESS[\\ \\\t]+([^\\ \\\t]+\\.git).*$" "\\1" AN_ADDRESS ${line})
	if(NOT "${line}" STREQUAL "${AN_ADDRESS}")
		set(${ADDRESS} ${AN_ADDRESS} PARENT_SCOPE)#an address had been found
	endif()
endforeach()
if(VERSION_COMMAND)
	#from here we are sure there is at least 2 digits 
	list(GET VERSION_COMMAND 0 MAJOR)
	list(GET VERSION_COMMAND 1 MINOR)
	list(LENGTH VERSION_COMMAND size_of_version)
	if(NOT size_of_version GREATER 2)
		set(PATCH 0)
		list(APPEND VERSION_COMMAND 0)
	else()
		list(GET VERSION_COMMAND 2 PATCH)
	endif()
	set(${STRING_NUMBER} "${MAJOR}.${MINOR}.${PATCH}" PARENT_SCOPE)
else()
	set(${STRING_NUMBER} "" PARENT_SCOPE)
endif()

set(${NUMBER} ${VERSION_COMMAND} PARENT_SCOPE)
endfunction(get_Version_Number_And_Repo_From_Package)

###
function(set_Version_Number_To_Package package major minor patch)

file(READ ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt PACKAGE_METADATA) #getting global info on the package
string(REGEX REPLACE "^(.*)set_PID_Package_Version\\(([0-9]+)(\\ +)([0-9]+)(\\ *)([0-9]*)(\\ *)\\)(.*)$" "\\1;\\8" PACKAGE_METADATA_WITHOUT_VERSION ${PACKAGE_METADATA})

list(GET PACKAGE_METADATA_WITHOUT_VERSION 0 BEGIN)
list(GET PACKAGE_METADATA_WITHOUT_VERSION 1 END)

set(TO_WRITE "${BEGIN}set_PID_Package_Version(${major} ${minor} ${patch})${END}")
file(WRITE ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt ${TO_WRITE}) #getting global info on the package

endfunction(set_Version_Number_To_Package)


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

# check that integration is a fast forward of master
merge_Into_Master(MERGE_OK ${package} ${STRING_NUMBER})
if(NOT MERGE_OK)
	message("[PID] ERROR : cannot release package ${package}, because there are potential merge conflicts between master and integration branches. Please update ${package} integration branch first then launch again the release process.")
	return()
endif()
publish_Repository_Version(${package} ${STRING_NUMBER})
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
set_Version_Number_To_Package(${package} ${major} ${minor} ${patch})
register_Repository_Version(${package} "${major}.${minor}.${patch}")
publish_Repository_Integration(${package})#if publication rejected => user has to handle merge by hand
set(${RESULT} ${STRING_NUMBER} PARENT_SCOPE)
update_Remotes(${package})
endfunction(release_PID_Package)

##########################################
############ updating packages ###########
##########################################

###
function(update_PID_Source_Package package)
set(INSTALLED FALSE)
message("[PID] INFO : launch the update of source package ${package}...")
list_Version_Subdirectories(version_dirs ${WORKSPACE_DIR}/install/${package})
deploy_Source_Package(INSTALLED ${package} "${version_dirs}")
if(NOT INSTALLED)
	message("[PID] ERROR : cannot update ${package}.")
else()
	message("[PID] INFO : package ${package} update finished.")
endif()
endfunction(update_PID_Source_Package)

###
function(update_PID_Binary_Package package)
message("[PID] INFO : launch the update of binary package ${package}...")
list_Version_Subdirectories(version_dirs ${WORKSPACE_DIR}/install/${package})
deploy_Binary_Package(DEPLOYED ${package} "${version_dirs}")
if(NOT DEPLOYED) 
	message("[PID] ERROR : cannot update ${package}.")
else()
	message("[PID] INFO : package ${package} update finished...")
endif()
endfunction(update_PID_Binary_Package)

###
function(update_PID_External_Package package)
message("[PID] INFO : new versions of external binary package ${package} will not be installed automatically (only if a new version is required by native package)...")
endfunction(update_PID_External_Package)

###
function(update_PID_All_Packages)
list_All_Binary_Packages_In_Workspace(NATIVES EXTERNALS)
list_All_Source_Packages_In_Workspace(SOURCE_PACKAGES)

if(SOURCE_PACKAGES)
	list(REMOVE_ITEM NATIVES ${SOURCE_PACKAGES})
	foreach(package IN ITEMS ${SOURCE_PACKAGES})
		update_PID_Source_Package(${package})
	endforeach()
endif()
if(NATIVES)
	foreach(package IN ITEMS ${NATIVES})
		update_PID_Binary_Package(${package})
	endforeach()
endif()
if(EXTERNALS)
	foreach(package IN ITEMS ${EXTERNALS})
		update_PID_External_Package(${package})
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

###
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


###
function(print_License_Info license)
message("LICENSE: ${LICENSE_NAME}")
message("VERSION: ${LICENSE_VERSION}")
message("OFFICIAL NAME: ${LICENSE_FULLNAME}")
message("AUTHORS: ${LICENSE_AUTHORS}")
endfunction()


