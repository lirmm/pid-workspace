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

set(CURRENT_DISTRIBUTION CACHE INTERNAL "")
set(CURRENT_DISTRIBUTION_VERSION "" CACHE INTERNAL "")

if(PID_CROSSCOMPILATION)
  # when cross compiling we cannot deduce distribution info
	# but we can still use information coming from environment description
	set(CURRENT_DISTRIBUTION "${PID_USE_DISTRIBUTION}" CACHE INTERNAL "")
	set(CURRENT_DISTRIBUTION_VERSION "${PID_USE_DISTRIB_VERSION}" CACHE INTERNAL "")
  return()
endif()

#need to detect the distribution and version
if(CURRENT_PLATFORM_OS STREQUAL "windows")
	set(CURRENT_DISTRIBUTION "windows" CACHE INTERNAL "")
	if(CMAKE_SYSTEM_VERSION)
		set(CURRENT_DISTRIBUTION_VERSION ${CMAKE_SYSTEM_VERSION} CACHE INTERNAL "")
	endif()
elseif(CURRENT_PLATFORM_OS STREQUAL "macos")
	set(CURRENT_DISTRIBUTION "macos" CACHE INTERNAL "")
	if(CMAKE_SYSTEM_VERSION)
		set(CURRENT_DISTRIBUTION_VERSION ${CMAKE_SYSTEM_VERSION} CACHE INTERNAL "")
	endif()
elseif(CURRENT_PLATFORM_OS STREQUAL "freebsd")
  set(CURRENT_DISTRIBUTION "freebsd" CACHE INTERNAL "")
  if(CMAKE_SYSTEM_VERSION)
    set(CURRENT_DISTRIBUTION_VERSION ${CMAKE_SYSTEM_VERSION} CACHE INTERNAL "")
  endif()
elseif(CURRENT_PLATFORM_OS STREQUAL "linux")
  #on linuxwe need to detect the distribution, if any
  find_program(PATH_TO_LSB NAMES lsb_release NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
  if(NOT PATH_TO_LSB AND CURRENT_PACKAGING_SYSTEM_EXE)#try to install lsb_release based on the identified package manager
    set(package_name)
    if(CURRENT_PACKAGING_SYSTEM STREQUAL APT)
      execute_OS_Command(${CURRENT_PACKAGING_SYSTEM_EXE} ${CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS} lsb-release)
    elseif(CURRENT_PACKAGING_SYSTEM STREQUAL PACMAN)
      execute_OS_Command(${CURRENT_PACKAGING_SYSTEM_EXE} ${CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS} lsb-release)
    elseif(CURRENT_PACKAGING_SYSTEM STREQUAL YUM)
      execute_OS_Command(${CURRENT_PACKAGING_SYSTEM_EXE} ${CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS} redhat-lsb-core)
    endif()
    find_program(PATH_TO_LSB NAMES lsb_release NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)#trying to find again
  endif()

  # now check for distribution (shoud not influence contraints but only the way to install required constraints)
  # only for system that have multiple distributions
  if(PATH_TO_LSB)
    execute_process(COMMAND ${PATH_TO_LSB} -i
                    OUTPUT_VARIABLE DISTRIB_STR RESULT_VARIABLE lsb_res ERROR_QUIET) #lsb_release is a standard linux command to get information about the system, including the distribution ID
    if(NOT lsb_res EQUAL 0)
      # lsb_release is not available
      # checking for archlinux
      if(EXISTS "/etc/arch-release")
        set(DISTRIB_STR "Distributor ID:	Arch") # same string as lsb_release -i would return
      endif()
    endif()
    string(REGEX REPLACE "^[^:]+:[ \t\r]*([A-Za-z_0-9]+)[ \t\r\n]*$" "\\1" RES "${DISTRIB_STR}")

    if(NOT RES STREQUAL "${DISTRIB_STR}")#match
      string(TOLOWER "${RES}" DISTRIB_ID)
      set(CURRENT_DISTRIBUTION "${DISTRIB_ID}" CACHE INTERNAL "")
      execute_process(COMMAND lsb_release -r
                      OUTPUT_VARIABLE VERSION_STR ERROR_QUIET) #lsb_release is a standard linux command to get information about the system, including the distribution ID
      string(REGEX REPLACE "^[^:]+:[ \t\r]*([\\.0-9]+)[ \t\r\n]*$" "\\1" RES "${VERSION_STR}")
      if(NOT RES STREQUAL "${VERSION_STR}")#match
        string(TOLOWER "${RES}" VERSION_NUMBER)
        set(CURRENT_DISTRIBUTION_VERSION "${VERSION_NUMBER}" CACHE INTERNAL "")
      else()
        set(CURRENT_DISTRIBUTION_VERSION "" CACHE INTERNAL "")
      endif()
    else()
      set(CURRENT_DISTRIBUTION "" CACHE INTERNAL "")
      set(CURRENT_DISTRIBUTION_VERSION "" CACHE INTERNAL "")
    endif()
  endif()
endif()

#other OS are not known (add new elseif statement to check for other OS and set adequate variables)
