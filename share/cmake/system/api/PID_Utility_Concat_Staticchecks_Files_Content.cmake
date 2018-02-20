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

set(OUTPUT_FILE ${CMAKE_CURRENT_BINARY_DIR}/share/static_checks_result.xml)

function(cat in_file out_file)
	file(STRINGS ${in_file} ALL_LINES) #getting global info on the package
	foreach(line IN LISTS ALL_LINES)
		string(REGEX MATCH "^[ \t]*<(/?results|/?errors|\\?xml|cppcheck).*$" BEGINEND_TAG ${line}) #if it is an error then report it
		if(NOT BEGINEND_TAG)
			file(APPEND ${out_file} "${line}\n")
		endif()
	endforeach()
endfunction()

function(extract_Header in_file out_file)
	set(to_append)
	file(STRINGS ${in_file} ALL_LINES) #getting global info on the package
	foreach(line IN LISTS ${ALL_LINES})
		string(REGEX MATCH "^[ \t]*<(/results|/errors)>.*$" END_TAG ${line}) #if it is an error then report it
		if(NOT END_TAG)
			file(APPEND ${out_file} "${line}\n")
		endif()
	endforeach()
endfunction()

# Prepare a temporary file to "cat" to:
file(WRITE ${OUTPUT_FILE} "") #reset output
file(GLOB LIST_OF_FILES "${CMAKE_CURRENT_BINARY_DIR}/share/static_checks_result_*.xml")

# concatenating the content of xml files
set(FIRST_FILE TRUE)
foreach(in_file IN LISTS LIST_OF_FILES)
	if(FIRST_FILE)
		extract_Header(${in_file} ${OUTPUT_FILE})
  		set(FIRST_FILE FALSE)
	else()
		cat(${in_file} ${OUTPUT_FILE})
	endif()
endforeach()

file(APPEND ${OUTPUT_FILE} "\n\t</errors>\n</results>\n")
