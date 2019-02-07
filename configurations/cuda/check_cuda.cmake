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

include(Configuration_Definition NO_POLICY_SCOPE)

# returned variables
PID_Configuration_Variables(cuda
				VARIABLES VERSION				LINK_OPTIONS 	INCLUDE_DIRS 			LIBRARY_DIRS  		COMPILER_OPTIONS	RPATH 					REAL_ARCHITECTURE 	VIRTUAL_ARCHITECTURE	TOOLKIT_PATH
				VALUES 		CUDA_VERSION	CUDA_LINKS 		CUDA_INCLUDE_DIRS CUDA_LIBRARY_DIR	NVCC_FLAGS_EXTRA  CUDA_LIBRARIES	CUDA_ARCH_REAL 			CUDA_ARCH_PTX					CUDA_TOOLKIT_TARGET_DIR)

# constraints (no required constraints)
PID_Configuration_Constraints(cuda OPTIONAL version
																	IN_BINARY architecture VALUE CUDA_ARCH)
