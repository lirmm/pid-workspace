####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(libxml2_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(libxml2_FIND_QUIETLY)
		return()#simply exitting
	else()
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### libxml2 find script begins here #####
####################################################

set(libxml2_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(EXTERNAL_PACKAGE_libxml2_SEARCH_PATH
    ${EXTERNAL_PACKAGE_BINARY_INSTALL_DIR}/libxml2
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the libxml2 external package"
  )

set(libxml2_PID_KNOWN_VERSION 2.9.2)

check_Directory_Exists(EXIST ${EXTERNAL_PACKAGE_libxml2_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions
	#variables that will be filled by generic functions
	if(libxml2_FIND_VERSION)
		if(libxml2_FIND_VERSION_EXACT) #using a specific version
			check_External_Exact_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_libxml2_SEARCH_PATH} "${libxml2_FIND_VERSION_MAJOR}.${libxml2_FIND_VERSION_MINOR}.${libxml2_FIND_VERSION_PATCH}")
		else() #using the best version as regard of version constraints
			check_External_Minimum_Version(VERSION_TO_USE libxml2 ${EXTERNAL_PACKAGE_libxml2_SEARCH_PATH} "${libxml2_FIND_VERSION_MAJOR}.${libxml2_FIND_VERSION_MINOR}.${libxml2_FIND_VERSION_PATCH}")
		endif()
	else(libxml2_FIND_VERSION) #no specific version targetted using last available version (takes the last version available)
		check_External_Last_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_libxml2_SEARCH_PATH})
	endif(libxml2_FIND_VERSION)

	if(VERSION_TO_USE)#a good version of the package has been found
		set(libxml2_FOUND TRUE CACHE INTERNAL "")
		set(libxml2_ROOT_DIR ${EXTERNAL_PACKAGE_libxml2_SEARCH_PATH}/${VERSION_TO_USE} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES} libxml2 CACHE INTERNAL "")
		if(libxml2_FIND_VERSION)
			if(libxml2_FIND_VERSION_EXACT)
				set(libxml2_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(libxml2_REQUIRED_VERSION_EXACT "${libxml2_FIND_VERSION_MAJOR}.${libxml2_FIND_VERSION_MINOR}.${libxml2_FIND_VERSION_PATCH}" CACHE INTERNAL "")
			else()
				set(libxml2_ALL_REQUIRED_VERSIONS ${libxml2_ALL_REQUIRED_VERSIONS} "${libxml2_FIND_VERSION_MAJOR}.${libxml2_FIND_VERSION_MINOR}.${libxml2_FIND_VERSION_PATCH}" CACHE INTERNAL "")	
			endif()
		else()
			set(libxml2_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(libxml2_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(libxml2_FIND_REQUIRED)
				if(libxml2_FIND_VERSION)
					add_To_Install_External_Package_Specification(libxml2 "${libxml2_FIND_VERSION_MAJOR}.${libxml2_FIND_VERSION_MINOR}.${libxml2_FIND_VERSION_PATCH}" ${libxml2_FIND_VERSION_EXACT})
				else()
					add_To_Install_External_Package_Specification(libxml2 "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package libxml2 with a version compatible with ${libxml2_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_TO_USE)

else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(libxml2_FIND_REQUIRED)
			if(libxml2_FIND_VERSION)
				add_To_Install_External_Package_Specification(libxml2 "${libxml2_FIND_VERSION_MAJOR}.${libxml2_FIND_VERSION_MINOR}.${libxml2_FIND_VERSION_PATCH}" ${libxml2_FIND_VERSION_EXACT})
			else()
				add_To_Install_External_Package_Specification(libxml2 "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required external package libxml2 cannot be found in the workspace")
	endif()
endif()

