param([string]$Url='http://127.0.0.1:8080/',[string]$Chrome='C:/Program Files/Google/Chrome/Application/chrome.exe')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
Push-Location (Join-Path $ProjectRoot 'tests/browser')
try {
 & go mod download
 if($LASTEXITCODE -ne 0){throw 'Browser test dependencies failed'}
 & go run . -url $Url -chrome $Chrome -profile (Join-Path $ProjectRoot '.local/browser-smoke')
 if($LASTEXITCODE -ne 0){throw 'Browser smoke failed'}
} finally {Pop-Location}
