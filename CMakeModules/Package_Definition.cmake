
#
# A convenience set of macros to create adequate variables in the context of the parent scope.
# used to define components of a package
#

##################################################################################
###########################  declaration of the package ##########################
##################################################################################
function(declare_Package major minor patch author institution description)

set(${PROJECT_NAME}_MAIN_AUTHOR ${author} CACHE INTERNAL "")
set(${PROJECT_NAME}_INSTITUTION ${institution} CACHE INTERNAL "")
set(${PROJECT_NAME}_DESCRIPTION ${description} CACHE INTERNAL "")

# generic variables
set(WORKSPACE_DIR ${CMAKE_SOURCE_DIR}/../.. CACHE INTERNAL "")
set(FRAMEWORKS_DIR ${WORKSPACE_DIR}/frameworks CACHE INTERNAL "")
set(${PROJECT_NAME}_FRAMEWORK_PATH ${FRAMEWORKS_DIR}/${PROJECT_NAME} CACHE INTERNAL "")

# basic build options
option(BUILD_WITH_EXAMPLES "Package builds examples" ON)
option(BUILD_WITH_TESTS "Package uses tests" OFF)
option(BUILD_WITH_PRINT_MESSAGES "Package generates print in console" OFF)

if(BUILD_WITH_PRINT_MESSAGES)
add_definitions(-DPRINT_MESSAGES)
endif(BUILD_WITH_PRINT_MESSAGES)

# setting the current version number
set (${PROJECT_NAME}_VERSION_MAJOR ${major} CACHE INTERNAL "")
set (${PROJECT_NAME}_VERSION_MINOR ${minor} CACHE INTERNAL "")
set (${PROJECT_NAME}_VERSION_PATCH ${patch} CACHE INTERNAL "")
set (${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH} CACHE INTERNAL "")

message("version currently built = "${${PROJECT_NAME}_VERSION}) 

# configuring installation process into frameworks: by default
# version specific deployment is selected except if users define
# USE_CUSTOM_DEPLOYMENT variable
option(USE_LOCAL_DEPLOYMENT "Package uses tests" ON)
if(USE_LOCAL_DEPLOYMENT)
MESSAGE("Deployment : Local")
set(${PROJECT_NAME}_DEPLOY_PATH own CACHE INTERNAL "")
else(USE_LOCAL_DEPLOYMENT)
MESSAGE("Deployment : version ${${PROJECT_NAME}_VERSION}")
set(${PROJECT_NAME}_DEPLOY_PATH ${${PROJECT_NAME}_VERSION} CACHE INTERNAL "")
endif(USE_LOCAL_DEPLOYMENT)

set(CMAKE_INSTALL_PREFIX ${${PROJECT_NAME}_FRAMEWORK_PATH} CACHE INTERNAL "")

set(${PROJECT_NAME}_COMPONENTS "" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_HEADERS "" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_LIBS "" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_APPS "" CACHE INTERNAL "")

##### finding system dependencies #####
SET(${PROJECT_NAME}_EXTERNAL_INCLUDE_DIRS "" CACHE INTERNAL "")
SET(${PROJECT_NAME}_EXTERNAL_LIB_DIRS "" CACHE INTERNAL "")
SET(${PROJECT_NAME}_EXTERNAL_LIBS "" CACHE INTERNAL "")
SET(${PROJECT_NAME}_EXTERNAL_APPS "" CACHE INTERNAL "")
SET(${PROJECT_NAME}_EXTERNAL_APP_DIRS "" CACHE INTERNAL "")

