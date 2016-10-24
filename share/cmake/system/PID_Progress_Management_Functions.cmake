
#########################################################################################
#	This file is part of the program PID						#
#  	Program description : build system supportting the PID methodology  		#
#  	Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique 	#
#	et de Microelectronique de Montpellier). All Right reserved.			#
#											#
#	This software is free software: you can redistribute it and/or modify		#
#	it under the terms of the CeCILL-C license as published by			#
#	the CEA CNRS INRIA, either version 1						#
#	of the License, or (at your option) any later version.				#
#	This software is distributed in the hope that it will be useful,		#
#	but WITHOUT ANY WARRANTY; without even the implied warranty of			#
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the			#
#	CeCILL-C License for more details.						#
#											#
#	You can find the complete license description on the official website 		#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
#########################################################################################

#################################################################################################################
######################## Utility functions to change the content of the progress file ###########################
#################################################################################################################

### function to create the build_management_file in workspace
function(init_Progress_File name)
set(thefile ${WORKSPACE_DIR}/pid/pid_progress.cmake)
file(WRITE ${thefile} "set(CURRENT_PROCESS_LAUNCHER ${name})\n")
string(TIMESTAMP TIME_VAR "%Y-%j-%H-%M" UTC)
file(APPEND ${thefile} "set(CURRENT_PROCESS_LAUNCH_DATE ${TIME_VAR})\n")
file(APPEND ${thefile} "set(CURRENT_PROCESS_LAST_UPDATE_DATE ${TIME_VAR})\n")
endfunction(init_Progress_File)

### function to reset the build_management_file in workspace, after modification
function(reset_Progress_File)
set(thefile ${WORKSPACE_DIR}/pid/pid_progress.cmake)
file(WRITE ${thefile} "set(CURRENT_PROCESS_LAUNCHER ${CURRENT_PROCESS_LAUNCHER})\n")
file(APPEND ${thefile} "set(CURRENT_PROCESS_LAUNCH_DATE ${CURRENT_PROCESS_LAUNCH_DATE})\n")

string(TIMESTAMP TIME_VAR "%Y-%j-%H-%M" UTC)
file(APPEND ${thefile} "set(CURRENT_PROCESS_LAST_UPDATE_DATE ${TIME_VAR})\n")
endfunction(reset_Progress_File)

### function to reset the build_management_file in workspace, after modification
function(check_Progress_File_Last_Modification_Outdated OUTDATED CONTEXT)
set(thefile ${WORKSPACE_DIR}/pid/pid_progress.cmake)
include (${thefile})
set(${OUTDATED} TRUE PARENT_SCOPE)
set(${CONTEXT} ${CURRENT_PROCESS_LAUNCHER} PARENT_SCOPE)
string(TIMESTAMP TIME_VAR "%Y-%j-%H-%M" UTC)
string(REGEX REPLACE "^([0-9]+)-([0-9]+)-([0-9]+)-([0-9]+)$" "\\1;\\2;\\3;\\4" DATE_OF_NOW ${TIME_VAR})
if(NOT DATE_OF_NOW STREQUAL TIME_VAR) # problem
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
		math(EXPR LAST_DATE_MINUTES_UTC "525600*${LAST_YEAR} + 1440*${LAST_DAY} + 60*${LAST_HOUR} + ${LAST_MIN} + 20")
		if(NOW_DATE_MINUTES_UTC GREATER LAST_DATE_MINUTES_UTC) # if last modification is older than 20 minutes ago
			return()
		endif()
		set(${OUTDATED} FALSE PARENT_SCOPE)
	endif()
endif()
endfunction(check_Progress_File_Last_Modification_Outdated)

### function to remove the build_management_file in workspace
function(remove_Progress_File)
set(thefile ${WORKSPACE_DIR}/pid/pid_progress.cmake)
if(EXISTS ${thefile})
	file(REMOVE ${thefile})
endif()
endfunction(remove_Progress_File)

