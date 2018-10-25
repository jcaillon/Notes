#!/usr/bin/env pwsh
<#
.Synopsis
    Acquires dependencies, builds, and tests this project.
.Description
    If no actions are specified, the default is to run all actions.
.Parameter Restore
    Restore NuGet packages.
.Parameter Build
    Build the entire project. Requires that -Restore is or has been executed.
.Parameter Test
    Run all built tests.
.Parameter Configuration
    The configuration to build. Either "debug" or "release". The default is debug, or the Configuration environment variable if set.
.Parameter WarnAsError
    Converts all build warnings to errors. Useful in preparation to sending a pull request.
.Parameter GeneratePInvokesTxt
    Produces the LIBNAME.pinvokes.txt files along with the assemblies during the build.
.Parameter NoParallelTests
    Do not execute tests in parallel.
#>
[CmdletBinding(PositionalBinding = $false)]
param(
    [ValidateSet('debug', 'release')]
    [string] $Configuration = ${Env:configuration},
    [switch] $Ci,
    [switch] $Sign,
    [Parameter(ValueFromRemainingArguments = $true)] [string[]] $MSBuildArgs
)

#Set-StrictMode -Version 2.0

Function Main {

    #$MSBuildCommand = Get-Command MSBuild.exe -ErrorAction SilentlyContinue
    if (!$MSBuildCommand) {
        $MSBuildCommand = & "${Env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -latest -prerelease -products * -requires Microsoft.Component.MSBuild -property InstallationPath
        $MSBuildCommand = & cmd.exe /c where /r "$MSBuildCommand" "msbuild.exe"
    }
    if (!$MSBuildCommand) {
        
    }
    Write-Log "$MSBuildCommand"
    


    Write-Log "$MSBuildCommand"

    

  #      New-Item $nstDir -ItemType Directory -ErrorAction Ignore | Out-Null
  #      Invoke-WebRequest https://github.com/onovotny/NuGetKeyVaultSignTool/releases/download/v1.1.4/NuGetKeyVaultSignTool.1.1.4.nupkg `
  #          -OutFile "$nstDir/NuGetKeyVaultSignTool.zip"
  #      Expand-Archive "$nstDir/NuGetKeyVaultSignTool.zip" -DestinationPath $nstDir

    Write-Log "================"
    Write-Log "This job pushes the current reference ($env:CI_COMMIT_REF_NAME) to the remote URL git clone :`nhttp://<OE_CI_CNAF_GITLAB_TOKEN>@git.intra.cnaf/$env:CI_GIT_INTRA_CNAF_PROJECT_PATH.git --config $env:OE_CI_CNAF_HTTP_PROXY"
    Write-Log "================"

    if (!$Configuration) {
        $Configuration = if ($ci) { 'Release' } else { 'Debug' }
    }

    Write-Log $Configuration -ForegroundColor "Green"
    Write-Log $sign

    Write-Log @MSBuildArgs
}


try {
    $ErrorActionPreference = 'Stop'
    # load module
    Import-Module -Force -Scope Local $(Join-Path -Path $PSScriptRoot -ChildPath "$([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)).psm1");
    # go
    Main
} catch {
    $exceptionCatched = $_.Exception.ToString();
    Write-Log "[$([datetime]::Now.ToLongTimeString())] Exception : $exceptionCatched" -ForegroundColor "Red";
    $Host.SetShouldExit(1)
    exit 1
}

exit 0