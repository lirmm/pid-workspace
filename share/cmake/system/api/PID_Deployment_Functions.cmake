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
if(PID_DEPLOYMENT_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_DEPLOYMENT_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)

#############################################################################################
############### API functions for managing references on dependent packages #################
#############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Reference_File| replace:: ``generate_Package_Reference_File``
#  .. _generate_Package_Reference_File:
#
#  generate_Package_Reference_File
#  -------------------------------
#
#   .. command:: generate_Package_Reference_File(pathtonewfile)
#
#      Generate the reference file used to retrieve the currently built package from online repositories (source git repository and binaries repositories).
#
#      :pathtonewfile: The path where to generate the reference file.
#
function(generate_Package_Reference_File pathtonewfile)
set(file ${pathtonewfile})
file(WRITE ${file} "")
file(APPEND ${file} "#### referencing package ${PROJECT_NAME} mode ####\n")
file(APPEND ${file} "set(${PROJECT_NAME}_MAIN_AUTHOR ${${PROJECT_NAME}_MAIN_AUTHOR} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_MAIN_INSTITUTION ${${PROJECT_NAME}_MAIN_INSTITUTION} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_CONTACT_MAIL ${${PROJECT_NAME}_CONTACT_MAIL} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK ${${PROJECT_NAME}_FRAMEWORK} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_SITE_ROOT_PAGE ${${PROJECT_NAME}_SITE_ROOT_PAGE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PROJECT_PAGE ${${PROJECT_NAME}_PROJECT_PAGE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_SITE_GIT_ADDRESS ${${PROJECT_NAME}_SITE_GIT_ADDRESS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_SITE_INTRODUCTION \"${${PROJECT_NAME}_SITE_INTRODUCTION}\" CACHE INTERNAL \"\")\n")

set(res_string "")
foreach(auth IN LISTS ${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS)
	list(APPEND res_string ${auth})
endforeach()
file(APPEND ${file} "set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS \"${res_string}\" CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_DESCRIPTION \"${${PROJECT_NAME}_DESCRIPTION}\" CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_YEARS ${${PROJECT_NAME}_YEARS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_LICENSE ${${PROJECT_NAME}_LICENSE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_ADDRESS ${${PROJECT_NAME}_ADDRESS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PUBLIC_ADDRESS ${${PROJECT_NAME}_PUBLIC_ADDRESS} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_CATEGORIES)
file(APPEND ${file} "set(${PROJECT_NAME}_CATEGORIES \"${${PROJECT_NAME}_CATEGORIES}\" CACHE INTERNAL \"\")\n")
else()
file(APPEND ${file} "set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL \"\")\n")
endif()

############################################################################
###### all available versions of the package for which there is a ##########
###### direct reference to a downloadable binary for a given platform ######
############################################################################
file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCES ${${PROJECT_NAME}_REFERENCES} CACHE INTERNAL \"\")\n")
foreach(ref_version IN LISTS ${PROJECT_NAME}_REFERENCES) #for each available version, all os for which there is a reference
	file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version} ${${PROJECT_NAME}_REFERENCE_${ref_version}} CACHE INTERNAL \"\")\n")
	foreach(ref_platform IN LISTS ${PROJECT_NAME}_REFERENCE_${ref_version})#for each version & os, all arch for which there is a reference
		file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL ${${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG ${${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG} CACHE INTERNAL \"\")\n")
	endforeach()
endforeach()
endfunction(generate_Package_Reference_File)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Wrapper_Reference_File| replace:: ``generate_Wrapper_Reference_File``
#  .. _generate_Wrapper_Reference_File:
#
#  generate_Wrapper_Reference_File
#  -------------------------------
#
#   .. command:: generate_Wrapper_Reference_File(pathtonewfile)
#
#      Generate the reference file used to retrieve the currently built wrapper from online repositories (source git repository and binaries repositories).
#
#      :pathtonewfile: The path where to generate the reference file.
#
function(generate_Wrapper_Reference_File pathtonewfile)
set(file ${pathtonewfile})
#1) write information related only to the wrapper project itself (not used in resulting installed external package description)
file(WRITE ${file} "")
file(APPEND ${file} "#### referencing wrapper of external package ${PROJECT_NAME} ####\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PID_WRAPPER_CONTACT_AUTHOR ${${PROJECT_NAME}_MAIN_AUTHOR} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PID_WRAPPER_CONTACT_INSTITUTION ${${PROJECT_NAME}_MAIN_INSTITUTION} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PID_WRAPPER_CONTACT_MAIL ${${PROJECT_NAME}_CONTACT_MAIL} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PID_WRAPPER_SITE_ROOT_PAGE ${${PROJECT_NAME}_SITE_ROOT_PAGE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PID_WRAPPER_PROJECT_PAGE ${${PROJECT_NAME}_PROJECT_PAGE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PID_WRAPPER_SITE_GIT_ADDRESS ${${PROJECT_NAME}_SITE_GIT_ADDRESS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PID_WRAPPER_SITE_INTRODUCTION \"${${PROJECT_NAME}_SITE_INTRODUCTION}\" CACHE INTERNAL \"\")\n")

set(res_string "")
foreach(auth IN LISTS ${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS)
	list(APPEND res_string ${auth})
endforeach()
file(APPEND ${file} "set(${PROJECT_NAME}_PID_WRAPPER_AUTHORS_AND_INSTITUTIONS \"${res_string}\" CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PID_WRAPPER_YEARS ${${PROJECT_NAME}_YEARS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PID_WRAPPER_LICENSE ${${PROJECT_NAME}_LICENSE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PID_WRAPPER_ADDRESS ${${PROJECT_NAME}_ADDRESS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PID_WRAPPER_PUBLIC_ADDRESS ${${PROJECT_NAME}_PUBLIC_ADDRESS} CACHE INTERNAL \"\")\n")

#2) write information shared between wrapper and its external packages
file(APPEND ${file} "set(${PROJECT_NAME}_DESCRIPTION \"${${PROJECT_NAME}_DESCRIPTION}\" CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_FRAMEWORK ${${PROJECT_NAME}_FRAMEWORK} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_CATEGORIES)
file(APPEND ${file} "set(${PROJECT_NAME}_CATEGORIES \"${${PROJECT_NAME}_CATEGORIES}\" CACHE INTERNAL \"\")\n")
else()
file(APPEND ${file} "set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL \"\")\n")
endif()

#3) write information related to original project only
file(APPEND ${file} "set(${PROJECT_NAME}_AUTHORS \"${${PROJECT_NAME}_WRAPPER_ORIGINAL_PROJECT_AUTHORS}\" CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_PROJECT_SITE ${${PROJECT_NAME}_WRAPPER_ORIGINAL_PROJECT_SITE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_LICENSES ${${PROJECT_NAME}_WRAPPER_ORIGINAL_PROJECT_LICENSES} CACHE INTERNAL \"\")\n")


############################################################################
###### all available versions of the package for which there is a ##########
###### direct reference to a downloadable binary for a given platform ######
############################################################################
file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCES ${${PROJECT_NAME}_REFERENCES} CACHE INTERNAL \"\")\n")
foreach(ref_version IN LISTS ${PROJECT_NAME}_REFERENCES) #for each available version, all os for which there is a reference
	file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version} ${${PROJECT_NAME}_REFERENCE_${ref_version}} CACHE INTERNAL \"\")\n")
	foreach(ref_platform IN LISTS ${PROJECT_NAME}_REFERENCE_${ref_version})#for each version & os, all arch for which there is a reference
		file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL ${${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG ${${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG} CACHE INTERNAL \"\")\n")
	endforeach()
endforeach()
endfunction(generate_Wrapper_Reference_File)


#############################################################################################
############ Generic functions to deploy packages (either source or binary, native or #######
################ external) in the workspace #################################################
#############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Package_Dependencies| replace:: ``resolve_Package_Dependencies``
#  .. _resolve_Package_Dependencies:
#
#  resolve_Package_Dependencies
#  ----------------------------
#
#   .. command:: resolve_Package_Dependencies(package mode)
#
#      Resolve dependencies of a given package: each dependency is defined as a path to the adequate package version located in the workspace. This can lead to the install of packages either direct or undirect dependencies of the target package.
#
#      :package: The name of given package for which dependencies are resolved.
#
#      :mode: The build mode (Debug or Release) of the package.
#
#      :first_time: the boolean indicating (if true) that the resolution process has been launch for firt time in build process, FALSE otherwise.
#
function(resolve_Package_Dependencies package mode first_time)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
################## management of configuration : for both external and native packages ##################
foreach(config IN LISTS ${package}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX}) ## all configuration constraints must be satisfied
  check_System_Configuration_With_Arguments(SYSCHECK_RESULT BINARY_CONTRAINTS ${config} ${package}_PLATFORM_CONFIGURATION_${config}_ARGS${VAR_SUFFIX})
  if(NOT SYSCHECK_RESULT)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to resolve configuration ${config} required by package ${package}.")
    return()
  endif()
endforeach()

################## management of external packages : for both external and native packages ##################
set(list_of_conflicting_dependencies)
# 1) managing external package dependencies (the list of dependent packages is defined as ${package}_EXTERNAL_DEPENDENCIES)
# - locating dependent external packages in the workspace and configuring their build variables recursively
foreach(dep_ext_pack IN LISTS ${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
	# 1) resolving direct dependencies
	resolve_External_Package_Dependency(IS_COMPATIBLE ${package} ${dep_ext_pack} ${mode})
	if(NOT ${dep_ext_pack}_FOUND)#not found in local workspace => need to install them
		# list(APPEND TO_INSTALL_EXTERNAL_DEPS ${dep_ext_pack})
    if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD) #download or clone of dependencies is automatic
      install_External_Package(INSTALL_OK ${dep_ext_pack} FALSE FALSE)
      if(NOT INSTALL_OK)
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to install external package: ${dep_ext_pack}. This bug is maybe due to bad referencing of this package. Please have a look in workspace and try to find ReferExternal${dep_ext_pack}.cmake file in share/cmake/references folder.")
  			return()
  		endif()
      resolve_External_Package_Dependency(IS_COMPATIBLE ${package} ${dep_ext_pack} ${mode})#launch again the resolution
      if(NOT ${dep_ext_pack}_FOUND)#this time the package must be found since installed => internal BUG in PID
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        message(FATAL_ERROR "[PID] INTERNAL ERROR : impossible to find installed external package ${dep_ext_pack}. This is an internal bug maybe due to a bad find file for ${dep_ext_pack}.")
        return()
      elseif(NOT IS_COMPATIBLE)#this time there is really nothing to do since package has been installed so it therically already has all its dependencies compatible (otherwise there is simply no solution)
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent external package ${dep_ext_pack} regarding versions constraints. Search ended when trying to satisfy version coming from package ${package}. All required versions are : ${${dep_ext_pack}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${dep_ext_pack}_REQUIRED_VERSION_EXACT}, Last exact version required is ${${package}_EXTERNAL_DEPENDENCY_${dep_ext_pack}_VERSION${VAR_SUFFIX}}.")
        return()
      else()#OK resolution took place !!
        add_Chosen_Package_Version_In_Current_Process(${dep_ext_pack})#memorize chosen version in progress file to share this information with dependent packages
        if(${dep_ext_pack}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}) #are there any dependency (external only) for this external package
          resolve_Package_Dependencies(${dep_ext_pack} ${mode} TRUE)#recursion : resolving dependencies for each external package dependency
        endif()
      endif()
    else()
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR :  external package dependency to ${dep_ext_pack} cannot be resolved since the automatic download of packages is not activated in ${PROJECT_NAME}. You may set the REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD option to ON.")
      return()
    endif()
  elseif(NOT IS_COMPATIBLE)#the dependency version is not compatible with previous constraints set by other packages
    list(APPEND list_of_conflicting_dependencies ${dep_ext_pack})#try to reinstall it from sources if possible, simply add it to the list of packages to install
  else()#OK resolution took place and is OK
    add_Chosen_Package_Version_In_Current_Process(${dep_ext_pack})#memorize chosen version in progress file to share this information with dependent packages
    if(${dep_ext_pack}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})#the external package has external dependencies !!
      resolve_Package_Dependencies(${dep_ext_pack} ${mode} TRUE)#recursion : resolving dependencies for each external package dependency
    endif()
  endif()
endforeach()

################## for native packages only ##################

# 1) managing package dependencies (the list of dependent packages is defined as ${package}_DEPENDENCIES)
# - locating dependent packages in the workspace and configuring their build variables recursively
foreach(dep_pack IN LISTS ${package}_DEPENDENCIES${VAR_SUFFIX})
	# 1) resolving direct dependencies
	resolve_Native_Package_Dependency(IS_COMPATIBLE ${package} ${dep_pack} ${mode})
	if(NOT ${dep_pack}_FOUND)# package is not found => need to install it
    if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD) #download or clone of dependencies is automatic
      install_Native_Package(INSTALL_OK ${dep_pack} FALSE)
      if(NOT INSTALL_OK)
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to install native package: ${dep_pack}. This bug is maybe due to bad referencing of this package. Please have a look in workspace and try to fond Refer${dep_pack}.cmake file in share/cmake/references folder.")
				return()
  		endif()
      resolve_Native_Package_Dependency(IS_COMPATIBLE ${package} ${dep_pack} ${mode})#launch again the resolution
      if(NOT ${dep_pack}_FOUND)#this time the package must be found since installed => internak BUG in PID
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        message(FATAL_ERROR "[PID] INTERNAL ERROR : impossible to find installed native package ${dep_pack}. This is an internal bug maybe due to a bad find file for ${dep_pack}.")
        return()
      elseif(NOT IS_COMPATIBLE)#this time there is really nothing to do since package has been installed so it therically already has all its dependencies compatible (otherwise there is simply no solution)
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent native package ${dep_pack} regarding versions constraints. Search ended when trying to satisfy version coming from package ${package}. All required versions are : ${${dep_pack}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${dep_pack}_REQUIRED_VERSION_EXACT}, Last exact version required is ${${package}_EXTERNAL_DEPENDENCY_${dep_pack}_VERSION${VAR_SUFFIX}}.")
        return()
      else()#OK resolution took place !!
        add_Chosen_Package_Version_In_Current_Process(${dep_pack})#memorize chosen version in progress file to share this information with dependent packages
        if(${dep_pack}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} OR ${dep_pack}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}) #are there any dependency (external only) for this external package
          resolve_Package_Dependencies(${dep_pack} ${mode} TRUE)#recursion : resolving dependencies for each external package dependency
        endif()
      endif()
    else()
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR :  native package dependency to ${dep_pack} cannot be resolved since the automatic download of packages is not activated in ${PROJECT_NAME}. You may set the REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD option to ON.")
      return()
    endif()
  elseif(NOT IS_COMPATIBLE)#package binary found in install tree but is not compatible !
    list(APPEND list_of_conflicting_dependencies ${dep_pack})
	else()# resolution took place and is OK
    add_Chosen_Package_Version_In_Current_Process(${dep_pack})#memorize chosen version in progress file to share this information with dependent packages
    if(${dep_pack}_DEPENDENCIES${VAR_SUFFIX} OR ${dep_pack}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}) #are there any dependency (native or external) for this package
			resolve_Package_Dependencies(${dep_pack} ${mode} TRUE)#recursion : resolving dependencies for each package dependency
		endif()
  endif()
endforeach()

