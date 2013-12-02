list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/references)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/licenses)

include(Workspace_Internal_Functions)

if(REQUIRED_PACKAGE)
	include(Refer${REQUIRED_PACKAGE} OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(REQUIRED_STATUS STREQUAL NOTFOUND)
		message("ERROR : Package name ${REQUIRED_PACKAGE} does not refer to any known package in the workspace")
		return()
	endif()
	if(REQUIRED_VERSION)
		if(	EXISTS ${WORKSPACE_DIR}/install/${REQUIRED_PACKAGE}/${REQUIRED_VERSION}
			AND IS_DIRECTORY ${WORKSPACE_DIR}/install/${REQUIRED_PACKAGE}/${REQUIRED_VERSION})
			message("Error : ${REQUIRED_PACKAGE} binary version ${REQUIRED_VERSION} already resides in the workspace")	
			return()	
		endif()		

		exact_Version_Exists(${REQUIRED_PACKAGE} "${REQUIRED_VERSION}" EXIST)
		if(NOT EXIST)
			message("Error : A binary relocatable archive with version ${REQUIRED_VERSION} does not exist for package ${REQUIRED_PACKAGE}")
			return()
		endif()
	else()
		if(EXISTS ${WORKSPACE_DIR}/packages/${REQUIRED_PACKAGE} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${REQUIRED_PACKAGE})
			message("Error : Source repository for package ${REQUIRED_PACKAGE} already resides in the workspace")	
			return()	
		endif()
	endif()
	deploy_PID_Package(${REQUIRED_PACKAGE} "${REQUIRED_VERSION}")

else()
	message("ERROR : You must specify a package using name=<name of package> argument")
endif()


