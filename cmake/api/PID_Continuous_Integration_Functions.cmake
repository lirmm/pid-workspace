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

##########################################################################################
############################ Guard for optimization of configuration process #############
##########################################################################################
if(PID_CONTINUOUS_INTEGRATION_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_CONTINUOUS_INTEGRATION_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_CI_Variables| replace:: ``reset_CI_Variables``
#  .. _reset_CI_Variables:
#
#  reset_CI_Variables
#  ------------------
#
#   .. command:: reset_CI_Variables()
#
#    Reset the cached variables used in current project continuous integration.
#
function(reset_CI_Variables)
		set(${PROJECT_NAME}_ALLOWED_CI_PLATFORMS CACHE INTERNAL "")
endfunction(reset_CI_Variables)

#.rst:
#
# .. ifmode:: internal
#
#  .. |allow_CI_For_Platform| replace:: ``allow_CI_For_Platform``
#  .. _allow_CI_For_Platform:
#
#  allow_CI_For_Platform
#  ---------------------
#
#   .. command:: allow_CI_For_Platform()
#
#    Add a platform for which the CI will take place.
#
#      :platform: The target platform.
#
function(allow_CI_For_Platform platform)
  list(FIND ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS ${platform} INDEX)
  if(INDEX EQUAL -1)##append the patform only if not already defined
	   set(${PROJECT_NAME}_ALLOWED_CI_PLATFORMS ${${PROJECT_NAME}_ALLOWED_CI_PLATFORMS} ${platform} CACHE INTERNAL "")
  endif()
endfunction(allow_CI_For_Platform)

#########################################################################################
############################# CI for native packges #####################################
#########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |verify_Package_CI_Content| replace:: ``verify_Package_CI_Content``
#  .. _verify_Package_CI_Content:
#
#  verify_Package_CI_Content
#  -------------------------
#
#   .. command:: verify_Package_CI_Content()
#
#    Verify that package CI scripts exist in package repository and perform corrective action otherwise.
#
function(verify_Package_CI_Content)

if(NOT EXISTS ${CMAKE_SOURCE_DIR}/share/ci)#the ci folder is missing
	file(COPY ${WORKSPACE_DIR}/cmake/patterns/packages/package/share/ci DESTINATION ${CMAKE_SOURCE_DIR}/share)
	message("[PID] INFO : creating the ci folder in package ${PROJECT_NAME} repository")
elseif(NOT IS_DIRECTORY ${CMAKE_SOURCE_DIR}/share/ci)#the ci folder is missing
	file(REMOVE ${CMAKE_SOURCE_DIR}/share/ci)
	message("[PID] WARNING : removed file ${CMAKE_SOURCE_DIR}/share/ci in package ${PROJECT_NAME}")
	file(COPY ${WORKSPACE_DIR}/cmake/patterns/packages/package/share/ci DESTINATION ${CMAKE_SOURCE_DIR}/share)
	message("[PID] INFO : creating the ci folder in package ${PROJECT_NAME} repository")
else() #updating these files by silently replacing the ci folder
	file(REMOVE_RECURSE ${CMAKE_SOURCE_DIR}/share/ci)
	file(COPY ${WORKSPACE_DIR}/cmake/patterns/packages/package/share/ci DESTINATION ${CMAKE_SOURCE_DIR}/share)
endif()
endfunction(verify_Package_CI_Content)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_CI_Config_File| replace:: ``generate_Package_CI_Config_File``
#  .. _generate_Package_CI_Config_File:
#
#  generate_Package_CI_Config_File
#  -------------------------------
#
#   .. command:: generate_Package_CI_Config_File()
#
#    Generate the configuration file that is used to manage current package CI (gitlab-ci.yml file).
#
function(generate_Package_CI_Config_File)

if(NOT ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS)
	if(EXISTS ${CMAKE_SOURCE_DIR}/.gitlab-ci.yml)
		file(REMOVE ${CMAKE_SOURCE_DIR}/.gitlab-ci.yml)#remove the file because CI is allowed for no platform
	endif()
	return() #no CI to run so no need to generate the file
else()
  list(GET ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS 0 PACKAGE_CI_MAIN_PLATFORM)
endif()

verify_Package_CI_Content()

# determine general informations about package content
if(NOT ${PROJECT_NAME}_COMPONENTS_LIBS)
	set(PACKAGE_CI_HAS_LIBRARIES "false")
else()
	set(PACKAGE_CI_HAS_LIBRARIES "true")
endif()

# are there tests and examples ?
set(PACKAGE_CI_HAS_TESTS "false")
set(PACKAGE_CI_HAS_EXAMPLES "false")
foreach(component IN LISTS ${PROJECT_NAME}_DECLARED_COMPS)#looking into all declared components
	if(${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE")
		set(PACKAGE_CI_HAS_EXAMPLES "true")
	elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
		set(PACKAGE_CI_HAS_TESTS "true")
	endif()
endforeach()

#is there a static site defined for the project ?
check_Documentation_Site_Generated(IS_GENERATED)
if(NOT IS_GENERATED)# CI may generate site during CI but it is not mandatory
	set(PACKAGE_CI_HAS_SITE "false")
	set(PACKAGE_CI_PUBLISH_BINARIES "false")# if no site then no repository for binaries and no place where to show developper info
	set(PACKAGE_CI_PUBLISH_DEV_INFO "false")
else()
	set(PACKAGE_CI_HAS_SITE "true")#CI also generate and publish site (using gitlab pages)
	if(${PROJECT_NAME}_BINARIES_AUTOMATIC_PUBLISHING)
		set(PACKAGE_CI_PUBLISH_BINARIES "true")
	else()
		set(PACKAGE_CI_PUBLISH_BINARIES "false")
	endif()
	if(${PROJECT_NAME}_DEV_INFO_AUTOMATIC_PUBLISHING)
		set(PACKAGE_CI_PUBLISH_DEV_INFO "true")
	else()
		set(PACKAGE_CI_PUBLISH_DEV_INFO "false")
	endif()
endif()

set(PACKAGE_CI_CONTRIBUTION_SPACES)
get_Package_All_Non_Official_Contribtion_Spaces_In_Use(LIST_OF_CS ${PROJECT_NAME} NATIVE "${TARGET_CONTRIBUTION_SPACE}" ${CMAKE_BUILD_TYPE})
foreach(cs IN LISTS LIST_OF_CS)
  get_Update_Remote_Of_Contribution_Space(UPDATE_REMOTE ${cs})
  list(APPEND PACKAGE_CI_CONTRIBUTION_SPACES ${cs} ${UPDATE_REMOTE})
endforeach()

#configuring pattern file
set(TARGET_TEMPORARY_FILE ${CMAKE_BINARY_DIR}/.gitlab-ci.yml)
configure_file(${WORKSPACE_DIR}/cmake/patterns/packages/.gitlab-ci.yml.in ${TARGET_TEMPORARY_FILE} @ONLY)#adding the gitlab-ci configuration file to the repository

#now need to complete the configuration file with platform and environment related information
# managing restriction on platforms used for CI and generating CI config file
foreach(platform IN LISTS ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS)
	add_CI_Config_File_Runner_Selection_By_Platform(${TARGET_TEMPORARY_FILE} ${platform})
endforeach()
file(APPEND ${TARGET_TEMPORARY_FILE} "\n\n############ jobs definition, by platform #############\n\n")
foreach(platform IN LISTS ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS)
	add_CI_Config_File_Jobs_Definitions_By_Platform(${TARGET_TEMPORARY_FILE} ${platform})
endforeach()

file(COPY ${TARGET_TEMPORARY_FILE} DESTINATION ${CMAKE_SOURCE_DIR})
endfunction(generate_Package_CI_Config_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_CI_Config_File_Runner_Selection_By_Platform| replace:: ``add_CI_Config_File_Runner_Selection_By_Platform``
#  .. _add_CI_Config_File_Runner_Selection_By_Platform:
#
#  add_CI_Config_File_Runner_Selection_By_Platform
#  -----------------------------------------------
#
#   .. command:: add_CI_Config_File_Runner_Selection_By_Platform(configfile platform)
#
#    Subsidiary CI generation function used to write how a runner is selected according to a given platform
#
#      :configfile: The path to the CI configuration file to write in.
#      :platform: the platform identifier.
#
function(add_CI_Config_File_Runner_Selection_By_Platform configfile platform)
file(APPEND ${configfile} "#platform ${platform}\n\n")
file(APPEND ${configfile} ".selection_platform_${platform}_: &selection_platform_${platform}\n    tags:\n        - pid\n        - ${platform}\n\n")
endfunction(add_CI_Config_File_Runner_Selection_By_Platform)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_CI_Config_File_Jobs_Definitions_By_Platform| replace:: ``add_CI_Config_File_Jobs_Definitions_By_Platform``
#  .. _add_CI_Config_File_Jobs_Definitions_By_Platform:
#
#  add_CI_Config_File_Jobs_Definitions_By_Platform
#  -----------------------------------------------
#
#   .. command:: add_CI_Config_File_Jobs_Definitions_By_Platform(configfile platform)
#
#    Subsidiary CI generation function used to write how a runner is selected according to a given platform, for all jabs of the pid CI pipeline
#
#      :configfile: The path to the CI configuration file to write in.
#      :platform: the platform identifier.
#
function(add_CI_Config_File_Jobs_Definitions_By_Platform configfile platform)
file(APPEND ${configfile} "#pipeline generated for platform: ${platform}\n\n")

file(APPEND ${configfile} "build_integration_${platform}:\n  <<: *build_integration\n  <<: *selection_platform_${platform}\n\n")
file(APPEND ${configfile} "build_release_${platform}:\n  <<: *build_release\n  <<: *selection_platform_${platform}\n\n")
endfunction(add_CI_Config_File_Jobs_Definitions_By_Platform)

#########################################################################################
############################ CI for external packages wrappers ##########################
#########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |verify_Wrapper_CI_Content| replace:: ``verify_Wrapper_CI_Content``
#  .. _verify_Wrapper_CI_Content:
#
#  verify_Wrapper_CI_Content
#  -------------------------
#
#   .. command:: verify_Wrapper_CI_Content()
#
#    Verify that wrapper CI scripts exist in wrapper repository and perform corrective action otherwise.
#
function(verify_Wrapper_CI_Content)

if(NOT EXISTS ${CMAKE_SOURCE_DIR}/share/ci)#the ci folder is missing
	file(COPY ${WORKSPACE_DIR}/cmake/patterns/wrappers/package/share/ci DESTINATION ${CMAKE_SOURCE_DIR}/share)
	message("[PID] INFO : creating the ci folder in wrapper ${PROJECT_NAME} repository")
elseif(NOT IS_DIRECTORY ${CMAKE_SOURCE_DIR}/share/ci)#the ci folder is missing
	file(REMOVE ${CMAKE_SOURCE_DIR}/share/ci)
	message("[PID] WARNING : removed file ${CMAKE_SOURCE_DIR}/share/ci in wrapper ${PROJECT_NAME}")
	file(COPY ${WORKSPACE_DIR}/cmake/patterns/wrappers/package/share/ci DESTINATION ${CMAKE_SOURCE_DIR}/share)
	message("[PID] INFO : creating the ci folder in wrapper ${PROJECT_NAME} repository")
else() #updating these files by silently replacing the ci folder
	file(REMOVE_RECURSE ${CMAKE_SOURCE_DIR}/share/ci)
	file(COPY ${WORKSPACE_DIR}/cmake/patterns/wrappers/package/share/ci DESTINATION ${CMAKE_SOURCE_DIR}/share)
endif()
endfunction(verify_Wrapper_CI_Content)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_CI_Config_File_Jobs_Definitions_By_Platform_For_Wrapper| replace:: ``add_CI_Config_File_Jobs_Definitions_By_Platform_For_Wrapper``
#  .. _add_CI_Config_File_Jobs_Definitions_By_Platform_For_Wrapper:
#
#  add_CI_Config_File_Jobs_Definitions_By_Platform_For_Wrapper
#  -----------------------------------------------------------
#
#   .. command:: add_CI_Config_File_Jobs_Definitions_By_Platform_For_Wrapper(configfile platform)
#
#    Subsidiary CI generation function used to write how a runner is selected according to a given platform, for all jobs of the pid CI pipeline
#
#      :configfile: The path to the CI configuration file to write in.
#      :platform: the platform identifier.
#
function(add_CI_Config_File_Jobs_Definitions_By_Platform_For_Wrapper configfile platform)
file(APPEND ${configfile} "#pipeline generated for platform: ${platform}\n\n")
file(APPEND ${configfile} "build_wrapper_${platform}:\n <<: *build_wrapper\n <<: *selection_platform_${platform}\n\n")
endfunction(add_CI_Config_File_Jobs_Definitions_By_Platform_For_Wrapper)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Wrapper_CI_Config_File| replace:: ``generate_Wrapper_CI_Config_File``
#  .. _generate_Wrapper_CI_Config_File:
#
#  generate_Wrapper_CI_Config_File
#  -------------------------------
#
#   .. command:: generate_Wrapper_CI_Config_File()
#
#    Generate the configuration file that is used to manage current wrapper CI (gitlab-ci.yml file).
#
function(generate_Wrapper_CI_Config_File)

if(NOT ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS)
	if(EXISTS ${CMAKE_SOURCE_DIR}/.gitlab-ci.yml)
		file(REMOVE ${CMAKE_SOURCE_DIR}/.gitlab-ci.yml)#remove the file as CI is allowed for no platform
	endif()
	return() #no CI to run so no need to generate the file
else()
  list(GET ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS 0 PACKAGE_CI_MAIN_PLATFORM)
endif()

verify_Wrapper_CI_Content()

#is there a static site defined for the project ?
if(NOT ${PROJECT_NAME}_FRAMEWORK AND NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS)
	set(PACKAGE_CI_HAS_SITE "false")
	set(PACKAGE_CI_PUBLISH_BINARIES "false")
else()
	set(PACKAGE_CI_HAS_SITE "true")
	if(${PROJECT_NAME}_BINARIES_AUTOMATIC_PUBLISHING)
		set(PACKAGE_CI_PUBLISH_BINARIES "true")
	else()
		set(PACKAGE_CI_PUBLISH_BINARIES "false")
	endif()
endif()

set(PACKAGE_CI_CONTRIBUTION_SPACES)
get_Wrapper_All_Non_Official_Contribtion_Spaces_In_Use(LIST_OF_CS ${PROJECT_NAME} "${TARGET_CONTRIBUTION_SPACE}")
foreach(cs IN LISTS LIST_OF_CS)
  get_Update_Remote_Of_Contribution_Space(UPDATE_REMOTE ${cs})
  list(APPEND PACKAGE_CI_CONTRIBUTION_SPACES ${cs} ${UPDATE_REMOTE})
endforeach()

#configuring pattern file
set(TARGET_TEMPORARY_FILE ${CMAKE_BINARY_DIR}/.gitlab-ci.yml)
configure_file(${WORKSPACE_DIR}/cmake/patterns/wrappers/.gitlab-ci.yml.in ${TARGET_TEMPORARY_FILE} @ONLY)#adding the gitlab-ci configuration file to the repository

#now need to complete the configuration file with platform and environment related information
# managing restriction on platforms used for CI and generating CI config file
foreach(platform IN LISTS ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS)
	add_CI_Config_File_Runner_Selection_By_Platform(${TARGET_TEMPORARY_FILE} ${platform})
endforeach()
file(APPEND ${TARGET_TEMPORARY_FILE} "\n\n############ jobs definition, by platform #############\n\n")
foreach(platform IN LISTS ${PROJECT_NAME}_ALLOWED_CI_PLATFORMS)
	add_CI_Config_File_Jobs_Definitions_By_Platform_For_Wrapper(${TARGET_TEMPORARY_FILE} ${platform})
endforeach()

file(COPY ${TARGET_TEMPORARY_FILE} DESTINATION ${CMAKE_SOURCE_DIR})
endfunction(generate_Wrapper_CI_Config_File)
