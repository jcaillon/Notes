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
Condition="$(TargetFramework.Contains('netstandard')) OR $(TargetFramework.Contains('netcoreapp'))"
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

Reserved Properties
https://msdn.microsoft.com/en-us/library/ms164309.aspx

Reference environment variables :
https://msdn.microsoft.com/en-us/library/ms171459.aspx

well known meta data like %(Fullname) :
https://msdn.microsoft.com/fr-fr/library/ms164313.aspx

http://source.roslyn.io/#MSBuildFiles/C/ProgramFiles(x86)/MicrosoftVisualStudio/2017/Enterprise/MSBuild/15.0/Bin_/Microsoft.Common.CurrentVersion.targets,2043

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

## Item groups

```xml
<ItemGroup>
  <Compile Include="..\Shared\*.cs" Exclude="..\Shared\Not\*.cs" />
  <EmbeddedResource Include="..\Shared\*.resx" />
  <Content Include="Views\**\*" PackagePath="%(Identity)" />
  <None Include="some/path/in/project.txt" Pack="true" PackagePath="in/package.txt" />

  <None Include="notes.txt" CopyToOutputDirectory="Always" />
  <!-- CopyToOutputDirectory = { Always, PreserveNewest, Never } -->

  <Content Include="files\**\*" CopyToPublishDirectory="PreserveNewest" />
  <None Include="publishnotes.txt" CopyToPublishDirectory="Always" />
  <!-- CopyToPublishDirectory = { Always, PreserveNewest, Never } -->

  <!-- you can set both copy output and publish directories-->
  <None Include="testasset.txt" CopyToOutputDirectory="Always" CopyToPublishDirectory="Always" />

  <!-- alternatively, use nested XML attributes. They're functionally the same-->
  <None Include="testasset2.txt">
    <CopyToOutputDirectory>Always</CopyToOutputDirectory>
    <CopyToPublishDirectory>Always</CopyToPublishDirectory>
  </None>

</ItemGroup>
```

## References

```xml
<ItemGroup>
  <PackageReference Include="Microsoft.AspNetCore" Version="1.1.0" />
</ItemGroup>
<ItemGroup Condition="'$(TargetFramework)'=='net451'">
  <PackageReference Include="System.Collections.Immutable" Version="1.3.1" />
</ItemGroup>
<ItemGroup Condition="'$(TargetFramework)'=='netstandard1.5'">
  <PackageReference Include="Newtonsoft.Json" Version="9.0.1" />
</ItemGroup>
<PropertyGroup>
  <PackageTargetFallback>dnxcore50;dotnet</PackageTargetFallback>
</PropertyGroup>
<ItemGroup>
  <PackageReference Include="YamlDotNet" Version="4.0.1-pre309" />
</ItemGroup>
<ItemGroup>
  <ProjectReference Include="..\MyOtherProject\MyOtherProject.csproj" />
  <ProjectReference Include="..\AnotherProject\AnotherProject.csproj" />
</ItemGroup>
<ItemGroup>
  <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="1.1.0" PrivateAssets="All" />
</ItemGroup>
```

## Reference a .dll or fallback to nuget package

```xml
  <!-- prefer to use the latest built dll of the plugin interface, or fallback to the latest package on nuget -->
  <PropertyGroup>
    <ReferenceDllPath>$(ProjectDir)..\..\MailBotPluginInterface\bin\Any CPU\Release\netstandard2.0\MailBotPluginInterface.dll</ReferenceDllPath>
  </PropertyGroup>
  <Choose>
    <When Condition="Exists('$(ReferenceDllPath)')">
      <ItemGroup>
        <Reference Include="$(ReferenceDllPath)" />
      </ItemGroup>
    </When>
    <Otherwise>
      <ItemGroup>
        <PackageReference Include="MailBotPluginInterface" Version="1.*" />
      </ItemGroup>
    </Otherwise>
  </Choose>
```


