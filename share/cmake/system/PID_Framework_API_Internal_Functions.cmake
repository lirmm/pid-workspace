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
include(PID_Package_Cache_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Deployment_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)

##################################################################################
##################  declaration of a lone package static site ####################
##################################################################################

############ function used to create the README.md file of the site  ###########
function(generate_Site_Readme_File)
set(README_CONFIG_FILE ${WORKSPACE_DIR}/share/patterns/static_sites/README.md.in)
set(PACKAGE_NAME ${PROJECT_NAME})
set(PACKAGE_PROJECT_REPOSITORY ${${PROJECT_NAME}_PROJECT_PAGE})
configure_file(${README_CONFIG_FILE} ${CMAKE_SOURCE_DIR}/README.md @ONLY)#put it in the source dir
endfunction(generate_Site_Readme_File)

############ function used to generate basic files and directory structure for jekyll  ###########
function(generate_Site_Data)
# 1) generate the basic site structure and default files from a pattern
if(EXISTS ${CMAKE_BINARY_DIR}/to_generate)
	file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/to_generate)
endif()
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/to_generate)

execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/share/patterns/static_sites/static ${CMAKE_BINARY_DIR}/to_generate)

#2) generating the global configuration file for package site
if(${PROJECT_NAME}_SITE_PAGE)
	get_Jekyll_URLs(${${PROJECT_NAME}_SITE_PAGE} PUBLIC_URL BASE_URL)
	set(PACKAGE_SITE_URL ${PUBLIC_URL})
	if(BASE_URL AND NOT BASE_URL STREQUAL "")
		set(PACKAGE_SITE_BASE_FOLDER "/${BASE_URL}")
	else()
		set(PACKAGE_SITE_BASE_FOLDER)
	endif()
else()
	set(PACKAGE_SITE_URL)
	set(PACKAGE_SITE_BASE_FOLDER)
endif()

configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/_config.yml.in ${CMAKE_BINARY_DIR}/to_generate/_config.yml @ONLY)

endfunction(generate_Site_Data)

###
function(generate_Site_Binary_References)
set(dir ${CMAKE_SOURCE_DIR}/src/_binaries)
set(file ${dir}/binary_references.cmake)
file(WRITE ${file} "# Contains references to binaries that are available for ${PROJECT_NAME} \n")
#this may overwrite binary references hard coded in the reference file, or simply add new ones

##################################################################
### all available versions of the package for which there is a ###
### reference to a downloadable binary for any platform ##########
##################################################################
list_Subdirectories(ALL_VERSIONS ${dir})
if(ALL_VERSIONS)
	foreach(ref_version IN ITEMS ${ALL_VERSIONS}) #for each available version, all os for which there is a reference
		set(VERSION_REGISTERED FALSE)

		list_Subdirectories(ALL_PLATFORMS ${dir}/${ref_version})
		if(ALL_PLATFORMS)
			foreach(ref_platform IN ITEMS ${ALL_PLATFORMS})#for each platform of this version
				# now referencing the binaries
				list_Regular_Files(ALL_BINARIES ${dir}/${ref_version}/${ref_platform})
				if(	ALL_BINARIES
					AND EXISTS ${dir}/${ref_version}/${ref_platform}/${PROJECT_NAME}-${ref_version}-${ref_platform}.tar.gz
					AND EXISTS ${dir}/${ref_version}/${ref_platform}/${PROJECT_NAME}-${ref_version}-dbg-${ref_platform}.tar.gz)# both release and binary versions have to exist

					if(NOT VERSION_REGISTERED)  # the version is registered only if there are binaries inside (sanity check)
					file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCES ${${PROJECT_NAME}_REFERENCES} ${ref_version} CACHE INTERNAL \"\")\n") # the version is registered
					set(VERSION_REGISTERED TRUE)
					endif()
					file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version} ${${PROJECT_NAME}_REFERENCE_${ref_version}} ${ref_platform} CACHE INTERNAL \"\")\n") # the platform is registered only if there are binaries inside (sanity check)

					file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL ${${PROJECT_NAME}_SITE_PAGE}/binaries/${ref_version}/${ref_platform}/${PROJECT_NAME}-${ref_version}-${ref_platform}.tar.gz CACHE INTERNAL \"\")\n")#reference on the release binary

					file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG ${${PROJECT_NAME}_SITE_PAGE}/binaries/${ref_version}/${ref_platform}/${PROJECT_NAME}-${ref_version}-dbg-${ref_platform}.tar.gz CACHE INTERNAL \"\")\n")#reference on the debug binary

				endif()
			endforeach()
		endif()
	endforeach()
endif()

endfunction(generate_Site_Binary_References)


