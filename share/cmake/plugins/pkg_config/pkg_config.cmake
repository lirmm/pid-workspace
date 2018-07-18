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

if(WIN32)
  set(LIBRARY_KEYWORD "")
elseif(UNIX)
  # Using -l:/some/absolute/path.so was an "undocumented ld feature, in
  # actual fact a ld bug, that has since been fixed".
  # This was apparently used (e.g. in ROS) because of pkg-config problems that
  # have since been fixed.
  # See: https://github.com/ros/catkin/issues/694#issuecomment-88323282
  # Note: ld version on Linux can be 2.25.1 or 2.24
  if (NOT CMAKE_LINKER)
    include(CMakeFindBinUtils)
  endif()

  execute_process(COMMAND ${CMAKE_LINKER} -v OUTPUT_VARIABLE LD_VERSION_STR ERROR_VARIABLE LD_VERSION_STR)
  string(REGEX MATCH "([0-9]+\\.[0-9]+(\\.[0-9]+)?)" LD_VERSION ${LD_VERSION_STR})
  if(LD_VERSION VERSION_LESS "2.24.90")#below this version pkg-config does not handle properly absolute path
    set(LIBRARY_KEYWORD "-l:")
  else()
    set(LIBRARY_KEYWORD "")
  endif()
endif()

# generate_Pkg_Config_Files
# ----------------------------------
#
# generate the .pc file corresponding to the library defined in the current project
#
function(generate_Pkg_Config_Files path_to_build_folder package platform version library_name mode)
	#generate and install .pc files for the library
  setup_And_Install_Library_Pkg_Config_File(${path_to_build_folder} ${package} ${platform} ${version} ${library_name} ${mode})
  # manage recursion with dependent packages (directly using their use file) to ensure generation of the library dependencies
  generate_Pkg_Config_Files_For_Dependencies(${path_to_build_folder} ${package} ${platform} ${version} ${library_name} ${mode})
endfunction(generate_Pkg_Config_Files)

###
function(generate_Pkg_Config_Files_For_Dependencies path_to_build_folder package platform version library_name mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode}) #getting mode info that will be used for generating adequate names
  foreach(dep_package IN LISTS ${package}_${library_name}_DEPENDENCIES${VAR_SUFFIX})
    foreach(dep_component IN LISTS ${package}_${library_name}_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
      # if(NOT EXISTS ${WORKSPACE_DIR}/pid/share/pkgconfig/${dep_package}_${${dep_package}_VERSION_STRING}_${dep_component}${TARGET_SUFFIX}.pc)
        #generate the pkg-config file to be sure the adeqaute version used locally is existing
        generate_Pkg_Config_Files(${path_to_build_folder} ${dep_package} ${platform} ${${dep_package}_VERSION_STRING} ${dep_component} ${mode})
      # endif()
    endforeach()
  endforeach()
endfunction(generate_Pkg_Config_Files_For_Dependencies)


###
#using a function (instead of a macro) ensures that local variable defined within macros will no be exported outside the context of the function
function(setup_And_Install_Library_Pkg_Config_File path_to_build_folder package platform version library_name mode)
  #set the local variable of the project
  setup_Pkg_Config_Variables(${package} ${platform} ${version} ${library_name} ${mode})
  # write and install .pc files of the project from these variables
  install_Pkg_Config_File(${path_to_build_folder} ${package} ${platform} ${version} ${library_name} ${mode})
endfunction(setup_And_Install_Library_Pkg_Config_File)

### generate and install pkg-config .pc files
macro(install_Pkg_Config_File path_to_build_folder package platform version library_name mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode}) #getting mode info that will be used for generating adequate names
  if(EXISTS ${path_to_build_folder}/${package}_${library_name}${TARGET_SUFFIX}.pc)
    file(REMOVE ${path_to_build_folder}/${package}_${library_name}${TARGET_SUFFIX}.pc)
  endif()
  #generate a temporary file with the adequate pkg-config format but whose content is not already generated from cmake
  configure_file("${WORKSPACE_DIR}/share/cmake/plugins/pkg_config/pkg_config.pc.pre.in"
  "${path_to_build_folder}/${package}_${library_name}${TARGET_SUFFIX}.pre.pc" @ONLY)
  #the final generation is performed after evaluation of generator expression (this is the case for currently build package only, not for dependencies for which expression have already been resolved)
  file(GENERATE OUTPUT ${path_to_build_folder}/${package}_${library_name}${TARGET_SUFFIX}.pc
                INPUT ${path_to_build_folder}/${package}_${library_name}${TARGET_SUFFIX}.pre.pc)
	#finally create the install target for the .pc file corresponding to the library
	set(PATH_TO_INSTALL_FOLDER ${WORKSPACE_DIR}/pid/share/pkgconfig) #put everythng in a global folder so that adding this folder to PKG_CONFIG_PATH will be a quite easy task
  install(
		FILES ${path_to_build_folder}/${package}_${library_name}${TARGET_SUFFIX}.pc
		DESTINATION ${PATH_TO_INSTALL_FOLDER} #put generated .pc files into a unique folder in install tree of the package
		PERMISSIONS OWNER_READ GROUP_READ WORLD_READ OWNER_WRITE)
