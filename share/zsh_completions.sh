
# ZSH behaves differently if the completion function starts with an underscore so don't use one
pid_ws_zsh_completions() {
    _pid_ws_get_project_dir
    _pid_ws_get_workspace_dir

    reply=()

    local cmd
    cmd=${=${(s: :)words}[2]}

    local opts
    opts="cd workspace exec run configure"

    if [ "$cmd" = "cd" ]; then
        folders=""
        _pid_ws_append_folders $ws_dir/packages
        _pid_ws_append_folders $ws_dir/wrappers
        _pid_ws_append_folders $ws_dir/sites/frameworks
        _pid_ws_append_folders $ws_dir/environments
        reply=( "${=folders}" )
        unset folders
    elif [ "$cmd" = "workspace" ]; then
        _pid_ws_get_targets $ws_dir
        opts="$opts $targets"
        reply=( "${=opts}" )
    elif [ "$cmd" = "exec" ]; then
        if [ $CURRENT -eq 3 ]; then
            _pid_ws_get_all_folders
            reply=( "${=folders}" )
            unset folders
        else
            _pid_ws_get_abs_path ${COMP_WORDS[2]}
            _pid_ws_get_targets $abs_path
            opts="$opts $targets"
            reply=( "${=opts}" )
        fi
    elif [ "$cmd" = "run" ]; then
        local platform
        local package
        local version
        platform=${=${(s: :)words}[3]}
        package=${=${(s: :)words}[4]}
        version=${=${(s: :)words}[5]}
        if [ $CURRENT -eq 3 ]; then
            _pid_ws_get_workspace_dir
            folders=""
            _pid_ws_append_folders $ws_dir/install
            reply=( "${=folders}" )
            unset folders
        elif [ $CURRENT -eq 4 ]; then
            _pid_ws_get_workspace_dir
            folders=""
            _pid_ws_append_folders $ws_dir/install/$platform
            reply=( "${=folders}" )
            unset folders
        elif [ $CURRENT -eq 5 ]; then
            _pid_ws_get_workspace_dir
            folders=""
            _pid_ws_append_folders $ws_dir/install/$platform/$package
            reply=( "${=folders}" )
            unset folders
        else
            _pid_ws_get_workspace_dir
            files=""
            _pid_ws_append_files $ws_dir/install/$platform/$package/$version/bin
            reply=( "${=files}" )
            unset files
        fi
    else
        _pid_ws_get_targets $project_dir
        opts="$opts $targets"
        reply=( "${=opts}" )
    fi

    unset project_dir
    unset ws_dir
    unset targets
}
