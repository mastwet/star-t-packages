@echo off
REM Uninstall PHP FastCGI Windows Service via NSSM
REM Usage: uninstall.cmd <NSSM_PATH> [SERVICE_NAME]

set NSSM_PATH=%~1
set SERVICE_NAME=%~2
if "%SERVICE_NAME%"=="" set SERVICE_NAME=STAR-T-PHP

echo Stopping %SERVICE_NAME%...
net stop %SERVICE_NAME% >nul 2>&1

echo Removing service %SERVICE_NAME%...
"%NSSM_PATH%" remove %SERVICE_NAME% confirm

if %ERRORLEVEL% equ 0 (
    echo Service %SERVICE_NAME% removed.
) else (
    echo Failed to remove service.
    exit /b 1
)
