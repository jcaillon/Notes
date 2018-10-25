@ECHO OFF
PowerShell -NoProfile -NoLogo -ExecutionPolicy unrestricted -Command "& '%~dp0%~n0.ps1' %*"
echo %errorlevel%
exit /b %errorlevel%