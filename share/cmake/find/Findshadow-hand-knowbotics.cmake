####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(shadow-hand-knowbotics_FIND_REQUIRED)
		message(SEND_ERROR ${message_to_send})#fatal error
		return()
	elseif(shadow-hand-knowbotics_FIND_QUIETLY)
		return()#simply exitting
	else(shadow-hand-knowbotics_FIND_QUIETLY)
		message(STATUS ${message_to_send})#simple notification message
		return() 
	endif()
endmacro(exitFindScript message_to_send)

####################################################
####### shadow-hand-knowbotics find script begins here #####
####################################################
set(shadow-hand-knowbotics_FOUND FALSE CACHE INTERNAL "")

#workspace dir must be defined for each package build
set(PACKAGE_shadow-hand-knowbotics_SEARCH_PATH
    ${PACKAGE_BINARY_INSTALL_DIR}/shadow-hand-knowbotics
    CACHE
    INTERNAL
    "path to the package install dir containing versions of the shadow-hand-knowbotics package"
  )

check_Directory_Exists(EXIST ${PACKAGE_shadow-hand-knowbotics_SEARCH_PATH})
if(EXIST)
	# at this stage the only thing to do is to check for versions

	#variables that will be filled by generic functions
	if(shadow-hand-knowbotics_FIND_VERSION)
		if(shadow-hand-knowbotics_FIND_VERSION_EXACT) #using a specific version (only patch number can be adapted, first searching if there is any local version matching constraints, otherwise search for a non local version)
			check_Exact_Version(VERSION_HAS_BEEN_FOUND "shadow-hand-knowbotics" ${PACKAGE_shadow-hand-knowbotics_SEARCH_PATH} ${shadow-hand-knowbotics_FIND_VERSION_MAJOR} ${shadow-hand-knowbotics_FIND_VERSION_MINOR})
		else() #using the best version as regard of version constraints (only non local version are used)
			check_Best_Version(VERSION_HAS_BEEN_FOUND "shadow-hand-knowbotics" ${PACKAGE_shadow-hand-knowbotics_SEARCH_PATH} ${shadow-hand-knowbotics_FIND_VERSION_MAJOR} ${shadow-hand-knowbotics_FIND_VERSION_MINOR})
		endif()
	else(shadow-hand-knowbotics_FIND_VERSION) #no specific version targetted using last available version (takes the last version available either local or non local - local first)
		check_Last_Version(VERSION_HAS_BEEN_FOUND "shadow-hand-knowbotics" ${PACKAGE_shadow-hand-knowbotics_SEARCH_PATH})
	endif(shadow-hand-knowbotics_FIND_VERSION)

	if(VERSION_HAS_BEEN_FOUND)#a good version of the package has been found
		set(PATH_TO_PACKAGE_VERSION ${PACKAGE_shadow-hand-knowbotics_SEARCH_PATH}/${shadow-hand-knowbotics_VERSION_RELATIVE_PATH})	
		if(shadow-hand-knowbotics_FIND_COMPONENTS) #specific components must be checked, taking only selected components	
				
			select_Components(shadow-hand-knowbotics ${shadow-hand-knowbotics_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION} "${shadow-hand-knowbotics_FIND_COMPONENTS}")
			if(USE_FILE_NOTFOUND)
				exitFindScript("The shadow-hand-knowbotics version selected (${shadow-hand-knowbotics_VERSION_STRING}) has no configuration file or file is corrupted")
			endif(USE_FILE_NOTFOUND)

			if(NOT ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND)
				exitFindScript("Some of the requested components of the package shadow-hand-knowbotics are missing (version chosen is ${shadow-hand-knowbotics_VERSION_STRING}, requested is ${shadow-hand-knowbotics_FIND_VERSION}),either bad names specified or broken package versionning")
			endif(NOT ALL_REQUIRED_COMPONENTS_HAVE_BEEN_FOUND)	
		
		else(shadow-hand-knowbotics_FIND_COMPONENTS)#no component check, register all of them
			all_Components("shadow-hand-knowbotics" ${shadow-hand-knowbotics_VERSION_STRING} ${PATH_TO_PACKAGE_VERSION})
			if(USE_FILE_NOTFOUND)
				exitFindScript("The shadow-hand-knowbotics version selected (${shadow-hand-knowbotics_VERSION_STRING}) has no configuration file or file is corrupted")
			endif(USE_FILE_NOTFOUND)
				
		endif(shadow-hand-knowbotics_FIND_COMPONENTS)

		#here everything has been found => setting global standard CMake find process variables to adequate values
		set(shadow-hand-knowbotics_FOUND TRUE CACHE INTERNAL "")
		set(shadow-hand-knowbotics_ROOT_DIR ${PATH_TO_PACKAGE_VERSION} CACHE INTERNAL "")
		set(${PROJECT_NAME}_ALL_USED_PACKAGES ${${PROJECT_NAME}_ALL_USED_PACKAGES} shadow-hand-knowbotics CACHE INTERNAL "")
		if(shadow-hand-knowbotics_FIND_VERSION)
			if(shadow-hand-knowbotics_FIND_VERSION_EXACT)
				set(shadow-hand-knowbotics_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
				set(shadow-hand-knowbotics_REQUIRED_VERSION_EXACT "${shadow-hand-knowbotics_FIND_VERSION_MAJOR}.${shadow-hand-knowbotics_FIND_VERSION_MINOR}" CACHE INTERNAL "")
			else()
				set(shadow-hand-knowbotics_ALL_REQUIRED_VERSIONS ${shadow-hand-knowbotics_ALL_REQUIRED_VERSIONS} "${shadow-hand-knowbotics_FIND_VERSION_MAJOR}.${shadow-hand-knowbotics_FIND_VERSION_MINOR}" CACHE INTERNAL "")	
			endif()
		else()
			set(shadow-hand-knowbotics_ALL_REQUIRED_VERSIONS CACHE INTERNAL "") #unset all the other required version
			set(shadow-hand-knowbotics_REQUIRED_VERSION_EXACT CACHE INTERNAL "") #unset the exact required version	
		endif()
		
	else(VERSION_HAS_BEEN_FOUND)#no adequate version found
		if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
			if(shadow-hand-knowbotics_FIND_REQUIRED)
				if(shadow-hand-knowbotics_FIND_VERSION)
					add_To_Install_Package_Specification(shadow-hand-knowbotics "${shadow-hand-knowbotics_FIND_VERSION_MAJOR}.${shadow-hand-knowbotics_FIND_VERSION_MINOR}" ${shadow-hand-knowbotics_FIND_VERSION_EXACT})
				else()
					add_To_Install_Package_Specification(shadow-hand-knowbotics "" FALSE)
				endif()
			endif()
		else()
			exitFindScript("The package shadow-hand-knowbotics with version ${shadow-hand-knowbotics_FIND_VERSION} cannot be found in the workspace")
		endif()
	endif(VERSION_HAS_BEEN_FOUND)
		
else(EXIST) #if the directory does not exist it means the package cannot be found
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		if(shadow-hand-knowbotics_FIND_REQUIRED)
			if(shadow-hand-knowbotics_FIND_VERSION)
				add_To_Install_Package_Specification(shadow-hand-knowbotics "${shadow-hand-knowbotics_FIND_VERSION_MAJOR}.${shadow-hand-knowbotics_FIND_VERSION_MINOR}" ${shadow-hand-knowbotics_FIND_VERSION_EXACT})
			else()
				add_To_Install_Package_Specification(shadow-hand-knowbotics "" FALSE)
			endif()
		endif()
	else()
		exitFindScript("The required package shadow-hand-knowbotics cannot be found in the workspace")
	endif()

endif(EXIST)


