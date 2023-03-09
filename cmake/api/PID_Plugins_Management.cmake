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
#  .. |manage_Plugins_In_Wrapper| replace:: ``manage_Plugins_In_Wrapper``
#  .. _manage_Plugins_In_Wrapper:
#
#  manage_Plugins_In_Wrapper
#  -------------------------
#
#   .. command:: manage_Plugins_In_Wrapper(filename)
#
#    Manage actions of activated plugins in currently built wrapper.
#
#    :filename : name of the file listing used plugins.
#    :package : name of the wrapper being built.
#    :version : version of the wrapper being built.
#
macro(manage_Plugins_In_Wrapper filename package version)
  set(plugins_path ${WORKSPACE_DIR}/build/${CURRENT_PROFILE}/plugins)
  #only manage on demand plugins for wrappers
  #Note: if they are part of _EXTRA_TOOLS_REQUIRED variable this means they have been required
  foreach(tool IN LISTS ${package}_KNOWN_VERSION_${version}_EXTRA_TOOLS)
    if(EXISTS ${plugins_path}/${tool}/${filename}.cmake)
      #get the corresponding instance in current profile description
      list(FIND ${package}_KNOWN_VERSION_${version}_EXTRA_TOOLS ${tool} index)
      list(GET ${package}_KNOWN_VERSION_${version}_EXTRA_TOOLS_INSTANCES ${index} instance)
      set(${tool}_TOOL_INSTANCE ${instance})
      include(${plugins_path}/${tool}/${filename}.cmake)
    endif()
  endforeach()
endmacro(manage_Plugins_In_Wrapper)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins_In_Wrapper_Before_Dependencies_Description| replace:: ``manage_Plugins_In_Wrapper_Before_Dependencies_Description``
#  .. _manage_Plugins_In_Wrapper_Before_Dependencies_Description:
#
#  manage_Plugins_In_Wrapper_Before_Dependencies_Description
#  ---------------------------------------------------------
#
#   .. command:: manage_Plugins_In_Wrapper_Before_Dependencies_Description()
#
#    Callback function used in currently built wrapper to manage specific configuration actions provided by active environments.
#    This callback is called BEFORE resolution of dependencies of the wrapper version being built.
#
#    :package : name of the wrapper being built.
#    :version : version of the wrapper being built.
#
macro(manage_Plugins_In_Wrapper_Before_Dependencies_Description package version)
 manage_Plugins_In_Wrapper(before_deps ${package} ${version})
endmacro(manage_Plugins_In_Wrapper_Before_Dependencies_Description)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Plugins_In_Wrapper_After_Components_Description| replace:: ``manage_Plugins_In_Wrapper_After_Components_Description``
#  .. _manage_Plugins_In_Wrapper_After_Components_Description:
#
#  manage_Plugins_In_Wrapper_After_Components_Description
#  ------------------------------------------------------
#
#   .. command:: manage_Plugins_In_Wrapper_After_Components_Description()
#
#    Callback function used in currently built wrapper to manage specific configuration actions provided by active environments.
#    This callback is called AFTER wrapper has been built.
#
#    :package : name of the wrapper being built.
#    :version : version of the wrapper being built.
#
macro(manage_Plugins_In_Wrapper_After_Components_Description package version)
  manage_Plugins_In_Wrapper(after_comps ${package} ${version})
