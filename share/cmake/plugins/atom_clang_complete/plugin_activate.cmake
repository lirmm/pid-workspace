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

include(PID_Utils_Functions)

## subsudiary function to get the folder path depending on component type
function(get_Dir_Path_For_Component RET_SOURCE_PATH RET_HEADER_PATH component)
set(${RET_SOURCE_PATH} PARENT_SCOPE)
set(${RET_HEADER_PATH} PARENT_SCOPE)
if(NOT ${PROJECT_NAME}_${component}_TYPE)
	return()
endif()

if(${PROJECT_NAME}_${component}_TYPE STREQUAL "APP")
	set(${RET_SOURCE_PATH} ${CMAKE_SOURCE_DIR}/apps/${${PROJECT_NAME}_${component}_SOURCE_DIR} PARENT_SCOPE)
elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "EXAMPLE")
	set(${RET_SOURCE_PATH} ${CMAKE_SOURCE_DIR}/apps/${${PROJECT_NAME}_${component}_SOURCE_DIR} PARENT_SCOPE)
elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "TEST")
	set(${RET_SOURCE_PATH} ${CMAKE_SOURCE_DIR}/test/${${PROJECT_NAME}_${component}_SOURCE_DIR} PARENT_SCOPE)
elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "MODULE")
	set(${RET_SOURCE_PATH} ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_${component}_SOURCE_DIR} PARENT_SCOPE)
elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "STATIC")
	set(${RET_SOURCE_PATH} ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_${component}_SOURCE_DIR} PARENT_SCOPE)
	set(${RET_HEADER_PATH} ${CMAKE_SOURCE_DIR}/include/${${PROJECT_NAME}_${component}_HEADER_DIR_NAME} PARENT_SCOPE)
elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "SHARED")
	set(${RET_SOURCE_PATH} ${CMAKE_SOURCE_DIR}/src/${${PROJECT_NAME}_${component}_SOURCE_DIR} PARENT_SCOPE)
	set(${RET_HEADER_PATH} ${CMAKE_SOURCE_DIR}/include/${${PROJECT_NAME}_${component}_HEADER_DIR_NAME} PARENT_SCOPE)
