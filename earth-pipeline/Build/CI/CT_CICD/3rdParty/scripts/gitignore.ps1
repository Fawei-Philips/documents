# Author: Vaibhav Garg (320219077)

# The script checks and updates the gitignore entries

# Usage: gitignore.ps1 [Path] [Component] [Version]

# Options:
#  Path: Root path of the target directory. Defaults to current path. 
#  Component: Name of the component being updated
#  Version: Version of the component being updated
#  PAT: PAT for Artifactory (Format= <username>:<PAT>).

# Example: .\gitignore.ps1 'D:\CT_3rdParty' 'Castle.Core' '4.2.0' 'PAT'

param( 
	[Parameter(Mandatory = $false, Position = 0)][string]$Path,
	[Parameter(Mandatory = $true, Position = 1)][string]$Component,
	[Parameter(Mandatory = $true, Position = 2)][string]$Version,
	[Parameter(Mandatory = $true, Position = 3)][string]$PAT
)

if (-Not($PSBoundParameters.ContainsKey('Path')) -or $Path -eq "") { $Path = Resolve-Path "." }

if (-Not (Test-Path $Path -PathType Container)) {
	Write-Error -Message "Could not find the path ($Path), exiting..." -ErrorAction Stop
}

$Path = $Path.TrimEnd("\")
$InstallersPath = Join-Path $Path "Export\Installers"
$NugetPath = Join-Path $Path "Export\Nuget"
$GitignorePath = Join-Path $Path '.gitignore'
$RTQueryPath = Join-Path $PSScriptRoot "artifactory_query.ps1"

if(-Not(Test-Path $GitignorePath)){ Write-Host "Created empty .gitignore file..."; New-Item $GitignorePath | Out-Null }

$ComponentVersion = "^$Component/Version $Version$"
$Exists = Select-String -Path $GitignorePath $ComponentVersion

if($Exists){
    Write-Host "Specified Component $Component and its version $Version already exists, exiting..." -ForegroundColor Red
    throw
}

$Query = Invoke-Expression "$RTQueryPath `"ct-workspace*`" `"$Component`" `"$Version`" `"CT_3rdParty`" `"$PAT`""
Write-Host "Query" $Query.name.count

if($Query.name.count -gt 0){
	Write-Host "Artifacts for Component $Component and its version $Version already exists in Artifactory, exiting..." -ForegroundColor Red
	throw
}


$Components = Get-ChildItem $Path -Exclude Build,Export -Directory | Get-ChildItem | ForEach-Object {"$($_.Parent)/$($_.BaseName)"}
$NugetComponents = Get-ChildItem $NugetPath -Directory | Get-ChildItem | ForEach-Object {"Export/Nuget/$($_.Parent)/$($_.BaseName)"}
$InstallersComponents = Get-ChildItem $InstallersPath -Directory | Get-ChildItem | ForEach-Object {"Export/Installers/$($_.Parent)/$($_.BaseName)"}

Clear-Content $GitignorePath
$Components | Out-File $GitignorePath
$NugetComponents | Out-File $GitignorePath -Append
$InstallersComponents | Out-File $GitignorePath -Append