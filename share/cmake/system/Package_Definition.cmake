
#
# A convenience set of macros to create adequate variables in the context of the parent scope.
# used to define components of a package
#
##################################################################################
#######################  auxiliary package management functions ##################
##################################################################################

###
macro(add_Author author institution)
	list(APPEND ${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${author}(${institution})")
endmacro(add_Author author insitution)

###
macro(add_Caterory category_spec)
	list(APPEND ${PROJECT_NAME}_CATEGORIES ${category_spec})
endmacro(add_Caterory category_spec)

###
macro(set_Version major minor patch)
	#################################################
	################## setting version ##############
	#################################################
	set (${PROJECT_NAME}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH} CACHE INTERNAL "")
	message(STATUS "version currently built = "${${PROJECT_NAME}_VERSION})

	#################################################
	############ MANAGING install paths #############
	#################################################
	if(USE_LOCAL_DEPLOYMENT)
		set(${PROJECT_NAME}_DEPLOY_PATH own CACHE INTERNAL "")
	else(USE_LOCAL_DEPLOYMENT)
		set(${PROJECT_NAME}_DEPLOY_PATH ${${PROJECT_NAME}_VERSION} CACHE INTERNAL "")
	endif(USE_LOCAL_DEPLOYMENT) 

	set ( ${PROJECT_NAME}_INSTALL_LIB_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_AR_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_HEADERS_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/include CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_SHARE_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/share CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_BIN_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/bin CACHE INTERNAL "")
endmacro(set_Version major minor patch)

###
macro(generate_License_File)

if(${CMAKE_BUILD_TYPE} MATCHES Release)
	if(	DEFINED ${PROJECT_NAME}_LICENSE 
		AND NOT ${${PROJECT_NAME}_LICENSE} STREQUAL "")
	
		find_file(LICENSE   "License${${PROJECT_NAME}_LICENSE}.cmake"
				PATHS "${WORKSPACE_DIR}/share/cmake/system"
				NO_DEFAULT_PATH
				DOC "Path to the license configuration file")
		if(LICENSE_IN-NOTFOUND)
			message(WARNING "license configuration file for ${${PROJECT_NAME}_LICENSE} not found in workspace, license file will not be generated")
		else(LICENSE_IN-NOTFOUND)
			include(${WORKSPACE_DIR}/share/cmake/licenses/License${${PROJECT_NAME}_LICENSE}.cmake)
			file(WRITE ${CMAKE_SOURCE_DIR}/license.txt ${LICENSE_LEGAL_TERMS})
		endif(LICENSE_IN-NOTFOUND)

	endif()
endif()
endmacro(generate_License_File)

##################################################################################
###########################  declaration of the package ##########################
##################################################################################
macro(declare_Package author institution year license address description)

#################################################
############ Initializing variables #############
#################################################
set(${PROJECT_NAME}_MAIN_AUTHOR "${author}" CACHE INTERNAL "")
set(${PROJECT_NAME}_MAIN_INSTITUTION "${institution}" CACHE INTERNAL "")

set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${author}(${institution})" CACHE INTERNAL "")

set(${PROJECT_NAME}_DESCRIPTION "${description}" CACHE INTERNAL "")
set(${PROJECT_NAME}_YEARS ${year} CACHE INTERNAL "")
set(${PROJECT_NAME}_LICENSE ${license} CACHE INTERNAL "")
set(${PROJECT_NAME}_ADDRESS ${address} CACHE INTERNAL "")
set(${PROJECT_NAME}_CATEGORIES "" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS "" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_LIBS "" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_APPS "" CACHE INTERNAL "")

#################################################
############ MANAGING generic paths #############
#################################################
set(PACKAGE_BINARY_INSTALL_DIR ${WORKSPACE_DIR}/install CACHE INTERNAL "")
set(${PROJECT_NAME}_INSTALL_PATH ${PACKAGE_BINARY_INSTALL_DIR}/${PROJECT_NAME} CACHE INTERNAL "")
set(CMAKE_INSTALL_PREFIX ${${PROJECT_NAME}_INSTALL_PATH})

#################################################
############ DECLARING options ##################
#################################################
option(BUILD_WITH_EXAMPLES "Package builds examples" ON)
option(BUILD_WITH_TESTS "Package uses tests" OFF)
option(BUILD_WITH_PRINT_MESSAGES "Package generates print in console" OFF)
option(BUILD_WITH_DOC "Package generates documentation" ON)
option(USE_LOCAL_DEPLOYMENT "Package uses tests" ON)
if(BUILD_WITH_PRINT_MESSAGES)
	add_definitions(-DPRINT_MESSAGES)
endif(BUILD_WITH_PRINT_MESSAGES)

#################################################
############ MANAGING build mode ################
#################################################
if(${CMAKE_BINARY_DIR} MATCHES release)
	set(CMAKE_BUILD_TYPE "Release" CACHE String "the type of build is dependent from build location" FORCE)
	set ( INSTALL_NAME_SUFFIX "" CACHE INTERNAL "")
elseif(${CMAKE_BINARY_DIR} MATCHES debug)
	set(CMAKE_BUILD_TYPE "Debug" CACHE String "the type of build is dependent from build location" FORCE)
	set ( INSTALL_NAME_SUFFIX -dbg CACHE INTERNAL "")
endif(${CMAKE_BINARY_DIR} MATCHES release)

########################################################################
############ inclusion of required macros and functions ################
########################################################################
#TODO uncomment to test
#include(Package_Finding)
#include(Package_Configuration)

endmacro(declare_Package author institution year license address description)



##################################################################################
################################### building the package #########################
##################################################################################
macro(build_Package)

##########################################################
############ MANAGING non source files ###################
##########################################################

generate_License_File() #license
install(FILES ${CMAKE_SOURCE_DIR}/license.txt DESTINATION ${${PROJECT_NAME}_DEPLOY_PATH})

# generating/installing the generic cmake find file for the package 
configure_file(${WORKSPACE_DIR}/share/cmake/system/FindPackage.cmake.in ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake DESTINATION ${WORKSPACE_DIR}/share/cmake/find) #install in the worskpace cmake find modules directory

#install(FILES ${CMAKE_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH}/cmake) #install it in the corresponding package version
# generating/installing the version specific cmake "use" file 
configure_file(${CMAKE_SOURCE_DIR}/share/UsePackageVersion.cmake.in ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake @ONLY)
install(FILES ${CMAKE_BINARY_DIR}/share/Use${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}.cmake DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})
#installing the CMakeModules folder (contains find scripts)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/share/cmake DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})

