# Author:   Vaibhav Garg (320219077)
#           Sanjana V (320218599)

# Usage: bump_version.ps1 [Region] [Project] <Repo> <Branch> <Auth> <BaseRepoPath>

param(
    [Parameter(Mandatory = $false, Position = 0)] [string]$Region = "TPC_Region26",
    [Parameter(Mandatory = $false, Position = 1)] [string]$Project = "CT-GlobalSW",
    [Parameter(Mandatory = $false, Position = 2)] [string]$Repo = "CT_RulesSystem",
    [Parameter(Mandatory = $false, Position = 3)] [string]$Branch = "versioning-test-new",
    [Parameter(Mandatory = $true, Position = 4)] [string]$Auth,
    [Parameter(Mandatory = $true, Position = 5)] [string]$BaseRepoPath,
    [Parameter(Mandatory = $false, Position = 6)] [string]$Prefix = "v",
    [Parameter(Mandatory = $false, Position = 7)] [bool]$IsProductBuild = $false
)

$env:GIT_REDIRECT_STDERR = '2>&1'

$CompRegistryPath = "\CT_CompRegistry\Sample.target"
$TargetFilePath = Join-Path $BaseRepoPath $CompRegistryPath

$configFilePath = "$BaseRepoPath\Build\Pkg\Version.config"
$infConfigFilePath = "$BaseRepoPath\Build\Version\InfVersion.config"
$infPkgConfigFilePath = "$BaseRepoPath\Build\Pkg\InfVersion.config"
$branchConfigPath = "$BaseRepoPath\Build\Pkg\BranchVersion.config"
$mainConfigPath = "$BaseRepoPath\Build\Version\Main.config"
$srcCommVerPath = "$BaseRepoPath\Src\CommonVersion\CommonVersion.cs"
$infCommVerPath = "$BaseRepoPath\ExtInf\CommonVersion\CommonVersion.cs"

$implNuspec = "$BaseRepoPath\Build\Pkg\Nuget\$($Repo)Impl.nuspec"
$infNuspec = "$BaseRepoPath\Build\Pkg\Nuget\$($Repo)Inf.nuspec"
$paNuspec = "$BaseRepoPath\Build\Pkg\Nuget\$($Repo)PostActions.nuspec"
$testNuspec = "$BaseRepoPath\Build\Pkg\Nuget\$($Repo)Test.nuspec"

$AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$Auth"))
$Headers = @{"Authorization" = "Basic $AuthToken" }
$GitBaseURL = "https://tfsemea1.ta.philips.com/tfs/$Region/$Project/_apis/git/repositories/$Repo"

$VersionBumpBranch = "automatic-version-bump"

# Get Branch Configuration
[int]$patchLimit = 999
$global:hasInfChanged = $false
$global:wasInfChanged = $false
$branchConfig = [xml](Get-Content -Path $branchConfigPath)
$branchVer = ($branchConfig.configuration.config.version).toString()

$SyncDependentScript = Join-Path $PSScriptRoot '.\sync_dependent_versions.ps1'

function getPreviousVersion {
    $config = [xml](Get-Content -Path $configFilePath)
    $branchConfig = [xml](Get-Content -Path $branchConfigPath)
    $currVer = $config.configuration.config.version.currentVersion
    $previousVersion = $currVer.major + "." + $currVer.minor + "." + $branchConfig.configuration.config.version + $currVer.patch + "." + $currVer.build
    return ($previousVersion -replace '\s' , '').ToString()
}

function hasCodeChanges {
    param([string]$TagName, [string]$Paths)
    $hasChanged = $false;
    $RepositoryData = Invoke-RestMethod -Method Get -Uri $GitBaseURL -ContentType "application/json" -Headers $Headers
    $CommitsURL = $RepositoryData._links.commits.href

    $ReqPaths = $Paths.Split(",").Trim()
    foreach ($ChangePath in $ReqPaths) {
        try {
            $ChangeCommitsURL = $CommitsURL + "?searchCriteria.compareVersion.versionType=branch&searchCriteria.compareVersion.version=$Branch&searchCriteria.itemVersion.versionType=tag&searchCriteria.itemVersion.version=$TagName&searchCriteria.itemPath=$ChangePath&searchCriteria.`$top=1"
            $ChangeCommitsData = Invoke-RestMethod -Method Get -Uri $ChangeCommitsURL -ContentType "application/json" -Headers $Headers
            if ($ChangeCommitsData.count -eq 1) {
                Write-Host "Changes found in $Paths from tag $TagName" -ForegroundColor Blue
                $hasChanged = $true
                break
            }
        }
        catch {
            Write-Host $Error[0]
        }
    }
    return $hasChanged;
}

