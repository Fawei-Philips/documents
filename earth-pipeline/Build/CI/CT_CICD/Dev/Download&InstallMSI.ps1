#Author: Sanjana V (320218599)

#The script downloads a particular version of the MSIs mentioned in the config file. If any of the MSIs are previously
#installed it is deleted and the downloaded MSIs are then installed according to the sequence mentioned in the config file.

#Usage: Download&InstallMSI.ps1 [version]

#Options:
# PAT: PAT for Artifactory (Format= <username>:<PAT>)
# version: (Mandatory) version of the MSI to be downloaded.
# BaseRepoPath: (Mandatory) The base Repository path


# Example: .\Download&InstallMSI.ps1 'pat' '1.0.0' 'D:\Repos'

param(
    [Parameter(Mandatory = $true, Position = 0)] [string]$PAT,
    [Parameter(Mandatory = $true, Position = 1)] [string]$version,
    [Parameter(Mandatory = $true, Position = 2)] [string]$BaseRepoPath

)

$BaseUrl="https://artifactory.pic.philips.com:8443/artifactory/ct-workspace-generic/"
$AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($PAT))
$Headers = @{"Authorization" = "Basic $($AuthToken)" }
$installationSequenceConfig="$BaseRepoPath\CT_CICD\Dev\MSIInstallationSequence.config"
$tempFolder="C:\temp_MSI"

if(Test-Path -Path $tempFolder){
    Remove-Item $tempFolder -Recurse
    Write-Host "temp_MSI folder exists...deleting it and creating a new one."  -ForegroundColor Yellow
}
New-Item -Path $tempFolder -ItemType Directory | Out-Null

#get the sequence of the installation from the config file
$xml = [xml](Get-Content $installationSequenceConfig)
$InstallSequence = $xml.SelectNodes("//MsiName")[0].InnerText.Trim() -split '\s+'

#Download MSI of particular version into C:\temp_MSI 
foreach($file in $InstallSequence){
    Write-Host "Downloading $($file).msi"
    Invoke-WebRequest -Uri "$BaseUrl/$($file)/$($version)/$($file).msi" -OutFile "$tempFolder\$($file).msi" -Headers $Headers
}

#uninstall any previously installed msi
foreach ($msiName in $InstallSequence) {
        Write-Host "Uninstalling $msiName ..."
        Start-Process msiexec.exe -ArgumentList "/x `"$msiName`" /quiet" -Wait
}

#install the downloaded msi
foreach ($msiName in $InstallSequence) {
    $msiPath = "$($tempFolder)\$msiName.msi"
    if (Test-Path $msiPath) {
        Write-Host "Installing $msiName ..."
        Start-Process msiexec.exe -ArgumentList "/i `"$msiPath`" /quiet" -Wait
    } else {
        Write-Warning "MSI $msiName not found at path $msiPath"
    }
}








