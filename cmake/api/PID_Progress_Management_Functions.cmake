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
if(PID_PROGRESS_MANAGEMENT_INCLUDED)
  return()
endif()
set(PID_PROGRESS_MANAGEMENT_INCLUDED TRUE)
##########################################################################################

#############################################################################################
#################### API functions for managing dependency constraints when building ########
#############################################################################################
############### W I P ############
# Explanations:
# 1) among all possible alternative we may have to select the adequate one depending on alternatives chosen previously by another package
# to do this, the package must get a set of internal variables that define what are the selected altervatives in a build that uses the current package as a dependency.
# 2) once received, the chosen alternatives must be set adequately OR an ERROR has to be generated (if the selected alternative of the same package is not managed locally).
# 3) when finding a dependency (into install tree) not only the version has to be checked but also the alternatives used by that package.
# If the binary is not using a compatible version with the selected one then it must be removed and reinstalled from source using alternative constraints.
# This ends up in going back to point 1

#################################################################################################################
######################## Utility functions to change the content of the progress file ###########################
#################################################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Progress_File| replace:: ``init_Progress_File``
#  .. _init_Progress_File:
#
#  init_Progress_File
#  ------------------
#
#   .. command:: init_Progress_File(name)
#
#    Create (or recreate) the temporary build progress management file in workspace (pid-workspace/build/pid_progress.cmake). This file contains the user information about the last launched build process or command.
#
#      :name: the name of the process to initialize.
#
function(init_Progress_File name)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
file(WRITE ${thefile} "set(CURRENT_PROCESS_LAUNCHER ${name})\n")
string(TIMESTAMP TIME_VAR "%Y-%j-%H-%M" UTC)
file(APPEND ${thefile} "set(CURRENT_PROCESS_LAUNCH_DATE ${TIME_VAR})\n")
file(APPEND ${thefile} "set(CURRENT_PROCESS_LAST_UPDATE_DATE ${TIME_VAR})\n")
endfunction(init_Progress_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Progress_File| replace:: ``reset_Progress_File``
#  .. _reset_Progress_File:
#
#  reset_Progress_File
#  -------------------
#
#   .. command:: reset_Progress_File()
#
#    Reset the content of the current build progress management file (pid-workspace/build/pid_progress.cmake) while keeping information about process launcher unchanged.
#
function(reset_Progress_File)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
file(WRITE ${thefile} "set(CURRENT_PROCESS_LAUNCHER ${CURRENT_PROCESS_LAUNCHER})\n")
file(APPEND ${thefile} "set(CURRENT_PROCESS_LAUNCH_DATE ${CURRENT_PROCESS_LAUNCH_DATE})\n")
string(TIMESTAMP TIME_VAR "%Y-%j-%H-%M" UTC)
file(APPEND ${thefile} "set(CURRENT_PROCESS_LAST_UPDATE_DATE ${TIME_VAR})\n")
endfunction(reset_Progress_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Progress_File_Last_Modification_Outdated| replace:: ``check_Progress_File_Last_Modification_Outdated``
#  .. _check_Progress_File_Last_Modification_Outdated:
#
#  check_Progress_File_Last_Modification_Outdated
#  ----------------------------------------------
#
#   .. command:: check_Progress_File_Last_Modification_Outdated(OUTDATED CONTEXT)
#
#    Check wether the build progress management file in workspace is outdated compared to current context (i.e. current process being run).
#
#      :OUTDATED: The output variable that is TRUE if file is outdated, FALSE otherwise.
#      :CONTEXT: The output variable that contains the context (build process of a package, execution of a script)
#
function(check_Progress_File_Last_Modification_Outdated OUTDATED CONTEXT)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
include (${thefile})
set(${OUTDATED} TRUE PARENT_SCOPE)
set(${CONTEXT} ${CURRENT_PROCESS_LAUNCHER} PARENT_SCOPE)
string(TIMESTAMP TIME_VAR "%Y-%j-%H-%M" UTC)
string(REGEX REPLACE "^([0-9]+)-([0-9]+)-([0-9]+)-([0-9]+)$" "\\1;\\2;\\3;\\4" DATE_OF_NOW ${TIME_VAR})
if(NOT DATE_OF_NOW STREQUAL TIME_VAR) # match found
	string(REGEX REPLACE "^([0-9]+)-([0-9]+)-([0-9]+)-([0-9]+)$" "\\1;\\2;\\3;\\4" LAST_DATE "${CURRENT_PROCESS_LAST_UPDATE_DATE}")
	if(NOT LAST_DATE STREQUAL CURRENT_PROCESS_LAST_UPDATE_DATE) # problem
		list(GET DATE_OF_NOW 0 NOW_YEAR)
		list(GET LAST_DATE 0 LAST_YEAR)
		list(GET DATE_OF_NOW 1 NOW_DAY)
		list(GET LAST_DATE 1 LAST_DAY)
		list(GET DATE_OF_NOW 2 NOW_HOUR)
		list(GET LAST_DATE 2 LAST_HOUR)
		list(GET DATE_OF_NOW 3 NOW_MIN)
		list(GET LAST_DATE 3 LAST_MIN)

		math(EXPR NOW_DATE_MINUTES_UTC "525600*${NOW_YEAR} + 1440*${NOW_DAY} + 60*${NOW_HOUR} + ${NOW_MIN}")
		math(EXPR LAST_DATE_MINUTES_UTC "525600*${LAST_YEAR} + 1440*${LAST_DAY} + 60*${LAST_HOUR} + ${LAST_MIN} + 1440")
		if(NOW_DATE_MINUTES_UTC GREATER LAST_DATE_MINUTES_UTC) # if last modification is older than 1440 minutes (== 1 day) ago
			return()
		endif()
		set(${OUTDATED} FALSE PARENT_SCOPE)
	endif()
endif()
endfunction(check_Progress_File_Last_Modification_Outdated)

#.rst:
#
# .. ifmode:: internal
#
#  .. |remove_Progress_File| replace:: ``remove_Progress_File``
#  .. _remove_Progress_File:
#
#  remove_Progress_File
#  --------------------
#
#   .. command:: remove_Progress_File()
#
#    Remove the build progress management file from workspace.
#
function(remove_Progress_File)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
if(EXISTS ${thefile})
	file(REMOVE ${thefile})
endif()
endfunction(remove_Progress_File)


#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Progress_File| replace:: ``update_Progress_File``
#  .. _update_Progress_File:
#
#  update_Progress_File
#  --------------------
#
#   .. command:: update_Progress_File()
#
#    Update progress file with local content.
#
function(update_Progress_File)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
reset_Progress_File()#reset the file but keep its header
# updating information about managed packages
file(APPEND ${thefile} "set(MANAGED_PACKAGES_IN_CURRENT_PROCESS ${MANAGED_PACKAGES_IN_CURRENT_PROCESS})\n")
file(APPEND ${thefile} "set(MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS ${MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS})\n")
foreach(pack IN LISTS MANAGED_PACKAGES_IN_CURRENT_PROCESS)
  file(APPEND ${thefile} "set(${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS ${${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS})\n")
  foreach(vers IN LISTS ${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS)
    file(APPEND ${thefile} "set(${pack}_${vers}_STATE_IN_CURRENT_PROCESS ${${pack}_${vers}_STATE_IN_CURRENT_PROCESS})\n")
  endforeach()
endforeach()
foreach(pack IN LISTS MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS)
  file(APPEND ${thefile} "set(${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS ${${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS})\n")
  foreach(vers IN LISTS ${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS)
    file(APPEND ${thefile} "set(${pack}_${vers}_STATE_IN_CURRENT_PROCESS ${${pack}_${vers}_STATE_IN_CURRENT_PROCESS})\n")
  endforeach()
endforeach()
# updating information about packages version that have been chosen
file(APPEND ${thefile} "set(CHOSEN_PACKAGES_VERSION_IN_CURRENT_PROCESS ${CHOSEN_PACKAGES_VERSION_IN_CURRENT_PROCESS})\n")
foreach(pack IN LISTS CHOSEN_PACKAGES_VERSION_IN_CURRENT_PROCESS)
  file(APPEND ${thefile} "set(${pack}_CHOSEN_VERSION_IN_CURRENT_PROCESS ${${pack}_CHOSEN_VERSION_IN_CURRENT_PROCESS})\n")
  file(APPEND ${thefile} "set(${pack}_CHOSEN_VERSION_IN_CURRENT_PROCESS_REQUESTORS ${${pack}_CHOSEN_VERSION_IN_CURRENT_PROCESS_REQUESTORS})\n")
  file(APPEND ${thefile} "set(${pack}_CHOSEN_VERSION_IN_CURRENT_PROCESS_IS_EXACT ${${pack}_CHOSEN_VERSION_IN_CURRENT_PROCESS_IS_EXACT})\n")
  file(APPEND ${thefile} "set(${pack}_CHOSEN_VERSION_IN_CURRENT_PROCESS_IS_SYSTEM ${${pack}_CHOSEN_VERSION_IN_CURRENT_PROCESS_IS_SYSTEM})\n")
endforeach()
#memorize if an update of used contribution spaces has been made
file(APPEND ${thefile} "set(CONTRBUTION_SPACES_UPDATED ${CONTRBUTION_SPACES_UPDATED})\n")
endfunction(update_Progress_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Managed_Package_In_Current_Process| replace:: ``add_Managed_Package_In_Current_Process``
#  .. _add_Managed_Package_In_Current_Process:
#
#  add_Managed_Package_In_Current_Process
#  --------------------------------------
#
#   .. command:: add_Managed_Package_In_Current_Process(package version state external)
#
#    Add a managed package in the build progress management file. Add nothing if the package has already been taken into account.
#
#      :package: the name of managed package.
#      :version: the version of the managed package.
#      :state: the state of managed package (SUCCESS, FAILURE).
#      :external: if TRUE the managed package is an external package.
#
function(add_Managed_Package_In_Current_Process package version state external)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
if(EXISTS ${thefile})
	include (${thefile})
	#updating variables
	if(external)
		list(APPEND MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS ${package})
		list(REMOVE_DUPLICATES MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS)
		list(APPEND ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS "${version}")
		list(REMOVE_DUPLICATES ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS)
		set(${package}_${version}_STATE_IN_CURRENT_PROCESS ${state})
	else()
		list(APPEND MANAGED_PACKAGES_IN_CURRENT_PROCESS ${package})
		list(REMOVE_DUPLICATES MANAGED_PACKAGES_IN_CURRENT_PROCESS)
    if(version)
      get_Version_String_Numbers(${version} major minor patch)
      if(DEFINED major)# valid version string
        list(APPEND ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS "${version}")
        list(REMOVE_DUPLICATES ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS)
        set(${package}_${version}_STATE_IN_CURRENT_PROCESS ${state})
      endif()
    endif()
	endif()
  update_Progress_File()
endif()
endfunction(add_Managed_Package_In_Current_Process)


#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Chosen_Package_Version_In_Current_Process| replace:: ``add_Chosen_Package_Version_In_Current_Process``
#  .. _add_Chosen_Package_Version_In_Current_Process:
#
#  add_Chosen_Package_Version_In_Current_Process
#  ---------------------------------------------
#
#   .. command:: add_Chosen_Package_Version_In_Current_Process(package version external)
#
#    Set the chosen version for a given package in the build progress management file.
#
#      :package: the name of package.
#      :version: the chosen version of package.
#      :exact: if TRUE package version chosen is exact.
#      :external: if TRUE package is an external package.
#
function(add_Chosen_Package_Version_In_Current_Process package requestor)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
if(EXISTS ${thefile})
	include (${thefile})
  set(version ${${package}_VERSION_STRING})
  if(${package}_REQUIRED_VERSION_EXACT)
    set(exact TRUE)
  else()
    set(exact FALSE)
  endif()
  if(${package}_REQUIRED_VERSION_SYSTEM)#the binary package version is the OS installed version
    set(system TRUE)
  else()
    set(system FALSE)
  endif()
	#updating variables
	list(APPEND CHOSEN_PACKAGES_VERSION_IN_CURRENT_PROCESS ${package})
	list(REMOVE_DUPLICATES CHOSEN_PACKAGES_VERSION_IN_CURRENT_PROCESS)
  if(${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS)#the variable already exists (i.e. a version has already been selected)
    if(version VERSION_GREATER ${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS)#update chosen version only if greater than current one
      set(${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS "${version}")
      set(${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS_REQUESTORS "${requestor}")
      set(${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS_IS_EXACT "${exact}")
      set(${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS_IS_SYSTEM "${system}")
    elseif(version VERSION_EQUAL ${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS AND exact)#the new version constraint is exact so set it
      append_Unique_In_cache(${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS_REQUESTORS "${requestor}")
      set(${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS_IS_EXACT "${exact}")
      set(${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS_IS_SYSTEM "${system}")
    endif()
  else()#not found already so simply set the variables without check
    set(${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS "${version}")
    set(${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS_REQUESTORS "${requestor}")
    set(${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS_IS_EXACT "${exact}")
    set(${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS_IS_SYSTEM "${system}")
  endif()
  update_Progress_File()
  return()
endif()
endfunction(add_Chosen_Package_Version_In_Current_Process)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Contribution_Spaces_Updated_In_Current_Process| replace:: ``set_Contribution_Spaces_Updated_In_Current_Process``
#  .. _set_Contribution_Spaces_Updated_In_Current_Process:
#
#  set_Contribution_Spaces_Updated_In_Current_Process
#  --------------------------------------------------
#
#   .. command:: set_Contribution_Spaces_Updated_In_Current_Process()
#
#    Mark the current process has having performed an update of contribution spaces.
#
function(set_Contribution_Spaces_Updated_In_Current_Process)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
if(EXISTS ${thefile})
	include (${thefile})
  set(CONTRIBUTION_SPACES_UPDATED TRUE)
  update_Progress_File()
  return()
endif()
endfunction(set_Contribution_Spaces_Updated_In_Current_Process)

####################################################################################################
######################## Utility functions to check state of the process ###########################
####################################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Contribution_Spaces_Updated_In_Current_Process| replace:: ``check_Contribution_Spaces_Updated_In_Current_Process``
#  .. _check_Contribution_Spaces_Updated_In_Current_Process:
#
#  check_Contribution_Spaces_Updated_In_Current_Process
#  ----------------------------------------------------
#
#   .. command:: check_Contribution_Spaces_Updated_In_Current_Process(RESULT)
#
#    Check whether contribution spaces lying in the workspace have already been updated during this run.
#
#      :RESULT: the output variable that is TRUE if contribution spaces have been updated false otherwise.
#
function(check_Contribution_Spaces_Updated_In_Current_Process RESULT)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
set(${RESULT} FALSE PARENT_SCOPE) #not already managed of no file exists
if(EXISTS ${thefile})
	include (${thefile})
  set(${RESULT} ${CONTRIBUTION_SPACES_UPDATED} PARENT_SCOPE) #not already managed of no file exists
endif()
endfunction(check_Contribution_Spaces_Updated_In_Current_Process)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Package_Version_Managed_In_Current_Process| replace:: ``check_Package_Version_Managed_In_Current_Process``
#  .. _check_Package_Version_Managed_In_Current_Process:
#
#  check_Package_Version_Managed_In_Current_Process
#  ------------------------------------------------
#
#   .. command:: check_Package_Version_Managed_In_Current_Process(package version RESULT)
#
#    Check whether a given package version has already been managed (i.e. its build procedure has been launched) since beginning of the current build process. This does NOT tell if the package build has been successful or not.
#
#      :package: the name of managed package.
#      :version: the version of the managed package.
#
#      :RESULT: the output variable that is TRUE if the given package version has already been managed in current build process.
#
function(check_Package_Version_Managed_In_Current_Process package version RESULT)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
if(EXISTS ${thefile})
	include (${thefile})
	list(FIND MANAGED_PACKAGES_IN_CURRENT_PROCESS ${package} FOUND)
	if(NOT FOUND EQUAL -1)# native package is already managed
		list(FIND ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS "${version}" FOUND)
		if(NOT FOUND EQUAL -1)# version of this package already managed
			set(${RESULT} TRUE PARENT_SCOPE) #MANAGED !!
			return()
		endif()
	else() #it may be an external package
		list(FIND MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS ${package} FOUND)
		if(NOT FOUND EQUAL -1)# package already managed
			list(FIND ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS ${version} FOUND)
			if(NOT FOUND EQUAL -1)# version of this package already managed
				set(${RESULT} TRUE PARENT_SCOPE) #MANAGED !!
				return()
			endif()
		endif()
	endif()
endif()
set(${RESULT} FALSE PARENT_SCOPE) #not already managed of no file exists
endfunction(check_Package_Version_Managed_In_Current_Process)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Package_Version_State_In_Current_Process| replace:: ``check_Package_Version_State_In_Current_Process``
#  .. _check_Package_Version_State_In_Current_Process:
#
#  check_Package_Version_State_In_Current_Process
#  ----------------------------------------------
#
#   .. command:: check_Package_Version_State_In_Current_Process(package version RESULT)
#
#    Check whether a given package version has already been built/installed/deployed since beginning of the current build process. This DOES tell wether the build of this package has been successful or not.
#
#      :package: the name of managed package.
#      :version: the version of the managed package.
#
#      :RESULT: the output variable that contains the string telling what is the build state of the given package. If build has been successful its value is "SUCCESS", if it failed its value is "FAILED", in other situation its value is "UNKNOWN".
#
function(check_Package_Version_State_In_Current_Process package version RESULT)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
if(EXISTS ${thefile})
	include (${thefile})
	list(FIND MANAGED_PACKAGES_IN_CURRENT_PROCESS ${package} FOUND)
	if(NOT FOUND EQUAL -1)# native package already managed
		list(FIND ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS "${version}" FOUND)
		if(NOT FOUND EQUAL -1)# version of this package already managed
			set(${RESULT} ${${package}_${version}_STATE_IN_CURRENT_PROCESS} PARENT_SCOPE) #not already managed or no file exists
			return()
		endif()
	else() #it may be an external package
		list(FIND MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS ${package} FOUND)
		if(NOT FOUND EQUAL -1)# package already managed
			list(FIND ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS ${version} FOUND)
			if(NOT FOUND EQUAL -1)# version of this package already managed
				set(${RESULT} ${${package}_${version}_STATE_IN_CURRENT_PROCESS} PARENT_SCOPE) #not already managed of no file exists
				return()
			endif()
		endif()
	endif()
endif()
set(${RESULT} "UNKNOWN" PARENT_SCOPE) #not already managed or no file exists
endfunction(check_Package_Version_State_In_Current_Process)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Package_Managed_In_Current_Process| replace:: ``check_Package_Managed_In_Current_Process``
#  .. _check_Package_Managed_In_Current_Process:
#
#  check_Package_Managed_In_Current_Process
#  ----------------------------------------
#
#   .. command:: check_Package_Managed_In_Current_Process(package RESULT)
#
#    Check whether a given package has already been managed since beginning of the current build process. This does NOT tell wether the build of this package has been successful or not.
#
#      :package: the name of managed package.
#
#      :RESULT: the output variable that is TRUE if the given package has already been managed in current build process.
#
function(check_Package_Managed_In_Current_Process package RESULT)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
if(EXISTS ${thefile})
	include (${thefile})
	list(FIND MANAGED_PACKAGES_IN_CURRENT_PROCESS ${package} FOUND)
	if(NOT FOUND EQUAL -1)# package already managed
		set(${RESULT} TRUE PARENT_SCOPE) #MANAGED !!
		return()
  else() #it may be an external package
  	list(FIND MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS ${package} FOUND)
  	if(NOT FOUND EQUAL -1)# package already managed
  		set(${RESULT} TRUE PARENT_SCOPE) #MANAGED !!
  		return()
  	endif()
  endif()
endif()
set(${RESULT} FALSE PARENT_SCOPE) #not already managed of no file exists
endfunction(check_Package_Managed_In_Current_Process)


#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Chosen_Version_In_Current_Process| replace:: ``get_Chosen_Version_In_Current_Process``
#  .. _get_Chosen_Version_In_Current_Process:
#
#  get_Chosen_Version_In_Current_Process
#  -------------------------------------
#
#   .. command:: get_Chosen_Version_In_Current_Process(VERSION REQUESTORS IS_EXACT IS_SYSTEM package)
#
#    Get the version of the given package that has been previously selected during the build process.
#
#      :package: the name of the given package.
#
#      :VERSION: the output variable that contains the chosen version number.
#      :REQUESTORS: the output variable that contains the list of packages that require the chosen version.
#      :IS_EXACT: the output variable that is TRUE if the chosen version must be exact.
#      :IS_SYSTEM: the output variable that is TRUE if the chosen version is the OS installed version.
#
function(get_Chosen_Version_In_Current_Process VERSION REQUESTORS IS_EXACT IS_SYSTEM package)
set(${VERSION} PARENT_SCOPE)
set(${IS_EXACT} FALSE PARENT_SCOPE)
set(${IS_SYSTEM} FALSE PARENT_SCOPE)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
if(EXISTS ${thefile})
	include (${thefile})
  list(FIND CHOSEN_PACKAGES_VERSION_IN_CURRENT_PROCESS ${package} FOUND)
	if(NOT FOUND EQUAL -1)# there is a chosen version for that package
    set(${VERSION} ${${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS} PARENT_SCOPE)
    set(${REQUESTORS} ${${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS_REQUESTORS} PARENT_SCOPE)
		set(${IS_EXACT} ${${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS_IS_EXACT} PARENT_SCOPE)
    set(${IS_SYSTEM} ${${package}_CHOSEN_VERSION_IN_CURRENT_PROCESS_IS_SYSTEM} PARENT_SCOPE)
		return()
  else()
      return()
  endif()
endif()
endfunction(get_Chosen_Version_In_Current_Process)

###########################################################################################
######################## Control progress of a current process ############################
###########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |begin_Progress| replace:: ``begin_Progress``
#  .. _begin_Progress:
#
#  begin_Progress
#  --------------
#
#   .. command:: begin_Progress(name NEED_REMOVE)
#
#    Declare the beginning of a build process.
#
#      :name: the name of of the process that launch the build (package or script name).
#
#      :NEED_REMOVE: the output variable that is TRUE if the build process management file must be removed in current process, FALSE otherwise. It is used to manage recursion in the build process, only the call to begin_Progress in first calling context will return TRUE.
#
function(begin_Progress name NEED_REMOVE)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
set(RESET_FILE FALSE)
if(EXISTS ${thefile})
	if(name STREQUAL "workspace") #launch from workspace => remove the old file
		set(RESET_FILE TRUE)
	else()
		check_Progress_File_Last_Modification_Outdated(OUTDATED CONTEXT)
		if(OUTDATED #file is too old
			OR CONTEXT STREQUAL name) #the launcher context is the current one... we can reset the file
			set(RESET_FILE TRUE)
		endif()
	endif()
else()#file not exists yet so this is the role of the package to supress it
	set(RESET_FILE TRUE)
endif()

if(RESET_FILE)
	init_Progress_File(${name})
	set(${NEED_REMOVE} TRUE PARENT_SCOPE)#remove the file even if it was existing before
else()
	set(${NEED_REMOVE} FALSE PARENT_SCOPE)#no need to manage the removal of the file if it was existing before (manage by another CMake file)
endif()
endfunction(begin_Progress)

#.rst:
#
# .. ifmode:: internal
#
#  .. |finish_Progress| replace:: ``finish_Progress``
#  .. _finish_Progress:
#
#  finish_Progress
#  ---------------
#
#   .. command:: finish_Progress(need_remove)
#
#    Declare the end of a build process.
#
#      :need_remove: if TRUE then the build process management file will be removed by the current process. Take the value of the variable return by the call to begin_Progress() in the same context.
#
function(finish_Progress need_remove)
if(EXISTS ${WORKSPACE_DIR}/build/pid_progress.cmake AND need_remove)
	remove_Progress_File()
endif()
endfunction(finish_Progress)

#.rst:
#
# .. ifmode:: internal
#
#  .. |some_Packages_Managed_Last_Time| replace:: ``some_Packages_Managed_Last_Time``
#  .. _some_Packages_Managed_Last_Time:
#
#  some_Packages_Managed_Last_Time
#  --------------------------------
#
#   .. command:: some_Packages_Managed_Last_Time(DEPLOYED)
#
#    Get the packages managed in last build process.
#
#      :DEPLOYED: the output variable that is TRUE if some packages have been managed in last build process.
#
function(some_Packages_Managed_Last_Time DEPLOYED)
set(${DEPLOYED} FALSE PARENT_SCOPE)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
if(EXISTS ${thefile} AND (MANAGED_PACKAGES_IN_CURRENT_PROCESS OR MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS))
	set(${DEPLOYED} TRUE PARENT_SCOPE)
endif()
endfunction(some_Packages_Managed_Last_Time)

#.rst:
#
# .. ifmode:: internal
#
#  .. |print_Managed_Packages| replace:: ``print_Managed_Packages``
#  .. _print_Managed_Packages:
#
#  print_Managed_Packages
#  -----------------------
#
#   .. command:: print_Managed_Packages()
#
#   Print information about the packages managed in last build process.
#
function (print_Managed_Packages)
set(thefile ${WORKSPACE_DIR}/build/pid_progress.cmake)
if(EXISTS ${thefile})
	include (${thefile})
	foreach(pack IN LISTS MANAGED_PACKAGES_IN_CURRENT_PROCESS)
		set(TO_PRINT "${pack}, versions :")
		foreach(vers IN LISTS ${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS)
			string(CONCAT TO_PRINT ${TO_PRINT} " ${vers}(${${pack}_${vers}_STATE_IN_CURRENT_PROCESS})")
		endforeach()
		message("${TO_PRINT}")
	endforeach()
	foreach(pack IN LISTS MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS)
		set(TO_PRINT "${pack}, versions :")
		foreach(vers IN LISTS ${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS)
			string(CONCAT TO_PRINT ${TO_PRINT} " ${vers}(${${pack}_${vers}_STATE_IN_CURRENT_PROCESS})")
		endforeach()
		message("${TO_PRINT}")
	endforeach()
endif()
endfunction(print_Managed_Packages)
