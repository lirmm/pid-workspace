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

set(PID_KNOWN_PACKAGING_SYSTEMS APT PACMAN YUM BREW PORTS CHOCO CACHE INTERNAL "")
#try to detect available packaging system depending on operating system
if(CURRENT_DISTRIBUTION AND NOT PID_CROSSCOMPILATION) #there is a pâckaging system only if a distribution is defined

  if(CURRENT_PLATFORM_OS STREQUAL "linux")
    find_program(PATH_TO_APT NAMES apt NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
    if(PATH_TO_APT)
      set(CURRENT_PACKAGING_SYSTEM APT CACHE INTERNAL "")#sudo apt install -y ...
      set(CURRENT_PACKAGING_SYSTEM_EXE apt  CACHE INTERNAL "")#sudo apt install -y ...
    else()
      find_program(PATH_TO_PACMAN NAMES pacman NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
      if(PATH_TO_PACMAN)
        set(CURRENT_PACKAGING_SYSTEM PACMAN  CACHE INTERNAL "")#sudo apt install -y ...
        set(CURRENT_PACKAGING_SYSTEM_EXE pacman  CACHE INTERNAL "")#sudo pacman -S ... --noconfirm
      else()
        find_program(PATH_TO_YUM NAMES yum NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
        if(PATH_TO_YUM)
          set(CURRENT_PACKAGING_SYSTEM YUM  CACHE INTERNAL "")
          set(CURRENT_PACKAGING_SYSTEM_EXE yum  CACHE INTERNAL "")#sudo yum install -y ...
        else()
          #TODO add more package management front end when necessary
        endif()
      endif()
    endif()

  elseif(CURRENT_PLATFORM_OS STREQUAL "macos")
    find_program(PATH_TO_BREW NAMES brew NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH) #sudo brew install ...
    if(PATH_TO_BREW)
      set(CURRENT_PACKAGING_SYSTEM BREW  CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE brew  CACHE INTERNAL "")
    else()
      find_program(PATH_TO_PORTS NAMES ports NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH) #sudo ports install ...
      if(PATH_TO_PORTS)
        set(CURRENT_PACKAGING_SYSTEM PORTS  CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_EXE ports  CACHE INTERNAL "")
      else()
        #TODO add more package manager when necessary
      endif()
    endif()

  elseif(CURRENT_PLATFORM_OS STREQUAL "windows") #only chocolatey for now
    find_program(PATH_TO_CHOCO NAMES choco NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH) #choco install -y ...
    if(PATH_TO_CHOCO)
      set(CURRENT_PACKAGING_SYSTEM CHOCO  CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE choco  CACHE INTERNAL "")
    else()
      #TODO add more package manager when necessary
    endif()
  endif()
endif()
