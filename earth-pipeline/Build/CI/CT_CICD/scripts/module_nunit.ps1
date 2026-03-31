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

if (-Not($PSBoundParameters.ContainsKey('RootPath')) -or $RootPath -eq "") { $RootPath = Resolve-Path "." }

$CompRegURL = "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/CT-GlobalSW/_apis/git/repositories/CT_CompRegistry/Items?path=$CompRegPath"

$MSINamesListPath = "$PSScriptRoot\..\Config\module_nunit_msi_list.txt"
$MSIListOverridePath = Join-Path $RootPath "\Build\Actions\Test\ModuleMSIList.txt"
$OutTestsPath = Join-Path $RootPath "\Output\OutTests"
$NunitListPath = Join-Path $RootPath "\Build\Actions\Test\NunitList.txt"
$DeployScriptPath = Join-Path $RootPath "\Build\Actions\Test\DeployTestDependencies.bat"
$CleanScriptPath = Join-Path $RootPath "\Build\Actions\Test\ClearTestDependencies.bat"
$GlobalCleanScriptPath = Join-Path $RootPath "\Build\CI\CT_CICD\scripts\GlobalCleanDependencies.ps1"
$WixMSIPath = Join-Path $RootPath "\Build\Pkg\MSI\$ComponentName.msi"
$TempPath = [System.Environment]::GetEnvironmentVariable('Temp', 'User')

$MSIList = [System.Collections.Specialized.OrderedDictionary]@{}

$AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$Auth"))
$TFSHeaders = @{"Authorization" = "Basic $($AuthToken)" }
$RtHeaders = @{"X-JFrog-Art-Api" = "$PAT" }

if (-Not(Test-Path $MSINamesListPath -PathType Leaf)) {
    Write-Error "Error: '$MSINamesListPath' was not found, exiting..." -ErrorAction Stop
}
if (-Not(Test-Path $NunitListPath -PathType Leaf)) {
    Write-Error "Error: '$NunitListPath' was not found, exiting..." -ErrorAction Stop
}
if (-Not(Test-Path $DeployScriptPath -PathType Leaf)) {
    Write-Error "Error: '$DeployScriptPath' was not found, exiting..." -ErrorAction Stop
}
if (-Not(Test-Path $CleanScriptPath -PathType Leaf)) {
    Write-Error "Error: '$CleanScriptPath' was not found, exiting..." -ErrorAction Stop
}

if (-Not(Test-Path $GlobalCleanScriptPath -PathType Leaf)) {
    Write-Error "Error: '$GlobalCleanScriptPath' was not found, exiting..." -ErrorAction Stop
}

$InfNuget = nuget list -Source "$ENV:nupkg_source_path"
$ImplNuget = nuget list -Source "$ENV:nupkg_source_path2"

$InfVersion = "$InfNuget".Split(" ")[1]
$ImplVersion = "$ImplNuget".Split(" ")[1]

Write-Host "Generating MSI with: '$ComponentName' Impl:'$ImplVersion' Inf:'$InfVersion' a:'$ENV:BUILD_ARTIFACTSTAGINGDIRECTORY'"

Set-Location "$RootPath\Build\CI\CT_CICD\WixScript"
Invoke-Expression "$RootPath\Build\CI\CT_CICD\WixScript\Nuget_restore_MSI.ps1 '$ComponentName' '$ImplVersion' '$InfVersion' '$ENV:BUILD_ARTIFACTSTAGINGDIRECTORY'"
Set-Location "$RootPath\Build\CI\CT_CICD\WixScript"
Invoke-Expression "$RootPath\Build\CI\CT_CICD\WixScript\CreateMsi.ps1 '$ComponentName' '$RootPath' '$ImplVersion' '$InfVersion' '$ImplVersion'"

if (-Not(Test-Path $WixMSIPath -PathType Leaf)) {
    Write-Error "Error: '$WixMSIPath' was not found, exiting..." -ErrorAction Stop
}

