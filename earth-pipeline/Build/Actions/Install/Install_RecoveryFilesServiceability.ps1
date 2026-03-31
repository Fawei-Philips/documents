
# This is a script to deploy config/database files for a given model to Recovery folder
# The model name should be available in the "D:\System\SystemType.json"

# Usage: .\DeployConfig.ps1

#copies the content of a given folder to Config, PCC etc.
function DeployConfigFromFolder
{
    param([string]$sourcePath)
    Write-Host "Processing folder $sourcePath"

    if(Test-Path -Path $sourcePath)
    {	
		#Note : Creating Recovery Folder if it does not exists
		$directory = "D:\PCC\ChorusHost\Recovery"

		if (-not (Test-Path $directory)) {
			New-Item -ItemType Directory -Path $directory
			Write-Host "Directory created successfully."
		} 
		#Note : This will check the Config path D:\Config
        $configPath = Join-Path $sourcePath 'Config'
        if(Test-Path $configPath)
        {
            #Note: Do not use move-item command here or below.
      
			Copy-Item $configPath -Destination 'D:\PCC\ChorusHost\Recovery\' -Force -Recurse

            #Note: Do not use move-item command here or below.
            Copy-Item $configPath -Destination 'D:\' -Force -Recurse
        }
			#Note : This will check the DataBase path D:\PCC\ChorusHost\DataBase
		$DatabasePath = Join-Path $sourcePath 'PCC\ChorusHost\Database'
        if(Test-Path $DatabasePath)
        {
			#Note : Copying items from D:\PCC\ChorusHost\DataBase to D:\PCC\ChorusHost\Recovery\DataBase
			Copy-Item -Path $DatabasePath -Destination 'D:\PCC\ChorusHost\Recovery\' -Force -Recurse
        }
		 #Note : This will check the Protocol path D:\PCC\ChorusHost\Protocols

        $pccPath = Join-Path $sourcePath 'PCC'
        if(Test-Path $pccPath)
        {
            Copy-Item -Path $pccPath -Destination 'D:\' -Force -Recurse
        }
      #  Remove-Item $sourcePath -Recurse -Force
    }

}


#this needs to be updated every time a new model is added.
#1. Pony- CT3300, kunpeng- CT3500, Taichi - CT5400, CT5400RT, CT5200RT, Chess/Kylin - CT5300
$models = ('CT3500', 'CT3300', 'CT5400', 'CT5400RT', 'CT5200RT', 'CT5300')

#The flow is as below
# Get the model name from json file 
# Copy files from D:\Base to corresponding folders
# Copy files from d:\<model> to corresponding folders
# Remove all folders in the 'models' array

$modelName = ""
$jsonPath = "D:\System\SystemType.json"
if(Test-Path -Path $jsonPath)
{
    try
    {
        $modelName = Get-Content -Path $jsonPath  | ConvertFrom-Json |%{$_.Scanner.model}
    }
    catch
    {
        throw "Could not read model name from json file: $_"        
    }

    Write-Host "Model detected as $modelName"
}
else
{
    throw "Could not find json file.  Exiting"
}

#copy files from Base folder
DeployConfigFromFolder d:\Base

$modelFolder = Join-Path 'D:\' $modelName

DeployConfigFromFolder $modelFolder

Write-Host 'Configurations copied'

foreach($model in $models)
{
    $fullPath = Join-Path 'D:\' $model
    Write-Host "Removing folder $fullPath"

    if(Test-Path $fullPath)
    {
        #Remove-Item $fullPath -Recurse -Force
    }
}