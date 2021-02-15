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
include(Package_Definition NO_POLICY_SCOPE) # to be able to interpret description of external components
load_Workspace_Info() #loading the current platform configuration
configure_Contribution_Spaces()

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
if(DEFINED ENV{package})
	unset(ENV{package})
endif()

if(NOT DEPLOYED_FRAMEWORK AND DEFINED ENV{framework})
	set(DEPLOYED_FRAMEWORK $ENV{framework} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{framework})
	unset(ENV{framework})
endif()

if(NOT DEPLOYED_ENVIRONMENT AND DEFINED ENV{environment})
	set(DEPLOYED_ENVIRONMENT $ENV{environment} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{environment})
	unset(ENV{environment})
endif()

if(NOT TARGET_VERSION AND DEFINED ENV{version})
	set(TARGET_VERSION $ENV{version} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{version})
	unset(ENV{version})
endif()

if(NOT VERBOSE_MODE AND DEFINED ENV{verbose})
	set(VERBOSE_MODE $ENV{verbose} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{verbose})
	unset(ENV{verbose})
endif()

if(NOT FORCE_REDEPLOY AND DEFINED ENV{force})
	set(FORCE_REDEPLOY $ENV{force} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{force})
	unset(ENV{force})
endif()

if(NOT USE_BINARIES AND DEFINED ENV{use_binaries})
	set(USE_BINARIES $ENV{use_binaries} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{use_binaries})
	unset(ENV{use_binaries})
endif()

if(NOT USE_SOURCE AND DEFINED ENV{use_source})
	set(USE_SOURCE $ENV{use_source} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{use_source})
	unset(ENV{use_source})
endif()

if(NOT USE_BRANCH AND DEFINED ENV{branch})
	set(USE_BRANCH $ENV{branch} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{branch})
	unset(ENV{branch})
endif()

if(NOT RUN_TESTS AND DEFINED ENV{test})
	set(RUN_TESTS $ENV{test} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{test})
	unset(ENV{test})
endif()

if(DEFINED ENV{manage_progress})
	set(MANAGE_PROGRESS $ENV{manage_progress})
else()
	set(MANAGE_PROGRESS TRUE)
endif()

if(NOT RELEASE_ONLY AND DEFINED ENV{release_only})
	set(RELEASE_ONLY $ENV{release_only} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{release_only})
	unset(ENV{release_only})
endif()
#only release binaries are deployed by default
if(RELEASE_ONLY MATCHES "false|FALSE")
	set(RELEASE_ONLY FALSE  CACHE INTERNAL "" FORCE)
else()
	set(RELEASE_ONLY TRUE CACHE INTERNAL "" FORCE)
endif()

#checking TARGET_VERSION value
if(TARGET_VERSION)
	if(TARGET_VERSION STREQUAL "system" OR TARGET_VERSION STREQUAL "SYSTEM" OR TARGET_VERSION STREQUAL "System")
		set(TARGET_VERSION "SYSTEM" CACHE INTERNAL "" FORCE)#prepare value for call to deploy_PID_Package
		set(USE_BINARIES FALSE CACHE INTERNAL "")#SYSTEM version can only be installed from external package wrapper
	endif()
endif()

#including the adequate reference file
if(DEPLOYED_FRAMEWORK)# a framework is deployed
	# checks of the arguments
	include_Framework_Reference_File(PATH_TO_FILE ${DEPLOYED_FRAMEWORK})
	if(NOT PATH_TO_FILE)
		message("[PID] ERROR : Framework name ${DEPLOYED_FRAMEWORK} does not refer to any known framework in contribution spaces of the workspace.")
		return()
	endif()
	# deployment of the framework
	if(EXISTS ${WORKSPACE_DIR}/sites/frameworks/${DEPLOYED_FRAMEWORK} AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${DEPLOYED_FRAMEWORK})
		message("[PID] ERROR : Source repository for framework ${DEPLOYED_FRAMEWORK} already resides in the workspace.")
		return()
	endif()
	message("[PID] INFO : deploying framework ${DEPLOYED_FRAMEWORK} in the workspace ...")
	deploy_PID_Framework(${DEPLOYED_FRAMEWORK} "${VERBOSE_MODE}") #do the job
	return()

