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

########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(External_Definition NO_POLICY_SCOPE) #to be able to interpret description of dependencies (external packages)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Version_Management_Functions NO_POLICY_SCOPE)
include(PID_Progress_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Finding_Functions NO_POLICY_SCOPE)
include(PID_Deployment_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
include(PID_Meta_Information_Management_Functions NO_POLICY_SCOPE)
include(PID_Continuous_Integration_Functions NO_POLICY_SCOPE)

###########################################################################
############ description of functions implementing the API ################
###########################################################################

###
function(init_Wrapper_Info_Cache_Variables author institution mail description year license address public_address readme_file)
set(res_string)
foreach(string_el IN ITEMS ${author})
	set(res_string "${res_string}_${string_el}")
endforeach()
set(${PROJECT_NAME}_MAIN_AUTHOR "${res_string}" CACHE INTERNAL "")

set(res_string "")
foreach(string_el IN ITEMS ${institution})
	set(res_string "${res_string}_${string_el}")
endforeach()
set(${PROJECT_NAME}_MAIN_INSTITUTION "${res_string}" CACHE INTERNAL "")
set(${PROJECT_NAME}_CONTACT_MAIL ${mail} CACHE INTERNAL "")
set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_MAIN_AUTHOR}(${${PROJECT_NAME}_MAIN_INSTITUTION})" CACHE INTERNAL "")
set(${PROJECT_NAME}_DESCRIPTION "${description}" CACHE INTERNAL "")
set(${PROJECT_NAME}_YEARS ${year} CACHE INTERNAL "")
set(${PROJECT_NAME}_LICENSE ${license} CACHE INTERNAL "")
set(${PROJECT_NAME}_ADDRESS ${address} CACHE INTERNAL "")
set(${PROJECT_NAME}_PUBLIC_ADDRESS ${public_address} CACHE INTERNAL "")
set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")#categories are reset
set(${PROJECT_NAME}_USER_README_FILE ${readme_file} CACHE INTERNAL "")
endfunction(init_Wrapper_Info_Cache_Variables)

### reconfiguring a wrapper
function(reconfigure_Wrapper_Build)
set(TARGET_BUILD_FOLDER ${${PROJECT_NAME}_ROOT_DIR}/build)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${TARGET_BUILD_FOLDER} ${CMAKE_COMMAND} ..)
endfunction(reconfigure_Wrapper_Build)

### reset whole data from version description to ensure there is no faulty description due to content change
function(reset_Wrapper_Description_Cached_Variables)
if(${PROJECT_NAME}_KNOWN_VERSIONS)
  foreach(version IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSIONS})
		#reset configurations
		if(${PROJECT_NAME}_KNOWN_VERSION_${version}_CONFIGURATIONS)
			foreach(config IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_CONFIGURATIONS})
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_CONFIGURATION_${config} CACHE INTERNAL "")
			endforeach()
		endif()
		set(${PROJECT_NAME}_KNOWN_VERSION_${version}_CONFIGURATIONS CACHE INTERNAL "")
		#reset package dependencies
		if(${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCIES)
			foreach(package IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCIES})
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCY_${package}_VERSIONS CACHE INTERNAL "")
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCY_${package}_VERSIONS_EXACT CACHE INTERNAL "")
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCY_${package}_VERSION_USED_FOR_BUILD CACHE INTERNAL "")
			endforeach()
		endif()
		set(${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCIES CACHE INTERNAL "")

		#reset build related variables for this version
		set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_LINKS CACHE INTERNAL "")
		set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_INCLUDES CACHE INTERNAL "")
		set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_DEFINITIONS CACHE INTERNAL "")
		set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_COMPILER_OPTIONS CACHE INTERNAL "")
		set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_C_STANDARD CACHE INTERNAL "")
		set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_CXX_STANDARD CACHE INTERNAL "")

		#reset components
		if(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENTS)
			foreach(component IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENTS})

				#reset information local to the component
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_SHARED_LINKS CACHE INTERNAL "")
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_STATIC_LINKS CACHE INTERNAL "")
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INCLUDES CACHE INTERNAL "")
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEFINITIONS CACHE INTERNAL "")
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_OPTIONS CACHE INTERNAL "")
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_C_STANDARD CACHE INTERNAL "")
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_CXX_STANDARD CACHE INTERNAL "")
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_RUNTIME_RESOURCES CACHE INTERNAL "")

				#reset information related to internal dependencies
				if(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCIES)
					foreach(dependency IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCIES})
						set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCY_${dependency}_DEFINITIONS CACHE INTERNAL "")
						set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCY_${dependency}_EXPORTED CACHE INTERNAL "")
					endforeach()
				endif()
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCIES CACHE INTERNAL "")

				#reset information related to other external dependencies
				if(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCIES)
					foreach(package IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCIES})
						#reset component level dependencies first
						if(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package})
							foreach(dependency IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}})
								set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_${dependency}_DEFINITIONS CACHE INTERNAL "")
								set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_${dependency}_EXPORTED CACHE INTERNAL "")
							endforeach()
						endif()
						set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package} CACHE INTERNAL "")

						#then reset direct package level dependencies of the component
						set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_INCLUDES CACHE INTERNAL "")
						set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_SHARED CACHE INTERNAL "")
						set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_STATIC CACHE INTERNAL "")
						set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_DEFINITIONS CACHE INTERNAL "")
						set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_OPTIONS CACHE INTERNAL "")
						set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_C_STANDARD CACHE INTERNAL "")
						set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_CXX_STANDARD CACHE INTERNAL "")
						set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_RUNTIME_RESOURCES CACHE INTERNAL "")
					endforeach()
				endif()
				set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCIES CACHE INTERNAL "")

			endforeach()
		endif()
		set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENTS CACHE INTERNAL "")

		#reset current version general information
		set(${PROJECT_NAME}_KNOWN_VERSION_${version}_SONAME CACHE INTERNAL "")
		set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPATIBLE_WITH CACHE INTERNAL "")
		set(${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPLOY_SCRIPT CACHE INTERNAL "")
		set(${PROJECT_NAME}_KNOWN_VERSION_${version}_POST_INSTALL_SCRIPT CACHE INTERNAL "")
	endforeach()
set(${PROJECT_NAME}_KNOWN_VERSIONS CACHE INTERNAL "")
endif()
endfunction(reset_Wrapper_Description_Cached_Variables)

###
macro(declare_Wrapper author institution mail year license address public_address description readme_file)

set(${PROJECT_NAME}_ROOT_DIR ${WORKSPACE_DIR}/wrappers/${PROJECT_NAME} CACHE INTERNAL "")
file(RELATIVE_PATH DIR_NAME ${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR})

#############################################################
############ Managing path into workspace ###################
#############################################################
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake) # adding the cmake scripts files from the package
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/find) # using common find modules of the workspace
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references) # using common find modules of the workspace
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/constraints/platforms) # using platform check modules

#############################################################
############ Managing current platform ######################
#############################################################

if(CURRENT_PLATFORM AND NOT CURRENT_PLATFORM STREQUAL "")# a current platform is already defined
  #if any of the following variable changed, the cache of the CMake project needs to be regenerated from scratch
  set(TEMP_PLATFORM ${CURRENT_PLATFORM})
  set(TEMP_C_COMPILER ${CMAKE_C_COMPILER})
  set(TEMP_CXX_COMPILER ${CMAKE_CXX_COMPILER})
  set(TEMP_CMAKE_LINKER ${CMAKE_LINKER})
  set(TEMP_CMAKE_RANLIB ${CMAKE_RANLIB})
  set(TEMP_CMAKE_CXX_COMPILER_ID ${CMAKE_CXX_COMPILER_ID})
  set(TEMP_CMAKE_CXX_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})
endif()

load_Current_Platform() #loading the current platform configuration

if(TEMP_PLATFORM) #check if any change occurred
  if( (NOT TEMP_PLATFORM STREQUAL CURRENT_PLATFORM) #the current platform has changed to we need to regenerate
      OR (NOT TEMP_C_COMPILER STREQUAL CMAKE_C_COMPILER)
      OR (NOT TEMP_CXX_COMPILER STREQUAL CMAKE_CXX_COMPILER)
      OR (NOT TEMP_CMAKE_LINKER STREQUAL CMAKE_LINKER)
      OR (NOT TEMP_CMAKE_RANLIB STREQUAL CMAKE_RANLIB)
      OR (NOT TEMP_CMAKE_CXX_COMPILER_ID STREQUAL CMAKE_CXX_COMPILER_ID)
      OR (NOT TEMP_CMAKE_CXX_COMPILER_VERSION STREQUAL CMAKE_CXX_COMPILER_VERSION)
    )
    message("[PID] INFO : cleaning the build folder after major environment change")
    hard_Clean_Wrapper(${PROJECT_NAME})
		reconfigure_Wrapper_Build()
  endif()
