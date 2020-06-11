@echo off
setlocal
set script_dir=%~dp0
set PATH=%PATH%;%script_dir%\..\lib;%script_dir%\..\src;%script_dir%\..\.rpath\%~n1

cmd /C "cd %script_dir% && %*"