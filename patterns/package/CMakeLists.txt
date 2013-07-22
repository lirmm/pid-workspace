
PROJECT(<package name>)
CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
# generic variables
set(FRAMEWORKS_DIR ${CMAKE_SOURCE_DIR}/../../frameworks)
set(FRAMEWORK_PATH ${FRAMEWORKS_DIR}/${PROJECT_NAME})

# basic build options
option(${PROJECT_NAME}_WITH_EXAMPLES "Package builds examples" ON)
option(${PROJECT_NAME}_WITH_TESTS "Package uses tests" OFF)

# setting the current version number
set (${PROJECT_NAME}_VERSION_MAJOR 0)
set (${PROJECT_NAME}_VERSION_MINOR 1)
set (${PROJECT_NAME}_VERSION_PATCH 0)
set(${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH})

# configuring installation process into frameworks: by default
# version specific deployment is selected except if users define
# USE_LOCAL_DEPLOYMENT variable

# just use the option USE STANDARD DEPLOYMENT if you want to install 
# in basic install folmders (e.g. /usr/local/include, /usr/local/lib and /usr/local/bin) 
option(USE_STANDARD_DEPLOYMENT "Package uses standard deployment rules" OFF)
if (USE_STANDARD_DEPLOYMENT)
message("Deployment : standard deployment ...")
else(USE_STANDARD_DEPLOYMENT)
option(USE_LOCAL_DEPLOYMENT "Package uses tests" ON)
if(USE_LOCAL_DEPLOYMENT)
MESSAGE("Deployment : package is deployed in the own folder of its framework")
set(DEPLOY_PATH own)
else(USE_LOCAL_DEPLOYMENT)
MESSAGE("Deployment : package is deployed in the version folder ${${PROJECT_NAME}_VERSION} of its framework")
set(DEPLOY_PATH ${${PROJECT_NAME}_VERSION})
endif(USE_LOCAL_DEPLOYMENT)
set(CMAKE_INSTALL_PREFIX ${FRAMEWORK_PATH})
endif(USE_STANDARD_DEPLOYMENT)


# adding the cmake scripts files from the package 
# and from the workspace
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMakeModules)
if (NOT USE_STANDARD_DEPLOYMENT)
list(APPEND CMAKE_MODULE_PATH /../../CMakeModules)
endif(NOT USE_STANDARD_DEPLOYMENT)
#otherwise cmake scripts must be insalled else where (default folder)


##### finding system dependencies #####
SET(EXTERNAL_INCLUDE_DIRS "")
SET(EXTERNAL_LIB_DIRS "")
SET(EXTERNAL_LIBS "")
SET(EXTERNAL_APPS "")
SET(EXTERNAL_APP_DIRS "")

## absolutely required dependencies ##
find_package(<name of resource> REQUIRED)
list(APPEND EXTERNAL_INCLUDE_DIRS ${<name of resource>_INCLUDE_DIRS})
list(APPEND EXTERNAL_LIB_DIRS ${<name of resource>_LINK_DIRECTORIES})

## optional system dependencies ##
find_package(<name of resource 4>)
if(<name of resource 4>_FOUND)
option(USE_<name of resource 4> "Using <name of resource 4>" ON)
else(<name of resource 4>_FOUND)
set (USE_<name of resource 4> FALSE)
endif(<name of resource>_FOUND)
if(USE_<name of resource 4>)
list(APPEND EXTERNAL_INCLUDE_DIRS ${<name of resource 4>_INCLUDE_DIRS})
list(APPEND EXTERNAL_LIB_DIRS ${<name of resource 4>_LINK_DIRECTORIES})
add_definitions(-DUSE_<name of resource 4>)
endif(USE_<name of resource 4>)
#...

## alternatively required system dependencies ##
# defining alternative 1
find_package(<name of resource 2>)
if(<name of resource 2>_FOUND)
option(USE_<name of resource2> "Using <name of resource2>" ON)
else(<name of resource 2>_FOUND)
set(USE_<name of resource2> FALSE)
endif(<name of resource 2>_FOUND)
# defining alternative 2
find_package(<name of resource 3>)
if(<name of resource 3>_FOUND)
option(USE_<name of resource3> "Using <name of resource3>" ON)
else(<name of resource 3>_FOUND)
set(USE_<name of resource 3> FALSE)
endif(<name of resource 3>_FOUND)

# selecting the alternative
if(USE_<name of resource 2>)
list(APPEND EXTERNAL_INCLUDE_DIRS ${<resource 2_INCLUDE_DIRS>})
list(APPEND EXTERNAL_LIB_DIRS ${<resource 2_LINK_DIRECTORIES>})
add_definitions(-DUSE_<name of resource 2>) #using same flag in code
elseif(USE_<name of resource 3>)
list(APPEND EXTERNAL_INCLUDE_DIRS ${<resource 3_INCLUDE_DIRS>})
list(APPEND EXTERNAL_LIB_DIRS ${<resource 3_LINK_DIRECTORIES>})
add_definitions(-DUSE_<name of resource 3>) #using same flag in code
else(USE_<name of resource 2>)
message("alternative system dependency not satisfied. Install/select either 
<name of resource 2>, <name of resource 3> or <name of resource 4>")
return()
endif(USE_<name of resource 2>)
#...
##### end finding system dependencies #####

##### finding package dependencies #####
find_package(FrameworkFinder REQUIRED COMPONENTS <package 1> <package 2> ...)
list(APPEND EXTERNAL_INCLUDE_DIRS ${<package 1>_INCLUDE_DIRS})
list(APPEND EXTERNAL_LIB_DIRS ${<package 1>_LINK_DIRECTORIES})
list(APPEND EXTERNAL_LIBS ${<package 1>_LIBRARIES})
list(APPEND EXTERNAL_APP_DIRS ${<package 1>_APP_DIRS})
list(APPEND EXTERNAL_APPS ${<package 1>_APPLICATIONS})

list(APPEND EXTERNAL_INCLUDE_DIRS ${<package 2>_INCLUDE_DIRS})
list(APPEND EXTERNAL_LIB_DIRS ${<package 2>_LINK_DIRECTORIES})
list(APPEND EXTERNAL_LIBS ${<package 2>_LIBRARIES})
#...

##### end finding package dependencies #####

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
set(CPACK_PACKAGE_CONTACT "<author name>")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "<short description>")
set(CPACK_PACKAGE_VENDOR "LIRMM")
set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/license.txt)
set(CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR "${${PROJECT_NAME}_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${${PROJECT_NAME}_VERSION_PATCH}")
set(CPACK_PACKAGE_VERSION "${${PROJECT_NAME}_VERSION}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "${FRAMEWORK_PATH}/installers")

if(UNIX AND NOT APPLE)
list(APPEND CPACK_GENERATOR DEB)
endif(UNIX AND NOT APPLE)
include(CPack)
endif(GENERATE_INSTALL)

