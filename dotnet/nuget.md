# nuget

## Create the package

```cmd
msbuild /t:pack
```

## Publish it

```cmd
nuget push <pack>.nupkg <APIKEY> -NonInteractive -ForceEnglishOutput -Source https://api.nuget.org/v3/index.json
```

## Properties in the csproj file

```xml
  <PropertyGroup Label="Nuget">
    <GeneratePackageOnBuild>false</GeneratePackageOnBuild>
    <PackageId>$(AssemblyName)Test</PackageId>
    <PackageVersionPrefix>$(VersionPrefix)</PackageVersionPrefix>
    <PackageVersionSuffix>$(VersionSuffix)</PackageVersionSuffix>
    <Title>Nuget package $(AssemblyName)</Title>
    <Description>This package is...</Description>
    <Authors>jcailon,authro2</Authors>
    <Company>your_company</Company>
    <Copyright>Copyright (c) 2018 - Julien Caillon - GNU General Public License v3</Copyright>
    <PackageRequireLicenseAcceptance>false</PackageRequireLicenseAcceptance>
    <PackageLicenseUrl>https://www.gnu.org/licenses/gpl-3.0.txt</PackageLicenseUrl>
    <PackageProjectUrl>https://github.com/jcaillon/uHttpSharp</PackageProjectUrl>
    <RepositoryUrl>https://github.com/jcaillon/uHttpSharp.git</RepositoryUrl>
    <PackageIconUrl></PackageIconUrl>
    <PackageReleaseNotes></PackageReleaseNotes>
    <PackageTags>tag1 tag2 space delimited</PackageTags>
    <PackageOutputPath>$(OutputPath)</PackageOutputPath>
    <IncludeSymbols>false</IncludeSymbols>
    <IncludeSource>false</IncludeSource>
    <!-- The prop below allows to pack the .pdb files along with the .dll -->
    <AllowedOutputExtensionsInPackageBuildOutputFolder>$(AllowedOutputExtensionsInPackageBuildOutputFolder);.pdb</AllowedOutputExtensionsInPackageBuildOutputFolder>
  </PropertyGroup>
```

## Copy a specific file in the nuget package

```xml
  <ItemGroup>
    <Content Include="HttpServer.cs">
      <PackagePath>pathinpack\</PackagePath>
      <Pack>true</Pack>
    </Content>
  </ItemGroup>
```

## Target to push to repo

```xml
<Target Name="PushNugetPackage" AfterTargets="Pack" Condition="'$(Configuration)' == 'Release'">
  <Exec Command="nuget.exe push -Source &quot;mysource&quot; -ApiKey VSTS $(OutputPath)..\$(PackageId).$(PackageVersion).nupkg" />
</Target>
```

## Target to pack with nuget

```xml
 <Target Name="PackNugets"  AfterTargets="AfterBuild">  
  <Exec Command="dotnet pack &quot;$(MSBuildProjectDirectory)\$(PackageId).csproj&quot; --no-build --include-symbols -o bin -c Release"/>
 </Target> 
```

## Target to copy the package elsewhere

```xml
  <Target Name="CopyPackage" AfterTargets="Pack">
    <Copy SourceFiles="$(OutputPath)$(PackageId).$(PackageVersion).nupkg" DestinationFolder="$(SolutionDir)\bin" />
  </Target>
```

```xml
<ItemGroup Condition=" '$(PackageSources)' == '' ">
    <!-- Package sources used to restore packages. By default, registered sources under %APPDATA%\NuGet\NuGet.Config will be used -->
    <!-- The official NuGet package source (https://www.nuget.org/api/v2/) will be excluded if package sources are specified and it does not appear in the list -->
    <!--
        <PackageSource Include="https://www.nuget.org/api/v2/" />
        <PackageSource Include="https://my-nuget-source/nuget/" />
    -->
</ItemGroup>
```