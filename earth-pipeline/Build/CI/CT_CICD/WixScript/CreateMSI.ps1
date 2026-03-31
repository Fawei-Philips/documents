[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RepoName,
    [Parameter(Mandatory = $true)][string]$BaseDir,
    [Parameter(Mandatory = $true)][string]$nugetVersion,
    [Parameter(Mandatory = $true)][string]$InfVersion,
    [Parameter(Mandatory = $true)][string]$msiVersion
)

$ScriptPath = [System.IO.DirectoryInfo]$PSCommandPath
$WixCreateMsiPath = Resolve-Path (Join-Path $ScriptPath.Parent.FullName ".\WixCreateMsi.ps1")
$CustomWixCreateMsiPath = Resolve-Path (Join-Path $ScriptPath.Parent.FullName ".\CustomWixCreateMsi.ps1")
$WixCreateMsiGenericPath = Resolve-Path (Join-Path $ScriptPath.Parent.FullName ".\WixCreateMSIGeneric.ps1")

$CustomWixPath = "$BaseDir\Build\Pkg\MSI\Product.wxs"
$IsCustomWixPresent = (Test-Path -Path $CustomWixPath -PathType Leaf)

if ($IsCustomWixPresent) {
    Write-Host "Custom Wix file found, using that to generate the MSI."
    Invoke-Expression "&`"$CustomWixCreateMsiPath`" '$RepoName' '$msiVersion' '$BaseDir' '$CustomWixPath'"
    return
}

$MSIConfigPath = "$BaseDir\Build\Pkg\MSI\MSI.config"
$BinPath = "$BaseDir\Output\OutImpl"
$MSIPath = "$BaseDir\Build\Pkg\MSI\"

$IsMSIConfigPresent = (Test-Path -Path $MSIConfigPath -PathType Leaf)

if ($IsMSIConfigPresent) {
    Write-Host "Targeted repo has an MSI config, using that to generate the MSI."
    $TargetPaths = ((Get-Content $MSIConfigPath) | ForEach-Object { $_.ToString().Trim() }) -join ","
    if ($TargetPaths.Length -eq 0) {
        Write-Error "MSI Config ('$MSIConfigPath') is an empty file, exiting..." -ErrorAction Stop
    }
    Write-Host "Target path(s) mentioned: '$TargetPaths'"
    # Invoke generic msi creation script
    Invoke-Expression "&`"$WixCreateMsiGenericPath`" '$RepoName' '$msiVersion' '$BinPath' '$MSIPath' '$TargetPaths'"
}
else {
    Write-Host "Targeted repo has no MSI config, using generic config to generate the MSI."
    # Invoke repo msi creation script
    Invoke-Expression "&`"$WixCreateMsiPath`" '$RepoName' '$BaseDir' '$nugetVersion' '$InfVersion' '$msiVersion'"
}