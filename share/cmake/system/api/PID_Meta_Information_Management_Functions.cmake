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

###
function(add_Author author institution)
	set(res_string_author)
	foreach(string_el IN ITEMS ${author})
		set(res_string_author "${res_string_author}_${string_el}")
	endforeach()
	set(res_string_instit)
	foreach(string_el IN ITEMS ${institution})
		set(res_string_instit "${res_string_instit}_${string_el}")
	endforeach()
	set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS};${res_string_author}(${res_string_instit})" CACHE INTERNAL "")
endfunction(add_Author)


###
function(add_Category category_spec)
	set(${PROJECT_NAME}_CATEGORIES ${${PROJECT_NAME}_CATEGORIES} ${category_spec} CACHE INTERNAL "")
endfunction(add_Category)


### add a direct reference to a binary version of the package
function(add_Reference version platform url url-dbg)
set(LIST_OF_VERSIONS ${${PROJECT_NAME}_REFERENCES} ${version})
list(REMOVE_DUPLICATES LIST_OF_VERSIONS)
set(${PROJECT_NAME}_REFERENCES  ${LIST_OF_VERSIONS} CACHE INTERNAL "")#to put the modification in cache
list(FIND ${PROJECT_NAME}_REFERENCE_${version} ${platform} INDEX)
if(INDEX EQUAL -1)#this version for tha target platform is not already registered
	set(${PROJECT_NAME}_REFERENCE_${version} ${${PROJECT_NAME}_REFERENCE_${version}} ${platform} CACHE INTERNAL "")
	set(${PROJECT_NAME}_REFERENCE_${version}_${platform}_URL ${url} CACHE INTERNAL "")
	set(${PROJECT_NAME}_REFERENCE_${version}_${platform}_URL_DEBUG ${url-dbg} CACHE INTERNAL "")
endif()
endfunction(add_Reference)

### reset variables describing direct references to binaries
function(reset_References_Info)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")
	# references to package binaries version available must be reset
	foreach(ref_version IN ITEMS ${${PROJECT_NAME}_REFERENCES})
		foreach(ref_platform IN ITEMS ${${PROJECT_NAME}_REFERENCE_${ref_version}})
			set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL CACHE INTERNAL "")
			set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG CACHE INTERNAL "")
		endforeach()
		set(${PROJECT_NAME}_REFERENCE_${ref_version} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_REFERENCES CACHE INTERNAL "")
endif()
endfunction(reset_References_Info)

### resetting meta information variables to be sure package is cleaned before configruation
function(init_Meta_Info_Cache_Variables author institution mail description year license address public_address readme_file)
set(res_string)
foreach(string_el IN ITEMS ${author})
	set(res_string "${res_string}_${string_el}")
endforeach()
set(${PROJECT_NAME}_MAIN_AUTHOR "${res_string}" CACHE INTERNAL "")

set(res_string "")
foreach(string_el IN ITEMS ${institution})
	set(res_string "${res_string}_${string_el}")
endforeach()
set(${PROJECT_NAME}_MAIN_INSTITUTION "${res_string}" CACHE INTERNAL "")
set(${PROJECT_NAME}_CONTACT_MAIL ${mail} CACHE INTERNAL "")

set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_MAIN_AUTHOR}(${${PROJECT_NAME}_MAIN_INSTITUTION})" CACHE INTERNAL "")
set(${PROJECT_NAME}_DESCRIPTION "${description}" CACHE INTERNAL "")
set(${PROJECT_NAME}_YEARS ${year} CACHE INTERNAL "")
set(${PROJECT_NAME}_LICENSE ${license} CACHE INTERNAL "")
set(${PROJECT_NAME}_ADDRESS ${address} CACHE INTERNAL "")
set(${PROJECT_NAME}_PUBLIC_ADDRESS ${public_address} CACHE INTERNAL "")
set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")#categories are reset
set(${PROJECT_NAME}_USER_README_FILE ${readme_file} CACHE INTERNAL "")
reset_References_Info()
endfunction(init_Meta_Info_Cache_Variables)

