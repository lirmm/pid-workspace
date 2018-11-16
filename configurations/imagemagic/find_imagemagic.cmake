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

#---------------------------------------------------------------------
# Helper functions
#---------------------------------------------------------------------
FUNCTION(FIND_IMAGEMAGICK_API component header)
  SET(ImageMagick_${component}_FOUND FALSE PARENT_SCOPE)

  FIND_PATH(ImageMagick_${component}_INCLUDE_DIR
    NAMES ${header}
    PATH_SUFFIXES ImageMagick ImageMagick-6
    DOC "Path to the ImageMagick include dir."
    )

  FIND_LIBRARY(ImageMagick_${component}_LIBRARY
    NAMES ${ARGN}
    DOC "Path to the ImageMagick Magick++ library."
    )
  MESSAGE("ImageMagick_${component}_INCLUDE_DIR=${ImageMagick_${component}_INCLUDE_DIR}")
  IF(ImageMagick_${component}_INCLUDE_DIR AND ImageMagick_${component}_LIBRARY)

    SET(ImageMagick_${component}_FOUND TRUE PARENT_SCOPE)

    LIST(APPEND ImageMagick_INCLUDE_DIRS
      ${ImageMagick_${component}_INCLUDE_DIR}
      )
    LIST(REMOVE_DUPLICATES ImageMagick_INCLUDE_DIRS)
    SET(ImageMagick_INCLUDE_DIRS ${ImageMagick_INCLUDE_DIRS} PARENT_SCOPE)

    LIST(APPEND ImageMagick_LIBRARIES
      ${ImageMagick_${component}_LIBRARY}
      )
    SET(ImageMagick_LIBRARIES ${ImageMagick_LIBRARIES} PARENT_SCOPE)
  ENDIF(ImageMagick_${component}_INCLUDE_DIR AND ImageMagick_${component}_LIBRARY)
ENDFUNCTION(FIND_IMAGEMAGICK_API)

FUNCTION(FIND_IMAGEMAGICK_EXE component)
  SET(_IMAGEMAGICK_EXECUTABLE ${ImageMagick_EXECUTABLE_DIR}/${component}${CMAKE_EXECUTABLE_SUFFIX})
  IF(EXISTS ${_IMAGEMAGICK_EXECUTABLE})
    SET(ImageMagick_${component}_EXECUTABLE ${_IMAGEMAGICK_EXECUTABLE} PARENT_SCOPE)
    SET(ImageMagick_${component}_FOUND TRUE PARENT_SCOPE)
  ELSE()
    SET(ImageMagick_${component}_FOUND FALSE PARENT_SCOPE)
  ENDIF()
ENDFUNCTION(FIND_IMAGEMAGICK_EXE)


include(Configuration_Definition NO_POLICY_SCOPE)

found_PID_Configuration(imagemagic FALSE)

# - Find imagemagic installation
# Try to find ImageMagic on UNIX systems. The following values are defined
#  imagemagic_FOUND        - True if X11 is available
#  imagemagic_LIBRARIES    - link against these to use X11
if (UNIX)
	FIND_PATH(ImageMagick_EXECUTABLE_DIR
		  NAMES mogrify${CMAKE_EXECUTABLE_SUFFIX}
	)

  	# Find each component. Search for all tools in same dir
	# <ImageMagick_EXECUTABLE_DIR>; otherwise they should be found
	# independently and not in a cohesive module such as this one.
	SET(IS_FOUND TRUE)
	set(COMPONENT_LIST magick-baseconfig MagickCore Magick++ MagickWand convert mogrify import montage composite)# DEPRECATED: forced components for backward compatibility
	FOREACH(component ${COMPONENT_LIST})
	  MESSAGE("searching component ${component}")
	  IF(component STREQUAL "magick-baseconfig")
		  SET(ImageMagick_${component}_FOUND FALSE)

		  FIND_PATH(ImageMagick_${component}_INCLUDE_DIR
		    NAMES "magick/magick-baseconfig.h"
		    PATH_SUFFIXES ImageMagick ImageMagick-6
		    )
		 IF(ImageMagick_${component}_INCLUDE_DIR)
		    SET(ImageMagick_${component}_FOUND TRUE)

		    LIST(APPEND ImageMagick_INCLUDE_DIRS
		      ${ImageMagick_${component}_INCLUDE_DIR}
		      )
		    LIST(REMOVE_DUPLICATES ImageMagick_INCLUDE_DIRS)
		ENDIF()

	  ELSEIF(component STREQUAL "Magick++")
	    FIND_IMAGEMAGICK_API(Magick++ Magick++.h Magick++ Magick++-6 Magick++-6.Q16 CORE_RL_Magick++_)
	  ELSEIF(component STREQUAL "MagickWand")
	    FIND_IMAGEMAGICK_API(MagickWand wand/MagickWand.h Wand MagickWand MagickWand-6 MagickWand-6.Q16 CORE_RL_wand_)
	  ELSEIF(component STREQUAL "MagickCore")
	    FIND_IMAGEMAGICK_API(MagickCore magick/MagickCore.h Magick MagickCore MagickCore-6 MagickCore-6.Q16 CORE_RL_magick_)
	  ELSE()
	    IF(ImageMagick_EXECUTABLE_DIR)
	      FIND_IMAGEMAGICK_EXE(${component})
	    ENDIF()
	  ENDIF()

	  IF(NOT ImageMagick_${component}_FOUND)
	    SET(IS_FOUND FALSE)
	  ENDIF()
	ENDFOREACH(component)

	include(FindPkgConfig)
	pkg_check_modules(LIBX264 x264)
	IF(NOT LIBX264_FOUND)
		SET(IS_FOUND FALSE)
	ENDIF()
  if(IS_FOUND)
    set(ImageMagick_LIBRARIES ${ImageMagick_LIBRARIES} ${LIBX264_LDFLAGS})
    set(ImageMagick_INCLUDE_DIRS ${ImageMagick_INCLUDE_DIRS} ${LIBX264_INCLUDE_DIRS})
    convert_PID_Libraries_Into_System_Links(ImageMagick_LIBRARIES ImageMagick_LINKS)#getting good system links (with -l)
    convert_PID_Libraries_Into_Library_Directories(ImageMagick_LIBRARIES ImageMagick_LIBDIR)
    found_PID_Configuration(imagemagic TRUE)
  endif()
endif ()
