$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
Push-Location (Join-Path $ProjectRoot 'server')
try {
 & go run ./cmd/contentimport
 if ($LASTEXITCODE -ne 0) { throw 'Content import failed' }
 & go run ./cmd/contentexport
 if ($LASTEXITCODE -ne 0) { throw 'Content export failed' }
} finally { Pop-Location }
