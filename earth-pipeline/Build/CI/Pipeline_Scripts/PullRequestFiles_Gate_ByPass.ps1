$pat = $args[0]
$PRID = $args[1]
$PRbypasslable = $args[2]
$repoid=$args[3]

$encodedPat = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes(":$pat"))
 
$listurl="https://tfsemea1.ta.philips.com/tfs/TPC_Region26/IAP/_apis/git/repositories/$repoid/pullRequests/$PRID/labels/"

# Call the REST API
$resp = Invoke-RestMethod -Uri $listurl -Headers @{Authorization = "Basic $encodedPat"}
$PRlabel=$resp.value.name

if($PRlabel)
{
  
 if ($PRlabel -eq $PRbypasslable)
 {
  Write-Host "both equal"
 }
 else 
 {
 Write-Host "##vso[task.setvariable variable=var.PRSize;]true"
 }
}
else
{
 Write-Host "##vso[task.setvariable variable=var.PRSize;]true"
}