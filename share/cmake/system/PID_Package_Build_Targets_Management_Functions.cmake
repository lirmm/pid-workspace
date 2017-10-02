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

############################################################################
####################### Language standard management #######################
############################################################################
function(initialize_Build_System)

	## create a property to deal with language standard in targets (created for compatibility with CMake 3.0.2 and CMake version < 3.8 when c++17 is used)
	define_property(TARGET PROPERTY PID_CXX_STANDARD
	                BRIEF_DOCS "Determine the C++ Language standard version to use"
								 	FULL_DOCS "Determine the C++ Language standard version to use")
	#standard for C
	define_property(TARGET PROPERTY PID_C_STANDARD
              BRIEF_DOCS "Determine the C Language standard version to use"
						 	FULL_DOCS "Determine the C Language standard version to use")

endfunction(initialize_Build_System)

function(resolve_Component_Language component_target)
	if(CMAKE_VERSION VERSION_LESS 3.1)#this is only usefll if CMake does not automatically deal with standard related properties
		get_target_property(STD_C ${component_target} PID_C_STANDARD)
		get_target_property(STD_CXX ${component_target} PID_CXX_STANDARD)

		#managing c++
		if(STD_CXX EQUAL 98)
			target_compile_options(${component_target} PUBLIC "-std=c++98")
		elseif(STD_CXX EQUAL 11)
			target_compile_options(${component_target} PUBLIC "-std=c++11")
		elseif(STD_CXX EQUAL 14)
			target_compile_options(${component_target} PUBLIC "-std=c++14")
		elseif(STD_CXX EQUAL 17)
			target_compile_options(${component_target} PUBLIC "-std=c++17")
		endif()

		#managing c
		if(STD_C EQUAL 90)
			target_compile_options(${component_target} PUBLIC "-std=c90")
		elseif(STD_C EQUAL 99)
			target_compile_options(${component_target} PUBLIC "-std=c99")
		elseif(STD_C EQUAL 11)
			target_compile_options(${component_target} PUBLIC "-std=c11")
		endif()
		return()

	elseif(CMAKE_VERSION VERSION_LESS 3.8)#if cmake version is less than 3.8 than the c++ 17 language is unknown
		get_target_property(STD_CXX ${component_target} PID_CXX_STANDARD)
		is_CXX_Version_Less(IS_LESS ${STD_CXX} 17)
		if(NOT IS_LESS)#cxx standard 17 or more
			target_compile_options(${component_target} PUBLIC "-std=c++17")
			return()
		endif()
	endif()

	#default case that can be managed directly by CMake
	get_target_property(STD_C ${component_target} PID_C_STANDARD)
	get_target_property(STD_CXX ${component_target} PID_CXX_STANDARD)

	set_target_properties(${component_target} PROPERTIES
			C_STANDARD ${STD_C}
			C_STANDARD_REQUIRED YES
			C_EXTENSIONS NO
	)#setting the standard in use locally

	set_target_properties(${component_target} PROPERTIES
			CXX_STANDARD ${STD_CXX}
			CXX_STANDARD_REQUIRED YES
			CXX_EXTENSIONS NO
	)#setting the standard in use locally

endfunction(resolve_Component_Language)

### global function that set compile option for all components that are build given some info not directly managed by CMake
function(resolve_Compile_Options_For_Targets mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})
	if(IS_BUILT_COMP)
		resolve_Component_Language(${component}${TARGET_SUFFIX})
	endif()
endforeach()
endfunction(resolve_Compile_Options_For_Targets)

### filter the options lines to get those options related to language standard in USE
function(filter_Compiler_Options STD_C_OPT STD_CXX_OPT FILTERED_OPTS opts)
set(RES_FILTERED)
if(opts AND NOT opts STREQUAL "")
	foreach(opt IN ITEMS ${opts})
		unset(STANDARD_NUMBER)
		#checking for CXX_STANDARD
		is_CXX_Standard_Option(STANDARD_NUMBER ${opt})
		if(STANDARD_NUMBER)
			set(${STD_CXX_OPT} ${STANDARD_NUMBER} PARENT_SCOPE)
		else()#checking for C_STANDARD
			is_C_Standard_Option(STANDARD_NUMBER ${opt})
			if(STANDARD_NUMBER)
				set(${STD_C_OPT} ${STANDARD_NUMBER} PARENT_SCOPE)
			else()
				list(APPEND RES_FILTERED ${opt})#keep the option unchanged
			endif()
		endif()
	endforeach()
	set(${FILTERED_OPTS} ${RES_FILTERED} PARENT_SCOPE)
endif()
endfunction(filter_Compiler_Options)

