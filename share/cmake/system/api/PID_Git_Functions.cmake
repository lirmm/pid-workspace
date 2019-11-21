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
if(PID_GIT_FUNCTIONS_INCLUDED)
  return()
endif()
set(PID_GIT_FUNCTIONS_INCLUDED TRUE)
##########################################################################################


######################################################################
############# function related to git tool configuration #############
######################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |configure_Git| replace:: ``configure_Git``
#  .. _configure_Git:
#
#  configure_Git
#  -------------
#
#   .. command:: configure_Git()
#
#      Check that git is well configured and memorize the version of the git tool used.
#
function(configure_Git)
execute_process(COMMAND git --version
                OUTPUT_VARIABLE version_string
                WORKING_DIRECTORY ${WORKSPACE_DIR})
string(REGEX REPLACE "^[^0-9]*([0-9]+\\.[0-9]+\\.[0-9]+).*$" "\\1" VERSION ${version_string})
if(VERSION STREQUAL version_string)
	message("[PID] WARNING : cannot determine version of git")
	set(GIT_VERSION CACHE INTERNAL "")
else()
	set(GIT_VERSION ${VERSION} CACHE INTERNAL "")
endif()
#now check that git is configured
execute_process(COMMAND git config --get user.name OUTPUT_VARIABLE username
                WORKING_DIRECTORY ${WORKSPACE_DIR})
execute_process(COMMAND git config --get user.email OUTPUT_VARIABLE usermail
                WORKING_DIRECTORY ${WORKSPACE_DIR})
set(GIT_CONFIGURED TRUE CACHE INTERNAL "")
if(NOT username OR NOT usermail)
  set(GIT_CONFIGURED FALSE CACHE INTERNAL "")
endif()
endfunction(configure_Git)

#.rst:
#
# .. ifmode:: internal
#
#  .. |git_Provides_GETURL| replace:: ``git_Provides_GETURL``
#  .. git_Provides_GETURL:
#
#  git_Provides_GETURL
#  -------------------
#
#   .. command:: git_Provides_GETURL( RESULT )
#
#      Tells wether the git tool used provides the geturl command.
#
#      :RESULT: The boolean variable that will be set to TRUE if git provides the geturl command, FALSE otherwise.
#
function(git_Provides_GETURL RESULT)

if(GIT_VERSION AND NOT (GIT_VERSION VERSION_LESS 2.7.0))
	set(${RESULT} TRUE PARENT_SCOPE)
else()
	set(${RESULT} FALSE PARENT_SCOPE)
endif()
endfunction(git_Provides_GETURL)

######################################################################
############# function used to navigate between branches #############
######################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |prepare_Repository_Context_Switch| replace:: ``prepare_Repository_Context_Switch``
#  .. _prepare_Repository_Context_Switch:
#
#  prepare_Repository_Context_Switch
#  ---------------------------------
#
#   .. command:: prepare_Repository_Context_Switch(package)
#
#     Clean the git repository, which must be done before any git context switch (i.e. checkout).
#
#     :package: The target source package whose repository is cleaned
#
function(prepare_Repository_Context_Switch package)
execute_process(
    COMMAND git reset --hard # remove any change applied to the previous repository state
		COMMAND git clean -ff -d # remove unstracked files
    WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
    OUTPUT_QUIET ERROR_QUIET)#this is a mandatory step due to the generation of versionned files in source dir when build takes place (this should let the repository in same state as initially)
endfunction(prepare_Repository_Context_Switch)

#.rst:
#
# .. ifmode:: internal
#
#  .. |checkout_To_Commit| replace:: ``checkout_To_Commit``
#  .. _checkout_To_Commit:
#
#  checkout_To_Commit
#  ------------------
#
#   .. command:: checkout_To_Commit(repo commit)
#
#     Checkout to the given commit in the target git repository.
#
#     :repo: The filesystem path to the target repository
#
#     :commit: the commit to go to
#
function(checkout_To_Commit repo commit)
  execute_process(COMMAND git checkout ${commit}
                  WORKING_DIRECTORY ${repo}
		              OUTPUT_QUIET ERROR_QUIET)
endfunction(checkout_To_Commit)

#.rst:
#
# .. ifmode:: internal
#
#  .. |go_To_Commit| replace:: ``go_To_Commit``
#  .. _go_To_Commit:
#
#  go_To_Commit
#  ------------
#
#   .. command:: go_To_Commit(package commit_or_branch)
#
#     Checkout to the integration branch of the target source package.
#
#     :package: The target source package
#
#     :commit_or_branch: The target commit to go to
#
function(go_To_Commit package commit_or_branch)
  prepare_Repository_Context_Switch(${package})
  checkout_To_Commit(${WORKSPACE_DIR}/packages/${package} ${commit_or_branch})
endfunction(go_To_Commit)

#.rst:
#
# .. ifmode:: internal
#
#  .. |go_To_Integration| replace:: ``go_To_Integration``
#  .. _go_To_Integration:
#
#  go_To_Integration
#  -----------------
#
#   .. command:: go_To_Integration(package)
#
#     Checkout to the integration branch of the target source package.
#
#     :package: The target source package
#
function(go_To_Integration package)
  go_To_Commit(${package} integration)
