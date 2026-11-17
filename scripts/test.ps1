param([switch]$ExpectFailure, [string]$Evidence='sqlite')
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$EvidenceDir = Join-Path $ProjectRoot ('.local/tdd/' + $Evidence)
New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null
$LogName = if ($ExpectFailure) { 'red.txt' } else { 'green.txt' }
Push-Location (Join-Path $ProjectRoot 'server')
try {
    $PreviousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & go test -count=1 -v ./... 2>&1 | Tee-Object -FilePath (Join-Path $EvidenceDir $LogName)
    $TestExitCode = $LASTEXITCODE
    $ErrorActionPreference = $PreviousPreference
} finally { Pop-Location }
if ($ExpectFailure) {
    if ($TestExitCode -eq 0) { throw 'Expected a failing RED test' }
    Write-Output "RED confirmed; test exit code $TestExitCode"
    exit 0
}
exit $TestExitCode
