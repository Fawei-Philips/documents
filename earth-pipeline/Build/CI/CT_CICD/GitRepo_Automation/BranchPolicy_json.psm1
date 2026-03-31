class BranchPolicy_json {
    $refName
    $repoid
    $policyid
    BranchPolicy_json($refName, $repoid, $policyid){
        $this.refName = $refName
        $this.repoid  = $repoid
        $this.policyid = $policyid
    }

    [string]minimum_number_of_reviewers(){
        $jsonBody = '{
            "isEnabled": true,
            "isBlocking": true,
            "isDeleted": false,
            "settings": {
                "minimumApproverCount": 2,
                "creatorVoteCounts": false,
                "allowDownvotes": false,
                "resetOnSourcePush": true,
                "blockLastPusherVote": false,
                "scope": [
                    {
                        "refName": "refs/heads/'+$this.refName+'",
                        "matchKind": "Exact",
                        "repositoryId": "'+$this.repoid+'"
                    }
                ]
            },
            "type": {
                "id": "'+$this.policyid+'",
                "displayName": "Minimum number of reviewers"
            }
        }'
        return $jsonBody
    }


    [string]comment_requirements(){
        $jsonBody = '{
            "isEnabled": true,
            "isBlocking": true,
            "isDeleted": false,
            "settings": {
                "scope": [
                    {
                        "refName": "refs/heads/'+$this.refName+'",
                        "matchKind": "Exact",
                        "repositoryId": "'+$this.repoid+'"
                    }
                ]
            },
                "type": {
                    "id": "'+$this.policyid+'",
                    "displayName": "Comment requirements"
                }
            }'
            return $jsonBody
    }
    [string]require_a_merge_strategy(){
        $jsonBody = '{
            "isEnabled": true,
            "isBlocking": true,
            "isDeleted": false,
            "settings": {
                "allowSquash": true,
                "scope": [
                    {
                        "refName": "refs/heads/'+$this.refName+'",
                        "matchKind": "Exact",
                        "repositoryId": "'+$this.repoid+'"
                    }
                ]
            },
            "type": {
                "id": "'+$this.policyid+'",
                "displayName": "Require a merge strategy"
            }
        }'
        return $jsonBody
    }

}