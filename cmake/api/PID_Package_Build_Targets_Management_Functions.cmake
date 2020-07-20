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
if(PID_PACKAGE_BUILD_TARGETS_MANAGEMENT_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_PACKAGE_BUILD_TARGETS_MANAGEMENT_FUNCTIONS_INCLUDED TRUE)
##########################################################################################

############################################################################
####################### build command creation auxiliary function ##########
############################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Global_Build_Command| replace:: ``create_Global_Build_Command``
#  .. _create_Global_Build_Command:
#
#  create_Global_Build_Command
#  -------------------------------------
#
#   .. command:: create_Global_Build_Command(privileges gen_install gen_build gen_package gen_doc gen_test_or_cover)
#
#     Create the global build target for current native package.
#
#     :privileges: the OS command to get privileged (root) permissions. Useful to run tests with root privileges if required.
#     :gen_install: if TRUE the build command launch installation.
#     :gen_build: if TRUE the build command launch compilation.
#     :gen_doc: if TRUE the build command generates API documentation.
#     :gen_test_or_cover: if value is "coverage" the build command generates coverage report after launching tests, if value is "test" the build command launch tests.
#
function(create_Global_Build_Command privileges gen_install gen_build gen_package gen_doc gen_test_or_cover)
if(gen_install)
	if(gen_build) #build package
		if(gen_package) #generate and install a binary package
			if(gen_doc) # documentation generated
				#this is the complete scenario
				if(NOT gen_test_or_cover)
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} doc
						COMMAND ${CMAKE_MAKE_PROGRAM} install
						COMMAND ${CMAKE_MAKE_PROGRAM} package
						COMMAND ${CMAKE_MAKE_PROGRAM} package_install
					)
				elseif(gen_test_or_cover STREQUAL "coverage")#coverage test
						add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} coverage ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} doc
						COMMAND ${CMAKE_MAKE_PROGRAM} install
						COMMAND ${CMAKE_MAKE_PROGRAM} package
						COMMAND ${CMAKE_MAKE_PROGRAM} package_install
					)
				else()# basic test
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} doc
						COMMAND ${CMAKE_MAKE_PROGRAM} install
						COMMAND ${CMAKE_MAKE_PROGRAM} package
						COMMAND ${CMAKE_MAKE_PROGRAM} package_install
					)
				endif()
			else() # no documentation generated
				#this is the complete scenario without documentation
				if(NOT gen_test_or_cover)
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} install
						COMMAND ${CMAKE_MAKE_PROGRAM} package
						COMMAND ${CMAKE_MAKE_PROGRAM} package_install
					)
				elseif(gen_test_or_cover STREQUAL "coverage")#coverage test
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} coverage ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} install
						COMMAND ${CMAKE_MAKE_PROGRAM} package
						COMMAND ${CMAKE_MAKE_PROGRAM} package_install
					)
				else()# basic test
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} install
						COMMAND ${CMAKE_MAKE_PROGRAM} package
						COMMAND ${CMAKE_MAKE_PROGRAM} package_install
					)
				endif()
			endif()
		else()#no binary package
			if(gen_doc) # documentation generated
				if(NOT gen_test_or_cover)#no test
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} doc
						COMMAND ${CMAKE_MAKE_PROGRAM} install
					)
				elseif(gen_test_or_cover STREQUAL "coverage")#coverage test
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} coverage ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} doc
						COMMAND ${CMAKE_MAKE_PROGRAM} install
					)
				else()# basic test
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} doc
						COMMAND ${CMAKE_MAKE_PROGRAM} install
					)
				endif()
			else() # no documentation generated
				if(NOT gen_test_or_cover)
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} install
					)
				elseif(gen_test_or_cover STREQUAL "coverage")#coverage test
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} coverage ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} install
					)
				else()# basic test
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} ${PARALLEL_JOBS_FLAG}
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} install
					)
				endif()
			endif()
		endif()
	else()#package not built !!
		if(gen_package)#package binary archive is built
			if(gen_doc)#documentation is built
				if(NOT gen_test_or_cover) # no test
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} doc
						COMMAND ${CMAKE_MAKE_PROGRAM} install
						COMMAND ${CMAKE_MAKE_PROGRAM} package
						COMMAND ${CMAKE_MAKE_PROGRAM} package_install
					)
				elseif(gen_test_or_cover STREQUAL "coverage")#coverage test
					add_custom_target(build
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} coverage ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} doc
						COMMAND ${CMAKE_MAKE_PROGRAM} install
						COMMAND ${CMAKE_MAKE_PROGRAM} package
						COMMAND ${CMAKE_MAKE_PROGRAM} package_install
					)
				else()# basic test
					add_custom_target(build
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} doc
						COMMAND ${CMAKE_MAKE_PROGRAM} install
						COMMAND ${CMAKE_MAKE_PROGRAM} package
						COMMAND ${CMAKE_MAKE_PROGRAM} package_install
					)
				endif()
			else()#no documentation generated
				if(NOT gen_test_or_cover)
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} install
						COMMAND ${CMAKE_MAKE_PROGRAM} package
						COMMAND ${CMAKE_MAKE_PROGRAM} package_install
					)
				elseif(gen_test_or_cover STREQUAL "coverage")#coverage test
					add_custom_target(build
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} coverage ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} install
						COMMAND ${CMAKE_MAKE_PROGRAM} package
						COMMAND ${CMAKE_MAKE_PROGRAM} package_install
					)
				else()# basic test
					add_custom_target(build
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} install
						COMMAND ${CMAKE_MAKE_PROGRAM} package
						COMMAND ${CMAKE_MAKE_PROGRAM} package_install
					)
				endif()
			endif()
		else()#no package binary generated
			if(gen_doc) #but with doc
				if(NOT gen_test_or_cover) #without test
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} doc
						COMMAND ${CMAKE_MAKE_PROGRAM} install
					)
				elseif(gen_test_or_cover STREQUAL "coverage")#coverage test
					add_custom_target(build
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} coverage ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} doc
						COMMAND ${CMAKE_MAKE_PROGRAM} install
					)
				else()# basic test
					add_custom_target(build
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} doc
						COMMAND ${CMAKE_MAKE_PROGRAM} install
					)
				endif()
			else()#no doc
				if(NOT gen_test_or_cover) #without test
					add_custom_target(build
						COMMAND ${CMAKE_MAKE_PROGRAM} install
					)
				elseif(gen_test_or_cover STREQUAL "coverage")#coverage test
					add_custom_target(build
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} coverage ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} install
					)
				else()# basic test
					add_custom_target(build
						COMMAND ${privileges} ${CMAKE_MAKE_PROGRAM} test ${PARALLEL_JOBS_FLAG}
						COMMAND ${CMAKE_MAKE_PROGRAM} install
					)
				endif()
			endif()
		endif()
	endif()
else()
	add_custom_target(build
		COMMAND ${CMAKE_COMMAND} -E echo "[PID] Nothing to be done. Build process aborted."
	)
endif()
endfunction(create_Global_Build_Command)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Component_Language_Support| replace:: ``resolve_Component_Language_Support``
#  .. _resolve_Component_Language_Support:
#
#  resolve_Component_Language_Support
#  ----------------------------------
#
#   .. command:: resolve_Component_Language_Support(component_target)
#
#     Set adequate language standard properties or compilation flags for a component, depending on CMake version.
#
#     :component: name of the component.
#
function(resolve_Component_Language_Support component)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${CMAKE_BUILD_TYPE})

  get_target_property(STD_CXX ${PROJECT_NAME}_${component}${TARGET_SUFFIX} CXX_STANDARD) #get component target
  get_Required_CMake_Version_For_Standard(RES_MIN_CMAKE_VERSION ${STD_CXX})

  if(CMAKE_VERSION VERSION_LESS RES_MIN_CMAKE_VERSION)#if cmake version is less than the version required to managed the standard in use
    target_compile_options(${PROJECT_NAME}_${component}${TARGET_SUFFIX} PUBLIC "-std=c++${STD_CXX}")
    return()
  endif()

endfunction(resolve_Component_Language_Support)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Build_Options_For_Targets| replace:: ``resolve_Build_Options_For_Targets``
#  .. _resolve_Build_Options_For_Targets:
#
#  resolve_Build_Options_For_Targets
#  ---------------------------------
#
#   .. command:: resolve_Build_Options_For_Targets()
#
#     Set compile option for all components that are build given some info not directly managed by CMake.
#
function(resolve_Build_Options_For_Targets)
  foreach(component IN LISTS ${PROJECT_NAME}_COMPONENTS)
  	is_Built_Component(IS_BUILT_COMP ${PROJECT_NAME} ${component})#no need to resolve alias since list of components contains only base name in current package
  	if(IS_BUILT_COMP)
  		resolve_Component_Language_Support(${component} ${CMAKE_BUILD_TYPE})
  	endif()
  endforeach()
endfunction(resolve_Build_Options_For_Targets)

############################################################################
############### API functions for internal targets management ##############
############################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Python_Scripts| replace:: ``manage_Python_Scripts``
#  .. _manage_Python_Scripts:
#
#  manage_Python_Scripts
#  ---------------------
#
#   .. command:: manage_Python_Scripts(c_name dirname)
#
#     Create a target for intalling python code.
#
#     :c_name: the name of component that provide python code (MODULE or SCRIPT).
#     :dirname: the nameof the folder that contains python code.
#
function(manage_Python_Scripts c_name dirname)
	if(${PROJECT_NAME}_${c_name}_TYPE STREQUAL "MODULE")
		set_target_properties(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES PREFIX "")#specific requirement for python, not lib prefix at beginning of the module
		# simply copy directory containing script at install time into a specific folder, but select only python script
		# Important notice: the trailing / at end of DIRECTORY argument is to allow the renaming of the directory into c_name
		install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${dirname}/
						DESTINATION ${${PROJECT_NAME}_INSTALL_SCRIPT_PATH}/${c_name}
						FILES_MATCHING PATTERN "*.py"
						PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)
	else()
		# simply copy directory containing script at install time into a specific folder, but select only python script
		# Important notice: the trailing / at end of DIRECTORY argument is to allow the renaming of the directory into c_name
		install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/script/${dirname}/
						DESTINATION ${${PROJECT_NAME}_INSTALL_SCRIPT_PATH}/${c_name}
						FILES_MATCHING PATTERN "*.py"
						PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)
	endif()

	install(#install symlinks that target the python module either in install directory and (undirectly) in the python install dir
			CODE
			"execute_process(
					COMMAND ${CMAKE_COMMAND}
					-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
					-DCMAKE_COMMAND=${CMAKE_COMMAND}
					-DWORKSPACE_DIR=${WORKSPACE_DIR}
					-DTARGET_PACKAGE=${PROJECT_NAME}
					-DTARGET_VERSION=${${PROJECT_NAME}_VERSION}
					-DTARGET_MODULE=${c_name}
					-DTARGET_COMPONENT_TYPE=${${PROJECT_NAME}_${c_name}_TYPE}
					-P ${WORKSPACE_DIR}/cmake/commands/Install_PID_Python_Script.cmake
			)
			"
	)
