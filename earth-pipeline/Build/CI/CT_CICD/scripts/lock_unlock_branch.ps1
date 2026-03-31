param(
    [Parameter(Mandatory = $false, Position = 0)] [string]$Region = "TPC_Region26",
    [Parameter(Mandatory = $false, Position = 1)] [string]$Project = "CT-GlobalSW",
    [Parameter(Mandatory = $true, Position = 2)] [string]$RepoName,
    [Parameter(Mandatory = $true, Position = 3)] [string]$Branch,
    [Parameter(Mandatory = $true, Position = 4)] [bool]$Lock,
    [Parameter(Mandatory = $true, Position = 5)] [string]$Auth
)

$AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$Auth"))
$Headers = @{"Authorization" = "Basic $AuthToken"; "Content-Type" = "application/json" }
$BranchBaseURL = "https://tfsemea1.ta.philips.com/tfs/$Region/$Project/_apis/git/repositories/$RepoName/refs?filter=heads/$($Branch)&api-version=6.0-preview"

if ($Lock) { $Body = @{"isLocked" = $true } }
else { $Body = @{"isLocked" = $false } }

Write-Host "Updating Branch State: isLocked" $Body.isLocked 
try {
    Invoke-RestMethod -Method Patch -Uri $BranchBaseURL -Headers $Headers -Body ($Body | ConvertTo-Json -Depth 20)
}
catch {
    Write-Host $Error[0]
    Write-Error "Could not update the branch state. Please check the logs above. Exiting..." -ErrorAction Stop
}