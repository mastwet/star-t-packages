@echo off
REM STAR-T Nginx Start Script
set "NGINX_DIR=%~1"
if not exist "%NGINX_DIR%\nginx.exe" (
    echo Error: nginx.exe not found in %NGINX_DIR%
    exit /b 1
)
start "" /B "%NGINX_DIR%\nginx.exe" -p "%NGINX_DIR%"
echo Nginx started.
