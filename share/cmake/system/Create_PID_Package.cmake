include(../share/cmake/system/Workspace_Internal_Functions.cmake)

if(REQUIRED_PACKAGE)
	create_PID_Package(${REQUIRED_PACKAGE})
else()
	message(FATAL_ERROR "You must specify a name for the package to create using name=<name of package> argument")
endif()