endif()

set(CMAKE_BUILD_TYPE Release CACHE INTERNAL "")
#############################################################
############ Managing build process #########################
#############################################################

if(DIR_NAME STREQUAL "build")

  #################################################
  ######## create global targets ##################
  #################################################
	add_custom_target(build
    ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
           -DTARGET_EXTERNAL_PACKAGE=${PROJECT_NAME}
           -DTARGET_EXTERNAL_VERSION=$(version)
           -DDO_NOT_EXECUTE_SCRIPT=$(skip_script)
					 -P ${WORKSPACE_DIR}/share/cmake/system/commands/Build_PID_Wrapper.cmake
    COMMENT "[PID] Building external package ${PROJECT_NAME} for platform ${CURRENT_PLATFORM} using environment ${CURRENT_ENVIRONMENT} ..."
    VERBATIM
  )
  # reference file generation target
  add_custom_target(referencing
    COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/share/ReferExternal${PROJECT_NAME}.cmake ${WORKSPACE_DIR}/share/cmake/references
  	COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake ${WORKSPACE_DIR}/share/cmake/find
  	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "[PID] installing references to the wrapped external package into the workspace..."
  	VERBATIM
  )

  #################################################
  ######## Initializing cache variables ###########
  #################################################
  reset_Wrapper_Description_Cached_Variables()
	reset_Documentation_Info()
	reset_CI_Variables()
	reset_Packages_Finding_Variables()
  init_PID_Version_Variable()
  init_Meta_Info_Cache_Variables("${author}" "${institution}" "${mail}" "${description}" "${year}" "${license}" "${address}" "${public_address}" "${readme_file}")
	begin_Progress(${PROJECT_NAME} GLOBAL_PROGRESS_VAR) #managing the build from a global point of view
else()
  message("[PID] ERROR : please run cmake in the build folder of the wrapper ${PROJECT_NAME}.")
  return()
endif()
endmacro(declare_Wrapper)

include(CMakeDependentOption)

macro(declare_Wrapper_Global_Cache_Options)
option(ADDITIONNAL_DEBUG_INFO "Getting more info on debug mode or more PID messages (hidden by default)" OFF)
endmacro(declare_Wrapper_Global_Cache_Options)

###
function(define_Wrapped_Project authors_references licenses original_project_url)
set(${PROJECT_NAME}_WRAPPER_ORIGINAL_PROJECT_AUTHORS ${authors_references} CACHE INTERNAL "")
set(${PROJECT_NAME}_WRAPPER_ORIGINAL_PROJECT_LICENSES ${licenses} CACHE INTERNAL "")
set(${PROJECT_NAME}_WRAPPER_ORIGINAL_PROJECT_SITE ${original_project_url} CACHE INTERNAL "")
endfunction(define_Wrapped_Project)


### generate the reference file used to retrieve packages
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
file(APPEND ${file} "set(${PROJECT_NAME}_PID_WRAPPER_SITE_INTRODUCTION ${${PROJECT_NAME}_SITE_INTRODUCTION} CACHE INTERNAL \"\")\n")

set(res_string "")
foreach(auth IN ITEMS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS})
	list(APPEND res_string ${auth})
endforeach()
set(printed_authors "${res_string}")
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
endfunction(generate_Wrapper_Reference_File)


### Get the root address of the wrapper page (either if it belongs to a framework or has its own lone static site)
function(get_Wrapper_Site_Address SITE_ADDRESS wrapper)
set(${SITE_ADDRESS} PARENT_SCOPE)
if(${wrapper}_FRAMEWORK) #package belongs to a framework
	if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferFramework${${wrapper}_FRAMEWORK}.cmake)
		include(${WORKSPACE_DIR}/share/cmake/references/ReferFramework${${wrapper}_FRAMEWORK}.cmake)
		set(${SITE_ADDRESS} ${${${wrapper}_FRAMEWORK}_FRAMEWORK_SITE}/packages/${wrapper} PARENT_SCOPE)
	endif()
elseif(${wrapper}_SITE_GIT_ADDRESS AND ${wrapper}_SITE_ROOT_PAGE)
	set(${SITE_ADDRESS} ${${wrapper}_SITE_ROOT_PAGE} PARENT_SCOPE)
endif()
endfunction(get_Wrapper_Site_Address)

