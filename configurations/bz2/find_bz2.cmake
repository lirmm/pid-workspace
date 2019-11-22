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

found_PID_Configuration(bz2 FALSE)

if (WIN32)
	set(_BZIP2_PATHS PATHS "[HKEY_LOCAL_MACHINE\\SOFTWARE\\GnuWin32\\Bzip2;InstallPath]")
endif()

find_path(BZIP2_INCLUDE_PATH bzlib.h ${_BZIP2_PATHS} PATH_SUFFIXES include)
set(BZ2_INCLUDE_DIR ${BZIP2_INCLUDE_PATH})
unset(BZIP2_INCLUDE_PATH CACHE)

find_PID_Library_In_Linker_Order("bz2;bzip2" ALL BZ2_LIB BZ2_SONAME)

if (BZ2_INCLUDE_DIR AND EXISTS "${BZ2_INCLUDE_DIR}/bzlib.h")
    file(STRINGS "${BZ2_INCLUDE_DIR}/bzlib.h" BZLIB_H REGEX "bzip2/libbzip2 version [0-9]+\\.[^ ]+ of [0-9]+ ")
    string(REGEX REPLACE ".* bzip2/libbzip2 version ([0-9]+\\.[^ ]+) of [0-9]+ .*" "\\1" BZ2_VERSION "${BZLIB_H}")
endif ()

if(BZ2_INCLUDE_DIR AND BZ2_LIB)
	convert_PID_Libraries_Into_System_Links(BZ2_LIB BZ2_LINKS)#getting good system links (with -l)
	convert_PID_Libraries_Into_Library_Directories(BZ2_LIB BZ2_LIBDIRS)
	found_PID_Configuration(bz2 TRUE)
else()
	message("[PID] ERROR : cannot find bz2 library (found include=${BZ2_INCLUDE_DIR}, library=${BZ2_LIB}).")
endif()
