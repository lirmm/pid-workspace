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

found_PID_Configuration(boost FALSE)
set(Boost_NO_BOOST_CMAKE ON)#avoid using CMake boost configuration file
set(components_to_search system filesystem ${boost_libraries})#boost_libraries used to check that components that user wants trully exist
list(REMOVE_DUPLICATES components_to_search)#using system and filesystem as these two libraries exist since early versions of boost
# set(CMAKE_PREFIX_PATH ${WORKSPACE_DIR}/configurations/boost)
set(CMAKE_MODULE_PATH ${WORKSPACE_DIR}/configurations/boost ${CMAKE_MODULE_PATH})
# if(EXISTS ${CMAKE_PREFIX_PATH})
# 	message("CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}")
# endif()
if(boost_version)
	find_package(Boost ${boost_version} EXACT QUIET COMPONENTS ${components_to_search})
else()
	find_package(Boost QUIET COMPONENTS ${components_to_search})
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
set(ALL_COMPS)
foreach(lib IN LISTS ALL_LIBS)
	if(lib MATCHES "^libboost_([^.]+)\\..*$")
		list(APPEND ALL_COMPS ${CMAKE_MATCH_1})
	endif()
endforeach()
list(REMOVE_DUPLICATES ALL_COMPS)
set(BOOST_VERSION ${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION}) #version has been detected
#Now relaunch the find script with the given components, to populate variables
find_package(Boost ${BOOST_VERSION} EXACT QUIET COMPONENTS ${ALL_COMPS})
if(NOT Boost_FOUND OR NOT Boost_LIBRARIES OR NOT Boost_LIBRARY_DIRS)#check failed : due to missing searched component !!
	unset(Boost_FOUND)
	return()
endif()
convert_PID_Libraries_Into_System_Links(Boost_LIBRARIES BOOST_LINKS)#getting good system links (with -l)
convert_PID_Libraries_Into_Library_Directories(Boost_LIBRARIES BOOST_LIBRARY_DIRS)
set(BOOST_COMPONENTS "${ALL_COMPS}")
found_PID_Configuration(boost TRUE)
unset(Boost_FOUND)