function bumpPatch {
    # Load the XML configuration file
    $config = [xml](Get-Content -Path $configFilePath)
    $preVer = $config.configuration.config.version.previousVersion
    $currVer = $config.configuration.config.version.currentVersion

    $versionConfig = [xml](Get-Content -Path $mainConfigPath)
    $mainVersion = $versionConfig.configuration.config.version

    # If minor and major changes set patch and build to 0
    if ($preVer.major -ne $mainVersion.major -or $preVer.minor -ne $mainVersion.minor ) {
        $newPatch = "000"
        $newBuild = "0"
        Write-Host "Major and/or Minor has changes, setting Patch and Build to 0" -ForegroundColor Blue
    }
    else {
        # Increment the patch by 1 and set build to 0 if there are changes in the folders
        $newPatch = ([int]$currVer.patch + 1).toString("D3")
        $newBuild = "0"
        Write-Host "Incrementing patch by 1 and setting build to 0" -ForegroundColor Blue
    }

    # Update previousVersion to match currentVersion
    $preVer.major = $currVer.major
    $preVer.minor = $currVer.minor
    $preVer.patch = $currVer.patch
    $preVer.build = $currVer.build

    # Update current version
    $currVer.major = $mainVersion.major
    $currVer.minor = $mainVersion.minor
    $currVer.patch = $newPatch
    $currVer.build = $newBuild

    $config.Save($configFilePath)
    $Patch = -Join $branchVer, $newPatch # Integrate Branch Version

    # Final version major.minor.patch.build
    $finalVersion = $currVer.major + "." + $currVer.minor + "." + $Patch + "." + $config.configuration.config.version.currentVersion.build
    return ($finalVersion -replace '\s', '').ToString()
}

function bumpBuild {
    # Load the XML configuration file
    $config = [xml](Get-Content -Path $configFilePath)
    $preVer = $config.configuration.config.version.previousVersion
    Write-Host "Previous version:" "$($preVer.major).$($preVer.minor).$($preVer.patch).$($preVer.build)"
    $currVer = $config.configuration.config.version.currentVersion
    Write-Host "Current version:" "$($currVer.major).$($currVer.minor).$($currVer.patch).$($currVer.build)"

    $versionConfig = [xml](Get-Content -Path $mainConfigPath)
    $mainVersion = $versionConfig.configuration.config.version

    # If minor and major change set patch and build to 0
    if ($preVer.major -ne $mainVersion.major -or $preVer.minor -ne $mainVersion.minor ) {
        $newPatch = "000"
        $newBuild = "0"
        Write-Host "Major and/or Minor has changes, setting Patch and Build to 0" -ForegroundColor Blue
    }
    else {
        # Increment the build by 1 if there are no changes in the folder
        Write-Host "Incrementing build by 1" -ForegroundColor Blue
        $newBuild = ([int]$currVer.build + 1).toString()
        Write-Host "New Build:" $newBuild
        $newPatch = $currVer.patch
        Write-Host "New Patch:" $newPatch
    }
    # Update previousVersion to match currentVersion
    $preVer.major = $currVer.major
    $preVer.minor = $currVer.minor
    $preVer.patch = $currVer.patch
    $preVer.build = $currVer.build

    # Update current version
    $currVer.major = $mainVersion.major
    $currVer.minor = $mainVersion.minor
    $currVer.patch = $newPatch
    $currVer.build = $newBuild

    $config.Save($configFilePath)
    $Patch = -Join $branchVer, $newPatch # Integrate Branch Version

    # Final version major.minor.patch.build
    $finalVersion = $currVer.major + "." + $currVer.minor + "." + $Patch + "." + $newBuild
    Write-Host "Final version:" ($finalVersion -replace '\s', '').ToString()
    return ($finalVersion -replace '\s', '').ToString()
}

function updateNuspecVersion {
    param (
        [Parameter(Mandatory = $true, Position = 0)][string]$nuspecPath,
        [Parameter(Mandatory = $true, Position = 1)][string]$finalVersion
    )

    $config = [xml](Get-Content -Path $nuspecPath)
    $config.package.metadata.version = $finalVersion
    $config.Save($nuspecPath)

    Write-Host "Updated $nuspecPath to $finalVersion" -ForegroundColor Blue
}

function updateCommonVersion {
    param (
        [Parameter(Mandatory = $true, Position = 0)][string]$csFilePath,
        [Parameter(Mandatory = $true, Position = 1)][string]$finalVersion
    )
    $content = Get-Content $csFilePath

    $content = $content -replace '(?<=\[assembly: AssemblyVersionAttribute\(")\d+\.\d+\.\d+\.\d+(?="\)\])', $finalVersion
    $content = $content -replace '(?<=\[assembly: AssemblyFileVersionAttribute\(")\d+\.\d+\.\d+\.\d+(?="\)\])', $finalVersion

    $content | Set-Content $csFilePath
    Write-Host "Updated $csFilePath to $finalVersion"
}

