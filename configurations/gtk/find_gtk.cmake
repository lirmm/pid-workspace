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

#=============================================================
# gtk2_Find_Include_Dir
# Internal function to find the GTK include directories
#   _var = variable to set (_INCLUDE_PATH is appended)
#   _hdr = header file to look for
#=============================================================
function(gtk2_Find_Include_Dir _var _hdr)

	set(_gtk_packages
		glibmm-2.4
		glib-2.0
		atk-1.0
		atkmm-1.6
		cairo
		cairomm-1.0
		gdk-pixbuf-2.0
		gdkmm-2.4
		giomm-2.4
		gtk-2.0
		gtkmm-2.4
		libglade-2.0
		libglademm-2.4
		pango-1.0
		pangomm-1.4
		sigc++-2.0
	)

#
# NOTE: The following suffixes cause searching for header files in both of
# these directories:
#         /usr/include/<pkg>
#         /usr/lib/<pkg>/include
#

	set(_suffixes)
	foreach(_d ${_gtk_packages})
		list(APPEND _suffixes ${_d})
		list(APPEND _suffixes ${_d}/include) # for /usr/lib/gtk-2.0/include
	endforeach()
	if(CMAKE_LIBRARY_ARCHITECTURE)
		set(_gtk2_arch_dir /usr/lib/${CMAKE_LIBRARY_ARCHITECTURE})
	endif()
	find_path(${_var}_INCLUDE_DIR ${_hdr}
		PATHS
		    ${_gtk2_arch_dir}
		    /usr/local/lib64
		    /usr/local/lib
		    /usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}
		    /usr/lib64
		    /usr/lib
		    /opt/gnome/include
		    /opt/gnome/lib
		    /opt/openwin/include
		    /usr/openwin/lib
		    /sw/include
		    /sw/lib
		    /opt/local/include
		    /opt/local/lib
		    /usr/pkg/lib
		    /usr/pkg/include/glib
		    $ENV{GTKMM_BASEPATH}/include
		    $ENV{GTKMM_BASEPATH}/lib
		PATH_SUFFIXES
		    ${_suffixes}
    )

    if(${_var}_INCLUDE_DIR)
        set(gtk2_INCLUDE_PATH ${gtk2_INCLUDE_PATH} ${${_var}_INCLUDE_DIR} PARENT_SCOPE)
    endif()

endfunction(gtk2_Find_Include_Dir)

#=============================================================
# gtk2_Find_Library
# Internal function to find libraries packaged with GTK2
#   _var = library variable to create (_LIBRARY is appended)
#=============================================================
function(gtk2_Find_Library _var _lib _append_version)

# Not GTK versions per se but the versions encoded into Windows
# import libraries (GtkMM 2.14.1 has a gtkmm-vc80-2_4.lib for example)
# Also the MSVC libraries use _ for . (this is handled below)
set(_versions 2.20 2.18 2.16 2.14 2.12
          2.10  2.8  2.6  2.4  2.2 2.0
          1.20 1.18 1.16 1.14 1.12
          1.10  1.8  1.6  1.4  1.2 1.0)

set(_lib_list)
if(_append_version)
	foreach(_ver ${_versions})
		list(APPEND _lib_list  "${_lib}-${_ver}")
	endforeach()
else()
	set(_lib_list ${_lib})
endif()

find_library(${_var}_LIBRARY_RELEASE NAMES ${_lib_list}) #nothing else than standard path

set(${_var}_LIBRARY ${${_var}_LIBRARY_RELEASE} PARENT_SCOPE)
set(gtk2_LIBS ${gtk2_LIBS} ${${_var}_LIBRARY_RELEASE})
set(gtk2_LIBS ${gtk2_LIBS} PARENT_SCOPE)
endfunction(gtk2_Find_Library)

