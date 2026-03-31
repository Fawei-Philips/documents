#Sequence of scripts:
- 1.Nuget_restore_MSI.ps1
- 2.WixCreateMsi.ps1
- 3.PushMsiToArtifacatory.ps1
- 4.clean_up.ps1


#Commands:
- .\Nuget_restore_MSI.ps1 'RepoName' 'NugetVersion' 'Path/To/Folder/Where/NugetPackages/Reside'

- .\WixCreateMsi.ps1 'RepoName' 'BaseDir' 'NugetVersion'

- .\PushMsiToArtifactory.ps1 'TargetPath' 'username:pat'

- .\clean_up/ps1 "Paths/To/Folders(comma separated values)"