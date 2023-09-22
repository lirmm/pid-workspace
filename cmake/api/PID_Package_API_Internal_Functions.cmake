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
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Version_Management_Functions NO_POLICY_SCOPE)
include(PID_Progress_Management_Functions NO_POLICY_SCOPE)
include(PID_Finding_Functions NO_POLICY_SCOPE)
include(PID_Package_Configuration_Functions NO_POLICY_SCOPE)
include(PID_Package_Cache_Management_Functions NO_POLICY_SCOPE)
include(PID_Package_Build_Targets_Management_Functions NO_POLICY_SCOPE)
include(PID_Documentation_Management_Functions NO_POLICY_SCOPE)
include(PID_Deployment_Functions NO_POLICY_SCOPE)
include(PID_Package_Coding_Support NO_POLICY_SCOPE)
include(PID_Continuous_Integration_Functions NO_POLICY_SCOPE)
include(PID_Plugins_Management NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)
include(PID_Meta_Information_Management_Functions NO_POLICY_SCOPE)
include(PID_Contribution_Space_Functions NO_POLICY_SCOPE)
include(External_Definition NO_POLICY_SCOPE) #to be able to interpret content of external package description files
include(Plugin_Definition NO_POLICY_SCOPE)#to be able to interpret content of plugin scripts
include(Environment_Definition NO_POLICY_SCOPE) #to be able to interpret description of build environment requirements

##################################################################################
#################### package management public functions and macros ##############
##################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Package| replace:: ``declare_Package``
#  .. declare_Package:
#
#  declare_Package
#  ---------------
#
#   .. command:: declare_Package(author institution mail year license address public_address description readme_file code_style contrib_space)
#
#     Declare the current CMake project as a native package. Internal counterpart to declare_PID_Package.
#
#     :author: the name of the contact author.
#     :institution: the institution(s) to which the contact author belongs.
#     :mail: E-mail of the contact author.
#     :year: reflects the lifetime of the package.
#     :license: The name of the license applying to the package.
#     :address: The url of the package's official repository.
#     :public_address: the public counterpart url to address.
#     :description: a short description of the package.
#     :readme_file: the path to a user-defined content of the readme file of the package.
#     :code_style: determines which clang-format file will be used to format the source code.
#     :contrib_space: determines the default contribution space of the package.
#
macro(declare_Package author institution mail year license address public_address description readme_file code_style contrib_space)

manage_Current_Platform("${CMAKE_BINARY_DIR}" "NATIVE") #loading the current platform configuration and perform adequate actions if any changes
set(PACKAGE_SPECIFIC_BUILD_INFO_FILE ${CMAKE_BINARY_DIR}/Package_Build_Info.cmake)
file(WRITE "${PACKAGE_SPECIFIC_BUILD_INFO_FILE}" "")#create the file (only useful in build mode specific folders)

set(${PROJECT_NAME}_ROOT_DIR CACHE INTERNAL "")
activate_Adequate_Languages()
#################################################
############ Managing options ###################
#################################################
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake) # adding the cmake scripts files from the package
if(EXISTS ${CMAKE_SOURCE_DIR}/cmake)
	list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake) # adding a user defined folder containing cmake scripts files from the package
endif()

configure_Git()
if(NOT GIT_CONFIGURED)
	message(FATAL_ERROR "[PID] CRITICAL ERROR: your git tool is NOT configured. To use PID you need to configure git:\ngit config --global user.name \"Your Name\"\ngit config --global user.email <your email address>\n")
	return()
endif()
set(${PROJECT_NAME}_ARCH ${CURRENT_PLATFORM_ARCH} CACHE INTERNAL "")#to keep compatibility with PID v1 released package versions

manage_Parrallel_Build_Option()
#################################################
############ MANAGING build mode ################
#################################################
if(CMAKE_BINARY_DIR MATCHES "${PROJECT_NAME}/build/release$")
	reset_Mode_Cache_Options(CACHE_POPULATED)
	init_Standard_Path_Cache_Variables()
	#setting the variables related to the current build mode
	set(CMAKE_BUILD_TYPE "Release" CACHE STRING "the type of build is dependent from build location" FORCE)
	set (INSTALL_NAME_SUFFIX "" CACHE INTERNAL "" FORCE)
	set (USE_MODE_SUFFIX "" CACHE INTERNAL "" FORCE)
	if(NOT CACHE_POPULATED)
		finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you must configure the package from the build folder at first time.")
		return()
	endif()
elseif(CMAKE_BINARY_DIR MATCHES "${PROJECT_NAME}/build/debug$")
	reset_Mode_Cache_Options(CACHE_POPULATED)
	init_Standard_Path_Cache_Variables()
	#setting the variables related to the current build mode
	set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "the type of build is dependent from build location" FORCE)
	set(INSTALL_NAME_SUFFIX -dbg CACHE INTERNAL "" FORCE)
	set(USE_MODE_SUFFIX "_DEBUG" CACHE INTERNAL "" FORCE)
	if(NOT CACHE_POPULATED)
		finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : you must configure the package from the build folder at first time.")
		return()
	endif()
elseif(CMAKE_BINARY_DIR MATCHES "${PROJECT_NAME}/build$")
	declare_Native_Global_Cache_Options() #first of all declaring global options so that the package is preconfigured with default options values and adequate comments for each variable
	set_Cache_Entry_For_Default_Contribution_Space("${contrib_space}")
	init_Standard_Path_Cache_Variables()
	file(WRITE ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/share/checksources "")
	file(WRITE ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/share/rebuilt "")

	################################################################################################
	################################ General purpose targets #######################################
	################################################################################################

	# target to check if source tree need to be rebuilt
	add_custom_target(checksources
		BYPRODUCTS ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/share/checksources
		COMMAND ${CMAKE_COMMAND} -DWORKSPACE_DIR=${WORKSPACE_DIR}
		-DPACKAGE_NAME=${PROJECT_NAME}
		-DSOURCE_PACKAGE_CONTENT=${CMAKE_BINARY_DIR}/share/Info${PROJECT_NAME}.cmake
		-P ${WORKSPACE_DIR}/cmake/commands/Check_PID_Package_Modification.cmake
		COMMENT "[PID] Checking for modified source tree ..."
	)
	# target to reconfigure the project
	add_custom_command(OUTPUT ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/share/rebuilt
			COMMAND ${CMAKE_MAKE_PROGRAM} rebuild_cache
			COMMAND ${CMAKE_COMMAND} -E touch ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/share/rebuilt
			DEPENDS ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/share/checksources
			COMMENT "[PID] Reconfiguring the package ${PROJECT_NAME} ..."
    	)
	add_custom_target(reconfigure
			DEPENDS ${WORKSPACE_DIR}/packages/${PROJECT_NAME}/build/share/rebuilt
    	)

	add_dependencies(reconfigure checksources)

	# target used to create/replace version tags
	add_custom_target(memorizing
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DCMAKE_SOURCE_DIR=${CMAKE_SOURCE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DTARGET_VERSION=\${version}
						-DREMOTE_ADDR=${address}
						-P ${WORKSPACE_DIR}/cmake/commands/Memorizing_PID_Version.cmake
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		COMMENT "[PID] memorizing existing version ..."
	)

	# target used to deprecate versions
	add_custom_target(deprecate
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DTARGET_MAJOR=\${major}
						-DTARGET_MINOR=\${minor}
						-P ${WORKSPACE_DIR}/cmake/commands/Deprecate_PID_Package_Versions.cmake
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		COMMENT "[PID] deprecating versions ..."
	)

	# update target (update the package from upstream git repository)
	add_custom_target(update
		COMMAND ${CMAKE_COMMAND}
		        -DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
					  -DFORCE_SOURCE=TRUE
						-P ${WORKSPACE_DIR}/cmake/commands/Update_PID_Deployment_Unit.cmake
		COMMENT "[PID] Updating the package ${PROJECT_NAME} ..."
		VERBATIM
	)


	add_custom_target(integrate
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DWITH_OFFICIAL=\${official}
						-P ${WORKSPACE_DIR}/cmake/commands/Integrate_PID_Package.cmake
		COMMENT "[PID] Integrating modifications ..."
	)

	# checking that the build takes place on integration
	add_custom_target(check-branch
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DGIT_REPOSITORY=${CMAKE_SOURCE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DFORCE_RELEASE_BUILD=\${force}
						-P ${WORKSPACE_DIR}/cmake/commands/Check_PID_Package_Branch.cmake
		COMMENT "[PID] Checking branch..."
	)

	# checking that the official has not been modified (migration)
	if(${PROJECT_NAME}_ADDRESS) #only if there is an official address spefified
		add_custom_target(check-repository
			COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
							-DTARGET_PACKAGE=${PROJECT_NAME}
							-P ${WORKSPACE_DIR}/cmake/commands/Check_PID_Package_Official_Repository.cmake
			COMMENT "[PID] Checking official repository consistency..."
			VERBATIM
		)
	endif()

	################################################################################################
	############ creating custom targets to delegate calls to mode specific targets ################
	################################################################################################

	set(SUDOER_PRIVILEGES)
	if(RUN_TESTS_WITH_PRIVILEGES)
		if(IN_CI_PROCESS)
			set(SUDOER_PRIVILEGES sudo)
		endif()
	endif()

	# global build target
	if(BUILD_RELEASE_ONLY)
		add_custom_target(build
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} build
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR} ${CMAKE_COMMAND} -E touch build_process
			COMMENT "[PID] Building package ${PROJECT_NAME} (Release mode only) for platform ${CURRENT_PLATFORM} using environment ${CURRENT_ENVIRONMENT} ..."
			VERBATIM
		)
		add_custom_target(build_release
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} build
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR} ${CMAKE_COMMAND} -E touch build_process
			COMMENT "[PID] Release build of package ${PROJECT_NAME} for platform ${CURRENT_PLATFORM} using environment ${CURRENT_ENVIRONMENT} ..."
			VERBATIM
		)
		add_dependencies(build_release reconfigure) #checking if reconfiguration is necessary before build
		add_dependencies(build_release check-branch)#checking if not built on master branch or released tag
		if(${PROJECT_NAME}_ADDRESS)
			add_dependencies(build_release check-repository) #checking if remote addrr needs to be changed
		endif()
	else()
		add_custom_target(build
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} build
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} build
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR} ${CMAKE_COMMAND} -E touch build_process
			COMMENT "[PID] Building package ${PROJECT_NAME} (Debug and Release modes) for platform ${CURRENT_PLATFORM} using environment ${CURRENT_ENVIRONMENT} ..."
			VERBATIM
		)
		#mode specific build commands
		add_custom_target(build_release
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} build
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR} ${CMAKE_COMMAND} -E touch build_process
			COMMENT "[PID] Release build of package ${PROJECT_NAME} for platform ${CURRENT_PLATFORM} using environment ${CURRENT_ENVIRONMENT} ..."
			VERBATIM
		)
		add_dependencies(build_release reconfigure) #checking if reconfiguration is necessary before build
		add_dependencies(build_release check-branch)#checking if not built on master branch or released tag
		if(${PROJECT_NAME}_ADDRESS)
			add_dependencies(build_release check-repository) #checking if remote addrr needs to be changed
		endif()
		add_custom_target(build_debug
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} build
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR} ${CMAKE_COMMAND} -E touch build_process
			COMMENT "[PID] Debug build of package ${PROJECT_NAME} for platform ${CURRENT_PLATFORM} using environment ${CURRENT_ENVIRONMENT} ..."
			VERBATIM
		)
		add_dependencies(build_debug reconfigure) #checking if reconfiguration is necessary before build
		add_dependencies(build_debug check-branch)#checking if not built on master branch or released tag
		if(${PROJECT_NAME}_ADDRESS)
			add_dependencies(build_debug check-repository) #checking if remote addrr needs to be changed
	  	endif()
	endif()

	add_dependencies(build reconfigure) #checking if reconfiguration is necessary before build
	add_dependencies(build check-branch)#checking if not built on master branch or released tag
	if(${PROJECT_NAME}_ADDRESS)
		add_dependencies(build check-repository) #checking if remote addrr needs to be changed
	endif()

	if(BUILD_RELEASE_ONLY)
		add_custom_target(global_main ALL
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
			COMMENT "[PID] Compiling and linking package (Release mode only) ..."
			VERBATIM
		)
	else()
		add_custom_target(global_main ALL
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
			COMMENT "[PID] Compiling and linking package ${PROJECT_NAME} (Debug and Release modes) ..."
			VERBATIM
		)
	endif()

	# cleaning target (cleaning the build tree)
	if(BUILD_RELEASE_ONLY)
		add_custom_target(cleaning
			COMMAND ${CMAKE_COMMAND} -E  touch ${CMAKE_BINARY_DIR}/share/checksources
			COMMAND ${CMAKE_COMMAND} -E  touch ${CMAKE_BINARY_DIR}/share/rebuilt
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} clean
			COMMENT "[PID] Cleaning package ${PROJECT_NAME} (Release mode only) ..."
			VERBATIM
		)
	else()
		add_custom_target(cleaning
			COMMAND ${CMAKE_COMMAND} -E  touch ${CMAKE_BINARY_DIR}/share/checksources
			COMMAND ${CMAKE_COMMAND} -E  touch ${CMAKE_BINARY_DIR}/share/rebuilt
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} clean
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} clean
			COMMENT "[PID] Cleaning package ${PROJECT_NAME} (Debug and Release modes) ..."
			VERBATIM
		)
	endif()
	# hard clean (remove content of the build tree including cmake generated configuration files)
  add_custom_target(hard_clean
  	COMMAND ${CMAKE_COMMAND}
            -DWORKSPACE_DIR=${WORKSPACE_DIR}
            -DTARGET_PACKAGE=${PROJECT_NAME}
			-DADDITIONAL_DEBUG_INFO=${ADDITIONAL_DEBUG_INFO}
			-P ${WORKSPACE_DIR}/cmake/commands/Hard_Clean_PID_Package.cmake
  	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
  )

	# reference file generation target
	add_custom_target(referencing
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} referencing
		COMMENT "[PID] Generating and installing reference to the package ${PROJECT_NAME} ..."
		VERBATIM
	)


	# reference file generation target
	add_custom_target(patching
		COMMAND ${CMAKE_COMMAND}
				-DWORKSPACE_DIR=${WORKSPACE_DIR}
				-DTARGET_PACKAGE=${PROJECT_NAME}
				-DADDITIONAL_DEBUG_INFO=${ADDITIONAL_DEBUG_INFO}
				-DTARGET_VERSION=\${version}
				-P ${WORKSPACE_DIR}/cmake/commands/Patch_PID_Package.cmake
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		COMMENT "[PID] Patching package ${PROJECT_NAME} ..."
	)

	# redefinition of install target
	if(BUILD_RELEASE_ONLY)
		add_custom_target(installing
			COMMAND ${CMAKE_COMMAND} -E  echo Installing ${PROJECT_NAME} Release artefacts
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} install
			COMMENT "[PID] Installing the package ${PROJECT_NAME} (Release artifacts only) ..."
			VERBATIM
		)
	else()
		add_custom_target(installing
			COMMAND ${CMAKE_COMMAND} -E  echo Installing ${PROJECT_NAME} Debug artefacts
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} install
			COMMAND ${CMAKE_COMMAND} -E  echo Installing ${PROJECT_NAME} Release artefacts
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} install
			COMMENT "[PID] Installing the package ${PROJECT_NAME} ..."
			VERBATIM
		)
	endif()

	# uninstall target (cleaning the install tree)
	add_custom_target(uninstall
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} uninstall
		COMMENT "[PID] Uninstalling the package ${PROJECT_NAME} ..."
		VERBATIM
	)

	# system installation
	add_custom_target(sysinstall
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} sysinstall
		VERBATIM
	)

	# site target (generation of a static site documenting the project)
	add_custom_target(site
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} site
		COMMENT "[PID] Creating/Updating web pages of package ${PROJECT_NAME} ..."
		VERBATIM
	)
	add_custom_target(serve
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} serve
		COMMENT "[PID] Serving web pages of package ${PROJECT_NAME} ..."
		VERBATIM
	)

	if(BUILD_AND_RUN_TESTS AND NOT PID_CROSSCOMPILATION)
		# test target (launch test units, redefinition of tests)
		if(RUN_TESTS_IN_DEBUG)
			if(BUILD_COVERAGE_REPORT)#coverage requires tests to be run in debug mode
				add_custom_target(coverage
					COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${SUDOER_PRIVILEGES}${CMAKE_MAKE_PROGRAM} coverage
					COMMENT "[PID] Generating coverage report for tests of ${PROJECT_NAME} ..."
					VERBATIM
				)
				add_dependencies(site coverage) #when the site is built with such options activated it means that the coverage report must be built first

				add_custom_target(testing #basic tests only in release
					COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_COMMAND} -E env CTEST_OUTPUT_ON_FAILURE=1 ${SUDOER_PRIVILEGES} ${CMAKE_MAKE_PROGRAM} test
					COMMENT "[PID] Launching tests of ${PROJECT_NAME} ..."
					VERBATIM
				)
			else()
				add_custom_target(testing
					COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_COMMAND} -E env CTEST_OUTPUT_ON_FAILURE=1 ${SUDOER_PRIVILEGES} ${CMAKE_MAKE_PROGRAM} test
					COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_COMMAND} -E env CTEST_OUTPUT_ON_FAILURE=1 ${SUDOER_PRIVILEGES} ${CMAKE_MAKE_PROGRAM} test
					COMMENT "[PID] Launching tests of ${PROJECT_NAME} ..."
					VERBATIM
				)
			endif()
		else()
			add_custom_target(testing
				COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_COMMAND} -E env CTEST_OUTPUT_ON_FAILURE=1 ${SUDOER_PRIVILEGES} ${CMAKE_MAKE_PROGRAM} test
				COMMENT "[PID] Launching tests of ${PROJECT_NAME} ..."
				VERBATIM
			)
		endif()
	endif()


	if(BUILD_STATIC_CODE_CHECKING_REPORT)
		add_custom_target(staticchecks
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} staticchecks
			COMMENT "[PID] Generating static checks report ..."
			VERBATIM
		)
		add_dependencies(site staticchecks)
	endif()

	if(BUILD_API_DOC)
		# doc target (generation of API documentation)
		add_custom_target(doc
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} doc
			COMMENT "[PID] Generating API documentation ..."
			VERBATIM
		)
		add_dependencies(site doc)
	endif()

	if(GENERATE_INSTALLER)
		# package target (generation and install of a UNIX binary packet)
		if(BUILD_RELEASE_ONLY)
			add_custom_target(packaging
				COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} package
				COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} package_install
				COMMENT "[PID] Generating and installing binary package for ${PROJECT_NAME} ..."
				VERBATIM
			)
		else()
			add_custom_target(packaging
				COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} package
				COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} package_install
				COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} package
				COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} package_install
				COMMENT "[PID] Generating and installing binary package for ${PROJECT_NAME} ..."
				VERBATIM
			)
		endif()
		add_dependencies(site packaging)
	endif()

	if(NOT "${license}" STREQUAL "")
		# target to add licensing information to all source files
		add_custom_target(licensing
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} licensing
			COMMENT "[PID] Applying license to sources of package ${PROJECT_NAME} ..."
			VERBATIM
		)
	endif()
	if(ADDITIONAL_DEBUG_INFO AND NOT BUILD_RELEASE_ONLY)
		add_custom_target(list_dependencies
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} list_dependencies
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_MAKE_PROGRAM} list_dependencies
			COMMENT "[PID] listing dependencies of the package ${PROJECT_NAME} ..."
			VERBATIM
		)
	else()
		add_custom_target(list_dependencies
			COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_MAKE_PROGRAM} list_dependencies
			COMMENT "[PID] listing dependencies of the package ${PROJECT_NAME} ..."
			VERBATIM
		)
	endif()
	add_custom_target(list_versions
		COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-P ${WORKSPACE_DIR}/cmake/commands/Listing_PID_Versions.cmake
		COMMENT "[PID] ${PROJECT_NAME} versions:"
	)
	add_custom_target(workspace_path
		COMMAND ${CMAKE_COMMAND} -DWORKSPACE_DIR=${WORKSPACE_DIR} -P ${WORKSPACE_DIR}/cmake/commands/Print_Workspace_Path.cmake
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	)

	set(PACKAGE_FORMAT_FOLDER ${CMAKE_SOURCE_DIR})
	set(PACKAGE_FORMAT_FILE ${PACKAGE_FORMAT_FOLDER}/.clang-format)
	# if a code style is provided, copy the configuration file to the package root folder
	set(no_format TRUE)
	if(NOT "${code_style}" STREQUAL "")# a code style is defined
		resolve_Path_To_Format_File(PATH_TO_STYLE ${code_style})
		if(NOT PATH_TO_STYLE)
			message(WARNING "[PID] WARNING: you use an undefined code format ${code_style}")
			set(format_cmd_message "no format called ${code_style} found")
		else()
			set(PATH_TO_CUSTOM_STYLE ${PACKAGE_FORMAT_FOLDER}/share/.clang-format)
			if(EXISTS ${PATH_TO_CUSTOM_STYLE})
				file(STRINGS ${PATH_TO_STYLE} BASE_STYLE)
				file(READ ${PATH_TO_CUSTOM_STYLE} CUSTOM_STYLE)
				set(STYLE)
				foreach(line IN LISTS BASE_STYLE)
					if(line STREQUAL "...")
						set(STYLE "${STYLE}${CUSTOM_STYLE}")
					endif()
					set(STYLE "${STYLE}${line}\n")
				endforeach()
				file(WRITE ${PACKAGE_FORMAT_FOLDER}/.clang-format ${STYLE})
			else()
				file(COPY ${PATH_TO_STYLE} DESTINATION ${PACKAGE_FORMAT_FOLDER})
				file(RENAME ${PACKAGE_FORMAT_FOLDER}/.clang-format.${code_style} ${PACKAGE_FORMAT_FILE})
			endif()
		endif()
	endif()
	# we have a .clang-format file, either provided by PID or by the user
	if(EXISTS ${PACKAGE_FORMAT_FILE})
		if(CLANG_FORMAT_EXECUTABLE)
			add_custom_target(format
				COMMAND ${CMAKE_COMMAND} -DWORKSPACE_DIR=${WORKSPACE_DIR}
								-DPACKAGE_NAME=${PROJECT_NAME}
								-DCLANG_FORMAT_EXE=${CLANG_FORMAT_EXECUTABLE}
								-P ${WORKSPACE_DIR}/cmake/commands/Format_PID_Package_Sources.cmake
				COMMENT "[PID] formatting the source files"
			)
			set(no_format FALSE)
		else()
			set(format_cmd_message "no clang formatter found")
		endif()
	else()
		set(format_cmd_message "the package does not have a .clang-format file at its root")
	endif()
	if(no_format)
		add_custom_target(format
			COMMAND ${CMAKE_COMMAND} -E echo "[PID] ERROR: ${format_cmd_message}. Formatting aborted."
			COMMAND exit 1
			COMMENT "[PID] formatting the source files"
		)
	endif()
	unset(no_format)

	if(BUILD_DEPENDENT_PACKAGES AND ADDITIONAL_DEBUG_INFO)
		message("[PID] INFO : build process of ${PROJECT_NAME} will be recursive.")
	endif()

	if(NOT EXISTS ${CMAKE_BINARY_DIR}/debug OR NOT IS_DIRECTORY ${CMAKE_BINARY_DIR}/debug)
		file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/debug)
	endif()
	if(NOT EXISTS ${CMAKE_BINARY_DIR}/release OR NOT IS_DIRECTORY ${CMAKE_BINARY_DIR}/release)
		file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/release)
	endif()

	#getting global options (those set by the user)
	set_Mode_Specific_Options_From_Global()

	#calling cmake for each build mode (continue package configuration for Release and Debug Modes
	if(NOT BUILD_RELEASE_ONLY)
		execute_process(
			COMMAND ${CMAKE_COMMAND}
				-G "${CMAKE_GENERATOR}"
				-C ${CMAKE_BINARY_DIR}/share/cacheConfig.cmake
				-DWORKSPACE_DIR=${WORKSPACE_DIR} ${CMAKE_SOURCE_DIR}
			WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/debug)
	endif()
	execute_process(
		COMMAND ${CMAKE_COMMAND}
			-G "${CMAKE_GENERATOR}"
			-C ${CMAKE_BINARY_DIR}/share/cacheConfig.cmake
			-DWORKSPACE_DIR=${WORKSPACE_DIR} ${CMAKE_SOURCE_DIR}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/release)

	#now getting options specific to debug and release modes
	set_Global_Options_From_Mode_Specific()
	return()# execution of the root CMakeLists.txt ends for general build
