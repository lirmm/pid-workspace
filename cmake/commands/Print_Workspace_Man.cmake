set(man_cmd_desc
"man               Print information about available workspace commands and their usage.\n"
)
set(man_cmd_args
"                  --- Argument ---\n"
"                  cmd=<command>\n"
"                    Print detailed information about the given command.\n"
)

set(list_cmd_desc
"list              List the available workspace commands.\n"
)

set(full_cmd_desc
"full              List the available workspace commands along with their arguments.\n"
)

set(info_cmd_desc
"info              Print information about the workspace. With no argument, prints the current version of PID.\n"
)
set(info_cmd_args
"                  --- Arguments (one of) ---\n"
"                  framework=<name> | all\n"
"                    Print information about a framework and list all packages of the framework, ordered by categories defined by the framework.\n"
"                    If all is specified then list all available frameworks.\n\n"
"                  package=<name> | all\n"
"                    Print information about a package. If all is specified then list all available packages ordered by categories.\n\n"
"                  environment=<name> | all\n"
"                    Print information on the environment. If all is specified then list all available environments.\n\n"
"                  license=<name> | all\n"
"                    Print information on the license. If all is specified then list all available licenses\n\n"
"                  language=<name> | all\n"
"                    Print information on the langague. If all is specified then list all available languages\n\n"
"                  search=<expression>\n"
"                    Search for package whose description matches the given expression. Expression is a comma separated list of words without spaces,\n"
"                    each word can be a CMake regular expression.\n\n"
"                  strict=true | false\n"
"                    Used with search argument. Tell wether the given terms of the expression must exactly matches.\n"
"                    It is false by default, meaning that the search engine append some automatic regular expression to the given words.\n"
)

set(deploy_cmd_desc
"deploy            Deploy a deployment unit into workspace, either a package, a framework or an environment.\n"
"                  For a package, either native or external, it can deploy it either from soure repository or from binary relocatable archive.\n"
)
set(deploy_cmd_args
"                  --- Arguments (one of) ---\n"
"                  package=<name>\n"
"                    Deploy source repository of a native package or external package wrapper.\n\n"
"                  framework=<name>\n"
"                    Deploy a framework from its repository.\n\n"
"                  environment=<name>\n"
"                    Deploy an environment from its repository.\n\n\n"
"                  --- [optional] Parameters for package argument ---\n"
"                  version=<version>\n"
"                    Deploy a specific version, mandatory for an external package.\n\n"
"                  use_binaries=true | false\n"
"                    Force the download of an existing binary package version archive.\n\n"
"                  use_source=true | false\n"
"                    Force the compilation of package sources.\n\n"
"                  force=true | false\n"
"                    Force deployment even if the adequate version already lies in the workspace.\n\n"
"                  verbose=true | false\n"
"                    Get more debug information during the deployment process\n\n\n"
"                  --- [optional] Parameters for native packages only ---\n"
"                  branch=<name>\n"
"                    Deploy a package repository from a specific branch.\n\n"
"                  test=true | false\n"
"                    Run tests to complete the deployment.\n"
)

set(resolve_cmd_desc
"resolve           Resolve runtime dependencies of an already installed native package. Used to fix missing\n"
"                  runtime dependencies without rebuilding, for instance after you moved the workspace.\n"
)
set(resolve_cmd_args
"                  --- Arguments (all required) ---\n"
"                  package=<name>\n"
"                    Target package to resolve.\n"
"                  version=<version>\n"
"                    Specify the version of target package.\n"
)

set(create_cmd_desc
"create            Create a new deployment unit, either package, wrapper, environment or framework.\n"
)
set(create_cmd_args
"                  --- Arguments (one of) ---\n"
"                  package=<name>\n"
"                    Create a native package.\n"
"                  wrapper=<name>\n"
"                    Create an external package wrapper.\n"
"                  framework=<name>\n"
"                    Create a framework.\n"
"                  environment=<name>\n"
"                    Create an environment.\n\n"
"                  --- [optional] Parameters (default to PID_DEFAULT_* environment variables) ---\n"
"                  author=<name>\n"
"                    Set the author name, default is current user.\n"
"                  affiliation=<affiliation>\n"
"                    Set the author institution name.\n"
"                  email=<address>\n"
"                    Set the author email.\n"
"                  license=<name>\n"
"                    Define a license for the project created, default is CeCILL.\n"
"                  code_style=<name>\n"
"                    Define a code style for the project created.\n"
"                  url=<url>\n"
"                    Set the official address of the remote repository to which the created\n"
"                    project is connected to. This mostly do the same as connect command.\n\n"
"                  --- [optional] Parameters for frameworks ---\n"
"                  site=<url>\n"
"                    Set the URL of the website generated by the framework.\n"
)

