#!/usr/bin/env pwsh
# parse trx file from dotnet test
Function ParseFailuresInTrxResultFile ( [string] $xmlInputFile )
{
    $xml = [Xml](Get-Content $xmlInputFile)

    # <ResultSummary outcome="Failed">
    #   <Counters total="652" executed="650" passed="630" failed="20" error="0" timeout="0" aborted="0" inconclusive="0" passedButRunAborted="0" notRunnable="0" notExecuted="0" disconnected="0" warning="0" completed="0" inProgress="0" pending="0" />
    #   ...

    $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    # our input mstest XML is per this schema
    $xmlNamespace = "http://microsoft.com/schemas/VisualStudio/TeamTest/2010"
    $ns.AddNamespace("ns", $xmlNamespace)

    $xpath = "//ns:ResultSummary/ns:Counters" # xpath when namespaces exists
    $resultSummary = $xml.SelectSingleNode($xpath, $ns)
    
    return $resultSummary.failed
}


[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter()][ValidateSet('debug', 'release')]
    [string]$Configuration = $env:configuration,
    [switch]
    $ci,
    [switch]
    $sign,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$MSBuildArgs
)

Set-StrictMode -Version 1
$ErrorActionPreference = 'Stop'

Import-Module -Force -Scope Local "$PSScriptRoot/src/common.psm1"

#
# Main
#

if ($env:CI -eq 'true') {
    $ci = $true
}

if (!$Configuration) {
    $Configuration = if ($ci) { 'Release' } else { 'Debug' }
}

if ($ci) {
    $MSBuildArgs += '-p:CI=true'
}

$CodeSign = $sign -or ($ci -and -not $env:APPVEYOR_PULL_REQUEST_HEAD_COMMIT -and ($IsWindows -or -not $IsCoreCLR))

if ($CodeSign) {
    $astDir = "$PSScriptRoot/.build/tools/store/AzureSignTool/1.0.1/"
    $AzureSignToolPath = "$astDir/AzureSignTool.exe"
    if (-not (Test-Path $AzureSignToolPath)) {
        New-Item $astDir -ItemType Directory -ErrorAction Ignore | Out-Null
        Invoke-WebRequest https://github.com/vcsjones/AzureSignTool/releases/download/1.0.1/AzureSignTool.zip `
            -OutFile "$astDir/AzureSignTool.zip"
        Expand-Archive "$astDir/AzureSignTool.zip" -DestinationPath $astDir
    }

    $nstDir = "$PSScriptRoot/.build/tools/store/NuGetKeyVaultSignTool/1.1.4/"
    $NuGetKeyVaultSignTool = "$nstDir/tools/net471/NuGetKeyVaultSignTool.exe"
    if (-not (Test-Path $NuGetKeyVaultSignTool)) {
        New-Item $nstDir -ItemType Directory -ErrorAction Ignore | Out-Null
        Invoke-WebRequest https://github.com/onovotny/NuGetKeyVaultSignTool/releases/download/v1.1.4/NuGetKeyVaultSignTool.1.1.4.nupkg `
            -OutFile "$nstDir/NuGetKeyVaultSignTool.zip"
        Expand-Archive "$nstDir/NuGetKeyVaultSignTool.zip" -DestinationPath $nstDir
    }

    $MSBuildArgs += '-p:CodeSign=true'
    $MSBuildArgs += "-p:AzureSignToolPath=$AzureSignToolPath"
    $MSBuildArgs += "-p:NuGetKeyVaultSignTool=$NuGetKeyVaultSignTool"
}

$artifacts = "$PSScriptRoot/artifacts/"

Remove-Item -Recurse $artifacts -ErrorAction Ignore

exec dotnet build --configuration $Configuration '-warnaserror:CS1591' @MSBuildArgs
exec dotnet pack --no-restore --no-build --configuration $Configuration -o $artifacts @MSBuildArgs

[string[]] $testArgs=@()
if ($PSVersionTable.PSEdition -eq 'Core' -and -not $IsWindows) {
    $testArgs += '--framework','netcoreapp2.1'
}

