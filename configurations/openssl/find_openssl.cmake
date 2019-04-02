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

found_PID_Configuration(openssl FALSE)

set(CMAKE_MODULE_PATH ${WORKSPACE_DIR}/configurations/openssl ${CMAKE_MODULE_PATH})
set(GENERATE_TARGETS FALSE)
if(openssl_version)
	find_package(OpenSSL ${openssl_version} EXACT QUIET)
else()
	find_package(OpenSSL QUIET)
endif()

if(NOT OPENSSL_FOUND)
	found_PID_Configuration(openssl FALSE)
endif()
set(OPENSSL_NICE_VERSION ${OPENSSL_VERSION_MAJOR}.${OPENSSL_VERSION_MINOR}.${OPENSSL_VERSION_FIX})
convert_PID_Libraries_Into_System_Links(OPENSSL_LIBRARIES OPENSSL_LINKS)#getting good system links (with -l)
convert_PID_Libraries_Into_Library_Directories(OPENSSL_LIBRARIES OPENSSL_LIBDIRS)


found_PID_Configuration(openssl TRUE)
