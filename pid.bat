@echo off
setlocal enableDelayedExpansion

set source_dir=%~dp0

rem Set the arguments as environment variables and store CMake options
:loop_start
if [%1] == [] goto after_loop
    set command=%1
    set value=%2
    if "!command:~0,2!"=="-D" (
        set cmake_options=!cmake_options! !command!=!value!
        shift
        shift
        goto loop_start
    ) 
    if [!target!] == [] (
        if "!command!"=="workspace" (
            echo "!command! is workspace"
            set fake_target=!command!
            shift
            goto loop_start
        )
        if "!command!"=="hard_clean" (
            echo "!command! is hard_clean"
            set fake_target=!command!
            shift
            goto loop_start
        )
        set target=!command!
        shift
        goto loop_start
    ) else (
        rem Set the command/value pair as an environment variable
        set !command!=!value!
        shift
        shift
        goto loop_start
    )
:after_loop
rem Don't ask me why this line is required

if "!fake_target!"=="workspace" (
    call :run !source_dir! workspace_path
    for /f "delims=" %%a in (!source_dir!\build\ws_path.txt) do ( 
        set ws_dir=%%a
    )
    echo "Forwarding command to workspace"
    call :run !ws_dir! , !target!
    goto :eof
)

if "!fake_target!"=="hard_clean" (
    cmd /C "cd !source_dir!\build && del *.*"
    goto :eof
)

call :run !source_dir! , !target!
goto :eof


rem %~1: source dir, %~2 cmake options
:configure
    cmake -S %~1 -B %~1/build !cmake_options!
    exit /B 0

rem %~1: source_dir, uses !cmake_options!
:apply_options
    if not [!cmake_options!] == [] (
        call :configure %~1
    )
    exit /B 0

rem %~1: source_dir, %~2: target
:run
    rem Configure the project a first time if necessary
    if not exist %~1\build\CMakeCache.txt (
        cmake -S %~1 -B %~1\build
    )

    call :apply_options %~1

    if [%~2] == [] (
        cmake --build %~1\build
    ) else (
        cmake --build %~1\build --target %~2
    )
    exit /B 0
