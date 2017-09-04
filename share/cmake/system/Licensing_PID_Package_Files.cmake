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

include(${WORKSPACE_DIR}/pid/Workspace_Platforms_Info.cmake) #loading the current platform configuration


list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)
#getting the file that contains the license info into C code comment
set(CONFIG_FILE ${BINARY_DIR}/share/file_header_comment.txt.in)

file(GLOB_RECURSE all_libraries_sources ${SOURCE_DIR}/src/*.c ${SOURCE_DIR}/src/*.cpp ${SOURCE_DIR}/src/*.cxx ${SOURCE_DIR}/src/*.cc ${SOURCE_DIR}/src/*.h ${SOURCE_DIR}/src/*.hh ${SOURCE_DIR}/src/*.hpp ${SOURCE_DIR}/src/*.hx)
file(GLOB_RECURSE all_libraries_headers ${SOURCE_DIR}/include/*.h ${SOURCE_DIR}/include/*.hh ${SOURCE_DIR}/include/*.hpp ${SOURCE_DIR}/include/*.hxx)
file(GLOB_RECURSE all_apps_sources ${SOURCE_DIR}/apps/*.c ${SOURCE_DIR}/apps/*.cc ${SOURCE_DIR}/apps/*.cpp ${SOURCE_DIR}/apps/*.cxx ${SOURCE_DIR}/apps/*.h ${SOURCE_DIR}/apps/*.hh ${SOURCE_DIR}/apps/*.hpp ${SOURCE_DIR}/apps/*.hx)
list(APPEND all_files ${all_libraries_sources} ${all_libraries_headers} ${all_apps_sources})


foreach(a_file IN ITEMS ${all_files})
	#generate the header comment for the current file
	get_filename_component(file_name ${a_file} NAME)
	set(PROJECT_FILENAME ${file_name})
	file(READ ${CONFIG_FILE} raw_header)
	string(CONFIGURE ${raw_header} configured_header @ONLY)

	#getting appropriate corresponding characters in the source file
	string(LENGTH "${configured_header}" header_size)
	file(READ ${a_file} beginning_of_file LIMIT ${header_size})
	# comparing header of the source with configured header
	if(NOT "${beginning_of_file}" STREQUAL "${configured_header}")#headers are not matching !!
		#header comment must be updated or created
		string(LENGTH "/* 	File: ${PROJECT_FILENAME}" beginning_of_header_size)
		math(EXPR beginning_of_header_size "${beginning_of_header_size}+1")
		file(READ ${a_file} first_line_of_file LIMIT ${beginning_of_header_size})#getting as many characters as counted previously
		file(READ ${a_file} full_content)#getting the whole filecontent
		string(REPLACE "." "\\." MATCHABLE_FILENAME " ${PROJECT_FILENAME}")
		set(COMPARISON_PATTERN "/*File:${PROJECT_FILENAME}")
		string(REGEX REPLACE "^[ \t\n]*/\\*[ \t\n]*File:[ \t\n]+${MATCHABLE_FILENAME}[ \t\n]*$" "${COMPARISON_PATTERN}" FORMATTED ${first_line_of_file})
		if(NOT  FORMATTED STREQUAL COMPARISON_PATTERN) #the file already has a license comment
			#this comment must be suppressed first
			string(FIND "${full_content}" "*/" position_of_first_comment_ending)#getting the size of the license comment
			math(EXPR thelength "${position_of_first_comment_ending}+2")
			string(SUBSTRING "${full_content}" ${thelength} -1 res_file_content)#remove this first license comment
			set(full_content ${res_file_content})#now only code and user defined header comments (e.g. for doxygen) are part of the new file content
			message("[PID] INFO : replacing license header of file ${a_file}.")
		else()
			message("[PID] INFO : adding license header to file ${a_file}.")
		endif()

		# now adding the newly created header to the file
		set(RES "${configured_header}")
		set(RES "${RES}${full_content}")
		file(WRITE ${a_file} "${RES}")
	else()
		message("[PID] INFO : file ${a_file} ALREADY contains a license header.")
	endif()

endforeach()