### implementation function for creating a static site for a lone package
macro(declare_Site package_url site_url)
set(${PROJECT_NAME}_PROJECT_PAGE ${package_url} CACHE INTERNAL "")
set(${PROJECT_NAME}_SITE_PAGE ${site_url} CACHE INTERNAL "")
file(RELATIVE_PATH DIR_NAME ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})
if(DIR_NAME STREQUAL "build")

	generate_Site_Readme_File() # generating the simple README file for the project
	generate_Site_Data() #generating the jekyll source folder in build tree
	generate_Site_Binary_References() #generating the cmake script that references available binaries

	#searching for jekyll (static site generator)
	find_program(JEKYLL_EXECUTABLE NAMES jekyll) #searching for the jekyll executable in standard paths

	if(JEKYLL_EXECUTABLE)
	get_Jekyll_URLs(${${PROJECT_NAME}_PROJECT_PAGE} PUBLIC_URL BASE_URL)
	set(STATIC_SITE_BASEURL "${BASE_URL}")
	add_custom_target(build
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DJEKYLL_EXECUTABLE=${JEKYLL_EXECUTABLE}
						-P ${WORKSPACE_DIR}/share/cmake/system/Build_PID_Package_Site.cmake
		COMMENT "[PID] Building package site ..."
		VERBATIM
	)

	add_custom_target(serve
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DJEKYLL_EXECUTABLE=${JEKYLL_EXECUTABLE}
						-DSITE_BASE_URL=${STATIC_SITE_BASEURL}
						-P ${WORKSPACE_DIR}/share/cmake/system/Serve_PID_Package_Site.cmake
		COMMENT "[PID] Serving the static site of the package ..."
		VERBATIM
	)

	else()
		message("[PID] ERROR: the jekyll executable cannot be found in the system, please install it and put it in a standard path.")
	endif()
else()
	message("[PID] ERROR : please run cmake in the build folder of the package ${PROJECT_NAME} static site.")
	return()
endif()
endmacro(declare_Site)

##################################################################################
##########################  declaration of a framework ###########################
##################################################################################
macro(declare_Framework author institution mail year site license git_address repo_site description)

