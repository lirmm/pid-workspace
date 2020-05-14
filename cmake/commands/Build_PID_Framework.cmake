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

### script used to build the framework using jekyll

#1) copy files from src to the adequate build folder

set(PATH_TO_FRAMEWORK ${FRAMEWORK_PATH})
set(PATH_TO_FRAMEWORK_SRC ${PATH_TO_FRAMEWORK}/src)
set(PATH_TO_FRAMEWORK_JEKYLL ${PATH_TO_FRAMEWORK}/build/to_generate)
set(PATH_TO_FRAMEWORK_RESULT ${PATH_TO_FRAMEWORK}/build/generated)

file(REMOVE ${PATH_TO_FRAMEWORK_RESULT})
file(COPY ${PATH_TO_FRAMEWORK_SRC}/assets ${PATH_TO_FRAMEWORK_SRC}/_packages ${PATH_TO_FRAMEWORK_SRC}/_external ${PATH_TO_FRAMEWORK_SRC}/pages ${PATH_TO_FRAMEWORK_SRC}/_posts DESTINATION ${PATH_TO_FRAMEWORK_JEKYLL} NO_SOURCE_PERMISSIONS)

set(INCREMENTAL_BUILD_OPTION --incremental)
if(NOT INCREMENTAL_BUILD OR (DEFINED ENV{incremental} AND NOT $ENV{incremental}))
    set(INCREMENTAL_BUILD_OPTION)
endif()

#2) build site with jekyll
execute_process(COMMAND ${JEKYLL_EXECUTABLE} build ${INCREMENTAL_BUILD_OPTION} -d ${PATH_TO_FRAMEWORK_RESULT} WORKING_DIRECTORY ${PATH_TO_FRAMEWORK_JEKYLL})

#3) finally copy assets "as is" from "to_generate" folder to "generated" folder (to ensure that no jekyll processing removed some files)
file(COPY ${PATH_TO_FRAMEWORK_JEKYLL}/assets DESTINATION ${PATH_TO_FRAMEWORK_RESULT} NO_SOURCE_PERMISSIONS)