#macro used to find gtk2
macro(find_GTK2 FOUND)
	set(${FOUND} TRUE)
	set(CMAKE_FIND_FRAMEWORK_SAVE ${CMAKE_FIND_FRAMEWORK})
	set(CMAKE_FIND_FRAMEWORK NEVER)
	#starting the check
	gtk2_Find_Include_Dir(gtk2_GTK gtk/gtk.h)
	gtk2_Find_Include_Dir(gtk2_GDK gdk/gdk.h)
	gtk2_Find_Include_Dir(gtk2_GDKCONFIG gdkconfig.h)
	gtk2_Find_Include_Dir(gtk2_GLIB glib.h)
	gtk2_Find_Include_Dir(gtk2_GLIBCONFIG glibconfig.h)
	gtk2_Find_Include_Dir(gtk2_FONTCONFIG fontconfig/fontconfig.h)
	gtk2_Find_Include_Dir(gtk2_PANGO pango/pango.h)
	gtk2_Find_Include_Dir(gtk2_CAIRO cairo.h)
	gtk2_Find_Include_Dir(gtk2_GDK_PIXBUF gdk-pixbuf/gdk-pixbuf.h)
	gtk2_Find_Include_Dir(gtk2_ATK atk/atk.h)
	gtk2_Find_Include_Dir(gtk2_GOBJECT gobject/gobject.h)

	if(	NOT gtk2_GTK_INCLUDE_DIR
		OR NOT gtk2_GDK_INCLUDE_DIR
		OR NOT gtk2_GDKCONFIG_INCLUDE_DIR
		OR NOT gtk2_GLIB_INCLUDE_DIR
		OR NOT gtk2_GLIBCONFIG_INCLUDE_DIR
		OR NOT gtk2_FONTCONFIG_INCLUDE_DIR
		OR NOT gtk2_PANGO_INCLUDE_DIR
		OR NOT gtk2_CAIRO_INCLUDE_DIR
		OR NOT gtk2_GDK_PIXBUF_INCLUDE_DIR
		OR NOT gtk2_ATK_INCLUDE_DIR
		OR NOT gtk2_GOBJECT_INCLUDE_DIR
		)
		set(${FOUND} FALSE)
	else()
		gtk2_Find_Library(gtk2_GTK gtk-x11 true)
		gtk2_Find_Library(gtk2_GDK gdk-x11 true)
		gtk2_Find_Library(gtk2_CAIRO cairo false)
		gtk2_Find_Library(gtk2_PANGO pango true)
		gtk2_Find_Library(gtk2_PANGOCAIRO pangocairo true)
		gtk2_Find_Library(gtk2_PANGOFT2 pangoft2 true)
		gtk2_Find_Library(gtk2_PANGOXFT pangoxft true)
		gtk2_Find_Library(gtk2_GDK_PIXBUF gdk_pixbuf true)
		gtk2_Find_Library(gtk2_GTHREAD gthread true)
		gtk2_Find_Library(gtk2_GMODULE gmodule true)
		gtk2_Find_Library(gtk2_GIO gio true)
		gtk2_Find_Library(gtk2_ATK atk true)
		gtk2_Find_Library(gtk2_GOBJECT gobject true)
		gtk2_Find_Library(gtk2_GLIB glib true)
		if(	NOT gtk2_GTK_LIBRARY
			OR NOT gtk2_GDK_LIBRARY
			OR NOT gtk2_CAIRO_LIBRARY
			OR NOT gtk2_PANGO_LIBRARY
			OR NOT gtk2_PANGOCAIRO_LIBRARY
			OR NOT gtk2_PANGOFT2_LIBRARY
			OR NOT gtk2_PANGOXFT_LIBRARY
			OR NOT gtk2_GDK_PIXBUF_LIBRARY
			OR NOT gtk2_GTHREAD_LIBRARY
			OR NOT gtk2_GMODULE_LIBRARY
			OR NOT gtk2_GIO_LIBRARY
			OR NOT gtk2_ATK_LIBRARY
			OR NOT gtk2_GOBJECT_LIBRARY
			OR NOT gtk2_GLIB_LIBRARY
		)
			set(${FOUND} FALSE)
		endif()
	endif()
	set(CMAKE_FIND_FRAMEWORK ${CMAKE_FIND_FRAMEWORK_SAVE})
