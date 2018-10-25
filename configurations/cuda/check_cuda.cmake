#########################################################################################
#       This file is part of the program PID                                            #
#       Program description : build system supporting the PID methodology              	#
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

if(NOT cuda_FOUND)
	set(cuda_TOOLKIT_PATH CACHE INTERNAL "")
	set(cuda_INCLUDE_DIRS CACHE INTERNAL "")
	set(cuda_LINK_OPTIONS CACHE INTERNAL "")
	set(cuda_EXECUTABLE_PATH CACHE INTERNAL "")
	set(cuda_VERSION CACHE INTERNAL "")
	include(${WORKSPACE_DIR}/configurations/cuda/find_cuda.cmake)
	if(cuda_FOUND)
		set(all_links)
		foreach(lib IN LISTS cuda_LIBRARIES)
			convert_Library_Path_To_Default_System_Library_Link(res_link ${lib})
			list(APPEND all_links ${res_link})
		endforeach()
		set(cuda_LINK_OPTIONS ${all_links} CACHE INTERNAL "")
		set(cuda_INCLUDE_DIRS ${cuda_INCS} CACHE INTERNAL "")
		set(cuda_EXECUTABLE_PATH ${cuda_EXE} CACHE INTERNAL "")
		set(cuda_TOOLKIT_PATH ${cuda_TOOLKIT} CACHE INTERNAL "")
		set(cuda_VERSION ${CUDA_VERSION_STRING} CACHE INTERNAL "")
		set(CHECK_cuda_RESULT TRUE)
	else()
		set(CHECK_cuda_RESULT FALSE)
	endif()
else()
	set(CHECK_cuda_RESULT TRUE)
endif()
