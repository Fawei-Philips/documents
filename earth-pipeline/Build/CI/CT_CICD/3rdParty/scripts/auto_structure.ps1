param(
    [Parameter(Mandatory = $false, Position = 1)][Alias('NupkgPath')][string]$InputNupkgPath,
    [Parameter(Mandatory = $false, Position = 2)][Alias('MsiPath')][string]$InputMSIPath,
    [Parameter(Mandatory = $false, Position = 3)][Alias('WxsPath')][string]$InputWxsPath,
    [Parameter(Mandatory = $false, Position = 4)][Alias('Default')][string]$MakeDefault,
    [Parameter(Mandatory = $false, Position = 5)][Alias('MsiReq')][string]$IsMSIReq,
    [Parameter(Mandatory = $false, Position = 6)][Alias('Name')][string]$ComponentName = (Write-Error "Component Name was not provided, exiting..." -ErrorAction Stop),
    [Parameter(Mandatory = $false, Position = 7)][Alias('Version')][string]$ComponentVersion = (Write-Error "Component Version was not provided, exiting..." -ErrorAction Stop)
)

$NupkgPathGiven = $false

if ("$InputNupkgPath".Length -gt 0) {
    $NupkgPathGiven = $true
    if (-Not(Test-Path $InputNupkgPath)) { Write-Error "Given Nupkg file path was not found, exiting..." -ErrorAction Stop }
}

if ("$InputMSIPath".Length -gt 0) {
    if (-Not(Test-Path $InputMSIPath)) { Write-Error "Given Msi file path was not found, exiting..." -ErrorAction Stop }
}

# Setting Temp path
$TempPath = [System.Environment]::GetEnvironmentVariable('Temp', 'User')
$RandomId = "$(New-Guid)".Split("-")[0]
$TempPath = Join-Path "$TempPath" "$RandomId"
New-Item -Path $TempPath -ItemType Directory | Out-Null
Write-Host "Temp path: '$TempPath'"

$InternalName = $ComponentName
$InternalVersion = $ComponentVersion
Write-Host "Given Component name: '$ComponentName' version: '$ComponentVersion'"

# Open and verify name and version in nuspec
if ($NupkgPathGiven) {
    $NupkgName = ([System.IO.FileInfo]$InputNupkgPath).Name
    Write-Host "Nupkg file name: '$NupkgName'"

    $TempExtractPath = Join-Path "$TempPath" "Temp"
    $NupkgPath = Join-Path "$TempPath" "$NupkgName"
    $ZipPath = Join-Path "$TempPath" "Package.zip"

    Copy-Item -Path $InputNupkgPath -Destination $NupkgPath
    Copy-Item -Path $InputNupkgPath -Destination $ZipPath

    Expand-Archive -Path $ZipPath -DestinationPath $TempExtractPath
    Write-Host "Extracted Nupkg file at '$TempExtractPath'"
    $InputNuspecPath = Get-ChildItem $TempExtractPath -File | Where-Object { $_.Extension -eq ".nuspec" } | Select-Object -First 1

    if ($null -eq $InputNuspecPath) {
        Write-Error "Error. Could not find a nuspec file in the package, exiting..." -ErrorAction Stop
    }

    $NuspecPath = $InputNuspecPath.FullName
    Write-Host "Nuspec file path: '$NupkgPath'"

    $NuspecXML = [xml](Get-Content $NuspecPath)
    $NuspecName = $NuspecXML.GetElementsByTagName('id')[0].InnerText
    $NuspecVersion = $NuspecXML.GetElementsByTagName('version')[0].InnerText

    Write-Host "Nuspec Component name: '$NuspecName' version: '$NuspecVersion'"

    if (($NuspecName -ne $ComponentName) -or ($NuspecVersion -ne $ComponentVersion)) {
        Write-Error "Name and version does not match the name and version in the given Nuspec file, exiting..." -ErrorAction Stop
    }

    $InternalName = $NuspecName
    $InternalVersion = $NuspecVersion
    Write-Host "Verified package with name: '$InternalName' version: '$InternalVersion'"
}

