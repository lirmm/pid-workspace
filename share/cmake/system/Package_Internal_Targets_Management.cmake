
### configure the target with exported flags (cflags and ldflags)
function(manage_Additional_Component_Exported_Flags component_name inc_dirs defs links)
#message("manage_Additional_Component_Exported_Flags comp=${component_name} include dirs=${inc_dirs} defs=${defs} links=${links}")
# managing compile time flags (-I<path>)
if(inc_dirs AND NOT inc_dirs STREQUAL "")
	foreach(dir IN ITEMS ${inc_dirs})
		target_include_directories(${component_name}${INSTALL_NAME_SUFFIX} PUBLIC "${dir}")
	endforeach()
endif()

# managing compile time flags (-D<preprocessor_defs>)
if(defs AND NOT defs STREQUAL "")
	foreach(def IN ITEMS ${defs})
		target_compile_definitions(${component_name}${INSTALL_NAME_SUFFIX} PUBLIC "${def}")
	endforeach()
endif()

# managing link time flags
if(links AND NOT links STREQUAL "")
	foreach(link IN ITEMS ${links})
		target_link_libraries(${component_name}${INSTALL_NAME_SUFFIX} ${link})
	endforeach()
endif()
endfunction(manage_Additional_Component_Exported_Flags)


### configure the target with internal flags (cflags only)
function(manage_Additional_Component_Internal_Flags component_name inc_dirs defs)
#message("manage_Additional_Component_Internal_Flags name=${component_name} include dirs=${inc_dirs} defs=${defs}")
# managing compile time flags
if(inc_dirs AND NOT inc_dirs STREQUAL "")
	foreach(dir IN ITEMS ${inc_dirs})
		target_include_directories(${component_name}${INSTALL_NAME_SUFFIX} PRIVATE "${dir}")
	endforeach()
endif()

# managing compile time flags
if(defs AND NOT defs STREQUAL "")
	foreach(def IN ITEMS ${defs})
		target_compile_definitions(${component_name}${INSTALL_NAME_SUFFIX} PRIVATE "${def}")
	endforeach()
endif()
endfunction(manage_Additional_Component_Internal_Flags)

function(manage_Additionnal_Component_Inherited_Flags component dep_component export)
	if(export)
		set(export_string "PUBLIC")
	else()
		set(export_string "PRIVATE")
	endif()
	target_include_directories(	${component}${INSTALL_NAME_SUFFIX} 
					${export_string} 
					$<TARGET_PROPERTY:${dep_component}${INSTALL_NAME_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>
				)
	target_compile_definitions(	${component}${INSTALL_NAME_SUFFIX} 
					${export_string} 
					$<TARGET_PROPERTY:${dep_component}${INSTALL_NAME_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>
				)
endfunction(manage_Additionnal_Component_Inherited_Flags)

### configure the target to link with another target issued from a component of the same package
function (fill_Component_Target_With_Internal_Dependency component dep_component export comp_defs comp_exp_defs dep_defs)
is_Executable_Component(DEP_IS_EXEC ${PROJECT_NAME} ${dep_component})
if(NOT DEP_IS_EXEC)#the required internal component is a library 
	if(export)	
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_exp_defs} ${dep_defs})
		manage_Additional_Component_Internal_Flags(${component} "" "${comp_defs}")				
		manage_Additional_Component_Exported_Flags(${component} "" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${dep_component}${INSTALL_NAME_SUFFIX}")
		manage_Additionnal_Component_Inherited_Flags(${component} ${dep_component} TRUE)		
	else()
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${dep_defs})
		manage_Additional_Component_Internal_Flags(${component} "" "${${PROJECT_NAME}_${component}_TEMP_DEFS}")
		manage_Additional_Component_Exported_Flags(${component} "" "${comp_exp_defs}" "${dep_component}${INSTALL_NAME_SUFFIX}")
		manage_Additionnal_Component_Inherited_Flags(${component} ${dep_component} FALSE)
	endif()
else()
	message(FATAL_ERROR "Executable component ${dep_c_name} cannot be a dependency for component ${component}")	
endif()

endfunction(fill_Component_Target_With_Internal_Dependency)


### configure the target to link with another component issued from another package
function (fill_Component_Target_With_Package_Dependency component dep_package dep_component export comp_defs comp_exp_defs dep_defs)
#message("DEBUG fill_Component_Target_With_Package_Dependency component=${component} dep_package=${dep_package} dep_component=${dep_component} export=${export} comp_defs=${comp_defs} comp_exp_defs=${comp_exp_defs} dep_defs=${dep_defs}")
is_Executable_Component(DEP_IS_EXEC ${dep_package} ${dep_component})
if(NOT DEP_IS_EXEC)#the required package component is a library
	
	if(export)
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_exp_defs} ${dep_defs})

		if(${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX})
			list(APPEND ${PROJECT_NAME}_${component}_TEMP_DEFS ${${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX}})
		endif()		
		manage_Additional_Component_Internal_Flags(${component} "" "${comp_defs}")
		manage_Additional_Component_Exported_Flags(${component} "${${dep_package}_${dep_component}_INCLUDE_DIRS${USE_MODE_SUFFIX}}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${${dep_package}_${dep_component}_LIBRARIES${USE_MODE_SUFFIX}}")
	else()
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${dep_defs})
		if(${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX})
			list(APPEND ${PROJECT_NAME}_${component}_TEMP_DEFS ${${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX}})
		endif()		
		manage_Additional_Component_Internal_Flags(${component} "${${dep_package}_${dep_component}_INCLUDE_DIRS${USE_MODE_SUFFIX}}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}")
		manage_Additional_Component_Exported_Flags(${component} "" "${comp_exp_defs}" "${${dep_package}_${dep_component}_LIBRARIES${USE_MODE_SUFFIX}}")
	endif()

else()
	message(FATAL_ERROR "Executable component ${dep_component} from package ${dep_package} cannot be a dependency for component ${component}")	
endif()
endfunction(fill_Component_Target_With_Package_Dependency)


### configure the target to link with an external dependancy
function(fill_Component_Target_With_External_Dependency component export comp_defs comp_exp_defs ext_defs ext_inc_dirs ext_links)
if(ext_links)
	resolve_External_Libs_Path(COMPLETE_LINKS_PATH ${PROJECT_NAME} "${ext_links}" ${CMAKE_BUILD_TYPE})
endif()
if(ext_inc_dirs)
	resolve_External_Includes_Path(COMPLETE_INCLUDES_PATH ${PROJECT_NAME} "${ext_inc_dirs}" ${CMAKE_BUILD_TYPE})
endif()

# setting compile/linkage definitions for the component target
if(export)
	set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_exp_defs} ${ext_defs})
	manage_Additional_Component_Internal_Flags(${component} "" "${comp_defs}")
	manage_Additional_Component_Exported_Flags(${component} "${COMPLETE_INCLUDES_PATH}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${COMPLETE_LINKS_PATH}")

else()
	set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${ext_defs})		
	manage_Additional_Component_Internal_Flags(${component} "${COMPLETE_INCLUDES_PATH}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}")
	manage_Additional_Component_Exported_Flags(${component} "" "${comp_exp_defs}" "${COMPLETE_LINKS_PATH}")
endif()

endfunction(fill_Component_Target_With_External_Dependency)


