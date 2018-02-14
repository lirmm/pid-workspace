#########################################################################################
#       This file is part of the program PID                                            #
#       Program description : build system supportting the PID methodology              #
#       Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique     #
#       et de Microelectronique de Montpellier). All Right reserved.                    #
#                                                                                       #
#       This software is free software: you can redistribute it and/or modify           #
#       it under the terms of the CeCILL-C license as published by                      #
#       the CEA CNRS INRIA, either version 1                                            #
#       of the License, or (at your option) any later version.                          #
#       This software is distributed in the hope that it will be useful,                #
#       but WITHOUT ANY WARRANTY; without even the implied warranty of                  #
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the                    #
#       CeCILL-C License for more details.                                              #
#                                                                                       #
#       You can find the complete license description on the official website           #
#       of the CeCILL licenses family (http://www.cecill.info/index.en.html)            #
#########################################################################################

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/api)
list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system/commands)

include(PID_Utils_Functions NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)

include(CMakeParseArguments)

##################################################################################################
#################### API to ease the description of external packages ############################
##################################################################################################
macro(declare_PID_External_Package)
	set(options)
	set(oneValueArgs PACKAGE)
	set(multiValueArgs)
	cmake_parse_arguments(DECLARE_PID_EXTERNAL_PACKAGE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	if(NOT DECLARE_PID_EXTERNAL_PACKAGE_PACKAGE)
		message("[PID] WARNING: Bad usage of function declare_PID_External_Package: package name must be defined using PACKAGE keyword")
		return() #return will exit from current Use file included (because we are in a macro)
	endif()
	#reset all values
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
	set(package ${DECLARE_PID_EXTERNAL_PACKAGE_PACKAGE})
	set(${package}_HAS_DESCRIPTION TRUE CACHE INTERNAL "")#variable to be used to test if the package is described with a wrapper (if this macro is used this is always TRUE)
	if(NOT ${package}_DECLARED)
		#reset all variables related to this external package
		set(${package}_PLATFORM${VAR_SUFFIX}  CACHE INTERNAL "")
		set(${package}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX}  CACHE INTERNAL "")
		if(${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
			foreach(dep IN ITEMS ${${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}})
				set(${package}_EXTERNAL_DEPENDENCY_${dep}_VERSION${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_EXTERNAL_DEPENDENCY_${dep}_VERSION_EXACT${VAR_SUFFIX} CACHE INTERNAL "")
			endforeach()
		endif()
		set(${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} CACHE INTERNAL "")
		if(${package}_COMPONENTS${VAR_SUFFIX})
			foreach(comp IN ITEMS ${${package}_COMPONENTS${VAR_SUFFIX}})
				#resetting variables of the component
				set(${package}_${comp}_INC_DIRS${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_OPTS${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_DEFS${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_STATIC_LINKS${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_SHARED_LINKS${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_C_STANDARD${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_CXX_STANDARD${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_RUNTIME_RESOURCES${VAR_SUFFIX} CACHE INTERNAL "")
				set(${package}_${comp}_INTERNAL_DEPENDENCIES${VAR_SUFFIX} CACHE INTERNAL "")
				if(${package}_${comp}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
					foreach(dep_pack IN ITEMS ${${package}_${comp}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}})
						if(${package}_${comp}_EXTERNAL_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX})
							foreach(dep_comp IN ITEMS ${${package}_${comp}_EXTERNAL_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX}})
								set(${package}_${comp}_EXTERNAL_EXPORT_${dep_pack}_${dep_comp}${VAR_SUFFIX} CACHE INTERNAL "")
							endforeach()
							set(${package}_${comp}_EXTERNAL_DEPENDENCY_${dep_pack}_COMPONENTS${VAR_SUFFIX} CACHE INTERNAL "")
						endif()
					endforeach()
					set(${package}_${comp}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} CACHE INTERNAL "")
				endif()
			endforeach()
		endif()
	else()
		return()#simply returns as the external package is already in memory
	endif()
	set(${package}_DECLARED TRUE)
endmacro(declare_PID_External_Package)

### API: used to describe external package platform constraints
macro(check_PID_External_Package_Platform)
set(options)
set(oneValueArgs PLATFORM PACKAGE)
set(multiValueArgs CONFIGURATION)
cmake_parse_arguments(CHECK_EXTERNAL_PID_PLATFORM "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
if(CHECK_EXTERNAL_PID_PLATFORM_PACKAGE
	AND CHECK_EXTERNAL_PID_PLATFORM_CONFIGURATION
	AND CHECK_EXTERNAL_PID_PLATFORM_PLATFORM)
	if(NOT ${CHECK_EXTERNAL_PID_PLATFORM_PACKAGE}_DECLARED)
		message("[PID] WARNING: Bad usage of function check_PID_External_Package_Platform: package ${CHECK_EXTERNAL_PID_PLATFORM_PACKAGE} is unknown. Use macro declare_PID_External_Package to declare it")
		return() #return will exit from current Use file included (because we are in a macro)
	endif()
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
	set(${CHECK_EXTERNAL_PID_PLATFORM_PACKAGE}_PLATFORM${VAR_SUFFIX} ${CHECK_EXTERNAL_PID_PLATFORM_PLATFORM}  CACHE INTERNAL "")
	set(${CHECK_EXTERNAL_PID_PLATFORM_PACKAGE}_PLATFORM_CONFIGURATIONS${VAR_SUFFIX} ${CHECK_EXTERNAL_PID_PLATFORM_CONFIGURATION}  CACHE INTERNAL "")
else()
	message("[PID] WARNING: Bad usage of function check_PID_External_Package_Platform: PACKAGE (value: ${CHECK_EXTERNAL_PID_PLATFORM_PACKAGE}), PLATFORM (value: ${CHECK_EXTERNAL_PID_PLATFORM_PLATFORM}) and CONFIGURATION (value: ${CHECK_EXTERNAL_PID_PLATFORM_CONFIGURATION}) keywords must be used !")
	return() #return will exit from current Use file included (because we are in a macro)
endif()
endmacro(check_PID_External_Package_Platform)

### API: used to describe external package dependency to other external packages
macro(declare_PID_External_Package_Dependency)
	set(options EXACT)
	set(oneValueArgs PACKAGE EXTERNAL VERSION)
	cmake_parse_arguments(DECLARE_PID_EXTERNAL_DEPENDENCY "${options}" "${oneValueArgs}" "" ${ARGN} )
	if(DECLARE_PID_EXTERNAL_DEPENDENCY_PACKAGE
		AND DECLARE_PID_EXTERNAL_DEPENDENCY_EXTERNAL) #if all keyword used
		if(NOT ${DECLARE_PID_EXTERNAL_DEPENDENCY_PACKAGE}_DECLARED)#target external package has not been declared as a dependency
			message("[PID] WARNING: Bad usage of function declare_PID_External_Package_Dependency: package ${DECLARE_PID_EXTERNAL_DEPENDENCY_PACKAGE} is unknown. Use macro declare_PID_External_Package to declare it")
			return() #return will exit from current Use file included (because we are in a macro)
		endif()
		set(package ${DECLARE_PID_EXTERNAL_DEPENDENCY_PACKAGE})
		set(dependency ${DECLARE_PID_EXTERNAL_DEPENDENCY_EXTERNAL})

		get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
		set(${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} ${${package}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}} ${dependency} CACHE INTERNAL "")

		if(NOT DECLARE_PID_EXTERNAL_DEPENDENCY_VERSION)
			if(DECLARE_PID_DEPENDENCY_EXTERNAL_EXACT)
				message("[PID] WARNING: Bad usage of function declare_PID_External_Package_Dependency: use EXACT keyword only if a version is defined.")
				return() #return will exit from current Use file included (because we are in a macro)
			endif()
			set(${package}_EXTERNAL_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX} CACHE INTERNAL "")
			set(${package}_EXTERNAL_DEPENDENCY_${dependency}_VERSION_EXACT${VAR_SUFFIX} FALSE CACHE INTERNAL "")

		else()
			if(DECLARE_PID_DEPENDENCY_EXTERNAL_EXACT)
				set(exact TRUE)
			else()
				set(exact FALSE)
			endif()
			if(NOT ${package}_EXTERNAL_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX})
				set(${package}_EXTERNAL_DEPENDENCY_${dependency}_VERSION${VAR_SUFFIX} ${DECLARE_PID_EXTERNAL_DEPENDENCY_VERSION} CACHE INTERNAL "")
				set(${package}_EXTERNAL_DEPENDENCY_${dependency}_VERSION_EXACT${VAR_SUFFIX} ${exact} CACHE INTERNAL "")
			else()
					message("[PID] WARNING: Bad usage of function declare_PID_External_Package_Dependency: package ${package} already declares a dependency to external package ${dependency} with version ${DECLARE_PID_EXTERNAL_DEPENDENCY_VERSION} has already been defined !")
					return() #return will exit from current Use file included (because we are in a macro)
			endif()
		endif()
	else()
		message("[PID] WARNING: Bad usage of function declare_PID_External_Package_Dependency: PACKAGE (value: ${package}) and EXTERNAL (value: ${dependency}) keywords must be used !")
		return() #return will exit from current Use file included (because we are in a macro)
	endif()
endmacro(declare_PID_External_Package_Dependency)

### API: used to describe a component inside and external package
macro(declare_PID_External_Component)
	set(options)
	set(oneValueArgs PACKAGE COMPONENT C_STANDARD CXX_STANDARD)
	set(multiValueArgs INCLUDES STATIC_LINKS SHARED_LINKS DEFINITIONS RUNTIME_RESOURCES COMPILER_OPTIONS)

	cmake_parse_arguments(DECLARE_PID_EXTERNAL_COMPONENT "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	if(NOT DECLARE_PID_EXTERNAL_COMPONENT_PACKAGE OR NOT DECLARE_PID_EXTERNAL_COMPONENT_COMPONENT)
		message("[PID] WARNING: Bad usage of function declare_PID_External_Component: you must define the PACKAGE (value: ${DECLARE_PID_EXTERNAL_COMPONENT_PACKAGE}) and the name of the component using COMPONENT keyword (value: ${DECLARE_PID_EXTERNAL_COMPONENT_COMPONENT}).")
		return()#return will exit from current Use file included (because we are in a macro)
	endif()
	if(NOT ${DECLARE_PID_EXTERNAL_COMPONENT_PACKAGE}_DECLARED)
		message("[PID] WARNING: Bad usage of function declare_PID_External_Component: package ${DECLARE_PID_EXTERNAL_COMPONENT_PACKAGE} is unknown. Use macro declare_PID_External_Package to declare it")
		return() #return will exit from current Use file included (because we are in a macro)
	endif()
	set(curr_ext_package ${DECLARE_PID_EXTERNAL_COMPONENT_PACKAGE})
	set(curr_ext_comp ${DECLARE_PID_EXTERNAL_COMPONENT_COMPONENT})
	set(comps_list ${${curr_ext_package}_COMPONENTS${VAR_SUFFIX}} ${curr_ext_comp})
	list(REMOVE_DUPLICATES comps_list)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
	set(${curr_ext_package}_COMPONENTS${VAR_SUFFIX} ${comps_list} CACHE INTERNAL "")

	#manage include folders
	set(incs)
	if(DECLARE_PID_EXTERNAL_COMPONENT_INCLUDES)
		foreach(an_include IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_INCLUDES})
			if(an_include MATCHES "^(<${curr_ext_package}>|/).*")
				list(APPEND incs ${an_include})
			else()#if the string DOES NOT start with a / (absolute path), a <package> (relative path from package root) then we add the header <package> to the path
				list(APPEND incs "<${curr_ext_package}>/${an_include}")# prepend the external package name
			endif()
		endforeach()
	endif()
	if(incs)
		list(REMOVE_DUPLICATES incs)
		set(${curr_ext_package}_${curr_ext_comp}_INC_DIRS${VAR_SUFFIX} ${incs} CACHE INTERNAL "")
	endif()
	#manage compile options
	set(${curr_ext_package}_${curr_ext_comp}_OPTS${VAR_SUFFIX} ${DECLARE_PID_EXTERNAL_COMPONENT_COMPILER_OPTIONS} CACHE INTERNAL "")
	#manage definitions
	set(${curr_ext_package}_${curr_ext_comp}_DEFS${VAR_SUFFIX} ${DECLARE_PID_EXTERNAL_COMPONENT_DEFINITIONS} CACHE INTERNAL "")

	#manage C standard in USE
	if(DECLARE_PID_EXTERNAL_COMPONENT_C_STANDARD)
		set(c_language_standard ${DECLARE_PID_EXTERNAL_COMPONENT_C_STANDARD})
		if(	NOT c_language_standard EQUAL 90
		AND NOT c_language_standard EQUAL 99
		AND NOT c_language_standard EQUAL 11)
			message("[PID] ERROR : bad C_STANDARD argument for component ${curr_ext_comp} from external package ${curr_ext_package}, the value used must be 90, 99 or 11.")
		endif()
	else() #default language standard is first standard
		set(c_language_standard 90)
	endif()
	set(${curr_ext_package}_${curr_ext_comp}_C_STANDARD${VAR_SUFFIX} ${c_language_standard} CACHE INTERNAL "")

	if(DECLARE_PID_EXTERNAL_COMPONENT_CXX_STANDARD)
		set(cxx_language_standard ${DECLARE_PID_EXTERNAL_COMPONENT_CXX_STANDARD})
		if(	NOT cxx_language_standard EQUAL 98
		AND NOT cxx_language_standard EQUAL 11
		AND NOT cxx_language_standard EQUAL 14
		AND NOT cxx_language_standard EQUAL 17 )
		message(FATAL_ERROR "[PID] ERROR : bad CXX_STANDARD argument for component ${curr_ext_comp} from external package ${curr_ext_package}, the value used must be 98, 11, 14 or 17.")
		endif()
	else() #default language standard is first standard
		set(cxx_language_standard 98)
	endif()
	#manage definitions
	set(${curr_ext_package}_${curr_ext_comp}_CXX_STANDARD${VAR_SUFFIX} ${cxx_language_standard} CACHE INTERNAL "")

	#manage links
	set(links)
	if(DECLARE_PID_EXTERNAL_COMPONENT_STATIC_LINKS)
		foreach(a_link IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_STATIC_LINKS})
			#if the string DOES NOT start with a / (absolute path), a <package> (relative path from package root) or - (link option specification) then we add the header <package>
			if(a_link MATCHES  "^(<${curr_ext_package}>|/|-).*")
				list(APPEND links ${a_link})
			else()
				list(APPEND links "<${curr_ext_package}>/${a_link}")# prepend the external package name
			endif()
		endforeach()
	endif()
	if(links)
		list(REMOVE_DUPLICATES links)
		set(${curr_ext_package}_${curr_ext_comp}_STATIC_LINKS${VAR_SUFFIX} ${links} CACHE INTERNAL "")
	endif()

	#manage shared links
	set(links)
	if(DECLARE_PID_EXTERNAL_COMPONENT_SHARED_LINKS)
		foreach(a_link IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_SHARED_LINKS})
			#if the string DOES NOT start with a / (absolute path), a <package> (relative path from package root) or - (link option specification) then we add the header <package>
			if(a_link MATCHES  "^(<${curr_ext_package}>|/|-).*")
				list(APPEND links ${a_link})
			else()
				list(APPEND links "<${curr_ext_package}>/${a_link}")# prepend the external package name
			endif()
		endforeach()
	endif()
	if(links)
		list(REMOVE_DUPLICATES links)
		set(${curr_ext_package}_${curr_ext_comp}_SHARED_LINKS${VAR_SUFFIX} ${links} CACHE INTERNAL "")
	endif()


	#manage runtime resources
	set(resources)
	if(DECLARE_PID_EXTERNAL_COMPONENT_RUNTIME_RESOURCES)
		foreach(a_resource IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_RUNTIME_RESOURCES})
			if(a_resource MATCHES "^<${curr_ext_package}>")
				list(APPEND resources ${a_resource})
			else()
				list(APPEND resources "<${curr_ext_package}>/${a_resource}")# prepend the external package name
			endif()
		endforeach()
	endif()
	if(resources)
		list(REMOVE_DUPLICATES links)
		set(${curr_ext_package}_${curr_ext_comp}_RUNTIME_RESOURCES${VAR_SUFFIX} ${resources} CACHE INTERNAL "")
	endif()
endmacro(declare_PID_External_Component)

### declare_PID_External_Component_Dependency (PACKAGE current COMPONENT curr_comp [DEPENDS or EXPORT other] comp EXTERNAL other ext pack)
### EXTERNAL may be not used if the dependency is INTERNAL to the external package
### if EXTERNAL is used it may be use with a component name (using EXPORT or DEPENDS) or without (and so will directly use keywords: INCLUDES LINKS DEFINITIONS RUNTIME_RESOURCES COMPILER_OPTIONS)
macro(declare_PID_External_Component_Dependency)
	set(options)
	set(oneValueArgs PACKAGE COMPONENT EXTERNAL EXPORT USE)
	set(multiValueArgs INCLUDES STATIC_LINKS SHARED_LINKS DEFINITIONS RUNTIME_RESOURCES COMPILER_OPTIONS)
	cmake_parse_arguments(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
	if(NOT DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_PACKAGE OR NOT DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_COMPONENT)
		message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: you must define the PACKAGE (value: ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_PACKAGE}) and the name of the component using COMPONENT keyword (value: ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_COMPONENT}).")
		return()
	endif()
	if(NOT ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_PACKAGE}_DECLARED)
		message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: package ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_PACKAGE} is unknown. Use macro declare_PID_External_Package to declare it")
		return() #return will exit from current Use file included (because we are in a macro)
	endif()
	set(LOCAL_PACKAGE ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_PACKAGE})
	set(LOCAL_COMPONENT ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_COMPONENT})
	set(TARGET_COMPONENT)
	set(EXPORT_TARGET FALSE)

	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})
	#checking that the component is defined locally
	list(FIND ${LOCAL_PACKAGE}_COMPONENTS${VAR_SUFFIX} ${LOCAL_COMPONENT} INDEX)
	if(INDEX EQUAL -1)
		message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: external package ${LOCAL_PACKAGE} does not define component ${LOCAL_COMPONENT}.")
		return()
	endif()

	#configuraing target package
	if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXTERNAL)
		list(FIND ${LOCAL_PACKAGE}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXTERNAL} INDEX)
		if(INDEX EQUAL -1)
			# the external package is using the dependent package
			message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: external package ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXTERNAL} is not defined as a dependency of external package ${LOCAL_PACKAGE}.")
			return()
		endif()
		set(TARGET_PACKAGE ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXTERNAL})
		#in that case a component is not mandatory defined we can just target the libraries inside the depdendency packages
	else() #if not an external component it means it is an internal one
		#in that case the component must be defined
		set(TARGET_PACKAGE)#internal means the local is the dependency
	endif()

	#configuring target component
	if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_USE)
		if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXPORT)
			message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: in package ${LOCAL_PACKAGE} you must use either USE OR EXPORT keywords not both.")
			return()
		endif()
		set(TARGET_COMPONENT ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_USE})
	elseif(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXPORT)
		set(TARGET_COMPONENT ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_EXPORT})
		set(EXPORT_TARGET TRUE)
	endif()

	if(TARGET_COMPONENT AND NOT TARGET_PACKAGE) #this is a link to a component locally defined
		list(FIND ${LOCAL_PACKAGE}_COMPONENTS${VAR_SUFFIX} ${TARGET_COMPONENT} INDEX)
		if(INDEX EQUAL -1)
			message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: external package ${LOCAL_PACKAGE} does not define component ${TARGET_COMPONENT} used as a dependency for ${LOCAL_COMPONENT}.")
			return()
		endif()
	endif()

	# more checks
	if(TARGET_COMPONENT)
		if(NOT TARGET_PACKAGE)
			set(list_of_comps ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_INTERNAL_DEPENDENCIES${VAR_SUFFIX}} ${TARGET_COMPONENT})
			list(REMOVE_DUPLICATES list_of_comps)
			set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_INTERNAL_DEPENDENCIES${VAR_SUFFIX} ${list_of_comps} CACHE INTERNAL "")
			set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_INTERNAL_EXPORT_${TARGET_COMPONENT}${VAR_SUFFIX} ${EXPORT_TARGET} CACHE INTERNAL "")
		else()
			set(list_of_deps ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}} ${TARGET_PACKAGE})
			list(REMOVE_DUPLICATES list_of_deps)
			set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} ${list_of_deps} CACHE INTERNAL "")
			set(list_of_comps ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_DEPENDENCY_${TARGET_PACKAGE}_COMPONENTS${VAR_SUFFIX}} ${TARGET_COMPONENT})
			list(REMOVE_DUPLICATES list_of_comps)
			set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_DEPENDENCY_${TARGET_PACKAGE}_COMPONENTS${VAR_SUFFIX} ${list_of_comps} CACHE INTERNAL "")
			set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_EXPORT_${TARGET_PACKAGE}_${TARGET_COMPONENT}${VAR_SUFFIX} ${EXPORT_TARGET} CACHE INTERNAL "")
		endif()
	else() #otherwise this is a direct reference to external package content
		set(list_of_deps ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX}} ${TARGET_PACKAGE})
		list(REMOVE_DUPLICATES list_of_deps)
		set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX} ${list_of_deps} CACHE INTERNAL "")
		#this previous line is used to tell the system that path inside this component's variables have to be resolved again that external package
		if(NOT TARGET_PACKAGE) #check that we really target an external package
			message("[PID] WARNING: Bad usage of function declare_PID_External_Component_Dependency: a target external package name must be defined when a component dependency is defined with no target component (use the EXTERNAL KEYWORD).")
			return()
		endif()
	endif()

