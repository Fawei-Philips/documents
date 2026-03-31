<#
    1. Here first we are getting list of absent .nupkg in variable absent_nupkg from previous module/script 
    2. Then we are finding all .nupkg files from location given by source_path and storing it into nupkg_name_list.
    3. If we found intersection between absent_nupkg and nupkg_name_list the upload that nupkg to artifactory. 
#>
class nupkg_uploader_module{
    [string]$upload_base_url
    [string]$artifactory_reponame
    [string]$internal_folder_name
    [string]$component_name
    [string]$state
    [string]$user_name
    [string]$token
    [string]$source_path

    nupkg_uploader_module($upload_base_url,$artifactory_reponame,$internal_folder_name,$component_name,$state,$user_name,$token,$nupkg_source_path){
        $this.upload_base_url = $upload_base_url
        $this.artifactory_reponame  = $artifactory_reponame
        $this.internal_folder_name  = $internal_folder_name
        $this.component_name= $component_name
        $this.state         = $state
        $this.user_name     = $user_name
        $this.token         = $token
        $this.source_path   = $nupkg_source_path
    }
#=======================================================================================
# Function to upload nupkg file to the artifactory
#=======================================================================================
    [void]upload_package($absent_nupkg){
        Write-Host "============== Uploading available .nupkg file to artifactory =============="
        try{

            $nupkg_abs_path_list = @()
            $nupkg_name_list = @()
            
            $nupkg_list =  Get-ChildItem -Path $this.source_path -Filter "*.nupkg" -Recurse
            $api_key = $this.user_name+":"+$this.token
            if($null -eq $nupkg_list){
                Write-Host "============================================================================================="
                Write-Host "There is no .nupkg file present on given location, which matches with existing .nuspec file"
                Write-Host "============================================================================================="
            }
            elseif($nupkg_list.count -eq 1){
                $nupkg_name_list += ($nupkg_list.Name)
                $nupkg_abs_path_list += ($nupkg_list.DirectoryName+"\"+$nupkg_list.Name)
            }
            else{
                for($i = 0; $i -lt $nupkg_list.count; $i++){
                    $nupkg_name_list += ($nupkg_list.Name[$i])
                    $nupkg_abs_path_list += ($nupkg_list.DirectoryName[$i]+"\"+$nupkg_list.Name[$i])
                }       
            }
            Write-Host "Total nuget packages present on loaction " $this.source_path $nupkg_list.Count
            foreach($nuget in $nupkg_name_list){
                Write-Host $nuget
            }
            #Write-Host $nupkg_name_list.Count "`n"

            for($i = 0; $i -lt ($nupkg_name_list.Count); $i++){
                $nuget_package = $nupkg_name_list[$i]
                if($absent_nupkg -contains $nuget_package){
                    Write-Host "Uploading nuget package $nuget_package"
                    #$component_name = Split-Path -Leaf (git remote get-url origin) #test  
                    #$artifactory_url =  $this.upload_base_url +"/"+$this.artifactory_reponame+"/"+$this.internal_folder_name+"/"+$this.component_name+"/"+$this.state
                    $artifactory_url =  $this.upload_base_url +"/"+$this.artifactory_reponame+"/"+$this.component_name+"/"+$this.state
                    Write-Host "Artifactory url :-  $artifactory_url"
                    Write-Host "Abs path pf package :- " $nupkg_abs_path_list[$i]
					[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
                    $upload_message = nuget push -Source $artifactory_url $nupkg_abs_path_list[$i] $api_key
                    Write-Host $upload_message
                    Write-Host "`n"
                }else{
                    Write-Host "Nuget package can not upload, as $nuget_package does not match with existing .nuspec file on local or package alredy present on artifactory."
                }  
            }
        }
        catch{
            Write-Host "Error Message: " $_.Exception.Message
            Write-Host "Error in Line: " $_.InvocationInfo.Line
            Write-Host "Error in Line Number: "$_.InvocationInfo.ScriptLineNumber
            Write-Host "##vso[task.complete result=Failed]Error detected"     
        }

    }
}

