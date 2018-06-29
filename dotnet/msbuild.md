# Msbuild

https://msdn.microsoft.com/en-us/library/dd393573.aspx

```xml
<?xml version="1.0" encoding="utf-8"?>  
<Project ToolsVersion="12.0" DefaultTargets="Build"  xmlns="http://schemas.microsoft.com/developer/msbuild/2003">  
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

# building Task

msbuild buildapp.csproj /t:HelloWorld  

# Build Properties

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

# Examining a Property Value

```xml
<Target Name="HelloWorld">  
  <Message Text="Configuration is $(Configuration)" />  
  <Message Text="MSBuildToolsPath is $(MSBuildToolsPath)" />  
</Target>
```

# Conditional Properties

```xml
<Configuration   Condition=" '$(Configuration)' == '' ">Debug</Configuration>  
```

# Settings properties in the cmd line

msbuild buildapp.csproj /t:HelloWorld /p:Configuration=Release  

# Special chars

Certain characters have special meaning in MSBuild project files. Examples of these characters include semicolons (;) and asterisks (*). In order to use these special characters as literals in a project file, they must be specified by using the syntax %xx, where xx represents the ASCII hexadecimal value of the character.

<Message Text="%24(Configuration) is %22$(Configuration)%22" />  

# Build Items

```xml
<ItemGroup>  
    <Compile Include="Program.cs" />  
    <Compile Include="Properties\AssemblyInfo.cs" />  
</ItemGroup>  
```
