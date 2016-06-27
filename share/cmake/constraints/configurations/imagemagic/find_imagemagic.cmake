#########################################################################################
#	This file is part of the program PID						#
#  	Program description : build system supportting the PID methodology  		#
#  	Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique 	#
#	et de Microelectronique de Montpellier). All Right reserved.			#
#											#
#	This software is free software: you can redistribute it and/or modify		#
#	it under the terms of the CeCILL-C license as published by			#
#	the CEA CNRS INRIA, either version 1						#
#	of the License, or (at your option) any later version.				#
#	This software is distributed in the hope that it will be useful,		#
#	but WITHOUT ANY WARRANTY; without even the implied warranty of			#
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the			#
#	CeCILL-C License for more details.						#
#											#
#	You can find the complete license description on the official website 		#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################

#---------------------------------------------------------------------
# Helper functions
#---------------------------------------------------------------------
FUNCTION(FIND_IMAGEMAGICK_API component header)
  SET(ImageMagick_${component}_FOUND FALSE PARENT_SCOPE)

  FIND_PATH(ImageMagick_${component}_INCLUDE_DIR
    NAMES ${header}
    PATHS
      ${ImageMagick_INCLUDE_DIRS}
      "[HKEY_LOCAL_MACHINE\\SOFTWARE\\ImageMagick\\Current;BinPath]/include"
    PATH_SUFFIXES
      ImageMagick
    DOC "Path to the ImageMagick include dir."
    )
  FIND_LIBRARY(ImageMagick_${component}_LIBRARY
    NAMES ${ARGN}
    PATHS
      "[HKEY_LOCAL_MACHINE\\SOFTWARE\\ImageMagick\\Current;BinPath]/lib"
    DOC "Path to the ImageMagick Magick++ library."
    )

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
  SET(_IMAGEMAGICK_EXECUTABLE
    ${ImageMagick_EXECUTABLE_DIR}/${component}${CMAKE_EXECUTABLE_SUFFIX})
  IF(EXISTS ${_IMAGEMAGICK_EXECUTABLE})
    SET(ImageMagick_${component}_EXECUTABLE
      ${_IMAGEMAGICK_EXECUTABLE}
       PARENT_SCOPE
       )
    SET(ImageMagick_${component}_FOUND TRUE PARENT_SCOPE)
  ELSE(EXISTS ${_IMAGEMAGICK_EXECUTABLE})
    SET(ImageMagick_${component}_FOUND FALSE PARENT_SCOPE)
  ENDIF(EXISTS ${_IMAGEMAGICK_EXECUTABLE})
ENDFUNCTION(FIND_IMAGEMAGICK_EXE)


set(imagemagic_FOUND FALSE CACHE INTERNAL "")
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
	FOREACH(component ${ImageMagick_FIND_COMPONENTS}
	    # DEPRECATED: forced components for backward compatibility
	    convert mogrify import montage composite
	    )
	  IF(component STREQUAL "Magick++")
	    FIND_IMAGEMAGICK_API(Magick++ Magick++.h
	      Magick++ CORE_RL_Magick++_
	      )
	  ELSEIF(component STREQUAL "MagickWand")
	    FIND_IMAGEMAGICK_API(MagickWand wand/MagickWand.h
	      Wand MagickWand CORE_RL_wand_
	      )
	  ELSEIF(component STREQUAL "MagickCore")
	    FIND_IMAGEMAGICK_API(MagickCore magick/MagickCore.h
	      Magick MagickCore CORE_RL_magick_
	      )
	  ELSE(component STREQUAL "Magick++")
	    IF(ImageMagick_EXECUTABLE_DIR)
	      FIND_IMAGEMAGICK_EXE(${component})
	    ENDIF(ImageMagick_EXECUTABLE_DIR)
	  ENDIF(component STREQUAL "Magick++")

	  IF(NOT ImageMagick_${component}_FOUND)
	    LIST(FIND ImageMagick_FIND_COMPONENTS ${component} is_requested)
	    IF(is_requested GREATER -1)
	      SET(IS_FOUND FALSE)
	    ENDIF(is_requested GREATER -1)
	  ENDIF(NOT ImageMagick_${component}_FOUND)
	ENDFOREACH(component)

  set(imagemagic_FOUND ${IS_FOUND} CACHE INTERNAL "")
	set(imagemagic_PATH ${ImageMagick_INCLUDE_DIRS}  CACHE INTERNAL "")
	set(imagemagic_LIBRARIES ${ImageMagick_LIBRARIES}  CACHE INTERNAL "")

	#---------------------------------------------------------------------
	# Standard Package Output
	#---------------------------------------------------------------------
	INCLUDE(FindPackageHandleStandardArgs)
	FIND_PACKAGE_HANDLE_STANDARD_ARGS(
	  ImageMagick DEFAULT_MSG ImageMagick_FOUND
	  )
	# Maintain consistency with all other variables.
	SET(ImageMagick_FOUND ${IMAGEMAGICK_FOUND})


endif ()
