
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
include(Workspace_Internal_Functions NO_POLICY_SCOPE)

if(TARGET_PACKAGE)
	if(EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
		release_PID_Package(${TARGET_PACKAGE} "${NEXT_VERSION}")
	else()
		message("ERROR : the target package ${TARGET_PACKAGE} does not exist")
	endif()
else()
	message("ERROR : You must specify the name of the package to release using name=<name of package> argument")
endif()

