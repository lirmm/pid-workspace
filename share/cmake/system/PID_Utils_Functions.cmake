
### printing variables for components in the package ################
macro(print_Component component)
	message("COMPONENT : ${component}${INSTALL_NAME_SUFFIX}")
	message("INTERFACE : ")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_INCLUDE_DIRECTORIES)
		message("includes of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INTERFACE_COMPILE_DEFINITIONS)
		message("defs of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} LINK_INTERFACE_LIBRARIES)
		message("libraries of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")		
		
	message("IMPLEMENTATION :")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} INCLUDE_DIRECTORIES)
		message("includes of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} COMPILE_DEFINITIONS)
		message("defs of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
		get_target_property(RES_VAR ${component}${INSTALL_NAME_SUFFIX} LINK_LIBRARIES)
		message("libraries of ${component}${INSTALL_NAME_SUFFIX} = ${RES_VAR}")
endmacro(print_Component)

macro(print_Component_Variables)
	message("components of package ${PROJECT_NAME} are :" ${${PROJECT_NAME}_COMPONENTS})
	message("libraries : " ${${PROJECT_NAME}_COMPONENTS_LIBS})
	message("applications : " ${${PROJECT_NAME}_COMPONENTS_APPS})

	foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
		print_Component(${component})	
	endforeach()
endmacro(print_Component_Variables)

###
function(is_A_System_Reference_Path path IS_SYSTEM)

if(UNIX)
	if(path STREQUAL / OR path STREQUAL /usr OR path STREQUAL /usr/local)
		set(${IS_SYSTEM} TRUE PARENT_SCOPE)
	else()
		set(${IS_SYSTEM} FALSE PARENT_SCOPE)
	endif()
endif()

if(APPLE AND NOT ${IS_SYSTEM})
	if(path STREQUAL /Library/Frameworks OR path STREQUAL /Network/Library/Frameworks OR path STREQUAL /System/Library/Framework)
		set(${IS_SYSTEM} TRUE PARENT_SCOPE)
	endif()
endif()

endfunction(is_A_System_Reference_Path)

###
function(extract_All_Words name_with_underscores all_words_in_list)
set(res "")
string(REPLACE "_" ";" res "${name_with_underscores}")
set(${all_words_in_list} ${res} PARENT_SCOPE)
endfunction()

###
function(fill_List_Into_String input_list res_string)
set(res "")
foreach(element IN ITEMS ${input_list})
	set(res "${res} ${element}")
endforeach()
string(STRIP "${res}" res_finished)
set(${res_string} ${res_finished} PARENT_SCOPE)
endfunction()

###
function(create_Symlink path_to_old path_to_new)
if(	EXISTS ${path_to_new} AND IS_SYMLINK ${path_to_new})
	execute_process(#removing the existing symlink
		COMMAND ${CMAKE_COMMAND} -E remove -f ${path_to_new}
	)
endif()
execute_process(
	COMMAND ${CMAKE_COMMAND} -E create_symlink ${path_to_old} ${path_to_new}
)
endfunction(create_Symlink)

###
function(create_Rpath_Symlink path_to_target path_to_rpath_folder rpath_sub_folder)
#first creating the path where to put symlinks if it does not exist
set(FULL_RPATH_DIR ${path_to_rpath_folder}/.rpath/${rpath_sub_folder})
file(MAKE_DIRECTORY ${FULL_RPATH_DIR})
get_filename_component(A_FILE ${path_to_target} NAME)
#second creating the symlink
create_Symlink(${path_to_target} ${FULL_RPATH_DIR}/${A_FILE})
endfunction(create_Rpath_Symlink)

###
function(install_Rpath_Symlink path_to_target path_to_rpath_folder rpath_sub_folder)
get_filename_component(A_FILE "${path_to_target}" NAME)
set(FULL_RPATH_DIR ${path_to_rpath_folder}/.rpath/${rpath_sub_folder})
install(DIRECTORY DESTINATION ${FULL_RPATH_DIR}) #create the folder that will contain symbolic links to runtime resources used by the component (will allow full relocation of components runtime dependencies at install time)
install(CODE "
	##create_Rpath_Symlink(${lib} ${${PROJECT_NAME}_DEPLOY_PATH} ${bin_component})
	if(EXISTS ${FULL_RPATH_DIR}/${A_FILE} AND IS_SYMLINK ${FULL_RPATH_DIR}/${A_FILE})
		execute_process(COMMAND ${CMAKE_COMMAND} -E remove -f ${FULL_RPATH_DIR}/${A_FILE}
				WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX})
	endif()
	message(\" creating link to ${path_to_target} as ${FULL_RPATH_DIR}/${A_FILE}\")
	execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink ${path_to_target} ${FULL_RPATH_DIR}/${A_FILE}
				WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX})
	message(\"-- Installing: ${FULL_RPATH_DIR}/${A_FILE}\")

")# creating links "on the fly" when installing

endfunction(install_Rpath_Symlink)
