@echo off
REM Uninstall MySQL Windows Service
REM Usage: uninstall.cmd [SERVICE_NAME]

set SERVICE_NAME=%~1
if "%SERVICE_NAME%"=="" set SERVICE_NAME=STAR-T-MySQL

echo Stopping %SERVICE_NAME%...
net stop %SERVICE_NAME% >nul 2>&1

echo Removing service %SERVICE_NAME%...
"%~dp0..\bin\mysqld.exe" --remove %SERVICE_NAME%

if %ERRORLEVEL% equ 0 (
    echo Service %SERVICE_NAME% removed.
) else (
    echo Failed to remove service.
    exit /b 1
)
