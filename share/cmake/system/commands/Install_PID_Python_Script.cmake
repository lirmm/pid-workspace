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

# using systems scripts the workspace
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)

include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration

if(NOT CURRENT_PYTHON)
  return()#do nothing if python not configured
endif()

get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})

if(CURRENT_PLATFORM_OS STREQUAL "macosx")
    set(module_binary_name ${TARGET_MODULE}${TARGET_SUFFIX}.dylib)
else()
    set(module_binary_name ${TARGET_MODULE}${TARGET_SUFFIX}.so)
endif()

# compute the path to the target module install folder
set(path_to_package_install ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE}/${TARGET_VERSION})
set(path_to_python_install ${WORKSPACE_DIR}/install/python${CURRENT_PYTHON})
set(path_to_module_python_wrapper ${path_to_package_install}/share/script/${TARGET_MODULE})#name is unique for DEBUG or RELEASE versions

if(TARGET_COMPONENT_TYPE STREQUAL "MODULE")#this is a binary module for wrapping c++ code into python
  set(path_to_module ${path_to_package_install}/lib/${module_binary_name})
  # 1) create the symlink to the module library
  message("-- Installing: ${path_to_module_python_wrapper}/${module_binary_name}")
  create_Symlink(${path_to_module} ${path_to_module_python_wrapper}/${module_binary_name})#generate the symlink used
endif()

# 2) now in python folder creating a symlink pointing to the module script folder
contains_Python_Package_Description(IS_PYTHON_PACK ${path_to_module_python_wrapper})
if(IS_PYTHON_PACK)
  if(NOT EXISTS path_to_python_install)
    file(MAKE_DIRECTORY ${path_to_python_install})
  endif()
  create_Symlink(${path_to_module_python_wrapper} ${path_to_python_install}/${TARGET_MODULE}${TARGET_SUFFIX})#generate the symlink used
  message("-- Installing: ${path_to_python_install}/${TARGET_MODULE}${TARGET_SUFFIX}")
endif()
