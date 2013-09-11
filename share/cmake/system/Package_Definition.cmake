##################################################################################
#################### package management public functions and macros ##############
##################################################################################

##################################################################################
###########################  declaration of the package ##########################
##################################################################################
macro(declare_Package author institution year license address description)
include(Package_Internal_Definition)
#################################################
############ DECLARING options ##################
#################################################

include(CMakeDependentOption)
option(BUILD_EXAMPLES "Package builds examples" ON)

option(BUILD_API_DOC "Package generates the HTML API documentation" ON)
CMAKE_DEPENDENT_OPTION(BUILD_LATEX_API_DOC "Package generates the LATEX api documentation" OFF
		         "BUILD_API_DOC" OFF)

option(BUILD_AND_RUN_TESTS "Package uses tests" OFF)
option(BUILD_WITH_PRINT_MESSAGES "Package generates print in console" OFF)

option(USE_LOCAL_DEPLOYMENT "Package uses tests" ON)
CMAKE_DEPENDENT_OPTION(GENERATE_INSTALLER "Package generates an OS installer for linux with debian" ON
		         "NOT USE_LOCAL_DEPLOYMENT" OFF)

option(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD "Enabling the automatic download of not found packages marked as required" OFF)

#################################################
############ MANAGING build mode ################
#################################################
if(${CMAKE_BINARY_DIR} MATCHES release)
	reset_Mode_Cache_Options()

	set(CMAKE_BUILD_TYPE "Release" CACHE String "the type of build is dependent from build location" FORCE)
	set ( INSTALL_NAME_SUFFIX "" CACHE INTERNAL "")
	set ( USE_MODE_SUFFIX "" CACHE INTERNAL "")
	
elseif(${CMAKE_BINARY_DIR} MATCHES debug)
	reset_Mode_Cache_Options()
	
	set(CMAKE_BUILD_TYPE "Debug" CACHE String "the type of build is dependent from build location" FORCE)
	set ( INSTALL_NAME_SUFFIX -dbg CACHE INTERNAL "")
	set ( USE_MODE_SUFFIX "_DEBUG" CACHE INTERNAL "")
	
