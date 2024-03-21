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

function(install_pip use_alternative)
  if(NOT use_alternative)
    #get the install procedure
    file(DOWNLOAD https://bootstrap.pypa.io/pip/${CURRENT_PYTHON}/get-pip.py ${CMAKE_BINARY_DIR}/get-pip.py)

    if(EXISTS ${CMAKE_BINARY_DIR}/get-pip.py)
      execute_OS_Command(${CURRENT_PYTHON_EXECUTABLE} get-pip.py WORKING_DIRECTORY ${CMAKE_BINARY_DIR})
    else()
      message("[PID] WARNING: cannot download official install script for pip !")
    endif()
  else()
    if(CURRENT_PACKAGING_SYSTEM STREQUAL APT)
      if(CURRENT_PYTHON VERSION_GREATER_EQUAL 3.0)
        execute_System_Packaging_Command(python3-pip)
      else()
        execute_System_Packaging_Command(python-pip)
      endif()
    elseif(CURRENT_PACKAGING_SYSTEM STREQUAL PACMAN)
      if(CURRENT_PYTHON VERSION_GREATER_EQUAL 3.0)
        execute_System_Packaging_Command(python3-pip)
      else()
        execute_System_Packaging_Command(python-pip)
      endif()
    elseif(CURRENT_PACKAGING_SYSTEM STREQUAL PKG)
      string(REPLACE "." "" res_py_version "${CURRENT_PYTHON}")
      execute_System_Packaging_Command(py${res_py_version}-pip)
    endif()
  endif()
endfunction(install_pip)

function(check_pip_installed INSTALLED)
set(${INSTALLED} FALSE PARENT_SCOPE)
execute_process(COMMAND ${CURRENT_PYTHON_EXECUTABLE} -m pip -V OUTPUT_VARIABLE output ERROR_VARIABLE output)
  if(output MATCHES "pip[ \t]+.*[ \t]+from[ \t]+.*\(python ${CURRENT_PYTHON}\)")
    set(${INSTALLED} TRUE PARENT_SCOPE)
  endif()
endfunction(check_pip_installed)

set(CURRENT_PYTHON CACHE INTERNAL "")
set(CURRENT_PYTHON_EXECUTABLE CACHE INTERNAL "")
set(CURRENT_PYTHON_LIBRARIES CACHE INTERNAL "")
set(CURRENT_PYTHON_INCLUDE_DIRS CACHE INTERNAL "")
set(PYTHONINTERP_FOUND FALSE)
set(PYTHONLIBS_FOUND FALSE)
set(Python_Language_AVAILABLE FALSE CACHE INTERNAL "")

find_package(PythonInterp) # find the default python interpreter (but will be configured with python variable from toolchain file)

if(PYTHONINTERP_FOUND)
  set(PY_VERSION "${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
  #Note: here the package is is installed on host but find_file and find_library calls it contains
  # will be interpreter relative to the system root (even in crosscompilation)
  find_package(PythonLibs ${PY_VERSION}) #searching for libs with the adequate version
  if(PYTHONLIBS_FOUND)
    set(CURRENT_PYTHON ${PY_VERSION} CACHE INTERNAL "")
    set(CURRENT_PYTHON_EXECUTABLE "${PYTHON_EXECUTABLE}" CACHE INTERNAL "")
    set(CURRENT_PYTHON_LIBRARIES "${PYTHON_LIBRARIES}" CACHE INTERNAL "")
    set(ALL_STD_LIBS)
    foreach(lib IN LISTS CURRENT_PYTHON_LIBRARIES)
      get_Binary_Description(DESCRIPTION ${lib})
      get_Soname(SONAME SOVERSION DESCRIPTION)
      list(APPEND ALL_STD_LIBS ${SONAME})
    endforeach()
    set(Python_STANDARD_LIBRARIES ${ALL_STD_LIBS} CACHE INTERNAL "")
    set(CURRENT_PYTHON_INCLUDE_DIRS ${PYTHON_INCLUDE_DIRS} CACHE INTERNAL "")
    set(Python_Language_AVAILABLE TRUE CACHE INTERNAL "")
  endif()
endif()

#now identifying the python package manager
set(CURRENT_PYTHON_PACKAGER CACHE INTERNAL "")
set(CURRENT_PYTHON_PACKAGER_EXE CACHE INTERNAL "")
set(CURRENT_PYTHON_PACKAGER_EXE_OPTIONS CACHE INTERNAL "")
if(Python_Language_AVAILABLE)#if python is available we should provide a package for it
  if(CURRENT_DISTRIBUTION STREQUAL "arch")
    #in arch, system wide python must be installed with pacman
    set(CURRENT_PYTHON_PACKAGER ${CURRENT_PACKAGING_SYSTEM} CACHE INTERNAL "")
    set(CURRENT_PYTHON_PACKAGER_EXE ${CURRENT_PACKAGING_SYSTEM_EXE} CACHE INTERNAL "")
    set(CURRENT_PYTHON_PACKAGER_EXE_OPTIONS ${CURRENT_PACKAGING_SYSTEM_EXE_OPTIONS} CACHE INTERNAL "")
  else()
    set(pip_installed FALSE)
    check_pip_installed(pip_installed)
    if(NOT pip_installed)
      #PROBLEM: pip is not installed for the current OS version
      install_pip(FALSE)
      check_pip_installed(pip_installed)
       if(NOT pip_installed)
        #PROBLEM: pip is still not installed for the current OS version, try with an alternative name for package
        install_pip(TRUE)
        check_pip_installed(pip_installed)
      endif()
    endif()
    if(pip_installed)
      set(CURRENT_PYTHON_PACKAGER PIP CACHE INTERNAL "")
      set(CURRENT_PYTHON_PACKAGER_EXE ${CURRENT_PYTHON_EXECUTABLE} -m pip CACHE INTERNAL "")
      set(CURRENT_PYTHON_PACKAGER_EXE_OPTIONS install CACHE INTERNAL "")
    endif()
    unset(pip_installed)
  endif()
endif()
