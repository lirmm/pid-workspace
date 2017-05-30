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

#############################################################################################
############### API functions for managing references on dependent packages #################
#############################################################################################

### generate the reference file used to retrieve packages
function(generate_Reference_File pathtonewfile)
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
file(APPEND ${file} "set(${PROJECT_NAME}_SITE_INTRODUCTION ${${PROJECT_NAME}_SITE_INTRODUCTION} CACHE INTERNAL \"\")\n")

set(res_string "")
foreach(auth IN ITEMS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS})
	list(APPEND res_string ${auth})
endforeach()
set(printed_authors "${res_string}")
file(APPEND ${file} "set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS \"${res_string}\" CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_DESCRIPTION ${${PROJECT_NAME}_DESCRIPTION} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_YEARS ${${PROJECT_NAME}_YEARS} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_LICENSE ${${PROJECT_NAME}_LICENSE} CACHE INTERNAL \"\")\n")
file(APPEND ${file} "set(${PROJECT_NAME}_ADDRESS ${${PROJECT_NAME}_ADDRESS} CACHE INTERNAL \"\")\n")
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
if(${PROJECT_NAME}_REFERENCES)
foreach(ref_version IN ITEMS ${${PROJECT_NAME}_REFERENCES}) #for each available version, all os for which there is a reference
	file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version} ${${PROJECT_NAME}_REFERENCE_${ref_version}} CACHE INTERNAL \"\")\n")
	if(${PROJECT_NAME}_REFERENCE_${ref_version})
	foreach(ref_platform IN ITEMS ${${PROJECT_NAME}_REFERENCE_${ref_version}})#for each version & os, all arch for which there is a reference
		file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL ${${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL} CACHE INTERNAL \"\")\n")
		file(APPEND ${file} "set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG ${${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_platform}_URL_DEBUG} CACHE INTERNAL \"\")\n")
	endforeach()
	endif()
endforeach()
endif()
endfunction(generate_Reference_File)


#############################################################################################
############ Generic functions to deploy packages (either source or binary, native or #######
################ external) in the workspace #################################################
#############################################################################################

### resolving dependencies means that each dependency of teh package finally targets a given package located in the workspace. This can lead to the install of packages either direct or undirect dependencies of the target package.
function(resolve_Package_Dependencies package mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
################## management of external packages : for both external and native packages ##################

# 1) managing external package dependencies (the list of dependent packages is defined as ${package}_EXTERNAL_DEPENDENCIES)
# - locating dependent external packages in the workspace and configuring their build variables recursively
set(TO_INSTALL_EXTERNAL_DEPS)
if(${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep_ext_pack IN ITEMS ${${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}})
		# 1) resolving direct dependencies
		resolve_External_Package_Dependency(${package} ${dep_ext_pack} ${mode})
		if(NOT ${dep_ext_pack}_FOUND)
			list(APPEND TO_INSTALL_EXTERNAL_DEPS ${dep_ext_pack})
		endif()
	endforeach()
endif()

# 2) for not found package
if(TO_INSTALL_EXTERNAL_DEPS) #there are dependencies to install
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		set(INSTALLED_EXTERNAL_PACKAGES "")
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : package ${package} needs to install following packages : ${TO_INSTALL_EXTERNAL_DEPS}")
		endif()
		install_Required_External_Packages("${TO_INSTALL_EXTERNAL_DEPS}" INSTALLED_EXTERNAL_PACKAGES)
		foreach(installed IN ITEMS ${INSTALLED_EXTERNAL_PACKAGES})#recursive call for newly installed packages
			resolve_External_Package_Dependency(${package} ${installed} ${mode})
			if(NOT ${installed}_FOUND)
				message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find installed external package ${installed}. This is an internal bug maybe due to a bad find file.")
				return()
			endif()
			if(${installed}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}) #are there any dependency (external only) for this external package
				resolve_Package_Dependencies(${installed} ${mode})#recursion : resolving dependencies for each external package dependency
			endif()
		endforeach()
	else()
		message(FATAL_ERROR "[PID] CRITICAL ERROR :  there are some unresolved required external package dependencies : ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${VAR_SUFFIX}}. You may use the required packages automatic download option.")
		return()
	endif()
endif()

################## for native packages only ##################

# 1) managing package dependencies (the list of dependent packages is defined as ${package}_DEPENDENCIES)
# - locating dependent packages in the workspace and configuring their build variables recursively
set(TO_INSTALL_DEPS)
if(${package}_DEPENDENCIES${VAR_SUFFIX})
	foreach(dep_pack IN ITEMS ${${package}_DEPENDENCIES${VAR_SUFFIX}})
		# 1) resolving direct dependencies
		resolve_Package_Dependency(${package} ${dep_pack} ${mode})
		if(${dep_pack}_FOUND)
			#message("resolve_Package_Dependencies ${package} ${dep_pack} deps = ${${dep_pack}_DEPENDENCIES${VAR_SUFFIX}} extdeps= ${${dep_pack}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}}")
			if(${dep_pack}_DEPENDENCIES${VAR_SUFFIX} OR ${dep_pack}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}) #are there any dependency (native or external) for this package
				resolve_Package_Dependencies(${dep_pack} ${mode})#recursion : resolving dependencies for each package dependency
			endif()
		else()
			list(APPEND TO_INSTALL_DEPS ${dep_pack})
		endif()
	endforeach()
endif()

# 2) for not found package
if(TO_INSTALL_DEPS) #there are dependencies to install
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		set(INSTALLED_PACKAGES "")
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : package ${package} needs to install following packages : ${TO_INSTALL_DEPS}")
		endif()
		install_Required_Packages("${TO_INSTALL_DEPS}" INSTALLED_PACKAGES NOT_INSTALLED)
		foreach(installed IN ITEMS ${INSTALLED_PACKAGES})#recursive call for newly installed packages
			resolve_Package_Dependency(${package} ${installed} ${mode})
			if(${installed}_FOUND)
				if(${installed}_DEPENDENCIES${VAR_SUFFIX})
					resolve_Package_Dependencies(${installed} ${mode})#recursion : resolving dependencies for each package dependency
				endif()
			else()
				message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find installed package ${installed}")
			endif()
		endforeach()
	else()
		message(FATAL_ERROR "[PID] CRITICAL ERROR : there are some unresolved required package dependencies : ${${PROJECT_NAME}_TOINSTALL_PACKAGES${VAR_SUFFIX}}. You may download them \"by hand\" or use the required packages automatic download option")
		return()
	endif()
endif()
endfunction(resolve_Package_Dependencies)

#############################################################################################
############## General functions to deploy  Native Packages (binary or source) ##############
#############################################################################################

