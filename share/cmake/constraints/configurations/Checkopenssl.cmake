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

macro(find_Open_SSL)
set(openssl_FOUND FALSE)
if(UNIX)
	find_path(openssl_INCLUDE_DIR openssl/ssl.h) #searching only in standard paths
	find_library(openssl_SSL_LIBRARY NAMES ssl ssleay32 ssleay32MD)
	find_library(openssl_CRYPTO_LIBRARY NAMES crypto)
	set(openssl_LIBRARIES ${openssl_SSL_LIBRARY} ${openssl_CRYPTO_LIBRARY})
	unset(openssl_INCLUDE_DIR CACHE)
	unset(openssl_SSL_LIBRARY CACHE)
	unset(openssl_CRYPTO_LIBRARY CACHE)
	set(openssl_FOUND TRUE)
endif()
endmacro(find_Open_SSL)

if(NOT openssl_FOUND)	
	set(openssl_COMPILE_OPTIONS CACHE INTERNAL "")
	set(openssl_LINK_OPTIONS CACHE INTERNAL "")
	set(openssl_RPATH CACHE INTERNAL "")
	find_Open_SSL()
	if(openssl_FOUND)
		set(openssl_LINK_OPTIONS ${openssl_LIBRARIES} CACHE INTERNAL "")
		set(CHECK_openssl_RESULT TRUE)
	else()
		if(	CURRENT_DISTRIBUTION STREQUAL ubuntu 
			OR CURRENT_DISTRIBUTION STREQUAL debian)
			message("[PID] INFO : trying to install openssl...")
			execute_process(COMMAND sudo apt-get install openssl)
			find_Open_SSL()
			if(openssl_FOUND)
				message("[PID] INFO : openssl installed !")
				set(openssl_LINK_OPTIONS ${openssl_LIBRARIES} CACHE INTERNAL "")
				set(CHECK_openssl_RESULT TRUE)
			else()
				message("[PID] INFO : install of openssl has failed !")
				set(CHECK_openssl_RESULT FALSE)
			endif()
		else()
			set(CHECK_openssl_RESULT FALSE)
		endif()
	endif()
else()
	set(CHECK_openssl_RESULT TRUE)
endif()
