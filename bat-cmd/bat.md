# batch windows

## trucs

for /?
in the command-line gives help about this syntax (which can be used outside FOR, too, this is just the place where help can be found).

In addition, substitution of FOR variable references has been enhanced. You can now use the following optional syntax:

%~I         - expands %I removing any surrounding quotes (")
%~fI        - expands %I to a fully qualified path name
%~dI        - expands %I to a drive letter only
%~pI        - expands %I to a path only
%~nI        - expands %I to a file name only
%~xI        - expands %I to a file extension only
%~sI        - expanded path contains short names only
%~aI        - expands %I to file attributes of file
%~tI        - expands %I to date/time of file
%~zI        - expands %I to size of file
%~$PATH:I   - searches the directories listed in the PATH
               environment variable and expands %I to the
               fully qualified name of the first one found.
               If the environment variable name is not
               defined or the file is not found by the
               search, then this modifier expands to the
               empty string
The modifiers can be combined to get compound results:

%~dpI       - expands %I to a drive letter and path only
%~nxI       - expands %I to a file name and extension only
%~fsI       - expands %I to a full path name with short names only
%~dp$PATH:I - searches the directories listed in the PATH
               environment variable for %I and expands to the
               drive letter and path of the first one found.
%~ftzaI     - expands %I to a DIR like output line
In the above examples %I and PATH can be replaced by other valid values. The %~ syntax is terminated by a valid FOR variable name. Picking upper case variable names like %I makes it more readable and avoids confusion with the modifiers, which are not case sensitive.

There are different letters you can use like f for "full path name", d for drive letter, p for path, and they can be combined. %~ is the beginning for each of those sequences and a number I denotes it works on the parameter %I (where %0 is the complete name of the batch file, just like you assumed).

## LOCK A FILE :

```bat
notepad>>filetolock
```

```bat
xcopy "%OUTPUTBASEDIR%\publish\*" "publish" /s /i /y
```

```bat
xcopy "%CURRENT_DIR%*" "%HOOK_DIR%" /s /i /y /h 1>nul
```

Folder selection menu :

```bat
REM - -------------------------------------
REM Configuration selection
REM - -------------------------------------
:STARTMENU
echo.
echo.======================
echo. Configuration selection
echo.======================
echo.
echo.Choose the best suited configuration for you
echo.Each configuration enforce (or does not enforce) some git policy
echo.Ask people in your project if you are not sure of which configuration to use
echo.
echo.1 - Abort
set "CHOICES=1"
set /a i=2
pushd config
FOR /D %%G in ("*") do (
    echo.!i! - %%~nxG
    set "CHOICES=!CHOICES!!i!"
    set /a i=!i!+1
)
popd
echo.
CHOICE /C:%CHOICES% /M "Select your configuration"
set "THE_CHOICE=%ERRORLEVEL%"
echo.You chose option %THE_CHOICE%

REM Abort?
IF "%THE_CHOICE%" == "1" exit /b 1

set /a i=2
pushd config
FOR /D %%G in ("*") do (
    if "!i!" == "%THE_CHOICE%" (
        set "CONFIGURATION_CHOSEN=%%~nxG"
        GOTO ENDOFCHOICELOOP
    )
    set /a i=!i!+1
)
popd
echo.Invalid choice
pause
exit /b 1
:ENDOFCHOICELOOP

echo.Applying configuration %CONFIGURATION_CHOSEN%

git config --global hook.configFolderName %CONFIGURATION_CHOSEN%

if not "%ERRORLEVEL%"=="0" (
    echo.ERROR : could not set up core.hooksPath with git
    pause
    exit /b 1
)

exit /b 0
```
