
PROJECT(<package name>)
CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
# generic variables
set(FRAMEWORKS_DIR ${CMAKE_SOURCE_DIR}/../../installs)
set(FRAMEWORK_PATH ${FRAMEWORKS_DIR}/neobotix-mpo700-robot)
# basic build options
option(MPO700_ROBOT_WITH_EXAMPLES "Package builds examples" ON)
option(MPO700_ROBOT_WITH_TESTS "Package uses tests" OFF)

# setting the current version number
set (MPO700_ROBOT_VERSION_MAJOR 0)
set (MPO700_ROBOT_VERSION_MINOR 1)
set (MPO700_ROBOT_VERSION_PATCH 0)
set(MPO700_ROBOT_VERSION ${MPO700_ROBOT_VERSION_MAJOR}.${MPO700_ROBOT_VERSION_MINOR}.${MPO700_ROBOT_VERSION_PATCH})

# configuring installation process into frameworks: by default
# version specific deployment is selected except if users define
# USE_CUSTOM_DEPLOYMENT variable
option(USE_CUSTOM_DEPLOYMENT "Package uses tests" ON)
if(USE_CUSTOM_DEPLOYMENT)
MESSAGE("Deployment : Custom")
set(DEPLOY_PATH own)
else(USE_CUSTOM_DEPLOYMENT)
MESSAGE("Deployment : version ${MPO700_ROBOT_VERSION}")
set(DEPLOY_PATH ${MPO700_ROBOT_VERSION})
endif(USE_CUSTOM_DEPLOYMENT)

set(CMAKE_INSTALL_PREFIX ${FRAMEWORK_PATH})

# adding the cmake scripts files from the package
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMakeModules)

##### finding system dependencies #####
SET(EXTERNAL_INCLUDE_DIRS "")
SET(EXTERNAL_LIB_DIRS "")
SET(EXTERNAL_LIBS "")
SET(EXTERNAL_APPS "")
SET(EXTERNAL_APP_DIRS "")

## managing dependencies ##
find_package (Threads REQUIRED)
list(APPEND EXTERNAL_LIBS ${CMAKE_THREAD_LIBS_INIT})
## end managing dependencies ##

# if all dependencies are satisfied
include_directories(include)
include_directories(${EXTERNAL_INCLUDE_DIRS})
link_directories(${EXTERNAL_LIB_DIRS})

set ( INSTALL_LIB_PATH ${DEPLOY_PATH}/lib)
set ( INSTALL_AR_PATH ${DEPLOY_PATH}/lib)
set ( INSTALL_HEADERS_PATH ${DEPLOY_PATH}/include)
set ( INSTALL_TESTS_PATH ${DEPLOY_PATH}/tests)
set ( INSTALL_CONFIG_PATH ${DEPLOY_PATH}/config)
set ( INSTALL_SHARE_PATH ${DEPLOY_PATH}/share)
set ( INSTALL_BIN_PATH ${DEPLOY_PATH}/bin)

if(CMAKE_BUILD_TYPE MATCHES Release)
set ( INSTALL_PATH_SUFFIX release)
elseif(CMAKE_BUILD_TYPE MATCHES Debug)
set ( INSTALL_PATH_SUFFIX debug)
endif(CMAKE_BUILD_TYPE MATCHES Release)

option(MPO700_ROBOT_WITH_TESTS "Package generates tests" OFF)
option(MPO700_ROBOT_WITH_EXAMPLES "Package generates examples" OFF)

add_subdirectory(src)
add_subdirectory(apps)
add_subdirectory(test)
add_subdirectory(share)
add_subdirectory(config)


option(GENERATE_INSTALL "Package generate an OS installer for linux with tgz and if possible debian" OFF)
if(GENERATE_INSTALL)
include(InstallRequiredSystemLibraries)
set(CPACK_GENERATOR TGZ)
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_CONTACT "Robin Passama")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "contains libraries implementing driver of the MPO700 mobile robot")
set(CPACK_PACKAGE_VENDOR "LIRMM")
set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/license.txt)
set(CPACK_PACKAGE_VERSION_MAJOR ${MPO700_ROBOT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR "${MPO700_ROBOT_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${MPO700_ROBOT_VERSION_PATCH}")
set(CPACK_PACKAGE_VERSION "${MPO700_ROBOT_VERSION}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "${FRAMEWORK_PATH}/installers")

if(UNIX AND NOT APPLE)
list(APPEND CPACK_GENERATOR DEB)
endif(UNIX AND NOT APPLE)
include(CPack)
endif(GENERATE_INSTALL)

