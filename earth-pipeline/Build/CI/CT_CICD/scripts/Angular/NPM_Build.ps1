# Author: KrishnaTeja Pallemalli (320233986)

# This is npm build script which reads multiple projects that are available 
# in the projects location directory and execute the npm run build on project.

# Usage:NPM_Build.ps1 <Projects dir> 

# Options:
#  args: Project dir location from root base directory
# Example: .\NPM_Build.ps1 'D:\Base\Src\WebClient\PlanApplication\projects'

$Angular_Projects_Path = $args[0] #$(Build.Sourcesdirectory)/Src/WebClient/PlanApplication/projects

# Getting list of angular projects
$Angular_projects = Get-ChildItem $Angular_Projects_Path

$Angular_project_list = @()
# Getting all names of folder into list
if($Angular_projects.count -eq 0){
    Write-Host "`nNo angular project present to build`n"
    exit
}elseif($Angular_projects.count -eq 1){
    $Angular_project_list += $Angular_projects.Name
}else{
    for($i = 0; $i -lt $Angular_projects.count; $i++){
        $Angular_project_list += $Angular_projects.Name[$i]
    }
}
Write-Host "`nAngular projects available :- "
$Angular_project_list
Write-Host "`n"

# Building angular projects
Set-Location $Angular_Projects_Path

$json_data = Get-Content "..\angular.json" | ConvertFrom-Json

for($i = 0; $i -lt $Angular_project_list.count; $i++){
if($Angular_project_list[$i].ToLower() -notmatch "installscripts"){
        $Path2 = $Angular_project_list[$i]
        # $TestPath2 = Test-Path "$Path2/package.json"

        $Project_type = $json_data.projects.$Path2.projectType
        # Building SPA or module
        if($Project_type -eq "application" -or $Project_type -eq "library"){
            npm run build $Path2
        }else{
            Write-Host "Can not build $Path2 as it is not present in angular.json or it is not of type SPA or module`n"
        }
    }
}
