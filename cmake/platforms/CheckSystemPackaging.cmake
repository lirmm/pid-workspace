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

set(CURRENT_PACKAGING_SYSTEM CACHE INTERNAL "")
set(CURRENT_PACKAGING_SYSTEM_EXE CACHE INTERNAL "")
set(CURRENT_PACKAGING_SYSTEM_FORCE_NON_ROOT_USER FALSE CACHE INTERNAL "")
set(CURRENT_PACKAGING_SYSTEM_CMD_INSTALL CACHE INTERNAL "")
set(CURRENT_PACKAGING_SYSTEM_CMD_UPDATE CACHE INTERNAL "")
set(CURRENT_PACKAGING_SYSTEM_CMD_UPGRADE CACHE INTERNAL "")


set(PID_KNOWN_PACKAGING_SYSTEMS APT PACMAN YUM PKG BREW PORTS CHOCO CACHE INTERNAL "")
if(PID_USE_PACKAGER)
  append_Unique_In_Cache(PID_KNOWN_PACKAGING_SYSTEMS ${PID_USE_PACKAGER})
  set(CURRENT_PACKAGING_SYSTEM ${PID_USE_PACKAGER} CACHE INTERNAL "")
  set(CURRENT_PACKAGING_SYSTEM_EXE ${PID_USE_PACKAGER_EXE} CACHE INTERNAL "")
  set(CURRENT_PACKAGING_SYSTEM_FORCE_NON_ROOT_USER ${PID_USE_PACKAGER_NONROOT} CACHE INTERNAL "")
  set(CURRENT_PACKAGING_SYSTEM_CMD_INSTALL ${PID_USE_PACKAGER_INSTALL_CMD} CACHE INTERNAL "")
  set(CURRENT_PACKAGING_SYSTEM_CMD_UPDATE ${PID_USE_PACKAGER_UPDATE_CMD} CACHE INTERNAL "")
  set(CURRENT_PACKAGING_SYSTEM_CMD_UPGRADE ${PID_USE_PACKAGER_UPGRADE_CMD} CACHE INTERNAL "")