############################################################################
############### API functions for internal targets management ##############
############################################################################
###create a fake target for a python component
function(manage_Python_Scripts c_name dirname)
	set_target_properties(${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES PREFIX "")#specific requirement for python, not lib prefix at beginning of the module

	# simply copy directory containing script at install time into a specific folder, but select only python script
	# Important notice: the trailing / at end of DIRECTORY argument is to allow the renaming of the directory into c_name
	install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${dirname}/
					DESTINATION ${${PROJECT_NAME}_INSTALL_SCRIPT_PATH}/${c_name}
					FILES_MATCHING PATTERN "*.py")

	#get_Binary_Location(RES_LOC ${PROJECT_NAME} ${c_name} Release) should be used but not usable due to a bug in install(CODE ...) avoiding to use generator expressions
	install(#install symlinks that target the python module either in install directory and (undirectly) in the python install dir
			CODE
			"execute_process(
					COMMAND ${CMAKE_COMMAND}
					-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
					-DCMAKE_COMMAND=${CMAKE_COMMAND}
					-DWORKSPACE_DIR=${WORKSPACE_DIR}
					-DTARGET_PACKAGE=${PROJECT_NAME}
					-DTARGET_VERSION=${${PROJECT_NAME}_VERSION}
					-DTARGET_MODULE=${c_name}
					-P ${WORKSPACE_DIR}/share/cmake/system/Install_PID_Python_Script.cmake
			)
			"
	)
endfunction(manage_Python_Scripts)

###create a module lib target for a newly defined library
function(create_Module_Lib_Target c_name c_standard cxx_standard sources internal_inc_dirs internal_defs internal_compiler_options internal_links)
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
	manage_Additional_Component_Internal_Flags(${c_name} "${c_standard}" "${cxx_standard}" "${INSTALL_NAME_SUFFIX}" "${internal_inc_dirs}" "${internal_defs}" "${internal_compiler_options}" "${internal_links}")
endfunction(create_Module_Lib_Target)

###create a shared lib target for a newly defined library
function(create_Shared_Lib_Target c_name c_standard cxx_standard sources exported_inc_dirs internal_inc_dirs exported_defs internal_defs exported_compiler_options internal_compiler_options exported_links internal_links)
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
	set(INC_DIRS ${internal_inc_dirs} ${exported_inc_dirs})
	set(DEFS ${internal_defs} ${exported_defs})
	set(LINKS ${exported_links} ${internal_links})
	set(COMP_OPTS ${exported_compiler_options} ${internal_compiler_options})
	manage_Additional_Component_Internal_Flags(${c_name} "${c_standard}" "${cxx_standard}" "${INSTALL_NAME_SUFFIX}" "${INC_DIRS}" "${DEFS}" "${COMP_OPTS}" "${LINKS}")
	manage_Additional_Component_Exported_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${exported_inc_dirs}" "${exported_defs}" "${exported_compiler_options}" "${exported_links}")
endfunction(create_Shared_Lib_Target)

###create a static lib target for a newly defined library
function(create_Static_Lib_Target c_name c_standard cxx_standard sources exported_inc_dirs internal_inc_dirs exported_defs internal_defs exported_compiler_options internal_compiler_options exported_links)
	add_library(${c_name}${INSTALL_NAME_SUFFIX} STATIC ${sources})
	install(TARGETS ${c_name}${INSTALL_NAME_SUFFIX}
		ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_AR_PATH}
	)
	set(INC_DIRS ${internal_inc_dirs} ${exported_inc_dirs})
	set(DEFS ${internal_defs} ${exported_defs})
	set(COMP_OPTS ${exported_compiler_options} ${internal_compiler_options})
	manage_Additional_Component_Internal_Flags(${c_name} "${c_standard}" "${cxx_standard}" "${INSTALL_NAME_SUFFIX}" "${INC_DIRS}" "${DEFS}" "${COMP_OPTS}" "")#no linking with static libraries so do not manage internal_flags
	manage_Additional_Component_Exported_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${exported_inc_dirs}" "${exported_defs}" "${exported_compiler_options}" "${exported_links}")

endfunction(create_Static_Lib_Target)

###create a shared lib target for a newly defined library
function(create_Header_Lib_Target c_name c_standard cxx_standard exported_inc_dirs exported_defs exported_compiler_options exported_links)
	add_library(${c_name}${INSTALL_NAME_SUFFIX} INTERFACE)
	manage_Additional_Component_Exported_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${exported_inc_dirs}" "${exported_defs}" "${exported_compiler_options}" "${exported_links}")
endfunction(create_Header_Lib_Target)

###create an executable target for a newly defined application
function(create_Executable_Target c_name c_standard cxx_standard sources internal_inc_dirs internal_defs internal_compiler_options internal_links)
	add_executable(${c_name}${INSTALL_NAME_SUFFIX} ${sources})
	manage_Additional_Component_Internal_Flags(${c_name} "${c_standard}" "${cxx_standard}" "${INSTALL_NAME_SUFFIX}" "${internal_inc_dirs}" "${internal_defs}" "${internal_compiler_options}" "${internal_links}")
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

function(create_TestUnit_Target c_name c_standard cxx_standard sources internal_inc_dirs internal_defs internal_compiler_options internal_links)
	add_executable(${c_name}${INSTALL_NAME_SUFFIX} ${sources})
	manage_Additional_Component_Internal_Flags(${c_name} "${c_standard}" "${cxx_standard}" "${INSTALL_NAME_SUFFIX}" "${internal_inc_dirs}" "${internal_defs}" "${internal_compiler_options}" "${internal_links}")
