
# README Wix config File

Contains information on which nuget(folder) are needed to be packaged during MSI creation.

***"0" represents the folder to be disregarded during MSI creation***

***"1" represents the folder to be packaged during MSI creation***

The Repo owner needs to make appropriate changes to config file to make sure correct nugets(folders) are ***packaged*** during MSI creation.

The defualt configuration in the file for any new repo is:
```
  <config>
    <outputFolders>
		<OutInf value="1"/>
		<OutImpl value="1"/>
		<OutRes value="1"/>
		<OutCfg value="1"/>
    </outputFolders>
  </config>
```
In this configuration all the nugets(folders) will be packaged in the MSI (This is the default configuration for any newly generated Repository) and if any folder is to be disregarded, the value should be changed from "1" to "0".