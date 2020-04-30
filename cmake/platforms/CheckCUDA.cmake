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

set(CUDA_Language_AVAILABLE FALSE CACHE INTERNAL "")

set(CUDA_USE_STATIC_CUDA_RUNTIME OFF CACHE INTERNAL "")
set(CUDA_LIBRARIES CACHE INTERNAL "")
set(CUDA_INCLUDE_DIRS CACHE INTERNAL "")
find_package(CUDA)
if(NOT CUDA_nppi_LIBRARY)#nppi is deduced from other libs (just to allow old code to resolve symbols)
  set(CUDA_nppi_LIBRARY ${CUDA_nppial_LIBRARY} ${CUDA_nppicc_LIBRARY} ${CUDA_nppicom_LIBRARY} ${CUDA_nppidei_LIBRARY} ${CUDA_nppif_LIBRARY} ${CUDA_nppig_LIBRARY} ${CUDA_nppim_LIBRARY} ${CUDA_nppist_LIBRARY} ${CUDA_nppisu_LIBRARY} ${CUDA_nppitc_LIBRARY} CACHE INTERNAL "" FORCE)
endif()

if(NOT CUDA_npp_LIBRARY)#old "all in one" npp library has been splitted into 3 libs (since 5.0)
  set(CUDA_npp_LIBRARY ${CUDA_nppi_LIBRARY} ${CUDA_nppc_LIBRARY} ${CUDA_npps_LIBRARY} CACHE INTERNAL "" FORCE)
endif()

if(NOT CUDA_FOUND)#simply stop the configuration
  if(NOT CUDA_NVCC_EXECUTABLE OR NOT CUDA_VERSION)
    message("[PID] WARNING : CUDA language is not supported because no CUDA compiler has been found.")
    return()
  else()#situation where runtime things have been found but toolkit "things" have not been found
        #try to find again but automatically setting the toolkit root dir from
        get_filename_component(PATH_TO_BIN ${CUDA_NVCC_EXECUTABLE} REALPATH)#get the path with symlinks resolved
        get_filename_component(PATH_TO_BIN_FOLDER ${PATH_TO_BIN} DIRECTORY)#get the path with symlinks resolved
        if(PATH_TO_BIN_FOLDER MATCHES "^.*/bin(32|64)?$")#if path finishes with bin or bin32 or bin 64
          #remove the binary folder
          get_filename_component(PATH_TO_TOOLKIT ${PATH_TO_BIN_FOLDER} DIRECTORY)#get folder containing the bin folder
        endif()

        if(PATH_TO_TOOLKIT AND EXISTS ${PATH_TO_TOOLKIT})
          set(CUDA_TOOLKIT_ROOT_DIR ${PATH_TO_TOOLKIT} CACHE PATH "" FORCE)
        endif()
        find_package(CUDA)
        if(NOT CUDA_FOUND)#simply stop the configuration
          message("[PID] WARNING : cannot automatically find all CUDA artefacts. Please set the CUDA_TOOLKIT_ROOT_DIR variable !")
          return()
        endif()
  endif()
endif()

#setting general variables
set(CUDA_Language_AVAILABLE TRUE CACHE INTERNAL "")
#memorizing build variables
if(NOT CMAKE_VERSION VERSION_LESS 3.8)#if version < 3.8 CUDA language is not natively supported by CMake
  check_language(CUDA)
  if(CMAKE_CUDA_COMPILER)
    enable_language(CUDA)
  else()#create the variable from the one created by find_package(CUDA)
    set(CMAKE_CUDA_COMPILER ${CUDA_NVCC_EXECUTABLE} CACHE FILEPATH "" FORCE)
  endif()
else()
  set(CMAKE_CUDA_COMPILER ${CUDA_NVCC_EXECUTABLE} CACHE FILEPATH "" FORCE)
endif()


set(CUDA_LIBRARIES ${CUDA_LIBRARIES} CACHE INTERNAL "" FORCE)
set(CUDA_INCLUDE_DIRS ${CUDA_INCLUDE_DIRS} CACHE INTERNAL "" FORCE)
set(CMAKE_CUDA_HOST_COMPILER ${CUDA_HOST_COMPILER} CACHE FILEPATH "" FORCE)
mark_as_advanced(CMAKE_CUDA_COMPILER CMAKE_CUDA_HOST_COMPILER)

