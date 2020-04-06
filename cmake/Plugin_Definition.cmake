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
if(PLUGIN_DEFINITION_INCLUDED)
  return()
endif()
set(PLUGIN_DEFINITION_INCLUDED TRUE)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Package_Component_Links| replace:: ``get_Package_Component_Links``
#  .. _get_Package_Component_Links:
#
#  get_Package_Component_Links
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Package_Component_Links(PACKAGE_LIB_FOLDER_IN_INSTALL RELATIVE_LINKS PUBLIC_LINKS PRIVATE_LINKS package component)
#
#    Get compilation options and definitions of a component of a given package.
#
#      :package: target package
#
#      :component: target component
#
#      :PACKAGE_LIB_FOLDER_IN_INSTALL: The output variable that contains the path to package library folder.
#
#      :RELATIVE_LINKS: The output variable that contains path to libraries relative to PACKAGE_LIB_FOLDER_IN_INSTALL (in package install folder)
#
#      :PUBLIC_LINKS: The output variable that contains absolute path to public links (not in package install folder).
#
#      :PRIVATE_LINKS: The output variable that contains absolute path to private links (not in package install folder).
#
function(get_Package_Component_Links PACKAGE_LIB_FOLDER_IN_INSTALL RELATIVE_LINKS PUBLIC_LINKS PRIVATE_LINKS package component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
  get_Package_Type(${package} PACK_TYPE)
  get_Package_Version(RES_VERSION ${package})
  set(PATH_TO_PACKAGE_INSTALL ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${RES_VERSION})
  set(${PACKAGE_LIB_FOLDER_IN_INSTALL} ${PATH_TO_PACKAGE_INSTALL}/lib)
  set(all_relative_links)
  set(all_public_links)
  set(all_private_links)

  #finding relative links
  if(PACK_TYPE STREQUAL "NATIVE")
    is_Built_Component(BUILT ${package} ${component})
    if(BUILT)#if the library generates a binary, add it as a relative link
      list(APPEND all_relative_links ${${package}_${component}_BINARY_NAME${VAR_SUFFIX}})
    endif()
  else()#for external components we need to get all the libraries they define
    if(${package}_${component}_STATIC_LINKS${VAR_SUFFIX})
      resolve_External_Libs_Path(COMPLETE_LINKS_PATH "${${package}_${component}_STATIC_LINKS${VAR_SUFFIX}}" ${CMAKE_BUILD_TYPE})
      foreach(link IN LISTS COMPLETE_LINKS_PATH)#links are absolute or already defined "the OS way"
        if(IS_ABSOLUTE ${link}) #this is an absolute path
          if(link MATCHES "^${PATH_TO_PACKAGE_INSTALL}/lib/(.+)$")#relative relation found between the file and the workspace
            list(APPEND all_relative_links ${CMAKE_MATCH_1})
          else()
            list(APPEND all_public_links ${link})
          endif()
        else()#this is already an option so let it "as is"
          list(APPEND all_public_links ${link})
        endif()
      endforeach()
    endif()
    if(${package}_${component}_SHARED_LINKS${VAR_SUFFIX})
      resolve_External_Libs_Path(COMPLETE_LINKS_PATH "${${package}_${component}_SHARED_LINKS${VAR_SUFFIX}}" ${CMAKE_BUILD_TYPE})
      foreach(link IN LISTS COMPLETE_LINKS_PATH)#links are absolute or already defined "the OS way"
        if(IS_ABSOLUTE ${link}) #this is an absolute path
          if(link MATCHES "^${PATH_TO_PACKAGE_INSTALL}/lib/(.+)$")#relative relation found between the file and the workspace
            list(APPEND all_relative_links ${CMAKE_MATCH_1})
          else()
            list(APPEND all_public_links ${link})
          endif()
        else()#this is already an option so let it "as is"
          list(APPEND all_public_links ${link})
        endif()
      endforeach()
    endif()
  endif()

  #finding other links (private and public)
  #add to libraries the linker options used for that library
  if(${package}_${component}_LINKS${VAR_SUFFIX})
    resolve_External_Libs_Path(COMPLETE_LINKS_PATH "${${package}_${component}_LINKS${VAR_SUFFIX}}" ${CMAKE_BUILD_TYPE})
    list(APPEND all_public_links ${COMPLETE_LINKS_PATH})
  endif()

  if(${package}_${component}_SYSTEM_STATIC_LINKS${VAR_SUFFIX})
    list(APPEND all_public_links ${${package}_${component}_SYSTEM_STATIC_LINKS${VAR_SUFFIX}})#links are all defined "the OS way" in this variable => no need to convert
  endif()

  #preparing to decide if libs will be generated as public or private
  if(PACK_TYPE STREQUAL "NATIVE" AND
    (${package}_${component}_TYPE STREQUAL "HEADER"
    OR ${package}_${component}_TYPE STREQUAL "STATIC"))
    #header and static libraries always export all their dependencies
    set(FORCE_EXPORT TRUE)
  else()
    set(FORCE_EXPORT FALSE)
  endif()

	#add to private libraries the private linker options used for that library
  if(${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX})
    resolve_External_Libs_Path(COMPLETE_LINKS_PATH "${${package}_${component}_PRIVATE_LINKS${VAR_SUFFIX}}" ${CMAKE_BUILD_TYPE})
  	foreach(link IN LISTS COMPLETE_LINKS_PATH)#links are absolute or already defined "the OS way"
      if(FORCE_EXPORT)
        list(APPEND all_public_links ${link})
      else()
        list(APPEND all_private_links ${link})
      endif()
  	endforeach()
  endif()

  set(${RELATIVE_LINKS} ${all_relative_links} PARENT_SCOPE)
  set(${PUBLIC_LINKS} ${all_public_links} PARENT_SCOPE)
  set(${PRIVATE_LINKS} ${all_private_links} PARENT_SCOPE)
endfunction(get_Package_Component_Links)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Package_Component_Compilation_Info| replace:: ``get_Package_Component_Compilation_Info``
#  .. _get_Package_Component_Compilation_Info:
#
#  get_Package_Component_Compilation_Info
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Package_Component_Compilation_Info(DEFS OPTS package component)
#
#    Get compilation options and definitions of a component of a given package.
#
#      :package: target package
#
#      :component: target component
#
#      :DEFS: The output variable that contains preprocessor definitions.
#
#      :OPTS: The output variable that contains compiler options
#
function(get_Package_Component_Compilation_Info DEFS OPTS package component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
  set(${DEFS} ${${package}_${component}_DEFS${VAR_SUFFIX}} PARENT_SCOPE)
  set(${OPTS} ${${package}_${component}_OPTS${VAR_SUFFIX}} PARENT_SCOPE)
endfunction(get_Package_Component_Compilation_Info)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Package_Component_Includes| replace:: ``get_Package_Component_Includes``
#  .. _get_Package_Component_Includes:
#
#  get_Package_Component_Includes
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Package_Component_Includes(PACKAGE_INCLUDE_FOLDER_IN_INSTALL INCLUDE_DIRS_ABS INCLUDE_DIRS_REL package component)
#
#    Get include directories for a component of a given package.
#
#      :package: target package
#
#      :component: target component
#
#      :PACKAGE_INCLUDE_FOLDER_IN_INSTALL: The output variable that contains the path to package include folder.
#
#      :INCLUDE_DIRS_ABS: The output variable that contains absolute include path (not in package install folder)
#
#      :INCLUDE_DIRS_REL: The output variable that contains the include path relative to package install folder.
#
function(get_Package_Component_Includes PACKAGE_INCLUDE_FOLDER_IN_INSTALL INCLUDE_DIRS_ABS INCLUDE_DIRS_REL package component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
  get_Package_Type(${package} PACK_TYPE)
  get_Package_Version(RES_VERSION ${package})
  set(include_list_abs)
  set(include_list_rel)
  set(PATH_TO_PACKAGE_INSTALL ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${RES_VERSION})
  set(${PACKAGE_INCLUDE_FOLDER_IN_INSTALL} ${PATH_TO_PACKAGE_INSTALL}/include PARENT_SCOPE)
  if(PACK_TYPE STREQUAL "NATIVE")
    #add the include folder defined by the component
    list(APPEND include_list_rel "${${package}_${component}_HEADER_DIR_NAME}")#relative to package include
  endif()
  #add direct includes coming from OS dependencies and direct external package content referencing
  #external components do not have an implicit header dir => just check it references include folders
  if(${package}_${component}_INC_DIRS${VAR_SUFFIX})
    resolve_External_Includes_Path(COMPLETE_INCLUDES_PATH "${${package}_${component}_INC_DIRS${VAR_SUFFIX}}" ${CMAKE_BUILD_TYPE})
   	foreach(inc IN LISTS COMPLETE_INCLUDES_PATH)
      if(inc MATCHES "^${PATH_TO_PACKAGE_INSTALL}/include(.*)$")#this is an external package relative include path
        if(NOT CMAKE_MATCH_1)
          set(include_list_rel "${include_list_rel};")
        else()
          list(APPEND include_list_rel "${CMAKE_MATCH_1}")
        endif()
      else()
        is_A_System_Include_Path(${inc} IS_SYSTEM)
        if(NOT IS_SYSTEM)#not in default system include path but not in package
          list(APPEND include_list_abs "${inc}")#only in absolute
        endif()
      endif()
   	endforeach()
  endif()
  if(include_list_abs)
    list(REMOVE_DUPLICATES include_list_abs)
  endif()
  set(${INCLUDE_DIRS_ABS} "${include_list_abs}" PARENT_SCOPE)
  set(${INCLUDE_DIRS_REL} "${include_list_rel}" PARENT_SCOPE)
endfunction(get_Package_Component_Includes)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |is_Native_Package| replace:: ``is_Native_Package``
#  .. _is_Native_Package:
#
#  is_Native_Package
#  ^^^^^^^^^^^^^^^^^
#
#   .. command:: is_Native_Package(IS_NATIVE package)
#
#    Tells whether the package is native or not.
#
#      :package: target package
#
#      :IS_NATIVE: The output variable that is TRUE if package is native, FALSE otherwise
#
function(is_Native_Package IS_NATIVE package)
  get_Package_Type(${package} PACK_TYPE)
  if(PACK_TYPE STREQUAL "NATIVE")
    set(${IS_NATIVE} TRUE PARENT_SCOPE)
  else()
    set(${IS_NATIVE} FALSE PARENT_SCOPE)
  endif()
endfunction(is_Native_Package)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |is_External_Package| replace:: ``is_External_Package``
#  .. _is_External_Package:
#
#  is_External_Package
#  ^^^^^^^^^^^^^^^^^^^
#
#   .. command:: is_External_Package(IS_EXTERNAL package)
#
#    Tells whether the package is external or not.
#
#      :package: target package
#
#      :IS_EXTERNAL: The output variable that is TRUE if package is external, FALSE otherwise
#
function(is_External_Package IS_EXTERNAL package)
  get_Package_Type(${package} PACK_TYPE)
  if(PACK_TYPE STREQUAL "EXTERNAL")
    set(${IS_EXTERNAL} TRUE PARENT_SCOPE)
  else()
    set(${IS_EXTERNAL} FALSE PARENT_SCOPE)
  endif()
endfunction(is_External_Package)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Package_Project_Page| replace:: ``get_Package_Project_Page``
#  .. _get_Package_Project_Page:
#
#  get_Package_Project_Page
#  ^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Package_Project_Page(VERSION package)
#
#    Get project page of the package.
#
#      :package: target package
#
#      :URL: The output variable containing the URL  of the package's project
#
function(get_Package_Project_Page URL package)
  set(${URL} ${${package}_PROJECT_PAGE} PARENT_SCOPE)
endfunction(get_Package_Project_Page)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Package_Version| replace:: ``get_Package_Version``
#  .. _get_Package_Version:
#
#  get_Package_Version
#  ^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Package_Version(VERSION package)
#
#    Get version of the package.
#
#      :package: target package
#
#      :VERSION: The output variable containing the version number of the package
#
function(get_Package_Version VERSION package)
  if(package STREQUAL PROJECT_NAME)
    set(${VERSION} ${${package}_VERSION} PARENT_SCOPE)
  else()
    set(${VERSION} ${${package}_VERSION_STRING} PARENT_SCOPE)
  endif()
endfunction(get_Package_Version)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Description| replace:: ``get_Description``
#  .. _get_Description:
#
#  get_Description
#  ^^^^^^^^^^^^^^^
#
#   .. command:: get_Description(DESCR package component)
#
#    Get decription for the component. If none specified for the component the package description is given.
#
#      :package: target package
#
#      :component: target component
#
#      :DESCR: The output variable containing the description of the component
#
function(get_Description DESCR package component)
  if(${package}_${component}_DESCRIPTION)
    set(${DESCR} "${_PKG_CONFIG_COMPONENT_DESCRIPTION_}: ${${package}_${component}_DESCRIPTION}" PARENT_SCOPE)
  elseif(${package}_DESCRIPTION)
    set(${DESCR} "${_PKG_CONFIG_COMPONENT_DESCRIPTION_}: ${${package}_DESCRIPTION}" PARENT_SCOPE)
  endif()
endfunction(get_Description)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Package_Libraries_Dirs| replace:: ``get_Package_Libraries_Dirs``
#  .. _get_Package_Libraries_Dirs:
#
#  get_Package_Libraries_Dirs
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Package_Libraries_Dirs(ALL_INCLUDE_DIRS ALL_SOURCE_DIRS)
#
#    Get all directories of the current package containing headers and sources of libraries.
#
#      :ALL_HEADER_DIRS: The output variable containing the list of all directories containing libraries headers
#
#      :ALL_SOURCE_DIRS: The output variable containing the list of all directories containing libraries sources
#
function(get_Package_Libraries_Dirs ALL_HEADER_DIRS ALL_SOURCE_DIRS)
  set(result_headers)
  set(result_sources)
  list_Subdirectories(HEADERS_DIRS ${CMAKE_SOURCE_DIR}/include)
  foreach(dir IN LISTS HEADERS_DIRS)
    list(APPEND result_headers ${CMAKE_SOURCE_DIR}/include/${dir})
  endforeach()
  list_Subdirectories(SOURCES_DIRS ${CMAKE_SOURCE_DIR}/src)
  foreach(dir IN LISTS SOURCES_DIRS)
    list(APPEND result_sources ${CMAKE_SOURCE_DIR}/src/${dir})
  endforeach()
  set(${ALL_HEADER_DIRS} ${result_headers} PARENT_SCOPE)
  set(${ALL_SOURCE_DIRS} ${result_sources} PARENT_SCOPE)
endfunction(get_Package_Libraries_Dirs)


#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Package_Apps_Dirs| replace:: ``get_Package_Apps_Dirs``
#  .. _get_Package_Apps_Dirs:
#
#  get_Package_Apps_Dirs
#  ^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Package_Apps_Dirs(ALL_SOURCE_DIRS)
#
#    Get all directories of the current package containing sources of applications.
#
#      :ALL_SOURCE_DIRS: The output variable containing the list of all directories containing applications sources
#
function(get_Package_Apps_Dirs ALL_SOURCE_DIRS)
  list_Subdirectories(SOURCES_DIRS ${CMAKE_SOURCE_DIR}/apps)
  set(result)
  foreach(dir IN LISTS SOURCES_DIRS)
    list(APPEND result ${CMAKE_SOURCE_DIR}/apps/${dir})
  endforeach()
  set(${ALL_SOURCE_DIRS} ${result} PARENT_SCOPE)
endfunction(get_Package_Apps_Dirs)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Package_Tests_Dirs| replace:: ``get_Package_Tests_Dirs``
#  .. _get_Package_Tests_Dirs:
#
#  get_Package_Tests_Dirs
#  ^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Package_Tests_Dirs(ALL_SOURCE_DIRS)
#
#    Get all directories of the current package containing sources of tests.
#
#      :ALL_SOURCE_DIRS: The output variable containing the list of all directories containing test sources
#
function(get_Package_Tests_Dirs ALL_SOURCE_DIRS)
  list_Subdirectories(SOURCES_DIRS ${CMAKE_SOURCE_DIR}/test)
  set(result)
  foreach(dir IN LISTS SOURCES_DIRS)
    list(APPEND result ${CMAKE_SOURCE_DIR}/test/${dir})
  endforeach()
  set(${ALL_SOURCE_DIRS} ${result} PARENT_SCOPE)
endfunction(get_Package_Tests_Dirs)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |dereference_Residual_Files| replace:: ``dereference_Residual_Files``
#  .. _dereference_Residual_Files:
#
#  dereference_Residual_Files
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: dereference_Residual_Files(plugin)
#
#    Dereference the residual files of the pugins (if any) in the git repository so that they will not be part of a commit.
#
#      :list_of_git_patterns: The list of patterns to exlcude from git
#
function(dereference_Residual_Files list_of_git_patterns)

set(PATH_TO_IGNORE ${CMAKE_SOURCE_DIR}/.gitignore)
file(STRINGS ${PATH_TO_IGNORE} IGNORED_FILES)
set(rules_added FALSE)
foreach(ignored IN LISTS list_of_git_patterns)
	set(add_rule TRUE)
	foreach(already_ignored IN LISTS IGNORED_FILES) #looking if this ignore rule is already written in the .gitignore file
		if(already_ignored STREQUAL ignored)
			set(add_rule FALSE)
			break()
		endif()
	endforeach()
	if(add_rule) #only add te ignore rule if necessary
		file(APPEND ${PATH_TO_IGNORE} "${ignored}\n")
		set(rules_added TRUE)
	endif()
endforeach()
if(rules_added)
	execute_process(COMMAND git add ${PATH_TO_IGNORE} WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}) #immediately add it to git reference system to avoid big troubles
endif()
endfunction(dereference_Residual_Files)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Path_To_Environment| replace:: ``get_Path_To_Environment``
#  .. _get_Path_To_Environment:
#
#  get_Path_To_Environment
#  ^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Path_To_Environment(environment)
#
#    Get the path to the environment containing the script currently executed.
#
#      :environment: The name of environment.
#
#      :RES_PATH: The output variable containing hte path to the environment defining the script
#
function(get_Path_To_Environment RES_PATH environment)
  set(${RES_PATH} ${WORKSPACE_DIR}/environments/${environment}/src PARENT_SCOPE)
endfunction(get_Path_To_Environment)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |list_Defined_Components| replace:: ``list_Defined_Components``
#  .. _list_Defined_Components:
#
#  list_Defined_Components
#  ^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: list_Defined_Components(LIST_OF_COMPS)
#
#    Get the list of components defined within the current package
#
#      :LIST_OF_COMPS: The output variable containing teh list of components defined into the package
#
function(list_Defined_Components LIST_OF_COMPS)
  set(${LIST_OF_COMPS} ${${PROJECT_NAME}_COMPONENTS} PARENT_SCOPE)
endfunction(list_Defined_Components)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |list_Component_Direct_External_Package_Dependencies| replace:: ``list_Component_Direct_External_Package_Dependencies``
#  .. _list_Component_Direct_External_Package_Dependencies:
#
#  list_Component_Direct_External_Package_Dependencies
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: list_Component_Direct_External_Package_Dependencies(DIRECT_EXT_DEPS package component)
#
#    List all direct dependencies of a component defined in a given package. This function gives the set of external package names used by the component.
#
#      :package: target package
#
#      :component: target component
#
#      :DIRECT_EXT_DEPS: The output variable that contains the list of package names that component depends on.
#
function(list_Component_Direct_External_Package_Dependencies DIRECT_EXT_DEPS package component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE}) #getting mode info that will be used for generating adequate name
  set(${DIRECT_EXT_DEPS} ${${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}} PARENT_SCOPE)
endfunction(list_Component_Direct_External_Package_Dependencies)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |list_Component_Direct_External_Component_Dependencies| replace:: ``list_Component_Direct_External_Component_Dependencies``
#  .. _list_Component_Direct_External_Component_Dependencies:
#
#  list_Component_Direct_External_Component_Dependencies
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: list_Component_Direct_External_Component_Dependencies(DIRECT_EXT_DEPS package component ext_package)
#
#    List all direct dependencies of a component defined in a given package. This function gives the set of external component names used by the component.
#
#      :package: target package
#
#      :component: target component
#
#      :ext_package: target external package that IS the dependency
#
#      :DIRECT_EXT_DEPS: The output variable that contains the list of component names that component depends on.
#
function(list_Component_Direct_External_Component_Dependencies DIRECT_EXT_DEPS package component ext_package)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE}) #getting mode info that will be used for generating adequate name
  set(${DIRECT_EXT_DEPS} ${${package}_${component}_EXTERNAL_DEPENDENCY_${ext_package}_COMPONENTS${VAR_SUFFIX}} PARENT_SCOPE)
