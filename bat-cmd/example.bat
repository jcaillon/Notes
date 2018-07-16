@echo off
REM -----------------------------------
REM Custom startup script by JCA
REM -----------------------------------

REM Issuing a SETLOCAL command, the batch script will inherit all current variables from the master environment/session,
REM Setting EnabledDelayedExpansion will cause each variable to be expanded at execution time rather than at parse time (use ! instead of %)
setlocal Enabledelayedexpansion EnableExtensions
color 70
mode CON lines=30 cols=80
title Startup script
cd /d "%~dp0"
cls


REM @@@@@@@@@@@@@@@@@@@@@@@@@@@@
REM Configuration

REM Set to "on" if there should be a pause after each step
set DEBUG_MODE=off

REM Set to "yes" if the drive should be disconnected prior to mounting it (use "net use * /d" to clean it all)
set UNMOUNT_BEFORE_MOUNT=no

set "DLC=C:\progress\client\v117x_dv\dlc"

REM @@@@@@@@@@@@@@@@@@@@@@@@@@@@
REM Compute stuff

SET PATH_TO_GROUPS=
call :get_value_from_ini "truc.ini" "key" PATH_TO_GROUPS

REM @@@@@@@@@@@@@@@@@@@@@@@@@@@@
REM Main stuff

REM Mount R:
call :try_ping "server.intra"
if "%ERRORLEVEL%"=="0" (
	call :mount_drive "R" "\\server.intra\shared" "/user:DOMAIN\user mdp"
)

REM create useful var
call :set_var "DLC" "%DLC%"
call :add_to_path "%DLC%\bin"

REM create our missing v1110_dv and v101a_dv
call :create_mlink "C:\progress\client\v1110_dv" "C:\progress\client\v117x_dv" /j

REM other links
if "%USERNAME%"=="jcaillon" (
	setx PATH "C:\Program Files\Docker\Docker\Resources\bin;C:\Program Files\dotnet\;C:\Program Files\TortoiseSVN\bin;C:\Program Files\TortoiseGit\bin;C:\Program Files\Git\cmd;C:\data\outils\gnupg\GnuPG\pub;C:\data\outils\ruby-gem\bin;C:\data\outils\VisualStudioCode;C:\data\outils\nuget;C:\data\outils\MTPuTTY;C:\data\outils\postgres;C:\data\outils\python;C:\data\outils\apache-maven\bin;C:\Program Files\7-Zip;C:\Program Files\Java\jdk1.8.0_172\jre\bin;C:\data\outils\openssl\bin;C:\Program Files\Git\usr\bin\;C:\Program Files\Git\;C:\progress\client\v117x_dv\dlc\bin;C:\data\outils\Fiddler;C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin"

	REM call :create_mlink "d:\docs" "%USERPROFILE%\docs" /j
	REM call :create_mlink "d:\outils" "%USERPROFILE%\outils" /j
	REM call :create_mlink "d:\Repo" "%USERPROFILE%\Repo" /j
	REM call :create_mlink "d:\VMs" "%USERPROFILE%\VMs" /j
	REM call :create_mlink "d:\docker" "%USERPROFILE%\docker" /j
	REM call :create_mlink "d:\Work" "%USERPROFILE%\Work" /j
	REM call :create_mlink "d:\OneDriveJca" "%USERPROFILE%\OneDrive - Sopra Steria" /j
	REM call :create_mlink "d:\OneDriveSopra" "%USERPROFILE%\Sopra Steria" /j
	REM call :create_mlink "c:\LiberKey" "%USERPROFILE%\outils\_liberKey" /j
)


color A0
call :show_message "SUCCESS" "The script ended" "Closing in 2s..."
call :delay_execution_by "1000"
call :show_message "SUCCESS" "The script ended" "Closing in 1s..."
call :delay_execution_by "1000"
call :show_message "SUCCESS" "The script ended" "Closing now!"
call :delay_execution_by "200"


REM restore environment variables
endlocal
exit /b 0




REM =================================================================================
REM 								SUBROUTINES - WINDOWS TOOL
REM =================================================================================


REM - -------------------------------------
REM Request admin rights
REM - -------------------------------------
:requestadmin

call :show_message "Requesting admin access..." "Need admin rights to continue"
call :get_unique_temp_file UNIQUETMPFILE
echo Set UAC = CreateObject^("Shell.Application"^) > "%UNIQUETMPFILE%.vbs"
set PARAMS = %*:"=""
echo UAC.ShellExecute "%~s0", "%PARAMS%", "%~dp0", "runas", 1 >> "%UNIQUETMPFILE%.vbs"
cscript //B //NoLogo "%UNIQUETMPFILE%.vbs"
del "%UNIQUETMPFILE%.vbs" 1> nul 2> nul
exit 0


