@echo off
REM Uninstall RabbitMQ Windows Service
REM Usage: uninstall.cmd <RABBITMQ_HOME> [SERVICE_NAME]

set RABBITMQ_HOME=%~1
set SERVICE_NAME=%~2
if "%SERVICE_NAME%"=="" set SERVICE_NAME=STAR-T-RabbitMQ

set ERLANG_HOME=%RABBITMQ_HOME%\erlang

echo Stopping %SERVICE_NAME%...
"%RABBITMQ_HOME%\rabbitmq\sbin\rabbitmq-service.bat" stop
"%RABBITMQ_HOME%\rabbitmq\sbin\rabbitmq-service.bat" remove

if %ERRORLEVEL% equ 0 (
    echo Service %SERVICE_NAME% removed.
) else (
    echo Failed to remove service.
    exit /b 1
)
