# Author: Vaibhav Garg (320219077)

# The script validates the folder structure and containing file types of a 3rd party directory

# Usage: validate.ps1 [Path] [Directory list]

# Options:
#  Path: Root path of the target directory. Defaults to current path. 
#  ComponentsList: List of comma-separated directories to be processed. Defaults to all components.

# Example: .\validate.ps1 'D:\CT_3rdParty' 'Castle.Core, log4net'

param( 
	[Parameter(Mandatory = $false, Position = 0)][string]$Path,
	[Parameter(Mandatory = $false, Position = 1)][string]$ComponentsList,
	[Parameter(Mandatory = $false, Position = 2)][switch]$help
)

if ($help.IsPresent) {
	Write-Host "The script validates the folder structure and containing file types of a 3rd party directory.`nUsage: validate.ps1 [Path] [Directory list]"
	Write-Host "`n`nPress any key to exit..."
	Write-Host -Object ([System.Console]::ReadKey().Key);
	exit
}

if (-Not($PSBoundParameters.ContainsKey('Path')) -or $Path -eq "") { $Path = Resolve-Path "." }
Write-Host $Path
if (-Not (Test-Path $Path -PathType Container)) {
	Write-Error -Message "Could not find the path ($Path), exiting..." -ErrorAction Stop
}

