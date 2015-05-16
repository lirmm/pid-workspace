############################################################################
############### API functions for internal targets management ##############
############################################################################

###create a module lib target for a newly defined library
function(create_Module_Lib_Target c_name sources internal_inc_dirs internal_defs internal_links)
	add_library(${c_name}${INSTALL_NAME_SUFFIX} MODULE ${sources})
	install(TARGETS ${c_name}${INSTALL_NAME_SUFFIX}
		LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}
	)
	#setting the default rpath for the target (rpath target a specific folder of the binary package for the installed version of the component)
	if(APPLE)
		set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_RPATH};@loader_path/../.rpath/${c_name}${INSTALL_NAME_SUFFIX}") #the library targets a specific folder that contains symbolic links to used shared libraries
	elseif(UNIX)
		set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_RPATH};\$ORIGIN/../.rpath/${c_name}${INSTALL_NAME_SUFFIX}") #the library targets a specific folder that contains symbolic links to used shared libraries
	endif()
	manage_Additional_Component_Internal_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${internal_inc_dirs}" "${internal_defs}" "${internal_links}")
endfunction(create_Module_Lib_Target)

###create a shared lib target for a newly defined library
function(create_Shared_Lib_Target c_name sources exported_inc_dirs internal_inc_dirs exported_defs internal_defs exported_links internal_links)
	add_library(${c_name}${INSTALL_NAME_SUFFIX} SHARED ${sources})
		
	install(TARGETS ${c_name}${INSTALL_NAME_SUFFIX}
		LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}
	)
	#setting the default rpath for the target (rpath target a specific folder of the binary package for the installed version of the component)
	if(APPLE)
		set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_RPATH};@loader_path/../.rpath/${c_name}${INSTALL_NAME_SUFFIX}") #the library targets a specific folder that contains symbolic links to used shared libraries
	elseif(UNIX)
		set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_RPATH};\$ORIGIN/../.rpath/${c_name}${INSTALL_NAME_SUFFIX}") #the library targets a specific folder that contains symbolic links to used shared libraries
	endif()

	manage_Additional_Component_Internal_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${internal_inc_dirs};${exported_inc_dirs}" "${internal_defs};${exported_defs}" "${exported_links};${internal_links}")
	manage_Additional_Component_Exported_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${exported_inc_dirs}" "${exported_defs}" "${exported_links}")
endfunction(create_Shared_Lib_Target)

###create a static lib target for a newly defined library
function(create_Static_Lib_Target c_name sources exported_inc_dirs internal_inc_dirs exported_defs internal_defs exported_links)
	add_library(${c_name}${INSTALL_NAME_SUFFIX} STATIC ${sources})
	install(TARGETS ${c_name}${INSTALL_NAME_SUFFIX}
		ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_AR_PATH}
	)
	manage_Additional_Component_Internal_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${internal_inc_dirs};${exported_inc_dirs}" "${internal_defs};${exported_defs}" "")#no linking with static libraries so do not manage internal_flags
	manage_Additional_Component_Exported_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${exported_inc_dirs}" "${exported_defs}" "${exported_links}")

endfunction(create_Static_Lib_Target)

###create a shared lib target for a newly defined library
function(create_Header_Lib_Target c_name exported_inc_dirs exported_defs exported_links)
	add_library(${c_name}${INSTALL_NAME_SUFFIX} INTERFACE)
	manage_Additional_Component_Exported_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${exported_inc_dirs}" "${exported_defs}" "${exported_links}")
endfunction(create_Header_Lib_Target)

###create an executable target for a newly defined application
function(create_Executable_Target c_name sources internal_inc_dirs internal_defs internal_links)
	add_executable(${c_name}${INSTALL_NAME_SUFFIX} ${sources})
	manage_Additional_Component_Internal_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${internal_inc_dirs}" "${internal_defs}" "${internal_links}")
	# adding the application to the list of installed components when make install is called (not for test applications)
	install(TARGETS ${c_name}${INSTALL_NAME_SUFFIX} 
		RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
	)
	#setting the default rpath for the target	
	if(APPLE)
		set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_RPATH};@loader_path/../.rpath/${c_name}${INSTALL_NAME_SUFFIX}") #the application targets a specific folder that contains symbolic links to used shared libraries
	elseif(UNIX)
		set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "${CMAKE_INSTALL_RPATH};\$ORIGIN/../.rpath/${c_name}${INSTALL_NAME_SUFFIX}") #the application targets a specific folder that contains symbolic links to used shared libraries
	endif()
