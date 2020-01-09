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

#find bazel program
find_program(BAZEL_EXECUTABLE bazel)

execute_process(COMMAND "${BAZEL_EXECUTABLE}" version
  RESULT_VARIABLE RES_VAR
  OUTPUT_VARIABLE OUTPUT_VAR
  ERROR_QUIET
)

#determine bazel version
set(BAZEL_VERSION)
if(RES_VAR EQUAL 0)#OK execution output is OK
  if(OUTPUT_VAR MATCHES "Build label: ([0-9a-zA-Z.]+)")
    set(BAZEL_VERSION "${CMAKE_MATCH_1}")
  endif()
endif()
unset(RES_VAR)
unset(OUTPUT_VAR)

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(Bazel
  FOUND_VAR BAZEL_FOUND
  REQUIRED_VARS BAZEL_EXECUTABLE
  VERSION_VAR BAZEL_VERSION
)
