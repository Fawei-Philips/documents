# Component specific Wix files documentation

## About
The wix files are custom Wix Product.wxs files that contain all the files that need to be packaged into their respective deployment paths. There are 3 custom wix files for the components PF2_0, IAP_Temp and 2ndPartyTemp components.

These are just Templates. To generate MSIs we need to run candle and light commands

# Steps
- Launch PowerShell
- navigate to the directory that contains the specific components Product.wxs file
- Run candle command
    `& $env:WIX\bin\candle.exe *.wxs -sw1026 -o obj\`
- This will create an obj folder that contains the wixobj file
- Run light command
    `& $env:Wix\bin\light.exe obj\*.wixobj -sw1076 -o "output\folder\path\MSIName.msi"`

    Ex: `& $env:Wix\bin\light.exe obj\*.wixobj -sw1076 -o "D:\Wix\CustomWixProj\IAP_Temp\IAP_Temp.msi"`
- This will link all the .wxs files and compile the wix code and create the MSI in the output path mentioned.