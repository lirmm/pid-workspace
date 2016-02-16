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

set(opengl_FOUND FALSE CACHE INTERNAL "")
if(UNIX)
	#searching only in standard paths
	if(APPLE)
		find_path(opengl_INCLUDE_DIR OpenGL/gl.h)
		find_library(opengl_gl_LIBRARY OpenGL)
		find_library(opengl_glu_LIBRARY AGL)
		set(LIBS_NAMES -lOpenGL -lAGL)
	else()
		find_path(opengl_INCLUDE_DIR GL/gl.h) 
		find_library(opengl_gl_LIBRARY NAMES GL)
		find_library(opengl_glu_LIBRARY NAMES GLU)
		find_path(opengl_glut_INCLUDE_DIR NAMES GL/glut.h GL/freeglut.h) 
		find_library(opengl_glut_LIBRARY NAMES glut)
		set(LIBS_NAMES -lGL -lGLU -lglut)
	endif()

	if(NOT opengl_INCLUDE_DIR MATCHES opengl_INCLUDE_DIR-NOTFOUND
	AND NOT opengl_gl_LIBRARY MATCHES opengl_gl_LIBRARY-NOTFOUND
	AND NOT opengl_glu_LIBRARY MATCHES opengl_glu_LIBRARY-NOTFOUND
	AND NOT opengl_glut_LIBRARY MATCHES opengl_glut_LIBRARY-NOTFOUND
	AND NOT opengl_glut_INCLUDE_DIR MATCHES opengl_glut_INCLUDE_DIR-NOTFOUND)
		message("LIBS_NAMES = ${LIBS_NAMES}")
		set(opengl_LIBRARIES ${LIBS_NAMES})
		unset(opengl_INCLUDE_DIR CACHE)
		unset(opengl_LIBRARY CACHE)
		set(opengl_FOUND TRUE CACHE INTERNAL "")
	endif()
endif()

