@if not defined _echo echo off
setlocal enabledelayedexpansion

set DEFAULT_RELEASE_MESSAGE=release
REM BINARIES_DIRECTORY contains the executables that should be stored under the binaries branch
set BINARIES_DIRECTORY=bin
REM PROJECT_ROOT_DIRECTORY is the path to go from this .bat to the project root directory
set PROJECT_ROOT_DIRECTORY=.
set MERGE_BRANCH=rel
set BINARIES_BRANCH=binaries

REM [works for gitlab and appveyor]
REM https://docs.gitlab.com/ee/ci/variables/
REM https://www.appveyor.com/docs/environment-variables/
if "%CI_BUILD_ID%"=="" set CI_BUILD_ID=%APPVEYOR_BUILD_ID%
if "%CI_COMMIT_TAG%"=="" set CI_COMMIT_TAG=%APPVEYOR_REPO_TAG_NAME%
if "%CI_COMMIT_SHA%"=="" set CI_COMMIT_SHA=%APPVEYOR_REPO_COMMIT%
REM also needs CI_REPO_SSH_URL

REM @@@@@@@@@@@@@@
REM Are we on a CI build? 
set IS_CI_BUILD=false
if not "%CI_COMMIT_SHA%"=="" set IS_CI_BUILD=true

REM @@@@@@@@@@@@@@
REM Are we on a TAG build? 
set IS_TAG_BUILD=false
if not "%CI_COMMIT_TAG%"=="" set IS_TAG_BUILD=true

REM @@@@@@@@@@@@@@
REM What will be the commit/release message?
set RELEASE_MESSAGE=%CI_COMMIT_TAG%
if "%RELEASE_MESSAGE%"=="" set RELEASE_MESSAGE=%DEFAULT_RELEASE_MESSAGE%
IF "%RELEASE_MESSAGE:~0,1%"=="v" set "RELEASE_MESSAGE=%RELEASE_MESSAGE:~1%"

REM @@@@@@@@@@@@@@
REM Pushing binaries to an orphan branch? only on tag
if "%IS_TAG_BUILD%"=="false" goto DONE

echo.=========================
echo.[%time:~0,8% INFO] RELEASING %RELEASE_MESSAGE%
echo.[%time:~0,8% INFO] CI BUILD : %IS_CI_BUILD%
echo.[%time:~0,8% INFO] TAG BUILD : %IS_TAG_BUILD%
echo.[%time:~0,8% INFO] COMMIT SHA : %CI_COMMIT_SHA%
echo.[%time:~0,8% INFO] COMMIT TAG : %CI_COMMIT_TAG%
echo.

if "%CI_REPO_SSH_URL%"=="" (
	echo.[%time:~0,8% ERRO].Variable CI_REPO_SSH_URL is not set!
	goto ENDINERROR
)

echo.
echo.=========================
echo.[%time:~0,8% INFO] GETTING REPO COPY...

pushd %PROJECT_ROOT_DIRECTORY%

if exist ".tmp" (
	rmdir /S /Q ".tmp"
)

echo.[%time:~0,8% INFO] git clone xxx .tmp
git clone %CI_REPO_SSH_URL% .tmp
if %errorlevel% neq 0 goto ENDINERROR

pushd .tmp

echo.[%time:~0,8% INFO] Copying bin output
xcopy "..\%BINARIES_DIRECTORY%\*" "%BINARIES_DIRECTORY%" /s /i /y /h
if %errorlevel% neq 0 goto ENDINERROR

echo.
echo.=========================
echo.[%time:~0,8% INFO] ADDING BINARIES TO %BINARIES_BRANCH% BRANCH...

echo.[%time:~0,8% INFO] git checkout --orphan %BINARIES_BRANCH%
git checkout --orphan %BINARIES_BRANCH%
if %errorlevel% neq 0 goto ENDINERROR

echo.[%time:~0,8% INFO] git reset
git reset
if %errorlevel% neq 0 goto ENDINERROR

echo.[%time:~0,8% INFO] git add %BINARIES_DIRECTORY%/* -f
git add %BINARIES_DIRECTORY%/* -f
if %errorlevel% neq 0 goto ENDINERROR

echo.[%time:~0,8% INFO] git commit -m "v%RELEASE_MESSAGE%"
git commit -m "v%RELEASE_MESSAGE%"
if %errorlevel% neq 0 goto ENDINERROR

echo.[%time:~0,8% INFO] git push -f origin %BINARIES_BRANCH%
git push -f origin %BINARIES_BRANCH%
if %errorlevel% neq 0 goto ENDINERROR

echo.
echo.=========================
echo.[%time:~0,8% INFO] MERGING ONTO %MERGE_BRANCH%...

echo.[%time:~0,8% INFO] git checkout -f %MERGE_BRANCH%
git checkout -f %MERGE_BRANCH%
if %errorlevel% neq 0 (

	echo.[%time:~0,8% INFO] git checkout -f -b %MERGE_BRANCH% %CI_COMMIT_TAG%
	git checkout -f -b %MERGE_BRANCH% %CI_COMMIT_TAG%
	if !errorlevel! neq 0 goto ENDINERROR
) else (
	
	echo.[%time:~0,8% INFO] git reset --hard origin/%MERGE_BRANCH%
	git reset --hard origin/%MERGE_BRANCH%

	echo.[%time:~0,8% INFO] git clean -f
	git clean -f

	echo.[%time:~0,8% INFO] git merge --ff-only %CI_COMMIT_TAG%
	git merge --ff-only %CI_COMMIT_TAG%
	if !errorlevel! neq 0 goto ENDINERROR
)

echo.[%time:~0,8% INFO] git push origin %MERGE_BRANCH%
git push origin %MERGE_BRANCH%
if %errorlevel% neq 0 goto ENDINERROR

popd

if exist ".tmp" (
	rmdir /S /Q ".tmp"
)

popd

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