endfunction(list_Component_Direct_External_Component_Dependencies)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |list_Component_Direct_Internal_Dependencies| replace:: ``list_Component_Direct_Internal_Dependencies``
#  .. _list_Component_Direct_Internal_Dependencies:
#
#  list_Component_Direct_Internal_Dependencies
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: list_Component_Direct_Internal_Dependencies(DIRECT_INT_DEPS package component)
#
#    List all direct dependencies (components inside same package) of a component defined in a given package.
#
#      :package: target package
#
#      :component: target component
#
#      :DIRECT_INT_DEPS: The output variable that contains the list of component names that component depends on.
#
function(list_Component_Direct_Internal_Dependencies DIRECT_INT_DEPS package component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE}) #getting mode info that will be used for generating adequate name
  set(${DIRECT_INT_DEPS} ${${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX}} PARENT_SCOPE)
endfunction(list_Component_Direct_Internal_Dependencies)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |list_Component_Direct_Native_Package_Dependencies| replace:: ``list_Component_Direct_Native_Package_Dependencies``
#  .. _list_Component_Direct_Native_Package_Dependencies:
#
#  list_Component_Direct_Native_Package_Dependencies
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: list_Component_Direct_Native_Package_Dependencies(DIRECT_NAT_DEPS package component)
#
#    List all direct dependencies of a component defined in a given package. This function gives the set of native package names used by the component.
#
#      :package: target package
#
#      :component: target component
#
#      :DIRECT_NAT_DEPS: The output variable that contains the list of native package names that component depends on.
#
function(list_Component_Direct_Native_Package_Dependencies DIRECT_NAT_DEPS package component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE}) #getting mode info that will be used for generating adequate name
  set(${DIRECT_NAT_DEPS} ${${package}_${component}_DEPENDENCIES${VAR_SUFFIX}} PARENT_SCOPE)
