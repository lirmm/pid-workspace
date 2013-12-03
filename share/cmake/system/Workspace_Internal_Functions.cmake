########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(Package_Internal_Finding)
include(Package_Internal_Configuration)
include(Package_Internal_Referencing)

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


###
function(write_Categories_File)
set(file ${CMAKE_BINARY_DIR}/CategoriesInfo.cmake)
file(WRITE ${file} "")
file(APPEND ${file} "######### declaration of workspace categories ########\n")
file(APPEND ${file} "set(ROOT_CATEGORIES ${ROOT_CATEGORIES} CACHE INTERNAL \"\")\n")
foreach(root_cat IN ITEMS ${ROOT_CATEGORIES})
	write_Category_In_File(${root_cat} ${file})
endforeach()
endfunction()

###
function(write_Category_In_File category thefile)
file(APPEND ${thefile} "set(${category}_CATEGORY_CONTENT ${${category}_CATEGORY_CONTENT} CACHE INTERNAL \"\")\n")
if(${category}_CATEGORIES)
	file(APPEND ${thefile} "set(${category}_CATEGORIES ${${category}_CATEGORIES} CACHE INTERNAL \"\")\n")
	foreach(cat IN ITEMS ${${category}_CATEGORIES})
		write_Category_In_File(${cat} ${thefile})
	endforeach()
endif()
endfunction()

###
function(find_category containing_category searched_category RESULT CAT_TO_CALL)
string(REGEX REPLACE "^([^/]+)/(.+)$" "\\1;\\2" CATEGORY_STRING_CONTENT ${searched_category})
if(NOT CATEGORY_STRING_CONTENT STREQUAL ${searched_category})# it macthes => searching category into a specific "category path"
	list(GET CATEGORY_STRING_CONTENT 0 ROOT_OF_CATEGORY)
	list(GET CATEGORY_STRING_CONTENT 1 REMAINING_OF_CATEGORY)

	if(containing_category)#if the searched category must be found into a super category
		list(FIND containing_category ${ROOT_OF_CATEGORY} INDEX)
		if(INDEX EQUAL -1)
			message("${ROOT_OF_CATEGORY} cannot be found in ${containing_category}	")
			set(${RESULT} FALSE PARENT_SCOPE)
			return()
		endif()
	endif()
	if(NOT ${ROOT_OF_CATEGORY}_CATEGORIES)#if the root category has no subcategories no need to continue
		set(${RESULT} FALSE PARENT_SCOPE)
		return()
	endif()
	set(SUB_RESULT FALSE)
	set(SUB_CAT_TO_CALL "")
	find_category("${${ROOT_OF_CATEGORY}_CATEGORIES}" "${REMAINING_OF_CATEGORY}" SUB_RESULT SUB_CAT_TO_CALL)
	if(SUB_RESULT)
		set(${RESULT} TRUE PARENT_SCOPE)
		set(${CAT_TO_CALL} ${SUB_CAT_TO_CALL} PARENT_SCOPE)
	else()
		set(${RESULT} FALSE PARENT_SCOPE)
	endif()
	
else()#this is a simple category name, just testing of this category exists
	if(containing_category)
		list(FIND containing_category ${searched_category} INDEX)
		if(INDEX EQUAL -1)
			set(${RESULT} FALSE PARENT_SCOPE)
			return()
		endif()
	endif()

	if(${searched_category}_CATEGORIES OR ${searched_category}_CATEGORY_CONTENT)
		set(${RESULT} TRUE PARENT_SCOPE)
		set(${CAT_TO_CALL} ${searched_category} PARENT_SCOPE)
	else()
		set(${RESULT} FALSE PARENT_SCOPE)
	endif()
endif()

endfunction()