#################################################
############ MANAGING the BUILD #################
#################################################

# if all dependencies are satisfied --> TODO : remove this include
include_directories(include)

#recursive call into subdirectories to build/install/test the package
add_subdirectory(src)
add_subdirectory(apps)
add_subdirectory(test)
add_subdirectory(share)

#################################################
##### MANAGING the SYSTEM PACKAGING #############
#################################################
#TODO Il faudrait packager les libs debug ET release d'un coup !! (PAS facile avec CMAKE) 
#option(GENERATE_INSTALLER "Package generate an OS installer for linux with tgz and if possible debian" OFF)
#if(GENERATE_INSTALLER)
#	include(InstallRequiredSystemLibraries)
#	set(CPACK_GENERATOR TGZ)
#	set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
#	set(CPACK_PACKAGE_CONTACT ${${PROJECT_NAME}_MAIN_AUTHOR})
#	set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${${PROJECT_NAME}_DESCRIPTION})
#	set(CPACK_PACKAGE_VENDOR ${${PROJECT_NAME}_MAIN_INSTITUTION})
#	set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/license.txt)#TODO change with binary dir and generate the file !!
#	set(CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
#	set(CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
#	set(CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
#	set(CPACK_PACKAGE_VERSION "${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}")
#	set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}/${${PROJECT_NAME}_VERSION}")
#
#	if(UNIX AND NOT APPLE)
#		list(APPEND CPACK_GENERATOR DEB)
#	endif(UNIX AND NOT APPLE)
#	include(CPack)


#	if(UNIX AND NOT APPLE) #linux install
#		add_custom_target(package_install
#				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tar.gz
#					${${PROJECT_NAME}_INSTALL_PATH}/installers/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tar.gz
#				DEPENDS ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tar.gz
#				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.deb
#					${${PROJECT_NAME}_INSTALL_PATH}/installers/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.deb
#				DEPENDS ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tar.gz
#				COMMENT "installing ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.deb in ${${PROJECT_NAME}_INSTALL_PATH}/installers"
			)
#	else(UNIX AND NOT APPLE) #apple install
#		add_custom_target(package_install
#			   	COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tar.gz
#					${${PROJECT_NAME}_INSTALL_PATH}/installers/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tar.gz
#				COMMENT "installing ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.tag.gz in ${${PROJECT_NAME}_INSTALL_PATH}/installers" 						 
#			)
#	endif(UNIX AND NOT APPLE)
#
#endif(GENERATE_INSTALLER)

#################################################
######### MANAGING global make commands #########
#################################################

