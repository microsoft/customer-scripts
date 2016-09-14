
$buildid=$env:BUILD_BUILDID
$tfsurl=$env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
$teamproject=$env:SYSTEM_TEAMPROJECT
$builduri=$env:BUILD_BUILDURI

Write-Host $buildid
Write-Host $tfsurl
Write-Host $teamproject
Write-Host $builduri

$headers=@{
    Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"
}

# get test run with builduri
# http://localhost:8080/tfs/DefaultCollection/testproject/_apis/test/runs?buildUri=vstfs:///Build/Build/43
$testrun=Invoke-RestMethod -Uri $tfsurl$teamproject/_apis/test/runs?buildUri=$builduri -Method Get -Headers $headers
$testrunid=$testrun.value.id

Write-Host $testrunid

# testrunid=result.id
# get test run attachments
# http://localhost:8080/tfs/DefaultCollection/testproject/_apis/test/runs/33/attachments
Write-Host $tfsurl$teamproject/_apis/test/runs/$testrunid/attachments
$attachments=Invoke-RestMethod -Uri $tfsurl$teamproject/_apis/test/runs/$testrunid/attachments -Method Get  -Headers $headers
$trxattachments = $attachments | where { $_.value.filename.endswith(".trx") } 

if($trxattachments -eq $null -or $trxattachments.count -eq 0)
{ 
  throw "no test run attachments found of type trx"
}

$trxattachments= $trxattachments | Sort-Object { $_.value.createddate }
$trxattachmentid=$trxattachments[0].value.id

Write-Host $trxattachmentid

# get trx - result.filename; result.id
# download trx
# http://localhost:8080/tfs/DefaultCollection/testproject/_apis/test/runs/33/attachments/26
$trx=Invoke-RestMethod -Uri $tfsurl$teamproject/_apis/test/runs/$testrunid/attachments/$trxattachmentid -Method Get  -Headers $headers
$trxxml=[xml]$trx.substring($trx.IndexOf("TestRun")-1)
$outcome=$trxxml.TestRun.ResultSummary.outcome

if($outcome -eq "failed")
{
 throw "ordered test has failed"
}

# check if trx is ordered test
# return failure code if ordered test has failed


# Invoke-RestMethod -Uri "$tfsurl/$teamproject/_apis/build/builds/$buildid?api-version=2.0 -Method Get