###
function(print_Author author)
string(REGEX REPLACE "^([^\\(]+)\\(([^\\)]*)\\)$" "\\1;\\2" author_institution "${author}")
list(GET author_institution 0 AUTHOR_NAME)
list(GET author_institution 1 INSTITUTION_NAME)
extract_All_Words("${AUTHOR_NAME}" AUTHOR_ALL_WORDS)
extract_All_Words("${INSTITUTION_NAME}" INSTITUTION_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
fill_List_Into_String("${INSTITUTION_ALL_WORDS}" INSTITUTION_STRING)
if(NOT INSTITUTION_STRING STREQUAL "")
	message("	${AUTHOR_STRING} - ${INSTITUTION_STRING}")
else()
	message("	${AUTHOR_STRING}")
endif()
endfunction()

###
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


###
function(print_Package_Info package)
message("PACKAGE: ${package}")
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
	print_Package_Binaries(${package})
endif()
endfunction()


###
function(print_Package_Contact package)
extract_All_Words("${${package}_MAIN_AUTHOR}" AUTHOR_ALL_WORDS)
extract_All_Words("${${package}_MAIN_INSTITUTION}" INSTITUTION_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
fill_List_Into_String("${INSTITUTION_ALL_WORDS}" INSTITUTION_STRING)
if(NOT INSTITUTION_STRING STREQUAL "")
	if(${package}_CONTACT_MAIL)
		message("CONTACT: ${AUTHOR_STRING} (${${package}_CONTACT_MAIL}) - ${INSTITUTION_STRING}")
	else()
		message("CONTACT: ${AUTHOR_STRING} - ${INSTITUTION_STRING}")
	endif()
else()
	if(${package}_CONTACT_MAIL)
		message("CONTACT: ${AUTHOR_STRING} (${${package}_CONTACT_MAIL})")
	else()
		message("CONTACT: ${AUTHOR_STRING}")
	endif()
endif()
endfunction()


###
function(print_Package_Binaries package)
foreach(version IN ITEMS ${${package}_REFERENCES})
	message("	${version}: ")
	foreach(system IN ITEMS ${${package}_REFERENCE_${version}})
		print_Accessible_Binary(${package} ${version} ${system})
	endforeach()
endforeach()
endfunction()


###
function(test_Package_Binary_Against_Platform package version IS_COMPATIBLE)
foreach(system IN ITEMS ${${package}_REFERENCE_${version}})
	if(system STREQUAL "linux" AND UNIX AND NOT APPLE)
		set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)
	elseif(system STREQUAL "macosx" AND APPLE)
		set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)
	endif()
endforeach()
set(${IS_COMPATIBLE} FALSE PARENT_SCOPE)
endfunction()

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
endfunction()

###
function(generate_Binary_Package_Name package version system mode RES_FILE RES_FOLDER)
if(system STREQUAL "linux")
	set(system_string Linux)
elseif(system STREQUAL "macosx")
	#TODO)
endif()
if(mode MATCHES Debug)
	set(mode_string "-dbg")
else()
	set(mode_string "")
endif()

set(${RES_FILE} "${package}-${version}${mode_string}-${system_string}.zip" PARENT_SCOPE)
set(${RES_FOLDER} "${package}-${version}${mode_string}-${system_string}" PARENT_SCOPE)
endfunction(generate_Binary_Package_Name)

###
function(test_binary_download package version system RESULT)

#testing release archive
set(download_url ${${package}_REFERENCE_${version}_${system}})
generate_Binary_Package_Name(${package} ${version} ${system} Release RES_FILE RES_FOLDER)
set(destination ${CMAKE_BINARY_DIR}/${RES_FILE})
set(res "")
file(DOWNLOAD ${download_url} ${destination} STATUS res)#waiting one second
list(GET res 0 numeric_error)
list(GET res 1 status)
if(NOT numeric_error EQUAL 0)#testing if connection can be established
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
endif()
execute_process(COMMAND ${CMAKE_COMMAND} -E tar xvf ${destination}
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	ERROR_VARIABLE error
	OUTPUT_QUIET
)
file(REMOVE ${destination}) #removing archive file
if(NOT error STREQUAL "")#testing if archive is valid
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
else()
	file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/${RES_FOLDER})#cleaning (removing extracted folder)
endif()