endfunction(create_TestUnit_Target)

### configure the target with exported flags (cflags and ldflags)
function(manage_Additional_Component_Exported_Flags component_name mode_suffix inc_dirs defs options links)
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

if(options AND NOT options STREQUAL "")
	foreach(opt IN ITEMS ${options})
		target_compile_options(${component_name}${mode_suffix} INTERFACE "${opt}")#keep the option unchanged
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
function(manage_Additional_Component_Internal_Flags component_name c_standard cxx_standard mode_suffix inc_dirs defs options links)
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

if(options AND NOT options STREQUAL "")
	foreach(opt IN ITEMS ${options})
		target_compile_options(${component_name}${mode_suffix} PRIVATE "${opt}")
	endforeach()
endif()

# managing link time flags
if(links AND NOT links STREQUAL "")
	foreach(link IN ITEMS ${links})
		target_link_libraries(${component_name}${mode_suffix} PRIVATE ${link})
	endforeach()
endif()

#management of standards (setting minimum standard at beginning)
if(c_standard AND NOT c_standard STREQUAL "")
	set_target_properties(${component_name}${mode_suffix} PROPERTIES PID_C_STANDARD ${c_standard})
endif()

if(cxx_standard AND NOT cxx_standard STREQUAL "")
	set_target_properties(${component_name}${mode_suffix} PROPERTIES PID_CXX_STANDARD ${cxx_standard})
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

		target_compile_options(		${component}${INSTALL_NAME_SUFFIX}
						INTERFACE
						$<TARGET_PROPERTY:${dep_component}${mode_suffix},INTERFACE_COMPILE_OPTIONS>
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
		target_compile_options(		${component}${INSTALL_NAME_SUFFIX}
						PRIVATE
						$<TARGET_PROPERTY:${dep_component}${mode_suffix},INTERFACE_COMPILE_OPTIONS>
		)
	endif()
endfunction(manage_Additionnal_Component_Inherited_Flags)

### configure the target to link with another target issued from a component of the same package
function (fill_Component_Target_With_Internal_Dependency component dep_component export comp_defs comp_exp_defs dep_defs)
is_HeaderFree_Component(DEP_IS_HF ${PROJECT_NAME} ${dep_component})
if(NOT DEP_IS_HF)#the required internal component is a library
	if(export)
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_exp_defs} ${dep_defs})
		manage_Additional_Component_Internal_Flags(${component} "" "" "${INSTALL_NAME_SUFFIX}" "" "${comp_defs}" "")
		manage_Additional_Component_Exported_Flags(${component} "${INSTALL_NAME_SUFFIX}" "" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${dep_component}${INSTALL_NAME_SUFFIX}")
		manage_Additionnal_Component_Inherited_Flags(${component} ${dep_component} "${INSTALL_NAME_SUFFIX}" TRUE)
	else()
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${dep_defs})
		manage_Additional_Component_Internal_Flags(${component} "" "" "${INSTALL_NAME_SUFFIX}" "" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "${dep_component}${INSTALL_NAME_SUFFIX}")
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
		manage_Additional_Component_Internal_Flags(${component} "" "" "${INSTALL_NAME_SUFFIX}" "" "${comp_defs}" "")
		manage_Additional_Component_Exported_Flags(${component} "${INSTALL_NAME_SUFFIX}" "" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "")
	else()
		set(${PROJECT_NAME}_${component}_TEMP_DEFS ${comp_defs} ${dep_defs})
		manage_Additional_Component_Internal_Flags(${component} "" "" "${INSTALL_NAME_SUFFIX}" "" "${${PROJECT_NAME}_${component}_TEMP_DEFS}" "")
		manage_Additional_Component_Exported_Flags(${component} "${INSTALL_NAME_SUFFIX}" "" "${comp_exp_defs}" "")
	endif()
endif()	#else, it is an application or a module => runtime dependency declaration
endfunction(fill_Component_Target_With_Package_Dependency)


### configure the target to link with an external dependancy
function(fill_Component_Target_With_External_Dependency component export comp_defs comp_exp_defs ext_defs ext_inc_dirs ext_links)
if(ext_links)
	resolve_External_Libs_Path(COMPLETE_LINKS_PATH ${PROJECT_NAME} "${ext_links}" ${CMAKE_BUILD_TYPE})
	if(COMPLETE_LINKS_PATH)
		foreach(link IN ITEMS ${COMPLETE_LINKS_PATH})
			create_External_Dependency_Target(EXT_TARGET_NAME ${link} ${CMAKE_BUILD_TYPE})
			if(EXT_TARGET_NAME)
				list(APPEND EXT_LINKS_TARGETS ${EXT_TARGET_NAME})
			else()
				list(APPEND EXT_LINKS_OPTIONS ${link})
			endif()
		endforeach()
	endif()
	list(APPEND EXT_LINKS ${EXT_LINKS_TARGETS} ${EXT_LINKS_OPTIONS})
