####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(kuka-lwr-applications_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(kuka-lwr-applications_FIND_QUIETLY)
		return()#simply exitting
	else(kuka-lwr-applications_FIND_QUIETLY)
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### kuka-lwr-applications find script begins here #####
####################################################
set(kuka-lwr-applications_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(PACKAGE_kuka-lwr-applications_SEARCH_PATH
    ${PACKAGE_BINARY_INSTALL_DIR}/kuka-lwr-applications
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the kuka-lwr-applications package"
  )

check_Directory_Exists(EXIST ${PACKAGE_kuka-lwr-applications_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions

	#variables that will be filled by generic functions
	if(kuka-lwr-applications_FIND_VERSION)
		if(kuka-lwr-applications_FIND_VERSION_EXACT) #using a specific version (only patch number can be adapted, first searching if there is any local version matching constraints, otherwise search for a non local version)
			check_Exact_Version(VERSION_HAS_BEEN_FOUND "kuka-lwr-applications" ${PACKAGE_kuka-lwr-applications_SEARCH_PATH} ${kuka-lwr-applications_FIND_VERSION_MAJOR} ${kuka-lwr-applications_FIND_VERSION_MINOR})
		else() #using the best version as regard of version constraints (only non local version are used)
			check_Best_Version(VERSION_HAS_BEEN_FOUND "kuka-lwr-applications" ${PACKAGE_kuka-lwr-applications_SEARCH_PATH} ${kuka-lwr-applications_FIND_VERSION_MAJOR} ${kuka-lwr-applications_FIND_VERSION_MINOR})
		endif()
	else(kuka-lwr-applications_FIND_VERSION) #no specific version targetted using last available version (takes the last version available either local or non local - local first)
		check_Last_Version(VERSION_HAS_BEEN_FOUND "kuka-lwr-applications" ${PACKAGE_kuka-lwr-applications_SEARCH_PATH})
	endif(kuka-lwr-applications_FIND_VERSION)

	if(VERSION_HAS_BEEN_FOUND)#a good version of the package has been found
		set(PATH_TO_PACKAGE_VERSION ${PACKAGE_kuka-lwr-applications_SEARCH_PATH}/${kuka-lwr-applications_VERSION_RELATIVE_PATH})	
		if(kuka-lwr-applications_FIND_COMPONENTS) #specific components must be checked, taking only selected components	
				
			select_Components(kuka-lwr-applications ${kuka-lwr-applications_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION} "${kuka-lwr-applications_FIND_COMPONENTS}")
			if(USE_FILE_NOTFOUND)
				exitFindScript("The kuka-lwr-applications version selected (${kuka-lwr-applications_VERSION_STRING}) has no configuration file or file is corrupted")
			endif(USE_FILE_NOTFOUND)

			if(NOT ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND)
				exitFindScript("Some of the requested components of the package kuka-lwr-applications are missing (version chosen is ${kuka-lwr-applications_VERSION_STRING}, requested is ${kuka-lwr-applications_FIND_VERSION}),either bad names specified or broken package versionning")
			endif(NOT ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND)	
		
		else(kuka-lwr-applications_FIND_COMPONENTS)#no component check, register all of them
			all_Components("kuka-lwr-applications" ${kuka-lwr-applications_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION})
			if(USE_FILE_NOTFOUND)
				exitFindScript("The kuka-lwr-applications version selected (${kuka-lwr-applications_VERSION_STRING}) has no configuration file or file is corrupted")
			endif(USE_FILE_NOTFOUND)
				
		endif(kuka-lwr-applications_FIND_COMPONENTS)

		#here everything has been found => setting global standard CMake find process variables to adequate values
		set(kuka-lwr-applications_FOUND TRUE CACHE INTERNAL "")
		set(kuka-lwr-applications_ROOT_DIR ${PATH_TO_PACKAGE_VERSION} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_PACKAGES ${${PROJECT_NAME}_ALL_USED_PACKAGES} kuka-lwr-applications CACHE INTERNAL "")
		if(kuka-lwr-applications_FIND_VERSION)
			if(kuka-lwr-applications_FIND_VERSION_EXACT)
				set(kuka-lwr-applications_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(kuka-lwr-applications_REQUIRED_VERSION_EXACT "${kuka-lwr-applications_FIND_VERSION_MAJOR}.${kuka-lwr-applications_FIND_VERSION_MINOR}" CACHE INTERNAL "")
			else()
				set(kuka-lwr-applications_ALL_REQUIRED_VERSIONS ${kuka-lwr-applications_ALL_REQUIRED_VERSIONS} "${kuka-lwr-applications_FIND_VERSION_MAJOR}.${kuka-lwr-applications_FIND_VERSION_MINOR}" CACHE INTERNAL "")	
			endif()
		else()
			set(kuka-lwr-applications_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(kuka-lwr-applications_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
		
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(kuka-lwr-applications_FIND_REQUIRED)
				if(kuka-lwr-applications_FIND_VERSION)
					add_To_Install_Package_Specification(kuka-lwr-applications "${kuka-lwr-applications_FIND_VERSION_MAJOR}.${kuka-lwr-applications_FIND_VERSION_MINOR}" ${kuka-lwr-applications_FIND_VERSION_EXACT})
				else()
					add_To_Install_Package_Specification(kuka-lwr-applications "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package kuka-lwr-applications with version ${kuka-lwr-applications_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_HAS_BEEN_FOUND)
		
else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(kuka-lwr-applications_FIND_REQUIRED)
			if(kuka-lwr-applications_FIND_VERSION)
				add_To_Install_Package_Specification(kuka-lwr-applications "${kuka-lwr-applications_FIND_VERSION_MAJOR}.${kuka-lwr-applications_FIND_VERSION_MINOR}" ${kuka-lwr-applications_FIND_VERSION_EXACT})
			else()
				add_To_Install_Package_Specification(kuka-lwr-applications "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required package kuka-lwr-applications cannot be found in the workspace")
	endif()

endif(EXIST)