set ( ${PROJECT_NAME}_INSTALL_LIB_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
set ( ${PROJECT_NAME}_INSTALL_AR_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
set ( ${PROJECT_NAME}_INSTALL_HEADERS_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/include CACHE INTERNAL "")
set ( ${PROJECT_NAME}_INSTALL_TESTS_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/tests CACHE INTERNAL "")
set ( ${PROJECT_NAME}_INSTALL_CONFIG_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/config CACHE INTERNAL "")
set ( ${PROJECT_NAME}_INSTALL_SHARE_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/share CACHE INTERNAL "")
set ( ${PROJECT_NAME}_INSTALL_BIN_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/bin CACHE INTERNAL "")

if(${CMAKE_BINARY_DIR} MATCHES release)
set(CMAKE_BUILD_TYPE "Release" CACHE String "the type of build is dependent from build location" FORCE)
set ( INSTALL_PATH_SUFFIX release CACHE INTERNAL "")
elseif(${CMAKE_BINARY_DIR} MATCHES debug)
set(CMAKE_BUILD_TYPE "Debug" CACHE String "the type of build is dependent from build location" FORCE)
set ( INSTALL_PATH_SUFFIX debug CACHE INTERNAL "")
endif(${CMAKE_BINARY_DIR} MATCHES release)

endfunction(declare_Package)

##################################################################################
################################### building the package #########################
##################################################################################
function(build_Package)

# if all dependencies are satisfied
include_directories(include)
include_directories(${${PROJECT_NAME}_EXTERNAL_INCLUDE_DIRS})
link_directories(${${PROJECT_NAME}_EXTERNAL_LIB_DIRS})

#recursive call into subdirectories to build/install/test the package
add_subdirectory(src)
add_subdirectory(apps)
add_subdirectory(test)
add_subdirectory(share)
add_subdirectory(config)

#generating installers for the package
option(GENERATE_INSTALLER "Package generate an OS installer for linux with tgz and if possible debian" OFF)
if(GENERATE_INSTALLER)
include(InstallRequiredSystemLibraries)
set(CPACK_GENERATOR TGZ)
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_CONTACT ${${PROJECT_NAME}_MAIN_AUTHOR})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${${PROJECT_NAME}_DESCRIPTION})
set(CPACK_PACKAGE_VENDOR ${${PROJECT_NAME}_INSTITUTION})
set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/license.txt)
set(CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
set(CPACK_PACKAGE_VERSION "${${PROJECT_NAME}_VERSION}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}/${${PROJECT_NAME}_VERSION}")

if(UNIX AND NOT APPLE)
list(APPEND CPACK_GENERATOR DEB)
endif(UNIX AND NOT APPLE)
include(CPack)


if(UNIX AND NOT APPLE) #linux install
add_custom_target(package_install
			COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-Linux.tar.gz
				${${PROJECT_NAME}_FRAMEWORK_PATH}/installers/${INSTALL_PATH_SUFFIX}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-Linux.tar.gz
			DEPENDS ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-Linux.tar.gz
			COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-Linux.deb
				${${PROJECT_NAME}_FRAMEWORK_PATH}/installers/${INSTALL_PATH_SUFFIX}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-Linux.deb
			DEPENDS ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-Linux.tar.gz
			COMMENT "installing ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-Linux.deb in ${${PROJECT_NAME}_FRAMEWORK_PATH}/installers/${INSTALL_PATH_SUFFIX}"
		)
else(UNIX AND NOT APPLE) #apple install
add_custom_target(package_install
		   	COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-Linux.tar.gz
				${${PROJECT_NAME}_FRAMEWORK_PATH}/installers/${INSTALL_PATH_SUFFIX}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-Linux.tar.gz
			COMMENT "installing ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-Linux.tag.gz in ${${PROJECT_NAME}_FRAMEWORK_PATH}/installers/${INSTALL_PATH_SUFFIX}" 						 
		)
endif(UNIX AND NOT APPLE)

endif(GENERATE_INSTALLER)

#creating a global build command
if(GENERATE_INSTALLER)
if(CMAKE_BUILD_TYPE MATCHES Release)
add_custom_target(build 
			COMMAND ${CMAKE_BUILD_TOOL}
			COMMAND ${CMAKE_BUILD_TOOL} doc 
			COMMAND ${CMAKE_BUILD_TOOL} install
			COMMAND ${CMAKE_BUILD_TOOL} package
			COMMAND ${CMAKE_BUILD_TOOL} package_install
		) 
else(CMAKE_BUILD_TYPE MATCHES Release)
add_custom_target(build 
			COMMAND ${CMAKE_BUILD_TOOL} 
			COMMAND ${CMAKE_BUILD_TOOL} install
			COMMAND ${CMAKE_BUILD_TOOL} package
			COMMAND ${CMAKE_BUILD_TOOL} package_install
		) 
endif(CMAKE_BUILD_TYPE MATCHES Release)

else(GENERATE_INSTALLER)
if(CMAKE_BUILD_TYPE MATCHES Release)
add_custom_target(build 
			COMMAND ${CMAKE_BUILD_TOOL}
			COMMAND ${CMAKE_BUILD_TOOL} doc 
			COMMAND ${CMAKE_BUILD_TOOL} install
		) 
else(CMAKE_BUILD_TYPE MATCHES Release)
add_custom_target(build 
			COMMAND ${CMAKE_BUILD_TOOL} 
			COMMAND ${CMAKE_BUILD_TOOL} install
		) 
endif(CMAKE_BUILD_TYPE MATCHES Release)
endif(GENERATE_INSTALLER)

endfunction(build_Package)



##################################################################################
########## adding source code of the example components to the API doc ###########
##################################################################################
function(add_Example_To_Doc c_name)
file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/share/examples/)
file(COPY ${PROJECT_BINARY_DIR}/apps/${c_name} DESTINATION ${PROJECT_BINARY_DIR}/share/examples/)
endfunction(add_Example_To_Doc c_name)

