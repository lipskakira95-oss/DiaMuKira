param(
 [string]$ApiBaseUrl='',
 [switch]$OfflineOnly
)
$ErrorActionPreference='Stop'
$apiUri=$null
if($ApiBaseUrl -and (-not [Uri]::TryCreate($ApiBaseUrl,[UriKind]::Absolute,[ref]$apiUri) -or $apiUri.Scheme -ne 'https')){throw 'Release API URL must be absolute HTTPS'}
if($ApiBaseUrl -and $OfflineOnly){throw 'Choose an HTTPS API or OfflineOnly, not both'}
$Root=Split-Path -Parent $PSScriptRoot
$arguments=@('build','web','--no-pub','--no-web-resources-cdn','--no-wasm-dry-run')
if($ApiBaseUrl){$arguments += "--dart-define=API_BASE_URL=$ApiBaseUrl"}
if($OfflineOnly){$arguments += '--dart-define=OFFLINE_ONLY=true'}
Push-Location (Join-Path $Root 'apps/quiz')
try {
 & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'flutter.ps1') @arguments
 if($LASTEXITCODE -ne 0){throw 'Flutter web build failed'}
} finally {Pop-Location}