if(list_of_conflicting_dependencies)#the package has conflicts in its dependencies
  message("[PID] WARNING : package ${package} has conflicting dependencies:")
  foreach(dep IN LISTS list_of_conflicting_dependencies)
    if(${dep}_REQUIRED_VERSION_EXACT)
      if(${dep}_REQUIRED_VERSION_SYSTEM)
        set(OUTPUT_STR "OS version already required is ${${dep}_REQUIRED_VERSION_EXACT}")
      else()
        set(OUTPUT_STR "exact version already required is ${${dep}_REQUIRED_VERSION_EXACT}")
      endif()
    elseif(${dep}_ALL_REQUIRED_VERSIONS)
      set(OUTPUT_STR "already required versions are : ${${dep}_ALL_REQUIRED_VERSIONS}")
    endif()
    get_Package_Type(${dep} PACK_TYPE)
    if(PACK_TYPE STREQUAL "EXTERNAL")
      if(${package}_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX})
        set(str "with version ${${package}_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}")
      else()
        set(str "without version constraint")
      endif()
      message("  - dependent package ${dep} is required ${str}: ${OUTPUT_STR}.")
    else()
      if(${package}_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX})
        set(str "with version ${${package}_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}")
      else()
        set(str "without version constraint")
      endif()
      message("  - dependent package ${dep} is required with version ${${package}_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX}}: ${OUTPUT_STR}.")
    endif()
  endforeach()
  if(NOT first_time)# we are currently trying to reinstall the same package !!
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : Impossible to solve conflicting dependencies for package ${package}. Try to solve these problems by setting adequate versions to dependencies.")
    return()
  else()#OK first time package is resolved during the build process
    message("[PID] INFO: rebuild package ${package} version ${${package}_VERSION_STRING}...")
    get_Package_Type(${package} PACK_TYPE)
    set(INSTALL_OK)
    # reinstall by forcing rebuild of the package => the rebuild will automatically manage and resolve dependencies with current global build constraints
    if(PACK_TYPE STREQUAL "EXTERNAL")
      install_External_Package(INSTALL_OK ${package} TRUE TRUE)
    elseif(PACK_TYPE STREQUAL "NATIVE")
      install_Native_Package(INSTALL_OK ${package} TRUE)
    endif()
    if(INSTALL_OK)
      set(${package}_FIND_VERSION_SYSTEM ${${package}_REQUIRED_VERSION_SYSTEM})#using the memorized contraint on version to set adeqautely which variant (OS or PID) to use
      if(${package}_REQUIRED_VERSION_EXACT)
        set(exact_str "EXACT")
      else()
        set(exact_str "")
      endif()
      find_package(${package} ${${package}_VERSION_STRING} ${exact_str} REQUIRED)#find again the package but this time we impose as constraint the specific version searched
      #TODO maybe use the ${package}_FIND_VERSION_EXACT variable instead of directly EXACT ?
      if(NOT ${package}_FOUND)
        finish_Progress(${GLOBAL_PROGRESS_VAR})
        if(${package}_REQUIRED_VERSION_SYSTEM)
          set(os_str "OS ")
        endif()
        message(FATAL_ERROR "[PID] CRITICAL ERROR : package ${package} with ${os_str}version ${${package}_VERSION_STRING} cannot be found after its redeployment ! No known solution can automatically be found to this problem. Aborting.")
        return()
      endif()
      resolve_Package_Dependencies(${package} ${mode} FALSE)#resolving again the dependencies on same package
    else()# cannot do much more about that !!
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR : package ${package} has conflicting dependencies and the target version ${${package}_VERSION_STRING} cannot be rebuit !")
    return()
    endif()
  endif()
endif()
endfunction(resolve_Package_Dependencies)

#############################################################################################
############## General functions to deploy  Native Packages (binary or source) ##############
#############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Package_Installed_Version| replace:: ``update_Package_Installed_Version``
#  .. _update_Package_Installed_Version:
#
#  update_Package_Installed_Version
#  --------------------------------
#
#   .. command:: update_Package_Installed_Version(package major minor patch exact already_installed)
#
#      Update a package to the given version. Function called by find script subfunctions to automatically update a package, if possible.
#
#      :package: The name of given package to update.
#
#      :major: major number of package version.
#
#      :minor: minor number of package version.
#
#      :patch: patch number of package version.
#
#      :exact: if TRUE the version constraint is exact.
#
#      :already_installed: the list of versions of the package already installed in the workspace.
#
function(update_Package_Installed_Version package major minor patch exact already_installed)
first_Called_Build_Mode(FIRST_TIME) # do the update only once per global configuration of the project
if(FIRST_TIME AND REQUIRED_PACKAGES_AUTOMATIC_UPDATE) #if no automatic download then simply do nothing
	if(NOT major STREQUAL "" AND NOT minor STREQUAL "")
		set(WITH_VERSION TRUE)
    if(patch)
      check_Package_Version_Managed_In_Current_Process(${package} "${major}.${minor}.${patch}" RES)
    else()
      check_Package_Version_Managed_In_Current_Process(${package} "${major}.${minor}" RES)
    endif()
    if(RES STREQUAL "UNKNOWN") #package has not been already updated during this run session
			set(NEED_CHECK_UPDATE TRUE)
		else()
			set(NEED_CHECK_UPDATE FALSE)
		endif()
	else()
		set(WITH_VERSION FALSE)
		check_Package_Managed_In_Current_Process(${package} RES) #as no version constraint apply simply do nothing if the package as already been managed
		if(RES)
			set(NEED_CHECK_UPDATE FALSE)
		else()
			set(NEED_CHECK_UPDATE TRUE)
		endif()
	endif()

	if(NEED_CHECK_UPDATE) #package has not been already updated during this run session
    package_Source_Exists_In_Workspace(SOURCE_EXIST RETURNED_PATH ${package})
		if(SOURCE_EXIST) # updating the source package, if possible
			if(WITH_VERSION)
        if(patch)
				  deploy_Source_Native_Package_Version(IS_DEPLOYED ${package} "${major}.${minor}.${patch}" ${exact} "${already_installed}" FALSE)
        else()
          deploy_Source_Native_Package_Version(IS_DEPLOYED ${package} "${major}.${minor}" ${exact} "${already_installed}" FALSE)
        endif()
      else()
				deploy_Source_Native_Package(IS_DEPLOYED ${package} "${already_installed}" FALSE) #install last version available
			endif()
		else() # updating the binary package, if possible
			include(Refer${package} OPTIONAL RESULT_VARIABLE refer_path)
			if(${refer_path} STREQUAL NOTFOUND)
				message("[PID] ERROR : the reference file for package ${package} cannot be found in the workspace ! Package update aborted.")
				return()
			endif()
			load_Package_Binary_References(LOADED ${package}) #loading binary references to be informed of new released versions
			if(NOT LOADED)
				if(ADDITIONNAL_DEBUG_INFO)
					message("[PID] WARNING : no binary reference for package ${package}. Package update aborted.") #just a warning because this si not a true error in PID development process. May be due to the fact that the package has been installed with sources but sources have been revomed and not the binary
				endif()
			endif()
			if(WITH_VERSION)
        if(patch)
				  deploy_Binary_Native_Package_Version(IS_DEPLOYED ${package} "${major}.${minor}.${patch}" ${exact} "${already_installed}")
        else()
          deploy_Binary_Native_Package_Version(IS_DEPLOYED ${package} "${major}.${minor}" ${exact} "${already_installed}")
        endif()
      else()
				deploy_Binary_Native_Package(IS_DEPLOYED ${package} "${already_installed}") #install last version available
			endif()
		endif()
	endif()
endif()
endfunction(update_Package_Installed_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Required_Native_Package_Version| replace:: ``resolve_Required_Native_Package_Version``
#  .. _resolve_Required_Native_Package_Version:
#
#  resolve_Required_Native_Package_Version
#  ---------------------------------------
#
#   .. command:: resolve_Required_Native_Package_Version(RESOLUTION_OK MINIMUM_VERSION IS_EXACT package)
#
#     Select the adequate version of a given package to be used in current build process.
#
#      :package: The name of the package for which a version must be found.
#
#      :RESOLUTION_OK: the output variable that is TRUE if a version of the package has been proposed by teh resolution process, FALSE otherwise.
#
#      :MINIMUM_VERSION: the output variable that contains the minimum version to use.
#
#      :IS_EXACT: the output variable that is TRUE if MINIMUM_VERSION must be exact, false otherwise.
#
function(resolve_Required_Native_Package_Version RESOLUTION_OK MINIMUM_VERSION IS_EXACT package)

foreach(version IN LISTS ${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX})
	get_Version_String_Numbers("${version}" compare_major compare_minor compared_patch)
  if(NOT DEFINED compare_major)
    finish_Progress(${GLOBAL_PROGRESS_VAR})
    message(FATAL_ERROR "[PID] CRITICAL ERROR : in ${PROJECT_NAME} corrupted version string ${version_string} for dependency to package ${package}.")
  endif()
	if(NOT MAJOR_RESOLVED)#first time
		set(MAJOR_RESOLVED ${compare_major})
		set(CUR_MINOR_RESOLVED ${compare_minor})
    if(compared_patch)
      set(CUR_PATCH_RESOLVED ${compared_patch})
    else()
      set(CUR_PATCH_RESOLVED 0)
    endif()
		if(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX})
			set(CURR_EXACT TRUE)
		else()
			set(CURR_EXACT FALSE)
		endif()
	elseif(NOT compare_major EQUAL MAJOR_RESOLVED)
		set(${RESOLUTION_OK} FALSE PARENT_SCOPE)
		return()
	elseif(CURR_EXACT AND (compare_minor GREATER CUR_MINOR_RESOLVED))
		set(${RESOLUTION_OK} FALSE PARENT_SCOPE)
		return()
	elseif(NOT CURR_EXACT AND (compare_minor GREATER CUR_MINOR_RESOLVED))
		set(CUR_MINOR_RESOLVED ${compare_minor})
    set(CUR_PATCH_RESOLVED 0) #reset the patch version as we changed the minor version number
		if(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX})
			set(CURR_EXACT TRUE)
		else()
			set(CURR_EXACT FALSE)
		endif()
	endif()
endforeach()
set(${RESOLUTION_OK} TRUE PARENT_SCOPE)
set(${MINIMUM_VERSION} "${MAJOR_RESOLVED}.${CUR_MINOR_RESOLVED}.${CUR_PATCH_RESOLVED}" PARENT_SCOPE)
set(${IS_EXACT} ${CURR_EXACT} PARENT_SCOPE)
endfunction(resolve_Required_Native_Package_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |package_Source_Exists_In_Workspace| replace:: ``package_Source_Exists_In_Workspace``
#  .. _package_Source_Exists_In_Workspace:
#
#  package_Source_Exists_In_Workspace
#  ----------------------------------
#
#   .. command:: package_Source_Exists_In_Workspace(EXIST RETURNED_PATH package)
#
#     Check wether the repository of a package already lies in the workspace.
#
#      :package: The name of target package.
#
#      :EXIST: the output variable that is TRUE if repository exists, FALSE otherwise.
#
#      :RETURNED_PATH: the output variable that contains the path to the package reposotiry on filesystem.
#
function(package_Source_Exists_In_Workspace EXIST RETURNED_PATH package)
set(res FALSE)
if(EXISTS ${WORKSPACE_DIR}/packages/${package} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
set(res TRUE)
set(${RETURNED_PATH} ${WORKSPACE_DIR}/packages/${package} PARENT_SCOPE)
endif()
set(${EXIST} ${res} PARENT_SCOPE)
endfunction(package_Source_Exists_In_Workspace)

#.rst:
#
# .. ifmode:: internal
#
#  .. |package_Reference_Exists_In_Workspace| replace:: ``package_Reference_Exists_In_Workspace``
#  .. _package_Reference_Exists_In_Workspace:
#
#  package_Reference_Exists_In_Workspace
#  -------------------------------------
#
#   .. command:: package_Reference_Exists_In_Workspace(EXIST package)
#
#     Check whether the reference file of a given package lies in the workspace.
#
#      :package: The name of target package.
#
#      :EXIST: the output variable that is TRUE if reference file exists, FALSE otherwise.
#
function(package_Reference_Exists_In_Workspace EXIST package)
set(res FALSE)
if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/Refer${package}.cmake)
  set(res TRUE)
endif()
set(${EXIST} ${res} PARENT_SCOPE)
endfunction(package_Reference_Exists_In_Workspace)

#.rst:
#
# .. ifmode:: internal
#
#  .. |install_Native_Package| replace:: ``install_Native_Package``
#  .. _install_Native_Package:
#
#  install_Native_Package
#  ----------------------
#
#   .. command:: install_Native_Package(INSTALL_OK package reinstall)
#
#     Install a given native package in workspace.
#
#      :package: The name of the package to install.
#
#      :reinstall: a boolean to indicate if version must be reinstalled
#
#      :INSTALL_OK: the output variable that is TRUE is package is installed, FALSE otherwise.
#
function(install_Native_Package INSTALL_OK package reinstall)

# 0) test if either reference or source of the package exist in the workspace
set(PATH_TO_SOURCE "")
package_Source_Exists_In_Workspace(IS_EXISTING PATH_TO_SOURCE ${package})
if(IS_EXISTING)
	set(USE_SOURCES TRUE)
  set(REPOSITORY_EXISTS TRUE)
else()
  set(REPOSITORY_EXISTS FALSE)
	package_Reference_Exists_In_Workspace(IS_EXISTING ${package})
	if(IS_EXISTING)
		set(USE_SOURCES FALSE)#by default do not use sources if repository does not lie in workspace
	else()
		set(${INSTALL_OK} FALSE PARENT_SCOPE)
		message("[PID] ERROR : unknown package ${package}, cannot find any source or reference of this package in the workspace.")
		return()
	endif()
endif()
if(reinstall)#the same version must be reinstalled from sources
  # package does not belong to packages to install then it means that its version is not adequate and it must be reinstalled from sources
	set(USE_SOURCES TRUE)# we need to build this package from sources, if any available
  set(NO_VERSION FALSE)# we need to specify a version !
  set(IS_EXACT TRUE)
  set(VERSION_MIN ${${package}_VERSION_STRING})#the version to reinstall is the currenlty used one

  if(NOT REPOSITORY_EXISTS)#avoiding problem when forcing a reinstall while the repository does not exists
    set(DEPLOYED FALSE)
    deploy_Package_Repository(DEPLOYED ${package})
    if(NOT DEPLOYED) # doing the same as for the USE_SOURCES step
      message("[PID] ERROR : When rebuilding package ${package} from source, impossible to clone its repository.")
      set(${INSTALL_OK} FALSE PARENT_SCOPE)
      return()
    endif()
  endif()
elseif(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX})
  # 1) resolve finally required package version (if any specific version required) (major.minor only, patch is let undefined)
	set(POSSIBLE FALSE)
	set(VERSION_MIN)
	set(IS_EXACT FALSE)
	resolve_Required_Native_Package_Version(POSSIBLE VERSION_MIN IS_EXACT ${package})
	if(NOT POSSIBLE)
		message("[PID] ERROR : When deploying package ${package}, impossible to find an adequate version for package ${package}.")
		set(${INSTALL_OK} FALSE PARENT_SCOPE)
		return()
	else()
    if(IS_EXACT)
      message("[PID] INFO : deploying package ${package} with version compatible with exact ${VERSION_MIN}...")
    else()
      message("[PID] INFO : deploying package ${package} with version compatible with ${VERSION_MIN}...")
    endif()
	endif()
	set(NO_VERSION FALSE)
else()
	set(NO_VERSION TRUE)
endif()

if(USE_SOURCES) #package sources reside in the workspace
  if(NO_VERSION)
    deploy_Source_Native_Package(SOURCE_DEPLOYED ${package} "" FALSE) # case when the sources exist but haven't been installed yet (should never happen)
	else()
    deploy_Source_Native_Package_Version(SOURCE_DEPLOYED ${package} ${VERSION_MIN} ${IS_EXACT} "" FALSE)
	endif()
	if(NOT SOURCE_DEPLOYED)
		message("[PID] ERROR : impossible to deploy package ${package} from sources. Try \"by hand\".")
	else()
		set(${INSTALL_OK} TRUE PARENT_SCOPE)
	endif()
