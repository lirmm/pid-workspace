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

CMAKE_MINIMUM_REQUIRED(VERSION 3.0.2)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/api)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/commands)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/platforms)

include(PID_Workspace_Internal_Functions NO_POLICY_SCOPE)

PROJECT(pid-workspace C CXX ASM)

manage_Platforms(${CMAKE_SOURCE_DIR}) # define the current platform in use and provide to the user some options to control finally targetted platform
manage_Migrations()

set(PACKAGE_BINARY_INSTALL_DIR ${CMAKE_SOURCE_DIR}/install CACHE INTERNAL "")
#spefici user entry to manage CI process speicifities
option(IN_CI_PROCESS "Determine wether the build takes place in a CI environment (ON) or not (default to OFF)." OFF)
mark_as_advanced(IN_CI_PROCESS)

configure_Git()
if(NOT GIT_CONFIGURED)
	message(FATAL_ERROR "[PID] CRITICAL ERROR: your git tool is NOT configured. To use PID you need to configure git:\n git config --global user.name \"Your Name\" \n git config --global user.email <your email address> \n")
endif()

reset_Contribution_Spaces() #define what is available
manage_Plugins() # define available plugins and plugins in use

###### automatically managing reference to official remote repository #####
set(PID_OFFICIAL_REMOTE_ADDRESS "https://gite.lirmm.fr/pid/pid-workspace.git" CACHE STRING "address of the official PID repository") #this is the "central" repo for PID system
execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git remote -v OUTPUT_VARIABLE res)
string(REPLACE "\n" ";" GIT_REMOTES ${res})
set(OFFICIAL_EXISTS)
foreach(remote IN LISTS GIT_REMOTES)# for each git remote defined in repository
	if(remote)#guard to avoid last semincolon to generate an empty element that makes the reges command crash
		string(REGEX REPLACE "^[ \t]*official[ \t]+([^ \t]+)[ \t]*\\(fetch\\)(.*)$" "\\1" OFFICIAL_ADDR ${remote})
		if(NOT "${remote}" STREQUAL "${OFFICIAL_ADDR}")#i.e. match => official already exists
			set(OFFICIAL_EXISTS ${OFFICIAL_ADDR})
			break()
		endif()
	endif()
endforeach()
if(NOT OFFICIAL_EXISTS) # automatically create a branch called official that points to the official remote. This is a sanity action to avoid troubles on updates / deployments.
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git remote add official ${PID_OFFICIAL_REMOTE_ADDRESS})
elseif(NOT OFFICIAL_EXISTS STREQUAL PID_OFFICIAL_REMOTE_ADDRESS)#strange thing remote may have changed
	execute_process(COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_SOURCE_DIR} git remote set-url official ${PID_OFFICIAL_REMOTE_ADDRESS})
endif()


##### management of PID version #####
# set the current PID version to memorize when updating the workspace.
set(PID_SYSTEM_VERSION 4 CACHE INTERNAL "")
configure_file(${CMAKE_SOURCE_DIR}/cmake/patterns/PID_version.cmake.in ${CMAKE_BINARY_DIR}/PID_version.cmake @ONLY) #put it into a file to allow packages to easily retrieve PID version information


#1) reset information about categories
reset_All_Categories()
#2) list the content of the workspace to get clean information about packages and framework
reset_Workspace_Content_Information()
#3) classifying packages w.r.t. framework and categories (framework are set of categories and packages belong to some categories)
classify_Packages()
#4) creating the file that will be used to manage information about categories, packages and frameworks in script file
write_Categories_File()

