param(
    [ValidateSet('debug', 'release')][string]$Mode = 'debug',
    [ValidateSet('apk', 'appbundle', 'both')][string]$Target = 'apk',
    [string]$ApiBaseUrl = '',
    [switch]$OfflineOnly
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$Root = Split-Path -Parent $PSScriptRoot
$Flutter = Join-Path $Root '.local/tools/flutter/bin/flutter.bat'
if ($env:ANDROID_HOME) {
    & $Flutter config --android-sdk $env:ANDROID_HOME | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Could not select the project Android SDK' }
}
$apiUri = $null
if ($ApiBaseUrl -and (-not [Uri]::TryCreate($ApiBaseUrl, [UriKind]::Absolute, [ref]$apiUri) -or $apiUri.Scheme -ne 'https')) {
    throw 'Release API URL must be absolute HTTPS'
}
if ($ApiBaseUrl -and $OfflineOnly) { throw 'Choose an HTTPS API or OfflineOnly, not both' }
if ($Mode -eq 'release' -and -not $ApiBaseUrl -and -not $OfflineOnly) {
    throw 'Release builds require -ApiBaseUrl https://... or -OfflineOnly for a preview'
}
$Targets = if ($Target -eq 'both') { @('apk', 'appbundle') } else { @($Target) }
Push-Location (Join-Path $Root 'apps/quiz')
try {
    foreach ($BuildTarget in $Targets) {
        $Arguments = @('build', $BuildTarget, "--$Mode")
        # Flutter must regenerate the release plugin registrant after pub get;
        # --no-pub can leave the dev-only integration_test plugin in that file.
        if ($Mode -ne 'release') { $Arguments += '--no-pub' }
        if ($ApiBaseUrl) { $Arguments += "--dart-define=API_BASE_URL=$ApiBaseUrl" }
        if ($OfflineOnly) { $Arguments += '--dart-define=OFFLINE_ONLY=true' }
        & $Flutter @Arguments
        if ($LASTEXITCODE -ne 0) { throw "Android $Mode $BuildTarget build failed" }
    }
} finally { Pop-Location }
