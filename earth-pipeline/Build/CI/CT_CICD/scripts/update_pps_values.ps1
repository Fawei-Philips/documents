# Author: Srikanth H S (320187230)

# The script Updates the values to EGS DB based on the latest EGS Values

# Script performs below steps to update EGS
# Fetches values from EGS DB
# Fetches values from Latest EGS generated xml
# Compare Values and update EGS DB

# Usage: \update_pps_values.ps1 <Project> <ParentBuildVersion> <ArtifactPath> <PAT> 

# Options:
#  Project: Project name.
#  ParentBuildVersion: BuildVersion.
#  ArtifactPath: Artifact Path.
#  PAT: Rest API PAT from ADS

# Example: .\update_pps_values.ps1 -Project "CT_ReconDeviceAbs" -ParentBuildVersion "CT_ReconDeviceAbs_Nightly_20250123.2" -ArtifactPath "$(Build.ArtifactStagingDirectory)" -PAT "$(PAT_ing07471)"

param(    
    [Parameter(Mandatory = $true, Position = 1)] [string]$Project,
    [Parameter(Mandatory = $true, Position = 2)] [string]$ParentBuildVersion,
    [Parameter(Mandatory = $true, Position = 3)] [string]$ArtifactPath,
    [Parameter(Mandatory = $true, Position = 8)] [string]$PAT
)


function fetchCategory
{
 param (
        [string[]]$Category
    )

    $value = $result | Where-Object { $_ -like "$category*" }

    # Split the found value on '-' and get the second part
    if ($value) {
        $finalValue = $value.Split('-')[1]    
        Write-Host "Database $Category = $finalValue"
        return $finalValue
    } else {
         Write-Host "Database Critical value not found"
         return $null
    }

}

try 
{
    Write-Host $Project
    Write-Host $ParentBuildVersion
    Write-Host $ArtifactPath

    #If executed at end build should be passed
    $ProjectSettingsStatus = "Passed"

    $script:User = "code1\ing07471"
    $script:Base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $User, $PAT)))

    $urlUpdate = "http://ingbtcpic7vw002:8098/api/BuildMetrics/upsertBuildSummary"
    $api = "http://ingbtcpic7vw002:8098/api/GetProjectSettingsLatestBuildSummary?projectName=$Project"
    Write-Host $api

    $egsLow = 0
    $egsMedium = 0
    $egsHigh = 0
    $egsCritical = 0

    #Compare Values and update database
    $updateDB = "false"

    $criticalCount = 0
    $HighCount = 0
    $MediumCount = 0
    $LowCount = 0

    #Fetch values from EGS generated files \ProjectScanner\*.xml
    Get-ChildItem "$ArtifactPath\ProjectScanner\*.xml" -recurse |
    %{
        Write-Host $_.FullName
        $xmlContent = [xml](Get-Content -Path $_.FullName)
        $critical = $xmlContent.ViolationSummary.Violations.ViolationInfo | Where-Object Level -Match 'Critical' 
        $criticalCount = $criticalCount + $critical.Count

        $High = $xmlContent.ViolationSummary.Violations.ViolationInfo | Where-Object Level -Match 'High' 
        $HighCount = $HighCount + $High.Count

        $Medium = $xmlContent.ViolationSummary.Violations.ViolationInfo | Where-Object Level -Match 'Medium' 
        $MediumCount = $MediumCount + $Medium.Count

        $Low = $xmlContent.ViolationSummary.Violations.ViolationInfo | Where-Object Level -Match 'Low' 
        $LowCount = $LowCount + $Low.Count

    }

    Write-Host "Latest Critical is $criticalCount"
    Write-Host "Latest High is $HighCount"
    Write-Host "Latest Medium is $MediumCount"
    Write-Host "Latest Low is $LowCount"
    #Fetch values END


    #Invoke rest API for DB values
    $response = Invoke-RestMethod -ContentType "application/json" -Uri $api -Method "Get"-UseDefaultCredentials
    Write-Host $response

    $successCheck = $response.Contains("success")

    if($successCheck)
    {
        Write-Host $success
        # Extract the substring starting from "Low"
        $result = $response.Substring($response.IndexOf("Low")).Trim('"').Trim('}').Split(',') | ForEach-Object { $_.Trim() }
    
        # Find the value that starts with the specified category (case-insensitive)
        $egsLow = fetchCategory("Low")
        $egsMedium = fetchCategory("Medium")
        $egsHigh = fetchCategory("High")
        $egsCritical = fetchCategory("Critical")    

        if ($egsLow -ne $LowCount)
        {
            $updateDB = "true"
        }
        elseif ($egsMedium -ne $MediumCount)
        {
            $updateDB = "true"
        }
        elseif ($egsHigh -ne $HighCount)
        {
            $updateDB = "true"
        }
        elseif ($egsCritical -ne $criticalCount)
        {
            $updateDB = "true"
        }
    }
    else
    {
        Write-Host "Update default values to DB"
        $updateDB = "true"
    }    

    #Update value if any one value is updated
    if($updateDB -eq "true")
    {    
    
        $body='{"_id":"'+$ParentBuildVersion+'","_Steps":{"_StepDetailedInfo":{"_ProjectSettingsCheckInfo":{"_Status":"'+$ProjectSettingsStatus +'","_ResultSummary":"Low-'+$LowCount +',Medium-'+$MediumCount+',High-'+$HighCount+',Critical-'+$CriticalCount+'"}}}}'
    
        $updateResp = Invoke-RestMethod -Uri $urlUpdate -ContentType "application/json" -Method POST -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo)} -Body $body
        if($updateResp -eq "True")
        {
            Write-Host "Updated EGS values to DB successfully"
        }
        else
        {
            Write-Host "Error during updating values to EGS DB"
        }
    }
    else
    {
        Write-Host "Valus are same as EGS DB update is not required"
    }
}
catch {
    Write-Host $Error[0]
    Write-Error "There were some errors while updating EGS. Please check the logs above for more details."
    return 1
}