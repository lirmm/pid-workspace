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

##########################################################################################
############################ Guard for optimization of configuration process #############
##########################################################################################
if(PID_META_INFORMATION_MANAGEMENT_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_META_INFORMATION_MANAGEMENT_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Author| replace:: ``add_Author``
#  .. _add_Author:
#
#  add_Author
#  ----------
#
#   .. command:: add_Author(author institution)
#
#     Add an author to the list of current project authors.
#
#      :author: The name of the author.
#
#      :institution: the name of author institution.
#
function(add_Author author institution)
	set(res_string_author)
	foreach(string_el IN LISTS author)
		set(res_string_author "${res_string_author}_${string_el}")
	endforeach()
	set(res_string_instit)
	foreach(string_el IN LISTS institution)
		set(res_string_instit "${res_string_instit}_${string_el}")
	endforeach()
	if(res_string_instit)
		set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS};${res_string_author}(${res_string_instit})" CACHE INTERNAL "")
	else() #no institution given
		set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS};${res_string_author}" CACHE INTERNAL "")
	endif()
endfunction(add_Author)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Category| replace:: ``add_Category``
#  .. _add_Category:
#
#  add_Category
#  ------------
#
#   .. command:: add_Category(category)
#
#     Add a category to the current project.
#
#      :category: The string representing the category. May be expressed as a path if it defines a subcategory (e.g. math/geometry)
#
function(add_Category category)
	set(${PROJECT_NAME}_CATEGORIES ${${PROJECT_NAME}_CATEGORIES} ${category} CACHE INTERNAL "")
endfunction(add_Category)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Reference| replace:: ``add_Reference``
#  .. _add_Reference:
#
#  add_Reference
#  -------------
#
#   .. command:: add_Reference(version platform url url-dbg)
#
#     Add a direct reference to a binary archive for a given version of the current project.
#
#      :version: version of the binary archive content.
#
#      :platform: target platform for binary archive content.
#
#      :url: url where to find the binary archive for release mode content.
#
#      :url-dbg: url where to find the binary archive for debug mode content.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_References_Info| replace:: ``reset_References_Info``
#  .. _reset_References_Info:
#
#  reset_References_Info
#  ---------------------
#
#   .. command:: reset_References_Info()
#
#     Reset all direct references to binary archives in current project.
#
function(reset_References_Info)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")
	# references to package binaries version available must be reset
	foreach(ref_version IN LISTS ${PROJECT_NAME}_REFERENCES)
		foreach(ref_platform IN LISTS ${PROJECT_NAME}_REFERENCE_${ref_version})
			set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL CACHE INTERNAL "")
			set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG CACHE INTERNAL "")
		endforeach()
		set(${PROJECT_NAME}_REFERENCE_${ref_version} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_REFERENCES CACHE INTERNAL "")
endif()
endfunction(reset_References_Info)

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Meta_Info_Cache_Variables| replace:: ``init_Meta_Info_Cache_Variables``
#  .. _init_Meta_Info_Cache_Variables:
#
#  init_Meta_Info_Cache_Variables
#  ------------------------------
#
#   .. command:: init_Meta_Info_Cache_Variables(author institution mail description year license address public_address readme_file)
#
#     Resetting meta information variables to be sure package is cleaned before configruation, then initialize variable describing meta information on current project.
#
#      :author: name of the contact author.
#
#      :institution: name of contact author institution.
#
#      :mail: email of the contact author.
#
#      :description: description of current project.
#
#      :year: current project lifecycle dates
#
#      :license: license applying to current project.
#
#      :address: private git address (used by project developpers and registered members)
#
#      :public_address: public https git address (use to clone project without restriction)
#
#      :readme_file: the user defined readme file for the current project.
#
function(init_Meta_Info_Cache_Variables author institution mail description year license address public_address readme_file)
set(res_string_auth "")
foreach(string_el IN LISTS author)
	set(res_string_auth "${res_string_auth}_${string_el}")
endforeach()

set(res_string_instit "")
foreach(string_el IN LISTS institution)
	set(res_string_instit "${res_string_instit}_${string_el}")
endforeach()

if( CMAKE_MAJOR_VERSION VERSION_GREATER 3
    OR (CMAKE_MAJOR_VERSION VERSION_EQUAL 3 AND CMAKE_MINOR_VERSION VERSION_GREATER 12))
    #starting from version 3.13 project command generates the ${PROJECT_NAME}_DESCRIPTION variable
  if(DEFINED ${PROJECT_NAME}_DESCRIPTION)
  	unset(${PROJECT_NAME}_DESCRIPTION PARENT_SCOPE)#unset this normal variable
  endif()
endif()