else()#using references
	include(Refer${package} OPTIONAL RESULT_VARIABLE refer_path)
	if(refer_path STREQUAL NOTFOUND)
		message("[PID] ERROR : the reference file for package ${package} cannot be found in the workspace ! Package update aborted.")
		return()
	endif()
	load_Package_Binary_References(LOADED ${package}) #loading binary references to be informed of new released versions
	if(NOT LOADED)
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] WARNING : no binary reference for package ${package}. Package update aborted.") #just a warning because this si not a true error in PID development process. May be due to the fact that the package has been installed with sources but sources have been revomed and not the binary
		endif()
	endif()

	set(PACKAGE_BINARY_DEPLOYED FALSE)
	if(NOT refer_path STREQUAL NOTFOUND)
		if(NOT NO_VERSION)#seeking for an adequate version regarding the pattern VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the greatest minor version number
			deploy_Binary_Native_Package_Version(PACKAGE_BINARY_DEPLOYED ${package} ${VERSION_MIN} ${IS_EXACT} "")
		else()# deploying the most up to date version
			deploy_Binary_Native_Package(PACKAGE_BINARY_DEPLOYED ${package} "")
		endif()
	else()
		message("[PID] ERROR : reference file not found for package ${package}!! This is maybe due to a bad release of package ${package}. Please contact the administrator of this package. !!!")
	endif()

	if(PACKAGE_BINARY_DEPLOYED) # if there is ONE adequate reference, downloading and installing it
		set(${INSTALL_OK} TRUE PARENT_SCOPE)
	else()# otherwise, trying to "git clone" the package source (if it can be accessed)
  	set(DEPLOYED FALSE)
  	deploy_Package_Repository(DEPLOYED ${package})
  	if(DEPLOYED) # doing the same as for the USE_SOURCES step
  		if(NOT NO_VERSION)
  			deploy_Source_Native_Package_Version(SOURCE_DEPLOYED ${package} ${VERSION_MIN} ${IS_EXACT} "" FALSE)
  		else()
  			deploy_Source_Native_Package(SOURCE_DEPLOYED ${package} "" FALSE)
  		endif()
    	if(NOT SOURCE_DEPLOYED)
    		set(${INSTALL_OK} FALSE PARENT_SCOPE)
    		message("[PID] ERROR : impossible to build the package ${package} (version ${VERSION_MIN}) from sources. Try \"by hand\".")
    		return()
    	endif()
    	set(${INSTALL_OK} TRUE PARENT_SCOPE)
    else()
    	set(${INSTALL_OK} FALSE PARENT_SCOPE)
    	message("[PID] ERROR : impossible to locate source repository of package ${package} or to find a compatible binary version starting from ${VERSION_MIN}.")
    	return()
		endif()
	endif()
endif()
endfunction(install_Native_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |load_Package_Binary_References| replace:: ``load_Package_Binary_References``
#  .. _load_Package_Binary_References:
#
#  load_Package_Binary_References
#  ------------------------------
#
#   .. command:: load_Package_Binary_References(REFERENCES_FOUND package)
#
#    Get the references to binary archives containing versions of a given package.
#
#      :package: The name of the package.
#
#      :REFERENCES_FOUND: the output variable that is TRUE is package binary references has been found, FALSE otherwise.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        The reference file of the given package must be loaded before this call. No automatic automatic (re)load id performed to improve performance.
#
function(load_Package_Binary_References REFERENCES_FOUND package)
set(${REFERENCES_FOUND} FALSE PARENT_SCOPE)
set(to_include)
if(${package}_FRAMEWORK) #references are deployed in a framework
	if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferFramework${${package}_FRAMEWORK}.cmake)
		#when package is in a framework there is one more indirection to get references (we need to get information about this framework before downloading the reference file)
		include(${WORKSPACE_DIR}/share/cmake/references/ReferFramework${${package}_FRAMEWORK}.cmake )
		set(FRAMEWORK_ADDRESS ${${${package}_FRAMEWORK}_FRAMEWORK_SITE})#get the address of the framework static site
    file(DOWNLOAD ${FRAMEWORK_ADDRESS}/packages/${package}/binaries/binary_references.cmake ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake STATUS res SHOW_PROGRESS TLS_VERIFY OFF)
		list(GET res 0 numeric_error)

		if(numeric_error EQUAL 0 #framework site is online & reference available.
		AND EXISTS ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake)
      set(to_include ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake)
		else() #it may be an external package, try this
			file(DOWNLOAD ${FRAMEWORK_ADDRESS}/external/${package}/binaries/binary_references.cmake ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake STATUS res SHOW_PROGRESS TLS_VERIFY OFF)
			list(GET res 0 numeric_error)
			if(numeric_error EQUAL 0 #framework site is online & reference available.
			AND EXISTS ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake)
				set(to_include ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake)
			endif()
		endif()
	endif()
elseif(${package}_SITE_GIT_ADDRESS)  #references are deployed in a lone static site
	#when package has a lone static site, the reference file can be directly downloaded
	file(DOWNLOAD ${${package}_SITE_ROOT_PAGE}/binaries/binary_references.cmake ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake STATUS res SHOW_PROGRESS TLS_VERIFY OFF)
	list(GET res 0 numeric_error)
	if(numeric_error EQUAL 0 #static site online & reference available.
	AND EXISTS ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake)
		set(to_include ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake)
	endif()
endif()
if(to_include)#there is a file to include but if static site is private it may have returned an invalid file (HTML connection ERROR response)
  file(STRINGS ${to_include} LINES)
  set(erroneous_file FALSE)
  foreach(line IN LISTS LINES)
    if(NOT line MATCHES "^(#.+|set\(.+\))")
      set(erroneous_file TRUE)
      break()
    endif()
  endforeach()
  if(NOT erroneous_file)
    include(${to_include})
  endif()
endif()
if(${package}_REFERENCES) #if there are direct reference (simpler case), no need to do more becase binary references are already included
	set(${REFERENCES_FOUND} TRUE PARENT_SCOPE)
endif()
endfunction(load_Package_Binary_References)

##################################################################################################
############################### functions for native source Packages #############################
##################################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Package_Repository| replace:: ``deploy_Package_Repository``
#  .. _deploy_Package_Repository:
#
#  deploy_Package_Repository
#  -------------------------
#
#   .. command:: deploy_Package_Repository(REFERENCES_FOUND package)
#
#    Deploy the source repository of a given native package into the workspace.
#
#      :package: The name of the package.
#
#      :IS_DEPLOYED: the output variable that is TRUE if package source repository is deployed, FALSE otherwise.
#
function(deploy_Package_Repository IS_DEPLOYED package)
if(${package}_ADDRESS)
	if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] INFO : cloning the repository of source package ${package}...")
	endif()
	if(${package}_PUBLIC_ADDRESS)#there is a public address where to fetch (without any )
		clone_Repository(DEPLOYED ${package} ${${package}_PUBLIC_ADDRESS}) #we clone from public address
		if(DEPLOYED)
			initialize_Git_Repository_Push_Address(${package} ${${package}_ADDRESS})#the push address is modified accordingly
		endif()
	else() #basic case where package deployment requires identification : push/fetch address are the same
		clone_Repository(DEPLOYED ${package} ${${package}_ADDRESS})
	endif()
	if(DEPLOYED)
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : repository of source package ${package} has been cloned.")
		endif()
	else()
		message("[PID] ERROR : cannot clone the repository of source package ${package}.")
	endif()
	set(${IS_DEPLOYED} ${DEPLOYED} PARENT_SCOPE)
else()
	set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : impossible to clone the repository of package ${package} (no repository address defined). This is maybe due to a malformed package, please contact the administrator of this package.")
endif()
endfunction(deploy_Package_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |build_And_Install_Source| replace:: ``build_And_Install_Source``
#  .. _build_And_Install_Source:
#
#  build_And_Install_Source
#  ------------------------
#
#   .. command:: build_And_Install_Source(DEPLOYED package version run_tests)
#
#   Build and install a version of a given package from its source repository. Called by: deploy_Source_Native_Package and deploy_Source_Native_Package_Version.
#
#      :package: The name of the package.
#
#      :version: The target version to build.
#
#      :branch: The target branch to build.
#
#      :run_tests: if true the build process will run the tests and tests fail the install is not performed.
#
#      :IS_DEPLOYED: the output variable that is TRUE if package source repository is deployed, FALSE otherwise.
#
function(build_And_Install_Source DEPLOYED package version branch run_tests)
	if(ADDITIONNAL_DEBUG_INFO)
        if(version)
          message("[PID] INFO : configuring version ${version} of package ${package} ...")
        else()
          message("[PID] INFO : configuring package ${package} (from branch ${branch}) ...")
        endif()
	endif()
    if(run_tests)
        set(TESTS_ARE_USED ON)
    else()
        set(TESTS_ARE_USED OFF)
    endif()

    # Configure the project twice to properly set then use all workspace variables (e.g. generator)
    foreach(_ RANGE 1)
        execute_process(
            COMMAND ${CMAKE_COMMAND} -D BUILD_EXAMPLES:BOOL=OFF -D BUILD_RELEASE_ONLY:BOOL=OFF -D GENERATE_INSTALLER:BOOL=OFF -D BUILD_API_DOC:BOOL=OFF -D BUILD_LATEX_API_DOC:BOOL=OFF -D BUILD_AND_RUN_TESTS:BOOL=${TESTS_ARE_USED} -D REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD:BOOL=ON -D ENABLE_PARALLEL_BUILD:BOOL=ON -D BUILD_DEPENDENT_PACKAGES:BOOL=OFF -D ADDITIONNAL_DEBUG_INFO:BOOL=${ADDITIONNAL_DEBUG_INFO} ..
            WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build
            RESULT_VARIABLE CONFIG_RES
        )
    endforeach()

	if(CONFIG_RES EQUAL 0)
		if(ADDITIONNAL_DEBUG_INFO)
      if(version)
        message("[PID] INFO : building version ${version} of package ${package} ...")
      else()
        message("[PID] INFO : building of package ${package} (from branch ${branch}) ...")
      endif()
		endif()
        target_Options_Passed_Via_Environment(use_env)
        if(${use_env})
            SET(ENV{force} true)
            execute_process(
                COMMAND ${CMAKE_MAKE_PROGRAM} build
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build
                RESULT_VARIABLE BUILD_RES
            )
        else()
            execute_process(
                COMMAND ${CMAKE_MAKE_PROGRAM} build "force=true"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build
                RESULT_VARIABLE BUILD_RES
            )
        endif()
    if(version)
  		get_Platform_Variables(BASENAME platform)
  		if(BUILD_RES EQUAL 0
        AND EXISTS ${WORKSPACE_DIR}/install/${platform}/${package}/${version}/share/Use${package}-${version}.cmake)
  			set(${DEPLOYED} TRUE PARENT_SCOPE)
  			if(ADDITIONNAL_DEBUG_INFO)
  				message("[PID] INFO : package ${package} version ${version} built !")
  			endif()
  			return()
      elseif(BUILD_RES EQUAL 0)#build succeeded but nothing installed means nothing to be installed
        if(ADDITIONNAL_DEBUG_INFO)
          message("[PID] INFO : package ${package} has no content to build !")
        endif()
  		else()
  			message("[PID] ERROR : building package ${package} version ${version} has FAILED !")
      endif()
    else()
      if(BUILD_RES EQUAL 0)
        set(${DEPLOYED} TRUE PARENT_SCOPE)
  			if(ADDITIONNAL_DEBUG_INFO)
  				message("[PID] INFO : package ${package} built (from branch ${branch})!")
  			endif()
  			return()
      else()
  			message("[PID] ERROR : building package ${package} (from branch ${branch}) has FAILED !")
      endif()
    endif()
	else()
    if(version)
      message("[PID] ERROR : configuration of package ${package} version ${version} has FAILED !")
    else()
      message("[PID] ERROR : configuration of package ${package} (from branch ${branch}) has FAILED !")
    endif()
	endif()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
endfunction(build_And_Install_Source)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Source_Native_Package| replace:: ``deploy_Source_Native_Package``
#  .. _deploy_Source_Native_Package:
#
#  deploy_Source_Native_Package
#  ----------------------------
#
#   .. command:: deploy_Source_Native_Package(DEPLOYED package already_installed_versions run_tests)
#
#   Deploy a native package (last version) from its source repository. Means deploy git repository + configure + build/install the native SOURCE package in the workspace so that it can be used by a third party package.
#
#      :package: The name of the package.
#
#      :already_installed_versions: The list of versions of the package that are already installed.
#
#      :run_tests: if true the build process will run the tests and tests they fail the deployment is aborted.
#
#      :DEPLOYED: the output variable that is TRUE if package version is installed in workspace, FALSE otherwise.
#
function(deploy_Source_Native_Package DEPLOYED package already_installed_versions run_tests)
# go to package source and find all version matching the pattern of VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the greatest version number
set(${DEPLOYED} FALSE PARENT_SCOPE)
save_Repository_Context(CURRENT_COMMIT SAVED_CONTENT ${package})
update_Repository_Versions(UPDATE_OK ${package}) # updating the local repository to get all available released modifications
if(NOT UPDATE_OK)
	message("[PID] ERROR : source package ${package} master branch cannot be updated from its official repository. Try to solve the problem by hand or contact the administrator of the official package.")
	restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
	return()
endif()
get_Repository_Version_Tags(GIT_VERSIONS ${package})
if(NOT GIT_VERSIONS) #no version available => BUG
	message("[PID] ERROR : no version available for source package ${package}. Maybe this is a malformed package, please contact the administrator of this package.")
	restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
	return()
endif()

normalize_Version_Tags(VERSION_NUMBERS "${GIT_VERSIONS}") #getting standard version number depending on value of tags
select_Last_Version(RES_VERSION "${VERSION_NUMBERS}")
if(NOT RES_VERSION)
	message("[PID] WARNING : no adequate version found for source package ${package} !! Maybe this is due to a malformed package (contact the administrator of this package). Otherwise that may mean you use a non released version of ${package} (in development version).")
	restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})

	return()
endif()
list(FIND already_installed_versions ${RES_VERSION} INDEX)
if(INDEX EQUAL -1) #not found in installed versions
	check_Package_Version_State_In_Current_Process(${package} ${RES_VERSION} RES)
	if(RES STREQUAL "UNKNOWN" OR RES STREQUAL "PROBLEM") # this package version has not been build since beginning of the process  OR this package version has FAILED TO be deployed from binary during current process
		set(ALL_IS_OK FALSE)
		build_And_Install_Package(ALL_IS_OK ${package} "${RES_VERSION}" "${run_tests}")

		if(ALL_IS_OK)
			message("[PID] INFO : package ${package} version ${RES_VERSION} has been deployed ...")
			set(${DEPLOYED} TRUE PARENT_SCOPE)
			add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
		else()
			message("[PID] ERROR : automatic build and install of source package ${package} FAILED !!")
			add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "FAIL" FALSE)
		endif()
	else()
		if(RES STREQUAL "FAIL") # this package version has FAILED TO be built during current process
			set(${DEPLOYED} FALSE PARENT_SCOPE)
		else() #SUCCESS (should never happen since if build was successfull then it would have generate an installed version)
			if(ADDITIONNAL_DEBUG_INFO)
				message("[PID] INFO : package ${package} version ${RES_VERSION} is deployed ...")
			endif()
			set(${DEPLOYED} TRUE PARENT_SCOPE)
		endif()
	endif()
else()#already installed !!
	is_Binary_Package_Version_In_Development(IN_DEV ${package} ${RES_VERSION})
	if(IN_DEV) # dev version is not generating the same binary as currently installed version
		message("[PID] WARNING : when installing the package ${package} from source : a possibly conflicting binary package with same version ${RES_VERSION} is already installed. Please uninstall it by hand by using the \"make uninstall\" command from package  build folder or \"make clear package=${package} version=${RES_VERSION} from workspace pid folder.\"")
	else()	#problem : the installed version is the result of the user build
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : package ${package} is already up to date ...")
		endif()
	endif()
	set(${DEPLOYED} TRUE PARENT_SCOPE)
	add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
