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
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
include(Package_Definition NO_POLICY_SCOPE) # to be able to interpret description of external components
set(CMAKE_BUILD_TYPE Release)

# needed to parse adequately CMAKe variables passed to the script
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PROGRAM_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_INCLUDE_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_LIBRARY_PATH)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_PREFIXES)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_SUFFIXES)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PREFIX_PATH)

#including the adequate reference file
if(TARGET_FRAMEWORK AND (NOT TARGET_FRAMEWORK STREQUAL ""))# a framework is deployed
	# checks of the arguments
	include(ReferFramework${TARGET_FRAMEWORK} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
		message("[PID] ERROR : Framework name ${TARGET_FRAMEWORK} does not refer to any known framework in the workspace.")
		return()
	endif()
	# deployment of the framework
	if(EXISTS ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK} AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${TARGET_FRAMEWORK})
		message("[PID] ERROR : Source repository for framework ${TARGET_FRAMEWORK} already resides in the workspace.")
		return()
	endif()
	message("[PID] INFO : deploying PID framework ${TARGET_FRAMEWORK} in the workspace ...")
	deploy_PID_Framework(${TARGET_FRAMEWORK} "${VERBOSE_MODE}") #do the job
	return()

else()# a package deployment is required

	####################################################################
	##########################  CHECKS  ################################
	####################################################################

	#check of arguments
	if(NOT TARGET_PACKAGE OR TARGET_PACKAGE STREQUAL "")
		message("[PID] ERROR : You must specify the project to deploy: either a native package or an external package using package=<name of package> or a framework using framework=<name of framework> argument.")
		return()
	endif()

	#check if package is known
	set(is_external FALSE)
	include(Refer${TARGET_PACKAGE} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
		include(ReferExternal${TARGET_PACKAGE} OPTIONAL RESULT_VARIABLE EXT_REQUIRED_STATUS)
		if(EXT_REQUIRED_STATUS STREQUAL NOTFOUND)
			message("[PID] ERROR : Package name ${TARGET_PACKAGE} does not refer to any known package in the workspace (either native or external).")
			return()
		else()
			set(is_external TRUE)
		endif()
	endif()
	#after this previous commands packages references are known
	if(FORCE_REDEPLOY AND (FORCE_REDEPLOY STREQUAL "true" OR FORCE_REDEPLOY STREQUAL "TRUE"))
		set(redeploy TRUE)
	else()
		set(redeploy FALSE)
	endif()

	# check if redeployment asked
	if(TARGET_VERSION) # a specific version is targetted
		if(is_external AND EXISTS ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${TARGET_PACKAGE}/${TARGET_VERSION}
			AND IS_DIRECTORY ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${TARGET_PACKAGE}/${TARGET_VERSION})
			if(NOT redeploy)
				message("[PID] WARNING : ${TARGET_PACKAGE} binary version ${TARGET_VERSION} already resides in the workspace. Use force=true to force the redeployment.")
				return()
			else()

			endif()
		elseif( NOT is_external AND	EXISTS ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE}/${TARGET_VERSION}
			AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${TARGET_PACKAGE}/${TARGET_VERSION})
			if(NOT redeploy)
				message("[PID] WARNING : ${TARGET_PACKAGE} binary version ${TARGET_VERSION} already resides in the workspace. Use force=true to force the redeployment.")
				return()
			endif()
		endif()
	endif()

	# check in case when direct binary deployment asked
	set(references_loaded FALSE)
	if(NO_SOURCE AND (NO_SOURCE STREQUAL "true" OR NO_SOURCE STREQUAL "TRUE"))
		#if no source required than binary references must exist
		load_Package_Binary_References(REFERENCES_OK ${TARGET_PACKAGE})# now load the binary references of the package
		set(references_loaded TRUE)#memorize that references have been loaded
		if(NOT REFERENCES_OK)
			message("[PID] ERROR : Cannot find any reference to a binary version of ${TARGET_PACKAGE}. Aborting since no source deployment has been required.")
			return()
		endif()
		if(TARGET_VERSION) # a specific version is targetted
			exact_Version_Archive_Exists(${TARGET_PACKAGE} "${TARGET_VERSION}" EXIST)
			if(NOT EXIST)
				message("[PID] ERROR : A binary relocatable archive with version ${TARGET_VERSION} does not exist for package ${TARGET_PACKAGE}.  Aborting since no source deployment has been required.")
				return()
			endif()
		endif()
	endif()


		####################################################################
		##########################  OPERATIONS  ############################
		####################################################################

	## start package deployment process
	remove_Progress_File() #reset the build progress information (sanity action)
	begin_Progress(workspace NEED_REMOVE)

	if(TARGET_VERSION)
		if(is_external)#external package is deployed
			set(message_to_print "[PID] INFO : deploying external package ${TARGET_PACKAGE} (version ${TARGET_VERSION}) in the workspace ...")
		else()#native package is deployed
			message("")
			set(message_to_print "[PID] INFO : deploying native PID package ${TARGET_PACKAGE} (version ${TARGET_VERSION}) in the workspace ...")
		endif()
		#from here the operation can be theorically realized
		if(redeploy)#if a redeploy has been forced then first action is to uninstall
			clear_PID_Package(${TARGET_PACKAGE} ${TARGET_VERSION})
			if("${VERBOSE_MODE}" STREQUAL "true" OR "${VERBOSE_MODE}" STREQUAL "TRUE")
				message("[PID] INFO : package ${TARGET_PACKAGE} version ${TARGET_VERSION} has been uninstalled ...")
			endif()
		endif()
	else()
		if(is_external)#external package is deployed
			set(message_to_print "[PID] INFO : deploying external package ${TARGET_PACKAGE} (last version) in the workspace ...")
		else()#native package is deployed
			message("")
			set(message_to_print "[PID] INFO : deploying native package ${TARGET_PACKAGE} (last version) in the workspace ...")
		endif()
	endif()

	if(NOT references_loaded)# now load the binary references of the package
		load_Package_Binary_References(REFERENCES_OK ${TARGET_PACKAGE})
	endif()

	if(NO_SOURCE AND (NO_SOURCE STREQUAL "true" OR NO_SOURCE STREQUAL "TRUE"))
		set(can_use_source FALSE)
	else()
		set(can_use_source TRUE)
	endif()

	message("${message_to_print}")
	# now do the deployment
	if(is_external)#external package is deployed
		deploy_PID_External_Package(${TARGET_PACKAGE} "${TARGET_VERSION}" "${VERBOSE_MODE}" ${can_use_source} ${redeploy})
	else()#native package is deployed
		deploy_PID_Native_Package(${TARGET_PACKAGE} "${TARGET_VERSION}" "${VERBOSE_MODE}" ${can_use_source} ${redeploy})
	endif()

	## global management of the process
	message("--------------------------------------------")
	message("All packages deployed during this process : ")
	print_Deployed_Packages()
	finish_Progress(TRUE) #reset the build progress information
	message("--------------------------------------------")
endif()