elseif(${CMAKE_BINARY_DIR} MATCHES build)

	add_custom_target(build ALL
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_BUILD_TOOL} build
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_BUILD_TOOL} build
	)
	add_custom_target(clean
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/debug ${CMAKE_BUILD_TOOL} clean
		COMMAND ${CMAKE_COMMAND} -E  chdir ${CMAKE_BINARY_DIR}/release ${CMAKE_BUILD_TOOL} clean
	)

	if(NOT EXISTS ${CMAKE_BINARY_DIR}/debug OR NOT IS_DIRECTORY ${CMAKE_BINARY_DIR}/debug)
		execute_process(COMMAND ${CMAKE_COMMAND} -E  make_directory debug WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
	endif()
	if(NOT EXISTS ${CMAKE_BINARY_DIR}/release OR NOT IS_DIRECTORY ${CMAKE_BINARY_DIR}/release)
		execute_process(COMMAND ${CMAKE_COMMAND} -E  make_directory release WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
	endif()
	
	#getting options
	execute_process(COMMAND ${CMAKE_COMMAND} -L -N WORKING_DIRECTORY ${CMAKE_BINARY_DIR} OUTPUT_FILE ${CMAKE_BINARY_DIR}/options.txt)
	#parsing option file and generating a load cache cmake script	
	file(STRINGS ${CMAKE_BINARY_DIR}/options.txt LINES)
	set(OPTIONS_FILE ${CMAKE_BINARY_DIR}/share/cacheConfig.cmake) 
	file(WRITE ${OPTIONS_FILE} "")
	foreach(line IN ITEMS ${LINES})
		if(NOT ${line} STREQUAL "-- Cache values")
			string(REGEX REPLACE "^([^:]+):([^=]+)=(.*)$" "set( \\1 \\3\ CACHE \\2 \"\" FORCE)\n" AN_OPTION "${line}")
			file(APPEND ${OPTIONS_FILE} ${AN_OPTION})
		endif()
	endforeach()
	
	execute_process(COMMAND ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/debug)
	execute_process(COMMAND ${CMAKE_COMMAND} ${CMAKE_SOURCE_DIR} WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/release)
	return()
else()	# the build must be done in the build directory
	message(WARNING "Please run cmake in the build folder of the package ${PROJECT_NAME}")
	return()
endif(${CMAKE_BINARY_DIR} MATCHES release)

#################################################
############ Initializing variables #############
#################################################
reset_cached_variables()

set(${PROJECT_NAME}_MAIN_AUTHOR "${author}" CACHE INTERNAL "")
set(${PROJECT_NAME}_MAIN_INSTITUTION "${institution}" CACHE INTERNAL "")

set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS "${author}(${institution})" CACHE INTERNAL "")

set(${PROJECT_NAME}_DESCRIPTION "${description}" CACHE INTERNAL "")
set(${PROJECT_NAME}_YEARS ${year} CACHE INTERNAL "")
set(${PROJECT_NAME}_LICENSE ${license} CACHE INTERNAL "")
set(${PROJECT_NAME}_ADDRESS ${address} CACHE INTERNAL "")

#################################################
############ MANAGING generic paths #############
#################################################
set(PACKAGE_BINARY_INSTALL_DIR ${WORKSPACE_DIR}/install CACHE INTERNAL "")
set(${PROJECT_NAME}_INSTALL_PATH ${PACKAGE_BINARY_INSTALL_DIR}/${PROJECT_NAME} CACHE INTERNAL "")
set(CMAKE_INSTALL_PREFIX ${${PROJECT_NAME}_INSTALL_PATH})

if(BUILD_WITH_PRINT_MESSAGES)
	add_definitions(-DPRINT_MESSAGES)
endif(BUILD_WITH_PRINT_MESSAGES)

########################################################################
############ inclusion of required macros and functions ################
########################################################################
include(Package_Internal_Finding)
endmacro(declare_Package)


###
function(add_Author author institution)
	set(${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS ${${PROJECT_NAME}_AUTHORS_AND_INSTITUTIONS} "${author}(${institution})" CACHE INTERNAL "")
endfunction(add_Author)

###
function(add_Reference version system url)
	set(${PROJECT_NAME}_REFERENCES ${${PROJECT_NAME}_REFERENCES} ${version} CACHE INTERNAL "")
	set(${PROJECT_NAME}_REFERENCE_${version} ${${PROJECT_NAME}_REFERENCE_${version}} ${system} CACHE INTERNAL "")
	set(${${PROJECT_NAME}_REFERENCE_${version}_${system} ${url} CACHE INTERNAL "")
endfunction(add_Reference)

###
function(add_Caterory category_spec)
	set(${PROJECT_NAME}_CATEGORIES ${${PROJECT_NAME}_CATEGORIES} ${category_spec} CACHE INTERNAL "")
endfunction(add_Caterory)

############################################################################
################## setting currently developed version number ##############
############################################################################
function(set_Current_Version major minor patch)

	set (${PROJECT_NAME}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set (${PROJECT_NAME}_VERSION ${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH} CACHE INTERNAL "")
	message(STATUS "version currently built = "${${PROJECT_NAME}_VERSION})

	#################################################
	############ MANAGING install paths #############
	#################################################
	if(USE_LOCAL_DEPLOYMENT)
		set(${PROJECT_NAME}_DEPLOY_PATH own-${${PROJECT_NAME}_VERSION} CACHE INTERNAL "")
	else(USE_LOCAL_DEPLOYMENT)
		set(${PROJECT_NAME}_DEPLOY_PATH ${${PROJECT_NAME}_VERSION} CACHE INTERNAL "")
	endif(USE_LOCAL_DEPLOYMENT) 
	set ( ${PROJECT_NAME}_INSTALL_LIB_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_AR_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/lib CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_HEADERS_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/include CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_SHARE_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/share CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_BIN_PATH ${${PROJECT_NAME}_DEPLOY_PATH}/bin CACHE INTERNAL "")
	set ( ${PROJECT_NAME}_INSTALL_RPATH_DIR ${${PROJECT_NAME}_DEPLOY_PATH}/.rpath CACHE INTERNAL "")
endfunction(set_Current_Version)


##################################################################################
################################### building the package #########################
##################################################################################
macro(build_Package)

set(CMAKE_SKIP_BUILD_RPATH  FALSE) # don't skip the full RPATH for the build tree
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) # when building, don't use the install RPATH already
#set(CMAKE_INSTALL_RPATH "${${PROJECT_NAME}_INSTALL_PATH}/${${PROJECT_NAME}_INSTALL_LIB_PATH}") 
if(UNIX AND NOT APPLE)
	set(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib") #the default install rpath is the library folder of the installed package (internal libraries managed by default), name is relative to $ORIGIN to enable easy package relocation
else() #TODO with APPLE
	message("install system is compatible with UNIX systems but not APPLE")
endif()

#################################################################################
############ MANAGING the configuration of package dependencies #################
#################################################################################
include(Package_Internal_Configuration)
# from here only direct dependencies have been satisfied
# 0) if there are packages to install it means that there are some unresolved required dependencies
if(${PROJECT_NAME}_TOINSTALL_PACKAGES)
	if(REQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD)
		message(FATAL_ERROR "there are some unresolved required package dependencies : ${${PROJECT_NAME}_TOINSTALL_PACKAGES}. Automatic download of package not supported yet")#TODO
		return()
	else()	
		message(FATAL_ERROR "there are some unresolved required package dependencies : ${${PROJECT_NAME}_TOINSTALL_PACKAGES}. You may download them \"by hand\" or use the required packages automatic download option")
		return()
	endif()

endif()

# 1) resolving required packages versions (there can be multiple versions required at the same time)
# we get the set of all packages undirectly required
foreach(dep_pack IN ITEMS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
	resolve_Package_Build_Dependencies(${dep_pack})
endforeach()
#here every package dependency should have been resolved OR ERROR

# 2) if all version are OK resolving all necessary variables (CFLAGS, LDFLAGS and include directories)
foreach(dep_pack IN ITEMS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
	configure_Package_Build_Variables(${dep_pack})
endforeach()

# 3) when done resolving runtime dependencies for all used package (direct or undirect)
foreach(dep_pack IN ITEMS ${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX})
	resolve_Package_Runtime_Dependencies(${dep_pack} ${CMAKE_BUILD_TYPE})
endforeach()

#################################################
############ MANAGING the BUILD #################
#################################################

# recursive call into subdirectories to build/install/test the package
add_subdirectory(src)
add_subdirectory(apps)
add_subdirectory(test)
add_subdirectory(share)

##########################################################
############ MANAGING non source files ###################
##########################################################
generate_License_File() # generating/installing the file containing license info about the package
generate_Find_File() # generating/installing the generic cmake find file for the package
if(${CMAKE_BUILD_TYPE} MATCHES Release)
	#installing the share/cmake folder (may contain specific find scripts for external libs used by the package)
	install(DIRECTORY ${CMAKE_SOURCE_DIR}/share/cmake DESTINATION ${${PROJECT_NAME}_INSTALL_SHARE_PATH})
endif()
generate_Use_File() #generating/installing the version specific cmake "use" file
generate_API() #generating/installing the API documentation

#resolving dependencies
foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	resolve_Source_Component_Runtime_Dependencies(${component})
endforeach()

#################################################
##### MANAGING the SYSTEM PACKAGING #############
#################################################
#TODO Il faudrait packager les libs debug ET release d'un coup !! (PAS facile avec CMAKE) -> pas nécessaire il suffit de fournir les 2 packages deb d'un coup + dans le package release un script d'installation => pas besoin on peut faire un script générique avec les infos contenues dans les use files
#
if(GENERATE_INSTALLER)
	include(InstallRequiredSystemLibraries)
	#common infos	
	set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
	set(CPACK_PACKAGE_CONTACT ${${PROJECT_NAME}_MAIN_AUTHOR})
	set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${${PROJECT_NAME}_DESCRIPTION})
	set(CPACK_PACKAGE_VENDOR ${${PROJECT_NAME}_MAIN_INSTITUTION})
	set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_SOURCE_DIR}/license.txt)
	set(CPACK_PACKAGE_VERSION_MAJOR ${${PROJECT_NAME}_VERSION_MAJOR})
	set(CPACK_PACKAGE_VERSION_MINOR ${${PROJECT_NAME}_VERSION_MINOR})
	set(CPACK_PACKAGE_VERSION_PATCH ${${PROJECT_NAME}_VERSION_PATCH})
	set(CPACK_PACKAGE_VERSION "${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}")
	set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}/${${PROJECT_NAME}_VERSION}")

	if(UNIX AND NOT APPLE AND NOT CYGWIN)#on any unix platform

		list(APPEND CPACK_GENERATOR DEB)	
		execute_process(COMMAND dpkg --print-architecture OUTPUT_VARIABLE OUT_DPKG)
		set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${OUT_DPKG})
		 		

		add_custom_target(package_install
				COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.deb
				${${PROJECT_NAME}_INSTALL_PATH}/installers/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.deb
				COMMENT "installing ${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}${INSTALL_NAME_SUFFIX}-Linux.deb in ${${PROJECT_NAME}_INSTALL_PATH}/installers"
				)
	endif() 
	
	if(CPACK_GENERATOR DEB) #there are defined generators
		include(CPack)
	endif()
endif(GENERATE_INSTALLER)

###############################################################################
######### creating build target for easy sequencing all make commands #########
###############################################################################

#creating a global build command
if(GENERATE_INSTALLER)
	if(CMAKE_BUILD_TYPE MATCHES Release)
		if(BUILD_AND_RUN_TESTS)
			if(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} test
					COMMAND ${CMAKE_BUILD_TOOL} doc 
					COMMAND ${CMAKE_BUILD_TOOL} install
					COMMAND ${CMAKE_BUILD_TOOL} package
					COMMAND ${CMAKE_BUILD_TOOL} package_install
				)
			else(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} test
					COMMAND ${CMAKE_BUILD_TOOL} install
					COMMAND ${CMAKE_BUILD_TOOL} package
					COMMAND ${CMAKE_BUILD_TOOL} package_install
				)
			endif(BUILD_API_DOC) 
		else(BUILD_AND_RUN_TESTS)
			if(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} doc 
					COMMAND ${CMAKE_BUILD_TOOL} install
					COMMAND ${CMAKE_BUILD_TOOL} package
					COMMAND ${CMAKE_BUILD_TOOL} package_install
				)
			else(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} install
					COMMAND ${CMAKE_BUILD_TOOL} package
					COMMAND ${CMAKE_BUILD_TOOL} package_install
				)
			endif(BUILD_API_DOC)
		endif(BUILD_AND_RUN_TESTS)
	else(CMAKE_BUILD_TYPE MATCHES Release)
		if(BUILD_AND_RUN_TESTS)
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL} 
				COMMAND ${CMAKE_BUILD_TOOL} test
				COMMAND ${CMAKE_BUILD_TOOL} install
				COMMAND ${CMAKE_BUILD_TOOL} package
				COMMAND ${CMAKE_BUILD_TOOL} package_install
			) 
		else(BUILD_AND_RUN_TESTS)
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL} 
				COMMAND ${CMAKE_BUILD_TOOL} install
				COMMAND ${CMAKE_BUILD_TOOL} package
				COMMAND ${CMAKE_BUILD_TOOL} package_install
			)  
		endif(BUILD_AND_RUN_TESTS)

	endif(CMAKE_BUILD_TYPE MATCHES Release)

