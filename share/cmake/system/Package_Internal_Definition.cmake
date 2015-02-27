########################################################################
##################### definition of CMake policies #####################
########################################################################
cmake_policy(SET CMP0026 OLD) #disable warning when reading LOCATION property
cmake_policy(SET CMP0048 OLD) #allow to use a custom versionning system
cmake_policy(SET CMP0037 OLD) #allow to redefine standard target such as clean
cmake_policy(SET CMP0045 OLD) #allow to test if a target exist without a warning

########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(Package_Internal_Finding NO_POLICY_SCOPE)
include(Package_Internal_Configuration NO_POLICY_SCOPE)
include(Package_Internal_Referencing NO_POLICY_SCOPE)
include(Package_Internal_External_Package_Management NO_POLICY_SCOPE)
##################################################################################
#################### package management public functions and macros ##############
##################################################################################

##################################################################################
###########################  declaration of the package ##########################
##################################################################################
macro(declare_Package author institution mail year license address description)
#################################################
############ DECLARING options ##################
#################################################
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake) # adding the cmake scripts files from the package
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/find) # using common find modules of the workspace
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references) # using common find modules of the workspace

include(CMakeDependentOption)
option(BUILD_EXAMPLES "Package builds examples" ON)

option(BUILD_API_DOC "Package generates the HTML API documentation" ON)
CMAKE_DEPENDENT_OPTION(BUILD_LATEX_API_DOC "Package generates the LATEX api documentation" OFF
		         "BUILD_API_DOC" OFF)

option(BUILD_AND_RUN_TESTS "Package uses tests" OFF)
#option(BUILD_WITH_PRINT_MESSAGES "Package generates print in console" OFF)

option(USE_LOCAL_DEPLOYMENT "Package uses tests" OFF)
CMAKE_DEPENDENT_OPTION(GENERATE_INSTALLER "Package generates an OS installer for linux with debian" ON
		         "NOT USE_LOCAL_DEPLOYMENT" OFF)

option(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD "Enabling the automatic download of not found packages marked as required" ON)

option(ENABLE_PARALLEL_BUILD "Package is built with optimum number of jobs with respect to system properties" ON)

##########################################################
############ checking system properties ##################
##########################################################

### parallel builds management
if(ENABLE_PARALLEL_BUILD)
	include(ProcessorCount)
	ProcessorCount(NUMBER_OF_JOBS)
	math(EXPR NUMBER_OF_JOBS ${NUMBER_OF_JOBS}+1)
	if(${NUMBER_OF_JOBS} GREATER 1)
		set(PARALLEL_JOBS_FLAG "-j${NUMBER_OF_JOBS}" CACHE INTERNAL "")
	endif()
else()
	set(PARALLEL_JOBS_FLAG CACHE INTERNAL "")
endif()

#################################################
############ MANAGING build mode ################
#################################################
if(${CMAKE_BINARY_DIR} MATCHES release)
	reset_Mode_Cache_Options()

	set(CMAKE_BUILD_TYPE "Release" CACHE String "the type of build is dependent from build location" FORCE)
	set ( INSTALL_NAME_SUFFIX "" CACHE INTERNAL "")
	set ( USE_MODE_SUFFIX "" CACHE INTERNAL "")
	
elseif(${CMAKE_BINARY_DIR} MATCHES debug)
	reset_Mode_Cache_Options()
	
	set(CMAKE_BUILD_TYPE "Debug" CACHE String "the type of build is dependent from build location" FORCE)
	set ( INSTALL_NAME_SUFFIX -dbg CACHE INTERNAL "")
	set ( USE_MODE_SUFFIX "_DEBUG" CACHE INTERNAL "")
	
elseif(${CMAKE_BINARY_DIR} MATCHES build)
	file(WRITE ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/release/share/checksources "")
	file(WRITE ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/release/share/rebuilt "")
	
	################################################################################################
	############ creating custom targets to delegate calls to mode specific targets ################
	################################################################################################
	# target to check if source tree need to be rebuilt
	add_custom_target(checksources
			COMMAND ${CMAKE_COMMAND} -DWORKSPACE_DIR=${WORKSPACE_DIR}
						 -DPACKAGE_NAME=${PROJECT_NAME}
						 -DSOURCE_PACKAGE_CONTENT=${CMAKE_BINARY_DIR}/release/share/Info${PROJECT_NAME}.cmake
						 -P ${WORKSPACE_DIR}/share/cmake/system/Check_PID_Package_Modification.cmake		
			COMMENT "Checking for modified source tree ..."
    	)

	# target to reconfigure the project
	add_custom_command(OUTPUT ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/release/share/rebuilt
			COMMAND ${CMAKE_MAKE_PROGRAM} rebuild_cache
			COMMAND ${CMAKE_COMMAND} -E touch ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/release/share/rebuilt
			DEPENDS ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/release/share/checksources
			COMMENT "Reconfiguring the package ..."
    	)	
	add_custom_target(reconfigure
			DEPENDS ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/release/share/rebuilt			
    	)
	
	add_dependencies(reconfigure checksources)

	# global build target
	add_custom_target(build
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} build
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} build
		COMMENT "Building package (Debug and Release modes) ..."	
		VERBATIM
	)

	add_dependencies(build reconfigure)

	add_custom_target(global_main ALL
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
		COMMENT "Compiling and linking package (Debug and Release modes) ..."	
		VERBATIM
	)

	# redefinition of clean target (cleaning the build tree)
	add_custom_target(clean
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} clean
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} clean
		COMMENT "Cleaning package (Debug and Release modes) ..."	
		VERBATIM
	)
	# reference file generation target
	add_custom_target(referencing
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} referencing
		COMMENT "Generating and installing reference to the package ..."
		VERBATIM
	)

	# redefinition of install target
	add_custom_target(install
		COMMAND ${CMAKE_COMMAND} -E  echo Installing ${PROJECT_NAME} Debug artefacts
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} install
		COMMAND ${CMAKE_COMMAND} -E  echo Installing ${PROJECT_NAME} Release artefacts
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} install
		COMMENT "Installing the package ..."
		VERBATIM
	)
	
	# uninstall target (cleaning the install tree) 
	add_custom_target(uninstall
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} uninstall
		COMMENT "Uninstalling the package ..."
		VERBATIM
	)

	if(BUILD_AND_RUN_TESTS)
		# test target (launch test units) 
		add_custom_target(test
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} test
			COMMENT "Launching tests ..."
			VERBATIM
		)
	endif()

	if(BUILD_API_DOC)
		# doc target (generation of API documentation) 
		add_custom_target(doc
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} doc
			COMMENT "Generating API documentation ..."
			VERBATIM
		)
	endif()

	if(GENERATE_INSTALLER)
		# package target (generation and install of a UNIX binary packet) 
		add_custom_target(package
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} package
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} package_install
			COMMENT "Generating and installing system binary package ..."
			VERBATIM
		)
	endif()

	if(NOT "${license}" STREQUAL "")
		# target to add licensing information to all source files
		add_custom_target(licensing
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} licensing
			COMMENT "Applying license to sources ..."
			VERBATIM
		)
	endif()

	if(NOT EXISTS ${CMAKE_BINARY_DIR}/debug OR NOT IS_DIRECTORY ${CMAKE_BINARY_DIR}/debug)
		execute_process(COMMAND ${CMAKE_COMMAND} -E  make_directory debug WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
	endif()
	if(NOT EXISTS ${CMAKE_BINARY_DIR}/release OR NOT IS_DIRECTORY ${CMAKE_BINARY_DIR}/release)
		execute_process(COMMAND ${CMAKE_COMMAND} -E  make_directory release WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
	endif()
	
	#getting options
	execute_process(COMMAND ${CMAKE_COMMAND} -L -N WORKING_DIRECTORY ${CMAKE_BINARY_DIR} OUTPUT_FILE ${CMAKE_BINARY_DIR}/options.txt)
	#parsing option file and generating a load cache cmake script	
	file(STRINGS ${CMAKE_BINARY_DIR}/options.txt LINES)
	set(OPTIONS_FILE ${CMAKE_BINARY_DIR}/share/cacheConfig.cmake) 
	file(WRITE ${OPTIONS_FILE} "")
	foreach(line IN ITEMS ${LINES})
		if(NOT ${line} STREQUAL "-- Cache values")
			string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "set( \\1 \\3\ CACHE \\2 \"\" FORCE)\n" AN_OPTION "${line}")
			file(APPEND ${OPTIONS_FILE} ${AN_OPTION})
		endif()
	endforeach()
	
	#calling cmake for each mode 
	execute_process(COMMAND ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/debug)
	execute_process(COMMAND ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/release)

	#now getting options specific to debug and release modes
	execute_process(COMMAND ${CMAKE_COMMAND} -LH -N WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/debug OUTPUT_FILE ${CMAKE_BINARY_DIR}/optionsDEBUG.txt)
	execute_process(COMMAND ${CMAKE_COMMAND} -LH -N WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/release OUTPUT_FILE ${CMAKE_BINARY_DIR}/optionsRELEASE.txt)
	# copying new cache entries in the global build cache
	file(STRINGS ${CMAKE_BINARY_DIR}/optionsDEBUG.txt LINES_DEBUG)
	file(STRINGS ${CMAKE_BINARY_DIR}/optionsRELEASE.txt LINES_RELEASE)
	# searching new cache entries in release mode cache	
	foreach(line IN ITEMS ${LINES_RELEASE})
		if(NOT "${line}" STREQUAL "-- Cache values" AND NOT "${line}" STREQUAL "")
			string(REGEX REPLACE "^//(.*)$" "\\1" COMMENT ${line})
			if("${line}" STREQUAL "${COMMENT}") #no match this is an option line
				string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "\\1;\\3;\\2" AN_OPTION "${line}")
				list(GET AN_OPTION 0 var_name)
				string(FIND "${LINES}" "${var_name}" POS)	
				if(POS EQUAL -1)#not found, this a new cache entry
					list(GET AN_OPTION 1 var_value)
					list(GET AN_OPTION 2 var_type)
					set(${var_name} ${var_value} CACHE ${var_type} "${last_comment}")
				endif()
			else()#match is OK
				set(last_comment "${COMMENT}")
			endif()
		endif()
	endforeach()

	# searching new cache entries in debug mode cache	
	foreach(line IN ITEMS ${LINES_DEBUG})
		if(NOT "${line}" STREQUAL "-- Cache values" AND NOT "${line}" STREQUAL "")
			string(REGEX REPLACE "^//(.*)$" "\\1" COMMENT ${line})
			if("${line}" STREQUAL "${COMMENT}") #no match this is an option line
				string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "\\1;\\3;\\2" AN_OPTION "${line}")
				list(GET AN_OPTION 0 var_name)
				string(FIND "${LINES}" "${var_name}" POS)
				string(FIND "${LINES_RELEASE}" "${var_name}" POS_REL)
				if(POS EQUAL -1 AND POS_REL EQUAL -1)#not found
					list(GET AN_OPTION 1 var_value)
					list(GET AN_OPTION 2 var_type)				
					set(${var_name} ${var_value} CACHE ${var_type} "${last_comment}")
				endif()
			else()#match is OK this is a comment line
				set(last_comment "${COMMENT}")
			endif()
		endif()
	endforeach()
	
	
	#removing temporary files containing cache entries
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/options.txt)
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/optionsDEBUG.txt)
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/optionsRELEASE.txt)

	return()
