
#########################################################################################
#	This file is part of the program PID						#
#  	Program description : build system supportting the PID methodology  		#
#  	Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique 	#
#	et de Microelectronique de Montpellier). All Right reserved.			#
#											#
#	This software is free software: you can redistribute it and/or modify		#
#	it under the terms of the CeCILL-C license as published by			#
#	the CEA CNRS INRIA, either version 1						#
#	of the License, or (at your option) any later version.				#
#	This software is distributed in the hope that it will be useful,		#
#	but WITHOUT ANY WARRANTY; without even the implied warranty of			#
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the			#
#	CeCILL-C License for more details.						#
#											#
#	You can find the complete license description on the official website 		#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################


###################################################################################
######## this is the script file to call to list a package's dependencies #########
###################################################################################
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system) # using systems scripts the workspace
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(${CMAKE_BINARY_DIR}/share/Dep${PROJECT_NAME}.cmake)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})

if(${CMAKE_BUILD_TYPE} MATCHES Release)
message("Release Mode")

elseif(${CMAKE_BUILD_TYPE} MATCHES Debug AND ADDITIONNAL_DEBUG_INFO)
message("Debug Mode")
endif()

message("target platform: ${TARGET_PLATFORM${VAR_SUFFIX}} (os=${TARGET_PLATFORM_OS${VAR_SUFFIX}}, arch=${TARGET_PLATFORM_ARCH${MODE_SUFFIX}})")
message("external dependencies:")

if(TARGET_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep IN ITEMS ${CURRENT_EXTERNAL_DEPENDENCY_${a_used_package}_VERSION${VAR_SUFFIX}})
		message("- ${dep}: ")
	endforeach()
endif()

if(TARGET_NATIVE_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep IN ITEMS ${CURRENT_NATIVE_DEPENDENCY_${a_used_package}_VERSION${VAR_SUFFIX}})
		message("- ${dep}: ")
	endforeach()
endif()