endif()
restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
endfunction(deploy_Source_Native_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Source_Native_Package_From_Branch| replace:: ``deploy_Source_Native_Package_From_Branch``
#  .. _deploy_Source_Native_Package_From_Branch:
#
#  deploy_Source_Native_Package_From_Branch
#  ----------------------------------------
#
#   .. command:: deploy_Source_Native_Package_From_Branch(DEPLOYED package branch run_tests)
#
#   Deploy a native package (last version) from its source repository. Means deploy git repository + configure + build/install the native SOURCE package in the workspace so that it can be used by a third party package.
#
#      :package: The name of the package.
#
#      :branch: The name of branch or ID of commit to deploy.
#
#      :run_tests: if true the build process will run the tests and tests fail the deployment is aborted.
#
#      :DEPLOYED: the output variable that is TRUE if package version is installed in workspace, FALSE otherwise.
#
function(deploy_Source_Native_Package_From_Branch DEPLOYED package branch run_tests)
  # go to package source and find all version matching the pattern of VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the greatest version number
  set(${DEPLOYED} FALSE PARENT_SCOPE)
  save_Repository_Context(CURRENT_COMMIT SAVED_CONTENT ${package})
  set(ALL_IS_OK FALSE)
	build_And_Install_Package(ALL_IS_OK ${package} "${branch}" "${run_tests}")
  if(ALL_IS_OK)
		message("[PID] INFO : package ${package} branch ${branch} has been deployed ...")
		set(${DEPLOYED} TRUE PARENT_SCOPE)
		add_Managed_Package_In_Current_Process(${package} "" "SUCCESS" FALSE)
	else()
		message("[PID] ERROR : automatic build and install of source package ${package} from branch ${branch} FAILED !!")
		add_Managed_Package_In_Current_Process(${package} "" "FAIL" FALSE)
	endif()
	restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
endfunction(deploy_Source_Native_Package_From_Branch)

#.rst:
#
# .. ifmode:: internal
#
#  .. |try_In_Development_Version| replace:: ``try_In_Development_Version``
#  .. _try_In_Development_Version:
#
#  try_In_Development_Version
#  --------------------------
#
#   .. command:: try_In_Development_Version(DEPLOYMENT_OK package version_to_check is_exact run_tests)
#
#   Try to deploy a given version of a package from its source repository's integration branch.
#
#      :package: The name of the package.
#
#      :version_to_check: The version that is required and is maybe installed by integration branch.
#
#      :is_exact: if TRUE the version to check must be exact.
#
#      :run_tests: if true the build process will run the tests and tests fail the deployment is aborted.
#
#      :DEPLOYED_VERSION: the output variable that contains the deployed version, empty if deployment failed.
#
function(try_In_Development_Version DEPLOYED_VERSION package version_to_check is_exact run_tests)
  set(${DEPLOYED_VERSION} PARENT_SCOPE)
  list_Version_Subdirectories(already_installed ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package})
  if(already_installed)
    list(FIND already_installed ${version_to_check} INDEX)
    if(NOT INDEX EQUAL -1)#the version to install from development branch is already in the install tree
      list(REMOVE_ITEM already_installed ${version_to_check})
      file(REMOVE_RECURSE ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${version_to_check})#removing this version to check from install tree so we can detect if it has been generated by the build
    endif()
  endif()
  build_And_Install_Package(ALL_IS_OK ${package} "integration" "${run_tests}")
  if(ALL_IS_OK)
    list_Version_Subdirectories(installed_after_build ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package})
    if(already_installed)
      list(REMOVE_ITEM installed_after_build ${already_installed})
    endif()
    if(installed_after_build)#a new version has been installed
      get_Version_String_Numbers("${version_to_check}.0" major minor patch)
      if(is_exact)#version constraint is exact
        is_Exact_Compatible_Version(IS_COMPATIBLE ${major} ${minor} ${installed_after_build})
      else()
        is_Compatible_Version(IS_COMPATIBLE ${major} ${minor} ${installed_after_build})
      endif()
      if(IS_COMPATIBLE) #the installed version (from integration branch) is compatible with the constraint
        set(${DEPLOYED_VERSION} ${installed_after_build} PARENT_SCOPE)
      else()#not a compatible version, simply clean the install folder
        file(REMOVE_RECURSE ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${package}/${installed_after_build})#removing this version to check from install tree so we can detect if it has been generated by the build
      endif()
    endif()#if no new version installed simply exit
  endif()
endfunction(try_In_Development_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Source_Native_Package_Version| replace:: ``deploy_Source_Native_Package_Version``
#  .. _deploy_Source_Native_Package_Version:
#
#  deploy_Source_Native_Package_Version
#  ------------------------------------
#
#   .. command:: deploy_Source_Native_Package_Version(DEPLOYED package min_version is_exact already_installed_versions run_tests)
#
#   Deploy a given version of a native package from its source repository. Means deploy git repository + configure + build/install the native SOURCE package in the workspace so that it can be used by a third party package.
#   Process checkout to the adequate revision corresponding to the best version according to constraints passed as arguments then configure and build it.
#
#      :package: The name of the package.
#
#      :min_version: The minimum required version.
#
#      :is_exact: if TRUE then version_min is an exact required version.
#
#      :already_installed_versions: The list of versions of the package that are already installed.
#
#      :run_tests: if true the build process will run the tests and tests they fail the deployment is aborted.
#
#      :DEPLOYED: the output variable that is TRUE if package version is installed in workspace, FALSE otherwise.
#
function(deploy_Source_Native_Package_Version DEPLOYED package min_version is_exact already_installed_versions run_tests)
set(${DEPLOYED} FALSE PARENT_SCOPE)
# go to package source and find all version matching the pattern of min_version : if exact taking min_version, otherwise taking the greatest version number
save_Repository_Context(CURRENT_COMMIT SAVED_CONTENT ${package})
update_Repository_Versions(UPDATE_OK ${package}) # updating the local repository to get all available modifications
if(NOT UPDATE_OK)
	message("[PID] WARNING : source package ${package} master branch cannot be updated from its official repository. Try to solve the problem by hand.")
	restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
	return()
endif()

get_Repository_Version_Tags(GIT_VERSIONS ${package}) #get all version tags
if(NOT GIT_VERSIONS) #no version available => BUG
	message("[PID] ERROR : no version available for source package ${package}. Maybe this is a malformed package, please contact the administrator of this package.")
	restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
	return()
endif()

normalize_Version_Tags(VERSION_NUMBERS "${GIT_VERSIONS}")

if(is_exact)
	select_Exact_Native_Version(RES_VERSION ${min_version} "${VERSION_NUMBERS}")
else()
	select_Best_Native_Version(RES_VERSION ${min_version} "${VERSION_NUMBERS}")
endif()
if(NOT RES_VERSION)#no adequate version found, this may be due to the use of a non release version
  try_In_Development_Version(RES_VERSION ${package} ${min_version} ${is_exact} "${run_tests}")#mainly usefull in CI process to build unreleased dependencies
  if(RES_VERSION)
    message("[PID] INFO : deployed version ${RES_VERSION} of source package ${package} is in development (found on integration branch).")
    set(${DEPLOYED} TRUE PARENT_SCOPE)
    add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
  else()
  	message("[PID] WARNING : no adequate version found for source package ${package} !! Maybe this is due to a malformed package (contact the administrator of this package). Otherwise that may mean you use a non released version of ${package} (in development version) that cannot be found on integration branch.")
    add_Managed_Package_In_Current_Process(${package} ${min_version} "FAIL" FALSE)
  endif()
  restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
  return()
endif()

list(FIND already_installed_versions ${RES_VERSION} INDEX)
if(INDEX EQUAL -1) # selected version is not excluded from deploy process
	check_Package_Version_State_In_Current_Process(${package} ${RES_VERSION} RES)
	if(RES STREQUAL "UNKNOWN" OR RES STREQUAL "PROBLEM") # this package version has not been build since last command OR this package version has FAILED TO be deployed from binary during current process
		set(ALL_IS_OK FALSE)
		build_And_Install_Package(ALL_IS_OK ${package} "${RES_VERSION}" "${run_tests}")
		if(ALL_IS_OK)
			message("[PID] INFO : package ${package} version ${RES_VERSION} has been deployed ...")
			set(${DEPLOYED} TRUE PARENT_SCOPE)
			add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
		else()
			message("[PID]  ERROR : automatic build and install of package ${package} (version ${RES_VERSION}) FAILED !!")
			add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "FAIL" FALSE)
		endif()
	else()#in other situations no need to register the package as managed as it is already
		if(RES STREQUAL "FAIL") # this package version has FAILED TO be built during current process
			set(${DEPLOYED} FALSE PARENT_SCOPE)
		else() #SUCCESS because last correct version already built
			if(ADDITIONNAL_DEBUG_INFO)
				message("[PID] INFO : package ${package} version ${RES_VERSION} is deployed ...")
			endif()
			set(${DEPLOYED} TRUE PARENT_SCOPE)
		endif()
	endif()
else()#selected version excluded from current process
	is_Binary_Package_Version_In_Development(IN_DEV ${package} ${RES_VERSION})
	if(IN_DEV) # dev version is not generating the same binary as currently installed version
		message("[PID] WARNING : when installing the package ${package} from source : a possibly conflicting binary package with same version ${RES_VERSION} is already installed. Please uninstall it by hand by using the \"make uninstall\" command from package build folder or \"make clear package=${package} version=${RES_VERSION} from workspace pid folder.\"")
	else()	#problem : the installed version is the result of the user build
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : package ${package} is already up to date ...")
		endif()
	endif()
	set(${DEPLOYED} TRUE PARENT_SCOPE)
	add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
endif()
restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
endfunction(deploy_Source_Native_Package_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |build_And_Install_Package| replace:: ``build_And_Install_Package``
#  .. _build_And_Install_Package:
#
#  build_And_Install_Package
#  -------------------------
#
#   .. command:: build_And_Install_Package(DEPLOYED package version run_tests)
#
#    Build and install a given native package version from its sources. Intermediate internal function that is used to put the source package in an adequate version (using git tags) and then build it. See: build_And_Install_Source.
#
#      :package: The name of the package.
#
#      :version_or_branch: The version or the name of branch to build.
#
#      :run_tests: if true the build process will run the tests and tests fail the install is not performed.
#
#      :DEPLOYED: the output variable that is TRUE if package version is installed in workspace, FALSE otherwise.
#
function(build_And_Install_Package DEPLOYED package version_or_branch run_tests)

get_Version_String_Numbers(${version_or_branch} MAJOR MINOR PATCH)
# message("build_And_Install_Package ${package} version_or_branch=${version_or_branch} version = ${MAJOR} ${MINOR} ${PATCH}")

if(NOT DEFINED MAJOR)#not a version string => it is a branch
  track_Repository_Branch(${package} official ${version_or_branch})
  go_To_Commit(${package} ${version_or_branch})
  build_And_Install_Source(IS_BUILT ${package} "" ${version_or_branch} "${run_tests}") # 2) building sources from a branch
else()
  go_To_Version(${package} ${version_or_branch})# 1) going to the adequate git tag matching the selected version
  build_And_Install_Source(IS_BUILT ${package} ${version_or_branch} "" "${run_tests}") # 2) building sources from a version tag
endif()

if(IS_BUILT)
	set(${DEPLOYED} TRUE PARENT_SCOPE)
else()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
endif()
endfunction(build_And_Install_Package)

##################################################################################################
############################### functions for native binary Packages #############################
##################################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Package_Platform_Against_Current| replace:: ``check_Package_Platform_Against_Current``
#  .. _check_Package_Platform_Against_Current:
#
#  check_Package_Platform_Against_Current
#  --------------------------------------
#
#   .. command:: check_Package_Platform_Against_Current(package platform CHECK_OK)
#
#    Check whether platform configurations defined for binary packages are matching the current platform.
#
#      :package: The name of the package.
#
#      :platform: The platform string used to filter configuation constraints. If different from current platform then configurations defined for that platorm are not checked.
#
#      :CHECK_OK: the output variable that is TRUE if current platform conforms to package required configurations, FALSE otherwise.
#
function(check_Package_Platform_Against_Current package platform CHECK_OK)
set(${CHECK_OK} TRUE PARENT_SCOPE)
# the platform may have an instance name so we need first to get the base name of the platform
extract_Info_From_Platform(RES_ARCH RES_BITS RES_OS RES_ABI RES_INSTANCE RES_PLATFORM_BASE ${platform})

get_Platform_Variables(BASENAME platfom_str)
if(RES_PLATFORM_BASE STREQUAL platfom_str) # OK this binary version is theorically eligible,
  # need to check for its platform configuration to be sure it can be used
	set(CONFIGS_TO_CHECK)
	if(${package}_PLATFORM_CONFIGURATIONS)
		set(CONFIGS_TO_CHECK ${${package}_PLATFORM_CONFIGURATIONS})
    list(REMOVE_DUPLICATES CONFIGS_TO_CHECK)
	else() # this case may be true if the package binary has been release in old PID v1 style
		PID_Package_Is_With_V2_Platform_Info_In_Use_Files(RES ${package})
		if(NOT RES) #this is an old style platform description
			set(OLD_PLATFORM_NAME ${${package}_PLATFORM})
			set(OLD_PLATFORM_CONFIG ${${package}_PLATFORM_${OLD_PLATFORM_NAME}_CONFIGURATION})
			if(OLD_PLATFORM_CONFIG) #there are required configurations in old style
				set(CONFIGS_TO_CHECK ${OLD_PLATFORM_CONFIG})
			endif()
		endif()
	endif()
	foreach(config IN LISTS CONFIGS_TO_CHECK) #if no specific check for configuration so simply reply TRUE
    is_Allowed_System_Configuration(ALLOWED ${config} ${package}_PLATFORM_CONFIGURATION_${config}_ARGS)
    if(NOT ALLOWED)
      set(${CHECK_OK} FALSE PARENT_SCOPE)
      return()
    endif()
	endforeach()
else()#the binary is not eligible since does not match either familly, os, arch or ABI of the current system
	set(${CHECK_OK} FALSE PARENT_SCOPE)
	return()
endif()
endfunction(check_Package_Platform_Against_Current)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Available_Binary_Package_Versions| replace:: ``get_Available_Binary_Package_Versions``
#  .. _get_Available_Binary_Package_Versions:
#
#  get_Available_Binary_Package_Versions
#  --------------------------------------
#
#   .. command:: get_Available_Binary_Package_Versions(package LIST_OF_VERSIONS LIST_OF_VERSION_PLATFORM)
#
#    Get the list of versions of a given package that conforms to current platform constraints and for which a binary archive is available.
#
#      :package: The name of the package.
#
#      :LIST_OF_VERSIONS: the output variable that contains the list of versions of package that are available with a binary archive.
#
#      :LIST_OF_VERSION_PLATFORM: the output variable that contains the list of versions+platform of package that are available with a binary archive.
#
function(get_Available_Binary_Package_Versions package LIST_OF_VERSIONS LIST_OF_VERSION_PLATFORM)
# listing available binaries of the package and searching if there is any "good version"
set(available_binary_package_version)
foreach(ref_version IN LISTS ${package}_REFERENCES)
	foreach(ref_platform IN LISTS ${package}_REFERENCE_${ref_version})
		set(BINARY_OK FALSE)
		check_Package_Platform_Against_Current(${package} ${ref_platform} BINARY_OK)#will return TRUE if the platform conforms to current one
		if(BINARY_OK)
			list(APPEND available_binary_package_version "${ref_version}")
			list(APPEND available_binary_package_version_with_platform "${ref_version}/${ref_platform}")
			# need to test for following platform because many instances may match
		endif()
	endforeach()
endforeach()
if(NOT available_binary_package_version)
	return()#nothing to do
endif()
list(REMOVE_DUPLICATES available_binary_package_version)
list(REMOVE_DUPLICATES available_binary_package_version_with_platform)
set(${LIST_OF_VERSIONS} ${available_binary_package_version} PARENT_SCOPE)
set(${LIST_OF_VERSION_PLATFORM} ${available_binary_package_version_with_platform} PARENT_SCOPE)
endfunction(get_Available_Binary_Package_Versions)

#.rst:
#
# .. ifmode:: internal
#
#  .. |select_Platform_Binary_For_Version| replace:: ``select_Platform_Binary_For_Version``
#  .. _select_Platform_Binary_For_Version:
#
#  select_Platform_Binary_For_Version
#  ----------------------------------
#
#   .. command:: select_Platform_Binary_For_Version(version list_of_bin_with_platform RES_FOR_PLATFORM)
#
#    Select the version passed as argument in the list of binary versions of a package and get corresponding platform.
#
#      :version: The selected version.
#
#      :list_of_bin_with_platform: list of available version+platform for a package (returned from get_Available_Binary_Package_Versions). All these archives are supposed to be binary compatible with current platform.
#
#      :RES_FOR_PLATFORM: the output variable that contains the platform to use.
#
function(select_Platform_Binary_For_Version version list_of_bin_with_platform RES_FOR_PLATFORM)
set(chosen_platform)
get_Platform_Variables(INSTANCE instance_name)
if(list_of_bin_with_platform)
  foreach(bin IN LISTS list_of_bin_with_platform)
    if(bin MATCHES "^${version}/(.*)$") #only select for the given version
      set(bin_platform_name ${CMAKE_MATCH_1})
      extract_Info_From_Platform(RES_ARCH RES_BITS RES_OS RES_ABI res_instance res_base_name ${bin_platform_name})
      if(instance_name AND res_instance STREQUAL instance_name)#the current platform is an instance so verify that binary archive is for this instance
        # This is the best choice we can do because there is a perfect match of platform instances
        set(${RES_FOR_PLATFORM} ${bin_platform_name} PARENT_SCOPE)
        return()
      else()
        if(NOT chosen_platform)
          set(chosen_platform ${bin_platform_name})#memorize the first in list, it will be selected by default
        elseif((NOT instance_name) AND (NOT res_instance))# if the current workspace has no instance specified, prefer a binary archive that is agnostic of instance, if any provided
          set(chosen_platform ${bin_platform_name})#memorize this archive because it is agnostic of platform instance
        endif()
      endif()
		endif()
	endforeach()
endif()
set(${RES_FOR_PLATFORM} ${chosen_platform} PARENT_SCOPE)
endfunction(select_Platform_Binary_For_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Binary_Native_Package| replace:: ``deploy_Binary_Native_Package``
#  .. _deploy_Binary_Native_Package:
#
#  deploy_Binary_Native_Package
#  ----------------------------
#
#   .. command:: deploy_Binary_Native_Package(DEPLOYED package already_installed_versions)
#
#    Deploy a package (last version) binary archive. It means that last version is installed and configured in the workspace.  See: download_And_Install_Binary_Native_Package.
#
#      :package: The name of package to deploy.
#
#      :already_installed_versions: list of already installed versions for that package.
#
#      :DEPLOYED: the output variable that contains is TRUE if binary archive has been deployed, FALSE otherwise.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        package binary references must be loaded before the call.
#
function(deploy_Binary_Native_Package DEPLOYED package already_installed_versions)
set(available_versions "")
get_Available_Binary_Package_Versions(${package} available_versions available_with_platform)
if(NOT available_versions)
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()
select_Last_Version(RES_VERSION "${available_versions}")# taking the most up to date version from all eligible versions
list(FIND already_installed_versions ${RES_VERSION} INDEX)
set(INSTALLED FALSE)
if(INDEX EQUAL -1) # selected version not found in versions already installed
	check_Package_Version_State_In_Current_Process(${package} ${RES_VERSION} RES)
	if(RES STREQUAL "UNKNOWN") # this package version has not been build since beginning of the current process
    select_Platform_Binary_For_Version(${RES_VERSION} "${available_with_platform}" RES_PLATFORM)
    if(RES_PLATFORM)
  		download_And_Install_Binary_Native_Package(INSTALLED ${package} "${RES_VERSION}" "${RES_PLATFORM}")
      if(NOT INSTALLED)
        add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "PROBLEM" FALSE) #situation is problematic but we can still overcome it by using sources ... if possible
        set(${DEPLOYED} FALSE PARENT_SCOPE)
      	return()
      endif()
      #checking and resolving package dependencies and constraints
      configure_Binary_Package(RESULT_DEBUG ${package} FALSE ${RES_VERSION} ${RES_PLATFORM} Debug)
      configure_Binary_Package(RESULT_RELEASE  ${package} FALSE ${RES_VERSION} ${RES_PLATFORM} Release)

      if(NOT RESULT_DEBUG OR NOT RESULT_RELEASE)
        add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "PROBLEM" FALSE)
        #need to remove the package because it cannot be configured
        uninstall_Binary_Package(${package} FALSE ${RES_VERSION} ${RES_PLATFORM})
        message("[PID] ERROR : cannot configure version ${version} of native package ${package}.")
        set(${DEPLOYED} FALSE PARENT_SCOPE)
      	return()
      endif()
      add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
    endif()
  else()
		if(NOT RES STREQUAL "SUCCESS") # this package version has FAILED TO be installed during current process
			set(INSTALLED FALSE)
		else() #SUCCESS because last correct version already built
			set(INSTALLED TRUE)
		endif()
	endif()