else(GENERATE_INSTALLER)
	if(CMAKE_BUILD_TYPE MATCHES Release)
		if(BUILD_AND_RUN_TESTS)
			if(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} test
					COMMAND ${CMAKE_BUILD_TOOL} doc 
					COMMAND ${CMAKE_BUILD_TOOL} install
				)
			else(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} test
					COMMAND ${CMAKE_BUILD_TOOL} install
				)
			endif(BUILD_API_DOC) 
		else(BUILD_AND_RUN_TESTS)
			if(BUILD_API_DOC)
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} doc 
					COMMAND ${CMAKE_BUILD_TOOL} install
				)
			else(BUILD_API_DOC) 
				add_custom_target(build 
					COMMAND ${CMAKE_BUILD_TOOL}
					COMMAND ${CMAKE_BUILD_TOOL} install
				)
			endif(BUILD_API_DOC)
		endif()
	else(CMAKE_BUILD_TYPE MATCHES Release)
		if(BUILD_AND_RUN_TESTS)
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL}
				COMMAND ${CMAKE_BUILD_TOOL} test
				COMMAND ${CMAKE_BUILD_TOOL} install
			) 
		else(BUILD_AND_RUN_TESTS)
			
			add_custom_target(build 
				COMMAND ${CMAKE_BUILD_TOOL} 
				COMMAND ${CMAKE_BUILD_TOOL} install
			) 
		endif(BUILD_AND_RUN_TESTS)
	endif(CMAKE_BUILD_TYPE MATCHES Release)
