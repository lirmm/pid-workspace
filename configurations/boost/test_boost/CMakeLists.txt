
cmake_minimum_required(VERSION 2.4)
project(test_boost C CXX Fortran)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR})
set(Boost_NO_BOOST_CMAKE ON)#avoid using CMake boost configuration file

if(BOOST_VERSION_TO_SEARCH)
	find_package(Boost ${BOOST_VERSION_TO_SEARCH} EXACT QUIET COMPONENTS ${BOOST_COMPONENTS_TO_SEARCH})
else()
	find_package(Boost QUIET COMPONENTS ${BOOST_COMPONENTS_TO_SEARCH})
endif()

if(NOT Boost_FOUND OR NOT Boost_LIBRARIES OR NOT Boost_LIBRARY_DIRS)#check failed : due to missing searched component !!
	unset(Boost_FOUND)
	return()
endif()

#Boost_LIBRARIES only contains libraries that have been queried, which is not sufficient to manage external package as SYSTEM in a clean way
#Need to get all binary libraries depending on the version, anytime boost is found ! Search them from location Boost_LIBRARY_DIRS
foreach(dir IN LISTS Boost_LIBRARY_DIRS)
	file(GLOB libs RELATIVE ${dir} "${dir}/libboost_*")
	if(libs)
		list(APPEND ALL_LIBS ${libs})
	endif()
endforeach()
set(ALL_BOOST_COMPS)
foreach(lib IN LISTS ALL_LIBS)
	if(lib MATCHES "^libboost_([^.]+)\\..*$")
		list(APPEND ALL_BOOST_COMPS ${CMAKE_MATCH_1})
	endif()
endforeach()

list(REMOVE_DUPLICATES ALL_BOOST_COMPS)

set(BOOST_VERSION ${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION}) #version has been detected
#Now relaunch the find script with the given components, to populate variables
find_package(Boost ${BOOST_VERSION} EXACT QUIET COMPONENTS ${ALL_BOOST_COMPS})

if(NOT Boost_FOUND OR NOT Boost_LIBRARIES OR NOT Boost_LIBRARY_DIRS)#check failed : due to missing searched component !!
	unset(Boost_FOUND)
	return()
endif()

set(input_file ${CMAKE_SOURCE_DIR}/boost_config_vars.cmake.in)
set(output_file ${CMAKE_BINARY_DIR}/boost_config_vars.cmake)
configure_file( ${input_file} ${output_file} @ONLY)
