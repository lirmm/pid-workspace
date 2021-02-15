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
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
load_Workspace_Info() #loading the current platform configuration
if(DEPENDENT_PACKAGES)
	set(remaining_packs ${DEPENDENT_PACKAGES})
	while(remaining_packs)
		list(GET remaining_packs 0 dep_pack)
		list(GET remaining_packs 1 dep_version)
		list(REMOVE_AT remaining_packs 0 1)
		package_Dependency_Needs_To_Be_Rebuilt(NEEDS_BUILD ${dep_pack} ${dep_version} ${PACKAGE_LAUCHING_BUILD})
		if(NEEDS_BUILD)# if not built modifications
			message("[PID] INFO : Building ${dep_pack} ...")
			execute_process (COMMAND ${CMAKE_MAKE_PROGRAM} build
											 WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${dep_pack}/build)
			message("[PID] INFO : ${dep_pack} built.")
		endif()
	endwhile()
else()
	message("[PID] INTERNAL ERROR : no package dependency to build !")
endif()