set(connect_cmd_desc
"connect           Synchronize local git repository of a project with a remote one.\n"
)
set(connect_cmd_args
"                  --- Arguments (one of) ---\n"
"                  package=<name>\n"
"                    Connect a native package with a git remote.\n"
"                  wrapper=<name>\n"
"                    Connect an external package wrapper with a git remote.\n"
"                  framework=<name>\n"
"                    Connect a framework with a git remote.\n"
"                  environment=<name>\n"
"                    Connect an environment with a git remote.\n\n"
"                  --- Parameters (one of) ---\n"
"                  official=<git url>\n"
"                    Set the official remote of the local repository.\n"
"                    This can only be set on an empty remote repository.\n"
"                  origin=<git url>\n"
"                    Set the origin remote of the local repository, used by project developpers.\n\n"
"                  --- [optional] Parameter for official argument ---\n"
"                  force=true | false\n"
"                    Force the update of the official repository. Used together with official.\n"
)

set(uninstall_cmd_desc
"uninstall         Uninstall package versions from workspace. Works for native or external packages.\n"
)
set(uninstall_cmd_args
"                  --- Arguments (all required) ---\n"
"                  package=<name>\n"
"                    Define the package to uninstall\n"
"                  version=<version> | all\n"
"                    Define the version to uninstall. If all is specified then uninstall all installed versions of the package.\n"
)

set(remove_cmd_desc
"remove            Remove a deployment unit from the workspace. This leads to remove its repository and all its installed versions.\n"
)
set(remove_cmd_args
"                  --- Arguments (one of) ---\n"
"                  package=<name>\n"
"                    Remove target native or external package.\n"
"                  framework=<name>\n"
"                    Remove target framework.\n"
"                  environment=<name>\n"
"                    Remove target environment.\n"
)

set(register_cmd_desc
"register          Register a deployment unit into from contribution space, updates the contribution space\n"
"                  that contains  or will contain the references to the deployment unit. After this operation\n"
"                  the deployment unit can now be deployed by people owning the adequate rights, or anyone if\n"
"                  deployment unit is public.\n"
)
set(register_cmd_args
"                  --- Arguments (one of) ---\n"
"                  package=<name>\n"
"                    Register a native or exte\nral package.\n"
"                  framework=<name>\n"
"                    Register a framework.\n"
"                  environment=<name>\n"
"                    Register an environment.\n\n"
"                  --- [optional] Parameter ---\n"
"                  space=<name>\n"
"                    Force to register into a given contribution space.\n"
)

set(unregister_cmd_desc
"unregister        Unregister a deployment unit from contribution space, updates the contribution space that\n"
"                  contains, and will no more contain  the references to the deployment unit. After this operation\n"
"                  the deployment unit can no more be deployed using the target contribution space.\n"
)
set(unregister_cmd_args
"                  --- Arguments (one of) ---\n"
"                  package=<name>\n"
"                    Unregister a native or external package.\n"
"                  framework=<name>\n"
"                    Unregister a framework.\n"
"                  environment=<name>\n"
"                    Unregister an environment.\n\n"
"                  --- [optional] Parameter ---\n"
"                  space=<name>\n"
"                    Force to unregister only for the given contribution space.\n"
)

set(release_cmd_desc
"release           Release the target native package. Release process consists in:\n"
"                   1. merging branches and tagging the package repository.\n"
"                   2. push repository to its remotes.\n"
"                   3. update package description to prepare next release.\n"
)
set(release_cmd_args
"                  --- Argument ---\n"
"                  package=<name>\n"
"                    Target package to release.\n\n"
"                  --- [optional] Parameters ---\n"
"                  nextversion=major | minor | patch\n"
"                    Indicates which version number to increase.\n"
"                  recursive=true | false\n"
"                    Makes the release process recursive so that if version of dependencies have\n"
"                    not been released yet, they are released before starting target package release.\n"
"                  branch=<name>\n"
"                    Perform the release from another branch than default integration branch.\n"
"                    This allows to release patches for previous version than current one in git history.\n"
"                  patch=<version>\n"
"                    Alternative to branch parameter. Perform the release from a patch branch\n"
"                    that has been created using patching command -e.g. with name patch-0.5.4.\n"
)

set(deprecate_cmd_desc
"deprecate         Deprecate versions of the target native package. It consists in:\n"
"                   1. untagging the package repository.\n"
"                   2. regenerating find file.\n"
)
set(deprecate_cmd_args
"                  --- Argument ---\n"
"                  package=<name>\n"
"                    Target package to deprecate.\n\n"
"                  --- Parameters (at least one of them) ---\n"
"                  major=<version>\n"
"                    Target major versions to deprecate, may be a comma separated list of versions.\n"
"                  minor=<version>\n"
"                    Target minor versions to deprecate, may be a comma separated list of versions.\n"
)