endfunction(manage_Python_Scripts)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Module_Lib_Target| replace:: ``create_Module_Lib_Target``
#  .. _create_Module_Lib_Target:
#
#  create_Module_Lib_Target
#  ------------------------
#
#   .. command:: create_Module_Lib_Target(c_name c_standard cxx_standard sources internal_inc_dirs internal_defs internal_compiler_options internal_links)
#
#     Create a target for a module library (shared object without a specific header and supposed to be used only at runtime to implement plugin like mechanism). Modules export nothing as they do not have public headers.
#
#     :c_name: the name of the library.
#     :c_standard: the C language standard used for that library.
#     :cxx_standard: the C++ language standard used for that library.
#     :sources: the source files of the library.
#     :internal_inc_dirs: list of additional include path to use when building the library.
#     :internal_defs: list of private definitions to use when building the library.
#     :internal_compiler_options: list of private compiler options to use when building the library.
#     :internal_links: list of private linker options to use when building the library.
#
function(create_Module_Lib_Target c_name c_standard cxx_standard sources internal_inc_dirs internal_defs internal_compiler_options internal_links)
	add_library(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} MODULE ${sources})
	install(TARGETS ${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX}
		LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}
	)
	#setting the default rpath for the target (rpath target a specific folder of the binary package for the installed version of the component)
	if(APPLE)
		set_target_properties(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "@loader_path/../.rpath/${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX};${CMAKE_INSTALL_RPATH}") #the library targets a specific folder that contains symbolic links to used shared libraries
	elseif(UNIX)
		set_target_properties(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "\$ORIGIN/../.rpath/${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX};${CMAKE_INSTALL_RPATH}") #the library targets a specific folder that contains symbolic links to used shared libraries
	endif()
	manage_Additional_Component_Internal_Flags(${c_name} "${c_standard}" "${cxx_standard}" "${INSTALL_NAME_SUFFIX}" "${internal_inc_dirs}" "" "${internal_defs}" "${internal_compiler_options}" "${internal_links}")
endfunction(create_Module_Lib_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Shared_Lib_Target| replace:: ``create_Shared_Lib_Target``
#  .. _create_Shared_Lib_Target:
#
#  create_Shared_Lib_Target
#  ------------------------
#
#   .. command:: create_Shared_Lib_Target(c_name c_standard cxx_standard sources exported_inc_dirs internal_inc_dirs exported_defs internal_defs exported_compiler_options internal_compiler_options exported_links internal_links)
#
#     Create a target for a shared library.
#
#     :c_name: the name of the library.
#     :c_standard: the C language standard used for that library.
#     :cxx_standard: the C++ language standard used for that library.
#     :sources: the source files of the library.
#     :exported_inc_dirs: list of include path exported by the library.
#     :internal_inc_dirs: list of additional include path to use when building the library.
#     :exported_defs: list of definitions exported by the library.
#     :internal_defs: list of private definitions to use when building the library.
#     :exported_compiler_options: list of compiler options exported by the library.
#     :internal_compiler_options: list of private compiler options to use when building the library.
#     :exported_links: list of linker options exported by the library.
#     :internal_links: list of private linker options to use when building the library.
#
function(create_Shared_Lib_Target c_name c_standard cxx_standard sources exported_inc_dirs internal_inc_dirs exported_defs internal_defs exported_compiler_options internal_compiler_options exported_links internal_links)
	set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
	add_library(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} SHARED ${sources})

  if(WIN32)
  	install(TARGETS ${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}) # for .dll
  	install(TARGETS ${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH}) # for .lib
  else()
    install(TARGETS ${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} LIBRARY DESTINATION ${${PROJECT_NAME}_INSTALL_LIB_PATH})
  endif()
	#setting the default rpath for the target (rpath target a specific folder of the binary package for the installed version of the component)
	if(APPLE)
		set_target_properties(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "@loader_path/../.rpath/${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX};${CMAKE_INSTALL_RPATH}") #the library targets a specific folder that contains symbolic links to used shared libraries
	elseif(UNIX)
		set_target_properties(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "\$ORIGIN/../.rpath/${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX};${CMAKE_INSTALL_RPATH}") #the library targets a specific folder that contains symbolic links to used shared libraries
	endif()
	set(INC_DIRS ${internal_inc_dirs} ${exported_inc_dirs})
	set(DEFS ${internal_defs} ${exported_defs})
	set(LINKS ${exported_links} ${internal_links})
	set(COMP_OPTS ${exported_compiler_options} ${internal_compiler_options})
	manage_Additional_Component_Internal_Flags(${c_name} "${c_standard}" "${cxx_standard}" "${INSTALL_NAME_SUFFIX}" "${INC_DIRS}" "" "${DEFS}" "${COMP_OPTS}" "${LINKS}")
	manage_Additional_Component_Exported_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${exported_inc_dirs}" "" "${exported_defs}" "${exported_compiler_options}" "${exported_links}")
endfunction(create_Shared_Lib_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Static_Lib_Target| replace:: ``create_Static_Lib_Target``
#  .. _create_Static_Lib_Target:
#
#  create_Static_Lib_Target
#  ------------------------
#
#   .. command:: create_Static_Lib_Target(c_name c_standard cxx_standard sources exported_inc_dirs internal_inc_dirs exported_defs internal_defs exported_compiler_options internal_compiler_options exported_links)
#
#     Create a target for a static library (they export all their links by construction)
#
#     :c_name: the name of the library.
#     :c_standard: the C language standard used for that library.
#     :cxx_standard: the C++ language standard used for that library.
#     :sources: the source files of the library.
#     :exported_inc_dirs: list of include path exported by the library.
#     :internal_inc_dirs: list of additional include path to use when building the library.
#     :exported_defs: list of definitions exported by the library.
#     :internal_defs: list of private definitions to use when building the library.
#     :exported_compiler_options: list of compiler options exported by the library.
#     :internal_compiler_options: list of private compiler options to use when building the library.
#     :exported_links: list of linker options exported by the library.
#
function(create_Static_Lib_Target c_name c_standard cxx_standard sources exported_inc_dirs internal_inc_dirs exported_defs internal_defs exported_compiler_options internal_compiler_options exported_links)
	add_library(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} STATIC ${sources})
	install(TARGETS ${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX}
		ARCHIVE DESTINATION ${${PROJECT_NAME}_INSTALL_AR_PATH}
	)
	set(INC_DIRS ${internal_inc_dirs} ${exported_inc_dirs})
	set(DEFS ${internal_defs} ${exported_defs})
	set(COMP_OPTS ${exported_compiler_options} ${internal_compiler_options})
	manage_Additional_Component_Internal_Flags(${c_name} "${c_standard}" "${cxx_standard}" "${INSTALL_NAME_SUFFIX}" "${INC_DIRS}" "" "${DEFS}" "${COMP_OPTS}" "")#no linking with static libraries so do not manage internal_flags
	manage_Additional_Component_Exported_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${exported_inc_dirs}" "" "${exported_defs}" "${exported_compiler_options}" "${exported_links}")
endfunction(create_Static_Lib_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Header_Lib_Target| replace:: ``create_Header_Lib_Target``
#  .. _create_Header_Lib_Target:
#
#  create_Header_Lib_Target
#  ------------------------
#
#   .. command:: create_Header_Lib_Target(c_name c_standard cxx_standard exported_inc_dirs exported_defs exported_compiler_options exported_links)
#
#     Create a target for a header only library (they export everything by construction and have no sources).
#
#     :c_name: the name of the library.
#     :c_standard: the C language standard used for that library.
#     :cxx_standard: the C++ language standard used for that library.
#     :exported_inc_dirs: list of include path exported by the library.
#     :exported_defs: list of definitions exported by the library.
#     :exported_compiler_options: list of compiler options exported by the library.
#     :exported_links: list of links exported by the library.
#
function(create_Header_Lib_Target c_name c_standard cxx_standard exported_inc_dirs exported_defs exported_compiler_options exported_links)
	add_library(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} INTERFACE)
	manage_Additional_Component_Exported_Flags(${c_name} "${INSTALL_NAME_SUFFIX}" "${exported_inc_dirs}" "" "${exported_defs}" "${exported_compiler_options}" "${exported_links}")
endfunction(create_Header_Lib_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Alias_Lib_Target| replace:: ``create_Alias_Lib_Target``
#  .. _create_Alias_Lib_Target:
#
#  create_Alias_Lib_Target
#  ------------------------
#
#   .. command:: create_Alias_Lib_Target(package real_name aliases target_suffix)
#
#     Create a set of alias targets for a given library.
#
#     :package: the name of the package containing library.
#     :real_name: the name of the library.
#     :aliases: the list of alias names.
#     :target_suffix: the suffix to use for target names, depending on build mode.
#
function(create_Alias_Lib_Target package real_name aliases target_suffix)
  foreach(alias IN LISTS aliases)
    add_library(${package}_${alias}${target_suffix} ALIAS ${package}_${real_name}${target_suffix})
  endforeach()
endfunction(create_Alias_Lib_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Alias_Exe_Target| replace:: ``create_Alias_Exe_Target``
#  .. _create_Alias_Exe_Target:
#
#  create_Alias_Exe_Target
#  ------------------------
#
#   .. command:: create_Alias_Exe_Target(package real_name aliases target_suffix)
#
#     Create a set of alias targets for a given executable.
#
#     :package: the name of the package containing library.
#     :real_name: the name of the library.
#     :aliases: the list of alias names.
#     :target_suffix: the suffix to use for target names, depending on build mode.
#
function(create_Alias_Exe_Target package real_name aliases target_suffix)
  foreach(alias IN LISTS aliases)
    add_executable(${package}_${alias}${target_suffix} ALIAS ${package}_${real_name}${target_suffix})
  endforeach()
endfunction(create_Alias_Exe_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Executable_Target| replace:: ``create_Executable_Target``
#  .. _create_Executable_Target:
#
#  create_Executable_Target
#  ------------------------
#
#   .. command:: create_Executable_Target(c_name c_standard cxx_standard sources internal_inc_dirs internal_defs internal_compiler_options internal_links)
#
#     Create a target for a executable (applications and examples). Applications export nothing as they do not have public headers.
#
#     :c_name: the name of executable.
#     :c_standard: the C language standard used for that executable.
#     :cxx_standard: the C++ language standard used for that executable.
#     :sources: the source files of the executable.
#     :internal_inc_dirs: list of additional include path to use when building the executable.
#     :internal_defs: list of private definitions to use when building the executable.
#     :internal_compiler_options: list of private compiler options to use when building the executable.
#     :internal_links: list of private links to use when building the executable.
#
function(create_Executable_Target c_name c_standard cxx_standard sources internal_inc_dirs internal_defs internal_compiler_options internal_links)
	add_executable(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} ${sources})
	manage_Additional_Component_Internal_Flags(${c_name} "${c_standard}" "${cxx_standard}" "${INSTALL_NAME_SUFFIX}" "${internal_inc_dirs}" "" "${internal_defs}" "${internal_compiler_options}" "${internal_links}")
	# adding the application to the list of installed components when make install is called (not for test applications)
	install(TARGETS ${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX}
		RUNTIME DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH}
	)
	#setting the default rpath for the target
	if(APPLE)
		set_target_properties(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "@loader_path/../.rpath/${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX};${CMAKE_INSTALL_RPATH}") #the application targets a specific folder that contains symbolic links to used shared libraries
	elseif(UNIX)
		set_target_properties(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} PROPERTIES INSTALL_RPATH "\$ORIGIN/../.rpath/${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX};${CMAKE_INSTALL_RPATH}") #the application targets a specific folder that contains symbolic links to used shared libraries
  elseif(WIN32)#need to install a specific run.bat script file
	install(FILES ${WORKSPACE_DIR}/cmake/patterns/packages/run.bat DESTINATION ${${PROJECT_NAME}_INSTALL_BIN_PATH})
	file(COPY ${WORKSPACE_DIR}/cmake/patterns/packages/run.bat DESTINATION ${CMAKE_BINARY_DIR}/apps)
	endif()
