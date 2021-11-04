#manage user arguments
pkgconfig=
install=
tests=off
sanitizers=off
examples=off
upgrade=off
build_type=both
contribution_spaces=()
contribution_spaces_prio=()

print_usage() {
    echo "standalone_install.sh script options:"
    echo "  COMMAND           VALUE               DESCRIPTION                                  DEFAULT VALUE"
    echo "  -i|--install      path                Install the package inside the given path"
    echo "  -p|--pkg-config   on|off              Generate pkg-config files                    (off or last value)"
    echo "  -t|--tests        on|off              Build and run the package tests              (off)"
    echo "  -s|--sanitizers   on|off              Build the package with sanitizers enabled    (off)"
    echo "  -e|--examples     on|off              Build the package example applications       (off)"
    echo "  -b|--build-type   both|debug|release  Build the package in release, debug of both  (both)"
    echo "  -c|--add-cs       url                 Git URL of the contribution space to add. Multiple CS can be added"
    echo "  -cp|--cs-prio     min|max             Set the priority of the last added contribution space"
    echo "  -u|--upgrade                          Upgrade pid-workspace before build"
    echo "  -h|--help                             Print this help message"
    echo ""
    echo "Example: standalone_install.sh --upgrade --build-type release --tests on --install /usr/local"
    exit
}

validate_boolean() {
    if [ ! "$2" = "on" ] && [ ! "$2" = "off" ]; then
        echo "[ERROR] Invalid value for argument $1 ($2)."
        echo ""
        print_usage
    fi
}

validate_build_type() {
    if [ ! "$2" = "both" ] && [ ! "$2" = "debug" ] && [ ! "$2" = "release" ]; then
        echo "[ERROR] Invalid value for argument $1 ($2)."
        echo ""
        print_usage
    fi
}

unknown_args=""
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -p|--pkg-config)
        pkgconfig="$2"
        validate_boolean $1 $2
        shift # past argument
        shift # past value
        ;;
        -i|--install)
        install="$2"
        shift # past argument
        shift # past value
        ;;
        -t|--tests)
        tests="$2"
        validate_boolean $1 $2
        shift # past argument
        shift # past value
        ;;
        -s|--sanitizers)
        sanitizers="$2"
        validate_boolean $1 $2
        shift # past argument
        shift # past value
        ;;
        -e|--examples)
        examples="$2"
        validate_boolean $1 $2
        shift # past argument
        shift # past value
        ;;
        -b|--build-type)
        build_type="$2"
        validate_build_type $1 $2
        shift # past argument
        shift # past value
        ;;
        -c|--add-cs)
        contribution_spaces+=("$2")
        contribution_spaces_prio+=("min")
        shift # past argument
        shift # past value
        ;;
        -cp|--cs-prio)
        if [ "$2" = "min" ] || [ "$2" = "max" ]; then
            contribution_spaces_prio[-1]=$2
        else
            echo "Invalid contribution space priority. Given $2, expected min or max"
            print_usage
        fi
        shift # past argument
        shift # past value
        ;;
        -u|--upgrade)
        upgrade=on
        shift # past argument
        ;;
        -h|--help)
        print_usage
        shift # past argument
        ;;
        *)    # unknown option
        if [ "$unknown_args" ]; then
            unknown_args="$unknown_args $1"
        else
            unknown_args="$1"
        fi
        shift # past argument
        ;;
    esac
done

if [ "$unknown_args" ]; then
    echo "[ERROR] invalid arguments given: $unknown_args"
    print_usage
fi

echo "Installing $package_name using:"
echo "  pkg-config: $pkgconfig"
echo "  install: $install"
echo "  tests: $tests"
echo "  sanitizers: $sanitizers"
echo "  examples: $examples"
echo "  build-type: $build_type"
echo "  upgrade: $upgrade"
for i in "${!contribution_spaces[@]}"; do
    echo "  contribution space: ${contribution_spaces[$i]}, prio: ${contribution_spaces_prio[$i]}"
done

#####################################
#  --  configure the workspace  --  #
#####################################
echo "Configuring pid-workspace before build ..."

if [ "$upgrade" = "on" ]; then
    (cd $workspace_root_path/build && cmake --build . --target upgrade -- official=false)
fi

(cd $workspace_root_path/build && cmake ..)

check_pkgconfig_enabled() {
    grep pkg-config $workspace_root_path/environments/profiles_list.cmake > /dev/null
    return $?
}

