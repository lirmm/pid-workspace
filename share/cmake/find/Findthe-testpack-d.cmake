####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(the-testpack-d_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(the-testpack-d_FIND_QUIETLY)
		return()#simply exitting
	else(the-testpack-d_FIND_QUIETLY)
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### the-testpack-d find script begins here #####
####################################################
set(the-testpack-d_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(PACKAGE_the-testpack-d_SEARCH_PATH
    ${PACKAGE_BINARY_INSTALL_DIR}/the-testpack-d
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the the-testpack-d package"
  )

check_Directory_Exists(EXIST ${PACKAGE_the-testpack-d_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions

	#variables that will be filled by generic functions
	if(the-testpack-d_FIND_VERSION)
		if(the-testpack-d_FIND_VERSION_EXACT) #using a specific version (only patch number can be adapted, first searching if there is any local version matching constraints, otherwise search for a non local version)
			check_Exact_Version(VERSION_HAS_BEEN_FOUND "the-testpack-d" ${PACKAGE_the-testpack-d_SEARCH_PATH} ${the-testpack-d_FIND_VERSION_MAJOR} ${the-testpack-d_FIND_VERSION_MINOR})
		else() #using the best version as regard of version constraints (only non local version are used)
			check_Best_Version(VERSION_HAS_BEEN_FOUND "the-testpack-d" ${PACKAGE_the-testpack-d_SEARCH_PATH} ${the-testpack-d_FIND_VERSION_MAJOR} ${the-testpack-d_FIND_VERSION_MINOR})
		endif()
	else(the-testpack-d_FIND_VERSION) #no specific version targetted using last available version (takes the last version available either local or non local - local first)
		check_Last_Version(VERSION_HAS_BEEN_FOUND "the-testpack-d" ${PACKAGE_the-testpack-d_SEARCH_PATH})
	endif(the-testpack-d_FIND_VERSION)

	if(VERSION_HAS_BEEN_FOUND)#a good version of the package has been found
		set(PATH_TO_PACKAGE_VERSION ${PACKAGE_the-testpack-d_SEARCH_PATH}/${the-testpack-d_VERSION_RELATIVE_PATH})	
		if(the-testpack-d_FIND_COMPONENTS) #specific components must be checked, taking only selected components	
				
			select_Components(the-testpack-d ${the-testpack-d_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION} "${the-testpack-d_FIND_COMPONENTS}")
			if(USE_FILE_NOTFOUND)
				exitFindScript("The the-testpack-d version selected (${the-testpack-d_VERSION_STRING}) has no configuration file or file is corrupted")
			endif(USE_FILE_NOTFOUND)

			if(NOT ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND)
				exitFindScript("Some of the requested components of the package the-testpack-d are missing (version chosen is ${the-testpack-d_VERSION_STRING}, requested is ${the-testpack-d_FIND_VERSION}),either bad names specified or broken package versionning")
			endif(NOT ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND)	
		
		else(the-testpack-d_FIND_COMPONENTS)#no component check, register all of them
			all_Components("the-testpack-d" ${the-testpack-d_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION})
			if(USE_FILE_NOTFOUND)
				exitFindScript("The the-testpack-d version selected (${the-testpack-d_VERSION_STRING}) has no configuration file or file is corrupted")
			endif(USE_FILE_NOTFOUND)
				
		endif(the-testpack-d_FIND_COMPONENTS)

		#here everything has been found => setting global standard CMake find process variables to adequate values
		set(the-testpack-d_FOUND TRUE CACHE INTERNAL "")
		set(the-testpack-d_ROOT_DIR ${PATH_TO_PACKAGE_VERSION} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_PACKAGES ${${PROJECT_NAME}_ALL_USED_PACKAGES} the-testpack-d CACHE INTERNAL "")
		if(the-testpack-d_FIND_VERSION)
			if(the-testpack-d_FIND_VERSION_EXACT)
				set(the-testpack-d_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(the-testpack-d_REQUIRED_VERSION_EXACT "${the-testpack-d_FIND_VERSION_MAJOR}.${the-testpack-d_FIND_VERSION_MINOR}" CACHE INTERNAL "")
			else()
				set(the-testpack-d_ALL_REQUIRED_VERSIONS ${the-testpack-d_ALL_REQUIRED_VERSIONS} "${the-testpack-d_FIND_VERSION_MAJOR}.${the-testpack-d_FIND_VERSION_MINOR}" CACHE INTERNAL "")	
			endif()
		else()
			set(the-testpack-d_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(the-testpack-d_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
		
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(the-testpack-d_FIND_REQUIRED)		
				set(${PROJECT_NAME}_TOINSTALL_PACKAGES ${${PROJECT_NAME}_TOINSTALL_PACKAGES} the-testpack-d CACHE INTERNAL "")
				set(${PROJECT_NAME}_TOINSTALL_PACKAGE_the-testpack-d_VERSION "${the-testpack-d_FIND_VERSION_MAJOR}.${the-testpack-d_FIND_VERSION_MINOR}" CACHE INTERNAL "")
				set(${PROJECT_NAME}_TOINSTALL_PACKAGE_the-testpack-d_VERSION_EXACT ${the-testpack-d_FIND_VERSION_EXACT} CACHE INTERNAL "")
			endif()
		else()
			exitFindScript("The package the-testpack-d with version ${the-testpack-d_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_HAS_BEEN_FOUND)
		
else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(the-testpack-d_FIND_REQUIRED)	
			set(${PROJECT_NAME}_TOINSTALL_PACKAGES ${${PROJECT_NAME}_TOINSTALL_PACKAGES} the-testpack-d CACHE INTERNAL "")
		endif()
	else()
		exitFindScript("The required package the-testpack-d cannot be found in the workspace")
	endif()

endif(EXIST)