#adding custom targets providing workspace level commands
add_custom_target(man ALL
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo "  ----- Available PID commands -----"
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " man:        print information about available workspace commands."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " info:       print information about the workspace. With no argument, prints the current"
	COMMAND ${CMAKE_COMMAND} -E echo "             version of PID."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [choose one of them] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - framework=*name of a framework* or all: print information about a framework and list"
	COMMAND ${CMAKE_COMMAND} -E echo "               all packages of the framework, ordered by categories defined by the framework. If"
	COMMAND ${CMAKE_COMMAND} -E echo "               all is specified then list all available frameworks."
	COMMAND ${CMAKE_COMMAND} -E echo "             - package=*name of a package* or all: print information about a package. If all is specified"
	COMMAND ${CMAKE_COMMAND} -E echo "               then list all available packages ordered by categories."
	COMMAND ${CMAKE_COMMAND} -E echo "             - license=*name of a license* or all: print information on the license. If all is specified"
	COMMAND ${CMAKE_COMMAND} -E echo "               then list all available licenses"
	COMMAND ${CMAKE_COMMAND} -E echo "             - environment=*name of an environment* or all : print information on the environment. If all"
	COMMAND ${CMAKE_COMMAND} -E echo "               is specified then list all available environments."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " deploy:     deploy a deployment unit into workspace, either a package, a framework or an environment."
	COMMAND ${CMAKE_COMMAND} -E echo "             For a package, either native or external, it can deploy it either from soure repository or"
	COMMAND ${CMAKE_COMMAND} -E echo "             from binary relocatable archive."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [choose one of them] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - package=*name of a package*: deploy source repository of a native package or"
	COMMAND ${CMAKE_COMMAND} -E echo "               external package wrapper."
	COMMAND ${CMAKE_COMMAND} -E echo "             - framework=*name of a framework*: deploy a framework from its repository."
	COMMAND ${CMAKE_COMMAND} -E echo "             - environment=*name of an environment*: deploy an environment from its repository."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments for package argument [optional] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - version=*version number*: deploy a specific version, mandatory for an external package."
	COMMAND ${CMAKE_COMMAND} -E echo "             - no_source=true: force the download of an existing binary package version archive."
	COMMAND ${CMAKE_COMMAND} -E echo "             - force=true: force deployment even if the adequate version already lies in the workspace."
	COMMAND ${CMAKE_COMMAND} -E echo "             - verbose=true: get more debug information during the deployment process"
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments for native package only [optional] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - branch=*name of a branch*: deploy a package reposiotry from a specific branch."
	COMMAND ${CMAKE_COMMAND} -E echo "             - test=true: run tests to complete the deployment."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " resolve:    resolve runtime dependencies of an already installed native package. Used to fix missing"
	COMMAND ${CMAKE_COMMAND} -E echo "             runtime dependencies without rebuilding, for instance after you moved the workspace."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [mandatory] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - package=*name of a package*: target package to resolve."
	COMMAND ${CMAKE_COMMAND} -E echo "             - version=*version number*: specify the version of target package."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " create:     create a new deployment unit, either package, wrapper, environment or framework."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [choose one of them] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - package=*name*: create a native package."
	COMMAND ${CMAKE_COMMAND} -E echo "             - wrapper=*name*: create an external package wrapper."
	COMMAND ${CMAKE_COMMAND} -E echo "             - framework=*name*: create a framework."
	COMMAND ${CMAKE_COMMAND} -E echo "             - environment=*name*: create an environment."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [optional] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - author=*author name*: set the author name, default is current user."
	COMMAND ${CMAKE_COMMAND} -E echo "             - affiliation=*author affiliation*: set the author institution name."
	COMMAND ${CMAKE_COMMAND} -E echo "             - license=*license name*: define a license for the project created, default is CeCILL."
	COMMAND ${CMAKE_COMMAND} -E echo "             - url=*url*: set the official address of the remote repository to which the created"
	COMMAND ${CMAKE_COMMAND} -E echo "               project is connected to. This mostly do the same as connect command."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments for frameworks [optional] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             site=*web site url*: set the URL of the website generated by the framework."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " connect:    synchronize local git repository of a project with a remote one."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [choose one of them] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - package=*name*: connect a native package with a git remote."
	COMMAND ${CMAKE_COMMAND} -E echo "             - wrapper=*name*: connect an external package wrapper with a git remote."
	COMMAND ${CMAKE_COMMAND} -E echo "             - framework=*name*: connect a framework with a git remote."
	COMMAND ${CMAKE_COMMAND} -E echo "             - environment=*name*: connect an environment with a git remote."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [choose one of them] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - official=*git url*: set the official remote of the local repository."
	COMMAND ${CMAKE_COMMAND} -E echo "               This can only be set on an empty remote repository."
	COMMAND ${CMAKE_COMMAND} -E echo "             - origin=*git url*: set the origin remote of the local repository, used by project developpers."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Argument for official argument [optional] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - force=true: force the update of the official repository. Used together with official."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " uninstall:  uninstall package versions from workspace. Works for native or external packages."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [mandatory] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - package=*name of package*: define the package to uninstall"
	COMMAND ${CMAKE_COMMAND} -E echo "             - version=*a valid number* or all: define the version to uninstall. If all is specified then"
	COMMAND ${CMAKE_COMMAND} -E echo "               uninstall all installed versions of the package."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " remove:     remove a deployment unit from the workspace. This leads to remove its repository and all its"
	COMMAND ${CMAKE_COMMAND} -E echo "             installed versions."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [choose one of them] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - package=*name of the package*: remove target native or external package."
	COMMAND ${CMAKE_COMMAND} -E echo "             - framework=*name of the framework*: remove target framework."
	COMMAND ${CMAKE_COMMAND} -E echo "             - environment=*name of the environment*: remove target environment."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " register:   register a deployment unit into workspace. This results in updating the contribution space"
	COMMAND ${CMAKE_COMMAND} -E echo "             that contains  or will contain the references to the deployment unit. After this operation"
	COMMAND ${CMAKE_COMMAND} -E echo "             the deployment unit can now be deployed by people owning the adequate rights, or anyone if"
	COMMAND ${CMAKE_COMMAND} -E echo "             deployment unit is public."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [choose one of them] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - package=*name of the package*: register a native or external package."
	COMMAND ${CMAKE_COMMAND} -E echo "             - framework=*name of the framework*: register a framework."
	COMMAND ${CMAKE_COMMAND} -E echo "             - environment=*name of the environment*: register an environment."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " release:    release the target native package. Release process consists in:"
	COMMAND ${CMAKE_COMMAND} -E echo "             - merging branches and tagging the package repository."
	COMMAND ${CMAKE_COMMAND} -E echo "             - push repository to its remotes."
	COMMAND ${CMAKE_COMMAND} -E echo "             - update package description to prepare next release."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [mandatory] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - package=*name of the package*: target package to release."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [optional] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - nextversion=MAJOR or MINOR or PATCH: indicates which version number to increase."
	COMMAND ${CMAKE_COMMAND} -E echo "             - recursive=true: makes the release process recursive so that if version of dependencies have"
	COMMAND ${CMAKE_COMMAND} -E echo "               not been released yet, they are released before starting target package release."
	COMMAND ${CMAKE_COMMAND} -E echo "             - branch=*branch name*: perform the release from another branch than default integration"
	COMMAND ${CMAKE_COMMAND} -E echo "               branch. This allows to release patches for previous version tahn current one in git history."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " build:      build target native package."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [mandatory] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - package=*name of the package* or all: target package to build. If all is used then"
	COMMAND ${CMAKE_COMMAND} -E echo "             	 all native packages in workspace will be built. all is default value."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " hard_clean: deep cleaning of package build folder. May be usefull after compiler changes for instance."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [mandatory] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - package=*name of the package* or all: clean the target package. If all is used then all"
	COMMAND ${CMAKE_COMMAND} -E echo "               source packages in workspace are cleaned."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " rebuild:    force the rebuild of target native package. This hard clean the build tree of the package and launch"
 	COMMAND ${CMAKE_COMMAND} -E echo "             its build process"
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [mandatory] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - package=*name of the package* or all: target package to build. If all is used then"
	COMMAND ${CMAKE_COMMAND} -E echo "             	 all native packages in workspace will be rebuilt. all is default value"
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " update:     update a native package. The last available version of this package is deployed in the workspace."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [mandatory] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - package=*name of the package* or all : target package to update. If *all* is used all source"
	COMMAND ${CMAKE_COMMAND} -E echo "               and binary packages will be updated."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " upgrade:    upgrade the workspace. It installs the more recent version of the PID API and update all"
	COMMAND ${CMAKE_COMMAND} -E echo "             contribution spaces in use."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [optional] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - official=false: use a non official repository, the one pointed by origin, to update the workspace."
	COMMAND ${CMAKE_COMMAND} -E echo "             - update=true: update all packages once the upgrade has been done."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " configure:  configure the workspace. Used to configure the current build environment for the while workspace."
	COMMAND ${CMAKE_COMMAND} -E echo "             Additional arguments can be used to customize the configuration process."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [mandatory] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - environment=*name of the environment*: set the given environment as the build environment to use "
	COMMAND ${CMAKE_COMMAND} -E echo "               for the whole workspace. If value is host then the build environment is reset to default OS settings."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Optional arguments ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - sysroot=*path*: set the sysroot path when environment is used to cross compile."
	COMMAND ${CMAKE_COMMAND} -E echo "             - staging=*path*: set the staging path when environment is used to cross compile."
	COMMAND ${CMAKE_COMMAND} -E echo "             - platform=*platform string*: set the target platform corresponding to the environment. This "
	COMMAND ${CMAKE_COMMAND} -E echo "               is usefull when the environment in use does not completely describe its target platform."
	COMMAND ${CMAKE_COMMAND} -E echo "             - distribution=*string*: set the target distribution corresponding to the environment. This "
	COMMAND ${CMAKE_COMMAND} -E echo "               is usefull when the environment in use does not define its target distribution."
	COMMAND ${CMAKE_COMMAND} -E echo "             - distrib_version=*string*: set the target distribution version corresponding to the environment."
	COMMAND ${CMAKE_COMMAND} -E echo "               This is usefull when the environment in use does not define its target distribution version."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	COMMAND ${CMAKE_COMMAND} -E echo " manage:     manage contribution spaces in use in the workspace."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments [mandatory] ---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - cmd=*name of the command*: apply the given command to contribution spaces. Possible values:"
	COMMAND ${CMAKE_COMMAND} -E echo "               - ls: list currenlty used contribution spaces."
	COMMAND ${CMAKE_COMMAND} -E echo "               - reset: remove all contribution space in use and go back to workspace original configuration."
	COMMAND ${CMAKE_COMMAND} -E echo "               - add: add a new contribution space to use."
	COMMAND ${CMAKE_COMMAND} -E echo "               - rm: remove a contribution space in use."
	COMMAND ${CMAKE_COMMAND} -E echo "               - churl: change remotes used for the contribution space."
	COMMAND ${CMAKE_COMMAND} -E echo "               - prio_min: give to the contribution space the lowest priority."
	COMMAND ${CMAKE_COMMAND} -E echo "               - prio_max: give to the contribution space the highest priority."
	COMMAND ${CMAKE_COMMAND} -E echo "               - publish: publish the content the contribution space."
	COMMAND ${CMAKE_COMMAND} -E echo "               - update: update the content the contribution space."
	COMMAND ${CMAKE_COMMAND} -E echo "               - status: see the new content into a contribution space. Usefull in combination to move/copy"
	COMMAND ${CMAKE_COMMAND} -E echo "                 and publish commands to migrate contributions from one contribution space to another."
	COMMAND ${CMAKE_COMMAND} -E echo "               - move: move a contribution from one contribution space to another."
	COMMAND ${CMAKE_COMMAND} -E echo "               - copy: copy a contribution from one contribution space to another."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Argument for add, rm, churl, prio_min, prio_max, status, publish, update, move, copy [mandatory]---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - space=*name*: name of the target contribution space. This argument is mandatory."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments for add and churl commands [optional or mandatory]---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - update=*URL*: URL of the remote used to update the contribution space. Mandatory for add command."
	COMMAND ${CMAKE_COMMAND} -E echo "             - publish=*URL*: URL of the remote used to publish new content into the contribution space. Mandatory"
	COMMAND ${CMAKE_COMMAND} -E echo "               for churl command."
	COMMAND ${CMAKE_COMMAND} -E echo "             --- Arguments for move and copy commands [mandatory]---"
	COMMAND ${CMAKE_COMMAND} -E echo "             - from=*contribution space*: name of the contribution space to move or copy content from."
	COMMAND ${CMAKE_COMMAND} -E echo "                target space is the one specified using space argument."
	COMMAND ${CMAKE_COMMAND} -E echo "             - content=*name*: name of the content to move or copy. This content must belong to contribution"
	COMMAND ${CMAKE_COMMAND} -E echo "               space specified by from argument. The content may refer to configruation and or reference files,"
	COMMAND ${CMAKE_COMMAND} -E echo "               and/or find files, and/or licenses and/or plugin. All files and folders matching the given name will"
	COMMAND ${CMAKE_COMMAND} -E echo "               be moved or copied."
	COMMAND ${CMAKE_COMMAND} -E echo ""
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## getting info on the workspace, packages, frameworks or licenses
add_custom_target(info
	COMMAND ${CMAKE_COMMAND} -DTARGET_PACKAGE="\${package}"
					-DTARGET_FRAMEWORK=\${framework}
					-DTARGET_ENVIRONMENT=\${environment}
					-DTARGET_LICENSE=\${license}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Print_PID_Workspace_Info.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## deploying a package (either soure repository or binary package relocatable archive)
add_custom_target(deploy
	COMMAND ${CMAKE_COMMAND} -DDEPLOYED_PACKAGE=\${package}
					-DTARGET_VERSION=\${version}
					-DDEPLOYED_ENVIRONMENT=\${environment}
					-DDEPLOYED_FRAMEWORK=\${framework}
					-DVERBOSE_MODE=\${verbose}
					-DFORCE_REDEPLOY=\${force}
					-DNO_SOURCE=\${no_source}
					-DUSE_BRANCH=\${branch}
					-DRUN_TESTS=\${test}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Deploy_PID_Deployment_Unit.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## building a list of source packages
add_custom_target(build
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGES="\${package}"
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Build_PID_Packages.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## rebuilding a list of source packages
add_custom_target(rebuild
	COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGES="\${package}"
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Rebuild_PID_Packages.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## resolving runtime dependencies of an already installed package
add_custom_target(resolve
	COMMAND ${CMAKE_COMMAND} 	-DRESOLVED_PACKAGE=\${package}
					-DTARGET_VERSION=\${version}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Resolve_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## creating a new package
add_custom_target(create
COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=\${package}
					-DTARGET_FRAMEWORK=\${framework}
					-DTARGET_WRAPPER=\${wrapper}
					-DTARGET_ENVIRONMENT=\${environment}
					-DOPTIONAL_AUTHOR="\${author}"
					-DOPTIONAL_INSTITUTION="\${affiliation}"
					-DOPTIONAL_LICENSE=\${license}
					-DOPTIONNAL_GIT_URL=\${url}
					-DOPTIONNAL_SITE=\${site}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Create_PID_Deployment_Unit.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## connect to newly created PID package to an existing empty repository
add_custom_target(connect
COMMAND ${CMAKE_COMMAND} 	-DTARGET_FRAMEWORK=\${framework}
					-DTARGET_PACKAGE=\${package}
					-DTARGET_WRAPPER=\${wrapper}
					-DTARGET_ENVIRONMENT=\${environment}
					-DOFFICIAL_GIT_URL=\${official}
					-DORIGIN_GIT_URL=\${origin}
					-DFORCED_RECONNECTION=\${force}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-DCMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Connect_PID_Deployment_Unit.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)


## clearing a package install directory
add_custom_target(uninstall
COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=\${package}
					-DTARGET_VERSION=\${version}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Clear_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## clearing a package install directory
add_custom_target(hard_clean
COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=\${package}
					-DRECONFIGURE=\${configure}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Hard_Clean_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## completely remove a package from workspace
add_custom_target(remove
COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=\${package}
					-DTARGET_FRAMEWORK=\${framework}
					-DTARGET_ENVIRONMENT=\${environment}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Remove_PID_Deployment_Unit.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## register a package in the workspace
add_custom_target(register
COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=\${package}
					-DTARGET_FRAMEWORK=\${framework}
					-DTARGET_ENVIRONMENT=\${environment}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Register_PID_Deployment_Unit.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## releasing a package
add_custom_target(release
COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=\${package}
					-DNEXT_VERSION=\${nextversion}
					-DFROM_BRANCH=\${branch}
					-DAUTOMATIC_RELEASE=\${recursive}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Release_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## updating a package
add_custom_target(update
COMMAND ${CMAKE_COMMAND} 	-DTARGET_PACKAGE=\${package}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Update_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## upgrading the workspace
add_custom_target(upgrade
COMMAND ${CMAKE_COMMAND} 	-DTARGET_OFFICIAL=\${official}
					-DUPDATE_ALL_PACKAGES=\${update}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Upgrade_PID_Workspace.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## upgrading the workspace
add_custom_target(system_install
COMMAND ${CMAKE_COMMAND} 	-DINSTALLED_PACKAGE=\${package}
					-DTARGET_VERSION=\${version}
					-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
					-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
					-DINSTALL_FOLDER=\${folder}
					-DINSTALL_MODE=\${mode}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Install_PID_Package.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## configuring the workspace
add_custom_target(configure
COMMAND ${CMAKE_COMMAND} -DTARGET_ENVIRONMENT=\${environment}
					-DTARGET_SYSROOT=\${sysroot}
					-DTARGET_STAGING=\${staging}
					-DTARGET_PLATFORM=\${platform}
					-DTARGET_PROC_TYPE=\${type}
					-DTARGET_PROC_ARCH=\${arch}
					-DTARGET_OS=\${os}
					-DTARGET_ABI=\${abi}
					-DTARGET_DISTRIBUTION=\${distribution}
					-DTARGET_DISTRIBUTION_VERSION=\${distrib_version}
					-DIN_CI_PROCESS=${IN_CI_PROCESS}
					-DCURRENT_ENVIRONMENT=${CURRENT_ENVIRONMENT}
					-DCURRENT_PLATFORM=${CURRENT_PLATFORM}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM} #using default or current native build system
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Configure_PID_Environment.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

## manage contribution spaces
add_custom_target(manage
COMMAND ${CMAKE_COMMAND}
					-DTARGET_COMMAND=\${cmd}
					-DTARGET_CS=\${space}
					-DUPDATE_URL=\${update}
					-DPUBLISH_URL=\${publish}
					-DSOURCE_CS=\${from}
					-DCONTENT_TO_OPERATE=\${content}
					-DIN_CI_PROCESS=${IN_CI_PROCESS}
					-DWORKSPACE_DIR=${CMAKE_SOURCE_DIR}
					-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM} #using default or current native build system
					-P ${CMAKE_SOURCE_DIR}/cmake/commands/Manage_PID_Contribution_Spaces.cmake
	WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
