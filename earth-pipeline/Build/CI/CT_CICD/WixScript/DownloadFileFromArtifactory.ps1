

param(
    [Parameter(Mandatory=$true)]
    [string]$ArtifactoryUrl,
    [Parameter(Mandatory=$true)]
    [string]$Output,
    [Parameter(Mandatory=$true)]    
    [string]$Username,
    [Parameter(Mandatory=$true)]
    [string]$Password
)

 Write-Host $ArtifactoryUrl
 Write-Host $Output
 Write-Host $Username
 Write-Host $Password


if ($ArtifactoryUrl -notmatch '^(https?)://[\w\-\.]+(:\d+)?(/\S*)?$') {
    Write-Host "Invalid URL format: $ArtifactoryUrl" -ForegroundColor Red
    exit 2
}

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$Username`:$Password"))


# Check if Output is not empty or whitespace
if (![string]::IsNullOrWhiteSpace($Output)) {
    if (Test-Path -Path $Output) {
        Write-Host "Warning: Output file $Output already exists. It will be deleted." -ForegroundColor Yellow
        Remove-Item -Path $Output -Force
    }
    $outputDir = Split-Path -Path $Output -Parent
    if (![string]::IsNullOrWhiteSpace($outputDir) -and !(Test-Path -Path $outputDir)) {
        Write-Host "Output directory does not exist. Creating recursively: $outputDir" -ForegroundColor Yellow
        $null = New-Item -Path $outputDir -ItemType Directory -Force -ErrorAction Stop
    }
} 

try {
    Invoke-WebRequest -Uri $ArtifactoryUrl -OutFile $Output -Headers @{ Authorization = "Basic $base64AuthInfo" } -ErrorAction Stop
    Write-Host "Download completed: $Output" -ForegroundColor Green
} catch {
    Write-Host "Download failed: $($_.Exception.Message)" -ForegroundColor Red
    if (Test-Path -Path $Output) { Remove-Item -Path $Output -Force }
    exit 1
}