else()
	set(INSTALLED TRUE) #if exlcuded it means that the version is already installed
	if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] INFO : package ${package} is already up to date ...")
	endif()
	add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
endif()
set(${DEPLOYED} ${INSTALLED} PARENT_SCOPE)
endfunction(deploy_Binary_Native_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Binary_Native_Package_Version| replace:: ``deploy_Binary_Native_Package_Version``
#  .. _deploy_Binary_Native_Package_Version:
#
#  deploy_Binary_Native_Package_Version
#  ------------------------------------
#
#   .. command:: deploy_Binary_Native_Package_Version(DEPLOYED package min_version is_exact already_installed_versions)
#
#    Deploy a given version of package from a binary archive. The package version archive is installed and configured in the workspace. See: download_And_Install_Binary_Native_Package.
#
#      :package: The name of package to deploy.
#
#      :min_version: The minimum allowed version for the binary archive
#
#      :is_exact: if TRUE then the exact constraint applies to min_version.
#
#      :already_installed_versions: list of already installed versions for that package.
#
#      :DEPLOYED: the output variable that contains is TRUE if binary archive has been deployed, FALSE otherwise.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        package binary references must be loaded before the call.
#
function(deploy_Binary_Native_Package_Version DEPLOYED package min_version is_exact already_installed_versions)
set(available_versions "")
get_Available_Binary_Package_Versions(${package} available_versions available_with_platform)
if(NOT available_versions)
	if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] INFO : no available binary versions of package ${package} for the current platform.")
	endif()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()

# taking the adequate version from the list of all eligible versions
if(is_exact)
	select_Exact_Native_Version(RES_VERSION ${min_version} "${available_versions}")
else()
	select_Best_Native_Version(RES_VERSION ${min_version} "${available_versions}")
endif()

if(NOT RES_VERSION)
	if(is_exact)
		message("[PID] INFO : no adequate binary compatible for ${package} version ${min_version} found.")
	else()
		message("[PID] INFO : no adequate binary version of package ${package} found with minimum version ${min_version}.")
	endif()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()
set(INSTALLED FALSE)
list(FIND already_installed_versions ${RES_VERSION} INDEX)
if(INDEX EQUAL -1) # selected version not found in versions to exclude
	check_Package_Version_State_In_Current_Process(${package} ${RES_VERSION} RES)
	if(RES STREQUAL "UNKNOWN") # this package version has not been managed since beginning of the current process
		select_Platform_Binary_For_Version(${RES_VERSION} "${available_with_platform}" RES_PLATFORM)
    if(RES_PLATFORM)
  		download_And_Install_Binary_Native_Package(INSTALLED ${package} "${RES_VERSION}" "${RES_PLATFORM}")
      if(NOT INSTALLED)
        add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "PROBLEM" FALSE) #situation is problematic but we can still overcome it by using sources ... if possible
        set(${DEPLOYED} FALSE PARENT_SCOPE)
      	return()
      endif()
      #checking and resolving package dependencies and constraints
      configure_Binary_Package(RESULT_DEBUG ${package} FALSE ${RES_VERSION} ${RES_PLATFORM} Debug)
      configure_Binary_Package(RESULT_RELEASE  ${package} FALSE ${RES_VERSION} ${RES_PLATFORM} Release)

      if(NOT RESULT_DEBUG OR NOT RESULT_RELEASE)
        add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "PROBLEM" FALSE)
        #need to remove the package because it cannot be configured
        uninstall_Binary_Package(${package} FALSE ${RES_VERSION} ${RES_PLATFORM})
        message("[PID] ERROR : cannot configure version ${RES_VERSION} of native package ${package}.")
        set(${DEPLOYED} FALSE PARENT_SCOPE)
      	return()
      endif()
      add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
    endif()
	else()
		if(NOT RES STREQUAL "SUCCESS") # this package version has FAILED TO be installed during current process
			set(INSTALLED FALSE)
		else() #SUCCESS because last correct version already built
			set(INSTALLED TRUE)
		endif()
	endif()
else()
	set(INSTALLED TRUE) #if exlcuded it means that the version is already installed
	if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] INFO : package ${package} is already up to date ...")
	endif()
	add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
endif()
set(${DEPLOYED} ${INSTALLED} PARENT_SCOPE)
endfunction(deploy_Binary_Native_Package_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Binary_Package_Name| replace:: ``generate_Binary_Package_Name``
#  .. _generate_Binary_Package_Name:
#
#  generate_Binary_Package_Name
#  ----------------------------
#
#   .. command:: generate_Binary_Package_Name(package version platform mode RES_FILE RES_FOLDER)
#
#    Get filesystem names usefull to manage package binary archives built for a given version of a package, for a target platform and in specific build mode.
#
#      :package: The name of package.
#
#      :version: version of the package.
#
#      :platform: target platform for archive binary content.
#
#      :mode: build mode  for archive binary content.
#
#      :RES_FILE: the output variable that contains the name of the archive (generated by PID)
#
#      :RES_FOLDER: the output variable that contains the name of the root folder contained in the archive (generated by CPack)
#
function(generate_Binary_Package_Name package version platform mode RES_FILE RES_FOLDER)
get_Platform_Variables(PKG_STRING pack_str)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(${RES_FILE} "${package}-${version}${TARGET_SUFFIX}-${platform}.tar.gz" PARENT_SCOPE) #this is the archive name generated by PID
set(${RES_FOLDER} "${package}-${version}${TARGET_SUFFIX}-${pack_str}" PARENT_SCOPE)#this is the folder name generated by CPack
endfunction(generate_Binary_Package_Name)

#.rst:
#
# .. ifmode:: internal
#
#  .. |download_And_Install_Binary_Native_Package| replace:: ``download_And_Install_Binary_Native_Package``
#  .. _download_And_Install_Binary_Native_Package:
#
#  download_And_Install_Binary_Native_Package
#  ------------------------------------------
#
#   .. command:: download_And_Install_Binary_Native_Package(INSTALLED package version platform)
#
#    Download the  binary archive of target package version and then intsall it. This call install Debug and Release mode versions of the package in the same time.
#
#      :package: The name of package.
#
#      :version: version of the package to install.
#
#      :platform: target platform for archive binary content.
#
#      :INSTALLED: the output variable that is TRUE if binary package has been installed.
#
function(download_And_Install_Binary_Native_Package INSTALLED package version platform)

message("[PID] INFO : deploying the binary package ${package} with version ${version} for platform ${platform}, please wait ...")
if(ADDITIONNAL_DEBUG_INFO)
	message("[PID] INFO : downloading the binary package ${package} version ${version} for platform ${platform}, please wait ...")
endif()

extract_Info_From_Platform(RES_ARCH RES_BITS RES_OS RES_ABI instance_str platform_str ${platform})
###### downloading the binary package ######
#release code
set(FILE_BINARY "")
set(FOLDER_BINARY "")
generate_Binary_Package_Name(${package} ${version} ${platform_str} Release FILE_BINARY FOLDER_BINARY)#whatever the platform is with instance or not, archive and folder are named the same way
set(download_url ${${package}_REFERENCE_${version}_${platform}_URL})#platform in download url may contain also the instance extension
file(DOWNLOAD ${download_url} ${CMAKE_BINARY_DIR}/share/${FILE_BINARY} STATUS res SHOW_PROGRESS TLS_VERIFY OFF)
list(GET res 0 numeric_error)
list(GET res 1 status)
if(NOT numeric_error EQUAL 0)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : problem when downloading binary version ${version} of package ${package} (release binaries) from address ${download_url}: ${status}")
	return()
endif()

#debug code
set(FILE_BINARY_DEBUG "")
set(FOLDER_BINARY_DEBUG "")
generate_Binary_Package_Name(${package} ${version} ${platform_str} Debug FILE_BINARY_DEBUG FOLDER_BINARY_DEBUG)
set(download_url_dbg ${${package}_REFERENCE_${version}_${platform}_URL_DEBUG})#platform in download url may contain also the instance extension
file(DOWNLOAD ${download_url_dbg} ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG} STATUS res-dbg SHOW_PROGRESS TLS_VERIFY OFF)
list(GET res-dbg 0 numeric_error_dbg)
list(GET res-dbg 1 status_dbg)
if(NOT numeric_error_dbg EQUAL 0)#there is an error
	package_License_Is_Closed_Source(CLOSED ${package} FALSE)#limit this high cost function when an error occurs
	if(NOT CLOSED) #generate an error if the package is not closed source (there is a missing archive)
		set(${INSTALLED} FALSE PARENT_SCOPE)
		message("[PID] ERROR : problem when downloading binary version ${version} of package ${package} (debug binaries) from address ${download_url_dbg} : ${status_dbg}.")
		return()
	else()
		set(MISSING_DEBUG_VERSION TRUE)
	endif()
endif()

######## installing the package ##########
set(target_install_folder ${WORKSPACE_DIR}/install/${platform_str}/${package})
# 1) creating the package root install folder
if(NOT EXISTS ${target_install_folder})
  file(MAKE_DIRECTORY ${target_install_folder})
endif()

# 2) extracting binary archive in a cross platform way
set(error_res)
set(error_res_debug)
set(output_mode_rel ERROR_VARIABLE error_res)
set(output_mode_deb ERROR_VARIABLE error_res_debug)
if(ADDITIONNAL_DEBUG_INFO)
	message("[PID] INFO : decompressing the binary package ${package}, please wait ...")
else()
  list(APPEND output_mode_rel OUTPUT_QUIET)
  list(APPEND output_mode_deb OUTPUT_QUIET)
endif()
#download release archive anytime
execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY}
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
  ${output_mode_rel})

#chech if there is no debug archive to manage
if(NOT MISSING_DEBUG_VERSION)
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
    ${output_mode_deb})
endif()

if (error_res)
	#try again
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
  ${output_mode_rel})
	if (error_res) #an error again -> FAIL
		set(${INSTALLED} FALSE PARENT_SCOPE)
		message("[PID] WARNING : cannot extract binary archive ${FILE_BINARY} when installing.")
		return()
	endif()
endif()

if (error_res_debug)
	#try again
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
  ${output_mode_deb})

	if (error_res_debug)
		set(${INSTALLED} FALSE PARENT_SCOPE)
		message("[PID] WARNING : cannot extract binary archive ${FILE_BINARY_DEBUG} when installing.")
		return()
	endif()
endif()

# 3) copying resulting folders into the install path in a cross platform way
set(output_mode_rel)
set(output_mode_deb)
if(ADDITIONNAL_DEBUG_INFO)
	message("[PID] INFO : installing the binary package ${package} (version ${version}) into the workspace, please wait ...")
else()
  list(APPEND output_mode_rel ERROR_QUIET OUTPUT_QUIET)
  list(APPEND output_mode_deb ERROR_QUIET OUTPUT_QUIET)
endif()

execute_process(
  COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/${FOLDER_BINARY} ${target_install_folder}
  ${output_mode_rel}
)
if(NOT MISSING_DEBUG_VERSION)  #no debug archive to manage
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/${FOLDER_BINARY_DEBUG} ${target_install_folder}
    ${output_mode_deb}
  )
endif()

if (NOT EXISTS ${target_install_folder}/${version}/share/Use${package}-${version}.cmake)#install did not work well
	#try again
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/${FOLDER_BINARY} ${target_install_folder}
    ${output_mode_rel}
  )
  if(NOT MISSING_DEBUG_VERSION)  #no debug archive to manage
    execute_process(
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/${FOLDER_BINARY_DEBUG} ${target_install_folder}
      ${output_mode_deb}
    )
  endif()

	if (NOT EXISTS ${target_install_folder}/${version}/share/Use${package}-${version}.cmake)
		set(${INSTALLED} FALSE PARENT_SCOPE)
		if(MISSING_DEBUG_VERSION)  #no debug archive to manage
			message("[PID] WARNING : when installing binary package ${package}, cannot extract version folder from ${FOLDER_BINARY}.")
		else()
			message("[PID] WARNING : when installing binary package ${package}, cannot extract version folder from ${FOLDER_BINARY} and ${FOLDER_BINARY_DEBUG}.")
		endif()
		return()
	endif()