file(RELATIVE_PATH DIR_NAME ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})
if(DIR_NAME STREQUAL "build")

	set(${PROJECT_NAME}_ROOT_DIR CACHE INTERNAL "")
	list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake) # adding the cmake scripts files from the framework

	init_PID_Version_Variable() # getting the workspace version used to generate the code
	set(res_string)
	foreach(string_el IN ITEMS ${author})
		set(res_string "${res_string}_${string_el}")
	endforeach()
	set(${PROJECT_NAME}_FRAMEWORK_MAIN_AUTHOR "${res_string}" CACHE INTERNAL "")

	set(res_string "")
	foreach(string_el IN ITEMS ${institution})
		set(res_string "${res_string}_${string_el}")
	endforeach()
	set(${PROJECT_NAME}_FRAMEWORK_MAIN_INSTITUTION "${res_string}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_FRAMEWORK_CONTACT_MAIL ${mail} CACHE INTERNAL "")
	set(${PROJECT_NAME}_FRAMEWORK_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_FRAMEWORK_MAIN_AUTHOR}(${${PROJECT_NAME}_FRAMEWORK_MAIN_INSTITUTION})" CACHE INTERNAL "")
	set(${PROJECT_NAME}_FRAMEWORK_DESCRIPTION "${description}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_FRAMEWORK_YEARS ${year} CACHE INTERNAL "")
	set(${PROJECT_NAME}_FRAMEWORK_SITE ${site} CACHE INTERNAL "")
	set(${PROJECT_NAME}_FRAMEWORK_ADDRESS ${git_address} CACHE INTERNAL "")
	set(${PROJECT_NAME}_FRAMEWORK_PROJECT_PAGE ${repo_site} CACHE INTERNAL "")
	set(${PROJECT_NAME}_FRAMEWORK_LICENSE ${license} CACHE INTERNAL "")
	set(${PROJECT_NAME}_FRAMEWORK_CATEGORIES CACHE INTERNAL "")#categories are reset


	#searching for jekyll (static site generator)
	find_program(JEKYLL_EXECUTABLE NAMES jekyll) #searcinh for the jekyll executable in standard paths

	if(JEKYLL_EXECUTABLE)
	get_Jekyll_URLs(${${PROJECT_NAME}_FRAMEWORK_SITE} PUBLIC_URL BASE_URL)
	set(STATIC_SITE_BASEURL "${BASE_URL}")

	add_custom_target(build
		COMMAND ${CMAKE_COMMAND}	-DFRAMEWORK_PATH=${CMAKE_SOURCE_DIR}
						-DTARGET_FRAMEWORK=${PROJECT_NAME}
						-DJEKYLL_EXECUTABLE=${JEKYLL_EXECUTABLE}
						-P ${WORKSPACE_DIR}/share/cmake/system/Build_PID_Framework.cmake
		COMMENT "[PID] Building framework ${PROJECT_NAME} ..."
		VERBATIM
	)

	add_custom_target(serve
		COMMAND ${CMAKE_COMMAND}	-DFRAMEWORK_PATH=${CMAKE_SOURCE_DIR}
						-DTARGET_FRAMEWORK=${PROJECT_NAME}
						-DJEKYLL_EXECUTABLE=${JEKYLL_EXECUTABLE}
						-DFRAMEWORK_BASE_URL=${STATIC_SITE_BASEURL}
						-P ${WORKSPACE_DIR}/share/cmake/system/Serve_PID_Framework.cmake
		COMMENT "[PID] Serving the static site of the framework ${PROJECT_NAME} ..."
		VERBATIM
	)

	else()
		message("[PID] ERROR: the jekyll executable cannot be found in the system, please install it and put it in a standard path.")
	endif()
else()
	message("[PID] ERROR : please run cmake in the build folder of the framework ${PROJECT_NAME}.")
	return()
endif()
endmacro(declare_Framework)

###
macro(declare_Framework_Image image_file_path is_banner)
set(IMG_TYPE ${is_banner})
if(IMG_TYPE)
	set(${PROJECT_NAME}_FRAMEWORK_BANNER_IMAGE_FILE_NAME ${image_file_path})
else() #this is a logo
	set(${PROJECT_NAME}_FRAMEWORK_LOGO_IMAGE_FILE_NAME ${image_file_path})
endif()

endmacro(declare_Framework_Image)


###
function(add_Framework_Author author institution)
	set(res_string_author)
	foreach(string_el IN ITEMS ${author})
		set(res_string_author "${res_string_author}_${string_el}")
	endforeach()
	set(res_string_instit)
	foreach(string_el IN ITEMS ${institution})
		set(res_string_instit "${res_string_instit}_${string_el}")
	endforeach()
	set(${PROJECT_NAME}_FRAMEWORK_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_FRAMEWORK_AUTHORS_AND_INSTITUTIONS};${res_string_author}(${res_string_instit})" CACHE INTERNAL "")
endfunction(add_Framework_Author)


###
function(add_Framework_Category category_spec)
	set(${PROJECT_NAME}_FRAMEWORK_CATEGORIES ${${PROJECT_NAME}_FRAMEWORK_CATEGORIES} ${category_spec} CACHE INTERNAL "")
endfunction(add_Framework_Category)

##################################################################################
############################### building the framework ###########################
##################################################################################


############ function used to create the README.md file of the framework  ###########
function(generate_Framework_Readme_File)
set(README_CONFIG_FILE ${WORKSPACE_DIR}/share/patterns/frameworks/README.md.in)


set(FRAMEWORK_NAME ${PROJECT_NAME})
set(FRAMEWORK_SITE ${${PROJECT_NAME}_FRAMEWORK_SITE})
set(README_OVERVIEW "${${PROJECT_NAME}_FRAMEWORK_DESCRIPTION}") #if no detailed description provided by wiki description use the short one


if(${PROJECT_NAME}_FRAMEWORK_LICENSE)
	set(LICENSE_FOR_README "The license that applies to this repository project is **${${PROJECT_NAME}_FRAMEWORK_LICENSE}**.")
else()
	set(LICENSE_FOR_README "The package has no license defined yet.")
endif()

set(README_AUTHORS_LIST "")

foreach(author IN ITEMS ${${PROJECT_NAME}_FRAMEWORK_AUTHORS_AND_INSTITUTIONS})
	generate_Full_Author_String(${author} STRING_TO_APPEND)
	set(README_AUTHORS_LIST "${README_AUTHORS_LIST}\n+ ${STRING_TO_APPEND}")
endforeach()

get_Formatted_Framework_Contact_String(${PROJECT_NAME} RES_STRING)
set(README_CONTACT_AUTHOR "${RES_STRING}")

configure_file(${README_CONFIG_FILE} ${CMAKE_SOURCE_DIR}/README.md @ONLY)#put it in the source dir
endfunction(generate_Framework_Readme_File)

############ function used to create the license.txt file of the package  ###########
function(generate_Framework_License_File)
if(	DEFINED ${PROJECT_NAME}_FRAMEWORK_LICENSE
	AND NOT ${${PROJECT_NAME}_FRAMEWORK_LICENSE} STREQUAL "")

	find_file(	LICENSE
			"License${${PROJECT_NAME}_FRAMEWORK_LICENSE}.cmake"
			PATH "${WORKSPACE_DIR}/share/cmake/licenses"
			NO_DEFAULT_PATH
		)
	set(LICENSE ${LICENSE} CACHE INTERNAL "")

	if(LICENSE_IN-NOTFOUND)
		message("[PID] WARNING : license configuration file for ${${PROJECT_NAME}_FRAMEWORK_LICENSE} not found in workspace, license file will not be generated")
	else()
		foreach(author IN ITEMS ${${PROJECT_NAME}_FRAMEWORK_AUTHORS_AND_INSTITUTIONS})
			generate_Full_Author_String(${author} STRING_TO_APPEND)
			set(${PROJECT_NAME}_FRAMEWORK_AUTHORS_LIST "${${PROJECT_NAME}_FRAMEWORK_AUTHORS_LIST} ${STRING_TO_APPEND}")
		endforeach()
		include(${WORKSPACE_DIR}/share/cmake/licenses/License${${PROJECT_NAME}_FRAMEWORK_LICENSE}.cmake)
		file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
	endif()
endif()
endfunction(generate_Framework_License_File)


############ function used to generate data files for jekyll  ###########
function(generate_Framework_Data)
# 1) generate the basic site structure and default files from a pattern
if(EXISTS ${CMAKE_BINARY_DIR}/to_generate)
	file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/to_generate)
endif()
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/to_generate)

execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${WORKSPACE_DIR}/share/patterns/frameworks/static ${CMAKE_BINARY_DIR}/to_generate
		COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/to_generate/_data)

# 2) generate the data file containing general information about the framework (generated from a CMake pattern file)
set(FRAMEWORK_NAME ${PROJECT_NAME})
if(${PROJECT_NAME}_FRAMEWORK_SITE)
	get_Jekyll_URLs(${${PROJECT_NAME}_FRAMEWORK_SITE} PUBLIC_URL BASE_URL)
	set(FRAMEWORK_SITE_URL ${PUBLIC_URL})
	if(BASE_URL AND NOT BASE_URL STREQUAL "")
		set(FRAMEWORK_SITE_BASE_FOLDER "/${BASE_URL}")
	else()
		set(FRAMEWORK_SITE_BASE_FOLDER)
	endif()
else()
	set(FRAMEWORK_SITE_URL)
	set(FRAMEWORK_SITE_BASE_FOLDER)
endif()

set(FRAMEWORK_PROJECT_REPOSITORY_PAGE ${${PROJECT_NAME}_FRAMEWORK_PROJECT_PAGE})
get_Formatted_Framework_Contact_String(${PROJECT_NAME} RES_STRING)
set(FRAMEWORK_MAINTAINER_NAME ${RES_STRING})
set(FRAMEWORK_MAINTAINER_MAIL ${${PROJECT_NAME}_FRAMEWORK_CONTACT_MAIL})
set(FRAMEWORK_DESCRIPTION ${${PROJECT_NAME}_FRAMEWORK_DESCRIPTION})
set(FRAMEWORK_BANNER ${${PROJECT_NAME}_FRAMEWORK_BANNER_IMAGE_FILE_NAME})
set(FRAMEWORK_LOGO ${${PROJECT_NAME}_FRAMEWORK_LOGO_IMAGE_FILE_NAME})
configure_file(${WORKSPACE_DIR}/share/patterns/frameworks/framework.yml.in ${CMAKE_BINARY_DIR}/to_generate/_data/framework.yml @ONLY)

# 3) generate the data file defining categories managed by the framework (generated from scratch)
file(WRITE ${CMAKE_BINARY_DIR}/to_generate/_data/categories.yml "")
if(${PROJECT_NAME}_FRAMEWORK_CATEGORIES)
	foreach(cat IN ITEMS ${${PROJECT_NAME}_FRAMEWORK_CATEGORIES})
		extract_All_Words_From_Path(${cat} "_" LIST_OF_NAMES)
		list(LENGTH LIST_OF_NAMES SIZE)
		set(FINAL_NAME "")
		if(SIZE GREATER 1)# there are subcategories
			foreach(name IN ITEMS ${LIST_OF_NAMES})
				extract_All_Words(${name} "_" NEW_NAMES)# replace underscores with spaces

				fill_List_Into_String("${NEW_NAMES}" RES_STRING)
				set(FINAL_NAME "${FINAL_NAME} ${RES_STRING}")
				math(EXPR SIZE '${SIZE}-1')
				if(SIZE GREATER 0) #there is more than on categrization level remaining
					set(FINAL_NAME "${FINAL_NAME}/ ")
				endif()

			endforeach()
			file(APPEND ${CMAKE_BINARY_DIR}/to_generate/_data/categories.yml "- name: \"${FINAL_NAME}\"\n  index: \"${cat}\"\n\n")
		else()
			extract_All_Words(${cat} "_" NEW_NAMES)# replace underscores with spaces
			fill_List_Into_String("${NEW_NAMES}" RES_STRING)
			set(FINAL_NAME "${RES_STRING}")
			file(APPEND ${CMAKE_BINARY_DIR}/to_generate/_data/categories.yml "- name: \"${FINAL_NAME}\"\n  index: \"${cat}\"\n\n")
		endif()
	endforeach()
