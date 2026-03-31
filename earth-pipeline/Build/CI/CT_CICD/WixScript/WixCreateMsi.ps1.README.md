#WixCreateMsi.ps1 Documentation

## About
*The script builds the MSI package using Wix installer. A template.wxs file is used which contains the installer specific details and the directory structure. Creates fragment files (using heat.exe) that contain the files that need to be installed (OutImplFragment,OutlnfFragment,OutResFragment,OutCfgFragment). All the fragment files are stored in a temporary folder.Fragment files are modified to replace the SourceDir with its respective Source paths. Adds prefixes to the IDs of the directories, components and files to make them unique. Compiles the wix source code using candle command and links all the .wxs files using light command.*
using XSLT file. 
## Usage
`WixCreateMsi.ps1 [RepoName][BaseDir][nugetVersion]`

## Steps
- Launch Powershell
- Navigate to Powershell
- Execute `&".\CT_CICD\WixScript\WixCreateMsi.ps1"`

## Options
- `RepoName`(Mandatory) Name of the Repository
- `nugetVersion` (Mandatory) Version of the nuget package 
- `BaseDir` (Mandatory) Base Directory path

## Example
`.\WixCreateMsi.ps1 'CT_CommonServices' 'D:\CT_CommonServices' '1.0.0'`

## Pre-Requisite
 - Should have WiX Toolset v3.11 installed in the system

