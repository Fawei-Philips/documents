<# 
Author: Mulakala Chaitanya (320218691) 

The script does the following
    1) Copies the repo specific config files to D:\ drive 
    2) Uses nunit-console to run the unit tests from the path - "[repoBaseDir]\Output\OutTests".

Tools used: 
    Nunit 2.6.3

Parameters for script:
    repoPath: (Required) Path to root directory of the repository.

Follow these steps:
- Launch Powershell
- Navigate to root directory of the repository.
- Run following commands: 
    cd .\Build\CI\CT_CICD\scripts
    .\clean_up.ps1 "D:\Config,D:\PCC,D:\Database"
    .\NUnitTesting.ps1 [repoPath]

Pre-Requisite:
    Before running NUnitTesting.ps1 script, you must run the clean up script using the below command:
    .\clean_up.ps1 "D:\Config,D:\PCC,D:\Database"
    "$($repoPath)\Tools\Tools.1.0.2\NUnit-2.6.3\bin\nunit-console.exe" should be present.

Usage: . [relative/absolute path to NUnitTesting.ps1] [repoPath]

Example: . 'c:\Cloned Repos\CT_CICD\scripts\NUnitTesting.ps1' 'C:\Cloned Repos\CT_Serviceability'

#>


# Input and initializing path variables
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)][string]$repoPath,
    [Parameter(Mandatory = $true)][string]$repoName,
    [Parameter(Mandatory = $true)][string]$BuildID,
    [Parameter(Mandatory = $true)][string]$Toolsversion,
    [Parameter(Mandatory = $false)][bool]$RunDotcover,
    [Parameter(Mandatory = $false)][string]$SharedPath,
    [Parameter(Mandatory = $false)][string]$reportPath,
    [Parameter(Mandatory = $false)][string]$NunitList,
    [Parameter(Mandatory = $false)][string]$TestBaseDir,
    [Parameter(Mandatory = $false)][string]$dotnetcore
    
)

Write-Host "repoPath: $repoPath"
Write-Host "repoName: $repoName"
Write-Host "BuildID: $BuildID"
Write-Host "Toolsversion: $Toolsversion"
Write-Host "RunDotcover: $RunDotcover"
Write-Host "SharedPath: $SharedPath"
Write-Host "reportPath: $reportPath"
Write-Host "NunitList: $NunitList"
Write-Host "TestBaseDir: $TestBaseDir"
Write-Host "dotnetcore: $dotnetcore"

$date = Get-Date -Format "yyyyMMdd_HHmmss"

$NcoverProject = $repoName
$BuildNumber = "$BuildID"
$srcDir = "$($reportPath)\$NcoverProject"
$srcFile = "$($srcDir)\$NcoverProject.xml"
$dstFile = "$($SharedPath)\$($NcoverProject)\Ncover\$($NcoverProject)_$($date).xml"
$dstDir = "$($SharedPath)\$($NcoverProject)\Ncover"
$dstNunitDir = "$($SharedPath)\$($NcoverProject)\NunitTest"

Write-Host "`$NcoverProject: $NcoverProject"
Write-Host "`$BuildNumber: $BuildNumber"
Write-Host "`$srcDir: $srcDir"
Write-Host "`$srcFile: $srcFile"
Write-Host "`$dstDir: $dstDir"
Write-Host "`$dstFile: $dstFile"
Write-Host "`$dstNunitDir: $dstNunitDir"

function Write-Logs {
    param ([string]$message, [array]$array, [bool]$console)
    $count = 0
    if ($console) {
        Write-Host "---------------------------------------------------------" -ForegroundColor Blue
        [System.Console]::WriteLine("`n$message")
    }
    else {
        Write-Host "---------------------------------------------------------" -ForegroundColor Blue
        Write-Host "`n$message"
    }
    foreach ($item in $array) {
        $count += 1
        if ($console) {
            [System.Console]::WriteLine("`n$message")
            [System.Console]::WriteLine("$count) $item`n")
        }
        else {
            Write-Host "$count) $item`n"
        }
    }
}