endif()

# 4) generate the configuration file for jekyll generation

configure_file(${WORKSPACE_DIR}/share/patterns/frameworks/_config.yml.in ${CMAKE_BINARY_DIR}/to_generate/_config.yml @ONLY)

endfunction(generate_Framework_Data)


### generate the reference file used to retrieve packages
function(generate_Framework_Reference_File pathtonewfile)
set(file ${pathtonewfile})
file(WRITE ${file} "")

file(APPEND ${file} "#### referencing package ${PROJECT_NAME} mode ####\n")
file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK_MAIN_AUTHOR ${${PROJECT_NAME}_FRAMEWORK_MAIN_AUTHOR} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK_MAIN_INSTITUTION ${${PROJECT_NAME}_FRAMEWORK_MAIN_INSTITUTION} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK_YEARS ${${PROJECT_NAME}_FRAMEWORK_YEARS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK_CONTACT_MAIL ${${PROJECT_NAME}_FRAMEWORK_CONTACT_MAIL} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK_SITE ${${PROJECT_NAME}_FRAMEWORK_SITE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK_PROJECT_PAGE ${${PROJECT_NAME}_FRAMEWORK_PROJECT_PAGE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK_DESCRIPTION ${${PROJECT_NAME}_FRAMEWORK_DESCRIPTION} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK_LICENSE ${${PROJECT_NAME}_FRAMEWORK_LICENSE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK_ADDRESS ${${PROJECT_NAME}_FRAMEWORK_ADDRESS} CACHE INTERNAL \"\")\n")

# writing concise author information
set(res_string "")
foreach(auth IN ITEMS ${${PROJECT_NAME}_FRAMEWORK_AUTHORS_AND_INSTITUTIONS})
	list(APPEND res_string ${auth})
endforeach()
set(printed_authors "${res_string}")
file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK_AUTHORS_AND_INSTITUTIONS \"${res_string}\" CACHE INTERNAL \"\")\n")

# writing concise category information
if(${PROJECT_NAME}_FRAMEWORK_CATEGORIES)
	file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK_CATEGORIES \"${${PROJECT_NAME}_FRAMEWORK_CATEGORIES}\" CACHE INTERNAL \"\")\n")
else()
	file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK_CATEGORIES CACHE INTERNAL \"\")\n")
endif()

endfunction(generate_Framework_Reference_File)



### generating cmake script files that reference the binaries of framework's packages
function(generate_Framework_Binary_References)
set(dir ${CMAKE_SOURCE_DIR}/src/_packages)
list_Subdirectories(ALL_PACKAGES ${dir})
if(ALL_PACKAGES)
	foreach(package IN ITEMS ${ALL_PACKAGES})
		generate_Framework_Binary_Reference_For_Package(${package} TRUE)
	endforeach()
endif()
#dealing also with external packages (no documentation only binary references)
set(dir ${CMAKE_SOURCE_DIR}/src/_external)
list_Subdirectories(ALL_PACKAGES ${dir})
if(ALL_PACKAGES)
	foreach(package IN ITEMS ${ALL_PACKAGES})
		generate_Framework_Binary_Reference_For_Package(${package} FALSE)
	endforeach()
endif()

endfunction(generate_Framework_Binary_References)


### create the file for listing binaries of a given package in the framework
function(generate_Package_Page_Binaries_In_Framework package)
set(PACKAGE_NAME ${package})
configure_file(${WORKSPACE_DIR}/share/patterns/static_sites/binaries.md.in ${CMAKE_SOURCE_DIR}/src/_packages/${package}/pages/binaries.md @ONLY)
endfunction(generate_Package_Page_Binaries_In_Framework)

### create the file for presenting an external package and listing its binaries in the framework
function(generate_External_Page_In_Framework package)
set(PATH_TO_PAGE ${CMAKE_SOURCE_DIR}/src/_external/${package}/index.md)
set(PATH_TO_REFERENCE_FILE ${WORKSPACE_DIR}/share/cmake/references/ReferExternal${package}.cmake)
if(NOT EXISTS ${PATH_TO_REFERENCE_FILE})
	message("[PID] WARNING : refernce file to package ${package} does not exists !")
	return()
endif()
if(EXISTS ${PATH_TO_PAGE}) #remove the file to be sure
	file(REMOVE ${PATH_TO_PAGE})
endif()

include(${PATH_TO_REFERENCE_FILE})

set(EXTERNAL_PACKAGE_NAME ${package})

fill_List_Into_String("${${package}_DESCRIPTION}" DESCRIPTION_STRING)
set(EXTERNAL_PACKAGE_DESCRIPTION ${DESCRIPTION_STRING})

set(EXTERNAL_PACKAGE_AUTHORS ${${package}_AUTHORS})
set(EXTERNAL_PACKAGE_LICENSE ${${package}_LICENSES})

