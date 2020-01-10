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

### script used to serve the package static site using jekyll

set(PATH_TO_PACKAGE ${WORKSPACE_DIR}/sites/packages/${TARGET_PACKAGE})
set(PATH_TO_PACKAGE_RESULT ${PATH_TO_PACKAGE}/build/generated)

if(EXISTS ${PATH_TO_PACKAGE_RESULT} AND IS_DIRECTORY ${PATH_TO_PACKAGE_RESULT})
	if(SITE_BASE_URL)
		execute_process(COMMAND ${JEKYLL_EXECUTABLE} serve --baseurl /${SITE_BASE_URL} WORKING_DIRECTORY ${PATH_TO_PACKAGE_RESULT})
	else()
		execute_process(COMMAND ${JEKYLL_EXECUTABLE} serve WORKING_DIRECTORY ${PATH_TO_PACKAGE_RESULT})
	endif()
else()
	message("[PID] ERROR: nothing to serve, no static site found !")
endif()