### function to add an already built in the pid_progress of the workspace
### add nothing if the package has already been taken into account
function(add_Managed_Package_In_Current_Process package version state external)
set(thefile ${WORKSPACE_DIR}/pid/pid_progress.cmake)
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
		get_Version_String_Numbers(${version} major minor patch)
		list(APPEND ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS "${major}.${minor}")
		list(REMOVE_DUPLICATES ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS)
		set(${package}_${major}.${minor}_STATE_IN_CURRENT_PROCESS ${state})
	endif()
	reset_Progress_File()
	file(APPEND ${thefile} "set(MANAGED_PACKAGES_IN_CURRENT_PROCESS ${MANAGED_PACKAGES_IN_CURRENT_PROCESS})\n")
	file(APPEND ${thefile} "set(MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS ${MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS})\n")
	foreach(pack IN ITEMS ${MANAGED_PACKAGES_IN_CURRENT_PROCESS})
		file(APPEND ${thefile} "set(${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS ${${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS})\n")
		foreach(vers IN ITEMS ${${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS})
			file(APPEND ${thefile} "set(${pack}_${vers}_STATE_IN_CURRENT_PROCESS ${${pack}_${vers}_STATE_IN_CURRENT_PROCESS})\n")
		endforeach()
	endforeach()
	foreach(pack IN ITEMS ${MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS})
		file(APPEND ${thefile} "set(${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS ${${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS})\n")
		foreach(vers IN ITEMS ${${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS})
			file(APPEND ${thefile} "set(${pack}_${vers}_STATE_IN_CURRENT_PROCESS ${${pack}_${vers}_STATE_IN_CURRENT_PROCESS})\n")
		endforeach()
	endforeach()
endif()
endfunction(add_Managed_Package_In_Current_Process)


####################################################################################################
######################## Utility functions to check state of the process ###########################
####################################################################################################

### function to test if a given package version has already been built/installed/deployed since beginning of the process
function(check_Package_Version_Managed_In_Current_Process package version RES)
set(thefile ${WORKSPACE_DIR}/pid/pid_progress.cmake)
if(EXISTS ${thefile})
	include (${thefile})
	list(FIND MANAGED_PACKAGES_IN_CURRENT_PROCESS ${package} FOUND)
	if(NOT FOUND EQUAL -1)# native package is already managed
		get_Version_String_Numbers(${version} major minor patch)
		list(FIND ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS "${major}.${minor}" FOUND)
		if(NOT FOUND EQUAL -1)# version of this package already managed
			set(${RES} TRUE PARENT_SCOPE) #MANAGED !!
			return()
		endif()
	else() #it may be an external package
		list(FIND MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS ${package} FOUND)
		if(NOT FOUND EQUAL -1)# package already managed
			list(FIND ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS ${version} FOUND)
			if(NOT FOUND EQUAL -1)# version of this package already managed
				set(${RES} TRUE PARENT_SCOPE) #MANAGED !!
				return()
			endif()
		endif()
	endif() 
endif()
set(${RES} FALSE PARENT_SCOPE) #not already managed of no file exists
endfunction(check_Package_Version_Managed_In_Current_Process)

### function to test if a given package version has already been built/installed/deployed since beginning of the process
function(check_Package_Version_State_In_Current_Process package version RES)
set(thefile ${WORKSPACE_DIR}/pid/pid_progress.cmake)
if(EXISTS ${thefile})
	include (${thefile})
	list(FIND MANAGED_PACKAGES_IN_CURRENT_PROCESS ${package} FOUND)
	if(NOT FOUND EQUAL -1)# native package already managed
		get_Version_String_Numbers(${version} major minor patch)
		list(FIND ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS "${major}.${minor}" FOUND)
		if(NOT FOUND EQUAL -1)# version of this package already managed
			set(${RES} ${${package}_${major}.${minor}_STATE_IN_CURRENT_PROCESS} PARENT_SCOPE) #not already managed or no file exists
			return()
		endif()
	else() #it may be an external package
		list(FIND MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS ${package} FOUND)
		if(NOT FOUND EQUAL -1)# package already managed
			list(FIND ${package}_MANAGED_VERSIONS_IN_CURRENT_PROCESS ${version} FOUND)
			if(NOT FOUND EQUAL -1)# version of this package already managed
				set(${RES} ${${package}_${version}_STATE_IN_CURRENT_PROCESS} PARENT_SCOPE) #not already managed of no file exists
				return()
			endif()
		endif()
	endif() 
endif()
set(${RES} "UNKNOWN" PARENT_SCOPE) #not already managed or no file exists
endfunction(check_Package_Version_State_In_Current_Process)


### function to test if a package has already been built/installed/deployed since beginning of the process
function(check_Package_Managed_In_Current_Process package RES)
set(thefile ${WORKSPACE_DIR}/pid/pid_progress.cmake)
if(EXISTS ${thefile})
	include (${thefile})
	list(FIND MANAGED_PACKAGES_IN_CURRENT_PROCESS ${package} FOUND)
	if(NOT FOUND EQUAL -1)# package already managed
		set(${RES} TRUE PARENT_SCOPE) #MANAGED !!
		return()
	endif()
else() #it may be an external package
	list(FIND MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS ${package} FOUND)
	if(NOT FOUND EQUAL -1)# package already managed
		set(${RES} TRUE PARENT_SCOPE) #MANAGED !!
		return()
	endif()
endif()
set(${RES} FALSE PARENT_SCOPE) #not already managed of no file exists
endfunction(check_Package_Managed_In_Current_Process)


###########################################################################################
######################## Control progress of a current process ############################
###########################################################################################

function(begin_Progress name NEED_REMOVE)
set(thefile ${WORKSPACE_DIR}/pid/pid_progress.cmake)
set(RESET_FILE FALSE)
if(EXISTS ${thefile})
	if(name STREQUAL "workspace") #launch from workspace => remove the old file 	
		set(RESET_FILE TRUE)
	else()
		check_Progress_File_Last_Modification_Outdated(OUTDATED CONTEXT)
		if(OUTDATED)
			set(RESET_FILE TRUE)
		endif()
	endif()
else()
	set(RESET_FILE TRUE)
endif()

if(RESET_FILE)
	init_Progress_File(${name})
	set(${NEED_REMOVE} TRUE PARENT_SCOPE)#remove the file even if it was existing before
else()
	set(${NEED_REMOVE} FALSE PARENT_SCOPE)#no need to manage the removal of the file if it was existing before (manage by another CMake file)
endif()
endfunction(begin_Progress)

###
function(finish_Progress need_remove)
if(EXISTS ${WORKSPACE_DIR}/pid/pid_progress.cmake AND need_remove)
	remove_Progress_File()
endif()
endfunction(finish_Progress)

###
function(some_Packages_Deployed_Last_Time DEPLOYED)
set(${DEPLOYED} FALSE PARENT_SCOPE)
set(thefile ${WORKSPACE_DIR}/pid/pid_progress.cmake)
if(EXISTS ${thefile} AND (MANAGED_PACKAGES_IN_CURRENT_PROCESS OR MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS))
	set(${DEPLOYED} TRUE PARENT_SCOPE)
endif()
endfunction(some_Packages_Deployed_Last_Time)

###
function (print_Deployed_Packages)
set(thefile ${WORKSPACE_DIR}/pid/pid_progress.cmake)
if(EXISTS ${thefile})
	include (${thefile})
	foreach(pack IN ITEMS ${MANAGED_PACKAGES_IN_CURRENT_PROCESS})
		set(TO_PRINT "${pack}, versions :")
		foreach(vers IN ITEMS ${${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS})
			string(CONCAT TO_PRINT ${TO_PRINT} " ${vers}(${${pack}_${vers}_STATE_IN_CURRENT_PROCESS})")
		endforeach()
		message("${TO_PRINT}")
	endforeach()
	foreach(pack IN ITEMS ${MANAGED_EXTERNAL_PACKAGES_IN_CURRENT_PROCESS})
		set(TO_PRINT "${pack}, versions :")
		foreach(vers IN ITEMS ${${pack}_MANAGED_VERSIONS_IN_CURRENT_PROCESS})
			string(CONCAT TO_PRINT ${TO_PRINT} " ${vers}(${${pack}_${vers}_STATE_IN_CURRENT_PROCESS})")
		endforeach()
		message("${TO_PRINT}")
	endforeach()
endif()
endfunction(print_Deployed_Packages)

