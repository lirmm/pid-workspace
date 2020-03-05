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
include(PID_Wrapper_API_Internal_Functions NO_POLICY_SCOPE)
load_Current_Platform() #loading the current platform configuration
configure_Contribution_Spaces()

#using
set(constraints "")
if(DEFINED ENV{arguments})
	set(EVAL_ARGUMENTS $ENV{arguments})
  separate_arguments(EVAL_ARGUMENTS)
  if(EVAL_ARGUMENTS)
    set(first_arg_done FALSE)
    foreach(arg IN LISTS EVAL_ARGUMENTS)
      if(first_arg_done)
        set(constraints "${constraints}:${arg}")
      else()
        set(constraints "${constraints}[${arg}")
      endif()
      set(first_arg_done TRUE)
    endforeach()
    set(constraints "${constraints}]")
  endif()
endif()
set(ENV{arguments})#reset environment variable
set(package_dir ${WORKSPACE_DIR}/wrappers/${TARGET_EXTERNAL_PACKAGE})
set(package_system_install_dir ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/system/${TARGET_EXTERNAL_PACKAGE})

begin_Progress(${TARGET_EXTERNAL_PACKAGE} GLOBAL_PROGRESS_VAR) #managing the build from a global point of view
check_System_Configuration(RESULT_OK CONFIG_NAME CONFIG_CONSTRAINTS "${TARGET_EXTERNAL_PACKAGE}${constraints}" Release)
finish_Progress(${GLOBAL_PROGRESS_VAR})
if(NOT RESULT_OK)
  message("[PID] ERROR : Evaluation of ${CONFIG_NAME} system configuration FAILED !")
  if(EVAL_ARGUMENTS)
    message(" --- Input constraints ---")
    foreach(constraint IN LISTS EVAL_ARGUMENTS)
      message("- ${constraint}")
    endforeach()
  endif()
  return()
endif()

message("[PID] INFO : Evaluation of ${CONFIG_NAME} system configuration SUCCEEDED")
if(EVAL_ARGUMENTS)
  message(" --- Input constraints ---")
  foreach(constraint IN LISTS EVAL_ARGUMENTS)
    message("- ${constraint}")
  endforeach()
endif()
message(" --- Returned variables ---")
foreach(var IN LISTS ${TARGET_EXTERNAL_PACKAGE}_RETURNED_VARIABLES)
  message("- ${TARGET_EXTERNAL_PACKAGE}_${var} = ${${TARGET_EXTERNAL_PACKAGE}_${var}}")
endforeach()
message(" --- Final contraints in binary ---")
foreach(constraint IN LISTS CONFIG_CONSTRAINTS)
  message("- ${constraint}")
endforeach()
