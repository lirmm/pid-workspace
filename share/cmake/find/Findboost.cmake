####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(boost_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(boost_FIND_QUIETLY)
		return()#simply exitting
	else()
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### boost find script begins here #####
####################################################

set(boost_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(EXTERNAL_PACKAGE_boost_SEARCH_PATH
    ${EXTERNAL_PACKAGE_BINARY_INSTALL_DIR}/boost
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the boost external package"
  )

set(boost_PID_KNOWN_VERSION 1.55.0)
#set(boost_PID_KNOWN_VERSION_1.55.0_GREATER_VERSIONS_COMPATIBLE_UP_TO 4.5.0)#the 4.5.0 is the first version that is not compatible with 3.2.0 version !!

check_Directory_Exists(EXIST ${EXTERNAL_PACKAGE_boost_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions
	#variables that will be filled by generic functions
	if(boost_FIND_VERSION)
		if(boost_FIND_VERSION_EXACT) #using a specific version
			check_External_Exact_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_boost_SEARCH_PATH} "${boost_FIND_VERSION_MAJOR}.${boost_FIND_VERSION_MINOR}.${boost_FIND_VERSION_PATCH}")
		else() #using the best version as regard of version constraints
			check_External_Minimum_Version(VERSION_TO_USE boost ${EXTERNAL_PACKAGE_boost_SEARCH_PATH} "${boost_FIND_VERSION_MAJOR}.${boost_FIND_VERSION_MINOR}.${boost_FIND_VERSION_PATCH}")
		endif()
	else(boost_FIND_VERSION) #no specific version targetted using last available version (takes the last version available)
		check_External_Last_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_boost_SEARCH_PATH})
	endif(boost_FIND_VERSION)

	if(VERSION_TO_USE)#a good version of the package has been found
		set(boost_FOUND TRUE CACHE INTERNAL "")
		set(boost_ROOT_DIR ${EXTERNAL_PACKAGE_boost_SEARCH_PATH}/${VERSION_TO_USE} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_PACKAGES ${${PROJECT_NAME}_ALL_USED_PACKAGES} boost CACHE INTERNAL "")
		if(boost_FIND_VERSION)
			if(boost_FIND_VERSION_EXACT)
				set(boost_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(boost_REQUIRED_VERSION_EXACT "${boost_FIND_VERSION_MAJOR}.${boost_FIND_VERSION_MINOR}.${boost_FIND_VERSION_PATCH}" CACHE INTERNAL "")
			else()
				set(the-testpack-a_ALL_REQUIRED_VERSIONS ${boost_ALL_REQUIRED_VERSIONS} "${boost_FIND_VERSION_MAJOR}.${boost_FIND_VERSION_MINOR}.${boost_FIND_VERSION_PATCH}" CACHE INTERNAL "")	
			endif()
		else()
			set(boost_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(boost_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(boost_FIND_REQUIRED)
				if(boost_FIND_VERSION)
					add_To_Install_External_Package_Specification(boost "${boost_FIND_VERSION_MAJOR}.${boost_FIND_VERSION_MINOR}.${boost_FIND_VERSION_PATCH}" ${boost_FIND_VERSION_EXACT})
				else()
					add_To_Install_External_Package_Specification(boost "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package boost with a version compatible with ${boost_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_TO_USE)

else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(boost_FIND_REQUIRED)
			if(boost_FIND_VERSION)
				add_To_Install_External_Package_Specification(boost "${boost_FIND_VERSION_MAJOR}.${boost_FIND_VERSION_MINOR}.${boost_FIND_VERSION_PATCH}" ${boost_FIND_VERSION_EXACT})
			else()
				add_To_Install_External_Package_Specification(boost "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required external package boost cannot be found in the workspace")
	endif()
endif()

