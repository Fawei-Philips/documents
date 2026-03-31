# Author: KrishnaTeja Pallemalli (320233986)

# The script reads multiple registries that are available 
# in the Registry.txt and set the registries in .npmrc file.

# Usage:NpmRegistryset.ps1 <BaseDir> 

# Options:
#  BaseDir: Root path of the repository.

# Example: .\NpmRegistryset.ps1 'D:\Base'

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
           
            npm config set $content[$i]

        }
    }
} else {
    
    Write-Host "Registry File don't exist.. Please upload registry file"
	 exit(1)
   
}