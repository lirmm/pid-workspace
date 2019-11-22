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

found_PID_Configuration(curl FALSE)
find_path(CURL_INCLUDE_DIR NAMES curl/curl.h)
set(CURL_INC ${CURL_INCLUDE_DIR})
unset(CURL_INCLUDE_DIR CACHE)#avoid caching those variable to avoid noise in cache
if(CURL_INC)
	set(CURL_VERSION_STRING)
	foreach(_curl_version_header curlver.h curl.h)
    if(EXISTS "${CURL_INC}/curl/${_curl_version_header}")
      file(STRINGS "${CURL_INC}/curl/${_curl_version_header}" curl_version_str REGEX "^#define[\t ]+LIBCURL_VERSION[\t ]+\".*\"")
      string(REGEX REPLACE "^#define[\t ]+LIBCURL_VERSION[\t ]+\"([^\"]*)\".*" "\\1" CURL_VERSION_STRING "${curl_version_str}")
      unset(curl_version_str)
      break()
    endif()
  endforeach()
endif()

find_PID_Library_In_Linker_Order("curl;curllib;libcurl_imp;curllib_static;libcurl" USER CURL_LIB CURL_SONAME)

if(CURL_INC AND CURL_LIB AND CURL_VERSION_STRING)
	#OK everything detected
	convert_PID_Libraries_Into_System_Links(CURL_LIB CURL_LINKS)#getting good system links (with -l)
	convert_PID_Libraries_Into_Library_Directories(CURL_LIB CURL_LIBDIR)
	extract_Symbols_From_PID_Libraries(CURL_LIB "CURL_OPENSSL_" CURL_SYMBOLS)
	found_PID_Configuration(curl TRUE)
else()
	message("[PID] ERROR : cannot find CURL library (found include=${CURL_INC}, library=${CURL_LIB}, version=${CURL_VERSION_STRING}).")
endif()
