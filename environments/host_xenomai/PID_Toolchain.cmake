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

execute_process(COMMAND which xeno-config RESULT_VARIABLE res OUTPUT_VARIABLE XENO_CONFIG_PATH OUTPUT_STRIP_TRAILING_WHITESPACE)
if(NOT res)
	execute_process(COMMAND ${XENO_CONFIG_PATH} --skin=posix --cflags OUTPUT_VARIABLE XENO_CFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
	execute_process(COMMAND ${XENO_CONFIG_PATH} --skin=posix --ldflags OUTPUT_VARIABLE XENO_LDFLAGS OUTPUT_STRIP_TRAILING_WHITESPACE)
	execute_process(COMMAND ${XENO_CONFIG_PATH} --library-dir OUTPUT_VARIABLE XENO_LIBS_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)

	set(xenomai_LINKS ${XENO_LDFLAGS} -L${XENO_LIBS_DIR} -lcobalt)
	set(xenomai_CFLAGS ${XENO_CFLAGS})

	#setting compiler variables
	set(CMAKE_C_COMPILER "${XENO_CONFIG_PATH} -cc")
	set(CMAKE_CXX_COMPILER "${XENO_CONFIG_PATH} -cxx")

	set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} ${xenomai_CFLAGS})
	set(CMAKE_CXX_FLAGS_DEBUG ${CMAKE_CXX_FLAGS_DEBUG} ${xenomai_CFLAGS})
	set(CMAKE_CXX_FLAGS_MINSIZEREL ${CMAKE_CXX_FLAGS_MINSIZEREL} ${xenomai_CFLAGS})
	set(CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE} ${xenomai_CFLAGS})
	set(CMAKE_CXX_FLAGS_RELWITHDEBINFO ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}${xenomai_CFLAGS})

	set(CMAKE_C_FLAGS ${CMAKE_C_FLAGS} ${xenomai_CFLAGS})
	set(CMAKE_C_FLAGS_DEBUG ${CMAKE_C_FLAGS_DEBUG} ${xenomai_CFLAGS})
	set(CMAKE_C_FLAGS_MINSIZEREL ${CMAKE_C_FLAGS_MINSIZEREL} ${xenomai_CFLAGS})
	set(CMAKE_C_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE} ${xenomai_CFLAGS})
	set(CMAKE_C_FLAGS_RELWITHDEBINFO ${CMAKE_C_FLAGS_RELWITHDEBINFO} ${xenomai_CFLAGS})

	set(CMAKE_EXE_LINKER_FLAGS ${CMAKE_EXE_LINKER_FLAGS} ${xenomai_LINKS})
	set(CMAKE_EXE_LINKER_FLAGS_DEBUG ${CMAKE_EXE_LINKER_FLAGS_DEBUG} ${xenomai_LINKS})
	set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL ${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL} ${xenomai_LINKS})
	set(CMAKE_EXE_LINKER_FLAGS_RELEASE ${CMAKE_EXE_LINKER_FLAGS_RELEASE} ${xenomai_LINKS})
	set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO ${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO} ${xenomai_LINKS})

	set(CMAKE_MODULE_LINKER_FLAGS ${CMAKE_MODULE_LINKER_FLAGS} ${xenomai_LINKS})
	set(CMAKE_MODULE_LINKER_FLAGS_DEBUG ${CMAKE_MODULE_LINKER_FLAGS_DEBUG} ${xenomai_LINKS})
	set(CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL ${CMAKE_MODULE_LINKER_FLAGS_MINSIZEREL} ${xenomai_LINKS})
	set(CMAKE_MODULE_LINKER_FLAGS_RELEASE ${CMAKE_MODULE_LINKER_FLAGS_RELEASE} ${xenomai_LINKS})
	set(CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO ${CMAKE_MODULE_LINKER_FLAGS_RELWITHDEBINFO} ${xenomai_LINKS})

	set(CMAKE_SHARED_LINKER_FLAGS ${CMAKE_SHARED_LINKER_FLAGS} ${xenomai_LINKS})
	set(CMAKE_SHARED_LINKER_FLAGS_DEBUG ${CMAKE_SHARED_LINKER_FLAGS_DEBUG} ${xenomai_LINKS})
	set(CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL ${CMAKE_SHARED_LINKER_FLAGS_MINSIZEREL} ${xenomai_LINKS})
	set(CMAKE_SHARED_LINKER_FLAGS_RELEASE ${CMAKE_SHARED_LINKER_FLAGS_RELEASE} ${xenomai_LINKS})
	set(CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO ${CMAKE_SHARED_LINKER_FLAGS_RELWITHDEBINFO} ${xenomai_LINKS})

	set(CMAKE_STATIC_LINKER_FLAGS ${CMAKE_STATIC_LINKER_FLAGS} ${xenomai_LINKS})
	set(CMAKE_STATIC_LINKER_FLAGS_DEBUG ${CMAKE_STATIC_LINKER_FLAGS_DEBUG} )
	set(CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL ${CMAKE_STATIC_LINKER_FLAGS_MINSIZEREL} ${xenomai_LINKS})
	set(CMAKE_STATIC_LINKER_FLAGS_RELEASE ${CMAKE_STATIC_LINKER_FLAGS_RELEASE} ${xenomai_LINKS})
	set(CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO ${CMAKE_STATIC_LINKER_FLAGS_RELWITHDEBINFO} ${xenomai_LINKS})
endif()

unset(XENO_LDFLAGS)
unset(XENO_CFLAGS)
unset(XENO_CONFIG_PATH)
unset(xenomai_LINKS)
unset(xenomai_CFLAGS)