endfunction(create_Executable_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_TestUnit_Target| replace:: ``create_TestUnit_Target``
#  .. _create_TestUnit_Target:
#
#  create_TestUnit_Target
#  ----------------------
#
#   .. command:: create_TestUnit_Target(c_name c_standard cxx_standard sources internal_inc_dirs internal_defs internal_compiler_options internal_links)
#
#     Create a target for an executable test unit. Test units export nothing as they do not have public headers. Difference with other applications is that test units are not installed (not useful for end users only for developers).
#
#     :c_name: the name of executable.
#     :c_standard: the C language standard used for that executable.
#     :cxx_standard: the C++ language standard used for that executable.
#     :sources: the source files of the executable.
#     :internal_inc_dirs: list of additional include path to use when building the executable.
#     :internal_defs: list of private definitions to use when building the executable.
#     :internal_compiler_options: list of private compiler options to use when building the executable.
#     :internal_links: list of private links to use when building the executable.
#
function(create_TestUnit_Target c_name c_standard cxx_standard sources internal_inc_dirs internal_defs internal_compiler_options internal_links)
	add_executable(${PROJECT_NAME}_${c_name}${INSTALL_NAME_SUFFIX} ${sources})
	manage_Additional_Component_Internal_Flags(${c_name} "${c_standard}" "${cxx_standard}" "${INSTALL_NAME_SUFFIX}" "${internal_inc_dirs}" "" "${internal_defs}" "${internal_compiler_options}" "${internal_links}")
	file(COPY ${WORKSPACE_DIR}/cmake/patterns/packages/run.bat DESTINATION ${CMAKE_BINARY_DIR}/test)
endfunction(create_TestUnit_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Additional_Component_Exported_Flags| replace:: ``manage_Additional_Component_Exported_Flags``
#  .. _manage_Additional_Component_Exported_Flags:
#
#  manage_Additional_Component_Exported_Flags
#  ------------------------------------------
#
#   .. command:: manage_Additional_Component_Exported_Flags(component_name mode_suffix inc_dirs defs options links)
#
#     Configure a component target with exported flags (cflags and ldflags).
#
#     :component_name: the name of the component.
#     :mode_suffix: the build mode of the target.
#     :inc_dirs: the list of includes to export.
#     :lib_dirs: the list of library search folders.
#     :defs: the list of preprocessor definitions to export.
#     :options: the list of compiler options to export.
#     :links: list of links to export.
#
function(manage_Additional_Component_Exported_Flags component_name mode_suffix inc_dirs lib_dirs defs options links)
# managing compile time flags (-I<path>)
foreach(dir IN LISTS inc_dirs)
	target_include_directories(${PROJECT_NAME}_${component_name}${mode_suffix} INTERFACE "${dir}")
endforeach()

# managing compile time flags (-D<preprocessor_defs>)
foreach(def IN LISTS defs)
	target_compile_definitions(${PROJECT_NAME}_${component_name}${mode_suffix} INTERFACE "${def}")
endforeach()

foreach(opt IN LISTS options)
	target_compile_options(${PROJECT_NAME}_${component_name}${mode_suffix} INTERFACE "${opt}")#keep the option unchanged
endforeach()

# managing link time flags
foreach(dir IN LISTS lib_dirs)#always putting library dirs flags before other links  (enfore resolution of library path before resolving library links)
  target_link_libraries(${PROJECT_NAME}_${component_name}${mode_suffix} INTERFACE "-L${dir}")#generate -L linker flags for library dirs
endforeach()

foreach(link IN LISTS links)
	target_link_libraries(${PROJECT_NAME}_${component_name}${mode_suffix} INTERFACE ${link})
endforeach()

endfunction(manage_Additional_Component_Exported_Flags)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Additional_Component_Internal_Flags| replace:: ``manage_Additional_Component_Internal_Flags``
#  .. _manage_Additional_Component_Internal_Flags:
#
#  manage_Additional_Component_Internal_Flags
#  ------------------------------------------
#
#   .. command:: manage_Additional_Component_Internal_Flags(component c_standard cxx_standard mode_suffix inc_dirs lib_dirs defs options links)
#
#     Configure a component target with internal flags (cflags and ldflags).
#
#     :component: the name of the component.
#
#     :c_standard: the C language standard to use.
#     :cxx_standard: the C++ language standard to use.
#     :mode_suffix: the build mode of the target.
#     :inc_dirs: the list of includes to use.
#     :lib_dirs: the list of library search folders.
#     :defs: the list of preprocessor definitions to use.
#     :options: the list of compiler options to use.
#     :links: list of links to use.
#
function(manage_Additional_Component_Internal_Flags component c_standard cxx_standard mode_suffix inc_dirs lib_dirs defs options links)
# managing compile time flags
foreach(dir IN LISTS inc_dirs)
	target_include_directories(${PROJECT_NAME}_${component}${mode_suffix} PRIVATE "${dir}")
endforeach()

# managing compile time flags
foreach(def IN LISTS defs)
	target_compile_definitions(${PROJECT_NAME}_${component}${mode_suffix} PRIVATE "${def}")
endforeach()

foreach(opt IN LISTS options)
	target_compile_options(${PROJECT_NAME}_${component}${mode_suffix} PRIVATE "${opt}")
endforeach()

# managing link time flags
foreach(dir IN LISTS lib_dirs) #put library dirs flags BEFORE library flags in link libraries !!
  target_link_libraries(${PROJECT_NAME}_${component}${mode_suffix} PRIVATE "-L${dir}")#generate -L linker flags for library dirs
endforeach()

foreach(link IN LISTS links)
	target_link_libraries(${PROJECT_NAME}_${component}${mode_suffix} PRIVATE ${link})
endforeach()

if(c_standard)#the std C is let optional as using a standard may cause error with posix includes
  set_target_properties(${PROJECT_NAME}_${component}${mode_suffix} PROPERTIES
  			C_STANDARD ${c_standard}
  			C_STANDARD_REQUIRED YES
  			C_EXTENSIONS NO
  	)#setting the standard in use locally
endif()

if(cxx_standard)
  set_target_properties(${PROJECT_NAME}_${component}${mode_suffix} PROPERTIES
  		CXX_STANDARD ${cxx_standard}
  		CXX_STANDARD_REQUIRED YES
  		CXX_EXTENSIONS NO
  )#setting the standard in use locally
endif()
endfunction(manage_Additional_Component_Internal_Flags)

#.rst:
#
# .. ifmode:: internal
#
#  .. |fill_Component_Target_With_External_Component_Dependency| replace:: ``fill_Component_Target_With_External_Component_Dependency``
#  .. _fill_Component_Target_With_External_Component_Dependency:
#
#  fill_Component_Target_With_External_Component_Dependency
#  --------------------------------------------------------
#
#   .. command:: fill_Component_Target_With_External_Component_Dependency(component export comp_defs comp_exp_defs ext_defs)
#
#     Configure a component target to link with a component defined in an external package.
#
#     :component: the name of the component to configure.
#     :dep_package: the name of the external package that contains the dependency.
#     :dep_component: the name of the external component that IS the dependency.
#     :mode: the build mode for the targets.
#     :export: TRUE if component exports the content.
#     :comp_defs: preprocessor definitions defined in implementation of component.
#     :comp_exp_defs: preprocessor definitions defined in interface (public headers) of component.
#     :dep_defs: preprocessor definitions used in interface of dep_component but defined by implementation of component.
#
function(fill_Component_Target_With_External_Component_Dependency component dep_package dep_component mode export comp_defs comp_exp_defs ext_defs)
  create_External_Component_Dependency_Target(${dep_package} ${dep_component} ${mode})
  #no need to check for target created, always bind !
  bind_Target(${component} TRUE ${dep_package} ${dep_component} ${mode} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
endfunction(fill_Component_Target_With_External_Component_Dependency)

#.rst:
#
# .. ifmode:: internal
#
#  .. |fill_Component_Target_With_External_Dependency| replace:: ``fill_Component_Target_With_External_Dependency``
#  .. _fill_Component_Target_With_External_Dependency:
#
#  fill_Component_Target_With_External_Dependency
#  ----------------------------------------------
#
#   .. command:: fill_Component_Target_With_External_Dependency(component export comp_defs comp_exp_defs ext_defs ext_inc_dirs ext_lib_dirs ext_links_shared ext_links_static c_standard cxx_standard)
#
#     Configure a component target to link with external content (from external packages or operating system).
#
#     :component: the name of the component to configure.
#     :export: TRUE if component exports the content.
#     :comp_defs: preprocessor definitions defined in implementation of component.
#     :comp_exp_defs: preprocessor definitions defined in interface (public headers) of component.
#     :dep_defs: preprocessor definitions used in interface of dep_component but defined by implementation of component.
#     :ext_inc_dirs: list of include path, either absolute or relative to external packages.
#     :ext_opts: list of compiler options.
#     :ext_lib_dirs: list of path, either absolute or relative to external packages, to folders that contain libraries to use at build time.
#     :ext_links_shared: list of path to shared libraries, either absolute or relative to external packages, or linker options.
#     :ext_links_static: list of path to static libraries, either absolute or relative to external packages, or linker options.
#     :c_standard: C language standard to use when using these dependencies.
#     :c_max_standard: max C language standard allowed when using these dependencies.
#     :cxx_standard: C++ language standard to use when using these dependencies.
#     :cxx_max_standard: max C++ language standard allowed when using these dependencies.
#
function(fill_Component_Target_With_External_Dependency component export
                                                        comp_defs comp_exp_defs ext_defs
                                                        ext_inc_dirs ext_opts ext_lib_dirs
                                                        ext_links_shared ext_links_static
                                                        c_standard c_max_standard cxx_standard cxx_max_standard)
if(ext_links_shared)
  evaluate_Variables_In_List(EVAL_SH_LINKS ext_links_shared) #first evaluate element of the list => if they are variables they are evaluated
	resolve_External_Libs_Path(COMPLETE_SH_LINKS_PATH "${EVAL_SH_LINKS}" ${CMAKE_BUILD_TYPE})
  if(COMPLETE_SH_LINKS_PATH)
		foreach(link IN LISTS COMPLETE_SH_LINKS_PATH)
			create_External_Dependency_Target(EXT_SH_TARGET_NAME ${link} "" ${CMAKE_BUILD_TYPE})#do not force SHARED type as some options may be linker options coming from configurations
			if(EXT_SH_TARGET_NAME)
				list(APPEND EXT_SH_LINKS_TARGETS ${EXT_SH_TARGET_NAME})
			else()
				list(APPEND EXT_SH_LINKS_OPTIONS ${link})
			endif()
		endforeach()
	endif()
	list(APPEND EXT_SH_LINKS ${EXT_SH_LINKS_TARGETS} ${EXT_SH_LINKS_OPTIONS})
  list(APPEND EXT_LINKS ${EXT_SH_LINKS})
endif()
if(ext_links_static)
  evaluate_Variables_In_List(EVAL_ST_LINKS ext_links_static) #first evaluate element of the list => if they are variables they are evaluated
	resolve_External_Libs_Path(COMPLETE_ST_LINKS_PATH "${EVAL_ST_LINKS}" ${CMAKE_BUILD_TYPE})
  if(COMPLETE_ST_LINKS_PATH)
		foreach(link IN LISTS COMPLETE_ST_LINKS_PATH)
			create_External_Dependency_Target(EXT_ST_TARGET_NAME ${link} STATIC ${CMAKE_BUILD_TYPE})
			if(EXT_ST_TARGET_NAME)
				list(APPEND EXT_ST_LINKS_TARGETS ${EXT_ST_TARGET_NAME})
			else()
				list(APPEND EXT_ST_LINKS_OPTIONS ${link})
			endif()
		endforeach()
	endif()
	list(APPEND EXT_ST_LINKS ${EXT_ST_LINKS_TARGETS} ${EXT_ST_LINKS_OPTIONS})
  list(APPEND EXT_LINKS ${EXT_ST_LINKS})
endif()

evaluate_Variables_In_List(EVAL_INCS ext_inc_dirs)#first evaluate element of the list => if they are variables they are evaluated
resolve_External_Includes_Path(COMPLETE_INCLUDES_PATH "${EVAL_INCS}" ${CMAKE_BUILD_TYPE})
evaluate_Variables_In_List(EVAL_OPTS ext_opts)#first evaluate element of the list => if they are variables they are evaluated
evaluate_Variables_In_List(EVAL_LDIRS ext_lib_dirs)
resolve_External_Libs_Path(COMPLETE_LIB_DIRS_PATH "${EVAL_LDIRS}" ${CMAKE_BUILD_TYPE})
evaluate_Variables_In_List(EVAL_DEFS ext_defs)#first evaluate element of the list => if they are variables they are evaluated
evaluate_Variables_In_List(EVAL_CSTD c_standard)
evaluate_Variables_In_List(EVAL_MAX_CSTD c_max_standard)
evaluate_Variables_In_List(EVAL_CXXSTD cxx_standard)
evaluate_Variables_In_List(EVAL_MAX_CXXSTD cxx_max_standard)

if(EVAL_CSTD OR EVAL_MAX_CSTD)
  get_target_property(CURR_C_STD ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} C_STANDARD)
  #adjust languages standards version, also check adjustment considering max standard, if any
  check_Imported_C_Standard(ERROR MESSAGE NEW_C_STD NEW_C_MAX_STD
    "${CURR_C_STD}" "${EVAL_CSTD}"
    "${${PROJECT_NAME}_${component}_C_MAX_STANDARD${USE_MODE_SUFFIX}}" "${EVAL_MAX_CSTD}")
  if(ERROR)
    if(ERROR STREQUAL "CRITICAL")
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR: in ${PROJECT_NAME}, when configuring target for component ${component} : ${MESSAGE}")
    else()#warning
      message("[PID] WARNING: in ${PROJECT_NAME}, when configuring target for component ${component} : ${MESSAGE}")
    endif()
  endif()
  if(NEW_C_STD)
    set(EVAL_CSTD ${NEW_C_STD})
  endif()
  if(NEW_C_MAX_STD)
    set(${PROJECT_NAME}_${component}_C_MAX_STANDARD${USE_MODE_SUFFIX} ${NEW_C_MAX_STD} CACHE INTERNAL "")
  endif()
endif()


if(EVAL_CXXSTD OR EVAL_MAX_CXXSTD)
  get_target_property(CURR_CXX_STD ${PROJECT_NAME}_${component}${INSTALL_NAME_SUFFIX} CXX_STANDARD)
  #adjust languages standards version, also check adjustment considering max standard, if any
  check_Imported_CXX_Standard(ERROR MESSAGE NEW_CXX_STD NEW_CXX_MAX_STD
    "${CURR_CXX_STD}" "${EVAL_CXXSTD}"
    "${${PROJECT_NAME}_${component}_CXX_MAX_STANDARD${USE_MODE_SUFFIX}}" "${EVAL_MAX_CXXSTD}")
  if(ERROR)
    if(ERROR STREQUAL "CRITICAL")
      finish_Progress(${GLOBAL_PROGRESS_VAR})
      message(FATAL_ERROR "[PID] CRITICAL ERROR: in ${PROJECT_NAME}, when configuring target for component ${component} : ${MESSAGE}")
    else()#warning
      message("[PID] WARNING: in ${PROJECT_NAME}, when configuring target for component ${component} : ${MESSAGE}")
    endif()
  endif()
  if(NEW_CXX_STD)
    set(EVAL_CXXSTD ${NEW_CXX_STD})
  endif()
  if(NEW_CXX_MAX_STD)
    set(${PROJECT_NAME}_${component}_CXX_MAX_STANDARD${USE_MODE_SUFFIX} ${NEW_CXX_MAX_STD} CACHE INTERNAL "")
  endif()
endif()

# setting compile/linkage definitions for the component target
if(export)
	if(NOT ${PROJECT_NAME}_${component}_TYPE STREQUAL "HEADER")#if component is a not header, everything is used to build
		set(INTERNAL_DEFS ${comp_exp_defs} ${EVAL_DEFS} ${comp_defs})
    manage_Additional_Component_Internal_Flags(${component} "${EVAL_CSTD}" "${EVAL_CXXSTD}" "${INSTALL_NAME_SUFFIX}" "${COMPLETE_INCLUDES_PATH}" "${COMPLETE_LIB_DIRS_PATH}" "${INTERNAL_DEFS}" "${EVAL_OPTS}" "${EXT_LINKS}")
	endif()
	set(EXPORTED_DEFS ${comp_exp_defs} ${EVAL_DEFS})#only definitions belonging to interfaces are exported (interface of current component + interface of exported component) also all linker options are exported
	manage_Additional_Component_Exported_Flags(${component} "${INSTALL_NAME_SUFFIX}" "${COMPLETE_INCLUDES_PATH}" "${COMPLETE_LIB_DIRS_PATH}" "${EXPORTED_DEFS}" "${EVAL_OPTS}" "${EXT_LINKS}")

else()#otherwise only definitions for interface of the current component is exported
	set(INTERNAL_DEFS ${comp_defs} ${EVAL_DEFS} ${comp_defs})#everything define for building current component
	manage_Additional_Component_Internal_Flags(${component} "${EVAL_CSTD}" "${EVAL_CXXSTD}" "${INSTALL_NAME_SUFFIX}" "${COMPLETE_INCLUDES_PATH}" "${COMPLETE_LIB_DIRS_PATH}" "${INTERNAL_DEFS}" "${EVAL_OPTS}" "${EXT_LINKS}")
	manage_Additional_Component_Exported_Flags(${component} "${INSTALL_NAME_SUFFIX}" "" "${COMPLETE_LIB_DIRS_PATH}" "${comp_exp_defs}" "" "${EXT_LINKS}")#only linker options and exported definitions are in the public interface
endif()
endfunction(fill_Component_Target_With_External_Dependency)

############################################################################
############### API functions for imported targets management ##############
############################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_All_Imported_External_Component_Dependency_Targets| replace:: ``create_All_Imported_External_Component_Dependency_Targets``
#  .. _create_All_Imported_External_Component_Dependency_Targets:
#
#  create_All_Imported_External_Component_Dependency_Targets
#  ---------------------------------------------------------
#
#   .. command:: create_All_Imported_External_Component_Dependency_Targets(package component mode)
#
#     Create imported targets in current package project for a given external component (belonging to an external package). This may ends up in defining multiple target if this component also has dependencies.
#
#     :package: the name of the external package that contains the component.
#     :component: the name of the external component for which a target has to be created.
#     :mode: the build mode for the imported target.
#
function (create_All_Imported_External_Component_Dependency_Targets package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
#collect only the package dependencies, not the internal ones
foreach(a_dep_component IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
  #for all direct internal dependencies
	create_External_Component_Dependency_Target(${package} ${a_dep_component} ${mode})
  bind_Imported_External_Component_Target(${package} ${component} ${package} ${a_dep_component} ${mode})
endforeach()

foreach(a_dep_package IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
	foreach(a_dep_component IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCY_${a_dep_package}_COMPONENTS${VAR_SUFFIX})
    #for all direct package dependencies
		create_External_Component_Dependency_Target(${a_dep_package} ${a_dep_component} ${mode})
    bind_Imported_External_Component_Target(${package} ${component} ${a_dep_package} ${a_dep_component} ${mode})
  endforeach()
endforeach()

endfunction(create_All_Imported_External_Component_Dependency_Targets)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_All_Imported_Dependency_Targets| replace:: ``create_All_Imported_Dependency_Targets``
#  .. _create_All_Imported_Dependency_Targets:
#
#  create_All_Imported_Dependency_Targets
#  --------------------------------------
#
#   .. command:: create_All_Imported_Dependency_Targets(package component mode)
#
#     Create imported targets in current package project for a given component belonging to another package. This may ends up in defining multiple target if this component also has dependencies.
#
#     :package: the name of the package that contains the component.
#     :component: the name of the component for which a target has to be created.
#     :mode: the build mode for the imported target.
#
function (create_All_Imported_Dependency_Targets package component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

#dealing with explicit external dependencies
foreach(a_dep_package IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCIES${VAR_SUFFIX})
  foreach(a_dep_component IN LISTS ${package}_${component}_EXTERNAL_DEPENDENCY_${a_dep_package}_COMPONENTS${VAR_SUFFIX})
    #for all direct package dependencies
    create_External_Component_Dependency_Target(${a_dep_package} ${a_dep_component} ${mode})
    bind_Imported_External_Target(${package} ${component} ${a_dep_package} ${a_dep_component} ${mode})
  endforeach()
endforeach()

#dealing with internal dependencies
foreach(a_dep_component IN LISTS ${package}_${component}_INTERNAL_DEPENDENCIES${VAR_SUFFIX})
	#for all direct internal dependencies
	create_Dependency_Target(${package} ${a_dep_component} ${mode})
	bind_Imported_Target(${package} ${component} ${package} ${a_dep_component} ${mode})
endforeach()

#dealing with package dependencies
foreach(a_dep_package IN LISTS ${package}_${component}_DEPENDENCIES${VAR_SUFFIX})
	foreach(a_dep_component IN LISTS ${package}_${component}_DEPENDENCY_${a_dep_package}_COMPONENTS${VAR_SUFFIX})
		#for all direct package dependencies
		create_Dependency_Target(${a_dep_package} ${a_dep_component} ${mode})
		bind_Imported_Target(${package} ${component} ${a_dep_package} ${a_dep_component} ${mode})
	endforeach()
endforeach()
endfunction(create_All_Imported_Dependency_Targets)


#.rst:
#
# .. ifmode:: internal
#
#  .. |create_External_Dependency_Target| replace:: ``create_External_Dependency_Target``
#  .. _create_External_Dependency_Target:
#
#  create_External_Dependency_Target
#  ---------------------------------
#
#   .. command:: create_External_Dependency_Target(EXT_TARGET_NAME link type mode)
#
#     Create an imported target for an external dependency (external components or OS dependencies).
#
#     :link: the name of the link option. If this is a real linker option and not a library then no target is created.
#     :type: SHARED or STATIC depending on expected type of the link, or empty string if type is unknown.
#     :mode: the build mode for the imported target.
#
#     :EXT_TARGET_NAME: the output variable that contains the created target name.
#
function (create_External_Dependency_Target EXT_TARGET_NAME link type mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
get_Link_Type(RES_TYPE ${link})
if(type STREQUAL "STATIC")
  if(RES_TYPE STREQUAL "SHARED")#not consistent !!
    message(SEND_ERROR "[PID] ERROR: ${link} specified as STATIC while it is a SHARED library !")
  else()#OK we will build a target
    if(RES_TYPE STREQUAL OPTION)#for options specified as static create a specific target that points to the path of the static library
      set(target_name ext${link}${TARGET_SUFFIX})
      if(NOT TARGET ${target_name})#target does not exist
        add_library(${target_name} INTERFACE)#need to use an interface library to give the linker flag
        if(WIN32)
          string(REGEX REPLACE "^-l(.+)$" "\\1.lib" link_name ${link})
        else()
          string(REGEX REPLACE "^-l(.+)$" "lib\\1.a" link_name ${link})
        endif()
        set_property(TARGET ${target_name} APPEND PROPERTY
    			INTERFACE_LINK_LIBRARIES  ${link_name}
    		)
      endif()
    else()#path to a static library
	  get_filename_component(LIB_NAME ${link} NAME)
      set(target_name ext-${LIB_NAME}${TARGET_SUFFIX})
      if(NOT TARGET ${target_name})#target does not exist
        add_library(${target_name} STATIC IMPORTED GLOBAL)
        set_target_properties(${target_name} PROPERTIES IMPORTED_LOCATION "${link}")
      endif()
    endif()
    set(${EXT_TARGET_NAME} ${target_name} PARENT_SCOPE)

  endif()
elseif(type STREQUAL "SHARED")#this is a shared library
  if(RES_TYPE STREQUAL STATIC) #not consistent !!
    message(SEND_ERROR "[PID] ERROR: ${link} specified as SHARED while it is a STATIC library !")
  else()
    if(RES_TYPE STREQUAL OPTION)#for options specified as static create a specific target
      set(target_name ext${link}${TARGET_SUFFIX})
      if(NOT TARGET ${target_name})#target does not exist
        add_library(${target_name} INTERFACE IMPORTED GLOBAL)#need to use an interface library to give the linker flag
        set_property(TARGET ${target_name} APPEND PROPERTY
    			INTERFACE_LINK_LIBRARIES ${link}
    		)
      endif()
    else()#path to a shared library
	  get_filename_component(LIB_NAME ${link} NAME)
      set(target_name ext-${LIB_NAME}${TARGET_SUFFIX})
      if(NOT TARGET ${target_name})#target does not exist
		add_library(${target_name} SHARED IMPORTED GLOBAL)
		if(WIN32)
			get_Windows_Link_Interface(INTERFACE ${link})
			set_target_properties(${target_name} PROPERTIES IMPORTED_LOCATION "${link}" IMPORTED_IMPLIB "${INTERFACE}")
		else()
			set_target_properties(${target_name} PROPERTIES IMPORTED_LOCATION "${link}")
		endif()
      endif()
    endif()
    set(${EXT_TARGET_NAME} ${target_name} PARENT_SCOPE)
  endif()
else()#type is unknown
  if(RES_TYPE STREQUAL OPTION) #for options there is no need to define a target (options also include -l options)
  	set(${EXT_TARGET_NAME} PARENT_SCOPE)
  elseif(RES_TYPE STREQUAL SHARED)
    get_filename_component(LIB_NAME ${link} NAME)
    set(target_name ext-${LIB_NAME}${TARGET_SUFFIX})
	if(NOT TARGET ${target_name})#target does not exist
	  	add_library(${target_name} SHARED IMPORTED GLOBAL)
	  	if(WIN32)
		  	get_Windows_Link_Interface(INTERFACE ${link})
			set_target_properties(${target_name} PROPERTIES IMPORTED_LOCATION "${link}" IMPORTED_IMPLIB "${INTERFACE}")
		else()
			set_target_properties(${target_name} PROPERTIES IMPORTED_LOCATION "${link}")
		endif()
  	endif()
  	set(${EXT_TARGET_NAME} ${target_name} PARENT_SCOPE)
  else(RES_TYPE STREQUAL STATIC)
	  get_filename_component(LIB_NAME ${link} NAME)
    set(target_name ext-${LIB_NAME}${TARGET_SUFFIX})
  	if(NOT TARGET ${target_name})#target does not exist
  		add_library(${target_name} STATIC IMPORTED GLOBAL)
  		set_target_properties(${target_name} PROPERTIES IMPORTED_LOCATION "${link}")
  	endif()
  	set(${EXT_TARGET_NAME} ${target_name} PARENT_SCOPE)
  endif()
endif()

endfunction(create_External_Dependency_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Dependency_Target| replace:: ``create_Dependency_Target``
#  .. _create_Dependency_Target:
#
#  create_Dependency_Target
#  ------------------------
#
#   .. command:: create_Dependency_Target(dep_package dep_component mode)
#
#     Create an imported target for a dependency that is a native component belonging to another package than currently built one. This ends up in creating all targets required by this dependency if it has dependencies (recursion).
#
#     :dep_package: the name of the package that contains the dependency.
#     :dep_component: the name of the component that IS the dependency.
#     :mode: the build mode for the imported target.
#
function (create_Dependency_Target dep_package dep_component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

rename_If_Alias(comp_name_to_use ${dep_package} FALSE ${dep_component} Release)

if(NOT TARGET ${dep_package}_${comp_name_to_use}${TARGET_SUFFIX})#check that this target does not exist, otherwise naming conflict
#create the dependent target (#may produce recursion to build undirect dependencies of targets
	if(${dep_package}_${comp_name_to_use}_TYPE STREQUAL "APP"
		OR ${dep_package}_${comp_name_to_use}_TYPE STREQUAL "EXAMPLE")
		create_Imported_Executable_Target(${dep_package} ${comp_name_to_use} ${mode})
	elseif(${dep_package}_${comp_name_to_use}_TYPE STREQUAL "MODULE")
		create_Imported_Module_Library_Target(${dep_package} ${comp_name_to_use} ${mode})
	elseif(${dep_package}_${comp_name_to_use}_TYPE STREQUAL "SHARED")
		create_Imported_Shared_Library_Target(${dep_package} ${comp_name_to_use} ${mode})
	elseif(${dep_package}_${comp_name_to_use}_TYPE STREQUAL "STATIC")
		create_Imported_Static_Library_Target(${dep_package} ${comp_name_to_use} ${mode})
	elseif(${dep_package}_${comp_name_to_use}_TYPE STREQUAL "HEADER")
		create_Imported_Header_Library_Target(${dep_package} ${comp_name_to_use} ${mode})
	endif()
	create_All_Imported_Dependency_Targets(${dep_package} ${comp_name_to_use} ${mode})
endif()
endfunction(create_Dependency_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_External_Component_Dependency_Target| replace:: ``create_External_Component_Dependency_Target``
#  .. _create_External_Component_Dependency_Target:
#
#  create_External_Component_Dependency_Target
#  -------------------------------------------
#
#   .. command:: create_External_Component_Dependency_Target(dep_package dep_component mode)
#
#     Create an imported target for a dependency that is an external component. This ends up in creating all targets required by this dependency if it has dependencies (recursion).
#
#     :dep_package: the name of the external package that contains the dependency.
#     :dep_component: the name of the external component that IS the dependency.
#     :mode: the build mode for the imported target.
#
function(create_External_Component_Dependency_Target dep_package dep_component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
set(EXT_SH_LINKS_OPTIONS)
set(EXT_ST_LINKS_OPTIONS)
rename_If_Alias(comp_name_to_use ${dep_package} TRUE ${dep_component} ${mode})

#contrarily to native dependencies we do not know the nature of the component
set(target_name ${dep_package}_${comp_name_to_use}${TARGET_SUFFIX})
if(NOT TARGET ${target_name})#check that this target does not exist, otherwise naming conflict

  # 0) create an imported target for the component
  add_library(${target_name} INTERFACE IMPORTED GLOBAL)#need to use an interface library to export all other proêrties of the component
  list_Public_Includes(INCLUDES ${dep_package} ${comp_name_to_use} ${mode} FALSE)#external package does not define their own header dir, simply define a set of include dirs
  list_Public_Lib_Dirs(LIBDIRS ${dep_package} ${comp_name_to_use} ${mode})
	list_Public_Definitions(DEFS ${dep_package} ${comp_name_to_use} ${mode})
	list_External_Links(SHARED_LNKS STATIC_LNKS ${dep_package} ${comp_name_to_use} ${mode})
  # 1) create dependent targets for each binary (also allow same global management of links as for legacy package dependencies)
  #shared first
  foreach(link IN LISTS SHARED_LNKS)
    create_External_Dependency_Target(EXT_SH_TARGET_NAME ${link} "" ${mode})#do not force SHARED type as some options may be linker options coming from configurations
    if(NOT EXT_SH_TARGET_NAME)#no target created
      list(APPEND EXT_SH_LINKS_OPTIONS ${link})
    else()#target created (not a linker option), link it
      set_property(TARGET ${target_name} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${EXT_SH_TARGET_NAME})
      # targets with binaries are just proxies for the global external componeht target (an external component may define many binaries)
    endif()
  endforeach()
  #static second
  foreach(link IN LISTS STATIC_LNKS)
    create_External_Dependency_Target(EXT_ST_TARGET_NAME ${link} STATIC ${mode})
    if(NOT EXT_ST_TARGET_NAME)#not target created
      list(APPEND EXT_ST_LINKS_OPTIONS ${link})#by definition it is a static link option (must force it to ensure it is correctly managed)
    else()#target created (not a linker option), link it
      set_property(TARGET ${target_name} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${EXT_ST_TARGET_NAME})
    endif()
  endforeach()

  # 2) create an imported target for the component AND bind all defined compilation related flags
  adjust_Languages_Standard_For_Imported_Component(FILTERED_OPTS ${dep_package} ${comp_name_to_use} ${mode})
	#add all properties that are not system like links to explicit libraries (explicit library links will be added as targets)
  manage_Additional_Imported_Component_Flags(
    "${dep_package}"
    "${comp_name_to_use}"
    "${mode}"
    "${INCLUDES}"
    "${DEFS}"
    "${FILTERED_OPTS}"
    "${EXT_SH_LINKS_OPTIONS}"
    "" #no private links locally
    "${EXT_ST_LINKS_OPTIONS}"
    "${LIBDIRS}"
  )
  create_All_Imported_External_Component_Dependency_Targets(${dep_package} ${comp_name_to_use} ${mode})
endif()
endfunction(create_External_Component_Dependency_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |manage_Additional_Imported_Component_Flags| replace:: ``manage_Additional_Imported_Component_Flags``
#  .. _manage_Additional_Imported_Component_Flags:
#
#  manage_Additional_Imported_Component_Flags
#  ------------------------------------------
#
#   .. command:: manage_Additional_Imported_Component_Flags(package component mode inc_dirs defs options public_links private_links system_static_links public_lib_dirs)
#
#     Setting the build properties of an imported target of a component. This may ends up in creating new targets if the component has external dependencies.
#
#     :package: the name of the package that contains the component.
#     :component: the name of the component whose target properties has to be set.
#     :mode: the build mode for the imported target.
#     :inc_dirs: the list of path to include folders to set.
#     :defs: the list of preprocessor definitions to set.
#     :options: the list of compiler options to set.
#     :public_links: the list of path to linked libraries that are exported by component, or exported linker options.
#     :private_links: the list of path to linked libraries that are internal to component, or internal linker options.
#     :system_static_links: the list of path to linked system libraries that are specified as static.
#     :public_lib_dirs: the list of path to libraries directories that are exported by component.
#
function(manage_Additional_Imported_Component_Flags package component mode inc_dirs defs options public_links private_links system_static_links public_lib_dirs)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
# managing include folders (-I<path>)
foreach(dir IN LISTS inc_dirs)
	set_property(TARGET ${package}_${component}${TARGET_SUFFIX} APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${dir}")
endforeach()

# managing compile time flags (-D<preprocessor_defs>)
foreach(def IN LISTS defs)
	set_property(TARGET ${package}_${component}${TARGET_SUFFIX} APPEND PROPERTY INTERFACE_COMPILE_DEFINITIONS "${def}")
endforeach()

# managing public link time flags (public links are always put in the interface)
foreach(link IN LISTS public_links)
	create_External_Dependency_Target(EXT_TARGET_NAME ${link} "" ${mode})#public links may be path to shared or static libs or linker options (considered as shared by default)
	if(EXT_TARGET_NAME) #this is a library
		set_property(TARGET ${package}_${component}${TARGET_SUFFIX} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${EXT_TARGET_NAME})
	else()#this is an option => simply pass it to the link interface
		set_property(TARGET ${package}_${component}${TARGET_SUFFIX} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${link})
	endif()
endforeach()

# managing private link time flags (private links are never put in the interface)
foreach(link IN LISTS private_links)
	create_External_Dependency_Target(EXT_TARGET_NAME ${link} "" ${mode})#private links are path to shared libraries used by a shared library
  if(EXT_TARGET_NAME) #this is a library
		set_property(TARGET ${package}_${component}${TARGET_SUFFIX} APPEND PROPERTY IMPORTED_LINK_DEPENDENT_LIBRARIES ${EXT_TARGET_NAME})
	else()#this is a linker option => simply pass it to the link interface
		set_property(TARGET ${package}_${component}${TARGET_SUFFIX} APPEND PROPERTY IMPORTED_LINK_DEPENDENT_LIBRARIES ${link})
	endif()
endforeach()

# managing system link time flags (system static links are always put in the interface)
foreach(link IN LISTS system_static_links)
	create_External_Dependency_Target(EXT_TARGET_NAME ${link} STATIC ${mode})# system static links are system liniking flags (-l<name>) pointing to a static library
  set_property(TARGET ${package}_${component}${TARGET_SUFFIX} APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${EXT_TARGET_NAME})
endforeach()

#managing library dirs
foreach(dir IN LISTS public_lib_dirs)
	set_property(TARGET ${package}_${component}${TARGET_SUFFIX} APPEND PROPERTY INTERFACE_LINK_LIBRARIES "-L${dir}")
endforeach()

endfunction(manage_Additional_Imported_Component_Flags)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Imported_Target_Mode| replace:: ``get_Imported_Target_Mode``
#  .. _get_Imported_Target_Mode:
#
#  get_Imported_Target_Mode
#  ------------------------
#
#   .. command:: get_Imported_Target_Mode(MODE_TO_IMPORT imported_package imported_binary_location build_mode)
#
#     Deduce which mode to use depending on the build mode required for the imported target. Release mode implies using Release binary ; Debug mode implies using Debug mode binaries or Release mode binaries if component is Closed source or whenever no Debug binary available.
#
#     :imported_package: the name of the package that contains the imported target.
#     :imported_binary_location: the path to the binary that is imported.
#     :build_mode: the build mode for the imported target.
#
#     :MODE_TO_IMPORT: the output variable that contains the build mode to finally use for the imported target.
#
function(get_Imported_Target_Mode MODE_TO_IMPORT imported_package imported_binary_location build_mode)
	if(mode MATCHES Debug)
			is_Closed_Source_Dependency_Package(CLOSED ${imported_package})
			if(CLOSED AND NOT EXISTS ${imported_binary_location})#if package is closed source and no debug code available (this is a normal case)
				set(${MODE_TO_IMPORT} Release PARENT_SCOPE) #we must use the Release code
			else() #use default mode
				set(${MODE_TO_IMPORT} Debug PARENT_SCOPE)
			endif()
	else() #use default mode
				set(${MODE_TO_IMPORT} Release PARENT_SCOPE)
	endif()
endfunction(get_Imported_Target_Mode)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Imported_Header_Library_Target| replace:: ``create_Imported_Header_Library_Target``
#  .. _create_Imported_Header_Library_Target:
#
#  create_Imported_Header_Library_Target
#  -------------------------------------
#
#   .. command:: create_Imported_Header_Library_Target(package component mode)
#
#     Create the imported target for a header only library belonging to a given native package.
#
#     :package: the name of the package that contains the library.
#     :component: the name of the header library.
#     :mode: the build mode for the imported target.
#
function(create_Imported_Header_Library_Target package component mode) #header libraries are never closed by definition
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})#get variables related to the current build mode
	add_library(${package}_${component}${TARGET_SUFFIX} INTERFACE IMPORTED GLOBAL)#suffix used only for target name
	list_Public_Includes(INCLUDES ${package} ${component} ${mode} TRUE)
	list_Public_Links(LINKS SYSTEM_STATIC LIB_DIRS ${package} ${component} ${mode})
  list_Public_Lib_Dirs(LIBDIRS ${package} ${component} ${mode})
	list_Public_Definitions(DEFS ${package} ${component} ${mode})

  adjust_Languages_Standard_For_Imported_Component(FILTERED_OPTS ${package} ${component} ${mode})
  manage_Additional_Imported_Component_Flags(${package} ${component} ${mode} "${INCLUDES}" "${DEFS}" "${FILTERED_OPTS}" "${LINKS}" "" "${SYSTEM_STATIC}" "${LIBDIRS}")
endfunction(create_Imported_Header_Library_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Imported_Static_Library_Target| replace:: ``create_Imported_Static_Library_Target``
#  .. _create_Imported_Static_Library_Target:
#
#  create_Imported_Static_Library_Target
#  -------------------------------------
#
#   .. command:: create_Imported_Static_Library_Target(package component mode)
#
#     Create the imported target for a static library belonging to a given native package.
#
#     :package: the name of the package that contains the library.
#     :component: the name of the header library.
#     :mode: the build mode for the imported target.
#
function(create_Imported_Static_Library_Target package component mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode}) #get variables related to the current build mode
	add_library(${package}_${component}${TARGET_SUFFIX} STATIC IMPORTED GLOBAL) #create the target for the imported library

	get_Binary_Location(LOCATION_RES ${package} ${component} ${mode})
	get_Imported_Target_Mode(MODE_TO_IMPORT ${package} ${LOCATION_RES} ${mode})#get the adequate mode to use for dependency
	if(NOT MODE_TO_IMPORT MATCHES mode)
		get_Binary_Location(LOCATION_RES ${package} ${component} ${MODE_TO_IMPORT})#find the adequate release binary
	endif()
	set_target_properties(${package}_${component}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${LOCATION_RES}")#Debug mode: we keep the suffix as-if we werre building using dependent debug binary even if not existing

	list_Public_Includes(INCLUDES ${package} ${component} ${MODE_TO_IMPORT} TRUE)
	list_Public_Links(LINKS SYSTEM_STATIC ${package} ${component} ${MODE_TO_IMPORT})
  list_Public_Lib_Dirs(LIBDIRS ${package} ${component} ${MODE_TO_IMPORT})
	list_Private_Links(PRIVATE_LINKS ${package} ${component} ${MODE_TO_IMPORT})
	list_Public_Definitions(DEFS ${package} ${component} ${MODE_TO_IMPORT})

  adjust_Languages_Standard_For_Imported_Component(FILTERED_OPTS ${package} ${component} ${MODE_TO_IMPORT})
  manage_Additional_Imported_Component_Flags(${package} ${component} ${mode} "${INCLUDES}" "${DEFS}" "${FILTERED_OPTS}" "${LINKS}" "${PRIVATE_LINKS}" "${SYSTEM_STATIC}" "${LIBDIRS}")
endfunction(create_Imported_Static_Library_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Imported_Shared_Library_Target| replace:: ``create_Imported_Shared_Library_Target``
#  .. _create_Imported_Shared_Library_Target:
#
#  create_Imported_Shared_Library_Target
#  -------------------------------------
#
#   .. command:: create_Imported_Shared_Library_Target(package component mode)
#
#     Create the imported target for a shared library belonging to a given native package.
#
#     :package: the name of the package that contains the library.
#     :component: the name of the header library.
#     :mode: the build mode for the imported target.
#
function(create_Imported_Shared_Library_Target package component mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})#get variables related to the current build mode
	add_library(${package}_${component}${TARGET_SUFFIX} SHARED IMPORTED GLOBAL)#create the target for the imported library
	get_Binary_Location(LOCATION_RES ${package} ${component} ${mode})#find the binary to use depending on build mode
	get_Imported_Target_Mode(MODE_TO_IMPORT ${package} ${LOCATION_RES} ${mode})#get the adequate mode to use for dependency
	if(NOT MODE_TO_IMPORT MATCHES mode)
		get_Binary_Location(LOCATION_RES ${package} ${component} ${MODE_TO_IMPORT})#find the adequate release binary
	endif()
  if(WIN32)#in windows a shared librairy is specific because it has two parts : a dll and an interface static library
    #we need to link againts the statis library while the "real" component is the dll
    #so we transform the name of the dll object into a .lib object
	   get_Windows_Link_Interface(STATIC_LOCATION_RES ${LOCATION_RES})
    set_target_properties(${package}_${component}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${LOCATION_RES}" IMPORTED_IMPLIB "${STATIC_LOCATION_RES}")
  else()#for UNIX system everything is automatic
    set_target_properties(${package}_${component}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${LOCATION_RES}")#Debug mode: we keep the suffix as-if we werre building using dependent debug binary even if not existing
  endif()

	list_Public_Includes(INCLUDES ${package} ${component} ${MODE_TO_IMPORT} TRUE)
	list_Public_Links(LINKS SYSTEM_STATIC ${package} ${component} ${MODE_TO_IMPORT})
  list_Public_Lib_Dirs(LIBDIRS ${package} ${component} ${MODE_TO_IMPORT})
	list_Private_Links(PRIVATE_LINKS ${package} ${component} ${MODE_TO_IMPORT})
	list_Public_Definitions(DEFS ${package} ${component} ${MODE_TO_IMPORT})

  adjust_Languages_Standard_For_Imported_Component(FILTERED_OPTS ${package} ${component} ${MODE_TO_IMPORT})
  manage_Additional_Imported_Component_Flags(${package} ${component} ${mode} "${INCLUDES}" "${DEFS}" "${FILTERED_OPTS}" "${LINKS}" "${PRIVATE_LINKS}" "${SYSTEM_STATIC}" "${LIBDIRS}")
endfunction(create_Imported_Shared_Library_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Imported_Module_Library_Target| replace:: ``create_Imported_Module_Library_Target``
#  .. _create_Imported_Module_Library_Target:
#
#  create_Imported_Module_Library_Target
#  -------------------------------------
#
#   .. command:: create_Imported_Module_Library_Target(package component mode)
#
#     Create the imported target for a module library belonging to a given native package.
#
#     :package: the name of the package that contains the library.
#     :component: the name of the header library.
#     :mode: the build mode for the imported target.
#
function(create_Imported_Module_Library_Target package component mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})#get variables related to the current build mode
	add_library(${package}_${component}${TARGET_SUFFIX} MODULE IMPORTED GLOBAL)#create the target for the imported library

	get_Binary_Location(LOCATION_RES ${package} ${component} ${mode})#find the binary to use depending on build mode
	get_Imported_Target_Mode(MODE_TO_IMPORT ${package} ${LOCATION_RES} ${mode})#get the adequate mode to use for dependency
	if(NOT MODE_TO_IMPORT MATCHES mode)
		get_Binary_Location(LOCATION_RES ${package} ${component} ${MODE_TO_IMPORT})#find the adequate release binary
	endif()

	set_target_properties(${package}_${component}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${LOCATION_RES}")#Debug mode: we keep the suffix as-if we werre building using dependent debug binary even if not existing
	#no need to do more, a module is kind of an executable so it stops build recursion
endfunction(create_Imported_Module_Library_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |create_Imported_Executable_Target| replace:: ``create_Imported_Executable_Target``
#  .. _create_Imported_Executable_Target:
#
#  create_Imported_Executable_Target
#  ---------------------------------
#
#   .. command:: create_Imported_Executable_Target(package component mode)
#
#     Create the imported target for an executable belonging to a given native package.
#
#     :package: the name of the package that contains the executable.
#     :component: the name of the executable.
#     :mode: the build mode for the imported target.
#
function(create_Imported_Executable_Target package component mode)
	get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})#get variables related to the current build mode
	add_executable(${package}_${component}${TARGET_SUFFIX} IMPORTED GLOBAL)#create the target for the imported executable

	get_Binary_Location(LOCATION_RES ${package} ${component} ${mode})
	get_Imported_Target_Mode(MODE_TO_IMPORT ${package} ${LOCATION_RES} ${mode})#get the adequate mode to use for dependency
	if(NOT MODE_TO_IMPORT MATCHES mode)
		get_Binary_Location(LOCATION_RES ${package} ${component} ${MODE_TO_IMPORT})#find the adequate release binary
	endif()

	set_target_properties(${package}_${component}${TARGET_SUFFIX} PROPERTIES IMPORTED_LOCATION "${LOCATION_RES}")#Debug mode: we keep the suffix as-if we werre building using dependent debug binary even if not existing
	#no need to do more, executable will not be linked in the build process (it stops build recursion)
endfunction(create_Imported_Executable_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |resolve_Component_Standard_For_Dependency| replace:: ``resolve_Component_Standard_For_Dependency``
#  .. _resolve_Component_Standard_For_Dependency:
#
#  resolve_Component_Standard_For_Dependency
#  -----------------------------------------
#
#   .. command:: resolve_Component_Standard_For_Dependency(package component dep_package dep_component mode configure_build)
#
#    Resolve the final language standard to use for a component of the current native package depending on the standard used in one of its dependencies.
#
#     :package: the name of the package that contains the component that HAS a dependency (package currenlty built).
#     :component: the name of the component that HAS a dependency.
#     :dep_package: the name of the package that contains the dependency.
#     :dep_component: the name of the component that IS the dependency.
#     :mode: the build mode for the imported target.
#     :configure_build: if TRUE then set component's target properties adequately.
#
function(resolve_Component_Standard_For_Dependency package component dep_package dep_component mode configure_build)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

  resolve_Imported_Standards(ERR MESS NEW_C_STD NEW_C_MAX_STD NEW_CXX_STD NEW_CXX_MAX_STD
                     "${${package}_${component}_C_STANDARD${VAR_SUFFIX}}" "${${package}_${component}_C_MAX_STANDARD${VAR_SUFFIX}}"
                     "${${package}_${component}_CXX_STANDARD${VAR_SUFFIX}}" "${${package}_${component}_CXX_MAX_STANDARD${VAR_SUFFIX}}"
                     "${${dep_package}_${dep_component}_C_STANDARD${VAR_SUFFIX}}" "${${dep_package}_${dep_component}_C_MAX_STANDARD${VAR_SUFFIX}}"
                     "${${dep_package}_${dep_component}_CXX_STANDARD${VAR_SUFFIX}}" "${${dep_package}_${dep_component}_CXX_MAX_STANDARD${VAR_SUFFIX}}")

  if(ERR)
   if(ERR STREQUAL "CRITICAL")
     finish_Progress(${GLOBAL_PROGRESS_VAR})
     message(FATAL_ERROR "[PID] CRITICAL ERROR: in ${PROJECT_NAME}, when configuring target for component ${component} from package ${package} with dependency ${dep_component} from package ${dep_package} : ${MESS}")
   else()#warning
     message("[PID] WARNING: in ${PROJECT_NAME}, when configuring target for component ${component} from package ${package} with dependency ${dep_component} from package ${dep_package} : ${MESS}")
   endif()
  endif()

  if(NEW_C_STD)#need to modify component due to its dependency
    set(${package}_${component}_C_STANDARD${VAR_SUFFIX} ${NEW_C_STD} CACHE INTERNAL "")
  	if(configure_build)# the build property is set for a target that is built locally (otherwise would produce errors)
  		set_target_properties(${package}_${component}${TARGET_SUFFIX} PROPERTIES C_STANDARD ${NEW_C_STD}) #the minimal value in use file is set adequately
  	endif()
  endif()
  if(NEW_C_MAX_STD)#need to update the max standard allowed
    set(${package}_${component}_C_MAX_STANDARD${USE_MODE_SUFFIX} ${NEW_C_MAX_STD} CACHE INTERNAL "")
  endif()

  if(NEW_CXX_STD)#need to modify component due to its dependency
    set(${package}_${component}_CXX_STANDARD${VAR_SUFFIX} ${NEW_CXX_STD} CACHE INTERNAL "")
  	if(configure_build)# the build property is set for a target that is built locally (otherwise would produce errors)
  		set_target_properties(${package}_${component}${TARGET_SUFFIX} PROPERTIES CXX_STANDARD ${NEW_CXX_STD}) #the minimal value in use file is set adequately
  	endif()
  endif()
  if(NEW_CXX_MAX_STD)#need to update the max standard allowed
    set(${package}_${component}_CXX_MAX_STANDARD${USE_MODE_SUFFIX} ${NEW_CXX_MAX_STD} CACHE INTERNAL "")
  endif()

endfunction(resolve_Component_Standard_For_Dependency)


#.rst:
#
# .. ifmode:: internal
#
#  .. |bind_Target| replace:: ``bind_Target``
#  .. _bind_Target:
#
#  bind_Target
#  -----------
#
#   .. command:: bind_Target(component is_external dep_package dep_component mode export comp_defs comp_exp_defs dep_defs)
#
#   Bind the target of a component build locally to the target of a component belonging to another package.
#
#     :component: the name of the component whose target has to be bound to another target.
#     :is_external: if TRUE the dependent package is an external package.
#     :dep_package: the name of the package that contains the dependency.
#     :dep_component: the name of the component that IS the dependency.
#     :mode: the build mode for the targets.
#     :export: if TRUE then set component's target export dep_component's target.
#     :comp_defs: the preprocessor definitions defined in component implementation that conditionate the use of dep_component.
#     :comp_exp_defs: the preprocessor definitions defined in component interface that conditionate the use of dep_component.
#     :dep_defs: the preprocessor definitions used in dep_component interface that are defined by dep_component.
#
function(bind_Target component is_external dep_package dep_component mode export comp_defs comp_exp_defs dep_defs)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

rename_If_Alias(comp_name_to_use ${PROJECT_NAME} FALSE ${component} Release)
#  the dependency may refer to an ALIAS name of dependent component
# as it is NOT internal an ALIAS target is NOT defined so we need to resolved alias before
if(is_external)
  rename_If_Alias(dep_name_to_use ${dep_package} TRUE ${dep_component} ${mode})
  set(DEP_IS_HF FALSE)#by default we consider that external components have headers
else()
  rename_If_Alias(dep_name_to_use ${dep_package} FALSE ${dep_component} Release)
  is_HeaderFree_Component(DEP_IS_HF ${dep_package} ${dep_name_to_use})
endif()

is_Built_Component(COMP_IS_BUILT ${PROJECT_NAME} ${comp_name_to_use})

if(COMP_IS_BUILT)
	#use definitions and links for building the target
	set(internal_defs ${comp_defs} ${comp_exp_defs} ${dep_defs})
	manage_Additional_Component_Internal_Flags(${comp_name_to_use} "" "" "${TARGET_SUFFIX}" "" "" "${internal_defs}" "" "")

	if(NOT DEP_IS_HF)
		target_link_libraries(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} PRIVATE ${dep_package}_${dep_name_to_use}${TARGET_SUFFIX})#Note: since dependency is imported we cannot used its alias

    target_include_directories(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} PRIVATE
			$<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)#Note: since dependency is imported we cannot used its alias

		target_compile_definitions(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} PRIVATE
			$<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)#Note: since dependency is imported we cannot used its alias

		target_compile_options(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} PRIVATE
			$<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>)#Note: since dependency is imported we cannot used its alias
	endif()

	# set adequately language standard for component depending on the value of dep_component
	resolve_Component_Standard_For_Dependency(${PROJECT_NAME} ${comp_name_to_use} ${dep_package} ${dep_name_to_use} ${mode} TRUE)
else()#for headers lib do not set the language standard build property (othewise CMake complains on recent versions)
	# set adequately language standard for component depending on the value of dep_component
	resolve_Component_Standard_For_Dependency(${PROJECT_NAME} ${comp_name_to_use} ${dep_package} ${dep_name_to_use} ${mode} FALSE)
endif()

if(NOT DEP_IS_HF)#the required package component is a library with header it can export something
	if(export)#the library export something
		set(exp_defs ${comp_exp_defs} ${dep_defs})
		manage_Additional_Component_Exported_Flags(${comp_name_to_use} "${TARGET_SUFFIX}" "" "" "${exp_defs}" "" "")

		target_include_directories(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} INTERFACE
			$<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)#Note: since dependency is imported we cannot used its alias

		target_compile_definitions(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} INTERFACE
			$<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)#Note: since dependency is imported we cannot used its alias

		target_compile_options(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} INTERFACE
			$<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>)#Note: since dependency is imported we cannot used its alias

	else()#the library do not export anything
		manage_Additional_Component_Exported_Flags(${comp_name_to_use} "${TARGET_SUFFIX}" "" "" "${comp_exp_defs}" "" "")
	endif()
  target_link_libraries(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} INTERFACE ${dep_package}_${dep_name_to_use}${TARGET_SUFFIX})#Note: since dependency is imported we cannot used its alias
endif()	#else, it is an application or a module => runtime dependency declaration only
endfunction(bind_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |bind_Internal_Target| replace:: ``bind_Internal_Target``
#  .. _bind_Internal_Target:
#
#  bind_Internal_Target
#  --------------------
#
#   .. command:: bind_Internal_Target(component dep_component mode export comp_defs comp_exp_defs dep_defs)
#
#   Bind the targets of two components built in current package.
#
#     :component: the name of the component whose target has to be bound to another target.
#     :dep_component: the name of the component that IS the dependency.
#     :mode: the build mode for the targets.
#     :export: if TRUE then set component's target export dep_component's target.
#     :comp_defs: the preprocessor definitions defined in component implementation that conditionate the use of dep_component.
#     :comp_exp_defs: the preprocessor definitions defined in component interface that conditionate the use of dep_component.
#     :dep_defs: the preprocessor definitions used in dep_component interface that are defined by dep_component.
#
function(bind_Internal_Target component dep_component mode export comp_defs comp_exp_defs dep_defs)

get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})
rename_If_Alias(comp_name_to_use ${PROJECT_NAME} FALSE ${component} Release)
rename_If_Alias(dep_name_to_use ${PROJECT_NAME} FALSE ${dep_component} Release)

is_HeaderFree_Component(DEP_IS_HF ${PROJECT_NAME} ${dep_name_to_use})
is_Built_Component(COMP_IS_BUILT ${PROJECT_NAME} ${comp_name_to_use})#by definition this is always called on real target (not alias so no need to check for alias)

#  the dependency may refer to an ALIAS name of another internal component
# as it is internal an ALIAS target is defined so theretically no need to check for specific cases
# but all PID properties are defined on real names only so calling functions on components require their alias names to be resolved
# here needed for is_HeaderFree_Component, resolve_Component_Standard_For_Dependency


if(COMP_IS_BUILT)# interface library cannot receive PRIVATE PROPERTIES
	#use definitions and links for building the target
	set(internal_defs ${comp_defs} ${comp_exp_defs} ${dep_defs})
	manage_Additional_Component_Internal_Flags(${comp_name_to_use} "" "" "${TARGET_SUFFIX}" "" "" "${internal_defs}" "" "")

	if(NOT DEP_IS_HF)#the dependency may export some things, so we need to bind definitions
		target_link_libraries(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} PRIVATE ${PROJECT_NAME}_${dep_component}${TARGET_SUFFIX})# since dependency is local we can use its alias

		target_include_directories(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} PRIVATE
			$<TARGET_PROPERTY:${PROJECT_NAME}_${dep_component}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)# since dependency is local we can use its alias

		target_compile_definitions(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} PRIVATE
			$<TARGET_PROPERTY:${PROJECT_NAME}_${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)# since dependency is local we can use its alias

		target_compile_options(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} PRIVATE
			$<TARGET_PROPERTY:${PROJECT_NAME}_${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>)# since dependency is local we can use its alias
	endif()

		# set adequately language standard for component depending on the value of dep_component
		resolve_Component_Standard_For_Dependency(${PROJECT_NAME} ${comp_name_to_use} ${PROJECT_NAME} ${dep_name_to_use} ${mode} TRUE)
else() #for header lib do not set the build property to avoid troubles
		# set adequately language standard for component depending on the value of dep_component
		resolve_Component_Standard_For_Dependency(${PROJECT_NAME} ${comp_name_to_use} ${PROJECT_NAME} ${dep_name_to_use} ${mode} FALSE)
endif()


if(NOT DEP_IS_HF)#the required package component is a library with header it can export something
	if(export)
		set(internal_defs ${comp_exp_defs} ${dep_defs})
		manage_Additional_Component_Exported_Flags(${comp_name_to_use} "${TARGET_SUFFIX}" "" "" "${internal_defs}" "" "")

		target_include_directories(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} INTERFACE
			$<TARGET_PROPERTY:${PROJECT_NAME}_${dep_component}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>)# since dependency is local we can use its alias

		target_compile_definitions(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} INTERFACE
			$<TARGET_PROPERTY:${PROJECT_NAME}_${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>)# since dependency is local we can use its alias

		target_compile_options(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} INTERFACE
			$<TARGET_PROPERTY:${PROJECT_NAME}_${dep_component}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>)# since dependency is local we can use its alias

	else()
		manage_Additional_Component_Exported_Flags(${comp_name_to_use} "${TARGET_SUFFIX}" "" "" "${comp_exp_defs}" "" "")
		#else non exported shared
	endif()
  target_link_libraries(${PROJECT_NAME}_${comp_name_to_use}${TARGET_SUFFIX} INTERFACE ${PROJECT_NAME}_${dep_component}${TARGET_SUFFIX})# since dependency is local we can use its alias

endif()	#else, it is an application or a module => runtime dependency declaration only
endfunction(bind_Internal_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |bind_Imported_External_Component_Target| replace:: ``bind_Imported_External_Component_Target``
#  .. _bind_Imported_External_Component_Target:
#
#  bind_Imported_External_Component_Target
#  ---------------------------------------
#
#   .. command:: bind_Imported_External_Component_Target(package component dep_package dep_component mode)
#
#   Bind two imported external component targets.
#
#     :package: the name of the external package that contains the component whose target depends on another imported target.
#     :component: the name of the external component whose target depends on another imported target.
#     :dep_package: the name of the external package that contains the dependency.
#     :dep_component: the name of the external component that IS the dependency.
#     :mode: the build mode for the targets.
#
function(bind_Imported_External_Component_Target package component dep_package dep_component mode)
  get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

  rename_If_Alias(comp_name_to_use ${package} TRUE ${component} ${mode})
  rename_If_Alias(dep_name_to_use ${dep_package} TRUE ${dep_component} ${mode})
  #Note: original and component and dep_component are considered as alias (they can have same value as base name)
  export_External_Component_Resolving_Alias(IS_EXPORTING ${package} ${comp_name_to_use} ${component} ${dep_package} ${dep_name_to_use} ${dep_component} ${mode})

  if(IS_EXPORTING)
		set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
			INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>
		)
		set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
			INTERFACE_COMPILE_DEFINITIONS $<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>
		)
		set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
			INTERFACE_COMPILE_OPTIONS $<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>
		)
	endif()
  #exporting the linked libraries in any case
  set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
    INTERFACE_LINK_LIBRARIES ${dep_package}_${dep_name_to_use}${TARGET_SUFFIX}
  )

	# set adequately language standard for component depending on the value of dep_component
	resolve_Component_Standard_For_Dependency(${package} ${comp_name_to_use} ${dep_package} ${dep_name_to_use} ${mode} FALSE)
