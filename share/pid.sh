# /!\ This script must stay POSIX compatible so avoid any Bash/ZSH extensions /!\
#
# Since sh might be symlinked to bash or something else on your system,
#  you can try using the dash shell, which is very close to POSIX, to make sure
#  that any modification you make doesn't break compatibility


platform="unknown"
unamestr=$(uname)
if [ "$unamestr" = "Linux" ]; then
   platform="linux"
elif [ "$unamestr" = "FreeBSD" ]; then
   platform="freebsd"
elif [ "$unamestr" = "Darwin" ]; then
   platform="macos"
fi



# Main function to be invoked by users
pid() {
    # Print help if -h or --help is passed
    case $1 in
        "-h"|"--help") _pid_ws_print_help && return 0;;
    esac

    local target=""
    local fake_target=""
    local fake_target_needs_arg=0
    local fake_target_more_arg=false
    local fake_target_args=""
    local cmake_options=""
    local to_unexport=""

    _pid_ws_unset_global_variables

    # Retreive current project and workspace locations
    _pid_ws_get_workspace_dir

    # Exit with an error if a project cannot be found
    if [ ! "$?" = "0" ]; then
        return $res
    fi
    _pid_ws_get_project_name
    # we know that using the pid script is only made by user, never internally
    # by PID commands: we can use this property to clean the global progress
    # file if for any reason it still exists in workspace
    if [ -e $ws_dir/build/pid_progress.cmake ]; then
      rm $ws_dir/build/pid_progress.cmake
    fi

    # Parses all arguments
    #  handle fake and real targets, sets the arguments as environment variables
    #  and save the CMake options
    for arg in $@; do
        if [ "`echo \"$arg\" | cut -c -2`" = "-D" ]; then
            if [ "$cmake_options" ]; then
                cmake_options="$cmake_options $arg"
            else
                cmake_options="$arg"
            fi
        elif [ -z "$target" -a -z "$fake_target" -a "$arg" = "workspace" ]; then
            fake_target=$arg
        elif [ -z "$target" -a -z "$fake_target" -a "$arg" = "configure" ]; then
            fake_target=$arg
        elif [ -z "$target" -a -z "$fake_target" -a "$arg" = "cd" ]; then
            fake_target=$arg
        elif [ -z "$target" -a -z "$fake_target" -a "$arg" = "exec" ]; then
            fake_target=$arg
            fake_target_needs_arg=1
        elif [ -z "$target" -a -z "$fake_target" -a "$arg" = "run" ]; then
            fake_target=$arg
            fake_target_needs_arg=4
            fake_target_more_arg=true
        elif [ -z "$target" -a -z "$fake_target" -a "$arg" = "run_build" ]; then
            fake_target=$arg
            fake_target_needs_arg=2
            fake_target_more_arg=true
        elif [ -n "$fake_target" -a $fake_target_needs_arg -gt 0 ]; then
            # specific arguments used in fake targets needs to be managed first
            if [ "$fake_target_args" ]; then
                fake_target_args="$fake_target_args $arg"
            else
                fake_target_args=$arg
            fi
            fake_target_needs_arg=$((fake_target_needs_arg-1))
        elif [ -n "$fake_target" -a "$fake_target_more_arg" = true ]; then
            # if no more specific argument for fake target BUT fake target
            # allows for program specific arguments
            if [ "$fake_target_args" ]; then
                fake_target_args="$fake_target_args $arg"
            else
                fake_target_args=$arg
            fi
        elif [ -z "$target" ]; then
            target=$arg
        else
            export $arg
            if [ "$to_unexport" ]; then
                to_unexport="$to_unexport $arg"
            else
                to_unexport=$arg
            fi
        fi
    done

    # Execute the given target or any of the "fake" targets
    # First handle "fake" targets
    if [ "$fake_target" = "workspace" ]; then
        # Special case for the "configure" fake target
        if [ "$target" = "configure" ]; then
            _pid_ws_configure $ws_dir "$cmake_options"
        else
            _pid_ws_run $ws_dir $target "$cmake_options"
        fi
    elif [ "$fake_target" = "configure" ]; then
        _pid_ws_configure $project_dir "$cmake_options"
    elif [ "$fake_target" = "cd" ]; then
        _pid_ws_get_abs_path $target
        if [ "$abs_path" ]; then
            cd $abs_path
        fi
    elif [ "$fake_target" = "exec" ]; then
        if [ -z "$fake_target_args" ]; then
            echo "The exec target requires a package followed by a target to execute as parameters"
        else
            _pid_ws_get_abs_path $fake_target_args
            if [ "$abs_path" ]; then
                _pid_ws_run $abs_path $target "$cmake_options"
            fi
        fi
    elif [ "$fake_target" = "run" ]; then
        if [ -z "$fake_target_args" -o $fake_target_needs_arg -gt 0 ]; then
            echo "The run target requires a platform, a package, a version and an executable as parameters"
        else
            local program_specific_args=""
            local current_arg=0
            if [ "$ZSH_VERSION" ]; then setopt shwordsplit; fi
            for arg in $fake_target_args; do
                if [ $current_arg -eq 0 ]; then
                    platform=$arg
                elif [ $current_arg -eq 1 ]; then
                    package=$arg
                elif [ $current_arg -eq 2 ]; then
                    version=$arg
                elif [ $current_arg -eq 3 ]; then
                    executable=$arg
                else
                  program_specific_args="$program_specific_args $arg"
                fi
                current_arg=$((current_arg+1))
            done
            if [ "$ZSH_VERSION" ]; then unsetopt shwordsplit; fi
            if [ -e $ws_dir/install/$platform/$package/$version/bin/$executable ]; then
                $ws_dir/install/$platform/$package/$version/bin/$executable
            elif [ -e $ws_dir/install/$platform/$package/$version/bin/${package}_${executable} ]; then
                $ws_dir/install/$platform/$package/$version/bin/${package}_${executable}
            else
                echo "Error, the executable $executable couldn't be found inside $ws_dir/install/$platform/$package/$version/bin"
            fi
            unset current_arg
            unset platform
            unset package
            unset version
            unset executable
        fi
    elif [ "$fake_target" = "run_build" ]; then
        if [ -z "$fake_target_args" -o $fake_target_needs_arg -gt 0 ]; then
            echo "The run_build target requires mode and executable as parameters"
        else
            local program_specific_args=""
            local current_arg=0
            if [ "$ZSH_VERSION" ]; then setopt shwordsplit; fi
            for arg in $fake_target_args; do
                if [ $current_arg -eq 0 ]; then
                  mode=$arg
                elif [ $current_arg -eq 1 ]; then
                  executable=$arg
                else
                  program_specific_args="$program_specific_args $arg"
                fi
                current_arg=$((current_arg+1))
            done
            if [ "$ZSH_VERSION" ]; then unsetopt shwordsplit; fi
            if [ -z "$project_name" ]; then
                echo "The run_build target requires to be launched from a package"
            fi
            if [ -z "$mode" ]; then
              echo "The run_build target requires to specify the mode (first argument)"
            fi
            if [ -z "$executable" ]; then
                echo "The run_build target requires to specify the executable name (second argument)"
            fi
            if [ -e $project_dir/build/$mode/apps/$executable ]; then
              $project_dir/build/$mode/apps/$executable $program_specific_args
            elif [ -e $project_dir/build/$mode/test/$executable ]; then
              $project_dir/build/$mode/test/$executable $program_specific_args
            elif [ -e $project_dir/build/$mode/test/${project_name}_$executable ]; then
              $project_dir/build/$mode/test/${project_name}_$executable $program_specific_args
            elif [ -e $project_dir/build/$mode/apps/${project_name}_$executable ]; then
              $project_dir/build/$mode/apps/${project_name}_$executable $program_specific_args
            else
                echo "Error, the executable $executable couldn't be found inside $project_name build folder ($mode mode)"
            fi
            unset current_arg
            unset mode
            unset executable
        fi
    # For real targets, simply execute them
    else
        _pid_ws_run $project_dir $target "$cmake_options"
    fi

    _pid_ws_unset_global_variables
    #Note: need to set zsh the correct way to interpret lists
    if [ "$ZSH_VERSION" ]; then
        setopt shwordsplit
    fi
    for var in $to_unexport; do
        local name="";
        if [ "$platform" = "macos" ]; then
          name=$(echo $var|gsed -re "s:([^=]+)=.*:\1:g")
        else
          name=$(echo $var|sed -re "s:([^=]+)=.*:\1:g")
        fi
        unset $name
    done
    if [ "$ZSH_VERSION" ]; then
      unsetopt shwordsplit
    fi
    return $pid_ws_res
}