endif()
if(ext_inc_dirs)
	resolve_External_Includes_Path(COMPLETE_INCLUDES_PATH ${PROJECT_NAME} "${ext_inc_dirs}" ${CMAKE_BUILD_TYPE})
endif()

# setting compile/linkage definitions for the component target
if(export)
	if(NOT ${${PROJECT_NAME}_${component}_TYPE} STREQUAL "HEADER")#if component is a not header, everything is used to build
		set(TEMP_DEFS ${comp_exp_defs} ${ext_defs} ${comp_defs})
		manage_Additional_Component_Internal_Flags(${component} "" "" "${INSTALL_NAME_SUFFIX}" "${COMPLETE_INCLUDES_PATH}" "${TEMP_DEFS}" "" "${EXT_LINKS}")
	endif()
	set(TEMP_DEFS ${comp_exp_defs} ${ext_defs})#only definitions belonging to interfaces are exported (interface of current component + interface of exported component)
	manage_Additional_Component_Exported_Flags(${component} "${INSTALL_NAME_SUFFIX}" "${COMPLETE_INCLUDES_PATH}" "${TEMP_DEFS}" "" "${EXT_LINKS}")

else()#otherwise only definitions for interface of the current component is exported
	set(TEMP_DEFS ${comp_defs} ${ext_defs} ${comp_defs})#everything define for building current component
	manage_Additional_Component_Internal_Flags(${component} "" "" "${INSTALL_NAME_SUFFIX}" "${COMPLETE_INCLUDES_PATH}" "${TEMP_DEFS}" "" "${EXT_LINKS}")
	manage_Additional_Component_Exported_Flags(${component} "${INSTALL_NAME_SUFFIX}" "" "${comp_exp_defs}" "" "${EXT_LINKS}")
endif()

endfunction(fill_Component_Target_With_External_Dependency)