elseif(${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")
	set(${RET_HEADER_PATH} ${CMAKE_SOURCE_DIR}/include/${${PROJECT_NAME}_${component}_HEADER_DIR_NAME} PARENT_SCOPE)
endif()

endfunction(get_Dir_Path_For_Component)

## subsidiary function to fill the .clang_complete file
function(write_In_Clang_Complete_File path_to_file target_component)
#the generated file is based on generator expressions to be able to deal with targets properties
if(${PROJECT_NAME}_${target_component}_TYPE STREQUAL HEADER)
	set(COMPONENT_INC_FLAGS $<TARGET_PROPERTY:${target_component},INTERFACE_INCLUDE_DIRECTORIES>)
	set(COMPONENT_DEF_FLAGS $<TARGET_PROPERTY:${target_component},INTERFACE_COMPILE_DEFINITIONS>)
	set(COMPONENT_OPT_FLAGS $<TARGET_PROPERTY:${target_component},INTERFACE_COMPILE_OPTIONS>)

else()
	set(COMPONENT_INC_FLAGS $<TARGET_PROPERTY:${target_component},INCLUDE_DIRECTORIES>)
	set(COMPONENT_DEF_FLAGS $<TARGET_PROPERTY:${target_component},COMPILE_DEFINITIONS>)
	set(COMPONENT_OPT_FLAGS $<TARGET_PROPERTY:${target_component},COMPILE_OPTIONS>)
endif()

if(NOT CMAKE_VERSION VERSION_LESS 3.1)#starting 3.1 the C and CXX standards are managed the good way by CMake (with target properties)
    set(ALREADY_IN_COMPILE_OPTIONS FALSE)
    if(CMAKE_VERSION VERSION_LESS 3.8)#starting for 3.8, if standard is 17 or more we use the old way to do (CMake does not know this standard, so it has been translated into a compile option by PID)
        is_CXX_Version_Less(IS_LESS ${${PROJECT_NAME}_${target_component}_CXX_STANDARD} 17)
        if(NOT IS_LESS)#if version of the standard is more or equal than 17 then use the classical way of doing (PID has generate compile options already)
            set(ALREADY_IN_COMPILE_OPTIONS TRUE)# do not used information from target in that specific case as it has already been translated
        endif()
    endif()

    if(NOT ALREADY_IN_COMPILE_OPTIONS)# we have to extract information from the CMake property
        translate_Standard_Into_Option(C_LANGUAGE_OPT CXX_LANGUAGE_OPT ${${PROJECT_NAME}_${target_component}_C_STANDARD} ${${PROJECT_NAME}_${target_component}_CXX_STANDARD})
    endif()
endif()

#preparing test expression -> getting generator expression resolved content (remove the list to get only one appended element) and test if there is any element
set(OPT_CONTENT_EXIST $<BOOL:$<JOIN:${COMPONENT_OPT_FLAGS},>>)#deal with empty list
set(DEF_CONTENT_EXIST $<BOOL:$<JOIN:${COMPONENT_DEF_FLAGS},>>)#deal with empty list
set(INC_CONTENT_EXIST $<BOOL:$<JOIN:${COMPONENT_INC_FLAGS},>>)#deal with empty list

#merging all flags together to put them in a file
set(ALL_OPTS_LINES $<${OPT_CONTENT_EXIST}:$<JOIN:${COMPONENT_OPT_FLAGS},\n>>)
if(USE_CMAKE_TARGETS)
	set(ALL_OPTS_LINES "${ALL_OPTS_LINES}\n${CXX_LANGUAGE_OPT}\n${C_LANGUAGE_OPT}")
endif()

set(ALL_DEFS_LINES $<${DEF_CONTENT_EXIST}:$<${OPT_CONTENT_EXIST}:\n>-D$<JOIN:${COMPONENT_DEF_FLAGS},\n-D>>)
set(ALL_INCS_LINES $<${INC_CONTENT_EXIST}:$<$<OR:${OPT_CONTENT_EXIST},${DEF_CONTENT_EXIST}>:\n>-I$<JOIN:${COMPONENT_INC_FLAGS},\n-I>>)

#generating the file at generation time (after configuration ends)
if(EXISTS ${path_to_file})
	file(REMOVE ${path_to_file})
endif()
file(GENERATE OUTPUT ${path_to_file} CONTENT "${ALL_OPTS_LINES}${ALL_DEFS_LINES}${ALL_INCS_LINES}")
endfunction(write_In_Clang_Complete_File)

## subsidiary function that generate a .clang_complete file for a source directory of the package
function(generate_Clang_Complete_File target_dir)
set(COMPONENTS_FOR_DIR)
get_filename_component(FOLDER_NAME ${target_dir} NAME)
get_filename_component(FULL_FOLDER ${target_dir} DIRECTORY)
get_filename_component(CONTAINER_FOLDER_NAME ${FULL_FOLDER} NAME)
set(FOLDER_IDENTIFIER ${CONTAINER_FOLDER_NAME}/${FOLDER_NAME})

# 1) finding all components that use this folder
foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	get_Dir_Path_For_Component(RET_SOURCE_PATH RET_HEADER_PATH ${component})
	if(RET_SOURCE_PATH AND target_dir STREQUAL RET_SOURCE_PATH)
		list(APPEND COMPONENTS_FOR_DIR ${component})
	elseif(RET_HEADER_PATH AND target_dir STREQUAL RET_HEADER_PATH)
		list(APPEND COMPONENTS_FOR_DIR ${component})
	endif()
endforeach()

# 2) now creating options if there are more than one component for a given directory
list(LENGTH COMPONENTS_FOR_DIR SIZE)
if(SIZE GREATER 1)
	list(GET COMPONENTS_FOR_DIR 0 DEFAULT_COMP)
	set(PLUGIN_CLANG_COMPLETE_TARGET_COMPONENT_FOR_${FOLDER_IDENTIFIER} ${DEFAULT_COMP} CACHE STRING "Set the component to be used by clang complete when dealing with directory ${FOLDER_IDENTIFIER}")
	# verifying if the target component exists
	list(FIND ${PROJECT_NAME}_COMPONENTS ${PLUGIN_CLANG_COMPLETE_TARGET_COMPONENT_FOR_${FOLDER_IDENTIFIER}} INDEX)
	if(INDEX EQUAL -1) # component not found
		message("[PID] WARNING: the component ${PLUGIN_CLANG_COMPLETE_TARGET_COMPONENT_FOR_${FOLDER_IDENTIFIER}} specified for directory ${FOLDER_IDENTIFIER} clang complete file, is unknown.")
		return()
	endif()
elseif(SIZE EQUAL 1)
	set(PLUGIN_CLANG_COMPLETE_TARGET_COMPONENT_FOR_${FOLDER_IDENTIFIER} ${COMPONENTS_FOR_DIR} CACHE INTERNAL "")
else() #no component for that folder,this folder is not used as an include folder for other components or as a sorce folder (maybe a temporary folder => do not manage it)
	return()
endif()


# 3) Getting the flags from all components using this folder and generating the resulting .clang_complete file for this folder
set(TARGET_FILE ${target_dir}/.clang_complete)
write_In_Clang_Complete_File(${TARGET_FILE} ${PLUGIN_CLANG_COMPLETE_TARGET_COMPONENT_FOR_${FOLDER_IDENTIFIER}})
endfunction(generate_Clang_Complete_File)

## main script

if(CMAKE_BUILD_TYPE MATCHES Release) #only generating in release mode

	if(${PROJECT_NAME}_COMPONENTS) #if no component => nothing to build so no need of a clang complete

		list_Subdirectories(HEADERS_DIRS ${CMAKE_SOURCE_DIR}/include)

		foreach(dir IN ITEMS ${HEADERS_DIRS})
			generate_Clang_Complete_File(${CMAKE_SOURCE_DIR}/include/${dir})
		endforeach()

		list_Subdirectories(SOURCES_DIRS ${CMAKE_SOURCE_DIR}/src)

		foreach(dir IN ITEMS ${SOURCES_DIRS})
			generate_Clang_Complete_File(${CMAKE_SOURCE_DIR}/src/${dir})
		endforeach()

		list_Subdirectories(APPS_DIRS ${CMAKE_SOURCE_DIR}/apps)

		foreach(dir IN ITEMS ${APPS_DIRS})
			generate_Clang_Complete_File(${CMAKE_SOURCE_DIR}/apps/${dir})
		endforeach()

		list_Subdirectories(TESTS_DIRS ${CMAKE_SOURCE_DIR}/test)

		foreach(dir IN ITEMS ${TESTS_DIRS})
			generate_Clang_Complete_File(${CMAKE_SOURCE_DIR}/test/${dir})
		endforeach()

	endif()

endif()
