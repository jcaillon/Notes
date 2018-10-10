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
    [ValidateSet('Debug', 'Release')]
    $Configuration = $null,
    [switch]
    $ci,
    [switch]
    $sign,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$MSBuildArgs
)

function Main {

    Write-Host "================"
    Write-Host "This job pushes the current reference ($env:CI_COMMIT_REF_NAME) to the remote URL git clone :`nhttp://<OE_CI_CNAF_GITLAB_TOKEN>@git.intra.cnaf/$CI_GIT_INTRA_CNAF_PROJECT_PATH.git --config $env:OE_CI_CNAF_HTTP_PROXY"
    Write-Host "================"

    if (!$Configuration) {
        $Configuration = if ($ci) { 'Release' } else { 'Debug' }
    }

    Write-Host $Configuration
    Write-Host $sign

    Write-Host @MSBuildArgs
}

try {
    $ErrorActionPreference = 'Stop'
    Write-Host "Starting $($MyInvocation.MyCommand)";
    # load module
    Import-Module -Force -Scope Local $(Join-Path -Path $PSScriptRoot -ChildPath "$([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)).psm1");
    # go
    Main
} catch {
    $exceptionCatched = $_.Exception.ToString();
    Write-Host "Exception : $exceptionCatched";
    ExitWithCode(1);
}

ExitWithCode(0);