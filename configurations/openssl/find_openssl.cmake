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
	return()
endif()
set(OPENSSL_LIBS ${OPENSSL_LIBRARIES})
unset(OPENSSL_LIBRARIES CACHE)
unset(OPENSSL_SSL_LIBRARY CACHE)
unset(OPENSSL_CRYPTO_LIBRARY CACHE)
set(OPENSSL_INCS ${OPENSSL_INCLUDE_DIR})
unset(OPENSSL_INCLUDE_DIR CACHE)
set(OPENSSL_NICE_VERSION ${OPENSSL_VERSION_MAJOR}.${OPENSSL_VERSION_MINOR}.${OPENSSL_VERSION_FIX})
unset(OPENSSL_VERSION_MAJOR CACHE)
unset(OPENSSL_VERSION_MINOR CACHE)
unset(OPENSSL_VERSION_FIX CACHE)
unset(OPENSSL_VERSION CACHE)

convert_PID_Libraries_Into_System_Links(OPENSSL_LIBS OPENSSL_LINKS)#getting good system links (with -l)
convert_PID_Libraries_Into_Library_Directories(OPENSSL_LIBS OPENSSL_LIBDIRS)
extract_Soname_From_PID_Libraries(OPENSSL_LIBS OPENSSL_SONAME)
extract_Symbols_From_PID_Libraries(OPENSSL_LIBS "OPENSSL_" OPENSSL_SYMBOLS)
found_PID_Configuration(openssl TRUE)