### function called by find script subfunctions to automatically update a package, if possible
function(update_Package_Installed_Version package major minor exact already_installed)
first_Called_Build_Mode(FIRST_TIME) # do the update only once per global configuration of the project
if(FIRST_TIME AND REQUIRED_PACKAGES_AUTOMATIC_UPDATE) #if no automatic download then simply do nothing
	if(NOT major STREQUAL "" AND NOT minor STREQUAL "")
		set(WITH_VERSION TRUE)
		check_Package_Version_Managed_In_Current_Process(${package} "${major}.${minor}" RES)
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
				deploy_Source_Package_Version(IS_DEPLOYED ${package} "${major}.${minor}" ${exact} "${already_installed}")
			else()
				deploy_Source_Package(IS_DEPLOYED ${package} "${already_installed}") #install last version available
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
				deploy_Binary_Package_Version(IS_DEPLOYED ${package} "${major}.${minor}" ${exact} "${already_installed}")
			else()
				deploy_Binary_Package(IS_DEPLOYED ${package} "${already_installed}") #install last version available
			endif()
		endif()
	endif()
endif()
endfunction(update_Package_Installed_Version)


### function used to select an adequate version to install for a given package.
function(resolve_Required_Package_Version version_possible min_version is_exact package)

foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX}})
	get_Version_String_Numbers("${version}.0" compare_major compare_minor compared_patch)
	if(NOT MAJOR_RESOLVED)#first time
		set(MAJOR_RESOLVED ${compare_major})
		set(CUR_MINOR_RESOLVED ${compare_minor})
		if(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX})
			set(CURR_EXACT TRUE)
		else()
			set(CURR_EXACT FALSE)
		endif()
	elseif(NOT compare_major EQUAL ${MAJOR_RESOLVED})
		set(${version_possible} FALSE PARENT_SCOPE)
		return()
	elseif(CURR_EXACT AND (compare_minor GREATER ${CUR_MINOR_RESOLVED}))
		set(${version_possible} FALSE PARENT_SCOPE)
		return()
	elseif(NOT CURR_EXACT AND (compare_minor GREATER ${CUR_MINOR_RESOLVED}))
		set(CUR_MINOR_RESOLVED ${compare_minor})
		if(${PROJECT_NAME}_TOINSTALL_${package}_${version}_EXACT${USE_MODE_SUFFIX})
			set(CURR_EXACT TRUE)
		else()
			set(CURR_EXACT FALSE)
		endif()
	endif()
endforeach()
set(${version_possible} TRUE PARENT_SCOPE)
set(${min_version} "${MAJOR_RESOLVED}.${CUR_MINOR_RESOLVED}" PARENT_SCOPE)
set(${is_exact} ${CURR_EXACT} PARENT_SCOPE)
endfunction(resolve_Required_Package_Version)


### root function for launching automatic installation of all dependencies of a given package.
function(install_Required_Packages list_of_packages_to_install INSTALLED_PACKAGES NOT_INSTALLED)
set(successfully_installed )
set(not_installed )
set(${NOT_INSTALLED} PARENT_SCOPE)
foreach(dep_package IN ITEMS ${list_of_packages_to_install}) #while there are still packages to install
	set(INSTALL_OK FALSE)
	install_Package(INSTALL_OK ${dep_package})
	if(INSTALL_OK)
		list(APPEND successfully_installed ${dep_package})
	else()
		list(APPEND not_installed ${dep_package})
	endif()
endforeach()
if(successfully_installed)
	set(${INSTALLED_PACKAGES} ${successfully_installed} PARENT_SCOPE)
endif()
if(not_installed)
	message("[PID] ERROR : some of the required packages cannot be installed : ${not_installed}.")
	set(${NOT_INSTALLED} ${not_installed} PARENT_SCOPE)
endif()
endfunction(install_Required_Packages)

### check if the repository of a package already lies in the workspace.
function(package_Source_Exists_In_Workspace EXIST RETURNED_PATH package)
set(res FALSE)
if(EXISTS ${WORKSPACE_DIR}/packages/${package} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
set(res TRUE)
set(${RETURNED_PATH} ${WORKSPACE_DIR}/packages/${package} PARENT_SCOPE)
endif()
set(${EXIST} ${res} PARENT_SCOPE)
endfunction(package_Source_Exists_In_Workspace)

### check if the reference file of a package lies in the workspace.
function(package_Reference_Exists_In_Workspace EXIST package)
set(res FALSE)
if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/Refer${package}.cmake)
set(res TRUE)
endif()
set(${EXIST} ${res} PARENT_SCOPE)
endfunction(package_Reference_Exists_In_Workspace)

### include the reference file of a package that lies in the workspace.
function(get_Package_References LIST_OF_REFS package)
include(Refer${package} OPTIONAL RESULT_VARIABLE res)
if(	${res} STREQUAL NOTFOUND) #if there is no component defined for the package there is an error
	set(${EXIST} ${FALSE} PARENT_SCOPE)
	return()
endif()
set(${EXIST} ${FALSE} PARENT_SCOPE)
endfunction(get_Package_References)


### install a package for the first time
function(install_Package INSTALL_OK package)

# 0) test if either reference or source of the package exist in the workspace
set(IS_EXISTING FALSE)
set(PATH_TO_SOURCE "")
package_Source_Exists_In_Workspace(IS_EXISTING PATH_TO_SOURCE ${package})
if(IS_EXISTING)
	set(USE_SOURCES TRUE)
else()
	set(IS_EXISTING)
	package_Reference_Exists_In_Workspace(IS_EXISTING ${package})
	if(IS_EXISTING)
		set(USE_SOURCES FALSE)
	else()
		set(${INSTALL_OK} FALSE PARENT_SCOPE)
		message("[PID] ERROR : unknown package ${package}, cannot find any source or reference of this package in the workspace.")
		return()
	endif()
endif()
if(${PROJECT_NAME}_TOINSTALL_${package}_VERSIONS${USE_MODE_SUFFIX})
# 1) resolve finally required package version (if any specific version required) (major.minor only, patch is let undefined)
	set(POSSIBLE FALSE)
	set(VERSION_MIN)
	set(EXACT FALSE)
	resolve_Required_Package_Version(POSSIBLE VERSION_MIN EXACT ${package})
	if(NOT POSSIBLE)
		message("[PID] ERROR : When deploying package ${package}, impossible to find an adequate version for package ${package}.")
		set(${INSTALL_OK} FALSE PARENT_SCOPE)
		return()
	else()
		message("[PID] INFO : deploying package ${package}...")
	endif()
	set(NO_VERSION FALSE)
