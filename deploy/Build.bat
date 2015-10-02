REM MSBuild EXE path
SET MSBuildPath="C:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe"
SET NuGetPath="C:\Program Files (x86)\NuGet\nuget.exe"
set StagingPath=deploy\staging

REM change to the source root directory
pushd ..


REM ======================= clean =======================================

REM ensure any previously created package is deleted
del *.nupkg

REM ensure staging folder is empty
mkdir %StagingPath%
rmdir /s /q %StagingPath%
rmdir /s /q %StagingPath%

REM ======================= build =======================================

REM Build out staging NuGet folder structure
mkdir %StagingPath%
mkdir %StagingPath%\build\uap10.0
mkdir %StagingPath%\lib\uap10.0
mkdir %StagingPath%\include
mkdir %StagingPath%\runtimes\win10-arm\lib\uap10.0
mkdir %StagingPath%\runtimes\win10-x64\lib\uap10.0
mkdir %StagingPath%\runtimes\win10-x86\lib\uap10.0

REM Stage platform-independent files
copy deploy\nuget\curve25519-uwp.targets %StagingPath%\build\uap10.0
copy curve25519\Curve25519_Internal.h %StagingPath%\include
copy curve25519\Curve25519Native.h %StagingPath%\include

REM build x86
%MSBuildPath% curve25519\curve25519.vcxproj /property:Configuration=Release /property:Platform=x86
REM stage x86
copy curve25519\Release\curve25519\curve25519.dll %StagingPath%\runtimes\win10-x86\lib\uap10.0
copy curve25519\Release\curve25519\curve25519.winmd %StagingPath%\runtimes\win10-x86\lib\uap10.0
copy curve25519\Release\curve25519\curve25519.pri %StagingPath%\runtimes\win10-x86\lib\uap10.0

REM copy winmd and dll to lib folder to serve as architecture-independent "ref assembly"
copy curve25519\Release\curve25519\curve25519.winmd %StagingPath%\lib\uap10.0

REM build x64
%MSBuildPath% curve25519\curve25519.vcxproj /property:Configuration=Release /property:Platform=x64
REM stage x64
copy curve25519\x64\Release\curve25519\curve25519.dll %StagingPath%\runtimes\win10-x64\lib\uap10.0
copy curve25519\x64\Release\curve25519\curve25519.winmd %StagingPath%\runtimes\win10-x64\lib\uap10.0
copy curve25519\x64\Release\curve25519\curve25519.pri %StagingPath%\runtimes\win10-x64\lib\uap10.0

REM build ARM
%MSBuildPath% curve25519\curve25519.vcxproj /property:Configuration=Release /property:Platform=ARM
REM stage ARM
copy curve25519\ARM\Release\curve25519\curve25519.dll %StagingPath%\runtimes\win10-arm\lib\uap10.0
copy curve25519\ARM\Release\curve25519\curve25519.winmd %StagingPath%\runtimes\win10-arm\lib\uap10.0
copy curve25519\ARM\Release\curve25519\curve25519.pri %StagingPath%\runtimes\win10-arm\lib\uap10.0

REM create NuGet package
REM (Note: Expect 6 Assembly outside lib folder warnings, due to WinRT custom packaging technique)
pushd deploy\staging
%NuGetPath% pack ..\nuget\curve25519-uwp.nuspec -outputdirectory ..
popd


REM ============================ done ==================================


REM go back to the build dir
popd
