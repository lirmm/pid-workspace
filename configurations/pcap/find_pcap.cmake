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

found_PID_Configuration(pcap FALSE)

# - Find pcap installation
# Try to find libraries for pcap on UNIX systems. The following values are defined
#  PCAP_FOUND        - True if pcap is available
#  PCAP_LIBRARIES    - link against these to use pcap library
if (UNIX)

	find_path(PCAP_INCLUDE_PATH NAMES pcap.h PATH_SUFFIXES pcap)
	find_library(PCAP_LIB NAMES pcap libpcap)

	set(PCAP_INCLUDE_DIR ${PCAP_INCLUDE_PATH})
	set(PCAP_LIBRARY ${PCAP_LIB})
	unset(PCAP_INCLUDE_PATH CACHE)
	unset(PCAP_LIB CACHE)

	if(PCAP_INCLUDE_DIR AND PCAP_LIBRARY)

		#need to extract pcap version in file
		if( EXISTS "${PCAP_INCLUDE_DIR}/pcap.h")
		  file(READ ${PCAP_INCLUDE_DIR}/pcap.h PCAP_VERSION_FILE_CONTENTS)
		  string(REGEX MATCH "define PCAP_VERSION_MAJOR * +([0-9]+)"
		        PCAP_VERSION_MAJOR "${PCAP_VERSION_FILE_CONTENTS}")
		  string(REGEX REPLACE "define PCAP_VERSION_MAJOR * +([0-9]+)" "\\1"
		        PCAP_VERSION_MAJOR "${PCAP_VERSION_MAJOR}")
		  string(REGEX MATCH "define PCAP_VERSION_MINOR * +([0-9]+)"
		        PCAP_VERSION_MINOR "${PCAP_VERSION_FILE_CONTENTS}")
		  string(REGEX REPLACE "define PCAP_VERSION_MINOR * +([0-9]+)" "\\1"
		        PCAP_VERSION_MINOR "${PCAP_VERSION_MINOR}")
		  		  set(PCAP_VERSION ${PCAP_VERSION_MAJOR}.${PCAP_VERSION_MINOR})
		else()
			set(PCAP_VERSION "NO-VERSION-FOUND")
		endif()

		convert_PID_Libraries_Into_System_Links(PCAP_LIBRARY PCAP_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(PCAP_LIBRARY PCAP_LIBDIRS)

		found_PID_Configuration(pcap TRUE)
	else()
		message("[PID] ERROR : cannot find pcap library.")
	endif()
endif ()
