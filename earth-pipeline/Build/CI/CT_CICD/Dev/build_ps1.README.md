# Build.ps1 Documentation

## About
*The script uses MSBuild to build and restore the Interface and Implementation Solutions (.sln) 
located in \ExtInf\ and \Src\ directories of the provided repository.*

## Help
`build.ps1 -help`

## Usage
`build.ps1 [Repo] [VsVer] [BuildParams]`

## Steps
- Launch Powershell 
- Navigate to the repo root 
- Execute `&".\Build\CI\CT_CICD\Dev\build.ps1"  -BuildParams '/p:platform="Any CPU" /p:configuration="Release"'`

## Options
- `repo` (Optional) Root directory of the repository. Defaults to the root directory of the script.
- `VsVer` (Optional) Range of installed VS to use for building. Defaults to the latest installed version.
- `BuildParams` (Optional) Parameters to be passed to the MSBuild to build the solutions.

## Examples
- `.\build.ps1 'D:\RepoBuilder\Dummy_Repo' '[15, 17)'`

- `.\build.ps1 'D:\RepoBuilder\Dummy_Repo' -BuildParams '/p:platform="Any CPU" /p:configuration="Release"'`

**Note:** *`VsVer`* takes a range of VS version codes. 
### VSVer Examples:
 1. `[15, 16)` : Inclusive of 15 but exclusive of 16, ie. 15.x.x.x
 2. `15` : Single version number  means that version *or newer*.
 3. *NA* : Deafults to the latest installed version.

More on versions: https://github.com/microsoft/vswhere/wiki/Versions

## Pre-requisite

### Add Submodules 
Make sure `.\Build\CI\CT_CICD\` and `./CT_CompRegistry` and other submodules are fetched. If  they are empty run `git submodule update --init --recursive` in root of repo. Or while cloning the repo use `git clone --recurse-submodules <repo_url>` to fetch submodules too.

### Set Execution Policy
The system must have the Execution Policy set to unrestricted.
In Powershell, run: `Set-ExecutionPolicy -ExecutionPolicy Unrestricted`, select [`Y`]es

### Add Artifactory source
To add artifactory source, run:  `\\ingbtcpic6vw294\Nuget\Nuget.exe sources Add -Name Artifactory -Source https://artifactory.pic.philips.com:8443/artifactory/api/nuget/ct-workspace  -username <USERNAME> -password <PASSWORD>`

*Note:* you need to have access to the artifactory repo

The nuget config file at `C:\Users\<user>\AppData\Roaming\NuGet\NuGet.Config` must contain only one above mentioned "*packageSources*" key (ie. Artifactory).  

To remove any other key: `\\ingbtcpic6vw294\Nuget\nuget.exe sources remove -Name "<id>"`

Example- To remove *"nuget.org"*, run: `\\ingbtcpic6vw294\Nuget\nuget.exe sources remove -Name "nuget.org"`

