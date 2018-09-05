@if not defined _echo echo off
setlocal enabledelayedexpansion

REM BINARIES_DIRECTORY contains the executables that should be stored under the binaries branch
set BINARIES_DIRECTORY=bin
set BINARIES_BRANCH=binaries

if "%REMOTE_SERVICE_NAME%"=="" set REMOTE_SERVICE_NAME=MailBot
if "%REMOTE_DEPLOY_DIRECTORY_NAME%"=="" set "REMOTE_DEPLOY_DIRECTORY_NAME=%REMOTE_SERVICE_NAME%"
if "%REMOTE_MACHINE_NAME%"=="" set REMOTE_MACHINE_NAME=
if "%REMOTE_NET_USE_DIR%"=="" set REMOTE_NET_USE_DIR=
if "%REMOTE_NET_USE_OPTIONS%"=="" set REMOTE_NET_USE_OPTIONS=

rem if "%REMOTE_MACHINE_NAME%"=="" set REMOTE_MACHINE_NAME=swinclsoutils01.lyon.fr.sopra
rem if "%REMOTE_NET_USE_DIR%"=="" set REMOTE_NET_USE_DIR=\\%REMOTE_MACHINE_NAME%\deploy
rem if "%REMOTE_NET_USE_OPTIONS%"=="" set REMOTE_NET_USE_OPTIONS=/user:EMEAAD\jiracnafsvc Sopra123*

if "%REMOTE_MACHINE_NAME%"=="" (
	echo.[%time:~0,8% ERRO].Variable REMOTE_MACHINE_NAME is not set!
	goto ENDINERROR
)
if "%REMOTE_NET_USE_DIR%"=="" (
	echo.[%time:~0,8% ERRO].Variable REMOTE_NET_USE_DIR is not set!
	goto ENDINERROR
)

REM [works for gitlab and appveyor]
REM https://docs.gitlab.com/ee/ci/variables/
REM https://www.appveyor.com/docs/environment-variables/
if "%CI_COMMIT_SHA%"=="" set CI_COMMIT_SHA=%APPVEYOR_REPO_COMMIT%

REM @@@@@@@@@@@@@@
REM Are we on a CI build? 
set IS_CI_BUILD=false
if not "%CI_COMMIT_SHA%"=="" set IS_CI_BUILD=true

echo.=========================
echo.[%time:~0,8% INFO] DEPLOYING...
echo.[%time:~0,8% INFO] REMOTE_SERVICE_NAME : %REMOTE_SERVICE_NAME%
echo.[%time:~0,8% INFO] REMOTE_MACHINE_NAME : %REMOTE_MACHINE_NAME%
echo.[%time:~0,8% INFO] REMOTE_NET_USE_DIR : %REMOTE_NET_USE_DIR%

echo.

echo.
echo.=========================
echo.[%time:~0,8% INFO] CONNECT TO %REMOTE_NET_USE_DIR%
net use "%REMOTE_NET_USE_DIR%" %REMOTE_NET_USE_OPTIONS% 1>nul 2>nul
if %errorlevel% neq 0 goto ENDINERROR


REM @@@@@@@@@@@@@@
REM Is there a service? 
set SERVICE_EXISTS=false
sc \\%REMOTE_MACHINE_NAME% query %REMOTE_SERVICE_NAME% 1> nul 2> nul
if "%ERRORLEVEL%" == "0" (
	set SERVICE_EXISTS=true
)
echo.[%time:~0,8% INFO] SERVICE_EXISTS : %SERVICE_EXISTS%

rem we could create/delete the service each time but our user doesn't have the rights to create services
rem sc \\<target> <name> create binpath= "cmd.exe /k <command>"

if "%SERVICE_EXISTS%" == "true" (
	echo.
	echo.=========================
	echo.[%time:~0,8% INFO] STOPPING REMOTE SERVICE
	call :STOP_SERVICE %REMOTE_MACHINE_NAME% %REMOTE_SERVICE_NAME%
	rem sc \\%REMOTE_MACHINE_NAME% stop %REMOTE_SERVICE_NAME%
)

echo.
echo.=========================
echo.[%time:~0,8% INFO] CHECKOUT BINARIES
echo.[%time:~0,8% INFO] git checkout -f origin/%BINARIES_BRANCH% -- %BINARIES_DIRECTORY%
git checkout -f origin/%BINARIES_BRANCH% -- %BINARIES_DIRECTORY%
if %errorlevel% neq 0 goto ENDINERROR

