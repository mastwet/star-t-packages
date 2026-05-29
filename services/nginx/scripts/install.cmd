@echo off
REM STAR-T Nginx Install Script
REM Called by STAR-T after extracting .star package
REM Args: %1 = install directory, %2 = port

set "INSTALL_DIR=%~1"
set "PORT=%~2"
if "%PORT%"=="" set "PORT=8080"

REM Create required directories
if not exist "%INSTALL_DIR%\logs\nginx" mkdir "%INSTALL_DIR%\logs\nginx"
if not exist "%INSTALL_DIR%\run" mkdir "%INSTALL_DIR%\run"
if not exist "%INSTALL_DIR%\html" mkdir "%INSTALL_DIR%\html"

echo Nginx installed. Port: %PORT%
