@echo off
REM Install and start RabbitMQ as Windows Service
REM Bundles Erlang — sets ERLANG_HOME automatically
REM Usage: install.cmd <RABBITMQ_HOME> [SERVICE_NAME]

set RABBITMQ_HOME=%~1
set SERVICE_NAME=%~2
if "%SERVICE_NAME%"=="" set SERVICE_NAME=STAR-T-RabbitMQ

REM Set ERLANG_HOME to bundled Erlang
set ERLANG_HOME=%RABBITMQ_HOME%\erlang

echo Erlang: %ERLANG_HOME%
echo RabbitMQ: %RABBITMQ_HOME%\rabbitmq

REM Enable management plugin
echo Enabling management plugin...
"%RABBITMQ_HOME%\rabbitmq\sbin\rabbitmq-plugins.bat" enable rabbitmq_management

REM Install as Windows Service
echo Installing %SERVICE_NAME%...
"%RABBITMQ_HOME%\rabbitmq\sbin\rabbitmq-service.bat" install

if %ERRORLEVEL% equ 0 (
    echo Starting %SERVICE_NAME%...
    "%RABBITMQ_HOME%\rabbitmq\sbin\rabbitmq-service.bat" start
    echo.
    echo RabbitMQ is running.
    echo   AMQP:      localhost:5672
    echo   Dashboard: http://localhost:15672 (guest/guest)
) else (
    echo Failed to install RabbitMQ service.
    exit /b 1
)
