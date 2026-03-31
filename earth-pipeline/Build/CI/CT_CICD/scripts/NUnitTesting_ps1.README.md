# NUnitTesting.ps1 documentation

## About
*The script does the following <br>
&nbsp;&nbsp;&nbsp;1) Copies the repo specific config files to D:\ drive <br>
&nbsp;&nbsp;&nbsp;2) Uses `nunit-console.exe` to run the unit tests from the path - `[repoBaseDir]\Output\OutTests`*

## Usage 
`.\NUnitTesting.ps1 [repoPath]`

## Option(s)
- `repoPath` (Mandatory) Path to root directory of the repository.

## Steps
- Launch Powershell
- Navigate to root directory of the repository.
- Run following commands: 
- &nbsp;&nbsp;&nbsp;`cd .\Build\CI\CT_CICD\scripts`
- &nbsp;&nbsp;&nbsp;`.\clean_up.ps1 "D:\Config,D:\PCC,D:\Database"`
- &nbsp;&nbsp;&nbsp;`.\NUnitTesting.ps1 [repoPath]`



## Examples 
- `. 'c:\ClonedRepos\CT_Serviceability\Build\CI\CT_CICD\scripts\NUnitTesting.ps1' 'C:\ClonedRepos\CT_Serviceability'`

- `.\NUnitTesting.ps1 'C:\ClonedRepos\CT_Serviceability'`

## Tools
- Nunit 2.6.3

## Pre-Requisite
### Run Clean up script
Before running NUnitTesting.ps1 script, you must run the clean up script using the below command: <br>
`.\clean_up.ps1 "D:\Config,D:\PCC,D:\Database"`
### nunit-console.exe    
Ensure that nunit-console.exe is present at the following path: <br>
`$($repoPath)\Tools\Tools.1.0.0\NUnit-2.6.3\bin\nunit-console.exe`

### You can download Tools from here:
https://artifactory.pic.philips.com:8443/ui/repos/tree/General/ct-workspace/Tools/Tools.1.0.0.nupkg
<br>
After downloading you can extract the `Tools.1.0.0` NuGet package file into the respective repo's `Tools` folder.


