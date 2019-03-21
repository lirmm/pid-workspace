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

include(Configuration_Definition NO_POLICY_SCOPE)

found_PID_Configuration(metis FALSE)

if(UNIX)
  find_path(METIS_INCLUDE_DIRS metis.h)
  find_library(METIS_LIBRARIES metis)

  set(IS_FOUND TRUE)
  if(METIS_INCLUDE_DIRS AND METIS_LIBRARIES)
    convert_PID_Libraries_Into_System_Links(METIS_LIBRARIES METIS_LINKS)#getting good system links (with -l)
    convert_PID_Libraries_Into_Library_Directories(METIS_LIBRARIES METIS_LIBDIR)
  else()
    message("[PID] ERROR : cannot find metis library.")
    set(IS_FOUND FALSE)
  endif()

  if(IS_FOUND)
    found_PID_Configuration(metis TRUE)
  endif ()

  unset(IS_FOUND)
endif ()
