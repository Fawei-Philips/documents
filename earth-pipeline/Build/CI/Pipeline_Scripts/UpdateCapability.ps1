
Param(
[parameter(Position=0,Mandatory=$true,HelpMessage="Give the agent pool id of IAP")][int]$poolid,
[parameter(Position=1,Mandatory=$true,HelpMessage="Give the agent id of IAP.")][int]$agentid,
[parameter(Position=2,Mandatory=$true,HelpMessage="Give the IAP team project url.")][string]$url,
[parameter(Position=3,Mandatory=$true,HelpMessage="The tags to added as a block of JSON ")]$cap,
[parameter(Position=4,Mandatory=$true,HelpMessage="Personal Access Token with rights to manage agents")]$patToken,
[parameter(Position=5,Mandatory=$true,HelpMessage="capabilitis name of a agent")]$CapName
)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$encodedPat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$patToken"))

$listurl="$url/_apis/distributedtask/pools/$poolid/agents/$agentid/usercapabilities?api-version=5.0-preview.1"

function Body
{
$value = @{}
$value = @"
    {"$CapName":"$cap"}
"@
 return $value
}
$json = Body

# Call the REST API
$resp = Invoke-RestMethod -Uri $listurl -Method PUT -Headers @{Authorization = "Basic $encodedPat"} -Body $json -ContentType "application/json"