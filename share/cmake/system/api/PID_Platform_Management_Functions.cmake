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

##########################################################################################
############################ Guard for optimization of configuration process #############
##########################################################################################
if(PID_PLATFORM_MANAGEMENT_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_PLATFORM_MANAGEMENT_FUNCTIONS_INCLUDED TRUE)
##########################################################################################


#############################################################################################
############### API functions for managing platform description variables ###################
#############################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Current_Platform| replace:: ``manage_Current_Platform``
#  .. _manage_Current_Platform:
#
#  manage_Current_Platform
#  ------------------------
#
#   .. command:: manage_Current_Platform(build_folder)
#
#    If the platform description has changed then clean and launch the reconfiguration of the package.
#
#     :build_folder: the path to the package build_folder.
#
macro(manage_Current_Platform build_folder)
	if(build_folder STREQUAL build)
		if(CURRENT_PLATFORM)# a current platform is already defined
			#if any of the following variable changed, the cache of the CMake project needs to be regenerated from scratch
			set(TEMP_PLATFORM ${CURRENT_PLATFORM})
			set(TEMP_C_COMPILER ${CMAKE_C_COMPILER})
			set(TEMP_CXX_COMPILER ${CMAKE_CXX_COMPILER})
			set(TEMP_CMAKE_LINKER ${CMAKE_LINKER})
			set(TEMP_CMAKE_RANLIB ${CMAKE_RANLIB})
			set(TEMP_CMAKE_CXX_COMPILER_ID ${CMAKE_CXX_COMPILER_ID})
			set(TEMP_CMAKE_CXX_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})
      set(TEMP_CXX_STANDARD_LIBRARIES ${CXX_STANDARD_LIBRARIES})
      foreach(lib IN LISTS TEMP_CXX_STANDARD_LIBRARIES)
        set(TEMP_CXX_STD_LIB_${lib}_ABI_SOVERSION ${CXX_STD_LIB_${lib}_ABI_SOVERSION})
      endforeach()
      set(TEMP_CXX_STD_SYMBOLS ${CXX_STD_SYMBOLS})
      foreach(symbol IN LISTS TEMP_CXX_STD_SYMBOLS)
        set(TEMP_CXX_STD_SYMBOL_${symbol}_VERSION ${CXX_STD_SYMBOL_${symbol}_VERSION})
      endforeach()
		endif()
	endif()
  load_Current_Platform()
	if(build_folder STREQUAL build)
		if(TEMP_PLATFORM)
			if( (NOT TEMP_PLATFORM STREQUAL CURRENT_PLATFORM) #the current platform has changed to we need to regenerate
					OR (NOT TEMP_C_COMPILER STREQUAL CMAKE_C_COMPILER)
					OR (NOT TEMP_CXX_COMPILER STREQUAL CMAKE_CXX_COMPILER)
					OR (NOT TEMP_CMAKE_LINKER STREQUAL CMAKE_LINKER)
					OR (NOT TEMP_CMAKE_RANLIB STREQUAL CMAKE_RANLIB)
					OR (NOT TEMP_CMAKE_CXX_COMPILER_ID STREQUAL CMAKE_CXX_COMPILER_ID)
					OR (NOT TEMP_CMAKE_CXX_COMPILER_VERSION STREQUAL CMAKE_CXX_COMPILER_VERSION)
				)
        set(DO_CLEAN TRUE)
      else()
        set(DO_CLEAN FALSE)
        foreach(lib IN LISTS TEMP_CXX_STANDARD_LIBRARIES)
          if(NOT TEMP_CXX_STD_LIB_${lib}_ABI_SOVERSION VERSION_EQUAL CXX_STD_LIB_${lib}_ABI_SOVERSION)
            set(DO_CLEAN TRUE)
            break()
          endif()
        endforeach()
        if(NOT DO_CLEAN)#must check that previous and current lists of standard libraries perfectly match
          foreach(lib IN LISTS CXX_STANDARD_LIBRARIES)
            if(NOT TEMP_CXX_STD_LIB_${lib}_ABI_SOVERSION VERSION_EQUAL CXX_STD_LIB_${lib}_ABI_SOVERSION)
              set(DO_CLEAN TRUE)
              break()
            endif()
          endforeach()
        endif()
        if(NOT DO_CLEAN)
          foreach(symbol IN LISTS TEMP_CXX_STD_SYMBOLS)
            if(NOT TEMP_CXX_STD_SYMBOL_${symbol}_VERSION VERSION_EQUAL CXX_STD_SYMBOL_${symbol}_VERSION)
              set(DO_CLEAN TRUE)
              break()
            endif()
          endforeach()
        endif()
        if(NOT DO_CLEAN)#must check that previous and current lists of ABI symbols perfectly match
          foreach(symbol IN LISTS CXX_STD_SYMBOLS)
            if(NOT CXX_STD_SYMBOL_${symbol}_VERSION VERSION_EQUAL TEMP_CXX_STD_SYMBOL_${symbol}_VERSION)
              set(DO_CLEAN TRUE)
              break()
            endif()
          endforeach()
        endif()

      endif()
      if(DO_CLEAN)
				message("[PID] INFO : cleaning the build folder after major environment change")
				hard_Clean_Package_Debug(${PROJECT_NAME})
				hard_Clean_Package_Release(${PROJECT_NAME})
				reconfigure_Package_Build_Debug(${PROJECT_NAME})#force reconfigure before running the build
				reconfigure_Package_Build_Release(${PROJECT_NAME})#force reconfigure before running the build
			endif()
		endif()
	endif()
