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

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake) # adding the cmake scripts files from the package
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/find) # using common find modules of the workspace
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references) # using common find modules of the workspace
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/constraints/platforms) # using platform check modules

include(PID_Utils_Functions NO_POLICY_SCOPE)
include(Wrapper_Definition NO_POLICY_SCOPE) # to be able to interpret description of external packages and generate the use files
include(External_Definition NO_POLICY_SCOPE) #to be able to interpret description of dependencies (external packages)

load_Current_Platform() #loading the current platform configuration before executing the deploy script

#########################################################################################
#######################################Build script #####################################
#########################################################################################

message("[PID] INFO : building wrapper for external package ${TARGET_EXTERNAL_PACKAGE} version ${TARGET_EXTERNAL_VERSION}...")
#checking that user input is coherent
if(NOT TARGET_EXTERNAL_VERSION OR TARGET_EXTERNAL_VERSION STREQUAL "")
  message(FATAL_ERROR "[PID] CRITICAL ERROR: you must define the version to build and deploy using version= argument to the build command")
  return()
endif()

if(NOT TARGET_BUILD_MODE OR (NOT TARGET_BUILD_MODE STREQUAL "Debug" AND NOT TARGET_BUILD_MODE STREQUAL "debug"))
  set(CMAKE_BUILD_TYPE Release)
else()
  set(CMAKE_BUILD_TYPE Debug)
endif()

set(package_dir ${WORKSPACE_DIR}/wrappers/${TARGET_EXTERNAL_PACKAGE})
set(package_version_src_dir ${package_dir}/src/${TARGET_EXTERNAL_VERSION})
set(package_version_build_dir ${package_dir}/build/${TARGET_EXTERNAL_VERSION})
set(package_version_install_dir ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${TARGET_EXTERNAL_PACKAGE}/${TARGET_EXTERNAL_VERSION})

if(NOT EXISTS ${package_version_build_dir})
  file(MAKE_DIRECTORY ${package_version_build_dir})
endif()

if(NOT EXISTS ${package_dir}/build/Build${TARGET_EXTERNAL_PACKAGE}.cmake)
  message(FATAL_ERROR "[PID] CRITICAL ERROR : build configuration file has not been generated for ${TARGET_EXTERNAL_PACKAGE}, please rerun wrapper configruation...")
  return()
endif()

include(${package_dir}/build/Build${TARGET_EXTERNAL_PACKAGE}.cmake)#load the content description

