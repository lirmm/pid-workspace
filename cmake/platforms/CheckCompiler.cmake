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

#check simply ised to have a clean and standardized way to get compiler identification in PID

if (CMAKE_ASM_COMPILER_ID MATCHES "GNU" OR CMAKE_COMPILER_IS_GNUCXX)
  set(CURRENT_ASM_COMPILER "gcc")
elseif(CMAKE_ASM_COMPILER_ID MATCHES "Clang|clang")
  set(CURRENT_ASM_COMPILER "clang")
elseif(CMAKE_ASM_COMPILER_ID MATCHES "AppleClang")
  set(CURRENT_ASM_COMPILER "appleclang")
elseif(CMAKE_ASM_COMPILER_ID MATCHES "MSVC")
  set(CURRENT_ASM_COMPILER "msvc")
elseif(CMAKE_ASM_COMPILER_ID MATCHES "icc|icl|Intel|intel")
  set(CURRENT_ASM_COMPILER "icc")
else()
  set(CURRENT_ASM_COMPILER ${CMAKE_ASM_COMPILER_ID})
endif()

if (CMAKE_CXX_COMPILER_ID MATCHES "GNU" OR CMAKE_COMPILER_IS_GNUCXX)
  set(CURRENT_CXX_COMPILER "gcc")
  set(CURRENT_CXX_COMPILER_WARN_ALL_OPTIONS -Wall -Wextra)
  set(CURRENT_CXX_COMPILER_WARN_AS_ERRORS_OPTIONS -Werror)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang|clang")
  set(CURRENT_CXX_COMPILER "clang")
  set(CURRENT_CXX_COMPILER_WARN_ALL_OPTIONS -Wall -Wextra)
  set(CURRENT_CXX_COMPILER_WARN_AS_ERRORS_OPTIONS -Werror)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "AppleClang")
  set(CURRENT_CXX_COMPILER "appleclang")
  set(CURRENT_CXX_COMPILER_WARN_ALL_OPTIONS -Wall -Wextra)
  set(CURRENT_CXX_COMPILER_WARN_AS_ERRORS_OPTIONS -Werror)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
  set(CURRENT_CXX_COMPILER "msvc")
  set(CURRENT_CXX_COMPILER_WARN_ALL_OPTIONS /Wall)
  set(CURRENT_CXX_COMPILER_WARN_AS_ERRORS_OPTIONS /WX)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "icc|icl|Intel|intel")
  set(CURRENT_CXX_COMPILER "icc")
  set(CURRENT_CXX_COMPILER_WARN_ALL_OPTIONS -Wall -Wextra)
  set(CURRENT_CXX_COMPILER_WARN_AS_ERRORS_OPTIONS -Werror)
else()
  set(CURRENT_CXX_COMPILER ${CMAKE_CXX_COMPILER_ID})
endif()

if (CMAKE_C_COMPILER_ID MATCHES "GNU" OR CMAKE_COMPILER_IS_GNUCXX)
  set(CURRENT_C_COMPILER "gcc")
elseif(CMAKE_C_COMPILER_ID MATCHES "Clang|clang")
  set(CURRENT_C_COMPILER "clang")
elseif(CMAKE_C_COMPILER_ID MATCHES "AppleClang")
  set(CURRENT_C_COMPILER "appleclang")
elseif(CMAKE_C_COMPILER_ID MATCHES "MSVC")
  set(CURRENT_C_COMPILER "msvc")
elseif(CMAKE_C_COMPILER_ID MATCHES "icc|icl|Intel|intel")
  set(CURRENT_C_COMPILER "icc")
else()
  set(CURRENT_C_COMPILER ${CMAKE_C_COMPILER_ID})
endif()
#all those languages are available by default
set(ASM_Language_AVAILABLE TRUE CACHE INTERNAL "")
set(C_Language_AVAILABLE TRUE CACHE INTERNAL "")
set(CXX_Language_AVAILABLE TRUE CACHE INTERNAL "")
