
cmake_minimum_required(VERSION 2.4)
project(test_freetype C CXX Fortran)

set(FREETYPE_NO_FIND_PACKAGE_CONFIG_FILE FALSE)
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR} ${CMAKE_MODULE_PATH})
find_package(Freetype REQUIRED)

set(input_file ${CMAKE_SOURCE_DIR}/freetype_config_vars.cmake.in)
set(output_file ${CMAKE_BINARY_DIR}/freetype_config_vars.cmake)
configure_file( ${input_file} ${output_file} @ONLY)