endfunction(create_Executable_Target)

function(create_TestUnit_Target c_name sources internal_inc_dirs internal_defs internal_links)
	add_executable(${c_name}${INSTALL_NAME_SUFFIX} ${sources})
	manage_Additional_Component_Internal_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${internal_inc_dirs}" "${internal_defs}" "${internal_links}")
endfunction(create_TestUnit_Target)

### configure the target with exported flags (cflags and ldflags)
function(manage_Additional_Component_Exported_Flags component_name mode_suffix inc_dirs defs links)
#message("manage_Additional_Component_Exported_Flags comp=${component_name} include dirs=${inc_dirs} defs=${defs} links=${links}")
# managing compile time flags (-I<path>)
if(inc_dirs AND NOT inc_dirs STREQUAL "")
	foreach(dir IN ITEMS ${inc_dirs})
		target_include_directories(${component_name}${mode_suffix} INTERFACE "${dir}")
	endforeach()
endif()

# managing compile time flags (-D<preprocessor_defs>)
if(defs AND NOT defs STREQUAL "")
	foreach(def IN ITEMS ${defs})
		target_compile_definitions(${component_name}${mode_suffix} INTERFACE "${def}")
	endforeach()
endif()

# managing link time flags
if(links AND NOT links STREQUAL "")
	foreach(link IN ITEMS ${links})
		target_link_libraries(${component_name}${mode_suffix} INTERFACE ${link})
	endforeach()
endif()
endfunction(manage_Additional_Component_Exported_Flags)


### configure the target with internal flags (cflags only)
function(manage_Additional_Component_Internal_Flags component_name mode_suffix inc_dirs defs links)
# managing compile time flags
if(inc_dirs AND NOT inc_dirs STREQUAL "")
	foreach(dir IN ITEMS ${inc_dirs})
		target_include_directories(${component_name}${mode_suffix} PRIVATE "${dir}")
	endforeach()
endif()

# managing compile time flags
if(defs AND NOT defs STREQUAL "")
	foreach(def IN ITEMS ${defs})
		target_compile_definitions(${component_name}${mode_suffix} PRIVATE "${def}")
	endforeach()
endif()

# managing link time flags
if(links AND NOT links STREQUAL "")
	foreach(link IN ITEMS ${links})
		target_link_libraries(${component_name}${mode_suffix} PRIVATE ${link})
	endforeach()
endif()

endfunction(manage_Additional_Component_Internal_Flags)

function(manage_Additionnal_Component_Inherited_Flags component dep_component mode_suffix export)
	if(export)
		target_include_directories(	${component}${mode_suffix} 
						INTERFACE 
						$<TARGET_PROPERTY:${dep_component}${mode_suffix},INTERFACE_INCLUDE_DIRECTORIES>
				)
		target_compile_definitions(	${component}${INSTALL_NAME_SUFFIX} 
						INTERFACE 
						$<TARGET_PROPERTY:${dep_component}${mode_suffix},INTERFACE_COMPILE_DEFINITIONS>
				)
	endif()
	is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})	
	if(IS_BUILT_COMP)
		target_include_directories(	${component}${INSTALL_NAME_SUFFIX} 
						PRIVATE 
						$<TARGET_PROPERTY:${dep_component}${mode_suffix},INTERFACE_INCLUDE_DIRECTORIES>
					)
		target_compile_definitions(	${component}${INSTALL_NAME_SUFFIX} 
						PRIVATE 
						$<TARGET_PROPERTY:${dep_component}${mode_suffix},INTERFACE_COMPILE_DEFINITIONS>
					)
	endif()
