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

found_PID_Configuration(suitesparse FALSE)

if(UNIX)
  set(CMAKE_MODULE_PATH ${WORKSPACE_DIR}/configurations/suitesparse ${CMAKE_MODULE_PATH})
	find_package(SuiteSparse QUIET)

	if(NOT SuiteSparse_FOUND OR NOT SuiteSparse_LIBRARIES)
		unset(SuiteSparse_FOUND)
		return()
	endif()

	convert_PID_Libraries_Into_System_Links(SuiteSparse_LIBRARIES SuiteSparse_LINKS)#getting good system links (with -l)
	convert_PID_Libraries_Into_Library_Directories(SuiteSparse_LIBRARIES SuiteSparse_LIBRARY_DIRS)

  if(SuiteSparse_FOUND)
    found_PID_Configuration(suitesparse TRUE)
    unset(SuiteSparse_FOUND)
  endif()
endif ()
