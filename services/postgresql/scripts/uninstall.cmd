@echo off
REM Unregister PostgreSQL Windows Service
REM Usage: uninstall.cmd <PG_HOME> <DATA_DIR> [SERVICE_NAME]

set PG_HOME=%~1
set DATA_DIR=%~2
set SERVICE_NAME=%~3
if "%SERVICE_NAME%"=="" set SERVICE_NAME=STAR-T-PostgreSQL

echo Stopping %SERVICE_NAME%...
"%PG_HOME%\bin\pg_ctl.exe" stop -D "%DATA_DIR%" -m fast 2>nul
net stop %SERVICE_NAME% >nul 2>&1

echo Unregistering service %SERVICE_NAME%...
"%PG_HOME%\bin\pg_ctl.exe" unregister -N %SERVICE_NAME%

if %ERRORLEVEL% equ 0 (
    echo Service %SERVICE_NAME% removed.
) else (
    echo Failed to remove service.
    exit /b 1
)