exec dotnet test --no-restore --no-build --configuration $Configuration '-clp:Summary' `
    "$PSScriptRoot/test/CommandLineUtils.Tests/McMaster.Extensions.CommandLineUtils.Tests.csproj" `
    @testArgs `
    @MSBuildArgs

write-host -f magenta 'Done'


##
###################################################################
##


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
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
Param(
    [switch]$Restore,
    [switch]$Build,
    [switch]$Test,
    [Parameter()][ValidateSet('debug', 'release')]
    [string]$Configuration = $env:configuration,
    [switch]$WarnAsError = $true,
    [switch]$GeneratePInvokesTxt,
    [switch]$NoParallelTests
)

if (!$Configuration) { $Configuration = 'debug' }

$NothingToDo = !($Restore -or $Build -or $Test)
if ($NothingToDo) {
    Write-Output "No actions specified. Applying default actions."
    $Restore = $true
    $Build = $true
    $Test = $true
}

# External dependencies
$sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/v3.3.0/nuget.exe"

# Path variables
$ProjectRoot = Split-Path -parent $PSCommandPath
$SolutionFolder = Join-Path $ProjectRoot src
$SolutionFile = Join-Path $SolutionFolder "PInvoke.sln"
$ToolsFolder = Join-Path $ProjectRoot tools
$BinFolder = Join-Path $ProjectRoot "bin"
$BinConfigFolder = Join-Path $BinFolder $Configuration
$BinTestsFolder = Join-Path $BinConfigFolder "tests"
$PackageRestoreRoot = Join-Path $env:userprofile '.nuget/packages/'

# Set script scope for external tool variables.
$MSBuildCommand = Get-Command MSBuild.exe -ErrorAction SilentlyContinue

Function Get-ExternalTools {
    if (!$MSBuildCommand) {
        Write-Error "Unable to find MSBuild.exe. Make sure you're running in a VS Developer Prompt."
        exit 1;
    }
}

Get-ExternalTools

if ($Restore -and $PSCmdlet.ShouldProcess($SolutionFile, "Restore packages")) {
    Write-Output "Restoring NuGet packages..."
    & $MSBuildCommand.Path /t:restore /nologo /m $SolutionFile
}

if ($Build -and $PSCmdlet.ShouldProcess($SolutionFile, "Build")) {
    $buildArgs = @()
    $buildArgs += $SolutionFile,'/nologo','/nr:false','/m','/v:minimal','/t:build,pack'
    $buildArgs += "/p:Configuration=$Configuration"
    $buildArgs += '/fl','/flp:verbosity=normal;logfile=msbuild.log','/flp1:warningsonly;logfile=msbuild.wrn;NoSummary;verbosity=minimal','/flp2:errorsonly;logfile=msbuild.err;NoSummary;verbosity=minimal'
    if ($GeneratePInvokesTxt) {
        $buildArgs += '/p:GeneratePInvokesTxt=true'
    }

    Write-Output "Building..."
    & $MSBuildCommand.Path $buildArgs
    $fail = $false

    $warnings = Get-Content msbuild.wrn
    $errors = Get-Content msbuild.err
    $WarningsPrompt = "$(($warnings | Measure-Object -Line).Lines) warnings during build"
    $ErrorsPrompt = "$(($errors | Measure-Object -Line).Lines) errors during build"
    if ($errors.length -gt 0) {
        Write-Error $ErrorsPrompt
        $fail = $true
    } else {
        Write-Output $ErrorsPrompt
    }

    if ($WarnAsError -and $warnings.length -gt 0) {
        Write-Error $WarningsPrompt
        $fail = $true
    } elseif ($warnings.length -gt 0) {
        Write-Warning $WarningsPrompt
    } else {
        Write-Output $WarningsPrompt
    }

    if ($fail) {
        exit 3;
    }
}

if ($Test -and $PSCmdlet.ShouldProcess('Test assemblies')) {
    $TestAssemblies = Get-ChildItem -Recurse "$BinTestsFolder\*.Tests.dll"
    Write-Output "Testing..."
    $xunitRunner = Join-Path $PackageRestoreRoot 'xunit.runner.console/2.2.0/tools/xunit.console.x86.exe'
    $xunitArgs = @()
    $xunitArgs += $TestAssemblies
    $xunitArgs += "-html","$BinTestsFolder\testresults.html","-xml","$BinTestsFolder\testresults.xml"
    $xunitArgs += "-notrait",'"skiponcloud=true"'
    if (!$NoParallelTests) {
        $xunitArgs += "-parallel","all"
    }

    & $xunitRunner $xunitArgs
}


##
###################################################################
##


[CmdletBinding(PositionalBinding=$false)]
Param(
  [switch] $build,
  [switch] $ci,
  [string] $configuration = "Debug",
  [switch] $help,
  [switch] $nolog,
  [switch] $pack,
  [switch] $prepareMachine,
  [switch] $rebuild,
  [switch] $norestore,
  [switch] $sign,
  [switch] $skiptests,
  [switch] $test,
  [switch] $bootstrapOnly,
  [string] $verbosity = "minimal",
  [string] $hostType,
  [switch] $DotNetBuildFromSource,
  [string] $DotNetCoreSdkDir = "",
  [Parameter(ValueFromRemainingArguments=$true)][String[]]$properties
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

# Opt into TLS 1.2, which is required for https://dot.net
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Print-Usage() {
    Write-Host "Common settings:"
    Write-Host "  -configuration <value>  Build configuration Debug, Release"
    Write-Host "  -verbosity <value>      Msbuild verbosity (q[uiet], m[inimal], n[ormal], d[etailed], and diag[nostic])"
    Write-Host "  -help                   Print help and exit"
    Write-Host ""
    Write-Host "Actions:"
    Write-Host "  -norestore              Don't automatically run restore"
    Write-Host "  -build                  Build solution"
    Write-Host "  -rebuild                Rebuild solution"
    Write-Host "  -skipTests              Don't run tests"
    Write-Host "  -test                   Run tests. Ignores skipTests"
    Write-Host "  -bootstrapOnly          Don't run build again with bootstrapped MSBuild"
    Write-Host "  -sign                   Sign build outputs"
    Write-Host "  -pack                   Package build outputs into NuGet packages and Willow components"
    Write-Host ""
    Write-Host "Advanced settings:"
    Write-Host "  -ci                     Set when running on CI server"
    Write-Host "  -nolog                  Disable logging"
    Write-Host "  -prepareMachine         Prepare machine for CI run"
    Write-Host "  -hostType                   Host / MSBuild flavor to use.  Possible values: full, core"
    Write-Host ""
    Write-Host "Command line arguments not listed above are passed through to MSBuild."
    Write-Host "The above arguments can be shortened as much as to be unambiguous (e.g. -co for configuration, -t for test, etc.)."
}

function Create-Directory([string[]] $Path) {
  if (!(Test-Path -Path $Path)) {
    New-Item -Path $Path -Force -ItemType "Directory" | Out-Null
  }
}

function GetVersionsPropsVersion([string[]] $Name) {
  [xml]$Xml = Get-Content $VersionsProps

  foreach ($PropertyGroup in $Xml.Project.PropertyGroup) {
    if (Get-Member -InputObject $PropertyGroup -name $Name) {
        return $PropertyGroup.$Name
    }
  }

  throw "Failed to locate the $Name property"
}

function InstallDotNetCli {
  $DotNetCliVersion = GetVersionsPropsVersion -Name "DotNetCliVersion"
  $DotNetInstallVerbosity = ""

  if (!$env:DOTNET_INSTALL_DIR) {
    $env:DOTNET_INSTALL_DIR = Join-Path $RepoRoot "artifacts\.dotnet\$DotNetCliVersion\"
  }

  $DotNetRoot = $env:DOTNET_INSTALL_DIR
  $DotNetInstallScript = Join-Path $DotNetRoot "dotnet-install.ps1"

  if (!(Test-Path $DotNetInstallScript)) {
    Create-Directory $DotNetRoot
    Invoke-WebRequest "https://dot.net/v1/dotnet-install.ps1" -UseBasicParsing -OutFile $DotNetInstallScript
  }

  if ($verbosity -eq "diagnostic") {
    $DotNetInstallVerbosity = "-Verbose"
  }

  # Install a stage 0
  $SdkInstallDir = Join-Path $DotNetRoot "sdk\$DotNetCliVersion"

  if (!(Test-Path $SdkInstallDir)) {
    # Use Invoke-Expression so that $DotNetInstallVerbosity is not positionally bound when empty
    Invoke-Expression -Command "& '$DotNetInstallScript' -Version $DotNetCliVersion $DotNetInstallVerbosity"

    if($LASTEXITCODE -ne 0) {
      throw "Failed to install stage0"
    }
  }

  # Put the stage 0 on the path
  $env:PATH = "$DotNetRoot;$env:PATH"

  # Disable first run since we want to control all package sources
  $env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1

  # Don't resolve runtime, shared framework, or SDK from other locations
  $env:DOTNET_MULTILEVEL_LOOKUP=0
}

function InstallNuGet {
  $NugetInstallDir = Join-Path $RepoRoot "artifacts\.nuget"
  $NugetExe = Join-Path $NugetInstallDir "nuget.exe"

  if (!(Test-Path -Path $NugetExe)) {
    Create-Directory $NugetInstallDir
    Invoke-WebRequest "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe" -UseBasicParsing -OutFile $NugetExe
  }
}

function InstallRepoToolset {
  $GlobalJson = Get-Content(Join-Path $RepoRoot "global.json") | ConvertFrom-Json
  $RepoToolsetVersion = $GlobalJson.'msbuild-sdks'.'RoslynTools.RepoToolset'
  $RepoToolsetDir = Join-Path $NuGetPackageRoot "roslyntools.repotoolset\$RepoToolsetVersion\tools"
  $RepoToolsetBuildProj = Join-Path $RepoToolsetDir "Build.proj"
  if ($DotNetBuildFromSource)
  {
    $RepoToolsetDir = Join-Path $env:RESOLVE_REPO_TOOLSET_PACKAGE_DIR "tools"
  }

  if (!(Test-Path -Path $RepoToolsetBuildProj)) {
    $ToolsetProj = Join-Path $PSScriptRoot "Toolset.csproj"
    $msbuildArgs = "/t:build", "/m", "/clp:Summary", "/warnaserror", "/v:$verbosity"
    $msbuildArgs = AddLogCmd "Toolset" $msbuildArgs
    # Piping to Out-Null is important here, as otherwise the MSBuild output will be included in the return value
    # of the function (Powershell handles return values a bit... weirdly)
    CallMSBuild "`"$ToolsetProj`"" @msbuildArgs | Out-Null

    if($LASTEXITCODE -ne 0) {
      throw "Failed to build $ToolsetProj"
    }
  }

  return $RepoToolsetBuildProj
}

