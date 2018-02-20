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


list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration

if(DEPENDENT_PACKAGES)
	SEPARATE_ARGUMENTS(DEPENDENT_PACKAGES)
	foreach(dep_pack IN LISTS DEPENDENT_PACKAGES)
		package_Already_Built(IS_BUILT ${dep_pack} ${PACKAGE_LAUCHING_BUILD})
		if(NOT IS_BUILT)# if not built modifications
			get_Repository_Current_Branch(BRANCH_NAME ${WORKSPACE_DIR}/packages/${dep_pack})
			if(BRANCH_NAME AND NOT BRANCH_NAME STREQUAL "master")
				#if on integration branch or another feature specific branch (not on master or on an "isolated" commit like one pointed by a tag)
				message("[PID] INFO : Building ${dep_pack} ...")
				execute_process (COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${dep_pack}/build ${CMAKE_MAKE_PROGRAM} build)
				message("[PID] INFO : ${dep_pack} built.")
			endif()
		endif()
	endforeach()
else()
	message("[PID] ERROR : no package to build !")
endif()
