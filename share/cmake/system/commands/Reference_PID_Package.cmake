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

message("[PID] Registering references of package ${REQUIRED_PACKAGE} into the worskpace ... ")
if(EXISTS ${BINARY_DIR}/share/Refer${REQUIRED_PACKAGE}.cmake)
  file( COPY ${BINARY_DIR}/share/Refer${REQUIRED_PACKAGE}.cmake
        DESTINATION ${WORKSPACE_DIR}/share/cmake/references)
else()
  message("[PID] WARNING: NO reference file found for package ${REQUIRED_PACKAGE}. This can be due to a missing official git remote for the package. Please set the address of the package's official remote within root CMakeLists.txt of ${REQUIRED_PACKAGE}.")
endif()

if(EXISTS ${BINARY_DIR}/share/Find${REQUIRED_PACKAGE}.cmake)
  file( COPY ${BINARY_DIR}/share/Find${REQUIRED_PACKAGE}.cmake
        DESTINATION ${WORKSPACE_DIR}/share/cmake/find)
else()
  message(FATAL_ERROR "[PID] BUG: NO find file found for package ${REQUIRED_PACKAGE}. This is a BUG in PID please contact PID developpers.")
endif()

message("[PID] package ${REQUIRED_PACKAGE} has been registered.")