else()	# the configuration must be done in the build directory
	message("[PID] ERROR : please run cmake in the build folder of the package ${PROJECT_NAME}.")
	return()
endif()

#################################################
######## Initializing cache variables ###########
#################################################
reset_Package_Description_Cached_Variables()
reset_Documentation_Info()
reset_CI_Variables()
reset_Package_Platforms_Variables()
reset_Packages_Finding_Variables()
init_PID_Version_Variable(${PROJECT_NAME} ${CMAKE_SOURCE_DIR})
init_Meta_Info_Cache_Variables("${author}" "${institution}" "${mail}" "${description}" "${year}" "${license}" "${address}" "${public_address}" "${readme_file}" "" "" "" "" "")
reset_Version_Cache_Variables()
reset_Temporary_Optimization_Variables(${CMAKE_BUILD_TYPE}) #resetting temporary variables used in optimization of configruation process

if(CHECK_GIT_REMOTES)
	check_For_Remote_Respositories("${ADDITIONAL_DEBUG_INFO}")
	check_For_Branches("${ADDITIONAL_DEBUG_INFO}")
endif()

begin_Progress(${PROJECT_NAME} GLOBAL_PROGRESS_VAR) #managing the build from a global point of view

endmacro(declare_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Documentation_Target| replace:: ``create_Documentation_Target``
#  .. _create_Documentation_Target:
#
#  create_Documentation_Target
#  ---------------------------
#
#   .. command:: create_Documentation_Target()
#
#     Create the "site" target for currently defined package project, used to launch static site update.
#
function(create_Documentation_Target)
if(NOT CMAKE_BUILD_TYPE MATCHES Release) # the documentation can be built in release mode only
	return()
endif()

package_License_Is_Closed_Source(CLOSED ${PROJECT_NAME} FALSE)
set(INCLUDING_BINARIES FALSE)
set(INCLUDING_COVERAGE FALSE)
set(INCLUDING_STATIC_CHECKS FALSE)
if(NOT CLOSED)#check if project is closed source or not

	# management of binaries publication
	if(${PROJECT_NAME}_BINARIES_AUTOMATIC_PUBLISHING)
		set(INCLUDING_BINARIES TRUE)
	endif()

	#checking for coverage generation
	if(BUILD_COVERAGE_REPORT AND PROJECT_RUN_TESTS)
		set(INCLUDING_COVERAGE TRUE)
	endif()

	#checking for coverage generation
	if(BUILD_STATIC_CODE_CHECKING_REPORT AND NOT CLOSED)
		set(INCLUDING_STATIC_CHECKS TRUE)
	endif()

endif()

if(${PROJECT_NAME}_SITE_GIT_ADDRESS) #the publication of the static site is done within a lone static site

	add_custom_target(site
		COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DIN_CI_PROCESS=${IN_CI_PROCESS}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DTARGET_VERSION=${${PROJECT_NAME}_VERSION}
						-DCMAKE_COMMAND=${CMAKE_COMMAND}
						-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
						-DINCLUDES_API_DOC=${BUILD_API_DOC}
						-DINCLUDES_COVERAGE=${INCLUDING_COVERAGE}
						-DINCLUDES_STATIC_CHECKS=${INCLUDING_STATIC_CHECKS}
						-DINCLUDES_INSTALLER=${INCLUDING_BINARIES}
						-DSYNCHRO=\${synchro}
						-DFORCED_UPDATE=\${force}
						-DSITE_GIT="${${PROJECT_NAME}_SITE_GIT_ADDRESS}"
						-DPACKAGE_PROJECT_URL="${${PROJECT_NAME}_PROJECT_PAGE}"
						-DPACKAGE_SITE_URL="${${PROJECT_NAME}_SITE_ROOT_PAGE}"
						-DPACKAGE_REGISTRY="${${PROJECT_NAME}_REGISTY}"
			 -P ${WORKSPACE_DIR}/cmake/commands/Build_PID_Site.cmake)

			 add_custom_target(serve
 				COMMAND ${CMAKE_MAKE_PROGRAM} serve
			  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${PROJECT_NAME}/build
			 )

elseif(${PROJECT_NAME}_FRAMEWORK) #the publication of the static site is done with a framework

	add_custom_target(site
		COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DIN_CI_PROCESS=${IN_CI_PROCESS}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DTARGET_VERSION=${${PROJECT_NAME}_VERSION}
						-DCMAKE_COMMAND=${CMAKE_COMMAND}
						-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
						-DTARGET_FRAMEWORK=${${PROJECT_NAME}_FRAMEWORK}
						-DINCLUDES_API_DOC=${BUILD_API_DOC}
						-DINCLUDES_COVERAGE=${INCLUDING_COVERAGE}
						-DINCLUDES_STATIC_CHECKS=${INCLUDING_STATIC_CHECKS}
						-DINCLUDES_INSTALLER=${INCLUDING_BINARIES}
						-DSYNCHRO=\${synchro}
						-DPACKAGE_PROJECT_URL="${${PROJECT_NAME}_PROJECT_PAGE}"
			 -P ${WORKSPACE_DIR}/cmake/commands/Build_PID_Site.cmake
	)

	add_custom_target(serve
		COMMAND ${CMAKE_COMMAND} -E echo "Nothing to be served. Use serve command of framework ${${PROJECT_NAME}_FRAMEWORK}"
	)
else()
	add_custom_target(serve
		COMMAND ${CMAKE_COMMAND} -E echo "Nothing to be served"
	)
endif()
endfunction(create_Documentation_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |set_Current_Version| replace:: ``set_Current_Version``
#  .. _set_Current_Version:
#
#  set_Current_Version
#  -------------------
#
#   .. command:: set_Current_Version(major minor patch)
#
#     Set the version of currently defined package project.
#
#     :major: the major version number
#
#     :minor: the minor version number
#
#     :patch: the patch version number
#
function(set_Current_Version major minor patch)
	set_Version_Cache_Variables("${major}" "${minor}" "${patch}")
	set_Install_Cache_Variables()
endfunction(set_Current_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Environment_Tool_Constraints| replace:: ``check_Environment_Tool_Constraints``
#  .. _check_Environment_Tool_Constraints:
#
#  check_Environment_Tool_Constraints
#  -----------------------------------
#
#   .. command:: check_Environment_Tool_Constraints(RESULT tool_constraints)
#
#     Check that the tools required is provided by the current build profile.
#
#     :tool_constraints: check if tool is available with constraints.
#
#     :ERROR: the output variable that is empty if constraints are satisfied, contains the error message if any constraint cannot be satisfied.
#
function(check_Environment_Tool_Constraints ERROR tool_constraints)
	set(${ERROR} PARENT_SCOPE)
	check_Extra_Tool_Configuration(RESULT_OK CONFIG_CONSTRAINTS "${tool_constraints}" ${CMAKE_BUILD_TYPE})
	if(NOT RESULT_OK)
		set(${ERROR} "tool constraints violated: ${tool_constraints}" PARENT_SCOPE)
		return()
	endif()
	foreach(config IN LISTS CONFIG_CONSTRAINTS)
		#checking all platform configurations required by the language toolset
		check_Platform_Constraints(RESULT IS_CURRENT "" "" "" "" "${config}" "${optional}")
		if(NOT RESULT)#bad result
			set(${ERROR}  "extra tool ${tool_constraints} has unsatisfied platform constraints: ${config}" PARENT_SCOPE)
			return()
		endif()
	endforeach()
endfunction(check_Environment_Tool_Constraints)



#.rst:
#
# .. ifmode:: internal
#
#  .. |configure_With_Project_Specific_Toolchain| replace:: ``configure_With_Project_Specific_Toolchain``
#  .. _configure_With_Project_Specific_Toolchain:
#
#  configure_With_Project_Specific_Toolchain
#  -----------------------------------------
#
#   .. command:: configure_With_Project_Specific_Toolchain()
#
#     genetae a toolchain file if required by toolsets then reconfigure the current project with this toolchain file
#
#
function(configure_With_Project_Specific_Toolchain)
	set(reconfigure FALSE)
	file(READ ${PACKAGE_SPECIFIC_BUILD_INFO_FILE} env_toolchains)
	if(env_toolchains)#there is configuration information
		file(READ ${WORKSPACE_DIR}/build/PID_Toolchain.cmake global_toolchain)
		set(global_str "${global_toolchain}\n${env_toolchains}")
		if(EXISTS ${WORKSPACE_DIR}/build/${PROJECT_NAME}_PID_Toolchain.cmake)
			file(READ ${WORKSPACE_DIR}/build/${PROJECT_NAME}_PID_Toolchain.cmake project_toolchain)
			if(project_toolchain STREQUAL global_str)
				return()#Just to avoid infinite recursion
			endif()
		endif()
		#last environment evaluation has generated a toolchain, simply use it
		file(WRITE ${WORKSPACE_DIR}/build/${PROJECT_NAME}_PID_Toolchain.cmake "${global_str}")
		set(reconfigure TRUE)
	else()#no toolchain defined
		if(EXISTS ${WORKSPACE_DIR}/build/${PROJECT_NAME}_PID_Toolchain.cmake)
			#old toolchain must be suppressed
			file(REMOVE ${WORKSPACE_DIR}/build/${PROJECT_NAME}_PID_Toolchain.cmake)
			set(reconfigure TRUE)
		endif()
	endif()
	if(reconfigure)
		#NOTE: since content of env is placed AFTER global it will overwrite it
		message("[PID] INFO: reconfigure from scratch with new toolchain ...")
		hard_Clean_Build_Folder(${CMAKE_SOURCE_DIR}/build)
		execute_process(COMMAND ${CMAKE_COMMAND}
							-S ${CMAKE_SOURCE_DIR}
							-B ${CMAKE_SOURCE_DIR}/build
							-G "${CMAKE_GENERATOR}"
							-DWORKSPACE_DIR=${WORKSPACE_DIR}
						WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/build)
		message(FATAL_ERROR "[PID] INFO: stopping initial configuration ...")
	endif()
endfunction(configure_With_Project_Specific_Toolchain)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Environment_Language_Constraints| replace:: ``check_Environment_Language_Constraints``
#  .. _check_Environment_Language_Constraints:
#
#  check_Environment_Language_Constraints
#  ---------------------------------------
#
#   .. command:: check_Environment_Language_Constraints(RESULT language_constraint lang_toolset bound_langs)
#
#     Check that the language specification required are provided by the current build profile.
#
#     :language_constraint: check on available languages.
#     :lang_toolset: list of language toolsets expressed as environment check expressions
#     :bound_langs: list of language whose configuration is bound to the current language (basically C can be bound to CXX). Most often use when the toolset needed to be changed either explicitly or automatically.
#
#     :ERROR: the output variable that is empty if constraints are satisfied, contains the error message if any constraint cannot be satisfied.
#
function(check_Environment_Language_Constraints ERROR language_constraint lang_toolset bound_langs)
	set(${ERROR} PARENT_SCOPE)
	set(automatic FALSE)
	set(error_messages)
	set(config_constraints)

	#first checking language constraints (not bound to a specific environment)
	check_Language_Configuration(RESULT_OK LANG_NAME LANG_CONSTRAINTS PLATFORM_CONSTRAINTS "${language_constraint}" ${CMAKE_BUILD_TYPE})
	if(RESULT_OK)#if the result if FALSE and the constraint was optional then skip it
		if(PLATFORM_CONSTRAINTS)
			# need to memorize the constraint to automatically add it to components
			foreach(config IN LISTS PLATFORM_CONSTRAINTS)
				#checking all platform configurations required by the language toolset
				check_Platform_Constraints(RESULT IS_CURRENT "" "" "" "" "${config}"  "${optional}")
				if(NOT RESULT)#bad result
					set(${ERROR} "language ${LANG_NAME} has unsatisfied platform constraints: ${config}" PARENT_SCOPE)
					return()
				else()
					list(APPEND config_constraints ${config})
				endif()
			endforeach()
		endif()
	else()
		# here set the toolset to use using lang_toolset
		get_adequate_compiler_toolchain_version(RES_TOOLCHAIN_CONSTRAINT ${language_constraint})
		if(NOT RES_TOOLCHAIN_CONSTRAINT)
			set(${ERROR} "language ${LANG_NAME} constraints violated: ${LANG_CONSTRAINTS}" PARENT_SCOPE)
			return()
		else()
			#overwritte the lang_toolset var
			set(lang_toolset ${RES_TOOLCHAIN_CONSTRAINT})
		endif()
	endif()
	if(lang_toolset)
		set(all_langs ${LANG_NAME} ${bound_langs})
		check_Language_Toolset(RESULT_OK TS_NAME TS_ARGS "${all_langs}" "${lang_toolset}" ${CMAKE_BUILD_TYPE})
		if(NOT RESULT_OK)
			set(${ERROR}  "language toolset requirement not satisfied: ${lang_toolset} for ${LANG_NAME}" PARENT_SCOPE)
			return()
		endif()
		#OK toolset is available
	endif()

	#then memorize language configuration
	append_Unique_In_Cache(${PROJECT_NAME}_LANGUAGE_CONFIGURATIONS${USE_MODE_SUFFIX} ${LANG_NAME})
	set(${PROJECT_NAME}_LANGUAGE_CONFIGURATION_${LANG_NAME}_ARGS${USE_MODE_SUFFIX} "${LANG_CONSTRAINTS}" CACHE INTERNAL "")
	if(config_constraints)
		append_Unique_In_Cache(${PROJECT_NAME}_IMPLICIT_PLATFORM_CONSTRAINTS${USE_MODE_SUFFIX} ${config_constraints})
	endif()

endfunction(check_Environment_Language_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_Platform_Constraints| replace:: ``check_Platform_Constraints``
#  .. _check_Platform_Constraints:
#
#  check_Platform_Constraints
#  --------------------------
#
#   .. command:: check_Platform_Constraints(RESULT IS_CURRENT type arch os abi constraints optional)
#
#     Check that the platform constraints provided match the current platform configuration. Constraints are checked only if the current platform matches platform filters provided.
#
#     :type: the target processor type used as a filter (may be empty string if no filter).
#     :arch: the target processor architecture (bits) used as a filter (may be empty string if no filter).
#     :os: the target kernel used as a filter (may be empty string if no filter).
#     :abi: the target abi type used as a filter (may be empty string if no filter).
#     :constraints: configurations checks to perform.
#     :optional: if configurations are optional.
#
#     :RESULT: the output variable that is TRUE if constraints are satisfied or if no constraint appliesdu to filters, FALSE if any constraint cannot be satisfied.
#     :IS_CURRENT: the output variable that contains the current platform identifier if current platform matches all filters.
#
function(check_Platform_Constraints RESULT IS_CURRENT type arch os abi constraints optional)
set(SKIP FALSE)
#The check of compatibility between the target platform and the constraints is immediate using platform configuration information (platform files) + additionnal global information (distribution for instance) coming from the workspace

#1) checking the conditions to know if the configuration concerns the platform currently in use
if(type) # a processor type is specified, so it applies like a filter on current platform
	if(NOT CURRENT_PLATFORM_TYPE IN_LIST type)
		set(SKIP TRUE)
	endif()
endif()

if(NOT SKIP AND arch) # a processor architecture is specified, so it applies like a filter on current platform
	if(NOT CURRENT_PLATFORM_ARCH IN_LIST arch)
		set(SKIP TRUE)
	endif()
endif()

if(NOT SKIP AND os) # an operating system is specified, so it applies like a filter on current platform
	if(NOT CURRENT_PLATFORM_OS IN_LIST os)
		set(SKIP TRUE)
	endif()
endif()

if(NOT SKIP AND abi) # a target ABI is specified, so it applies like a filter on current platform
	if(NOT CURRENT_PLATFORM_ABI IN_LIST abi)
		set(SKIP TRUE)
	endif()
endif()

#2) testing configuration constraints if the platform currently in use satisfies conditions
#
set(${RESULT} TRUE PARENT_SCOPE)
if(SKIP)#if the check is skipped then it means that current platform does not satisfy platform constraints
	set(${IS_CURRENT} PARENT_SCOPE)
else()
	set(${IS_CURRENT} ${CURRENT_PLATFORM} PARENT_SCOPE)
endif()

set(configurations_to_memorize)
if(NOT SKIP AND constraints)
	foreach(config IN LISTS constraints) ## all configuration constraints must be satisfied
		check_Platform_Configuration(RESULT_OK CONFIG_NAME CONFIG_CONSTRAINTS ${PROJECT_NAME} "${config}" ${CMAKE_BUILD_TYPE})
		if(NOT RESULT_OK)
			set(${RESULT} FALSE PARENT_SCOPE)#returns false as soon as one config check fails
		endif()
		if(RESULT_OK OR NOT optional)#if the result if FALSE and the configuration was optional then skip it
			list(APPEND configurations_to_memorize ${CONFIG_NAME})#memorize name of the configuration
			set(${CONFIG_NAME}_constraints_to_memorize ${CONFIG_CONSTRAINTS})#then memorize all constraints that apply to the configuration
		endif()
	endforeach()

	#registering all configurations wether they are satisfied or not, except non satisfied optional ones
	append_Unique_In_Cache(${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX} "${configurations_to_memorize}")
	foreach(config IN LISTS configurations_to_memorize)
		if(${config}_constraints_to_memorize)#there are paremeters for that configuration, they need to be registered
			list(REMOVE_DUPLICATES ${config}_constraints_to_memorize)
			set(${PROJECT_NAME}_PLATFORM_CONFIGURATION_${config}_ARGS${USE_MODE_SUFFIX} "${${config}_constraints_to_memorize}" CACHE INTERNAL "")
		endif()
	endforeach()
endif()

endfunction(check_Platform_Constraints)

#.rst:
#
# .. ifmode:: internal
#
#  .. |build_Package| replace:: ``build_Package``
#  .. _build_Package:
#
#  build_Package
#  -------------
#
#   .. command:: build_Package()
#
#     Finalize configuration of the current package build process. Internal counterpart of build_PID_Package.
#
macro(build_Package)

#do not check, simply add C and C++ languages if not already explicitly required by user as they are default
list(FIND ${PROJECT_NAME}_LANGUAGE_CONFIGURATIONS${USE_MODE_SUFFIX} C INDEX)
if(INDEX EQUAL -1)
	check_Language_Configuration(RESULT_OK LANG_NAME LANG_CONSTRAINTS PLATFORM_CONSTRAINTS "C" ${CMAKE_BUILD_TYPE})
	if(NOT RESULT_OK)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: There is no support for C language (mandatory) ! Abort build of package ${PROJECT_NAME}. Please reconfigure your workspace.")
	endif()
	set(error_message)
	if(PLATFORM_CONSTRAINTS)
		# need to memorize the constraint to automatically add it to components
		foreach(config IN LISTS PLATFORM_CONSTRAINTS)
			#checking all platform configurations required by the language toolset
			check_Platform_Constraints(RESULT IS_CURRENT "" "" "" "" "${config}"  FALSE)
			if(NOT RESULT)#bad result
				set(config_eval_result FALSE)
				if(error_messages)
					set(error_messages "${error_messages}, ${config}")
				else()
					set(error_messages "language ${lang} has unsatisfied platform constraints: ${config}")
				endif()
			else()
				append_Unique_In_Cache(${PROJECT_NAME}_IMPLICIT_PLATFORM_CONSTRAINTS${USE_MODE_SUFFIX} ${config})
			endif()
		endforeach()
	endif()
	if(error_message)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: Support for C language requires use of platform configurations that cannot be satisfies, error is: ${error_message}")
	endif()
	append_Unique_In_Cache(${PROJECT_NAME}_LANGUAGE_CONFIGURATIONS${USE_MODE_SUFFIX} C)
	set(${PROJECT_NAME}_LANGUAGE_CONFIGURATION_C_ARGS${USE_MODE_SUFFIX} ${LANG_CONSTRAINTS} CACHE INTERNAL "")
endif()

list(FIND ${PROJECT_NAME}_LANGUAGE_CONFIGURATIONS${USE_MODE_SUFFIX} CXX INDEX)
if(INDEX EQUAL -1)
	check_Language_Configuration(RESULT_OK LANG_NAME LANG_CONSTRAINTS PLATFORM_CONSTRAINTS "CXX" ${CMAKE_BUILD_TYPE})
	if(NOT RESULT_OK)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: There is no support for CXX language (mandatory) ! Abort build of package ${PROJECT_NAME}. Please reconfigure your workspace.")
	endif()
	set(error_message)
	if(PLATFORM_CONSTRAINTS)
		# need to memorize the constraint to automatically add it to components
		foreach(config IN LISTS PLATFORM_CONSTRAINTS)
			#checking all platform configurations required by the language toolset
			check_Platform_Constraints(RESULT IS_CURRENT "" "" "" "" "${config}"  FALSE)
			if(NOT RESULT)#bad result
				set(config_eval_result FALSE)
				if(error_messages)
					set(error_messages "${error_messages}, ${config}")
				else()
					set(error_messages "language ${lang} has unsatisfied platform constraints: ${config}")
				endif()
			else()
				append_Unique_In_Cache(${PROJECT_NAME}_IMPLICIT_PLATFORM_CONSTRAINTS${USE_MODE_SUFFIX} ${config})
			endif()
		endforeach()
	endif()
	if(error_message)
		message(FATAL_ERROR "[PID] CRITICAL ERROR: Support for C language requires use of platform configurations that cannot be satisfies, error is: ${error_message}")
	endif()
	append_Unique_In_Cache(${PROJECT_NAME}_LANGUAGE_CONFIGURATIONS${USE_MODE_SUFFIX} CXX)
	set(${PROJECT_NAME}_LANGUAGE_CONFIGURATION_CXX_ARGS${USE_MODE_SUFFIX} ${LANG_CONSTRAINTS} CACHE INTERNAL "")
endif()

#now generate toolchain file and reconfigure if needed
configure_With_Project_Specific_Toolchain()

get_Platform_Variables(BASENAME curr_platform_name PKG_STRING cpack_platform_str)

### configuring RPATH management in CMake
set(CMAKE_SKIP_BUILD_RPATH FALSE) # don't skip the full RPATH for the build tree
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE) #do not use any link time info when installing
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) # when building, don't use the install RPATH already

if(APPLE)
	set(CMAKE_MACOSX_RPATH TRUE)
	set(CMAKE_INSTALL_RPATH "@loader_path/../lib;@loader_path") #the default install rpath is the library folder of the installed package (internal librari	es managed by default), name is relative to @loader_path to enable easy package relocation
elseif (UNIX)
	set(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib;\$ORIGIN") #the default install rpath is the library folder of the installed package (internal libraries managed by default), name is relative to $ORIGIN to enable easy package relocation
endif()

#################################################################################
############ MANAGING the configuration of package dependencies #################
#################################################################################
# from here only direct dependencies existing in workspace have been satisfied

#resolving external dependencies for project external dependencies

# 1) resolving dependencies of required external packages versions (different versions can be required at the same time)
# we get the set of all packages undirectly required
foreach(dep_pack IN LISTS ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
	need_Install_External_Package(MUST_BE_INSTALLED MUST_BE_FOUND ${dep_pack})
	if(MUST_BE_INSTALLED)
		install_External_Package(INSTALL_OK ${dep_pack} FALSE FALSE "${BUILD_RELEASE_ONLY}")
		if(NOT INSTALL_OK)
			finish_Progress(${GLOBAL_PROGRESS_VAR})
			message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to install external package: ${dep_pack}. This bug is maybe due to bad referencing of this package. Please have a look in workspace contributions folder and try to find ReferExternal${dep_pack}.cmake file.")
			return()
		endif()
	endif()
	if(MUST_BE_FOUND)
		resolve_External_Package_Dependency(IS_VERSION_COMPATIBLE IS_ABI_COMPATIBLE ${PROJECT_NAME} ${dep_pack} ${CMAKE_BUILD_TYPE})#launch again the resolution
		if(NOT ${dep_pack}_FOUND${USE_MODE_SUFFIX})#this time the package must be found since installed => internal BUG in PID
			finish_Progress(${GLOBAL_PROGRESS_VAR})
			message(FATAL_ERROR "[PID] INTERNAL ERROR : impossible to find installed external package ${dep_pack}. This is an internal bug maybe due to a bad find file for ${dep_pack}.")
			return()
		elseif(NOT IS_VERSION_COMPATIBLE)#this time there is really nothing to do since package has been installed so it therically already has all its dependencies compatible (otherwise there is simply no solution)
			finish_Progress(${GLOBAL_PROGRESS_VAR})
			if(${dep_pack}_ALL_REQUIRED_VERSIONS)
				set(mess_str "All required versions are : ${${dep_pack}_ALL_REQUIRED_VERSIONS}")
			else()
				set(mess_str "Exact version already required is ${${dep_pack}_REQUIRED_VERSION_EXACT}")
			endif()
			if(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_pack}_VERSION${USE_MODE_SUFFIX})
				if(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_pack}_VERSION_EXACT${USE_MODE_SUFFIX})
					set(local_version "exact version ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_pack}_VERSION${USE_MODE_SUFFIX}}")
				else()
					set(local_version "version ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_pack}_VERSION${USE_MODE_SUFFIX}}")
				endif()
			endif()
			message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent external package ${dep_pack} regarding versions constraints. Search ended when trying to satisfy ${local_version} coming from package ${PROJECT_NAME}. ${mess_str}.")
			return()
		elseif(NOT IS_ABI_COMPATIBLE)
			finish_Progress(${GLOBAL_PROGRESS_VAR})
			message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find a version of dependent external package ${dep_pack} with an ABI compatible with current platform. This may mean that you have no access to ${dep_pack} wrapper and no binary package for ${dep_pack} match current platform ABI")
			return()
		else()#OK resolution took place !!
			add_Chosen_Package_Version_In_Current_Process(${dep_pack} ${PROJECT_NAME})#memorize chosen version in progress file to share this information with dependent packages
			resolve_Package_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE} TRUE "${BUILD_RELEASE_ONLY}")#recursion : resolving dependencies for each external package dependency
		endif()
	else()#no need to install => simply resolve its dependencies
		resolve_Package_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE} TRUE "${BUILD_RELEASE_ONLY}")
	endif()