endfunction(bind_Imported_External_Component_Target)

#.rst:
#
# .. ifmode:: internal
#
#  .. |bind_Imported_Target| replace:: ``bind_Imported_Target``
#  .. _bind_Imported_Target:
#
#  bind_Imported_Target
#  --------------------
#
#   .. command:: bind_Imported_Target(package component dep_package dep_component mode)
#
#   Bind two imported targets.
#
#     :package: the name of the package that contains the component whose target depends on another imported target.
#     :component: the name of the component whose target depends on another imported target.
#     :dep_package: the name of the package that contains the dependency.
#     :dep_component: the name of the component that IS the dependency.
#     :mode: the build mode for the targets.
#
function(bind_Imported_Target package component dep_package dep_component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

rename_If_Alias(dep_name_to_use ${dep_package} FALSE ${dep_component} Release)
rename_If_Alias(comp_name_to_use ${package} FALSE ${component} Release)

# Note: in this call component and dep_component can be aliases
export_Component_Resolving_Alias(IS_EXPORTING ${package} ${comp_name_to_use} ${component} ${dep_package} ${dep_name_to_use} ${dep_component} ${mode})

is_HeaderFree_Component(DEP_IS_HF ${dep_package} ${dep_name_to_use})
if(NOT DEP_IS_HF)#the required package component is a library with header it defins symbols so it can be exported
	if(IS_EXPORTING)

		set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
			INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>
		)
		set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
			INTERFACE_COMPILE_DEFINITIONS $<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>
		)
		set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
			INTERFACE_COMPILE_OPTIONS $<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>
		)
		set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
			INTERFACE_LINK_LIBRARIES ${dep_package}_${dep_name_to_use}${TARGET_SUFFIX}
		)
	else()
		if(${package}_${comp_name_to_use}_TYPE STREQUAL "SHARED")
      set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
				IMPORTED_LINK_DEPENDENT_LIBRARIES ${dep_package}_${dep_name_to_use}${TARGET_SUFFIX}
			)
    else()#static OR header lib always export links
    	set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
				INTERFACE_LINK_LIBRARIES ${dep_package}_${dep_name_to_use}${TARGET_SUFFIX}
			)
		endif()
	endif()#exporting the linked libraries in any case

	# set adequately language standard for component depending on the value of dep_component
	resolve_Component_Standard_For_Dependency(${package} ${comp_name_to_use} ${dep_package} ${dep_name_to_use} ${mode} FALSE)