else()	# the build must be done in the build directory
	message(WARNING "Please run cmake in the build folder of the package ${PROJECT_NAME}")
	return()
endif(${CMAKE_BINARY_DIR} MATCHES release)

#################################################
############ Initializing variables #############
#################################################
reset_cached_variables()
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

if(${CMAKE_BUILD_TYPE} MATCHES Release)
	set(${PROJECT_NAME}_ADDRESS ${address} CACHE INTERNAL "")
	set(${PROJECT_NAME}_CATEGORIES CACHE INTERNAL "")
	# references to package binaries version available must be reset
	foreach(ref_version IN ITEMS ${${PROJECT_NAME}_REFERENCES})
		foreach(ref_system IN ITEMS ${${PROJECT_NAME}_REFERENCE_${ref_version}})
			set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_system} CACHE INTERNAL "")
			set(${PROJECT_NAME}_REFERENCE_${ref_version}_${ref_system}_DEBUG CACHE INTERNAL "")
		endforeach()
		set(${PROJECT_NAME}_REFERENCE_${ref_version} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_REFERENCES CACHE INTERNAL "")
	
endif()

#################################################
############ MANAGING generic paths #############
#################################################
set(PACKAGE_BINARY_INSTALL_DIR ${WORKSPACE_DIR}/install CACHE INTERNAL "")
set(EXTERNAL_PACKAGE_BINARY_INSTALL_DIR ${WORKSPACE_DIR}/external CACHE INTERNAL "")
set(${PROJECT_NAME}_INSTALL_PATH ${PACKAGE_BINARY_INSTALL_DIR}/${PROJECT_NAME} CACHE INTERNAL "")
set(CMAKE_INSTALL_PREFIX ${${PROJECT_NAME}_INSTALL_PATH})

endmacro(declare_Package)


############################################################################
################## setting currently developed version number ##############
############################################################################
function(set_Current_Version major minor patch)

	set (${PROJECT_NAME}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH} CACHE INTERNAL "")
	message(STATUS "version currently built = " ${${PROJECT_NAME}_VERSION})

	#################################################
	############ MANAGING install paths #############
	#################################################
	if(USE_LOCAL_DEPLOYMENT)
		set(${PROJECT_NAME}_DEPLOY_PATH own-${${PROJECT_NAME}_VERSION} CACHE INTERNAL "")
	else(USE_LOCAL_DEPLOYMENT)
		set(${PROJECT_NAME}_DEPLOY_PATH ${${PROJECT_NAME}_VERSION} CACHE INTERNAL "")
	endif(USE_LOCAL_DEPLOYMENT) 
	set ( ${PROJECT_NAME}_INSTALL_LIB_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_AR_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_HEADERS_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/include CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_SHARE_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/share CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_BIN_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/bin CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_RPATH_DIR ${${PROJECT_NAME}_DEPLOY_PATH}/.rpath CACHE INTERNAL "")
endfunction(set_Current_Version)

############################################################################
############### API functions for setting additionnal package info #########
############################################################################
###
function(add_Author author institution)
	set(res_string_author)	
	foreach(string_el IN ITEMS ${author})
		set(res_string_author "${res_string_author}_${string_el}")
	endforeach()
	set(res_string_instit)
	foreach(string_el IN ITEMS ${institution})
		set(res_string_instit "${res_string_instit}_${string_el}")
	endforeach()
	set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS};${res_string_author}(${res_string_instit})" CACHE INTERNAL "")
endfunction(add_Author)


###
function(add_Reference version system url url-dbg)
	set(${PROJECT_NAME}_REFERENCES ${${PROJECT_NAME}_REFERENCES} ${version} CACHE INTERNAL "")
	set(${PROJECT_NAME}_REFERENCE_${version} ${${PROJECT_NAME}_REFERENCE_${version}} ${system} CACHE INTERNAL "")
	set(${PROJECT_NAME}_REFERENCE_${version}_${system} ${url} CACHE INTERNAL "")
	set(${PROJECT_NAME}_REFERENCE_${version}_${system}_DEBUG ${url-dbg} CACHE INTERNAL "")
endfunction(add_Reference)

###
function(shadow_Repository_Address url)
	set(${PROJECT_NAME}_ADDRESS ${url} CACHE INTERNAL "")
endfunction(shadow_Repository_Address)

###
function(add_Category category_spec)
	set(${PROJECT_NAME}_CATEGORIES ${${PROJECT_NAME}_CATEGORIES} ${category_spec} CACHE INTERNAL "")
endfunction(add_Category)

##################################################################################
################################### building the package #########################
##################################################################################
macro(build_Package)

set(CMAKE_SKIP_BUILD_RPATH FALSE) # don't skip the full RPATH for the build tree
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) # when building, don't use the install RPATH already
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE) #do not use any link time info when installing

if(UNIX AND NOT APPLE)
	set(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib") #the default install rpath is the library folder of the installed package (internal libraries managed by default), name is relative to $ORIGIN to enable easy package relocation
elseif (APPLE)
	set(CMAKE_MACOSX_RPATH TRUE)
	set(CMAKE_INSTALL_RPATH "@loader_path/../lib") #the default install rpath is the library folder of the installed package (internal libraries managed by default), name is relative to @loader_path to enable easy package relocation TODO solve the BUG
endif()

#################################################################################
############ MANAGING the configuration of package dependencies #################
#################################################################################

# from here only direct dependencies have been satisfied
# 0) if there are packages to install it means that there are some unresolved required dependencies
set(INSTALL_REQUIRED FALSE)
need_Install_External_Packages(INSTALL_REQUIRED)
if(INSTALL_REQUIRED)
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		message("Getting required external package dependencies : ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX}}")
		set(INSTALLED_PACKAGES "")	
		install_Required_External_Packages("${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX}}" INSTALLED_PACKAGES)
		message("Automatically installed external packages : ${INSTALLED_PACKAGES}")
	else()
		message(FATAL_ERROR "there are some unresolved required external package dependencies : ${${PROJECT_NAME}_TOINSTALL_EXTERNAL_PACKAGES${USE_MODE_SUFFIX}}. You may download them \"by hand\" or use the required packages automatic download option")
		return()
	endif()
endif()

set(INSTALL_REQUIRED FALSE)
need_Install_Packages(INSTALL_REQUIRED)
if(INSTALL_REQUIRED)
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		message("Getting required package dependencies : ${${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX}}")
		set(INSTALLED_PACKAGES "")	
		install_Required_Packages("${${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX}}" INSTALLED_PACKAGES)
		message("Automatically installed packages : ${INSTALLED_PACKAGES}")
	else()
		message(FATAL_ERROR "there are some unresolved required package dependencies : ${${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX}}. You may download them \"by hand\" or use the required packages automatic download option")
		return()
	endif()
endif()

if(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
	# 1) resolving required packages versions (different versions can be required at the same time)
	# we get the set of all packages undirectly required
	foreach(dep_pack IN ITEMS ${${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX}})
		resolve_Package_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE})
	endforeach()
	#here every package dependency should have been resolved OR ERROR
	
	# 2) if all version are OK resolving all necessary variables (CFLAGS, LDFLAGS and include directories)
	foreach(dep_pack IN ITEMS ${${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX}})
		configure_Package_Build_Variables(${dep_pack} ${CMAKE_BUILD_TYPE})
	endforeach()

	# 3) when done resolving runtime dependencies for all used package (direct or undirect)
	foreach(dep_pack IN ITEMS ${${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX}})
		resolve_Package_Runtime_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE})
	endforeach()
endif()
#################################################
############ MANAGING the BUILD #################
#################################################
# recursive call into subdirectories to build/install/test the package
add_subdirectory(src)
add_subdirectory(apps)
if(BUILD_AND_RUN_TESTS AND ${CMAKE_BUILD_TYPE} MATCHES Release)
	enable_testing()
	add_subdirectory(test)
endif()
add_subdirectory(share)
##########################################################
############ MANAGING non source files ###################
##########################################################
generate_License_File() # generating/installing the file containing license info about the package
generate_Find_File() # generating/installing the generic cmake find file for the package

generate_Use_File() #generating the version specific cmake "use" file and the rule to install it
generate_API() #generating the API documentation configuration file and the rule to launche doxygen and install the doc
clean_Install_Dir() #cleaning the install directory (include/lib/bin folders) if there are files that are removed  
generate_Info_File() #generating a cmake "info" file containing info about source code of components 

if(${CMAKE_BUILD_TYPE} MATCHES Release)
	#installing the share/cmake folder (may contain specific find scripts for external libs used by the package)
	install(DIRECTORY ${CMAKE_SOURCE_DIR}/share/cmake DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})
endif()

