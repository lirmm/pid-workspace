
####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(yaml-cpp_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(yaml-cpp_FIND_QUIETLY)
		return()#simply exitting
	else()
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### yaml-cpp find script begins here #####
####################################################

set(yaml-cpp_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(EXTERNAL_PACKAGE_yaml-cpp_SEARCH_PATH
    ${EXTERNAL_PACKAGE_BINARY_INSTALL_DIR}/yaml-cpp
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the yaml-cpp external package"
  )

set(yaml-cpp_PID_KNOWN_VERSION 0.5.1)
#set(yaml-cpp_PID_KNOWN_VERSION_0.5.1_GREATER_VERSIONS_COMPATIBLE_UP_TO 1.90)#the 1.90 is the first version that is not compatible with 1.55 version !!

check_Directory_Exists(EXIST ${EXTERNAL_PACKAGE_yaml-cpp_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions
	#variables that will be filled by generic functions
	if(yaml-cpp_FIND_VERSION)
		if(yaml-cpp_FIND_VERSION_EXACT) #using a specific version
			check_External_Exact_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_yaml-cpp_SEARCH_PATH} "${yaml-cpp_FIND_VERSION_MAJOR}.${yaml-cpp_FIND_VERSION_MINOR}.${yaml-cpp_FIND_VERSION_PATCH}")
		else() #using the best version as regard of version constraints
			check_External_Minimum_Version(VERSION_TO_USE yaml-cpp ${EXTERNAL_PACKAGE_yaml-cpp_SEARCH_PATH} "${yaml-cpp_FIND_VERSION_MAJOR}.${yaml-cpp_FIND_VERSION_MINOR}.${yaml-cpp_FIND_VERSION_PATCH}")
		endif()
	else(yaml-cpp_FIND_VERSION) #no specific version targetted using last available version (takes the last version available)
		check_External_Last_Version(VERSION_TO_USE ${EXTERNAL_PACKAGE_yaml-cpp_SEARCH_PATH})
	endif(yaml-cpp_FIND_VERSION)

	if(VERSION_TO_USE)#a good version of the package has been found
		set(yaml-cpp_FOUND TRUE CACHE INTERNAL "")
		set(yaml-cpp_ROOT_DIR ${EXTERNAL_PACKAGE_yaml-cpp_SEARCH_PATH}/${VERSION_TO_USE} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES ${${PROJECT_NAME}_ALL_USED_EXTERNAL_PACKAGES} yaml-cpp CACHE INTERNAL "")
		if(yaml-cpp_FIND_VERSION)
			if(yaml-cpp_FIND_VERSION_EXACT)
				set(yaml-cpp_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(yaml-cpp_REQUIRED_VERSION_EXACT "${yaml-cpp_FIND_VERSION_MAJOR}.${yaml-cpp_FIND_VERSION_MINOR}.${yaml-cpp_FIND_VERSION_PATCH}" CACHE INTERNAL "")
			else()
				set(yaml-cpp_ALL_REQUIRED_VERSIONS ${yaml-cpp_ALL_REQUIRED_VERSIONS} "${yaml-cpp_FIND_VERSION_MAJOR}.${yaml-cpp_FIND_VERSION_MINOR}.${yaml-cpp_FIND_VERSION_PATCH}" CACHE INTERNAL "")	
			endif()
		else()
			set(yaml-cpp_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(yaml-cpp_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(yaml-cpp_FIND_REQUIRED)
				if(yaml-cpp_FIND_VERSION)
					add_To_Install_External_Package_Specification(yaml-cpp "${yaml-cpp_FIND_VERSION_MAJOR}.${yaml-cpp_FIND_VERSION_MINOR}.${yaml-cpp_FIND_VERSION_PATCH}" ${yaml-cpp_FIND_VERSION_EXACT})
				else()
					add_To_Install_External_Package_Specification(yaml-cpp "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package yaml-cpp with a version compatible with ${yaml-cpp_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_TO_USE)

else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(yaml-cpp_FIND_REQUIRED)
			if(yaml-cpp_FIND_VERSION)
				add_To_Install_External_Package_Specification(yaml-cpp "${yaml-cpp_FIND_VERSION_MAJOR}.${yaml-cpp_FIND_VERSION_MINOR}.${yaml-cpp_FIND_VERSION_PATCH}" ${yaml-cpp_FIND_VERSION_EXACT})
			else()
				add_To_Install_External_Package_Specification(yaml-cpp "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required external package yaml-cpp cannot be found in the workspace")
	endif()
endif()