REM - -------------------------------------
REM Check for admin rights
REM - -------------------------------------
REM - %1: name
REM - %2: ip
REM - -------------------------------------
:has_admin_rights
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if not "%ERRORLEVEL%"=="0" (
    exit /b 1
) else (
	exit /b 0
)



REM - -------------------------------------
REM Modify the host file
REM - -------------------------------------
REM - %1: name
REM - %2: ip
REM - -------------------------------------
:modify_to_host_file
REM  --> Check for permissions
call :has_admin_rights

REM --> If error flag set, we do not have admin.
if not "%ERRORLEVEL%"=="0" (
    call :requestadmin
) else (
	call :show_message "MODIFYING HOST FILE... " "%~1 %~2"
)

pushd "%temp%"
copy /b/v/y %SystemRoot%\System32\drivers\etc\hosts %SystemRoot%\System32\drivers\etc\hosts.bak 1>nul 2>nul
set  _name=%~1
set  _value=%~2
set NEWLINE=^& echo.
REM strip out this specific line and store in tmp file
type %SystemRoot%\System32\drivers\etc\hosts | findstr /v !_name! > tmp.txt
REM re-add the line to it
echo %NEWLINE%^!_value! !_name!>>tmp.txt
REM overwrite host file
copy /b/v/y tmp.txt %SystemRoot%\System32\drivers\etc\hosts 1>nul 2>nul
del tmp.txt 1>nul 2>nul
popd
ipconfig /flushdns 1>nul 2>nul

exit /b 0


REM - -------------------------------------
REM Get the value of the variable for the user
REM - -------------------------------------
REM - %1: Var name
REM - %2: Sets the value to this var
REM - -------------------------------------
:get_var
set %2=
for /f "usebackq tokens=3,*" %%A in (`reg query HKCU\Environment /v %~1 2^>nul`) do set %2=%%A

exit /b 0


REM - -------------------------------------
REM Add the given var name/value to the user
REM - -------------------------------------
REM - %1: var name
REM - %2: var value
REM - -------------------------------------
:set_var
call :get_var "%~1" VARVALUE
if not "!VARVALUE!"=="" (
	exit /b 0
)

call :show_message "SETTING USER VAR..." "%~1"
SetX "%~1" "%~2" 1>nul 2>nul
if not "%ERRORLEVEL%" == "0" (
	call :show_error "couldn't set %~1"
	SetX "%~1" "%~2"
	pause
	exit /b 1
)

exit /b 0


REM - -------------------------------------
REM Add the given path to the %PATH% var for the user, make sure it doesn't appear twice
REM - -------------------------------------
REM - %1: Path to add
REM - -------------------------------------
:add_to_path
echo ;%PATH%; | find /C /I "%~1" 1>nul 2>nul
if "%ERRORLEVEL%"=="0" (
	exit /b 0
)
call :show_message "ADDING TO PATH..." "%~1"
set outPath=
for /f "skip=2 tokens=3*" %%a in ('reg query HKCU\Environment /v PATH 2^>nul') do (
	if [%%b]==[] (
		set outPath=%%~a;%~1
	) else (
		set outPath=%%~a %%~b;%~1
	)
)
set outPath=!outPath:%~1;=!
call :set_var "PATH" "%outPath%"
exit /b 0


REM - -------------------------------------
REM Mounts a drive letter to the specified folder
REM - -------------------------------------
REM - %1: Drive letter to be mounted
REM - %2: Path to mount
REM - %2: Options for net use
REM - -------------------------------------
:mount_drive
if "%UNMOUNT_BEFORE_MOUNT%" == "yes" (
	call :unmount_drive "%~1"
)
if not exist "%~1:\" (
	call :show_message "MOUNTING..." "%~1: on" "%~2"
	net use %~1: "%~2" %~3 /persistent:no 1>nul 2>nul
	if not exist "%~1:\" (
		call :show_error "couldn't mount %~1:"
		net use %~1: "%~2" %~3 /persistent:no
		pause
		exit /b 1
	)
)

exit /b 0


REM - -------------------------------------
REM Unmounts a drive letter
REM - -------------------------------------
REM - %1: Drive letter to be unmounted
REM - -------------------------------------
:unmount_drive
if exist "%~1:\" (
	call :show_message "UNMOUNTING..." "%~1:"
	net use %~1: /delete /y 1>nul 2>nul
)

exit /b 0


