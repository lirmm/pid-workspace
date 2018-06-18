@echo off
setlocal
set PATH=%PATH%;..\lib;..\.rpath\%~n1
echo %PATH%
%*