###
function(generate_Wrapper_Readme_Files)
set(README_CONFIG_FILE ${WORKSPACE_DIR}/share/patterns/wrappers/README.md.in)
## introduction (more detailed description, if any)
get_Wrapper_Site_Address(ADDRESS ${PROJECT_NAME})
if(NOT ADDRESS)#no site description has been provided nor framework reference
	# intro
	set(README_OVERVIEW "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided by site use the short one
	# no reference to site page
	set(WRAPPER_SITE_REF_IN_README "")

	# simplified install section
	set(INSTALL_USE_IN_README "The procedures for installing the ${PROJECT_NAME} wrapper and for using its components is based on the [PID](http://pid.lirmm.net/pid-framework/pages/install.html) build and deployment system called PID. Just follow and read the links to understand how to install, use and call its API and/or applications.")
else()
	# intro
	generate_Formatted_String("${${PROJECT_NAME}_SITE_INTRODUCTION}" RES_INTRO)
	if("${RES_INTRO}" STREQUAL "")
		set(README_OVERVIEW "${${PROJECT_NAME}_DESCRIPTION}") #if no detailed description provided by site description use the short one
	else()
		set(README_OVERVIEW "${RES_INTRO}") #otherwise use detailed one specific for site
	endif()

	# install procedure
	set(INSTALL_USE_IN_README "The procedures for installing the ${PROJECT_NAME} wrapper and for using its components is available in this [site][package_site]. It is based on a CMake based build and deployment system called [PID](http://pid.lirmm.net/pid-framework/pages/install.html). Just follow and read the links to understand how to install, use and call its API and/or applications.")

	# reference to site page
	set(WRAPPER_SITE_REF_IN_README "[package_site]: ${ADDRESS} \"${PROJECT_NAME} wrapper\"
")
endif()

if(${PROJECT_NAME}_LICENSE)
	set(WRAPPER_LICENSE_FOR_README "The license that applies to the PID wrapper content (Cmake files mostly) is **${${PROJECT_NAME}_LICENSE}**. Please look at the license.txt file at the root of this repository. The content generated by the wrapper being based on third party code it is subject to the licenses that apply for the ${PROJECT_NAME} project ")
else()
	set(WRAPPER_LICENSE_FOR_README "The wrapper has no license defined yet.")
endif()

set(README_USER_CONTENT "")
if(${PROJECT_NAME}_USER_README_FILE AND EXISTS ${CMAKE_SOURCE_DIR}/share/${${PROJECT_NAME}_USER_README_FILE})
	file(READ ${CMAKE_SOURCE_DIR}/share/${${PROJECT_NAME}_USER_README_FILE} CONTENT_OF_README)
	set(README_USER_CONTENT "${CONTENT_OF_README}")
endif()

set(README_AUTHORS_LIST "")
foreach(author IN ITEMS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS})
	generate_Full_Author_String(${author} STRING_TO_APPEND)
	set(README_AUTHORS_LIST "${README_AUTHORS_LIST}\n+ ${STRING_TO_APPEND}")
endforeach()

get_Formatted_Package_Contact_String(${PROJECT_NAME} RES_STRING)
set(README_CONTACT_AUTHOR "${RES_STRING}")

configure_file(${README_CONFIG_FILE} ${CMAKE_SOURCE_DIR}/README.md @ONLY)#put the readme in the source dir

endfunction(generate_Wrapper_Readme_Files)

###
function(generate_Wrapper_License_File)
if(	DEFINED ${PROJECT_NAME}_LICENSE
	AND NOT ${${PROJECT_NAME}_LICENSE} STREQUAL "")

	find_file(LICENSE_IN
			"License${${PROJECT_NAME}_LICENSE}.cmake"
			PATH "${WORKSPACE_DIR}/share/cmake/licenses"
			NO_DEFAULT_PATH
		)
	if(LICENSE_IN STREQUAL LICENSE_IN-NOTFOUND)
		message("[PID] WARNING : license configuration file for ${${PROJECT_NAME}_LICENSE} not found in workspace, license file will not be generated")
	else()

		#prepare license generation
		set(${PROJECT_NAME}_FOR_LICENSE "${PROJECT_NAME} PID Wrapper")
		set(${PROJECT_NAME}_DESCRIPTION_FOR_LICENSE ${${PROJECT_NAME}_DESCRIPTION})
		set(${PROJECT_NAME}_YEARS_FOR_LICENSE ${${PROJECT_NAME}_YEARS})
		foreach(author IN ITEMS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS})
			generate_Full_Author_String(${author} STRING_TO_APPEND)
			set(${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE "${${PROJECT_NAME}_AUTHORS_LIST_FOR_LICENSE} ${STRING_TO_APPEND}")
		endforeach()

		include(${WORKSPACE_DIR}/share/cmake/licenses/License${${PROJECT_NAME}_LICENSE}.cmake)
		file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
	endif()
endif()
endfunction(generate_Wrapper_License_File)

function(check_External_Version_Compatibility IS_COMPATIBLE ref_version version_to_check)
if(version_to_check VERSION_GREATER ref_version)#the version to check is greater to the reference version
	# so we need to check the compatibility constraints of that version => recursive call
	check_External_Version_Compatibility(IS_RECURSIVE_COMPATIBLE ${ref_version} ${${PROJECT_NAME}_${version_to_check}_COMPATIBLE_WITH})
	set(${IS_COMPATIBLE} ${IS_RECURSIVE_COMPATIBLE} PARENT_SCOPE)
else()#the version to check is compatible as it target a version lower or equal to the reference version
	set(${IS_COMPATIBLE} TRUE PARENT_SCOPE)
endif()
endfunction(check_External_Version_Compatibility)

###
function(generate_Wrapper_Find_File)
	set(FIND_FILE_KNOWN_VERSIONS ${${PROJECT_NAME}_KNOWN_VERSIONS})
	set(FIND_FILE_VERSIONS_COMPATIBLITY)
	if(${PROJECT_NAME}_KNOWN_VERSIONS)
		# first step verifying that at least a version defines its compatiblity
		set(COMPATIBLE_VERSION_FOUND FALSE)
		foreach(version IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSIONS} )
			if(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPATIBLE_WITH)
				set(COMPATIBLE_VERSION_FOUND TRUE)
				break()
			endif()
		endforeach()
		# second step defines version compatibility at fine grain only if needed
		if(COMPATIBLE_VERSION_FOUND)
			foreach(version IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSIONS})
				set(FIRST_INCOMPATIBLE_VERSION)
				set(COMPATIBLE_VERSION_FOUND FALSE)
				foreach(other_version IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSIONS})
					if(other_version VERSION_GREATER version)#the version is greater than the currenlty managed one
						if(${PROJECT_NAME}_KNOWN_VERSION_${other_version}_COMPATIBLE_WITH)
							check_External_Version_Compatibility(IS_COMPATIBLE ${version} ${${PROJECT_NAME}_KNOWN_VERSION_${other_version}_COMPATIBLE_WITH})
							if(NOT IS_COMPATIBLE)#not compatible
								if(NOT FIRST_INCOMPATIBLE_VERSION)
									set(FIRST_INCOMPATIBLE_VERSION ${${PROJECT_NAME}_KNOWN_VERSION_${other_version}_COMPATIBLE_WITH}) #memorize the lower incompatible version with ${version}
								elseif(FIRST_INCOMPATIBLE_VERSION VERSION_GREATER ${${PROJECT_NAME}_KNOWN_VERSION_${other_version}_COMPATIBLE_WITH})
									set(FIRST_INCOMPATIBLE_VERSION ${${PROJECT_NAME}_KNOWN_VERSION_${other_version}_COMPATIBLE_WITH}) #memorize the lower incompatible version with ${version}
								endif()
							else()
								set(COMPATIBLE_VERSION_FOUND TRUE) #at least a compatible version has been found
							endif()
						else()#this other version is compatible with nothing
							if(NOT FIRST_INCOMPATIBLE_VERSION)
								set(FIRST_INCOMPATIBLE_VERSION ${other_version}) #memorize the lower incompatible version with ${version}
							elseif(FIRST_INCOMPATIBLE_VERSION VERSION_GREATER ${other_version})
								set(FIRST_INCOMPATIBLE_VERSION ${other_version}) #memorize the lower incompatible version with ${version}
							endif()
						endif()
					endif()
				endforeach()
				if(FIRST_INCOMPATIBLE_VERSION)#if there is a known incompatible version
					set(FIND_FILE_VERSIONS_COMPATIBLITY "${FIND_FILE_VERSIONS_COMPATIBLITY}\nset(${PROJECT_NAME}_PID_KNOWN_VERSION_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO ${FIRST_INCOMPATIBLE_VERSION})")
			  elseif(COMPATIBLE_VERSION_FOUND)#at least one compatible version has been found but no incompatible versions defined
					#we need to say that version are all compatible by specifying an "infinite version"
					set(FIND_FILE_VERSIONS_COMPATIBLITY "${FIND_FILE_VERSIONS_COMPATIBLITY}\nset(${PROJECT_NAME}_PID_KNOWN_VERSION_${version}_GREATER_VERSIONS_COMPATIBLE_UP_TO 100000.100000.100000)")
				endif()
			endforeach()
		endif()
	endif()
	# generating/installing the generic cmake find file for the package
	configure_file(${WORKSPACE_DIR}/share/patterns/wrappers/FindExternalPackage.cmake.in ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake @ONLY)
	install(FILES ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake DESTINATION ${WORKSPACE_DIR}/share/cmake/find) #install in the worskpace cmake directory which contains cmake find modules
endfunction(generate_Wrapper_Find_File)