endif()	#else, it is an application or a module => runtime dependency declaration only (build recursion is stopped)
endfunction(bind_Imported_Target)


#.rst:
#
# .. ifmode:: internal
#
#  .. |bind_Imported_External_Target| replace:: ``bind_Imported_External_Target``
#  .. _bind_Imported_External_Target:
#
#  bind_Imported_External_Target
#  -----------------------------
#
#   .. command:: bind_Imported_External_Target(package component dep_package dep_component mode)
#
#   Bind a native imported target with an external target.
#
#     :package: the name of the native package that contains the component whose target depends on another imported external target.
#     :component: the name of the native component whose target depends on another imported target.
#     :dep_package: the name of the external package that contains the dependency.
#     :dep_component: the name of the external component that IS the dependency.
#     :mode: the build mode for the targets.
#
function(bind_Imported_External_Target package component dep_package dep_component mode)
get_Mode_Variables(TARGET_SUFFIX VAR_SUFFIX ${mode})

rename_If_Alias(comp_name_to_use ${package} FALSE ${component} Release)
rename_If_Alias(dep_name_to_use ${dep_package} TRUE ${dep_component} ${mode})
export_External_Component_Resolving_Alias(IS_EXPORTING ${package} ${comp_name_to_use} ${component} ${dep_package} ${dep_name_to_use} ${dep_component} ${mode})

