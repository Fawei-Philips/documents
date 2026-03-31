#PushMsiToArtifactory.ps1 Documentation

##About
*The script pushes the MSI's to Artifactory.*

##Usage
`PushMsiToArtifactory.ps1 [Target] [PAT] [RepoName]`

##Steps
- Launch Powershell
- Navigate to Powershell
- Execute `&".\CT_CICD\WixScript\PushMsiToArtifactory.ps1"`

##Options
- `Target` Root path of the target directory.
- `PAT` PAT for Artifactory (Format= <username>:<PAT>)
- `RepoName` Name of the repository

##Examples
`.\PushMsiToArtifactory.ps1 'D:\CT_CommonServices' 'username:pat' 'CT_CommonServices'`

##Pre-requisite
###Set Execution Policy
The system must have the Execution Policy set to unrestricted.
In Powershell, run: `Set-ExecutionPolicy -ExecutionPolicy Unrestricted`, select [`Y`]es

###Add Artifactory source
To add artifactory source, run:  `\\ingbtcpic6vw294\Nuget\Nuget.exe sources Add -Name Artifactory -Source https://artifactory.pic.philips.com:8443/artifactory/api/nuget/ct-workspace  -username <USERNAME> -password <PASSWORD>`

*Note:* you need to have access to the artifactory repo

The nuget config file at `C:\Users\<user>\AppData\Roaming\NuGet\NuGet.Config` must contain only one above mentioned "*packageSources*" key (ie. Artifactory).  

To remove any other key: `\\ingbtcpic6vw294\Nuget\nuget.exe sources remove -Name "<id>"`

Example- To remove *"nuget.org"*, run: `\\ingbtcpic6vw294\Nuget\nuget.exe sources remove -Name "nuget.org"`
