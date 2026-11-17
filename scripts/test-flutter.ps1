param([switch]$ExpectFailure, [string]$Evidence='flutter')
$ErrorActionPreference='Stop'
$Root=Split-Path -Parent $PSScriptRoot
$LogDir=Join-Path $Root ('.local/tdd/'+$Evidence)
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$LogName=if($ExpectFailure){'red.txt'}else{'green.txt'}
Push-Location (Join-Path $Root 'apps/quiz')
try {
 $ErrorActionPreference='Continue'
 & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'flutter.ps1') test --no-pub --reporter expanded 2>&1 | Tee-Object -FilePath (Join-Path $LogDir $LogName)
 $Result=$LASTEXITCODE
} finally { Pop-Location }
if($ExpectFailure){if($Result -eq 0){throw 'Expected RED before implementation'};Write-Output "RED confirmed: $Result";exit 0}
exit $Result
