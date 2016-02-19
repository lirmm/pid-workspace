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

set(x11_FOUND FALSE CACHE INTERNAL "")
# - Find x11 installation
# Try to find X11 on UNIX systems. The following values are defined
#  x11_FOUND        - True if X11 is available
#  x11_LIBRARIES    - link against these to use X11
if (UNIX)

	# X11 is never a framework and some header files may be
	# found in tcl on the mac
	set(CMAKE_FIND_FRAMEWORK_SAVE ${CMAKE_FIND_FRAMEWORK})
	set(CMAKE_FIND_FRAMEWORK NEVER)

	# MODIFICATION for our needs: must be in default system folders so do not provide additionnal folders !!!!!
	find_path(x11_X11_INCLUDE_PATH X11/X.h)
	find_path(x11_Xlib_INCLUDE_PATH X11/Xlib.h)
	find_path(x11_ICE_INCLUDE_PATH X11/ICE/ICE.h)
	find_path(x11_SM_INCLUDE_PATH X11/SM/SM.h)

	find_library(x11_X11_LIB X11) 
	find_library(x11_ICE_LIB ICE)
	find_library(x11_SM_LIB SM)
	find_library(x11_Xext_LIB Xext)

	# no need to check for include or library dirs as all must be in default system folders (no configuration required)

	##### x11 base libraries #####
	set(x11_LIBRARIES) # start with empty list

	set(IS_FOUND TRUE)
	if(x11_X11_INCLUDE_PATH AND x11_Xlib_INCLUDE_PATH AND x11_X11_LIB)
		set(x11_LIBRARIES ${x11_LIBRARIES} -lX11 )
	else()
		message("[PID] ERROR : when finding x11 framework, cannot find X11 base library.")
		set(IS_FOUND FALSE)
	endif()

	if(x11_Xext_LIB)
		set(x11_LIBRARIES ${x11_LIBRARIES} -lXext)
	else()
		message("[PID] ERROR : when finding x11 framework, cannot find X11 extension library.")
		set(IS_FOUND FALSE)
	endif()

	if(x11_ICE_LIB AND x11_ICE_INCLUDE_PATH)
		set(x11_LIBRARIES ${x11_LIBRARIES} -lICE)
	else()
		message("[PID] ERROR : when finding x11 framework, cannot find ICE library.")
		set(IS_FOUND FALSE)
	endif ()

	if(x11_SM_LIB AND x11_SM_INCLUDE_PATH)
		set(x11_LIBRARIES ${x11_LIBRARIES} -lSM)
	else()
		message("[PID] ERROR : when finding x11 framework, cannot find SM library.")
		set(IS_FOUND FALSE)
	endif ()

	if(IS_FOUND)
		set(x11_FOUND TRUE CACHE INTERNAL "")
	endif ()

	### now searching extension libraries they may be present or not ###
	
	#Xt
	find_path(x11_Xt_INCLUDE_PATH X11/Intrinsic.h)
	find_library(x11_Xt_LIB Xt )	
	if(x11_Xt_LIB AND x11_Xt_INCLUDE_PATH)
		set(x11_Xt_LIB -lXt CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xt_LIB})		
	else()
		unset(x11_Xt_LIB CACHE)#remove from cache
	endif ()

	#Xft
	find_library(x11_Xft_LIB Xft )
	find_path(x11_Xft_INCLUDE_PATH X11/Xft/Xft.h )
	if(x11_Xft_LIB AND x11_Xft_INCLUDE_PATH)
		set(x11_Xft_LIB -lXft CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xft_LIB})
		
	else()
		unset(x11_Xft_LIB CACHE)#remove from cache
	endif ()

	#Xv
	find_path(x11_Xv_INCLUDE_PATH X11/extensions/Xvlib.h )
	find_library(x11_Xv_LIB Xv)
	if(x11_Xv_LIB AND x11_Xv_INCLUDE_PATH)
		set(x11_Xv_LIB -lXv CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xv_LIB})
	else()
		unset(x11_Xv_LIB CACHE)#remove from cache
	endif ()

	#Xauth
	find_path(x11_Xau_INCLUDE_PATH X11/Xauth.h )
	find_library(x11_Xau_LIB Xau)
	if (x11_Xau_LIB AND x11_Xau_INCLUDE_PATH)
		set(x11_Xau_LIB -lXau CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xau_LIB})
	else()
		unset(x11_Xau_LIB CACHE)#remove from cache
	endif ()

	# Xdcmp
	find_path(x11_Xdmcp_INCLUDE_PATH X11/Xdmcp.h)
	find_library(x11_Xdmcp_LIB Xdmcp)
	if (x11_Xdmcp_INCLUDE_PATH AND x11_Xdmcp_LIB)
		set(x11_Xdmcp_LIB -lXdmcp CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xdmcp_LIB})
	else()
		unset(x11_Xdmcp_LIB CACHE)#remove from cache
	endif ()

	#Xpm	
	find_path(x11_Xpm_INCLUDE_PATH X11/xpm.h )
	find_library(x11_Xpm_LIB Xpm )
	if (x11_Xpm_INCLUDE_PATH AND x11_Xpm_LIB)
		set(x11_Xpm_LIB -lXpm CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xpm_LIB})
	else()
		unset(x11_Xpm_LIB CACHE)#remove from cache
	endif ()

	#Xcomposite
	find_library(x11_Xcomposite_LIB Xcomposite)
	find_path(x11_Xcomposite_INCLUDE_PATH X11/extensions/Xcomposite.h)
	if (x11_Xcomposite_INCLUDE_PATH AND x11_Xcomposite_LIB)
		set(x11_Xcomposite_LIB -lXcomposite CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xcomposite_LIB})
	else()
		unset(x11_Xcomposite_LIB CACHE)#remove from cache
	endif ()

	#Xdamage
	find_path(x11_Xdamage_INCLUDE_PATH X11/extensions/Xdamage.h)
	find_library(x11_Xdamage_LIB Xdamage)
	if (x11_Xdamage_INCLUDE_PATH AND x11_Xdamage_LIB)
		set(x11_Xdamage_LIB -lXdamage CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xdamage_LIB})
	else()
		unset(x11_Xdamage_LIB CACHE)#remove from cache
	endif ()

	#XTest
	find_path(x11_XTest_INCLUDE_PATH X11/extensions/XTest.h )
	find_library(x11_XTest_LIB Xtst)
	if (x11_XTest_INCLUDE_PATH AND x11_XTest_LIB)
		set(x11_XTest_LIB -lXTest CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_XTest_LIB})
	else()
		unset(x11_XTest_LIB CACHE)#remove from cache
	endif ()

	
	#Xinput
	find_path(x11_Xinput_INCLUDE_PATH X11/extensions/XInput.h )
	find_library(x11_Xinput_LIB Xi  )
	if (x11_Xinput_INCLUDE_PATH AND x11_Xinput_LIB)
		set(x11_Xinput_LIB -lXi CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xinput_LIB})
	else()
		unset(x11_Xinput_LIB CACHE)#remove from cache
	endif ()

	#Xinerama
	find_path(x11_Xinerama_INCLUDE_PATH X11/extensions/Xinerama.h)
	find_library(x11_Xinerama_LIB Xinerama )
	if (x11_Xinerama_INCLUDE_PATH AND x11_Xinerama_LIB)
		set(x11_Xinerama_LIB -lXinerama CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xinerama_LIB})
	else()
		unset(x11_Xinerama_LIB CACHE)#remove from cache
	endif ()

	#Xfixes
	find_path(x11_Xfixes_INCLUDE_PATH X11/extensions/Xfixes.h)
	find_library(x11_Xfixes_LIB Xfixes)
	if (x11_Xfixes_INCLUDE_PATH AND x11_Xfixes_LIB)
		set(x11_Xfixes_LIB -lXfixes CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xfixes_LIB})
	else()
		unset(x11_Xfixes_LIB CACHE)#remove from cache
	endif ()

	#Xrender
	find_path(x11_Xrender_INCLUDE_PATH X11/extensions/Xrender.h )
	find_library(x11_Xrender_LIB Xrender )
	if (x11_Xrender_INCLUDE_PATH AND x11_Xrender_LIB)
		set(x11_Xrender_LIB -lXrender CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xrender_LIB})
	else()
		unset(x11_Xrender_LIB CACHE)#remove from cache
	endif ()

	#Xres
	find_path(x11_XRes_INCLUDE_PATH X11/extensions/XRes.h )
	find_library(x11_XRes_LIB XRes)
	if (x11_XRes_INCLUDE_PATH AND x11_XRes_LIB)
		set(x11_XRes_LIB -lXRes CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_XRes_LIB})
	else()
		unset(x11_XRes_LIB CACHE)#remove from cache
	endif ()

	#Xrandr
	find_path(x11_Xrandr_INCLUDE_PATH X11/extensions/Xrandr.h )
	find_library(x11_Xrandr_LIB Xrandr )
	if (x11_Xrandr_INCLUDE_PATH AND x11_Xrandr_LIB)
		set(x11_Xrandr_LIB -lXrandr CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xrandr_LIB})
	else()
		unset(x11_Xrandr_LIB CACHE)#remove from cache
	endif ()

	#xf86misc
	find_path(x11_xf86misc_INCLUDE_PATH X11/extensions/xf86misc.h )
	find_library(x11_Xxf86misc_LIB Xxf86misc)
	if (x11_xf86misc_INCLUDE_PATH AND x11_Xxf86misc_LIB)
		set(x11_Xxf86misc_LIB -lXxf86misc CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xxf86misc_LIB})
	else()
		unset(x11_Xxf86misc_LIB CACHE)#remove from cache
	endif ()

	#xf86vmode
	find_path(x11_xf86vmode_INCLUDE_PATH X11/extensions/xf86vmode.h)
	find_library(x11_Xxf86vm_LIB Xxf86vm)
	if (x11_xf86vmode_INCLUDE_PATH AND x11_Xxf86vm_LIB)
		set(x11_Xxf86vm_LIB -lXxf86vm CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xxf86vm_LIB})
	else()
		unset(x11_Xxf86vm_LIB CACHE)#remove from cache
	endif ()

	#Xcursor
	find_path(x11_Xcursor_INCLUDE_PATH X11/Xcursor/Xcursor.h )
	find_library(x11_Xcursor_LIB Xcursor)
	if (x11_Xcursor_INCLUDE_PATH AND x11_Xcursor_LIB)
		set(x11_Xcursor_LIB -lXcursor CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xcursor_LIB})
	else()
		unset(x11_Xcursor_LIB CACHE)#remove from cache
	endif ()

	#Xscreensaver
	find_library(x11_Xscreensaver_LIB Xss)
	find_path(x11_Xscreensaver_INCLUDE_PATH X11/extensions/scrnsaver.h)
	if (x11_Xscreensaver_INCLUDE_PATH AND x11_Xscreensaver_LIB)
		set(x11_Xscreensaver_LIB -lXss CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xscreensaver_LIB})
	else()
		unset(x11_Xscreensaver_LIB CACHE)#remove from cache
	endif ()

	#Xkb
	find_path(x11_Xkb_INCLUDE_PATH X11/extensions/XKB.h )
	find_path(x11_Xkblib_INCLUDE_PATH X11/XKBlib.h )
	find_path(x11_Xkbfile_INCLUDE_PATH X11/extensions/XKBfile.h )
	find_library(x11_Xkbfile_LIB xkbfile)
	if (x11_Xkb_INCLUDE_PATH AND x11_Xkbfile_INCLUDE_PATH AND x11_Xkblib_INCLUDE_PATH AND x11_Xkbfile_LIB)
		set(x11_Xkbfile_LIB -lxkbfile CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xkbfile_LIB})
	else()
		unset(x11_Xkbfile_LIB CACHE)#remove from cache
	endif ()


	#Xmu
	find_path(x11_Xmu_INCLUDE_PATH X11/Xmu/Xmu.h )
	find_library(x11_Xmu_LIB Xmu)
	if (x11_Xmu_INCLUDE_PATH AND x11_Xmu_LIB)
		set(x11_Xmu_LIB -lXmu CACHE INTERNAL "") #remove from user cache
		set(x11_EXTENSI0NS_LIBS ${x11_EXTENSI0NS_LIBS} ${x11_Xmu_LIB})
	else()
		unset(x11_Xmu_LIB CACHE)#remove from cache
	endif ()


	# variable to select extension libraries 
	unset(IS_FOUND)
	unset(x11_X11_INCLUDE_PATH CACHE)
	unset(x11_Xlib_INCLUDE_PATH CACHE)
	unset(x11_X11_LIB CACHE)
	unset(x11_Xext_LIB CACHE)
	unset(x11_ICE_LIB CACHE)
	unset(x11_ICE_INCLUDE_PATH CACHE)
	unset(x11_SM_LIB CACHE)
	unset(x11_SM_INCLUDE_PATH CACHE)
	unset(x11_Xau_INCLUDE_PATH CACHE)
	unset(x11_Xcomposite_INCLUDE_PATH CACHE)
	unset(x11_Xcursor_INCLUDE_PATH CACHE)
	unset(x11_Xdamage_INCLUDE_PATH CACHE)
	unset(x11_Xdmcp_INCLUDE_PATH CACHE)
	unset(x11_xf86misc_INCLUDE_PATH CACHE)
	unset(x11_xf86vmode_INCLUDE_PATH CACHE)
	unset(x11_Xfixes_INCLUDE_PATH CACHE)
	unset(x11_Xft_INCLUDE_PATH CACHE)
	unset(x11_Xinerama_INCLUDE_PATH CACHE)
	unset(x11_Xinput_INCLUDE_PATH CACHE)
	unset(x11_Xkb_INCLUDE_PATH CACHE)
	unset(x11_Xkblib_INCLUDE_PATH CACHE)
	unset(x11_Xkbfile_INCLUDE_PATH CACHE)
	unset(x11_Xmu_INCLUDE_PATH CACHE)
	unset(x11_Xpm_INCLUDE_PATH CACHE)
	unset(x11_XTest_INCLUDE_PATH CACHE)
	unset(x11_Xrandr_INCLUDE_PATH CACHE)
	unset(x11_Xrender_INCLUDE_PATH CACHE)
	unset(x11_XRes_INCLUDE_PATH CACHE)
	unset(x11_Xscreensaver_INCLUDE_PATH CACHE)
	unset(x11_Xutil_INCLUDE_PATH CACHE)
	unset(x11_Xt_INCLUDE_PATH CACHE)
	unset(x11_Xv_INCLUDE_PATH CACHE)
	set(CMAKE_FIND_FRAMEWORK ${CMAKE_FIND_FRAMEWORK_SAVE})
endif ()

