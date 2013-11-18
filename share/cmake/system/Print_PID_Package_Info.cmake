include(${WORKSPACE_DIR}/share/cmake/system/Workspace_Internal_Functions.cmake)

if(REQUIRED_PACKAGE)
	include(${WORKSPACE_DIR}/share/cmake/references/Refer${REQUIRED_PACKAGE}.cmake OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
		message("ERROR : Package name ${REQUIRED_PACKAGE} does not refer to any known package in the workspace")
		return()
	endif()
	print_Package_Info(${REQUIRED_PACKAGE})

else()
	message("ERROR : You must specify a package using name=<name of package> argument")
endif()


