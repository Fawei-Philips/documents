@echo off
setlocal

:: Define the first and second folder where files will be deleted
set "folder1=D:\PCC\ChorusHost\Bin"
set "folder2=D:\Config"

:: Check if the first folder exists, then delete all files and subfolders in it
if exist "%folder1%" (
    echo Deleting all files and subfolders in "%folder1%"...
    del /f /q "%folder1%\*" 2>nul
    for /d %%p in ("%folder1%\*") do rd /s /q "%%p"
) else (
    echo The folder "%folder1%" does not exist.
)

:: Check if the second folder exists, then delete all files and subfolders in it
if exist "%folder2%" (
    echo Deleting all files and subfolders in "%folder2%"...
    del /f /q "%folder2%\*" 2>nul
    for /d %%p in ("%folder2%\*") do rd /s /q "%%p"
) else (
    echo The folder "%folder2%" does not exist.
)

echo All files and subfolders have been deleted (if the folders existed).