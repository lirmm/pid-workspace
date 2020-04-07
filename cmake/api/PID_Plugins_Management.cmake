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

##########################################################################################
############################ Guard for optimization of configuration process #############
##########################################################################################
if(PID_PLUGINS_MANAGEMENT_INCLUDED)
  return()
endif()
set(PID_PLUGINS_MANAGEMENT_INCLUDED TRUE)
##########################################################################################

include(PID_Contribution_Space_Functions NO_POLICY_SCOPE)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins_In_Package| replace:: ``manage_Plugins_In_Package``
#  .. _manage_Plugins_In_Package:
#
#  manage_Plugins_In_Package
#  -------------------------
#
#   .. command:: manage_Plugins_In_Package()
#
#    Manage actions of activated/deactivated plugins in currently built package.
#
macro(manage_Plugins_In_Package folder)
  set(target_path ${WORKSPACE_DIR}/pid/${CURRENT_PROFILE}/plugins/${folder})
  if(EXISTS ${target_path})#check if the folder exists, otherwise simply do nothing
    file(GLOB ALL_SCRIPTS "${target_path}/*")
    if(ALL_SCRIPTS)#check if the folder contains scripts, otherwise simply do nothing
      foreach(plugin_script IN LISTS ALL_SCRIPTS)
        include(${plugin_script})#simply include the corresponding cmake script
    	endforeach()
    endif()
  endif()
endmacro(manage_Plugins_In_Package)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins_In_Package_After_Components_Description| replace:: ``manage_Plugins_In_Package_After_Components_Description``
#  .. _manage_Plugins_In_Package_After_Components_Description:
#
#  manage_Plugins_In_Package_After_Components_Description
#  ------------------------------------------------------
#
#   .. command:: manage_Plugins_In_Package_After_Components_Description()
#
#    Callback function used in currently built package to manage specific configuration actions provided by active environments.
#    This callback is called AFTER components of the package have been described.
#
macro(manage_Plugins_In_Package_After_Components_Description)
  manage_Plugins_In_Package(after_comps)
