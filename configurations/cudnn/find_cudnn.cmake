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

found_PID_Configuration(cudnn FALSE)

get_filename_component(__libpath_cudart "${CUDA_CUDART_LIBRARY}" PATH)

# We use major only in library search as major/minor is not entirely consistent among platforms.
# Also, looking for exact minor version of .so is in general not a good idea.
# More strict enforcement of minor/patch version is done if/when the header file is examined.
if(CUDNN_FIND_VERSION_EXACT)
  SET(__cudnn_ver_suffix ".${CUDNN_FIND_VERSION_MAJOR}")
  SET(__cudnn_lib_win_name cudnn64_${CUDNN_FIND_VERSION_MAJOR})
else()
  SET(__cudnn_lib_win_name cudnn64)
endif()

find_library(CUDNN_LIBRARY
  NAMES libcudnn.so${__cudnn_ver_suffix} libcudnn${__cudnn_ver_suffix}.dylib ${__cudnn_lib_win_name}
  PATHS $ENV{LD_LIBRARY_PATH} ${__libpath_cudart} ${CUDNN_ROOT_DIR} ${CMAKE_INSTALL_PREFIX}
  PATH_SUFFIXES lib lib64 bin
  DOC "CUDNN library." )

if(CUDNN_LIBRARY)
  SET(CUDNN_MAJOR_VERSION ${CUDNN_FIND_VERSION_MAJOR})
  set(CUDNN_VERSION ${CUDNN_MAJOR_VERSION})
  get_filename_component(__found_cudnn_root ${CUDNN_LIBRARY} PATH)
  find_path(CUDNN_INCLUDE_DIR
    NAMES cudnn.h
    HINTS ${PC_CUDNN_INCLUDE_DIRS} ${CUDNN_ROOT_DIR} ${CUDA_TOOLKIT_INCLUDE} ${__found_cudnn_root}
    PATH_SUFFIXES include
    DOC "Path to CUDNN include directory." )
endif()

if(CUDNN_LIBRARY AND CUDNN_INCLUDE_DIR)
  file(READ ${CUDNN_INCLUDE_DIR}/cudnn.h CUDNN_VERSION_FILE_CONTENTS)
  string(REGEX MATCH "define CUDNN_MAJOR * +([0-9]+)"
    CUDNN_MAJOR_VERSION "${CUDNN_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "define CUDNN_MAJOR * +([0-9]+)" "\\1"
    CUDNN_MAJOR_VERSION "${CUDNN_MAJOR_VERSION}")
  string(REGEX MATCH "define CUDNN_MINOR * +([0-9]+)"
    CUDNN_MINOR_VERSION "${CUDNN_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "define CUDNN_MINOR * +([0-9]+)" "\\1"
    CUDNN_MINOR_VERSION "${CUDNN_MINOR_VERSION}")
  string(REGEX MATCH "define CUDNN_PATCHLEVEL * +([0-9]+)"
    CUDNN_PATCH_VERSION "${CUDNN_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "define CUDNN_PATCHLEVEL * +([0-9]+)" "\\1"
    CUDNN_PATCH_VERSION "${CUDNN_PATCH_VERSION}")
  set(CUDNN_VERSION ${CUDNN_MAJOR_VERSION}.${CUDNN_MINOR_VERSION})
endif()


if(cudnn_version)# a version constraint is defined (if code works only with a given version)
	if(CUDNN_VERSION VERSION_LESS cudnn_version)#if the CUDA version is known and a nvcc compiler has been defined
		return()#version does not match
	endif()
endif()

found_PID_Configuration(cudnn TRUE)

convert_PID_Libraries_Into_System_Links(CUDNN_LIBRARY CUDNN_LINK)#getting good system links (with -l)
convert_PID_Libraries_Into_Library_Directories(CUDNN_LIBRARY CUDNN_LIBRARY_DIR)
