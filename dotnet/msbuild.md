# Msbuild

https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild
https://msdn.microsoft.com/en-us/library/dd393574.aspx

```xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="12.0" DefaultTargets="Build"  xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
```

```xml
Condition="'$(TargetFrameworkIdentifier)' == '.NETCoreApp'"
Condition="'$(TargetFrameworkIdentifier)' != '.NETFramework'"
```

## Target and a Task

```xml
<Target Name="BeforeBuild">
</Target>
<Target Name="AfterBuild">
</Target>

<Target Name="HelloWorld">
  <Message Text="Hello"></Message>  <Message Text="World"></Message>
</Target>
```

## building Task

msbuild buildapp.csproj /t:HelloWorld

## Build Properties

```xml
<PropertyGroup>
...
  <ProductVersion>10.0.11107</ProductVersion>
  <SchemaVersion>2.0</SchemaVersion>
  <ProjectGuid>{30E3C9D5-FD86-4691-A331-80EA5BA7E571}</ProjectGuid>
  <OutputType>WinExe</OutputType>
...
</PropertyGroup>
```

Reserved Properties
https://msdn.microsoft.com/en-us/library/ms164309.aspx

Reference environment variables :
https://msdn.microsoft.com/en-us/library/ms171459.aspx

## Examining a Property Value

```xml
<Target Name="HelloWorld">
  <Message Text="Configuration is $(Configuration)" />
  <Message Text="MSBuildToolsPath is $(MSBuildToolsPath)" />
</Target>
```

## Conditional Properties

```xml
<Configuration   Condition=" '$(Configuration)' == '' ">Debug</Configuration>
```

## Conditional construct

```xml
<Choose>
    <When Condition=" '$(Configuration)'=='Debug' ">
        <PropertyGroup>
            <DebugSymbols>true</DebugSymbols>
            <DebugType>full</DebugType>
            <Optimize>false</Optimize>
            <OutputPath>.\bin\Debug\</OutputPath>
            <DefineConstants>DEBUG;TRACE</DefineConstants>
        </PropertyGroup>
        <ItemGroup>
            <Compile Include="UnitTesting\*.cs" />
            <Reference Include="NUnit.dll" />
        </ItemGroup>
    </When>
    <When Condition=" '$(Configuration)'=='retail' ">
        <PropertyGroup>
            <DebugSymbols>false</DebugSymbols>
            <Optimize>true</Optimize>
            <OutputPath>.\bin\Release\</OutputPath>
            <DefineConstants>TRACE</DefineConstants>
        </PropertyGroup>
    </When>
</Choose>
```

## Settings properties in the cmd line

msbuild buildapp.csproj /t:HelloWorld /p:Configuration=Release

## Special chars

Certain characters have special meaning in MSBuild project files. Examples of these characters include semicolons (;) and asterisks (*). In order to use these special characters as literals in a project file, they must be specified by using the syntax %xx, where xx represents the ASCII hexadecimal value of the character.

<Message Text="%24(Configuration) is %22$(Configuration)%22" />

## Build Items

```xml
<ItemGroup>
    <Compile Include="Program.cs" />
    <Compile Include="Properties\AssemblyInfo.cs" />
</ItemGroup>
```

## Zip directory

```xml
  <Target Name="ZipOutputPath" AfterTargets="Build">
      <ZipDirectory
          SourceDirectory="$(OutputPath)"
          Overwrite="true"
          DestinationFile="$(MSBuildProjectDirectory)\output.zip">
      />
  </Target>
```