endforeach()

if(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
	# 1) resolving dependencies of required native packages versions (different versions can be required at the same time)
	# we get the set of all packages undirectly required
	foreach(dep_pack IN LISTS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
		need_Install_Native_Package(MUST_BE_INSTALLED MUST_BE_FOUND ${dep_pack})
		if(MUST_BE_INSTALLED)
			install_Native_Package(INSTALL_OK ${dep_pack} FALSE "${BUILD_RELEASE_ONLY}")
			if(NOT INSTALL_OK)
				finish_Progress(${GLOBAL_PROGRESS_VAR})
				message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to install native package: ${dep_pack}. This bug is maybe due to bad referencing of this package. Please have a look in workspace contributions and try to find Refer${dep_pack}.cmake file.")
			endif()
		endif()
		if(MUST_BE_FOUND)
			resolve_Native_Package_Dependency(IS_VERSION_COMPATIBLE IS_ABI_COMPATIBLE ${PROJECT_NAME} ${dep_pack} ${CMAKE_BUILD_TYPE})#launch again the resolution
			if(NOT ${dep_pack}_FOUND${USE_MODE_SUFFIX})#this time the package must be found since installed => internal BUG in PID
				finish_Progress(${GLOBAL_PROGRESS_VAR})
				message(FATAL_ERROR "[PID] INTERNAL ERROR : impossible to find installed native package ${dep_pack}. This is an internal bug maybe due to a bad find file for ${dep_pack}.")
			elseif(NOT IS_VERSION_COMPATIBLE)#this time there is really nothing to do since package has been installed so it theoretically already has all its dependencies compatible (otherwise there is simply no solution)
				finish_Progress(${GLOBAL_PROGRESS_VAR})
				message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent native package ${dep_pack} regarding versions constraints. Search ended when trying to satisfy version coming from package ${PROJECT_NAME}. All required versions are : ${${dep_pack}_ALL_REQUIRED_VERSIONS}, Exact version already required is ${${dep_pack}_REQUIRED_VERSION_EXACT}, Last exact version required is ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_pack}_VERSION${VAR_SUFFIX}}.")
			elseif(NOT IS_ABI_COMPATIBLE)
				finish_Progress(${GLOBAL_PROGRESS_VAR})
				message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find a version of dependent native package ${dep_pack} with an ABI compatible with current platform. This may mean that you have no access to ${dep_pack} repository and no binary package for ${dep_pack} matches current platform ABI")
			else()#OK resolution took place !!
				add_Chosen_Package_Version_In_Current_Process(${dep_pack} ${PROJECT_NAME})#memorize chosen version in progress file to share this information with dependent packages
				resolve_Package_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE} TRUE "${BUILD_RELEASE_ONLY}")#recursion : resolving dependencies for each external package dependency
			endif()
		else()#no need to install so directly resolve
			resolve_Package_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE} TRUE "${BUILD_RELEASE_ONLY}")
		endif()
 	endforeach()
endif()
#here every package dependency should have been resolved OR ERROR

# 2) when done resolving runtime dependencies for all used package (direct or undirect)
foreach(dep_pack IN LISTS ${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX})
	resolve_Package_Runtime_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE})
	resolve_preuse(${PROJECT_NAME} ${dep_pack} ${CMAKE_BUILD_TYPE} TRUE)
endforeach()
foreach(dep_pack IN LISTS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
	resolve_Package_Runtime_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE})
endforeach()
clear_Managed_Packages_For_Runtime_Dependencies(${CMAKE_BUILD_TYPE})
#################################################
############ MANAGING the BUILD #################
#################################################

# listing closed source packages, info to be used in targets managements
if(CMAKE_BUILD_TYPE MATCHES Debug)
	list_Closed_Source_Dependency_Packages()
else()
	set(CLOSED_SOURCE_DEPENDENCIES CACHE INTERNAL "")
endif()

#plugin callback call point
manage_Plugins_In_Package_Before_Components_Description()

# recursive call into subdirectories to build, install, test the package
add_subdirectory(src)
add_subdirectory(apps)

if(BUILD_AND_RUN_TESTS)
 	if(	CMAKE_BUILD_TYPE MATCHES Release
		OR (CMAKE_BUILD_TYPE MATCHES Debug AND RUN_TESTS_IN_DEBUG))
		enable_testing()
	endif()
endif()
add_subdirectory(share)
add_subdirectory(test)

list(LENGTH ${PROJECT_NAME}_PREDECLARED_COMPS NUM_PREDECLARED_COMPS)
if(NUM_PREDECLARED_COMPS GREATER 0)
	message(FATAL_ERROR "[PID] CRITICAL ERROR : These predeclared components have not been declared in the package: ${${PROJECT_NAME}_PREDECLARED_COMPS}")
endif()

##########################################################
############ MANAGING non source files ###################
##########################################################
generate_Package_Readme_Files() # generating and putting into source directory the readme file used by gitlab + in build tree the api doc welcome page (contain the same information)
if(${CMAKE_BUILD_TYPE} MATCHES Release) # generating and putting into source directory the .gitignore file removing all unwanted artifacts
  update_Git_Ignore_File(${WORKSPACE_DIR}/cmake/patterns/packages/package/.gitignore)
endif()
generate_Package_Authors_File()  # generating and putting into source directory the file containing the list of contributors
generate_Package_License_File() # generating and putting into source directory the file containing license info about the package
generate_Package_Install_Script() # generating and putting into source directory the file and folder containing stand alone install scripts
generate_Package_Find_File() # generating/installing the generic cmake find file for the package
generate_Use_File() #generating the version specific cmake "use" file and the rule to install it
generate_API() #generating the API documentation configuration file and the rule to launch doxygen and install the doc
generate_Info_File() #generating a cmake "info" file containing info about source code of components
generate_Dependencies_File() #generating a cmake "dependencies" file containing information about dependencies
generate_Coverage() #generating a coverage report in debug mode
generate_Static_Checks() #generating a static check report in release mode, if tests are enabled then static check test are automatically generated
create_Documentation_Target() # create target for generating documentation
configure_Package_Pages() # generating the markdown files for the project web pages
generate_Package_CI_Config_File() #generating the CI config file in the project


#installing specific folders of the share sub directory
if(CMAKE_BUILD_TYPE MATCHES Release AND EXISTS ${CMAKE_SOURCE_DIR}/share/cmake)
	#installing the cmake folder (may contain specific find scripts for external libs used by the package)
	install(DIRECTORY ${CMAKE_SOURCE_DIR}/share/cmake DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})
endif()

if(EXISTS ${CMAKE_SOURCE_DIR}/share/resources)
	#installing the share/resource folder (may contain runtime resources for components)
	install(DIRECTORY ${CMAKE_SOURCE_DIR}/share/resources DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})
endif()

#creating specific .rpath folders if build tree
if(NOT EXISTS ${CMAKE_BINARY_DIR}/.rpath)
	file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/.rpath)
endif()
foreach(component IN LISTS ${PROJECT_NAME}_COMPONENTS)
	if(${PROJECT_NAME}_${component}_TYPE STREQUAL "SHARED"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "MODULE"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "APP"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE"
	OR ${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
		will_be_Built(RES ${component})#Note: no need to resolve alias since component list contains only base name in current project
		if(RES)
			if(EXISTS ${CMAKE_BINARY_DIR}/.rpath/${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX})
				file(REMOVE_RECURSE ${CMAKE_BINARY_DIR}/.rpath/${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX})
			endif()
			file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/.rpath/${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX})
		endif()
	endif()
endforeach()

#resolving runtime dependencies for install tree
foreach(component IN LISTS ${PROJECT_NAME}_COMPONENTS)
	will_be_Built(RES ${component})#Note: no need to resolve alias since component list contains only base name in current project
	if(RES)
		resolve_Source_Component_Runtime_Dependencies(${component} ${CMAKE_BUILD_TYPE})
	endif()
endforeach()

#resolving runtime dependencies for build tree
foreach(component IN LISTS ${PROJECT_NAME}_COMPONENTS)
	will_be_Built(RES ${component})#Note: no need to resolve alias since component list contains only base name in current project
	if(RES)
		resolve_Source_Component_Runtime_Dependencies_Build_Tree(${component} ${CMAKE_BUILD_TYPE})
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
	generate_Formatted_String("${${PROJECT_NAME}_DESCRIPTION}" RES_DESCR)
	set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${RES_DESCR}")
	generate_Formatted_String("${${PROJECT_NAME}_MAIN_INSTITUTION}" RES_INSTIT)
	set(CPACK_PACKAGE_VENDOR "${RES_INSTIT}")
	set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/license.txt)
	set(CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
	set(CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
	set(CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
	set(CPACK_PACKAGE_VERSION "${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}")
	set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}/${${PROJECT_NAME}_VERSION}")
	list(APPEND CPACK_GENERATOR TGZ)


	if(cpack_platform_str)
		set(PACKAGE_SOURCE_NAME ${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-${cpack_platform_str}.tar.gz)
		set(PACKAGE_TARGET_NAME ${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-${curr_platform_name}.tar.gz) #we use specific PID platform name instead of CMake default one to avoid troubles (because it is not really discrimant)

		if(${PROJECT_NAME}_LICENSE)
			package_License_Is_Closed_Source(CLOSED ${PROJECT_NAME} FALSE)
			if(CLOSED)
					#if the license is not open source then we do not generate a package with debug info
					#this requires two step -> first consists in renaming adequately the generated artifcats, second in installing a package with adequate name
					if(CMAKE_BUILD_TYPE MATCHES Release)#release => generate two packages with two different names but with same content
						add_custom_target(	package_install
									COMMAND ${CMAKE_COMMAND} -E rename ${CMAKE_BINARY_DIR}/${PACKAGE_SOURCE_NAME} ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME}
									COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME} ${${PROJECT_NAME}_INSTALL_PATH}/installers/${PACKAGE_TARGET_NAME}
									COMMENT "[PID] installing ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME} in ${${PROJECT_NAME}_INSTALL_PATH}/installers")
					else()#debug => do not install the package
						add_custom_target(	package_install
									COMMAND ${CMAKE_COMMAND} -E echo ""
								COMMENT "[PID] debug package not installed in ${${PROJECT_NAME}_INSTALL_PATH}/installers due to license restriction")
					endif()

			else()#license is open source, do as usual
				add_custom_target(	package_install
							COMMAND ${CMAKE_COMMAND} -E rename ${CMAKE_BINARY_DIR}/${PACKAGE_SOURCE_NAME} ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME}
							COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME} ${${PROJECT_NAME}_INSTALL_PATH}/installers/${PACKAGE_TARGET_NAME}
							COMMENT "[PID] installing ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME} in ${${PROJECT_NAME}_INSTALL_PATH}/installers")
			endif()
		else()#no license (should never happen) => package is supposed to be closed source
			if(CMAKE_BUILD_TYPE MATCHES Release)#release => generate two packages with two different names but with same content
				add_custom_target(	package_install
							COMMAND ${CMAKE_COMMAND} -E rename ${CMAKE_BINARY_DIR}/${PACKAGE_SOURCE_NAME} ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME}
							COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME} ${${PROJECT_NAME}_INSTALL_PATH}/installers/${PACKAGE_TARGET_NAME}
							COMMENT "[PID] installing ${CMAKE_BINARY_DIR}/${PACKAGE_TARGET_NAME} in ${${PROJECT_NAME}_INSTALL_PATH}/installers")
			else()#debug => do not install the package
				add_custom_target(	package_install
							COMMAND ${CMAKE_COMMAND} -E echo ""
						COMMENT "[PID] debug package not installed in ${${PROJECT_NAME}_INSTALL_PATH}/installers due to license restriction")
			endif()
		endif()
		include(CPack)
	endif()
