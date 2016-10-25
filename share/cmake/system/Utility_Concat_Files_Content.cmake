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

if(NOT OUTPUT_FILE)
	message(FATAL_ERROR "[PID] ERROR : you must define an output where to write the conatctenated content of files")
endif()

if(NOT PATTERN)
	message(FATAL_ERROR "[PID] ERROR : you must define a pattern for files to read.")
endif()


function(cat IN_FILE OUT_FILE)
  file(READ ${IN_FILE} CONTENTS)
  file(APPEND ${OUT_FILE} "${CONTENTS}")
endfunction()

# Prepare a temporary file to "cat" to:
file(WRITE ${OUTPUT_FILE} "")
file(GLOB LIST_OF_FILES "${PATTERN}*${EXTENSION}")
list(REMOVE_DUPLICATES LIST_OF_FILES)
list(REMOVE_ITEM LIST_OF_FILES ${OUTPUT_FILE}) #caution: suppress the output from the inputs (if needed)

# Call the "cat" function for each input file
foreach(in_file ${LIST_OF_FILES})
  cat(${in_file} ${OUTPUT_FILE})
endforeach()



