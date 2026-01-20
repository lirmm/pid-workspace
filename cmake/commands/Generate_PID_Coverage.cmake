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

set(coverage_dir "${TARGET_BINARY_DIR}/share/coverage_report")

get_filename_component(gcov_name ${GCOV_EXECUTABLE} NAME)

macro(is_executable file is_exe)
  if(UNIX)
    execute_process(COMMAND test -x ${file} RESULT_VARIABLE _result)
    if(_result EQUAL 0)
      set(${is_exe} TRUE)
    else()
      set(${is_exe} FALSE)
    endif()
  else()
    # Pour Windows, utilise une autre méthode si nécessaire
    set(${is_exe} FALSE)
  endif()
endmacro()

if(gcov_name STREQUAL "llvm-cov")
  
  set(LLVM_PROFILE_FILE "${TARGET_BINARY_DIR}/coverage.profraw")
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E env LLVM_PROFILE_FILE=${LLVM_PROFILE_FILE} CTEST_OUTPUT_ON_FAILURE=1 ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG}
    WORKING_DIRECTORY ${TARGET_BINARY_DIR}
  )

  if(EXISTS "${LLVM_PROFILE_FILE}")
    set(COVERAGE_PROFRAW_FILES "${LLVM_PROFILE_FILE}")
  else()
    file(GLOB_RECURSE COVERAGE_PROFRAW_FILES "${TARGET_BINARY_DIR}/*.profraw")
  endif()

  execute_process(
    COMMAND llvm-profdata merge -output=${TARGET_BINARY_DIR}/coverage.profdata ${COVERAGE_PROFRAW_FILES}
    WORKING_DIRECTORY ${TARGET_BINARY_DIR}
  )

  file(GLOB TEST_BINARIES "${TARGET_BINARY_DIR}/test/*")
  foreach(binary IN LISTS TEST_BINARIES)
    if(NOT IS_DIRECTORY ${binary})
      is_executable(${binary} IS_EXE)
        if(IS_EXE)
          list(APPEND TEST_BINARIES_OPTIONS "--object" "${binary}")
        endif()
    endif()
  endforeach()

  execute_process(
    COMMAND llvm-cov show
      --format=html
      --output-dir=${coverage_dir}
      --instr-profile=${TARGET_BINARY_DIR}/coverage.profdata
      --ignore-filename-regex="${TARGET_SOURCE_DIR}/test/.*|${WORKSPACE_DIR}/install/.*|/usr/.*"
      --no-warn
      --no-deprecated-warn
      ${TEST_BINARIES_OPTIONS}
    WORKING_DIRECTORY ${TARGET_BINARY_DIR}
  )

  file(REMOVE_RECURSE ${COVERAGE_PROFRAW_FILES} ${TARGET_BINARY_DIR}/coverage.profdata)

elseif(gcov_name STREQUAL "gcov")

  set(coverage_info "${TARGET_BINARY_DIR}/lcovoutput.info")
  set(coverage_cleaned "${TARGET_BINARY_DIR}/${PROJECT_NAME}_coverage")

  execute_process(
    COMMAND ${LCOV_EXECUTABLE} --base-directory ${TARGET_SOURCE_DIR} --directory ${TARGET_BINARY_DIR} --zerocounters #prepare coverage generation
    WORKING_DIRECTORY ${TARGET_BINARY_DIR}
  )
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E env CTEST_OUTPUT_ON_FAILURE=1 ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG} # Run tests
    WORKING_DIRECTORY ${TARGET_BINARY_DIR}
  )
  execute_process(
    COMMAND ${LCOV_EXECUTABLE} --base-directory ${TARGET_SOURCE_DIR} --directory ${TARGET_BINARY_DIR} --capture --output-file ${coverage_info} --no-external
    WORKING_DIRECTORY ${TARGET_BINARY_DIR}
  )
  execute_process(
    #configure the filter of output (remove everything that is not related to the libraries)
    COMMAND ${LCOV_EXECUTABLE} --remove ${coverage_info} "/usr/*" "${WORKSPACE_DIR}/install/*" "${TARGET_SOURCE_DIR}/test/*" --output-file ${coverage_cleaned}
    WORKING_DIRECTORY ${TARGET_BINARY_DIR}
  )
  execute_process(
    COMMAND ${GENHTML_EXECUTABLE} -o ${coverage_dir} ${coverage_cleaned} #generating output
    WORKING_DIRECTORY ${TARGET_BINARY_DIR}
  )

  file(REMOVE ${coverage_info} ${coverage_cleaned})

endif()