endif(GENERATE_INSTALLER)

###############################################################################
######### creating specific targets for easy management of the package ########
###############################################################################

if(${CMAKE_BUILD_TYPE} MATCHES Release)
	#copy the reference file of the package into the "references" folder of the workspace
	add_custom_target(referencing
		COMMAND ${CMAKE_COMMAND}
						-DWORKSPACE_DIR=${WORKSPACE_DIR}
						-DTARGET_PACKAGE=${PROJECT_NAME}
						-DCMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}
						-DTARGET_CONTRIBUTION_SPACE=${TARGET_CONTRIBUTION_SPACE}
						-DTARGET_CS=\${space}
						-P ${WORKSPACE_DIR}/cmake/commands/Referencing_PID_Deployment_Unit.cmake
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
							-P ${WORKSPACE_DIR}/cmake/commands/Licensing_PID_Package_Files.cmake
			VERBATIM
		)
	endif()

	# adding an uninstall command (uninstall the whole installed version currently built)
	# only if native build system generator does not generate one
	if(NOT TARGET uninstall)
		add_custom_target(uninstall
			COMMAND ${CMAKE_COMMAND} -E  echo Uninstalling ${PROJECT_NAME} version ${${PROJECT_NAME}_VERSION}
			COMMAND ${CMAKE_COMMAND} -E  remove_directory ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/${PROJECT_NAME}/${${PROJECT_NAME}_VERSION}
			VERBATIM
		)
	endif()

	# sysinstall target (install currently built version on the system)
	add_custom_target(sysinstall
		COMMAND ${CMAKE_COMMAND}
					-DWORKSPACE_DIR=${WORKSPACE_DIR}
					-DINSTALLED_PACKAGE=${PROJECT_NAME}
					-DTARGET_VERSION=${${PROJECT_NAME}_VERSION}
					-DINSTALL_FOLDER=\${folder}
					-DINSTALL_MODE=\${mode}
					-P ${WORKSPACE_DIR}/cmake/commands/Install_PID_Package.cmake
	)

endif()

add_custom_target(list_dependencies
	COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
					-DPROJECT_NAME=${PROJECT_NAME}
					-DPROJECT_VERSION=${${PROJECT_NAME}_VERSION}
					-DCMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}
					-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
					-DADDITIONAL_DEBUG_INFO=${ADDITIONAL_DEBUG_INFO}
					-DFLAT_PRESENTATION=\${flat}
					-DWRITE_TO_FILE=\${write_file}
					-P ${WORKSPACE_DIR}/cmake/commands/Listing_PID_Package_Dependencies.cmake
)

#########################################################################################################################
######### writing the global reference file for the package with all global info contained in the CMakeFile.txt #########
#########################################################################################################################
if(${PROJECT_NAME}_ADDRESS)
	generate_Package_Reference_File(${CMAKE_BINARY_DIR}/share/Refer${PROJECT_NAME}.cmake)
endif()

if(${CMAKE_BUILD_TYPE} MATCHES Release)
	if(GLOBAL_PROGRESS_VAR)
		some_Packages_Managed_Last_Time(DEPLOYED)
		if(DEPLOYED)
			message("------------------------------------------------------------------")
			message("Packages updated or installed during ${PROJECT_NAME} configuration :")
			print_Managed_Packages()
			message("------------------------------------------------------------------")
		endif()
	endif()
endif()

# dealing with plugins at the end of the configuration process
manage_Plugins_In_Package_After_Components_Description()
reset_Removed_Examples_Build_Option()

###############################################################################
######### creating build target for easy sequencing all make commands #########
###############################################################################

set(SUDOER_PRIVILEGES)
if(RUN_TESTS_WITH_PRIVILEGES)
	if(NOT IN_CI_PROCESS)#do not use sudo if in CI process
		set(SUDOER_PRIVILEGES sudo)
	endif()
endif()

#creating a global build command
package_Has_Nothing_To_Install(NOTHING_INSTALLED)
if(NOTHING_INSTALLED) #if nothing to install, it means that there is nothing to generate... so do nothing
	create_Global_Build_Command("${SUDOER_PRIVILEGES}" FALSE FALSE FALSE FALSE FALSE)
else()
	package_Has_Nothing_To_Build(NOTHING_BUILT)
	if(NOTHING_BUILT)
		set(BUILD_CODE FALSE)
	else()
		set(BUILD_CODE TRUE)
	endif()
	if(CMAKE_BUILD_TYPE MATCHES Release)
		if(BUILD_AND_RUN_TESTS AND PROJECT_RUN_TESTS)
			create_Global_Build_Command("${SUDOER_PRIVILEGES}" TRUE ${BUILD_CODE} "${GENERATE_INSTALLER}" "${BUILD_API_DOC}" "test")
		else()#if tests are not run then remove the test target
			create_Global_Build_Command("${SUDOER_PRIVILEGES}" TRUE ${BUILD_CODE} "${GENERATE_INSTALLER}" "${BUILD_API_DOC}" "")
		endif()
	else()#debug => never build api doc in debug mode
		if(BUILD_AND_RUN_TESTS AND RUN_TESTS_IN_DEBUG AND PROJECT_RUN_TESTS)  #if tests are not run then remove the coverage or test target
			if(BUILD_COVERAGE_REPORT) #covergae report must be generated with debug symbols activated
				create_Global_Build_Command("${SUDOER_PRIVILEGES}" TRUE ${BUILD_CODE} "${GENERATE_INSTALLER}" FALSE "coverage")
			else() #simple tests
				create_Global_Build_Command("${SUDOER_PRIVILEGES}" TRUE ${BUILD_CODE} "${GENERATE_INSTALLER}" FALSE "test")
			endif()
		else()
			create_Global_Build_Command("${SUDOER_PRIVILEGES}" TRUE ${BUILD_CODE} "${GENERATE_INSTALLER}" FALSE "")
		endif()
	endif()
endif()

#retrieving dependencies on sources packages
if(	BUILD_DEPENDENT_PACKAGES
	AND 	(CMAKE_BUILD_TYPE MATCHES Debug
		OR (CMAKE_BUILD_TYPE MATCHES Release AND BUILD_RELEASE_ONLY)))
	#only necessary to do dependent build one time, so we do it in debug mode or release if debug not built (i.e. first mode built)
	set(DEPENDENT_SOURCE_PACKAGES)
	list_All_Source_Packages_In_Workspace(RESULT_PACKAGES)
	if(RESULT_PACKAGES)
		foreach(dep_pack IN LISTS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
			list(FIND RESULT_PACKAGES ${dep_pack} id)
			if(id GREATER_EQUAL 0)#the package is a dependent source package
				if(${dep_pack}_VERSION_STRING)#Safety check: verify that the package has been installed => there is a version
					list(APPEND DEPENDENT_SOURCE_PACKAGES ${dep_pack} ${${dep_pack}_VERSION_STRING})
				endif()
			endif()
		endforeach()
	endif()
	if(DEPENDENT_SOURCE_PACKAGES)#there are some dependency managed with source package
		add_custom_target(build-dependencies
			COMMAND ${CMAKE_COMMAND}	-DWORKSPACE_DIR=${WORKSPACE_DIR}
							-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
							"-DDEPENDENT_PACKAGES=${DEPENDENT_SOURCE_PACKAGES}"
							-DPACKAGE_LAUCHING_BUILD=${PROJECT_NAME}
							-DBUILD_RELEASE_ONLY=${BUILD_RELEASE_ONLY}
							-P ${WORKSPACE_DIR}/cmake/commands/Build_PID_Package_Dependencies.cmake
				COMMENT "[PID] INFO : building dependencies of ${PROJECT_NAME} ..."
				VERBATIM
		)
		add_dependencies(build build-dependencies)# first building dependencies if necessary
	endif()
else()
	set(DEPENDENT_SOURCE_PACKAGES)
endif()


################################################################################
########################### END CONFIGURATION PROCESS ##########################
################################################################################
clean_Install_Dir() #cleaning the install directory (include/lib/bin folders) if there are files that are removed (do this only in release mode)
finish_Progress(${GLOBAL_PROGRESS_VAR})
endmacro(build_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Library_Component| replace:: ``declare_Library_Component``
#  .. _declare_Library_Component:
#
#  declare_Library_Component
#  -------------------------
#
#   .. command:: declare_Library_Component(	c_name dirname type
#                                          	c_standard c_max_standard cxx_standard cxx_max_standard
#											internal_inc_dirs internal_defs internal_compiler_options
#											exported_defs exported_compiler_options
#											internal_links exported_links
#											runtime_resources more_headers more_sources
#                                          	is_loggable aliases manage_symbols
#											internal_only for_examples for_tests)
#
#     Declare a library in the currently defined package.
#
#     :c_name: the name of the library.
#     :dirname: the name of the folder that contains includes and/or source code of the library.
#     :type: the type of the library (HEADER, STATIC, SHARED or MODULE).
#     :c_standard: the C language standard used (may be empty).
#     :c_max_standard: the maximum C language standard allowed when using the component.
#     :cxx_standard: the C++ language standard used (98, 11, 14, 17).
#     :cxx_max_standard: the maximum C++ language standard allowed when using the component.
#     :internal_inc_dirs: additionnal include dirs (internal to package, that contains header files, e.g. like common definition between package components), that don't have to be exported since not in the interface of the library.
#     :internal_defs: definitions that affects only the implementation of the library.
#     :internal_compiler_options: compiler options used for building the library but not exported to component using the library.
#     :exported_defs: definitions that affects the interface (public headers) of the library.
#     :exported_compiler_options: compiler options that need to be used whenever a component uses the library.
#     :internal_links: only for module or shared libs some internal linker flags used to build the component.
#     :exported_links: only for static and shared libs : some linker flags (not a library inclusion, e.g. -l<li> or full path to a lib) that must be used when linking with the component.
#     :runtime_resources: list of path to files relative to share/resources folder, supposed to be used at runtime by the library.
#     :more_headers: list of path to files or globing expressions relative to include/${dirname} folder, targetting additionnal headers to be part of the interface of the library (used to target files with no extension for instance).
#     :more_sources: list of path to files and folders relative to src folder, containing auxiliary sources to be used for building the library.
#     :is_loggable: if TRUE the componnet can be uniquely identified by the logging system.
#     :aliases: the list of alias for the component.
#     :manage_symbols: if not empty export of symbols of the library will be managed by hand and are all hidden by default, the path given will contain the generated header defining macro for exporting symbols. Otherwise if empty all symbols are exported.
#     :internal_only: if TRUE means the library is not provided by the package but is used for internal purpose only.
#     :for_examples: if TRUE means the library must be internal_only and is used for example purpose.
#     :for_tests: if TRUE means the librarymust be internal_only and is used for test purpose.
#
function(declare_Library_Component 	c_name dirname type
									c_standard c_max_standard cxx_standard cxx_max_standard
									internal_inc_dirs internal_defs internal_compiler_options
									exported_defs exported_compiler_options
									internal_links exported_links
									runtime_resources more_headers more_sources
									is_loggable aliases
									manage_symbols
									internal_only for_examples for_tests)
#indicating that the component has been declared and need to be completed
is_Library_Type(RES "${type}")
if(RES)
	set(${PROJECT_NAME}_${c_name}_TYPE ${type} CACHE INTERNAL "")
else()
	finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : you must specify a type (HEADER, STATIC, SHARED or MODULE) for library ${c_name}")
	return()
endif()
set_Internal_Only(${c_name} ${internal_only} ${for_examples} ${for_tests})
#prepare general info
if(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "MODULE")
	if(dirname)
		set(${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include/${dirname})
		if(more_headers)
			foreach(a_file IN LISTS more_headers)
				list(APPEND ${PROJECT_NAME}_${c_name}_TEMP_MORE_HEADERS ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/${a_file})
			endforeach()
		endif()
	endif()
endif()
if(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "HEADER")
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/${dirname})
endif()
set(CURRENT_COMP_DEFINED ${c_name})
manage_Plugins_In_Package_During_Components_Description()#call plugin scripts

#manage generation of specific headers used by the logging system
if(is_loggable)
	if(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "MODULE")
		generate_Loggable_File(PATH_TO_FILE NAME_FOR_PREPROC ${c_name} ${CMAKE_SOURCE_DIR}/include/${dirname} TRUE)
		list(APPEND exported_defs ${NAME_FOR_PREPROC})
	else()
		generate_Loggable_File(PATH_TO_FILE NAME_FOR_PREPROC ${c_name} ${CMAKE_SOURCE_DIR}/src/${dirname} FALSE)
		list(APPEND internal_defs ${NAME_FOR_PREPROC})
	endif()
endif()

# specifically managing examples
if(${PROJECT_NAME}_${c_name}_FOR_EXAMPLES OR ${PROJECT_NAME}_${c_name}_FOR_TESTS)
	if(${PROJECT_NAME}_${c_name}_FOR_EXAMPLES)
		add_Example_To_Doc(${c_name}) #examples are added to the doc to be referenced
	endif()
	set(needed_for_test TRUE)
	set(needed_for_ex TRUE)
	if(${PROJECT_NAME}_${c_name}_FOR_EXAMPLES AND NOT BUILD_EXAMPLES)
		set(needed_for_ex FALSE)
	endif()
	if(${PROJECT_NAME}_${c_name}_FOR_TESTS AND NOT BUILD_AND_RUN_TESTS)
		set(needed_for_test FALSE)
	endif()
	if(NOT needed_for_ex AND NOT needed_for_test)
		set(${PROJECT_NAME}_${c_name}_FOR_DOC_ONLY TRUE PARENT_SCOPE)
		mark_As_Declared(${c_name})
		return()
	endif()
endif()

### managing headers ###
if(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "MODULE") # a module library has no declared interface (only used dynamically)
	set(${PROJECT_NAME}_${c_name}_HEADER_DIR_NAME ${dirname} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_HEADERS CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_HEADERS_ADDITIONAL_FILTERS ${more_headers} CACHE INTERNAL "")
	if(dirname)# a pure header library may define no folder
		set(${PROJECT_NAME}_${c_name}_HEADERS_SELECTION_PATTERN "^$")
		#a library defines a folder containing one or more headers and/or subdirectories
		get_All_Headers_Relative(${PROJECT_NAME}_${c_name}_ALL_HEADERS_RELATIVE ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR} "${${PROJECT_NAME}_${c_name}_HEADERS_ADDITIONAL_FILTERS}")
		set(${PROJECT_NAME}_${c_name}_HEADERS ${${PROJECT_NAME}_${c_name}_ALL_HEADERS_RELATIVE} CACHE INTERNAL "")

		#build the header selection pattern according to all selected headers
		foreach(header IN LISTS ${PROJECT_NAME}_${c_name}_HEADERS)
			set(${PROJECT_NAME}_${c_name}_HEADERS_SELECTION_PATTERN  "^.*${header}$|${${PROJECT_NAME}_${c_name}_HEADERS_SELECTION_PATTERN}")
		endforeach()
		#get complete path to files that will be used at compile time
		get_All_Headers_Absolute(${PROJECT_NAME}_${c_name}_ALL_HEADERS ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR} "${more_headers}")

		#install the include folder with only header file
		if(NOT internal_only)
			install(DIRECTORY ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING REGEX "${${PROJECT_NAME}_${c_name}_HEADERS_SELECTION_PATTERN}")
		endif()
	elseif(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "HEADER")
		#problem only header libraries may have no folder !!
		finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR: when declaring library ${c_name} in ${PROJECT_NAME}, this component is not a header library and defines no folder where finding includes !!")
		return()
	endif()
endif()

### managing sources and defining targets ###
if(more_sources)
	set(target_folders_more_sources)
	foreach(tgt IN LISTS more_sources)
		if(EXISTS ${CMAKE_SOURCE_DIR}/${tgt})
			list(APPEND target_folders_more_sources ${tgt})
		elseif(EXISTS ${CMAKE_SOURCE_DIR}/src/${tgt})
			list(APPEND target_folders_more_sources src/${tgt})#contextual finding depending on type of component
		else()
			message("[PID] WARNING: in component ${c_name} you defined a path to auxiliary sources that is not referenced from project root dir")
		endif()
	endforeach()
