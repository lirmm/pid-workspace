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
#  .. |is_Language_Available| replace:: ``is_Language_Available``
#  .. _is_Language_Available:
#
#  is_Language_Available
#  ^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: is_Language_Available(AVAILABLE language)
#
#    Check whether a language is sppourted by current build environment.
#
#      :language: the langauge to check support for
#
#      :AVAILABLE: The output variable that is TRUE if language is supported.
#
function(is_Language_Available AVAILABLE language)
  set(${AVAILABLE} ${${language}_Language_AVAILABLE} PARENT_SCOPE)
endfunction(is_Language_Available)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |abort_When_Not_Required| replace:: ``abort_When_Not_Required``
#  .. _abort_When_Not_Required:
#
#  abort_When_Not_Required
#  ^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: abort_When_Not_Required()
#
#    Abort when the tool is not explictly required by current project
#
macro(abort_When_Not_Required tool)
  if(NOT ${tool}_REQUIRED)
    return()
  endif()
endmacro(abort_When_Not_Required)

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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
#  .. |is_First_Package_Configuration| replace:: ``is_First_Package_Configuration``
#  .. _is_First_Package_Configuration:
#
#  is_First_Package_Configuration
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: is_First_Package_Configuration(FIRST_CONFIG)
#
#    Tells whether the current package has already been configure in another build mode or not.
#
#      :FIRST_CONFIG: The output variable that is TRUE if package has not been configured in any mode already.
#
function(is_First_Package_Configuration FIRST_CONFIG)
  if(CMAKE_BUILD_TYPE STREQUAL Debug
    OR BUILD_RELEASE_ONLY)#only build in Release mode
    set(${FIRST_CONFIG} TRUE PARENT_SCOPE)
    return()
  endif()
  set(${FIRST_CONFIG} FALSE PARENT_SCOPE)
endfunction(is_First_Package_Configuration)

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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function cannot be called in BEFORE_DEPS scripts.
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function cannot be called in BEFORE_DEPS scripts.
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function cannot be called in BEFORE_DEPS scripts.
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
#   .. command:: dereference_Residual_Files(list_of_git_patterns)
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
#  .. |generate_Code_In_Place| replace:: ``generate_Code_In_Place``
#  .. _generate_Code_In_Place:
#
#  generate_Code_In_Place
#  ^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: generate_Code_In_Place(list_of_source_files generated_extension command)
#
#    use a generator to generated compilable files in same directory as where source files are placed.
#
#      :list_of_source_files: The list of generated files
#
#      :generated_extension: the extension for generated file
#
#      :command: The command to call
#
#      :message: The commennt to print when calling the generation command
#
function(generate_Code_In_Place list_of_source_files generated_extension command message)
  #directly dereference the generated files
  convert_Files_Extensions(ALL_GENERATED_FILES list_of_source_files "${generated_extension}")
  dereference_Residual_Files("${ALL_GENERATED_FILES}")
  #generate code into same folders
  set(index 0)
  foreach(a_file IN LISTS list_of_source_files)
    list(GET ALL_GENERATED_FILES ${index} gen_gile)
    get_filename_component(FOLDER ${a_file} DIRECTORY)
    #generate at coniguration time to allow C files to be automatically manage dby PID
    execute_process(COMMAND ${command} ${a_file}
                    WORKING_DIRECTORY ${FOLDER})
    # #also add a custom command to regenerate at each build
    add_custom_command(OUTPUT ${CMAKE_SOURCE_DIR}/${gen_gile}
                 DEPENDS ${a_file}
                 COMMAND ${command} ${a_file}
                 WORKING_DIRECTORY ${FOLDER}
                 COMMENT "${message}: ${gen_gile}")#generate C code into same folders
    math(EXPR index "${index}+1")
  endforeach()
endfunction(generate_Code_In_Place)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |remove_Residual_Files| replace:: ``remove_Residual_Files``
#  .. _remove_Residual_Files:
#
#  remove_Residual_Files
#  ^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: remove_Residual_Files(list_of_files)
#
#    Remove the residual files of the pugins (if any). Files path are relative to project source directory.
#
#      :list_of_files: The list of path to files to remove
#
function(remove_Residual_Files list_of_files)
  foreach(a_file IN LISTS list_of_files)
    if(EXISTS ${CMAKE_SOURCE_DIR}/${a_file})
      file(REMOVE ${CMAKE_SOURCE_DIR}/${a_file})
    endif()
  endforeach()
