####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(reflexxes_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(reflexxes_FIND_QUIETLY)
		return()#simply exitting
	else()
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### reflexxes find script begins here #####
####################################################

set(reflexxes_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(EXTERNAL_PACKAGE_reflexxes_SEARCH_PATH
    ${EXTERNAL_PACKAGE_BINARY_INSTALL_DIR}/reflexxes
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the reflexxes external package"
  )

set(reflexxes_PID_KNOWN_VERSION 1.0.0)
#set(reflexxes_PID_KNOWN_VERSION_1.55.0_GREATER_VERSIONS_COMPATIBLE_UP_TO 1.90)#the 1.90 is the first version that is not compatible with 1.55 version !!

check_Directory_Exists(EXIST ${EXTERNAL_PACKAGE_reflexxes_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions
	#variables that will be filled by generic functions
	if(reflexxes_FIND_VERSION)
		if(reflexxes_FIND_VERSION_EXACT) #using a specific version
			check_External_Exact_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_reflexxes_SEARCH_PATH} "${reflexxes_FIND_VERSION_MAJOR}.${reflexxes_FIND_VERSION_MINOR}.${reflexxes_FIND_VERSION_PATCH}")
		else() #using the best version as regard of version constraints
			check_External_Minimum_Version(VERSION_TO_USE reflexxes ${EXTERNAL_PACKAGE_reflexxes_SEARCH_PATH} "${reflexxes_FIND_VERSION_MAJOR}.${reflexxes_FIND_VERSION_MINOR}.${reflexxes_FIND_VERSION_PATCH}")
		endif()
	else(reflexxes_FIND_VERSION) #no specific version targetted using last available version (takes the last version available)
		check_External_Last_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_reflexxes_SEARCH_PATH})
	endif(reflexxes_FIND_VERSION)

	if(VERSION_TO_USE)#a good version of the package has been found
		set(reflexxes_FOUND TRUE CACHE INTERNAL "")
		set(reflexxes_ROOT_DIR ${EXTERNAL_PACKAGE_reflexxes_SEARCH_PATH}/${VERSION_TO_USE} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES} reflexxes CACHE INTERNAL "")
		if(reflexxes_FIND_VERSION)
			if(reflexxes_FIND_VERSION_EXACT)
				set(reflexxes_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(reflexxes_REQUIRED_VERSION_EXACT "${reflexxes_FIND_VERSION_MAJOR}.${reflexxes_FIND_VERSION_MINOR}.${reflexxes_FIND_VERSION_PATCH}" CACHE INTERNAL "")
			else()
				set(reflexxes_ALL_REQUIRED_VERSIONS ${reflexxes_ALL_REQUIRED_VERSIONS} "${reflexxes_FIND_VERSION_MAJOR}.${reflexxes_FIND_VERSION_MINOR}.${reflexxes_FIND_VERSION_PATCH}" CACHE INTERNAL "")	
			endif()
		else()
			set(reflexxes_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(reflexxes_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(reflexxes_FIND_REQUIRED)
				if(reflexxes_FIND_VERSION)
					add_To_Install_External_Package_Specification(reflexxes "${reflexxes_FIND_VERSION_MAJOR}.${reflexxes_FIND_VERSION_MINOR}.${reflexxes_FIND_VERSION_PATCH}" ${reflexxes_FIND_VERSION_EXACT})
				else()
					add_To_Install_External_Package_Specification(reflexxes "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package reflexxes with a version compatible with ${reflexxes_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_TO_USE)

else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(reflexxes_FIND_REQUIRED)
			if(reflexxes_FIND_VERSION)
				add_To_Install_External_Package_Specification(reflexxes "${reflexxes_FIND_VERSION_MAJOR}.${reflexxes_FIND_VERSION_MINOR}.${reflexxes_FIND_VERSION_PATCH}" ${reflexxes_FIND_VERSION_EXACT})
			else()
				add_To_Install_External_Package_Specification(reflexxes "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required external package reflexxes cannot be found in the workspace")
	endif()
endif()

