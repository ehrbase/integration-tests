<#
.SYNOPSIS
    PoC script (ran locally) for the Xray Cloud Robot Framework workflow:
    authenticate -> upload output.xml as a Test Execution -> ensure target
    folder exists -> move tests into that folder.

.NOTES
    STATUS: Doc/PoC only, not wired into CI. Lives at repo root as a reference
    until the real implementation (xray_prepare.py / penJiraXrayExport) replaces it.

.PARAMETER ProjectId
    Numeric Xray/Jira project ID (not the key). CDR = 10015.

.PARAMETER FolderPath
    Target path in the Xray test repository, e.g. "/open-ehrbase/..."

.PARAMETER TestExecutionIssueId
    Jira internal issueId of the Test Execution to pull tests from (used with -MoveFromExecution).

.PARAMETER TestIssueIds
    Explicit list of test issueIds to move into FolderPath.

.PARAMETER TestExecInfoJson
    Path to testExecInfo.json for the robot multipart import.

.PARAMETER OutputXmlPath
    Path to the Robot Framework output.xml to import.

.EXAMPLE
    .\xray_robot_upload_and_organize.ps1 -ProjectId 10015 -FolderPath "/open-ehrbase/STORED_QUERY" `
        -TestExecInfoJson .\testExecInfo.json -OutputXmlPath .\results\output.xml -MoveFromExecution

.EXAMPLE
    .\xray_robot_upload_and_organize.ps1 -ProjectId 10015 -FolderPath "/open-ehrbase/STORED_QUERY" `
        -TestIssueIds "136671","136672","136673" -SkipImport
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectId,

    [Parameter(Mandatory = $true)]
    [string]$FolderPath,

    [string]$TestExecInfoJson = ".\testExecInfo.json",
    [string]$OutputXmlPath    = ".\results\output.xml",

    [string]$TestExecutionIssueId,
    [string[]]$TestIssueIds,

    [switch]$MoveFromExecution,
    [switch]$SkipImport,

    [string]$XrayClientId     = $env:XRAY_CLIENT_ID,
    [string]$XrayClientSecret = $env:XRAY_CLIENT_SECRET
)

$ErrorActionPreference = "Stop"

$AuthUrl    = "https://xray.cloud.getxray.app/api/v2/authenticate"
$GraphqlUrl = "https://xray.cloud.getxray.app/api/v2/graphql"
$ImportUrl  = "https://xray.cloud.getxray.app/api/v2/import/execution/robot/multipart"

# --ssl-no-revoke needed on corp network (OCSP check hangs otherwise)
$CurlSslFlag = "--ssl-no-revoke"

# Step 1 - Authenticate
function Get-XrayToken {
    param([string]$ClientId, [string]$ClientSecret)

    if (-not $ClientId -or -not $ClientSecret) {
        throw "XRAY_CLIENT_ID / XRAY_CLIENT_SECRET not set. Pass -XrayClientId/-XrayClientSecret or set them as env vars."
    }

    $body = @{
        client_id     = $ClientId
        client_secret = $ClientSecret
    } | ConvertTo-Json -Compress

    $token = Invoke-RestMethod -Uri $AuthUrl -Method POST -ContentType "application/json" -Body $body
    Write-Host "Authenticated, token acquired."
    return $token
}