update_pkgconfig_state() {
    check_pkgconfig_enabled
    if [ "$?" = 0 ]; then
        pkgconfig=on
    else
        pkgconfig=off
    fi
}

if [ "$pkgconfig" = "on" ]; then
    check_pkgconfig_enabled
    # only add pkg-config if not enabled already to speed up subsequent workspace configurations
    if [ ! "$?" = 0 ]; then
        (cd $workspace_root_path/build && cmake --build . --target profiles -- cmd=add env=pkg-config)
    fi
elif [ "$pkgconfig" = "off" ]; then
    check_pkgconfig_enabled
    # only remove pkg-config if already enabled to speed up subsequent workspace configurations
    if [ "$?" = 0 ]; then
        (cd $workspace_root_path/build && cmake --build . --target profiles -- cmd=rm env=pkg-config)
    fi
fi

update_pkgconfig_state

contribution_spaces_name=()
for i in "${!contribution_spaces[@]}"; do
    existing_cs=`ls -d $workspace_root_path/contributions/*/`
    (cd $workspace_root_path/build && cmake --build . --target contributions -- cmd=add update="${contribution_spaces[$i]}")
    new_cs=`ls -d $workspace_root_path/contributions/*/`
    for cs in ${new_cs[@]}; do
        for prev_cs in ${existing_cs[@]}; do
            if [ ! "$cs" = "$prev_cs" ]; then
                added_cs=$cs
                break
            fi
            if [ "$added_cs" ]; then
                break
            fi
        done
    done
    if [ "$added_cs" ]; then
        cs_name=`basename $added_cs`
        (cd $workspace_root_path/build && cmake --build . --target contributions -- cmd="prio_${contribution_spaces_prio[$i]}" space="${cs_name}")
    fi
done

##################################
#  --  building the project  --  #
##################################

if [ "$build_type" = "debug" ]; then
    build_target=build_debug
    release_only="OFF"
elif [ "$build_type" = "release" ]; then
    build_target=build_release
    release_only="ON"
else
    build_target=build
    release_only="OFF"
fi

echo "Configuring $package_name ..."
cmake_options="-DREQUIRED_PACKAGES_AUTOMATIC_DOWNLOAD=ON"
cmake_options="$cmake_options -DADDITIONAL_DEBUG_INFO=OFF"
cmake_options="$cmake_options -DENABLE_PARALLEL_BUILD=ON"
cmake_options="$cmake_options -DBUILD_API_DOC=OFF"
cmake_options="$cmake_options -DBUILD_STATIC_CODE_CHECKING_REPORT=OFF"
cmake_options="$cmake_options -DGENERATE_INSTALLER=OFF"
cmake_options="$cmake_options -DWORKSPACE_DIR=$workspace_root_path"
cmake_options="$cmake_options -DBUILD_AND_RUN_TESTS=${tests^^}"
cmake_options="$cmake_options -DENABLE_SANITIZERS=${sanitizers^^}"
cmake_options="$cmake_options -DBUILD_EXAMPLES=${examples^^}"
cmake_options="$cmake_options -DBUILD_RELEASE_ONLY=${release_only}"

(cd $package_root_path/build && cmake $cmake_options ..)

echo "Building $package_name ..."
(cd $package_root_path/build && cmake --build . --target $build_target -- force=true)

if [ "$?" = 0 ]; then
    echo ""
    echo "Package $package_name has ben successfully built"
    if [ "$pkgconfig" = "on" ]; then
        pkgconfig_path=`(cd $workspace_root_path/install/*/__pkgconfig__ && pwd)`
        echo ""
        echo "For usage with pkg-config, add $pkgconfig_path to your PKG_CONFIG_PATH environment variable."
        echo "  i.e export PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:$pkgconfig_path"
    fi
    if [ "$install" ]; then
        version=`(cd $package_root_path/build && cmake --build . --target version 2> /dev/null)|head -n1 -`
        echo ""
        echo "Installing $package_name with version $version inside $install"
        touch $install/pid_test_write_access 2> /dev/null
        if [ "$?" = 0 ]; then
            # user has write access to install dir
            rm $install/pid_test_write_access
            (cd $package_root_path/build && cmake --build . --target sysinstall -- folder=$install mode=${build_type^})
        else
            # sudo is required
            (cd $package_root_path/build && sudo cmake --build . --target sysinstall -- folder=$install mode=${build_type^})
        fi
    fi
fi