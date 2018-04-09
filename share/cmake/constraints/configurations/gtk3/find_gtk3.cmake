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

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK3 gtk+-3.0)
pkg_check_modules(GTKMM gtkmm-3.0)

if(${GTK3_FOUND} AND ${GTKMM_FOUND})
	set(gtk3_FOUND TRUE CACHE INTERNAL "")
	set(gtk3_INCLUDE_PATH ${GTKMM_INCLUDE_DIRS} PARENT_SCOPE)
	set(gtk3_LINK_OPTIONS ${GTKMM_LIBRARIES} PARENT_SCOPE)
else()
	set(gtk3_FOUND FALSE CACHE INTERNAL "")
endif()
