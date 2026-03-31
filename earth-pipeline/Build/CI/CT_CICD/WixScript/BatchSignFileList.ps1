param(
    [Parameter(Mandatory=$true)]
    [string]$baseRoot
)

# Initialize execution result: default to success, set to false if any failure occurs
$ret = $true

# Define path to signtool (WITHOUT extra quotes)
$signtoolPath = "C:\Program Files (x86)\Windows Kits\10\bin\10.0.18362.0\x64\signtool.exe"
# Verify if signtool exists
if (-not (Test-Path -Path $signtoolPath -PathType Leaf)) {
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Error: signtool.exe not found, please check the path: $signtoolPath" -ForegroundColor Red
    exit 1
}

$pfxPath = "C:\Windows\System32\PhilipsRSD.pfx"
$pfxPassword = "1234567890te"
$timestampUrl = "http://timestamp.digicert.com/"

# Optimized execution function (fix quote duplication)
function ExecuteCmd {
    param(
        [string]$executable,
        [array]$arguments
    )
    try {
        # Generate unique log file names
        $timestamp = Get-Date -Format 'yyyyMMddHHmmss'
        $errorLog = "error_$timestamp.log"
        $outputLog = "output_$timestamp.log"

        # Use Start-Process (PowerShell recommended way) - NO extra quotes
        $process = Start-Process -FilePath $executable `
            -ArgumentList $arguments `
            -NoNewWindow `
            -Wait `
            -PassThru `
            -RedirectStandardError $errorLog `
            -RedirectStandardOutput $outputLog

        return $process.ExitCode -eq 0
    }
    catch {
        Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Exception occurred while executing command: $_" -ForegroundColor Red
        return $false
    }
}

function PrintMessage {
    param(
        [string]$message,
        [ConsoleColor]$color = [ConsoleColor]::White
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Write-Host "[$timestamp] $message" -ForegroundColor $color
}

# Combine path to signature list file
$strSignedListFile = Join-Path -Path $baseRoot -ChildPath "Build\Actions\Sign\SignList.txt"

if (-not (Test-Path -Path $strSignedListFile -PathType Leaf)) {
    PrintMessage "File $strSignedListFile does not exist!" -ForegroundColor Red
    $ret = $false
    exit 0
}

# Read signature list (filter empty/comment lines)
$files = Get-Content -Path $strSignedListFile | 
    ForEach-Object { $_.Trim() } |
    Where-Object { 
        $_ -notmatch '^\s*$' -and $_ -notmatch '^\s*#'
    }

if ($files.Count -eq 0) {
    PrintMessage "No files need to be signed" -ForegroundColor Yellow
    $ret = $false
    exit 0
}

# Traverse files for signing
foreach ($fileName in $files) {
    $strFile = Join-Path -Path $baseRoot -ChildPath "Output\$fileName"

    if (-not (Test-Path -Path $strFile -PathType Leaf)) {
        PrintMessage "File $strFile does not exist, skipping!" -ForegroundColor Red
        $ret = $false
        continue
    }

    PrintMessage "Start signing file: $strFile" -ForegroundColor Cyan

    # Build arguments as ARRAY (NO manual quotes - PowerShell handles it)
    $signArgs = @(
        "sign",
        "/f", $pfxPath,       # NO extra quotes here
        "/p", $pfxPassword,   # NO extra quotes here
        $strFile              # NO extra quotes here
    )

    # Execute sign command
    if (-not (ExecuteCmd -executable $signtoolPath -arguments $signArgs)) {
        PrintMessage "Failed to sign file: $strFile" -ForegroundColor Red
        $ret = $false
        continue
    }

    # Build timestamp arguments
    $timestampArgs = @(
        "timestamp",
        "/t", $timestampUrl,
        $strFile
    )

    # Execute timestamp command
    if (-not (ExecuteCmd -executable $signtoolPath -arguments $timestampArgs)) {
        PrintMessage "Failed to add timestamp to file: $strFile" -ForegroundColor Red
        $ret = $false
        continue
    }

    PrintMessage "Successfully signed file: $strFile" -ForegroundColor Green
}

PrintMessage "Batch signing completed, execution result: $ret" -ForegroundColor Blue
exit ($ret?0:1)