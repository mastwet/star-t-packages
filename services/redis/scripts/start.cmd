@echo off
REM STAR-T Redis Start Script
set "REDIS_DIR=%~1"
set "CONF=%~2"

if not exist "%REDIS_DIR%\redis-server.exe" (
    echo Error: redis-server.exe not found in %REDIS_DIR%
    exit /b 1
)

if "%CONF%"=="" (
    start "" /B "%REDIS_DIR%\redis-server.exe"
) else (
    start "" /B "%REDIS_DIR%\redis-server.exe" "%CONF%"
)
echo Redis started.
