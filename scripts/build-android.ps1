param(
    [ValidateSet('debug', 'release')][string]$Mode = 'debug',
    [string]$ApiBaseUrl = ''
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$Root = Split-Path -Parent $PSScriptRoot
$Flutter = Join-Path $Root '.local/tools/flutter/bin/flutter.bat'
if ($env:ANDROID_HOME) {
    & $Flutter config --android-sdk $env:ANDROID_HOME | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Could not select the project Android SDK' }
}
$Arguments = @('build', 'apk', "--$Mode", '--no-pub')
if ($ApiBaseUrl) { $Arguments += "--dart-define=API_BASE_URL=$ApiBaseUrl" }
Push-Location (Join-Path $Root 'apps/quiz')
try {
    & $Flutter @Arguments
    if ($LASTEXITCODE -ne 0) { throw "Android $Mode build failed" }
} finally { Pop-Location }