endif()
if(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "HEADER")# a header library has no source code (generates no binary)
	set(${PROJECT_NAME}_${c_name}_SOURCE_DIR ${dirname} CACHE INTERNAL "")

	## 1) collect info about the sources for registration purpose
	#register the source dir
	if(${CMAKE_BUILD_TYPE} MATCHES Release)
		get_All_Sources_Relative(${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR})
		set(${PROJECT_NAME}_${c_name}_SOURCE_CODE ${${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE} CACHE INTERNAL "")
		if(more_sources)
			get_All_Sources_Relative_From(SOURCES PATH_TO_MONITOR ${CMAKE_SOURCE_DIR} "${target_folders_more_sources}")
			set(${PROJECT_NAME}_${c_name}_AUX_SOURCE_CODE ${SOURCES} CACHE INTERNAL "")
			set(${PROJECT_NAME}_${c_name}_AUX_MONITORED_PATH ${PATH_TO_MONITOR} CACHE INTERNAL "")
		endif()
	endif()
	## 2) collect sources for build process
	set(use_includes ${internal_inc_dirs})
	get_All_Sources_Absolute(${PROJECT_NAME}_${c_name}_ALL_SOURCES ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR})
	if(more_sources)
		set(MORE_SOURCES)
		set(MORE_INCLUDES)
		get_All_Sources_Absolute_From(MORE_SOURCES MORE_INCLUDES ${CMAKE_SOURCE_DIR} "${target_folders_more_sources}")
		list(APPEND ${PROJECT_NAME}_${c_name}_ALL_SOURCES ${MORE_SOURCES})
		if(MORE_INCLUDES)
			list(APPEND use_includes ${MORE_INCLUDES})
		endif()
	endif()
	list(APPEND ${PROJECT_NAME}_${c_name}_ALL_SOURCES ${${PROJECT_NAME}_${c_name}_ALL_HEADERS})

	#defining shared and/or static targets for the library and
	#adding the targets to the list of installed components when make install is called
	if(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "STATIC") #a static library has no internal links (never trully linked)
		create_Static_Lib_Target(${c_name} "${c_standard}" "${cxx_standard}" "${${PROJECT_NAME}_${c_name}_ALL_SOURCES}" "${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}"  "${use_includes}" "${exported_defs}" "${internal_defs}" "${exported_compiler_options}" "${internal_compiler_options}" "${exported_links}")
		register_Component_Binary(${c_name})
	elseif(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "SHARED")
		create_Shared_Lib_Target(${c_name} "${c_standard}" "${cxx_standard}" "${${PROJECT_NAME}_${c_name}_ALL_SOURCES}" "${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}" "${use_includes}" "${exported_defs}" "${internal_defs}" "${exported_compiler_options}" "${internal_compiler_options}" "${exported_links}" "${internal_links}" "${manage_symbols}")
		if(NOT internal_only)
			install(DIRECTORY DESTINATION ${${PROJECT_NAME}_INSTALL_RPATH_DIR}/${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX})#create the folder that will contain symbolic links (e.g. to shared libraries) used by the component (will allow full relocation of components runtime dependencies at install time)
		endif()
		register_Component_Binary(${c_name})
	elseif(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "MODULE") #a static library has no exported links (no interface)
		contains_Python_Code(HAS_WRAPPER ${CMAKE_CURRENT_SOURCE_DIR}/${dirname})
		if(HAS_WRAPPER)
			if(NOT CURRENT_PYTHON)#we cannot build the module because there is no python module
				return()
			endif()
			#adding adequate path to pyhton librairies
			list(APPEND INCLUDE_DIRS_WITH_PYTHON ${use_includes} ${CURRENT_PYTHON_INCLUDE_DIRS})
			list(APPEND LIBRARIES_WITH_PYTHON ${internal_links} ${CURRENT_PYTHON_LIBRARIES})
			create_Module_Lib_Target(${c_name} "${c_standard}" "${cxx_standard}" "${${PROJECT_NAME}_${c_name}_ALL_SOURCES}" "${INCLUDE_DIRS_WITH_PYTHON}" "${internal_defs}" "${internal_compiler_options}" "${LIBRARIES_WITH_PYTHON}" "${manage_symbols}")
		else()
			create_Module_Lib_Target(${c_name} "${c_standard}" "${cxx_standard}" "${${PROJECT_NAME}_${c_name}_ALL_SOURCES}" "${use_includes}" "${internal_defs}" "${internal_compiler_options}" "${internal_links}" "${manage_symbols}")
		endif()
		if(NOT internal_only)
			install(DIRECTORY DESTINATION ${${PROJECT_NAME}_INSTALL_RPATH_DIR}/${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX})#create the folder that will contain symbolic links (e.g. to shared libraries) used by the component (will allow full relocation of components runtime dependencies at install time)
		endif()
		register_Component_Binary(${c_name})#need to register before calling manage python
		register_Runtime_Component_Binary(${c_name} "MODULE")#need to register before calling manage python
		if(HAS_WRAPPER)
			manage_Python_Scripts(${c_name} ${dirname})#specific case to manage, python scripts must be installed in a share/script subfolder
			set(${PROJECT_NAME}_${c_name}_HAS_PYTHON_WRAPPER TRUE CACHE INTERNAL "")
		else()
			set(${PROJECT_NAME}_${c_name}_HAS_PYTHON_WRAPPER FALSE CACHE INTERNAL "")
		endif()
	endif()
else()#simply creating a "fake" target for header only library
	create_Header_Lib_Target(${c_name} "${c_standard}" "${cxx_standard}" "${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}" "${exported_defs}" "${exported_compiler_options}" "${exported_links}")
endif()

if(manage_symbols)
	include(GenerateExportHeader)#using CMake dedicated module
	#NOTE: if symbols are managed then we need to generate the header defining macros used for exporting symbols
	GENERATE_EXPORT_HEADER(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} BASE_NAME ${PROJECT_NAME}_${c_name})
	set(target_exporting_header ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}_${c_name}_export.h)
	set(exporting_header_path_in_build_tree ${CMAKE_CURRENT_BINARY_DIR}/include/${${PROJECT_NAME}_${c_name}_HEADER_DIR_NAME}/${manage_symbols})
	file(COPY ${target_exporting_header}
		DESTINATION ${exporting_header_path_in_build_tree})
	target_include_directories(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} PUBLIC
		${CMAKE_CURRENT_BINARY_DIR}/include/${${PROJECT_NAME}_${c_name}_HEADER_DIR_NAME})

	if(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "MODULE")
		#NOTE: a module does not define an interface, just implement an existing one so no need to install
		if(NOT internal_only)
			install(FILES ${target_exporting_header}
					DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH}/${${PROJECT_NAME}_${c_name}_HEADER_DIR_NAME}/${manage_symbols}
			)
		endif()
	endif()
endif()
# registering exported flags for all kinds of libs
init_Component_Cached_Variables_For_Export(${c_name} "${c_standard}" "${c_max_standard}" "${cxx_standard}" "${cxx_max_standard}" "${exported_defs}" "${exported_compiler_options}" "${exported_links}" "${runtime_resources}")

#create local "real" CMake ALIAS target
if(aliases)
	add_Alias_To_Cache(${c_name} "${aliases}")
	create_Alias_Lib_Target(${PROJECT_NAME} ${c_name} "${aliases}" "${INSTALL_NAME_SUFFIX}")
endif()

#updating global variables of the CMake process
append_Unique_In_Cache(${PROJECT_NAME}_COMPONENTS ${c_name})
append_Unique_In_Cache(${PROJECT_NAME}_COMPONENTS_LIBS ${c_name})
# global variable to know that the component has been declared (must be reinitialized at each run of cmake)
mark_As_Declared(${c_name})

#finaly apply plugins actions
manage_Plugins_Contribution_Into_Current_Component()
#automatically manage implicit platform constraints
foreach(config IN LISTS ${PROJECT_NAME}_IMPLICIT_PLATFORM_CONSTRAINTS${USE_MODE_SUFFIX})
	declare_System_Component_Dependency_Using_Configuration(
		${c_name}
		FALSE
		${config}
		"" "" ""
	)
endforeach()

endfunction(declare_Library_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Application_Component| replace:: ``declare_Application_Component``
#  .. _declare_Application_Component:
#
#  declare_Application_Component
#  -----------------------------
#
#   .. command:: declare_Application_Component(c_name dirname type
#                                              c_standard c_max_standard cxx_standard cxx_max_standard
#																						   internal_inc_dirs internal_defs internal_compiler_options
#																						   internal_link_flags
#																						   runtime_resources
#																						   more_sources is_loggable aliases)
#
#     Declare an  application (executable) in the currently defined package.
#
#     :c_name: the name of the application.
#     :dirname: the name of the folder that contains source code of the application.
#     :type: the type of the applciation (APPLICATION, EXAMPLE, TEST).
#     :c_standard: the C language standard used (may be empty).
#     :c_max_standard: the maximum C language standard allowed when using the component.
#     :cxx_standard: the C++ language standard used (98, 11, 14, 17).
#     :cxx_max_standard: the maximum C++ language standard allowed when using the component.
#     :internal_inc_dirs: additionnal include dirs (internal to package, that contains header files, e.g. like common definition between package components).
#     :internal_defs: preprocessor definitions used for building the application.
#     :internal_compiler_options: compiler options used for building the application.
#     :internal_link_flags: internal linker flags used to build the application.
#     :runtime_resources: list of path to files relative to share/resources folder, supposed to be used at runtime by the application.
#     :more_sources: list of path to files and folders relative to app folder, containing auxiliary sources to be used for building the application.
#     :is_loggable: if TRUE the componnet can be uniquely identified by the logging system.
#     :aliases: the list of alias for the component.
#
function(declare_Application_Component c_name dirname type
	c_standard c_max_standard cxx_standard cxx_max_standard
	internal_inc_dirs internal_defs internal_compiler_options internal_link_flags
	runtime_resources more_sources is_loggable aliases)

is_Application_Type(RES "${type}")#double check, for internal use only (purpose: simplify PID code debugging)
if(RES)
	set(${PROJECT_NAME}_${c_name}_TYPE ${type} CACHE INTERNAL "")
else() #a simple application by default
	finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR : you have to set a type name (TEST, APP, EXAMPLE) for the application component ${c_name}")
	return()
endif()

#managing sources for the application
if(	${PROJECT_NAME}_${c_name}_TYPE STREQUAL "APP"
	OR ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "EXAMPLE")
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/apps/${dirname} CACHE INTERNAL "")
elseif(	${PROJECT_NAME}_${c_name}_TYPE STREQUAL "TEST")
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/test/${dirname} CACHE INTERNAL "")
endif()
set(CURRENT_COMP_DEFINED ${c_name})
manage_Plugins_In_Package_During_Components_Description()#call plugin scripts

#manage generation of specific headers used by the logging system
if(is_loggable)
	generate_Loggable_File(PATH_TO_FILE NAME_FOR_PREPROC ${c_name} ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR} FALSE)
	list(APPEND internal_defs ${NAME_FOR_PREPROC})
endif()

# specifically managing examples
if(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "EXAMPLE")
	build_Option_For_Example(${c_name})
	add_Example_To_Doc(${c_name}) #examples are added to the doc to be referenced
	if(NOT BUILD_EXAMPLES OR NOT BUILD_EXAMPLE_${c_name}) #examples are not built so no need to continue
		mark_As_Declared(${c_name})
		set(${PROJECT_NAME}_${c_name}_FOR_DOC_ONLY TRUE PARENT_SCOPE)
		return()
	endif()
elseif(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "TEST")
	if(NOT BUILD_AND_RUN_TESTS) #tests are not built so no need to continue
		set(${PROJECT_NAME}_${c_name}_FOR_DOC_ONLY TRUE PARENT_SCOPE)
		mark_As_Declared(${c_name})
		return()
	endif()
endif()
will_be_Installed(COMP_WILL_BE_INSTALLED ${c_name})#no need to resolve since c_name defined the base component name by construction

set(use_includes ${internal_inc_dirs})
get_All_Sources_Absolute(${PROJECT_NAME}_${c_name}_ALL_SOURCES ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR})
if(more_sources)
	set(target_folders_more_sources)
	foreach(tgt IN LISTS more_sources)
		if(EXISTS ${CMAKE_SOURCE_DIR}/${tgt})
			list(APPEND target_folders_more_sources ${tgt})
		elseif(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "TEST" AND EXISTS ${CMAKE_SOURCE_DIR}/apps/${tgt})#contextual finding depending on type of component
			list(APPEND target_folders_more_sources apps/${tgt})
		elseif(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "TEST" AND EXISTS ${CMAKE_SOURCE_DIR}/test/${tgt})#contextual finding depending on type of component
			list(APPEND target_folders_more_sources test/${tgt})
		else()
			message("[PID] WARNING: in component ${c_name} you defined a path to auxiliary sources that is not referenced from project root dir")
		endif()
	endforeach()
	set(MORE_SOURCES)
	set(MORE_INCLUDES)
	get_All_Sources_Absolute_From(MORE_SOURCES MORE_INCLUDES ${CMAKE_SOURCE_DIR} "${target_folders_more_sources}")
	list(APPEND ${PROJECT_NAME}_${c_name}_ALL_SOURCES ${MORE_SOURCES})
	if(MORE_INCLUDES)
		list(APPEND use_includes ${MORE_INCLUDES})
	endif()
endif()
#defining the target to build the application

if(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "TEST")# NB : tests do not need to be relocatable since they are purely local
	create_Executable_Target(${c_name} "${c_standard}" "${cxx_standard}" "${${PROJECT_NAME}_${c_name}_ALL_SOURCES}" "${use_includes}" "${internal_defs}" "${internal_compiler_options}" "${internal_link_flags}")

	install(DIRECTORY DESTINATION ${${PROJECT_NAME}_INSTALL_RPATH_DIR}/${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX})#create the folder that will contain symbolic links (e.g. to shared libraries) used by the component (will allow full relocation of components runtime dependencies at install time)
	register_Runtime_Component_Binary(${c_name} "${${PROJECT_NAME}_${c_name}_TYPE}")#need specific recording for local runtime component since they can be used as dependencies by other internal components
else()
	create_TestUnit_Target(${c_name} "${c_standard}" "${cxx_standard}" "${${PROJECT_NAME}_${c_name}_ALL_SOURCES}" "${use_includes}" "${internal_defs}" "${internal_compiler_options}" "${internal_link_flags}")
endif()
register_Component_Binary(${c_name})# resgistering name of the executable

