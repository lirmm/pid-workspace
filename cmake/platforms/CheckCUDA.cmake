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

function(get_Greatest_CUDA_Arch RES_ARCH available_archs)
  set(max_arch 0.0)
  foreach(arch IN LISTS available_archs)
    if(arch VERSION_GREATER max_arch)
      set(max_arch ${arch})
    endif()
  endforeach()
  set(${RES_ARCH} ${max_arch} PARENT_SCOPE)
endfunction()

set(CUDA_Language_AVAILABLE FALSE CACHE INTERNAL "")
# CUDA arch may have been directly set in CMAKE_CUDA_FLAGS
set(used_CUDA_ARCH)
foreach(flag IN LISTS CMAKE_CUDA_FLAGS)
  if(flag MATCHES "arch=compute_([0-9]+),code=sm_([0-9]+)")
    string(REGEX REPLACE "([0-9]+)([0-9])$" "\\1.\\2" used_arch ${CMAKE_MATCH_1})
    list(APPEND used_CUDA_ARCH ${used_arch})
    break()
  endif()
endforeach()

set(CUDA_USE_STATIC_CUDA_RUNTIME OFF CACHE INTERNAL "")
set(CUDA_LIBRARIES CACHE INTERNAL "")
set(CUDA_INCLUDE_DIRS CACHE INTERNAL "")
find_package(CUDA)

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
unset(CMAKE_CUDA_FLAGS)
set(CMAKE_CUDA_FLAGS CACHE INTERNAL "" FORCE) #for security, avoid setting flags when language is checked (otherwise if errors occurs they will be persistent)
if(NOT PID_CROSSCOMPILATION)#when crosscompiling simply do not check language and use what is provided
  set(CUDA_INCLUDE_DIRS ${CUDA_INCLUDE_DIRS} CACHE INTERNAL "" FORCE)
  check_language(CUDA)#only check for language if crosscompilation is not active
  if(NOT CMAKE_CUDA_COMPILER)
    set(CMAKE_CUDA_COMPILER ${CUDA_NVCC_EXECUTABLE} CACHE INTERNAL "" FORCE)
  endif()
  check_language(CUDA)
  if(NOT CMAKE_CUDA_HOST_COMPILER)
    set(CMAKE_CUDA_HOST_COMPILER ${CUDA_HOST_COMPILER} CACHE FILEPATH "Path to CUDA host CC compiler" FORCE)
  endif()
  #if language automatic detection failed then force it a bit
endif()

if(CMAKE_CUDA_COMPILER)
  enable_language(CUDA)
else()#create the variable from the one created by find_package(CUDA)
  message("[PID] WARNING : cannot automatically detect CUDA. Please set the CUDA_TOOLKIT_ROOT_DIR variable !")
  return()
endif()

set(CUDA_LIBRARIES ${CUDA_LIBRARIES} CACHE INTERNAL "" FORCE)
mark_as_advanced(CMAKE_CUDA_COMPILER CMAKE_CUDA_HOST_COMPILER)

#manage soname to test for binary compatibility
get_Soname_Info_From_Library_Path(LIB_PATH SONAME SOVERSION cudart ${CUDA_LIBRARIES})
set(CUDA_STANDARD_LIBRARIES ${SONAME} CACHE INTERNAL "")
set(CUDA_STD_SYMBOLS CACHE INTERNAL "")#no symbol version in cuda library

# Check which arch can be computed depending on the version of NVCC
# reference is https://en.wikipedia.org/wiki/CUDA
set(possible_CUDA_codes )
execute_process(
      COMMAND "${CMAKE_CUDA_COMPILER}" --list-gpu-code
      OUTPUT_VARIABLE CUDA_SUPPORTED_CODES
      RESULT_VARIABLE CUDA_QUERY_RESULT
      OUTPUT_STRIP_TRAILING_WHITESPACE
      )
if(NOT CUDA_QUERY_RESULT EQUAL 0)
  message("[PID] ERROR: Failed to query supported CUDA architectures.")
endif()
string(REGEX MATCHALL "sm_[0-9]+[a-z]*" possible_CUDA_codes "${CUDA_SUPPORTED_CODES}")
string(REGEX REPLACE "sm_" "" possible_CUDA_codes "${possible_CUDA_codes}")
set(AVAILABLE_CUDA_ARCHS_DOTTED)
foreach(code IN LISTS possible_CUDA_codes)          # cuda_codes = 35;37;50;...;86;87
  math(EXPR major "${code} / 10")
  math(EXPR minor "${code} % 10")
  list(APPEND AVAILABLE_CUDA_ARCHS_DOTTED "${major}.${minor}")
endforeach()
set(AVAILABLE_CUDA_ARCHS ${AVAILABLE_CUDA_ARCHS_DOTTED} CACHE INTERNAL "")

if(used_CUDA_ARCH) #target architecture has been specified using environment
  set(DEFAULT_CUDA_ARCH ${used_CUDA_ARCH} CACHE INTERNAL "")#default arch is greater available
else()
  # we are not in the context of evaluating an environment on current host
  # detecting current CUDA architecture on host, if any
  # goal is to set default values for used architectures
  execute_process( COMMAND ${CMAKE_CUDA_COMPILER} --cudart shared --compiler-bindir ${CMAKE_CUDA_HOST_COMPILER} ${WORKSPACE_DIR}/cmake/platforms/checks/DetectCudaArch.cu --run
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
    if(ADDITIONAL_DEBUG_INFO)
      message("[PID] WARNING: no CUDA GPU found while a CUDA compiler is installed. Cannot detect default CUDA architecture. This is probably due to a problem in mismatching driver/toolkit versions. Please install your CUDA drivers.")
    endif()
    #cannot detect so compile for every possible known card supported by the compiler
    set(DEFAULT_CUDA_ARCH ${AVAILABLE_CUDA_ARCHS} CACHE INTERNAL "")#default arch is greater available
    set(DEFAULT_CUDA_DRIVER CACHE INTERNAL "")#no default driver means no nvidia card installed
    set(DEFAULT_CUDA_RUNTIME CACHE INTERNAL "")#no default runtime means no nvidia card installed
  endif()
endif()
set(final_cuda_flag)
foreach(arch IN LISTS DEFAULT_CUDA_ARCH)
  string(REGEX REPLACE "\\." "" arch "${arch}")
  set(final_cuda_flag "${final_cuda_flag} -gencode arch=compute_${arch},code=sm_${arch}")
endforeach()
set(final_cuda_flag "${final_cuda_flag} -D_FORCE_INLINES")
string(STRIP "${final_cuda_flag}" final_cuda_flag)
set(CMAKE_CUDA_FLAGS "${final_cuda_flag}" CACHE STRING "" FORCE)

set(CUDA_NVCC_FLAGS "${CMAKE_CUDA_FLAGS}" CACHE STRING "" FORCE)
