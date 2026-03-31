# Author: Vaibhav Garg (320219077)

param( 
    [Parameter(Mandatory = $false, Position = 0)][string]$Component,
    [Parameter(Mandatory = $false, Position = 1)][string]$Version,
    [Parameter(Mandatory = $false, Position = 2)][string]$BinPath,
    [Parameter(Mandatory = $false, Position = 3)][string]$MSIPath,
    # [Parameter(Mandatory = $false, Position = 4)][string]"TODO"$WxsPath,
    [Parameter(Mandatory = $false, Position = 4)][string]$TargetPaths
)

$ScriptPath = [System.IO.DirectoryInfo]$PSCommandPath
$ProductTemplate = Resolve-Path (Join-Path $ScriptPath.Parent.FullName "Product.wxs") #TODO
$ProgramFiles = [System.Environment]::GetEnvironmentVariable('ProgramFiles(x86)')
$WixDir = Get-ChildItem -Path "$ProgramFiles\Wix Toolset**\bin\" -Directory

if ($null -eq $WixDir) {
    Write-Error -Message "Could not find the Wix Toolset under $ProgramFiles, exiting..." -ErrorAction Stop
}

if (-Not (Test-Path $BinPath -PathType Container)) {
    Write-Error -Message "Could not find the path ($BinPath), exiting..." -ErrorAction Stop
}

if (-Not (Test-Path $ProductTemplate -PathType Leaf)) {
    Write-Error -Message "Could not find the template wxs file (Product.wxs), exiting..." -ErrorAction Stop #TODO
}

Write-Host "Using Wix Toolset from '$WixDir'"
$heat = Join-Path $WixDir "heat.exe"
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

function GenerateFileId {
    return ( -join ((97..122) | Get-Random -Count 10 | ForEach-Object { [char]$_ }))
}

function AddPathsToSourceFiles {
    param ($WxsPath, $Paths)
    try {
        $xmlns = "http://schemas.microsoft.com/wix/2006/wi"
        $PathsArr = $Paths.Split(",").Trim()
        [xml]$xml = Get-Content $WxsPath
    
        $i = 0;
        foreach ($path in $PathsArr) {
            if ("$path".Length -gt 0) {
                $PropertyElement = $xml.CreateElement("Property", $xmlns)
                $PropertyElement.SetAttribute("Id", "DestinationFolder$i")
                $PropertyElement.SetAttribute("Value", $Path)
                $xml.Wix.Fragment[0].AppendChild($PropertyElement) | Out-Null
            }
            $i++;
        }
    
        $CopyFileElements = $xml.CreateElement("CopyFileGroup", $xmlns)

        $xml.SelectNodes("//*") | Where-Object { $_.Name -eq "File" } | ForEach-Object {
            $CopyFileElements = $xml.CreateElement("CopyFileParent", $xmlns)
            # CopyFile should be added only for more than one target paths,
            # as first one is added as base path, starting loop from index 1.
            for ($i = 1; $i -lt $PathsArr.Count; $i++) {
                $CopyFileId = GenerateFileId
                $CopyFileElement = $xml.CreateElement("CopyFile", $xmlns)
                $CopyFileElement.SetAttribute("Id", $CopyFileId)
                $CopyFileElement.SetAttribute("DestinationProperty", "DestinationFolder$i")
                $CopyFileElements.AppendChild($CopyFileElement) | Out-Null
            }
            $_.InnerXML = $CopyFileElements.InnerXml

        } | Out-Null
    
        $xml.Save($WxsPath)
        return $true
    }
    catch {
        Write-Host $Error[0]
        return $false
    }
}

function GenerateWxs {
    [CmdletBinding()]
    param ($BinPath, $Component)

    return (ExecuteSyncProcess $heat "dir `"$BinPath`" -dr INSTALLFOLDER -cg DynamicFragment -nologo -ag -scom -sreg -sfrag -suid -srd -out `"$TempOut\$Component\sourceFiles.wxs`" -var `"var.Source`"") -eq 0
}
function GenerateWxsObj {
    [CmdletBinding()]
    param ($Component, $Version, $UpgradeCode, $BasePath)

    $ProductObj = ExecuteSyncProcess $candle "$ProductTemplate -out `"$TempOut\$Component\Product.wixobj`" -dComponentName=`"$Component`" -dProductVersion=`"$Version`" -dUpgradeCode=`"$UpgradeCode`" -dTargetFolder=`"$BasePath`" -nologo"

    Write-Host $ProductObj
    $SourceObj = ExecuteSyncProcess $candle "`"$TempOut\$Component\sourceFiles.wxs`" -out `"$TempOut\$Component\allFragments.wixobj`" -dSource=`"$BinPath`" -nologo"

    return ($ProductObj -eq 0) -and ($SourceObj -eq 0)
}
function GenerateMSI {
    [CmdletBinding()]
    param ($Component, $Version, $MSIOutFolder)
    return (ExecuteSyncProcess $light "-b `"$TempOut\$Component`" `"$TempOut\$Component\Product.wixobj`" `"$TempOut\$Component\allFragments.wixobj`" -out `"$MSIOutFolder\$Component.msi`" -spdb -sw1076 -nologo") -eq 0
}

try {
    Write-Host "Packaging '$Component' '$Version' ..."
    $BasePath = $TargetPaths.Split(",")[0].Trim()
    Write-Host "Base path: '$BasePath'"

    Write-Host "Packaging contents in '$BinPath' ..."

    Write-Host "Generating wix files..."
    $WxsSuccess = GenerateWxs $BinPath $Component
    if (!$WxsSuccess) {
        throw "Could not generate the WXS files for $Component"
    }

    if (-Not (Test-Path -Path "$TempOut\$Component\sourceFiles.wxs" -PathType Leaf)) {
        Write-Error "Could not find the generated source wxs file, please check the logs above. Exiting..." -ErrorAction Stop
    }

    $AddPathsSuccess = AddPathsToSourceFiles -WxsPath "$TempOut\$Component\sourceFiles.wxs" -Paths $TargetPaths
    if (!$AddPathsSuccess) {
        throw "Could not generate the WXS Object files for $Component"
    }

    Write-Host "Generating wix objects..."
    $UpgradeCode = [guid]::NewGuid().ToString()
    $WxsObjSuccess = GenerateWxsObj $Component $Version $UpgradeCode $BasePath
    if (!$WxsObjSuccess) {
        throw "Could not generate the WXS Object files for $Component"
    }

    Write-Host "Generating msi installer..."
    $MSISuccess = GenerateMSI $Component $Version $MSIPath
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
    Remove-Item $TempOut -Recurse -ErrorAction Ignore
    Write-Host "Cleaned temp objects"
}