############################################################################
############### API functions for imported targets management ##############
############################################################################
function (create_All_Imported_Dependency_Targets package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
#collect only the package dependencies, not the internal ones
foreach(a_dep_component IN ITEMS ${${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX}})
	#for all direct internal dependencies
	create_Dependency_Target(${package} ${a_dep_component} ${mode})
	bind_Imported_Target(${package} ${component} ${package} ${a_dep_component} ${mode})
endforeach()
foreach(a_dep_package IN ITEMS ${${package}_${component}_DEPENDENCIES${VAR_SUFFIX}})
	foreach(a_dep_component IN ITEMS ${${package}_${component}_DEPENDENCY_${a_dep_package}_COMPONENTS${VAR_SUFFIX}})
		#for all direct package dependencies
		create_Dependency_Target(${a_dep_package} ${a_dep_component} ${mode})
		bind_Imported_Target(${package} ${component} ${a_dep_package} ${a_dep_component} ${mode})
	endforeach()
endforeach()
endfunction(create_All_Imported_Dependency_Targets)

function (create_External_Dependency_Target EXT_TARGET_NAME link mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
get_Link_Type(RES_TYPE ${link})
if(RES_TYPE STREQUAL OPTION) #for options there is no need to define a target
	set(${EXT_TARGET_NAME} PARENT_SCOPE)
elseif(RES_TYPE STREQUAL SHARED)
	get_filename_component(LIB_NAME ${link} NAME)
	if(NOT TARGET ext-${LIB_NAME}${TARGET_SUFFIX})#target does not exist
		add_library(ext-${LIB_NAME}${TARGET_SUFFIX} SHARED IMPORTED GLOBAL)
		set_target_properties(ext-${LIB_NAME}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${link}")
	endif()
	set(${EXT_TARGET_NAME} ext-${LIB_NAME}${TARGET_SUFFIX} PARENT_SCOPE)
else(RES_TYPE STREQUAL STATIC)
	get_filename_component(LIB_NAME ${link} NAME)
	if(NOT TARGET ext-${LIB_NAME}${TARGET_SUFFIX})#target does not exist
		add_library(ext-${LIB_NAME}${TARGET_SUFFIX} STATIC IMPORTED GLOBAL)
		set_target_properties(ext-${LIB_NAME}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${link}")
	endif()
	set(${EXT_TARGET_NAME} ext-${LIB_NAME}${TARGET_SUFFIX} PARENT_SCOPE)
endif()
endfunction(create_External_Dependency_Target)


function (create_Dependency_Target dep_package dep_component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
if(NOT TARGET ${dep_package}-${dep_component}${TARGET_SUFFIX})#check that this target does not exist, otherwise naming conflict
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

function(manage_Additional_Imported_Component_Flags package component mode inc_dirs defs options public_links private_links)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

if(inc_dirs AND NOT inc_dirs STREQUAL "")
	foreach(dir IN ITEMS ${inc_dirs})
		set_property(TARGET ${package}-${component}${TARGET_SUFFIX} APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${dir}")
	endforeach()
endif()

# managing compile time flags (-D<preprocessor_defs>)
if(defs AND NOT defs STREQUAL "")
	foreach(def IN ITEMS ${defs})
		set_property(TARGET ${package}-${component}${TARGET_SUFFIX} APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS "${def}")
	endforeach()
endif()

if(options AND NOT options STREQUAL "")
	foreach(opt IN ITEMS ${options})
		#checking for CXX_STANDARD
		is_CXX_Standard_Option(STANDARD_NUMBER ${opt})
		if(STANDARD_NUMBER)
			message("[PID] WARNING: directly using option -std=c++${STANDARD_NUMBER} is not recommanded, use the CXX_STANDARD keywork in component description instead. PID performs corrective action.")
			if(NOT ${package}_${component}_CXX_STANDARD${VAR_SUFFIX}
			OR ${package}_${component}_CXX_STANDARD${VAR_SUFFIX} LESS STANDARD_NUMBER)
				set(${package}_${component}_CXX_STANDARD${VAR_SUFFIX} ${STANDARD_NUMBER} CACHE INTERNAL "")
			endif()
		else()#checking for C_STANDARD
			is_C_Standard_Option(STANDARD_NUMBER ${opt})
			if(STANDARD_NUMBER)
				message("[PID] WARNING: directly using option -std=c${STANDARD_NUMBER} is not recommanded, use the C_STANDARD keywork in component description instead. PID performs corrective action.")
				if(NOT ${package}_${component}_C_STANDARD${VAR_SUFFIX}
				OR ${package}_${component}_C_STANDARD${VAR_SUFFIX} LESS STANDARD_NUMBER)
					set(${package}_${component}_C_STANDARD${VAR_SUFFIX} ${STANDARD_NUMBER} CACHE INTERNAL "")
				endif()
			else()
				set_property(TARGET ${package}-${component}${TARGET_SUFFIX} APPEND PROPERTY INTERFACE_COMPILE_OPTIONS "${opt}")
			endif()
		endif()
	endforeach()
endif()

# managing link time flags (public links are always put in the interface
if(public_links AND NOT public_links STREQUAL "")
	foreach(link IN ITEMS ${public_links})
		create_External_Dependency_Target(EXT_TARGET_NAME ${link} ${mode})
		if(EXT_TARGET_NAME) #this is a library
			set_property(TARGET ${package}-${component}${TARGET_SUFFIX} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${EXT_TARGET_NAME})
		else()#this is an option => simply pass it to the link interface
			set_property(TARGET ${package}-${component}${TARGET_SUFFIX} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${link})
		endif()
	endforeach()
endif()

# managing link time flags (public links are always put in the interface
if(private_links AND NOT private_links STREQUAL "")
	foreach(link IN ITEMS ${private_links})
		create_External_Dependency_Target(EXT_TARGET_NAME ${link} ${mode})
		if(EXT_TARGET_NAME) #this is a library
			set_property(TARGET ${package}-${component}${TARGET_SUFFIX} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${EXT_TARGET_NAME})
		else() #this is an option => simply pass it to the link interface
			set_property(TARGET ${package}-${component}${TARGET_SUFFIX} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${link})
		endif()
	endforeach()
endif()

endfunction(manage_Additional_Imported_Component_Flags)

#function used to define which mode to use depending on the build mode in build (Release=release Debug= Debug or Release if Closed source and no debug binary available)
function(get_Imported_Target_Mode MODE_TO_IMPORT imported_package imported_binary_location build_mode)
	if(mode MATCHES Debug)
			is_Closed_Source_Dependency_Package(CLOSED ${imported_package})
			if(CLOSED AND NOT EXISTS ${imported_binary_location})#if package is closed source and no debug code available (this is a normal case)
				set(${MODE_TO_IMPORT} Release PARENT_SCOPE) #we must use the Release code
			else() #use default mode
				set(${MODE_TO_IMPORT} Debug PARENT_SCOPE)
			endif()
	else() #use default mode
				set(${MODE_TO_IMPORT} Release PARENT_SCOPE)
	endif()
endfunction(get_Imported_Target_Mode)

# imported target, by definition, do not belog to the currently build package
function(create_Imported_Header_Library_Target package component mode) #header libraries are never closed by definition
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})#get variables related to the current build mode
	add_library(${package}-${component}${TARGET_SUFFIX} INTERFACE IMPORTED GLOBAL)#suffix used only for target name
	list_Public_Includes(INCLUDES ${package} ${component} ${mode})
	list_Public_Links(LINKS ${package} ${component} ${mode})
	list_Public_Definitions(DEFS ${package} ${component} ${mode})
	list_Public_Options(OPTS ${package} ${component} ${mode})
	manage_Additional_Imported_Component_Flags(${package} ${component} ${mode} "${INCLUDES}" "${DEFS}" "${OPTS}" "${LINKS}" "")
	# check that C/C++ languages are defined or defult them
	manage_Language_Standards(${package} ${component} ${mode})
endfunction(create_Imported_Header_Library_Target)

function(create_Imported_Static_Library_Target package component mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode}) #get variables related to the current build mode
	add_library(${package}-${component}${TARGET_SUFFIX} STATIC IMPORTED GLOBAL) #create the target for the imported library

	get_Binary_Location(LOCATION_RES ${package} ${component} ${mode})
	get_Imported_Target_Mode(MODE_TO_IMPORT ${package} ${LOCATION_RES} ${mode})#get the adequate mode to use for dependency
	if(NOT MODE_TO_IMPORT MATCHES mode)
		get_Binary_Location(LOCATION_RES ${package} ${component} ${MODE_TO_IMPORT})#find the adequate release binary
	endif()
	set_target_properties(${package}-${component}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${LOCATION_RES}")#Debug mode: we keep the suffix as-if we werre building using dependent debug binary even if not existing

	list_Public_Includes(INCLUDES ${package} ${component} ${MODE_TO_IMPORT})
	list_Public_Links(LINKS ${package} ${component} ${MODE_TO_IMPORT})
	list_Private_Links(PRIVATE_LINKS ${package} ${component} ${MODE_TO_IMPORT})
	list_Public_Definitions(DEFS ${package} ${component} ${MODE_TO_IMPORT})
	list_Public_Options(OPTS ${package} ${component} ${MODE_TO_IMPORT})

	manage_Additional_Imported_Component_Flags(${package} ${component} ${mode} "${INCLUDES}" "${DEFS}" "${OPTS}" "${LINKS}" "${PRIVATE_LINKS}")
	# check that C/C++ languages are defined or defult them
	manage_Language_Standards(${package} ${component} ${mode})
endfunction(create_Imported_Static_Library_Target)

function(create_Imported_Shared_Library_Target package component mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})#get variables related to the current build mode
	add_library(${package}-${component}${TARGET_SUFFIX} SHARED IMPORTED GLOBAL)#create the target for the imported library

	get_Binary_Location(LOCATION_RES ${package} ${component} ${mode})#find the binary to use depending on build mode
	get_Imported_Target_Mode(MODE_TO_IMPORT ${package} ${LOCATION_RES} ${mode})#get the adequate mode to use for dependency
	if(NOT MODE_TO_IMPORT MATCHES mode)
		get_Binary_Location(LOCATION_RES ${package} ${component} ${MODE_TO_IMPORT})#find the adequate release binary
	endif()

	set_target_properties(${package}-${component}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${LOCATION_RES}")#Debug mode: we keep the suffix as-if we werre building using dependent debug binary even if not existing

	list_Public_Includes(INCLUDES ${package} ${component} ${MODE_TO_IMPORT})
	list_Public_Links(LINKS ${package} ${component} ${MODE_TO_IMPORT})
	list_Private_Links(PRIVATE_LINKS ${package} ${component} ${MODE_TO_IMPORT})
	list_Public_Definitions(DEFS ${package} ${component} ${MODE_TO_IMPORT})
	list_Public_Options(OPTS ${package} ${component} ${MODE_TO_IMPORT})
	manage_Additional_Imported_Component_Flags(${package} ${component} ${mode} "${INCLUDES}" "${DEFS}" "${OPTS}" "${LINKS}" "${PRIVATE_LINKS}")

	# check that C/C++ languages are defined or default them
	manage_Language_Standards(${package} ${component} ${mode})
endfunction(create_Imported_Shared_Library_Target)

function(create_Imported_Module_Library_Target package component mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})#get variables related to the current build mode
	add_library(${package}-${component}${TARGET_SUFFIX} MODULE IMPORTED GLOBAL)#create the target for the imported library

	get_Binary_Location(LOCATION_RES ${package} ${component} ${mode})#find the binary to use depending on build mode
	get_Imported_Target_Mode(MODE_TO_IMPORT ${package} ${LOCATION_RES} ${mode})#get the adequate mode to use for dependency
	if(NOT MODE_TO_IMPORT MATCHES mode)
		get_Binary_Location(LOCATION_RES ${package} ${component} ${MODE_TO_IMPORT})#find the adequate release binary
	endif()

	set_target_properties(${package}-${component}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${LOCATION_RES}")#Debug mode: we keep the suffix as-if we werre building using dependent debug binary even if not existing
	#no need to do more, a module is kind of an executable so it stops build recursion
endfunction(create_Imported_Module_Library_Target)


function(create_Imported_Executable_Target package component mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})#get variables related to the current build mode
	add_executable(${package}-${component}${TARGET_SUFFIX} IMPORTED GLOBAL)#create the target for the imported executable

	get_Binary_Location(LOCATION_RES ${package} ${component} ${mode})
	get_Imported_Target_Mode(MODE_TO_IMPORT ${package} ${LOCATION_RES} ${mode})#get the adequate mode to use for dependency
	if(NOT MODE_TO_IMPORT MATCHES mode)
		get_Binary_Location(LOCATION_RES ${package} ${component} ${MODE_TO_IMPORT})#find the adequate release binary
	endif()

	set_target_properties(${package}-${component}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${LOCATION_RES}")#Debug mode: we keep the suffix as-if we werre building using dependent debug binary even if not existing
	#no need to do more, executable will not be linked in the build process (it stops build recursion)
endfunction(create_Imported_Executable_Target)

### resolving the standard to use depending on the standard used in dependency
function(resolve_Standard_Before_Linking package component dep_package dep_component mode configure_build)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

#get the languages standard in use for both components
get_Language_Standards(STD_C STD_CXX ${package} ${component} ${mode})
get_Language_Standards(DEP_STD_C DEP_STD_CXX ${dep_package} ${dep_component} ${mode})

is_C_Version_Less(IS_LESS ${STD_C} ${DEP_STD_C})
if( IS_LESS )#dependency has greater or equal level of standard required
	set(${package}_${component}_C_STANDARD${VAR_SUFFIX} ${DEP_STD_C} CACHE INTERNAL "")
	if(configure_build)# the build property is set for a target that is built locally (otherwise would produce errors)
		set_target_properties(${component}${TARGET_SUFFIX} PROPERTIES PID_C_STANDARD ${DEP_STD_C}) #the minimal value in use file is set adequately
	endif()
endif()

is_CXX_Version_Less(IS_LESS ${STD_CXX} ${DEP_STD_CXX})
if( IS_LESS )#dependency has greater or equal level of standard required
	set(${package}_${component}_CXX_STANDARD${VAR_SUFFIX} ${DEP_STD_CXX} CACHE INTERNAL "")#the minimal value in use file is set adequately
	if(configure_build)# the build property is set for a target that is built locally (otherwise would produce errors)
		set_target_properties(${component}${TARGET_SUFFIX} PROPERTIES PID_CXX_STANDARD ${DEP_STD_CXX})
	endif()
endif()
endfunction(resolve_Standard_Before_Linking)

### bind a component build locally to a component belonging to another package
function(bind_Target component dep_package dep_component mode export comp_defs comp_exp_defs dep_defs)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
is_Built_Component(COMP_IS_BUILT ${PROJECT_NAME} ${component})
is_HeaderFree_Component(DEP_IS_HF ${dep_package} ${dep_component})
if(COMP_IS_BUILT)
	#use definitions and links for building the target
	set(internal_defs ${comp_defs} ${comp_exp_defs} ${dep_defs})
	manage_Additional_Component_Internal_Flags(${component} "" "" "${TARGET_SUFFIX}" "" "${internal_defs}" "" "")

	if(NOT DEP_IS_HF)
		target_link_libraries(${component}${TARGET_SUFFIX} PRIVATE ${dep_package}-${dep_component}${TARGET_SUFFIX})
		target_include_directories(${component}${TARGET_SUFFIX} PRIVATE
			$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)

		target_compile_definitions(${component}${TARGET_SUFFIX} PRIVATE
			$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)

		target_compile_options(${component}${TARGET_SUFFIX} PRIVATE
			$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>)
	endif()

	# set adequately language standard for component depending on the value of dep_component
	resolve_Standard_Before_Linking(${PROJECT_NAME} ${component} ${dep_package} ${dep_component} ${mode} TRUE)
else()#for headers lib do not set the language standard build property (othewise CMake complains on recent versions)
	# set adequately language standard for component depending on the value of dep_component
	resolve_Standard_Before_Linking(${PROJECT_NAME} ${component} ${dep_package} ${dep_component} ${mode} FALSE)
endif()

if(NOT DEP_IS_HF)#the required package component is a library with header it can export something
	if(export)
		set(internal_defs ${comp_exp_defs} ${dep_defs})
		manage_Additional_Component_Exported_Flags(${component} "${TARGET_SUFFIX}" "" "${internal_defs}" "" "")

		target_include_directories(${component}${TARGET_SUFFIX} INTERFACE
			$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)

		target_compile_definitions(${component}${TARGET_SUFFIX} INTERFACE
			$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)

		target_compile_options(${component}${TARGET_SUFFIX} INTERFACE
			$<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>)

		target_link_libraries(${component}${TARGET_SUFFIX} INTERFACE ${dep_package}-${dep_component}${TARGET_SUFFIX})
	else()
		manage_Additional_Component_Exported_Flags(${component} "${TARGET_SUFFIX}" "" "${comp_exp_defs}" "" "")
		if(NOT ${PROJECT_NAME}_${component}_TYPE STREQUAL "SHARED")#static OR header lib always export private links
			target_link_libraries(${component}${TARGET_SUFFIX} INTERFACE  ${dep_package}-${dep_component}${TARGET_SUFFIX})
		endif()
	endif()
endif()	#else, it is an application or a module => runtime dependency declaration only
endfunction(bind_Target)

### bind a component built locally with another component buit locally
function(bind_Internal_Target component dep_component mode export comp_defs comp_exp_defs dep_defs)

get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
is_Built_Component(COMP_IS_BUILT ${PROJECT_NAME} ${component})
is_HeaderFree_Component(DEP_IS_HF ${PROJECT_NAME} ${dep_component})

if(COMP_IS_BUILT)# interface library cannot receive PRIVATE PROPERTIES
	#use definitions and links for building the target
	set(internal_defs ${comp_defs} ${comp_exp_defs} ${dep_defs})
	manage_Additional_Component_Internal_Flags(${component} "" "" "${TARGET_SUFFIX}" "" "${internal_defs}" "" "")

	if(NOT DEP_IS_HF)#the dependency may export some things
		target_link_libraries(${component}${TARGET_SUFFIX} PRIVATE ${dep_component}${TARGET_SUFFIX})

		target_include_directories(${component}${TARGET_SUFFIX} PRIVATE
			$<TARGET_PROPERTY:${dep_component}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)

		target_compile_definitions(${component}${TARGET_SUFFIX} PRIVATE
			$<TARGET_PROPERTY:${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)

		target_compile_options(${component}${TARGET_SUFFIX} PRIVATE
			$<TARGET_PROPERTY:${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>)
	endif()

		# set adequately language standard for component depending on the value of dep_component
		resolve_Standard_Before_Linking(${PROJECT_NAME} ${component} ${PROJECT_NAME} ${dep_component} ${mode} TRUE)
else() #for header lib do not set the build property to avoid troubles
		# set adequately language standard for component depending on the value of dep_component
		resolve_Standard_Before_Linking(${PROJECT_NAME} ${component} ${PROJECT_NAME} ${dep_component} ${mode} FALSE)
endif()


if(NOT DEP_IS_HF)#the required package component is a library with header it can export something
	if(export)
		set(internal_defs ${comp_exp_defs} ${dep_defs})
		manage_Additional_Component_Exported_Flags(${component} "${TARGET_SUFFIX}" "" "${internal_defs}" "" "")

		target_include_directories(${component}${TARGET_SUFFIX} INTERFACE
			$<TARGET_PROPERTY:${dep_component}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)

		target_compile_definitions(${component}${TARGET_SUFFIX} INTERFACE
			$<TARGET_PROPERTY:${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)

		target_compile_options(${component}${TARGET_SUFFIX} INTERFACE
			$<TARGET_PROPERTY:${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>)

		target_link_libraries(${component}${TARGET_SUFFIX} INTERFACE ${dep_component}${TARGET_SUFFIX})

	else()
		manage_Additional_Component_Exported_Flags(${component} "${TARGET_SUFFIX}" "" "${comp_exp_defs}" "" "")
		if(NOT ${PROJECT_NAME}_${component}_TYPE STREQUAL "SHARED")#static OR header lib always export links
			target_link_libraries(${component}${TARGET_SUFFIX} INTERFACE ${dep_component}${TARGET_SUFFIX})
		endif()
		#else non exported shared
	endif()

endif()	#else, it is an application or a module => runtime dependency declaration only
endfunction(bind_Internal_Target)

### bind an imported target with another imported target
function(bind_Imported_Target package component dep_package dep_component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
export_Component(IS_EXPORTING ${package} ${component} ${dep_package} ${dep_component} ${mode})
is_HeaderFree_Component(DEP_IS_HF ${dep_package} ${dep_component})
if(NOT DEP_IS_HF)#the required package component is a library with header it can export something
	if(IS_EXPORTING)

		set_property(TARGET ${package}-${component}${TARGET_SUFFIX} APPEND PROPERTY
			INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>
		)
		set_property(TARGET ${package}-${component}${TARGET_SUFFIX} APPEND PROPERTY
			INTERFACE_COMPILE_DEFINITIONS $<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>
		)
		set_property(TARGET ${package}-${component}${TARGET_SUFFIX} APPEND PROPERTY
			INTERFACE_COMPILE_OPTIONS $<TARGET_PROPERTY:${dep_package}-${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>
		)
		set_property(TARGET ${package}-${component}${TARGET_SUFFIX} APPEND PROPERTY
			INTERFACE_LINK_LIBRARIES ${dep_package}-${dep_component}${TARGET_SUFFIX}
		)
	else()
		if(NOT ${package}_${component}_TYPE STREQUAL "SHARED")#static OR header lib always export links
			set_property(TARGET ${package}-${component}${TARGET_SUFFIX} APPEND PROPERTY
				INTERFACE_LINK_LIBRARIES ${dep_package}-${dep_component}${TARGET_SUFFIX}
			)
		endif()
	endif()#exporting the linked libraries in any case

	# set adequately language standard for component depending on the value of dep_component
	resolve_Standard_Before_Linking(${package} ${component} ${dep_package} ${dep_component} ${mode} FALSE)

endif()	#else, it is an application or a module => runtime dependency declaration only (build recursion is stopped)
endfunction(bind_Imported_Target)


function (fill_Component_Target_With_Dependency component dep_package dep_component mode export comp_defs comp_exp_defs dep_defs)
if(${PROJECT_NAME} STREQUAL ${dep_package})#target already created elsewhere since internal target
	bind_Internal_Target(${component} ${dep_component} ${mode} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
else()# it is a dependency to another package
	create_Dependency_Target(${dep_package} ${dep_component} ${mode})
	bind_Target(${component} ${dep_package} ${dep_component} ${mode} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
endif()
endfunction(fill_Component_Target_With_Dependency)
