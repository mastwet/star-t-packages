@echo off
REM Install Tomcat as a Windows Service
REM Usage: install.cmd <TOMCAT_HOME> <JAVA_HOME> [SERVICE_NAME]

set TOMCAT_HOME=%~1
set JAVA_HOME=%~2
set SERVICE_NAME=%~3
if "%SERVICE_NAME%"=="" set SERVICE_NAME=STAR-T-Tomcat9

echo Installing %SERVICE_NAME% ...
"%TOMCAT_HOME%\bin\tomcat9.exe" //IS//%SERVICE_NAME% ^
    --Startup=auto ^
    --JavaHome="%JAVA_HOME%" ^
    --StartMode=jvm ^
    --StopMode=jvm ^
    --StartClass=org.apache.catalina.startup.Bootstrap ^
    --StartParams=start ^
    --StopClass=org.apache.catalina.startup.Bootstrap ^
    --StopParams=stop

if %ERRORLEVEL% equ 0 (
    echo Service %SERVICE_NAME% installed successfully.
) else (
    echo Failed to install service %SERVICE_NAME%.
    exit /b 1
)
