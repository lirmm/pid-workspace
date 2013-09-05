#############################################
#inutile car le INTERFACE_COMPILE_FLAGS n'existe pas
if(	${CMAKE_MAJOR_VERSION} EQUAL 2
	AND ${CMAKE_MINOR_VERSION} EQUAL 8
	AND NOT ${CMAKE_PATCH_VERSION} GREATER 10)#until this version target_include_directories and target_compie_definitions are not defined yet, the mode argument is just for compatibility with newer versions of cmake

function(target_include_directories target mode paths)
	get_target_property(MY_COMPILE_FLAGS ${target} COMPILE_FLAGS)
	if("${MY_COMPILE_FLAGS}" STREQUAL "MY_COMPILE_FLAGS-NOTFOUND")
		set(MY_COMPILE_FLAGS "")
	endif()
	message("current properties of ${target} are ${MY_COMPILE_FLAGS}")

	if(UNIX)
		foreach(IPATH ${paths})
		    set(MY_COMPILE_FLAGS "${MY_COMPILE_FLAGS} -I${IPATH}")
		endforeach()	
	elseif(WIN32)		
		foreach(IPATH ${paths})
		    set(MY_COMPILE_FLAGS "${MY_COMPILE_FLAGS} /I${IPATH}")
		endforeach()
	endif()
	message("before setting target properties my flags are : ${MY_COMPILE_FLAGS}")
	set_target_properties(	${target} 
				PROPERTIES COMPILE_FLAGS "${MY_COMPILE_FLAGS}")
endfunction()


function(target_compile_definitions target mode defs)
	get_target_property(MY_COMPILE_DEFS ${target} COMPILE_DEFINITIONS)
	if("${MY_COMPILE_DEFS}" STREQUAL "MY_COMPILE_DEFS-NOTFOUND")
		set(MY_COMPILE_DEFS "")
	endif()
	set(MY_COMPILE_DEFS "${MY_COMPILE_DEFS} ${defs}")
	set_target_properties(	${target}
				PROPERTIES COMPILE_DEFINITIONS "${MY_COMPILE_DEFS}")
endfunction()

endif()

############################################

function(resolve_Component_Exported_Configuration package component res_definitions res_include_dirs res_links)
	set(${res_definitions} "" PARENT_SCOPE)
	set(${res_include_dirs} "" PARENT_SCOPE)
	set(${res_links} "" PARENT_SCOPE)

	if(${package}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}) # the component has internal dependencies -> recursion
		foreach(a_int_dep IN ITEMS ${${package}_${component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}})
			#for each of its internal dependencies resolve (recursion)
			resolve_Component_Exported_Configuration(${package} ${a_int_dep} EXPORTED_DEFS EXPORTED_INCLUDE_DIRS EXPORTED_LINKS)
			if(${package}_${component}_INTERNAL_EXPORT_${a_int_dep}${USE_MODE_SUFFIX})
				list(APPEND ALL_EXPORTED_DEFS ${EXPORTED_DEFS})
				list(APPEND ALL_EXPORTED_DIRS ${EXPORTED_INCLUDE_DIRS})
			endif()
			list(APPEND ALL_EXPORTED_LINKS ${EXPORTED_LINKS})
		endforeach()
	endif()

	if(${package}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}) # the component has package dependencies -> recursion
		foreach(dep_package IN ITEMS ${${package}_${component}_DEPENDENCIES${USE_MODE_SUFFIX}})
			foreach(dep_component IN ITEMS ${${package}_${component}_DEPENDENCY_${dep_package}_COMPONENTS${USE_MODE_SUFFIX}})
				resolve_Component_Exported_Configuration(${dep_package} ${dep_component} EXPORTED_DEFS EXPORTED_INCLUDE_DIRS EXPORTED_LINKS)
				if(${package}_${component}_EXPORT_${dep_package}_${dep_component}${USE_MODE_SUFFIX})
					list(APPEND ALL_EXPORTED_DEFS ${EXPORTED_DEFS})
					list(APPEND ALL_EXPORTED_DIRS ${EXPORTED_INCLUDE_DIRS})
				endif()
				list(APPEND ALL_EXPORTED_LINKS ${EXPORTED_LINKS})
			endforeach()
		endforeach()
	endif()

	#managing system dependencies and own exported defs
 
	list(APPEND ALL_EXPORTED_DEFS ${${package}_${component}_DEFS${USE_MODE_SUFFIX}})
	list(APPEND ALL_EXPORTED_DIRS ${${package}_${component}_INC_DIRS${USE_MODE_SUFFIX}})
	list(APPEND ALL_EXPORTED_LINKS ${${package}_${component}_LINKS${USE_MODE_SUFFIX}})
	
	#individual info
	is_Executable_Component(IS_EXE_COMP ${package} ${component})
	if(NOT IS_EXE_COMP)#component is a library
		list(APPEND ALL_EXPORTED_DIRS ${CMAKE_SOURCE_DIR}/include/${${package}_${component}_HEADER_DIR_NAME})
	endif()
	#remove duplicates and return values
	if(ALL_EXPORTED_DEFS)
		list(REMOVE_DUPLICATES ALL_EXPORTED_DEFS)
	endif()
	if(ALL_EXPORTED_DIRS)	
		list(REMOVE_DUPLICATES ALL_EXPORTED_DIRS)
	endif()
	if(ALL_EXPORTED_LINKS)
		list(REMOVE_DUPLICATES ALL_EXPORTED_LINKS)
	endif()
	set(${res_definitions} "${ALL_EXPORTED_DEFS}" PARENT_SCOPE)
	set(${res_include_dirs} "${ALL_EXPORTED_DIRS}" PARENT_SCOPE)
	set(${res_links} "${ALL_EXPORTED_LINKS}" PARENT_SCOPE)

