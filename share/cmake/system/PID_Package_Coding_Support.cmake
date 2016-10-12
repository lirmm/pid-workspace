#########################################################################################
#	This file is part of the program PID						#
#  	Program description : build system supportting the PID methodology  		#
#  	Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique 	#
#	et de Microelectronique de Montpellier). All Right reserved.			#
#											#
#	This software is free software: you can redistribute it and/or modify		#
#	it under the terms of the CeCILL-C license as published by			#
#	the CEA CNRS INRIA, either version 1						#
#	of the License, or (at your option) any later version.				#
#	This software is distributed in the hope that it will be useful,		#
#	but WITHOUT ANY WARRANTY; without even the implied warranty of			#
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the			#
#	CeCILL-C License for more details.						#
#											#
#	You can find the complete license description on the official website 		#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################



### generating test coverage reports for the package
function(generate_Coverage)

if(${CMAKE_BUILD_TYPE} MATCHES Debug) # coverage is well generated in debug mode

	if(NOT BUILD_COVERAGE_REPORT)
		return()
	endif()

	find_program( GCOV_PATH gcov ) # for generating coverage traces
	find_program( LCOV_PATH lcov ) # for generating HTML coverage reports
	find_program( GENHTML_PATH genhtml ) #for generating HTML
	mark_as_advanced(GCOV_PATH LCOV_PATH GENHTML_PATH)

	if(NOT GCOV_PATH)
		message("[PID] WARNING : gcov not found please install it to generate coverage reports.")
	endif()

	if(NOT LCOV_PATH)
		message("[PID] WARNING : lcov not found please install it to generate coverage reports.")
	endif()

	if(NOT GENHTML_PATH)
		message("[PID] WARNING : genhtml not found please install it to generate coverage reports.")
	endif()

	if(NOT GCOV_PATH OR NOT LCOV_PATH OR NOT GENHTML_PATH)
		set(BUILD_COVERAGE_REPORT OFF FORCE)
	endif()

	# CHECK VALID COMPILER
	if("${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
		if("${CMAKE_CXX_COMPILER_VERSION}" VERSION_LESS 3)
			message("[PID] WARNING : Clang version must be 3.0.0 or greater to generate coverage reports")
			set(BUILD_COVERAGE_REPORT OFF FORCE)
		endif()
	elseif(NOT CMAKE_COMPILER_IS_GNUCXX)
		message("[PID] WARNING : not a gnu C/C++ compiler, impossible to generate coverage reports.")
		set(BUILD_COVERAGE_REPORT OFF FORCE)
	endif() 
endif()

if(BUILD_COVERAGE_REPORT)
	
	set(CMAKE_CXX_FLAGS_DEBUG  "-g -O0 --coverage -fprofile-arcs -ftest-coverage" CACHE STRING "Flags used by the C++ compiler during coverage builds." FORCE)
	set(CMAKE_C_FLAGS_DEBUG  "-g -O0 --coverage -fprofile-arcs -ftest-coverage" CACHE STRING "Flags used by the C compiler during coverage builds." FORCE)
	set(CMAKE_EXE_LINKER_FLAGS_DEBUG "--coverage" CACHE STRING "Flags used for linking binaries during coverage builds." FORCE)
	set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "--coverage" CACHE STRING "Flags used by the shared libraries linker during coverage builds."  FORCE)
	mark_as_advanced(CMAKE_CXX_FLAGS_DEBUG CMAKE_C_FLAGS_DEBUG CMAKE_EXE_LINKER_FLAGS_DEBUG CMAKE_SHARED_LINKER_FLAGS_DEBUG)


	if(${CMAKE_BUILD_TYPE} MATCHES Debug)
	
		set(coverage_info "${CMAKE_BINARY_DIR}/lcovoutput.info")
		set(coverage_cleaned "${CMAKE_BINARY_DIR}/lcovoutput.cleaned")
		set(coverage_dir "${CMAKE_BINARY_DIR}/lcovoutput")
	
		# Setup coverage target
		add_custom_target(coverage
                  
			COMMAND ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --zerocounters #prepare coverage generation
			
			COMMAND ${CMAKE_MAKE_PROGRAM} test # Run tests

			COMMAND ${LCOV_PATH} --directory ${CMAKE_BINARY_DIR} --capture --output-file ${coverage_info}
			COMMAND ${LCOV_PATH} --remove ${coverage_info} 'test/*' '/usr/*' 'external/*' 'install/*' --output-file ${coverage_cleaned} #configure the filter of output (remove everything that is not related to
			COMMAND ${GENHTML_PATH} -o ${coverage_dir} ${coverage_cleaned} #generating output
			COMMAND ${CMAKE_COMMAND} -E remove ${coverage_info} ${coverage_cleaned} #cleanup lcov files

			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
			COMMENT "Generating code coverage report."
		)

	endif()
else() #no coverage wanted or possible
	set(CMAKE_CXX_FLAGS_DEBUG  "-g" CACHE STRING "Flags used by the C++ compiler during coverage builds." FORCE)
	set(CMAKE_C_FLAGS_DEBUG  "-g" CACHE STRING "Flags used by the C compiler during coverage builds." FORCE)
	set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE STRING "Flags used for linking binaries during coverage builds." FORCE)
	set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "" CACHE STRING "Flags used by the shared libraries linker during coverage builds."  FORCE)
	mark_as_advanced(CMAKE_CXX_FLAGS_DEBUG CMAKE_C_FLAGS_DEBUG CMAKE_EXE_LINKER_FLAGS_DEBUG CMAKE_SHARED_LINKER_FLAGS_DEBUG)

endif()
endfunction(generate_Coverage)


