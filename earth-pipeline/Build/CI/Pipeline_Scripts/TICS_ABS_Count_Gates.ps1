$callfun=$args[0]
$SourcesDirectory=$args[1]
$ProjectName = "Navigation"

[xml]$gates_count=Get-Content "$SourcesDirectory/Build/CodeQuality_Gates/Values.xml"

$AI_ABS_Thr=$gates_count.Gates.TICS.Project.AbsoluteValues.AbstractInterpretation
$CW_Supp_Thr=$gates_count.Gates.TICS.Project.Suppresions.CompilerSuppresionCount
$AI_Supp_Thr=$gates_count.Gates.TICS.Project.Suppresions.AbstractInterpretationSuppresionCount

Function AI_ABS_Count
{
$int_url="https://tics-pic.ta.philips.com/tiobeweb/DI/api/public/v1/Measure?nodes=HIE://$ProjectName/trunk&metrics=G(Violations(AI))"
$Int_abtvalue = Invoke-RestMethod -Method Get -Uri $int_url
$Int_ABS_INT=$Int_abtvalue.data.value
Write-Output "$ProjectName Current Abstract Interpretation value $Int_ABS_INT"
if($Int_ABS_INT -gt $AI_ABS_Thr){
Write-Output "$ProjectName Current Abstract Interpretation value $Int_ABS_INT is greater than the base value $AI_ABS_Thr"
Write-Output "##vso[task.logissue type=error;]TICS-Gate: $ProjectName Abstract Interpretation Number of Violations failed --> Current Number of AI Violations '$Int_ABS_INT' is greater than the base value '$AI_ABS_Thr'"
Write-Output "##vso[task.complete result=Failed]Error detected"
}
}


Function CW_Suppression
{
$int_com="https://tics-pic.ta.philips.com/tiobeweb/DI/api/public/v1/Measure?nodes=HIE://$ProjectName/trunk&metrics=G(Violations(CW),Suppressions(yes))"
$int_CW_Supp = Invoke-RestMethod -Method Get -Uri $int_com
$interfaces_CW_Supp=$int_CW_Supp.data.value
Write-Output "$ProjectName Current Compiler warning suppression is: $interfaces_CW_Supp"

if($interfaces_CW_Supp -gt $CW_Supp_Thr){
Write-Output "In $ProjectName Current Compiler Warning Suppression value $interfaces_CW_Supp is greater than the base value $CW_Supp_Thr"
Write-Output "##vso[task.logissue type=error;]TICS-Gate: $ProjectName Compiler Warning Suppression failed --> Current Number of Compiler Warning Suppression '$interfaces_CW_Supp' is greater than the base value $CW_Supp_Thr"
Write-Output "##vso[task.complete result=Failed]Error detected"
}
}

Function AI_Suppression
{
$url_I="https://tics-pic.ta.philips.com/tiobeweb/DI/api/public/v1/Measure?nodes=HIE://$ProjectName/trunk&metrics=G(Violations(AI),Suppressions(yes))"
$I_AI_Supp = Invoke-RestMethod -Method Get -Uri $url_I
$I_AI_Count=$I_AI_Supp.data.value
Write-Output "Current $ProjectName AI Suppression count is $I_AI_Count"
if($I_AI_Count -gt $AI_Supp_Thr){
Write-Output " In $ProjectName Current AI Suppression value $I_AI_Count , greater than the base value $AI_Supp_Thr"
Write-Output "##vso[task.logissue type=error;]TICS-Gate: $ProjectName Abstract Interpretation Suppression Count failed --> Current Number of AI Suppression count $I_AI_Count is greater than the base value $AI_Supp_Thr"
Write-Output "##vso[task.complete result=Failed]Error detected"
}
}

 Function call_gates{
 if($callfun -eq "AI_ABS_Count")
 {
 AI_ABS_Count
 } 
 elseif($callfun -eq "CW_Suppression")
 {
 CW_Suppression
 }
 elseif($callfun -eq "AI_Suppression")
 {
 AI_Suppression
 }
 }

 call_gates

