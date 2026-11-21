param(
 [string]$Url='http://127.0.0.1:8080/',
 [string]$Chrome='C:/Program Files/Google/Chrome/Application/chrome.exe',
 [string]$Profile=''
)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
Push-Location (Join-Path $ProjectRoot 'tests/browser')
try {
 if(-not $Profile){$Profile=Join-Path $ProjectRoot '.local/browser-smoke'}
 & go mod download
 if($LASTEXITCODE -ne 0){throw 'Browser test dependencies failed'}
 & go run . -url $Url -chrome $Chrome -profile $Profile
 if($LASTEXITCODE -ne 0){throw 'Browser smoke failed'}
} finally {Pop-Location}
