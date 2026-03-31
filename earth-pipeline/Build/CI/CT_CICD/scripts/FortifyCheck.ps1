# Following script reads the Wix.config file to identify if inf & impl solutions are present and sets INF and IMPL variables for later use in pipeline.

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $BaseDir
)
$configFilePath = "$($BaseDir)\Build\Pkg\MSI\Wix.config"
$xml = [xml](Get-Content $configFilePath) 
$inf = $xml.configuration.config.outputFolders.OutInf.GetAttribute("value")
$impl = $xml.configuration.config.outputFolders.OutImpl.GetAttribute("value")
Write-Host ("##vso[task.setvariable variable=INF;isoutput=true]$inf")
Write-Host ("##vso[task.setvariable variable=IMPL;isoutput=true]$impl")
if ($inf -eq 1) {
    Write-Host "Inf solution is present."
}
if ($impl -eq 1) {
    Write-Host "Impl solution is present."
}