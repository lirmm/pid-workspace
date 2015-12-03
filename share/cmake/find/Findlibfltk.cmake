####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(libfltk_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(libfltk_FIND_QUIETLY)
		return()#simply exitting
	else()
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### libfltk find script begins here #####
####################################################

set(libfltk_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(EXTERNAL_PACKAGE_libfltk_SEARCH_PATH
    ${EXTERNAL_PACKAGE_BINARY_INSTALL_DIR}/libfltk
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the libfltk external package"
  )

set(libfltk_PID_KNOWN_VERSION 1.3.3)

check_Directory_Exists(EXIST ${EXTERNAL_PACKAGE_libfltk_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions
	#variables that will be filled by generic functions
	if(libfltk_FIND_VERSION)
		if(libfltk_FIND_VERSION_EXACT) #using a specific version
			check_External_Exact_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_libfltk_SEARCH_PATH} "${libfltk_FIND_VERSION_MAJOR}.${libfltk_FIND_VERSION_MINOR}.${libfltk_FIND_VERSION_PATCH}")
		else() #using the best version as regard of version constraints
			check_External_Minimum_Version(VERSION_TO_USE libfltk ${EXTERNAL_PACKAGE_libfltk_SEARCH_PATH} "${libfltk_FIND_VERSION_MAJOR}.${libfltk_FIND_VERSION_MINOR}.${libfltk_FIND_VERSION_PATCH}")
		endif()
	else(libfltk_FIND_VERSION) #no specific version targetted using last available version (takes the last version available)
		check_External_Last_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_libfltk_SEARCH_PATH})
	endif(libfltk_FIND_VERSION)

	if(VERSION_TO_USE)#a good version of the package has been found
		set(libfltk_FOUND TRUE CACHE INTERNAL "")
		set(libfltk_ROOT_DIR ${EXTERNAL_PACKAGE_libfltk_SEARCH_PATH}/${VERSION_TO_USE} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES} libfltk CACHE INTERNAL "")
		if(libfltk_FIND_VERSION)
			if(libfltk_FIND_VERSION_EXACT)
				set(libfltk_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(libfltk_REQUIRED_VERSION_EXACT "${libfltk_FIND_VERSION_MAJOR}.${libfltk_FIND_VERSION_MINOR}.${libfltk_FIND_VERSION_PATCH}" CACHE INTERNAL "")
			else()
				set(libfltk_ALL_REQUIRED_VERSIONS ${libfltk_ALL_REQUIRED_VERSIONS} "${libfltk_FIND_VERSION_MAJOR}.${libfltk_FIND_VERSION_MINOR}.${libfltk_FIND_VERSION_PATCH}" CACHE INTERNAL "")	
			endif()
		else()
			set(libfltk_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(libfltk_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(libfltk_FIND_REQUIRED)
				if(libfltk_FIND_VERSION)
					add_To_Install_External_Package_Specification(libfltk "${libfltk_FIND_VERSION_MAJOR}.${libfltk_FIND_VERSION_MINOR}.${libfltk_FIND_VERSION_PATCH}" ${libfltk_FIND_VERSION_EXACT})
				else()
					add_To_Install_External_Package_Specification(libfltk "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package libfltk with a version compatible with ${libfltk_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_TO_USE)

else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(libfltk_FIND_REQUIRED)
			if(libfltk_FIND_VERSION)
				add_To_Install_External_Package_Specification(libfltk "${libfltk_FIND_VERSION_MAJOR}.${libfltk_FIND_VERSION_MINOR}.${libfltk_FIND_VERSION_PATCH}" ${libfltk_FIND_VERSION_EXACT})
			else()
				add_To_Install_External_Package_Specification(libfltk "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required external package libfltk cannot be found in the workspace")
	endif()
endif()