echo.
echo.=========================
echo.[%time:~0,8% INFO] DEPLOY BINARIES
set EXCLUDE_FILE=.git\excluded_files.txt
echo.MailBot.Settings.json>%EXCLUDE_FILE%
echo.NLog.config>>%EXCLUDE_FILE%
xcopy "%BINARIES_DIRECTORY%\*" "%REMOTE_NET_USE_DIR%\%REMOTE_DEPLOY_DIRECTORY_NAME%" /s /i /y /h /EXCLUDE:%EXCLUDE_FILE%
del %EXCLUDE_FILE%

if "%SERVICE_EXISTS%" == "true" (
	echo.
	echo.=========================
	echo.[%time:~0,8% INFO] STARTING REMOTE SERVICE
	rem sc \\%REMOTE_MACHINE_NAME% start %REMOTE_SERVICE_NAME%
	call :START_SERVICE %REMOTE_MACHINE_NAME% %REMOTE_SERVICE_NAME%
)

net use "%REMOTE_NET_USE_DIR%" /delete 1>nul 2>nul

:DONE
echo.
echo.=========================
echo.[%time:~0,8% INFO] DONE

if "%IS_CI_BUILD%"=="false" (
	pause
)


REM @@@@@@@@@@@@@@
REM End of script
exit /b 0


REM =================================================================================
REM 								SUBROUTINES - LABELS
REM =================================================================================


REM - -------------------------------------
REM Ending in error
REM - -------------------------------------
:ENDINERROR

echo.=========================
echo.[%time:~0,8% ERRO] ERROR!!! ERRORLEVEL = %errorlevel%

if "%IS_CI_BUILD%"=="false" (
	pause
)

exit /b 1


REM - -------------------------------------
REM Stop a distant service
REM - -------------------------------------
REM - %1: machine
REM - %2: service
REM - -------------------------------------
:STOP_SERVICE

ping -n 1 %1 | FIND "TTL=" >NUL
IF errorlevel 1 GOTO SystemOffline
SC \\%1 query %2 | FIND "STATE" >NUL
IF errorlevel 1 GOTO SystemOffline

:ResolveInitialState
SC \\%1 query %2 | FIND "STATE" | FIND "RUNNING" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO StopService
SC \\%1 query %2 | FIND "STATE" | FIND "STOPPED" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO StoppedService
SC \\%1 query %2 | FIND "STATE" | FIND "PAUSED" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO SystemOffline
echo Service State is changing, waiting for service to resolve its state before making changes
sc \\%1 query %2 | Find "STATE" >NUL
timeout /t 2 /nobreak >NUL
GOTO ResolveInitialState

:StopService
echo Stopping %2 on \\%1
sc \\%1 stop %2 %3 >NUL
GOTO StoppingService

:StoppingServiceDelay
echo Waiting for %2 to stop
timeout /t 2 /nobreak >NUL

:StoppingService
SC \\%1 query %2 | FIND "STATE" | FIND "STOPPED" >NUL
IF errorlevel 1 GOTO StoppingServiceDelay

:StoppedService
echo %2 on \\%1 is stopped
exit /b 0

:SystemOffline
echo Server \\%1 or service %2 is not accessible or is offline
exit /b 1


REM - -------------------------------------
REM Start a distant service
REM - -------------------------------------
REM - %1: machine
REM - %2: service
REM - -------------------------------------
:START_SERVICE

ping -n 1 %1 | FIND "TTL=" >NUL
IF errorlevel 1 GOTO SystemOffline2
SC \\%1 query %2 | FIND "STATE" >NUL
IF errorlevel 1 GOTO SystemOffline2

:ResolveInitialState2
SC \\%1 query %2 | FIND "STATE" | FIND "STOPPED" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO StartService
SC \\%1 query %2 | FIND "STATE" | FIND "RUNNING" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO StartedService
SC \\%1 query %2 | FIND "STATE" | FIND "PAUSED" >NUL
IF errorlevel 0 IF NOT errorlevel 1 GOTO SystemOffline2
echo Service State is changing, waiting for service to resolve its state before making changes
sc \\%1 query %2 | Find "STATE" >NUL
timeout /t 2 /nobreak >NUL
GOTO ResolveInitialState2

:StartService
echo Starting %2 on \\%1
sc \\%1 start %2 >NUL
GOTO StartingService

:StartingServiceDelay
echo Waiting for %2 to start
timeout /t 2 /nobreak >NUL

:StartingService
SC \\%1 query %2 | FIND "STATE" | FIND "RUNNING" >NUL
IF errorlevel 1 GOTO StartingServiceDelay

:StartedService
echo %2 on \\%1 is started
exit /b 0

:SystemOffline2
echo Server \\%1 is not accessible or is offline
exit /b 1