endmacro(manage_Plugins_In_Wrapper_After_Components_Description)


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
#   .. command:: manage_Plugins_In_Package(filename)
#
#    Manage actions of activated/deactivated plugins in currently built package.
#
#    :filename : name of the file listing automatically used plugins.
#
macro(manage_Plugins_In_Package filename)
  set(plugins_path ${WORKSPACE_DIR}/build/${CURRENT_PROFILE}/plugins)
  set(target_path ${plugins_path}/auto_${filename}.cmake)
  if(EXISTS ${target_path})#check if the folder exists, otherwise simply do nothing
    include(${target_path})
    foreach(tool IN LISTS PLUGINS_TO_EXECUTE)
      include(${plugins_path}/${tool}/${filename}.cmake)
    endforeach()
    set(PLUGINS_TO_EXECUTE CACHE INTERNAL "")#reset variable provided by the file
  endif()
  #also manage on demand plugins
  #Note: if they are part of _EXTRA_TOOLS_REQUIRED variable this means they have been required
  foreach(tool IN LISTS ${PROJECT_NAME}_EXTRA_TOOLS_REQUIRED)
    if(EXISTS ${plugins_path}/${tool}/${filename}.cmake)
      #get the corresponding instance in current profile description
      list(FIND ${PROJECT_NAME}_EXTRA_TOOLS_REQUIRED ${tool} index)
      list(GET ${PROJECT_NAME}_EXTRA_TOOLS_INSTANCES_REQUIRED ${index} instance)
      set(${tool}_TOOL_INSTANCE ${instance})
      include(${plugins_path}/${tool}/${filename}.cmake)
    endif()
  endforeach()
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
    if(${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_INTERNAL_CONFIGURATION)
      foreach(config IN LISTS ${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_INTERNAL_CONFIGURATION)
        #Note : no need to give as they will not be part of the component interface
        declare_System_Component_Dependency_Using_Configuration(
          ${CURRENT_COMP_DEFINED}
          FALSE
          ${config}
          ""
          ""
          ""
        )
      endforeach()
    endif()
    if(${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_EXPORTED_CONFIGURATION)
      foreach(config IN LISTS ${CURRENT_COMP_DEFINED}_ENVIRONMENT_${environment}_EXPORTED_CONFIGURATION)
        declare_System_Component_Dependency_Using_Configuration(
          ${CURRENT_COMP_DEFINED}
          TRUE
          ${config}
          ""
          ""
          ""
        )
        #need to say somethin equivalent to BUILD_WITH_XXX variables generated in binary packages
      endforeach()
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
#  .. |find_Automatic_Tool_Prefix_For_Current_Profile| replace:: ``find_Automatic_Tool_Prefix_For_Current_Profile``
#  .. _find_Automatic_Tool_For_Current_Profile:
#
#  find_Automatic_Tool_Prefix_For_Current_Profile
#  ----------------------------------------------
#
#   .. command:: find_Automatic_Tool_Prefix_For_Current_Profile( RES_PREFIX profile)
#
#    Find the prefix to use to get description of configuration for an additional tool for a given profile
#
#     :environment: name of the environment defining tool.
#
#     :RES_PREFIX: the prefix for variable holding the value for the given environment
#
#
function(find_Automatic_Tool_Prefix_For_Current_Profile RES_PREFIX environment)
  set(${RES_PREFIX} PARENT_SCOPE)
  hashcode_From_Expression(def_name def_hash ${PROFILE_${CURRENT_PROFILE}_DEFAULT_ENVIRONMENT})
  find_Automatic_Tool_Prefix(RES_DEF ${def_name}_${def_hash} ${environment})
  if(RES_DEF)
    set(${RES_PREFIX} ${RES_DEF} PARENT_SCOPE)
  else()
    foreach(env IN LISTS PROFILE_${CURRENT_PROFILE}_MORE_ENVIRONMENTS)
      hashcode_From_Expression(name hash ${env})
      find_Automatic_Tool_Prefix(RES_ADD ${name}_${hash} ${environment})
      if(RES_ADD)
        set(${RES_PREFIX} ${RES_ADD} PARENT_SCOPE)
        return()
      endif()
    endforeach()
  endif()
endfunction(find_Automatic_Tool_Prefix_For_Current_Profile)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_Automatic_Tool_Prefix| replace:: ``find_Automatic_Tool_Prefix``
#  .. _find_Environment_Tool:
#
#  find_Automatic_Tool_Prefix
#  --------------------------
#
#   .. command:: find_Automatic_Tool_Prefix()
#
#    Find the prefix to use to get description of configuration for an additional tool
#
#     :env_prefix: prefix for CMake variable holding info about environment.
#     :environment: name of the environment defining tool.
#
#     :RES_PREFIX: the prefix for variable holding the value for the given environment
#
#
function(find_Automatic_Tool_Prefix RES_PREFIX env_prefix environment)
  set(${RES_PREFIX} PARENT_SCOPE)
  list(FIND ${env_prefix}_EXTRA_TOOLS ${environment} INDEX)
  if(INDEX EQUAL -1)
    return()#not found
  endif()
  set(${RES_PREFIX} ${env_prefix}_EXTRA_${environment} PARENT_SCOPE)
endfunction(find_Automatic_Tool_Prefix)

#.rst:
#
# .. ifmode:: internal
#
#  .. |find_On_Demand_Tool_Prefix| replace:: ``find_On_Demand_Tool_Prefix``
#  .. _find_On_Demand_Tool_Prefix:
#
#  find_On_Demand_Tool_Prefix
#  ---------------------------
#
#   .. command:: find_On_Demand_Tool_Prefix(RES_PREFIX tool)
#
#    Find the prefix to use to get description of configuration for an additional tool
#
#     :tool: name of the tool
#     :RES_PREFIX: output variable containing the prefix for variable holding the values for the given tool
#
#
function(find_On_Demand_Tool_Prefix RES_PREFIX tool)
  set(${RES_PREFIX} ${${tool}_TOOL_INSTANCE}_EXTRA_${tool} PARENT_SCOPE)
endfunction(find_On_Demand_Tool_Prefix)