#resolving link time dependencies for executables
foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS_APPS})
	will_be_Built(RES ${component})
	if(RES)
		resolve_Source_Component_Linktime_Dependencies(${component} ${component}_THIRD_PARTY_LINKS)
	endif()
endforeach()

#resolving runtime dependencies
foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	will_be_Built(RES ${component})
	if(RES)
		resolve_Source_Component_Runtime_Dependencies(${component} "${${component}_THIRD_PARTY_LINKS}")
	endif()
endforeach()

#################################################
##### MANAGING the SYSTEM PACKAGING #############
#################################################
# both release and debug packages are built and both must be generated+upoaded / downloaded+installed in the same time
if(GENERATE_INSTALLER)
	include(InstallRequiredSystemLibraries)
	#common infos	
	set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
	generate_Contact_String("${${PROJECT_NAME}_MAIN_AUTHOR}" "${${PROJECT_NAME}_CONTACT_MAIL}" RES_CONTACT)
	set(CPACK_PACKAGE_CONTACT "${RES_CONTACT}")
	generate_Institution_String("${${PROJECT_NAME}_DESCRIPTION}" RES_INSTITUTION)
	set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${RES_INSTITUTION}")
	set(CPACK_PACKAGE_VENDOR ${${PROJECT_NAME}_MAIN_INSTITUTION})
	set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/license.txt)
	set(CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
	set(CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
	set(CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
	set(CPACK_PACKAGE_VERSION "${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}")
	set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}/${${PROJECT_NAME}_VERSION}")
	list(APPEND CPACK_GENERATOR TGZ)

	if(APPLE)
		set(PACKAGE_SYSTEM_STRING Darwin)
	elseif(UNIX)
		set(PACKAGE_SYSTEM_STRING Linux)
	else()
		set(PACKAGE_SYSTEM_STRING)
	endif()
	if(PACKAGE_SYSTEM_STRING)
		add_custom_target(	package_install
					COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-${PACKAGE_SYSTEM_STRING}.tar.gz
					${${PROJECT_NAME}_INSTALL_PATH}/installers/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-${PACKAGE_SYSTEM_STRING}.tar.gz
					COMMENT "installing ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-${PACKAGE_SYSTEM_STRING}.tar.gz in ${${PROJECT_NAME}_INSTALL_PATH}/installers"
				)
		include(CPack)
	endif()
endif(GENERATE_INSTALLER)

###############################################################################
######### creating specific targets for easy management of the package ########
###############################################################################

if(${CMAKE_BUILD_TYPE} MATCHES Release)
	
	#copy the reference file of the package into the "references" folder of the workspace
	add_custom_target(referencing
		COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/share/Refer${PROJECT_NAME}.cmake ${WORKSPACE_DIR}/share/cmake/references
		COMMAND ${CMAKE_COMMAND} -E echo "Package references have been registered into the worskpace"
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}	
	)
	
	#licensing all files of the project 
	if(	DEFINED ${PROJECT_NAME}_LICENSE 
		AND NOT ${${PROJECT_NAME}_LICENSE} STREQUAL "")
		add_custom_target(licensing
			COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
							-DREQUIRED_PACKAGE=${PROJECT_NAME}
							-DSOURCE_DIR=${CMAKE_SOURCE_DIR}
							-DBINARY_DIR=${CMAKE_BINARY_DIR}
							-P ${WORKSPACE_DIR}/share/cmake/system/Licensing_PID_Package_Files.cmake
			VERBATIM
		)
	endif()

	# adding an uninstall command (uninstall the whole installed version)
	if(USE_LOCAL_DEPLOYMENT)
		add_custom_target(uninstall
			COMMAND ${CMAKE_COMMAND} -E  echo Uninstalling ${PROJECT_NAME} version ${${PROJECT_NAME}_VERSION} (own version)
			COMMAND ${CMAKE_COMMAND} -E  remove_directory ${WORKSPACE_DIR}/install/${PROJECT_NAME}/own-${${PROJECT_NAME}_VERSION}
			VERBATIM
		)
	else()
		add_custom_target(uninstall
			COMMAND ${CMAKE_COMMAND} -E  echo Uninstalling ${PROJECT_NAME} version ${${PROJECT_NAME}_VERSION}
			COMMAND ${CMAKE_COMMAND} -E  remove_directory ${WORKSPACE_DIR}/install/${PROJECT_NAME}/${${PROJECT_NAME}_VERSION}
			VERBATIM
		)
	endif()

	
endif()

###############################################################################
######### creating build target for easy sequencing all make commands #########
###############################################################################

#creating a global build command
if(GENERATE_INSTALLER)
	if(CMAKE_BUILD_TYPE MATCHES Release)
		
		if(BUILD_AND_RUN_TESTS)
			if(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
					COMMAND ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG}
					COMMAND ${CMAKE_MAKE_PROGRAM} doc 
					COMMAND ${CMAKE_MAKE_PROGRAM} install
					COMMAND ${CMAKE_MAKE_PROGRAM} package
					COMMAND ${CMAKE_MAKE_PROGRAM} package_install
				)
			else(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
					COMMAND ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG}
					COMMAND ${CMAKE_MAKE_PROGRAM} install
					COMMAND ${CMAKE_MAKE_PROGRAM} package
					COMMAND ${CMAKE_MAKE_PROGRAM} package_install
				)
			endif(BUILD_API_DOC) 
		else(BUILD_AND_RUN_TESTS)
			if(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
					COMMAND ${CMAKE_MAKE_PROGRAM} doc 
					COMMAND ${CMAKE_MAKE_PROGRAM} install
					COMMAND ${CMAKE_MAKE_PROGRAM} package
					COMMAND ${CMAKE_MAKE_PROGRAM} package_install
				)
			else(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
					COMMAND ${CMAKE_MAKE_PROGRAM} install
					COMMAND ${CMAKE_MAKE_PROGRAM} package
					COMMAND ${CMAKE_MAKE_PROGRAM} package_install
				)
			endif(BUILD_API_DOC)
		endif(BUILD_AND_RUN_TESTS)
	else(CMAKE_BUILD_TYPE MATCHES Release)
		add_custom_target(build 
			COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
			COMMAND ${CMAKE_MAKE_PROGRAM} install
			COMMAND ${CMAKE_MAKE_PROGRAM} package
			COMMAND ${CMAKE_MAKE_PROGRAM} package_install
		) 
	endif(CMAKE_BUILD_TYPE MATCHES Release)

else(GENERATE_INSTALLER)
	if(CMAKE_BUILD_TYPE MATCHES Release)
		if(BUILD_AND_RUN_TESTS)
			if(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
					COMMAND ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG}
					COMMAND ${CMAKE_MAKE_PROGRAM} doc 
					COMMAND ${CMAKE_MAKE_PROGRAM} install
				)
			else(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
					COMMAND ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG}
					COMMAND ${CMAKE_MAKE_PROGRAM} install
				)
			endif(BUILD_API_DOC) 
		else(BUILD_AND_RUN_TESTS)
			if(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
					COMMAND ${CMAKE_MAKE_PROGRAM} doc 
					COMMAND ${CMAKE_MAKE_PROGRAM} install
				)
			else(BUILD_API_DOC) 
				add_custom_target(build 
					COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
					COMMAND ${CMAKE_MAKE_PROGRAM} install
				)
			endif(BUILD_API_DOC)
		endif()
	else(CMAKE_BUILD_TYPE MATCHES Release)#debug
			add_custom_target(build 
				COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
				COMMAND ${CMAKE_MAKE_PROGRAM} install
			) 
	endif(CMAKE_BUILD_TYPE MATCHES Release)
endif(GENERATE_INSTALLER)

#########################################################################################################################
######### writing the global reference file for the package with all global info contained in the CMakeFile.txt #########
#########################################################################################################################
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	if(${PROJECT_NAME}_ADDRESS)
		generate_Reference_File(${CMAKE_BINARY_DIR}/share/Refer${PROJECT_NAME}.cmake) 
	endif()
endif()
#print_Component_Variables()
endmacro(build_Package)

##################################################################################
###################### declaration of a library component ########################
##################################################################################
# internal_defs : definitions that affects the implementation of the library component
# exported_defs : definitions that affects the interface of the library component
# internal_inc_dirs : additionnal include dirs (internal to package, that contains header files, e.g. like common definition between package components, that don't have to be exported since not in the interface)
# internal_links : only for executables or shared libs some internal linker flags used to build the component 
# exported_links : only for static and shared libs : some linker flags (not a library inclusion, e.g. -l<li> or full path to a lib) that must be used when linking with the component
function(declare_Library_Component c_name dirname type internal_inc_dirs internal_defs exported_defs internal_links)
set(DECLARED FALSE)
is_Declared(${c_name} DECLARED)
if(DECLARED)
	message(FATAL_ERROR "When declaring the library ${c_name} : a component with the same name is already defined")
	return()
endif()	
#indicating that the component has been declared and need to be completed
if(type STREQUAL "HEADER"
OR type STREQUAL "STATIC"
OR type STREQUAL "SHARED")
	set(${PROJECT_NAME}_${c_name}_TYPE ${type} CACHE INTERNAL "")
else()
	message(FATAL_ERROR "you must specify a type (HEADER, STATIC or SHARED) for your library")
	return()
endif()

### managing headers ###
#a library defines a folder containing one or more headers and/or subdirectories 
set(${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include/${dirname})

set(${PROJECT_NAME}_${c_name}_HEADER_DIR_NAME ${dirname} CACHE INTERNAL "")
file(	GLOB_RECURSE
	${PROJECT_NAME}_${c_name}_ALL_HEADERS_RELATIVE
	RELATIVE ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}
	"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.h"
	"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hh"
	"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hpp"
	"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hxx"
)

set(${PROJECT_NAME}_${c_name}_HEADERS ${${PROJECT_NAME}_${c_name}_ALL_HEADERS_RELATIVE} CACHE INTERNAL "")
set(${PROJECT_NAME}_${c_name}_HEADERS_SELECTION_PATTERN "^$")
foreach(header IN ITEMS ${${PROJECT_NAME}_${c_name}_HEADERS})
	set(${PROJECT_NAME}_${c_name}_HEADERS_SELECTION_PATTERN  "${header}|${${PROJECT_NAME}_${c_name}_HEADERS_SELECTION_PATTERN}")
