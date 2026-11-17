$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
Push-Location (Join-Path $ProjectRoot 'tests/browser')
try {
 & go mod tidy
 if($LASTEXITCODE -ne 0){throw 'Browser dependencies failed'}
 & gofmt -w main.go
 if($LASTEXITCODE -ne 0){throw 'Browser test formatting failed'}
} finally {Pop-Location}
