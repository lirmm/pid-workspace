list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)
#getting the file that contains the license info into C code comment
set(CONFIG_FILE ${BINARY_DIR}/share/file_header_comment.txt.in)

file(GLOB_RECURSE all_libraries_sources ${SOURCE_DIR}/src/*.c ${SOURCE_DIR}/src/*.cpp ${SOURCE_DIR}/src/*.cxx ${SOURCE_DIR}/src/*.cc)
file(GLOB_RECURSE all_libraries_headers ${SOURCE_DIR}/include/*.h ${SOURCE_DIR}/include/*.hh ${SOURCE_DIR}/include/*.hpp ${SOURCE_DIR}/include/*.hxx)
file(GLOB_RECURSE all_apps_sources ${SOURCE_DIR}/apps/*.c ${SOURCE_DIR}/apps/*.cc ${SOURCE_DIR}/apps/*.cpp ${SOURCE_DIR}/apps/*.cxx)
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
		file(READ ${a_file} first_line_of_file LIMIT ${beginning_of_header_size})		
		file(READ ${a_file} full_content)
		if("${first_line_of_file}" STREQUAL "/* 	File: ${PROJECT_FILENAME}\n") #the file already has a license comment
			#this comment must be suppressed first
			string(FIND "${full_content}" "*/" position_of_first_comment_ending)
			math(EXPR thelength "${position_of_first_comment_ending}+2")
			string(SUBSTRING "${full_content}" ${thelength} -1 res_file_content)
			set(full_content ${res_file_content})#now only code and user defined header comments (e.g. for doxygen) are part of the new file content  
			#message("RESULT = ${full_content}")
		endif()
		
		# now adding the newly created header to the file
		set(RES "${configured_header}")
		set(RES "${RES}${full_content}")
		message("new content for ${a_file} :\n${RES}")	
		file(WRITE ${a_file} "${RES}")
	else()
		message("file ${a_file} ALREADY contains a license header")	
	endif()
		
endforeach()


