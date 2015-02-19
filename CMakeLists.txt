CMAKE_MINIMUM_REQUIRED(VERSION 2.8.12)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/licenses)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/share/cmake/find)
include(Workspace_Internal_Functions NO_POLICY_SCOPE)

PROJECT(pid-workspace)

set(ALL_AVAILABLE_PACKAGES "")
# 1) searching for all reference files. 
file(GLOB reference_files ${CMAKE_SOURCE_DIR}/share/cmake/references/Refer*.cmake)
# 2) including all reference files and memorizing packages names
foreach(a_ref_file IN ITEMS ${reference_files})
	string(REGEX REPLACE "^${CMAKE_SOURCE_DIR}/share/cmake/references/Refer([^\\.]+)\\.cmake$" "\\1" PACKAGE_NAME ${a_ref_file})
	list(APPEND ALL_AVAILABLE_PACKAGES ${PACKAGE_NAME})
	include(${a_ref_file})
endforeach()
# 3) resetting categories
reset_All_Categories()
# 4) extracting all available categories and classifying all packages in these categories
foreach(a_package IN ITEMS ${ALL_AVAILABLE_PACKAGES})
	classify_Package_Categories(${a_package})
endforeach()
#5) registering categories
write_Categories_File()

#adding targets
add_custom_target(help ALL
	COMMAND ${CMAKE_COMMAND} -E echo "Available PID commands:"
	COMMAND ${CMAKE_COMMAND} -E echo "list -- listing all packages ordered by categories OR listing the content of a given category using name=NAME_OF_CATEGORY argument."
	COMMAND ${CMAKE_COMMAND} -E echo "info -- getting info on a given package using name=NAME_OF_PACKAGE argument."
	COMMAND ${CMAKE_COMMAND} -E echo "deploy -- deploying a package, either soure repository or binary relocatable archive. Use only name=NAME_OF_PACKAGE argument to deploy source repository or use in addition version=VERSION to deploy the specific binary version."
	COMMAND ${CMAKE_COMMAND} -E echo "resolve -- resolving runtime dependencies of an already installed package. Use name=NAME_OF_PACKAGE and version=VERSION arguments to specify the target binary package."
	COMMAND ${CMAKE_COMMAND} -E echo "create -- create a new package. Use name=NAME_OF_PACKAGE to specify the name of the new package. Other optional arguments are: author, affiliation, license."
	COMMAND ${CMAKE_COMMAND} -E echo "connect -- Synchronize local repository with an empty remote one. Required arguments are : name to specify the name of the package and url to specify the url of the remote repository."
	COMMAND ${CMAKE_COMMAND} -E echo "license -- Printing information on licenses or more precise information on a given license using name=NAME_OF_LICENSE argument."
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## listing all packages ordered by categories OR listing the content of a given category
add_custom_target(list
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DREQUIRED_CATEGORY=$(name) 
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Print_PID_Categories.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## getting info on a package
add_custom_target(info
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DREQUIRED_PACKAGE=$(name)
					-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Print_PID_Package_Info.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## deploying a package (either soure repository or binary package relocatable archive) 
add_custom_target(deploy
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DPACKAGE_BINARY_INSTALL_DIR=${CMAKE_SOURCE_DIR}/install
					-DCMAKE_FIND_LIBRARY_PREFIXES=${CMAKE_FIND_LIBRARY_PREFIXES}
					-DCMAKE_FIND_LIBRARY_SUFFIXES=${CMAKE_FIND_LIBRARY_SUFFIXES}
					-DREQUIRED_PACKAGE=$(name) 
					-DREQUIRED_VERSION=$(version)
					-DCMAKE_SOURCE_DIR=${CMAKE_SOURCE_DIR}
					-DCMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}
					-DCMAKE_BUILD_TOOL=${CMAKE_BUILD_TOOL}
					-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Deploy_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## resolving runtime dependencies of an already installed package
add_custom_target(resolve
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-DPACKAGE_BINARY_INSTALL_DIR=${CMAKE_SOURCE_DIR}/install
					-DCMAKE_FIND_LIBRARY_PREFIXES=${CMAKE_FIND_LIBRARY_PREFIXES}
					-DCMAKE_FIND_LIBRARY_SUFFIXES=${CMAKE_FIND_LIBRARY_SUFFIXES}
					-DREQUIRED_PACKAGE=$(name) 
					-DREQUIRED_VERSION=$(version)
					-DCMAKE_SOURCE_DIR=${CMAKE_SOURCE_DIR}
					-DCMAKE_BINARY_DIR=${CMAKE_BINARY_DIR}
					-DCMAKE_BUILD_TOOL=${CMAKE_BUILD_TOOL}
					-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Resolve_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## creating a new package
add_custom_target(create
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DREQUIRED_PACKAGE=$(name) 
					-DOPTIONAL_AUTHOR="$(author)" 
					-DOPTIONAL_INSTITUTION="$(affiliation)"
					-DOPTIONAL_LICENSE=$(license)
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Create_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## connect to newly created PID package to an existing empty repository
add_custom_target(connect
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DREQUIRED_PACKAGE=$(name) 
					-DREQUIRED_GIT_URL=$(url) 
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Connect_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)


## listing available licenses
add_custom_target(license
	COMMAND ${CMAKE_COMMAND} 	-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR} 
					-DREQUIRED_LICENSE=$(name)
					-P ${CMAKE_SOURCE_DIR}/share/cmake/system/Print_PID_License_Info.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

