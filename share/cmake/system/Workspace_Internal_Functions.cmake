########################################################################
############ inclusion of required macros and functions ################
########################################################################
if(NOT ${CMAKE_VERSION} VERSION_LESS "3.0")
cmake_policy(SET CMP0026 OLD) #disable warning when reading LOCATION property
cmake_policy(SET CMP0048 OLD) #allow to use a custom versionning system
cmake_policy(SET CMP0037 OLD) #allow to redefine standard target such as clean
cmake_policy(SET CMP0045 OLD) #allow to test if a target exist without a warning
endif()
include(Package_Internal_Finding NO_POLICY_SCOPE)
include(Package_Internal_Configuration NO_POLICY_SCOPE)
include(Package_Internal_Referencing NO_POLICY_SCOPE)

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
	print_Package_Binaries(${package})
endif()
endfunction()

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
	print_Package_Binaries(${package})
endif()
endfunction()

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
	elseif(system STREQUAL "darwin" AND APPLE)
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
elseif(system STREQUAL "darwin")
	set(system_string Darwin)
endif()
if(mode MATCHES Debug)
	set(mode_string "-dbg")
else()
	set(mode_string "")
endif()

set(${RES_FILE} "${package}-${version}${mode_string}-${system_string}.tar.gz" PARENT_SCOPE)
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
	if("${system}" STREQUAL "darwin")
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
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git init)
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
#confuguring git repository
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git add --all)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git commit -m "initialization of package done")
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git tag -a v0.0.0 -m "creation of package")
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout -b integration master)
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

###
function(get_Repository_Name RES_NAME git_url)
#testing ssh address
string(REGEX REPLACE "^[^@]+@[^:]+:(.+)$" "\\1" REPO_PATH ${git_url})
if(REPO_PATH STREQUAL "${git_url}")
	#testing https address
	string(REGEX REPLACE "^https?://(.*)$" "\\1" REPO_PATH ${git_url})
	if(REPO_PATH STREQUAL "${git_url}")
		return()
	endif()
endif()
get_filename_component(REPO_NAME ${REPO_PATH} NAME_WE)
set(${RES_NAME} ${REPO_NAME} PARENT_SCOPE) 
endfunction()


###
function(set_Package_Repository_Address package git_url)
	file(READ ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt CONTENT)
	string(REPLACE "YEAR" "ADDRESS ${git_url} YEAR" NEW_CONTENT ${CONTENT})
	file(WRITE ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt ${NEW_CONTENT})
endfunction()

###
function(is_Package_Connected CONNECTED package)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote show origin OUTPUT_QUIET ERROR_VARIABLE res)
	if(NOT res OR res STREQUAL "")
		set(${CONNECTED} TRUE PARENT_SCOPE)
	else()
		set(${CONNECTED} FALSE PARENT_SCOPE)
	endif()
endfunction()


###
function(connect_PID_Package package git_url)
# updating local repository
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout integration)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git add --all)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git commit -m "prepare synchronization with repository")
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout master)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git add --all)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git commit -m "prepare synchronization with repository")
# updating the address of the official repository in the CMakeLists.txt of the package 
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout integration)
set_Package_Repository_Address(${package} ${git_url})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git add CMakeLists.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git commit -m "adding repository address to the root CMakeLists.txt file")
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout master)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git merge integration)
# synchronizing with the empty git repository
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote add origin ${git_url})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git fetch origin)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin master)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin integration)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin --tags)
endfunction()

###
function(clear_PID_Package package version)
if("${version}" MATCHES "own-[0-9]+\\.[0-9]+\\.[0-9]+"		#specific own version targetted
	OR "${version}" MATCHES "[0-9]+\\.[0-9]+\\.[0-9]+")	#specific version targetted

	if( EXISTS ${WORKSPACE_DIR}/install/${package}/${version}
	AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${package}/${version})
		execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/install/${package}/${version})
	else()
		message(ERROR "package ${package} version ${version} does not resides in workspace install directory")
	endif()

elseif("${version}" MATCHES "own")#all own version targetted
	file(	GLOB TO_SUPPRESS
		"${WORKSPACE_DIR}/install/${package}/own-*")
	foreach (folder IN ITEMS ${TO_SUPPRESS})
		execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${folder})
	endforeach()
elseif("${version}" MATCHES "all")#all versions targetted (including own versions and installers folder)
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/install/${package})
else()
	message(ERROR "invalid version string : ${version}, possible inputs are version numbers (with or without own- prefix), all and own")
endif()
endfunction()

###
function(remove_PID_Package package)

if(	EXISTS ${WORKSPACE_DIR}/install/${package})
	clear_PID_Package(${package} all)
endif()

execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/packages/${package})
endfunction()


###
function(register_PID_Package package)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git checkout master)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package}/build ${CMAKE_BUILD_TOOL} install)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package}/build ${CMAKE_BUILD_TOOL} referencing)
if(EXISTS ${WORKSPACE_DIR}/share/cmake/find/Find${package}.cmake AND EXISTS ${WORKSPACE_DIR}/share/cmake/references/Refer${package}.cmake)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git add share/cmake/find/Find${package}.cmake)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git add share/cmake/references/Refer${package}.cmake)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git commit -m "${package} registered")
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git push origin master)
else()
	message("ERROR : problem registering package ${package}, cannot generate adequate cmake files")
endif()
endfunction()


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


function(set_Version_Number_To_Package package major minor patch)

file(READ ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt PACKAGE_METADATA) #getting global info on the package
string(REGEX REPLACE "^(.*)set_PID_Package_Version\\(([0-9]+)(\\ +)([0-9]+)(\\ *)([0-9]*)(\\ *)\\)(.*)$" "\\1;\\8" PACKAGE_METADATA_WITHOUT_VERSION ${PACKAGE_METADATA})

list(GET PACKAGE_METADATA_WITHOUT_VERSION 0 BEGIN)
list(GET PACKAGE_METADATA_WITHOUT_VERSION 1 END)

set(TO_WRITE "${BEGIN}set_PID_Package_Version(${major} ${minor} ${patch})${END}")
file(WRITE ${WORKSPACE_DIR}/packages/${package}/CMakeLists.txt ${TO_WRITE}) #getting global info on the package

endfunction(set_Version_Number_To_Package)

function(release_PID_Package package next)
### registering current version
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout integration) #force going to integration branch
get_Version_Number_And_Repo_From_Package(${package} NUMBER STRING_NUMBER ADDRESS)
message("address is ---${ADDRESS}---")
if(NOT NUMBER)
	message("ERROR : problem releasing package ${package}, bad version format")
endif()
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout master) #force going to master branch
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git merge integration)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git tag -a v${STRING_NUMBER} -m "releasing version ${STRING_NUMBER}")
if(ADDRESS)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin master)#releasing on master branch
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin v${STRING_NUMBER})#releasing version tag
endif()
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout integration)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git merge master)#just in case of...

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
set_Version_Number_To_Package(${package} ${major} ${minor} ${patch})

execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git add CMakeLists.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git commit -m "start new version ${major}.${minor}.${patch}")
if(ADDRESS)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin integration)
endif()
endfunction()

