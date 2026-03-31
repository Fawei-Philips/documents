# Author: Liuyang

# This is a common script for brackup&restore and tubhistory tool lnk destop creation.

# Usage: .\CreateServiceToolLnkInDesktop .ps1

#copies the content of a given folder to Config, PCC, Recovery etc.
$shell = New-Object -ComObject WScript.Shell
$desktop =[System.Environment]::GetFolderPath('Desktop')
$shortcut = $shell.CreateShortcut("$desktop\Backup & Restore.lnk")
$shortcut.TargetPath = "D:\PCC\ChorusHost\Bin\BackupRestoreUI.exe"
$shortcut.IconLocation = "D:\PCC\ChorusHost\Bin\BackupRestoreUI.exe"
$shortcut.Save()

$shortcut1 = $shell.CreateShortcut("$desktop\Philips Support Connect.lnk")
$shortcut1.TargetPath = "C:\Program Files\Philips\PSC\Philips.ServicePlatform.HostingApplication.exe"
$shortcut1.IconLocation = "C:\Program Files\Philips\PSC\Philips.ServicePlatform.HostingApplication.exe"
$shortcut1.Save()

$shortcut2 = $shell.CreateShortcut("$desktop\TubeHistory.lnk")
$shortcut2.TargetPath = "D:\PCC\ChorusHost\Bin\TubeHistory.exe"
$shortcut2.IconLocation = "D:\PCC\ChorusHost\Bin\TubeHistory.exe"
$shortcut2.Save()
