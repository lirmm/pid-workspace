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
        if [!fake_target!] == [] (
            if "!command!"=="workspace" (
                set fake_target=!command!
                shift
                goto loop_start
            )
            if "!command!"=="configure" (
                set fake_target=!command!
                shift
                goto loop_start
            )
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
    set cmake_options_backup=!cmake_options!
    set cmake_options=""
    call :run !source_dir! workspace_path
    set cmake_options=!cmake_options_backup!
    for /f "delims=" %%a in (!source_dir!\build\ws_path.txt) do ( 
        set ws_dir=%%a
    )
    if "!target!"=="configure" (
        call :configure !ws_dir!
    ) else (
        call :run !ws_dir! , !target!
    )
    goto :eof
)

if "!fake_target!"=="configure" (
    call :configure !source_dir!
    goto :eof
)

call :run !source_dir! , !target!
goto :eof


rem %~1: source dir, %~2 cmake options
:configure
    cmake -S %~1 -B %~1/build !cmake_options!
    exit /B %ERRORLEVEL%

rem %~1: source_dir, uses !cmake_options!
:apply_options
    if not [!cmake_options!] == [] (
        call :configure %~1
    )
    exit /B %ERRORLEVEL%

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
    exit /B %ERRORLEVEL%