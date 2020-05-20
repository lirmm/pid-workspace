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


list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
load_Workspace_Info() #loading the current platform configuration

is_Repository_Connected(CONNECTED ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} official)
if(CONNECTED)
	get_Deployment_Unit_Repository_Address_In_Description(${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} OFFICIAL_URL OFFICIAL_PUBLIC_URL)
	get_Remotes_Address(${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} ADDR_OFFICIAL_FETCH ADDR_OFFICIAL_PUSH ADDR_ORIGIN_FETCH ADDR_ORIGIN_PUSH)
	if(NOT ADDR_OFFICIAL_PUSH STREQUAL OFFICIAL_URL
		 AND NOT ADDR_OFFICIAL_FETCH STREQUAL OFFICIAL_PUBLIC_URL)# the remote address does not match address specified in the package
		reconnect_Repository_Remote(${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} ${OFFICIAL_URL} "${OFFICIAL_PUBLIC_URL}" official)
		if(OFFICIAL_PUBLIC_URL)
			message("[PID] INFO : reconfiguing official repository address to fetch=${OFFICIAL_URL} push=${OFFICIAL_PUBLIC_URL}")
		else()
			message("[PID] INFO : reconfiguing official repository address to ${OFFICIAL_URL}")
		endif()
		if(ADDR_OFFICIAL STREQUAL ADDR_ORIGIN_FETCH)#origin was also official
			reconnect_Repository_Remote(${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} ${OFFICIAL_URL} "${OFFICIAL_PUBLIC_URL}" origin)
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
