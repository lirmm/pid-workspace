######################################################################
############# function used to navigate between branches #############
######################################################################

###
function(go_To_Integration package)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout integration
		OUTPUT_QUIET ERROR_QUIET)
endfunction(go_To_Integration)
###
function(go_To_Master package)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout master
		OUTPUT_QUIET ERROR_QUIET)
endfunction(go_To_Master)

###
function(go_To_Workspace_Master)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git checkout master
		OUTPUT_QUIET ERROR_QUIET)
endfunction(go_To_Workspace_Master)

###
function(go_To_Workspace_Development)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git checkout development
		OUTPUT_QUIET ERROR_QUIET)
endfunction(go_To_Workspace_Development)

###
function(go_To_Commit package branch)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout ${branch}
		OUTPUT_QUIET ERROR_QUIET)
endfunction(go_To_Commit)

###
function(go_To_Version package version)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout tags/v${version}
		OUTPUT_QUIET ERROR_QUIET)
endfunction(go_To_Version)


###
function(get_Repository_Version_Tags AVAILABLE_VERSIONS package)
set(${AVAILABLE_VERSIONS} PARENT_SCOPE)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git tag -l v*
		OUTPUT_VARIABLE res)

if(NOT res) #no version available => BUG
	return()
endif()
string(REPLACE "\n" ";" GIT_VERSIONS ${res})
set(${AVAILABLE_VERSIONS} ${GIT_VERSIONS} PARENT_SCOPE)
endfunction(get_Repository_Version_Tags)

###
function(get_Repository_Current_Branch BRANCH_NAME package)
set(${BRANCH_NAME} PARENT_SCOPE)
execute_process(COMMAND git branch
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
		OUTPUT_VARIABLE current_branches ERROR_QUIET)
string(REPLACE "\n" ";" GIT_BRANCHES ${current_branches})

foreach(branch IN ITEMS ${GIT_BRANCHES})
	string(REGEX REPLACE "^\\* (.*)$" "\\1" A_BRANCH ${branch})
	if(NOT "${branch}" STREQUAL "${A_BRANCH}")#i.e. match found (this is the current branch)
		set(${BRANCH_NAME} ${A_BRANCH} PARENT_SCOPE)
		break()
	endif()
endforeach()
return()
endfunction(get_Repository_Current_Branch)


###
function(get_Repository_Current_Commit COMMIT_NAME package)
set(${COMMIT_NAME} PARENT_SCOPE)
execute_process(COMMAND git log -n 1
		WORKING_DIRECTORY ${WORKSPACE_DIR}/packages/${package}
		OUTPUT_VARIABLE last_log ERROR_QUIET)
string(REPLACE "\n" ";" LINES ${last_log})
string(REGEX REPLACE "^commit ([^;]+).*$" "\\1" SHA1_ID ${LINES})
set(${COMMIT_NAME} ${SHA1_ID} PARENT_SCOPE)
endfunction(get_Repository_Current_Commit)

######################################################################
############# function used to merge standard branches ###############
######################################################################

###
function(merge_Into_Master package version_string)
go_To_Master(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git merge integration)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git tag -a v${version_string} -m "releasing version ${version_string}")
endfunction(merge_Into_Master)

###
function(merge_Into_Integration package)
go_To_Integration(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git merge master)
endfunction(merge_Into_Integration)

###
function(commit_Current_Repository_Branch package commit_message)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git add --all)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git commit -m "${commit_message}")
endfunction(commit_Current_Repository_Branch)


### registering the address means registering the CMakelists.txt
function(register_Repository_Address package)
go_To_Integration(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git add CMakeLists.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git commit -m "adding repository address to the root CMakeLists.txt file")
endfunction(register_Repository_Address)

###
function(register_Repository_Version package version_string)
go_To_Integration(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git add CMakeLists.txt)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git commit -m "start new version ${version_string}")
endfunction(register_Repository_Version)

######################################################################
############# function used to publish modifications   ###############
######################################################################

###
function(publish_References_In_Workspace_Repository package)
if(EXISTS ${WORKSPACE_DIR}/share/cmake/find/Find${package}.cmake AND EXISTS ${WORKSPACE_DIR}/share/cmake/references/Refer${package}.cmake)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git add share/cmake/find/Find${package}.cmake)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git add share/cmake/references/Refer${package}.cmake)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git commit -m "${package} registered")
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR} git push origin master)
else()
	message("ERROR : problem registering package ${package}, cannot generate adequate cmake files")
endif()
endfunction(publish_References_In_Workspace_Repository)

###
function(publish_Repository_version package version_string)
go_To_Master(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin master)#releasing on master branch
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin v${version_string})#releasing version tag
endfunction(publish_Repository_version)


######################################################################
############################ other functions #########################
######################################################################

###
function(init_Repository package)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git init)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git add --all)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git commit -m "initialization of package done")
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git tag -a v0.0.0 -m "creation of package")
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git checkout -b integration master)
endfunction(init_Repository)

###
function(connect_Repository package url remote_name)
go_To_Integration(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git remote add ${remote_name} ${git_url})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git fetch ${remote_name})
go_To_Master(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin --tags)
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin master)
go_To_Integration(${package})
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git push origin integration)
endfunction(connect_Repository)

###
function(save_Repository_Context INITIAL_COMMIT SAVED_CONTENT package)
get_Repository_Current_Branch(BRANCH_NAME ${package})
if(NOT BRANCH_NAME)
get_Repository_Current_Commit(COMMIT_NAME ${package})
set(CONTEXT ${COMMIT_NAME})
else()
set(CONTEXT ${BRANCH_NAME})
endif()
set(${INITIAL_COMMIT} ${CONTEXT} PARENT_SCOPE)

execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git stash save 
	OUTPUT_VARIABLE res)
if(res MATCHES "No stash found")
	set(${SAVED_CONTENT} FALSE PARENT_SCOPE)
else()
	set(${SAVED_CONTENT} TRUE PARENT_SCOPE)
endif()
endfunction(save_Repository_Context)

###
function(restore_Repository_Context package initial_commit saved_content)
go_To_Commit(${package} ${initial_commit})
if(saved_content)
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${WORKSPACE_DIR}/packages/${package} git stash pop)
endif()
endfunction(restore_Repository_Context)

###
function(update_Local_Git_Repository package)
go_To_Integration(${package})
commit_Current_Repository_Branch(${package} "prepare synchronization with repository")
go_To_Master(${package})
commit_Current_Repository_Branch(${package} "prepare synchronization with repository")
go_To_Integration(${package})
endfunction(update_Local_Git_Repository)

