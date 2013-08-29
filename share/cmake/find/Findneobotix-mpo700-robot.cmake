####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(${neobotix-mpo700-robot_FIND_REQUIRED})
		message(FATAL_ERROR message_to_send)#fatal error
		return()
	elseif(${neobotix-mpo700-robot_FIND_QUIETLY})
		return()#simply exitting
	else(${neobotix-mpo700-robot_FIND_QUIETLY})
		message(message_to_send)#simple notification message
		return() 
	endif(${neobotix-mpo700-robot_FIND_REQUIRED})
endmacro(exitFindScript message_to_send)

####################################################
####### neobotix-mpo700-robot find script begins here #####
####################################################
set(neobotix-mpo700-robot_FOUND FALSE)

#workspace dir must be defined for each package build
set(PACKAGE_neobotix-mpo700-robot_SEARCH_PATH
    ${PACKAGE_BINARY_INSTALL_DIR}/neobotix-mpo700-robot
    CACHE
    "path to the package install dir containing versions of the neobotix-mpo700-robot package"
  )
mark_as_advanced(PACKAGE_neobotix-mpo700-robot_SEARCH_PATH)
include(Package_Finding_Functions)
check_Directory_Exists(${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH})
if(${RETURN_CHECK_DIRECTORY_EXISTS})
	# at this stage the only thing to do is to check for versions

	#variables that will be filled by generic functions
	set(VERSION_HAS_BEEN_FOUND FALSE)
	if(DEFINED neobotix-mpo700-robot_FIND_VERSION)
		if(${neobotix-mpo700-robot_FIND_VERSION_EXACT}) #using a specific version (only patch number can be adapted)
			check_Exact_Version("neobotix-mpo700-robot" ${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH} ${neobotix-mpo700-robot_FIND_VERSION_MAJOR} ${neobotix-mpo700-robot_FIND_VERSION_MINOR})
		else(${neobotix-mpo700-robot_FIND_VERSION_EXACT}) #using the best version as regard of version constraints
			check_Minor_Version("neobotix-mpo700-robot" ${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH} ${neobotix-mpo700-robot_FIND_VERSION_MAJOR} ${neobotix-mpo700-robot_FIND_VERSION_MINOR})
		endif(${neobotix-mpo700-robot_FIND_VERSION_EXACT})
	else(DEFINED neobotix-mpo700-robot_FIND_VERSION) #no specific version targetted using own or the last available version if it does not exist   
		check_Local_Or_Newest_Version("neobotix-mpo700-robot" ${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH})
	endif(DEFINED neobotix-mpo700-robot_FIND_VERSION)

	if(${VERSION_HAS_BEEN_FOUND})#a good version of the package has been found		
		set(PATH_TO_PACKAGE_VERSION ${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH}/${neobotix-mpo700-robot_VERSION_STRING})		
		if(${neobotix-mpo700-robot_FIND_COMPONENTS}) #specific components must be checked, taking only selected components	
				
			select_Components("neobotix-mpo700-robot" ${neobotix-mpo700-robot_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION} ${neobotix-mpo700-robot_FIND_COMPONENTS})
			if(${USE_FILE_NOTFOUND})
				exitFindScript("The neobotix-mpo700-robot version selected (${neobotix-mpo700-robot_VERSION_STRING}) has no configuration file or file is corrupted")
			endif(${USE_FILE_NOTFOUND})

			if(NOT ${ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND})
				exitFindScript("Some of the requested components of the package neobotix-mpo700-robot are missing (version chosen is ${neobotix-mpo700-robot_VERSION_STRING}, requested is ${neobotix-mpo700-robot_FIND_VERSION})")
			endif(NOT ${ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND})	
		
		else(neobotix-mpo700-robot_FIND_COMPONENTS)#no component check, register all of them
			all_Components("neobotix-mpo700-robot" ${neobotix-mpo700-robot_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION})
			if(${USE_FILE_NOTFOUND})
				exitFindScript("The neobotix-mpo700-robot version selected (${neobotix-mpo700-robot_VERSION_STRING}) has no configuration file or file is corrupted")
			endif(${USE_FILE_NOTFOUND})
				
		endif(neobotix-mpo700-robot_FIND_COMPONENTS)
		#here everything has been found => setting global standard CMake find process variables to adequate values
		set(neobotix-mpo700-robot_FOUND TRUE)
		set(neobotix-mpo700-robot_VERSION_${neobotix-mpo700-robot_VERSION_STRING} TRUE)
		set(neobotix-mpo700-robot_ROOT_DIR ${PATH_TO_PACKAGE_VERSION})
		#now configuring exported variables
		set(PACKAGE_TO_CONFIG "neobotix-mpo700-robot")
		include(Package_Configuration)
	else(${VERSION_HAS_BEEN_FOUND})#no adequate version found
		exitFindScript("The package neobotix-mpo700-robot with version ${neobotix-mpo700-robot_FIND_VERSION} cannot be found")
	endif(${VERSION_HAS_BEEN_FOUND})
		
else(${RETURN_CHECK_DIRECTORY_EXISTS}) #if the directory does not exist it means the package cannot be found
	exitFindScript("The required package neobotix-mpo700-robot cannot be found")
endif(${RETURN_CHECK_DIRECTORY_EXISTS})

####################################################
####### neobotix-mpo700-robot find script ends here #######
####################################################