endmacro(install_Pkg_Config_File)

# setup_Pkg_Config_Variables
# ----------------------------------
#
# set the variables that will be usefull for .pc file generation
#
macro(setup_Pkg_Config_Variables package platform version library_name mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode}) #getting mode info that will be used for generating adequate names

  set(_PKG_CONFIG_WORKSPACE_GLOBAL_PATH_ ${WORKSPACE_DIR})

  #1. Set general meta-information about the library
	#set the prefix
	set(_PKG_CONFIG_PACKAGE_PREFIX_ install/${platform}/${package}/${version})

	#set the version
	set(_PKG_CONFIG_PACKAGE_VERSION_ ${version})

	#set the URL
	if(${package}_PROJECT_PAGE)
		set(_PKG_CONFIG_PACKAGE_URL_ ${${package}_PROJECT_PAGE})
	else()
		set(_PKG_CONFIG_PACKAGE_URL_)
	endif()

	#set the name (just something that is human readable so keep only the name of the library)
	set(_PKG_CONFIG_COMPONENT_NAME_ "${library_name}${TARGET_SUFFIX}")
  set(_PKG_CONFIG_COMPONENT_DESCRIPTION_ "library ${library_name} from package ${package} (in ${mode} mode)")
	#set the description
	if(${package}_${library_name}_DESCRIPTION)
		set(_PKG_CONFIG_COMPONENT_DESCRIPTION_ "${_PKG_CONFIG_COMPONENT_DESCRIPTION_}: ${${package}_${library_name}_DESCRIPTION}")
	elseif(${package}_DESCRIPTION)
		set(_PKG_CONFIG_COMPONENT_DESCRIPTION_ "${_PKG_CONFIG_COMPONENT_DESCRIPTION_}: ${${package}_DESCRIPTION}")
	else()
		set(_PKG_CONFIG_COMPONENT_DESCRIPTION_ "${_PKG_CONFIG_COMPONENT_DESCRIPTION_}")
	endif()

	#2. Set build information about the library
	#2.a management of cflags
	#add the include folder to cflags
	set(_PKG_CONFIG_COMPONENT_CFLAGS_ "-I\${includedir}/${${package}_${library_name}_HEADER_DIR_NAME}")
	#add to cflags the definitions used for that library
	foreach(def IN LISTS ${package}_${library_name}_DEFS${VAR_SUFFIX})
		set(_PKG_CONFIG_COMPONENT_CFLAGS_ "${_PKG_CONFIG_COMPONENT_CFLAGS_} -D${def}")
	endforeach()
	#add to cflags the specific includes used for that library
  if(${package}_${library_name}_INC_DIRS${VAR_SUFFIX})
    resolve_External_Includes_Path(COMPLETE_INCLUDES_PATH "${${package}_${library_name}_INC_DIRS${VAR_SUFFIX}}" ${mode})
  	foreach(inc IN LISTS COMPLETE_INCLUDES_PATH)
      if(IS_ABSOLUTE ${inc}) #this is an absolute path
        file(RELATIVE_PATH relative_inc ${_PKG_CONFIG_WORKSPACE_GLOBAL_PATH_} ${inc})
        if(relative_inc)#relative relation found between the file and the workspace
          set(_PKG_CONFIG_COMPONENT_CFLAGS_ "${_PKG_CONFIG_COMPONENT_CFLAGS_} -I\${global}/${relative_inc}")
        else()
          set(_PKG_CONFIG_COMPONENT_CFLAGS_ "${_PKG_CONFIG_COMPONENT_CFLAGS_} -I${inc}")#using adequate pkg-config keyword
        endif()
      else()#this is already an explicit include option (-I...) so let it "as is"
        set(_PKG_CONFIG_COMPONENT_CFLAGS_ "${_PKG_CONFIG_COMPONENT_CFLAGS_} ${inc}")
      endif()
  	endforeach()
  endif()
	#add to cflags the specific options used for that library
	foreach(opt IN LISTS ${package}_${library_name}_OPTS${VAR_SUFFIX})
		set(_PKG_CONFIG_COMPONENT_CFLAGS_ "${_PKG_CONFIG_COMPONENT_CFLAGS_} -${opt}")
	endforeach()

  #add also the corresponding C and C++ standards in use
  translate_Standard_Into_Option(RES_STD_C RES_STD_CXX "${package}_${library_name}_C_STANDARD${VAR_SUFFIX}" "${package}_${library_name}_CXX_STANDARD${VAR_SUFFIX}")
  if(RES_STD_C)
    set(_PKG_CONFIG_COMPONENT_CFLAGS_ "${_PKG_CONFIG_COMPONENT_CFLAGS_} ${RES_STD_C}")
  endif()
  set(_PKG_CONFIG_COMPONENT_CFLAGS_ "${_PKG_CONFIG_COMPONENT_CFLAGS_} ${RES_STD_CXX}")

  #2.b management of libraries
	#add the binary object to libs flags
  is_Built_Component(BUILT ${package} ${library_name})
  if(BUILT)#if the library generates a binary
    set(_PKG_CONFIG_COMPONENT_LIBS_ "${LIBRARY_KEYWORD}\${libdir}/${${package}_${library_name}_BINARY_NAME${VAR_SUFFIX}}")
  endif()

  #add to libraries the linker options used for that library
  if(${package}_${library_name}_LINKS${VAR_SUFFIX})
    resolve_External_Libs_Path(COMPLETE_LINKS_PATH "${${package}_${library_name}_LINKS${VAR_SUFFIX}}" ${mode})
  	foreach(link IN LISTS COMPLETE_LINKS_PATH)#links are absolute or already defined "the OS way"
      if(IS_ABSOLUTE ${link}) #this is an absolute path
        file(RELATIVE_PATH relative_link ${_PKG_CONFIG_WORKSPACE_GLOBAL_PATH_} ${link})
        if(relative_link)#relative relation found between the file and the workspace
          set(_PKG_CONFIG_COMPONENT_LIBS_ "${_PKG_CONFIG_COMPONENT_LIBS_} ${LIBRARY_KEYWORD}\${global}/${relative_link}")
        else()
          set(_PKG_CONFIG_COMPONENT_LIBS_ "${_PKG_CONFIG_COMPONENT_LIBS_} ${LIBRARY_KEYWORD}${link}")#using adequate pkg-config keyword
        endif()
      else()#this is already an option so let it "as is"
        set(_PKG_CONFIG_COMPONENT_LIBS_ "${_PKG_CONFIG_COMPONENT_LIBS_} ${link}")
      endif()
    endforeach()
  endif()

  #preparing to decide if libs will be generated as public or private
  if( ${package}_${library_name}_TYPE STREQUAL "HEADER" #header and static libraries always export all their dependencies
    OR ${package}_${library_name}_TYPE STREQUAL "STATIC")
    set(FORCE_EXPORT TRUE)
  else()
    set(FORCE_EXPORT FALSE)
  endif()

	#add to private libraries the private linker options used for that library
  if(${package}_${library_name}_PRIVATE_LINKS${VAR_SUFFIX})
    resolve_External_Libs_Path(COMPLETE_LINKS_PATH "${${package}_${library_name}_PRIVATE_LINKS${VAR_SUFFIX}}" ${mode})
  	foreach(link IN LISTS COMPLETE_LINKS_PATH)#links are absolute or already defined "the OS way"
      if(IS_ABSOLUTE ${link}) #this is an absolute path
        file(RELATIVE_PATH relative_link ${_PKG_CONFIG_WORKSPACE_GLOBAL_PATH_} ${link})
        if(relative_link)#relative relation found between the file and the workspace
          if(FORCE_EXPORT)
            set(_PKG_CONFIG_COMPONENT_LIBS_ "${_PKG_CONFIG_COMPONENT_LIBS_} ${LIBRARY_KEYWORD}\${global}/${relative_link}")
          else()
            set(_PKG_CONFIG_COMPONENT_LIBS_PRIVATE_ "${_PKG_CONFIG_COMPONENT_LIBS_PRIVATE_} ${LIBRARY_KEYWORD}\${global}/${relative_link}")
          endif()
        else()
          if(FORCE_EXPORT)
            set(_PKG_CONFIG_COMPONENT_LIBS_ "${_PKG_CONFIG_COMPONENT_LIBS_} ${LIBRARY_KEYWORD}${link}")
          else()
            set(_PKG_CONFIG_COMPONENT_LIBS_PRIVATE_ "${_PKG_CONFIG_COMPONENT_LIBS_PRIVATE_} ${LIBRARY_KEYWORD}${link}")#using adequate pkg-config keyword
          endif()
        endif()
      else()#this is already an option so let it "as is"
        if(FORCE_EXPORT)
          set(_PKG_CONFIG_COMPONENT_LIBS_ "${_PKG_CONFIG_COMPONENT_LIBS_} ${link}")
        else()
          set(_PKG_CONFIG_COMPONENT_LIBS_PRIVATE_ "${_PKG_CONFIG_COMPONENT_LIBS_PRIVATE_} ${link}")
        endif()
      endif()
  	endforeach()
  endif()

	#3 management of dependent packages and libraries
  set(_PKG_CONFIG_COMPONENT_REQUIRES_)
  set(_PKG_CONFIG_COMPONENT_REQUIRES_PRIVATE_)
  #3.a manage internal dependencies
  foreach(a_int_dep IN LISTS ${package}_${library_name}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
    set(DEPENDENT_PKG_MODULE_NAME "${package}_${a_int_dep}${TARGET_SUFFIX} = ${version}")# STRONG version constraint between component of the same package
    if( FORCE_EXPORT OR ${package}_${library_name}_INTERNAL_EXPORT_${a_int_dep}${VAR_SUFFIX}) #otherwise shared libraries export their dependencies if it is explicitly specified (according to pkg-config doc)
        if(_PKG_CONFIG_COMPONENT_REQUIRES_)
          set(_PKG_CONFIG_COMPONENT_REQUIRES_ "${_PKG_CONFIG_COMPONENT_REQUIRES_}, ${DEPENDENT_PKG_MODULE_NAME}")
        else()
          set(_PKG_CONFIG_COMPONENT_REQUIRES_ "${DEPENDENT_PKG_MODULE_NAME}")
        endif()
    else()
      if(_PKG_CONFIG_COMPONENT_REQUIRES_PRIVATE_)
        set(_PKG_CONFIG_COMPONENT_REQUIRES_PRIVATE_ "${_PKG_CONFIG_COMPONENT_REQUIRES_PRIVATE_}, ${DEPENDENT_PKG_MODULE_NAME}")
      else()
        set(_PKG_CONFIG_COMPONENT_REQUIRES_PRIVATE_ "${DEPENDENT_PKG_MODULE_NAME}")
      endif()
    endif()
  endforeach()
  #3.b manage dependencies to other packages
  # dependencies are either generated when source package is built
  # or if not, just after the call to setup_Pkg_Config_Variables
  foreach(dep_package IN LISTS ${package}_${library_name}_DEPENDENCIES${VAR_SUFFIX})
    foreach(dep_component IN LISTS ${package}_${library_name}_DEPENDENCY_${dep_package}_COMPONENTS${VAR_SUFFIX})
      set(DEPENDENT_PKG_MODULE_NAME "${dep_package}_${dep_component}${TARGET_SUFFIX} >= ${${package}_DEPENDENCY_${dep_package}_VERSION${VAR_SUFFIX}}") # version constraint here is less STRONG as any version greater than the one specified should work
      if( FORCE_EXPORT OR ${package}_${library_name}_EXPORT_${dep_package}_${dep_component})#otherwise shared libraries export their dependencies in it is explicitly specified (according to pkg-config doc)
        if(_PKG_CONFIG_COMPONENT_REQUIRES_)
          set(_PKG_CONFIG_COMPONENT_REQUIRES_ "${_PKG_CONFIG_COMPONENT_REQUIRES_}, ${DEPENDENT_PKG_MODULE_NAME}")
        else()
          set(_PKG_CONFIG_COMPONENT_REQUIRES_ "${DEPENDENT_PKG_MODULE_NAME}")
        endif()
      else()
        if(_PKG_CONFIG_COMPONENT_REQUIRES_PRIVATE_)
          set(_PKG_CONFIG_COMPONENT_REQUIRES_PRIVATE_ "${_PKG_CONFIG_COMPONENT_REQUIRES_PRIVATE_}, ${DEPENDENT_PKG_MODULE_NAME}")
        else()
          set(_PKG_CONFIG_COMPONENT_REQUIRES_PRIVATE_ "${DEPENDENT_PKG_MODULE_NAME}")
        endif()
      endif()
    endforeach()
  endforeach()
endmacro(setup_Pkg_Config_Variables)
