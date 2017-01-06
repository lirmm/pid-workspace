#########################################################################################
#	This file is part of the program PID						#
#  	Program description : build system supportting the PID methodology  		#
#  	Copyright (C) Robin Passama, LIRMM (Laboratoire d'Informatique de Robotique 	#
#	et de Microelectronique de Montpellier). All Right reserved.			#
#											#
#	This software is free software: you can redistribute it and/or modify		#
#	it under the terms of the CeCILL-C license as published by			#
#	the CEA CNRS INRIA, either version 1						#
#	of the License, or (at your option) any later version.				#
#	This software is distributed in the hope that it will be useful,		#
#	but WITHOUT ANY WARRANTY; without even the implied warranty of			#
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the			#
#	CeCILL-C License for more details.						#
#											#
#	You can find the complete license description on the official website 		#
#	of the CeCILL licenses family (http://www.cecill.info/index.en.html)		#
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
function(write_In_Clang_Complete_File path_to_file list_of_components)
message("------------ ${path_to_file} --------------")
#the generated file is based on generator expressions to be able to deal with targets properties
set(INC_FLAGS_CONTENT)
set(DEF_FLAGS_CONTENT)
set(OPT_FLAGS_CONTENT)

#grouping properties of components, by category
foreach(component IN ITEMS ${list_of_components})
	#includes
	set(COMPONENT_INC_FLAGS $<TARGET_PROPERTY:${component},INCLUDE_DIRECTORIES>)
	set(INC_TO_ADD $<$<BOOL:${COMPONENT_INC_FLAGS}>:-I$<JOIN:${COMPONENT_INC_FLAGS},$<SEMICOLON>-I>>)
	list(APPEND INC_FLAGS_CONTENT ${INC_TO_ADD})

	#definitions
	set(COMPONENT_DEF_FLAGS $<TARGET_PROPERTY:${component},COMPILE_DEFINITIONS>)
	set(DEF_TO_ADD $<$<BOOL:${COMPONENT_DEF_FLAGS}>:-D$<JOIN:${COMPONENT_DEF_FLAGS},$<SEMICOLON>-D>>)
	list(APPEND DEF_FLAGS_CONTENT ${DEF_TO_ADD})
	
	#options
	set(COMPONENT_OPT_FLAGS $<TARGET_PROPERTY:${component},COMPILE_OPTIONS>)
	set(OPT_TO_ADD $<$<BOOL:${COMPONENT_OPT_FLAGS}>:$<JOIN:${COMPONENT_OPT_FLAGS},$<SEMICOLON>>>)
	#if(OPT_FLAGS_CONTENT)
	#	set(OPT_FLAGS_CONTENT $<$<BOOL:${OPT_FLAGS_CONTENT}>,${OPT_FLAGS_CONTENT}$<SEMICOLON>${OPT_TO_ADD}>$<$<NOT:$<BOOL:${OPT_FLAGS_CONTENT}>>,${OPT_TO_ADD}>)
	#else()
	#	set(OPT_FLAGS_CONTENT ${OPT_TO_ADD})
	#endif()
	list(APPEND OPT_FLAGS_CONTENT ${OPT_TO_ADD})
	
endforeach()


message("INC_FLAGS_CONTENT:")
foreach(member IN ITEMS ${INC_FLAGS_CONTENT})
message(" + ${member}")
endforeach()


message("COMPONENT_OPT_FLAGS:")
foreach(member IN ITEMS ${OPT_FLAGS_CONTENT})
message(" + ${member}")
endforeach()


message("DEF_FLAGS_CONTENT:")
foreach(member IN ITEMS ${DEF_FLAGS_CONTENT})
message(" + ${member}")
endforeach()
message("----------------------------------------")

