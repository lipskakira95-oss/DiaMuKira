$ErrorActionPreference='Stop'
$Root=Split-Path -Parent $PSScriptRoot
Push-Location (Join-Path $Root 'apps/quiz')
try {
 & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'flutter.ps1') build web --no-pub --no-web-resources-cdn --no-wasm-dry-run
 if($LASTEXITCODE -ne 0){throw 'Flutter web build failed'}
} finally {Pop-Location}
