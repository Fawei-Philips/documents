param(
  
	[string]$Auth = (Write-Error "Auth not provided, exiting..." -ErrorAction Stop),
	[string]$RepoName = "default"   
)
$PipelineRunsIds = [System.Collections.ArrayList]@()

$AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$Auth"))
$Headers = @{"Authorization" = "Basic $AuthToken" }

if (-not [string]::IsNullOrEmpty($RepoName) -and -not "default") {
	Write-Output "Starting product build from $RepoName"			
}
		
function InvokePipeline { 	
	Write-Output "Inside InvokePipeline method"
	Write-Output $Auth
	$ApiVersionParam = "?api-version=6.0-preview"
	$RepoPipelineBaseUrl = "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/CT-GlobalSW/_apis/pipelines/"		
	Authenticate -Url $RepoPipelineBaseUrl		

	# Find and update the object using Where-Object
	$index = 0
	if ($RepoName -ne "default") {	
		Write-Output "Inside if"		
		$startrepo = $PipelineRunsIds | ForEach-Object { $_ } | Where-Object { $_.Name -eq $RepoName } 
		$index = $PipelineRunsIds.IndexOf($startrepo)
	}	
	else {
		Write-Output "Inside else"
	}

	if ($null -ne $index) {
		Write-Output "The index of the start repo $RepoName is $index."
	} 
	else {
		Write-Output "Start repo $RepoName not found in the RepoList.xml. So exiting.."
		Write-Error "Pipeline:" $PipelineRunsIds.Name " failed" -ErrorAction Stop 
	}
	Write-Output  "Length of array " $PipelineRunsIds.Count
	for ($i = $index; $i -lt $PipelineRunsIds.Count; $i++) {

		$LockScriptLocation = Join-Path $PSScriptRoot "..\scripts\lock_unlock_branch.ps1"
        $IsLockSuccess = Invoke-Expression "& `"$LockScriptLocation`" 'TPC_Region26' 'CT-GlobalSW' 'CT_CompRegistry' 'master' 1 '$Auth'"

		#foreach ($RepoTable in $PipelineRunsIds)							
		$RepoTable = $PipelineRunsIds[$i]
		$pipelineId = $RepoTable.PipelineId		
		$repoName = $RepoTable.Name

		$refsName = "refs/heads/main"

		if ($repoName -eq "CT_CompRegistry"){
			$refsName = "refs/heads/master"
		}


        		
		Write-Output "Repo Name:" $repoName " Pipeline Id:" $pipelineId 			
		$RepoPipelineUrl = "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/CT-GlobalSW/_apis/pipelines/$pipelineId/runs?api-version=6.0-preview"        
		try {
			$params = @{
			 "resources" = @{
				 "repositories" = @{
						"self" = @{
							"refName" = $refsName;
						}
					}
				}
            
			};
					
			$PipelineRunData = Invoke-RestMethod -Method Post -Uri $RepoPipelineUrl -ContentType "application/json" -Headers $Headers -Body ($params | ConvertTo-Json -Depth 100 -Compress | Out-String)
			Write-Host "Run Id: $($PipelineRunData.id) `nWebLink: $($PipelineRunData._links.web.href)"			
			$runId = $PipelineRunData.id
			
			$runUrl = "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/CT-GlobalSW/_apis/pipelines/$pipelineId/runs/$runId" + $ApiVersionParam
			Write-Output $runUrl
			while ($true) {	
				$AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$Auth"))
				$Headers = @{"Authorization" = "Basic $AuthToken" }
				$runData = Invoke-RestMethod -Method Get -Uri $runUrl -ContentType "application/json" -Headers $Headers				
				if ($runData.state -eq "completed" -and $runData.result -eq "succeeded") {
					Write-Host "$($RepoTable.Name) completed successfully"
					break
				}
				elseif ($runData.result -eq "failed") {					
					Write-Host "$($RepoTable.Name) failed stopping product build"
					Write-Error "Pipeline:" "$($PipelineRunsIds.Name)" " failed" -ErrorAction Stop 
				}
				Start-Sleep -Seconds 10
			}
		}		
		catch {
			Write-Host $Error[0]
			Write-Error "Error while executing the pipeline $($RepoTable.Name)..." -ErrorAction Stop
		}		
		
	}	

	$LockScriptLocation = Join-Path $PSScriptRoot "..\scripts\lock_unlock_branch.ps1"
    $IsLockSuccess = Invoke-Expression "& `"$LockScriptLocation`" 'TPC_Region26' 'CT-GlobalSW' 'CT_CompRegistry' 'master' 0 '$Auth'"
}

function Authenticate {
	param(	    
		[string]$Url
	)

	# Authenticate TFS PAT
	try {
		Invoke-RestMethod -Method Get -Uri $Url -ContentType "application/json" -Headers $Headers
		Write-Host "Authenticated successfully."
	}
	catch {
		Write-Host $Error[0]
		Write-Error "Please check the Auth token provided. Exiting..." -ErrorAction Stop
	}
	
}

function FillRepoList {
	$localPath = Get-Location
	Write-Output $localPath
	[xml]$xmlDoc = Get-Content -Path "$localPath\Config\RepoList.xml"
	$node = $xmlDoc.SelectNodes("//RepoList//Repo")

	Write-Output "Node :  $($node.Name)"
	foreach ($childNode in $node) {			
			
		Write-Output "childNode :  $($childNode.Name)"					
		$pipelineId = $childNode.GetAttribute("PipelineId")				
		$sequenceOrder = $childNode.GetAttribute("SequenceOrder")	
		$Name = $childNode.GetAttribute("Name")	
		Write-Output "$pipelineid, $sequenceOrder, $Name"
		$RepoObject = New-Object PSObject -Property @{
				
			Name          = $Name
			PipelineId    = $pipelineId
			SequenceOrder = $sequenceOrder
				
		}			
		$PipelineRunsIds.Add($RepoObject)
		Write-Output "$RepoObject"
	}
	Write-Output  "Length of array " $PipelineRunsIds.Count
}

FillRepoList
InvokePipeline

