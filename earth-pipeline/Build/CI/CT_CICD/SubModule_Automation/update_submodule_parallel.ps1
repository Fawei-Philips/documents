# Author:   Vaibhav Garg (320219077)
#           Shubham Srivastava (320218605)

# The script updates submodules in the listed repositories 
# for the desired branches listed in given config file.

# NOTE: Script requires git 2.39.2.windows.1 or above to work
# To override git used by agent software bundle (can be lower than required),
# and use git installed on the agent, set a pipeline variable named 
# System.PreferGitFromPath to true in your pipeline.

[CmdletBinding()]
param( 
    [Parameter(Mandatory = $true, Position = 0)][string]$ConfigFilePath = (Write-Error "Parameter ConfigFilePath can not be empty, exiting..." -ErrorAction Stop),
    [Parameter(Mandatory = $true, Position = 1)][string]$PAT = (Write-Error "Parameter PAT can not be empty, exiting..." -ErrorAction Stop),
    [Parameter(Mandatory = $true, Position = 2)][string]$RootPath = (Write-Error "Root path can not be empty, exiting..." -ErrorAction Stop)
)

if (-Not(Test-Path $ConfigFilePath)) {
    Write-Error "Could not find the Config file, exiting..." -ErrorAction Stop
}

[xml]$Config = Get-Content -Path $ConfigFilePath
$Repolist = $Config.config.ChildNodes

$faliure_flag = 0
$failed_repos = @()

$UpdateSubmodule = {
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory = $true, Position = 0)][string]$RepoName,
        [Parameter(Mandatory = $true, Position = 1)][string]$Branch,
        [Parameter(Mandatory = $true, Position = 2)][string]$PAT,
        [Parameter(Mandatory = $true, Position = 3)][string]$ScriptRoot,
        [Parameter(Mandatory = $true, Position = 4)][string]$RootPath
    )
    Write-Host "Updating: " $RepoName $Branch

    $RandomBuild = "$(New-Guid)".Split("-")[0]
    $RemoteURL = "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/CT-GlobalSW/_git/$RepoName"
    $PRName = "Devops-Update-Submodule-$RandomBuild"

#    $TempPath = [System.Environment]::GetEnvironmentVariable('Temp', 'User')
    $TempPath = "$RootPath\s\SubModule"
    if (-not (Test-Path $TempPath))
    {
        New-Item -Path $TempPath -ItemType Directory 
    }
    $RepoPath = "$TempPath/$RandomBuild-$RepoName"
    New-Item -Path $RepoPath -ItemType Directory | Out-Null
    Set-Location $RepoPath
    
    $env:GIT_REDIRECT_STDERR = '2>&1'

    git init
    git remote add -t $Branch origin $RemoteURL
    git fetch --depth=1
    git config core.sparseCheckout true
    git sparse-checkout set ".gitmodules"
    git pull origin $Branch
    git checkout $Branch
    git submodule update --init --remote --depth=1 --recommend-shallow --single-branch
    git push origin -d $PRName
    git checkout -B $PRName
    git add --sparse .
    git commit -m "Automatic Submodule Update"
    git push --set-upstream origin $PRName

    $PRScriptLocation = Join-Path $ScriptRoot "..\scripts\create_merge_pr.ps1"

    $IsPRMergeSuccess = Invoke-Expression "&`"$PRScriptLocation`" 'TPC_Region26' 'CT-GlobalSW' '$RepoName' '$PRName' '$Branch' 'Update Submodule' 'Auto update Submodule' 'AutoMerged Update Submodule' '$PAT'"
    if ($IsPRMergeSuccess -ne 0) {
        throw "PR Merge failed."
    }

    # If the PR does not get merged, this is skipped and cleanup does not happen

    Set-Location $ScriptRoot

    try {
        Remove-Item $RepoPath -Force -Recurse
        Write-Host "clean repo path completed: $RepoPath"
    } catch {
        Write-Warning "clean repo path failed: $RepoPath, error message: $($_.Exception.Message)"
    }
}

Get-Job | Remove-Job

$MaxThreads = 10
$StartedIds = @()

$StartTime = (Get-Date)

$ScriptRoot = $PSScriptRoot

$Repolist | ForEach-Object {
    $RepoName = $_.name;
    $Branches = $_.branches.branch

    $Branches | ForEach-Object {
        $Branch = $_
        try {
            while ($(Get-Job -State Running).ChildJobs.Count -gt $MaxThreads) {
                Start-Sleep -Milliseconds 5
            }

            $startJob = Start-Job -Name "$RepoName|$Branch" -ScriptBlock $UpdateSubmodule -ArgumentList $RepoName, $Branch, $PAT, $ScriptRoot, $RootPath
            
            Write-Host "Started" $startJob.Name $startJob.Id
            $StartedIds += , $startJob.Id
        }
        catch {
            $faliure_flag += 1
            Write-Host $Error[0]
            $failed_repos += $RepoName
        }
    }
}

foreach ($id in $StartedIds) {
    $waitingJob = Wait-Job -Id $id
    Write-Host "Job Id completed" $waitingJob.Id
}

foreach ($job in Get-Job) {
    try {
        $info = Receive-Job -Id ($job.Id)
        Write-Host $info
    }
    catch {
        $faliure_flag += 1
        Write-Host $Error[0]
        $failed_repos += $job.Name
    }
}

if ($faliure_flag -gt 0) {
    Write-Host "Could not update submodules for these repos: "
    foreach ($element in $failed_repos) {
        Write-Host $element
    }
}
$EndTime = (Get-Date)
Write-Host "`nTotal time taken" (New-TimeSpan -Start $StartTime -End $EndTime)


Set-Location $PSScriptRoot
