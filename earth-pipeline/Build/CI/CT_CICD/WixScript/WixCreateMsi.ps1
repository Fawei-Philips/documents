# Author: Sanjana V (320218599)

# This is a common script to build MSI packages using Wix installer.

# Usage: .\WixCreateMsi.ps1 'RepoName' 'PathToRepo' 'nuget_Version'

# Options: 
#   RepoName: (Mandatory) Name of the Repository
#   nugetVersion: (Mandatory) Version of the nuget package
#   BaseDir : (Mandatory) Base directory of the repo

# Example: .\WixCreateMsi.ps1 'CT_CommonServices' 'D:\CT_CommonServices' '1.0.0'

# Note: 
#   System must have  WiX Toolset v3.11 installed
#   The script must be run from '\Build\CI\CT_CICD\WixScript\'

[CmdletBinding()]
param(
        [Parameter(Mandatory=$true)]
        [string]$RepoName,
        [Parameter(Mandatory=$true)]
        [string]$BaseDir,
        [Parameter(Mandatory=$true)]
        [string]$nugetVersion,
        [Parameter(Mandatory=$true)]
        [string]$InfVersion,
        [Parameter(Mandatory=$true)]
        [string]$msiVersion
)

#env variables
$WxsOutputStorePath="D:\$($RepoName)CommonMsiScriptFragmentFile"                                              
$ProductWxsPath=""
$tmpFolderPath="D:\$($RepoName)_temp"
$InfSourcePath="$($tmpFolderPath)\$($RepoName)Inf.$($InfVersion)\lib\net48"
$ImplSourcePath="$($tmpFolderPath)\$($RepoName)Impl.$($nugetVersion)\lib\net48"
$CfgSourcePath="$($tmpFolderPath)\$($RepoName)Impl.$($nugetVersion)\Impl\OutCfg"
$ResSourcePath="$($tmpFolderPath)\$($RepoName)Impl.$($nugetVersion)\Impl\OutRes"
$PostInsScrPath="$($tmpFolderPath)\$($RepoName)PostActions.$($nugetVersion)\PostActions"
$MSIOuputPath="$($BaseDir)\Build\Pkg\MSI"
$WixDir = "C:\Program Files (x86)\WiX Toolset v3.11\bin"
$CurrentWorkingDir="$($BaseDir)\Build\CI\CT_CICD\WixScript"
$OutInfWxs="$($WxsOutputStorePath)\OutInfFragment.wxs"
$OutImplWxs="$($WxsOutputStorePath)\OutImplFragment.wxs"
$OutResWxs="$($WxsOutputStorePath)\OutResFragment.wxs"
$OutCfgWxs="$($WxsOutputStorePath)\OutCfgFragment.wxs"
$OutPSWxs="$($WxsOutputStorePath)\OutPostFragment.wxs"
$configFilePath="Pkg\MSI\Wix.config"
$PostInstallScript="$tmpFolderPath\$($RepoName)PostActions.$($nugetVersion)\PostActions\Install\Install_$($RepoName).bat"
$PreUninstallScrip="$tmpFolderPath\$($RepoName)PostActions.$($nugetVersion)\PostActions\Uninstall\Uninstall_$($RepoName).bat"
$GUIDPath="$($BaseDir)\Build\Pkg\MSI\GUID"
$outPosIns = 0
if((Test-Path -pathtype leaf $PostInstallScript) -and (Test-Path -pathtype leaf $PreUninstallScrip)){
    $WixTemplatePath = "$($BaseDir)\Build\CI\CT_CICD\WixScript\TemplateWithPostInstall.wxs"
    $ProductWxsPath="$WxsOutputStorePath\TemplateWithPostInstall.wxs"
    $outPosIns = 1
}
else{
    $WixTemplatePath = "$($BaseDir)\Build\CI\CT_CICD\WixScript\TemplateWithoutPostInstall.wxs"
    $ProductWxsPath="$WxsOutputStorePath\TemplateWithoutPostInstall.wxs"
}

if (Test-Path $GUIDPath) {
   $content = Get-Content -Path $GUIDPath -Raw
   if ($null -eq $content -or $content -eq [string]::Empty) {
        Write-Host "Guid value don't exist in file,please Update GUID in file...The Wix scripts will exit "
        exit 1
        
    } else {
        $GUID = '{'+$content.Trim()+'}'
    }
} else {
    $Guid = '{'+[guid]::NewGuid().ToString()+'}'
   
}

