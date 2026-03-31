
$repoPath = $PSScriptRoot
$masterBranch = "master"
$CompRegPath = Join-Path $repoPath "CT_CompRegistry"
$tagName = ""

git clone -b $masterBranch "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/CT-GlobalSW/_git/CT_CompRegistry" $CompRegPath
Set-Location $CompRegPath

#read consle version from IntegrationSetting.xml

[xml]$xml = Get-Content ".\IntegrationSetting.xml"
$tagName = $xml.IntegrationSetting.Version
Write-Output $tagName

git tag $tagName -m "create console tag from push build pipeline"
git push origin $tagName


$PackagingRegPath = Join-Path $repoPath "Packaging"


git clone -b $masterBranch "https://tfsemea1.ta.philips.com/tfs/TPC_Region26/SY_CT_Projects/_git/Packaging" $PackagingRegPath

$localPath = Join-Path $PackagingRegPath 'BuildScript\CompileInfo\CT_WorkSpace'
Write-Output $localPath

Set-Location $localPath

#modify 1Click_CompileInfo.xml

[xml]$xml_1 = Get-Content ".\1Click_CompileInfo.xml"

$node = $xml_1.CompileInfo.Media.Section |
    Where-Object { $_.name -eq "Software" } |
    Select-Object -ExpandProperty SubSection |
    Where-Object { $_.name -eq "Console" }

if ($null -eq $node) {
    throw "does not find Console node"
}

Write-Output $node.Label
$node.Label = $tagName
$xml_1.Save((Resolve-Path ".\1Click_CompileInfo.xml"))

git add 1Click_CompileInfo.xml
git commit -m "update console label to $tagName"
git push origin $masterBranch

