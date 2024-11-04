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

set(CUDA_EVAL_RESULT FALSE)
set(LANG_CUDA_PLATFORM_CONSTRAINTS)

if(NOT CUDA_Language_AVAILABLE)#if the CUDA version is NOT available => CUDA not defined
	return()#if NVCC not found no need to continue
endif()

if(CUDA_version # a version constraint is defined (if code works only with a given version)
	AND NOT CUDA_version VERSION_EQUAL CUDA_VERSION) #required VS provided CUDA versions DOES NOT MATCH !
	return()
endif()

if(CUDA_min_version)
  if(CUDA_VERSION VERSION_LESS CUDA_min_version)
    return()
  endif()
endif()

if(CUDA_max_version)
  if(CUDA_VERSION VERSION_GREATER_EQUAL CUDA_max_version)
    return()
  endif()
endif()

if(CUDA_architecture)
  foreach(an_arch IN LISTS CUDA_architecture)
    list(FIND AVAILABLE_CUDA_ARCHS ${an_arch} INDEX)
    if(INDEX EQUAL -1)
      return()#arch cannot ne used !!
    endif()
  endforeach()
else()
  set(CUDA_architecture ${DEFAULT_CUDA_ARCH}) #using the default CUDA arch by default
endif()
set(CUDA_soname ${CUDA_STANDARD_LIBRARIES})

# now set the flags according to the selected archs
set(NVCC_FLAGS_EXTRA "")# NVCC flags to be set when using target architectures
foreach(an_arch IN LISTS CUDA_architecture)
  string(REGEX REPLACE "\\." "" res_number "${an_arch}")
  # Tell NVCC to add binaries for the specified GPUs
  set(NVCC_FLAGS_EXTRA "${NVCC_FLAGS_EXTRA} -gencode arch=compute_${res_number},code=sm_${res_number}")
endforeach()

set(NVCC_FLAGS_EXTRA "${NVCC_FLAGS_EXTRA} -D_FORCE_INLINES")
#set the compile flags to ensure that locally compiled units match requirements in binary
set(CUDA_NVCC_FLAGS ${NVCC_FLAGS_EXTRA} CACHE STRING "" FORCE)
set(CMAKE_CUDA_FLAGS ${NVCC_FLAGS_EXTRA} CACHE STRING "" FORCE)
set(CUDA_EVAL_RESULT TRUE)
