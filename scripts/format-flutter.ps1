param([switch]$Check)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$env:DART_SUPPRESS_ANALYTICS='true'
$env:APPDATA=Join-Path $ProjectRoot '.local/config/appdata'
$Dart=Join-Path $ProjectRoot '.local/tools/flutter/bin/cache/dart-sdk/bin/dart.exe'
$FormatArguments=@('format')
if($Check){$FormatArguments+=@('--output=none','--set-exit-if-changed')}
$FormatArguments+=@((Join-Path $ProjectRoot 'apps/quiz/lib'),(Join-Path $ProjectRoot 'apps/quiz/test'))
& $Dart @FormatArguments
exit $LASTEXITCODE
