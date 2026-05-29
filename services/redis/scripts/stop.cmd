@echo off
REM STAR-T Redis Stop Script
set "REDIS_DIR=%~1"
if exist "%REDIS_DIR%\redis-cli.exe" (
    "%REDIS_DIR%\redis-cli.exe" shutdown 2>nul
    echo Redis stopped.
) else (
    taskkill /F /IM redis-server.exe 2>nul
)