# managing categories
if(NOT ${package}_CATEGORIES)
	set(EXTERNAL_PACKAGE_CATEGORIES)
else()
	list(LENGTH ${package}_CATEGORIES SIZE)
	if(SIZE EQUAL 1)
		set(EXTERNAL_PACKAGE_CATEGORIES ${${package}_CATEGORIES})
	else()
		set(EXTERNAL_PACKAGE_CATEGORIES "[")
		set(idx 0)
		foreach(cat IN ITEMS ${${package}_CATEGORIES})
			set(EXTERNAL_PACKAGE_CATEGORIES "${EXTERNAL_PACKAGE_CATEGORIES}${cat}")
			math(EXPR idx '${idx}+1')
			if(NOT idx EQUAL SIZE)
				set(EXTERNAL_PACKAGE_CATEGORIES "${EXTERNAL_PACKAGE_CATEGORIES},")
			endif()
		endforeach()
		set(EXTERNAL_PACKAGE_CATEGORIES "${EXTERNAL_PACKAGE_CATEGORIES}]")
	endif()
endif()
# managing binaries
set(binary_dir ${CMAKE_SOURCE_DIR}/src/_external/${package})
list_Version_Subdirectories(ALL_VERSIONS ${binary_dir})
set(PRINTED_VERSIONS)
if(ALL_VERSIONS)
	foreach(ref_version IN ITEMS ${ALL_VERSIONS}) #for each available version, all os for which there is a reference
		set(${ref_version}_PRINTED_PLATFORM)
		# binaries may be referenced with subdirectories (basic case)
		list_Platform_Subdirectories(ALL_PLATFORMS ${binary_dir}/${ref_version})
		if(ALL_PLATFORMS)
			foreach(ref_platform IN ITEMS ${ALL_PLATFORMS})#for each platform of this version
				# now referencing the binaries
				list_Regular_Files(ALL_BINARIES ${binary_dir}/${ref_version}/${ref_platform})
				if(ALL_BINARIES AND EXISTS ${binary_dir}/${ref_version}/${ref_platform}/${package}-${ref_version}-${ref_platform}.tar.gz) # check to avoid problem is the binaries have been badly published
					list(APPEND PRINTED_VERSIONS ${ref_version})
					list(APPEND ${ref_version}_PRINTED_PLATFORM ${ref_platform})
				endif()
			endforeach()
		endif()

		# binaries may also be referenced with symlinks (case when different platform can share the same binary package, typical with header only libraries)
		list_Platform_Symlinks(ALL_PLATFORMS ${binary_dir}/${ref_version})
		if(ALL_PLATFORMS)
			foreach(ref_platform IN ITEMS ${ALL_PLATFORMS})#for each platform of this version
				# now referencing the binaries
				list_Regular_Files(ALL_BINARIES ${binary_dir}/${ref_version}/${ref_platform})
				if(ALL_BINARIES) #do not check for binary archive name since it may differ from standard regarding platform (king of generic platform name may be used)

					list(APPEND PRINTED_VERSIONS ${ref_version})
					list(APPEND ${ref_version}_PRINTED_PLATFORM ${ref_platform})
				endif()
			endforeach()
		endif()
	endforeach()
endif()
if(PRINTED_VERSIONS)
list(REMOVE_DUPLICATES PRINTED_VERSIONS)
foreach(version IN ITEMS ${PRINTED_VERSIONS})
	set(EXTERNAL_PACKAGE_BINARIES "${EXTERNAL_PACKAGE_BINARIES}\n### ${version}\n\n")
	foreach(platform IN ITEMS ${${version}_PRINTED_PLATFORM})
		set(EXTERNAL_PACKAGE_BINARIES "${EXTERNAL_PACKAGE_BINARIES} + ${platform}\n")
	endforeach()
endforeach()
set(EXTERNAL_PACKAGE_BINARIES "${EXTERNAL_PACKAGE_BINARIES}\n")
else()
	set(EXTERNAL_PACKAGE_BINARIES "There is no binary provided for this package !")
endif()
configure_file(${WORKSPACE_DIR}/share/patterns/frameworks/external_index.md.in ${PATH_TO_PAGE} @ONLY)
endfunction(generate_External_Page_In_Framework)

### generating a cmake script files that references the binaries for a given package (native or external) that has been put into the framework
function(generate_Framework_Binary_Reference_For_Package package native)
if(native)
	generate_Package_Page_Binaries_In_Framework(${package}) # create markdown page listing available binaries
	set(dir ${CMAKE_SOURCE_DIR}/src/_packages/${package}/binaries)
else() # external packages have different deployment
	generate_External_Page_In_Framework(${package})
	set(dir ${CMAKE_SOURCE_DIR}/src/_external/${package})
endif()

