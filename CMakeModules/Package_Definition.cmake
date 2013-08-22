
#
# A convenience set of macros to create adequate variables in the context of the parent scope.
# used to define components of a package
#

##################################################################################
###########################  declaration of the package ##########################
##################################################################################
macro(declare_package major minor patch author institution description)

set(${PROJECT_NAME}_MAIN_AUTHOR ${author})
set(${PROJECT_NAME}_INSTITUTION ${institution})
set(${PROJECT_NAME}_DESCRIPTION ${description})

# generic variables
set(WORKSPACE_DIR ${CMAKE_SOURCE_DIR}/../..)
set(FRAMEWORKS_DIR ${WORKSPACE_DIR}/frameworks)
set(${PROJECT_NAME}_FRAMEWORK_PATH ${FRAMEWORKS_DIR}/${PROJECT_NAME})

# basic build options
option(BUILD_WITH_EXAMPLES "Package builds examples" ON)
option(BUILD_WITH_TESTS "Package uses tests" OFF)
option(BUILD_WITH_PRINT_MESSAGES "Package generates print in console" OFF)

if(BUILD_WITH_PRINT_MESSAGES)
add_definitions(-DPRINT_MESSAGES)
endif(BUILD_WITH_PRINT_MESSAGES)

# setting the current version number
set (${PROJECT_NAME}_VERSION_MAJOR ${major})
set (${PROJECT_NAME}_VERSION_MINOR ${minor})
set (${PROJECT_NAME}_VERSION_PATCH ${patch})
set (${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH})

message("version currently built = "${${PROJECT_NAME}_VERSION}) 

# configuring installation process into frameworks: by default
# version specific deployment is selected except if users define
# USE_CUSTOM_DEPLOYMENT variable
option(USE_LOCAL_DEPLOYMENT "Package uses tests" ON)
if(USE_LOCAL_DEPLOYMENT)
MESSAGE("Deployment : Local")
set(${PROJECT_NAME}_DEPLOY_PATH own)
else(USE_LOCAL_DEPLOYMENT)
MESSAGE("Deployment : version ${${PROJECT_NAME}_VERSION}")
set(${PROJECT_NAME}_DEPLOY_PATH ${${PROJECT_NAME}_VERSION})
endif(USE_LOCAL_DEPLOYMENT)

set(CMAKE_INSTALL_PREFIX ${${PROJECT_NAME}_FRAMEWORK_PATH})

set(${PROJECT_NAME}_COMPONENTS "" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_HEADERS "" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_LIBS "" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_APPS "" CACHE INTERNAL "")

##### finding system dependencies #####
SET(${PROJECT_NAME}_EXTERNAL_INCLUDE_DIRS "")
SET(${PROJECT_NAME}_EXTERNAL_LIB_DIRS "")
SET(${PROJECT_NAME}_EXTERNAL_LIBS "")
SET(${PROJECT_NAME}_EXTERNAL_APPS "")
SET(${PROJECT_NAME}_EXTERNAL_APP_DIRS "")

set ( ${PROJECT_NAME}_INSTALL_LIB_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib)
set ( ${PROJECT_NAME}_INSTALL_AR_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib)
set ( ${PROJECT_NAME}_INSTALL_HEADERS_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/include)
set ( ${PROJECT_NAME}_INSTALL_TESTS_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/tests)
set ( ${PROJECT_NAME}_INSTALL_CONFIG_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/config)
set ( ${PROJECT_NAME}_INSTALL_SHARE_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/share)
set ( ${PROJECT_NAME}_INSTALL_BIN_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/bin)

if(${CMAKE_BINARY_DIR} MATCHES release)
set(CMAKE_BUILD_TYPE "Release" CACHE String "the type of build is dependent from build location" FORCE)
set ( INSTALL_PATH_SUFFIX release)
elseif(${CMAKE_BINARY_DIR} MATCHES debug)
set(CMAKE_BUILD_TYPE "Debug" CACHE String "the type of build is dependent from build location" FORCE)
set ( INSTALL_PATH_SUFFIX debug)
endif(${CMAKE_BINARY_DIR} MATCHES release)

endmacro(declare_package)

##################################################################################
################################### building the package #########################
##################################################################################
macro(build_package)

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

endmacro(build_package)



##################################################################################
###################### declaration of a header component #########################
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


##################################################################################
########## adding source code of the example components to the API doc ###########
##################################################################################
macro(addSourceOfExampleComponent source_dir_of_a_component)
file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/share/examples/)
file(COPY ${source_dir_of_a_component} DESTINATION ${PROJECT_BINARY_DIR}/share/examples/)
endmacro(addSourceOfExampleComponent)

##################################################################################
################### generating API documentation for the package #################
##################################################################################
macro(generate_API)
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
"${DOXYFILE_OUTPUT_DIR}/${DOXYFILE_LATEX_DIR}")

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
endmacro(generate_API)

