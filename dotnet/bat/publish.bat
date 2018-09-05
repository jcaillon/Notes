@if not defined _echo echo off
setlocal enabledelayedexpansion

call build.bat
if %errorlevel% neq 0 goto ENDINERROR

if "%NUPKG_DIR%"=="" set "NUPKG_DIR=bin\Any CPU\Release\"
if "%API_KEY%"=="" set API_KEY=

if "%NUPKG_DIR%"=="" (
	echo.[%time:~0,8% ERRO].Variable NUPKG_DIR is not set!
	goto ENDINERROR
)

if "%API_KEY%"=="" (
	echo.[%time:~0,8% ERRO].Variable API_KEY is not set!
	goto ENDINERROR
)

REM @@@@@@@@@@@@@@
REM Solution name
set "NUPKG_FILE="
FOR /F "tokens=* USEBACKQ" %%F IN (`dir /b "%NUPKG_DIR%*.nupkg"`) DO (
	set NUPKG_FILE=%%F
)

REM [works for gitlab and appveyor]
REM https://docs.gitlab.com/ee/ci/variables/
REM https://www.appveyor.com/docs/environment-variables/
if "%CI_COMMIT_SHA%"=="" set CI_COMMIT_SHA=%APPVEYOR_REPO_COMMIT%

REM @@@@@@@@@@@@@@
REM Are we on a CI build? 
set IS_CI_BUILD=false
if not "%CI_COMMIT_SHA%"=="" set IS_CI_BUILD=true

echo.
echo.=========================
echo.[%time:~0,8% INFO] PUBLISHING TO NUGET.ORG...
echo.[%time:~0,8% INFO] NUPKG_FILE = %NUPKG_FILE%

nuget push "%NUPKG_DIR%%NUPKG_FILE%" %API_KEY% -NonInteractive -ForceEnglishOutput -Source https://api.nuget.org/v3/index.json

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