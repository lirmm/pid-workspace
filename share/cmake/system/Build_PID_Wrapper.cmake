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

if(NOT TARGET_EXTERNAL_VERSION OR TARGET_EXTERNAL_VERSION STREQUAL "")
  message(FATAL_ERROR "[PID] CRITICAL ERROR: you must define the version to build and deploy using version= argument to the build command")
  return()
endif()
set(package_dir ${WORKSPACE_DIR}/wrappers/${TARGET_EXTERNAL_PACKAGE})
set(package_version_src_dir ${package_dir}/src/${TARGET_EXTERNAL_VERSION})
set(package_version_build_dir ${package_dir}/build/${TARGET_EXTERNAL_VERSION})
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

set(target_script_file ${${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSION_${TARGET_EXTERNAL_VERSION}_SCRIPT_FILE})
set(target_script_type ${${TARGET_EXTERNAL_PACKAGE}_KNOWN_VERSION_${TARGET_EXTERNAL_VERSION}_SCRIPT_TYPE})


message("[PID] INFO : Executing install script ${package_version_src_dir}/${target_script_file}...")
if(target_script_type STREQUAL SHELL)
  execute_process(COMMAND ${package_version_src_dir}/${target_script_file}
                WORKING_DIRECTORY ${package_version_build_dir})
elseif(target_script_type STREQUAL CMAKE)
  set(CURRENT_WORKING_DIRECTORY ${package_version_build_dir})
  include(${package_version_src_dir}/${target_script_file} NO_POLICY_SCOPE)
endif()