### documentation sites related cache variables management
function(init_Documentation_Info_Cache_Variables framework project_page repo home_page introduction)
if(framework STREQUAL "")
	set(${PROJECT_NAME}_FRAMEWORK CACHE INTERNAL "")
	set(${PROJECT_NAME}_PROJECT_PAGE ${project_page} CACHE INTERNAL "")
	set(${PROJECT_NAME}_SITE_ROOT_PAGE "${home_page}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_SITE_GIT_ADDRESS "${repo}" CACHE INTERNAL "")
else()
	set(${PROJECT_NAME}_FRAMEWORK ${framework} CACHE INTERNAL "")
	set(${PROJECT_NAME}_PROJECT_PAGE ${project_page} CACHE INTERNAL "")
	set(${PROJECT_NAME}_SITE_ROOT_PAGE CACHE INTERNAL "")
	set(${PROJECT_NAME}_SITE_GIT_ADDRESS CACHE INTERNAL "")
endif()
set(${PROJECT_NAME}_SITE_INTRODUCTION "${introduction}" CACHE INTERNAL "")
endfunction(init_Documentation_Info_Cache_Variables)


### defining a framework static site the project belongs to
macro(define_Framework_Contribution framework url description)
if(${PROJECT_NAME}_FRAMEWORK AND (NOT ${PROJECT_NAME}_FRAMEWORK STREQUAL ""))
	message("[PID] ERROR: a framework (${${PROJECT_NAME}_FRAMEWORK}) has already been defined, cannot define a new one !")
	return()
elseif(${PROJECT_NAME}_SITE_GIT_ADDRESS AND (NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS STREQUAL ""))
	message("[PID] ERROR: a static site (${${PROJECT_NAME}_SITE_GIT_ADDRESS}) has already been defined, cannot define a framework !")
	return()
endif()
init_Documentation_Info_Cache_Variables("${framework}" "${url}" "" "" "${description}")
endmacro(define_Framework_Contribution)

### defining a lone static site for the package
macro(define_Static_Site_Contribution url git_repository homepage description)
if(${PROJECT_NAME}_FRAMEWORK AND (NOT ${PROJECT_NAME}_FRAMEWORK STREQUAL ""))
	message("[PID] ERROR: a framework (${${PROJECT_NAME}_FRAMEWORK}) has already been defined, cannot define a static site !")
	return()
elseif(${PROJECT_NAME}_SITE_GIT_ADDRESS AND (NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS STREQUAL ""))
	message("[PID] ERROR: a static site (${${PROJECT_NAME}_SITE_GIT_ADDRESS}) has already been defined, cannot define a new one !")
	return()
endif()
init_Documentation_Info_Cache_Variables("" "${url}" "${git_repository}" "${homepage}" "${description}")

endif()
endmacro(define_Static_Site_Contribution)

### reset all cache variables used in static web site based documentation
function(reset_Documentation_Info)
	set(${PROJECT_NAME}_FRAMEWORK CACHE INTERNAL "")
	set(${PROJECT_NAME}_PROJECT_PAGE CACHE INTERNAL "")
	set(${PROJECT_NAME}_SITE_ROOT_PAGE CACHE INTERNAL "")
	set(${PROJECT_NAME}_SITE_GIT_ADDRESS CACHE INTERNAL "")
	set(${PROJECT_NAME}_SITE_INTRODUCTION CACHE INTERNAL "")
	set(${PROJECT_NAME}_BINARIES_AUTOMATIC_PUBLISHING CACHE INTERNAL "")
	set(${PROJECT_NAME}_DEV_INFO_AUTOMATIC_PUBLISHING CACHE INTERNAL "")
	set(${PROJECT_NAME}_USER_README_FILE CACHE INTERNAL "")
endfunction(reset_Documentation_Info)

###
function(publish_Binaries true_or_false)
set(${PROJECT_NAME}_BINARIES_AUTOMATIC_PUBLISHING ${true_or_false}  CACHE INTERNAL "")
endfunction(publish_Binaries)

###
function(publish_Development_Info true_or_false)
set(${PROJECT_NAME}_DEV_INFO_AUTOMATIC_PUBLISHING ${true_or_false}  CACHE INTERNAL "")
endfunction(publish_Development_Info)

### restrict CI to a limited set of platforms using this function
function(restrict_CI platform)
	set(${PROJECT_NAME}_ALLOWED_CI_PLATFORMS ${${PROJECT_NAME}_ALLOWED_CI_PLATFORMS} ${platform} CACHE INTERNAL "")
endfunction(restrict_CI)