endfunction(manage_Additionnal_Component_Inherited_Flags)

### configure the target to link with another target issued from a component of the same package
function (fill_Component_Target_With_Internal_Dependency component dep_component export comp_defs comp_exp_defs dep_defs)
is_HeaderFree_Component(DEP_IS_HF ${PROJECT_NAME} ${dep_component})
if(NOT DEP_IS_HF)#the required internal component is a library 
	if(export)	
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_exp_defs} ${dep_defs})
		manage_Additional_Component_Internal_Flags(${component} "${INSTALL_NAME_SUFFIX}" "" "${comp_defs}" "")				
		manage_Additional_Component_Exported_Flags(${component} "${INSTALL_NAME_SUFFIX}" "" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${dep_component}${INSTALL_NAME_SUFFIX}")
		manage_Additionnal_Component_Inherited_Flags(${component} ${dep_component} "${INSTALL_NAME_SUFFIX}" TRUE)		
	else()
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${dep_defs})
		manage_Additional_Component_Internal_Flags(${component} "${INSTALL_NAME_SUFFIX}" "" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${dep_component}${INSTALL_NAME_SUFFIX}")
		manage_Additional_Component_Exported_Flags(${component} "${INSTALL_NAME_SUFFIX}" "" "${comp_exp_defs}" "")
		manage_Additionnal_Component_Inherited_Flags(${component} ${dep_component} "${INSTALL_NAME_SUFFIX}" FALSE)
	endif()
endif()#else, it is an application or a module => runtime dependency declaration
endfunction(fill_Component_Target_With_Internal_Dependency)


### configure the target to link with another component issued from another package
function (fill_Component_Target_With_Package_Dependency component dep_package dep_component export comp_defs comp_exp_defs dep_defs)
is_HeaderFree_Component(DEP_IS_HF ${dep_package} ${dep_component})
if(NOT DEP_IS_HF)#the required package component is a library
	
	if(export)
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_exp_defs} ${dep_defs})
		if(${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX})
			list(APPEND ${PROJECT_NAME}_${component}_TEMP_DEFS ${${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX}})
		endif()
		manage_Additional_Component_Internal_Flags(${component} "${INSTALL_NAME_SUFFIX}" "" "${comp_defs}" "")
		manage_Additional_Component_Exported_Flags(${component} "${INSTALL_NAME_SUFFIX}" "${${dep_package}_${dep_component}_INCLUDE_DIRS${USE_MODE_SUFFIX}}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${${dep_package}_${dep_component}_LIBRARIES${USE_MODE_SUFFIX}}")
	else()
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${dep_defs})
		if(${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX})
			list(APPEND ${PROJECT_NAME}_${component}_TEMP_DEFS ${${dep_package}_${dep_component}_DEFINITIONS${USE_MODE_SUFFIX}})
		endif()		
		manage_Additional_Component_Internal_Flags(${component} "${INSTALL_NAME_SUFFIX}" "${${dep_package}_${dep_component}_INCLUDE_DIRS${USE_MODE_SUFFIX}}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${${dep_package}_${dep_component}_LIBRARIES${USE_MODE_SUFFIX}}")
		manage_Additional_Component_Exported_Flags(${component} "${INSTALL_NAME_SUFFIX}" "" "${comp_exp_defs}" "")
	endif()
endif()	#else, it is an application or a module => runtime dependency declaration
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
	manage_Additional_Component_Internal_Flags(${component} "${INSTALL_NAME_SUFFIX}" "" "${comp_defs}" "")
	manage_Additional_Component_Exported_Flags(${component} "${INSTALL_NAME_SUFFIX}" "${COMPLETE_INCLUDES_PATH}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${COMPLETE_LINKS_PATH}")

