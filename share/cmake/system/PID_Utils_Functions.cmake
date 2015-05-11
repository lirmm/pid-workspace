
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
	execute_process(COMMAND ${CMAKE_COMMAND} -E create_symlink ${path_to_target} ${FULL_RPATH_DIR}/${A_FILE}
				WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX})
	message(\"-- Installing: ${FULL_RPATH_DIR}/${A_FILE}\")

")# creating links "on the fly" when installing

endfunction(install_Rpath_Symlink)

###
function (check_Directory_Exists is_existing path)
if(	EXISTS "${path}" 
	AND IS_DIRECTORY "${path}"
  )
	set(${is_existing} TRUE PARENT_SCOPE)
	return()
endif()
set(${is_existing} FALSE PARENT_SCOPE)
endfunction(check_Directory_Exists)

###
function(get_Version_String_Numbers version_string major minor patch)
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$" "\\1;\\2;\\3" A_VERSION "${version_string}")
if(NOT A_VERSION STREQUAL "${version_string}")
	list(GET A_VERSION 0 major_vers)
	list(GET A_VERSION 1 minor_vers)
	list(GET A_VERSION 2 patch_vers)
	set(${major} ${major_vers} PARENT_SCOPE)
	set(${minor} ${minor_vers} PARENT_SCOPE)
	set(${patch} ${patch_vers} PARENT_SCOPE)
else()
	message(FATAL_ERROR "BUG : corrupted version string : ${version_string}")
endif()	
endfunction(get_Version_String_Numbers)

###
function (document_Version_Strings package_name major minor patch)
	set(${package_name}_VERSION_MAJOR ${major} CACHE INTERNAL "")
	set(${package_name}_VERSION_MINOR ${minor} CACHE INTERNAL "")
	set(${package_name}_VERSION_PATCH ${patch} CACHE INTERNAL "")
	set(${package_name}_VERSION_STRING "${major}.${minor}.${patch}" CACHE INTERNAL "")
	set(${package_name}_VERSION_RELATIVE_PATH "${major}.${minor}.${patch}" CACHE INTERNAL "")
endfunction(document_Version_Strings)

###
function(list_Version_Subdirectories result curdir)
	file(GLOB children RELATIVE ${curdir} ${curdir}/*)
	set(dirlist "")
	foreach(child ${children})
		if(IS_DIRECTORY ${curdir}/${child})
			list(APPEND dirlist ${child})
		endif()
	endforeach()
	list(REMOVE_ITEM dirlist "installers")
	set(${result} ${dirlist} PARENT_SCOPE)
endfunction(list_Version_Subdirectories)


###
function(is_Compatible_Version is_compatible reference_major reference_minor version_to_compare)
set(${is_compatible} FALSE PARENT_SCOPE)
get_Version_String_Numbers("${version_to_compare}.0" compare_major compare_minor compared_patch)
if(	NOT ${compare_major} EQUAL ${reference_major}
	OR ${compare_minor} GREATER ${reference_minor})
	return()#not compatible
endif()
set(${is_compatible} TRUE PARENT_SCOPE)
endfunction(is_Compatible_Version)


###
function(generate_Full_Author_String author RES_STRING)
string(REGEX REPLACE "^([^\\(]+)\\(([^\\)]*)\\)$" "\\1;\\2" author_institution "${author}")
list(GET author_institution 0 AUTHOR_NAME)
list(GET author_institution 1 INSTITUTION_NAME)
extract_All_Words("${AUTHOR_NAME}" AUTHOR_ALL_WORDS)
extract_All_Words("${INSTITUTION_NAME}" INSTITUTION_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
fill_List_Into_String("${INSTITUTION_ALL_WORDS}" INSTITUTION_STRING)
if(NOT INSTITUTION_STRING STREQUAL "")
	set(${RES_STRING} "${AUTHOR_STRING} (${INSTITUTION_STRING})" PARENT_SCOPE)
else()
	set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
endif()
endfunction()

###
function(generate_Contact_String author mail RES_STRING)
extract_All_Words("${author}" AUTHOR_ALL_WORDS)
fill_List_Into_String("${AUTHOR_ALL_WORDS}" AUTHOR_STRING)
if(mail AND NOT mail STREQUAL "")
	set(${RES_STRING} "${AUTHOR_STRING} (${mail})" PARENT_SCOPE)
else()
	set(${RES_STRING} "${AUTHOR_STRING}" PARENT_SCOPE)
endif()
endfunction()

###
function(generate_Institution_String institution RES_STRING)
extract_All_Words("${institution}" INSTITUTION_ALL_WORDS)
fill_List_Into_String("${INSTITUTION_ALL_WORDS}" INSTITUTION_STRING)
set(${RES_STRING} "${INSTITUTION_STRING}" PARENT_SCOPE)
endfunction()

###
function(get_All_Sources_Relative RESULT dir)
file(	GLOB_RECURSE 
	RES
	RELATIVE ${dir} 
	"${dir}/*.c"
	"${dir}/*.cc"
	"${dir}/*.cpp"
	"${dir}/*.cxx"
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.hh"
	"${dir}/*.hxx"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Sources_Relative)

###
function(get_All_Sources_Absolute RESULT dir)
file(	GLOB_RECURSE 
	RES
	${dir} 
	"${dir}/*.c"
	"${dir}/*.cc"
	"${dir}/*.cpp"
	"${dir}/*.cxx"
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.hh"
	"${dir}/*.hxx"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Sources_Absolute)

###
function(get_All_Headers_Relative RESULT dir)
file(	GLOB_RECURSE 
	RES
	RELATIVE ${dir} 
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.hh"
	"${dir}/*.hxx"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Headers_Relative)

###
function(get_All_Headers_Absolute RESULT dir)
file(	GLOB_RECURSE 
	RES
	${dir} 
	"${dir}/*.h"
	"${dir}/*.hpp"
	"${dir}/*.hh"
	"${dir}/*.hxx"
)
set (${RESULT} ${RES} PARENT_SCOPE)
endfunction(get_All_Headers_Absolute)

###
function(is_Shared_Lib_With_Path SHARED input_link)
set(${SHARED} FALSE PARENT_SCOPE)
get_filename_component(LIB_TYPE ${input_link} EXT)
if(LIB_TYPE)
	if(APPLE) 		
		if(LIB_TYPE MATCHES "^\\.dylib(\\.[^\\.]+)*$")#found shared lib
			set(${SHARED} TRUE PARENT_SCOPE)
		endif()
	elseif(UNIX)
		if(LIB_TYPE MATCHES "^\\.so(\\.[^\\.]+)*$")#found shared lib
			set(${SHARED} TRUE PARENT_SCOPE)
		endif()
	endif()
endif()
endfunction(is_Shared_Lib_With_Path)


