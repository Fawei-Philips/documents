<#
    DESCRIPTION:- This script will set the branch policies for the master as well as newly 
                  created branch with gievn name (main) in the given repo

    Author :- shubham.patre@philips.com

    Example :- ./BranchPolicies.ps1 "main" "CTWORKSPACE_Repo" "TFS_PAT" "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/CT-GlobalSW/_apis/git/repositories?api-version=5.0" "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/CT-GlobalSW/_apis/policy/Configurations?api-version=5.0"
#>

using module .\BranchPolicy_json.psm1

$branch_name   = $args[0]
$repo_name     = $args[1] 
$pat_token     = $args[2]
$all_repo_api  = $args[3]
$policy_set_api =$args[4]

try{
    $jsonBody = ''
    $repoid   = ''
    $refName  = ''
    $policyid = ''
    $displayname = ''
    $policyid_list = @('fa4e907d-c16b-4a4c-9dfa-4906e5d171dd', 'c6a1889d-b943-4856-b76f-9e46bb6b0df2','fa4e907d-c16b-4a4c-9dfa-4916e5d171ab')
    $policyname_list = @('Minimum number of reviewers', 'Comment requirements', 'Require a merge strategy')
    $all_branches = $branch_name, 'master'

    $token = $pat_token
    $encodedPat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$token"))
    $AllRepo = Invoke-RestMethod  -method Get -Headers @{Authorization = "Basic $encodedPat"} -Uri $all_repo_api  -ContentType "application/json"

    $Count = $AllRepo.value.count
    for($i = 0; $i -lt $Count; $i++){
        if($AllRepo.value[$i].name -eq $repo_name){
            $repoid = $AllRepo.value[$i].id
            break
        }
    }

    for($i = 0; $i -lt $policyid_list.Count; $i++){
        for($j = 0; $j -lt $all_branches.Count; $j++){
            if($j -eq 0){
                $refName = $all_branches[$j]
                $displayname = $policyname_list[$i]
                $policyid = $policyid_list[$i]
            } else {
                $refName = $all_branches[$j]
                $displayname = $policyname_list[$i]
                $policyid = $policyid_list[$i]
            }
            if($displayname -eq "Minimum number of reviewers"){
                $json_obj = [BranchPolicy_json]::New($refName, $repoid, $policyid)
                $jsonBody = $json_obj.minimum_number_of_reviewers()
            }

            if($displayname -eq "Comment requirements"){
                $json_obj = [BranchPolicy_json]::New($refName, $repoid, $policyid)
                $jsonBody = $json_obj.comment_requirements()
            }

            if($displayName -eq "Require a merge strategy"){
                $json_obj = [BranchPolicy_json]::New($refName, $repoid, $policyid)
                $jsonBody = $json_obj.require_a_merge_strategy()
            }         
            Invoke-RestMethod  -method Post -Uri $policy_set_api -Body $jsonBody  -ContentType "application/json" -Headers @{Authorization = "Basic $encodedPat"}
        }
    }
    Write-Host "All Branch policies has been set"
}
catch{
Write-Host "Error Message: " $_.Exception.Message
Write-Host "Error in Line: " $_.InvocationInfo.Line
Write-Host "Error in Line Number: "$_.InvocationInfo.ScriptLineNumber
Write-Host "##vso[task.complete result=Failed]Error detected"
}
