param(
    [Parameter(Mandatory = $false, Position = 0)] [string]$Region = "TPC_Region26",
    [Parameter(Mandatory = $false, Position = 1)] [string]$Project = "CT-GlobalSW",
    [Parameter(Mandatory = $true, Position = 2)] [string]$DefID,
    [Parameter(Mandatory = $true, Position = 3)] [bool]$Enable,
    [Parameter(Mandatory = $true, Position = 4)] [string]$Auth
)

$AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$Auth"))
$Headers = @{"Authorization" = "Basic $AuthToken"; "Content-Type" = "application/json" }
$DefBaseURL = "https://tfsemea1.ta.philips.com/tfs/$Region/$Project/_apis/build/definitions/$($DefID)?api-version=6.0-preview"

$DefData = $null;
Write-Host "Def URL:" $DefBaseURL

Write-Host "Authenticating..."
try {
    $DefData = Invoke-RestMethod -Method Get -Uri $DefBaseURL -Headers $Headers
    Write-Host "Authenticated."
}
catch {
    Write-Host $Error[0]
    Write-Error "Could not authenticate with PAT or definition id provided is incorrect. Please check the logs above. Exiting..." -ErrorAction Stop
}

Write-Host "Current Definition State:" $DefData.queueStatus
if ($Enable) {
    $DefData.queueStatus = "enabled"
}
else {
    $DefData.queueStatus = "disabled"
}

Write-Host "Updating Definition State:" $DefData.queueStatus
try {
    
    $NewDefData = Invoke-RestMethod -Method Put -Uri $DefBaseURL -Headers $Headers -Body ($DefData | ConvertTo-Json -Depth 20)
    
    Write-Host "New Definition state:" $NewDefData.queueStatus
}
catch {
    Write-Host $Error[0]
    Write-Error "Could not update the definition state. Please check the logs above. Exiting..." -ErrorAction Stop
}