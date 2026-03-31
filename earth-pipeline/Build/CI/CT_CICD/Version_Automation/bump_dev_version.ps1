
#=============================================================================================================
# Get the Dev Build Version update it in Nuspec file and set DEV artifactoy reponame as  variable
#=============================================================================================================

param(
    [Parameter(Mandatory = $true)] [string]$BaseRepoPath,
    [Parameter(Mandatory = $true)] [string]$Repo,
    [Parameter(Mandatory = $false)] [string]$Pub
)

#Get the Build number and set Artifactory reponame
$currentDate = Get-Date -Format "yyyyMMdd"
$revisionNumber = $env:BUILD_BUILDID
$version = $currentDate + "." + $revisionNumber + "." + 0
Write-Host "$version"
$finalVersion = $version
$Artifactory_reponame = "ct-dev-workspace-generic"
$impl = "$BaseRepoPath\Build\Pkg\Nuget\$($Repo)Impl.nuspec"
$inf = "$BaseRepoPath\Build\Pkg\Nuget\$($Repo)Inf.nuspec"
$postActions = "$BaseRepoPath\Build\Pkg\Nuget\$($Repo)PostActions.nuspec"
$test = "$BaseRepoPath\Build\Pkg\Nuget\$($Repo)Test.nuspec"

Write-Host "Publish Set to::$Pub"
if($Pub -eq "True") {
 $Artifactory_reponame = "ct-workspace "
}

Write-Host "Artifactory Repo Name set to:$Artifactory_reponame"

$config = [xml](Get-Content -Path $impl)
$config.package.metadata.version = $finalVersion
$config.Save($impl)

$config = [xml](Get-Content -Path $inf)
$config.package.metadata.version = $finalVersion
$config.Save($inf)

$config = [xml](Get-Content -Path $postActions)
$config.package.metadata.version = $finalVersion
$config.Save($postActions)

$config = [xml](Get-Content -Path $test)
$config.package.metadata.version = $finalVersion
$config.Save($test)
Write-Host "Updated $Repo nuspec to $finalVersion" -ForegroundColor Yellow

Write-Host "##vso[task.setvariable variable=FinalVersion]$finalVersion"
Write-Host "##vso[task.setvariable variable=artifact_reponame]$Artifactory_reponame"