### pid helper functions

# Configure the given project
#  $1: project dir, $2 cmake options
_pid_ws_configure() {
    cd $1/build
    cmake $2 $1
    pid_ws_res=$?
    cd $1
}

# Run the given target. (Re)configure the project
#  beforehand if necesarry
#  $1: project dir, $2: target, $3: cmake options
_pid_ws_run() {
    # Configure the project a first time if necessary
    if [ ! -f $1/build/CMakeCache.txt ]; then
        cd $1/build
        cmake $1
        cd $1
    fi
    if [ "$3" ]; then
      _pid_ws_configure $1 "$3"
    fi
    if [ -z "$2" ]; then
        cmake --build $1/build
        pid_ws_res=$?
    else
        cmake --build $1/build --target $2
        pid_ws_res=$?
    fi
}

# sets project_dir with the absolute path to the first PID project
#  or workspace found
_pid_ws_get_project_dir() {
    project_dir=$PWD
    local curr_dir_name=$(basename $project_dir)
    #if launch from build folder, go into parent dir
    if [ "$curr_dir_name" = "build" ]; then
        project_dir=$(dirname $project_dir)
    fi
    #if launch from build folder, go into parent dir
    while [ "" = "" ]; do
        if [ -e "$project_dir/CMakeLists.txt" ]; then
          if [ -e "$project_dir/pid" ]; then
            break
          elif [ -e "$project_dir/build" ]; then
            #no pid script but a build folder exists
            #force a first reconfigure to generate the pid script
            _pid_ws_configure $project_dir
            if [ -e "$project_dir/pid" ]; then
              break
            fi
          fi
        fi
        if [ "$project_dir" = "/" ]; then
            break
        fi
        project_dir=$(dirname $project_dir)
    done
    if [ "$project_dir" = "/" ]; then
        return 1
    else
        return 0
    fi
}