#registering source code for the component
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	get_All_Sources_Relative(${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR})
	set(${PROJECT_NAME}_${c_name}_SOURCE_CODE ${${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_SOURCE_DIR ${dirname} CACHE INTERNAL "")
	if(more_sources)
		get_All_Sources_Relative_From(SOURCES PATH_TO_MONITOR ${CMAKE_SOURCE_DIR} "${target_folders_more_sources}")
		set(${PROJECT_NAME}_${c_name}_AUX_SOURCE_CODE ${SOURCES} CACHE INTERNAL "")
		set(${PROJECT_NAME}_${c_name}_AUX_MONITORED_PATH ${PATH_TO_MONITOR} CACHE INTERNAL "")
	endif()
endif()

# registering exported flags for all kinds of apps => empty variables (except runtime resources since applications export no flags)
init_Component_Cached_Variables_For_Export(${c_name} "${c_standard}" "${c_max_standard}" "${cxx_standard}" "${cxx_max_standard}" "" "" "" "${runtime_resources}" "${aliases}")

if(aliases)#create alias target on demand
	add_Alias_To_Cache(${c_name} "${aliases}")
	create_Alias_Exe_Target(${PROJECT_NAME} ${c_name} "${aliases}" "${INSTALL_NAME_SUFFIX}")
endif()

#updating global variables of the CMake process
append_Unique_In_Cache(${PROJECT_NAME}_COMPONENTS ${c_name})
append_Unique_In_Cache(${PROJECT_NAME}_COMPONENTS_APPS ${c_name})
# global variable to know that the component has been declared  (must be reinitialized at each run of cmake)
mark_As_Declared(${c_name})
#finaly apply plugins actions
manage_Plugins_Contribution_Into_Current_Component()
#automatically manage implicit platform constraints
foreach(config IN LISTS ${PROJECT_NAME}_IMPLICIT_PLATFORM_CONSTRAINTS${VAR_SUFFIX})
	declare_System_Component_Dependency_Using_Configuration(
		${c_name}
		FALSE
		${config}
		"" "" ""
	)
endforeach()
endfunction(declare_Application_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Python_Component| replace:: ``declare_Python_Component``
#  .. _declare_Python_Component:
#
#  declare_Python_Component
#  ------------------------
#
#   .. command:: declare_Python_Component(c_name dirname)
#
#     Declare a python package.
#
#     :c_name: the name of the python package.
#     :dirname: the name of the folder that contains script of the python package.
#
function(declare_Python_Component	c_name dirname)
set(${PROJECT_NAME}_${c_name}_TYPE "PYTHON" CACHE INTERNAL "")
#registering source code for the component
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/share/script/${dirname} CACHE INTERNAL "")
	get_All_Sources_Relative(${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE ${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR})
	set(${PROJECT_NAME}_${c_name}_SOURCE_CODE ${${PROJECT_NAME}_${c_name}_ALL_SOURCES_RELATIVE} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_SOURCE_DIR ${dirname} CACHE INTERNAL "")
	if(more_sources)
		get_All_Sources_Relative_From(SOURCES PATH_TO_MONITOR ${CMAKE_SOURCE_DIR} "${more_sources}")
		set(${PROJECT_NAME}_${c_name}_AUX_SOURCE_CODE ${SOURCES} CACHE INTERNAL "")
		set(${PROJECT_NAME}_${c_name}_AUX_MONITORED_PATH ${PATH_TO_MONITOR} CACHE INTERNAL "")
	endif()
endif()
manage_Python_Scripts(${c_name} ${dirname})
#updating global variables of the CMake process
append_Unique_In_Cache(${PROJECT_NAME}_COMPONENTS ${c_name})
append_Unique_In_Cache(${PROJECT_NAME}_COMPONENTS_SCRIPTS ${c_name})
# global variable to know that the component has been declared  (must be reinitialized at each run of cmake)
mark_As_Declared(${c_name})
endfunction(declare_Python_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Native_Package_Dependency| replace:: ``declare_Native_Package_Dependency``
#  .. _declare_Native_Package_Dependency:
#
#  declare_Native_Package_Dependency
#  ---------------------------------
#
#   .. command:: declare_Native_Package_Dependency(dep_package optional all_possible_versions all_exact_versions list_of_components)
#
#     Specify a dependency between the currently defined package and another native package.
#
#     :dep_package: the package that is the dependency.
#     :optional: if TRUE the dependency is optional.
#     :all_possible_versions: the list of possible incompatible versions for the dependency.
#     :all_exact_versions: the list of exact version among possible ones.
#     :list_of_components: the list of required components that must belong to dependency.
#
function(declare_Native_Package_Dependency dep_package optional all_possible_versions all_exact_versions list_of_components)
	set(unused FALSE)
	### 0) for native package we need to prepare the list of version to make it full of version numbers with exactly 3 digits
	set(list_of_possible_versions)
	set(list_of_exact_versions)
	if(all_possible_versions)
		set(list_of_possible_versions ${all_possible_versions})
		set(list_of_exact_versions ${all_exact_versions})
		# foreach(ver IN LISTS all_possible_versions)
		# 	normalize_Version_String(${ver} NORM_STR)
		# 	list(APPEND list_of_possible_versions ${NORM_STR})
		# endforeach()
		# foreach(ver IN LISTS all_exact_versions)
		# 	normalize_Version_String(${ver} NORM_STR)
		# 	list(APPEND list_of_exact_versions ${NORM_STR})
		# endforeach()
		list(LENGTH list_of_possible_versions SIZE)
		list(GET list_of_possible_versions 0 default_version) #by defaut this is the first element in the list that is taken
	endif()
	set_Dependency_Complete_Description(${dep_package} FALSE list_of_possible_versions list_of_exact_versions)
	### 1) setting user cache variable. The goal is to given users the control "by-hand" on the version used for a given dependency ###
	#1.A) preparing message coming with this user cache variable
	if(NOT list_of_possible_versions) # no version constraint specified
		set(message_str "Input a valid version of dependency ${dep_package} or use ANY.")
	else()#there are version specified
		fill_String_From_List(available_versions list_of_possible_versions ", ") #get available version as a string (used to print them)
		set(message_str "Input a valid version of dependency ${dep_package} among versions: ${available_versions}.")
	endif()
	if(optional) #message for the optional dependency includes the possiiblity to input NONE
		set(message_str "${message_str} Or use NONE to avoid using this dependency.")
	endif()
	#1.B) creating the user cache entries
	if(NOT list_of_possible_versions) # no version constraint specified
		### setting default cache variable that user can directly manage "by-hand" ###
		if(optional)
			#set the cache option, NONE by default
			set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "${message_str}")
		else()#dependency is not optional so any version can be used
			set(${dep_package}_ALTERNATIVE_VERSION_USED "ANY" CACHE STRING "${message_str}")#no message since nothing to say to the user
		endif()
	else()#there are version(s) specified
		#first do some checks
		if(optional)
			# since dependency is optional, we simply just do not use it by default to avoid unresolvable configuration
			set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "${message_str}.")#initial value set to unused
		else() #version of a required dependency
			if(SIZE EQUAL 1)#no alternative a given version constraint must be satisfied
				set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE INTERNAL "" FORCE)#do not show the variable to the user
			else() #we can choose among many versions, use the first specified by default
				set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE STRING "${message_str}")
			endif()
		endif()
	endif()
	### 2) check and set the value of the user cache entry dependening on constraints coming from the build context (dependent build or classical build) #####
	# check if a version of this dependency is required by another package used in the current build process and memorize this version
	set(USE_EXACT FALSE)
	get_Chosen_Version_In_Current_Process(REQUIRED_VERSION VERSION_REQUESTORS IS_EXACT IS_SYSTEM ${dep_package})
	if(REQUIRED_VERSION) #the package is already used as a dependency in the current build process so we need to reuse the version already specified or use a compatible one instead
		if(list_of_possible_versions) #list of possible versions is constrained
			#finding the best compatible version, if any (otherwise returned "version" variable is empty)
			find_Best_Compatible_Version(force_version FALSE ${dep_package} ${REQUIRED_VERSION} "${IS_EXACT}" FALSE "${list_of_possible_versions}" "${list_of_exact_versions}")
			if(NOT force_version)#the build context is a dependent build and no compatible version has been found
				if(optional)#hopefully the dependency is optional so we can deactivate it
					set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "${message_str}" FORCE)
					message("[PID] WARNING : dependency ${dep_package} for package ${PROJECT_NAME} is optional and has been automatically deactivated as its version (${force_version}) is not compatible with version ${REQUIRED_VERSION} previously required by other packages.")
				else()#this is to ensure that on a dependent build an adequate version has been chosen from the list of possible versions
					finish_Progress(${GLOBAL_PROGRESS_VAR})
					fill_String_From_List(RES_REQ VERSION_REQUESTORS ", ")
					message(FATAL_ERROR "[PID] CRITICAL ERROR : In ${PROJECT_NAME} dependency ${dep_package} is used with possible versions: ${available_versions}. But incompatible version ${REQUIRED_VERSION} is already used in packages: ${RES_REQ}.")
					return()
				endif()
			else()
				if(SIZE EQUAL 1)#no alternative a given version constraint must be satisfied
					set(${dep_package}_ALTERNATIVE_VERSION_USED ${force_version} CACHE INTERNAL "" FORCE)#do not show the variable to the user
				else() #we can choose among many versions, use the first specified by default
					set(${dep_package}_ALTERNATIVE_VERSION_USED ${force_version} CACHE STRING "${message_str}" FORCE)#explicitlty set the dependency to the chosen version number
				endif()
			endif()
		else()#no constraint on version => use the required one
			set(${dep_package}_ALTERNATIVE_VERSION_USED ${REQUIRED_VERSION} CACHE STRING "${message_str}" FORCE)#explicitlty set the dependency to the chosen version number
		endif()
		set(USE_EXACT ${IS_EXACT})
	else()#classical build
		if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED)#SPECIAL CASE: no value set by user (i.e. error of the user)!!
			if(optional)#hopefully the dependency is optional so we can force its deactivation
				set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "${message_str}" FORCE)#explicitlty deactivate the optional dependency (corrective action)
				message("[PID] WARNING : dependency ${dep_package} for package ${PROJECT_NAME} is optional and has been automatically deactivated because no version was specified by the user.")
			elseif(list_of_possible_versions)
					if(SIZE EQUAL 1)#only one possible version => do not provide it to to user
						set(${dep_package}_ALTERNATIVE_VERSION_USED ${list_of_possible_versions} CACHE INTERNAL "" FORCE)
					else()
						set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE STRING "${message_str}" FORCE)
					endif()
			else()
				set(${dep_package}_ALTERNATIVE_VERSION_USED "ANY" CACHE STRING "${message_str}" FORCE)
			endif()
		else()#there is a value for the ALTERNATIVE variable
			if(list_of_possible_versions)#there is a constraint on usable versions
				if(${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "ANY")#the value in cache was previously ANY but user added a list of versions in the meantime
					if(SIZE EQUAL 1)#only one possible version => no more provide it to to user
						set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE INTERNAL "" FORCE)
					else()#many possible versions now !!
						set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE STRING "${message_str}" FORCE)
					endif()
				else()#a version has been given explicitly (either from dependent build or directly by the user)
					list(FIND list_of_possible_versions ${${dep_package}_ALTERNATIVE_VERSION_USED} INDEX)
					if(INDEX EQUAL -1 )#no possible version found -> may be due to a change in cmake description of possible versions
						#simply reset the description to first found
						if(SIZE EQUAL 1)#only one possible version => no more provide it to to user
							set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE INTERNAL "" FORCE)
						else()#many possible versions now !!
							set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE STRING "${message_str}" FORCE)
						endif()
					endif()
				endif()
				if(list_of_exact_versions)
					list(FIND list_of_exact_versions ${${dep_package}_ALTERNATIVE_VERSION_USED} INDEX)
					if(NOT INDEX EQUAL -1 )
						set(USE_EXACT TRUE)
					endif()
				endif()
			endif()
		endif()
	endif()

	### 3) setting internal cache variable used to generate the use file and to resolve find operations
	# they are simply set from the value of the alternative and depending on
	if(${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "NONE")
		set(unused TRUE)
	elseif(${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "ANY")# any version can be used so for now no contraint
		add_Package_Dependency_To_Cache(${dep_package} "" FALSE "${list_of_components}")
	else()#a version is specified by the user OR the dependent build process has automatically set it
		add_Package_Dependency_To_Cache(${dep_package} "${${dep_package}_ALTERNATIVE_VERSION_USED}" "${USE_EXACT}" "${list_of_components}") #set the dependency
	endif()

	# 4) resolve the package dependency according to memorized internal variables
	if(NOT unused) #if the dependency is really used (in case it were optional and unselected by user)
		if(NOT ${dep_package}_FOUND${USE_MODE_SUFFIX})#testing if the package has been previously found locally or not
			#package has never been found by a direct call to find_package in root CMakeLists.txt
			resolve_Native_Package_Dependency(IS_VERSION_COMPATIBLE IS_ABI_COMPATIBLE ${PROJECT_NAME} ${dep_package} ${CMAKE_BUILD_TYPE})
			if(NOT IS_VERSION_COMPATIBLE)# version compatiblity problem => no adequate solution with constraint imposed by a dependent build
				finish_Progress(${GLOBAL_PROGRESS_VAR})
				set(message_versions "")
				if(${dep_package}_ALL_REQUIRED_VERSIONS)
					set(message_versions "All non exact required versions are : ${${dep_package}_ALL_REQUIRED_VERSIONS}")
				elseif(${dep_package}_REQUIRED_VERSION_EXACT)#the exact required version is contained in ${dep_package}_REQUIRED_VERSION_EXACT variable.
					set(message_versions "Exact version already required is ${${dep_package}_REQUIRED_VERSION_EXACT}")
				endif()
				message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent package ${dep_package} regarding versions constraints. Search ended when trying to satisfy version ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}} coming from package ${PROJECT_NAME}. ${message_versions}. Try to put this dependency as first dependency in your CMakeLists.txt in order to force its version constraint before any other.")
				return()
			elseif(${dep_package}_FOUND${USE_MODE_SUFFIX})
				if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "ANY")#do not propagate choice if none made
					add_Chosen_Package_Version_In_Current_Process(${dep_package} ${PROJECT_NAME})
				endif()
				if(NOT IS_ABI_COMPATIBLE)#need to reinstall the package anyway because it is not compatible with current platform
					#from here we can add it to versions to install (force reinstall)
					add_To_Install_Package_Specification(${dep_package} "${${dep_package}_VERSION_STRING}" ${USE_EXACT})
				endif()
			endif()#if not found after resolution simply wait it to be installed automatically
		else()#if found before this call (security when a basic find_package has been used previously)
			if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "ANY")#do not propagate choice if none made
				add_Chosen_Package_Version_In_Current_Process(${dep_package} ${PROJECT_NAME})#FOR compatibility: report the choice made to global build process
			endif()
		endif()#otherwise nothing more to do
	endif()
endfunction(declare_Native_Package_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_External_Package_Dependency| replace:: ``declare_External_Package_Dependency``
#  .. _declare_External_Package_Dependency:
#
#  declare_External_Package_Dependency
#  -----------------------------------
#
#   .. command:: declare_External_Package_Dependency(dep_package optional list_of_possible_versions list_of_exact_versions list_of_components)
#
#     Specify a dependency between the currently defined native package and an external package.
#
#     :dep_package: the external package that is the dependency.
#     :optional: if TRUE the dependency is optional.
#     :list_of_possible_versions: the list of possible incompatible versions for the dependency.
#     :list_of_exact_versions: the list of exact version among possible ones.
#     :list_of_components: the list of required components that must belong to dependency.
#
function(declare_External_Package_Dependency dep_package optional list_of_possible_versions list_of_exact_versions list_of_components)
set(unused FALSE)
set_Dependency_Complete_Description(${dep_package} TRUE list_of_possible_versions list_of_exact_versions)
### 1) setting user cache variable. The goal is to given users the control "by-hand" on the version used for a given dependency ###
#1.A) preparing message coming with this user cache variable
if(NOT list_of_possible_versions) # no version constraint specified
	set(message_str "Input version of dependency ${dep_package} or use ANY.")
else()#there are version specified
	fill_String_From_List(available_versions list_of_possible_versions ", ") #get available version as a string (used to print them)
	set(message_str "Input version of dependency ${dep_package} among: ${available_versions}.")
	list(LENGTH list_of_possible_versions SIZE)
	list(GET list_of_possible_versions 0 default_version) #by defaut this is the first element in the list that is taken
endif()
if(optional) #message for the optional dependency includes the possiiblity to input NONE
	set(message_str "${message_str} Or use NONE to avoid using this dependency.")
endif()
#1.B) creating the user cache entries
if(NOT list_of_possible_versions) # no version constraint specified
	### setting default cache variable that user can directly manage "by-hand" ###
	if(optional)
		#set the cache option, NONE by default
		set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "${message_str}")
	else()#dependency is not optional so any version can be used
		set(${dep_package}_ALTERNATIVE_VERSION_USED "ANY" CACHE STRING "${message_str}")#no message since nothing to say to the user
	endif()
else()#there are version(s) specified
	if(optional)
		# since dependency is optional, we simply just do not use it by default to avoid unresolvable configuration
		set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "${message_str}.")#initial value set to unused
	else() #version of a required dependency
		if(SIZE EQUAL 1)#no alternative a given version constraint must be satisfied
			set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE INTERNAL "" FORCE)#do not show the variable to the user
		else() #we can choose among many versions, use the first specified by default
			set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE STRING "${message_str}")
		endif()
	endif()
endif()

### 2) check and set the value of the user cache entry dependening on constraints coming from the build context (dependent build or classical build) #####
set(USE_EXACT FALSE)
set(chosen_version_for_selection)
# check if a version of this dependency is required by another package used in the current build process and memorize this version
get_Chosen_Version_In_Current_Process(REQUIRED_VERSION VERSION_REQUESTORS IS_EXACT IS_SYSTEM ${dep_package})
if(REQUIRED_VERSION) #the package is already used as a dependency in the current build process so we need to reuse the version already specified or use a compatible one instead
	if(list_of_possible_versions) #list of possible versions is constrained
		#finding the best compatible version, if any (otherwise returned "version" variable is empty)
		find_Best_Compatible_Version(force_version TRUE ${dep_package} ${REQUIRED_VERSION} "${IS_EXACT}" "${IS_SYSTEM}" "${list_of_possible_versions}" "${list_of_exact_versions}")
		if(NOT force_version)#the build context is a dependent build and no compatible version has been found
			if(optional)#hopefully the dependency is optional so we can deactivate it
				set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "${message_str}" FORCE)
				message("[PID] WARNING : dependency ${dep_package} for package ${PROJECT_NAME} is optional and has been automatically deactivated as its version (${force_version}) is not compatible with version ${REQUIRED_VERSION} previously required by other packages.")
			else()#this is to ensure that on a dependent build an adequate version has been chosen from the list of possible versions
				finish_Progress(${GLOBAL_PROGRESS_VAR})
				fill_String_From_List(RES_REQ VERSION_REQUESTORS ", ")
				if(RES_REQ STREQUAL PROJECT_NAME)
					#specific case : the dependency has been previously requested (directly or undirectly) as an OS dependency
					message(FATAL_ERROR "[PID] INFO : In ${PROJECT_NAME}, dependency ${dep_package} is used with possible versions: ${available_versions}, but incompatible OS version ${REQUIRED_VERSION} has been previously required in the build process. Ask developpers of ${dep_package} wrapper to provide a receipe for this version or ask them to update the contribution space where ${dep_package} is referenced.")
				else()
					message(FATAL_ERROR "[PID] INFO : In ${PROJECT_NAME}, dependency ${dep_package} is used with possible versions: ${available_versions}. But incompatible version ${REQUIRED_VERSION} is already used in packages: ${RES_REQ}.")
				endif()
				return()
			endif()
		else()#a version is forced
			if(IS_SYSTEM)
				set(chosen_version_for_selection "SYSTEM")#specific keyword to use to specify that the SYSTEM version is in use
			else()
				set(chosen_version_for_selection ${force_version})
			endif()
			#simply reset the description to first found
			if(SIZE EQUAL 1)#only one possible version => no more provide it to to user
				set(${dep_package}_ALTERNATIVE_VERSION_USED ${chosen_version_for_selection} CACHE INTERNAL "" FORCE)
			else()#many possible versions now !!
				set(${dep_package}_ALTERNATIVE_VERSION_USED ${chosen_version_for_selection} CACHE STRING "${message_str}" FORCE)
			endif()
		endif()
	else()#no constraint on version => use the required one
		if(IS_SYSTEM)
			set(chosen_version_for_selection "SYSTEM")#specific keyword to use to specify that the SYSTEM version is in use
		else()
			set(chosen_version_for_selection ${REQUIRED_VERSION})
		endif()
		set(${dep_package}_ALTERNATIVE_VERSION_USED ${chosen_version_for_selection} CACHE STRING "${message_str}" FORCE)#explicitlty set the dependency to the chosen version number
	endif()
	set(USE_EXACT ${IS_EXACT})

else()#classical build => perform only corrective actions if cache variable is no more compatible with user specifications
	if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED)#SPECIAL CASE: no value set by user (i.e. error of the user)!!
		if(optional)#hopefully the dependency is optional so we can force its deactivation
			set(${dep_package}_ALTERNATIVE_VERSION_USED "NONE" CACHE STRING "${message_str}" FORCE)#explicitlty deactivate the optional dependency (corrective action)
			message("[PID] WARNING : dependency ${dep_package} for package ${PROJECT_NAME} is optional and has been automatically deactivated because no version was specified by the user.")
		elseif(list_of_possible_versions)#set if to default version
			if(SIZE EQUAL 1)#only one possible version => do not provide it to to user
				set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE INTERNAL "" FORCE)
			else()
				set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE STRING "${message_str}" FORCE)
			endif()
		else()#set if to ANY version
			set(${dep_package}_ALTERNATIVE_VERSION_USED "ANY" CACHE STRING "${message_str}" FORCE)
		endif()

	else()#OK the variable ${dep_package}_ALTERNATIVE_VERSION_USED has a value
		if(list_of_possible_versions)#there is a constraint on usable versions
			if(${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "ANY")#the value in cache was previously ANY but user added a list of versions in the meantime
				if(SIZE EQUAL 1)#only one possible version => no more provide it to to user
					set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE INTERNAL "" FORCE)
				else()
					set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE STRING "${message_str}" FORCE)
				endif()
			else()#the value is a version, check if this version is allowed
				if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "SYSTEM")#check version specified by user except if system is required
					list(FIND list_of_possible_versions ${${dep_package}_ALTERNATIVE_VERSION_USED} INDEX)
					if(INDEX EQUAL -1)#no possible version found -> bad input of the user
						message("[PID] WARNING: version constraint given by user for dependency ${dep_package} (${${dep_package}_ALTERNATIVE_VERSION_USED}) is not possible ... fixing to default version (${default_version}).")
						#simply reset the description to first found
						if(SIZE EQUAL 1)#only one possible version => no more provide it to to user
							set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE INTERNAL "" FORCE)
						else()#many possible versions now !!
							set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE STRING "${message_str}" FORCE)
						endif()
					endif()
				else()#system dependency
					set(need_reset FALSE)
					check_Platform_Configuration(RESULT_OK CONFIG_NAME CONFIG_CONSTRAINTS ${PROJECT_NAME} "${dep_package}" ${CMAKE_BUILD_TYPE})
					if(NOT RESULT_OK OR NOT ${PROJECT_NAME}_${dep_package}_VERSION)
						set(need_reset TRUE)
					else()
						list(FIND list_of_possible_versions ${${PROJECT_NAME}_${dep_package}_VERSION} INDEX)
						if(INDEX EQUAL -1)#no possible version found -> bad input of the user or dependent build
							set(need_reset TRUE)
						endif()
					endif()
					if(need_reset)
						#reset all information about the system variant to enforce a good resolution
						reset_Platform_Configuration_Cache_Variables(${dep_package})
						unset(${PROJECT_NAME}_${dep_package}_VERSION CACHE)
						unset(${dep_package}_VERSION CACHE)#FOR COMPATIBILITY
						unset(${dep_package}_VERSION_STRING CACHE)
						unset(${dep_package}_REQUIRED_VERSION_EXACT CACHE)
						unset(${dep_package}_REQUIRED_VERSION_SYSTEM CACHE)
						remove_Chosen_Package_Version_In_Current_Process(${dep_package} ${PROJECT_NAME})#this is necessary as check_Platform_Configuration may have generated a coice that is finally invalid
						message("[PID] WARNING: SYSTEM version constraint given by user for dependency ${dep_package} is not possible ... fixing to default version (${default_version}).")
						#simply reset the description to first found
						if(SIZE EQUAL 1)#only one possible version => no more provide it to to user
							set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE INTERNAL "" FORCE)
						else()#many possible versions now !!
							set(${dep_package}_ALTERNATIVE_VERSION_USED ${default_version} CACHE STRING "${message_str}" FORCE)
						endif()
					endif()
				endif()
			endif()
		endif()
	endif()
	#now checking if the selected version is forced to be exact
	if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "SYSTEM")
		if(list_of_exact_versions)
			list(FIND list_of_exact_versions ${${dep_package}_ALTERNATIVE_VERSION_USED} INDEX)
			if(NOT INDEX EQUAL -1 )
				set(USE_EXACT TRUE)
			endif()
		endif()
	else()#if system it is always exact
		set(USE_EXACT TRUE)
	endif()
