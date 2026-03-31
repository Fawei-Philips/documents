# Author: Vaibhav Garg (320219077)

# The script is used to push the nupkg to Artificatory

# Usage: nuget_push.ps1 <Target>

# Options:
#  Target: Root path of the target 3rd_Party directory.

# Example: .\nuget_push.ps1 'D:\Base'

param(
    [Parameter(Mandatory = $false, Position = 0)] [string]$Target
)

if (-Not($PSBoundParameters.ContainsKey('Target'))) { $Target = "." }

$Name = Split-Path $Target -Leaf
$NugetExePath = "\\ingbtcpic6vw294\Nuget\Nuget.exe"
$NugetSource = "https://artifactory.pic.philips.com:8443/artifactory/api/nuget/v3/ct-workspace/CT_3rdParty"
$NugetFolder = "Export\Nuget\$Name\Version*"
$Filter = "*.nupkg"

$NugetPath = Join-Path $Target $NugetFolder

if (-Not (Test-Path $NugetPath -PathType Container)) {
    Write-Error -Message "Could not find the path ($NugetPath), exiting..." -ErrorAction Stop
}

function NugetPush {
    param ($PackagePath, $Source)
    process {
        $PushCommand = "push `"$PackagePath`" -Source `"$Source`""
        try {
            $PushProcess = Start-Process -FilePath $NugetExePath $PushCommand -NoNewWindow -PassThru
            $Handle = $PushProcess.Handle # Storing the Process Handle in the Process Object for ExitCode reference
            Write-Host "Cached process handle: " $Handle
            $PushProcess.WaitForExit()
            return $PushProcess.ExitCode
        }
        catch {
            Write-Host $Error[0]
            return 1
        }
    }
    
}

Write-Host "Pushing Nuget packages..." -ForegroundColor Cyan
Get-ChildItem -Path $NugetPath | ForEach-Object {
    Write-Host "Processing: $_"
    Get-ChildItem -Path $_ -Filter $Filter -File | ForEach-Object {
        Write-Host "Pushing: $_"
        $IsSuccess = NugetPush -PackagePath $_.FullName -Source $NugetSource
        if ($IsSuccess -eq 0) { Write-Host "Pushed: $_" -ForegroundColor Green }
        else { Write-Error "Could not push: $_" }
    }
}
Write-Host "Pushing Nuget packages completed." -ForegroundColor Cyan

