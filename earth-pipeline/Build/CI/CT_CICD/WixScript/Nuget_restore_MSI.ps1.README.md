Nuget_restore_MSI.ps1.README.md
#Nuget_restore_MSI.ps1 Documentation

 

##About
*The script is used to install and unpack nuget packages of the provided repositories. Initially checks if the version provided exists in the Export folder. If it exists, it unpacks it into a temp folder. If the version does not exist, it is checked if it is present in the artifactory. If that version  exists in the artifactory, it is downloaded, else the latest version is downloaded and unpacked.*

 

##Usage
`Nuget_restore_MSI.ps1 [RepoName] [version] [folder_path]`

 

##Steps
- Launch Powershell
- Navigate to Powershell
- Execute &".\CT_CICD\WixScript\Nuget_restore_MSI.ps1"

 

##Options
- `RepoName` (Mandatory) Name of the Repository
- `version` (Not Mandatory) Version of the nuget package 
- `folder_path` (Mandatory) Path where the nuget packages are present

 

##Example
`.\Nuget_restore_MSI.ps1 'CT_CommonServices' '1.0.0' 'D:\CT_CommonServices\Export'`

 

##Pre-requisite
###Set Execution Policy
The system must have the Execution Policy set to unrestricted.
In Powershell, run: `Set-ExecutionPolicy -ExecutionPolicy Unrestricted`, select [`Y`]es

 

###Add Artifactory source
To add artifactory source, run:  `\\ingbtcpic6vw294\Nuget\Nuget.exe sources Add -Name Artifactory -Source https://artifactory.pic.philips.com:8443/artifactory/api/nuget/ct-workspace  -username <USERNAME> -password <PASSWORD>`

 

*Note:* you need to have access to the artifactory repo

 

The nuget config file at `C:\Users\<user>\AppData\Roaming\NuGet\NuGet.Config` must contain only one above mentioned "*packageSources*" key (ie. Artifactory).  

 

To remove any other key: `\\ingbtcpic6vw294\Nuget\nuget.exe sources remove -Name "<id>"`

 

Example- To remove *"nuget.org"*, run: `\\ingbtcpic6vw294\Nuget\nuget.exe sources remove -Name "nuget.org"`