set(build_cmd_desc
"build             Build target native package.\n"
)
set(build_cmd_args
"                  --- Argument ---\n"
"                  package=<name> | all: target package to build. If all is used then\n"
"                  	 all native packages in workspace will be built. all is default value.\n"
)

set(hard_clean_cmd_desc
"hard_clean        Deep cleaning of a build folder. May be usefull after compiler changes for instance.\n"
)
set(hard_clean_cmd_args
"                  --- Arguments (one of) ---\n"
"                  package=<name> | all\n"
"                    Clean the target package. If all is used then all source packages in workspace are cleaned.\n"
"                  framework=<name>\n"
"                    Clean the target framework.\n"
"                  environment=<name>\n"
"                    Clean the target environment.\n"
)

set(rebuild_cmd_desc
"rebuild           Force the rebuild of target native package. This hard clean the build tree of the package and launch its build process\n"
)
set(rebuild_cmd_args
"                  --- Argument ---\n"
"                  package=<name> | all"
"                    Target package to build. If all is used then all native packages in workspace will be rebuilt. all is default value\n"
)

set(update_cmd_desc
"update            Update a deployment unit. For native and external packages the last available version of this package is deployed in the workspace.\n"
)
set(update_cmd_args
"                  --- Arguments (one of) ---\n"
"                  package=<name> | all\n"
"                    Target package to update. If all is used all source and binary packages will be updated.\n"
"                  framework=<name>\n"
"                    Target framework to update.\n"
"                  environment=<name>\n"
"                    Target environment to update.\n"
)

set(upgrade_cmd_desc
"upgrade           Upgrade the workspace. It installs the more recent version of the PID API and update all contribution spaces in use.\n"
)
set(upgrade_cmd_args
"                  --- [optional] parameters ---\n"
"                  official=true | false\n"
"                    Use a non official repository, the one pointed by origin, to update the workspace.\n"
"                  update=true | false\n"
"                    Update all packages once the upgrade has been done.\n"
)

set(sysinstall_cmd_desc
"sysinstall        Install a binary package and all its dependencies into the operating system.\n"
)
set(sysinstall_cmd_args
"                  --- Arguments (all required) ---\n"
"                  package=<name>\n"
"                    Target package to install.\n"
"                  version=<version>\n"
"                    Version of the binary package to install.\n\n"
"                  --- [optional] parameters ---\n"
"                  folder=<path>\n"
"                    Path of the system install folder in which all binaries are installed. If not specified, \n"
"                    the variable CMAKE_INSTALL_PREFIX defined in workspace project will be used as default -e.g. /usr/local.\n"
"                  mode=Debug | Release\n"
"                    The build mode of the binary package to install. If not specified the variable CMAKE_BUILD_TYPE defined in the\n"
"                    workspace project will be used as default -e.g. Release.\n"
)

set(profiles_cmd_desc
"profiles          Manage the profiles in use in the workspace. Used to configure build environments for the whole workspace.\n"
"                  Additional parameters can be used to customize the configuration process.\n"
)
set(profiles_cmd_args
"                  --- Argument ---\n"
"                  cmd=<name>\n"
"                    Apply the given command to profiles. Possible values:\n"
"                      ls     list currenlty defined profiles.\n"
"                      reset  reset currently used profile to default one.\n"
"                      mk     create a new profile and make it current profile.\n"
"                      del    remove an available profile. It it was current one, then current becomes default profile.\n"
"                      load   make the target profile the current one.\n"
"                      add    add an additionnal environment to a target available profile.\n"
"                      rm     remove an additionnal environment from a target available profile.\n\n"
"                  --- [mandatory] Parameters for mk, del, load and optional for add, rm ---\n"
"                  profile=<name>\n"
"                    Name of the target profile. If not specified -for add and rm-, the target profile is default.\n\n"
"                  --- [mandatory] Parameters for mk, add, rm ---\n"
"                  env=<name>\n"
"                    Name of the target environment.\n\n"
"                  --- [optional] Parameters ---\n"
"                  sysroot=<path>\n"
"                    Set the sysroot path when environment is used to cross compile.\n"
"                  staging=<path>\n"
"                    Set the staging path when environment is used to cross compile.\n"
"                  instance=<string>\n"
"                    Set the instance name for target platform.\n"
"                  platform=<platform string>\n"
"                    Set a constraint on the target platform - equivalent to specifying proc_type, proc_arch, os and abi.\n"
"                  proc_type=<os string>\n"
"                    Set a constraint on the target processor type - e.g. x86, arm.\n"
"                  proc_arch=<os string>\n"
"                    Set a constraint on the target processor architecture - e.g. 32, 64.\n"
"                  os=<os string>\n"
"                    Set a constraint on the target operating system - e.g. linux, macosx.\n"
"                  abi=<ABI string>\n"
"                    Set a constraint on the target C++ ABI used - 98 or 11.\n"
"                  distribution=<string>\n"
"                    Set a constraint on the target distribution - e.g. ubuntu.\n"
"                  distrib_version=<string>\n"
"                    Set a constraint on the target distribution version - e.g. 18.04.\n"
)

