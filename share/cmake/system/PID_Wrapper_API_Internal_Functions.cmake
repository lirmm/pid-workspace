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
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Package_Cache_Management_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)

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

###
function(hard_Clean_Wrapper)
set(TARGET_BUILD_FOLDER ${${PROJECT_NAME}_ROOT_DIR}/build)
file(GLOB thefiles RELATIVE ${TARGET_BUILD_FOLDER} ${TARGET_BUILD_FOLDER}/*)
if(thefiles)
foreach(a_file IN ITEMS ${thefiles})
	if(NOT a_file STREQUAL ".gitignore")
		if(IS_DIRECTORY ${TARGET_BUILD_FOLDER}/${a_file})
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${TARGET_BUILD_FOLDER}/${a_file})
		else()#it is a regular file or symlink
			execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${TARGET_BUILD_FOLDER}/${a_file})
		endif()
	endif()
endforeach()
endif()
endfunction(hard_Clean_Wrapper)

### reconfiguring a wrapper
function(reconfigure_Wrapper_Build)
set(TARGET_BUILD_FOLDER ${${PROJECT_NAME}_ROOT_DIR}/build)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${TARGET_BUILD_FOLDER} ${CMAKE_COMMAND} ..)
endfunction(reconfigure_Wrapper_Build)

###
function(reset_Wrapper_Description_Cached_Variables)
if(${PROJECT_NAME}_KNOWN_VERSIONS)
  foreach(version IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSIONS})

	endforeach()
set(${PROJECT_NAME}_KNOWN_VERSIONS CACHE INTERNAL "")
endif()
reset_Documentation_Info()
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

include(${WORKSPACE_DIR}/pid/Workspace_Platforms_Info.cmake) #loading the current platform configuration

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
    hard_Clean_Wrapper()
		reconfigure_Wrapper_Build()
  endif()
endif()

if(DIR_NAME STREQUAL "build")

  #################################################
  ######## create global targets ##################
  #################################################
	add_custom_target(build
    ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
           -DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
           -DTARGET_EXTERNAL_PACKAGE=${PROJECT_NAME}
           -DTARGET_EXTERNAL_VERSION=$(version)
           -DTARGET_PLATFORM="${CURRENT_PLATFORM}"
					 -DTARGET_SCRIPT_FILE=${${PROJECT_NAME}_KNOWN_VERSION_${version}_SCRIPT_FILE}
					 -DTARGET_SCRIPT_TYPE=${${PROJECT_NAME}_KNOWN_VERSION_${version}_SCRIPT_TYPE}
           -P ${WORKSPACE_DIR}/share/cmake/system/Build_PID_Wrapper.cmake
    COMMENT "[PID] Building external package for platform ${CURRENT_PLATFORM} using environment ${CURRENT_ENVIRONMENT} ..."
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
  init_PID_Version_Variable()
  init_Wrapper_Info_Cache_Variables("${author}" "${institution}" "${mail}" "${description}" "${year}" "${license}" "${address}" "${public_address}" "${readme_file}")

else()
  message("[PID] ERROR : please run cmake in the build folder of the wrapper ${PROJECT_NAME}.")
  return()
endif()
endmacro(declare_Wrapper)

###
macro(define_Wrapped_Project authors_references licenses original_project_url)
set(${PROJECT_NAME}_WRAPPER_ORIGINAL_PROJECT_AUTHORS ${authors_references} CACHE INTERNAL "")
set(${PROJECT_NAME}_WRAPPER_ORIGINAL_PROJECT_LICENSES ${licenses} CACHE INTERNAL "")
set(${PROJECT_NAME}_WRAPPER_ORIGINAL_PROJECT_SITE ${original_project_url} CACHE INTERNAL "")
endmacro(define_Wrapped_Project)


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
			if(${PROJECT_NAME}_${version}_COMPATIBLE_WITH)
				set(COMPATIBLE_VERSION_FOUND TRUE)
				break()
			endif()
		endforeach()
		# second step defines version compatibility at fine grain only if needed
		if(COMPATIBLE_VERSION_FOUND)
			foreach(version IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSIONS} )
				set(FIRST_INCOMPATIBLE_VERSION)
				set(COMPATIBLE_VERSION_FOUND FALSE)
				foreach(other_version IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSIONS})
					if(other_version VERSION_GREATER version)#the version is greater than the currenlty managed one
						if(${PROJECT_NAME}_${other_version}_COMPATIBLE_WITH)
							check_External_Version_Compatibility(IS_COMPATIBLE ${version} ${${PROJECT_NAME}_${other_version}_COMPATIBLE_WITH})
							if(NOT IS_COMPATIBLE)#not compatible
								if(NOT FIRST_INCOMPATIBLE_VERSION)
									set(FIRST_INCOMPATIBLE_VERSION ${${PROJECT_NAME}_${other_version}_COMPATIBLE_WITH}) #memorize the lower incompatible version with ${version}
								elseif(FIRST_INCOMPATIBLE_VERSION VERSION_GREATER ${PROJECT_NAME}_${other_version}_COMPATIBLE_WITH)
									set(FIRST_INCOMPATIBLE_VERSION ${${PROJECT_NAME}_${other_version}_COMPATIBLE_WITH}) #memorize the lower incompatible version with ${version}
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
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_SCRIPT_TYPE ${${PROJECT_NAME}_KNOWN_VERSION_${version}_SCRIPT_TYPE} CACHE INTERNAL \"\")\n")
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_SCRIPT_FILE ${${PROJECT_NAME}_KNOWN_VERSION_${version}_SCRIPT_FILE} CACHE INTERNAL \"\")\n")
	file(APPEND ${path_to_file} "set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPATIBLE_WITH ${${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPATIBLE_WITH} CACHE INTERNAL \"\")\n")
endforeach()
endif()
endfunction(generate_Wrapper_Build_File)

###
macro(build_Wrapped_Project)
# if(${PROJECT_NAME}_KNOWN_VERSIONS)
# foreach(version IN ITEMS ${${PROJECT_NAME}_KNOWN_VERSIONS})
# 	set(CURRENT_MANAGED_VERSION ${version})
# 	add_subdirectory(src/${version})
# endforeach()
# endif()

################################################################################
######## generating CMake configuration files used by PID ######################
################################################################################
generate_Wrapper_Build_File(${CMAKE_BINARY_DIR}/Build${PROJECT_NAME}.cmake)
generate_Wrapper_Reference_File(${CMAKE_BINARY_DIR}/share/ReferExternal${PROJECT_NAME}.cmake)
generate_Wrapper_Readme_Files() # generating and putting into source directory the readme file used by gitlab
generate_Wrapper_License_File() # generating and putting into source directory the file containing license info about the package
generate_Wrapper_Find_File() # generating/installing the generic cmake find file for the package

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
			 -P ${WORKSPACE_DIR}/share/cmake/system/Build_PID_Site.cmake)
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
			 -P ${WORKSPACE_DIR}/share/cmake/system/Build_PID_Site.cmake
	)
endif()
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
function(add_Known_Version version script_type install_file_name compatible_with_version)
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/src/${version} OR NOT IS_DIRECTORY ${CMAKE_SOURCE_DIR}/src/${version})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, no folder \"${version}\" can be found in src folder !")
	return()
endif()
list(FIND ${PROJECT_NAME}_KNOWN_VERSIONS ${version} INDEX)
if(NOT INDEX EQUAL -1)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : bad version argument when calling add_PID_Wrapper_Known_Version, version \"${version}\" is already registered !")
	return()
endif()
set(${PROJECT_NAME}_KNOWN_VERSIONS ${${PROJECT_NAME}_KNOWN_VERSIONS} ${version} CACHE INTERNAL "")
set(${PROJECT_NAME}_KNOWN_VERSION_${version}_SCRIPT_TYPE ${script_type} CACHE INTERNAL "")
set(${PROJECT_NAME}_KNOWN_VERSION_${version}_SCRIPT_FILE ${install_file_name} CACHE INTERNAL "")
if(compatible_with_version AND NOT compatible_with_version STREQUAL "")
	set(${PROJECT_NAME}_KNOWN_VERSION_${version}_COMPATIBLE_WITH ${compatible_with_version} CACHE INTERNAL "")
endif()
endfunction(add_Known_Version)

### dependency to another external package
macro(declare_Wrapper_Configuration platform configurations)

endmacro(declare_Wrapper_Configuration)

### dependency to another external package
macro(declare_PID_Wrapper_External_Dependency dependency_project dependency_version)

endmacro(declare_PID_Wrapper_External_Dependency)

### define a component
macro(declare_PID_Wrapper_Component component deploy_script shared_links static_links includes definitions)

endmacro(declare_PID_Wrapper_Component)

### define a component
macro(declare_PID_Wrapper_Component_Dependency )

endmacro(declare_PID_Wrapper_Component_Dependency)
