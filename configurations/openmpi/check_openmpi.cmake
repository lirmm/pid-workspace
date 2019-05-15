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

# returned variables
PID_Configuration_Variables(openmpi
	VARIABLES	VERSION				VERSION_MPI		COMPILER			COMPILER_OPTIONS		INLCUDE_DIRS			LINK_OPTIONS		RPATH					LIBRARY_DIRS			C_COMPILER			C_COMPILER_OPTION			C_INCLUDE_DIR				C_RPATH						C_LINK_OPTIONS		CXX_COMPILER			CXX_COMPILER_OPTION			CXX_INCLUDE_DIR				CXX_RPATH						CXX_LINK_OPTIONS		EXECUTABLE					EXEC_NUMPROCS 				EXEC_NUMPROCS_FLAG 		EXEC_POST_FLAGS 	EXEC_PRE_FLAGS
	VALUES		OMPI_VERSION	MPI_VERSION 	MPI_COMPILER	MPI_COMPILE_FLAGS		MPI_INCLUDE_DIRS	MPI_LINK_FLAGS	MPI_LIBRARIES	MPI_LIBRARY_DIRS	MPI_C_COMPILER	MPI_C_COMPILE_FLAGS		MPI_C_INCLUDE_DIRS	MPI_C_LIBRARIES		MPI_C_LINKS				MPI_CXX_COMPILER	MPI_CXX_COMPILE_FLAGS		MPI_CXX_INCLUDE_DIRS	MPI_CXX_LIBRARIES		MPI_CXX_LINKS				MPIEXEC_EXECUTABLE	MPIEXEC_MAX_NUMPROCS	MPIEXEC_NUMPROC_FLAG	MPIEXEC_POSTFLAGS	MPIEXEC_PREFLAGS	)




# constraints
PID_Configuration_Constraints(openmpi		IN_BINARY version
																				VALUE			OMPI_VERSION)
