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

#########################################################################################
############### load everything required to execute this command ########################
#########################################################################################


list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(Wrapper_Definition NO_POLICY_SCOPE) # to be able to interpret description of external packages and generate the use files
include(External_Definition NO_POLICY_SCOPE) #to be able to interpret description of dependencies (external packages)
include(PID_Plugins_Management NO_POLICY_SCOPE)

load_Workspace_Info() #loading the current workspace configuration before executing the deploy script
#########################################################################################
#######################################Build script #####################################
#########################################################################################

#manage arguments if they are passed as environmentvariables (for non UNIX makefile generators usage)
if(NOT TARGET_EXTERNAL_VERSION AND DEFINED ENV{version})
	set(TARGET_EXTERNAL_VERSION $ENV{version} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{version})
	unset(ENV{version})
endif()
if(NOT TARGET_BUILD_MODE AND DEFINED ENV{mode})#to manage the call for non UNIX makefile generators
	set(TARGET_BUILD_MODE $ENV{mode} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{mode})
	unset(ENV{mode})
endif()
if(NOT GENERATE_BINARY_ARCHIVE AND DEFINED ENV{archive})#to manage the call for non UNIX makefile generators
	set(GENERATE_BINARY_ARCHIVE $ENV{archive} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{archive})
	unset(ENV{archive})
endif()
if(NOT DO_NOT_EXECUTE_SCRIPT AND DEFINED ENV{skip_script})#to manage the call for non UNIX makefile generators
	set(DO_NOT_EXECUTE_SCRIPT $ENV{skip_script} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{skip_script})
	unset(ENV{skip_script})
endif()
if(NOT USE_SYSTEM_VARIANT AND DEFINED ENV{os_variant})#to manage the call for non UNIX makefile generators
	set(USE_SYSTEM_VARIANT $ENV{os_variant} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{os_variant})
	unset(ENV{os_variant})
endif()

if(DEFINED ENV{show_build_output})#this is usually set by workspace level commands and so should take precedence over the local value
	set(SHOW_WRAPPERS_BUILD_OUTPUT $ENV{show_build_output} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{show_build_output})
	unset(ENV{show_build_output})
endif()

if(USE_SYSTEM_VARIANT AND (USE_SYSTEM_VARIANT STREQUAL "true" OR USE_SYSTEM_VARIANT STREQUAL "TRUE"  OR USE_SYSTEM_VARIANT STREQUAL "ON" ))
	set(use_os_variant TRUE)
endif()

begin_Progress(${TARGET_EXTERNAL_PACKAGE} GLOBAL_PROGRESS_VAR) #managing the build from a global point of view

#checking that user input is coherent
if(NOT TARGET_EXTERNAL_VERSION)
	finish_Progress(${GLOBAL_PROGRESS_VAR})
  message(FATAL_ERROR "[PID] CRITICAL ERROR: you must define the version to build and deploy using version= argument to the build command")
	return()
elseif(TARGET_EXTERNAL_VERSION MATCHES "^v.*$")#if version is given as a version tag name (i.e. "v<version string>")
  normalize_Version_Tags(version "${TARGET_EXTERNAL_VERSION}")
else()
  set(version ${TARGET_EXTERNAL_VERSION})
endif()
set(TARGET_EXTERNAL_VERSION ${version} CACHE INTERNAL "" FORCE) #reset the variable TARGET_EXTERNAL_VERSION to make it usable in scripts

message("[PID] INFO : building wrapper for external package ${TARGET_EXTERNAL_PACKAGE} version ${version}...")


set(package_dir ${WORKSPACE_DIR}/wrappers/${TARGET_EXTERNAL_PACKAGE})
set(package_version_src_dir ${package_dir}/src/${version})
set(package_version_build_dir ${package_dir}/build/${version})
set(package_version_install_dir ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_EXTERNAL_PACKAGE}/${version})


if(NOT EXISTS ${package_dir}/build/Build${TARGET_EXTERNAL_PACKAGE}.cmake)
	finish_Progress(${GLOBAL_PROGRESS_VAR})
  message(FATAL_ERROR "[PID] CRITICAL ERROR : build configuration file has not been generated for ${TARGET_EXTERNAL_PACKAGE}, please rerun wrapper configruation...")
  return()