function LocateVisualStudio {
  $VSWhereVersion = GetVersionsPropsVersion -Name "VSWhereVersion"
  $VSWhereDir = Join-Path $ArtifactsDir ".tools\vswhere\$VSWhereVersion"
  $VSWhereExe = Join-Path $vsWhereDir "vswhere.exe"

  if (!(Test-Path $VSWhereExe)) {
    Create-Directory $VSWhereDir
    Invoke-WebRequest "http://github.com/Microsoft/vswhere/releases/download/$VSWhereVersion/vswhere.exe" -UseBasicParsing -OutFile $VSWhereExe
  }

  $VSInstallDir = & $VSWhereExe -latest -property installationPath -requires Microsoft.Component.MSBuild -requires Microsoft.VisualStudio.Component.VSSDK -requires Microsoft.Net.Component.4.6.TargetingPack -requires Microsoft.VisualStudio.Component.Roslyn.Compiler -requires Microsoft.VisualStudio.Component.VSSDK

  if (!(Test-Path $VSInstallDir)) {
    throw "Failed to locate Visual Studio (exit code '$LASTEXITCODE')."
  }

  return $VSInstallDir
}

function KillProcessesFromRepo {
  # Jenkins does not allow taskkill
  if (-not $ci) {
    # Kill compiler server and MSBuild node processes from bootstrapped MSBuild (otherwise a second build will fail to copy files in use)
    foreach ($process in Get-Process | Where-Object {'msbuild', 'dotnet', 'vbcscompiler' -contains $_.Name})
    {
      
      if ([string]::IsNullOrEmpty($process.Path))
      {
        Write-Host "Process $($process.Id) $($process.Name) does not have a Path. Skipping killing it."
        continue
      }

      if ($process.Path.StartsWith($RepoRoot, [StringComparison]::InvariantCultureIgnoreCase))
      {
        Write-Host "Killing $($process.Name) from $($process.Path)"
        taskkill /f /pid $process.Id
      }
    }
  }
}

