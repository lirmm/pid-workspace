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

found_PID_Configuration(glibs FALSE)

# finding gflags
# Search user-installed locations first, so that we prefer user installs
# to system installs where both exist.
list(APPEND GFLAGS_CHECK_INCLUDE_DIRS
	/usr/local/include
	/usr/local/homebrew/include # Mac OS X
	/opt/local/var/macports/software # Mac OS X.
	/opt/local/include
	/usr/include)
list(APPEND GFLAGS_CHECK_PATH_SUFFIXES
	gflags/include # Windows (for C:/Program Files prefix).
	gflags/Include ) # Windows (for C:/Program Files prefix).

list(APPEND GFLAGS_CHECK_LIBRARY_DIRS
	/usr/local/lib
	/usr/local/homebrew/lib # Mac OS X.
	/opt/local/lib
	/usr/lib)
list(APPEND GFLAGS_CHECK_LIBRARY_SUFFIXES
	gflags/lib # Windows (for C:/Program Files prefix).
	gflags/Lib ) # Windows (for C:/Program Files prefix).

# Search supplied hint directories first if supplied.
find_path(GFLAGS_INCLUDE_DIR
	NAMES gflags/gflags.h
	PATHS ${GFLAGS_INCLUDE_DIR_HINTS}
	${GFLAGS_CHECK_INCLUDE_DIRS}
	PATH_SUFFIXES ${GFLAGS_CHECK_PATH_SUFFIXES})
if (NOT GFLAGS_INCLUDE_DIR OR
		NOT EXISTS ${GFLAGS_INCLUDE_DIR})
		return()
endif ()

find_library(GFLAGS_LIBRARY NAMES gflags
	PATHS ${GFLAGS_LIBRARY_DIR_HINTS}
	${GFLAGS_CHECK_LIBRARY_DIRS}
	PATH_SUFFIXES ${GFLAGS_CHECK_LIBRARY_SUFFIXES})
if (NOT GFLAGS_LIBRARY OR
		NOT EXISTS ${GFLAGS_LIBRARY})
		return()
endif ()

#finding glog
if(WIN32)
    find_path(GLOG_INCLUDE_DIR glog/logging.h
        PATHS ${GLOG_ROOT_DIR}/src/windows)
else()
    find_path(GLOG_INCLUDE_DIR glog/logging.h
        PATHS ${GLOG_ROOT_DIR})
endif()

if(MSVC)
    find_library(GLOG_LIBRARY_RELEASE libglog_static
        PATHS ${GLOG_ROOT_DIR}
        PATH_SUFFIXES Release)

    find_library(GLOG_LIBRARY_DEBUG libglog_static
        PATHS ${GLOG_ROOT_DIR}
        PATH_SUFFIXES Debug)

    set(GLOG_LIBRARY optimized ${GLOG_LIBRARY_RELEASE} debug ${GLOG_LIBRARY_DEBUG})
else()
    find_library(GLOG_LIBRARY glog
        PATHS ${GLOG_ROOT_DIR}
        PATH_SUFFIXES lib lib64)
endif()

if(GLOG_LIBRARY AND GLOG_INCLUDE_DIR)
  set(GLIBS_INCLUDE_DIRS ${GLOG_INCLUDE_DIR} ${GFLAGS_INCLUDE_DIRS})
	unset(GLOG_INCLUDE_DIR CACHE)
  set(GLIBS_LIBRARIES ${GLOG_LIBRARY} ${GFLAGS_LIBRARIES})
	unset(GLOG_LIBRARY CACHE)
	convert_PID_Libraries_Into_System_Links(GLIBS_LIBRARIES GLIBS_LINKS)#getting good system links (with -l)
	convert_PID_Libraries_Into_Library_Directories(GLIBS_LIBRARIES GLIBS_LIBDIR)
	found_PID_Configuration(glibs TRUE)
endif()
