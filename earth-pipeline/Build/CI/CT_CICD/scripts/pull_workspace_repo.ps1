function Pull-WorkSpaceCode {
    param(
        [string]$BackupRepoPath,
        [string]$InternalFolderName,
        [string]$LocalPath
    )
    Write-Host "Src: $BackupRepoPath\$InternalFolderName\*"
    Write-Host "Dest: $LocalPath\"
    Copy-Item -Path "$BackupRepoPath\$InternalFolderName\*" -Destination "$LocalPath\" -Recurse -Force
    Set-Location "$LocalPath"

    $prId = $env:SYSTEM_PULLREQUEST_PULLREQUESTID
    if(-not [string]::IsNullOrEmpty($prId)) {
        Write-Host "PR ID: $prId"
        git pull
        git fetch origin pull/$prId/merge:pr_merge_tmp
        git checkout pr_merge_tmp
        git submodule update --init --recursive
    }
    elseif ($env:BUILD_SOURCEBRANCH -match '^refs/heads/(.*)$') {
        $branch = $matches[1]
        Write-Host "branch name: $branch"
        git pull origin $branch
        git checkout $branch
        git submodule update --init --recursive
    }
    elseif ($env:BUILD_SOURCEBRANCH -match '^refs/tags/(.*)$') {
        $tagName = $matches[1]
        Write-Host "Tag name: $tagName"
        $branch = "main"
        Write-Host "default branch name: $branch"
        git pull origin $branch
        git checkout $branch
        git reset --hard $tagName
        git submodule update --init --recursive
    }
    else {
        $branch = "main"
        Write-Host "default branch name: $branch"
        git pull origin $branch
        git checkout $branch
        git submodule update --init --recursive
    }
}

# do not use