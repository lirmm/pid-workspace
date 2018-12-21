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

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# To install the toolchain on your system see here :
# https://crosstool-ng.github.io/

#set(tools $ENV{HOME}/x-tools/)
set(CMAKE_C_COMPILER armv8-rpi3-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER armv8-rpi3-linux-gnueabihf-g++)

#Maybe useless
SET(CMAKE_FIND_ROOT_PATH $ENV{HOME}/x-tools/armv8-rpi3-linux-gnueabihf)

#The one usefull
SET(CMAKE_SYSROOT $ENV{HOME}/x-tools/armv8-rpi3-linux-gnueabihf/armv8-rpi3-linux-gnueabihf/sysroot)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
