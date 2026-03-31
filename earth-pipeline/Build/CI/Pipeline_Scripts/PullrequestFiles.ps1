#################################################################################################################################################################
##  																														                                    #
##    Script Name: Pullrequestfiles.ps1                                                                                                                         #                  
##	  Parameters:                                                                                                                                               #
##        PullrequestID = TFS predefined variables $(PullrequestID)                                                                                             # 
##        ReposID =  Repos ID of Offconsole                                                                                                                     #
##		  ProjectURL =  Azure devops Project URL                                                                                                                #
##        PRDirectory = TFS predefined variables $(build.sourcesdirectory)																					 	#	                                                            #
##        Output: Generate the textfile which contain the path of Pull request files                                                                            #                                                # 
##                                                                                   									                                        #
##      TFS Version: Azure DevOps Server	  																				                                    #
##		OWNER = Indresh.Mourya@philips.com 																				     
##                                                                                                                           
#################################################################################################################################################################   

$PullrequestID = $args[0]
$ReposID= $args[1]
$ProjectURL= $args[2]
$PRDirectory= $args[3]

#=========================== Azure devops Rest API for finding the latest itearation and changes of files=================================#
$URL_Iteration="$ProjectURL/_apis/git/repositories/$ReposID/pullRequests/$PullrequestID/iterations?api-version=5.0" #Retrieve a Iteration
$IterationDetail = Invoke-RestMethod -Uri $URL_Iteration -UseDefaultCredentials #Invoke rest API 
$LatestIterationID=$IterationDetail.value.id | Select-Object -Last 1  
$URL_ItearationPR="$ProjectURL/_apis/git/repositories/$ReposID/pullRequests/$PullrequestID/iterations/$LatestIterationID/changes?api-version=5.0" #Retrieve a pull request
$PRFilesPath = Invoke-RestMethod -Uri $URL_ItearationPR -Method Get -ContentType "application/json" -UseDefaultCredentials #Invoke rest API 
$PRChanges=$PRFilesPath.changeEntries
#=========================== ********************************************************====================================================#

#=========================== Function to create PR textfile of pull request files========================================================#
function PRpath{

$PR_file=New-item $PRDirectory\$PullrequestID.txt  # Create new file in Build source directory
$vartype=$PRChanges.GetType()
if($vartype.Name -eq "PSCustomObject")
{
    
    
    write-output $PRChanges.Item.path 
    Add-Content -Path $PR_file -Value $PRChanges.Item.path #append the modified files name into text file.

}
else{
for($i = 0; $i -lt $PRChanges.Count; $i++) 

{ 
    write-output $PRChanges.Item($i).item.path | Tee-Object -filePath $PR_file -Append
} 
}
}
#=========================*****End of the function******========================================================#
#Calling function
PRpath







