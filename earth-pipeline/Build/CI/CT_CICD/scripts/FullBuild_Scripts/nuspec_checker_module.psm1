<#
    1.Here we are finding all .nuspec files from location given by source_path and constructing 
      name of .nupkg (Ex.NUnit.3.10.1.nupkg) and then checking whether the .nupkg file corresponding 
      to given .nuspec file that we found from source_path is/are present on artifactory or not.

    2. To check availability of .nupkg on artifactory we are constructing API URL dynamically using url
       parameters taken as arguments.
#>
class nuspec_checker_module{
    [string]$artifactory_base_url
    [string]$artifactory_reponame
    [string]$folder_name
    [string]$component_name
    [string]$state
    [string]$user_name
    [string]$token
    [string]$source_path

    nuspec_checker_module($validate_artifactory_base_url,$artifactory_reponame,$internal_folder_name,$component_name,$state,$user_name,$token,$nuspec_source_path){
        $this.artifactory_base_url = $validate_artifactory_base_url
        $this.artifactory_reponame  = $artifactory_reponame
        $this.folder_name   = $internal_folder_name
        $this.component_name= $component_name
        $this.state         = $state
        $this.user_name     = $user_name
        $this.token         = $token
        $this.source_path   = $nuspec_source_path
    }
    [array]get_missing_nupkg_from_artifactory(){
        #=============================================================================================================
        # Geting all .nuspec files from given folder then get id and version from that file
        #=============================================================================================================
        $version_and_id = @()
        try{
            $raw_nuspec_file_list =  Get-ChildItem $this.source_path -Filter "*.nuspec" -Recurse
            $nuspec_file_path_list = @()
            $absent_nupkg = @()
            
            if($raw_nuspec_file_list.count -eq 0){
                Write-Host "============== No .nuspec file present =============="
                return $nuspec_file_path_list
            } 
            elseif($raw_nuspec_file_list.count -eq 1){
                $nuspec_file_path_list += $raw_nuspec_file_list.DirectoryName+"\"+$raw_nuspec_file_list.Name
            }
            else {
                for($i = 0; $i -lt $raw_nuspec_file_list.Length; $i++){
                    $nuspec_file_path_list += ($raw_nuspec_file_list.DirectoryName[$i]+"\"+$raw_nuspec_file_list.Name[$i])
                }
            }
        
            Write-Host "============== List of .nuspec files =============="
            foreach($file_name in $nuspec_file_path_list){
                Write-Host $nuspec_file_path_list
            }
            Write-Host "============== Version and id from nuspec files =============="
            for($i = 0; $i -lt $nuspec_file_path_list.Length; $i++){
                [xml]$xml_doc  = Get-Content $nuspec_file_path_list[$i]
                $version_and_id += $xml_doc.package.metadata.id+"."+$xml_doc.package.metadata.version
            }
            foreach($pkg in $version_and_id){
                Write-Host $pkg
            }
            Write-Host "`n"
            #===================================================================
            # Checking if packge is available on artifactory or not
            #===================================================================
            #$component_name = Split-Path -Leaf (git remote get-url origin) #test
            $artifactory_url =  $this.artifactory_base_url+"/"+$this.artifactory_reponame+"/"+$this.component_name+"/"+$this.state
            #$artifactory_url =  $this.artifactory_base_url+"/"+$this.folder_name+"/"+$this.component_name+"/"+$this.state

            Write-Host "Articaftory url :- $artifactory_url"
            
            $user_name_temp = $this.user_name
            Write-Host "user name : $user_name_temp"

            $user_token_temp = $this.token
            Write-Host "user token : $user_token_temp"

            $encripted_token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($this.user_name+":"+$this.token))
            $response = Invoke-RestMethod -Uri $artifactory_url -Headers @{Authorization = "Basic $encripted_token"} -Method Get -ContentType application/json
            
            
            $package_found_on_artifactory = @()
            Write-Host "List of packages present on artifactory:-"
            for($i = 0; $i -lt $response.children.count; $i++){
                $nuget_pkg = $response.children[$i].uri.Substring(1)
                Write-Host $nuget_pkg
                $package_found_on_artifactory += $nuget_pkg
            }

            foreach($pkg in $version_and_id){
                $package_name = $pkg + ".nupkg"
                if($package_found_on_artifactory -notcontains $package_name){
                    $absent_nupkg += $package_name
                }
            }
            Write-Host "`n"
            Write-Host "====== List of .nupkg files which are not present on artifactory but corresponding .nuspec file present ======"
            #>
            return $absent_nupkg
            
        }
        catch{
            $absent_nupkg = @()
            if($_.Exception.Response.StatusCode -eq "NotFound"){
                foreach($pkg in $version_and_id){
                    $package_name = $pkg + ".nupkg"
                    #if($package_found_on_artifactory -notcontains $package_name){
                    $absent_nupkg += $package_name
                    #}
                }
                return $absent_nupkg
            }
            else {
                Write-Host "Error Message: " $_.Exception.Message
                Write-Host "Status code : " $_.Exception.Response.StatusCode
                Write-Host "Error in Line: " $_.InvocationInfo.Line
                Write-Host "Error in Line Number: "$_.InvocationInfo.ScriptLineNumber
                Write-Host "##vso[task.complete result=Failed]Error detected"
                return $null                    
            }
        }
    }     
}