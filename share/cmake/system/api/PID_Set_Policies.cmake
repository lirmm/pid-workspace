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

############ Guard for optimization of configuration process ############################
if(PID_SET_POLICIES_INCLUDED)
  return()
endif()
set(PID_SET_POLICIES_INCLUDED TRUE)
##########################################################################################


#.rst:
#
# .. ifmode:: internal
#
#  .. |policies| replace:: ``policies``
#  .. _policies:
#
#  script for setting policies
#  ---------------------------
#
#  Set the default policies applied by CMake during configuration process.
#

########################################################################
##################### definition of CMake policies #####################
########################################################################
cmake_policy(VERSION 3.0.2)

#not guarded policies (they exist since version 3.0 which is the minimum for PID)
set(CMAKE_WARN_DEPRECATED FALSE CACHE INTERNAL "" FORCE)
cmake_policy(SET CMP0048 OLD) #allow to use a custom versionning system
cmake_policy(SET CMP0037 OLD) #do not allow to redefine standard target such as clean or install
cmake_policy(SET CMP0026 NEW) #avoid using the LOCATION property
cmake_policy(SET CMP0045 NEW) #allow to test if a target exist without a warning on a get_target_property
cmake_policy(SET CMP0007 NEW) #do not allow a list to have empty elements without warning

if(POLICY CMP0009)
  cmake_policy(SET CMP0009 NEW)#do not follow symlinks by default in file(GLOB RECURSE)
endif()

# guarded policies (they exist in further version of CMake)
if(POLICY CMP0053)
	cmake_policy(SET CMP0053 NEW) #iSimplify variable reference and escape sequence evaluation
endif()

if(POLICY CMP0054)
	cmake_policy(SET CMP0054 NEW) #only KEYWORDS (without "") are considered as KEYWORDS
endif()

if(POLICY CMP0058)#if in a version of CMake that provides this policy
	cmake_policy(SET CMP0058 NEW) #avoid ninja to warn about Policy CMP0058 is not set
endif()

if(POLICY CMP0064)
	cmake_policy(SET CMP0064 NEW) #do not warn when a Keyword between guillemet "" is used in an if expression
endif()
