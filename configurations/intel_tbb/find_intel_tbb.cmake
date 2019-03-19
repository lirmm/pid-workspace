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

found_PID_Configuration(intel_tbb FALSE)

# - Find tbb installation
# Try to find libraries for intel_tbb on UNIX systems. The following values are defined
#  intel_tbb_FOUND        - True if intel_mkl is available
if (UNIX)
  set(CMAKE_MODULE_PATH ${WORKSPACE_DIR}/configurations/intel_tbb ${CMAKE_MODULE_PATH})
	find_package(TBB QUIET)

	if(NOT TBB_FOUND OR NOT TBB_LIBRARIES) #OR NOT TBB_LIBRARY) # check failed
		unset(TBB_FOUND)
		return()
	endif()

	convert_PID_Libraries_Into_System_Links(TBB_LIBRARIES TBB_LINKS)#getting good system links (with -l)
	convert_PID_Libraries_Into_Library_Directories(TBB_LIBRARIES TBB_LIBRARY_DIRS)

  if(TBB_FOUND)
    found_PID_Configuration(intel_tbb TRUE)
    unset(TBB_FOUND)
  endif()
endif ()
