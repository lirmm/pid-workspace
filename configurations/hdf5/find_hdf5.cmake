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

found_PID_Configuration(hdf5 FALSE)

# FindHDF5 need to be use in a "non script" environment (try_compile function)
# so we create a separate project (test_hdf5) to generate usefull vars
# and extract them in a file (hdf5_config_vars.cmake)
# Then read this file in our context.

# execute separate project to extract datas
set(path_test_hdf5 ${WORKSPACE_DIR}/configurations/hdf5/test_hdf5/build)
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${path_test_hdf5}
								WORKING_DIRECTORY  ${WORKSPACE_DIR}/pid OUTPUT_QUIET)
file(WRITE ${path_test_hdf5}/.gitignore "*\n")
execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR}/configurations/hdf5/test_hdf5/
								WORKING_DIRECTORY ${path_test_hdf5} OUTPUT_QUIET)

# Extract datas from hdf5i_config_vars.cmake
set(path_hdf5_config_vars ${path_test_hdf5}/hdf5_config_vars.cmake )
if(EXISTS ${path_hdf5_config_vars} )
  include(${path_hdf5_config_vars})
else()
  return()
endif()

if(HDF5_FOUND)

	list(APPEND OpenMP_COMPILER_OPTIONS ${OpenMP_C_FLAGS} ${OpenMP_CXX_FLAGS})
  if(OpenMP_COMPILER_OPTIONS)
     list(REMOVE_DUPLICATES OpenMP_COMPILER_OPTIONS)
  endif()
	convert_PID_Libraries_Into_System_Links(HDF5_LIBRARIES HDF5_LINKS)#getting good system links (with -l)
	convert_PID_Libraries_Into_Library_Directories(HDF5_LIBRARIES HDF5_LIBDIRS)

	found_PID_Configuration(hdf5 TRUE)
endif()
