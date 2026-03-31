#Author : Shubham Srivastava(320218605)

# The script is used to install and unpack specific versions of nuget packages of the provided repositories.

# Nuget_restore_MSI.ps1 [RepoName] [version] [folder_path]

# Options: 

# RepoName: (Mandatory) Name of the Repository

# version: (Not Mandatory) Version of the nuget package

# folder_path: (Mandatory) Path where the nuget packages are present

# Example: .\Nuget_restore_MSI.ps1 'CT_CommonServices' '1.0.0' 'D:\CT_CommonServices\Export'

param(
    [Parameter(Mandatory=$true, Position = 0)][string]$RepoName,
    [Parameter(Mandatory = $false, Position = 1)][string]$Version,
    [Parameter(Mandatory = $false, Position = 2)][string]$InfVersion,
    [Parameter(Mandatory = $true, Position = 3)][string]$folder_path
)

Write-Host $RepoName
Write-Host $Version
Write-Host $InfVersion
Write-Host $folder_path

$NuGetConfigPath = "$($Env:APPDATA)\NuGet\NuGet.Config"

$RepoNameInf = $($RepoName)+'Inf'
$RepoNameImpl = $($RepoName)+'Impl'
$RepoNamePostActions = $($RepoName)+'PostActions'


$dirs = @("$folder_path\$RepoNameInf", "$folder_path\$RepoNameImpl", "$folder_path\$RepoNamePostActions")
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

if (-Not($PSBoundParameters.ContainsKey('Version'))){
    Write-Host "Version not provided... Installing latest Package"
    nuget install $RepoNameInf  -OutputDirectory "D:\$($RepoName)_temp"
    nuget install $RepoNameImpl -OutputDirectory "D:\$($RepoName)_temp"
    nuget install $RepoNamePostActions -OutputDirectory "D:\$($RepoName)_temp"
    exit
}



function unzip{

    param([string]$zipPath,[string]$DestinationPath)

    Expand-Archive -Path $zipPath -DestinationPath $DestinationPath -Force

}
 
$version_list_Inf = nuget list -Source "$folder_path\$RepoNameInf"
$check_Inf=$false
foreach($version_Inf in $version_list_Inf){
    $version_num=$version_list_Inf.split(" ")
    if($version_num[1] -eq $InfVersion){
        $check_Inf=$true
    }
}
Set-Location $folder_path\$RepoNameInf
Get-ChildItem *.nupkg | rename-item -newname { [io.path]::ChangeExtension($_.name, "zip") }


$version_list_Impl = nuget list -Source "$folder_path\$RepoNameImpl"
$check_Impl=$false
foreach($version_Impl in $version_list_Impl){
    $version_num=$version_list_Impl.split(" ")
    if($version_num[1] -eq $version){
        $check_Impl=$true
    }
}
Set-Location $folder_path\$RepoNameImpl
Get-ChildItem *.nupkg | rename-item -newname { [io.path]::ChangeExtension($_.name, "zip") }


$version_list_PostActions = nuget list -Source "$folder_path\$RepoNamePostActions"
$check_PostActions=$false
foreach($version_PostActions in $version_list_PostActions){
    $version_num=$version_list_PostActions.split(" ")
    if($version_num[1] -eq $version){
        $check_PostActions=$true
    }
}
Set-Location $folder_path\$RepoNamePostActions
Get-ChildItem *.nupkg | rename-item -newname { [io.path]::ChangeExtension($_.name, "zip") }


if ($check_Inf){
    Set-Location "$folder_path\$RepoNameInf"
    Write-Host "$folder_path\$RepoNameInf"
    Write-Host "Inf Package found Installing..."
    #nuget install $RepoNameInf -Version $version -OutputDirectory "D:\$($RepoName)_temp"
    unzip -zipPath "$folder_path\$($RepoNameInf)\$($RepoName)Inf.$($InfVersion).zip" -DestinationPath "D:\$($RepoName)_temp\$($RepoName)Inf.$($InfVersion)"
}
Set-Location $folder_path\$RepoNameInf
Get-ChildItem *.zip | rename-item -newname { [io.path]::ChangeExtension($_.name, "nupkg") }

if ($check_Impl){
    Set-Location "$folder_path\$RepoNameImpl"
    Write-Host "Impl Package found Installing..."
   # nuget install $RepoNameImpl -Version $version -OutputDirectory "D:\$($RepoName)_temp"
   unzip -zipPath "$folder_path\$($RepoNameImpl)\$($RepoName)Impl.$($Version).zip" -DestinationPath "D:\$($RepoName)_temp\$($RepoName)Impl.$($Version)"
}
Set-Location $folder_path\$RepoNameImpl
Get-ChildItem *.zip | rename-item -newname { [io.path]::ChangeExtension($_.name, "nupkg") }

if ($check_PostActions){
    Set-Location "$folder_path\$RepoNamePostActions"
    Write-Host "PostActions Package found Installing..."
    #nuget install $RepoNamePostActions -Version $version -OutputDirectory "D:\$($RepoName)_temp"
    unzip -zipPath "$folder_path\$($RepoNamePostActions)\$($RepoName)PostActions.$($Version).zip" -DestinationPath "D:\$($RepoName)_temp\$($RepoName)PostActions.$($Version)"
}
Set-Location $folder_path\$RepoNamePostActions
Get-ChildItem *.zip | rename-item -newname { [io.path]::ChangeExtension($_.name, "nupkg") }

if(!($check_Inf -or $check_Impl -or $check_PostActions)){
    Write-Host "Package not found in Mentioned Folder, Checking in Artifactory.. "
    $version_list = nuget list $RepoName -AllVersions -ConfigFile $NuGetConfigPath
    Write-Host "VL: " $version_list
    $check_artfact=$false
    foreach($version_c in $version_list){
        $version_num=$version_list.split(" ")
        if($version_num[1] -eq $version){
            $check_artfact=$true
        }
    }
    if ($check_artfact){
        Write-Host "Package found in Artifactory Installing..."
        nuget install $RepoNameInf -Version $InfVersion -OutputDirectory "D:\$($RepoName)_temp"
        nuget install $RepoNameImpl -Version $version -OutputDirectory "D:\$($RepoName)_temp"
        nuget install $RepoNamePostActions -Version $version -OutputDirectory "D:\$($RepoName)_temp"
    }
    else {
        Write-Host "Mentioned package not found installing latest package."

        nuget install $RepoNameInf  -OutputDirectory "D:\$($RepoName)_temp"
        nuget install $RepoNameImpl -OutputDirectory "D:\$($RepoName)_temp"
        nuget install $RepoNamePostActions -OutputDirectory "D:\$($RepoName)_temp"
        
    }
}