# Create folder structure
$StrPath = "$TempPath\s"
$VersionFolder = "$InternalName\Version $InternalVersion"
$StrBinPath = Join-Path "$StrPath\$VersionFolder" "Bin"
$StrBuildPath = "$StrPath\$VersionFolder\Build"
$StrInstallersPath = "$StrPath\Export\Installers\$VersionFolder"
$StrNugetPath = "$StrPath\Export\Nuget\$VersionFolder"
New-Item -Path $StrBinPath, $StrBuildPath, $StrInstallersPath, $StrNugetPath -ItemType Directory | Out-Null

# Populate Nuget and Build folders
if ($NupkgPathGiven) {
    $BuildNuspecPath = "$StrBuildPath\$InternalName.nuspec"
    $BuildWxsPath = "$StrBuildPath\$InternalName.wxs"
    $NugetPackagePath = "$StrNugetPath\$InternalName.$InternalVersion.nupkg"

    Expand-Archive -Path $ZipPath -DestinationPath $StrBinPath
    Copy-Item -Path $NuspecPath -Destination $BuildNuspecPath
    Copy-Item -Path $NupkgPath -Destination $NugetPackagePath

    $InputWxsPath = $InputWxsPath.Trim()

    $GlobalBuildWxsPath = "$StrBuildPath\$InternalName\Build\$InternalName.wxs"

    if ($IsMSIReq -eq "generate-using-custom-wxs") {
        # If use-default wxs is used, set current wxs path to global wxs
        if ("$InputWxsPath".Equals("use-default")) {
            if (-Not (Test-Path $GlobalBuildWxsPath -PathType Leaf)) {
                Write-Error "Wxs path was set to use-default, but could not find '$GlobalBuildWxsPath' path, exiting..." -ErrorAction Stop
            }
            Write-Host "Using default Wxs from: '$GlobalBuildWxsPath'"
            $InputWxsPath = $GlobalBuildWxsPath
        }

        if (-Not(Test-Path $InputWxsPath)) {
            Write-Error "Could not find the shared Wxs file at '$InputWxsPath', exiting..." -ErrorAction Stop
        }

        try {
            if($MakeDefault){
                New-Item $GlobalBuildWxsPath  -Force | Out-Null
                Copy-Item -Path $InputWxsPath -Destination $GlobalBuildWxsPath
            }
        }
        catch {
            Write-Host $Error[0]
            Write-Host "Could not replace the default Wxs template, skipping..."
        }

        # If wxs is provided, copy it to Build
        try {
            Write-Host "Wxs path: '$InputWxsPath'"
            if ("$InputWxsPath".EndsWith(".wxs")) {
                Write-Host "Copying Wxs file to: '$BuildWxsPath'"
                Copy-Item -Path $InputWxsPath -Destination $BuildWxsPath
            }
        }
        catch {
            Write-Error "Could not access the shared Wxs file, exiting..." -ErrorAction Stop
        }
    }
}

# MSI file paths
$InstallerPath = "$StrInstallersPath\$InternalName.msi"
$NoInstallerPath = "$StrInstallersPath\.gitkeep"

# Check if MSI path is provided
$InstallerFile = $null
try {
    $InstallerFile = [System.IO.FileInfo]$InputMSIPath
    Write-Host $InstallerFile
}
catch {
    Write-Host "MSI installer file not provided."
}

# Populate Installers folder
if (($null -eq $InstallerFile) -or ($InstallerFile.Extension -ne ".msi")) {
    New-Item $NoInstallerPath | Out-Null
    Write-Host "Created .gitkeep in Installers directory."
}
else {
    Copy-Item $InputMSIPath $InstallerPath
    Write-Host "Copied MSI to Installers directory."
}

# Cleaning up
if ($NupkgPathGiven) {
    Remove-Item $TempExtractPath, $ZipPath, $NupkgPath -Recurse -Force
}

Write-Host "Structured path: '$StrPath'"
Write-Host "##vso[task.setvariable variable=StructurePath;isoutput=true]$StrPath"
return $StrPath