function hasBumpedManually {
    $mainConfig = [xml](Get-Content -Path $mainConfigPath)
    $config = [xml](Get-Content -Path $configFilePath)
    $currVer = $config.configuration.config.version.currentVersion
    $mainVer = $mainConfig.configuration.config.version
    if (($currVer.major -ne $mainVer.major) -or ($currVer.minor -ne $mainVer.minor)) {
        return $true
    }
    return $false
}

function checkPatchLimit {
    $config = [xml](Get-Content -Path $configFilePath)
    if ([int]($config.configuration.config.version.currentVersion.patch) -le $patchLimit ) {
        return $true
    }
    return $false
}

function createInfVersion {
    $infConfig = [xml](Get-Content -Path $infConfigFilePath)
    $branchConfig = [xml](Get-Content -Path $branchConfigPath)
    $mainConfig = [xml](Get-Content -Path $mainConfigPath)
    $infPkgConfig = [xml](Get-Content -Path $infPkgConfigFilePath)

    $infVer = $infConfig.configuration.config.version
    $branchVer = $branchConfig.configuration.config.version
    $mainVer = $mainConfig.configuration.config.version
    $infPkgVer = $infPkgConfig.configuration.config.version

    $patchNumber = [int]$infVer.patch
    $buildNumber = [int]$infVer.build

    if ($patchNumber -gt $patchLimit) {
        throw "Build Failed. Inf patch number should be less than $patchLimit, Update Minor or Major."
    }

    # Reset Inf Patch and Build if Major/Minor is manually updated
    if (hasBumpedManually) {
        $patchNumber = 0
        $buildNumber = 0
        $infVer.patch = "$patchNumber"
        $infVer.build = "$buildNumber"
        $infConfig.Save($infConfigFilePath)
        Set-Variable -Name hasInfChanged -Scope Global -Value $true
    }

    # Update previous and current version and save
    if (($infPkgVer.currentVersion.patch -ne $patchNumber) -or ($infPkgVer.currentVersion.build -ne $buildNumber)) {
        $infPkgVer.previousVersion.patch = $infPkgVer.currentVersion.patch
        $infPkgVer.previousVersion.build = $infPkgVer.currentVersion.build
        $infPkgVer.currentVersion.patch = "$patchNumber"
        $infPkgVer.currentVersion.build = "$buildNumber"
        $infPkgConfig.Save($infPkgConfigFilePath)
        Set-Variable -Name hasInfChanged -Scope Global -Value $true
    }

    # Format and log final Inf version
    $infPatchVer = $patchNumber.toString("D3")
    $infVersion = $mainVer.major + "." + $mainVer.minor + "." + $branchVer + $infPatchVer + "." + $buildNumber
    $cleanInfVersion = ($infVersion -replace '\s' , '').ToString()
    Write-Host "Inf version:" $cleanInfVersion
    return $cleanInfVersion
}

# Go to Target repo
Set-Location $BaseRepoPath

# Create fresh branch
git fetch origin $Branch --depth=1 --no-tags
git checkout $Branch
git reset --hard origin/$Branch
git branch -D $VersionBumpBranch
git checkout -b $VersionBumpBranch

$previousVersion = getPreviousVersion
Write-Host "Previous Version:" $previousVersion
$previousVersionTag = "$($Prefix)_$previousVersion"
Write-Host "Previous Version Tag:" $previousVersionTag

# Check if Current Patch Version has incremented to 999
$check = checkPatchLimit
if (-not $check) {
    Write-Error "Build Failed. Patch Number has reached $patchLimit, Update Minor or Major."
    exit 1
}
else {
    Write-Host "Patch Number is less than 999"
}

$TagsData = Invoke-RestMethod -Method Get -Uri "$GitBaseURL/refs?filter=tags/$previousVersionTag&`$top=1" -ContentType "application/json" -Headers $Headers
if ($TagsData.count -eq 0) {
    Write-Host "The version tag $previousVersionTag was not found on the remote, exiting..." -ForegroundColor Red
    throw
}
else { Write-Host "Tag found on remote: $($TagsData.value[0].name) $($TagsData.value[0].objectId)" }

# Check if there are changes in the specific folders
$changesInSrc = hasCodeChanges $previousVersionTag "/Src"
$changesInInf = hasCodeChanges $previousVersionTag "/ExtInf"