endmacro(manage_Current_Platform)

#.rst:
#
# .. ifmode:: internal
#
#  .. |load_Current_Platform| replace:: ``load_Current_Platform``
#  .. _load_Current_Platform:
#
#  load_Current_Platform
#  ---------------------
#
#   .. command:: load_Current_Platform()
#
#    Load the platform description information into current process.
#
function(load_Current_Platform)
#loading the current platform configuration simply consist in including the config file generated by the workspace
include(${WORKSPACE_DIR}/pid/Workspace_Platforms_Info.cmake)
endfunction(load_Current_Platform)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reset_Package_Platforms_Variables| replace:: ``reset_Package_Platforms_Variables``
#  .. _reset_Package_Platforms_Variables:
#
#  reset_Package_Platforms_Variables
#  ---------------------------------
#
#   .. command:: reset_Package_Platforms_Variables()
#
#    Reset all platform constraints aplying to current project.
#
function(reset_Package_Platforms_Variables)

	if(${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX}) # reset all configurations satisfied by current platform
    foreach(config IN LISTS ${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX})
      set(${PROJECT_NAME}_PLATFORM_CONFIGURATION_${config}_ARGS${USE_MODE_SUFFIX} CACHE INTERNAL "")#reset arguments if any
    endforeach()
		set(${PROJECT_NAME}_PLATFORM_CONFIGURATIONS${USE_MODE_SUFFIX} CACHE INTERNAL "")
	endif()
	#reset all constraints defined by the package
	if(${PROJECT_NAME}_ALL_PLATFORMS_CONSTRAINTS${USE_MODE_SUFFIX} GREATER 0)
		set(CURRENT_INDEX 0)

		while(${${PROJECT_NAME}_ALL_PLATFORMS_CONSTRAINTS${USE_MODE_SUFFIX}} GREATER CURRENT_INDEX)
			set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONDITION_TYPE${USE_MODE_SUFFIX} CACHE INTERNAL "")
			set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONDITION_ARCH${USE_MODE_SUFFIX} CACHE INTERNAL "")
		  	set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONDITION_OS${USE_MODE_SUFFIX} CACHE INTERNAL "")
			set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONDITION_ABI${USE_MODE_SUFFIX} CACHE INTERNAL "")
			set(${PROJECT_NAME}_PLATFORM_CONSTRAINT_${CURRENT_INDEX}_CONFIGURATION${USE_MODE_SUFFIX} CACHE INTERNAL "")
			math(EXPR CURRENT_INDEX "${CURRENT_INDEX}+1")
		endwhile()
	endif()
	set(${PROJECT_NAME}_ALL_PLATFORMS_CONSTRAINTS${USE_MODE_SUFFIX} 0 CACHE INTERNAL "")
