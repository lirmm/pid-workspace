
#
# A convenience macro to create adequate variables in the context of the parent scope.
# used to handle components
#

##################################################################################
###########################  declaration of the package ##########################
##################################################################################
macro(declare_package major minor patch author institution description)

set(${PROJECT_NAME}_MAIN_AUTHOR ${author})
set(${PROJECT_NAME}_INSTITUTION ${institution})
set(${PROJECT_NAME}_DESCRIPTION ${description})

# generic variables
set(FRAMEWORKS_DIR ${CMAKE_SOURCE_DIR}/../../frameworks)
set(${PROJECT_NAME}_FRAMEWORK_PATH ${FRAMEWORKS_DIR}/${PROJECT_NAME})

# basic build options
option(${PROJECT_NAME}_WITH_EXAMPLES "Package builds examples" ON)
option(${PROJECT_NAME}_WITH_TESTS "Package uses tests" OFF)
option(${PROJECT_NAME}_WITH_PRINT_MESSAGES "Package generates print in console" OFF)

if(${PROJECT_NAME}_WITH_PRINT_MESSAGES)
add_definitions(-DPRINT_MESSAGES)
endif(${PROJECT_NAME}_WITH_PRINT_MESSAGES)

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

set(${PROJECT_NAME}_COMPONENTS "")

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

if(CMAKE_BUILD_TYPE MATCHES Release)
set ( INSTALL_PATH_SUFFIX release)
elseif(CMAKE_BUILD_TYPE MATCHES Debug)
set ( INSTALL_PATH_SUFFIX debug)
endif(CMAKE_BUILD_TYPE MATCHES Release)

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

file(COPY ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-Linux.tar.gz
	DESTINATION ${${PROJECT_NAME}_FRAMEWORK_PATH}/installers/${INSTALL_PATH_SUFFIX})

if(UNIX AND NOT APPLE)
file(COPY ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-Linux.deb
	DESTINATION ${${PROJECT_NAME}_FRAMEWORK_PATH}/installers/${INSTALL_PATH_SUFFIX})
endif(UNIX AND NOT APPLE)

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
	list(APPEND ${PROJECT_NAME}_COMPONENTS ${c_name})
	list(APPEND ${PROJECT_NAME}_COMPONENTS_HEADERS ${c_name})	
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
	message(${c_name})

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
	list(APPEND ${PROJECT_NAME}_COMPONENTS ${c_name})
	list(APPEND ${PROJECT_NAME}_COMPONENTS_LIBS ${c_name})
endmacro(buildLibComponent)


##################################################################################
###################### declaration of an example component #######################
##################################################################################
macro(buildExampleComponent c_name used_libraries_list)
	#managing sources
	set(${PROJECT_NAME}_COMP_APP_${c_name}_SOURCE_DIR ${CMAKE_SOURCE_DIR}/apps/${c_name})
	
	message("libs = "${used_libraries_list})
	file(GLOB_RECURSE ${PROJECT_NAME}_COMP_APP_${c_name}_ALL_SOURCES "${c_name}/*.c" "${c_name}/*.cpp" "${c_name}/*.h" "${c_name}/*.hpp")
	
	add_executable(${c_name} EXCLUDE_FROM_ALL ${${PROJECT_NAME}_COMP_APP_${c_name}_ALL_SOURCES})
	target_link_libraries(${c_name} ${used_libraries_list})

	# installing library
	INSTALL(TARGETS ${c_name} 
	RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}/${INSTALL_PATH_SUFFIX}
	)

	#updating global variables of the CMake process	
	list(APPEND ${PROJECT_NAME}_COMPONENTS ${c_name})
	list(APPEND ${PROJECT_NAME}_COMPONENTS_APPS ${c_name})
endmacro(buildExampleComponent)

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
	list(APPEND ${PROJECT_NAME}_COMPONENTS ${c_name})
	list(APPEND ${PROJECT_NAME}_COMPONENTS_APPS ${c_name})
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