endfunction(remove_Residual_Files)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |convert_Files_Extensions| replace:: ``convert_Files_Extensions``
#  .. _convert_Files_Extensions:
#
#  convert_Files_Extensions
#  ^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: convert_Files_Extensions(RES_FILES_PATH input_list generated_extension)
#
#    Convert a set of file with one extension to the same set of file with another extension.
#
#      :input_list: The list of file to convert
#
#      :generated_extension: The expression specifying what is the new extension for files.
#
#      :RES_FILES_PATH: The output variable containing the list of path to resulting files relative to current package root folder.
#
function(convert_Files_Extensions RES_FILES_PATH input_list generated_extension)
  set(temp_list)
  foreach(a_file IN LISTS ${input_list})
    if(a_file MATCHES "^${CMAKE_SOURCE_DIR}/(.+)$")#give a relative path
      list(APPEND temp_list ${CMAKE_MATCH_1})
    elseif(NOT IS_ABSOLUTE ${a_file})#directly using the relative path
      list(APPEND temp_list ${a_file})
    endif()
  endforeach()
  set(result)
  foreach(a_file IN LISTS temp_list)
    get_filename_component(RES_DIR ${a_file} DIRECTORY)
    get_filename_component(RES_NAME ${a_file} NAME)
    if(RES_NAME MATCHES "^(.+)\\.[^.]+$")
      list(APPEND result "${RES_DIR}/${CMAKE_MATCH_1}${generated_extension}")
    endif()
  endforeach()
  set(${RES_FILES_PATH} ${result} PARENT_SCOPE)
endfunction(convert_Files_Extensions)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Current_Component_Files| replace:: ``get_Current_Component_Files``
#  .. _get_Current_Component_Files:
#
#  get_Current_Component_Files
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Current_Component_Files(ALL_FILES extension_filters)
#
#    Get all source files of a component whose extension matches the possible extensions.
#
#      :extension_filters: The list of possible extensions
#
#      :ALL_PUB_HEADERS: The output variable containing the list of path to files.
#      :ALL_SOURCES: The output variable containing the list of path to files.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in DURING_COMPS scripts.
#
function(get_Current_Component_Files ALL_PUB_HEADERS ALL_SOURCES extension_filters)
  set(all_incs)
  set(all_srcs)
  foreach(filter IN LISTS extension_filters)
    if(${PROJECT_NAME}_${CURRENT_COMP_DEFINED}_TEMP_INCLUDE_DIR)
      file(GLOB_RECURSE in_include_dir
            ${${PROJECT_NAME}_${CURRENT_COMP_DEFINED}_TEMP_INCLUDE_DIR}
            "${${PROJECT_NAME}_${CURRENT_COMP_DEFINED}_TEMP_INCLUDE_DIR}/*${filter}")
      list(APPEND all_incs ${in_include_dir})
    endif()
    if(${PROJECT_NAME}_${CURRENT_COMP_DEFINED}_TEMP_SOURCE_DIR)
      file(GLOB_RECURSE in_src_dir
            ${${PROJECT_NAME}_${CURRENT_COMP_DEFINED}_TEMP_SOURCE_DIR}
            "${${PROJECT_NAME}_${CURRENT_COMP_DEFINED}_TEMP_SOURCE_DIR}/*${filter}")
      list(APPEND all_srcs ${in_src_dir})
    endif()
    if(${PROJECT_NAME}_${CURRENT_COMP_DEFINED}_TEMP_MORE_HEADERS)
      foreach(aux IN LISTS ${PROJECT_NAME}_${CURRENT_COMP_DEFINED}_TEMP_MORE_HEADERS)
        get_filename_component(RES_EXT ${aux} EXT)
        if(RES_EXT STREQUAL filter)
          list(APPEND all_incs ${aux})
        endif()
      endforeach()
    endif()
    if(${PROJECT_NAME}_${CURRENT_COMP_DEFINED}_TEMP_MORE_SOURCES)
      foreach(aux IN LISTS ${PROJECT_NAME}_${CURRENT_COMP_DEFINED}_TEMP_MORE_SOURCES)
        if(IS_DIRECTORY ${aux})
          file(GLOB_RECURSE all_aux
                ${aux}
                "${aux}/*${filter}")
          list(APPEND all_srcs ${all_aux})
        else()#check if the file has adequate extension
          get_filename_component(RES_EXT ${aux} EXT)
          if(RES_EXT STREQUAL filter)
            list(APPEND all_srcs ${aux})
          endif()
        endif()
      endforeach()
    endif()
  endforeach()
  set(${ALL_PUB_HEADERS} ${all_incs} PARENT_SCOPE)
  set(${ALL_SOURCES} ${all_srcs} PARENT_SCOPE)
