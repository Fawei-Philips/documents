# Generic MSI Creation documentation

## About
The script generates MSI Installers using Wix for a 3rd party components. 

Usage: `create_msi.ps1 <Path> <ComponentsList> <TargetPath>`

## Options:
`Path`: Root path of the target directory.

`ComponentsList`: List of comma-separated directories to be processed.

`TargetPaths`: Comma separated paths at which the component should be installed in the user's computer. Defaults to ProgramFiles folder.

## Example:
 `.\create_msi.ps1 'D:\CT_3rdParty' 'Castle.Core, log4net' 'C:\PCC\ChorusHost, D:\PSC'`

## Notes:
- The installer will be generated for all the versions available under the Path provided.
- The generated Installers will be placed under the Export/Installers directory for each component.
- Before installing the MSI, make sure the previous versions are of the components are uninstalled.