# If ExtInf has changed, but Major and/or Minor versions have not, throw error
if ($changesInInf -eq $true) {
    $hasVersionChanged = hasBumpedManually
    if ($hasVersionChanged -eq $false) {
        Write-Host "ExtInf folder contains changes but the Major & Minor version codes are not updated."
        # Write-Error "Build Failed. Inf folder contains changes but the Major & Minor version codes are not updated."
        # exit 1
        if ($IsProductBuild -eq $true) {
            Write-Error "Build Failed. Inf folder contains changes but the Major & Minor version codes are not updated."
            exit 1
        }
    }
}

$finalVersion = ""
$infVersion = createInfVersion

# If Src has changed bump Patch else only bump Build
if ($changesInSrc -eq $true) {
    $finalVersion = bumpPatch
}
else {
    $finalVersion = bumpBuild
}

# Update Common version files
updateCommonVersion -csFilePath $srcCommVerPath -finalVersion $finalVersion
updateCommonVersion -csFilePath $infCommVerPath -finalVersion $infVersion

# Create new version tags on TFS
$NewVersion = "$($Prefix)_$finalVersion"

# Checking for trailing 0 for nuget packages
$version1 = $finalVersion.split('.').Trim()
Write-Host "Last digit of Version:"$version1[3]

if ($version1[3] -eq 0) {
    $finalVersion = $version1[0] + '.' + $version1[1] + '.' + $version1[2]
}

# Checking for trailing 0 for nuget packages
$infVersionSplit = $infVersion.split('.').Trim()
Write-Host "Last digit of Inf version:"$infVersionSplit[3]

if ($infVersionSplit[3] -eq 0) {
    $infVersion = $infVersionSplit[0] + '.' + $infVersionSplit[1] + '.' + $infVersionSplit[2]
}

Write-Host "Inf version to update to Nuspec:" $infVersion
Write-Host "Version to update to Nuspec:" $finalVersion

# Update NuSpec files
updateNuspecVersion -nuspecPath $implNuspec -finalVersion $finalVersion
updateNuspecVersion -nuspecPath $infNuspec -finalVersion $infVersion
updateNuspecVersion -nuspecPath $paNuspec -finalVersion $finalVersion
updateNuspecVersion -nuspecPath $testNuspec -finalVersion $finalVersion

Invoke-Expression "& `"$SyncDependentScript`" '$Repo' '$BaseRepoPath' '\CT_CompRegistry\Sample.target'"

# Commit & push changes
git add .
git commit -m "Updated Version"

if($IsProductBuild -eq $true) {
    Write-Host "ProductBuild is set to true, updating submodules..."
    git submodule update --init --recursive --remote
    git add .
    git commit -m "Automatic Submodule Update"
}

git push origin --delete $VersionBumpBranch
git fetch origin $Branch --depth=1 --no-tags --prune
git push --set-upstream origin $VersionBumpBranch

$CompRegFile = Test-Path -Path $TargetFilePath -PathType Leaf
if ($CompRegFile -eq $false) {
    Write-Host "Ignoring Product build as CompRegistry file is not found"
}

if (($CompRegFile -eq $true) -and ($IsProductBuild -eq $true)) {
    Write-Host "ProductBuild is set to true and CompRegistry file path was found"
    $CompRegistryXML = [xml](Get-Content -Path $TargetFilePath)
    $CompRegPackages = $CompRegistryXML.GetElementsByTagName("PackageReference")

    $InfComponentName = "$($Repo)Inf"

    $CompRegPackages | ForEach-Object {
        if ($_.Update -eq $InfComponentName) {
            $CompRegVersions = $_.Version.split('.')
            $CompRegInf = $CompRegVersions[0] + "." + $CompRegVersions[1]
            $InfVersions = $infVersion.split('.')
            $VersionInf = $InfVersions[0] + "." + $InfVersions[1]

            Write-Host "CompRegistry Inf Version:" $CompRegInf
            Write-Host "New Inf Version:" $VersionInf

            if ($CompRegInf -eq $VersionInf) {
                Write-Host "Inf version is in sync"
                $global:wasInfChanged = $false
            }
            else {
                Write-Host "Inf version is not in sync"
                $global:wasInfChanged = $true
            }
        }
    }
}

Write-Host "##vso[task.setvariable variable=updatedVersion;]$finalVersion"
Write-Host "##vso[task.setvariable variable=Version;isoutput=true]$NewVersion"
Write-Host "##vso[task.setvariable variable=FinalVersion;isoutput=true]$finalVersion"
Write-Host "##vso[task.setvariable variable=InfVersion;isoutput=true]$infVersion"
Write-Host "##vso[task.setvariable variable=HasInfChanged;isoutput=true]$hasInfChanged"
Write-Host "##vso[task.setvariable variable=WasInfChanged;isoutput=true]$wasInfChanged"