#manage include folders
if(TARGET_PACKAGE AND NOT TARGET_COMPONENT) #if a target package is specified but not a component
	set(incs ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_INC_DIRS${VAR_SUFFIX}})
	if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_INCLUDES)
		foreach(an_include IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_INCLUDES})
			if(an_include MATCHES "^(<${TARGET_PACKAGE}>|/).*")
				list(APPEND incs ${an_include})
			else()
				list(APPEND incs "<${TARGET_PACKAGE}>/${an_include}")# prepend the external package name
			endif()
		endforeach()
		list(REMOVE_DUPLICATES incs)
	endif()
	set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_INC_DIRS${VAR_SUFFIX} ${incs} CACHE INTERNAL "")

	#manage compile options
	set(opts ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_OPTS${VAR_SUFFIX}} ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_COMPILER_OPTIONS})
	if(opts)
		list(REMOVE_DUPLICATES opts)
	endif()
	set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_OPTS${VAR_SUFFIX} ${opts} CACHE INTERNAL "")
	#manage definitions
	set(defs ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_DEFS${VAR_SUFFIX}} ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_DEFINITIONS})
	if(defs)
		list(REMOVE_DUPLICATES defs)
	endif()
	set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_DEFS${VAR_SUFFIX} ${defs} CACHE INTERNAL "")
	#manage links
	set(links ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_STATIC_LINKS${VAR_SUFFIX}})
	if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_STATIC_LINKS)
		foreach(a_link IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_STATIC_LINKS})
			if(a_link MATCHES  "^(<${TARGET_PACKAGE}>|/|-).*")
				list(APPEND links ${a_link})
			else()
				list(APPEND links "<${TARGET_PACKAGE}>/${a_link}")# prepend the external package name
			endif()
		endforeach()
		list(REMOVE_DUPLICATES links)
	endif()
	set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_STATIC_LINKS${VAR_SUFFIX} ${links} CACHE INTERNAL "")

	#manage shared links
	set(links ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_SHARED_LINKS${VAR_SUFFIX}})
	if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_SHARED_LINKS)
		foreach(a_link IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_SHARED_LINKS})
			if(a_link MATCHES  "^(<${TARGET_PACKAGE}>|/|-).*")
				list(APPEND links ${a_link})
			else()
				list(APPEND links "<${TARGET_PACKAGE}>/${a_link}")# prepend the external package name
			endif()
		endforeach()
		list(REMOVE_DUPLICATES links)
	endif()
	set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_SHARED_LINKS${VAR_SUFFIX} ${links} CACHE INTERNAL "")

	#manage runtime resources
	set(resources ${${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_RUNTIME_RESOURCES${VAR_SUFFIX}})
	if(DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_RUNTIME_RESOURCES)
		foreach(a_resource IN ITEMS ${DECLARE_PID_EXTERNAL_COMPONENT_DEPENDENCY_RUNTIME_RESOURCES})
			if(a_resource MATCHES "^<${TARGET_PACKAGE}>")
				list(APPEND resources ${a_resource})
			else()
				list(APPEND resources "<${TARGET_PACKAGE}>/${a_resource}")# prepend the external package name
			endif()
		endforeach()
		list(REMOVE_DUPLICATES resources)
	endif()
	set(${LOCAL_PACKAGE}_${LOCAL_COMPONENT}_RUNTIME_RESOURCES${VAR_SUFFIX} ${resources} CACHE INTERNAL "")
endif()
endmacro(declare_PID_External_Component_Dependency)
