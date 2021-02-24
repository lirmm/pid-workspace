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
include(PID_Set_Policies NO_POLICY_SCOPE)
include(PID_Wrapper_API_Internal_Functions NO_POLICY_SCOPE)
load_Workspace_Info() #loading the current platform configuration
configure_Contribution_Spaces()

set(package_dir ${WORKSPACE_DIR}/wrappers/${TARGET_EXTERNAL_PACKAGE})
set(package_system_src_dir ${package_dir}/src/system)
set(package_system_install_dir ${WORKSPACE_DIR}/install/${CURRENT_PLATFORM}/__system__/${TARGET_EXTERNAL_PACKAGE})

set(regenerate FALSE)
if(NOT EXISTS ${package_system_install_dir})
  set(regenerate TRUE)
else()
  is_Src_File_Updated(UPDATED ${package_system_install_dir}/check_${TARGET_EXTERNAL_PACKAGE}.cmake ${package_system_src_dir}/CMakeLists.txt)
  if(UPDATED)#description is updated since last timecheck was generated
    set(regenerate TRUE)
  else()
    include(${package_system_install_dir}/check_${TARGET_EXTERNAL_PACKAGE}.cmake)
    set(eval_src_file ${package_system_src_dir}/${${TARGET_EXTERNAL_PACKAGE}_EVAL_FILE})
    set(eval_install_file ${package_system_install_dir}/${${TARGET_EXTERNAL_PACKAGE}_EVAL_FILE})
    is_Src_File_Updated(UPDATED_EVAL ${eval_install_file} ${eval_src_file})
    if(UPDATED_EVAL)
      set(regenerate TRUE)
    endif()
  endif()
endif()
if(regenerate)
  if(NOT EXISTS ${package_dir}/build/Build${TARGET_EXTERNAL_PACKAGE}.cmake)
    message(FATAL_ERROR "[PID] CRITICAL ERROR : build configuration file has not been generated for ${TARGET_EXTERNAL_PACKAGE}, please rerun wrapper configruation...")
  endif()

  include(${package_dir}/build/Build${TARGET_EXTERNAL_PACKAGE}.cmake)#load the content description

  if(NOT ${TARGET_EXTERNAL_PACKAGE}_SYSTEM_CONFIGURATION_DEFINED) #check that the target version exists
    message(FATAL_ERROR "[PID] CRITICAL ERROR : wrapper of ${TARGET_EXTERNAL_PACKAGE} does not define any system configuration check !!! Build aborted ...")
  endif()
  generate_Wrapper_System_Configuration_Check_Scripts(${TARGET_EXTERNAL_PACKAGE} ${package_system_src_dir} ${package_system_install_dir})
endif()

begin_Progress(${TARGET_EXTERNAL_PACKAGE} GLOBAL_PROGRESS_VAR) #managing the build from a global point of view
evaluate_Wrapper_System_Config_From_Script(RESULT_OK OUTPUTS INPUTS ${TARGET_EXTERNAL_PACKAGE})
finish_Progress(${GLOBAL_PROGRESS_VAR})
if(NOT RESULT_OK)
  message("[PID] ERROR : Evaluation of ${TARGET_EXTERNAL_PACKAGE} system configuration FAILED !")
  if(INPUTS)
    message(" --- Input constraints ---")
    foreach(constraint IN LISTS INPUTS)
      message("- ${constraint}")
    endforeach()
  endif()
  return()
endif()

message("[PID] INFO : Evaluation of ${TARGET_EXTERNAL_PACKAGE} system configuration SUCCEEDED")
if(INPUTS)
  message(" --- Input constraints ---")
  foreach(constraint IN LISTS INPUTS)
    message("- ${constraint}")
  endforeach()
endif()
message(" --- Returned variables ---")
foreach(var IN LISTS ${TARGET_EXTERNAL_PACKAGE}_RETURNED_VARIABLES)
  message("- ${TARGET_EXTERNAL_PACKAGE}_${var} = ${${TARGET_EXTERNAL_PACKAGE}_${var}}")
endforeach()
message(" --- Final contraints in binary ---")
foreach(constraint IN LISTS OUTPUTS)
  message("- ${constraint}")
endforeach()
