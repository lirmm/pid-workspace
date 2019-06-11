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

execute_OS_Configuration_Command(apt update)
execute_OS_Configuration_Command(apt-get install -y xorg openbox libx11-dev)

if(x11_extensions)
  foreach(x11_ext_needed IN LISTS x11_extensions)# for each extensions needed
    string(TOLOWER ${x11_ext_needed} x11_ext_needed) # convert to lower case to match with X11_EXT_FOUND_NAMES
    message("[PID] INFO : installing/updating configuration x11 ${x11_ext_needed} extension...")
    if (x11_ext_needed MATCHES "xkb")
      execute_OS_Configuration_Command(apt-get install -y libxkbfile-dev)
    else()
      execute_OS_Configuration_Command(apt-get install -y lib${x11_ext_needed}-dev)
    endif()
  endforeach()
else()
  execute_OS_Configuration_Command(apt-get install -y libxt-dev libxft-dev libxv-dev libxau-dev libxdmcp-dev libxpm-dev libxcomposite-dev libxdamage-dev libxtst-dev libxi-dev libxinerama-dev libxfixes-dev libxrender-dev libxres-dev libxrandr-dev libxxf86vm-dev libxcursor-dev libxss-dev libxmu-dev libxkbfile-dev)
endif()