endif()

set(${INSTALLED} TRUE PARENT_SCOPE)
message("[PID] INFO : binary package ${package} (version ${version}) has been installed into the workspace.")
endfunction(download_And_Install_Binary_Native_Package)

#############################################################################################
############################### functions for external Packages #############################
#############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |load_And_Configure_Wrapper| replace:: ``load_And_Configure_Wrapper``
#  .. _load_And_Configure_Wrapper:
#
#  load_And_Configure_Wrapper
#  --------------------------
#
#   .. command:: load_And_Configure_Wrapper(LOADED package)
#
#   Load the description provided by an external package wrapper into current build process.
#
#      :package: The name of external package.
#
#      :LOADED: the output variable that is TRUE if external package wrapper has been loaded.
#
function(load_And_Configure_Wrapper LOADED package)
	if(NOT EXISTS ${WORKSPACE_DIR}/wrappers/${package}/CMakeLists.txt)
		message("[PID] ERROR : cannot find external package ${package} wrapper in workspace !")
		set(${LOADED} FALSE PARENT_SCOPE)
		return()
	endif()
	#configure the wrapper
	if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] INFO : configuring wrapper of external package ${package} ...")
	endif()
	execute_process(
		COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" ..
		WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${package}/build
		RESULT_VARIABLE CONFIG_RES
	)
	if((NOT CONFIG_RES EQUAL 0) OR (NOT EXISTS ${WORKSPACE_DIR}/wrappers/${package}/build/Build${package}.cmake))
		message("[PID] ERROR : configuration of external package  ${package} wrapper has FAILED !")
		set(${LOADED} FALSE PARENT_SCOPE)
		return()
	endif()
	include(${WORKSPACE_DIR}/wrappers/${package}/build/Build${package}.cmake NO_POLICY_SCOPE)#loading the wrapper description
	set(${LOADED} TRUE PARENT_SCOPE)
endfunction(load_And_Configure_Wrapper)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Wrapper_Known_Versions| replace:: ``get_Wrapper_Known_Versions``
#  .. get_Wrapper_Known_Versions:
#
#  get_Wrapper_Known_Versions
#  --------------------------
#
#   .. command:: get_Wrapper_Known_Versions(RES_VERSIONS package)
#
#   Get all versions that can be built from an external package wrapper.
#
#      :package: The name of external package.
#
#      :RES_VERSIONS: the output variable that contains the list of versions of an external package provided by its wrapper.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        Wrapper must be configured and loaded before the call to this function (see load_And_Configure_Wrapper)
#
function(get_Wrapper_Known_Versions RES_VERSIONS package)
set(${RES_VERSIONS} ${${package}_KNOWN_VERSIONS} PARENT_SCOPE)
endfunction(get_Wrapper_Known_Versions RES_VERSIONS package)

### building an external package from its wrapper

#.rst:
#
# .. ifmode:: internal
#
#  .. |build_And_Install_External_Package_Version| replace:: ``build_And_Install_External_Package_Version``
#  .. _build_And_Install_External_Package_Version:
#
#  build_And_Install_External_Package_Version
#  ------------------------------------------
#
#   .. command:: build_And_Install_External_Package_Version(INSTALLED package version is_system)
#
#    Build and install a given external package version from its wrapper.
#
#      :package: The name of the external package.
#
#      :version: The version to install.
#
#      :is_system: if TRUE the OS variant of teh given version will be "built" (i.e. symlinked from external package install tree).
#
#      :INSTALLED: the output variable that is TRUE if package version is installed in workspace, FALSE otherwise.
#
function(build_And_Install_External_Package_Version INSTALLED package version is_system)
  if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] INFO : building version ${version} of external package ${package} ...")
  endif()

  target_Options_Passed_Via_Environment(use_env)
  if(${use_env})
     set(ENV{version} ${version})
     if(is_system)
         set(ENV{os_variant} true)
     endif()
     execute_process(#call the wrapper command used to build the version of the external package
         COMMAND ${CMAKE_MAKE_PROGRAM} build
         WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${package}/build
         RESULT_VARIABLE BUILD_RES
     )
  else()
     set(args_to_use version=${version})
     if(is_system)
         set(args_to_use ${args_to_use} os_variant=true)
     endif()
     execute_process(#call the wrapper command used to build the version of the external package
         COMMAND ${CMAKE_MAKE_PROGRAM} build ${args_to_use}
         WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${package}/build
         RESULT_VARIABLE BUILD_RES
     )
  endif()

  get_Platform_Variables(BASENAME platform PKG_STRING package_string)
  if(BUILD_RES EQUAL 0
  AND EXISTS ${WORKSPACE_DIR}/external/${platform}/${package}/${version}/share/Use${package}-${version}.cmake)
  	set(${INSTALLED} TRUE PARENT_SCOPE)
  	if(ADDITIONNAL_DEBUG_INFO)
  		message("[PID] INFO : external package ${package} version ${version} built !")
  	endif()
  	return()
	else()
		message("[PID] ERROR : building external package ${package} version ${version} FAILED !")
	endif()
	set(${INSTALLED} FALSE PARENT_SCOPE)
endfunction(build_And_Install_External_Package_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Wrapper_Repository| replace:: ``deploy_Wrapper_Repository``
#  .. _deploy_Wrapper_Repository:
#
#  deploy_Wrapper_Repository
#  -------------------------
#
#   .. command:: deploy_Wrapper_Repository(INSTALLED package version platform)
#
#    Deploy into workspace the git repository of the given external package wrapper.
#
#      :package: The name of external package.
#
#      :IS_DEPLOYED: the output variable that is TRUE if external package wrapper has been deployed in workspace, FALSE otherwise.
#
function(deploy_Wrapper_Repository IS_DEPLOYED package)
if(${package}_PID_WRAPPER_ADDRESS)
	if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] INFO : cloning the repository of wrapper for external package ${package}...")
	endif()
	if(${package}_PID_WRAPPER_PUBLIC_ADDRESS)#there is a public address where to fetch (without any )
		clone_Wrapper_Repository(DEPLOYED ${package} ${${package}_PID_WRAPPER_PUBLIC_ADDRESS})#we clone from public address
		if(DEPLOYED)
			initialize_Wrapper_Git_Repository_Push_Address(${package} ${${package}_PID_WRAPPER_ADDRESS})#the push address is modified accordingly
		endif()
	else() #basic case where package deployment requires identification : push/fetch address are the same
		clone_Wrapper_Repository(DEPLOYED ${package} ${${package}_PID_WRAPPER_ADDRESS})
	endif()
	if(DEPLOYED)
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : repository of of the wrapper for external package ${package} has been cloned.")
		endif()
	else()
		message("[PID] ERROR : cannot clone the repository of the wrapper for external package ${package}.")
	endif()
	set(${IS_DEPLOYED} ${DEPLOYED} PARENT_SCOPE)
else()
	set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : impossible to clone the repository of the wrapper of external package ${package} (no repository address defined). This is maybe due to a malformed package, please contact the administrator of this wrapper package.")
endif()
endfunction(deploy_Wrapper_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Source_External_Package| replace:: ``deploy_Source_External_Package``
#  .. _deploy_Source_External_Package:
#
#  deploy_Source_External_Package
#  ------------------------------
#
#   .. command:: deploy_Source_External_Package(DEPLOYED package already_installed_versions)
#
#   Deploy an external package (last version) into workspace from its wrapper. Consists in cloning wrapper git repository then configure then build/install the external wrapper SOURCE package in the workspace so that it can be used by a third party package.
#
#      :package: The name of the external package.
#
#      :already_installed_versions: The list of versions of the external package that are already installed.
#
#      :DEPLOYED: the output variable that is TRUE if external package version is installed in workspace, FALSE otherwise.
#
function(deploy_Source_External_Package DEPLOYED package already_installed_versions)
# go to wrapper source and find all version matching the pattern of VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the greatest version number
set(${DEPLOYED} FALSE PARENT_SCOPE)

update_Wrapper_Repository(${package})#update wrapper repository
load_And_Configure_Wrapper(LOADED ${package})
if(NOT LOADED)
	return()
endif()
get_Wrapper_Known_Versions(ALL_VERSIONS ${package})
select_Last_Version(RES_VERSION "${ALL_VERSIONS}")
if(NOT RES_VERSION)
	message("[PID] ERROR : no adequate version found for wrapper of external package ${package} !! Maybe this is due to a malformed package (contact the administrator of this package). Otherwise that may mean you use a non released version of ${package} (in development version).")
	add_Managed_Package_In_Current_Process(${package} "NO VERSION" "FAIL" TRUE)
	return()
endif()
list(FIND already_installed_versions ${RES_VERSION} INDEX)
if(INDEX EQUAL -1) # selected version is not excluded from deploy process
	build_And_Install_External_Package_Version(INSTALLED ${package} ${RES_VERSION} FALSE)
	if(NOT INSTALLED) # this package version has FAILED TO be built during current process
		set(${DEPLOYED} FALSE PARENT_SCOPE)
		add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "FAIL" TRUE)
	else() #SUCCESS because last correct version already built
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : wrapper for external package ${package} has deployed the version ${RES_VERSION}...")
		endif()
		set(${DEPLOYED} TRUE PARENT_SCOPE)
		add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" TRUE)
	endif()
else() #nothing to do but result is OK
	set(${DEPLOYED} TRUE PARENT_SCOPE)
	message("[PID] WARNING : no need to deploy external package ${package} version ${RES_VERSION} from wrapper, since version already exists.")
add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" TRUE)
endif()
endfunction(deploy_Source_External_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Source_External_Package_Version| replace:: ``deploy_Source_External_Package_Version``
#  .. _deploy_Source_External_Package_Version:
#
#  deploy_Source_External_Package_Version
#  --------------------------------------
#
#   .. command:: deploy_Source_External_Package_Version(DEPLOYED package min_version is_exact already_installed_versions)
#
#   Deploy a given version of an external package from its wrapper. Means deploy wrapper git repository + configure + build/install the native SOURCE package in the workspace so that it can be used by a third party package.
#   Process checkout to the adequate revision corresponding to the best version according to constraints passed as arguments then configure and build it.
#
#      :package: The name of the external package.
#
#      :min_version: The minimum required version.
#
#      :is_exact: if TRUE then version_min is an exact required version.
#
#      :is_system: if TRUE then version_min is the OS installed version.
#
#      :already_installed_versions: The list of versions of the external package that are already installed.
#
#      :DEPLOYED: the output variable that is TRUE if external package version is installed in workspace, FALSE otherwise.
#
function(deploy_Source_External_Package_Version DEPLOYED package min_version is_exact is_system already_installed_versions)
set(${DEPLOYED} FALSE PARENT_SCOPE)
# go to package source and find all version matching the pattern of min_version : if exact taking min_version, otherwise taking the greatest version number

update_Wrapper_Repository(${package})#update wrapper repository
load_And_Configure_Wrapper(LOADED ${package})
if(NOT LOADED)
	return()
endif()
get_Wrapper_Known_Versions(ALL_VERSIONS ${package})

if(is_exact)
	select_Exact_External_Version(RES_VERSION ${min_version} "${ALL_VERSIONS}")
else()
	select_Best_External_Version(RES_VERSION ${package} ${min_version} "${ALL_VERSIONS}")
endif()

if(NOT RES_VERSION)
	message("[PID] WARNING : no adequate version found for wrapper of external package ${package} !! Maybe this is due to a malformed package (contact the administrator of this package).")
	return()
endif()
list(FIND already_installed_versions ${RES_VERSION} INDEX)
if(INDEX EQUAL -1) # selected version is not excluded from deploy process
	build_And_Install_External_Package_Version(INSTALLED ${package} ${RES_VERSION} "${is_system}")
	if(NOT INSTALLED) # this package version has FAILED TO be built during current process
		set(${DEPLOYED} FALSE PARENT_SCOPE)
		add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "FAIL" TRUE)
	else() #SUCCESS because last correct version already built
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : wrapper for external package ${package} has deployed the version ${RES_VERSION}...")
		endif()
		set(${DEPLOYED} TRUE PARENT_SCOPE)
		add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" TRUE)
	endif()
else() #nothing to do but result is OK
	set(${DEPLOYED} TRUE PARENT_SCOPE)
	add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" TRUE)
endif()
endfunction(deploy_Source_External_Package_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Required_External_Package_Version| replace:: ``resolve_Required_External_Package_Version``
#  .. _resolve_Required_External_Package_Version:
#
#  resolve_Required_External_Package_Version
#  -----------------------------------------
#
#   .. command:: resolve_Required_External_Package_Version(RESOLUTION_OK SELECTED_VERSION IS_EXACT package)
#
#     Select the adequate version of a given external package to be used in current build process.
#
#      :package: The name of the external package for which a version must be found.
#
#      :RESOLUTION_OK: the output variable that is TRUE if a version of the package has been proposed by teh resolution process, FALSE otherwise.
#
#      :SELECTED_VERSION: the output variable that contains the selected version to use.
#
#      :IS_EXACT: the output variable that is TRUE if SELECTED_VERSION must be exact, false otherwise.
#
#      :IS_SYSTEM: the output variable that is TRUE if SELECTED_VERSION must be an OS installed version, false otherwise.
#
function(resolve_Required_External_Package_Version RESOLUTION_OK SELECTED_VERSION IS_EXACT IS_SYSTEM package)
  if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX})
    list(REMOVE_DUPLICATES ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX})
  endif()
  set(CURRENT_EXACT FALSE)
  set(CURRENT_SYSTEM FALSE)
	#1) first pass to eliminate everything impossible just when considering exactness
	foreach(version IN LISTS ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX})
		if(CURRENT_EXACT)#current version is an exact version
			if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX}) #impossible to find two different exact versions solution
				set(${RESOLUTION_OK} FALSE PARENT_SCOPE)
				return()
			elseif(version VERSION_GREATER CURRENT_VERSION)#any not exact version that is greater than current exact one makes the solution impossible
				set(${RESOLUTION_OK} FALSE PARENT_SCOPE)
				return()
			endif()
		else()#current version is not exact
			#there is no current version (first run)
			if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX})#the current version is exact
				if(NOT CURRENT_VERSION OR CURRENT_VERSION VERSION_LESS version)#no current version defined OR this version is less
					set(CURRENT_EXACT TRUE)
					set(CURRENT_VERSION ${version})
          # additional step => check if the OS variant is required
          if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_SYSTEM${USE_MODE_SUFFIX})
            set(CURRENT_SYSTEM TRUE)
          endif()
				else()# current version is greater than exact one currently required => impossible to find a solution
					set(${RESOLUTION_OK} FALSE PARENT_SCOPE)
					return()
				endif()
			else()#getting the greater minimal required version
				if(NOT CURRENT_VERSION OR CURRENT_VERSION VERSION_LESS ${version})
					set(CURRENT_VERSION ${version})
				endif()
			endif()
		endif()
	endforeach()

	#2) testing if a solution exists as regard of "compatibility" of required versions
	foreach(version IN LISTS ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX})
		if(NOT version VERSION_EQUAL CURRENT_VERSION)
			if(DEFINED ${package}_REFERENCE_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO
			AND NOT CURRENT_VERSION VERSION_LESS ${package}_REFERENCE_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO) #current version not compatible with the version
				set(${RESOLUTION_OK} FALSE PARENT_SCOPE) #there is no solution
				return()
			endif()
		endif()
	endforeach()

	set(${RESOLUTION_OK} TRUE PARENT_SCOPE)
	set(${SELECTED_VERSION} "${CURRENT_VERSION}" PARENT_SCOPE)
	set(${IS_EXACT} ${CURRENT_EXACT} PARENT_SCOPE)
	set(${IS_SYSTEM} ${CURRENT_SYSTEM} PARENT_SCOPE)
