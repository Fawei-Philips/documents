# Author: Vaibhav Garg (320219077)

# The script is used to push the nuget packages and installers to Artificatory

# Usage: push.ps1 [Target] <Component> <Version> <PAT>

# Options:
#  Target: Root path of the target 3rd_Party directory.
#  Component: Name of component to be processed.
#  Version: Version of component to be processed.
#  PAT: PAT for Artifactory (Format= <username>:<PAT>).

# Example: .\push.ps1 'D:\CT_3rdParty' 'Castle.Core' '4.2.0' 'username:pat'

param(
    [Parameter(Mandatory = $false, Position = 0)] [string]$Target,
    [Parameter(Mandatory = $true, Position = 1)][string]$Component,
    [Parameter(Mandatory = $true, Position = 2)][string]$Version,
    [Parameter(Mandatory = $false, Position = 3)] [string]$PAT
)

if (-Not($PSBoundParameters.ContainsKey('Target'))) { $Target = Resolve-Path "." }
$Name = Split-Path $Target -Leaf

$BaseURL = "https://artifactory-china.ta.philips.com/artifactory/"
$AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($PAT))

# Test Cerdentials
Write-Host "Authenticating artifactory..."
try {
    $Client = New-Object System.Net.WebClient
    $Client.Headers.add("Authorization", "Basic " + $AuthToken)
    $Client.DownloadString("$($BaseURL)api/repositories") | Out-Null
    Write-Host "Authenticated." -ForegroundColor Green
}
catch {
    Write-Host $Error[0]
    Write-Error "Could not authenticate artifactory. Please check the username & password. Example- <Username>:<PAT>" -ErrorAction Stop
}

Write-Host "Pushing Nuget packages..." -ForegroundColor Cyan
try {
    $Name = [string]$Component.trim()
    Write-Host "Pushing $Name..."
    $Pushables = @(
        @{
            "Path" = Join-Path $Target "Export\Nuget\$Name\Version $Version\*"
            "URI"  = "$($BaseURL)ct-workspace/CT_3rdParty/"
        },
        @{
            "Path" = Join-Path $Target "Export\Installers\$Name\Version $Version\*"
            "URI"  = "$($BaseURL)ct-workspace-generic/CT_3rdParty/$Name/$Version/"
        },
        @{
            "Path" = Join-Path $Target "Export\Installers\$Name\Version $Version\*"
            "URI"  = "$($BaseURL)ct-workspace-generic/CT_3rdParty/$Name/latest/"
        }
    )

    # Perform Upload
    foreach ($Pushable in $Pushables) {
        Get-ChildItem -Path $Pushable["Path"] -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "Processing: $_"
            Get-ChildItem -Path $_ -File | ForEach-Object {
                try {
                    $FileURI = "$($Pushable["URI"])$($_.Name);nuget.version=$Version"
                    Write-Host "Push URI: " $FileURI
                    $URI = New-Object System.Uri($FileURI)
                    $Client = New-Object System.Net.WebClient
                    $Client.Headers.add("Authorization", "Basic " + $AuthToken)
                    $Client.Headers.add("Content-Type", "application/octet-stream")
                    $Client.UploadFile($URI, "PUT", $_.FullName) | Out-Null
                    $Client.Dispose()
                    Write-Host "Pushed: $($_.FullName)" -ForegroundColor Green
                }
                catch {
                    Write-Host $Error[0]
                    Write-Error "Could not push: $_" -ErrorAction Continue
                }
            }
        }
    }
}
catch {
    Write-Host $Error[0]
    Write-Error "Pushing was unsuccessful."
    return 1
}

Write-Host "Pushing Nuget packages completed." -ForegroundColor Cyan
return 0
