<#
    DESCRIPTION:- This script create the new branch in the existing repo and push the changes to tfs

    Author :- shubham.patre@philips.com

    Example :- ./BranchCreator.ps1" "C:\Users\320003019\Desktop\Repo" "Develop"
#>

$dest_path   = $args[0]
$branch_name = $args[1]

try{
    Set-Location $dest_path
    git config --global credential.helper wincred
    git branch $branch_name
    git checkout $branch_name
    git push --set-upstream origin $branch_name
    Write-Host "New Branch Created with the name " $branch_name
}
catch{
    Write-Host "Error Message: " $_.Exception.Message
    Write-Host "Error in Line: " $_.InvocationInfo.Line
    Write-Host "Error in Line Number: "$_.InvocationInfo.ScriptLineNumber
    Write-Host "##vso[task.complete result=Failed]Error detected"
}