Write-Host "`nGetting versions from CompRegistry..."
$RawCompReg = Invoke-WebRequest -Uri $CompRegURL -Method Get -Headers $TFSHeaders
$CompRegistryXml = [xml]$RawCompReg
$PackageList = $CompRegistryXml.GetElementsByTagName("PackageReference")

Write-Host "Using MSI list override file"
if($MSIListOverridePath -ne "" -And (Test-Path $MSIListOverridePath -PathType Leaf)) {
    Write-Host "Using MSI list override file: '$MSIListOverridePath'"
    $MSINames = (Get-Content $MSIListOverridePath)
    Write-Host "MSI override list: $($MSINames -join ', ')"
} else {
    $MSINames = (Get-Content $MSINamesListPath)
}
Write-Host "Using MSI list override file - completed"

foreach ($MSIName in $MSINames) {
    foreach ($Package in $PackageList) {
        if ("$($Package.Update)" -match "^$($MSIName)(Impl)?$") {
            $MSIList.Add($MSIName, $Package.Version)
            Write-Host "`nName: '$MSIName' Version: $($Package.Version)"
        }
    }
}

$LastStartedId = $null
$InstallMSI = {
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory = $true, Position = 0)][string]$MSIPath
    )
    $UninstallProcess = Start-Process msiexec.exe -ArgumentList "/x `"$MSIPath`" /quiet" -Wait -PassThru
    $UninstallProcessHandle = $UninstallProcess.Handle # Storing the Process Handle in the Process Object for ExitCode reference
    Write-Host "Cached process handle:" $UninstallProcessHandle -ForegroundColor DarkGray
    $UninstallProcess.WaitForExit()
    # EC:0 Uninstall success. EC:1605 Not already installed.
    if ($UninstallProcess.ExitCode -notin @(0, 1605)) {
        Write-Error "Error: Uninstall of already installed $MSIPath failed with the exit code $($UninstallProcess.ExitCode), exiting..." -ErrorAction Stop
    }
    $InstallProcess = Start-Process msiexec.exe -ArgumentList "/i `"$MSIPath`" /quiet" -Wait -PassThru
    $InstallProcessHandle = $InstallProcess.Handle # Storing the Process Handle in the Process Object for ExitCode reference
    Write-Host "Cached process handle:" $InstallProcessHandle -ForegroundColor Blue
    Write-Host "Installation exit code: " $InstallProcess.ExitCode
    if ($InstallProcess.ExitCode -ne 0) {
        throw "Error: Installation of MSI '$MSIPath' failed with the exit code $($InstallProcess.ExitCode)."
    }
    Write-Host "Installation of MSI '$MSIPath' was successful with the exit code $($InstallProcess.ExitCode)."
    return 0
}

function Resolve-RtMsiPath {
    param ($Name, $Version)
    $BaseURL = "https://artifactory-china.ta.philips.com:443/artifactory/ct-workspace-generic/"
    $AqlURI = "https://artifactory-china.ta.philips.com:443/artifactory/api/search/aql"
    $RtQueryHeaders = @{"X-JFrog-Art-Api" = "$PAT"; "Content-Type" = "text/plain" }
    $RtQuery = @"
items.find(
    {
        "repo":{"`$match":"ct-workspace-generic"},
        "name":{"`$match":"$Name.msi"},
        "path":{"`$match":"*$Name/$Version"}
    }
)
"@
    $AqlResponse = Invoke-RestMethod -Uri $AqlURI -Method Post -Headers $RtQueryHeaders -Body $RtQuery -UseBasicParsing
    if ($AqlResponse.results.length -gt 0) {
        return $BaseURL + "$($AqlResponse.results[0].path)" + "/$Name.msi"
    }
    else {
        throw "Error: Could not find the MSI in artifactory with name '$Name' version: '$Version"
    }
}


Write-Host "Before InstallMSI Execute clean global Path: '$GlobalCleanScriptPath'"
Set-Location "$RootPath\Build\CI\CT_CICD\scripts"
Invoke-Expression "$GlobalCleanScriptPath"

