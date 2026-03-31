param (
	[string]$Auth,
	[string]$repoPath,
	[string]$branchName,
	[string]$commitMessage,
	[string]$interfaceChanged,
	[string]$ImplVersion,
	[string]$InfVersion,
	[string]$mainBranch,
	[string]$title = "CT_CompRegistry Integration Settings and Sample.target automated update",
	[string]$body = "Automated updated of Integration Settings and Sample.target files",
	[string]$repoName
)

$env:GIT_REDIRECT_STDERR = '2>&1'

function UpdateFile {
	param (
		[string]$repoPath,
		[string]$fileName,
		[string]$repoName,
		[string]$ImplVersion,
		[string]$InfVersion
	)
	Write-Output "Updating $repoName with Impl:$ImplVersion & Inf:$InfVersion"
	UpdateContent -repoPath $repoPath -fileName $fileName -repoName $repoName -ImplVersion $ImplVersion -InfVersion $InfVersion

}

#IMPLVersion -. 5.1.0.1 -> Integsettings for given repo and  Sample.target for given repo suffix Impl
#INFVersion -> 5.1.0.0 -> sample.target for given repo suffix Inf
function UpdateContent {
	param (
		[string]$repoPath,
		[string]$fileName,
		[string]$repoName,
		[string]$ImplVersion,
		[string]$InfVersion
	)
	$fullpath = "$repoPath\$fileName"
	write-Output "File path : $fullpath"
	Write-Output "Updating, $repoName with $ImplVersion $InfVersion"
	[xml]$xmlDoc = Get-Content -Path $fullpath
	
	if ($fileName -eq "IntegrationSetting.xml") {
		# Modify a specific node
		foreach ($node in $xmlDoc.SelectNodes("//IntegrationSetting")) {				
			foreach ($childNode in $node.SelectNodes("//Component")) {					
				$componentName = $childNode.GetAttribute("Name")
				if ($componentName -eq $repoName) {
					Write-Output "Child Node :  $($childNode.Name)"	
					$childNode.SetAttribute("Version", $ImplVersion)	
				}
			}
		}

		$version = $xmlDoc.IntegrationSetting.Version
		$parts = $version.Split('.')
		$parts[-1] = ([int]$parts[-1] + 1).ToString()
		$newVersion = $parts -join '.'
		$xmlDoc.IntegrationSetting.Version = $newVersion
	} 
	
	elseif ($fileName -eq "Sample.target") {		
		Write-Output "xml loaded"
		# Modify a specific node
		$node = $xmlDoc.SelectNodes("//Project//ItemGroup//PackageReference")
		$suffixImpl = "Impl"
		$suffixInf = "Inf"
		foreach ($childNode in $node) {			
			$componentName = $childNode.GetAttribute("Update")			
			$fullrepoNameImpl = -join ($repoName + "" + $suffixImpl)
			#Write-Output "$componentName-$fullrepoNameImpl"
			if ($componentName -eq $fullrepoNameImpl) {
				#Write-Output "Component name :  $componentName "" $suffixImpl"	
				$childNode.SetAttribute("Version", $ImplVersion)
			}
			$fullrepoNameInf = -join ($repoName + "" + $suffixInf)
			#Write-Output "$componentName-$fullrepoNameInf"
			if ($componentName -eq $fullrepoNameInf) {
				#Write-Output "Component name :  $componentName+""+$suffixInf"	
				$childNode.SetAttribute("Version", $InfVersion)
			}
		}
	}		
	# Save the XML document with UTF-8 encoding explicitly		
	$streamWriter = [System.IO.StreamWriter]::new($fullpath, $false, [System.Text.Encoding]::UTF8::new($false))
	$xmlTextWriter = [System.Xml.XmlTextWriter]::new($streamWriter)
	$xmlTextWriter.Formatting = [System.Xml.Formatting]::Indented
	$xmlDoc.WriteTo($xmlTextWriter)
	$xmlTextWriter.Close()	

}

$filePaths = @("IntegrationSetting.xml", "Sample.target") # List of files to add

# Navigate to the repository
$CompRegPath = Join-Path $repoPath "CT_CompRegistry"
Set-Location -Path $repoPath

try {
	if (Test-Path -Path "$CompRegPath") {
		Write-Host "Cleaning the local copy of CompReg"
		Remove-Item -Path "$CompRegPath" -Recurse -Force
	}
}
catch {
	Write-Host $Error[0]
}

git clone -b $mainBranch "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/CT-GlobalSW/_git/CT_CompRegistry"
Set-Location $CompRegPath

# Check if the branch exists
$branchExists = git show-ref --verify --quiet "refs/heads/$branchName"

if ($branchExists) {
	Write-Output "Branch '$branchName' already exists. Switching to the branch."
	git checkout $branchName
}
else {
	Write-Output "Branch '$branchName' does not exist. Creating and switching to the branch."
	git checkout -b $branchName
}

git pull origin $branchName
# Add files to the staging area
foreach ($file in $filePaths) {
	UpdateFile -repoPath $CompRegPath -fileName $file -repoName $repoName -ImplVersion $ImplVersion -InfVersion $InfVersion
	git add $file
}

git commit -m "Updating Sample.target and IntegrationSetting files from script for repo: $repoName"
git push --set-upstream origin $branchName

$interfaceChanged = "true"

$LockScriptLocation = Join-Path $PSScriptRoot "..\scripts\lock_unlock_branch.ps1"
$IsLockSuccess = Invoke-Expression "& `"$LockScriptLocation`" 'TPC_Region26' 'CT-GlobalSW' 'CT_CompRegistry' 'master' 0 '$Auth'"


if ($interfaceChanged -eq "true") {
	#'"TPC_Region26" "CT-GlobalSW" "CT_CompRegistry" "update-product-build" "master-copy-product-build" "Updated Components  using Product Build" "Syncing Product Build Components" "AutoMerged update-product-build" "$(TFS_AUTH)"'
	$PRScriptLocation = Join-Path $PSScriptRoot "..\scripts\create_merge_pr.ps1"
	$IsPRMergeSuccess = Invoke-Expression "&`"$PRScriptLocation`" 'TPC_Region26' 'CT-GlobalSW' 'CT_CompRegistry' $branchName $mainBranch 'Update comp registry' 'Auto update comp registry' 'AutoMerged comp registry' '$Auth'"
	if ($IsPRMergeSuccess -ne 0) {
		throw "PR Merge failed."
	}
}

#$LockScriptLocation = Join-Path $PSScriptRoot "..\scripts\lock_unlock_branch.ps1"
#$IsLockSuccess = Invoke-Expression "& `"$LockScriptLocation`" 'TPC_Region26' 'CT-GlobalSW' 'CT_CompRegistry' 'master' 1 '$Auth'"

try {
	Write-Host "Cleaning the local copy of CompReg"
	Set-Location ".."
	Remove-Item -Path "$CompRegPath" -Recurse -Force
}
catch {
	Write-Host $Error[0]
	Write-Host "Could not clean the local copy of CompReg"
}