# Step 2 - Upload output.xml
function Import-RobotResults {
    param(
        [string]$Token,
        [string]$InfoJsonPath,
        [string]$OutputXmlPath
    )

    if (-not (Test-Path $InfoJsonPath)) { throw "testExecInfo.json not found at $InfoJsonPath" }
    if (-not (Test-Path $OutputXmlPath)) { throw "output.xml not found at $OutputXmlPath" }

    Write-Host "Uploading $OutputXmlPath as a new Test Execution..."
    $result = curl.exe -s -X POST $ImportUrl `
        -H "Authorization: Bearer $Token" `
        -F "info=@$InfoJsonPath" `
        -F "results=@$OutputXmlPath"

    Write-Host "Import response: $result"
    return $result | ConvertFrom-Json
}

# GraphQL helper - query goes through a temp file (avoids quoting issues)
function Invoke-XrayGraphQL {
    param(
        [string]$Token,
        [string]$Query,
        [string]$TmpFile = "gql_tmp.json"
    )

    $payload = @{ query = $Query } | ConvertTo-Json -Compress
    $payload | Out-File -Encoding utf8 -FilePath $TmpFile

    $response = curl.exe -s -X POST $GraphqlUrl `
        -H "Authorization: Bearer $Token" `
        -H "Content-Type: application/json" `
        $CurlSslFlag `
        -d "@$TmpFile"

    Remove-Item $TmpFile -ErrorAction SilentlyContinue
    return $response | ConvertFrom-Json
}

# Step 3 - Ensure target folder exists
function New-XrayFolder {
    param([string]$Token, [string]$ProjectId, [string]$FolderPath)

    Write-Host "Ensuring folder '$FolderPath' exists in project $ProjectId..."
    $query = "mutation { createFolder(projectId: `"$ProjectId`", path: `"$FolderPath`") { folder { name } } }"
    $result = Invoke-XrayGraphQL -Token $Token -Query $query

    if ($result.errors) {
        # already-exists error is fine, not fatal
        Write-Host "createFolder returned errors (likely already exists): $($result.errors | ConvertTo-Json -Compress)"
    } else {
        Write-Host "Folder ready: $($result.data.createFolder.folder.name)"
    }
}

# Step 3b - Get test issueIds from an execution
function Get-TestIssueIdsFromExecution {
    param([string]$Token, [string]$TestExecutionIssueId)

    $query = "{ getTestExecution(issueId: `"$TestExecutionIssueId`") { tests(limit: 100) { results { issueId jira(fields: [`"key`"]) } } } }"
    $result = Invoke-XrayGraphQL -Token $Token -Query $query

    if ($result.errors) {
        throw "getTestExecution failed: $($result.errors | ConvertTo-Json -Compress)"
    }

    $tests = $result.data.getTestExecution.tests.results
    Write-Host "Found $($tests.Count) tests on execution $TestExecutionIssueId"
    return $tests | ForEach-Object { $_.issueId }
}

# Step 4 - Move tests into folder
function Move-TestsToFolder {
    param([string]$Token, [string[]]$IssueIds, [string]$FolderPath)

    foreach ($issueId in $IssueIds) {
        $query = "mutation { updateTestFolder(issueId: `"$issueId`", folderPath: `"$FolderPath`") }"
        $result = Invoke-XrayGraphQL -Token $Token -Query $query

        if ($result.errors) {
            Write-Host "  [$issueId] FAILED: $($result.errors | ConvertTo-Json -Compress)"
        } else {
            Write-Host "  [$issueId] moved to $FolderPath"
        }
    }
}

# Main
$XrayToken = Get-XrayToken -ClientId $XrayClientId -ClientSecret $XrayClientSecret

$createdExecutionIssueId = $TestExecutionIssueId

if (-not $SkipImport) {
    $importResult = Import-RobotResults -Token $XrayToken -InfoJsonPath $TestExecInfoJson -OutputXmlPath $OutputXmlPath
    # capture created execution id so -MoveFromExecution can chain off it
    if ($importResult.testExecIssue.id) {
        $createdExecutionIssueId = $importResult.testExecIssue.id
        Write-Host "Created Test Execution issueId: $createdExecutionIssueId (key: $($importResult.testExecIssue.key))"
    }
}

New-XrayFolder -Token $XrayToken -ProjectId $ProjectId -FolderPath $FolderPath

$idsToMove = $TestIssueIds
if (-not $idsToMove -and $MoveFromExecution) {
    if (-not $createdExecutionIssueId) {
        throw "-MoveFromExecution was set but no Test Execution issueId is available (import skipped and -TestExecutionIssueId not provided)."
    }
    $idsToMove = Get-TestIssueIdsFromExecution -Token $XrayToken -TestExecutionIssueId $createdExecutionIssueId
}

if ($idsToMove) {
    Move-TestsToFolder -Token $XrayToken -IssueIds $idsToMove -FolderPath $FolderPath
} else {
    Write-Host "No test issueIds to move (pass -TestIssueIds or -MoveFromExecution / -TestExecutionIssueId)."
}

Write-Host "Done."