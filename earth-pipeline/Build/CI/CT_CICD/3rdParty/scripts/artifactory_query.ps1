# Author: Vaibhav Garg (320219077)

# The script is used to query nukpkg versions on Artificatory

# Usage: artifactory_query.ps1 <Components> <PAT>

# Options:
#  Repo: Repo name
#  Name: Component name
#  Ver: Component version
#  Path: Folder path on Artifactory (Optional)
#  PAT: PAT for Artifactory (Format= <username>:<PAT>).

# Example: .\artifactory_query.ps1 'ct-workspace' 'Castle.Core' '4.2.0' 'CT_3rdParty' 'username:pat'

param(
    [Parameter(Mandatory = $false, Position = 0)][string]$Repo,
    [Parameter(Mandatory = $false, Position = 1)][string]$Name,
    [Parameter(Mandatory = $false, Position = 2)][string]$Ver,
    [Parameter(Mandatory = $false, Position = 3)][string]$Path,
    [Parameter(Mandatory = $true, Position = 4)] [string]$PAT
)

$BaseURL = "https://artifactory-china.ta.philips.com:443/artifactory/api/search/aql"
$AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($PAT))
$Headers = @{"Authorization" = "Basic $AuthToken"; "Content-Type" = "text/plain" }


$pathQuery = if($Path -eq ""){ "{`"`$match`":`"*`"}" } else { "{`"`$eq`":`"$Path`"}" }

$msiData = @"
items.find(
    {
        "repo":{"`$match":"$Repo"},
        "name":{"`$match":"$Name.$Ver.nupkg"},
        "path":$pathQuery,
        "@nuget.version":{"`$eq":"$Ver"}
    }
)
"@

$nupkgData = @"
items.find(
    {
        "repo":{"`$match":"$Repo"},
        "name":{"`$match":"$Name.msi"},
        "path":$pathQuery,
        "@nuget.version":{"`$eq":"$Ver"}
    }
)
"@

$msiResult = Invoke-RestMethod -Uri $BaseURL -Method POST -Headers $Headers -Body $msiData -UseBasicParsing
$nupkgResult = Invoke-RestMethod -Uri $BaseURL -Method POST -Headers $Headers -Body $nupkgData -UseBasicParsing
$result = $msiResult.results + $nupkgResult.results
Write-Host "Query result: " $result
return $result