endfunction(go_To_Integration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |go_To_Master| replace:: ``go_To_Master``
#  .. _go_To_Master:
#
#  go_To_Master
#  -----------------
#
#   .. command:: go_To_Master(package)
#
#     Checkout to the master branch of the target source package.
#
#     :package: The target source package
#
function(go_To_Master package)
  go_To_Commit(${package} master)
endfunction(go_To_Master)

#.rst:
#
# .. ifmode:: internal
#
#  .. |go_To_Workspace_Master| replace:: ``go_To_Workspace_Master``
#  .. _go_To_Workspace_Master:
#
#  go_To_Workspace_Master
#  ----------------------
#
#   .. command:: go_To_Workspace_Master()
#
#     Checkout to the master branch of the PID workspace.
#
function(go_To_Workspace_Master)
  checkout_To_Commit(${WORKSPACE_DIR} master)
endfunction(go_To_Workspace_Master)

#.rst:
#
# .. ifmode:: internal
#
#  .. |go_To_Workspace_Development| replace:: ``go_To_Workspace_Development``
#  .. _go_To_Workspace_Development:
#
#  go_To_Workspace_Development
#  ---------------------------
#
#   .. command:: go_To_Workspace_Development()
#
#     Checkout to the development branch of the PID workspace.
#
function(go_To_Workspace_Development)
  checkout_To_Commit(${WORKSPACE_DIR} development)
endfunction(go_To_Workspace_Development)

#.rst:
#
# .. ifmode:: internal
#
#  .. |go_To_Version| replace:: ``go_To_Version``
#  .. _go_To_Version:
#
#  go_To_Version
#  -------------
#
#   .. command:: go_To_Version(package version)
#
#     Checkout to the target version commit of a package.
#
#     :package: The target source package
#
#     :version: the target version
#
function(go_To_Version package version)
  go_To_Commit(${package} tags/v${version})
endfunction(go_To_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Repository_Version_Tags| replace:: ``get_Repository_Version_Tags``
#  .. _get_Repository_Version_Tags:
#
#  get_Repository_Version_Tags
#  ---------------------------
#
#   .. command:: get_Repository_Version_Tags(AVAILABLE_VERSION package)
#
#     Get all version tags of a package.
#
#     :package: The target source package
#
#     :AVAILABLE_VERSIONS: the variable that contains the list of all tagged versions
#
function(get_Repository_Version_Tags AVAILABLE_VERSIONS package)
set(${AVAILABLE_VERSIONS} PARENT_SCOPE)
get_Package_Type(${package} PACK_TYPE)
if(PACK_TYPE STREQUAL "NATIVE")
  if(EXISTS ${WORKSPACE_DIR}/packages/${package})
    execute_process(COMMAND git tag -l v*
      WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
      OUTPUT_VARIABLE res)
  endif()
elseif(PACK_TYPE STREQUAL "EXTERNAL")
  if(EXISTS ${WORKSPACE_DIR}/wrappers/${package})
    execute_process(COMMAND git tag -l v*
      WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${package}
      OUTPUT_VARIABLE res)
  endif()
endif()

if(NOT res) #no version available => BUG
	return()
endif()
string(REPLACE "\n" ";" GIT_VERSIONS ${res})
set(${AVAILABLE_VERSIONS} ${GIT_VERSIONS} PARENT_SCOPE)
endfunction(get_Repository_Version_Tags)

#.rst:
#
# .. ifmode:: internal
#
#  .. |normalize_Version_Tags| replace:: ``normalize_Version_Tags``
#  .. _normalize_Version_Tags:
#
#  normalize_Version_Tags
#  ----------------------
#
#   .. command:: normalize_Version_Tags(AVAILABLE_VERSION package)
#
#     Get all version tags of a package.
#
#     :package: The target source package
#
#     :AVAILABLE_VERSIONS: the output variable that contains the list of all tagged versions
#
function(normalize_Version_Tags VERSION_NUMBERS VERSIONS_TAGS)
foreach(tag IN LISTS VERSIONS_TAGS)
	string(REGEX REPLACE "^v(.*)$" "\\1" VNUMBERS ${tag})
	list(APPEND result ${VNUMBERS})
endforeach()
set(${VERSION_NUMBERS} ${result} PARENT_SCOPE)
endfunction(normalize_Version_Tags)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Repository_Current_Branch| replace:: ``get_Repository_Current_Branch``
#  .. _get_Repository_Current_Branch:
#
#  get_Repository_Current_Branch
#  -----------------------------
#
#   .. command:: get_Repository_Current_Branch(BRANCH_NAME repo)
#
#     Get the current branch of a git repository.
#
#     :repo: the path to the repository on filesystem
#
#     :BRANCH_NAME: the output variable that contains the current branch name
#
function(get_Repository_Current_Branch BRANCH_NAME repo)
set(${BRANCH_NAME} PARENT_SCOPE)
execute_process(COMMAND git rev-parse --abbrev-ref HEAD
		WORKING_DIRECTORY ${repo}
		OUTPUT_VARIABLE current_branch ERROR_QUIET)
if(current_branch AND NOT current_branch MATCHES "HEAD")
	string(REGEX REPLACE "^[ \t\n]*([^ \t\n]+)[ \t\n]*$" "\\1" RES_BRANCH ${current_branch})
	set(${BRANCH_NAME} ${RES_BRANCH} PARENT_SCOPE)
endif()
endfunction(get_Repository_Current_Branch)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Repository_Current_Commit| replace:: ``get_Repository_Current_Commit``
#  .. _get_Repository_Current_Commit:
#
#  get_Repository_Current_Commit
#  -----------------------------
#
#   .. command:: get_Repository_Current_Commit(COMMIT_NAME repo)
#
#     Get the current commit of a git repository.
#
#     :repo: the path to the repository on filesystem
#
#     :COMMIT_NAME: the output variable that contains the current commit id
#
function(get_Repository_Current_Commit COMMIT_NAME repo)
set(${COMMIT_NAME} PARENT_SCOPE)
execute_process(COMMAND git log --oneline -n 1
		WORKING_DIRECTORY ${repo}
		OUTPUT_VARIABLE last_log ERROR_QUIET)
set(SHA1_ID)
string(REGEX REPLACE "^([^ \t]+)[ \t].*$" "\\1" SHA1_ID ${last_log})
set(${COMMIT_NAME} ${SHA1_ID} PARENT_SCOPE)
endfunction(get_Repository_Current_Commit)

#.rst:
#
# .. ifmode:: internal
#
#  .. |save_Repository_Context| replace:: ``save_Repository_Context``
#  .. _save_Repository_Context:
#
#  save_Repository_Context
#  -----------------------
#
#   .. command:: save_Repository_Context(INITIAL_COMMIT SAVED_CONTENT package)
#
#     Save and clean the current state of a package's repository.
#
#     :package: the name of target package  name
#
#     :INITIAL_COMMIT: the output variable that contains the current commit id
#
#     :SAVED_CONTENT: the output variable that is TRUE if some content has ben stashed, false otherwise
#
function(save_Repository_Context INITIAL_COMMIT SAVED_CONTENT package)
get_Repository_Current_Branch(BRANCH_NAME ${WORKSPACE_DIR}/packages/${package})
if(NOT BRANCH_NAME)
  set(COMMIT_ID)
	get_Repository_Current_Commit(COMMIT_ID ${WORKSPACE_DIR}/packages/${package})
	set(CONTEXT ${COMMIT_ID})
else()
	set(CONTEXT ${BRANCH_NAME})
endif()
set(${INITIAL_COMMIT} ${CONTEXT} PARENT_SCOPE)
has_Modifications(RESULT ${package})
if(RESULT)
	execute_process(COMMAND git stash save --include-untracked --keep-index
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                  OUTPUT_QUIET ERROR_QUIET)
	set(${SAVED_CONTENT} TRUE PARENT_SCOPE)
else()
	set(${SAVED_CONTENT} FALSE PARENT_SCOPE)
endif()
endfunction(save_Repository_Context)

#.rst:
#
# .. ifmode:: internal
#
#  .. |restore_Repository_Context| replace:: ``restore_Repository_Context``
#  .. _restore_Repository_Context:
#
#  restore_Repository_Context
#  --------------------------
#
#   .. command:: restore_Repository_Context(package initial_commit saved_content)
#
#     Restore the previous state of a package's repository.
#
#     :package:  the name of target package  name
#
#     :initial_commit: the id of the commit to checkout to
#
#     :saved_content: if TRUE then stashed content will be pop
#
function(restore_Repository_Context package initial_commit saved_content)
  prepare_Repository_Context_Switch(${package})
  checkout_To_Commit(${WORKSPACE_DIR}/packages/${package} ${initial_commit})
  if(saved_content)
  	execute_process(COMMAND git stash pop --index
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                    OUTPUT_QUIET ERROR_QUIET)
  endif()
endfunction(restore_Repository_Context)

#.rst:
#
# .. ifmode:: internal
#
#  .. |save_Workspace_Repository_Context| replace:: ``save_Workspace_Repository_Context``
#  .. _save_Workspace_Repository_Context:
#
#  save_Workspace_Repository_Context
#  ---------------------------------
#
#   .. command:: save_Workspace_Repository_Context(INITIAL_COMMIT SAVED_CONTENT))
#
#     Save and clean the current state of the workspace.
#
#     :INITIAL_COMMIT: the output variable that contains the current commit id of the workspace
#
#     :SAVED_CONTENT: the output variable that is TRUE if some content in workspace has ben stashed, false otherwise
#
function(save_Workspace_Repository_Context INITIAL_COMMIT SAVED_CONTENT)
get_Repository_Current_Branch(BRANCH_NAME ${WORKSPACE_DIR})
if(NOT BRANCH_NAME)
	get_Repository_Current_Commit(COMMIT_NAME ${WORKSPACE_DIR})
	set(CONTEXT ${COMMIT_NAME})
else()
	set(CONTEXT ${BRANCH_NAME})
endif()
set(${INITIAL_COMMIT} ${CONTEXT} PARENT_SCOPE)
execute_process(COMMAND git status --porcelain
                WORKING_DIRECTORY ${WORKSPACE_DIR}
                OUTPUT_VARIABLE res_out ERROR_QUIET)
if(NOT res_out)# no modification to stage or commit
	set(${SAVED_CONTENT} FALSE PARENT_SCOPE)
else()
	execute_process(COMMAND git stash save --include-untracked
                  WORKING_DIRECTORY ${WORKSPACE_DIR}
                  OUTPUT_QUIET ERROR_QUIET)
	set(${SAVED_CONTENT} TRUE PARENT_SCOPE)
endif()
endfunction(save_Workspace_Repository_Context)

#.rst:
#
# .. ifmode:: internal
#
#  .. |restore_Workspace_Repository_Context| replace:: ``restore_Workspace_Repository_Context``
#  .. _restore_Workspace_Repository_Context:
#
#  restore_Workspace_Repository_Context
#  ------------------------------------
#
#   .. command:: restore_Workspace_Repository_Context(initial_commit saved_content)
#
#     Restore the previous state of the workspace's repository.
#
#     :initial_commit: the id of the commit to checkout to
#
#     :saved_content: if TRUE then stashed content will be pop
#
function(restore_Workspace_Repository_Context initial_commit saved_content)
checkout_To_Commit(${WORKSPACE_DIR} ${initial_commit})
if(saved_content)
	execute_process(COMMAND git stash pop
                  WORKING_DIRECTORY ${WORKSPACE_DIR}
                  OUTPUT_QUIET ERROR_QUIET)
endif()
endfunction(restore_Workspace_Repository_Context)

######################################################################
############# function used to merge standard branches ###############
######################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |merge_Into_Master| replace:: ``merge_Into_Master``
#  .. _merge_Into_Master:
#
#  merge_Into_Master
#  -----------------
#
#   .. command:: merge_Into_Master(RESULT package branch version_string)
#
#     Merge the integration branch of a package into its master branch, then tag the current commit on master with a new version.
#
#     :package: the name of target package
#
#     :branch: the name of the branch merged
#
#     :version_string: the new version to tag
#
#     :RESULT: the ouuput variable that is set to TRUE if merge succeeded, FALSE otherwise
#
function(merge_Into_Master RESULT package branch version_string)
go_To_Master(${package})
execute_process(COMMAND git merge --ff-only ${branch}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                RESULT_VARIABLE res OUTPUT_QUIET ERROR_QUIET)
if(NOT res EQUAL 0)
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
endif()
set(${RESULT} TRUE PARENT_SCOPE)
endfunction(merge_Into_Master)

#.rst:
#
# .. ifmode:: internal
#
#  .. |tag_Version| replace:: ``tag_Version``
#  .. _tag_Version:
#
#  tag_Version
#  -----------
#
#   .. command:: tag_Version(package version_string)
#
#     Tag the given package repository with given version..
#
#     :package: the name of target package
#
#     :version_string: the new version to tag
#
#     :add_it: if TRUE the tag is added, removed otherwise
#
function(tag_Version package version_string add_it)
  get_Package_Type(${package} PACK_TYPE)
  if(PACK_TYPE STREQUAL "NATIVE")
    set(path_element "packages")
    set(tag_message "releasing version ${version_string}")
  elseif(PACK_TYPE STREQUAL "EXTERNAL")
    set(path_element "wrappers")
    set(tag_message "memorizing version ${version_string}")
  else()
    return()
  endif()

  if(add_it)
    execute_process(COMMAND git tag -a v${version_string} -m "${tag_message}"
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/${path_element}/${package})
  else()
    execute_process(COMMAND git tag -d v${version_string}
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/${path_element}/${package})
  endif()
endfunction(tag_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |merge_Into_Integration| replace:: ``merge_Into_Integration``
#  .. _merge_Into_Integration:
#
#  merge_Into_Integration
#  ----------------------
#
#   .. command:: merge_Into_Integration(package)
#
#     Merge the master branch of a package into its integration branch.
#
#     :package: the name of target package
#
function(merge_Into_Integration package)
go_To_Integration(${package})
execute_process(COMMAND git merge --ff-only master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
endfunction(merge_Into_Integration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |integrate_Branch| replace:: ``integrate_Branch``
#  .. _integrate_Branch:
#
#  integrate_Branch
#  ----------------
#
#   .. command:: integrate_Branch(package branch)
#
#     Merge the target branch of a package into its current branch.
#
#     :package: the name of target package
#
#     :branch: the branch to merge
#
function(integrate_Branch package branch)
execute_process(COMMAND git merge ${branch}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                OUTPUT_QUIET ERROR_QUIET)
endfunction(integrate_Branch)

#.rst:
#
# .. ifmode:: internal
#
#  .. |commit_Current_Repository_Branch| replace:: ``commit_Current_Repository_Branch``
#  .. _commit_Current_Repository_Branch:
#
#  commit_Current_Repository_Branch
#  --------------------------------
#
#   .. command:: commit_Current_Repository_Branch(package commit_message)
#
#     Commit all modifications inside a package's repository.
#
#     :package: the name of target package
#
#     :commit_message: the commit message
#
function(commit_Current_Repository_Branch package commit_message)
execute_process(COMMAND git add --all
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
execute_process(COMMAND git commit -m "${commit_message}"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
endfunction(commit_Current_Repository_Branch)

#.rst:
#
# .. ifmode:: internal
#
#  .. |register_Repository_Address| replace:: ``register_Repository_Address``
#  .. _register_Repository_Address:
#
#  register_Repository_Address
#  ---------------------------
#
#   .. command:: register_Repository_Address(package)
#
#     Create a commit after update of the package repository address in its CMakeLists.txt.
#
#     :package: the name of target package
#
function(register_Repository_Address package)
execute_process(COMMAND git add CMakeLists.txt
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}) ### registering the address means registering the CMakelists.txt
execute_process(COMMAND git commit -m "adding repository address to the root CMakeLists.txt file"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
endfunction(register_Repository_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |register_Repository_Version| replace:: ``register_Repository_Version``
#  .. _register_Repository_Version:
#
#  register_Repository_Version
#  ---------------------------
#
#   .. command:: register_Repository_Version(package version_string)
#
#     Create a commit after update of the package version in its CMakeLists.txt.
#
#     :package: the name of target package
#
function(register_Repository_Version package version_string)
execute_process(COMMAND git add CMakeLists.txt
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
execute_process(COMMAND git commit -m "[skip ci] start new version ${version_string}"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
endfunction(register_Repository_Version)

#############################################################################
############# function used to publish/update modifications   ###############
#############################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Package_References_In_Workspace_Repository| replace:: ``publish_Package_References_In_Workspace_Repository``
#  .. _publish_Package_References_In_Workspace_Repository:
#
#  publish_Package_References_In_Workspace_Repository
#  --------------------------------------------------
#
#   .. command:: publish_Package_References_In_Workspace_Repository(package)
#
#     Commit and push cmake script files (find and reference) used to reference a package.
#
#     :package: the name of target package
#
function(publish_Package_References_In_Workspace_Repository package)
if(EXISTS ${WORKSPACE_DIR}/share/cmake/find/Find${package}.cmake AND EXISTS ${WORKSPACE_DIR}/share/cmake/references/Refer${package}.cmake)
	execute_process(COMMAND git add share/cmake/find/Find${package}.cmake
                  WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND git add share/cmake/references/Refer${package}.cmake
                  WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND git commit -m "${package} registered"
                  WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND git push origin master
                  WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
else()
	message("[PID] ERROR : problem registering package ${package}, cannot find adequate cmake files in workspace.")
endif()
endfunction(publish_Package_References_In_Workspace_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Wrapper_References_In_Workspace_Repository| replace:: ``publish_Wrapper_References_In_Workspace_Repository``
#  .. _publish_Wrapper_References_In_Workspace_Repository:
#
#  publish_Wrapper_References_In_Workspace_Repository
#  --------------------------------------------------
#
#   .. command:: publish_Wrapper_References_In_Workspace_Repository(wrapper)
#
#     Commit and push cmake script files (find and reference) used to reference an external package.
#
#     :wrapper: the name of external package wrapper to use.
#
function(publish_Wrapper_References_In_Workspace_Repository wrapper)
  if(EXISTS ${WORKSPACE_DIR}/share/cmake/find/Find${wrapper}.cmake
  AND EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferExternal${wrapper}.cmake)
  	execute_process(COMMAND git add share/cmake/find/Find${wrapper}.cmake
                    WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
  	execute_process(COMMAND git add share/cmake/references/ReferExternal${wrapper}.cmake
                    WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
  	execute_process(COMMAND git commit -m "${wrapper} registered"
                    WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
  	execute_process(COMMAND git push origin master
                    WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
  else()
  	message("[PID] ERROR : problem registering wrapper ${wrapper}, cannot find adequate cmake files in workspace.")
  endif()
endfunction(publish_Wrapper_References_In_Workspace_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Framework_References_In_Workspace_Repository| replace:: ``publish_Framework_References_In_Workspace_Repository``
#  .. _publish_Framework_References_In_Workspace_Repository:
#
#  publish_Framework_References_In_Workspace_Repository
#  ----------------------------------------------------
#
#   .. command:: publish_Framework_References_In_Workspace_Repository(package)
#
#     Commit and push cmake script files (reference) used to reference a framework.
#
#     :framework: the name of target framework
#
function(publish_Framework_References_In_Workspace_Repository framework)
if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferFramework${framework}.cmake)
	execute_process(COMMAND git add share/cmake/references/ReferFramework${framework}.cmake
                  WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND git commit -m "framework ${framework} registered"
                  WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND git push origin master
                  WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
else()
	message("[PID] ERROR : problem registering framework ${framework}, cannot find adequate cmake files in workspace.")
endif()
endfunction(publish_Framework_References_In_Workspace_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Environment_References_In_Workspace_Repository| replace:: ``publish_Environment_References_In_Workspace_Repository``
#  .. _publish_Environment_References_In_Workspace_Repository:
#
#  publish_Environment_References_In_Workspace_Repository
#  ------------------------------------------------------
#
#   .. command:: publish_Environment_References_In_Workspace_Repository(environment)
#
#     Commit and push cmake script files (reference) used to reference a environment.
#
#     :environment: the name of target environment
#
function(publish_Environment_References_In_Workspace_Repository environment)
if(EXISTS ${WORKSPACE_DIR}/share/cmake/references/ReferFramework${environment}.cmake)
	execute_process(COMMAND git add share/cmake/references/ReferEnvironment${environment}.cmake
                  WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND git commit -m "environment ${environment} registered"
                  WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND git push origin master
                  WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)
else()
	message("[PID] ERROR : problem registering environment ${environment}, cannot find adequate cmake files in workspace.")
endif()
endfunction(publish_Environment_References_In_Workspace_Repository)



#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Workspace_Repository| replace:: ``update_Workspace_Repository``
#  .. _update_Workspace_Repository:
#
#  update_Workspace_Repository
#  ---------------------------
#
#   .. command:: update_Workspace_Repository(remote)
#
#     Pull the history of target git remote's master branch.
#
#     :remote: the target git remote
#
function(update_Workspace_Repository remote)
go_To_Workspace_Master()
execute_process(COMMAND git pull ${remote} master
                WORKING_DIRECTORY ${WORKSPACE_DIR} OUTPUT_QUIET ERROR_QUIET)#pulling master branch of origin or official
endfunction(update_Workspace_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Repository_Integration| replace:: ``publish_Repository_Integration``
#  .. _publish_Repository_Integration:
#
#  publish_Repository_Integration
#  ------------------------------
#
#   .. command:: publish_Repository_Integration(package)
#
#     Push the integration of a package.
#
#     :package: the name of target package
#
function(publish_Repository_Integration package)
go_To_Integration(${package})
execute_process(COMMAND git push origin integration
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)#try pushing on integration branch

#now testing if everything is OK using the git log command
execute_process(COMMAND git log --oneline --decorate --max-count=1
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} ERROR_QUIET OUTPUT_VARIABLE res)
if (NOT "${res}" STREQUAL "")
	string(FIND "${res}" "integration" INDEX_LOCAL)
	string(FIND "${res}" "origin/integration" INDEX_REMOTE)
	if(INDEX_LOCAL GREATER 0 AND INDEX_REMOTE GREATER 0)# both found => the last commit on integration branch is tracked by local and remote integration branches
		return()
	else()
		message("[PID] WARNING : problem updating package ${package} integration branch on its origin remote. Maybe due to a conflict between local and origin integration branches.")
	endif()
endif()
endfunction(publish_Repository_Integration)

#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Package_Temporary_Branch| replace:: ``publish_Package_Temporary_Branch``
#  .. _publish_Package_Temporary_Branch:
#
#  publish_Package_Temporary_Branch
#  --------------------------------
#
#   .. command:: publish_Package_Temporary_Branch(PUBLISH_OK package branch)
#
#     Push a temporary branch of a package.
#
#     :package: the name of target package
#
#     :branch: the name of branch to push to official repository
#
#     :PUBLISH_OK: the output variable that is TRUE is push succeeded, FALSE otherwise
#
function(publish_Package_Temporary_Branch PUBLISH_OK package branch)
execute_process(COMMAND git push --porcelain official ${branch}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                OUTPUT_VARIABLE out ERROR_QUIET)#try pushing on branch
if(out MATCHES "^.*rejected.*$")
	set(${PUBLISH_OK} FALSE PARENT_SCOPE)
	return()
endif()
set(${PUBLISH_OK} TRUE PARENT_SCOPE)
endfunction(publish_Package_Temporary_Branch)


#.rst:
#
# .. ifmode:: internal
#
#  .. |delete_Package_Temporary_Branch| replace:: ``delete_Package_Temporary_Branch``
#  .. _delete_Package_Temporary_Branch:
#
#  delete_Package_Temporary_Branch
#  -------------------------------
#
#   .. command:: delete_Package_Temporary_Branch(package branch)
#
#     Delete a temporary branch of a package official remote.
#
#     :package: the name of target package
#
#     :branch: the name of branch to delete from official repository
#
function(delete_Package_Temporary_Branch package branch)
execute_process(COMMAND git push --delete official ${branch}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                OUTPUT_QUIET ERROR_QUIET)#try pushing on branch
endfunction(delete_Package_Temporary_Branch)

#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Repository_Master| replace:: ``publish_Repository_Master``
#  .. _publish_Repository_Master:
#
#  publish_Repository_Master
#  -------------------------
#
#   .. command:: publish_Repository_Master(RESULT_OK package)
#
#     Publish an update to the master branch of a package official remote.
#
#     :package: the name of target package
#
#     :RESULT_OK: the output variable that is TRUE if official remote master branch has been updated, FALSE otherwise
#
function(publish_Repository_Master RESULT_OK package)
set(${RESULT_OK} FALSE PARENT_SCOPE)
go_To_Master(${package})
execute_process(COMMAND git push --porcelain official master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                OUTPUT_VARIABLE out ERROR_QUIET)#releasing on master branch of official
if(out MATCHES "^.*rejected.*$")
	return()
endif()

#now testing if everything is OK using the git log command
execute_process(COMMAND git log --oneline --decorate --max-count=1
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                OUTPUT_VARIABLE res ERROR_QUIET)
if (NOT "${res}" STREQUAL "")
	string(FIND "${res}" "master" INDEX_LOCAL)
	string(FIND "${res}" "official/master" INDEX_REMOTE)
	if(INDEX_LOCAL GREATER 0 AND INDEX_REMOTE GREATER 0)# both found => the last commit on master branch is tracked by local and remote master branch
		set(${RESULT_OK} TRUE PARENT_SCOPE)
	endif()
endif()

endfunction(publish_Repository_Master)


#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Repository_Version| replace:: ``publish_Repository_Version``
#  .. _publish_Repository_Version:
#
#  publish_Repository_Version
#  --------------------------
#
#   .. command:: publish_Repository_Version(RESULT package version_string)
#
#     Publish a new version on a package official repository.
#
#     :package: the name of target package
#
#     :version_string: the version to push
#
#     :RESULT: the output variable that is TRUE if official remote has been update with new version tag, FALSE otherwise
#
function(publish_Repository_Version RESULT package version_string)
execute_process(COMMAND git push --porcelain official v${version_string}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                OUTPUT_VARIABLE out ERROR_QUIET)#releasing on master branch of official
if(out MATCHES "^.*rejected.*$")
  set(${RESULT} FALSE PARENT_SCOPE)
	return()
endif()
set(${RESULT} TRUE PARENT_SCOPE)
endfunction(publish_Repository_Version)

#.rst:
#
# .. ifmode:: internal
#
#  .. |test_Remote_Connection| replace:: ``test_Remote_Connection``
#  .. _test_Remote_Connection:
#
#  test_Remote_Connection
#  ----------------------
#
#   .. command:: test_Remote_Connection(CONNECTED package remote)
#
#     Test if a package (native or external wrapper) is trully connected to a given remote.
#
#     :package: the name of target package
#
#     :remote: the name of the target remote (origin or official)
#
#     :CONNECTED: the output variable that is TRUE if package connected to the target remote, FALSE otherwise
#
function(test_Remote_Connection CONNECTED package remote)
get_Package_Type(${package} PACK_TYPE)
if(PACK_TYPE STREQUAL "NATIVE")
  execute_process(COMMAND git remote show ${remote}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                  OUTPUT_QUIET ERROR_QUIET RESULT_VARIABLE res)
elseif(PACK_TYPE STREQUAL "EXTERNAL")
  execute_process(COMMAND git remote show ${remote}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${package}
                  OUTPUT_QUIET ERROR_QUIET RESULT_VARIABLE res)
else()
  set(res 0)
endif()
if(res EQUAL 0)
	set(${CONNECTED} TRUE PARENT_SCOPE)
else()
	set(${CONNECTED} FALSE PARENT_SCOPE)
endif()
endfunction(test_Remote_Connection)

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Repository_Versions| replace:: ``update_Repository_Versions``
#  .. _update_Repository_Versions:
#
#  update_Repository_Versions
#  --------------------------
#
#   .. command:: update_Repository_Versions(CONNECTED package remote)
#
#     Update local package's repository known versions.
#
#     :package: the name of target package
#
#     :RESULT: the output variable that is TRUE if package versions are up to date, FALSE otherwise
#
function(update_Repository_Versions RESULT package)
go_To_Master(${package})
adjust_Official_Remote_Address(OFFICIAL_CONNECTED ${package} TRUE)
if(NOT OFFICIAL_CONNECTED)
  message("[PID] WARNING : cannot get connection with official remote (see previous outputs). Aborting ${package} update !")
	set(${RESULT} TRUE PARENT_SCOPE) #this is not an error since no official defined
	return()
endif()
execute_process(COMMAND git fetch official --tags
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                OUTPUT_QUIET ERROR_QUIET)#getting new tags
execute_process(COMMAND git pull --ff-only official master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                RESULT_VARIABLE res OUTPUT_QUIET ERROR_QUIET)#pulling master branch of official
if(NOT res EQUAL 0)#not a fast forward !! => there is a problem
	message("[PID] WARNING : local package ${package} master branch and corresponding branch in official repository have diverge ! If you committed no modification to the local master branch (use gitk or git log to see that), ask to the administrator of this repository to solve the problem !")
	set(${RESULT} FALSE PARENT_SCOPE)
	return()
endif()
set(${RESULT} TRUE PARENT_SCOPE)
endfunction(update_Repository_Versions)

#.rst:
#
# .. ifmode:: internal
#
#  .. |adjust_Official_Remote_Address| replace:: ``adjust_Official_Remote_Address``
#  .. _adjust_Official_Remote_Address:
#
#  adjust_Official_Remote_Address
#  ------------------------------
#
#   .. command:: adjust_Official_Remote_Address(OFFICIAL_REMOTE_CONNECTED package verbose)
#
#     Check connection to remote VS official remote address specified in package description. If they differ, performs corrective actions.
#
#     :package: the name of the package.
#
#     :git_url: the url of the package's official repository.
#
function(adjust_Official_Remote_Address OFFICIAL_REMOTE_CONNECTED package verbose)
set(${OFFICIAL_REMOTE_CONNECTED} TRUE PARENT_SCOPE)
is_Package_Connected(CONNECTED ${package} official) #check if the package has a repository URL defined (fetch)
get_Package_Repository_Address(${package} URL PUBLIC_URL) #get addresses of official remote from package description
if(NOT CONNECTED)#no official remote (due to old package style or due to a misuse of git command within a package)
  if(URL)#the package has an official repository declared
    connect_Repository_Remote(${package} ${URL} "${PUBLIC_URL}" official)
    test_Remote_Connection(CONNECTED ${package} official) #test again connection

    if(NOT CONNECTED)#remote currently in use is a bad one (migration took place and for any reason the official remote has been deleted)
      get_Package_Reference_Info(${package} REF_FILE_EXISTS REF_ADDR REF_PUB_ADDR)
			if(NOT REF_FILE_EXISTS) #reference not found, may mean the package has been removed
        if(verbose)
          message("[PID] WARNING : local package ${package} lost connection with its official remote : no official remote defined, address from its description (${URL}) is no more reachable, and ${package} is not referenced into workspace ! Please check that the package still exists or try upgrading your workspace.")
        endif()
        disconnect_Repository_Remote(${package} official) #remove the remote
        set(${OFFICIAL_REMOTE_CONNECTED} FALSE PARENT_SCOPE) #simply exitting
				return()
			endif()
			#from here the package is known and its reference related variables have been updated
      if(NOT REF_ADDR)#Nothing more to do
        disconnect_Repository_Remote(${package} official) #remove the remote
        if(verbose)
          message("[PID] WARNING : local package ${package} lost connection with its official remote : no official remote defined, address from its description (${URL}) is no more reachable, and ${package} reference defines no official address ! Please check that the package still exists or try upgrading your workspace.")
        endif()
        set(${OFFICIAL_REMOTE_CONNECTED} FALSE PARENT_SCOPE) #simply exitting
				return()
      elseif (REF_PUB_ADDR STREQUAL PUBLIC_URL
				    OR REF_ADDR STREQUAL URL)#OK so no problem detected but cannot interact with the remote repository
        #do not remove the remote as it is supposed to be the good one !
        if(verbose)
          message("[PID] WARNING : local package ${package} lost connection with its official remote : no official remote defined, address from its description (${URL}) is no more reachable ! Please check your network connection.")
        endif()
        set(${OFFICIAL_REMOTE_CONNECTED} FALSE PARENT_SCOPE) #simply exitting
				return()
			else()
        #for now only updating the official remote address so that update can occur
        reconnect_Repository_Remote(${package} ${REF_ADDR} "${REF_PUB_ADDR}" official)
        test_Remote_Connection(CONNECTED ${package} official) #test again connection
        if(NOT CONNECTED)#cannot do mush more, even the referenced address is bad
          if(verbose)
            if(PUBLIC_URL)#the package has a public address where anyone can get it
              message("[PID] WARNING : local package ${package} lost connection with its official remote : no official remote defined, address from its reference (${${package}_PUBLIC_ADDRESS}) is no more reachable ! Please check your network connection.")
            else()
              message("[PID] WARNING : local package ${package} lost connection with its official remote : no official remote defined, address from its reference (${${package}_ADDRESS}) is no more reachable ! Please check your network connection or that you still have rights to clone this package.")
            endif()
          endif()
          set(${OFFICIAL_REMOTE_CONNECTED} FALSE PARENT_SCOPE) #simply exitting
         return()
        endif()
      	# once the update will be done the official address in description should have changed accordingly
			endif()
    endif()
	else() #no official repository and no URL defined for the package => the package has never been connected since last release (normal situation)
		set(${OFFICIAL_REMOTE_CONNECTED} FALSE PARENT_SCOPE)
		return()
	endif()
elseif(URL) # official package is connected and has an official repository declared
	get_Remotes_Address(${package} RES_OFFICIAL_FETCH RES_OFFICIAL_PUSH RES_ORIGIN_FETCH RES_ORIGIN_PUSH)#get the adress of the official and origin git remotes
  if((NOT RES_OFFICIAL_FETCH STREQUAL URL)
      AND (NOT RES_OFFICIAL_FETCH STREQUAL PUBLIC_URL))
      # the address of official is not the same as the one specified in the package description
      # this can be due to a migration of the repository since last release
      test_Remote_Connection(CONNECTED ${package} official)
  		if(NOT CONNECTED)#remote currently in use is a bad one (strange situation, maybe due to a bad command from user)
        #try with declared one
        reconnect_Repository_Remote(${package} ${URL} "${PUBLIC_URL}" official)
        test_Remote_Connection(CONNECTED ${package} official)
        if(NOT CONNECTED)#remote defined by description is also a bad one
          # put again original addresses
          reconnect_Repository_Remote(${package} ${RES_OFFICIAL_PUSH} "${RES_OFFICIAL_FETCH}" official)
          get_Package_Reference_Info(${package} REF_FILE_EXISTS REF_ADDR REF_PUB_ADDR)
    			if(NOT REF_FILE_EXISTS) #reference not found, may mean the package has been removed
            if(verbose)
              message("[PID] WARNING : local package ${package} lost connection with its official remote : an unreachable official remote is defined, address from its description (${URL}) is no more reachable, and ${package} is not referenced into workspace ! Please check that the package still exists or try upgrading your workspace.")
            endif()
            #do not disconnect as the problem may be due to a bad network connection
            set(${OFFICIAL_REMOTE_CONNECTED} FALSE PARENT_SCOPE) #simply exitting
    				return()
    			endif()
    			#from here the package is known and its reference related variables have been updated
          if(NOT REF_ADDR)#no address bound to the package
            if(verbose)
              message("[PID] WARNING : local package ${package} lost connection with its official remote : an unreachable official remote is defined, address from its description (${URL}) is no more reachable, and ${package} reference defines no official address ! Please check that the package still exists or try upgrading your workspace.")
            endif()
            set(${OFFICIAL_REMOTE_CONNECTED} FALSE PARENT_SCOPE) #simply exitting
    				return()
          elseif (REF_PUB_ADDR STREQUAL PUBLIC_URL
    				    OR REF_ADDR STREQUAL URL)#OK so no problem detected but cannot interact with the remote repository
            #do not remove the remote as it is supposed to be the good one !
            if(verbose)
              message("[PID] WARNING : local package ${package} lost connection with its official remote : no official remote defined, address from its description (${URL}) is no more reachable ! Please check your network connection.")
            endif()
            set(${OFFICIAL_REMOTE_CONNECTED} FALSE PARENT_SCOPE) #simply exitting
    				return()
    			else()
            #for now only updating the official remote address so that update can occur
            reconnect_Repository_Remote(${package} ${${package}_ADDRESS} "${${package}_PUBLIC_ADDRESS}" official)
            test_Remote_Connection(CONNECTED ${package} official) #test again connection
            if(NOT CONNECTED)#cannot do mush more, even the referenced address is bad
              reconnect_Repository_Remote(${package} ${RES_OFFICIAL_PUSH} "${RES_OFFICIAL_FETCH}" official)
              if(verbose)
                if(PUBLIC_URL)#the package has a public address where anyone can get it
                  message("[PID] WARNING : local package ${package} lost connection with its official remote : no official remote defined, address from its reference (${${package}_PUBLIC_ADDRESS}) is no more reachable ! Please check your network connection.")
                else()
                  message("[PID] WARNING : local package ${package} lost connection with its official remote : no official remote defined, address from its reference (${${package}_ADDRESS}) is no more reachable ! Please check your network connection or that you still have rights to clone this package.")
                endif()
              endif()
              set(${OFFICIAL_REMOTE_CONNECTED} FALSE PARENT_SCOPE) #simply exitting
             return()
            endif()
          	# once the update will be done the official address in description should have changed accordingly
    			endif()
        endif()
      endif()# else the current official remote in use is OK, so description is bad (migration occurred since last release) !
	else()#package remotes are consistent, but this can be an old version of the package before a migration occurred
    #use the reference file (if any) to deduce if a migration occured
    get_Package_Reference_Info(${package} REF_FILE_EXISTS REF_ADDR REF_PUB_ADDR)
    if(NOT REF_FILE_EXISTS) #reference not found, may mean the package has been removed OR has never been referenced (for instance pid tests packages)
      #simply considering the result is OK since we have no clue
      set(${OFFICIAL_REMOTE_CONNECTED} TRUE PARENT_SCOPE) #simply exitting
      return()
    endif()
    if (REF_PUB_ADDR STREQUAL RES_OFFICIAL_FETCH
        AND REF_ADDR STREQUAL RES_OFFICIAL_PUSH)#OK no change from official => nothing to do
      set(${OFFICIAL_REMOTE_CONNECTED} TRUE PARENT_SCOPE) #simply exitting
      return()
    endif()
    #from here we can deduce that a migration may have occurred for official repository
    #2 possibilities: either the reference is invalid or this is the local package
    test_Remote_Connection(CONNECTED ${package} official)#testing the connection to know if local package is OK
		if(NOT CONNECTED) # if not connected a migration probably occurred OR network connection is lost !!
	    reconnect_Repository_Remote(${package} ${REF_ADDR} "${REF_PUB_ADDR}" official)
      test_Remote_Connection(CONNECTED ${package} official)
      if(NOT CONNECTED) #problem if not connected a migration occurred but has not been referenced OR network connection is lost
        disconnect_Repository_Remote(${package} official) #remove the remote
        reconnect_Repository_Remote(${package} ${RES_OFFICIAL_PUSH} "${RES_OFFICIAL_FETCH}" official)#put back the previous one
        if(verbose)
          message("[PID] WARNING : local package ${package} lost connection with its official remote:\n- either a migration of this package probably occurred but has not been referenced into workspace ! Please check that the package still exists, or try upgrading your workspace to get an up to date reference of this package.\n- or there is currenlty no possible network connection with this package for an unknown reason.")
        endif()
        set(${OFFICIAL_REMOTE_CONNECTED} FALSE PARENT_SCOPE) #simply exitting
        return()
      else()
        if(verbose)
          message("[PID] WARNING : local package ${package} lost connection with its official remote due to a migration of this package official repository ! Official remote address has been automatically changed.")
        endif()
        set(${OFFICIAL_REMOTE_CONNECTED} TRUE PARENT_SCOPE) #simply exitting
      endif()
			# once the update will be done the official address in description should have changed accordingly
    else()#in this situation the local address is good BUT the reference file is supposed to be invalid
      message("[PID] WARNING : local package ${package} is connected with its official remote that is not the same address as the one used in its reference file. Either the reference file is not up to date (solution: upgrade your workspace then relaunch configuration) OR your package is connected to an old repository that is no more the official one (solution: use workspace connect command)")
      set(${OFFICIAL_REMOTE_CONNECTED} TRUE PARENT_SCOPE) #simply exitting
    endif()
	endif()
# else No URL defined in description : maybe the remote has been defined on integration branch after previous release
endif()
endfunction(adjust_Official_Remote_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Package_Repository_From_Remotes| replace:: ``update_Package_Repository_From_Remotes``
#  .. _update_Package_Repository_From_Remotes:
#
#  update_Package_Repository_From_Remotes
#  --------------------------------------
#
#   .. command:: update_Package_Repository_From_Remotes(package)
#
#     Update the local graph of commits from official and origin remotes.
#
#     :package: name of target package.
#
function(update_Package_Repository_From_Remotes package)
execute_process(COMMAND git fetch official
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                OUTPUT_QUIET ERROR_QUIET)#fetching official
execute_process(COMMAND git fetch origin
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                OUTPUT_QUIET ERROR_QUIET)#fetching origin
endfunction(update_Package_Repository_From_Remotes)

######################################################################
############################ other functions #########################
######################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |has_Modifications| replace:: ``has_Modifications``
#  .. _has_Modifications:
#
#  has_Modifications
#  -----------------
#
#   .. command:: has_Modifications(RESULT package)
#
#     Tell wether a package's repository has modifications to stage or commit on its current branch.
#
#     :package: the name of target package
#
#     :RESULT: the output variable that is TRUE if package has modifications, FALSE otherwise
#
function(has_Modifications RESULT package)
execute_process(COMMAND git status --porcelain
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                OUTPUT_VARIABLE res_out ERROR_QUIET)
if(NOT res_out)# no modification to stage or commit
	set(${RESULT} FALSE PARENT_SCOPE)
else()#there are modification
	set(${RESULT} TRUE PARENT_SCOPE)
endif()
endfunction(has_Modifications)

### to know

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_For_New_Commits_To_Release| replace:: ``check_For_New_Commits_To_Release``
#  .. _check_For_New_Commits_To_Release:
#
#  check_For_New_Commits_To_Release
#  --------------------------------
#
#   .. command:: check_For_New_Commits_To_Release(RESULT package)
#
#     Tell wether a package's repository has interesting commits that may be part of a release.
#
#     :package: the name of target package
#
#     :RESULT: the output variable that is TRUE if package has commit that may be part of a release, FALSE otherwise
#
function(check_For_New_Commits_To_Release RESULT package)
execute_process(COMMAND git log --oneline --decorate --max-count=2
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                OUTPUT_VARIABLE res ERROR_QUIET)
if (NOT "${res}" STREQUAL "")
	string(REPLACE " " "%" GIT_LOGS ${res})
	string(REPLACE "\t" "%" GIT_LOGS ${GIT_LOGS})
	string(REGEX REPLACE "^(.+)\n$" "\\1" GIT_LOGS ${GIT_LOGS})
	string(REPLACE "\n" ";" GIT_LOGS ${GIT_LOGS})
	list(LENGTH GIT_LOGS SIZE)
	if(SIZE GREATER 1)
		list(GET GIT_LOGS 1 LINE2)
		string(FIND "${LINE2}" "%master" INDEX_MAS)
		if(INDEX_MAS EQUAL -1)# master not found in two last lines starting from branch
			set(${RESULT} TRUE PARENT_SCOPE) #master is more than 1 commit away from branch
			return()
		endif()
	endif()
endif()
set(${RESULT} FALSE PARENT_SCOPE)
endfunction(check_For_New_Commits_To_Release)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Package_Connected| replace:: ``is_Package_Connected``
#  .. _is_Package_Connected:
#
#  is_Package_Connected
#  --------------------
#
#   .. command:: is_Package_Connected(CONNECTED package remote)
#
#     Tell wether a package's repository (native or external) is connected with a given remote (only fetch address is tested).
#
#     :package: the name of target package
#
#     :remote: the name of the remote
#
#     :CONNECTED: the output variable that is TRUE if package is connected to the remote, FALSE otherwise (including if teh remote does not exist)
#
function(is_Package_Connected CONNECTED package remote)
	git_Provides_GETURL(RESULT)#depending on the version of git we can use the get-url command or not
  get_Package_Type(${package} PACK_TYPE)

  if(RESULT)#the get-url approach is the best one
    if(PACK_TYPE STREQUAL "NATIVE")
      execute_process(COMMAND git remote get-url ${remote}
                      WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                      OUTPUT_VARIABLE out RESULT_VARIABLE res)
    elseif(PACK_TYPE STREQUAL "EXTERNAL")
      execute_process(COMMAND git remote get-url ${remote}
                      WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${package}
                      OUTPUT_VARIABLE out RESULT_VARIABLE res)
    else()
      set(res -1)
    endif()
		if(NOT res AND NOT out STREQUAL "")
			set(${CONNECTED} TRUE PARENT_SCOPE)
		else()
			set(${CONNECTED} FALSE PARENT_SCOPE)
		endif()
		return()
	else()
    if(PACK_TYPE STREQUAL "NATIVE")
      execute_process(COMMAND git remote -v
                      WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                      OUTPUT_VARIABLE out RESULT_VARIABLE res)
    elseif(PACK_TYPE STREQUAL "EXTERNAL")
      execute_process(COMMAND git remote -v
                      WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${package}
                      OUTPUT_VARIABLE out RESULT_VARIABLE res)
    else()
      set(res -1)
    endif()
		if(NOT res AND NOT out STREQUAL "")
			string(REPLACE "${remote}" "found" IS_FOUND ${out})
			if(NOT IS_FOUND STREQUAL ${out})
				set(${CONNECTED} TRUE PARENT_SCOPE)
				return()
			endif()
		endif()
		set(${CONNECTED} FALSE PARENT_SCOPE)
		return()
	endif()
endfunction(is_Package_Connected)

#.rst:
#
# .. ifmode:: internal
#
#  .. |clone_Repository| replace:: ``clone_Repository``
#  .. _clone_Repository:
#
#  clone_Repository
#  ----------------
#
#   .. command:: clone_Repository(IS_DEPLOYED package url)
#
#     Cloning the repository of a package.
#
#     :package: the name of target package
#
#     :url: the git url to clone
#
#     :IS_DEPLOYED: the output variable that is TRUE if package has been cloned, FALSE otherwise
#
function(clone_Repository IS_DEPLOYED package url)
execute_process(COMMAND git clone ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages)
if(EXISTS ${WORKSPACE_DIR}/packages/${package} AND IS_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
	set(${IS_DEPLOYED} TRUE PARENT_SCOPE)
	execute_process(COMMAND git fetch origin
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                  OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND git checkout integration
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                  OUTPUT_QUIET ERROR_QUIET)#go to integration to create the local branch
	execute_process(COMMAND git checkout master
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                  OUTPUT_QUIET ERROR_QUIET)#go back to master by default

	# now adding reference to official remote with official == origin (default case)
	execute_process(COMMAND git remote add official ${url}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                )
	execute_process(COMMAND git fetch official
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                  OUTPUT_QUIET ERROR_QUIET) #updating remote branches for official remote
else()
	set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : impossible to clone the repository of package ${package} (bad repository address or you have no clone rights for this repository). Please contact the administrator of this package.")
endif()
endfunction(clone_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |track_Repository_Branch| replace:: ``track_Repository_Branch``
#  .. _track_Repository_Branch:
#
#  track_Repository_Branch
#  -----------------------
#
#   .. command:: track_Repository_Branch(package remote branch)
#
#     Make the local repository of package track the given branch from given remote.
#
#     :package: the name of target package
#
#     :remote: the name of remote whose branch will be tracked
#
#     :branch: the name of the branch
#
function(track_Repository_Branch package remote branch)
  #TODO check if it does no provoke any problems in currenlty developped package
  execute_process(COMMAND git checkout --track -b ${branch} ${remote}/${branch}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                  OUTPUT_QUIET ERROR_QUIET)#updating reference on branch defined in remote
endfunction(track_Repository_Branch)

#.rst:
#
# .. ifmode:: internal
#
#  .. |initialize_Git_Repository_Push_Address| replace:: ``initialize_Git_Repository_Push_Address``
#  .. _initialize_Git_Repository_Push_Address:
#
#  initialize_Git_Repository_Push_Address
#  --------------------------------------
#
#   .. command:: initialize_Git_Repository_Push_Address(package url)
#
#     Initialize the push adress of a package's repository.
#
#     :package: the name of target package
#
#     :url: the git push url
#
function(initialize_Git_Repository_Push_Address package url)
execute_process(COMMAND git remote set-url --push origin ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
execute_process(COMMAND git remote set-url --push official ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
endfunction(initialize_Git_Repository_Push_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |test_Package_Remote_Initialized| replace:: ``test_Package_Remote_Initialized``
#  .. _test_Package_Remote_Initialized:
#
#  test_Package_Remote_Initialized
#  -------------------------------
#
#   .. command:: test_Package_Remote_Initialized(package url INITIALIZED)
#
#     Test is a remote repository of a package is initialized according to PID standard (basically it has an integration branch).
#
#     :package: the name of target package
#
#     :url: the git url of teh package repository
#
#     :INITIALIZED: the output variable that is TRUE if package's remote is initialized, FALSE otherwise
#
function(test_Package_Remote_Initialized package url INITIALIZED)
  if(EXISTS ${WORKSPACE_DIR}/pid/${package})
    file(REMOVE_RECURSE ${WORKSPACE_DIR}/pid/${package})
  endif()
execute_process(COMMAND git clone ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/pid
                OUTPUT_QUIET ERROR_QUIET) #cloning in a temporary area

execute_process(COMMAND git branch -a
            		WORKING_DIRECTORY ${WORKSPACE_DIR}/pid/${package}
            		OUTPUT_VARIABLE all_branches ERROR_QUIET)#getting all branches

if(all_branches)
	string(REPLACE "\n" ";" GIT_BRANCHES ${all_branches})
	set(INTEGRATION_FOUND FALSE)
	foreach(branch IN LISTS GIT_BRANCHES)#checking that the origin/integration branch exists
		if(branch MATCHES "^[ \t]*remotes/(origin/integration)[ \t]*$")
			set(INTEGRATION_FOUND TRUE)
			break()
		endif()
	endforeach()

	set(${INITIALIZED} ${INTEGRATION_FOUND} PARENT_SCOPE)
else()
	set(${INITIALIZED} FALSE PARENT_SCOPE)
endif()
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/pid/${package}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/pid
                  OUTPUT_QUIET ERROR_QUIET)
endfunction(test_Package_Remote_Initialized)

#.rst:
#
# .. ifmode:: internal
#
#  .. |test_Remote_Initialized| replace:: ``test_Remote_Initialized``
#  .. _test_Remote_Initialized:
#
#  test_Remote_Initialized
#  ------------------------
#
#   .. command:: test_Remote_Initialized(repository url INITIALIZED)
#
#     Test is a remote repository is initialized (git initialization).
#
#     :repository: the name of the repository
#
#     :url: the git url of the repository
#
#     :INITIALIZED: the output variable that is TRUE if package's remote is initialized, FALSE otherwise
#
function(test_Remote_Initialized repository url INITIALIZED)
if(EXISTS ${WORKSPACE_DIR}/pid/${repository})#cleaning pid folder if for any reason a repo with same name already lie in there
  file(REMOVE_RECURSE ${WORKSPACE_DIR}/pid/${repository})
endif()
execute_process(COMMAND git clone ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/pid
                OUTPUT_QUIET ERROR_QUIET) #cloning in a temporary area

execute_process(COMMAND git branch -a
            		WORKING_DIRECTORY ${WORKSPACE_DIR}/pid/${repository}
            		OUTPUT_VARIABLE all_branches ERROR_QUIET)#getting all branches

if(all_branches)#the repository must have branches to be initialized
	set(${INITIALIZED} TRUE PARENT_SCOPE)
else()
	set(${INITIALIZED} FALSE PARENT_SCOPE)
endif()
	execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/pid/${repository}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/pid
                  OUTPUT_QUIET ERROR_QUIET)

endfunction(test_Remote_Initialized)

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Repository| replace:: ``init_Repository``
#  .. _init_Repository:
#
#  init_Repository
#  ---------------
#
#   .. command:: init_Repository(package)
#
#     Initialize a package folder as a git repository (with no official remote).
#
#     :package: the name of the package
#
function(init_Repository package)
execute_process(COMMAND git init
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
                OUTPUT_QUIET ERROR_QUIET)#initialize the git repository
execute_process(COMMAND git add -A
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git commit -m "initialization of package done"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git tag -a v0.0.0 -m "creation of package"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)#0.0.0 tag = creation of package
execute_process(COMMAND git checkout -b integration master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)#going to master branch
set_Version_Number_To_Package(RESULT_OK ${package} "DOTTED_STRING" "ARG" 0 1 0)#(NEW WAY OF DOING) use dotted string in VERSION argument of declare_pid_package function
execute_process(COMMAND git add -A
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git commit -m "starting work on package (version 0.1.0)"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)
endfunction(init_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |connect_Package_Repository| replace:: ``connect_Package_Repository``
#  .. _connect_Repository:
#
#  connect_Package_Repository
#  --------------------------
#
#   .. command:: connect_Package_Repository(package url)
#
#     Connect a package's repository to a remote (this later become origin and official in the same time). Used first time the package is connected after its creation.
#
#     :package: the name of the package
#
#     :url: the url of the package's remote
#
function(connect_Package_Repository package url)
connect_Repository_Remote(${package} ${url} "" origin)
connect_Repository_Remote(${package} ${url} "" official)

execute_process(COMMAND git push origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git push origin --tags
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git push origin integration
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git fetch official
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
endfunction(connect_Package_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reconnect_Repository| replace:: ``reconnect_Repository``
#  .. _reconnect_Repository:
#
#  reconnect_Repository
#  --------------------
#
#   .. command:: reconnect_Repository(package url)
#
#     Reconnect an already connected package's repository to another remote (this later becomes official). Used when official repository has moved.
#
#     :package: the name of the package
#
#     :url: the url of the package's remote
#
function(reconnect_Repository package url)
reconnect_Repository_Remote(${package} ${url} ${url} official)
go_To_Master(${package})
execute_process(COMMAND git pull official master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} )#updating master
execute_process(COMMAND git fetch official --tags
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)
go_To_Integration(${package})
endfunction(reconnect_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |connect_Repository_Remote| replace:: ``connect_Repository_Remote``
#  .. _connect_Repository_Remote:
#
#  connect_Repository_Remote
#  ---------------------------
#
#   .. command:: connect_Repository_Remote(package url public_url remote_name)
#
#     Add the target remote to a package repository.
#
#     :package: the name of the package
#
#     :url: the new private url of the package's remote
#
#     :public_url: the public counterpart url of the package's remote
#
#     :remote_name: the name of the package's remote (official or origin)
#
function(connect_Repository_Remote package url public_url remote_name)
	if(public_url) #if there is a public URL the package is clonable from a public address
		execute_process(COMMAND git remote add ${remote_name} ${public_url}
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
		execute_process(COMMAND git remote set-url --push ${remote_name} ${url}
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
	else()#default case => same push and fetch address for remote
		execute_process(COMMAND git remote add ${remote_name} ${url}
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
	endif()
endfunction(connect_Repository_Remote)


#.rst:
#
# .. ifmode:: internal
#
#  .. |reconnect_Repository_Remote| replace:: ``reconnect_Repository_Remote``
#  .. _reconnect_Repository_Remote:
#
#  reconnect_Repository_Remote
#  ---------------------------
#
#   .. command:: reconnect_Repository_Remote(package url public_url remote_name)
#
#     Change the target remote of a package repository.
#
#     :package: the name of the package
#
#     :url: the new private url of the package's remote
#
#     :public_url: the public counterpart url of the package's remote
#
#     :remote_name: the name of the package's remote (official or origin)
#
function(reconnect_Repository_Remote package url public_url remote_name)
	if(public_url) #if there is a public URL the package is clonable from a public address
		execute_process(COMMAND git remote set-url ${remote_name} ${public_url}
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
		execute_process(COMMAND git remote set-url --push ${remote_name} ${url}
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
	else()#default case => same push and fetch address for remote
		execute_process(COMMAND git remote set-url ${remote_name} ${url}
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
		execute_process(COMMAND git remote set-url --push ${remote_name} ${url}
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
	endif()
endfunction(reconnect_Repository_Remote)


#.rst:
#
# .. ifmode:: internal
#
#  .. |disconnect_Repository_Remote| replace:: ``disconnect_Repository_Remote``
#  .. _disconnect_Repository_Remote:
#
#  disconnect_Repository_Remote
#  ----------------------------
#
#   .. command:: disconnect_Repository_Remote(package remote_name)
#
#     Disconnect an package's repository from one of its remote.
#
#     :package: the name of the package
#
#     :remote_name: the name of the package's remote (official or origin)
#
function(disconnect_Repository_Remote package remote_name)
	execute_process(COMMAND git remote remove ${remote_name}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package})
endfunction(disconnect_Repository_Remote)

#.rst:
#
# .. ifmode:: internal
#
#  .. |change_Origin_Repository| replace:: ``change_Origin_Repository``
#  .. _change_Origin_Repository:
#
#  change_Origin_Repository
#  ------------------------
#
#   .. command:: change_Origin_Repository(package url)
#
#     Set the origin remote of a package to a completely new address. Used when a fork of a package's official repository is performed.
#
#     :package: the name of the package
#
#     :url: the url of the package's origin remote
#
function(change_Origin_Repository package url)
execute_process(COMMAND git remote set-url origin ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)
go_To_Integration(${package})
execute_process(COMMAND git pull origin integration
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git push origin integration
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_QUIET ERROR_QUIET)
message("[PID] INFO: Origin remote has been changed to ${url}.")
endfunction(change_Origin_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Repository_Name| replace:: ``get_Repository_Name``
#  .. _get_Repository_Name:
#
#  get_Repository_Name
#  -------------------
#
#   .. command:: get_Repository_Name(RES_NAME git_url)
#
#     Get the name of the project from a given git url.
#
#     :git_url: the url of the repository.
#
#     :RES_NAME: the output variable containing the name of the project.
#
function(get_Repository_Name RES_NAME git_url)
#testing ssh address
string(REGEX REPLACE "^[^@]+@[^:]+:(.+)$" "\\1" REPO_PATH ${git_url})
if(REPO_PATH STREQUAL "${git_url}")
	#testing https address
	string(REGEX REPLACE "^https?://(.*)$" "\\1" REPO_PATH ${git_url})
	if(REPO_PATH STREQUAL "${git_url}")
		return()
	endif()
endif()
get_filename_component(REPO_NAME ${REPO_PATH} NAME_WE)
set(${RES_NAME} ${REPO_NAME} PARENT_SCOPE)
endfunction(get_Repository_Name)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_For_Remote_Respositories| replace:: ``check_For_Remote_Respositories``
#  .. _check_For_Remote_Respositories:
#
#  check_For_Remote_Respositories
#  ------------------------------
#
#   .. command:: check_For_Remote_Respositories(verbose)
#
#     Check, and eventually perform corrective actions, that package's repository origin and official remotes are defined.
#
#     :verbose: if TRUE the function will echo more messages.
#
function(check_For_Remote_Respositories verbose)
adjust_Official_Remote_Address(OFFICIAL_REMOTE_CONNECTED ${PROJECT_NAME} "${verbose}")
if(NOT OFFICIAL_REMOTE_CONNECTED)
  if(verbose)
    message("[PID] WARNING: no official remote defined for ${PROJECT_NAME}.")
  endif()
  return()
else()#there is a connected remote after adjustment
  get_Remotes_Address(${PROJECT_NAME} RES_OFFICIAL_FETCH RES_OFFICIAL_PUSH RES_ORIGIN_FETCH RES_ORIGIN_PUSH)#get the adress of the official and origin git remotes
  if(NOT ${PROJECT_NAME}_PUBLIC_ADDRESS)#no public address defined (only adress is used for fetch and push)
    if(NOT ${PROJECT_NAME}_ADDRESS STREQUAL RES_OFFICIAL_PUSH
      OR NOT ${PROJECT_NAME}_ADDRESS STREQUAL RES_OFFICIAL_FETCH)
      message("[PID] WARNING: the address used in package description (${${PROJECT_NAME}_ADDRESS}) seems to be pointing to an invalid repository while the corresponding git remote targets another remote repository (fetch=${RES_OFFICIAL_FETCH} push=${RES_OFFICIAL_PUSH}). Using the current remote by default. You should change the address in package description.")
    endif()
  else()#a public address is defined !
    set(ADDR_OK TRUE)
    if(NOT ${PROJECT_NAME}_ADDRESS STREQUAL RES_OFFICIAL_PUSH)
      message("[PID] WARNING: the address used in package description (${${PROJECT_NAME}_ADDRESS}) seems to be pointing to an invalid repository while the corresponding git remote targets another remote repository (${RES_OFFICIAL_PUSH}). Using the current remote by default. You should change the address in package description.")
      set(ADDR_OK FALSE)#means that we keep official "as is"
    endif()
    if(NOT ${PROJECT_NAME}_PUBLIC_ADDRESS STREQUAL RES_OFFICIAL_FETCH)
      if(ADDR_OK)
        #we know that the address is correct so we simply need to reconnect the public address
        reconnect_Repository_Remote(${PROJECT_NAME} ${${PROJECT_NAME}_ADDRESS} ${${PROJECT_NAME}_PUBLIC_ADDRESS} official)
      else()
        message("[PID] WARNING: the public address used in package description (${${PROJECT_NAME}_PUBLIC_ADDRESS}) seems to be pointing to an invalid repository while the corresponding git remote targets another remote repository (${RES_OFFICIAL_FETCH}). Using the current remote by default. You should change the address in package description.")
      endif()
    endif()
  endif()
  #updating local repository from remote one
  execute_process(COMMAND git fetch official --tags
                  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_QUIET ERROR_QUIET)
  # now checking that there is an origin remote
  is_Package_Connected(CONNECTED ${PROJECT_NAME} origin)
  if(NOT CONNECTED) #the package has no origin remote => create it and set it to the same address as official
  	execute_process(COMMAND git remote add origin ${${PROJECT_NAME}_ADDRESS}
                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_QUIET ERROR_QUIET)
  	execute_process(COMMAND git fetch origin
                    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_QUIET ERROR_QUIET)
  #else we cannot conclude if origin is OK or not as the user may have forked the official project (and so may want to keep another address than official)
  endif()
endif()
endfunction(check_For_Remote_Respositories)

#.rst:
#
# .. ifmode:: internal
#
#  .. |check_For_Wrapper_Remote_Respositories| replace:: ``check_For_Wrapper_Remote_Respositories``
#  .. _check_For_Wrapper_Remote_Respositories:
#
#  check_For_Wrapper_Remote_Respositories
#  --------------------------------------
#
#   .. command:: check_For_Wrapper_Remote_Respositories()
#
#     Check, and eventually perform corrective actions, so that wrapper's repository origin remote is defined.
#
function(check_For_Wrapper_Remote_Respositories)
  is_Package_Connected(CONNECTED ${PROJECT_NAME} origin)
  if(NOT CONNECTED) #the package has no origin remote => create it and set it to the same address as official
      if(${PROJECT_NAME}_PUBLIC_ADDRESS)
        execute_process(COMMAND git remote add origin ${${PROJECT_NAME}_PUBLIC_ADDRESS}
                        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_QUIET ERROR_QUIET)
        if(${PROJECT_NAME}_ADDRESS)
          execute_process(COMMAND git remote set-url --push origin ${${PROJECT_NAME}_ADDRESS}
                          WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_QUIET ERROR_QUIET)
        endif()
      elseif(${PROJECT_NAME}_ADDRESS)
        execute_process(COMMAND git remote add origin ${${PROJECT_NAME}_ADDRESS}
                        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_QUIET ERROR_QUIET)
      else()#no need to check more the package is not connected and this is normal
        return()
      endif()
      execute_process(COMMAND git fetch origin
                      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_QUIET ERROR_QUIET)
  else()#already connected
    get_Remotes_Address(${PROJECT_NAME} RES_OFFICIAL_FETCH RES_OFFICIAL_PUSH RES_ORIGIN_FETCH RES_ORIGIN_PUSH)#get the adress of the official and origin git remotes
    if(NOT ${PROJECT_NAME}_PUBLIC_ADDRESS)#no public address defined (only adress is used for fetch and push)
      if(NOT ${PROJECT_NAME}_ADDRESS STREQUAL RES_ORIGIN_FETCH)
        message("[PID] WARNING: the address used in package description (${${PROJECT_NAME}_ADDRESS}) seems to be pointing to an invalid repository while the corresponding git remote targets another remote repository (${RES_ORIGIN_FETCH}). Using the current remote by default. You should change the address in package description.")
      endif()
    else()#a public address is defined !
      if(NOT ${PROJECT_NAME}_ADDRESS STREQUAL RES_ORIGIN_PUSH
        AND NOT ${PROJECT_NAME}_PUBLIC_ADDRESS STREQUAL RES_ORIGIN_FETCH)
        message("[PID] WARNING: none of the addresses used in package description (${${PROJECT_NAME}_ADDRESS} and ${${PROJECT_NAME}_PUBLIC_ADDRESS}) seems to be pointing to an invalid repository while the corresponding git remote targets another remote repository (${RES_ORIGIN_FETCH}). Using the current remote by default. You should change the address in package description.")
      endif()
    endif()
  endif()
endfunction(check_For_Wrapper_Remote_Respositories)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Remotes_To_Update| replace:: ``get_Remotes_To_Update``
#  .. _get_Remotes_To_Update:
#
#  get_Remotes_To_Update
#  ---------------------
#
#   .. command:: get_Remotes_To_Update(REMOTES_TO_UPDATE package)
#
#     Get the package's remotes whose integration branch can be updated with new commits.
#
#     :package: the name of the package.
#
#     :REMOTES_TO_UPDATE: the output variable containing the list of remote to update.
#
function(get_Remotes_To_Update REMOTES_TO_UPDATE package)
set(return_list)
execute_process(COMMAND git log --oneline --decorate --max-count=1
                WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_VARIABLE res ERROR_QUIET)
if (NOT "${res}" STREQUAL "")
	string(FIND "${res}" "origin/integration" INDEX_ORIGIN)
	string(FIND "${res}" "official/integration" INDEX_OFFICIAL)
	if(INDEX_ORIGIN LESS 1)
		list(APPEND return_list origin)
	endif()
	if(INDEX_OFFICIAL LESS 1)
		list(APPEND return_list official)
	endif()
endif()
set(${REMOTES_TO_UPDATE} ${return_list} PARENT_SCOPE)
endfunction(get_Remotes_To_Update)

#.rst:
#
# .. ifmode:: internal
#
#  .. |get_Remotes_Address| replace:: ``get_Remotes_Address``
#  .. _get_Remotes_Address:
#
#  get_Remotes_Address
#  --------------------
#
#   .. command:: get_Remotes_Address(package RES_OFFICIAL_FETCH RES_OFFICIAL_PUSH  RES_ORIGIN_FETCH RES_ORIGIN_PUSH)
#
#     Get the package's origin and official remotes addresses.
#
#     :package: the name of the package.
#
#     :RES_OFFICIAL_FETCH: the output variable containg the address of package's official remote for fetching.
#
#     :RES_OFFICIAL_PUSH: the output variable containg the address of package's official remote for pushing.
#
#     :RES_ORIGIN_FETCH: the output variable containg the address of package's origin remote for fetching..
#
#     :RES_ORIGIN_PUSH: the output variable containg the address of package's origin remote for pushing.
#
function(get_Remotes_Address package RES_OFFICIAL_FETCH RES_OFFICIAL_PUSH RES_ORIGIN_FETCH RES_ORIGIN_PUSH)
set(${RES_OFFICIAL_FETCH} PARENT_SCOPE)
set(${RES_OFFICIAL_PUSH} PARENT_SCOPE)
set(${RES_ORIGIN_FETCH} PARENT_SCOPE)
set(${RES_ORIGIN_PUSH} PARENT_SCOPE)
get_Package_Type(${package} PACK_TYPE)
if(PACK_TYPE STREQUAL "NATIVE")
  execute_process(COMMAND git remote -v
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package} OUTPUT_VARIABLE RESULTING_REMOTES)
elseif(PACK_TYPE STREQUAL "EXTERNAL")
  execute_process(COMMAND git remote -v
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${package} OUTPUT_VARIABLE RESULTING_REMOTES)
else()
  return()
endif()

if(RESULTING_REMOTES)
	string(REPLACE "\n" ";" LINES ${RESULTING_REMOTES})
	string(REGEX REPLACE ";$" "" LINES "${LINES}")
	foreach(remote IN LISTS LINES)
		string(REGEX REPLACE "^([^ \t]+)[ \t]+([^ \t]+)[ \t]+\\((fetch|push)\\).*$" "\\1;\\2;\\3" REMOTES_INFO ${remote})
    list(GET REMOTES_INFO 1 ADDR_REMOTE)
		list(GET REMOTES_INFO 0 NAME_REMOTE)
		if(NAME_REMOTE STREQUAL "official")
      list(GET REMOTES_INFO 2 FETCH_OR_PUSH)
      if(FETCH_OR_PUSH STREQUAL "fetch")
        set(${RES_OFFICIAL_FETCH} ${ADDR_REMOTE} PARENT_SCOPE)
      elseif(FETCH_OR_PUSH STREQUAL "push")
        set(${RES_OFFICIAL_PUSH} ${ADDR_REMOTE} PARENT_SCOPE)
      endif()
		elseif(NAME_REMOTE STREQUAL "origin")
      list(GET REMOTES_INFO 2 FETCH_OR_PUSH)
      if(FETCH_OR_PUSH STREQUAL "fetch")
        set(${RES_ORIGIN_FETCH} ${ADDR_REMOTE} PARENT_SCOPE)
      elseif(FETCH_OR_PUSH STREQUAL "push")
        set(${RES_ORIGIN_PUSH} ${ADDR_REMOTE} PARENT_SCOPE)
      endif()
		endif()
	endforeach()
endif()
endfunction(get_Remotes_Address)

##############################################################################
############## wrappers repository related functions #########################
##############################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |clone_Wrapper_Repository| replace:: ``clone_Wrapper_Repository``
#  .. _clone_Wrapper_Repository:
#
#  clone_Wrapper_Repository
#  ------------------------
#
#   .. command:: clone_Wrapper_Repository(IS_DEPLOYED package url)
#
#     Clone the repository of a wrapper in adequate folder of the workspace.
#
#     :wrapper: the name of target wrapper
#
#     :url: the git url to clone
#
#     :IS_DEPLOYED: the output variable that is TRUE if wrapper has been cloned, FALSE otherwise
#
function(clone_Wrapper_Repository IS_DEPLOYED wrapper url)
execute_process(COMMAND git clone ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers OUTPUT_QUIET ERROR_QUIET)
if(EXISTS ${WORKSPACE_DIR}/wrappers/${wrapper} AND IS_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper})
	set(${IS_DEPLOYED} TRUE PARENT_SCOPE)
	execute_process(COMMAND git fetch origin --tags
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper} OUTPUT_QUIET ERROR_QUIET) #just in case of version were not updated
else()
	set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
	message("[PID] ERROR : impossible to clone the repository of external package wrapper ${wrapper} (bad repository address or you have no clone rights for this repository). Please contact the administrator of this wrapper.")
endif()
endfunction(clone_Wrapper_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Wrapper_Repository| replace:: ``init_Wrapper_Repository``
#  .. _init_Wrapper_Repository:
#
#  init_Wrapper_Repository
#  -----------------------
#
#   .. command:: init_Wrapper_Repository(wrapper)
#
#     Initialize a wrapper folder as a git repository.
#
#     :wrapper: the name of the wrapper
#
function(init_Wrapper_Repository wrapper)
execute_process(COMMAND git init
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper} )
execute_process(COMMAND git add -A
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper} )
execute_process(COMMAND git commit -m "initialization of wrapper"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper} )
execute_process(COMMAND git lfs track "*.tar.gz"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper} OUTPUT_QUIET ERROR_QUIET)
endfunction(init_Wrapper_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |register_Wrapper_Repository_Address| replace:: ``register_Wrapper_Repository_Address``
#  .. _register_Wrapper_Repository_Address:
#
#  register_Wrapper_Repository_Address
#  -----------------------------------
#
#   .. command:: register_Wrapper_Repository_Address(wrapper)
#
#     Create a commit after update of the wrapper repository address in its CMakeLists.txt.
#
#     :wrapper: the name of target wrapper
#
function(register_Wrapper_Repository_Address wrapper)
execute_process(COMMAND git add CMakeLists.txt
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper}) # registering the address means registering the CMakelists.txt
execute_process(COMMAND git commit -m "adding repository address to the root CMakeLists.txt file"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper})
endfunction(register_Wrapper_Repository_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |connect_Wrapper_Repository| replace:: ``connect_Wrapper_Repository``
#  .. _connect_Wrapper_Repository:
#
#  connect_Wrapper_Repository
#  --------------------------
#
#   .. command:: connect_Wrapper_Repository(wrapper url)
#
#     Connect a wrapper's repository to a remote. Used first time the wrapper is connected after its creation.
#
#     :wrapper: the name of the wrapper
#
#     :url: the url of the wrapper's remote
#
function(connect_Wrapper_Repository wrapper url)
execute_process(COMMAND git remote add origin ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper} )
execute_process(COMMAND git push origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git fetch origin
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper} )
endfunction(connect_Wrapper_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reconnect_Wrapper_Repository| replace:: ``reconnect_Wrapper_Repository``
#  .. _reconnect_Wrapper_Repository:
#
#  reconnect_Wrapper_Repository
#  ----------------------------
#
#   .. command:: reconnect_Wrapper_Repository(wrapper url)
#
#     Reonnect an already connected wrapper's repository to another remote.
#
#     :wrapper: the name of the wrapper
#
#     :url: the url of the wrapper's remote
#
function(reconnect_Wrapper_Repository wrapper url)
execute_process(COMMAND git remote set-url origin ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper})
execute_process(COMMAND git pull origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper})#updating master
endfunction(reconnect_Wrapper_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |initialize_Wrapper_Git_Repository_Push_Address| replace:: ``initialize_Wrapper_Git_Repository_Push_Address``
#  .. _initialize_Wrapper_Git_Repository_Push_Address:
#
#  initialize_Wrapper_Git_Repository_Push_Address
#  ----------------------------------------------
#
#   .. command:: initialize_Wrapper_Git_Repository_Push_Address(wrapper url)
#
#     Initialize the push adress of a wrapper's repository.
#
#     :wrapper: the name of target wrapper
#
#     :url: the git push url
#
function(initialize_Wrapper_Git_Repository_Push_Address wrapper url)
execute_process(COMMAND git remote set-url --push origin ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper})
endfunction(initialize_Wrapper_Git_Repository_Push_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Wrapper_Repository| replace:: ``update_Wrapper_Repository``
#  .. _update_Wrapper_Repository:
#
#  update_Wrapper_Repository
#  --------------------------
#
#   .. command:: update_Wrapper_Repository(wrapper)
#
#     Update local wrapper's repository (pull).
#
#     :wrapper: the name of target wrapper
#
function(update_Wrapper_Repository wrapper)
execute_process(COMMAND git pull origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper} OUTPUT_QUIET ERROR_QUIET)#pulling master branch of origin (in case of) => merge can take place
execute_process(COMMAND git pull origin --tags
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper} OUTPUT_QUIET ERROR_QUIET)#pulling master branch of origin (in case of) => merge can take place
execute_process(COMMAND git lfs pull origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${wrapper} )#fetching master branch to get most up to date archives
endfunction(update_Wrapper_Repository)


#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Wrapper_Repository_Version| replace:: ``publish_Wrapper_Repository_Version``
#  .. _publish_Wrapper_Repository_Version:
#
#  publish_Wrapper_Repository_Version
#  ----------------------------------
#
#   .. command:: publish_Wrapper_Repository_Version(RESULT package version_string add_it)
#
#     Push (or delete) a version tag on the remote wrapper repository.
#
#     :package: the name of target package
#
#     :version_string: the version tag to push
#
#     :add_it: if TRUE the tag is added, if FALSE it is removed
#
#     :RESULT: the output variable that is TRUE if operation succeeded, FALSE otherwise
#
function(publish_Wrapper_Repository_Version RESULT package version_string add_it)
if(add_it)
  execute_process(COMMAND git push --porcelain origin v${version_string}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${package} OUTPUT_VARIABLE out ERROR_QUIET)#pushing a version tag
  if(out MATCHES "^.*rejected.*$")
    set(${RESULT} FALSE PARENT_SCOPE)
  	return()
  endif()
else()
  execute_process(COMMAND git push --porcelain --delete origin v${version_string}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/wrappers/${package} OUTPUT_VARIABLE out ERROR_QUIET)#deletting a version tag
  if(out MATCHES "^error.*$")
    set(${RESULT} FALSE PARENT_SCOPE)
    return()
  endif()
endif()
set(${RESULT} TRUE PARENT_SCOPE)
endfunction(publish_Wrapper_Repository_Version)

##############################################################################
############## frameworks repository related functions #######################
##############################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |clone_Framework_Repository| replace:: ``clone_Framework_Repository``
#  .. _clone_Framework_Repository:
#
#  clone_Framework_Repository
#  --------------------------
#
#   .. command:: clone_Framework_Repository(IS_DEPLOYED framework url)
#
#     Clone the repository of a framework in adequate folder of the workspace.
#
#     :framework: the name of target framework
#
#     :url: the git url to clone
#
#     :IS_DEPLOYED: the output variable that is TRUE if framework has been cloned, FALSE otherwise
#
function(clone_Framework_Repository IS_DEPLOYED framework url)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/sites/frameworks git clone ${url} OUTPUT_QUIET ERROR_QUIET)

#framework may be named by only by their name or with a -framework suffix
if(EXISTS ${WORKSPACE_DIR}/sites/frameworks/${framework} AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework})
	set(${IS_DEPLOYED} TRUE PARENT_SCOPE)
	execute_process(COMMAND git fetch origin
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET) #just in case of
else()
	if(EXISTS ${WORKSPACE_DIR}/sites/frameworks/${framework}-framework AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework}-framework)
		execute_process(COMMAND ${CMAKE_COMMAND} -E rename ${WORKSPACE_DIR}/sites/frameworks/${framework}-framework ${WORKSPACE_DIR}/sites/frameworks/${framework}
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/pid OUTPUT_QUIET ERROR_QUIET)
		execute_process(COMMAND git lfs pull origin master
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework})#fetching master branch to get most up to date archives
		set(${IS_DEPLOYED} TRUE PARENT_SCOPE)

	else()
		set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
		message("[PID] ERROR : impossible to clone the repository of framework ${framework} (bad repository address or you have no clone rights for this repository). Please contact the administrator of this framework.")
	endif()
endif()
endfunction(clone_Framework_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Framework_Repository| replace:: ``init_Framework_Repository``
#  .. _init_Framework_Repository:
#
#  init_Framework_Repository
#  -------------------------
#
#   .. command:: init_Framework_Repository(framework)
#
#     Initialize a framework folder as a git repository.
#
#     :framework: the name of the target framework
#
function(init_Framework_Repository framework)
execute_process(COMMAND git init
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} )
execute_process(COMMAND git add -A
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} )
execute_process(COMMAND git commit -m "initialization of framework"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} )
execute_process(COMMAND git lfs track "*.tar.gz"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET)
endfunction(init_Framework_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Framework_Repository| replace:: ``update_Framework_Repository``
#  .. _update_Framework_Repository:
#
#  update_Framework_Repository
#  ---------------------------
#
#   .. command:: update_Framework_Repository(framework)
#
#     Update local framework's repository (pull).
#
#     :framework: the name of target framework
#
function(update_Framework_Repository framework)
execute_process(COMMAND git pull origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET)#pulling master branch of origin (in case of) => merge can take place
execute_process(COMMAND git lfs pull origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} )#fetching master branch to get most up to date archives
endfunction(update_Framework_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Framework_Repository| replace:: ``publish_Framework_Repository``
#  .. _publish_Framework_Repository:
#
#  publish_Framework_Repository
#  ----------------------------
#
#   .. command:: publish_Framework_Repository(framework PUBLISHED)
#
#     Commit and push unpublished content of local framework's repository.
#
#     :framework: the name of target framework
#
#     :PUBLISHED: the output variable that is TRUE if framework published, FALSE otherwise
#
function(publish_Framework_Repository framework PUBLISHED)
execute_process(COMMAND git status --porcelain
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_VARIABLE res)
if(res)#there is something to commit !
	execute_process(COMMAND git add -A
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND git commit -m "publishing new version of framework"
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} )
endif()
execute_process(COMMAND git pull --ff-only origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET RESULT_VARIABLE PULL_RESULT)#pulling master branch of origin to get modifications (new binaries) that would have been published at the same time (most of time a different binary for another plateform of the package)
if(PULL_RESULT EQUAL 0)#no conflict to manage
  execute_process(COMMAND git lfs pull origin master
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET) #fetching LFS content
  execute_process(COMMAND git push origin master
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET RESULT_VARIABLE PUSH_RESULT)#pushing to master branch of origin
  if(PUSH_RESULT EQUAL 0)
    set(${PUBLISHED} TRUE PARENT_SCOPE)
    return()
  endif()
endif()
set(${PUBLISHED} FALSE PARENT_SCOPE)
endfunction(publish_Framework_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |merge_Framework_Repository| replace:: ``merge_Framework_Repository``
#  .. _merge_Framework_Repository:
#
#  merge_Framework_Repository
#  ---------------------------
#
#   .. command:: merge_Framework_Repository(framework)
#
#     Force the merge of master branch of origin into local framework's repository.
#
#     :framework: the name of target framework
#
function(merge_Framework_Repository framework)
  #pulling master branch of origin to get modifications (new binaries) that would have been published at the same time (most of time a different binary for another plateform of the package)
  execute_process(COMMAND git pull -f origin master
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET)
endfunction(merge_Framework_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |register_Framework_Repository_Address| replace:: ``register_Framework_Repository_Address``
#  .. _register_Framework_Repository_Address:
#
#  register_Framework_Repository_Address
#  -------------------------------------
#
#   .. command:: register_Framework_Repository_Address(framework)
#
#     Create a commit after update of the framework repository address in its CMakeLists.txt.
#
#     :framework: the name of target framework
#
function(register_Framework_Repository_Address framework)
execute_process(COMMAND git add CMakeLists.txt
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework})
execute_process(COMMAND git commit -m "adding repository address to the root CMakeLists.txt file"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework})
endfunction(register_Framework_Repository_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |connect_Framework_Repository| replace:: ``connect_Framework_Repository``
#  .. _connect_Framework_Repository:
#
#  connect_Framework_Repository
#  ----------------------------
#
#   .. command:: connect_Framework_Repository(framework url)
#
#     Connect a framework's repository to a remote. Used first time the framework is connected after its creation.
#
#     :framework: the name of the framework
#
#     :url: the url of the framework's remote
#
function(connect_Framework_Repository framework url)
execute_process(COMMAND git remote add origin ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} )
execute_process(COMMAND git push origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git fetch origin
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} )
endfunction(connect_Framework_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reconnect_Framework_Repository| replace:: ``reconnect_Framework_Repository``
#  .. _reconnect_Framework_Repository:
#
#  reconnect_Framework_Repository
#  ------------------------------
#
#   .. command:: reconnect_Framework_Repository(framework url)
#
#     Reonnect an already connected framework's repository to another remote.
#
#     :framework: the name of the framework
#
#     :url: the url of the framework's remote
#
function(reconnect_Framework_Repository framework url)
execute_process(COMMAND git remote set-url origin ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework})
execute_process(COMMAND git pull origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework})#updating master
endfunction(reconnect_Framework_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Framework_Connected| replace:: ``is_Framework_Connected``
#  .. _is_Framework_Connected:
#
#  is_Framework_Connected
#  ----------------------
#
#   .. command:: is_Framework_Connected(CONNECTED framework remote)
#
#     Tell wether a framework's repository is connected with a given remote.
#
#     :framework: the name of target framework
#
#     :remote: the name of the remote
#
#     :CONNECTED: the output variable that is TRUE if framework is connected to the remote, FALSE otherwise (including if the remote does not exist)
#
function(is_Framework_Connected CONNECTED framework remote)
	execute_process(COMMAND git remote show ${remote}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_VARIABLE res)
	if(NOT res OR res STREQUAL "")
		set(${CONNECTED} TRUE PARENT_SCOPE)
	else()
		set(${CONNECTED} FALSE PARENT_SCOPE)
	endif()
endfunction(is_Framework_Connected)

#.rst:
#
# .. ifmode:: internal
#
#  .. |change_Origin_Framework_Repository| replace:: ``change_Origin_Framework_Repository``
#  .. _change_Origin_Framework_Repository:
#
#  change_Origin_Framework_Repository
#  ----------------------------------
#
#   .. command:: change_Origin_Framework_Repository(framework url)
#
#     Set the origin remote to a completely new address.
#
#     :framework: the name of target framework
#
#     :url: the new url of the origin remote
#
function(change_Origin_Framework_Repository framework url)
execute_process(COMMAND git remote set-url origin ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git pull origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git push origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/frameworks/${framework} OUTPUT_QUIET ERROR_QUIET)
message("[PID] INFO: Origin remote has been changed to ${url}.")
endfunction(change_Origin_Framework_Repository)


##############################################################################
############## environment repository related functions #######################
##############################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |clone_Environment_Repository| replace:: ``clone_Environment_Repository``
#  .. _clone_Environment_Repository:
#
#  clone_Environment_Repository
#  ----------------------------
#
#   .. command:: clone_Environment_Repository(IS_DEPLOYED framework url)
#
#     Clone the repository of an environment in adequate folder of the workspace.
#
#     :environment: the name of target environment
#
#     :url: the git url to clone
#
#     :IS_DEPLOYED: the output variable that is TRUE if environment has been cloned, FALSE otherwise
#
function(clone_Environment_Repository IS_DEPLOYED environment url)
  execute_process(COMMAND git clone ${url}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/environments)

#environment may be named by only by their name or with a -framework suffix
if(EXISTS ${WORKSPACE_DIR}/environments/${environment} AND IS_DIRECTORY ${WORKSPACE_DIR}/environments/${environment})
  set(${IS_DEPLOYED} TRUE PARENT_SCOPE)
	execute_process(COMMAND git fetch origin
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} OUTPUT_QUIET ERROR_QUIET) #just in case of
else()
  if(EXISTS ${WORKSPACE_DIR}/environments/${environment}-environment
    AND IS_DIRECTORY ${WORKSPACE_DIR}/environments/${environment}-environment)
		execute_process(COMMAND ${CMAKE_COMMAND} -E rename ${WORKSPACE_DIR}/environments/${environment}-environment ${WORKSPACE_DIR}/environments/${environment}
    WORKING_DIRECTORY ${WORKSPACE_DIR}/pid OUTPUT_QUIET ERROR_QUIET)
		execute_process(COMMAND git lfs pull origin master
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment})#fetching master branch to get most up to date archives
		set(${IS_DEPLOYED} TRUE PARENT_SCOPE)
	else()
		set(${IS_DEPLOYED} FALSE PARENT_SCOPE)
		message("[PID] ERROR : impossible to clone the repository of environment ${environment} (bad repository address or you have no clone rights for this repository). Please contact the administrator of this framework.")
	endif()
endif()
endfunction(clone_Environment_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Environment_Repository| replace:: ``init_Environment_Repository``
#  .. _init_Environment_Repository:
#
#  init_Environment_Repository
#  ---------------------------
#
#   .. command:: init_Environment_Repository(environment)
#
#     Initialize a environment folder as a git repository.
#
#     :environment: the name of the target environment
#
function(init_Environment_Repository environment)
execute_process(COMMAND git init
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} )
execute_process(COMMAND git add -A
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} )
execute_process(COMMAND git add -f build/.gitignore
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} )
execute_process(COMMAND git commit -m "initialization of environment"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} )
execute_process(COMMAND git lfs track "*.tar.gz"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} OUTPUT_QUIET ERROR_QUIET)
endfunction(init_Environment_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Environment_Repository| replace:: ``update_Environment_Repository``
#  .. _update_Environment_Repository:
#
#  update_Environment_Repository
#  -----------------------------
#
#   .. command:: update_Environment_Repository(environment)
#
#     Update local environment's repository (pull).
#
#     :environment: the name of target environment
#
function(update_Environment_Repository environment)
execute_process(COMMAND git pull origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} OUTPUT_QUIET ERROR_QUIET)#pulling master branch of origin (in case of) => merge can take place
execute_process(COMMAND git lfs pull origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} )#fetching master branch to get most up to date archives
endfunction(update_Environment_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Environment_Repository| replace:: ``publish_Environment_Repository``
#  .. _publish_Environment_Repository:
#
#  publish_Environment_Repository
#  ------------------------------
#
#   .. command:: publish_Environment_Repository(environment PUBLISHED)
#
#     Commit and push unpublished content of local environment's repository.
#
#     :environment: the name of target environment
#
function(publish_Environment_Repository environment PUBLISHED)
execute_process(COMMAND git status --porcelain
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} OUTPUT_VARIABLE res)
if(res)#there is something to commit !
	execute_process(COMMAND git add -A
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND git commit -m "publishing new version of framework"
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} )
  execute_process(COMMAND git pull origin master
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} OUTPUT_QUIET ERROR_QUIET)#pulling master branch of origin to get modifications (new binaries) that would have been published at the same time (most of time a different binary for another plateform of the package)
  execute_process(COMMAND git lfs pull origin master
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} OUTPUT_QUIET ERROR_QUIET) #fetching LFS content
  execute_process(COMMAND git push origin master
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} RESULT_VARIABLE PUSH_RESULT)#pushing to master branch of origin
  if(PUSH_RESULT EQUAL 0)
    set(${PUBLISHED} TRUE PARENT_SCOPE)
    return()
  endif()
endif()
set(${PUBLISHED} FALSE PARENT_SCOPE)
endfunction(publish_Environment_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |register_Environment_Repository_Address| replace:: ``register_Environment_Repository_Address``
#  .. _register_Environment_Repository_Address:
#
#  register_Environment_Repository_Address
#  ---------------------------------------
#
#   .. command:: register_Environment_Repository_Address(environment)
#
#     Create a commit after update of the environment repository address in its CMakeLists.txt.
#
#     :environment: the name of target environment
#
function(register_Environment_Repository_Address environment)
execute_process(COMMAND git add CMakeLists.txt
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment})
execute_process(COMMAND git commit -m "adding repository address to the root CMakeLists.txt file"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment})
endfunction(register_Environment_Repository_Address)

#.rst:
#
# .. ifmode:: internal
#
#  .. |connect_Environment_Repository| replace:: ``connect_Environment_Repository``
#  .. _connect_Environment_Repository:
#
#  connect_Environment_Repository
#  ------------------------------
#
#   .. command:: connect_Environment_Repository(environment url)
#
#     Connect a environment's repository to a remote. Used first time the environment is connected after its creation.
#
#     :environment: the name of the environment
#
#     :url: the url of the environment's remote
#
function(connect_Environment_Repository environment url)
execute_process(COMMAND git remote add origin ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} )
execute_process(COMMAND git push origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git fetch origin
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} )
endfunction(connect_Environment_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |reconnect_Environment_Repository| replace:: ``reconnect_Environment_Repository``
#  .. _reconnect_Environment_Repository:
#
#  reconnect_Environment_Repository
#  --------------------------------
#
#   .. command:: reconnect_Environment_Repository(framework url)
#
#     Reonnect an already connected environment's repository to another remote.
#
#     :environment: the name of the environment
#
#     :url: the url of the environment's remote
#
function(reconnect_Environment_Repository environment url)
execute_process(COMMAND git remote set-url origin ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment})
execute_process(COMMAND git pull origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment})#updating master
endfunction(reconnect_Environment_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |is_Environment_Connected| replace:: ``is_Environment_Connected``
#  .. _is_Environment_Connected:
#
#  is_Environment_Connected
#  ------------------------
#
#   .. command:: is_Environment_Connected(CONNECTED environment remote)
#
#     Tell wether a environment's repository is connected with a given remote.
#
#     :environment: the name of target environment
#
#     :remote: the name of the remote
#
#     :CONNECTED: the output variable that is TRUE if environment is connected to the remote, FALSE otherwise (including if the remote does not exist)
#
function(is_Environment_Connected CONNECTED environment remote)
	execute_process(COMMAND git remote show ${remote}
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} OUTPUT_QUIET ERROR_VARIABLE res)
	if(NOT res OR res STREQUAL "")
		set(${CONNECTED} TRUE PARENT_SCOPE)
	else()
		set(${CONNECTED} FALSE PARENT_SCOPE)
	endif()