#creating a global build command
#if(GENERATE_INSTALLER)
#	if(CMAKE_BUILD_TYPE MATCHES Release)
#		if(${BUILD_WITH_TESTS})
#			add_custom_target(build 
#				COMMAND ${CMAKE_BUILD_TOOL}
#				COMMAND ${CMAKE_BUILD_TOOL} test
#				COMMAND ${CMAKE_BUILD_TOOL} doc 
#				COMMAND ${CMAKE_BUILD_TOOL} install
#				COMMAND ${CMAKE_BUILD_TOOL} package
#				COMMAND ${CMAKE_BUILD_TOOL} package_install
#			) 
#		else(${BUILD_WITH_TESTS})
#			add_custom_target(build 
#				COMMAND ${CMAKE_BUILD_TOOL}
#				COMMAND ${CMAKE_BUILD_TOOL} doc 
#				COMMAND ${CMAKE_BUILD_TOOL} install
#				COMMAND ${CMAKE_BUILD_TOOL} package
#				COMMAND ${CMAKE_BUILD_TOOL} package_install
#			) 
#		endif(${BUILD_WITH_TESTS})
#	else(CMAKE_BUILD_TYPE MATCHES Release)
#		if(${BUILD_WITH_TESTS})
#			add_custom_target(build 
#				COMMAND ${CMAKE_BUILD_TOOL} 
#				COMMAND ${CMAKE_BUILD_TOOL} test
#				COMMAND ${CMAKE_BUILD_TOOL} install
#				COMMAND ${CMAKE_BUILD_TOOL} package
#				COMMAND ${CMAKE_BUILD_TOOL} package_install
#			) 
#		else(${BUILD_WITH_TESTS})
#			add_custom_target(build 
#				COMMAND ${CMAKE_BUILD_TOOL} 
#				COMMAND ${CMAKE_BUILD_TOOL} install
#				COMMAND ${CMAKE_BUILD_TOOL} package
#				COMMAND ${CMAKE_BUILD_TOOL} package_install
#			)  
#		endif(${BUILD_WITH_TESTS})
#
#	endif(CMAKE_BUILD_TYPE MATCHES Release)
#
#else(GENERATE_INSTALLER)
	if(CMAKE_BUILD_TYPE MATCHES Release)
		if(${BUILD_WITH_TESTS})
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL}
				COMMAND ${CMAKE_BUILD_TOOL} test
				COMMAND ${CMAKE_BUILD_TOOL} doc 
				COMMAND ${CMAKE_BUILD_TOOL} install
			) 
		else(${BUILD_WITH_TESTS})
	
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL}
				COMMAND ${CMAKE_BUILD_TOOL} doc 
				COMMAND ${CMAKE_BUILD_TOOL} install
			) 
		endif()
	else(CMAKE_BUILD_TYPE MATCHES Release)
		if(${BUILD_WITH_TESTS})
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL}
				COMMAND ${CMAKE_BUILD_TOOL} test
				COMMAND ${CMAKE_BUILD_TOOL} install
			) 
		else(${BUILD_WITH_TESTS})
			
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL} 
				COMMAND ${CMAKE_BUILD_TOOL} install
			) 
		endif(${BUILD_WITH_TESTS})
	endif(CMAKE_BUILD_TYPE MATCHES Release)
#endif(GENERATE_INSTALLER)

endmacro(build_Package)



##################################################################################
########## adding source code of the example components to the API doc ###########
##################################################################################
function(add_Example_To_Doc c_name)
	file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/share/examples/)
	file(COPY ${PROJECT_SOURCE_DIR}/apps/${c_name} DESTINATION ${PROJECT_BINARY_DIR}/share/examples/)
endfunction(add_Example_To_Doc c_name)

##################################################################################
################### generating API documentation for the package #################
##################################################################################
function(generate_API)
option(GENERATE_LATEX_API "Generating the latex api documentation" ON)
if(CMAKE_BUILD_TYPE MATCHES Release) # if in release mode we generate the doc

#finding doxygen tool and doxygen configuration file 
find_package(Doxygen)
find_file(DOXYFILE_IN   "Doxyfile.in"
			PATHS "${CMAKE_SOURCE_DIR}/share/doxygen"
			NO_DEFAULT_PATH
			DOC "Path to the doxygen configuration template file")

if(NOT DOXYGEN_FOUND)
	message(WARNING "Doxygen not found please install it to generate the API documentation")
endif(NOT DOXYGEN_FOUND)
if(DOXYFILE_IN-NOTFOUND)
	message(WARNING "Doxyfile not found in the share folder of your package !! Getting the standard doxygen template file from workspace ... ")
	find_file(GENERIC_DOXYFILE_IN   "Doxyfile.in"
					PATHS "${WORKSPACE_DIR}/share/cmake/system"
					NO_DEFAULT_PATH
					DOC "Path to the generic doxygen configuration template file")
	if(GENERIC_DOXYFILE_IN-NOTFOUND)
		message(WARNING "No Template file found, skipping documentation generation !!")		
	else(GENERIC_DOXYFILE_IN-NOTFOUND)
		file(COPY ${WORKSPACE_DIR}/share/doxygen/Doxyfile.in ${CMAKE_SOURCE_DIR}/share/doxygen)
		message(STATUS "Template file found and copied to your package, you can now modify it")		
	endif(GENERIC_DOXYFILE_IN-NOTFOUND)