else()
	set(NO_VERSION TRUE)
endif()

if(USE_SOURCES) #package sources reside in the workspace

	set(SOURCE_DEPLOYED FALSE)
	if(NOT NO_VERSION)
		deploy_Source_Package_Version(SOURCE_DEPLOYED ${package} ${VERSION_MIN} ${EXACT} "")
	else()
		deploy_Source_Package(SOURCE_DEPLOYED ${package} "") # case when the sources exist but haven't been installed yet (should never happen)
	endif()
	if(NOT SOURCE_DEPLOYED)
		message("[PID] ERROR : impossible to deploy package ${package} from sources. Try \"by hand\".")
	else()
		set(${INSTALL_OK} TRUE PARENT_SCOPE)
	endif()
else()#using references
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

	set(PACKAGE_BINARY_DEPLOYED FALSE)
	if(NOT ${refer_path} STREQUAL NOTFOUND)
		if(NOT NO_VERSION)#seeking for an adequate version regarding the pattern VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the greatest minor version number
			deploy_Binary_Package_Version(PACKAGE_BINARY_DEPLOYED ${package} ${VERSION_MIN} ${EXACT} "")
		else()# deploying the most up to date version
			deploy_Binary_Package(PACKAGE_BINARY_DEPLOYED ${package} "")
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
			set(SOURCE_DEPLOYED FALSE)
			if(NOT NO_VERSION)
				deploy_Source_Package_Version(SOURCE_DEPLOYED ${package} ${VERSION_MIN} ${EXACT} "")
			else()
				deploy_Source_Package(SOURCE_DEPLOYED ${package} "")
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
endfunction(install_Package)

### Get the references to binary archives containing package versions. Constraint: the reference file of the package must be loaded before this call.
function(load_Package_Binary_References REFERENCES_OK package)
set(${REFERENCES_OK} FALSE PARENT_SCOPE)
if(${package}_FRAMEWORK) #references are deployed in a framework
	if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferFramework${${package}_FRAMEWORK}.cmake)
		#when package is in a framework there is one more indirection to get references (we need to get information about this framework before downloading the reference file)
		include(${WORKSPACE_DIR}/share/cmake/references/ReferFramework${${package}_FRAMEWORK}.cmake)
		set(FRAMEWORK_ADDRESS ${${${package}_FRAMEWORK}_FRAMEWORK_SITE})#get the address of the framework static site
		file(DOWNLOAD ${FRAMEWORK_ADDRESS}/packages/${package}/binaries/binary_references.cmake ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake STATUS res SHOW_PROGRESS TLS_VERIFY OFF)
		list(GET res 0 numeric_error)
		if(numeric_error EQUAL 0 #framework site is online & reference available.
		AND EXISTS ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake)
			include(${WORKSPACE_DIR}/pid/${package}_binary_references.cmake)
		else() #it may be an external package, try this
			file(DOWNLOAD ${FRAMEWORK_ADDRESS}/external/${package}/binary_references.cmake ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake STATUS res SHOW_PROGRESS TLS_VERIFY OFF)
			list(GET res 0 numeric_error)
			if(numeric_error EQUAL 0 #framework site is online & reference available.
			AND EXISTS ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake)
				include(${WORKSPACE_DIR}/pid/${package}_binary_references.cmake)
			endif()
		endif()
	endif()
elseif(${package}_SITE_GIT_ADDRESS)  #references are deployed in a lone static site
	#when package has a lone static site, the reference file can be directly downloaded
	file(DOWNLOAD ${${package}_SITE_ROOT_PAGE}/binaries/binary_references.cmake ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake STATUS res SHOW_PROGRESS TLS_VERIFY OFF)
	list(GET res 0 numeric_error)
	if(numeric_error EQUAL 0 #static site online & reference available.
	AND EXISTS ${WORKSPACE_DIR}/pid/${package}_binary_references.cmake)
		include(${WORKSPACE_DIR}/pid/${package}_binary_references.cmake)
	endif()
endif()
if(${package}_REFERENCES) #if there are direct reference (simpler case), no need to do more becase binary references are already included
	set(${REFERENCES_OK} TRUE PARENT_SCOPE)
	return()
endif()
endfunction(load_Package_Binary_References)

##################################################################################################
############################### functions for native source Packages #############################
##################################################################################################

### function used to put into workspace the repository of the native package.
function(deploy_Package_Repository IS_DEPLOYED package)
if(${package}_ADDRESS)
	if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] INFO : cloning the repository of source package ${package}...")
	endif()
	clone_Repository(DEPLOYED ${package} ${${package}_ADDRESS})
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

### function used to configure and build the target package version. Called by: deploy_Source_Package and deploy_Source_Package_Version.
function(build_And_Install_Source DEPLOYED package version)
	if(ADDITIONNAL_DEBUG_INFO)
		message("[PID] INFO : configuring version ${version} of package ${package} ...")
	endif()
	execute_process(
		COMMAND ${CMAKE_COMMAND} -D BUILD_EXAMPLES:BOOL=OFF -D BUILD_RELEASE_ONLY:BOOL=OFF -D GENERATE_INSTALLER:BOOL=OFF -D BUILD_API_DOC:BOOL=OFF -D BUILD_LATEX_API_DOC:BOOL=OFF -D BUILD_AND_RUN_TESTS:BOOL=OFF -D REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD:BOOL=ON -D ENABLE_PARALLEL_BUILD:BOOL=ON -D BUILD_DEPENDENT_PACKAGES:BOOL=OFF -D ADDITIONNAL_DEBUG_INFO:BOOL=${ADDITIONNAL_DEBUG_INFO} ..
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build
		RESULT_VARIABLE CONFIG_RES
	)

	if(CONFIG_RES EQUAL 0)
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : building version ${version} of package ${package} ...")
		endif()
		execute_process(
			COMMAND ${CMAKE_MAKE_PROGRAM} build "force=true"
			WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}/build
			RESULT_VARIABLE BUILD_RES
			)
		get_System_Variables(platform package_string)
		if(BUILD_RES EQUAL 0 AND EXISTS ${WORKSPACE_DIR}/install/${platform}/${package}/${version}/share/Use${package}-${version}.cmake)
			set(${DEPLOYED} TRUE PARENT_SCOPE)
			if(ADDITIONNAL_DEBUG_INFO)
				message("[PID] INFO : ... package ${package} version ${version} built !")
			endif()
			return()
		else()
			message("[PID] ERROR : ... building package ${package} version ${version} has FAILED !")
		endif()

	else()
		message("[PID] ERROR : ... configuration of package ${package} version ${version} has FAILED !")
	endif()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
