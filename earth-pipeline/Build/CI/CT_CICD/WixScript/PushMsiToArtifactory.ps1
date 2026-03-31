#Author : Shubham Srivastava(320218605)

# The script pushes the MSIs to Artifactory

# Usage: PushMsiToArtifactory.ps1 [Target] [PAT] [RepoName]

# Options: 
#   Target: Root path of the target directory.
#   PAT: PAT for Artifactory (Format= <username>:<PAT>)
#   RepoName: Name of the repository

# Example: .\PushMsiToArtifactory.ps1 'https://artifactory-china.ta.philips.com/artifactory/' 'D:\CT_CommonServices' 'username:pat' 'CT_CommonServices'

param(
    [Parameter(Mandatory = $true)] [string]$ArtifactoryURL,
    [Parameter(Mandatory = $true)] [string]$Target,
    [Parameter(Mandatory = $true)] [string]$PAT,
    [Parameter(Mandatory = $true)] [string]$RepoName,
    [Parameter(Mandatory = $true)] [string]$nugetVersion,
    [Parameter(Mandatory = $false)] [string]$checkdev
)

if ($checkdev -eq 1 -or $checkdev -eq 2) {
    $Artifact_repo = "ct-dev-workspace-generic"
    Write-Host "Artifactory repo $Artifact_repo..."
}
else {
    $Artifact_repo = "ct-workspace-generic"  
    Write-Host "Artifactory repo $Artifact_repo..."
} 

$BaseURL = $ArtifactoryURL + "/"
$AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($PAT))
$Headers = @{"Authorization" = "Basic $($AuthToken)" }

$Pushable = @{
    "Path" = Join-Path $Target "\Build\Pkg\MSI\$($RepoName).msi"
    "URI"  = "$($BaseURL)$($Artifact_repo)/$($RepoName)/$($nugetVersion)/"
}

Write-Host "Target:" $Target
Write-Host "Path:" $Pushable["Path"]
Write-Host "URI:" $Pushable["URI"]

if ($checkdev -eq 2) {
    $Pushable["URI"] = $Pushable["URI"] + "debug/"
}
Write-Host "Pushing to URI: " $Pushable["URI"]

$CREDS = $PAT.Split(':')
$Usr = $CREDS[0]
$Pswd = $CREDS[1]

# Test Cerdentials
Write-Host "Authenticating artifactory..."
try {
    Invoke-RestMethod -Method Head -Uri "$($BaseURL)api/repositories" -Headers $Headers
    Write-Host "Authenticated." -ForegroundColor Green
}
catch {
    Write-Host $Error[0]
    Write-Error "Could not authenticate artifactory. Please check the username & password. Example- <Username>:<PAT>" -ErrorAction Stop
}

# Perform Upload
Write-Host "Pushing MSI to Artifactory..." -ForegroundColor Cyan

Get-ChildItem -Path $Pushable["Path"] | ForEach-Object {
    Write-Host "Processing: $_"
    Get-ChildItem -Path $_ -File | ForEach-Object {
        Write-Host "Pushing: $_"
        try {
            $File_URI = "$($Pushable["URI"])$($_.Name);nuget.version=$nugetVersion"
            $WebClient = New-Object System.Net.WebClient  
            $WebClient.Credentials = New-Object System.Net.NetworkCredential("$Usr", "$Pswd")  
            $URI = New-Object System.Uri($File_URI)
            $METHOD = "PUT" 
            $WebClient.Headers.Add("Authorization", "Basic " + $($AuthToken))
            $WebClient.Headers.add("Content-Type", "application/octet-stream")
            $loca = $Pushable["Path"]
            Write-Host "Location: $loca"
            $WebClient.UploadFile($URI, $METHOD, $loca) 
            $WebClient.Dispose()
            Write-Host "Pushed: $_" -ForegroundColor Green
        }
        catch {
            Write-Host $Error[0]
            Write-Host "Could not push: $_" -ForegroundColor Red
        }
    }
}

Write-Host "Pushing MSI completed." -ForegroundColor Cyan