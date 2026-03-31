# Author:   Vaibhav Garg (320219077)
#           Shubham Srivastava (320218605)

# The script updates submodules in the listed repositories 
# for the desired branches listed in config.xml file.

[CmdletBinding()]
param( 
    [Parameter(Mandatory = $true, Position = 0)][string]$ConfigFilePath,
    [Parameter(Mandatory = $true, Position = 1)][string]$PAT
)

[xml]$Config = Get-Content -Path $ConfigFilePath

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

$Repolist = $Config.config.ChildNodes
$AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$PAT"))
$Headers = @{"Authorization" = "Basic $AuthToken" }
$TempLocation = "D:\CloneRepos" 
$PRName = 'Devops-Integrator-Update-Submodule'
$DefaultScriptRoot = $PSScriptRoot;
if(Test-Path -Path "D:\CloneRepos"){
  Set-Location "D:\"
  Remove-Item D:\CloneRepos\* -Recurse -Force
}

$flag=0
$a = @()
foreach ($Repo in $Repolist) {
        $RepoName = $Repo.name;
        $BaseURL = "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/CT-GlobalSW/_apis/git/repositories/"
        $GitURL = $BaseURL + $RepoName
        try {
            $RepoData = Invoke-RestMethod -Method Get -Uri $GitURL -ContentType "application/json" -Headers $Headers
            $RemoteURL = $RepoData.remoteURL
            $DefaultBranchRef = $RepoData.defaultBranch
            $DefaultBranch = $DefaultBranchRef.Split('/')[2]
            $Branches = $Repo.branches.branch 
        }
        catch {
            Write-Debug $Error[0]
            throw "Error fetching data from: $GitURL"
        }
        
        foreach ($Branch in $Branches) {
            try {
                $CloneLocation = Join-Path $TempLocation $RepoName
                $env:GIT_REDIRECT_STDERR = '2>&1'
                Write-Host "`n Working on branch: " $Branch
                mkdir $CloneLocation | Out-Null
                ExecuteSyncProcess "git" "-c http.extraHeader=`"Authorization:Basic $AuthToken`" clone --recurse-submodules -b $Branch $RemoteURL $CloneLocation"
                Set-Location $CloneLocation            
                Write-Host "Updating submodules..."
                ExecuteSyncProcess "git" "-c http.extraHeader=`"Authorization:Basic $AuthToken`" submodule update --remote"     
        
                Write-Host "Commiting changes..."
                ExecuteSyncProcess "git" "-c http.extraHeader=`"Authorization:Basic $AuthToken`" commit -a -m `"Automatic Submodule Update`""
                
                ExecuteSyncProcess "git" "branch -D $PRName"
                
                ExecuteSyncProcess "git" "-c http.extraHeader=`"Authorization:Basic $AuthToken`" checkout -b $PRName"
                
                ExecuteSyncProcess "git" "-c http.extraHeader=`"Authorization:Basic $AuthToken`" pull origin $DefaultBranch"
                
                ExecuteSyncProcess "git" "-c http.extraHeader=`"Authorization:Basic $AuthToken`" pull origin $PRName"
                
                ExecuteSyncProcess "git" "-c http.extraHeader=`"Authorization:Basic $AuthToken`" push --set-upstream origin $PRName"
                
                $PRScriptLocation = Join-Path $DefaultScriptRoot "..\scripts\create_merge_pr.ps1"
                Write-Host $PRScriptLocation
                $IsPRMergeSuccess = Invoke-Expression "&`"$PRScriptLocation`" 'TPC_Region26' 'CT-GlobalSW' '$RepoName' '$PRName' '$Branch' 'Update Submodule' 'Auto update Submodule' 'AutoMerged Update Submodule' '$PAT'"
                if ($IsPRMergeSuccess -ne 0) {
                    throw "PR Merge failed."
                }
                Set-Location "D:\"
                Remove-Item D:\CloneRepos\* -Recurse -Force
                Write-Host "Updated Submodule for $Branch"
            }
            catch {
                $flag=1
                Write-Host $Error[0]
                $a += $RepoName
            }
                
        }
}
if($flag -eq 1){
    Write-Host "The Submodule update could not be done for these repos: "
    foreach($element in $a){
        Write-Host $element
    }
}