endfunction(get_Current_Component_Files)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |configure_Current_Component| replace:: ``configure_Current_Component``
#  .. _configure_Current_Component:
#
#  configure_Current_Component
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: configure_Current_Component(...)
#
#    Set properties of current component.
#
#      :environment: The name of environment defining the plugin.
#
#      :INTERNAL: if used then the following configuration is internal to the current component.
#      :EXPORTED: if used then the following configuration is exported by the current component.
#      :CONFIGURATION ...: The list of platform configuration to use to configure the component.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in DURING_COMPS scripts.
#
function(configure_Current_Component environment)
  set(options INTERNAL EXPORTED)
  set(multiValueArgs CONFIGURATION)
  cmake_parse_arguments(CONF_CURR_COMP "${options}" "" "${multiValueArgs}" ${ARGN})
  if(NOT ${CURRENT_COMP_DEFINED}_ENVIRONMENTS)
    set(${CURRENT_COMP_DEFINED}_ENVIRONMENTS ${environment} PARENT_SCOPE)
  else()
    set(${CURRENT_COMP_DEFINED}_ENVIRONMENTS ${${CURRENT_COMP_DEFINED}_ENVIRONMENTS} ${environment} PARENT_SCOPE)
  endif()
  if(CONF_CURR_COMP_INTERNAL)
    set(${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_INTERNAL_CONFIGURATION ${CONF_CURR_COMP_CONFIGURATION} PARENT_SCOPE)
  elseif(CONF_CURR_COMP_EXPORTED)
    set(${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_EXPORTED_CONFIGURATION ${CONF_CURR_COMP_CONFIGURATION} PARENT_SCOPE)
  else()
    message("[PID] WARNING: when calling configure_Current_Component in plugin script defined in ${environment},  ")
  endif()
endfunction(configure_Current_Component)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |get_Environment_Configuration| replace:: ``get_Environment_Configuration``
#  .. _get_Environment_Configuration:
#
#  get_Environment_Configuration
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Environment_Configuration(environment ...)
#
#    Get configuration information coming from the environment.
#
#      :environment: The name of environment defining the plugin.
#
#      :PROGRAM var : The output variable containing the path to the program defined by the environment
#      :PROGRAM_DIRS var : The output variable containing the list of runtime path defined by the environment
#      :CONFIGURATION var : The output variable containing the list of platform configurations required by the environment
#
function(get_Environment_Configuration environment)
  set(oneValueArgs PROGRAM PROGRAM_DIRS CONFIGURATION)
  cmake_parse_arguments(GET_ENV_CONF "" "${oneValueArgs}" "" ${ARGN})
  find_Environment_Tool_For_Current_Profile(TOOL_PREFIX ${environment})
  if(GET_ENV_CONF_PROGRAM)
    set(${GET_ENV_CONF_PROGRAM} ${${TOOL_PREFIX}_PROGRAM} PARENT_SCOPE)
  endif()
  if(GET_ENV_CONF_PROGRAM_DIRS)
    set(${GET_ENV_CONF_PROGRAM_DIRS} ${${TOOL_PREFIX}_PROGRAM_DIRS} PARENT_SCOPE)
  endif()
  if(GET_ENV_CONF_CONFIGURATION)
    set(${GET_ENV_CONF_CONFIGURATION} ${${TOOL_PREFIX}_PLATFORM_CONFIGURATIONS} PARENT_SCOPE)
  endif()
endfunction(get_Environment_Configuration)


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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
#
function(list_Component_Direct_External_Component_Dependencies DIRECT_EXT_DEPS package component ext_package)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE}) #getting mode info that will be used for generating adequate name
  set(result)
  foreach(dep IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCY_${ext_package}_COMPONENTS${VAR_SUFFIX})
    rename_If_Alias(EXT_DEP ${ext_package} TRUE ${dep} ${CMAKE_BUILD_TYPE})#by definition a resolved component is a native one
    list(APPEND result ${EXT_DEP})
  endforeach()
  set(${DIRECT_EXT_DEPS} ${result} PARENT_SCOPE)
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
#
function(list_Component_Direct_Internal_Dependencies DIRECT_INT_DEPS package component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE}) #getting mode info that will be used for generating adequate name
  set(result)
  foreach(dep IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
    rename_If_Alias(INT_DEP ${package} FALSE ${dep} ${CMAKE_BUILD_TYPE})#resokve alias if any
    list(APPEND result ${INT_DEP})
  endforeach()
  set(${DIRECT_INT_DEPS} ${result} PARENT_SCOPE)
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
#
function(list_Component_Direct_Native_Component_Dependencies DIRECT_NAT_DEPS package component nat_package)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE}) #getting mode info that will be used for generating adequate name
  set(result)
  foreach(dep IN LISTS ${package}_${component}_DEPENDENCY_${nat_package}_COMPONENTS${VAR_SUFFIX})
    rename_If_Alias(NAT_DEP ${nat_package} FALSE ${dep} ${CMAKE_BUILD_TYPE})#resokve alias if any
    list(APPEND result ${NAT_DEP})
  endforeach()
  set(${DIRECT_NAT_DEPS} ${result} PARENT_SCOPE)