## Typical project file

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup  Label="Basic info">    
    <!-- Exe or Library-->
    <OutputType>Exe</OutputType>
    <AssemblyName>sakoe</AssemblyName>
    <RootNamespace>Oetools.Runner</RootNamespace>
    <!-- Assembly.GetExecutingAssembly().GetName().Version = $(Version) but completed if necessary to make a 4 digit version and without what is after the dash -->
    <!-- FileVersionInfo.GetVersionInfo(Assembly.GetExecutingAssembly().Location).ProductVersion = $(Version) -->
    <Version>1.0.0-beta</Version>
    <!-- FileVersionInfo.GetVersionInfo(Assembly.GetExecutingAssembly().Location).FileVersion = $(FileVersion) -->
    <FileVersion>$(VersionPrefix)</FileVersion>
    <!-- this will be the product name-->
    <Product>sakoe</Product>
    <!-- this will be the file description -->
    <AssemblyTitle>$(Product) - Swiss Army Knife for OpenEdge</AssemblyTitle>
    <Copyright>Copyright (c) 2018 - Julien Caillon - GNU General Public License v3</Copyright>
    <ApplicationIcon>app.ico</ApplicationIcon>
  </PropertyGroup>

  <PropertyGroup Label="Package info basic">
    <Title>$(AssemblyTitle)</Title>
    <Description>A set of handy tools for openedge developers</Description>
    <Company>Noyacode</Company>
    <Authors>jcailon</Authors>
  </PropertyGroup>

  <PropertyGroup Label="Package info">
    <GeneratePackageOnBuild>false</GeneratePackageOnBuild>
    <PackageId>$(Company).$(AssemblyName)</PackageId>
    <PackageVersion>$(Version)</PackageVersion>
    <PackageRequireLicenseAcceptance>false</PackageRequireLicenseAcceptance>
    <PackageLicenseUrl>https://github.com/jcaillon/Oetools.Runner/blob/master/LICENSE</PackageLicenseUrl>
    <PackageProjectUrl>https://github.com/jcaillon/Oetools.Runner</PackageProjectUrl>
    <RepositoryType>git</RepositoryType>
    <RepositoryUrl>https://github.com/jcaillon/Oetools.Runner.git</RepositoryUrl>
    <PackageIconUrl>https://raw.githubusercontent.com/jcaillon/Oetools.Runner/master/.docs/logo.png</PackageIconUrl>
    <PackageReleaseNotes></PackageReleaseNotes>
    <PackageTags>openedge sakoe progress 4GL abl</PackageTags>
    <PackageOutputPath>$(OutputPath)</PackageOutputPath>
    <!-- allow pdb to be packed with the the nuget package (instead of having a separate pack for debug symbols) -->
    <AllowedOutputExtensionsInPackageBuildOutputFolder>$(AllowedOutputExtensionsInPackageBuildOutputFolder);.pdb</AllowedOutputExtensionsInPackageBuildOutputFolder>   
  </PropertyGroup>

  <PropertyGroup Label="Compilation info">
    <!-- https://docs.microsoft.com/en-us/dotnet/standard/frameworks -->
    <TargetFrameworks>net461;netcoreapp2.0</TargetFrameworks>
    <!-- The operating system you are building for. Valid values are "Any CPU", "x86", and "x64" -->
    <Platform>Any Cpu</Platform>
    <Configuration>Release</Configuration>
    <SolutionDir Condition=" $(SolutionDir) == ''">..\</SolutionDir>
    <DebugSymbols>true</DebugSymbols>
    <Optimize Condition=" '$(Configuration)' == 'Release' ">true</Optimize>
  </PropertyGroup>

  <PropertyGroup Label="Extra stuff">
    <TargetName>$(AssemblyName)</TargetName>
    <!-- fallback language for language resources -->
    <NeutralLanguage>en-GB</NeutralLanguage>
    <!-- Specifies the path of the file that is used to generate external User Account Control (UAC) manifest information -->
    <ApplicationManifest></ApplicationManifest>
    <!-- Path to the strong name key file (.snk) (you need the 3 following props to sign -->
    <AssemblyOriginatorKeyFile></AssemblyOriginatorKeyFile>
    <SignAssembly>true</SignAssembly>
    <PublicSign Condition="'$(OS)' != 'Windows_NT'">true</PublicSign>
    <!-- To use with #if... -->
    <DefineConstants Condition=" '$(TargetFramework)'=='net461' ">$(DefineConstants);NET461;WINDOWSONLYBUILD</DefineConstants>
    <!-- generate an xml file documentation -->
    <GenerateDocumentationFile>false</GenerateDocumentationFile>
    <!-- Specify the class that contains the main method -->
    <StartupObject></StartupObject>
    <!-- stop on compiler warning -->
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <!-- throw an exception on overflow instead of failing quietly -->
    <CheckForOverflowUnderflow>true</CheckForOverflowUnderflow>
    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
    <NoWarn>$(NoWarn);CS0168;CS0219</NoWarn>
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

## Extra targets

```xml
<ItemGroup Label="ProjectReferences">
  <ProjectReference Include="..\Oetools.HtmlExport\Oetools.HtmlExport.csproj" />
  <ProjectReference Include="..\Oetools.Packager\Oetools.Packager\Oetools.Packager.csproj" />
  <ProjectReference Include="..\Oetools.Packager\Oetools.Utilities\Oetools.Utilities\Oetools.Utilities.csproj" />
</ItemGroup>

<ItemGroup Label="PackageReferences">
  <PackageReference Include="McMaster.Extensions.CommandLineUtils" Version="2.2.4" />
</ItemGroup>

<ItemGroup Label="Files to copy">
    <None Include="app.ico" CopyToOutputDirectory="Always" CopyToPublishDirectory="Always" />
</ItemGroup>

<!-- Extra targets -->

<!-- Embed dependencies -->
<Import Project="Target.EmbedDependencies.target" />

<!-- CopyOutput -->
<Import Project="Target.CopyOutput.target" />
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