##################################################################################
################### generating API documentation for the package #################
##################################################################################
function(generate_API)
option(GENERATE_LATEX_API "Generating the latex api documentation" ON)
if(CMAKE_BUILD_TYPE MATCHES Release) # if in release mode we generate the doc

#finding doxygen tool and doxygen configuration file 
find_package(Doxygen)
find_file(DOXYFILE_IN "Doxyfile.in"
			PATHS "${CMAKE_SOURCE_DIR}/share"
			NO_DEFAULT_PATH
			DOC "Path to the doxygen configuration template file")

if(NOT DOXYGEN_FOUND)
message("Doxygen not found please install it to generate the API documentation")
endif(NOT DOXYGEN_FOUND)
if(DOXYFILE_IN-NOTFOUND)
message("Doxyfile not found in the share folder of your package !!")
endif(DOXYFILE_IN-NOTFOUND)

if(DOXYGEN_FOUND AND NOT DOXYFILE_IN-NOTFOUND) #we are able to generate the doc
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
configure_file(${CMAKE_SOURCE_DIR}/share/Doxyfile.in ${CMAKE_BINARY_DIR}/share/Doxyfile @ONLY)

### end doxyfile configuration ###


### installing documentation ###

install(DIRECTORY ${CMAKE_BINARY_DIR}/share/doc DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})

### end installing documentation ###

endif(DOXYGEN_FOUND AND NOT DOXYFILE_IN-NOTFOUND)
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
	#updating global variables of the CMake process	
	set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
	set(${PROJECT_NAME}_COMPONENTS_HEADERS "${${PROJECT_NAME}_COMPONENTS_HEADERS};${c_name}" CACHE INTERNAL "")
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
	
	add_library(${c_name}_st STATIC ${${PROJECT_NAME}_COMP_LIB_${c_name}_ALL_SOURCES})
	target_link_libraries(${c_name}_st ${used_libraries_list})
	add_library(${c_name} SHARED ${${PROJECT_NAME}_COMP_LIB_${c_name}_ALL_SOURCES})
	target_link_libraries(${c_name} ${used_libraries_list})

	# installing library
	INSTALL(TARGETS ${c_name} ${c_name}_st
	RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}/${INSTALL_PATH_SUFFIX}
	LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}/${INSTALL_PATH_SUFFIX}
	ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_AR_PATH}/${INSTALL_PATH_SUFFIX}
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
	
	add_executable(${c_name} ${${PROJECT_NAME}_COMP_APP_${c_name}_ALL_SOURCES})
	target_link_libraries(${c_name} ${used_libraries_list})

	# installing library
	INSTALL(TARGETS ${c_name} 
	RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}/${INSTALL_PATH_SUFFIX}
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
	message("pure headers : "${${PROJECT_NAME}_COMPONENTS_HEADERS})
	message("libraries : "${${PROJECT_NAME}_COMPONENTS_LIBS})
	message("applications : "${${PROJECT_NAME}_COMPONENTS_APPS})
endmacro(printComponentVariables)


##################################################################################
############ generating/installing configuration files for the package ###########
##################################################################################
macro(configure_package)

# configure a cmake file to check if runtime dependencies of this package are satisfied 

configure_file (
  "${PROJECT_SOURCE_DIR}/share/Check${PROJECT_NAME}.cmake.in"
  "${PROJECT_BINARY_DIR}/share/Check${PROJECT_NAME}.cmake"
  )

# install the cmake "check" file in the share folder of the framework version

install(FILES "${PROJECT_BINARY_DIR}/share/Check${PROJECT_NAME}.cmake"        
         DESTINATION ${PROJECT_NAME}_DEPLOY_PATH/share
)

# configure a cmake file to help finding the current package

configure_file (
  "${PROJECT_SOURCE_DIR}/share/Find${PROJECT_NAME}.cmake.in"
  "${PROJECT_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake"
  )

# install the cmake "find" file in the share folder

install(FILES "${PROJECT_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake"        
         DESTINATION ${PROJECT_NAME}_DEPLOY_PATH/share
)

install(FILES "${PROJECT_BINARY_DIR}/share/Find${PROJECT_NAME}.cmake"        
         DESTINATION ${WORKSPACE_DIR}/CMakeModules
)
endmacro(configure_package)


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
	target_include_directories(${c_name}_st PUBLIC ${${dep_name}_INC_DIRS})
	endif(NOT ${${dep_name}_INC_DIRS} STREQUAL "")

	if(NOT ${${dep_name}_DEFS} STREQUAL "")
	target_compile_definitions(${c_name}_st PUBLIC ${${dep_name}_DEFS})
	endif(NOT ${${dep_name}_DEFS} STREQUAL "")