endfunction(list_Component_Direct_Native_Component_Dependencies)

#.rst:
#
# .. ifmode:: plugin
#
#  .. |is_Component_Exported| replace:: ``is_Component_Exported``
#  .. _is_Component_Exported:
#
#  is_Component_Exported
#  ^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: is_Component_Exported(EXPORTED package component dep_package dep_component)
#
#    Tells wether a component export another component
#
#      :package: target package
#
#      :component: target component
#
#      :dep_package: target package that IS the dependency
#
#      :dep_component: target component that IS the dependency
#
#      :EXPORTED: The output variable that is TRUE if component exports dep_component, FALSE otherwise.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
#
function(is_Component_Exported EXPORTED package component dep_package dep_component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
  get_Package_Type(${package} PACK_TYPE)
  if(PACK_TYPE STREQUAL "EXTERNAL")
    set(pack_ext TRUE)
  else()
    set(pack_ext FALSE)
  endif()
  if(dep_package STREQUAL package)
    set(dep_pack_ext ${pack_ext})
  else()
    get_Package_Type(${dep_package} DEP_PACK_TYPE)
    if(DEP_PACK_TYPE STREQUAL "EXTERNAL")
      set(dep_pack_ext TRUE)
    else()
      set(dep_pack_ext FALSE)
    endif()
  endif()
  rename_If_Alias(comp_name_to_use ${package} ${pack_ext} ${component} ${CMAKE_BUILD_TYPE})
  rename_If_Alias(dep_name_to_use ${dep_package} ${dep_pack_ext} ${dep_component} ${CMAKE_BUILD_TYPE})
  if(DEP_PACK_TYPE STREQUAL "EXTERNAL")#depending on the dependency type we call either one or the other function to test export with aliases
    export_External_Component_Resolving_Alias(IS_EXPORTING
              ${package} ${comp_name_to_use} ${component}
              ${dep_package} ${dep_name_to_use} ${dep_component}
              ${CMAKE_BUILD_TYPE})
  else()
    export_Component_Resolving_Alias(IS_EXPORTING
              ${package} ${comp_name_to_use} ${component}
              ${dep_package} ${dep_name_to_use} ${dep_component}
              ${CMAKE_BUILD_TYPE})
  endif()
  set(${EXPORTED} ${IS_EXPORTING} PARENT_SCOPE)
endfunction(is_Component_Exported)


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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function can be called in DURING_COMPS or AFTER_COMPS scripts.
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
#
function(get_Package_Component_Dependencies_Targets RES_DEPS package component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
  set(result)
  foreach(dep_package IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
    foreach(dep_component IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
      rename_If_Alias(comp_name_to_use ${dep_package} TRUE ${dep_component} ${CMAKE_BUILD_TYPE})
      get_Package_Component_Target(RES_TARGET ${dep_package} ${comp_name_to_use})#getting component own target
      get_Package_Component_Dependencies_Targets(RES_EXT_DEPS ${dep_package} ${comp_name_to_use})#recursive call to get its dependencies
      list(APPEND result ${RES_TARGET} ${RES_EXT_DEPS})
    endforeach()
  endforeach()
  get_Package_Type(${package} PACK_TYPE)
  if(PACK_TYPE STREQUAL "EXTERNAL")
    set(ext_pack TRUE)
  else()
    set(ext_pack FALSE)
  endif()
  foreach(dep_component IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
    rename_If_Alias(comp_name_to_use ${package} ${ext_pack} ${dep_component} ${CMAKE_BUILD_TYPE})
    get_Package_Component_Target(RES_TARGET ${package} ${comp_name_to_use}) #getting component own target
    get_Package_Component_Dependencies_Targets(RES_INT_DEPS ${package} ${comp_name_to_use}) #recursive call to get its dependencies
    list(APPEND result ${RES_TARGET} ${RES_INT_DEPS})
  endforeach()
  foreach(dep_package IN LISTS ${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
    foreach(dep_component IN LISTS ${package}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
      rename_If_Alias(comp_name_to_use ${dep_package} FALSE ${dep_component} ${CMAKE_BUILD_TYPE})
      get_Package_Component_Target(RES_TARGET ${dep_package} ${comp_name_to_use}) #getting component own target
      get_Package_Component_Dependencies_Targets(RES_PACK_DEPS ${dep_package} ${comp_name_to_use})#recursive call to get its dependencies
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
#  .. |get_Package_Component_Language_Standard| replace:: ``get_Package_Component_Language_Standard``
#  .. _get_Package_Component_Language_Standard:
#
#  get_Package_Component_Language_Standard
#  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#
#   .. command:: get_Package_Component_Language_Standard(MANAGED_AS_STANDARD RES_C_STD RES_CXX_STD RES_C_OPT RES_CXX_OPT package component)
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
#
function(get_Package_Component_Language_Standard MANAGED_AS_STANDARD RES_C_STD RES_CXX_STD RES_C_OPT RES_CXX_OPT package component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
  set(ALREADY_IN_COMPILE_OPTIONS FALSE)#to know if the language is already translated into a compilation option
  if(CMAKE_VERSION VERSION_LESS 3.8)# starting from 3.8 language standard is managed automatically by CMake so NOT in compile options
  	is_CXX_Version_Less(IS_LESS ${${package}_${component}_CXX_STANDARD${VAR_SUFFIX}} 17)
		if(NOT IS_LESS)#if version of the standard is more or equal than 17 then use the classical way of doing (PID has generate compile options already)
				set(ALREADY_IN_COMPILE_OPTIONS TRUE)# do not used information from target in that specific case as it has already been translated
		endif()
  endif()#not already in compile options for a greater version of cmake
  if(NOT ALREADY_IN_COMPILE_OPTIONS)
    set(${MANAGED_AS_STANDARD} TRUE PARENT_SCOPE)
  else()
    set(${MANAGED_AS_STANDARD} FALSE PARENT_SCOPE)
  endif()
  translate_Standard_Into_Option(C_LANGUAGE_OPT CXX_LANGUAGE_OPT
                                "${${package}_${component}_C_STANDARD${VAR_SUFFIX}}"
                                "${${package}_${component}_CXX_STANDARD${VAR_SUFFIX}}")

  set(${RES_C_STD} ${${package}_${component}_C_STANDARD${VAR_SUFFIX}} PARENT_SCOPE)
  set(${RES_CXX_STD} ${${package}_${component}_CXX_STANDARD${VAR_SUFFIX}} PARENT_SCOPE)
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
#     .. admonition:: Constraints
#        :class: warning
#
#        - This function must be called in AFTER_COMPS scripts.
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
  file(RELATIVE_PATH THEPATH ${CMAKE_SOURCE_DIR} ${source_dir})
  create_Symlink(
              ${file_to_symlink_from_build_tree}
              ${source_dir}/${FILENAME})
 dereference_Residual_Files(${THEPATH}/${FILENAME})
endfunction(create_In_Source_Symlink)
