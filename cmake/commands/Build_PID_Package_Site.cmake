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

### script used to build the site using jekyll

#1) copy files from src to the adequate build folder

set(PATH_TO_SITE ${WORKSPACE_DIR}/sites/packages/${TARGET_PACKAGE})
set(PATH_TO_SITE_SRC ${PATH_TO_SITE}/src)
set(PATH_TO_SITE_JEKYLL ${PATH_TO_SITE}/build/to_generate)
set(PATH_TO_SITE_RESULT ${PATH_TO_SITE}/build/generated)
file(REMOVE ${PATH_TO_SITE_RESULT})

message("checking ${PATH_TO_SITE_SRC}/pages")
set(list_of_folders_to_copy)
if(EXISTS ${PATH_TO_SITE_SRC}/api_doc)
  list(APPEND list_of_folders_to_copy ${PATH_TO_SITE_SRC}/api_doc)
endif()
if(EXISTS ${PATH_TO_SITE_SRC}/coverage)
  list(APPEND list_of_folders_to_copy ${PATH_TO_SITE_SRC}/coverage)
endif()
if(EXISTS ${PATH_TO_SITE_SRC}/pages)
  list(APPEND list_of_folders_to_copy ${PATH_TO_SITE_SRC}/pages)
endif()
if(EXISTS ${PATH_TO_SITE_SRC}/static_checks)
  list(APPEND list_of_folders_to_copy ${PATH_TO_SITE_SRC}/static_checks)
endif()
if(EXISTS ${PATH_TO_SITE_SRC}/_binaries)
  list(APPEND list_of_folders_to_copy ${PATH_TO_SITE_SRC}/_binaries)
endif()
if(EXISTS ${PATH_TO_SITE_SRC}/_data)
  list(APPEND list_of_folders_to_copy ${PATH_TO_SITE_SRC}/_data)
endif()
if(EXISTS ${PATH_TO_SITE_SRC}/_posts)
  list(APPEND list_of_folders_to_copy ${PATH_TO_SITE_SRC}/_posts)
endif()
if(list_of_folders_to_copy)
  file(COPY ${list_of_folders_to_copy} DESTINATION ${PATH_TO_SITE_JEKYLL})
  #2) build site with jekyll
  execute_process(COMMAND ${JEKYLL_EXECUTABLE} build -d ${PATH_TO_SITE_RESULT} WORKING_DIRECTORY ${PATH_TO_SITE_JEKYLL})
else()
  message("[PID] WARNING: nothing to publish in static site of package ${TARGET_PACKAGE}")
endif()
