
pid_ws_bash_completions() {
    _pid_ws_get_project_dir
    _pid_ws_get_workspace_dir

    local cmd
    cmd=${COMP_WORDS[1]}

    local opts
    opts="cd workspace hard_clean exec run"

    if [ "$cmd" = "cd" ]; then
        _pid_ws_get_all_folders
        COMPREPLY=( $(compgen -W "$folders" "${COMP_WORDS[2]}") )
        unset folders
    elif [ "$cmd" = "workspace" ]; then
        _pid_ws_get_targets $ws_dir
        opts="$opts $targets"
        COMPREPLY=($(compgen -W "$opts" "${COMP_WORDS[2]}"))
    elif [ "$cmd" = "exec" ]; then
        if [ $COMP_CWORD -eq 2 ]; then
            _pid_ws_get_all_folders
            COMPREPLY=($(compgen -W "$folders" "${COMP_WORDS[2]}"))
            unset folders
        else
            _pid_ws_get_abs_path ${COMP_WORDS[2]}
            _pid_ws_get_targets $abs_path
            opts="$opts $targets"
            COMPREPLY=($(compgen -W "$opts" "${COMP_WORDS[3]}"))
        fi
    elif [ "$cmd" = "run" ]; then
        local platform
        local package
        local version
        platform=${COMP_WORDS[2]}
        package=${COMP_WORDS[3]}
        version=${COMP_WORDS[4]}
        if [ $COMP_CWORD -eq 2 ]; then
            _pid_ws_get_workspace_dir
            folders=""
            _pid_ws_append_folders $ws_dir/install
            COMPREPLY=($(compgen -W "$folders" "${COMP_WORDS[2]}"))
            unset folders
        elif [ $COMP_CWORD -eq 3 ]; then
            _pid_ws_get_workspace_dir
            folders=""
            _pid_ws_append_folders $ws_dir/install/$platform
            COMPREPLY=($(compgen -W "$folders" "${COMP_WORDS[3]}"))
            unset folders
        elif [ $COMP_CWORD -eq 4 ]; then
            _pid_ws_get_workspace_dir
            folders=""
            _pid_ws_append_folders $ws_dir/install/$platform/$package
            COMPREPLY=($(compgen -W "$folders" "${COMP_WORDS[4]}"))
            unset folders
        else
            _pid_ws_get_workspace_dir
            files=""
            _pid_ws_append_files $ws_dir/install/$platform/$package/$version/bin
            COMPREPLY=($(compgen -W "$files" "${COMP_WORDS[5]}"))
            unset files
        fi
    else
        _pid_ws_get_targets $project_dir
        opts="$opts $targets"
        COMPREPLY=($(compgen -W "$opts" "${COMP_WORDS[1]}"))
    fi
    
    unset project_dir
    unset ws_dir
    unset targets
}
