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

found_PID_Configuration(libjpeg FALSE)

find_path(JPEG_INCLUDE_DIR jpeglib.h)
if(JPEG_INCLUDE_DIR AND EXISTS "${JPEG_INCLUDE_DIR}/jpeglib.h")
  file(STRINGS "${JPEG_INCLUDE_DIR}/jpeglib.h"
    jpeg_lib_version REGEX "^#define[\t ]+JPEG_LIB_VERSION[\t ]+.*")

  if (NOT jpeg_lib_version)
    # libjpeg-turbo sticks JPEG_LIB_VERSION in jconfig.h
    find_path(jconfig_dir jconfig.h)
    if (jconfig_dir)
      file(STRINGS "${jconfig_dir}/jconfig.h"
        jpeg_lib_version REGEX "^#define[\t ]+JPEG_LIB_VERSION[\t ]+.*")
    endif()
    unset(jconfig_dir)
  endif()

  string(REGEX REPLACE "^#define[\t ]+JPEG_LIB_VERSION[\t ]+([0-9]+).*"
    "\\1" JPEG_VERSION "${jpeg_lib_version}")
  unset(jpeg_lib_version)
endif()

find_library(JPEG_LIB jpeg)
set(JPEG_INCLUDE ${JPEG_INCLUDE_DIR})
set(JPEG_LIBRARY ${JPEG_LIB})
unset(JPEG_INCLUDE_DIR CACHE)
unset(JPEG_LIB CACHE)

if(JPEG_INCLUDE AND JPEG_LIBRARY)
	convert_PID_Libraries_Into_System_Links(JPEG_LIBRARY LIBJPEG_LINKS)#getting good system links (with -l)
  convert_PID_Libraries_Into_Library_Directories(JPEG_LIBRARY LIBJPEG_LIBDIR)
	found_PID_Configuration(libjpeg TRUE)
else()
	message("[PID] WARNING : cannot find jpeg library.")
endif()
