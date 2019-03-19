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

found_PID_Configuration(nccl FALSE)

set(NCCL_INC_PATHS
    /usr/include
    /usr/local/include
    $ENV{NCCL_DIR}/include
    )

set(NCCL_LIB_PATHS
    /lib
    /lib64
    /usr/lib
    /usr/lib64
    /usr/local/lib
    /usr/local/lib64
    $ENV{NCCL_DIR}/lib
    )

find_path(NCCL_INCLUDE_DIR NAMES nccl.h PATHS ${NCCL_INC_PATHS})
find_library(NCCL_LIBRARY NAMES nccl PATHS ${NCCL_LIB_PATHS})

if (NCCL_INCLUDE_DIR AND NCCL_LIBRARY)
  message(STATUS "Found NCCL    (include: ${NCCL_INCLUDE_DIR}, library: ${NCCL_LIBRARIES})")
  mark_as_advanced(NCCL_INCLUDE_DIR NCCL_LIBRARY)
  #need to extract the version
  file(READ ${NCCL_INCLUDE_DIR}/nccl.h NCCL_VERSION_FILE_CONTENTS)
  string(REGEX MATCH "define NCCL_MAJOR * +([0-9]+)"
    NCCL_MAJOR_VERSION "${NCCL_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "define NCCL_MAJOR * +([0-9]+)" "\\1"
    NCCL_MAJOR_VERSION "${NCCL_MAJOR_VERSION}")
  string(REGEX MATCH "define NCCL_MINOR * +([0-9]+)"
    NCCL_MINOR_VERSION "${NCCL_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "define NCCL_MINOR * +([0-9]+)" "\\1"
    NCCL_MINOR_VERSION "${NCCL_MINOR_VERSION}")
  string(REGEX MATCH "define NCCL_PATCH * +([0-9]+)"
    NCCL_PATCH_VERSION "${NCCL_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "define NCCL_PATCH * +([0-9]+)" "\\1"
    NCCL_PATCH_VERSION "${NCCL_PATCH_VERSION}")
  set(NCCL_VERSION ${NCCL_MAJOR_VERSION}.${NCCL_MINOR_VERSION})
endif ()

if(nccl_version)# a version constraint is defined (if code works only with a given version)
	if(NCCL_VERSION VERSION_LESS nccl_version)#if the CUDA version is known and a nvcc compiler has been defined
    unset(NCCL_INCLUDE_DIR CACHE)
    unset(NCCL_LIBRARY CACHE)
    return()#version does not match
	endif()
endif()

found_PID_Configuration(nccl TRUE)

convert_PID_Libraries_Into_System_Links(NCCL_LIBRARY NCCL_LINK)#getting good system links (with -l)
convert_PID_Libraries_Into_Library_Directories(NCCL_LIBRARY NCCL_LIBRARY_DIR)
