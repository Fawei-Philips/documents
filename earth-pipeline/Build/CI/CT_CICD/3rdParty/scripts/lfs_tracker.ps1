# Author: Vaibhav Garg (320219077)

# The script crawls in the given directory to find different files
# and differentiates them between Binary and non Binary files.
# Binary file/filetypes are added to Git LFS (in `.gitattributes` file) present in the root of the directory provided
# and non Binary filetypes are recorded in the root of this script in `.nonbinaries` file.

# Usage: lfs_tracker.ps1 <Source> <Target> <Components> <Message>

# Options:
#  Source: Root path of the source 3rd_Party component directory.
#  Target: Root path of the target repository.
#  Component: Component name to be processed.
#  Version: Version code to be processed.
#  Message: Commit message.
#  Auth: Auth for Artifactory (Format= <username>:<PAT>).

# Example: .\lfs_tracker.ps1 'D:\Castle.Core' 'D:\CT_3rdParty' 'Castle.Core' '4.2.0' 'Commit Castle.Core' 'username:pat'

param(
    [Parameter(Mandatory = $false, Position = 0)] [string]$Source,
    [Parameter(Mandatory = $false, Position = 1)] [string]$Target,
    [Parameter(Mandatory = $false, Position = 2)] [string]$Component = (Write-Error "Please provide component name using -Components=`"Castle.Core`". Exiting..." -ErrorAction Stop),
    [Parameter(Mandatory = $false, Position = 3)] [string]$Version = (Write-Error "Please provide version code to be added using -Version=`"4.2.0`". Exiting..." -ErrorAction Stop),
    [Parameter(Mandatory = $false, Position = 4)] [string]$Message = (Write-Error "Please provide a commit message by using -Message=`"message`". Exiting..." -ErrorAction Stop),
    [Parameter(Mandatory = $true, Position = 5)] [string]$Auth = (Write-Error "Please provide the Artifactory auth using -Auth=`"<username>:<PAT>`". Exiting..." -ErrorAction Stop)
)

if (-Not ($PSBoundParameters.ContainsKey('Source'))) {
    Write-Host "The script crawls in the given directory to find different files`n and differentiates them between Binary and non Binary files.`nBinary file/filetypes are added to Git LFS (in `.gitattributes` file) present in the root of the directory provided`n and non Binary filetypes are recorded in the root of this script in `.nonbinaries` file.`n`nUsage: lfs_tracker.ps1 <Target>`n`nOptions:`nSource: Root path of the source 3rd_Party component directory.
    `nTarget: Root path of the target repository.
    `nComponent: Component name to be processed.
    `Version: Version code to be processed.
    `nMessage: Commit message.
    `nAuth: Auth for Artifactory (Format= <username>:<PAT>).`n`nExample: .\lfs_tracker.ps1 'D:\Castle.Core' 'D:\CT_3rdParty' 'Base, Castle.Core' 'Commit Castle.Core' 'username:pat'`nPress any key to exit..."
    Write-Host -Object ([System.Console]::ReadKey().Key);
    exit
}

if (-Not ($PSBoundParameters.ContainsKey('Message'))) {
    Write-Error "Please provide a commit message by using -Message param. Exiting..." -ErrorAction Stop
}

if (-Not (Test-Path $Source -PathType Container)) {
    Write-Error -Message "Source directory not found: $Source" -ErrorAction Stop
}
if (-Not (Test-Path $Target -PathType Container)) {
    Write-Error -Message "Target directory not found: $Target" -ErrorAction Stop
}

if (-Not (Test-Path "$Source/$Component" -PathType Container)) {
    Write-Error -Message "Component in Source directory not found: $Source/$Component" -ErrorAction Stop
}
if (-Not (Test-Path "$Source/$Component/Version $Version" -PathType Container)) {
    Write-Error -Message "Version in Component directory not found: $Source/$Component/Version $Version" -ErrorAction Stop
}

# Stores all the file types present in the target directory
$FoundTypes = @{}

# Stores types defined in .gitattributes and .nonbinaries
$KnownNonBinaries = @()
$KnownBinaries = @()

# Stores new file types found in the directory
$NewTypes = @()

# Stores new binary types and files 
$NewBinFiles = @()
$NewBinTypes = @()

# Stores new non binary types
$NewNonBinaries = @()

# Default location for the git attributes file
$AttributesPath = Join-Path $Target ".gitattributes"

# Default location for the non binaries files
$NonBinariesPath = Join-Path $Target ".nonbinaries"

# Get all the files in the directory
$RootPath = "$Source/$Component/Version $Version"
$InstallersPath = "$Source/Export/Installers/$Component/Version $Version"
$NugetPath = "$Source/Export/Nuget/$Component/Version $Version"
$Files = Get-ChildItem $RootPath,$InstallersPath,$NugetPath | Get-ChildItem -File -Recurse

# URLs for the artifactory & .lfsconfig file
$BaseURL = "https://artifactory-china.ta.philips.com:443/artifactory/"
$PlaceholderURL = "https://[LFS_AUTH]@artifactory-china.ta.philips.com:443/artifactory/api/lfs/CT_3rdParty"
$DefaultURL = $PlaceholderURL.Replace("[LFS_AUTH]", "<CODE1>:<PAT>")
$LFS_URL = $PlaceholderURL.Replace("[LFS_AUTH]", $Auth)
$AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Auth))
$Headers = @{"Authorization" = "Basic $AuthToken" }