endif(GENERATE_INSTALLER)

endmacro(build_Package)


##################################################################################
################ printing variables for components in the package ################
##################################################################################
macro(printComponentVariables)
	message("components of package ${PROJECT_NAME} are :" ${${PROJECT_NAME}_COMPONENTS})
	message("libraries : "${${PROJECT_NAME}_COMPONENTS_LIBS})
	message("applications : "${${PROJECT_NAME}_COMPONENTS_APPS})
endmacro(printComponentVariables)

##################################################################################
###################### declaration of a library component ########################
##################################################################################
# internal_defs : definitions that affects the implementation of the library component
# exported_defs : definitions that affects the interface of the library component
# internal_inc_dirs : additionnal include dirs (internal to package, that contains header files, e.g. like common definition between package components, that don't have to be exported since not in the interface)

function(declare_Library_Component c_name dirname type internal_inc_dirs internal_defs exported_defs)
if(${PROJECT_NAME}_${c_name}_DECLARED)
	message(FATAL_ERROR "declare_Library_Component : a component with the same name ${c_name} is already defined")
	return()
endif()	
#indicating that the component has been declared and need to be completed
if(type STREQUAL "HEADER"
OR type STREQUAL "STATIC"
OR type STREQUAL "SHARED")
	set(${PROJECT_NAME}_${c_name}_TYPE ${type} CACHE INTERNAL "")
else()
	message(FATAL_ERROR "you must specify a type (HEADER, STATIC or SHARED) for your library")
	return()
endif()

### managing headers ###
#a library defines a folder containing one or more headers and/or subdirectories 
set(${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include/${dirname})

set(${PROJECT_NAME}_${c_name}_HEADER_DIR_NAME ${dirname} CACHE INTERNAL "")
file(	GLOB_RECURSE
	${PROJECT_NAME}_${c_name}_ALL_HEADERS_RELATIVE
	RELATIVE ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}
       	"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.h" 
	"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hh" 
	"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hpp"
)


#message("relative headers are : ${${PROJECT_NAME}_${c_name}_ALL_HEADERS_RELATIVE}")

set(${PROJECT_NAME}_${c_name}_HEADERS ${${PROJECT_NAME}_${c_name}_ALL_HEADERS_RELATIVE} CACHE INTERNAL "")

install(DIRECTORY ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.h")
install(DIRECTORY ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.hpp")
install(DIRECTORY ${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR} DESTINATION ${${PROJECT_NAME}_INSTALL_HEADERS_PATH} FILES_MATCHING PATTERN "*.hh")


if(NOT ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "HEADER")
	#collect sources for the library
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/${dirname})

	file(	GLOB_RECURSE 
		${PROJECT_NAME}_${c_name}_ALL_SOURCES 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.c" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cc" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cpp" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.h" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hpp" 
		"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hh"
	       	"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.h" 
		"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hh" 
		"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hpp"
	)
	
	#defining shared and/or static targets for the library and
	#adding the targets to the list of installed components when make install is called
	if(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "STATIC")
		add_library(${c_name}${INSTALL_NAME_SUFFIX} STATIC ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
		install(TARGETS ${c_name}${INSTALL_NAME_SUFFIX}
			ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_AR_PATH}
		)

	elseif(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "SHARED")
		add_library(${c_name}${INSTALL_NAME_SUFFIX} SHARED ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
		
		install(TARGETS ${c_name}${INSTALL_NAME_SUFFIX}
			LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}
			RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
		)
		#setting the default rpath for the target	
		set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_RPATH};\$ORIGIN/../.rpath/${c_name}") #the library targets a specific folder that contains symbolic links to used shared libraries
		install(DIRECTORY DESTINATION ${${PROJECT_NAME}_INSTALL_RPATH_DIR}/${c_name}${INSTALL_NAME_SUFFIX})#create the folder that will contain symbolic links to shared libraries used by the component (will allow full relocation of components runtime dependencies at install time)
		
	endif()
	manage_Additional_Component_Internal_Flags(${c_name} "${internal_inc_dirs}" "${internal_defs}")
	manage_Additional_Component_Exported_Flags(${c_name} "${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}" "${exported_defs}" "")
	# registering the binary name
	get_target_property(LIB_NAME ${c_name}${INSTALL_NAME_SUFFIX} LOCATION)
	get_filename_component(LIB_NAME ${LIB_NAME} NAME)
	set(${PROJECT_NAME}_${c_name}_BINARY_NAME${USE_MODE_SUFFIX} ${LIB_NAME} CACHE INTERNAL "") #exported include directories