endforeach()

install(DIRECTORY ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING REGEX "${${PROJECT_NAME}_${c_name}_HEADERS_SELECTION_PATTERN}")

if(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "HEADER")
	#collect sources for the library
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/${dirname})

	## 1) collect info about the sources for registration purpose
	#register the source dir
	if(${CMAKE_BUILD_TYPE} MATCHES Release)	
		set(${PROJECT_NAME}_${c_name}_SOURCE_DIR ${dirname} CACHE INTERNAL "")
	
		file(	GLOB_RECURSE 
			${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE
			RELATIVE ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR} 
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.c"
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cc"
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cpp"
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cxx"
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.h"
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hpp"
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hh"
			"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hxx"
		)
		set(${PROJECT_NAME}_${c_name}_SOURCE_CODE ${${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE} CACHE INTERNAL "")
		
	endif()
	## 2) collect sources for build process
	file(	GLOB_RECURSE 
		${PROJECT_NAME}_${c_name}_ALL_SOURCES
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.c"
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cc"
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cpp"
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cxx"
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.h"
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hpp"
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hh"
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hxx"
		"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.h"
		"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hh"
		"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hpp"
		"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hxx"
	)
	
	#defining shared and/or static targets for the library and
	#adding the targets to the list of installed components when make install is called
	if(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "STATIC")
		add_library(${c_name}${INSTALL_NAME_SUFFIX} STATIC ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
		install(TARGETS ${c_name}${INSTALL_NAME_SUFFIX}
			ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_AR_PATH}
		)

	elseif(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "SHARED")
		add_library(${c_name}${INSTALL_NAME_SUFFIX} SHARED ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
		
		install(TARGETS ${c_name}${INSTALL_NAME_SUFFIX}
			LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}
		)
		#setting the default rpath for the target (rpath target a specific folder of the binary package for the installed version of the component)
		if(APPLE)
			set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_RPATH};@loader_path/../.rpath/${c_name}${INSTALL_NAME_SUFFIX}") #the library targets a specific folder that contains symbolic links to used shared libraries
		elseif(UNIX)
			set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_RPATH};\$ORIGIN/../.rpath/${c_name}${INSTALL_NAME_SUFFIX}") #the library targets a specific folder that contains symbolic links to used shared libraries
		else()
			message(FATAL_ERROR "only UNIX (inclusing MACOSX) shared libraries are handled")
		endif()

		if(NOT internal_links STREQUAL "") #usefull only when trully linking so only beneficial to shared libs
			target_link_libraries(${c_name}${INSTALL_NAME_SUFFIX} ${internal_links})
		endif()
	endif()
	manage_Additional_Component_Internal_Flags(${c_name} "${internal_inc_dirs}" "${internal_defs}")
	manage_Additional_Component_Exported_Flags(${c_name} "${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}" "${exported_defs}" "")
	# registering the binary name
	get_target_property(LIB_NAME ${c_name}${INSTALL_NAME_SUFFIX} LOCATION)
	get_filename_component(LIB_NAME ${LIB_NAME} NAME)
	set(${PROJECT_NAME}_${c_name}_BINARY_NAME${USE_MODE_SUFFIX} ${LIB_NAME} CACHE INTERNAL "") #exported include directories
else()#simply creating a "fake" target for header only library
	if(APPLE)
		file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/fake_for_macosx.cpp "void fake_function(){}")#used for clang ar tool to work properly
		file(	GLOB_RECURSE
			${PROJECT_NAME}_${c_name}_ALL_SOURCES
			"${CMAKE_CURRENT_BINARY_DIR}/fake_for_macosx.cpp"
			"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.h"
			"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hh"
			"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hpp"
			"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hxx"
		)

	elseif(UNIX)
		file(	GLOB_RECURSE
			${PROJECT_NAME}_${c_name}_ALL_SOURCES
			"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.h"
			"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hh"
			"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hpp"
			"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hxx"
		)
	endif()

	add_library(${c_name}${INSTALL_NAME_SUFFIX} STATIC ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
	set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES LINKER_LANGUAGE CXX) #to allow CMake to know the linker to use (will be called but create en empty static library) for the "fake library" target 	
	manage_Additional_Component_Exported_Flags(${c_name} "${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}" "${exported_defs}" "")
endif()

# registering exported flags for all kinds of libs
set(${PROJECT_NAME}_${c_name}_DEFS${USE_MODE_SUFFIX} "${exported_defs}" CACHE INTERNAL "") #exported defs
set(${PROJECT_NAME}_${c_name}_LINKS${USE_MODE_SUFFIX} "" CACHE INTERNAL "") #exported links
set(${PROJECT_NAME}_${c_name}_INC_DIRS${USE_MODE_SUFFIX} "" CACHE INTERNAL "") #exported include directories (not useful to set it there since they will be exported "manually")

#updating global variables of the CMake process	
set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_LIBS "${${PROJECT_NAME}_COMPONENTS_LIBS};${c_name}" CACHE INTERNAL "")
# global variable to know that the component has been declared (must be reinitialized at each run of cmake)
mark_As_Declared(${c_name})
endfunction(declare_Library_Component)


##################################################################################
################# declaration of an application component ########################
##################################################################################
# internal_defs : definitions that affects the implementation of the application component
# internal_link_flags : additionnal linker flags that affects required to link the application component
# internal_inc_dirs : additionnal include dirs (internal to project, that contains header files, e.g. common definition between components that don't have to be exported)
function(declare_Application_Component c_name dirname type internal_inc_dirs internal_defs internal_link_flags)
set(DECLARED FALSE)
is_Declared(${c_name} DECLARED)
if(DECLARED)
	message(FATAL_ERROR "A component with the same name ${c_name} is already defined")
	return()
endif()

if(	type STREQUAL "TEST" 
	OR type STREQUAL "APP"
	OR type STREQUAL "EXAMPLE")
	set(${PROJECT_NAME}_${c_name}_TYPE ${type} CACHE INTERNAL "")
else() #a simple application by default
	message(FATAL_ERROR "you have to set a type name (TEST, APP, EXAMPLE) for the application component ${c_name}")
	return()
endif()	
# specifically managing examples 	
if(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "EXAMPLE") 
	add_Example_To_Doc(${c_name}) #examples are added to the doc to be referenced		
	if(NOT ${BUILD_EXAMPLES}) #examples are not built so no need to continue
		mark_As_Declared(${c_name})		
		return()
	endif()
elseif(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "TEST")
	if(NOT ${BUILD_AND_RUN_TESTS}) #tests are not built so no need to continue
		mark_As_Declared(${c_name})
		return()
	endif()
endif()

#managing sources for the application

if(	${PROJECT_NAME}_${c_name}_TYPE STREQUAL "APP"
	OR ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "EXAMPLE")	
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/apps/${dirname} CACHE INTERNAL "")
elseif(	${PROJECT_NAME}_${c_name}_TYPE STREQUAL "TEST")
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/test/${dirname} CACHE INTERNAL "")
endif()

file(	GLOB_RECURSE 
	${PROJECT_NAME}_${c_name}_ALL_SOURCES 
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.c" 
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cc" 
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cpp"
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cxx"
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.h" 
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hpp" 
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hh"
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hxx"
)

#defining the target to build the application
add_executable(${c_name}${INSTALL_NAME_SUFFIX} ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
manage_Additional_Component_Internal_Flags(${c_name} "${internal_inc_dirs}" "${internal_defs}")
manage_Additional_Component_Exported_Flags(${c_name} "" "" "${internal_link_flags}")

if(NOT ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "TEST")
	# adding the application to the list of installed components when make install is called (not for test applications)
	install(TARGETS ${c_name}${INSTALL_NAME_SUFFIX} 
		RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
	)
	#setting the default rpath for the target	
	if(UNIX AND NOT APPLE)
		set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_RPATH};\$ORIGIN/../.rpath/${c_name}${INSTALL_NAME_SUFFIX}") #the application targets a specific folder that contains symbolic links to used shared libraries
	elseif(APPLE)
		set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_RPATH};@loader_path/../.rpath/${c_name}${INSTALL_NAME_SUFFIX}") #the application targets a specific folder that contains symbolic links to used shared libraries
	endif()
	install(DIRECTORY DESTINATION ${${PROJECT_NAME}_INSTALL_RPATH_DIR}/${c_name}${INSTALL_NAME_SUFFIX})#create the folder that will contain symbolic links to shared libraries used by the component (will allow full relocation of components runtime dependencies at install time)
	# NB : tests do not need to be relocatable since they are purely local
endif()

