param([string]$Device = '')
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$Root = Split-Path -Parent $PSScriptRoot
$Flutter = Join-Path $Root '.local/tools/flutter/bin/flutter.bat'
if ($env:ANDROID_HOME) {
    & $Flutter config --android-sdk $env:ANDROID_HOME | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Could not select the project Android SDK' }
}
if (-not $Device) {
    $Device = (& $Flutter devices --machine | ConvertFrom-Json |
        Where-Object { $_.targetPlatform -like 'android*' } |
        Select-Object -First 1 -ExpandProperty id)
}
if (-not $Device) { throw 'No running Android emulator or device found.' }
Push-Location (Join-Path $Root 'apps/quiz')
try {
    & $Flutter test integration_test/android_smoke_test.dart -d $Device --no-pub
    if ($LASTEXITCODE -ne 0) { throw 'Android smoke failed' }
} finally { Pop-Location }
