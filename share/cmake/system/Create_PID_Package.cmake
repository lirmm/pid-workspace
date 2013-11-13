include(../share/cmake/system/Workspace_Internal_Functions.cmake)

if(REQUIRED_PACKAGE)
	include(../share/cmake/references/Refer${REQUIRED_PACKAGE}.cmake OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
	if(NOT REQUIRED_STATUS STREQUAL NOTFOUND)
		message("ERROR : A package with the same name ${REQUIRED_PACKAGE} is already referenced in the workspace")
		return()
	endif()
	if(EXISTS ../packages/${REQUIRED_PACKAGE} AND IS_DIRECTORY ../packages/${REQUIRED_PACKAGE})
		message("ERROR : A package with the same name ${REQUIRED_PACKAGE} is already present in the workspace")
		return()
	endif()
	if(OPTIONAL_LICENSE)
		include(../share/cmake/licenses/License${OPTIONAL_LICENSE}.cmake OPTIONAL RESULT_VARIABLE REQUIRED_STATUS)
		if(REQUIRED_STATUS STREQUAL NOTFOUND)
			message("ERROR : License name ${REQUIRED_LICENSE} does not refer to any known license in the workspace")
			return()
		endif()
	endif()
	create_PID_Package(	${REQUIRED_PACKAGE} 
				"${OPTIONAL_AUTHOR}" 
				"${OPTIONAL_INSTITUTION}"
				"${OPTIONAL_LICENSE}")
else()
	message("ERROR : You must specify a name for the package to create using name=<name of package> argument")
endif()