endfunction(build_And_Install_Source)

### deploy a package means manage git repository + configure + build the native SOURCE package in the workspace so that it can be used by a third party package. It goes to the adequate revision corresponding to the best version according to constraints passed as arguments then configure and build it. See: build_And_Install_Package. See: build_And_Install_Source.
function(deploy_Source_Package DEPLOYED package already_installed_versions)
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
		build_And_Install_Package(ALL_IS_OK ${package} "${RES_VERSION}")

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
		message("[PID] WARNING : when installing the package ${package} from source : a possibly conflicting binary package with same version ${RES_VERSION} is already installed. Please uninstall it by hand by using the \"make uninstall\" command from package  build folder or \"make clear name=${package} version=${RES_VERSION} from workspace pid folder.\"")
	else()	#problem : the installed version is the result of the user build
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : package ${package} is already up to date ...")
		endif()
	endif()
	set(${DEPLOYED} TRUE PARENT_SCOPE)
	add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
endif()
restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
endfunction(deploy_Source_Package)


### deploy a version means manage git repository + configure + build the native SOURCE package version in the workspace so that it can be used by a third party package. It goes to the adequate revision corresponding to the best version according to constraints passed as arguments then configure and build it. See: build_And_Install_Package.
function(deploy_Source_Package_Version DEPLOYED package VERSION_MIN EXACT already_installed_versions)
set(${DEPLOYED} FALSE PARENT_SCOPE)
# go to package source and find all version matching the pattern of VERSION_MIN : if exact taking VERSION_MIN, otherwise taking the greatest version number
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

if(EXACT)
	select_Exact_Version(RES_VERSION ${VERSION_MIN} "${VERSION_NUMBERS}")
else()
	select_Best_Version(RES_VERSION ${VERSION_MIN} "${VERSION_NUMBERS}")
endif()
if(NOT RES_VERSION)
	message("[PID] WARNING : no adequate version found for source package ${package} !! Maybe this is due to a malformed package (contact the administrator of this package). Otherwise that may mean you use a non released version of ${package} (in development version).")
	restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
	return()
endif()

list(FIND already_installed_versions ${RES_VERSION} INDEX)
if(INDEX EQUAL -1) # selected version is not excluded from deploy process
	check_Package_Version_State_In_Current_Process(${package} ${RES_VERSION} RES)
	if(RES STREQUAL "UNKNOWN" OR RES STREQUAL "PROBLEM") # this package version has not been build since last command OR this package version has FAILED TO be deployed from binary during current process
		set(ALL_IS_OK FALSE)
		build_And_Install_Package(ALL_IS_OK ${package} "${RES_VERSION}")
		if(ALL_IS_OK)
			message("[PID] INFO : package ${package} version ${RES_VERSION} has been deployed ...")
			set(${DEPLOYED} TRUE PARENT_SCOPE)
			add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
		else()
			message("[PID]  ERROR : automatic build and install of package ${package} (version ${RES_VERSION}) FAILED !!")
			add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "FAIL" FALSE)
		endif()
	else()
		if(RES STREQUAL "FAIL") # this package version has FAILED TO be built during current process
			set(${DEPLOYED} FALSE PARENT_SCOPE)
		else() #SUCCESS because last correct version already built
			if(ADDITIONNAL_DEBUG_INFO)
				message("[PID] INFO : package ${package} version ${RES_VERSION} is deployed ...")
			endif()
			set(${DEPLOYED} TRUE PARENT_SCOPE)
		endif()

	endif()
else()
	is_Binary_Package_Version_In_Development(IN_DEV ${package} ${RES_VERSION})
	if(IN_DEV) # dev version is not generating the same binary as currently installed version
		message("[PID] WARNING : when installing the package ${package} from source : a possibly conflicting binary package with same version ${RES_VERSION} is already installed. Please uninstall it by hand by using the \"make uninstall\" command from package build folder or \"make clear name=${package} version=${RES_VERSION} from workspace pid folder.\"")
	else()	#problem : the installed version is the result of the user build
		if(ADDITIONNAL_DEBUG_INFO)
			message("[PID] INFO : package ${package} is already up to date ...")
		endif()
	endif()
	set(${DEPLOYED} TRUE PARENT_SCOPE)
	add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
endif()

restore_Repository_Context(${package} ${CURRENT_COMMIT} ${SAVED_CONTENT})
endfunction(deploy_Source_Package_Version)


### intermediate internal function that is used to put the source package in an adequate version (using git tags) and then build it. See: build_And_Install_Source.
function(build_And_Install_Package DEPLOYED package version)

# 1) going to the adequate git tag matching the selected version
go_To_Version(${package} ${version})
# 2) building sources
set(IS_BUILT FALSE)

build_And_Install_Source(IS_BUILT ${package} ${version})

if(IS_BUILT)
	set(${DEPLOYED} TRUE PARENT_SCOPE)
else()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
endif()
endfunction(build_And_Install_Package)

##################################################################################################
############################### functions for native binary Packages #############################
##################################################################################################

### function to test if platforms configurations defined for binary packages are matching the current platform
function(check_Package_Platform_Against_Current package platform CHECK_OK)
set(${CHECK_OK} TRUE PARENT_SCOPE)
get_System_Variables(PLATFORM_STRING PACKAGE_STRING)
if(platform STREQUAL ${PLATFORM_STRING})
	# OK this binary version is theorically eligible, but need to check for its platform configuration to be sure it can be used
	set(CONFIGS_TO_CHECK)
	if(${package}_PLATFORM_CONFIGURATIONS)
		set(CONFIGS_TO_CHECK ${${package}_PLATFORM_CONFIGURATIONS})
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

	if(CONFIGS_TO_CHECK)
		foreach(config IN ITEMS ${CONFIGS_TO_CHECK})
			if(EXISTS ${WORKSPACE_DIR}/share/cmake/constraints/configurations/${config}/find_${config}.cmake)
				include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/${config}/find_${config}.cmake)	# find the configuation
				if(NOT ${config}_FOUND)# not found, trying to see if can be installed
					if(EXISTS ${WORKSPACE_DIR}/share/cmake/constraints/configurations/${config}/installable_${config}.cmake)
						include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/${config}/installable_${config}.cmake)
						if(NOT ${config}_INSTALLABLE)
							set(${CHECK_OK} FALSE PARENT_SCOPE)
							return()
						endif()
					else()
						set(${CHECK_OK} FALSE PARENT_SCOPE)
						return()
					endif()
				endif()
			else()
				set(${CHECK_OK} FALSE PARENT_SCOPE)
				return()
			endif()
		endforeach()
	endif()#OK no specific check for configuration so simply reply TRUE
