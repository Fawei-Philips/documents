param(
    [Parameter(Mandatory = $false)][string[]]$Paths
)


# WinDirs is the list of directories which are marked as *not* important to be cleaned entirely.
$WinDirs = @()

# NonWinDirs is the list of directories which are marked as important to be cleaned entirely. 
# Hence the script will *not* end gracefully if some items were not deleted successfully.
$NonWinDirs = @()

if(!$PSBoundParameters.ContainsKey("Paths")){
    $WinDirs = [System.Environment]::GetEnvironmentVariable('Temp', 'User'), "$($Env:SystemRoot)\Prefetch\"
}

$PathsArr = $Paths.Split(",")
foreach ($PathsArrItem in $PathsArr) {
    $NonWinDirs += "$PathsArrItem".Trim()
}

function CleanDir($path, $forced) {
    # Clean the contents of the given $path 
    # List the files which were not deleted
    # If some files could not be deleted, with $forced set as true throw exception 

    $path = [string]$path.Trim();

    if (-Not($path -and (Test-Path $path))) {
        Write-Host -NoNewline "Warning: " -ForegroundColor Yellow; Write-Host -NoNewline "Could not find "; Write-Host $($path) -ForegroundColor Blue
        return
    }

    Write-Host -NoNewline "`nCleaning: "; Write-Host $path -ForegroundColor Blue
    
    # Remove the items recursively
    Get-ChildItem $path * -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

    # Check if directory has items left
    if ((Get-ChildItem $path -force | Select-Object -First 1 | Measure-Object).Count -ne 0) {
        # If forced flag is true then throw error, else only log the remaining items

        if (-Not $forced) { Write-Host -NoNewline "`nWarning: " -ForegroundColor Yellow } else { Write-Host -NoNewline "`nError: " -ForegroundColor Red }
        Write-Host -NoNewline "Could not delete the listed item(s) in "; Write-Host $($path) -ForegroundColor Blue
        
        Get-ChildItem -Recurse $path | ForEach-Object { Write-Host "`t" $_.FullName }
        
        if ($forced) {
            throw "Unable to delete all files in the directory with forced flag."
        }
    }
    else {
        Write-Host -NoNewline -ForegroundColor Green "Successfully deleted all items in "; Write-Host $($path) -ForegroundColor Blue
    }
}

Write-Host "Cleanup started..."
if ($NonWinDirs.Count -gt 0) {
    Write-Host "`Begin to stop service..."
    foreach ($Dir in $NonWinDirs) {
        Get-WmiObject -Class Win32_Service |
        Where-Object { $_.PathName -like "*$Dir*" } |
        ForEach-Object {
            Write-Host "Stopping and deleting service: $($_.Name) ($($_.PathName))"
            Stop-Service -Name $_.Name -Force -ErrorAction SilentlyContinue
            sc.exe delete $_.Name
        }
    }
}


if ($WinDirs.Count -gt 0) {
    Write-Host "`nCleaning Windows Directories..."
    foreach ($Dir in $WinDirs) {
        CleanDir -path $Dir 
    }
}

if ($NonWinDirs.Count -gt 0) {
    Write-Host "`nCleaning Non Windows Directories..."
        # Setting -forced True to mark directory as important to be cleaned entirely
        CleanDir -path $Dir -forced true 
}


Write-Host "`nCleanup completed"