try{

    #Removing README files from the temp folder since do not neet it in the msi
    Get-ChildItem -Path $tmpFolderPath -Include "README*" -Recurse | ForEach-Object { $_.Delete() }


    #Set-Location D:
    Set-Location "..\..\..\"
    $xml = [xml](Get-Content $configFilePath) 
	#$xml = [xml](Get-Content $configFilePath)
	$outinf=$xml.configuration.config.outputFolders.OutInf.GetAttribute("value")
	$outimpl=$xml.configuration.config.outputFolders.OutImpl.GetAttribute("value")
	$outres=$xml.configuration.config.outputFolders.OutRes.GetAttribute("value")
	$outcfg=$xml.configuration.config.outputFolders.OutCfg.GetAttribute("value")

    if( ($outinf -and $outimpl -and $outres -and $outcfg) -eq 0 ){
        Write-Host "There is nothing in the output folders to package...The Wix scripts will exit"
        exit 1
    }

    #checking if any temp folders created previously exist... if it does remove it and create a new temp folder
    if(Test-Path -Path $WxsOutputStorePath){
        Remove-Item $WxsOutputStorePath -Recurse
        Write-Host "$($RepoName) temp folder exists...deleting it and creating a new one."  -ForegroundColor Yellow
    }

    New-Item -Path $WxsOutputStorePath -ItemType Directory | Out-Null
    copy-item -Path $WixTemplatePath -Destination $WxsOutPutStorePath

    #filling in repo specific details like Product name,ProductId, UpgradeCode, cabinet file, Guid, etc
    $xml=[xml](Get-Content $ProductWxsPath)
    $xml.Wix.Product.Name = $RepoName
    $xml.Wix.Product.Package.Description=$RepoName
    $xml.Wix.Product.UpgradeCode=$Guid
    $Guid = '{'+[guid]::NewGuid().ToString()+'}'
    $xml.Wix.Product.Id=$Guid
    $xml.Wix.Product.Media.Cabinet=$RepoName+".cab"
    $xml.Save($ProductWxsPath)

    #Removing README files from the temp folder since do not neet it in the msi
    Get-ChildItem -Path $tmpFolderPath -Include "README*" -Recurse | ForEach-Object { $_.Delete() }
    

	#maybe create flags by checking the config file and use that to perform the rest of the flow
    function ReplaceSourceDir{
        param (
            [string]$find,
            [string]$file,
            [string]$replace
        )
        $content = Get-Content $file -Raw
        $content -replace $find,$replace | Out-File $file 
        $xml=[xml](Get-Content $file)
        $xml.Save($file)
    }


    #checking if OutPut folders are empty and deleting nodes from the template
    if( $outimpl -eq 0 ){
        $xml = [xml](Get-Content $ProductWxsPath)
        $xml.Wix.Product.Feature | Where-Object { $_.Id -eq "OutImplFeature" } | ForEach-Object { $_.ParentNode.RemoveChild($_) }
        $xml.Wix.Fragment.Directory.Directory.Directory.Directory.Component | Where-Object { $_.Id -eq "Impl" } | ForEach-Object { $_.ParentNode.RemoveChild($_) }
        $xml.Save($ProductWxsPath)
    }

    if( $outinf -eq 0 ){
        $xml = [xml](Get-Content $ProductWxsPath)
        $xml.Wix.Product.Feature | Where-Object { $_.Id -eq "OutInfFeature" } | ForEach-Object { $_.ParentNode.RemoveChild($_) }
        $xml.Wix.Fragment.Directory.Directory.Directory.Directory.Component | Where-Object { $_.Id -eq "Inf" } | ForEach-Object { $_.ParentNode.RemoveChild($_) }

        $xml.Save($ProductWxsPath)
    }

    if( $outres -eq 0 ){
        $xml = [xml](Get-Content $ProductWxsPath)
        $xml.Wix.Product.Feature | Where-Object { $_.Id -eq "OutResFeature" } | ForEach-Object { $_.ParentNode.RemoveChild($_) }
        $xml.Wix.Fragment.Directory.Component | Where-Object { $_.Id -eq "Res" } | ForEach-Object { $_.ParentNode.RemoveChild($_) }
    
        $xml.Save($ProductWxsPath)
    }

    if( $outcfg -eq 0 ){
        $xml = [xml](Get-Content $ProductWxsPath)
        $xml.Wix.Product.Feature | Where-Object { $_.Id -eq "OutCnfgFeature" } | ForEach-Object { $_.ParentNode.RemoveChild($_) }
        $xml.Wix.Fragment.Directory.Component | Where-Object { $_.Id -eq "Cnfg" } | ForEach-Object { $_.ParentNode.RemoveChild($_) }

        $xml.Save($ProductWxsPath)
    }
    
    if( $outPosIns -eq 0 ){
        $xml = [xml](Get-Content $ProductWxsPath)
        $xml.Wix.Product.Feature | Where-Object { $_.Id -eq "OutPostFeature" } | ForEach-Object { $_.ParentNode.RemoveChild($_) }
        $xml.Wix.Fragment.Directory.Component | Where-Object { $_.Id -eq "PosIns" } | ForEach-Object { $_.ParentNode.RemoveChild($_) }

        $xml.Save($ProductWxsPath)
    }
   


    #generating .wxs files with the components and files required to be installed using heat.exe and using an XSLT file to remove all README files
    Set-Location $WixDir
    if( $outinf -eq 1 ){
        .\heat.exe dir  $InfSourcePath  -dr Bin -cg ctCommonOutInf -gg -scom -sreg -sfrag -suid -srd -out "$($WxsOutputStorePath)\OutInfFragment.wxs"
        Write-Host "Generating outinf fragment files" -ForegroundColor Yellow

    }
    if( $outimpl -eq 1 ){
         .\heat.exe dir  $ImplSourcePath  -dr Bin -cg ctCommonOutImpl -gg -scom -sreg -sfrag -suid -srd -out "$($WxsOutputStorePath)\OutImplFragment.wxs"
         Write-Host "Generating outinpl fragment files" -ForegroundColor Yellow
    }
    if( $outres -eq 1 ){
         .\heat.exe dir  $ResSourcePath  -dr TARGETDIR -cg ctCommonOutRes -gg -scom -sreg -sfrag -suid -srd -out "$($WxsOutputStorePath)\OutResFragment.wxs"
         Write-Host "Generating outres fragment files" -ForegroundColor Yellow

    }
    if( $outcfg -eq 1 ){
         .\heat.exe dir  $CfgSourcePath  -dr TARGETDIR -cg ctCommonOutCfg -gg -scom -sreg -sfrag -suid -srd  -out "$($WxsOutputStorePath)\OutCfgFragment.wxs"
         Write-Host "Generating outcfg fragment files" -ForegroundColor Yellow
    }
    if( $outPosIns -eq 1 ){
         .\heat.exe dir  $PostInsScrPath  -dr TARGETDIR -cg ctPostIns -gg -scom -sreg -sfrag -suid -srd  -out "$($WxsOutputStorePath)\OutPostFragment.wxs"
         Write-Host "Generating outposins fragment files OutPostFragment" -ForegroundColor Yellow
    }

    #editing the generated .wxs files' SourceDir to their specific source paths
    
    #check if all these .wxs files exist then call the function
    if(Test-Path -Path $OutInfWxs){
        ReplaceSourceDir -find "SourceDir" -replace "$tmpFolderPath\$($RepoName)Inf.$($InfVersion)\lib\net48" -file "$($WxsOutputStorePath)\OutInfFragment.wxs"
    }
    if(Test-Path -Path $OutImplWxs){
        ReplaceSourceDir -find "SourceDir" -replace "$tmpFolderPath\$($RepoName)Impl.$($nugetVersion)\lib\net48" -file "$($WxsOutputStorePath)\OutImplFragment.wxs"
    }
    if(Test-Path -Path $OutResWxs){
        ReplaceSourceDir -find "SourceDir" -replace "$tmpFolderPath\$($RepoName)Impl.$($nugetVersion)\Impl\OutRes" -file "$($WxsOutputStorePath)\OutResFragment.wxs"
    }
    if(Test-Path -Path $OutCfgWxs){
         ReplaceSourceDir -find "SourceDir" -replace "$tmpFolderPath\$($RepoName)Impl.$($nugetVersion)\Impl\OutCfg" -file "$($WxsOutputStorePath)\OutCfgFragment.wxs"
    }
    if(Test-Path -Path $OutPSWxs){
         ReplaceSourceDir -find "SourceDir" -replace "$tmpFolderPath\$($RepoName)PostActions.$($nugetVersion)\PostActions" -file "$($WxsOutputStorePath)\OutPostFragment.wxs"
    }

    
    function ReplacePostSourcePath{
        param(
            [string]$ProductWxsPath,
            [string]$BaseDir
        )
    
        $content = Get-Content -Path $ProductWxsPath -Raw
        
        $content = $content -replace '\[INSTALLFOLDER\]post.bat', "[TARGETDIR]Install\Install_$($RepoName).bat"
        $content = $content -replace '\[INSTALLFOLDER\]pre.bat', "[TARGETDIR]Uninstall\Uninstall_$($RepoName).bat"
        
        Set-Content -Path $ProductWxsPath -Value $content
        Write-Host "Replaced Post and Pre Install script source paths"
    }
    
    if(Test-Path -pathtype leaf $PostInstallScript){
        ReplacePostSourcePath -ProductWxsPath $ProductWxsPath -BaseDir $BaseDir
    }
    
   

    #Add prefix to Id to make it unique
    function AddPrefix{
        param(
            [string]$xmlPath,
            [string]$node,
            [string]$Prefix
        )

        [xml]$xml = Get-Content $xmlPath
        $namespace = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
        $namespace.AddNamespace("wix", "http://schemas.microsoft.com/wix/2006/wi")
        $xml.SelectNodes($node, $namespace) | ForEach-Object {
            $id = $_.GetAttribute("Id")
            $newId = "$($Prefix).$id"
            $_.SetAttribute("Id", $newId)
        }
        $xml.Save($xmlPath)
    }

    #Add prefix to directory Ids 
    if(Test-Path -Path $OutInfWxs){
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutInfFragment.wxs"  -node "//wix:Directory" -Prefix "Inf"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutInfFragment.wxs"  -node "//wix:Component" -Prefix "Inf"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutInfFragment.wxs"  -node "//wix:ComponentRef" -Prefix "Inf"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutInfFragment.wxs"  -node "//wix:File" -Prefix "Inf"
    }
    if(Test-Path -Path $OutImplWxs){
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutImplFragment.wxs" -node "//wix:Directory" -Prefix "Impl"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutImplFragment.wxs" -node "//wix:Component" -Prefix "Impl"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutImplFragment.wxs" -node "//wix:ComponentRef" -Prefix "Impl"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutImplFragment.wxs" -node "//wix:File" -Prefix "Impl"
    }
    if(Test-Path -Path $OutResWxs){
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutResFragment.wxs" -node "//wix:Directory" -Prefix "Res"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutResFragment.wxs" -node "//wix:Component" -Prefix "Res"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutResFragment.wxs" -node "//wix:ComponentRef" -Prefix "Res"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutResFragment.wxs" -node "//wix:File" -Prefix "Res"
    }
    if(Test-Path -Path $OutCfgWxs){
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutCfgFragment.wxs" -node "//wix:Directory" -Prefix "Cfg"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutCfgFragment.wxs" -node "//wix:Component" -Prefix "Cfg"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutCfgFragment.wxs" -node "//wix:ComponentRef" -Prefix "Cfg"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutCfgFragment.wxs" -node "//wix:File" -Prefix "Cfg"
    }
    if(Test-Path -Path $OutPSWxs){
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutPostFragment.wxs" -node "//wix:Directory" -Prefix "PosIns"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutPostFragment.wxs" -node "//wix:Component" -Prefix "PosIns"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutPostFragment.wxs" -node "//wix:ComponentRef" -Prefix "PosIns"
        AddPrefix -xmlPath "$($WxsOutputStorePath)\OutPostFragment.wxs" -node "//wix:File" -Prefix "PosIns"
    }

    #Compiling wix source code
    Set-Location "D:\$($RepoName)CommonMsiScriptFragmentFile"
    Write-Host "Creating wix obj with Repo name: $RepoName & code: $msiVersion" -ForegroundColor Yellow
    & $env:WIX\bin\candle.exe *.wxs -dComponentName="$RepoName" -dProductVersion="$msiVersion" -sw1026 -o obj\
    
    #Linking all the .wxs files
    Write-Host "Generating MSI at $($MSIOuputPath)\$RepoName.msi" -ForegroundColor Yellow
    & $env:Wix\bin\light.exe obj\*.wixobj -sw1076 -o "$($MSIOuputPath)\$RepoName.msi"
}

catch{
    Write-Host $Error[0]
    Write-Host "An error occurred while running the script"
}

finally{
    Set-Location "D:\"
    Set-Location $CurrentWorkingDir
}