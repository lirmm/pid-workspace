
#######################################################################################################
############# variable générées par les fonctions génériques à partir des infos de ce fichier #########
############# utile uniquement pour l'utilisateur du package ##########################################
#######################################################################################################
#attention ICI ce sont des PATH complets !!!!

# XXX_YYY_INCLUDE_DIRS			# tous les paths à utiliser pour que le composant marche
# XXX_YYY_DEFINITIONS			# toutes les definitions à utiliser pour que le composant marche
# XXX_YYY_LIBRARIES			# toutes les libraries à utiliser pour que le composant marche
# XXX_YYY_APPS				# tous les executables à trouver pour que le composant marche

# pour un composant application uniquement
# XXX_YYY_EXECUTABLE			# path vers l'exécutable correspondant au composant


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
	set(${package}_${component}_LIBRARIES ${component} CACHE INTERNAL "")
endmacro(update_Config_Application package component)


###
macro (set_Config_Application package component)
	set(${package}_${component}_EXECUTABLE ${component} CACHE INTERNAL "")
	set(${package}_${component}_APPS ${component} CACHE INTERNAL "")
endmacro(update_Config_Application package component)


##################################################################################
##################end auxiliary functions fill exported variables ################
##################################################################################



##################################################################################
##################################  main script  #################################
##################################################################################

#TODO virer le type "COMPLETE" qui va foutre la merde PARTOUT (MAIS PERMETTRE à l'UTILISATEUR de définir les 2 composants d'un coup) 
#first step append to global variables the path to local components
foreach(a_component IN ITEMS ${${PACKAGE_TO_CONFIG}_COMPONENTS})
	
	if(${${PACKAGE_TO_CONFIG}_${a_component}_TYPE} STREQUAL "SHARED")
		update_Config_Include_Dirs(${PACKAGE_TO_CONFIG} ${a_component} ${PATH_TO_PACKAGE_VERSION}/include)	
		if(${${PACKAGE_TO_CONFIG}_${a_component}_DEFS}) #if library defines exported definitions
			update_Config_Definitions(${PACKAGE_TO_CONFIG} ${a_component} ${${PACKAGE_TO_CONFIG}_${a_component}_DEFS})
		endif(${${PACKAGE_TO_CONFIG}_${a_component}_DEFS})
		update_Config_Library(${PACKAGE_TO_CONFIG} ${a_component} ${PATH_TO_PACKAGE_VERSION}/lib/${a_component})
	
	elseif(${${PACKAGE_TO_CONFIG}_${a_component}_TYPE} STREQUAL "STATIC")
		update_Config_Include_Dirs(${PACKAGE_TO_CONFIG} ${a_component} ${PATH_TO_PACKAGE_VERSION}/include)	
		if(${${PACKAGE_TO_CONFIG}_${a_component}_DEFS}) #if library defines exported definitions
			update_Config_Definitions(${PACKAGE_TO_CONFIG} ${a_component} ${${PACKAGE_TO_CONFIG}_${a_component}_DEFS})
		endif(${${PACKAGE_TO_CONFIG}_${a_component}_DEFS})
		update_Config_Library(${PACKAGE_TO_CONFIG} ${a_component} ${PATH_TO_PACKAGE_VERSION}/lib/${a_component})

	elseif(${${PACKAGE_TO_CONFIG}_${a_component}_TYPE} STREQUAL "HEADER")
		update_Config_Include_Dirs(${PACKAGE_TO_CONFIG} ${a_component} ${PATH_TO_PACKAGE_VERSION}/include)	
		if(${${PACKAGE_TO_CONFIG}_${a_component}_DEFS}) #if library defines exported definitions
			update_Config_Definitions(${PACKAGE_TO_CONFIG} ${a_component} ${${PACKAGE_TO_CONFIG}_${a_component}_DEFS})
		endif(${${PACKAGE_TO_CONFIG}_${a_component}_DEFS})
		#no targets so nothing to update		
	elseif(${${PACKAGE_TO_CONFIG}_${a_component}_TYPE} STREQUAL "APP")
		update_Config_Application(${PACKAGE_TO_CONFIG} ${a_component})
	endif()
	
endforeach()

#second step : managing dependencies i.e.
# 1) find_package des packages utilisés par le package -> appel récursif !!!!!!!!!!!!!!!!!!!
# 2) affectation des variables en fonction des dépendences
#3) 