###
function(generate_Wrapper_Build_File path_to_file)
file(WRITE ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSIONS ${${PROJECT_NAME}_KNOWN_VERSIONS} CACHE INTERNAL \"\")\n")
if(${PROJECT_NAME}_KNOWN_VERSIONS)
foreach(version IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSIONS})
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPLOY_SCRIPT ${${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPLOY_SCRIPT} CACHE INTERNAL \"\")\n")
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_POST_INSTALL_SCRIPT ${${PROJECT_NAME}_KNOWN_VERSION_${version}_POST_INSTALL_SCRIPT} CACHE INTERNAL \"\")\n")
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPATIBLE_WITH ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPATIBLE_WITH} CACHE INTERNAL \"\")\n")
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_SONAME ${${PROJECT_NAME}_KNOWN_VERSION_${version}_SONAME} CACHE INTERNAL \"\")\n")

	#manage platform configuration description
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_CONFIGURATIONS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_CONFIGURATIONS} CACHE INTERNAL \"\")\n")
	if(${PROJECT_NAME}_KNOWN_VERSION_${version}_CONFIGURATIONS)
		foreach(config IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_CONFIGURATIONS})
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_CONFIGURATION_${config} ${${PROJECT_NAME}_KNOWN_VERSION_${version}_CONFIGURATION_${config}} CACHE INTERNAL \"\")\n")
		endforeach()
	endif()

	#manage package dependencies
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCIES ${${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCIES} CACHE INTERNAL \"\")\n")
	if(${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCIES)
		foreach(package IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCIES})
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCY_${package}_VERSIONS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCY_${package}_VERSIONS} CACHE INTERNAL \"\")\n")
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCY_${package}_VERSIONS_EXACT ${${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCY_${package}_VERSIONS_EXACT} CACHE INTERNAL \"\")\n")
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCY_${package}_VERSION_USED_FOR_BUILD ${${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPENDENCY_${package}_VERSION_USED_FOR_BUILD} CACHE INTERNAL \"\")\n")
		endforeach()
	endif()

	#manage build flags coming from dependencies (includes, links, flags)
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_LINKS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_LINKS} CACHE INTERNAL \"\")\n")
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_INCLUDES ${${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_INCLUDES} CACHE INTERNAL \"\")\n")
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_DEFINITIONS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_DEFINITIONS} CACHE INTERNAL \"\")\n")
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_COMPILER_OPTIONS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_COMPILER_OPTIONS} CACHE INTERNAL \"\")\n")
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_C_STANDARD ${${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_C_STANDARD} CACHE INTERNAL \"\")\n")
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_CXX_STANDARD ${${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_CXX_STANDARD} CACHE INTERNAL \"\")\n")


	#manage components description
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENTS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENTS} CACHE INTERNAL \"\")\n")
	if(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENTS)
		foreach(component IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENTS})
			#manage information local to the component
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_SHARED_LINKS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_SHARED_LINKS} CACHE INTERNAL \"\")\n")
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_STATIC_LINKS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_STATIC_LINKS} CACHE INTERNAL \"\")\n")
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INCLUDES ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INCLUDES} CACHE INTERNAL \"\")\n")
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEFINITIONS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEFINITIONS} CACHE INTERNAL \"\")\n")
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_OPTIONS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_OPTIONS} CACHE INTERNAL \"\")\n")
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_C_STANDARD ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_C_STANDARD} CACHE INTERNAL \"\")\n")
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_CXX_STANDARD ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_CXX_STANDARD} CACHE INTERNAL \"\")\n")
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_RUNTIME_RESOURCES ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_RUNTIME_RESOURCES} CACHE INTERNAL \"\")\n")

			#manage information related to internal dependencies
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCIES ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCIES} CACHE INTERNAL \"\")\n")
			if(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCIES)
				foreach(dependency IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCIES})
					file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCY_${dependency}_DEFINITIONS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCY_${dependency}_DEFINITIONS} CACHE INTERNAL \"\")\n")
					file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCY_${dependency}_EXPORTED ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCY_${dependency}_EXPORTED} CACHE INTERNAL \"\")\n")
				endforeach()
			endif()

			#manage information related to other external dependencies
			file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCIES ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCIES} CACHE INTERNAL \"\")\n")
			if(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCIES)
				foreach(package IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCIES})
					#reset component level dependencies first
					file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package} ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}} CACHE INTERNAL \"\")\n")
					if(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package})
						foreach(dependency IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}})
							file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_${dependency}_DEFINITIONS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_${dependency}_DEFINITIONS} CACHE INTERNAL \"\")\n")
							file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_${dependency}_EXPORTED ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_${dependency}_EXPORTED} CACHE INTERNAL \"\")\n")
						endforeach()
					endif()

					#then reset direct package level dependencies of the component
					file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_INCLUDES ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_INCLUDES} CACHE INTERNAL \"\")\n")
					file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_SHARED ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_SHARED} CACHE INTERNAL \"\")\n")
					file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_STATIC ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_STATIC} CACHE INTERNAL \"\")\n")
					file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_DEFINITIONS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_DEFINITIONS} CACHE INTERNAL \"\")\n")
					file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_OPTIONS ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_OPTIONS} CACHE INTERNAL \"\")\n")
					file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_C_STANDARD ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_C_STANDARD} CACHE INTERNAL \"\")\n")
					file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_CXX_STANDARD ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_CXX_STANDARD} CACHE INTERNAL \"\")\n")
					file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_RUNTIME_RESOURCES ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_RUNTIME_RESOURCES} CACHE INTERNAL \"\")\n")
				endforeach()
			endif()
		endforeach()
	endif()

endforeach()
endif()
endfunction(generate_Wrapper_Build_File)

### deduce the options than can be used when building an external package that depends on the target package
# based on the description provided by external package use file
# FOR LINKS: path to links folders or direct link options
# !! remove the -l option so that we can use it even with projects that do not use direct compiler options like those using cmake)
# !! do not remove the -l if no absolute path can be deduced
# !! resolve the path for those that can be translated into absolute path
# FOR INCLUDES: only the list of path to include folders
# !! remove the -I option so that we can use it even with projects that do not use direct compiler options like those using cmake)
# !! systematically translated into absolute path
# FOR DEFINITIONS:  only the list of definitions used to compile the project version
# !! remove the -D option so that we can use it even with projects that do not use direct compiler options like those using cmake)
# FOR COMPILER OPTIONS: return the list of other compile options used to compile the project version
# !! option are kept "as is" EXCEPT those setting the C and CXX languages standards to use to build the package
function(agregate_All_Build_Info_For_Package package mode RES_INCS RES_DEFS RES_OPTS RES_STD_C REST_STD_CXX RES_LINKS)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(all_links)
set(all_definitions)
set(all_includes)
set(all_compiler_options)
set(c_std 90)
set(cxx_std 98)
#dealing with configurations
foreach(config IN ITEMS ${${package}_CONFIGURATIONS})
	list(APPEND all_links ${${package}_LINK_OPTIONS})
	list(APPEND all_definitions ${${package}_DEFINITIONS})
	list(APPEND all_includes ${${package}_INCLUDE_DIRS})
	list(APPEND all_compiler_options ${${package}_COMPILE_OPTIONS})
endforeach()

#there is a description of package content
# simply append the options related to this description (rutal but quite simple approach)
if(${package}_COMPONENTS)
	foreach(comp IN ITEMS ${${package}_COMPONENTS}${VAR_SUFFIX})
		list(APPEND all_links ${${package}_${comp}_STATIC_LINKS${VAR_SUFFIX}} ${${package}_${comp}_SHARED_LINKS${VAR_SUFFIX}})
		list(APPEND all_definitions ${${package}_${comp}_DEFS${VAR_SUFFIX}})
		list(APPEND all_includes ${${package}_${comp}_INC_DIRS${VAR_SUFFIX}})
		list(APPEND all_compiler_options ${${package}_${comp}_OPTS${VAR_SUFFIX}})
		if(RES_STD_C)#always take the greater standard number
			is_C_Version_Less(IS_LESS ${c_std} ${${package}_${comp}_C_STANDARD${VAR_SUFFIX}})
			set(c_std ${${package}_${comp}_C_STANDARD${VAR_SUFFIX}})
		endif()
		if(REST_STD_CXX)#always take the greater standard number
			is_CXX_Version_Less(IS_LESS ${cxx_std} ${${package}_${comp}_CXX_STANDARD${VAR_SUFFIX}})
			set(cxx_std ${${package}_${comp}_CXX_STANDARD${VAR_SUFFIX}})
		endif()
	endforeach()
endif()

#dealing with dependent package (do the recursion)
foreach(dep_package IN ITEMS ${${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}})
	agregate_All_Build_Info_For_Package(${package} ${mode}
	RES_INCS RES_DEFS RES_OPTS STD_C STD_CXX RES_LINKS)
	list(APPEND all_links ${RES_LINKS})
	list(APPEND all_definitions ${RES_DEFS})
	list(APPEND all_includes ${RES_INCS})
	list(APPEND all_compiler_options ${RES_OPTS})
	if(STD_C)
		is_C_Version_Less(IS_LESS ${c_std} ${STD_C})
		set(c_std ${STD_C})
	endif()
	if(STD_CXX)
		is_CXX_Version_Less(IS_LESS ${cxx_std} ${STD_CXX})
		set(cxx_std ${STD_CXX})
	endif()
endforeach()
remove_Duplicates_From_List(all_includes)
remove_Duplicates_From_List(all_definitions)
remove_Duplicates_From_List(all_compiler_options)
remove_Duplicates_From_List(all_links)
set(${RES_INCS} ${all_includes} CACHE INTERNAL "")
set(${RES_DEFS} ${all_definitions} CACHE INTERNAL "")
set(${RES_OPTS} ${all_compiler_options} CACHE INTERNAL "")
set(${RES_STD_C} ${c_std} CACHE INTERNAL "")
set(${RES_STD_CXX} ${cxx_std} CACHE INTERNAL "")
set(${RES_LINKS} ${all_links} CACHE INTERNAL "")
endfunction(agregate_All_Build_Info_For_Package)


