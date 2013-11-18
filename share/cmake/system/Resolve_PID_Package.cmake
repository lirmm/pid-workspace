include(${WORKSPACE_DIR}/share/cmake/system/Workspace_Internal_Functions.cmake)

if(REQUIRED_PACKAGE AND REQUIRED_VERSION)
	if(	NOT EXISTS ${WORKSPACE_DIR}/install/${REQUIRED_PACKAGE} 
		OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/install/${REQUIRED_PACKAGE}
		OR NOT EXISTS ${WORKSPACE_DIR}/install/${REQUIRED_PACKAGE}/${REQUIRED_VERSION}
		OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/install/${REQUIRED_PACKAGE}/${REQUIRED_VERSION}
	)
		message("ERROR : binary package version ${REQUIRED_VERSION} is not installed on the system")
		return()
	endif()
	resolve_PID_Package(${REQUIRED_PACKAGE} ${REQUIRED_VERSION})
else()
	message("ERROR : You must specify (1) a package using argument name=<name of package>, (2) a package version using argument version=<version number>")
	return()
endif()