# Branch name for pushing changes
$Branch = "update-lfs-content"

$env:GIT_REDIRECT_STDERR = '2>&1'

function isTypeTracked {
    # Get the current attribute for the given extension
    [CmdletBinding()]
    param ($Type)
    process {
        Set-Location $Target
        $CurrAttr = (Set-Location $Target | git check-attr filter $Type)
        if ($CurrAttr.Contains('lfs')) {
            return $true
        }
        return $false
    }
}

function isFileBinaryEncoded {
    [CmdletBinding()]
    param ($File)
    process {
        # Check for allowed encoding or Null character in the first 8000 bytes of the file
        Set-Location $Source
        # Get the first 8000 bytes from the files
        $byteArray = Get-Content -Path $File -Encoding Byte -TotalCount 8000

        if ($byteArray.Length -ge 4) {
            # Encoding check using BOM
            # https://en.wikipedia.org/wiki/Byte_order_mark#Representations_of_byte_order_marks_by_encoding
            if ( ("{0:X}{1:X}{2:X}" -f $byteArray) -eq "EFBBBF" -or 
            ("{0:X}{1:X}" -f $byteArray) -eq "FFFE" -or 
            ("{0:X}{1:X}" -f $byteArray) -eq "FEFF" -or
            ("{0:X}{1:X}{2:X}{3:X}" -f $byteArray) -eq "FFFE0000" -or
            ("{0:X}{1:X}{2:X}{3:X}" -f $byteArray) -eq "0000FEFF" ) {
                # File is either UTF-8 UTF-16 or UTF-32 encoded
                return $false
            }
        }
        # Check if the array contains a Null character
        if ( $byteArray -contains 0 ) {
            return $true
        }
        return $false
    }
}

function GenerateGlob {
    # Convert extensions to glob patterns to include all files & make them case-insensitive
    [CmdletBinding()]
    param ([string[]]$Exts)
    process {
        $GlobParams = @()
        foreach ($Ext in $Exts) {   
            # Convert ".ext" to "*.[eE][xX][tT]"
            $GlobPattern = "*"
            foreach ($e in $Ext.ToCharArray()) { $globPattern += if ($e -match '[a-z]') { "[" + $e + "$e".toUpper() + "]" }else { $e } }
            $GlobParams += $GlobPattern
        }
        return $GlobParams
    }
}

function AddLFSTracker {
    # Add LFS tracking for the given extension or file in the target directory
    [CmdletBinding()]
    param ([string[]] $Types,
        [boolean]$areExts)
    process {
        $Params = $Types
        try {
            if ($areExts) { $Params = GenerateGlob -Exts $Types }
            (Set-Location $Target | git lfs track $Params) 
        }
        catch {
            Write-Error "Could not add '$Type' for tracking" -NoNewline
            Write-Host $Error[0]
        }
    }
}

function AddNonBinary {
    # Log the non binary file type
    [CmdletBinding()]
    param ([string]$Ext)
    process {
        try {
            # Write exclude rule for the extension in file
            [System.IO.File]::AppendAllText($NonBinariesPath, "`n$Ext")
            Write-Host "Added '$Ext' as non binary"
        }
        catch {
            Write-Error "Could not add '$Ext' as non binary" -NoNewline
            Write-Host $Error[0]
        }
    }
}

# Test Credentials
Write-Host "Authenticating artifactory..."
try {
    Invoke-RestMethod -Method Head -Uri "$($BaseURL)api/repositories" -Headers $Headers
    Write-Host "Authenticated." -ForegroundColor Green
}
catch {
    Write-Host $Error[0]
    Write-Error "Could not authenticate artifactory. Please check the username & password. Example- <Username>:<PAT>" -ErrorAction Stop
}

