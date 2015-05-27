
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
include(Workspace_Internal_Functions NO_POLICY_SCOPE)

if(TARGET_PACKAGE)
	if(TARGET_PACKAGE STREQUAL "all")
		if(EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
			update_PID_Source_Package(${TARGET_PACKAGE})
		else()
			# it may be a binary package
			update_PID_Binary_Package(${TARGET_PACKAGE})
		endif()
	else()
		update_PID_All_Package()
	endif()
else()
	message("ERROR : You must specify the name of the package to update using name= argument. If you use all as name, all packages will be updated, either they are binary or source.")
endif()

