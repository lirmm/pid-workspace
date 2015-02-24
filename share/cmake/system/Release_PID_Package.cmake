
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
include(Workspace_Internal_Functions NO_POLICY_SCOPE)

if(TARGET_PACKAGE AND EXISTS ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${TARGET_PACKAGE})
	if(NEXT_VERSION AND 
	("${NEXT_VERSION}" STREQUAL "MAJOR" OR "${NEXT_VERSION}" STREQUAL "MINOR" OR "${NEXT_VERSION}" STREQUAL "PATCH"))
		release_PID_Package(${TARGET_PACKAGE} ${NEXT_VERSION})
	else()
		message(SEND_ERROR "You must specify which kind of next version you will generate: MAJOR or MINOR or PATCH")
	endif()
else()
	message(SEND_ERROR "You must specify the name of the package to remove using name=<name of package> argument")
endif()

