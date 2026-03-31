import json
import re
import requests
import sys
import os


from requests_negotiate_sspi import HttpNegotiateAuth

prefix_branch_api_uri = ""
tfs_repositories_url = ""
tfs_prefix_url = ""'?api-version=4.0'""
rep_id = ""
ccexcep_str = []
ticsexcep_str = []
resharpexcep_str = []
ppsexcep_str = []
excep_app = []


pullRequestId = ""
file_in = ""
ccexcep_com = ""
ticsexcep_com = ""
resharpexcep_com = ""
ppsexcep_com = ""
ccexcep_com_auth = ""
ticsexcep_com_auth = ""
resharpexcep_com_auth = ""
ppsexcep_com_auth = ""


def extractInput(gate_inputs):
    if len(gate_inputs) == 0:
        print("CheckImpactModule.py <PR> <Config.json>")
        exit(1)
    pullRequestId = gate_inputs[1]
    file_in = gate_inputs[2]
   
   
    if not os.path.isfile(file_in) :
        print("Check the config file path...")
        exit(1)

    return pullRequestId, file_in
  
def update_config(file_in):  
    with open(file_in, "r") as json_data:
      _config_json = json.load(json_data)
      _tfs_values = _config_json['TFS']
      json_data.close()

      prefix_branch_api_uri = _tfs_values["PREFIX_BRANCH_API_URI"]
      tfs_repositories_url = prefix_branch_api_uri + 'git/repositories/'
      tfs_prefix_url = _tfs_values["TFS_PREFIX_URL"]
      rep_id = _tfs_values["REP_ID"]
      excep_app = _tfs_values["EXCEPTION_APPROVERS"]
      ccexcep_str = _tfs_values["CCEXCEPTION_STRING"]
      ticsexcep_str = _tfs_values["TICSEXCEPTION_STRING"]
      resharpexcep_str = _tfs_values["RESHARPEXCEPTION_STRING"]
      ppsexcep_str = _tfs_values["PPSEXCEPTION_STRING"]      
      cc_sup_str = _tfs_values["CCSUPP_STRING"]
      tics_sup_str = _tfs_values["TICSSUPP_STRING"]
      re_supp_str = _tfs_values["RESHARPSUPP_STRING"]
      pps_supp_str = _tfs_values["PPSSUPP_STRING"]

      return prefix_branch_api_uri, tfs_repositories_url, tfs_prefix_url,rep_id,excep_app,ccexcep_str,ticsexcep_str,resharpexcep_str,ppsexcep_str,cc_sup_str,tics_sup_str,re_supp_str,pps_supp_str 
  

def _getJson(url):
        print('Requesting:\n' + url)

        build = requests.get(url, auth=HttpNegotiateAuth())
        
        return build.json()


