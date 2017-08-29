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

########################################################################
##################### definition of CMake policies #####################
########################################################################

cmake_policy(SET CMP0026 OLD) #disable warning when reading LOCATION property
cmake_policy(SET CMP0048 OLD) #allow to use a custom versionning system
cmake_policy(SET CMP0037 OLD) #allow to redefine standard target such as clean
cmake_policy(SET CMP0045 OLD) #allow to test if a target exist without a warning

cmake_policy(SET CMP0007 NEW) #do not allow a list to have empty elements without warning

if(POLICY CMP0054)
	cmake_policy(SET CMP0054 NEW) #only KEYWORDS (without "") are considered as KEYWORDS
endif()

if(POLICY CMP0064)
	cmake_policy(SET CMP0064 NEW) #do not warn when a Keyword between guillemet "" is used in an if expression
endif()
