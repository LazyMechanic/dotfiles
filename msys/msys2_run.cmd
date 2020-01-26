@echo off
setlocal

rem To activate windows native symlinks uncomment next line
set MSYS=winsymlinks:nativestrict
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1

rem Shell types
if "x%~1" == "x-msys2" set MSYSTEM=MSYS
if "x%~1" == "x-mingw32" set MSYSTEM=MINGW32
if "x%~1" == "x-mingw64" set MSYSTEM=MINGW64

for /f "tokens=1,* delims= " %%a in ("%*") do set SHELL_ARGS=%%b

rem Shell types
rem set MSYSTEM=MSYS

D:\msys64\usr\bin\zsh.exe --login -i %SHELL_ARGS%

exit /b 0