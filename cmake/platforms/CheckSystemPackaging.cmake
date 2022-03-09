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

set(PID_KNOWN_PACKAGING_SYSTEMS APT PACMAN YUM PKG BREW PORTS CHOCO CACHE INTERNAL "")
set(CURRENT_PACKAGING_SYSTEM CACHE INTERNAL "")
set(CURRENT_PACKAGING_SYSTEM_EXE CACHE INTERNAL "")
set(CURRENT_PACKAGING_SYSTEM_FORCE_NON_ROOT_USER FALSE CACHE INTERNAL "")
set(CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS CACHE INTERNAL "")
set(CURRENT_PACKAGING_SYSTEM_EXE_UPDATE_OPTIONS CACHE INTERNAL "")
set(CURRENT_PACKAGING_SYSTEM_EXE_UPGRADE_OPTIONS CACHE INTERNAL "")

#try to detect available packaging system depending on operating system
if(NOT PID_CROSSCOMPILATION) #there is a pâckaging system only if a distribution is defined

  if(CURRENT_PLATFORM_OS STREQUAL "linux")
    find_program(PATH_TO_APT NAMES apt-get NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
    if(PATH_TO_APT)
      set(CURRENT_PACKAGING_SYSTEM APT CACHE INTERNAL "")#sudo apt install -y ...
      set(CURRENT_PACKAGING_SYSTEM_EXE apt-get CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS install -y CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE_UPDATE_OPTIONS update -y CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE_UPGRADE_OPTIONS upgrade -y CACHE INTERNAL "")
    else()
      find_program(PATH_TO_PACMAN NAMES pacman NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
      if(PATH_TO_PACMAN)
        set(CURRENT_PACKAGING_SYSTEM PACMAN  CACHE INTERNAL "")#sudo pacman -S ... --noconfirm
        set(CURRENT_PACKAGING_SYSTEM_EXE pacman  CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS -S --noconfirm CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_EXE_UPDATE_OPTIONS -Syy --noconfirm CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_EXE_UPGRADE_OPTIONS -Syyu --noconfirm CACHE INTERNAL "")
        find_program(PATH_TO_YAY NAMES yay NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
        if(PATH_TO_YAY)#prefer using YAY if available
          set(CURRENT_PACKAGING_SYSTEM_EXE yay CACHE INTERNAL "")
          set(CURRENT_PACKAGING_SYSTEM_FORCE_NON_ROOT_USER TRUE CACHE INTERNAL "")#force a non root user, even in CI
        endif()
      else()
        find_program(PATH_TO_YUM NAMES yum NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
        if(PATH_TO_YUM)
          set(CURRENT_PACKAGING_SYSTEM YUM  CACHE INTERNAL "")
          set(CURRENT_PACKAGING_SYSTEM_EXE yum  CACHE INTERNAL "")#sudo yum install -y ...
          set(CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS install -y CACHE INTERNAL "")
          set(CURRENT_PACKAGING_SYSTEM_EXE_UPDATE_OPTIONS updateinfo -y CACHE INTERNAL "")
          set(CURRENT_PACKAGING_SYSTEM_EXE_UPGRADE_OPTIONS upgrade -y CACHE INTERNAL "")
        else()
          #TODO add more package management front end when necessary
        endif()
      endif()
    endif()

  elseif(CURRENT_PLATFORM_OS STREQUAL "macos")
    find_program(PATH_TO_BREW NAMES brew NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
    if(PATH_TO_BREW)
      set(CURRENT_PACKAGING_SYSTEM BREW  CACHE INTERNAL "")#sudo brew install ...
      set(CURRENT_PACKAGING_SYSTEM_EXE brew  CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS install CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE_UPDATE_OPTIONS update CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE_UPGRADE_OPTIONS upgrade CACHE INTERNAL "")
    else()
      find_program(PATH_TO_PORTS NAMES ports NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
      if(PATH_TO_PORTS)
        set(CURRENT_PACKAGING_SYSTEM PORTS  CACHE INTERNAL "")#sudo ports install ...
        set(CURRENT_PACKAGING_SYSTEM_EXE ports  CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS install CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_EXE_UPDATE_OPTIONS selfupdate CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_EXE_UPGRADE_OPTIONS upgrade outdated CACHE INTERNAL "")
      else()
        #TODO add more package manager when necessary
      endif()
    endif()

  elseif(CURRENT_PLATFORM_OS STREQUAL "freebsd")
    find_program(PATH_TO_PKG NAMES pkg NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
    if(PATH_TO_PKG)
      set(CURRENT_PACKAGING_SYSTEM PKG  CACHE INTERNAL "")#sudo brew install ...
      set(CURRENT_PACKAGING_SYSTEM_EXE pkg  CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS install -y CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE_UPDATE_OPTIONS update CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE_UPGRADE_OPTIONS upgrade -y CACHE INTERNAL "")
    endif()

  elseif(CURRENT_PLATFORM_OS STREQUAL "windows") #only chocolatey for now
    find_program(PATH_TO_CHOCO NAMES choco NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
    if(PATH_TO_CHOCO)
      set(CURRENT_PACKAGING_SYSTEM CHOCO  CACHE INTERNAL "")#choco install -y ...
      set(CURRENT_PACKAGING_SYSTEM_EXE choco  CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS install -y CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE_UPDATE_OPTIONS CACHE INTERNAL "")
      set(CURRENT_PACKAGING_SYSTEM_EXE_UPGRADE_OPTIONS upgrade all -y CACHE INTERNAL "")
    else()
      #TODO add more package manager when necessary
    endif()
  endif()
endif()
if(CURRENT_PACKAGING_SYSTEM)
  message("[PID] INFO: package manager detected is: ${CURRENT_PACKAGING_SYSTEM}")
else()
  message("[PID] WARNING: no package manager detected")
endif()

  #Note: In CI update/upgrade operation is automatic
if(NOT EVALUATION_RUN)#no need to reupdate the system anytime an environment is evaluated
  if(IN_CI_PROCESS)
    if(CURRENT_PACKAGING_SYSTEM)
      message("[PID] INFO: updating OS packages of the CI environment with package manager: ${CURRENT_PACKAGING_SYSTEM}")
      if(CURRENT_PACKAGING_SYSTEM STREQUAL PACMAN)
        # force updating the signing keys first to avoid potential install/upgrade issues
        execute_process(COMMAND pacman-key --refresh-keys)
      endif()
      execute_System_Packaging_Command()#do not provide package => update/uĝrade
    else()
      message("[PID] WARNING: cannot update OS packages of the CI environment because no package manager detected")
    endif()
  endif()
endif()