elseif(DEPLOYED_ENVIRONMENT)# deployment of an environment is required
	# checks of the arguments
	include_Environment_Reference_File(PATH_TO_FILE ${DEPLOYED_ENVIRONMENT})
	if(NOT PATH_TO_FILE)
		message("[PID] ERROR : Environment name ${DEPLOYED_ENVIRONMENT} does not refer to any known environment in in contribution spaces of the workspace.")
		return()
	endif()
	# deployment of the framework
	if(EXISTS ${WORKSPACE_DIR}/environments/${DEPLOYED_ENVIRONMENT} AND IS_DIRECTORY ${WORKSPACE_DIR}/environments/${DEPLOYED_ENVIRONMENT})
		message("[PID] INFO : Source repository for environment ${DEPLOYED_FRAMEWORK} already resides in the workspace. Nothing to do...")
		return()
	endif()
	message("[PID] INFO : deploying environment ${DEPLOYED_ENVIRONMENT} in the workspace ...")
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

	#check if package is known since a deployment supposes that the package is referenced
	get_Package_Type(${DEPLOYED_PACKAGE} PACK_TYPE)
	if(PACK_TYPE STREQUAL "UNKNOWN")
		update_Contribution_Spaces(UPDATED)
		if(UPDATED)
			get_Package_Type(${DEPLOYED_PACKAGE} PACK_TYPE)
		endif()
		if(PACK_TYPE STREQUAL "UNKNOWN")
			message("[PID] ERROR : Unknown native or external package ${DEPLOYED_PACKAGE} : it does not refer to any known package in contribution spaces already in use.")
			return()
		endif()
		#TODO CONTRIB update and retry
	endif()
	if(PACK_TYPE STREQUAL "NATIVE")
		include_Package_Reference_File(PATH_TO_FILE ${DEPLOYED_PACKAGE})
		if(NOT PATH_TO_FILE)
			message("[PID] ERROR : Package name ${DEPLOYED_PACKAGE} does not refer to any known package in the workspace (either native or external).")
			return()
		else()
			set(is_external FALSE)
		endif()
		if(TARGET_VERSION STREQUAL "SYSTEM")
			message("[PID] ERROR : Native package (as ${DEPLOYED_PACKAGE}) cannot be installed as OS variants, only external packages can.")
			return()
		endif()
	elseif(PACK_TYPE STREQUAL "EXTERNAL")
		include_External_Reference_File(PATH_TO_FILE ${DEPLOYED_PACKAGE})
		if(NOT PATH_TO_FILE)
			message("[PID] ERROR : Package name ${DEPLOYED_PACKAGE} does not refer to any known package in the workspace (either native or external).")
			return()
		else()
			set(is_external TRUE)
		endif()
	else()#unknown package type => we have no ereferecen of it
		message("[PID] ERROR : Package name ${DEPLOYED_PACKAGE} does not refer to any known package in the workspace (either native or external).")
		return()
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
	set(deploy_mode "ANY")
	if(USE_BINARIES STREQUAL "true" OR USE_BINARIES STREQUAL "TRUE")
		if(USE_SOURCE STREQUAL "true" OR USE_SOURCE STREQUAL "TRUE")
			message("[PID] ERROR : Cannot force use of deployment from sources and binaries at same time. Use either use_source or use_binaries but not both.")
			return()
		endif()
	endif()
	if(USE_BINARIES STREQUAL "true" OR USE_BINARIES STREQUAL "TRUE")
		set(deploy_mode "BINARY")
	elseif(USE_SOURCE STREQUAL "true" OR USE_SOURCE STREQUAL "TRUE")
		set(deploy_mode "SOURCE")
	endif()

	if(deploy_mode STREQUAL "BINARY")
		#if no source required then binary references must exist
		load_Package_Binary_References(REFERENCES_OK ${DEPLOYED_PACKAGE})# now load the binary references of the package
		if(NOT REFERENCES_OK)
			message("[PID] ERROR : Cannot find any reference to a binary version of ${DEPLOYED_PACKAGE}. Aborting since no source deployment has been required.")
			return()
		endif()
		set(references_loaded TRUE)#memorize that references have been loaded
		if(TARGET_VERSION) # a specific version is targetted
			exact_Version_Archive_Exists(${DEPLOYED_PACKAGE} "${TARGET_VERSION}" EXIST)
			if(NOT EXIST)
				message("[PID] ERROR : A binary relocatable archive with version ${TARGET_VERSION} does not exist for package ${DEPLOYED_PACKAGE}.  Aborting since no source deployment has been required.")
				return()
			endif()
		endif()
	endif()

	if(USE_BRANCH)
		if(is_external)
			message("[PID] ERROR : Cannot deploy a specific branch of ${DEPLOYED_PACKAGE} because it is an external package.")
			return()
		endif()
		if(deploy_mode STREQUAL "BINARY")#need to run the deployment from sources !!
			message("[PID] ERROR : Cannot deploy a specific branch of ${DEPLOYED_PACKAGE} if no source deployment is required (using argument use_binaries=true).")
			return()
		elseif(deploy_mode STREQUAL "ANY")
			set(deploy_mode "SOURCE")
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
		if(deploy_mode STREQUAL "BINARY")#need to run the deployment from sources !!
			message("[PID] ERROR : Cannot run test during deployment of ${DEPLOYED_PACKAGE} if deployment from binaries is required (you used use_binaries=true).")
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
			set(message_to_print "[PID] INFO : deploying external PID package ${DEPLOYED_PACKAGE} (version ${TARGET_VERSION}) in the workspace ...")
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
		deploy_PID_External_Package(PACK_DEPLOYED ${DEPLOYED_PACKAGE} "${TARGET_VERSION}" "${VERBOSE_MODE}" ${deploy_mode} ${redeploy} "${RELEASE_ONLY}")
	else()#native package is deployed
		deploy_PID_Native_Package(PACK_DEPLOYED ${DEPLOYED_PACKAGE} "${TARGET_VERSION}" "${VERBOSE_MODE}" ${deploy_mode} "${branch}" ${run_tests} "${RELEASE_ONLY}")
	endif()
	if(NOT PACK_DEPLOYED)
		message(SEND_ERROR "[PID] CRITICAL ERROR : there were errors during deployment of ${DEPLOYED_PACKAGE}")
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
