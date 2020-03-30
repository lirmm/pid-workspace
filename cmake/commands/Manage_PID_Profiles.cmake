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
include(PID_Deployment_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
include(PID_Environment_API_Internal_Functions NO_POLICY_SCOPE)
include(PID_Contribution_Space_Functions NO_POLICY_SCOPE)
include(PID_Profiles_Functions NO_POLICY_SCOPE)

load_Current_Contribution_Spaces()
### script used to configure the build environment

#first check that commmand parameters are not passed as environment variables
if(NOT TARGET_COMMAND AND DEFINED ENV{cmd})
	set(TARGET_COMMAND $ENV{cmd} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_PROFILE AND DEFINED ENV{profile})
	set(TARGET_PROFILE $ENV{profile} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_ENVIRONMENT AND DEFINED ENV{env})
	set(TARGET_ENVIRONMENT $ENV{env} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_INSTANCE AND DEFINED ENV{instance})
	set(TARGET_INSTANCE $ENV{instance} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_SYSROOT AND DEFINED ENV{sysroot})
	set(TARGET_SYSROOT $ENV{sysroot} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_STAGING AND DEFINED ENV{staging})
	set(TARGET_STAGING $ENV{staging} CACHE INTERNAL "" FORCE)
endif()

#more on platform
if(NOT TARGET_PLATFORM AND DEFINED ENV{platform})
	set(TARGET_PLATFORM $ENV{platform} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_PROC_TYPE AND DEFINED ENV{proc_type})
	set(TARGET_PROC_TYPE $ENV{proc_type} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_PROC_ARCH AND DEFINED ENV{proc_arch})
	set(TARGET_PROC_ARCH $ENV{proc_arch} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_OS AND DEFINED ENV{os})
	set(TARGET_OS $ENV{os} CACHE INTERNAL "" FORCE)
endif()

if(NOT TARGET_ABI AND DEFINED ENV{abi})
	if("$ENV{abi}" STREQUAL "abi98" OR "$ENV{abi}" STREQUAL "98")
		set(TARGET_ABI CXX CACHE INTERNAL "" FORCE)
	elseif("$ENV{abi}" STREQUAL "abi11" OR "$ENV{abi}" STREQUAL "11")
		set(TARGET_ABI CXX11 CACHE INTERNAL "" FORCE)
	else()
		message("[PID] ERROR when using the command ${TARGET_COMMAND}, unknown ABI specified: $ENV{abi}. Use the argument \"abi\" with value 98 or 11.")
		return()
	endif()
endif()

if(NOT TARGET_DISTRIBUTION AND DEFINED ENV{distribution})
	set(TARGET_DISTRIBUTION $ENV{distribution} CACHE INTERNAL "" FORCE)
	#more on platform
	if(NOT TARGET_DISTRIBUTION_VERSION AND DEFINED ENV{distrib_version})
		set(TARGET_DISTRIBUTION_VERSION $ENV{distrib_version} CACHE INTERNAL "" FORCE)
	endif()
endif()

read_Profiles_Description_File(READ_SUCCESS) #reading information about profiles description

# check inputs depending on the value of the "cmd" argument
set(cmd_list "ls|mk|del|load|reset|add|rm")
if(NOT TARGET_COMMAND MATCHES "^${cmd_list}$")
	message(FATAL_ERROR "[PID] bad command \"${TARGET_COMMAND}\" used for profiles management. Allowed commands are: ${cmd_list}")
	return()
endif()

if(NOT TARGET_COMMAND MATCHES "ls|reset")#except when listing profiles or resetting to defaultprofile, a profile name must be given
	if(NOT TARGET_PROFILE)
		if(TARGET_COMMAND MATCHES "add|rm")#add and rm commands apply by default to current profile
			set(TARGET_PROFILE ${CURRENT_PROFILE} CACHE INTERNAL "")
		else()
			message("[PID] ERROR when using the command ${TARGET_COMMAND}: you must given the name of target profile using \"profile\" argument")
			return()
		endif()
	endif()
	if(TARGET_COMMAND MATCHES "mk|add|rm")
		if(NOT TARGET_ENVIRONMENT)
			message("[PID] ERROR when using the command ${TARGET_COMMAND}: you must give the name of environment using \"env\" argument")
			return()
		endif()
	endif()
	if(TARGET_COMMAND STREQUAL "mk")
		#more checks: when a profileis created target platform must be more or less precisely specified
		if(TARGET_PLATFORM)
			extract_Info_From_Platform(RES_TYPE RES_ARCH RES_OS RES_ABI RES_INSTANCE RES_PLATFORM_BASE ${TARGET_PLATFORM})
			set(TARGET_PROC_TYPE ${RES_TYPE} CACHE INTERNAL "" FORCE)
			set(TARGET_PROC_ARCH ${RES_ARCH} CACHE INTERNAL "" FORCE)
			if(NOT RES_OS)
				set(TARGET_OS "Generic" CACHE INTERNAL "" FORCE)
			else()
				set(TARGET_OS ${RES_OS} CACHE INTERNAL "" FORCE)
			endif()
			set(TARGET_ABI ${RES_ABI} CACHE INTERNAL "" FORCE)

		endif()
	endif()
endif()


# now basic checks have been made perform operations
# this basically consists in raeding/writing profile description file
# more operations can be done, for instance
# - deleting specific build folders
# - reconfiguring the workspace

set(need_reconfigure FALSE)

if(TARGET_COMMAND STREQUAL "ls")
	message("[PID] current profile: ${CURRENT_PROFILE}")
	message("[PID] all available profiles: ")
	foreach(profile IN LISTS PROFILES)
		message(" - ${profile}: based on ${PROFILE_${profile}_DEFAULT_ENVIRONMENT} environment")
		if(PROFILE_${profile}_TARGET_SYSROOT)
			message("   + sysroot: ${PROFILE_${profile}_TARGET_SYSROOT}")
		endif()
		if(PROFILE_${profile}_TARGET_STAGING)
			message("   + staging: ${PROFILE_${profile}_TARGET_STAGING}")
		endif()
		if(PROFILE_${profile}_TARGET_INSTANCE)
			message("   + instance name: ${PROFILE_${profile}_TARGET_INSTANCE}")
		endif()
		if(PROFILE_${profile}_TARGET_PLATFORM_OS
			OR PROFILE_${profile}_TARGET_PLATFORM_PROC_ARCH
			OR PROFILE_${profile}_TARGET_PLATFORM_PROC_TYPE
			OR PROFILE_${profile}_TARGET_PLATFORM_ABI
		)
			set(mess_str "   + target platform:")
			if(PROFILE_${profile}_TARGET_PLATFORM_OS)
				set(mess_str "${mess_str} OS=${PROFILE_${profile}_TARGET_PLATFORM_OS}")
			endif()
			if(PROFILE_${profile}_TARGET_PLATFORM_PROC_ARCH)
				set(mess_str "${mess_str} processor=${PROFILE_${profile}_TARGET_PLATFORM_PROC_ARCH}")
			endif()
			if(PROFILE_${profile}_TARGET_PLATFORM_PROC_TYPE)
				set(mess_str "${mess_str} bits=${PROFILE_${profile}_TARGET_PLATFORM_PROC_TYPE}")
			endif()
			if(PROFILE_${profile}_TARGET_PLATFORM_ABI)
				set(mess_str "${mess_str} abi=${PROFILE_${profile}_TARGET_PLATFORM_ABI}")
			endif()
			message("${mess_str}")
		endif()
		if(PROFILE_${profile}_TARGET_DISTRIBUTION)
			if(PROFILE_${profile}_TARGET_DISTRIBUTION_VERSION)
				message("   + target distribution: ${PROFILE_${profile}_TARGET_DISTRIBUTION} ${PROFILE_${profile}_TARGET_DISTRIBUTION_VERSION}")
			else()
				message("   + target distribution: ${PROFILE_${profile}_TARGET_DISTRIBUTION}")
			endif()
		endif()
		if(PROFILE_${profile}_MORE_ENVIRONMENTS)
			fill_String_From_List(PROFILE_${profile}_MORE_ENVIRONMENTS RES_STR)
			message("   + additionnal environments: ${RES_STR}")
		endif()
  endforeach()

elseif(TARGET_COMMAND STREQUAL "del")
	list(FIND PROFILES ${TARGET_PROFILE} INDEX)
	if(INDEX EQUAL -1)#profile does not exist
		message("[PID] ERROR : target profile ${TARGET_PROFILE} does not exist, cannot delete it.")
		return()
	endif()
	remove_Profile(CHANGED ${TARGET_PROFILE})
	file(REMOVE_RECURSE ${WORKSPACE_DIR}/pid/${TARGET_PROFILE})
	if(CHANGED)
		set(need_reconfigure TRUE)#reconfigrue if necessary
	endif()
elseif(TARGET_COMMAND STREQUAL "reset")
	set(CURRENT_PROFILE "default" CACHE INTERNAL "")
	set(need_reconfigure TRUE)#reconfigrue even if not necessarily mandatory

elseif(TARGET_COMMAND STREQUAL "load")
	list(FIND PROFILES ${TARGET_PROFILE} INDEX)
	if(INDEX EQUAL -1)#profile does not exist
		message("[PID] ERROR : target profile ${TARGET_PROFILE} does not exist, cannot load it.")
		return()
	endif()
	set(CURRENT_PROFILE "${TARGET_PROFILE}" CACHE INTERNAL "")
	set(need_reconfigure TRUE)#reconfigrue even if not necessarily mandatory

elseif(TARGET_COMMAND STREQUAL "mk")
	list(FIND PROFILES ${TARGET_PROFILE} INDEX)
	if(NOT INDEX EQUAL -1)#profile does not exist
		message("[PID] ERROR : target profile ${TARGET_PROFILE} already exists, cannot create a profile with same name*.")
		return()
	endif()
	set(args )
	if(TARGET_SYSROOT)
		list(APPEND args SYSROOT ${TARGET_SYSROOT})
	endif()
	if(TARGET_STAGING)
		list(APPEND args STAGING ${TARGET_STAGING})
	endif()
	if(TARGET_INSTANCE)
		list(APPEND args INSTANCE ${TARGET_INSTANCE})
	endif()
	if(TARGET_PLATFORM_OS)
		list(APPEND args OS ${TARGET_PLATFORM_OS})
	endif()
	if(TARGET_PLATFORM_PROC_ARCH)
		list(APPEND args PROC_ARCH ${TARGET_PLATFORM_PROC_ARCH})
	endif()
	if(TARGET_PLATFORM_PROC_TYPE)
		list(APPEND args PROC_TYPE ${TARGET_PLATFORM_PROC_TYPE})
	endif()
	if(TARGET_PLATFORM_ABI)
		list(APPEND args ABI ${TARGET_PLATFORM_ABI})
	endif()
	if(TARGET_DISTRIBUTION)
		list(APPEND args DISTRIBUTION ${TARGET_DISTRIBUTION})
		if(TARGET_DISTRIBUTION_VERSION)
			list(APPEND args DISTRIB_VERSION ${TARGET_DISTRIBUTION_VERSION})
		endif()
	endif()
	add_Managed_Profile(${TARGET_PROFILE} ENVIRONMENT ${TARGET_ENVIRONMENT} ${args})
	set(CURRENT_PROFILE "${TARGET_PROFILE}" CACHE INTERNAL "")
	set(need_reconfigure TRUE)#reconfigrue (always mandatory)

elseif(TARGET_COMMAND STREQUAL "add")
	list(FIND PROFILES ${TARGET_PROFILE} INDEX)
	if(INDEX EQUAL -1)#profile does not exist
		message("[PID] ERROR : target profile ${TARGET_PROFILE} does not exist, cannot add an additionnal environment to it.")
		return()
	endif()

	add_Managed_Profile(${TARGET_PROFILE} ENVIRONMENT ${TARGET_ENVIRONMENT})
	if(CURRENT_PROFILE STREQUAL TARGET_PROFILE)
		set(need_reconfigure TRUE)#reconfigure only if necessary
	endif()
elseif(TARGET_COMMAND STREQUAL "rm")
	list(FIND PROFILES ${TARGET_PROFILE} INDEX)
	if(INDEX EQUAL -1)#profile does not exist
		message("[PID] ERROR : target profile ${TARGET_PROFILE} does not exist, cannot remove an additionnal environment from it.")
		return()
	endif()
	remove_Additional_Environment(SUCCESS ${TARGET_PROFILE} ${TARGET_ENVIRONMENT})
	if(NOT SUCCESS)
		message("[PID] ERROR : target profile ${TARGET_PROFILE} does not have an additionnal environment named ${TARGET_ENVIRONMENT}, cannot remove it.")
		return()
	endif()
	if(CURRENT_PROFILE STREQUAL TARGET_PROFILE)
		set(need_reconfigure TRUE)#reconfigure only if necessary
	endif()

endif()

# write the configuration file to memorize choices for next configuration
write_Profiles_Description_File()

if(need_reconfigure)
	execute_process(COMMAND ${CMAKE_COMMAND}
									-DFORCE_CURRENT_PROFILE_EVALUATION=TRUE
									${WORKSPACE_DIR}
									WORKING_DIRECTORY ${WORKSPACE_DIR}/pid)
endif()
