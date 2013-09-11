####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(neobotix-mpo700-robot_FIND_REQUIRED)
		message(SEND_ERROR message_to_send)#fatal error
		return()
	elseif(neobotix-mpo700-robot_FIND_QUIETLY)
		return()#simply exitting
	else(neobotix-mpo700-robot_FIND_QUIETLY)
		message(STATUS message_to_send)#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### neobotix-mpo700-robot find script begins here #####
####################################################
set(neobotix-mpo700-robot_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(PACKAGE_neobotix-mpo700-robot_SEARCH_PATH
    ${PACKAGE_BINARY_INSTALL_DIR}/neobotix-mpo700-robot
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the neobotix-mpo700-robot package"
  )

check_Directory_Exists(EXIST ${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions

	#variables that will be filled by generic functions
	if(neobotix-mpo700-robot_FIND_VERSION)
		if(neobotix-mpo700-robot_FIND_VERSION_EXACT) #using a specific version (only patch number can be adapted, first searching if there is any local version matching constraints, otherwise search for a non local version)
			check_Exact_Version(VERSION_HAS_BEEN_FOUND "neobotix-mpo700-robot" ${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH} ${neobotix-mpo700-robot_FIND_VERSION_MAJOR} ${neobotix-mpo700-robot_FIND_VERSION_MINOR})
		else() #using the best version as regard of version constraints (only non local version are used)
			check_Best_Version(VERSION_HAS_BEEN_FOUND "neobotix-mpo700-robot" ${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH} ${neobotix-mpo700-robot_FIND_VERSION_MAJOR} ${neobotix-mpo700-robot_FIND_VERSION_MINOR})
		endif()
	else(neobotix-mpo700-robot_FIND_VERSION) #no specific version targetted using last available version (takes the last version available either local or non local - local first)
		check_Last_Version(VERSION_HAS_BEEN_FOUND "neobotix-mpo700-robot" ${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH})
	endif(neobotix-mpo700-robot_FIND_VERSION)

	if(VERSION_HAS_BEEN_FOUND)#a good version of the package has been found
		set(PATH_TO_PACKAGE_VERSION ${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH}/${neobotix-mpo700-robot_VERSION_RELATIVE_PATH})		
		if(neobotix-mpo700-robot_FIND_COMPONENTS) #specific components must be checked, taking only selected components	
				
			select_Components(neobotix-mpo700-robot ${neobotix-mpo700-robot_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION} ${neobotix-mpo700-robot_FIND_COMPONENTS})
			if(USE_FILE_NOTFOUND)
				exitFindScript("The neobotix-mpo700-robot version selected (${neobotix-mpo700-robot_VERSION_STRING}) has no configuration file or file is corrupted")
			endif(USE_FILE_NOTFOUND)

			if(NOT ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND)
				exitFindScript("Some of the requested components of the package neobotix-mpo700-robot are missing (version chosen is ${neobotix-mpo700-robot_VERSION_STRING}, requested is ${neobotix-mpo700-robot_FIND_VERSION}),either bad names specified or broken package versionning")
			endif(NOT ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND)	
		
		else(neobotix-mpo700-robot_FIND_COMPONENTS)#no component check, register all of them
			all_Components("neobotix-mpo700-robot" ${neobotix-mpo700-robot_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION})
			if(USE_FILE_NOTFOUND)
				exitFindScript("The neobotix-mpo700-robot version selected (${neobotix-mpo700-robot_VERSION_STRING}) has no configuration file or file is corrupted")
			endif(USE_FILE_NOTFOUND)
				
		endif(neobotix-mpo700-robot_FIND_COMPONENTS)

		#here everything has been found => setting global standard CMake find process variables to adequate values
		set(neobotix-mpo700-robot_FOUND TRUE CACHE INTERNAL "")
		set(neobotix-mpo700-robot_ROOT_DIR ${PATH_TO_PACKAGE_VERSION} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_PACKAGES ${${PROJECT_NAME}_ALL_USED_PACKAGES} neobotix-mpo700-robot CACHE INTERNAL "")
		if(neobotix-mpo700-robot_FIND_VERSION)
			if(neobotix-mpo700-robot_FIND_VERSION_EXACT)
				set(neobotix-mpo700-robot_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(neobotix-mpo700-robot_REQUIRED_VERSION_EXACT "${neobotix-mpo700-robot_FIND_VERSION_MAJOR}.${neobotix-mpo700-robot_FIND_VERSION_MINOR}" CACHE INTERNAL "")
			else()
				set(neobotix-mpo700-robot_ALL_REQUIRED_VERSIONS ${neobotix-mpo700-robot_ALL_REQUIRED_VERSIONS} "${neobotix-mpo700-robot_FIND_VERSION_MAJOR}.${neobotix-mpo700-robot_FIND_VERSION_MINOR}" CACHE INTERNAL "")	
			endif()
		else()
			set(neobotix-mpo700-robot_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(neobotix-mpo700-robot_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
		
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(neobotix-mpo700-robot_FIND_REQUIRED)		
				set(${PROJECT_NAME}_TOINSTALL_PACKAGES ${${PROJECT_NAME}_TOINSTALL_PACKAGES} neobotix-mpo700-robot CACHE INTERNAL "")
				set(${PROJECT_NAME}_TOINSTALL_PACKAGE_neobotix-mpo700-robot_VERSION "${neobotix-mpo700-robot_FIND_VERSION_MAJOR}.${neobotix-mpo700-robot_FIND_VERSION_MINOR}" CACHE INTERNAL "")
				set(${PROJECT_NAME}_TOINSTALL_PACKAGE_neobotix-mpo700-robot_VERSION_EXACT ${neobotix-mpo700-robot_FIND_VERSION_EXACT} CACHE INTERNAL "")
			endif()
		else()
			exitFindScript("The package neobotix-mpo700-robot with version ${neobotix-mpo700-robot_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_HAS_BEEN_FOUND)
		
else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(neobotix-mpo700-robot_FIND_REQUIRED)	
			set(${PROJECT_NAME}_TOINSTALL_PACKAGES ${${PROJECT_NAME}_TOINSTALL_PACKAGES} neobotix-mpo700-robot CACHE INTERNAL "")
		endif()
	else()
		exitFindScript("The required package neobotix-mpo700-robot cannot be found in the workspace")
	endif()

endif(EXIST)