endfunction(list_Component_Direct_Native_Package_Dependencies)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |list_Component_Direct_Native_Component_Dependencies| replace:: ``list_Component_Direct_Native_Component_Dependencies``
#  .. _list_Component_Direct_Native_Component_Dependencies:
#
#  list_Component_Direct_Native_Component_Dependencies
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: list_Component_Direct_Native_Component_Dependencies(DIRECT_NAT_DEPS package component nat_package)
#
#    List all direct dependencies of a component defined in a given package. This function gives the set of native component names used by the component.
#
#      :package: target package
#
#      :component: target component
#
#      :nat_package: target native package that IS the dependency
#
#      :DIRECT_NAT_DEPS: The output variable that contains the list of native package names that component depends on.
#
function(list_Component_Direct_Native_Component_Dependencies DIRECT_NAT_DEPS package component nat_package)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE}) #getting mode info that will be used for generating adequate name
  set(${DIRECT_NAT_DEPS} ${${package}_${component}_DEPENDENCY_${nat_package}_COMPONENTS${VAR_SUFFIX}} PARENT_SCOPE)
endfunction(list_Component_Direct_Native_Component_Dependencies)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |is_Package_Component_Exported| replace:: ``is_Package_Component_Exported``
#  .. _is_Package_Component_Exported:
#
#  is_Package_Component_Exported
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: is_Package_Component_Exported(EXPORTED package component dep_package dep_component)
#
#    Tells wether a native component export another native component
#
#      :package: target package
#
#      :component: target component
#
#      :dep_package: target native package that IS the dependency
#
#      :dep_component: target native component that IS the dependency
#
#      :EXPORTED: The output variable that is TRUE if component export dep_component, FALSE otherwise.
#
function(is_Package_Component_Exported EXPORTED package component dep_package dep_component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
  set(${EXPORTED} ${${package}_${component}_EXPORT_${dep_package}_${dep_component}${VAR_SUFFIX}} PARENT_SCOPE)
endfunction(is_Package_Component_Exported)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |is_Internal_Component_Exported| replace:: ``is_Internal_Component_Exported``
#  .. _is_Internal_Component_Exported:
#
#  is_Internal_Component_Exported
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: is_Internal_Component_Exported(EXPORTED package component dep_component)
#
#    Tells wether a component export another component of same package.
#
#      :package: target package
#
#      :component: target component
#
#      :dep_component: target native component that IS the dependency
#
#      :EXPORTED: The output variable that is TRUE if component export dep_component, FALSE otherwise.
#
function(is_Internal_Component_Exported EXPORTED package component dep_component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
  set(${EXPORTED} ${${package}_${component}_INTERNAL_EXPORT_${dep_component}${VAR_SUFFIX}} PARENT_SCOPE)
endfunction(is_Internal_Component_Exported)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |is_External_Component_Exported| replace:: ``is_External_Component_Exported``
#  .. _is_External_Component_Exported:
#
#  is_External_Component_Exported
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: is_External_Component_Exported(EXPORTED package component dep_component)
#
#    Tells wether a (native or external) component exports another external component.
#
#      :package: target package
#
#      :component: target component
#
#      :dep_component: target external component that IS the dependency
#
#      :dep_package: target external package that IS the dependency
#
#      :EXPORTED: The output variable that is TRUE if component export dep_component, FALSE otherwise.
#
function(is_External_Component_Exported EXPORTED package component dep_package dep_component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
  set(${EXPORTED} ${${package}_${component}_EXTERNAL_EXPORT_${dep_package}_${dep_component}${VAR_SUFFIX}} PARENT_SCOPE)
endfunction(is_External_Component_Exported)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |list_Defined_Applications| replace:: ``list_Defined_Applications``
#  .. _list_Defined_Applications:
#
#  list_Defined_Applications
#  ^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: list_Defined_Applications(LIST_OF_COMPS)
#
#    Get the list of libraries defined within the current package
#
#      :LIST_OF_COMPS: The output variable containing the list of applications defined into the package
#
function(list_Defined_Applications LIST_OF_COMPS)
  set(${LIST_OF_COMPS} ${${PROJECT_NAME}_COMPONENTS_APPS} PARENT_SCOPE)
endfunction(list_Defined_Applications)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |list_Defined_Libraries| replace:: ``list_Defined_Libraries``
#  .. _list_Defined_Libraries:
#
#  list_Defined_Libraries
#  ^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: list_Defined_Libraries(LIST_OF_COMPS)
#
#    Get the list of libraries defined within the current package
#
#      :LIST_OF_COMPS: The output variable containing the list of libraries defined into the package
#
function(list_Defined_Libraries LIST_OF_COMPS)
  set(${LIST_OF_COMPS} ${${PROJECT_NAME}_COMPONENTS_LIBS} PARENT_SCOPE)
endfunction(list_Defined_Libraries)


#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Component_Type| replace:: ``get_Component_Type``
#  .. _get_Component_Type:
#
#  get_Component_Type
#  ^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Component_Type(REST_TYPE component)
#
#    Get the type of a component defined within the current package
#
#      :component: The target component
#
#      :REST_TYPE: The type of this component
#
function(get_Component_Type REST_TYPE component)
  set(${REST_TYPE} ${${PROJECT_NAME}_${component}_TYPE} PARENT_SCOPE)
endfunction(get_Component_Type)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Component_Target| replace:: ``get_Component_Target``
#  .. _get_Component_Target:
#
#  get_Component_Target
#  ^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Component_Target(REST_TARGET component)
#
#    Get the name of the CMake target for the given component.
#
#      :component: The target component
#
#      :RES_TARGET: The name of target for this component
#
function(get_Component_Target RES_TARGET component)
  get_Package_Component_Target(RES ${PROJECT_NAME} ${component})
  set(${RES_TARGET} ${RES} PARENT_SCOPE)
endfunction(get_Component_Target)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Component_Dependencies_Targets| replace:: ``get_Component_Dependencies_Targets``
#  .. _get_Component_Dependencies_Targets:
#
#  get_Component_Dependencies_Targets
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Component_Dependencies_Targets(RES_DEPS component)
#
#    Get the dependencies of a component defined in current package.
#
#      :component: The target source component
#
#      :RES_DEPS: The output variable containing the list of components that component depends on
#
function(get_Component_Dependencies_Targets RES_DEPS component)
  get_Package_Component_Dependencies_Targets(RES_DEPS_TARGETS ${PROJECT_NAME} ${component})
  set(${RES_DEPS} ${RES_DEPS_TARGETS} PARENT_SCOPE)
endfunction(get_Component_Dependencies_Targets)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Package_Component_Target| replace:: ``get_Package_Component_Target``
#  .. _get_Package_Component_Target:
#
#  get_Package_Component_Target
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Package_Component_Target(RES_TARGET package component)
#
#    Get the name of the CMake target for a given component of a given package.
#
#      :package: The target package
#
#      :component: The target component
#
#      :RES_TARGET: The name of target for this component
#
function(get_Package_Component_Target RES_TARGET package component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
  set(${RES_TARGET} ${package}_${component}${TARGET_SUFFIX} PARENT_SCOPE)
endfunction(get_Package_Component_Target)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Package_Component_Dependencies_Targets| replace:: ``get_Package_Component_Dependencies_Targets``
#  .. _get_Package_Component_Dependencies_Targets:
#
#  get_Package_Component_Dependencies_Targets
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Package_Component_Dependencies_Targets(RES_DEPS package component)
#
#    Get the targets for all dependencies of a component belonging to a specific package.
#
#      :package: The target package
#
#      :component: The target component
#
#      :RES_DEPS: The output variable containing the list of targets that component targets depends on
#
function(get_Package_Component_Dependencies_Targets RES_DEPS package component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
  set(result)
  foreach(dep_package IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
    foreach(dep_component IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
      get_Package_Component_Target(RES_TARGET ${dep_package} ${dep_component})#getting component own target
      get_Package_Component_Dependencies_Targets(RES_EXT_DEPS ${dep_package} ${dep_component})#recursive call to get its dependencies
      list(APPEND result ${RES_TARGET} ${RES_EXT_DEPS})
    endforeach()
  endforeach()
  foreach(dep_component IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
    get_Package_Component_Target(RES_TARGET ${package} ${dep_component}) #getting component own target
    get_Package_Component_Dependencies_Targets(RES_INT_DEPS ${package} ${dep_component}) #recursive call to get its dependencies
    list(APPEND result ${RES_TARGET} ${RES_INT_DEPS})
  endforeach()
  foreach(dep_package IN LISTS ${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
    foreach(dep_component IN LISTS ${package}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
      get_Package_Component_Target(RES_TARGET ${dep_package} ${dep_component}) #getting component own target
      get_Package_Component_Dependencies_Targets(RES_PACK_DEPS ${dep_package} ${dep_component})#recursive call to get its dependencies
      list(APPEND result ${RES_TARGET} ${RES_PACK_DEPS})
    endforeach()
  endforeach()
  if(result)
    list(REMOVE_DUPLICATES result)
  endif()
  set(${RES_DEPS} ${result} PARENT_SCOPE)
endfunction(get_Package_Component_Dependencies_Targets)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Component_Language_Standard| replace:: ``get_Component_Language_Standard``
#  .. _get_Component_Language_Standard:
#
#  get_Component_Language_Standard
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Component_Language_Standard(MANAGED_AS_STANDARD RES_C_STD RES_CXX_STD RES_C_OPT RES_CXX_OPT component)
#
#    Get information about language standards used by a component.
#
#      :component: The target component
#
#      :MANAGED_AS_STANDARD: The output variable that is TRUE if langauge is defined via CMake Language standard support feature instead of direct compiler option, FALSE otherwise
#      :RES_C_STD: The output variable that contains the C language standard version used by the component.
#      :RES_CXX_STD: The output variable that contains the C++ language standard version used by the component.
#      :RES_C_OPT: The output variable thatcontains the C compiler option to use to get equivalent C language standard version.
#      :RES_CXX_OPT: The output variable thatcontains the C++ compiler option to use to get equivalent C++ language standard version.
#
function(get_Component_Language_Standard MANAGED_AS_STANDARD RES_C_STD RES_CXX_STD RES_C_OPT RES_CXX_OPT component)
  get_Package_Component_Language_Standard(MANAGED C_STD CXX_STD C_OPT CXX_OPT ${PROJECT_NAME} ${component})
  set(${MANAGED_AS_STANDARD} ${MANAGED} PARENT_SCOPE)
  set(${RES_C_STD} ${C_STD} PARENT_SCOPE)
  set(${RES_CXX_STD} ${CXX_STD} PARENT_SCOPE)
  set(${RES_C_OPT} ${C_OPT} PARENT_SCOPE)
  set(${RES_CXX_OPT} ${CXX_OPT} PARENT_SCOPE)
endfunction(get_Component_Language_Standard)


#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Component_Language_Standard| replace:: ``get_Component_Language_Standard``
#  .. _get_Component_Language_Standard:
#
#  get_Component_Language_Standard
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Component_Language_Standard(MANAGED_AS_STANDARD RES_C_STD RES_CXX_STD RES_C_OPT RES_CXX_OPT package component)
#
#    Get information about language standards used by a component of a given package.
#
#      :package: The target package
#
#      :component: The target component
#
#      :MANAGED_AS_STANDARD: The output variable that is TRUE if langauge is defined via CMake Language standard support feature instead of direct compiler option, FALSE otherwise
#      :RES_C_STD: The output variable that contains the C language standard version used by the component.
#      :RES_CXX_STD: The output variable that contains the C++ language standard version used by the component.
#      :RES_C_OPT: The output variable that contains the C compiler option to use to get equivalent C language standard version.
#      :RES_CXX_OPT: The output variable that contains the C++ compiler option to use to get equivalent C++ language standard version.
#
function(get_Package_Component_Language_Standard MANAGED_AS_STANDARD RES_C_STD RES_CXX_STD RES_C_OPT RES_CXX_OPT package component)

  set(ALREADY_IN_COMPILE_OPTIONS FALSE)#to know if the language is already translated into a compilation option
  if(CMAKE_VERSION VERSION_LESS 3.8)# starting from 3.8 language standard is managed automatically by CMake so NOT in compile options
  	if(CMAKE_VERSION VERSION_LESS 3.1)#starting 3.1 the C and CXX standards are managed the good way by CMake (with target properties)
  		set(ALREADY_IN_COMPILE_OPTIONS TRUE)# with version < 3.1 the standard properties are already transformed into an equivalent compilation option by PID
  	else()#starting for 3.8, if standard is 17 or more we use the old way to do (CMake does not know this standard, so it has been translated into a compile option by PID)
  		is_CXX_Version_Less(IS_LESS ${${package}_${component}_CXX_STANDARD} 17)
  		if(NOT IS_LESS)#if version of the standard is more or equal than 17 then use the classical way of doing (PID has generate compile options already)
  				set(ALREADY_IN_COMPILE_OPTIONS TRUE)# do not used information from target in that specific case as it has already been translated
  		endif()
  	endif()
  endif()#not already in compile options for a greater version of cmake
  if(NOT ALREADY_IN_COMPILE_OPTIONS)
    set(${MANAGED_AS_STANDARD} TRUE PARENT_SCOPE)
  else()
    set(${MANAGED_AS_STANDARD} FALSE PARENT_SCOPE)
  endif()
  translate_Standard_Into_Option(C_LANGUAGE_OPT CXX_LANGUAGE_OPT
                                "${${package}_${component}_C_STANDARD}"
                                "${${package}_${component}_CXX_STANDARD}")

  set(${RES_C_STD} ${${package}_${component}_C_STANDARD} PARENT_SCOPE)
  set(${RES_CXX_STD} ${${package}_${component}_CXX_STANDARD} PARENT_SCOPE)
  set(${RES_C_OPT} ${C_LANGUAGE_OPT} PARENT_SCOPE)
  set(${RES_CXX_OPT} ${CXX_LANGUAGE_OPT} PARENT_SCOPE)
endfunction(get_Package_Component_Language_Standard)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Dir_Path_For_Component| replace:: ``get_Dir_Path_For_Component``
#  .. _get_Dir_Path_For_Component:
#
#  get_Dir_Path_For_Component
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Dir_Path_For_Component(RET_SOURCE_PATH RET_HEADER_PATH component)
#
#    Get the source and/or include folders containig the code of a component defined in currrent project.
#
#      :component: The target component
#
#      :RET_SOURCE_PATH: The output variable containing the path to component internal sources directory
#
#      :RET_HEADER_PATH: The output variable containing the path to component exported headers directory
#
function(get_Dir_Path_For_Component RET_SOURCE_PATH RET_HEADER_PATH component)
set(${RET_SOURCE_PATH} PARENT_SCOPE)
set(${RET_HEADER_PATH} PARENT_SCOPE)
if(NOT ${PROJECT_NAME}_${component}_TYPE)
	return()
endif()

if(${PROJECT_NAME}_${component}_TYPE STREQUAL "APP")
	set(${RET_SOURCE_PATH} ${CMAKE_SOURCE_DIR}/apps/${${PROJECT_NAME}_${component}_SOURCE_DIR} PARENT_SCOPE)
elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE")
	set(${RET_SOURCE_PATH} ${CMAKE_SOURCE_DIR}/apps/${${PROJECT_NAME}_${component}_SOURCE_DIR} PARENT_SCOPE)
elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
	set(${RET_SOURCE_PATH} ${CMAKE_SOURCE_DIR}/test/${${PROJECT_NAME}_${component}_SOURCE_DIR} PARENT_SCOPE)
elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "MODULE")
	set(${RET_SOURCE_PATH} ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_${component}_SOURCE_DIR} PARENT_SCOPE)
elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "STATIC")
	set(${RET_SOURCE_PATH} ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_${component}_SOURCE_DIR} PARENT_SCOPE)
	set(${RET_HEADER_PATH} ${CMAKE_SOURCE_DIR}/include/${${PROJECT_NAME}_${component}_HEADER_DIR_NAME} PARENT_SCOPE)
elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "SHARED")
	set(${RET_SOURCE_PATH} ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_${component}_SOURCE_DIR} PARENT_SCOPE)
	set(${RET_HEADER_PATH} ${CMAKE_SOURCE_DIR}/include/${${PROJECT_NAME}_${component}_HEADER_DIR_NAME} PARENT_SCOPE)
elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
	set(${RET_HEADER_PATH} ${CMAKE_SOURCE_DIR}/include/${${PROJECT_NAME}_${component}_HEADER_DIR_NAME} PARENT_SCOPE)
endif()
endfunction(get_Dir_Path_For_Component)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |create_In_Source_Symlink| replace:: ``create_In_Source_Symlink``
#  .. _create_In_Source_Symlink:
#
#  create_In_Source_Symlink
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: create_In_Source_Symlink(source_dir file_to_symlink_from_build_tree)
#
#    Create a symlink in source folder pointing to a file generated into build folder.
#
#      :source_dir: path to the source folder to create symlink in
#
#      :file_to_symlink_from_build_tree: the file, in build tree to be symlinked
#
function(create_In_Source_Symlink source_dir file_to_symlink_from_build_tree)
  get_filename_component(FILENAME ${file_to_symlink_from_build_tree} NAME)
  create_Symlink(
              ${file_to_symlink_from_build_tree}
              ${source_dir}/${FILENAME})
 dereference_Residual_Files(${FILENAME})
endfunction(create_In_Source_Symlink)
