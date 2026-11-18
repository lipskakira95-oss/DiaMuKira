param([switch]$Check)
$ErrorActionPreference='Stop'
$Root=Split-Path -Parent $PSScriptRoot
Push-Location (Join-Path $Root 'apps/quiz')
try {
 & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'flutter.ps1') pub run build_runner build
 if($LASTEXITCODE -ne 0){throw 'Drift code generation failed'}
} finally {Pop-Location}
if($Check){
 & git -C $Root diff --exit-code -- apps/quiz/lib/data/local_database.g.dart
 if($LASTEXITCODE -ne 0){throw 'Generated Drift code is not up to date'}
}