endmacro(find_GTK2)

#macro used to find gtk3
macro(find_GTK3 FOUND)
	set(${FOUND} TRUE)
	find_package(PkgConfig REQUIRED)
	pkg_check_modules(GTK3 gtk+-3.0)
	pkg_check_modules(GTKMM gtkmm-3.0)

	if(GTK3_FOUND AND GTKMM_FOUND)
		set(gtk3_INCLUDE_PATH ${GTKMM_INCLUDE_DIRS})
		set(gtk3_LIBS ${GTKMM_LIBRARIES})
	else()
		set(${FOUND} FALSE)
	endif()
endmacro(find_GTK3)


#starting find script
found_PID_Configuration(gtk FALSE)

if (UNIX)#GTK not available on a non UNIX system
	set(IS_FOUND TRUE)
	set(GTK_LIBS) # start with empty list of libraries
	set(GTK_INCLUDE_PATH) # start with empty list of path
	set(GTK_LINKS) # start with empty list of links
	set(GTK_VERSION)

	if(gtk_version)#a specific version is desired
		if(gtk_version EQUAL 2)
			find_GTK2(found_gtk2)
			if(found_gtk2)
				set(GTK_LIBS ${gtk2_LIBS})
				set(GTK_INCLUDE_PATH ${gtk2_INCLUDE_PATH})
				set(GTK_VERSION 2)
			else()
				set(IS_FOUND FALSE)
			endif()
		elseif(gtk_version EQUAL 3)
			find_GTK3(found_gtk3)
			if(found_gtk3)
				set(GTK_LIBS ${gtk3_LIBS})
				set(GTK_INCLUDE_PATH ${gtk3_INCLUDE_PATH})
				set(GTK_VERSION 3)
			else()
				set(IS_FOUND FALSE)
			endif()
		else()
				set(IS_FOUND FALSE)
		endif()
	elseif(gtk_preferred)# an ordered list of versions is given

		foreach(version IN LISTS gtk_preferred)
			if(version EQUAL 2)
				find_GTK2(found_gtk2)
				if(found_gtk2)
					set(GTK_LIBS ${gtk2_LIBS})
					set(GTK_INCLUDE_PATH ${gtk2_INCLUDE_PATH})
					set(GTK_VERSION 2)
					break()#stop searching once something found
				endif()
			elseif(gtk_version EQUAL 3)
				find_GTK3(found_gtk3)
				if(found_gtk3)
					set(GTK_LIBS ${gtk3_LIBS})
					set(GTK_INCLUDE_PATH ${gtk3_INCLUDE_PATH})
					set(GTK_VERSION 3)
					break()#stop searching once something found
				endif()
			endif()
		endforeach()

		if(NOT GTK_VERSION)
			set(IS_FOUND FALSE)
		endif()
	else()#no preference on version given, finding gtk2 first then gtk3, taking the first found
		find_GTK2(found_gtk2)
		if(found_gtk2)
			set(GTK_LIBS ${gtk2_LIBS})
			set(GTK_INCLUDE_PATH ${gtk2_INCLUDE_PATH})
			set(GTK_VERSION 2)
		else()
			find_GTK3(found_gtk3)
			if(found_gtk3)
				set(GTK_LIBS ${gtk3_LIBS})
				set(GTK_INCLUDE_PATH ${gtk3_INCLUDE_PATH})
				set(GTK_VERSION 3)
			else()
				set(IS_FOUND FALSE)
			endif()
		endif()
	endif()

	if(IS_FOUND)
		list(REMOVE_DUPLICATES GTK_INCLUDE_PATH)
		list(REMOVE_DUPLICATES GTK_LIBS)
		convert_PID_Libraries_Into_System_Links(GTK_LIBS GTK_LINKS)#getting good system links (with -l)
		convert_PID_Libraries_Into_Library_Directories(GTK_LIBS GTK_LIBRARY_DIRS)
		found_PID_Configuration(gtk TRUE)
	endif ()

	unset(IS_FOUND)
endif ()
