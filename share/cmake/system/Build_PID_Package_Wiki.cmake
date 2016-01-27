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

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/share/cmake/system)
include(Package_Internal_Documentation_Management NO_POLICY_SCOPE)
include(PID_Git_Functions NO_POLICY_SCOPE)
include(PID_Utils_Functions NO_POLICY_SCOPE)

set(package ${TARGET_PACKAGE})
set(content_file_to_remove ${REMOVED_CONTENT})
set(repo_addr ${WIKI_ADDRESS})
if(DEFINED SYNCHRO_WIKI AND SYNCHRO_WIKI STREQUAL "false")
	set(push_wiki FALSE)
else()
	set(push_wiki TRUE)
endif()

wiki_Project_Exists(WIKI_EXISTS PATH_TO_WIKI ${package})

if(NOT WIKI_EXISTS)

	if(NOT repo_addr OR "${repo_addr}" STREQUAL "")
		message("[PID] ERROR : you need to set the wiki repository address.")
		return()
	endif()

	#create the wiki repository in the workspace
	create_Local_Wiki_Project(SUCCEEDED ${package} ${repo_addr})
	if(NOT SUCCEEDED)
		message("[PID] ERROR : impossible to connect to the wiki repository. You are probably not a developer of the package ${package} which explains why you cannot publish the wiki.")
		return()
	endif()
endif()
update_Wiki_Repository(${package}) # update wiki repository
clean_Local_Wiki(${package}) # clean the folder content (api-doc content)
copy_Wiki_Content(${package} ${content_file_to_remove}) # copy everything needed (api-doc content, share/wiki except content_file_to_remove
if(push_wiki)
	message("[PID] INFO : wiki of ${package} has been updated on server.")
	publish_Wiki_Repository(${package})
else()
	message("[PID] INFO : wiki of ${package} has been updated locally.")
endif()