endif(DOXYFILE_IN-NOTFOUND)

if(DOXYGEN_FOUND AND NOT DOXYFILE_IN-NOTFOUND AND NOT GENERIC_DOXYFILE_IN-NOTFOUND) #we are able to generate the doc
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

	if(GENERATE_LATEX_API)
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

	else(GENERATE_LATEX_API)
		set(DOXYFILE_GENERATE_LATEX "NO")
	endif(GENERATE_LATEX_API)

	#configuring the Doxyfile.in file to generate a doxygen configuration file
	configure_file(${CMAKE_SOURCE_DIR}/share/doxygen/Doxyfile.in ${CMAKE_BINARY_DIR}/share/Doxyfile @ONLY)
	### end doxyfile configuration ###

	### installing documentation ###
	install(DIRECTORY ${CMAKE_BINARY_DIR}/share/doc DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})

	### end installing documentation ###

endif(DOXYGEN_FOUND AND NOT DOXYFILE_IN-NOTFOUND AND NOT GENERIC_DOXYFILE_IN-NOTFOUND)
	set(BUILD_WITH_DOC OFF)
endif(CMAKE_BUILD_TYPE MATCHES Release)
endfunction(generate_API)

###################### !!!!!!!!!!!!!!!!!!!!! ####################
### DEBUT code a virer une fois le système de gestion de dépendences fini
##################################################################

