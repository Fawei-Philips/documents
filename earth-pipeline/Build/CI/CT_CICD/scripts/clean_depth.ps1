# Author: Vaibhav Garg (320219077)

# The script cleans the items present in the target directory 
# which are older than the specified days. Depth control is used to
# look for subfolders within the parent for older items.

# Usage: clean_depth.ps1 <Target> <Days> [Depth]

# Options:
#  Target: Root path of the target repository.
#  Days: Folders older than specified days to be deleted.
#  Depth: Depth of the directories it should look for items.

# Note: The Depth values 0 and 1 are same and will process the items 
#  directly under the Target path.

# Example: .\clean_depth.ps1 '\\INGBTCPIC6VWA52\ScannerProd\Console' 15 2

param(
    [Parameter(Mandatory = $false, Position = 0)] [string]$Target,
    [Parameter(Mandatory = $false, Position = 1)] [int32]$Days,
    [Parameter(Mandatory = $false, Position = 2)] [int32]$Depth
)

if ($PSBoundParameters.Count -eq 0) {
    Write-Host "The script cleans the items present in the target directory `nwhich are older than the specified days. Depth control is used to`nlook for subfolders within the parent for older items.`nUsage: clean_depth.ps1 <Target> <Days> [Depth]`nOptions:`n Target: Root path of the target repository.`n Days: Folders older than specified days to be deleted.`n Depth: Depth of the directories it should look for items.`nExample: .\clean_depth.ps1 '\\INGBTCPIC6VWA52\ScannerProd\Console' 15 2"
    Write-Host -Object ([System.Console]::ReadKey().Key);
    exit
}

if (-Not ($PSBoundParameters.ContainsKey('Target'))) {
    Write-Error "Please provide the Target directory. Exiting..." -ErrorAction Stop
}

if (-Not ($PSBoundParameters.ContainsKey('Days'))) {
    Write-Error "Please provide the Days param. Exiting..." -ErrorAction Stop
}

if (-Not ($PSBoundParameters.ContainsKey('Depth'))) {
    Write-Warning "Depth is 1 since its value was not assigned."
    $Depth = 1
}

$LimitDate = (Get-Date).AddDays(-1 * $Days).Date

Write-Host "Cleanup started..." -ForegroundColor Cyan
Write-Host "Target: $Target"

$DepthString = "\"
while ($Depth -gt 0) { $DepthString += "*\"; $Depth -= 1; }

$PreObjects = Get-ChildItem -Path "$Target$DepthString" -Force
Write-Host "Total objects in target (Depth: $Depth):" ($PreObjects | Measure-Object).Count

$OldObjects = $PreObjects | Where-Object CreationTime -lt $LimitDate 
Write-Host "Objects older than $Days days (Count: $(($OldObjects | Measure-Object).Count)): "  
$OldObjects | ForEach-Object { Write-Host "`t" $_.FullName }

$OldObjects | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue

$PostObjects = Get-ChildItem -Path "$Target$DepthString" -Force | Where-Object CreationTime -lt $LimitDate

if (($PostObjects | Select-Object -First 1 | Measure-Object).Count -ne 0) {
    Write-Host "Could not delete the listed objects (Count: $(($PostObjects | Measure-Object).Count)): "
    $PostObjects | ForEach-Object { Write-Host "`t" $_.FullName }

    throw "Unable to delete all objects in the target directory."
}

Write-Host "Cleanup completed" -ForegroundColor Cyan