function Build {
  if (![string]::IsNullOrEmpty($DotNetCoreSdkDir) -and (Test-Path -Path $DotNetCoreSdkDir)) {
    $env:DOTNET_INSTALL_DIR = $DotNetCoreSdkDir
  }
  else {
    InstallDotNetCli
  }

  $env:DOTNET_HOST_PATH = Join-Path $env:DOTNET_INSTALL_DIR "dotnet.exe"

  if ($prepareMachine) {
    Create-Directory $NuGetPackageRoot
    & "$env:DOTNET_HOST_PATH" nuget locals all --clear

    if($LASTEXITCODE -ne 0) {
      throw "Failed to clear NuGet cache"
    }
  }

  InstallNuget

  if ($hostType -eq 'full')
  {
    $msbuildHost = $null
  }
  elseif ($hostType -eq 'core')
  {
    $msbuildHost = $env:DOTNET_HOST_PATH
  }
  else
  {
    throw "Unknown hostType parameter: $hostType"
  }

  $RepoToolsetBuildProj = InstallRepoToolset

  echo "Repo toolset used from: $RepoToolsetBuildProj"

  if ($DotNetBuildFromSource)
  {
    $solution = Join-Path $RepoRoot "MSBuild.SourceBuild.sln"
  }
  else
  {
    $solution = Join-Path $RepoRoot "MSBuild.sln"
  }

  $commonMSBuildArgs = "/m", "/clp:Summary", "/v:$verbosity", "/p:Configuration=$configuration", "/p:Projects=`"$solution`"", "/p:CIBuild=$ci", "/p:RepoRoot=`"$RepoRoot`""
  if ($ci)
  {
    # Only enable warnaserror on CI runs.  For local builds, we will generate a warning if we can't run EditBin because
    # the C++ tools aren't installed, and we don't want this to fail the build
    $commonMSBuildArgs = $commonMSBuildArgs + "/warnaserror"
  }

  if ($DotnetBuildFromSource)
  {
    $commonMSBuildArgs = $commonMSBuildArgs + "/p:CreateTlb=false"
  }

  if ($hostType -ne 'full')
  {
    # Make signing a no-op if building not using full Framework MSBuild (as all of the assets that are signed won't be produced)
    $emptySignToolDataPath = [io.path]::combine($RepoRoot, 'build', 'EmptySignToolData.json')
    $commonMSBuildArgs = $commonMSBuildArgs + "/p:SignToolDataPath=`"$emptySignToolDataPath`""
  }

  # Only test using stage 0 MSBuild if -bootstrapOnly is specified
  $testStage0 = $false
  if ($bootstrapOnly)
  {
    $testStage0 = $runTests
  }

  $msbuildArgs = AddLogCmd "Build" $commonMSBuildArgs

  Try
  {
    CallMSBuild `"$RepoToolsetBuildProj`" @msbuildArgs /p:Restore=$restore /p:Build=$build /p:Rebuild=$rebuild /p:Test=$testStage0 /p:Sign=$sign /p:Pack=$pack /p:CreateBootstrap=true @properties

    if (-not $bootstrapOnly)
    {
      $bootstrapRoot = Join-Path $ArtifactsConfigurationDir "bootstrap"

      if ($hostType -eq 'full')
      {
        $msbuildToUse = Join-Path $bootstrapRoot "net46\MSBuild\15.0\Bin\MSBuild.exe"

        if ($configuration -eq "Debug-MONO" -or $configuration -eq "Release-MONO")
        {
          # Copy MSBuild.dll to MSBuild.exe so we can run it without a host
          $sourceDll = Join-Path $bootstrapRoot "net46\MSBuild\15.0\Bin\MSBuild.dll"
          Copy-Item -Path $sourceDll -Destination $msbuildToUse
        }
      }
      else
      {
        $msbuildToUse = Join-Path $bootstrapRoot "netcoreapp2.1\MSBuild\\MSBuild.dll"
      }

      # Use separate artifacts folder for stage 2
      $env:ArtifactsDir = Join-Path $ArtifactsDir "2\"

      $msbuildArgs = AddLogCmd "BuildWithBootstrap" $commonMSBuildArgs

      # When using bootstrapped MSBuild:
      # - Turn off node reuse (so that bootstrapped MSBuild processes don't stay running and lock files)
      # - Don't sign
      # - Don't pack
      # - Do run tests (if not skipped)
      # - Don't try to create a bootstrap deployment
      CallMSBuild `"$RepoToolsetBuildProj`" @msbuildArgs /nr:false /p:Restore=$restore /p:Build=$build /p:Rebuild=$rebuild /p:Test=$runTests /p:Sign=false /p:Pack=false /p:CreateBootstrap=false @properties
    }
  }
  Finally
  {
    if ($ci)
    {
      # Log VSTS errors for build errors
      Get-Content (Join-Path $LogDir "*.err") | ForEach-Object { "##vso[task.logissue type=error] $_" }

      # Log VSTS errors for changed lines
      git --no-pager diff HEAD --unified=0 --no-color --exit-code | ForEach-Object { "##vso[task.logissue type=error] $_" }
      if($LASTEXITCODE -ne 0) {
        throw "[ERROR] After building, there are changed files.  Please build locally and include these changes in your pull request."
      }
    }
  }
}

