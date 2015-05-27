list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)

include(Workspace_Internal_Functions NO_POLICY_SCOPE)

if(REQUIRED_PACKAGE)
	include(${WORKSPACE_DIR}/share/cmake/references/Refer${REQUIRED_PACKAGE}.cmake OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(NOT REQUIRED_STATUS STREQUAL NOTFOUND)
		message("ERROR : A package with the same name ${REQUIRED_PACKAGE} is already referenced in the workspace")
		return()
	endif()
	if(EXISTS ${WORKSPACE_DIR}/packages/${REQUIRED_PACKAGE} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${REQUIRED_PACKAGE})
		message("ERROR : A package with the same name ${REQUIRED_PACKAGE} is already present in the workspace")
		return()
	endif()
	if(OPTIONAL_LICENSE)
		include(${WORKSPACE_DIR}/share/cmake/licenses/License${OPTIONAL_LICENSE}.cmake OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
		if(REQUIRED_STATUS STREQUAL NOTFOUND)
			message("ERROR : License ${REQUIRED_LICENSE} does not refer to any known license in the workspace")
			return()
		endif()
	endif()
	create_PID_Package(	${REQUIRED_PACKAGE} 
				"${OPTIONAL_AUTHOR}" 
				"${OPTIONAL_INSTITUTION}"
				"${OPTIONAL_LICENSE}")
	if(OPTIONNAL_GIT_URL)
		get_Repository_Name(RES_NAME ${OPTIONNAL_GIT_URL})
		if(NOT "${RES_NAME}" STREQUAL "${REQUIRED_PACKAGE}")
			message("ERROR : the git url of the repository (${REQUIRED_GIT_URL}) does not define a repository with same name than package ${REQUIRED_PACKAGE}")
			return()
		endif()
		connect_PID_Package(	${REQUIRED_PACKAGE} 
					${OPTIONNAL_GIT_URL})
	endif()

	

else()
	message("ERROR : You must specify a name for the package to create using name=<name of package> argument")
endif()



