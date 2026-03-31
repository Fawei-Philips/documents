#Download&InstallMSI.ps1 Documentation

## About
*The script downloads a particular version of the MSIs mentioned in the config file. If any of the MSIs are previously installed it is deleted and the downloaded MSIs are then installed according to the sequence mentioned in the config file.

## Usage
`Download&InstallMSI.ps1 'pat' '1.0.0' 'D:\Repos'`

## Steps
- Launch powershell
- Execute `&"Download&InstallMSI.ps1 'pat' '1.0.0' 'D:\Repos'"`

## Options
- `PAT`: PAT for Artifactory (Format= <username>:<PAT>)
- `version` (Mandatory) Version of the MSI to be downloaded
- `BaseRepoPath`: () The base Repository path

## Example
`.\Download&InstallMSI.ps1 'pat' '1.0.0' 'D:\Repos'`

## Pre-requisites

### Set Execution Policy
The system must have the Execution Policy set to unrestricted.
In Powershell, run: `Set-ExecutionPolicy -ExecutionPolicy Unrestricted`, select [`Y`]

### Add Artifactory source
To add artifactory source, run:  `\\ingbtcpic6vw294\Nuget\Nuget.exe sources Add -Name Artifactory -Source https://artifactory.pic.philips.com:8443/artifactory/api/nuget/ct-workspace  -username <USERNAME> -password <PASSWORD>`

*Note:* you need to have access to the artifactory repo

The nuget config file at `C:\Users\<user>\AppData\Roaming\NuGet\NuGet.Config` must contain only one above mentioned "*packageSources*" key (ie. Artifactory).  

To remove any other key: `\\ingbtcpic6vw294\Nuget\nuget.exe sources remove -Name "<id>"`

Example- To remove *"nuget.org"*, run: `\\ingbtcpic6vw294\Nuget\nuget.exe sources remove -Name "nuget.org"`