### set the the list of compilation option used to build the external package
function(agregate_All_Build_Info version)
	set(prefix ${PROJECT_NAME}_KNOWN_VERSION_${version})#just for a simpler description
	set(all_links)
	set(all_definitions)
	set(all_includes)
	set(all_compiler_options)
	set(c_std 90) #basic C language version
	set(cxx_std 98) #basic CXX language version
	#dealing with configurations
	foreach(config IN ITEMS ${${prefix}_CONFIGURATIONS})
		list(APPEND all_links ${${config}_LINK_OPTIONS})
		list(APPEND all_definitions ${${config}_DEFINITIONS})
		list(APPEND all_includes ${${config}_INCLUDE_DIRS})
		list(APPEND all_compiler_options ${${config}_COMPILE_OPTIONS})
	endforeach()

	#dealing with direct package dependencies
	foreach(package IN ITEMS ${${prefix}_DEPENDENCIES})
		#agregate all information about the dependency package (no need to get per component requirements as external projects are built all at once)
		agregate_All_Build_Info_For_Package(${package} Release
		RES_INCS RES_DEFS RES_OPTS RES_STD_C REST_STD_CXX RES_LINKS)
		list(APPEND all_links ${RES_LINKS})
		list(APPEND all_definitions ${RES_DEFS})
		list(APPEND all_includes ${RES_INCS})
		list(APPEND all_compiler_options ${RES_OPTS})
		if(RES_STD_C)
			is_C_Version_Less(IS_LESS ${c_std} ${RES_STD_C})
			set(c_std ${RES_STD_C})
		endif()
		if(REST_STD_CXX)
			is_CXX_Version_Less(IS_LESS ${cxx_std} ${REST_STD_CXX})
			set(cxx_std ${REST_STD_CXX})
		endif()
	endforeach()
	remove_Duplicates_From_List(all_includes)
	remove_Duplicates_From_List(all_definitions)
	remove_Duplicates_From_List(all_compiler_options)
	remove_Duplicates_From_List(all_links)

	#now resolving path when necessary
	resolve_External_Libs_Path(COMPLETE_LINKS_PATH "${all_links}" Release)
	resolve_External_Includes_Path(COMPLETE_INCS_PATH "${all_includes}" Release)

	#set the cached variable accordingly
	set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_INCLUDES ${COMPLETE_INCS_PATH} CACHE INTERNAL "")
	set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_DEFINITIONS ${all_definitions} CACHE INTERNAL "")
	set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_COMPILER_OPTIONS ${all_compiler_options} CACHE INTERNAL "")
	set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_C_STANDARD ${c_std} CACHE INTERNAL "")
	set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_CXX_STANDARD ${cxx_std} CACHE INTERNAL "")
	set(${PROJECT_NAME}_KNOWN_VERSION_${version}_BUILD_LINKS ${COMPLETE_LINKS_PATH} CACHE INTERNAL "")
endfunction(agregate_All_Build_Info)

###
function(configure_Wrapper_Build_Variables)
if(${PROJECT_NAME}_KNOWN_VERSIONS)
	foreach(version IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSIONS})
		agregate_All_Build_Info(${version})
	endforeach()
endif()
endfunction(configure_Wrapper_Build_Variables)

###
macro(build_Wrapped_Project)

#####################################################################################################################
######## recursion into version subdirectories to describe the content of the external package ######################
#####################################################################################################################

list_Version_Subdirectories(VERSIONS_DIRS ${CMAKE_SOURCE_DIR}/src)
if(VERSIONS_DIRS)
	foreach(version IN ITEMS ${VERSIONS_DIRS})
	 	add_subdirectory(src/${version})
		################################################################################
		##### resolve dependencies after full package description of any version #######
		################################################################################
		# from here only direct dependencies have been satisfied
		set(INSTALL_REQUIRED FALSE)
		need_Install_External_Packages(INSTALL_REQUIRED)
		if(INSTALL_REQUIRED)# if there are packages to install it means that there are some unresolved required dependencies
			set(INSTALLED_PACKAGES)
			set(NOT_INSTALLED)
			install_Required_External_Packages("${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES}" INSTALLED_PACKAGES NOT_INSTALLED)
			if(NOT_INSTALLED)
				message(FATAL_ERROR "[PID] CRITICAL ERROR when building ${PROJECT_NAME}, there are some unresolved required external package dependencies for version ${CURRENT_MANAGED_VERSION}: ${NOT_INSTALLED}.")
				return()
			endif()
			foreach(a_dep IN ITEMS ${INSTALLED_PACKAGES})#do the recursion on installed external packages
				#perform a new refind to be sure that all direct dependencies are well configured
				resolve_External_Package_Dependency(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION} ${a_dep} ${CMAKE_BUILD_TYPE})
			endforeach()
		endif()
		#resolving external dependencies for project external dependencies (recursion but only with binaries)
		#need to do this here has
		if(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_EXTERNAL_DEPENDENCIES)
			# 1) resolving dependencies of required external packages versions (different versions can be required at the same time)
			# we get the set of all packages undirectly required
			foreach(dep_pack IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_EXTERNAL_DEPENDENCIES})
				resolve_Package_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE})
			endforeach()
		endif()
		reset_To_Install_External_Packages()#reset "to install" depenencies for next version of the package
	endforeach()
endif()

################################################################################
######## generating CMake configuration files used by PID ######################
################################################################################
### configure the project in order to get the complete configruation data required to build versions (includes, flags, links)
configure_Wrapper_Build_Variables()
generate_Wrapper_Build_File(${CMAKE_BINARY_DIR}/Build${PROJECT_NAME}.cmake)
generate_Wrapper_Reference_File(${CMAKE_BINARY_DIR}/share/ReferExternal${PROJECT_NAME}.cmake)
generate_Wrapper_Readme_Files() # generating and putting into source directory the readme file used by gitlab
generate_Wrapper_License_File() # generating and putting into source directory the file containing license info about the package
generate_Wrapper_Find_File() # generating/installing the generic cmake find file for the package
# TODO generate CI + documentation files

################################################################################
######## create global targets from entire project description #################
################################################################################
if(${PROJECT_NAME}_SITE_GIT_ADDRESS) #the publication of the static site is done within a lone static site

	add_custom_target(site
		COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DTARGET_VERSION=${${PROJECT_NAME}_VERSION}
						-DTARGET_PLATFORM=${CURRENT_PLATFORM_NAME}
						-DCMAKE_COMMAND=${CMAKE_COMMAND}
						-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
						-DINCLUDES_API_DOC=${BUILD_API_DOC}
						-DINCLUDES_COVERAGE=${INCLUDING_COVERAGE}
						-DINCLUDES_STATIC_CHECKS=${INCLUDING_STATIC_CHECKS}
						-DINCLUDES_INSTALLER=${INCLUDING_BINARIES}
						-DSYNCHRO=$(synchro)
						-DFORCED_UPDATE=$(force)
						-DSITE_GIT="${${PROJECT_NAME}_SITE_GIT_ADDRESS}"
						-DPACKAGE_PROJECT_URL="${${PROJECT_NAME}_PROJECT_PAGE}"
						-DPACKAGE_SITE_URL="${${PROJECT_NAME}_SITE_ROOT_PAGE}"
			 -P ${WORKSPACE_DIR}/share/cmake/system/commands/Build_PID_Site.cmake)
elseif(${PROJECT_NAME}_FRAMEWORK) #the publication of the static site is done with a framework

	add_custom_target(site
		COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DTARGET_VERSION=${${PROJECT_NAME}_VERSION}
						-DTARGET_PLATFORM=${CURRENT_PLATFORM_NAME}
						-DCMAKE_COMMAND=${CMAKE_COMMAND}
						-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
						-DTARGET_FRAMEWORK=${${PROJECT_NAME}_FRAMEWORK}
						-DINCLUDES_API_DOC=${BUILD_API_DOC}
						-DINCLUDES_COVERAGE=${INCLUDING_COVERAGE}
						-DINCLUDES_STATIC_CHECKS=${INCLUDING_STATIC_CHECKS}
						-DINCLUDES_INSTALLER=${INCLUDING_BINARIES}
						-DSYNCHRO=$(synchro)
						-DPACKAGE_PROJECT_URL="${${PROJECT_NAME}_PROJECT_PAGE}"
			 -P ${WORKSPACE_DIR}/share/cmake/system/commands/Build_PID_Site.cmake
	)
endif()
finish_Progress("${GLOBAL_PROGRESS_VAR}") #managing the build from a global point of view
endmacro(build_Wrapped_Project)

###
function(belongs_To_Known_Versions BELONGS_TO version)
	list(FIND ${PROJECT_NAME}_KNOWN_VERSIONS ${version} INDEX)
	if(INDEX EQUAL -1)
		set(${BELONGS_TO} FALSE PARENT_SCOPE)
	else()
		set(${BELONGS_TO} TRUE PARENT_SCOPE)
	endif()
endfunction(belongs_To_Known_Versions)

