
cmake_minimum_required(VERSION 2.4)
project(test_openmp C CXX Fortran)
cmake_policy(PUSH)
cmake_policy(SET CMP0012 NEW) # if() recognizes numbers and booleans

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR})
find_package(OpenMP)

set(input_file ${CMAKE_SOURCE_DIR}/openmp_config_vars.cmake.in)
set(output_file ${CMAKE_BINARY_DIR}/openmp_config_vars.cmake)
configure_file( ${input_file} ${output_file} @ONLY)
cmake_policy(POP)
