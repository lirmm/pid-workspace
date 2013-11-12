include(../share/cmake/system/Workspace_Internal_Functions.cmake)

if(REQUIRED_PACKAGE AND REQUIRED_VERSION)
	resolve_PID_Package(${REQUIRED_PACKAGE} ${REQUIRED_VERSION})
else()
	message(FATAL_ERROR "You must specify (1) a package using argument name=<name of package>, (2) a package version using argument version=<version number>")
endif()



