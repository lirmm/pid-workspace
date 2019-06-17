
cmake_minimum_required(VERSION 2.4)
project(test_hdf5 C CXX Fortran)

set(HDF5_NO_FIND_PACKAGE_CONFIG_FILE FALSE)
find_package(HDF5 COMPONENTS C  CXX Fortran HL)
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR})

set(input_file ${CMAKE_SOURCE_DIR}/hdf5_config_vars.cmake.in)
set(output_file ${CMAKE_BINARY_DIR}/hdf5_config_vars.cmake)
configure_file( ${input_file} ${output_file} @ONLY)
