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

found_PID_Configuration(openmp FALSE)

# FindOpenMP need to be use in a "non script" environment (try_compile function)
# so we create a separate project (test_openmp) to generate usefull vars
# and extract them in a file (openmp_config_vars.cmake)
# Then read this file in our context.


# execute separate project to extract datas
set(path_test_openmp ${WORKSPACE_DIR}/configurations/openmp/test_openmp/build)
execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${path_test_openmp} OUTPUT_QUIET)
file(WRITE ${path_test_openmp}/.gitignore "*\n")
execute_process(COMMAND ${CMAKE_COMMAND} .. WORKING_DIRECTORY ${path_test_openmp} OUTPUT_QUIET)

# Extract datas from openmpi_config_vars.cmake
set(path_openmp_config_vars ${path_test_openmp}/openmp_config_vars.cmake )
if(EXISTS ${path_openmp_config_vars} )
  include(${path_openmp_config_vars})
else()
  return()
endif()

if(OpenMP_FOUND)
	if(OpenMP_C_FOUND AND OpenMP_CXX_FOUND)
		list(APPEND OpenMP_LIB_NAMES ${OpenMP_C_LIB_NAMES} ${OpenMP_CXX_LIB_NAMES})
    if(OpenMP_LIB_NAMES)
	     list(REMOVE_DUPLICATES OpenMP_LIB_NAMES)
    endif()
		list(APPEND OpenMP_RPATH ${OpenMP_C_LIBRARIES} ${OpenMP_CXX_LIBRARIES})
    if(OpenMP_LIB_NAMES)
      list(REMOVE_DUPLICATES OpenMP_RPATH)
    endif()
		list(APPEND OpenMP_COMPILER_OPTIONS ${OpenMP_C_FLAGS} ${OpenMP_CXX_FLAGS})
    if(OpenMP_LIB_NAMES)
	     list(REMOVE_DUPLICATES OpenMP_COMPILER_OPTIONS)
    endif()
		convert_PID_Libraries_Into_System_Links(OpenMP_RPATH OpenMP_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(OpenMP_RPATH OpenMP_LIBDIRS)

		convert_PID_Libraries_Into_System_Links(OpenMP_C_LIBRARIES OpenMP_C_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(OpenMP_C_LIBRARIES OpenMP_C_LIBDIRS)

		convert_PID_Libraries_Into_System_Links(OpenMP_CXX_LIBRARIES OpenMP_CXX_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(OpenMP_CXX_LIBRARIES OpenMP_CXX_LIBDIRS)

		#Check OpenMP less version
		if(OpenMP_C_VERSION LESS_EQUAL OpenMP_CXX_VERSION)
			set(OpenMP_VERSION ${OpenMP_C_VERSION})
		else()
			set(OpenMP_VERSION ${OpenMP_CXX_VERSION})
		endif()


	elseif(OpenMP_C_FOUND AND NOT OpenMP_CXX_FOUND)
	# If only C is found
		set(OpenMP_LIB_NAMES ${OpenMP_C_LIB_NAMES})
		set(OpenMP_RPATH ${OpenMP_C_LIBRARIES})
		set(OpenMP_COMPILER_OPTIONS ${OpenMP_C_FLAGS})
		convert_PID_Libraries_Into_System_Links(OpenMP_C_LIBRARIES OpenMP_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(OpenMP_C_LIBRARIES OpenMP_LIBDIRS)
		set(OpenMP_VERSION ${OpenMP_C_FOUND})

		convert_PID_Libraries_Into_System_Links(OpenMP_C_LIBRARIES OpenMP_C_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(OpenMP_C_LIBRARIES OpenMP_C_LIBDIRS)

	elseif(NOT OpenMP_C_FOUND AND OpenMP_CXX_FOUND)
	# If only CXX is found
		set(OpenMP_LIB_NAMES ${OpenMP_CXX_LIB_NAMES})
		set(OpenMP_RPATH ${OpenMP_CXX_LIBRARIES})
		set(OpenMP_COMPILER_OPTIONS ${OpenMP_CXX_FLAGS})
		convert_PID_Libraries_Into_System_Links(OpenMP_CXX_LIBRARIES OpenMP_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(OpenMP_CXX_LIBRARIES OpenMP_LIBDIRS)
		set(OpenMP_VERSION ${OpenMP_CXX_FOUND})

		convert_PID_Libraries_Into_System_Links(OpenMP_CXX_LIBRARIES OpenMP_CXX_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(OpenMP_CXX_LIBRARIES OpenMP_CXX_LIBDIRS)

	else()
		message("[PID] ERROR : cannot find OpenMP library.")
		return()
	endif()

	found_PID_Configuration(openmp TRUE)
endif()