else()#the binary is not eligible since does not match either familly, os, arch or ABI of the current system
	set(${CHECK_OK} FALSE PARENT_SCOPE)
	return()
endif()
endfunction(check_Package_Platform_Against_Current)


### get the list of binary versions of a given packages that conforms to current platform constraints
function(get_Available_Binary_Package_Versions package list_of_versions list_of_versions_with_platform)
# listing available binaries of the package and searching if there is any "good version"
set(available_binary_package_version "")
foreach(ref_version IN ITEMS ${${package}_REFERENCES})
	foreach(ref_platform IN ITEMS ${${package}_REFERENCE_${ref_version}})
		set(BINARY_OK FALSE)
		check_Package_Platform_Against_Current(${package} ${ref_platform} BINARY_OK)#will return TRUE if the platform conforms to current one
		if(BINARY_OK)
			list(APPEND available_binary_package_version "${ref_version}")
			list(APPEND available_binary_package_version_with_platform "${ref_version}/${ref_platform}")
			break() # no need to test for following platform only the first is selected (this one has the greatest priority by construction)
		endif()
	endforeach()
endforeach()
if(NOT available_binary_package_version)
	return()#nothing to do
endif()
list(REMOVE_DUPLICATES available_binary_package_version)
list(REMOVE_DUPLICATES available_binary_package_version_with_platform)
set(${list_of_versions} ${available_binary_package_version} PARENT_SCOPE)
set(${list_of_versions_with_platform} ${available_binary_package_version_with_platform} PARENT_SCOPE)
endfunction(get_Available_Binary_Package_Versions)

### select the version passed as argument in the list of binary versions of a package
function(select_Platform_Binary_For_Version version list_of_bin_with_platform RES_PLATFORM)

foreach(bin IN ITEMS ${list_of_bin_with_platform})
	string (REGEX REPLACE "^${version}/(.*)$" "\\1" RES ${bin})

	if(NOT RES STREQUAL "${bin}") #match
		set(${RES_PLATFORM} ${RES} PARENT_SCOPE)
		return()
	endif()
endforeach()
set(${RES_PLATFORM} PARENT_SCOPE)
endfunction(select_Platform_Binary_For_Version)

### deploying a binary package, if necessary. It means that last version is installed and configured in the workspace.  See: download_And_Install_Binary_Package. Constraints: package binary references must be loaded before.
function(deploy_Binary_Package DEPLOYED package already_installed_versions)
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

		download_And_Install_Binary_Package(INSTALLED ${package} "${RES_VERSION}" "${RES_PLATFORM}")
		if(INSTALLED)
			add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
		else()
			add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "PROBLEM" FALSE) #situation is problematic but we can still overcome it by using sources ... if possible
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
endfunction(deploy_Binary_Package)

### deploying a given binary version package, if necessary. The package version archive is installed and configured in the workspace. See: download_And_Install_Binary_Package.  Constraints: package binary references must be loaded before.
function(deploy_Binary_Package_Version DEPLOYED package VERSION_MIN EXACT already_installed_versions)
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
if(EXACT)
	select_Exact_Version(RES_VERSION ${VERSION_MIN} "${available_versions}")
else()
	select_Best_Version(RES_VERSION ${VERSION_MIN} "${available_versions}")
endif()

if(NOT RES_VERSION)
	if(EXACT)
		message("[PID] INFO : no adequate binary compatible for ${package} version ${VERSION_MIN} found.")
	else()
		message("[PID] INFO : no adequate binary version of package ${package} found with minimum version ${VERSION_MIN}.")
	endif()
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()
set(INSTALLED FALSE)
list(FIND already_installed_versions ${RES_VERSION} INDEX)
if(INDEX EQUAL -1) # selected version not found in versions to exclude
	check_Package_Version_State_In_Current_Process(${package} ${RES_VERSION} RES)
	if(RES STREQUAL "UNKNOWN") # this package version has not been build since beginning of the current process
		select_Platform_Binary_For_Version(${RES_VERSION} "${available_with_platform}" RES_PLATFORM)
		download_And_Install_Binary_Package(INSTALLED ${package} "${RES_VERSION}" "${RES_PLATFORM}")
		if(INSTALLED)
			add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "SUCCESS" FALSE)
		else()
			add_Managed_Package_In_Current_Process(${package} ${RES_VERSION} "PROBLEM" FALSE)
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

endfunction(deploy_Binary_Package_Version)

### get the filename of a binary archive for a given package, version, platform and build mode.  Constraints: package binary references must be loaded before.
function(generate_Binary_Package_Name package version platform mode RES_FILE RES_FOLDER)
get_System_Variables(PLATFORM_STRING PACKAGE_STRING)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(${RES_FILE} "${package}-${version}${TARGET_SUFFIX}-${platform}.tar.gz" PARENT_SCOPE) #this is the archive name generated by PID
set(${RES_FOLDER} "${package}-${version}${TARGET_SUFFIX}-${PACKAGE_STRING}" PARENT_SCOPE)#this is the folder name generated by CPack
endfunction(generate_Binary_Package_Name)

### download the target binary version archive of a package and then intsall it. Constraint: the binary references of the package must be loaded before this call
function(download_And_Install_Binary_Package INSTALLED package version_string platform)

message("[PID] INFO : deploying the binary package ${package} with version ${version_string} for platform ${platform}, please wait ...")
if(ADDITIONNAL_DEBUG_INFO)
	message("[PID] INFO : downloading the binary package ${package} version ${version_string} for platform ${platform}, please wait ...")
endif()

###### downloading the binary package ######
#release code
set(FILE_BINARY "")
set(FOLDER_BINARY "")

generate_Binary_Package_Name(${package} ${version_string} ${platform} Release FILE_BINARY FOLDER_BINARY)
set(download_url ${${package}_REFERENCE_${version_string}_${platform}_URL})
file(DOWNLOAD ${download_url} ${CMAKE_BINARY_DIR}/share/${FILE_BINARY} STATUS res SHOW_PROGRESS TLS_VERIFY OFF)
list(GET res 0 numeric_error)
list(GET res 1 status)
if(NOT numeric_error EQUAL 0)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : problem when downloading binary version ${version_string} of package ${package} (release binaries) from address ${download_url}: ${status}")
	return()
endif()

