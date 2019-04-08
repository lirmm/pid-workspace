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

found_PID_Configuration(libgif FALSE)

find_path(GIF_INCLUDE_DIR gif_lib.h HINTS ENV GIF_DIR PATH_SUFFIXES include)
# the gif library can have many names :-/
set(POTENTIAL_GIF_LIBS gif libgif ungif libungif giflib giflib4)
find_library(GIF_LIBRARY NAMES ${POTENTIAL_GIF_LIBS} HINTS ENV GIF_DIR PATH_SUFFIXES lib)
set(GIF_INC ${GIF_INCLUDE_DIR})
set(GIF_LIB ${GIF_LIBRARY})
unset(GIF_INCLUDE_DIR CACHE)#avoid caching those variable to avoid noise in cache
unset(GIF_LIBRARY CACHE)#avoid caching those variable to avoid noise in cache
if(GIF_INC AND GIF_LIB)
	file(STRINGS ${GIF_INC}/gif_lib.h GIF_DEFS REGEX "^[ \t]*#define[ \t]+GIFLIB_(MAJOR|MINOR|RELEASE)")
	if(GIF_DEFS)
		# yay - got exact version info
		string(REGEX REPLACE ".*GIFLIB_MAJOR ([0-9]+).*" "\\1" _GIF_MAJ "${GIF_DEFS}")
		string(REGEX REPLACE ".*GIFLIB_MINOR ([0-9]+).*" "\\1" _GIF_MIN "${GIF_DEFS}")
		string(REGEX REPLACE ".*GIFLIB_RELEASE ([0-9]+).*" "\\1" _GIF_REL "${GIF_DEFS}")
		set(GIF_VERSION "${_GIF_MAJ}.${_GIF_MIN}.${_GIF_REL}")

		#OK everything detected
		convert_PID_Libraries_Into_System_Links(GIF_LIB GIF_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(GIF_LIB GIF_LIBDIR)
		found_PID_Configuration(libgif TRUE)
	endif()
endif()