endfunction(resolve_Component_Exported_Configuration)

function(resolve_Components_Targets_Configuration)
set(COMPONENTS_TO_CHECK "")
if(${CMAKE_CURRENT_SOURCE_DIR} MATCHES src)
	set(COMPONENTS_TO_CHECK ${${PROJECT_NAME}_COMPONENTS_LIBS})
elseif(${CMAKE_CURRENT_SOURCE_DIR} MATCHES apps)
	set(COMPONENTS_TO_CHECK ${${PROJECT_NAME}_COMPONENTS_APPS})#all apps since tests have not been declared yet
elseif(${CMAKE_CURRENT_SOURCE_DIR} MATCHES test)
	foreach(a_test IN ITEMS ${${PROJECT_NAME}_COMPONENTS_APPS})
		if(${PROJECT_NAME}_${a_test}_TYPE STREQUAL "TEST")
			list(APPEND COMPONENTS_TO_CHECK ${a_test})
		endif()
	endforeach()
else()
	return()
endif()
if(NOT COMPONENTS_TO_CHECK)
	return()
endif()

message("!!!!!!!!!!!! COMPONENTS TO CHECK (2) = ${COMPONENTS_TO_CHECK}")

foreach(a_component IN ITEMS ${COMPONENTS_TO_CHECK})
	# only the internal dependencies can be not satisfied
	if(${PROJECT_NAME}_${a_component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}) # the component has internal dependencies
		foreach(a_int_dep IN ITEMS ${${PROJECT_NAME}_${a_component}_INTERNAL_DEPENDENCIES${USE_MODE_SUFFIX}})
			#for each of its internal dependencies resolve
			resolve_Component_Exported_Configuration(${PROJECT_NAME} ${a_int_dep} EXPORTED_DEFS EXPORTED_INCLUDE_DIRS EXPORTED_LINKS)  
			list(APPEND ALL_EXPORTED_DEFS ${EXPORTED_DEFS})
			list(APPEND ALL_EXPORTED_DIRS ${EXPORTED_INCLUDE_DIRS})
			list(APPEND ALL_EXPORTED_LINKS ${EXPORTED_LINKS})
		endforeach()
		if(ALL_EXPORTED_DEFS)
			list(REMOVE_DUPLICATES ALL_EXPORTED_DEFS)
		endif()
		if(ALL_EXPORTED_DIRS)	
			list(REMOVE_DUPLICATES ALL_EXPORTED_DIRS)
		endif()
		if(ALL_EXPORTED_LINKS)
			list(REMOVE_DUPLICATES ALL_EXPORTED_LINKS)
		endif()
		manage_Additional_Component_Exported_Flags(${a_component} "${ALL_EXPORTED_DIRS}" "${ALL_EXPORTED_DEFS}" "${ALL_EXPORTED_LINKS}")
	endif()
endforeach()
endfunction(resolve_Components_Targets_Configuration)

endif()


function(finalize_dependencies)
# resolve internal dependencies and configure targets adequately (this step is necessary before version 2.8.11 because there is now way to simply resolve targets include directories and compile definitions propagation between local targets)
if(	${CMAKE_MAJOR_VERSION} EQUAL 2
	AND ${CMAKE_MINOR_VERSION} EQUAL 8
	AND NOT ${CMAKE_PATCH_VERSION} GREATER 10)#until this version target_include_directories and target_compie_definitions are not defined yet, the mode argument is just for compatibility with newer versions of cmake

resolve_Components_Targets_Configuration()
endif()#otherwise the function is not useful so does nothing
endfunction(finalize_dependencies)