#debug code
set(FILE_BINARY_DEBUG "")
set(FOLDER_BINARY_DEBUG "")
generate_Binary_Package_Name(${package} ${version_string} ${platform} Debug FILE_BINARY_DEBUG FOLDER_BINARY_DEBUG)
set(download_url_dbg ${${package}_REFERENCE_${version_string}_${platform}_URL_DEBUG})
file(DOWNLOAD ${download_url_dbg} ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG} STATUS res-dbg SHOW_PROGRESS TLS_VERIFY OFF)
list(GET res-dbg 0 numeric_error_dbg)
list(GET res-dbg 1 status_dbg)
if(NOT numeric_error_dbg EQUAL 0)#there is an error
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : problem when downloading binary version ${version_string} of package ${package} (debug binaries) from address ${download_url_dbg} : ${status_dbg}.")
	return()
endif()

######## installing the package ##########
# 1) creating the package root folder
if(NOT EXISTS ${WORKSPACE_DIR}/install/${platform}/${package})
	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${package}
			WORKING_DIRECTORY ${WORKSPACE_DIR}/install/${platform}
			ERROR_QUIET OUTPUT_QUIET)
endif()

# 2) extracting binary archive in a cross platform way
if(ADDITIONNAL_DEBUG_INFO)
	message("[PID] INFO : decompressing the binary package ${package}, please wait ...")
endif()
set(error_res "")
if(ADDITIONNAL_DEBUG_INFO)
	execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY}
          	COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
		ERROR_VARIABLE error_res)
else()
	execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY}
          	COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
		ERROR_VARIABLE error_res OUTPUT_QUIET)
endif()

if (error_res)
	#try again
	if(ADDITIONNAL_DEBUG_INFO)
		execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY}
		  	COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG}
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
			ERROR_VARIABLE error_res)
	else()
		execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY}
		  	COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG}
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
			ERROR_VARIABLE error_res OUTPUT_QUIET)
	endif()
	if (error_res)
		set(${INSTALLED} FALSE PARENT_SCOPE)
		message("[PID] WARNING : cannot extract binary archives ${FILE_BINARY} ${FILE_BINARY_DEBUG} when installing.")
		return()
	endif()
endif()

# 3) copying resulting folders into the install path in a cross platform way
if(ADDITIONNAL_DEBUG_INFO)
	message("[PID] INFO : installing the binary package ${package} (version ${version_string}) into the workspace, please wait ...")
endif()

set(error_res "")
if(ADDITIONNAL_DEBUG_INFO)
	execute_process(
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/${FOLDER_BINARY} ${WORKSPACE_DIR}/install/${platform}/${package}
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/${FOLDER_BINARY_DEBUG} ${WORKSPACE_DIR}/install/${platform}/${package}
)
else()
	execute_process(
	COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/${FOLDER_BINARY} ${WORKSPACE_DIR}/install/${platform}/${package}
        COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/${FOLDER_BINARY_DEBUG} ${WORKSPACE_DIR}/install/${platform}/${package}
 	ERROR_QUIET OUTPUT_QUIET)
endif()


if (NOT EXISTS ${WORKSPACE_DIR}/install/${platform}/${package}/${version_string}/share/Use${package}-${version_string}.cmake)
	#try again
	if(ADDITIONNAL_DEBUG_INFO)
		execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY}
		  	COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG}
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
			ERROR_VARIABLE error_res)
	else()
		execute_process(COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY}
		  	COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/${FILE_BINARY_DEBUG}
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share
			ERROR_VARIABLE error_res OUTPUT_QUIET)
	endif()
	if (NOT EXISTS ${WORKSPACE_DIR}/install/${platform}/${package}/${version_string}/share/Use${package}-${version_string}.cmake)
		set(${INSTALLED} FALSE PARENT_SCOPE)
		message("[PID] WARNING : when installing binary package ${package}, cannot extract version folder from ${FOLDER_BINARY} and ${FOLDER_BINARY_DEBUG}.")
		return()
	endif()
endif()

############ post install configuration of the workspace ############
set(PACKAGE_NAME ${package})
set(PACKAGE_VERSION ${version_string})
set(PLATFORM_NAME ${platform})
include(${WORKSPACE_DIR}/share/cmake/system/Bind_PID_Package.cmake NO_POLICY_SCOPE)
if(NOT ${PACKAGE_NAME}_BINDED_AND_INSTALLED)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message("[PID] WARNING : cannot configure runtime dependencies for installed version ${version_string} of package ${package}.")
	return()
endif()
set(${INSTALLED} TRUE PARENT_SCOPE)
message("[PID] INFO : binary package ${package} (version ${version_string}) has been installed into the workspace.")
endfunction(download_And_Install_Binary_Package)


#############################################################################################
############################### functions for external Packages #############################
#############################################################################################

### resolving the version to use for the external package according to current build constraints. Constraints: package binary references must be loaded before.
function(resolve_Required_External_Package_Version selected_version package)
get_Available_Binary_Package_Versions(${package} available_versions available_with_platform)
if(NOT available_versions)
	set(${selected_version} PARENT_SCOPE)
	message("[PID] ERROR : impossible to find a version of external package ${package} that conforms to current platform constraints.")
	return()
endif()

if(NOT ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX})#no specific version required
	if(${package}_REFERENCES)
		#simply searching to most up to date one in available references
		set(CURRENT_VERSION 0.0.0)
		foreach(ref IN ITEMS ${available_versions})
			if(ref VERSION_GREATER ${CURRENT_VERSION})
				set(CURRENT_VERSION ${ref})
			endif()
		endforeach()
		set(${selected_version} "${CURRENT_VERSION}" PARENT_SCOPE)
		return()
	else()
		set(${selected_version} PARENT_SCOPE)
		message("[PID] ERROR : impossible to find a valid reference to any version of external package ${package}.")
		return()
	endif()