endfunction(resolve_Required_External_Package_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |uninstall_External_Package| replace:: ``uninstall_External_Package``
#  .. _uninstall_External_Package:
#
#  uninstall_External_Package
#  --------------------------
#
#   .. command:: uninstall_External_Package(package)
#
#     Uninstall a given external package from the workspace. All versions of this external package are removed from install tree.
#
#      :package: The name of the external package to uninstall.
#
function(uninstall_External_Package package)
set(version ${${package}_VERSION_STRING})
get_Platform_Variables(BASENAME platform_str)
set(path_to_install_dir ${WORKSPACE_DIR}/external/${platform_str}/${package}/${version})
if(EXISTS ${path_to_install_dir} AND IS_DIRECTORY ${path_to_install_dir})
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory  ${path_to_install_dir}) #delete the external package version folder
endif()
endfunction(uninstall_External_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |memorize_External_Binary_References| replace:: ``memorize_External_Binary_References``
#  .. _memorize_External_Binary_References:
#
#  memorize_External_Binary_References
#  -----------------------------------
#
#   .. command:: memorize_External_Binary_References(REFERENCES_FOUND package)
#
#     Put into memory of current build process the references to binary archives for the given external package.
#
#      :package: The name of the external package.
#
#      :REFERENCES_FOUND: The output variable that is TRUE if binary references for external package have been found.
#
function(memorize_External_Binary_References REFERENCES_FOUND package)
set(IS_EXISTING FALSE)
package_Reference_Exists_In_Workspace(IS_EXISTING External${package})
if(NOT IS_EXISTING)
	set(${REFERENCES_FOUND} FALSE PARENT_SCOPE)
	message("[PID] WARNING : unknown external package ${package} : cannot find any reference of this package in the workspace. Cannot install this package.")
	return()
endif()

include(ReferExternal${package} OPTIONAL RESULT_VARIABLE refer_path)
if(${refer_path} STREQUAL NOTFOUND)
	set(${REFERENCES_FOUND} FALSE PARENT_SCOPE)
	message("[PID] WARNING : reference file not found for external package ${package}!! This is certainly due to a badly referenced package. Please contact the administrator of the external package ${package} !!!")
	return()
endif()

load_Package_Binary_References(RES ${package}) #getting the references (address of sites) where to download binaries for that package
set(${REFERENCES_FOUND} ${RES} PARENT_SCOPE) #returns wether refernces have been found or not
endfunction(memorize_External_Binary_References)

#.rst:
#
# .. ifmode:: internal
#
#  .. |install_External_Package| replace:: ``install_External_Package``
#  .. _install_External_Package:
#
#  install_External_Package
#  ------------------------
#
#   .. command:: install_External_Package(INSTALL_OK package force reinstall)
#
#     Install a given external package in workspace.
#
#      :package: The name of the external package to install.
#
#      :reinstall: if TRUE force the reinstall of binary version.
#
#      :from_sources: if TRUE the external package will be reinstalled from sources if already installed. if value "SYSTEM" is given the OS variant of the version will be installed
#
#      :INSTALL_OK: the output variable that is TRUE is external package is installed, FALSE otherwise.
#
function(install_External_Package INSTALL_OK package reinstall from_sources)
#TODO from here
set(USE_SOURCES FALSE)#by default try to install from binaries, if they are available
set(SELECTED)
set(IS_EXACT FALSE)

# test if some binaries for this external package exists in the workspace
memorize_External_Binary_References(RES ${package})
if(NOT RES)# no binary reference found...
	set(USE_SOURCES TRUE)#...means we need to build this package from sources, if any available
endif()

# resolve finally required package version by current project, if any specific version required
if(reinstall AND from_sources)#if the package does not belong to packages to install then it means that its version is not adequate and it must be reinstalled
  set(USE_SOURCES TRUE) # by definition reinstall from sources (otherwise no change possible while PID does not handle mutliple archive for same platform/version)
  set(NO_VERSION FALSE)# we need to specify a version !
  set(IS_EXACT TRUE)#this version must be exact !!
  set(SELECTED ${${package}_VERSION_STRING})#the version to reinstall is the currenlty used one
  set(FORCE_REBUILD TRUE)
elseif(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX})
  #based on missing dependency, deduce the version constraint that applies
	resolve_Required_External_Package_Version(VERSION_POSSIBLE SELECTED IS_EXACT IS_SYSTEM ${package})
	if(NOT VERSION_POSSIBLE)
		message("[PID] ERROR : When deploying package ${package}, impossible to find an adequate version for package ${package}.")
		set(${INSTALL_OK} FALSE PARENT_SCOPE)
		return()
	else()
		message("[PID] INFO : deploying package ${package}...")
	endif()
  set(NO_VERSION FALSE)#a version must be used
  if(IS_SYSTEM)
    set(USE_SOURCES TRUE)#to get OS variant of a version we need to use sources (i.e. the wrapper project) !!
    set(IS_EXACT TRUE)#OS variant constraints are always exact !!
    set(FORCE_REBUILD TRUE)# always force the rebuild because the project can exist in filesystem but find script returned FALSE because this version is not the OS variant (furthermore generating symlinks to pre built binaries is a cheap operation so we can support removing existing symlinks)
  endif()
else()
	set(NO_VERSION TRUE)#no code in project of its dependencies apply constraint to the target external package version
endif()

# Just check if there is any chance to get an adequate Binary Archive for that external package
if(NOT USE_SOURCES) #no need to manage binairies if building from sources
	#otherwise we need to be sure that there are binaries
	get_Available_Binary_Package_Versions(${package} available_versions available_with_platform)
	if(NOT available_versions)
		set(USE_SOURCES TRUE)# no solution with binaries since no version available for current platform => so use the sources
	else()
		if(NOT NO_VERSION)#there is a constraint on the version to use
			set(RES FALSE)
			#try to find if at least one available version is OK
			foreach(version IN LISTS available_versions)
				if(version VERSION_EQUAL SELECTED)#exactly same version number => OK no need to continue
					set(RES TRUE)#at least a good version found !
					break()
				elseif(NOT IS_EXACT)#not exact, compatibility may be defined by a variable
					if(version VERSION_GREATER SELECTED
							AND version VERSION_LESS ${package}_PID_KNOWN_VERSION_${SELECTED}_GREATER_VERSIONS_COMPATIBLE_UP_TO)
							#greater version, may be compatible if version less than the maximum compatible version with version SELECTED
							set(RES TRUE)#at least a good version found !
							break()
					endif()
				endif()
			endforeach()
			if(NOT RES)#no version found compatible with required one
				set(USE_SOURCES TRUE)# no solution with binaries since no version available for current platform => so use the sources
			endif()
		endif()
	endif()
endif()

if(NOT USE_SOURCES)# we can still try a binary archive deployment
	set(BINARY_DEPLOYED FALSE)
	if(NO_VERSION)#there is no constraint on the version to use for package
		deploy_Binary_External_Package(BINARY_DEPLOYED ${package} "")
	else()	#we know there is at least an adequate version in binary format, the target version is SELECTED
		deploy_Binary_External_Package_Version(BINARY_DEPLOYED ${package} ${SELECTED} ${reinstall})
	endif()
	if(BINARY_DEPLOYED)
		if(NO_VERSION)
			message("[PID] INFO : external package ${package} has been installed from a binary archive.")
		else()
			message("[PID] INFO : external package ${package} (version ${SELECTED}) has been installed from a binary archive.")
		endif()
		set(${INSTALL_OK} TRUE PARENT_SCOPE)
		return()
	endif()
endif()

#from here no binary deployment has been possible
#so try to do it from sources
set(REPOSITORY_IN_WORKSPACE FALSE)
if(EXISTS ${WORKSPACE_DIR}/wrappers/${package})
	set(REPOSITORY_IN_WORKSPACE TRUE)
endif()
if(NOT REPOSITORY_IN_WORKSPACE)# if the external wrapper repository does not ly in workspace then install it
	deploy_Wrapper_Repository(DEPLOYED ${package})
	if(NOT DEPLOYED)
		message("[PID] ERROR : cannot clone external package ${package} wrapper repository. Deployment aborted !")
		set(${INSTALL_OK} FALSE PARENT_SCOPE)
		return()
	endif()
endif()

#get the list of already installed versions used to avoid installation if not mandatory
set(list_of_installed_versions)
if(EXISTS ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${package}/)
	list_Version_Subdirectories(RES_VERSIONS ${WORKSPACE_DIR}/external/${CURRENT_PLATFORM}/${package})
	set(list_of_installed_versions ${RES_VERSIONS})
  if(FORCE_REBUILD)
    list(REMOVE_ITEM list_of_installed_versions ${SELECTED})
  endif()
endif()

#now deploy
if(NO_VERSION)
	deploy_Source_External_Package(SOURCE_DEPLOYED ${package} "${list_of_installed_versions}")
else()
	deploy_Source_External_Package_Version(SOURCE_DEPLOYED ${package} ${SELECTED} "${IS_EXACT}" "${IS_SYSTEM}" "${list_of_installed_versions}")
endif()

if(SOURCE_DEPLOYED)
		message("[PID] INFO : external package ${package} has been deployed from its wrapper repository.")
		set(${INSTALL_OK} TRUE PARENT_SCOPE)
		return()
else()
	message("[PID] ERROR : cannot build external package ${package} from its wrapper repository. Deployment aborted !")
endif()
set(${INSTALL_OK} FALSE PARENT_SCOPE)
endfunction(install_External_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Binary_External_Package| replace:: ``deploy_Binary_External_Package``
#  .. _deploy_Binary_External_Package:
#
#  deploy_Binary_External_Package
#  ------------------------------
#
#   .. command:: deploy_Binary_External_Package(DEPLOYED package already_installed_versions)
#
#    Deploy an external package (last version) binary archive. It means that last version is installed and configured in the workspace.  See: download_And_Install_Binary_External_Package.
#
#      :package: The name of the external package to deploy.
#
#      :already_installed_versions: list of already installed versions for that package.
#
#      :DEPLOYED: the output variable that contains is TRUE if binary archive has been deployed, FALSE otherwise.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        external package binary references must be loaded before the call.
#
function(deploy_Binary_External_Package DEPLOYED package already_installed_versions)
set(available_versions "")
get_Available_Binary_Package_Versions(${package} available_versions available_with_platform)
if(NOT available_versions)
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()
select_Last_Version(RES_VERSION "${available_versions}")# taking the most up to date version from all eligible versions
list(FIND already_installed_versions ${RES_VERSION} INDEX)
set(INSTALLED FALSE)

if(INDEX EQUAL -1) # selected version not found in versions already installed
	check_Package_Version_State_In_Current_Process(${package} ${RES_VERSION} RES)
	if(RES STREQUAL "UNKNOWN") # this package version has not been build since beginning of the current process
		select_Platform_Binary_For_Version(${RES_VERSION} "${available_with_platform}" TARGET_PLATFORM)
		if(NOT TARGET_PLATFORM)
			message("[PID] ERROR : cannot find the binary version ${RES_VERSION} of package ${package} compatible with current platform.")
			set(${DEPLOYED} FALSE PARENT_SCOPE)
			return()
		endif()

		download_And_Install_Binary_External_Package(INSTALLED ${package} "${RES_VERSION}" "${TARGET_PLATFORM}")
		if(NOT INSTALLED)
      add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "PROBLEM" TRUE)
      message("[PID] ERROR : cannot install version ${RES_VERSION} of external package ${package}.")
      set(${DEPLOYED} FALSE PARENT_SCOPE)
      return()
		endif()
    #checking and resolving external package dependencies and constraints
    configure_Binary_Package(RESULT_DEBUG ${package} TRUE ${RES_VERSION} ${TARGET_PLATFORM} Debug)
    configure_Binary_Package(RESULT_RELEASE  ${package} TRUE ${RES_VERSION} ${TARGET_PLATFORM} Release)

    if(NOT RESULT_DEBUG OR NOT RESULT_RELEASE)
      add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "PROBLEM" TRUE)
      #need to remove the package because it cannot be configured
      uninstall_Binary_Package(${package} TRUE ${RES_VERSION} ${TARGET_PLATFORM})
      message("[PID] ERROR : cannot configure version ${RES_VERSION} of external package ${package}.")
      set(${DEPLOYED} FALSE PARENT_SCOPE)
      return()
    endif()

    add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" TRUE)

	else() #no need to do the job again if already successfull
		if(NOT RES STREQUAL "SUCCESS") # this package version has FAILED TO be installed during current process
			set(INSTALLED FALSE)
		else() #SUCCESS because last correct version already built
			set(INSTALLED TRUE)
		endif()
	endif()
else()#version to install already found in installed version
	set(INSTALLED TRUE) #if exlcuded it means that the version is already installed
	if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] INFO : package ${package} is already up to date ...")
	endif()
	add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" TRUE)
endif()

set(${DEPLOYED} ${INSTALLED} PARENT_SCOPE)
endfunction(deploy_Binary_External_Package)


### deploy means download + install + configure the external package in the workspace so that it can be used by a third party package.

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Binary_External_Package_Version| replace:: ``deploy_Binary_External_Package_Version``
#  .. _deploy_Binary_External_Package_Version:
#
#  deploy_Binary_External_Package_Version
#  --------------------------------------
#
#   .. command:: deploy_Binary_External_Package_Version(DEPLOYED package min_version is_exact already_installed_versions)
#
#    Deploy a given version of an external package from a binary archive. The external package version archive is installed  in the workspace and configured. See: download_And_Install_Binary_External_Package.
#
#      :package: The name of external package to deploy.
#
#      :min_version: The minimum allowed version for the binary archive
#
#      :is_exact: if TRUE then the exact constraint applies to min_version.
#
#      :already_installed_versions: list of already installed versions for that external package.
#
#      :DEPLOYED: the output variable that contains is TRUE if binary archive has been deployed, FALSE otherwise.
#
#     .. admonition:: Constraints
#        :class: warning
#
#        package binary references must be loaded before the call.
#
function(deploy_Binary_External_Package_Version DEPLOYED package version force)
set(available_versions "")
get_Available_Binary_Package_Versions(${package} available_versions available_with_platform)
if(NOT available_versions)
	message("[PID] ERROR : no available binary version of package ${package} that match current platform ${CURRENT_PLATFORM}.")
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()
#now getting the best platform for that version
select_Platform_Binary_For_Version("${version}" "${available_with_platform}" TARGET_PLATFORM)
if(NOT TARGET_PLATFORM)
	message("[PID] ERROR : cannot find the binary version ${version} of package ${package} compatible with current platform.")
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()
if(NOT force)# forcing means reinstalling from scratch
	check_Package_Version_State_In_Current_Process(${package} ${version} RES)
else()
	uninstall_External_Package(${package}) #if force then uninstall before reinstalling
	set(RES "UNKNOWN")
endif()
if(RES STREQUAL "UNKNOWN")
	download_And_Install_Binary_External_Package(INSTALLED ${package} ${version} ${TARGET_PLATFORM})
	if(NOT INSTALLED)
    add_Managed_Package_In_Current_Process(${package} ${version} "PROBLEM" TRUE)
    message("[PID] ERROR : cannot install version ${version} of external package ${package}.")
    set(${DEPLOYED} FALSE PARENT_SCOPE)
    return()
	endif()

  #5) checking for platform constraints
  configure_Binary_Package(RESULT_DEBUG ${package} TRUE ${version} ${TARGET_PLATFORM} Debug)
  configure_Binary_Package(RESULT_RELEASE ${package} TRUE ${version} ${TARGET_PLATFORM} Release)

  if(NOT RESULT_DEBUG OR NOT RESULT_RELEASE)
    add_Managed_Package_In_Current_Process(${package} ${version} "PROBLEM" TRUE)
    #need to remove the package because it cannot be configured
    uninstall_Binary_Package(${package} TRUE ${version} ${TARGET_PLATFORM})
    message("[PID] ERROR : cannot configure version ${version} of external package ${package}.")
    set(${DEPLOYED} FALSE PARENT_SCOPE)
    return()
  endif()
  add_Managed_Package_In_Current_Process(${package} ${version} "SUCCESS" TRUE)

elseif(NOT RES STREQUAL "SUCCESS") # this package version has already FAILED TO be install during current process
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()

