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

set(OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/share/static_checks_result.xml)

function(cat in_file errors_list RET_LIST)
	set(to_append ${errors_list})
	file(STRINGS ${in_file} ALL_LINES) #getting global info on the package
	foreach(line IN ITEMS ${ALL_LINES})
		string(REGEX MATCH "^[ \t]*<error.*$" A_RESULT ${line}) #if it is an error then report it
		if(A_RESULT)
			list(APPEND to_append ${A_RESULT})
		endif()
	endforeach()
	set(${RET_LIST} ${to_append} PARENT_SCOPE)
endfunction()

# Prepare a temporary file to "cat" to:
file(WRITE ${OUTPUT_FILE} "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<results>\n")
file(GLOB LIST_OF_FILES "${CMAKE_CURRENT_BINARY_DIR}/share/static_checks_result_*.xml")

# Call the "cat" function for each input file
set(LIST_OF_ERRORS)

foreach(in_file ${LIST_OF_FILES})
  cat(${in_file} "${LIST_OF_ERRORS}" LIST_OF_ERRORS)
endforeach()

list(REMOVE_DUPLICATES LIST_OF_ERRORS)
if(LIST_OF_ERRORS)
	foreach(error ${LIST_OF_ERRORS})
		file(APPEND ${OUTPUT_FILE} "${error}")
	endforeach()
endif()
file(APPEND ${OUTPUT_FILE} "\n</results>\n")
