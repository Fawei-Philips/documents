<#
    1. Here task is to download given .nupkg or .zip or .cab file from artifactory.
    2. To download package we are using an API call and for an API we are construction URL
       dynamically by using user given arguments
#>

$base_url      = $args[0] #"https://artifactory.pic.philips.com:8443/artifactory"
$repo_name     = $args[1] #"dinxgenhost-local-nuget" #"dinxgenhost-local-release"
$internal_comp_name = $args[2] #"nxgen-internal" #"Develop"
$component_name= $args[3] #"Automation/Initial" #"Initial"
$package_name  = $args[4] #"CTA.Platform.2.0.0.45.nupkg"#"340512.zip"
$artifactory_PAT = $args[5]    # artifactory pat
$destination_path= $args[6] #'C:/Users/320103928/Work/CD_PipelineTask/'

try{    
    $artifactory_url = $base_url+"/"+$repo_name+"/"+$internal_comp_name +"/"+$component_name+"/"+$package_name
    Write-Host "URL to download $package_name :- " $artifactory_url
    $token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($artifactory_PAT))
    $destination_path = $destination_path + $package_name
    Invoke-RestMethod -Uri $artifactory_url -Headers @{Authorization = "Basic $token"} -Method Get -ContentType application/zip -OutFile $destination_path
}
catch{
    Write-Host "Error Message: " $_.Exception.Message
    Write-Host "Error in Line: " $_.InvocationInfo.Line
    Write-Host "Error in Line Number: "$_.InvocationInfo.ScriptLineNumber
    Write-Host "##vso[task.complete result=Failed]Error detected"
}