function CallMSBuild
{
  try 
  {
    Write-Host "=========================="
    Write-Host "$msbuildHost $msbuildToUse $args"
    Write-Host "=========================="

    if ($msbuildHost)
    {
      & $msbuildHost $msbuildToUse $args
    }
    else
    {
      
      & $msbuildToUse $args
    }

    if($LASTEXITCODE -ne 0) {
        throw "Failed to build $args"
    }
  }
  finally
  {
    KillProcessesFromRepo
  }
}

function AddLogCmd([string] $logName, [string[]] $extraArgs)
{

  if ($ci -or $log) {
    Create-Directory $LogDir
    $extraArgs = $extraArgs + ("/bl:`"" + (Join-Path $LogDir "$logName.binlog") + "`"")

    # When running under CI, also create a text error log,
    # so it can be emitted to VSTS.
    if ($ci) {
      $extraArgs = $extraArgs + ("/fileloggerparameters:ErrorsOnly;LogFile=" + '"' + (Join-Path $LogDir "$logName.err") + '"')
    }
  }

  return $extraArgs;
}

function Stop-Processes() {
  Write-Host "Killing running build processes..."
  Get-Process -Name "msbuild" -ErrorAction SilentlyContinue | Stop-Process
  Get-Process -Name "vbcscompiler" -ErrorAction SilentlyContinue | Stop-Process
}

if ($help -or (($properties -ne $null) -and ($properties.Contains("/help") -or $properties.Contains("/?")))) {
  Print-Usage
  exit 0
}

$RepoRoot = Join-Path $PSScriptRoot "..\"
$RepoRoot = [System.IO.Path]::GetFullPath($RepoRoot).TrimEnd($([System.IO.Path]::DirectorySeparatorChar));

$ArtifactsDir = Join-Path $RepoRoot "artifacts"
$ArtifactsConfigurationDir = Join-Path $ArtifactsDir $configuration
$LogDir = Join-Path $ArtifactsConfigurationDir "log"
$VersionsProps = Join-Path $PSScriptRoot "Versions.props"

$log = -not $nolog
$restore = -not $norestore
$runTests = (-not $skiptests) -or $test

if ($hostType -eq '')
{
  $hostType = 'full'
}

# TODO: If host type is full, either make sure we're running in a developer command prompt, or attempt to locate VS, or fail

$msbuildHost = $null
$msbuildToUse = "msbuild"

try {

  KillProcessesFromRepo

  if ($ci) {
    $TempDir = Join-Path $ArtifactsConfigurationDir "tmp"
    Create-Directory $TempDir

    $env:TEMP = $TempDir
    $env:TMP = $TempDir
    $env:MSBUILDDEBUGPATH = $TempDir
  }

  if (!($env:NUGET_PACKAGES)) {
    $env:NUGET_PACKAGES = Join-Path $env:UserProfile ".nuget\packages"
  }

  $NuGetPackageRoot = $env:NUGET_PACKAGES

  Build
  exit $lastExitCode
}
catch {
  Write-Host $_
  Write-Host $_.Exception
  Write-Host $_.ScriptStackTrace
  exit 1
}
finally {
  Pop-Location
  if ($ci -and $prepareMachine) {
    Stop-Processes
  }
}



##
###################################################################
##


https://github.com/AutoMapper/AutoMapper/blob/master/psake.psm1