$Path = $Path.TrimEnd("\")
$InstallersPath = Join-Path $Path "Export\Installers"
$NugetPath = Join-Path $Path "Export\Nuget"

if (-Not($PSBoundParameters.ContainsKey('ComponentsList')) -or $ComponentsList -eq "") {
	$Components = Get-ChildItem $NugetPath, $InstallersPath, $Path -Directory -Exclude Build, Export | ForEach-Object BaseName | Select-Object -Unique
}
else {
	$Components = $ComponentsList.Split(",").Trim()
}

$Structure = @{
	"Export\Installers\[ComponentName]\Version*" = @{
		"AllowedExtensions" = @(".msi", ".exe", ".gitkeep")
		"Naming"            = "[ComponentName]"
	}
	"Export\Nuget\[ComponentName]\Version*"      = @{
		"AllowedExtensions" = @(".nupkg")
		"Naming"            = "[ComponentName].[Version]"
	}
	"[ComponentName]\Version*\Bin"               = @{
		"AllowedExtensions" = $null	
		"Naming"            = $null	
	}
	"[ComponentName]\Version*\Build"             = @{
		"AllowedExtensions" = @(".nuspec", ".wxs")
		"Naming"            = "[ComponentName]"
	}
	"[ComponentName]\Build"                      = @{
		"AllowedExtensions" = @(".wxs")
		"Naming"            = "[ComponentName]"
		"Optional"          = $true
	}
}

$ContainerPaths = @()

foreach ($ContainerPath in $Structure.GetEnumerator()) {
	$ContainerPaths += $ContainerPath.Name.Replace("\", "\\").Replace("*", "[ -~]*")
}

function GetComponentsList {
	param($Path, $Components, $Exclude)
	return Get-ChildItem $Path -Exclude $Exclude -Directory | Where-Object { $Components.Contains($_.BaseName) } | Get-ChildItem | Where-Object { $_.BaseName -ne "Build" } | ForEach-Object { $_.FullName.Replace($Path, "") }
}

function PrintDiff {
	param ($Diff, $Head1, $Head2)
	$Pre = "=>"
	$Switched = $false
	if ($Diff[0].SideIndicator -eq $Pre) { Write-Host "Mismatch in $Head2 :" }
	foreach ($DiffItem in $Diff) {
		if (!$Switched -and ($Pre -ne $DiffItem.SideIndicator)) {
			Write-Host "Mismatch in $Head1 :"
			$Switched = $true
		}
		Write-Host "`t$($DiffItem.InputObject)"
	}
}

function ValidateComponents {
	param($Path, $Components)

	try {
		$RootComponents = GetComponentsList $Path $Components "Export"
		Write-Host "Total root components:" $RootComponents.Count

		$InstallersComponents = GetComponentsList $InstallersPath $Components
		Write-Host "Total Installers components:" $InstallersComponents.Count

		$NugetComponents = GetComponentsList $NugetPath $Components
		Write-Host "Total Nuget components:" $NugetComponents.Count

		$DiffRootNInstallers = Compare-Object $RootComponents $InstallersComponents
		if ($DiffRootNInstallers) { 
			Write-Host "Error while verifying root components with Installers: (total $(($DiffRootNInstallers).Count))"
			PrintDiff $DiffRootNInstallers "root" "Installers"
			throw 
		}
		Write-Host "Verified root components with Installers"
		
		$DiffInstallerNNuget = Compare-Object $InstallersComponents $NugetComponents
		if ($DiffInstallerNNuget) { 
			Write-Host "Error while verifying Installers components with Nuget: (total $(($DiffInstallerNNuget).Count))"
			PrintDiff $DiffInstallerNNuget "Installers" "Nuget"
			throw 
		}
		Write-Host "Verified Installers components with Nuget"

		return $true 
	}
	catch {
		return $false
	}
}

function ValidateComponentStructure {
	param ($Name)

	try {
		foreach ($Rule in $Structure.GetEnumerator()) {
			$FolderPath = $Rule.Name.Replace("[ComponentName]", $Name)
			$Extensions = $Rule.Value["AllowedExtensions"]
			$Naming = $Rule.Value["Naming"]
			$Optional = $Rule.Value["Optional"]
			$Found = $true

			# Current directory path
			$CurrDir = Join-Path $Path $FolderPath
	
			# Check folder exists
			if (-Not(Test-Path -Path $CurrDir -PathType Container) ) { 
				if (-not($Optional)) {
					Write-Host "Could not find: $CurrDir"
					throw 
				}
				$Found = $false
			}
	
			if (($Extensions -or $Naming) -and $Found) {
				# Get list of directories from wildcard rule
				Get-ChildItem -Path $CurrDir | ForEach-Object { 
					$Parent = $_.BaseName
					# For every directory get all files
					Get-ChildItem $_.FullName -File | ForEach-Object { 
						# If extensions need to be checked
						if ($Extensions) {
							if ($_.Extension -eq ".gitkeep") { Write-Host "Ignoring gitkeep for " $Name $Parent; continue }
							# Check extension of every file found
							if (-Not($Extensions.Contains($_.Extension))) {
								Write-Host "Invalid file: $($_.FullName)" 
								Write-Host "Error: $FolderPath can only contain $Extensions files"
								throw
							}
						}
						
						# If naming needs to be checked
						if ($Naming) {
							# Get version code from parent
							$FolderVersion = $Parent.Replace("Version ", "")
							# Populate required file name using naming convention
							$FileName = $Naming.Replace("[ComponentName]", $Name)
							$FileName = $FileName.Replace("[Version]", $FolderVersion)
							# Check file name
							if (-Not($_.BaseName -eq $FileName)) {
								Write-Host "Invalid file: $($_.FullName)" 
								Write-Host "Error: $FolderPath can only contain file with name $Naming"
								throw
							}
						}
					}
				}
			}
		}
		return $true
	}
	catch {
		return $false
	}
	
}

function ValidateDanglingFiles {
	param ($TestPath, $Component)

	$Dir = $TestPath
	$Files = Get-ChildItem $Dir -Recurse -File | ForEach-Object { $_.DirectoryName.Replace($Path, "") } | Select-Object -Unique
	$TemplatePathsArr = $TemplatePaths -join "|"  
	$TemplatePathsArr = $TemplatePathsArr.Replace("[ComponentName]", $Component) 
	$Files | ForEach-Object { 
		if (-Not($_ -match $TemplatePathsArr )) {
			Write-Host "Invalid files at:" $TestPath$_
			throw
		}
	}
	return $true
}

try {
	# Validate component structure
	Write-Host "Validating components folder structure..." -ForegroundColor Cyan
	foreach ($Component in $Components) {
		Write-Host "Validating structure of $Component ..."

		Write-Host "Checking root of $Component ..."
		$RootPath = Join-Path $Path $Component
		$IsDirectoryClean = ValidateDanglingFiles $RootPath $Component
		Write-Host "Checking Installers of $Component ..."
		$ComponentInstallersPath = Join-Path $InstallersPath $Component 
		$IsDirectoryClean = ValidateDanglingFiles $ComponentInstallersPath $Component
		Write-Host "Checking Nuget of $Component ..."
		$ComponentNugetPath = Join-Path $NugetPath $Component 
		$IsDirectoryClean = ValidateDanglingFiles $ComponentNugetPath $Component
		if (-Not $IsDirectoryClean) {
			Write-Error "Could not validate component directory: $Component"
			throw
		}

		$IsValidStructure = ValidateComponentStructure $Component
		if (-Not $IsValidStructure) {
			Write-Error "Could not validate component structure: $Component"
			throw
		}
	}
	Write-Host "Completed validating folder structure." -ForegroundColor Cyan
	
	# Validate components
	Write-Host "Checking root, Installers & Nuget sub-directories..." -ForegroundColor Cyan
	$AreComponentsValid = ValidateComponents $Path $Components
	if (-Not $AreComponentsValid) {
		Write-Error "Could not validate sub-directories." 
		throw
	}
	Write-Host "Completed validating sub-directories." -ForegroundColor Cyan
}
catch {
	Write-Error "Validation was unsuccessful." 
	return 1
}

Write-Host "Validation was successful." -ForegroundColor Green
return 0