## Typical project file

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup  Label="Basic info">
    <!-- Exe or Library-->
    <OutputType>Library</OutputType>
    <AssemblyName>uhttpsharp</AssemblyName>
    <RootNamespace>$(AssemblyName)</RootNamespace>
    <TargetName>$(AssemblyName)</TargetName>
    <!-- Assembly.GetExecutingAssembly().GetName().Version = $(Version) but completed if necessary to make a 4 digit version and without what is after the dash -->
    <!-- FileVersionInfo.GetVersionInfo(Assembly.GetExecutingAssembly().Location).ProductVersion = $(Version) -->
    <Version>1.0.0-rc</Version>
    <!-- FileVersionInfo.GetVersionInfo(Assembly.GetExecutingAssembly().Location).FileVersion = $(FileVersion) -->
    <FileVersion>$(VersionPrefix)</FileVersion>
    <!-- this will be the product name-->
    <Product>µHttpSharp</Product>
    <!-- this will be the file description -->
    <AssemblyTitle>$(Product) - a micro http server</AssemblyTitle>
    <Copyright>Copyright (c) 2018</Copyright>
    <!-- The file version will be VersionPrefix and the Product version will be VersionPrefix-VersionSuffix -->
    <ApplicationIcon></ApplicationIcon>
  </PropertyGroup>

  <PropertyGroup Label="Package info basic">
    <Title>$(AssemblyTitle)</Title>
    <Description>A very lightweight &amp; simple embedded http server for c#</Description>
    <Company>Noyacode</Company>
    <Authors>jcailon,shani.elh,Joe White, Hüseyin Uslu</Authors>
  </PropertyGroup>

  <PropertyGroup Label="Package info">
    <GeneratePackageOnBuild>false</GeneratePackageOnBuild>
    <PackageId>$(Company).$(AssemblyName)</PackageId>
    <PackageVersionPrefix>$(VersionPrefix)</PackageVersionPrefix>
    <PackageVersionSuffix>$(VersionSuffix)</PackageVersionSuffix>
    <PackageRequireLicenseAcceptance>false</PackageRequireLicenseAcceptance>
    <PackageLicenseUrl>https://github.com/jcaillon/uHttpSharp/blob/master/LICENSE.txt</PackageLicenseUrl>
    <PackageProjectUrl>https://github.com/jcaillon/uHttpSharp</PackageProjectUrl>
    <RepositoryType>git</RepositoryType>
    <RepositoryUrl>https://github.com/jcaillon/uHttpSharp.git</RepositoryUrl>
    <PackageIconUrl></PackageIconUrl>
    <PackageReleaseNotes>Initial release for dotnet standard</PackageReleaseNotes>
    <PackageTags>http server microframeworks</PackageTags>
    <PackageOutputPath>$(OutputPath)</PackageOutputPath>
    <AllowedOutputExtensionsInPackageBuildOutputFolder>$(AllowedOutputExtensionsInPackageBuildOutputFolder);.pdb</AllowedOutputExtensionsInPackageBuildOutputFolder>
  </PropertyGroup>

  <PropertyGroup Label="Compilation info">
    <!-- https://docs.microsoft.com/en-us/dotnet/standard/frameworks -->
    <TargetFrameworks>net461;netstandard2.0</TargetFrameworks>
    <!-- The operating system you are building for. Valid values are "Any CPU", "x86", and "x64" -->
    <Platform>Any Cpu</Platform>
    <Configuration>Release</Configuration>
    <SolutionDir Condition=" $(SolutionDir) == ''">.\</SolutionDir>
    <DebugSymbols>true</DebugSymbols>
    <Optimize Condition=" '$(Configuration)' == 'Release' ">true</Optimize>
  </PropertyGroup>

  <PropertyGroup Label="Extra stuff">
    <!-- fallback language for language resources -->
    <NeutralLanguage>en-GB</NeutralLanguage>
    <!-- Specifies the path of the file that is used to generate external User Account Control (UAC) manifest information -->
    <ApplicationManifest></ApplicationManifest>
    <!-- Path to the strong name key file (.snk) (you need the 3 following props to sign -->
    <AssemblyOriginatorKeyFile></AssemblyOriginatorKeyFile>
    <SignAssembly>true</SignAssembly>
    <PublicSign Condition="'$(OS)' != 'Windows_NT'">true</PublicSign>
    <!-- To use with #if... -->
    <DefineConstants>DEBUG;MACHIN</DefineConstants>
    <!-- generate an xml file documentation -->
    <GenerateDocumentationFile>false</GenerateDocumentationFile>
    <!-- Specify the class that contains the main method -->
    <StartupObject></StartupObject>
    <!-- stop on compiler warning -->
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <!-- throw an exception on overflow instead of failing quietly -->
    <CheckForOverflowUnderflow>true</CheckForOverflowUnderflow>
    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
  </PropertyGroup>

  <!-- DebugType -->
  <!-- Need to be full if you want .pdb files to work for .net framework <= 4.7.1, otherwise portable is ok -->
  <!-- pdbonly = you get line numbers, full = you can attach the debugger! so use pdbonly for releases, none/embedded/portable -->
  <!-- portable = new .pdb format to use since dotnet and >= 4.7.1, embedded = same as portable excepct the .pdb is inside the .dll -->
  <Choose>
    <When Condition="$(TargetFramework.Contains('netstandard')) OR $(TargetFramework.Contains('netcoreapp'))">
      <PropertyGroup>
        <DebugType>embedded</DebugType>
      </PropertyGroup>
    </When>
    <Otherwise>
      <Choose>
        <When Condition=" '$(Configuration)'=='Debug' ">
          <PropertyGroup>
            <DebugType>full</DebugType>
          </PropertyGroup>
        </When>
        <Otherwise>
          <PropertyGroup>
            <DebugType>pdbonly</DebugType>
          </PropertyGroup>
        </Otherwise>
      </Choose>
    </Otherwise>
  </Choose>
</Project>
```

## app.manifest example

```xml
<?xml version="1.0" encoding="utf-8"?>
<asmv1:assembly manifestVersion="1.0" xmlns="urn:schemas-microsoft-com:asm.v1" xmlns:asmv1="urn:schemas-microsoft-com:asm.v1" xmlns:asmv2="urn:schemas-microsoft-com:asm.v2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <assemblyIdentity version="1.0.0.0" name="MyApplication.app"/>
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v2">
    <security>
      <requestedPrivileges xmlns="urn:schemas-microsoft-com:asm.v3">
        <!-- UAC Manifest Options
            If you want to change the Windows User Account Control level replace the
            requestedExecutionLevel node with one of the following.

        <requestedExecutionLevel  level="asInvoker" uiAccess="false" />
        <requestedExecutionLevel  level="requireAdministrator" uiAccess="false" />
        <requestedExecutionLevel  level="highestAvailable" uiAccess="false" />

            Specifying requestedExecutionLevel node will disable file and registry virtualization.
            If you want to utilize File and Registry Virtualization for backward
            compatibility then delete the requestedExecutionLevel node.
        -->
        <requestedExecutionLevel level="highestAvailable" uiAccess="false" />
      </requestedPrivileges>
    </security>
  </trustInfo>

  <compatibility xmlns="urn:schemas-microsoft-com:compatibility.v1">
    <application>
      <!-- A list of all Windows versions that this application is designed to work with.
      Windows will automatically select the most compatible environment.-->

      <!-- If your application is designed to work with Windows Vista, uncomment the following supportedOS node-->
      <!--<supportedOS Id="{e2011457-1546-43c5-a5fe-008deee3d3f0}"></supportedOS>-->

      <!-- If your application is designed to work with Windows 7, uncomment the following supportedOS node-->
      <!--<supportedOS Id="{35138b9a-5d96-4fbd-8e2d-a2440225f93a}"/>-->

      <!-- If your application is designed to work with Windows 8, uncomment the following supportedOS node-->
      <!--<supportedOS Id="{4a2f28e3-53b9-4441-ba9c-d69d4a4a6e38}"></supportedOS>-->

      <!-- If your application is designed to work with Windows 8.1, uncomment the following supportedOS node-->
      <!--<supportedOS Id="{1f676c76-80e1-4239-95bb-83d0f6d0da78}"/>-->

    </application>
  </compatibility>

  <!-- Enable themes for Windows common controls and dialogs (Windows XP and later) -->
  <!-- <dependency>
    <dependentAssembly>
      <assemblyIdentity
          type="win32"
          name="Microsoft.Windows.Common-Controls"
          version="6.0.0.0"
          processorArchitecture="*"
          publicKeyToken="6595b64144ccf1df"
          language="*"
        />
    </dependentAssembly>
  </dependency>-->

</asmv1:assembly>
```