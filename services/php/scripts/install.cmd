@echo off
REM Register PHP FastCGI as Windows Service via NSSM
REM Usage: install.cmd <PHP_HOME> <NSSM_PATH> [SERVICE_NAME]

set PHP_HOME=%~1
set NSSM_PATH=%~2
set SERVICE_NAME=%~3
if "%SERVICE_NAME%"=="" set SERVICE_NAME=STAR-T-PHP

echo Installing %SERVICE_NAME% (FastCGI) ...
"%NSSM_PATH%" install %SERVICE_NAME% "%PHP_HOME%\bin\php-cgi.exe"
"%NSSM_PATH%" set %SERVICE_NAME% AppParameters "-b 127.0.0.1:9000"
"%NSSM_PATH%" set %SERVICE_NAME% AppDirectory "%PHP_HOME%\bin"
"%NSSM_PATH%" set %SERVICE_NAME% DisplayName "STAR-T PHP FastCGI"
"%NSSM_PATH%" set %SERVICE_NAME% Start SERVICE_AUTO_START
"%NSSM_PATH%" set %SERVICE_NAME% AppStdout "%PHP_HOME%\logs\nssm-php.log"
"%NSSM_PATH%" set %SERVICE_NAME% AppStderr "%PHP_HOME%\logs\nssm-php-error.log"

if %ERRORLEVEL% equ 0 (
    echo Service %SERVICE_NAME% installed.
    net start %SERVICE_NAME%
) else (
    echo Failed to install PHP service.
    exit /b 1
)