set(${DEPLOYED} TRUE PARENT_SCOPE)
endfunction(deploy_Binary_External_Package_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |download_And_Install_Binary_External_Package| replace:: ``download_And_Install_Binary_External_Package``
#  .. _download_And_Install_Binary_External_Package:
#
#  download_And_Install_Binary_External_Package
#  --------------------------------------------
#
#   .. command:: download_And_Install_Binary_External_Package(INSTALLED package version platform)
#
#    Download the binary archive of target external package version and then install it. This call install all available build mode versions (Release and/or Debug) of the package in the same time.
#
#      :package: The name of the external package.
#
#      :version: version of the external package to install.
#
#      :platform: target platform for archive binary content.
#
#      :INSTALLED: the output variable that is TRUE if binary archive has been installed.
#
function(download_And_Install_Binary_External_Package INSTALLED package version platform)
set(${INSTALLED} FALSE PARENT_SCOPE)

###### downloading the binary package ######
message("[PID] INFO : deploying the external package ${package} with version ${version} for platform ${platform}, please wait ...")
if(ADDITIONNAL_DEBUG_INFO)
	message("[PID] INFO : installing external package ${package}, version ${version}...")
endif()

extract_Info_From_Platform(RES_ARCH RES_BITS RES_OS RES_ABI instance_str platform_str ${platform})

#1) release code
set(FILE_BINARY "")
set(FOLDER_BINARY "")
generate_Binary_Package_Name(${package} ${version} ${platform_str} Release FILE_BINARY FOLDER_BINARY)
set(download_url ${${package}_REFERENCE_${version}_${platform}_URL})#mechanism: "platform" in the name of download url variable contains the instance extension, if any
set(FOLDER_BINARY ${${package}_REFERENCE_${version}_${platform}_FOLDER})#mechanism: "platform" in the name of archive folder variable contains the instance extension, if any
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory release
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
			ERROR_QUIET OUTPUT_QUIET)
file(DOWNLOAD ${download_url} ${CMAKE_BINARY_DIR}/share/release/${FILE_BINARY} STATUS res SHOW_PROGRESS TLS_VERIFY OFF)
list(GET res 0 numeric_error)
list(GET res 1 status)
if(NOT numeric_error EQUAL 0)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : problem when downloading binary version ${version} of package ${package} from address ${download_url}: ${status}.")
	return()
endif()
#2) debug code (optionnal for external packages => just to avoid unecessary redoing code download)
if(EXISTS ${package}_REFERENCE_${version}_${platform}_URL_DEBUG)
	set(FILE_BINARY_DEBUG "")
	set(FOLDER_BINARY_DEBUG "")
	generate_Binary_Package_Name(${package} ${version} ${platform_str} Debug FILE_BINARY_DEBUG FOLDER_BINARY_DEBUG)
	set(download_url_dbg ${${package}_REFERENCE_${version}_${platform}_URL_DEBUG})#mechanism: "platform" in the name of download url variable contains the instance extension, if any
	set(FOLDER_BINARY_DEBUG ${${package}_REFERENCE_${version}_${platform}_FOLDER_DEBUG})#mechanism: "platform" in the name of archive folder variable contains the instance extension, if any
	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory debug
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
			ERROR_QUIET OUTPUT_QUIET)
	file(DOWNLOAD ${download_url_dbg} ${CMAKE_BINARY_DIR}/share/debug/${FILE_BINARY_DEBUG} STATUS res-dbg SHOW_PROGRESS TLS_VERIFY OFF)
	list(GET res-dbg 0 numeric_error_dbg)
	list(GET res-dbg 1 status_dbg)
	if(NOT numeric_error_dbg EQUAL 0)#there is an error
		set(${INSTALLED} FALSE PARENT_SCOPE)
		message("[PID] ERROR : problem when downloading binary version ${version} of package ${package} from address ${download_url_dbg} : ${status_dbg}.")
		return()
	endif()
endif()

######## installing the external package ##########
set(target_install_folder ${WORKSPACE_DIR}/external/${platform_str}/${package}/${version})
# 1) creating the external package root folder and the version folder
if(NOT EXISTS ${target_install_folder})
  file(MAKE_DIRECTORY ${target_install_folder})
endif()

# 2) extracting binary archive in cross platform way
set(error_res "")
set(error_res_debug "")
if(ADDITIONNAL_DEBUG_INFO)
	message("[PID] INFO : decompressing the external binary package ${package}, please wait ...")
endif()
if(EXISTS download_url_dbg)
	execute_process(
          	COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/debug/${FILE_BINARY_DEBUG}
        		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share/debug
        		ERROR_VARIABLE error_res_debug OUTPUT_QUIET)

	if (error_res_debug)
		set(${INSTALLED} FALSE PARENT_SCOPE)
		message("[PID] ERROR : cannot extract binary archives ${FILE_BINARY_DEBUG}.")
		return()
	endif()
endif()

execute_process(
	COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/release/${FILE_BINARY}
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share/release
	ERROR_VARIABLE error_res OUTPUT_QUIET)

if (error_res)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : cannot extract binary archives ${FILE_BINARY}.")
	return()
endif()

# 3) copying resulting folders into the install path in a cross platform way
if(ADDITIONNAL_DEBUG_INFO)
	message("[PID] INFO : installing the external binary package ${package} (version ${version}) into the workspace, please wait ...")
endif()
set(error_res "")
set(error_res_debug "")

if(EXISTS download_url_dbg)
	execute_process(
		COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/debug/${FOLDER_BINARY_DEBUG} ${target_install_folder}/
    ERROR_VARIABLE error_res_debug OUTPUT_QUIET)
endif()

execute_process(
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/release/${FOLDER_BINARY} ${target_install_folder}/
	ERROR_VARIABLE error_res OUTPUT_QUIET)

if (error_res OR error_res_debug)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : cannot extract folder from ${FOLDER_BINARY} ${FOLDER_BINARY_DEBUG} to get binary version ${version} of package ${package}.")
	return()
endif()
# 4) removing generated artifacts
if(EXISTS download_url_dbg)
	execute_process(
		COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/share/debug
		ERROR_QUIET OUTPUT_QUIET)
endif()

execute_process(
	COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/share/release
	ERROR_QUIET OUTPUT_QUIET)

set(${INSTALLED} TRUE PARENT_SCOPE)
endfunction(download_And_Install_Binary_External_Package)


#.rst:
#
# .. ifmode:: internal
#
#  .. |uninstall_Binary_Package| replace:: ``uninstall_Binary_Package``
#  .. _uninstall_Binary_Package:
#
#  uninstall_Binary_Package
#  ------------------------
#
#   .. command:: uninstall_Binary_Package(package external version platform)
#
#    Remove the given binary package from install tree
#
#      :package: The name of the external package.
#
#      :external: if TRUE the target package is an external package, otherwise it is a native package.
#
#      :version: version of the external package to install.
#
#      :platform: target platform for archive binary content (name may contain also instance extension).
#
function(uninstall_Binary_Package package external version platform)
  if(external)
    set(path_to_install ${WORKSPACE_DIR}/external/${platform}/${package}/${version})
  else()
    set(path_to_install ${WORKSPACE_DIR}/install/${platform}/${package}/${version})
  endif()
  if(EXISTS ${path_to_install})
    file(REMOVE_RECURSE ${path_to_install})
  endif()
endfunction(uninstall_Binary_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |configure_Binary_Package| replace:: ``configure_Binary_Package``
#  .. _configure_Binary_Package:
#
#  configure_Binary_Package
#  ------------------------
#
#   .. command:: configure_Binary_Package(RESULT package external version platform mode)
#
#    Configure the external package after it has been installed in workspace. It can lead to the install of OS packages depending of its system configuration.
#
#      :package: The name of the external package.
#
#      :external: if true teh target package is an external package, otherwise it is a native package.
#
#      :version: version of the external package to install.
#
#      :platform: target platform for archive binary content (name may contain also instance extension).
#
#      :mode: the build mode of the content installed.
#
#      :RESULT: the output variable that is TRUE if the binary package has been configured, FALSE if its configuration failed for any reason.
#
function(configure_Binary_Package RESULT package external version platform mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(${RESULT} TRUE PARENT_SCOPE)

extract_Info_From_Platform(RES_ARCH RES_BITS RES_OS RES_ABI RES_INSTANCE platform_base ${platform})

if(external)
  include(${WORKSPACE_DIR}/external/${platform_base}/${package}/${version}/share/Use${package}-${version}.cmake OPTIONAL RESULT_VARIABLE res)
  #using the hand written Use<package>-<version>.cmake file to get adequate version information about plaforms
  if(res STREQUAL NOTFOUND)
  	return()# no use file in external package ("raw external package") => nothing to do
  endif()
else()
  include(${WORKSPACE_DIR}/install/${platform_base}/${package}/${version}/share/Use${package}-${version}.cmake OPTIONAL RESULT_VARIABLE res)
  if(res STREQUAL NOTFOUND)
    set(${RESULT} FALSE PARENT_SCOPE)
    return()# no use file in native package => problem !
  endif()
endif()

# 0) checking global ABI compatibility
is_Compatible_With_Current_ABI(IS_ABI_COMPATIBLE ${package})
if(NOT IS_ABI_COMPATIBLE)
  message("[PID] WARNING : binaries in package ${package} version ${version} are not compatible with your current platform settings.")
  set(${RESULT} FALSE PARENT_SCOPE)
  return() #problem => the binary package has been built with an incompatible C++ ABI
endif()

# 1) checking platforms constraints
set(CONFIGS_TO_CHECK)
if(${package}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX})
	set(CONFIGS_TO_CHECK ${${package}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX}})#there are configuration constraints in PID v2 style
elseif(${package}_PLATFORM${VAR_SUFFIX} STREQUAL platform) # this case may be true if the package binary has been release in old PID v1 style
	set(OLD_PLATFORM_CONFIG ${${package}_PLATFORM_${platform}_CONFIGURATION${VAR_SUFFIX}})
	if(OLD_PLATFORM_CONFIG) #there are required configurations in old style
		set(CONFIGS_TO_CHECK ${OLD_PLATFORM_CONFIG})#there are configuration constraints in PID v1 style
	endif()
endif()

# 2) checking constraints on configuration
foreach(config IN LISTS CONFIGS_TO_CHECK)#if empty no configuration for this platform is supposed to be necessary
  check_System_Configuration_With_Arguments(RESULT_OK BINARY_CONSTRAINTS ${config} ${package}_PLATFORM_CONFIGURATION_${config}_ARGS${VAR_SUFFIX})
  if(RESULT_OK)
    message("[PID] INFO : platform configuration ${config} for package ${package} is satisfied.")
  else()
    message("[PID] WARNING : platform configuration ${config} for package ${package} is NOT satisfied.")
    set(${RESULT} FALSE PARENT_SCOPE)
    return()
  endif()
endforeach()

# Manage external package dependencies => need to check direct external dependencies
foreach(dep_pack IN LISTS ${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}) #check that version of these dependencies is OK
  if(${package}_EXTERNAL_DEPENDENCY_${dep_pack}_VERSION${VAR_SUFFIX})#there is a specific version to target (should be most common case)
    get_Chosen_Version_In_Current_Process(REQUIRED_VERSION IS_EXACT IS_SYSTEM ${dep_pack})
  	if(REQUIRED_VERSION)#if a version of the same package is already required then check their compatibility
      get_Compatible_Version(IS_COMPATIBLE TRUE ${dep_pack} ${REQUIRED_VERSION} ${IS_EXACT} ${IS_SYSTEM} ${${package}_EXTERNAL_DEPENDENCY_${dep_pack}_VERSION${VAR_SUFFIX}} "${${package}_EXTERNAL_DEPENDENCY_${dep_pack}_VERSION_EXACT${VAR_SUFFIX}}" "${${package}_EXTERNAL_DEPENDENCY_${dep_pack}_VERSION_SYSTEM${VAR_SUFFIX}}")
        if(NOT IS_COMPATIBLE)
          set(${RESULT} FALSE PARENT_SCOPE)
          message("[PID] ERROR : package ${package} uses external package ${dep_pack} with version ${${package}_EXTERNAL_DEPENDENCY_${dep_pack}_VERSION${VAR_SUFFIX}}, and this version is not compatible with already used version ${REQUIRED_VERSION}.")
          return()
        endif()
      endif()
  endif()
endforeach()

if(NOT external)
  # Manage native package dependencies => need to check direct native dependencies
	foreach(dep_pack IN LISTS ${package}_DEPENDENCIES${VAR_SUFFIX}) #check that version of these dependencies is OK
    if(${package}_DEPENDENCY_${dep_pack}_VERSION${VAR_SUFFIX})#there is a specific version to target (should be most common case)
      get_Chosen_Version_In_Current_Process(REQUIRED_VERSION IS_EXACT IS_SYSTEM ${dep_pack})
    	if(REQUIRED_VERSION)#if a version of the same native package is already required then check their compatibility
        get_Compatible_Version(IS_COMPATIBLE FALSE ${dep_pack} ${REQUIRED_VERSION} ${IS_EXACT} FALSE ${${package}_DEPENDENCY_${dep_pack}_VERSION${VAR_SUFFIX}} "${${package}_DEPENDENCIY_${dep_pack}_VERSION_EXACT${VAR_SUFFIX}}" FALSE)
        if(NOT IS_COMPATIBLE)
          set(${RESULT} FALSE PARENT_SCOPE)
          message("[PID] ERROR : package ${package} uses external package ${dep_pack} with version ${${package}_DEPENDENCY_${dep_pack}_VERSION${VAR_SUFFIX}}, and this version is not compatible with already used version ${REQUIRED_VERSION}.")
          return()
        endif()
      endif()
    endif()
  endforeach()
endif()

endfunction(configure_Binary_Package)

#############################################################################################
############################### functions for frameworks ####################################
#############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Framework_Repository| replace:: ``deploy_Framework_Repository``
#  .. _deploy_Framework_Repository:
#
#  deploy_Framework_Repository
#  ---------------------------
#
#   .. command:: deploy_Framework_Repository(IS_DEPLOYED framework)
#
#    Deploy a framework git repository into the workspace.
#
#      :framework: The name of the framework.
#
#      :IS_DEPLOYED: the output variable that is TRUE if framework has ben deployed.
#
function(deploy_Framework_Repository IS_DEPLOYED framework)
if(${framework}_FRAMEWORK_ADDRESS)
	if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] INFO : cloning the repository of framework ${framework}...")
	endif()
	clone_Framework_Repository(DEPLOYED ${framework} ${${framework}_FRAMEWORK_ADDRESS})
	if(DEPLOYED)
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : repository of framework ${framework} has been cloned.")
		endif()
	else()
		message("[PID] ERROR : cannot clone the repository of framework ${framework}.")
	endif()
	set(${IS_DEPLOYED} ${DEPLOYED} PARENT_SCOPE)
else()
	set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : impossible to clone the repository of framework ${framework} (no repository address defined). This is maybe due to a malformed package, please contact the administrator of this framework.")
endif()
endfunction(deploy_Framework_Repository)

#############################################################################################
############################### functions for frameworks ####################################
#############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |deploy_Environment_Repository| replace:: ``deploy_Environment_Repository``
#  .. _deploy_Environment_Repository:
#
#  deploy_Environment_Repository
#  -----------------------------
#
#   .. command:: deploy_Environment_Repository(IS_DEPLOYED environment)
#
#    Deploy an environment git repository into the workspace.
#
#      :environment: The name of the environment.
#
#      :IS_DEPLOYED: the output variable that is TRUE if environment has ben deployed.
#
function(deploy_Environment_Repository IS_DEPLOYED environment)
if(${environment}_ADDRESS OR ${environment}_PUBLIC_ADDRESS)
	if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] INFO : cloning the repository of environment ${environment}...")
	endif()
  if(${environment}_PUBLIC_ADDRESS)
    set(addr ${${environment}_PUBLIC_ADDRESS})
  elseif(${environment}_ADDRESS)
    set(addr ${${environment}_ADDRESS})
  endif()
	clone_Environment_Repository(DEPLOYED ${environment} ${addr})
	if(DEPLOYED)
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : repository of environment ${environment} has been cloned.")
		endif()
	else()
		message("[PID] ERROR : cannot clone the repository of environment ${environment}.")
	endif()
	set(${IS_DEPLOYED} ${DEPLOYED} PARENT_SCOPE)
else()
	set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : impossible to clone the repository of environment ${environment} (no repository address defined). This is maybe due to a malformed package, please contact the administrator of this environment.")
endif()
endfunction(deploy_Environment_Repository)
