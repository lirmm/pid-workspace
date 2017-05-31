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

# the gcc compiler is user for building codes on host
set(PID_ENVIRONMENT_DESCRIPTION "The development environment is a 32 bit build based on the host default configuration (${CMAKE_CXX_COMPILER_ID})" CACHE INTERNAL "")

set(PID_CROSSCOMPILATION FALSE CACHE INTERNAL "") #do not crosscompile since it is the same environment (host)

#TODO check these commands (they do not seem to work all as expected)
execute_process(COMMAND sudo apt-get install gcc-multilib)
execute_process(COMMAND sudo apt-get install g++-multilib)
execute_process(COMMAND ln /usr/bin/ar ${CMAKE_SOURCE_DIR}/environments/host_linux32/i686-linux-gnu-ar)
execute_process(COMMAND chmod a+x ${CMAKE_SOURCE_DIR}/environments/host64_linux32/i686-linux-gnu-g++)
execute_process(COMMAND chmod a+x ${CMAKE_SOURCE_DIR}/environments/host64_linux32/i686-linux-gnu-gcc)