else()#specific version(s) required (common case)
	list(REMOVE_DUPLICATES ${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX})
	#1) testing if a solution exists as regard of "exactness" of versions
	set(CURRENT_EXACT FALSE)
	set(CURRENT_VERSION)
	foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX}})
		if(CURRENT_EXACT)
			if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX}) #impossible to find two different exact versions solution
				set(${selected_version} PARENT_SCOPE)
				return()
			elseif(${version} VERSION_GREATER ${CURRENT_VERSION})#any not exact version that is greater than current exact one makes the solution impossible
				set(${selected_version} PARENT_SCOPE)
				return()
			endif()
		else()
			if(${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_${version}_EXACT${USE_MODE_SUFFIX})
				if(NOT CURRENT_VERSION OR CURRENT_VERSION VERSION_LESS ${version})
					set(CURRENT_EXACT TRUE)
					set(CURRENT_VERSION ${version})
				else()# current version is greater than exact one currently required => impossible
					set(${selected_version} PARENT_SCOPE)
					return()
				endif()

			else()#getting the greater minimal required version
				if(NOT CURRENT_VERSION OR CURRENT_VERSION VERSION_LESS ${version})
					set(CURRENT_VERSION ${version})
				endif()
			endif()

		endif()

	endforeach()
	#2) testing if a solution exists as regard of "compatibility" of versions
	foreach(version IN ITEMS ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_${package}_VERSIONS${USE_MODE_SUFFIX}})
		if(NOT ${version} VERSION_EQUAL ${CURRENT_VERSION})
			if(DEFINED ${package}_REFERENCE_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO
			AND NOT ${CURRENT_VERSION} VERSION_LESS ${package}_REFERENCE_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO) #current version not compatible with the version
				set(${selected_version} PARENT_SCOPE) #there is no solution
				return()
			endif()
		endif()
	endforeach()

	#3) testing if there is a binary package with adequate platform constraints for the current version
	list(FIND available_versions ${CURRENT_VERSION} INDEX)
	if(INDEX EQUAL -1) #a package binary for that version has not been found
		set(${selected_version} PARENT_SCOPE) #there is no solution
		return()
	endif()

endif()

set(${selected_version} "${CURRENT_VERSION}" PARENT_SCOPE)
endfunction(resolve_Required_External_Package_Version)


### function used to install a single external package. It leads to the resolution of the adequate package version and the deployment of that version. See: deploy_External_Package_Version and resolve_Required_External_Package_Version.
function(install_External_Package INSTALL_OK package)

# 0) test if reference of the external package exists in the workspace
set(IS_EXISTING FALSE)
package_Reference_Exists_In_Workspace(IS_EXISTING External${package})
if(NOT IS_EXISTING)
	set(${INSTALL_OK} FALSE PARENT_SCOPE)
	message("[PID] ERROR : unknown external package ${package} : cannot find any reference of this package in the workspace. Cannot install this package.")
	return()
endif()

include(ReferExternal${package} OPTIONAL RESULT_VARIABLE refer_path)
if(${refer_path} STREQUAL NOTFOUND)
	message("[PID] ERROR : reference file not found for external package ${package}!! This is certainly due to a badly referenced package. Please contact the administrator of the external package ${package} !!!")
	return()
endif()

load_Package_Binary_References(REFERENCES_OK ${package}) #getting the references (address of sites) where to download binaries for that package
if(NOT REFERENCES_OK)
	message("[PID] ERROR : cannot load the references to external package binaries ! This is certainly due to a badly referenced package. Please contact the administrator of the external package ${package} !!!")
	return()
endif()

# 1) resolve finally required package version (if any specific version required) (major.minor only, patch is let undefined)
set(SELECTED)
resolve_Required_External_Package_Version(SELECTED ${package})
if(SELECTED) # if there is ONE adequate reference, downloading and installing it
	#2) installing package
	set(PACKAGE_BINARY_DEPLOYED FALSE)
	deploy_External_Package_Version(PACKAGE_BINARY_DEPLOYED ${package} ${SELECTED})
	if(PACKAGE_BINARY_DEPLOYED)
		message("[PID] INFO : external package ${package} (version ${SELECTED}) has been installed.")
		set(${INSTALL_OK} TRUE PARENT_SCOPE)
		return()
	else()
		message("[PID] ERROR : external package ${package} (version ${SELECTED}) cannot be deployed.")
	endif()
else()
	message("[PID] ERROR : impossible to find an adequate version for external package ${package}.")
endif()

set(${INSTALL_OK} FALSE PARENT_SCOPE)
endfunction(install_External_Package)

### function used to install a list of external packages. See : install_External_Package.
function(install_Required_External_Packages list_of_packages_to_install INSTALLED_PACKAGES)
set(successfully_installed "")
set(not_installed "")
foreach(dep_package IN ITEMS ${list_of_packages_to_install}) #while there are still packages to install
	set(INSTALL_OK FALSE)
	install_External_Package(INSTALL_OK ${dep_package})
	if(INSTALL_OK)
		list(APPEND successfully_installed ${dep_package})
	else()
		list(APPEND not_installed ${dep_package})
	endif()
endforeach()
if(successfully_installed)
	set(${INSTALLED_PACKAGES} ${successfully_installed} PARENT_SCOPE)
endif()
if(not_installed)
	message("[PID] ERROR : some of the required external packages cannot be installed : ${not_installed}.")
endif()
endfunction(install_Required_External_Packages)


### deploy means download + install + configure the external package in the workspace so that it can be used by a third party package.
function(deploy_External_Package_Version DEPLOYED package version)
set(available_versions "")
get_Available_Binary_Package_Versions(${package} available_versions available_with_platform)
if(NOT available_versions)
	message("[PID] ERROR : no available binary versions of package ${package}.")
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()
#now getting the best platform for that version
select_Platform_Binary_For_Version(${version} "${available_with_platform}" PLATFORM)
if(NOT PLATFORM)
	message("[PID] ERROR : cannot find the binary version ${version} of package ${package} compatible with current platform.")
	set(${DEPLOYED} FALSE PARENT_SCOPE)
	return()
endif()
check_Package_Version_State_In_Current_Process(${package} ${version} RES)
if(RES STREQUAL "UNKNOWN")
	download_And_Install_External_Package(INSTALLED ${package} ${version} ${PLATFORM})
	if(INSTALLED)
		add_Managed_Package_In_Current_Process(${package} ${version} "SUCCESS" TRUE)
	else()
		add_Managed_Package_In_Current_Process(${package} ${version} "FAIL" TRUE) #for external binary packages the fail is automatic as they cannot be buit from sources
		message("[PID] ERROR : cannot install version ${version} of external package ${package}.")
		set(${DEPLOYED} FALSE PARENT_SCOPE)
		return()
	endif()

	#5) checking for platform constraints
	configure_External_Package(${package} ${version} Debug)
	configure_External_Package(${package} ${version} Release)

elseif(NOT RES STREQUAL "SUCCESS") # this package version has FAILED TO be install during current process
	set(${DEPLOYED} FALSE PARENT_SCOPE)
endif()

set(${DEPLOYED} TRUE PARENT_SCOPE)
endfunction(deploy_External_Package_Version)


### function to get the target external package version and put it in the workspace. Constraint: the reference file for that package must be loaded before. See: deploy_External_Package_Version
function(download_And_Install_External_Package INSTALLED package version platform)
set(${INSTALLED} FALSE PARENT_SCOPE)

###### downloading the binary package ######
message("[PID] INFO : deploying the external package ${package} with version ${version} for platform ${platform}, please wait ...")
if(ADDITIONNAL_DEBUG_INFO)
	message("[PID] INFO : installing external package ${package}, version ${version}...")
