#=============================================================================================================
# Get all .nuspec files from given folder then get id and version from that file.
# Then checking any .nupkg available on artifactory with extracted version and id.
#=============================================================================================================
 
 param(
    [Parameter(Mandatory = $true)] [string]$BaseDir,
    [Parameter(Mandatory = $true)] [string]$Workspace,
    [Parameter(Mandatory = $true)] [string]$user_name,
    [Parameter(Mandatory = $true)] [string]$token,
    [Parameter(Mandatory = $true)] [string]$RepoName
)
 
 $raw_nuspec_file_list =  Get-ChildItem $BaseDir\Build\Pkg\Nuget -Filter "*.nuspec" -Recurse
 $nuspec_file_path_list = @()
 $AuthToken = $user_name +":"+$token
  
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

Write-Host "============== Extract version and Id and check if nuspec package already exists =============="
            for($i = 0; $i -lt $nuspec_file_path_list.Length; $i++){
                [xml]$xml_doc  = Get-Content $nuspec_file_path_list[$i]
				$version = $xml_doc.package.metadata.version
                $Id = $xml_doc.package.metadata.id
                Write-Host $version
                Write-Host $Id

                $Query = Invoke-Expression "$BaseDir\Build\CI\CT_CICD\3rdParty\scripts\artifactory_query.ps1 '$Workspace' '$Id' '$version' '' $AuthToken"
                Write-Host "Query" $Query.name.count

                if($Query.name.count -gt 0){
	             Write-Host "Artifacts for Nuspec $Id and its version $version already exists in Artifactory, exiting..." -ForegroundColor Red
	            throw
                }else{
                 Write-Host "Artifacts for Nuspec $Id and its version $version Not exists in Artifatory"
                }
            }
               
Write-Host "============== Query to check if Msi already exists =============="
              $Query = Invoke-Expression "$BaseDir\Build\CI\CT_CICD\3rdParty\scripts\artifactory_query.ps1 'ct-workspace-generic' '$RepoName' '$version' '' $AuthToken"
               Write-Host "Query" $Query.name.count

               if($Query.name.count -gt 0){
	            Write-Host "MSI for Component $RepoName and its version $version already exists in Artifactory, exiting..." -ForegroundColor Red
	            throw
                }            
