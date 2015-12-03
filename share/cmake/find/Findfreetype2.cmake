####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(freetype2_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(freetype2_FIND_QUIETLY)
		return()#simply exitting
	else()
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### freetype2 find script begins here #####
####################################################

set(freetype2_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(EXTERNAL_PACKAGE_freetype2_SEARCH_PATH
    ${EXTERNAL_PACKAGE_BINARY_INSTALL_DIR}/freetype2
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the freetype2 external package"
  )

set(freetype2_PID_KNOWN_VERSION 2.6.1)

check_Directory_Exists(EXIST ${EXTERNAL_PACKAGE_freetype2_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions
	#variables that will be filled by generic functions
	if(freetype2_FIND_VERSION)
		if(freetype2_FIND_VERSION_EXACT) #using a specific version
			check_External_Exact_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_freetype2_SEARCH_PATH} "${freetype2_FIND_VERSION_MAJOR}.${freetype2_FIND_VERSION_MINOR}.${freetype2_FIND_VERSION_PATCH}")
		else() #using the best version as regard of version constraints
			check_External_Minimum_Version(VERSION_TO_USE freetype2 ${EXTERNAL_PACKAGE_freetype2_SEARCH_PATH} "${freetype2_FIND_VERSION_MAJOR}.${freetype2_FIND_VERSION_MINOR}.${freetype2_FIND_VERSION_PATCH}")
		endif()
	else(freetype2_FIND_VERSION) #no specific version targetted using last available version (takes the last version available)
		check_External_Last_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_freetype2_SEARCH_PATH})
	endif(freetype2_FIND_VERSION)

	if(VERSION_TO_USE)#a good version of the package has been found
		set(freetype2_FOUND TRUE CACHE INTERNAL "")
		set(freetype2_ROOT_DIR ${EXTERNAL_PACKAGE_freetype2_SEARCH_PATH}/${VERSION_TO_USE} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES} freetype2 CACHE INTERNAL "")
		if(freetype2_FIND_VERSION)
			if(freetype2_FIND_VERSION_EXACT)
				set(freetype2_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(freetype2_REQUIRED_VERSION_EXACT "${freetype2_FIND_VERSION_MAJOR}.${freetype2_FIND_VERSION_MINOR}.${freetype2_FIND_VERSION_PATCH}" CACHE INTERNAL "")
			else()
				set(freetype2_ALL_REQUIRED_VERSIONS ${freetype2_ALL_REQUIRED_VERSIONS} "${freetype2_FIND_VERSION_MAJOR}.${freetype2_FIND_VERSION_MINOR}.${freetype2_FIND_VERSION_PATCH}" CACHE INTERNAL "")	
			endif()
		else()
			set(freetype2_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(freetype2_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(freetype2_FIND_REQUIRED)
				if(freetype2_FIND_VERSION)
					add_To_Install_External_Package_Specification(freetype2 "${freetype2_FIND_VERSION_MAJOR}.${freetype2_FIND_VERSION_MINOR}.${freetype2_FIND_VERSION_PATCH}" ${freetype2_FIND_VERSION_EXACT})
				else()
					add_To_Install_External_Package_Specification(freetype2 "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package freetype2 with a version compatible with ${freetype2_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_TO_USE)

else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(freetype2_FIND_REQUIRED)
			if(freetype2_FIND_VERSION)
				add_To_Install_External_Package_Specification(freetype2 "${freetype2_FIND_VERSION_MAJOR}.${freetype2_FIND_VERSION_MINOR}.${freetype2_FIND_VERSION_PATCH}" ${freetype2_FIND_VERSION_EXACT})
			else()
				add_To_Install_External_Package_Specification(freetype2 "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required external package freetype2 cannot be found in the workspace")
	endif()
endif()