elseif(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "COMPLETE")
	if(NOT ${${dep_name}_INC_DIRS} STREQUAL "")
	target_include_directories(${c_name} PUBLIC ${${dep_name}_INC_DIRS})
	endif(NOT ${${dep_name}_INC_DIRS} STREQUAL "")

	if(NOT ${${dep_name}_DEFS} STREQUAL "")
	target_compile_definitions(${c_name} PUBLIC ${${dep_name}_DEFS})
	endif(NOT ${${dep_name}_DEFS} STREQUAL "")

	if(NOT ${${dep_name}_INC_DIRS} STREQUAL "")
	target_include_directories(${c_name}_st PUBLIC ${${dep_name}_INC_DIRS})
	endif(NOT ${${dep_name}_INC_DIRS} STREQUAL "")

	if(NOT ${${dep_name}_DEFS} STREQUAL "")
	target_compile_definitions(${c_name}_st PUBLIC ${${dep_name}_DEFS})
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

elseif(	${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "STATIC")
	if(NOT ${${dep_name}_LINKS} STREQUAL "")
	target_link_libraries(${c_name}_st ${${dep_name}_LINKS})
	endif(NOT ${${dep_name}_LINKS} STREQUAL "")
elseif(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "COMPLETE")
	if(NOT ${${dep_name}_LINKS} STREQUAL "")
	target_link_libraries(${c_name} ${${dep_name}_LINKS})
	endif(NOT ${${dep_name}_LINKS} STREQUAL "")
	if(NOT ${${dep_name}_LINKS} STREQUAL "")
	target_link_libraries(${c_name}_st ${${dep_name}_LINKS})
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
	set(${PROJECT_NAME}_${c_name}_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include/${c_name})
	
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
			add_library(${c_name}_st STATIC ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
			target_include_directories(${c_name}_st ${${PROJECT_NAME}_COMP_HEADER_${c_name}_INCLUDE_DIR})
			manage_Additional_Component_Flags(${c_name}_st ${defs} ${links} ${exp_defs} ${exp_links})
			INSTALL(TARGETS ${c_name}_st
			ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_AR_PATH}/${INSTALL_PATH_SUFFIX}
			)
		elseif(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "SHARED")
			add_library(${c_name} SHARED ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
			target_include_directories(${c_name} ${${PROJECT_NAME}_COMP_HEADER_${c_name}_INCLUDE_DIR})			
			manage_Additional_Component_Flags(${c_name} ${defs} ${links} ${exp_defs} ${exp_links})
			INSTALL(TARGETS ${c_name}
			LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}/${INSTALL_PATH_SUFFIX}
			)
		elseif(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "COMPLETE")
			add_library(${c_name}_st STATIC ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
			target_include_directories(${c_name}_st ${${PROJECT_NAME}_COMP_HEADER_${c_name}_INCLUDE_DIR})			
			manage_Additional_Component_Flags(${c_name}_st ${defs} ${links} ${exp_defs} ${exp_links})
			add_library(${c_name} SHARED ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
			target_include_directories(${c_name} ${${PROJECT_NAME}_COMP_HEADER_${c_name}_INCLUDE_DIR})
			manage_Additional_Component_Flags(${c_name} ${defs} ${links} ${exp_defs} ${exp_links})
			INSTALL(TARGETS ${c_name} ${c_name}_st
			LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}/${INSTALL_PATH_SUFFIX}
			ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_AR_PATH}/${INSTALL_PATH_SUFFIX}
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
	if(${type} STREQUAL "TEST" 
	OR ${type} STREQUAL "APP"
	OR ${type} STREQUAL "EXAMPLE")
		set(${PROJECT_NAME}_${c_name}_TYPE ${type} CACHE INTERNAL "")
	else() #a simple application by default
		set(${PROJECT_NAME}_${c_name}_TYPE "APP" CACHE INTERNAL "")
	endif()	
	
	# specifically managing examples 	
	if(${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "EXAMPLE") 
		add_Example_To_Doc(${c_name}) #examples are added to the doc to be referenced
		if(NOT BUILD_WITH_EXAMPLES) #examples are not built so no need to continue
			unset(${PROJECT_NAME}_${c_name}_TYPE CACHE)
			return()
		endif(NOT BUILD_WITH_EXAMPLES)
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
		INSTALL(TARGETS ${c_name} 
		RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}/${INSTALL_PATH_SUFFIX}
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

	if(NOT ${links} STREQUAL "")#adding link time flags
		set(${dep_name}_LINKS ${links} CACHE INTERNAL "")
	endif(NOT ${links} STREQUAL "")

	if(NOT ${inc_dirs} STREQUAL "")#adding include directories
		set(${dep_name}_INC_DIRS ${inc_dirs} CACHE INTERNAL "")
	endif(NOT ${inc_dirs} STREQUAL "")

endif()

endfunction(declare_Dependency)

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


