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

include(${WORKSPACE_DIR}/pid/Workspace_Platforms_Info.cmake) #loading the current platform configuration


list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)

is_Package_Connected(CONNECTED ${TARGET_PACKAGE} official)
if(CONNECTED)
	get_Package_Repository_Address(${TARGET_PACKAGE} OFFICIAL_URL OFFICIAL_PUBLIC_URL)
	get_Remotes_Address(${TARGET_PACKAGE} ADDR_OFFICIAL ADDR_ORIGIN)
	if(NOT ADDR_OFFICIAL STREQUAL OFFICIAL_URL AND NOT ADDR_OFFICIAL STREQUAL OFFICIAL_PUBLIC_URL)# the remote address does not match address specified in the package
		reconnect_Repository_Remote(${TARGET_PACKAGE} ${OFFICIAL_URL} "${OFFICIAL_PUBLIC_URL}" official)
		if(OFFICIAL_PUBLIC_URL)
			message("[PID] INFO : reconfiguing official repository address to fetch=${OFFICIAL_URL} push=${OFFICIAL_PUBLIC_URL}")
		else()
			message("[PID] INFO : reconfiguing official repository address to ${OFFICIAL_URL}")
		endif()
		if(ADDR_OFFICIAL STREQUAL ADDR_ORIGIN)#origin was also affocial
			reconnect_Repository_Remote(${TARGET_PACKAGE} ${OFFICIAL_URL} "${OFFICIAL_PUBLIC_URL}" origin)
			if(OFFICIAL_PUBLIC_URL)
				message("[PID] INFO : reconfiguing origin repository address to fetch=${OFFICIAL_URL} push=${OFFICIAL_PUBLIC_URL} (keep it same as official)")
			else()
				message("[PID] INFO : reconfiguing official repository address to ${OFFICIAL_URL} (keep it same as official)")
			endif()
		endif()
	# else nothing to do
	endif()
# else nothing to do
endif()
