# Author: KrishnaTeja Pallemalli (320233986)

# The script reads multiple registries that are available 
# in the Registry.txt and unset the registries in .npmrc file
# post the Angular build step is completed.

# Usage:NpmRegistryremove.ps1 <BaseDir> 

# Options:
#  BaseDir: Root path of the repository.

# Example: .\NpmRegistryremove.ps1 'D:\Base'

param(
    [Parameter(Mandatory = $true)] [string]$BaseDir
    )

$RegistryPath="$BaseDir\Build\AngularRegistry\Registry.txt"

if (Test-Path $RegistryPath) {
   $content = Get-Content -Path $RegistryPath
   if ($content -eq $null -or $content -eq [string]::Empty) {
        Write-Host "Registry values don't exist in file.. Add registry content"
		exit(1)
        
    } else {
        for($i = 0; $i -lt $content.count; $i++) {

            $removeregistry = $content[$i].split("=")
            npm config rm $removeregistry[0]
        }
    }
} else {
    
    Write-Host "Registry File don't exist..! Please upload registry file"
	 exit(1)
   
}