else()
  #try to detect available packaging system depending on operating system
  if(NOT PID_CROSSCOMPILATION) #there is a pâckaging system only if not crosscompiling
    if(CURRENT_PLATFORM_OS STREQUAL "linux")
      find_program(PATH_TO_APT NAMES apt-get NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
      if(PATH_TO_APT)
        set(CURRENT_PACKAGING_SYSTEM APT CACHE INTERNAL "")#sudo apt install -y ...
        set(CURRENT_PACKAGING_SYSTEM_EXE apt-get CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_CMD_INSTALL ${CURRENT_PACKAGING_SYSTEM_EXE} install -y CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_CMD_UPDATE ${CURRENT_PACKAGING_SYSTEM_EXE} update -y CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_CMD_UPGRADE ${CURRENT_PACKAGING_SYSTEM_EXE} upgrade -y CACHE INTERNAL "")
      else()
        find_program(PATH_TO_PACMAN NAMES pacman NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
        if(PATH_TO_PACMAN)
          set(CURRENT_PACKAGING_SYSTEM PACMAN  CACHE INTERNAL "")#sudo pacman -S ... --noconfirm
          set(CURRENT_PACKAGING_SYSTEM_EXE pacman CACHE INTERNAL "")
          find_program(PATH_TO_YAY NAMES yay NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
          if(PATH_TO_YAY)#prefer using YAY if available
            set(CURRENT_PACKAGING_SYSTEM_FORCE_NON_ROOT_USER TRUE CACHE INTERNAL "")#force a non root user, even in CI
            set(CURRENT_PACKAGING_SYSTEM_EXE yay CACHE INTERNAL "")
          endif()
          set(CURRENT_PACKAGING_SYSTEM_CMD_INSTALL ${CURRENT_PACKAGING_SYSTEM_EXE} -S --noconfirm CACHE INTERNAL "")
          set(CURRENT_PACKAGING_SYSTEM_CMD_UPDATE ${CURRENT_PACKAGING_SYSTEM_EXE} -Syy --noconfirm CACHE INTERNAL "")
          set(CURRENT_PACKAGING_SYSTEM_CMD_UPGRADE ${CURRENT_PACKAGING_SYSTEM_EXE} -Syyu --noconfirm CACHE INTERNAL "")
          
        else()
          find_program(PATH_TO_YUM NAMES yum NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
          if(PATH_TO_YUM)
            set(CURRENT_PACKAGING_SYSTEM YUM  CACHE INTERNAL "")
            set(CURRENT_PACKAGING_SYSTEM_EXE yum CACHE INTERNAL "")
            set(CURRENT_PACKAGING_SYSTEM_CMD_INSTALL ${CURRENT_PACKAGING_SYSTEM_EXE} install -y CACHE INTERNAL "")
            set(CURRENT_PACKAGING_SYSTEM_CMD_UPDATE ${CURRENT_PACKAGING_SYSTEM_EXE} updateinfo -y CACHE INTERNAL "")
            set(CURRENT_PACKAGING_SYSTEM_CMD_UPGRADE ${CURRENT_PACKAGING_SYSTEM_EXE} upgrade -y CACHE INTERNAL "")
          else()
            #TODO add more package management front end when necessary
          endif()
        endif()
      endif()

    elseif(CURRENT_PLATFORM_OS STREQUAL "macos")
      find_program(PATH_TO_BREW NAMES brew NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
      if(PATH_TO_BREW)
        set(CURRENT_PACKAGING_SYSTEM BREW  CACHE INTERNAL "")#sudo brew install ...
        set(CURRENT_PACKAGING_SYSTEM_EXE brew CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_CMD_INSTALL ${CURRENT_PACKAGING_SYSTEM_EXE} install CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_CMD_UPDATE ${CURRENT_PACKAGING_SYSTEM_EXE} update CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_CMD_UPGRADE ${CURRENT_PACKAGING_SYSTEM_EXE} upgrade CACHE INTERNAL "")
      else()
        find_program(PATH_TO_PORTS NAMES ports NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
        if(PATH_TO_PORTS)
          set(CURRENT_PACKAGING_SYSTEM PORTS  CACHE INTERNAL "")#sudo ports install ...
          set(CURRENT_PACKAGING_SYSTEM_EXE ports CACHE INTERNAL "")
          set(CURRENT_PACKAGING_SYSTEM_CMD_INSTALL ${CURRENT_PACKAGING_SYSTEM_EXE} install CACHE INTERNAL "")
          set(CURRENT_PACKAGING_SYSTEM_CMD_UPDATE ${CURRENT_PACKAGING_SYSTEM_EXE} selfupdate CACHE INTERNAL "")
          set(CURRENT_PACKAGING_SYSTEM_CMD_UPGRADE ${CURRENT_PACKAGING_SYSTEM_EXE} upgrade outdated CACHE INTERNAL "")
        else()
          #TODO add more package manager when necessary
        endif()
      endif()

    elseif(CURRENT_PLATFORM_OS STREQUAL "freebsd")
      find_program(PATH_TO_PKG NAMES pkg NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
      if(PATH_TO_PKG)
        set(CURRENT_PACKAGING_SYSTEM PKG  CACHE INTERNAL "")#sudo brew install ...
        set(CURRENT_PACKAGING_SYSTEM_EXE pkg CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_CMD_INSTALL ${CURRENT_PACKAGING_SYSTEM_EXE} install -y CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_CMD_UPDATE ${CURRENT_PACKAGING_SYSTEM_EXE} update CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_CMD_UPGRADE ${CURRENT_PACKAGING_SYSTEM_EXE} upgrade -y CACHE INTERNAL "")
      endif()

    elseif(CURRENT_PLATFORM_OS STREQUAL "windows") #only chocolatey for now
      find_program(PATH_TO_CHOCO NAMES choco NO_CMAKE_PATH NO_CMAKE_ENVIRONMENT_PATH)
      if(PATH_TO_CHOCO)
        set(CURRENT_PACKAGING_SYSTEM CHOCO  CACHE INTERNAL "")#choco install -y ...
        set(CURRENT_PACKAGING_SYSTEM_EXE choco CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_CMD_INSTALL ${CURRENT_PACKAGING_SYSTEM_EXE} install -y CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_CMD_UPDATE CACHE INTERNAL "")
        set(CURRENT_PACKAGING_SYSTEM_CMD_UPGRADE ${CURRENT_PACKAGING_SYSTEM_EXE} upgrade all -y CACHE INTERNAL "")
      else()
        #TODO add more package manager when necessary
      endif()
    endif()
  endif()
  if(ADDITIONAL_DEBUG_INFO)
    if(CURRENT_PACKAGING_SYSTEM)
      message("[PID] INFO: package manager detected is: ${CURRENT_PACKAGING_SYSTEM}")
    else()
      message("[PID] WARNING: no package manager detected")
    endif()
  endif()
endif()

#for eventual backward compatibility with wrappers directly using those variables
set(CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS CACHE INTERNAL "")

  #Note: In CI update/upgrade operation is automatic
if(NOT EVALUATION_RUN)#no need to reupdate the system anytime an environment is evaluated
  if(IN_CI_PROCESS)
    if(CURRENT_PACKAGING_SYSTEM)
      message("[PID] INFO: updating OS packages of the CI environment with package manager: ${CURRENT_PACKAGING_SYSTEM}")
      execute_System_Packaging_Command()#do not provide package => update/uĝrade
    else()
      message("[PID] WARNING: cannot update OS packages of the CI environment because no package manager detected")
    endif()
  endif()
endif()
