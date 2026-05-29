@echo off
REM STAR-T Nginx Stop Script
set "NGINX_DIR=%~1"
if exist "%NGINX_DIR%\nginx.exe" (
    "%NGINX_DIR%\nginx.exe" -s quit 2>nul
    echo Nginx stopped.
) else (
    echo Warning: nginx.exe not found
)
