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
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
load_Workspace_Info() #loading the current platform configuration

if(NOT TARGET_PACKAGE AND DEFINED ENV{package})
	set(TARGET_PACKAGE $ENV{package} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{package})
	unset(ENV{package})
endif()

if(NOT TARGET_VERSION AND DEFINED ENV{version})
	set(TARGET_VERSION $ENV{version} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{version})
	unset(ENV{version})
endif()


#### preliminary checks ###

#check for inputs
if(NOT TARGET_PACKAGE)
	message(FATAL_ERROR "[PID] ERROR : You must specify the name of the package to patch using package=<name of package> argument.")
endif()

if(NOT EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
	message(FATAL_ERROR "[PID] ERROR : package ${TARGET_PACKAGE} does not exist in ${WORKSPACE_DIR}/packages, cannot patch it !.")
endif()

if(NOT TARGET_VERSION)
	message(FATAL_ERROR "[PID] ERROR : You must specify the version to patch. Specify a major.minor version for which you want to create a patch")
endif()

get_Version_String_Numbers(${TARGET_VERSION} TARGET_MAJOR TARGET_MINOR TARGET_PATCH)
if("${TARGET_MINOR}" STREQUAL "")
	message(FATAL_ERROR "[PID] ERROR : the version you specified (${TARGET_VERSION}) does not contain a minor version. Specify a major.minor version for which you want to create a patch.")
endif()

get_Repository_Current_Branch(CURRENT_COMMIT_OR_BRANCH ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
if(NOT CURRENT_COMMIT_OR_BRANCH)
	get_Repository_Current_Commit(CURRENT_COMMIT_OR_BRANCH ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})#Note: to be able to go back to initial state if any error occurs
endif()
# check for modifications
has_Modifications(HAS_MODIFS ${TARGET_PACKAGE})
if(HAS_MODIFS)
	message("[PID] ERROR : package ${TARGET_PACKAGE} has modification to commit or stash, patch aborted.")
	return()
endif()
# from here we can navigate between branches freely
list_Ignored_Files(IGNORED_ON_INITIAL_COMMIT ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})

# udpate the master branch from official remote repository
update_Package_Repository_Versions(UPDATE_OK ${TARGET_PACKAGE})
if(NOT UPDATE_OK)
	message("[PID] ERROR : ${TARGET_PACKAGE} cannot be updated from official one. Patch command cannot ensure you will not try to patch a non existing version. Maybe you have no clone rights from official or local master branch of package ${package} is not synchronizable with official master branch.")
	go_To_Commit(${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} ${CURRENT_COMMIT_OR_BRANCH})
	return()
endif() #from here graph of commits and version tags are OK

# here there may have newly untracked files in master that are newly ignored files on dev branch
# these files should be preserved
checkout_From_Master_To_Commit(${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} ${CURRENT_COMMIT_OR_BRANCH} IGNORED_ON_INITIAL_COMMIT)

# check that version is not already released on official/master branch
get_Repository_Version_Tags(AVAILABLE_VERSION_TAGS ${TARGET_PACKAGE})
normalize_Version_Tags(VERSION_NUMBERS "${AVAILABLE_VERSION_TAGS}")
if(NOT VERSION_NUMBERS)
	message("[PID] ERROR : malformed package ${TARGET_PACKAGE}, no version tag detected in ${TARGET_PACKAGE} repository ! This denote a bad state of your repository. Maybe this repository has been cloned by hand wthout pulling its version tags.\n
	1) you can try doing the command `update` into ${TARGET_PACKAGE} project, then try patching again.\n
  2) you can try solving the problem by yourself. Please go into ${TARGET_PACKAGE} repository and enter command `git fetch official --tags`. If no tag exists that probably means you did not create the package using the create command but by copy/pasting code of an existing one. Then create a tag v0.0.0 on your first commit and push it to your official repository: `git checkout <first commit> && git tag -a v0.0.0 -m \"first commit\" && git push official v0.0.0 && git checkout inegration`. Then try again to release your package.")
	return()
endif()

set(max_patch_for_minor_version -1)
foreach(version IN LISTS VERSION_NUMBERS)
	get_Version_String_Numbers(${version} MAJOR MINOR PATCH)
	if(MAJOR EQUAL TARGET_MAJOR AND MINOR EQUAL TARGET_MINOR)
		if(	PATCH GREATER max_patch_for_minor_version)
			set(max_patch_for_minor_version ${PATCH})
		endif()
	endif()
endforeach()

if(max_patch_for_minor_version EQUAL -1)
	message(FATAL_ERROR "[PID] ERROR : cannot patch package ${TARGET_PACKAGE} version ${TARGET_VERSION} because no such major.minor version can be found !")
endif()

if(TARGET_PATCH)
	if(TARGET_PATCH GREATER max_patch_for_minor_version)
		message(FATAL_ERROR "[PID] ERROR : cannot patch package ${TARGET_PACKAGE} version ${TARGET_VERSION} because patch version you specified (${TARGET_PATCH}) does not match any existing patch version.")
	endif()
endif()
##### now we can proceed ######

#OK from here the biggest patch version for major.minor has been found
math(EXPR new_patch_number "${max_patch_for_minor_version}+1")
set(new_patch_version ${TARGET_MAJOR}.${TARGET_MINOR}.${new_patch_number})
set(new_branch_name "patch-${new_patch_version}")
start_Patching_Version(NEW_BRANCH ${TARGET_PACKAGE} ${new_branch_name} ${TARGET_MAJOR}.${TARGET_MINOR}.${max_patch_for_minor_version})
if(NEW_BRANCH)
	message("[PID] INFO : new patch branch ${new_branch_name} created.")
	get_Version_Number_And_Repo_From_Package(${TARGET_PACKAGE} DIGITS STRING FORMAT METHOD ADDRESS)
	# performing basic checks
	if(NOT DIGITS)#version number is not well defined
		message("[PID] ERROR : problem patching package ${TARGET_PACKAGE}, bad version format in its root CMakeLists.txt.")
		return()
	endif()
	set_Version_Number_To_Package(RESULT_OK ${TARGET_PACKAGE} "DOTTED_STRING" "${METHOD}" ${TARGET_MAJOR} ${TARGET_MINOR} ${new_patch_number})
	if(NOT RESULT_OK)
		message(FATAL_ERROR "[PID] ERROR : creating patch ${new_patch_version} for package ${TARGET_PACKAGE} failed !")
	else()
		register_Repository_Version(${TARGET_PACKAGE} ${new_patch_version})#commit the modification and start working
		message("[PID] INFO : patching package ${TARGET_PACKAGE} with new version ${new_patch_version} starts now...")
	endif()
else()
	message("[PID] INFO : use existing patch branch ${new_branch_name}.")
	# Note: here there is not much more to do as the branch wa existing previously
	# operation is in the end mostly a checkout
endif()
