####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(eigen_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(eigen_FIND_QUIETLY)
		return()#simply exitting
	else()
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### eigen find script begins here #####
####################################################

set(eigen_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(EXTERNAL_PACKAGE_eigen_SEARCH_PATH
    ${EXTERNAL_PACKAGE_BINARY_INSTALL_DIR}/eigen
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the eigen external package"
  )

set(eigen_PID_KNOWN_VERSION 3.2.0)
#set(eigen_PID_KNOWN_VERSION_3.2.0_GREATER_VERSIONS_COMPATIBLE_UP_TO 4.5.0)#the 4.5.0 is the first version that is not compatible with 3.2.0 version !!

check_Directory_Exists(EXIST ${EXTERNAL_PACKAGE_eigen_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions
	#variables that will be filled by generic functions
	if(eigen_FIND_VERSION)
		if(eigen_FIND_VERSION_EXACT) #using a specific version
			check_External_Exact_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_eigen_SEARCH_PATH} "${eigen_FIND_VERSION_MAJOR}.${eigen_FIND_VERSION_MINOR}.${eigen_FIND_VERSION_PATCH}")
		else() #using the best version as regard of version constraints
			check_External_Minimum_Version(VERSION_TO_USE eigen ${EXTERNAL_PACKAGE_eigen_SEARCH_PATH} "${eigen_FIND_VERSION_MAJOR}.${eigen_FIND_VERSION_MINOR}.${eigen_FIND_VERSION_PATCH}")
		endif()
	else(eigen_FIND_VERSION) #no specific version targetted using last available version (takes the last version available)
		check_External_Last_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_eigen_SEARCH_PATH})
	endif(eigen_FIND_VERSION)

	if(VERSION_TO_USE)#a good version of the package has been found
		set(eigen_FOUND TRUE CACHE INTERNAL "")
		set(eigen_ROOT_DIR ${EXTERNAL_PACKAGE_eigen_SEARCH_PATH}/${VERSION_TO_USE} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_PACKAGES ${${PROJECT_NAME}_ALL_USED_PACKAGES} eigen CACHE INTERNAL "")
		if(eigen_FIND_VERSION)
			if(eigen_FIND_VERSION_EXACT)
				set(eigen_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(eigen_REQUIRED_VERSION_EXACT "${eigen_FIND_VERSION_MAJOR}.${eigen_FIND_VERSION_MINOR}.${eigen_FIND_VERSION_PATCH}" CACHE INTERNAL "")
			else()
				set(the-testpack-a_ALL_REQUIRED_VERSIONS ${eigen_ALL_REQUIRED_VERSIONS} "${eigen_FIND_VERSION_MAJOR}.${eigen_FIND_VERSION_MINOR}.${eigen_FIND_VERSION_PATCH}" CACHE INTERNAL "")	
			endif()
		else()
			set(eigen_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(eigen_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(eigen_FIND_REQUIRED)
				if(eigen_FIND_VERSION)
					add_To_Install_External_Package_Specification(eigen "${eigen_FIND_VERSION_MAJOR}.${eigen_FIND_VERSION_MINOR}.${eigen_FIND_VERSION_PATCH}" ${eigen_FIND_VERSION_EXACT})
				else()
					add_To_Install_External_Package_Specification(eigen "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package eigen with a version compatible with ${eigen_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_TO_USE)

else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(eigen_FIND_REQUIRED)
			if(eigen_FIND_VERSION)
				add_To_Install_External_Package_Specification(eigen "${eigen_FIND_VERSION_MAJOR}.${eigen_FIND_VERSION_MINOR}.${eigen_FIND_VERSION_PATCH}" ${eigen_FIND_VERSION_EXACT})
			else()
				add_To_Install_External_Package_Specification(eigen "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required external package eigen cannot be found in the workspace")
	endif()
endif()

