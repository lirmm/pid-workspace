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
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/find)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)
include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)
include(Package_Definition NO_POLICY_SCOPE) # to be able to interpret description of external components
load_Current_Platform() #loading the current platform configuration

set(CMAKE_BUILD_TYPE Release)

# needed to parse adequately CMAKe variables passed to the script
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PROGRAM_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_INCLUDE_PATH)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_LIBRARY_PATH)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_PREFIXES)
SEPARATE_ARGUMENTS(CMAKE_FIND_LIBRARY_SUFFIXES)
SEPARATE_ARGUMENTS(CMAKE_SYSTEM_PREFIX_PATH)

#first check that commmand parameters are not passed as environment variables
if(NOT DEPLOYED_PACKAGE AND DEFINED ENV{package})
	set(DEPLOYED_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()

if(NOT DEPLOYED_FRAMEWORK AND DEFINED ENV{framework})
	set(DEPLOYED_FRAMEWORK $ENV{framework} CACHE INTERNAL "" FORCE)
endif()

if(NOT DEPLOYED_ENVIRONMENT AND DEFINED ENV{environment})
	set(DEPLOYED_ENVIRONMENT $ENV{environment} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_VERSION AND DEFINED ENV{version})
	set(TARGET_VERSION $ENV{version} CACHE INTERNAL "" FORCE)
endif()

if(NOT VERBOSE_MODE AND DEFINED ENV{verbose})
	set(VERBOSE_MODE $ENV{verbose} CACHE INTERNAL "" FORCE)
endif()

if(NOT FORCE_REDEPLOY AND DEFINED ENV{force})
	set(FORCE_REDEPLOY $ENV{force} CACHE INTERNAL "" FORCE)
endif()

if(NOT NO_SOURCE AND DEFINED ENV{no_source})
	set(NO_SOURCE $ENV{no_source} CACHE INTERNAL "" FORCE)
endif()

if(NOT USE_BRANCH AND DEFINED ENV{branch})
	set(USE_BRANCH $ENV{branch} CACHE INTERNAL "" FORCE)
endif()

if(NOT RUN_TESTS AND DEFINED ENV{test})
	set(RUN_TESTS $ENV{test} CACHE INTERNAL "" FORCE)
endif()

if(DEFINED ENV{manage_progress})
	set(MANAGE_PROGRESS $ENV{manage_progress})
else()
	set(MANAGE_PROGRESS TRUE)
endif()

#checking TARGET_VERSION value
if(TARGET_VERSION)
	if(TARGET_VERSION STREQUAL "system" OR TARGET_VERSION STREQUAL "SYSTEM" OR TARGET_VERSION STREQUAL "System")
		set(TARGET_VERSION "SYSTEM" CACHE INTERNAL "" FORCE)#prepare value for call to deploy_PID_Package
		set(NO_SOURCE FALSE CACHE INTERNAL "")#SYSTEM version can only be installed from external package wrapper
	endif()
endif()

#including the adequate reference file
if(DEPLOYED_FRAMEWORK)# a framework is deployed
	# checks of the arguments
	include(ReferFramework${DEPLOYED_FRAMEWORK} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
		message("[PID] ERROR : Framework name ${DEPLOYED_FRAMEWORK} does not refer to any known framework in the workspace.")
		return()
	endif()
	# deployment of the framework
	if(EXISTS ${WORKSPACE_DIR}/sites/frameworks/${DEPLOYED_FRAMEWORK} AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${DEPLOYED_FRAMEWORK})
		message("[PID] ERROR : Source repository for framework ${DEPLOYED_FRAMEWORK} already resides in the workspace.")
		return()
	endif()
	message("[PID] INFO : deploying PID framework ${DEPLOYED_FRAMEWORK} in the workspace ...")
	deploy_PID_Framework(${DEPLOYED_FRAMEWORK} "${VERBOSE_MODE}") #do the job
	return()

elseif(DEPLOYED_ENVIRONMENT)# deployment of an environment is required
	# checks of the arguments
	include(ReferEnvironment${DEPLOYED_ENVIRONMENT} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
		message("[PID] ERROR : Environment name ${DEPLOYED_ENVIRONMENT} does not refer to any known environment in the workspace.")
		return()
	endif()
	# deployment of the framework
	if(EXISTS ${WORKSPACE_DIR}/environments/${DEPLOYED_ENVIRONMENT} AND IS_DIRECTORY ${WORKSPACE_DIR}/environments/${DEPLOYED_ENVIRONMENT})
		message("[PID] ERROR : Source repository for environment ${DEPLOYED_FRAMEWORK} already resides in the workspace.")
		return()
	endif()
	message("[PID] INFO : deploying PID environment ${DEPLOYED_ENVIRONMENT} in the workspace ...")
	deploy_PID_Environment(${DEPLOYED_ENVIRONMENT} "${VERBOSE_MODE}") #do the job
	return()
else()# a package deployment is required

	####################################################################
	##########################  CHECKS  ################################
	####################################################################

	#check of arguments
	if(NOT DEPLOYED_PACKAGE)
		message("[PID] ERROR : You must specify the project to deploy: either a native package or an external package using package=<name of package> or a framework using framework=<name of framework> argument.")
		return()
	endif()

	#check if package is known
	set(is_external FALSE)
	include(Refer${DEPLOYED_PACKAGE} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
		include(ReferExternal${DEPLOYED_PACKAGE} OPTIONAL RESULT_VARIABLE EXT_REQUIRED_STATUS)
		if(EXT_REQUIRED_STATUS STREQUAL NOTFOUND)
			message("[PID] ERROR : Package name ${DEPLOYED_PACKAGE} does not refer to any known package in the workspace (either native or external).")
			return()
		else()
			set(is_external TRUE)
		endif()
	else()#this is a native package
		if(TARGET_VERSION STREQUAL "SYSTEM")
			message("[PID] ERROR : Native package (as ${DEPLOYED_PACKAGE}) cannot be installed as OS variants, only external packages can.")
			return()
		endif()
	endif()
	#after this previous commands packages references are known
	if(FORCE_REDEPLOY AND (FORCE_REDEPLOY STREQUAL "true" OR FORCE_REDEPLOY STREQUAL "TRUE"))
		set(redeploy TRUE)
	else()
		set(redeploy FALSE)
	endif()

	# check if redeployment asked
	if(TARGET_VERSION AND NOT TARGET_VERSION STREQUAL "SYSTEM") # a specific version is targetted
		package_Binary_Exists_In_Workspace(RETURNED_PATH ${DEPLOYED_PACKAGE} ${TARGET_VERSION} ${CURRENT_PLATFORM})
		if(RETURNED_PATH)#binary version already exists
			if(NOT redeploy)
				message("[PID] WARNING : ${DEPLOYED_PACKAGE} binary version ${TARGET_VERSION} already resides in the workspace. Use force=true to force the redeployment.")
				return()
			endif()
		endif()
	endif()

	# check in case when direct binary deployment asked
	set(references_loaded FALSE)
	if(NO_SOURCE STREQUAL "true" OR NO_SOURCE STREQUAL "TRUE")
		#if no source required then binary references must exist
		load_Package_Binary_References(REFERENCES_OK ${DEPLOYED_PACKAGE})# now load the binary references of the package
		set(references_loaded TRUE)#memorize that references have been loaded
		if(NOT REFERENCES_OK)
			message("[PID] ERROR : Cannot find any reference to a binary version of ${DEPLOYED_PACKAGE}. Aborting since no source deployment has been required.")
			return()
		endif()
		if(TARGET_VERSION) # a specific version is targetted
			exact_Version_Archive_Exists(${DEPLOYED_PACKAGE} "${TARGET_VERSION}" EXIST)
			if(NOT EXIST)
				message("[PID] ERROR : A binary relocatable archive with version ${TARGET_VERSION} does not exist for package ${DEPLOYED_PACKAGE}.  Aborting since no source deployment has been required.")
				return()
			endif()
		endif()
		set(can_use_source FALSE)
	else()
		set(can_use_source TRUE)
	endif()

	if(USE_BRANCH)
		if(is_external)
			message("[PID] ERROR : Cannot deploy a specific branch of ${DEPLOYED_PACKAGE} because it is an external package.")
			return()
		endif()
		if(NOT can_use_source)#need to run the deployment from sources !!
			message("[PID] ERROR : Cannot deploy a specific branch of ${DEPLOYED_PACKAGE} if no source deployment is required (using argument no_source=true).")
			return()
		endif()
		if(TARGET_VERSION)
			message("[PID] ERROR : Cannot deploy a specific branch of ${DEPLOYED_PACKAGE} if a specific version is required (using argument version=${TARGET_VERSION}).")
			return()
		endif()
		set(branch ${USE_BRANCH})
	else()
		set(branch)
	endif()

	if(RUN_TESTS STREQUAL "true" OR RUN_TESTS STREQUAL "TRUE")
		if(is_external)
			message("[PID] ERROR : Cannot run test during deployment of ${DEPLOYED_PACKAGE} because it is an external package.")
			return()
		endif()
		if(NOT can_use_source)#need to run the deployment from sources !!
			message("[PID] ERROR : Cannot run test during deployment of ${DEPLOYED_PACKAGE} if no source deployment is required (using argument no_source=true).")
			return()
		endif()
		set(run_tests TRUE)
	else()#do not run tests
		set(run_tests FALSE)
	endif()
		####################################################################
		##########################  OPERATIONS  ############################
		####################################################################

	## start package deployment process
	if(MANAGE_PROGRESS)#conditionate the progress management to allow an external CMake project to preconfigure some constraints on external packages
		remove_Progress_File() #reset the build progress information (sanity action)
		begin_Progress(workspace GLOBAL_PROGRESS_VAR)
  else()
		set(GLOBAL_PROGRESS_VAR FALSE)#to avoid troubles when progres managed from an external project
	endif()


	if(TARGET_VERSION)
		if(is_external)#external package is deployed
			set(message_to_print "[PID] INFO : deploying external package ${DEPLOYED_PACKAGE} (version ${TARGET_VERSION}) in the workspace ...")
		else()#native package is deployed
			set(message_to_print "[PID] INFO : deploying native PID package ${DEPLOYED_PACKAGE} (version ${TARGET_VERSION}) in the workspace ...")
		endif()
		#from here the operation can be theorically realized
		if(redeploy)#if a redeploy has been forced then first action is to uninstall
			clear_PID_Package(RES ${DEPLOYED_PACKAGE} ${TARGET_VERSION})
			if(RES AND ("${VERBOSE_MODE}" STREQUAL "true" OR "${VERBOSE_MODE}" STREQUAL "TRUE"))
				message("[PID] INFO : package ${DEPLOYED_PACKAGE} version ${TARGET_VERSION} has been uninstalled ...")
			endif()
		endif()
	else()#no version specified
		if(branch)#a given branch must be deployed
			set(version_info "version from branch ${branch}")
		else()#no more info = deploying last version
			set(version_info "last version")
		endif()
		if(is_external)#external package is deployed
			set(message_to_print "[PID] INFO : deploying external package ${DEPLOYED_PACKAGE} (${version_info}) in the workspace ...")
		else()#native package is deployed
			message("")
			set(message_to_print "[PID] INFO : deploying native package ${DEPLOYED_PACKAGE} (${version_info}) in the workspace ...")
		endif()
	endif()

	message("${message_to_print}")
	# now do the deployment
	if(is_external)#external package is deployed
		deploy_PID_External_Package(PACK_DEPLOYED ${DEPLOYED_PACKAGE} "${TARGET_VERSION}" "${VERBOSE_MODE}" ${can_use_source} ${redeploy})
	else()#native package is deployed
		deploy_PID_Native_Package(PACK_DEPLOYED ${DEPLOYED_PACKAGE} "${TARGET_VERSION}" "${VERBOSE_MODE}" ${can_use_source} "${branch}" ${run_tests})
	endif()
	if(NOT PACK_DEPLOYED)
		message("[PID] CRITICAL ERROR : there were errors during deployment of ${DEPLOYED_PACKAGE}")
	endif()
	## global management of the process
	if(MANAGE_PROGRESS)
		message("--------------------------------------------")
		message("All packages deployed during this process : ")
		print_Managed_Packages()
		message("--------------------------------------------")
		finish_Progress(TRUE) #reset the build progress information
	endif()
endif()
