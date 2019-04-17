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
if(NOT CUDA_VERSION OR NOT CMAKE_CUDA_COMPILER)#if the CUDA version is known and a nvcc compiler has been defined
	return()#if NVCC not found no need to continue
endif()

if(cuda_version)# a version constraint is defined (if code works only with a given version)
	if(NOT cuda_version VERSION_EQUAL CUDA_VERSION) #required VS provided CUDA versions DO NOT match !
		return()
	endif()
endif()

#there is one or more target architecture(s) defined
set(list_of_arch)# we put all those architectures inside this variable
string(REPLACE " " ";" all_flags "${CMAKE_CUDA_FLAGS}")
foreach(flag IN LISTS all_flags)#checking that architecture is supported
	if(flag MATCHES "arch=compute_([^,]+),code=sm_(.+)"
		AND ("${CMAKE_MATCH_1}" STREQUAL "${CMAKE_MATCH_2}"))
		list(APPEND list_of_arch ${CMAKE_MATCH_1})
	endif()
endforeach()

if(cuda_architecture) # a constraint on architecture version is defined (if some deatures work for only a restricted set of architectures)
	string(REPLACE "." "" ARCH_LIST "${cuda_architecture}")
	foreach(arch IN LISTS ARCH_LIST)#for each arch that is checked
		list(FIND list_of_arch ${arch} INDEX)
		if(INDEX EQUAL -1)#check if the target arch is a used arch for NVCC compiler
			return()
		endif()
	endforeach()
endif()

found_PID_Configuration(cuda TRUE)
set(CUDA_ARCH_REAL)# CUDA sm architecture
set(CUDA_ARCH_FEATURES)# CUDA compute architecture

# Tell NVCC to add binaries for the specified GPUs
foreach(arch IN LISTS list_of_arch)
	list(APPEND CUDA_ARCH_REAL "${arch}")
	list(APPEND CUDA_ARCH_FEATURES "${arch}")
endforeach()

convert_PID_Libraries_Into_System_Links(CUDA_LIBRARIES CUDA_LINKS)#getting good system links (with -l)
convert_PID_Libraries_Into_Library_Directories(CUDA_CUDART_LIBRARY CUDA_LIBRARY_DIR)
set(NVCC_FLAGS_EXTRA ${CMAKE_CUDA_FLAGS})