#testing debug archive
set(download_url_dbg ${${package}_REFERENCE_${version}_${system}_DEBUG})
generate_Binary_Package_Name(${package} ${version} ${system} Debug RES_FILE RES_FOLDER)
set(destination_dbg ${CMAKE_BINARY_DIR}/${RES_FILE})
set(res_dbg "")
file(DOWNLOAD ${download_url_dbg} ${destination_dbg} STATUS res_dbg)#waiting one second
list(GET res_dbg 0 numeric_error_dbg)
list(GET res_dbg 1 status_dbg)
if(NOT numeric_error_dbg EQUAL 0)#testing if connection can be established
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
endif()
execute_process(COMMAND ${CMAKE_COMMAND} -E tar xvf ${destination_dbg}
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	ERROR_VARIABLE error
	OUTPUT_QUIET
)
file(REMOVE ${destination_dbg})#removing archive file
if(NOT error STREQUAL "")#testing if archive is valid
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
else()
	file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/${RES_FOLDER}) #cleaning (removing extracted folder)
endif()

#release and debug versions are accessible => OK
set(${RESULT} TRUE PARENT_SCOPE)
endfunction()


###
function(print_Accessible_Binary package version system)
set(printed_string "		${system}:")
#1) testing if binary can be installed
if(UNIX AND NOT APPLE) 
	if("${system}" STREQUAL "linux")
		set(RESULT FALSE)
		test_binary_download(${package} ${version} ${system} RESULT)
		if(RESULT)
			set(printed_string "${printed_string} CAN BE INSTALLED")
		else()
			set(printed_string "${printed_string} CANNOT BE DOWNLOADED")
		endif()
	else()
		set(printed_string "${printed_string} CANNOT BE INSTALLED")
	endif()
elseif(APPLE)
	if("${system}" STREQUAL "macosx")
		set(RESULT FALSE)
		test_binary_download(${package} ${version} ${system} RESULT)
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
endfunction()

###
function(create_PID_Package package author institution license)
message("create_PID_Package ${package}")
#copying the pattern folder into teh package folder and renaming it
execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/share/patterns/package ${WORKSPACE_DIR}/packages/${package})
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
	message("WARNING: no license defined so using the default CeCILL license")
	set(PACKAGE_LICENSE "CeCILL")#default license is CeCILL
endif()
set(PACKAGE_DESCRIPTION "TODO: input a short description of package ${package} utility here")
string(TIMESTAMP date "%Y")
set(PACKAGE_YEARS ${date}) 
# generating the root CMakeLists.txt of the package
configure_file(${WORKSPACE_DIR}/share/patterns/CMakeLists.txt.in ../packages/${package}/CMakeLists.txt @ONLY)
#TODO intialize git features
endfunction()


###
function(deploy_PID_Package package version)
set(PROJECT_NAME ${package})
set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD TRUE)
if("${version}" STREQUAL "")#deploying the source repository
	set(DEPLOYED FALSE)
	deploy_Package_Repository(DEPLOYED ${package})
	if(DEPLOYED) 
		deploy_Source_Package(INSTALLED ${package})
		if(NOT INSTALLED)
			message("Error : cannot install ${package}")
			return()
		endif()
	else()
		message("Error : cannot deploy ${package} repository")
	endif()
else()#deploying the target binary relocatable archive 
	deploy_Binary_Package_Version(DEPLOYED ${package} ${version} TRUE)
	if(NOT DEPLOYED) 
		message("Error : cannot deploy ${package} binary archive version ${version}")
	endif()
endif()
endfunction()


###
function(resolve_PID_Package package version)
message("resolve_PID_Package ${package} ${version}")
set(PACKAGE_NAME ${package})
set(PROJECT_NAME ${package})
set(PACKAGE_VERSION ${version})
set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD TRUE)
include(${WORKSPACE_DIR}/share/cmake/system/Bind_PID_Package.cmake)
if(NOT ${PACKAGE_NAME}_BINDED_AND_INSTALLED)
	message("ERROR : cannot configure runtime dependencies for installed version ${version} of package ${package}")
endif()
endfunction()

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

