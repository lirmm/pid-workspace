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

found_PID_Configuration(libjasper FALSE)

find_path(JASPER_INCLUDE_DIR jasper/jasper.h)
if (JASPER_INCLUDE_DIR AND EXISTS "${JASPER_INCLUDE_DIR}/jasper/jas_config.h")
    file(STRINGS "${JASPER_INCLUDE_DIR}/jasper/jas_config.h" jasper_version_str REGEX "^#define[\t ]+JAS_VERSION[\t ]+\".*\".*")
    string(REGEX REPLACE "^#define[\t ]+JAS_VERSION[\t ]+\"([^\"]+)\".*" "\\1" JASPER_VERSION_STRING "${jasper_version_str}")
endif ()

find_library(JASPER_LIBRARY NAMES jasper libjasper)
set(JASPER_LIBRARIES ${JASPER_LIBRARY})
set(JASPER_INCLUDE_DIRS ${JASPER_INCLUDE_DIR})
unset(JASPER_LIBRARY CACHE)
unset(JASPER_INCLUDE_DIR CACHE)

if(JASPER_LIBRARIES AND JASPER_INCLUDE_DIRS)
	convert_PID_Libraries_Into_System_Links(JASPER_LIBRARIES JAPSER_LINKS)#getting good system links (with -l)
  convert_PID_Libraries_Into_Library_Directories(JASPER_LIBRARIES JAPSER_LIBDIR)
	found_PID_Configuration(libjasper TRUE)
else()
	message("[PID] WARNING : cannot find jasper library.")
endif()
