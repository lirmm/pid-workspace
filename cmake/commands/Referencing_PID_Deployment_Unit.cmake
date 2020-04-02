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

list(APPEND CMAKE_MODULE_PATH ${WORKSPACE_DIR}/cmake)
include(PID_Set_Modules_Path NO_POLICY_SCOPE)
include(PID_Contribution_Space_Functions NO_POLICY_SCOPE)
include(PID_Platform_Management_Functions NO_POLICY_SCOPE)

# needed to parse adequately CMAKe variables passed to the script
SEPARATE_ARGUMENTS(ALL_PUBLISHING_CS)
if(TARGET_ENVIRONMENT)
  foreach(cs_path IN LISTS ALL_PUBLISHING_CS)
    file(COPY ${CMAKE_BINARY_DIR}/share/ReferEnvironment${TARGET_ENVIRONMENT}.cmake
         DESTINATION ${cs_path}/references)
  endforeach()
  message("[PID] INFO: reference of environment ${TARGET_ENVIRONMENT} has been registered into the worskpace (target contribution spaces are: ${ALL_PUBLISHING_CS})")
elseif(TARGET_FRAMEWORK)
  foreach(cs_path IN LISTS ALL_PUBLISHING_CS)
    file(COPY ${CMAKE_BINARY_DIR}/share/ReferFramework${TARGET_FRAMEWORK}.cmake
         DESTINATION ${cs_path}/references)
  endforeach()
  message("[PID] INFO: reference of framework ${TARGET_FRAMEWORK} has been registered into the worskpace (target contribution spaces are: ${ALL_PUBLISHING_CS})")
elseif(TARGET_WRAPPER)
  foreach(cs_path IN LISTS ALL_PUBLISHING_CS)
    file(COPY ${CMAKE_BINARY_DIR}/share/ReferExternal${TARGET_WRAPPER}.cmake
         DESTINATION ${cs_path}/references)
    file(COPY ${CMAKE_BINARY_DIR}/share/Find${TARGET_WRAPPER}.cmake
         DESTINATION ${cs_path}/finds)
  endforeach()
  message("[PID] INFO: reference of external package ${TARGET_WRAPPER} has been registered into the worskpace (target contribution spaces are: ${ALL_PUBLISHING_CS})")
elseif(TARGET_PACKAGE)
  foreach(cs_path IN LISTS ALL_PUBLISHING_CS)
    file(COPY ${CMAKE_BINARY_DIR}/share/Refer${TARGET_PACKAGE}.cmake
         DESTINATION ${cs_path}/references)
    file(COPY ${CMAKE_BINARY_DIR}/share/Find${TARGET_PACKAGE}.cmake
         DESTINATION ${cs_path}/finds)
  endforeach()
  message("[PID] INFO: reference of native package ${TARGET_PACKAGE} has been registered into the worskpace (target contribution spaces are: ${ALL_PUBLISHING_CS})")
else()
  return()
endif()