message("lib name is ${LIB_NAME}")

else()#simply creating a "fake" target for header only library
	file(	GLOB_RECURSE 
		${PROJECT_NAME}_${c_name}_ALL_SOURCES 
	       	"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.h" 
		"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hh" 
		"${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}/*.hpp"
	)
	#add_library(${c_name}${INSTALL_NAME_SUFFIX} STATIC IMPORTED GLOBAL)
	add_library(${c_name}${INSTALL_NAME_SUFFIX} STATIC ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
	set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES LINKER_LANGUAGE CXX) #to allow CMake to knwo the linker to use (will not be trully called) for the "fake library" target 
	manage_Additional_Component_Exported_Flags(${c_name} "${${PROJECT_NAME}_${c_name}_TEMP_INCLUDE_DIR}" "${exported_defs}" "")
endif()

# registering exported flags for all kinds of libs
set(${PROJECT_NAME}_${c_name}_DEFS${USE_MODE_SUFFIX} "${exported_defs}" CACHE INTERNAL "") #exported defs
set(${PROJECT_NAME}_${c_name}_LINKS${USE_MODE_SUFFIX} "" CACHE INTERNAL "") #exported links
set(${PROJECT_NAME}_${c_name}_INC_DIRS${USE_MODE_SUFFIX} "" CACHE INTERNAL "") #exported include directories (not useful to set it there since they will be exported "manually")

#registering dynamic dependencies
set(${PROJECT_NAME}_${c_name}_RUNTIME_DEPS${USE_MODE_SUFFIX} "" CACHE INTERNAL "") #runtime dependencies (may be exported in links)

#updating global variables of the CMake process	
set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_LIBS "${${PROJECT_NAME}_COMPONENTS_LIBS};${c_name}" CACHE INTERNAL "")
# global variable to know that the component has been declared (must be reinitialized at each run of cmake)
set(${PROJECT_NAME}_${c_name}_DECLARED TRUE CACHE INTERNAL "")
endfunction(declare_Library_Component)


##################################################################################
################# declaration of an application component ########################
##################################################################################
# internal_defs : definitions that affects the implementation of the application component
# internal_link_flags : additionnal linker flags that affects required to link the application component
# internal_inc_dirs : additionnal include dirs (internal to project, that contains header files, e.g. common definition between components that don't have to be exported)
function(declare_Application_Component c_name dirname type internal_inc_dirs internal_defs internal_link_flags)
if(${PROJECT_NAME}_${c_name}_DECLARED)
	message(FATAL_ERROR "declare_Application_Component : a component with the same name ${c_name} is already defined")
	return()
endif()

if(	type STREQUAL "TEST" 
	OR type STREQUAL "APP"
	OR type STREQUAL "EXAMPLE")
	set(${PROJECT_NAME}_${c_name}_TYPE ${type} CACHE INTERNAL "")
else() #a simple application by default
	message(FATAL_ERROR "you have to set a type name (TEST, APP, EXAMPLE) for the application component ${c_name}")
	return()
endif()	
# specifically managing examples 	
if(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "EXAMPLE") 
	add_Example_To_Doc(${c_name}) #examples are added to the doc to be referenced		
	if(NOT ${BUILD_EXAMPLES}) #examples are not built so no need to continue
		set(${PROJECT_NAME}_${c_name}_DECLARED TRUE CACHE INTERNAL "")		
		return()
	endif()
elseif(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "TEST")
	if(NOT ${BUILD_AND_RUN_TESTS}) #tests are not built so no need to continue
		set(${PROJECT_NAME}_${c_name}_DECLARED TRUE CACHE INTERNAL "")
		return()
	endif()
endif()

#managing sources for the application

if(	${PROJECT_NAME}_${c_name}_TYPE STREQUAL "APP"
	OR ${PROJECT_NAME}_${c_name}_TYPE STREQUAL "EXAMPLE")	
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/apps/${dirname} CACHE INTERNAL "")
elseif(	${PROJECT_NAME}_${c_name}_TYPE STREQUAL "TEST")
	set(${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR ${CMAKE_SOURCE_DIR}/test/${dirname} CACHE INTERNAL "")
endif()

file(	GLOB_RECURSE 
	${PROJECT_NAME}_${c_name}_ALL_SOURCES 
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.c" 
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cc" 
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.cpp" 
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.h" 
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hpp" 
	"${${PROJECT_NAME}_${c_name}_TEMP_SOURCE_DIR}/*.hh"
)

#defining the target to build the application
add_executable(${c_name}${INSTALL_NAME_SUFFIX} ${${PROJECT_NAME}_${c_name}_ALL_SOURCES})
manage_Additional_Component_Internal_Flags(${c_name} "${internal_inc_dirs}" "${internal_defs}")
manage_Additional_Component_Exported_Flags(${c_name} "" "" "${internal_link_flags}")

if(NOT ${${PROJECT_NAME}_${c_name}_TYPE} STREQUAL "TEST")
	# adding the application to the list of installed components when make install is called (not for test applications)
	install(TARGETS ${c_name}${INSTALL_NAME_SUFFIX} 
		RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
	)
	#setting the default rpath for the target	
	set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_RPATH};\$ORIGIN/../.rpath/${c_name}") #the application targets a specific folder that contains symbolic links to used shared libraries
	install(DIRECTORY DESTINATION ${${PROJECT_NAME}_INSTALL_RPATH_DIR}/${c_name}${INSTALL_NAME_SUFFIX})#create the folder that will contain symbolic links to shared libraries used by the component (will allow full relocation of components runtime dependencies at install time)
	# NB : tests do not need to be relocatable since they are purely local
