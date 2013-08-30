
#######################################################################################################
############# variable générées par les fonctions génériques à partir des infos de ce fichier #########
############# utile uniquement pour l'utilisateur du package ##########################################
#######################################################################################################
#attention ICI ce sont des PATH complets !!!!

# XXX_YYY_INCLUDE_DIRS			# tous les paths à utiliser pour que le composant marche
# XXX_YYY_DEFINITIONS			# toutes les definitions à utiliser pour que le composant marche
# XXX_YYY_LIBRARIES			# toutes les libraries à utiliser pour que le composant marche
# XXX_YYY_APPS				# tous les executables à trouver pour que le composant marche
# XXX_YYY_RUNTIME_LIBRARY_DIRS		# tous les répertoires dans lesquels aller chercher les lib dynamiques pour que le composant marche

# pour un composant application uniquement
# XXX_YYY_EXECUTABLE			# path vers l'exécutable correspondant au composant

##################################################################################
##################    auxiliary functions for utility purposes ###################
##################################################################################

macro(test_Package_Location package dependency)
	if(NOT ${${dependency}_FOUND})

		if(${${package}_DEPENDANCY_${dependency}_VERSION} STREQUAL "")
			message(SEND_ERROR "The required package ${a_dependency} has not been found !")
		elseif(${${package}_DEPENDANCY_${dependency}_VERSION_EXACT})
			message(SEND_ERROR "The required package ${a_dependency} with exact version ${${package}_DEPENDANCY_${dependency}_VERSION} has not been found !")
		else()
			message(SEND_ERROR "The required package ${a_dependency} with version compatible with ${${package}_DEPENDANCY_${dependency}_VERSION} has not been found !")
		endif()
		list(APPEND ${package}_DEPENDANCIES_NOTFOUND ${dependency})
	endif()
endmacro()

###
# each dependent package version is defined as ${package_name}_DEPENDENCY_${a_dependency}_VERSION
# other variables set by the package version use file 
# ${package_name}_DEPENDANCY_${a_dependency}_REQUIRED		# TRUE if package is required FALSE otherwise (QUIET MODE)
# ${package_name}_DEPENDANCY_${a_dependency}_VERSION		# version if a version if specified
# ${package_name}_DEPENDENCY_${a_dependency}_VERSION_EXACT		# TRUE if exact version is required
# ${package_name}_DEPENDENCY_${a_dependency}_COMPONENTS		# list of components
macro(locate_Package package dependency)

	if(	NOT ${${package}_DEPENDANCY_${dependency}_VERSION} STREQUAL ""
		AND ${${package}_DEPENDENCY_${dependency}_VERSION_EXACT}) #an exact version has been specified
		set(${package}_DEPENDANCY_${dependency}_VERSION_EXACT_STRING "EXACT")	
	endif()

	#WARNING recursive call to find package
	find_package(
			${dependency} 
			${${package}_DEPENDANCY_${dependency}_VERSION} 
			${${package}_DEPENDANCY_${dependency}_VERSION_EXACT_STRING}
			MODULE
			"REQUIRED"
			${${package}_DEPENDENCY_${dependency}_COMPONENTS}
		)
	test_Package_Location(${package} ${dependency})

endmacro()

##################################################################################
##################end auxiliary functions for utility purposes ###################
##################################################################################


##################################################################################
##################    auxiliary functions fill exported variables ################
##################################################################################



###
macro (update_Config_Include_Dirs package component path)
	set(${package}_${component}_INCLUDE_DIRS ${${package}_${component}_INCLUDE_DIRS};${path} CACHE INTERNAL "")
endmacro(update_Config_Include_Dirs package component path)

###
macro (update_Config_Definitions package component defs)
	set(${package}_${component}_DEFINITIONS ${${package}_${component}_DEFINITIONS};${defs} CACHE INTERNAL "")
endmacro(update_Config_Definitions package component path)

###
macro (update_Config_Library package component)
	set(${package}_${component}_LIBRARIES ${${package}_${component}_LIBRARIES};${component} CACHE INTERNAL "")
endmacro(update_Config_Application package component)


###
macro (set_Config_Application package component)
	
endmacro(update_Config_Application package component)