endmacro(manage_Plugins_In_Package_After_Components_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins_In_Package_During_Components_Description| replace:: ``manage_Plugins_In_Package_During_Components_Description``
#  .. _manage_Plugins_In_Package_During_Components_Description:
#
#  manage_Plugins_In_Package_During_Components_Description
#  -------------------------------------------------------
#
#   .. command:: manage_Plugins_In_Package_During_Components_Description()
#
#    Callback function used in currently built package to manage specific configuration actions provided by active environments.
#    This callback is called DURING definition of each component of the package.
#
macro(manage_Plugins_In_Package_During_Components_Description)
  manage_Plugins_In_Package(during_comps)
endmacro(manage_Plugins_In_Package_During_Components_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins_Contribution_Into_Current_Component| replace:: ``manage_Plugins_Contribution_Into_Current_Component``
#  .. _manage_Plugins_Contribution_Into_Current_Component:
#
#  manage_Plugins_In_Package_During_Components_Description
#  -------------------------------------------------------
#
#   .. command:: manage_Plugins_Contribution_Into_Current_Component()
#
#    Macro configuring current component with environment specifications
#
macro(manage_Plugins_Contribution_Into_Current_Component)
  foreach(environment IN LISTS ${CURRENT_COMP_DEFINED}_ENVIRONMENTS)
    if(${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_INTERNAL)
      #Note : no need to give as they will not be part of the component interface
      declare_System_Component_Dependency(${CURRENT_COMP_DEFINED} FALSE
                                          "${${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_INTERNAL_INCLUDE_DIRS}"
                                          "${${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_INTERNAL_LIBRARY_DIRS}"
                                          ""#no locally defined definition
                                          ""#no exported definition
                                          "${${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_INTERNAL_DEFINITIONS}"#only dependency defintions
                                          "${${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_INTERNAL_OPTIONS}"
                                          "${${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_EXPORTED_STATIC_LINKS}"
                                          "${${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_EXPORTED_SHARED_LINKS}"
                                          "" "" "")
    endif()
    if(${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_EXPORTED)
      #TODO Note: need to manage export of this system dependency into binary description
      #need to say somethin equivalent to BUILD_WITH_XXX variables generated in binary packages
      # generate_Plugins_Cache_Variables(${environment}
      #                                 "${${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_EXPORTED_INCLUDE_DIRS}"
      #                                 "${${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_EXPORTED_LIBRARY_DIRS}"
      #                                 "${${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_EXPORTED_DEFINITIONS}"#only dependency defintions
      #                                 "${${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_EXPORTED_OPTIONS}"
      #                                 "${${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_EXPORTED_STATIC_LINKS}"
      #                                 "${${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_EXPORTED_SHARED_LINKS}"
      #                                 "${${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_EXPORTED_RUNTIME_RESOURCES}"
      #                               )
      #TODO : why not use expressions like for configurations since this is same kind of expressions?
      declare_System_Component_Dependency(${CURRENT_COMP_DEFINED} TRUE
                                          "${environment}_INCLUDE_DIRS"
                                          "${environment}_LIBRARY_DIRS"
                                          ""#no locally defined definition
                                          ""#no exported definition
                                          "${environment}_DEFINITIONS"#only dependency defintions
                                          "${environment}_COMPILER_OPTIONS"
                                          "${environment}_STATIC_LINKS"
                                          "${environment}_SHARED_LINKS"
                                          "" ""
                                          "${environment}_RPATH")
    endif()
  endforeach()
endmacro(manage_Plugins_Contribution_Into_Current_Component)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins_In_Package_Before_Components_Description| replace:: ``manage_Plugins_In_Package_Before_Components_Description``
#  .. _manage_Plugins_In_Package_Before_Components_Description:
#
#  manage_Plugins_In_Package_Before_Components_Description
#  -------------------------------------------------------
#
#   .. command:: manage_Plugins_In_Package_Before_Components_Description()
#
#    Callback function used in currently built package to manage specific configuration actions provided by active environments.
#    This callback is called BEFORE description of components of the package.
#
macro(manage_Plugins_In_Package_Before_Components_Description)
 manage_Plugins_In_Package(before_comps)
endmacro(manage_Plugins_In_Package_Before_Components_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins_In_Package_Before_Dependencies_Description| replace:: ``manage_Plugins_In_Package_Before_Dependencies_Description``
#  .. _manage_Plugins_In_Package_Before_Dependencies_Description:
#
#  manage_Plugins_In_Package_Before_Dependencies_Description
#  ---------------------------------------------------------
#
#   .. command:: manage_Plugins_In_Package_Before_Dependencies_Description()
#
#    Callback function used in currently built package to manage specific configuration actions provided by active environments.
#    This callback is called BEFORE description of dependencies of the package.
#
macro(manage_Plugins_In_Package_Before_Dependencies_Description)
 manage_Plugins_In_Package(before_deps)
endmacro(manage_Plugins_In_Package_Before_Dependencies_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Environment_Tool_For_Current_Profile| replace:: ``find_Environment_Tool_For_Current_Profile``
#  .. _find_Environment_Tool_For_Current_Profile:
#
#  find_Environment_Tool_For_Current_Profile
#  ------------------------------------------
#
#   .. command:: find_Environment_Tool_For_Current_Profile( RES_PREFIX profile)
#
#    Find the prefix to use to get description of configuration for an additional tool for a given profile
#
#     :environment: name of teh environment defining tool.
#
#     :RES_PREFIX: the prefix for variable holding the value for the given environment
#
#
function(find_Environment_Tool_For_Current_Profile RES_PREFIX environment)
  set(${RES_PREFIX} PARENT_SCOPE)
  set(current_profile_env ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT})
  find_Environment_Tool(RES_DEF ${current_profile_env} ${environment})
  if(RES_DEF)
    set(${RES_PREFIX} ${RES_DEF} PARENT_SCOPE)
  else()
    foreach(env IN LISTS PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS)
      find_Environment_Tool(RES_ADD ${env} ${environment})
      if(RES_ADD)
        set(${RES_PREFIX} ${RES_ADD} PARENT_SCOPE)
        return()
      endif()
    endforeach()
  endif()
endfunction(find_Environment_Tool_For_Current_Profile)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Environment_Tool| replace:: ``find_Environment_Tool``
#  .. _find_Environment_Tool:
#
#  find_Environment_Tool
#  ----------------------
#
#   .. command:: find_Environment_Tool()
#
#    Find the prefix to use to get description of configuration for an additional tool
#
#     :env_prefix: prefix for CMke variable holding info about environment.
#
#     :environment: name of the environment defining tool.
#
#     :RES_PREFIX: the prefix for variable holding the value for the given environment
#
#
function(find_Environment_Tool RES_PREFIX env_prefix environment)
  set(${RES_PREFIX} PARENT_SCOPE)
  list(FIND ${env_prefix}_EXTRA_TOOLS ${environment} INDEX)
  if(INDEX EQUAL -1)
    return()#not found
  endif()
  set(${RES_PREFIX} ${env_prefix}_EXTRA_${environment} PARENT_SCOPE)
endfunction(find_Environment_Tool)