# sets ws_dir with the absolute path to the first PID workspace found
_pid_ws_get_workspace_dir() {
    if [ -z "$project_dir" ]; then
        _pid_ws_get_project_dir
    fi
    ws_dir=$(_pid_ws_readlink $project_dir/pid)
    ws_dir=$(dirname $ws_dir)
    # On Windows pid is a hardlink leading to Bash failing to resolve the original file
    # In that case we move up until we find Use_PID.cmake
    if [ ! -e $ws_dir/Use_PID.cmake ]; then
        while [ "" = "" ]; do
            if [ -e $ws_dir/Use_PID.cmake ]; then
                break
            fi
            if [ "$ws_dir" = "/" ]; then
                break
            fi
            ws_dir=$(dirname $ws_dir)
        done
        if [ "$ws_dir" = "/" ]; then
            if [ "$PID_DEFAULT_WORKSPACE_PATH" ]; then
                ws_dir=$PID_DEFAULT_WORKSPACE_PATH
            else
                echo "ERROR: failed to locate the root of the PID workspace and PID_DEFAULT_WORKSPACE_PATH is not defined"
                return 1
            fi
        else
            return 0
        fi
    fi
}


# if in a specific project (other than workspace) set the project_name value
_pid_ws_get_project_name() {
    echo
    if [ "$project_dir" != "$ws_dir" ]; then
      project_name=$(basename $project_dir)
    else
      project_name=""
    fi
}


_pid_ws_readlink() {
    local target=""
    if [ "$platform" = "macos" ]; then
      target=$(greadlink "$1")
    elif [ "$platform" = "freebsd" ]; then
      target=$(greadlink "$1")
    else
      target=$(readlink "$1")
    fi
    if [ "$target" = "" ]; then
        target=$1
    fi
    if [ -d "$target" ]; then
        local target_dir=$target
    else
        local target_dir=$(dirname $target)
    fi
    (cd $target_dir && echo `pwd`/$(basename $1))
}

# $1: package/wrapper/framework/environment to search in the workspace
#  sets abs_path with the absolute path to the project
_pid_ws_get_abs_path() {
    _pid_ws_get_workspace_dir
    if [ -z "$1" ]; then
        abs_path=$ws_dir
    elif [ -d "$ws_dir/packages/$1" ]; then
        abs_path=$ws_dir/packages/$1
    elif [ -d "$ws_dir/wrappers/$1" ]; then
        abs_path=$ws_dir/wrappers/$1
    elif [ -d "$ws_dir/sites/frameworks/$1" ]; then
        abs_path=$ws_dir/sites/frameworks/$1
    elif [ -d "$ws_dir/environments/$1" ]; then
        abs_path=$ws_dir/environments/$1
    else
        abs_path=""
        echo "Failed to find $1 in the available packages, wrappers, frameworks and environments"
        return 1
    fi
    return 0
}