endif()

# registering exported flags for all kinds of apps => empty variables since applications export no flags
set(${PROJECT_NAME}_${c_name}_DEFS${USE_MODE_SUFFIX} "" CACHE INTERNAL "")
set(${PROJECT_NAME}_${c_name}_LINKS${USE_MODE_SUFFIX} "" CACHE INTERNAL "")
set(${PROJECT_NAME}_${c_name}_INC_DIRS${USE_MODE_SUFFIX} "" CACHE INTERNAL "") #exported include directories

#registering dynamic dependencies
set(${PROJECT_NAME}_${c_name}_RUNTIME_DEPS${USE_MODE_SUFFIX} "" CACHE INTERNAL "") #private runtime dependencies only

get_target_property(EXE_NAME ${c_name}${INSTALL_NAME_SUFFIX} LOCATION)
get_filename_component(EXE_NAME ${EXE_NAME} NAME)
set(${PROJECT_NAME}_${c_name}_BINARY_NAME${USE_MODE_SUFFIX} ${EXE_NAME} CACHE INTERNAL "") #name of the executable

#updating global variables of the CMake process	
set(${PROJECT_NAME}_COMPONENTS "${${PROJECT_NAME}_COMPONENTS};${c_name}" CACHE INTERNAL "")
set(${PROJECT_NAME}_COMPONENTS_APPS "${${PROJECT_NAME}_COMPONENTS_APPS};${c_name}" CACHE INTERNAL "")
# global variable to know that the component has been declared  (must be reinitialized at each run of cmake)
set(${PROJECT_NAME}_${c_name}_DECLARED TRUE CACHE INTERNAL "")
endfunction(declare_Application_Component)


##################################################################################
####### specifying a dependency between the current package and another one ######
### global dependencies between packages (the system package is considered #######
###### as external but requires no additionnal info (default system folders) ##### 
### these functions are to be used after a find_package command. #################
##################################################################################

function(declare_Package_Dependancy dep_package version exact list_of_components)
# ${PROJECT_NAME}_DEPENDENCIES				# packages required by current package
# ${PROJECT_NAME}__DEPENDENCY_${dep_package}_VERSION		# version constraint for package ${dep_package}   required by ${PROJECT_NAME}  
# ${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION_EXACT	# TRUE if exact version is required
# ${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS	# list of composants of ${dep_package} used by current package
	# the package is necessarily required at that time
	set(${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCIES${USE_MODE_SUFFIX}} ${dep_package} CACHE INTERNAL "")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_VERSION${USE_MODE_SUFFIX} ${version} CACHE INTERNAL "")

 	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_${version}_EXACT${USE_MODE_SUFFIX} ${exact} CACHE INTERNAL "")
	set(${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX} ${${PROJECT_NAME}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}} ${list_of_components} CACHE INTERNAL "")
endfunction(declare_Package_Dependancy)

### declare external dependancies
function(declare_External_Package_Dependancy dep_package path_to_dependency)
	#${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_REFERENCE_PATH is the helper path to locate external libs
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_EXTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}} ${dep_package} CACHE INTERNAL "")
	set(${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_REFERENCE_PATH${USE_MODE_SUFFIX} ${path_to_dependency} CACHE PATH "Reference path to the root dir of external library")
endfunction(declare_External_Package_Dependancy)


##################################################################################
################# local dependencies between components ########################## 
### these functions are to be used after a find_package command and after ######## 
### the declaration of internal components (otherwise will not work) #############
##################################################################################

### declare internal dependancies between components of the same package ${PROJECT_NAME}
### comp_exp_defs : definitions in the interface of ${component} that conditionnate the use of ${dep_component}, if any  => definitions are exported
### comp_defs  : definitions in the implementation of ${component} that conditionnate the use of ${dep_component}, if any => definitions are not exported
### dep_defs  : definitions in the interface of ${dep_component} that must be defined when ${component} uses ${dep_component}, if any => definitions are exported if dep_component is exported
### export : if true the component export the dep_component in its interface (export is always false if component is an application)

function(declare_Internal_Component_Dependancy component dep_component export comp_defs comp_exp_defs dep_defs)
#message("declare_Internal_Component_Dependancy : component = ${component}, dep_component=${dep_component}, export=${export}, comp_defs=${comp_defs} comp_exp_defs=${comp_exp_defs} dep_defs=${dep_defs}")

will_be_Built(COMP_WILL_BE_BUILT ${component})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()
if( NOT ${PROJECT_NAME}_${dep_component}_DECLARED)
	message(FATAL_ERROR "Problem : component ${dep_component} is not defined in current package")
endif()
#guarding depending type of involved components
is_Executable_Component(IS_EXEC_COMP ${PROJECT_NAME} ${component})	
is_Executable_Component(IS_EXEC_DEP ${PROJECT_NAME} ${dep_component})
is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})
if(IS_EXEC_DEP)
	message(FATAL_ERROR "an executable component (${dep_component}) cannot be a dependancy !!")
	return()