endif()

#1) release code
set(FILE_BINARY "")
set(FOLDER_BINARY "")
generate_Binary_Package_Name(${package} ${version} ${platform} Release FILE_BINARY FOLDER_BINARY)
set(download_url ${${package}_REFERENCE_${version}_${platform}_URL})
set(FOLDER_BINARY ${${package}_REFERENCE_${version}_${platform}_FOLDER})
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
	generate_Binary_Package_Name(${package} ${version} ${platform} Debug FILE_BINARY_DEBUG FOLDER_BINARY_DEBUG)
	set(download_url_dbg ${${package}_REFERENCE_${version}_${platform}_URL_DEBUG})
	set(FOLDER_BINARY_DEBUG ${${package}_REFERENCE_${version}_${platform}_FOLDER_DEBUG})
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
# 1) creating the external package root folder and the version folder
if(NOT EXISTS ${WORKSPACE_DIR}/external/${platform}/${package} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/external/${platform}/${package})
	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${package}
			WORKING_DIRECTORY ${WORKSPACE_DIR}/external/${platform}
			ERROR_QUIET OUTPUT_QUIET)
endif()
if(NOT EXISTS ${WORKSPACE_DIR}/external/${platform}/${package}/${version} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/external/${platform}/${package}/${version})
	execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${version}
		WORKING_DIRECTORY ${WORKSPACE_DIR}/external/${platform}/${package}
		ERROR_QUIET OUTPUT_QUIET)
endif()

# 2) extracting binary archive in cross platform way
set(error_res "")
if(ADDITIONNAL_DEBUG_INFO)
	message("[PID] INFO : decompressing the external binary package ${package}, please wait ...")
endif()
if(EXISTS download_url_dbg)
	execute_process(
          	COMMAND ${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/share/debug/${FILE_BINARY_DEBUG}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/share/debug
		ERROR_VARIABLE error_res OUTPUT_QUIET)

	if (error_res)
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
if(EXISTS download_url_dbg)
	execute_process(
		COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/release/${FOLDER_BINARY} ${WORKSPACE_DIR}/external/${platform}/${package}/${version}
          	COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/debug/${FOLDER_BINARY_DEBUG} ${WORKSPACE_DIR}/external/${platform}/${package}/${version}
		ERROR_VARIABLE error_res OUTPUT_QUIET)
else()
	execute_process(
		COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_BINARY_DIR}/share/release/${FOLDER_BINARY} ${WORKSPACE_DIR}/external/${platform}/${package}/${version}/
		ERROR_VARIABLE error_res OUTPUT_QUIET)
endif()

if (error_res)
	set(${INSTALLED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : cannot extract folder from ${FOLDER_BINARY} ${FOLDER_BINARY_DEBUG} to get binary version ${version} of package ${package}.")
	return()
endif()
# 4) removing generated artifacts
if(EXISTS download_url_dbg)
	execute_process(
		COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/share/debug
		COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/share/release
		ERROR_QUIET OUTPUT_QUIET)
else()
	execute_process(
		COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/share/release
		ERROR_QUIET OUTPUT_QUIET)
endif()

set(${INSTALLED} TRUE PARENT_SCOPE)
endfunction(download_And_Install_External_Package)


### configure the external package, after it has been installed. It can lead to the install of OS related packages depending of its system configuration. See: deploy_External_Package_Version.
function(configure_External_Package package version mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(${package}_CURR_DIR ${WORKSPACE_DIR}/external/${platform}/${package}/${version}/share/)
include(${WORKSPACE_DIR}/external/${platform}/${package}/${version}/share/Use${package}-${version}.cmake OPTIONAL RESULT_VARIABLE res)
#using the hand written Use<package>-<version>.cmake file to get adequate version information about plaforms
if(res STREQUAL NOTFOUND)
	# no platform usage file => nothing to do
	return()
endif()
unset(${package}_CURR_DIR)

# checking platforms constraints
set(CONFIGS_TO_CHECK)
if(${package}_PLATFORM_CONFIGURATIONS)
	set(CONFIGS_TO_CHECK ${${package}_PLATFORM_CONFIGURATIONS})#there are configuration constraints in PID v2 style
elseif(${package}_PLATFORM${VAR_SUFFIX}) # this case may be true if the package binary has been release in old PID v1 style
	set(platform ${${package}_PLATFORM})
	set(OLD_PLATFORM_CONFIG ${${package}_PLATFORM_${platform}_CONFIGURATION${VAR_SUFFIX}})
	if(OLD_PLATFORM_CONFIG) #there are required configurations in old style
		set(CONFIGS_TO_CHECK ${OLD_PLATFORM_CONFIG})#there are configuration constraints in PID v1 style
	endif()
endif()

if(CONFIGS_TO_CHECK)#arch and OS are not checked as they are supposed to be already OK
	# 2) checking constraints on configuration
	foreach(config IN ITEMS ${CONFIGS_TO_CHECK})
		if(EXISTS ${WORKSPACE_DIR}/share/cmake/constraints/configurations/${config}/check_${config}.cmake)
			include(${WORKSPACE_DIR}/share/cmake/constraints/configurations/${config}/check_${config}.cmake)	# check the platform constraint and install it if possible
			if(NOT CHECK_${config}_RESULT) #constraints must be satisfied otherwise error
				message(FATAL_ERROR "[PID] CRITICAL ERROR : platform configuration constraint ${config} is not satisfied and cannot be solved automatically. Please contact the administrator of package ${package}.")
				return()
			else()
				message("[PID] INFO : platform configuration ${config} for package ${package} is satisfied.")
			endif()
		else()
			message(FATAL_ERROR "[PID] CRITICAL ERROR : when checking platform configuration constraint ${config}, information for ${config} does not exists that means this constraint is unknown within PID. Please contact the administrator of package ${package}.")
			return()
		endif()
	endforeach()
endif() #otherwise no configuration for this platform is supposed to be necessary

# Manage external package dependencies => need to deploy other external packages
#if(${package}_EXTERNAL_DEPENDENCIES) #the external package has external dependencies
#	foreach(dep_pack IN ITEMS ${${package}_EXTERNAL_DEPENDENCIES}) #recursive call for deployment of dependencies
#		deploy_External_Package_Version(DEPLOYED ${dep_pack} ${${package}_EXTERNAL_DEPENDENCY_${dep_pack}_VERSION})
#	endforeach()
#endif()
endfunction(configure_External_Package)

#############################################################################################
############################### functions for frameworks ####################################
#############################################################################################

### function used to put into workspace the repository of the target framework
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
