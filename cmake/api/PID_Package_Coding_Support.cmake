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

##########################################################################################
############################ Guard for optimization of configuration process #############
##########################################################################################
if(PID_PACKAGE_CODING_SUPPORT_INCLUDED)
  return()
endif()
set(PID_PACKAGE_CODING_SUPPORT_INCLUDED TRUE)
##########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Coverage| replace:: ``generate_Coverage``
#  .. _generate_Coverage:
#
#  generate_Coverage
#  -----------------
#
#   .. command:: generate_Coverage()
#
#   Generate test coverage reports for the currently defined package. This function create the "coverage" target that launch tests and generate the coverage report.
#
function(generate_Coverage)

if(CMAKE_BUILD_TYPE MATCHES Debug) # coverage is well generated in debug mode only

	if(NOT BUILD_COVERAGE_REPORT)#no coverage wanted => exit
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
		message("[PID] WARNING : generation of coverage reports has been deactivated.")
		set(BUILD_COVERAGE_REPORT  OFF CACHE BOOL "" FORCE)
	endif()

	# CHECK VALID COMPILER
	if("${CMAKE_CXX_COMPILER_ID}" MATCHES "(Apple)?[Cc]lang")
		if("${CMAKE_CXX_COMPILER_VERSION}" VERSION_LESS 3)
			message("[PID] WARNING : Clang version must be 3.0.0 or greater to generate coverage reports")
			set(BUILD_COVERAGE_REPORT  OFF CACHE BOOL "" FORCE)
		endif()
	elseif(NOT CMAKE_COMPILER_IS_GNUCXX)
		message("[PID] WARNING : not a gnu C/C++ compiler, impossible to generate coverage reports.")
		set(BUILD_COVERAGE_REPORT OFF CACHE BOOL "" FORCE)
	endif()
endif()

if(BUILD_COVERAGE_REPORT AND PROJECT_RUN_TESTS)

	set(CMAKE_CXX_FLAGS_DEBUG  "-g -O0 --coverage -fprofile-arcs -ftest-coverage" CACHE STRING "Flags used by the C++ compiler during coverage builds." FORCE)
	set(CMAKE_C_FLAGS_DEBUG  "-g -O0 --coverage -fprofile-arcs -ftest-coverage" CACHE STRING "Flags used by the C compiler during coverage builds." FORCE)
	set(CMAKE_EXE_LINKER_FLAGS_DEBUG "--coverage" CACHE STRING "Flags used for linking binaries during coverage builds." FORCE)
	set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "--coverage" CACHE STRING "Flags used by the shared libraries linker during coverage builds."  FORCE)
	mark_as_advanced(CMAKE_CXX_FLAGS_DEBUG CMAKE_C_FLAGS_DEBUG CMAKE_EXE_LINKER_FLAGS_DEBUG CMAKE_SHARED_LINKER_FLAGS_DEBUG)

	if(CMAKE_BUILD_TYPE MATCHES Debug)

		set(coverage_info "${CMAKE_BINARY_DIR}/lcovoutput.info")
		set(coverage_cleaned "${CMAKE_BINARY_DIR}/${PROJECT_NAME}_coverage")
		set(coverage_dir "${CMAKE_BINARY_DIR}/share/coverage_report")

    message("[PID] INFO : Allowing coverage checks ...")
		# Setup coverage target
		add_custom_target(coverage

			COMMAND ${LCOV_PATH} --base-directory ${CMAKE_SOURCE_DIR} --directory ${CMAKE_BINARY_DIR} --zerocounters #prepare coverage generation
			COMMAND ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG} # Run tests

			COMMAND ${LCOV_PATH} --base-directory ${CMAKE_SOURCE_DIR} --directory ${CMAKE_BINARY_DIR} --capture --output-file ${coverage_info}
			COMMAND ${LCOV_PATH} --remove ${coverage_info} 'test/*' '/usr/*' 'external/*' 'install/*' --output-file ${coverage_cleaned} #configure the filter of output (remove everything that is not related to
			COMMAND ${GENHTML_PATH} -o ${coverage_dir} ${coverage_cleaned} #generating output
			COMMAND ${CMAKE_COMMAND} -E remove ${coverage_info} ${coverage_cleaned} #cleanup lcov files

			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
			COMMENT "Generating code coverage report."
		)
		### installing coverage report ###
		install(DIRECTORY ${coverage_dir} DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})
	endif()

