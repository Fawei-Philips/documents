using module .\nupkg_uploader_module.psm1
[cmdletBinding()]
Param(
  [Parameter(Mandatory = $true, HelpMessage = "Base url to upload nupkg")]
  [string]$upload_base_url,
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
  [Parameter(Mandatory = $true, HelpMessage = "Path where nupkg files present")]
  [string] $nupkg_source_path,
  [Parameter(Mandatory = $false, HelpMessage = "Folder name in repo")]
  [string] $component_name
  
)
  #=========================================================================================================
  # Uploading .nupkg to the artifactory
  #=========================================================================================================
  $component_name = Split-Path -Leaf (git remote get-url origin)
  $component_name = $component_name.substring(0,1).toupper()+$component_name.substring(1)
  Write-Host $component_name
  $nupkg_files_list = @()
  $nupkg_files = Get-Content -Path "$PSScriptRoot/nuget_package_info.txt"
  if($nupkg_files.Count -eq 0){
    Write-Host "============== No .nupkg need to upload as all .nupkg are updated on artifactory =============="
  }
  elseif ($nupkg_files.Count -eq 1) {
    Write-Host "These packages is/are not present on artifactory :- "
    Write-Host $nupkg_files
    $nupkg_files_list += $nupkg_files
  }
  else{
    Write-Host "These packages is/are not present on artifactory :- "
    #Write-Host $nupkg_files
    foreach($pkg in $nupkg_files){
      Write-Host $pkg
      $nupkg_files_list += $pkg
    }
  }
  $nupkg_obj = [nupkg_uploader_module]::New($upload_base_url,$artifactory_reponame,$internal_folder_name,$component_name,$state,$user_name,$token,$nupkg_source_path)
  $nupkg_obj.upload_package($nupkg_files_list)