function execNunit {
    [CmdletBinding()]
    param ([string]$ExePath, [string]$test, [string]$Params)

    process {
        $stdoutfile = -join ("$test", ".log")
        $stderrfile = -join ("$test", ".err.log")
        
        $StartProc = Start-Process -FilePath $ExePath "$test $Params" -PassThru -NoNewWindow -RedirectStandardOutput "$stdoutfile" -RedirectStandardError "$stderrfile"
        $StartProcHandle = $StartProc.Handle 
        Write-Host "Cached process handle: " $StartProcHandle
        $StartProc.WaitForExit()
        $stdout = (Get-Content $stdoutfile) -join ("`n")
        $stderr = (Get-Content $stderrfile) -join ("`n" )
        Write-Host "stdout: $stdout"
        Write-Host "stderr: $stderr"
        return $StartProc.ExitCode
    }
}
function stopProc {
    [CmdletBinding()]
    param ([string]$proc)

    $ProcThread = Get-Process -Name $proc -ErrorAction SilentlyContinue 

    if ($ProcThread) {
        $ProcThread | ForEach-Object {
            if (Get-Process -Id $_.Id -ErrorAction SilentlyContinue) {
                Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
                Write-Host ("Stopped Process: $($_.Id)")
            }
        }            
    }
    else {
        Write-Host "No process named '$proc' was found."
    }
}
function retry {
    param(
        [string]$pattern,
        [string]$text,
        [int]$maxRetries = 5,
        [int]$waitTime = 60
    )

    $retrycount = 0
    while ($retrycount -lt $maxRetries) {
        if ($text -cmatch $pattern) {
            Write-Host "$text is a match $pattern"
            Write-Host "Able to query the execution"
            return
        }
        else {
            Write-Host "Not ready. Retrying..."
            $retrycount++
        }

        Start-Sleep -Seconds $waitTime
    }

    Write-Host "Still not able to query after 1 min. Exiting"

}

function copyReport {
    [CmdletBinding()]
    param ([string]$srcFile, [string]$dstFile)

    try {
        Write-Host "New non-empty report found, copying to shared path..."                        
        Copy-Item -Path $srcFile -Destination $dstFile -Force -ErrorAction Stop
        Write-Host "File successfully copied to : '$dstFile'"                      
    }
    catch {
        Write-Host "##vso[task.logissue type=warning;]Reason: $($_.Exception.Message)"
        Write-Host "##vso[task.complete result=SucceededWithIssues;]Reason: $($_.Exception.Message)"
    }      
}

