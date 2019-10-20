cmake_minimum_required(VERSION 3.0.2)
project(test_fortran)

include(${WORKSPACE_DIR}/pid/Workspace_Platforms_Info.cmake)

if(NOT CMAKE_Fortran_COMPILER)
  message(FATAL_ERROR "")
endif()