#registering source code for the component
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	file(	GLOB_RECURSE 
		${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE
		RELATIVE ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.c" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cc" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cpp"
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cxx"
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.h" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hpp" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hh"
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hxx"
	)
	set(${PROJECT_NAME}_${c_name}_SOURCE_CODE ${${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_SOURCE_DIR ${dirname} CACHE INTERNAL "")
endif()

# registering exported flags for all kinds of apps => empty variables since applications export no flags
set(${PROJECT_NAME}_${c_name}_DEFS${USE_MODE_SUFFIX} "" CACHE INTERNAL "")
set(${PROJECT_NAME}_${c_name}_LINKS${USE_MODE_SUFFIX} "" CACHE INTERNAL "")
set(${PROJECT_NAME}_${c_name}_INC_DIRS${USE_MODE_SUFFIX} "" CACHE INTERNAL "") #exported include directories
get_target_property(EXE_NAME ${c_name}${INSTALL_NAME_SUFFIX} LOCATION)
get_filename_component(EXE_NAME ${EXE_NAME} NAME)
set(${PROJECT_NAME}_${c_name}_BINARY_NAME${USE_MODE_SUFFIX} ${EXE_NAME} CACHE INTERNAL "") #name of the executable

#updating global variables of the CMake process	
set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_APPS "${${PROJECT_NAME}_COMPONENTS_APPS};${c_name}" CACHE INTERNAL "")
# global variable to know that the component has been declared  (must be reinitialized at each run of cmake)
mark_As_Declared(${c_name})
endfunction(declare_Application_Component)

###
function(mark_As_Declared component)
set(${PROJECT_NAME}_DECLARED_COMPS ${${PROJECT_NAME}_DECLARED_COMPS} ${component} CACHE INTERNAL "")
endfunction(mark_As_Declared)

###
function(is_Declared component RES)
list(FIND ${PROJECT_NAME}_DECLARED_COMPS ${component} INDEX)
if(INDEX EQUAL -1)
	set(${RES} FALSE PARENT_SCOPE)
else()
	set(${RES} TRUE PARENT_SCOPE)
endif()

endfunction(is_Declared)

###
function(reset_Declared)
set(${PROJECT_NAME}_DECLARED_COMPS CACHE INTERNAL "")
endfunction(reset_Declared)

##################################################################################
####### specifying a dependency between the current package and another one ######
### global dependencies between packages (the system package is considered #######
###### as external but requires no additionnal info (default system folders) ##### 
### these functions are to be used after a find_package command. #################
##################################################################################
function(declare_Package_Dependency dep_package version exact list_of_components)
# ${PROJECT_NAME}_DEPENDENCIES				# packages required by current package
# ${PROJECT_NAME}__DEPENDENCY_${dep_package}_VERSION		# version constraint for package ${dep_package}   required by ${PROJECT_NAME}  
# ${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION_EXACT	# TRUE if exact version is required
# ${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS	# list of composants of ${dep_package} used by current package
	# the package is necessarily required at that time
	set(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX}} ${dep_package} CACHE INTERNAL "")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} ${version} CACHE INTERNAL "")

 	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION_EXACT${USE_MODE_SUFFIX} ${exact} CACHE INTERNAL "")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}} ${list_of_components} CACHE INTERNAL "")
	
	# managing automatic install process if needed 	
	if(NOT ${dep_package}_FOUND)#testing if the package has been previously found or not
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)#testing if there is automatic install activated
			list(FIND ${PROJECT_NAME}_TOINSTALL_PACKAGES${USE_MODE_SUFFIX} ${dep_package} INDEX)
			if(INDEX EQUAL -1)
			#if the package where not specified as REQUIRED in the find_package call, we face a case of conditional dependency => the package has not been registered as "to install" while now we know it must be installed
				if(version)
					add_To_Install_Package_Specification(${dep_package} "${version}" ${exact})
				else()
					add_To_Install_Package_Specification(${dep_package} "" FALSE)
				endif()
			endif()
		endif()
	endif()
endfunction(declare_Package_Dependency)

### declare external dependancies
function(declare_External_Package_Dependency dep_package version exact components_list)
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}} ${dep_package} CACHE INTERNAL "")
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} ${version} CACHE INTERNAL "")
	
	#HERE new way of managing external packages
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION_EXACT${USE_MODE_SUFFIX} ${exact} CACHE INTERNAL "")
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} ${components_list} CACHE INTERNAL "")
	
endfunction(declare_External_Package_Dependency)


##################################################################################
################# local dependencies between components ########################## 
### these functions are to be used after a find_package command and after ######## 
### the declaration of internal components (otherwise will not work) #############
##################################################################################

### declare internal dependancies between components of the same package ${PROJECT_NAME}
### comp_exp_defs : definitions in the interface of ${component} that conditionnate the use of ${dep_component}, if any  => definitions are exported
### comp_defs  : definitions in the implementation of ${component} that conditionnate the use of ${dep_component}, if any => definitions are not exported
### dep_defs  : definitions in the interface of ${dep_component} that must be defined when ${component} uses ${dep_component}, if any => definitions are exported if dep_component is exported
### export : if true the component export the dep_component in its interface (export is always false if component is an application)

function(declare_Internal_Component_Dependency component dep_component export comp_defs comp_exp_defs dep_defs)
#message("declare_Internal_Component_Dependency : component = ${component}, dep_component=${dep_component}, export=${export}, comp_defs=${comp_defs} comp_exp_defs=${comp_exp_defs} dep_defs=${dep_defs}")
set(COMP_WILL_BE_BUILT FALSE)
will_be_Built(COMP_WILL_BE_BUILT ${component})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()
set(DECLARED FALSE)
is_Declared(${dep_component} DECLARED)
if(NOT DECLARED)
	message(FATAL_ERROR "Problem : component ${dep_component} is not defined in current package")
endif()
#guarding depending type of involved components
is_Executable_Component(IS_EXEC_COMP ${PROJECT_NAME} ${component})	
is_Executable_Component(IS_EXEC_DEP ${PROJECT_NAME} ${dep_component})
is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})
if(IS_EXEC_DEP)
	message(FATAL_ERROR "an executable component (${dep_component}) cannot be a dependancy !!")
	return()
