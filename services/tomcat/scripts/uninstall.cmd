@echo off
REM Uninstall Tomcat Windows Service
REM Usage: uninstall.cmd [SERVICE_NAME]

set SERVICE_NAME=%~1
if "%SERVICE_NAME%"=="" set SERVICE_NAME=STAR-T-Tomcat

echo Removing service %SERVICE_NAME% ...

REM Stop first
sc stop %SERVICE_NAME% >nul 2>&1
timeout /t 2 /nobreak >nul

REM Remove
"%~dp0..\bin\tomcat9.exe" //DS//%SERVICE_NAME%

if %ERRORLEVEL% equ 0 (
    echo Service %SERVICE_NAME% removed.
) else (
    echo Failed to remove service %SERVICE_NAME%.
    exit /b 1
)
