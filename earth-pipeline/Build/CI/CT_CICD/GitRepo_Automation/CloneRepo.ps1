<#
    DESCRIPTION:- This script first clone newly created repo in location given by destination_path
                  Then it copies repo template from given source path to the cloned repo folder in above step
                  Then push it to the TFS
    Author :- shubham.patre@philips.com
    Example :- ./CloneRepo.ps1 "//INGBTCPIC6DT258/Logs_for_automation_Report/Repo_Template" "C:\Users\320003019\Desktop\Repo" "CTWORKSPACE_Repo" "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/IAP/_git/"
#>
$source_path      = $args[0]
$destination_path = $args[1]
$repo_name        = $args[2]
$clone_repo_api   = $args[3]

try{
    mkdir $destination_path
    Set-Location $destination_path
    $repo_url =  $clone_repo_api + $repo_name
    git config --global credential.helper wincred
    git clone $repo_url $destination_path

    $destination_path = $destination_path + "/"
    $source_path = $source_path + "/*"
    Copy-Item -Path $source_path -Destination $destination_path -Recurse -Force
    Start-Sleep -s 20

    git add .
    git commit -m "Auto Repo Creation based on CT-WORKSPACE template"
    git push
    Write-Host "Repo cloned from TFS and Repo template files are copied and pushed"
}
catch{
    Write-Host "Error Message: " $_.Exception.Message
    Write-Host "Error in Line: " $_.InvocationInfo.Line
    Write-Host "Error in Line Number: "$_.InvocationInfo.ScriptLineNumber
    Write-Host "##vso[task.complete result=Failed]Error detected"
}
