# Author: Vaibhav Garg (320219077)

# The script uses MSBuild to build the Interface and Implementation Solutions (.sln) 
# located in \ExtInf\ and \Src\ directories of the provided repository.

# Usage: build.ps1 [Repo] [VsVer] [BuildParams]

# Options:
#  repo:  (Optional) Root directory of the repository. 
#          Defaults to the root directory of the script.
#  VsVer: (Optional) Range of installed VS to use for building.
#          Defaults to the latest installed version.
# BuildParams: (Optional) Parameters to be passed to the MSBuild to build the solutions.

# Example: .\build.ps1 'D:\RepoBuilder\Dummy_Repo' '[15, 17)'
# Example: .\build.ps1 'D:\RepoBuilder\Dummy_Repo' -BuildParams '/p:platform="Any CPU" /p:configuration="Release"'

# Note: `VsVer` takes a range of VS version codes. Examples:
#  1. '[15, 16)' : Inclusive of 15 but exclusive of 16, ie. 15.x.x.x
#  2. '15' : Single version number  means that version or newer.
#  3. NA : Deafults to the latest installed version.
# More on version: https://github.com/microsoft/vswhere/wiki/Versions

param( [Parameter(Mandatory = $false, Position = 0)][string]$Repo,
    [Parameter(Mandatory = $false, Position = 1)][string]$VSVer,
    [Parameter(Mandatory = $false, Position = 2)][string]$BuildParams,
    [Parameter(Mandatory = $false, Position = 3)][switch]$help)

function ExecuteMSBuildSync {
    [CmdletBinding()]
    param ([string]$MSBPath, [string]$SoultionPath, [string]$Params)
    process {
        $InfRestore = Start-Process -FilePath $MSBPath "$SoultionPath $Params" -PassThru -NoNewWindow
        $InfRestoreHandle = $InfRestore.Handle # Storing the Process Handle in the Process Object for ExitCode reference
        Write-Host "Cached process handle: " $InfRestoreHandle
        $InfRestore.WaitForExit()
        return $InfRestore.ExitCode
    }
}

function CleanUpBuild {
    try {
        Get-ChildItem "$Repo\Output\*\" -Exclude "README.md" | Remove-Item -Force -Recurse -ErrorAction Stop
        Get-ChildItem "$Repo\Export" -Exclude "README.md" | Remove-Item -Force -Recurse -ErrorAction Stop
        Get-ChildItem "$Repo\Build\Pkg\Nuget\" -Include "*.nupkg" -Recurse | Remove-Item -Force -Recurse -ErrorAction Stop
        Get-ChildItem "$Repo\Build\Pkg\MSI\" -Include "*.msi" -Recurse | Remove-Item -Force -Recurse -ErrorAction Stop
    }
    catch {
        Write-Error $Error[0]
        return 1
    }
    return 0
}

