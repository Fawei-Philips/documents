param(
    [Parameter(Mandatory = $false, Position = 1)][string]$RootPath,
    [Parameter(Mandatory = $false, Position = 2)][string]$ComponentName,
    [Parameter(Mandatory = $false, Position = 3)][Alias('Bin')][string]$TargetBinFolder = "D:\PCC\ChorusHost\Bin"
)

if (-Not($PSBoundParameters.ContainsKey('RootPath')) -or $RootPath -eq "") { $RootPath = Resolve-Path "." }

$MSINamesListPath = "$PSScriptRoot\..\Config\module_nunit_msi_list.txt"
$CleanScriptPath = Join-Path $RootPath "Build\Actions\Test\ClearTestDependencies.bat"
$GlobalCleanScriptPath = Join-Path $RootPath "\Build\CI\CT_CICD\scripts\GlobalCleanDependencies.ps1"
$MSIListOverridePath = Join-Path $RootPath "\Build\Actions\Test\ModuleMSIList.txt"

if (-Not(Test-Path $MSINamesListPath -PathType Leaf)) {
    Write-Error "Error: '$MSINamesListPath' was not found, exiting..." -ErrorAction Stop
}

if (-Not(Test-Path $CleanScriptPath -PathType Leaf)) {
    Write-Error "Error: '$CleanScriptPath' was not found, exiting..." -ErrorAction Stop
}

if (-Not(Test-Path $GlobalCleanScriptPath -PathType Leaf)) {
    Write-Error "Error: '$GlobalCleanScriptPath' was not found, exiting..." -ErrorAction Stop
}

$Installer = New-Object -ComObject WindowsInstaller.Installer
$Products = $Installer.ProductsEx("", "", 7);
$UninstallIds = @{}
$InstalledProductsGUIDs = @{}

$global:EC = $null

function Uninstall-GUID {
    param ($GUID)
    $UninstallProcess = Start-Process msiexec.exe -ArgumentList "/x `"$GUID`" /quiet" -Wait -PassThru
    $UninstallProcessHandle = $UninstallProcess.Handle # Storing the Process Handle in the Process Object for ExitCode reference
    Write-Host "Cached process handle:" $UninstallProcessHandle -ForegroundColor DarkGray
    $UninstallProcess.WaitForExit()
    return $UninstallProcess.ExitCode
}

Write-Host "`nGetting installed products..."
foreach ($product in $Products) {
    $productName = $product.InstallProperty("ProductName")
    $productCode = $product.ProductCode()
    if (-Not ($InstalledProductsGUIDs.ContainsKey($productName))) {
        $InstalledProductsGUIDs.Add($productName, $productCode)
    }
}

# Reading msi cleanup list
if ($MSIListOverridePath -ne "" -And (Test-Path $MSIListOverridePath -PathType Leaf)) {
    Write-Host "Using MSI list override file: '$MSIListOverridePath'"
    $MSINames = (Get-Content $MSIListOverridePath)
    Write-Host "MSI override list: $($MSINames -join ', ')"
}
else {
    $MSINames = (Get-Content $MSINamesListPath)
}
# Adding repo msi name to cleanup list
$MSINames += , $ComponentName

Write-Host "`nGetting products needed to be uninstalled..."
foreach ($MSIName in $MSINames) {
    if ($InstalledProductsGUIDs.ContainsKey($MSIName)) {
        $productCode = $InstalledProductsGUIDs[$MSIName]
        if (-Not ($UninstallIds.ContainsKey($MSIName))) {
            $UninstallIds.Add($MSIName, $productCode)
        }
        Write-Host "Registered for uninstall = Name: $MSIName" "Code: $productCode"
    }
}
Write-Host "Done"

Write-Host "`nUninstalling MSIs..."
foreach ($UninstallName in $UninstallIds.Keys) {
    $Name = $UninstallName
    $GUID = $UninstallIds[$UninstallName]
    $Attempts = 0

    if($Name -eq "LoggingFramework"){
        continue
    }

    do {
        $Attempts++
        
        Write-Host "Uninstalling: $Name ID: $GUID"
        $ExitCode = Uninstall-GUID -GUID $GUID
        Write-Host "ExitCode:" $ExitCode
        Set-Variable -Name EC -Value $ExitCode -Scope Global
        if ($Attempts -eq 1) {
            Write-Host "Warning: Seems like module tests were cancelled in between the run. As this is not recommended, please report this link to the DI Team."
            Write-Host "Info: Trying to cleanup the machine..."
        }
        
        # EC:1618 Previous Uninstall is in progress
        if ($EC -eq 1618) {
            Write-Host "Info: Exit code: $EC. Some install/uninstall is in progress. Waiting 10 seconds... (Attempt: $Attempts)"
            Start-Sleep -Seconds 10
        }
    } while (
        ($Attempts -lt 3) -and ($EC -eq 1618)
    )

    # EC:0 Uninstall success. EC:1605 Not already installed.
    if ($EC -notin @(0, 1605)) {
        Write-Error "Error: Uninstall of $Name $GUID failed with the exit code $EC, exiting..." -ErrorAction Stop
    }
    Write-Host "Successfully uninstalled $Name with $GUID"
}
Write-Host "Done"

# Cleaning up target bin directory
Write-Host "`nCleaning target bin directory '$TargetBinFolder' silently..."
Get-ChildItem $TargetBinFolder * -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "Done"

Write-Host "`nExecuting cleanup script..."

Write-Host "After InstallMSI Execute clean global Path: '$GlobalCleanScriptPath'"
Set-Location "$RootPath\Build\CI\CT_CICD\scripts"
Invoke-Expression "$GlobalCleanScriptPath"

Write-Host "Path: '$CleanScriptPath'"
$CleanupResult = Start-Process -FilePath "$CleanScriptPath" -NoNewWindow -PassThru -Wait
$CleanupResultHandle = $CleanupResult.Handle # Storing the Process Handle in the Process Object for ExitCode reference
Write-Host "Cached process handle:" $CleanupResultHandle -ForegroundColor DarkGray
$CleanupResult.WaitForExit()
$CleanupEC = $CleanupResult.ExitCode
Write-Host "Cleanup script exit code:" $CleanupEC
if ($CleanupEC -ne 0) {
    Write-Error "Process stopped due to Cleanup script failure. Please check the logs above." -ErrorAction Stop
}
Write-Host "Successfully executed the cleanup script."
