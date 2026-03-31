@echo off

Set RootDir=%~dp0
Echo(%RootDir%
Set TestDataPath=%rootdir%..\..\..\Src\TestData

robocopy %TestDataPath%\Config D:\Config /s

echo "Config Deployement Completed"

robocopy %TestDataPath%\PCC D:\PCC /s

echo "PCC Deployement Completed"

Pause