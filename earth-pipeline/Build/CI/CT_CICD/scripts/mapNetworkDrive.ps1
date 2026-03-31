<#
    Authors:
    Mulakala, Chaitanya (320218691)
    B J, Aditi (320219109)

    Description: Script creates a shared folder and maps network drive or unmaps a network drive based on inputs provided.

    Input:
        - $map (Mandatory): type(int) 1 -> Map network drive, 0 -> UnMap network drive
        - $driveLetters (Mandatory): type(String) Provide comma separated drive letters in capital. Eg. "D,E,Y" 
        - NOTE: drive letters must be in capital and list must not contain any spaces.

    Usage:
        .\mappingNetworkDrive.ps1 -map 1 -driveLetters "E,Y"
        .\mappingNetworkDrive.ps1 -map 0 -driveLetters "E,Y"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false, Position = 0)] [int]$map,
    [Parameter(Mandatory = $false, Position = 1)] [string]$driveLetters
)

# Input Validation
if ($PSBoundParameters.Count -eq 0) {
    Write-Host "The script requires two inputs in order to function.`nNamely:`n1) map: accepts 0 or 1 as input.`n   1 - to map network drive(s) `n   0 - to disconnect mapped network drive(s)`n2) driveLetters: accepts comma separated drive letters with no extra spaces. (Eg. D,E,Y or d,e)" -ForegroundColor Green
    
    # Input for map
    $userInput = Read-Host "Enter input for map"
    if (-not ([Int32]::TryParse($userInput, [ref]$map))) {
        Write-Error "Invalid Input! Please enter an integer value as input." -ErrorAction Stop
    }

    # Input for driveLetters
    $inputString = Read-Host "Enter input for driveLetters"
    $driveLetters = $inputString.ToString()
}
else {
    if (-Not ($PSBoundParameters.ContainsKey('map'))) {
        $userInput = Read-Host "Enter input for map`n1 - to map network drive(s) `n0 - to disconnect mapped network drive(s)`n"
        if (-not ([Int32]::TryParse($userInput, [ref]$map))) {
            Write-Error "Invalid Input! Please enter an integer value as input." -ErrorAction Stop
        }
    }
    if (-Not ($PSBoundParameters.ContainsKey('driveLetters'))) {
        $inputString = Read-Host "Enter comma separated drive letters with no extra spaces.`nExample - D,E,Y`n"
        $driveLetters = $inputString.ToString()
    }
}
# Validating input for driveLetters
$driveLetters = $driveLetters.ToString()
$driveLetters = $driveLetters.ToUpper()
$pattern = "^([A-Z],)*[A-Z]$"
if (-not ($driveLetters -match $pattern)) {
    Write-Error "Invalid input string. It should be in the format as shown in the below example: `nD,E,Y or d,e`nMake sure that there are no spaces in the input string." -ErrorAction Stop
}

# Function to create a shared folder. It returns the shared folder path.
function NewSharedFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $driveLetter
    )
    $shareFolderName = "Nunit_$($driveLetter)"
    $shareFolderPath = "D:\Shared\$($shareFolderName)"
    
    # Creating a root directory to store shared folders within
    if (-not (Test-Path "D:\Shared")) {
        Write-Host "Creating folder: D:\Shared ..." -ForegroundColor Green
        New-Item -ItemType Directory -Path "D:\Shared"
    }

    # Check if the folder already exists else Create it.
    if (Test-Path $shareFolderPath) {
        Write-Host "Folder already exists! `nPath: $($shareFolderPath)" -ForegroundColor Green
    }
    else {
        Write-Host "Creating shared folder: $($shareFolderPath) ..." -ForegroundColor Green
        New-Item -ItemType Directory -Path $shareFolderPath
    }
    
    # Get the list of shared folders
    $sharedFolders = Get-SmbShare

    # Check if the specified folder is already shared
    $isShared = $sharedFolders | Where-Object { $_.Name -eq $shareFolderName }

    if ($isShared) {
        Write-Host "The folder '$shareFolderName' is already shared." -ForegroundColor Green
    }
    else {    
        # Share the created folder
        Write-Host "Sharing folder: $shareFolderName ..."
        New-SmbShare -Name $shareFolderName -Path $shareFolderPath -FullAccess "Everyone"
    }

}

