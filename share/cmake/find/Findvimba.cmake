####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(vimba_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(vimba_FIND_QUIETLY)
		return()#simply exitting
	else()
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### vimba find script begins here #####
####################################################

set(vimba_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(EXTERNAL_PACKAGE_vimba_SEARCH_PATH
    ${EXTERNAL_PACKAGE_BINARY_INSTALL_DIR}/vimba
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the vimba external package"
  )

set(vimba_PID_KNOWN_VERSION 1.3.0)
#set(vimba_PID_KNOWN_VERSION_1.3.0_GREATER_VERSIONS_COMPATIBLE_UP_TO 1.50)#the 1.50 is the first version that is not compatible with 1.3 version !!

check_Directory_Exists(EXIST ${EXTERNAL_PACKAGE_vimba_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions
	#variables that will be filled by generic functions
	if(vimba_FIND_VERSION)
		if(vimba_FIND_VERSION_EXACT) #using a specific version
			check_External_Exact_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_vimba_SEARCH_PATH} "${vimba_FIND_VERSION_MAJOR}.${vimba_FIND_VERSION_MINOR}.${vimba_FIND_VERSION_PATCH}")
		else() #using the best version as regard of version constraints
			check_External_Minimum_Version(VERSION_TO_USE vimba ${EXTERNAL_PACKAGE_vimba_SEARCH_PATH} "${vimba_FIND_VERSION_MAJOR}.${vimba_FIND_VERSION_MINOR}.${vimba_FIND_VERSION_PATCH}")
		endif()
	else(vimba_FIND_VERSION) #no specific version targetted using last available version (takes the last version available)
		check_External_Last_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_vimba_SEARCH_PATH})
	endif(vimba_FIND_VERSION)

	if(VERSION_TO_USE)#a good version of the package has been found
		set(vimba_FOUND TRUE CACHE INTERNAL "")
		set(vimba_ROOT_DIR ${EXTERNAL_PACKAGE_vimba_SEARCH_PATH}/${VERSION_TO_USE} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES} vimba CACHE INTERNAL "")
		if(vimba_FIND_VERSION)
			if(vimba_FIND_VERSION_EXACT)
				set(vimba_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(vimba_REQUIRED_VERSION_EXACT "${vimba_FIND_VERSION_MAJOR}.${vimba_FIND_VERSION_MINOR}.${vimba_FIND_VERSION_PATCH}" CACHE INTERNAL "")
			else()
				set(vimba_ALL_REQUIRED_VERSIONS ${vimba_ALL_REQUIRED_VERSIONS} "${vimba_FIND_VERSION_MAJOR}.${vimba_FIND_VERSION_MINOR}.${vimba_FIND_VERSION_PATCH}" CACHE INTERNAL "")	
			endif()
		else()
			set(vimba_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(vimba_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(vimba_FIND_REQUIRED)
				if(vimba_FIND_VERSION)
					add_To_Install_External_Package_Specification(vimba "${vimba_FIND_VERSION_MAJOR}.${vimba_FIND_VERSION_MINOR}.${vimba_FIND_VERSION_PATCH}" ${vimba_FIND_VERSION_EXACT})
				else()
					add_To_Install_External_Package_Specification(vimba "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package vimba with a version compatible with ${vimba_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_TO_USE)

else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(vimba_FIND_REQUIRED)
			if(vimba_FIND_VERSION)
				add_To_Install_External_Package_Specification(vimba "${vimba_FIND_VERSION_MAJOR}.${vimba_FIND_VERSION_MINOR}.${vimba_FIND_VERSION_PATCH}" ${vimba_FIND_VERSION_EXACT})
			else()
				add_To_Install_External_Package_Specification(vimba "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required external package vimba cannot be found in the workspace")
	endif()
endif()

