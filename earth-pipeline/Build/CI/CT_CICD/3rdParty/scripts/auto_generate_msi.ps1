# Author: Vaibhav Garg (320219077)

param( 
    [Parameter(Mandatory = $false, Position = 0)][string]$IsMSIReq,
    [Parameter(Mandatory = $false, Position = 1)][string]$ComponentName,
    [Parameter(Mandatory = $false, Position = 2)][string]$ComponentVersion,
    [Parameter(Mandatory = $false, Position = 3)][string]$ComponentRootPath,
    [Parameter(Mandatory = $false, Position = 4)][string]$WxsPath,
    [Parameter(Mandatory = $false, Position = 5)][string]$TargetPaths,
    [Parameter(Mandatory = $false, Position = 6)][string]$FrameworkPath
)

$ScriptPath = [System.IO.DirectoryInfo]$PSCommandPath
$WxsScriptPath = Resolve-Path (Join-Path $ScriptPath.Parent.FullName "..\wix\create_msi_wxs.ps1")
$GenericScriptPath = Resolve-Path (Join-Path $ScriptPath.Parent.FullName "..\wix\create_msi.ps1")

switch ($IsMSIReq) {
    "do-not-generate" {
        Write-Host "MSI generation skipped..."
    }

    "generate-using-custom-wxs" {
        Write-Host "Generating MSI using custom Wxs..."
        Invoke-Expression "&`"$WxsScriptPath`" '$ComponentName' '$ComponentVersion' '$ComponentRootPath' '$WxsPath'"      
    }

    "generate-using-paths" { 
        Write-Host "Generating MSI using Paths..."
        if(("$TargetPaths" -eq "no-value") -or ("$TargetPaths".Length -eq 0)){
            Write-Error "Error: No paths were provided, exiting..." -ErrorAction Stop
        }
        Invoke-Expression "&`"$GenericScriptPath`" '$ComponentName' '$ComponentVersion' '$ComponentRootPath' '$FrameworkPath' '$TargetPaths'"
    }

    Default {
        Write-Error "Incorrect input provided while processing auto msi creation, exiting.." -ErrorAction Stop
    }
}
