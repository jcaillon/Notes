@if not defined _echo echo off
setlocal enabledelayedexpansion

REM if PROJECT_PATH is empty, we use the solution
set PROJECT_PATH=GitPolicyAgentServer\GitPolicyAgentServer.csproj
set DEFAULT_VERSION=0.0.1
set "VERSION_SUFFIX="
REM set below to false if you don't want to change the target framework on build
set CHANGE_DEFAULT_TARGET=true
set TARGETED_FRAMEWORKS=(netcoreapp2.0 net461)
set TTYPE=Publish

REM https://github.com/Microsoft/msbuild/wiki/MSBuild-Tips-&-Tricks

REM [works for gitlab and appveyor]
REM https://docs.gitlab.com/ee/ci/variables/
REM https://www.appveyor.com/docs/environment-variables/
rem if "%CI_BUILD_ID%"=="" set CI_BUILD_ID=%APPVEYOR_BUILD_ID%
if "%CI_COMMIT_TAG%"=="" set CI_COMMIT_TAG=%APPVEYOR_REPO_TAG_NAME%
if "%CI_COMMIT_SHA%"=="" set CI_COMMIT_SHA=%APPVEYOR_REPO_COMMIT%

REM @@@@@@@@@@@@@@
REM Are we on a CI build? 
set IS_CI_BUILD=false
if not "%CI_COMMIT_SHA%"=="" set IS_CI_BUILD=true

REM @@@@@@@@@@@@@@
REM Are we on a TAG build? 
set IS_TAG_BUILD=false
if "%VERSION_TO_BUILD%"=="" set VERSION_TO_BUILD=%CI_COMMIT_TAG%
if not "%VERSION_TO_BUILD%"=="" set IS_TAG_BUILD=true

REM @@@@@@@@@@@@@@
REM What is the version we are building?
set VERSION_TO_BUILD=%CI_COMMIT_TAG%
if "%VERSION_TO_BUILD%"=="" set VERSION_TO_BUILD=%DEFAULT_VERSION%
IF "%VERSION_TO_BUILD:~0,1%"=="v" set "VERSION_TO_BUILD=%VERSION_TO_BUILD:~1%"

REM @@@@@@@@@@@@@@
REM Verbosity
set MSBUILD_VERBOSITY=m
if "%IS_CI_BUILD%"=="true" set MSBUILD_VERBOSITY=n

REM @@@@@@@@@@@@@@
REM Solution name
FOR /F "tokens=* USEBACKQ" %%F IN (`dir /b *.sln`) DO (
	set SOLUTION_NAME=%%F
)

if "%PROJECT_PATH%"=="" (
	set "PROJECT_PATH=%SOLUTION_NAME%"
)

echo.=========================
echo.[%time:~0,8% INFO] BUILDING VERSION %VERSION_TO_BUILD%
echo.[%time:~0,8% INFO] CI BUILD : %IS_CI_BUILD%
echo.[%time:~0,8% INFO] TAG BUILD : %IS_TAG_BUILD%
echo.[%time:~0,8% INFO] COMMIT SHA : %CI_COMMIT_SHA%
echo.[%time:~0,8% INFO] COMMIT TAG : %CI_COMMIT_TAG%
echo.[%time:~0,8% INFO] VERBOSITY : %MSBUILD_VERBOSITY%
echo.[%time:~0,8% INFO] SOLUTION : %SOLUTION_NAME%
echo.[%time:~0,8% INFO] PROJECT PATH : %PROJECT_PATH%
echo.


REM @@@@@@@@@@@@@@
REM Actual Build

if "%CHANGE_DEFAULT_TARGET%"=="true" (
	for %%i in %TARGETED_FRAMEWORKS% do (
		echo.[%time:~0,8% INFO] Target is %%i
		Call :BUILD_ONE "%%i" "%ADD_RESTORE%"
		if not "!ERRORLEVEL!"=="0" (
			GOTO ENDINERROR
		)
	)
) else (
	Call :BUILD_ONE "" "%ADD_RESTORE%"
	if not "!ERRORLEVEL!"=="0" (
		GOTO ENDINERROR
	)
)

:DONE
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
REM Build one target
REM - -------------------------------------
REM - %1: target framework
REM - %2: need restore
REM - -------------------------------------
:BUILD_ONE

echo.
echo.=========================
echo.[%time:~0,8% INFO] BUILDING %~1

echo.[%time:~0,8% INFO] Restoring packages
echo.

set ADD_RESTORE=false
where nuget 1>nul 2>nul
if "%ERRORLEVEL%"=="0" (
	echo.[%time:~0,8% INFO] Nuget found
	nuget restore %SOLUTION_NAME% -Recursive -NonInteractive
	if not "!ERRORLEVEL!"=="0" (
		set ADD_RESTORE=true
	)
) else (
	echo.[%time:~0,8% INFO] Nuget not found in PATH
	set ADD_RESTORE=true
)

REM common params
set "COMMON_PARAM=%PROJECT_PATH% /p:VersionPrefix="%VERSION_TO_BUILD%" /p:VersionSuffix="%VERSION_SUFFIX%" /p:Configuration=Release /p:Platform="Any CPU" /p:IncludeSymbols=true /verbosity:%MSBUILD_VERBOSITY% /m /p:ZipRelease=true"

REM targetFramework
if not "%~1"=="" (
	set "PROPTARGET=/p:targetFramework=%~1"
)

REM Build/Publish + Restore
set "INPUTFWORK=%~1"
IF "%INPUTFWORK:~0,4%"=="netc" (
	set "TTYPE=Publish"
)
IF "%INPUTFWORK:~0,4%"=="nets" (
	set "TTYPE=Publish"	
)
IF "%TTYPE%"=="" (
	set "TTYPE=Rebuild"	
)
if "%~2"=="true" (
	set "TTYPE=Restore,%TTYPE%"
)

echo.
echo.[%time:~0,8% INFO] Starting msbuild
echo.[%time:~0,8% INFO] PROPTARGET = %PROPTARGET%
echo.[%time:~0,8% INFO] TTYPE = %TTYPE%
echo.

echo msbuild binlog viewer : http://msbuildlog.com/

call :MS_BUILD %COMMON_PARAM% %PROPTARGET% /t:%TTYPE% /bl:%~1.binlog
if not "%ERRORLEVEL%"=="0" (
	exit /b 1
)

echo.

exit /b 0


REM - -------------------------------------
REM MS_BUILD
REM - -------------------------------------
:MS_BUILD

@REM Determine if MSBuild is already in the PATH
for /f "usebackq delims=" %%I in (`where msbuild.exe 2^>nul`) do (
    "%%I" %*
    exit /b !ERRORLEVEL!
)

@REM Find the latest MSBuild that supports our projects
for /f "usebackq delims=" %%I in ('"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -version "[15.0,)" -latest -prerelease -products * -requires Microsoft.Component.MSBuild Microsoft.VisualStudio.Component.Roslyn.Compiler Microsoft.VisualStudio.Component.VC.140 -property InstallationPath') do (
    for /f "usebackq delims=" %%J in (`where /r "%%I\MSBuild" msbuild.exe 2^>nul ^| sort /r`) do (
        "%%J" %*
        exit /b !ERRORLEVEL!
    )
)

echo.=========================
echo.[%time:~0,8% ERRO] Could not find msbuild.exe 1>&2
exit /b 2