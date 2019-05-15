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
PID_Configuration_Variables(openmp
				VARIABLES VERSION  				COMPILER_OPTIONS				LIBRARY_DIRS		RPATH					LINK_OPTIONS	LIB_NAMES					GOMP_LIBRARY					PTHREAD_LIBRARY				C_COMPILER_OPTIONS	C_RPATH							C_LINK_OPTIONS	C_LIBRARY_DIRS		C_LIB_NAMES					CXX_COMPILER_OPTIONS	CXX_RPATH							CXX_LINK_OPTIONS	CXX_LIBRARY_DIRS		CXX_LIB_NAMES
				VALUES 		OpenMP_VERSION  OpenMP_COMPILER_OPTIONS	OpenMP_LIBDIRS 	OpenMP_RPATH 	OpenMP_LINKS	OpenMP_LIB_NAMES  OpenMP_GOMP_LIBRARY		OpenMP_PTHREAD_LIBRARY	OpenMP_C_FLAGS			OpenMP_C_LIBRARIES	OpenMP_C_LINKS	OpenMP_C_LIBDIRS	OpenMP_C_LIB_NAMES	OpenMP_CXX_FLAGS			OpenMP_CXX_LIBRARIES	OpenMP_CXX_LINKS	OpenMP_CXX_LIBDIRS	OpenMP_CXX_LIB_NAMES	)



# constraints
PID_Configuration_Constraints(openmp		IN_BINARY version
																				VALUE			OpenMP_VERSION)
