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

found_PID_Configuration(turbojpeg FALSE)
# - Find turbojpeg installation
# Try to find libraries for turbojpeg on UNIX systems. The following values are defined
#  turbojpeg_FOUND        - True if turbojpeg is available
#  turbojpeg_LIBRARIES    - link against these to use turbojpeg library
set(turbojpeg_LIBRARIES) # start with empty list

find_path(TurboJPEG_INCLUDE_DIRS NAMES turbojpeg.h)
find_library(TurboJPEG_LIBRARIES NAMES libturbojpeg.so.1 libturbojpeg.so.0) #either version 0 or 1 is used (depending on distro)

if(TurboJPEG_INCLUDE_DIRS AND NOT TurboJPEG_INCLUDE_DIRS MATCHES TurboJPEG_INCLUDE_DIRS-NOTFOUND
	AND TurboJPEG_LIBRARIES AND NOT TurboJPEG_LIBRARIES MATCHES TurboJPEG_LIBRARIES-NOTFOUND)
	set(turbojpeg_LIBRARIES -lturbojpeg) # start with empty list
	found_PID_Configuration(turbojpeg TRUE)
	
	unset(TurboJPEG_INCLUDE_DIRS CACHE)
	unset(TurboJPEG_LIBRARIES CACHE)
endif()