set(contributions_cmd_desc
"contributions     Manage contribution spaces in use in the workspace.\n"
)
set(contributions_cmd_args
"                  --- Argument ---\n"
"                  cmd=<name>\n"
"                    Apply the given command to contribution spaces. Possible values:\n"
"                      ls        list currenlty used contribution spaces.\n"
"                      reset     remove all contribution space in use and go back to workspace original configuration.\n"
"                      add       add a new contribution space to use.\n"
"                      rm        remove a contribution space in use.\n"
"                      churl     change remotes used for the contribution space.\n"
"                      prio_min  give to the contribution space the lowest priority.\n"
"                      prio_max  give to the contribution space the highest priority.\n"
"                      publish   publish the content the contribution space.\n"
"                      update    update the content the contribution space.\n"
"                      list      see the whole content referenced into a contribution space.\n"
"                      find      find the contribution space that reference a given contribution.\n"
"                      status    see the new content into a contribution space. Usefull in combination to move/copy\n"
"                                and publish commands to migrate contributions from one contribution space to another.\n"
"                      move      move a contribution from one contribution space to another.\n"
"                      copy      copy a contribution from one contribution space to another.\n"
"                      delete    delete a contribution from one contribution space.\n"
"                      clean     clean the repository of a contribution space.\n\n"
"                  --- [mandatory] Parameters for add, rm, churl, prio_min, prio_max, list, status, publish, update, move, copy, delete and clean ---\n"
"                  space=<name>\n"
"                    Name of the target contribution space. This parameter is mandatory except for add command.\n\n"
"                  --- Parameters for add and churl commands ---\n"
"                  update=<url>\n"
"                    URL of the remote used to update the contribution space. Mandatory for add command.\n"
"                  publish=<url>\n"
"                    URL of the remote used to publish new content into the contribution space. Mandatory for churl command.\n\n"
"                  --- [mandatory] Parameters for move and copy commands ---\n"
"                  from=<contribution space>\n"
"                    Name of the contribution space to move or copy content from. Target space is the one specified using space parameter.\n\n"
"                  --- [mandatory] Parameters for find, move, copy and delete commands ---\n"
"                  content=<name>\n"
"                    Name of the content to move, copy or delete. This content must belong to contribution\n"
"                    space specified by from parameter. The content may refer to configruation and or reference files,\n"
"                    and/or find files, and/or licenses and/or plugin. All files and folders matching the given name will\n"
"                    be moved / copied / deleted / found.\n"
)

set(all_cmds
    man
    list
    full
    info
    deploy
    resolve
    create
    connect
    uninstall
    remove
    register
    unregister
    release
    deprecate
    build
    hard_clean
    rebuild
    update
    upgrade
    sysinstall
    profiles
    contributions
)

list(TRANSFORM all_cmds APPEND _cmd_desc OUTPUT_VARIABLE all_cmds_desc)

list(JOIN all_cmds ", " all_cmds_str)

if(NOT COMMAND_INFO AND DEFINED ENV{cmd})
	set(COMMAND_INFO $ENV{cmd} CACHE INTERNAL "" FORCE)
endif()
if(DEFINED ENV{cmd})
	unset(ENV{cmd})
endif()

# Handle special commands first
if(COMMAND_INFO STREQUAL "list")
    message("The available commands are: ${all_cmds_str}")
    return()
elseif(COMMAND_INFO STREQUAL "full")
    foreach(cmd IN LISTS all_cmds)
        message(${${cmd}_cmd_desc})
        if(${cmd}_cmd_args)
            message(${${cmd}_cmd_args})
        endif()
    endforeach()
    return()
endif()

if(COMMAND_INFO)
    list(FIND all_cmds ${COMMAND_INFO} cmd_info_index)
    if(cmd_info_index EQUAL -1)
        message("Unknown ${COMMAND_INFO} command. The available commands are: ${all_cmds_str}")
    else()
        message(${${COMMAND_INFO}_cmd_desc})
        if(${COMMAND_INFO}_cmd_args)
            message(${${COMMAND_INFO}_cmd_args})
        endif()
    endif()
else()
    message("----- Available PID commands -----")
    message("")
    message("Pass cmd=<command> to get more help on a given command (e.g pid man cmd=deploy).")
    message("")
    foreach(cmd IN LISTS all_cmds_desc)
        message(${${cmd}})
    endforeach()
endif()
