# Aurhor : Sadhana Pandey

param(
    [string] $directory,
    [string] $oldString,
    [string] $newString
)
# Rename files
Get-ChildItem -Path $directory -Recurse -File| Where-Object { $_.Name -match $oldString } | ForEach-Object {
    $newName = $_.Name -replace $oldString, $newString
    Rename-Item -Path $_.FullName -NewName $newName -Force
    Write-Host "Renamed file: $($_.FullName) to $newName"
}

# Rename directories
Get-ChildItem -Path $rootDirectory -Directory -Recurse | Where-Object { $_.Name -match $oldString } | ForEach-Object {
    $newName = $_.Name -replace $oldString, $newString
    Rename-Item -Path $_.FullName -NewName $newName -Force
    Write-Host "Renamed directory: $($_.FullName) to $newName"
}

