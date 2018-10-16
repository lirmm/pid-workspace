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

#using a modified version of find cuda to make it usable into a script
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/configurations/cuda) # using generic scripts/modules of the workspace
find_package(CUDA)

if(CUDA_FOUND)
	set(cuda_FOUND TRUE CACHE INTERNAL "")
	set(cuda_LIBRARIES -lcudart-static -lrt -lpthread -ldl)
	set(cuda_EXE ${CUDA_NVCC_EXECUTABLE})
	set(cuda_TOOLKIT ${CUDA_TOOLKIT_TARGET_DIR})
	set(cuda_INCS ${CUDA_INCLUDE_DIRS})#everything should be in standard system path so no need to specify include dirs
	unset(CUDA_LIBRARIES CACHE)
	unset(CUDA_INCLUDE_DIRS CACHE)
endif()
