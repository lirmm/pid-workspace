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

set(coverage_info "${TARGET_BINARY_DIR}/lcovoutput.info")
set(coverage_cleaned "${TARGET_BINARY_DIR}/${PROJECT_NAME}_coverage")
set(coverage_dir "${TARGET_BINARY_DIR}/share/coverage_report")

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
