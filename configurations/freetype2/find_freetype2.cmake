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

found_PID_Configuration(freetype2 FALSE)

# - Find freetype2 installation
# Try to find libraries for freetype2 on UNIX systems. The following values are defined
#  freetype2_FOUND        - True if freetype2 is available
#  freetype2_LIBRARIES    - link against these to use freetype2 library
if (UNIX)

	# execute separate project to extract datas
	set(path_test_freetype ${WORKSPACE_DIR}/configurations/freetype2/test_freetype/build/${CURRENT_PLATFORM})
	set(path_freetype_config_vars ${path_test_freetype}/freetype_config_vars.cmake )

	if(EXISTS ${path_freetype_config_vars})#file already computed
		include(${path_freetype_config_vars}) #just to check that same version is required
		if(FREETYPE_FOUND)#optimization only possible if freetype has been found
			if(NOT freetype2_version #no specific version to search for
				OR freetype2_version VERSION_EQUAL FREETYPE_VERSION)# or same version required and already found no need to regenerate

				find_PID_Library_In_Linker_Order("${FREETYPE_LIBRARIES}" ALL FREETYPE_LIB FREETYPE_SONAME)
				convert_PID_Libraries_Into_System_Links(FREETYPE_LIBRARIES freetype2_LINKS)#getting good system links (with -l)
				convert_PID_Libraries_Into_Library_Directories(FREETYPE_LIBRARIES freetype2_LIBDIR)
				found_PID_Configuration(freetype2 TRUE)
				return()#exit without regenerating (avoid regenerating between debug and release builds due to generated file timestamp change)
				#also an optimization avoid launching again and again boost config for each package build in debug and release modes (which is widely used)
			endif()
		endif()
	endif()

	if(NOT EXISTS ${path_test_freetype})
		file(MAKE_DIRECTORY ${path_test_freetype})
	endif()

	message("[PID] INFO : performing tests for freetype ...")
	execute_process(COMMAND ${CMAKE_COMMAND} ${WORKSPACE_DIR}/configurations/freetype2/test_freetype
	                WORKING_DIRECTORY ${path_test_freetype} OUTPUT_QUIET)

	# Extract datas from freetypei_config_vars.cmake
	if(EXISTS ${path_freetype_config_vars} )
	  include(${path_freetype_config_vars})
	else()
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] WARNING : cannot execute tests for freetype !")
		endif()
	  return()
	endif()

	if(FREETYPE_FOUND)#optimization only possible if freetype has been found
		if(NOT freetype2_version #no specific version to search for
			OR freetype2_version VERSION_EQUAL FREETYPE_VERSION)# or same version required and already found no need to regenerate
			find_PID_Library_In_Linker_Order("${FREETYPE_LIBRARIES}" ALL FREETYPE_LIB FREETYPE_SONAME)
			convert_PID_Libraries_Into_System_Links(FREETYPE_LIBRARIES freetype2_LINKS)#getting good system links (with -l)
			convert_PID_Libraries_Into_Library_Directories(FREETYPE_LIBRARIES freetype2_LIBDIR)
			found_PID_Configuration(freetype2 TRUE)
			return()#exit without regenerating (avoid regenerating between debug and release builds due to generated file timestamp change)
			#also an optimization avoid launching again and again boost config for each package build in debug and release modes (which is widely used)
		endif()
	endif()
endif ()