if(${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSIONS) #check that the target version exist
  list(FIND ${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSIONS ${TARGET_EXTERNAL_VERSION} INDEX)
  if(INDEX EQUAL -1)
    message(FATAL_ERROR "[PID] CRITICAL ERROR : ${TARGET_EXTERNAL_PACKAGE} external package version ${TARGET_EXTERNAL_VERSION} is not defined by wrapper of ${TARGET_EXTERNAL_PACKAGE}")
    return()
  endif()
else()
  message(FATAL_ERROR "[PID] CRITICAL ERROR : wrapper of ${TARGET_EXTERNAL_PACKAGE} does not define any version !!! Build aborted ...")
  return()
endif()

if(EXISTS ${package_version_install_dir})#clean the install folder
  file(REMOVE_RECURSE ${package_version_install_dir})
endif()

# prepare script execution
set(deploy_script_file ${${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSION_${TARGET_EXTERNAL_VERSION}_DEPLOY_SCRIPT})
set(TARGET_BUILD_DIR ${WORKSPACE_DIR}/wrappers/${TARGET_EXTERNAL_PACKAGE}/build/${TARGET_EXTERNAL_VERSION})
set(TARGET_INSTALL_DIR ${package_version_install_dir})

set(post_install_script_file ${${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSION_${TARGET_EXTERNAL_VERSION}_POST_INSTALL_SCRIPT})

if(NOT DO_NOT_EXECUTE_SCRIPT OR NOT DO_NOT_EXECUTE_SCRIPT STREQUAL true)
  message("[PID] INFO : Executing deployment script ${package_version_src_dir}/${deploy_script_file}...")
  set(ERROR_IN_SCRIPT FALSE)
  include(${package_version_src_dir}/${deploy_script_file} NO_POLICY_SCOPE)#execute the script
  if(ERROR_IN_SCRIPT)
    message("[PID] ERROR : Cannot deploy external package ${TARGET_EXTERNAL_PACKAGE} version ${TARGET_EXTERNAL_VERSION}...")
    return()
  endif()
endif()

# generate and install the use file
generate_External_Use_File_For_Version(${TARGET_EXTERNAL_PACKAGE} ${TARGET_EXTERNAL_VERSION} ${CURRENT_PLATFORM})
message("[PID] INFO : Installing external package ${TARGET_EXTERNAL_PACKAGE} version ${TARGET_EXTERNAL_VERSION}...")

#create the output folder
file(MAKE_DIRECTORY ${TARGET_INSTALL_DIR}/share)
install_External_Use_File_For_Version(${TARGET_EXTERNAL_PACKAGE} ${TARGET_EXTERNAL_VERSION} ${CURRENT_PLATFORM})

if(post_install_script_file AND EXISTS ${package_version_src_dir}/${post_install_script_file})
  file(COPY ${package_version_src_dir}/${post_install_script_file} DESTINATION  ${TARGET_INSTALL_DIR}/share)
  message("[PID] Info performing post install operations from file ${TARGET_INSTALL_DIR}/share/${post_install_script_file} ...")
  include(${TARGET_INSTALL_DIR}/share/${post_install_script_file} NO_POLICY_SCOPE)#execute the script
endif()

if(GENERATE_BINARY_ARCHIVE AND (GENERATE_BINARY_ARCHIVE STREQUAL "true" OR GENERATE_BINARY_ARCHIVE STREQUAL "TRUE"))
  #cleaning the build folder to start from a clean situation
  set(path_to_installer_content ${WORKSPACE_DIR}/wrappers/${TARGET_EXTERNAL_PACKAGE}/build/${TARGET_EXTERNAL_PACKAGE}-${TARGET_EXTERNAL_VERSION}-${CURRENT_PLATFORM})
  if(EXISTS ${path_to_installer_content} AND IS_DIRECTORY ${path_to_installer_content})
    file(REMOVE_RECURSE ${path_to_installer_content})
  endif()

  if(TARGET_BUILD_MODE STREQUAL "Debug")
    set(path_to_installer_archive ${WORKSPACE_DIR}/wrappers/${TARGET_EXTERNAL_PACKAGE}/build/${TARGET_EXTERNAL_PACKAGE}-${TARGET_EXTERNAL_VERSION}-dbg-${CURRENT_PLATFORM}.tar.gz)
  else()
    set(path_to_installer_archive ${WORKSPACE_DIR}/wrappers/${TARGET_EXTERNAL_PACKAGE}/build/${TARGET_EXTERNAL_PACKAGE}-${TARGET_EXTERNAL_VERSION}-${CURRENT_PLATFORM}.tar.gz)
  endif()
  file(REMOVE ${path_to_installer_archive})

  #need to create an archive from relocatable binary created in install tree (use the / at the end of the copied path to target content of the folder and not folder itself)
  file(COPY ${TARGET_INSTALL_DIR}/ DESTINATION ${path_to_installer_content})

  #generate archive
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar cf ${path_to_installer_archive}
      ${path_to_installer_content}
    )

  # immediate cleaning to avoid keeping unecessary data in build tree
  if(EXISTS ${path_to_installer_content} AND IS_DIRECTORY ${path_to_installer_content})
    file(REMOVE_RECURSE ${path_to_installer_content})
  endif()
  message("[PID] INFO : binary archive for external package ${TARGET_EXTERNAL_PACKAGE} version ${TARGET_EXTERNAL_VERSION} has been generated.")
endif()

message("[PID] INFO : external package ${TARGET_EXTERNAL_PACKAGE} version ${TARGET_EXTERNAL_VERSION} built.")
