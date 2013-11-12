include(../share/cmake/system/Workspace_Internal_Functions.cmake)

if(REQUIRED_PACKAGE)
	include(../share/cmake/references/Refer${REQUIRED_PACKAGE}.cmake OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
		message(FATAL_ERROR "Package name ${REQUIRED_PACKAGE} does not refer to any known package in the workspace")
	endif()
	if(REQUIRED_VERSION)
		message("Deploying package ${REQUIRED_PACKAGE} binary archive with version ${REQUIRED_VERSION}")
	endif()	
	deploy_PID_Package(${REQUIRED_PACKAGE} "${REQUIRED_VERSION}")

else()
	message(FATAL_ERROR "You must specify a package using name=<name of package> argument")
endif()