def main():
    pullRequestId, file_in  = extractInput(sys.argv)
    prefix_branch_api_uri, tfs_repositories_url, tfs_prefix_url,rep_id,excep_app,ccexcep_str,ticsexcep_str,resharpexcep_str,ppsexcep_str,cc_sup_str,tics_sup_str,re_supp_str,pps_supp_str=update_config(file_in)

    tfs_repositories_url = prefix_branch_api_uri + 'git/repositories/'
    uri_iter_prefix = tfs_repositories_url + rep_id + '/pullRequests/' + str(pullRequestId)  + "/threads"
    iterations_count_uri =  uri_iter_prefix  + tfs_prefix_url
  
    commit_changes_response = _getJson(iterations_count_uri)

   
    _changesInPullRequest = commit_changes_response
    ticsSuppReq = False
    reSuppReq = False
    ccSuppReq = False
    ppsSuppReq = False    
    resetCCpassGates = False
    resetTICSpassGates = False
    resetRepassGates = False
    resetPPSGates = False

    for change in _changesInPullRequest['value']:
       _comments = change['comments']
       for comment in _comments:      
            keys=comment.keys()
            if not 'isDeleted' in keys:  
                if(str(cc_sup_str).lower() in str(comment['content']).lower()):
                        ccSuppReq = True
                        print("CC Suppression Request by::"+comment['author']['displayName'])
                        break
                if(str(tics_sup_str).lower() in str(comment['content']).lower()):
                        ticsSuppReq = True
                        print("TICS Suppression Request by::"+comment['author']['displayName'])
                        break
                if(str(re_supp_str).lower() in str(comment['content']).lower()):
                        reSuppReq = True
                        print("Resharper Suppression Request by::"+comment['author']['displayName'])
                        break
                if(str(pps_supp_str).lower() in str(comment['content']).lower()):
                        ppsSuppReq = True
                        print("PPS Suppression Request by::"+comment['author']['displayName'])
                        break        

    for change in _changesInPullRequest['value']:
       _comments = change['comments']
       for comment in _comments:
            keys=comment.keys()
            app_ok = comment['author']['displayName'] in excep_app
            if not 'isDeleted' in keys:
                if app_ok and ccSuppReq and (str(comment['content']).lower()  in str(ccexcep_str).lower()): 
                  ccexcep_com =  comment['content']
                  ccexcep_com_auth = comment['author']['displayName']
                  resetCCpassGates = True                  
                  break
                if app_ok and ticsSuppReq and (str(comment['content']).lower()  in str(ticsexcep_str).lower()): 
                  ticsexcep_com = comment['content']
                  ticsexcep_com_auth = comment['author']['displayName']
                  resetTICSpassGates = True                  
                  break 
                if app_ok and reSuppReq and (str(comment['content']).lower()  in str(resharpexcep_str).lower()): 
                  resharpexcep_com = comment['content']
                  resharpexcep_com_auth = comment['author']['displayName']
                  resetRepassGates = True                  
                  break
                if app_ok and ppsSuppReq and (str(comment['content']).lower()  in str(ppsexcep_str).lower()):                         
                  ppsexcep_com = comment['content']
                  ppsexcep_com_auth = comment['author']['displayName']
                  resetPPSGates = True
                  break  

            else:
                print(comment['author']['displayName']+ " has deleted comment.")      
               

    if resetCCpassGates:       
            print(ccexcep_com_auth)
            print(ccexcep_com)
            os.environ["ccpassgates"] = "True"
            print("ccpassgates::"+os.environ["ccpassgates"])
            print (f'##vso[task.setvariable variable=ccpassgates]{os.environ["ccpassgates"]}')
                
    else: 
            os.environ["ccpassgates"] = ""   
            print("ccpassgates::"+os.environ["ccpassgates"])
            
    if resetTICSpassGates:       
            print(ticsexcep_com_auth)
            print(ticsexcep_com)
            os.environ["ticspassgates"] = "True"
            print("ticspassgates::"+os.environ["ticspassgates"])
            print (f'##vso[task.setvariable variable=ticspassgates]{os.environ["ticspassgates"]}')
                
    else: 
            os.environ["ticspassgates"] = ""   
            print("ticspassgates::"+os.environ["ticspassgates"])
            
    if resetRepassGates:       
            print(resharpexcep_com_auth)
            print(resharpexcep_com)
            os.environ["resharpassgates"] = "True"
            print("resharpassgates::"+os.environ["resharpassgates"])
            print (f'##vso[task.setvariable variable=resharpassgates]{os.environ["resharpassgates"]}')
                
    else: 
            os.environ["resharpassgates"] = ""   
            print("resharpassgates::"+os.environ["resharpassgates"])

    if resetPPSGates:       
            print(ppsexcep_com_auth)
            print(ppsexcep_com)
            os.environ["ppspassgates"] = "True"
            print("ppspassgates::"+os.environ["ppspassgates"])
            print (f'##vso[task.setvariable variable=ppspassgates]{os.environ["ppspassgates"]}')
                
    else: 
            os.environ["ppspassgates"] = ""   
            print("ppspassgates::"+os.environ["ppspassgates"])



if __name__ == '__main__':
    main()      