else() #no coverage wanted or possible (no test defined), create a do nothing rule for coverage
	if(BUILD_COVERAGE_REPORT AND CMAKE_BUILD_TYPE MATCHES Debug) #create a do nothing target when no run is possible on coverage
		add_custom_target(coverage
			COMMAND ${CMAKE_COMMAND} -E echo "[PID] WARNING : no coverage to perform !!"
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		)
    #reset compilation flags to default value
    set(CMAKE_CXX_FLAGS_DEBUG  "-g" CACHE STRING "Flags used by the C++ compiler during coverage builds." FORCE)
    set(CMAKE_C_FLAGS_DEBUG  "-g" CACHE STRING "Flags used by the C compiler during coverage builds." FORCE)
    set(CMAKE_EXE_LINKER_FLAGS_DEBUG "" CACHE STRING "Flags used for linking binaries during coverage builds." FORCE)
    set(CMAKE_SHARED_LINKER_FLAGS_DEBUG "" CACHE STRING "Flags used by the shared libraries linker during coverage builds."  FORCE)
    mark_as_advanced(CMAKE_CXX_FLAGS_DEBUG CMAKE_C_FLAGS_DEBUG CMAKE_EXE_LINKER_FLAGS_DEBUG CMAKE_SHARED_LINKER_FLAGS_DEBUG)
	endif()