endif()

include(${package_dir}/build/Build${TARGET_EXTERNAL_PACKAGE}.cmake)#load the content description

if(${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSIONS) #check that the target version exists
  list(FIND ${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSIONS ${version} INDEX)
  if(INDEX EQUAL -1)
		finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : ${TARGET_EXTERNAL_PACKAGE} external package version ${version} is not defined by wrapper of ${TARGET_EXTERNAL_PACKAGE}")
    return()
  endif()
else()
	finish_Progress(${GLOBAL_PROGRESS_VAR})
  message(FATAL_ERROR "[PID] CRITICAL ERROR : wrapper of ${TARGET_EXTERNAL_PACKAGE} does not define any version (no version subfolder found in src folder of the wrapper, each name of version folder following the pattern major.minor.patch) !!! Build aborted ...")
  return()
endif()

if(NOT EXISTS ${package_version_build_dir})#create the directory for building that version
	file(MAKE_DIRECTORY ${package_version_build_dir})
endif()

if(use_os_variant OR (NOT DO_NOT_EXECUTE_SCRIPT OR NOT DO_NOT_EXECUTE_SCRIPT STREQUAL true))#when executing script or installing OS variant clean the install folder
	if(EXISTS ${package_version_install_dir})#clean the install folder
	  file(REMOVE_RECURSE ${package_version_install_dir})
	endif()
endif()

set(TARGET_INSTALL_DIR ${package_version_install_dir})
#define the build mode
if(NOT TARGET_BUILD_MODE
	 OR (NOT TARGET_BUILD_MODE STREQUAL "Debug" AND NOT TARGET_BUILD_MODE STREQUAL "debug")
	 OR BUILD_RELEASE_ONLY)
	set(CMAKE_BUILD_TYPE Release)
else()#debug only if exlicitly asked for
	message("[PID] INFO: building ${TARGET_EXTERNAL_PACKAGE} in Debug mode...")
	set(CMAKE_BUILD_TYPE Debug)
endif()

if(use_os_variant)#instead of building the project using its variant coming from the current OS/distribution
	#only thing to resolve: the external package equivalent configuration,
	# that is used to check if external package is installed on system
	#this resolution is based on the standard "version" argument of corresponding configuration
	#NOTE: evaluation context is the wrapper itself (so ${TARGET_EXTERNAL_PACKAGE} is passed as calling package)
	check_Platform_Configuration(RESULT_OK CONFIG_NAME CONFIG_CONSTRAINTS ${TARGET_EXTERNAL_PACKAGE} "${TARGET_EXTERNAL_PACKAGE}[version=${version}]" Release)
	if(NOT RESULT_OK)
		finish_Progress(${GLOBAL_PROGRESS_VAR})
		message("[PID] ERROR : Cannot deploy OS variant of ${TARGET_EXTERNAL_PACKAGE} with version ${version} because of platform configuration error !")
		return()
	endif()
	#if system configuration is OK, this means that dependencies are also OK (also installed on system)
	# but we need to be sure to have their CMake description (USE file), as this later will be used on current package description (mandatory for keeping consistency of description)
	message("[PID] INFO : deploying dependencies of ${TARGET_EXTERNAL_PACKAGE} version ${version}...")
	resolve_Wrapper_Dependencies(${TARGET_EXTERNAL_PACKAGE} ${version} TRUE)
	message("[PID] INFO : all required dependencies for external package ${TARGET_EXTERNAL_PACKAGE} version ${version} are satisfied !")

	# After external package own configuration check is OK, we have access to various configuration variables
	# => produce symlinks to the adequate target OS artefacts with adequate names
	generate_OS_Variant_Symlinks(${TARGET_EXTERNAL_PACKAGE} ${CURRENT_PLATFORM} ${version} ${TARGET_INSTALL_DIR})

else()#by default build the given package version using external project specific build process

	# prepare script execution
	set(deploy_script_file ${${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSION_${version}_DEPLOY_SCRIPT})
	set(TARGET_BUILD_DIR ${WORKSPACE_DIR}/wrappers/${TARGET_EXTERNAL_PACKAGE}/build/${version})
	set(TARGET_SOURCE_DIR ${package_version_src_dir})

	set(post_install_script_file ${${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSION_${version}_POST_INSTALL_SCRIPT})
	set(pre_use_script_file ${${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSION_${version}_PRE_USE_SCRIPT})

	#checking for language configurations
	resolve_Wrapper_Language_Configuration(IS_OK ${TARGET_EXTERNAL_PACKAGE} ${version})
	if(NOT IS_OK)
		finish_Progress(${GLOBAL_PROGRESS_VAR})
		message("[PID] ERROR : Cannot satisfy build environment's required language configurations for external package ${TARGET_EXTERNAL_PACKAGE} version ${version} !")
		return()
	else()
		message("[PID] INFO : all required build environment language configurations for external package ${TARGET_EXTERNAL_PACKAGE} version ${version} are satisfied !")
	endif()
	#callback for plugins execution
	manage_Plugins_In_Wrapper_Before_Dependencies_Description(${TARGET_EXTERNAL_PACKAGE} ${version})

	#checking for platform configurations
	resolve_Wrapper_Platform_Configuration(IS_OK ${TARGET_EXTERNAL_PACKAGE} ${version})
	if(NOT IS_OK)
		finish_Progress(${GLOBAL_PROGRESS_VAR})
		message("[PID] ERROR : Cannot satisfy target platform's required configurations for external package ${TARGET_EXTERNAL_PACKAGE} version ${version} !")
		return()
	else()
		message("[PID] INFO : all required platform configurations for external package ${TARGET_EXTERNAL_PACKAGE} version ${version} are satisfied !")
	endif()

	# checking for dependencies
	message("[PID] INFO : deploying dependencies of ${TARGET_EXTERNAL_PACKAGE} version ${version}...")
	resolve_Wrapper_Dependencies(${TARGET_EXTERNAL_PACKAGE} ${version} FALSE)
	message("[PID] INFO : all required dependencies for external package ${TARGET_EXTERNAL_PACKAGE} version ${version} are satisfied !")

	#prepare deployment script execution by caching build variable that may be used inside
	configure_Wrapper_Build_Variables(${TARGET_EXTERNAL_PACKAGE} ${version} ${CURRENT_PLATFORM})

	if(NOT DO_NOT_EXECUTE_SCRIPT OR NOT DO_NOT_EXECUTE_SCRIPT STREQUAL true)

	  message("[PID] INFO : Executing deployment script ${package_version_src_dir}/${deploy_script_file}...")
	  set(ERROR_IN_SCRIPT FALSE)
	  include(${package_version_src_dir}/${deploy_script_file} NO_POLICY_SCOPE)#execute the script
	  if(ERROR_IN_SCRIPT)
		finish_Progress(${GLOBAL_PROGRESS_VAR})
	    message(FATAL_ERROR "[PID] CRITICAL ERROR: Cannot deploy external package ${TARGET_EXTERNAL_PACKAGE} version ${version}...")
	    return()
	  endif()
	endif()
endif()

# generate and install the use file for binary installed version
generate_External_Use_File_For_Version(${TARGET_EXTERNAL_PACKAGE} ${version} ${CURRENT_PLATFORM} "${use_os_variant}")

message("[PID] INFO : Installing external package ${TARGET_EXTERNAL_PACKAGE} version ${version}...")

#create the output folder
file(MAKE_DIRECTORY ${TARGET_INSTALL_DIR}/share)
install_External_Use_File_For_Version(${TARGET_EXTERNAL_PACKAGE} ${version} ${CURRENT_PLATFORM})
install_External_Find_File_For_Version(${TARGET_EXTERNAL_PACKAGE})
install_External_PID_Version_File_For_Version(${TARGET_EXTERNAL_PACKAGE} ${version} ${CURRENT_PLATFORM})
if(NOT use_os_variant)# perform specific operations at the end of the install process, if any specified and if external package is not the OS_variant
	install_External_Rpath_Symlinks(${TARGET_EXTERNAL_PACKAGE} ${version} ${CURRENT_PLATFORM})
	if(CURRENT_PYTHON)#only install python packages if python set for target platform
		install_External_Python_Packages(${TARGET_EXTERNAL_PACKAGE} ${version} ${CURRENT_PLATFORM} ${CURRENT_PYTHON})
	endif()
	if(post_install_script_file AND EXISTS ${package_version_src_dir}/${post_install_script_file})
	  file(COPY ${package_version_src_dir}/${post_install_script_file} DESTINATION  ${TARGET_INSTALL_DIR}/cmake_script)
	  message("[PID] INFO : performing post install operations from file ${TARGET_INSTALL_DIR}/cmake_script/${post_install_script_file} ...")
		set(${TARGET_EXTERNAL_PACKAGE}_VERSION_STRING ${version})#only variable that is not defined yet is the version string of current project
		get_filename_component(post_install_filename ${package_version_src_dir}/${post_install_script_file} NAME)
		include(${TARGET_INSTALL_DIR}/cmake_script/${post_install_filename} NO_POLICY_SCOPE)#execute the script
	endif()

	if(pre_use_script_file AND EXISTS ${package_version_src_dir}/${pre_use_script_file})
		file(COPY ${package_version_src_dir}/${pre_use_script_file} DESTINATION  ${TARGET_INSTALL_DIR}/cmake_script)
		#simply copy the file, the script will be executed later (at user package install time)
	endif()

	# create a relocatable binary archive, on demand.
	if(GENERATE_BINARY_ARCHIVE AND (GENERATE_BINARY_ARCHIVE STREQUAL "true" OR GENERATE_BINARY_ARCHIVE STREQUAL "TRUE" OR GENERATE_BINARY_ARCHIVE STREQUAL "ON"))
	  #cleaning the build folder to start from a clean situation
		set(name_of_archive_folder ${TARGET_EXTERNAL_PACKAGE}-${version}-${CURRENT_PLATFORM})
		set(path_to_installer_content ${TARGET_BUILD_DIR}/installer/${name_of_archive_folder})
	  if(EXISTS ${path_to_installer_content} AND IS_DIRECTORY ${path_to_installer_content})
	    file(REMOVE_RECURSE ${path_to_installer_content})
	  endif()

	  generate_Binary_Package_Name(${TARGET_EXTERNAL_PACKAGE} ${version} ${CMAKE_BUILD_TYPE} installer_archive_name installer_folder_unused)
	  set(path_to_installer_archive ${TARGET_BUILD_DIR}/installer/${installer_archive_name})
	  file(REMOVE ${path_to_installer_archive})

	  #need to create an archive from relocatable binary created in install tree (use the / at the end of the copied path to target content of the folder and not folder itself)
	  file(COPY ${TARGET_INSTALL_DIR}/ DESTINATION ${path_to_installer_content})

	  #generate archive
		#TODO check
	  execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${TARGET_BUILD_DIR}/installer ${CMAKE_COMMAND} -E tar cvf ${installer_archive_name} ${name_of_archive_folder}
				WORKING_DIRECTORY ${TARGET_BUILD_DIR}/installer
	   )

	  # immediate cleaning to avoid keeping unecessary data in build tree
	  if(EXISTS ${path_to_installer_content} AND IS_DIRECTORY ${path_to_installer_content})
	    file(REMOVE_RECURSE ${path_to_installer_content})
	  endif()
	  message("[PID] INFO : binary archive for external package ${TARGET_EXTERNAL_PACKAGE} version ${version} has been generated.")
	endif()
	message("[PID] INFO : external package ${TARGET_EXTERNAL_PACKAGE} version ${version} built.")
else()
	message("[PID] INFO : external package ${TARGET_EXTERNAL_PACKAGE} version ${version} configured from OS settings.")
endif()
#call back for plugins execution
manage_Plugins_In_Wrapper_After_Components_Description(${TARGET_EXTERNAL_PACKAGE} ${version})

finish_Progress(${GLOBAL_PROGRESS_VAR})