if(IS_EXPORTING)
	set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
		INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_INCLUDE_DIRECTORIES>
	)
	set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
		INTERFACE_COMPILE_DEFINITIONS $<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_COMPILE_DEFINITIONS>
	)
	set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
		INTERFACE_COMPILE_OPTIONS $<TARGET_PROPERTY:${dep_package}_${dep_name_to_use}${TARGET_SUFFIX},INTERFACE_COMPILE_OPTIONS>
	)
	set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
		INTERFACE_LINK_LIBRARIES ${dep_package}_${dep_name_to_use}${TARGET_SUFFIX}
	)
else()
  if(${package}_${comp_name_to_use}_TYPE STREQUAL "SHARED")
    set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
      IMPORTED_LINK_DEPENDENT_LIBRARIES ${dep_package}_${dep_name_to_use}${TARGET_SUFFIX}
    )
  else()#static OR header lib always export links
		set_property(TARGET ${package}_${comp_name_to_use}${TARGET_SUFFIX} APPEND PROPERTY
			INTERFACE_LINK_LIBRARIES ${dep_package}_${dep_name_to_use}${TARGET_SUFFIX}
		)
	endif()
endif()#exporting the linked libraries in any case

# set adequately language standard for component depending on the value of dep_component
resolve_Component_Standard_For_Dependency(${package} ${comp_name_to_use} ${dep_package} ${dep_name_to_use} ${mode} FALSE)
endfunction(bind_Imported_External_Target)