else()
	set(${PROJECT_NAME}_${c_name}_INTERNAL_EXPORT_${dep_component} FALSE)
	if (IS_EXEC_COMP)
		# setting compile definitions for configuring the target
		fill_Component_Target_With_Internal_Dependency(${component} ${dep_component} FALSE "${comp_defs}" "" "${dep_defs}")
		
	elseif(IS_BUILT_COMP)
		#prepare the dependancy export
		if(export)
			set(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${dep_component} TRUE)
		endif()
		configure_Install_Variables(${component} ${export} "" "${dep_defs}" "${comp_exp_defs}" "" "")

		# setting compile definitions for configuring the target
		fill_Component_Target_With_Internal_Dependency(${component} ${dep_component} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
		
	elseif(	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
		#prepare the dependancy export
		set(${PROJECT_NAME}_${component}_INTERNAL_EXPORT_${dep_component} TRUE) #export is necessarily true for a pure header library
		configure_Install_Variables(${component} TRUE "" "${dep_defs}" "${comp_exp_defs}" "" "")
		#NEW		
		# setting compile definitions for configuring the "fake" target
		fill_Component_Target_With_Internal_Dependency(${component} ${dep_component} TRUE "" "${comp_exp_defs}"  "${dep_defs}")

	else()
		message (FATAL_ERROR "unknown type (${${PROJECT_NAME}_${component}_TYPE}) for component ${component}")
		return()
	endif()
	# include directories and links do not require to be added 
	# declare the internal dependency
	set(	${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX} 
		${${PROJECT_NAME}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}} ${dep_component}
		CACHE INTERNAL "")
endif()
endfunction(declare_Internal_Component_Dependancy)


### declare package dependancies between components of two packages ${PROJECT_NAME} and ${dep_package}
### comp_exp_defs : definitions in the interface of ${component} that conditionnate the use of ${dep_component}, if any => definitions are exported
### comp_defs  : definitions in the implementation of ${component} that conditionnate the use of ${dep_component}, if any => definitions are not exported
### dep_defs  : definitions in the interface of ${dep_component} that must be defined when ${component} uses ${dep_component}, if any => definitions are exported if dep_component is exported
### export : if true the component export the dep_component in its interface (export is always false if component is an application)
function(declare_Package_Component_Dependancy component dep_package dep_component export comp_defs comp_exp_defs dep_defs)
	# ${PROJECT_NAME}_${component}_DEPENDENCIES			# packages used by the component ${component} of the current package
	# ${PROJECT_NAME}_${component}_DEPENDENCY_${dep_package}_COMPONENTS	# components of package ${dep_package} used by component ${component} of current package
#message("declare_Package_Component_Dependancy : component = ${component}, dep_package = ${dep_package}, dep_component=${dep_component}, export=${export}, comp_defs=${comp_defs} comp_exp_defs=${comp_exp_defs} dep_defs=${dep_defs}")
will_be_Built(COMP_WILL_BE_BUILT ${component})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()

if( NOT ${dep_package}_${dep_component}_DECLARED)
	message(FATAL_ERROR "Problem : ${dep_component} in package ${dep_package} is not defined")
endif()

if(dep_package STREQUAL ${PROJECT_NAME})
	declare_Internal_Component_Dependancy(${component} ${dep_component} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
else()
	set(${PROJECT_NAME}_${c_name}_EXPORT_${dep_package}_${dep_component} FALSE)
	#guarding depending type of involved components
	is_Executable_Component(IS_EXEC_COMP ${PROJECT_NAME} ${component})	
	is_Executable_Component(IS_EXEC_DEP ${dep_package} ${dep_component})
	is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})
	if(IS_EXEC_DEP)
		message(FATAL_ERROR "an executable component (${dep_component}) cannot be a dependancy !!")
		return()
	else()
		if (IS_EXEC_COMP)
			# setting compile definitions for configuring the target
			fill_Component_Target_With_Package_Dependency(${component} ${dep_package} ${dep_component} FALSE "${comp_defs}" "" "${dep_defs}")
			#do not export anything

		elseif(IS_BUILT_COMP)
			#prepare the dependancy export
			if(export)
				set(${PROJECT_NAME}_${component}_EXPORT_${dep_package}_${dep_component} TRUE)
			endif()
			configure_Install_Variables(${component} ${export} "" "${dep_defs}" "${comp_exp_defs}" "" "")
	
			# setting compile definitions for configuring the target
			fill_Component_Target_With_Package_Dependency(${component} ${dep_package} ${dep_component} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")

		elseif(	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
			#prepare the dependancy export
			set(${PROJECT_NAME}_${component}_EXPORT_${dep_package}_${dep_component} TRUE) #export is necessarily true for a pure header library
			configure_Install_Variables(${component} TRUE "" "${dep_defs}" "${comp_exp_defs}" "" "")
			# NEW
			# setting compile definitions for configuring the "fake" target
			fill_Component_Target_With_Package_Dependency(${component} ${dep_package} ${dep_component} TRUE "" "${comp_exp_defs}" "${dep_defs}")

		else()
			message (FATAL_ERROR "unknown type (${${PROJECT_NAME}_${component}_TYPE}) for component ${component}")
			return()
		endif()

	#links and include directories do not require to be added (will be found automatically)	
	set(${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX} ${${PROJECT_NAME}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}}  ${dep_package} CACHE INTERNAL "")
	set(${PROJECT_NAME}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}  ${${PROJECT_NAME}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}} ${dep_component} CACHE INTERNAL "")
	endif()
