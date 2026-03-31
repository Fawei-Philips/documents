@echo off

REM Copying files to recovery folder
Powershell.exe -ExecutionPolicy Bypass -File "%~dp0Install_RecoveryFilesServiceability.ps1"
Powershell.exe -ExecutionPolicy Bypass -File "%~dp0CreateServiceToolLnkInDesktop.ps1"
REM - Post Build Script

echo "Moving DataAnalysisTool to PCC Folder"

REM Define the source and destination directories
set source="D:\PCC\ChorusHost\Bin\DataAnalysisTool"
set destination="D:\PCC\DataAnalysisTool"

REM Copy the source directory to the destination directory
xcopy %source% %destination% /E /I /H /C /K /Y

REM Check if the copy was successful
if errorlevel 1 (
    echo Error: Failed to copy files.
    pause
    exit /B 1
)

REM Remove the source directory after successful copy
rd /S /Q %source%

