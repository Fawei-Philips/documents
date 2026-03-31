<#
    DESCRIPTION:- This Script to create new Repo on TFS given url with the given repo name
    Author :- shubham.patre@philips.com
    Example :- ./RepoCreator.ps1 "TFS_PAT" "CTWORKSPACE_Repo" "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/IAP/_apis/git/repositories?api-version=5.0"
#>
$pat_token = $args[0]
$repo_name = $args[1]
$all_repo_api = $args[2]

try{
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $token = $pat_token
    $encodedPat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$token"))

    $repoBody = @{
        name = $repo_name
    } | ConvertTo-Json

    $PRFilesPath = Invoke-RestMethod  -method Post -Headers @{Authorization = "Basic $encodedPat"} -body $repoBody -Uri $all_repo_api  -ContentType "application/json"
    $PRFilesPath
    Write-Host "New Repo created with the name " $repo_name
}
catch{
    Write-Host "Error Message: " $_.Exception.Message
    Write-Host "Error in Line: " $_.InvocationInfo.Line
    Write-Host "Error in Line Number: "$_.InvocationInfo.ScriptLineNumber
    Write-Host "##vso[task.complete result=Failed]Error detected"
}
