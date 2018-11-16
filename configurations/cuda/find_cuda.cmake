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

include(Configuration_Definition NO_POLICY_SCOPE)

found_PID_Configuration(cuda FALSE)

if(CUDA_VERSION)#if the CUDA version is known (means that a nvcc compiler has been defined)
	if(	NOT cuda_version														#no contraint on version
			OR cuda_version VERSION_EQUAL CUDA_VERSION) #required VS provided CUDA version match !
		set(adequate_version_found TRUE)
	else()
		set(adequate_version_found FALSE)
	endif()

	if(NOT cuda_architecture)                            #no contraint on architecture
		set(arch_to_use ${DEFAULT_CUDA_ARCH})
	else()#there is one or more target architecture(s) defined
		foreach(arch IN LISTS cuda_architecture)
			list(FIND AVAILABLE_CUDA_ARCHS ${cuda_architecture} INDEX)
			if(NOT INDEX EQUAL -1)#check if the target arch is a possible arch for NVCC compiler
				list(GET AVAILABLE_CUDA_ARCHS ${INDEX} RES_ARCH)
				list(APPEND arch_to_use ${RES_ARCH})
			else()#problem => cannot build for all architectures so exit
				set(arch_to_use)
				break()
			endif()
		endforeach()
	endif()

	if(arch_to_use AND adequate_version_found)
		found_PID_Configuration(cuda TRUE)
		set(CUDA_ARCH ${arch_to_use})


		set(NVCC_FLAGS_EXTRA "")# NVCC flags to be set
		set(CUDA_ARCH_REAL "")# CUDA sm architecture
		set(CUDA_ARCH_FEATURES "")# CUDA compute architecture

		string(REGEX REPLACE "\\." "" ARCH_LIST "${CUDA_ARCH}")
		# Tell NVCC to add binaries for the specified GPUs
		foreach(arch IN LISTS ARCH_LIST)
		  set(NVCC_FLAGS_EXTRA ${NVCC_FLAGS_EXTRA} -gencode arch=compute_${arch},code=sm_${arch})
	    set(CUDA_ARCH_REAL "${CUDA_ARCH_REAL} ${arch}"  CACHE INTERNAL "")
	    set(CUDA_ARCH_FEATURES "${CUDA_ARCH_FEATURES} ${arch}"  CACHE INTERNAL "")
		endforeach()
		set(NVCC_FLAGS_EXTRA ${NVCC_FLAGS_EXTRA} -D_FORCE_INLINES)
		convert_PID_Libraries_Into_System_Links(CUDA_LIBRARIES CUDA_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(CUDA_CUDART_LIBRARY CUDA_LIBRARY_DIR)
	endif()

endif()#if NVCC not found no need to continue
