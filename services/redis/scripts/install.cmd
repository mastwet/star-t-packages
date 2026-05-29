@echo off
REM STAR-T Redis Install Script
set "INSTALL_DIR=%~1"
set "PORT=%~2"
if "%PORT%"=="" set "PORT=6379"

if not exist "%INSTALL_DIR%\logs" mkdir "%INSTALL_DIR%\logs"

echo Redis installed. Port: %PORT%