Write-Host "Before InstallMSI Clean CustomPath: '$CleanScriptPath'"
$CleanupResult = Start-Process -FilePath "$CleanScriptPath" -NoNewWindow -PassThru -Wait

Get-Job | Remove-Job

Write-Host "`nDownloading & Installing MSIs from Artifactory..."
$StartTime = (Get-Date)

try {
    $MSIList.Keys | ForEach-Object {
        $Name = $_
        $Version = $MSIList[$Name]
        $DownloadPath = "$TempPath\$Name.$Version.msi"
        $BaseURL = Resolve-RtMsiPath -Name $Name -Version $Version
    
        Write-Host "`nDownloading '$Name' '$Version'" $BaseURL
        Invoke-WebRequest -Method Get -Uri $BaseURL -OutFile $DownloadPath -Headers $RtHeaders
        Write-Host "`nDownloaded '$Name' '$Version'" (Get-Date)
    
        if ($null -ne $LastStartedId) {
            $LastJob = Get-Job -Id $LastStartedId
            while ('Running' -eq $LastJob.State) {
                Write-Host "`nInstallation $($LastJob.Name) is in progress..."
                Start-Sleep 1
            }
            Receive-Job -Id $LastStartedId
            if ('Failed' -eq $LastJob.State) {
                Write-Host "`nFailed to install $($LastJob.Name) MSI, exiting..."
                throw "Process stopped due to MSI installation failure. Please check the logs above."
            }
            elseif ('Completed' -eq $LastJob.State) {
                Write-Host "`nSuccessfully installed $($LastJob.Name) MSI"
            }
        }
        
        $InstallJob = Start-Job -Name "$Name|$Version" -ScriptBlock $InstallMSI -ArgumentList $DownloadPath
        Write-Host "`nStarted installing $($InstallJob.Name) in background..."
        $LastStartedId = $InstallJob.Id
    }
    
    if ($null -ne $LastStartedId) {
        $LastJob = Get-Job -Id $LastStartedId
        while ('Running' -eq $LastJob.State) {
            Write-Host "`nInstallation $($LastJob.Name) is in progress..."
            Start-Sleep 1
        }
        Receive-Job -Id $LastStartedId
        if ('Failed' -eq $LastJob.State) {
            Write-Host "`nFailed to install $($LastJob.Name) MSI, exiting..."
            throw "Process stopped due to MSI installation failure. Please check the logs above."
        }
        elseif ('Completed' -eq $LastJob.State) {
            Write-Host "`nSuccessfully installed $($LastJob.Name) MSI"
        }
    }
}
catch {
    Write-Error $Error[0] -ErrorAction Stop
}

Write-Host "`nExecuting deployment script..."
Write-Host "Path: '$DeployScriptPath'"

$DeployResult = Start-Process -FilePath "$DeployScriptPath" -NoNewWindow -PassThru -Wait
$DeployResultHandle = $DeployResult.Handle # Storing the Process Handle in the Process Object for ExitCode reference
Write-Host "Cached process handle:" $DeployResultHandle -ForegroundColor DarkGray
$DeployResult.WaitForExit()
$DeploymentEC = $DeployResult.ExitCode
Write-Host "Deployment script exit code:" $DeploymentEC
if ($DeploymentEC -ne 0) {
    Write-Error "Process stopped due to Deployment script failure. Please check the logs above." -ErrorAction Stop
}
Write-Host "`nSuccessfully executed the deployment script."

Write-Host "`nInstalling Repo MSI from '$WixMSIPath' ..."
Invoke-Command -ScriptBlock $InstallMSI -ArgumentList $WixMSIPath

Write-Host "`nCopying output tests to target bin folder..."
if (-Not(Test-Path -Path $TargetBinFolder -PathType Container)) {
    Write-Host "Creating the target bin path..."
    New-Item $TargetBinFolder -ItemType Directory -Force | Out-Null
}