#manage soname to test for binary compatibility
get_Soname_Info_From_Library_Path(LIB_PATH SONAME SOVERSION cudart ${CUDA_LIBRARIES})
set(CUDA_STANDARD_LIBRARIES ${SONAME} CACHE INTERNAL "")
set(CUDA_STD_SYMBOLS CACHE INTERNAL "")#no symbol version in cuda library

set(__cuda_arch_bin)
set(__cuda_arch_ptx)

# Check which arch can be computed depending on the version of NVCC
if(CUDA_VERSION VERSION_LESS "6.0")#CUDA not really managed under version 6
  set(AVAILABLE_CUDA_ARCHS "2.0" "2.1" "3.0" "3.2" "3.5" CACHE INTERNAL "")
elseif(CUDA_VERSION VERSION_LESS "8.0")
  set(AVAILABLE_CUDA_ARCHS  "2.0" "2.1" "3.0" "3.2" "3.5" "5.0" "5.2" CACHE INTERNAL "")
elseif(CUDA_VERSION VERSION_LESS "9.0")
  set(AVAILABLE_CUDA_ARCHS  "2.0" "2.1" "3.0" "3.2" "3.5" "5.0" "5.2" "6.0" "6.1" CACHE INTERNAL "")
else()#version is greater than 9, deprecated arch are 201 21, etc.
  set(AVAILABLE_CUDA_ARCHS  "3.0" "3.2" "3.5" "5.0" "5.2" "6.0" "6.1" "6.2" "7.0" "7.2" "7.5" CACHE INTERNAL "")
endif()

# detecting current CUDA architecture on host, if any
# goal is to set default values for used architectures
execute_process( COMMAND ${CUDA_NVCC_EXECUTABLE} --compiler-bindir ${CMAKE_CUDA_HOST_COMPILER} ${WORKSPACE_DIR}/cmake/platforms/checks/DetectCudaArch.cu --run
                   WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
                   RESULT_VARIABLE _nvcc_res OUTPUT_VARIABLE _nvcc_out ERROR_VARIABLE _nvcc_error
                   OUTPUT_STRIP_TRAILING_WHITESPACE)

if(_nvcc_res EQUAL 0)#OK default arch has been found
  list(GET _nvcc_out 0 nb_devices)
  set(nb_device_managed 0)
  while(nb_device_managed LESS nb_devices)
    math(EXPR nb_device_managed "${nb_device_managed}+1")#increment first to use it in list(GET)
    list(GET _nvcc_out ${nb_device_managed} device_managed)
    list(APPEND using_arch ${device_managed})
  endwhile()
  math(EXPR nb_device_managed "${nb_device_managed}+1")
  list(GET _nvcc_out ${nb_device_managed} driver_version)
  math(EXPR nb_device_managed "${nb_device_managed}+1")
  list(GET _nvcc_out ${nb_device_managed} runtime_version)
  # choose the default arch among those available (take the greatest version)
  set(DEFAULT_CUDA_ARCH ${using_arch} CACHE INTERNAL "")#there may have more than one arch specified if more than one CPU is used
  set(DEFAULT_CUDA_DRIVER ${driver_version} CACHE INTERNAL "")
  set(DEFAULT_CUDA_RUNTIME ${runtime_version} CACHE INTERNAL "")
else()#error during nvcc compilation
  message("[PID] WARNING: no CUDA GPU found while a CUDA compiler is installed. Error message from nvcc is : ${_nvcc_error}")
  set(DEFAULT_CUDA_ARCH CACHE INTERNAL "")#no default arch means no nvidia card installed
  set(DEFAULT_CUDA_DRIVER CACHE INTERNAL "")#no default driver means no nvidia card installed
  set(DEFAULT_CUDA_RUNTIME CACHE INTERNAL "")#no default runtime means no nvidia card installed
endif()
