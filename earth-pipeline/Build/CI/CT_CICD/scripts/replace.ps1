# Aurhor : Pawan Kulkarni.S
# TA,2023                                                                    
param(
    [string] $filePath,
    [string] $find,
    [string] $replace
)
write-host "ParamExePath: " $filePath
$tempFilePath = "$env:TEMP\$($filePath | Split-Path -Leaf)"
(Get-Content -Path $filePath) -replace $find, $replace | Add-Content -Path $tempFilePath
Remove-Item -Path $filePath
Move-Item -Path $tempFilePath -Destination $filePath