#	memorizing a new known version (the target folder that can be found in src folder contains the script used to install the project)
function(add_Known_Version version deploy_file_name compatible_with_version so_name post_install_script)
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${version} OR NOT IS_DIRECTORY ${CMAKE_SOURCE_DIR}/src/${version})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, no folder \"${version}\" can be found in src folder !")
	return()
endif()
list(FIND ${PROJECT_NAME}_KNOWN_VERSIONS ${version} INDEX)
if(NOT INDEX EQUAL -1)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, version \"${version}\" is already registered !")
	return()
endif()
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSIONS ${version})
set(${PROJECT_NAME}_KNOWN_VERSION_${version}_DEPLOY_SCRIPT ${deploy_file_name} CACHE INTERNAL "")
set(${PROJECT_NAME}_KNOWN_VERSION_${version}_POST_INSTALL_SCRIPT ${post_install_script} CACHE INTERNAL "")
set(${PROJECT_NAME}_KNOWN_VERSION_${version}_SONAME ${so_name} CACHE INTERNAL "")
if(compatible_with_version AND NOT compatible_with_version STREQUAL "")
	set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPATIBLE_WITH ${compatible_with_version} CACHE INTERNAL "")
endif()
set(CURRENT_MANAGED_VERSION ${version} CACHE INTERNAL "")
endfunction(add_Known_Version)

### dependency to another external package
function(declare_Wrapped_Configuration platform configurations)
# update the list of required configurations
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_CONFIGURATIONS "${configurations}")

if(platform AND NOT platform STREQUAL "")# if a platform constraint applies
	foreach(config IN ITEMS ${configurations})
		if(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_CONFIGURATION_${config}) # another platform constraint already applies
			if(NOT ${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_CONFIGURATION_${config} STREQUAL "all")#the configuration has no constraint
				# simply add it
				set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_CONFIGURATION_${config} ${${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_CONFIGURATION_${config}} ${platform} CACHE INTERNAL "")
			endif()
		else() #simply set the variable
			set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_CONFIGURATION_${config} ${platform} CACHE INTERNAL "")
		endif()
	endforeach()
else()#no platform constraint applies => this platform configuration is adequate for all platforms
	foreach(config IN ITEMS ${configurations})
		set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_CONFIGURATION_${config} "all" CACHE INTERNAL "")
	endforeach()
endif()
endfunction(declare_Wrapped_Configuration)


### set cached variable for external packages dependency
function(add_External_Package_Dependency_To_Wrapper external_version dep_package list_of_versions exact_versions list_of_components)
	append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${external_version}_DEPENDENCIES ${dep_package})#dep package must be deployed in irder t use current project
	append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${external_version}_DEPENDENCY_${dep_package}_VERSIONS "${list_of_versions}")
	set(${PROJECT_NAME}_KNOWN_VERSION_${external_version}_DEPENDENCY_${dep_package}_VERSIONS_EXACT "${exact_versions}" CACHE INTERNAL "")
	append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${external_version}_DEPENDENCY_${dep_package}_COMPONENTS "${list_of_components}")
endfunction(add_External_Package_Dependency_To_Wrapper)

### dependency to another external package
function(declare_Wrapped_External_Dependency dep_package list_of_versions exact_versions list_of_components)
add_External_Package_Dependency_To_Wrapper(${CURRENT_MANAGED_VERSION} ${dep_package} "${list_of_versions}" "${exact_versions}" "${list_of_components}")

### now finding external package dependencies as they are required to build the package
set(unused FALSE)
# 1) the package may be required at that time
# defining if there is either a specific version to use or not
if(NOT list_of_versions OR list_of_versions STREQUAL "")#no specific version to use
	set(${CURRENT_MANAGED_VERSION}_${dep_package}_ALTERNATIVE_VERSION_USED ANY CACHE INTERNAL "" FORCE)
	set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_VERSION_USED_FOR_BUILD CACHE INTERNAL "")#no version means any version (no contraint)
else()#there are version specified
	# defining which version to use, if any
	list(LENGTH list_of_versions SIZE)
	list(GET list_of_versions 0 version) #by defaut this is the first element in the list that is taken
	if(SIZE EQUAL 1)#only one dependent version, this is the basic version of the function
		set(${CURRENT_MANAGED_VERSION}_${dep_package}_ALTERNATIVE_VERSION_USED ${version} CACHE INTERNAL "" FORCE)
	else() #there are many possible versions
		fill_List_Into_String("${list_of_versions}" available_versions)
		set(${CURRENT_MANAGED_VERSION}_${dep_package}_ALTERNATIVE_VERSION_USED ${version} CACHE STRING "Select the version of ${dep_package} to be used among versions : ${available_versions}")
		#check if the user input is not faulty (version is in the list)
		if(NOT ${CURRENT_MANAGED_VERSION}_${dep_package}_ALTERNATIVE_VERSION_USED)
			message(FATAL_ERROR "[PID] CRITICAL ERROR : you did not define any version for dependency ${dep_package}.")
			return()
		endif()

		if(${CURRENT_MANAGED_VERSION}_${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "ANY")#special case where any version was specified by the user
			list(GET list_of_versions 0 VERSION_AUTOMATICALLY_SELECTED) #taking first version available
			#force reset the value of the variable to this version
			set(${CURRENT_MANAGED_VERSION}_${dep_package}_ALTERNATIVE_VERSION_USED ${VERSION_AUTOMATICALLY_SELECTED} CACHE STRING "Select if ${dep_package} is to be used (input NONE) ot choose among versions : ${available_versions}" FORCE)
		else()# a version has been specified
			list(FIND list_of_versions ${${CURRENT_MANAGED_VERSION}_${dep_package}_ALTERNATIVE_VERSION_USED} INDEX)
			if(INDEX EQUAL -1 )#no possible version found corresponding to user input
				message(FATAL_ERROR "[PID] CRITICAL ERROR : you set a bad version value (${${dep_package}_${CURRENT_MANAGED_VERSION}_ALTERNATIVE_VERSION_USED}) for dependency ${dep_package}.")
				return()
			endif()
		endif()
	endif()# at the end the version USED for the dependency is specified

	#now set the version used for build depending on what has been chosen
	set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_VERSION_USED_FOR_BUILD ${${CURRENT_MANAGED_VERSION}_${dep_package}_ALTERNATIVE_VERSION_USED} CACHE INTERNAL "")#no version means any version (no contraint)
endif()

# based on this version constraint, try to find an adequate package version in workspace
set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD TRUE)#by default downloading is the behavior of a wrapper so download is always automatic
if(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_VERSION_USED_FOR_BUILD)
	set(version_used ${${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_VERSION_USED_FOR_BUILD})

	list(FIND ${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_VERSIONS_EXACT ${version_used} EXACT_AT)
	if(EXACT_AT GREATER -1)#exact version used
		if(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_COMPONENTS)#check components
			find_package(${dep_package} ${${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_VERSION_USED_FOR_BUILD}
				EXACT REQUIRED
				COMPONENTS ${${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_COMPONENTS})
		else()#do not check for components
			find_package(${dep_package} ${${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_VERSION_USED_FOR_BUILD}
				EXACT REQUIRED)
		endif()
	else()#any compatible version
		if(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_COMPONENTS)#check components
			find_package(${dep_package} ${${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_VERSION_USED_FOR_BUILD}
				REQUIRED
				COMPONENTS ${${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_COMPONENTS})
		else()#do not check for components
			find_package(${dep_package} ${${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_VERSION_USED_FOR_BUILD}
				REQUIRED)#this is the basic situation
		endif()
	endif()
else()#no version specified
	if(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_COMPONENTS)#check components
		find_package(${dep_package}
			REQUIRED
			COMPONENTS ${${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_COMPONENTS})
	else()#do not check for components
		find_package(${dep_package} REQUIRED)
	endif()
endif()

#  managing automatic install process if required (when not found)
if(NOT ${dep_package}_FOUND)#testing if the package has been previously found or not
		list(FIND ${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES ${dep_package} INDEX)
		if(INDEX EQUAL -1)
			#if the package where not specified as REQUIRED in the find_package call, we face a case of conditional dependency => the package has not been registered as "to install" while now we know it must be installed
			if(version)# a version is specified (the same as for native packages)
				list(FIND ${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_VERSIONS_EXACT ${${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_VERSION_USED_FOR_BUILD} EXACT_AT)
				if(EXACT_AT GREATER -1)#exact version used
					set(is_exact TRUE)
				else()
					set(is_exact FALSE)
				endif()
				add_To_Install_External_Package_Specification(${dep_package} "${${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_VERSION_USED_FOR_BUILD}" ${is_exact})
			else()#no version simply install
				add_To_Install_External_Package_Specification(${dep_package} "" FALSE)
			endif()
		endif()
else()#if something found then it becomes the real version used in the end
	set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_DEPENDENCY_${dep_package}_VERSION_USED_FOR_BUILD ${${dep_package}_VERSION_STRING} CACHE INTERNAL "")
endif()
endfunction(declare_Wrapped_External_Dependency)

### define a component
function(declare_Wrapped_Component component shared_links static_links includes definitions options c_standard cxx_standard runtime_resources)
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENTS ${component})
set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_SHARED_LINKS ${shared_links} CACHE INTERNAL "")
set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_STATIC_LINKS ${static_links} CACHE INTERNAL "")
set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_INCLUDES ${includes} CACHE INTERNAL "")
set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEFINITIONS ${definitions} CACHE INTERNAL "")
set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_OPTIONS ${options} CACHE INTERNAL "")
set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_C_STANDARD ${c_standard} CACHE INTERNAL "")
set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_CXX_STANDARD ${cxx_standard} CACHE INTERNAL "")
set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_RUNTIME_RESOURCES ${runtime_resources} CACHE INTERNAL "")
endfunction(declare_Wrapped_Component)

### define a component
function(declare_Wrapped_Component_Dependency_To_Explicit_Component component package dependency_component exported definitions)
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEPENDENCIES ${package})
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEPENDENCY_${package} ${dependency_component})
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEPENDENCY_${package}_${dependency_component}_DEFINITIONS "${definitions}")
set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEPENDENCY_${package}_${dependency_component}_EXPORTED ${exported} CACHE INTERNAL "")
endfunction(declare_Wrapped_Component_Dependency_To_Explicit_Component)

