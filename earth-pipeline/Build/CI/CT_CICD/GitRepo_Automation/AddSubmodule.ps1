# This script is used to add a submodule reference to a git repository

# Input Parameters:
#     1) Source directory of the cloned repository
#     2) Branch name
#     3) Submodule BranchName

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $sourceDir,
    [Parameter(Mandatory = $true)]
    [string]
    $branch,
    [Parameter(Mandatory = $true)]
    [string]
    $submoduleBranch,
    [Parameter(Mandatory = $true)]
    [string]
    $submoduleRepo
)

# Local Variables
#$submoduleRepo = "CT_CompRegistry"
$baseDir = "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/CT-GlobalSW/_git/"
$submoduleRepoPath = "$($baseDir)$($submoduleRepo)"

Write-Host "Switching to path: $($sourceDir)..." -ForegroundColor Blue
Set-Location $sourceDir

if (git rev-parse --quiet --verify $branch) {
    Write-Host "Checking out to branch: $($branch)..." -ForegroundColor Blue
    git checkout $branch
}
else {
    Write-Host "Creating and switching to branch: $($branch)"
    git checkout -b $branch
}

# Checking if the submodule reference is already added
$submodulesList = git config --file .gitmodules --name-only --get-regexp path
$containsSubmodule = $false
foreach ($submodule in $submodulesList) {
    if ($submodule -eq "submodule.$($submoduleRepo).path") {
        $containsSubmodule = $true
        break
    }
}

if ($containsSubmodule) {
    Write-Host "Submodule already exists! Updating it..." -ForegroundColor Blue
    git submodule update --remote
}
else {
    Write-Host "Adding submodule reference for: $($submoduleRepo) ..." -ForegroundColor Blue
    git submodule add -b $submoduleBranch $submoduleRepoPath
    
    Write-Host "Initializing and updating the submodule..." -ForegroundColor Blue
    git submodule update --init --recursive
}

Write-Host "Committing the changes..." -ForegroundColor Blue
git commit -m "Added $($submoduleRepo) as a submodule reference."

Write-Host "Pushing the commits to origin..." -ForegroundColor Blue
git push --set-upstream origin $branch