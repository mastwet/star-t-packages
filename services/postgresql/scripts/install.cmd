@echo off
REM Initialize and register PostgreSQL as Windows Service
REM Usage: install.cmd <PG_HOME> <DATA_DIR> [SERVICE_NAME] [PORT]

set PG_HOME=%~1
set DATA_DIR=%~2
set SERVICE_NAME=%~3
set PG_PORT=%~4
if "%SERVICE_NAME%"=="" set SERVICE_NAME=STAR-T-PostgreSQL
if "%PG_PORT%"=="" set PG_PORT=5432

echo Initializing PostgreSQL data directory...
"%PG_HOME%\bin\initdb.exe" -U postgres -A trust -E UTF8 -D "%DATA_DIR%"

echo Registering service %SERVICE_NAME%...
"%PG_HOME%\bin\pg_ctl.exe" register -N %SERVICE_NAME% -D "%DATA_DIR%" -w

if %ERRORLEVEL% equ 0 (
    echo Starting %SERVICE_NAME%...
    net start %SERVICE_NAME%

    REM Set password after start
    timeout /t 3 /nobreak >nul
    echo Setting postgres password...
    "%PG_HOME%\bin\psql.exe" -U postgres -p %PG_PORT% -c "ALTER USER postgres PASSWORD 'STAR-T-PG-TEMP';"
    echo Password set. User can change it via STAR-T UI.
) else (
    echo Failed to register PostgreSQL service.
    exit /b 1
)