endif()
endfunction(generate_Coverage)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Static_Check| replace:: ``add_Static_Check``
#  .. _add_Static_Check:
#
#  add_Static_Check
#  ----------------
#
#   .. command:: add_Static_Check(component is_library)
#
#   Add a specific static check target for a component of the currenlty defined package. This target launches a static code check (based on cppcheck) for that component that is added to the test target.
#
#     :component: the name of target component to check.
#
#     :is_library: if TRUE the component is a library.
#
function(add_Static_Check component is_library)

	if(NOT TARGET ${component})
    finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR: unknown target name ${component} when trying to cppcheck !")
	endif()

  # getting include automatically search by the compiler => this allow also to be robust to cross compilation requests
  set(CPP_CHECK_SETTING_EXPR)

  set(SYSTEM_INCLUDES ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES} ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
  get_Join_Generator_Expression(CPP_CHECK_SETTING_EXPR "${SYSTEM_INCLUDES}" "-I")

  if(${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
		#header targets have no sources => list them by hand
		set(SOURCES_TO_CHECK)
		foreach(source IN LISTS ${PROJECT_NAME}_${component}_HEADERS)
			list(APPEND SOURCES_TO_CHECK ${CMAKE_SOURCE_DIR}/include/${${PROJECT_NAME}_${component}_HEADER_DIR_NAME}/${source})
		endforeach()
	else()
		#getting sources of the target
		get_target_property(SOURCES_TO_CHECK ${component} SOURCES)
    append_Join_Generator_Expressions(CPP_CHECK_SETTING_EXPR "$<$<BOOL:$<TARGET_PROPERTY:${component},INCLUDE_DIRECTORIES>>:-I$<JOIN:$<TARGET_PROPERTY:${component},INCLUDE_DIRECTORIES>, -I>>")
    append_Join_Generator_Expressions(CPP_CHECK_SETTING_EXPR "$<$<BOOL:$<TARGET_PROPERTY:${component},COMPILE_DEFINITIONS>>:-D$<JOIN:$<TARGET_PROPERTY:${component},COMPILE_DEFINITIONS>, -D>>")
	endif()

  #filtering sources to keep only C/C++ sources
  filter_All_Sources(SOURCES_TO_CHECK)

	# getting specific settings of the target (using generator expression to make it robust)
	is_HeaderFree_Component(IS_HF ${PROJECT_NAME} ${component})#no need to check for alias as in current project component only base component names (by construction)
	if(NOT IS_HF)#component has a public interface
    append_Join_Generator_Expressions(CPP_CHECK_SETTING_EXPR "$<$<BOOL:$<TARGET_PROPERTY:${component},INTERFACE_INCLUDE_DIRECTORIES>>:-I$<JOIN:$<TARGET_PROPERTY:${component},INTERFACE_INCLUDE_DIRECTORIES>, -I>>")
    append_Join_Generator_Expressions(CPP_CHECK_SETTING_EXPR "$<$<BOOL:$<TARGET_PROPERTY:${component},INTERFACE_COMPILE_DEFINITIONS>>:-D$<JOIN:$<TARGET_PROPERTY:${component},INTERFACE_COMPILE_DEFINITIONS>, -D>>")
	endif()

	set(CPPCHECK_TEMPLATE_TEST --template="{severity}: {message}")
  set(CPPCHECK_LANGUAGE --language=c++)#always using c++ language
  if(BUILD_AND_RUN_TESTS) #adding a test target to check only for errors
		add_test(NAME ${component}_staticcheck
    COMMAND ${CPPCHECK_EXECUTABLE} ${CPPCHECK_LANGUAGE} ${PARALLEL_JOBS_FLAG} ${CPP_CHECK_SETTING_EXPR} ${CPPCHECK_TEMPLATE_TEST} ${SOURCES_TO_CHECK} VERBATIM)
		set_tests_properties(${component}_staticcheck PROPERTIES FAIL_REGULAR_EXPRESSION "error: ")
	endif()#TODO also manage the language standard here (option -std=)!! necessary ?

	set(CPPCHECK_TEMPLATE_GLOBAL --template="{id} in file {file} line {line}: {severity}: {message}")
	if(is_library) #only adding stylistic issues for library, not unused functions (because by definition libraries own source code has unused functions)
		set(CPPCHECK_ARGS --enable=style --inconclusive)
	else()
		set(CPPCHECK_ARGS --enable=all --inconclusive)
	endif()

	#adding a target to print all issues for the given target, this is used to generate a report
	add_custom_command(TARGET staticchecks PRE_BUILD
		COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_CURRENT_BINARY_DIR}/share/static_checks_result_${component}.xml
		COMMAND ${CPPCHECK_EXECUTABLE} ${CPPCHECK_LANGUAGE} ${CPP_CHECK_SETTING_EXPR} ${CPPCHECK_ARGS} --xml-version=2 ${SOURCES_TO_CHECK} 2> ${CMAKE_CURRENT_BINARY_DIR}/share/static_checks_result_${component}.xml
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
		COMMENT "[PID] INFO: Running cppcheck on target ${component}..."
		VERBATIM)
endfunction(add_Static_Check)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Static_Checks| replace:: ``generate_Static_Checks``
#  .. _generate_Static_Checks:
#
#  generate_Static_Checks
#  ----------------------
#
#   .. command:: generate_Static_Checks()
#
#   Generate static check reports for the currently built package.
#
function(generate_Static_Checks)

if(${CMAKE_BUILD_TYPE} MATCHES Release)

	if(NOT BUILD_STATIC_CODE_CHECKING_REPORT)
		return()
	endif()
	# cppcheck app bundles on Mac OS X are GUI, we want command line only
	set(_oldappbundlesetting ${CMAKE_FIND_APPBUNDLE})
	set(CMAKE_FIND_APPBUNDLE NEVER)
	#trying to find the cpp check executable
	find_program(CPPCHECK_EXECUTABLE NAMES cppcheck)

	if(NOT CPPCHECK_EXECUTABLE)
		message(STATUS "[PID] WARNING: cppcheck not found, forcing option BUILD_STATIC_CODE_CHECKING_REPORT to OFF.")
		set(BUILD_STATIC_CODE_CHECKING_REPORT OFF CACHE INTERNAL "" FORCE)
	endif()

	#trying to find the cppcheck-htmlreport executable
	find_program(CPPCHECK_HTMLREPORT_EXECUTABLE NAMES cppcheck-htmlreport)
	if(NOT CPPCHECK_HTMLREPORT_EXECUTABLE)
		message(STATUS "[PID] WARNING: cppcheck-htmlreport not found, forcing option BUILD_STATIC_CODE_CHECKING_REPORT to OFF.")
		set(BUILD_STATIC_CODE_CHECKING_REPORT OFF CACHE INTERNAL "" FORCE)
	endif()

	# Restore original setting for appbundle finding
	set(CMAKE_FIND_APPBUNDLE ${_oldappbundlesetting})
	mark_as_advanced(CPPCHECK_EXECUTABLE CPPCHECK_HTMLREPORT_EXECUTABLE)
else()
	return()
endif()

if(BUILD_STATIC_CODE_CHECKING_REPORT)
	add_custom_target(staticchecks COMMENT "[PID] INFO : generating a static check report (look into debug/share/static_checks_report folder)")
	#now creating test target and enriching the staticchecks global target with information coming from components
	if(${PROJECT_NAME}_COMPONENTS_LIBS)
		foreach(component ${${PROJECT_NAME}_COMPONENTS_LIBS})
			add_Static_Check(${component} TRUE)
		endforeach()
	endif()
	if(${PROJECT_NAME}_COMPONENTS_APPS)
		foreach(component ${${PROJECT_NAME}_COMPONENTS_APPS})
			# adding a static check target only for applications
			if(${PROJECT_NAME}_${component}_TYPE STREQUAL "APP")
				add_Static_Check(${component} FALSE)
			endif()
		endforeach()
	endif()
  message("[PID] INFO : Allowing static code checks ...")
  add_custom_command(TARGET staticchecks POST_BUILD
		COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/share/static_checks_report
		COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/share/static_checks_report
		COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_CURRENT_BINARY_DIR}/share/static_checks_result.xml
		COMMAND ${CMAKE_COMMAND} -DCMAKE_CURRENT_BINARY_DIR=${CMAKE_CURRENT_BINARY_DIR} -P ${WORKSPACE_DIR}/cmake/commands/PID_Utility_Concat_Staticchecks_Files_Content.cmake
		COMMAND ${CPPCHECK_HTMLREPORT_EXECUTABLE} --title="${PROJECT_NAME}" --source-dir=${CMAKE_SOURCE_DIR} --report-dir=${CMAKE_CURRENT_BINARY_DIR}/share/static_checks_report --file=${CMAKE_CURRENT_BINARY_DIR}/share/static_checks_result.xml
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
	)

else()
	add_custom_target(staticchecks COMMENT "[PID] INFO : do not generate a static check report (cppcheck not found)")
endif()

endfunction(generate_Static_Checks)