#preparing merge expression
set(OPT_CONTENT_EXIST $<BOOL:${OPT_FLAGS_CONTENT}>)
set(DEF_CONTENT_EXIST $<BOOL:${DEF_FLAGS_CONTENT}>)
set(INC_CONTENT_EXIST $<BOOL:${INC_FLAGS_CONTENT}>)
set(OPT_CONTENT_DOESNT_EXIST $<NOT:${OPT_CONTENT_EXIST}>)
set(DEF_CONTENT_DOESNT_EXIST $<NOT:${DEF_CONTENT_EXIST}>)
set(INC_CONTENT_DOESNT_EXIST $<NOT:${INC_CONTENT_EXIST}>)

set(STUPID_DEBUG_STRING_OPT "$<${OPT_CONTENT_EXIST}:EXIST-$<JOIN:${OPT_FLAGS_CONTENT}, EXIST->+>$<${OPT_CONTENT_DOESNT_EXIST}:OPT DOES NOT EXIST !!>")
set(STUPID_DEBUG_STRING_DEF "$<${DEF_CONTENT_EXIST}:EXIST-$<JOIN:${DEF_FLAGS_CONTENT}, EXIST->+>$<${DEF_CONTENT_DOESNT_EXIST}:DEF DOES NOT EXIST !!>")
set(STUPID_DEBUG_STRING_INC "$<${INC_CONTENT_EXIST}:EXIST-$<JOIN:${INC_FLAGS_CONTENT}, EXIST->+>$<${INC_CONTENT_DOESNT_EXIST}:INC DOES NOT EXIST !!>")
set(STUPID_DEBUG_STRING "-------------\n${STUPID_DEBUG_STRING_OPT}\n${STUPID_DEBUG_STRING_DEF}\n${STUPID_DEBUG_STRING_INC}\n-------------\n")

#merging all flags together to put them in a file
set(ALL_OPTS_LINES $<${OPT_CONTENT_EXIST}:$<JOIN:${OPT_FLAGS_CONTENT},\n>>$<${OPT_CONTENT_DOESNT_EXIST}:>)
set(ALL_DEFS_LINES $<${DEF_CONTENT_EXIST}:$<${OPT_CONTENT_EXIST}:\n>$<JOIN:${DEF_FLAGS_CONTENT},\n>>$<${DEF_CONTENT_DOESNT_EXIST}:>)
set(ALL_INCS_LINES $<${INC_CONTENT_EXIST}:$<$<OR:${OPT_CONTENT_EXIST},${DEF_CONTENT_EXIST}>:\n>$<JOIN:${INC_FLAGS_CONTENT},\n>>$<${INC_CONTENT_DOESNT_EXIST}:>)

#generating the file at generation time (after configuration ends)
if(EXISTS ${path_to_file})
	file(REMOVE ${path_to_file})
endif()
file(GENERATE OUTPUT ${path_to_file} CONTENT "${STUPID_DEBUG_STRING}\n${ALL_OPTS_LINES}${ALL_DEFS_LINES}${ALL_INCS_LINES}")
endfunction(write_In_Clang_Complete_File)

## subsidiary function that generate a .clang_complete file for a source directory of the package
function(generate_Clang_Complete_File target_dir)
set(COMPONENTS_FOR_DIR)
# 1) finding all components that use this folder
foreach(component IN ITEMS ${${PROJECT_NAME}_COMPONENTS})
	get_Dir_Path_For_Component(RET_SOURCE_PATH RET_HEADER_PATH ${component})	
	if(RET_SOURCE_PATH AND target_dir STREQUAL RET_SOURCE_PATH)
		list(APPEND COMPONENTS_FOR_DIR ${component})
	elseif(RET_HEADER_PATH AND target_dir STREQUAL RET_HEADER_PATH)
		list(APPEND COMPONENTS_FOR_DIR ${component})
	endif()
endforeach()

# 2) Getting the flags from all components using this folder and generating the resulting .clang_complete file for this folder
set(TARGET_FILE ${target_dir}/.clang_complete)
write_In_Clang_Complete_File(${TARGET_FILE} "${COMPONENTS_FOR_DIR}")
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
