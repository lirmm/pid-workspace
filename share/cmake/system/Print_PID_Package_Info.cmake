list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)

include(Workspace_Internal_Functions NO_POLICY_SCOPE)

if(REQUIRED_PACKAGE)
	include(Refer${REQUIRED_PACKAGE} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
		
		include(ReferExternal${REQUIRED_PACKAGE} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
		if(REQUIRED_STATUS STREQUAL NOTFOUND)
			message("ERROR : Package name ${REQUIRED_PACKAGE} does not refer to any known package in the workspace")
			return()
		endif()
		print_External_Package_Info(${REQUIRED_PACKAGE})
		return()
	endif()
	print_Package_Info(${REQUIRED_PACKAGE})

else()
	message("ERROR : You must specify a package using name=<name of package> argument")
endif()


