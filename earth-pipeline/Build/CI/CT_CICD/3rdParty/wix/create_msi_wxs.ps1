# Author: Vaibhav Garg (320219077)

param( 
    [Parameter(Mandatory = $false, Position = 0)][string]$Component,
    [Parameter(Mandatory = $false, Position = 1)][string]$Version,
    [Parameter(Mandatory = $false, Position = 2)][string]$RootPath,
    [Parameter(Mandatory = $false, Position = 3)][string]$ProductTemplate
)

$ProductTemplate = $ProductTemplate.Trim()
$ProgramFiles = [System.Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
$WixDir = Get-ChildItem -Path "$ProgramFiles\Wix Toolset**\bin\" -Directory

if ($null -eq $WixDir) {
    Write-Error -Message "Could not find the Wix Toolset under $ProgramFiles, exiting..." -ErrorAction Stop
}

if (-Not (Test-Path $RootPath -PathType Container)) {
    Write-Error -Message "Could not find the path ($RootPath), exiting..." -ErrorAction Stop
}

if ("$ProductTemplate" -eq "use-default") {
    $GlobalBuildWxsPath = [System.IO.DirectoryInfo]"$Component/Build/$Component.wxs"
    if (-Not (Test-Path $GlobalBuildWxsPath -PathType Leaf)) {
        Write-Error "Wxs path was set to use-default, but could not find '$GlobalBuildWxsPath' path, exiting..." -ErrorAction Stop
    }
    Write-Host "Using default Wxs from: '$GlobalBuildWxsPath'" 
    $ProductTemplate = $GlobalBuildWxsPath.FullName
}

if (-Not (Test-Path $ProductTemplate -PathType Leaf)) {
    Write-Error -Message "Could not find the template wxs file, exiting..." -ErrorAction Stop
}

Write-Host "Using Wix Toolset from $WixDir"
$candle = Join-Path $WixDir "candle.exe"
$light = Join-Path $WixDir "light.exe"

$TempOut = Join-Path $PSScriptRoot "obj"

function ExecuteSyncProcess {
    [CmdletBinding()]
    param ([string]$ExecPath, [string]$Params)
    process {
        $Process = Start-Process -FilePath "$ExecPath" "$Params" -PassThru -NoNewWindow
        $ProcessHandle = $Process.Handle # Storing the Process Handle in the Process Object for ExitCode reference
        Write-Host "Cached process handle: " $ProcessHandle -ForegroundColor DarkGray
        $Process.WaitForExit()
        return $Process.ExitCode
    }
}

function GenerateWxsObj {
    [CmdletBinding()]
    param ($Component, $Version)
    return (ExecuteSyncProcess $candle "$ProductTemplate -out `"$TempOut\$Component.$Version.wixobj`" -dComponentName=`"$Component`" -dProductVersion=`"$Version`" -dSourceRoot=`"$RootPath`" -nologo") -eq 0
}
function GenerateMSI {
    [CmdletBinding()]
    param ($Component, $Version, $MSIOutFolder)
    return (ExecuteSyncProcess $light "-b `"$TempOut\$Component`" `"$TempOut\$Component.$Version.wixobj`" -out `"$MSIOutFolder\$Component.msi`" -spdb -sw1076 -nologo") -eq 0
}

try {
    Write-Host "Packaging '$Component' '$Version' ..."

    $InstallersPath = Join-Path $RootPath "Export\Installers\$Component\Version $Version"
    if (Test-Path $InstallersPath -PathType Container) {
        Remove-Item "$InstallersPath\*" -Force -Recurse
    }

    Write-Host "Generating wix objects..."
    $WxsObjSuccess = GenerateWxsObj $Component $Version
    if (!$WxsObjSuccess) {
        throw "Could not generate the WXS Object files for $Component"
    }

    Write-Host "Generating msi installer..."
    $MSISuccess = GenerateMSI $Component $Version $InstallersPath
    if (!$MSISuccess) {
        throw "Could not generate the MSI Installer for $Component"
    }

    Write-Host "Successfully created the MSI for $Component $Version"
}
catch {
    Write-Host $Error[0]
    Write-Error "Failed to create the MSIs! Please check the error logs above." -ErrorAction Stop
}
finally {
    Remove-Item $TempOut -Recurse
    Write-Host "Cleaned temp objects"
}