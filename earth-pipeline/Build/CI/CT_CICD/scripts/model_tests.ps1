param(
    [Parameter(Mandatory = $false, Position = 1)][string]$RootPath,
    [Parameter(Mandatory = $false, Position = 2)][string]$ComponentName,
    [Parameter(Mandatory = $false, Position = 3)][string]$Id,
    [Parameter(Mandatory = $false, Position = 4)][string]$CompRegPath = "/Sample.target",
    [Parameter(Mandatory = $false, Position = 5)][Alias('Bin')][string]$TargetBinFolder = "D:\PCC\ChorusHost\Bin",
    [Parameter(Mandatory = $false, Position = 6)][string]$ToolsVersion,
    [Parameter(Mandatory = $false, Position = 7)][string]$Auth,
    [Parameter(Mandatory = $false, Position = 8)][string]$PAT,
    [Parameter(Mandatory = $false, Position = 9)][string]$TargetTestFolder = "",
    [Parameter(Mandatory = $false, Position = 10)][bool]$RunDotcover,
    [Parameter(Mandatory = $false, Position = 11)][string]$SharedPath,
    [Parameter(Mandatory = $false, Position = 12)][string]$reportPath,
    [Parameter(Mandatory = $false, Position = 13)][string]$dotnetcore
)
$TestActionsPath = Join-Path $RootPath "\Build\Actions\Test"
$ModelListName = "ModuleModelList.txt"
$ModelScriptName = "ModuleModelSetup.ps1"
$ModelListPath = Join-Path $TestActionsPath $ModelListName
$ModelScriptPath = Join-Path $TestActionsPath $ModelScriptName
$LogPath = "$($env:Build_ArtifactStagingDirectory)\model-test-output.log"
$ModuleNunitPath = Join-Path $PSScriptRoot "module_nunit.ps1"
$SystemJsonPath = Join-Path $PSScriptRoot "..\Config\systemType.json"

# try to remove log file if it exists
if (Test-Path $LogPath) {
    Remove-Item $LogPath -Force -ErrorAction Continue
    Write-Host "Removed existing log file: $LogPath"
}

function Invoke-Tests {
    param(
        [string]$ShowOutput = $false
    )
    try {
        Stop-Transcript
    }
    catch {
        Write-Host "Error stopping transcript: $($_.Exception.Message)"
    }
    Start-Transcript -Path $LogPath -Append
    try {
        if ($RunDotcover -eq $true) {
            Write-Host "Running tests with dotcover..."
            if ($ShowOutput -eq $true) {
                & $ModuleNunitPath "$RootPath" "$ComponentName" $Id "$CompRegPath" "$TargetBinFolder" $ToolsVersion $Auth $PAT "$TargetTestFolder" $True "$SharedPath" "$reportPath" "$dotnetcore"
            }
            else {
                & $ModuleNunitPath "$RootPath" "$ComponentName" $Id "$CompRegPath" "$TargetBinFolder" $ToolsVersion $Auth $PAT "$TargetTestFolder" $True "$SharedPath" "$reportPath" "$dotnetcore" *>&1 | Out-Null
            }
        }
        else {
            Write-Host "Running tests without dotcover..."
            if ($ShowOutput -eq $true) {
                & $ModuleNunitPath "$RootPath" "$ComponentName" $Id "$CompRegPath" "$TargetBinFolder" $ToolsVersion $Auth $PAT "$TargetTestFolder" $False "$SharedPath" "$reportPath" -dotnetcore "$dotnetcore"
            }
            else {
                & $ModuleNunitPath "$RootPath" "$ComponentName" $Id "$CompRegPath" "$TargetBinFolder" $ToolsVersion $Auth $PAT "$TargetTestFolder" $False "$SharedPath" "$reportPath" -dotnetcore "$dotnetcore" *>&1 | Out-Null
            }
        }
    }
    catch {
        Write-Host "Error: $($Error[0])"
        Write-Error "Failed to execute tests for model '$ModelConfig'." -ErrorAction Stop
    }
    finally {
        Stop-Transcript
    }
}

if (Test-Path $ModelListPath) {
    Write-Host "Found $ModelListName file in the specified path."
    if (Test-Path $ModelScriptPath) {
        $ModelList = Get-Content $ModelListPath
        $ModelList = $ModelList | Where-Object { $_ -notmatch '^\s*#' } # Remove comments
        $ModelList = $ModelList | Where-Object { $_ -notmatch '^\s*$' } # Remove empty lines
        $ModelList | ForEach-Object {
            $ModelConfig = $_.Trim()
            if ("$ModelConfig".Length -gt 0) {
                $StartTime = (Get-Date)
                Write-Host "`n=============== Setting up '$ModelConfig' for module testing"
                Write-Host "Executing $ModelScriptName for model: '$ModelConfig'"
                try {
                    & $ModelScriptPath -Model $ModelConfig -SystemJson $SystemJsonPath
                    Write-Host "$ModelScriptName executed successfully for model '$ModelConfig'."
                }
                catch {
                    Write-Host $Error[0]
                    Write-Error "Execution of $ModelScriptName for model '$ModelConfig' failed." -ErrorAction Stop
                }
                Write-Host "Executing tests for '$ModelConfig'..."
                Invoke-Tests -ShowOutput $false
                Write-Host "=============== Tests executed successfully for model '$ModelConfig'."
                $EndTime = (Get-Date)
                $Duration = $EndTime - $StartTime
                Write-Host "Duration for model '$ModelConfig': $($Duration.Hours) hours, $($Duration.Minutes) minutes, $($Duration.Seconds) seconds"
            }
        }
    }
    else {
        throw "Error: $ModelScriptName file does not exist in the specified path."
    }
}
else {
    Write-Host "=============== Executing tests..."
    Invoke-Tests -ShowOutput $true
    Write-Host "Tests executed successfully."
}

if ($env:BUILD_BUILDURI -and $env:BUILD_BUILDID) {
    $ArtifactLink = "$($env:BUILD_BUILDURI)_build/results?buildId=$($env:BUILD_BUILDID)&view=artifacts"
    Write-Host "Please find test logs here: $ArtifactLink"
}
else {
    Write-Host "Build artifact link could not be generated. Ensure this script is running in a pipeline environment."
}