else()
	set(${PROJECT_NAME}_${c_name}_INTERNAL_EXPORT_${dep_component}${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")
	if (IS_EXEC_COMP)
		# setting compile definitions for configuring the target
		fill_Component_Target_With_Internal_Dependency(${component} ${dep_component} FALSE "${comp_defs}" "" "${dep_defs}")
		
	elseif(IS_BUILT_COMP)
		#prepare the dependancy export
		if(export)
			set(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${dep_component}${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		endif()
		configure_Install_Variables(${component} ${export} "" "${dep_defs}" "${comp_exp_defs}" "" "")

		# setting compile definitions for configuring the target
		fill_Component_Target_With_Internal_Dependency(${component} ${dep_component} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
		
	elseif(	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
		#prepare the dependancy export
		set(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${dep_component}${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "") #export is necessarily true for a pure header library
		configure_Install_Variables(${component} TRUE "" "${dep_defs}" "${comp_exp_defs}" "" "")
		#NEW		
		# setting compile definitions for configuring the "fake" target
		fill_Component_Target_With_Internal_Dependency(${component} ${dep_component} TRUE "" "${comp_exp_defs}"  "${dep_defs}")

	else()
		message (FATAL_ERROR "unknown type (${${PROJECT_NAME}_${component}_TYPE}) for component ${component}")
		return()
	endif()
	# include directories and links do not require to be added 
	# declare the internal dependency
	set(	${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} 
		${${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}} ${dep_component}
		CACHE INTERNAL "")
endif()
endfunction(declare_Internal_Component_Dependency)


### declare package dependancies between components of two packages ${PROJECT_NAME} and ${dep_package}
### comp_exp_defs : definitions in the interface of ${component} that conditionnate the use of ${dep_component}, if any => definitions are exported
### comp_defs  : definitions in the implementation of ${component} that conditionnate the use of ${dep_component}, if any => definitions are not exported
### dep_defs  : definitions in the interface of ${dep_component} that must be defined when ${component} uses ${dep_component}, if any => definitions are exported if dep_component is exported
### export : if true the component export the dep_component in its interface (export is always false if component is an application)
function(declare_Package_Component_Dependency component dep_package dep_component export comp_defs comp_exp_defs dep_defs)
	# ${PROJECT_NAME}_${component}_DEPENDENCIES			# packages used by the component ${component} of the current package
	# ${PROJECT_NAME}_${component}_DEPENDENCY_${dep_package}_COMPONENTS	# components of package ${dep_package} used by component ${component} of current package
message("declare_Package_Component_Dependency : component = ${component}, dep_package = ${dep_package}, dep_component=${dep_component}, export=${export}, comp_defs=${comp_defs} comp_exp_defs=${comp_exp_defs} dep_defs=${dep_defs}")
will_be_Built(COMP_WILL_BE_BUILT ${component})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()

if( NOT ${dep_package}_${dep_component}_TYPE)
	message(FATAL_ERROR "Problem : ${dep_component} in package ${dep_package} is not defined")
endif()

set(${PROJECT_NAME}_${c_name}_EXPORT_${dep_package}_${dep_component} FALSE CACHE INTERNAL "")
#guarding depending type of involved components
is_Executable_Component(IS_EXEC_COMP ${PROJECT_NAME} ${component})	
is_Executable_Component(IS_EXEC_DEP ${dep_package} ${dep_component})
is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})
if(IS_EXEC_DEP)
	message(FATAL_ERROR "an executable component (${dep_component}) cannot be a dependancy !!")
	return()
else()
	if (IS_EXEC_COMP)
		# setting compile definitions for configuring the target
		fill_Component_Target_With_Package_Dependency(${component} ${dep_package} ${dep_component} FALSE "${comp_defs}" "" "${dep_defs}")
		#do not export anything

	elseif(IS_BUILT_COMP)
		#prepare the dependancy export
		if(export)
			set(${PROJECT_NAME}_${component}_EXPORT_${dep_package}_${dep_component} TRUE CACHE INTERNAL "")
		endif()
		configure_Install_Variables(${component} ${export} "" "${dep_defs}" "${comp_exp_defs}" "" "")

		# setting compile definitions for configuring the target
		fill_Component_Target_With_Package_Dependency(${component} ${dep_package} ${dep_component} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")

	elseif(	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
		#prepare the dependancy export
		set(${PROJECT_NAME}_${component}_EXPORT_${dep_package}_${dep_component} TRUE CACHE INTERNAL "") #export is necessarily true for a pure header library
		configure_Install_Variables(${component} TRUE "" "${dep_defs}" "${comp_exp_defs}" "" "")
		# setting compile definitions for configuring the "fake" target
		fill_Component_Target_With_Package_Dependency(${component} ${dep_package} ${dep_component} TRUE "" "${comp_exp_defs}" "${dep_defs}")

	else()
		message (FATAL_ERROR "unknown type (${${PROJECT_NAME}_${component}_TYPE}) for component ${component}")
		return()
	endif()

#links and include directories do not require to be added (will be found automatically)	
set(${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}}  ${dep_package} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}  ${${PROJECT_NAME}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}} ${dep_component} CACHE INTERNAL "")
endif()

endfunction(declare_Package_Component_Dependency)

### declare system (add-hoc) dependancy between a component of the current package and system components (should be used as rarely as possible, except for "true" system dependencies like math, threads, etc.). Usable only whith libraries described with -l option. 
### comp_exp_defs : definitions in the interface of ${component} that conditionnate the use of the system dependancy, if any  => definitions are exported
### comp_defs  : definitions in the implementation of ${component} that conditionnate the use of system dependancy, if any => definitions are not exported
### dep_defs  : definitions in the interface of the system dependancy that must be defined when using this system dependancy, if any => definitions are exported if dependancy is exported
### export : if true the component export the depenancy in its interface (export is always false if component is an application)
### links : links defined by the system dependancy, will be exported in any case (except by executables components)
function(declare_System_Component_Dependency component export comp_defs comp_exp_defs dep_defs static_links shared_links)
will_be_Built(COMP_WILL_BE_BUILT ${component})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()
#guarding depending type of involved components
is_Executable_Component(IS_EXEC_COMP ${PROJECT_NAME} ${component})
is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})
set(TARGET_LINKS ${static_links} ${shared_links})

if (IS_EXEC_COMP)
	# setting compile definitions for the target
	fill_Component_Target_With_External_Dependency(${component} FALSE "${comp_defs}" "" "${dep_defs}" "" "${TARGET_LINKS}")
	
elseif(IS_BUILT_COMP)
	#prepare the dependancy export
	configure_Install_Variables(${component} ${export} "" "${dep_defs}" "${comp_exp_defs}" "${static_links}" "${shared_links}")
	# setting compile definitions for the target
	fill_Component_Target_With_External_Dependency(${component} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}" "" "${TARGET_LINKS}")

elseif(	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
	#prepare the dependancy export
	configure_Install_Variables(${component} TRUE "" "${dep_defs}" "${comp_exp_defs}" "${static_links}" "${shared_links}") #export is necessarily true for a pure header library
	# setting compile definitions for the target
	fill_Component_Target_With_External_Dependency(${component} TRUE "" "${comp_exp_defs}" "${dep_defs}" "" "${TARGET_LINKS}")
else()
	message (FATAL_ERROR "unknown type (${${PROJECT_NAME}_${component}_TYPE}) for component ${component}")
endif()
endfunction(declare_System_Component_Dependency)


### declare external (add-hoc) dependancy between components of current and an external package (should be used prior to system dependencies for all dependencies that are not true system dependencies, event if installed in default systems folders)
### comp_exp_defs : definitions in the interface of ${component} that conditionnate the use of the exported dependancy, if any  => definitions are exported
### comp_defs  : definitions in the implementation of ${component} that conditionnate the use of external dependancy, if any => definitions are not exported
### dep_defs  : definitions in the interface of the external dependancy that must be defined when using this external dependancy, if any => definitions are exported if dependancy is exported
### export : if true the component export the external depenancy in its interface (export is always false if component is an application)
### inc_dirs : include directories to add to target component in order to build (these include dirs are expressed relatively) to the reference path to the external dependancy root dir
### links : libraries and linker flags. libraries path are given relative to the dep_package root dir.
function(declare_External_Component_Dependency component dep_package export inc_dirs comp_defs comp_exp_defs dep_defs static_links shared_links)
will_be_Built(COMP_WILL_BE_BUILT ${component})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()

if(NOT ${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX})
	message (FATAL_ERROR "the external package ${dep_package} is not defined !")
else()
#	if(NOT shared_links STREQUAL "") #the component has runtime dependencis with an external package
#		set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_USE_RUNTIME${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
#	endif()

	#guarding depending type of involved components
	is_Executable_Component(IS_EXEC_COMP ${PROJECT_NAME} ${component})
	is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})
	set(TARGET_LINKS ${static_links} ${shared_links})
	if (IS_EXEC_COMP)
		# setting compile definitions for the target		
		fill_Component_Target_With_External_Dependency(${component} FALSE "${comp_defs}" "" "${dep_defs}" "${inc_dirs}" "${TARGET_LINKS}")

	elseif(IS_BUILT_COMP)
		#prepare the dependancy export
		configure_Install_Variables(${component} ${export} "${inc_dirs}" "${dep_defs}" "${comp_exp_defs}" "${static_links}" "${shared_links}")
		# setting compile definitions for the target
		fill_Component_Target_With_External_Dependency(${component} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}" "${inc_dirs}" "${TARGET_LINKS}")

	elseif(	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
		#prepare the dependancy export
		configure_Install_Variables(${component} TRUE "${inc_dirs}" "${dep_defs}" "${comp_exp_defs}" "${static_links}" "${shared_links}") #export is necessarily true for a pure header library

		# setting compile definitions for the "fake" target
		fill_Component_Target_With_External_Dependency(${component} TRUE "" "${comp_exp_defs}" "${dep_defs}" "${inc_dirs}" "${TARGET_LINKS}")

	else()
		message (FATAL_ERROR "unknown type (${${PROJECT_NAME}_${component}_TYPE}) for component ${component}")
	endif()
endif()
endfunction(declare_External_Component_Dependency)

##################################################################################
############# auxiliary package management internal functions and macros #########
##################################################################################

### printing variables for components in the package ################
macro(print_Component component)
	message("COMPONENT : ${component}${INSTALL_NAME_SUFFIX}")
	message("INTERFACE : ")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_INCLUDE_DIRECTORIES)
		message("includes of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_COMPILE_DEFINITIONS)
		message("defs of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} LINK_INTERFACE_LIBRARIES)
		message("libraries of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")		
		
	message("IMPLEMENTATION :")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INCLUDE_DIRECTORIES)
		message("includes of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} COMPILE_DEFINITIONS)
		message("defs of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} LINK_LIBRARIES)
		message("libraries of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
endmacro(print_Component)

macro(print_Component_Variables)
	message("components of package ${PROJECT_NAME} are :" ${${PROJECT_NAME}_COMPONENTS})
	message("libraries : " ${${PROJECT_NAME}_COMPONENTS_LIBS})
	message("applications : " ${${PROJECT_NAME}_COMPONENTS_APPS})

	foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
		print_Component(${component})	
	endforeach()
endmacro(print_Component_Variables)


### generating the license of the package
function(generate_License_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	if(	DEFINED ${PROJECT_NAME}_LICENSE 
		AND NOT ${${PROJECT_NAME}_LICENSE} STREQUAL "")
	
		find_file(	LICENSE   
				"License${${PROJECT_NAME}_LICENSE}.cmake"
				PATH "${WORKSPACE_DIR}/share/cmake/system"
				NO_DEFAULT_PATH
			)
		set(LICENSE ${LICENSE} CACHE INTERNAL "")
		
		if(LICENSE_IN-NOTFOUND)
			message(WARNING "license configuration file for ${${PROJECT_NAME}_LICENSE} not found in workspace, license file will not be generated")
		else(LICENSE_IN-NOTFOUND)
			foreach(author IN ITEMS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS})
				generate_Full_Author_String(${author} STRING_TO_APPEND)
				set(${PROJECT_NAME}_AUTHORS_LIST "${${PROJECT_NAME}_AUTHORS_LIST} ${STRING_TO_APPEND}")
			endforeach()
			include(${WORKSPACE_DIR}/share/cmake/licenses/License${${PROJECT_NAME}_LICENSE}.cmake)
			file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
			install(FILES ${CMAKE_SOURCE_DIR}/license.txt DESTINATION ${${PROJECT_NAME}_DEPLOY_PATH})
			file(WRITE ${CMAKE_BINARY_DIR}/share/file_header_comment.txt.in ${LICENSE_HEADER_FILE_DESCRIPTION})
		endif(LICENSE_IN-NOTFOUND)
	endif()
endif()
endfunction(generate_License_File)


### generating the Find<package>.cmake file of the package
function(generate_Find_File)
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	# generating/installing the generic cmake find file for the package 
	configure_file(${WORKSPACE_DIR}/share/cmake/patterns/FindPackage.cmake.in ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake @ONLY)
	install(FILES ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake DESTINATION ${WORKSPACE_DIR}/share/cmake/find) #install in the worskpace cmake directory which contains cmake find modules
endif()
endfunction(generate_Find_File)

### generating the Use<package>-<version>.cmake file for the current package version
macro(generate_Use_File)
create_Use_File()
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	install(	FILES ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake 
			DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH}
	)
endif()
endmacro(generate_Use_File)

### generating the Info<package>.cmake file for the current package
macro(generate_Info_File)
create_Info_File()
endmacro(generate_Info_File)

### configure variables exported by component that will be used to generate the package cmake use file
function (configure_Install_Variables component export include_dirs dep_defs exported_defs static_links shared_links)
#message("configure_Install_Variables component=${component} export=${export} include_dirs=${include_dirs} dep_defs=${dep_defs} exported_defs=${exported_defs} static_links=${static_links} shared_links=${shared_links}")
# configuring the export
if(export) # if dependancy library is exported then we need to register its dep_defs and include dirs in addition to component interface defs
	if(	NOT dep_defs STREQUAL "" 
		OR NOT exported_defs  STREQUAL "")	
		set(	${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}} 
			${exported_defs} ${dep_defs}
			CACHE INTERNAL "")
	endif()
	if(NOT include_dirs STREQUAL "")
		set(	${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} 
			${${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX}} 
			${include_dirs}
			CACHE INTERNAL "")
	endif()
	# links are exported since we will need to resolve symbols in the third party components that will the use the component 	
	if(NOT shared_links STREQUAL "")
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}			
			${shared_links}			
			CACHE INTERNAL "")
	endif()
	if(NOT static_links STREQUAL "")
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}			
			${static_links}			
			CACHE INTERNAL "")
	endif()

else() # otherwise no need to register them since no more useful
	if(NOT exported_defs STREQUAL "") 
		#just add the exported defs of the component not those of the dependency
		set(	${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX}} 
			${exported_defs}
			CACHE INTERNAL "")
	endif()
	if(NOT static_links STREQUAL "") #static links are exported if component is not a shared lib
		if (	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER" 
			OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "STATIC"
		)
		set(	${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX}}			
			${static_links}			
			CACHE INTERNAL "")
		endif()
	endif()
	if(NOT shared_links STREQUAL "")#shared links are privates (not exported) -> these links are used to process executables linking
		set(	${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX}
			${${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX}}			
			${shared_links}
			CACHE INTERNAL "")
	endif()
