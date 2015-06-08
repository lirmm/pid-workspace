

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
include(Workspace_Internal_Functions NO_POLICY_SCOPE)

if(TARGET_REMOTE_REPOSITORY)
	upgrade_Workspace(${TARGET_REMOTE_REPOSITORY})
else()
	#by default using origin
	upgrade_Workspace(origin)
endif()