endfunction(is_Environment_Connected)

#.rst:
#
# .. ifmode:: internal
#
#  .. |change_Origin_Environment_Repository| replace:: ``change_Origin_Environment_Repository``
#  .. _change_Origin_Environment_Repository:
#
#  change_Origin_Environment_Repository
#  ------------------------------------
#
#   .. command:: change_Origin_Environment_Repository(environment url)
#
#     Set the origin remote to a completely new address.
#
#     :environment: the name of target environment
#
#     :url: the new url of the origin remote
#
function(change_Origin_Environment_Repository environment url)
execute_process(COMMAND git remote set-url origin ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git pull origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git push origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/environments/${environment} OUTPUT_QUIET ERROR_QUIET)
message("[PID] INFO: Origin remote has been changed to ${url}.")
endfunction(change_Origin_Environment_Repository)

########################################################################################
############## static site repository repository related functions #####################
########################################################################################

#.rst:
#
# .. ifmode:: internal
#
#  .. |clone_Static_Site_Repository| replace:: ``clone_Static_Site_Repository``
#  .. _clone_Static_Site_Repository:
#
#  clone_Static_Site_Repository
#  ----------------------------
#
#   .. command:: clone_Static_Site_Repository(IS_INITIALIZED BAD_URL package url)
#
#     Clone the repository of the static site of a package in adequate folder of the workspace.
#
#     :package: the name of target package
#
#     :url: the git url to clone
#
#     :IS_INITIALIZED: the output variable that is TRUE if package's static site resides in workspace, FALSE otherwise
#
#     :BAD_URL: the output variable that is TRUE if package's static site URL is correct, FALSE otherwise
#
function(clone_Static_Site_Repository IS_INITIALIZED BAD_URL package url)
execute_process(COMMAND git clone ${url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages)

# the static sites may have a different name than its package
extract_Package_Namespace_From_SSH_URL(${url} ${package} NAMESPACE SERVER_ADDRESS EXTENSION)
if(EXTENSION AND NOT EXTENSION STREQUAL "") # there is an extension to the name of the package
	if(EXISTS ${WORKSPACE_DIR}/sites/packages/${package}${EXTENSION} AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package}${EXTENSION})
		execute_process(COMMAND ${CMAKE_COMMAND} -E rename ${WORKSPACE_DIR}/sites/packages/${package}${EXTENSION} ${WORKSPACE_DIR}/sites/packages/${package}
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/pid OUTPUT_QUIET ERROR_QUIET)
	endif()