endif()
endfunction(declare_Package_Component_Dependancy)



### declare system (add-hoc) dependancy between components of current and a system packages 
### comp_exp_defs : definitions in the interface of ${component} that conditionnate the use of the system dependancy, if any  => definitions are exported
### comp_defs  : definitions in the implementation of ${component} that conditionnate the use of system dependancy, if any => definitions are not exported
### dep_defs  : definitions in the interface of the system dependancy that must be defined when using this system dependancy, if any => definitions are exported if dependancy is exported
### export : if true the component export the depenancy in its interface (export is always false if component is an application)
### links : links defined by the system dependancy, will be exported in any case (except by executables components)
function(declare_System_Component_Dependancy component export comp_defs comp_exp_defs dep_defs static_links shared_links)
will_be_Built(COMP_WILL_BE_BUILT ${component})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()
#guarding depending type of involved components
is_Executable_Component(IS_EXEC_COMP ${PROJECT_NAME} ${component})
is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})
	
if (IS_EXEC_COMP)
	# setting compile definitions for the target
	fill_Component_Target_With_External_Dependency(${component} FALSE "${comp_defs}" "" "${dep_defs}" "" "${links}")

elseif(IS_BUILT_COMP)
	#prepare the dependancy export
	configure_Install_Variables(${component} ${export} "" "${dep_defs}" "${comp_exp_defs}" "${static_links}" "${shared_links}")
	# setting compile definitions for the target
	set(TARGET_LINKS ${static_links} ${shared_links})
	fill_Component_Target_With_External_Dependency(${component} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}" "" "${TARGET_LINKS}")

elseif(	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
	#prepare the dependancy export
	configure_Install_Variables(${component} TRUE "" "${dep_defs}" "${comp_exp_defs}" "${static_links}" "${shared_links}") #export is necessarily true for a pure header library
	# NEW
	# setting compile definitions for the target
	set(TARGET_LINKS ${static_links} ${shared_links})
	fill_Component_Target_With_External_Dependency(${component} TRUE "" "${comp_exp_defs}" "${dep_defs}" "" "${TARGET_LINKS}")
else()
	message (FATAL_ERROR "unknown type (${${PROJECT_NAME}_${component}_TYPE}) for component ${component}")
endif()
endfunction(declare_System_Component_Dependancy)


### declare external (add-hoc) dependancy between components of current and an external package 
### comp_exp_defs : definitions in the interface of ${component} that conditionnate the use of the exported dependancy, if any  => definitions are exported
### comp_defs  : definitions in the implementation of ${component} that conditionnate the use of external dependancy, if any => definitions are not exported
### dep_defs  : definitions in the interface of the external dependancy that must be defined when using this external dependancy, if any => definitions are exported if dependancy is exported
### export : if true the component export the external depenancy in its interface (export is always false if component is an application)
### inc_dirs : include directories to add to target component in order to build (these include dirs are expressed relatively) to the reference path to the external dependancy root dir
### links : libraries and linker flags. libraries path are given relative to the dep_package REFERENCE_PATH
function(declare_External_Component_Dependancy component dep_package export inc_dirs comp_defs comp_exp_defs dep_defs static_links shared_links)
will_be_Built(COMP_WILL_BE_BUILT ${component})
if(NOT COMP_WILL_BE_BUILT)
	return()
endif()

if(DEFINED ${PROJECT_NAME}_EXTERNAL_DEPENDENCY_${dep_package}_REFERENCE_PATH${USE_MODE_SUFFIX})
	#guarding depending type of involved components
	is_Executable_Component(IS_EXEC_COMP ${PROJECT_NAME} ${component})
	is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})
	if (IS_EXEC_COMP)
		# setting compile definitions for the target
		fill_Component_Target_With_External_Dependency(${component} FALSE "${comp_defs}" "" "${dep_defs}" "${inc_dirs}" "${static_links} ${shared_links}")

	elseif(IS_BUILT_COMP)
		#prepare the dependancy export
		configure_Install_Variables(${component} ${export} "${inc_dirs}" "${dep_defs"} "${comp_exp_defs}" "${static_links}" "${shared_links}")
		# setting compile definitions for the target
		set(TARGET_LINKS ${static_links} ${shared_links})
		fill_Component_Target_With_External_Dependency(${component} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}" "${inc_dirs}" "${TARGET_LINKS}")

	elseif(	${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
		#prepare the dependancy export
		configure_Install_Variables(${component} TRUE "${inc_dirs}" "${dep_defs}" "${comp_exp_defs}" "${static_links}" "${shared_links}") #export is necessarily true for a pure header library

		# setting compile definitions for the "fake" target
		set(TARGET_LINKS ${static_links} ${shared_links}) 
		fill_Component_Target_With_External_Dependency(${component} TRUE "" "${comp_exp_defs}" "${dep_defs}" "${inc_dirs}" "${TARGET_LINKS}")

	else()
		message (FATAL_ERROR "unknown type (${${PROJECT_NAME}_${component}_TYPE}) for component ${component}")
	endif()
			
else()#the external dependancy is a system dependancy
	declare_System_Component_Dependancy(${component} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}" "${static_links}" "${shared_links}")
endif()
endfunction(declare_External_Component_Dependancy)