endif()
### 3) setting internal cache variable used to generate the use file and to resolve find operations
# they are simply set from the value of the alternative and depending on
if(${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "NONE")
	set(unused TRUE)
elseif(${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "SYSTEM")#the system version has been selected => need to perform specific actions
	#need to check the equivalent OS configuration to get the OS installed version
	check_Platform_Configuration(RESULT_OK CONFIG_NAME CONFIG_CONSTRAINTS ${PROJECT_NAME} "${dep_package}" ${CMAKE_BUILD_TYPE})
	if(NOT RESULT_OK OR NOT ${PROJECT_NAME}_${dep_package}_VERSION)
		finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR : In ${PROJECT_NAME} dependency ${dep_package} is defined with SYSTEM version but this version cannot be found on OS.")
		return()
	endif()
	add_External_Package_Dependency_To_Cache(${dep_package} "${${PROJECT_NAME}_${dep_package}_VERSION}" TRUE TRUE "${list_of_components}") #set the dependency
elseif(${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "ANY")# any version can be used so for now no contraint
	add_External_Package_Dependency_To_Cache(${dep_package} "" FALSE FALSE "${list_of_components}")
else()#a version is specified by the user OR the dependent build process has automatically set it
	add_External_Package_Dependency_To_Cache(${dep_package} "${${dep_package}_ALTERNATIVE_VERSION_USED}" ${USE_EXACT} FALSE "${list_of_components}") #set the dependency
endif()

# 4) resolve the package dependency according to memorized internal variables
if(NOT unused) #if the dependency is really used (in case it were optional and unselected by user)
	# try to find the adequate package version => it is necessarily required
	if(NOT ${dep_package}_FOUND${USE_MODE_SUFFIX})#testing if the package has been previously found or not
		#package has never been found by a direct call to find_package in root CMakeLists.txt
		resolve_External_Package_Dependency(IS_VERSION_COMPATIBLE IS_ABI_COMPATIBLE ${PROJECT_NAME} ${dep_package} ${CMAKE_BUILD_TYPE})
		if(NOT IS_VERSION_COMPATIBLE)# version compatiblity problem => no adequate solution with constraint imposed by a dependent build
			finish_Progress(${GLOBAL_PROGRESS_VAR})
			set(message_versions "")
			if(${dep_package}_ALL_REQUIRED_VERSIONS)
				set(message_versions "All non exact required versions are : ${${dep_package}_ALL_REQUIRED_VERSIONS}")
			elseif(${dep_package}_REQUIRED_VERSION_EXACT)#the exact required version is contained in ${dep_package}_REQUIRED_VERSION_EXACT variable.
				if(${dep_package}_REQUIRED_VERSION_SYSTEM)
					set(message_versions "OS installed version already required is ${${dep_package}_REQUIRED_VERSION_EXACT}")
				else()
					set(message_versions "Exact version already required is ${${dep_package}_REQUIRED_VERSION_EXACT}")
				endif()
			endif()
			message(FATAL_ERROR "[PID] CRITICAL ERROR : impossible to find compatible versions of dependent package ${dep_package} regarding versions constraints. Search ended when trying to satisfy version ${${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX}} coming from package ${PROJECT_NAME}. ${message_versions}. Try to put this dependency as first dependency in your CMakeLists.txt in order to force its version constraint before any other.")
			return()
		elseif(${dep_package}_FOUND${USE_MODE_SUFFIX})#dependency has been found in workspace after resolution
			if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "ANY")
				add_Chosen_Package_Version_In_Current_Process(${dep_package} ${PROJECT_NAME})#report the choice made to global build process
			endif()
			if(NOT IS_ABI_COMPATIBLE)#need to reinstall the package anyway because it is not compatible with current platform
				#from here we can add it to versions to install to force reinstall
				if(${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "SYSTEM")
					add_To_Install_External_Package_Specification(${dep_package} "${${dep_package}_VERSION}" TRUE TRUE)
				else()
					add_To_Install_External_Package_Specification(${dep_package} "${${dep_package}_VERSION}" ${USE_EXACT} FALSE)
				endif()
			endif()
		endif()
	else()#if was found prior to this call
		if(NOT ${dep_package}_ALTERNATIVE_VERSION_USED STREQUAL "ANY")
			add_Chosen_Package_Version_In_Current_Process(${dep_package} ${PROJECT_NAME})#report the choice made to global build process
		endif()
	endif()
endif()
endfunction(declare_External_Package_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Internal_Component_Dependency| replace:: ``declare_Internal_Component_Dependency``
#  .. _declare_Internal_Component_Dependency:
#
#  declare_Internal_Component_Dependency
#  -------------------------------------
#
#   .. command:: declare_Internal_Component_Dependency(component dep_component export comp_defs comp_exp_defs dep_defs)
#
#     Specify a dependency between two components of the currently defined native package.
#
#     :component: the name of the component that have a dependency.
#     :dep_component: the name of the component that IS the dependency.
#     :export: if TRUE component exports dep_component (i.e. public headers of component include public headers of dep_component)
#     :comp_defs: preprocessor definitions in the implementation of component that conditionnate the use of dep_component (may be an empty string). These definitions are not exported by component.
#     :comp_exp_defs: preprocessor definitions in the interface (public headers) of component that conditionnate the use of dep_component (may be an empty string). These definitions are exported by component.
#     :dep_defs: preprocessor definitions used in the interface of dep_component, that are set when component uses dep_component (may be an empty string). These definitions are exported if dep_component is exported by component.
#
function(declare_Internal_Component_Dependency component dep_component export comp_defs comp_exp_defs dep_defs)
set(COMP_WILL_BE_BUILT FALSE)
set(DECLARED_COMP)
is_Declared(${component} DECLARED_COMP)
if(NOT DECLARED_COMP)
	finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR when defining dependency for ${component} in ${PROJECT_NAME} : component ${component} is not defined in current package ${PROJECT_NAME}.")
endif()
will_be_Built(COMP_WILL_BE_BUILT ${DECLARED_COMP})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()
set(DECLARED_DEP)
is_Declared(${dep_component} DECLARED_DEP)
if(NOT DECLARED_DEP)
	is_Predeclared(${dep_component} PREDECLARED_DEP)
	set(DECLARED_DEP ${PREDECLARED_DEP})
	if(NOT PREDECLARED_DEP)
		finish_Progress(${GLOBAL_PROGRESS_VAR})
		message(FATAL_ERROR "[PID] CRITICAL ERROR when when defining dependency for ${component} in ${PROJECT_NAME} : dependency ${dep_component} is not defined in current package ${PROJECT_NAME}.")
	endif()
endif()
#guarding depending type of involved components
is_HeaderFree_Component(IS_HF_COMP ${PROJECT_NAME} ${DECLARED_COMP})
is_HeaderFree_Component(IS_HF_DEP ${PROJECT_NAME} ${DECLARED_DEP})
is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${DECLARED_COMP})
set(${PROJECT_NAME}_${DECLARED_COMP}_INTERNAL_EXPORT_${DECLARED_DEP}${USE_MODE_SUFFIX} FALSE CACHE INTERNAL "")#export always expressed relative to realcomponent name, not relative to aliases
if (IS_HF_COMP)
		if(IS_HF_DEP)
			# setting compile definitions for configuring the target
			fill_Component_Target_With_Dependency(${DECLARED_COMP} ${PROJECT_NAME} ${DECLARED_DEP} ${CMAKE_BUILD_TYPE} FALSE "${comp_defs}" "" "")
		else()
			# setting compile definitions for configuring the target
			fill_Component_Target_With_Dependency(${DECLARED_COMP} ${PROJECT_NAME} ${DECLARED_DEP} ${CMAKE_BUILD_TYPE} FALSE "${comp_defs}" "" "${dep_defs}")
		endif()
elseif(IS_BUILT_COMP)
	if(IS_HF_DEP)
		configure_Install_Variables_From_Dependency(${DECLARED_COMP} FALSE "" "" "" "${comp_exp_defs}" "" "" "" "" "" "" "" "")
		# setting compile definitions for configuring the target
		fill_Component_Target_With_Dependency(${DECLARED_COMP} ${PROJECT_NAME} ${DECLARED_DEP} ${CMAKE_BUILD_TYPE} FALSE "${comp_defs}" "${comp_exp_defs}" "")

	else()
		#prepare the dependancy export
		if(export)
			set(${PROJECT_NAME}_${DECLARED_COMP}_INTERNAL_EXPORT_${DECLARED_DEP}${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "")
		endif()
		configure_Install_Variables_From_Dependency(${DECLARED_COMP} ${export} "" "" "${dep_defs}" "${comp_exp_defs}" "" "" "" "" "" "" "" "")

		# setting compile definitions for configuring the target
		fill_Component_Target_With_Dependency(${DECLARED_COMP} ${PROJECT_NAME} ${DECLARED_DEP} ${CMAKE_BUILD_TYPE} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
	endif()
elseif(	${PROJECT_NAME}_${DECLARED_COMP}_TYPE STREQUAL "HEADER")
	if(IS_HF_DEP)
		configure_Install_Variables_From_Dependency(${DECLARED_COMP} FALSE "" "" "" "${comp_exp_defs}" "" "" "" "" "" "" "" "")
		fill_Component_Target_With_Dependency(${DECLARED_COMP} ${PROJECT_NAME} ${DECLARED_DEP} ${CMAKE_BUILD_TYPE} FALSE "" "${comp_exp_defs}" "")

	else()
		#prepare the dependancy export
		set(${PROJECT_NAME}_${DECLARED_COMP}_INTERNAL_EXPORT_${DECLARED_DEP}${USE_MODE_SUFFIX} TRUE CACHE INTERNAL "") #export is necessarily true for a pure header library
		configure_Install_Variables_From_Dependency(${DECLARED_COMP} TRUE "" "" "${dep_defs}" "${comp_exp_defs}" "" "" "" "" "" "" "" "")
		# setting compile definitions for configuring the "fake" target
		fill_Component_Target_With_Dependency(${DECLARED_COMP} ${PROJECT_NAME} ${DECLARED_DEP} ${CMAKE_BUILD_TYPE} TRUE "" "${comp_exp_defs}" "${dep_defs}")

	endif()
else()
	message (FATAL_ERROR "[PID] CRITICAL ERROR when building ${component} in ${PROJECT_NAME} : unknown type (${${PROJECT_NAME}_${DECLARED_COMP}_TYPE}) for component ${component} of package ${PROJECT_NAME}.")
	return()
endif()
# include directories and links do not require to be added
# declare the internal dependency
append_Unique_In_Cache(${PROJECT_NAME}_${DECLARED_COMP}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${DECLARED_DEP})
endfunction(declare_Internal_Component_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_Package_Component_Dependency| replace:: ``declare_Package_Component_Dependency``
#  .. _declare_Package_Component_Dependency:
#
#  declare_Package_Component_Dependency
#  ------------------------------------
#
#   .. command:: declare_Package_Component_Dependency(component dep_package dep_component export comp_defs comp_exp_defs dep_defs)
#
#     Specify a dependency between a component of the currently defined native package and a component belonging to another native package.
#
#     :component: the name of the component that have a dependency.
#     :dep_package: the name of the package that contains the dependency.
#     :dep_component: the name of the component that IS the dependency,which belongs to dep_package.
#     :export: if TRUE component exports dep_component (i.e. public headers of component include public headers of dep_component)
#     :comp_defs: preprocessor definitions in the implementation of component that conditionnate the use of dep_component (may be an empty string). These definitions are not exported by component.
#     :comp_exp_defs: preprocessor definitions in the interface (public headers) of component that conditionnate the use of dep_component (may be an empty string). These definitions are exported by component.
#     :dep_defs: preprocessor definitions used in the interface of dep_component, that are set when component uses dep_component (may be an empty string). These definitions are exported if dep_component is exported by component.
#
function(declare_Package_Component_Dependency component dep_package dep_component export comp_defs comp_exp_defs dep_defs)
set(DECLARED_COMP)
is_Declared(${component} DECLARED_COMP)
if(NOT DECLARED_COMP)
	finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR when defining dependency for ${component} in ${PROJECT_NAME} : component ${component} is not defined in current package ${PROJECT_NAME}.")
endif()
will_be_Built(COMP_WILL_BE_BUILT ${DECLARED_COMP})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()
rename_If_Alias(dep_name_to_use ${dep_package} ${dep_component})
list(FIND ${dep_package}_COMPONENTS ${dep_name_to_use} INDEX)
if(INDEX EQUAL -1)
	message (FATAL_ERROR "[PID] CRITICAL ERROR when declaring dependency to component ${dep_component} of package ${dep_package} in ${PROJECT_NAME} : this component does not exist !")
endif()
set(${PROJECT_NAME}_${DECLARED_COMP}_EXPORT_${dep_package}_${dep_name_to_use} FALSE CACHE INTERNAL "")#Note: alawys use teh resolved alias name in current package
#guarding depending type of involved components
is_HeaderFree_Component(IS_HF_COMP ${PROJECT_NAME} ${DECLARED_COMP})
is_HeaderFree_Component(IS_HF_DEP ${dep_package} ${dep_name_to_use})
is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${DECLARED_COMP})
if (IS_HF_COMP)
	# setting compile definitions for configuring the target
	if(IS_HF_DEP)#the dependency has no build interface(header free) => it is a runtime dependency
		fill_Component_Target_With_Dependency(${DECLARED_COMP} ${dep_package} ${dep_name_to_use} ${CMAKE_BUILD_TYPE} FALSE "${comp_defs}" "" "")
	else()	#the dependency has a build interface
		fill_Component_Target_With_Dependency(${DECLARED_COMP} ${dep_package} ${dep_name_to_use} ${CMAKE_BUILD_TYPE} FALSE "${comp_defs}" "" "${dep_defs}")
	#do not export anything
	endif()
elseif(IS_BUILT_COMP)
	if(IS_HF_DEP)#the dependency has no build interface(header free) => it is a runtime dependency
		# setting compile definitions for configuring the target
		fill_Component_Target_With_Dependency(${DECLARED_COMP} ${dep_package} ${dep_name_to_use} ${CMAKE_BUILD_TYPE} FALSE "${comp_defs}" "${comp_exp_defs}" "")
		configure_Install_Variables_From_Dependency(${DECLARED_COMP} FALSE "" "" "" "${comp_exp_defs}" "" "" "" "" "" "" "" "")
	else()	#the dependency has a build interface
		if(export)#prepare the dependancy export
			set(${PROJECT_NAME}_${DECLARED_COMP}_EXPORT_${dep_package}_${dep_name_to_use} TRUE CACHE INTERNAL "")
		endif()
		configure_Install_Variables_From_Dependency(${DECLARED_COMP} ${export} "" "" "${dep_defs}" "${comp_exp_defs}" "" "" "" "" "" "" "" "")

		# setting compile definitions for configuring the target
		fill_Component_Target_With_Dependency(${DECLARED_COMP} ${dep_package} ${dep_name_to_use} ${CMAKE_BUILD_TYPE} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
	endif()

elseif(	${PROJECT_NAME}_${DECLARED_COMP}_TYPE STREQUAL "HEADER")
		# setting compile definitions for configuring the target
	if(IS_HF_DEP)#the dependency has no build interface(header free) => it is a runtime dependency => no export possible
		fill_Component_Target_With_Dependency(${DECLARED_COMP} ${dep_package} ${dep_name_to_use} ${CMAKE_BUILD_TYPE} FALSE "" "${comp_exp_defs}" "")

		configure_Install_Variables_From_Dependency(${DECLARED_COMP} FALSE "" "" "" "${comp_exp_defs}" "" "" "" "" "" "" "" "")
	else()	#the dependency has a build interface

		#prepare the dependancy export
		set(${PROJECT_NAME}_${DECLARED_COMP}_EXPORT_${dep_package}_${dep_name_to_use} TRUE CACHE INTERNAL "") #export is necessarily true for a pure header library
		configure_Install_Variables_From_Dependency(${DECLARED_COMP} TRUE "" "" "${dep_defs}" "${comp_exp_defs}" "" "" "" "" "" "" "" "")
		fill_Component_Target_With_Dependency(${DECLARED_COMP} ${dep_package} ${dep_name_to_use} ${CMAKE_BUILD_TYPE} TRUE "" "${comp_exp_defs}" "${dep_defs}")
	endif()
else()
	message (FATAL_ERROR "[PID] CRITICAL ERROR when building ${component} in ${PROJECT_NAME} : unknown type (${${PROJECT_NAME}_${DECLARED_COMP}_TYPE}) for component ${component} in package ${PROJECT_NAME}.")
	return()
endif()

#links and include directories do not require to be added (will be found automatically)
append_Unique_In_Cache(${PROJECT_NAME}_${DECLARED_COMP}_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package})
append_Unique_In_Cache(${PROJECT_NAME}_${DECLARED_COMP}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} ${dep_name_to_use})
endfunction(declare_Package_Component_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_External_Component_Dependency| replace:: ``declare_External_Component_Dependency``
#  .. _declare_External_Component_Dependency:
#
#  declare_External_Component_Dependency
#  -------------------------------------
#
#   .. command:: declare_External_Component_Dependency(component dep_package dep_component export comp_defs comp_exp_defs dep_defs)
#
#     Specify a dependency between a component of the currently defined native package and a component belonging to an external package.
#
#     :component: the name of the component that have a dependency.
#     :dep_package: the name of the external package that contains the dependency.
#     :dep_component: the name of the external component that IS the dependency, which belongs to dep_package.
#     :export: if TRUE component exports dep_component (i.e. public headers of component include public headers of dep_component)
#     :comp_defs: preprocessor definitions in the implementation of component that conditionnate the use of dep_component (may be an empty string). These definitions are not exported by component.
#     :comp_exp_defs: preprocessor definitions in the interface (public headers) of component that conditionnate the use of dep_component (may be an empty string). These definitions are exported by component.
#     :dep_defs: preprocessor definitions used in the interface of dep_component, that are set when component uses dep_component (may be an empty string). These definitions are exported if dep_component is exported by component.
#
function(declare_External_Component_Dependency component dep_package dep_component export comp_defs comp_exp_defs dep_defs)
set(DECLARED_COMP)
is_Declared(${component} DECLARED_COMP)
if(NOT DECLARED_COMP)
	finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR when defining dependency for ${component} in ${PROJECT_NAME} : component ${component} is not defined in current package ${PROJECT_NAME}.")
endif()
will_be_Built(COMP_WILL_BE_BUILT ${DECLARED_COMP})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()
if(NOT ${dep_package}_HAS_DESCRIPTION)# no external package description provided (maybe due to the fact that an old version of the external package is installed)
	message ("[PID] WARNING when building ${component} in ${PROJECT_NAME} : the external package ${dep_package} provides no description. Attempting to reinstall it to get it !")
	install_External_Package(INSTALL_OK ${dep_package} TRUE FALSE  "${BUILD_RELEASE_ONLY}")#force the reinstall of binary
	if(NOT INSTALL_OK)
		message (FATAL_ERROR "[PID] CRITICAL ERROR when reinstalling package ${dep_package} in ${PROJECT_NAME}, cannot redeploy package binary archive !")
		return()
	endif()

	find_package(#configure again the package to get its description
		${dep_package}
		${${dep_package}_VERSION_STRING} #use the version already in use
		EXACT
		MODULE
		REQUIRED
	)
	if(NOT ${dep_package}_HAS_DESCRIPTION)
		#description still unavailable => fatal error
		message (FATAL_ERROR "[PID] CRITICAL ERROR after reinstalling package ${dep_package} in ${PROJECT_NAME} : the project has no description of its content !")
	endif()
	message ("[PID] INFO when building ${component} in ${PROJECT_NAME} : the external package ${dep_package} now provides content description.")
endif()

will_be_Installed(COMP_WILL_BE_INSTALLED ${DECLARED_COMP})
#guarding depending on type of involved components
is_HeaderFree_Component(IS_HF_COMP ${PROJECT_NAME} ${DECLARED_COMP})
is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${DECLARED_COMP})
rename_If_Alias(dep_name_to_use ${dep_package} ${dep_component})#resolve alias for dependency (more homogeneous solution)
list(FIND ${dep_package}_COMPONENTS ${dep_name_to_use} INDEX)
if(INDEX EQUAL -1)
	message (FATAL_ERROR "[PID] CRITICAL ERROR when declaring dependency to component ${dep_component} of package ${dep_package} in ${PROJECT_NAME} : this component does not exist !")
endif()

if (IS_HF_COMP) #a component without headers
	# setting compile definitions for the target
	fill_Component_Target_With_External_Component_Dependency(${DECLARED_COMP} ${dep_package} ${dep_name_to_use} ${CMAKE_BUILD_TYPE} FALSE "${comp_defs}" "" "${dep_defs}")
	if(COMP_WILL_BE_INSTALLED)
		configure_Install_Variables_From_Dependency(${DECLARED_COMP} FALSE "" "" "" "" "" "" "" "" "" "" "" "")#standard is not propagated in this situation (no symbols exported in binaries)
	endif()
elseif(IS_BUILT_COMP) #a component that is built by the build procedure
	# setting compile definitions for configuring the target
	fill_Component_Target_With_External_Component_Dependency(${DECLARED_COMP} ${dep_package} ${dep_name_to_use} ${CMAKE_BUILD_TYPE} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
	if(export)#prepare the dependancy export
		set(${PROJECT_NAME}_${DECLARED_COMP}_EXTERNAL_EXPORT_${dep_package}_${dep_name_to_use} TRUE CACHE INTERNAL "")
		# for install variables do the same as for native package => external info will be deduced from external component description
		configure_Install_Variables_From_Dependency(${DECLARED_COMP} ${export} "" "" "${dep_defs}" "${comp_exp_defs}" "" "" "" "" "" "" "" "")
	else()
		# for install variables do the same as for native package => external info will be deduced from external component description
		configure_Install_Variables_From_Dependency(${DECLARED_COMP} ${export} "" "" "" "${comp_exp_defs}" "" "" "" "" "" "" "" "")
	endif()

elseif(	${PROJECT_NAME}_${DECLARED_COMP}_TYPE STREQUAL "HEADER") #a pure header component
	# setting compile definitions for configuring the target
	#prepare the dependancy export
	set(${PROJECT_NAME}_${DECLARED_COMP}_EXTERNAL_EXPORT_${dep_package}_${dep_name_to_use} TRUE CACHE INTERNAL "") #export is necessarily true for a pure header library
	#prepare the dependancy export
	fill_Component_Target_With_External_Component_Dependency(${DECLARED_COMP} ${dep_package} ${dep_name_to_use} ${CMAKE_BUILD_TYPE} TRUE "" "${comp_exp_defs}" "${dep_defs}")
	configure_Install_Variables_From_Dependency(${DECLARED_COMP} TRUE "" "" "${dep_defs}" "${comp_exp_defs}" "" "" "" "" "" "" "" "")
else()
	message (FATAL_ERROR "[PID] CRITICAL ERROR when building ${component} in ${PROJECT_NAME} : unknown type (${${PROJECT_NAME}_${DECLARED_COMP}_TYPE}) for component ${component} in package ${PROJECT_NAME}.")
endif()
#links and include directories do not require to be added (will be found automatically)
append_Unique_In_Cache(${PROJECT_NAME}_${DECLARED_COMP}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${dep_package})
append_Unique_In_Cache(${PROJECT_NAME}_${DECLARED_COMP}_EXTERNAL_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} ${dep_name_to_use})
endfunction(declare_External_Component_Dependency)



#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_System_Component_Dependency_Using_Configuration| replace:: ``declare_System_Component_Dependency_Using_Configuration``
#  .. _declare_System_Component_Dependency_Using_Configuration:
#
#  declare_System_Component_Dependency_Using_Configuration
#  -------------------------------------------------------
#
#   .. command:: declare_System_Component_Dependency_Using_Configuration(component export platform_config comp_defs comp_exp_defs dep_defs)
#
#     Specify a dependency between a component of the currently defined native package and system components defined using a platform configuration.
#
#     :component: the name of the component that have a dependency.
#     :export: if TRUE component exports the content of the dependency.
#     :platform_config: the name of the platform configuration to export.
#     :comp_defs: preprocessor definitions in the implementation of component that conditionnate the use of system dependencies (may be an empty string). These definitions are not exported by component.
#     :comp_exp_defs: preprocessor definitions in the interface (public headers) of component that conditionnate the use of system dependencies (may be an empty string). These definitions are exported by component.
#     :dep_defs: preprocessor definitions used in the headers system dependencies, that are defined by component (may be an empty string). These definitions are exported if dep_component is exported by component.
#
function(declare_System_Component_Dependency_Using_Configuration component export platform_config comp_defs comp_exp_defs dep_defs)
	set(all_shared_links)
	set(all_static_links)
	get_All_Configuration_Visible_Build_Variables(LINK_OPTS COMPILE_OPTS INC_DIRS LIB_DIRS DEFS RPATH ${platform_config})
	foreach(var IN LISTS LINK_OPTS)
		foreach(link IN LISTS ${var})#for each link defined by the configuration variable
			get_Link_Type(RES_TYPE ${link})
			if(RES_TYPE STREQUAL STATIC)#a static archive extension is explicitly given
				list(APPEND all_static_links ${link})
			else()#by default links refer to shared object (if no extension given)
				list(APPEND all_shared_links ${link})
			endif()
		endforeach()
	endforeach()
	#same call as an hand-made one but using automatically standard configuration variables
	set(all_dep_defs ${dep_defs})#preprocessor definition that apply to the interface of the configuration's components come from : 1) the configuration definition itself and 2) can be set directly by the user component
	foreach(var IN LISTS DEFS)#note: ${var} is the name of the variable
		list(APPEND all_dep_defs ${${var}})#preprocessor definition that apply to the interface of the configuration's components come from : 1) the configuration definition itself and 2) can be set directly by the user component
	endforeach()
	set(opts)
	foreach(var IN LISTS COMPILE_OPTS)#note: ${var} is the name of the variable
		list(APPEND opts ${${var}})#preprocessor definition that apply to the interface of the configuration's components come from : 1) the configuration definition itself and 2) can be set directly by the user component
	endforeach()
	#only transmit configuration variable if the configuration defines those variables (even if standard they are not all always defined)
	#Note: compared to previous variables those ones are not immediately evaluated since they refer to "path" that can change when relocation occurs
	#or when deployed on another system
	set(includes ${INC_DIRS})
	set(lib_dirs ${LIB_DIRS})
	set(rpath ${RPATH})

	declare_System_Component_Dependency(
			${component}
			${export}
			"${includes}"
			"${lib_dirs}"
			"${comp_defs}"#only definitions can come from the description of the dependency
			"${comp_exp_defs}"#only definitions can come from the description of the dependency
			"${all_dep_defs}"#only definitions can come from the description of the dependency
			"${opts}"
			"${all_static_links}"
			"${all_shared_links}"
			"${${platform_config}_C_STANDARD}"
			"${${platform_config}_C_MAX_STANDARD}"
			"${${platform_config}_CXX_STANDARD}"
			"${${platform_config}_CXX_MAX_STANDARD}"
			"${rpath}"
	 )
endfunction(declare_System_Component_Dependency_Using_Configuration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_System_Component_Dependency| replace:: ``declare_System_Component_Dependency``
#  .. _declare_System_Component_Dependency:
#
#  declare_System_Component_Dependency
#  -----------------------------------
#
#   .. command:: declare_System_Component_Dependency(component export inc_dirs comp_defs comp_exp_defs dep_defs compiler_options static_links shared_links c_standard cxx_standard runtime_resources)
#
#     Specify a dependency between a component of the currently defined native package and system components.
#     details: declare a dependancy that does not create new targets, but directly configures the component with adequate flags coming from system dependencies.
#     Should be avoided anytime possible, but useful to configure a component with flags and options coming from a platform configuration.
#
#     :component: the name of the component that have a dependency.
#     :export: if TRUE component exports the content of the dependency.
#     :inc_dirs: path to include directories required by the component in order to build.
#     :lib_dirs: additionnal library dirs used to search system libraries (with -l) in.
#     :comp_defs: preprocessor definitions in the implementation of component that conditionnate the use of system dependencies (may be an empty string). These definitions are not exported by component.
#     :comp_exp_defs: preprocessor definitions in the interface (public headers) of component that conditionnate the use of system dependencies (may be an empty string). These definitions are exported by component.
#     :dep_defs: preprocessor definitions used in the headers system dependencies, that are defined by component (may be an empty string). These definitions are exported if dep_component is exported by component.
#     :compiler_options: compiler options to use for this dependency (may be left empty).
#     :static_links: list of path to static libraries (may be left empty).
#     :shared_links: list of path to shared libraries or linker options (may be left empty).
#     :c_standard: the C language standard to use because of the dependency (may be left empty).
#     :c_max_standard: max C language standard allowed when using the dependency (may be left empty).
#     :cxx_standard: the C++ language standard to use because of the dependency (may be left empty).
#     :cxx_max_standard: max C++ language standard allowed when using the dependency (may be left empty).
#     :runtime_resources: set of path to files or folder used at runtime (may be left empty).
#
function(declare_System_Component_Dependency component export inc_dirs lib_dirs comp_defs comp_exp_defs dep_defs
                                             compiler_options static_links shared_links
																					   c_standard c_max_standard cxx_standard cxx_max_standard
																					 	 runtime_resources)
set(DECLARED_COMP)
is_Declared(${component} DECLARED_COMP)
if(NOT DECLARED_COMP)
	finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR when defining dependency for ${component} in ${PROJECT_NAME} : component ${component} is not defined in current package ${PROJECT_NAME}.")
endif()

will_be_Built(COMP_WILL_BE_BUILT ${DECLARED_COMP})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()
will_be_Installed(COMP_WILL_BE_INSTALLED ${DECLARED_COMP})

#guarding depending type of involved components
is_HeaderFree_Component(IS_HF_COMP ${PROJECT_NAME} ${DECLARED_COMP})
is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${DECLARED_COMP})

if (IS_HF_COMP) #no header to the component
	if(COMP_WILL_BE_INSTALLED)
		configure_Install_Variables_From_Dependency(${DECLARED_COMP} FALSE "" "" "" "" "" "" "" "" "" "" "" "${runtime_resources}")
	endif()
	# setting compile definitions for the target
	fill_Component_Target_With_External_Dependency(${DECLARED_COMP} FALSE "${comp_defs}" "" "${dep_defs}" "${inc_dirs}" "${compiler_options}" "${lib_dirs}" "${shared_links}" "${static_links}" "${c_standard}" "${c_max_standard}" "${cxx_standard}" "${cxx_max_standard}")
elseif(IS_BUILT_COMP)
	#prepare the dependancy export
	configure_Install_Variables_From_Dependency(${DECLARED_COMP} ${export} "${inc_dirs}" "${lib_dirs}" "${dep_defs}" "${comp_exp_defs}" "${compiler_options}" "${static_links}" "${shared_links}" "${c_standard}" "${c_max_standard}" "${cxx_standard}" "${cxx_max_standard}" "${runtime_resources}")
	# setting compile definitions for the target
	fill_Component_Target_With_External_Dependency(${DECLARED_COMP} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}" "${inc_dirs}" "${compiler_options}" "${lib_dirs}" "${shared_links}" "${static_links}" "${c_standard}" "${c_max_standard}" "${cxx_standard}" "${cxx_max_standard}")

elseif(	${PROJECT_NAME}_${DECLARED_COMP}_TYPE STREQUAL "HEADER")
	#prepare the dependancy export
	configure_Install_Variables_From_Dependency(${DECLARED_COMP} TRUE "${inc_dirs}" "${lib_dirs}" "${dep_defs}" "${comp_exp_defs}" "${compiler_options}" "${static_links}" "${shared_links}" "${c_standard}" "${c_max_standard}" "${cxx_standard}" "${cxx_max_standard}" "${runtime_resources}") #export is necessarily true for a pure header library
	# setting compile definitions for the target
	fill_Component_Target_With_External_Dependency(${DECLARED_COMP} TRUE "" "${comp_exp_defs}" "${dep_defs}" "${inc_dirs}" "${compiler_options}" "${lib_dirs}" "${shared_links}" "${static_links}" "${c_standard}" "${c_max_standard}" "${cxx_standard}" "${cxx_max_standard}")
else()
	message (FATAL_ERROR "[PID] CRITICAL ERROR when building ${component} in ${PROJECT_NAME} : unknown type (${${PROJECT_NAME}_${DECLARED_COMP}_TYPE}) for component ${component} in package ${PROJECT_NAME}.")
endif()
endfunction(declare_System_Component_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |declare_External_Package_Component_Dependency| replace:: ``declare_External_Package_Component_Dependency``
#  .. _declare_External_Package_Component_Dependency:
#
#  declare_External_Package_Component_Dependency
#  ---------------------------------------------
#
#   .. command:: declare_External_Package_Component_Dependency(component dep_package export inc_dirs comp_defs comp_exp_defs dep_defs
#                                                              compiler_options static_links shared_links
#																														   c_standard c_max_standard cxx_standard cxx_max_standard runtime_resources)
#
#     Specify a dependency between a component of the currently defined native package and the content of an external package.
#     details: declare an external dependancy that does not create new targets, but directly configures the component with adequate flags coming from dep_package.
#     Should be used prior to system dependencies for all dependencies that are not true system dependencies but should be avoided everytime the external package provide a content description (use file).
#
#     :component: the name of the component that have a dependency.
#     :dep_package: the name of the external package that contains the dependency.
#     :export: if TRUE component exports the content of dep_package.
#     :inc_dirs: include directories to add to component in order to build it. These include dirs are expressed relatively to dep_package root dir using "<dep_package>" expression (e.g. <boost>).
#     :comp_defs: preprocessor definitions in the implementation of component that conditionnate the use of dep_package (may be an empty string). These definitions are not exported by component.
#     :comp_exp_defs: preprocessor definitions in the interface (public headers) of component that conditionnate the use of dep_package (may be an empty string). These definitions are exported by component.
#     :dep_defs: preprocessor definitions used in the headers of dep_package, that are set by component(may be an empty string). These definitions are exported if dep_component is exported by component.
#     :compiler_options: compiler options to use for this dependency (may be let empty).
#     :static_links: list of path to static libraries relative to dep_package root dir (may be let empty).
#     :shared_links: list of path to shared libraries relative to dep_package root dir or linker options (may be let empty).
#     :c_standard: the C language standard to use because of the dependency (may be let empty).
#     :c_max_standard: max C language standard allowed when using the dependency (may be let empty).
#     :cxx_standard: the C++ language standard to use because of the dependency (may be let empty).
#     :cxx_max_standard: max C++ language standard allowed when using the dependency (may be let empty).
#     :runtime_resources: st of path to files or folder used at runtime relative to dep_package root dir (may be let empty).
#
function(declare_External_Package_Component_Dependency component dep_package export inc_dirs comp_defs comp_exp_defs dep_defs
																											compiler_options static_links shared_links
																										  c_standard c_max_standard cxx_standard cxx_max_standard runtime_resources)
set(DECLARED_COMP)
is_Declared(${component} DECLARED_COMP)
if(NOT DECLARED_COMP)
	finish_Progress(${GLOBAL_PROGRESS_VAR})
	message(FATAL_ERROR "[PID] CRITICAL ERROR when defining dependency for ${component} in ${PROJECT_NAME} : component ${component} is not defined in current package ${PROJECT_NAME}.")
endif()
will_be_Built(COMP_WILL_BE_BUILT ${DECLARED_COMP})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()
will_be_Installed(COMP_WILL_BE_INSTALLED ${DECLARED_COMP})

if(NOT ${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX})
	message (FATAL_ERROR "[PID] CRITICAL ERROR when building ${component} in ${PROJECT_NAME} : the external package ${dep_package} is not defined !")
else()

	#guarding depending type of involved components
	is_HeaderFree_Component(IS_HF_COMP ${PROJECT_NAME} ${DECLARED_COMP})
	is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${DECLARED_COMP})

	if (IS_HF_COMP)
		if(COMP_WILL_BE_INSTALLED)
			configure_Install_Variables_From_Dependency(${DECLARED_COMP} FALSE "" "" "" "" "" "" "${shared_links}" "" "" "" "" "${runtime_resources}")
		endif()
		# setting compile definitions for the target
		fill_Component_Target_With_External_Dependency(${DECLARED_COMP} FALSE "${comp_defs}" "" "${dep_defs}" "${inc_dirs}" "${compiler_options}" "" "${shared_links}" "${static_links}" "${c_standard}" "${c_max_standard}" "${cxx_standard}" "${cxx_max_standard}")
	elseif(IS_BUILT_COMP)
		#prepare the dependancy export
		configure_Install_Variables_From_Dependency(${DECLARED_COMP} ${export} "${inc_dirs}" "" "${dep_defs}" "${comp_exp_defs}" "${compiler_options}" "${static_links}" "${shared_links}" "${c_standard}" "${c_max_standard}" "${cxx_standard}" "${cxx_max_standard}" "${runtime_resources}")
		# setting compile definitions for the target
		fill_Component_Target_With_External_Dependency(${DECLARED_COMP} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}" "${inc_dirs}" "${compiler_options}" "" "${shared_links}" "${static_links}" "${c_standard}" "${c_max_standard}" "${cxx_standard}" "${cxx_max_standard}")
	elseif(	${PROJECT_NAME}_${DECLARED_COMP}_TYPE STREQUAL "HEADER")
		#prepare the dependancy export
		configure_Install_Variables_From_Dependency(${DECLARED_COMP} TRUE "${inc_dirs}" "" "${dep_defs}" "${comp_exp_defs}" "${compiler_options}" "${static_links}" "${shared_links}" "${c_standard}" "${c_max_standard}" "${cxx_standard}" "${cxx_max_standard}" "${runtime_resources}") #export is necessarily true for a pure header library
		# setting compile definitions for the "fake" target
		fill_Component_Target_With_External_Dependency(${DECLARED_COMP} TRUE "" "${comp_exp_defs}" "${dep_defs}" "${inc_dirs}" "${compiler_options}" "" "${shared_links}" "${static_links}" "${c_standard}" "${c_max_standard}" "${cxx_standard}" "${cxx_max_standard}")
	else()
		message (FATAL_ERROR "[PID] CRITICAL ERROR when building ${component} in ${PROJECT_NAME} : unknown type (${${PROJECT_NAME}_${DECLARED_COMP}_TYPE}) for component ${component} in package ${PROJECT_NAME}.")
	endif()
endif()
endfunction(declare_External_Package_Component_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |generate_Package_Install_Script| replace:: ``generate_Package_Install_Script``
#  .. _generate_Package_Install_Script:
#
#  generate_Package_Install_Script
#  -------------------------------
#
#   .. command:: generate_Package_Install_Script()
#
#     (Re)Generate the stand alone install script into share folder of current package project.
#
function(generate_Package_Install_Script)
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/share/install)
	file(COPY ${WORKSPACE_DIR}/cmake/patterns/packages/package/share/install DESTINATION ${CMAKE_SOURCE_DIR}/share)
	return()
endif()
if(NOT EXISTS ${CMAKE_SOURCE_DIR}/share/install/standlone_install.sh)
	file(COPY ${WORKSPACE_DIR}/cmake/patterns/packages/package/share/install/standalone_install.sh DESTINATION ${CMAKE_SOURCE_DIR}/share/install)
endif()
#TODO copy .bat file also when written
endfunction(generate_Package_Install_Script)

#.rst:
#
# .. ifmode:: internal
#
#  .. |add_Sanitizer_Flags_If_Available| replace:: ``add_Sanitizer_Flags_If_Available``
#  .. _add_Sanitizer_Flags_If_Available:
#
#  add_Sanitizer_Flags_If_Available
#  --------------------------------
#
#   .. command:: add_Sanitizer_Flags_If_Available(sanitizer compilier_options link_flags)
#
#     Check if the given sanitizer is available and, if so, append the compiler options and link flags to
#     compilier_options and link_flags in the parent scope
#
function(add_Sanitizer_Flags_If_Available sanitizer compilier_options link_flags)
	include(CheckCXXCompilerFlag)

	set(extra_compiler_options)

	if(sanitizer STREQUAL ADDRESS)
		set(SAN_FLAG -fsanitize=address)
		set(extra_compiler_options -fno-omit-frame-pointer)
	elseif(sanitizer STREQUAL LEAK)
		set(SAN_FLAG -fsanitize=leak)
	elseif(sanitizer STREQUAL UNDEFINED)
		set(SAN_FLAG -fsanitize=undefined)
	else()
		message(FATAL_ERROR "[PID] CRITICAL ERROR : Unknown satinizer ${sanitizer}. Valid options are ADDRESS, LEAK and UNDEFINED.")
	endif()

	# Need to set LDFLAGS otherwise check_cxx_compilier_flag will fail
	set(LDFLAGS_OLD $ENV{LDFLAGS})
	set(ENV{LDFLAGS} "$ENV{LDFLAGS} ${SAN_FLAG}")
	set(CMAKE_EXE_LINKER_FLAGS_OLD ${CMAKE_EXE_LINKER_FLAGS})
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${SAN_FLAG}")
	check_cxx_compiler_flag("${SAN_FLAG} ${extra_compiler_options}" HAS_${sanitizer}_SANITIZER)
	if(HAS_${sanitizer}_SANITIZER)
		list(APPEND ${compilier_options} ${SAN_FLAG} ${extra_compiler_options})
		set(${compilier_options} ${${compilier_options}} PARENT_SCOPE)

		list(APPEND ${link_flags} ${SAN_FLAG} ${extra_compiler_options})
		set(${link_flags} ${${link_flags}} PARENT_SCOPE)
	else()
		message("[PID] WARNING : ${sanitizer} sanitizer activated but your compiler doesn't support it")
	endif()
	set(ENV{LDFLAGS} ${LDFLAGS_OLD})
	set(CMAKE_EXE_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS_OLD})
endfunction(add_Sanitizer_Flags_If_Available)