# Prints pid function usage
_pid_ws_print_help() {
        echo ""
        echo "Usage:"
        echo "  pid [target] [args] [options]"
        echo ""
        echo "Target:"
        echo "  Either a real or a fake target. Fake targets behave like real ones but dont exist in the build system"
        echo "  The available real targets depend on each project"
        echo "  The available fake targets are:"
        echo "    workspace [target] [arguments] [options]         executes a target in the workspace"
        echo "    configure [options]                              (re)configures the project"
        echo "    cd [project]                                     changes the current directory to the root of the given project, or workspace if omited"
        echo "    exec <project> [target] [arguments] [options]    executes a target in the given project"
        echo "    run <platform> <package> <version> <executable>  runs the given executable matching the specified platform, package and version"
        echo "    run_build <mode> <executable>                    runs the given executable contained in current package"
        echo ""
        echo "  If target is omited, the project's default target is invoked"
        echo "  Projects can be packages, wrappers, frameworks or environments"
        echo ""
        echo "Arguments:"
        echo "  Arguments in the form of arg=value passed to the target"
        echo ""
        echo "Options:"
        echo "  CMake options in the form -DVAR=VALUE used to configure the project"
        echo ""
        echo "Examples (assuming current directory is pid-workspace):"
        echo "  pid deploy package=pid-rpath                                          deploy pid-rpath"
        echo "  pid exec pid-rpath build force=true                                   force rebuild of pid-rpath"
        echo "  pid cd pid-rpath                                                      change directory to pid-rpath"
        echo "  pid build force=true -DBUILD_EXAMPLES=ON                              build pid-rpath examples"
        echo "  pid run x86_64_linux_stdc++11 pid-rpath 2.0.0 pid-rpath_rpath-example run pid-rpath example"
        echo "  pid run_build release pid-rpath_rpath-example                         run pid-rpath example from build tree"
        echo "  pid workspace configure -DADDITIONAL_DEBUG_INFO=ON                    reconfigure the workspace"
}

_pid_ws_unset_global_variables() {
    unset project_dir
    unset ws_dir
    unset project_name
    unset abs_path
}

### Completion helper function

# Append all subfolders of the given one to the folders variable
#  $1: folder to search inside
_pid_ws_append_folders() {
    for f in $1/*; do
        if [ -d ${f} ]; then
            if [ "$folders" ]; then
                folders="$folders $(basename $f)"
            else
                folders="$(basename $f)"
            fi
        fi
    done
}

# Append all executable files contained in the given folder to the files variable
#  $1: folder to search inside
_pid_ws_append_executables() {
    for f in $1/*; do
      if [ -f ${f} ] && [ -x ${f} ] ; then
        if [ "$files" ]; then
            files="$files $(basename $f)"
        else
            files="$(basename $f)"
        fi
      fi
    done
}

# Call _pid_ws_append_folders for the workspace's packages, wrappers,
#  sites/frameworks and environments folders
_pid_ws_get_all_folders() {
    _pid_ws_get_workspace_dir
    folders=""
    _pid_ws_append_folders $ws_dir/packages
    _pid_ws_append_folders $ws_dir/wrappers
    _pid_ws_append_folders $ws_dir/sites/frameworks
    _pid_ws_append_folders $ws_dir/environments
}

# Sets the targets variable with the list of all available targets for the specified project
_pid_ws_get_targets() {
  if [ "$platform" = "macos" ]; then
    targets=$(cmake --build build --target help 2> /dev/null|gsed -re "s:^[. ]*([a-z][^ ]+).*$:\1:g"|tail -n +2)
  else
    targets=$(cmake --build build --target help 2> /dev/null|sed -re "s:^[. ]*([a-z][^ ]+).*$:\1:g"|tail -n +2)
  fi
}

# Don't include the completions in this file otherwise a POSIX shell will complain about unsupported syntax
if [ "$BASH_VERSION" ]; then
    pidws_share_dir=$(dirname $BASH_SOURCE)
    . $pidws_share_dir/bash_completions.sh
    complete -F pid_ws_bash_completions pid
    unset pidws_share_dir
elif [ "$ZSH_VERSION" ]; then
    pidws_share_dir="`dirname \"$0\"`"
    . $pidws_share_dir/zsh_completions.sh
    compctl -K pid_ws_zsh_completions pid
    unset pidws_share_dir
fi
