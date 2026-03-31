param(
    [Parameter(Mandatory = $true)] [string]$upload_base_url,
    [Parameter(Mandatory = $true)] [string]$artifactory_reponame,
    [Parameter(Mandatory = $true)] [string]$internal_folder_name,
    [Parameter(Mandatory = $true)] [string]$state,
    [Parameter(Mandatory = $true)] [string]$user_name,
    [Parameter(Mandatory = $true)] [string]$token,
    [Parameter(Mandatory = $true)] [string]$nupkg_source_path,
    [Parameter(Mandatory = $true)] [string]$component_name,
    [Parameter(Mandatory = $true)] [string]$nuspecversion
)
try {
    $nupkg_abs_path_list = @()
    $nupkg_name_list = @()
    $baseURL = [System.Uri]$upload_base_url
    $uploadUrl = $baseURL.GetLeftPart([System.UriPartial]::Authority) + "/" + "artifactory"
    $nupkg_list = Get-ChildItem -Path $nupkg_source_path -Filter "*.nupkg" -Recurse
    $api_key = $user_name + ":" + $token
    $AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($api_key))
    if ($null -eq $nupkg_list) {
        Write-Host "============================================================================================="
        Write-Host "There is no .nupkg file present on given location, which matches with existing .nuspec file"
        Write-Host "============================================================================================="
    }
    elseif ($nupkg_list.count -eq 1) {
        $nupkg_name_list += ($nupkg_list.Name)
        $nupkg_abs_path_list += ($nupkg_list.DirectoryName + "\" + $nupkg_list.Name)
    }
    else {
        for ($i = 0; $i -lt $nupkg_list.count; $i++) {
            $nupkg_name_list += ($nupkg_list.Name[$i])
            $nupkg_abs_path_list += ($nupkg_list.DirectoryName[$i] + "\" + $nupkg_list.Name[$i])
        }       
    }
    Write-Host "Total nuget packages present on loaction " $nupkg_source_path $nupkg_list.Count
    foreach ($nuget in $nupkg_name_list) {
        Write-Host $nuget
    }

    for ($i = 0; $i -lt ($nupkg_name_list.Count); $i++) {
        $nuget_package = $nupkg_name_list[$i]
        Write-Host "Uploading nuget package $nuget_package"
        $artifactory_url = $uploadUrl + "/" + $artifactory_reponame + "/" + $internal_folder_name + "/" + $nuspecversion + "/" + $state + "/"
        Write-Host "Artifactory url :-  $artifactory_url"
        Write-Host "Abs path pf package :- " $nupkg_abs_path_list[$i]
        $Pushable = @{
            "Path" = $nupkg_abs_path_list[$i]
            "URI"  = $artifactory_url
        }
        Get-ChildItem -Path $Pushable["Path"] | ForEach-Object {
            Write-Host "Processing: $_"
            Get-ChildItem -Path $_ -File | ForEach-Object {
                Write-Host "Pushing: $_"
                try {
                    $File_URI = "$($Pushable["URI"])$($_.Name);nuget.version=$nuspecversion"
                    $WebClient = New-Object System.Net.WebClient  
                    $WebClient.Credentials = New-Object System.Net.NetworkCredential("$Usr", "$Pwd")  
                    $URI = New-Object System.Uri($File_URI)
                    $METHOD = "PUT" 
                    $WebClient.Headers.Add("Authorization", "Basic " + $($AuthToken))
                    $WebClient.Headers.add("Content-Type", "application/octet-stream")
                    $loca = (Get-LocalUser).Path + $Pushable["Path"]
                    Write-Host "Location.$loca"
                    $WebClient.UploadFile($URI, $METHOD, $loca) 
                    Write-Host "Pushed: $_" -ForegroundColor Green
                    Write-Host "Pushing nuget package completed." -ForegroundColor Cyan
                }
                catch {
                    Write-Host $Error[0]
                    Write-Host "Could not push: $_" -ForegroundColor Red
                }
            }
        }   
    }
}
catch {
    Write-Host "Error Message: " $_.Exception.Message
    Write-Host "Error in Line: " $_.InvocationInfo.Line
    Write-Host "Error in Line Number: "$_.InvocationInfo.ScriptLineNumber
    Write-Host "##vso[task.complete result=Failed]Error detected"     
}