#

#.rst:
#
# .. ifmode:: internal
#
#  .. |fill_Component_Target_With_Dependency| replace:: ``fill_Component_Target_With_Dependency``
#  .. _fill_Component_Target_With_Dependency:
#
#  fill_Component_Target_With_Dependency
#  -------------------------------------
#
#   .. command:: fill_Component_Target_With_Dependency(component dep_package dep_component mode export comp_defs comp_exp_defs dep_defs)
#
#   Fill a component's target of the package currently built with information coming from another component (from same or another package). Subsidiary function that perform adeqaute actions depending on the package containing the dependency.
#
#     :component: the name of the component whose target depends on another component.
#     :dep_package: the name of the package that contains the dependency.
#     :dep_component: the name of the component that IS the dependency.
#     :mode: the build mode for the targets.
#     :export: if TRUE then set component's target export dep_component's target.
#     :comp_defs: the preprocessor definitions defined in component implementation that conditionate the use of dep_component.
#     :comp_exp_defs: the preprocessor definitions defined in component interface that conditionate the use of dep_component.
#     :dep_defs: the preprocessor definitions used in dep_component interface that are defined by dep_component.
#
function (fill_Component_Target_With_Dependency component dep_package dep_component mode export comp_defs comp_exp_defs dep_defs)
if(PROJECT_NAME STREQUAL ${dep_package})#target already created elsewhere since internal target
	bind_Internal_Target(${component} ${dep_component} ${mode} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
else()# it is a dependency to another package
	create_Dependency_Target(${dep_package} ${dep_component} ${mode})
	bind_Target(${component} FALSE ${dep_package} ${dep_component} ${mode} ${export} "${comp_defs}" "${comp_exp_defs}" "${dep_defs}")
endif()
endfunction(fill_Component_Target_With_Dependency)

function(get_Windows_Link_Interface result link)
	string(REPLACE "/bin/" "/lib/" interface_link_path ${link})
	string(REPLACE ".dll" ".lib" interface_link_path ${interface_link_path})
	set(${result} ${interface_link_path} PARENT_SCOPE)
endfunction(get_Windows_Link_Interface)
