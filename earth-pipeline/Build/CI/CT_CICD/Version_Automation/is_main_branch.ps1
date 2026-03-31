param(
    [Parameter(Mandatory = $false, Position = 0)] [string]$Repo,
    [Parameter(Mandatory = $false, Position = 1)] [string]$Branch
)
$branchConfigPath = Join-Path $PSScriptRoot "..\Config\main_branches.xml"
$branchConfig = [xml](Get-Content -Path $branchConfigPath)
$repos = $branchConfig.config.repo
Set-Variable -Name isMain -Value 0 -Scope Global
$repos | ForEach-Object { if ($_.name -eq $Repo) { $_.branches | ForEach-Object { if ($_.branch -eq $Branch) { Set-Variable -Name isMain -Value 1 -Scope Global } } } }
$isMain = (Get-Variable -Name isMain -Scope Global).Value
Write-Host "##vso[task.setvariable variable=isMain;isoutput=true]$isMain"