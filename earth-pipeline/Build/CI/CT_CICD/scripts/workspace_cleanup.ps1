<#
.SYNOPSIS
    Cleans specified directories and optionally cleans the D:\ drive except for excluded folders.

.DESCRIPTION
    This script deletes contents of directories passed via the -Paths parameter and,
    if enabled, cleans up the D:\ drive while preserving a set of excluded folders.
    It skips deleting .git directories and common ignored files like .gitignore or Thumbs.db.
    Excluded folders for D:\ cleanup can be provided via a file `excluded_folders.txt`
    placed in the same directory as this script. If not found, default folders are excluded.

.PARAMETER Paths
    (Optional) One or more directory paths (non-Windows) to clean.
    These paths are scanned recursively for subfolders named 's', and their contents are deleted.

.PARAMETER CleanDDrive
    (Optional) If true, triggers cleanup of D:\ drive except excluded folders.
    Excluded folder list can be customized in 'excluded_folders.txt'.

.NOTES
    Author: Karthik Shetty
    Date  : May 2025
    Version: 1.0

.EXAMPLE
    .\clean_up.ps1 -Paths "D:\DEV\Project1", "D:\Logs"

    Cleans all 's' subfolders under D:\DEV\Project1 and D:\Logs.

.EXAMPLE
    .\clean_up.ps1 -Paths "D:\DEV\ML-D151\WS" -CleanDDrive $true

    Cleans the specified path and also cleans D:\ drive except excluded folders.

.LINK
    Internal Documentation or Repo URL if applicable
#>

param(
    [Parameter(Mandatory = $false)][string[]]$Paths,
    [Parameter(Mandatory = $false)][bool]$CleanDDrive = $false
)

$WinDirs = @()
$NonWinDirs = @()

# If Paths not provided, skip non-Windows cleanup silently
if ($Paths) {
    $PathsArr = $Paths -join "," -split ","
    foreach ($PathsArrItem in $PathsArr) {
        $NonWinDirs += "$($PathsArrItem.Trim())"
    }
}

function CleanDir($path, $forced) {
    $path = [string]$path.Trim()

    if (-Not($path -and (Test-Path $path))) {
        Write-Host -NoNewline "Warning: " -ForegroundColor Yellow
        Write-Host -NoNewline "Could not find "
        Write-Host $path -ForegroundColor Blue
        return
    }

    Write-Host -NoNewline "`nCleaning: "
    Write-Host $path -ForegroundColor Blue

    $itemsToDelete = Get-ChildItem -Force $path | Where-Object { $_.Name -ne '.git' }

    foreach ($item in $itemsToDelete) {
        try {
            if ($item.PSIsContainer) {
                Remove-Item $item.FullName -Recurse -Force -ErrorAction Stop
            } else {
                Remove-Item $item.FullName -Force -ErrorAction Stop
            }
        } catch {
            Write-Host -NoNewline "Warning: " -ForegroundColor Yellow
            Write-Host "Could not delete: $($item.FullName)"
        }
    }

    $remaining = Get-ChildItem -Force $path | Where-Object { $_.Name -ne '.git' }
    $ignoredItems = @('.gitignore', '.gitattributes', 'Thumbs.db')
    $actualRemaining = $remaining | Where-Object { $ignoredItems -notcontains $_.Name }

    if ($actualRemaining.Count -ne 0) {
        if (-Not $forced) {
            Write-Host -NoNewline "`nWarning: " -ForegroundColor Yellow
        } else {
            Write-Host -NoNewline "`nError: " -ForegroundColor Red
        }

        Write-Host -NoNewline "Could not delete the listed item(s) in "
        Write-Host $path -ForegroundColor Blue
        $actualRemaining | ForEach-Object { Write-Host "`t" $_.FullName }

        if ($forced) {
            Write-Host -ForegroundColor Yellow "Warning: Cleanup incomplete but continuing execution as 'forced' is enabled."
        }
    } else {
        Write-Host -NoNewline -ForegroundColor Green "Successfully deleted all items (except .git) in "
        Write-Host $path -ForegroundColor Blue
    }
}

function CleanDDriveFunc() {
    Write-Host "`nCleaning D:\ except specific folders..."

    $excludedFoldersFile = Join-Path -Path $PSScriptRoot -ChildPath "excluded_folders.txt"
    if (Test-Path $excludedFoldersFile) {
        Write-Host -ForegroundColor Green "Note: File '$excludedFoldersFile' found. deleating the folders from the file."
        $excludedFolders = Get-Content $excludedFoldersFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    } else {
        Write-Host -ForegroundColor Yellow "Warning: File '$excludedFoldersFile' not found. Using default excluded folders."
        $excludedFolders = @("system", "Softwares", "Shared", "PCC", "Logs", "DEV", "Database", "Config")
    }

    $basePath = "D:\"

    $folders = Get-ChildItem -Path $basePath -Directory | Where-Object {
        $folderName = $_.Name
        -not ($excludedFolders -contains $folderName) -and -not ($folderName.StartsWith("CT_"))
    }

    foreach ($folder in $folders) {
        try {
            Write-Host -NoNewline "Deleting folder: "
            Write-Host $folder.FullName -ForegroundColor Cyan
            Remove-Item -Recurse -Force -Path $folder.FullName -ErrorAction Stop
        } catch {
            Write-Host -NoNewline "Warning: " -ForegroundColor Yellow
            Write-Host "Failed to delete $($folder.FullName): $_"
        }
    }

    Write-Host "`nD:\ cleanup completed."
}


Write-Host "Cleanup started..."

if ($WinDirs.Count -gt 0) {
    Write-Host "`nCleaning Windows Directories..."
    foreach ($Dir in $WinDirs) {
        CleanDir -path $Dir
    }
}

if ($NonWinDirs.Count -gt 0) {
    Write-Host "`nCleaning Non Windows Directories..."
    foreach ($Dir in $NonWinDirs) {
        CleanDir -path $Dir -forced $true
    }
} else {
    Write-Host "`nNo Paths provided for Non-Windows cleanup. Skipping..."
}

if ($CleanDDrive) {
    CleanDDriveFunc
}

Write-Host "`nCleanup completed"
