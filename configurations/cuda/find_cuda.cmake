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

set(cuda_FOUND FALSE CACHE INTERNAL "")
# - Find cuda installation
# Try to find libraries for cuda on UNIX systems. The following values are defined
#  cuda_FOUND        - True if cuda is available
#  cuda_LIBRARIES    - link against these to use cuda library

set(CUDA_USE_STATIC_CUDA_RUNTIME FALSE CACHE INTERNAL "" FORCE)
set(cuda_BINARY_CONSTRAINTS)
if(CUDA_VERSION)#if the CUDA version is known (means that a nvcc compiler has been defined)
	if(NOT cuda_architecture) #no target architecture defined => take the default one
		list(APPEND cuda_BINARY_CONSTRAINTS "architecture=${DEFAULT_CUDA_ARCH}") #architecture is the only argument that must be constrained in the resulting binary
	endif()#otherwise the constraint on architecture will exists beore calling the configuration

	if(	NOT cuda_version														#no contraint on version
			OR cuda_version VERSION_EQUAL CUDA_VERSION) #required VS provided CUDA version match !
		set(adequate_version_found TRUE)
	else()
		set(adequate_version_found FALSE)
	endif()

	if( NOT cuda_architecture                            #no contraint on architecture
			OR cuda_architecture STREQUAL DEFAULT_CUDA_ARCH  #required VS provided CUDA architecture match !
		)
		set(arch_to_use ${DEFAULT_CUDA_ARCH})
	else()#there is a target architecture defined but not the default one
		list(FIND AVAILABLE_CUDA_ARCHS ${cuda_architecture} INDEX)
		if(NOT INDEX EQUAL -1)#check if the target arch is a possible arch for NVCC compiler
			list(GET AVAILABLE_CUDA_ARCHS ${INDEX} RES_ARCH) #TODO detect possible architecture for nvcc then compare
			set(arch_to_use ${RES_ARCH})
		else()
			set(arch_to_use)
		endif()
	endif()

	if(arch_to_use AND adequate_version_found)
		set(cuda_FOUND TRUE CACHE INTERNAL "")
		set(cuda_ARCHITECTURE ${arch_to_use} CACHE INTERNAL "")

		# NVCC flags to be set
		set(NVCC_FLAGS_EXTRA "")
		set(CUDA_ARCH_BIN "")
		set(CUDA_ARCH_FEATURES "")

		string(REGEX REPLACE "\\." "" ARCH_BIN_NO_POINTS "${arch_to_use}")
		string(REGEX MATCHALL "[0-9()]+" ARCH_LIST "${ARCH_BIN_NO_POINTS}")

		# Tell NVCC to add binaries for the specified GPUs
		foreach(arch IN LISTS ARCH_LIST)
		  if(arch MATCHES "([0-9]+)\\(([0-9]+)\\)")
		    # User explicitly specified PTX for the concrete BIN
		    set(NVCC_FLAGS_EXTRA ${NVCC_FLAGS_EXTRA} -gencode arch=compute_${CMAKE_MATCH_2},code=sm_${CMAKE_MATCH_1})
		    set(CUDA_ARCH_BIN "${CUDA_ARCH_BIN} ${CMAKE_MATCH_1}"  CACHE INTERNAL "")
		    set(CUDA_ARCH_FEATURES "${CUDA_ARCH_FEATURES} ${CMAKE_MATCH_2}"  CACHE INTERNAL "")
		  else()
		    # User didn't explicitly specify PTX for the concrete BIN, we assume PTX=BIN
		    set(NVCC_FLAGS_EXTRA ${NVCC_FLAGS_EXTRA} -gencode arch=compute_${ARCH},code=sm_${ARCH})
		    set(CUDA_ARCH_BIN "${CUDA_ARCH_BIN} ${ARCH}"  CACHE INTERNAL "")
		    set(CUDA_ARCH_FEATURES "${CUDA_ARCH_FEATURES} ${ARCH}"  CACHE INTERNAL "")
		  endif()
		endforeach()
		set(NVCC_FLAGS_EXTRA ${NVCC_FLAGS_EXTRA} -D_FORCE_INLINES)
		# These vars will be processed in other scripts
		set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} ${NVCC_FLAGS_EXTRA} CACHE INTERNAL "" FORCE)
		set(CMAKE_CUDA_FLAGS ${CUDA_NVCC_FLAGS} CACHE INTERNAL "" FORCE)
	endif()
endif()#if NVCC not found no need to continue
