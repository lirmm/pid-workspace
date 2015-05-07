
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
include(Workspace_Internal_Functions NO_POLICY_SCOPE)

if(TARGET_PACKAGE AND TARGET_VERSION)
	if(	EXISTS ${WORKSPACE_DIR}/install/${TARGET_PACKAGE}
		AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${TARGET_PACKAGE})
		clear_PID_Package(	${TARGET_PACKAGE} 
					${TARGET_VERSION})
	else()
		message("ERROR : there is no package named ${TARGET_PACKAGE} installed")
	endif()
else()
	message("ERROR : You must specify the name of the package to clear using name=<name of package> argument and a version using version=<type or number of the  version>")
endif()


