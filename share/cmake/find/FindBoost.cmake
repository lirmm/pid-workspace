####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(Boost_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(Boost_FIND_QUIETLY)
		return()#simply exitting
	else()
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### Boost find script begins here #####
####################################################

set(Boost_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(EXTERNAL_PACKAGE_Boost_SEARCH_PATH
    ${EXTERNAL_PACKAGE_BINARY_INSTALL_DIR}/Boost
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the Boost external package"
  )

set(Boost_PID_KNOWN_VERSION 1.55.0)
#set(Boost_PID_KNOWN_VERSION_3.2.0_GREATER_VERSIONS_COMPATIBLE_UP_TO 4.5.0)#the 4.5.0 is the first version that is not compatible with 3.2.0 version !!

check_Directory_Exists(EXIST ${EXTERNAL_PACKAGE_Boost_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions
	#variables that will be filled by generic functions
	if(Boost_FIND_VERSION)
		if(Boost_FIND_VERSION_EXACT) #using a specific version
			check_External_Exact_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_Boost_SEARCH_PATH} "${Boost_FIND_VERSION_MAJOR}.${Boost_FIND_VERSION_MINOR}.${Boost_FIND_VERSION_PATCH}")
		else() #using the best version as regard of version constraints
			check_External_Minimum_Version(VERSION_TO_USE Boost ${EXTERNAL_PACKAGE_Boost_SEARCH_PATH} "${Boost_FIND_VERSION_MAJOR}.${Boost_FIND_VERSION_MINOR}.${Boost_FIND_VERSION_PATCH}")
		endif()
	else(Boost_FIND_VERSION) #no specific version targetted using last available version (takes the last version available)
		check_External_Last_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_Boost_SEARCH_PATH})
	endif(Boost_FIND_VERSION)

	if(VERSION_TO_USE)#a good version of the package has been found
		set(Boost_FOUND TRUE CACHE INTERNAL "")
		set(Boost_ROOT_DIR ${EXTERNAL_PACKAGE_Boost_SEARCH_PATH}/${VERSION_TO_USE} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_PACKAGES ${${PROJECT_NAME}_ALL_USED_PACKAGES} Boost CACHE INTERNAL "")
		if(Boost_FIND_VERSION)
			if(Boost_FIND_VERSION_EXACT)
				set(Boost_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(Boost_REQUIRED_VERSION_EXACT "${Boost_FIND_VERSION_MAJOR}.${Boost_FIND_VERSION_MINOR}.${Boost_FIND_VERSION_PATCH}" CACHE INTERNAL "")
			else()
				set(the-testpack-a_ALL_REQUIRED_VERSIONS ${Boost_ALL_REQUIRED_VERSIONS} "${Boost_FIND_VERSION_MAJOR}.${Boost_FIND_VERSION_MINOR}.${Boost_FIND_VERSION_PATCH}" CACHE INTERNAL "")	
			endif()
		else()
			set(Boost_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(Boost_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(Boost_FIND_REQUIRED)
				if(Boost_FIND_VERSION)
					add_To_Install_External_Package_Specification(Boost "${Boost_FIND_VERSION_MAJOR}.${Boost_FIND_VERSION_MINOR}.${Boost_FIND_VERSION_PATCH}" ${Boost_FIND_VERSION_EXACT})
				else()
					add_To_Install_External_Package_Specification(Boost "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package Boost with a version compatible with ${Boost_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_TO_USE)

else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(Boost_FIND_REQUIRED)
			if(Boost_FIND_VERSION)
				add_To_Install_External_Package_Specification(Boost "${Boost_FIND_VERSION_MAJOR}.${Boost_FIND_VERSION_MINOR}.${Boost_FIND_VERSION_PATCH}" ${Boost_FIND_VERSION_EXACT})
			else()
				add_To_Install_External_Package_Specification(Boost "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required external package Boost cannot be found in the workspace")
	endif()
endif()