endfunction(reset_Package_Platforms_Variables)


#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Compatible_With_Current_ABI| replace:: ``is_Compatible_With_Current_ABI``
#  .. _is_Compatible_With_Current_ABI:
#
#  is_Compatible_With_Current_ABI
#  ------------------------------
#
#   .. command:: is_Compatible_With_Current_ABI(COMPATIBLE package)
#
#    Chech whether the given package binary in use use a compatible ABI for standard library.
#
#     :package: the name of binary package to check.
#
#     :COMPATIBLE: the output variable that is TRUE if package's stdlib usage is compatible with current platform ABI, FALSE otherwise.
#
function(is_Compatible_With_Current_ABI COMPATIBLE package)

  if((${package}_BUILT_WITH_CXX_ABI AND NOT ${package}_BUILT_WITH_CXX_ABI STREQUAL CURRENT_CXX_ABI)
    OR (${package}_BUILT_WITH_CMAKE_INTERNAL_PLATFORM_ABI AND NOT ${package}_BUILT_WITH_CMAKE_INTERNAL_PLATFORM_ABI STREQUAL CMAKE_INTERNAL_PLATFORM_ABI))
    set(${COMPATIBLE} FALSE PARENT_SCOPE)
    #remark: by default we are not restructive if teh binary file does not contain sur information
    return()
  else()
    #test for standard libraries versions
    foreach(lib IN LISTS ${package}_BUILT_WITH_CXX_STD_LIBRARIES)
      if(${package}_BUILT_WITH_CXX_STD_LIB_${lib}_ABI_SOVERSION
          AND CXX_STD_LIB_${lib}_ABI_SOVERSION
          AND (NOT ${package}_BUILT_WITH_CXX_STD_LIB_${lib}_ABI_SOVERSION STREQUAL CXX_STD_LIB_${lib}_ABI_SOVERSION))
          #soversion number must be defined for the given lib in order to be compared (if no sonumber => no restriction)
          set(${COMPATIBLE} FALSE PARENT_SCOPE)
          return()
      endif()
    endforeach()
    foreach(lib IN LISTS CXX_STANDARD_LIBRARIES)
      if(${package}_BUILT_WITH_CXX_STD_LIB_${lib}_ABI_SOVERSION
          AND CXX_STD_LIB_${lib}_ABI_SOVERSION
          AND (NOT ${package}_BUILT_WITH_CXX_STD_LIB_${lib}_ABI_SOVERSION STREQUAL CXX_STD_LIB_${lib}_ABI_SOVERSION))
          #soversion number must be defined for the given lib in order to be compared (if no sonumber => no restriction)
          set(${COMPATIBLE} FALSE PARENT_SCOPE)
          return()
      endif()
    endforeach()

    #test symbols versions
    foreach(symbol IN LISTS ${package}_BUILT_WITH_CXX_STD_SYMBOLS)#for each symbol used by the binary
      if(NOT CXX_STD_SYMBOL_${symbol}_VERSION)#corresponding symbol do not exist in current environment => it is an uncompatible binary
        set(${COMPATIBLE} FALSE PARENT_SCOPE)
        return()
      endif()

      #the binary has been built and linked against a newer version of standard libraries => NOT compatible
      if(${package}_BUILT_WITH_CXX_STD_SYMBOL_${symbol}_VERSION VERSION_GREATER CXX_STD_SYMBOL_${symbol}_VERSION)
        set(${COMPATIBLE} FALSE PARENT_SCOPE)
        return()
      endif()
    endforeach()
  endif()
  set(${COMPATIBLE} TRUE PARENT_SCOPE)
endfunction(is_Compatible_With_Current_ABI)
