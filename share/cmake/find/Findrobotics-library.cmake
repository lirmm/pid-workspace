####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(robotics-library_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(robotics-library_FIND_QUIETLY)
		return()#simply exitting
	else(robotics-library_FIND_QUIETLY)
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### robotics-library find script begins here #####
####################################################
set(robotics-library_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(PACKAGE_robotics-library_SEARCH_PATH
    ${PACKAGE_BINARY_INSTALL_DIR}/robotics-library
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the robotics-library package"
  )

check_Directory_Exists(EXIST ${PACKAGE_robotics-library_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions

	#variables that will be filled by generic functions
	if(robotics-library_FIND_VERSION)
		if(robotics-library_FIND_VERSION_EXACT) #using a specific version (only patch number can be adapted, first searching if there is any local version matching constraints, otherwise search for a non local version)
			check_Exact_Version(VERSION_HAS_BEEN_FOUND "robotics-library" ${PACKAGE_robotics-library_SEARCH_PATH} ${robotics-library_FIND_VERSION_MAJOR} ${robotics-library_FIND_VERSION_MINOR})
		else() #using the best version as regard of version constraints (only non local version are used)
			check_Best_Version(VERSION_HAS_BEEN_FOUND "robotics-library" ${PACKAGE_robotics-library_SEARCH_PATH} ${robotics-library_FIND_VERSION_MAJOR} ${robotics-library_FIND_VERSION_MINOR})
		endif()
	else(robotics-library_FIND_VERSION) #no specific version targetted using last available version (takes the last version available either local or non local - local first)
		check_Last_Version(VERSION_HAS_BEEN_FOUND "robotics-library" ${PACKAGE_robotics-library_SEARCH_PATH})
	endif(robotics-library_FIND_VERSION)

	if(VERSION_HAS_BEEN_FOUND)#a good version of the package has been found
		set(PATH_TO_PACKAGE_VERSION ${PACKAGE_robotics-library_SEARCH_PATH}/${robotics-library_VERSION_RELATIVE_PATH})	
		if(robotics-library_FIND_COMPONENTS) #specific components must be checked, taking only selected components	
				
			select_Components(robotics-library ${robotics-library_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION} "${robotics-library_FIND_COMPONENTS}")
			if(USE_FILE_NOTFOUND)
				exitFindScript("The robotics-library version selected (${robotics-library_VERSION_STRING}) has no configuration file or file is corrupted")
			endif(USE_FILE_NOTFOUND)

			if(NOT ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND)
				exitFindScript("Some of the requested components of the package robotics-library are missing (version chosen is ${robotics-library_VERSION_STRING}, requested is ${robotics-library_FIND_VERSION}),either bad names specified or broken package versionning")
			endif(NOT ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND)	
		
		else(robotics-library_FIND_COMPONENTS)#no component check, register all of them
			all_Components("robotics-library" ${robotics-library_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION})
			if(USE_FILE_NOTFOUND)
				exitFindScript("The robotics-library version selected (${robotics-library_VERSION_STRING}) has no configuration file or file is corrupted")
			endif(USE_FILE_NOTFOUND)
				
		endif(robotics-library_FIND_COMPONENTS)

		#here everything has been found => setting global standard CMake find process variables to adequate values
		set(robotics-library_FOUND TRUE CACHE INTERNAL "")
		set(robotics-library_ROOT_DIR ${PATH_TO_PACKAGE_VERSION} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_PACKAGES ${${PROJECT_NAME}_ALL_USED_PACKAGES} robotics-library CACHE INTERNAL "")
		if(robotics-library_FIND_VERSION)
			if(robotics-library_FIND_VERSION_EXACT)
				set(robotics-library_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(robotics-library_REQUIRED_VERSION_EXACT "${robotics-library_FIND_VERSION_MAJOR}.${robotics-library_FIND_VERSION_MINOR}" CACHE INTERNAL "")
			else()
				set(robotics-library_ALL_REQUIRED_VERSIONS ${robotics-library_ALL_REQUIRED_VERSIONS} "${robotics-library_FIND_VERSION_MAJOR}.${robotics-library_FIND_VERSION_MINOR}" CACHE INTERNAL "")	
			endif()
		else()
			set(robotics-library_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(robotics-library_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
		
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(robotics-library_FIND_REQUIRED)
				if(robotics-library_FIND_VERSION)
					add_To_Install_Package_Specification(robotics-library "${robotics-library_FIND_VERSION_MAJOR}.${robotics-library_FIND_VERSION_MINOR}" ${robotics-library_FIND_VERSION_EXACT})
				else()
					add_To_Install_Package_Specification(robotics-library "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package robotics-library with version ${robotics-library_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_HAS_BEEN_FOUND)
		
else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(robotics-library_FIND_REQUIRED)
			if(robotics-library_FIND_VERSION)
				add_To_Install_Package_Specification(robotics-library "${robotics-library_FIND_VERSION_MAJOR}.${robotics-library_FIND_VERSION_MINOR}" ${robotics-library_FIND_VERSION_EXACT})
			else()
				add_To_Install_Package_Specification(robotics-library "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required package robotics-library cannot be found in the workspace")
	endif()

endif(EXIST)


