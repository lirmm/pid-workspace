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


list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
load_Workspace_Info() #loading the current platform configuration

#getting the file that contains the license info into C code comment
set(CONFIG_FILE ${BINARY_DIR}/share/file_header_comment.txt.in)

file(GLOB_RECURSE all_libraries_sources ${SOURCE_DIR}/src/*.c ${SOURCE_DIR}/src/*.cpp ${SOURCE_DIR}/src/*.cxx ${SOURCE_DIR}/src/*.cc ${SOURCE_DIR}/src/*.h ${SOURCE_DIR}/src/*.hh ${SOURCE_DIR}/src/*.hpp ${SOURCE_DIR}/src/*.hxx)
file(GLOB_RECURSE all_libraries_headers ${SOURCE_DIR}/include/*.h ${SOURCE_DIR}/include/*.hh ${SOURCE_DIR}/include/*.hpp ${SOURCE_DIR}/include/*.hxx)
file(GLOB_RECURSE all_apps_sources ${SOURCE_DIR}/apps/*.c ${SOURCE_DIR}/apps/*.cc ${SOURCE_DIR}/apps/*.cpp ${SOURCE_DIR}/apps/*.cxx ${SOURCE_DIR}/apps/*.h ${SOURCE_DIR}/apps/*.hh ${SOURCE_DIR}/apps/*.hpp ${SOURCE_DIR}/apps/*.hxx)
list(APPEND all_files ${all_libraries_sources} ${all_libraries_headers} ${all_apps_sources})

foreach(a_file IN LISTS all_files)
	#generate the header comment for the current file
	get_filename_component(file_name ${a_file} NAME)
	set(PROJECT_FILENAME ${file_name})
	file(READ ${CONFIG_FILE} raw_header)
	string(CONFIGURE ${raw_header} configured_header @ONLY)# raw_header contains the header corresponding to the license, configured with project information

	#getting appropriate corresponding characters in the source file
	string(LENGTH "${configured_header}" header_size)

	#formatting the full content by removing first empty lines
	file(READ ${a_file} full_content)#getting the whole file content
	string(REGEX REPLACE "^[ \t\n]*([^ \t\n].*)$" "\\1" input_text "${full_content}")#using guillemet to avoid semicolon removal (string interpretation)

	# comparing header of the source with configured header
	string(SUBSTRING "${input_text}" 0 ${header_size} beginning_of_file)#getting as many characters as counted previously
	if(NOT "${beginning_of_file}" STREQUAL "${configured_header}")#headers are not matching !!
		#=> header comment must be either updated or created
		string(FIND "${beginning_of_file}" "\n" INDEX)
		string(SUBSTRING "${beginning_of_file}" 0 ${INDEX} first_line_of_file)
		string(LENGTH "${first_line_of_file}" first_header_line_size)
		math(EXPR first_header_line_size "${first_header_line_size}+1")

		string(REPLACE "." "\\." MATCHABLE_FILENAME "${PROJECT_FILENAME}")#create the regex pattern from file name
		set(COMPARISON_PATTERN "/*File:${PROJECT_FILENAME}") # creating the formatted string used for coparison of headers
		string(REGEX REPLACE "^[ \t\n]*/\\*[ \t\n]*File:[ \t\n]+${MATCHABLE_FILENAME}[ \t\n]*$" "${COMPARISON_PATTERN}" FORMATTED ${first_line_of_file})
		if(	NOT FORMATTED STREQUAL first_line_of_file #there is a match (=> first line does not match a valid mattern)
				AND FORMATTED STREQUAL COMPARISON_PATTERN) #the file already has a license comment
			#this comment must be suppressed first
			string(FIND "${input_text}" "*/" position_of_first_comment_ending)#getting the size of the license comment
			math(EXPR thelength "${position_of_first_comment_ending}+3")#+3 for : * and / characters followed by a \n
			string(SUBSTRING "${input_text}" ${thelength} -1 res_file_content)#remove this first license comment
			set(input_text "${res_file_content}")#now only code and user defined header comments (e.g. for doxygen) are part of the new file content
			message("[PID] INFO : replacing license header of file ${a_file}.")
		else()
			message("[PID] INFO : adding license header to file ${a_file}.")
		endif()

		# now adding the newly created header to the file (without first blank lines)
		file(WRITE ${a_file} "${configured_header}${input_text}")
	else()
		message("[PID] INFO : file ${a_file} ALREADY contains a license header.")
	endif()

endforeach()
