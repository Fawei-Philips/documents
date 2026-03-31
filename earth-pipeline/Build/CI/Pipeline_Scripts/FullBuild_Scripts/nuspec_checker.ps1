using module .\nuspec_checker_module.psm1
[cmdletBinding()]
Param(
  [Parameter(Mandatory = $true, HelpMessage = "Articatory url upto storage")]
  [string] $validate_artifactory_base_url,
  [Parameter(Mandatory = $true, HelpMessage = "Artifactory repo name")]
  [string] $artifactory_reponame,
  [Parameter(Mandatory = $true, HelpMessage = "Component name")]
  [string] $internal_folder_name,
  [Parameter(Mandatory = $true, HelpMessage = "State")]
  [string] $state,
  [Parameter(Mandatory = $true, HelpMessage = "User name")]
  [string] $user_name,
  [Parameter(Mandatory = $true, HelpMessage = "Pat token")]
  [string] $token,
  [Parameter(Mandatory = $true, HelpMessage = "Path where nuspec files present")]
  [string] $nuspec_source_path,
  [Parameter(Mandatory = $false, HelpMessage = "Folder name in repo")]
  [string] $component_name  
)
#=============================================================================================================
# Get all .nuspec files from given folder then get id and version from that file.
# Then checking any .nupkg available on artifactory with extracted version and id.
#=============================================================================================================
  $component_name = Split-Path -Leaf (git remote get-url origin) 
  $component_name = $component_name.substring(0,1).toupper()+$component_name.substring(1)
  Write-Host $component_name
  $modify_obj = [nuspec_checker_module]::New($validate_artifactory_base_url,$artifactory_reponame,$internal_folder_name,$component_name,$state,$user_name,$token,$nuspec_source_path)
  $absent_nupkg = $modify_obj.get_missing_nupkg_from_artifactory()
  foreach ($pkg in $absent_nupkg) {
    Write-Host $pkg
  }
  $absent_nupkg | Out-File "$PSScriptRoot/nuget_package_info.txt"
  if ($absent_nupkg.Count -ne 0) {
    Write-Host "##vso[task.setvariable variable=var.createnugetpackage;]true" 
  }else {
    Write-Host "##vso[task.setvariable variable=var.createnugetpackage;]false"
}