set(REGENERATE_LICENSE FALSE CACHE INTERNAL "")
if(	NOT ${PROJECT_NAME}_LICENSE STREQUAL license OR
		NOT ${PROJECT_NAME}_YEARS STREQUAL year OR
		NOT ${PROJECT_NAME}_DESCRIPTION STREQUAL description OR
		NOT ${PROJECT_NAME}_MAIN_AUTHOR STREQUAL res_string_auth OR
		NOT ${PROJECT_NAME}_MAIN_INSTITUTION STREQUAL res_string_instit
	)
	set(REGENERATE_LICENSE TRUE CACHE INTERNAL "")
endif()
set(${PROJECT_NAME}_MAIN_AUTHOR "${res_string_auth}" CACHE INTERNAL "")

set(${PROJECT_NAME}_MAIN_INSTITUTION "${res_string_instit}" CACHE INTERNAL "")
set(${PROJECT_NAME}_CONTACT_MAIL ${mail} CACHE INTERNAL "")
if(NOT res_string STREQUAL "")
	set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_MAIN_AUTHOR}(${${PROJECT_NAME}_MAIN_INSTITUTION})" CACHE INTERNAL "")
else()
	set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_MAIN_AUTHOR}" CACHE INTERNAL "")
endif()

set(${PROJECT_NAME}_DESCRIPTION "${description}" CACHE INTERNAL "")
set(${PROJECT_NAME}_YEARS ${year} CACHE INTERNAL "")
set(${PROJECT_NAME}_LICENSE ${license} CACHE INTERNAL "")
set(${PROJECT_NAME}_ADDRESS ${address} CACHE INTERNAL "")
set(${PROJECT_NAME}_PUBLIC_ADDRESS ${public_address} CACHE INTERNAL "")
set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")#categories are reset
set(${PROJECT_NAME}_USER_README_FILE ${readme_file} CACHE INTERNAL "")
reset_References_Info()
endfunction(init_Meta_Info_Cache_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Documentation_Info_Cache_Variables| replace:: ``init_Documentation_Info_Cache_Variables``
#  .. _init_Documentation_Info_Cache_Variables:
#
#  init_Documentation_Info_Cache_Variables
#  ---------------------------------------
#
#   .. command:: init_Documentation_Info_Cache_Variables(framework project_page repo home_page introduction)
#
#     Initialize variables related to current project documentation.
#
#      :framework: name of the framework to which the current project belongs.
#
#      :project_page: online url where to find the the project page of current project.
#
#      :repo: git repository of current project static site.
#
#      :home_page: online url where to find the current project lone static site.
#
#      :introduction: The introduction text used in current project static site (lone or framework)
#
function(init_Documentation_Info_Cache_Variables framework project_page repo home_page introduction)
if(NOT framework)
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


#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Documentation_Site_Generated| replace:: ``check_Documentation_Site_Generated``
#  .. _check_Documentation_Site_Generated:
#
#  check_Documentation_Site_Generated
#  ----------------------------------
#
#   .. command:: check_Documentation_Site_Generated(GENERATED)
#
#     Check if the project generates static site pages.
#
#      :GENERATED: The output variable that is TRUE if static site may be generated from the project
#
function(check_Documentation_Site_Generated GENERATED)
if(${PROJECT_NAME}_FRAMEWORK OR ${PROJECT_NAME}_SITE_GIT_ADDRESS)
  set(${GENERATED} TRUE PARENT_SCOPE)
else()
  set(${GENERATED} FALSE PARENT_SCOPE)
endif()
endfunction(check_Documentation_Site_Generated)


#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Documentation_Info| replace:: ``reset_Documentation_Info``
#  .. _reset_Documentation_Info:
#
#  reset_Documentation_Info
#  ------------------------
#
#   .. command:: reset_Documentation_Info()
#
#     Reset all cache variables used in static web site based documentation.
#
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

#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Binaries| replace:: ``publish_Binaries``
#  .. _publish_Binaries:
#
#  publish_Binaries
#  ----------------
#
#   .. command:: publish_Binaries(true_or_false)
#
#     Set the publication policy for current project binaries.
#
#      :true_or_false: if TRUE current project CI automatically publish binary archives of current project.
#
function(publish_Binaries true_or_false)
set(${PROJECT_NAME}_BINARIES_AUTOMATIC_PUBLISHING ${true_or_false}  CACHE INTERNAL "")
endfunction(publish_Binaries)

#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Development_Info| replace:: ``publish_Development_Info``
#  .. _publish_Development_Info:
#
#  publish_Development_Info
#  ------------------------
#
#   .. command:: publish_Development_Info(true_or_false)
#
#     Set the publication policy for current project development information (coverage, static checks).
#
#      :true_or_false: if TRUE current project CI automatically publish developers information of current project.
#
function(publish_Development_Info true_or_false)
set(${PROJECT_NAME}_DEV_INFO_AUTOMATIC_PUBLISHING ${true_or_false}  CACHE INTERNAL "")
endfunction(publish_Development_Info)
