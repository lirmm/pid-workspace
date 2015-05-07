####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(qtlibs_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(qtlibs_FIND_QUIETLY)
		return()#simply exitting
	else()
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### qtlibs find script begins here #####
####################################################

set(qtlibs_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(EXTERNAL_PACKAGE_qtlibs_SEARCH_PATH
    ${EXTERNAL_PACKAGE_BINARY_INSTALL_DIR}/qtlibs
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the qtlibs external package"
  )

set(qtlibs_PID_KNOWN_VERSION 5.2.1)

check_Directory_Exists(EXIST ${EXTERNAL_PACKAGE_qtlibs_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions
	#variables that will be filled by generic functions
	if(qtlibs_FIND_VERSION)
		if(qtlibs_FIND_VERSION_EXACT) #using a specific version
			check_External_Exact_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_qtlibs_SEARCH_PATH} "${qtlibs_FIND_VERSION_MAJOR}.${qtlibs_FIND_VERSION_MINOR}.${qtlibs_FIND_VERSION_PATCH}")
		else() #using the best version as regard of version constraints
			check_External_Minimum_Version(VERSION_TO_USE qtlibs ${EXTERNAL_PACKAGE_qtlibs_SEARCH_PATH} "${qtlibs_FIND_VERSION_MAJOR}.${qtlibs_FIND_VERSION_MINOR}.${qtlibs_FIND_VERSION_PATCH}")
		endif()
	else(qtlibs_FIND_VERSION) #no specific version targetted using last available version (takes the last version available)
		check_External_Last_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_qtlibs_SEARCH_PATH})
	endif(qtlibs_FIND_VERSION)

	if(VERSION_TO_USE)#a good version of the package has been found
		set(qtlibs_FOUND TRUE CACHE INTERNAL "")
		set(qtlibs_ROOT_DIR ${EXTERNAL_PACKAGE_qtlibs_SEARCH_PATH}/${VERSION_TO_USE} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES} qtlibs CACHE INTERNAL "")
		if(qtlibs_FIND_VERSION)
			if(qtlibs_FIND_VERSION_EXACT)
				set(qtlibs_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(qtlibs_REQUIRED_VERSION_EXACT "${qtlibs_FIND_VERSION_MAJOR}.${qtlibs_FIND_VERSION_MINOR}.${qtlibs_FIND_VERSION_PATCH}" CACHE INTERNAL "")
			else()
				set(qtlibs_ALL_REQUIRED_VERSIONS ${qtlibs_ALL_REQUIRED_VERSIONS} "${qtlibs_FIND_VERSION_MAJOR}.${qtlibs_FIND_VERSION_MINOR}.${qtlibs_FIND_VERSION_PATCH}" CACHE INTERNAL "")	
			endif()
		else()
			set(qtlibs_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(qtlibs_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(qtlibs_FIND_REQUIRED)
				if(qtlibs_FIND_VERSION)
					add_To_Install_External_Package_Specification(qtlibs "${qtlibs_FIND_VERSION_MAJOR}.${qtlibs_FIND_VERSION_MINOR}.${qtlibs_FIND_VERSION_PATCH}" ${qtlibs_FIND_VERSION_EXACT})
				else()
					add_To_Install_External_Package_Specification(qtlibs "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package qtlibs with a version compatible with ${qtlibs_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_TO_USE)

else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(qtlibs_FIND_REQUIRED)
			if(qtlibs_FIND_VERSION)
				add_To_Install_External_Package_Specification(qtlibs "${qtlibs_FIND_VERSION_MAJOR}.${qtlibs_FIND_VERSION_MINOR}.${qtlibs_FIND_VERSION_PATCH}" ${qtlibs_FIND_VERSION_EXACT})
			else()
				add_To_Install_External_Package_Specification(qtlibs "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required external package qtlibs cannot be found in the workspace")
	endif()
endif()

