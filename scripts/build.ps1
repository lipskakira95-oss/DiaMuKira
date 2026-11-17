$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$OutputDir = Join-Path $ProjectRoot '.local/build'
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
Push-Location (Join-Path $ProjectRoot 'server')
try {
    & go fmt ./...
    if ($LASTEXITCODE -ne 0) { throw 'go fmt failed' }
    & go mod tidy
    if ($LASTEXITCODE -ne 0) { throw 'go mod tidy failed' }
    & go vet ./...
    if ($LASTEXITCODE -ne 0) { throw 'go vet failed' }
    & go build -o (Join-Path $OutputDir 'contentimport.exe') ./cmd/contentimport
    if ($LASTEXITCODE -ne 0) { throw 'Importer build failed' }
    & go build -o (Join-Path $OutputDir 'api.exe') ./cmd/api
    if ($LASTEXITCODE -ne 0) { throw 'API build failed' }
} finally { Pop-Location }