# Function to map a drive to the shared folder
function NewMappedDrive {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $driveLetter
    )
   
    # Create shared folder
    NewSharedFolder -driveLetter $driveLetter
    $shareName = "Nunit_$($driveLetter)"
    $shareUNCPath = "\\localhost\$($shareName)"


    # Map network drive
    try {
        # Get the list of mapped drives
        $mappedDrives = Get-PSDrive -PSProvider FileSystem

        # Check if the specified drive is already mapped
        $isMapped = $mappedDrives | Where-Object { $_.Name -eq $driveLetter }

        if ($isMapped) {
            Write-Host "The drive '$driveLetter' is already mapped." -ForegroundColor Green
        }
        else {
            if (Test-Path $shareUNCPath) {
                Write-Host "Mapping drive - '$($driveLetter)' to share location - '$($shareLocation)' ..." -ForegroundColor Green
                net use "$($driveLetter):" $shareUNCPath
            }
            else {
                Write-Error "Invalid share path" -ErrorAction Stop
            }
        }
        
    }
    catch {
        Write-Error "An error occured:`n"
        Write-Host $_
    }
}

# Function to remove a mapped drive 
function RemoveMappedDrive {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $driveLetter
    )
            
    try {
        $folderName = "Nunit_$driveLetter"

        # Get the list of mapped drives
        $mappedDrives = Get-PSDrive -PSProvider FileSystem

        # Check if the specified drive is already mapped
        $isMapped = $mappedDrives | Where-Object { $_.Name -eq $driveLetter }

        if ($isMapped) {
            Write-Host "Disconnecting drive $($driveLetter): ..." -ForegroundColor Green
            net use "$($driveLetter):" /delete
        }
        else {
            Write-Host "Drive $($driveLetter) is already diconnected!" -ForegroundColor Green
        }
        
        # Get the list of shared folders
        $sharedFolders = Get-SmbShare

        # Check if the specified folder is already shared
        $isShared = $sharedFolders | Where-Object { $_.Name -eq $folderName }

        if ($isShared) {
            # Remove the share
            Write-Host "Removing share: $($folderName) ..." -ForegroundColor Green
            Remove-SmbShare -Name $folderName -Force
        }
        else {
            Write-Host "Share is already removed for $($folderName)!" -ForegroundColor Green
        }      

        # Delete the folder
        $folderPath = "D:\Shared\$folderName"
        if (Test-Path $folderPath) {
            Write-Host "Deleting folder: $($folderName) ..." -ForegroundColor Green
            Remove-Item $folderPath -Recurse
        }
        else {
            Write-Host "Folder $($folderPath) already deleted!" -ForegroundColor Green
        }
    }
    catch {
        Write-Error "An error occurred:`n"
        Write-Host $_
    }
    
}

$driveLetterArr = $driveLetters.Split(",")

try {
    if ($map -eq 1) {
        Write-Host "Mapping process started..." -ForegroundColor Green
        foreach ($driveLetter in $driveLetterArr) {
            Write-Host "Creating Mapped Drive: $($driveLetter)" -ForegroundColor Cyan
            NewMappedDrive -driveLetter $driveLetter            
        }
    }
    elseif ($map -eq 0) {
        Write-Host "Unmapping process started..." -ForegroundColor Green
        foreach ($driveLetter in $driveLetterArr) {
            Write-Host "Removing Mapped Drive: $($driveLetter)" -ForegroundColor Cyan
            RemoveMappedDrive -driveLetter $driveLetter      
        }
    }
    else {
        Write-Error "Invalid input for the variable `$map. It only accepts two integer values: 1 to map network drive(s) or 0 to disconnect mapped drive(s)." -ErrorAction Stop
    }
}
catch {
    Write-Error "An error occurred:`n" 
    Write-Host $_ 
}