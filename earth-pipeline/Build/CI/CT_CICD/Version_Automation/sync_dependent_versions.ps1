# Author: Vaibhav Garg 

# This scripts syncs the versions of dependencies in the nuspec files 
# to the versions present in the Component Registry 

# Parameters:
#  Repo: Repo name
#  BaseRepoPath: Full path to the root of the repo
#  CompRegistryPath: Relative path to the Comp registry file

param(
    [Parameter(Mandatory = $true)] [string]$Repo,
    [Parameter(Mandatory = $true)] [string]$BaseRepoPath,
    [Parameter(Mandatory = $false)] [string]$CompRegistryPath = "\CT_CompRegistry\Sample.target"
)

$CompRegistryPath = Join-Path $BaseRepoPath $CompRegistryPath
$NugetPath = "$BaseRepoPath\Build\Pkg\Nuget\"
$NuspecPaths = Get-ChildItem -Path $NugetPath -Filter "*.nuspec"

if (-not(Test-Path -Path $CompRegistryPath -PathType Leaf)) {
    Write-Error "CompRegistry file path was found, exiting..." -ErrorAction Stop
}

$CompRegistryXML = [xml](Get-Content -Path $CompRegistryPath)
$CompRegPackages = $CompRegistryXML.GetElementsByTagName("PackageReference")

$NuspecPaths | ForEach-Object {
    Write-Host $_.FullName
    $NuspecXML = [xml](Get-Content $_.FullName)
    $DependenciesTags = $NuspecXML.GetElementsByTagName('dependency')
    Write-Host $DependenciesTags.Count
    $DependenciesTags | ForEach-Object {
        $PackageName = $_.id
        Write-Host "Found $PackageName with version $($_.version)"
        $RefPackage = $CompRegPackages | Where-Object { $_.Update -eq $PackageName }
        $NewVersion = $RefPackage.version
        $_.version = $NewVersion
        Write-Host "Updated $PackageName to version $NewVersion"
    }
    $NuspecXML.Save($_.FullName)
}