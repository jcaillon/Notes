# nuget

## Create the package

```cmd
msbuild /t:pack
nuget pack
dotnet pack
```

## Publish it

```cmd
nuget push <pack>.nupkg <APIKEY> -NonInteractive -ForceEnglishOutput -Source https://api.nuget.org/v3/index.json
```

## Properties in the csproj file

```xml
<PropertyGroup Label="Package info basic">
  <Title>$(AssemblyTitle)</Title>
  <Description>A very lightweight &amp; simple embedded http server for c#</Description>
  <Company>Noyacode</Company>
  <Authors>jcailon,shani.elh,Joe White, Hüseyin Uslu</Authors>
</PropertyGroup>

<PropertyGroup Label="Package info">
  <GeneratePackageOnBuild>false</GeneratePackageOnBuild>
  <PackageId>$(Company).$(AssemblyName)</PackageId>
  <PackageVersion>$(Version)</PackageVersion>
  <PackageRequireLicenseAcceptance>false</PackageRequireLicenseAcceptance>
  <PackageLicenseUrl>https://github.com/jcaillon/uHttpSharp/blob/master/LICENSE.txt</PackageLicenseUrl>
  <PackageProjectUrl>https://github.com/jcaillon/uHttpSharp</PackageProjectUrl>
  <RepositoryType>git</RepositoryType>
  <RepositoryUrl>https://github.com/jcaillon/uHttpSharp.git</RepositoryUrl>
  <PackageIconUrl>https://raw.githubusercontent.com/jcaillon/uHttpSharp/master/.docs/project_logo.png</PackageIconUrl>
  <PackageReleaseNotes>Initial release for dotnet standard</PackageReleaseNotes>
  <PackageTags>http server microframeworks</PackageTags>
  <PackageOutputPath>$(OutputPath)</PackageOutputPath>
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