function Nunit {
    $testResultPath = "$repoPath\Output\OutTests\test-results.xml"
    $outTestsPath = "$repoPath\Output\OutTests"
    $nunitConsole = "$repoPath\Tools\Tools.$Toolsversion\NUnit-2.6.3\bin\nunit-console.exe"
    $dotcoverpath = "$repopath\Tools\Tools.$Toolsversion\dotcover\dotcover.exe"
    $currentWorkingDir = Get-Location
    $dotnetpath = "C:\Program Files\dotnet\dotnet.exe"


    # Copying required config files and folders into D:\ drive
    $outCfgPath = "$repoPath\Output\OutCfg\Base\*" 
    $outResPath = "$repoPath\Output\OutRes\Base\*"
    $destinationPath = "D:\"

    $ExcludeListPath = "$repoPath\Build\CI\CT_CICD\Config\GlobalExcludeTests.txt"
    Write-Host "Nunit Exclude List Path: '$ExcludeListPath'"
    if (Test-Path $outCfgPath) {
        Write-Host -NoNewline "`nCopying contents of: "; Write-Host -NoNewline "$outCfgPath" -ForegroundColor Green
        Write-Host -NoNewline " to: "; Write-Host "$destinationPath" -ForegroundColor Green
        Copy-Item -Path $outCfgPath -Destination $destinationPath -Force -Recurse 
    } 
    if (Test-Path $outResPath) {
        Write-Host -NoNewline "`nCopying contents of: "; Write-Host -NoNewline "$outResPath" -ForegroundColor Green
        Write-Host -NoNewline " to: "; Write-Host "$destinationPath" -ForegroundColor Green
        Copy-Item -Path $outResPath -Destination $destinationPath -Force -Recurse 
    } 
    
    # Filtering out the test dll's for NUnit testing
    if ("$NunitList".Length -gt 0) {
        $testDlls = Get-Content $NunitList | ForEach-Object { "$_".Trim() }
    }
    else {
        $testDlls = Get-ChildItem -Path $outTestsPath -Include "*Tests.dll", "*Test.dll" -Recurse -ErrorAction SilentlyContinue
    }
    
    if (Test-Path -Path $ExcludeListPath -PathType Leaf) {
        Write-Host "Found Nunit Exclude List at: '$ExcludeListPath'"
        $ExcludeList = Get-Content $ExcludeListPath | ForEach-Object { "$_".Trim() }
        Write-Host "Nunit Exclude List content:" $ExcludeList
        $testDlls = $testDlls | Where-Object -Property Name -notin $ExcludeList
    }
    
    # Initializing local variables
    $totalTests = 0
    $totalFailures = 0
    $totalErrors = 0
    $totalInconclusive = 0
    [float]$totalTime = 0
    $notRun = 0
    $invalid = 0
    $ignored = 0
    $skipped = 0
    $counter = 0
    $errors = 0
    $failures = 0
    $listOfTestErrors = @()
    
    $totalNcoverFailures = 0
    $listOfNCoverFailures = @()
    
    $totalNunitFailures = 0
    $listOfNunitFailures = @()
    
    # Running tests
    if ("$TestBaseDir".Length -gt 0) {
        Set-Location $TestBaseDir
        Write-Host -NoNewline "`nChanging directory to: "; Write-Host -NoNewline "$TestBaseDir`n" -ForegroundColor Green
    }
    else {
        Set-Location $outTestsPath
        Write-Host -NoNewline "`nChanging directory to: "; Write-Host -NoNewline "$outTestsPath`n" -ForegroundColor Green
    }
    Write-Host -NoNewline "`nRunning tests using: "; Write-Host "$nunitConsole" -ForegroundColor Green
    Write-Host "---------------------------------------------------------" -ForegroundColor Blue

    if ($null -ne $testDlls) {
        try {
            foreach ($test in $testDlls) {                

                #Running NUnit tests

                if (-Not $dotnetcore) {
                    $counter += 1			
                    Write-Host "$counter) Testing: $test" -ForegroundColor Cyan
                    $result = 'test-results'
                    $testArgs = "/noshadow /result:$testResultPath"
                    $testProc = execNunit -ExePath $nunitConsole -test $test -Params $testArgs
                    Write-Host "Nunit Exit Code:$testProc"
                    if ($testProc -ne 0) {
                        $totalNunitFailures += 1
                        $listOfNunitFailures += $test
                    }
                    Write-Host "Nunit failure count:" $totalNunitFailures
                    stopProc -proc "nunit-console"
                    stopProc -proc "nunit-agent"
                }
                else {
                    $counter += 1			
                    Write-Host "$counter) Testing: $test" -ForegroundColor Cyan
                    $result = 'test-run'
                    $testProc = & $dotnetpath test $test --no-restore --test-adapter-path "Dependencies\Ref\nunit\4.2.2" --logger "nunit;LogFilePath=$testResultPath"
                    $exiteCode = $LASTEXITCODE
                    Write-Host "dotnet Exit Code:$exiteCode"
                    $testProcOutput = $testProc | Out-String
                    $testProcLines = $testProcOutput -split "`n"
                    foreach ($line in $testProcLines) {
                        Write-Host $line
                    }
                    if ($exiteCode -ne 0) {
                        $totalNunitFailures += 1
                        $listOfNunitFailures += $test
                    }
                }

                # Parse the test results
                if (Test-Path $testResultPath) {
                    $testResults = [xml](Get-Content $testResultPath)
                    $errors = [int]$testResults.$result.getAttribute("errors")
                    $failures = [int]$testResults.$result.getAttribute("failures")
                    $totalErrors += $errors
                    $totalFailures += $failures
                    $totalTests += [int]$testResults.$result.getAttribute("total")
                    $totalInconclusive += [int]$testResults.$result.getAttribute("inconclusive")
                    $totalTime += [float]$testResults.$result.getAttribute("duration")
                    $notRun += [int]$testResults.$result.getAttribute("not-run")
                    $invalid += [int]$testResults.$result.getAttribute("invalid")
                    $ignored += [int]$testResults.$result.getAttribute("ignored")
                    $skipped += [int]$testResults.$result.getAttribute("skipped")
                    $skipped += [int]$testResults.$result.getAttribute("skipped")
                    if (($errors -gt 0) -or ($failures -gt 0)) {
                        $listOfTestErrors += $test
                    }

                    #copy nunit result
                    Write-Host "Begin to copy Nunit result ...."
                    Write-Host "testResultPath: $testResultPath"
                    $dstNunitFile = "$($SharedPath)\$($NcoverProject)\NunitTest\$($NcoverProject)_$($test)_$($date).xml"
                    Write-Host "dstNunitFile: $dstNunitFile"
                    if (-not (Test-Path $dstNunitDir)) {
                        New-Item -Path $dstNunitDir -ItemType Directory | Out-Null
                    }
                    copyReport $testResultPath $dstNunitFile
                }
                else {
                    Write-Host "Error: Could not generate test-results.xml for $test" -ForegroundColor Red
                }

                if ($RunDotcover) {
                    Write-Host "Running dotcover..."
					
                    $cwd = Get-Location
                    Write-Host "Coverage for test:$test"
                    $testName = [System.IO.Path]::GetFileNameWithoutExtension($test)

                    if (-not $dotnetcore) {
                        $runDC = & $dotcoverpath cover --output="$($srcDir)\$testName.dcvr" --TargetExecutable="$nunitConsole" --TargetArguments="$test /noshadow /result:$($srcDir)\$testName.xml " --WorkingDir=$cwd --DisableNGen
                    }
                    else {
                        $runDC = & $dotcoverpath cover /TargetExecutable="$dotnetpath" /TargetArguments="test $test --Logger:trx --test-adapter-path Dependencies\Ref\nunit\4.2.2" /Output="$($srcDir)\$testName.dcvr" --WorkingDir=$cwd
                    }
                    $exiteCode = $LASTEXITCODE
                    Write-Host "Dotcover Exite code: $exiteCode"
                    $runDCOutput = $runDC | Out-String
                    $runDCLines = $runDCOutput -split "`n"
                    foreach ($line in $runDCLines) {
                        Write-Host $line
                    }
                    if ($exiteCode -ne 0) {
                        $totalNcoverFailures += 1
                        $listOfNCoverFailures += $test
                    }
                }
            }
            Write-Host "`nFinished running tests" -ForegroundColor Green
            if (($totalErrors -gt 0) -or ($totalFailures -gt 0)) {
                Write-Logs -message "Following test(s) failed: " -array $listOfTestErrors
                Write-Logs -message "Following test(s) failed: " -array $listOfTestErrors -console $true
                exit 1
            }
		   
            if ($totalNcoverFailures -gt 0) {
                Write-Logs -message "Total DotCover Failures: $totalNcoverFailures" -array $listOfNCoverFailures
                Write-Logs -message "Total DotCover Failures: $totalNcoverFailures" -array $listOfNCoverFailures -console $true
                exit 1
            }
        }
        catch {
            Write-Host "An error occurred while running the tests:`n"
            Write-Host $_
        }
    }
    else {
        Write-Host "Skipping the Nunit and coverage as no testdll's are found...."
    }
    
    if (-not $RunDotcover) {
        Write-Host "`nCumulative Results:" -ForegroundColor Green
        Write-Host "------------------------------------------------------" -ForegroundColor Green
        Write-Host "Tests run: $totalTests" -ForegroundColor Green
        Write-Host "Errors: $totalErrors" -ForegroundColor Green
        Write-Host "Failures: $totalFailures" -ForegroundColor Green
        Write-Host "Inconclusive: $totalInconclusive" -ForegroundColor Green
        Write-Host "Time: $totalTime seconds" -ForegroundColor Green
        Write-Host "Not run: $notRun" -ForegroundColor Green
        Write-Host "Invalid: $invalid" -ForegroundColor Green
        Write-Host "Ignored: $ignored" -ForegroundColor Green
        Write-Host "Skipped: $skipped" -ForegroundColor Green

        if ($totalNunitFailures -gt 0) {
            Write-Logs -message "Total Nunit Failures: $totalNunitFailures" -array $totalNunitFailures
            Write-Logs -message "Total Nunit Failures: $totalNunitFailures" -array $totalNunitFailures -console $true
            exit 1
        }
    }

    if ($RunDotcover) {
        Write-Host "Total DotCover errors: $totalNcoverFailures"
        if (Test-Path "$($srcDir)\*.dcvr") {
            & $dotcoverpath merge --Source="$($srcDir)\*.dcvr" --Output="$($srcDir)\$NcoverProject.dcvr"
            $testProc = & $dotcoverpath report /Source="$($srcDir)\$NcoverProject.dcvr" /Output="$($srcDir)\$NcoverProject.xml" /ReportType=DetailedXML
            $exiteCode = $LASTEXITCODE
            Write-Host "Dotcover Report Exite code: $exiteCode"
            $testProcOutput = $testProc | Out-String
            $testProcLines = $testProcOutput -split "`n"
            foreach ($line in $testProcLines) {
                Write-Host $line
            }
            try {
                if (Test-Path -Path $srcFile) {
                    $localFileSize = [math]::Round((Get-Item "$srcFile").Length / 1MB)
                    $sharedFileSize = [math]::Round((Get-Item "$dstFile").Length / 1MB)
                    Write-Host "source file size in MB $localFileSize"
                    Write-Host "shared path file size in MB $sharedFileSize"
                    if ($localFileSize -lt $sharedFileSize) {
                        throw "New report size is less than old report, skipping copy."
                    }
                    else {

                        Write-Host "Begin to copy Dotcover result ...."
                        Write-Host "srcFile: $srcFile"                    
                        Write-Host "dstFile: $dstFile"
                        if (-not (Test-Path $dstDir)) {
                            New-Item -Path $dstDir -ItemType Directory | Out-Null
                        }
                        copyReport $srcFile $dstFile
                    }
                }
                else {
                    throw "Report not found at $srcFile"
                }
            }
            catch {
                $res1 = @(
                    Write-Host "##vso[task.logissue type=warning;]Reason: $($_.Exception.Message)" 
                    Write-Host "##vso[task.complete result=SucceededWithIssues;]Reason: $($_.Exception.Message)"
                )
                return $res1
            } 
        }
    }
}
Write-Host "Running Nunit function..."
Nunit