endif()
endfunction(configure_Install_Variables)

### to know if the component is an application
function(is_Executable_Component ret_var package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	)
	set(${ret_var} TRUE PARENT_SCOPE)
else()
	set(${ret_var} FALSE PARENT_SCOPE)
endif()
endfunction(is_Executable_Component)

### to know if component will be built
function (is_Built_Component ret_var  package component)
if (	${package}_${component}_TYPE STREQUAL "APP"
	OR ${package}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${package}_${component}_TYPE STREQUAL "TEST"
	OR ${package}_${component}_TYPE STREQUAL "STATIC"
	OR ${package}_${component}_TYPE STREQUAL "SHARED"
)
	set(${ret_var} TRUE PARENT_SCOPE)
else()
	set(${ret_var} FALSE PARENT_SCOPE)
endif()
endfunction(is_Built_Component)

### 
function(will_be_Built result component)
set(DECLARED FALSE)
is_Declared(${component} DECLARED)
if(NOT DECLARED)
	set(${result} FALSE PARENT_SCOPE)
	message(FATAL_ERROR "component ${component} does not exist")
elseif( (${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST" AND NOT BUILD_AND_RUN_TESTS)
	OR (${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE" AND NOT BUILD_EXAMPLES))
	set(${result} FALSE PARENT_SCOPE)
else()
	set(${result} TRUE PARENT_SCOPE)
endif()
endfunction(will_be_Built)


### adding source code of the example components to the API doc
function(add_Example_To_Doc c_name)
	file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/share/examples/)
	file(COPY ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR} DESTINATION ${PROJECT_BINARY_DIR}/share/examples/)
endfunction(add_Example_To_Doc c_name)

### generating API documentation for the package
function(generate_API)

if(${CMAKE_BUILD_TYPE} MATCHES Release) # if in release mode we generate the doc

if(NOT BUILD_API_DOC)
	return()
endif()

#finding doxygen tool and doxygen configuration file 
find_package(Doxygen)
if(NOT DOXYGEN_FOUND)
	message(WARNING "Doxygen not found please install it to generate the API documentation")
	return()
endif(NOT DOXYGEN_FOUND)
find_file(DOXYFILE_IN   "Doxyfile.in"
			PATHS "${CMAKE_SOURCE_DIR}/share/doxygen"
			NO_DEFAULT_PATH
	)
set(DOXYFILE_IN ${DOXYFILE_IN} CACHE INTERNAL "")
if(DOXYFILE_IN-NOTFOUND)
	message(WARNING "Doxyfile not found in the share folder of your package !! Getting the standard doxygen template file from workspace ... ")
	find_file(GENERIC_DOXYFILE_IN   "Doxyfile.in"
					PATHS "${WORKSPACE_DIR}/share/cmake/patterns"
					NO_DEFAULT_PATH
		)
	set(GENERIC_DOXYFILE_IN ${GENERIC_DOXYFILE_IN} CACHE INTERNAL "")
	if(GENERIC_DOXYFILE_IN-NOTFOUND)
		message(WARNING "No Template file found in ${WORKSPACE_DIR}/share/cmake/patterns/, skipping documentation generation !!")		
	else(GENERIC_DOXYFILE_IN-NOTFOUND)
		file(COPY ${WORKSPACE_DIR}/share/cmake/patterns/Doxyfile.in ${CMAKE_SOURCE_DIR}/share/doxygen)
		message(STATUS "Template file found in ${WORKSPACE_DIR}/share/cmake/patterns/ and copied to your package, you can now modify it")		
	endif(GENERIC_DOXYFILE_IN-NOTFOUND)
endif(DOXYFILE_IN-NOTFOUND)

if(DOXYGEN_FOUND AND (NOT DOXYFILE_IN-NOTFOUND OR NOT GENERIC_DOXYFILE_IN-NOTFOUND)) #we are able to generate the doc
	# general variables
	set(DOXYFILE_SOURCE_DIRS "${CMAKE_SOURCE_DIR}/include/")
	set(DOXYFILE_PROJECT_NAME ${PROJECT_NAME})
	set(DOXYFILE_PROJECT_VERSION ${${PROJECT_NAME}_VERSION})
	set(DOXYFILE_OUTPUT_DIR ${CMAKE_BINARY_DIR}/share/doc)
	set(DOXYFILE_HTML_DIR html)
	set(DOXYFILE_LATEX_DIR latex)

	### new targets ###
	# creating the specific target to run doxygen
	add_custom_target(doxygen
		${DOXYGEN_EXECUTABLE} ${CMAKE_BINARY_DIR}/share/Doxyfile
		DEPENDS ${CMAKE_BINARY_DIR}/share/Doxyfile
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
		COMMENT "Generating API documentation with Doxygen" VERBATIM
	)

	# target to clean installed doc
	set_property(DIRECTORY
		APPEND PROPERTY
		ADDITIONAL_MAKE_CLEAN_FILES
		"${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_HTML_DIR}")

	# creating the doc target
	get_target_property(DOC_TARGET doc TYPE)
	if(NOT DOC_TARGET)
		add_custom_target(doc)
	endif(NOT DOC_TARGET)

	add_dependencies(doc doxygen)

	### end new targets ###

	### doxyfile configuration ###

	# configuring doxyfile for html generation 
	set(DOXYFILE_GENERATE_HTML "YES")

	# configuring doxyfile to use dot executable if available
	set(DOXYFILE_DOT "NO")
	if(DOXYGEN_DOT_EXECUTABLE)
		set(DOXYFILE_DOT "YES")
	endif()

	# configuring doxyfile for latex generation 
	set(DOXYFILE_PDFLATEX "NO")

	if(BUILD_LATEX_API_DOC)
		# target to clean installed doc
		set_property(DIRECTORY
			APPEND PROPERTY
			ADDITIONAL_MAKE_CLEAN_FILES
			"${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_LATEX_DIR}")
		set(DOXYFILE_GENERATE_LATEX "YES")
		find_package(LATEX)
		find_program(DOXYFILE_MAKE make)
		mark_as_advanced(DOXYFILE_MAKE)
		if(LATEX_COMPILER AND MAKEINDEX_COMPILER AND DOXYFILE_MAKE)
			if(PDFLATEX_COMPILER)
				set(DOXYFILE_PDFLATEX "YES")
			endif(PDFLATEX_COMPILER)

			add_custom_command(TARGET doxygen
				POST_BUILD
				COMMAND "${DOXYFILE_MAKE}"
				COMMENT	"Running LaTeX for Doxygen documentation in ${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_LATEX_DIR}..."
				WORKING_DIRECTORY "${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_LATEX_DIR}")
		else(LATEX_COMPILER AND MAKEINDEX_COMPILER AND DOXYFILE_MAKE)
			set(DOXYGEN_LATEX "NO")
		endif(LATEX_COMPILER AND MAKEINDEX_COMPILER AND DOXYFILE_MAKE)

	else(BUILD_LATEX_API_DOC)
		set(DOXYFILE_GENERATE_LATEX "NO")
	endif(BUILD_LATEX_API_DOC)

	#configuring the Doxyfile.in file to generate a doxygen configuration file
	configure_file(${CMAKE_SOURCE_DIR}/share/doxygen/Doxyfile.in ${CMAKE_BINARY_DIR}/share/Doxyfile @ONLY)
	### end doxyfile configuration ###

	### installing documentation ###
	install(DIRECTORY ${CMAKE_BINARY_DIR}/share/doc DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})

	### end installing documentation ###

endif()
	set(BUILD_API_DOC OFF FORCE)
endif()
endfunction(generate_API)


### configure the target with exported flags (cflags and ldflags)
function(manage_Additional_Component_Exported_Flags component_name inc_dirs defs links)
#message("manage_Additional_Component_Exported_Flags comp=${component_name} include dirs=${inc_dirs} defs=${defs} links=${links}")
# managing compile time flags (-I<path>)
if(inc_dirs AND NOT inc_dirs STREQUAL "")
	foreach(dir IN ITEMS ${inc_dirs})
		target_include_directories(${component_name}${INSTALL_NAME_SUFFIX} PUBLIC "${dir}")
	endforeach()
endif()

# managing compile time flags (-D<preprocessor_defs>)
if(defs AND NOT defs STREQUAL "")
	foreach(def IN ITEMS ${defs})
		target_compile_definitions(${component_name}${INSTALL_NAME_SUFFIX} PUBLIC "${def}")
	endforeach()
endif()

# managing link time flags
if(links AND NOT links STREQUAL "")
	foreach(link IN ITEMS ${links})
		target_link_libraries(${component_name}${INSTALL_NAME_SUFFIX} ${link})
	endforeach()
endif()
endfunction(manage_Additional_Component_Exported_Flags)


### configure the target with internal flags (cflags only)
function(manage_Additional_Component_Internal_Flags component_name inc_dirs defs)
#message("manage_Additional_Component_Internal_Flags name=${component_name} include dirs=${inc_dirs} defs=${defs}")
# managing compile time flags
if(inc_dirs AND NOT inc_dirs STREQUAL "")
	foreach(dir IN ITEMS ${inc_dirs})
		target_include_directories(${component_name}${INSTALL_NAME_SUFFIX} PRIVATE "${dir}")
	endforeach()
endif()

# managing compile time flags
if(defs AND NOT defs STREQUAL "")
	foreach(def IN ITEMS ${defs})
		target_compile_definitions(${component_name}${INSTALL_NAME_SUFFIX} PRIVATE "${def}")
	endforeach()
endif()
endfunction(manage_Additional_Component_Internal_Flags)

function(manage_Additionnal_Component_Inherited_Flags component dep_component export)
	if(export)
		set(export_string "PUBLIC")
	else()
		set(export_string "PRIVATE")
	endif()
	target_include_directories(	${component}${INSTALL_NAME_SUFFIX} 
					${export_string} 
					$<TARGET_PROPERTY:${dep_component}${INSTALL_NAME_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>
				)
	target_compile_definitions(	${component}${INSTALL_NAME_SUFFIX} 
					${export_string} 
					$<TARGET_PROPERTY:${dep_component}${INSTALL_NAME_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>
				)
endfunction(manage_Additionnal_Component_Inherited_Flags)

### configure the target to link with another target issued from a component of the same package
function (fill_Component_Target_With_Internal_Dependency component dep_component export comp_defs comp_exp_defs dep_defs)
is_Executable_Component(DEP_IS_EXEC ${PROJECT_NAME} ${dep_component})
if(NOT DEP_IS_EXEC)#the required internal component is a library 
	if(export)	
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_exp_defs} ${dep_defs})
		manage_Additional_Component_Internal_Flags(${component} "" "${comp_defs}")				
		manage_Additional_Component_Exported_Flags(${component} "" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${dep_component}${INSTALL_NAME_SUFFIX}")
		manage_Additionnal_Component_Inherited_Flags(${component} ${dep_component} TRUE)		
	else()
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${dep_defs})
		manage_Additional_Component_Internal_Flags(${component} "" "${${PROJECT_NAME}_${component}_TEMP_DEFS}")
		manage_Additional_Component_Exported_Flags(${component} "" "${comp_exp_defs}" "${dep_component}${INSTALL_NAME_SUFFIX}")
		manage_Additionnal_Component_Inherited_Flags(${component} ${dep_component} FALSE)
	endif()
else()
	message(FATAL_ERROR "Executable component ${dep_c_name} cannot be a dependency for component ${component}")	
endif()

endfunction(fill_Component_Target_With_Internal_Dependency)


### configure the target to link with another component issued from another package
function (fill_Component_Target_With_Package_Dependency component dep_package dep_component export comp_defs comp_exp_defs dep_defs)
#message("DEBUG fill_Component_Target_With_Package_Dependency component=${component} dep_package=${dep_package} dep_component=${dep_component} export=${export} comp_defs=${comp_defs} comp_exp_defs=${comp_exp_defs} dep_defs=${dep_defs}")
is_Executable_Component(DEP_IS_EXEC ${dep_package} ${dep_component})
if(NOT DEP_IS_EXEC)#the required package component is a library
	
	if(export)
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_exp_defs} ${dep_defs})

		if(${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX})
			list(APPEND ${PROJECT_NAME}_${component}_TEMP_DEFS ${${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX}})
		endif()		
		manage_Additional_Component_Internal_Flags(${component} "" "${comp_defs}")
		manage_Additional_Component_Exported_Flags(${component} "${${dep_package}_${dep_component}_INCLUDE_DIRS${USE_MODE_SUFFIX}}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${${dep_package}_${dep_component}_LIBRARIES${USE_MODE_SUFFIX}}")
	else()
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${dep_defs})
		if(${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX})
			list(APPEND ${PROJECT_NAME}_${component}_TEMP_DEFS ${${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX}})
		endif()		
		manage_Additional_Component_Internal_Flags(${component} "${${dep_package}_${dep_component}_INCLUDE_DIRS${USE_MODE_SUFFIX}}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}")
		manage_Additional_Component_Exported_Flags(${component} "" "${comp_exp_defs}" "${${dep_package}_${dep_component}_LIBRARIES${USE_MODE_SUFFIX}}")
	endif()