### define a component
function(declare_Wrapped_Component_Dependency_To_Implicit_Components component package includes shared static definitions options c_standard cxx_standard runtime_resources)
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEPENDENCIES ${package})
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_INCLUDES "${includes}")
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_SHARED "${shared}")
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_STATIC "${static}")
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_DEFINITIONS "${definitions}")
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_OPTIONS "${options}")
set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_C_STANDARD "${c_standard}")
set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_CXX_STANDARD "${cxx_standard}")
set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_DEPENDENCY_${package}_CONTENT_RUNTIME_RESOURCES "${runtime_resources}")
endfunction(declare_Wrapped_Component_Dependency_To_Implicit_Components)

###
function(declare_Wrapped_Component_Internal_Dependency component dependency_component exported definitions)
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_INTERNAL_DEPENDENCIES ${dependency_component})
append_Unique_In_Cache(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_INTERNAL_DEPENDENCY_${dependency_component}_DEFINITIONS "${definitions}")
set(${PROJECT_NAME}_KNOWN_VERSION_${CURRENT_MANAGED_VERSION}_COMPONENT_${component}_INTERNAL_DEPENDENCY_${dependency_component}_EXPORTED ${exported} CACHE INTERNAL "")
endfunction(declare_Wrapped_Component_Internal_Dependency)

###
function(install_External_Use_File_For_Version package version platform)
	set(file_path ${WORKSPACE_DIR}/wrappers/${package}/build/Use${package}-${version}.cmake)
	set(target_folder ${WORKSPACE_DIR}/external/${platform}/${package}/${version}/share)
	file(COPY ${file_path} DESTINATION ${target_folder})
endfunction(install_External_Use_File_For_Version)

###
function(generate_External_Use_File_For_Version package version platform)
	set(file_for_version ${WORKSPACE_DIR}/wrappers/${package}/build/Use${package}-${version}.cmake)
	file(WRITE ${file_for_version} "#############################################\n")#reset file content (if any) or create file
	file(APPEND ${file_for_version} "#description of ${package} content (version ${version})\n")
	file(APPEND ${file_for_version} "declare_PID_External_Package(PACKAGE ${package})\n")

	#add checks for required platform configurations
	if(${package}_KNOWN_VERSION_${version}_CONFIGURATIONS)
		set(list_of_configs)
		foreach(config IN ITEMS ${${package}_KNOWN_VERSION_${version}_CONFIGURATIONS})
			if(${package}_KNOWN_VERSION_${version}_CONFIGURATION_${config} STREQUAL "all"
				OR ${package}_KNOWN_VERSION_${version}_CONFIGURATION_${config} STREQUAL "${platform}")#this configuration is required for any platform
				list(APPEND list_of_configs ${config})
			endif()
		endforeach()
		if(list_of_configs)
			file(APPEND ${file_for_version} "#description of external package ${package} version ${version} required platform configurations\n")
			fill_List_Into_String(${list_of_configs} RES_CONFIG)
			file(APPEND ${file_for_version} "check_PID_External_Package_Platform(PACKAGE ${package} PLATFORM ${platform} CONFIGURATION ${RES_CONFIG})\n")
		endif()
	endif()

	#add required external dependencies
	if(${package}_KNOWN_VERSION_${version}_DEPENDENCIES)
		file(APPEND ${file_for_version} "#description of external package ${package} dependencies for version ${version}\n")
		foreach(dependency IN ITEMS ${${package}_KNOWN_VERSION_${version}_DEPENDENCIES})#do the description for each dependency
			set(VERSION_STR "")
			if(${package}_KNOWN_VERSION_${version}_DEPENDENCY_${dependency}_VERSIONS)#there is at least one version requirement
				set(selected_version ${${package}_KNOWN_VERSION_${version}_DEPENDENCY_${dependency}_VERSION_USED_FOR_BUILD})
				if(${package}_KNOWN_VERSION_${version}_DEPENDENCY_${dependency}_VERSIONS_EXACT)
					list(FIND ${package}_KNOWN_VERSION_${version}_DEPENDENCY_${dependency}_VERSIONS_EXACT ${selected_version} INDEX)
					if(INDEX EQUAL -1)
						set(STR_EXACT "")#not an exact version
					else()
						set(STR_EXACT "EXACT ")
					endif()
				endif()
				#setting the selected version as the "reference version" (only compatible versions can be used instead when using the binary version of a package)
				file(APPEND ${file_for_version} "declare_PID_External_Package_Dependency(PACKAGE ${package} EXTERNAL ${dependency} ${EXACT_STR}VERSION ${selected_version})\n")
			else()
				file(APPEND ${file_for_version} "declare_PID_External_Package_Dependency(PACKAGE ${package} EXTERNAL ${dependency})\n")
			endif()
		endforeach()
	endif()

	# manage generation of component description
	if(${package}_KNOWN_VERSION_${version}_COMPONENTS ${component})
		file(APPEND ${file_for_version} "#description of external package ${package} version ${version} components\n")
		foreach(component IN ITEMS ${${package}_KNOWN_VERSION_${version}_COMPONENTS})
			generate_Description_For_External_Component(${file_for_version} ${package} ${platform} ${version} ${component})
		endforeach()
	endif()
endfunction(generate_External_Use_File_For_Version)

###
function(create_Shared_Lib_Extension RES_EXT platform soname)
	extract_Info_From_Platform(RES_ARCH RES_BITS RES_OS RES_ABI ${platform})
	if(RES_OS STREQUAL macosx)
		set(${RES_EXT} ".dylib" PARENT_SCOPE)
	else()# Linux or any other standard UNIX system
		if(soname AND NOT soname STREQUAL "")
			set(${RES_EXT} ".so.${soname}" PARENT_SCOPE)
		else()
			set(${RES_EXT} ".so" PARENT_SCOPE)
		endif()
	endif()
endfunction(create_Shared_Lib_Extension)

###
function(generate_Description_For_External_Component_Internal_Dependency file_for_version package version component dependency)
if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCY_${dependency}_DEFINITIONS)
	fill_List_Into_String(${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCY_${dependency}_DEFINITIONS} RES_STR)
	set(defs " DEFINITIONS ${RES_STR}")
else()
	set(defs "")
endif()
if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCY_${dependency}_EXPORTED)
	set(usage "EXPORT")
else()
	set(usage "USE")