else()
	set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${ext_defs})		
	manage_Additional_Component_Internal_Flags(${component} "${INSTALL_NAME_SUFFIX}" "${COMPLETE_INCLUDES_PATH}" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${COMPLETE_LINKS_PATH}")
	manage_Additional_Component_Exported_Flags(${component} "${INSTALL_NAME_SUFFIX}" "" "${comp_exp_defs}" "")
endif()

endfunction(fill_Component_Target_With_External_Dependency)

############################################################################
############### API functions for imported targets management ##############
############################################################################
function (create_All_Imported_Dependency_Targets package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
	#collect only the package dependencies, not the internnal ones 
	foreach(a_dep_package IN ITEMS ${${package}_${component}_DEPENDENCIES${VAR_SUFFIX}})
		foreach(a_dep_component IN ITEMS ${${package}_${component}_DEPENDENCY_${a_dep_package}_COMPONENTS${VAR_SUFFIX}})
			#for all direct package dependencies	
			create_Dependency_Target(${a_dep_package} ${a_dep_component} ${mode})
			bind_Imported_Target(${package} ${component} ${a_dep_package} ${a_dep_component} ${mode})
		endforeach()
	endforeach()

endfunction(create_All_Imported_Dependency_Targets)

function (create_Dependency_Target dep_package dep_component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(NOT TARGET 	${dep_package}-${dep_component}${TARGET_SUFFIX})#target does not exist
#create the dependent target (#may produce recursion to build undirect dependencies of targets
	if(${dep_package}_${dep_component}_TYPE STREQUAL "APP"
		OR ${dep_package}_${dep_component}_TYPE STREQUAL "EXAMPLE")
		create_Imported_Executable_Target(${dep_package} ${dep_component} ${mode})
	elseif(${dep_package}_${dep_component}_TYPE STREQUAL "MODULE")
		create_Imported_Module_Library_Target(${dep_package} ${dep_component} ${mode})
	elseif(${dep_package}_${dep_component}_TYPE STREQUAL "SHARED")
		create_Imported_Shared_Library_Target(${dep_package} ${dep_component} ${mode})
	elseif(${dep_package}_${dep_component}_TYPE STREQUAL "STATIC")
		create_Imported_Static_Library_Target(${dep_package} ${dep_component} ${mode})
	elseif(${dep_package}_${dep_component}_TYPE STREQUAL "HEADER")
		create_Imported_Header_Library_Target(${dep_package} ${dep_component} ${mode})
	endif()
	create_All_Imported_Dependency_Targets(${dep_package} ${dep_component} ${mode})
endif()
endfunction(create_Dependency_Target)

function(create_Imported_Header_Library_Target package component mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})	
	add_library(${package}-${component}${TARGET_SUFFIX} INTERFACE IMPORTED GLOBAL)
	list_Public_Includes(INCLUDES ${package} ${component} ${mode})
	list_Public_Links(LINKS ${package} ${component} ${mode})
	list_Public_Definitions(DEFS ${package} ${component} ${mode})
	manage_Additional_Component_Exported_Flags(${package}-${component} "${TARGET_SUFFIX}" "${INCLUDES}" "${DEFS}" "${LINKS}")
endfunction(create_Imported_Header_Library_Target)

function(create_Imported_Static_Library_Target package component mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})	
	add_library(${package}-${component}${TARGET_SUFFIX} STATIC IMPORTED GLOBAL)

	get_Binary_Location(LOCATION_RES ${package} ${component} ${mode})
	set_target_properties(${package}-${component}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${LOCATION_RES}")

	list_Public_Includes(INCLUDES ${package} ${component} ${mode})
	list_Public_Links(LINKS ${package} ${component} ${mode})
	list_Public_Definitions(DEFS ${package} ${component} ${mode})

	manage_Additional_Component_Exported_Flags(${package}-${component} "${TARGET_SUFFIX}" "${INCLUDES}" "${DEFS}" "${LINKS}")
endfunction(create_Imported_Static_Library_Target)

function(create_Imported_Shared_Library_Target package component mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})	
	add_library(${package}-${component}${TARGET_SUFFIX} SHARED IMPORTED GLOBAL)
	
	get_Binary_Location(LOCATION_RES ${package} ${component} ${mode})
	set_target_properties(${package}-${component}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${LOCATION_RES}")

	list_Public_Includes(INCLUDES ${package} ${component} ${mode})
	list_Public_Links(LINKS ${package} ${component} ${mode})
	list_Public_Definitions(DEFS ${package} ${component} ${mode})
	manage_Additional_Component_Exported_Flags(${package}-${component} "${TARGET_SUFFIX}" "${INCLUDES}" "${DEFS}" "${LINKS}")

	 #list_Private_Links(PRIVATE_LINKS ${package} ${component} ${mode})
	#manage_Additional_Component_Internal_Flags(${package}-${component} "${TARGET_SUFFIX}" "" "" "${PRIVATE_LINKS}")
endfunction(create_Imported_Shared_Library_Target)

function(create_Imported_Module_Library_Target package component mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})	
	add_library(${package}-${component}${TARGET_SUFFIX} MODULE IMPORTED GLOBAL)

	get_Binary_Location(LOCATION_RES ${package} ${component} ${mode} ${${package}_ROOT_DIR})
	set_target_properties(${package}-${component}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${LOCATION_RES}")
	#no need to do more, a module is kind of an executable in this case
endfunction(create_Imported_Module_Library_Target)


function(create_Imported_Executable_Target package name mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})	
	add_executable(${package}-${name}${TARGET_SUFFIX} IMPORTED GLOBAL)
	
	get_Binary_Location(LOCATION_RES ${package} ${component} ${mode} ${${package}_ROOT_DIR})
	set_target_properties(${package}-${component}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${LOCATION_RES}")
endfunction(create_Imported_Executable_Target)

function(bind_Target component dep_package dep_component mode comp_defs comp_exp_defs dep_defs)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
is_Built_Component(COMP_IS_BUILT ${dep_package} ${component})
is_HeaderFree_Component(DEP_IS_HF ${dep_package} ${dep_component})

if(COMP_IS_BUILT)
	#use definitions and links for building the target
	set(internal_defs ${comp_defs} ${comp_exp_defs} ${dep_defs})
	manage_Additional_Component_Internal_Flags(${component} "${TARGET_SUFFIX}" "" "${internal_defs}" "")
		
	if(NOT DEP_IS_HF)
		target_link_libraries(${component}${TARGET_SUFFIX} PRIVATE ${dep_package}-${dep_component}${TARGET_SUFFIX})

		target_include_directories(${component}${TARGET_SUFFIX} PRIVATE 
			$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)
	
		target_compile_definitions(${component}${TARGET_SUFFIX} PRIVATE 
			$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)

		#target_link_libraries(${component}${TARGET_SUFFIX} PRIVATE 
		#$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_LINK_LIBRARIES>)
	endif()
endif()

if(NOT DEP_IS_HF)#the required package component is a library with header it can export something
	if(export)
		set(internal_defs ${comp_exp_defs} ${dep_defs})
		manage_Additional_Component_Exported_Flags(${component} "${TARGET_SUFFIX}" "" "${internal_defs}" "")

		target_link_libraries(${component}${TARGET_SUFFIX} INTERFACE ${dep_package}-${dep_component}${TARGET_SUFFIX})
		
		target_include_directories(${component}${TARGET_SUFFIX} INTERFACE 
		$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)

		target_compile_definitions(${component}${TARGET_SUFFIX} INTERFACE
		$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)

		#target_link_libraries(${component}${TARGET_SUFFIX} INTERFACE 
		#$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_LINK_LIBRARIES>)

	else()
		manage_Additional_Component_Exported_Flags(${component} "${TARGET_SUFFIX}" "" "${comp_exp_defs}" "")
	endif()
	
endif()	#else, it is an application or a module => runtime dependency declaration only

endfunction(bind_Target)

function(bind_Internal_Target component dep_component mode comp_defs comp_exp_defs dep_defs)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
is_Built_Component(COMP_IS_BUILT ${PROJECT_NAME} ${component})
is_HeaderFree_Component(DEP_IS_HF ${PROJECT_NAME} ${dep_component})
message("bind_Internal_Target ${component} ${dep_component} ${mode} defs=<${comp_defs}> exp_def=<${comp_exp_defs}> deps_defs=<${dep_defs}>")
if(COMP_IS_BUILT)# interface library cannot receive PRIVATE PROPERTIES 
	#use definitions and links for building the target
	set(internal_defs ${comp_defs} ${comp_exp_defs} ${dep_defs})
	manage_Additional_Component_Internal_Flags(${component} "${TARGET_SUFFIX}" "" "${internal_defs}" "")

	if(NOT DEP_IS_HF)#the dependency may export some things
		target_link_libraries(${component}${TARGET_SUFFIX} PRIVATE ${dep_component}${TARGET_SUFFIX})
		
		target_include_directories(${component}${TARGET_SUFFIX} PRIVATE 
			$<TARGET_PROPERTY:${dep_component}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)

		target_compile_definitions(${component}${TARGET_SUFFIX} PRIVATE 
			$<TARGET_PROPERTY:${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)

		#target_link_libraries(${component}${TARGET_SUFFIX} PRIVATE
		#	$<TARGET_PROPERTY:${dep_component}${TARGET_SUFFIX},INTERFACE_LINK_LIBRARIES>)
	endif()
endif()


if(NOT DEP_IS_HF)#the required package component is a library with header it can export something
	if(export)
		set(internal_defs ${comp_exp_defs} ${dep_defs})
		manage_Additional_Component_Exported_Flags(${component} "${TARGET_SUFFIX}" "" "${internal_defs}" "")
		target_link_libraries(${component}${TARGET_SUFFIX} INTERFACE ${dep_component}${TARGET_SUFFIX})
		
		target_include_directories(${component}${TARGET_SUFFIX} INTERFACE 
			$<TARGET_PROPERTY:${dep_component}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)

		target_compile_definitions(${component}${TARGET_SUFFIX} INTERFACE
			$<TARGET_PROPERTY:${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)

		#target_link_libraries(${component}${TARGET_SUFFIX} INTERFACE 
		#	$<TARGET_PROPERTY:${dep_component}${TARGET_SUFFIX},INTERFACE_LINK_LIBRARIES>)

	else()
		manage_Additional_Component_Exported_Flags(${component} "${TARGET_SUFFIX}" "" "${comp_exp_defs}" "")
	endif()
	
endif()	#else, it is an application or a module => runtime dependency declaration only

endfunction(bind_Internal_Target)


function(bind_Imported_Target package component dep_package dep_component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

is_HeaderFree_Component(DEP_IS_HF ${dep_package} ${dep_component})
if(NOT DEP_IS_HF)#the required package component is a library with header it can export something
	if(export)
		target_link_libraries(${package}-${component}${TARGET_SUFFIX} INTERFACE ${dep_package}-${dep_component}${TARGET_SUFFIX})
		target_include_directories(${package}-${component}${TARGET_SUFFIX} INTERFACE 
		$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)

		target_compile_definitions(${package}-${component}${TARGET_SUFFIX} INTERFACE
		$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)

		#target_link_libraries(${package}-${component}${TARGET_SUFFIX} INTERFACE 
		#$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_LINK_LIBRARIES>)

	else()
		target_compile_definitions(${package}-${component}${TARGET_SUFFIX} INTERFACE "${comp_exp_defs}")
	endif()
	
endif()	#else, it is an application or a module => runtime dependency declaration only

endfunction(bind_Imported_Target)


function (fill_Component_Target_With_Dependency component dep_package dep_component mode export comp_defs comp_exp_defs dep_defs)
if(${PROJECT_NAME} STREQUAL ${dep_package})#target already created elsewhere since internal target
	bind_Internal_Target(${component} ${dep_component} ${mode} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
else()# it is an external dependency
	create_Dependency_Target(${dep_package} ${dep_component} ${mode})
	bind_Target(${component} ${dep_package} ${dep_component} ${mode} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
endif()
endfunction(fill_Component_Target_With_Dependency)


