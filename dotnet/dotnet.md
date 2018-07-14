```
dotnet build
dotnet Oetools.Runner.Cli\bin\Debug\netcoreapp2.0\Oetools.Runner.Cli.dll
dotnet run
dotnet test
```

```
mkdir SolutionWithSrcAndTest
cd SolutionWithSrcAndTest
dotnet new sln
dotnet new classlib -o MyProject
dotnet new xunit -o MyProject.Test
dotnet sln add MyProject/MyProject.csproj
dotnet sln add MyProject.Test/MyProject.Test.csproj
dotnet add reference ../MyProject/MyProject.csproj

dotnet sln todo.sln add **/*.csproj
dotnet sln remove **/*.csproj
```

### install build tools

You can simply install the latest visual studio version (2017 atm).

Or, if you don't want to install everything but just build with `ght-cli/build.bat`, you can install msbuild tools :

https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2017

With the following options :

- MsBuild tools
- .Net Core build tools
- Individual components :
  - (Testing tools core features) optional
  - .Net framework 4.6.1 SKD
  - .Net framework 4.6.1 Targeting pack


### evzervzer

https://github.com/Microsoft/msbuild/wiki/MSBuild-Tips-&-Tricks