<#
    DESCRIPTION:- This script will frist fetch all repos from tfs then based on repo name given by us
                  it will find that repo url and sets given branch name (develop) as default branch.

    Author :- shubham.patre@philips.com

    Example :- ./SetDefaultBranch.ps1 "TFS_PAT" "CTWORKSPACE_Repo" "develop" "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/IAP/_apis/git/repositories?api-version=5.0"
#>
$pat_token   = $args[0]
$repo_name   = $args[1]
$branch_name = $args[2]
$all_repo_api = $args[3]

try {
    $RepoUrl = ''
    $token = $pat_token
    $encodedPat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$token"))
    $AllRepo = Invoke-RestMethod  -method Get -Headers @{Authorization = "Basic $encodedPat"} -Uri $all_repo_api  -ContentType "application/json"

    $Count = $AllRepo.value.count
        for($i = 0; $i -lt $Count; $i++){
            if($AllRepo.value[$i].name -eq $repo_name){
                $RepoUrl = $AllRepo.value[$i].url
            }
        }
    $RepoUrl = $RepoUrl + '/?api-version=5.0'
    $repoBody = '{
        "defaultBranch": "refs/heads/'+$branch_name+'"
    }'
    $PRFilesPath = Invoke-RestMethod  -method Patch -Headers @{Authorization = "Basic $encodedPat"} -body $repoBody -Uri $RepoUrl  -ContentType "application/json"
    Write-Host $PRFilesPath
    Write-Host "Default branch set to " $branch_name
}
catch {
    Write-Host "Error Message: " $_.Exception.Message
    Write-Host "Error in Line: " $_.InvocationInfo.Line
    Write-Host "Error in Line Number: "$_.InvocationInfo.ScriptLineNumber
    Write-Host "##vso[task.complete result=Failed]Error detected"
}
