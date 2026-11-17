param([string]$Address='127.0.0.1:8080')
$ErrorActionPreference='Stop'
$Root=Split-Path -Parent $PSScriptRoot
& (Join-Path $Root '.local/build/api.exe') -db (Join-Path $Root '.local/data/quiz.sqlite') -web (Join-Path $Root 'apps/quiz/build/web') -addr $Address -allow-draft
exit $LASTEXITCODE