try {
    Write-Host "Setting up LFS Tracker... "
    
    if (-Not (Test-Path $AttributesPath -PathType Leaf)) {
        Write-Host "Installing LFS... "
        (Set-Location $Target | git lfs install )
    }
    
    Write-Host "Crawling target directory..."

    # Move to the target directory
    Set-Location $Source

    # Store all file types with relative path of their first occurrence 
    # and mark them as an extension or a file without extension
    foreach ($File in $Files) {
        $RelativePath = $File.FullName | Resolve-Path -Relative
        $Key = $File.Extension
        $Data = @{"isExtension" = $true; "path" = $RelativePath }
        # If file does not have any extension
        if (!($Key)) {
            # Mark it as a file
            $Data["isExtension"] = $false
            # Store it as the relative path instead of extension
            $Key = $RelativePath
        }
        # Add the file/extension to the map
        if (!$FoundTypes[$Key]) {
            $FoundTypes.add($Key, $Data)
        }
    }
    Write-Host "Found $($FoundTypes.Count) types in the target directory"

    try {
        if (-Not (Test-Path $NonBinariesPath -PathType Leaf)) {
            Write-Host "Could not find `".nonbinaries`" file, creating..."
            New-Item -Path $NonBinariesPath -ErrorAction Stop | Out-Null
        }
    }
    catch {
        Write-Error "Could not create `"$NonBinariesPath`"" -ErrorAction Stop
    }
    
    # Populate known non binaries
    $NonBinaries = Get-Content $NonBinariesPath
    foreach ($NB in $NonBinaries) {
        $KnownNonBinaries += $NB
    }
    
    # Find the new file types and populate known binaries simultaneously 
    Write-Host "Searching for new file types..."
    foreach ($Type in $FoundTypes.keys) {
        if (!($KnownNonBinaries.Contains($Type))) {
            if (!(isTypeTracked -Type $Type)) { $NewTypes += $Type }
            else { $KnownBinaries += $Type }
        }
    }
    
    Write-Host "Found $($KnownNonBinaries.Count) types in `".nonbinaries`""
    Write-Host "Found $($KnownBinaries.Count) types in `".gitattributes`" (including .lfsconfig)"
    Write-Host "Found $($NewTypes.Count) new types"
    
    # Read & filter all new types
    Write-Host "Filtering new types..."
    foreach ($Type in $NewTypes) {
        $IsBinary = isFileBinaryEncoded -File $FoundTypes[$Type]["path"]
        if ($IsBinary) { 
            if ($FoundTypes[$Type]['isExtension']) { $NewBinTypes += $Type }
            else { $NewBinFiles += $Type }
        }
        else { $NewNonBinaries += $Type }
    }
    Write-Host "Found $($NewBinTypes.Count) new binary types"
    Write-Host "Found $($NewBinFiles.Count) new binary files (without extension)"
    Write-Host "Found $($NewNonBinaries.Count) new non binary types"

    # Add new binary file/filetype to .gitattributes
    Write-Host "Adding new binary files/filetypes..."

    if ($NewBinTypes) { AddLFSTracker -Types $NewBinTypes -areExts $true }
    if ($NewBinFiles) { AddLFSTracker -Types $NewBinFiles -areExts $false }
    
    Write-Host "Total: Added $($NewBinTypes.Count) new binary types"
    Write-Host "Total: Added $($NewBinFiles.Count) new binary files (without extension)"
    
    # Add new non binary extensions to .nonbinaries
    Write-Host "Adding new non binary extensions..."
    foreach ($NonBinType in $NewNonBinaries) { AddNonBinary -Ext $NonBinType }

    Write-Host "Total: Added $($NewNonBinaries.Count) new non binary extensions"

    Write-Host "Checking-in source to the target..."

    # Copy files of components from source to target
    Get-ChildItem $RootPath,$InstallersPath,$NugetPath | Get-ChildItem -File -Recurse | ForEach-Object {
        $Source = $Source.TrimEnd("\")
        $DestFolder = $_.Directory.ToString().Replace($Source, $Target)
        $Exists = Test-Path -Path $DestFolder
        if (!$Exists) {
            New-Item $DestFolder -ItemType Directory | Out-Null
        }
        Copy-Item $_.FullName $DestFolder | Out-Null
    }

    Set-Location $Target

    Write-Host "Switching to the new branch..."
    git checkout master
    git branch -D $Branch
    git checkout -b $Branch
    
    # Commit .nonbinaries changes   
    git add $NonBinariesPath 
    git commit -m "Updated Non Binaries"

    Write-Host "Committing changes..."
    git add .
    git commit -m $Message
    
    $Gitignore = Join-Path $PSScriptRoot '.\gitignore.ps1'
    Invoke-Expression "$Gitignore `"$Target`" `"$Component`" `"$Version`" `"$Auth`""
    
    $GitignorePath = Join-Path $Target ".gitignore"
    git add $GitignorePath
    git commit -m "Updated .gitignore"

    Write-Host "Setting up LFS Config... "
    git config -f .lfsconfig lfs.url $LFS_URL
    
    Write-Host "Pulling remote changes... "
    git pull origin $Branch

    Write-Host "Pushing to remote..."
    git push --set-upstream origin $Branch
    
    Write-Host "Re-setting LFS Config... "
    git config -f .lfsconfig lfs.url $DefaultURL
    Write-Host "LFS Tracker complete." -ForegroundColor Green
    return 0
}
catch {
    Write-Error $Error[0]
    return 1
}