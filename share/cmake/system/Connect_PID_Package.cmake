list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)

include(Workspace_Internal_Functions NO_POLICY_SCOPE)

if(REQUIRED_PACKAGE)
	if(NOT EXISTS ${WORKSPACE_DIR}/packages/${REQUIRED_PACKAGE} OR NOT IS_DIRECTORY ${WORKSPACE_DIR}/packages/${REQUIRED_PACKAGE})
		message("ERROR : Package ${REQUIRED_PACKAGE} to connect is not contained in the workspace")
		return()
	endif()
	if(NOT REQUIRED_GIT_URL)
		message("ERROR : you must enter a git url using url=<git url> argument")
		return()
	endif()
	set(ALREADY_CONNECTED FALSE)
	is_Package_Connected(CONNECTED ${REQUIRED_PACKAGE})
	if(CONNECTED)
		message("ERROR : package ${REQUIRED_PACKAGE} is already connected to a git repository.")
		return()
	endif()
	get_Repository_Name(RES_NAME ${REQUIRED_GIT_URL})	
	if(NOT "${RES_NAME}" STREQUAL "${REQUIRED_PACKAGE}")
		message("ERROR : the git url of the repository (${REQUIRED_GIT_URL}) does not define a repository with same name than package ${REQUIRED_PACKAGE}")
		return()
	endif()
	connect_PID_Package(	${REQUIRED_PACKAGE} 
				${REQUIRED_GIT_URL})
else()
	message("ERROR : You must specify the name of the package to connect to a git repository using name=<name of package> argument")
endif()