endif()

if(EXISTS ${WORKSPACE_DIR}/sites/packages/${package} AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package})
	set(${BAD_URL} FALSE PARENT_SCOPE) # if the folder exists it means that the official repository exists but it may be still unintialized
	if(EXISTS ${WORKSPACE_DIR}/sites/packages/${package}/build AND IS_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package}/build
		AND EXISTS ${WORKSPACE_DIR}/sites/packages/${package}/CMakeLists.txt)
		set(${IS_INITIALIZED} TRUE PARENT_SCOPE)
		execute_process(COMMAND git fetch origin
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET) #just in case of
		execute_process(COMMAND git lfs pull origin master
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} )#fetching master branch to get most up to date archives
	else() # the site's repository appear to be non existing
		execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory ${WORKSPACE_DIR}/sites/packages/${package}
                    WORKING_DIRECTORY ${WORKSPACE_DIR}/pid OUTPUT_QUIET ERROR_QUIET) #just in case of
		set(${IS_INITIALIZED} FALSE PARENT_SCOPE)
	endif()
else()
	set(${IS_INITIALIZED} FALSE PARENT_SCOPE)
	set(${BAD_URL} TRUE PARENT_SCOPE)
endif()
endfunction(clone_Static_Site_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |init_Static_Site_Repository| replace:: ``init_Static_Site_Repository``
#  .. _init_Static_Site_Repository:
#
#  init_Static_Site_Repository
#  ---------------------------
#
#   .. command:: init_Static_Site_Repository(CONNECTED package wiki_git_url push_site)
#
#     Initialize a package's static site folder as a git repository.
#
#     :package: the name of the target package
#
#     :site_git_url: the git url of the package static site
#
#     :push_site: if TRUE the origin remote is updated after local initialization
#
#     :CONNECTED: the output variable that is TRUE if package static site is connected to a remote repository
#
function(init_Static_Site_Repository CONNECTED package site_git_url push_site)
execute_process(COMMAND git init
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git remote add origin ${site_git_url}
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git add -f build/.gitignore
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git lfs track "*.tar.gz"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET) #tracking tar.gz archives with git LFS
execute_process(COMMAND git add -A
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET)
execute_process(COMMAND git commit -m "initialization of static site project"
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET)
if(push_site) #if push is required, then synchronized static site local repository with its official repository
	execute_process(COMMAND git push origin master
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET)
	#now testing if everything is OK using the git log command
	execute_process(COMMAND git log --oneline --decorate --max-count=1
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_VARIABLE res ERROR_QUIET)
	if (NOT "${res}" STREQUAL "")
		string(FIND "${res}" "master" INDEX_LOCAL)
		string(FIND "${res}" "origin/master" INDEX_REMOTE)
		if(INDEX_LOCAL GREATER 0 AND INDEX_REMOTE GREATER 0)# both found => the last commit on master branch is tracked by local and remote master branch
			set(${CONNECTED} TRUE PARENT_SCOPE)
			return()
		endif()
	endif()
endif()
set(${CONNECTED} FALSE PARENT_SCOPE)
endfunction(init_Static_Site_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |update_Static_Site_Repository| replace:: ``update_Static_Site_Repository``
#  .. _update_Static_Site_Repository:
#
#  update_Static_Site_Repository
#  -----------------------------
#
#   .. command:: update_Static_Site_Repository(package)
#
#     Update local package's static site repository (pull).
#
#     :package: the name of target package
#
function(update_Static_Site_Repository package)
execute_process(COMMAND git pull origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET)# pulling master branch of origin (in case of) => merge can take place
execute_process(COMMAND git lfs pull origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package})# pulling master branch of origin (in case of) => merge can take place
endfunction(update_Static_Site_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |publish_Static_Site_Repository| replace:: ``publish_Static_Site_Repository``
#  .. _publish_Static_Site_Repository:
#
#  publish_Static_Site_Repository
#  ------------------------------
#
#   .. command:: publish_Static_Site_Repository(package PUBLISHED)
#
#     Commit and push unpublished content of local package's static site repository.
#
#     :package: the name of target package
#
#     :PUBLISHED: the output variable that is TRUE if package static site has been pushed to a remote repository
#
function(publish_Static_Site_Repository package PUBLISHED)
execute_process(COMMAND git status --porcelain
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_VARIABLE res)
if(res)#there is something to commit
	execute_process(COMMAND git add -A
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET)
	execute_process(COMMAND git commit -m "publising ${package} static site"
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET)
endif()
execute_process(COMMAND git pull --ff-only  origin master
                WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET RESULT_VARIABLE PULL_RESULT)#pulling master branch of origin to get modifications (new binaries) that would have been published at the same time (most of time a different binary for another plateform of the package)
if(PULL_RESULT EQUAL 0)
  execute_process(COMMAND git lfs pull origin master
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET) #fetching LFS content
  execute_process(COMMAND git push origin master
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} RESULT_VARIABLE PUSH_RESULT)#pushing to master branch of origin
  if(PUSH_RESULT EQUAL 0)
    set(${PUBLISHED} TRUE PARENT_SCOPE)
    return()
  endif()
endif()
set(${PUBLISHED} FALSE PARENT_SCOPE)
endfunction(publish_Static_Site_Repository)

#.rst:
#
# .. ifmode:: internal
#
#  .. |merge_Static_Site_Repository| replace:: ``merge_Static_Site_Repository``
#  .. _merge_Static_Site_Repository:
#
#  merge_Static_Site_Repository
#  ----------------------------
#
#   .. command:: merge_Static_Site_Repository(package)
#
#     Force the merge of master branch of origin into local package's static site repository.
#
#     :package: the name of target package
#
function(merge_Static_Site_Repository package)
  execute_process(COMMAND git pull -f origin master
                  WORKING_DIRECTORY ${WORKSPACE_DIR}/sites/packages/${package} OUTPUT_QUIET ERROR_QUIET)#pulling master branch of origin to get modifications (new binaries) that would have been published at the same time (most of time a different binary for another plateform of the package)
endfunction(merge_Static_Site_Repository)
