
cmake_minimum_required(VERSION 2.4)
project(test_mpi C CXX Fortran)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR})
find_package(MPI)

set(input_file ${CMAKE_SOURCE_DIR}/openmpi_config_vars.cmake.in)
set(output_file ${CMAKE_BINARY_DIR}/openmpi_config_vars.cmake)
configure_file( ${input_file} ${output_file} @ONLY)
