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

found_PID_Configuration(tiff FALSE)

if (UNIX)
#copied stuff from official find tiff
find_path(TIFF_INCLUDE_DIR tiff.h)

set(TIFF_NAMES ${TIFF_NAMES} tiff libtiff tiff3 libtiff3)
foreach(name ${TIFF_NAMES})
  list(APPEND TIFF_NAMES_DEBUG "${name}d")
endforeach()

find_library(TIFF_LIBRARY NAMES ${TIFF_NAMES})
mark_as_advanced(TIFF_LIBRARY)
unset(TIFF_NAMES)
unset(TIFF_NAMES_DEBUG)

if(TIFF_INCLUDE_DIR AND EXISTS "${TIFF_INCLUDE_DIR}/tiffvers.h")
    file(STRINGS "${TIFF_INCLUDE_DIR}/tiffvers.h" tiff_version_str
         REGEX "^#define[\t ]+TIFFLIB_VERSION_STR[\t ]+\"LIBTIFF, Version .*")

    string(REGEX REPLACE "^#define[\t ]+TIFFLIB_VERSION_STR[\t ]+\"LIBTIFF, Version +([^ \\n]*).*"
           "\\1" TIFF_VERSION_STRING "${tiff_version_str}")
    unset(tiff_version_str)
endif()

	if(TIFF_INCLUDE_DIR AND TIFF_LIBRARY)
		convert_PID_Libraries_Into_System_Links(TIFF_LIBRARY TIFF_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(TIFF_LIBRARY TIFF_LIBDIRS)
		found_PID_Configuration(tiff TRUE)
	else()
		message("[PID] ERROR : cannot find tiff library.")
	endif()

	unset(TIFF_FOUND)
endif ()