else()
	message(FATAL_ERROR "Executable component ${dep_component} from package ${dep_package} cannot be a dependency for component ${component}")	
endif()
endfunction(fill_Component_Target_With_Package_Dependency)


### configure the target to link with an external dependancy
function(fill_Component_Target_With_External_Dependency component export comp_defs comp_exp_defs ext_defs ext_inc_dirs ext_links)
if(ext_links)
	resolve_External_Libs_Path(COMPLETE_LINKS_PATH ${PROJECT_NAME} "${ext_links}" ${CMAKE_BUILD_TYPE})
endif()
if(ext_inc_dirs)
	resolve_External_Includes_Path(COMPLETE_INCLUDES_PATH ${PROJECT_NAME} "${ext_inc_dirs}" ${CMAKE_BUILD_TYPE})
endif()

# setting compile/linkage definitions for the component target
if(export)
	set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_exp_defs} ${ext_defs})
	manage_Additional_Component_Internal_Flags(${component} "" "${comp_defs}")
	manage_Additional_Component_Exported_Flags(${component} "${COMPLETE_INCLUDES_PATH}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${COMPLETE_LINKS_PATH}")

else()
	set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${ext_defs})		
	manage_Additional_Component_Internal_Flags(${component} "${COMPLETE_INCLUDES_PATH}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}")
	manage_Additional_Component_Exported_Flags(${component} "" "${comp_exp_defs}" "${COMPLETE_LINKS_PATH}")
endif()

endfunction(fill_Component_Target_With_External_Dependency)


### reset components related cached variables 
function(reset_component_cached_variables component)
# resetting package dependencies
foreach(a_dep_pack IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}})
	foreach(a_dep_comp IN ITEMS ${${PROJECT_NAME}_${component}_DEPENDENCY_${a_dep_pack}_COMPONENTS${USE_MODE_SUFFIX}})
		set(${PROJECT_NAME}_${component}_EXPORT_${a_dep_pack}_${a_dep_comp}${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endforeach()
	set(${PROJECT_NAME}_${component}_DEPENDENCY_${a_dep_pack}_COMPONENTS${USE_MODE_SUFFIX}  CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}  CACHE INTERNAL "")

# resetting internal dependencies
foreach(a_internal_dep_comp IN ITEMS ${${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}})
	set(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${a_internal_dep_comp}${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")

#resetting all other variables
set(${PROJECT_NAME}_${component}_HEADER_DIR_NAME CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_HEADERS CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_BINARY_NAME${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_DEFS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_LINKS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_PRIVATE_LINKS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_INC_DIRS${USE_MODE_SUFFIX} CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_SOURCE_CODE CACHE INTERNAL "")
set(${PROJECT_NAME}_${component}_SOURCE_DIR CACHE INTERNAL "")
endfunction(reset_component_cached_variables)

### resetting all internal cached variables that would cause some troubles
function(reset_cached_variables)

#resetting general info about the package : only list are reset
set (${PROJECT_NAME}_VERSION_MAJOR CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION_MINOR CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION_PATCH CACHE INTERNAL "" )
set (${PROJECT_NAME}_VERSION CACHE INTERNAL "" )

# package dependencies declaration must be reinitialized otherwise some problem (uncoherent dependancy versions) would appear
foreach(dep_package IN ITEMS ${${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX}})
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} CACHE INTERNAL "")	
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_${${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}}_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")

# external package dependencies declaration must be reinitialized 
foreach(dep_package IN ITEMS ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}})
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} CACHE INTERNAL "")	
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} CACHE INTERNAL "")
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION_EXACT${USE_MODE_SUFFIX} CACHE INTERNAL "")
endforeach()
set(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} CACHE INTERNAL "")


# component declaration must be reinitialized otherwise some problem (redundancy of declarations) would appear
foreach(a_component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	reset_component_cached_variables(${a_component})
endforeach()
reset_Declared()
set(${PROJECT_NAME}_COMPONENTS CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_LIBS CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_APPS CACHE INTERNAL "")

#unsetting all root variables usefull to the find/configuration mechanism
foreach(a_used_package IN ITEMS ${${PROJECT_NAME}_ALL_USED_PACKAGES})
	set(${a_used_package}_FOUND CACHE INTERNAL "")
	set(${a_used_package}_ROOT_DIR CACHE INTERNAL "")
	set(${a_used_package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "")
	set(${a_used_package}_REQUIRED_VERSION_EXACT CACHE INTERNAL "")
endforeach()
foreach(a_used_package IN ITEMS ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES})
	set(${a_used_package}_FOUND CACHE INTERNAL "")
	set(${a_used_package}_ROOT_DIR CACHE INTERNAL "")
	set(${a_used_package}_ALL_REQUIRED_VERSIONS CACHE INTERNAL "")
	set(${a_used_package}_REQUIRED_VERSION_EXACT CACHE INTERNAL "")
endforeach()

set(${PROJECT_NAME}_ALL_USED_PACKAGES CACHE INTERNAL "")
set(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES CACHE INTERNAL "")
reset_To_Install_Packages()
reset_To_Install_External_Packages()
endfunction(reset_cached_variables)

function(reset_Mode_Cache_Options)
#unset all global options
set(BUILD_EXAMPLES FALSE CACHE BOOL "" FORCE)
set(BUILD_API_DOC FALSE CACHE BOOL "" FORCE)
set(BUILD_API_DOC FALSE CACHE BOOL "" FORCE)
set(BUILD_AND_RUN_TESTS FALSE CACHE BOOL "" FORCE)
set(BUILD_WITH_PRINT_MESSAGES FALSE CACHE BOOL "" FORCE)
set(USE_LOCAL_DEPLOYMENT FALSE CACHE BOOL "" FORCE)
set(GENERATE_INSTALLER FALSE CACHE BOOL "" FORCE)
set(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD FALSE CACHE BOOL "" FORCE)
#include the cmake script that sets the options coming from the global build configuration
include(${CMAKE_BINARY_DIR}/../share/cacheConfig.cmake)

endfunction(reset_Mode_Cache_Options)

###
function(is_A_System_Reference_Path path IS_SYSTEM)

if(UNIX)
	if(path STREQUAL / OR path STREQUAL /usr OR path STREQUAL /usr/local)
		set(${IS_SYSTEM} TRUE PARENT_SCOPE)
	else()
		set(${IS_SYSTEM} FALSE PARENT_SCOPE)
	endif()
endif()

if(APPLE AND NOT ${IS_SYSTEM})
	if(path STREQUAL /Library/Frameworks OR path STREQUAL /Network/Library/Frameworks OR path STREQUAL /System/Library/Framework)
		set(${IS_SYSTEM} TRUE PARENT_SCOPE)
	endif()
endif()

endfunction(is_A_System_Reference_Path)


