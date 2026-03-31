# Author: Vaibhav Garg (320219077)

# The script syncs changes between desired branch and base branch
# by creating and merging a Pull Request. 

# Usage: \create_merge_pr.ps1.ps1 <Region> <Project> <Repo> <Source> <Title> <Desc> <CommitMessage> <Auth>

# Options:
#  Region: Region name.
#  Project: Project name.
#  Repo: Repo name.
#  Source: Source branch name.
#  Target: Target branch name.
#  Title: PR Title.
#  Desc: PR Description.
#  CommitMessage: Merge commit message.
#  Auth: Rest API PAT from ADOS.
#  Tag: Tag name to be applied on the merge commit (Optional).

# Example: .\create_merge_pr.ps1.ps1 TPC_Region26 CT-GlobalSW TESTREPO feature-branch target-branch "Add feature" "Feature Desc" "AutoMerged feature-branch" "abcd"

param(
    [Parameter(Mandatory = $true, Position = 0)] [string]$Region,
    [Parameter(Mandatory = $true, Position = 1)] [string]$Project,
    [Parameter(Mandatory = $true, Position = 2)] [string]$Repo,
    [Parameter(Mandatory = $true, Position = 3)] [string]$Source,
    [Parameter(Mandatory = $true, Position = 4)] [string]$Target,
    [Parameter(Mandatory = $true, Position = 5)] [string]$Title,
    [Parameter(Mandatory = $false, Position = 6)] [string]$Desc = "",
    [Parameter(Mandatory = $false, Position = 7)] [string]$CommitMessage = "AutoMerged $Source",
    [Parameter(Mandatory = $true, Position = 8)] [string]$Auth,
    [Parameter(Mandatory = $false, Position = 9)] [string]$Tag = ""
)

try {
    $GitBaseURL = "https://tfsemea1.ta.philips.com/tfs/$Region/$Project/_apis/git/repositories/$Repo"
    
    $AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$Auth"))
    $Headers = @{"Authorization" = "Basic $AuthToken" }

    $RepositoryData = Invoke-RestMethod -Method Get -Uri $GitBaseURL -ContentType "application/json" -Headers $Headers
    
    Write-Host "Project name:" $RepositoryData.project.name
    Write-Host "Repository name:" $RepositoryData.name
    Write-Host "Target branch:" $Target

    Write-Host "`nCreating PR..."
    $ActivePRUrl = $RepositoryData._links.pullRequests.href + "?searchCriteria.targetRefName=refs/heads/$Target&searchCriteria.sourceRefName=refs/heads/$Source&api-version=5.0-preview"
    $ActivePRResponse = Invoke-RestMethod -Method Get -Uri $ActivePRUrl -ContentType "application/json" -Headers $Headers
    $ActivePRCount = $ActivePRResponse.count
    
    if (($ActivePRCount -ne 0)) {
        Write-Host "PR from $Source already exists."
        # throw
    }

    $PRUrl = $RepositoryData._links.pullRequests.href + "?api-version=5.0-preview"
    $PRData = "{`"sourceRefName`": `"refs/heads/$Source`", `"targetRefName`": `"refs/heads/$Target`", `"title`": `"$Title`", `"description`":`"$Desc`" }"
    Write-Host "Using PR params: `n" $PRData
    $PRResponse = Invoke-RestMethod -Method Post -Uri $PRUrl -Body $PRData -ContentType "application/json" -Headers $Headers
    Write-Host ($PRResponse | Out-String)
    Write-Host "`nPR Created with id:" $PRResponse.pullRequestId

    Write-Host "`nInitiating Merge..."
    $PollingInterval = 5
    $MaxRetries = 12
    $RetryCount = 1
    :RetryLoop while ($RetryCount -lt $MaxRetries) {
        $Url = "$($RepositoryData._links.pullRequests.href)/$($PRResponse.pullRequestId)?api-version=5.0-preview"
        $response = Invoke-RestMethod -Method Get -Uri $Url -Headers $Headers -ContentType "application/json"
        switch ($response.mergeStatus) {
            "notSet" {
                Write-Host "PR not ready yet. Retrying ($RetryCount/$MaxRetries)..."
                $RetryCount++
                break
            }
            "queued" {
                Write-Host "PR not ready yet. Retrying ($RetryCount/$MaxRetries)..."
                $RetryCount++
                break
            }
            "succeeded" {
                Write-Host "PR is active. Proceeding with merge..."
                break RetryLoop 
                
            }
            "conflicts" {
                Write-Error "There were conflicts in the PR created." -ErrorAction Stop
                break RetryLoop
            }
            "failure" {
                Write-Error "There were issues in the PR created." -ErrorAction Stop
                break RetryLoop
            }
            "rejectedByPolicy" {
                Write-Error "There were issues in the PR created." -ErrorAction Stop
                break RetryLoop
            }
            Default {}
        }
        Start-Sleep -Seconds $PollingInterval
    }
    Write-Host "`nMerging PR..."

    $PRMergeUrl = "$($RepositoryData._links.pullRequests.href)/$($PRResponse.pullRequestId)?api-version=5.0-preview"
    $PRMergeData = "{`"status`" : `"completed`",`"completionOptions`": {`"bypassPolicy`": true,`"bypassReason`": `"force`",`"deleteSourceBranch`": true,`"mergeCommitMessage`": `"$CommitMessage`",`"transitionWorkItems`": false},`"LastMergeSourceCommit`": {`"commitId`": `"$($PRResponse.lastMergeSourceCommit.commitId)`"} }"
    Write-Host "Using merge params: `n" $PRMergeData
    $MergeResponse = Invoke-RestMethod -Method Patch -Uri $PRMergeUrl -Body $PRMergeData -Headers $Headers -ContentType "application/json"
    
    if ($Tag -ne "") {
        Start-Sleep -Seconds 2
        $PRData = Invoke-RestMethod -Method Get -Uri $PRMergeUrl -Headers $Headers -ContentType "application/json"
        $MergeCommitId = $PRData.lastMergeCommit.commitId
        try {
            Write-Host "`nApplying tag '$Tag' to merge commit..."
            if (($MergeCommitId -eq "") -or ($null -eq $MergeCommitId)) {
                Write-Host "Merge commit id not found. Please check if the PR was merged correctly."
                throw
            }
            $TagUrl = "$GitBaseURL/annotatedtags?api-version=5.0-preview"
            $TagData = "{`"name`": `"$Tag`", `"taggedObject`": {`"objectId`": `"$MergeCommitId`", `"objectType`": `"commit`" }, `"message`": `"auto-applied tag after auto-merge`" }"
            Write-Host "Using tag params: `n" $TagData
            $TagResponse = Invoke-RestMethod -Method Post -Uri $TagUrl -Body $TagData -Headers $Headers -ContentType "application/json"
            Write-Host ($TagResponse | Out-String)

            if ($TagResponse.objectId) { Write-Host "`nTag applied to merge commit." }
            else { throw }
        }
        catch {
            Write-Host $Error[0]
            Write-Host "##vso[task.logissue type=warning;]Reason: Error applying tag to merge commit."
            Write-Host "##vso[task.complete result=SucceededWithIssues;]Reason: Error applying tag to merge commit."
            Write-Host "`nError applying tag to merge commit."
        }
    }


    Write-Host ($MergeResponse | Out-String)
    Write-Host "`nMerge attempt was successful."
    return 0
}
catch {
    Write-Host $Error[0]
    Write-Error "`nError: There were some errors creating & merging the PR. Please check the logs above for more details."
    return 1
}
