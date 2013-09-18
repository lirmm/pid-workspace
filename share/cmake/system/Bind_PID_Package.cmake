
###################################################################################
### this is the script file to call with cmake -P to rebind a package's content ###
###################################################################################
## arguments (passed with -D<name>=<value>): WORKSPACE_DIR, PACKAGE_NAME, PACKAGE_VERSION, REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD (TRUE or FALSE)

include(${WORKSPACE_DIR}/install/${PACKAGE_NAME}/${PACKAGE_VERSION}/share/Use${PACKAGE_NAME}-${PACKAGE_VERSION}.cmake OPTIONAL RESULT_VARIABLE res)
#using the generated Use<package>-<version>.cmake file to get adequate version information about components
if(	${res} STREQUAL NOTFOUND
	OR NOT DEFINED ${PACKAGE_NAME}_COMPONENTS) #if there is no component defined for the package there is an error
	message("The binary package ${PACKAGE_NAME} (version ${PACKAGE_VERSION}) whose runtime dependencies must be (re)bound cannot be found from the workspace path : ${WORKSPACE_DIR}")
	return()
endif()
set(BIN_PACKAGE_PATH ${WORKSPACE_DIR}/install/${PACKAGE_NAME}/${PACKAGE_VERSION})
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system) # using systems scripts the workspace
list(APPEND CMAKE_MODULE_PATH ${BIN_PACKAGE_PATH}/share/cmake) # adding the cmake find scripts files from the package
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/find) # using common find modules of the workspace
include(Package_Internal_Definition)

# resolving external dependencies
# 1) getting all the runtime external dependencies of the package
foreach(ext_dep IN ITEMS ${${PACKAGE_NAME}_EXTERNAL_DEPENDENCIES_DEBUG})
	if(${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_USE_RUNTIME_DEBUG)
		list(APPEND ALL_EXTERNAL_DEPS_DEBUG ${ext_dep})
	endif()
endforeach()
foreach(ext_dep IN ITEMS ${${PACKAGE_NAME}_EXTERNAL_DEPENDENCIES})
	if(${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_USE_RUNTIME)
		list(APPEND ALL_EXTERNAL_DEPS ${ext_dep})
	endif()
endforeach()

# 2) looking for unresolved external runtime dependencies
foreach(ext_dep IN ITEMS ${ALL_EXTERNAL_DEPS_DEBUG})
	if(CONFIG_${ext_dep})#the path has been set by the user with -DCONFIG_<package>=<path> argument
		set(${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_REFERENCE_PATH_DEBUG ${CONFIG_${ext_dep}})#changing the reference path
	else()
		list(APPEND NOT_DEFINED_EXT_DEPS_DEBUG ${ext_dep})
	endif()
endforeach()
foreach(ext_dep IN ITEMS ${ALL_EXTERNAL_DEPS})
	if(CONFIG_${ext_dep})#the path has been set by the user with -DCONFIG_<package>=<path> argument
		set(${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_REFERENCE_PATH ${CONFIG_${ext_dep}})#changing the reference path
	else()
		list(APPEND NOT_DEFINED_EXT_DEPS ${ext_dep})
	endif()
endforeach()

if(NOT_DEFINED_EXT_DEPS)
	message("External packages whose path must be resolved by hand (using -DCONFIG_<package>=<path>)")
	foreach(ext_dep IN ITEMS ${NOT_DEFINED_EXT_DEPS_DEBUG})
		message("DEBUG mode : ${ext_dep} with path = ${${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_REFERENCE_PATH_DEBUG}")
	endforeach()
	foreach(ext_dep IN ITEMS ${NOT_DEFINED_EXT_DEPS})
		message("RELEASE mode : ${ext_dep} with path = ${${PACKAGE_NAME}_EXTERNAL_DEPENDENCY_${ext_dep}_REFERENCE_PATH}")
	endforeach()
	return()
endif()
# 3) replacing "once and for all" (until next rebind call) these dependencies in the use file
set(theusefile ${WORKSPACE_DIR}/install/${PACKAGE_NAME}/${PACKAGE_VERSION}/share/Use${PACKAGE_NAME}-${PACKAGE_VERSION}.cmake)
file(WRITE ${theusefile} "")#resetting the file content
write_Use_File(${theusefile} ${PACKAGE_NAME} Release)
write_Use_File(${theusefile} ${PACKAGE_NAME} Debug)

# finding all dependencies
resolve_Package_Dependencies(${PACKAGE_NAME} "_DEBUG")
resolve_Package_Dependencies(${PACKAGE_NAME} "")

# resolving runtime dependencies
resolve_Package_Runtime_Dependencies(${PACKAGE_NAME} "Debug")
resolve_Package_Runtime_Dependencies(${PACKAGE_NAME} "Release")



