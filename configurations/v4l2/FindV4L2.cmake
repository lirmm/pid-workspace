#########################################################################################
#       This file is part of the program PID                                            #
#       Program description : build system supporting the PID methodology              	#
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

if(NOT UNIX)
  set(V4L2_FOUND FALSE)
else()

  find_path(V4L2_INCLUDE_VIDEODEV2 linux/videodev2.h
    PATH /usr/include
         /usr/local/include
         /usr/src/linux/include)
  find_path(V4L2_INCLUDE_LIBV4L2 libv4l2.h
    PATH /usr/include
         /usr/local/include
         /usr/src/linux/include)
  find_library(V4L2_LIBRARY_LIBV4L2 NAMES v4l2
    PATH  /usr/lib
          /usr/local/lib)
  find_library(V4L2_LIBRARY_LIBV4LCONVERT NAMES v4lconvert
    PATH  /usr/lib
          /usr/local/lib)

  if(V4L2_INCLUDE_VIDEODEV2 AND V4L2_INCLUDE_LIBV4L2
    AND V4L2_LIBRARY_LIBV4L2 AND V4L2_LIBRARY_LIBV4LCONVERT)
    set(V4L2_INCLUDE_DIRS ${V4L2_INCLUDE_VIDEODEV2} ${V4L2_INCLUDE_LIBV4L2})
    set(V4L2_LIBRARIES ${V4L2_LIBRARY_LIBV4L2} ${V4L2_LIBRARY_LIBV4LCONVERT})
    set(V4L2_FOUND TRUE)
  else()
    set(V4L2_FOUND FALSE)
  endif()

  mark_as_advanced(
    V4L2_INCLUDE_VIDEODEV2
    V4L2_INCLUDE_LIBV4L2
    V4L2_LIBRARY_LIBV4L2
    V4L2_LIBRARY_LIBV4LCONVERT
    )
endif()