###
macro (init_Component_Variables package component path_to_version )
	set(${package}_${component}_INCLUDE_DIRS "" CACHE INTERNAL "")
	set(${package}_${component}_DEFINITIONS "" CACHE INTERNAL "")
	set(${package}_${component}_DEFINITIONS_DEBUG "" CACHE INTERNAL "")
	set(${package}_${component}_LIBRARIES "" CACHE INTERNAL "")
	set(${package}_${component}_LIBRARIES_DEBUG "" CACHE INTERNAL "")
	set(${package}_${component}_EXECUTABLE "" CACHE INTERNAL "")
	set(${package}_${component}_EXECUTABLE_DEBUG "" CACHE INTERNAL "")
	
	if(${${package}_${component}_TYPE} STREQUAL "SHARED" OR ${${package}_${component}_TYPE} STREQUAL "STATIC")
		#exported include dirs (cflags -I<path>)
		set(${package}_${component}_INCLUDE_DIRS "${path_to_version}/include/${${package}_${component}_HEADER_DIR_NAME}" CACHE INTERNAL "")
		#exported additionnal cflags
		if(${${package}_${component}_DEFS}) 	
			set(${package}_${component}_DEFINITIONS ${${package}_${component}_DEFS} CACHE INTERNAL "")
		endif()
		if(${${package}_${component}_DEFS_DEBUG})	
			set(${package}_${component}_DEFINITIONS_DEBUG ${${package}_${component}_DEFS_DEBUG} CACHE INTERNAL "")
		endif()

		#exported library (ldflags -l<path>)
				

		#exported additionnal ld flags
		if(${${package}_${component}_LINKS})
			set(${package}_${component}_LIBRARIES ${${package}_${component}_LIBRARIES};${${package}_${component}_LINKS} CACHE INTERNAL "")
		endif()
		if(${${package}_${component}_LINKS_DEBUG})	
			set(${package}_${component}_LIBRARIES_DEBUG ${${package}_${component}_LIBRARIES_DEBUG};${${package}_${component}_LINKS_DEBUG} CACHE INTERNAL "")
		endif()
	elseif(${${package}_${component}_TYPE} STREQUAL "HEADER")
		#exported include dirs (cflags -I<path>)
		set(${package}_${component}_INCLUDE_DIRS "${path_to_version}/include/${${package}_${component}_HEADER_DIR_NAME}" CACHE INTERNAL "")
		#exported additionnal cflags
		if(${${package}_${component}_DEFS}) #if library defines exported definitions	
			set(${package}_${component}_DEFINITIONS ${${package}_${component}_DEFS} CACHE INTERNAL "")
		endif()
		if(${${package}_${component}_DEFS_DEBUG})	
			set(${package}_${component}_DEFINITIONS_DEBUG ${${package}_${component}_DEFS_DEBUG} CACHE INTERNAL "")
		endif()
		#no targets so nothing to update
		
	elseif(${${package}_${component}_TYPE} STREQUAL "APP")
		
		set(${package}_${component}_EXECUTABLE "${path_to_version}/bin/${${package}_${component}_BINARY_NAME}" CACHE INTERNAL "")
		set(${package}_${component}_EXECUTABLE_DEBUG "${path_to_version}/bin/${${package}_${component}_BINARY_NAME_DEBUG}" CACHE INTERNAL "")
	endif()

	
endmacro (init_Component_Variables package component)



##################################################################################
##################end auxiliary functions fill exported variables ################
##################################################################################



##################################################################################
##################################  main script  #################################
##################################################################################

#TODO virer le type "COMPLETE" qui va foutre la merde PARTOUT (MAIS PERMETTRE à l'UTILISATEUR de définir les 2 composants d'un coup) 
macro(configure_Package_Build_Variables package_name path_to_version)
#first step : initializing all build variable that are internal to each component
foreach(a_component IN ITEMS ${${package_name}_COMPONENTS})
	init_Component_Variables ${package_name} ${a_component} ${path_to_version})
endforeach()

#second step : managing dependencies i.e.
# the list of dependent packages is defined as ${package_name}_DEPENDENCIES

# locating dependent packages in the workspace
foreach(a_dependency IN ITEMS ${${package_name}_DEPENDENCIES}) 
	locate_Package(${${package_name} ${a_dependency})
endforeach()

if(${${package}_DEPENDANCIES_NOTFOUND ${dependency}})
	message(FATAL_ERROR "Some dependencies have not been found exitting")
	#TODO here managing the automatic installation of binay packages or git repo (if not exist)
endif()

# 2) affectation des variables en fonction des dépendences
foreach(a_component IN ITEMS ${${package_name}_COMPONENTS}) 
	foreach(a_package IN ITEMS ${${package_name}_${a_component}_DEPENDENCIES}) 
		foreach(a_dep_component IN ITEMS ${${package_name}_${a_component}_DEPENDANCY_${a_package}_COMPONENTS}) 
			
			
			
		endforeach()

	endforeach()		

endforeach()


# 3) 

endmacro(configure_Package_Build_Variables package_name)