REM - -------------------------------------
REM Creates a symbolic link (windows 7 and above only)
REM - -------------------------------------
REM - %1: Path of the link folder in D:/
REM - %2: The path in D:/profiles/%USERNAME%/ to be linked in D:/
REM - %3: Params : /D, /J, /F
REM - -------------------------------------
:create_mlink
if exist "%~2" (
	if not exist "%~1" (
		call :show_message "LINKING..." "%~1 on" "%~2"
		mklink %~3 "%~1" "%~2" 1>nul 2>nul
		if not "!ERRORLEVEL!" == "0" (
			call :show_error "couldn't create the link between %~1 and %~2"
			mklink %~3 "%~1" "%~2"
			pause
			exit /b 1
		)
	)
)

exit /b 0



REM - -------------------------------------
REM Copy the given source folder to the target
REM - -------------------------------------
REM - %1: source
REM - %2: target
REM - -------------------------------------
:copy_folder

xcopy /Y /S /I "%~1" "%~2" 1>nul 2>nul
if not "%ERRORLEVEL%" == "0" (
	call :show_error "Error copying %~1:"
	xcopy /Y /S /I "%~1" "%~2"
	pause
	exit /b 1
) else (
	call :show_message "COPYING FOLDER..." "%~1:"
)

exit /b 0


REM - -------------------------------------
REM Unzip a progress library located under $DLC/src/name.pl
REM - --------------------------------------------------------------------------
REM - %1: Name of the .pl file to be extracted (without the .pl extension)
REM - %2: DLC directory
REM - --------------------------------------------------------------------------
:extract_progress_pl
if exist "%~2" (
	if not exist "%~2\src\%~1" (
		call :show_message "EXTRACTING PL..." "%~1.pl in" "%~2\src"
		pushd "%~2\src\"
		md %~1 2>nul
		"%~2\bin\prolib" "%~1.pl" -extract *.*
		popd
	)
)

exit /b 0


REM - -------------------------------------
REM Ping a given ip/hostname and returns if it's alive
REM - -------------------------------------
REM - %1: Address to ping
REM - Sets the errorlevel to 0 if the address is alive, or 1 if it isn't
REM - -------------------------------------
:try_ping
REM first, get the associated IP address
SET IP_TO_PING=
call :get_ip_from_hostname "%~1" IP_TO_PING
if not "%IP_TO_PING%" == "" (
	REM we will find 3 occurrences of the ip address in the response of ping -n 1 if the ip is alive, 2 otherwise
	for /f "delims=" %%d in ('ping -w 250 -n 1 %IP_TO_PING% ^| findstr /c:"%IP_TO_PING%" ^| find /c /v "UselessString"') do (
		if "%%d" == "3" (
			exit /b 0
		)
	)
)

exit /b 1


REM - -------------------------------------
REM Ping a given ip/hostname and returns if it's alive
REM - -------------------------------------
REM - %1: Address to ping
REM - Sets the errorlevel to 0 if the address is alive, or 1 if it isn't
REM - -------------------------------------
:try_ping_ip
REM we will find 3 occurrences of the ip address in the response of ping -n 1 if the ip is alive, 2 otherwise
for /f "delims=" %%d in ('ping -w 100 -n 1 %~1 ^| findstr /c:"%~1" ^| find /c /v "UselessString"') do (
	if "%%d" == "3" (
		exit /b 0
	)
)
exit /b 1



