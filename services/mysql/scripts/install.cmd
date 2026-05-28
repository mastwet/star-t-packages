@echo off
REM Initialize and install MySQL as Windows Service
REM Usage: install.cmd <MYSQL_HOME> <DATA_DIR> [SERVICE_NAME]

set MYSQL_HOME=%~1
set DATA_DIR=%~2
set SERVICE_NAME=%~3
if "%SERVICE_NAME%"=="" set SERVICE_NAME=STAR-T-MySQL

echo Initializing MySQL data directory...
"%MYSQL_HOME%\bin\mysqld.exe" --initialize-insecure --basedir="%MYSQL_HOME%" --datadir="%DATA_DIR%"

echo Installing service %SERVICE_NAME%...
"%MYSQL_HOME%\bin\mysqld.exe" --install %SERVICE_NAME% --defaults-file="%MYSQL_HOME%\my.ini"

if %ERRORLEVEL% equ 0 (
    echo Service %SERVICE_NAME% installed. Starting...
    net start %SERVICE_NAME%
) else (
    echo Failed to install MySQL service.
    exit /b 1
)
