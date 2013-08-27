PROJECT(<package name>)
CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
set(WORKSPACE_DIR ${CMAKE_SOURCE_DIR}/../.. CACHE PATH "root of the packages workspace directory")
mark_as_advanced(WORKSPACE_DIR)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/CMakeModules) # adding the cmake scripts files from the package
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/CMakeModules) #using generic and/or common modules of the workspace
include(Package_Definition)

declare_Package(0 1 0 "Robin Passama" "LIRMM" "libraries implementing driver for communication with the MPO700 mobile robot") #here simply change the package version

## managing dependencies ## here manage all required system dependencies
find_package (Threads REQUIRED)
list(APPEND ${PROJECT_NAME}_EXTERNAL_LIBS ${CMAKE_THREAD_LIBS_INIT})
## end managing dependencies ##

build_Package()#building the package

printComponentVariables()