Write-Host "`nCopying following files from '$OutTestsPath' to '$TargetBinFolder'...`n"
Copy-Item "$OutTestsPath\*" $TargetBinFolder -Force -Recurse -PassThru | ForEach-Object { Write-Host $_.FullName }
Write-Host "`nSuccessfully copied output tests to target bin folder."
Write-Host "`nContent of target bin folder after copying..."
Get-ChildItem $TargetBinFolder -Recurse -File | ForEach-Object { Write-Host $_.FullName }

Write-Host "Running nunit tests..."
$Result = Invoke-Expression "$RootPath\Build\CI\CT_CICD\scripts\NUnitTesting.ps1 '$RootPath' '$ComponentName' '$Id' '$ToolsVersion' `$RunDotcover '$SharedPath' '$reportPath' '$NunitListPath' '$TargetTestFolder' $dotnetcore"
Write-Host "Nunit result: $Result"
Write-Host "Completed nunit tests."

Write-Host "Cleaning downloaded MSIs..."
$MSIList.Keys | ForEach-Object {
    $Name = $_
    $Version = $MSIList[$Name]
    $DownloadPath = "$TempPath\$Name.$Version.msi"
    $UninstallProcess = Start-Process msiexec.exe -ArgumentList "/x `"$DownloadPath`" /quiet" -Wait -PassThru
    $UninstallProcessHandle = $UninstallProcess.Handle # Storing the Process Handle in the Process Object for ExitCode reference
    Write-Host "Cached process handle:" $UninstallProcessHandle -ForegroundColor DarkGray
    $UninstallProcess.WaitForExit()
    # EC:0 Uninstall success. EC:1605 Not already installed.
    if ($UninstallProcess.ExitCode -notin @(0, 1605)) {
        Write-Error "Error: Uninstall of already installed $DownloadPath failed with the exit code $($UninstallProcess.ExitCode), exiting..." -ErrorAction Stop
    }
    Remove-Item $DownloadPath -Force -ErrorAction Ignore
}

Write-Host "Uninstalling Repo MSI..."
$RepoUninstallProcess = Start-Process msiexec.exe -ArgumentList "/x `"$WixMSIPath`" /quiet" -Wait -PassThru
$RepoUninstallProcessHandle = $RepoUninstallProcess.Handle # Storing the Process Handle in the Process Object for ExitCode reference
Write-Host "Cached process handle:" $RepoUninstallProcessHandle -ForegroundColor DarkGray
$RepoUninstallProcess.WaitForExit()
# EC:0 Uninstall success. EC:1605 Not already installed.
if ($RepoUninstallProcess.ExitCode -notin @(0, 1605)) {
    Write-Error "Error: Uninstall of already installed '$WixMSIPath' failed with the exit code $($RepoUninstallProcess.ExitCode), exiting..." -ErrorAction Stop
}
Write-Host "Uninstalled Repo MSI."

#Write-Host "`nExecuting cleanup script..."

#Write-Host "After InstallMSI Execute clean global Path: '$GlobalCleanScriptPathAfter'"
#Set-Location "$RootPath\Build\CI\CT_CICD\scripts"
#Invoke-Expression "$GlobalCleanScriptPathAfter"

#Write-Host "Path: '$CleanScriptPath'"

#$CleanupResult = Start-Process -FilePath "$CleanScriptPath" -NoNewWindow -PassThru -Wait
#$CleanupResultHandle = $CleanupResult.Handle # Storing the Process Handle in the Process Object for ExitCode reference
#Write-Host "Cached process handle:" $CleanupResultHandle -ForegroundColor DarkGray
#$CleanupResult.WaitForExit()
#$CleanupEC = $CleanupResult.ExitCode
#Write-Host "Cleanup script exit code:" $CleanupEC
#if ($CleanupEC -ne 0) {
#    Write-Error "Process stopped due to Cleanup script failure. Please check the logs above." -ErrorAction Stop
#}
#Write-Host "`nSuccessfully executed the cleanup script."

$EndTime = (Get-Date)
Write-Host "`n`nTotal time taken" (New-TimeSpan -Start $StartTime -End $EndTime)
