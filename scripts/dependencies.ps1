$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
Push-Location (Join-Path $ProjectRoot 'server')
try {
    & go get modernc.org/sqlite@v1.62.0
    if ($LASTEXITCODE -ne 0) { throw 'SQLite driver download failed' }
} finally { Pop-Location }
