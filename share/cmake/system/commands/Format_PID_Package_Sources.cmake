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

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE) # to be able to interpret description of external components

function(format_source_directory dir)
    # get C/C++ files based on extension matching
    get_All_Cpp_Sources_Absolute(CPP_SOURCES ${dir})

    foreach(file IN LISTS CPP_SOURCES)
        # format the file inplace (-i) using the closest .clang-format file in the hierarchy (-style=file)
        execute_process(
            COMMAND ${CLANG_FORMAT_EXE} -style=file -i ${file}
            RESULT_VARIABLE res
            OUTPUT_VARIABLE out)
    endforeach()
endfunction(format_source_directory)

set(PACKAGE_DIR ${WORKSPACE_DIR}/packages/${PACKAGE_NAME})

format_source_directory(${PACKAGE_DIR}/apps)
format_source_directory(${PACKAGE_DIR}/include)
format_source_directory(${PACKAGE_DIR}/src)
format_source_directory(${PACKAGE_DIR}/test)