##################################################################################
###################### building a header component #########################
##################################################################################
macro(buildPureHeaderComponent c_name)
	#managing headers	
	set(${PROJECT_NAME}_COMP_HEADER_${c_name}_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include/${c_name})
	install(DIRECTORY ${${PROJECT_NAME}_COMP_HEADER_${c_name}_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.h")
	install(DIRECTORY ${${PROJECT_NAME}_COMP_HEADER_${c_name}_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.hpp")
	install(DIRECTORY ${${PROJECT_NAME}_COMP_HEADER_${c_name}_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.hh")
	#updating global variables of the CMake process	
	set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_LIBS "${${PROJECT_NAME}_COMPONENTS_LIBS};${c_name}" CACHE INTERNAL "")
endmacro(buildPureHeaderComponent)


##################################################################################
###################### declaration of a library component ########################
##################################################################################
macro(buildLibComponent c_name used_libraries_list)
	#managing headers	
	set(${PROJECT_NAME}_COMP_LIB_${c_name}_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include/${c_name})
	install(DIRECTORY ${PROJECT_NAME}_COMP_LIB_${c_name}_INCLUDE_DIR DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.h")
	install(DIRECTORY ${PROJECT_NAME}_COMP_LIB_${c_name}_INCLUDE_DIR DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.hpp")
	#managing sources
	set(${PROJECT_NAME}_COMP_LIB_${c_name}_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/${c_name})
	
	file(GLOB_RECURSE ${PROJECT_NAME}_COMP_LIB_${c_name}_ALL_SOURCES "${c_name}/*.c" "${c_name}/*.cpp" "${c_name}/*.h" "${c_name}/*.hpp")
	
	add_library(${c_name}-st${INSTALL_NAME_SUFFIX} STATIC ${${PROJECT_NAME}_COMP_LIB_${c_name}_ALL_SOURCES})
	target_link_libraries(${c_name}-st${INSTALL_NAME_SUFFIX} ${used_libraries_list})
	add_library(${c_name}${INSTALL_NAME_SUFFIX} SHARED ${${PROJECT_NAME}_COMP_LIB_${c_name}_ALL_SOURCES})
	target_link_libraries(${c_name}${INSTALL_NAME_SUFFIX} ${used_libraries_list})

	# installing library
	INSTALL(TARGETS ${c_name}${INSTALL_NAME_SUFFIX} ${c_name}-st${INSTALL_NAME_SUFFIX}
	RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
	LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}
	ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_AR_PATH}
	)

	#updating global variables of the CMake process	
	set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_LIBS "${${PROJECT_NAME}_COMPONENTS_LIBS};${c_name}" CACHE INTERNAL "")

endmacro(buildLibComponent)


##################################################################################
################## declaration of an application component #######################
##################################################################################
macro(buildAppComponent c_name used_libraries_list)
	#managing sources
	set(${PROJECT_NAME}_COMP_APP_${c_name}_SOURCE_DIR ${CMAKE_SOURCE_DIR}/apps/${c_name})

	file(GLOB_RECURSE ${PROJECT_NAME}_COMP_APP_${c_name}_ALL_SOURCES "${c_name}/*.c" "${c_name}/*.cpp" "${c_name}/*.h" "${c_name}/*.hpp")
	
	add_executable(${c_name}${INSTALL_NAME_SUFFIX} ${${PROJECT_NAME}_COMP_APP_${c_name}_ALL_SOURCES})
	target_link_libraries(${c_name}${INSTALL_NAME_SUFFIX} ${used_libraries_list})

	# installing library
	INSTALL(TARGETS ${c_name}${INSTALL_NAME_SUFFIX} 
	RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
	)

	#updating global variables of the CMake process	
	set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_APPS "${${PROJECT_NAME}_COMPONENTS_APPS};${c_name}" CACHE INTERNAL "")
	
endmacro(buildAppComponent)


##################################################################################
################ printing variables for components in the package ################
##################################################################################
macro(printComponentVariables)
	message("components of package ${PROJECT_NAME} are :" ${${PROJECT_NAME}_COMPONENTS})
	message("libraries : "${${PROJECT_NAME}_COMPONENTS_LIBS})
	message("applications : "${${PROJECT_NAME}_COMPONENTS_APPS})
endmacro(printComponentVariables)



###################### !!!!!!!!!!!!!!!!!!!!! ####################
### FIN code a virer une fois le système de gestion de dépendences fini
####################!!!!!!!!!!!!!!!!!!!!!!!!!!!##################

###REMARQUE
###
### pour defs et links il faut permettre de dire qu'on les exporte OU PAS
### i.e. ils servent uniquement en interne OU ils doivent être exportés en même
### temps que le composant !!!

##################################################################################
############################ auxiliary functions #################################
##################################################################################
###
function(manage_Additional_Component_Flags target_name defs links exp_defs exp_links)

# managing compile time flags
if(NOT ${defs} STREQUAL "")
	target_compile_definitions(${target_name} ${defs})
endif(NOT ${defs} STREQUAL "")

if(NOT ${exp_defs} STREQUAL "")
	target_compile_definitions(${target_name} ${exp_defs})
endif(NOT ${exp_defs} STREQUAL "")

# managing link time flags
if(NOT ${links} STREQUAL "")
	target_link_libraries(${target_name} ${links})
endif(NOT ${links} STREQUAL "")

if(NOT ${exp_links} STREQUAL "")
	target_link_libraries(${target_name} ${exp_links})
endif(NOT ${exp_links} STREQUAL "")

endfunction(manage_Additional_Component_Flags target_name defs links exp_defs exp_links)

###
function (fill_Component_Target_Compilation c_name dep_name)

if(	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "APP"
	OR ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "SHARED")
	if(NOT ${${dep_name}_INC_DIRS} STREQUAL "")
		target_include_directories(${c_name} PUBLIC ${${dep_name}_INC_DIRS})
	endif(NOT ${${dep_name}_INC_DIRS} STREQUAL "")

	if(NOT ${${dep_name}_DEFS} STREQUAL "")
		target_compile_definitions(${c_name} PUBLIC ${${dep_name}_DEFS})
	endif(NOT ${${dep_name}_DEFS} STREQUAL "")

elseif(	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "STATIC")
	if(NOT ${${dep_name}_INC_DIRS} STREQUAL "")
		target_include_directories(${c_name}-st PUBLIC ${${dep_name}_INC_DIRS})
	endif(NOT ${${dep_name}_INC_DIRS} STREQUAL "")

	if(NOT ${${dep_name}_DEFS} STREQUAL "")
		target_compile_definitions(${c_name}-st PUBLIC ${${dep_name}_DEFS})
	endif(NOT ${${dep_name}_DEFS} STREQUAL "")

elseif(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "COMPLETE")
	if(NOT ${${dep_name}_INC_DIRS} STREQUAL "")
		target_include_directories(${c_name} PUBLIC ${${dep_name}_INC_DIRS})
	endif(NOT ${${dep_name}_INC_DIRS} STREQUAL "")

	if(NOT ${${dep_name}_DEFS} STREQUAL "")
		target_compile_definitions(${c_name} PUBLIC ${${dep_name}_DEFS})
	endif(NOT ${${dep_name}_DEFS} STREQUAL "")

	if(NOT ${${dep_name}_INC_DIRS} STREQUAL "")
		target_include_directories(${c_name}-st PUBLIC ${${dep_name}_INC_DIRS})
	endif(NOT ${${dep_name}_INC_DIRS} STREQUAL "")

	if(NOT ${${dep_name}_DEFS} STREQUAL "")
		target_compile_definitions(${c_name}-st PUBLIC ${${dep_name}_DEFS})
	endif(NOT ${${dep_name}_DEFS} STREQUAL "")
	
endif()#do nothing in case of a pure header component

endfunction (fill_Component_Target_Compilation c_name dep_name)

###
function (fill_Component_Target_Linking c_name dep_name)

if(	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "APP"
	OR ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "SHARED")
	if(NOT ${${dep_name}_LINKS} STREQUAL "")
		target_link_libraries(${c_name} ${${dep_name}_LINKS})
	endif(NOT ${${dep_name}_LINKS} STREQUAL "")
elseif(	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "SHARED")
	if(NOT ${${dep_name}_LINKS} STREQUAL "")
		target_link_libraries(${c_name} ${${dep_name}_LINKS})
	endif(NOT ${${dep_name}_LINKS} STREQUAL "")
elseif(	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "STATIC")
	if(NOT ${${dep_name}_LINKS} STREQUAL "")
		target_link_libraries(${c_name}-st ${${dep_name}_LINKS})
	endif(NOT ${${dep_name}_LINKS} STREQUAL "")
elseif(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "COMPLETE")
	if(NOT ${${dep_name}_LINKS} STREQUAL "")
		target_link_libraries(${c_name} ${${dep_name}_LINKS})
	endif(NOT ${${dep_name}_LINKS} STREQUAL "")
	if(NOT ${${dep_name}_LINKS} STREQUAL "")
		target_link_libraries(${c_name}-st ${${dep_name}_LINKS})
	endif(NOT ${${dep_name}_LINKS} STREQUAL "")	
endif()#do nothing in case of a pure header component

endfunction (fill_Component_Target_Linking c_name dep_name)

###

##################################################################################
###################### declaration of a library component ########################
##################################################################################
function(declare_Library_Component c_name type defs links exp_defs exp_links)
	#indicating that the component has been declared and need to be completed
	if(${type} STREQUAL "HEADER"
	OR ${type} STREQUAL "STATIC"
	OR ${type} STREQUAL "SHARED"
	OR ${type} STREQUAL "COMPLETE")
		set(${PROJECT_NAME}_${c_name}_TYPE ${type} CACHE INTERNAL "")
	else()#by default a library is COMPLETE (header + static + shared)
		set(${PROJECT_NAME}_${c_name}_TYPE "COMPLETE" CACHE INTERNAL "")
	endif()

	### managing headers ###
	#a library defines a folder containing one or more headers and/or subdirectories 
	set(${PROJECT_NAME}_${c_name}_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include/${c_name} CACHE INTERNAL "")
	
	install(DIRECTORY ${${PROJECT_NAME}_${c_name}_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.h")
	install(DIRECTORY ${${PROJECT_NAME}_${c_name}_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.hpp")
	install(DIRECTORY ${${PROJECT_NAME}_${c_name}_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.hh")

	if(NOT ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "HEADER")
		#managing sources for the library
		set(${PROJECT_NAME}_${c_name}_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/${c_name})
	
		file(GLOB_RECURSE ${PROJECT_NAME}_${c_name}_ALL_SOURCES "${${PROJECT_NAME}_${c_name}_SOURCE_DIR}/*.c" "${${PROJECT_NAME}_${c_name}_SOURCE_DIR}/*.cc" "${${PROJECT_NAME}_${c_name}_SOURCE_DIR}/*.cpp" "${${PROJECT_NAME}_${c_name}_SOURCE_DIR}/*.h" "${${PROJECT_NAME}_${c_name}_SOURCE_DIR}/*.hpp" "${${PROJECT_NAME}_${c_name}_SOURCE_DIR}/*.hh")
		
		#defining shared and/or static targets for the library and
		#adding the targets to the list of installed components when make install is called
		if(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "STATIC")
			add_library(${c_name}-st${INSTALL_NAME_SUFFIX} STATIC ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
			target_include_directories(${c_name}-st${INSTALL_NAME_SUFFIX} include)
			manage_Additional_Component_Flags(${c_name}-st${INSTALL_NAME_SUFFIX} ${defs} ${links} ${exp_defs} ${exp_links})
			INSTALL(TARGETS ${c_name}-st${INSTALL_NAME_SUFFIX}
				ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_AR_PATH}
			)
		elseif(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "SHARED")
			add_library(${c_name}${INSTALL_NAME_SUFFIX} SHARED ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
			target_include_directories(${c_name}${INSTALL_NAME_SUFFIX} include)			
			manage_Additional_Component_Flags(${c_name}${INSTALL_NAME_SUFFIX} ${defs} ${links} ${exp_defs} ${exp_links})
			INSTALL(TARGETS ${c_name}${INSTALL_NAME_SUFFIX}
				LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}
				RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
			)
		elseif(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "COMPLETE")
			add_library(${c_name}-st${INSTALL_NAME_SUFFIX} STATIC ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
			target_include_directories(${c_name}-st${INSTALL_NAME_SUFFIX} include)			
			manage_Additional_Component_Flags(${c_name}-st${INSTALL_NAME_SUFFIX} ${defs} ${links} ${exp_defs} ${exp_links})
			add_library(${c_name}${INSTALL_NAME_SUFFIX} SHARED ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
			target_include_directories(${c_name}${INSTALL_NAME_SUFFIX} include)
			manage_Additional_Component_Flags(${c_name}${INSTALL_NAME_SUFFIX} ${defs} ${links} ${exp_defs} ${exp_links})
			INSTALL(TARGETS ${c_name}${INSTALL_NAME_SUFFIX} ${c_name}-st${INSTALL_NAME_SUFFIX}
				LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}
				ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_AR_PATH}
				RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
			)
		endif()
	endif(NOT ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "HEADER")

	# registering exported flags for all kinds of libs
	set(${PROJECT_NAME}_${c_name}_DEFS ${exp_defs} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_LINKS ${exp_links} CACHE INTERNAL "")
	
	#updating global variables of the CMake process	
	set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_LIBS "${${PROJECT_NAME}_COMPONENTS_LIBS};${c_name}" CACHE INTERNAL "")
	# global variable to know that the component has been declared
	set(${PROJECT_NAME}_${c_name}_DECLARED TRUE CACHE INTERNAL "")
	
endfunction(declare_Library_Component c_name type)



##################################################################################
################# declaration of an application component ########################
##################################################################################
function(declare_Application_Component c_name type defs links)
	if(DEFINED ${PROJECT_NAME}_${c_name}_TYPE)
		message("ERROR declare_Application_Component : a component with the same name ${c_name} is already defined")
	endif(DEFINED ${PROJECT_NAME}_${c_name}_TYPE)

	if(${type} STREQUAL "TEST" 
	OR ${type} STREQUAL "APP"
	OR ${type} STREQUAL "EXAMPLE")
		set(${PROJECT_NAME}_${c_name}_TYPE ${type} CACHE INTERNAL "")
	else() #a simple application by default
		set(${PROJECT_NAME}_${c_name}_TYPE "APP" CACHE INTERNAL "")
	endif()	
	
	# specifically managing examples 	
	if(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "EXAMPLE") 
		if(NOT BUILD_WITH_EXAMPLES) #examples are not built so no need to continue
			unset(${PROJECT_NAME}_${c_name}_TYPE CACHE)
			return()
		endif(NOT BUILD_WITH_EXAMPLES)
		add_Example_To_Doc(${c_name}) #examples are added to the doc to be referenced
	endif(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "EXAMPLE")

	#managing sources for the application
	if(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "APP"
	OR ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "EXAMPLE")		
		set(${PROJECT_NAME}_${c_name}_SOURCE_DIR ${CMAKE_SOURCE_DIR}/apps/${c_name})
	elseif(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "TEST")
		set(${PROJECT_NAME}_${c_name}_SOURCE_DIR ${CMAKE_SOURCE_DIR}/test/${c_name})
	endif()

	file(GLOB_RECURSE ${PROJECT_NAME}_${c_name}_ALL_SOURCES "${${PROJECT_NAME}_${c_name}_SOURCE_DIR}/*.c" "${${PROJECT_NAME}_${c_name}_SOURCE_DIR}/*.cc" "${${PROJECT_NAME}_${c_name}_SOURCE_DIR}/*.cpp" "${${PROJECT_NAME}_${c_name}_SOURCE_DIR}/*.h" "${${PROJECT_NAME}_${c_name}_SOURCE_DIR}/*.hpp" "${${PROJECT_NAME}_${c_name}_SOURCE_DIR}/*.hh")
	
	#defining the target to build the application
	add_executable(${c_name} ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
	manage_Additional_Component_Flags(${c_name} ${defs} ${links} "" "")
	
	if(NOT ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "TEST")
		# adding the application to the list of installed components when make install is called (not for test applications)
		INSTALL(TARGETS ${c_name}${INSTALL_NAME_SUFFIX} 
			RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
		)
	endif(NOT ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "TEST")

	# registering exported flags for all kinds of apps => empty variables
	set(${PROJECT_NAME}_${c_name}_DEFS "" CACHE INTERNAL "")
	set(${PROJECT_NAME}_${c_name}_LINKS "" CACHE INTERNAL "")

	#updating global variables of the CMake process	
	set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_APPS "${${PROJECT_NAME}_COMPONENTS_APPS};${c_name}" CACHE INTERNAL "")
	# global variable to know that the component has been declared
	set(${PROJECT_NAME}_${c_name}_DECLARED TRUE CACHE INTERNAL "")
endfunction(declare_Application_Component c_name type)


##################################################################################
########################### specifying a dependency ##############################
### to be used either for system or package dependency after FindPackage used ####
##################################################################################
function(create_Dependency dep_name package type component inc_dirs defs links)

if(DEFINED ${dep_name}_TYPE)
message("ERROR : the dependency ${dep_name} has already been defined")
endif(DEFINED ${dep_name}_TYPE)

if(	${type} STREQUAL "SHARED"
	OR ${type} STREQUAL "STATIC"
	OR ${type} STREQUAL "HEADER"
	OR ${type} STREQUAL "APP" #this is a purely informative dependency (program must be present in the system when this depepdency is used by a component - for instance with an "exec" system call)
)
	set(${dep_name}_TYPE ${type} CACHE INTERNAL "")
	if(${package} STREQUAL "")
		set(${dep_name}_PACKAGE ${PROJECT_NAME} CACHE INTERNAL "") #by default the target package is the current one
	else(${package} STREQUAL "")
		set(${dep_name}_PACKAGE ${package} CACHE INTERNAL "") #package from where comes the dependency
	endif(${package} STREQUAL "")
else()
	message("ERROR : the dependency type ${type} does not exist")
	return()
endif()

set(${dep_name}_COMP ${component} CACHE INTERNAL "")
if (NOT ${type} STREQUAL "APP") #it is a library	
	if(NOT ${defs} STREQUAL "")#adding compile time definitions
		set(${dep_name}_DEFS ${defs} CACHE INTERNAL "")
	endif(NOT ${defs} STREQUAL "")

	if(NOT ${links} STREQUAL "") #adding link time flags
		set(${dep_name}_LINKS ${links} CACHE INTERNAL "")
	endif(NOT ${links} STREQUAL "")

	if(NOT ${inc_dirs} STREQUAL "") #adding include directories
		set(${dep_name}_INC_DIRS ${inc_dirs} CACHE INTERNAL "")
	endif(NOT ${inc_dirs} STREQUAL "")
endif()

endfunction(create_Dependency dep_name package type component inc_dirs defs links)

##################################################################################
########################### specifying a local dependency ########################
#################### to be used for insternal use in a package ###################
##################################################################################
function(create_Local_Dependency c_name type)
	if (NOT DEFINED ${PROJECT_NAME}_${c_name}_TYPE)
		message("ERROR create_Local_Dependency : the component ${c_name} has not been defined")
	endif(NOT DEFINED ${PROJECT_NAME}_${c_name}_TYPE)
	
	if(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "APP")#this is an application
		#create the dependency corresponding to the local application
		create_Dependency(	"${${PROJECT_NAME}_${c_name}_DEP}" 
					"${PROJECT_NAME}"
					"APP"
					"${c_name}"
					""
					""
					""
				)

	elseif(		${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "HEADER"
		OR	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "SHARED"
		OR	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "STATIC"
		OR	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "COMPLETE")#this is a library
		#create the dependency corresponding to the local library
		if (${type} STREQUAL "")
			set(local_type "SHARED")
		else(${type} STREQUAL "") 
			set(local_type ${type})
		endif(${type} STREQUAL "")
		create_Dependency(	"${${PROJECT_NAME}_${c_name}_DEP}" 
					"${PROJECT_NAME}"
					"${local_type}"
					"${c_name}"
					"${${PROJECT_NAME}_${c_name}_INCLUDE_DIR}"
					"${${PROJECT_NAME}_${c_name}_DEFS}"
					"${${PROJECT_NAME}_${c_name}_LINKS}"
				)
	else()
		message("ERROR create_Local_Dependency : the type ${${PROJECT_NAME}_${c_name}_TYPE} of the dependency target is not valid")
	endif()
endfunction(create_Local_Dependency c_name type)

##################################################################################
###################### adding dependency to a component ##########################
### to be used after a call to a declare_Component and the corresponding declare_Dependency functions
########################################################################################################

function(add_Component_Dependency c_name dep_name)

#checking that arguments are correct
if(NOT DEFINED ${dep_name}_TYPE)
	message("ERROR add_Component_Dependency : the dependency ${dep_name} has not been defined")
endif(NOT DEFINED ${dep_name}_TYPE)

if (NOT DEFINED ${PROJECT_NAME}_${c_name}_TYPE)
	message("ERROR add_Component_Dependency : the component ${c_name} has not been defined")
endif(NOT DEFINED ${PROJECT_NAME}_${c_name}_TYPE)

if(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "HEADER")
	# specific case when the type of component is pure header 
	# => there is no target to populate with target_xxx functions
	#adding the dependency to the list of dependencies of the component
	set(${PROJECT_NAME}_${c_name}_DEPENDENCIES ${${PROJECT_NAME}_${c_name}_DEPENDENCIES};${dep_name} CACHE INTERNAL "")
	return() #no need to do more
else(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "HEADER")
	#adding the dependency to the list of dependencies of the component
	set(${PROJECT_NAME}_${c_name}_DEPENDENCIES ${${PROJECT_NAME}_${c_name}_DEPENDENCIES};${dep_name} CACHE INTERNAL "")
endif()

# compile and link time operations have to be done
fill_Component_Target_Compilation(${c_name} ${dep_name})
fill_Component_Target_Linking(${c_name} ${dep_name})

endfunction(add_Component_Dependency c_name dep_name)


