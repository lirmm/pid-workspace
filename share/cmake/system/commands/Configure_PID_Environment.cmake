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

function(clean_Build_Tree workspace)
file(GLOB ALL_FILES "${workspace}/pid/*")
if(ALL_FILES)
	foreach(a_file IN LISTS ALL_FILES)
		if(IS_DIRECTORY ${a_file})
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${a_file})
		elseif(NOT ${a_file} STREQUAL "${workspace}/pid/.gitignore")
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${a_file})
		endif()
	endforeach()
endif()
endfunction(clean_Build_Tree)



### script used to configure the environment to another one

#first check that commmand parameters are not passed as environment variables

if(NOT TARGET_ENVIRONMENT AND ENV{environment})
	set(TARGET_ENVIRONMENT $ENV{environment} CACHE INTERNAL "")
endif()
if(NOT TARGET_VERSION AND ENV{version})
	set(TARGET_VERSION $ENV{version} CACHE INTERNAL "")
endif()

#second: do the job

if(TARGET_ENVIRONMENT) # checking if the target environment has to change
	if(TARGET_ENVIRONMENT STREQUAL "python")
			# reconfigure the pid workspace
			if(TARGET_VERSION)
				if(TARGET_VERSION STREQUAL "default")
					message("[PID] INFO : changing to default python version ... ")
					execute_process(COMMAND ${CMAKE_COMMAND} -DUSE_PYTHON_VERSION= ${WORKSPACE_DIR}
							WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
				else()
					message("[PID] INFO : changing to python version ${TARGET_VERSION} ... ")
					execute_process(COMMAND ${CMAKE_COMMAND} -DUSE_PYTHON_VERSION=${TARGET_VERSION} ${WORKSPACE_DIR}
						WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
				endif()
			endif()

	elseif(	TARGET_ENVIRONMENT STREQUAL "${CURRENT_ENVIRONMENT}"
		OR (NOT CURRENT_ENVIRONMENT AND TARGET_ENVIRONMENT STREQUAL "host"))
		message("[PID] INFO : the target environment ${TARGET_ENVIRONMENT} is already the current environment of the workspace.")
	elseif(TARGET_ENVIRONMENT STREQUAL "host") # going back to default environment
		message("[PID] INFO : changing to default host environment")
		#removing all cmake or pid configuration files
		clean_Build_Tree(${WORKSPACE_DIR})

		# reconfigure the pid workspace
		execute_process(COMMAND ${CMAKE_COMMAND} -DCURRENT_ENVIRONMENT= ${WORKSPACE_DIR}
				WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)

	elseif(EXISTS ${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT}/PID_Environment_Description.cmake)# selecting a specific environment
		include(${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT}/PID_Environment_Description.cmake)
		if(PID_ENVIRONMENT_NOT_AVAILABLE)#check to be sure that the environment can be used
			return()
		endif()
		message("[PID] INFO : changing to environment ${TARGET_ENVIRONMENT}")

		#removing all cmake or pid configuration files
		clean_Build_Tree(${WORKSPACE_DIR})

		# reconfigure the pid workspace
		execute_process(COMMAND ${CMAKE_COMMAND} -DCURRENT_ENVIRONMENT=${TARGET_ENVIRONMENT} -DCMAKE_TOOLCHAIN_FILE=${WORKSPACE_DIR}/environments/${TARGET_ENVIRONMENT}/PID_Toolchain.cmake ${WORKSPACE_DIR} WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
	else()
		message("[PID] ERROR : the target environment ${TARGET_ENVIRONMENT} does not refer to a known environment in the workspace.")
	endif()
else()
	message("[PID] ERROR : you must set the name of the target environment using environment=*name of the environment folder in ${WORKSPACE_DIR}/environments/*. You cas use the value python to set the python version (using version=) in use and/or the python path (using register=).")
endif()