endif()
file(APPEND ${file_for_version} "declare_PID_External_Component_Dependency(PACKAGE ${package} COMPONENT ${component} ${usage} ${dependency}${defs})\n")
endfunction(generate_Description_For_External_Component_Internal_Dependency)

###
function(generate_Description_For_External_Component_Dependency file_for_version package platform version component external_package_dependency)
if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency})
foreach(dep_component IN ITEMS ${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}})
	#managing each component individually
	set(defs "")
	if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_${dep_component}_DEFINITIONS)
		fill_List_Into_String(${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_${dep_component}_DEFINITIONS} RES_STR)
		set(defs "DEFINITIONS ${RES_STR}")
	endif()
	if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_${dep_component}_EXPORTED)
		set(usage "EXPORT ${dep_component}")
	else()
		set(usage "USE ${dep_component}")
	endif()
	file(APPEND ${file_for_version} "declare_PID_External_Component_Dependency(PACKAGE ${package} COMPONENT ${component} ${usage} EXTERNAL ${dependency}${defs})\n")
endforeach()
endif()

#direct package relationship described
set(package_rel_to_write FALSE)
if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_INCLUDES)
	fill_List_Into_String(${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_INCLUDES} RES_INC)
	set(includes " INCLUDES ${RES_INC}")
	set(package_rel_to_write TRUE)
else()
	set(includes "")
endif()
if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_SHARED)
	create_Shared_Lib_Extension(RES_EXT ${platform} ${${package}_KNOWN_VERSION_${version}_SONAME})
	set(final_list_of_shared)#add the adequate extension name depending on the platform
	foreach(shared_lib_path IN ITEMS ${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_SHARED})
			get_filename_component(EXTENSION ${shared_lib_path} EXT)
			if(NOT EXTENSION OR EXTENSION STREQUAL "")#OK no extension defined we can apply
				list(APPEND final_list_of_shared "${shared_lib_path}${RES_EXT}")
			else()#need to apply an extension since there is none
				list(APPEND final_list_of_shared "${shared_lib_path}")
			endif()
	endforeach()
	fill_List_Into_String("${final_list_of_shared}" RES_SHARED)
	set(shared " SHARED_LINKS ${RES_SHARED}")
	set(package_rel_to_write TRUE)
else()
	set(shared "")
endif()
if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_STATIC)
	fill_List_Into_String(${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_STATIC} RES_STATIC)
	set(static " STATIC_LINKS ${RES_STATIC}")
	set(package_rel_to_write TRUE)
else()
	set(static "")
endif()
if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_DEFINITIONS)
	fill_List_Into_String(${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_DEFINITIONS} RES_DEFS)
	set(defs " DEFINITIONS ${RES_DEFS}")
	set(package_rel_to_write TRUE)
else()
	set(defs "")
endif()
if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_OPTIONS)
	fill_List_Into_String(${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_OPTIONS} RES_OPTS)
	set(opts " COMPILER_OPTIONS ${RES_OPTS}")
	set(package_rel_to_write TRUE)
else()
	set(opts "")
endif()
if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_C_STANDARD)
	set(c_std " C_STANDARD ${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_C_STANDARD}")
	set(package_rel_to_write TRUE)
else()
	set(c_std "")
endif()
if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_CXX_STANDARD)
	set(cxx_std " CXX_STANDARD ${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_CXX_STANDARD}")
	set(package_rel_to_write TRUE)
else()
	set(cxx_std "")
endif()
if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_RUNTIME_RESOURCES)
	fill_List_Into_String(${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCY_${external_package_dependency}_CONTENT_RUNTIME_RESOURCES} RES_RESOURCES)
	set(resources " RUNTIME_RESOURCES ${RES_RESOURCES}")
	set(package_rel_to_write TRUE)
else()
	set(resources "")
endif()
if(package_rel_to_write)#write all the imported stuff from another external package in one call
	file(APPEND ${file_for_version} "declare_PID_External_Component_Dependency(PACKAGE ${package} COMPONENT ${component} EXTERNAL ${dependency}${includes}${shared}${static}${defs}${opts}${c_std}${cxx_std}${resources})\n")
endif()
endfunction(generate_Description_For_External_Component_Dependency)

###
function(generate_Description_For_External_Component file_for_version package platform version component)
	file(APPEND ${file_for_version} "#component ${component}\n")
	set(options_str "")
	if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_SHARED_LINKS)
		create_Shared_Lib_Extension(RES_EXT ${shared} ${platform} ${${package}_KNOWN_VERSION_${version}_SONAME})
		set(final_list_of_shared)#add the adequate extension name depending on the platform
		foreach(shared_lib_path IN ITEMS ${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_SHARED_LINKS})
				get_filename_component(EXTENSION ${shared_lib_path} EXT)
				if(NOT EXTENSION OR EXTENSION STREQUAL "")#OK no extension defined we can apply
					list(APPEND final_list_of_shared "${shared_lib_path}${RES_EXT}")
				else()
					list(APPEND final_list_of_shared "${shared_lib_path}")
				endif()
		endforeach()

		fill_List_Into_String("${final_list_of_shared}" RES_SHARED)
		set(options_str " SHARED_LINKS ${RES_SHARED}")
	endif()
	if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_STATIC_LINKS)
		fill_List_Into_String("${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_STATIC_LINKS}" RES_STR)
		set(options_str "${options_str} STATIC_LINKS ${RES_STR}")
	endif()
	if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_INCLUDES)
		fill_List_Into_String("${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_INCLUDES}" RES_STR)
		set(options_str "${options_str} INCLUDES ${RES_STR}")
	endif()
	if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEFINITIONS)
		fill_List_Into_String("${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEFINITIONS}" RES_STR)
		set(options_str "${options_str} DEFINITIONS ${RES_STR}")
	endif()
	if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_OPTIONS)
		fill_List_Into_String("${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_OPTIONS}" RES_STR)
		set(options_str "${options_str} OPTIONS ${RES_STR}")
	endif()
	if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_C_STANDARD)
		fill_List_Into_String("${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_C_STANDARD}" RES_STR)
		set(options_str "${options_str} C_STANDARD ${RES_STR}")
	endif()
	if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_CXX_STANDARD)
		fill_List_Into_String("${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_CXX_STANDARD}" RES_STR)
		set(options_str "${options_str} CXX_STANDARD ${RES_STR}")
	endif()
	if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_RUNTIME_RESOURCES)
		fill_List_Into_String("${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_RUNTIME_RESOURCES}" RES_STR)
		set(options_str "${options_str} RUNTIME_RESOURCES ${RES_STR}")
	endif()
	file(APPEND ${file_for_version} "declare_PID_External_Component(PACKAGE ${package} COMPONENT ${component}${options_str})\n")

	#management of component internal dependencies
	if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCIES)
		file(APPEND ${file_for_version} "#declaring internal dependencies for component ${component}\n")
		foreach(dep IN ITEMS ${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_INTERNAL_DEPENDENCIES})
			generate_Description_For_External_Component_Internal_Dependency(${file_for_version} ${package} ${version} ${component} ${dep})
		endforeach()
	endif()

	#management of component internal dependencies
	if(${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCIES)
		file(APPEND ${file_for_version} "#declaring external dependencies for component ${component}\n")
		foreach(dep_pack IN ITEMS ${${package}_KNOWN_VERSION_${version}_COMPONENT_${component}_DEPENDENCIES})
			generate_Description_For_External_Component_Dependency(${file_for_version} ${package} ${platform} ${version} ${component} ${dep_pack})
		endforeach()
	endif()
endfunction(generate_Description_For_External_Component)


### defining a framework static site the package belongs to
macro(define_Wrapper_Framework_Contribution framework url description)
if(${PROJECT_NAME}_FRAMEWORK AND (NOT ${PROJECT_NAME}_FRAMEWORK STREQUAL ""))
	message("[PID] ERROR: a framework (${${PROJECT_NAME}_FRAMEWORK}) has already been defined, cannot define a new one !")
	return()
elseif(${PROJECT_NAME}_SITE_GIT_ADDRESS AND (NOT ${PROJECT_NAME}_SITE_GIT_ADDRESS STREQUAL ""))
	message("[PID] ERROR: a static site (${${PROJECT_NAME}_SITE_GIT_ADDRESS}) has already been defined, cannot define a framework !")
	return()
endif()
init_Documentation_Info_Cache_Variables("${framework}" "${url}" "" "" "${description}")
endmacro(define_Wrapper_Framework_Contribution)
