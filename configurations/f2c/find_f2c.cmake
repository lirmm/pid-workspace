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

found_PID_Configuration(f2c FALSE)

find_program(F2C_EXECUTABLE NAMES f2c)
if(NOT F2C_EXECUTABLE)#no f2c compiler found => no need to continue
	message("[PID] WARNING : no f2c executable found...")
	return()
endif()

find_path(F2C_INCLUDE_DIR f2c.h /sw/include )
set(F2C_NAMES ${F2C_NAMES} f2c.a libf2c.a f2c.lib)
# Use FIND_FILE instead of FIND_LIBRARY because we need the
# static version of libf2c. The shared library produces linker
# errors.
find_file(F2C_LIBRARY NAMES ${F2C_NAMES}
	PATHS /usr/lib /usr/local/lib /opt /sw/lib/
)

# Look for libg2c as fallback. libg2c is part of the
# compat-g77 package.
if(NOT F2C_LIBRARY)
	set(G2C_NAMES ${G2C_NAMES} g2c libg2c)
	find_library(F2C_LIBRARY NAMES ${G2C_NAMES})
endif()

if(F2C_LIBRARY AND F2C_INCLUDE_DIR)
	set(F2C_LIBRARIES ${F2C_LIBRARY})
	set(F2C_INCLUDE_DIRS ${F2C_INCLUDE_DIR})
	set(F2C_COMPILER ${F2C_EXECUTABLE})
	found_PID_Configuration(f2c TRUE)
	convert_PID_Libraries_Into_System_Links(F2C_LIBRARIES f2C_LINKS)#getting good system links (with -l)
	convert_PID_Libraries_Into_Library_Directories(F2C_LIBRARIES f2C_LIBDIR)#getting good system libraries folders (to be used with -L)
else()
	if(F2C_LIBRARY)
		message("[PID] WARNING : no headers found for f2c library (${F2C_LIBRARY})")
	elseif(F2C_INCLUDE_DIR)
		message("[PID] WARNING : no binary found for f2c library with headers (${F2C_INCLUDE_DIR})")
	else()
		message("[PID] WARNING : no binary or headers found for f2c library")
	endif()
endif()

unset(F2C_INCLUDE_DIR CACHE)
unset(F2C_LIBRARY CACHE)
unset(F2C_EXECUTABLE CACHE)