REM - -------------------------------------
REM Get the IP address of a given hostname (if it's already an IP then it returns the same...)
REM - -------------------------------------
REM - %1: Hostname to resolve
REM - %2: Sets the IP address that is the return of this subroutine
REM - -------------------------------------
:get_ip_from_hostname
set %2=
REM Parses <Pinging vm [192.168.150.131] with 32 bytes of data:> to get the VM IP Address
for /f "tokens=2 delims=[" %%a in ('ping -a -w 0 -n 1 %~1 ^| findstr /i "["') do (
	set LOCAL_VAR_IP=%%a
	for /f "tokens=1 delims=]" %%b in ('echo;!LOCAL_VAR_IP!') do (
		set %2=%%b
	)
)

exit /b 0


REM - -------------------------------------
REM Read an "ini style" file and returns the value associated with a key
REM key=value
REM - -------------------------------------
REM - %1: File path to read
REM - %2: The key to read
REM - %3: The return value
REM - -------------------------------------
:get_value_from_ini
for /f "tokens=2 delims=^=" %%g in ('type "%~1" ^| findstr /i "^%~2="') do (
	set %3=%%g
)

exit /b 0


REM - -------------------------------------
REM Parses the batch name in parts separated by ~, returns the part number asked
REM - -------------------------------------
REM - %1: Part number to return
REM - %2: Return value for the part asked
REM - -------------------------------------
:get_batchname_part
set %2=
for /f "tokens=%~1 delims=~" %%a in ('echo;%~n0') do (
	set %2=%%a
)

exit /b 0


REM - -------------------------------------
REM Get the path of a temporary file
REM - -------------------------------------
REM - %1: Returns the file path to a temporary file (unique)
REM - -------------------------------------
:get_unique_temp_file
:loop_get_unique_temp_file
set /a y+=1
set "ff=%TEMP%\xbat_!y!.log"
if exist !ff! goto :loop_get_unique_temp_file
set %1=%ff%
exit /b 0


REM =================================================================================
REM 								SUBROUTINES - BAT TOOLS
REM =================================================================================


REM - -------------------------------------
REM Delay the script execution by X milliseconds
REM - -------------------------------------
REM - %1: ms to wait
REM - -------------------------------------
:delay_execution_by
ping 192.0.0.0 -n 1 -w %~1 1>nul 2>nul

exit /b 0


REM - -------------------------------------
REM Show an error message to the user
REM - -------------------------------------
REM - %1: Error message
REM - -------------------------------------
:show_error
color E0
call :show_message "ERROR" "%~1"
pause
color 70

exit /b 0


REM - -------------------------------------
REM Show a message center in the middle of the console
REM - -------------------------------------
REM - %1: Message title
REM - %2: Message line
REM - -------------------------------------
:show_message
REM Get the number of rows for the console
if "%NB_ROWS%" == "" (
	set NB_ROWS=
	for /f "tokens=3 delims=:" %%g in ('mode CON ^| more +3 ^| findstr /n . ^| findstr /b 1:') do (
		set NB_ROWS=%%g
	)
	set NB_ROWS=!NB_ROWS: =!
	if "!NB_ROWS!" == "" (
		set NB_ROWS=30
	)
	set /a NB_ROWS=!NB_ROWS!-1
)

pushd %TEMP%
REM set "TMP_FILE="
set TMP_FILE=console.out
del /F /Q "%TMP_FILE%" 1>nul 2>nul

REM insert empty lines
set /a NB_LINES=%NB_ROWS%/2-4
for /l %%c in (1, 1, %NB_LINES%) do (
	call :echo_centered "" "%TMP_FILE%"
)
call :echo_centered "###################" "%TMP_FILE%"
if not "%~1" == "" (
	call :echo_centered "%~1" "%TMP_FILE%"
) else (
	call :echo_centered "EXECUTING..." "%TMP_FILE%"
)
call :echo_centered "###################" "%TMP_FILE%"
if not "%~2" == "" (
	call :echo_centered "%~2" "%TMP_FILE%"
) else (
	call :echo_centered "" "%TMP_FILE%"
)
if not "%~3" == "" (
	call :echo_centered "%~3" "%TMP_FILE%"
) else (
	call :echo_centered "" "%TMP_FILE%"
)
REM insert empty lines
set /a NB_LINES=%NB_ROWS%-(%NB_ROWS%/2-4+5)-1
for /l %%c in (1, 1, %NB_LINES%) do (
	call :echo_centered "" "%TMP_FILE%"
)

if "%DEBUG_MODE%"=="on" (
	pause
)

REM flush the content of TMP_FILE to the console screen
cls
type "%TMP_FILE%"
popd


exit /b 0


REM - -------------------------------------
REM Echo command centered
REM - -------------------------------------
REM - %1: Message
REM - %2: if not empty, echo; to file instead of console
REM - -------------------------------------
:echo_centered
REM Get the number of columns for the console
if "%NB_COLUMNS%" == "" (
	set NB_COLUMNS=
	for /f "tokens=3 delims=:" %%g in ('mode CON ^| more +4 ^| findstr /n . ^| findstr /b 1:') do (
		set NB_COLUMNS=%%g
	)
	set NB_COLUMNS=!NB_COLUMNS: =!
	if "!NB_COLUMNS!" == "" (
		set NB_COLUMNS=80
	)
	set /a NB_COLUMNS=!NB_COLUMNS!-1
)

set "s="
if not "%~1" == "" (
	REM Add enough space before the text to make it look centered
	set "s=%~1"
	for /L %%# in (1, 2, %NB_COLUMNS%) do (
		if "!s:~%NB_COLUMNS%,1!" == "" (
			set "s= !s! "
		)
	)
	set s=!s:~1,%NB_COLUMNS%!
)

set OUTPUT_FILE=%~2
if "%~2" == "" (
	echo;!s!
) else (
	echo;!s!>>"%OUTPUT_FILE%"
)

exit /b 0


REM - -------------------------------------
REM Resets the error level
REM - -------------------------------------
:reset_errorlevel

exit /b 0

