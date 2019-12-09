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

include(Configuration_Definition NO_POLICY_SCOPE)

found_PID_Configuration(processor FALSE)
set(FLAGS_FOR_OPTIMS)

if(processor_optimizations STREQUAL "all")
	foreach(opt IN LISTS CURRENT_SPECIFIC_INSTRUCTION_SET)
		foreach(flag IN LISTS CPU_${opt}_FLAGS)#these variables can themselves contain list
			set(FLAGS_FOR_OPTIMS "${FLAGS_FOR_OPTIMS} ${flag}")
		endforeach()
	endforeach()
	#need also to give the adequate value to teh cahche variable that will be written in binaries
	set(processor_optimizations ${CURRENT_SPECIFIC_INSTRUCTION_SET} CACHE INTERNAL "")
else()#only a subset of all processor instructions is required, check if they exist
	foreach(opt IN LISTS processor_optimizations)
		list(FIND CURRENT_SPECIFIC_INSTRUCTION_SET ${opt} INDEX)
		if(INDEX EQUAL -1)
			return()
		else()
			foreach(flag IN LISTS CPU_${opt}_FLAGS)#these variables can themselves contain list
				set(FLAGS_FOR_OPTIMS "${FLAGS_FOR_OPTIMS} ${flag}")
			endforeach()
		endif()
	endforeach()
endif()

found_PID_Configuration(processor TRUE)#all required processor optimizations have been found
