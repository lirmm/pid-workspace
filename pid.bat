@echo off
setlocal enableDelayedExpansion

set build_dir=%~dp0build

rem Configure the project if necessary
if not exist !build_dir!\CMakeCache.txt cmd /C "cd !build_dir! && cmake .."

set argC=0
for %%x in (%*) do Set /A argC+=1
rem If no argument are given then simply configure the project
if %argC%==0 (
    cmd /C "cd !build_dir! && cmake .."
) else (
    rem Extract the target
    set target=%1

    rem Extract the remaining arguments
    set first_loop=1
    :loop1
    if [%1] == [] goto after_loop
        if !first_loop!==1 set first_loop=0 & shift & goto loop1
        set command=%1
        set value=%2
        if "%command:~0,2%"=="-D" (
            rem Store the cmake options
            set cmake_options=!cmake_options! !command!=!value!
        ) else (
            rem Set the command/value pair as an environment variable
            set !command!=!value!
        )
        shift
        shift
        goto loop1
    :after_loop
    rem Don't ask me why this line is required


    rem Extract the remaining arguments
    cmd /C "cmake !cmake_options! --target !target! --build !build_dir!"
)