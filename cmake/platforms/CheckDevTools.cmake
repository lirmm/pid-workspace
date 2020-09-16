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

####### searching for shared objects manipulation utility (patchelf on unix, libtool on macos) #######
if(CMAKE_HOST_APPLE)
  find_program(SHARED_OBJ_UTILITY install_name_tool)
elseif(CMAKE_HOST_UNIX)
  find_program(SHARED_OBJ_UTILITY patchelf)
endif()
if(SHARED_OBJ_UTILITY)
  set(RPATH_UTILITY "${SHARED_OBJ_UTILITY}" CACHE INTERNAL "" FORCE)
else()
  set(RPATH_UTILITY CACHE INTERNAL "" FORCE)
endif()

####### searching for doxygen related binaries (api documentation generator) #######
find_package(Doxygen)
if(DOXYGEN_FOUND)
  set(DOXYGEN_EXECUTABLE ${DOXYGEN_EXECUTABLE} CACHE INTERNAL "" FORCE)
  find_package(LATEX)
  set(MAKEINDEX_COMPILER ${MAKEINDEX_COMPILER} CACHE INTERNAL "" FORCE)
  set(LATEX_COMPILER ${LATEX_COMPILER} CACHE INTERNAL "" FORCE)
else()
  set(DOXYGEN_EXECUTABLE CACHE INTERNAL "" FORCE)
  set(MAKEINDEX_COMPILER CACHE INTERNAL "" FORCE)
  set(LATEX_COMPILER CACHE INTERNAL "" FORCE)
endif()

####### searching for jekyll (static site generator) #######
find_program(JEKYLL_PATH NAMES jekyll) #searching for the jekyll executable in standard paths
set(JEKYLL_EXECUTABLE ${JEKYLL_PATH} CACHE INTERNAL "" FORCE)
unset(JEKYLL_PATH CACHE)

####### searching for clang-format (code formatter) #######
find_program(CLANG_FORMAT_PATH clang-format)
set(CLANG_FORMAT_EXECUTABLE ${CLANG_FORMAT_PATH} CACHE INTERNAL "" FORCE)
unset(CLANG_FORMAT_PATH CACHE)

####### searching for make tool #######
find_program(PATH_TO_MAKE make)
set(MAKE_TOOL_EXECUTABLE ${PATH_TO_MAKE} CACHE INTERNAL "" FORCE)
unset(PATH_TO_MAKE CACHE)

# searching for bazel bazel
find_package(Bazel)
if(BAZEL_FOUND)
  set(BAZEL_EXECUTABLE ${BAZEL_EXECUTABLE} CACHE INTERNAL "" FORCE)
  set(BAZEL_VERSION ${BAZEL_VERSION} CACHE INTERNAL "" FORCE)
else()
  set(BAZEL_EXECUTABLE CACHE INTERNAL "" FORCE)
  set(BAZEL_VERSION CACHE INTERNAL "" FORCE)
endif()

####### searching for code coverage tools #######
set(GCOV_EXECUTABLE CACHE INTERNAL "" FORCE)
set(LCOV_EXECUTABLE CACHE INTERNAL "" FORCE)
set(GENHTML_EXECUTABLE CACHE INTERNAL "" FORCE)
if(NOT PID_CROSSCOMPILATION) #code coverage tools are not usable when crosscompiling (cannot run tests anyway)
  find_program( GCOV_PATH gcov ) # for generating coverage traces
  find_program( LCOV_PATH lcov ) # for generating HTML coverage reports
  find_program( GENHTML_PATH genhtml ) #for generating HTML
  if(GCOV_PATH AND LCOV_PATH AND GENHTML_PATH)
    set(GCOV_EXECUTABLE ${GCOV_PATH} CACHE INTERNAL "" FORCE)
    set(LCOV_EXECUTABLE ${LCOV_PATH} CACHE INTERNAL "" FORCE)
    set(GENHTML_EXECUTABLE ${GENHTML_PATH} CACHE INTERNAL "" FORCE)
  endif()
  unset(GCOV_PATH CACHE)
  unset(LCOV_PATH CACHE)
  unset(GENHTML_PATH CACHE)
endif()

####### searching for cppcheck (static checks tool) #######
# cppcheck app bundles on Mac OS X are GUI, we want command line only
set(_oldappbundlesetting ${CMAKE_FIND_APPBUNDLE})
set(CMAKE_FIND_APPBUNDLE NEVER)

#trying to find the cpp check executable
find_program(CPPCHECK_PATH NAMES cppcheck)
#trying to find the cppcheck-htmlreport executable
find_program(CPPCHECK_HTMLREPORT_PATH NAMES cppcheck-htmlreport)
if(CPPCHECK_PATH AND CPPCHECK_HTMLREPORT_PATH)
  set(CPPCHECK_EXECUTABLE ${CPPCHECK_PATH} CACHE INTERNAL "" FORCE)
  set(CPPCHECK_HTMLREPORT_EXECUTABLE ${CPPCHECK_HTMLREPORT_PATH} CACHE INTERNAL "" FORCE)
else()
  set(CPPCHECK_EXECUTABLE CACHE INTERNAL "" FORCE)
  set(CPPCHECK_HTMLREPORT_EXECUTABLE CACHE INTERNAL "" FORCE)
endif()
unset(CPPCHECK_PATH CACHE)
unset(CPPCHECK_HTMLREPORT_PATH CACHE)

# Restore original setting for appbundle finding
set(CMAKE_FIND_APPBUNDLE ${_oldappbundlesetting})
