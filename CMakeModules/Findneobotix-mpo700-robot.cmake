####################################################
################ auxiliary macro ###################
####################################################
macro(exitFindScript message_to_send)
	if(${neobotix-mpo700-robot_FIND_REQUIRED})
		message(FATAL_ERROR message_to_send)#fatal error
		return()
	elseif(${neobotix-mpo700-robot_FIND_QUIETLY})
		return()#simply exitting
	else(${neobotix-mpo700-robot_FIND_QUIETLY})
		message(message_to_send)#simple notification message
		return() 
	endif(${neobotix-mpo700-robot_FIND_REQUIRED})
endmacro(exitFindScript message_to_send)

####################################################
####### neobotix-mpo700-robot find script begins here #####
####################################################
set(neobotix-mpo700-robot_FOUND FALSE)

#workspace dir must be defined for each package build
set(PACKAGE_neobotix-mpo700-robot_SEARCH_PATH
    ${WORKSPACE_DIR}/frameworks/neobotix-mpo700-robot
    CACHE
    "path to the package framework containing versions of the neobotix-mpo700-robot package"
  )
mark_as_advanced(PACKAGE_neobotix-mpo700-robot_SEARCH_PATH)

if(	EXISTS "${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH}" 
	AND IS_DIRECTORY "${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH}"
  )
# at this stage the only thing to do is to check for versions
include(Package_Finding_Functions)
#variables that will be filled by generic functions
set(VERSION_HAS_BEEN_FOUND FALSE)
set(PATH_TO_PACKAGE_VERSION "")

if(DEFINED neobotix-mpo700-robot_FIND_VERSION)
	if(${neobotix-mpo700-robot_FIND_VERSION_EXACT}) #using a specific version (only patch number can be adapted)
		check_Exact_Version("neobotix-mpo700-robot" ${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH} ${neobotix-mpo700-robot_FIND_VERSION_MAJOR} ${neobotix-mpo700-robot_FIND_VERSION_MINOR})
	else(${neobotix-mpo700-robot_FIND_VERSION_EXACT}) #using the best version as regard of version constraints
		check_Adequate_Version("neobotix-mpo700-robot" ${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH} ${neobotix-mpo700-robot_FIND_VERSION_MAJOR} ${neobotix-mpo700-robot_FIND_VERSION_MINOR})
	endif(${neobotix-mpo700-robot_FIND_VERSION_EXACT})
else(DEFINED neobotix-mpo700-robot_FIND_VERSION) #no specific version targetted using own or the last available version if it does not exist   
	check_Local_Or_Newest_Version("neobotix-mpo700-robot" ${PACKAGE_neobotix-mpo700-robot_SEARCH_PATH} ${neobotix-mpo700-robot_FIND_VERSION_MAJOR} ${neobotix-mpo700-robot_FIND_VERSION_MINOR})
endif(DEFINED neobotix-mpo700-robot_FIND_VERSION)

if(${VERSION_HAS_BEEN_FOUND})#a good version of the package has been found

	if(neobotix-mpo700-robot_FIND_COMPONENTS) #specific components must be checked, taking only selected components	
		set(ALL_COMPONENTS_HAVE_BEEN_FOUND FALSE)		
		select_Components("neobotix-mpo700-robot" ${PATH_TO_PACKAGE_VERSION} ${neobotix-mpo700-robot_FIND_COMPONENTS})
		if(NOT ${ALL_COMPONENTS_HAVE_BEEN_FOUND})
			exitFindScript("Some of the requested components of the package neobotix-mpo700-robot are missing (version chosen is ${neobotix-mpo700-robot_VERSION_STRING}, requested is ${neobotix-mpo700-robot_FIND_VERSION})")
		endif(NOT ${ALL_COMPONENTS_HAVE_BEEN_FOUND})	
		
	else(neobotix-mpo700-robot_FIND_COMPONENTS)#no component check, register all of them
		all_Components("neobotix-mpo700-robot" ${PATH_TO_PACKAGE_VERSION})
	endif(neobotix-mpo700-robot_FIND_COMPONENTS)
	#here everything has been found and configured
	set(neobotix-mpo700-robot_FOUND TRUE)
else(${VERSION_HAS_BEEN_FOUND})#no adequate version found
	exitFindScript("The package neobotix-mpo700-robot with required version ${neobotix-mpo700-robot_FIND_VERSION} cannot be found")
endif(${VERSION_HAS_BEEN_FOUND})

else() #if the directory does not exist it means the package cannot be found
	exitFindScript("The required package neobotix-mpo700-robot cannot be found")
endif()

####################################################
####### neobotix-mpo700-robot find script ends here #######
####################################################

