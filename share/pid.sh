# /!\ This script must stay POSIX compatible so avoid any Bash/ZSH extensions /!\
#
# Since sh might be symlinked to bash or something else on your system,
#  you can try using the dash shell, which is very close to POSIX, to make sure
#  that any modification you make doesn't break compatibility

# Main function to be invoked by users
pid() {
    # Print help if -h or --help is passed
    case $1 in
        "-h"|"--help") _pid_ws_print_help && return 0;;
    esac

    local target=""
    local fake_target=""
    local fake_target_needs_arg=0
    local fake_target_args=""
    local cmake_options=""
    local to_unexport=""

    # Retreive current project and workspace locations
    _pid_ws_get_project_dir
    _pid_ws_get_workspace_dir

    # Exit with an error if a project cannot be found
    if [ ! "$?" = "0" ]; then
        return $res
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
        elif [ $fake_target_needs_arg -gt 0 ]; then
            if [ "$fake_target_args" ]; then
                fake_target_args="$fake_target_args $arg"
            else
                fake_target_args=$arg
            fi
            fake_target_needs_arg=$((fake_target_needs_arg-1))
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
            _pid_ws_configure $ws_dir $cmake_options
        else
            _pid_ws_run $ws_dir $target $cmake_options
        fi
    elif [ "$fake_target" = "configure" ]; then
        _pid_ws_configure $project_dir $cmake_options
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
                _pid_ws_run $abs_path $target $cmake_options
            fi
        fi
    elif [ "$fake_target" = "run" ]; then
        if [ -z "$fake_target_args" ]; then
            echo "The run target requires a platform, a package, a version and an executable as parameters"
        else
            current_arg=0
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
                fi
                current_arg=$((current_arg+1))
            done
            if [ "$ZSH_VERSION" ]; then unsetopt shwordsplit; fi
            if [ -e $ws_dir/install/$platform/$package/$version/bin/${package}_${executable} ]; then
                (cd $ws_dir/install/$platform/$package/$version/bin && ./${package}_${executable})
            elif [ -e $ws_dir/install/$platform/$package/$version/bin/$executable ]; then
                (cd $ws_dir/install/$platform/$package/$version/bin && ./$executable)
            else
                echo "Error, the executable $executable couldn't be found inside $ws_dir/install/$platform/$package/$version/bin"
            fi
            unset current_arg
            unset platform
            unset package
            unset version
            unset executable
        fi
    # For real targets, simply execute them
    else
        _pid_ws_run $project_dir $target $cmake_options
    fi

    unset project_dir
    unset ws_dir
    for var in $to_unexport; do
        local name=$(echo $var|sed -E "s:(.*)=.*:\1:g")
        unset $name
    done

    return $pid_ws_res
}

### pid helper functions

# Configure the given project
#  $1: project dir, $2 cmake options
_pid_ws_configure() {
    cmake -S $1 -B $1/build $2
    pid_ws_res=$?
}

# Apply CMake options to the given project
#   $1: project dir, $2: cmake options
_pid_ws_apply_options() {
    if [ "$2" ]; then
        _pid_ws_configure $1 $2
    fi
}

# Run the given target. (Re)configure the project
#  beforehand if necesarry
#  $1: project dir, $2: target, $3: cmake options
_pid_ws_run() {
    # Configure the project a first time if necessary
    if [ ! -f $1/build/CMakeCache.txt ]; then
        cmake -S $1 -B $1/build
    fi

    _pid_ws_apply_options $1 $3

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
    while [ "" = "" ]; do
        if [ -e $project_dir/pid ]; then
            if [ -e $project_dir/CMakeLists.txt ]; then
                break
            fi
        fi
        if [ "$project_dir" = "/" ]; then
            break
        fi
        project_dir=$(_pid_ws_readlink $project_dir/..)
    done
    if [ "$project_dir" = "/" ]; then
        echo "ERROR: you must run this command from somewhere inside a PID workspace"
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
            ws_dir=$(_pid_ws_readlink $ws_dir/..)
        done
        if [ "$ws_dir" = "/" ]; then
            echo "ERROR: failed to locate the root of the PID workspace"
            return 1
        else
            return 0
        fi
    fi
}

_pid_ws_readlink() {
    local target=$(readlink "$1")
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
        echo "  pid run x86_64_linux_abi11 pid-rpath 2.0.0 pid-rpath_rpath-example    run pid-rpath example"
        echo "  pid workspace configure -DADDITIONNAL_DEBUG_INFO=ON                   reconfigure the workspace"
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

# Append all files contained in the given folder to the files variable
#  $1: folder to search inside
_pid_ws_append_files() {
    for f in $1/*; do
        if [ ! -d ${f} ]; then
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
    targets=$(cmake --build build --target help 2> /dev/null|sed -re "s:([. ])*([a-z][a-z\-_]+)(.*):\2:g"|tail -n +2)
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