try {
    if (-Not($PSBoundParameters.ContainsKey('Repo'))) { $Repo = "." }
    $NuGetConfigPath = "$($Env:APPDATA)\NuGet\NuGet.Config"
    $RestorePackagesPath = "$Repo\Dependencies\Ref"
    $RestoreCommand = "/t:Restore -p:RestoreConfigFile=`"$NuGetConfigPath`",RestorePackagesPath=`"$RestorePackagesPath`""
    $BuildCommand = "/t:Build $BuildParams"
    $CleanCommand = "/t:Clean"

    if ($help.IsPresent) {
        Write-Host "The script uses MSBuild to build the Interface and Implementation Solutions (.sln) `nlocated in \ExtInf\ and \Src\ directories of the provided repository."
        Write-Host "`nUsage: build.ps1 [Repo] [VsVer] [BuildParams]`n`nOptions: `n repo:   (Optional) Root directory of the repository. Defaults to the root directory of the script. `n VsVer: (Optional) Range of installed VS to use for building. `n         Defaults to the latest installed version.`nBuildParams: (Optional) Parameters to be passed to the MSBuild to build the solutions."
        Write-Host "`nExample: .\build.ps1 'D:\RepoBuilder\Dummy_Repo' '[15, 17)'"
        Write-Host "         .\build.ps1 'D:\RepoBuilder\Dummy_Repo' -BuildParams '/p:platform=`"Any CPU`" /p:configuration=`"Release`"'"
        Write-Host "`n`nNote: ``VsVer`` takes a range of VS version codes. Examples:`n 1. '[15, 16)' : Inclusive of 15 but exclusive of 16, ie. 15.x.x.x `n 2. '15' : Single version number  means that version or newer. `n 3. NA : Deafults to the latest installed version. `nMore on version: https://github.com/microsoft/vswhere/wiki/Versions"
        Write-Host "`n`nPress any key to exit..."
        Write-Host -Object ([System.Console]::ReadKey().Key);
        exit
    }

    if (-Not (Test-Path $Repo)) {
        Write-Error -Message "Could not find the path ($Repo), exiting..." -ErrorAction Stop
    }
    
    Write-Host "Locating MSBuild..."

    # `vswhere` is designed to be a redistributable, single-file executable that can be used 
    # in build or deployment scripts to find where Visual Studio - or other products in the Visual Studio family - is located.
    # `vswhere` is included with the installer as of Visual Studio 2017 (version version 15.2^)
    # https://github.com/microsoft/vswhere
    $VSWhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (-Not (Test-Path $VSWhere)) {
        Write-Error -Message "Visual Studio not installed, exiting..." -ErrorAction Stop
    }
    
    # Invoking `vswhere` according to the version range supplied in the parameters
    $VSConfig = if ($PSBoundParameters.ContainsKey('VSVer')) { 
        & $VSWhere -requires Microsoft.Component.MSBuild -version $VSVer -utf8 -format json 
    }
    else { 
        & $VSWhere -requires Microsoft.Component.MSBuild -latest -utf8 -format json 
    }

    $VSConfigJSON = $VSConfig | ConvertFrom-Json 
    $VSPath = $VSConfigJSON[0].installationPath
    if (-Not ($VSPath)) {
        Write-Error -Message "Visual Studio for spefied version ($VSVer) not found, exiting..." -ErrorAction Stop
    }
    
    # Searching for the `MSBuild.exe` under the installation path.
    # MSBuild tools path has no fixed location and changes for different versions of Visual Studio.
    # https://learn.microsoft.com/en-us/visualstudio/msbuild/what-s-new-in-msbuild-15-0?view=vs-2022
    $GC_MSB = Get-ChildItem -Path "$VSPath\MSBuild\**\Bin\MSBuild.exe"
    if ($GC_MSB.Count -eq 0) {
        Write-Error -Message "Could not determine the installation path of MSBuild, exiting..." -ErrorAction Stop
    }
    $MSB = $GC_MSB[0].FullName
    
    if (-Not (Test-Path $MSB)) { 
        Write-Error -Message "Could not find MSBuild, exiting..." -ErrorAction Stop
    }
    Write-Host "`nUsing MSBuild located at: `"$MSB`"`n" -ForegroundColor Cyan
    
    Write-Host "Starting the build..."

    $RepoName = Split-Path $Repo -Leaf
    
    $InfSln = "$Repo\ExtInf\$($RepoName)Inf.sln"
    $ImplSln = "$Repo\Src\$($RepoName)Impl.sln"

    if (-Not((Test-Path($InfSln)) -And (Test-Path($ImplSln)))) {
        Write-Error "Required Solutions were not found in the given path, exiting..." -ErrorAction Stop
    }

    Write-Host "Cleaning the interfaces..."
    $InfCleanEC = ExecuteMSBuildSync -MSBPath $MSB -SoultionPath $InfSln -Params $CleanCommand
    if ($InfCleanEC -ne 0) {
        Write-Error "Something went wrong. Clean for $InfSln was not successful. Check error logs above for more details." -ErrorAction Stop
    }
    Write-Host "Successfully cleaned $InfSln [Exited with '$InfCleanEC' exit code]" -ForegroundColor Cyan

    Write-Host "Cleaning the implementations..."
    $ImplCleanEC = ExecuteMSBuildSync -MSBPath $MSB -SoultionPath $ImplSln -Params $CleanCommand    
    if ($ImplCleanEC -ne 0) {
        Write-Error "Something went wrong. Clean for $ImplSln was not successful. Check error logs above for more details." -ErrorAction Stop
    }
    Write-Host "Successfully cleaned $ImplSln [Exited with '$ImplCleanEC' exit code]" -ForegroundColor Cyan
    
    Write-Host "Cleaning the Output..."
    $CleanBuildEC = CleanUpBuild
    if ($CleanBuildEC -ne 0) {
        Write-Error "Something went wrong. Clean for Output folders was not successful. Check error logs above for more details." -ErrorAction Stop
    }
    Write-Host "Successfully cleaned Output" -ForegroundColor Cyan

    Write-Host "Restoring the interfaces..."
    $InfRestoreEC = ExecuteMSBuildSync -MSBPath $MSB -SoultionPath $InfSln -Params $RestoreCommand
    if ($InfRestoreEC -ne 0) {
        Write-Error "Something went wrong. Restore for $InfSln was not successful. Check error logs above for more details." -ErrorAction Stop
    }
    Write-Host "Successfully restored $InfSln [Exited with '$InfRestoreEC' exit code]" -ForegroundColor Cyan
    
    Write-Host "Building the interfaces using- $BuildCommand"
    $InfBuildEC = ExecuteMSBuildSync -MSBPath $MSB -SoultionPath $InfSln -Params $BuildCommand
    if ($InfBuildEC -ne 0) {
        Write-Error "Something went wrong. Build for $InfSln was not successful. Check error logs above for more details." -ErrorAction Stop
    }
    Write-Host "Successfully built $InfSln [Exited with '$InfRestoreEC' exit code]" -ForegroundColor Cyan
    
    Write-Host "Restoring the implementations..."

    $ImplRestoreEC = ExecuteMSBuildSync -MSBPath $MSB -SoultionPath $ImplSln -Params $RestoreCommand    
    if ($ImplRestoreEC -ne 0) {
        Write-Error "Something went wrong. Restore for $ImplSln was not successful. Check error logs above for more details." -ErrorAction Stop
    }
    Write-Host "Successfully restored $ImplSln [Exited with '$ImplRestoreEC' exit code]" -ForegroundColor Cyan
    
    Write-Host "Building the implementations using- $BuildCommand"
    $ImplBuildEC = ExecuteMSBuildSync -MSBPath $MSB -SoultionPath $ImplSln -Params $BuildCommand    
    if ($ImplBuildEC -ne 0) {
        Write-Error "Something went wrong. Build for $ImplSln was not successful. Check error logs above for more details." -ErrorAction Stop
    }
    Write-Host "Successfully built $ImplSln [Exited with '$ImplRestoreEC' exit code]" -ForegroundColor Cyan

    Write-Host "Builds were successful." -ForegroundColor Green
}
catch {
    Write-Host $Error[0]
}