set(${package}_FRAMEWORK_REFERENCES)
set(file ${dir}/binary_references.cmake)
file(WRITE ${file} "# Contains references to binaries that are available for ${package} \n")
#this may overwrite binary references hard coded in the reference file, or simply add new ones

##################################################################
### all available versions of the package for which there is a ###
### reference to a downloadable binary for any platform ##########
##################################################################
list_Version_Subdirectories(ALL_VERSIONS ${dir})

if(ALL_VERSIONS)
	foreach(ref_version IN ITEMS ${ALL_VERSIONS}) #for each available version, all os for which there is a reference

		list_Platform_Subdirectories(ALL_PLATFORMS ${dir}/${ref_version})
		if(ALL_PLATFORMS)
			foreach(ref_platform IN ITEMS ${ALL_PLATFORMS})#for each platform of this version
				# now referencing the binaries
				list_Regular_Files(ALL_BINARIES ${dir}/${ref_version}/${ref_platform})

				if(ALL_BINARIES) # check to avoid problem is the binaries have been badly released

					# the version is registered only if there are binaries inside (sanity check)
					if(native AND EXISTS ${dir}/${ref_version}/${ref_platform}/${package}-${ref_version}-${ref_platform}.tar.gz
						  AND EXISTS ${dir}/${ref_version}/${ref_platform}/${package}-${ref_version}-dbg-${ref_platform}.tar.gz)# both release and binary versions have to exist for native packages
						set(${package}_FRAMEWORK_REFERENCES ${${package}_FRAMEWORK_REFERENCES} ${ref_version})
						set(${package}_FRAMEWORK_REFERENCE_${ref_version} ${${package}_FRAMEWORK_REFERENCE_${ref_version}} ${ref_platform})
						set(${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_URL ${${PROJECT_NAME}_FRAMEWORK_SITE}/packages/${package}/binaries/${ref_version}/${ref_platform}/${package}-${ref_version}-${ref_platform}.tar.gz)
						set(${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG ${${PROJECT_NAME}_FRAMEWORK_SITE}/packages/${package}/binaries/${ref_version}/${ref_platform}/${package}-${ref_version}-dbg-${ref_platform}.tar.gz)
					elseif(NOT NATIVE AND EXISTS ${dir}/${ref_version}/${ref_platform}/${package}-${ref_version}-${ref_platform}.tar.gz) #at least a release version is required for external packages

						set(${package}_FRAMEWORK_REFERENCES ${${package}_FRAMEWORK_REFERENCES} ${ref_version})
						set(${package}_FRAMEWORK_REFERENCE_${ref_version} ${${package}_FRAMEWORK_REFERENCE_${ref_version}} ${ref_platform})
						set(${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_URL ${${PROJECT_NAME}_FRAMEWORK_SITE}/external/${package}/${ref_version}/${ref_platform}/${package}-${ref_version}-${ref_platform}.tar.gz)
						set(${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_FOLDER ${package}-${ref_version}-${ref_platform})
						if(EXISTS ${dir}/${ref_version}/${ref_platform}/${package}-${ref_version}-dbg-${ref_platform}.tar.gz)
							set(${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG ${${PROJECT_NAME}_FRAMEWORK_SITE}/external/${package}/${ref_version}/${ref_platform}/${package}-${ref_version}-dbg-${ref_platform}.tar.gz)
							set(${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_FOLDER_DEBUG ${package}-${ref_version}-dbg-${ref_platform})
						endif()
					endif()
				endif()
			endforeach()
		endif()
		if(NOT native) # testing the reference on external with symlinks
			list_Platform_Symlinks(ALL_PLATFORMS ${dir}/${ref_version})
			if(ALL_PLATFORMS)
				foreach(ref_platform IN ITEMS ${ALL_PLATFORMS})#for each platform of this version
					# now referencing the binaries
					list_Regular_Files(ALL_BINARIES ${dir}/${ref_version}/${ref_platform})
					if(ALL_BINARIES) #do not check for binary archive name since it may differ from standard regarding platform (kind of generic platform name may be used instead of the symink one)
						set(RELEASE_BINARY)
						set(DEBUG_BINARY)
						foreach(binary IN ITEMS ${ALL_BINARIES})
							string(REGEX REPLACE "^${package}-${ref_version}-dbg-([^\\.]+)\\.tar\\.gz$" "\\1" RES ${binary})
							if(NOT RES STREQUAL "${binary}") # package binary debug with any kind of platform
								set(DEBUG_BINARY ${RES})
							else()
								string(REGEX REPLACE "^${package}-${ref_version}-([^\\.]*)\\.tar\\.gz$" "\\1" RES ${binary})
								if(NOT RES STREQUAL "${binary}") # package binary release with any kind of platform
									set(RELEASE_BINARY ${RES})
								endif()

							endif()
						endforeach()
						if(RELEASE_BINARY) #if no release version do nothing
							set(${package}_FRAMEWORK_REFERENCES ${${package}_FRAMEWORK_REFERENCES} ${ref_version}) #adding the version
							set(${package}_FRAMEWORK_REFERENCE_${ref_version} ${${package}_FRAMEWORK_REFERENCE_${ref_version}} ${ref_platform}) #adding the platform

							set(${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_URL ${${PROJECT_NAME}_FRAMEWORK_SITE}/external/${package}/${ref_version}/${RELEASE_BINARY}/${package}-${ref_version}-${RELEASE_BINARY}.tar.gz)
							set(${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_FOLDER ${package}-${ref_version}-${RELEASE_BINARY})
							if(DEBUG_BINARY)
								set(${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG ${${PROJECT_NAME}_FRAMEWORK_SITE}/external/${package}/${ref_version}/${DEBUG_BINARY}/${package}-${ref_version}-dbg-${DEBUG_BINARY}.tar.gz)
								set(${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_FOLDER_DEBUG ${package}-${ref_version}-dbg-${DEBUG_BINARY})

							endif()
						endif()

					endif()
				endforeach()
			endif()
		endif()
	endforeach()

	if(${package}_FRAMEWORK_REFERENCES)
		list(REMOVE_DUPLICATES ${package}_FRAMEWORK_REFERENCES)
		file(APPEND ${file} "set(${package}_REFERENCES ${${package}_FRAMEWORK_REFERENCES} CACHE INTERNAL \"\")\n") # the version is registered
		foreach(ref_version IN ITEMS ${${package}_FRAMEWORK_REFERENCES})
			list(REMOVE_DUPLICATES ${package}_FRAMEWORK_REFERENCE_${ref_version})
			file(APPEND ${file} "set(${package}_REFERENCE_${ref_version} ${${package}_FRAMEWORK_REFERENCE_${ref_version}} CACHE INTERNAL \"\")\n")
			foreach(ref_platform IN ITEMS ${${package}_FRAMEWORK_REFERENCE_${ref_version}}) #there is at least one platform referenced so no need to test for nullity

				#release binary referencing
				file(APPEND ${file} "set(${package}_REFERENCE_${ref_version}_${ref_platform}_URL ${${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_URL} CACHE INTERNAL \"\")\n")#reference on the release binary
				if(NOT native)
					file(APPEND ${file} "set(${package}_REFERENCE_${ref_version}_${ref_platform}_FOLDER ${${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_FOLDER} CACHE INTERNAL \"\")\n")# name of the folder contained in the archive
				endif()

				#debug binary referencing
				if(${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG) #always true for native packages, may be true for native packages
					file(APPEND ${file} "set(${package}_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG ${${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG} CACHE INTERNAL \"\")\n")#reference on the debug binary
					if(NOT native)
						file(APPEND ${file} "set(${package}_REFERENCE_${ref_version}_${ref_platform}_FOLDER_DEBUG ${${package}_FRAMEWORK_REFERENCE_${ref_version}_${ref_platform}_FOLDER_DEBUG} CACHE INTERNAL \"\")\n")#name of the folder contained in the archive
					endif()
				endif()
			endforeach()
		endforeach()
	endif()
endif()
endfunction(generate_Framework_Binary_Reference_For_Package)



### main function for building the package
macro(build_Framework)

####################################################
############ CONFIGURING the BUILD #################
####################################################

# configuring all that can be configured from framework description
generate_Framework_Readme_File() # generating and putting into source directory the readme file used by gitlab
generate_Framework_License_File() # generating and putting into source directory the file containing license info about the package
generate_Framework_Data() # generating the data files for jekyll (result in the build tree)

generate_Framework_Binary_References() # generating in the project the cmake script files that allow to find references on packages of the framework

# build steps
# 1) create or clean the "generated" folder in build tree.
# 2) create or clean the "to_generate" folder in build tree. When created all files are copied from "static" folder of framework pattern. When cleaned only user specific code is removed
# 3) copy all framework specific content from src (hand written or generated by packages) INTO the "to_generate" folder.
# 4) call jekyll on the "to_generate" folder with "generated" has output => the output site is in the "generated" folder of the build tree.

#########################################################################################################################
######### writing the global reference file for the package with all global info contained in the CMakeFile.txt #########
#########################################################################################################################
if(${PROJECT_NAME}_FRAMEWORK_ADDRESS)
	generate_Framework_Reference_File(${CMAKE_BINARY_DIR}/share/ReferFramework${PROJECT_NAME}.cmake)
	#copy the reference file of the package into the "references" folder of the workspace
	add_custom_target(referencing
		COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/share/ReferFramework${PROJECT_NAME}.cmake ${WORKSPACE_DIR}/share/cmake/references
		COMMAND ${CMAKE_COMMAND} -E echo "Framework references have been registered into the worskpace"
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
endif()

endmacro(build_Framework)
